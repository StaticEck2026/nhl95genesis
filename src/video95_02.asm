; $07A02A  Adapted from video94.asm: display helpers
;	NHL 95 segment $7A02A-$7A761, from lst/nhl95.bin.lst. 94 forceblack, forceblack2, the graphics decompressor (DecompressBytecode,
;	jump_table, the Opcode_* handlers, FlushOutputBuffer; no caller in 95), AddSmallFont, DecompressGraphicsWithCallback, Framer,
;	AddFramer, the 95 AddFramer2; moved in: hockey94 VBjsr, display94 VBlank, sound94 p_music_vblank (95: pads, then SoundCmd 1),
;	display94 vb2 and IRQ7, attract94 VBlank_SetOptions; then orjoy, the 95 orjoy4way, nodiag, ReadJoy1-4, ReadJoy, jdtab, sound94
;	ReadJoyData ... ResetZ80Bus (95 pauses the sound driver around the pad reads), then the 95 ReadMenuJoy. collide95_01 follows at $7A762.
;	IDA dc.b written as instructions: forceblack2 ... AddSmallFont ($7A054-$7A263), AddFramer ($7A2EC), VBlank, vb2, VBlank_SetOptions,
;	ReadJoyData ... ResetZ80Bus ($7A55A-$7A6A9).
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

; fade all colors to black but don't upset palfadenew
forceblack	;IDA: sub_7A02A. Called from most screens
	movem.l	d0/a0,-(sp)
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d0
.0
	move.l	(a0),-(sp)
	clr.l	(a0)+
	dbf	d0,.0
	move.w	#$18,(palcount).w
	bsr.w	forcefade
	moveq	#$1F,d0
.1
	move.l	(sp)+,-(a0)
	dbf	d0,.1
	movem.l	(sp)+,d0/a0
	rts

forceblack2	;$7A054. IDA dc.b, no xref. forceblack with palcount $64 (one step, CopyPaletteToCRAM)
	movem.l	d0/a0,-(sp)
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d0
.loop
	move.l	(a0),-(sp)
	clr.l	(a0)+
	dbf	d0,.loop
	move.w	#$64,(palcount).w
	bsr.w	forcefade
	moveq	#$1F,d0
.loop2
	move.l	(sp)+,-(a0)
	dbf	d0,.loop2
	movem.l	(sp)+,d0/a0
	rts

DecompressBytecode	;$7A07E. IDA dc.b, no caller in 95 (DecompressGraphics skips packed blocks). 93 name. Unpack a0 into the 256 byte ring buffer
	;at ThreeStars (93 DispAttribCtr)
	movea.w	#(ThreeStars-M68K_RAM),a1
	movea.w	#(ThreeStars-M68K_RAM),a3
	movea.w	#(callbackPtr-M68K_RAM),a4
	movea.l	#remap,a5
	movea.l	#DoDMApro,a6
	movem.l	d0-d3/a0-a2,-(sp)
	move.w	d1,d3
	clr.w	d1
	clr.w	d2
.loop
	move.b	(a0)+,d0
	andi.w	#$F0,d0
	lsr.w	#3,d0
	lea	jump_table(pc),a2
	move.w	0(a2,d0.w),d0
	jsr	0(a2,d0.w)
	bra.s	.loop
jump_table	;93 name. DecompressBytecode handler offsets, one per opcode high nibble
	dc.w	Opcode_CopyLiteral-jump_table	;0
	dc.w	Opcode_CopyLiteral-jump_table	;1
	dc.w	Opcode_ClearBytes-jump_table	;2
	dc.w	Opcode_Fillbytes-jump_table	;3
	dc.w	Opcode_CopyBackwardShort-jump_table	;4
	dc.w	Opcode_CopyBackwardShort-jump_table	;5
	dc.w	Opcode_CopyBackwardShort-jump_table	;6
	dc.w	Opcode_CopyBackwardShort-jump_table	;7
	dc.w	Opcode_CopyBackwardMedium-jump_table	;8
	dc.w	Opcode_CopyBackwardLong-jump_table	;9
	dc.w	Opcode_CopyBackwardExtended1-jump_table	;A
	dc.w	Opcode_CopyBackwardExtended2-jump_table	;B
	dc.w	Opcode_CopyBackwardReverseShort-jump_table	;C
	dc.w	Opcode_CopyBackwardReverseShort-jump_table	;D
	dc.w	Opcode_CopyBackwardReverseMedium-jump_table	;E
	dc.w	Opcode_CopyBackwardReverseLong-jump_table	;F
Opcode_CopyLiteral	;93: opcodes 0-1, copy (low 5 bits)+1 bytes from the data
	move.b	-1(a0),d0
	andi.w	#$1F,d0
.loop
	move.b	(a0)+,0(a1,d1.w)
	addq.b	#1,d1
	bne.w	.next
	bsr.w	FlushOutputBuffer
.next
	dbf	d0,.loop
	rts
Opcode_ClearBytes	;93: opcode 2, write (low 4 bits)+1 zero bytes
	move.b	-1(a0),d0
	andi.w	#$F,d0
.loop
	clr.b	0(a1,d1.w)
	addq.b	#1,d1
	bne.w	.next
	bsr.w	FlushOutputBuffer
.next
	dbf	d0,.loop
	rts
Opcode_Fillbytes	;93: opcode 3, write the next data byte (low 4 bits)+3 times
	move.b	-1(a0),d0
	andi.w	#$F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
.loop
	move.b	d2,0(a1,d1.w)
	addq.b	#1,d1
	bne.w	.next
	bsr.w	FlushOutputBuffer
.next
	dbf	d0,.loop
	rts
Opcode_CopyBackwardShort	;93: opcodes 4-7, copy from back in the output buffer
	move.b	-1(a0),d0
	andi.w	#7,d0
	addq.w	#1,d0
	move.b	-1(a0),d2
	lsr.w	#3,d2
	andi.w	#7,d2
	addq.w	#1,d2
CopyBackwardRun	;93: shared copy loop, d0 = count-1, d2 = distance back
	neg.b	d2
	add.b	d1,d2
.loop
	move.b	0(a1,d2.w),0(a1,d1.w)
	addq.b	#1,d2
	addq.b	#1,d1
	bne.w	.next
	bsr.w	FlushOutputBuffer
.next
	dbf	d0,.loop
	rts
Opcode_CopyBackwardMedium	;93: opcode 8
	move.b	-1(a0),d0
	andi.w	#$F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	bra.s	CopyBackwardRun
Opcode_CopyBackwardLong	;93: opcode 9
	move.b	(a0),d0
	asl.b	#1,d0
	move.b	-1(a0),d0
	roxl.b	#1,d0
	andi.w	#$1F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	andi.w	#$7F,d2
	addq.w	#1,d2
	bra.s	CopyBackwardRun
Opcode_CopyBackwardExtended1	;93: opcode A
	move.b	-1(a0),d0
	asl.w	#8,d0
	move.b	(a0),d0
	lsr.w	#6,d0
	andi.w	#$3F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	andi.w	#$3F,d2
	addq.w	#1,d2
	bra.s	CopyBackwardRun
Opcode_CopyBackwardExtended2	;93: opcode B
	move.b	-1(a0),d0
	asl.w	#8,d0
	move.b	(a0),d0
	lsr.w	#5,d0
	andi.w	#$7F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	andi.w	#$1F,d2
	addq.w	#1,d2
	bra.s	CopyBackwardRun
Opcode_CopyBackwardReverseShort	;93: opcodes C-D, copy backwards through the source
	move.b	-1(a0),d0
	andi.w	#3,d0
	addq.w	#1,d0
	move.b	-1(a0),d2
	lsr.w	#2,d2
	andi.w	#7,d2
	addq.w	#1,d2
CopyBackwardReverseRun	;93: shared reverse copy loop
	neg.b	d2
	add.b	d1,d2
.loop
	move.b	0(a1,d2.w),0(a1,d1.w)
	subq.b	#1,d2
	addq.b	#1,d1
	bne.w	.next
	bsr.w	FlushOutputBuffer
.next
	dbf	d0,.loop
	rts
Opcode_CopyBackwardReverseMedium	;93: opcode E. Distance 0 is the end code
	move.b	-1(a0),d0
	andi.w	#$F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	bne.s	CopyBackwardReverseRun
	tst.w	d1
	beq.w	.fin
	bsr.w	FlushOutputBuffer
.fin
	addq.w	#4,sp
	movem.l	(sp)+,d0-d3/a0-a2
	rts
Opcode_CopyBackwardReverseLong	;93: opcode F
	move.b	(a0),d0
	asl.b	#1,d0
	move.b	-1(a0),d0
	roxl.b	#1,d0
	andi.w	#$1F,d0
	addq.w	#2,d0
	move.b	(a0)+,d2
	andi.w	#$7F,d2
	addq.w	#1,d2
	bra.s	CopyBackwardReverseRun
FlushOutputBuffer	;93 name. Write the full ring buffer to vram
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	d1,d0
	bne.w	.size
	move.w	#$100,d0
.size
	lsr.w	#1,d0
	move.w	d3,d1
	add.w	d0,d3
	add.w	d0,d3
	movea.l	a1,a0
	tst.l	(a4)
	beq.w	.dma
	movea.l	(a4),a1
	jsr	(a5)
	bra.w	.done
.dma
	jsr	(a6)
.done
	movem.l	(sp)+,d0-d1/a0-a1
	rts

AddSmallFont	;$7A256. IDA dc.b. 93 name. Jumped to from ReAddSmallFont (video95_03). 95 loads the map at the address in smallfontptr (94: SmallFontMap)
	move.w	d4,(smallfontchars).w
	movea.l	(smallfontptr).w,a2
	addq.w	#8,a2
	bra.w	DoDMA_clearCallbackPointer

DecompressGraphicsWithCallback	;IDA: sub_7A264. 93 name. DecompressGraphics, then return 8 bytes past the call (callback data)
	move.l	(sp),(callbackPtr).w
	bsr.w	DecompressGraphics
	addq.l	#8,(sp)
	rts

; use print x/y/m to set vram address
Framer	;IDA: sub_7A270. Draw a d0 x d1 frame at printx / printy from the framer map. 95 takes the map from framermapptr (94: framermap)
	movem.l	d0-d4/a0-a1,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movem.w	d0-d1,-(sp)
	move.w	(printa).w,d2
	add.w	(framercset).w,d2
	movea.l	(framermapptr).w,a1
	adda.l	4(a1),a1
	addq.w	#4,a1
	clr.w	d4
	bsr.w	.tbline
	subq.w	#3,2(sp)
.mtop
	bsr.w	.tbline
	subq.w	#6,d4
	subq.w	#1,2(sp)
	bpl.s	.mtop
	addq.w	#6,d4
	bsr.w	.tbline
	addq.w	#4,sp
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0-d4/a0-a1
	rts
.tbline	;IDA: sub_7A2BC
	bsr.w	xyVmMap
	addq.w	#1,(printy).w
	bsr.w	.setter
	addq.w	#2,d4
	move.w	4(sp),d0
	subq.w	#3,d0
.tblp
	bsr.w	.setter
	dbf	d0,.tblp
	addq.w	#2,d4
	bsr.w	.setter
	addq.w	#2,d4
	rts
.setter	;IDA: sub_7A2E2
	move.w	(a1,d4.w),d3
	add.w	d2,d3
	move.w	d3,(a0)
	rts

AddFramer	;$7A2EC. IDA dc.b. 93 name. Jumped to from ReAddFramer (video95_03). Load the framer tiles at char d4 through DecompressGraphicsWithCallback with the remap table
	;after the jsr (colour 7 to 1); 95 also stores the map address in framermapptr
	movea.l	#Framermap+8,a2
	move.w	d4,(framercset).w
	move.l	#Framermap,(framermapptr).l
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$61,$89,$AB,$CD,$EF	;remap table: colour n to n, except 7 to 1
	rts

AddFramer2	;IDA: sub_7A310. 95 only. AddFramer for the second framer map, no remap
	movea.l	#Framermap2+8,a2
	move.l	#Framermap2,(framermapptr).l
	move.w	d4,(framercset).w
	jsr	(DoDMA_clearCallbackPointer).l
	rts

VBjsr	;IDA: VBLANK (hockey94). Vertical blank interrupt (vector $78), jumps through the vbint RAM vector
	move.l	(vbint).w,-(sp)	;push handler address
	rts	;and "return" into it

VBlank	;$7A332. IDA dc.b (display94). 93 name; 93 IDA VBlank_org. Main vblank code for game play (vbint target). DumpSprites when dfok is set,
	;cramfade, then the game clock. gmode2 bit 2 keeps the clock running after the whistle, and with gmode2 bit 1 (penalty shot /
	;shootout) shootoutclock counts down instead (shootoutjiffy jiffies, not while gmode2 bit 7 is set)
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#dfng,(disflags).w	;dfng: don't touch the vdp
	bne.w	.nograph
	bclr	#dfok,(disflags).w
	beq.w	.01
	bsr.w	DumpSprites
.01
	bsr.w	cramfade
.nograph
	btst	#sfpz,(sflags).w
	bne.w	.c
	btst	#2,(gmode2).w
	bne.w	.0
	btst	#0,(gmode).w	;gmclock: game clock stopped
	bne.w	.c
.0
	btst	#1,(gmode2).w	;penalty shot / shootout clock
	bne.w	.1
	tst.w	(gameclock).w
	beq.w	.c
	subi.w	#$AAA,(gameclock+2).w	;jiffy ($10000/24)
	bcc.w	.c
	bset	#dfclock,(disflags).w
	subq.w	#1,(gameclock).w
	cmpi.w	#$3D,(gameclock).w	;61
	bgt.w	.c
	cmpi.w	#$3C,(gameclock).w	;60
	blt.w	.c
	move.w	#2,-(sp)	;SFXbeep2, played when gameclock reaches 60
	jsr	(sfx).l	;95: jsr (94: bsr.w)
.c
	addq.w	#1,(vcount).w	;92 Vcount
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte
.1
	tst.w	(shootoutclock).w
	beq.s	.c
	subi.w	#$AAA,(shootoutjiffy).w
	bcc.s	.c
	bset	#dfclock,(disflags).w
	btst	#7,(gmode2).w
	bne.s	.c
	subq.w	#1,(shootoutclock).w
	bra.s	.c

p_music_vblank	;$7A3E6. 92 name (sound94). Read the pads (ReadJoyData), then SoundCmd 1: the 95 sound driver's vblank update. Called from the
	;vblank handlers
	bsr.w	ReadJoyData
	move.w	#1,d0
	jsr	(SoundCmd).l
	rts

vb2	;$7A3F6. IDA dc.b (display94). 93 name. Vblank used for palfades only, no dmas (vbint target). No rte here: falls into IRQ7
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#dfng,(disflags).w
	bne.w	.nograph
	bsr.w	cramfade
.nograph
	addq.w	#1,(vcount).w
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
IRQ7	;rte only. vb2 falls in; the vector table ($60, $64, ...) points here
	rte

VBlank_SetOptions	;$7A418. IDA dc.b (attract94; 93 hockey93_08 name). vbint handler stored by the menus: 92 vb2 (cramfade unless dfng), plus
	;DumpSprites2 when dfok is set
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#dfng,(disflags).w
	bne.w	.nograph
	bclr	#dfok,(disflags).w
	beq.w	.fade
	bsr.w	DumpSprites2
.fade
	bsr.w	cramfade
.nograph
	addq.w	#1,(vcount).w
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte

; return d1 = new button presses
orjoy	;IDA: sub_7A448. Pads 1 and 2 (95: no four way case here, see orjoy4way)
	bsr.w	ReadJoy1
	move.w	d1,-(sp)
	bsr.w	ReadJoy2
	or.w	(sp)+,d1
	rts

orjoy4way	;IDA: loc_7A456. 95 only. orjoy for pads 1-4 (3 and 4 with FourWayPlay), d1 new presses and d3 held buttons of all pads.
	;Jumped to from ReadMenuJoy
	bsr.w	ReadJoy1
	move.w	d1,-(sp)
	move.w	d3,-(sp)
	bsr.w	ReadJoy2
	or.w	(sp)+,d3
	or.w	(sp)+,d1
	tst.w	(FourWayPlay).w
	beq.w	.x
	move.w	d1,-(sp)
	move.w	d3,-(sp)
	bsr.w	ReadJoy3
	or.w	(sp)+,d3
	or.w	(sp)+,d1
	move.w	d1,-(sp)
	move.w	d3,-(sp)
	bsr.w	ReadJoy4
	or.w	(sp)+,d3
	or.w	(sp)+,d1
.x
	rts

; eliminate diagonal direction presses on d0
nodiag	;IDA: sub_7A488
	movem.l	d0/d4-d5,-(sp)
	moveq	#3,d4
	move.w	d3,d0
	andi.w	#$F,d0
	beq.w	.ok
.0
	clr.w	d5
	bset	d4,d5
	cmp.w	d5,d0
	dbeq	d4,.0
	beq.w	.ok
	andi.w	#$FFF0,d1
.ok
	movem.l	(sp)+,d0/d4-d5
	rts

; Read controller 1
; return d0 = direction (bit 0-3) and new button (bit 4-7) presses
; d1 = new presses (all 8 bits)
; d2 = changed buttons (all 8)
; d3 = current held buttons (all 8)
ReadJoy1	;IDA: sub_7A4B0
	move.b	(pad4way1).w,d0
	bsr.w	ReadJoy
	move.w	(lj1).w,d2
	move.w	d1,(lj1).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts
; Read controller 2
ReadJoy2	;IDA: sub_7A4C8
	move.b	(pad4way2).w,d0
	bsr.w	ReadJoy
	move.w	(lj2).w,d2
	move.w	d1,(lj2).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts
ReadJoy3	;IDA: sub_7A4E0. 95: nothing pressed (NoJoy) without FourWayPlay
	tst.w	(FourWayPlay).w
	beq.w	NoJoy
	move.b	(pad4way3).w,d0
	bsr.w	ReadJoy
	move.w	(lj3).w,d2
	move.w	d1,(lj3).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts
NoJoy	;IDA: loc_7A500. 95 only. No buttons, direction 8 (none)
	clr.w	d1
	clr.w	d2
	clr.w	d3
	move.w	#8,d0
	rts
ReadJoy4	;IDA: sub_7A50C. 95: NoJoy without FourWayPlay
	tst.w	(FourWayPlay).w
	beq.s	NoJoy
	move.b	(pad4way4).w,d0
	bsr.w	ReadJoy
	move.w	(lj4).w,d2
	move.w	d1,(lj4).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts
ReadJoy	;IDA: sub_7A52A. d0 = pad byte: buttons to the high nibble, direction 0-8 (jdtab) in the low nibble, d1 = the buttons
	not.b	d0
	clr.w	d1
	move.b	d0,d1
	move.w	d1,-(sp)
	andi.w	#$F0,d0
	andi.w	#$F,d1
	movea.l	#jdtab,a0
	move.b	(a0,d1.w),d1
	or.w	d1,d0
	move.w	(sp)+,d1
	rts
jdtab	dc.b	8
	;convert button l,r,d,u into directions 0-7,8
	dc.b	0,4,8,6,7,5,8,2,1,3,8,8,8,8,8

ReadJoyData	;$7A55A. IDA dc.b (sound94). Read the pads every vblank (p_music_vblank). With FourWayPlay, pads 1-4 through the 4 way adaptor
	;(ReadPad4Way1 ... ReadPad4Way4) to pad4way1-pad4way4, else pads 1 and 2 (ReadPad1, ReadPad2)
	movem.l	d1/a0,-(sp)
	tst.w	(FourWayPlay).w
	beq.w	.0
	bsr.s	ReadPad4Way1
	move.b	d0,(pad4way1).w
	bsr.s	ReadPad4Way2
	move.b	d0,(pad4way2).w
	bsr.w	ReadPad4Way3
	move.b	d0,(pad4way3).w
	bsr.w	ReadPad4Way4
	move.b	d0,(pad4way4).w
	bra.w	.x
.0
	bsr.w	ReadPad1
	move.b	d0,(pad4way1).w
	bsr.w	ReadPad2
	move.b	d0,(pad4way2).w
.x
	movem.l	(sp)+,d1/a0
	rts
ReadPad4Way1	;4 way play pad 1: pause the sound driver (SoundCmd $D; 94 took the Z80 bus), select pad 1 on port 2 and read it on port 1
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.b	#$C,(IO_CT2_DATA+1).l
	bra.w	ReadPad4WayPort1
ReadPad4Way2	;4 way play pad 2, as ReadPad4Way1
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.b	#$1C,(IO_CT2_DATA+1).l
	bra.w	ReadPad4WayPort1
ReadPad4Way3	;4 way play pad 3, as ReadPad4Way1
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.b	#$2C,(IO_CT2_DATA+1).l
	bra.w	ReadPad4WayPort1
ReadPad4Way4	;4 way play pad 4, as ReadPad4Way1. Falls into ReadPad4WayPort1
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.b	#$3C,(IO_CT2_DATA+1).l
ReadPad4WayPort1	;Read the pad on port 1; branched to from ReadPad4Way1 ... ReadPad4Way4
	movem.l	d1/a0,-(sp)
	lea	(IO_CT1_DATA+1).l,a0
	bra.w	ReadPad3Button
ReadPad2	;Read pad 2 (port 2). Falls into ReadPadA0
	movem.l	d1/a0,-(sp)
	lea	(IO_CT2_DATA+1).l,a0
	bra.s	ReadPadA0
ReadPad1	;Read pad 1 (port 1)
	movem.l	d1/a0,-(sp)
	lea	(IO_CT1_DATA+1).l,a0
ReadPadA0	;Pause the sound driver (SoundCmd $D; 94 took the Z80 bus), then ReadPad3Button
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
ReadPad3Button	;Read a 3 button pad at a0 (TH low, then high), resume the sound driver (SoundCmd $E) and return d0 = the buttons, the directions
	;through PadDirTable
	moveq	#0,d0
	move.b	#0,(a0)
	nop
	nop
	move.b	(a0),d0
	move.b	#$40,(a0)
	nop
	nop
	move.b	(a0),d1
	move.w	d0,-(sp)	;95: resume the sound driver where 94 released the Z80 bus
	move.w	#$E,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	asl.b	#2,d0
	andi.b	#$C0,d0
	andi.b	#$3F,d1
	or.b	d1,d0
	not.b	d0
	not.b	d1
	andi.w	#$F,d1
	lea	PadDirTable(pc),a0
	andi.b	#$F0,d0
	or.b	0(a0,d1.w),d0
	not.b	d0
	movem.l	(sp)+,d1/a0
	rts
PadDirTable	;Direction nibble table for ReadPad3Button: remaps the nibble when opposite directions are pressed together
	dc.b	0,1,2,1,4,5,6,6,8,9,$A,$A,8,9,$A,0
ResetZ80Bus	;Reset the Z80 and wait for its bus. No caller in 95
	move.w	#$100,(IO_Z80RES).l
	move.w	#$100,(IO_Z80BUS).l
.loop
	btst	#0,(IO_Z80BUS).l
	bne.s	.loop
	rts

ReadMenuJoy	;IDA: sub_7A6AA. 95 only. Read the menu pad: with sflags12 bit 0 clear, pad menupadnum (ReadJoy1-4). Else, with no pad on a team,
	;all pads (orjoy4way); otherwise the first pad on a team that has buttons down becomes menupadnum
	btst	#0,(sflags12).w
	bne.w	.any
	tst.w	(menupadnum).w
	beq.w	ReadJoy1
	cmpi.w	#1,(menupadnum).w
	beq.w	ReadJoy2
	cmpi.w	#2,(menupadnum).w
	beq.w	ReadJoy3
	bra.w	ReadJoy4
.any
	move.w	(cont1team).w,d0
	or.w	(cont2team).w,d0
	or.w	(cont3team).w,d0
	or.w	(cont4team).w,d0
	beq.w	.all
	clr.w	(menupadnum).w
	tst.w	(cont1team).w
	beq.w	.2
	bsr.w	ReadJoy1
	tst.b	d3
	bne.w	.x
	tst.b	d1
	bne.w	.x
.2
	tst.w	(cont2team).w
	beq.w	.3
	move.w	#1,(menupadnum).w
	bsr.w	ReadJoy2
	tst.b	d3
	bne.w	.x
	tst.b	d1
	bne.w	.x
.3
	tst.w	(FourWayPlay).w
	beq.w	.x
	tst.w	(cont3team).w
	beq.w	.4
	move.w	#2,(menupadnum).w
	bsr.w	ReadJoy3
	tst.b	d3
	bne.w	.x
	tst.b	d1
	bne.w	.x
.4
	tst.w	(cont4team).w
	beq.w	.x
	move.w	#3,(menupadnum).w
	bsr.w	ReadJoy4
.x
	rts
.all
	jmp	(orjoy4way).l
