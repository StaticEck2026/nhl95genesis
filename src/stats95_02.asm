;	NHL 95 stats95_02. Retail $0A0B3E-$0A12A9 (1900 bytes).
;	Mapped to stats94 (58%): ScoringSummaryScreen ... DisplayPenaltyEntry (the goal and penalty summaries); before them updatecrowdf (hockey94)
;	and showcrowd (display94), with the 95 crowd frame table.
;	IDA left ScoringSummaryScreen ... DisplayPenaltyEntry ($0A0D1A-$0A12A9) as dc.b; it is transcribed from the retail bytes.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

updatecrowdf	;IDA: sub_A0B3E. hockey94 updatecrowdf. Every game loop, d7 = elapsed frames: the crowd level falls (faster when loud); every $10 frames the next crowd frame of CrowdFrameTbl (crowdtblidx) in crowdframe.
	;95: a frame table instead of the 94 random frame / time pairs
	cmpi.w	#$15E,(crowdlevel).w
	blt.w	.0
	subq.w	#3,(crowdlevel).w
.0
	sub.w	d7,(crowdlevel).w
	bpl.w	.1
	clr.w	(crowdlevel).w
.1
	sub.w	d7,(crowdcnt).w
	bpl.w	.3
	move.w	#$10,(crowdcnt).w
	movem.w	d0/a0,-(sp)
	movea.l	#CrowdFrameTbl,a0
	move.w	(crowdtblidx).w,d0
	addq.w	#1,d0
	tst.b	(a0,d0.w)
	bpl.w	.2
	clr.w	d0
.2
	move.w	d0,(crowdtblidx).w
	move.b	(a0,d0.w),d0
	ext.w	d0
	subq.w	#1,d0
	move.w	d0,(crowdframe).w
	movem.w	(sp)+,d0/a0
.3
	rts

CrowdFrameTbl	;IDA: unk_A0B96. 95 only. updatecrowdf crowd animation frames, -1 wraps
	dc.b	1,2,3,4,5,6,5,6,5,9,$A,4,3,4,3,4
	dc.b	5,4,3,4,5,6,7,8,9,$A,$B,$C,9,$A,8,7
	dc.b	6,5,4,$C,9,$A,5,6,7,8,1,2,3,4,5,6
	dc.b	7,8,9,$A,1,2,3,4,3,4,$B,$C,3,4,5,6
	dc.b	7,8,9,$A,$B,$C,1,2,3,4,5,4,5,9,$A,$B
	dc.b	4,5,4,3,2,3,4,5,4,5,$B,$C,6,7,8,9
	dc.b	$FF,$FF

showcrowd	;IDA: sub_A0BF8. display94 showcrowd. Crowd sprites (CrowdFrameList): up to 3 frames per PBnum nibble (ShowCrowdPb), then the crowdframe frame (ShowCrowdFrame);
	;none in a reverse angle replay (sflags4 bit 4). a6 = sprite table, d6 = link counter
	btst	#4,(sflags4).w
	bne.w	rtsShowCrowd
	movea.l	#CrowdFrameList,a1
	adda.l	4(a1),a1
	move.w	(Hpos).w,d4
	move.w	(Vpos).w,d5
	clr.w	d0
	move.b	(PBnum).w,d2
	moveq	#$C,d3
	bsr.w	ShowCrowdPb
	move.b	(PBnum).w,d2
	lsr.w	#4,d2
	moveq	#$F,d3
	bsr.w	ShowCrowdPb
	move.b	(crowdframe+1).w,d0
	bra.w	ShowCrowdFrame

ShowCrowdPb	;IDA: sub_A0C34. display94 showcrowd .pb. d2 = the count (PBnum nibble, at most 3), d3 = the first frame (ShowCrowdFrame)
	andi.w	#$F,d2
	cmp.w	#3,d2
	bls.w	.0
	moveq	#3,d2
.0
	bra.w	.2
.1
	move.w	d3,d0
	add.w	d2,d0
	bsr.w	ShowCrowdFrame
.2
	dbf	d2,.1
	rts

ShowCrowdFrame	;IDA: sub_A0C54. display94 showcrowd .sc. Crowd frame d0 (0 = none): its sprites in view as sprite table entries at a6 (at most $40)
	ext.w	d0
	beq.w	rtsShowCrowd
	cmp.w	#$40,d6
	bge.w	rtsShowCrowd
	movem.l	d0-d5,-(sp)
	add.w	d0,d0
	movea.l	a1,a0
	move.w	2(a0,d0.w),d1
	sub.w	(a0,d0.w),d1
	lsr.w	#3,d1
	subq.w	#1,d1
	move.w	d1,-(sp)
	adda.w	(a0,d0.w),a0
	move.w	d4,d0
	addi.w	#$C0,d0
	move.w	d0,d1
	subi.w	#$90,d0
	addi.w	#$80,d1
	move.w	#$170,d2
	sub.w	d5,d2
	move.w	d2,d3
	subi.w	#$80,d2
	addi.w	#$70,d3
	move.w	(sp)+,d4
.0
	cmp.w	(a0),d2
	bgt.w	.2
	cmp.w	(a0),d3
	blt.w	.2
	cmp.w	6(a0),d0
	bgt.w	.2
	cmp.w	6(a0),d1
	blt.w	.2
	move.w	(a0),d5
	addi.w	#$80,d5
	sub.w	d2,d5
	move.w	d5,(a6)+
	move.b	2(a0),(a6)+
	andi.b	#$F,-1(a6)
	move.b	d6,(a6)+
	move.b	4(a0),d5
	andi.w	#$F8,d5
	cmpi.w	#$28A,(a0)
	blt.w	.1
	ori.w	#$80,d5
.1
	lsl.w	#8,d5
	move.w	d5,-(sp)
	move.w	4(a0),d5
	andi.w	#$7FF,d5
	add.w	(gamesetuptilesetindex).w,d5
	or.w	(sp)+,d5
	move.w	d5,(a6)+
	move.w	6(a0),d5
	addi.w	#$70,d5
	sub.w	d0,d5
	move.w	d5,(a6)+
	addq.w	#1,d6
	cmp.w	#$40,d6
	beq.w	.3
.2
	addq.w	#8,a0
	dbf	d4,.0
.3
	movem.l	(sp)+,d0-d5

rtsShowCrowd	;IDA: locret_A0D18. display94. Shared rts of showcrowd
	rts

ScoringSummaryScreen	;no IDA label. stats94 ScoringSummaryScreen (93 name). "Scoring Summary": one 4 row entry per goal (6 bytes each from ScoreSum), scrolled with up / down, start exits
	moveq	#9,d0
	moveq	#$19,d1
	move.l	#ControllerBgMap,(screenarg).l
	jsr	(DrawTeamScreen2).l
	jsr	(printbigz).l
	String	$BD,6,1,'Scoring',$BD,$14,1,'Summary',$BD,7,4,0
	move.w	#$2C,d0
	jsr	(PutTeamBlock).l
	addq.w	#3,(printx).w
	clr.w	d0
	jsr	(PutTeamBlock).l
	jsr	(printz2).l
	String	$F8,4,3,0,7,$F9,3,'^^Per^^Time^^Tm^^Goal/Assist^^^^^^P/S^^^',$F9,0
	clr.l	d0
	move.w	(ScoreSumbytes).w,d0
	divu.w	#6,d0
	asl.w	#5,d0
	move.w	d0,(VertLineScrolling).w
	subi.w	#$80,d0
	bpl.w	.0
	clr.w	d0
.0
	move.w	d0,(SelectedPlayerIdx).w
	move.w	(VertLineScrolling).w,d0
.1
	jsr	(vcountwait).l
	bsr.w	UpdateGameStatScroll
	move.w	(VertLineScrolling).w,d0
	subq.w	#2,d0
	cmp.w	(SelectedPlayerIdx).w,d0
	bge.s	.1
	clr.w	(PlayerScrollCtr).w
.2
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	btst	#7,d3
	beq.w	.3
	jmp	(ExitAttributeScreen2).l
.3
	moveq	#-2,d0
	btst	#0,d3
	bne.w	.4
	neg.w	d0
	btst	#1,d3
	beq.w	.5
.4
	move.w	d0,(PlayerScrollCtr).w
.5
	bsr.w	CheckGameStatScroll
	bra.s	.2

CheckGameStatScroll	;no IDA label. stats94 CheckGameStatScroll. Add the scroll speed (PlayerScrollCtr) to the scroll position (VertLineScrolling) within 0 ... SelectedPlayerIdx, then UpdateGameStatScroll
	move.w	(PlayerScrollCtr).w,d0
	beq.w	rtsGameStatScroll
	add.w	(VertLineScrolling).w,d0
	bmi.w	rtsGameStatScroll
	cmp.w	(SelectedPlayerIdx).w,d0
	bgt.w	rtsGameStatScroll

UpdateGameStatScroll	;no IDA label. stats94 UpdateGameStatScroll. Scroll to d0: on an entry boundary the arrows (DrawScrollArrowsPenalty) and stop; the entry coming into view; VSRAM = position - $50
	move.w	(VertLineScrolling).w,d1
	move.w	d0,(VertLineScrolling).w
	ext.l	d0
	divs.w	#$20,d0
	swap	d0
	tst.w	d0
	bne.w	.0
	bsr.w	DrawScrollArrowsPenalty
	clr.w	(PlayerScrollCtr).w
.0
	andi.w	#$1F,d1
	bne.w	.2
	move.l	d0,-(sp)
	cmp.w	#$1E,d0
	bne.w	.1
	bsr.w	DisplayGameStatLineUp
.1
	move.l	(sp)+,d0
	cmp.w	#2,d0
	bne.w	.2
	bsr.w	DisplayGameStatLineDown
.2
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movea.l	#VDP_DATA,a0
	move.l	#$40020010,4(a0)
	moveq	#-$50,d0
	add.w	(VertLineScrolling).w,d0
	move.w	d0,(a0)
	move.w	(sp)+,(disflags).w
	rts

DisplayGameStatLineUp	;no IDA label. stats94 DisplayGameStatLineUp. The goal entry in the high word of d0 at the top of the window
	move.l	d0,-(sp)
	swap	d0
	moveq	#6,d3
	mulu.w	d0,d3
	jsr	(printz).l
	String	$BE,0,0
	move.w	(VertLineScrolling).w,d0
	lsr.w	#3,d0
	subq.w	#3,d0
	andi.w	#$1F,d0
	move.w	d0,(printy).w
	bsr.w	DisplayGameStatEntry
	move.l	(sp)+,d0
	rts

DisplayGameStatLineDown	;no IDA label. stats94 DisplayGameStatLineDown. Goal entry + 4 at the bottom of the window
	move.l	d0,-(sp)
	swap	d0
	addq.w	#4,d0
	moveq	#6,d3
	mulu.w	d0,d3
	jsr	(printz).l
	String	$BE,0,0
	move.w	(VertLineScrolling).w,d0
	lsr.w	#3,d0
	addi.w	#$10,d0
	andi.w	#$1F,d0
	move.w	d0,(printy).w
	bsr.w	DisplayGameStatEntry
	move.l	(sp)+,d0
	rts

DisplayGameStatEntry	;no IDA label. stats94 DisplayGameStatEntry. Goal entry d3: the time, the team, the goal type (GoalTypeTbl), the scorer and the assists (PrintPeriodTime)
	move.w	(printy).w,-(sp)
	moveq	#$28,d0
	moveq	#4,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
	movea.w	#(ScoreSum-M68K_RAM),a0
	move.w	0(a0,d3.w),d0
	move.w	#2,(printx).w
	jsr	(FormatAndPrintTime).l
	movea.w	#(HmShots-M68K_RAM),a2
	btst	#7,2(a0,d3.w)
	beq.w	.0
	adda.w	#$366,a2
.0
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	move.w	#$D,(printx).w
	jsr	(print).l
	move.w	#$23,(printx).w
	lea	GoalTypeTbl(pc),a1
	move.b	2(a0,d3.w),d0
	andi.w	#$7F,d0
	jsr	(PrintSmallListItem).l
	move.w	#$11,(printx).w
	move.b	3(a0,d3.w),d0
	bsr.w	PrintPeriodTime
	move.w	#4,(printfontset).w
	move.w	#$13,(printx).w
	move.b	4(a0,d3.w),d0
	bsr.w	PrintPeriodTime
	move.w	#$13,(printx).w
	move.b	5(a0,d3.w),d0
	bsr.w	PrintPeriodTime
	clr.w	(printfontset).w
	rts

PrintPeriodTime	;no IDA label. stats94 PrintPeriodTime (93 name). Print player d0 (byte, negative = none) and go down a row
	ext.w	d0
	bmi.w	.0
	jsr	(FormatPlayerNameWithAttrib).l
	jsr	(printsmall).l
.0
	addq.w	#1,(printy).w

rtsGameStatScroll	;no IDA label. stats94. Shared rts of CheckGameStatScroll
	rts

GoalTypeTbl	;no IDA label. stats94 GoalTypeTbl (93 name). ScoreSum byte 2 & $7F: SH2, SH, even, PP, PP2
	String	'SH2'
	String	'SH'
	String	' '
	String	'PP'
	String	'PP2'

DrawScrollArrowsPenalty	;no IDA label. stats94 DrawScrollArrowsPenalty (93 name). Summary screen up / down arrows (ScrollArrowTbl). Saves d0-d1/a1
	movem.l	d0-d1/a1,-(sp)
	jsr	(printz2).l
	String	$F8,$4,$3,$1,$9,$F9,$1,$0
	clr.w	d0
	move.w	(VertLineScrolling).w,d1
	tst.w	d1
	sgt	d0
	neg.b	d0
	cmp.w	(SelectedPlayerIdx).w,d1
	slt	d1
	neg.b	d1
	add.b	d1,d0
	add.b	d1,d0
	lea	ScrollArrowTbl(pc),a1
	jsr	(PrintSmallListItem).l
	movem.l	(sp)+,d0-d1/a1
	rts

ScrollArrowTbl	;no IDA label. stats94 ScrollArrowTbl (93 name). None, up, down, both
	String	' ',$FB,$FF,$FA,$10,' ',$F9,$0
	String	'{',$FB,$FF,$FA,$10,' ',$F9,$0
	String	' ',$FB,$FF,$FA,$10,'}',$F9,$0
	String	'{',$FB,$FF,$FA,$10,'}',$F9,$0

PenaltySummaryScreen	;no IDA label. stats94 PenaltySummaryScreen (93 name). "Penalties": one 3 row entry per penalty (4 bytes each from PenSum, PenSumLength), scrolled with up / down, start exits
	moveq	#9,d0
	moveq	#$19,d1
	move.l	#ControllerBgMap,(screenarg).l
	jsr	(DrawTeamScreen2).l
	jsr	(printbigz).l
	String	$BD,$B,$1,'Penalties',$BD,$7,$4,$0
	move.w	#$2C,d0
	jsr	(PutTeamBlock).l
	addq.w	#3,(printx).w
	clr.w	d0
	jsr	(PutTeamBlock).l
	jsr	(printz2).l
	String	$F8,$4,$3,$0,$7,$F9,$3,'^^Per^^Time^^Tm^^Player/Penalty^^^min^^^',$F9,$0,$0
	clr.l	d0
	move.w	(PenSumLength).w,d0
	lsr.w	#2,d0
	mulu.w	#$18,d0
	move.w	d0,(VertLineScrolling).w
	subi.w	#$78,d0
	bpl.w	.0
	clr.w	d0
.0
	move.w	d0,(SelectedPlayerIdx).w
	move.w	(VertLineScrolling).w,d0
.1
	jsr	(vcountwait).l
	bsr.w	UpdatePenaltyScroll
	move.w	(VertLineScrolling).w,d0
	subq.w	#2,d0
	cmp.w	(SelectedPlayerIdx).w,d0
	bge.s	.1
	clr.w	(PlayerScrollCtr).w
.2
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	btst	#7,d3
	beq.w	.3
	jmp	(ExitAttributeScreen2).l
.3
	moveq	#-2,d0
	btst	#0,d3
	bne.w	.4
	neg.w	d0
	btst	#1,d3
	beq.w	.5
.4
	move.w	d0,(PlayerScrollCtr).w
.5
	bsr.w	CheckPenaltyScroll
	bra.s	.2

CheckPenaltyScroll	;no IDA label. stats94 CheckPenaltyScroll. As CheckGameStatScroll for the penalty summary
	move.w	(PlayerScrollCtr).w,d0
	beq.w	rtsPenaltyScroll
	add.w	(VertLineScrolling).w,d0
	bmi.w	rtsPenaltyScroll
	cmp.w	(SelectedPlayerIdx).w,d0
	bgt.w	rtsPenaltyScroll

UpdatePenaltyScroll	;no IDA label. stats94 UpdatePenaltyScroll. As UpdateGameStatScroll for the penalty summary
	move.w	(VertLineScrolling).w,d1
	move.w	d0,(VertLineScrolling).w
	ext.l	d0
	divs.w	#$18,d0
	swap	d0
	tst.w	d0
	bne.w	.0
	bsr.w	DrawScrollArrowsPenalty
	clr.w	(PlayerScrollCtr).w
.0
	ext.l	d1
	divs.w	#$18,d1
	swap	d1
	tst.w	d1
	bne.w	.2
	move.l	d0,-(sp)
	cmp.w	#$16,d0
	bne.w	.1
	bsr.w	DisplayPenaltyLineUp
.1
	move.l	(sp)+,d0
	cmp.w	#2,d0
	bne.w	.2
	bsr.w	DisplayPenaltyLineDown
.2
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movea.l	#VDP_DATA,a0
	move.l	#$40020010,4(a0)
	move.w	#$FFB0,d0
	add.w	(VertLineScrolling).w,d0
	move.w	d0,(a0)
	move.w	(sp)+,(disflags).w

rtsPenaltyScroll	;no IDA label. stats94. Shared rts of CheckPenaltyScroll
	rts

DisplayPenaltyLineUp	;no IDA label. stats94 DisplayPenaltyLineUp. The penalty entry in the high word of d0 at the top of the window
	move.l	d0,-(sp)
	swap	d0
	move.w	d0,d3
	asl.w	#2,d3
	jsr	(printz).l
	String	$BE,$0,$0,$0
	move.w	(VertLineScrolling).w,d0
	lsr.w	#3,d0
	subq.w	#2,d0
	andi.w	#$1F,d0
	move.w	d0,(printy).w
	bsr.w	DisplayPenaltyEntry
	move.l	(sp)+,d0
	rts

DisplayPenaltyLineDown	;no IDA label. stats94 DisplayPenaltyLineDown. Penalty entry + 5 at the bottom of the window
	move.l	d0,-(sp)
	swap	d0
	addq.w	#5,d0
	move.w	d0,d3
	asl.w	#2,d3
	jsr	(printz).l
	String	$BE,$0,$0,$0
	move.w	(VertLineScrolling).w,d0
	lsr.w	#3,d0
	addi.w	#$F,d0
	andi.w	#$1F,d0
	move.w	d0,(printy).w
	bsr.w	DisplayPenaltyEntry
	move.l	(sp)+,d0
	rts

DisplayPenaltyEntry	;no IDA label. stats94 DisplayPenaltyEntry (93 name). PenSum entry d3: time, team (bit 7 of byte 2 = away), minutes and name from PenaltyNames, player (byte 3)
	move.w	(printy).w,-(sp)
	moveq	#$28,d0
	moveq	#3,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
	movea.w	#(PenSum-M68K_RAM),a0
	move.w	(a0,d3.w),d0
	move.w	#2,(printx).w
	jsr	(FormatAndPrintTime).l
	movea.w	#(HmShots-M68K_RAM),a2
	btst	#7,2(a0,d3.w)
	beq.w	.0
	adda.w	#$366,a2
.0
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	move.w	#$D,(printx).w
	jsr	(print).l
	move.b	2(a0,d3.w),d0
	andi.w	#$7F,d0
	movea.l	#PenaltyNames,a3
	adda.w	(a3,d0.w),a3
	clr.w	d0
	move.b	1(a3),d0
	jsr	(PushNumber).l
	move.w	#$23,(printx).w
	jsr	(print).l
	move.w	#$11,(printx).w
	clr.w	d0
	move.b	3(a0,d3.w),d0
	jsr	(FormatPlayerNameWithAttrib).l
	jsr	(print).l
	addq.w	#1,(printy).w
	move.w	#$14,(printx).w
	move.w	#4,(printfontset).w
	lea	2(a3),a1
	jsr	(printsmall).l
	clr.w	(printfontset).w
	rts
