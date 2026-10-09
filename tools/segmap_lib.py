"""Shared code for the segment-map tools: listing parsers and the 68k token normalizer.

Two listing formats are read:
  * a SNASM listing of a built reference game (address column, real labels) -> parse_built_listing
  * an IDA ASM68K/MRI listing with no address column (the game being split)  -> parse_ida_listing
"""

import re
import sys
from array import array

try:
    from capstone import Cs, CS_ARCH_M68K, CS_MODE_M68K_040, CS_MODE_BIG_ENDIAN
except ImportError:
    sys.exit("capstone is required: pip3 install -r tools/requirements.txt")

_md = Cs(CS_ARCH_M68K, CS_MODE_M68K_040 | CS_MODE_BIG_ENDIAN)
_md.detail = False

DATA_DIRECTIVES = ("dc.", "dcb", "incbin", "ds.", "even", "cnop", "align")


# ---------------------------------------------------------------------------
# 68k normalization
# ---------------------------------------------------------------------------

_FLOW = re.compile(r"^(b(ra|sr|hi|ls|cc|cs|ne|eq|vc|vs|pl|mi|ge|lt|gt|le|hs|lo)|db\w+|jsr|jmp|pea)(\.\w)?$")
_NUM = re.compile(r"(#?)(-?)\$([0-9a-f]+)(\.[wl])?(\((?:pc|a\d|sp)[^)]*\))?|(#)(-?\d+)\b")


def _mask_operand(m):
    imm, neg, hexv, size, ea = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5)
    if m.group(6):  # decimal immediate
        v = int(m.group(7))
        return "#%d" % v if abs(v) <= 0xFF else "#I"
    v = int(hexv, 16)
    if imm:
        return "#%s%x" % (neg, v) if v <= 0xFF else "#I"
    if ea:
        if "pc" in ea:
            return "P" + ea[ea.index(","):] if "," in ea else "P(pc)"
        return ("%s%x" % (neg, v) if v < 0x80 else "D") + ea
    if size:  # absolute .w / .l: one token for both, since a RAM operand often changes size
        if v >= 0xFF0000 or (size == ".w" and v >= 0x8000):
            return "R"
        return "A"
    return "A"


def norm_insn(mnem, op_str):
    """Token for one instruction: opcode, size, modes and registers kept; addresses, PC
    displacements, branch targets and large immediates/displacements masked."""
    if _FLOW.match(mnem):
        if mnem.startswith("db"):
            return mnem + " " + op_str.split(",")[0]
        if mnem in ("jsr", "jmp", "pea") and "(" in op_str and "pc" not in op_str and not op_str.startswith("$"):
            return mnem + " " + _NUM.sub(_mask_operand, op_str)
        return mnem
    return mnem + " " + _NUM.sub(_mask_operand, op_str) if op_str else mnem


def decode_run(rom, start, end, tokens, addrs, resync=True):
    """Linear-sweep decode rom[start:end] into (tokens, addrs). An undecodable word is a
    one-word 'BAD' token, so the sweep stays on even addresses and resynchronises."""
    pos = start
    while pos < end:
        got = False
        for a, size, mnem, op in _md.disasm_lite(rom[pos:end], pos):
            tokens.append(norm_insn(mnem, op))
            addrs.append(a)
            pos = a + size
            got = True
        if pos < end:
            if not resync:
                break
            tokens.append("BAD")
            addrs.append(pos)
            pos += 2
        if not got and not resync:
            break


def insn_size(rom, addr):
    for a, size, mnem, op in _md.disasm_lite(rom[addr:addr + 12], addr, 1):
        return size
    return 0


def _decode1(rom, addr, cache):
    hit = cache.get(addr)
    if hit is None:
        hit = (0, "")
        for a, size, mnem, op in _md.disasm_lite(rom[addr:addr + 12], addr, 1):
            hit = (size, mnem.split(".")[0])
        cache[addr] = hit
    return hit


# ---------------------------------------------------------------------------
# Built SNASM listing (reference game)
# ---------------------------------------------------------------------------

_BLINE = re.compile(r"^([0-9A-F]{8}) (.{27})(.*)$")
_EQU = re.compile(r"^\S+\s*(=|equ\b|set\b|rs\b|rsset\b|macro\b|equr\b|reg\b)", re.I)


def parse_built_listing(path, top_files):
    """Return (labels, line_kind_runs, seg_starts).

    labels: sorted list of (addr, name) for global labels.
    kinds:  list of (addr, kind) per source line: 'code', 'data', or 'ptr' (a dc.w/dc.l whose
            operand is a symbol, so its bytes are an address that moves between games).
    seg_starts: {file: addr} for each top-level include named in top_files (first occurrence)."""
    labels, kinds, seg_starts = [], [], {}
    want = {f.lower(): f for f in top_files}
    with open(path, encoding="latin-1") as fh:
        for line in fh:
            m = _BLINE.match(line.rstrip("\r\n"))
            if not m:
                continue
            addr = int(m.group(1), 16)
            if m.group(2).startswith("="):
                continue
            src = m.group(3)
            body = src.split(";", 1)[0]
            if not body.strip():
                continue
            low = body.strip().lower()
            if low.startswith("include"):
                parts = low.split()
                if len(parts) > 1 and parts[1] in want and want[parts[1]] not in seg_starts:
                    seg_starts[want[parts[1]]] = addr
                continue
            if not body[0].isspace():
                if _EQU.match(body):
                    continue
                name = re.split(r"[:\s]", body, 1)[0]
                rest = body[len(name):].lstrip(":").strip()
                if name and name[0] not in ".@" and not name.lower().startswith(("if", "endc", "else", "endif")):
                    labels.append((addr, name))
                if not rest:
                    continue
                low = rest.lower()
            parts = low.split(None, 1)
            op = parts[0]
            if op in ("org", "if", "ifd", "ifnd", "else", "endc", "endif", "endm", "rsreset", "opt", "list", "nolist", "end", "section", "incdir", "local", "module", "modend"):
                continue
            if op.startswith(DATA_DIRECTIVES):
                args = parts[1] if len(parts) > 1 else ""
                symbolic = op.startswith("dc.") and op != "dc.b" and re.search(r"(^|[,\s(+\-*/])[a-z_.@][\w.@]*", args) is not None
                kinds.append((addr, "ptr" if symbolic else "data"))
            else:
                kinds.append((addr, "code"))
    labels.sort()
    return labels, kinds, seg_starts


# ---------------------------------------------------------------------------
# IDA listing without an address column (target game)
# ---------------------------------------------------------------------------

_ILABEL = re.compile(r"^([A-Za-z_.@?$][\w.@?$]*):?(?=\s|$)")
_HEXNAME = re.compile(r"^(?:loc|sub|unk|locret|byte|word|dword|off|asc|stru|algn)_([0-9A-F]+)$")


def _split_items(s):
    items, cur, q = [], "", None
    for ch in s:
        if q:
            cur += ch
            if ch == q:
                q = None
        elif ch in "'\"":
            q = ch
            cur += ch
        elif ch == ",":
            items.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        items.append(cur.strip())
    return items


def _data_size(op, args):
    unit = {"b": 1, "w": 2, "l": 4}[op[-1]]
    if op.startswith("dcb"):
        return unit * int(_eval_num(_split_items(args)[0]))
    n = 0
    for it in _split_items(args):
        if it[:1] in "'\"" and unit == 1:
            n += len(it) - 2
        else:
            n += unit
    return n


def _eval_num(s):
    s = s.strip()
    return int(s[1:], 16) if s.startswith("$") else int(s, 0)


class IdaLine:
    __slots__ = ("addr", "size", "kind", "label", "lineno")

    def __init__(self, addr, size, kind, label, lineno):
        self.addr, self.size, self.kind, self.label, self.lineno = addr, size, kind, label, lineno


def _ida_read(path):
    """One record per listing line that has a label or a statement:
    (lineno, label, text, kind, size) with size None for instructions."""
    recs = []
    with open(path, encoding="latin-1") as fh:
        for lineno, raw in enumerate(fh, 1):
            text = raw.rstrip("\r\n")
            body = text.split(";", 1)[0].rstrip() if not text.lstrip().startswith(";") else ""
            if not body:
                continue
            label = None
            if not body[0].isspace():
                m = _ILABEL.match(body)
                if m:
                    label = m.group(1)
                    body = body[m.end():]
            stripped = body.strip()
            low = stripped.lower()
            if low.startswith(("include", "end")) and label is None:
                continue
            if low.startswith("org"):
                recs.append((lineno, None, stripped, "org", _eval_num(stripped.split(None, 1)[1])))
                continue
            op = low.split(None, 1)[0] if stripped else ""
            if not stripped:
                recs.append((lineno, label, "", None, 0))
            elif op.startswith(("dc.", "dcb.")):
                recs.append((lineno, label, stripped, "data", _data_size(op, stripped.split(None, 1)[1])))
            elif op.startswith("_"):
                recs.append((lineno, label, stripped, "data", 2))  # A-line word printed as a Mac trap
            else:
                recs.append((lineno, label, stripped, "code", None))
    return recs


_JSR_ABS = re.compile(r"^jsr\s+\(\w+\)\.l$")


def _ida_pass(recs, rom, learned, fixed, cache):
    lines, labels, errors, stretches = [], {}, [], []
    addr, trusted, cands, sus, first, after_jsr = None, None, [], [], 0, False
    for idx, (lineno, label, text, kind, size) in enumerate(recs):
        if kind == "org":
            addr = trusted = size
            cands, sus, first = [], [], idx + 1
            continue
        if label:
            hm = _HEXNAME.match(label)
            if hm:
                want = int(hm.group(1), 16)
                if addr != want:
                    errors.append((lineno, label, addr, want, trusted))
                stretches.append((cands, want - addr, first, idx, trusted, want, sus))
                addr = trusted = want
                cands, sus, first = [], [], idx
            labels.setdefault(addr, label)
        if kind is None:
            continue
        if kind == "code":
            size = _code_size(rom, addr, text, idx, learned, fixed, cache)[0]
            if idx not in fixed and (size == 0 or after_jsr):
                sus.append(idx)
            if size == 0:
                cands.append(text)
                size = 2
            after_jsr = bool(_JSR_ABS.match(text))
        else:
            after_jsr = False
        lines.append(IdaLine(addr, size, kind, label, lineno))
        addr += size
    return lines, labels, errors, stretches


def _code_size(rom, addr, text, idx, learned, fixed, cache):
    """(size, decodes as the mnemonic IDA printed)."""
    if idx in fixed:
        return fixed[idx], True
    size, mnem = _decode1(rom, addr, cache)
    if size:
        return size, mnem == text.split(None, 1)[0].split(".")[0].lower()
    size = learned.get(text, 0)
    return size, bool(size)


def _walk(recs, rom, lo, hi, addr, learned, fixed, cache):
    """Address recs[lo:hi] from addr; returns (end address, lines that do not decode as printed)."""
    miss = 0
    for idx in range(lo, hi):
        kind = recs[idx][3]
        if kind is None or kind == "org":
            continue
        if kind == "code":
            size, ok = _code_size(rom, addr, recs[idx][2], idx, learned, fixed, cache)
            miss += not ok
            addr += size or 2
        else:
            addr += recs[idx][4]
    return addr, miss


def _repair(recs, rom, stretch, learned, fixed, cache):
    """Resize one or two suspect lines of a stretch so that it ends on its anchor; take the
    resize after which the fewest lines decode differently from IDA's text, if it is unique."""
    _, _, lo, hi, start, want, sus = stretch
    if start is None or not sus or len(sus) > 24:
        return None
    sizes = range(2, 18, 2)
    for picks, combos in (([(i,) for i in sus], [(z,) for z in sizes]),
                          ([(a, b) for n, a in enumerate(sus) for b in sus[n + 1:]],
                           [(x, y) for x in sizes for y in sizes])):
        sols = []
        for pick in picks:
            for zs in combos:
                trial = dict(fixed)
                trial.update(zip(pick, zs))
                end, miss = _walk(recs, rom, lo, hi, start, learned, trial, cache)
                if end == want:
                    sols.append((miss, dict(zip(pick, zs))))
        if sols:
            sols.sort(key=lambda t: t[0])
            if len(sols) == 1 or sols[0][0] < sols[1][0]:
                return sols[0][1]
            return None
    return None


def parse_ida_listing(path, rom):
    """Give every IDA line an address. Data sizes come from the directive; instruction sizes
    come from decoding the ROM at the running address. Hex-named labels are checked against
    the running address and reset it. IDA prints EA's inline jsr parameters as instructions
    that capstone cannot decode or decodes at another length (ori.b #9,a0 ...). Two repairs,
    repeated until nothing changes: the size of an undecodable text is voted from the stretches
    between two anchors where it is the only unknown (kept when all votes agree), and a stretch
    that still misses its anchor gets the unique resize of one or two suspect lines (undecodable,
    or right after a jsr abs.l) after which every line decodes and the anchor is hit.
    Returns (lines, labels {addr: name}, errors [(lineno, label, got, want, last_trusted)])."""
    recs = _ida_read(path)
    learned, fixed, cache = {}, {}, {}
    while True:
        lines, labels, errors, stretches = _ida_pass(recs, rom, learned, fixed, cache)
        votes = {}
        for st in stretches:
            cands, delta = st[0], st[1]
            if cands and len(set(cands)) == 1 and delta % len(cands) == 0:
                size = 2 + delta // len(cands)
                if size >= 2 and size % 2 == 0:
                    votes.setdefault(cands[0], set()).add(size)
        new = {t: min(v) for t, v in votes.items() if len(v) == 1 and t not in learned}
        learned.update(new)
        changed = bool(new)
        for st in stretches:
            if st[1]:
                sol = _repair(recs, rom, st, learned, fixed, cache)
                if sol:
                    fixed.update(sol)
                    changed = True
        if not changed:
            return lines, labels, errors


def untrusted(errors):
    """Addresses where a listing line may sit at the wrong address: everything after the last
    anchor that agreed, up to the anchor that disagreed (and the overshoot past it)."""
    bad = set()
    for _, _, got, want, trusted in errors:
        lo = want if trusted is None else trusted
        bad.update(a for a in range(min(lo, got), max(want, got) + 1) if a not in (want, trusted))
    return bad


def u32_array(values=()):
    return array("I", values)
