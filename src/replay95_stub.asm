;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	replay95 segment stub. Retail $08D39A-$08DF59.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$8D39A

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $08D39A-$08DF59, read from lst/nhl95.bin.
revframetbl = $8596		;no IDA label. used at $8DD46 (frames95)
setvideo = $A204		;IDA: sub_A204. used at $8D740, $8D8DC, $8D946, $8D9B4, $8DA0E, $8DA3E, $8DC22, $8DC3E (hockey95)
SprSort = $A8E6			;IDA: sub_A8E6. used at $8D73A, $8D9AE, $8DA08, $8DA38, $8DAA6, $8DAE4 (setup95_01)
setpads = $AB2A			;IDA: sub_AB2A. used at $8D8D2 (setup95_01)
Z80Program = $BD86		;no IDA label. used at $8D67C (sound95_01)
SoundBanks = $D8EC		;no IDA label. used at $8D698 (sound95_01)
SoundCmd = $676D8		;IDA: sub_676D8. used at $8D682, $8D68C, $8D69E, $8D6AC (sound95_01)
sfx = $677AC			;IDA: sub_677AC. used at $8DA32 (sound95_01)
SoundOff = $679B2		;IDA: sub_679B2. used at $8D668 (sound95_01)
DoFill = $79902			;IDA: sub_79902. used at $8D6F2 (sound95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $8DB3A, $8DB8C (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $8D702, $8D712 (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $8D6B8, $8DAC0 (display95_02)
forceblack2 = $7A054		;no IDA label. used at $8DBFE (video95_02)
ReadMenuJoy = $7A6AA		;IDA: sub_7A6AA. used at $8D7AE (video95_02)
vtoa = $7C586			;IDA: sub_7C586. used at $8D416, $8D438, $8D4D2, $8D4F4, $8D864 (video95_03)
vcountwait = $7C6BE		;IDA: sub_7C6BE. used at $8DC04, $8DC0A, $8DC28, $8DC44 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $8DB10, $8DB40, $8DB62, $8DB92 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $8DB58, $8DBAA (video95_03)
InitMenuState = $7E526		;IDA: sub_7E526. used at $8DAFC (menu95)
RestoreGameScreen = $7EBBE	;IDA: sub_7EBBE. used at $8D6CE (menu95)
ReplayMap = $1625F2		;no IDA label. used at $8D6FC, $8DB7E (graphics95_01)
ReplayIconMap = $162D18		;no IDA label. used at $8D70C, $8DB2C (graphics95_01)

; Main segment code
	include	replay95.asm
