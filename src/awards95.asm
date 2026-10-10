;	NHL 95 awards95. Retail $09C6F0-$09DA4F (4960 bytes).
;	New in 95 (no 94 file): GetTeamUser (UpdateRecords), the end of season awards (SeasonAwards: the award scans, the finalists and
;	winner screens) and the playoffs (InitPlayoffs ... CollectSeriesWinners, PlayoffTreeScreen).
;	The segment map ended this file at $09D9BF; RoundSeriesOffsets / RoundSeriesCounts and PlayoffTreeScreen (to $09DA4F) belong here,
;	title95_01 starts at $09DA50 (94 ClearShootout).
;	IDA left ScanPresidents ... GetAwardAssists ($09D03E-$09D4CD), RestoreSeasonHeader and PlayoffTreeScreen as dc.b; they are transcribed
;	from the retail bytes. IDA hid printz / printz2 Strings and remap bytes as instructions.
;	$20xxxx addresses are save RAM (odd bytes).
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

GetTeamUser	;IDA: sub_9C6F0. 95 only. (recuser1) = the name log entry of the pad on team a1 (HmShots 1, else 2), 0 without sflags11 bit 7
	movem.l	d0-d2,-(sp)
	btst	#7,(sflags11).w
	bne.w	.0
	clr.w	(recuser1).w
	bra.w	.5
.0
	move.w	#1,d0
	cmpa.l	#HmShots,a1
	beq.w	.1
	move.w	#2,d0
.1
	clr.w	(recuser1).w
	cmp.w	(cont1team).w,d0
	bne.w	.2
	move.w	(pad1user).w,(recuser1).w
	bra.w	.5
.2
	cmp.w	(cont2team).w,d0
	bne.w	.3
	move.w	(pad2user).w,(recuser1).w
	bra.w	.5
.3
	cmp.w	(cont3team).w,d0
	bne.w	.4
	move.w	(pad3user).w,(recuser1).w
	bra.w	.5
.4
	cmp.w	(cont4team).w,d0
	bne.w	.5
	move.w	(pad4user).w,(recuser1).w
.5
	movem.l	(sp)+,d0-d2
	rts

SeasonAwards	;IDA: sub_9C766. 95 only. End of season awards: for each of the 9 awards the finalists, then the winner (AwardsLoop) until a button
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(forceblack).l
	jsr	(AwardsScreenSetup).l
	clr.w	(AwardIndex).w
	clr.w	(AwardHilite).w
	clr.l	(AwardTimer).w
	move.w	#$F,(AwardCycle).w
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	bsr.w	DrawFinalistsPanel
	bsr.w	FindAwardFinalists
	bsr.w	PrintAwardTitle
	bsr.w	DrawAwardPicture
.0
	bsr.w	AwardsLoop
	tst.w	d1
	beq.w	.1
	btst	#7,d1
	bne.w	.1
	bra.s	.0
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintAwardTitle	;IDA: sub_9C7BE. 95 only. Print award AwardIndex: name, description and second line (PrintCentered)
	jsr	(printz2).l
	String	$F9,$0,$FE,$1,$FF,$1,$FC,$2
	move.w	(AwardIndex).w,d0
	movea.l	#AwardNames,a1
	bsr.w	PrintCentered
	addq.w	#1,(printy).w
	move.w	(AwardIndex).w,d0
	movea.l	#AwardDescs,a1
	bsr.w	PrintCentered
	addq.w	#1,(printy).w
	move.w	(AwardIndex).w,d0
	movea.l	#AwardDescs2,a1
	bsr.w	PrintCentered
	rts

PrintCentered	;IDA: sub_9C802. 95 only. Print String d0 of the list a1 (SkipStrings) centred on the 40 columns
	jsr	(SkipStrings).l
	move.w	(a1),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	subi.w	#$14,d0
	neg.w	d0
	move.w	d0,(printx).w
	jmp	(printsmall).l

AwardNames	;IDA: unk_9C81E. 95 only. PrintAwardTitle Strings: the award names
	String	'HART MEMORIAL TROPHY'
	String	'JAMES NORRIS TROPHY',$0
	String	'VEZINA TROPHY',$0
	String	'ART ROSS TROPHY',$0
	String	'WILLIAM JENNINGS TROPHY',$0
	String	'LESTER B. PEARSON AWARD',$0
	String	'FRANK SELKE AWARD',$0
	String	'PRESIDENTS TROPHY',$0
	String	'CONN SMYTHE AWARD',$0

AwardDescs	;IDA: unk_9C8DC. 95 only. PrintAwardTitle Strings: the award descriptions
	String	'Most Valuable Player'
	String	'Best Defenseman',$0
	String	'Best Goalkeeper',$0
	String	'Most Points',$0
	String	'Goalie with Fewest'
	String	'NHLPA Most Valuable',$0
	String	'Best Defensive Forward'
	String	'Team with Best Regular'
	String	'Most Valuable Player'

AwardDescs2	;IDA: unk_9C994. 95 only. PrintAwardTitle Strings: the second description lines
	String	' ',$0
	String	' ',$0
	String	' ',$0
	String	' ',$0
	String	'Goals Against',$0
	String	'Player'
	String	' ',$0
	String	'Season Record',$0
	String	'In Playoffs',$0

DrawAwardPicture	;IDA: sub_9C9DE. 95 only. Draw the picture of award AwardIndex (AwardPictures) at AwardPictureX / AwardPictureY (dobitmap)
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	(AwardIndex).w,d0
	add.w	d0,d0
	movea.l	#AwardPictureX,a0
	move.w	(a0,d0.w),(printx).w
	movea.l	#AwardPictureY,a0
	move.w	(a0,d0.w),(printy).w
	move.w	(AwardIndex).w,d0
	asl.w	#2,d0
	movea.l	#AwardPictures,a0
	movea.l	(a0,d0.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	move.w	#1,d5
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	move.w	(awardpicchars).w,d4
	jsr	(dobitmap).l
	move.w	#$64,(palcount).w
	rts

AwardPictures	;IDA: unk_9CA40. 95 only. The award picture bitmaps, one per award
	dc.l	HartPic
	dc.l	NorrisPic
	dc.l	VezinaPic
	dc.l	ArtRossPic
	dc.l	JenningsPic
	dc.l	PearsonPic
	dc.l	SelkePic
	dc.l	PresidentsPic
	dc.l	ConnSmythePic

AwardPictureX	;IDA: unk_9CA64. 95 only. DrawAwardPicture x of each award picture
	dc.w	$7,$7,$6,$6,$6,$7,$5,$5,$6

AwardPictureY	;IDA: unk_9CA76. 95 only. DrawAwardPicture y of each award picture
	dc.w	$5,$5,$5,$5,$5,$5,$5,$4,$5

DrawFinalistsPanel	;IDA: sub_9CA88. 95 only. Draw the finalists panel (FinalistsPanelMap) at 31,9
	jsr	(printz).l
	String	$FF,$1F,$9,$0
	movea.l	#FinalistsPanelMap,a0
	bra.w	DrawAwardPanel

DrawWinnerPanel	;IDA: sub_9CA9E. 95 only. Draw the winner panel (WinnerPanelMap) at 29,9
	jsr	(printz).l
	String	$FF,$1D,$9,$0
	movea.l	#WinnerPanelMap,a0
	bra.w	DrawAwardPanel

DrawAwardPanel	;IDA: loc_9CAB4. 95 only. Draw the panel bitmap a0 at awardpanelchars (dobitmap)
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	move.w	#0,d5
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	move.w	(awardpanelchars).w,d4
	jmp	(dobitmap).l

AwardWinnerNop	;IDA: nullsub_6. 95 only. Does nothing (AwardsLoop calls it after DrawWinnerPanel)
	rts

PrintFinalists	;IDA: sub_9CAD6. 95 only. "FINALISTS:" and the 3 finalists (player names, or teams for a team award), the highlight (AwardHilite) moving every AwardCycle frames; in winner mode (BA_PS_flags bit 1) only the winner (AwardWinner) stays
	btst	#1,(BA_PS_flags).w
	bne.w	.1
	jsr	(printz2).l
	String	$F9,$0,$FE,$1,$FF,$1,$FD,$11,$FC,$6,'FINALISTS:'
	move.w	(AwardFlashTimer).w,d0
	ext.l	d0
	divu.w	(AwardCycle).w,d0
	swap	d0
	tst.w	d0
	bne.w	.1
	cmpi.l	#$F0,(AwardTimer).w
	blt.w	.0
	movea.l	#AwardIds,a0
	move.w	(AwardHilite).w,d0
	move.w	(a0,d0.w),d0
	cmp.w	(AwardWinner).w,d0
	beq.w	.1
.0
	addq.w	#2,(AwardHilite).w
	cmpi.w	#4,(AwardHilite).w
	ble.w	.1
	clr.w	(AwardHilite).w
.1
	jsr	(printz).l
	String	$EF,$11,$8,$0
	clr.w	d1
	movea.l	#AwardIds,a0
.2
	clr.w	(printfontset).w
	cmp.w	(AwardHilite).w,d1
	bne.w	.3
	move.w	#2,(printfontset).w
.3
	btst	#4,(sflags11).w
	beq.w	.7
	move.w	(a0,d1.w),d0
	asl.w	#2,d0
	movea.l	#TeamList,a1
	movea.l	(a1,d0.w),a1
	move.w	4(a1),d0
	ext.l	d0
	adda.l	d0,a1
	move.l	a1,-(sp)
	btst	#1,(BA_PS_flags).w
	beq.w	.4
	tst.w	(printfontset).w
	bne.w	.4
	movea.l	#.6,a1
.4
	jsr	(printsmall).l
	move.w	#$11,(printx).w
	addq.w	#1,(printy).w
	movea.l	(sp)+,a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	btst	#1,(BA_PS_flags).w
	beq.w	.5
	tst.w	(printfontset).w
	bne.w	.5
	movea.l	#.6,a1
.5
	jsr	(printsmall).l
	addq.w	#2,(printy).w
	move.w	#$11,(printx).w
	addq.w	#2,d1
	cmp.w	#4,d1
	ble.w	.2
	rts
.6	;blank String (12 spaces)
	String	'            '
.7
	move.w	(a0,d1.w),d0
	ext.l	d0
	divu.w	#$1A,d0
	move.w	d0,d7
	swap	d0
	movem.w	d0/d7,-(sp)
	jsr	(FormatFirstNameD7).l
	btst	#1,(BA_PS_flags).w
	beq.w	.8
	tst.w	(printfontset).w
	bne.w	.8
	movea.l	#.6,a1
.8
	jsr	(printsmall).l
	move.w	#$11,(printx).w
	addq.w	#1,(printy).w
	movem.w	(sp)+,d0/d7
	jsr	(FormatLastNameD7).l
	btst	#1,(BA_PS_flags).w
	beq.w	.9
	tst.w	(printfontset).w
	bne.w	.9
	movea.l	#.6,a1
.9
	jsr	(printsmall).l
	addq.w	#2,(printy).w
	move.w	#$11,(printx).w
	addq.w	#2,d1
	cmp.w	#4,d1
	ble.w	.2
	rts

FlashWinnerCaption	;IDA: sub_9CC7A. 95 only. Flash "The Winner !" (AwardFlashTimer: on $1E frames, off to $3C)
	jsr	(printz2).l
	String	$F9,$0,$FE,$1,$FF,$1,$FD,$11,$FC,$6,'          '
	move.w	#2,(printfontset).w
	move.w	(AwardFlashTimer).w,d0
	cmp.w	#$1E,d0
	blt.w	.0
	move.w	#0,(printfontset).w
	cmp.w	#$3C,d0
	blt.w	.0
	clr.w	(AwardFlashTimer).w
.0
	jsr	(printz2).l
	String	$FE,$1,$FF,$1,$FD,$12,$FC,$6,'The Winner !'
	rts

AwardsLoop	;IDA: sub_9CCD8. 95 only. Awards frames: finalists for $12C frames, then the winner to $258, then the next award; d1 = a pad button (exit), 0 after the last award or AwardWait frames
	move.w	#$5460,(AwardWait).w
.0
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.0
	move.w	(vcount).w,(oldvcount).w
	tst.l	(AwardTimer).w
	bne.w	.1
	bsr.w	DrawFinalistsPanel
.1
	addq.w	#1,(AwardFlashTimer).w
	addq.l	#1,(AwardTimer).w
	cmpi.l	#$12C,(AwardTimer).w
	bge.w	.2
	bclr	#1,(BA_PS_flags).w
	bsr.w	PrintFinalists
	bra.w	.4
.2
	cmpi.l	#$12C,(AwardTimer).w
	bne.w	.3
	bsr.w	DrawWinnerPanel
	bsr.w	AwardWinnerNop
.3
	bsr.w	FlashWinnerCaption
	bset	#1,(BA_PS_flags).w
	bsr.w	PrintFinalists
.4
	cmpi.l	#$258,(AwardTimer).w
.5
	blt.w	.7
	addq.w	#1,(AwardIndex).w
	cmpi.w	#9,(AwardIndex).w
	blt.w	.6
	clr.w	d1
	rts
.6
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	#$7FF,d2
	move.w	#$28,d0
	move.w	#$1C,d1
	jsr	(eraser).l
	move.w	#$18,(palcount).w
	bsr.w	DrawFinalistsPanel
	clr.w	(AwardHilite).w
	clr.l	(AwardTimer).w
	move.w	#$F,(AwardCycle).w
	bsr.w	FindAwardFinalists
	bsr.w	PrintAwardTitle
	bsr.w	DrawAwardPicture
.7
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.8
	bra.w	.12
.8
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.9
	bra.w	.12
.9
	tst.w	(FourWayPlay).w
	beq.w	.11
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.10
	bra.w	.12
.10
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.11
	bra.w	.12
.11
	subq.w	#1,(AwardWait).w
	bpl.w	.0
.12
	rts

AwardsScreenSetup	;IDA: sub_9CE08. 95 only. Awards screen setup: vram layout, the small font (two remaps) and the background bitmap (AwardsBgMap)
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
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$44,$67,$89,$AB,$CD,$EF
	move.l	#SmallFontMap,(smallfontptr).l
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	#AwardsBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	move.w	d4,(awardpicchars).w
	addi.w	#$78,d4
	move.w	d4,(awardpanelchars).w
	rts

FindAwardFinalists	;IDA: sub_9CEDC. 95 only. Score the candidates of award AwardIndex (AwardScanTbl), sort them (SortAwardScores), keep the winner in AwardWinner and put the top 3 in a random order
	move.w	(AwardIndex).w,d0
	asl.w	#2,d0
	movea.l	#AwardScanTbl,a0
	movea.l	(a0,d0.w),a0
	bclr	#4,(sflags11).w
	cmpa.l	#ScanPresidents,a0
	bne.w	.0
	bset	#4,(sflags11).w
.0
	jsr	(a0)
	bsr.w	SortAwardScores
	bclr	#6,(sflags12).w
	movea.l	#AwardIds,a0
	move.w	(a0),(AwardWinner).w
	move.w	#2,d0
	jsr	(randomd0).l
	add.w	d0,d0
	move.w	(a0,d0.w),d2
	addq.w	#2,d0
	cmp.w	#4,d0
	ble.w	.1
	clr.w	d0
.1
	move.w	(a0,d0.w),d3
	addq.w	#2,d0
	cmp.w	#4,d0
	ble.w	.2
	clr.w	d0
.2
	move.w	(a0,d0.w),d4
	move.w	d2,(a0)
	move.w	d3,2(a0)
	move.w	d4,4(a0)
	rts

SortAwardScores	;IDA: sub_9CF54. 95 only. Bubble sort AwardScores (with AwardIds), highest first, lowest first with sflags12 bit 6
	btst	#6,(sflags12).w
	bne.w	.2
	move.w	(AwardCount).w,d1
	subq.w	#2,d1
	bmi.w	.5
	movea.l	#AwardIds,a1
	movea.l	#AwardScores,a0
	clr.w	d0
	clr.w	(TempWord1).w
.0
	move.w	(a0,d0.w),d2
	move.w	2(a0,d0.w),d3
	cmp.w	d2,d3
	ble.w	.1
	st	(TempWord1).w
	move.w	d2,2(a0,d0.w)
	move.w	d3,(a0,d0.w)
	move.w	(a1,d0.w),d2
	move.w	2(a1,d0.w),d3
	move.w	d2,2(a1,d0.w)
	move.w	d3,(a1,d0.w)
.1
	addq.w	#2,d0
	dbf	d1,.0
	tst.w	(TempWord1).w
	beq.w	.5
	bra.s	SortAwardScores
.2
	move.w	(AwardCount).w,d1
	subq.w	#2,d1
	bmi.w	.5
	movea.l	#AwardIds,a1
	movea.l	#AwardScores,a0
	clr.w	d0
	clr.w	(TempWord1).w
.3
	move.w	(a0,d0.w),d2
	move.w	2(a0,d0.w),d3
	cmp.w	d2,d3
	bge.w	.4
	st	(TempWord1).w
	move.w	d2,2(a0,d0.w)
	move.w	d3,(a0,d0.w)
	move.w	(a1,d0.w),d2
	move.w	2(a1,d0.w),d3
	move.w	d2,2(a1,d0.w)
	move.w	d3,(a1,d0.w)
.4
	addq.w	#2,d0
	dbf	d1,.3
	tst.w	(TempWord1).w
	beq.w	.5
	bra.s	.2
.5
	rts

AwardScanTbl	;IDA: unk_9D00C. 95 only. The award scans in award order (Hart ... Conn Smythe)
	dc.l	ScanHart
	dc.l	ScanNorris
	dc.l	ScanVezina
	dc.l	ScanArtRoss
	dc.l	ScanJennings
	dc.l	ScanPearson
	dc.l	ScanSelke
	dc.l	ScanPresidents
	dc.l	ScanConnSmythe

ScanConnSmythe	;no IDA label. 95 only. Conn Smythe: skaters by playoff points (ConnSmytheScore)
	movea.l	#ConnSmytheScore,a6
	bsr.w	ScanAllPlayers
	rts

rtsAwardScan	;no IDA label. 95 only. Not used
	rts

ScanPresidents	;IDA: unk_9D03E. 95 only. Presidents Trophy: the 26 teams by regular season points (ReadStandings with SeasonFlags bit 5 clear, PresidentsScore)
	movea.l	#PresidentsScore,a6
	move.l	a0,-(sp)
	movea.l	#StandingsBuf,a0
	move.b	(SeasonDay+1).w,-(sp)
	bclr	#5,(SeasonDay+1).w
	jsr	(ReadStandings).l
	move.b	(sp)+,(SeasonDay+1).w
	movea.l	(sp)+,a0
	move.w	#$19,d7
	movea.l	#AwardIds,a1
	movea.l	#AwardScores,a2
	clr.w	(AwardCount).w
.0
	movem.l	d1-d3/a1-a2,-(sp)
	jsr	(a6)
	movem.l	(sp)+,d1-d3/a1-a2
	addq.w	#1,(AwardCount).w
	move.w	d7,(a1)+
	move.w	d5,(a2)+
	dbf	d7,.0
	rts

ScanSelke	;no IDA label. 95 only. Selke: forwards (SelkeScore)
	movea.l	#SelkeScore,a6
	bsr.w	ScanAllPlayers
	rts

ScanPearson	;no IDA label. 95 only. Pearson: skaters by points (PearsonScore)
	movea.l	#PearsonScore,a6
	bsr.w	ScanAllPlayers
	rts

ScanJennings	;no IDA label. 95 only. Jennings: goalies by goals against average, lowest first (JenningsScore, sflags12 bit 6)
	movea.l	#JenningsScore,a6
	bsr.w	ScanAllPlayers
	bset	#6,(sflags12).w
	rts

ScanArtRoss	;no IDA label. 95 only. Art Ross: skaters by points (ArtRossScore)
	movea.l	#ArtRossScore,a6
	bsr.w	ScanAllPlayers
	rts

ScanNorris	;no IDA label. 95 only. Norris: defensemen (NorrisScore)
	movea.l	#NorrisScore,a6
	bsr.w	ScanAllPlayers
	rts

ScanHart	;no IDA label. 95 only. Hart: all players (HartScore)
	movea.l	#HartScore,a6
	bsr.w	ScanAllPlayers
	rts

ScanVezina	;no IDA label. 95 only. Vezina: goalies (VezinaScore)
	movea.l	#VezinaScore,a6
	bsr.w	ScanAllPlayers
	rts

ScanAllPlayers	;no IDA label. 95 only. Every player d1 of the 26 teams (d7): when the score routine a6 qualifies him (d5 >= 0), add d1 to AwardIds and d5 to AwardScores (AwardCount)
	clr.w	d1
	clr.w	d7
	movea.l	#AwardIds,a1
	movea.l	#AwardScores,a2
	clr.w	(AwardCount).w
.0
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	move.w	d0,-(sp)
	jsr	(ReadAttributeNibbleD7).l
	move.w	d0,d2
	move.w	(sp),d0
	jsr	(GetPlayerCountD7).l
	move.w	d0,d3
.1
	movem.l	d1-d3/a1-a2,-(sp)
	jsr	(a6)
	movem.l	(sp)+,d1-d3/a1-a2
	bmi.w	.2
	addq.w	#1,(AwardCount).w
	move.w	d1,(a1)+
	move.w	d5,(a2)+
.2
	addq.w	#1,(sp)
	move.w	(sp),d0
	addq.w	#1,d1
	cmp.w	d3,d0
	bge.w	.3
	bra.s	.1
.3
	tst.w	(sp)+
	addq.w	#1,d7
	cmp.w	#$1A,d7
	bge.w	.4
	move.w	d7,d1
	mulu.w	#$1A,d1
	bra.s	.0
.4
	rts

ConnSmytheScore	;no IDA label. 95 only. Score: skaters (from d2, the goalie count), playoff goals + assists (sflags11 bit 3)
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	cmp.w	d0,d2
	bgt.w	AwardNotQualified
	bset	#3,(sflags11).w
	bsr.w	GetAwardGoals
	bsr.w	GetAwardAssists
	bclr	#3,(sflags11).w
	add.w	d6,d5
	beq.w	AwardNotQualified
	bra.w	AwardQualifies

PresidentsScore	;no IDA label. 95 only. Score: team d7, 2 * wins + ties (StandingsBuf)
	movem.l	d0/a0,-(sp)
	movea.l	#StandingsBuf,a0
	move.w	d7,d0
	mulu.w	#3,d0
	adda.l	d0,a0
	clr.w	d3
	clr.w	d5
	move.b	(a0),d5
	add.b	d5,d5
	add.b	1(a0),d5
	movem.l	(sp)+,d0/a0
	bra.w	AwardQualifies
	rts

SelkeScore	;no IDA label. 95 only. Score: forwards (d2 up to GetDefenseStartD7) with 10 goals per 100 games or more; the score adds two rating nibbles (GetRosterName)
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	move.w	d0,d6
	cmp.w	d2,d6
	blt.w	AwardNotQualified
	jsr	(GetDefenseStartD7).l
	cmp.w	d0,d6
	bge.w	AwardNotQualified
	jsr	(GetAwardGoals).l
	movem.l	d4,-(sp)
	movem.l	d7/a0,-(sp)
	movea.l	#$2035EC,a0
	mulu.w	#6,d7
	clr.w	d4
	move.b	1(a0,d7.w),d4
	add.b	3(a0,d7.w),d4
	add.b	5(a0,d7.w),d4
	movem.l	(sp)+,d7/a0
	mulu.w	#$64,d5
	tst.w	d4
	beq.w	.0
	divu.w	d4,d5
	movem.l	(sp)+,d4
	cmp.w	#$A,d5
	blt.w	AwardNotQualified
	move.w	d6,d0
	jsr	(GetRosterName).l
	adda.w	(a1),a1
	move.b	4(a1),d0
	lsr.w	#4,d0
	andi.w	#$F,d0
	move.b	3(a1),d0
	lsr.w	#4,d5
	andi.w	#$F,d5
	add.w	d0,d5
	bra.w	AwardQualifies
	rts
.0
	movem.l	(sp)+,d4
	bra.w	AwardNotQualified

PearsonScore	;no IDA label. 95 only. Score: skaters, goals + assists
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	cmp.w	d0,d2
	bgt.w	AwardNotQualified
	bsr.w	GetAwardGoals
	bsr.w	GetAwardAssists
	add.w	d6,d5
	beq.w	AwardNotQualified
	bra.w	AwardQualifies
	rts

JenningsScore	;no IDA label. 95 only. Score: goalies who played half the games or more, 100 * goals against / minutes (GetGoalieAwardStats)
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	move.w	d0,d6
	jsr	(ReadAttributeNibbleD7).l
	cmp.w	d0,d6
	bge.w	AwardNotQualified
	movem.l	d7/a0,-(sp)
	movea.l	#$2035EC,a0
	mulu.w	#6,d7
	clr.w	d4
	move.b	1(a0,d7.w),d4
	add.b	3(a0,d7.w),d4
	add.b	5(a0,d7.w),d4
	movem.l	(sp)+,d7/a0
	bsr.w	GetGoalieAwardStats
	tst.w	d4
	beq.w	AwardNotQualified
	movem.l	d5-d6,-(sp)
	mulu.w	#$64,d6
	divu.w	d4,d6
	cmp.w	#$32,d6
	movem.l	(sp)+,d5-d6
	blt.w	AwardNotQualified
	mulu.w	#$64,d5
	divu.w	d6,d5
	bra.w	AwardQualifies

ArtRossScore	;no IDA label. 95 only. Score: skaters, goals + assists
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	move.w	d0,d6
	jsr	(ReadAttributeNibbleD7).l
	cmp.w	d0,d6
	blt.w	AwardNotQualified
	bsr.w	GetAwardGoals
	bsr.w	GetAwardAssists
	add.w	d6,d5
	beq.w	AwardNotQualified
	bra.w	AwardQualifies

VezinaScore	;no IDA label. 95 only. Score: goalies who played a quarter of the games or more, (600 - min(100 * goals against / minutes, 600)) / 10
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	move.w	d0,d6
	jsr	(ReadAttributeNibbleD7).l
	cmp.w	d0,d6
	bge.w	AwardNotQualified
	movem.l	d7/a0,-(sp)
	movea.l	#$2035EC,a0
	mulu.w	#6,d7
	clr.w	d4
	move.b	1(a0,d7.w),d4
	add.b	3(a0,d7.w),d4
	add.b	5(a0,d7.w),d4
	movem.l	(sp)+,d7/a0
	tst.w	d4
	beq.w	AwardNotQualified
	bsr.w	GetGoalieAwardStats
	movem.l	d5-d6,-(sp)
	mulu.w	#$64,d6
	divu.w	d4,d6
	cmp.w	#$19,d6
	movem.l	(sp)+,d5-d6
	blt.w	AwardNotQualified
	mulu.w	#$64,d5
	divu.w	d6,d5
	cmp.w	#$258,d5
	ble.w	.0
	move.w	#$258,d5
.0
	subi.w	#$258,d5
	neg.w	d5
	divu.w	#$A,d5
	bra.w	AwardQualifies

NorrisScore	;no IDA label. 95 only. Score: defensemen, 100 * (6 - min(penalty minutes per game, 6)) + 10 * goals + assists
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	move.w	d0,d6
	jsr	(GetDefenseStartD7).l
	cmp.w	d0,d6
	blt.w	AwardNotQualified
	move.w	d7,d0
	mulu.w	#$A,d0
	add.w	d0,d0
	movea.l	#$20FA5E,a0
	adda.w	d0,a0
	move.b	1(a0),d5
	lsl.w	#8,d5
	move.b	3(a0),d5
	movem.l	d7/a0,-(sp)
	movea.l	#$2035EC,a0
	mulu.w	#6,d7
	clr.w	d6
	move.b	1(a0,d7.w),d6
	add.b	3(a0,d7.w),d6
	add.b	5(a0,d7.w),d6
	movem.l	(sp)+,d7/a0
	ext.l	d5
	tst.w	d6
	beq.w	AwardNotQualified
	divu.w	d6,d5
	cmp.w	#6,d5
	ble.w	.0
	move.w	#6,d5
.0
	subq.w	#6,d5
	neg.w	d5
	mulu.w	#$64,d5
	movea.l	#$204348,a0
	move.w	d1,d0
	asl.w	#2,d0
	move.b	1(a0,d0.w),d6
	lsl.w	#8,d6
	move.b	3(a0,d0.w),d6
	mulu.w	#$A,d6
	add.w	d6,d5
	movea.l	#$204E40,a0
	move.w	d1,d0
	asl.w	#2,d0
	move.b	1(a0,d0.w),d6
	lsl.w	#8,d6
	move.b	3(a0,d0.w),d6
	add.w	d6,d5
	bra.w	AwardQualifies

HartScore	;no IDA label. 95 only. Score: goalies 10 * (3 - min(goals against / minutes, 3)), skaters 2 * goals + assists
	move.w	d1,d0
	ext.l	d0
	divu.w	#$1A,d0
	swap	d0
	cmp.w	d0,d2
	ble.w	.1
	bsr.w	GetGoalieAwardStats
	tst.w	d6
	beq.w	AwardNotQualified
	divu.w	d6,d5
	cmp.w	#3,d5
	ble.w	.0
	move.w	#3,d5
.0
	subq.w	#3,d5
	neg.w	d5
	mulu.w	#$A,d5
	bra.w	AwardQualifies
.1
	bsr.w	GetAwardGoals
	add.w	d5,d5
	bsr.w	GetAwardAssists
	add.w	d6,d5
	beq.w	AwardNotQualified
	bra.w	AwardQualifies

AwardQualifies	;no IDA label. 95 only. Score exit: qualifies (d5 is the score)
	clr.w	d0
	rts

AwardNotQualified	;no IDA label. 95 only. Score exit: does not qualify (d5 = -1)
	move.w	#-1,d5
	rts

GetGoalieAwardStats	;no IDA label. 95 only. d5 / d6 = the goalie stat words of player d1 (save RAM $206F28 / $206430)
	movea.l	#$206F28,a0
	move.w	d1,d0
	asl.w	#2,d0
	move.b	1(a0,d0.w),d5
	lsl.w	#8,d5
	move.b	3(a0,d0.w),d5
	movea.l	#$206430,a0
	move.b	1(a0,d0.w),d6
	lsl.w	#8,d6
	move.b	3(a0,d0.w),d6
	andi.l	#$7FFF,d6
	rts

GetAwardGoals	;no IDA label. 95 only. d5 = goals of player d1 (save RAM $204348, the playoff $20C382 with sflags11 bit 3)
	movea.l	#$204348,a0
	btst	#3,(sflags11).w
	beq.w	.0
	movea.l	#$20C382,a0
.0
	move.w	d1,d0
	asl.w	#2,d0
	move.b	1(a0,d0.w),d5
	lsl.w	#8,d5
	move.b	3(a0,d0.w),d5
	andi.w	#$7FFF,d5
	rts

GetAwardAssists	;no IDA label. 95 only. d6 = assists of player d0 / 4 (save RAM $204E40, the playoff $20CE7A with sflags11 bit 3; the ROM has lsr.w #8, not lsl)
	movea.l	#$204E40,a0
	btst	#3,(sflags11).w
	beq.w	.0
	movea.l	#$20CE7A,a0
.0
	move.b	1(a0,d0.w),d6
	lsr.w	#8,d6
	move.b	3(a0,d0.w),d6
	rts

InitPlayoffs	;IDA: sub_9D4CE. 95 only. Seed the playoffs: the two conferences (ConferenceTeams1 / 2) sorted by points (SortSeeds), 1 v 8 ... 4 v 5 to save RAM $20BFC0 (SeedPairings)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$B,d0
	movea.l	#AwardIds,a0
	movea.l	#ConferenceTeams1,a1
	bsr.w	CopyBytes
	move.w	#$D,d0
	movea.l	#AwardIds+$14,a0
	movea.l	#ConferenceTeams2,a1
	bsr.w	CopyBytes
	movea.l	#StandingsBuf,a0
	jsr	(ReadStandings).l
	bsr.w	CalcSeedPoints
	move.w	#$C,(SeedCount).w
	movea.l	#AwardIds,a0
	bsr.w	SortSeeds
	move.w	#$E,(SeedCount).w
	movea.l	#AwardIds+$14,a0
	bsr.w	SortSeeds
	movea.l	#$20BFC0,a0
	movea.l	#AwardIds,a1
	movea.l	#AwardIds+$14,a2
	bsr.w	SeedPairings
	exg	a1,a2
	bsr.w	SeedPairings
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeedPairings	;IDA: sub_9D552. 95 only. Write the pairings 1 v 8, 2 v 7, 3 v 6, 4 v 5 of the sorted teams a1 to a0
	clr.w	d0
	move.b	(a1),d0
	move.w	d0,(a0)+
	move.b	7(a1),d0
	move.w	d0,(a0)+
	move.b	1(a1),d0
	move.w	d0,(a0)+
	move.b	6(a1),d0
	move.w	d0,(a0)+
	move.b	2(a1),d0
	move.w	d0,(a0)+
	move.b	5(a1),d0
	move.w	d0,(a0)+
	move.b	3(a1),d0
	move.w	d0,(a0)+
	move.b	4(a1),d0
	move.w	d0,(a0)+
	rts

SortSeeds	;IDA: sub_9D584. 95 only. Bubble sort the SeedCount team bytes at a0 by SeedPoints, then SeedGames, highest first
	movea.l	#SeedPoints,a1
	movea.l	#SeedGames,a2
.0
	bclr	#6,(sflags6).w
	clr.w	d7
.1
	clr.w	d6
	move.b	(a0,d7.w),d6
	move.b	(a1,d6.w),d0
	move.b	1(a0,d7.w),d6
	cmp.b	(a1,d6.w),d0
	bgt.w	.3
	blt.w	.2
	move.b	(a0,d7.w),d6
	move.b	(a2,d6.w),d0
	move.b	1(a0,d7.w),d6
	cmp.b	(a2,d6.w),d0
	ble.w	.3
.2
	bset	#6,(sflags6).w
	move.b	(a0,d7.w),d5
	move.b	1(a0,d7.w),d4
	move.b	d5,1(a0,d7.w)
	move.b	d4,(a0,d7.w)
.3
	addq.w	#2,d7
	cmp.w	(SeedCount).w,d7
	bge.w	.4
	subq.w	#1,d7
	bra.s	.1
.4
	btst	#6,(sflags6).w
	bne.s	.0
	rts

CalcSeedPoints	;IDA: sub_9D5F4. 95 only. SeedPoints = 2 * wins + ties and SeedGames = wins + losses + ties of the 26 teams (StandingsBuf)
	move.w	#$1A,d0
	movea.l	#StandingsBuf,a1
	movea.l	#SeedPoints,a2
	movea.l	#SeedGames,a3
	clr.w	d2
	bra.w	.1
.0
	move.w	d2,d5
	mulu.w	#3,d2
	clr.w	d3
	move.b	(a1,d2.w),d3
	add.b	d3,d3
	add.b	1(a1,d2.w),d3
	move.b	d3,(a2,d5.w)
	move.b	(a1,d2.w),d3
	add.b	1(a1,d2.w),d3
	add.b	2(a1,d2.w),d3
	move.b	d3,(a3,d5.w)
	move.w	d5,d2
	addq.w	#1,d2
.1
	dbf	d0,.0
	rts

CopyBytes	;IDA: sub_9D640. 95 only. Copy d0 + 1 bytes from a1 to a0
	move.b	(a1)+,(a0)+
	dbf	d0,CopyBytes
	rts

ConferenceTeams1	;IDA: unk_9D648. 95 only. The 12 teams of the first conference
	dc.b	0,3,7,$A,$13,$17,4,5,6,$14,$16,$19

ConferenceTeams2	;IDA: unk_9D654. 95 only. The 14 teams of the second conference
	dc.b	1,2,9,$B,$F,$11,$12,8,$C,$D,$E,$10,$15,$18

SetupPlayoffs	;IDA: sub_9D662. 95 only. Start the playoffs: save the season header ($20BFAC), reset it for the playoffs (SeasonFlags bit 5), clear the playoff stats, round 1 (NextPlayoffRound)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$201C44,a0
	movea.l	#$20BFAC,a1
	move.w	#8,d0
	subq.w	#1,d0
.0
	move.w	(a0)+,(a1)+
	dbf	d0,.0
	movea.l	#$201C44,a0
	clr.w	(a0)
	move.w	#1,d0
	btst	#1,(SeasonDay+1).w
	beq.w	.1
	move.w	#7,d0
.1
	move.w	d0,2(a0)
	clr.w	4(a0)
	jsr	(ReadSeasonHeader).l
	bset	#5,(SeasonDay+1).w
	jsr	(WriteSeasonHeader).l
	movea.l	#$201C54,a0
	move.w	#$CCC,d0
	subq.w	#1,d0
.2
	clr.w	(a0)+
	dbf	d0,.2
	movea.l	#$20C2E6,a0
	move.w	#$4E,d0
	subq.w	#1,d0
.3
	clr.w	(a0)+
	dbf	d0,.3
	movea.l	#$20C382,a0
	move.w	#$1B6C,d0
	subq.w	#1,d0
.4
	clr.w	(a0)+
	dbf	d0,.4
	movea.l	#$20FA5A,a0
	move.w	#$104,d0
	subq.w	#1,d0
.5
	clr.w	(a0)+
	dbf	d0,.5
	clr.l	($20BFBC).l
	move.l	#0,($20C000).l
	bsr.w	NextPlayoffRound
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

RestoreSeasonHeader	;no IDA label. 95 only. Put back the season header saved by SetupPlayoffs (ReadSeasonHeader). Nothing calls it
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$201C44,a0
	movea.l	#$20BFAC,a1
	move.w	#8,d0
	subq.w	#1,d0
.0
	move.w	(a1)+,(a0)+
	dbf	d0,.0
	jsr	(ReadSeasonHeader).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

NextPlayoffRound	;IDA: sub_9D748. 95 only. Next playoff round: the winners of the last round (CollectSeriesWinners), the series (InitPlayoffSeries) and the games (PlayoffRoundDone)
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	($20C004).l
	move.l	($20C000).l,d0
	tst.b	d0
	beq.w	.0
	bsr.w	CollectSeriesWinners
.0
	bsr.w	InitPlayoffSeries
	bsr.w	PlayoffRoundDone
	movem.l	(sp)+,d0-d7/a0-a6
	rts

InitPlayoffSeries	;IDA: sub_9D770. 95 only. The series of the round at save RAM $20C008 ($20 bytes each: the two teams, wins cleared)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	GetRoundPairings
	movea.l	#$20C008,a0
	bsr.w	SeriesInRound
	move.w	d0,d5
	subq.w	#1,d5
.0
	move.w	(a1)+,d0
	andi.w	#$FF,d0
	ext.l	d0
	move.l	d0,(a0)
	move.w	(a1)+,d0
	andi.w	#$FF,d0
	ext.l	d0
	move.l	d0,4(a0)
	move.l	#$10000,$1C(a0)
	clr.l	8(a0)
	clr.l	$C(a0)
	adda.w	#$20,a0
	dbf	d5,.0
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayoffRoundDone	;IDA: sub_9D7C0. 95 only. The games of day SeasonDay: the series of the round not yet won (4 wins, 1 without SeasonFlags bit 1); d0 = the count (0 = round over)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$20C10A,a0
	clr.w	d0
	move.b	(SeasonDay).w,d0
	bra.w	.1
.0
	move.w	(a0)+,d1
	andi.w	#$FF,d1
	asl.w	#2,d1
	adda.w	d1,a0
.1
	dbf	d0,.0
	bsr.w	GetRoundPairings
	movea.l	a0,a2
	clr.w	(a0)
	addq.w	#2,a2
	bsr.w	SeriesInRound
	subq.w	#1,d0
	movea.l	#$20C010,a4
.2
	move.w	2(a4),d1
	move.b	#4,d6
	btst	#1,(SeasonDay+1).w
	bne.w	.3
	move.b	#1,d6
.3
	cmp.b	d6,d1
	bge.w	.5
	move.w	6(a4),d1
	move.b	#4,d6
	btst	#1,(SeasonDay+1).w
	bne.w	.4
	move.b	#1,d6
.4
	cmp.b	d6,d1
	bge.w	.5
	move.w	(a1),(a2)+
	move.w	2(a1),(a2)+
	addq.w	#1,(a0)
.5
	addq.w	#4,a1
	adda.w	#$20,a4
	dbf	d0,.2
	move.l	a0,-(sp)
	jsr	(MakeSRAMChecksum).l
	movea.l	(sp)+,a0
	move.w	(a0),d0
	tst.b	d0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeriesInRound	;IDA: sub_9D856. 95 only. d0 = the series in the round (SeriesCountTbl)
	movem.l	a3,-(sp)
	movea.l	#SeriesCountTbl,a3
	move.w	($20C002).l,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d0
	movem.l	(sp)+,a3
	rts

SeriesCountTbl	;IDA: unk_9D876. 95 only. Series per round
	dc.w	8,4,2,1

GetRoundPairings	;IDA: sub_9D87E. 95 only. a1 = the pairings of the round in save RAM $20BFC0 (RoundPairOffsets)
	movem.l	d0/a0,-(sp)
	movea.l	#$20BFC0,a1
	move.w	($20C002).l,d0
	andi.w	#$FF,d0
	movea.l	#RoundPairOffsets,a0
	move.b	(a0,d0.w),d0
	andi.w	#$FF,d0
	adda.w	d0,a1
	movem.l	(sp)+,d0/a0
	rts

RoundPairOffsets	;IDA: unk_9D8A8. 95 only. GetRoundPairings offset of each round
	dc.b	0,$20,$30,$38,$3C,$FF

ReadPlayoffSchedule	;IDA: sub_9D8AE. 95 only. PlayoffSchedule = the low bytes of the $EF words at save RAM $20C108
	movem.l	d4-d5/a5-a6,-(sp)
	movea.l	#$20C108,a5
	move.w	#$EF,d4
	subq.w	#1,d4
	movea.l	#picturebuf,a6
.0
	move.w	(a5)+,d5
	move.b	d5,(a6)+
	dbf	d4,.0
	movem.l	(sp)+,d4-d5/a5-a6
	rts

RecordPlayoffGame	;IDA: sub_9D8D2. 95 only. In the playoffs (SeasonFlags bit 5): add the game a0 (teams, scores) to its series wins
	btst	#5,(SeasonDay+1).w
	beq.w	.5
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d0
	move.b	(a0),d0
	movea.l	#$20C008,a1
.0
	move.l	(a1),d1
	cmp.b	d0,d1
	beq.w	.1
	move.l	4(a1),d1
	cmp.b	d0,d1
	beq.w	.1
	adda.w	#$20,a1
	bra.s	.0
.1
	move.b	3(a0),d1
	cmp.b	2(a0),d1
	blt.w	.2
	move.b	1(a0),d0
.2
	move.l	(a1),d1
	cmp.b	d0,d1
	beq.w	.3
	move.l	$C(a1),d1
	addq.b	#1,d1
	move.l	d1,$C(a1)
	bra.w	.4
.3
	move.l	8(a1),d1
	addq.b	#1,d1
	move.l	d1,8(a1)
.4
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
.5
	rts

CollectSeriesWinners	;IDA: sub_9D93E. 95 only. The winners of the round series to the next round pairings (RoundSeriesOffsets, RoundSeriesCounts)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$20BFC0,a0
	move.l	($20C000).l,d0
	andi.w	#$FF,d0
	move.w	d0,-(sp)
	add.w	d0,d0
	movea.l	#RoundSeriesOffsets,a1
	move.w	(a1,d0.w),d0
	adda.w	d0,a0
	movea.l	#RoundSeriesCounts,a1
	move.w	(sp)+,d0
	move.b	(a1,d0.w),d0
	move.w	d0,d1
	asr.w	#1,d1
	subq.w	#1,d1
	movea.l	#$20C008,a1
.0
	move.l	(a1),d2
	move.l	8(a1),d3
	move.l	$C(a1),d4
	cmp.b	d4,d3
	bgt.w	.1
	move.l	4(a1),d2
.1
	move.w	d2,-(sp)
	adda.w	#$20,a1
	move.l	(a1),d2
	move.l	8(a1),d3
	move.l	$C(a1),d4
	cmp.b	d4,d3
	bgt.w	.2
	move.l	4(a1),d2
.2
	adda.w	#$20,a1
	move.w	(sp)+,(a0)+
	move.w	d2,(a0)+
	dbf	d1,.0
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

RoundSeriesOffsets	;IDA: unk_9D9C0. 95 only. CollectSeriesWinners pairing offset of each round
	dc.w	0,$20,$30,$38

RoundSeriesCounts	;IDA: unk_9D9C8. 95 only. CollectSeriesWinners series of each round
	dc.b	0,8,4,2,1,$FF

PlayoffTreeScreen	;no IDA label. 95 only. Playoff tree: the series (gsstruct), bosgames, gamelevel and the pairings (potree) from save RAM, then PlayoffScreen (sflags11 bit 2)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#7,d0
	movea.l	#gsstruct,a0
	movea.l	#$20C008,a1
	move.w	#$40,d1
.0
	move.l	(a1)+,d2
	andi.w	#$FF,d2
	move.w	d2,(a0)+
	dbf	d1,.0
	move.l	($20C004).l,d0
	andi.w	#$FF,d0
	move.w	d0,(bosgames).w
	btst	#1,(SeasonDay+1).w
	bne.w	.1
	move.w	#7,(bosgames).w
.1
	move.l	($20C000).l,d0
	andi.w	#$FF,d0
	move.w	d0,(gamelevel).w
	bset	#2,(sflags11).w
	move.w	#$20,d0
	subq.w	#1,d0
	movea.l	#$20BFC0,a0
	movea.l	#potree,a1
.2
	move.w	(a0)+,d1
	move.b	d1,(a1)+
	dbf	d0,.2
	jsr	(PlayoffScreen).l
	bclr	#2,(sflags11).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts
