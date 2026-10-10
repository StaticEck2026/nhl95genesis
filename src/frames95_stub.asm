;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	frames95 segment stub. Retail $005A34-$008DD7.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; External addresses outside $005A34-$008DD7: none. Every word is a direction offset inside its own table,
; a flag, or a frame / time pair; revframetbl is an incbin.
; .region code
	org	$5A34

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; Main segment code
	include	frames95.asm
