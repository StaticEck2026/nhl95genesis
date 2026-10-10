;	NHL 95 checks95_07. Retail $09E5F0-$09F58F (4000 bytes).
;	Mapped to checks94 (75%): puckshootout, SelectPenaltyShotSkater, puckpenshot, UpdatePenaltyShotEnd, EndPenaltyShotPlay; moved in:
;	SetupPenaltyShot (collide94), PenaltyShotBox / PenShotBigTxt (data94), PenShotChk / getBAplayerInfo (penalty94), ShortenMsgTimer
;	(period94), setInjuryType (collide94), getFgtbyte / chkFgtBit1 (title94), updatepwrplay / GetLowestPen (penalty94); 95 only: the season
;	injuries (SetSeasonInjuries ... DeleteInjurySlot, save RAM $20BCB8), CheckInjury and ClearPowerPlay.
;	IDA left puckshootout ... UpdatePenaltyShotEnd ($09E5F0-$09ECE5) and SetupPenaltyShot as dc.b; they are transcribed from the retail
;	bytes. IDA hid the printz / printbigz / appendz Strings as instructions.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

puckshootout	;no IDA label. checks94 puckshootout. Start a penalty shot or shootout attempt: the pads cleared, the shooter (NextShooter) or the path
	;(StartShootoutPath), the song, the goalies back, SelectPenaltyShotSkater; the puck assignment $20 (3 with no skater)
	bclr	#1,$62(a3)
	beq.w	.7
	bclr	#7,(sflags).w
	bset	#7,(sflags7).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	bclr	#7,(gmode2).w
	btst	#0,(gmode2).w
	beq.w	.0
	jsr	(NextShooter).l
	bra.w	.2
.0
	jsr	(StartShootoutPath).l
	move.l	a2,-(sp)
	movea.l	#HmShots,a2
	tst.w	(BA_Team).w
	beq.w	.1
	movea.l	#AwShots,a2
.1
	addq.w	#1,$362(a2)
	movea.l	(sp)+,a2
.2
	bclr	#2,(BA_PS_flags).w
	bclr	#4,(BA_PS_flags).w
	bclr	#5,(BA_PS_flags).w
	bclr	#6,(BA_PS_flags).w
	bset	#1,(sflags6).w
	btst	#3,(gmode).w
	beq.w	.3
	jmp	(Stop4Pen).l
.3
	bclr	#1,$62(a3)
	btst	#0,(gmode2).w
	beq.w	.4
	tst.w	(shootoutteam).w
	bne.w	.6
	tst.w	(homeshootnum).w
	bne.w	.6
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#2,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	(SongNum).w,-(sp)
	bra.w	.5
.4
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#2,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	(SongNum).w,-(sp)
.5
	jsr	(song).l
.6
	bset	#0,(gmode).w
	bset	#1,(gmode2).w
	clr.w	(puckvx).w
	clr.w	(puckvy).w
	move.w	#$19,(shootoutclock).w
	jsr	(ReturnGoalies).l
	st	$40(a3)
	st	$42(a3)
.7
	bset	#2,(BA_PS_flags).w
	movem.w	d1-d2,-(sp)
	jsr	(SelectPenaltyShotSkater).l
	bmi.w	.8
	movem.w	(sp)+,d1-d2
	bra.w	.9
.8
	movem.w	(sp)+,d1-d2
	bclr	#2,(BA_PS_flags).w
	move.w	#3,d0
	jsr	(assreplace).l
	rts
.9
	movem.w	d1-d2,-(sp)
	move.w	(BA_Goalie_SCnum).w,d0
	movea.l	#SortCords,a2
	asl.w	#7,d0
	adda.w	d0,a2
	tst.w	$34(a2)
	bne.w	.10
	btst	#2,$63(a2)
	beq.w	.14
.10
	move.w	(BA_Goalie_SCnum).w,d0
	move.w	#6,d2
.11
	subq.w	#1,d2
	bmi.s	.8
	subq.w	#1,d0
	bpl.w	.12
	move.w	#5,d0
	bra.w	.13
.12
	cmp.w	#5,d0
	bne.w	.13
	move.w	#$B,d0
.13
	movea.l	#SortCords,a2
	move.w	d0,d1
	asl.w	#7,d1
	adda.w	d1,a2
	tst.w	$34(a2)
	bne.s	.11
	btst	#2,$63(a2)
	bne.s	.11
	move.w	d0,(BA_Goalie_SCnum).w
.14
	movem.w	(sp)+,d1-d2
	movea.w	#(HmShots-M68K_RAM),a2
	move.w	#$20,d0
	jmp	(assreplace).l

SelectPenaltyShotSkater	;no IDA label. checks94 SelectPenaltyShotSkater. The best rated free skater of the shooting team (9 rating nibbles) in BA_Skater_Offset, a3 his sort object; d0 = 1, or -1 with none
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#HmShots,a0
	tst.w	(BA_Team).w
	beq.w	.0
	movea.l	#AwShots,a0
.0
	move.w	#0,d1
	move.w	#$FFFF,d6
	move.w	#$FFFF,d5
	movea.l	$1E(a0),a2
	adda.w	(a2),a2
.1
	cmpi.w	#2,(a2)
	beq.w	.5
	adda.w	(a2),a2
	move.w	d1,d7
	asl.w	#1,d7
	move.b	5(a2),d0
	andi.w	#$F,d0
	cmp.b	#1,d0
	ble.w	.4
	btst	#0,(gmode2).w
	bne.w	.6
	cmpi.w	#$FFFE,$68(a0,d7.w)
	beq.w	.2
	cmpi.w	#$FFFF,$68(a0,d7.w)
	bne.w	.4
.2
	clr.w	d3
	clr.w	d0
	move.b	1(a2),d0
	andi.w	#$F,d0
	add.w	d0,d3
	move.b	2(a2),d0
	andi.w	#$F,d0
	add.w	d0,d3
	move.b	2(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	move.b	3(a2),d0
	andi.w	#$F,d0
	add.w	d0,d3
	move.b	3(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	move.b	5(a2),d0
	andi.w	#$F,d0
	add.w	d0,d3
	move.b	5(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	move.b	6(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	move.b	7(a2),d0
	andi.w	#$F0,d0
	lsr.w	#4,d0
	add.w	d0,d3
	cmp.w	(BA_Skater_Offset).w,d1
	bne.w	.3
	move.w	#$7FFF,d3
.3
	cmp.w	d6,d3
	blt.w	.4
	move.w	d3,d6
	move.w	d1,d5
	bra.w	.4
.4
	addq.l	#8,a2
	addq.w	#1,d1
	cmp.w	#$1A,d1
	blt.w	.1
.5
	tst.w	d5
	bmi.w	.8
	move.w	d5,(BA_Skater_Offset).w
.6
	move.w	#0,(BA_Sktr_SCnum).w
	tst.w	(BA_Team).w
	beq.w	.7
	move.w	#6,(BA_Sktr_SCnum).w
.7
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a3
	adda.w	d0,a3
	move.w	(BA_Skater_Offset).w,d3
	bra.w	.9
.8
	move.w	#$FFFF,d0
	bra.w	.10
.9
	move.w	#1,d0
.10
	movem.l	(sp)+,d0-d7/a0-a6
	rts

puckpenshot	;no IDA label. checks94 puckpenshot. Penalty shot / shootout face-off: rink, puck and nets reset, the shooter at the puck and the goalie in the net, the others off the ice; without $62(a3) bit 1 resume play
	bclr	#1,$62(a3)
	beq.w	.21
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(forceblack).l
.0
	btst	#0,(disflags).w
	bne.s	.0
	cmpi.w	#$258,(crowdlevel).w
	bls.w	.1
	move.w	#$258,(crowdlevel).w
	addi.w	#$14,(CwdExciteLvl).w
.1
	move.w	(ExtraChars).w,d4
	movea.l	#RefTiles+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	bset	#3,(disflags).w
	bclr	#0,(sflags).w
	bclr	#0,(sflags3).w
	clr.w	(glovecords).w
	clr.b	(iflags).w
	st	(RefCnt).w
	bclr	#1,(sflags2).w
	st	(passplayer).w
	jsr	(RestoreGameScreen).l
	clr.w	(Vpos).w
	clr.w	(Hpos).w
	move.w	#0,(puckx).w
	move.w	#0,(pucky).w
	clr.w	(puckz).w
	clr.w	(puckvx).w
	clr.w	(puckvy).w
	clr.w	(puckvz).w
	st	(puckc).w
	movea.w	#(SortCords+(12*SCstruct)-M68K_RAM),a0
	clr.w	$28(a0)
	clr.w	$2A(a0)
	clr.w	(a0)
	move.w	#$112,$14(a0)
	adda.w	#$80,a0
	clr.w	$28(a0)
	clr.w	$2A(a0)
	clr.w	(a0)
	move.w	#$FEEE,$14(a0)
	movea.w	#(SortCords+((puckscnum+1)*SCstruct)-M68K_RAM),a0
	move.w	#$1B3,6(a0)
	clr.w	$58(a0)
	clr.w	4(a0)
	clr.w	(SortCords+(puckscnum*SCstruct)+attribute).w
	bclr	#6,(sflags).w
	moveq	#$64,d4
.2
	jsr	(checkwindow).l
	dbf	d4,.2
	move.w	#$3C,(yleader).w
	jsr	(ResetBench).l
	movea.w	#(HmShots-M68K_RAM),a2
	jsr	(SetPersonel).l
	bsr.w	SetupPenaltyShot
	adda.w	#$366,a2
	jsr	(SetPersonel).l
	bsr.w	SetupPenaltyShot
	jsr	(resetplstuff).l
	move.l	a3,-(sp)
	movea.l	#SortCords+(11*SCstruct),a3
	move.w	#$B,d2
.3
	cmp.w	(BA_Sktr_SCnum).w,d2
	beq.w	.4
	cmp.w	(BA_Goalie_SCnum).w,d2
	beq.w	.9
	move.w	#$FF10,(a3)
	clr.w	$14(a3)
	clr.w	6(a3)
	move.w	#$1D,d0
	jsr	(assinsert).l
	bra.w	.15
.4
	tst.w	$34(a3)
	bpl.w	.6
	bclr	#2,$63(a3)
	beq.w	.6
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d3
	move.b	$66(a3),d3
	jsr	(setplayer).l
	movem.l	(sp)+,d0-d7/a0-a6
	tst.w	$34(a3)
	beq.w	.5
	bpl.w	.6
.5
	nop
.6
	move.w	(puckx).w,d0
	subi.w	#0,d0
	move.w	d0,(a3)
	move.w	(pucky).w,d0
	btst	#7,$62(a3)
	bne.w	.7
	addi.w	#$10,d0
	move.w	#4,$54(a3)
	bra.w	.8
.7
	addi.w	#-$10,d0
	move.w	#0,$54(a3)
.8
	move.w	d0,$14(a3)
	clr.w	$28(a3)
	clr.w	$2A(a3)
	clr.w	$2C(a3)
	move.w	#$E,d0
	jsr	(assinsert).l
	bra.w	.15
.9
	btst	#0,(gmode2).w
	beq.w	.10
	move.b	(shootoutteam-1).w,$66(a3)
	tst.w	(shootoutteam).w
	beq.w	.11
	move.b	(homeshootnum-1).w,$66(a3)
	bra.w	.11
.10
	tst.w	$34(a3)
	bpl.w	.13
	bclr	#2,$63(a3)
	beq.w	.13
.11
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d3
	move.b	$66(a3),d3
	jsr	(setplayer).l
	movem.l	(sp)+,d0-d7/a0-a6
	tst.w	$34(a3)
	bne.w	.12
	bpl.w	.13
.12
	nop
.13
	bclr	#2,$63(a3)
	move.w	#0,d0
	move.w	#$E5,d1
	btst	#7,$62(a3)
	bne.w	.14
	move.w	#$FF1B,d1
.14
	move.w	d0,(a3)
	move.w	d1,$14(a3)
	clr.w	$28(a3)
	clr.w	$2A(a3)
	clr.w	$18(a3)
	sub.w	(puckx).w,d0
	sub.w	(pucky).w,d1
	neg.w	d0
	neg.w	d1
	jsr	(vtoa).l
	move.w	d0,$54(a3)
	bclr	#2,$63(a3)
	bclr	#5,$62(a3)
	move.w	#$B5C,d1
	jsr	(SetSPA).l
.15
	suba.l	#$80,a3
	dbf	d2,.3
	jsr	(SprSort).l
	movea.l	(sp)+,a3
	jsr	(AssignPads).l
	move.w	(BA_Goalie_SCnum).w,d0
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	move.w	#0,(a3)
	move.w	#$FF06,$14(a3)
	btst	#7,$62(a3)
	bne.w	.16
	move.w	#$FA,$14(a3)
.16
	move.w	(BA_Goalie_SCnum).w,d0
	move.w	#1,d1
	btst	#6,$62(a3)
	beq.w	.17
	move.w	#2,d1
.17
	cmp.w	(cont1team).w,d1
	bne.w	.18
	jsr	(setc1player).l
	bra.w	.19
.18
	cmp.w	(cont2team).w,d1
	bne.w	.19
	jsr	(setc2player).l
.19
	move.w	#6,d0
	jsr	(assreplace).l
	bset	#7,(BA_PS_flags).w
	bset	#2,(sflags2).w
	move.w	#$190,(msgtimer).w
	tst.w	(cont1team).w
	bne.w	.20
	tst.w	(cont2team).w
	bne.w	.20
	move.w	#$64,(msgtimer).w
.20
	move.w	#$18,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.21
	bset	#2,(gmode2).w
	move.w	#1,d0
	jsr	(assreplace).l
	clr.w	$28(a3)
	clr.w	$2A(a3)
	rts

PenShotTable	;no IDA label. checks94 puckpenshot data (94 has no label). Not used
	dc.b	0,1,2,3,4,5,6,0,0,1,5,3,4,2,0,0
	dc.b	0,3,5,1,4,0,0,0,0,0
	dc.w	$FF06,$FFDD,$FFCE,$0023,$FFCE,$FFCE,$FFF6,$0000,$FFF1,$0032,$FFF6,$0000,$FFC4

UpdatePenaltyShotEnd	;no IDA label. checks94 UpdatePenaltyShotEnd. The shot ends (BA_PS_flags bit 4) when the goalie has the puck, the loose puck timer or the clock runs out; the first time AddPenalty2 $A. Runs on into EndPenaltyShotPlay
	movem.w	d0,-(sp)
	move.w	(puckc).w,d0
	cmp.w	(BA_Goalie_SCnum).w,d0
	movem.w	(sp)+,d0
	beq.w	.2
	btst	#5,(BA_PS_flags).w
	beq.w	.3
	btst	#5,(gmode2).w
	bne.w	.0
	tst.w	(puckc).w
	bpl.w	.1
	bset	#5,(gmode2).w
.0
	tst.w	(puckc).w
	bpl.w	.2
.1
	tst.w	(passmodetimer).w
	bmi.w	.2
	subq.w	#1,(passmodetimer).w
	bra.w	.3
.2
	bset	#4,(BA_PS_flags).w
.3
	tst.w	(shootoutclock).w
	bne.w	.4
	bset	#4,(BA_PS_flags).w
.4
	btst	#4,(BA_PS_flags).w
	bne.w	.5
	rts
.5
	btst	#6,(BA_PS_flags).w
	bne.w	PenaltyShotEndReturn
	bset	#6,(BA_PS_flags).w
	move.w	#$A,d0
	jsr	(AddPenalty2).l

EndPenaltyShotPlay	;IDA: sub_9ECE6. checks94 EndPenaltyShotPlay. LockScroll, end the penalty shot play (the BA flags), the shooter newpnum back, then CountShootoutGoals
	jsr	(LockScroll).l
	btst	#0,(gmode2).w
	bne.w	.0
	move.w	#$A,(replaydelay).w
	bset	#2,(sflags2).w
.0
	bset	#0,(gmode).w
	bclr	#2,(gmode2).w
	bclr	#2,(BA_PS_flags).w
	bclr	#3,(BA_PS_flags).w
	bclr	#5,(BA_PS_flags).w
	bclr	#4,(BA_PS_flags).w
	bclr	#6,(BA_PS_flags).w
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	move.b	(savednewpnum).w,$61(a0,d0.w)
	movem.l	(sp)+,d0/a0
	jsr	(CountShootoutGoals).l

PenaltyShotEndReturn	;no IDA label. checks94 PenaltyShotEndReturn. Shared rts
	rts

SetupPenaltyShot	;no IDA label. collide94 SetupPenaltyShot. Penalty shot for team a2: the shooter plays center (BA_Skater_Offset), the goalie stays, the other players unavailable (assreplace $1D)
	movem.l	d0-d5/a0-a3,-(sp)
	movea.w	$22(a2),a3
	moveq	#5,d4
.0
	move.w	$52(a3),d0
	cmp.w	(BA_Sktr_SCnum).w,d0
	beq.w	.1
	cmp.w	(BA_Goalie_SCnum).w,d0
	beq.w	.2
	bset	#2,$63(a3)
	move.w	#$1D,d0
	jsr	(assreplace).l
	bra.w	.4
.1
	jsr	(Setplass).l
	move.b	$61(a3),(savednewpnum).w
	move.b	(BA_Skater_Offset+1).w,$61(a3)
	move.w	#4,$34(a3)
	bra.w	.3
.2
	jsr	(Setplass).l
	clr.w	$34(a3)
.3
	clr.w	d3
	move.b	$61(a3),d3
	add.w	d3,d3
	move.w	#$FFFF,$68(a2,d3.w)
	lsr.w	#1,d3
	jsr	(setplayer).l
.4
	st	$61(a3)
	st	$60(a3)
	adda.w	#$80,a3
	dbf	d4,.0
	movem.l	(sp)+,d0-d5/a0-a3
	rts

PenaltyShotBox	;IDA: sub_9EDD2. data94 PenaltyShotBox. In a shootout PlayoffRoundScreen; else the "PENALTY SHOT!" box: the shooter, the penalty (PenaltyNames) and " by" the checker
	bset	#7,(gmode2).w
	btst	#0,(gmode2).w
	beq.w	.0
	jmp	(PlayoffRoundScreen).l
.0
	movem.l	d0-d2/a0-a4,-(sp)
	move.w	#$FFFF,d0
	jsr	(prefmes).l
	jsr	(printz).l
	String	$BF,$3,$2,$0
	moveq	#$1B,d0
	moveq	#8,d1
	jsr	(Framer).l
	lea	PenShotBigTxt(pc),a1
	jsr	(printbig1).l
	move.w	(BA_Sktr_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a2
	adda.w	d0,a2
	clr.w	d0
	move.b	$66(a2),d0
	movea.l	#HmShots,a2
	tst.w	(BA_Team).w
	beq.w	.1
	movea.l	#AwShots,a2
.1
	jsr	(FormatPlayerNameWithAttrib).l
	jsr	(print).l
	jsr	(printz).l
	String	$BF,$4,$7,$0
	movem.l	a1/a3,-(sp)
	move.w	(pspenalty).w,d0
	movea.l	#PenaltyNames,a1
	adda.w	(a1,d0.w),a1
	lea	2(a1),a1
	jsr	(print).l
	movem.l	(sp)+,a1/a3
	jsr	(printz).l
	String	' by',$BF,$4,$8
	move.w	(BA_Checker_Offset).w,d0
	movea.l	#AwShots,a2
	tst.w	(BA_Team).w
	beq.w	.2
	movea.l	#HmShots,a2
.2
	jsr	(FormatPlayerNameWithAttrib).l
	jsr	(print).l
	movem.l	(sp)+,d0-d2/a0-a4
	rts

PenShotBigTxt	;IDA: unk_9EEAE. data94 PenShotBigTxt. PenaltyShotBox big text
	String	$BF,$4,$3,'PENALTY SHOT!',$BF,$4,$5,$0

PenShotChk	;IDA: sub_9EEC4. penalty94 PenShotChk. A breakaway shooter hit: a penalty shot when penalty d0 allows one (PenShotPenalties); d0 = the penalty
	movem.l	d1-d3/a0,-(sp)
	btst	#1,$64(a2)
	beq.w	.0
	btst	#3,(gmode).w
	bne.w	.0
	movem.w	d2,-(sp)
	move.w	(PBnum).w,d2
	andi.w	#$FF00,d2
	movem.w	(sp)+,d2
	bne.w	.0
	btst	#3,(BA_PS_flags).w
	beq.w	.1
.0
	move.w	#$FFFF,d1
	bra.w	.3
.1
	movea.l	#PenShotPenalties,a0
	move.w	(a0,d0.w),d1
	bmi.w	.3
	move.w	$52(a2),d2
	movem.w	d0-d1,-(sp)
	move.w	d2,d0
	jsr	(getBAplayerInfo).l
	movem.w	(sp)+,d0-d1
	bpl.w	.2
	bclr	#3,(BA_PS_flags).w
	bra.s	.0
.2
	move.w	d1,(pspenalty).w
	move.w	d1,d0
.3
	movem.l	(sp)+,d1-d3/a0
	rts

getBAplayerInfo	;IDA: sub_9EF3C. penalty94 getBAplayerInfo. Keep the breakaway shooter, team, goalie and checker for the penalty shot; N clear when set
	movem.l	d1-d3/a1,-(sp)
	tst.w	(OptPen).w
	beq.w	.4
	bset	#3,(BA_PS_flags).w
	movem.w	d0,-(sp)
	move.w	#5,d1
	move.w	#0,d2
	cmp.w	#5,d0
	bgt.w	.0
	move.w	#$B,d1
	move.w	#1,d2
.0
	move.w	d1,d0
	jsr	(FindGoalie).l
	tst.w	d0
	bpl.w	.1
	movem.w	(sp)+,d0
	bclr	#3,(BA_PS_flags).w
	bra.w	.3
.1
	move.w	d0,d1
	move.w	(sp)+,d0
	move.w	d0,(BA_Sktr_SCnum).w
	movea.l	#SortCords,a1
	move.w	d0,d3
	asl.w	#7,d3
	move.w	#0,(BA_Team).w
	btst	#6,$62(a1,d3.w)
	beq.w	.2
	move.w	#1,(BA_Team).w
.2
	move.w	#0,(BA_Skater_Offset).w
	move.b	$66(a1,d3.w),(BA_Skater_Offset+1).w
	move.w	d1,(BA_Goalie_SCnum).w
	asl.w	#7,d1
	move.w	#0,(BA_Goalie_Offset).w
	move.b	$66(a1,d1.w),(BA_Goalie_Offset+1).w
	move.w	#0,(BA_Checker_Offset).w
	move.b	$66(a3),(BA_Checker_Offset+1).w
.3
	movem.l	(sp)+,d1-d3/a1
	rts
.4
	move.w	#$FFFF,d1
	bra.s	.3

ShortenMsgTimer	;IDA: sub_9EFE4. period94 ShortenMsgTimer. Cap the message timer at 2, unless a second pad is on and a3 is not the puck carrier
	movem.l	d0,-(sp)
	tst.w	(cont2team).w
	beq.w	.0
	move.w	$52(a3),d0
	cmp.w	(puckc).w,d0
	bne.w	.1
.0
	cmpi.w	#2,(msgtimer).w
	ble.w	.1
	move.w	#2,(msgtimer).w
.1
	movem.l	(sp)+,d0
	rts

setInjuryType	;IDA: sub_9F012. collide94 setInjuryType. a2 injured: out for the period ($FFFD) or the game ($FFFC); in a season a random games count (SetInjuryGames)
	bclr	#1,(sflags12).w
	move.w	d0,-(sp)
	bset	#2,$63(a2)
	addi.w	#$12C,(crowdlevel).w
	addi.w	#$1E,(CwdExciteLvl).w
	move.w	#$D,-(sp)
	jsr	(sfx).l
	clr.w	$28(a2)
	clr.w	$2A(a2)
	move.w	(a2),(xc1).w
	move.w	$14(a2),(yc1).w
	bset	#6,(sflags).w
	clr.w	d1
	movea.w	#(HmShots-M68K_RAM),a0
	btst	#6,$62(a2)
	beq.w	.0
	move.w	#$8000,d1
	adda.w	#$366,a0
.0
	move.b	$66(a2),d1
	move.w	d1,(TempPlOffset).w
	ext.w	d1
	add.w	d1,d1
	btst	#1,(sflags13).w
	bne.w	.1
	exg	a2,a3
	jsr	(getFgtbyte).l
	exg	a2,a3
	tst.w	d0
	bne.w	.1
	bclr	#5,(sflags7).w
	move.w	#$FFFD,$68(a0,d1.w)
	bra.w	.4
.1
	cmp.w	#3,d0
	beq.w	.2
	bclr	#5,(sflags7).w
	move.w	#$FFFD,$68(a0,d1.w)
	jsr	(chkFgtBit1).l
	beq.w	.4
.2
	bset	#5,(sflags7).w
	move.w	#$FFFC,$68(a0,d1.w)
	btst	#3,(GameFlags).w
	beq.w	.4
	btst	#2,(SeasonDay+1).w
	beq.w	.4
	move.w	#$64,d0
	jsr	(randomd0).l
	cmp.w	#$32,d0
	blt.w	.4
	movem.w	d1,-(sp)
	clr.w	d0
	move.b	(SeasonLength).w,d0
	clr.w	d1
	move.b	(SeasonDay).w,d1
	sub.w	d1,d0
	movem.w	(sp)+,d1
	cmp.w	#2,d0
	blt.w	.4
	subq.w	#1,d0
	cmp.w	#5,d0
	ble.w	.3
	move.w	#5,d0
.3
	jsr	(randomd0).l
	addq.w	#1,d0
	movem.l	d1/d7,-(sp)
	move.w	$28(a0),d7
	move.w	(TempPlOffset).w,d1
	andi.w	#$FF,d1
	bset	#1,(sflags13).w
	jsr	(SetInjuryGames).l
	movem.l	(sp)+,d1/d7
.4
	move.w	(sp)+,d0
	rts

SetSeasonInjuries	;IDA: sub_9F144. 95 only. The players of team a2 with injury games left (save RAM $20BCB8) are out ($FFFC)
	movem.l	d0-d3/a0/a2,-(sp)
	movea.l	#$20BCB8,a0
	move.w	$28(a2),d0
	mulu.w	#$1C,d0
	adda.l	d0,a0
	adda.w	#$68,a2
	move.w	#$19,d3
.0
	move.w	(a0),d1
	andi.w	#$F0,d1
	beq.w	.1
	move.w	#$FFFC,(a2)
.1
	addq.w	#2,a2
	subq.w	#1,d3
	bmi.w	.3
	move.w	(a0),d1
	andi.w	#$F,d1
	beq.w	.2
	move.w	#$FFFC,(a2)
.2
	addq.w	#2,a2
	addq.w	#2,a0
	dbf	d3,.0
.3
	movem.l	(sp)+,d0-d3/a0/a2
	rts

TickTeamInjuries	;IDA: sub_9F192. 95 only. A game played: one injury game off for teams d0 and d1 (TickInjuries), save RAM checksum
	movem.l	d2-d4/a0,-(sp)
	bsr.w	TickInjuries
	move.w	d1,d0
	bsr.w	TickInjuries
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d2-d4/a0
	rts

TickInjuries	;IDA: sub_9F1AC. 95 only. One game off every injury of team d0 (save RAM $20BCB8, a nibble per player)
	movea.l	#$20BCB8,a0
	mulu.w	#$1C,d0
	adda.l	d0,a0
	move.w	#$C,d2
.0
	move.w	(a0),d3
	andi.w	#$F,d3
	beq.w	.1
	subq.w	#1,d3
	andi.w	#$F0,(a0)
	or.w	d3,(a0)
.1
	move.w	(a0),d3
	andi.w	#$F0,d3
	beq.w	.2
	subi.w	#$10,d3
	andi.w	#$F,(a0)
	or.w	d3,(a0)
.2
	addq.w	#2,a0
	dbf	d2,.0
	rts

SetInjuryGames	;IDA: sub_9F1EA. 95 only. Injury games d0 for player d1 of team d7 (save RAM $20BCB8); sflags12 bit 1 and injurygames
	movem.l	d0-d7/a0-a7,-(sp)
	bset	#1,(sflags12).w
	move.w	d0,(injurygames).w
	mulu.w	#$1C,d7
	movea.l	#$20BCB8,a0
	adda.l	d7,a0
	move.w	d1,d2
	lsr.w	#1,d2
	add.w	d2,d2
	move.w	(a0,d2.w),d3
	btst	#0,d1
	bne.w	.0
	andi.w	#$F,d3
	asl.w	#4,d0
	or.w	d0,d3
	bra.w	.1
.0
	andi.w	#$F0,d3
	or.w	d0,d3
.1
	move.w	d3,(a0,d2.w)
	movem.l	(sp)+,d0-d7/a0-a7
	rts

GetInjuryGames	;IDA: sub_9F232. 95 only. d0 = the injury games of player d1 of team d7 (save RAM $20BCB8)
	movem.l	d1-d7/a0,-(sp)
	movea.l	#$20BCB8,a0
	mulu.w	#$1C,d7
	adda.l	d7,a0
	move.w	d1,d2
	lsr.w	#1,d2
	add.w	d2,d2
	move.w	(a0,d2.w),d0
	btst	#0,d1
	bne.w	.0
	lsr.w	#4,d0
.0
	andi.w	#$F,d0
	movem.l	(sp)+,d1-d7/a0
	rts

getFgtbyte	;IDA: sub_9F260. title94 getFgtbyte. d0 = $74(a2) / 4
	clr.w	d0
	move.b	$74(a2),d0
	lsr.w	#2,d0
	rts

chkFgtBit1	;IDA: sub_9F26A. title94 chkFgtBit1. 95: Z from bit 1 of a random 0-99 (94 tested bit 1 of $74(a2))
	movem.w	d0,-(sp)
	move.w	#$64,d0
	jsr	(randomd0).l
	btst	#1,d0
	movem.w	(sp)+,d0
	rts

CheckInjury	;IDA: sub_9F282. 95 only. The injury message when its timer runs out: "Injury to:" the player, "Out for period", "game" or n "games"
	subq.w	#1,(InjCntDown).w
	beq.w	.0
	rts
.0
	btst	#1,(sflags12).w
	beq.w	.1
	jsr	(MakeSRAMChecksum).l
.1
	movem.l	d0-d2/a0-a4,-(sp)
	jsr	(printz).l
	String	$BF,$B,$3,$0
	moveq	#$12,d0
	moveq	#5,d1
	jsr	(Framer).l
	btst	#1,(sflags12).w
	bne.w	.3
	btst	#5,(sflags7).w
	bne.w	.2
	jsr	(printz).l
	String	$BF,$C,$4,'Injury to:',$BF,$C,$6,'Out for period',$BF,$C,$5,$0
	bra.w	.6
.2
	jsr	(printz).l
	String	$BF,$C,$4,'Injury to:',$BF,$C,$6,'Out for game',$BF,$C,$5,$0
	bra.w	.6
.3
	jsr	(printz).l
	String	$BF,$C,$4,'Injury to:',$BF,$C,$6,'Out for '
	move.w	(injurygames).w,d0
	move.w	#1,d1
	jsr	(PushNumberWidth).l
.4
	jsr	(print).l
	cmpi.w	#1,(injurygames).w
	bgt.w	.5
	jsr	(printz).l
	String	' game',$BF,$C,$5
	bra.w	.6
.5
	jsr	(printz).l
	String	' games',$BF,$C,$5,$0
.6
	jsr	(GetTempPlayerNameAttrib).l
	jsr	(print).l
	btst	#0,(puck_pflags2).w
	beq.w	.7
	jsr	(printz).l
	String	$BF,$14,$6,'the game',$0
.7
	movem.l	(sp)+,d0-d2/a0-a4
	rts

InsertInjurySlot	;IDA: sub_9F3B8. 95 only. Open an injury slot at player d1 of team d7 (the later nibbles up one); a player traded in
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$20BCB8,a0
	mulu.w	#$1C,d7
	adda.l	d7,a0
	adda.l	#$18,a0
	move.w	#$19,d3
.0
	move.w	(a0),d0
	subq.w	#2,a0
	cmp.w	d1,d3
	ble.w	.1
	asr.w	#4,d0
	andi.w	#$F,d0
.1
	subq.w	#1,d3
	bmi.w	.3
	cmp.w	d1,d3
	ble.w	.2
	move.w	(a0),d4
	asl.w	#4,d4
	andi.w	#$F0,d4
	andi.w	#$F,d0
	or.w	d4,d0
.2
	andi.w	#$FF,d0
	move.w	d0,2(a0)
	dbf	d3,.0
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DeleteInjurySlot	;IDA: sub_9F40E. 95 only. Remove the injury slot of player d1 of team d7 (the later nibbles down one); a player traded out
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$20BCB8,a0
	mulu.w	#$1C,d7
	adda.l	d7,a0
	move.w	#$D,d2
	clr.w	d3
.0
	move.w	(a0)+,d0
	cmp.w	d1,d3
	blt.w	.1
	asl.w	#4,d0
.1
	subq.w	#1,d2
	bmi.w	.3
	addq.w	#1,d3
	cmp.w	d1,d3
	blt.w	.2
	move.w	(a0),d4
	asr.w	#4,d4
	andi.w	#$F,d4
	andi.w	#$F0,d0
	or.w	d4,d0
.2
	andi.w	#$FF,d0
	move.w	d0,-2(a0)
	addq.w	#1,d3
	dbf	d2,.0
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

updatepwrplay	;IDA: sub_9F45E. penalty94 updatepwrplay. The power play box: the team and the time left (GetLowestPen)
	btst	#1,(gmode2).w
	bne.w	rtsPowerPlay
	movea.w	#(HmShots-M68K_RAM),a2
	lea	$366(a2),a3
	move.w	$24(a2),d0
	sub.w	$24(a3),d0
	beq.w	ClearPowerPlay
	bpl.w	.0
	btst	#6,(sflags2).w
	bne.w	.1
	bsr.w	ClearPowerPlay
	bset	#6,(sflags2).w
	bra.w	.1
.0
	exg	a2,a3
	btst	#6,(sflags2).w
	beq.w	.1
	bsr.w	ClearPowerPlay
	bclr	#6,(sflags2).w
.1
	bset	#5,(sflags2).w
	bne.w	.4
	addq.w	#1,4(a3)
	cmpa.w	#$C288,a3
	bne.w	.3
.2
	bra.w	.4
.3
	bra.s	.2
.4
	jsr	(printz).l
	String	$BF,$1,$19,'   ',$16,$17,$18,$19,$BF,$1,$1A,'  ',$0
	bsr.w	GetLowestPen
	jsr	(PushTime).l
	jsr	(print).l
	movea.l	$1E(a3),a0
	movea.w	#(mesarea-M68K_RAM),a3
	move.w	#2,(a3)
	jsr	(appendz).l
	String	$BF,$1,$19,$0
	adda.w	4(a0),a0
	adda.w	(a0),a0
	movea.l	a0,a1
	jsr	(appstring).l
	movea.w	a3,a1
	jmp	(print).l

ClearPowerPlay	;IDA: sub_9F520. 95 only. Clear the power play box (sflags2 bit 5)
	bclr	#5,(sflags2).w
	beq.w	rtsPowerPlay
	jsr	(printz).l
	String	$BF,$1,$19,' '
	jmp	(EASNLogo).l

rtsPowerPlay	;IDA: locret_9F53C. 95 only. Shared rts of updatepwrplay / ClearPowerPlay
	rts

GetLowestPen	;IDA: sub_9F53E. penalty94 GetLowestPen. a2 = shorthanded team, a3 = team on the power play. d0 = power play time left from the penalty box times
	clr.w	d0
	clr.w	d3
	lea	$9C(a2),a0
.0
	clr.w	d2
	move.b	(a0)+,d2
	bmi.w	.1
	move.w	$68(a2,d2.w),d2
	btst	#$E,d2
	bne.s	.0
	sub.w	d3,d2
	add.w	d2,d0
	move.w	d2,d3
	bra.s	.0
.1
	cmpi.w	#6,$24(a3)
	beq.w	.3
	sub.w	d3,d0
	lea	$9C(a3),a0
	clr.w	d2
.2
	move.b	(a0)+,d2
	bmi.w	.3
	btst	#6,$68(a3,d2.w)
	bne.s	.2
	cmp.w	$68(a3,d2.w),d0
	blt.w	.3
	add.w	d3,d0
.3
	andi.w	#$FF,d0
	rts
