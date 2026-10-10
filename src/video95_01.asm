; $079902  Adapted from video94.asm: display helpers
;	NHL 95 segment $79902-$79D7F, from lst/nhl95.bin.lst. The 94 middle94_1 / middle94_2 vdp helpers in a new order: DoFill, setvram,
;	setVram_0, Vmaddr, dobitmap, DoDMA_clearCallbackPointer, DecompressGraphics (95: no packed graphics), DoDMApro, WaitDMA, forcefade,
;	cramfade, CopyPaletteToCRAM, xyVmMap, remap; then the display94 vblank transfers DumpSprites, DumpSprites2, DoDMAlist (ends at the
;	shared rts rtss2), SetScroll2; then DoDMA (95: no Z80 bus request). display95_02 (94 addframe) follows at $79D80.
;	cramfade ($79B54) and DumpSprites ($79C94) are IDA dc.b, written as instructions.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp; fixopcodes.js patches the
;	cmp encoding after assembly.

; fill vram
; d0 = bytes to fill
; d1 = vram address
; d2 = data to fill with
DoFill	;IDA: sub_79902. Called from menu95, video95_03. 95 writes the long straight to the vdp (94 went through dmaram)
	movem.l	d3/a1,-(sp)
	movea.l	#VDP_DATA,a1
	andi.l	#$FFFF,d1
	asl.l	#2,d1
	lsr.w	#2,d1
	ori.w	#$4000,d1
	swap	d1
	move.l	d1,4(a1)
	move.w	d2,d3
	swap	d3
	move.w	d2,d3
	lsr.w	#1,d0
	subq.w	#1,d0
.0
	move.l	d3,(a1)
	dbf	d0,.0
	movem.l	(sp)+,d3/a1
	rts

; d0 = color to fade to
setvram	;IDA: sub_79936. Fade every colour to d0, then fall into setVram_0
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$3F,d1
.0
	move.w	d0,(a0)+
	dbf	d1,.0
	move.w	#$18,(palcount).w
	bsr.w	forcefade
setVram_0	;IDA: sub_7994C. 93 name: second half of 92 setVram (no fade): clear vram and set the VDP registers from disflags, Map1col,
	;VmMap1-3, VSPRITES and VSCRLPM. Falls in from setvram, called from checks95_05, menu95, title95_02
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	move.w	#$8F02,(VDP_CTRL).l
	clr.w	d0
	bsr.w	Vmaddr
	move.w	#$3FFF,d0
	clr.l	d1
.9
	move.l	d1,(a0)
	dbf	d0,.9
	move.w	#$8C00,d0	;8 for shadow mode
	btst	#df32c,(disflags).w
	bne.w	.i32
	ori.w	#$81,d0
.i32
	move.w	d0,4(a0)	;40 col mode, no interlace, normal brightness
	move.w	#$8004,4(a0)	;512 color palette enable
	move.w	#$8164,4(a0)
	move.w	#$9001,d0	;playfield is 64x32
	cmpi.w	#6,(Map1col1).w
	beq.w	.i64
	move.w	#$9003,d0
.i64
	move.w	d0,4(a0)
	move.w	#$8200,d0
	move.b	(VmMap1).w,d0
	lsr.b	#2,d0
	andi.b	#$38,d0
	move.w	d0,4(a0)
	move.w	#$8400,d0
	move.b	(VmMap2).w,d0
	lsr.b	#5,d0
	move.w	d0,4(a0)
	move.w	#$8300,d0
	move.b	(VmMap3).w,d0
	lsr.b	#2,d0
	andi.b	#$3E,d0
	move.w	d0,4(a0)
	move.w	#$8500,d0
	move.b	(VSPRITES).w,d0
	lsr.b	#1,d0
	move.w	d0,4(a0)
	move.w	#$8D00,d0
	move.b	(VSCRLPM).w,d0
	lsr.b	#2,d0
	move.w	d0,4(a0)
	move.w	#$9100,4(a0)	;disable plane 3 graphics
	move.w	#$9200,4(a0)	;disable plane 3 graphics
	move.w	#$8700,4(a0)	;Palette # 0 is border/transparent
	move.w	#$8B00,4(a0)	;Scroll mode (entire scroll)
	move.l	#$40000010,4(a0)	;vsram
	move.l	#0,(a0)	;playfield 1/2
	move.w	(sp)+,(disflags).w
	rts

; set video port to address d0
; d0 = vram address
; returns a0 = Vdata!!!
Vmaddr	;IDA: sub_79A22
	movea.l	#VDP_DATA,a0
	asl.l	#2,d0
	lsr.w	#2,d0
	ori.w	#$4000,d0
	swap	d0
	andi.w	#3,d0
	move.l	d0,4(a0)
	rts

dobitmap	;IDA: sub_79A3C. Copy the palettes flagged in d5 to palfadenew, then write the map at a1 to the screen at printx / printy.
	;Called from most screens. 95 steps the palettes with adda.w and always ends in DoDMA_clearCallbackPointer (94 skipped it when sflags6 bit 0)
	move.w	(printy).w,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.l	d0-d3/d5-d6/a0-a3,-(sp)
	move.w	d1,d6
	movea.w	#(palfadenew-M68K_RAM),a3
	bra.w	.00
.01
	move.b	(a0,d0.w),(a3,d0.w)
	dbf	d0,.01
.02
	adda.w	#$20,a0
	adda.w	#$20,a3
.00
	moveq	#$1F,d0
	lsr.w	#1,d5
	bcs.s	.01
	bne.s	.02
	move.w	(printa).w,d5
	andi.w	#$F800,d5
	move.w	$E(sp),d2
	subq.w	#1,d2
.loop2
	bsr.w	xyVmMap
	move.w	d6,d0	;y start
	mulu.w	(a1),d0	;map width
	add.w	2(sp),d0
	asl.w	#1,d0
	move.w	$A(sp),d1
	subq.w	#1,d1
.loop1
	move.w	4(a1,d0.w),d3
	add.w	d4,d3
	eor.w	d5,d3
	move.w	d3,(a0)
	addq.w	#2,d0
	dbf	d1,.loop1
	addq.w	#1,(printy).w
	addq.w	#1,d6
	dbf	d2,.loop2
	bsr.w	DoDMA_clearCallbackPointer
	movem.l	(sp)+,d0-d3/d5-d6/a0-a3
	move.w	(sp)+,(disflags).w
	move.w	(sp)+,(printy).w
	rts

DoDMA_clearCallbackPointer	;IDA: sub_79AC0. 93 name. Clear callbackPtr, fall into DecompressGraphics
	clr.l	(callbackPtr).w
DecompressGraphics	;IDA: sub_79AC4. 93 name. a2 = graphics data, d4 = start char. Called from video95_02. 95 has no decompressor:
	;a packed block (size bit 15 set) only moves d4 past its chars
	movem.l	d0-d1/a0-a6,-(sp)
	movea.l	a2,a0
	move.w	d4,d1
	asl.w	#5,d1
	move.w	(a0)+,d0
	beq.w	.done
	bmi.w	.packed
	add.w	d0,d4
	asl.w	#4,d0
	pea	(.done).l
	tst.l	(callbackPtr).w
	beq.w	DoDMApro
	movea.l	(callbackPtr).w,a1
	bra.w	remap
.packed
	andi.w	#$7FFF,d0
	add.w	d0,d4
.done
	movem.l	(sp)+,d0-d1/a0-a6
	rts

DoDMApro	;IDA: loc_79AFE. DoDMA protected from vblank (dfng set)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	bsr.w	DoDMA
	move.w	(sp)+,(disflags).w
	rts

WaitDMA	;IDA: sub_79B12. Wait for the vdp dma busy bit to clear
	move.w	(VDP_CTRL).l,-(sp)
	btst	#1,1(sp)
	addq.w	#2,sp
	bne.s	WaitDMA
	rts

forcefade	;IDA: sub_79B24. Run the palette fade to the end: vbint = vb2 (fades only), interrupts on, wait for palcount to go negative
	move	sr,-(sp)
	move.l	(vbint).w,-(sp)
	move.w	(disflags).w,-(sp)
	bclr	#dfng,(disflags).w
	move.l	#vb2,(vbint).l
	move	#$2500,sr
.1
	tst.w	(palcount).w
	bpl.s	.1
	move.w	(sp)+,(disflags).w
	move.l	(sp)+,(vbint).w
	move	(sp)+,sr
	rts

; fade from current color in color ram to color held in palfadenew
; this should be called during vblank because palette changes punch holes in video
cramfade	;$79B54. IDA dc.b, no xref in the listing
	tst.w	(palcount).w
	bmi.w	rtss2
	cmpi.w	#$64,(palcount).w
	beq.w	CopyPaletteToCRAM
	subq.w	#1,(palcount).w
	bmi.w	rtss2
	clr.l	d0
	move.w	(palcount).w,d0
	cmp.w	#$18,d0
	bgt.w	rtss2
	divu.w	#3,d0
	swap	d0
	asl.w	#2,d0
	moveq	#2,d3
	asl.w	d0,d3
	moveq	#$E,d5
	asl.w	d0,d5
	move.w	d5,d4
	not.w	d4
	movea.l	#palfadenew,a1
	movea.l	#VDP_DATA,a0
	clr.w	d6
.top
	move.w	d3,d2
	move.w	d6,d0
	swap	d0
	move.w	#$20,d0
	move.l	d0,4(a0)
	move.w	(a0),d7
	move.w	d7,d0
	and.w	d5,d0
	move.w	(a1)+,d1
	and.w	d5,d1
	cmp.w	d1,d0
	beq.w	.next
	blt.w	.nn
	neg.w	d2
.nn
	add.w	d2,d0
	and.w	d4,d7
	or.w	d0,d7
	move.l	#$C000,d0
	move.b	d6,d0
	swap	d0
	move.l	d0,4(a0)
	move.w	d7,(a0)
.next
	addq.w	#2,d6
	cmp.w	#$80,d6
	bne.s	.top
	rts

CopyPaletteToCRAM	;IDA: sub_79BE2. 93 name. Copy all 64 palfadenew colours to colour ram (dfng set), then palcount = -1. Called from
	;cramfade and checks95_05. 95 writes cram straight (94 waited for the dma and the Z80 bus)
	movem.l	d0/a0-a1,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movea.w	#(palfadenew-M68K_RAM),a1
	movea.l	#VDP_DATA,a0
	move.l	#$C0000000,4(a0)	;cram write, address 0
	moveq	#$1F,d0
.0
	move.l	(a1)+,(a0)
	dbf	d0,.0
	st	(palcount).w
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0/a0-a1
	rts

xyVmMap	;IDA: sub_79C18. Set the vdp write address to printx, printy in the map at VmMap1 + printm
	movem.l	d0-d2,-(sp)
	move.w	(printx).w,d0
	move.w	(printy).w,d1
	movea.w	#(VmMap1-M68K_RAM),a0
	adda.w	(printm).w,a0
	move.w	2(a0),d2
	asl.w	d2,d1
	add.w	d1,d0
	asl.w	#1,d0
	add.w	(a0),d0
	bsr.w	Vmaddr
	movem.l	(sp)+,d0-d2
	rts

remap	;IDA: loc_79C42. Write d0 chars at a0 to vram d1, each pixel through the colour map at a1. Reached from DecompressGraphics
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.l	d0-d4/a0-a2,-(sp)
	exg	d1,d0
	movea.l	a0,a2
	bsr.w	Vmaddr
	subq.w	#1,d1
.1
	moveq	#3,d0
	move.w	(a2)+,d2
	clr.w	d3
.11
	move.w	d2,d4
	andi.w	#$F,d4
	lsr.w	#1,d4
	move.b	(a1,d4.w),d4
	btst	#0,d2
	bne.w	.2
	lsr.w	#4,d4
.2
	andi.w	#$F,d4
	or.b	d4,d3
	ror.w	#4,d3
	ror.w	#4,d2
	dbf	d0,.11
	move.w	d3,(a0)
	dbf	d1,.1
	movem.l	(sp)+,d0-d4/a0-a2
	move.w	(sp)+,(disflags).w
	rts

DumpSprites	;$79C94. IDA dc.b. 93 name (display94). Transfer (by dma) scroll stuff, sprite table, vram data in dmalist. IDA dc.b, no xref in the listing.
	;Falls into DumpSprites2
	bsr.w	SetScroll2
DumpSprites2	;93 name (display94). Transfer sprite table, then the dma list. Falls into DoDMAlist
	movea.w	#(Satt-M68K_RAM),a0
	move.w	(Sattsize).w,d0	;93 Sattsize: words
	move.w	(VSPRITES).w,d1
	bsr.w	DoDMA
DoDMAlist	;IDA: sub_79CA8 (display94). Transfer data from dmalist. Also called from video95_03
	movea.l	(DMAlistend).w,a6
	cmpa.l	#DMAList,a6
	beq.w	rtss2	;list empty
.0
	move.w	-(a6),d1	;vram address
	move.w	-(a6),d0	;words
	movea.l	-(a6),a0	;source
	bsr.w	DoDMA
	cmpa.l	#DMAList,a6
	bne.s	.0
rtss2	;IDA: locret_79CC8. Shared rts (93 rtss; 94 kept it in collide94), branched to from cramfade, collide95_01, display95_02, setup95_02,
	;video95_03, and movea.l #x in data95_01
	rts

SetScroll2	;IDA: sub_79CCA. 93 name (display94); 93 IDA DoScroller. Write Hscroll / Vscroll to the vdp. Called from DumpSprites, checks95
	move.w	(VSCRLPM).w,d0
	addq.w	#2,d0
	bsr.w	Vmaddr
	move.w	(Hscroll).w,(a0)
	move.l	#$40020010,4(a0)	;vsram write, address 2
	move.w	(Vscroll).w,(a0)
	rts

; initiate dma transfer (dma transfer bug is compensated for)
; d0 = words to transfer
; d1 = destination vram address
; a0 = source address
DoDMA	;IDA: sub_79CE6. 95 drops the 94 Z80 bus request, the sr save and the last word fix for a source in RAM
	movem.l	d2/a1,-(sp)
	move.w	d0,d2
	add.w	d2,d2
	add.w	a0,d2
	bcc.w	.nd
	beq.w	.nd
	lsr.w	#1,d2	;do 2 transers if source address crosses 64k boundary
	sub.w	d2,d0
	move.w	d0,-(sp)
	bsr.w	.dd
	move.w	(sp)+,d0
	add.w	d0,d0
	add.w	d0,d1
	adda.w	d0,a0
	move.w	d2,d0
	bra.w	.nd
.dd	;IDA: sub_79D10 (only DoDMA calls it)
	movem.l	d2/a1,-(sp)
.nd
	lea	(VDP_CTRL).l,a1
	move.w	#$8154,(a1)
	move.w	#$8F02,(a1)
	move.w	#$9300,d2
	move.b	d0,d2
	move.w	d2,(a1)
	move.w	#$9400,d2
	lsr.w	#8,d0
	move.b	d0,d2
	move.w	d2,(a1)
	move.l	a0,d0
	lsr.l	#1,d0
	move.w	#$9500,d2
	move.b	d0,d2
	move.w	d2,(a1)
	lsr.l	#8,d0
	move.w	#$9600,d2
	move.b	d0,d2
	move.w	d2,(a1)
	lsr.l	#8,d0
	andi.b	#$7F,d0
	move.w	#$9700,d2
	move.b	d0,d2
	move.w	d2,(a1)
	clr.l	d0
	move.w	d1,d0
	asl.l	#2,d0
	lsr.w	#2,d0
	ori.l	#$804000,d0
	move.l	d0,(dmaram).w
	move.w	(dmaram+2).w,(a1)
	move.w	(dmaram).w,(a1)
	bsr.w	WaitDMA
	move.w	#$8164,(a1)
	movem.l	(sp)+,d2/a1
	rts
