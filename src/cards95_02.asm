;	NHL 95 cards95_02. Retail $09C01A-$09C6EF (1750 bytes).
;	Mapped to cards94 (67%): UpdateRecords (the user records after a game, four pads in 95), UpdateTeamRecord, UpdateCrowdRecord,
;	UpdatePlayerRecords, the save RAM record block IO (ReadTeamRecord ... WritePlayerRecord, PlayerRecordOffsets), CountGoalies and
;	CountPlayers; SetupScreen (stats94, 93 name) follows them in 95.
;	IDA left SetupScreen ($09C5B8) as dc.b; it is transcribed from the retail bytes. IDA hid its printz Strings and remap bytes.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches
;	the cmp encoding after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

UpdateRecords	;IDA: sub_9C01A. cards94 UpdateRecords. With save RAM (ValidSRAM) and user records on (OptUserRec 0), update the player records
	;(UpdatePlayerRecords), with sflags11 bit 7 the crowd records of both teams (UpdateCrowdRecord), then the team record of each pad
	;(UpdateUserRecord), then the save RAM checksum
	tst.w	(ValidSRAM).w
	bmi.w	.x
	tst.w	(OptUserRec).w
	bne.w	.x
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	CountGoalies
	bsr.w	CountPlayers
	move.w	(HomeTeam).w,d1
	ext.l	d1
	movea.l	#ThreeStars,a0
	movea.l	#HmShots,a2
	move.w	(homegoalies).w,d5
	move.w	(VisTeam).w,d6
	bsr.w	UpdatePlayerRecords
	move.w	(VisTeam).w,d1
	ext.l	d1
	movea.l	#AwShots,a2
	move.w	(awaygoalies).w,d5
	move.w	(HomeTeam).w,d6
	bsr.w	UpdatePlayerRecords
	btst	#7,(sflags11).w
	beq.w	.0
	clr.w	d7
	movea.l	#HmShots,a1
	bsr.w	GetTeamUser
	move.w	(recuser1).w,d4
	movea.l	#AwShots,a1
	bsr.w	GetTeamUser
	move.w	(recuser1).w,d5
	movea.l	#HmShots,a1
	move.w	(HomeTeam).w,d1
	move.w	(VisTeam).w,d2
	move.w	(homegoalies).w,d6
	ext.l	d1
	movea.l	#ThreeStars,a0
	bsr.w	UpdateCrowdRecord
	movea.l	#AwShots,a1
	bsr.w	GetTeamUser
	move.w	(recuser1).w,d4
	movea.l	#HmShots,a1
	bsr.w	GetTeamUser
	move.w	(recuser1).w,d5
	movea.l	#AwShots,a1
	move.w	(VisTeam).w,d1
	move.w	(HomeTeam).w,d2
	move.w	(awaygoalies).w,d6
	ext.l	d1
	movea.l	#ThreeStars,a0
	bsr.w	UpdateCrowdRecord
.0
	move.w	d0,-(sp)
	movea.l	#ThreeStars,a0
	move.w	(pad1user).w,d1
	ext.l	d1
	move.w	(cont1team).w,d0
	bsr.w	UpdateUserRecord
	movea.l	#ThreeStars,a0
	move.w	(pad2user).w,d1
	ext.l	d1
	move.w	(cont2team).w,d0
	bsr.w	UpdateUserRecord
	movea.l	#ThreeStars,a0
	move.w	(pad3user).w,d1
	ext.l	d1
	move.w	(cont3team).w,d0
	bsr.w	UpdateUserRecord
	movea.l	#ThreeStars,a0
	move.w	(pad4user).w,d1
	ext.l	d1
	move.w	(cont4team).w,d0
	bsr.w	UpdateUserRecord
	move.w	(sp)+,d0
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
.x
	rts
UpdateTeamRecord	;IDA: loc_9C14C. cards94 UpdateTeamRecord. Add the game of team a1 (against a2) to team record block d1 (games, wins, ties);
	;with sflags11 bit 7 keep the biggest win and loss margins with users d3 / d4 and team d2 (WriteTeamRecord)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	ReadTeamRecord
	st	d7
	movem.w	d0,-(sp)
	clr.w	d0
	move.b	$A(a0),d0
	lsl.w	#8,d0
	move.b	$B(a0),d0
	cmp.w	#$2328,d0
	bge.w	.1
	addq.w	#1,d0
	move.b	d0,$B(a0)
	lsr.w	#8,d0
	move.b	d0,$A(a0)
	move.w	$C(a1),d0
	cmp.w	$C(a2),d0
	bgt.w	.0
	blt.w	.1
	clr.w	d0
	move.b	$C(a0),d0
	lsl.w	#8,d0
	move.b	$D(a0),d0
	addq.w	#1,d0
	move.b	d0,$D(a0)
	lsr.w	#8,d0
	move.b	d0,$C(a0)
	bra.w	.1
.0
	clr.w	d0
	move.b	8(a0),d0
	lsl.w	#8,d0
	move.b	9(a0),d0
	addq.w	#1,d0
	move.b	d0,9(a0)
	lsr.w	#8,d0
	move.b	d0,8(a0)
.1
	movem.w	(sp)+,d0
	btst	#7,(sflags11).w
	beq.w	.3
	movem.w	d0,-(sp)
	move.w	$C(a1),d0
	cmp.w	$C(a2),d0
	movem.w	(sp)+,d0
	ble.w	.3
	move.w	$C(a1),d5
	cmp.b	(a0),d5
	ble.w	.2
	st	d7
	move.b	d5,(a0)
	move.b	d3,1(a0)
	move.b	d4,2(a0)
	move.b	d2,3(a0)
.2
	move.w	$C(a2),d5
	move.w	(a2),d6
	sub.w	d5,d6
	cmp.b	4(a0),d6
	ble.w	.3
	st	d7
	move.b	d6,4(a0)
	move.b	d3,5(a0)
	move.b	d4,6(a0)
	move.b	d2,7(a0)
.3
	bsr.w	WriteTeamRecord
	movem.l	(sp)+,d0-d7/a0-a6
	rts
UpdateCrowdRecord	;IDA: sub_9C226. cards94 UpdateCrowdRecord. Crowd record block d1 of team a1: the most goals, the biggest period lead and (home
	;team) the crowd peak (CrowdPeak), with users d4 / d5 and opponent d2 (clrCrowdRAM, WriteCrowdRecord)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	clrCrowdRAM
	move.w	$C(a1),d3
	cmp.b	(a0),d3
	ble.w	.0
	move.b	d3,(a0)
	move.b	d4,1(a0)
	move.b	d5,3(a0)
	move.b	d2,2(a0)
	st	d7
.0
	subq.w	#1,d6
	clr.w	d3
.loop
	move.w	d6,d0
	addi.w	#$EA,d0
	move.b	(a1,d0.w),(TempWord1).w
	addi.w	#-$34,d0
	move.b	(a1,d0.w),d0
	sub.b	d0,(TempWord1).w
	cmp.b	(TempWord1).w,d3
	bge.w	.1
	move.b	(TempWord1).w,d3
.1
	dbf	d6,.loop
	cmp.b	4(a0),d3
	ble.w	.2
	st	d7
	move.b	d3,4(a0)
	move.b	d4,5(a0)
	move.b	d5,7(a0)
	move.b	d2,6(a0)
.2
	cmp.w	(HomeTeam).w,d1
	bne.w	.3
	move.b	8(a0),d3
	andi.w	#$FF,d3
	cmp.w	(CrowdPeak).w,d3
	bge.w	.3
	move.w	(CrowdPeak).w,d3
	st	d7
	move.b	d3,8(a0)
	move.b	d4,9(a0)
	move.b	d5,$B(a0)
	move.b	d2,$A(a0)
.3
	tst.w	d7
	beq.w	.x
	bsr.w	WriteCrowdRecord
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts
UpdatePlayerRecords	;IDA: sub_9C2CC. cards94 UpdatePlayerRecords. For the 26 players of team a2, keep each new best (goals, or saves for the
	;goalies) in his player record with opponent d6 and, with sflags11 bit 7, the users of both teams (GetPadUser)
	clr.l	d0
	move.w	#$19,d2
.loop
	bsr.w	ReadPlayerRecord
	cmp.w	d5,d0
	blt.w	.0
	move.w	d0,-(sp)
	addi.w	#$B6,d0
	move.b	(a2,d0.w),d4
	move.w	(sp)+,d0
	bra.w	.1
.0
	move.w	d0,-(sp)
	addi.w	#$EA,d0
	move.b	(a2,d0.w),d4
	addi.w	#-$34,d0
	sub.b	(a2,d0.w),d4
	move.w	(sp)+,d0
.1
	move.b	(a0),d3
	cmp.b	d3,d4
	ble.w	.5
	move.b	d4,(a0)
	btst	#7,(sflags11).w
	bne.w	.2
	move.b	#0,1(a0)
	move.b	#0,3(a0)
	bra.w	.4
.2
	move.l	a4,-(sp)
	move.w	#1,d0
	cmpa.l	#HmShots,a2
	bne.w	.3
	move.w	#2,d0
.3
	movea.l	#recuser1,a4
	bsr.w	GetPadUser
	eori.w	#3,d0
	movea.l	#recuser2,a4
	bsr.w	GetPadUser
	move.b	(recuser1+1).w,1(a0)
	move.b	(recuser2+1).w,3(a0)
	movea.l	(sp)+,a4
.4
	move.b	d6,2(a0)
	bsr.w	WritePlayerRecord
.5
	addq.w	#1,d0
	dbf	d2,.loop
	rts
GetPadUser	;IDA: sub_9C36E. 95 only. (a4) = the name log entry (pad1user ... pad4user) of the first pad on team d0, or 0
	clr.w	(a4)
	cmp.w	(cont1team).w,d0
	bne.w	.0
	move.w	(pad1user).w,(a4)
	rts
.0
	cmp.w	(cont2team).w,d0
	bne.w	.1
	move.w	(pad2user).w,(a4)
	rts
.1
	cmp.w	(cont3team).w,d0
	bne.w	.2
	move.w	(pad3user).w,(a4)
	rts
.2
	cmp.w	(cont4team).w,d0
	bne.w	.x
	move.w	(pad4user).w,(a4)
.x
	rts
UpdateUserRecord	;IDA: sub_9C3A8. 95 only. Team record block d1 (a pad's name log entry) for the pad's team d0 (UpdateTeamRecord); for a pad
	;with no team, the team no pad plays (none when both have pads)
	tst.w	d0
	bne.w	.2
	movea.l	#HmShots,a1
	cmpi.w	#1,(cont1team).w
	beq.w	.0
	cmpi.w	#1,(cont2team).w
	beq.w	.0
	cmpi.w	#1,(cont3team).w
	beq.w	.0
	cmpi.w	#1,(cont4team).w
	beq.w	.0
	bra.w	.1
.0
	movea.l	#AwShots,a1
	cmpi.w	#2,(cont1team).w
	beq.w	.x
	cmpi.w	#2,(cont2team).w
	beq.w	.x
	cmpi.w	#2,(cont3team).w
	beq.w	.x
	cmpi.w	#2,(cont4team).w
	beq.w	.x
.1
	bra.w	.3
.2
	movea.l	#HmShots,a1
	cmp.w	#2,d0
	bne.w	.3
	movea.l	#AwShots,a1
.3
	cmpa.l	#HmShots,a1
	bne.w	.5
	movea.l	#AwShots,a2
	move.w	(HomeTeam).w,d3
	move.w	(VisTeam).w,d4
.4
	exg	a1,a2
	bsr.w	GetTeamUser
	move.w	(recuser1).w,d2
	exg	a1,a2
	bra.w	.6
.5
	movea.l	#HmShots,a2
	move.w	(VisTeam).w,d3
	move.w	(HomeTeam).w,d4
	bra.s	.4
.6
	bra.w	UpdateTeamRecord
.x
	rts
ReadTeamRecord	;IDA: sub_9C464. cards94 ReadTeamRecord. Read the 16 byte team record block d1 ($D22 + d1 * 16) to a0 (TeamRecordIO)
	bclr	#6,(sflags6).w
TeamRecordIO	;IDA: loc_9C46A. cards94 TeamRecordIO. The team record block: read or write (sflags6 bit 6)
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	d1,d0
	asl.w	#4,d0
	addi.l	#$D22,d0
	moveq	#$10,d1
	btst	#6,(sflags6).w
	beq.w	.0
	jsr	(WriteSRAM).l
	bra.w	.x
.0
	jsr	(ReadSRAM).l
.x
	movem.l	(sp)+,d0-d1/a0-a1
	rts
WriteTeamRecord	;IDA: sub_9C49A. cards94 WriteTeamRecord. Write the team record block (TeamRecordIO)
	bset	#6,(sflags6).w
	bra.s	TeamRecordIO
clrCrowdRAM	;IDA: sub_9C4A2. cards94 clrCrowdRAM (IDA name). Read the 16 byte crowd record block of team d1 ($B62 + d1 * 16) to a0 (CrowdRecordIO)
	bclr	#6,(sflags6).w
CrowdRecordIO	;IDA: loc_9C4A8. cards94 CrowdRecordIO. The crowd record block: read or write (sflags6 bit 6)
	movem.l	d0-d1/a0-a1,-(sp)
	move.l	d1,d0
	asl.w	#4,d0
	addi.l	#$B62,d0
	moveq	#$10,d1
	btst	#6,(sflags6).w
	beq.w	.0
	jsr	(WriteSRAM).l
	bra.w	.x
.0
	jsr	(ReadSRAM).l
.x
	movem.l	(sp)+,d0-d1/a0-a1
	rts
WriteCrowdRecord	;IDA: sub_9C4D8. cards94 WriteCrowdRecord. Write the crowd record block (CrowdRecordIO)
	bset	#6,(sflags6).w
	bra.s	CrowdRecordIO
ReadPlayerRecord	;IDA: sub_9C4E0. cards94 ReadPlayerRecord. Read the 4 byte player record d0 of team d1 (PlayerRecordOffsets) from save RAM to a0
	bclr	#6,(sflags6).w
PlayerRecordIO	;IDA: loc_9C4E6. cards94 PlayerRecordIO. The player record: read or write (sflags6 bit 6)
	movem.l	d0-d1/a0-a1,-(sp)
	asl.l	#2,d0
	addq.l	#2,d0
	movea.l	#PlayerRecordOffsets,a1
	add.w	d1,d1
	move.w	(a1,d1.w),d1
	asl.w	#2,d1
	ext.l	d1
	add.l	d1,d0
	moveq	#4,d1
	btst	#6,(sflags6).w
	beq.w	.0
	jsr	(WriteSRAM).l
	bra.w	.x
.0
	jsr	(ReadSRAM).l
.x
	movem.l	(sp)+,d0-d1/a0-a1
	rts
WritePlayerRecord	;IDA: sub_9C522. cards94 WritePlayerRecord. Write the 4 byte player record (PlayerRecordIO)
	bset	#6,(sflags6).w
	bra.s	PlayerRecordIO
PlayerRecordOffsets	;IDA: unk_9C52A. cards94 PlayerRecordOffsets. The first player record of each team (26 per team), ReadPlayerRecord
	dc.w	0,$1A,$34,$4E,$68,$82,$9C,$B6,$D0,$EA,$104,$11E,$138,$152
	dc.w	$16C,$186,$1A0,$1BA,$1D4,$1EE,$208,$222,$23C,$256,$270,$28A,$2A4,$2BE
	dc.w	$2D8
CountGoalies	;IDA: sub_9C564. cards94 CountGoalies. homegoalies / awaygoalies = goalies of the home / away team (ReadAttributeNibble)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#HmShots,a2
	jsr	(ReadAttributeNibble).l
	move.w	d0,(homegoalies).w
	movea.l	#AwShots,a2
	jsr	(ReadAttributeNibble).l
	move.w	d0,(awaygoalies).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
CountPlayers	;IDA: sub_9C58E. cards94 CountPlayers. homeplayers / awayplayers = players of the home / away team (GetPlayerCount)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#HmShots,a2
	jsr	(GetPlayerCount).l
	move.w	d0,(homeplayers).w
	movea.l	#AwShots,a2
	jsr	(GetPlayerCount).l
	move.w	d0,(awayplayers).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
SetupScreen	;no IDA label. stats94 SetupScreen (93 name). Common start of the stats screens: blank, scroll 0, 40 cell mode, the framer, the
	;background bitmap (ControllerBgMap), the small fonts (three remaps) and the big font
	movem.l	d0-d1/a2,-(sp)
	jsr	(forceblack).l
.0
	btst	#0,(disflags).w
	bne.s	.0
	clr.w	(Hscroll).w
	clr.w	(Vscroll).w
	jsr	(SetScroll2).l
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movea.l	#VDP_DATA,a0
	move.w	#$9100,4(a0)
	move.w	#$921C,4(a0)
	move.w	(VSPRITES).w,d0
	jsr	(Vmaddr).l
	move.l	#0,(a0)
	move.w	#$8C81,4(a0)
	move.w	#6,(Map3col1).w
	move.w	#$8D00,4(a0)
	clr.w	d0
	jsr	(Vmaddr).l
	move.l	#0,(a0)
	move.w	(sp)+,(disflags).w
	bclr	#1,(disflags).w
	move.w	#1,d4
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movem.l	(sp),d0-d1/a2
	movea.l	#ControllerBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	move.w	#$1C,d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$44,$67,$89,$AB,$CD,$EF	;remap table
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$4C,$67,$89,$AB,$CD,$EF	;remap table
	move.w	d4,(smallfont3chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$48,$67,$89,$AB,$CD,$EF	;remap table
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(printz).l
	String	$FF,$0,$0,$0
	moveq	#$40,d0
	moveq	#$20,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	movem.l	(sp)+,d0-d1/a2
	rts
