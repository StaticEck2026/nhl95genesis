;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	trade95 segment stub. Retail $0962EE-$097C53.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$962EE

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $0962EE-$097C53, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $963B8, $963EA, $9640C, $964AE, $96546, $965B8, $97A88 (main95)
WriteSRAM = $98E6		;IDA: sub_98E6. used at $96596, $96680, $968C2, $96A2C, $96B62, $96C0C (sram95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $9659C, $9699E, $96BA6 (sram95)
ReadSRAM = $9952		;IDA: sub_9952. used at $96486, $964FE, $9652C, $96578, $965FC, $9662E, $96898, $969D0, $96B34, $96BD8 (sram95)
Opening2 = $9ADA		;IDA: loc_9ADA. used at $970BA, $97796, $97B56 (hockey95)
clearTeamStats = $AE48		;IDA: sub_AE48. used at $96C64 (setup95_01)
setvram = $79936		;IDA: sub_79936. used at $9748C (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $97574, $975A0, $97894, $978DC, $97936, $97A52, $97ACA (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $97528 (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $96C14, $97074, $9766E, $97784, $97B44 (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $974A6, $974BE, $974D6, $974EE, $97510, $97542 (video95_02)
Framer = $7A270			;IDA: sub_7A270. used at $97278 (video95_02)
VBlank_SetOptions = $7A418	;IDA: unk_7A418. used at $9743A (video95_02)
orjoy = $7A448			;IDA: sub_7A448. used at $97492 (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $97042, $97836, $97BA8 (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $97058, $9784C, $97BBE (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $97BDC (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $97BF2 (video95_02)
ProcessInputWithRepeat = $7A762	;IDA: sub_7A762. used at $97048, $9705E, $9783C, $97852, $97BAE, $97BC4, $97BE2, $97BF8 (video95_02)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $96CFC, $96D1A, $96D38, $96D54, $96F60, $96F98, $96FA8, $96FB8, $9727E, $9767A, $976AE, $97714, $97736, $97980, $979A6, $97A6C, $97AD0, $97AE8 (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $96FD4, $97008, $977CA, $977FE, $97A98, $97B76 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $9635E, $96CBA, $96CD8, $96CEC, $96F46, $97264, $972B2, $97550, $97708, $9786E, $9789E, $978F8, $97940, $97954, $979BC, $979D0, $97A2E, $97AA6, $97B0C (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $972C6 (video95_03)
PrintSmallListItem = $7CB38	;IDA: sub_7CB38. used at $96FEC, $972A4, $977E2 (video95_03)
ReadAttributeNibbleD7 = $7CB60	;IDA: sub_7CB60. used at $96710, $9676C, $967CE, $975B0 (video95_03)
GetDefenseStartD7 = $7CBB6	;IDA: sub_7CBB6. used at $96722, $9677E, $967DE, $975B8 (video95_03)
FormatPlayerInitialD7 = $7CCF4	;IDA: sub_7CCF4. used at $97B70 (video95_03)
FormatPlayerNameWithAttribD7 = $7CD2C	;IDA: sub_7CD2C. used at $977C4 (video95_03)
FormatPlayerNameD7 = $7CD82	;IDA: sub_7CD82. used at $96FCE (video95_03)
CalcAttrib = $7CF16		;IDA: sub_7CF16. used at $9762C (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $97002, $977F8 (video95_03)
ScaleAttrib = $7D258		;IDA: sub_7D258. used at $9764E (video95_03)
TeamLogoBitmaps = $7D3F8	;IDA: unk_7D3F8. used at $978AA, $97904 (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $96C1E, $976E2, $9796A (video95_03)
SeasonPlayerOut = $7DBD8	;IDA: sub_7DBD8. used at $97640 (video95_03)
GetPlayerCountD7 = $83904	;IDA: sub_83904. used at $9660E, $9672C, $96788, $975C2 (collide95_02)
PAttribOverallMask = $85846	;IDA: dword_85846. used at $9761A (data95_01)
GAttribOverallMask = $859A8	;IDA: dword_859A8. used at $97626 (data95_01)
CheckSavedLines = $8A79A	;IDA: sub_8A79A. used at $967AE (checks95_05)
ReadTeamPlayerStats = $93226	;IDA: sub_93226. used at $9691E, $96AC0 (stats95_01)
WriteTeamPlayerStats = $932F8	;IDA: sub_932F8. used at $9695C, $96B02 (stats95_01)
CreateScreenGfx = $97C54	;IDA: sub_97C54. used at $97966 (create95)
SetInjuryGames = $9F1EA		;IDA: sub_9F1EA. used at $9698C, $96B9A (checks95_07)
GetInjuryGames = $9F232		;IDA: sub_9F232. used at $9697C (checks95_07)
InsertInjurySlot = $9F3B8		;IDA: sub_9F3B8. used at $96B8A (checks95_07)
DeleteInjurySlot = $9F40E		;IDA: sub_9F40E. used at $96992 (checks95_07)
SmallFontMap = $139094		;IDA: unk_139094. used at $974A0, $974B8, $974D0, $974E8, $974FC (graphics95_01)
Teamblocksmap = $142906		;IDA: unk_142906. used at $97522, $97588 (graphics95_01)
Framermap = $14C148		;IDA: unk_14C148. used at $9752E, $97534 (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $9750A (graphics95_01)
TradeBgMap = $172CCC		;IDA: unk_172CCC. used at $9755C (graphics95_01)
GMDecisionMap = $180D54		;IDA: unk_180D54. used at $9787A (graphics95_01)
TradeAdvantageMap2 = $181B04	;IDA: unk_181B04. used at $97AB2 (graphics95_01)
TradeAdvantageMap1 = $18277C	;IDA: unk_18277C. used at $97A3A (graphics95_01)
TeamLogoPalettes = $1A169A	;IDA: unk_1A169A. used at $978C2, $97920 (graphics95_01)

; Main segment code
	include	trade95.asm
