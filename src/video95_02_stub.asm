;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	video95_02 segment stub. Retail $07A02A-$07A761.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$7A02A

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $07A02A-$07A761, read from lst/nhl95.bin.
SoundCmd = $676D8		;IDA: sub_676D8. jsr (x).l at $7A3EE, $7A5A2, $7A5BC, $7A5D6, $7A5F0, $7A62A, $7A64E (sound95_01)
sfx = $677AC			;IDA: sub_677AC. jsr (x).l at $7A3AE (sound95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. bra.w / jsr (x).l at $7A260, $7A324 (video95_01)
DecompressGraphics = $79AC4	;IDA: sub_79AC4. bsr.w at $7A268 (video95_01)
DoDMApro = $79AFE		;IDA: loc_79AFE. movea.l #x at $7A090 (video95_01)
forcefade = $79B24		;IDA: sub_79B24. bsr.w at $7A042, $7A06C (video95_01)
cramfade = $79B54		;IDA dc.b. bsr.w at $7A34E, $7A404, $7A434 (video95_01)
xyVmMap = $79C18		;IDA: sub_79C18. bsr.w at $7A2BC (video95_01)
remap = $79C42			;IDA: loc_79C42. movea.l #x at $7A08A (video95_01)
DumpSprites = $79C94		;IDA dc.b. bsr.w at $7A34A (video95_01)
DumpSprites2 = $79C98		;IDA dc.b. bsr.w at $7A430 (video95_01)
Framermap = $14C148		;IDA dc.b. #x at $7A2EC, $7A2F6. Framer map, tiles at +8 (graphics95_01)
Framermap2 = $14C308		;IDA: unk_14C308. #x at $7A310, $7A316. Second framer map, tiles at +8 (graphics95_01)

; Main segment code
	include	video95_02.asm
