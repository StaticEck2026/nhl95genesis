;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	checks95_08 segment stub. Retail $082FC2-$082FF9.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$82FC2

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $082FC2-$082FF9, read from lst/nhl95.bin.
assexit = $8155E		;IDA: sub_8155E. used at $82FE2 (checks95_02)
rtsskate = $81A5C		;IDA: locret_81A5C. used at $82FC8 (checks95_02)
SetShotMode = $84A36		;IDA: loc_84A36. used at $82FD6 (input95_01)
ShotMode = $84AD0		;IDA: loc_84AD0. used at $82FF4 (input95_01)

; Main segment code
	include	checks95_08.asm
