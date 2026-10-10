;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	title95_01 segment stub. Retail $09DA50-$09DD3D.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9DA50

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $09DA50-$09DD3D, read from lst/nhl95.bin.
randomd0 = $7C63A		;IDA: sub_7C63A. used at $9DB12 (video95_03)

; Main segment code
	include	title95_01.asm
