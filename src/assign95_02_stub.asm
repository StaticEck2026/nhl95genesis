;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	assign95_02 segment stub. Retail $08282E-$082BCF.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$8282E

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $08282E-$082BCF, read from lst/nhl95.bin.
SprSort = $A8E6			;IDA: sub_A8E6. used at $82B9A (setup95_01)
setpads = $AB2A			;IDA: sub_AB2A. used at $829C6 (setup95_01)
chgplayer = $AB4E		;IDA: sub_AB4E. used at $82B04 (setup95_01)
Setplass = $81540		;IDA: sub_81540. used at $82996 (checks95_02)
assexit = $8155E		;IDA: sub_8155E. used at $8284C, $82BCC (checks95_02)
assreplace = $8157A		;IDA: sub_8157A. used at $82ABC (checks95_02)
EvadePC = $8158E		;no IDA label. used at $8297C (checks95_02)
skateto = $8162C		;no IDA label. used at $82982, $82ACE (checks95_02)
rtsskate = $81A5C		;IDA: locret_81A5C. used at $82834, $829AC, $82A3E, $82A82, $82A8E, $82AC8, $82AD8, $82B10, $82B18, $82B44 (checks95_02)
check4bench = $82790		;no IDA label. used at $82842 (checks95_02)
setplayer = $83960		;IDA: sub_83960. used at $82966 (collide95_02)
GoalieReadySPA = $8B9A8		;IDA: sub_8B9A8. used at $828CE (input95_03)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $828D4, $82924, $82A50, $82AAE, $82B94 (checks95_06)

; Main segment code
	include	assign95_02.asm
