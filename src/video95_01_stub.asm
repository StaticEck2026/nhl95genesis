;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	video95_01 segment stub. Retail $079902-$079D7F.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$79902

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $079902-$079D7F, read from lst/nhl95.bin.
vb2 = $7A3F6			;IDA: unk_7A3F6. move.l #x at $79B34. Vblank for palette fades only (video95_02)

; Main segment code
	include	video95_01.asm
