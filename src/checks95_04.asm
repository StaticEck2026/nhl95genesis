;	NHL 95 checks95_04. Retail $088046-$088F05 (3776 bytes).
;	94 checks94 puckfaceoff ... Endfaceoff, with moved in: data94 PlayoffTreeSetup, title94 DrawPlayoffSprite, display94 SetSframe and
;	checkfo, penalty94 UpdateScores / SetScore / sctab, hockey94 ClearShotData, assign94 assfaceoff / assfaceoffp1, and the 95
;	DrawFaceoffWindow (94 puckfaceoff2 .drawfaceoffwindow). 94 ChkGoalies, ReturnGoalies, CPgoalie and CompLine are not here. penalty95
;	follows at $088F06.
;	IDA left puckfaceoff ... Endfaceoff ($883C8-$88D51) as dc.b; that code is read from the retail bytes with the 94 source as the
;	guide. IDA hid the printz / printz2 Strings as instructions; they are String here. Local labels are numbered; the IDA local names
;	are not kept.
;	95 changes: four pads (c1playernum ... c4playernum, cont3team / cont4team), the 95 assignment numbers ($1F, 4, $10, $11, 1) and SPA
;	values, net y $112 / $FEEE (94 $10C / $FEF4), Practice Mode (sflags9 bit 7) faceoffs, tmsize $366.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


PlayoffTreeSetup	;IDA: unk_88046 (data94). 93 name. Playoff tree layout by gamelevel, the same bytes as 94. Used by PlayoffScreen
	;(setup95_02). Per level: teams-1 then x,y per team (DrawTeamBlocks), arrows-1 then x,d0 per arrow (DrawPlayoffBracket), scores-1
	;then x,y per score (FormatScore, negative: none)
	dc.w	.l0-PlayoffTreeSetup
	dc.w	.l1-PlayoffTreeSetup
	dc.w	.l2-PlayoffTreeSetup
	dc.w	.l3-PlayoffTreeSetup
	dc.w	.l4-PlayoffTreeSetup
;tree graphics for level 0: teams-1 then x,y per team (DrawTeamBlocks), arrows-1 then x,d0 per arrow
;(DrawPlayoffBracket), scores-1 then x,y per score (FormatScore, negative: none)
.l0	dc.b	16-1
	dc.b	46,2,46,5,46,8,46,11,46,14,46,17,46,20,46,23
	dc.b	71,2,71,5,71,8,71,11,71,14,71,17,71,20,71,23
	dc.b	1,57,0,69,10
	dc.b	7,50,4,50,10,50,16,50,22,75,4,75,10,75,16,75,22
;tree graphics for level 1
.l1	dc.b	16+8-1
	dc.b	32,2,32,5,32,8,32,11,32,14,32,17,32,20,32,23
	dc.b	85,2,85,5,85,8,85,11,85,14,85,17,85,20,85,23
	dc.b	46,4,46,10,46,15,46,21
	dc.b	71,4,71,10,71,15,71,21
	dc.b	3,43,0,57,2,69,8,83,10
	dc.b	3,50,8,50,18,75,8,75,18
;tree graphics for level 2
.l2	dc.b	16+8+4-1
	dc.b	18,2,18,5,18,8,18,11,18,14,18,17,18,20,18,23
	dc.b	99,2,99,5,99,8,99,11,99,14,99,17,99,20,99,23
	dc.b	32,4,32,10,32,15,32,21
	dc.b	85,4,85,10,85,15,85,21
	dc.b	46,7,46,18
	dc.b	71,7,71,18
	dc.b	5,29,0,43,2,57,4,69,6,83,8,97,10
	dc.b	1,50,13,75,13
;tree graphics for level 3
.l3	dc.b	16+8+4+2-1
	dc.b	4,2,4,5,4,8,4,11,4,14,4,17,4,20,4,23
	dc.b	113,2,113,5,113,8,113,11,113,14,113,17,113,20,113,23
	dc.b	18,4,18,10,18,15,18,21
	dc.b	99,4,99,10,99,15,99,21
	dc.b	32,7,32,18
	dc.b	85,7,85,18
	dc.b	46,12
	dc.b	71,12
	dc.b	5,15,0,29,2,43,4,83,6,97,8,111,10
	dc.b	0,63,23
;tree graphics for level 4
.l4	dc.b	16+8+4+2+1-1
	dc.b	4,2,4,5,4,8,4,11,4,14,4,17,4,20,4,23
	dc.b	113,2,113,5,113,8,113,11,113,14,113,17,113,20,113,23
	dc.b	18,4,18,10,18,15,18,21
	dc.b	99,4,99,10,99,15,99,21
	dc.b	32,7,32,18
	dc.b	85,7,85,18
	dc.b	46,12
	dc.b	71,12
	dc.b	58,23
	dc.b	5,15,0,29,2,43,4,83,6,97,8,111,10
	dc.b	-1;no scores
	dc.b	$FF;pad (93 $47)

DrawPlayoffSprite	;IDA: sub_881B0 (title94). The PlayoffSprite sprite at playoffspritex / playoffspritey (SetSframe) in Satt, then end the
	;list and set Sattsize. 95 animates it: frame picturebits 0-4, the next one every $A calls (pausetimeout). Called from PlayoffScreen
	movea.w	#(Satt-M68K_RAM),a6
	moveq	#1,d6
	movea.l	#PlayoffSprite,a0
	move.w	(energybarchars).w,d3
	ori.w	#$8000,d3
	move.w	(playoffspritex).w,d0
	move.w	(playoffspritey).w,d1
	move.w	(picturebits).w,d2
	addq.w	#1,(pausetimeout).w
	cmpi.w	#$A,(pausetimeout).w
	blt.w	.0
	clr.w	(pausetimeout).w
	addq.w	#1,(picturebits).w
	cmpi.w	#5,(picturebits).w
	blt.w	.0
	clr.w	(picturebits).w
.0
	jsr	(SetSframe).l
	cmpa.w	#$BC1E,a6
	bne.w	.1
	clr.l	(a6)+
	clr.l	(a6)+
.1
	clr.b	-5(a6)
	move.l	a6,d0
	subi.l	#$FFFFBC1E,d0
	lsr.w	#1,d0
	move.w	d0,(Sattsize).w
	rts

SetSframe	;IDA: sub_8821A (display94). Draw one sprite frame. a0 = framelist, d0/d1 = x/y cords, d2 = frame, d3 = start char,
	;a6 = Satt pointer, d6 = link counter. 95 builds the attribute word from the frame entry's flags and char
	cmp.w	#$40,d6
	bge.w	.2
	movem.l	d0-d5/a0,-(sp)
	adda.l	4(a0),a0
	add.w	d2,d2
	move.w	2(a0,d2.w),d4
	sub.w	(a0,d2.w),d4
	lsr.w	#3,d4
	subq.w	#1,d4
	adda.w	(a0,d2.w),a0
.0
	move.w	2(a0),d2
	andi.w	#$F000,d2
	lsr.w	#1,d2
	move.w	d2,-(sp)
	move.w	4(a0),d2
	andi.w	#$7FF,d2
	or.w	(sp)+,d2
	add.w	d3,d2
	move.w	(a0),(a6)
	add.w	d1,(a6)+
	move.b	2(a0),(a6)+
	move.b	d6,(a6)+
	move.w	d2,(a6)+
	move.w	6(a0),(a6)
	add.w	d0,(a6)+
	addq.w	#1,d6
	cmp.w	#$40,d6
	beq.w	.1
	addq.w	#8,a0
	dbf	d4,.0
.1
	movem.l	(sp)+,d0-d5/a0
.2
	rts

UpdateScores	;IDA: sub_8827C (penalty94). Update the ticker score values of the other games (SetScore). Called from PeriodOver
	bsr.w	GetShifter
	move.w	d1,(TickerNum).w
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d0
	mulu.w	d1,d0
	adda.w	d0,a0
.0
	cmp.w	(gamenum).w,d1
	beq.w	.1
	bclr	#1,$E(a0)
	btst	#2,$E(a0)
	bne.w	.1
	bsr.w	SetScore
.1
	suba.w	#$10,a0
	dbf	d1,.0
	rts

SetScore	;IDA: sub_882B4 (penalty94). Add to the score of the game in a0. After period 3 a game within one goal goes to OT (gsper 3)
	;and asks for a highlight
	cmpi.w	#4,8(a0)
	bge.w	.2
	movem.l	d0-d1/a0-a1,-(sp)
	cmpi.w	#3,8(a0)
	bne.w	.0
	move.w	#5,8(a0)
	move.w	$A(a0),d0
	sub.w	$C(a0),d0
	cmp.w	#1,d0
	bgt.w	.1
	cmp.w	#$FFFF,d0
	blt.w	.1
	move.w	#3,8(a0)
	bset	#1,$E(a0)
	bra.w	.1
.0
	addq.w	#1,8(a0)
	move.w	(a0),d0
	move.w	2(a0),d1
	bsr.w	.3
	add.w	d0,$A(a0)
	move.w	2(a0),d0
	move.w	(a0),d1
	bsr.w	.3
	add.w	d0,$C(a0)
.1
	movem.l	(sp)+,d0-d1/a0-a1
.2
	rts
.3
	asl.w	#2,d0
	movea.w	#TeamList,a1
	movea.l	(a1,d0.w),a1
	adda.w	8(a1),a1
	move.b	(a1),d0
	andi.w	#$70,d0
	lsr.w	#1,d0
	lea	sctab(pc),a1
	move.l	(a1,d0.w),(nibblebuffer).w
	move.l	4(a1,d0.w),(nibblebuffer+4).w
	asl.w	#2,d1
	movea.w	#TeamList,a1
	movea.l	(a1,d1.w),a1
	adda.w	8(a1),a1
	move.b	(a1),d0
	andi.w	#7,d0
	asl.w	#3,d0
	lea	sctab(pc),a1
	move.l	(a1,d0.w),d1
	add.l	d1,(nibblebuffer).w
	move.l	4(a1,d0.w),d1
	add.l	d1,(nibblebuffer+4).w
	moveq	#4,d0
	jmp	WeightedRandomSelect

sctab	;IDA: unk_88378 (penalty94). 93 SetScore .sctab. Weights for 0, 1, 2, 3 goals, 8 rows
	dc.w	$2B,$1E,$17,4
	dc.w	$27,$20,$18,5
	dc.w	$23,$21,$1A,6
	dc.w	$1E,$22,$1E,6
	dc.w	$1A,$24,$1E,8
	dc.w	$16,$25,$1F,$A
	dc.w	$13,$26,$1F,$C
	dc.w	$F,$26,$20,$F

ClearShotData	;IDA: sub_883B8 (hockey94). Clear $E4 words at outputbuffer
	move.w	#$E3,d0
	movea.w	#(outputbuffer-M68K_RAM),a0
.0
	clr.w	(a0)+
	dbf	d0,.0
	rts

puckfaceoff	;IDA dc.b (checks94). Puck assignment 3: start a faceoff. Shootout: stop the puck, assignment $1F (puckshootout). Else on
	;the first call: clear the faceoff spot when sflags8 bit 0, the pads, check for the end of the period (PeriodOver, clockcont_0 in
	;overtime) and a delayed penalty (Stop4Pen), the halftime song, return the goalies (ReturnGoalies); with line changes on, start the
	;pads' line changes (StartFaceoffLineChange) and the computer line (SetFaceoffComputerLine). 95 has no faceoff animation choice here
	bclr	#4,(sflags8).w
	btst	#0,(gmode2).w
	beq.w	.0
	clr.w	(puckvx).w
	clr.w	(puckvy).w
	move.w	#$1F,d0
	jmp	assreplace
.0
	bclr	#1,pflags(a3)
	beq.w	WaitForFaceoffLineChanges
	bclr	#0,(sflags8).w
	beq.w	.1
	clr.w	(fox).w
	clr.w	(foy).w
.1
	bclr	#7,(sflags7).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	bclr	#1,(sflags6).w
	bclr	#1,(gmode2).w
	tst.w	(gameclock).w
	beq.w	PeriodOver
	btst	#6,(gmode).w
	bne.w	PeriodOver
	cmpi.w	#3,(gsp).w
	bne.w	.2
	move.w	(HmGoals).w,d0
	cmp.w	(AwGoals).w,d0
	bne.w	clockcont_0
.2
	btst	#3,(gmode).w
	bne.w	Stop4Pen
	move.w	(PerTimeTotal).w,d0
	asr.w	#1,d0
	cmp.w	(gameclock).w,d0
	bls.w	.3
	cmpi.w	#$3C,(gameclock).w
	blt.w	.3
	bclr	#7,(sflags3).w
	beq.w	.3
	btst	#0,(gmode).w
	beq.w	.3
	btst	#6,(sflags8).w
	bne.w	.3
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#2,(SongIndex).w
	jsr	(ChooseSong).l
	bset	#4,(sflags8).w
.3
	bsr.w	ReturnGoalies
	st	temp1(a3)
	st	temp2(a3)
	tst.w	(OptLine).w
	bne.w	WaitForFaceoffLineChanges
	bclr	#1,(HmShots+tmflags).w
	bclr	#1,(AwShots+tmflags).w
	movea.w	#(SortCords-M68K_RAM),a0
	moveq	#$B,d0
.4
	bclr	#3,pflags2(a0)
	adda.w	#SCstruct,a0
	dbf	d0,.4
	move.w	(cont1team).w,d0
	or.w	(cont2team).w,d0
	or.w	(cont3team).w,d0
	or.w	(cont4team).w,d0
	beq.w	.5
.5
	move.w	(c1playernum).w,d0
	cmp.w	#6,d0
	blt.w	.6
	move.w	(c2playernum).w,d0
	cmp.w	#6,d0
	blt.w	.6
	move.w	(c3playernum).w,d0
	cmp.w	#6,d0
	blt.w	.6
	move.w	(c4playernum).w,d0
	cmp.w	#6,d0
	bge.w	.7
.6
	tst.w	d0
	bmi.w	.7
	bsr.w	StartFaceoffLineChange
.7
	move.w	(c1playernum).w,d0
	cmp.w	#6,d0
	bge.w	.8
	move.w	(c2playernum).w,d0
	cmp.w	#6,d0
	bge.w	.8
	move.w	(c3playernum).w,d0
	cmp.w	#6,d0
	bge.w	.8
	move.w	(c4playernum).w,d0
	cmp.w	#6,d0
	blt.w	.9
.8
	tst.w	d0
	bmi.w	.9
	bsr.w	StartFaceoffLineChange
.9
	movea.w	#(HmShots-M68K_RAM),a1
	lea	tmsize(a1),a2
	moveq	#2,d0
	bsr.w	SetFaceoffComputerLine
	bra.w	WaitForFaceoffLineChanges

SetFaceoffComputerLine	;IDA dc.b (checks94). Line changes on and team d0 not on a pad (or sflags7 bit 4): CompLine, SetPersonel,
	;PrintScores1, crowdnoisedelay $2710
	tst.w	(OptLine).w
	bne.w	rtsfaceoff
	btst	#4,(sflags7).w
	bne.w	.0
	cmp.w	(cont1team).w,d0
	beq.w	rtsfaceoff
	cmp.w	(cont2team).w,d0
	beq.w	rtsfaceoff
	cmp.w	(cont3team).w,d0
	beq.w	rtsfaceoff
	cmp.w	(cont4team).w,d0
	beq.w	rtsfaceoff
.0
	jsr	(CompLine).l
	jsr	(SetPersonel).l
	jsr	(PrintScores1).l
	move.w	#$2710,(crowdnoisedelay).w
	rts

StartFaceoffLineChange	;IDA dc.b (checks94). Player d0 (sort object) opens the line change box (SetLCmode); when it is open start
	;its timer in the puck temp1 / temp2 and keep the SCnum in temp3 / temp4
	exg	a2,a3
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	bclr	#3,pflags2(a3)
	move.l	a2,-(sp)
	bsr.w	SetLCmode
	movea.l	(sp)+,a2
	btst	#3,pflags2(a3)
	beq.w	.1
	btst	#6,pflags(a3)
	beq.w	.0
	move.w	#$168,temp2(a2)
	move.w	SCnum(a3),temp4(a2)
	bra.w	.1
.0
	move.w	#$258,temp1(a2)
	move.w	SCnum(a3),temp3(a2)
.1
	exg	a2,a3

rtsfaceoff	;IDA: locret_88608. The shared rts of the faceoff routines (94 rtss2)
	rts

WaitForFaceoffLineChanges	;IDA dc.b (checks94). Lock the pads (padcont -1), run both line change timers; when both are done set the
	;home computer line and go to assignment 4 (puckfaceoff2)
	move.l	#$FFFFFFFF,(padcont).w
	move.l	#$FFFFFFFF,(padcont+4).w
	move.l	#$FFFFFFFF,(padcont+8).w
	move.w	#$40,d0
	bsr.w	UpdateFaceoffLineChangeTimer
	move.w	#$42,d0
	bsr.w	UpdateFaceoffLineChangeTimer
	tst.w	temp1(a3)
	bpl.s	rtsfaceoff
	tst.w	temp2(a3)
	bpl.s	rtsfaceoff
	movea.w	#(HmShots-M68K_RAM),a2
	lea	tmsize(a2),a1
	moveq	#1,d0
	bsr.w	SetFaceoffComputerLine
	move.w	#4,d0
	bra.w	assreplace

UpdateFaceoffLineChangeTimer	;IDA dc.b (checks94). Line change timer d0 (temp1 / temp2 of the puck): close the box (SetLCmode2) when the
	;player closed it, else count down by d7 and pick the line (lcfound) when it runs out
	tst.w	(a3,d0.w)
	bmi.s	rtsfaceoff
	move.w	4(a3,d0.w),d1
	asl.w	#7,d1
	movea.w	#(SortCords-M68K_RAM),a0
	movea.w	#(HmShots-M68K_RAM),a2
	btst	#6,$62(a0,d1.w)
	beq.w	.0
	adda.w	#tmsize,a2
.0
	btst	#3,$63(a0,d1.w)
	bne.w	.1
	st	(a3,d0.w)
	bra.w	SetLCmode2
.1
	sub.w	d7,(a3,d0.w)
	bpl.w	rtsfaceoff
	move.l	a3,-(sp)
	lea	(a0,d1.w),a3
	btst	#3,pflags2(a3)
	beq.w	.2
	clr.w	d2
	bsr.w	lcfound
	bsr.w	SetLCmode2
.2
	movea.l	(sp)+,a3
	rts

puckfaceoff2	;IDA dc.b (checks94). Puck assignment 4. First call: set up the faceoff: clear the penalty flags, stop the clock,
	;reset the rink, puck and nets, scroll to the spot (checkwindow), reset the bench and players (ResetBench, SetPersonel,
	;forcepldata, resetplstuff), place the players (.apl / .ptab, as 94) with the faceoff assignments ($10 assfaceoff, $11 assfaceoffp1
	;for the centers), load the faceoff tiles, draw the window (DrawFaceoffWindow) and set the drop time. Practice (sflags9 bit 7)
	;keeps the scroll on the spot and drops at once. Later calls: count down (updatefaceoff), then Endfaceoff
	bclr	#1,pflags(a3)
	beq.w	.28
	bclr	#2,(BA_PS_flags).w
	bclr	#5,(BA_PS_flags).w
	bclr	#0,(sflags4).w
	bclr	#1,(sflags4).w
	bclr	#0,(sflags9).w
	bclr	#1,(sflags9).w
	bclr	#2,(sflags9).w
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(forceblack).l
.0
	btst	#0,(disflags).w
	bne.s	.0
	move	sr,-(sp)
	move.w	#$3C,(holdreset).w
	tst.w	(fox).w
	bne.w	.1
	tst.w	(foy).w
	bne.w	.1
	move.w	#$FFFF,(faceoffanim).w
	bra.w	.2
.1
	move	#$2700,sr
.2
	cmpi.w	#$258,(crowdlevel).w
	bls.w	.3
	move.w	#$258,(crowdlevel).w
.3
	bset	#3,(disflags).w
	bclr	#0,(sflags).w
	bclr	#0,(sflags3).w
	clr.b	(iflags).w
	st	(RefCnt).w
	st	(puckcross2).w
	st	(puckcross6).w
	bclr	#1,(sflags2).w
	bset	#0,(sflags2).w
	bset	#2,(sflags2).w
	st	(passplayer).w
	st	(onetimerplayer).w
	btst	#7,(sflags9).w
	bne.w	.4
	bset	#4,(disflags).w
.4
	jsr	(ClrHor).l
	clr.w	(Vpos).w
	clr.w	(Hpos).w
	btst	#7,(sflags9).w
	beq.w	.8
	move.w	(fox).w,(Hpos).w
	cmpi.w	#$FFCC,(Hpos).w
	blt.w	.6
	cmpi.w	#$34,(Hpos).w
	bgt.w	.5
	bra.w	.7
.5
	move.w	#$34,(Hpos).w
	bra.w	.7
.6
	move.w	#$FFCC,(Hpos).w
.7
	move.w	(foy).w,(Vpos).w
.8
	move.w	(fox).w,(puckx).w
	move.w	(foy).w,(pucky).w
	st	(puckz).w
	clr.w	(puckvx).w
	clr.w	(puckvy).w
	clr.w	(puckvz).w
	st	(puckc).w
	movea.w	#(SortCords+(12*SCstruct)-M68K_RAM),a0
	clr.w	Xvel(a0)
	clr.w	Yvel(a0)
	clr.w	(a0)
	move.w	#$112,Ypos(a0)
	adda.w	#SCstruct,a0
	clr.w	Xvel(a0)
	clr.w	Yvel(a0)
	clr.w	(a0)
	move.w	#$FEEE,Ypos(a0)
	movea.w	#(SortCords+((puckscnum+1)*SCstruct)-M68K_RAM),a0
	move.w	#$1B3,frame(a0)
	clr.w	SPA(a0)
	clr.w	attribute(a0)
	clr.w	(SortCords+(puckscnum*SCstruct)+attribute).w
	bclr	#6,(sflags).w
	moveq	#$64,d4
.9
	jsr	(checkwindow).l
	dbf	d4,.9
	move.w	#$3C,(yleader).w
	jsr	(ResetBench).l
	movea.w	#(HmShots-M68K_RAM),a2
	jsr	(SetPersonel).l
	jsr	(forcepldata).l
	adda.w	#tmsize,a2
	jsr	(SetPersonel).l
	jsr	(forcepldata).l
	jsr	(resetplstuff).l
	btst	#7,(sflags9).w
	beq.w	.10
	jsr	(SetGoaliesCtl).l
.10
	move.l	a3,-(sp)
	movea.w	#(SortCords-M68K_RAM),a3
	moveq	#$B,d2
.11
	move.w	#$FF10,(a3)
	clr.w	Ypos(a3)
	clr.w	frame(a3)
	move.w	position(a3),d1
	bmi.w	.20
	beq.w	.14
	moveq	#$10,d0
	cmp.w	#4,d1
	bne.w	.13
	movea.w	#(HmShots-M68K_RAM),a2
	btst	#6,pflags(a3)
	beq.w	.12
	adda.w	#tmsize,a2
.12
	clr.w	$18(a2)
	move.b	pnum(a3),$19(a2)
	bclr	#7,(sflags8).w
	st	$1A(a2)
	st	$1C(a2)
	bclr	#3,tmflags(a2)
	moveq	#$11,d0
.13
	jsr	(assinsert).l
.14
	move.w	(HmShots+tmap).w,d4
	btst	#6,pflags(a3)
	beq.w	.15
	move.w	(AwShots+tmap).w,d4
.15
	neg.w	d4
	addq.w	#6,d4
	asl.w	#3,d4
	movea.l	#.apl,a1	;position by players on ice
	adda.w	d4,a1
	move.b	(a1,d1.w),d4
	asl.w	#2,d4
	movea.l	#.ptab,a1	;x, y offsets from the spot
	move.w	(a1,d4.w),d0
	move.w	2(a1,d4.w),d1
	btst	#7,pflags(a3)
	bne.w	.16
	neg.w	d0
	neg.w	d1
.16
	tst.w	position(a3)
	beq.w	.19
	cmp.w	#8,d4
	bgt.w	.18
	move.w	(fox).w,d3
	eor.w	d0,d3
	bpl.w	.17
	move.w	(foy).w,d3
	asr.w	#3,d3
	sub.w	d3,d1
.17
	move.w	(fox).w,d3
	asr.w	#2,d3
	sub.w	d3,d0
.18
	add.w	(fox).w,d0
	add.w	(foy).w,d1
.19
	move.w	d0,(a3)
	move.w	d1,Ypos(a3)
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	sub.w	(puckx).w,d0
	sub.w	(pucky).w,d1
	neg.w	d0
	neg.w	d1
	jsr	(vtoa).l
	move.w	d0,facedir(a3)
	bclr	#2,pflags2(a3)
	bclr	#5,pflags(a3)
	move.w	#$B5C,d1
	jsr	(SetSPA).l
.20
	adda.w	#SCstruct,a3
	dbf	d2,.11
	jsr	(SprSort).l
	movea.l	(sp)+,a3
	jsr	(AssignPads).l
	move.w	(ExtraChars).w,d4
	movea.l	#FaceOffMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(faceoffvrcset).w
	movea.l	#FaceOffSprites+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	#$FFFF,(arenaanim).w
	btst	#0,(sflags7).w
	beq.w	.21
	move.w	(faceoffanim).w,d0
	bmi.w	.21
.21
	btst	#7,(sflags9).w
	bne.w	.22
	bsr.w	DrawFaceoffWindow
.22
	move.w	#$78,d0
	jsr	(randomd0).l
	addi.w	#$B4,d0
	move.w	#2,temp1(a3)
	btst	#7,(sflags9).w
	bne.w	.23
	move.w	d0,temp1(a3)
.23
	move.w	#$18,(palcount).w
	movea.l	#fofdata2,a0
	move.w	#1,(a0)
	move.w	#$8000,2(a0)
	move.w	#4,attribute(a0)
	move.w	#$A800,frame(a0)
	move.w	#7,8(a0)
	move.w	#$8000,$A(a0)
	btst	#1,(gmode).w
	bne.w	.24
	eori.w	#$800,2(a0)
	eori.w	#$800,frame(a0)
.24
	move.w	#$FFFF,(fodir1).w
	move.w	#$FFFF,(fodir2).w
	jsr	(LeadSong).l
	bclr	#6,(sflags8).w
	bne.w	.25
	bclr	#4,(sflags8).w
	beq.w	.26
.25
	bclr	#4,(sflags8).w
	move.w	(SongNum).w,-(sp)
	jsr	(song).l
.26
	jsr	(PrintScores1).l
	st	(palcount).w
	btst	#5,(sflags9).w
	bne.w	.27
	move.w	#$18,(palcount).w
.27
	move	(sp)+,sr
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.28
	move.l	#$FFFFFFFF,(padcont).w
	move.l	#$FFFFFFFF,(padcont+4).w
	move.l	#$FFFFFFFF,(padcont+8).w
	subq.w	#1,temp1(a3)
	bpl.w	updatefaceoff
	bra.w	Endfaceoff
.apl
	dc.b	0,1,2,3,4,5,6,0
	dc.b	0,1,5,3,4,2,0,0
	dc.b	0,3,5,1,4,0,0,0
.ptab
	dc.w	0,$FEF9,$FFDD,$FFCE,$23,$FFCE,$FFCE,$FFF6
	dc.w	0,$FFF1,$32,$FFF6,0,$FFC4

assfaceoff	;IDA dc.b (assign94). Assignment $10: wait for the faceoff to end (sflags2 bit 0), then assexit
	btst	#5,pflags(a3)
	bne.w	.0
	btst	#0,(sflags2).w
	beq.w	assexit
.0
	rts

assfaceoffp1	;IDA dc.b (assign94). Assignment $11, the faceoff player: set his fofdata2 frame from his stick hand and goal,
	;and start the faceoff SPA ($1B36, or $1B60 at random once the puck temp1 is above $10). After the faceoff: nopuck $14 and assexit
	btst	#5,pflags(a3)
	bne.w	.7
	btst	#0,(sflags2).w
	beq.w	.6
	bclr	#1,pflags(a3)
	beq.w	.0
	clr.w	temp1(a3)
.0
	movea.l	#fofdata2,a0
	btst	#6,pflags(a3)
	beq.w	.1
	addq.w	#4,a0
.1
	move.w	SPAnum(a3),d0
	lsr.w	#2,d0
	addq.w	#1,d0
	tst.b	handed(a3)
	bne.w	.2
	addq.w	#3,d0
.2
	btst	#7,pflags(a3)
	beq.w	.4
	cmp.w	#3,d0
	ble.w	.3
	subq.w	#3,d0
	bra.w	.4
.3
	addq.w	#3,d0
.4
	move.w	d0,(a0)
	btst	#3,pflags(a3)
	bne.w	.7
	bset	#1,pflags2(a3)
	bne.w	.7
	move.w	#$1B36,d1
	cmpi.w	#$10,(SortCords+(puckscnum*SCstruct)+temp1).w
	bls.w	.5
	moveq	#8,d0
	jsr	(randomd0).l
	tst.w	d0
	beq.w	.5
	move.w	#$1B60,d1
.5
	bset	#1,pflags2(a3)
	jmp	SetSPA
.6
	move.b	#$14,nopuck(a3)
	bra.w	assexit
.7
	rts

updatefaceoff	;IDA dc.b (checks94). Faceoff count down: fofdata frame from temp1; at 0 erase the faceoff window (fodropx / fodropy)
	btst	#5,(sflags9).w
	beq.w	.0
	bset	#0,(sflags).w
.0
	move.w	temp1(a3),d0
	beq.w	.2
	addq.w	#6,d0
	lsr.w	#3,d0
	cmp.w	#2,d0
	bgt.w	.1
	neg.w	d0
	addi.w	#$A,d0
	move.w	d0,(fofdata).w
.1
	rts
.2
	bclr	#4,(disflags).w
	jsr	(printz).l
	String	$BF,0,0,0
	move.w	(fodropx).w,d0
	subi.w	#$2E,d0
	asr.w	#3,d0
	move.w	d0,(printx).w
	move.w	(fodropy).w,d0
	subi.w	#$44,d0
	asr.w	#3,d0
	move.w	d0,(printy).w
	moveq	#$C,d0
	moveq	#$D,d1
	move.w	#$7FF,d2
	btst	#7,(sflags9).w
	bne.w	.3
	jsr	(eraser).l
.3
	bset	#3,(disflags).w
	jmp	PrintScores1

Endfaceoff	;IDA dc.b (checks94). Drop the puck: sfx $2C, reload the ref tiles (RefTiles), clear the faceoff flags, pick the winner
	;(.ftab from the two fofdata2 frames and randomd0) and the puck direction (fodir1 / fodir2 or random, dirtab); assignment 1
	;(pucknorm). Practice drops it dead
	move.w	#$2C,-(sp)
	jsr	(sfx).l
	bclr	#0,(sflags2).w
	move.w	#$3C,(holdreset).w
	move.w	(ExtraChars).w,d4
	movea.l	#RefTiles+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	bclr	#2,(sflags2).w
	bclr	#0,(gmode).w
	bclr	#0,pflags2(a3)
	clr.w	(crowdnoisedelay).w
	bset	#4,(sflags3).w
	move.w	(fodir1).w,d3
	move.w	#$800,d4
	movea.l	#.ftab,a0
	movea.w	#(fofdata2-M68K_RAM),a1
	moveq	#$10,d2
	move.w	(a1),d1
	sub.b	-1(a0,d1.w),d2
	move.w	4(a1),d1
	add.b	-1(a0,d1.w),d2
	moveq	#$21,d0
	jsr	(randomd0).l
	cmp.b	d0,d2
	bls.w	.0
	addq.w	#4,a1
.0
	btst	#3,2(a1)
	beq.w	.1
	move.w	(fodir2).w,d3
	neg.w	d4
.1
	move.w	d3,d0
	btst	#3,d0
	bne.w	.2
	andi.w	#7,d0
	move.w	(VDP_CNTR).l,d1
	andi.w	#3,d1
	bne.w	.3
.2
	moveq	#5,d0
	jsr	(randomd0).l
	subq.w	#2,d0
	andi.w	#7,d0
	tst.w	d4
	bmi.w	.3
	eori.w	#4,d0
.3
	btst	#7,(sflags9).w
	beq.w	.4
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	clr.w	Zvel(a3)
	bra.w	.5
.4
	asl.w	#2,d0
	movea.l	#dirtab,a0
	move.w	(a0,d0.w),d1
	asl.w	#5,d1
	move.w	d1,Xvel(a3)
	move.w	2(a0,d0.w),d1
	asl.w	#5,d1
	add.w	d4,d1
	move.w	d1,Yvel(a3)
	move.w	#$800,d0
	jsr	(randomd0).l
	move.w	d0,Zvel(a3)
.5
	clr.w	(puckz).w
	bclr	#2,pflags(a3)
	moveq	#1,d0
	jmp	assreplace
.ftab
	dc.b	0,8,$10,0,8,$10

checkfo	;IDA: sub_88D52 (display94). Check for faceoff sprites: the 3 fofdata2 entries (frame, flags) as FaceOffSprites sprites
	;at fodropx / fodropy in Satt (a6, d6). Called from setvideo
	btst	#0,(sflags).w
	bne.w	.7
	btst	#4,(disflags).w
	beq.w	.7
	movea.w	#(fofdata2-M68K_RAM),a3
	moveq	#2,d0
.0
	move.w	(a3),d4
	bmi.w	.6
	beq.w	.6
	movea.l	#FaceOffSprites,a2
	adda.l	4(a2),a2
	subq.w	#1,d4
	add.w	d4,d4
	move.w	2(a2,d4.w),d5
	sub.w	(a2,d4.w),d5
	lsr.w	#3,d5
	subq.w	#1,d5
	adda.w	(a2,d4.w),a2
.1
	move.w	(a2),d2
	tst.w	d0
	bne.w	.2
	subi.w	#$B,d2
.2
	addi.w	#$80,d2
	add.w	(fodropy).w,d2
	tst.w	d0
	beq.w	.3
	subi.w	#$A,d2
.3
	move.w	d2,(a6)
	move.w	6(a2),d2
	tst.w	d0
	beq.w	.4
	addq.w	#3,d2
.4
	btst	#3,2(a3)
	beq.w	.5
	subq.w	#3,(a6)
	move.b	2(a2),d2
	andi.w	#$C,d2
	addq.w	#4,d2
	asl.w	#1,d2
	neg.w	d2
	sub.w	6(a2),d2
.5
	addi.w	#$80,d2
	add.w	(fodropx).w,d2
	move.w	d2,6(a6)
	move.b	2(a2),2(a6)
	move.b	d6,3(a6)
	move.b	4(a2),d2
	asl.w	#8,d2
	andi.w	#$FF00,d2
	or.b	2(a2),d2
	andi.w	#$F800,d2
	movem.w	d0,-(sp)
	move.b	3(a2),d0
	asl.w	#8,d0
	andi.w	#$FF00,d0
	or.b	5(a2),d0
	or.w	d0,d2
	movem.w	(sp)+,d0
	move.w	2(a3),d1
	andi.w	#$F800,d1
	eor.w	d1,d2
	add.w	(faceoffvrcset).w,d2
	move.w	d2,4(a6)
	addq.w	#1,d6
	addq.w	#8,a6
	addq.w	#8,a2
	dbf	d5,.1
	addq.w	#4,a3
.6
	dbf	d0,.0
.7
	rts

DrawFaceoffWindow	;IDA: sub_88E42. 95 only (94 puckfaceoff2 .drawfaceoffwindow). The faceoff window (FaceOffMap) at x $36 or $BE,
	;y $5C, and with line changes on the two line names (linelist)
	jsr	(printz).l
	String	$FF,0,0,0
	moveq	#$36,d0
	tst.w	(fox).w
	bpl.w	.0
	move.w	#$BE,d0
.0
	move.w	d0,(fodropx).w
	subi.w	#$2E,d0
	asr.w	#3,d0
	move.w	d0,(printx).w
	moveq	#$5C,d0
	move.w	d0,(fodropy).w
	subi.w	#$44,d0
	asr.w	#3,d0
	move.w	d0,(printy).w
	move.w	(ExtraChars).w,d4
	movea.l	#FaceOffMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$C,d2
	moveq	#$A,d3
	moveq	#0,d5
	bset	#0,(sflags6).w
	jsr	(dobitmap).l
	bclr	#0,(sflags6).w
	tst.w	(OptLine).w
	bne.w	.2
	jsr	(printz2).l
	String	$FA,$A,$FE,4
	moveq	#$C,d0
	moveq	#3,d1
	jsr	(Framer).l
	move.w	(HmShots+tmline).w,d0
	move.w	(AwShots+tmline).w,d1
	btst	#1,(gmode).w
	bne.w	.1
	exg	d0,d1
.1
	jsr	(printz2).l
	String	$FB,1,$FA,$FE
	movea.l	#linelist,a1
	jsr	(PrintSmallListItem).l
	addq.w	#4,(printx).w
	move.w	d1,d0
	movea.l	#linelist,a1
	jsr	(PrintSmallListItem).l
.2
	rts

