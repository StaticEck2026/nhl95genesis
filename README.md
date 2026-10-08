# NHL 95 Genesis

Bitwise rebuild of NHL 95 for the Sega Genesis. No segment is matched.

The listing is `lst/nhl95.bin.lst`. The ROM it was generated from is `lst/nhl95.bin`. That file is the reference for every segment verify. Do not use a different ROM. It is 2 MB.

The listing is an IDA LST in ASM68K / MRI mode. It has no address column. `loc_` / `sub_` names are the address.

Style source for a segment is the matching file in [NHL94Genesis](https://github.com/abdulahmad/NHL94Genesis). Use [NHLPA93Genesis](https://github.com/abdulahmad/NHLPA93Genesis) only when 94 does not have the routine.

## Segment queue

`src/nhl95.asm` is the include list, in the 94 file order. Every file under `src/` except the include list is a placeholder. No org is confirmed. `SEGMENT_AGENT.md` is the rule file. `PROMPT.md` is the Copilot prompt.

A 95 system that 94 does not have gets a new file when the listing shows it. Do not invent the org.

## Build

Segment builds use `buildseg.bat` and `npm run seg:<name>` once a segment has a stub and a confirmed org. Verify against `lst/nhl95.bin`.

Full ROM builds assemble `src/nhl95.asm`. The listing is `output/nhl95 .lst`. The opcode-corrected output is `output/modified_nhl95.bin`.

| Script | Flags | Result |
| --- | --- | --- |
| `npm run build:retail` | `rev=0`, `checksum=1` | Retail, then a byte compare to `lst/nhl95.bin`. |
| `npm run build:dev` | `rev=0`, `checksum=0` | No validation and no retail verify. Use this while editing. |
