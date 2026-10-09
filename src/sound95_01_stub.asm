;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	sound95_01 segment stub. Retail $0676D8-$079901.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$676D8

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $0676D8-$079901, read from lst/nhl95.bin.
SndDriver = $AF44		;IDA: sub_AF44. jsr (x).l at $676D8, $6783C (sounddrv95)
randomd0 = $7C63A		;IDA: sub_7C63A. jsr (x).l at $67A06, $682B4 (video95_02)
Z80_Program_Code = $7E0E0	;IDA: Z80_Program_Code. movea.l #x at $68238. The 94 Z80 program, still loaded by p_initialZ80 (sound95_02)

; Main segment code
	include	sound95_01.asm
