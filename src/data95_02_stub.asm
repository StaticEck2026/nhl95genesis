	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	data95_02 segment stub. Retail $08996E-$08A055.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$8996E

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $08996E-$08A055, read from lst/nhl95.bin.
randomd0 = $7C63A		;IDA: sub_7C63A. used at $899B8, $89A00 (video95_03)
rtspen = $8913E			;IDA: locret_8913E. used at $89A34, $89F62, $89F6C (penalty95)
PushRef = $89820		;IDA: sub_89820. used at $89FD8 (penalty95)

; Main segment code
	include	data95_02.asm
