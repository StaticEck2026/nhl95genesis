;	NHL 95 checks95_06. Retail $08B9A8-$08D399 (6642 bytes).
;	Mapped to checks94 (48%): checks94 dirtab, MaxSpeed, dostop, stopna, SetSPA, doplayeracc, noturn0, noturn, playeracc and the goal
;	code, with moved in: crowd94 stopna2, penalty94 PenGoalStuff, data94 box / DisplayPlayerAttributeMenu / GoalBigTxt / PPGoalBigTxt,
;	title94 PrintPlayerAssists / PrintPlayerGoals / PrintParenNumber, replay94 checkwindow, setup94 PeriodOver / GameOver /
;	ExitToOpening, hockey94 clockcont_0 / clockcont; and the 95 controller setup screen (SetContTeams ... ReadAllPads). Each routine
;	comment names its 94 file or says 95 only. replay95 follows at $08D39A.
;	IDA left SetGoaliesCtl and PeriodOver as dc.b and the last four routines as wrong code; they and the tables are read from the
;	retail bytes. IDA hid printz Strings and DecompressGraphicsWithCallback remap bytes as instructions; they are String / dc.b here.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


GoalieReadySPA	;IDA: sub_8B9A8. 95 only. d1 = the goalie ready SPA: $1B7A near the puck (within $56 in y) or in a shootout, else $1C54
	move.w	d0,-(sp)
	move.w	#$1C54,d1
	btst	#0,(gmode).w
	bne.w	.1
	move.w	(pucky).w,d0
	sub.w	Ypos(a3),d0
	bpl.w	.0
	neg.w	d0
.0
	cmp.w	#$56,d0
	bgt.w	.2
.1
	move.w	#$1B7A,d1
.2
	move.w	(sp)+,d0
	rts

dirtab	;IDA: unk_8B9D6. (checks94) X / Y acc speed for each direction 0-7. 95 runspeed $F0 ($A9 = runspeed / sqrt(2); 94 $C8 / $8D)
	dc.w	0,$F0,$A9,$A9,$F0,0,$A9,$FF57
	dc.w	0,$FF10,$FF57,$FF57,$FF10,0,$FF57,$A9
	dc.w	0,0

dirtab2	;no IDA label. 95 only: the same with runspeed $E4 / $A1
	dc.w	0,$E4,$A1,$A1,$E4,0,$A1,$FF5F
	dc.w	0,$FF1C,$FF5F,$FF5F,$FF1C,0,$FF5F,$A1
	dc.w	0,0

MaxSpeed	;IDA: unk_8BA1E. (checks94) Max speed values for each rating level 0-$F: ((n+20)*325)^2 (94 275)
	dc.l	((0+20)*325)*((0+20)*325);$0284AF10
	dc.l	((1+20)*325)*((1+20)*325);$02C6C391
	dc.l	((2+20)*325)*((2+20)*325);$030C1144
	dc.l	((3+20)*325)*((3+20)*325);$03549829
	dc.l	((4+20)*325)*((4+20)*325);$03A05840
	dc.l	((5+20)*325)*((5+20)*325);$03EF5189
	dc.l	((6+20)*325)*((6+20)*325);$04418404
	dc.l	((7+20)*325)*((7+20)*325);$0496EFB1
	dc.l	((8+20)*325)*((8+20)*325);$04EF9490
	dc.l	((9+20)*325)*((9+20)*325);$054B72A1
	dc.l	((10+20)*325)*((10+20)*325);$05AA89E4
	dc.l	((11+20)*325)*((11+20)*325);$060CDA59
	dc.l	((12+20)*325)*((12+20)*325);$06726400
	dc.l	((13+20)*325)*((13+20)*325);$06DB26D9
	dc.l	((14+20)*325)*((14+20)*325);$074722E4
	dc.l	((15+20)*325)*((15+20)*325);$07B65821

dostop	;IDA: loc_8BA5E. (checks94) Stop player a3: under $1000 speed in x and y the velocities are cleared, else slowed
	cmpi.w	#$1000,Xvel(a3)
	bgt.w	.0
	cmpi.w	#$F000,Xvel(a3)
	blt.w	.0
	cmpi.w	#$1000,Yvel(a3)
	bgt.w	.0
	cmpi.w	#$F000,Yvel(a3)
	blt.w	.0
	bra.w	stopna
.0
	move.w	SCnum(a3),d1
	cmp.w	(puckc).w,d1
	beq.w	.1
	move.w	#$B5C,d1
	bra.w	.2
.1
	move.w	#$B8E,d1
.2
	btst	#4,pflags(a3)
	bne.w	.6
	move.w	#$D08,d1
	movem.w	d1,-(sp)
	move.w	SCnum(a3),d1
	cmp.w	(puckc).w,d1
	movem.w	(sp)+,d1
	bne.w	.3
	move.w	#$D5A,d1
.3
	bsr.w	SetSPA
	movem.w	d0,-(sp)
	move.w	Xvel(a3),d0
	bpl.w	.4
	neg.w	d0
.4
	move.w	d0,-(sp)
	move.w	Yvel(a3),d0
	bpl.w	.5
	neg.w	d0
.5
	add.w	(sp)+,d0
	cmp.w	#$2000,d0
	movem.w	(sp)+,d0
	ble.w	.6
	bset	#1,pflags2(a3)
	move.w	#$D08,d1
	movem.w	d1,-(sp)
	move.w	SCnum(a3),d1
	cmp.w	(puckc).w,d1
	movem.w	(sp)+,d1
	bne.w	.6
	move.w	#$D5A,d1
.6
	bsr.w	SetSPA

stopna	;IDA: sub_8BB1A. (checks94) Slow player a3 by $96 in x and y toward 0, no animation change
	tst.w	Xvel(a3)
	beq.w	.1
	bpl.w	.0
	addi.w	#$96,Xvel(a3)
	bmi.w	.1
	clr.w	Xvel(a3)
.0
	subi.w	#$96,Xvel(a3)
	bpl.w	.1
	clr.w	Xvel(a3)
.1
	tst.w	Yvel(a3)
	beq.w	.3
	bpl.w	.2
	addi.w	#$96,Yvel(a3)
	bmi.w	.3
	clr.w	Yvel(a3)
.2
	subi.w	#$96,Yvel(a3)
	bpl.w	.3
	clr.w	Yvel(a3)
.3
	rts

updatevel	;IDA: sub_8BB6C. 95 only. The velocity update 94 updateplayers does in line
	cmpi.w	#$E,SCnum(a3)
	bne.w	.1
	cmpi.w	#$150,Ypos(a3)
	bgt.w	.0
	cmpi.w	#$FEB0,Ypos(a3)
	blt.w	.0
	cmpi.w	#$CA,(a3)
	bgt.w	.0
	cmpi.w	#$FF36,(a3)
	bge.w	.1
.0
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	st	Zpos(a3)
.1
	tst.w	Zpos(a3)
	bne.w	.7
	moveq	#5,d2
	btst	#0,pflags(a3)
	beq.w	.2
	moveq	#9,d2
	cmpi.w	#$E,SCnum(a3)
	bne.w	.2
	move.w	#7,d2
.2
	move.w	Xvel(a3),d0
	beq.w	.5
	tst.w	position(a3)
	bne.w	.3
	cmpi.w	#$E,SCnum(a3)
	beq.w	.3
	tst.w	d2
	beq.w	.3
	cmpi.w	#$22BA,SPA(a3)
	beq.w	.3
	subq.w	#1,d2
.3
	asr.w	d2,d0
	bne.w	.4
	moveq	#1,d0
.4
	sub.w	d0,Xvel(a3)
.5
	move.w	Yvel(a3),d0
	beq.w	.7
	asr.w	d2,d0
	bne.w	.6
	moveq	#1,d0
.6
	sub.w	d0,Yvel(a3)
.7
	move.w	Xvel(a3),d0
	beq.w	.8
	muls.w	d4,d0
	move.l	d0,-(sp)
	asr.l	#5,d0
	add.l	(sp)+,d0
	add.l	d0,(a3)
.8
	move.w	Yvel(a3),d0
	beq.w	.9
	muls.w	d4,d0
	move.l	d0,-(sp)
	asr.l	#5,d0
	add.l	(sp)+,d0
	add.l	d0,Ypos(a3)
.9
	tst.w	Zpos(a3)
	bmi.w	.12
	bne.w	.10
	tst.w	Zvel(a3)
	beq.w	.12
.10
	asl.w	#1,d4
	sub.w	d4,Zvel(a3)
	asl.w	#1,d4
	sub.w	d4,Zvel(a3)
	lsr.w	#2,d4
	move.w	Zvel(a3),d0
	muls.w	d4,d0
	add.l	d0,Zpos(a3)
	bpl.w	.12
	clr.l	Zpos(a3)
	neg.w	Zvel(a3)
	asr	Zvel(a3)
	moveq	#5,d0
	sub.b	Zvel(a3),d0
	bpl.w	.11
	clr.w	d0
.11
	cmp.w	#3,d0
	bhi.w	.12
	move.w	#$2C,d0
	move.w	d0,-(sp)
	jsr	(sfx).l
.12
	rts

SetSPA	;IDA: sub_8BC9A. (checks94) Set animation d1 for player a3 unless it is already running
	cmp.w	SPA(a3),d1
	beq.w	.0
	clr.w	SPAnum(a3)
	move.w	d1,SPA(a3)
	st	SPAcnt(a3)
.0
	rts

stopna2	;IDA: sub_8BCB0. (crowd94) Stop, keeping the animation (goalies)
	tst.w	Xvel(a3)
	bpl.w	.0
	addi.w	#$7D0,Xvel(a3)
	bmi.w	.1
	clr.w	Xvel(a3)
.0
	subi.w	#$7D0,Xvel(a3)
	bpl.w	.1
	clr.w	Xvel(a3)
.1
	tst.w	Yvel(a3)
	bpl.w	.2
	addi.w	#$7D0,Yvel(a3)
	bmi.w	.3
	clr.w	Yvel(a3)
.2
	subi.w	#$7D0,Yvel(a3)
	bpl.w	.3
	clr.w	Yvel(a3)
.3
	rts

doplayeracc	;IDA: loc_8BCFA. (checks94) Player acceleration toward direction d0 by his speed rating (dirtab, MaxSpeed, TempRawSpd / TempMaxSpd),
	;with the turning (turnstep) and the skating animations
	tst.w	position(a3)
	bne.w	.0
	jmp	goalieacc
.0
	move.w	d0,(TempWord1).w
	move.w	SCnum(a3),d1
	cmp.w	(puckc).w,d1
	beq.w	.1
	move.w	#$B5C,d1
	bra.w	.2
.1
	move.w	#$B8E,d1
.2
	btst	#4,pflags(a3)
	beq.w	.3
	move.w	#$2564,d1
.3
	andi.w	#$F,d0
	cmp.w	#7,d0
	ble.w	.7
	cmp.w	#9,d0
	bne.w	.4
	move.w	Xvel(a3),d0
	or.w	Yvel(a3),d0
	bne.w	.5
.4
	btst	#1,pflags2(a3)
	beq.w	.6
	rts
.5
	jmp	dostop
.6
	jmp	SetSPA
.7
	movem.w	d0-d1,-(sp)
	move.w	d0,d2
	move.w	SCnum(a3),d0
	move.w	SCnum(a3),d0
	cmp.w	(puckc).w,d0
	beq.w	.11
	move.w	(puckx).w,d0
	sub.w	(a3),d0
	move.w	Ypos(a3),d3
	move.b	(puckvy).w,d1
	ext.w	d1
	add.w	(pucky).w,d1
	sub.w	d3,d1
	btst	#7,pflags(a3)
	bne.w	.8
	neg.w	d0
	neg.w	d1
	neg.w	d3
	eori.w	#4,d2
.8
	btst	#4,pflags(a3)
	tst.w	d3
	bpl.w	.11
	cmp.w	#4,d2
	bne.w	.11
	jsr	(vtoa).l
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	.11
	bra.w	.9
	subq.w	#3,d2
	andi.w	#7,d2
	cmp.w	#2,d2
	bhi.w	.11
	jsr	(vtoa).l
	addq.w	#2,d0
	andi.w	#7,d0
	cmp.w	#4,d0
	bhi.w	.11
.9
	btst	#4,pflags(a3)
	bne.w	.12
	move.w	Xvel(a3),d0
	or.w	Yvel(a3),d0
	beq.w	.10
	move.w	Xvel(a3),d0
	move.w	Yvel(a3),d1
	jsr	(vtoa).l
	sub.w	(sp),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	.12
.10
	bset	#4,pflags(a3)
	bra.w	.12
.11
	bclr	#4,pflags(a3)
	beq.w	.12
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
.12
	movem.w	(sp)+,d0-d1
	move.w	facedir(a3),d2
	sub.w	d2,d0
	andi.w	#7,d0
	movea.l	#.23,a0
	asl.w	#1,d0
	move.w	(a0,d0.w),(turnstep).w
	tst.w	(turnstep).w
	bne.w	.14
	cmp.w	#8,d0
	beq.w	.14
.13
	move.b	(turnstep+1).w,$77(a3)
	bra.w	noturn0
.14
	cmp.w	#8,d0
	bne.w	.16
	bra.s	.13
	btst	#3,pflags(a3)
	bne.s	.13
	move.w	(VDP_CNTR).l,d4
	btst	#1,d4
	beq.s	.13
	tst.b	$77(a3)
	bne.w	.15
	move.w	#$10,d4
	move.w	d4,(turnstep).w
	bra.w	.16
.15
	move.b	$77(a3),d4
	ext.w	d4
	move.w	d4,(turnstep).w
.16
	move.w	Xvel(a3),d4
	move.w	d4,d3
	asr.w	#6,d4
	sub.w	d4,Xvel(a3)
	move.w	Yvel(a3),d4
	move.w	d4,d3
	asr.w	#6,d4
	sub.w	d4,Yvel(a3)
	move.w	Xvel(a3),d4
	muls.w	d4,d4
	move.w	Yvel(a3),d3
	muls.w	d3,d3
	add.l	d4,d3
	swap	d3
	move.w	#$300,d4
	cmp.w	#$180,d4
	bge.w	.17
	move.w	#$180,d4
.17
	muls.w	(turnstep).w,d4
	btst	#4,pflags(a3)
	beq.w	.18
	neg.l	d4
.18
	add.l	d4,facedir(a3)
	andi.w	#7,facedir(a3)
	move.w	facedir(a3),d2
	movem.w	d0,-(sp)
	move.w	facedir(a3),d0
	cmp.w	(TempWord1).w,d0
	movem.w	(sp)+,d0
	beq.w	.22
	cmp.w	#$14,d3
	bls.w	.22
	clr.w	d1
	tst.w	(turnstep).w
	bpl.w	.19
	eori.w	#$FFAE,d1
.19
	btst	#3,4(a3)
	beq.w	.20
	eori.w	#$FFAE,d1
.20
	addi.w	#$C12,d1
	movem.w	d1,-(sp)
	move.w	SCnum(a3),d1
	cmp.w	(puckc).w,d1
	movem.w	(sp)+,d1
	bne.w	.21
	addi.w	#$A4,d1
.21
	bset	#1,pflags2(a3)
.22
	jsr	(SetSPA).l
	move.b	(turnstep+1).w,$77(a3)
	cmp.w	#2,d3
	bhi.w	noturn
	rts
.23
	dc.w	0,$10,$10,$10,0,$FFF0,$FFF0,$FFF0
	rts;unused

noturn0	;IDA: loc_8BF92. (checks94) doplayeracc: no turn
	moveq	#2,d4
	btst	#4,pflags(a3)
	beq.w	.0
	addq.w	#4,d4
	eori.w	#8,d0
.0
	tst.w	d0
	beq.w	.5
	move.w	Xvel(a3),d0
	move.w	Yvel(a3),d1
	jsr	(vtoa).l
	btst	#3,d0
	bne.w	.1
	sub.w	facedir(a3),d0
	add.w	d4,d0
	andi.w	#7,d0
	cmp.w	#4,d0
	blt.w	dostop
.1
	addq.w	#1,facedir(a3)
	btst	#3,4(a3)
	beq.w	.2
	subq.w	#2,facedir(a3)
.2
	andi.w	#7,facedir(a3)
	move.w	SCnum(a3),d1
	cmp.w	(puckc).w,d1
	beq.w	.3
	move.w	#$B5C,d1
	bra.w	.4
.3
	move.w	#$B8E,d1
.4
	bra.w	SetSPA
.5
	move.w	#$19D2,d1
	btst	#4,pflags(a3)
	bne.w	.9
	move.w	#2,d1
	btst	#7,(sflags).w
	beq.w	.6
	move.w	#$426,d1
.6
	movem.w	d1,-(sp)
	move.w	SCnum(a3),d1
	cmp.w	(puckc).w,d1
	movem.w	(sp)+,d1
	bne.w	.7
	move.w	#$738,d1
.7
	cmpi.w	#$BC0,SPA(a3)
	beq.w	.8
	cmpi.w	#$C12,SPA(a3)
	beq.w	.8
	cmpi.w	#$C64,SPA(a3)
	beq.w	.8
	cmpi.w	#$CB6,SPA(a3)
	bne.w	.9
.8
	move.w	#$314,d1
.9
	btst	#1,pflags2(a3)
	bne.w	noturn
	bsr.w	SetSPA

noturn	;IDA: loc_8C078. (checks94) doplayeracc: no turn, d2 = facedir
	btst	#4,pflags(a3)
	beq.w	playeracc
	eori.w	#4,d2

playeracc	;IDA: loc_8C086. (checks94) Player acceleration with facing d2 (doplayeracc entry used by the goalie and input code)
	asl.w	#2,d2
	lea	dirtab(pc),a0
	move.w	2(a0,d2.w),d1
	move.w	(a0,d2.w),d0
	move.w	$50(a3),d2
	beq.w	.0
	eor.w	d0,d2
	bpl.w	.0
	clr.w	d0
.0
	move.w	$4E(a3),d2
	beq.w	.1
	eor.w	d1,d2
	bmi.w	.1
	clr.w	d1
.1
	clr.w	d2
	move.b	$67(a3),d2
	lsr.w	#2,d2
	neg.w	d2
	addi.w	#$60,d2
	add.b	$68(a3),d2
	asr.w	#1,d2
	muls.w	d2,d0
	muls.w	d2,d1
	asr.l	#5,d0
	asr.l	#5,d1
	muls.w	d7,d0
	muls.w	d7,d1
	tst.w	position(a3)
	bne.w	.2
	btst	#3,pflags(a3)
	bne.w	.2
	cmpi.w	#$22BA,SPA(a3)
	beq.w	.2
	asr.l	#1,d0
	asr.l	#1,d1
.2
	add.w	Xvel(a3),d0
	add.w	Yvel(a3),d1
	move.w	d0,d2
	move.w	d1,d3
	muls.w	d2,d2
	muls.w	d3,d3
	add.l	d2,d3
	movem.w	d0-d1,-(sp)
	clr.l	d0
	jsr	(getpde).l
	btst	#4,(sflags7).w
	beq.w	.3
	move.w	#$1000,d0
.3
	clr.w	d2
	move.b	$69(a3),d2
	move.w	d2,(TempRawSpd).w
	lsr.w	#1,d2
	mulu.w	d0,d2
	asl.l	#4,d2
	swap	d2
	asl.w	#2,d2
	andi.w	#$3F,d2
	lea	MaxSpeed(pc),a2
	move.w	d2,(rosterscroll).w
	move.l	(a2,d2.w),d2
	move.l	d2,(TempMaxSpd).w
	cmpi.w	#$3C,(rosterscroll).w
	bge.w	.4
	btst	#0,(TempRawSpd+1).w
	beq.w	.4
	move.w	(rosterscroll).w,d2
	addq.w	#4,d2
	move.l	(a2,d2.w),d2
	sub.l	(TempMaxSpd).w,d2
	asr.l	#1,d2
	add.l	(TempMaxSpd).w,d2
.4
	btst	#6,pflags2(a3)
	beq.w	.5
	lsr.l	#3,d2
.5
	tst.w	position(a3)
	bne.w	.6
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	.6
	asr.l	#1,d2
.6
	movem.w	(sp)+,d0-d1
	cmp.l	d2,d3
	bhi.w	.7
	move.w	d0,Xvel(a3)
	move.w	d1,Yvel(a3)
.7
	tst.w	(OptLine).w
	bne.w	.9
	move.w	(VDP_CNTR).l,d0
	andi.w	#$7F,d0
	bne.w	.9
	jsr	(getpde).l
	subi.w	#$21,d0
	cmp.w	#$C00,d0
	blt.w	.8
	move.b	$72(a3),d2
	ext.w	d2
	lsr.w	#1,d2
	add.w	d2,d0
	jsr	(setpde).l
	btst	#0,$72(a3)
	beq.w	.9
	btst	#0,(vcount+1).w
	beq.w	.9
	addq.w	#1,d0
.8
	jmp	setpde
.9
	rts

PlaceBoardFall	;IDA: sub_8C1FA. 95 only. Board fall animations (SPA $26C8, $276A, $220E ...): place player a3 against the boards
	cmpi.w	#$26C8,SPA(a3)
	beq.w	.12
	cmpi.w	#$276A,SPA(a3)
	beq.w	.8
	cmpi.w	#$220E,SPA(a3)
	beq.w	.10
	cmpi.w	#$2122,SPA(a3)
	beq.w	.6
	cmpi.w	#$20B0,SPA(a3)
	beq.w	.0
	cmpi.w	#$219C,SPA(a3)
	beq.w	.3
	bra.w	.14
.0
	move.w	#$124,d0
	cmpi.w	#$56,(FallXPos).w
	bgt.w	.1
	cmpi.w	#$FFAA,(FallXPos).w
	bgt.w	.2
.1
	move.w	#$116,d0
.2
	sub.w	Ypos(a3),d0
	bmi.w	.14
	asr.w	#1,d0
	add.w	d0,Ypos(a3)
	bra.w	.14
.3
	move.w	#$FEDC,d0
	cmpi.w	#$56,(FallXPos).w
	bgt.w	.4
	cmpi.w	#$FFAA,(FallXPos).w
	bgt.w	.5
.4
	move.w	#$FEEA,d0
.5
	sub.w	Ypos(a3),d0
	bpl.w	.14
	asr.w	#1,d0
	add.w	d0,Ypos(a3)
	bra.w	.14
.6
	move.w	#$92,d0
	btst	#3,4(a3)
	beq.w	.7
	move.w	#$FF6E,d0
.7
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	.14
.8
	move.w	#$98,d0
	btst	#3,4(a3)
	beq.w	.9
	move.w	#$FF68,d0
.9
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	.14
.10
	move.w	#$FF6E,d0
	btst	#3,4(a3)
	beq.w	.11
	move.w	#$92,d0
.11
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
	bra.w	.14
.12
	move.w	#$FF68,d0
	btst	#3,4(a3)
	beq.w	.13
	move.w	#$98,d0
.13
	sub.w	(a3),d0
	asr.w	#1,d0
	add.w	d0,(a3)
.14
	rts

Goal	;IDA: loc_8C304. (checks94 checkgoal .goal) A goal: the shootout count (shootoutteam, sohomegoals / soawaygoals), EndPenaltyShotPlay, the
	;score summary (ScoreSum), the assignments of both teams (AssignTeam), PenGoalStuff
	btst	#2,(BA_PS_flags).w
	beq.w	.6
	btst	#0,(gmode2).w
	bne.w	.0
	movem.l	d0/a0,-(sp)
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a0
	adda.w	d0,a0
	btst	#7,$62(a0)
	movem.l	(sp)+,d0/a0
	bne.w	.1
	bra.w	.2
.0
	tst.w	(shootoutteam).w
	bne.w	.2
.1
	tst.w	(pucky).w
	bmi.w	rtsgoal
	bra.w	.3
.2
	tst.w	(pucky).w
	bpl.w	rtsgoal
.3
	bset	#5,(sflags4).w
	tst.w	(shootoutteam).w
	beq.w	.4
	addq.w	#1,(soawaygoals).w
	bra.w	.5
.4
	addq.w	#1,(sohomegoals).w
.5
	bset	#0,(sflags8).w
	jsr	(EndPenaltyShotPlay).l
	bra.w	.7
.6
	btst	#0,(gmode).w
	bne.w	rtsgoal
.7
	bset	#0,(sflags4).w
	bclr	#3,(sflags8).w
	bsr.w	ChkShotStat
	jsr	(play_new_song).l
	move.w	d0,-(sp)
	move.w	(vcount).w,d0
.8
	cmp.w	(vcount).w,d0
	beq.s	.8
	move.w	(sp)+,d0
	move.w	#0,-(sp)
	jsr	(sfx).l
	jsr	(LockScroll).l
	addi.w	#$1F4,(crowdlevel).w
	movea.w	#(HmShots-M68K_RAM),a2
	lea	$366(a2),a1
	tst.w	$14(a3)
	bpl.w	.9
	exg	a2,a1
.9
	btst	#1,(gmode).w
	beq.w	.10
	exg	a2,a1
.10
	addq.w	#1,$C(a2)
	btst	#5,(sflags4).w
	beq.w	.11
	btst	#0,(gmode2).w
	bne.w	.11
	addq.w	#1,$364(a2)
.11
	bclr	#4,(gmode2).w
	beq.w	.12
	addq.w	#1,$35C(a2)
.12
	btst	#5,(sflags2).w
	beq.w	.15
	btst	#6,(sflags2).w
	bne.w	.14
	cmpa.l	#$FFFFC5EE,a2
	bne.w	.15
.13
	addq.w	#1,$358(a2)
	bra.w	.15
.14
	cmpa.l	#$FFFFC288,a2
	beq.s	.13
.15
	movem.l	d0/a2,-(sp)
	move.w	(gsp).w,d0
	add.w	d0,d0
	adda.w	d0,a2
	addq.w	#1,$344(a2)
	movem.l	(sp)+,d0/a2
	bclr	#7,(sflags8).w
	beq.w	.16
	addq.w	#1,$360(a2)
.16
	cmpa.w	#$C288,a2
	bne.w	.17
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#3,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	#$100,(songdelay).w
	move.w	(SongNum).w,-(sp)
	move.w	(sp)+,(delayedsong).w
.17
	cmpi.w	#$168,(ScoreSumbytes).w
	bne.w	.18
	subq.w	#6,(ScoreSumbytes).w
.18
	movea.w	#(ScoreSum-M68K_RAM),a0
	adda.w	(ScoreSumbytes).w,a0
	addq.w	#6,(ScoreSumbytes).w
	jsr	(GetPeriodTimeRemaining).l
	move.w	d0,(a0)+
	moveq	#2,d0
	add.w	$24(a2),d0
	sub.w	$24(a1),d0
	move.b	d0,(a0)+
	addi.w	#$1E,(CwdExciteLvl).w
	cmpa.w	#$C288,a2
	beq.w	.19
	subi.w	#$14,(CwdExciteLvl).w
	bset	#7,-1(a0)
.19
	move.w	$18(a2),d0
	move.b	d0,(a0)+
	move.w	#$FFFF,(a0)
	addi.w	#$B6,d0
	movem.l	d0-d2,-(sp)
	move.w	$18(a2),d1
	jsr	(ReadAttributeNibble).l
	cmp.w	d0,d1
	movem.l	(sp)+,d0-d2
	blt.w	.20
	addq.b	#1,(a2,d0.w)
.20
	move.w	$1A(a2),d0
	bmi.w	.21
	cmp.w	$18(a2),d0
	beq.w	.21
	move.b	d0,(a0)+
	addi.w	#$D0,d0
	addq.b	#1,(a2,d0.w)
	move.w	$1C(a2),d0
	bmi.w	.21
	cmp.w	$18(a2),d0
	beq.w	.21
	move.b	d0,(a0)
	addi.w	#$D0,d0
	addq.b	#1,(a2,d0.w)
.21
	move.w	$26(a1),d0
	bmi.w	.22
	addi.w	#$B6,d0
	addq.b	#1,(a1,d0.w)
.22
	bsr.w	ChkShotStat
	btst	#2,(BA_PS_flags).w
	bne.w	.23
	bsr.w	PenGoalStuff
.23
	bclr	#3,(BA_PS_flags).w
	jsr	(PrintScores1).l
	move.w	#$2710,(crowdnoisedelay).w
	btst	#0,(gmode2).w
	beq.w	.24
	bra.w	.25
.24
	moveq	#$1C,d0
	bsr.w	AssignTeam
.25
	clr.w	(collflag).w
	clr.w	$28(a3)
	clr.w	$2A(a3)
	moveq	#6,d0
	tst.w	(a3)
	bpl.w	.26
	neg.w	d0
.26
	move.w	d0,(a3)
	move.w	#$113,d0
	tst.w	$14(a3)
	bpl.w	.27
	neg.w	d0
.27
	move.w	d0,$14(a3)
	move.w	#$600,$2C(a3)
	clr.w	$18(a3)
	st	(puckcross2).w
	st	(puckcross6).w
	bset	#2,$62(a3)
	move.w	#5,d0
	jsr	(assreplace).l
	move.l	a3,-(sp)
	adda.w	#SCstruct,a3
	move.w	#$1F1E,d1
	bsr.w	SetSPA
	movea.w	$22(a1),a3
	moveq	#$E,d0
	bsr.w	AddPenalty2
	movea.l	(sp)+,a3
	rts

AssignTeam	;IDA: sub_8C5DC. 95 only. Give assignment d0 to every player of team a2 on the ice (assinsert)
	move.l	a3,-(sp)
	movea.w	tmsort(a2),a3
	moveq	#5,d3
.0
	tst.w	position(a3)
	ble.w	.2
	btst	#0,pflags2(a3)
	bne.w	.2
	bclr	#2,pflags(a3)
	bclr	#3,$64(a3)
	beq.w	.1
	jsr	(EndOneTimer).l
.1
	jsr	(assinsert).l
.2
	adda.w	#SCstruct,a3
	dbf	d3,.0
	movea.l	(sp)+,a3

rtsgoal	;IDA: locret_8C61C. The shared rts of Goal and AssignTeam
	rts

PenGoalStuff	;IDA: sub_8C61E. (penalty94) 93 name. Do this stuff after a goal: a1 = scored on team, a2 = scoring team. Clears PenBuf, lets the
	;first penalized player of the scored on team out (RemovePlayerFromList), erases the message box (box)
	movem.l	d0-d2/a0,-(sp)
	cmpi.w	#3,(gsp).w
	bne.w	.0
	bclr	#3,(gmode).w
	jsr	(ClearPenaltyBuffer).l
	bra.w	.1
.0
	cmpi.w	#6,$24(a1)
	bne.w	.1
	jsr	(ClearPenaltyBuffer).l
.1
	move.w	$24(a2),d2
	cmp.w	$24(a1),d2
	ble.w	.3
	lea	$9C(a1),a0
.2
	clr.w	d2
	move.b	(a0)+,d2
	bmi.w	.3
	btst	#6,$68(a1,d2.w)
	bne.s	.2
	clr.w	$68(a1,d2.w)
	bsr.w	RemovePlayerFromList
	bset	#0,(sflags9).w
	addq.w	#1,$24(a1)
	addq.w	#1,2(a2)
	bset	#0,(HmShots+tmflags).w
	bset	#0,(AwShots+tmflags).w
.3
	movem.l	(sp)+,d0-d2/a0
	rts

box	;IDA: sub_8C694. (data94) Fill a $13 x 8 rectangle at printz position $FF,$B,2 with char $7FF (eraser)
	jsr	(printz).l
	String	$FF,$B,2,0
	moveq	#$13,d0
	moveq	#8,d1
	move.l	#$7FF,d2
	jmp	eraser

DisplayPlayerAttributeMenu	;IDA: loc_8C6B0. (data94) 93 name. Goal box: close both line change boxes (lcfound2), then the scorer and the assists from
	;ScoreSum (PrintPlayerGoals / PrintPlayerAssists), the goalie counts (CountGoalies)
	movem.l	d0-d2/a0-a4,-(sp)
	btst	#2,(BA_PS_flags).w
	beq.w	.0
	bset	#2,(sflags2).w
.0
	movea.w	#(HmShots-M68K_RAM),a2
	jsr	(lcfound2).l
	adda.w	#$366,a2
	jsr	(lcfound2).l
	movea.w	#(ChkCnt-M68K_RAM),a4
	adda.w	(ScoreSumbytes).w,a4
	jsr	(printz).l
	String	$BF,$B,2,0
	moveq	#$13,d0
	move.w	#5,d1
	tst.b	4(a4)
	bmi.w	.1
	addq.w	#2,d1
	tst.b	5(a4)
	bmi.w	.1
	addq.w	#1,d1
.1
	jsr	(Framer).l
	jsr	(CountGoalies).l
	movea.w	#(HmShots-M68K_RAM),a2
	move.w	(homegoalies).w,(recwins).w
	btst	#7,2(a4)
	beq.w	.2
	adda.w	#$366,a2
	move.w	(awaygoalies).w,(recwins).w
.2
	lea	GoalBigTxt(pc),a1
	bclr	#0,(sflags9).w
	beq.w	.3
	lea	PPGoalBigTxt(pc),a1
.3
	clr.w	d0
	move.b	3(a4),d0
	addi.w	#$B6,d0
	cmpi.b	#3,(a2,d0.w)
	bne.w	.5
	movem.w	d1,-(sp)
	clr.w	d1
	move.b	3(a4),d1
	cmp.w	(recwins).w,d1
	movem.w	(sp)+,d1
	blt.w	.5
	adda.w	(a1),a1
	move.w	d0,-(sp)
	move.w	$28(a2),d0
	cmp.w	(HomeTeam).w,d0
	bne.w	.4
	move.w	#0,d0
.4
	move.w	(sp)+,d0
.5
	jsr	(printbig1).l
	clr.w	d0
	move.b	3(a4),d0
	move.w	d0,-(sp)
	move.w	#$C,(printx).w
	jsr	(FormatPlayerName).l
	jsr	(print).l
	move.w	(sp)+,d0
	movem.w	d1,-(sp)
	clr.w	d1
	move.b	3(a4),d1
	cmp.w	(recwins).w,d1
	movem.w	(sp)+,d1
	blt.w	.6
	jsr	(PrintPlayerGoals).l
.6
	clr.w	d0
	move.b	4(a4),d0
	bmi.w	.7
	bclr	#5,(sflags4).w
	bne.w	.7
	jsr	(printz).l
	String	$BF,$E,6,'Assist by:',$BF,$C,7
	move.w	d0,-(sp)
	jsr	(FormatPlayerName).l
	jsr	(print).l
	move.w	(sp)+,d0
	jsr	(PrintPlayerAssists).l
	clr.w	d0
	move.b	5(a4),d0
	bmi.w	.7
	jsr	(printz).l
	String	$BF,$C,8,0
	move.w	d0,-(sp)
	jsr	(FormatPlayerName).l
	jsr	(print).l
	move.w	(sp)+,d0
	jsr	(PrintPlayerAssists).l
.7
	bclr	#5,(sflags4).w
	movem.l	(sp)+,d0-d2/a0-a4
	rts

GoalBigTxt	;IDA: unk_8C83A. (data94) printbig Strings for DisplayPlayerAttributeMenu: GOAL!, then HAT TRICK!
	String	$BF,$F,3,'GOAL!',$BF,$C,5
	String	$BF,$C,3,'HAT TRICK!',$BF,$C,5

PPGoalBigTxt	;IDA: unk_8C85A. (data94) The same after a power play: PP GOAL!, then HAT TRICK!
	String	$BF,$D,3,'PP GOAL!',$BF,$C,5
	String	$BF,$C,3,'HAT TRICK!',$BF,$C,5

PrintPlayerAssists	;IDA: sub_8C87C. (title94) Print " (" and the assists of player d0 of team a2 (PrintParenNumber)
	movem.l	d0/a2,-(sp)
	jsr	(printz).l
	String	' ('
	adda.w	#$D0,a2
	bra.w	PrintParenNumber

PrintPlayerGoals	;IDA: sub_8C892. (title94) Print " (" and the goals of player d0 of team a2
	movem.l	d0/a2,-(sp)
	jsr	(printz).l
	String	' ('
	adda.w	#$B6,a2

PrintParenNumber	;IDA: loc_8C8A4. (title94) Print the number at d0 of a2 (1 to 3 digits) and ")"
	move.b	(a2,d0.w),d0
	ext.w	d0
	move.w	#1,d1
	cmp.w	#9,d0
	ble.w	.0
	move.w	#2,d1
	cmp.w	#$63,d0
	ble.w	.0
	move.w	#3,d1
.0
	jsr	(PushNumberWidth).l
	jsr	(print).l
	jsr	(printz).l
	String	')'
	addq.w	#1,(printy).w
	move.w	#$E,(printx).w
	movem.l	(sp)+,d0/a2
	rts

LockScroll	;IDA: sub_8C8EC. 95 only. xc1 / yc1 = Hpos / Vpos, sfslock
	move.w	(Vpos).w,(yc1).w
	move.w	(Hpos).w,(xc1).w
	bset	#6,(sflags).w
	rts

checkwindow	;IDA: sub_8C900. (replay94) Scroll the window one step toward xc1 / yc1 (sflags bit 6) or the puck
	movem.l	d0-d3/a3,-(sp)
	move.w	(yc1).w,d2
	move.w	(xc1).w,d3
	btst	#6,(sflags).w
	bne.w	.2
	movea.l	#puckx,a3
	move.w	(puckc).w,d0
	bmi.w	.1
	asl.w	#7,d0
	movea.l	#SortCords,a3
	adda.w	d0,a3
	move.w	d7,d0
	add.w	d0,d0
	btst	#7,$62(a3)
	beq.w	.0
	add.w	d0,(yleader).w
	cmpi.w	#$32,(yleader).w
	blt.w	.1
	move.w	#$32,(yleader).w
	bra.w	.1
.0
	sub.w	d0,(yleader).w
	cmpi.w	#$FFCE,(yleader).w
	bgt.w	.1
	move.w	#$FFCE,(yleader).w
.1
	move.w	$2A(a3),d2
	asr.w	#7,d2
	add.w	$14(a3),d2
	add.w	(yleader).w,d2
	move.w	(a3),d3
.2
	move.w	d2,d0
	sub.w	(Vpos).w,d0
	cmp.w	#$FFF6,d0
	bge.w	.3
	move.w	d2,d1
	subi.w	#$FFF6,d1
	cmp.w	#$FF2E,d1
	bgt.w	.4
	move.w	#$FF2E,d1
	bra.w	.4
.3
	cmp.w	#$A,d0
	ble.w	.6
	move.w	d2,d1
	subi.w	#$A,d1
	cmp.w	#$F0,d1
	blt.w	.4
	move.w	#$F0,d1
.4
	sub.w	(Vpos).w,d1
	beq.w	.6
	asr.w	#4,d1
	bne.w	.5
	addq.w	#1,d1
.5
	move.w	(Vpos).w,d0
	add.w	d1,(Vpos).w
	move.w	(Vpos).w,d1
	eor.w	d1,d0
	bpl.w	.6
	clr.w	(SortCords+(12*SCstruct)+oldframe).w
	clr.w	(SortCords+(13*SCstruct)+oldframe).w
.6
	move.w	d3,d0
	sub.w	(Hpos).w,d0
	cmp.w	#$FFD8,d0
	bge.w	.7
	move.w	d3,d1
	subi.w	#$FFD8,d1
	cmp.w	#$FFCC,d1
	bge.w	.8
	move.w	#$FFCC,d1
	bra.w	.8
.7
	cmp.w	#$34,d0
	ble.w	.10
	move.w	d3,d1
	subi.w	#$28,d1
	cmp.w	#$34,d1
	ble.w	.8
	move.w	#$34,d1
.8
	sub.w	(Hpos).w,d1
	beq.w	.10
	asr.w	#4,d1
	bne.w	.9
	addq.w	#1,d1
.9
	add.w	d1,(Hpos).w
.10
	movem.l	(sp)+,d0-d3/a3
	rts

SetGoaliesCtl	;IDA dc.b. 95 only. Practice Mode: pull the goalies the home / away goalie control (homegoaliectl / awaygoaliectl)
	;does not allow (GoalieCtlLimits by position): position -1, assignment $19
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#SortCords,a0
	move.w	(homegoaliectl).w,d0
	bsr.w	.0
	movea.l	#$FFFFAF62,a0
	move.w	(awaygoaliectl).w,d0
	bsr.w	.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.0
	move.w	#5,d1
	movea.l	#GoalieCtlLimits,a1
.1
	move.w	d1,d2
	asl.w	#7,d2
	move.w	$34(a0,d2.w),d3
	bmi.w	.3
	move.b	(a1,d3.w),d3
	andi.w	#$FF,d3
	cmp.w	d0,d3
	bgt.w	.3
.2
	dbf	d1,.1
	rts
.3
	move.w	#$FFFF,$34(a0,d2.w)
	bset	#2,$63(a0,d2.w)
	bset	#2,$62(a0,d2.w)
	move.w	#$FFFF,$18(a0,d2.w)
	movem.l	d0/a3,-(sp)
	move.w	#$19,d0
	lea	(a0,d2.w),a3
	jsr	(assreplace).l
	movem.l	(sp)+,d0/a3
	bra.s	.2

GoalieCtlLimits	;IDA: unk_8CAB8. 95 only. Goalie control value needed per position
	dc.b	0,4,5,2,1,3

GetGoalieCtl	;IDA: sub_8CABE. 95 only. Test the goalie control of team d0 (1 home, else away)
	movem.l	a0,-(sp)
	movea.l	#homegoaliectl,a0
	cmp.w	#1,d0
	beq.w	.0
	movea.l	#awaygoaliectl,a0
.0
	tst.w	(a0)
	movem.l	(sp)+,a0
	rts

PracticeGoalies	;IDA: sub_8CADE. 95 only. Practice Mode goalie setup (GetGoalieCtl)
	movem.l	d0-d1,-(sp)
	cmpi.w	#1,(cont1team).w
	beq.w	.0
	cmpi.w	#1,(cont2team).w
	beq.w	.0
	cmpi.w	#1,(cont3team).w
	beq.w	.0
	cmpi.w	#1,(cont4team).w
	bne.w	.1
.0
	move.w	#1,d0
	bsr.s	GetGoalieCtl
	bne.w	.1
	move.w	#0,(goaliemode1).w
.1
	cmpi.w	#2,(cont1team).w
	beq.w	.2
	cmpi.w	#2,(cont2team).w
	beq.w	.2
	cmpi.w	#2,(cont3team).w
	beq.w	.2
	cmpi.w	#2,(cont4team).w
	bne.w	.3
.2
	move.w	#2,d0
	bsr.w	GetGoalieCtl
	bne.w	.3
	move.w	#0,(goaliemode2).w
.3
	movem.l	(sp)+,d0-d1
	rts

PeriodOver	;IDA dc.b. (setup94) What to do if the period is over: next period, overtime or game over (gsp 4); Practice Mode
	;(sflags9 bit 7) ends the game; a season game with season flag bit 5 plays on in overtime. Then forceblack and IntermissionStart
	btst	#7,(sflags9).w
	bne.w	.2
	addq.w	#1,(gsp).w
	bchg	#1,(gmode).w
	cmpi.w	#3,(gsp).w
	blt.w	.3
	beq.w	.1
	move.w	#3,(gsp).w
	tst.w	(OptPlayMode).w
	bne.w	.1
	btst	#3,(GameFlags).w
	beq.w	.0
	btst	#5,(SeasonDay+1).w
	bne.w	.1
.0
	move.w	#4,(gsp).w
.1
	move.w	(HmGoals).w,d0
	sub.w	(AwGoals).w,d0
	beq.w	.3
.2
	move.w	#4,(gsp).w
.3
	jsr	(forceblack).l
	jmp	IntermissionStart

clockcont_0	;IDA: loc_8CBC2. (hockey94) The clock ran out in overtime / the game: game over handling, the Stanley Cup (sflags13 bit 2, cupwinner)
	movea.w	#(puckx-M68K_RAM),a3
	moveq	#1,d0
	jsr	(assinsert).l
	cmpi.w	#2,(gsp).w
	blt.w	.9
	moveq	#$1C,d0
	movea.w	#(SortCords-M68K_RAM),a3
	cmpi.w	#3,(gamelevel).w
	bne.w	.5
	cmpi.w	#7,(bosgames).w
	beq.w	.2
	moveq	#$10,d3
	mulu.w	(gamenum).w,d3
	movea.w	#(gsstruct-M68K_RAM),a0
	adda.w	d3,a0
	clr.w	d3
	btst	#0,$E(a0)
	beq.w	.0
	eori.w	#2,d3
.0
	move.w	(HmGoals).w,d1
	sub.w	(AwGoals).w,d1
	bpl.w	.1
	eori.w	#2,d3
.1
	cmpi.w	#3,4(a0,d3.w)
	bne.w	.5
.2
	bset	#2,(sflags13).w
	move.w	(HmShots+$28).w,(cupwinner).w
	move.w	(HmGoals).w,d2
	cmp.w	(AwGoals).w,d2
	bgt.w	.3
	move.w	(AwShots+$28).w,(cupwinner).w
.3
	moveq	#$B,d2
.4
	bclr	#3,$62(a3)
	adda.w	#SCstruct,a3
	dbf	d2,.4
	movea.w	#(SortCords-M68K_RAM),a3
.5
	moveq	#5,d2
	move.w	(HmGoals).w,d1
	sub.w	(AwGoals).w,d1
	beq.w	.9
	bpl.w	.6
	adda.w	#$300,a3
.6
	tst.w	$34(a3)
	ble.w	.7
	jsr	(assinsert).l
	moveq	#$1C,d0
.7
	adda.w	#SCstruct,a3
	dbf	d2,.6
.8
	jsr	(ClearPenaltyBuffer).l
	addi.w	#$3E8,(crowdlevel).w
	bset	#0,(gmode).w
	bset	#6,(gmode).w
	jsr	(ClearPenalties).l
	move.w	#4,d0
	jmp	AddPenalty2
.9
	btst	#7,(sflags9).w
	bne.s	.8
	cmpi.w	#3,(gsp).w
	bne.w	.11
	btst	#3,(GameFlags).w
	beq.w	.10
	btst	#5,(SeasonDay+1).w
	bne.w	.11
.10
	tst.w	(OptPlayMode).w
	beq.s	.8
.11
	move.w	#2,d0
	jmp	AddPenalty2

GameOver	;IDA: loc_8CCE6. (setup94) EncodePW, the Stanley Cup screen (sflags13 bit 2), SeasonGameOver, then ExitToOpening
	jsr	(EncodePW).l
	btst	#2,(sflags13).w
	beq.w	.0
	jsr	(StanleyCupScreen).l
.0
	jsr	(SeasonGameOver).l

ExitToOpening	;IDA: loc_8CD02. (setup94) jmp to the opening
	jmp	Opening2

clockcont	;IDA: sub_8CD08. (hockey94) Clock continue: when the clock is at 0 stop the play (sfx 4) and go to clockcont_0
	btst	#0,(gmode).w
	bne.w	.0
	tst.w	(gameclock).w
	bne.w	.0
	bset	#3,(disflags).w
	jsr	(play_new_song).l
	move.w	#4,-(sp)
	jsr	(sfx).l
	bsr.w	LockScroll
	jmp	clockcont_0
.0
	rts

SetContTeams	;IDA: sub_8CD3C. 95 only. The controller setup screen: pick the team of each pad (cont1team ... cont4team) and the Practice Mode
	;players and goalies
	tst.w	(demoflag).w
	bmi.w	.1
.0
	clr.w	(cont1team).w
	clr.w	(cont2team).w
	clr.w	(cont3team).w
	clr.w	(cont4team).w
	rts
.1
	clr.w	(setupvalues).w
	clr.w	(setupvalues+2).w
	move.w	#1,(cont1team).w
	clr.w	(cont2team).w
	clr.w	(cont3team).w
	clr.w	(cont4team).w
	bsr.w	ControllerSetupScreen
	bsr.w	PrintPracticeTitle
	bsr.w	DrawPadSetup
	btst	#7,(sflags9).w
	beq.w	.2
	bsr.w	PrintPracticeGoalies
.2
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	clr.w	(carddelay).w
.3
	move.w	(vcount).w,d0
.4
	cmp.w	(vcount).w,d0
	beq.s	.4
	addq.w	#1,(carddelay).w
	cmpi.w	#$5460,(carddelay).w
	bge.s	.0
	bsr.w	ReadAllPads
	tst.w	(TempLegSpd).w
	beq.w	.5
	clr.w	(carddelay).w
.5
	btst	#7,(TempLegSpd+1).w
	bne.w	.16
	btst	#1,(TempLegSpd+1).w
	beq.w	.6
	tst.w	(setupvalues).w
	bne.w	.6
	btst	#7,(sflags9).w
	beq.w	.6
	eori.w	#1,(setupvalues).w
	bsr.w	PrintPracticeTitle
.6
	btst	#0,(TempLegSpd+1).w
	beq.w	.7
	tst.w	(setupvalues).w
	beq.w	.7
	eori.w	#1,(setupvalues).w
	bsr.w	PrintPracticeTitle
.7
	move.w	#1,d4
	tst.w	(FourWayPlay).w
	beq.w	.8
	btst	#0,(gmode2).w
	bne.w	.8
	move.w	#3,d4
.8
	movea.l	#cont1team,a0
	movea.l	#$FFFFBB11,a3
.9
	move.b	(a3),d1
	btst	#2,d1
	beq.w	.12
	tst.w	(setupvalues).w
	bne.w	.10
	move.w	(a0),d0
	cmp.w	#2,d0
	beq.w	.12
	movea.l	#ContTeamOrder1,a4
	move.b	(a4,d0.w),d0
	move.w	d0,(a0)
	bsr.w	DrawPadSetup
	bra.w	.15
.10
	subq.w	#1,(setupvalues+2).w
	bpl.w	.11
	move.w	#7,(setupvalues+2).l
.11
	bsr.w	PrintPracticeGoalies
	bra.w	.15
.12
	btst	#3,d1
	beq.w	.15
	tst.w	(setupvalues).w
	bne.w	.13
	move.w	(a0),d0
	cmp.w	#1,d0
	beq.w	.15
	movea.l	#ContTeamOrder2,a4
	move.b	(a4,d0.w),d0
	move.w	d0,(a0)
	bsr.w	DrawPadSetup
	bra.w	.15
.13
	addq.w	#1,(setupvalues+2).w
	cmpi.w	#7,(setupvalues+2).l
	ble.w	.14
	move.w	#0,(setupvalues+2).w
.14
	bsr.w	PrintPracticeGoalies
	bra.w	*+4
.15
	addq.w	#2,a0
	addq.w	#2,a3
	dbf	d4,.9
	bra.w	.3
.16
	rts

ContTeamOrder1	;IDA: unk_8CED4. 95 only. Pad team order tables for SetContTeams
	dc.b	2,0,2,$FF

ContTeamOrder2	;IDA: unk_8CED8
	dc.b	1,1,0,$FF

PrintPracticeGoalies	;IDA: sub_8CEDC. 95 only. Set homegoaliectl / awaygoaliectl from PracticeGoalieTbl and print them
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#PracticeGoalieTbl,a0
	move.w	(setupvalues+2).w,d0
	add.w	d0,d0
	clr.w	(homegoaliectl).w
	move.b	(a0,d0.w),(homegoaliectl+1).w
	clr.w	(awaygoaliectl).w
	move.b	1(a0,d0.w),(awaygoaliectl+1).w
	move.w	#$19,(printy).w
	move.w	(homegoaliectl).w,d0
	move.w	#$1F,(printx).w
	bsr.w	PrintGoalieCount
	move.w	(awaygoaliectl).w,d0
	move.w	#8,(printx).w
	bsr.w	PrintGoalieCount
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintGoalieCount	;IDA: sub_8CF28. 95 only. Print GoalieCountTxt string d0 (PrintSetupStr)
	movea.l	#GoalieCountTxt,a1
	bra.w	.1
.0
	adda.w	(a1),a1
.1
	dbf	d0,.0
	bra.w	PrintSetupStr

GoalieCountTxt	;IDA: unk_8CF3C. 95 only. "0", "1", "2"
	String	'0'
	String	'1'
	String	'2'

PracticeGoalieTbl	;IDA: unk_8CF48. 95 only. Home / away goalie control by Practice Mode setting
	dc.b	1,0,0,1,2,0,0,2,1,2,2,1,1,1,2,2

DrawPadSetup	;IDA: sub_8CF58. 95 only. Draw the pads, their icons (DrawPadIcon) and the cursor (DrawPadCursor)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$A,(printy).w
	move.w	#1,d4
	tst.w	(FourWayPlay).w
	beq.w	.0
	btst	#0,(gmode2).w
	bne.w	.0
	move.w	#3,d4
.0
	movea.l	#cont1team,a0
	move.w	#0,d7
.1
	move.w	(printy).w,-(sp)
	subq.w	#1,(printy).w
	movea.l	#BlankLineTxt,a1
	bsr.w	PrintSetupStr
	addq.w	#1,(printy).w
	bsr.w	PrintSetupStr
	addq.w	#1,(printy).w
	bsr.w	PrintSetupStr
	jsr	(printz).l
	String	$FF,0,0,0
	move.w	(sp)+,(printy).w
	move.w	#$F,(printx).w
	tst.w	(a0)
	beq.w	.2
	move.w	#$1B,(printx).w
	cmpi.w	#1,(a0)
	beq.w	.2
	move.w	#3,(printx).w
.2
	bsr.w	DrawPadIcon
	bsr.w	DrawPadCursor
	addq.w	#2,a0
	addq.w	#3,(printy).w
	addq.w	#1,d7
	dbf	d4,.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawPadIcon	;IDA: sub_8CFF2. 95 only. Draw pad icon d7 (PadIconMaps at PadIconChars)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#PadIconMaps,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	movea.l	#PadIconChars,a1
	movea.l	(a1,d7.w),a1
	move.w	(a1),d4
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#2,d2
	moveq	#2,d3
	moveq	#4,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PadIconMaps	;IDA: unk_8D02C. 95 only. Pad icon bitmaps, then (PadIconChars) the RAM words with their chars
	dc.l	PadIconMap1,PadIconMap2,PadIconMap3,PadIconMap4

PadIconChars	;IDA: unk_8D03C
	dc.l	padiconchars1,padiconchars2,padiconchars3,padiconchars4

DrawPadCursor	;IDA: sub_8D04C. 95 only. Draw the pad cursor (PadCursorMap, padcursorchars) beside printx / printy
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(padcursorchars).w,d4
	movea.l	#PadCursorMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	addq.w	#4,(printx).w
	clr.w	d1
	subq.w	#1,(printy).w
	moveq	#7,d2
	moveq	#3,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	(sp)+,(printy).w
	move.w	(sp)+,(printx).w
	rts

BlankLineTxt	;IDA: unk_8D090. 95 only. A blank line
	String	$FD,$0,'                                        '

PrintPracticeTitle	;IDA: sub_8D0BC. 95 only. Practice Mode: print PracticePlayersTxt, highlighted (PrintSetupStrHi) when setupvalues is 0
	btst	#7,(sflags9).w
	beq.w	.1
	movea.l	#PracticePlayersTxt,a1
	tst.w	(setupvalues).w
	beq.w	.0
	bsr.w	PrintSetupStrHi
	bra.w	.1
.0
	bsr.w	PrintSetupStr
.1
	rts

PracticePlayersTxt	;IDA: unk_8D0E2. 95 only
	String	$FD,$C,$FC,$16,'PRACTICE PLAYERS',$FD,$19,$FC,$17,'No. of Players',$FD,$2,'No. of Players'

ControllerSetupScreen	;IDA: sub_8D11A. 95 only. Build the controller setup screen: vram, fonts, the team blocks and pad tiles, the backgrounds and
	;"Controller SetUp" (printbigz); the team blocks of VisTeam / HomeTeam (DrawSetupTeamBlock)
	move.l	#VBlank_SetOptions,(vbint).w
	move	#$2500,sr
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0
	jsr	(setvram).l
	jsr	(orjoy).l
	move.w	#1,d4
	move.w	d4,(smallfontchars).w
	movea.l	#RosterFont+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(smallfont2chars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$05,$23,$45,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(smallfont3chars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0D,$23,$45,$67,$89,$AB,$CD,$EF;remap table
	move.l	#RosterFont,(smallfontptr).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(teamblocksmapptr).w
	movea.l	#Teamblocksmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padcursorchars).w
	movea.l	#PadCursorMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padiconchars1).w
	movea.l	#PadIconMap1+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padiconchars2).w
	movea.l	#PadIconMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padiconchars3).w
	movea.l	#PadIconMap3+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padiconchars4).w
	movea.l	#PadIconMap4+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	(VisTeam).w,d1
	jsr	(printz).l
	String	$BF,2,6,0
	bsr.w	DrawSetupTeamBlock
	move.w	(HomeTeam).w,d1
	jsr	(printz).l
	String	$BF,$1B,6,0
	bsr.w	DrawSetupTeamBlock
	jsr	(printz).l
	String	$FE,0,0,0
	movea.l	#ControllerBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#3,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,$E,6,0
	movea.l	#ControllerTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$C,d2
	moveq	#2,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printbigz).l
	String	$BF,5,2,'Controller SetUp'
	rts

DrawSetupTeamBlock	;Wrong code in IDA. 95 only. Draw team block d1 (Teamblocksmap) at printx / printy
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d0
	asl.w	#1,d1
	move.w	(teamblocksmapptr).w,d4
	movea.l	#Teamblocksmap,a0
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	moveq	#2,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintSetupStr	;Wrong code in IDA. 95 only. Print String a1 (printz2 $FE,5,$FF,1,$F9,0, then printsmall)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a1,-(sp)
	jsr	(printz2).l
	String	$FE,5,$FF,1,$F9,0
	movea.l	(sp)+,a1
	jsr	(printsmall).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintSetupStrHi	;Wrong code in IDA. 95 only. The same highlighted ($F9,1)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a1,-(sp)
	jsr	(printz2).l
	String	$FE,5,$FF,1,$F9,1
	movea.l	(sp)+,a1
	jsr	(printsmall).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadAllPads	;Wrong code in IDA. 95 only. Read the 4 pads (nodiag) into TempWord1, TempWord2, TempRawSpd and TempMaxSpd
	;(the same RAM as scratch here), all of them ored in TempLegSpd
	jsr	(ReadJoy1).l
	jsr	(nodiag).l
	move.w	d1,(TempWord1).w
	jsr	(ReadJoy2).l
	jsr	(nodiag).l
	move.w	d1,(TempWord2).w
	jsr	(ReadJoy3).l
	jsr	(nodiag).l
	move.w	d1,(TempRawSpd).w
	jsr	(ReadJoy4).l
	jsr	(nodiag).l
	move.w	d1,(TempMaxSpd).w
	move.w	(TempWord1).w,d1
	or.w	(TempWord2).w,d1
	or.w	(TempRawSpd).w,d1
	or.w	(TempMaxSpd).w,d1
	move.w	d1,(TempLegSpd).w
	rts

