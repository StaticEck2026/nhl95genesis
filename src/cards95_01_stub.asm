;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	cards95_01 segment stub. Retail $09ACE6-$09B6F3.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9ACE6

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $09ACE6-$09B6F3, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $9ADA0 (main95)
WriteSRAM = $98E6		;IDA: sub_98E6. used at $9B622, $9B6A6, $9B6E2 (sram95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $9B5C4, $9B6E8 (sram95)
ReadSRAM = $9952		;IDA: sub_9952. used at $9B5FA, $9B646, $9B6CE (sram95)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $9AD7E (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $9AD0A, $9AD1A (video95_01)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $9AED4 (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $9AEC6 (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $9AEB8 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $9AEAA (video95_02)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $9B136, $9B1DA, $9B4B6, $9B4CA, $9B4DA (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $9ADBA, $9B110, $9B2F0, $9B3EA, $9B3FA, $9B480, $9B4D4 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $9AD2C, $9AD84, $9ADFC, $9AE54, $9AFB2, $9AFC2, $9B0BA, $9B0E2, $9B12A, $9B1AE, $9B1CE, $9B2B2 and 3 more (video95_03)
print = $7C822			;IDA: sub_7C822. used at $9B24E (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $9AFDC, $9B04A, $9B0D2, $9B1A8 (video95_03)
TeamLogoBitmaps = $7D3F8	;IDA: unk_7D3F8. used at $9AD4A (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $9ADC0 (video95_03)
NameEntryFramer = $986B6	;IDA: sub_986B6. used at $9AE26, $9B07A (create95)
CreateRatingsGfx = $98AFE	;IDA: sub_98AFE. used at $9ACF2 (create95)
NameInUse = $9B7EA		;IDA: sub_9B7EA. used at $9ADEA, $9AF90 (records95)
WriteNameLog = $9B86C		;IDA: sub_9B86C. used at $9B5BA (records95)
ReadNameLog = $9B876		;IDA: sub_9B876. used at $9ADDA (records95)
ClearNameHelp = $9B8B2		;IDA: sub_9B8B2. used at $9B124, $9B1C8 (records95)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $9AD04 (graphics95_01)
NameEntryBgMap = $1834F4	;IDA: unk_1834F4. used at $9AD14 (graphics95_01)
TeamLogoPalettes = $1A169A	;IDA: unk_1A169A. used at $9AD5C (graphics95_01)

; Main segment code
	include	cards95_01.asm
