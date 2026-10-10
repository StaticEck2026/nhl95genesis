;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	collide95_02 segment stub. Retail $0836AC-$083EB1.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$836AC

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $0836AC-$083EB1, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $8393E (main95)
ReadSRAM = $9952		;IDA: sub_9952. used at $83926 (sram95)
randomd0s = $7C62E		;IDA: sub_7C62E. used at $83E94 (video95_03)
GetPeriodTime = $7D4CA		;IDA: sub_7D4CA. used at $83A20 (video95_03)
chkpk2 = $7D894			;IDA: sub_7D894. used at $839CE (video95_03)
Setplass = $81540		;IDA: sub_81540. used at $838B4 (checks95_02)
assinsert = $81570		;IDA: sub_81570. used at $838C4, $83994 (checks95_02)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $83DF8 (checks95_06)
GetRosterName = $9649E		;IDA: sub_9649E. used at $83A5E (trade95)
GetJerseyNumber = $965A8	;IDA: sub_965A8. used at $83A7A (trade95)
SetSeasonInjuries = $9F144	;IDA: sub_9F144. used at $836DA. 95 only: mark the season injuries (tmpdst -4) of team a2 from save RAM (checks95_07)

; Main segment code
	include	collide95_02.asm
