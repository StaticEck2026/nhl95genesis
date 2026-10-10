;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	title95_02 segment stub. Retail $0A12AA-$0A1A59.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$A12AA

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $0A12AA-$0A1A59, read from lst/nhl95.bin.
SoundCmd = $676D8		;IDA: sub_676D8. used at $A1480, $A1494, $A14A6, $A14B4, $A1874, $A1888, $A189A, $A18A8 (sound95_01)
song = $678C2			;IDA: sub_678C2. used at $A14BE, $A18B2 (sound95_01)
play_new_song = $67938		;IDA: sub_67938. used at $A1476, $A186A (sound95_01)
setvram = $79936		;IDA: sub_79936. used at $A1302, $A1800 (video95_01)
setVram_0 = $7994C		;IDA: sub_7994C. used at $A172E (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $A138E, $A13C8, $A13FE, $A175C, $A1788, $A185A, $A1982 (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $A1818, $A182E (video95_01)
cramfade = $79B54		;no IDA label. used at $A1610, $A193C (video95_01)
DoDMA = $79CE6			;IDA: sub_79CE6. used at $A15DE, $A160A, $A1936 (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $A171C (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $A1424 (video95_02)
p_music_vblank = $7A3E6		;no IDA label. used at $A1620, $A1946 (video95_02)
vb2 = $7A3F6			;IDA: unk_7A3F6. used at $A16DE (video95_02)
orjoy = $7A448			;IDA: sub_7A448. used at $A159E (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $A18CC (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $A18D4 (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $A18E4 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $A18EC (video95_02)
printz = $7C810			;IDA: sub_7C810. used at $A1324, $A1344, $A1368, $A139A, $A13D8, $A1436, $A14EA, $A1734, $A1762, $A1834, $A1956 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $A156C (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $A133E, $A135E, $A1554 (video95_03)
waitx = $7D706			;IDA: sub_7D706. used at $A17A0 (video95_03)
RosterFont = $1383C6		;IDA: unk_1383C6. used at $A1414, $A141E (graphics95_01)
Teamblocksmap = $142906		;IDA: unk_142906. used at $A1812, $A1968 (graphics95_01)
HiScoreBgMap = $16334A		;IDA: unk_16334A. used at $A1740 (graphics95_01)
HiScoreImg = $16430A		;IDA: unk_16430A. used at $A176E (graphics95_01)
TitleScreenImg = $18DAA8	;IDA: unk_18DAA8. used at $A1374, $A13A6 (graphics95_01)
TitleImg = $1960D6		;no IDA label. used at $A13E4 (graphics95_01)
StanleyCupImg = $196C4C		;no IDA label. used at $A1840 (graphics95_01)
CupSprites = $19A0FA		;IDA: unk_19A0FA. used at $A181E, $A1994 (graphics95_01)
Credits = $1A6C28		;no IDA label. used at $A1442 (graphics95_02)
CreditsList = $1A6C6A		;no IDA label. used at $A14F6 (credits95)

; Main segment code
	include	title95_02.asm
