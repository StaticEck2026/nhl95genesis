	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	fourway95 segment stub. Retail $07DEA0-$07E0DF.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$7DEA0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $07DEA0-$07E0DF, read from lst/nhl95.bin.
dobitmap = $79A3C		;IDA: sub_79A3C. bra.w at $7DF64 (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. jsr (x).l at $7DEB8, $7DF74 (video95_01)
ReadJoy = $7A52A		;IDA: sub_7A52A. jmp (x).l at $7E0DA (video95_02)
printz = $7C810			;IDA: sub_7C810. bsr.w at $7DF3C (video95_03)
print = $7C822			;IDA: sub_7C822. bra.w at $7DF98 (video95_03)
PrintSmallListItem = $7CB38	;IDA: sub_7CB38. bsr.w at $7DF88 (video95_03)
PushTime = $7D0BC		;IDA: sub_7D0BC. bsr.w at $7DF94 (video95_03)
EASNmap = $180B4E		;IDA: unk_180B4E. movea.l #x at $7DF46, $7DF6E (graphics95_01)
ArenaGfxBank = $1A1A1A		;dc.l x+n at $7DEC2, $7DED2, $7DEE2, $7DEF2, $7DF02, $7DF12, $7DF22 (TeamGfxList rows; graphics95_02)

; Main segment code
	include	fourway95.asm
