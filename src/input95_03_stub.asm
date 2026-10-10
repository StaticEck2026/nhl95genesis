;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	input95_03 segment stub. Retail $08B734-$08B9A7.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$8B734

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $08B734-$08B9A7, read from lst/nhl95.bin.
SPAlist = $5A34			;no IDA label. used at $8B74C (frames95)
sroot = $7C512			;IDA: sub_7C512. used at $8B814 (collide95_01)
vtoa = $7C586			;IDA: sub_7C586. used at $8B7A0 (video95_03)
goaliesave = $80478		;IDA: sub_80478. used at $8B884 (checks95_01)
rtss15 = $8B732			;IDA: locret_8B732. used at $8B77A, $8B966 (checks95_05)
doplayeracc = $8BCFA		;IDA: loc_8BCFA. used at $8B8DE, $8B96E (checks95_06)

; Main segment code
	include	input95_03.asm
