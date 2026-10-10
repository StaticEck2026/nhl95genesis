;	NHL 95 period95. Retail $0920DE-$0925AD (1232 bytes).
;	Mapped to period94 (87%): GameStatisticsScreen, its scroll step, SetStatScroll, StatScrollRow / StatScrollRowEnd,
;	PrintStatScrollArrows, DisplayTeamStatsScreen, FormatStatValue, TeamStatTextTbl and TeamStatTextTblNoPen. The rest of
;	period94 is in other 95 files; rtsStatTables, the rts after the tables, starts stats95_01 at $0925AE.
;	The segment map started this file at $0920BE (IDA loc_920BE), but $0920BE-$0920DD is the end of season95's SimTieTbl
;	(26 teams x 3 bytes); GameStatisticsScreen (no IDA label) starts at $0920DE.
;	IDA read the screen head, the arrows and the Strings in DisplayTeamStatsScreen / FormatStatValue as code or dc.b; they are
;	written from the retail bytes.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

GameStatisticsScreen	;no IDA label. period94 GameStatisticsScreen (93 name). Pause menu GAME STATS: both teams' totals
	;(DisplayTeamStatsScreen). There are more rows than the screen: up / down scroll them (matchupvis the most, $70 or $30 without
	;penalties, OptPen), start exits (ExitAttributeScreen2). 95 draws the screen with DrawTeamScreen2 (ControllerBgMap)
	moveq	#9,d0
	moveq	#$19,d1
	move.l	#ControllerBgMap,(screenarg).l
	jsr	(DrawTeamScreen2).l
	jsr	(printbigz).l
	String	$BD,7,2,'Game',$BD,$10,2,'Statistics',$BD,7,1,0
	clr.w	(DispAttribCtr).w
	clr.w	(VertLineScrolling).w
	clr.w	(PlayerScrollCtr).w
	move.w	#$70,(matchupvis).w	;the most scroll: 15 rows
	tst.w	(OptPen).w
	bne.w	.0
	move.w	#$30,(matchupvis).w	;11 rows
.0
	bsr.w	DisplayTeamStatsScreen
	bsr.w	PrintStatScrollArrows
.loop
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	btst	#7,d3
	beq.w	.1
	jmp	ExitAttributeScreen2
.1
	jsr	(nodiag).l
	move.w	#$FFFE,d0
	btst	#0,d3
	bne.w	.2
	neg.w	d0
	btst	#1,d3
	beq.w	.3
.2
	move.w	d0,(PlayerScrollCtr).w
.3
	bsr.w	StatScrollStep
	bsr.w	PrintStatScrollArrows
	bra.s	.loop
StatScrollStep	;IDA: sub_9217E. GameStatisticsScreen .4 in 94: one scroll step of PlayerScrollCtr, within 0 ... matchupvis
	move.w	(PlayerScrollCtr).w,d0
	beq.w	rtsStatTables
	add.w	(VertLineScrolling).w,d0
	bmi.w	rtsStatTables
	cmp.w	(matchupvis).w,d0
	bgt.w	rtsStatTables
	move.w	(VertLineScrolling).w,d1
	move.w	d0,(VertLineScrolling).w
	andi.w	#$F,d0
	bne.w	.5
	clr.w	(PlayerScrollCtr).w
.5
	andi.w	#$F,d1
	bne.w	SetStatScroll
	move.w	d0,-(sp)
	cmp.w	#$E,d0
	bne.w	.6
	bsr.w	StatScrollRow
.6
	move.w	(sp)+,d0
	cmp.w	#2,d0
	bne.w	SetStatScroll
	bsr.w	StatScrollRowEnd
SetStatScroll	;IDA: sub_921CE. period94 SetStatScroll. Plane A vertical scroll (VSRAM 0) = VertLineScrolling - $50, with disflags bit 2
	;set while it writes
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movea.l	#VDP_DATA,a0
	move.l	#$40020010,4(a0)
	move.w	#$FFB0,d0
	add.w	(VertLineScrolling).w,d0
	move.w	d0,(a0)
	move.w	(sp)+,(disflags).w
	rts
StatScrollRow	;IDA: sub_921F6. period94 StatScrollRow. d3 = VertLineScrolling / 16
	move.w	(VertLineScrolling).w,d3
	lsr.w	#4,d3
	bra.w	rtsStatScroll
StatScrollRowEnd	;IDA: sub_92200. period94 StatScrollRowEnd. d3 = VertLineScrolling / 16 + 6
	move.w	(VertLineScrolling).w,d3
	lsr.w	#4,d3
	addq.w	#6,d3
	bra.w	rtsStatScroll
rtsStatScroll	;IDA: locret_9220C. rts of StatScrollRow / StatScrollRowEnd
	rts
PrintStatScrollArrows	;IDA: loc_9220E. period94 PrintStatScrollArrows. Scroll arrows (printz2): up ($7B) when VertLineScrolling > 0, down
	;($7D) when it is below matchupvis
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz2).l
	String	$F9,1
	tst.w	(VertLineScrolling).w
	beq.w	.0
	jsr	(printz2).l
	String	$F8,4,3,'$',9,$F9,1,'{'
	bra.w	.1
.0
	jsr	(printz2).l
	String	$F8,4,3,'$',9,$F9,1,' '
.1
	move.w	(matchupvis).w,d0
	cmp.w	(VertLineScrolling).w,d0
	beq.w	.2
	jsr	(printz2).l
	String	$F8,4,3,'$',$19,$F9,1,'}'
	bra.w	.3
.2
	jsr	(printz2).l
	String	$F8,4,3,'$',$19,$F9,1,' '
.3
	jsr	(printz2).l
	String	$F9,0
	movem.l	(sp)+,d0-d7/a0-a6
	rts
DisplayTeamStatsScreen	;IDA: sub_92288. period94 DisplayTeamStatsScreen (93 name). Team blocks (PutTeamBlock), then each TeamStatTextTbl row
	;(TeamStatTextTblNoPen when penalties are off, OptPen) centred, with the home value at x $22 and the visitors' at x 9 (FormatStatValue);
	;SetStatScroll first
	jsr	(printz).l
	String	$BD,3,6,0
	move.w	#$2C,d0
	jsr	(PutTeamBlock).l
	jsr	(printz).l
	String	$BD,$1A,6,0
	moveq	#0,d0
	jsr	(PutTeamBlock).l
	bsr.w	SetStatScroll
	jsr	(printz).l
	String	$BE,0,0,0
	moveq	#$E,d6
	lea	TeamStatTextTbl(pc),a1
	tst.w	(OptPen).w
	bne.w	.loop
	move.w	#$A,d6
	lea	TeamStatTextTblNoPen(pc),a1
.loop
	move.w	(a1),d0
	lsr.w	#1,d0
	neg.w	d0
	addi.w	#$15,d0
	move.w	d0,(printx).w
	jsr	(print).l
	movea.l	a1,a0
	move.w	#$22,(printx).w
	movea.w	#(HmShots-M68K_RAM),a2
	bsr.w	FormatStatValue
	move.w	#9,(printx).w
	lea	tmsize(a2),a2
	bsr.w	FormatStatValue
	lea	4(a0),a1
	addq.w	#2,(printy).w
	dbf	d6,.loop
	rts
FormatStatValue	;IDA: sub_92318. period94 FormatStatValue (93 name). Print TeamStatTextTbl entry a0 for team a2 centred at printx: the
	;value (offsets $A and $354 are times, PushTime), "/second" if any, " (pct%)" for passing; offset $FFFF is the shooting percentage
	;(goals $C * 100 / shots 0), printed with a "%"
	movea.w	#(mesarea-M68K_RAM),a3
	move.w	#2,(a3)
	cmpi.w	#$FFFF,(a0)	;shooting percentage row
	bne.w	.1
	move.w	#$C,d0
	move.w	(a2,d0.w),d0
	mulu.w	#$64,d0
	move.w	#0,d1
	move.w	(a2,d1.w),d1
	beq.w	.0
	divu.w	d1,d0
.0
	jsr	(PushNumber).l
	jsr	(appstring).l
	jsr	(appendz).l
	String	'%'
	bra.w	.6
.1
	move.w	(a0),d0
	move.w	(a2,d0.w),d0
	cmpi.w	#$354,(a0)	;PP Minutes: a time (94 $352)
	bne.w	.2
	bsr.w	.8
	bra.w	.4
.2
	cmpi.w	#$A,(a0)
	beq.w	.3
	bsr.w	.7
.3
	cmpi.w	#$A,(a0)
	bne.w	.4
	bsr.w	.8
.4
	jsr	(appstring).l
	move.w	2(a0),d0
	bmi.w	.6
	jsr	(appendz).l
	String	'/'
	move.w	(a2,d0.w),d0
	jsr	(PushNumber).l
	jsr	(appstring).l
	cmpi.w	#$14,(a0)
	bne.w	.6
	jsr	(appendz).l
	String	' ('
	move.w	(a0),d0
	move.w	(a2,d0.w),d0
	mulu.w	#$64,d0
	move.w	2(a0),d1
	move.w	(a2,d1.w),d1
	beq.w	.5
	divu.w	d1,d0
.5
	jsr	(PushNumber).l
	jsr	(appstring).l
	jsr	(appendz).l
	String	'%)'
.6
	movea.w	a3,a1
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jmp	print
.7
	jmp	PushNumber
.8
	jmp	PushTime
TeamStatTextTbl	;IDA: unk_9240E. period94 TeamStatTextTbl (93 name). Label, then the team struct stat offset and the second offset ($FFFF
	;none). 15 rows; the offsets from $354 are 2 more than 94 (95 team struct)
	dc.w	$0008
	dc.b	'Score',0
	dc.w	$C,$FFFF
	dc.w	$0008
	dc.b	'Shots',0
	dc.w	0,$FFFF
	dc.w	$000E
	dc.b	'Shooting Pct'
	dc.w	$FFFF,$FFFF
	dc.w	$000C
	dc.b	'Power Play'
	dc.w	2,4
	dc.w	$000C
	dc.b	'PP Minutes'
	dc.w	$354,$FFFF
	dc.w	$000A
	dc.b	'PP Shots'
	dc.w	$356,$FFFF
	dc.w	$000A
	dc.b	'SH Goals'
	dc.w	$358,$FFFF
	dc.w	$000C
	dc.b	'Breakaways'
	dc.w	$35C,$35A
	dc.w	$000C
	dc.b	'One-Timers'
	dc.w	$360,$35E
	dc.w	$0010
	dc.b	'Penalty Shots',0
	dc.w	$364,$362
	dc.w	$000E
	dc.b	'Faceoffs Won'
	dc.w	$E,$FFFF
	dc.w	$000E
	dc.b	'Body Checks',0
	dc.w	$10,$FFFF
	dc.w	$000C
	dc.b	'Penalties',0
	dc.w	6,8
	dc.w	$000E
	dc.b	'Attack Zone',0
	dc.w	$A,$FFFF
	dc.w	$000A
	dc.b	'Passing',0
	dc.w	$14,$12
TeamStatTextTblNoPen	;IDA: unk_924FC. period94 TeamStatTextTblNoPen. The rows without the power play ones, used when penalties are off.
	;11 rows
	dc.w	$0008
	dc.b	'Score',0
	dc.w	$C,$FFFF
	dc.w	$0008
	dc.b	'Shots',0
	dc.w	0,$FFFF
	dc.w	$000E
	dc.b	'Shooting Pct'
	dc.w	$FFFF,$FFFF
	dc.w	$000C
	dc.b	'Breakaways'
	dc.w	$35C,$35A
	dc.w	$000C
	dc.b	'One-Timers'
	dc.w	$360,$35E
	dc.w	$0010
	dc.b	'Penalty Shots',0
	dc.w	$364,$362
	dc.w	$000E
	dc.b	'Faceoffs Won'
	dc.w	$E,$FFFF
	dc.w	$000E
	dc.b	'Body Checks',0
	dc.w	$10,$FFFF
	dc.w	$000C
	dc.b	'Penalties',0
	dc.w	6,8
	dc.w	$000E
	dc.b	'Attack Zone',0
	dc.w	$A,$FFFF
	dc.w	$000A
	dc.b	'Passing',0
	dc.w	$14,$12
