# NHL 95 segment agent

This file is the queue. Do not rewrite it as a whole file. Edit the current row in place. Do not append a history entry.

## Current segment

`main95`. Start label `Trap3` (the vector table at `$000000`). The confirmed org is `$0`. Confirm every org against `lst/nhl95.bin.lst` before the first verify. The 94 addresses are not 95 addresses.

RAM (`ram95`) is skipped by the segment queue. The queue processes ROM segments only. RAM names come from the code segments as they are transcribed, not as a separate first pass. After ROM segments are matched, RAM will be organized as a final consolidation pass.

The files in `src/nhl95.asm` are a starting map, not a confirmed split. Use https://github.com/abdulahmad/NHL94Genesis to decide where a segment starts and ends. Find the 94 routine that matches the 95 listing, then take the 95 range from the 95 listing, not from the 94 org. Split a placeholder when the 94 files are separate ranges here. Add a file when 95 has a system 94 does not have. Drop a placeholder when 95 has no matching code, and remove its include. Keep the includes in ROM order.

## Sources

- Listing: `lst/nhl95.bin.lst`. Open it. Do not disassemble `lst/nhl95.bin`. Do not write a disassembler.
- The listing is an IDA LST in ASM68K / MRI mode. It has no address column. A `loc_`, `sub_`, or `unk_` name is the address.
- Style source: the matching file in https://github.com/abdulahmad/NHL94Genesis. Use https://github.com/abdulahmad/NHLPA93Genesis only when 94 does not have the routine. A 94 name wins when the body is the same routine.
- Reference ROM: `lst/nhl95.bin`. It is 2 MB. Bytes and branch displacements come from it.
- `src/nhl95.asm` is the include list, in the 94 file order. Put the confirmed org on the include line in the session that matches the file.
- Stub includes: `src/stubinc/ports.inc`, `equals.inc`, `ram_addrs.inc`.

## Teams

Provisional until the listing confirms it. NHL 95 is the 1994-95 season, still 26 teams. Quebec is still the Nordiques. Winnipeg is still the Jets. Colorado and Phoenix are NHL 96. A 94 team index is not a 95 index until the listing confirms the order.

## Build

`buildseg.bat <name>` assembles `src/<name>_stub.asm`. The stub carries the org. A file included by `nhl95.asm` has no org.

`npm run seg:<name>` runs buildseg, then `fixopcodes.js` on `output/<name> .lst` and `output/<name>.bin`, then `verifySegment.js`. The assembler listing name has a space before `.lst`.

A MATCH of 0 bytes is a failure. The byte count must be the confirmed range.

After every matched segment, delete `output/nhl95.bin` and `output/modified_nhl95.bin`, run `npm run build:retail`, and compare `output/modified_nhl95.bin` to `lst/nhl95.bin`. The full build assembles `src/nhl95.asm`, so the listing stays `output/nhl95 .lst`. An old output can look like a pass. Only a compare made this session counts.

## Rules

- Write real `cmp`, `cmpi`, and `exg`. `fixopcodes.js` rewrites an EA `cmp.l` only. A real `cmpi.l #imm,d0` stays `0C80`. Do not write a compare as `dc.w`.
- Retail pad bytes win over the listing.
- A `printz` string can hide the next instruction. Write the instruction. Do not label a byte inside a string.
- If IDA splits one instruction into `dc.b` and `ori.b`, write the instruction.
- A 94 name is the field even when the 95 value differs. The equate gets the 95 value. The comment records the 94 value.
- Bit names replace the number. Keep the flag word the retail bytes use.
- `jsr name` only when SNASM emits the same opcode. `jsr (name).l` is `4EB9`. `jsr (name).w` is `4EB8`. `bsr.w` stays `bsr.w`.
- A global label ends local-label scope. A local that another routine or another file calls stays global. SNASM cannot reference another routine's local.
- SNASM symbols are case-insensitive. `setVram` and `setvram` are the same symbol.
- Keep each comment line under 200 characters. A longer line makes SNASM write an empty bin, and verify can then print MATCH for 0 bytes.
- Do not delete an asm file. Edit it in place.
- Data goes in the segment of the code that owns it. Sound data follows the sound driver. Graphics are incbins from `extractAssets95.js`, named for the asset, never for an IDA address. A map reference is `Label+8`. Team palettes are `.pal` incbins.
- A new ROM map row gets its include in `src/nhl95.asm` in ROM order in the same session.
- Do not copy a 94 name onto a 95 address because the low 16 bits match. Do not copy a 94 org.
- RAM names go in `stubinc/ram_addrs.inc` as you transcribe code segments. Add each new RAM name to that file when you first encounter it. Do not wait for a RAM consolidation pass.

## Naming

Name it in the session that transcribes it. Do not leave a cleanup pass.

- Match a function to the 94 routine when the body is the same. Keep the 94 name. Put the IDA name in one `;IDA:` comment on the definition, not on every line.
- If 94 already uses that name for a different routine, do not steal it. Name the new routine from what it does.
- A structure field is an expression (`SortCords+OldXpos`), not a new global.
- Do not leave `loc_`, `sub_`, `unk_`, `word_`, `byte_`, or `dword_` in code or in `ram_addrs.inc`.
- Bring over the 94 comment when the routine matches. If there is no comment, add one that says what it does.

## ROM map

The first unmatched ROM segment is the current segment. The order is the 94 file order. Orgs are blank until the listing confirms them.

| File | Status | Org | Note |
|---|---|---|---|
| main95 | not matched | $0 | Adapted from main94.asm: header, startup, vectors. Start label `Trap3` |
| teamdata95 | not matched | org not confirmed | Adapted from teamdata94.asm: teams, palettes, credits text |
| frames95 | not matched | org not confirmed | Adapted from frames94.asm: sprite animation tables |
| ram95 | skipped | no org (equates only) | Adapted from ram94.asm: equates only, no ROM bytes. Skipped by the segment queue. RAM names come from code segments as transcribed, added to `stubinc/ram_addrs.inc`. A final consolidation pass may organize `src/ram95.asm` after ROM segments are complete |
| hockey95 | not matched | org not confirmed | Adapted from hockey94.asm: game loop, pause |
| menu95 | not matched | org not confirmed | Adapted from menu94.asm: menu core |
| stats95 | not matched | org not confirmed | Adapted from stats94.asm: scores, line editor, roster, scoring and penalty summaries, player stats, crowd meter, goalie select |
| replay95 | not matched | org not confirmed | Adapted from replay94.asm: replay |
| input95 | not matched | org not confirmed | Adapted from input94.asm: controller input and line changes |
| assign95 | not matched | org not confirmed | Adapted from assign94.asm: player assignments |
| checks95 | not matched | org not confirmed | Adapted from checks94.asm: checks before the display code |
| video95 | not matched | org not confirmed | Adapted from video94.asm: display helpers |
| penalty95 | not matched | org not confirmed | Adapted from penalty94.asm: penalties, scoreboard, highlights |
| collide95 | not matched | org not confirmed | Adapted from collide94.asm: puck, players, walls, fights, goals |
| display95 | not matched | org not confirmed | Adapted from display94.asm: vblank, clock, crowd, rink scroll |
| setup95 | not matched | org not confirmed | Adapted from setup94.asm: ice setup, intermission, playoff screen |
| attract95 | not matched | org not confirmed | Adapted from attract94.asm: EA Sports attract screen |
| data95 | not matched | org not confirmed | Adapted from data94.asm: menus, season results, string tables |
| sram95 | not matched | org not confirmed | Adapted from sram94.asm: save data |
| sound95 | not matched | org not confirmed | Adapted from sound94.asm: sound driver, then the sound data |
| graphics95 | not matched | org not confirmed | Adapted from graphics94.asm: graphics only |
| onetimer95 | not matched | org not confirmed | Adapted from onetimer94.asm: one-timer |
| fourway95 | not matched | org not confirmed | Adapted from fourway94.asm: four-player adaptor |
| crowd95 | not matched | org not confirmed | Adapted from crowd94.asm: crowd meter and hot / cold players |
| optsetup95 | not matched | org not confirmed | Adapted from optsetup94.asm: game setup and options |
| cards95 | not matched | org not confirmed | Adapted from cards94.asm: player cards and matchup palettes |
| records95 | not matched | org not confirmed | Adapted from records94.asm: name entry and record holders |
| shootout95 | not matched | org not confirmed | Adapted from shootout94.asm: shootout |
| scout95 | not matched | org not confirmed | Adapted from scout94.asm: matchups and scouting report |
| period95 | not matched | org not confirmed | Adapted from period94.asm: period stats and game statistics |
| goalie95 | not matched | org not confirmed | Adapted from goalie94.asm: manual goalie |
| title95 | not matched | org not confirmed | Adapted from title94.asm: song select, title, credits |
| checksum95 | not matched | org not confirmed | Adapted from checksum94.asm: checksum |

## New in 95

Add a file here when the listing shows a system 94 does not have. Do not add it before that.
