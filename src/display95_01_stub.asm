;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	display95_01 segment stub. Retail $00A204-$00A535.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$A204

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $00A204-$00A535, read from lst/nhl95.bin: jsr / jmp (x).l and movea.l #x carry the address.
updatescroll = $79F64		;IDA: sub_79F64. jsr (x).l at $A214 (display95_02)
checkfo = $88D52		;IDA: sub_88D52. jsr (x).l at $A220 (checks95_04)
showclock = $7C90A		;IDA: sub_7C90A. jsr (x).l at $A23C (video95_03)
showcrowd = $A0BF8		;IDA: sub_A0BF8. jsr (x).l at $A242 (stats95_02)
showref = $89A2E		;IDA: sub_89A2E. jsr (x).l at $A248 (data95_02)
addframe = $79D80		;IDA: sub_79D80. jsr (x).l at $A290, $A412 (display95_02)
jdtab = $7A54A			;IDA: unk_7A54A. movea.l #x at $A37A (video95_02)
addframe2 = $79DA8		;IDA: addframe2. jmp (x).l at $A3BE (display95_02)
SmallFontMap = $139094		;IDA: unk_139094. movea.l #x at $A4FE, $A514 (graphics95_01)

; Main segment code
	include	display95_01.asm
