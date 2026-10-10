;	NHL 95 input95_02. Retail $08A056-$08A3FD (936 bytes).
;	94 input94 SetLCmode, SetLCmode2, setlccords, getlchoice, getlchoice2, lineinput, lcfound, lcfound2, with penalty94 linebar,
;	getlinee and AvgCline moved in. checks95_05 follows at $08A3FE (CompLine).
;	IDA code except AvgCline (dc.b, read from the retail bytes). IDA hid a printz String as instructions; it is String here. Local labels
;	are numbered; the IDA local names are not kept.
;	95 changes: the team struct offsets, the zero long at $69A (94 $30A).
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


SetLCmode	;IDA: loc_8A056 (input94) Open the line change box for team of player a3 (loadTeamStruct): not with line changes off (OptLine) or
	;sflags7 bit 4, once (tmflags bit 1); sets pflags2 bit 3 (line change mode) and falls into SetLCmode2
	tst.w	(OptLine).w
	bne.w	rtslc
	btst	#4,(sflags7).w
	bne.w	rtslc
	jsr	(loadTeamStruct).l
	bset	#1,tmflags(a2)
	bne.w	rtslc
	btst	#3,(sflags5).w
	bne.w	.0
	bclr	#2,(sflags).w
.0
	bclr	#3,(sflags).w
	bset	#3,pflags2(a3)

SetLCmode2	;IDA: sub_8A094 (input94) 93 name. a2 = team struct. Draw the line change box (box, Framer) with the line names (linelist) and their
	;energy bars (linebar)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	setlccords
	cmpi.w	#$F,(printy).w
	blt.w	.0
	bset	#0,(sflags3).w
	bra.w	.1
.0
	jsr	(box).l
	bsr.w	setlccords
.1
	jsr	(Framer).l
	subq.w	#2,(printy).w
	addq.w	#1,(printx).w
	moveq	#2,d4
.2
	move.w	d4,d0
	bsr.w	getlchoice
	tst.w	d0
	bmi.w	.5
	btst	#1,tmflags(a2)
	bne.w	.3
	cmp.w	$2E(a2),d4
	bne.w	.4
	move.w	tmline(a2),d0
.3
	movea.w	#(mesarea-M68K_RAM),a1
	move.l	#$44120,(a1)	;String length 4, 'A ' (94 the same)
	add.b	d4,2(a1)
	jsr	(print).l
	move.w	d0,-(sp)
	movea.l	#linelist,a1
	jsr	(PrintSmallListItem).l
	move.w	(sp)+,d0
	bsr.w	linebar
	subq.w	#5,(printx).w
.4
	subq.w	#1,(printy).w
.5
	dbf	d4,.2
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	addq.w	#2,(printx).w
	jsr	(print).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

setlccords	;IDA: sub_8A13A (input94) Set printx / printy for the line change box of team a2
	clr.w	d0
	cmpa.w	#$C288,a2
	bne.w	.0
	eori.w	#$16,d0
.0
	btst	#1,(gmode).w
	beq.w	.1
	eori.w	#$16,d0
.1
	jsr	(printz).l
	String	$BF,$16,0,0
	add.w	d0,(printy).w
	moveq	#2,d0
	bsr.w	getlchoice
	moveq	#6,d1
	tst.w	d0
	bpl.w	.2
	subq.w	#1,d1
	addq.w	#1,(printy).w
.2
	moveq	#9,d0
	rts

getlchoice	;IDA: sub_8A17E (input94) d0 = the line for button d0 of team a2 (getlchoice2)
	movem.l	d1-d2,-(sp)
	move.w	$38A(a2),d2
	cmpa.w	#$C288,a2
	beq.w	getlchoice2
	move.w	-$342(a2),d2

getlchoice2	;IDA: loc_8A192 (input94) The line for choice d0 by the player difference (tmap of the two teams) and the current line (tmline); .tab
	sub.w	tmap(a2),d2
	beq.w	.0
	addi.w	#$15,d0
	tst.w	d2
	bmi.w	.0
	addi.w	#$15,d0
.0
	move.w	tmline(a2),d1
	add.w	d1,d0
	add.w	d1,d0
	add.w	d1,d0
	lea	.1(pc),a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	movem.l	(sp)+,d1-d2
	rts
.1
	dc.b	0,1,2,1,2,0,2,0,1,0,1,2,0,1,2,0
	dc.b	1,2,0,1,2,3,4,$FF,3,4,$FF,3,4,$FF,3,4
	dc.b	$FF,4,3,$FF,3,4,$FF,3,4,$FF,5,6,$FF,5,6,$FF
	dc.b	5,6,$FF,5,6,$FF,5,6,$FF,5,6,$FF,6,5,$FF,$FF

lineinput	;IDA: loc_8A202 (input94) Process input for line changes: d1 = new button presses (passmode first with sflags5 bit 3)
	movem.l	d1-d3/a0,-(sp)
	movea.l	#$FFFFBF14,a0
	btst	#6,d2
	bne.w	.0
	btst	#6,d3
	bne.w	.0
	clr.w	(a0,d4.w)
.0
	movea.w	#(HmShots-M68K_RAM),a2
	btst	#6,pflags(a3)
	beq.w	.1
	adda.w	#tmsize,a2
.1
	bclr	#0,tmflags(a2)
	beq.w	.2
	bsr.w	lcfound2
	bsr.w	SetLCmode2
.2
	movem.l	(sp)+,d1-d3/a0
	move.w	d2,(rosterteam).w
	clr.w	d2
	movem.l	a0,-(sp)
	movea.l	#$FFFFBF14,a0
	tst.w	(a0,d4.w)
	movem.l	(sp)+,a0
	bne.w	.3
	btst	#6,(rosterteam+1).w
	beq.w	.3
	btst	#6,d3
	bne.w	.3
	bra.w	lcfound
.3
	addq.w	#1,d2
	btst	#4,(rosterteam+1).w
	beq.w	.4
	btst	#4,d3
	bne.w	.4
	bra.w	lcfound
.4
	addq.w	#1,d2
	btst	#5,(rosterteam+1).w
	beq.w	.5
	btst	#5,d3
	bne.w	.5
	bra.w	lcfound
.5
	btst	#3,pflags(a3)
	beq.w	.6
	btst	#5,pflags(a3)
	bne.w	.6
	btst	#0,pflags2(a3)
	beq.w	doplayeracc
.6
	rts

lcfound	;IDA: loc_8A2CA (input94) Line d2 was picked: store it ($2E), set tmline (getlchoice) and the players (SetPersonel); falls into lcfound2
	move.w	d2,d0
	move.w	d2,$2E(a2)
	bsr.w	getlchoice
	tst.w	d0
	bmi.w	rtslc
	bclr	#3,pflags2(a3)
	bset	#3,pflags(a3)
	jsr	(loadTeamStruct).l
	bclr	#1,tmflags(a2)
	move.w	d0,tmline(a2)
	jsr	(SetPersonel).l

lcfound2	;IDA: sub_8A2FC (input94) Erase the line change box (eraser) and redraw the scores (PrintScores1)
	btst	#7,(sflags).w
	bne.w	rtslc
	bsr.w	setlccords
	bsr.w	setlccords
	cmpi.w	#$F,(printy).w
	blt.w	.0
	bclr	#0,(sflags3).w
.0
	addq.w	#1,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jmp	PrintScores1

rtslc	;IDA: locret_8A330. The shared rts of the line change routines (94 rtss2)
	rts

linebar	;IDA: sub_8A332 (penalty94) 93 name. Draw the energy bar of line d0 for team a2 at printx / printy (EnergyBarMap, 16 steps)
	movem.l	d0-d5/a0-a2,-(sp)
	bsr.w	getlinee
	move.w	(printa).w,-(sp)
	move.w	#$8000,(printa).w
	ext.l	d0
	divu.w	#$100,d0
	cmp.w	#$F,d0
	bls.w	.0
	moveq	#$F,d0
.0
	moveq	#$F,d1
	sub.w	d0,d1
	clr.w	d0
	movea.l	#EnergyBarMap,a1
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	moveq	#1,d3
	move.w	(energybarchars).w,d4
	moveq	#0,d5
	jsr	(dobitmap).l
	move.w	(sp)+,(printa).w
	movem.l	(sp)+,d0-d5/a0-a2
	rts

getlinee	;IDA: sub_8A382 (penalty94) d0 = line number, a2 = team struct. Return d0 = energy level of this line
	movem.l	d1-d5/a0-a3,-(sp)
	lea	$16C(a2),a1
	asl.w	#3,d0
	adda.w	d0,a1
	clr.l	d0
	clr.w	d1
	movea.l	#priolist,a0
	move.w	tmap(a2),d4
	bra.w	.1
.0
	clr.w	d5
	move.b	(a0,d4.w),d5
	beq.w	.1
	clr.w	d3
	move.b	(a1,d5.w),d3
	asl.w	#1,d3
	addq.w	#1,d1
	add.w	$32(a2,d3.w),d0
.1
	dbf	d4,.0
	divu.w	d1,d0
	movem.l	(sp)+,d1-d5/a0-a3
	rts

AvgCline	;IDA dc.b (penalty94) 93 name. Return d0 = average energy of the current line on team a2
	movem.l	d1-d3/a0,-(sp)
	clr.l	d0
	clr.w	d1
	moveq	#5,d2
	movea.w	tmsort(a2),a0
.0
	tst.w	position(a0)
	ble.w	.1
	clr.w	d3
	move.b	pnum(a0),d3
	add.w	d3,d3
	add.w	tmpde(a2,d3.w),d0
	addq.w	#1,d1
.1
	adda.w	#SCstruct,a0
	dbf	d2,.0
	tst.w	d1
	beq.w	.2
	divu.w	d1,d0
.2
	movem.l	(sp)+,d1-d3/a0
	rts

