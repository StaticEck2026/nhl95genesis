;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	sound95_02 segment stub. Retail $07E0E0-$07E36B.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$7E0E0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $07E0E0-$07E36B, read from lst/nhl95.bin.
fm_instrument_patches = $79502	;dc.b x at $7E358, $7E35A: the Z80 ld bc / ld a bytes (sound95_01)

; Main segment code
	include	sound95_02.asm
