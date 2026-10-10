	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	checks95_06 segment stub. Retail $08B9A8-$08D399.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$8B9A8

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $08B9A8-$08D399, read from lst/nhl95.bin.
Opening2 = $9ADA		;IDA: loc_9ADA. used at $8CD02 (hockey95)
IntermissionStart = $9D18	;no IDA label. used at $8CBBC (hockey95)
sfx = $677AC			;IDA: sub_677AC. used at $8BC92, $8C3B4, $8CD2A (sound95_01)
play_new_song = $67938		;IDA: sub_67938. used at $8C39C, $8CD20 (sound95_01)
ChooseSong = $679C4		;IDA: sub_679C4. used at $8C472 (sound95_01)
setvram = $79936		;IDA: sub_79936. used at $8D16C (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $8D020, $8D07C, $8D282, $8D2AC, $8D2F4 (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $8D186, $8D1D0, $8D1E0, $8D1F0, $8D200, $8D210, $8D220, $8D230 (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $8CBB6 (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $8D196, $8D1AE (video95_02)
Framer = $7A270			;IDA: sub_7A270. used at $8C706 (video95_02)
VBlank_SetOptions = $7A418	;IDA: unk_7A418. used at $8D11A (video95_02)
orjoy = $7A448			;IDA: sub_7A448. used at $8D172 (video95_02)
nodiag = $7A488			;IDA: sub_7A488. used at $8D34A, $8D35A, $8D36A, $8D37A (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $8D344 (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $8D354 (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $8D364 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $8D374 (video95_02)
vtoa = $7C586			;IDA: sub_7C586. used at $8BDBE, $8BDE4, $8BE16, $8BFB2 (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $8D306, $8D328 (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $8D316, $8D338 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $8C694, $8C6E0, $8C7D4, $8C80C, $8C880, $8C896, $8C8D2, $8CFA8, $8D23A, $8D24E, $8D25E, $8D288 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $8C79C, $8C7F4, $8C820, $8C8CC (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $8C6AA (video95_03)
getpde = $7CAD0			;IDA: sub_7CAD0. used at $8C10C, $8C1BA (video95_03)
ReadAttributeNibble = $7CB4E	;IDA: sub_7CB4E. used at $8C4E4 (video95_03)
FormatPlayerName = $7CDC2	;IDA: sub_7CDC2. used at $8C796, $8C7EE, $8C81A (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $8C8C6 (video95_03)
GetPeriodTimeRemaining = $7D762	;IDA: sub_7D762. used at $8C4A0 (video95_03)
PrintScores1 = $7D776		;IDA: sub_7D776. used at $8C554 (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $8D2B2 (video95_03)
printbig1 = $7D908		;IDA: sub_7D908. used at $8C782 (video95_03)
setpde = $7DBCA			;IDA: sub_7DBCA. used at $8C1D6, $8C1F2 (video95_03)
assinsert = $81570		;IDA: sub_81570. used at $8C60C, $8CBC8, $8CC78 (checks95_02)
assreplace = $8157A		;IDA: sub_8157A. used at $8C5BA, $8CAAC (checks95_02)
EndOneTimer = $82F60		;IDA: sub_82F60. used at $8C606 (onetimer95)
EncodePW = $8756E		;IDA: sub_8756E. used at $8CCE6 (data95_01)
AddPenalty2 = $8916E		;IDA: sub_8916E. used at $8C5D4, $8CCAA, $8CCE0 (penalty95)
RemovePlayerFromList = $8962C	;IDA: sub_8962C. used at $8C670 (penalty95)
ClearPenaltyBuffer = $89A7C	;IDA: sub_89A7C. used at $8C632, $8C646, $8CC88 (data95_02)
ClearPenalties = $89A8A		;IDA: sub_89A8A. used at $8CCA0 (data95_02)
lcfound2 = $8A2FC		;IDA: sub_8A2FC. used at $8C6C8, $8C6D2 (input95_02)
ChkShotStat = $8ABDA		;IDA: sub_8ABDA. used at $8C398, $8C53C (checks95_05)
goalieacc = $8B4E0		;IDA: loc_8B4E0. used at $8BD02 (checks95_05)
SeasonGameOver = $8EF2A		;IDA: sub_8EF2A. used at $8CCFC (season95)
CountGoalies = $9C564		;IDA: sub_9C564. used at $8C70C (cards95_02)
EndPenaltyShotPlay = $9ECE6		;IDA: sub_9ECE6. used at $8C378 (checks95_07)
StanleyCupScreen = $A17B8	;IDA: sub_A17B8. used at $8CCF6 (title95_02)
RosterFont = $1383C6		;IDA: unk_1383C6. used at $8D180, $8D190, $8D1A8, $8D1BC (graphics95_01)
Teamblocksmap = $142906		;IDA: unk_142906. used at $8D1DA, $8D2DC (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $8D1CA (graphics95_01)
ControllerBgMap = $164AC8	;IDA: unk_164AC8. used at $8D26A (graphics95_01)
ControllerTitleMap = $16AA7C	;no IDA label. used at $8D294 (graphics95_01)
PadCursorMap = $16AD5A		;IDA: unk_16AD5A. used at $8D05C, $8D1EA (graphics95_01)
PadIconMap1 = $16B0B2		;no IDA label. used at $8D02C, $8D1FA (graphics95_01)
PadIconMap2 = $16B1C8		;no IDA label. used at $8D02C, $8D20A (graphics95_01)
PadIconMap3 = $16B2DE		;no IDA label. used at $8D02C, $8D21A (graphics95_01)
PadIconMap4 = $16B3F4		;no IDA label. used at $8D02C, $8D22A (graphics95_01)

; Main segment code
	include	checks95_06.asm
