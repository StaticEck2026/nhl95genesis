;	NHL 95 shootout95. Retail $09DD3E-$09E5EF (2226 bytes).
;	Mapped to shootout94 (85%): NextShooter, CountShootoutGoals, EndShootout (period94), PlayoffRoundScreen and RoundBigTxt (records94),
;	ShootoutWonBy, ShootoutSetup (94 ShootoutShooters) ... PrintShooterNames (the shootout shooters screen).
;	IDA left NextShooter ($09DD3E) and ShootoutWonBy+$50 ... PrintShooterNames ($09E036-$09E5EF) as dc.b; they are transcribed from
;	the retail bytes. IDA hid the printz / printz2 / printbigz Strings as instructions.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches
;	the cmp encoding after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

NextShooter	;no IDA label. shootout94 NextShooter. Shootout: the next shooter (BA_Team, BA_Goalie_SCnum, StartShootoutPath), or the end
	;(ExitToOpening)
	btst	#3,(gmode2).w
	beq.w	.0
	jmp	(ExitToOpening).l
.0
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	StartShootoutPath
	move.w	(shootoutteam).w,(BA_Team).w
	move.w	#$B,(BA_Goalie_SCnum).w
	movea.l	#homeshooters,a0
	tst.w	(shootoutteam).w
	beq.w	.1
	move.w	#5,(BA_Goalie_SCnum).w
	movea.l	#awayshooters,a0
.1
	move.w	(homeshootnum).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),(BA_Skater_Offset).w
	bclr	#2,(SortCords+(puckscnum*SCstruct)+pflags).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
CountShootoutGoals	;IDA: sub_9DD94. shootout94 CountShootoutGoals. Shootout: count the goals and end it when one team cannot catch up
	;(EndShootout)
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#0,(shootoutteam+1).w
	beq.w	.0
	cmpi.w	#5,(playoffround).w
	blt.w	.0
	move.w	(sohomegoals).w,d0
	cmp.w	(soawaygoals).w,d0
	beq.w	.0
	bset	#3,(gmode2).w
	jsr	(EndShootout).l
	bra.w	.x
.0
	eori.w	#1,(shootoutteam).w
	bne.w	.x
	addq.w	#1,(homeshootnum).w
	cmpi.w	#5,(homeshootnum).w
	blt.w	.1
	clr.w	(homeshootnum).w
.1
	addq.w	#1,(playoffround).w
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts
EndShootout	;IDA: sub_9DDEE. period94 EndShootout. Shootout over: LockScroll, then the 5 skaters of player slots 1-5 (sohomegoals >
	;soawaygoals) or 7-$B are set up (setplayer) above or below the view and get assscore (assinsert 7)
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#2,(sflags2).w
	jsr	(LockScroll).l
	move.w	#$60,(shootoutdelay).w
	movea.l	#SortCords,a3
	move.w	#0,d0
	move.w	(sohomegoals).w,d2
	cmp.w	(soawaygoals).w,d2
	bgt.w	.0
	move.w	#6,d0
.0
	asl.w	#7,d0
	adda.w	d0,a3
	move.w	#4,d2
	move.w	#6,d3
	bra.w	.2
.loop
	movem.w	d2-d3,-(sp)
	jsr	(setplayer).l
	move.w	#2,$34(a3)
	move.w	#$F0,d0
	tst.w	(Vpos).w
	bmi.w	.1
	move.w	#$FF10,d0
.1
	add.w	(Vpos).w,d0
	move.w	d0,$14(a3)
	move.w	#0,(a3)
	move.w	#$1C,d0	;assscore
	jsr	(assinsert).l
	bclr	#5,$62(a3)
	bclr	#1,$63(a3)
	bclr	#2,$62(a3)
	movem.w	(sp)+,d2-d3
.2
	adda.l	#$80,a3
	dbf	d2,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
PlayoffRoundScreen	;IDA: loc_9DE8A. records94 PlayoffRoundScreen. Shootout round box: "SHOOTOUT MODE" (RoundBigTxt), the shooter " vs." the
	;goalie, the goals of both teams and the round
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$FFFF,d0
	jsr	(prefmes).l
	jsr	(printz).l
	String	$BF,$3,$2,$0
	moveq	#$1B,d0
	moveq	#$C,d1
	jsr	(Framer).l
	lea	RoundBigTxt(pc),a1
	jsr	(printbig1).l
	move.w	(BA_Skater_Offset).w,d0
	movea.l	#HmShots,a2
	tst.w	(BA_Team).w
	beq.w	.0
	movea.l	#AwShots,a2
.0
	jsr	(FormatPlayerNameWithAttrib).l
	move.w	(printx).w,-(sp)
	jsr	(print).l
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
	addq.w	#6,(printx).w
	jsr	(printz).l
	String	' vs.',$BF,$4,$7,$0
	move.w	(BA_Goalie_SCnum).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a2
	adda.w	d0,a2
	clr.w	d0
	move.b	$66(a2),d0
	movea.l	#AwShots,a2
	tst.w	(BA_Team).w
	beq.w	.1
	movea.l	#HmShots,a2
.1
	jsr	(FormatPlayerNameWithAttrib).l
	jsr	(print).l
	jsr	(printz).l
	String	$BF,$4,$9,$0
	movea.l	#HmShots,a1
	movea.l	$1E(a1),a1
	adda.w	4(a1),a1
	jsr	(print).l
	move.w	#$15,(printx).w
	move.w	(sohomegoals).w,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	jsr	(printz).l
	String	$BF,$4,$A,$0
	movea.l	#AwShots,a1
	movea.l	$1E(a1),a1
	adda.w	4(a1),a1
	jsr	(print).l
	move.w	#$15,(printx).w
	move.w	(soawaygoals).w,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	jsr	(printz).l
	String	$BF,$4,$C,'Round ',$0
	move.w	(playoffround).w,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
RoundBigTxt	;IDA: unk_9DFD0. records94 RoundBigTxt. PlayoffRoundScreen big text
	String	$BF,$4,$3,'SHOOTOUT MODE',$BF,$4,$5,$0
ShootoutWonBy	;IDA: sub_9DFE6. shootout94 ShootoutWonBy. Shootout: "SHOOTOUT WON BY" and the winning team (printbig1)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$1,$D,$0
	move.w	#6,d1
	move.w	#$1E,d0
	jsr	(Framer).l
	jsr	(printbigz1).l
	String	$BF,$2,$E,'SHOOTOUT WON BY'
	addq.w	#2,(printy).w
	move.w	(HomeTeam).w,d1
	move.w	(sohomegoals).w,d0
	cmp.w	(soawaygoals).w,d0
	bgt.w	.0
	move.w	(VisTeam).w,d1
.0
	asl.w	#2,d1
	movea.l	#TeamList,a1
	movea.l	(a1,d1.w),a1
	adda.w	4(a1),a1
	move.w	#2,(printx).w
	jsr	(printbig1).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ShootoutSetup	;no IDA label. shootout94 ShootoutShooters. Pause menu SHOOTOUT SETUP: pick the 5 shooters and the goalie of team a2
	btst	#0,(gmode2).w
	beq.w	ShootersExit
	moveq	#0,d0
	moveq	#$1C,d1
	move.l	#PlayerSelectMap1,(screenarg).l
	jsr	(DrawTeamScreen6).l
	clr.w	(DispAttribCtr).w
	clr.w	(PlayerScrollCtr).w
	jsr	(printz2).l
	String	$FF,$2,$FD,$0,$FC,$0
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(LineEditorBg).l
	bsr.w	PrintShooterSlots
	move.w	#0,(TestList).w
ShootersRedraw	;no IDA label. shootout94 ShootersRedraw. Shootout shooters: redraw (ShootersBackground, PrintShooterNames, PrintShooterBox)
	bsr.w	ShootersBackground
	bsr.w	PrintShooterNames
	bsr.w	PrintShooterBox
ShootersLoop	;no IDA label. shootout94 ShootersLoop. Shootout shooters: the input loop
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	bne.w	ShootersExit
	move.w	#1,d0
	btst	#1,d1
	bne.w	ShootersMove
	move.w	#$FFFF,d0
	btst	#0,d1
	bne.w	ShootersMove
	move.w	#0,d0
	btst	#2,d1
	bne.w	ShootersPick
	move.w	#5,d0
	btst	#3,d1
	bne.w	ShootersPick
	btst	#5,d1
	bne.w	ShooterSelectList
	bra.s	ShootersLoop
ShootersExit	;no IDA label. shootout94 ShootersExit. Leave (ExitAttributeScreen2)
	jmp	(ExitAttributeScreen2).l
ShooterSelectList	;no IDA label. shootout94 ShooterSelectList. Shootout shooters: the "{Select  Player}" list for slot TestList (skaters, or the
	;goalies for slot 5)
	move.w	#$C000,d7
	movea.l	#homeshooters,a0
	cmpa.l	#HmShots,a2
	beq.w	.0
	movea.l	#awayshooters,a0
.0
	move.w	(TestList).w,d0
	asl.w	#1,d0
	move.w	(a0,d0.w),d6
	jsr	(ReadAttributeNibble).l
	move.w	d0,d1
	jsr	(GetPlayerCount).l
	sub.w	d1,d0
	subq.w	#1,d0
	cmpi.w	#5,(TestList).w
	bne.w	.1
	move.w	d1,d0
	subq.w	#1,d0
	clr.w	d1
.1
	move.w	d0,(screentimer).w
	clr.w	(PlayerScrollCtr).w
	clr.w	(VertLineScrolling).w
	movea.w	#(Satt-M68K_RAM),a0
	clr.w	d2
.loop
	move.b	d1,(a0,d2.w)
	cmp.w	d1,d6
	bne.w	.2
	move.w	d2,(VertLineScrolling).w
.2
	addq.w	#1,d1
	addq.w	#1,d2
	dbf	d0,.loop
	jsr	(PlayerSelectBg).l
	jsr	(ClearShooterScreen).l
	jsr	(printz2).l
	String	$F8,$0,$3,$1,$0,$0
	moveq	#$12,d0
	moveq	#3,d1
	jsr	(printz2).l
	String	$FD,$15,$FC,$0
	moveq	#$12,d0
	moveq	#3,d1
	jsr	(printz2).l
	String	$F8,$4,$2,$2,$1,'{Select  Player}',$0
	clr.w	d0
	bra.w	.6
.loop2
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	beq.w	.3
	jsr	(LineEditorBg).l
	bra.w	ShootersRedraw
.3
	btst	#5,d1
	bne.w	.10
	moveq	#1,d0
	btst	#1,d1
	bne.w	.6
	btst	#3,d1
	bne.w	.4
	moveq	#-1,d0
	btst	#0,d1
	bne.w	.6
	btst	#2,d1
	bne.w	.4
	bra.s	.loop2
.4
	add.w	(DispAttribCtr).w,d0
	bmi.s	.loop2
	move.w	d0,(DispAttribCtr).w
	bsr.w	PrintShooterList
	bra.s	.loop2
.6
	add.w	(VertLineScrolling).w,d0
	bmi.s	.loop2
	cmp.w	(screentimer).w,d0
	bgt.s	.loop2
	move.w	d0,(VertLineScrolling).w
	cmp.w	(PlayerScrollCtr).w,d0
	bgt.w	.8
	move.w	d0,(PlayerScrollCtr).w
.8
	subq.w	#5,d0
	cmp.w	(PlayerScrollCtr).w,d0
	ble.w	.9
	move.w	d0,(PlayerScrollCtr).w
.9
	bsr.w	PrintShooterList
	bra.w	.loop2
.10
	movea.w	#(Satt-M68K_RAM),a3
	adda.w	(VertLineScrolling).w,a3
	clr.w	d0
	move.b	(a3),d0
	move.w	(TestList).w,d2
	movea.l	#homeshooters,a0
	cmpa.l	#HmShots,a2
	beq.w	.11
	movea.l	#awayshooters,a0
.11
	asl.w	#1,d2
	move.w	d0,(a0,d2.w)
	jsr	(LineEditorBg).l
	bra.w	ShootersRedraw
PrintShooterList	;no IDA label. shootout94 PrintShooterList. Shootout shooters: the player list rows (getNameandAttrib); the selected row in
	;printa d7 ($E000 with BA_PS_flags bit 1)
	jsr	(printz).l
	String	$BE,$16,$1,$0
.loop
	movea.l	#PAttribOverall,a1
	cmpi.w	#5,(TestList).w
	bne.w	.0
	movea.l	#GAttribOverall,a1
.0
	move.w	(DispAttribCtr).w,d0
	bra.w	.1
.loop2
	adda.w	(a1),a1
	addq.w	#4,a1
.1
	tst.w	(a1)
	dbmi	d0,.loop2
	bpl.w	.2
	subq.w	#1,(DispAttribCtr).w
	bra.s	.loop
.2
	cmpa.l	#PAttribOverall,a1
	bne.w	.3
	movea.l	#ShooterOverallTxt,a1
.3
	cmpa.l	#GAttribOverall,a1
	bne.w	.4
	movea.l	#ShooterOverallTxt2,a1
.4
	jsr	(print).l
	move.l	(a1),d4
	movea.w	#(Satt-M68K_RAM),a3
	move.w	(PlayerScrollCtr).w,d2
	move.w	(screentimer).w,d1
	sub.w	d2,d1
	cmp.w	#5,d1
	bls.w	.5
	moveq	#5,d1
.5
	move.w	#2,(printy).w
.loop3
	jsr	(printz2).l
	String	$FE,$4,$FD,$5,$FA,$1,'                      ',$FD,$5
	cmp.w	(VertLineScrolling).w,d2
	bne.w	.6
	move.w	d7,(printa).w
	cmp.w	#$C000,d7
	bne.w	.6
	btst	#1,(BA_PS_flags).w
	beq.w	.6
	move.w	#$E000,(printa).w
.6
	clr.w	d0
	move.b	(a3,d2.w),d0
	jsr	(getNameandAttrib).l
	addq.w	#1,d2
	dbf	d1,.loop3
	rts
ShooterOverallTxt	;no IDA label. shootout94 ShooterOverallTxt. PrintShooterList heading, then the attribute long (d4)
	String	'    Overall    ]'
	dc.w	$1F3A,$A
ShooterOverallTxt2	;no IDA label. shootout94 ShooterOverallTxt2. PrintShooterList goalie heading, then the attribute long (d4)
	String	'    Overall    ]'
	dc.w	$1B0F,$A
ShootersPick	;no IDA label. shootout94 ShootersPick. Shootout shooters: C on a slot; the same slot (TestList) goes back to the loop, else
	;select it (ShootersSelect)
	cmp.w	(TestList).w,d0
	beq.w	ShootersLoop
	bra.w	ShootersSelect
ShootersMove	;no IDA label. shootout94 ShootersMove. Shootout shooters: move the slot cursor by d0, wrapping in 0 ... 4 (not on slot 5)
	cmpi.w	#5,(TestList).w
	beq.w	ShootersLoop
	add.w	(TestList).w,d0
	bmi.w	.0
	cmp.w	#5,d0
	blt.w	ShootersSelect
	clr.w	d0
	bra.w	ShootersSelect
.0
	move.w	#4,d0
ShootersSelect	;no IDA label. shootout94 ShootersSelect. Shootout shooters: TestList = d0, redraw the names and the player box, back to the loop
	move.w	d0,(TestList).w
	bsr.w	PrintShooterNames
	bsr.w	PrintShooterBox
	bra.w	ShootersLoop
ShootersBackground	;no IDA label. shootout94 ShootersBackground. Shootout shooters: "Shootout" title and the team block (PutTeamBlock)
	bsr.w	ClearShooterScreen
	jsr	(printz).l
	String	$BE,$7,$1,$0
	moveq	#$1A,d0
	moveq	#6,d1
	jsr	(printbigz).l
	String	$BE,$A,$4,'  Shootout  ',$BE,$F,$1
	clr.w	d0
	cmpa.w	#HmShots&$FFFF,a2
	beq.w	.0
	move.w	#$2C,d0
.0
	jmp	(PutTeamBlock).l
ClearShooterScreen	;no IDA label. shootout94 ClearShooterScreen. Shootout shooters: erase the top of the screen
	jsr	(printz).l
	String	$BE,$0,$0,$0
	moveq	#$28,d0
	moveq	#$A,d1
	move.w	#$7FF,d2
	jmp	(eraser).l
ResetShooterScroll	;no IDA label. shootout94 ResetShooterScroll. Clear the list scroll words palfadenew+$5A and palfadenew+$7A. Nothing calls it in 95
	clr.w	(palfadenew+$5A).w
	clr.w	(palfadenew+$7A).w
	rts
PrintShooterSlots	;no IDA label. shootout94 PrintShooterSlots. Shootout shooters: "Shooters" 1. ... 5. and "Goalie"
	jsr	(printz2).l
	String	$F9,$0,$FF,$2,$FD,$0,$FC,$A
	jsr	(printz2).l
	String	$FE,$4
	jsr	(printz2).l
	String	$FD,$7,$FC,$C,'Shooters'
	jsr	(printz2).l
	String	$FD,$3,$FC,$E,'1. ',$0
	jsr	(printz2).l
	String	$FD,$3,$FC,$10,'2. ',$0
	jsr	(printz2).l
	String	$FD,$3,$FC,$12,'3. ',$0
	jsr	(printz2).l
	String	$FD,$3,$FC,$14,'4. ',$0
	jsr	(printz2).l
	String	$FD,$3,$FC,$16,'5. ',$0
	jsr	(printz2).l
	String	$FD,$1A,$FC,$C,'Goalie'
	rts
PrintShooterBox	;no IDA label. shootout94 PrintShooterBox. Shootout shooters: the selected player (getname), centred
	jsr	(printz2).l
	String	$F8,$4,$2,$8,$7,$F9,$1,$0
	jsr	(printz2).l
	String	$FD,$0,$FC,$7,'                                       ',$0
	jsr	(printz2).l
	String	$FD,$15,$FC,$7
	movea.l	#homeshooters,a1
	cmpa.l	#HmShots,a2
	beq.w	.0
	movea.l	#awayshooters,a1
.0
	move.w	(TestList).w,d0
	asl.w	#1,d0
	move.w	(a1,d0.w),d0
	jsr	(getname).l
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	move.w	d7,(printa).w
	jsr	(printsmall).l
	clr.w	(printfontset).w
	rts
PrintShooterNames	;no IDA label. shootout94 PrintShooterNames. Shootout shooters: the shooters' names (FormatPlayerNameShort), slot TestList
	;highlighted
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz2).l
	String	$FD,$6,$FC,$E,$FE,$6,$F9,$0
	move.w	#0,d1
	movea.l	#homeshooters,a0
	cmpa.l	#HmShots,a2
	beq.w	.loop
	movea.l	#awayshooters,a0
.loop
	move.w	d1,d0
	asl.w	#1,d0
	move.w	(a0,d0.w),d0
	jsr	(FormatPlayerNameShort).l
	move.w	(printx).w,-(sp)
	cmp.w	(TestList).w,d1
	bne.w	.1
	move.w	#2,(printfontset).w
.1
	cmp.w	#5,d1
	bne.w	.2
	move.w	#$19,(printx).w
	move.w	#$E,(printy).w
.2
	jsr	(printsmall).l
	clr.w	(printfontset).w
	move.w	(sp)+,(printx).w
	addq.w	#2,(printy).w
	addq.w	#1,d1
	cmp.w	#6,d1
	blt.s	.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
