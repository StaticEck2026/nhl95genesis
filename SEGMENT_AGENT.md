# NHL 95 segment agent

This file is the queue. Do not rewrite it as a whole file. Edit the current row in place. Do not append a history entry.

## Current segment

`frames95`. No IDA label at `$005A34` (94 `SPAlist`; it follows playoffseats at the end of teamdata95). The mapped org is `$5A34`. Confirm every org against `lst/nhl95.bin.lst` before the first verify. The 94 addresses are not 95 addresses.

RAM (`ram95`) is not a queue segment. It has no ROM bytes, so there is nothing to byte-verify, and the queue moves past its row. That does not put RAM off limits. RAM names come from the code segments as they are transcribed, not from a separate first pass: add each one to `src/stubinc/ram_addrs.inc`, which the stubs include. `src/ram95.asm` is the RAM map those names are consolidated into, and you may add to it whenever it fits. When the stubs are removed, the RAM definitions end up in `src/ram95.asm`. The full build includes both files and a stub includes only `ram_addrs.inc`, so define each name in one file, and keep a name a stub uses in `ram_addrs.inc` until the stubs are removed.

The files in `src/nhl95.asm` come from the fingerprint map `tools/segmap95.json`: every 94 routine was located in `lst/nhl95.bin`, and the rows tile the ROM. It is a provisional split. Use https://github.com/abdulahmad/NHL94Genesis to confirm where a segment starts and ends. Find the 94 routine that matches the 95 listing, then take the 95 range from the 95 listing, not from the 94 org. Split a placeholder when the 94 files are separate ranges here. Add a file when 95 has a system 94 does not have. Drop a placeholder when 95 has no matching code, and remove its include. Keep the includes in ROM order.

## Sources

- Listing: `lst/nhl95.bin.lst`. Open it. Do not disassemble `lst/nhl95.bin`. Do not write a disassembler.
- The listing is an IDA LST in ASM68K / MRI mode. It has no address column. A `loc_`, `sub_`, or `unk_` name is the address.
- Style source: the matching file in https://github.com/abdulahmad/NHL94Genesis. Use https://github.com/abdulahmad/NHLPA93Genesis only when 94 does not have the routine. A 94 name wins when the body is the same routine.
- Reference ROM: `lst/nhl95.bin`. It is 2 MB. Bytes and branch displacements come from it.
- `src/nhl95.asm` is the include list, in 95 ROM order. Each include line has the mapped org. Correct it in the session that matches the file.
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
- RAM names go in `stubinc/ram_addrs.inc` as you transcribe code segments. Add each new RAM name to that file when you first encounter it. Do not wait for a RAM consolidation pass. You may also add to `src/ram95.asm`, the RAM map the names are consolidated into. Define each name in only one of the two files.

## Naming

Name it in the session that transcribes it. Do not leave a cleanup pass.

- Match a function to the 94 routine when the body is the same. Keep the 94 name. Put the IDA name in one `;IDA:` comment on the definition, not on every line.
- If 94 already uses that name for a different routine, do not steal it. Name the new routine from what it does.
- A structure field is an expression (`SortCords+OldXpos`), not a new global.
- Do not leave `loc_`, `sub_`, `unk_`, `word_`, `byte_`, or `dword_` in code or in `ram_addrs.inc`.
- Bring over the 94 comment when the routine matches. If there is no comment, add one that says what it does.

## ROM map

The first row that is not matched is the current segment. The rows are in 95 ROM order and tile $000000-$1FFFFF with the `$FF` fill ($1A7310-$1FFFFF, the `dcb.b` in `src/nhl95.asm`). They come from `tools/segmap95.json`: `python3 tools/fingerprint_map.py --ref <NHL94Genesis>` locates the 94 routines, `python3 tools/verify_segmap.py` checks the tiling and boundaries, `python3 tools/apply_segmap.py --ref <NHL94Genesis>` writes this table. Org and end are provisional until the row matches. Matched is the share of the row covered by 94 routines found at similarity 0.5 or more. Confidence is how sure the row's range is, not a byte match.

| File | Status | Org, start label | End | 94 file | Matched | Confidence | Note |
|---|---|---|---|---|---|---|---|
| main95 | matched, 1906 bytes $000000-$000771 | $0, Trap3 | $000771 | main94 | 50% | high | Vectors, header, SegaInit, then 95 code: region lock and its message (loc_2FA-$68F), jsr checksum, dc.l 0 ($69A, 94 kept it at the start of teamdata94), four rts exception stubs, and 94 Begin (hockey94) at loc_6A6 ending jmp $9AC8. TeamList is $772 |
| teamdata95 | matched, 21186 bytes $000772-$005A33 | $772, no IDA label; 94 TeamList | $005A33 | teamdata94 | 0% | high | 94 TeamList, the 28 team blocks ($7E2-$5833), then playoffseats ($5834). Team palettes are the `*95.pal` slices in extractAssets95.js |
| frames95 | not matched | $5A34, no IDA label; 94 SPAlist | $0093FF | frames94 | 0% | low | SPAlist ($5A34, from movea.l #SPAlist operands), the SPA tables (frame numbers changed, so no byte match), then revframetbl at $8596 (94 kept it at the end of graphics94; RestoreReplayFrame reads it). $8C76-$93FF is unmatched data; byte_8DD8 is read by season code (sub_8E26A) |
| ram95 | skipped | no org (equates only) | - | ram94 | - | - | Equates only, no ROM bytes. `skipped` only means this is not a queue segment: there is nothing to byte-verify, so the queue moves past it. RAM names still go in `stubinc/ram_addrs.inc` as code is transcribed, and `src/ram95.asm` may be added to |
| sram95 | not matched | $9400, no IDA label; 94 ScrollArrowTbl | $009AC7 | sram94 | 35% | medium | 94 ScrollArrowTbl ... ReadSRAM; moved in: stats94:ScrollArrowTbl |
| hockey95 | not matched | $9AC8, loc_9AC8 | $00A203 | hockey94 | 0% | low | Game flow: 95 Begin (main95) ends jmp $9AC8. 94 StartGame is near $9BD2 (similarity 0.56) and StartPer near $9DC2 (0.74), both rewritten; sub_9F22, sub_9FD2, sub_A01C are called from here. Before it, $9972-$9AC7 is three new save RAM routines (movea.l #$200000) after 94 ReadSRAM |
| display95_01 | not matched | $A204, sub_A204 | $00A655 | display94 | 70% | high | 94 setvideo ... ButtonLabelCharTable |
| setup95_01 | not matched | $A656, sub_A656 | $00AF43 | setup94 | 53% | medium | 94 defaultsprites ... setteams; moved in: input94:holdplayer, input94:Acheck, input94:burst, title94:chgplayer (+3) |
| sound95_01 | not matched | $AF44, sub_AF44 | $079901 | sound94 | 16% | low | 95 sound driver: sub_AF44 is the command dispatcher sub_676D8 calls; sub_BD7C releases the Z80 bus and the Z80 program starts at $BD86 (C3 00 06, JP $0600); the sound banks follow |
| video95_01 | not matched | $79902, sub_79902 | $079D7F | video94 | 100% | high | 94 DoFill ... DoDMA; moved in: display94:DumpSprites, display94:DumpSprites2, display94:DoDMAlist, display94:SetScroll2 |
| display95_02 | not matched | $79D80, sub_79D80 | $07A029 | display94 | 100% | high | 94 addframe ... updatescroll; moved in: data94:sizetab |
| video95_02 | not matched | $7A02A, sub_7A02A | $07A761 | video94 | 74% | high | 94 forceblack ... PadDirTable; moved in: hockey94:VBjsr, display94:VBlank, sound94:p_music_vblank, display94:vb2 (+14) |
| collide95_01 | not matched | $7A762, sub_7A762 | $07C511 | collide94 | 80% | high | 94 ProcessInputWithRepeat ... checkint; moved in: video94:ProcessInputWithRepeat, stats94:WaitVSyncAndReadInput, cards94:wallcollduringcheck |
| video95_03 | not matched | $7C512, sub_7C512 | $07DE9F | video94 | 64% | high | 94 sroot ... TrimSpaces; moved in: checks94:vtoa, checks94:vtoa+$5A, display94:find3d, checks94:GetHot (+46) |
| fourway95 | not matched | $7DEA0, sub_7DEA0 | $07E0DF | fourway94 | 80% | high | 94 LoadHomeTeamGfx ... Set4WayPlayerStub; moved in: title94:LoadHomeTeamGfx, title94:TeamGfxList, penalty94:EASNLogo, penalty94:EASNLogo+$14 (+2) |
| sound95_02 | not matched | $7E0E0, no IDA label; 94 Z80_Program_Code | $07E4D5 | sound94 | 64% | high | 94 Z80_Program_Code |
| menu95 | not matched | $7E4D6, sub_7E4D6 | $07F97D | menu94 | 12% | low | 94 seta2 ... PrintMenuItem; moved in: hockey94:seta2, hockey94:startpause, hockey94:startpause1, hockey94:startpause3 (+1) |
| checks95_01 | not matched | $7F97E, no IDA label; 94 ManualGoalieMenu | $0807EB | checks94 | 76% | high | 94 ManualGoalieMenu ... assgoalietopuck; moved in: goalie94:ManualGoalieMenu, stats94:SelectGoalieMenu+$1A, stats94:DisplayPlayerSelectMenu, stats94:TimeoutMenu+$3E |
| assign95_01 | not matched | $807EC, no IDA label; 94 assdefd | $080BE9 | assign94 | 80% | high | 94 assdefd ... asswingd |
| checks95_02 | not matched | $80BEA, no IDA label; 94 asswingo | $08282D | checks94 | 88% | high | 94 asswingo ... check4bench; moved in: assign94:assdefo, assign94:assnothing, collide94:Setplass, input94:check4bench |
| assign95_02 | not matched | $8282E, no IDA label; 94 assbench | $082BCF | assign94 | 97% | high | 94 assbench ... assepen |
| onetimer95 | not matched | $82BD0, no IDA label; 94 assonetimer | $082FF9 | onetimer94 | 93% | high | 94 assonetimer ... EndOneTimer; moved in: title94:EndOneTimer |
| checks95_03 | not matched | $82FFA, no IDA label; 94 assgoaliectrl | $08369D | checks94 | 55% | medium | 94 assgoaliectrl ... CPgoalie; moved in: assign94:asseben, cards94:setSlotBit, assign94:assgoaliebreakwait |
| collide95_02 | not matched | $8369E, loc_8369E | $083EBF | collide94 | 88% | high | 94 CPgoalie ... HotColdLoop; moved in: checks94:CPgoalie, stats94:GetPlayerCount, crowd94:AttributeCalc, setup94:resetplstuff (+4) |
| input95_01 | not matched | $83EC0, loc_83EC0 | $084FE5 | input94 | 93% | high | 94 doinput ... compshoot; moved in: onetimer94:OneTimerTarget, onetimer94:OneTimerNearTbl, onetimer94:OneTimerFarTbl, onetimer94:OneTimerGoalieTbl (+3) |
| data95_01 | not matched | $84FE6, no IDA label | $087BA1 | data94 | 34% | medium | 94 DisplayPlayerList+$30 ... WriteLineData; moved in: stats94:DisplayPlayerList+$30, stats94:ExitAttributeScreen2, optsetup94:j_NewPO, stats94:getNameandAttrib (+18) |
| setup95_02 | not matched | $87BA2, sub_87BA2 | $088045 | setup94 | 70% | high | 94 PlayoffScreen ... PlayoffScreenDataTable |
| checks95_04 | not matched | $88046, unk_88046 | $088F05 | checks94 | 88% | high | 94 PlayoffTreeSetup ... puckfaceoff2+$2D0; moved in: data94:PlayoffTreeSetup, title94:DrawPlayoffSprite, display94:SetSframe, penalty94:UpdateScores (+3) |
| penalty95 | not matched | $88F06, sub_88F06 | $08996D | penalty94 | 94% | high | 94 limitfo ... prefmes+$38; moved in: title94:LeadSong, title94:ClearLeadSong, title94:LeadSongExit |
| data95_02 | not matched | $8996E, sub_8996E | $08A055 | data94 | 100% | high | 94 checkagr ... linelist; moved in: collide94:checkagr, display94:showref, penalty94:ClearPenaltyBuffer, title94:ClearPenalties (+4) |
| input95_02 | not matched | $8A056, loc_8A056 | $08A3FD | input94 | 97% | high | 94 SetLCmode ... AvgCline; moved in: penalty94:linebar, penalty94:getlinee, penalty94:AvgCline |
| checks95_05 | not matched | $8A3FE, no IDA label; 94 CompLine | $08B747 | checks94 | 27% | low | 94 CompLine ... goalieacc; moved in: penalty94:PrintScores1, attract94:EASportsScreen, period94:updatePPTeamTime, penalty94:ChkShotStat |
| input95_03 | not matched | $8B748, loc_8B748 | $08B9A7 | input94 | 97% | high | 94 doinput_cbut ... getGoalieSCnum |
| checks95_06 | not matched | $8B9A8, sub_8B9A8 | $08D399 | checks94 | 48% | medium | 94 dirtab ... demoread; moved in: crowd94:stopna2, penalty94:PenGoalStuff, data94:box, data94:DisplayPlayerAttributeMenu (+16) |
| replay95 | not matched | $8D39A, sub_8D39A | $08DF59 | replay94 | 80% | high | 94 updatereplay ... ClampReplayView |
| season95 | not matched | $8DF5A, sub_8DF5A | $0920BD | new | - | medium | New in 95: season mode. sub_8E06E is called from the main flow ($9B7C) and calls the season routines up to sub_91B6A; month names ($8F1E8), SEASON SETUP, period lengths; tables loc_91D84-loc_92090 are read by sub_8F35E / sub_8F3E0. Starts after ClampReplayView (replay94) and ends at loc_920BE, 94 GameStatisticsScreen (period94) |
| period95 | not matched | $920BE, loc_920BE | $0925AD | period94 | 87% | high | 94 GameStatisticsScreen+$3E ... TeamStatTextTblNoPen |
| stats95_01 | not matched | $925AE, locret_925AE | $0962ED | stats94 | 22% | low | 94 rtsStatTables ... CalculateTeamAttributeValues; moved in: period94:rtsStatTables, period94:PeriodStatsScreen+$52, period94:PeriodStatsScreen+$AC, period94:PeriodStatsScreen+$F0 (+9) |
| trade95 | not matched | $962EE, sub_962EE | $097C53 | new | - | medium | New in 95: schedule day ('More games', 'Change day', $9636B) then trades ('Trade Player', 'INVALID TRADE', $96C29-$97325). sub_962EE is called from sub_92FBA (stats95_01) |
| create95 | not matched | $97C54, sub_97C54 | $09ACE5 | new | - | medium | New in 95: create player (letter entry help text $981B6, 'Maximum Unallocated Points', the attribute names $9980C). sub_97C54 is called from trade95 (loc_97966); sub_9A9D4, sub_9AAE0, sub_9AB02 and sub_9AC02 are called from $9A6xx. It reuses 94 NameEntryFramer (cards94) at $986B6. Ends at sub_9ACE6, 94 NameEntryScreen |
| cards95_01 | not matched | $9ACE6, sub_9ACE6 | $09B72F | cards94 | 81% | high | 94 NameEntryScreen+$11E ... WriteNameRecord |
| records95 | not matched | $9B730, loc_9B730 | $09C019 | records94 | 84% | high | 94 UserNameEntry ... ClearWinRecords; moved in: cards94:WriteNameLog, cards94:ReadNameLog, cards94:NameLogIO, title94:ClearWinRecords |
| cards95_02 | not matched | $9C01A, sub_9C01A | $09C6EF | cards94 | 67% | high | 94 UpdateRecords ... CountGoalies |
| awards95 | not matched | $9C6F0, sub_9C6F0 | $09D9BF | new | - | medium | New in 95: end of season awards (HART MEMORIAL TROPHY ... CONN SMYTHE AWARD, $9C820). sub_9C6F0 is called from sub_9C01A (94 UpdateRecords) |
| title95_01 | not matched | $9D9C0, unk_9D9C0 | $09DD3D | title94 | 77% | high | 94 ClearShootout ... ShootoutShootCheck; moved in: shootout94:ClearShootout |
| shootout95 | not matched | $9DD3E, no IDA label; 94 NextShooter | $09E5EF | shootout94 | 85% | high | 94 NextShooter ... PrintShooterNames+$12; moved in: records94:RoundBigTxt |
| checks95_07 | not matched | $9E5F0, no IDA label; 94 puckshootout | $09F58F | checks94 | 75% | high | 94 puckshootout ... GetLowestPen; moved in: collide94:SetupPenaltyShot, data94:PenaltyShotBox, data94:PenaltyShotBox+$2E, data94:PenaltyShotBox+$78 (+10) |
| scout95 | not matched | $9F590, loc_9F590 | $0A00D5 | scout94 | 85% | high | 94 ScoutingReport ... BuildHotColdLists; moved in: crowd94:BuildHotColdLists |
| setup95_03 | not matched | $A00D6, sub_A00D6 | $0A0B3D | setup94 | 58% | medium | 94 StartScoutText ... GetTeamRating; moved in: crowd94:CompareHotColdTotals, crowd94:GetHotColdTotal, period94:PrintPlayerNameRight, title94:HotColdIcon (+13) |
| stats95_02 | not matched | $A0B3E, sub_A0B3E | $0A12A9 | stats94 | 58% | medium | 94 ScoringSummaryScreen+$88 ... DisplayPenaltyEntry |
| title95_02 | not matched | $A12AA, sub_A12AA | $0A1A59 | title94 | 53% | medium | sub_A12AA is 94 newTitleScreen (called from the main flow at $9ACE); the first matched unit is newTitleScreen+$CA at $A1376 |
| graphics95_01 | not matched | $A1A5A, unk_A1A5A | $1A1699 | graphics94 | 15% | low | 94 PicturePalette ... logoWPG |
| title95_03 | not matched | $1A169A, unk_1A169A | $1A1A19 | title94 | 100% | high | 94 TeamLogoPalettes |
| graphics95_02 | not matched | $1A1A1A, no IDA label | $1A6C27 | graphics94 | 0% | low | Unmatched 4bpp tiles after TeamLogoPalettes, zero padded to $1A6C28 |
| credits95 | not matched | $1A6C28, no IDA label | $1A72BF | teamdata94 | 0% | medium | Credits ($1A6C28, '$ 1994 Electronic Arts') and the credits list, same length-prefixed String format as 94 Credits / CreditsList (teamdata94 $5776-$5B1B); the text changed, so no byte match |
| checksum95 | not matched | $1A72C0, sub_1A72C0 | $1A730F | checksum94 | 100% | high | 94 ValidationRoutine |

## New in 95

Add a file here when the listing shows a system 94 does not have.

- `season95` `$08DF5A-$0920BD`: season mode. sub_8E06E is called from the main flow ($9B7C) and calls the season routines up to sub_91B6A; month names ($8F1E8), SEASON SETUP, period lengths; tables loc_91D84-loc_92090 are read by sub_8F35E / sub_8F3E0. Starts after ClampReplayView (replay94) and ends at loc_920BE, 94 GameStatisticsScreen (period94)
- `trade95` `$0962EE-$097C53`: schedule day ('More games', 'Change day', $9636B) then trades ('Trade Player', 'INVALID TRADE', $96C29-$97325). sub_962EE is called from sub_92FBA (stats95_01)
- `create95` `$097C54-$09ACE5`: create player (letter entry help text $981B6, 'Maximum Unallocated Points', the attribute names $9980C). sub_97C54 is called from trade95 (loc_97966); sub_9A9D4, sub_9AAE0, sub_9AB02 and sub_9AC02 are called from $9A6xx. It reuses 94 NameEntryFramer (cards94) at $986B6. Ends at sub_9ACE6, 94 NameEntryScreen
- `awards95` `$09C6F0-$09D9BF`: end of season awards (HART MEMORIAL TROPHY ... CONN SMYTHE AWARD, $9C820). sub_9C6F0 is called from sub_9C01A (94 UpdateRecords)
