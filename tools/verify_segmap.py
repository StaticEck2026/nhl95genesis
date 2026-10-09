#!/usr/bin/env python3
"""Byte-slice check of a segment map.

  python3 tools/verify_segmap.py [tools/segmap95.json]

1. The segments tile the ROM: the first starts at 0, each starts where the one before ends,
   the last ends at the ROM size.
2. Slicing the ROM at the segment bounds and concatenating the slices gives the ROM back,
   byte for byte (and the same SHA-1).
3. Every segment start is the address of a line of the IDA listing (each listing line gets its
   address from the directive size or the decoded instruction, checked against every hex-named
   label), so no segment starts inside an instruction or a dc line. A start may not fall in a
   stretch whose addresses an anchor contradicts. Starts at a label are named.
4. A segment marked pad holds only $FF.
Exit status 1 on any failure.
"""

import hashlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import segmap_lib as L  # noqa: E402


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, "segmap95.json")
    m = json.load(open(path))
    base = os.path.dirname(os.path.abspath(path))
    rom = open(os.path.join(base, m["rom"]), "rb").read()
    segs = [(s["name"], int(s["start"][1:], 16), int(s["end"][1:], 16), s.get("kind")) for s in m["segments"]]
    fails = []

    if segs[0][1] != 0:
        fails.append("first segment starts at $%06X, not 0" % segs[0][1])
    for (n0, s0, e0, _), (n1, s1, e1, _) in zip(segs, segs[1:]):
        if e0 != s1:
            fails.append("%s ends $%06X but %s starts $%06X" % (n0, e0, n1, s1))
    for n, s, e, _ in segs:
        if e <= s:
            fails.append("%s is empty or reversed ($%06X-$%06X)" % (n, s, e))
    if segs[-1][2] != len(rom):
        fails.append("last segment ends $%06X, ROM is $%06X" % (segs[-1][2], len(rom)))
    print("tiling: %d segments, $%06X-$%06X" % (len(segs), segs[0][1], segs[-1][2] - 1))

    joined = b"".join(rom[s:e] for _, s, e, _ in segs)
    same = joined == rom
    print("slices: %d bytes joined, ROM %d bytes, %s, sha1 %s / %s" % (
        len(joined), len(rom), "identical" if same else "DIFFERENT",
        hashlib.sha1(joined).hexdigest()[:16], hashlib.sha1(rom).hexdigest()[:16]))
    if not same:
        fails.append("concatenated slices differ from the ROM")

    lines, labels, errors = L.parse_ida_listing(os.path.join(base, m["listing"]), rom)
    starts = {ln.addr for ln in lines}
    anchors = sum(1 for a, n in labels.items() if L._HEXNAME.match(n))
    drift = L.untrusted(errors)
    print("listing: %d lines, %d hex-named labels, %d anchors still disagree; %d bytes after them untrusted" % (
        len(lines), anchors, len(errors), len(drift)))
    at_label = 0
    for n, s, e, kind in segs[1:]:
        if s not in starts:
            fails.append("%s starts at $%06X, not at a listing line" % (n, s))
        elif s in drift:
            fails.append("%s starts at $%06X, inside a listing resync span" % (n, s))
        elif s in labels:
            at_label += 1
    print("boundaries: %d starts, all at listing lines; %d at a label" % (len(segs) - 1, at_label))
    for n, s, e, kind in segs:
        lab = labels.get(s)
        print("  %-14s $%06X-$%06X %8d  %s" % (n, s, e - 1, e - s, lab or "(line)"))
        if kind == "pad" and rom[s:e] != b"\xff" * (e - s):
            fails.append("%s is marked pad but is not all $FF" % n)

    if fails:
        print("FAIL")
        for f in fails:
            print("  " + f)
        sys.exit(1)
    print("PASS")


if __name__ == "__main__":
    main()
