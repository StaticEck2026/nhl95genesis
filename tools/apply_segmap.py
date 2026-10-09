#!/usr/bin/env python3
"""Write a segment map (tools/segmap95.json) into the repo: the include list, the placeholder
files, the ROM map rows of SEGMENT_AGENT.md and the seg:<name> scripts of package.json.

  python3 tools/apply_segmap.py --ref ../NHL94Genesis [--map tools/segmap95.json]

The 94 file descriptions come from the include comments of the reference src/<ref-game>.asm.
A placeholder that holds more than its four header lines is never rewritten or removed.
"""

import argparse
import json
import os
import re
import sys

PLACEHOLDER = "NHL 95 placeholder. Not matched."
REF_URL = "https://github.com/abdulahmad/NHL94Genesis"


def ref_descriptions(ref_dir, game):
    out = {}
    for line in open(os.path.join(ref_dir, "src", game + ".asm"), encoding="latin-1"):
        m = re.match(r"\s*include\s+(\w+)\.asm\s*;\s*(?:\$[0-9A-F]+)?\s*(.*)$", line, re.I)
        if m:
            desc = m.group(2).split(":", 1)
            out[m.group(1)] = (desc[1] if len(desc) > 1 else desc[0]).strip()
    return out


def is_placeholder(path):
    if not os.path.exists(path):
        return True
    lines = [ln for ln in open(path, encoding="latin-1").read().splitlines() if ln.strip()]
    return len(lines) <= 4 and all(ln.lstrip().startswith(";") for ln in lines) and (
        not lines or PLACEHOLDER in lines[0])


def first_sentence(note):
    s = note.split(". ")[0].rstrip(".")
    return re.sub(r"^New in 95:\s*", "", s)


def row_info(seg, descs):
    ref = seg.get("ref")
    new = seg.get("kind", "").startswith("new")
    if new or not ref or ref == "pad":
        desc = first_sentence(seg.get("note") or "") or "new 95 code"
        return None, desc
    return ref, descs.get(ref, "")


def start_name(seg):
    if seg.get("start_label"):
        return seg["start_label"]
    for u in seg.get("units", []):
        if u[3] == seg["start"]:
            return "no IDA label; 94 %s" % u[1]
    return "no IDA label"


def note_for(seg):
    if seg.get("note"):
        return seg["note"]
    units = [u for u in seg.get("units", []) if float(u[5]) >= 0.5]
    parts = []
    if units:
        parts.append("94 %s ... %s" % (units[0][1], units[-1][1]) if len(units) > 1 else "94 " + units[0][1])
    if seg.get("moved_in"):
        moved = seg["moved_in"]
        parts.append("moved in: " + ", ".join(moved[:4]) + (" (+%d)" % (len(moved) - 4) if len(moved) > 4 else ""))
    return "; ".join(parts)


def hexa(s):
    return int(s[1:], 16)


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    root = os.path.dirname(here)
    ap = argparse.ArgumentParser()
    ap.add_argument("--ref", required=True, help="reference repo (NHL94Genesis)")
    ap.add_argument("--ref-game", default="nhl94")
    ap.add_argument("--game", default="nhl95")
    ap.add_argument("--map", default=os.path.join(here, "segmap95.json"))
    args = ap.parse_args()
    m = json.load(open(args.map))
    descs = ref_descriptions(args.ref, args.ref_game)
    segs = [s for s in m["segments"] if s.get("kind") != "pad"]
    src = os.path.join(root, "src")
    suffix = args.game[-2:]

    keep = {s["name"] for s in segs} | {"ram" + suffix, args.game}
    old = sorted(f[:-4] for f in os.listdir(src) if f.endswith(".asm") and not f.endswith("_stub.asm"))
    blocked = []
    for name in old:
        if name in keep:
            continue
        path = os.path.join(src, name + ".asm")
        if not is_placeholder(path):
            blocked.append(name)
            continue
        first = next((s["name"] for s in segs if s["name"].startswith(name + "_")), None)
        if first and not os.path.exists(os.path.join(src, first + ".asm")):
            os.rename(path, os.path.join(src, first + ".asm"))
        else:
            os.remove(path)
    if blocked:
        sys.exit("not a placeholder, left alone: " + ", ".join(blocked))

    for s in segs:
        path = os.path.join(src, s["name"] + ".asm")
        if not is_placeholder(path):
            continue
        ref, desc = row_info(s, descs)
        where = "Org $%06X, end $%06X (tools/segmap%s.json, %s confidence)." % (
            hexa(s["start"]), hexa(s["end"]) - 1, suffix, s["confidence"])
        if ref:
            head = "Adapted from %s.asm: %s." % (ref, desc.rstrip("."))
            where += " The 94 file is %s src/%s.asm." % (REF_URL, ref)
        else:
            head = "New in 95: %s." % desc
        with open(path, "w", newline="\r\n") as fh:
            fh.write(";\t%s\n;\t%s\n;\t%s\n;\tTranscribe lst/nhl95.bin.lst into this file. Do not copy 94 bytes.\n" % (
                PLACEHOLDER, head, where))

    top = os.path.join(src, args.game + ".asm")
    lines = open(top, encoding="latin-1").read().splitlines()
    head = [ln for ln in lines if ln.startswith(";")]
    stub = [ln for ln in lines if "stubinc" in ln]
    tail = [ln for ln in lines if ln.strip().startswith("dcb")]
    head = [
        ";",
        ";\tTop level of the full NHL 95 ROM build (build95.bat, npm run build:retail). The listing is output\\nhl95 .lst.",
        ";\tThe includes are in 95 ROM order, from the fingerprint map tools/segmap95.json (tools/fingerprint_map.py).",
        ";\tThe address on each include line is the mapped lst/nhl95.bin start. It is provisional until the segment matches.",
        ";\tThe org for a segment build goes in its _stub.asm. Do not put an org in a file this list includes.",
        ";\tram95.asm has no bytes. The ports, VDP status bits and RAM names are in stubinc.",
        ";",
    ] if head else head
    body = []
    for s in segs:
        ref, desc = row_info(s, descs)
        what = ("Adapted from %s.asm: %s" % (ref, desc)) if ref else "New in 95: " + desc
        body.append("\tinclude\t%s.asm\t\t; $%06X  %s" % (s["name"], hexa(s["start"]), what))
        if s["name"].startswith("frames"):
            body.append("\tinclude\tram%s.asm\t\t;          Adapted from ram94.asm: equates only" % suffix)
    with open(top, "w", newline="\r\n") as fh:
        fh.write("\n".join(head + stub + [""] + body + tail) + "\n")

    pkg_path = os.path.join(root, "package.json")
    pkg = json.load(open(pkg_path))
    scripts = {k: v for k, v in pkg["scripts"].items() if not k.startswith("seg:")}
    for s in segs:
        n = s["name"]
        scripts["seg:" + n] = ("buildseg.bat %s && node fixopcodes.js \"output\\\\%s .lst\" output\\\\%s.bin && "
                               "node verifySegment.js %s 0x%X lst/%s.bin" % (n, n, n, n, hexa(s["start"]), args.game))
    pkg["scripts"] = scripts
    with open(pkg_path, "w") as fh:
        fh.write(json.dumps(pkg, indent=2) + "\n")

    agent = os.path.join(root, "SEGMENT_AGENT.md")
    text = open(agent, encoding="utf-8").read()
    rows = ["| File | Status | Org, start label | End | 94 file | Matched | Confidence | Note |",
            "|---|---|---|---|---|---|---|---|"]
    for s in segs:
        ref, _ = row_info(s, descs)
        rows.append("| %s | not matched | $%X, %s | $%06X | %s | %s | %s | %s |" % (
            s["name"], hexa(s["start"]), start_name(s), hexa(s["end"]) - 1, ref or "new",
            ("%.0f%%" % s["matched_pct"]) if ref else "-", s["confidence"], note_for(s).replace("|", "/")))
        if s["name"].startswith("frames"):
            rows.append("| ram%s | skipped | no org (equates only) | - | ram94 | - | - | Equates only, no ROM bytes. "
                        "Skipped by the segment queue. RAM names go in `stubinc/ram_addrs.inc` as code is transcribed |" % suffix)
    pad = [s for s in m["segments"] if s.get("kind") == "pad"]
    intro = ("The first row that is not matched is the current segment. The rows are in 95 ROM order and tile "
             "$000000-$1FFFFF with the `$FF` fill")
    if pad:
        intro += " ($%06X-$%06X, the `dcb.b` in `src/%s.asm`)" % (hexa(pad[0]["start"]), hexa(pad[0]["end"]) - 1, args.game)
    intro += (". They come from `tools/segmap%s.json`: `python3 tools/fingerprint_map.py --ref <NHL94Genesis>` "
              "locates the 94 routines, `python3 tools/verify_segmap.py` checks the tiling and boundaries, "
              "`python3 tools/apply_segmap.py --ref <NHL94Genesis>` writes this table. Org and end are provisional "
              "until the row matches. Matched is the share of the row covered by 94 routines found at similarity "
              "0.5 or more. Confidence is how sure the row's range is, not a byte match." % suffix)
    new_rows = [s for s in segs if not row_info(s, descs)[0]]
    new_text = "\n".join("- `%s` `$%06X-$%06X`: %s" % (s["name"], hexa(s["start"]), hexa(s["end"]) - 1, s.get("note", ""))
                         for s in new_rows)
    text = re.sub(r"(## ROM map\n\n).*?(\n## New in 95\n)",
                  lambda mm: mm.group(1) + intro + "\n\n" + "\n".join(rows) + "\n" + mm.group(2),
                  text, flags=re.S)
    text = re.sub(r"(## New in 95\n\n)(.*?)(\n## |\Z)",
                  lambda mm: mm.group(1) + "Add a file here when the listing shows a system 94 does not have.\n\n"
                  + new_text + "\n" + mm.group(3), text, count=1, flags=re.S)
    with open(agent, "w", encoding="utf-8") as fh:
        fh.write(text)
    print("wrote %d placeholders, %s, package.json (%d seg scripts), SEGMENT_AGENT.md (%d rows)" % (
        len(segs), os.path.relpath(top, root), len(segs), len(rows) - 2))


if __name__ == "__main__":
    main()
