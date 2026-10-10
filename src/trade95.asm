;	NHL 95 trade95. Retail $0962EE-$097C53 (6502 bytes).
;	New in 95: the season roster helpers (GetHighlightSlot, HighlightsHelp, DefaultRosters, GetRosterId, GetCreatedName,
;	GetRosterName, Read / WriteTeamRoster, GetJerseyNumber) and the season trades: the Trade Player screen (TradePlayers),
;	CheckTrade (roster rules, INVALID TRADE), EvaluateTrade, GMDecision and ExecuteTrade, which moves the players with their
;	stats, saved lines and line slots. No 94 code. create95 follows at $097C54.
;	IDA hid printz / printz2 / printbigz Strings and DecompressGraphicsWithCallback remap bytes as instructions and left
;	HighlightsHelp and ReadTradePads3 as dc.b; they are written from the retail bytes.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

GetHighlightSlot	;IDA: sub_962EE. 95 only. d0 = save RAM offset ($5FD6 + 4 a game) of the highlight slot of HomeTeam's game today, -1 none
	movem.l	d1-d7/a0-a6,-(sp)
	clr.w	d1
	move.b	(SeasonDay).w,d1
	clr.w	d2
	move.b	(SeasonStartDay).w,d2
	movea.l	#$8DD8,a6
	clr.w	d5
	move.b	(a6)+,d5
	add.w	d2,d1
	cmp.w	d5,d1
	blt.w	.0
	sub.w	d5,d1
.0
	move.l	#$5FD6,d0
	bra.w	.2
.1
	clr.l	d3
	move.b	(a6)+,d3
	move.w	d3,d4
	add.w	d4,d4
	adda.w	d4,a6
	asl.w	#2,d3
	add.l	d3,d0
.2
	dbf	d1,.1
	move.b	(a6)+,d3
.3
	move.b	(a6),d4
	cmp.b	(HomeTeam+1).w,d4
	beq.w	.4
	addq.l	#4,d0
	addq.l	#2,a6
	dbf	d3,.3
	move.w	#$FFFF,d0
	bra.w	.4
.4
	movem.l	(sp)+,d1-d7/a0-a6
	rts

HighlightsHelp	;no IDA label. 95 only. HighlightsScreen help line: {} More games, [] Change day (called from HighlightsScreen)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printz).l
	String	$FF,2,$19,'{} More games',$FF,$19,$19,'[] Change day'
	move.w	(sp)+,(smallfontchars).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DefaultRosters	;IDA: sub_96390. 95 only. Build the default roster tables for the 28 teams in RAM (RosterTable $38 bytes a team: player ids, then the goalie, forward and defense counts; RosterRatings $20 a team) from TeamList
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#0,d1
	movea.l	#RosterTable,a6
	movea.l	#RosterRatings,a4
.0
	clr.w	d2
	movea.l	a6,a0
	move.w	#$19,d5
.1
	move.w	#$8000,(a0)+
	dbf	d5,.1
	movea.l	a6,a0
	movea.l	a4,a2
	movea.l	#TeamList,a1
	move.w	d1,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	(a1),a1
	bra.w	.3
.2
	cmpi.w	#2,(a1)
	beq.w	.4
	addq.w	#1,d2
.3
	move.b	d1,(a0)+
	move.b	d2,(a0)+
	adda.w	(a1),a1
	move.b	(a1),d4
	move.b	d4,(a2)+
	addq.w	#8,a1
	bra.s	.2
.4
	movem.l	d1-d7/a0,-(sp)
	move.w	d1,d7
	movea.l	#TeamList,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	adda.w	$A(a0),a0
	move.w	(a0),d1
	clr.w	d0
.5
	addq.w	#1,d0
	asl.w	#4,d1
	bne.s	.5
	movea.l	a6,a0
	move.b	d0,$34(a0)
	move.w	d0,d4
	movea.l	#TeamList,a0
	movea.l	(a0,d7.w),a0
	adda.w	8(a0),a0
	move.b	3(a0),d0
	lsr.w	#4,d0
	andi.w	#$F,d0
	movea.l	a6,a0
	move.b	d0,$36(a0)
	addq.w	#1,d2
	add.b	d4,d0
	sub.b	d0,d2
	move.b	d2,$35(a0)
	movem.l	(sp)+,d1-d7/a0
	adda.l	#$38,a6
	adda.l	#$20,a4
	addq.w	#1,d1
	cmp.w	#$1C,d1
	blt.w	.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GetRosterId	;IDA: sub_96454. 95 only. d0 = roster id word of player d0 of team d7 (season roster in save RAM $1B4C, or d7 << 8 | d0 outside a season)
	movem.l	d1/d6-d7/a0,-(sp)
	btst	#6,(sflags11).w
	beq.w	.0
	asl.w	#8,d7
	andi.w	#$FF,d0
	or.w	d7,d0
	bra.w	.1
.0
	mulu.w	#$38,d7
	add.w	d0,d0
	ext.l	d0
	add.l	d7,d0
	addi.l	#$1B4C,d0
	moveq	#2,d1
	movea.l	#SRAMbyte,a0
	jsr	(ReadSRAM).l
	move.w	(a0),d0
.1
	movem.l	(sp)+,d1/d6-d7/a0
	rts

GetCreatedName	;IDA: sub_96494. 95 only. a1 = player record of roster id d0 (created players from save RAM $5AA0)
	movem.l	d0-d1/d5-d7/a0,-(sp)
	bra.w	GetRosterNameTail
	rts

GetRosterName	;IDA: sub_9649E. 95 only. a1 = player record of player d0 of team d7: TeamList outside a season, else from the season roster (team $1C: the created players at $5D22)
	movem.l	d0-d1/d5-d7/a0,-(sp)
	btst	#6,(sflags11).w
	beq.w	.2
	move.w	d7,d6
	movea.l	#TeamList,a1
	asl.w	#2,d6
	movea.l	(a1,d6.w),a1
	adda.w	(a1),a1
	bra.w	.1
.0
	adda.w	(a1),a1
	addq.w	#8,a1
.1
	dbf	d0,.0
	movem.l	(sp)+,d0-d1/d5-d7/a0
	rts
.2
	cmp.w	#$1C,d7
	bne.w	.3
	add.w	d0,d0
	ext.l	d0
	addi.l	#$5D22,d0
	bra.w	.4
.3
	move.w	d7,d6
	mulu.w	#$38,d7
	add.w	d0,d0
	ext.l	d0
	add.l	d7,d0
	addi.l	#$1B4C,d0
.4
	moveq	#2,d1
	movea.l	#SRAMbyte,a0
	jsr	(ReadSRAM).l
	move.w	(a0),d0

GetRosterNameTail	;IDA: loc_96506. 95 only. GetCreatedName / GetRosterName: a1 = the player record of roster id d0
	move.w	d0,-(sp)
	andi.w	#$1F00,d0
	cmp.w	#$1E00,d0
	bne.w	.0
	move.w	(sp)+,d0
	andi.w	#$FF,d0
	asl.w	#5,d0
	ext.l	d0
	addi.l	#$5AA0,d0
	moveq	#$20,d1
	movea.l	#CreatedPlayerBuf+$2,a0
	jsr	(ReadSRAM).l
	movea.l	a0,a1
	bra.w	.3
.0
	move.w	(sp)+,d0
	move.w	d0,d6
	lsr.w	#8,d6
	andi.w	#$1F,d6
	andi.w	#$FF,d0
	movea.l	#TeamList,a1
	asl.w	#2,d6
	movea.l	(a1,d6.w),a1
	adda.w	(a1),a1
	bra.w	.2
.1
	adda.w	(a1),a1
	addq.w	#8,a1
.2
	dbf	d0,.1
.3
	movem.l	(sp)+,d0-d1/d5-d7/a0
	rts

ReadTeamRoster	;IDA: sub_96566. 95 only. Read team d7's $38 byte season roster from save RAM $1B4C into a0
	movem.l	d0-d1,-(sp)
	move.w	d7,d0
	mulu.w	#$38,d0
	addi.l	#$1B4C,d0
	moveq	#$38,d1
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d1
	rts

WriteTeamRoster	;IDA: sub_96584. 95 only. Write team d7's $38 byte season roster to save RAM $1B4C and update the checksum
	movem.l	d0-d1,-(sp)
	move.w	d7,d0
	mulu.w	#$38,d0
	addi.l	#$1B4C,d0
	moveq	#$38,d1
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d1
	rts

GetJerseyNumber	;IDA: sub_965A8. 95 only. jerseynum = the jersey number byte of player d0 of team d7 (TeamList or the season roster)
	movem.l	d0-d1/a0,-(sp)
	btst	#6,(sflags11).w
	beq.w	.2
	move.w	d7,-(sp)
	movea.l	#TeamList,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	adda.w	(a0),a0
	bra.w	.1
.0
	adda.w	(a0),a0
	addq.w	#8,a0
.1
	dbf	d0,.0
	adda.w	(a0),a0
	clr.w	(CreatedPlayerBuf).w
	move.b	(a0),(jerseynum).w
	move.w	(sp)+,d7
	bra.w	.3
.2
	move.w	d7,d1
	asl.w	#5,d1
	ext.l	d1
	ext.l	d0
	add.l	d1,d0
	addi.l	#$5700,d0
	moveq	#1,d1
	movea.l	#CreatedPlayerBuf,a0
	clr.b	(a0)+
	jsr	(ReadSRAM).l
.3
	movem.l	(sp)+,d0-d1/a0
	rts

MoveSavedLines	;IDA: sub_96608. 95 only. Fix team d7's saved line players (save RAM $5700) after player d0 left
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,d2
	jsr	(GetPlayerCountD7).l
	move.w	d0,d3
	movea.l	#ThreeStars,a0
	asl.w	#5,d7
	ext.l	d7
	addi.l	#$5700,d7
	move.l	d7,d0
	moveq	#$20,d1
	movem.l	d0-d1/a0,-(sp)
	jsr	(ReadSRAM).l
.0
	move.b	(a0,d2.w),d4
	move.w	d3,d5
	subq.w	#1,d5
	clr.w	d0
.1
	cmp.w	d0,d2
	beq.w	.3
	cmp.b	(a0,d0.w),d4
	bne.w	.3
	addq.b	#1,d4
	move.b	d4,d6
	andi.w	#$F,d6
	cmp.b	#$A,d6
	bne.w	.2
	addi.b	#$10,d4
	andi.w	#$F0,d4
	cmp.b	#$A0,d4
	bne.w	.2
	move.b	#1,d4
.2
	move.b	d4,(a0,d2.w)
	bra.s	.0
.3
	addq.w	#1,d0
	dbf	d5,.1
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ExecuteTrade	;IDA: sub_9668C. 95 only. Do the trade: sort the chosen players of both teams (TradeList at $FFCC32 / $FFCC3A), move each to the other team (MoveTradedPlayer) and close the gaps (RemoveTradedPlayer)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#tradeteam1,a0
	bsr.w	SortTradePlayers
	movea.l	#tradeteam2,a0
	bsr.w	SortTradePlayers
	movea.w	#(tradeteam1-M68K_RAM),a0
	movea.w	#(tradeteam2-M68K_RAM),a1
	move.w	#2,d6
.0
	movea.l	#M68K_RAM,a2
	move.w	(a0),(TradeFromTeam).w
	move.w	(a0,d6.w),d0
	bmi.w	.1
	move.w	d0,(TempWord1).w
	bsr.w	MoveTradedPlayer
	bsr.w	ShiftTradeDown
.1
	movea.l	#TradeBuf,a2
	move.w	(a1),(TradeFromTeam).w
	move.w	(a1,d6.w),d0
	bmi.w	.2
	move.w	d0,(TempWord1).w
	bsr.w	MoveTradedPlayer
	exg	a1,a0
	bsr.w	ShiftTradeDown
	exg	a1,a0
.2
	movea.l	#M68K_RAM,a2
	move.w	(a1),(TradeToTeam).w
	move.w	(a0,d6.w),d5
	bmi.w	.6
	andi.w	#$FF00,d5
	move.w	(a1),d7
	cmp.w	#0,d5
	bne.w	.3
	jsr	(ReadAttributeNibbleD7).l
	bra.w	.5
.3
	cmp.w	#$100,d5
	bne.w	.4
	jsr	(GetDefenseStartD7).l
	bra.w	.5
.4
	jsr	(GetPlayerCountD7).l
.5
	or.w	d0,d5
	move.w	d5,(TempWord2).w
	bsr.w	RemoveTradedPlayer
	movem.l	d0-d7/a0-a6,-(sp)
	exg	a0,a1
	bsr.w	ShiftTradeUp
	exg	a0,a1
	movem.l	(sp)+,d0-d7/a0-a6
.6
	movea.l	#TradeBuf,a2
	move.w	(a0),(TradeToTeam).w
	move.w	(a1,d6.w),d5
	bmi.w	.10
	andi.w	#$FF00,d5
	move.w	(a0),d7
	cmp.w	#0,d5
	bne.w	.7
	jsr	(ReadAttributeNibbleD7).l
	bra.w	.9
.7
	cmp.w	#$100,d5
	bne.w	.8
	jsr	(GetDefenseStartD7).l
	bra.w	.9
.8
	jsr	(GetPlayerCountD7).l
.9
	or.w	d0,d5
	move.w	d5,(TempWord2).w
	bsr.w	RemoveTradedPlayer
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	ShiftTradeUp
	movem.l	(sp)+,d0-d7/a0-a6
.10
	addq.w	#2,d6
	cmp.w	#8,d6
	blt.w	.0
	jsr	(CheckSavedLines).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SortTradePlayers	;IDA: sub_967BA. 95 only. Sort the chosen players of a trade list by position (goalies, forwards, defense)
	move.w	(a0)+,d7
	move.w	#2,d6
.0
	move.w	(a0)+,d1
	bmi.w	.2
	andi.w	#$FF,d1
	move.w	#0,d2
	jsr	(ReadAttributeNibbleD7).l
	cmp.w	d0,d1
	blt.w	.1
	move.w	#1,d2
	jsr	(GetDefenseStartD7).l
	cmp.w	d0,d1
	blt.w	.1
	move.w	#2,d2
.1
	move.b	d2,-2(a0)
.2
	dbf	d6,.0
	rts

ShiftTradeUp	;IDA: sub_967F8. 95 only. Trade list: player numbers after a removed player move up one
	move.b	(TempWord2+1).w,d0
.0
	tst.w	(a0,d6.w)
	bmi.w	.2
	cmp.b	1(a0,d6.w),d0
	bgt.w	.1
	addq.b	#1,1(a0,d6.w)
.1
	addq.w	#2,d6
	cmp.w	#8,d6
	blt.s	.0
.2
	rts

ShiftTradeDown	;IDA: sub_9681A. 95 only. Trade list: player numbers after an added player move down one
	movem.l	d0-d7/a0-a6,-(sp)
	addq.w	#2,d6
	cmp.w	#8,d6
	bge.w	.2
.0
	tst.w	(a0,d6.w)
	bmi.w	.2
	cmp.b	1(a0,d6.w),d0
	bgt.w	.1
	subq.b	#1,1(a0,d6.w)
.1
	addq.w	#2,d6
	cmp.w	#8,d6
	blt.s	.0
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

MoveTradedPlayer	;IDA: sub_9684A. 95 only. Insert traded player TempWord1 of team TradeFromTeam into team TradeToTeam: roster, player stats (ReadTeamPlayerStats / WriteTeamPlayerStats), saved lines and line slots
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a2,-(sp)
	bset	#7,(GameFlags).w
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	move.w	(TradeFromTeam).w,d7
	movem.w	d0/d7,-(sp)
	jsr	(GetRosterId).l
	move.w	d0,(a2)+
	movem.w	(sp)+,d0/d7
	jsr	(GetJerseyNumber).l
	move.w	(CreatedPlayerBuf).w,(a2)+
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ThreeStars,a0
	move.w	d7,d0
	asl.w	#5,d0
	ext.l	d0
	addi.l	#$5700,d0
	moveq	#$20,d1
	movem.l	d0-d1/a0,-(sp)
	jsr	(ReadSRAM).l
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	move.w	#$19,d1
	sub.w	d0,d1
	beq.w	.1
.0
	move.b	1(a0,d0.w),d2
	move.b	d2,(a0,d0.w)
	addq.w	#1,d0
	dbf	d1,.0
.1
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	movea.l	#ThreeStars,a0
	jsr	(ReadTeamRoster).l
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	move.w	#$32,d3
.2
	move.w	2(a0,d0.w),d1
	move.w	d1,(a0,d0.w)
	addq.w	#2,d0
	cmp.w	d3,d0
	blt.s	.2
	move.w	#$8000,(a0,d0.w)
	move.w	(TempWord1).w,d0
	lsr.w	#8,d0
	add.w	d0,d0
	movea.l	#TradeStatOffsets,a3
	move.w	(a3,d0.w),d0
	subq.b	#1,(a0,d0.w)
	jsr	(WriteTeamRoster).l
	cmp.w	#$19,d7
	bgt.w	.6
	jsr	(ReadTeamPlayerStats).l
	movea.l	#ThreeStars,a3
	move.w	#4,d6
.3
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d3
	move.w	d3,(a2)+
	move.w	#$32,d3
.4
	move.w	2(a3,d0.w),d1
	move.w	d1,(a3,d0.w)
	addq.w	#2,d0
	cmp.w	d3,d0
	blt.s	.4
	clr.w	(a3,d0.w)
	adda.w	#$34,a3
	dbf	d6,.3
	jsr	(WriteTeamPlayerStats).l
	move.w	#3,d6
.5
	bsr.w	FixSavedLine
	dbf	d6,.5
.6
	movea.l	(sp)+,a2
	move.w	(TempWord1).w,d1
	andi.w	#$FF,d1
	move.w	(TradeFromTeam).w,d7
	jsr	(GetInjuryGames).l
	adda.l	#$E,a2
	move.w	d0,(a2)
	clr.w	d0
	jsr	(SetInjuryGames).l
	jsr	(DeleteInjurySlot).l
	bclr	#7,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

TradeStatOffsets	;IDA: unk_969AA. 95 only. Roster count bytes per position ($34 goalies, $36 defense, $35 forwards)
	dc.w	$34,$36,$35

FixSavedLine	;IDA: sub_969B0. 95 only. Fix saved line block d6 (TeamRecordSRAM) of team TradeFromTeam after an added player
	movea.l	#TeamRecordSRAM,a0
	move.w	d6,d2
	asl.w	#3,d2
	move.l	(a0,d2.w),d0
	move.l	4(a0,d2.w),d1
	move.w	(TradeFromTeam).w,d2
	mulu.w	d1,d2
	add.l	d2,d0
	movea.l	#ThreeStars,a0
	jsr	(ReadSRAM).l
	cmpi.b	#$64,-1(a0,d1.w)
	bne.w	.3
	movem.l	d0-d1/a0,-(sp)
	subq.w	#2,d1
	move.w	(TempWord1).w,d3
	andi.w	#$FF,d3
	addq.w	#1,d3
.0
	cmp.b	(a0,d1.w),d3
	bgt.w	.2
	beq.w	.1
	cmpi.b	#1,(a0,d1.w)
	ble.w	.2
	subq.b	#1,(a0,d1.w)
	bra.w	.2
.1
	cmp.b	#1,d3
	beq.w	.2
	cmp.b	#2,d3
	beq.w	.2
	move.b	#$FF,(a0,d1.w)
.2
	dbf	d1,.0
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
.3
	rts

TeamRecordSRAM	;IDA: unk_96A34. 95 only. Save RAM blocks of the saved team lines (offset, size a team)
	dc.l	$3E14,$41
	dc.l	$4530,$39
	dc.l	$4B6C,$39
	dc.l	$5136,$39

RemoveTradedPlayer	;IDA: sub_96A54. 95 only. Remove the traded player from his old team: roster, stats, saved lines and line slots
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a2,-(sp)
	bset	#7,(GameFlags).w
	move.w	(TradeToTeam).w,d7
	move.w	(TempWord2).w,d0
	andi.w	#$FF,d0
	movea.l	#ThreeStars,a0
	jsr	(ReadTeamRoster).l
	add.w	d0,d0
	move.w	#$34,d3
	bra.w	.1
.0
	move.w	-2(a0,d3.w),d1
	move.w	d1,(a0,d3.w)
.1
	subq.w	#2,d3
	cmp.w	d0,d3
	ble.w	.2
	bra.s	.0
.2
	move.w	(a2)+,(a0,d0.w)
	move.w	(a2)+,(CreatedPlayerBuf).w
	move.w	(TempWord2).w,d0
	lsr.w	#8,d0
	add.w	d0,d0
	movea.l	#TradeStatOffsets2,a3
	move.w	(a3,d0.w),d0
	addq.b	#1,(a0,d0.w)
	jsr	(WriteTeamRoster).l
	cmp.w	#$19,d7
	bgt.w	.10
	jsr	(ReadTeamPlayerStats).l
	movea.l	#ThreeStars,a3
	move.w	#4,d6
.3
	move.w	(TempWord2).w,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	move.w	#$34,d3
	bra.w	.5
.4
	move.w	-2(a3,d3.w),d1
	move.w	d1,(a3,d3.w)
.5
	subq.w	#2,d3
	cmp.w	d0,d3
	ble.w	.6
	bra.s	.4
.6
	move.w	(a2)+,d1
	move.w	d1,(a3,d3.w)
	adda.w	#$34,a3
	dbf	d6,.3
	jsr	(WriteTeamPlayerStats).l
	move.w	#3,d6
.7
	bsr.w	FixSavedLine2
	dbf	d6,.7
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ThreeStars,a0
	move.w	(TradeToTeam).w,d7
	move.w	d7,d0
	asl.w	#5,d0
	ext.l	d0
	addi.l	#$5700,d0
	moveq	#$20,d1
	movem.l	d0-d1/a0,-(sp)
	jsr	(ReadSRAM).l
	move.w	(TempWord2).w,d0
	andi.w	#$FF,d0
	move.w	#$19,d1
.8
	cmp.w	d0,d1
	beq.w	.9
	move.b	-1(a0,d1.w),d2
	move.b	d2,(a0,d1.w)
	dbf	d1,.8
.9
	move.b	(jerseynum).w,(a0,d1.w)
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	(TempWord2).w,d0
	andi.w	#$FF,d0
	move.w	(TradeToTeam).w,d7
	jsr	(MoveSavedLines).l
.10
	move.w	(TempWord2).w,d1
	andi.w	#$FF,d1
	move.w	(TradeToTeam).w,d7
	jsr	(InsertInjurySlot).l
	movea.l	(sp)+,a2
	adda.l	#$E,a2
	move.w	(a2),d0
	jsr	(SetInjuryGames).l
	bclr	#7,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

TradeStatOffsets2	;IDA: unk_96BB2. 95 only. As TradeStatOffsets, for RemoveTradedPlayer
	dc.w	$34,$36,$35

FixSavedLine2	;IDA: sub_96BB8. 95 only. Fix saved line block d6 of team TradeToTeam after a removed player
	movea.l	#TeamRecordSRAM,a0
	move.w	d6,d2
	asl.w	#3,d2
	move.l	(a0,d2.w),d0
	move.l	4(a0,d2.w),d1
	move.w	(TradeToTeam).w,d2
	mulu.w	d1,d2
	add.l	d2,d0
	movea.l	#ThreeStars,a0
	jsr	(ReadSRAM).l
	cmpi.b	#$64,-1(a0,d1.w)
	bne.w	.2
	movem.l	d0-d1/a0,-(sp)
	subq.w	#2,d1
	move.w	(TempWord2).w,d3
	andi.w	#$FF,d3
	addq.w	#1,d3
.0
	cmp.b	(a0,d1.w),d3
	bgt.w	.1
	addq.b	#1,(a0,d1.w)
.1
	dbf	d1,.0
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
.2
	rts

TradePlayers	;IDA: loc_96C14. 95 only. Trade Player screen (main flow): the two rosters with position / rating, A cancel, B modify, C team, start evaluates the trade (CheckTrade, EvaluateTrade)
	jsr	(forceblack).l
	bsr.w	TradeGfx
	jsr	(printbigz).l
	String	$BF,$9,$2,'Trade Player',$0
	clr.w	(TradeData+$4).l
	clr.w	(TradeData+$8).l
	move.w	#5,(TradeData+$6).l
	move.w	#5,(TradeData+$A).l
	clr.w	(TradeData+$C).l
	clr.w	(TradeData).l
	clr.w	(TradeData+$2).l
	jsr	(clearTeamStats).l
	move.w	(HomeTeam).w,d7
	movea.l	#TradeRoster1,a0
	movea.l	#TradeWork,a1
	btst	#3,(sflags10).w
	bne.w	.0
	bsr.w	DrawTradeTeam
	bsr.w	rtsTrade
.0
	movea.l	#TradeRoster2,a0
.1
	movea.l	#TradeWork+$6,a1
	move.w	(VisTeam).w,d7
	bclr	#3,(sflags10).w
	bne.w	.2
	bsr.w	DrawTradeTeam
	bsr.w	rtsTrade
.2
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	jsr	(printz).l
	String	$BF,$0,$0,$0
	bsr.w	DrawTradeRoster1
	bsr.w	DrawTradeRoster2
	move.w	#$FFFF,(setupdir).w
.3
	move.w	(HomeTeam).w,d1
	jsr	(printz).l
	String	$BF,$8,$6,$0
	bsr.w	DrawTradeLogo
	move.w	(VisTeam).w,d1
	jsr	(printz).l
	String	$BF,$8,$10,$0
	bsr.w	DrawTradeLogo
	jsr	(printz2).l
	String	$F9,$2,$FD,$15,$FC,$7,'POSITION',$FD,$1F,'RATING'
	jsr	(printz2).l
	String	$F9,$2,$FD,$15,$FC,$11,'POSITION',$FD,$1F,'RATING'
	jsr	(printz2).l
	dc.w	$16;String length
	dc.b	$F9,$1,$FD,$4,$FC,$19,'A',$FD
	dc.b	$C,'B',$FD,$16,'C',$FD,$1F,'Start'
	jsr	(printz2).l
	dc.w	$26;String length
	dc.b	$FD,$2,$FC,$1A,'Team',$FD,$A,'Cancel'
	dc.b	$FD,$14,'Player',$FD,$1E,'Evaluate',$F9,$0
.4
	cmpi.w	#$FFFF,(setupdir).w
	beq.w	.5
	bsr.w	DrawTradeRoster1
	bsr.w	DrawTradeRoster2
.5
	move.w	#$FFFF,(setupdir).w
	bsr.w	ReadTradePads
	tst.w	d1
	beq.w	TradeExit
	move.w	#$FFFF,(setupdir).w
	btst	#7,d1
	bne.w	.21
	btst	#5,d1
	bne.w	.19
	btst	#6,d1
	bne.w	.18
	btst	#0,d1
	bne.w	.14
	btst	#1,d1
.6
	bne.w	.9
.7
	btst	#4,d1
	beq.s	.4
.8
	bra.w	TradeExit
.9
	movea.l	#TradeData+$4,a0
	movea.l	#TradeData+$6,a1
.10
	movea.l	#TradeData,a2
	move.w	(TradeWork+$4).l,d3
	tst.w	(TradeData+$C).l
	beq.w	.11
	movea.l	#TradeData+$8,a0
	movea.l	#TradeData+$A,a1
	movea.l	#TradeData+$2,a2
	move.w	(TradeWork+$A).l,d3
.11
	subq.w	#1,d3
	cmpi.w	#5,(a2)
	blt.w	.12
	cmp.w	(a1),d3
	beq.w	.4
	addq.w	#1,(a0)
	addq.w	#1,(a1)
	bra.w	.13
.12
	addq.w	#1,(a2)
.13
	move.w	#1,(setupdir).w
	bra.w	.4
.14
	movea.l	#TradeData+$4,a0
	movea.l	#TradeData+$6,a1
	movea.l	#TradeData,a2
	tst.w	(TradeData+$C).l
	beq.w	.15
	movea.l	#TradeData+$8,a0
	movea.l	#TradeData+$A,a1
	movea.l	#TradeData+$2,a2
.15
	tst.w	(a2)
	bne.w	.16
	tst.w	(a0)
	beq.w	.4
	subq.w	#1,(a0)
	subq.w	#1,(a1)
	bra.w	.17
.16
	subq.w	#1,(a2)
.17
	move.w	#0,(setupdir).w
	bra.w	.4
.18
	move.w	#6,(setupdir).w
	eori.w	#1,(TradeData+$C).l
	bra.w	.4
.19
	move.w	#5,(setupdir).w
	move.w	(TradeData).l,d0
	add.w	(TradeData+$4).l,d0
	movea.l	#TradeRoster1,a0
	tst.w	(TradeData+$C).l
	beq.w	.20
	move.w	(TradeData+$2).l,d0
	add.w	(TradeData+$8).l,d0
	movea.l	#TradeRoster2,a0
.20
	asl.w	#2,d0
	eori.b	#1,(a0,d0.w)
	bra.w	.4
.21
	bsr.w	CheckTrade
	bne.w	TradeDone
	move.w	#7,(setupdir).w
	bra.w	.3

DrawTradeRoster1	;IDA: sub_96EEA. 95 only. Draw the roster of HomeTeam with the chosen marks; falls into DrawTradeRosterRows
	move.w	(TradeData).l,d5
	tst.w	(TradeData+$C).l
	beq.w	.0
	move.w	#$FFFF,d5
.0
	movea.l	#TradeData+$4,a5
	movea.l	#TradeRoster1,a4
	move.w	#9,(printy).w
	move.w	(HomeTeam).w,d7
	bra.w	DrawTradeRosterRows

DrawTradeRoster2	;IDA: sub_96F18. 95 only. Draw the roster of VisTeam with the chosen marks
	move.w	(TradeData+$2).l,d5
	tst.w	(TradeData+$C).l
	bne.w	.0
	move.w	#$FFFF,d5
.0
	movea.l	#TradeData+$8,a5
	movea.l	#TradeRoster2,a4
	move.w	#$13,(printy).w
	move.w	(VisTeam).w,d7

DrawTradeRosterRows	;IDA: loc_96F42. 95 only. Draw the roster rows of team d7 (name, position, rating), * for the chosen players
	move.w	(printy).w,-(sp)
	jsr	(printz).l
	String	$BF,$0,$0,$0
	move.w	(sp)+,(printy).w
	clr.w	d6
	move.w	(a5),d0
	asl.w	#2,d0
	ext.l	d0
	adda.l	d0,a4
.0
	jsr	(printz2).l
	String	$FD,$0,'                                       ',$0
	move.w	#6,(printx).w
	jsr	(printz2).l
	String	$F9,$0
	cmp.w	d5,d6
	bne.w	.1
	jsr	(printz2).l
	String	$F9,$1
.1
	tst.b	(a4)
	beq.w	.2
	jsr	(printz2).l
	String	'*',$0
.2
	move.w	#8,(printx).w
	clr.w	d0
	move.b	2(a4),d0
	jsr	(FormatPlayerNameD7).l
	jsr	(printsmall).l
	move.w	#$18,(printx).w
	movea.l	#PositionLetters,a1
	clr.w	d0
	move.b	1(a4),d0
	jsr	(PrintSmallListItem).l
	move.w	#$21,(printx).w
	clr.w	d0
	move.b	3(a4),d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	addq.l	#4,a4
	addq.w	#1,(printy).w
	addq.w	#1,d6
	cmp.w	#6,d6
	blt.w	.0
	rts

PositionLetters	;IDA: unk_97020. 95 only. G, F, D
	String	'G',$0
	String	'F',$0
	String	'D',$0

ReadTradePads	;IDA: sub_9702C. 95 only. Wait up to $5460 frames for a pad 1 / 2 press (ProcessInputWithRepeat), d1 = buttons
	move.l	#$5460,d6
.0
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.0
	move.w	(vcount).w,(oldvcount).w
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	bra.w	.3
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.3
.2
	dbf	d6,.0
.3
	rts

TradeDone	;IDA: loc_97074. 95 only. After a trade: rebuild both teams' trade lists (BuildTradeList) and go to EvaluateTrade
	jsr	(forceblack).l
	movea.l	#tradeteam1,a1
	movea.l	#TradeRoster1,a2
	move.w	(HomeTeam).w,d7
	move.w	(TradeWork+$4).l,d6
	bsr.w	BuildTradeList
	movea.l	#tradeteam2,a1
	movea.l	#TradeRoster2,a2
	move.w	(VisTeam).w,d7
	move.w	(TradeWork+$A).l,d6
	bsr.w	BuildTradeList
	jmp	EvaluateTrade

TradeExit	;IDA: loc_970B4. 95 only. Leave the trade screen: set byte $FFD036 bit 6 and go to Opening2
	bset	#6,(setupcardflags).w
	jmp	Opening2

CheckTrade	;IDA: sub_970C0. 95 only. Check the trade: players chosen on both teams, at most three a team, and after it each team has 17-25 players, 2-3 goalies, 9-15 forwards and 6-15 defensemen; else INVALID TRADE with the reason (InvalidTradeText). d0 = 1 valid
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#StatWork,a0
	movea.l	#TradeRoster1,a1
	move.w	(TradeWork+$4).l,d0
	bsr.w	CountChosen
	movea.l	#StatWork+$A,a0
	movea.l	#TradeRoster2,a1
	move.w	(TradeWork+$A).l,d0
	bsr.w	CountChosen
	clr.w	d0
	move.w	#5,d1
	movea.l	#StatWork,a0
.0
	add.w	(a0)+,d0
	dbf	d1,.0
	tst.w	d0
	bne.w	.3
	move.w	#0,(StatWork+$14).w
	bra.w	.7
.1
	move.w	#2,(StatWork+$14).w
	bra.w	.7
.2
	move.w	#3,(StatWork+$14).w
	bra.w	.7
.3
	move.w	(StatWork).w,d0
	add.w	(StatWork+2).w,d0
	add.w	(SeasonGameCount).w,d0
	cmp.w	#3,d0
	bgt.s	.2
	move.w	(StatWork+$A).w,d0
	add.w	(StatWork+$C).w,d0
	add.w	(StatWork+$E).w,d0
	cmp.w	#3,d0
	bgt.s	.2
	move.w	(StatWork).w,d0
	add.w	(StatWork+2).w,d0
	add.w	(SeasonGameCount).w,d0
	beq.s	.1
	move.w	(StatWork+$A).w,d0
	add.w	(StatWork+$C).w,d0
	add.w	(StatWork+$E).w,d0
	beq.s	.1
	move.w	(TradeWork+$4).l,d0
	sub.w	(StatWork).w,d0
	sub.w	(StatWork+2).w,d0
	sub.w	(SeasonGameCount).w,d0
	add.w	(StatWork+$A).w,d0
	add.w	(StatWork+$C).w,d0
	add.w	(StatWork+$E).w,d0
	cmp.w	#$19,d0
	ble.w	.5
.4
	move.w	#1,(StatWork+$14).w
	bra.w	.7
.5
	cmp.w	#$11,d0
	bge.w	.6
	bra.s	.4
.6
	move.w	(TradeWork).l,d0
	sub.w	(StatWork).w,d0
	add.w	(StatWork+$A).w,d0
	cmp.w	#2,d0
	blt.s	.4
	cmp.w	#3,d0
	bgt.s	.4
	move.w	(TradeWork+$6).l,d0
	sub.w	(StatWork+$A).w,d0
	add.w	(StatWork).w,d0
	cmp.w	#2,d0
	blt.s	.4
	cmp.w	#3,d0
	bgt.s	.4
	move.w	(TradeWork+$2).l,d0
	sub.w	(TradeWork).l,d0
	sub.w	(StatWork+2).w,d0
	add.w	(StatWork+$C).w,d0
	cmp.w	#9,d0
	blt.s	.4
	cmp.w	#$F,d0
	bgt.s	.4
	move.w	(TradeWork+$8).l,d0
	sub.w	(TradeWork+$6).l,d0
	sub.w	(StatWork+$C).w,d0
	add.w	(StatWork+2).w,d0
	cmp.w	#9,d0
	blt.w	.4
	cmp.w	#$F,d0
	bgt.w	.4
	move.w	(TradeWork+$4).l,d0
	sub.w	(TradeWork+$2).l,d0
	sub.w	(SeasonGameCount).w,d0
	add.w	(StatWork+$E).w,d0
	cmp.w	#6,d0
	blt.w	.4
	cmp.w	#$F,d0
	bgt.w	.4
	move.w	(TradeWork+$A).l,d0
	sub.w	(TradeWork+$8).l,d0
	sub.w	(StatWork+$E).w,d0
	add.w	(SeasonGameCount).w,d0
	cmp.w	#6,d0
	blt.w	.4
	cmp.w	#$F,d0
	bgt.w	.4
	bra.w	.8
.7
	jsr	(printz).l
	String	$BF,$5,$A,$0
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(Framer).l
	jsr	(printz2).l
	String	$F9,$3,$FD,$D,$FC,$B,'INVALID  TRADE'
	move.w	(StatWork+$14).w,d0
	movea.l	#InvalidTradeText,a1
	jsr	(PrintSmallListItem).l
	bsr.w	ReadTradePads
	move.w	#$7FF,d2
	jsr	(printz).l
	String	$BF,$5,$A,$0
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(eraser).l
	bra.w	.9
.8
	move.w	#1,d0
	bra.w	.10
.9
	clr.w	d0
.10
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CountChosen	;IDA: sub_972E0. 95 only. Count the chosen players of a trade list by position into the three words at a0
	clr.w	(a0)
	clr.w	2(a0)
	clr.w	4(a0)
	subq.w	#1,d0
.0
	tst.b	(a1)
	beq.w	.3
	tst.b	1(a1)
	beq.w	.2
	cmpi.b	#1,1(a1)
	beq.w	.1
	addq.w	#1,4(a0)
	bra.w	.3
.1
	addq.w	#1,2(a0)
	bra.w	.3
.2
	addq.w	#1,(a0)
.3
	tst.l	(a1)+
	dbf	d0,.0
	rts

InvalidTradeText	;IDA: unk_9731E. 95 only. INVALID TRADE reasons (PrintSmallListItem)
	String	$FD,$6,$FC,$D,'* No players chosen.'

TradeRulesText	;IDA: unk_97338. 95 only. The roster rules text
	dc.w	$7A;String length
	dc.b	$FD,$6,$FC,$D,'All teams must have:',$FA,$1,$FD
	dc.b	$6,'* 17 to 25 players.',$FA,$1,$FD,$6,'*  2 to  3 goalies.',$FA
	dc.b	$1,$FD,$6,'*  9 to 15 forwards.',$FA,$1,$FD,$6
	dc.b	'*  6 to 15 defensemen.'
	String	$FD,$6,$FC,$D,'* No players chosen on one',$FA,$1,$FD,$8,'team.',$0
	String	$FD,$6,$FC,$D,'* More than three players',$FA,$1,$FD,$8,'chosen on a team.'

BuildTradeList	;IDA: sub_97410. 95 only. Trade list of team d7: the chosen players ($FFFF = none)
	move.w	d7,(a1)+
	move.w	#$FFFF,(a1)
	move.w	#$FFFF,2(a1)
	move.w	#$FFFF,4(a1)
	subq.w	#1,d6
.0
	tst.b	(a2)
	beq.w	.1
	clr.w	d0
	move.b	2(a2),d0
	move.w	d0,(a1)+
.1
	tst.l	(a2)+
	dbf	d6,.0
	rts

TradeGfx	;IDA: sub_9743A. 95 only. Trade screen video set up and graphics
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
	dc.b	$0B,$23,$44,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$4C,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont3chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$47,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont4chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$BB,$23,$44,$67,$89,$AB,$CD,$EF
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	move.w	d4,(teamblocksmapptr).w
	movea.l	#Teamblocksmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	movea.l	#Framermap+8,a2
	move.l	#Framermap,(framermapptr).l
	move.w	d4,(framercset).w
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	#TradeBgMap,a0
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
	rts

DrawTradeLogo	;IDA: sub_9757C. 95 only. Draw the team block of team d1
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

DrawTradeTeam	;IDA: sub_975AC. 95 only. Set up the trade rosters of HomeTeam and VisTeam
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ReadAttributeNibbleD7).l
	move.w	d0,(a1)
	jsr	(GetDefenseStartD7).l
	move.w	d0,2(a1)
	jsr	(GetPlayerCountD7).l
	move.w	d0,4(a1)
	subq.w	#1,d0
	movea.l	a0,a2
	clr.w	d1
.0
	clr.l	(a2)
	move.b	d1,2(a2)
	move.w	#0,d3
	cmp.w	(a1),d1
	blt.w	.1
	move.w	#1,d3
	cmp.w	2(a1),d1
	blt.w	.1
	move.w	#2,d3
.1
	move.b	d3,1(a2)
	movem.l	d0-d1/d4,-(sp)
	move.l	a2,-(sp)
	clr.w	d0
	move.b	2(a2),d0
	move.w	d0,(screenarg).w
	movea.l	#HmShots,a2
	cmp.w	(HomeTeam).w,d7
	beq.w	.2
	movea.l	#AwShots,a2
.2
	move.l	(PAttribOverallMask).l,d4
	tst.w	d3
	bne.w	.3
	move.l	(GAttribOverallMask).l,d4
.3
	jsr	(CalcAttrib).l
	mulu.w	#$64,d0
	divu.w	d1,d0
	movem.l	d0,-(sp)
	move.w	(screenarg).w,d0
	jsr	(SeasonPlayerOut).l
	movem.l	(sp)+,d0
	beq.w	.4
	jsr	(ScaleAttrib).l
.4
	movea.l	(sp)+,a2
	move.b	d0,3(a2)
	movem.l	(sp)+,d0-d1/d4
	tst.l	(a2)+
	addq.w	#1,d1
	dbf	d0,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

rtsTrade	;IDA: nullsub_1. IDA nullsub_1. rts
	rts

EvaluateTrade	;IDA: loc_9766E. 95 only. Evaluate Trade screen: the chosen players of both teams; A cancel, B modify, C execute, start propose (GMDecision)
	jsr	(forceblack).l
	jsr	(GMDecision).l
	jsr	(printz2).l
	String	$F9,$1,$FD,$1,$FC,$19,'     A        B         C       Start',$0
	jsr	(printz2).l
	String	$F9,$1,$FD,$1,$FC,$1A,'   Cancel   Modify   Execute   Propose'
.0
	jsr	(printbigz).l
	String	$BF,$6,$2,'Evaluate Trade',$0
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	jsr	(printz).l
	String	$BF,$0,$0,$0
	jsr	(printz2).l
	String	$F9,$0,$FD,$F,$FC,$9
	movea.l	#TradeRoster1,a0
.1
	move.w	(TradeWork+$4).l,d3
.2
	move.w	(HomeTeam).w,d7
.3
	bsr.w	PrintTradeNames
	jsr	(printz2).l
	String	$F9,$0,$FD,$F,$FC,$13
.4
	movea.l	#TradeRoster2,a0
.5
	move.w	(TradeWork+$A).l,d3
	move.w	(VisTeam).w,d7
	bsr.w	PrintTradeNames
.6
	bsr.w	ReadTradePads2
	tst.w	d1
	beq.w	.9
	btst	#7,d1
.7
	bne.w	.12
	btst	#6,d1
	bne.w	.11
	btst	#4,d1
	bne.w	.10
	btst	#5,d1
	bne.w	.8
	bra.s	.6
.8
	jsr	(forceblack).l
	jsr	(ExecuteTrade).l
.9
	bset	#6,(setupcardflags).w
	jmp	Opening2
.10
	bset	#3,(sflags10).w
	jmp	TradePlayers
.11
	bra.s	.9
.12
	jmp	GMDecisionRetry

PrintTradeNames	;IDA: sub_977B0. 95 only. Print the chosen players of a trade list with their position (PositionLetters2)
	subq.w	#1,d3
.0
	tst.b	(a0)
	beq.w	.1
	move.w	#$F,(printx).w
	clr.w	d0
	move.b	2(a0),d0
	jsr	(FormatPlayerNameWithAttribD7).l
	jsr	(printsmall).l
	move.w	#$20,(printx).w
	movea.l	#PositionLetters2,a1
	clr.w	d0
	move.b	1(a0),d0
	jsr	(PrintSmallListItem).l
	move.w	#$23,(printx).w
	clr.w	d0
	move.b	3(a0),d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	addq.w	#1,(printy).w
.1
	tst.l	(a0)+
	dbf	d3,.0
	rts

PositionLetters2	;IDA: unk_97810. 95 only. G, F, D
	String	'G',$0
	String	'F',$0
	String	'D',$0

ReadTradePads2	;IDA: sub_9781C. 95 only. As ReadTradePads
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
	bra.w	.3
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.3
.2
	dbf	d6,.0
.3
	rts

GMDecision	;IDA: sub_97868. 95 only. GM DECISION: rate both sides of the trade (TradeValue) and show which team has the ADVANTAGE; B modify, start continue
	jsr	(TradeGfx).l
	jsr	(printz).l
	String	$FE,$E,$10,$0
	movea.l	#GMDecisionMap,a0
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
	move.w	d4,(TradeToTeam).w
	jsr	(printz).l
	String	$9E,$8,$8,$0
	movea.l	#TeamLogoBitmaps,a0
	move.w	(HomeTeam).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
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
	String	$8E,$8,$12,$0
	movea.l	#TeamLogoBitmaps,a0
	move.w	(VisTeam).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
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
	move.w	(HomeTeam).w,d1
	jsr	(printz).l
	String	$BF,$8,$6,$0
	bsr.w	DrawTradeLogo
	move.w	(VisTeam).w,d1
	jsr	(printz).l
	String	$BF,$8,$10,$0
	bsr.w	DrawTradeLogo
	rts

GMDecisionRetry	;IDA: loc_97966. 95 only. GMDecision: back to the trade screen (CreateScreenGfx, TradePlayers)
	bsr.w	CreateScreenGfx
	jsr	(printbigz).l
	String	$BF,$B,$2,'GM DECISION'
	jsr	(printz2).l
	String	$F9,$1,$FD,$8,$FC,$1A,'B=Modify',$FD,$12,'Start=Continue'
	jsr	(printz2).l
	String	$F9,$2,$FD,$12,$FC,$8,'FOR',$0
	move.w	(HomeTeam).w,d1
	jsr	(printz).l
	String	$BF,$4,$5,$0
	bsr.w	DrawTradeLogo
	move.w	(VisTeam).w,d1
	jsr	(printz).l
	String	$BF,$17,$5,$0
	bsr.w	DrawTradeLogo
	movea.l	#TradeRoster1,a0
	move.w	(TradeWork+$4).l,d3
	move.w	(HomeTeam).w,d7
	bsr.w	TradeValue
	move.w	d0,(TempWord1).w
.0
	movea.l	#TradeRoster2,a0
	move.w	(TradeWork+$A).l,d3
	move.w	(VisTeam).w,d7
	bsr.w	TradeValue
.1
	move.w	d0,(TempWord2).w
.2
	sub.w	(TempWord1).w,d0
	bpl.w	.3
	neg.w	d0
.3
	clr.w	(rosterteam).w
	cmp.w	#2,d0
	blt.w	.5
	st	(rosterteam).w
	move.w	(StatWork+$3C).w,d4
	jsr	(printz).l
	String	$FF,$0,$B,$0
	movea.l	#TradeAdvantageMap1,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$13,d2
	moveq	#7,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	move.w	(HomeTeam).w,d7
	move.w	(TempWord2).w,d0
	cmp.w	(TempWord1).w,d0
	bgt.w	.4
	move.w	(VisTeam).w,d7
.4
	jsr	(printz2).l
	String	$F9,$0,$FD,$9,$FC,$11,'ADVANTAGE',$FA,$1,$FD,$9,$0
	movea.l	#TeamList,a1
	asl.w	#2,d7
	movea.l	(a1,d7.w),a1
	adda.w	4(a1),a1
	jsr	(printsmall).l
	bra.w	.6
.5
	move.w	(StatWork+$3C).w,d4
	jsr	(printz).l
	String	$FF,$0,$B,$0
	movea.l	#TradeAdvantageMap2,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$13,d2
	moveq	#7,d3
	moveq	#0,d5
	jsr	(dobitmap).l
.6
	jsr	(printz2).l
	String	$F9,$0,$FD,$4,$FC,$8
	movea.l	#tradeteam1,a0
	bsr.w	PrintTradedPlayers
	jsr	(printz2).l
	String	$F9,$0,$FD,$17,$FC,$8
	movea.l	#tradeteam2,a0
	bsr.w	PrintTradedPlayers
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	jsr	(printz).l
	String	$BF,$0,$0,$0
.7
	bsr.w	ReadTradePads3
	tst.w	d1
	beq.w	.9
	btst	#7,d1
	bne.w	.8
	btst	#4,d1
	beq.s	.7
	bset	#3,(sflags10).w
	jmp	TradePlayers
.8
	tst.w	(rosterteam).w
	bmi.w	.9
	jsr	(forceblack).l
	jsr	(ExecuteTrade).l
.9
	bset	#6,(setupcardflags).w
	jmp	Opening2

PrintTradedPlayers	;IDA: sub_97B5C. 95 only. Print the players of a trade list (up to 3)
	move.w	(printx).w,-(sp)
	move.w	(a0)+,d7
	move.w	#2,d6
.0
	move.w	(a0)+,d0
	bmi.w	.1
	andi.w	#$FF,d0
	jsr	(FormatPlayerInitialD7).l
	jsr	(printsmall).l
	addq.w	#1,(printy).w
	move.w	(sp),(printx).w
	dbf	d6,.0
.1
	move.w	(sp)+,(printx).w
	rts

ReadTradePads3	;no IDA label. 95 only. Wait up to $5460 frames for a pad press (pads 3, 4 with FourWayPlay), d1 = buttons (no IDA label)
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

TradeValue	;IDA: sub_97C0E. 95 only. d0 = trade value of the d3 players at a0: each rating (byte 3) mapped through TradeRatingSteps / TradeRatingValues
	subq.w	#1,d3
	clr.w	d0
.0
	tst.b	(a0)
	beq.w	.3
	move.b	3(a0),d1
	movea.l	#TradeRatingSteps,a1
	movea.l	#TradeRatingValues,a2
	clr.w	d4
.1
	cmp.b	(a1,d4.w),d1
	blt.w	.2
	addq.w	#1,d4
	bra.s	.1
.2
	move.b	(a2,d4.w),d4
	ext.w	d4
	add.w	d4,d0
.3
	tst.l	(a0)+
	dbf	d3,.0
	rts

TradeRatingSteps	;IDA: unk_97C46. 95 only. Rating steps
	dc.b	$32,$3C,$46,$50,$5A,$60,$65

TradeRatingValues	;IDA: unk_97C4D. 95 only. Trade value of each rating step
	dc.b	1,3,4,6,8,$A,$C
