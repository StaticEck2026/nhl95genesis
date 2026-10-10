;	NHL 95 penalty95. Retail $088F06-$08996D (2664 bytes).
;	94 penalty94 limitfo, Stop4Pen, AddPenalty ... checkfornewpen, UpdatePA, SetPA, SetPA2, PushRef, prefmes, PrintPenaltyMessagesString,
;	with title94 LeadSong / ClearLeadSong / LeadSongExit moved in. data95_02 follows at $08996E.
;	IDA code except LeadSong ... LeadSongExit and PrintPenaltyMessagesString (dc.b, read from the retail bytes). IDA hid the printz
;	Strings as instructions; they are String here. Local labels are numbered; the IDA local names are not kept. Each routine comment
;	names its 94 file.
;	95 changes: the team struct offsets (tmpdst $68, the penalty box list $9C), the RAM moved (RefRamMap $DBBE), the 95 sounds.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


limitfo	;IDA: sub_88F06 (penalty94) Limit the faceoff spot to 5-20 feet from the walls of the rink, for every player in PenBuf (.1 is 93 .lf, IDA sub_88F1E).
	;95: the blue line is $56 (94 $58)
	movem.l	d0-d1/a0-a1,-(sp)
	movea.w	#(PenBuf-M68K_RAM),a0
.0
	bsr.w	.1
	addq.w	#2,a0
	tst.w	(a0)
	bne.s	.0
	movem.l	(sp)+,d0-d1/a0-a1
	rts
.1
	move.b	1(a0),d0
	andi.w	#$7F,d0
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a1
	move.w	#$56,d1
	btst	#7,$62(a1,d0.w)
	bne.w	.2
	neg.w	d1
	cmp.w	(foy).w,d1
	blt.w	.5
	move.w	#$FFBF,(foy).w
	bra.w	.3
.2
	cmp.w	(foy).w,d1
	bgt.w	.5
	move.w	#$41,(foy).w
.3
	move.w	#$46,d0
	tst.w	(fox).w
	bpl.w	.4
	neg.w	d0
.4
	move.w	d0,(fox).w
.5
	rts

LeadSong	;IDA dc.b (title94) Not in a shootout (gmode2 bit 1) and one team has more players on ice (tmap): once (sflags2 bit 5) ChooseSong
	;with SongIndex 1 (home) or 4, and sflags8 bit 6; sflags2 bit 6 keeps which team. sflags2 is put back on exit. Called from puckfaceoff2
	movem.l	d0/a0-a3,-(sp)
	move.w	(sflags2).w,-(sp)
	btst	#1,(gmode2).w
	bne.w	LeadSongExit
	movea.w	#(HmShots-M68K_RAM),a2
	lea	tmsize(a2),a3
	move.w	tmap(a2),d0
	sub.w	tmap(a3),d0
	beq.w	LeadSongExit
	bpl.w	.0
	btst	#6,(sflags2).w
	bne.w	.1
	bsr.w	ClearLeadSong
	bset	#6,(sflags2).w
	bra.w	.1
.0
	exg	a2,a3
	btst	#6,(sflags2).w
	beq.w	.1
	bsr.w	ClearLeadSong
	bclr	#6,(sflags2).w
.1
	bset	#5,(sflags2).w
	bne.w	LeadSongExit
	cmpa.w	#$C288,a3
	bne.w	.3
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#1,(SongIndex).w
	jsr	(ChooseSong).l
.2
	bset	#6,(sflags8).w
	bra.w	LeadSongExit
.3
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#4,(SongIndex).w
	jsr	(ChooseSong).l
	bra.s	.2

ClearLeadSong	;IDA dc.b (title94) Clear sflags2 bit 5
	bclr	#5,(sflags2).w
	rts

LeadSongExit	;IDA dc.b (title94) LeadSong exit
	move.w	(sp)+,(sflags2).w
	movem.l	(sp)+,d0/a0-a3
	rts

Stop4Pen	;IDA: sub_8901C (penalty94) a0 = PenaltyNames penalty + 2. Stop the clock, set the faceoff spot from the penalty type, blow the whistle
	;and start the ref (SetPA)
	bset	#0,(gmode).w
	bne.w	.5
	clr.w	d0
	clr.w	d1
	cmpi.b	#$E,-2(a0)
	beq.w	.0
	move.w	(ltx).w,d0
	move.w	(lty).w,d1
	cmpi.b	#6,-2(a0)
	beq.w	.0
	move.w	(puckx).w,d0
	move.w	(pucky).w,d1
	cmpi.b	#$C,-2(a0)
	bne.w	.0
	move.l	a3,-(sp)
	movea.w	#(SortCords-M68K_RAM),a3
	move.b	-1(a0),d1
	ext.w	d1
	asl.w	#7,d1
	adda.w	d1,a3
	move.w	#$258,d1
	btst	#7,$62(a3)
	movea.l	(sp)+,a3
	beq.w	.0
	neg.w	d1
.0
	movem.w	d0-d1,-(sp)
	cmp.w	#$4D,d0
	blt.w	.1
	move.w	#$4D,d0
.1
	cmp.w	#$FFB3,d0
	bgt.w	.2
	move.w	#$FFB3,d0
.2
	cmp.w	#$AF,d1
	blt.w	.3
	move.w	#$D7,d1
	move.w	#$4D,d0
	tst.w	(sp)
	bpl.w	.3
	neg.w	d0
.3
	cmp.w	#$FF51,d1
	bgt.w	.4
	move.w	#$FF29,d1
	move.w	#$4D,d0
	tst.w	(sp)
	bpl.w	.4
	neg.w	d0
.4
	move.w	d0,(fox).w
	move.w	d1,(foy).w
	addq.w	#4,sp
	jsr	(limitfo).l
.5
	clr.w	(Pencntdwn).w
	bset	#2,(gmode).w
	jsr	(play_new_song).l
	move.w	#3,-(sp)
	jsr	(sfx).l
	movem.l	d1/a0-a3,-(sp)
	movea.l	#PenBuf,a0
	movea.l	#penaltymsgs,a1
	move.w	#$20,d0
	movea.l	#SortCords,a3
.6
	move.w	(a0)+,(a1)+
	beq.w	.7
	clr.w	d1
	move.b	-1(a0),d1
	asl.w	#7,d1
	move.b	$66(a3,d1.w),-1(a1)
	cmpi.b	#5,-1(a0)
	ble.w	.7
	bset	#7,-1(a1)
.7
	dbf	d0,.6
	movem.l	(sp)+,d1/a0-a3
	move.w	#$A,d0
	bra.w	SetPA

rtspen	;IDA: locret_8913E. The shared rts of the penalty routines (94 rtss2)
	rts

AddPenalty	;IDA: sub_89140 (penalty94) Add penalty d0 (PenaltyNames offset) for player a3. Ignored while the clock is stopped
	btst	#0,(gmode).w
	bne.s	rtspen
	cmp.w	#$C,d0
	beq.w	AddPenalty2
	tst.w	(OptPen).w
	beq.s	rtspen
	btst	#2,$63(a3)
	bne.s	rtspen
	btst	#5,(gmode).w
	bne.w	AddPenalty2
	cmp.w	#$10,d0
	beq.s	rtspen

AddPenalty2	;IDA: sub_8916E (penalty94) Forced penalties like faceoff and game over. d0 = penalty number, a3 = player
	btst	#7,(sflags).w
	bne.s	rtspen
	movem.l	d1/a0-a1,-(sp)
	cmp.w	#$E,d0
	blt.w	.1
	addi.w	#$C8,(crowdlevel).w
	move.w	#$C,-(sp)
	btst	#6,$62(a3)
	beq.w	.0
	addi.w	#$14,(CwdExciteLvl).w
	move.w	#$B,(sp)
.0
	jsr	(song).l
.1
	movea.w	#(PenBuf-M68K_RAM),a1
	moveq	#$1F,d1
.2
	tst.w	(a1)+
	dbeq	d1,.2
	bne.w	.5
	move.b	$53(a3),-(a1)
	move.b	d0,-(a1)
	movea.l	#PenaltyNames,a0
	adda.w	(a0,d0.w),a0
	tst.b	1(a0)
	beq.w	.5
	bmi.w	.5
	btst	#6,$62(a3)
	bne.w	.3
	bset	#1,(sflags9).w
	bra.w	.4
.3
	bset	#2,(sflags9).w
.4
	bset	#4,$63(a3)
	beq.w	.5
	clr.w	(a1)
.5
	movem.l	(sp)+,d1/a0-a1
	rts

PenaltyManager	;IDA: sub_891FE (penalty94) Called periodically. d7 = elapsed time since last call: checkfornewpen, chkprogress, updatepentime, UpdatePA
	bsr.w	updatepentime
	bsr.w	checkfornewpen
	bsr.w	chkprogress
	bra.w	UpdatePA

chkprogress	;IDA: sub_8920E (penalty94) Control the progress of the ref and the game through penalty events. While BA_PS_flags bit 2 is set run
	;PenaltyShotBox (bit 7) or the msgtimer count down and erase the message area
	btst	#2,(BA_PS_flags).w
	beq.w	.3
	btst	#7,(BA_PS_flags).w
	bne.w	.1
	tst.w	(msgtimer).w
	bmi.w	.3
	subq.w	#1,(msgtimer).w
	bpl.w	.2
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#2,(sflags2).w
	bclr	#7,(gmode2).w
	jsr	(printz).l
	String	$FF,3,2,0
	moveq	#$1B,d0
	moveq	#8,d1
	btst	#0,(gmode2).w
	beq.w	.0
	move.w	#$C,d1
.0
	move.l	#$7FF,d2
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	bra.w	.2
.1
	jsr	(PenaltyShotBox).l
	bclr	#7,(BA_PS_flags).w
.2
	rts
.3
	btst	#2,(gmode).w
	beq.w	rtspen
	tst.w	(Pencntdwn).w
	bmi.w	InProgress
	sub.w	d7,(Pencntdwn).w
	bpl.w	rtspen
	bclr	#3,(gmode).w
	movea.w	#(PenBuf-M68K_RAM),a0
.4
	tst.w	(a0)+
	beq.w	rtspen
	clr.w	d0
	move.b	-2(a0),d0
	movea.l	#PenaltyNames,a1
	adda.w	(a1,d0.w),a1
	tst.b	1(a1)
	beq.s	.4
	bmi.s	.4
	bset	#2,(sflags2).w
	bset	#7,(sflags).w
	btst	#6,(sflags).w
	bne.w	.5
	move.w	#$98,(xc1).w
	move.w	#0,(yc1).w
	bset	#6,(sflags).w
.5
	move.w	(ExtraChars).w,d4
	movea.l	#RefTilesHor+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	st	(puckc).w
	movea.w	#(puckx-M68K_RAM),a3
	moveq	#5,d0
	jsr	(assinsert).l
	move.w	#$1C20,$40(a3)
	st	(RefStep).w
	clr.w	(RefCnt).w
	bsr.w	UpdatePA
	move.w	#$32,(RefCnt).w
	clr.w	d0
	bsr.w	PushRef
	move.w	#$18,(palcount).w
	rts

InProgress	;IDA: loc_89332 (penalty94) Ref in progress: update the graphics, stats and penalty information
	tst.w	(RefCnt).w
	bpl.w	rtspen
	tst.w	(RefStep).w
	bpl.w	rtspen
	movem.l	d0/a0-a3,-(sp)
.0
	movea.w	#(PenBuf-M68K_RAM),a0
	tst.w	(a0)+
	beq.w	.11
.1
	tst.w	(a0)+
	bne.s	.1
	subq.w	#4,a0
	bclr	#7,1(a0)
	bne.w	.2
	movem.l	a3,-(sp)
	clr.w	d1
	move.b	1(a0),d1
	asl.w	#7,d1
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d1,a3
	tst.w	$34(a3)
	movem.l	(sp)+,a3
	bpl.w	.14
	clr.w	(a0)
	bra.w	.14
.2
	clr.w	d0
	move.b	(a0),d0
	movea.l	#PenaltyNames,a1
	adda.w	(a1,d0.w),a1
	bclr	#5,(sflags5).w
	clr.w	d2
	move.b	1(a1),d2
	beq.w	.10
	bmi.w	.10
	cmp.b	#5,d2
	bne.w	.3
	bset	#5,(sflags5).w
.3
	movem.l	d0-d1/a1-a4,-(sp)
	jsr	(GetPeriodTimeRemaining).l
	movea.w	#(PenSum-M68K_RAM),a4
	adda.w	(PenSumLength).w,a4
	cmpi.w	#$EC,(PenSumLength).w
	beq.w	.4
	addq.w	#4,(PenSumLength).w
.4
	move.w	d0,(a4)+
	move.b	(a0),(a4)+
	clr.w	d1
	move.b	1(a0),d1
	asl.w	#7,d1
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d1,a3
	clr.w	d0
	movea.w	#(HmShots-M68K_RAM),a2
	lea	tmsize(a2),a1
	btst	#6,$62(a3)
	beq.w	.5
	bset	#7,-1(a4)
	move.w	#$8000,d0
	exg	a1,a2
.5
	addq.w	#1,6(a2)
	add.w	d2,8(a2)
	move.b	$66(a3),d0
	move.b	d0,(a4)
	move.w	d0,(TempPlOffset).w
	ext.w	d0
	addi.w	#$104,d0
	add.b	d2,(a2,d0.w)
	subi.w	#$104,d0
	asl.w	#1,d0
	ext.w	d2
	mulu.w	#$3C,d2
	bset	#$D,d2
	tst.w	tmpdst(a2,d0.w)
	bmi.w	.6
	btst	#4,tmpdst(a2,d0.w)
	beq.w	.6
	bset	#$C,d2
.6
	move.w	d2,tmpdst(a2,d0.w)
	andi.w	#$EFFF,d2
	moveq	#$34,d1
.7
	subq.w	#2,d1
	bmi.w	.8
	move.w	$68(a1,d1.w),d3
	andi.w	#$EFFF,d3
	cmp.w	d3,d2
	bne.s	.7
	btst	#5,(sflags5).w
	beq.s	.7
	bset	#6,$68(a1,d1.w)
	bset	#6,tmpdst(a2,d0.w)
.8
	movem.l	a0,-(sp)
	lea	$9C(a2),a0
	moveq	#$18,d1
.9
	tst.b	(a0)+
	dbmi	d1,.9
	move.b	d0,-1(a0)
	st	(a0)
	movem.l	(sp)+,a0
	addq.w	#1,$32(a2)
	bset	#6,(sflags9).w
	move.w	#$15,d0
	jsr	(assreplace).l
	movem.l	(sp)+,d0-d1/a1-a4
	bsr.w	SetPA
	bra.w	.14
.10
	clr.w	(a0)
	btst	#7,(sflags).w
	bne.w	.0
	bsr.w	SetPA
	bra.w	.14
.11
	movea.w	#(HmShots-M68K_RAM),a2
	bsr.w	coinsearch
	adda.w	#tmsize,a2
	bsr.w	coinsearch
	bclr	#2,(gmode).w
	movea.w	#(puckx-M68K_RAM),a3
	bclr	#6,(BA_PS_flags).w
	bclr	#6,(sflags9).w
	beq.w	.12
	bset	#5,(sflags9).w
.12
	move.w	#3,d0
	btst	#3,(BA_PS_flags).w
	beq.w	.13
	move.w	#$1F,d0
.13
	jsr	(assreplace).l
.14
	movem.l	(sp)+,d0/a0-a3
	rts

coinsearch	;IDA: sub_89514 (penalty94) 93 IDA name. a2 = team. Count the players kept off the ice by penalties (coincidental penalties)
	moveq	#6,d1
	moveq	#$32,d0
.0
	tst.w	tmpdst(a2,d0.w)
	ble.w	.1
	bclr	#5,tmpdst(a2,d0.w)
	btst	#6,tmpdst(a2,d0.w)
	bne.w	.1
	btst	#4,tmpdst(a2,d0.w)
	bne.w	.1
	cmp.w	#4,d1
	beq.w	.1
	subq.w	#1,d1
.1
	subq.w	#2,d0
	bpl.s	.0
	move.w	d1,tmap(a2)
	rts

updatepentime	;IDA: sub_8954E (penalty94) Update the time remaining on all penalized players, once a second (Penaltytimer); sets sflags3 bit 6 on that
	;tick. chkatop, updatePPTeamTime, then ProcessPenaltyList for both teams
	bclr	#6,(sflags3).w
	btst	#0,(gmode).w
	bne.w	rtspen
	sub.w	d7,(Penaltytimer).w
	bpl.w	rtspen
	addi.w	#$18,(Penaltytimer).w
	bset	#6,(sflags3).w
	jsr	(chkatop).l
	jsr	(updatePPTeamTime).l
	movea.w	#(HmShots-M68K_RAM),a2
	bsr.w	ProcessPenaltyList
	adda.w	#tmsize,a2

ProcessPenaltyList	;IDA: sub_8958A (penalty94) 93 name. a2 = team. Walk the penalty box list ($9C, 94 $9A): the first two players without a coincidental
	;penalty count down one second and the rest wait. Beeps when the first served time gets to 5 or less and releases the player at 0
	lea	$9C(a2),a0
	movea.w	#(mesarea-M68K_RAM),a1
	moveq	#2,d1
	moveq	#2,d3
.0
	clr.w	d0
	move.b	(a0)+,d0
	bmi.w	.2
	btst	#6,tmpdst(a2,d0.w)
	bne.w	.7
	subq.w	#1,d1
	bmi.s	.0
	move.w	d0,(a1)+
	subq.w	#1,tmpdst(a2,d0.w)
	bne.w	.1
	bsr.w	RemovePlayerFromList
.1
	bra.s	.0
.2
	move.w	(mesarea).w,d0
	cmp.w	#1,d1
	beq.w	.5
	tst.w	d1
	bne.w	.3
	bsr.w	.5
	bra.w	.4
.3
	cmp.w	#$FFFF,d1
	bne.w	rtspen
.4
	move.w	(TextBuffer).w,d0
.5
	cmpi.w	#5,tmpdst(a2,d0.w)
	bgt.w	rtspen
	move.w	#1,-(sp)
	tst.w	tmpdst(a2,d0.w)
	bne.w	.6
	bsr.w	releasepl
	move.w	#2,(sp)
.6
	jsr	(sfx).l
	rts
.7
	subq.w	#1,tmpdst(a2,d0.w)
	btst	#3,tmpdst(a2,d0.w)
	beq.s	.0
	btst	#4,tmpdst(a2,d0.w)
	bne.w	.8
	move.w	#$1000,tmpdst(a2,d0.w)
	bra.w	RemovePlayerFromList
.8
	clr.w	tmpdst(a2,d0.w)

RemovePlayerFromList	;IDA: sub_8962C (penalty94) 93 name. Remove the entry before a0 from a penalty box list by shifting the rest down. Return a0 =
	;removed slot
	moveq	#$FFFFFFFF,d2
.0
	addq.w	#1,d2
	move.b	(a0,d2.w),-1(a0,d2.w)
	bpl.s	.0
	subq.w	#1,a0
	rts

releasepl	;IDA: sub_8963C (penalty94) 93 name. The player's penalty time is up, so let him out (if appropriate). a2 = team, d0 = player * 2
	movem.l	d0-d3/a0-a3,-(sp)
	movea.w	$22(a2),a3
	suba.w	#$80,a3
.0
	adda.w	#$80,a3
	tst.w	$34(a3)
	bpl.s	.0
	move.w	d0,d3
	lsr.w	#1,d3
	move.w	tmap(a2),d1
	addq.w	#1,tmap(a2)
	bset	#0,(HmShots+tmflags).w
	bset	#0,(AwShots+tmflags).w
	movea.l	#priolist,a0
	tst.w	$26(a2)
	bpl.w	.1
	addq.w	#1,a0
.1
	clr.w	$34(a3)
	move.b	(a0,d1.w),$35(a3)
	jsr	(Setplass).l
	bsr.w	setplayer
	bset	#2,$63(a3)
	movem.l	(sp)+,d0-d3/a0-a3
	rts

checkfornewpen	;IDA: sub_8969A (penalty94) Look for a new penalty (entered through AddPenalty / AddPenalty2)
	btst	#7,(sflags).w
	bne.w	rtspen
	movea.w	#(PenBuf-M68K_RAM),a0
.0
	tst.w	(a0)+
	beq.w	rtspen
	btst	#2,(gmode).w
	bne.w	.2
	clr.w	d0
	move.b	-2(a0),d0
	movea.l	#PenaltyNames,a1
	adda.w	(a1,d0.w),a1
	tst.b	1(a1)
	beq.w	.1
	move.w	(puckc).w,d0
	bmi.w	.3
	subq.w	#6,d0
	move.b	-1(a0),d1
	ext.w	d1
	subq.w	#6,d1
	eor.w	d1,d0
	bmi.w	.3
.1
	bsr.w	Stop4Pen
.2
	bset	#7,-1(a0)
	bne.s	.0
	clr.w	d0
	move.b	-2(a0),d0
	movea.l	#PenaltyNames,a1
	adda.w	(a1,d0.w),a1
	clr.w	d1
	move.b	(a1),d1
	asl.w	#5,d1
	cmp.w	(Pencntdwn).w,d1
	ble.s	.0
	move.w	d1,(Pencntdwn).w
	bra.s	.0
.3
	bset	#3,(gmode).w
	bne.s	.0
	move.w	#$2C,d0
	bsr.w	SetPA
	bra.s	.0

UpdatePA	;IDA: sub_89728 (penalty94) Animate the ref in the ref window (RefCnt, SetPA2); game over (RefPen 4): DisplayPeriodOver; penmsgtimer
	tst.w	(RefCnt).w
	bmi.w	rtspen
	sub.w	d7,(RefCnt).w
	bpl.w	.0
	bsr.w	SetPA2
.0
	cmpi.w	#4,(RefPen).l
	bne.w	.1
	jsr	(DisplayPeriodOver).l
.1
	sub.w	d7,(penmsgtimer).w
	bpl.w	rtspen
	move.w	#$7FFF,(penmsgtimer).w
	rts

SetPA	;IDA: sub_8975E (penalty94) Start ref animation d0 (penalty number); from $2E up ignored. prefmes, goal ($E): DisplayPlayerAttributeMenu,
	;Shootout: ShootoutWonBy. Falls into SetPA2
	move.w	d0,(RefPen).w
	cmp.w	#$2E,d0
	blt.w	.0
	rts
.0
	clr.w	(RefStep).w
	bsr.w	prefmes
	cmp.w	#$E,d0
	bne.w	.1
	jsr	(DisplayPlayerAttributeMenu).l
.1
	btst	#0,(gmode2).w
	beq.w	.2
	btst	#3,(gmode2).w
	beq.w	.2
	jsr	(ShootoutWonBy).l
.2
	move.w	#$7FFF,(penmsgtimer).w
	btst	#7,(sflags).w
	beq.w	SetPA2
	move.w	#$3C,(penmsgtimer).w

SetPA2	;IDA: sub_897B2 (penalty94) IDA: setPA2 (94). Update the ref animation: next frame / delay pair from the PenaltyNames animation
	movem.l	d0-d2/a0-a1,-(sp)
	moveq	#$40,d0
	tst.w	(RefStep).w
	bmi.w	.2
	move.w	(RefStep).w,d0
	addq.w	#2,(RefStep).w
	move.w	(RefPen).w,d1
	movea.l	#PenaltyNames,a0
	adda.w	(a0,d1.w),a0
	addq.w	#2,a0
	adda.w	(a0),a0
	move.w	(a0,d0.w),d0
	bpl.w	.0
	neg.w	d0
	st	(RefStep).w
.0
	clr.w	d1
	move.b	d0,d1
	asl.w	#3,d1
	move.w	d1,(RefCnt).w
	btst	#0,(gmode2).w
	beq.w	.1
	btst	#3,(gmode2).w
	beq.w	.1
	move.w	d0,-(sp)
	move.w	(RefCnt).w,d0
	add.w	d0,d0
	move.w	d0,(RefCnt).w
	move.w	(sp)+,d0
.1
	lsr.w	#8,d0
.2
	bsr.w	PushRef
	movem.l	(sp)+,d0-d2/a0-a1
	rts

PushRef	;IDA: sub_89820 (penalty94) Tell vblank what to display: ref frame d0 (RefTiles, RefTilesHor in the horizontal rink) into RefRamMap; $40
	;clears the window
	movem.l	d0-d2/a0-a1,-(sp)
	cmp.w	#$40,d0
	beq.w	.2
	mulu.w	#$70,d0
	movea.l	#RefTiles,a0
	btst	#7,(sflags).w
	beq.w	.0
	movea.l	#RefTilesHor,a0
.0
	adda.l	4(a0),a0
	addq.w	#4,a0
	adda.w	d0,a0
	movea.w	#(RefRamMap-M68K_RAM),a1
	move.w	(ExtraChars).w,d2
	ori.w	#$8000,d2
	moveq	#$37,d0
.1
	move.w	(a0)+,(a1)
	add.w	d2,(a1)+
	dbf	d0,.1
	bset	#1,(sflags2).w
	bra.w	.5
.2
	btst	#7,(sflags).w
	bne.w	.4
	movea.w	#(RefRamMap-M68K_RAM),a1
	moveq	#$37,d0
.3
	move.w	#$7FF,(a1)+
	dbf	d0,.3
	bset	#1,(sflags2).w
.4
	moveq	#$FFFFFFFF,d0
	bsr.w	prefmes
.5
	movem.l	(sp)+,d0-d2/a0-a1
	rts

prefmes	;IDA: sub_89898 (penalty94) Print the message for penalty d0 (negative clears it) under the ref
	movem.l	d0-d2/a1,-(sp)
	btst	#7,(sflags).w
	bne.w	.3
	tst.w	d0
	bpl.w	.0
	jsr	(printz).l
	String	$BF,0,$A,0
	moveq	#$D,d0
	moveq	#3,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	bra.w	.4
.0
	jsr	(printz).l
	String	$BF,5,$A,0
	movea.l	#PenaltyNames,a1
	adda.w	(a1,d0.w),a1
	addq.w	#2,a1
	move.w	(a1),d0
	subq.w	#2,d0
	beq.w	.4
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	bpl.w	.1
	clr.w	(printx).w
.1
	move.w	(a1),d0
	tst.b	-1(a1,d0.w)
	bne.w	.2
	subq.w	#1,d0
.2
	moveq	#3,d1
	jsr	(Framer).l
	subq.w	#2,(printy).w
	addq.w	#1,(printx).w
	jsr	(print).l
	bra.w	.4
.3
	tst.w	d0
	bmi.w	.4
	jsr	(printz).l
	String	$BF,$11,$B,$0
	movea.l	#PenaltyNames,a1
	adda.w	(a1,d0.w),a1
	addq.w	#2,a1
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
.4
	movem.l	(sp)+,d0-d2/a1
	rts

PrintPenaltyMessagesString	;IDA dc.b (penalty94) 93 name. Blank the horizontal mode penalty message line (22 spaces at x 5, y $B). IDA dc.b, no xref
	jsr	(printz).l
	String	$BF,5,$B,'                      '
	rts

