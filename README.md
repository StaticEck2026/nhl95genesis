# NHL 95 Genesis

Bitwise rebuild of NHL 95 for the Sega Genesis. The segment pass has not started.

The listing goes in `lst/nhl95.bin.lst`. The ROM it was generated from goes in `lst/nhl95.bin`. That file is the reference for every segment verify. Do not use a different ROM.

Export the listing from IDA as an LST in ASM68K / MRI mode. It has no address column. `loc_` / `sub_` names are the address.

Style source for a segment is the matching file in [NHL94Genesis](https://github.com/abdulahmad/NHL94Genesis). Use [NHLPA93Genesis](https://github.com/abdulahmad/NHLPA93Genesis) only when 94 does not have the routine.

## Segment queue

`src/hockey95.asm` is the include list. `SEGMENT_AGENT.md` is the rule file. `PROMPT.md` is the Copilot prompt. No segment is matched.

RAM is first. Write `src/ram95.asm` from the listing before transcribing code. Do not copy `ram_addrs.inc` from 94.

## Build

Segment builds use `buildseg.bat` and `npm run seg:<name>` once a segment has a stub and a confirmed org. Verify against `lst/nhl95.bin`.

`npm run build:retail` assembles `src/hockey95.asm`. It is not a match until the queue is filled.
