;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	display95_02 segment stub. Retail $079D80-$07A029.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$79D80

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $079D80-$07A029, read from lst/nhl95.bin.
find3d = $7C5EE			;IDA: sub_7C5EE. bsr.w at $79D92 (video95_03)
rtss2 = $79CC8			;IDA: locret_79CC8. beq.w at $79F8C. An rts (video95_01)
Sprites = $CA56A		;IDA: unk_CA56A. movea.l #x at $79DCC, $79E86. Sprite frames and tiles (graphics95_01)
Rinktilelist = $C4A7C		;IDA: unk_C4A7C. movea.l #x at $79F90. Rink map (graphics95_01)
RevRinkTilelist = $16060E	;IDA: unk_16060E. movea.l #x at $79FA8, $79FEE. Reverse angle rink map (graphics95_01)

; Main segment code
	include	display95_02.asm
