# NHL 95 segment agent

This file is the queue. Do not rewrite it as a whole file. Edit the current row in place. Do not append a history entry.

## Current segment

None. Put `lst/nhl95.bin` and `lst/nhl95.bin.lst` in the repo first. The first pass is RAM, then `main95`.

## Sources

- Listing: `lst/nhl95.bin.lst`. Open it. Do not disassemble `lst/nhl95.bin`. Do not write a disassembler.
- The listing is an IDA LST in ASM68K / MRI mode. It has no address column. A `loc_`, `sub_`, or `unk_` name is the address. Confirm the org against `lst/nhl95.bin` before the first verify.
- Style source: the matching file in https://github.com/abdulahmad/NHL94Genesis. Use https://github.com/abdulahmad/NHLPA93Genesis only when 94 does not have the routine. A 94 name wins when the body is the same routine.
- Reference ROM: `lst/nhl95.bin`. Bytes and branch displacements come from it.
- `src/hockey95.asm` is the include list, in address order. Add this file's include in the session that matches it.
- Stub includes: `src/stubinc/ports.inc`, `equals.inc`, `ram_addrs.inc`.

## Teams

Provisional until the listing confirms it. NHL 95 is the 1994-95 season, still 26 teams. Quebec is still the Nordiques. Winnipeg is still the Jets. Colorado and Phoenix are NHL 96. Anaheim, Florida, and Dallas stay. A 94 team index is not a 95 index until the listing confirms the order. Conferences stay Eastern (Atlantic, Northeast) and Western (Central, Pacific).

## Build

`buildseg.bat <name>` assembles `src/<name>_stub.asm` at the confirmed org.

`npm run seg:<name>` runs buildseg, then `fixopcodes.js` on `output/<name> .lst` and `output/<name>.bin`, then `verifySegment.js`. The assembler listing name has a space before `.lst`.

A MATCH of 0 bytes is a failure. The byte count must be the confirmed range.

After every matched segment, and after every global rename, delete `output/nhl95.bin` and `output/modified_nhl95.bin`, run `npm run build:retail`, read `output/Build95.log`, and compare `output/modified_nhl95.bin` to `lst/nhl95.bin`. An old output can look like a pass. Only a compare made this session counts.

## Rules

- Write real `cmp`, `cmpi`, and `exg`. `fixopcodes.js` rewrites an EA `cmp.l` only. A real `cmpi.l #imm,d0` stays `0C80`. Do not write a compare as `dc.w`.
- Retail pad bytes win over the listing.
- A `printz` string can hide the next instruction. Write the instruction. Do not label a byte inside a string.
- If IDA splits one instruction into `dc.b` and `ori.b`, write the instruction.
- A 94 or 93 name is the field even when the 95 value differs. The equate gets the 95 value. The comment records the older value.
- Bit names replace the number. Keep the flag word the retail bytes use.
- `jsr name` only when SNASM emits the same opcode. `jsr (name).l` is `4EB9`. `jsr (name).w` is `4EB8`. `bsr.w` stays `bsr.w`.
- A global label ends local-label scope. A local that another routine or another file calls stays global. SNASM cannot reference another routine's local.
- SNASM symbols are case-insensitive. `setVram` and `setvram` are the same symbol.
- Keep each comment line under 200 characters. A longer line makes SNASM write an empty bin, and verify can then print MATCH for 0 bytes.
- Do not delete an asm file. Edit it in place.
- Data goes in the segment of the code that owns it. Sound data follows the sound driver, split as 94 `sound94` does. Graphics are incbins from `extractAssets95.js`, named for the asset, never for an IDA address. A map reference is `Label+8`, not a second equate for the tile start. Team palettes are `.pal` incbins, not `dc.w`.
- A new ROM map row gets its include in `src/hockey95.asm` in the same session.
- Do not copy a 94 name onto a 95 address because the low 16 bits match. RAM shifted after `$BE1E` in 94, and it may shift again.

## Naming

Name it in the session that transcribes it. Do not leave a cleanup pass.

- Match a function to the 94 routine when the body is the same. Keep the 94 name. Put the IDA name in one `;IDA:` comment on the definition, not on every line.
- If 94 already uses that name for a different routine, do not steal it. Name the new routine from what it does.
- A structure field is an expression (`SortCords+OldXpos`, `hmtmstruct+tmline`), not a new global.
- Do not leave `loc_`, `sub_`, `unk_`, `word_`, `byte_`, or `dword_` in code or in `ram_addrs.inc`.
- Bring over the 94 comment when the routine matches. If there is no comment, add one that says what it does.
- RAM is the first pass. Write `src/ram95.asm` in address order, one line per variable, with 94 names only where the address and the using routine match. Include it from every stub. It has no ROM bytes, so it has no byte verify.

## ROM map

No row is matched. Add a row only after the listing confirms the start.

| File | Status | Org, start label | Note |
|---|---|---|---|
| ram95 | not matched | no org | equates only. First pass |
| main95 | not matched | org 0 | vectors, header, Start. After RAM |
