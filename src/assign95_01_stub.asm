;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	assign95_01 segment stub. Retail $0807EC-$080BE9.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$807EC

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $0807EC-$080BE9, read from lst/nhl95.bin.
chkpk = $7D884			;IDA dc.b, no label. used at $8082A, $808A8 (video95_03)
assnothing = $81202		;no IDA label. used at $807FC, $80A0C (checks95_02)
assreplace = $8157A		;IDA: sub_8157A. used at $8083E, $808BC, $80A68 (checks95_02)
EvadePC = $8158E		;no IDA label. used at $809EE (checks95_02)
skateto = $8162C		;no IDA label. used at $809F4, $80B12, $80B1A, $80BA2 (checks95_02)
check4check = $816FA		;no IDA label. used at $809F8, $80BB0 (checks95_02)
check4bench = $82790		;no IDA label. used at $80800, $80A10 (checks95_02)
assdefdchase = $83220		;no IDA label. used at $808C4, $808EC. 95 only: sets bit 7 of $64(a3), then plays the carrier when near the puck (checks95_03)

; Main segment code
	include	assign95_01.asm
