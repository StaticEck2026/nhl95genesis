	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	setup95_02 segment stub. Retail $087BA2-$088045.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$87BA2

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $087BA2-$088045, read from lst/nhl95.bin.
song = $678C2			;IDA: sub_678C2. used at $87DFE (sound95_01)
setvram = $79936		;IDA: sub_79936. used at $87BFE (video95_01)
Vmaddr = $79A22			;IDA: sub_79A22. used at $87FD6 (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $87CB8, $87F50, $87F9E (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $87C4A, $87C7C, $87C8C, $87CE6 (video95_01)
cramfade = $79B54		;no IDA label. used at $87FE6 (video95_01)
rtss2 = $79CC8			;IDA: locret_79CC8. used at $87E20 (video95_01)
DoDMA = $79CE6			;IDA: sub_79CE6. used at $87FCC (video95_01)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $87C64 (video95_02)
p_music_vblank = $7A3E6		;no IDA label. used at $87FF0 (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $87E34 (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $87E3C (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $87E44 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $87E4C (video95_02)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $87D92, $87DAA (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $87C04, $87C22, $87C92, $87D22, $87D4A, $87D68, $87DD4 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $87F28 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $87C1C, $87C36 (video95_03)
SkipStrings = $7CB42		;IDA: sub_7CB42. used at $87DC0 (video95_03)
printbig = $7D916		;IDA: sub_7D916. used at $87DC6 (video95_03)
rtsLineData = $87BA0		;IDA: locret_87BA0. used at $87BA8, $87BB8, $87E7C, $87E98, $87EA0, $87ED0 (data95_01)
PlayoffTreeSetup = $88046	;IDA: unk_88046. used at $87D0E (checks95_04)
DrawPlayoffSprite = $881B0	;IDA: sub_881B0. used at $87E26 (checks95_04)
SmallFontMap = $139094		;IDA: unk_139094. used at $87C50 (graphics95_01)
Teamblocksmap = $142906		;IDA: unk_142906. used at $87C44, $87F84 (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $87C76 (graphics95_01)
Arrowsmap = $1835D6		;IDA: unk_1835D6. used at $87C82, $87F32 (graphics95_01)
ScoutMap = $18394C		;no IDA label. used at $87C9E (graphics95_01)
PlayoffSprite = $1842DA		;IDA: unk_1842DA. used at $87CBE (graphics95_01)

; Main segment code
	include	setup95_02.asm
