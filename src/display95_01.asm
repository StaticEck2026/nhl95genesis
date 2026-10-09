; $00A204  Adapted from display94.asm: vblank, clock, crowd, rink scroll
;	NHL 95 segment $A204-$A535, from lst/nhl95.bin.lst. 94 setvideo, checksso, setsortcords, setffo, uppads, FormatControllerDisplay,
;	RenderSmallFontChar and ButtonLabelCharTable (display94). updateanim (replay94) follows at $A536 (replay95_01).
;	95 has 6 pad objects and no glove object (94: 7 with glovestruct), and keeps the pad nibbles in one long (PadControlBits).

setvideo	;IDA: sub_A204. this is not vblank code but sets up ram for vblank transfers. Called once per game frame (DoGameFrame, Pausemode, ...).
	;95 has no showzam, AddArenaAnimSprite or Crowd_Noise here, and no clock while paused
	movem.l	d0-d7/a0-a6,-(sp)
.p
	btst	#dfok,(disflags).w	;dfok: wait for vblank to take the last frame
	bne.s	.p
	movea.w	#(DMAList-M68K_RAM),a5	;dma transfer list
	jsr	(updatescroll).l
	movea.w	#(Satt-M68K_RAM),a6	;sprite attribute table area
	moveq	#1,d6	;link counter
	jsr	(checkfo).l
	bsr.w	checksso
	bsr.w	setsortcords
	bsr.w	setffo
	btst	#sfpz,(sflags).w	;95: no clock while paused
	bne.w	.0
	jsr	(showclock).l
.0
	jsr	(showcrowd).l
	jsr	(showref).l
	cmpa.w	#(Satt-M68K_RAM),a6	;no sprites: one blank sprite
	bne.w	.n
	clr.l	(a6)+
	clr.l	(a6)+
.n
	clr.b	-5(a6)	;end sprite list
	move.l	a6,d0
	subi.l	#Satt,d0
	lsr.w	#1,d0	;words
	move.w	d0,(Sattsize).w	;93 Sattsize
	move.l	a5,(DMAlistend).w
	bset	#dfok,(disflags).w	;dfok
	movem.l	(sp)+,d0-d7/a0-a6
	rts

setsortcords	;IDA: sub_A27C. setup sort cord graphics: addframe for the 16 objects in OOlist order. a5 = dmalist, a6 = sprite attribute table,
	;d6 = link counter
	movea.w	#(OOlist-M68K_RAM),a4	;move OOlist into a4
	move.w	#$F,d0	;sortobj-1 (15 dec)
.top
	clr.w	d1
	move.b	(a4)+,d1	;move next sortcord into d1
	asl.w	#6,d1	;mult by 64
	movea.w	#(SortCords-M68K_RAM),a3	;Sort Cord struct start into a3
	adda.w	d1,a3	;add offset to next struct
	jsr	(addframe).l
	dbf	d0,.top	;loop until done
rtssdisp	;IDA: locret_A29A. checksso .ca branches here (94: rtss2)
	rts

checksso	;IDA: sub_A29C. do graphics for sso structure: arrows for the players when they are off screen. Called from setvideo. a5 = dma list,
	;a6 = sprite table, d6 = link counter. Returns on the horizontal rink. Pads 3 and 4 when cont3team / cont4team. Falls into .ca for the last one
	btst	#sfhor,(sflags).w
	bne.w	.x
	movea.w	#(Joy1Struct-M68K_RAM),a0
	movea.w	#(sso-M68K_RAM),a3
	move.w	#$69,d3	;first arrow frame (94: $180, SPFarrow)
	bsr.w	.ca
	adda.w	#$1C,a0	;ffosize
	adda.w	#$14,a3	;ssosize
	move.w	#$6C,d3
	bsr.w	.ca
	tst.w	(cont3team).w
	beq.w	.x	;on screen: no arrow
	movea.w	#(Joy3Struct-M68K_RAM),a0
	adda.w	#$14,a3
	move.w	#$73,d3
	bsr.w	.ca
	tst.w	(cont4team).w
	beq.w	.x
	movea.w	#(Joy4Struct-M68K_RAM),a0
	adda.w	#$14,a3
	move.w	#$76,d3
.ca	;IDA: sub_A2F2 (93 .ca). a0 = object, a3 = sso, d3 = first arrow frame. In a shootout, with sflags2 bit 3 or in a penalty shot, no arrow
	;for a player beyond x $B6 (94: $A6). 95 has no horizontal rink case here
	tst.w	Zpos(a0)
	bmi.w	.x	;not on the ice
	st	frame(a3)
	move.w	(a0),d0
	btst	#0,(gmode2).w
	bne.w	.0
	btst	#3,(sflags2).w
	bne.w	.0
	btst	#2,(BA_PS_flags).w
	beq.w	.7
.0
	move.w	d0,-(sp)
	tst.w	d0
	bpl.w	.2
	neg.w	d0
.2
	cmp.w	#$B6,d0
	blt.w	.6
	move.w	(sp)+,d0
.x
	rts
.6
	move.w	(sp)+,d0
.7
	move.w	Ypos(a0),d1
	sub.w	(Hpos).w,d0
	sub.w	(Vpos).w,d1
	clr.w	d2
	cmp.w	#$74,d0	;.xoff = 116
	blt.w	.8
	bset	#3,d2
.8
	cmp.w	#$FF8C,d0	;-.xoff
	bgt.w	.1
	bset	#2,d2
.1
	cmp.w	#$64,d1	;.yoff = 100
	blt.w	.9
	bset	#0,d2
.9
	cmp.w	#$FF9C,d1	;-.yoff
	bgt.w	.3
	bset	#1,d2
.3
	tst.w	d2
	beq.w	rtssdisp
	movea.l	#jdtab,a1
	move.b	(a1,d2.w),d2
	asl.w	#3,d2
	movea.l	#.tab,a1
	move.w	(a1,d2.w),d4
	beq.w	.4
	move.w	d4,d0
.4
	addi.w	#$100,d0	;128+128
	move.w	d0,(a3)
	move.w	2(a1,d2.w),d4
	beq.w	.5
	move.w	d4,d1
.5
	neg.w	d1
	addi.w	#$F0,d1	;112+128
	move.w	d1,2(a3)
	add.w	4(a1,d2.w),d3
	move.w	d3,frame(a3)
	move.w	6(a1,d2.w),attribute(a3)
	jmp	(addframe2).l	;94: bra.w
.tab	;$A3C4. 93 .tab. x spot, y spot, frame add, attribute per direction
	dc.w	0,$64,0,$0000
	dc.w	$74,$64,1,$0000
	dc.w	$74,0,2,$0000
	dc.w	$74,-$64,1,$1000
	dc.w	0,-$64,0,$1000
	dc.w	-$74,-$64,1,$1800
	dc.w	-$74,0,2,$0800
	dc.w	-$74,$64,1,$0800

setffo	;IDA: sub_A404. draw the 6 objects tied to icerink scrolling (the pads; 94: 7 with the gloves), moving each by its x offset. Called from setvideo
	bsr.w	uppads
	move.w	#5,d0	;ffo obj -1 (94: 6)
	movea.w	#(pads-M68K_RAM),a3	;move start of struct into a3
.top
	movea.w	a6,a0
	jsr	(addframe).l
	cmpa.w	a6,a0
	beq.w	.next
	move.w	2(a3),d1
	add.w	d1,6(a0)
	add.w	d1,$E(a0)
.next
	adda.w	#$1C,a3	;move to next struct
	dbf	d0,.top
	rts

uppads	;IDA: sub_A434. update the 6 pad objects and queue new pad labels (FormatControllerDisplay). The pad players come from the
	;PadControlBits nibbles ($E = no change, $F = none). 95 has no glove object and takes all 6 nibbles from one long (94: PadControlBits34 too)
	move.w	#5,d4
	movea.w	#(pads-M68K_RAM),a0
	movea.w	#(padcont-M68K_RAM),a1
	movea.w	#(SortCords-M68K_RAM),a2
	move.l	(PadControlBits).w,d3
.nibble
	move.w	d3,d0
	andi.w	#$F,d0
	move.w	#$F,d1
	cmp.w	#$E,d0
	beq.w	.chg
	st	Zpos(a0)
	cmp.w	#$F,d0
	beq.w	.next
	asl.w	#7,d0
	move.w	(a2,d0.w),(a0)
	move.w	Ypos(a2,d0.w),Ypos(a0)
	clr.w	Zpos(a0)
	move.b	$35(a2,d0.w),d1	;position+1
	asl.w	#8,d1
	move.b	$6F(a2,d0.w),d1	;rostnum
.chg
	cmp.w	(a1),d1
	beq.w	.next
	move.w	d1,(a1)
	bsr.w	FormatControllerDisplay
.next
	lsr.l	#4,d3
	adda.w	#$1C,a0
	addq.w	#2,a1
	dbf	d4,.nibble
	rts

FormatControllerDisplay	;IDA: sub_A49A. 93 name. Queue the 3 character label of a pad object. d1 = label code: bits 7-4 and 3-0 are digits ($F =
	;blank), bits 10-8 index ButtonLabelCharTable (none while sflags7 bit 7 is set). a0 = pad object, a5 = dma list. Falls into
	;RenderSmallFontChar for the last char
	lea	ButtonLabelCharTable(pc),a4
	clr.w	2(a0)	;x offset (setffo adds it to the sprites)
	move.w	d1,d2
	lsr.w	#4,d2
	andi.w	#$F,d2
	bne.w	.hi
	move.w	#$FFF0,d2	;' '-'0': blank leading zero
	subq.w	#4,2(a0)
.hi
	addi.w	#$30,d2
	clr.w	d0
	bsr.w	RenderSmallFontChar
	move.w	d1,d2
	andi.w	#$F,d2
	cmp.w	#$F,d2
	bne.w	.lo
	move.w	#$FFF0,d2	;$F: blank
.lo
	addi.w	#$30,d2
	moveq	#1,d0
	bsr.w	RenderSmallFontChar
	move.w	d1,d2
	btst	#7,(sflags7).w
	beq.w	.0
	clr.w	d2
.0
	lsr.w	#8,d2
	andi.w	#7,d2
	bne.w	.1
	addq.w	#4,2(a0)
.1
	move.b	(a4,d2.w),d2
	moveq	#2,d0

RenderSmallFontChar	;IDA: sub_A4FE. 93 name. Dma one small font tile (SmallFontMap) to the object's chars. d2 = ascii char, d0 = char slot,
	;a0 = object (VRchar), a5 = dma list
	movea.l	#SmallFontMap,a3
	adda.l	4(a3),a3
	add.w	d2,d2
	move.w	4(a3,d2.w),d2
	andi.w	#$7FF,d2
	asl.w	#5,d2	;32 bytes per tile
	movea.l	#SmallFontMap,a3
	lea	$A(a3,d2.w),a3
	move.l	a3,(a5)+
	move.w	#$10,(a5)+	;words to transfer
	add.w	VRchar(a0),d0
	asl.w	#5,d0
	move.w	d0,(a5)+
	rts

ButtonLabelCharTable	;IDA: unk_A52E. 93 name. Third label character by bits 10-8 of the label code
	dc.b	' DDLCRX',$FF	;pad byte $FF as 94
