	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	sram95 segment stub. Retail $009722-$009AC7.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9722

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $009722-$009AC7, read from lst/nhl95.bin: jsr (x).l carries the address.
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. jsr (x).l at $9736 (video95_02)
vcountwait = $7C6BE		;IDA: sub_7C6BE. jsr (x).l at $9816 (video95_03)
DefaultRosters = $96390		;IDA: sub_96390. jsr (x).l at $989C (trade95)
DefaultLineData = $8A5D8	;IDA: sub_8A5D8. jsr (x).l at $98A2 (checks95_05)
ClearCreatedPlayers = $98C88	;IDA: sub_98C88. jsr (x).l at $98A8 (create95)
NullSaveClear = $A0A2E		;IDA: nullsub_7. jsr (x).l at $98AE (setup95_03)

; Main segment code
	include	sram95.asm
