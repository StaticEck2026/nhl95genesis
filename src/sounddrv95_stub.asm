;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	sounddrv95 segment stub. Retail $00AF44-$0676D7.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; External addresses outside $00AF44-$0676D7: none. The driver only uses its RAM (ram_addrs.inc), Z80 RAM and the IO ports.
; .region code
	org	$AF44

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; Main segment code
	include	sounddrv95.asm
