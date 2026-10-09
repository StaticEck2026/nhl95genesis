;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	replay95_01 segment stub. Retail $00A536-$00A655.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$A536

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $00A536-$00A655 (frames95.asm defines them in the full build).
SPAlist = $5A34			;movea.l #x at $A54C
SPAfallback = $109C		;cmpi.w #x at $A614
SPAinjuryfall = $2454		;cmpi.w #x at $A5DC

; Main segment code
	include	replay95_01.asm
