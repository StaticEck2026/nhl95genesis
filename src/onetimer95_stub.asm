;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	onetimer95 segment stub. Retail $082BD0-$082FC1.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$82BD0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $082BD0-$082FC1, read from lst/nhl95.bin.
setc1player = $AD80		;IDA: loc_AD80. used at $82C3C (setup95_01)
setc2player = $AD8A		;IDA: loc_AD8A. used at $82C46 (setup95_01)
setc3player = $AD96		;IDA: loc_AD96. used at $82C50 (setup95_01)
setc4player = $ADA2		;IDA: loc_ADA2. used at $82C32 (setup95_01)
vtoa = $7C586			;IDA: sub_7C586. used at $82E6E (video95_03)
Setplass = $81540		;IDA: sub_81540. used at $82F9C (checks95_02)
assexit = $8155E		;IDA: sub_8155E. used at $82F92 (checks95_02)
Findhittype = $84A16		;IDA: sub_84A16. used at $82FB6 (input95_01)
doshot = $84B6E			;IDA: loc_84B6E. used at $82F04 (input95_01)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $82C64, $82F84 (checks95_06)

; Main segment code
	include	onetimer95.asm
