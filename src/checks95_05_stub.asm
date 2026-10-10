	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	checks95_05 segment stub. Retail $08A3FE-$08B733.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$8A3FE

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $08A3FE-$08B733, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $8A5E2 (teamdata95)
WriteSRAM = $98E6		;IDA: sub_98E6. used at $8A74A, $8A81C (sram95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $8A754, $8A826 (sram95)
ReadSRAM = $9952		;IDA: sub_9952. used at $8A5CC, $8A64E, $8A6A8, $8A70C, $8A7E2 (sram95)
setVram_0 = $7994C		;IDA: sub_7994C. used at $8AB18 (video95_01)
Vmaddr = $79A22			;IDA: sub_79A22. used at $8AD2C, $8AD4C, $8AEC0, $8AEE0, $8B05C, $8B07C, $8B1EC, $8B20C, $8B36A, $8B38A (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $8AB48, $8ADA0, $8ADD2, $8AF34, $8AF66, $8B0CC, $8B0FE, $8B25C, $8B28E, $8B3E4, $8B416 (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $8B09E, $8B22E, $8B426, $8B436, $8B498 (video95_01)
CopyPaletteToCRAM = $79BE2	;IDA: sub_79BE2. used at $8AB12 (video95_01)
SetScroll2 = $79CCA		;IDA: sub_79CCA. used at $8AD06, $8AE9A, $8B036, $8B1C6, $8B344 (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $8AB76, $8ACF0, $8AE84, $8B020, $8B1B0, $8B32E (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $8ADEC, $8AE04, $8AE1C, $8AE34, $8AE4C, $8AF80, $8AF98, $8AFB0, $8AFC8, $8AFE0, $8B118, $8B130, $8B148, $8B160, $8B178, $8B2A8, $8B2C0, $8B2D8, $8B2F0, $8B450, $8B468, $8B480, $8B4B2 (video95_02)
vb2 = $7A3F6			;IDA: unk_7A3F6. used at $8AAC8 (video95_02)
vtoa = $7C586			;IDA: sub_7C586. used at $8B574 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $8AB1E, $8AD7C, $8ADA6, $8AE5A, $8AF10, $8AF3A, $8AFEE, $8B0A8, $8B0D2, $8B186, $8B238, $8B262, $8B2FE, $8B3C0, $8B3EA, $8B4C0 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $8AE6E, $8B002, $8B19A, $8B312, $8B4D4 (video95_03)
loadTeamStruct = $7CAF0		;IDA: sub_7CAF0. used at $8AC82 (video95_03)
ReadAttributeNibbleD7 = $7CB60	;IDA: sub_7CB60. used at $8A6D2, $8A85C, $8A9C4, $8AA72, $8AAAA (video95_03)
GetDefenseStartD7 = $7CBB6	;IDA: sub_7CBB6. used at $8A6DA, $8A8B2, $8A95C, $8A9BC (video95_03)
setupTeamBlocksMap = $7D2AE	;IDA: sub_7D2AE. used at $8AD72, $8AF06, $8B3B2 (video95_03)
waitx = $7D706			;IDA: sub_7D706. used at $8AB60 (video95_03)
PrintScores1 = $7D776		;IDA: sub_7D776. used at $8A566 (video95_03)
ResetTeamEnergy = $7DBA2	;IDA: sub_7DBA2. used at $8A584 (video95_03)
AdjustFacingDirection = $80426	;IDA: sub_80426. used at $8B584, $8B5A2 (checks95_01)
SetPersonel = $836CC		;IDA: sub_836CC. used at $8A560 (collide95_02)
GetPlayerCountD7 = $83904	;IDA: sub_83904. used at $8A6E2, $8A8AA (collide95_02)
ResetBench = $83D5E		;IDA: sub_83D5E. used at $8A572 (collide95_02)
compshoot = $84FB6		;no IDA label. used at $8A56C (input95_01)
rtslc = $8A330			;IDA: locret_8A330. used at $8A502, $8A518, $8A520, $8A52E, $8A538, $8A558 (input95_02)
getlinee = $8A382		;IDA: sub_8A382. used at $8A418, $8A422, $8A472, $8A4D6 (input95_02)
AvgCline = $8A3C4		;no IDA label. used at $8A550 (input95_02)
doinput_cbut = $8B734		;IDA: loc_8B734. used at $8B6FC, $8B708 (checks95_05)
GoalieReadySPA = $8B9A8		;IDA: sub_8B9A8. used at $8B5AC, $8B622 (input95_03)
stopna = $8BB1A			;IDA: sub_8BB1A. used at $8B678 (checks95_06)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $8B5BA, $8B6BE, $8B6E6, $8B71A (checks95_06)
stopna2 = $8BCB0		;IDA: sub_8BCB0. used at $8B608, $8B612, $8B6AC (checks95_06)
playeracc = $8C086		;IDA: loc_8C086. used at $8B61C, $8B6F0 (checks95_06)
GetRosterName = $9649E		;IDA: sub_9649E. used at $8A86E, $8A90C, $8AA1C (trade95)
TeamRecordSRAM = $96A34		;IDA: unk_96A34. used at $8A6EE, $8A7BC (trade95)
RosterFont = $1383C6		;IDA: unk_1383C6. used at $8ADDC, $8ADFE, $8AE16, $8AE2E (graphics95_01)
SmallFontMap = $139094		;IDA: unk_139094. used at $8AF70, $8AF7A, $8AF92, $8AFAA, $8AFC2, $8B108, $8B112, $8B12A, $8B142, $8B15A, $8B298, $8B2A2, $8B2BA, $8B2D2, $8B440, $8B44A, $8B462, $8B47A (graphics95_01)
Teamblocksmap = $142906		;IDA: unk_142906. used at $8AD68, $8AEFC, $8B098, $8B228, $8B3A8 (graphics95_01)
Framermap = $14C148		;IDA: unk_14C148. used at $8B49E, $8B4A4 (graphics95_01)
EASportsMap = $14C796		;no IDA label. used at $8AB2A (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $8AE46, $8AFDA, $8B172, $8B2EA, $8B492 (graphics95_01)
Screen6Tiles1 = $16EABC		;no IDA label. used at $8B420 (graphics95_01)
Screen6Tiles2 = $16F7DA		;no IDA label. used at $8B430 (graphics95_01)

; Main segment code
	include	checks95_05.asm
