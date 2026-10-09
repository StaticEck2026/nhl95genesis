#!/usr/bin/env python3
"""Locate the routines and tables of a built reference game (NHL 94) in a target ROM (NHL 95)
and write the target segment map.

  python3 tools/fingerprint_map.py --ref ../NHL94Genesis [--overrides tools/segmap95_overrides.json]

The reference repo must be built first (tools/build_ref.sh): this reads its SNASM listing
`output/<game> .lst`, its ROM, and the include order in src/<game>.asm.

Method
  1. Reference units: every global label span in every reference segment, split into
     same-kind runs (code / data). Code runs become normalized 68k tokens (segmap_lib.norm_insn);
     data runs keep raw bytes with symbolic dc.w / dc.l operands masked.
  2. Target stream: the target ROM is decoded into the same tokens by a linear sweep that
     restarts at every code run of the IDA listing.
  3. Index: K-token windows of reference code and W-byte windows of reference data go into hash
     tables. One pass over the target stream / ROM votes for (unit, diagonal) pairs.
  4. Refine the best diagonals with difflib (code) or a byte compare (data): start, end, similarity.
  5. Place globally (the target is re-linked routine by routine, so no per-file chain): unique
     candidates first, then candidates next to placed reference neighbours, then overlaps are
     resolved; gaps between placed neighbours are searched for the missing units (local_fill).
  6. Operand xrefs: identical aligned instructions pair reference and target operand addresses
     (and dc.l pointer slots of placed data); unplaced units go where those pairs point.
  7. Map: target runs per reference file, small runs absorbed by their neighbours (reported as
     moved), gaps assigned by the rom references into them and then by reference order, big
     unmatched gaps split into code and data by the IDA listing, every cut snapped to a label or
     listing line outside any untrusted stretch, then the overrides file. The map tiles the ROM
     from 0 to its size.
"""

import argparse
import bisect
import difflib
import json
import os
import re
import sys
import time
from collections import Counter, defaultdict

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import segmap_lib as L  # noqa: E402

K = 8            # tokens per code window
W = 16           # bytes per data window
W_STRIDE = 4     # reference data window stride
MAX_OCC = 4      # a window seen more often than this in the reference is not a seed
MIN_SIM = 0.5    # a unit placement below this similarity is not a match


def log(msg):
    print(msg, flush=True)


# ---------------------------------------------------------------------------
# Reference side
# ---------------------------------------------------------------------------

class Unit:
    __slots__ = ("id", "seg", "name", "start", "end", "kind", "tokens", "taddr", "cands", "pick")

    def __init__(self, uid, seg, name, start, end, kind):
        self.id, self.seg, self.name, self.start, self.end, self.kind = uid, seg, name, start, end, kind
        self.tokens, self.taddr, self.cands, self.pick = None, None, [], None

    @property
    def size(self):
        return self.end - self.start


def load_reference(ref_dir, game):
    top = os.path.join(ref_dir, "src", game + ".asm")
    files = re.findall(r"^\s*include\s+(\w+\.asm)", open(top, encoding="latin-1").read(), re.M | re.I)
    files = [f for f in files if not f.lower().startswith("stubinc")]
    rom = open(os.path.join(ref_dir, "lst", game + ".bin"), "rb").read()
    labels, kinds, seg_starts = L.parse_built_listing(os.path.join(ref_dir, "output", game + " .lst"), files)

    kind = bytearray(len(rom))  # 0 code, 1 data, 2 masked data
    code = {"code": 0, "data": 1, "ptr": 2}
    for i, (a, k) in enumerate(kinds):
        b = kinds[i + 1][0] if i + 1 < len(kinds) else len(rom)
        if b > a:
            kind[a:b] = bytes([code[k]]) * (b - a)

    fill_end = len(rom)
    while fill_end > 0 and rom[fill_end - 1] == 0xFF:
        fill_end -= 1
    fill_end += fill_end & 1

    segs = []
    ordered = sorted((a, files.index(f), f[:-4]) for f, a in seg_starts.items())
    ordered = [(a, name) for a, _, name in ordered]
    for i, (a, name) in enumerate(ordered):
        b = ordered[i + 1][0] if i + 1 < len(ordered) else fill_end
        if b > a:
            segs.append((name, a, b))
    return rom, kind, labels, segs, fill_end


def build_units(rom, kind, labels, segs):
    units = []
    label_addrs = sorted({a for a, _ in labels})
    names = defaultdict(list)
    for a, n in labels:
        names[a].append(n)
    for seg, s, e in segs:
        cuts = [s] + [a for a in label_addrs if s < a < e] + [e]
        for i in range(len(cuts) - 1):
            a, b = cuts[i], cuts[i + 1]
            base = "/".join(names.get(a, [])) or "%s+$%X" % (seg, a - s)
            p = a
            while p < b:
                k = 0 if kind[p] == 0 else 1
                q = p
                while q < b and (0 if kind[q] == 0 else 1) == k:
                    q += 1
                nm = base if p == a else "%s+$%X" % (base.split("/")[0], p - a)
                units.append(Unit(len(units), seg, nm, p, q, "code" if k == 0 else "data"))
                p = q
    for u in units:
        if u.kind == "code":
            toks, addrs = [], []
            L.decode_run(rom, u.start, u.end, toks, addrs)
            u.tokens, u.taddr = toks, addrs
    return units


# ---------------------------------------------------------------------------
# Target side
# ---------------------------------------------------------------------------

def target_stream(rom, ida_lines):
    starts = []
    prev = None
    for ln in ida_lines:
        if ln.kind == "code" and (prev is None or prev.kind != "code"):
            starts.append(ln.addr)
        prev = ln
    bounds = sorted(set([0, len(rom)] + [s for s in starts if 0 < s < len(rom)]))
    toks, addrs = [], L.u32_array()
    for i in range(len(bounds) - 1):
        L.decode_run(rom, bounds[i], bounds[i + 1], toks, addrs)
    return toks, addrs


# ---------------------------------------------------------------------------
# Matching
# ---------------------------------------------------------------------------

def intern(tokens, table):
    return [table.setdefault(t, len(table)) for t in tokens]


def match_code(units, t95, addr95):
    occ = Counter()
    seeds = defaultdict(list)
    for u in units:
        if u.kind != "code" or len(u.tokens) < K:
            continue
        t = u.tokens
        for i in range(len(t) - K + 1):
            h = hash(tuple(t[i:i + K]))
            occ[h] += 1
            seeds[h].append((u.id, i))
    seeds = {h: v for h, v in seeds.items() if occ[h] <= MAX_OCC}
    votes = defaultdict(Counter)
    get = seeds.get
    for j in range(len(t95) - K + 1):
        hit = get(hash(tuple(t95[j:j + K])))
        if hit:
            for uid, i in hit:
                votes[uid][j - i] += 1
    for uid, diag in votes.items():
        u = units[uid]
        n = len(u.tokens)
        tried = []
        for d, v in diag.most_common(12):
            if any(abs(d - t) < max(n, 8) for t in tried):
                continue
            tried.append(d)
            lo = max(0, d - max(8, n // 4))
            hi = min(len(t95), d + n + max(8, n // 4))
            sm = difflib.SequenceMatcher(None, u.tokens, t95[lo:hi], autojunk=False)
            blocks = [b for b in sm.get_matching_blocks() if b.size]
            m = sum(b.size for b in blocks)
            if not blocks:
                continue
            first, last = blocks[0], blocks[-1]
            j0 = lo + first.b - first.a          # target token where the unit would start
            j1 = lo + last.b + last.size + (n - last.a - last.size)
            j0, j1 = max(lo, j0), min(hi, j1)
            a0 = addr95[j0]
            a1 = addr95[j1] if j1 < len(addr95) else addr95[-1] + 2
            u.cands.append((m / n, a0, a1, v))
            if len(tried) >= 3:
                break
        u.cands.sort(reverse=True)


def match_data(units, rom94, kind94, rom95):
    occ = Counter()
    seeds = defaultdict(list)
    for u in units:
        if u.kind != "data" or u.size < W:
            continue
        for off in range(0, u.size - W + 1, W_STRIDE):
            a = u.start + off
            if 2 in kind94[a:a + W]:
                continue
            w = rom94[a:a + W]
            if len(set(w)) < 4:
                continue
            occ[w] += 1
            seeds[w].append((u.id, off))
    seeds = {w: v for w, v in seeds.items() if occ[w] <= MAX_OCC}
    votes = defaultdict(Counter)
    get = seeds.get
    for p in range(len(rom95) - W + 1):
        hit = get(rom95[p:p + W])
        if hit:
            for uid, off in hit:
                votes[uid][p - off] += 1
    band = 512
    for uid, diag in votes.items():
        u = units[uid]
        mask = kind94[u.start:u.end]
        ref = rom94[u.start:u.end]
        want = sum(1 for k in mask if k != 2) or 1
        tried = []
        for d, v in diag.most_common(8):
            if any(abs(d - t) <= band for t in tried):
                continue
            tried.append(d)
            # Exact compare on the main diagonal, then seed coverage over nearby diagonals so a
            # table with an inserted or dropped run still scores.
            eq = 0
            if 0 <= d and d + u.size <= len(rom95):
                tgt = rom95[d:d + u.size]
                eq = sum(1 for x, y, k in zip(ref, tgt, mask) if k != 2 and x == y)
            hits = sorted((dd, n) for dd, n in diag.items() if abs(dd - d) <= band)
            cov = min(want, sum(n for _, n in hits) * W_STRIDE)
            sim = max(eq, cov) / want
            a0 = max(0, d) if eq >= cov else max(0, min(dd for dd, _ in hits))
            a1 = min(len(rom95), (d if eq >= cov else max(dd for dd, _ in hits)) + u.size)
            u.cands.append((min(1.0, sim), a0, a1, v))
            if len(tried) >= 3:
                break
        u.cands.sort(reverse=True)


def place(units, rom95_size):
    """Pick one target range per unit.

    Pass 1 anchors: a strong candidate (sim >= 0.8, >= 24 bytes) that is unique (no second
    candidate within 0.1 of it). Pass 2: every other unit takes the candidate nearest the address
    its placed same-segment reference neighbours predict; a distant candidate is kept only when it
    is strong and unique (a moved routine). Overlaps go to the higher score."""
    def unique(u):
        c = u.cands
        return c and c[0][0] >= 0.8 and u.size >= 24 and (len(c) == 1 or c[1][0] < c[0][0] - 0.1)

    for u in units:
        u.pick = u.cands[0] if unique(u) else None
    for _ in range(3):
        for i, u in enumerate(units):
            if not u.cands or (u.pick and unique(u)):
                continue
            preds = []
            for j in range(i - 1, max(-1, i - 40), -1):
                p = units[j]
                if p.seg != u.seg:
                    break
                if p.pick and unique(p):
                    preds.append(p.pick[2] + (u.start - p.end))
                    break
            for j in range(i + 1, min(len(units), i + 40)):
                n = units[j]
                if n.seg != u.seg:
                    break
                if n.pick and unique(n):
                    preds.append(n.pick[1] - (n.start - u.end) - u.size)
                    break
            best = None
            for c in u.cands:
                if c[0] < MIN_SIM:
                    continue
                dist = min((abs(c[1] - p) for p in preds), default=1 << 30)
                if dist <= max(2048, 4 * u.size) and (best is None or dist < best[0]):
                    best = (dist, c)
            u.pick = best[1] if best else None
    taken = []
    for u in sorted((u for u in units if u.pick), key=lambda u: -u.pick[0] * u.size):
        a0, a1 = u.pick[1], u.pick[2]
        k = bisect.bisect_left(taken, (a0, a0))
        clash = 0
        for s, e in taken[max(0, k - 2):k + 2]:
            clash += max(0, min(e, a1) - max(s, a0))
        if clash > 0.25 * (a1 - a0):
            u.pick = None
        else:
            bisect.insort(taken, (a0, a1))


def local_fill(units, rom94, kind94, rom95, tok95, addr95):
    """Search for unplaced units in the target gap their placed reference neighbours leave.
    Exact search first; code that changed is aligned with difflib over the gap."""
    placed = 0
    for _ in range(4):
        before = placed
        for i, u in enumerate(units):
            if u.pick:
                continue
            prev = next((units[j] for j in range(i - 1, -1, -1) if units[j].pick), None)
            nxt = next((units[j] for j in range(i + 1, len(units)) if units[j].pick), None)
            if prev and prev.seg != u.seg:
                prev = None
            if nxt and nxt.seg != u.seg:
                nxt = None
            if not prev and not nxt:
                continue
            gap94 = (nxt.start if nxt else u.end) - (prev.end if prev else u.start)
            lo = prev.pick[2] if prev else nxt.pick[1] - 2 * gap94 - 256
            hi = nxt.pick[1] if nxt else prev.pick[2] + 2 * gap94 + 256
            lo, hi = max(0, lo), min(len(rom95), hi)
            if hi - lo < 2 or hi - lo > max(0x2000, 4 * gap94):
                continue
            if u.kind == "data":
                ref = rom94[u.start:u.end]
                if u.size < 4 or 2 in kind94[u.start:u.end]:
                    continue
                p = rom95.find(ref, lo, hi)
                if p >= 0:
                    u.pick = (1.0, p, p + u.size, 0)
            elif u.tokens:
                j0 = bisect.bisect_left(addr95, lo)
                j1 = bisect.bisect_left(addr95, hi)
                n = len(u.tokens)
                for j in range(j0, max(j0, j1 - n + 1)):
                    if tok95[j:j + n] == u.tokens:
                        end = addr95[j + n] if j + n < len(addr95) else len(rom95)
                        u.pick = (1.0, addr95[j], end, 0)
                        break
                if not u.pick and n >= 4 and j1 - j0 <= 4 * n + 64:
                    sm = difflib.SequenceMatcher(None, u.tokens, tok95[j0:j1], autojunk=False)
                    blocks = [b for b in sm.get_matching_blocks() if b.size]
                    m = sum(b.size for b in blocks)
                    if blocks and m / n >= MIN_SIM:
                        s = j0 + blocks[0].b
                        e = j0 + blocks[-1].b + blocks[-1].size
                        u.pick = (m / n, addr95[s], addr95[e] if e < len(addr95) else len(rom95), 0)
            if u.pick:
                placed += 1
        if placed == before:
            break
    return placed


_ADDR_OPS = re.compile(r"(?<![-\w])\$([0-9a-f]+)(\.[wl])?(?!\((?:a\d|sp))")


def _addr_operands(rom, a):
    """ROM-looking operand values of one instruction: absolute, PC-relative, branch targets and
    immediates. A short absolute >= $8000 sign-extends to RAM and is dropped."""
    for _, size, mnem, op in L._md.disasm_lite(rom[a:a + 12], a, 1):
        if mnem.startswith("moveq"):
            return []
        out = []
        for x, sz in _ADDR_OPS.findall(op):
            v = int(x, 16)
            out.append(-1 if (sz == ".w" and v >= 0x8000) or v >= 0xFF0000 else v)
        return out
    return []


def xrefs(units, rom94, kind94, rom95, tok95, addr95, label94):
    """Reference address -> Counter(target address), from operands of aligned identical
    instructions in placed code units and from dc.l pointer slots of placed data units."""
    xmap = defaultdict(Counter)
    for u in units:
        if not u.pick or u.pick[0] < 0.6:
            continue
        a0, a1 = u.pick[1], u.pick[2]
        if u.kind == "code":
            j0 = bisect.bisect_left(addr95, a0)
            j1 = bisect.bisect_left(addr95, a1)
            sm = difflib.SequenceMatcher(None, u.tokens, tok95[j0:j1], autojunk=False)
            for b in sm.get_matching_blocks():
                for k in range(b.size):
                    p94 = u.taddr[b.a + k]
                    p95 = addr95[j0 + b.b + k]
                    o94, o95 = _addr_operands(rom94, p94), _addr_operands(rom95, p95)
                    if len(o94) == len(o95):
                        for v94, v95 in zip(o94, o95):
                            if v94 in label94 and v95 < len(rom95):
                                xmap[v94][v95] += 1
        else:
            delta = a0 - u.start
            p = u.start
            while p + 4 <= u.end:
                if kind94[p] == 2 and kind94[p + 3] == 2 and 0 <= p + delta and p + delta + 4 <= len(rom95):
                    v94 = int.from_bytes(rom94[p:p + 4], "big")
                    v95 = int.from_bytes(rom95[p + delta:p + delta + 4], "big")
                    if v94 in label94 and v95 < len(rom95):
                        xmap[v94][v95] += 1
                    p += 4
                else:
                    p += 2
    return xmap


def place_by_xref(units, xmap, rom94, kind94, rom95, tok95, addr95):
    """Put an unplaced unit at the target address its references vote for."""
    placed = 0
    taken = sorted((u.pick[1], u.pick[2]) for u in units if u.pick)
    for u in units:
        if u.pick or u.start not in xmap:
            continue
        (a95, v), = xmap[u.start].most_common(1)
        total = sum(xmap[u.start].values())
        if v < 0.6 * total:
            continue
        k = bisect.bisect_right(taken, (a95, 1 << 30))
        if k > 0 and taken[k - 1][1] > a95:
            continue
        limit = taken[k][0] if k < len(taken) else len(rom95)
        if u.kind == "code" and u.tokens:
            n = len(u.tokens)
            j0 = bisect.bisect_left(addr95, a95)
            j1 = min(len(tok95), j0 + n + max(16, n // 2))
            sm = difflib.SequenceMatcher(None, u.tokens, tok95[j0:j1], autojunk=False)
            blocks = [b for b in sm.get_matching_blocks() if b.size]
            m = sum(b.size for b in blocks)
            e = j0 + (blocks[-1].b + blocks[-1].size + n - blocks[-1].a - blocks[-1].size if blocks else n)
            a1 = addr95[min(e, len(addr95) - 1)]
            u.pick = (m / n, a95, min(a1, limit), v, "x")
        else:
            a1 = min(a95 + u.size, limit)
            ref, tgt, mask = rom94[u.start:u.start + (a1 - a95)], rom95[a95:a1], kind94[u.start:u.end]
            eq = sum(1 for x, y, kk in zip(ref, tgt, mask) if kk == 2 or x == y)
            u.pick = (eq / max(1, len(ref)), a95, a1, v, "x")
        bisect.insort(taken, (u.pick[1], u.pick[2]))
        placed += 1
    return placed


# ---------------------------------------------------------------------------
# Map
# ---------------------------------------------------------------------------

def interval_union(ranges):
    total, cur_s, cur_e = 0, None, None
    for s, e in sorted(ranges):
        if cur_e is None or s > cur_e:
            if cur_e is not None:
                total += cur_e - cur_s
            cur_s, cur_e = s, e
        else:
            cur_e = max(cur_e, e)
    if cur_e is not None:
        total += cur_e - cur_s
    return total


def covered(ranges, s, e):
    return interval_union([(max(a, s), min(b, e)) for a, b in ranges if min(b, e) > max(a, s)])


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    here = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(here)
    ap.add_argument("--ref", required=True, help="built reference repo (e.g. ../NHL94Genesis)")
    ap.add_argument("--ref-game", default="nhl94")
    ap.add_argument("--rom", default=os.path.join(root, "lst", "nhl95.bin"))
    ap.add_argument("--lst", default=os.path.join(root, "lst", "nhl95.bin.lst"))
    ap.add_argument("--suffix", default="95", help="target file suffix replacing the reference one")
    ap.add_argument("--overrides", default=os.path.join(here, "segmap95_overrides.json"))
    ap.add_argument("--out", default=os.path.join(here, "segmap95.json"))
    ap.add_argument("--units-out", default=None, help="optional per-unit match dump (JSON)")
    args = ap.parse_args()

    t0 = time.time()
    ref_suffix = re.sub(r"^\D+", "", args.ref_game)
    rom94, kind94, labels94, segs94, fill94 = load_reference(args.ref, args.ref_game)
    units = build_units(rom94, kind94, labels94, segs94)
    log("reference: %d segments, %d units (%d code, %d data), %.1fs" % (
        len(segs94), len(units), sum(u.kind == "code" for u in units), sum(u.kind == "data" for u in units), time.time() - t0))

    rom95 = open(args.rom, "rb").read()
    t1 = time.time()
    ida_lines, ida_labels, ida_err = L.parse_ida_listing(args.lst, rom95)
    log("target listing: %d lines, %d labels, %d anchor/decode disagreements, %.1fs" % (
        len(ida_lines), len(ida_labels), len(ida_err), time.time() - t1))
    t1 = time.time()
    tok95, addr95 = target_stream(rom95, ida_lines)
    log("target stream: %d tokens, %.1fs" % (len(tok95), time.time() - t1))

    t1 = time.time()
    table = {}
    tok95 = intern(tok95, table)
    for u in units:
        if u.kind == "code":
            u.tokens = intern(u.tokens, table)
    match_code(units, tok95, addr95)
    log("code match: %.1fs" % (time.time() - t1))
    t1 = time.time()
    match_data(units, rom94, kind94, rom95)
    log("data match: %.1fs" % (time.time() - t1))

    t1 = time.time()
    place(units, len(rom95))
    n_place = sum(1 for u in units if u.pick)
    n_fill = local_fill(units, rom94, kind94, rom95, tok95, addr95)
    label94 = {a for a, _ in labels94}
    n_x = 0
    for _ in range(3):
        xmap = xrefs(units, rom94, kind94, rom95, tok95, addr95, label94)
        got = place_by_xref(units, xmap, rom94, kind94, rom95, tok95, addr95)
        got += local_fill(units, rom94, kind94, rom95, tok95, addr95)
        n_x += got
        if not got:
            break
    log("placement: %d units from candidates, %d from local search, %d from operand references, %.1fs" % (
        n_place, n_fill, n_x, time.time() - t1))

    elapsed_match = time.time() - t0
    result = build_map(args, units, segs94, rom94, kind94, rom95, ida_lines, ida_labels, ida_err, tok95, addr95, ref_suffix, fill94)
    result["runtime_seconds"] = round(time.time() - t0, 1)
    result["match_seconds"] = round(elapsed_match, 1)
    with open(args.out, "w") as fh:
        json.dump(result, fh, indent=1)
    if args.units_out:
        with open(args.units_out, "w") as fh:
            json.dump([{
                "seg": u.seg, "name": u.name, "kind": u.kind, "ref": "$%06X-$%06X" % (u.start, u.end),
                "pick": None if not u.pick else ["%.3f" % u.pick[0], "$%06X" % u.pick[1], "$%06X" % u.pick[2]],
                "cands": [["%.3f" % c[0], "$%06X" % c[1], "$%06X" % c[2], c[3]] for c in u.cands[:3]],
            } for u in units], fh, indent=0)
    log("wrote %s (%.1fs total)" % (args.out, time.time() - t0))


MIN_RUN = 0x200      # a run of one reference file with fewer matched bytes is absorbed by its neighbours
BIG_GAP = 0x1000     # an unmatched stretch this long becomes its own region
MERGE_GAP = 0x800    # same-file placements closer than this form one run


def code_mask(ida_lines, size):
    m = bytearray(size)
    for ln in ida_lines:
        if ln.kind == "code":
            m[ln.addr:ln.addr + ln.size] = b"\1" * ln.size
    return m


def split_gap(lo, hi, cmask):
    """Split [lo, hi) into code / data stretches by the IDA listing, ignoring islands < 64 bytes."""
    parts = []
    p = lo
    while p < hi:
        k = cmask[p]
        q = p
        while q < hi and cmask[q] == k:
            q += 1
        parts.append([p, q, "code" if k else "data"])
        p = q
    merged = []
    for s, e, k in parts:
        if merged and (merged[-1][2] == k or e - s < 64):
            merged[-1][1] = e
        else:
            merged.append([s, e, k])
    return merged


def rom_refs(rom95, ida_lines, units, addr95):
    """(source, target) for every ROM operand of an IDA code line or of a swept instruction inside a
    placed code unit."""
    srcs = {ln.addr for ln in ida_lines if ln.kind == "code"}
    for u in units:
        if u.pick and u.kind == "code":
            j0 = bisect.bisect_left(addr95, u.pick[1])
            j1 = bisect.bisect_left(addr95, u.pick[2])
            srcs.update(addr95[j0:j1])
    out = []
    for a in sorted(srcs):
        for v in _addr_operands(rom95, a):
            if 0x200 <= v < len(rom95):
                out.append((a, v))
    return out


def build_map(args, units, segs94, rom94, kind94, rom95, ida_lines, ida_labels, ida_err, tok95, addr95, ref_suffix, fill94):
    size95 = len(rom95)
    seg_order = [s for s, _, _ in segs94]
    cmask = code_mask(ida_lines, size95)
    line_starts = {ln.addr for ln in ida_lines}
    drift = L.untrusted(ida_err)

    fill_start = size95
    while fill_start > 0 and rom95[fill_start - 1] == 0xFF:
        fill_start -= 1
    fill_start += fill_start & 1

    # 1. Placed intervals; an overlap is trimmed from the later one.
    ivs = []
    for u in sorted((u for u in units if u.pick), key=lambda u: (u.pick[1], -u.pick[2])):
        a0, a1 = u.pick[1], min(u.pick[2], fill_start)
        if ivs and a0 < ivs[-1][1]:
            a0 = ivs[-1][1]
        if a1 - a0 >= 2:
            ivs.append((a0, a1, u))
    placed = {id(u) for _, _, u in ivs}

    by_seg = defaultdict(list)
    for u in units:
        by_seg[u.seg].append(u)
    pos_in_seg = {id(u): i for us in by_seg.values() for i, u in enumerate(us)}

    def missing_after(u):
        us = by_seg[u.seg]
        n = 0
        for v in us[pos_in_seg[id(u)] + 1:]:
            if id(v) in placed:
                break
            n += v.size
        return n

    def missing_before(u):
        us = by_seg[u.seg]
        n = 0
        for v in reversed(us[:pos_in_seg[id(u)]]):
            if id(v) in placed:
                break
            n += v.size
        return n

    # 2. Runs of one reference file.
    runs = []
    for a0, a1, u in ivs:
        r = runs[-1] if runs else None
        if r and r["seg"] == u.seg and a0 - r["end"] < MERGE_GAP:
            r["end"] = a1
            r["own"].append(u)
        else:
            runs.append({"seg": u.seg, "start": a0, "end": a1, "own": [u], "bytes": 0})
    for r in runs:
        r["bytes"] = sum(u.size for u in r["own"])

    def tail_missing(r):
        return missing_after(max(r["own"], key=lambda u: u.start))

    def head_missing(r):
        return missing_before(min(r["own"], key=lambda u: u.start))

    def join(a, b):
        a["start"], a["end"] = min(a["start"], b["start"]), max(a["end"], b["end"])
        if a["seg"] == b["seg"]:
            a["own"] += b["own"]
            a["bytes"] += b["bytes"]

    # 3. Absorb small runs, smallest first. A small run that is followed by a long data gap
    #    its own reference file can explain (unplaced data after it) is kept: it is the head
    #    of a table block whose bytes changed.
    file_size = {s: e - a for s, a, e in segs94}
    while True:
        small = [i for i, r in enumerate(runs)
                 if r["bytes"] < min(MIN_RUN, 0.4 * file_size[r["seg"]]) and not r.get("keep")]
        if not small or len(runs) < 2:
            break
        i = min(small, key=lambda i: runs[i]["bytes"])
        r = runs[i]
        left = runs[i - 1] if i > 0 else None
        right = runs[i + 1] if i + 1 < len(runs) else None
        gl = r["start"] - left["end"] if left else 1 << 30
        gr = right["start"] - r["end"] if right else 1 << 30
        if gr >= BIG_GAP and tail_missing(r) >= 0.25 * gr:
            r["keep"] = True
            continue
        if min(gl, gr) >= BIG_GAP:
            r["keep"] = True
            continue
        if left and right and left["seg"] == right["seg"] and max(gl, gr) < BIG_GAP:
            join(left, r)
            join(left, right)
            del runs[i:i + 2]
        elif gl <= gr:
            join(left, r)
            del runs[i]
        else:
            join(right, r)
            del runs[i]
        j = 0
        while j + 1 < len(runs):
            if runs[j]["seg"] == runs[j + 1]["seg"] and runs[j + 1]["start"] - runs[j]["end"] < BIG_GAP:
                join(runs[j], runs[j + 1])
                del runs[j + 1]
            else:
                j += 1

    # 4. Tile runs and gaps.
    refs = rom_refs(rom95, ida_lines, units, addr95)
    ref_tgts = sorted((t, s) for s, t in refs)

    def votes(lo, hi, side):
        k0 = bisect.bisect_left(ref_tgts, (lo, -1))
        k1 = bisect.bisect_left(ref_tgts, (hi, -1))
        return sum(1 for t, s in ref_tgts[k0:k1] if side["start"] <= s < side["end"])

    def cut_points(lo, hi):
        pts = sorted(a for a, n in ida_labels.items() if lo < a < hi and a not in drift
                     and not n.startswith(("loc_", "locret_")))
        return pts

    rows = []
    pos = 0
    for k, r in enumerate(runs + [None]):
        gap_end = r["start"] if r else fill_start
        left = rows[-1] if rows and rows[-1].get("seg") else None
        if gap_end > pos:
            lo, hi = pos, gap_end
            parts = split_gap(lo, hi, cmask)
            if hi - lo < BIG_GAP and left and r:
                # References from either side decide; with none, the side whose reference
                # file has unplaced units next to the gap takes it; with neither, the left.
                pts = [lo] + cut_points(lo, hi) + [hi]
                best, cut = None, hi
                for c in pts:
                    score = votes(lo, c, left) + votes(c, hi, r)
                    if best is None or score > best:
                        best, cut = score, c
                if best == 0:
                    tm, hm = tail_missing(left), head_missing(r)
                    if hm and not tm:
                        cut = lo
                    elif tm and hm:
                        want = lo + (hi - lo) * tm // (tm + hm)
                        cut = min(pts, key=lambda c: abs(c - want))
                    else:
                        cut = hi
                left["end"] = cut
                if r:
                    r["start"] = cut
            elif hi - lo < BIG_GAP and (left or r):
                if left:
                    left["end"] = hi
                else:
                    r["start"] = lo
            elif left and r and left["seg"] == r["seg"] and all(p[2] == "data" for p in parts):
                left["end"] = hi
            elif left and all(p[2] == "data" for p in parts) and tail_missing(left) >= 0.25 * (hi - lo):
                left["end"] = hi
            else:
                for n, (s, e, kind) in enumerate(parts):
                    if e - s < BIG_GAP and n == 0 and left:
                        left["end"] = e
                    elif e - s < BIG_GAP and n == len(parts) - 1 and r:
                        r["start"] = s
                    elif rows and not rows[-1].get("seg") and rows[-1]["end"] == s and (e - s < BIG_GAP or rows[-1]["kind"] == kind):
                        rows[-1]["end"] = e
                        if rows[-1]["kind"] != kind:
                            rows[-1]["kind"] = "code+data"
                    else:
                        rows.append({"seg": None, "start": s, "end": e, "kind": kind})
        if r:
            if rows and rows[-1].get("seg") == r["seg"]:
                join(rows[-1], r)
            else:
                rows.append(r)
            pos = rows[-1]["end"]
    rows[0]["start"] = 0
    for a, b in zip(rows, rows[1:]):
        b["start"] = a["end"]

    # 5. Snap each start back to a label, else a listing line start, within 64 bytes.
    for i in range(1, len(rows)):
        b = rows[i]["start"]
        floor = rows[i - 1]["start"] + 2
        best = next((a for a in range(b, max(floor, b - 64) - 1, -1) if a in ida_labels and a not in drift), None)
        if best is None:
            best = next((a for a in range(b, max(floor, b - 64) - 1, -1) if a in line_starts and a not in drift), None)
        if best is not None and best != b:
            rows[i]["start"] = best
            rows[i - 1]["end"] = best

    # 6. Overrides: forced cuts with a name, applied on top of the automatic rows.
    overrides = []
    if args.overrides and os.path.exists(args.overrides):
        overrides = json.load(open(args.overrides)).get("cuts", [])
    for ov in sorted(overrides, key=lambda o: int(o["start"].lstrip("$"), 16)):
        s = int(ov["start"].lstrip("$"), 16)
        e = int(ov["end"].lstrip("$"), 16) if ov.get("end") else None
        new = []
        for r in rows:
            pieces = [(r["start"], r["end"])]
            for c in (s, e):
                if c is not None:
                    pieces = [q for a, b in pieces for q in (((a, c), (c, b)) if a < c < b else ((a, b),))]
            for a, b in pieces:
                q = dict(r, start=a, end=b)
                if a >= s and (e is None and a == s or e is not None and b <= e):
                    q.update({k: v for k, v in ov.items() if k not in ("start", "end")})
                    q["seg"] = ov.get("ref")
                    q["override"] = True
                new.append(q)
        rows = new
    # 7. Names, coverage, ordering. Neighbours with one base become one row.
    def base_of(r):
        if r.get("name"):
            return None
        if r.get("base"):
            return r["base"]
        if r.get("seg"):
            return re.sub(re.escape(ref_suffix) + "$", "", r["seg"]) + args.suffix
        return None

    merged = []
    for r in rows:
        p = merged[-1] if merged else None
        if p and p["end"] == r["start"] and (
                (base_of(p) and base_of(p) == base_of(r)) or (p.get("name") and p.get("name") == r.get("name"))):
            p["end"] = r["end"]
            if r.get("note") and r.get("note") not in p.get("note", ""):
                p["note"] = (p.get("note", "") + " " + r["note"]).strip()
        else:
            merged.append(dict(r))
    rows = merged

    counts = Counter(base_of(r) for r in rows if base_of(r))
    seen = Counter()
    out_rows = []
    for r in rows:
        s, e = r["start"], r["end"]
        b = base_of(r)
        if b:
            seen[b] += 1
            name = b if counts[b] == 1 else "%s_%02d" % (b, seen[b])
        else:
            name = r.get("name") or "new%s_%06X" % (args.suffix, s)
        k0 = bisect.bisect_left(ivs, (s, -1))
        while k0 > 0 and ivs[k0 - 1][1] > s:
            k0 -= 1
        pl = []
        for a0, a1, u in ivs[k0:]:
            if a0 >= e:
                break
            if a1 > s:
                pl.append((max(a0, s), min(a1, e), u))
        mix = Counter()
        for a0, a1, u in pl:
            mix[u.seg] += a1 - a0
        ref = r.get("ref") or r.get("seg") or (mix.most_common(1)[0][0] if mix and r.get("base") else None)
        own = [u for _, _, u in pl if u.seg == ref]
        seq = [u.start for _, _, u in pl if u.seg == ref]
        matched = interval_union([(a, b) for a, b, u in pl if u.pick[0] >= MIN_SIM])
        located = interval_union([(a, b) for a, b, u in pl])
        row = {
            "name": name, "start": s, "end": e, "ref": ref,
            "kind": r.get("kind") if not r.get("seg") and not r.get("base") and not r.get("ref") else "match",
            "start_label": ida_labels.get(s),
            "ref_range": [min(u.start for u in own), max(u.end for u in own)] if own else None,
            "matched_pct": round(100.0 * matched / (e - s), 1),
            "located_pct": round(100.0 * located / (e - s), 1),
            "ref_mix": dict(mix.most_common()),
            "out_of_order": sum(1 for x, y in zip(seq, seq[1:]) if y < x),
            "moved_in": ["%s:%s" % (u.seg, u.name) for _, _, u in pl if ref and u.seg != ref],
            "note": r.get("note", ""),
            "desc": r.get("desc", ""),
            "units": [[u.seg, u.name, "$%06X" % u.start, "$%06X" % a, "$%06X" % b, round(u.pick[0], 3),
                       u.pick[4] if len(u.pick) > 4 else ""] for a, b, u in pl],
        }
        m = row["matched_pct"]
        row["confidence"] = r.get("confidence") or (
            ("high" if m >= 60 else "medium" if m >= 30 or row["located_pct"] >= 60 else "low")
            if row["ref"] and row["kind"] == "match" else "none")
        out_rows.append(row)
    if fill_start < size95:
        out_rows.append({"name": "fill", "start": fill_start, "end": size95, "ref": None, "kind": "pad",
                         "start_label": ida_labels.get(fill_start), "ref_range": None, "matched_pct": 0.0,
                         "located_pct": 0.0, "ref_mix": {}, "out_of_order": 0, "moved_in": [],
                         "note": "$FF fill to the ROM end", "units": [], "confidence": "exact"})

    # boundary slack: unplaced bytes on both sides of each cut
    starts = [a for a, _, _ in ivs]
    for i in range(1, len(out_rows)):
        c = out_rows[i]["start"]
        k = bisect.bisect_left(starts, c)
        prev_end = max((ivs[j][1] for j in range(max(0, k - 3), k)), default=0)
        next_start = ivs[k][0] if k < len(ivs) else size95
        lo, hi = min(prev_end, c), max(next_start, c)
        out_rows[i]["boundary_slack"] = [lo, hi]
        out_rows[i]["boundary_labels"] = ["%s $%06X" % (ida_labels[a], a) for a in sorted(ida_labels) if lo <= a < hi
                                          and not ida_labels[a].startswith(("loc_", "locret_"))][:8]

    missing = defaultdict(list)
    for u in units:
        if id(u) not in placed and u.size >= 16:
            missing[u.seg].append("%s $%06X %d %s" % (u.name, u.start, u.size, u.kind))

    order95 = []
    for row in out_rows:
        if row["ref"] and row["ref"] not in order95:
            order95.append(row["ref"])

    for row in out_rows:
        log("%-14s $%06X-$%06X %8d  %-11s m%5.1f%% l%5.1f%% %-6s %s" % (
            row["name"], row["start"], row["end"] - 1, row["end"] - row["start"], row["ref"] or row["kind"],
            row["matched_pct"], row["located_pct"], row["confidence"], row["start_label"] or ""))

    def hexify(row):
        d = dict(row, start="$%06X" % row["start"], end="$%06X" % row["end"])
        if row.get("ref_range"):
            d["ref_range"] = ["$%06X" % x for x in row["ref_range"]]
        if row.get("boundary_slack"):
            d["boundary_slack"] = ["$%06X" % x for x in row["boundary_slack"]]
        return d

    return {
        "rom": os.path.relpath(args.rom, os.path.dirname(os.path.abspath(args.out))),
        "listing": os.path.relpath(args.lst, os.path.dirname(os.path.abspath(args.out))),
        "rom_size": size95,
        "reference": args.ref_game,
        "params": {"K": K, "W": W, "W_STRIDE": W_STRIDE, "MAX_OCC": MAX_OCC, "MIN_SIM": MIN_SIM,
                   "MIN_RUN": MIN_RUN, "BIG_GAP": BIG_GAP, "MERGE_GAP": MERGE_GAP},
        "segments": [hexify(r) for r in out_rows],
        "reference_file_order": seg_order,
        "reference_file_first_seen_in_target": order95,
        "missing": missing,
        "listing_anchor_disagreements": [[ln, lab, "$%06X" % got, "$%06X" % want] for ln, lab, got, want, _ in ida_err],
    }


if __name__ == "__main__":
    main()
