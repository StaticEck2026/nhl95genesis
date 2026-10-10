;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	checks95_03 segment stub. Retail $082FFA-$0836AB.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$82FFA

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $082FFA-$0836AB, read from lst/nhl95.bin.
randomd0 = $7C63A		;IDA: sub_7C63A. used at $8352A, $8354C (video95_03)
checkanim = $7FDAE		;no IDA label. used at $830A0 (checks95_01)
rtss21 = $809FC			;no IDA label. used at $83344, $83366 (assign95_01)
assexit = $8155E		;IDA: sub_8155E. used at $83004, $8321A, $8358C (checks95_02)
skateto = $8162C		;no IDA label. used at $83350, $83372, $8355E (checks95_02)
check4check2 = $8180E		;no IDA label. used at $8335A (checks95_02)
rtsskate = $81A5C		;IDA: locret_81A5C. used at $830AA, $830D0, $830DA, $835CC, $835E6, $835EE, $83600, $8361A, $83622, $83646, $83652, $8365A, $83668, $83674, $8367C, $83686, $836A0 (checks95_02)
check4bench = $82790		;no IDA label. used at $830AE (checks95_02)
SetPersonel = $836CC		;IDA: sub_836CC. used at $83612, $836A8 (collide95_02)
AddPenalty = $89140		;IDA: sub_89140. used at $831A2 (penalty95)
AddPenalty2 = $8916E		;IDA: sub_8916E. used at $8303C, $8311C (penalty95)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $831F2, $834C2, $83544 (checks95_06)

; Main segment code
	include	checks95_03.asm
