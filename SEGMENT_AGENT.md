# NHL 95 segment agent

This file is the queue and the history. Do not rewrite it as a whole file. Edit it in place.

## Current segment

None. The listing and the ROM are not in the repo yet. Put them at `lst/nhl95.bin.lst` and `lst/nhl95.bin` before the first pass. The first pass is RAM, then `main95`.

## Sources

- Listing: `lst/nhl95.bin.lst` in this repo. Open that file. Do not disassemble `lst/nhl95.bin`. Do not write a disassembler.
- The listing is an IDA LST in ASM68K / MRI mode. It has no address column. A `loc_`, `sub_`, or `unk_` name is the address. Confirm the org against `lst/nhl95.bin` before the first verify.
- Style source: the matching file in https://github.com/abdulahmad/NHL94Genesis. Use https://github.com/abdulahmad/NHLPA93Genesis only when 94 does not have the routine. A 94 name wins when the body is the same routine.
- Reference ROM: `lst/nhl95.bin`. Bytes and branch displacements come from it. Do not substitute another ROM.
- `src/hockey95.asm` is the include list, in address order. Add an include in the session that matches the segment.
- Stub includes live in `src/stubinc` (`ports.inc`, `equals.inc`, `ram_addrs.inc`).

## Teams

Provisional, from the 1994-95 season. Confirm every name against `lst/nhl95.bin` before writing `teamdata95`.

NHL 94 has 26 teams. NHL 95 has the same 26. Quebec is still the Nordiques. Winnipeg is still the Jets. Colorado and Phoenix are NHL 96.

Still present from 94: Anaheim Mighty Ducks, Florida Panthers, Dallas Stars, Ottawa Senators, Tampa Bay Lightning, San Jose Sharks, Hartford Whalers. All Stars East and All Stars West may still be present. Confirm them in the listing.

Conferences stay Eastern (Atlantic, Northeast) and Western (Central, Pacific). A 94 team index is not a 95 index until the listing confirms the order.

## Build

`buildseg.bat <name>` assembles `src/<name>_stub.asm`. The stub is `org` at the confirmed start, includes `src/stubinc`, and includes `src/<name>.asm`.

`npm run seg:<name>` runs buildseg, then `fixopcodes.js` on `output/<name> .lst` and `output/<name>.bin` with the org, then `verifySegment.js`. The assembler listing name has a space before `.lst`.

A MATCH of 0 bytes is a failure. The byte count must be the confirmed range.

Full build check (`npm run build:retail`): delete `output/nhl95.bin` and `output/modified_nhl95.bin` first. Compare `output/modified_nhl95.bin` to `lst/nhl95.bin`. Only a compare made this session counts.

## Rules

- Write real `cmp`, `cmpi`, and `exg`. `fixopcodes.js` rewrites an EA `cmp.l` (`0Cxx` to `B0BC`) only. A real `cmpi.l #imm,d0` stays `0C80`.
- Retail pad bytes win over the listing.
- A `printz` string can hide the next instruction. Write the instruction. Do not label a byte inside a string.
- If IDA splits one instruction into `dc.b` and `ori.b`, write the instruction.
- A 94 or 93 name is the field even when the 95 value differs. The equate gets the 95 value. The comment records the older value.
- Bit names replace the number. Keep the flag word the retail bytes use.
- `jsr name` only when SNASM emits the same opcode. `jsr (name).l` is `4EB9`. `jsr (name).w` is `4EB8`. `bsr.w` stays `bsr.w`.
- A global label ends local-label scope. Strip `?` from IDA names. Keep each comment line under 200 characters.
- Do not delete an asm file. Edit it in place. Do not add a file except the stub and the segment asm.
- Data goes in the segment of the code that owns it. Sound data follows the sound driver. Graphics are incbins from `extractAssets95.js`.
- A new ROM map row gets its include in `src/hockey95.asm` in the same session.
- SNASM symbols are case-insensitive. `setVram` and `setvram` are the same symbol.
- Do not copy a 94 name onto a 95 address because the low 16 bits match. 94 RAM shifted after `$BE1E`. 95 may shift again.

## Naming rules

- Match a function name to the NHL94Genesis routine when the body is the same. If the IDA name differs, keep the 94 name and put the IDA name in a comment.
- Match subroutines, arguments, parameters, and expressions to 94 when 94 has a name. A 95 value may differ.
- Do not leave a generic name. `loc_`, `sub_`, `unk_`, `word_`, `byte_`, and `dword_` need a name. Use the 94 name when the body matches. Otherwise name it from what it does, in the 94 style.
- Bring over the 94 comment when the routine matches. If a function has no comment, add one that says what it does.
- A label two routines reach across a global label stays global.
- RAM names: use the 94 name at the same address only when the routine that uses it is the same. Otherwise name it from what it holds. Write the RAM map as 93 `ram93.asm` does, one line per variable, before the first code segment.

## ROM map

No row is matched. Add a row only after the listing confirms the start.

| File | Status | Org, start label | Note |
|---|---|---|---|
| ram95 | not matched | no org | equates only. First pass |
| main95 | not matched | org 0 | vectors, header, Start. After RAM |

## History

No segment has matched.
