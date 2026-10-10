;	NHL 95 records95. Retail $09B6F4-$09C019 (2342 bytes).
;	Mapped to records94 (84%): UserNameEntry (four pads in 95), the name log checks (NameInUse ... SkipUserName, 94 SkipOtherUserName),
;	WriteNameLog / ReadNameLog / NameLogIO (cards94), ClearNameHelp, PlayoffStatsScreen (95 only), RecordHoldersScreen, PrintRecordPage,
;	PrintRecordTitles, PrintWinRecords, ClearRecordArea, PrintPlayerRecords, PrintRecordName, CalcWinPercents, ReadTeamRecords and
;	ClearWinRecords (title94).
;	The segment map started this file at $09B730 (inside UserNameEntry); the confirmed start is $09B6F4.
;	IDA left $09B8D6-$09C019 as dc.b; it is transcribed from the retail bytes. IDA hid printz / printz2 / printbigz Strings as instructions.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches
;	the cmp encoding after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

UserNameEntry	;IDA: sub_9B6F4. With user records on (OptUserRec 0): the name entry (NameEntryScreen) for each pad in use (records94 UserNameEntry),
	;then sflags11 bit 7 when no team has more than one pad
	bclr	#7,(sflags11).w
	tst.w	(OptUserRec).w
	bne.w	.x
	clr.w	(pad1user).w
	clr.w	(pad2user).w
	clr.w	(pad3user).w
	clr.w	(pad4user).w
	tst.w	(cont1team).w
	beq.w	.0
	move.w	(cont1team).w,(nameentryvis).w
	subq.w	#1,(nameentryvis).w
	movea.l	#pad1user,a5
	jsr	(NameEntryScreen).l
.0
	tst.w	(cont2team).w
	beq.w	.1
	move.w	(cont2team).w,(nameentryvis).w
	subq.w	#1,(nameentryvis).w
	movea.l	#pad2user,a5
	jsr	(NameEntryScreen).l
.1
	tst.w	(cont3team).w
	beq.w	.2
	move.w	(cont3team).w,(nameentryvis).w
	subq.w	#1,(nameentryvis).w
	movea.l	#pad3user,a5
	jsr	(NameEntryScreen).l
.2
	tst.w	(cont4team).w
	beq.w	.3
	move.w	(cont4team).w,(nameentryvis).w
	subq.w	#1,(nameentryvis).w
	movea.l	#pad4user,a5
	jsr	(NameEntryScreen).l
.3
	bset	#7,(sflags11).w
	move.w	#1,d0
	bsr.w	CountTeamPads
	cmp.w	#1,d2
	ble.w	.4
	bclr	#7,(sflags11).w
.4
	move.w	#2,d0
	bsr.w	CountTeamPads
	cmp.w	#1,d2
	ble.w	.x
	bclr	#7,(sflags11).w
.x
	rts
CountTeamPads	;IDA: sub_9B7BE. 95 only. d2 = the number of pads (cont1team ... cont4team) on team d0 (1 home, 2 away)
	clr.w	d2
	cmp.w	(cont1team).w,d0
	bne.w	.0
	addq.w	#1,d2
.0
	cmp.w	(cont2team).w,d0
	bne.w	.1
	addq.w	#1,d2
.1
	cmp.w	(cont3team).w,d0
	bne.w	.2
	addq.w	#1,d2
.2
	cmp.w	(cont4team).w,d0
	bne.w	.x
	addq.w	#1,d2
.x
	rts
NameInUse	;IDA: sub_9B7EA. 95 only. Step the name log selection (CreateListRow) past the names the other pads (pad1user ... pad4user, not a5) picked,
	;in direction d0; Z set (d2 0) when it moved
	movem.l	d1-d2/a0,-(sp)
	move.w	#1,d2
	movea.l	#pad1user,a0
	bsr.w	SkipPadName
	movea.l	#pad2user,a0
	bsr.w	SkipPadName
	movea.l	#pad3user,a0
	bsr.w	SkipPadName
	movea.l	#pad4user,a0
	bsr.w	SkipPadName
	tst.w	d2
	movem.l	(sp)+,d1-d2/a0
	rts
SkipPadName	;IDA: sub_9B822. 95 only. When pad slot a0 is not a5 and holds the selected name (CreateListRow), step past it (SkipUserName)
	cmpa.l	a5,a0
	beq.w	.x
	move.w	(a0),d1
	cmp.w	(CreateListRow).w,d1
	bne.w	.x
	bsr.w	SkipUserName
.x
	rts
SkipUserName	;IDA: sub_9B838. records94 SkipOtherUserName. Step the name log selection (CreateListRow) by 1 in direction d0, wrapping 1-7; d2 = 0
	move.w	#1,d1
	tst.w	d0
	bpl.w	.0
	move.w	#$FFFF,d1
.0
	add.w	d1,(CreateListRow).w
	cmpi.w	#7,(CreateListRow).w
	ble.w	.1
	move.w	#1,(CreateListRow).w
.1
	tst.w	(CreateListRow).w
	bne.w	.2
	move.w	#7,(CreateListRow).w
.2
	clr.w	d2
	rts
WriteNameLog	;IDA: sub_9B86C. cards94 WriteNameLog. Write the user name log ($80 bytes at namelog) to save RAM $DA2 (NameLogIO)
	bset	#6,(sflags6).w
	bra.w	NameLogIO
ReadNameLog	;IDA: sub_9B876. cards94 ReadNameLog. Read the user name log from save RAM $DA2 to namelog (NameLogIO)
	bclr	#6,(sflags6).w
NameLogIO	;IDA: loc_9B87C. cards94 NameLogIO. Read or write (sflags6 bit 6) the name log
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$80,d1
	move.l	#$DA2,d0
	movea.l	#namelog,a0
	btst	#6,(sflags6).w
	beq.w	.0
	jsr	(WriteSRAM).l
	bra.w	.x
.0
	jsr	(ReadSRAM).l
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ClearNameHelp	;IDA: sub_9B8B2. 95 only. Name entry: erase the help text area ($16 x 8 at 24,17)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$18,$11,$0
	moveq	#$16,d0
	moveq	#8,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
PlayoffStatsScreen	;no IDA label. 95 only. Pause menu PLAYOFF STATS: the playoff stats (DisplayAttributeScreen, d7 1) of the team in the playoff
	;tree slot potreeteam (home or away team struct)
	movem.l	a2,-(sp)
	jsr	(ReadTeamStats).l
	movea.l	#potree,a0
	move.w	(potreeteam).w,d0
	move.b	(a0,d0.w),d0
	movea.l	#HmShots,a2
	cmp.w	$28(a2),d0
	beq.w	.0
	adda.w	#$366,a2
.0
	moveq	#1,d7
	jsr	(DisplayAttributeScreen).l
	movem.l	(sp)+,a2
	rts
RecordHoldersScreen	;no IDA label. records94 RecordHoldersScreen. Pause menu RECORD HOLDERS: the save RAM records (PrintRecordTitles ... ReadTeamRecords);
	;page TempWord1 (left / right), A+C on the win page clears the win records (ClearWinRecords)
	bsr.w	ReadNameLog
	clr.w	(TempWord1).w
	bclr	#6,(sflags6).w
	bsr.w	ReadTeamRecords
	bset	#6,(sflags6).w
	bsr.w	ReadTeamRecords
	bsr.w	CalcWinPercents
	move.w	#0,d0
	move.w	#$1A,d1
	jsr	(SetupScreen).l
	jsr	(printz).l
	String	$FD,$0,$0,$0
	move.w	#$7FF,d2
	move.w	#$28,d0
	move.w	#$1C,d1
	jsr	(eraser).l
	jsr	(printbigz).l
	String	$BD,$7,$2,'Record Holders',$BD,$1,$9
	jsr	(printz2).l
	String	$F8,$4,$3,$5,$8,$F9,$1,'Name',$F9,$0,$0
	bsr.w	PrintRecordTitles
	bsr.w	PrintWinRecords
.loop
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d3
	beq.w	.0
	jmp	(ExitAttributeScreen2).l
.0
	tst.w	(TempWord1).w
	bne.w	.1
	btst	#6,d3
	beq.w	.1
	btst	#5,d3
	beq.w	.1
	bsr.w	ClearWinRecords
	bsr.w	CalcWinPercents
	bsr.w	PrintWinRecords
	bra.s	.loop
.1
	btst	#3,d1
	beq.w	.2
	cmpi.w	#2,(TempWord1).w
	beq.s	.loop
	bsr.w	ClearRecordArea
	addq.w	#1,(TempWord1).w
	bsr.w	PrintRecordTitles
	bsr.w	PrintRecordPage
	bra.s	.loop
.2
	btst	#2,d1
	beq.s	.loop
	tst.w	(TempWord1).w
	beq.s	.loop
	bsr.w	ClearRecordArea
	subq.w	#1,(TempWord1).w
	bsr.w	PrintRecordTitles
	bsr.w	PrintRecordPage
	bra.w	.loop
	rts	;never reached
PrintRecordPage	;no IDA label. records94 PrintRecordPage. Record Holders: print page TempWord1 (0: PrintWinRecords, else PrintPlayerRecords)
	tst.w	(TempWord1).w
	beq.w	PrintWinRecords
	bra.w	PrintPlayerRecords
PrintRecordTitles	;no IDA label. records94 PrintRecordTitles. Record Holders: the titles of page TempWord1 (WinRecTitles, GoalRecTitles, SaveRecTitles)
	movea.l	#WinRecTitles,a1
	tst.w	(TempWord1).w
	beq.w	.0
	movea.l	#SaveRecTitles,a1
	cmpi.w	#2,(TempWord1).w
	beq.w	.0
	movea.l	#GoalRecTitles,a1
.0
	jsr	(printsmall).l
	rts
WinRecTitles	;no IDA label. records94 WinRecTitles. PrintRecordTitles String, page 0
	dc.w	$52	;String length
	dc.b	$F8,$4,$3,$10,$8,$F9,$1,'   Win %   Win-Loss-Tie'
	dc.b	$FD,$4,$FC,$19,'Use A+C to clear ALL win records',$FD,$10,$FC
	dc.b	$1A,'  More ]',$F9,$0
GoalRecTitles	;no IDA label. records94 GoalRecTitles. PrintRecordTitles String, page 1
	dc.w	$50	;String length
	dc.b	$F8,$4,$3,$12,$8,$F9,$1,'Goals       Teams    '
	dc.b	$FD,$4,$FC,$19,'    TEAM MUST WIN TO QUALIFY    ',$FD,$10,$FC
	dc.b	$1A,'[ More ]',$F9,$0
SaveRecTitles	;no IDA label. records94 SaveRecTitles. PrintRecordTitles String, page 2
	dc.w	$50	;String length
	dc.b	$F8,$4,$3,$12,$8,$F9,$1,'Saves       Teams    '
	dc.b	$FD,$4,$FC,$19,'    TEAM MUST WIN TO QUALIFY    ',$FD,$10,$FC
	dc.b	$1A,'[ More  ',$F9,$0
PrintWinRecords	;no IDA label. records94 PrintWinRecords. Record Holders page 0: name (PrintRecordName), win %, wins, losses, ties of the 7 rows
	;in winsort order
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz2).l
	String	$F8,$4,$3,$2,$A,$F9,$0,$0
	move.w	#6,d7
	movea.l	#winsort,a0
	movea.l	#winpcts,a2
	movea.l	#ThreeStars,a5
.loop
	move.w	#2,(printx).w
	move.b	(a0)+,d0
	ext.w	d0
	move.b	0(a2,d0.w),d5
	asl.w	#4,d0
	move.b	$A(a5,d0.w),d4
	lsl.w	#8,d4
	move.b	$B(a5,d0.w),d4
	move.w	d4,-(sp)
	move.b	$C(a5,d0.w),d4
	lsl.w	#8,d4
	move.b	$D(a5,d0.w),d4
	move.w	d4,(recties).w
	move.b	8(a5,d0.w),d4
	lsl.w	#8,d4
	move.b	9(a5,d0.w),d4
	move.w	d4,(recwincount).w
	add.w	(recties).w,d4
	sub.w	(sp),d4
	neg.w	d4
	move.w	d4,(reclosses).w
	move.w	(sp)+,d4
	tst.w	d4
	beq.w	.0
	bsr.w	PrintRecordName
	move.w	#$13,(printx).w
	move.w	d0,-(sp)
	move.w	d5,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	move.w	#$1A,(printx).w
	move.w	(recwincount).w,d0
	move.w	#4,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	move.w	#$1F,(printx).w
	move.w	(reclosses).w,d0
	move.w	#4,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	move.w	#$24,(printx).w
	move.w	(recties).w,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	move.w	(sp)+,d0
	bra.w	.1
.0
	movea.l	#RecBlankTxt,a1
.1
	jsr	(printsmall).l
	addq.w	#2,(printy).w
	dbf	d7,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ClearRecordArea	;no IDA label. records94 ClearRecordArea. Record Holders: erase the record rows ($28 x $12), keeping printx / printy / printm
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	move.w	(printm).w,-(sp)
	jsr	(printz2).l
	String	$F8,$4,$3,$0,$A,$0
	move.w	#$28,d0
	move.w	#$12,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	(sp)+,(printm).w
	move.w	(sp)+,(printy).w
	move.w	(sp)+,(printx).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
PrintPlayerRecords	;no IDA label. records94 PrintPlayerRecords. Record Holders pages 1 (goals, recsort1) and 2 (saves, recsort2): name, value,
	;"by TEAM vs. TEAM" of the 7 rows
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz2).l
	String	$F8,$4,$3,$2,$A,$F9,$0,$0
	move.w	#6,d7
	movea.l	#recsort1,a0
	cmpi.w	#1,(TempWord1).w
	beq.w	.0
	movea.l	#recsort2,a0
.0
	movea.l	#ThreeStars,a2
.loop
	move.w	#2,(printx).w
	move.b	(a0)+,d0
	ext.w	d0
	asl.w	#4,d0
	move.b	0(a2,d0.w),d5
	cmpi.w	#1,(TempWord1).w
	beq.w	.1
	move.b	4(a2,d0.w),d5
.1
	tst.b	d5
	beq.w	.8
	bsr.w	PrintRecordName
	move.w	#$12,(printx).w
	move.w	d0,-(sp)
	cmpi.w	#1,(TempWord1).w
	bne.w	.2
	move.b	0(a2,d0.w),d0
	bra.w	.3
.2
	move.b	4(a2,d0.w),d0
.3
	andi.w	#$FF,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	move.w	(sp)+,d0
	move.w	#$19,(printx).w
	movea.l	#RecHolderByTxt,a1
	movea.l	#mesarea,a3
	jsr	(StartText).l
	move.w	d0,-(sp)
	cmpi.w	#1,(TempWord1).w
	bne.w	.4
	move.b	1(a2,d0.w),d0
	bra.w	.5
.4
	move.b	5(a2,d0.w),d0
.5
	andi.w	#$FF,d0
	movea.l	#mesarea,a1
	jsr	(AppendTeamName).l
	movea.l	#RecHolderVsTxt,a1
	movea.l	#mesarea,a3
	jsr	(appstring).l
	movea.l	#mesarea,a1
	move.w	(sp)+,d0
	cmpi.w	#1,(TempWord1).w
	bne.w	.6
	move.b	2(a2,d0.w),d0
	bra.w	.7
.6
	move.b	6(a2,d0.w),d0
.7
	andi.w	#$FF,d0
	jsr	(AppendTeamName).l
	bra.w	.9
.8
	movea.l	#RecBlankTxt,a1
.9
	jsr	(printsmall).l
	addq.w	#2,(printy).w
	dbf	d7,.loop
	movem.l	(sp)+,d0-d7/a0-a6
	rts
RecBlankTxt	;no IDA label. records94 RecParenTxt. A blank record row (38 spaces)
	String	'                                      '
RecHolderByTxt	;no IDA label. records94 RecHolderByTxt. PrintPlayerRecords "by "
	String	'by ',$0
RecHolderVsTxt	;no IDA label. records94 RecHolderVsTxt. PrintPlayerRecords " vs. "
	String	' vs. ',$0
PrintRecordName	;no IDA label. records94 PrintRecordName. Record Holders: print the row number ("1. ") at d7 and the user name (AppendUserName) of
	;the record row before a0
	move.w	d7,-(sp)
	neg.w	d7
	addq.w	#7,d7
	addi.w	#$30,d7
	movea.l	#mesarea,a1
	move.w	#6,(a1)
	move.b	d7,2(a1)
	move.b	#$2E,3(a1)
	move.b	#$20,4(a1)
	move.b	#0,5(a1)
	jsr	(printsmall).l
	move.w	(sp)+,d7
	move.b	-1(a0),d2
	ext.w	d2
	movea.l	#mesarea,a1
	bclr	#7,(sflags6).w
	jsr	(AppendUserName).l
	jmp	(printsmall).l
CalcWinPercents	;no IDA label. records94 CalcWinPercents. For the 8 user record blocks at ThreeStars: the win % (winpcts), games (wingames) and ties
	;(winties), then sort the rows (winsort)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ThreeStars,a0
	movea.l	#winpcts,a1
	movea.l	#winties,a6
	movea.l	#wingames,a5
	move.w	#7,d7
.loop
	move.b	8(a0),d0
	lsl.w	#8,d0
	move.b	9(a0),d0
	move.b	$A(a0),d1
	lsl.w	#8,d1
	move.b	$B(a0),d1
	move.w	d1,(a5)+
	tst.w	d1
	bne.w	.0
	clr.w	d0
	bra.w	.1
.0
	mulu.w	#$64,d0
	divu.w	d1,d0
.1
	move.b	d0,(a1)+
	move.b	$C(a0),(a6)+
	move.b	$D(a0),(a6)+
	adda.w	#$10,a0
	dbf	d7,.loop
	movea.l	#winsort,a1
	move.l	a1,-(sp)
	move.w	#1,d0
	move.w	#6,d7
.loop2
	move.b	d0,(a1)+
	addq.w	#1,d0
	dbf	d7,.loop2
	movea.l	(sp),a1
	movea.l	#winpcts,a0
	movea.l	#winties,a6
	movea.l	#wingames,a5
.loop3
	movea.l	(sp),a1
	move.w	#5,d7
	clr.w	d6
.loop4
	move.b	(a1)+,d1
	ext.w	d1
	move.b	(a1),d2
	ext.w	d2
	move.b	0(a0,d1.w),d0
	move.b	0(a0,d2.w),d3
	cmp.b	d3,d0
	bgt.w	.3
	blt.w	.2
	movem.l	d1-d3,-(sp)
	add.w	d1,d1
	add.w	d2,d2
	move.w	0(a6,d1.w),d0
	move.w	0(a6,d2.w),d3
	cmp.w	d3,d0
	movem.l	(sp)+,d1-d3
	bgt.w	.3
	blt.w	.2
	movem.l	d1-d3,-(sp)
	add.w	d1,d1
	add.w	d2,d2
	move.w	0(a5,d1.w),d0
	move.w	0(a5,d2.w),d3
	cmp.w	d3,d0
	movem.l	(sp)+,d1-d3
	bge.w	.3
.2
	move.b	(a1),d0
	move.b	-1(a1),d1
	move.b	d0,-1(a1)
	move.b	d1,(a1)
	st	d6
.3
	dbf	d7,.loop4
	tst.w	d6
	bne.s	.loop3
	movea.l	(sp)+,a1
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ReadTeamRecords	;no IDA label. records94 ReadTeamRecords. Read the $80 byte records from save RAM $D22 (ReadSRAM) and sort the rows on record
	;byte 0 (recsort1) or, with sflags6 bit 6, byte 4 (recsort2)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$D22,d0
	move.l	#$80,d1
	movea.l	#ThreeStars,a0
	jsr	(ReadSRAM).l
	movea.l	#recsort1,a1
	btst	#6,(sflags6).w
	beq.w	.0
	movea.l	#recsort2,a1
.0
	move.l	a1,-(sp)
	move.w	#1,d0
	move.w	#6,d7
.loop
	move.b	d0,(a1)+
	addq.w	#1,d0
	dbf	d7,.loop
	movea.l	(sp),a1
	movea.l	#ThreeStars,a0
.loop2
	movea.l	(sp),a1
	move.w	#5,d7
	clr.w	d6
.loop3
	move.b	(a1)+,d1
	ext.w	d1
	move.b	(a1),d2
	ext.w	d2
	asl.w	#4,d1
	asl.w	#4,d2
	move.b	0(a0,d1.w),d0
	move.b	0(a0,d2.w),d3
	btst	#6,(sflags6).w
	beq.w	.1
	move.b	4(a0,d1.w),d0
	move.b	4(a0,d2.w),d3
.1
	cmp.b	d3,d0
	bge.w	.2
	move.b	(a1),d0
	move.b	-1(a1),d1
	move.b	d0,-1(a1)
	move.b	d1,(a1)
	st	d6
.2
	dbf	d7,.loop3
	tst.w	d6
	bne.s	.loop2
	movea.l	(sp)+,a1
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ClearWinRecords	;no IDA label. title94 ClearWinRecords. Clear bytes 8-$B (wins, games) of the 8 ThreeStars records and write the $80 bytes to
	;save RAM $D22 (WriteSRAM, MakeSRAMChecksum)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ThreeStars,a0
	move.w	#7,d7
.loop
	clr.b	8(a0)
	clr.b	9(a0)
	clr.b	$A(a0)
	clr.b	$B(a0)
	adda.w	#$10,a0
	dbf	d7,.loop
	move.l	#$D22,d0
	move.l	#$80,d1
	movea.l	#ThreeStars,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
