;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	awards95 segment stub. Retail $09C6F0-$09DA4F.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9C6F0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $09C6F0-$09DA4F, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $9CB78 (main95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $9D546, $9D70E, $9D73C, $9D7B4, $9D844, $9D932, $9D9B4 (sram95)
setvram = $79936		;IDA: sub_79936. used at $9CE5A (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $9CA32, $9CACE, $9CEC8 (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $9C76A (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $9CE74, $9CE8C (video95_02)
VBlank_SetOptions = $7A418	;IDA: unk_7A418. used at $9CE08 (video95_02)
orjoy = $7A448			;IDA: sub_7A448. used at $9CE60 (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $9CD9E (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $9CDB4 (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $9CDD2 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $9CDE8 (video95_02)
ProcessInputWithRepeat = $7A762	;IDA: sub_7A762. used at $9CDA4, $9CDBA, $9CDD8, $9CDEE (video95_02)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $9CF1C (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $9C7BE, $9CAE0, $9CC7A, $9CCBA (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $9C818, $9CBA4, $9CBD2, $9CC2C, $9CC5E (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $9C9DE, $9CA88, $9CA9E, $9CB42, $9CD5C, $9CEA4 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $9CD74 (video95_03)
SkipStrings = $7CB42		;IDA: sub_7CB42. used at $9C802 (video95_03)
ReadAttributeNibbleD7 = $7CB60	;IDA: sub_7CB60. used at $9D108, $9D268, $9D2CA, $9D2F4 (video95_03)
GetDefenseStartD7 = $7CBB6	;IDA: sub_7CBB6. used at $9D1BC, $9D36C (video95_03)
FormatFirstNameD7 = $7CE56	;IDA: sub_7CE56. used at $9CC0E (video95_03)
FormatLastNameD7 = $7CE8E	;IDA: sub_7CE8E. used at $9CC40 (video95_03)
GetPlayerCountD7 = $83904	;IDA: sub_83904. used at $9D112 (collide95_02)
PlayoffScreen = $87BA2		;IDA: sub_87BA2. used at $9DA3E (data95_01)
ReadSeasonHeader = $8E228	;IDA: sub_8E228. used at $9D6A0, $9D736 (season95)
WriteSeasonHeader = $8E246	;IDA: sub_8E246. used at $9D6AC (season95)
ReadStandings = $8F332		;IDA: sub_8F332. used at $9D056, $9D500 (season95)
GetRosterName = $9649E		;IDA: sub_9649E. used at $9D20C (trade95)
SmallFontMap = $139094		;IDA: unk_139094. used at $9CE6E, $9CE86, $9CE9A (graphics95_01)
AwardsBgMap = $17409A		;no IDA label. used at $9CEB0 (graphics95_01)
FinalistsPanelMap = $1787C8	;IDA: unk_1787C8. used at $9CA94 (graphics95_01)
WinnerPanelMap = $178B12	;IDA: unk_178B12. used at $9CAAA (graphics95_01)
HartPic = $178EC6		;no IDA label. used at $9CA40 (graphics95_01)
NorrisPic = $179690		;no IDA label. used at $9CA44 (graphics95_01)
VezinaPic = $17A94A		;no IDA label. used at $9CA48 (graphics95_01)
ArtRossPic = $17B2E8		;no IDA label. used at $9CA4C (graphics95_01)
SelkePic = $17BF00		;no IDA label. used at $9CA58 (graphics95_01)
JenningsPic = $17E0D6		;no IDA label. used at $9CA50 (graphics95_01)
PresidentsPic = $17EE8E		;no IDA label. used at $9CA5C (graphics95_01)
ConnSmythePic = $17F76C		;no IDA label. used at $9CA60 (graphics95_01)
PearsonPic = $18022A		;no IDA label. used at $9CA54 (graphics95_01)

; Main segment code
	include	awards95.asm
