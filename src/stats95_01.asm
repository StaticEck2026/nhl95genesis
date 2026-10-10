;	NHL 95 stats95_01. Retail $0925AE-$0962ED (15680 bytes).
;	Mapped to stats94 (22%), with period94 and data94 moved in. In ROM order: rtsStatTables (period94); the pause menu
;	PLAYER STATS screen (stats94 PlayerStatsScreen ... ScrollArrowTbl2); the 95 season stats save code (InitSeasonStats,
;	SaveSimGame, the player / team stat blocks in save RAM and the game highlights); the 95 season PLAYER STATS, TEAM STATS
;	and LEAGUE LEADERS screens (also the pause menu SEASON PLAYERS / SEASON TEAMS); period94 PeriodStatsScreen; the stats94
;	line editor (LineEditor ... UpdatePlayerAttribute) with the 95 save / load of team lines; data94 DisplayPeriodOver,
;	FindMaxAttributeTEam, CalculateTeamAttributes, CalculateTeamAttributeValues; and the 95 season NHL HIGHLIGHTS screen.
;	Each routine comment names its 94 file or says 95 only (no 94 name). trade95 follows at $0962EE.
;	IDA left $925B0-$92BEB, $933CA-$9342F, $9348A-$95B1D and $95D28-$962ED as dc.b; they are written from the retail bytes,
;	the 94 routines from the 94 source. IDA hid printz Strings; they are String here.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

rtsStatTables	;IDA: locret_925AE
	rts

PlayerStatsScreen	;stats94 PlayerStatsScreen (93 name). Pause menu PLAYER STATS: DisplayAttributeScreen with d7 = 0 (this game)
	clr.w	d7

DisplayAttributeScreen	;stats94 DisplayAttributeScreen (93 name). Stats screen for team a2, d7 = 0 game / 1 playoff
	moveq	#$D,d0
	moveq	#$18,d1
	move.l	#PlayerStatsBgMap,(screenarg).l
	jsr	(DrawTeamScreen3).l
	movem.l	d0-d3/d5-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BD,0,6,0
	movea.l	#PlayerStatsTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#4,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d3/d5-d7/a0-a6
	clr.w	(DispAttribCtr).w
	clr.w	(VertLineScrolling).w
.redraw
	clr.w	(PlayerScrollCtr).w
	jsr	(printz).l
	String	$BD,5,1,0
	tst.w	d7
	beq.w	.title
	jsr	(printbigz).l
	String	$BD,7,4,'Playoff',$BD,$17,4,'Stats',$BD,$E,1,0
	bra.w	.team
.title
	jsr	(printz2).l
	String	$F8,4,3,$C,$1A,$F9,3,'A^-^Switch^Teams',$F9,0,0
	jsr	(printbigz).l
	String	$BD,8,4,'Player',$BD,$15,4,'Stats',$BD,$E,1
.team
	clr.w	d0
	cmpa.w	#(HmShots-M68K_RAM),a2
	beq.w	.home
	move.w	#$2C,d0
.home
	jsr	(PutTeamBlock).l
	bsr.w	DisplayAttributeMenu
	bsr.w	DrawScrollArrowsAttribute
.loop
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	btst	#7,d3
	beq.w	.0
	jmp	(ExitAttributeScreen2).l
.0
	btst	#6,d1
	bne.w	.switch
	jsr	(nodiag).l
	moveq	#1,d0
	btst	#3,d1
	bne.w	.col
	neg.w	d0
	btst	#2,d1
	bne.w	.col
	moveq	#-2,d0
	btst	#0,d3
	bne.w	.set
	neg.w	d0
	btst	#1,d3
	beq.w	.scroll
.set
	move.w	d0,(PlayerScrollCtr).w
.scroll
	bsr.w	UpdateAttributeScroll
	bra.s	.loop
.col
	add.w	(DispAttribCtr).w,d0
	cmp.w	#$FFFF,d0
	blt.s	.scroll
	cmp.w	#4,d0
	bgt.s	.scroll
	move.w	d0,(DispAttribCtr).w
	bsr.w	DisplayAttributeMenu
	bsr.w	DrawScrollArrowsAttribute
	bra.s	.scroll
.switch
	tst.w	d7
	bne.s	.scroll
	lea	tmsize(a2),a2
	cmpa.w	#(AwShots-M68K_RAM),a2
	beq.w	.redraw
	movea.w	#(HmShots-M68K_RAM),a2
	bra.w	.redraw

UpdateAttributeScroll	;stats94 UpdateAttributeScroll (93 name). Stats screen per frame
	move.w	(PlayerScrollCtr).w,d0
	beq.w	rtsAttrib
	add.w	(VertLineScrolling).w,d0
	bmi.w	rtsAttrib
	cmp.w	(SelectedPlayerIdx).w,d0
	bgt.w	rtsAttrib
	move.w	(VertLineScrolling).w,d1
	move.w	d0,(VertLineScrolling).w
	andi.w	#$F,d0
	bne.w	.0
	bsr.w	DrawScrollArrowsAttribute
	clr.w	(PlayerScrollCtr).w
.0
	andi.w	#$F,d1
	bne.w	SetAttribScrollReg
	move.w	d0,-(sp)
	cmp.w	#$E,d0
	bne.w	.1
	bsr.w	DisplayAttributeLineUp
.1
	move.w	(sp)+,d0
	cmp.w	#2,d0
	bne.w	SetAttribScrollReg
	bsr.w	DisplayAttributeLineDown

SetAttribScrollReg	;stats94 SetAttribScrollReg (93 name). VSRAM = VertLineScrolling - $68
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movea.l	#VDP_DATA,a0
	move.l	#$40020010,4(a0)
	move.w	#$FF98,d0
	add.w	(VertLineScrolling).w,d0
	move.w	d0,(a0)
	move.w	(sp)+,(disflags).w

rtsAttrib
	rts

DisplayAttributeLineUp	;stats94 DisplayAttributeLineUp (93 name)
	move.w	(VertLineScrolling).w,d3
	lsr.w	#4,d3
	bra.w	DisplayAttributeEntry

DisplayAttributeLineDown	;stats94 DisplayAttributeLineDown (93 name)
	move.w	(VertLineScrolling).w,d3
	lsr.w	#4,d3
	addq.w	#6,d3
	bra.w	DisplayAttributeEntry

DisplayAttributeMenu	;stats94 DisplayAttributeMenu (93 name)
	jsr	(printz2).l
	String	$F8,4,3,4,9,$F9,1,'Player',$FB,7,0
	lea	AttributeMenuTxt(pc),a1
	moveq	#5,d3
	tst.w	(DispAttribCtr).w
	bmi.w	.0
	adda.w	(a1),a1
	clr.w	d3
.0
	move.w	#$8000,(printa).w
	cmp.w	(DispAttribCtr).w,d3
	bne.w	.1
	move.w	#$C000,(printa).w
.1
	jsr	(printsmall).l
	addq.w	#1,d3
	cmp.w	#5,d3
	blt.s	.0
	jsr	(printz2).l
	String	$F8,4,3,9,7,0
	jsr	(printz2).l
	String	$F9,1
	jsr	(printz).l
	String	$BD,$A,7,0
	lea	AttributeTitleTxt(pc),a1
	moveq	#1,d0
	add.w	(DispAttribCtr).w,d0
	jsr	(PrintSmallListItem).l
	clr.w	(printfontset).w
	movea.w	#(Satt-M68K_RAM),a3
	clr.l	d6
	tst.w	(DispAttribCtr).w
	bpl.w	.2
	jsr	(ReadAttributeNibble).l
	bset	d0,d6
	subq.w	#1,d6
	not.l	d6
.2
	moveq	#-1,d4
	st	d5
	jsr	(GetPlayerCount).l
	bra.w	.6
.3
	btst	d0,d6
	bne.w	.6
	clr.w	d2
	bclr	#2,(sflags5).w
	move.w	(DispAttribCtr).w,d1
	bmi.w	.4
	bsr.w	CheckAttributeValid
.4
	btst	#2,(sflags5).w
	bne.w	.6
	ext.l	d2
	asl.l	#8,d2
	movem.l	d7/a0,-(sp)
	move.w	$28(a2),d7
	jsr	(GetRosterName).l
	adda.w	(a1),a1
	movem.l	(sp)+,d7/a0
	move.b	#$FF,d2
	sub.b	(a1),d2
	cmp.l	d4,d2
	ble.w	.6
	move.l	d2,d4
	move.w	d0,d5
.6
	dbf	d0,.3
	bset	d5,d6
	move.b	d5,(a3)+
	bpl.s	.2
	moveq	#5,d0
.7
	st	0(a3,d0.w)
	dbf	d0,.7
	move.w	a3,d0
	subi.w	#$BC24,d0
	bpl.w	.8
	clr.w	d0
.8
	asl.w	#4,d0
	move.w	d0,(SelectedPlayerIdx).w
	cmp.w	(VertLineScrolling).w,d0
	bcc.w	.9
	move.w	d0,(VertLineScrolling).w
.9
	moveq	#5,d4
.ent
	move.w	(VertLineScrolling).w,d3
	lsr.w	#4,d3
	add.w	d4,d3
	bsr.w	DisplayAttributeEntry
	dbf	d4,.ent
	bra.w	SetAttribScrollReg

DisplayAttributeEntry	;stats94 DisplayAttributeEntry (93 name)
	movea.w	#(Satt-M68K_RAM),a4
	adda.w	d3,a4
	jsr	(printz).l
	String	$BE,0,0,0
	add.w	d3,d3
	andi.w	#$1F,d3
	move.w	d3,(printy).w
	moveq	#$28,d0
	moveq	#1,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	tst.b	(a4)
	bmi.w	rtsAttrib
	subq.w	#1,(printy).w
	move.w	#1,(printx).w
	move.w	a4,d0
	subi.w	#$BC1D,d0
	moveq	#2,d1
	move.w	#$E000,(printa).w
	jsr	(PushNumberWidth).l
	jsr	(print).l
	clr.w	d0
	move.b	(a4),d0
	jsr	(FormatPlayerName).l
	addq.w	#1,(printx).w
	move.w	#$8000,(printa).w
	jsr	(print).l
	move.w	#$11,(printx).w
	tst.w	(DispAttribCtr).w
	bmi.w	.goalie
	clr.w	d5
.0
	clr.w	d0
	move.b	(a4),d0
	move.w	d5,d1
	bsr.w	CheckAttributeValid
	move.w	d2,d0
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	move.w	#$8000,(printa).w
	cmp.w	(DispAttribCtr).w,d5
	bne.w	.1
	move.w	#$C000,(printa).w
.1
	jsr	(print).l
	addq.w	#1,d5
	cmp.w	#5,d5
	bne.s	.0
	bra.w	.x
.goalie
	clr.w	d0
	move.b	(a4),d0
	moveq	#3,d1
	bsr.w	GetAttributeValue2
	clr.w	d0
	move.b	(a4),d0
	moveq	#0,d1
	move.w	d2,-(sp)
	bsr.w	GetAttributeValue2
	move.w	(sp)+,d0
	move.w	d0,d3
	sub.w	d2,d0
	bpl.w	.2
	clr.w	d0
.2
	move.w	d0,d2
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	addq.w	#1,(printx).w
	jsr	(print).l
	move.w	d3,d0
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	addq.w	#2,(printx).w
	jsr	(print).l
	tst.w	d3
	beq.w	.3
	mulu.w	#$64,d2
	divu.w	d3,d2
.3
	move.w	d2,d0
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	addq.w	#2,(printx).w
	jsr	(print).l
	jsr	(printz).l
	String	'%',0
.x
	rts

CheckAttributeValid	;stats94 CheckAttributeValid (93 name). d2 = stat column d1 for player d0. Goalies only have PIM; 95 sets sflags5 bit 2
	;for a goalie column it does not show (DisplayAttributeMenu leaves the player out)
	bclr	#2,(sflags5).w
	move.w	d0,-(sp)
	jsr	(ReadAttributeNibble).l
	move.w	d0,d2
	move.w	(sp)+,d0
	cmp.w	d2,d0
	bge.w	GetAttributeValue2
	clr.w	d2
	btst	d1,#6
	beq.w	SkipAttribute
	moveq	#1,d1

GetAttributeValue2	;stats94 GetAttributeValue2 (93 name). d2 = stat column d1 for player d0. d7 = 0: the team struct byte arrays
	;(AttributeOffsetTbl2); d7 = 1: the playoff tables (GetStatsValue)
	tst.w	d7
	bne.w	GetPlayoffAttribute
	lea	AttributeOffsetTbl2(pc),a1
	asl.w	#2,d1
	adda.w	d1,a1
	move.w	(a1),d1
	add.w	d0,d1
	clr.w	d2
	move.b	0(a2,d1.w),d2
	move.w	2(a1),d1
	bmi.w	rtsAttrib
	add.w	d0,d1
	clr.w	d3
	move.b	0(a2,d1.w),d3
	add.w	d3,d2
	rts

SkipAttribute	;95: the column is not shown for this goalie (sflags5 bit 2)
	bset	#2,(sflags5).w
	rts

GetPlayoffAttribute	;d7 = 1: G, A, ... from the playoff stat tables (GetStatsValue)
	asl.w	#2,d1
	add.w	d0,d0
	clr.w	d2
	bsr.w	GetStatsValue
	addq.w	#2,d1
	bsr.w	GetStatsValue
	lsr.w	#1,d0
	rts

GetStatsValue	;stats94 GetStatsValue (93 name). d2 += word d0 of the RAM table at StatsOffsetTbl2+d1 (0 = none)
	movea.l	#StatsOffsetTbl2,a1
	tst.w	0(a1,d1.w)
	beq.w	rtsAttrib
	movea.w	0(a1,d1.w),a1
	add.w	0(a1,d0.w),d2
	rts

StatsOffsetTbl2	;stats94 StatsOffsetTbl2 (93 name). Playoff stat RAM tables per column (G, A, G+A, SOG, PIM)
	dc.w	$C954,0,$C988,0,$C954,$C988,$C9BC,0,$C9F0,0

AttributeOffsetTbl2	;stats94 AttributeOffsetTbl2 (93 name). Team struct byte arrays per column, same order (94 + 2)
	dc.w	$B6,$FFFF,$D0,$FFFF,$B6,$D0,$EA,$FFFF,$104,$FFFF

AttributeMenuTxt	;stats94 AttributeMenuTxt (93 name). Column headers (goalie header, then 5 columns)
	String	'Saves Shots Save %  '
	String	'   G'
	String	'   A'
	String	' Pts'
	String	' SOG'
	String	' PIM'

AttributeTitleTxt	;stats94 AttributeTitleTxt (93 name). Sort column titles
	String	'    Goalie Saves   ]'
	String	'[      Goals       ]'
	String	'[     Assists      ]'
	String	'[      Points      ]'
	String	'[  Shots On Goal   ]'
	String	'[ Penalty Minutes   '

DrawScrollArrowsAttribute	;stats94 DrawScrollArrowsAttribute (93 name). Up / down arrows (ScrollArrowTbl2). Saves d0-d1/a1
	movem.l	d0-d1/a1,-(sp)
	jsr	(printz2).l
	String	$F8,4,3,'$',$C,$F9,3,0
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
	lea	ScrollArrowTbl2(pc),a1
	jsr	(PrintSmallListItem).l
	movem.l	(sp)+,d0-d1/a1
	rts

ScrollArrowTbl2	;stats94 ScrollArrowTbl2 (93 name). None, up, down, both
	String	' ',$FB,$FF,$FA,$E,' ',$F9,0
	String	'{',$FB,$FF,$FA,$E,' ',$F9,0
	String	' ',$FB,$FF,$FA,$E,'}',$F9,0
	String	'{',$FB,$FF,$FA,$E,'}',$F9,0

InitSeasonStats	;IDA: sub_92BEC
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(M68K_RAM).l,a0
	move.w	#$6DC,d0
	clr.l	d1
.0
	move.l	d1,(a0)+
	dbf	d0,.0
	move.l	#$21A4,d0
	move.l	#$1B6C,d1
	movea.l	#M68K_RAM,a0
	jsr	(WriteSRAM).l
	lea	(LeaderValues).w,a0
	move.w	#$42,d0
	clr.l	d1
.1
	move.l	d1,(a0)+
	dbf	d0,.1
	move.l	#$5D58,d0
	move.l	#$104,d1
	movea.l	#LeaderValues,a0
	jsr	(WriteSRAM).l
	lea	(M68K_RAM).l,a0
	move.w	#$103,d0
	clr.l	d1
.2
	move.b	d1,(a0)+
	dbf	d0,.2
	move.l	#$3D10,d0
	move.l	#$104,d1
	movea.l	#M68K_RAM,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	lea	(M68K_RAM).l,a0
	move.w	#$179,d0
	clr.l	d1
.3
	move.b	d1,(a0)+
	dbf	d0,.3
	move.l	#$5E5C,d0
	move.l	#$17A,d1
	movea.l	#M68K_RAM,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	jsr	(MarkSeasonRosters).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SaveSimGame	;IDA: sub_92CAE
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(HmShots+$28).w,($20FDDC).l
	move.w	(HmGoals).w,d7
	cmp.w	(AwGoals).w,d7
	bgt.w	.0
	move.w	(AwShots+$28).w,($20FDDC).l
.0
	bclr	#0,(SimFlags).w
	move.w	#1,d0
	move.w	(HmGoals).w,d7
	cmp.w	(AwGoals).w,d7
	bgt.w	.1
	beq.w	.3
	move.w	#2,d0
.1
	cmp.w	(cont1team).w,d0
	beq.w	.2
	cmp.w	(cont2team).w,d0
	beq.w	.2
	cmp.w	(cont3team).w,d0
	beq.w	.2
	cmp.w	(cont4team).w,d0
	bne.w	.3
.2
	btst	#1,(SimFlags).w
	beq.w	.3
	bset	#0,(SimFlags).w
.3
	move.w	(HomeTeam).w,d7
	jsr	(ReadAttributeNibbleD7).l
	move.w	d0,d6
	subq.w	#1,d6
	add.w	d6,d6
	move.w	d7,d0
	movea.l	#HmShots,a1
	bsr.w	AddPlayerSeasonStats
	move.w	(VisTeam).w,d0
	movea.l	#AwShots,a1
	bsr.w	AddPlayerSeasonStats
	bsr.w	SaveGameHighlights
	move.w	(HomeTeam).w,d0
	movea.l	#HmShots,a1
	movea.l	#AwShots,a2
	bsr.w	AddTeamSeasonStats
	move.w	(VisTeam).w,d0
	movea.l	#AwShots,a1
	movea.l	#HmShots,a2
	bsr.w	AddTeamSeasonStats
	move.w	(HmShots+$28).w,d0
	move.w	(AwShots+$28).w,d1
	jsr	(TickTeamInjuries).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

AddTeamSeasonStats	;IDA: sub_92D86
	mulu.w	#$A,d0
	btst	#5,(SeasonDay+1).w
	beq.w	.0
	addi.l	#$7D2D,d0
	bra.w	.1
.0
	addi.l	#$3D10,d0
.1
	movea.l	#StatBuf,a0
	moveq	#$A,d1
	movem.l	d0-d1/a0,-(sp)
	jsr	(ReadSRAM).l
	movea.l	#StatBuf,a0
	move.w	$C(a1),d5
	add.w	d5,(a0)
	move.w	$C(a2),d5
	add.w	d5,2(a0)
	move.w	8(a1),d5
	add.w	d5,4(a0)
	move.w	(a1),d5
	add.w	d5,6(a0)
	move.w	(a2),d5
	add.w	d5,8(a0)
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	rts

AddPlayerSeasonStats	;IDA: sub_92DF0
	move.l	#$21A4,d2
	btst	#5,(SeasonDay+1).w
	beq.w	.0
	move.l	#$61C1,d2
.0
	movem.l	d0/a1,-(sp)
	bsr.w	ReadStatBlock
.1
	clr.w	d2
	move.b	$B6(a1),d2
	andi.w	#$7FFF,(a0,d0.w)
	add.w	d2,(a0,d0.w)
	cmp.w	d6,d0
	bgt.w	.2
	ori.w	#$8000,(a0,d0.w)
.2
	addq.w	#1,a1
	addq.w	#2,d0
	dbf	d7,.1
	bsr.w	WriteStatBlock
	movem.l	(sp),d0/a1
	move.l	#$2720,d2
	btst	#5,(SeasonDay+1).w
	beq.w	.3
	move.l	#$673D,d2
.3
	bsr.w	ReadStatBlock
.4
	clr.w	d2
	move.b	$D0(a1),d2
	add.w	d2,(a0,d0.w)
	addq.w	#1,a1
	addq.w	#2,d0
	dbf	d7,.4
	bsr.w	WriteStatBlock
	movem.l	(sp),d0/a1
	move.l	#$2C9C,d2
	btst	#5,(SeasonDay+1).w
	beq.w	.5
	move.l	#$6CB9,d2
.5
	bsr.w	ReadStatBlock
.6
	clr.w	d2
	move.b	$EA(a1),d2
	andi.w	#$7FFF,(a0,d0.w)
	add.w	d2,(a0,d0.w)
	cmp.w	d6,d0
	bgt.w	.7
	ori.w	#$8000,(a0,d0.w)
.7
	addq.w	#1,a1
	addq.w	#2,d0
	dbf	d7,.6
	bsr.w	WriteStatBlock
	movem.l	(sp),d0/a1
	move.l	a4,-(sp)
	movea.l	a1,a4
	move.l	#$3794,d2
	btst	#5,(SeasonDay+1).w
	beq.w	.8
	move.l	#$77B1,d2
.8
	bsr.w	ReadStatBlock
.9
	clr.w	d2
	cmp.w	d6,d0
	bgt.w	.13
	move.b	$B6(a1),d2
	movem.l	d4-d5,-(sp)
	move.w	(PerTimeTotal).w,d4
	add.w	(PerTimeTotal).w,d4
	add.w	(PerTimeTotal).w,d4
	move.w	$138(a4),d5
	beq.w	.12
	ext.l	d4
	divu.w	d5,d4
	cmp.w	#1,d4
	bge.w	.10
	move.w	#1,d4
.10
	mulu.w	d4,d2
	cmp.l	#$7FFF,d2
	blt.w	.11
	move.w	#$7FFF,d2
.11
	add.w	d2,(a0,d0.w)
.12
	movem.l	(sp)+,d4-d5
	bra.w	.14
.13
	move.b	$104(a1),d2
	add.w	d2,(a0,d0.w)
.14
	addq.w	#1,a1
	addq.w	#2,a4
	addq.w	#2,d0
	dbf	d7,.9
	bsr.w	WriteStatBlock
	movea.l	(sp)+,a4
	movem.l	(sp),d0/a1
	move.l	#$3218,d2
	btst	#5,(SeasonDay+1).w
	beq.w	.15
	move.l	#$7235,d2
.15
	bsr.w	ReadStatBlock
.16
	clr.w	d2
	tst.w	$138(a1)
	beq.w	.17
	cmp.w	d6,d0
	bgt.w	.17
	addq.w	#1,(a0,d0.w)
.17
	addq.w	#2,a1
	addq.w	#2,d0
	dbf	d7,.16
	bsr.w	WriteStatBlock
	movem.l	(sp)+,d0/a1
	jsr	(MakeSRAMChecksum).l
	rts

ReadStatBlock	;IDA: sub_92F84
	mulu.w	#$34,d0
	add.l	d2,d0
	movea.l	#StatBuf,a0
	moveq	#$34,d1
	movea.l	#StatWork+$14,a5
	movem.l	d0-d1/a0,-(a5)
	jsr	(ReadSRAM).l
	movea.l	#StatBuf,a0
	clr.w	d0
	move.w	#$19,d7
	rts

WriteStatBlock	;IDA: sub_92FB0
	movem.l	(a5)+,d0-d1/a0
	jmp	WriteSRAM

SaveGameHighlights	;IDA: sub_92FBA
	btst	#3,(SeasonDay+1).w
	bne.w	rtsHighlight
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#StatBuf,a0
	clr.w	(a0)
	bclr	#1,(BA_PS_flags).w
	movea.l	#HmShots,a2
	movea.l	#AwShots,a3
	move.w	(HmGoals).w,d0
	cmp.w	(AwGoals).w,d0
	bgt.w	.1
	blt.w	.0
	bset	#1,(BA_PS_flags).w
	bra.w	.1
.0
	movea.l	#AwShots,a2
	movea.l	#HmShots,a3
.1
	movem.l	a2-a3,-(sp)
	bsr.w	MostGoals
	cmp.w	#2,d2
	blt.w	.2
	move.w	$28(a2),d0
	mulu.w	#$1A,d0
	add.w	d3,d0
	ori.w	#$2000,d0
	bsr.w	AddHighlight
.2
	movem.l	(sp),a2-a3
	movea.l	a3,a2
	bsr.w	MostGoals
	cmp.w	#3,d2
	blt.w	.3
	move.w	$28(a2),d0
	mulu.w	#$1A,d0
	add.w	d3,d0
	ori.w	#$2000,d0
	bsr.w	AddHighlight
.3
	movem.l	(sp),a2-a3
	bsr.w	BestGoalieSaves
	tst.w	$C(a3)
	bne.w	.5
.4
	move.w	$28(a2),d0
	mulu.w	#$1A,d0
	add.w	d3,d0
	ori.w	#$6000,d0
	bsr.w	AddHighlight
	bra.w	.6
.5
	cmp.w	#$18,d2
	bgt.s	.4
.6
	movem.l	(sp),a2-a3
	bsr.w	MostAssists
	move.l	a2,(StatWork).w
	move.w	d2,(SeasonGameCount).w
	move.w	d3,(StatWork+$6).w
	exg	a2,a3
	bsr.w	MostAssists
	cmp.w	(SeasonGameCount).w,d2
	bge.w	.7
	movea.l	(StatWork).w,a2
	move.w	(SeasonGameCount).w,d2
	move.w	(StatWork+$6).w,d3
.7
	cmp.w	#2,d2
	blt.w	.8
	move.w	$28(a2),d0
	mulu.w	#$1A,d0
	add.w	d3,d0
	ori.w	#$4000,d0
	bsr.w	AddHighlight
.8
	nop
	move.w	(StatBuf).w,d0
	andi.w	#$E000,d0
	bne.w	.9
	movem.l	(sp),a2-a3
	bsr.w	MostGoals
	move.w	$28(a2),d0
	mulu.w	#$1A,d0
	add.w	d3,d0
	ori.w	#$2000,d0
	bsr.w	AddHighlight
.9
	movem.l	(sp)+,a2-a3
	jsr	(GetHighlightSlot).l
	tst.w	d0
	bmi.w	.10
	movea.l	#StatBuf,a0
	moveq	#4,d1
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
.10
	movem.l	(sp)+,d0-d7/a0-a6
	rts

BestGoalieSaves	;IDA: sub_93114
	movem.l	d4-d6/a2-a3,-(sp)
	jsr	(ReadAttributeNibble).l
	clr.w	d2
	clr.w	d3
	subq.w	#1,d0
	move.w	d0,d1
	clr.w	d0
	movea.l	a2,a3
	adda.l	#$B6,a2
	adda.l	#$EA,a3
.0
	move.b	(a3,d0.w),d4
	sub.b	(a2,d0.w),d4
	bpl.w	.1
	clr.b	d4
.1
	cmp.b	d4,d2
	bge.w	.2
	move.b	d4,d2
	move.w	d0,d3
.2
	addq.w	#1,d0
	dbf	d1,.0
	movem.l	(sp)+,d4-d6/a2-a3
	rts

MostAssists	;IDA: sub_9315A
	jsr	(ReadAttributeNibble).l
	move.w	#$1A,d1
	sub.w	d0,d1
	subq.w	#1,d1
	clr.w	d2
	clr.w	d3
	move.l	a2,-(sp)
	adda.l	#$D0,a2
.0
	cmp.b	(a2,d0.w),d2
	bge.w	.1
	move.b	(a2,d0.w),d2
	move.w	d0,d3
.1
	addq.w	#1,d0
	dbf	d1,.0
	movea.l	(sp)+,a2
	rts

MostGoals	;IDA: sub_9318C
	jsr	(ReadAttributeNibble).l
	move.w	#$1A,d1
	sub.w	d0,d1
	subq.w	#1,d1
	clr.w	d2
	clr.w	d3
	move.l	a2,-(sp)
	adda.l	#$B6,a2
.0
	cmp.b	(a2,d0.w),d2
	bge.w	.1
	move.b	(a2,d0.w),d2
	move.w	d0,d3
.1
	addq.w	#1,d0
	dbf	d1,.0
	movea.l	(sp)+,a2
	rts

AddHighlight	;IDA: sub_931BE
	move.w	d3,-(sp)
	movem.l	d7,-(sp)
	move.w	d0,d7
	andi.w	#$E000,d7
	move.w	d7,-(sp)
	move.w	d0,d7
	andi.w	#$1FFF,d7
	divu.w	#$1A,d7
	move.l	d7,d0
	swap	d0
	jsr	(GetRosterId).l
	or.w	(sp)+,d0
	movem.l	(sp)+,d7
	move.w	(a0),d1
	bsr.w	CompareHighlight
	beq.w	.1
	move.w	(a0),d1
	andi.w	#$E000,d1
	beq.w	.0
	bne.w	.1
.0
	move.w	d0,(a0)
	move.w	d2,2(a0)
.1
	move.w	(sp)+,d3
	rts

CompareHighlight	;IDA: sub_93208
	move.w	d1,d3
	andi.w	#$E000,d3
	beq.w	.0
	andi.w	#$1FFF,d1
	move.w	d0,d3
	andi.w	#$1FFF,d3
	cmp.w	d1,d3
	rts
.0
	move.w	#1,d3

rtsHighlight	;IDA: locret_93224
	rts

ReadTeamPlayerStats	;IDA: sub_93226
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d7,d0
	mulu.w	#$34,d0
	move.l	d0,-(sp)
	btst	#5,(SeasonDay+1).w
	beq.w	.0
	addi.l	#$61C1,d0
	bra.w	.1
.0
	addi.l	#$21A4,d0
.1
	movea.l	#StatBuf,a0
	moveq	#$34,d1
	jsr	(ReadSRAM).l
	move.l	(sp),d0
	btst	#5,(SeasonDay+1).w
	beq.w	.2
	addi.l	#$673D,d0
	bra.w	.3
.2
	addi.l	#$2720,d0
.3
	adda.w	#$34,a0
	jsr	(ReadSRAM).l
	move.l	(sp),d0
	btst	#5,(SeasonDay+1).w
	beq.w	.4
	addi.l	#$6CB9,d0
	bra.w	.5
.4
	addi.l	#$2C9C,d0
.5
	adda.w	#$34,a0
	jsr	(ReadSRAM).l
	move.l	(sp),d0
	btst	#5,(SeasonDay+1).w
	beq.w	.6
	addi.l	#$7235,d0
	bra.w	.7
.6
	addi.l	#$3218,d0
.7
	adda.w	#$34,a0
	jsr	(ReadSRAM).l
	move.l	(sp)+,d0
	btst	#5,(SeasonDay+1).w
	beq.w	.8
	addi.l	#$77B1,d0
	bra.w	.9
.8
	addi.l	#$3794,d0
.9
	adda.w	#$34,a0
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WriteTeamPlayerStats	;IDA: sub_932F8
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d7,d0
	mulu.w	#$34,d0
	move.l	d0,-(sp)
	btst	#5,(SeasonDay+1).w
	beq.w	.0
	addi.l	#$61C1,d0
	bra.w	.1
.0
	addi.l	#$21A4,d0
.1
	movea.l	#StatBuf,a0
	moveq	#$34,d1
	jsr	(WriteSRAM).l
	move.l	(sp),d0
	btst	#5,(SeasonDay+1).w
	beq.w	.2
	addi.l	#$673D,d0
	bra.w	.3
.2
	addi.l	#$2720,d0
.3
	adda.w	#$34,a0
	jsr	(WriteSRAM).l
	move.l	(sp),d0
	btst	#5,(SeasonDay+1).w
	beq.w	.4
	addi.l	#$6CB9,d0
	bra.w	.5
.4
	addi.l	#$2C9C,d0
.5
	adda.w	#$34,a0
	jsr	(WriteSRAM).l
	move.l	(sp),d0
	btst	#5,(SeasonDay+1).w
	beq.w	.6
	addi.l	#$7235,d0
	bra.w	.7
.6
	addi.l	#$3218,d0
.7
	adda.w	#$34,a0
	jsr	(WriteSRAM).l
	move.l	(sp)+,d0
	btst	#5,(SeasonDay+1).w
	beq.w	.8
	addi.l	#$77B1,d0
	bra.w	.9
.8
	addi.l	#$3794,d0
.9
	adda.w	#$34,a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadSeasonTeamRecord	;no IDA label. 95 only. Read the season record of team d7 (save RAM $3D10, or $7D2D with SeasonDay bit 5) to a0
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d7,d0
	mulu.w	#$A,d0
	btst	#5,(SeasonDay+1).w
	beq.w	.0
	addi.l	#$7D2D,d0
	bra.w	.1
.0
	addi.l	#$3D10,d0
.1
	moveq	#$A,d1
	movem.l	d7/a0,-(sp)
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d7/a0
	adda.w	#$A,a0
	move.w	d7,d0
	mulu.w	#3,d0
	btst	#5,(SeasonDay+1).w
	beq.w	.2
	addi.l	#$6173,d0
	bra.w	.3
.2
	addi.l	#$1AF6,d0
.3
	moveq	#3,d1
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

MarkSeasonRosters	;IDA: sub_93430
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d7
	movea.l	#$204348,a0
	movea.l	#$205938,a1
.0
	jsr	(ReadAttributeNibbleD7).l
	subq.w	#1,d0
	clr.w	d1
.1
	move.w	(a0,d1.w),d2
	ori.w	#$80,d2
	move.w	d2,(a0,d1.w)
	move.w	(a1,d1.w),d2
	ori.w	#$80,d2
	move.w	d2,(a1,d1.w)
	addq.w	#4,d1
	dbf	d0,.1
	addq.w	#1,d7
	adda.l	#$68,a0
	adda.l	#$68,a1
	cmp.w	#$1A,d7
	blt.s	.0
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeasonPlayerStats	;no IDA label. 95 season Player Stats screen: set VRAM layout (AC00-AC0E), clear VRAM (setvram), then run the stats screen and return
	bclr	#1,(disflags).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$DC00,(VSPRITES).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$FC00,(VSCRLPM).w
	moveq	#0,d0
	jsr	(setvram).l
	bra.w	SeasonAttributeScreen

SeasonPlayersScreen	;no IDA label. Run the season stats screen, then jump to ExitAttributeScreen2
	bsr.w	SeasonAttributeScreen
	jmp	(ExitAttributeScreen2).l

SeasonPlayersRedraw	;no IDA label. Wait for vblank, reset scroll, clear the window/scroll VDP areas, draw the team screen (DrawTeamScreen4NoSetup) and enter the stats screen draw
	btst	#0,(disflags).w
	bne.s	SeasonPlayersRedraw
	clr.w	(Hscroll).w
	clr.w	(Vscroll).w
	jsr	(SetScroll2).l
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movea.l	#VDP_DATA,a0
	move.w	#$9100,4(a0)
	move.w	#$9200,4(a0)
	move.w	(VSPRITES).w,d0
	jsr	(Vmaddr).l
	move.l	#0,(a0)
	move.w	#$8C81,4(a0)
	move.w	#6,(Map2col1).w
	move.w	#$8D00,4(a0)
	clr.w	d0
	jsr	(Vmaddr).l
	move.l	#0,(a0)
	move.w	(sp)+,(disflags).w
	bclr	#1,(disflags).w
	move.w	#$800,d0
	move.w	(VmMap1).w,d1
	move.w	#$7FF,d2
	jsr	(DoFill).l
	clr.w	d7
	moveq	#$D,d0
	moveq	#$18,d1
	move.l	#PlayerStatsBgMap,(screenarg).l
	jsr	(DrawTeamScreen4NoSetup).l
	bra.w	SeasonAttributeDraw

SeasonAttributeScreen	;no IDA label. stats94 DisplayAttributeScreen (season version). d7 = team 0-$19 (A/B cycles teams); sflags BF0C bit 3 = playoff variant
	move.b	(SeasonDay+1).w,-(sp)
	btst	#3,(sflags11).w
	bne.w	.0
	bclr	#5,(SeasonDay+1).w
.0
	clr.w	d7
	moveq	#$D,d0
	moveq	#$18,d1
	move.l	#PlayerStatsBgMap,(screenarg).l
	jsr	(DrawTeamScreen4).l

SeasonAttributeDraw	;no IDA label
	jsr	(printz).l
	String	$BD,$0,$6,$0
	movea.l	#PlayerStatsTitleMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#4,d5
	jsr	(dobitmap).l
	clr.w	(DispAttribCtr).w
	clr.w	(VertLineScrolling).w
.0
	jsr	(ReadTeamPlayerStats).l
	clr.w	(PlayerScrollCtr).w
	jsr	(printz).l
	String	$BD,$5,$1,$0
	jsr	(printz2).l
	String	$F8,$4,$3,$B,$1A,$F9,$3,'A,B^-^Switch^Teams',$F9,$0,$0
	btst	#3,(sflags11).w
	bne.w	.1
	jsr	(printbigz).l
	dc.w	$20;String length
	dc.b	$BD,$2,$4,'Season',$BD,$F,$4,'Player'
	dc.b	$BD,$1C,$4,'Stats',$BD,$E,$1,$0
	bra.w	.2
.1
	jsr	(printbigz).l
	String	$BD,$6,$4,'Playoff',$BD,$15,$4,'Players',$BD,$E,$1,$0
.2
	clr.w	d0
	move.w	d7,d0
	jsr	(DrawTeamLogo1).l
	bsr.w	SeasonAttributeMenu
	bsr.w	SeasonScrollArrows
.3
	jsr	(vcountwait).l
	jsr	(orjoy4way).l
	btst	#7,d3
	beq.w	.4
	move.b	(sp)+,(SeasonDay+1).w
	rts
.4
	btst	#6,d1
	bne.w	.8
	btst	#4,d1
	bne.w	.9
	jsr	(nodiag).l
	moveq	#1,d0
	btst	#3,d1
	bne.w	.7
	neg.w	d0
	btst	#2,d1
	bne.w	.7
	moveq	#-2,d0
	btst	#0,d3
	bne.w	.5
	neg.w	d0
	btst	#1,d3
	beq.w	.6
.5
	move.w	d0,(PlayerScrollCtr).w
.6
	bsr.w	SeasonAttribScroll
	bra.s	.3
.7
	add.w	(DispAttribCtr).w,d0
	cmp.w	#$FFFF,d0
	blt.s	.6
	cmp.w	#2,d0
	bgt.s	.6
	move.w	d0,(DispAttribCtr).w
	bsr.w	SeasonAttributeMenu
	bsr.w	SeasonScrollArrows
	bra.s	.6
.8
	subq.w	#1,d7
	bpl.w	.0
	move.w	#$19,d7
	bra.w	.0
.9
	addq.w	#1,d7
	cmp.w	#$1A,d7
	bne.w	.0
	clr.w	d7
	bra.w	.0

SeasonAttribScroll	;no IDA label. stats94 UpdateAttributeScroll. Per-frame scroll of the player list
	move.w	(PlayerScrollCtr).w,d0
	beq.w	rtsSeasonAttrib
	add.w	(VertLineScrolling).w,d0
	bmi.w	rtsSeasonAttrib
	cmp.w	(SelectedPlayerIdx).w,d0
	bgt.w	rtsSeasonAttrib
	move.w	(VertLineScrolling).w,d1
	move.w	d0,(VertLineScrolling).w
	andi.w	#$F,d0
	bne.w	.0
	bsr.w	SeasonScrollArrows
	clr.w	(PlayerScrollCtr).w
.0
	andi.w	#$F,d1
	bne.w	SeasonAttribScrollReg
	move.w	d0,-(sp)
	cmp.w	#$E,d0
	bne.w	.1
	bsr.w	SeasonAttribLineUp
.1
	move.w	(sp)+,d0
	cmp.w	#2,d0
	bne.w	SeasonAttribScrollReg
	bsr.w	SeasonAttribLineDown

SeasonAttribScrollReg	;no IDA label. stats94 SetAttribScrollReg. VSRAM = word_FFD278 - $68
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movea.l	#VDP_DATA,a0
	move.l	#$40020010,4(a0)
	move.w	#$FF98,d0
	add.w	(VertLineScrolling).w,d0
	move.w	d0,(a0)
	move.w	(sp)+,(disflags).w

rtsSeasonAttrib	;no IDA label
	rts

SeasonAttribLineUp	;no IDA label. stats94 DisplayAttributeLineUp
	move.w	(VertLineScrolling).w,d3
	lsr.w	#4,d3
	bra.w	SeasonAttributeEntry

SeasonAttribLineDown	;no IDA label. stats94 DisplayAttributeLineDown
	move.w	(VertLineScrolling).w,d3
	lsr.w	#4,d3
	addq.w	#6,d3
	bra.w	SeasonAttributeEntry

SeasonAttributeMenu	;no IDA label. stats94 DisplayAttributeMenu (3 columns: G, A, Pts). Headers, sort title, sorted player list at $FFBC1E, draws 6 rows
	jsr	(printz2).l
	String	$F8,$4,$3,$4,$9,$F9,$1,'Player',$FB,$7,$0
	lea	SeasonAttributeMenuTxt(pc),a1
	moveq	#3,d3
	tst.w	(DispAttribCtr).w
	bmi.w	.0
	adda.w	(a1),a1
	clr.w	d3
.0
	move.w	#$8000,(printa).w
	cmp.w	(DispAttribCtr).w,d3
	bne.w	.1
	move.w	#$C000,(printa).w
.1
	jsr	(printsmall).l
	addq.w	#1,d3
	cmp.w	#3,d3
	blt.s	.0
	jsr	(printz2).l
	String	$F8,$4,$3,$9,$7,$0
	jsr	(printz2).l
	String	$F9,$1
	jsr	(printz).l
	String	$BD,$A,$7,$0
	lea	SeasonAttributeTitleTxt(pc),a1
	moveq	#1,d0
	add.w	(DispAttribCtr).w,d0
	jsr	(PrintSmallListItem).l
	clr.w	(printfontset).w
	movea.w	#$BC1E,a3
	clr.l	d6
	tst.w	(DispAttribCtr).w
	bpl.w	.2
	jsr	(ReadAttributeNibbleD7).l
	bset	d0,d6
	subq.w	#1,d6
	not.l	d6
.2
	moveq	#-1,d4
	st	d5
	jsr	(GetPlayerCountD7).l
	bra.w	.5
.3
	btst	d0,d6
	bne.w	.5
	clr.w	d2
	bclr	#2,(sflags5).w
	move.w	(DispAttribCtr).w,d1
	bmi.w	.4
	bsr.w	SeasonCheckAttribute
.4
	btst	#2,(sflags5).w
	bne.w	.5
	ext.l	d2
	asl.l	#8,d2
	jsr	(GetRosterName).l
	adda.w	(a1),a1
	move.b	#$FF,d2
	sub.b	(a1),d2
	cmp.l	d4,d2
	ble.w	.5
	move.l	d2,d4
	move.w	d0,d5
.5
	dbf	d0,.3
	bset	d5,d6
	move.b	d5,(a3)+
	bpl.s	.2
	moveq	#5,d0
.6
	st	0(a3,d0.w)
	dbf	d0,.6
	move.w	a3,d0
	subi.w	#$BC24,d0
	bpl.w	.7
	clr.w	d0
.7
	asl.w	#4,d0
	move.w	d0,(SelectedPlayerIdx).w
	cmp.w	(VertLineScrolling).w,d0
	bcc.w	.8
	move.w	d0,(VertLineScrolling).w
.8
	moveq	#5,d4
.9
	move.w	(VertLineScrolling).w,d3
	lsr.w	#4,d3
	add.w	d4,d3
	bsr.w	SeasonAttributeEntry
	dbf	d4,.9
	bra.w	SeasonAttribScrollReg

SeasonAttributeEntry	;no IDA label. stats94 DisplayAttributeEntry. Draws list row d3 (rank, name, 3 stat columns or goalie saves/shots/save %)
	movea.w	#$BC1E,a4
	adda.w	d3,a4
	jsr	(printz).l
	String	$BE,$0,$0,$0
	add.w	d3,d3
	andi.w	#$1F,d3
	move.w	d3,(printy).w
	moveq	#$28,d0
	moveq	#1,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	tst.b	(a4)
	bmi.w	rtsSeasonAttrib
	subq.w	#1,(printy).w
	move.w	#1,(printx).w
	move.w	a4,d0
	subi.w	#$BC1D,d0
	moveq	#2,d1
	move.w	#$E000,(printa).w
	jsr	(PushNumberWidth).l
	jsr	(print).l
	clr.w	d0
	move.b	(a4),d0
	jsr	(FormatPlayerNameD7).l
	addq.w	#1,(printx).w
	move.w	#$8000,(printa).w
	jsr	(print).l
	move.w	#$11,(printx).w
	tst.w	(DispAttribCtr).w
	bmi.w	.2
	clr.w	d5
.0
	clr.w	d0
	move.b	(a4),d0
	move.w	d5,d1
	bsr.w	SeasonCheckAttribute
	move.w	d2,d0
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	move.w	#$8000,(printa).w
	cmp.w	(DispAttribCtr).w,d5
	bne.w	.1
	move.w	#$C000,(printa).w
.1
	jsr	(print).l
	addq.w	#2,(printx).w
	addq.w	#1,d5
	cmp.w	#3,d5
	bne.s	.0
	bra.w	.5
.2
	clr.w	d0
	move.b	(a4),d0
	moveq	#3,d1
	bsr.w	SeasonGetAttribute
	clr.w	d0
	move.b	(a4),d0
	moveq	#0,d1
	move.w	d2,-(sp)
	bsr.w	SeasonGetAttribute
	move.w	(sp)+,d0
	move.w	d0,d3
	sub.w	d2,d0
	bpl.w	.3
	clr.w	d0
.3
	move.w	d0,d2
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	addq.w	#1,(printx).w
	jsr	(print).l
	move.w	d3,d0
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	addq.w	#2,(printx).w
	jsr	(print).l
	tst.w	d3
	beq.w	.4
	mulu.w	#$64,d2
	divu.w	d3,d2
.4
	move.w	d2,d0
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	addq.w	#2,(printx).w
	jsr	(print).l
	jsr	(printz).l
	String	'%',$0
.5
	rts

SeasonCheckAttribute	;no IDA label. stats94 CheckAttributeValid. d2 = stat column d1 for player d0; goalies: columns 1-2 read column 1 (A), others set BEFC bit 2 (skip)
	bclr	#2,(sflags5).w
	move.w	d0,-(sp)
	jsr	(ReadAttributeNibbleD7).l
	move.w	d0,d2
	move.w	(sp)+,d0
	cmp.w	d2,d0
	bge.w	SeasonGetAttribute
	clr.w	d2
	btst	d1,#6
	beq.w	SeasonSkipAttribute
	moveq	#1,d1

SeasonGetAttribute	;no IDA label. stats94 GetAttributeValue2 (season version). d2 = sum of the season stat words (low 15 bits) at $FFCAF8 + SeasonAttributeOffsets column offsets, player d0
	movem.w	d0,-(sp)
	movea.l	#StatBuf,a2
	lea	SeasonAttributeOffsets(pc),a1
	asl.w	#2,d1
	adda.w	d1,a1
	move.w	(a1),d1
	add.w	d0,d0
	add.w	d0,d1
	move.w	0(a2,d1.w),d2
	andi.w	#$7FFF,d2
	move.w	2(a1),d1
	bmi.w	.0
	add.w	d0,d1
	move.w	0(a2,d1.w),d3
	andi.w	#$7FFF,d2;(sic: masks d2 again, not d3)
	add.w	d3,d2
.0
	movem.w	(sp)+,d0
	rts

SeasonSkipAttribute	;no IDA label. Column not shown for this goalie: set BEFC bit 2
	bset	#2,(sflags5).w
	rts

SeasonAttributeOffsets	;no IDA label. stats94 AttributeOffsetTbl2 (season version). Word offsets into $FFCAF8 per column (G, A, Pts=G+A, saves, shots), $FFFF = none
	dc.w	$0,$FFFF,$34,$FFFF,$0,$34,$68,$FFFF,$D0,$FFFF

SeasonAttributeMenuTxt	;no IDA label. stats94 AttributeMenuTxt. Column headers (goalie header, then G, A, Pts, SOG, PIM)
	String	'Saves Shots Save %  '
	String	'   G'
	String	'     A'
	String	'   Pts    '
	String	' SOG'
	String	' PIM'

SeasonAttributeTitleTxt	;no IDA label. stats94 AttributeTitleTxt. Sort column titles
	String	'    Goalie Saves   ]'
	String	'[      Goals       ]'
	String	'[     Assists      ]'
	String	'[      Points       '
	String	'[  Shots On Goal   ]'
	String	'[ Penalty Minutes   '

SeasonScrollArrows	;no IDA label. stats94 DrawScrollArrowsAttribute. Up / down arrows (SeasonScrollArrowTbl). Saves d0-d1/a1
	movem.l	d0-d1/a1,-(sp)
	jsr	(printz2).l
	String	$F8,$4,$3,'$',$C,$F9,$3,$0
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
	lea	SeasonScrollArrowTbl(pc),a1
	jsr	(PrintSmallListItem).l
	movem.l	(sp)+,d0-d1/a1
	rts

SeasonScrollArrowTbl	;no IDA label. stats94 ScrollArrowTbl2. None, up, down, both
	String	' ',$FB,$FF,$FA,$E,' ',$F9,$0
	String	'{',$FB,$FF,$FA,$E,' ',$F9,$0
	String	' ',$FB,$FF,$FA,$E,'}',$F9,$0
	String	'{',$FB,$FF,$FA,$E,'}',$F9,$0

DrawTeamLogo1	;no IDA label. Draw bitmap Teamblocksmap via dobitmap (dobitmap) with tile base $69A, d1 = 2*d0 (team d0). Saves all regs
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#1,d4
	move.w	d0,d1
	clr.w	d0
	asl.w	#1,d1
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

SeasonTeamStats	;no IDA label. 95 season TEAM STATS screen (sflags11 bit 3 = playoff "Playoff Teams"): d7 = team 0-$19, left/right (bits 6/4 of d1) change team, start exits
	bclr	#1,(disflags).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$DC00,(VSPRITES).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$FC00,(VSCRLPM).w
	moveq	#0,d0
	jsr	(setvram).l
	bra.w	SeasonTeamStatsRun

SeasonTeamsScreen	;no IDA label
	bsr.w	SeasonTeamStatsRun
	jmp	(ExitAttributeScreen2).l

SeasonTeamStatsRun	;no IDA label
	move.b	(SeasonDay+1).w,-(sp)
	btst	#3,(sflags11).w
	bne.w	.0
	bclr	#5,(SeasonDay+1).w
.0
	clr.w	d7
	move.w	#0,d0
	move.w	#$1B,d1
	move.l	#ControllerBgMap,(screenarg).l
	jsr	(DrawTeamScreen5).l
	btst	#3,(sflags11).w
	bne.w	.1
	jsr	(printbigz).l
	String	$BE,$4,$2,'Season',$BE,$11,$2,'Team',$BE,$1A,$2,'Stats'
	bra.w	.2
.1
	jsr	(printbigz).l
	String	$BE,$8,$2,'Playoff',$BE,$17,$2,'Teams'
.2
	movea.l	#StatBuf,a0
	jsr	(ReadSeasonTeamRecord).l
	jsr	(printz2).l
	String	$F8,$4,$2,$B,$1A,$F9,$1,'A,B^-^Switch^Teams',$F9,$0,$0
	jsr	(printz).l
	String	$BD,$E,$6,$0
	move.w	d7,d0
	jsr	(DrawTeamLogo2).l
	bsr.w	PrintSeasonTeamStats
.3
	jsr	(vcountwait).l
	jsr	(orjoy4way).l
	btst	#7,d3
	beq.w	.4
	move.b	(sp)+,(SeasonDay+1).w
	rts
.4
	btst	#6,d1
	bne.w	.6
	btst	#4,d1
	bne.w	.5
	bra.s	.3
.5
	addq.w	#1,d7
	cmp.w	#$1A,d7
	bne.s	.2
	clr.w	d7
	bra.s	.2
.6
	subq.w	#1,d7
	bpl.w	.2
	move.w	#$19,d7
	bra.w	.2

PrintSeasonTeamStats	;no IDA label. print the team stat rows from the record at $FFCAF8 (a6): W,L,T,Pts, then per-game / percentage stats (like 94 DisplayTeamStatsScreen rows)
	movem.l	a6,-(sp)
	movea.l	#StatBuf,a6
	jsr	(printz2).l
	String	$F9,$0
	jsr	(printz2).l
	String	$F8,$4,$2,$3,$9,'Wins,Losses,Ties,Pts  ',$0
	clr.w	(rosterscroll).w
	clr.w	d0
	move.b	$A(a6),d0
	add.w	d0,(rosterscroll).w
	move.w	d0,-(sp)
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	',',$0
	clr.w	d0
	move.b	$C(a6),d0
	add.w	d0,(rosterscroll).w
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	',',$0
	clr.w	d0
	move.b	$B(a6),d0
	add.w	d0,(rosterscroll).w
	move.w	d0,-(sp)
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	',',$0
	move.w	(sp)+,d0
	add.w	(sp),d0
	add.w	(sp)+,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	$F8,$4,$2,$3,$B,'Goals Scored Per Game',$FD,$1E
	move.w	(rosterscroll).w,d1
	clr.l	d0
	tst.w	d1
	beq.w	.0
	move.w	(a6),d0
	mulu.w	#$64,d0
	divu.w	d1,d0
	andi.l	#$FFFF,d0
	divu.w	#$64,d0
.0
	swap	d0
	move.w	d0,-(sp)
	swap	d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	'.',$0
	move.w	(sp)+,d0
	move.w	#2,d1
	jsr	(PushNumberWidthZero).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	$F8,$4,$2,$3,$D,'Goals Allowed Per Game',$FD,$1E,$0
	move.w	(rosterscroll).w,d1
	clr.w	d0
	tst.w	d1
	beq.w	.1
	move.w	2(a6),d0
	mulu.w	#$64,d0
	divu.w	d1,d0
	andi.l	#$FFFF,d0
	divu.w	#$64,d0
.1
	swap	d0
	move.w	d0,-(sp)
	swap	d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	'.',$0
	move.w	(sp)+,d0
	move.w	#2,d1
	jsr	(PushNumberWidthZero).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	$F8,$4,$2,$3,$F,'Penalty Minutes Per Game',$FD,$1E,$0
	move.w	(rosterscroll).w,d1
	clr.l	d0
	tst.w	d1
	beq.w	.2
	move.w	4(a6),d0
	mulu.w	#$64,d0
	divu.w	d1,d0
	andi.l	#$FFFF,d0
	divu.w	#$64,d0
.2
	swap	d0
	move.w	d0,-(sp)
	swap	d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	'.',$0
	move.w	(sp)+,d0
	move.w	#2,d1
	jsr	(PushNumberWidthZero).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	$F8,$4,$2,$3,$11,'Save Percentage',$FD,$1F
	move.w	8(a6),d3
	move.w	d3,d2
	sub.w	2(a6),d2
	bpl.w	.3
	clr.w	d2
.3
	tst.w	d3
	beq.w	.4
	mulu.w	#$64,d2
	divu.w	d3,d2
.4
	move.w	d2,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	'%',$0
	jsr	(printz2).l
	String	$F8,$4,$2,$3,$13,'Shooting Percentage',$FD,$1F
	move.w	6(a6),d3
	move.w	(a6),d2
	tst.w	d3
	beq.w	.5
	mulu.w	#$64,d2
	divu.w	d3,d2
.5
	move.w	d2,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	'%',$0
	jsr	(printz2).l
	String	$F8,$4,$2,$3,$15,'Shots Per Game',$FD,$1E,$0
	move.w	(rosterscroll).w,d1
	clr.l	d0
	tst.w	d1
	beq.w	.6
	move.w	6(a6),d0
	mulu.w	#$64,d0
	divu.w	d1,d0
	andi.l	#$FFFF,d0
	divu.w	#$64,d0
.6
	swap	d0
	move.w	d0,-(sp)
	swap	d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	'.',$0
	move.w	(sp)+,d0
	move.w	#2,d1
	jsr	(PushNumberWidthZero).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	$F8,$4,$2,$3,$17,'Shots Allowed Per Game',$FD,$1E,$0
	move.w	(rosterscroll).w,d1
	clr.l	d0
	tst.w	d1
	beq.w	.7
	move.w	8(a6),d0
	mulu.w	#$64,d0
	divu.w	d1,d0
	andi.l	#$FFFF,d0
	divu.w	#$64,d0
.7
	swap	d0
	move.w	d0,-(sp)
	swap	d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	'.',$0
	move.w	(sp)+,d0
	move.w	#2,d1
	jsr	(PushNumberWidthZero).l
	jsr	(printsmall).l
	movem.l	(sp)+,a6
	rts

DrawTeamLogo2	;no IDA label. draw team d0's logo: frame d0*2 of the bitmap set at Teamblocksmap, tile $69A, via dobitmap (dobitmap)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#1,d4
	move.w	d0,d1
	clr.w	d0
	asl.w	#1,d1
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

LeagueLeadersScreen	;no IDA label. 95 League Leaders screen (season menu): team/individual stat leader lists, scroll and category select
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(MarkSeasonRosters).l
	move.l	#PlayerStatsBgMap,(screenarg).l
	bsr.w	StandingsGfx
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	jsr	(printbigz).l
	String	$BF,$6,$2,'League Leaders',$0
	clr.w	(StatWork).w
	clr.w	(SeasonGameCount).w
	move.w	#8,(StatWork+$8).w
	move.w	#7,(StatWork+$6).w
	clr.w	(linemarkbuf+2).w
	movea.l	#.8,a0
	move.w	(StatWork).w,d5
	add.w	d5,d5
	move.w	0(a0,d5.w),(StatWork+$A).w
.0
	bsr.w	BuildLeaders
.1
	bsr.w	PrintLeadersHeader
	bsr.w	PrintTeamCategory
	move.w	#$18,(palcount).w
	bsr.w	DrawLeaderRows
	bsr.w	LeadersScrollArrows
	bsr.w	LeadersHelp
.2
	bsr.w	ReadAnyPad6
	tst.w	d1
	beq.w	.10
	btst	#7,d1
	bne.w	.11
	btst	#4,d1
	beq.w	.3
	jsr	(forceblack).l
	eori.w	#1,(StatWork).w
	clr.w	(linemarkbuf+2).w
	clr.w	(SeasonGameCount).w
	move.w	#7,(StatWork+$6).w
	movea.l	#.8,a0
	move.w	(StatWork).w,d5
	add.w	d5,d5
	move.w	0(a0,d5.w),(StatWork+$A).w
	bra.s	.0
.3
	btst	#2,d1
	beq.w	.6
	bsr.w	ClearLeadersArea
	subq.w	#1,(linemarkbuf+2).w
	bpl.w	.4
	movea.l	#.5,a0
	move.w	(StatWork).w,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	move.w	d0,(linemarkbuf+2).w
.4
	movea.l	#.8,a0
	move.w	(StatWork).w,d5
	add.w	d5,d5
	move.w	0(a0,d5.w),(StatWork+$A).w
	clr.w	(SeasonGameCount).w
	move.w	#7,(StatWork+$6).w
	bra.w	.0
.5
	dc.w	6,3
.6
	btst	#0,d1
	beq.w	.7
	tst.w	(SeasonGameCount).w
	beq.w	.2
	subq.w	#1,(SeasonGameCount).w
	subq.w	#1,(StatWork+$6).w
	bra.w	.1
.7
	btst	#1,d1
	beq.w	.9
	move.w	(StatWork+$6).w,d0
	cmp.w	(StatWork+$A).w,d0
	bge.w	.2
	addq.w	#1,(SeasonGameCount).w
	addq.w	#1,(StatWork+$6).w
	bra.w	.1
.8
	dc.w	$19,$13
.9
	btst	#3,d1
	beq.w	.2
	bsr.w	ClearLeadersArea
	addq.w	#1,(linemarkbuf+2).w
	movea.l	#.5,a0
	move.w	(StatWork).w,d0
	add.w	d0,d0
	move.w	0(a0,d0.w),d0
	cmp.w	(linemarkbuf+2).w,d0
	bge.w	.4
	clr.w	(linemarkbuf+2).w
	bra.w	.4
.10
	jmp	(Opening2).l
.11
	movem.l	(sp)+,d0-d7/a0-a6
	rts

LeadersScrollArrows	;no IDA label. League Leaders: draw up/down scroll arrows depending on list position
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(SeasonGameCount).w
	beq.w	.0
	jsr	(printz).l
	String	$BF,$1,$9,'{'
	bra.w	.1
.0
	jsr	(printz).l
	String	$BF,$1,$9,' '
.1
	move.w	(StatWork+$6).w,d1
	cmp.w	(StatWork+$A).w,d1
	bge.w	.2
	jsr	(printz).l
	String	$BF,$1,$18,'}'
	bra.w	.3
.2
	jsr	(printz).l
	String	$BF,$1,$18,' '
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintTeamCategory	;no IDA label. League Leaders: print category name, team mode (7 categories); individual mode goes to PrintPlayerCategory
	tst.w	(StatWork).w
	bne.w	PrintPlayerCategory
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$10,$7,$0
	move.w	(linemarkbuf+2).w,d0
	movea.l	#TeamCategoryText,a1
	jsr	(PrintListItem).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

TeamCategoryText	;no IDA label
	String	'       Points        ',$0
	String	'      Goals Avg.     ',$0
	String	'  Goals Allowed Avg. ',$0
	String	'   Save Percentage   ',$0
	String	' Shooting Percentage ',$0
	String	'      Shots Avg.     ',$0
	String	'  Shots Allowed Avg. ',$0

PrintPlayerCategory	;no IDA label. League Leaders: print category name, individual mode (4 categories)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$19,$7,$0
	move.w	(linemarkbuf+2).w,d0
	movea.l	#PlayerCategoryText,a1
	jsr	(PrintListItem).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayerCategoryText	;no IDA label
	String	'   Goals       ',$0
	String	'  Assists      ',$0
	String	'  Points       ',$0
	String	'      GAA      ',$0

PrintLeadersHeader	;no IDA label. League Leaders: print TEAM / INDIVIDUAL column headers
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$0,$5,$0
	movea.l	#BlankLine40,a1
	jsr	(print).l
	move.w	(StatWork).w,d0
	movea.l	#LeaderModeText,a1
	jsr	(PrintListItem).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

LeaderModeText	;no IDA label
	String	$BF,$11,$5,'TEAM',$BF,$5,$7,'   Team    ',$0
	String	$BF,$F,$5,'INDIVIDUAL',$BF,$6,$7,'No. Player   Team  ',$0

ReadAnyPad6	;no IDA label. League Leaders: wait (frame-synced) until a joypad reports input; d1 = buttons
	move.l	#$5460,d6
.0
	move.w	#$64,d6
.1
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.0
	move.w	(vcount).w,(oldvcount).w
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.6
.2
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.3
	bra.w	.6
.3
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.4
	bra.w	.6
.4
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.5
	bra.w	.6
.5
	dbf	d6,.0
.6
	rts

ClearLeadersArea	;no IDA label. League Leaders: clear a $28x$14 text area with tile $7FF (individual mode only; team mode returns at once)
	tst.w	(StatWork).w
	beq.w	.0
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$28,d0
	move.w	#$14,d1
	move.w	#$7FF,d2
	jsr	(printz).l
	String	$FF,$0,$7,$0
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
.0
	rts

BuildLeaders	;no IDA label. League Leaders: build sorted team leader list for category BB20 (jump table) or individual list
	tst.w	(StatWork).w
	bne.w	BuildPlayerLeaders
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(linemarkbuf+2).w,d0
	asl.w	#2,d0
	movea.l	#TeamLeaderJumps,a0
	movea.l	0(a0,d0.w),a0
	jmp	(a0)

TeamLeaderJumps	;no IDA label
	dc.l	LeadersPoints,LeadersGoalsAvg,LeadersGoalsAllowed,LeadersSavePct,LeadersShootPct,LeadersShotsAvg,LeadersShotsAllowed

LeadersPoints	;no IDA label. Points: 2*wins+ties per team, sort descending
	movea.l	#StatBuf,a0
	jsr	(ReadStandings).l
	move.w	#$19,d3
	clr.w	d4
	movea.l	#picturebuf,a0
	movea.l	#TeamLeaderValues,a1
	movea.l	#StatBuf,a2
.0
	move.b	d4,(a0)+
	clr.w	d0
	move.b	(a2),d0
	add.b	d0,d0
	add.b	1(a2),d0
	move.w	d0,(a1)+
	addq.w	#3,a2
	addq.w	#1,d4
	dbf	d3,.0
	movea.l	#picturebuf,a0
	bsr.w	SortLeadersDown
	bra.w	BuildLeadersDone

LeadersGoalsAvg	;no IDA label. Goals Avg: goals*100/games per team, sort descending
	move.l	#$3D10,d0
	move.l	#$104,d1
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	movea.l	#StandingsRecs,a0
	jsr	(ReadStandings).l
	move.w	#$19,d3
	clr.w	d4
	movea.l	#LeaderTeamTbls+$1A,a0
	movea.l	#TeamLeaderValues,a1
	movea.l	#StatBuf,a2
	movea.l	#StandingsRecs,a3
.0
	move.b	d4,(a0)+
	move.w	0(a2),d0
	beq.w	.1
	mulu.w	#$64,d0
	clr.w	d1
	move.b	(a3),d1
	add.b	2(a3),d1
	add.b	1(a3),d1
	divu.w	d1,d0
.1
	move.w	d0,(a1)+
	addq.w	#3,a3
	adda.w	#$A,a2
	addq.w	#1,d4
	dbf	d3,.0
	movea.l	#LeaderTeamTbls+$1A,a0
	bsr.w	SortLeadersDown
	bra.w	BuildLeadersDone

LeadersGoalsAllowed	;no IDA label. Goals Allowed Avg: goals against*100/games per team, sort ascending
	move.l	#$3D10,d0
	move.l	#$104,d1
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	movea.l	#StandingsRecs,a0
	jsr	(ReadStandings).l
	move.w	#$19,d3
	clr.w	d4
	movea.l	#LeaderTeamTbls+$34,a0
	movea.l	#TeamLeaderValues,a1
	movea.l	#StatBuf,a2
	movea.l	#StandingsRecs,a3
.0
	move.b	d4,(a0)+
	move.w	2(a2),d0
	beq.w	.1
	mulu.w	#$64,d0
	clr.w	d1
	move.b	(a3),d1
	add.b	2(a3),d1
	add.b	1(a3),d1
	divu.w	d1,d0
.1
	move.w	d0,(a1)+
	addq.w	#3,a3
	adda.w	#$A,a2
	addq.w	#1,d4
	dbf	d3,.0
	movea.l	#LeaderTeamTbls+$34,a0
	bsr.w	SortLeadersUp
	bra.w	BuildLeadersDone

LeadersField4	;no IDA label. unreferenced: field 4 *100/games per team, sort descending
	move.l	#$3D10,d0
	move.l	#$104,d1
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	movea.l	#StandingsRecs,a0
	jsr	(ReadStandings).l
	move.w	#$19,d3
	clr.w	d4
	movea.l	#LeaderTeamTbls+$4E,a0
	movea.l	#TeamLeaderValues,a1
	movea.l	#StatBuf,a2
	movea.l	#StandingsRecs,a3
.0
	move.b	d4,(a0)+
	move.w	4(a2),d0
	beq.w	.1
	mulu.w	#$64,d0
	clr.w	d1
	move.b	(a3),d1
	add.b	2(a3),d1
	add.b	1(a3),d1
	divu.w	d1,d0
.1
	move.w	d0,(a1)+
	addq.w	#3,a3
	adda.w	#$A,a2
	addq.w	#1,d4
	dbf	d3,.0
	movea.l	#LeaderTeamTbls+$4E,a0
	bsr.w	SortLeadersDown
	bra.w	BuildLeadersDone

LeadersSavePct	;no IDA label. Save Percentage: (shots against - goals against)*100/shots against per team, sort descending
	move.l	#$3D10,d0
	move.l	#$104,d1
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	move.w	#$19,d3
	clr.w	d4
	movea.l	#LeaderTeamTbls+$68,a0
	movea.l	#TeamLeaderValues,a1
	movea.l	#StatBuf,a2
.0
	move.b	d4,(a0)+
	move.w	8(a2),d0
	move.w	d0,d1
	beq.w	.2
	sub.w	2(a2),d1
	bpl.w	.1
	clr.w	d1
.1
	mulu.w	#$64,d1
	divu.w	d0,d1
.2
	move.w	d1,(a1)+
	adda.w	#$A,a2
	addq.w	#1,d4
	dbf	d3,.0
	movea.l	#LeaderTeamTbls+$68,a0
	bsr.w	SortLeadersDown
	bra.w	BuildLeadersDone

LeadersShootPct	;no IDA label. Shooting Percentage: goals*100/shots per team, sort descending
	move.l	#$3D10,d0
	move.l	#$104,d1
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	move.w	#$19,d3
	clr.w	d4
	movea.l	#LeaderTeamTbls+$82,a0
	movea.l	#TeamLeaderValues,a1
	movea.l	#StatBuf,a2
.0
	move.b	d4,(a0)+
	clr.w	d1
	move.w	6(a2),d0
	beq.w	.2
	move.w	(a2),d1
	cmp.w	d0,d1
	ble.w	.1
	move.w	d1,d0
.1
	mulu.w	#$64,d1
	divu.w	d0,d1
.2
	move.w	d1,(a1)+
	adda.w	#$A,a2
	addq.w	#1,d4
	dbf	d3,.0
	movea.l	#LeaderTeamTbls+$82,a0
	bsr.w	SortLeadersDown
	bra.w	BuildLeadersDone

LeadersShotsAvg	;no IDA label. Shots Avg: shots*100/games per team, sort descending
	move.l	#$3D10,d0
	move.l	#$104,d1
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	movea.l	#StandingsRecs,a0
	jsr	(ReadStandings).l
	move.w	#$19,d3
	clr.w	d4
	movea.l	#LeaderTeamTbls+$9C,a0
	movea.l	#TeamLeaderValues,a1
	movea.l	#StatBuf,a2
	movea.l	#StandingsRecs,a3
.0
	move.b	d4,(a0)+
	move.w	6(a2),d0
	beq.w	.1
	mulu.w	#$64,d0
	clr.w	d1
	move.b	(a3),d1
	add.b	2(a3),d1
	add.b	1(a3),d1
	divu.w	d1,d0
.1
	move.w	d0,(a1)+
	addq.w	#3,a3
	adda.w	#$A,a2
	addq.w	#1,d4
	dbf	d3,.0
	movea.l	#LeaderTeamTbls+$9C,a0
	bsr.w	SortLeadersDown
	bra.w	BuildLeadersDone

LeadersShotsAllowed	;no IDA label. Shots Allowed Avg: shots against*100/games per team, sort ascending
	move.l	#$3D10,d0
	move.l	#$104,d1
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	movea.l	#StandingsRecs,a0
	jsr	(ReadStandings).l
	move.w	#$19,d3
	clr.w	d4
	movea.l	#LeaderTeamTbls+$B6,a0
	movea.l	#TeamLeaderValues,a1
	movea.l	#StatBuf,a2
	movea.l	#StandingsRecs,a3
.0
	move.b	d4,(a0)+
	move.w	8(a2),d0
	beq.w	.1
	mulu.w	#$64,d0
	clr.w	d1
	move.b	(a3),d1
	add.b	2(a3),d1
	add.b	1(a3),d1
	divu.w	d1,d0
.1
	move.w	d0,(a1)+
	addq.w	#3,a3
	adda.w	#$A,a2
	addq.w	#1,d4
	dbf	d3,.0
	movea.l	#LeaderTeamTbls+$B6,a0
	bsr.w	SortLeadersUp
	bra.w	BuildLeadersDone

BuildLeadersDone	;no IDA label
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SortLeadersDown	;no IDA label. League Leaders: bubble sort word values at $FFDB04 (25 pairs) descending, swapping index bytes at a0
	movea.l	#TeamLeaderValues,a1
.0
	clr.w	d1
	clr.w	d0
	clr.w	(TempWord1).w
	move.w	#$18,d2
.1
	move.w	0(a1,d1.w),d5
	move.w	2(a1,d1.w),d6
	cmp.w	d5,d6
	ble.w	.2
	st	(TempWord1).w
	move.w	0(a1,d1.w),-(sp)
	move.w	2(a1,d1.w),-(sp)
	move.w	(sp)+,0(a1,d1.w)
	move.w	(sp)+,2(a1,d1.w)
	move.b	0(a0,d0.w),-(sp)
	move.b	1(a0,d0.w),-(sp)
	move.b	(sp)+,0(a0,d0.w)
	move.b	(sp)+,1(a0,d0.w)
.2
	addq.w	#1,d0
	addq.w	#2,d1
	dbf	d2,.1
	tst.w	(TempWord1).w
	bne.s	.0
	rts

SortLeadersUp	;no IDA label. League Leaders: same bubble sort, ascending
	movea.l	#TeamLeaderValues,a1
.0
	clr.w	d1
	clr.w	d0
	clr.w	(TempWord1).w
	move.w	#$18,d2
.1
	move.w	0(a1,d1.w),d5
	move.w	2(a1,d1.w),d6
	cmp.w	d5,d6
	bge.w	.2
	st	(TempWord1).w
	move.w	0(a1,d1.w),-(sp)
	move.w	2(a1,d1.w),-(sp)
	move.w	(sp)+,0(a1,d1.w)
	move.w	(sp)+,2(a1,d1.w)
	move.b	0(a0,d0.w),-(sp)
	move.b	1(a0,d0.w),-(sp)
	move.b	(sp)+,0(a0,d0.w)
	move.b	(sp)+,1(a0,d0.w)
.2
	addq.w	#1,d0
	addq.w	#2,d1
	dbf	d2,.1
	tst.w	(TempWord1).w
	bne.s	.0
	rts

BuildPlayerLeaders	;no IDA label. League Leaders: individual mode, dispatch on category BB20 through table at $949D0
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(linemarkbuf+2).w,d0
	asl.w	#2,d0
	movea.l	#PlayerLeaderJumps,a0
	movea.l	0(a0,d0.w),a0
	jmp	(a0)

BuildPlayerLeadersDone	;no IDA label
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayerLeaderJumps	;no IDA label. League Leaders: per category (word_FFBB20, from $949B4) handler that builds and sorts the leader list
	dc.l	PlayerLeadersGoals
	dc.l	PlayerLeadersAssists
	dc.l	PlayerLeadersPoints
	dc.l	PlayerLeadersGAA

PlayerLeadersGoals	;no IDA label. Category 0: gather with BuildLeaderList (d0 = $21A4, d1 = $548), sort descending
	move.l	#$21A4,d0
	move.l	#$548,d1
	movea.l	#BuildLeaderList,a5
	bclr	#1,(BA_PS_flags).w
	bsr.w	GatherAndSort
	bra.s	BuildPlayerLeadersDone

PlayerLeadersAssists	;no IDA label. Category 1: gather with BuildLeaderList (d0 = $2720, d1 = $548), sort descending
	move.l	#$2720,d0
	move.l	#$548,d1
	movea.l	#BuildLeaderList,a5
	bclr	#1,(BA_PS_flags).w
	bsr.w	GatherAndSort
	bra.s	BuildPlayerLeadersDone

PlayerLeadersPoints	;no IDA label. Category 2: gather with BuildLeaderListSum (d0 = $21A4, d1 = $548), sort descending
	move.l	#$21A4,d0
	move.l	#$548,d1
	movea.l	#BuildLeaderListSum,a5
	bclr	#1,(BA_PS_flags).w
	bsr.w	GatherAndSort
	bra.s	BuildPlayerLeadersDone

PlayerLeadersGAA	;no IDA label. Category 3: gather with BuildLeaderListPct (d0 = $21A4, d1 = $548), sort ascending (bit 1 of byte_FFBEF8 set)
	move.l	#$21A4,d0
	move.l	#$548,d1
	movea.l	#BuildLeaderListPct,a5
	bset	#1,(BA_PS_flags).w
	bsr.w	GatherAndSort
	bra.w	BuildPlayerLeadersDone

GatherAndSort	;no IDA label. Call a5 to fill values at $FFFFA1AA / players at $FFFF9C60 (count word_FFBB2A), then bubble sort both lists by value (descending, or ascending when bit 1 of byte_FFBEF8)
	movea.l	#LeaderValues,a0
	movea.l	#StatWork+$C,a2
	movea.l	#LeaderPlayers,a3
	jsr	(a5)
	move.w	(StatWork+$C).w,d3
	beq.w	rtsSortValues
	subq.w	#1,d3
	clr.w	d4
	movea.l	#LeaderValues,a1
	movea.l	#LeaderPlayers,a0
	btst	#1,(BA_PS_flags).w
	bne.w	SortValuesUp

SortValuesDown	;no IDA label. Descending pass: swap neighbours where the next value is larger, repeat until no swap
	clr.w	d0
	clr.w	(TempWord1).w
	move.w	(StatWork+$C).w,d2
	beq.w	rtsSortValues
	subq.w	#2,d2
	beq.w	rtsSortValues
	bmi.w	rtsSortValues
.0
	move.w	0(a1,d0.w),d5
	move.w	2(a1,d0.w),d6
	cmp.w	d5,d6
	ble.w	.1
	st	(TempWord1).w
	move.w	0(a1,d0.w),-(sp)
	move.w	2(a1,d0.w),-(sp)
	move.w	(sp)+,0(a1,d0.w)
	move.w	(sp)+,2(a1,d0.w)
	move.w	0(a0,d0.w),-(sp)
	move.w	2(a0,d0.w),-(sp)
	move.w	(sp)+,0(a0,d0.w)
	move.w	(sp)+,2(a0,d0.w)
.1
	addq.w	#2,d0
	dbf	d2,.0
	tst.w	(TempWord1).w
	bne.s	SortValuesDown

rtsSortValues	;no IDA label
	rts

SortValuesUp	;no IDA label. Ascending pass: swap neighbours where the next value is smaller, repeat until no swap
	clr.w	d0
	clr.w	(TempWord1).w
	move.w	(StatWork+$C).w,d2
	beq.s	rtsSortValues
	subq.w	#2,d2
	beq.s	rtsSortValues
	bmi.s	rtsSortValues
.0
	move.w	0(a1,d0.w),d5
	move.w	2(a1,d0.w),d6
	cmp.w	d5,d6
	bge.w	.1
	st	(TempWord1).w
	move.w	0(a1,d0.w),-(sp)
	move.w	2(a1,d0.w),-(sp)
	move.w	(sp)+,0(a1,d0.w)
	move.w	(sp)+,2(a1,d0.w)
	move.w	0(a0,d0.w),-(sp)
	move.w	2(a0,d0.w),-(sp)
	move.w	(sp)+,0(a0,d0.w)
	move.w	(sp)+,2(a0,d0.w)
.1
	addq.w	#2,d0
	dbf	d2,.0
	tst.w	(TempWord1).w
	bne.s	SortValuesUp
	rts

DrawLeaderRows	;no IDA label. Draw the leader rows (word_FFBB26 rows from word_FFBB22): when word_FFBB1E is set use the sorted list (DrawPlayerLeaderRows), else rank, team logo (DrawTeamLogo3), and the category value (LeaderPrintJumps) from the RAM tables in LeaderTables
	tst.w	(StatWork).w
	bne.w	DrawPlayerLeaderRows
	clr.w	d6
	movea.l	#LeaderTables,a5
	move.w	(linemarkbuf+2).w,d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a5
	movea.l	a5,a0
	move.w	#9,(printy).w
.0
	move.w	#5,(printx).w
	movea.l	#BlankLine40,a1
	jsr	(print).l
	move.w	#5,(printx).w
	addq.w	#1,(printy).w
	movea.l	#BlankLine40,a1
	jsr	(print).l
	move.w	#2,(printx).w
	move.w	d6,d0
	add.w	(SeasonGameCount).w,d0
	addq.w	#1,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	subq.w	#1,(printy).w
	move.w	d6,d0
	add.w	(SeasonGameCount).w,d0
	clr.w	d1
	move.b	(a5,d0.w),d1
	move.w	#5,(printx).w
	bsr.w	DrawTeamLogo3
	addq.w	#1,(printy).w
	move.w	#$18,(printx).w
	movea.l	#TeamLeaderValues,a0
	adda.w	(SeasonGameCount).w,a0
	adda.w	(SeasonGameCount).w,a0
	move.w	d6,d0
	asl.w	#1,d0
	move.w	(a0,d0.w),d0
	movea.l	#LeaderPrintJumps,a6
	move.w	(linemarkbuf+2).w,d4
	asl.w	#2,d4
	movea.l	(a6,d4.w),a6
	jsr	(a6)
	addq.w	#1,(printy).w
	addq.w	#1,d6
	cmp.w	(StatWork+$8).w,d6
	blt.w	.0
	bra.w	rtsLeaderRows

LeaderPrintJumps	;no IDA label. Value print handlers per category (word_FFBB20)
	dc.l	PrintLeaderNum
	dc.l	PrintLeaderAvg
	dc.l	PrintLeaderAvg
	dc.l	PrintLeaderPct
	dc.l	PrintLeaderPct
	dc.l	PrintLeaderAvg
	dc.l	PrintLeaderAvg

PrintLeaderNum	;no IDA label. Print d0 3 wide
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jmp	(print).l

PrintLeaderAvg	;no IDA label. Print d0 / 100 as nn.nn (3 wide, '.', 2 digits)
	ext.l	d0
	divu.w	#$64,d0
	swap	d0
	move.w	d0,-(sp)
	swap	d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	jsr	(printz).l
	String	'.',$0
	move.w	(sp)+,d0
	move.w	#2,d1
	jsr	(PushNumberWidthZero).l
	jmp	(print).l

PrintLeaderPct	;no IDA label. Print d0 3 wide followed by '%'
	jsr	(PrintLeaderNum).l
	jsr	(printz).l
	String	'%',$0
	rts

DrawPlayerLeaderRows	;no IDA label. Sorted list rows: rank, player name (team $772 table, d7 = value / 26 team, remainder player) and value from $FFFFA1AA (category 3 as nn.nn); records the last row in word_FFBB28
	clr.w	d6
	movea.l	#LeaderValues,a5
	move.w	#9,(printy).w
.0
	move.w	#5,(printx).w
	movea.l	#BlankLine40,a1
	jsr	(print).l
	move.w	#5,(printx).w
	addq.w	#1,(printy).w
	movea.l	#BlankLine40,a1
	jsr	(print).l
	move.w	d6,d0
	add.w	(SeasonGameCount).w,d0
	cmp.w	(StatWork+$C).w,d0
	blt.w	.1
	movea.l	#BlankLine40,a1
	move.w	#1,(printx).w
	jsr	(print).l
	move.w	d6,d0
	add.w	(SeasonGameCount).w,d0
	cmp.w	(StatWork+$A).w,d0
	bge.w	.4
	move.w	d0,(StatWork+$A).w
	bra.w	.4
.1
	move.w	#2,(printx).w
	move.w	d6,d0
	add.w	(SeasonGameCount).w,d0
	addq.w	#1,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	move.w	#6,(printx).w
	movea.l	#LeaderPlayers,a0
	move.w	d6,d0
	add.w	(SeasonGameCount).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	ext.l	d0
	divu.w	#$1A,d0
	move.w	d0,d7
	swap	d0
	jsr	(FormatPlayerNameD7).l
	jsr	(print).l
	move.w	#$14,(printx).w
	movea.l	#TeamList,a1
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	jsr	(print).l
	move.w	#$1D,(printx).w
	movea.l	#LeaderValues,a0
	move.w	d6,d0
	add.w	(SeasonGameCount).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	cmpi.w	#3,(linemarkbuf+2).w
	bne.w	.2
	ext.l	d0
	divu.w	#$64,d0
	swap	d0
	move.w	d0,-(sp)
	swap	d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	jsr	(printz).l
	String	'.',$0
	move.w	(sp)+,d0
	move.w	#2,d1
	jsr	(PushNumberWidthZero).l
	bra.w	.3
.2
	move.w	#3,d1
	jsr	(PushNumberWidth).l
.3
	jsr	(print).l
.4
	addq.w	#1,(printy).w
	addq.w	#1,d6
	cmp.w	(StatWork+$8).w,d6
	blt.w	.0
	bra.w	rtsLeaderRows

rtsLeaderRows	;no IDA label
	rts

LeaderTables	;no IDA label. RAM tables (team order) per category for DrawLeaderRows
	dc.l	LeaderTeamTbls
	dc.l	LeaderTeamTbls+$1A
	dc.l	LeaderTeamTbls+$34
	dc.l	LeaderTeamTbls+$68
	dc.l	LeaderTeamTbls+$82
	dc.l	LeaderTeamTbls+$9C
	dc.l	LeaderTeamTbls+$B6

DrawTeamLogo3	;no IDA label. Draw small team logo d1 from Teamblocksmap at word_FFAC40/42 (dobitmap). Saves all
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

BlankLine40	;no IDA label. String record (40 spaces) used by the League Leaders code before this range
	String	'                                       ',0

LeadersHelp	;no IDA label. League Leaders footer: printz2 "[]=Change Stats  B=Team Leaders" or (word_FFBB1E set) "B=Individual Leaders"
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(StatWork).w
	beq.w	.0
	jsr	(printz).l
	String	$BF,2,$1A,0
	jsr	(printz2).l
	String	$F9,1,'[]=Change Stats       B=Team Leaders ',$F9,0,0
	bra.w	.1
.0
	jsr	(printz).l
	String	$BF,2,$1A,0
	jsr	(printz2).l
	String	$F9,1,'[]=Change Stats  B=Individual Leaders',$F9,0,0
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PeriodStatsScreen	;no IDA label. period94 PeriodStatsScreen: both team logos, goals/shots by period and total; left/right switch, start exits
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(matchup).w
	moveq	#0,d0
	moveq	#$1C,d1
	move.l	#ControllerBgMap,(screenarg).l
	jsr	(DrawTeamScreen2).l
	jsr	(printz).l
	String	$FD,2,6,0
	movea.l	#PeriodStatsMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$BE,1,8,0
	move.w	#8,d0
	move.w	#8,d1
	jsr	(printz).l
	String	$BE,1,$F,0
	move.w	#8,d0
	move.w	#8,d1
	jsr	(printz).l
	String	$9E,2,9,0
	movea.l	#TeamLogoBitmaps,a0
	move.w	(VisTeam).w,d0
	asl.w	#2,d0
	movea.l	0(a0,d0.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	asl.w	#3,d0
	movea.l	#TeamLogoPalettes,a0
	subi.w	#$40,d0
	adda.w	d0,a0
	adda.l	(a2)+,a1
	clr.w	d1
	clr.w	d0
	moveq	#6,d2
	move.w	#6,d3
	moveq	#4,d5
	jsr	(dobitmap).l
	movea.l	#palfadenew+$40,a0
	movea.l	#palfadenew+$60,a1
	move.w	#7,d0
.0
	move.l	(a0)+,(a1)+
	dbf	d0,.0
	jsr	(printz).l
	String	$8E,2,$10,0
	movea.l	#TeamLogoBitmaps,a0
	move.w	(HomeTeam).w,d0
	asl.w	#2,d0
	movea.l	0(a0,d0.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	asl.w	#3,d0
	subi.w	#$40,d0
	movea.l	#TeamLogoPalettes,a0
	adda.w	d0,a0
	adda.l	(a2)+,a1
	clr.w	d1
	clr.w	d0
	moveq	#6,d2
	move.w	#6,d3
	moveq	#4,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$BD,4,1,0
	moveq	#$20,d0
	moveq	#6,d1
	jsr	(printbigz).l
	String	$BD,9,2,'Period',$BD,$15,2,'Stats',$BE,6,1
	btst	#1,(sflags7).w
	beq.w	.1
	jsr	(printz).l
	dc.w	$001C;String length: too many arguments for the String macro
	dc.b	$BE,$C,7,'1',$BE,$11,7,'2',$BE,$16,7,'3',$BE,$1A,7,'OT',$BE,' ',7,'Total',0
	bra.w	.2
.1
	jsr	(printz).l
	dc.w	$0016;String length: too many arguments for the String macro
	dc.b	$BE,$C,7,'1',$BE,$11,7,'2',$BE,$16,7,'3',$BE,' ',7,'Total'
.2
	bsr.w	PeriodStatsCaption
	bsr.w	PeriodStatsColumns
	move.w	#$18,(palcount).w
.3
	jsr	(WaitVSyncAndReadInput).l
	btst	#7,d1
	bne.w	.6
	btst	#2,d1
	bne.w	.5
	btst	#3,d1
	bne.w	.4
	bra.s	.3
.4
	tst.w	(matchup).w
	bne.s	.3
	st	(matchup).w
	bsr.w	PeriodStatsCaption
	bsr.w	PeriodStatsColumns
	bra.s	.3
.5
	tst.w	(matchup).w
	beq.s	.3
	clr.w	(matchup).w
	bsr.w	PeriodStatsCaption
	bsr.w	PeriodStatsColumns
	bra.s	.3
.6
	movem.l	(sp)+,d0-d7/a0-a6
	jmp	(ExitAttributeScreen2).l

PeriodStatsCaption	;no IDA label. PeriodStatsScreen .5: caption "Shots" + "[ For Goals" or "Goals" + "For Shots ]" by word_FFD262
	tst.w	(matchup).w
	beq.w	.0
	jsr	(printz).l
	String	$BE,$11,5,'Shots',$BE,$F,$1A,0
	jsr	(printz2).l
	String	$F9,1,'[ For Goals',$F9,0,0
	rts
.0
	jsr	(printz).l
	String	$BE,$11,5,'Goals',$BE,$F,$1A,0
	jsr	(printz2).l
	String	$F9,1,'For Shots ]',$F9,0,0
	rts

PeriodStatsColumns	;no IDA label. period94 PeriodStatsScreen tail (+$25A): print both teams' period columns (away row $B, home row $12) and the total
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BE,$0,$0,$0
	movea.l	#AwShots,a2
	move.w	#$B,(printy).w
	bsr.w	PeriodStatsTeam
	movea.l	#HmShots,a2
	move.w	#$12,(printy).w
	bsr.w	PeriodStatsTeam
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PeriodStatsTeam	;no IDA label. PeriodStatsScreen per team: goals ($344) or shots ($34C) by period up to the current one (OT if sflags7 bit 1), then the total
	lea	$344(a2),a0
	tst.w	(matchup).w
	beq.w	.0
	lea	$34C(a2),a0
.0
	clr.w	(matchuptimer).w
	move.w	#$B,(printx).w
	bsr.w	PeriodStatsValue
	cmpi.w	#1,(gsp).w
	blt.w	.1
	move.w	#$10,(printx).w
	bsr.w	PeriodStatsValue
	cmpi.w	#2,(gsp).w
	blt.w	.1
	move.w	#$15,(printx).w
	bsr.w	PeriodStatsValue
	cmpi.w	#3,(gsp).w
	blt.w	.1
	btst	#1,(sflags7).w
	beq.w	.1
	move.w	#$1A,(printx).w
	bsr.w	PeriodStatsValue
.1
	move.w	#$21,(printx).w
	jsr	(printz).l
	String	'   ',$0
	subq.w	#3,(printx).w
	move.w	(matchuptimer).w,d0
	move.w	#2,d1
	cmp.w	#$64,d0
	blt.w	.2
	move.w	#3,d1
.2
	jsr	(PushNumberWidth).l
	jsr	(print).l
	rts

PeriodStatsValue	;no IDA label. PeriodStatsScreen: print the next period value (a0)+ and add it to the total
	move.w	(a0)+,d0
	add.w	d0,(matchuptimer).w
	jsr	(printz).l
	String	'   ',$0
	subq.w	#3,(printx).w
	move.w	#2,d1
	cmp.w	#$64,d0
	blt.w	.0
	move.w	#3,d1
.0
	jsr	(PushNumberWidth).l
	jmp	(print).l

LineEditor	;no IDA label. stats94 LineEditor: "Line Editor" screen for team a2, slot cursor = 1
	bset	#0,$30(a2)
	moveq	#0,d0
	moveq	#$1C,d1
	move.l	#PlayerSelectMap1,(screenarg).l
	jsr	(DrawTeamScreen6).l
	clr.w	(DispAttribCtr).w
	clr.w	(PlayerScrollCtr).w
	move.w	#1,(setupvalues).w

LineEditorRedraw	;no IDA label. stats94 LineEditorRedraw: clear and redraw the whole editor (also the exit menu's return point)
	jsr	(LineEditorBg).l
	jsr	(seta2).l

LineEditorReturn	;no IDA label
	jsr	(printz2).l
	String	$FF,$2,$FD,$0,$FC,$0
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	st	(redrawicons).w
	jsr	(ClearMenuFlags).l

LineEditorMenu	;no IDA label. stats94 LineEditorMenu: slot cursor loop; start exits, C picks a player, d-pad moves via LineCursorTable
	jsr	(DrawLineEditorScreen).l
	jsr	(DrawAttributeMenu).l
.0
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	bne.w	ExitAttributeScreen
	btst	#5,d1
	bne.w	SelectAttributeItem
	moveq	#1,d0
	btst	#1,d1
	bne.w	.1
	moveq	#-1,d0
	btst	#0,d1
	bne.w	.1
	moveq	#8,d0
	btst	#3,d1
	bne.w	.1
	moveq	#-8,d0
	btst	#2,d1
	beq.s	.0
.1
	add.w	(setupvalues).w,d0
	tst.w	(OptLine).w
	beq.w	.2
	cmp.w	#1,d0
	blt.s	.0
	cmp.w	#5,d0
	bgt.s	.0
.2
	lea	LineCursorTable(pc),a0
	move.b	8(a0,d0.w),(setupvalues+1).w
	jsr	(DrawAttributeMenu).l
	bra.s	.0

SelectAttributeItem	;no IDA label. stats94 SelectAttributeItem: build the list of players for the slot and let the user pick one (UpdatePlayerAttribute)
	jsr	(ReadAttributeNibble).l
	move.w	d0,d1
	jsr	(GetForwards).l
	move.w	(setupvalues).w,d2
	andi.w	#7,d2
	cmp.w	#2,d2
	bgt.w	.0
	add.w	d0,d1
	jsr	(GetPlayerCount).l
	sub.w	d1,d0
.0
	subq.w	#1,d0
	move.w	d0,(screentimer).w
	clr.w	(PlayerScrollCtr).w
	clr.w	(VertLineScrolling).w
	movea.w	#$BC1E,a0
	clr.w	d2
.1
	move.b	d1,0(a0,d2.w)
	cmp.w	d1,d6
	bne.w	.2
	move.w	d2,(VertLineScrolling).w
.2
	addq.w	#1,d1
	addq.w	#1,d2
	dbf	d0,.1
	jsr	(PlayerSelectBg).l
	jsr	(ClearAttributeArea2).l
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
.3
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d1
	beq.w	.4
	jsr	(LineEditorBg).l
	bra.w	LineEditorMenu
.4
	btst	#5,d1
	bne.w	.9
	moveq	#1,d0
	btst	#1,d1
	bne.w	.6
	btst	#3,d1
	bne.w	.5
	moveq	#-1,d0
	btst	#0,d1
	bne.w	.6
	btst	#2,d1
	bne.w	.5
	bra.s	.3
.5
	add.w	(DispAttribCtr).w,d0
	bmi.s	.3
	move.w	d0,(DispAttribCtr).w
	jsr	(PrintAttribHeader).l
	bra.s	.3
.6
	add.w	(VertLineScrolling).w,d0
	bmi.s	.3
	cmp.w	(screentimer).w,d0
	bgt.s	.3
	move.w	d0,(VertLineScrolling).w
	cmp.w	(PlayerScrollCtr).w,d0
	bgt.w	.7
	move.w	d0,(PlayerScrollCtr).w
.7
	subq.w	#5,d0
	cmp.w	(PlayerScrollCtr).w,d0
	ble.w	.8
	move.w	d0,(PlayerScrollCtr).w
.8
	jsr	(PrintAttribHeader).l
	bra.w	.3
.9
	movea.w	#$BC1E,a3
	adda.w	(VertLineScrolling).w,a3
	move.b	(a3),d0
	addq.b	#1,d0
	move.w	(setupvalues).w,d2
	jsr	(UpdatePlayerAttribute).l
	jsr	(LineEditorBg).l
	bra.w	LineEditorMenu

PrintAttribHeader	;no IDA label. stats94 PrintAttribHeader: player list column header (PAttribColumns page word_FFD276), then 6 rows of names, selected row highlighted
	jsr	(printz).l
	String	$BE,$16,$1,$0
.0
	movea.l	#PAttribColumns,a1
	move.w	(DispAttribCtr).w,d0
	bra.w	.2
.1
	adda.w	(a1),a1
	addq.w	#4,a1
.2
	tst.w	(a1)
	dbmi	d0,.1
	bpl.w	.3
	subq.w	#1,(DispAttribCtr).w
	bra.s	.0
.3
	jsr	(print).l
	move.l	(a1),d4
	movea.w	#$BC1E,a3
	move.w	(PlayerScrollCtr).w,d2
	move.w	(screentimer).w,d1
	sub.w	d2,d1
	cmp.w	#5,d1
	bls.w	.4
	moveq	#5,d1
.4
	move.w	#2,(printy).w
.5
	jsr	(printz2).l
	String	$FE,$4,$FD,$3,$FA,$1,'                        ',$FD,$5
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
	move.b	0(a3,d2.w),d0
	jsr	(getNameandAttrib).l
	addq.w	#1,d2
	dbf	d1,.5
	rts

DrawAttributeMenu	;no IDA label. stats94 DrawAttributeMenu: draw the line icons for the cursor's line, then the selected player box
	moveq	#6,d5
	lea	AttributeMenuTable(pc),a0
	move.w	(setupvalues).w,d0
	lsr.w	#3,d0
	adda.w	d0,a0
	tst.w	(OptLine).w
	beq.w	.0
	subq.w	#1,a0
.0
	move.b	(a0),d0
	cmp.b	(redrawicons).w,d0
	beq.w	.1
	move.b	d0,(redrawicons).w
	jsr	(ClearAttributeArea).l
.1
	btst	d5,(redrawicons).w
	beq.w	.2
	bsr.w	DrawMenuIcon
.2
	dbf	d5,.1
	jsr	(printz2).l
	String	$F8,$4,$2,$8,$7,$F9,$1,$0
	jsr	(printz2).l
	String	$FD,$0,$FC,$7,'                                       ',$0
	jsr	(printz2).l
	String	$FD,$15,$FC,$7
	move.w	d6,d0
	jsr	(getname).l
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	move.w	d7,(printa).w
	jsr	(printsmall).l
	clr.w	(printfontset).w
	rts
	dc.b	0,1;the entry before AttributeMenuTable (read with OptLine set)

AttributeMenuTable	;no IDA label. stats94 AttributeMenuTable: per line, bit mask of the lines drawn together
	dc.b	7,7,7,$18,$18,$60,$60,$FF

DrawMenuIcon	;no IDA label. stats94 DrawMenuIcon: draw line d5 (name, then its player slots) at MenuIconPosTable
	moveq	#6,d0
	mulu.w	d5,d0
	lea	MenuIconPosTable(pc),a0
	adda.w	d0,a0
	tst.w	(OptLine).w
	beq.w	.0
	subq.w	#6,a0
.0
	move.w	(a0),(printx).w
	move.w	2(a0),(printy).w
	move.w	d5,d0
	movea.l	#linelist,a1
	move.w	#$8000,(printa).w
	jsr	(PrintSmallListItem).l
	jsr	(printz2).l
	String	' Line',$0
	move.w	(a0),(printx).w
	move.w	d5,d4
	asl.w	#3,d4
	addq.w	#1,d4
	move.w	2(a0),(printy).w
	move.w	4(a0),d3
	lea	$16C(a2),a3
.1
	move.w	(a0),(printx).w
	jsr	(printz2).l
	String	$FB,$FF,$FA,$2,$FE,$6
	clr.w	d0
	move.b	0(a3,d4.w),d0
	subq.w	#1,d0
	jsr	(FormatPlayerNameShort).l
	cmp.w	(setupvalues).w,d4
	bne.w	.2
	move.w	d0,d6
	move.w	(printa).w,d7
	move.w	#2,(printfontset).w
.2
	jsr	(printsmall).l
	clr.w	(printfontset).w
	addq.w	#1,d4
	dbf	d3,.1
	rts

ClearAttributeArea	;no IDA label. stats94 ClearAttributeArea: erase the line area and print the position header (LD RD LW C RW)
	jsr	(printz2).l
	String	$FF,$2,$FD,$0,$FC,$A
	moveq	#$28,d0
	moveq	#$12,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	(MenuIconPosTable+2).l,(printy).l
	move.w	(MenuIconPosTable).l,(printx).l
	tst.w	(OptLine).w
	beq.w	.0
	move.w	(MenuIconPosTable-6).l,(printx).l
.0
	jsr	(printz2).l
	dc.w	$22;String length
	dc.b	$FE,$4,$FB,$FD,$FA,$2,'LD',$FB
	dc.b	$FE,$FA,$2,'RD',$FB,$FE,$FA,$2
	dc.b	'LW',$FB,$FE,$FA,$2,'C ',$FB,$FE
	dc.b	$FA,$2,'RW'
	rts

DrawLineEditorScreen	;no IDA label. stats94 DrawTeamScreen: clear, print the "Line Editor" title and the team logo (95: no ScoutMap bitmap / Framer)
	jsr	(ClearAttributeArea2).l
	jsr	(printz).l
	String	$BE,$7,$1,$0
	moveq	#$1A,d0
	moveq	#6,d1
	jsr	(printbigz).l
	String	$BE,$A,$4,'Line  Editor',$BE,$E,$1
	clr.w	d0
	cmpa.w	#$C288,a2
	beq.w	.0
	move.w	#$2C,d0
.0
	jmp	(PutTeamBlock).l

ClearAttributeArea2	;no IDA label. stats94 ClearAttributeArea2: erase 40 x 10 at the top of map 2
	jsr	(printz).l
	String	$BE,$0,$0,$0
	moveq	#$28,d0
	moveq	#$A,d1
	move.w	#$7FF,d2
	jmp	(eraser).l

ClearMenuFlags	;no IDA label. stats94 ClearMenuFlags: clear word_FFB99C and word_FFB9BC
	clr.w	(palfadenew+$5A).w
	clr.w	(palfadenew+$7A).w
	rts
	dc.w	$10,$C,4;MenuIconPosTable-6: the entry used with OptLine set

MenuIconPosTable	;no IDA label. stats94 MenuIconPosTable: line icons x, y, slot count - 1
	dc.w	4,$C,4
	dc.w	$10,$C,4
	dc.w	$1C,$C,4
	dc.w	4,$C,4
	dc.w	$10,$C,4
	dc.w	4,$C,3
	dc.w	$10,$C,3
	dc.w	$FFFF

LineCursorTable	;no IDA label. stats94 LineCursorTable: the slot after a cursor move, indexed by slot + 8
	dc.b	1,1,2,3,4,5,$19,1
	dc.b	1,1,2,3,4,5,$19,1
	dc.b	9,9,$A,$B,$C,$D,$21,1
	dc.b	$11,$11,$12,$13,$14,$15,$21,1
	dc.b	5,$19,$1A,$1B,$1C,$1D,$29,1
	dc.b	$D,$21,$22,$23,$24,$25,$31,1
	dc.b	$1D,$29,$2A,$2B,$2C,$2C,1,1
	dc.b	$25,$31,$32,$33,$34,$34,1,1
	dc.b	$25,$31,$32,$33,$34,$34,1,1

ExitAttributeScreen	;no IDA label. stats94 ExitAttributeScreen (95 rewrite): exit box; Start leaves, A original lines, B load / C save team line (save RAM)
	jsr	(ClearMenuFlags).l
	btst	#6,(sflags11).w
	beq.w	.0
	jsr	(printz).l
	String	$CE,$8,$A,$0
	move.w	#$18,d0
	move.w	#9,d1
	jsr	(Framer).l
	jsr	(printz2).l
	dc.w	$32;String length
	dc.b	$F8,$4,$2,$9,$B,$F9,$2,'Start = Exit'
	dc.b	$FD,$9,$FC,$D,'A = Set Original Lines',$F9,$0,$0
	bra.w	.2
.0
	bsr.w	TeamLinesOffset
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	move.b	$38(a0),d0
	cmp.b	#$64,d0
	bne.w	.1
	bset	#1,(sflags10).w
	jsr	(printz).l
	String	$CE,$8,$A,$0
	move.w	#$18,d0
	move.w	#9,d1
	jsr	(Framer).l
	jsr	(printz2).l
	dc.w	$5E;String length
	dc.b	$F8,$4,$2,$9,$B,$F9,$2,'Start = Exit'
	dc.b	$FD,$9,$FC,$D,'A = Set Original Lines',$FD,$9,$FC
	dc.b	$F,'B = Load Team Line',$FD,$9,$FC,$11,'C = Save Team Line',$F9
	dc.b	$0,$0
	bra.w	.2
.1
	bclr	#1,(sflags10).w
	jsr	(printz).l
	String	$CE,$8,$A,$0
	move.w	#$18,d0
	move.w	#7,d1
	jsr	(Framer).l
	jsr	(printz2).l
	dc.w	$48;String length
	dc.b	$F8,$4,$2,$9,$B,$F9,$2,'Start = Exit'
	dc.b	$FD,$9,$FC,$D,'A = Set Original Lines',$FD,$9,$FC
	dc.b	$F,'C = Save Team Line',$F9,$0,$0
	bra.w	.2
.2
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	tst.w	d1
	beq.s	.2
	btst	#7,d1
	beq.w	.3
	bra.w	.7
.3
	btst	#6,d1
	beq.w	.4
	jsr	(LoadTeamLines).l
	bra.w	LineEditorReturn
.4
	btst	#6,(sflags11).w
	bne.s	.2
	btst	#4,d1
	beq.w	.5
	btst	#1,(sflags10).w
	beq.w	.5
	movea.l	#StatBuf,a0
	jsr	(CopyTeamLines).l
	bra.w	LineEditorReturn
.5
	btst	#5,d1
	beq.w	.6
	jsr	(SaveTeamLines).l
	bra.w	LineEditorReturn
.6
	bra.s	.2
.7
	jmp	(ExitAttributeScreen2).l

LineEditorBg	;no IDA label. draw the line editor background bitmap (LineEditorBgMap) on map 2, clear byte_FFBEF8 bit 1
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#1,(BA_PS_flags).w
	move.w	(screen6chars2).w,d4
	jsr	(printz).l
	String	$FD,$0,$0,$0
	movea.l	#LineEditorBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	movea.l	#$69A,a2
	moveq	#$F,d5
	jsr	(dobitmap).l
	move.w	#$18,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayerSelectBg	;no IDA label. draw the player select list background bitmaps (PlayerSelectMap1, PlayerSelectMap2) on map 2, set byte_FFBEF8 bit 1
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#1,(BA_PS_flags).w
	move.w	(screen6chars1).w,d4
	jsr	(printz).l
	String	$FD,$0,$0,$0
	movea.l	#PlayerSelectMap1,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	#$A,d3
	movea.l	#$69A,a2
	moveq	#0,d5
	jsr	(dobitmap).l
	move.w	(screen6chars3).w,d4
	jsr	(printz).l
	String	$FD,$0,$0,$0
	movea.l	#PlayerSelectMap2,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	movea.l	#$69A,a2
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

UpdatePlayerAttribute	;no IDA label. stats94 UpdatePlayerAttribute: put player d0 in line slot d2 of team a2 (swap if already in that line)
	movem.l	d0-d2/a0-a1,-(sp)
	lea	$16C(a2),a0
	move.w	d2,d1
	andi.w	#$FFF8,d1
	lea	0(a0,d1.w),a1
	moveq	#5,d1
.0
	cmp.b	1(a1,d1.w),d0
	dbeq	d1,.0
	bne.w	.1
	move.b	0(a0,d2.w),1(a1,d1.w)
.1
	move.b	d0,0(a0,d2.w)
	movem.l	(sp)+,d0-d2/a0-a1
	rts

SaveTeamLines	;no IDA label. C in exit menu: save team a2's lines ($16C) to save RAM at the team's slot and mark the buffer valid ($64)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	TeamLinesOffset
	move.l	d0,-(sp)
	lea	$16C(a2),a0
	jsr	(WriteSRAM).l
	movea.l	#StatBuf,a0
	move.b	#$64,(a0)
	moveq	#1,d1
	move.l	(sp)+,d0
	addi.l	#$38,d0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CopyTeamLines	;no IDA label. B in exit menu: copy the loaded line data (a0, 56 bytes) into team a2's lines ($16C)
	movem.l	d0-d7/a0-a6,-(sp)
	lea	$16C(a2),a1
	move.w	#$D,d0
.0
	move.l	(a0)+,(a1)+
	dbf	d0,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

TeamLinesOffset	;no IDA label. d0 = save RAM offset of team a2's saved line ($39 bytes per team; base by byte_FFBF08 bit 3 / byte_FFBF0A bit 0)
	move.l	#$4530,d0
	btst	#3,(GameFlags).w
	bne.w	.1
	btst	#0,(sflags10).w
	bne.w	.0
	bra.w	.2
.0
	move.l	#$5136,d0
	bra.w	.2
.1
	move.l	#$4B6C,d0
.2
	moveq	#$39,d1
	move.w	d1,-(sp)
	mulu.w	$28(a2),d1
	add.l	d1,d0
	move.w	(sp)+,d1
	rts

DisplayPeriodOver	;IDA: sub_95B1E
	cmpi.w	#$40,(RefCnt).w
	bgt.w	.4
	bset	#7,(gmode).w
	bne.w	.4
	btst	#7,(sflags9).w
	bne.w	.4
	movem.l	d0/a1,-(sp)
	bset	#3,(disflags).w
	move.w	(vcount).w,d0
.0
	cmp.w	(vcount).w,d0
	beq.s	.0
	movem.l	(sp)+,d0/a1
	movem.l	d0-d5/a0-a4,-(sp)
	jsr	(printz).l
	String	$BF,$2,$E,$0
	moveq	#$1C,d0
	moveq	#9,d1
	jsr	(Framer).l
	jsr	(printz).l
	String	$BF,$9,$10,'Stars of the Game',$BF,$3,$F,$0
	bsr.w	CalculateTeamAttributes
	move.w	#$12,(printy).w
	moveq	#2,d2
.1
	bsr.w	FindMaxAttributeTEam
	move.w	#$1A,(printx).w
.2
	addq.w	#1,(printy).w
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	jsr	(print).l
	jsr	(getname).l
	move.w	#3,(printx).w
	jsr	(print).l
	dbf	d2,.1
	move.w	(HmGoals).w,d0
	sub.w	(AwGoals).w,d0
	ble.w	.3
	move.w	#$F,-(sp)
	jsr	(song).l
.3
	movem.l	(sp)+,d0-d5/a0-a4
.4
	rts

FindMaxAttributeTEam	;IDA: sub_95BEA
	movem.l	d1-d2/a1/a4,-(sp)
.0
	movea.w	#(StatBuf-M68K_RAM),a4
	clr.l	d0
	moveq	#$33,d2
.1
	cmp.l	(a4)+,d0
	bge.w	.2
	lea	-4(a4),a1
	move.l	(a1),d0
.2
	dbf	d2,.1
	clr.l	(a1)
	move.w	a1,d0
	subi.w	#$CAF8,d0
	lsr.w	#2,d0
	movea.w	#(HmShots-M68K_RAM),a2
	cmp.w	#$1A,d0
	blt.w	.3
	subi.w	#$1A,d0
	adda.w	#$366,a2
.3
	movem.l	(sp)+,d1-d2/a1/a4
	rts

CalculateTeamAttributes	;IDA: sub_95C2A
	movea.w	#(StatBuf-M68K_RAM),a4
	jsr	(GetPeriodTime).l
	move.w	d0,d5
	add.w	d2,d5
	movea.w	#(HmShots-M68K_RAM),a2
	lea	$366(a2),a3
	bsr.w	CalculateTeamAttributeValues
	movea.w	a3,a2
	lea	-$366(a2),a3
	bsr.w	CalculateTeamAttributeValues
	cmpi.w	#3,(gsp).w
	bne.w	.1
	tst.w	d3
	beq.w	.1
	movea.w	#(ChkCnt-M68K_RAM),a0
	adda.w	(ScoreSumbytes).w,a0
	clr.w	d0
	btst	#7,2(a0)
	beq.w	.0
	addi.w	#$1A,d0
.0
	add.b	3(a0),d0
	asl.w	#2,d0
	movea.w	#(StatBuf-M68K_RAM),a0
	move.l	#$7FFFFFFF,(a0,d0.w)
.1
	rts

CalculateTeamAttributeValues	;IDA: sub_95C8A
	movea.w	a2,a1
	move.w	$C(a2),d3
	sub.w	$C(a3),d3
	ext.l	d3
	moveq	#$19,d4
	jsr	(ReadAttributeNibble).l
	neg.w	d0
	add.w	d4,d0
.0
	move.l	d3,(a4)
	cmp.w	d0,d4
	bhi.w	.2
	clr.w	d1
	move.b	$B6(a2),d1
	mulu.w	#$2AF8,d1
	add.l	d1,(a4)
	clr.w	d1
	move.b	$D0(a2),d1
	mulu.w	#$2774,d1
	add.l	d1,(a4)
	clr.w	d1
	move.b	$EA(a2),d1
	mulu.w	#$A,d1
	tst.w	d3
	bne.w	.1
	mulu.w	#$64,d1
	add.l	d1,(a4)
	clr.l	d1
	add.w	$138(a1),d1
.1
	add.l	d1,(a4)
	bra.w	.3
.2
	cmp.w	$138(a1),d5
	bhi.w	.3
	clr.w	d1
	move.b	$B6(a2),d1
	mulu.w	#$64,d1
	clr.w	d2
	move.b	$EA(a2),d2
	beq.w	.3
	divu.w	d2,d1
	cmp.w	#4,d1
	bhi.w	.3
	addi.l	#$7D00,(a4)
	tst.w	d1
	bne.w	.3
	addi.l	#$124F8,(a4)
.3
	addq.w	#2,a1
	addq.w	#1,a2
	addq.w	#4,a4
	dbf	d4,.0
	rts

HighlightsScreen	;no IDA label. 95 season NHL HIGHLIGHTS screen: draw bg/title, joypad loop: left/right change day (byte_FFD1A6), up/down change game (word_FFBB1A), Start exits
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ReadSeasonHeader).l
	btst	#0,(sflags11).w
	bne.w	.0
	jsr	(SkipToGameDay).l
	btst	#3,(SeasonFlags).w
	bne.w	.13
.0
	jsr	(BuildSeasonTeamList).l
	move.b	(SeasonDay).w,(GamesTodayDay).w
	move.l	#ControllerBgMap,(screenarg).l
	bsr.w	GamesTodayGfx
	jsr	(printz).l
	String	$FE,$2,$6,$0
	movea.l	#HighlightsBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(PrintHighlightsTitle).l
	jsr	(HighlightsHelp).l
	clr.w	(rosterscroll).w
	move.w	#$FFFF,(setupdir).w
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	bsr.w	DrawHighlightPage
.1
	cmpi.w	#$FFFF,(setupdir).w
	beq.w	.2
	bsr.w	DrawHighlightPage
.2
	bsr.w	ReadAnyPad7
	move.w	(SelectedPlayerIdx).w,(setupprevline).w
	tst.w	d1
	bne.w	.4
	move.b	(SeasonDay).w,d0
	cmp.b	(GamesTodayDay).w,d0
	beq.w	.3
	jsr	(ReadSeasonHeader).l
	jsr	(BuildSeasonTeamList).l
.3
	jmp	(Opening2).l
.4
	move.w	#$FFFF,(setupdir).w
	btst	#7,d1
	bne.w	.12
	btst	#2,d1
	bne.w	.8
	btst	#3,d1
	bne.w	.7
	btst	#1,d1
	beq.w	.5
	bra.w	.11
.5
	btst	#0,d1
	beq.w	.6
	bra.w	.9
.6
	bra.s	.1
.7
	move.w	#$FFFF,(setupdir).w
	movem.w	d0,-(sp)
	move.b	(SeasonDay).w,d0
	cmp.b	(GamesTodayDay).w,d0
	movem.w	(sp)+,d0
	beq.w	.1
	move.w	#3,(setupdir).w
	addq.b	#1,(SeasonDay).w
	jsr	(DayHasGames).l
	beq.s	.7
	jsr	(BuildSeasonTeamList).l
	clr.w	(rosterscroll).w
	bra.w	.1
.8
	move.w	#$FFFF,(setupdir).w
	tst.b	(SeasonDay).w
	beq.w	.1
	move.w	#2,(setupdir).w
	jsr	(PrevSeasonDay).l
	jsr	(DayHasGames).l
	beq.s	.8
	jsr	(BuildSeasonTeamList).l
	clr.w	(rosterscroll).w
	bra.w	.1
.9
	move.w	#0,(setupdir).w
	tst.w	(rosterscroll).w
	bne.w	.10
	move.w	#$FFFF,(setupdir).w
	bra.w	.1
.10
	subq.w	#1,(rosterscroll).w
	bra.w	.1
.11
	move.w	#1,(setupdir).w
	movem.w	d0,-(sp)
	addq.w	#1,(rosterscroll).w
	move.w	(rosterscroll).w,d0
	cmp.b	(SeasonTeams+$1).w,d0
	movem.w	(sp)+,d0
	blt.w	.1
	subq.w	#1,(rosterscroll).w
	move.w	#$FFFF,(setupdir).w
	bra.w	.1
.12
	jsr	(forceblack).l
	move.b	(SeasonDay).w,d0
	cmp.b	(GamesTodayDay).w,d0
	beq.w	.13
	jsr	(ReadSeasonHeader).l
	jsr	(BuildSeasonTeamList).l
.13
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadAnyPad7	;no IDA label. Highlights joypad wait: each frame poll joypads (ReadJoy1/7A4C8/7A4E0/7A50C + ProcessInputWithRepeat) until d1 != 0
	move.l	#$5460,d6
.0
	move.w	#$64,d6
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.0
	move.w	(vcount).w,(oldvcount).w
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	bra.w	.5
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.5
.2
	tst.w	(FourWayPlay).w
	beq.w	.4
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.3
	bra.w	.5
.3
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.4
	bra.w	.5
.4
	dbf	d6,.0
.5
	rts

PrintHighlightsTitle	;no IDA label. print big title NHL HIGHLIGHTS
	jsr	(printbigz).l
	String	$BF,$8,$2,'NHL HIGHLIGHTS',$0
	rts

DrawHighlightPage	;no IDA label. draw the current highlight page: day header, team logos/score of game word_FFBB1A, then goal/star list
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(VisTeam).w,-(sp)
	move.w	(HomeTeam).w,-(sp)
	move.w	#$28,d0
	move.w	#$13,d1
	move.w	#$7FF,d2
	jsr	(printz).l
	String	$FF,$0,$6,$0
	jsr	(eraser).l
	movea.l	#SeasonTeams,a0
	clr.w	d1
	move.b	1(a0),d3
	beq.w	.0
	jsr	(printz).l
	String	$FF,$14,$7,$0
	movem.l	d0/a0-a1,-(sp)
	jsr	(MakeDateString).l
	movea.l	#StatWork,a1
	move.w	(a1),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jsr	(print).l
	movem.l	(sp)+,d0/a0-a1
	move.w	(rosterscroll).w,d0
	mulu.w	#5,d0
	addq.w	#2,d0
	jsr	(printz).l
	String	$FF,$7,$A,$0
	clr.w	d1
	move.b	0(a0,d0.w),d1
	move.w	d1,(HomeTeam).w
	bsr.w	DrawTeamLogo4
	move.w	#7,(printx).w
	move.w	#$E,(printy).w
	clr.w	d1
	move.b	1(a0,d0.w),d1
	move.w	d1,(VisTeam).w
	bsr.w	DrawTeamLogo4
	bsr.w	PrintGameScore2
	bsr.w	DrawHighlightEntry
.0
	move.w	(sp)+,(HomeTeam).w
	move.w	(sp)+,(VisTeam).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawHighlightEntry	;no IDA label. clear text area ($FFFFCAF8 via ReadSRAM) and print one highlight entry (PrintHighlight)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	GetHighlightSlot
	moveq	#4,d1
	movea.l	#StatBuf,a0
	jsr	(ReadSRAM).l
	jsr	(printz).l
	String	$FF,$14,$13,$0
	bsr.w	PrintHighlight
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintStatHighlight	;no IDA label. print a highlight record of type 4: player name + stat line "a-b-c" (bytes FFBB1E/FFBB20/FFBB1F), centered
	move.l	a0,-(sp)
	jsr	(printz).l
	String	$FF,$14,$13,$0
	move.w	(a0),d0
	andi.w	#$FFF,d0
	move.w	d0,-(sp)
	mulu.w	#3,d0
	addi.l	#$1AF6,d0
	movea.l	#StatWork,a0
	moveq	#3,d1
	jsr	(ReadSRAM).l
	move.w	(sp)+,d0
	asl.w	#2,d0
	movea.l	#TeamList,a0
	movea.l	0(a0,d0.w),a0
	adda.w	4(a0),a0
	move.w	(a0),d0
	movea.l	#mesarea,a1
	bra.w	.1
.0
	move.b	(a0)+,(a1)+
.1
	dbf	d0,.0
	movea.l	#mesarea,a3
	jsr	(appendz).l
	String	' ',$0
	clr.w	d0
	move.b	(StatWork).w,d0
	bsr.w	AppendNumber
	jsr	(appendz).l
	String	'-',$0
	clr.w	d0
	move.b	(linemarkbuf+2).w,d0
	bsr.w	AppendNumber
	jsr	(appendz).l
	String	'-',$0
	clr.w	d0
	move.b	(StatWork+$1).w,d0
	bsr.w	AppendNumber
	movea.l	#mesarea,a3
	move.w	(a3),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	movea.l	a3,a1
	jsr	(print).l
	movea.l	(sp)+,a0
	rts

AppendNumber	;no IDA label. append number d0 (1 or 2 digits) to string at $FFFFBBAA
	movea.l	#mesarea,a3
	move.w	#2,d1
	cmp.w	#9,d0
	bgt.w	.0
	move.w	#1,d1
.0
	jsr	(PushNumberWidth).l
	jsr	(appstring).l
	movea.l	#mesarea,a3
	rts

PrintHighlight	;no IDA label. print highlight record a0: type (bits 13-15) 0 none, 4 stat line, else player name + count + GOAL(S)/ASSIST(S)/SAVE(S)
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d0
	move.w	(a0),d0
	lsr.w	#8,d0
	lsr.w	#5,d0
	tst.w	d0
	beq.w	.2
	cmp.w	#4,d0
	bne.w	.0
	bsr.w	PrintStatHighlight
	bra.w	.2
.0
	move.w	(a0),d0
	move.l	a0,-(sp)
	andi.w	#$1FFF,d0
	jsr	(FormatLastNameAlt).l
	movea.l	a1,a3
	movea.l	(sp)+,a0
	move.w	2(a0),d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	move.l	a3,-(sp)
	jsr	(appstring).l
	movea.l	(sp)+,a3
	move.w	(a0),d0
	lsr.w	#8,d0
	lsr.w	#5,d0
	asl.w	#2,d0
	movea.l	#HighlightPlurals,a6
	cmpi.w	#1,2(a0)
	bne.w	.1
	movea.l	#HighlightSingulars,a6
.1
	movea.l	0(a6,d0.w),a1
	move.l	a3,-(sp)
	jsr	(appstring).l
	movea.l	(sp)+,a3
	move.w	(a3),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	movea.l	a3,a1
	jsr	(print).l
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

HighlightPlurals	;no IDA label. plural suffix pointers by record type
	dc.l	0,AssistText,GoalsText,SavesText

HighlightSingulars	;no IDA label. singular suffix pointers by record type
	dc.l	0,SaveText,AssistsText,GoalText

GoalsText	;no IDA label
	String	' ASSISTS'

AssistsText	;no IDA label
	String	' ASSIST',$0

SavesText	;no IDA label
	String	' SAVES'

GoalText	;no IDA label
	String	' SAVE',$0

AssistText	;no IDA label
	String	' GOALS'

SaveText	;no IDA label
	String	' GOAL',$0

PrintGameScore2	;no IDA label. print the game's score (bytes 2/3 of game record a0+d0) or ".......LATER" if not yet played
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#1,4(a0,d0.w)
	bne.w	.0
	jsr	(printz).l
	String	$FF,$13,$E,'.......LATER',$0
	bra.w	.1
.0
	clr.w	d5
	move.b	2(a0,d0.w),d5
	move.w	#$19,(printx).w
	move.w	#$A,(printy).w
	bsr.w	PrintScore2
	move.b	3(a0,d0.w),d5
	move.w	#$19,(printx).w
	move.w	#$E,(printy).w
	bsr.w	PrintScore2
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintScore2	;no IDA label. print 2-digit number d5 at current cursor (PushNumberWidth + printbig)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d5,d0
	moveq	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printbig).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawTeamLogo4	;no IDA label. draw team logo d1 (from Teamblocksmap graphics, palette word_FFBFC8) via dobitmap
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
