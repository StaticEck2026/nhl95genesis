;	NHL 95 season95. Retail $08DF5A-$0920DD (16772 bytes).
;	New in 95: season mode. SeasonMain runs the season from the main flow: SEASON SETUP, the SEASON OPTIONS menu (play games,
;	play until a day, standings, team schedule calendar, games today, stats and playoff screens), the simulation of the computer
;	games (SimDayGames, SimScore, SimGameStats and the goal weight tables at the end) and the save RAM records. Moved in at the
;	head: hockey94 demoread / HandleJoy1, and RandomSetupTeams (95 only; optsetup94 SetupDemo picks random teams). Each routine
;	comment names its 94 file or says 95 only. period95 follows at $0920DE.
;	IDA left DayToDate / DateToDay, the season menu actions and the calendar screen as dc.b; they and the tables are read from the
;	retail bytes. IDA hid printz / printz2 / printbigz Strings and DecompressGraphicsWithCallback remap bytes as instructions; they
;	are String / dc.b here. The four goal weight tables at the end IDA read as code.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

demoread	;IDA: sub_8DF5A. hockey94 demoread. Monitor the pads in demo mode (called every game loop): start on a pad pauses, any other button
	;ends the demo. 95 checks all four cont*team words and reads pads 3 and 4 when FourWayPlay is set
	tst.w	(cont1team).w
	bne.w	rtsdemo
	tst.w	(cont2team).w
	bne.w	rtsdemo
	tst.w	(cont3team).w
	bne.w	rtsdemo
	tst.w	(cont4team).w
	bne.w	rtsdemo
	jsr	(ReadJoy1).l
	btst	#7,d1
	beq.w	.0
	jmp	startpause1
.0
	bsr.w	HandleJoy1
	jsr	(ReadJoy2).l
	btst	#7,d1
	beq.w	.1
	jmp	startpause2
.1
	tst.w	(FourWayPlay).w
	beq.w	HandleJoy1
	jsr	(ReadJoy3).l
	btst	#7,d1
	beq.w	.2
	jmp	startpause3
.2
	bsr.w	HandleJoy1
	jsr	(ReadJoy4).l
	btst	#7,d1
	beq.w	HandleJoy1
	jmp	startpause4

HandleJoy1	;IDA: sub_8DFDA. hockey94 HandleJoy1. Any button on the pad just read (d1) ends the demo; 95 also sets demoflag and setuphome /
	;setupvis to $64 before ExitToOpening
	tst.w	d1
	beq.w	rtsdemo
	st	(demoflag).w
	move.w	#$64,(setuphome).w
	move.w	#$64,(setupvis).w
	jmp	ExitToOpening

rtsdemo	;IDA: locret_8DFF6. shared rts of demoread / HandleJoy1
	rts

RandomSetupTeams	;IDA: sub_8DFF8. 95 only (optsetup94 SetupDemo picks random teams). Step the two setup team values by a random 0-27 and copy them
	;to Opt1Team / Opt2Team, set OptUserRec, clear OptPlayMode and GameFlags bits 3, 4 (season), OptPen = random 0 / 1
	move.w	#$1C,d0
	jsr	(randomd0).l
	add.b	d0,(setupvalues+1).w
	cmpi.b	#$1C,(setupvalues+1).w
	blt.w	.0
	subi.b	#$1C,(setupvalues+1).w
.0
	move.b	(setupvalues+1).w,(Opt1Team+1).w
	move.w	#$1C,d0
	jsr	(randomd0).l
	add.b	d0,(setupvalues+2).w
	cmpi.b	#$1C,(setupvalues+2).w
	blt.w	.1
	subi.b	#$1C,(setupvalues+2).w
.1
	move.b	(setupvalues+2).w,(Opt2Team+1).w
	move.w	#1,(OptUserRec).w
	clr.w	(OptPlayMode).w
	bclr	#3,(GameFlags).w
	bclr	#4,(GameFlags).w
	clr.w	(OptPen).w
	move.w	#$64,d0
	jsr	(randomd0).l
	andi.w	#1,d0
	move.w	d0,(OptPen).w
	rts

SeasonMain	;IDA: sub_8E06E. 95 only. Season mode flow, called from the main flow when GameFlags bit 3 (season) is set: a new season
	;(GameFlags bit 4) runs SeasonSetup and clears the save data; then the season options menu, the day simulation, the
	;games today screen and the playoffs until a human game is picked (GameSetUp) or the season ends (StanleyCupScreen,
	;SeasonAwards, Opening2)
	btst	#3,(GameFlags).w
	beq.w	.13
	move.w	($20FDCC).l,d0
	tst.b	d0
	beq.w	.0
	clr.w	($20FDCC).l
	jsr	(MakeSRAMChecksum).l
	bra.w	.8
.0
	btst	#3,(GameFlags).w
	beq.w	.13
	btst	#4,(GameFlags).w
	beq.w	.1
	jsr	(SeasonSetup).l
	jsr	(ClearSeasonData).l
	clr.w	($20FDCC).l
	jsr	(MakeSRAMChecksum).l
	bsr.w	PickSeasonStartDay
.1
	tst.b	(AutoplayDay).w
	beq.w	.2
	move.b	(SeasonDay).w,d0
	andi.w	#$FF,d0
	move.b	(AutoplayDay).w,d1
	andi.w	#$FF,d1
	cmp.w	d1,d0
	blt.w	.4
	clr.b	(AutoplayDay).w
.2
	btst	#4,(SeasonFlags).w
	bne.w	.12
	jsr	(GamesToday).l
	btst	#3,(SeasonFlags).w
	beq.w	.3
	btst	#5,(SeasonFlags).w
	beq.w	.7
.3
	jsr	(SeasonOptions).l
	bsr.w	BuildSeasonTeamList
	st	(seasonteamsel).w
	bsr.w	NextSeasonTeam
	tst.w	(seasonteamsel).w
	bpl.w	.6
.4
	bsr.w	SimDayGames
	bsr.w	NextSeasonDay
	btst	#3,(SeasonFlags).w
	beq.w	.5
	btst	#5,(SeasonFlags).w
	bne.w	.5
	clr.w	(optbgchars+$40).w
	bset	#0,(sflags11).w
	bset	#5,(sflags12).w
	move.w	#$64,($20FDCC).l
	jsr	(MakeSRAMChecksum).l
	jsr	(SeasonOptions).l
	clr.w	($20FDCC).l
	jsr	(MakeSRAMChecksum).l
	bclr	#5,(sflags12).w
	bclr	#0,(sflags11).w
	bra.w	.8
.5
	btst	#3,(SeasonFlags).w
	bne.w	.7
	bra.w	.1
.6
	bset	#5,(GameFlags).w
	jmp	GameSetUp
.7
	btst	#4,(SeasonFlags).w
	bne.w	.10
	btst	#5,(SeasonFlags).w
	bne.w	.9
	bset	#0,(sflags11).w
	clr.w	(optbgchars+$40).w
	jsr	(GamesToday).l
	bclr	#0,(sflags11).w
	jsr	(StandingsScreen).l
.8
	jsr	(InitPlayoffs).l
	jsr	(WriteSeasonHeader).l
	jsr	(SetupPlayoffs).l
.9
	bra.w	.1
.10
	bset	#1,(sflags11).w
	btst	#1,(SimFlags).w
	bne.w	.11
	jsr	(GamesToday).l
.11
	bclr	#1,(sflags11).w
	btst	#0,(SimFlags).w
	beq.w	.12
	move.w	($20FDDC).l,(cupwinner).w
	andi.w	#$FF,(cupwinner).w
	jsr	(StanleyCupScreen).l
.12
	jsr	(SeasonAwards).l
	jmp	Opening2
.13
	rts

ReadSeasonHeader	;IDA: sub_8E228. 95 only. Read the 8 byte season header (SeasonStartDay ...) from save RAM $E22
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#8,d1
	move.l	#$E22,d0
	movea.l	#SeasonStartDay,a0
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WriteSeasonHeader	;IDA: sub_8E246. 95 only. Write the 8 byte season header to save RAM $E22 and update the checksum
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#8,d1
	move.l	#$E22,d0
	movea.l	#SeasonStartDay,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PickSeasonStartDay	;IDA: sub_8E26A. 95 only. SeasonDay = 0; with a random schedule (GameFlags bit 6) SeasonStartDay = a random schedule day that has
	;games, else 0. Then WriteSeasonHeader
	move.b	#0,(SeasonDay).w
	btst	#6,(GameFlags).w
	bne.w	.0
	move.b	#0,(SeasonStartDay).w
	bra.w	.1
.0
	clr.w	d0
	move.b	(SeasonSchedule).l,d0
	subq.w	#1,d0
	jsr	(randomd0).l
	move.b	d0,(SeasonStartDay).w
	movem.l	a0,-(sp)
	bsr.w	FindDayGames
	tst.b	(a0)
	movem.l	(sp)+,a0
	beq.s	.0
.1
	bsr.s	WriteSeasonHeader
	rts

BuildSeasonTeamList	;IDA: sub_8E2AC. 95 only. Build today's game list in SeasonTeams (day, count, then 5 bytes a game: home, away, home score, away
	;score, flags) from the schedule (or the playoff schedule) and the results in save RAM. Falls into ReadDayGames
	clr.w	d1
	move.b	(SeasonDay).w,d1
	clr.w	d2
	move.b	(SeasonStartDay).w,d2
	movea.l	#SeasonTeams,a2

ReadDayGames	;no IDA label. 95 only. d1 = day, d2 = start day, a2 = buffer: read the day's games and their saved results ($E2A + 3 bytes a game)
	movem.l	d0-d7/a0-a6,-(sp)
	move.b	d1,(a2)+
	btst	#0,(sflags11).w
	bne.w	.1
	btst	#1,(sflags11).w
	bne.w	.0
	btst	#3,(SeasonFlags).w
	beq.w	.1
.0
	jsr	(ReadPlayoffSchedule).l
	movea.l	#PlayoffSchedule+$1,a0
	bra.w	.2
.1
	movea.l	#SeasonSchedule,a0
	clr.w	d5
	move.b	(a0)+,d5
	add.w	d2,d1
	cmp.w	d5,d1
	blt.w	.2
	sub.w	d5,d1
.2
	move.l	#$E2A,d0
	bra.w	.4
.3
	clr.l	d3
	move.b	(a0)+,d3
	move.w	d3,d4
	add.w	d4,d4
	adda.w	d4,a0
	move.b	d3,-(sp)
	add.b	d3,d3
	add.b	(sp)+,d3
	add.l	d3,d0
.4
	dbf	d1,.3
	clr.w	d1
	move.b	(a0)+,d1
	move.b	d1,(a2)+
	bra.w	.6
.5
	move.b	(a0)+,(a2)
	move.b	(a0)+,1(a2)
	movem.l	d0-d7/a0-a7,-(sp)
	moveq	#3,d1
	lea	2(a2),a0
	jsr	(ReadSRAM).l
	eori.b	#1,4(a2)
	movem.l	(sp)+,d0-d7/a0-a7
	addq.l	#3,d0
	addq.w	#5,a2
.6
	dbf	d1,.5
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WriteDayGames	;IDA: sub_8E35E. 95 only. Write the results of the games in SeasonTeams back to save RAM
	clr.w	d2
	move.b	(SeasonStartDay).w,d2
	movea.l	#SeasonTeams,a2
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d1
	move.b	(a2)+,d1
	btst	#3,(SeasonFlags).w
	beq.w	.0
	jsr	(ReadPlayoffSchedule).l
	movea.l	#PlayoffSchedule+$1,a0
	bra.w	.1
.0
	movea.l	#SeasonSchedule,a0
	clr.w	d5
	move.b	(a0)+,d5
	add.w	d2,d1
	cmp.w	d5,d1
	blt.w	.1
	sub.w	d5,d1
.1
	move.l	#$E2A,d0
	bra.w	.3
.2
	clr.l	d3
	move.b	(a0)+,d3
	move.w	d3,d4
	add.w	d4,d4
	adda.w	d4,a0
	move.b	d3,-(sp)
	add.b	d3,d3
	add.b	(sp)+,d3
	add.l	d3,d0
.3
	dbf	d1,.2
	clr.w	d1
	move.b	(a2)+,d1
	bra.w	.5
.4
	movem.l	d0-d7/a0-a6,-(sp)
	moveq	#3,d1
	lea	2(a2),a0
	eori.b	#1,4(a2)
	jsr	(WriteSRAM).l
	eori.b	#1,4(a2)
	movem.l	(sp)+,d0-d7/a0-a6
	addq.l	#3,d0
	addq.w	#5,a2
.5
	dbf	d1,.4
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SkipToGameDay	;IDA: sub_8E3FC. 95 only. Step SeasonDay forward until a day with games
	movem.l	d0-d7/a0-a6,-(sp)
.0
	bsr.w	FindDayGames
	tst.b	(a0)
	bne.w	.1
	bsr.w	NextSeasonDay
	bra.s	.0
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DayHasGames	;IDA: sub_8E416. 95 only. ne when SeasonDay has games (FindDayGames)
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	FindDayGames
	tst.b	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

FindDayGames	;IDA: sub_8E426. 95 only. a0 = the schedule entry of SeasonDay (count byte, then 2 bytes a game); the playoffs read PlayoffSchedule
	movem.l	d0-d7/a1-a6,-(sp)
	btst	#3,(SeasonFlags).w
	beq.w	.2
	jsr	(ReadPlayoffSchedule).l
	movea.l	#PlayoffSchedule+$1,a0
	clr.w	d5
	move.b	(SeasonDay).w,d5
	bra.w	.1
.0
	clr.w	d4
	move.b	(a0)+,d4
	add.w	d4,d4
	adda.w	d4,a0
.1
	dbf	d5,.0
	bra.w	.6
.2
	clr.w	d4
	move.b	(SeasonStartDay).w,d4
	clr.w	d5
	move.b	(SeasonDay).w,d5
	add.w	d4,d5
	cmp.w	#$C0,d5
	blt.w	.3
	subi.w	#$C0,d5
.3
	movea.l	#SeasonSchedule+1,a0
	bra.w	.5
.4
	clr.w	d0
	move.b	(a0),d0
	add.w	d0,d0
	addq.w	#1,d0
	adda.w	d0,a0
.5
	dbf	d5,.4
.6
	movem.l	(sp)+,d0-d7/a1-a6
	rts

PrevSeasonDay	;IDA: sub_8E492. 95 only. SeasonDay - 1 (not below 0)
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d0
	move.b	(SeasonLength).w,d0
	clr.w	d1
	move.b	(SeasonDay).w,d1
	beq.w	.0
	subq.w	#1,d1
	move.b	d1,(SeasonDay).w
.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

NextSeasonDay	;IDA: sub_8E4B2. 95 only. SeasonDay + 1; at SeasonLength set SeasonFlags bit 3 (regular season over). In the playoffs advance the
	;playoff day and round (NextPlayoffRound), SeasonFlags bit 4 after the last round
	btst	#5,(SeasonFlags).w
	bne.w	.2
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d0
	move.b	(SeasonLength).w,d0
	clr.w	d1
	move.b	(SeasonDay).w,d1
	addq.w	#1,d1
	cmp.w	d0,d1
	blt.w	.0
	bset	#3,(SeasonFlags).w
	bra.w	.1
.0
	move.b	d1,(SeasonDay).w
.1
	bsr.w	WriteSeasonHeader
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.2
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#7,(GameFlags).w
	addq.b	#1,(SeasonDay).w
	move.l	($20C004).l,d0
	addq.b	#1,d0
	move.l	d0,($20C004).l
	jsr	(WriteSeasonHeader).l
	jsr	(PlayoffRoundDone).l
	bne.w	.4
	move.l	($20C000).l,d0
	cmp.b	#3,d0
	bge.w	.3
	addq.b	#1,d0
	move.l	d0,($20C000).l
	jsr	(NextPlayoffRound).l
	bra.w	.4
.3
	bset	#4,(SeasonFlags).w
	jsr	(WriteSeasonHeader).l
.4
	bclr	#7,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

NextSeasonTeam	;IDA: sub_8E556. 95 only. seasonteamsel = offset of the first unplayed human game in SeasonTeams after it, -1 none
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#SimWeights+$1B,a0
	clr.w	d0
	move.b	(a0)+,d0
	move.w	#2,d1
	bra.w	.2
.0
	btst	#0,4(a0)
	bne.w	.1
	btst	#1,4(a0)
	bne.w	.1
	cmp.w	(seasonteamsel).w,d1
	ble.w	.1
	move.w	d1,(seasonteamsel).w
	bra.w	.3
.1
	addq.w	#5,d1
	addq.w	#5,a0
.2
	dbf	d0,.0
	st	(seasonteamsel).w
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrevSeasonTeam	;IDA: sub_8E5A2. 95 only. seasonteamsel = offset of the last unplayed human game in SeasonTeams before it, -1 none
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#SimWeights+$1B,a0
	clr.w	d0
	move.b	(a0)+,d0
	move.w	d0,d6
	subq.w	#1,d6
	mulu.w	#5,d6
	addq.w	#2,d6
	move.w	d6,d1
	lea	-2(a0,d1.w),a0
	bra.w	.3
.0
	btst	#0,4(a0)
	bne.w	.2
	btst	#1,4(a0)
	bne.w	.2
	tst.w	(seasonteamsel).w
	bmi.w	.1
	cmp.w	(seasonteamsel).w,d1
	bge.w	.2
.1
	move.w	d1,(seasonteamsel).w
	bra.w	.4
.2
	subq.w	#5,d1
	subq.w	#5,a0
.3
	dbf	d0,.0
	st	(seasonteamsel).w
.4
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimDayGames	;IDA: sub_8E602. 95 only. Simulate every computer game of the day (flags bit 0 set, bit 1 clear): SimScore, mark it played,
	;RecordPlayoffGame, RecordGameResult, SimGameStats. Then WriteDayGames
	movem.l	d0-d7/a0-a6,-(sp)
	move	sr,-(sp)
	bset	#7,(GameFlags).w
	move	#$2300,sr
	bsr.w	BuildSeasonTeamList
	movea.l	#SeasonTeams,a0
	clr.w	d0
	move.b	1(a0),d0
	addq.w	#2,a0
	bra.w	.2
.0
	btst	#0,4(a0)
	beq.w	.1
	btst	#1,4(a0)
	bne.w	.1
	bclr	#0,(SimFlags).w
	bclr	#1,(SimFlags).w
	bsr.w	SimScore
	bset	#1,4(a0)
	jsr	(RecordPlayoffGame).l
	bsr.w	RecordGameResult
	move.w	#$4B0,(PerTimeTotal).w
	bsr.w	SimGameStats
.1
	addq.w	#5,a0
.2
	dbf	d0,.0
	bclr	#7,(GameFlags).w
	bsr.w	WriteDayGames
	move	(sp)+,sr
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimGameStats	;IDA: sub_8E67E. 95 only. Fill the team structs for a simulated game a0 (teams, scores, shots, scorers, goalies) and SaveSimGame
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(vcount).w,d0
	jsr	(randomd0).l
	movea.l	#HmShots,a1
	move.w	#$365,d0
.0
	clr.w	(a1)+
	dbf	d0,.0
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,(HomeTeam).w
	clr.w	d0
	move.b	1(a0),d0
	move.w	d0,(VisTeam).w
	movea.l	#HmShots,a1
	movea.l	#AwShots,a2
	move.w	(HomeTeam).w,$28(a1)
	move.w	(VisTeam).w,$28(a2)
	clr.w	d0
	move.b	2(a0),d0
	move.w	d0,$C(a1)
	move.w	d0,(rosterscroll).w
	move.w	(HomeTeam).w,d1
	bsr.w	SimShots
	move.w	d0,(a1)
	bsr.w	SimScorers
	clr.w	d0
	move.b	3(a0),d0
	move.w	d0,$C(a2)
	move.w	d0,(rosterscroll).w
	move.w	(VisTeam).w,d1
	bsr.w	SimShots
	move.w	d0,(a2)
	movea.l	a2,a1
	bsr.w	SimScorers
	bsr.w	SimGoalieStats
	tst.b	(SeasonPen).w
	beq.w	.3
	move.l	a0,-(sp)
	movea.l	#SimTeamTbl,a0
	move.w	(HomeTeam).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	move.w	#$258,d0
	jsr	(randomd0s).l
	add.w	d0,d1
	bpl.w	.1
	clr.w	d1
.1
	ext.l	d1
	divu.w	#$64,d1
	move.w	d1,(HmShots+8).w
	movea.l	#SimTeamTbl,a0
	move.w	(VisTeam).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	move.w	#$258,d0
	jsr	(randomd0s).l
	add.w	d0,d1
	bpl.w	.2
	clr.w	d1
.2
	ext.l	d1
	divu.w	#$64,d1
	move.w	d1,(AwShots+8).w
	movea.l	(sp)+,a0
.3
	bclr	#1,(SimFlags).w
	jsr	(SaveSimGame).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimTeamTbl	;IDA: unk_8E77A. 95 only. A word per team: SimGameStats adds random +-$258 and stores /100 at team struct +8
	dc.w	$73A,$6AE,$834,$8CA,$99C,$8DE,$85C,$8C0,$7A8,$898,$9A6,$712,$820
	dc.w	$866,$820,$7DA,$7BC,$758,$7B2,$654,$758,$708,$8AC,$910,$956,$A0A

SimGoalieStats	;IDA: sub_8E7AE. 95 only. SimGoalie for the home and the away team
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(HomeTeam).w,d7
	movea.l	#HmShots,a1
	movea.l	#AwShots,a2
	bsr.w	SimGoalie
	move.w	(VisTeam).w,d7
	movea.l	#AwShots,a1
	movea.l	#HmShots,a2
	bsr.w	SimGoalie
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimGoalie	;IDA: sub_8E7E0. 95 only. Credit the goalie (1/16 the backup): $E10 more time, the shots and goals against
	jsr	(ReadAttributeNibbleD7).l
	subq.w	#1,d0
	bsr.w	PickSimGoalie
	move.w	d0,d3
	add.w	d3,d3
	addi.w	#$138,d3
	addi.w	#$E10,(a1,d3.w)
	move.w	(a2),d4
	cmp.w	#$FF,d4
	ble.w	.0
	move.w	#$FF,d4
.0
	move.w	d0,d3
	addi.w	#$EA,d3
	move.b	d4,(a1,d3.w)
	move.w	$C(a2),d4
	move.w	d0,d3
	addi.w	#$B6,d3
	move.b	d4,(a1,d3.w)
	rts

PickSimGoalie	;IDA: sub_8E822. 95 only. d0 = 1 one time in 16, else 0
	movem.l	d1-d7,-(sp)
	clr.w	d1
	move.w	#$F,d0
	jsr	(randomd0).l
	bne.w	.0
	move.w	#1,d1
.0
	move.w	d1,d0
	movem.l	(sp)+,d1-d7
	rts

SimScorers	;IDA: sub_8E842. 95 only. Give each goal of team d1 to a skater picked from TeamScoringTbls, with SimAssists
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d1,d7
	jsr	(ReadAttributeNibbleD7).l
	move.w	d0,d2
	move.w	d0,(TempRawSpd).w
	jsr	(GetPlayerCountD7).l
	move.w	d0,d3
	move.w	d0,(TempMaxSpd).w
	move.w	d3,d0
	sub.w	d2,d0
	movea.l	#TeamScoringTbls,a2
	move.w	d1,d7
	asl.w	#2,d7
	movea.l	(a2,d7.w),a2
	clr.w	d7
	clr.w	d4
	move.w	d2,d5
	add.w	d5,d5
	bra.w	.1
.0
	clr.w	d6
	move.b	(a2,d5.w),d6
	add.w	d6,d7
	move.b	1(a2,d5.w),d6
	add.w	d6,d4
	addq.w	#2,d5
.1
	dbf	d0,.0
	move.w	d4,(rosterteam).w
	move.w	(rosterscroll).w,d1
	bra.w	.5
.2
	move.w	d7,d0
	subq.w	#1,d0
	jsr	(randomd0).l
	clr.w	d6
	move.w	d2,d5
	add.w	d5,d5
	move.w	d2,d3
.3
	clr.w	d4
	move.b	(a2,d5.w),d4
	add.w	d4,d6
	cmp.w	d0,d6
	bge.w	.4
	addq.w	#2,d5
	addq.w	#1,d3
	bra.s	.3
.4
	move.l	a1,-(sp)
	adda.w	#$B6,a1
	addq.b	#1,(a1,d3.w)
	movea.l	(sp)+,a1
	bsr.w	SimAssists
.5
	dbf	d1,.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimAssists	;IDA: sub_8E8DE. 95 only. Up to 2 assists for a goal (95% one, 75% two), PickAssist
	movem.l	d0-d7,-(sp)
	move.w	#$64,d0
	jsr	(randomd0).l
	cmp.w	#5,d0
	ble.w	.0
	move.w	d3,(TempLegSpd).w
	move.w	d3,(recwins).w
	move.w	d0,-(sp)
	bsr.w	PickAssist
	move.l	a1,-(sp)
	adda.w	#$D0,a1
	addq.b	#1,(a1,d0.w)
	movea.l	(sp)+,a1
	move.w	d0,(recwins).w
	move.w	(sp)+,d0
	cmp.w	#$19,d0
	ble.w	.0
	bsr.w	PickAssist
	move.l	a1,-(sp)
	adda.w	#$D0,a1
	addq.b	#1,(a1,d0.w)
	movea.l	(sp)+,a1
.0
	movem.l	(sp)+,d0-d7
	rts

PickAssist	;IDA: sub_8E932. 95 only. d0 = a skater picked from the assist weights, not the scorer or the first assist
	move.w	(rosterteam).w,d0
	subq.w	#1,d0
	jsr	(randomd0).l
	clr.w	d6
	move.w	(TempRawSpd).w,d5
	add.w	d5,d5
	move.w	(TempRawSpd).w,d3
.0
	clr.w	d4
	move.b	1(a2,d5.w),d4
	add.w	d4,d6
	cmp.w	d0,d6
	bge.w	.1
	addq.w	#2,d5
	addq.w	#1,d3
	bra.s	.0
.1
	cmp.w	(TempLegSpd).w,d0
	beq.s	PickAssist
	cmp.w	(recwins).w,d0
	beq.s	PickAssist
	move.w	d3,d0
	rts

TeamScoring0	;no IDA label
	dc.b	$14,$1E,3,5,$17,$1C,$F,$B,$B,$13,8,$19,$13,$12,$15,$1F
	dc.b	$C,$16,9,9,8,3,$D,6,$12,$1B,1,5,$10,$1B,$C,$B
	dc.b	5,$F,7,$14,9,$B,3,9,$E,$19,3,5,1,9

TeamScoring1	;no IDA label
	dc.b	$1E,$18,9,$B,$20,$50,8,$F,0,1,$1F,$14,7,3,$32,$18
	dc.b	5,$A,$A,$B,$12,$D,2,1,$D,$B,$C,7,$16,$20,6,$11
	dc.b	3,7,$14,$47,1,9,$F,$2B,6,$F,$E,$2C,1,6,1,8

TeamScoring2	;no IDA label
	dc.b	$D,$F,$1E,$1A,6,$F,5,$D,$23,$33,$B,$E,3,4,$16,$10
	dc.b	$1B,$1F,$12,$1B,8,8,6,7,$15,$23,$20,$2F,$11,8,$1D,$1E
	dc.b	2,4,2,$B,7,$20,4,$14,6,8,2,$C,2,$E,$E,$1B

TeamScoring3	;no IDA label
	dc.b	$1A,$16,$D,$D,$24,$27,$28,$35,$B,$C,$D,$2A,7,$17,$1B,$12
	dc.b	$29,$2B,3,8,$B,$1B,$28,$2D,5,5,9,$14,1,6,$A,$25
	dc.b	$A,$19,$1C,$36,1,$15,6,$F,1,8,2,$15,0,3,1,$B

TeamScoring4	;no IDA label
	dc.b	$25,$1E,2,$F,$2E,$3D,9,$14,9,$1D,3,$D,2,6,$E,$15
	dc.b	$10,$E,$D,$B,$E,$E,4,2,$F,$12,$11,$19,$C,$E,$1F,$27
	dc.b	4,$18,$10,$2C,5,$16,3,9,4,8,1,1,6,$C,1,7

TeamScoring5	;no IDA label
	dc.b	$18,$1B,$12,$F,$32,$2B,$20,$1D,$11,$23,2,5,$B,$21,$E,$18
	dc.b	3,$11,$11,$E,$14,$F,5,7,6,7,$D,$18,1,0,$17,$39
	dc.b	$C,$C,1,4,6,$12,$C,$13,1,$D,0,3,9,$25,$B,$21

TeamScoring6	;no IDA label
	dc.b	$17,$2D,$17,$D,$18,$3A,$38,$40,$1F,$2A,5,8,6,$B,$22,$27
	dc.b	$A,$C,7,$A,4,4,8,$15,$1C,$1D,$34,$29,9,$11,6,7
	dc.b	0,7,$E,$3F,$D,$21,1,6,$A,$2E,4,$14,$C,$15,1,4

TeamScoring7	;no IDA label
	dc.b	$16,$2D,3,$D,$18,$32,0,1,$21,$23,6,$15,4,7,$C,$D
	dc.b	$D,5,$19,$1D,4,6,$13,$12,$16,$23,$11,$F,3,5,$B,8
	dc.b	3,$12,8,$14,$C,$26,$B,$18,3,6,$B,$20,2,6,7,$18

TeamScoring8	;no IDA label
	dc.b	$15,$24,$C,$E,$F,$19,$17,$18,9,$11,$11,$21,$12,$E,6,$17
	dc.b	$F,$16,$13,$1C,6,6,3,5,$D,$D,$1E,$1E,$28,$1E,4,5
	dc.b	6,$18,1,8,4,7,$E,$1D,1,9,2,0,4,8,2,2

TeamScoring9	;no IDA label
	dc.b	$11,$1D,5,$C,5,$C,$10,$2A,2,$A,6,$C,4,$B,4,$F
	dc.b	$29,$1A,$C,$11,3,2,6,$A,$12,9,$A,$11,$25,$26,6,2
	dc.b	$18,$1A,4,$B,3,$13,1,$11,1,5,5,$10,5,$19,1,2

TeamScoring10	;no IDA label
	dc.b	$16,$26,4,$10,$26,$5C,9,$A,8,$E,1,3,$F,$D,$2C,$2A
	dc.b	$A,9,$15,$15,$1F,$2E,7,$E,$C,3,3,4,$E,$11,$14,$30
	dc.b	$C,$28,7,$18,8,$1B,5,$D,1,5,2,6,1,9

TeamScoring11	;no IDA label
	dc.b	$23,$1C,$C,$14,$17,$22,$13,$18,$E,$18,$D,$14,2,$A,$13,$1A
	dc.b	$28,$33,$A,$14,1,2,4,5,$10,$1E,$21,$26,$C,$F,6,8
	dc.b	$C,$17,$14,$20,2,$15,4,9,1,2,2,$C,$B,$1D,2,$C

TeamScoring12	;no IDA label
	dc.b	$14,$F,$1B,$13,$C,$11,$13,$1B,$14,$1E,$A,$17,5,$A,$1A,$1F
	dc.b	$D,$14,$C,$F,$15,$14,4,$10,$12,$1A,$19,$13,$25,$21,$24,$24
	dc.b	0,5,$12,$3C,1,$E,8,$18,$A,$24,1,9,2,$11,2,$F

TeamScoring13	;no IDA label
	dc.b	$1B,$20,8,$D,$26,$38,$15,$20,2,7,$12,$16,1,1,$24,$21
	dc.b	$19,$1F,$1E,$28,0,6,5,9,$2A,$21,$B,$13,$C,$1E,3,1
	dc.b	2,1,$A,$2F,1,$A,7,$E,9,$1F,3,$B,2,$B,1,4

TeamScoring14	;no IDA label
	dc.b	$2A,$12,$A,$E,$1A,$3A,$16,$1B,$14,$D,$17,$21,3,5,$34,$1B
	dc.b	3,5,$16,$20,4,$B,4,7,$15,$14,$13,$13,$15,$27,2,1
	dc.b	$12,$17,$17,$38,3,$F,$C,$4D,8,8,5,$E,0,2,2,7

TeamScoring15	;no IDA label
	dc.b	$B,$2D,0,2,$14,$1F,$1E,$31,2,4,$B,$F,$A,8,0,3
	dc.b	7,$10,2,5,2,4,$11,$1A,$B,8,7,$D,8,$B,2,3
	dc.b	2,5,0,2,3,$14,4,$13,6,9,4,$E,1,4,0,$15

TeamScoring16	;no IDA label
	dc.b	$1D,$19,6,$16,$2C,$35,$23,$3E,$C,$18,4,$B,$B,$C,$14,$12
	dc.b	$26,$2C,$1C,$15,8,5,$28,$43,$13,$17,1,4,4,3,$A,$3C
	dc.b	5,$19,1,5,9,$2B,0,7,1,8,1,3,0,2,1,3

TeamScoring17	;no IDA label
	dc.b	$16,$14,$15,$13,$11,$14,$1B,$42,$14,$16,4,$B,$29,$2F,$26,$20
	dc.b	$1E,$22,3,5,$12,$25,$E,$1A,$20,$43,$17,$23,4,7,0,0
	dc.b	5,8,5,$18,$11,$38,2,$C,2,2,3,8,6,$1C,2,4

TeamScoring18	;no IDA label
	dc.b	$14,$1D,8,$10,$1C,$40,$1E,$15,$20,$35,$F,$19,$B,$11,9,$17
	dc.b	$1C,$25,4,4,0,4,$11,$14,6,8,$D,$F,2,2,$10,$11
	dc.b	$1A,$19,4,$F,5,$11,5,$14,0,$B,5,$C,4,$D,1,$B

TeamScoring19	;no IDA label
	dc.b	$1E,$2C,3,7,$12,$26,$19,$29,$C,5,3,6,$C,$B,$C,$12
	dc.b	$C,$12,$12,$23,$E,$1A,$D,8,$F,$14,$19,$2C,$16,$1F,$1E,$26
	dc.b	7,$21,1,3,$1A,$26,6,$13,0,2,1,9,1,6

TeamScoring20	;no IDA label
	dc.b	$24,$22,4,$A,$10,$44,5,$B,6,$E,6,$E,1,2,$34,$32
	dc.b	$F,$A,2,3,$39,$28,$17,$19,9,$10,9,$C,6,$A,2,5
	dc.b	1,0,7,$F,2,7,5,9,2,8,$C,$13,1,7,4,$14

TeamScoring21	;no IDA label
	dc.b	2,4,$16,$27,$D,$1D,$18,$28,$12,$1C,8,7,4,9,$14,$17
	dc.b	$A,$A,$D,$C,6,6,$D,$F,$11,$17,$1C,$1B,1,2,$B,$14
	dc.b	3,$12,$B,$17,1,$F,3,6,1,2,0,0

TeamScoring22	;no IDA label
	dc.b	$22,$1F,9,$A,8,$A,$1B,$54,$D,$11,5,6,8,8,4,4
	dc.b	$2E,$1E,$35,$2D,8,$B,7,9,9,$10,$E,$15,$22,$1E,$C,$12
	dc.b	4,$17,7,$24,9,$1B,2,8,3,$1B,5,$B,2,9,0,1

TeamScoring23	;no IDA label
	dc.b	$17,$1D,$12,$E,$19,$2B,$B,$11,$F,$28,3,6,$1A,$2C,$10,$D
	dc.b	$D,$18,1,2,$E,$D,3,4,$3C,$2F,$20,$1D,$E,$E,7,7
	dc.b	0,$C,$D,$2A,$E,$34,1,9,5,$21,4,$1C,6,$E,1,$A

TeamScoring25	;no IDA label
	dc.b	$15,$13,0,$A,$1A,$2D,$13,$20,$D,$1B,4,8,7,7,$29,$28
	dc.b	4,8,4,8,$15,$25,6,2,$19,$1D,5,$D,$21,$29,8,$B
	dc.b	3,$D,0,4,5,$12,8,$12,0,7,0,$11,4,$11,2,8

TeamScoring24	;no IDA label
	dc.b	$18,$18,$D,$10,2,2,$1A,$2C,$13,$42,9,$1D,$E,$24,6,$13
	dc.b	$E,$19,$1D,$1D,7,7,$19,$11,$18,$13,$C,$E,$C,$12,$10,$13
	dc.b	$B,$12,$10,$18,1,$10,$10,$23,9,$21,0,7,0,9,7,9

TeamScoringTbls	;IDA: unk_8EE44. 95 only. Per team: the goal / assist weights (2 bytes a player) used by SimScorers
	dc.l	TeamScoring0,TeamScoring1,TeamScoring2,TeamScoring3
	dc.l	TeamScoring4,TeamScoring5,TeamScoring6,TeamScoring7
	dc.l	TeamScoring8,TeamScoring9,TeamScoring10,TeamScoring11
	dc.l	TeamScoring12,TeamScoring13,TeamScoring14,TeamScoring15
	dc.l	TeamScoring16,TeamScoring17,TeamScoring18,TeamScoring19
	dc.l	TeamScoring20,TeamScoring21,TeamScoring22,TeamScoring23
	dc.l	TeamScoring24,TeamScoring25

SimShots	;IDA: sub_8EEAC. 95 only. d0 = d0 + 7 + a random pick from SimShotsTbl (46 weights)
	movem.l	d1-d7/a0-a6,-(sp)
	move.w	d0,-(sp)
	move.w	#$2D,d0
	movea.l	#SimShotsTbl,a1
	clr.w	d7
.0
	clr.w	d6
	move.b	(a1)+,d6
	add.w	d6,d7
	dbf	d0,.0
	move.w	d7,d0
	jsr	(randomd0).l
	move.w	#$2D,d1
	movea.l	#SimShotsTbl,a3
	clr.w	d2
	move.w	#7,d3
.1
	clr.w	d4
	move.b	(a3)+,d4
	add.w	d4,d2
	cmp.w	d0,d2
	bgt.w	.2
	addq.w	#1,d3
	dbf	d1,.1
.2
	add.w	(sp)+,d3
	move.w	d3,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

SimShotsTbl	;IDA: unk_8EEFC. 95 only. Shot count weights for SimShots
	dc.b	1,0,0,0,0,0,2,3,4,3,$C,$E,$A,$10,$13,$A
	dc.b	$19,$E,$B,$E,$13,$F,$F,$F,$D,$A,$A,$A,9,9,5,$B
	dc.b	4,4,2,5,3,1,1,1,0,1,0,1,0,0

SeasonGameOver	;IDA: sub_8EF2A. 95 only. After a human season game: copy the scores into its SeasonTeams entry, mark it played and save the
	;results (AddSeasonGoals, WriteDayGames, RecordGameResult, SaveSimGame)
	clr.w	(seasonsetupreq).w
	btst	#3,(GameFlags).w
	beq.w	.4
	st	(seasonsetupreq).w
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	ReadSeasonHeader
	bsr.w	BuildSeasonTeamList
	move.w	(HomeTeam).w,d1
	movea.l	#SimWeights+$1B,a0
	clr.w	d0
	move.b	(a0)+,d0
	beq.w	.3
	bra.w	.1
.0
	cmp.b	(a0),d1
	beq.w	.2
	addq.w	#5,a0
.1
	dbf	d0,.0
	bra.w	.3
.2
	movea.l	#HmShots,a1
	move.b	$D(a1),2(a0)
	adda.w	#$366,a1
	move.b	$D(a1),3(a0)
	bset	#1,4(a0)
	jsr	(RecordPlayoffGame).l
	bset	#7,(GameFlags).w
	bsr.w	AddSeasonGoals
	bsr.w	WriteDayGames
	bsr.w	RecordGameResult
	bset	#1,(SimFlags).w
	jsr	(SaveSimGame).l
	bclr	#7,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
.3
	movem.l	(sp)+,d0-d7/a0-a6
.4
	rts

AddSeasonGoals	;IDA: sub_8EFC0. 95 only. Add the game's goals to the season goal total (save RAM $1B44) and count the game
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a0,-(sp)
	move.l	#$1B44,d0
	moveq	#6,d1
	movea.l	#SeasonGoalSum,a0
	jsr	(ReadSRAM).l
	movea.l	(sp)+,a0
	clr.l	d0
	move.b	2(a0),d0
	add.b	3(a0),d0
	add.l	d0,(SeasonGoalSum).w
	addq.w	#1,(SeasonGameCount).w
	move.l	#$1B44,d0
	moveq	#6,d1
	movea.l	#SeasonGoalSum,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearSeasonData	;IDA: sub_8F00E. 95 only. Clear the season results and standings in save RAM for a new season
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(M68K_RAM).l,a0
	move.w	#$CCB,d0
	clr.l	d1
.0
	move.b	d1,(a0)+
	dbf	d0,.0
	move.l	#$E2A,d0
	move.l	#$CCC,d1
	lea	(M68K_RAM).l,a0
	jsr	(WriteSRAM).l
	lea	(M68K_RAM).l,a0
	move.w	#$4D,d0
	clr.l	d1
.1
	move.b	d1,(a0)+
	dbf	d0,.1
	move.l	#$1AF6,d0
	moveq	#$4E,d1
	lea	(M68K_RAM).l,a0
	jsr	(WriteSRAM).l
	move.l	#$24,(M68K_RAM).l
	move.w	#5,(M68K_RAM+4).l
	move.l	#$1B44,d0
	moveq	#6,d1
	lea	(M68K_RAM).l,a0
	jsr	(WriteSRAM).l
	move.w	#$1113,d1
	lsr.w	#2,d1
	clr.l	d0
	lea	(M68K_RAM).l,a0
.2
	move.l	d0,(a0)+
	dbf	d1,.2
	move.l	#$5FD6,d0
	move.l	#$1110,d1
	lea	(M68K_RAM).l,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

RecordGameResult	;IDA: sub_8F0C0. 95 only. RecordTeamResult for the home and the away team, then the checksum
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d4
	bsr.w	RecordTeamResult
	move.w	#1,d4
	bsr.w	RecordTeamResult
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

RecordTeamResult	;IDA: sub_8F0DE. 95 only. Add a win, loss or tie to the team's standings record in save RAM ($1AF6, playoffs $6173; 3 bytes a team)
	movem.l	a0,-(sp)
	clr.w	d2
	move.b	(a0),d2
	tst.w	d4
	beq.w	.0
	move.b	1(a0),d2
.0
	mulu.w	#3,d2
	move.l	#$1AF6,d0
	btst	#5,(SeasonFlags).w
	beq.w	.1
	move.l	#$6173,d0
.1
	add.l	d2,d0
	move.b	2(a0),d3
	move.b	3(a0),d5
	tst.w	d4
	beq.w	.2
	move.w	d3,-(sp)
	move.w	d5,d3
	move.w	(sp)+,d5
.2
	cmp.b	d5,d3
	beq.w	.4
	bgt.w	.3
	addq.l	#2,d0
	bra.w	.5
.3
	addi.l	#0,d0
	bra.w	.5
.4
	addq.l	#1,d0
.5
	moveq	#1,d1
	movea.l	#shootoutteam,a0	;shootoutteam as a one byte save RAM buffer
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	addq.b	#1,(shootoutteam).w
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	movem.l	(sp)+,a0
	rts

MakeDateString	;IDA: sub_8F16A. 95 only. a1 = "Month day" string for SeasonDay (MonthNames, MonthDays)
	movem.l	d0-d7/a0/a2-a6,-(sp)
	clr.w	d0
	move.b	(SeasonDay).w,d0
	addq.w	#4,d0
	clr.w	d1
	movea.l	#MonthDays,a0
	clr.w	d2
.0
	move.b	(a0,d1.w),d2
	cmp.w	d2,d0
	ble.w	.1
	addq.w	#1,d1
	sub.w	d2,d0
	subq.w	#1,d0
	bra.s	.0
.1
	movea.l	#MonthNames,a1
	bra.w	.3
.2
	adda.w	(a1),a1
.3
	dbf	d1,.2
	move.w	d0,-(sp)
	movea.l	#SeasonGoalSum,a3
	move.w	(a1),d0
	subq.w	#1,d0
.4
	move.b	(a1)+,(a3)+
	dbf	d0,.4
	move.w	(sp)+,d0
	addq.w	#1,d0
	cmp.w	#9,d0
	ble.w	.5
	move.w	#3,d1
	bra.w	.6
.5
	move.w	#2,d1
.6
	jsr	(PushNumberWidth).l
	movea.l	#SeasonGoalSum,a3
	jsr	(appstring).l
	movea.l	a3,a1
	movem.l	(sp)+,d0-d7/a0/a2-a6
	rts

MonthNames	;IDA: unk_8F1E6. 95 only. October ... April (String)
	String	'October',$0
	String	'November'
	String	'December'
	String	'January',$0
	String	'February'
	String	'March',$0
	String	'April',$0

DayToDate	;no IDA label. 95 only. d1 = month, d0 = day for SeasonDay
	movem.l	d2-d7/a0,-(sp)
	clr.w	d0
	move.b	(SeasonDay).w,d0
	addq.w	#4,d0
	clr.w	d1
	movea.l	#MonthDays,a0
	clr.w	d2
.loop
	move.b	(a0,d1.w),d2
	cmp.w	d2,d0
	ble.w	.done
	addq.w	#1,d1
	sub.w	d2,d0
	subq.w	#1,d0
	bra.s	.loop
.done
	movem.l	(sp)+,d2-d7/a0
	rts

DateToDay	;no IDA label. 95 only. d2 = schedule day of month d1, day d0 (clamped to the season)
	movem.l	d0-d1/d4,-(sp)
	cmp.b	#6,d1
	ble.w	.0
	clr.w	d1
	cmp.b	#4,d0
	bge.w	.0
	move.b	#4,d0
.0
	cmp.b	#6,d1
	bne.w	.1
	cmp.b	#$D,d0
	ble.w	.1
	move.b	#$D,d0
.1
	movea.l	#MonthDays,a0
	ext.w	d0
	clr.w	d3
	clr.w	d2
.2
	cmp.w	d1,d2
	bge.w	.3
	move.b	(a0,d2.w),d4
	andi.w	#$FF,d4
	add.w	d4,d3
	addq.w	#1,d3
	addq.w	#1,d2
	bra.s	.2
.3
	add.b	d3,d0
	subq.b	#4,d0
	move.w	d0,d2
	andi.w	#$FF,d2
	movem.l	(sp)+,d0-d1/d4
	rts

MonthDays	;IDA: unk_8F2B6. 95 only. Days - 1 of October ... April, then $FF
	dc.b	$1E,$1D,$1E,$1E,$1B,$1E,$1D,$FF

CountTeamGames	;IDA: sub_8F2BE. 95 only. d1 = number of season games of team d0
	movem.l	d2-d7/a0-a6,-(sp)
	btst	#3,(SeasonFlags).w
	bne.w	.7
	clr.w	d2
	move.b	(SeasonDay).w,d2
	clr.w	d3
	move.b	(SeasonLength).w,d3
	cmp.w	d2,d3
	beq.w	.7
	move.w	(SeasonDay).w,-(sp)
	clr.b	(SeasonDay).w
	bsr.w	FindDayGames
	move.w	(sp)+,(SeasonDay).w
	clr.w	d2
	move.b	(SeasonLength).w,d2
	clr.w	d1
	bra.w	.6
.0
	clr.w	d3
	move.b	(a0)+,d3
	bra.w	.4
.1
	cmp.b	(a0),d0
	beq.w	.2
	cmp.b	1(a0),d0
	bne.w	.3
.2
	addq.w	#1,d1
.3
	addq.w	#2,a0
.4
	cmpa.l	#SeasonScheduleEnd,a0
	blt.w	.5
	movea.l	#SeasonSchedule+1,a0
.5
	dbf	d3,.1
.6
	dbf	d2,.0
.7
	movem.l	(sp)+,d2-d7/a0-a6
	rts

ReadStandings	;IDA: sub_8F332. 95 only. Read the 26 teams' standings records (3 bytes: wins, losses, ties) into a0
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#$1AF6,d0
	btst	#5,(SeasonFlags).w
	beq.w	.0
	move.l	#$6173,d0
.0
	moveq	#3,d1
	mulu.w	#$1A,d1
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimScore	;IDA: sub_8F35E. 95 only. Simulate the score of game a0: SimTeamGoals for each team, SimTieBreak on a tie, ScaleSimScore
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(rosterscroll).w,-(sp)
	movea.l	#SimGoalsHome,a1
	movea.l	#SimGoalsHomeDef,a2
	bsr.w	SimTeamGoals
	move.b	d3,2(a0)
	movea.l	#SimGoalsAway,a1
	movea.l	#SimGoalsAwayDef,a2
	bsr.w	SimTeamGoals
	move.b	d3,3(a0)
	cmp.b	2(a0),d3
	bne.w	.0
	bsr.w	SimTieBreak
.0
	bsr.w	ScaleSimScore
	btst	#3,(GameFlags).w
	beq.w	.2
	btst	#5,(SeasonFlags).w
	beq.w	.2
	move.b	2(a0),d0
	move.b	3(a0),d1
	cmp.b	d0,d1
	bne.w	.2
	btst	#2,(vcount).w
	beq.w	.1
	addq.b	#1,3(a0)
	bra.w	.2
.1
	addq.b	#1,2(a0)
.2
	move.w	(sp)+,(rosterscroll).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimTieBreak	;IDA: sub_8F3E0. 95 only. Overtime: maybe add a goal to the home team (SimTieTbl weights)
	movea.l	#SimTieTbl,a1
	clr.w	d0
	move.b	(a0),d0
	move.w	d0,-(sp)
	add.w	d0,d0
	add.w	(sp)+,d0
	adda.w	d0,a1
	move.l	a1,-(sp)
	move.w	#2,d0
	clr.w	d7
.0
	add.b	(a1)+,d7
	dbf	d0,.0
	move.w	d7,d0
	jsr	(randomd0).l
	move.w	#2,d1
	movea.l	(sp)+,a3
	move.w	#$FFFF,d3
	clr.w	d2
.1
	add.b	(a3)+,d2
	cmp.w	d0,d2
	bgt.w	.2
	addq.w	#1,d3
	dbf	d1,.1
.2
	move.b	2(a0),d0
	add.b	d3,d0
	bmi.w	.3
	move.b	d0,2(a0)
.3
	rts

SimTeamGoals	;IDA: sub_8F432. 95 only. d3 = goals picked from the sum of the team's offense and the other team's defense weights (10 each)
	clr.w	d0
	move.b	(a0),d0
	mulu.w	#$A,d0
	adda.w	d0,a1
	clr.w	d0
	move.b	1(a0),d0
	mulu.w	#$A,d0
	adda.w	d0,a2
	movea.l	#SimWeights,a3
	move.w	#9,d0
	clr.w	d7
.0
	move.b	(a1)+,(a3)
	move.b	(a3),d6
	add.b	(a2)+,d6
	move.b	d6,(a3)
	add.b	(a3)+,d7
	dbf	d0,.0
	move.w	d7,d0
	jsr	(randomd0).l
	move.w	#9,d1
	movea.l	#SimWeights,a3
	clr.w	d2
	clr.w	d3
.1
	add.b	(a3)+,d2
	cmp.w	d0,d2
	bgt.w	.2
	addq.w	#1,d3
	dbf	d1,.1
.2
	rts

ScaleSimScore	;IDA: sub_8F488. 95 only. Scale the score to the average goals of the human games so far (SeasonGoalSum / SeasonGameCount), keep
	;the winner
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(TempWord2).w
	move.b	2(a0),d0
	cmp.b	3(a0),d0
	bgt.w	.0
	move.w	#$FFFF,(TempWord2).w
	cmp.b	3(a0),d0
	blt.w	.0
	move.w	#1,(TempWord2).w
.0
	move.l	a0,-(sp)
	move.l	#$1B44,d0
	moveq	#6,d1
	movea.l	#SeasonGoalSum,a0
	jsr	(ReadSRAM).l
	movea.l	(sp)+,a0
	move.l	(SeasonGoalSum).w,d0
	move.w	(SeasonGameCount).w,d1
	tst.w	d1
	beq.w	.7
	divu.w	d1,d0
	mulu.w	#$64,d0
	divu.w	#$48,d0
	cmp.w	#5,d0
	bge.w	.1
	move.w	#5,d0
.1
	cmp.w	#$5A,d0
	ble.w	.2
	move.w	#$5A,d0
.2
	clr.w	d1
	move.b	2(a0),d1
	mulu.w	d0,d1
	addq.w	#5,d1
	divu.w	#$A,d1
	move.b	d1,2(a0)
	clr.w	d1
	move.b	3(a0),d1
	mulu.w	d0,d1
	addq.w	#5,d1
	divu.w	#$A,d1
	move.b	d1,3(a0)
.3
	move.b	2(a0),d0
	move.b	3(a0),d1
	tst.w	(TempWord2).w
	beq.w	.6
	bmi.w	.5
	sub.b	d0,d1
	beq.w	.7
	bmi.w	.4
	addq.b	#1,2(a0)
	bra.s	.3
.4
	addq.b	#1,3(a0)
	bra.s	.3
.5
	cmp.b	d0,d1
	bgt.w	.7
	addq.b	#1,3(a0)
	bra.s	.3
.6
	cmp.b	d1,d0
	bgt.w	.7
	addq.b	#1,2(a0)
	bra.s	.3
.7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeasonSetup	;IDA: sub_8F564. 95 only. SEASON SETUP screen: period length, penalties, line changes, playoffs, injuries, schedule. Start stores
	;the setup (StoreSeasonSetup), WriteSeasonHeader and InitSeasonStats
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	(setupvalues).w
	clr.l	(setupvalues+4).w
	clr.l	(setupvalues+8).w
	bclr	#6,(GameFlags).w
	clr.b	(SeasonFlags).w
	bsr.w	SeasonSetupGfx
	jsr	(printbigz).l
	String	$BF,$8,$2,'SEASON SETUP',$0
	movea.l	#SeasonSetupHelp,a1
	bsr.w	PrintOptionHi
	clr.w	(SelectedPlayerIdx).w
	clr.w	(setupprevline).w
	clr.w	(DispAttribCtr).w
	move.w	#4,(VertLineScrolling).w
	move.w	#$FFFF,(setupdir).w
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.0
	bsr.w	SeasonSetupLines
	bsr.w	DrawSeasonSetup
	bsr.w	ReadAnyPad
	move.w	(SelectedPlayerIdx).w,(setupprevline).w
	tst.w	d1
	bne.w	.1
	bra.w	.8
.1
	move.w	#$FFFF,(setupdir).w
	btst	#7,d1
	bne.w	.8
	btst	#1,d1
	beq.w	.2
	bra.w	.7
.2
	btst	#0,d1
	beq.w	.3
	bra.w	.6
.3
	btst	#2,d1
	beq.w	.4
	bra.w	.5
.4
	btst	#3,d1
	beq.s	.0
	move.w	#3,(setupdir).w
	move.w	(SelectedPlayerIdx).w,d0
	movea.l	#setupvalues,a0
	addq.b	#1,(a0,d0.w)
	bsr.w	WrapSetupUp
	bra.s	.0
.5
	move.w	#2,(setupdir).w
	move.w	(SelectedPlayerIdx).w,d0
	movea.l	#setupvalues,a0
	subq.b	#1,(a0,d0.w)
	bsr.w	WrapSetupDown
	bra.w	.0
.6
	move.w	#0,(setupdir).w
	tst.w	(SelectedPlayerIdx).w
	beq.w	.0
	subq.w	#1,(SelectedPlayerIdx).w
	bra.w	.0
.7
	move.w	#$FFFF,(setupdir).w
	cmpi.w	#4,(SelectedPlayerIdx).w
	beq.w	.0
	move.w	#1,(setupdir).w
	addq.w	#1,(SelectedPlayerIdx).w
	bra.w	.0
.8
	jsr	(forceblack).l
	bsr.w	StoreSeasonSetup
	jsr	(WriteSeasonHeader).l
	jsr	(InitSeasonStats).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadAnyPad	;IDA: sub_8F6A2. 95 only. Wait up to $5460 frames for a pad 1-4 press (ProcessInputWithRepeat), d1 = buttons
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

StoreSeasonSetup	;IDA: sub_8F722. 95 only. Copy the setup values into the season header and flags (SeasonFlags bits 1, 2; GameFlags bit 6)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#setupvalues,a0
	move.w	#$C0,d0
	move.b	d0,(SeasonLength).w
	move.b	(a0),(SeasonPerlen).w
	move.b	1(a0),(SeasonPen).w
	move.b	2(a0),(SeasonLine).w
	bclr	#1,(SeasonFlags).w
	tst.b	3(a0)
	beq.w	.0
	bset	#1,(SeasonFlags).w
.0
	bset	#2,(SeasonFlags).w
	tst.b	4(a0)
	beq.w	.1
	bclr	#2,(SeasonFlags).w
.1
	bclr	#6,(GameFlags).w
	tst.b	5(a0)
	beq.w	.2
	bset	#6,(GameFlags).w
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeasonSetupCounts	;IDA: unk_8F786. 95 only. Number of values of each setup line
	dc.b	3,3,3,2,2,2

WrapSetupUp	;IDA: sub_8F78C. 95 only. Wrap setup value d0 to 0 past its last value
	movea.l	#SeasonSetupCounts,a1
	clr.w	d2
	move.b	(a1,d0.w),d2
	cmp.b	(a0,d0.w),d2
	bgt.w	.0
	clr.b	(a0,d0.w)
.0
	rts

WrapSetupDown	;IDA: sub_8F7A6. 95 only. Wrap setup value d0 to its last value below 0
	tst.b	(a0,d0.w)
	bpl.w	.0
	movea.l	#SeasonSetupCounts,a1
	move.b	(a1,d0.w),d2
	subq.b	#1,d2
	move.b	d2,(a0,d0.w)
.0
	rts

SeasonSetupLines	;IDA: sub_8F7C0. 95 only. a0 = setupvalues; 5 setup lines
	movea.l	#setupvalues,a0
	move.w	#5,(setuplines).w
	move.w	#5,(setupshown).w
	rts

SeasonSetupGfx	;IDA: sub_8F7D4. 95 only. Season setup screen video set up and graphics
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
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$44,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(smallfont3chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$4C,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	#ControllerBgMap,a0
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

DrawSeasonSetup	;IDA: sub_8F8A2. 95 only. Print the setup lines (names and values)
	move.w	(DispAttribCtr).w,d0
	move.w	#9,(printy).w
.0
	move.w	#3,(printx).w
	bsr.w	PrintSetupName
	move.w	#$18,(printx).w
	bsr.w	PrintSetupValue
	addq.w	#2,(printy).w
	addq.w	#1,d0
	cmp.w	(VertLineScrolling).w,d0
	ble.s	.0
	rts

PrintSetupValue	;IDA: sub_8F8CE. 95 only. Print the value of setup line d0, highlighted on the cursor line
	movem.l	d0-d2/a0-a1,-(sp)
	movea.l	#setupvalues,a0
	clr.w	d1
	move.b	(a0,d0.w),d1
	move.w	d0,d2
	add.w	d2,d2
	movea.l	#SetupValueText,a1
	adda.w	(a1,d2.w),a1
	bra.w	.1
.0
	adda.w	(a1),a1
.1
	dbf	d1,.0
	cmp.w	(SelectedPlayerIdx).w,d0
	bne.w	.2
	bsr.w	PrintOptionHi
	bra.w	.3
.2
	bsr.w	PrintOption
.3
	movem.l	(sp)+,d0-d2/a0-a1
	rts

PrintSetupName	;IDA: sub_8F910. 95 only. Print the name of setup line d0, highlighted on the cursor line
	movem.l	d0/a1,-(sp)
	move.w	d0,-(sp)
	movea.l	#SetupNameText,a1
	bra.w	.1
.0
	adda.w	(a1),a1
.1
	dbf	d0,.0
	move.w	(sp)+,d0
	cmp.w	(SelectedPlayerIdx).w,d0
	bne.w	.2
	bsr.w	PrintOptionHi
	bra.w	.3
.2
	bsr.w	PrintOption
.3
	movem.l	(sp)+,d0/a1
	rts

PrintOption	;IDA: sub_8F942. 95 only. Print String a1 at printx / printy in the second small font
	move.w	(smallfontchars).w,-(sp)
	movem.l	a1,-(sp)
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	(smallfont2chars).w,(smallfontchars).w
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	(sp)+,(printy).w
	move.w	(sp)+,(printx).w
	movem.l	(sp)+,a1
	jsr	(print).l
	move.w	(sp)+,(smallfontchars).w
	rts

PrintOptionHi	;IDA: sub_8F986. 95 only. Print String a1 at printx / printy in the highlight font
	move.w	(smallfontchars).w,-(sp)
	movem.l	a1,-(sp)
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	(smallfont3chars).w,(smallfontchars).w
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	(sp)+,(printy).w
	move.w	(sp)+,(printx).w
	movem.l	(sp)+,a1
	jsr	(print).l
	move.w	(sp)+,(smallfontchars).w
	rts

SetupValueText	;IDA: unk_8F9CA. 95 only. Offsets of the value lists of each setup line, then the value Strings
	dc.w	.0-SetupValueText,.1-SetupValueText,.2-SetupValueText,.3-SetupValueText,.4-SetupValueText,.5-SetupValueText
.0
	String	'5 Minutes     '
	String	'10 Minutes    '
	String	'20 Minutes    '
	String	'30 Seconds    '
.1
	String	'Off           '
	String	'On            '
	String	'On,No Offsides'
.2
	String	'On            '
	String	'Off           '
	String	'Auto          '
.3
	String	'Single Game   '
	String	'Best Of Seven '
.4
	String	'Multi-game    '
	String	'One Game Only '
.5
	String	'Normal        '
	String	'Random        '

SetupNameText	;IDA: unk_8FAD6. 95 only. Setup line names
	String	'Period Length',$0
	String	'Penalties    ',$0
	String	'Line Changes ',$0
	String	'Playoffs     ',$0
	String	'Injuries     ',$0
	String	'Season Schedule     '

SeasonSetupHelp	;IDA: unk_8FB3C. 95 only. Season setup help line
	String	$BF,$2,$19,'{} Select option    [] Change option',$BF,$9,$1A,'Start = Store Setup',$0

GamesToday	;IDA: sub_8FB7C. 95 only. GAMES TODAY screen: list the day's games, A toggles human / computer for a game, left / right change the
	;day, start goes on. Also shows the previous day after a game
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ReadSeasonHeader).l
	btst	#0,(sflags11).w
	beq.w	.0
	bclr	#3,(SeasonFlags).w
	bra.w	.2
.0
	btst	#1,(sflags11).w
	beq.w	.1
	subq.b	#1,(SeasonDay).w
	bra.w	.2
.1
	jsr	(SkipToGameDay).l
	btst	#3,(SeasonFlags).w
	beq.w	.2
	btst	#4,(SeasonFlags).w
	bne.w	GamesTodayDone
.2
	jsr	(BuildSeasonTeamList).l
	move.b	(SeasonDay).w,(GamesTodayDay).w
	move.l	#GamesTodayLogoMap,(screenarg).l
	bsr.w	GamesTodayGfx
	jsr	(PrintGamesToday).l
	jsr	(GamesTodayHelp).l
	bsr.w	GamesTodayLines
	move.w	#$FFFF,(setupdir).w
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w

GamesTodayLoop	;IDA: loc_8FC02. 95 only. GamesToday: draw and read the pads
	bsr.w	DrawGamesToday
	bsr.w	ReadAnyPad2
	move.w	(SelectedPlayerIdx).w,(setupprevline).w
	tst.w	d1
	bne.w	.1
	move.b	(SeasonDay).w,d0
	cmp.b	(GamesTodayDay).w,d0
	beq.w	.0
	jsr	(ReadSeasonHeader).l
	jsr	(BuildSeasonTeamList).l
.0
	jmp	Opening2
.1
	move.w	#$FFFF,(setupdir).w
	btst	#7,d1
	bne.w	GamesTodayExit
	btst	#2,d1
	bne.w	GamesTodayPrev
	btst	#3,d1
	bne.w	GamesTodayNext
	btst	#1,d1
	beq.w	.2
	bra.w	GamesTodayDown
.2
	btst	#0,d1
	beq.w	.3
	bra.w	GamesTodayUp
.3
	btst	#6,d1
	bne.w	GamesTodayToggle
	bra.s	GamesTodayLoop

GamesTodayLines	;IDA: sub_8FC74. 95 only. GamesToday: cursor and scroll lines for the day's game count
	clr.w	(SelectedPlayerIdx).w
	clr.w	(setupprevline).w
	clr.w	(DispAttribCtr).w
	move.w	#3,(setupshown).w
	move.w	#2,(VertLineScrolling).w
	movea.l	#SeasonTeams,a0
	clr.w	d0
	move.b	1(a0),d0
	move.w	d0,(setuplines).w
	cmp.b	#3,d0
	bge.w	.0
	subq.w	#1,d0
	move.w	d0,(VertLineScrolling).w
.0
	rts

GamesTodayNext	;IDA: loc_8FCAC. 95 only. GamesToday: right, the next day with games (up to today)
	move.w	#$FFFF,(setupdir).w
	movem.w	d0,-(sp)
	move.b	(SeasonDay).w,d0
	cmp.b	(GamesTodayDay).w,d0
	movem.w	(sp)+,d0
	beq.w	GamesTodayLoop
	move.w	#3,(setupdir).w
	addq.b	#1,(SeasonDay).w
	jsr	(DayHasGames).l
	beq.s	GamesTodayNext
	jsr	(BuildSeasonTeamList).l
	bsr.s	GamesTodayLines
	bra.w	GamesTodayLoop

GamesTodayPrev	;IDA: loc_8FCE4. 95 only. GamesToday: left, the previous day with games
	move.w	#$FFFF,(setupdir).w
	tst.b	(SeasonDay).w
	beq.w	GamesTodayLoop
	movem.w	d0,-(sp)
	move.b	(SeasonDay).w,d0
	cmp.b	(GamesTodayDay).w,d0
	movem.w	(sp)+,d0
	bne.w	.0
	jsr	(WriteDayGames).l
.0
	move.w	#2,(setupdir).w
	jsr	(PrevSeasonDay).l
	jsr	(DayHasGames).l
	beq.s	GamesTodayPrev
	jsr	(BuildSeasonTeamList).l
	bsr.w	GamesTodayLines
	bra.w	GamesTodayLoop

GamesTodayToggle	;IDA: loc_8FD2E. 95 only. GamesToday: A toggles human (flags bit 0) for an unplayed game
	move.w	#6,(setupdir).w
	bra.w	.0
.0
	movem.l	d0-d1/a0,-(sp)
	move.w	(DispAttribCtr).w,d0
	add.w	(SelectedPlayerIdx).w,d0
	mulu.w	#5,d0
	movea.l	#SimWeights+$1C,a0
	btst	#1,4(a0,d0.w)
	bne.w	.1
	bchg	#0,4(a0,d0.w)
	bra.w	.2
.1
	move.w	#$FFFF,(setupdir).w
.2
	movem.l	(sp)+,d0-d1/a0
	bra.w	GamesTodayLoop

GamesTodayUp	;IDA: loc_8FD70. 95 only. GamesToday: cursor up
	move.w	#$FFFF,(setupdir).w
	tst.w	(DispAttribCtr).w
	bne.w	.0
	tst.w	(SelectedPlayerIdx).w
	beq.w	GamesTodayLoop
.0
	move.w	#0,(setupdir).w
	subq.w	#1,(SelectedPlayerIdx).w
	movem.w	d0-d1,-(sp)
	move.w	(DispAttribCtr).w,d1
	add.w	(SelectedPlayerIdx).w,d1
	move.w	(DispAttribCtr).w,d0
	cmp.w	d1,d0
	movem.w	(sp)+,d0-d1
	ble.w	GamesTodayLoop
	addq.w	#1,(SelectedPlayerIdx).w
	subq.w	#1,(DispAttribCtr).w
	subq.w	#1,(VertLineScrolling).w
	bra.w	GamesTodayLoop

GamesTodayDown	;IDA: loc_8FDBA. 95 only. GamesToday: cursor down
	move.w	#$FFFF,(setupdir).w
	movem.w	d0-d1,-(sp)
	move.w	(setuplines).w,d0
	subq.w	#1,d0
.0
	move.w	(DispAttribCtr).w,d1
	add.w	(SelectedPlayerIdx).w,d1
	cmp.w	d1,d0
	movem.w	(sp)+,d0-d1
	beq.w	GamesTodayLoop
	move.w	#1,(setupdir).w
.1
	addq.w	#1,(SelectedPlayerIdx).w
	movem.w	d0-d1,-(sp)
	move.w	(VertLineScrolling).w,d0
	move.w	(SelectedPlayerIdx).w,d1
	add.w	(DispAttribCtr).w,d1
	cmp.w	d1,d0
.2
	movem.w	(sp)+,d0-d1
	bge.w	GamesTodayLoop
	subq.w	#1,(SelectedPlayerIdx).w
	addq.w	#1,(VertLineScrolling).w
	addq.w	#1,(DispAttribCtr).w
	bra.w	GamesTodayLoop

GamesTodayExit	;IDA: loc_8FE10. 95 only. GamesToday: start, save today's games
	jsr	(forceblack).l
	btst	#1,(sflags11).w
	bne.w	.0
	btst	#0,(sflags11).w
	bne.w	.0
	move.b	(SeasonDay).w,d0
	cmp.b	(GamesTodayDay).w,d0
	beq.w	.1
.0
	jsr	(ReadSeasonHeader).l
	jsr	(BuildSeasonTeamList).l
.1
	jsr	(WriteDayGames).l

GamesTodayDone	;IDA: loc_8FE48. 95 only. GamesToday: return
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadAnyPad2	;IDA: sub_8FE4E. 95 only. As ReadAnyPad
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

PrintGamesToday	;IDA: sub_8FECA. 95 only. GAMES TODAY title
	jsr	(printbigz).l
	String	$BF,$9,$2,'GAMES TODAY'
	rts

PrintPreviousDay	;IDA: sub_8FEE2. 95 only. PREVIOUS DAY title, falls into DrawGamesToday
	jsr	(printbigz).l
	String	$BF,$8,$2,'PREVIOUS DAY',$0
	rts

DrawGamesToday	;IDA: loc_8FEFC. 95 only. Draw the date, the day's games and the arrows
	movem.l	d0-d7/a0-a6,-(sp)
	cmpi.w	#2,(setupdir).w
	beq.w	.1
	cmpi.w	#3,(setupdir).w
	beq.w	.1
	cmpi.w	#0,(setupdir).w
	beq.w	.0
	cmpi.w	#1,(setupdir).w
	bne.w	.3
.0
	jsr	(printz).l
	String	$FF,$19,$7,$0
	move.w	#7,d0
	move.w	#$11,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	bra.w	.3
.1
	move.w	#$28,d0
	move.w	#$17,d1
	move.w	#$7FF,d2
	jsr	(printz).l
	String	$FF,$0,$2,$0
	jsr	(eraser).l
	move.b	(GamesTodayDay).w,d0
	cmp.b	(SeasonDay).w,d0
	beq.w	.2
	bsr.w	PrintPreviousDay
	bra.w	.3
.2
	bsr.w	PrintGamesToday
.3
	move.w	(setuplines).w,d0
	subq.w	#1,d0
	cmp.w	(VertLineScrolling).w,d0
	ble.w	.4
	jsr	(printz).l
	String	$FF,$3,$17,'}'
	bra.w	.5
.4
	jsr	(printz).l
	String	$FF,$3,$17,' '
.5
	tst.w	(DispAttribCtr).w
	beq.w	.6
	jsr	(printz).l
	String	$FF,$3,$8,'{'
	bra.w	.7
.6
	jsr	(printz).l
	String	$FF,$3,$8,' '
.7
	movea.l	#SeasonTeams,a0
	clr.w	d1
	move.b	1(a0),d3
	beq.w	.13
	subq.w	#1,d3
	mulu.w	#5,d3
	addq.w	#2,d3
	move.w	(DispAttribCtr).w,d0
	mulu.w	#5,d0
	addq.w	#2,d0
	clr.w	d2
.8
	cmp.w	d3,d0
	bgt.w	.13
	jsr	(printz).l
	String	$FF,$14,$5,$0
	btst	#5,(SeasonFlags).w
	beq.w	.9
	movem.l	d0-d1/a1,-(sp)
	jsr	(printz).l
	String	$FF,$C,$5,'PLAYOFFS DAY '
	move.w	#2,d1
	clr.w	d0
	move.b	(SeasonDay).w,d0
	addq.w	#1,d0
	jsr	(PushNumberWidth).l
	jsr	(print).l
	movem.l	(sp)+,d0-d1/a1
	bra.w	.10
.9
	movem.l	d0/a1,-(sp)
	jsr	(MakeDateString).l
	movea.l	#SeasonGoalSum,a1
	move.w	(a1),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jsr	(print).l
	movem.l	(sp)+,d0/a1
.10
	bsr.w	DrawGameTeams
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	#$E,(printx).w
	movea.l	#GameColsTbl2,a1
	move.b	(a1,d2.w),(printy+1).w
	clr.w	d1
	move.b	(a0,d0.w),d1
	bsr.w	DrawGameCursor
	move.w	#$E,(printx).w
	movea.l	#GameColsTbl1,a1
	move.b	(a1,d2.w),(printy+1).w
	clr.w	d1
	move.b	1(a0,d0.w),d1
	bsr.w	DrawGameCursor
	movea.l	#GameColsTbl4,a1
	move.b	(a1,d2.w),(printy+1).w
	move.w	#$13,(printx).w
	jsr	(printz).l
	String	'AT'
	btst	#0,4(a0,d0.w)
	bne.w	.11
	bsr.w	DrawGameUser
	bra.w	.12
.11
	bsr.w	DrawGameResult
.12
	bsr.w	PrintGameLine
	addq.w	#5,d0
	addq.w	#1,d2
	cmp.w	#3,d2
	bge.w	.13
	bra.w	.8
.13
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintGameLine	;IDA: sub_90102. 95 only. Print a game line
	btst	#1,4(a0,d0.w)
	beq.w	.0
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d5
	move.b	2(a0,d0.w),d5
	movea.l	#GameColsTbl6,a1
	bsr.w	PrintGameScore
	move.b	3(a0,d0.w),d5
	movea.l	#GameColsTbl5,a1
	bsr.w	PrintGameScore
	movem.l	(sp)+,d0-d7/a0-a6
.0
	rts

PrintGameScore	;IDA: sub_90134. 95 only. Print a game score
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$FF,$1C,$0,$0
	move.b	(a1,d2.w),(printy+1).w
	move.w	d5,d0
	moveq	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(print).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawGameTeams	;IDA: sub_90160. 95 only. Draw the team names of a game line
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$FF,$8,$0,$0
	movea.l	#(GameColsTbl4+3),a0
	move.w	(setupprevline).w,d1
	move.b	(a0,d1.w),(printy+1).w
	move.w	#2,d0
	move.w	#3,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$FF,$8,$0,$0
	movea.l	#(GameColsTbl4+3),a0
	move.w	(SelectedPlayerIdx).w,d1
	move.b	(a0,d1.w),(printy+1).w
	move.w	(seasonchars2).w,d4
	movea.l	#GamesTodayMap1,a0
	clr.w	d0
	clr.w	d1
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawGameUser	;IDA: sub_901DC. 95 only. Draw the C / H (computer / human) marks of a game line
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#1,4(a0,d0.w)
	bne.w	.0
	jsr	(printz).l
	String	$FF,$B,$0,$0
	movea.l	#GameColsTbl3,a1
	move.b	(a1,d2.w),(printy+1).w
	clr.w	d0
	clr.w	d1
	move.w	(padcursorchars).w,d4
	movea.l	#GamesTodayMap2,a0
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	bra.w	.1
.0
	jsr	(printz).l
	String	$FF,$1A,$0,$0
	movea.l	#GameColsTbl4,a1
	move.b	(a1,d2.w),(printy+1).w
	movea.l	#HumanText,a1
	jsr	(print).l
	move.w	#$B,(printx).w
	subq.w	#1,(printy).w
	move.w	#$7FF,d2
	move.w	#3,d0
	move.w	#3,d1
	jsr	(eraser).l
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CompText	;IDA: unk_90274. 95 only. "C"
	String	'C',$0

HumanText	;IDA: unk_90278. 95 only. "H"
	String	'H',$0

DrawGameResult	;IDA: sub_9027C. 95 only. Draw the result of a game line
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#1,4(a0,d0.w)
	bne.w	.0
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	#$B,(printx).w
	movea.l	#GameColsTbl3,a1
	move.b	(a1,d2.w),(printy+1).w
	clr.w	d0
	clr.w	d1
	move.w	(seasonchars1).w,d4
	movea.l	#GamesTodayMap3,a0
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	bra.w	.1
.0
	jsr	(printz).l
	String	$FF,$1A,$0,$0
	movea.l	#GameColsTbl4,a1
	move.b	(a1,d2.w),(printy+1).w
	movea.l	#CompText,a1
	jsr	(print).l
	move.w	#$B,(printx).w
	subq.w	#1,(printy).w
	move.w	#$7FF,d2
	move.w	#3,d0
	move.w	#3,d1
	jsr	(eraser).l
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawGameCursor	;IDA: sub_9031A. 95 only. Draw the cursor on the game line
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

GameColsTbl1	;IDA: unk_9034A. 95 only. Game line columns
	dc.b	7,$D,$13

GameColsTbl2	;IDA: unk_9034D
	dc.b	$A,$10,$16

GameColsTbl3	;IDA: unk_90350
	dc.b	8,$E,$14

GameColsTbl4	;IDA: unk_90353
	dc.b	9,$F,$15,8,$E,$14

GameColsTbl5	;IDA: unk_90359
	dc.b	8,$E,$14

GameColsTbl6	;IDA: unk_9035C
	dc.b	$A,$10,$16,$FF

GamesTodayGfx	;IDA: sub_90360. 95 only. Games today screen video set up and graphics
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
	dc.b	$0B,$83,$44,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$4C,$67,$89,$AB,$CD,$EF;remap table
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(seasonchars2).w
	movea.l	#GamesTodayMap1+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$97,$54,$CF,$F9,$AB,$CD,$E1;remap table
	move.w	d4,(padcursorchars).w
	movea.l	#GamesTodayMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$97,$54,$CF,$F9,$AB,$CD,$E1;remap table
	move.w	d4,(seasonchars1).w
	movea.l	#GamesTodayMap3+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$97,$54,$CF,$F9,$AB,$CD,$E1;remap table
	move.w	d4,(teamblocksmapptr).w
	movea.l	#Teamblocksmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	(screenarg).w,a0
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
	rts

GamesTodayHelp	;IDA: sub_9048E. 95 only. Games today help line
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printz).l
	String	$FF,$2,$19,'A=Human/Computer',$FF,$19,$19,'[] Change day',$0
	move.w	(sp)+,(smallfontchars).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SeasonOptions	;IDA: sub_904D2. 95 only. SEASON OPTIONS menu: the regular season, end of season or playoff item list (GetSeasonMenu); an item
	;runs through SeasonMenuJumps / SeasonEndMenuJumps / PlayoffMenuJumps
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(SelectedPlayerIdx).w
	clr.w	(DispAttribCtr).w
	move.w	#9,(VertLineScrolling).w
.0
	bsr.w	SeasonOptionsGfx
	jsr	(printbigz).l
	String	$BF,$7,$2,'SEASON OPTIONS',$0
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.1
	bsr.w	DrawSeasonMenu
.2
	bsr.w	ReadAnyPad3
	tst.w	d1
	bne.w	.6
.3
	jmp	Opening2
.4
	movem.l	(sp)+,d0-d7/a0-a6
.5
	rts
.6
	btst	#1,d1
	beq.w	.9
	move.w	(SelectedPlayerIdx).w,d0
	addq.w	#1,d0
	add.w	(DispAttribCtr).w,d0
	bsr.w	GetSeasonMenu
	tst.w	(a1)
	beq.s	.2
	move.w	(SelectedPlayerIdx).w,d0
	cmp.w	#$A,d0
	blt.w	.7
	addq.w	#1,(DispAttribCtr).w
	addq.w	#1,(VertLineScrolling).w
	bra.w	.8
.7
	addq.w	#1,(SelectedPlayerIdx).w
.8
	bra.s	.1
.9
	btst	#0,d1
	beq.w	.13
	tst.w	(SelectedPlayerIdx).w
	bne.w	.10
	tst.w	(DispAttribCtr).w
	beq.s	.2
.10
	move.w	#0,(setupdir).w
	tst.w	(SelectedPlayerIdx).w
	bne.w	.11
	subq.w	#1,(DispAttribCtr).w
	subq.w	#1,(VertLineScrolling).w
	bra.w	.12
.11
	subq.w	#1,(SelectedPlayerIdx).w
.12
	bra.w	.1
.13
	btst	#7,d1
	beq.w	.14
	bra.w	.15
.14
	btst	#5,d1
	beq.w	.2
.15
	move.w	(SelectedPlayerIdx).w,d0
	add.w	(DispAttribCtr).w,d0
	asl.w	#2,d0
	movea.l	#SeasonMenuJumps,a0
	btst	#5,(SeasonFlags).w
	beq.w	.16
	movea.l	#PlayoffMenuJumps,a0
.16
	btst	#5,(sflags12).w
	beq.w	.17
	movea.l	#SeasonEndMenuJumps,a0
.17
	movea.l	(a0,d0.w),a0
	move.w	(SelectedPlayerIdx).w,-(sp)
	move.w	(DispAttribCtr).w,-(sp)
	move.w	(VertLineScrolling).w,-(sp)
	jsr	(a0)
	beq.w	.18
	bmi.w	.20
	bra.w	.19
.18
	addq.w	#6,sp
	bra.w	.4
.19
	move.w	(sp)+,(VertLineScrolling).w
	move.w	(sp)+,(DispAttribCtr).w
	move.w	(sp)+,(SelectedPlayerIdx).w
	bra.w	.0
.20
	move.w	(sp)+,(VertLineScrolling).w
	move.w	(sp)+,(DispAttribCtr).w
	move.w	(sp)+,(SelectedPlayerIdx).w
	bra.w	.1

SeasonMenuJumps	;IDA: unk_90620. 95 only. SeasonMenuText items
	dc.l	MenuPlayGames,MenuPlayUntil,MenuStandings,MenuCalendar,MenuGamesToday
	dc.l	MenuLeagueLeaders,MenuTeamStats,MenuPlayerStats,MenuHighlights,MenuEndSeason

SeasonEndMenuJumps	;IDA: unk_90648. 95 only. SeasonEndMenuText items
	dc.l	MenuPlayGames,MenuStandings,MenuCalendar,MenuGamesToday,MenuLeagueLeaders
	dc.l	MenuTeamStats,MenuPlayerStats

PlayoffMenuJumps	;IDA: unk_90664. 95 only. PlayoffMenuText items
	dc.l	MenuPlayGames,MenuGamesToday,MenuTeamStats,MenuPlayerStats,MenuPlayoffTeamStats
	dc.l	MenuPlayoffPlayerStats,MenuPlayoffTree

MenuEndSeason	;no IDA label. 95 only. End Season After Today
	move.b	(SeasonDay).w,(SeasonLength).w
	addq.b	#1,(SeasonLength).w
	jsr	(WriteSeasonHeader).l
	bra.w	MenuStay

MenuLeagueLeaders	;no IDA label. 95 only. League Leaders
	jsr	(LeagueLeadersScreen).l
	bra.w	MenuStay

MenuPlayoffTeamStats	;no IDA label. 95 only. Playoff Team Stats (sflags11 bit 3)
	bset	#3,(sflags11).w
	jsr	(SeasonTeamStats).l
	bclr	#3,(sflags11).w
	bra.w	MenuStay

MenuTeamStats	;no IDA label. 95 only. Team Stats
	jsr	(SeasonTeamStats).l
	bra.w	MenuStay

MenuPlayoffPlayerStats	;no IDA label. 95 only. Playoff Player Stats (sflags11 bit 3)
	bset	#3,(sflags11).w
	jsr	(SeasonPlayerStats).l
	bclr	#3,(sflags11).w
	bra.w	MenuStay

MenuPlayerStats	;no IDA label. 95 only. Player Stats
	jsr	(SeasonPlayerStats).l
	bra.w	MenuStay

MenuHighlights	;no IDA label. 95 only. Highlights
	jsr	(HighlightsScreen).l
	bra.w	MenuStay

MenuGamesToday	;no IDA label. 95 only. Games Today
	jsr	(GamesToday).l
	bra.w	MenuStay

MenuStandings	;no IDA label. 95 only. NHL Standings
	jsr	(StandingsScreen).l
	bra.w	MenuStay

MenuPlayoffTree	;no IDA label. 95 only. Playoff Tree
	jsr	(PlayoffTreeScreen).l
	bra.w	MenuStay

MenuStay	;no IDA label. 95 only. d0 = 1: stay in the menu
	move.w	#1,d0
	rts

MenuCalendar	;no IDA label. 95 only. Team Schedule Calendar
	jsr	(CalendarScreen).l
	bra.s	MenuStay

MenuPlayGames	;no IDA label. 95 only. Play Games: d0 = 0
	clr.b	(AutoplayDay).w
	jsr	(forceblack).l
	clr.w	d0
	rts

MenuPlayUntil	;no IDA label. 95 only. Play Until A Day: pick the day with A (month) / B (day), C cancels, start autoplays to AutoplayDay
	bsr.w	BuildSeasonTeamList
	st	(seasonteamsel).w
	bsr.w	NextSeasonTeam
	tst.w	(seasonteamsel).w
	bmi.w	.2
	jsr	(printz).l
	String	$BF,$5,$A,$0
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(Framer).l
	jsr	(printz).l
	String	$BF,$7,$C,$0
	jsr	(printz2).l
	String	$F9,$2,'Please complete human',$FD,$7,$FC,$D,'controlled games before'
	jsr	(printz2).l
	dc.w	$3C;String length
	dc.b	$FD,$7,$FA,$1,$F9,$2,'selecting autoplay.',$FD
	dc.b	$7,$FA,$2,$F9,$2,'Press START to continue.',$F9,$0
	dc.b	$0
.0
	move.w	(vcount).w,d0
.1
	cmp.w	(vcount).w,d0
	beq.s	.1
	jsr	(orjoy4way).l
	btst	#7,d1
	beq.s	.0
	jmp	(AutoplayCancel).l
.2
	jsr	(printz).l
	String	$BF,$5,$A,$0
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(Framer).l
	jsr	(printz).l
	String	$BF,$7,$C,$0
	jsr	(printz2).l
	String	$F9,$2,'Autoplay games until this',$FD,$7,$FC,$D,'day...',$F9,$0,$0
	jsr	(printz2).l
	String	$FD,$7,$FC,$12,$F9,$2,'Press A to change Month',$0
	jsr	(printz2).l
	String	$FD,$7,$FC,$13,$F9,$2,'Press B to change Day',$0
	jsr	(printz2).l
	String	$FD,$7,$FC,$14,$F9,$2,'Press C to cancel',$0
	jsr	(printz2).l
	String	$FD,$7,$FC,$15,$F9,$2,'Press Start to autoplay',$F9,$0,$0
	move.b	(SeasonDay).w,d0
	addq.b	#1,d0
	move.b	d0,(AutoplayDay).w
	bsr.w	PrintAutoplayDay
.3
	move.w	(vcount).w,d0
.4
	cmp.w	(vcount).w,d0
	beq.s	.4
	jsr	(orjoy4way).l
	btst	#5,d1
	bne.w	AutoplayCancel
	btst	#6,d1
	bne.w	.11
	btst	#4,d1
	bne.w	.5
	btst	#7,d1
	bne.w	AutoplayMessage
	bra.s	.4
.5
	move.b	(SeasonDay).w,-(sp)
	move.b	(AutoplayDay).w,(SeasonDay).w
	jsr	(DayToDate).l
	move.b	(sp)+,(SeasonDay).w
.6
	movea.l	#MonthDays,a0
	move.b	(a0,d1.w),d2
	addq.b	#1,d0
	cmp.b	d2,d0
	ble.w	.7
	clr.w	d0
	tst.w	d1
	bne.w	.7
	move.w	#5,d0
.7
	cmp.w	#6,d1
	bne.w	.8
	cmp.w	#$E,d0
	ble.w	.8
	clr.w	d0
.8
	cmp.w	#6,d1
	bne.w	.9
	cmp.w	#$E,d0
	bne.w	.9
	move.w	#$C0,d2
	bra.w	.10
.9
	jsr	(DateToDay).l
.10
	move.b	(SeasonDay).w,d5
	andi.w	#$FF,d5
	cmp.w	d5,d2
	ble.s	.6
	move.b	d2,(AutoplayDay).w
	bsr.w	PrintAutoplayDay
	bra.w	.4
.11
	move.b	(SeasonDay).w,-(sp)
	jsr	(DayToDate).l
	cmp.w	#6,d1
	bne.w	.12
	move.b	(sp)+,(SeasonDay).w
	bra.w	.4
.12
	move.b	(AutoplayDay).w,(SeasonDay).w
	jsr	(DayToDate).l
	move.b	(sp)+,(SeasonDay).w
	addq.b	#1,d1
.13
	jsr	(DateToDay).l
	move.b	(SeasonDay).w,d4
	andi.w	#$FF,d4
	cmp.w	d4,d2
	ble.w	.14
	move.b	d2,(AutoplayDay).w
	bsr.w	PrintAutoplayDay
	bra.w	.4
.14
	move.b	(SeasonDay).w,-(sp)
	addq.b	#1,d4
	move.b	d4,(SeasonDay).w
	jsr	(DayToDate).l
	move.b	(sp)+,(SeasonDay).w
	bra.s	.13

AutoplayCancel	;no IDA label. 95 only. Cancel: AutoplayDay = SeasonDay, erase the window, d0 = -1
	move.b	(SeasonDay).w,(AutoplayDay).w
	jsr	(printz).l
	String	$BF,$5,$A,$0
	move.w	#$7FF,d2
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(eraser).l
	move.w	#$FFFF,d0
	rts

AutoplayMessage	;no IDA label. 95 only. AUTOPLAYING GAMES. DO NOT PRESS RESET !!, d0 = 0
	jsr	(printz).l
	String	$BF,$5,$A,$0
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(Framer).l
	jsr	(printz).l
	String	$BF,$7,$C,$0
	jsr	(printz2).l
	dc.w	$46;String length
	dc.b	$F9,$2,$FA,$3,'AUTOPLAYING GAMES.',$FA,$2,$FD
	dc.b	$7,'DO NOT PRESS RESET !!',$FA,$2,$FD,$7,'Please wait...',$F9
	dc.b	$0,$0
	clr.w	d0
	rts

PrintAutoplayDay	;no IDA label. 95 only. Print the AutoplayDay date
	jsr	(printz).l
	String	$BF,$A,$F,$0
	move.w	(printx).w,-(sp)
	jsr	(printz2).l
	String	$F9,$2,'               ',$0
	move.w	(sp)+,(printx).w
	move.b	(SeasonDay).w,-(sp)
	move.b	(AutoplayDay).w,(SeasonDay).w
	jsr	(MakeDateString).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	$F9,$0
	move.b	(sp)+,(SeasonDay).w
	rts

ReadAnyPad3	;IDA: sub_90AEC. 95 only. As ReadAnyPad
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

DrawSeasonMenu	;IDA: sub_90B6C. 95 only. Draw the season menu items
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d1
	jsr	(printz).l
	String	$FF,$0,$7,$0
.0
	move.w	d1,d0
	add.w	(DispAttribCtr).w,d0
	bsr.w	GetSeasonMenu
	tst.w	(a1)
	beq.w	.3
	move.w	(a1),d2
	subq.w	#2,d2
	lsr.w	#1,d2
	subi.w	#$14,d2
	neg.w	d2
	move.w	d2,(printx).w
	cmp.w	(SelectedPlayerIdx).w,d1
	beq.w	.1
	jsr	(print).l
	bra.w	.2
.1
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(print).l
	move.w	(sp)+,(smallfontchars).w
.2
	addq.w	#1,d1
	addq.w	#2,(printy).w
	cmp.w	#$A,d1
	blt.s	.0
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GetSeasonMenu	;IDA: sub_90BD6. 95 only. a1 = item d0 of the season menu for the season state
	movem.w	d0,-(sp)
	movea.l	#SeasonMenuText,a1
	btst	#5,(SeasonFlags).w
	beq.w	.0
	movea.l	#PlayoffMenuText,a1
.0
	btst	#5,(sflags12).w
	beq.w	.2
	movea.l	#SeasonEndMenuText,a1
	bra.w	.2
.1
	adda.w	(a1),a1
	tst.w	(a1)
	beq.w	.3
.2
	dbf	d0,.1
	bra.w	.3
.3
	movem.w	(sp)+,d0
	rts

SeasonMenuText	;IDA: unk_90C1A. 95 only. Regular season menu
	String	'      Play Games      '
	String	'   Play Until A Day   '
	String	'    NHL Standings     '
	String	'Team Schedule Calendar'
	String	'     Games Today      '
	String	'    League Leaders    '
	String	'      Team Stats      '
	String	'     Player Stats     '
	String	'      Highlights      '
	String	'End Season After Today'
	dc.w	0;end

SeasonEndMenuText	;IDA: unk_90D0C. 95 only. Menu after the regular season
	String	'    On To Playoffs    '
	String	'    NHL Standings     '
	String	'Team Schedule Calendar'
	String	'     Games Today      '
	String	'    League Leaders    '
	String	'      Team Stats      '
	String	'     Player Stats     '
	dc.w	0;end

PlayoffMenuText	;IDA: unk_90DB6. 95 only. Playoff menu
	String	'      Play Games      '
	String	'     Games Today      '
	String	'      Team Stats      '
	String	'     Player Stats     '
	String	'  Playoff Team Stats  '
	String	' Playoff Player Stats '
	String	'     Playoff Tree     '
	dc.w	0;end

SeasonOptionsGfx	;IDA: sub_90E60. 95 only. Season options screen video set up and graphics
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
	dc.b	$0B,$83,$44,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$4C,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(smallfont3chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$BB,$83,$44,$67,$89,$AB,$CD,$EF;remap table
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	movea.l	#Framermap+8,a2
	move.l	#Framermap,(framermapptr).l
	move.w	d4,(framercset).w
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF;remap table
	jsr	(printz).l
	String	$FE,$0,$0,$0
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
	move.w	d4,(optbgchars).w
	rts

PrintWait	;no IDA label. 95 only. Show the wait box
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(optbgchars).w,d4
	jsr	(printz).l
	String	$BE,$F,$F,$0
	movea.l	#WaitBoxMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	move.w	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$BE,$F,$10,$0
	jsr	(printz).l
	String	'  Wait...',$0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CalendarScreen	;no IDA label. 95 only. CALENDAR (team schedule): {} change team, [] change month, start exits
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(CalTeam).w
	clr.w	(CalMonth).w
	clr.w	(CalDay).w
	bsr.w	CountSeasonMonths
	bsr.w	CalendarGfx
	jsr	(printbigz).l
	String	$FF,$C,$2,'CALENDAR',$0
	jsr	(printz).l
	String	$BF,$1,$7,$0
	jsr	(printz2).l
	dc.w	$38;String length
	dc.b	$F9,$1,'[ ]',$FD,$1,$FA,$1,'= Change'
	dc.b	$FD,$1,$FA,$1,'Month',$FD,$1,$FA
	dc.b	$2,'{ }',$FD,$1,$FA,$1,'= Change',$FD
	dc.b	$1,$FA,$1,'Team',$0
	jsr	(printz2).l
	String	$FD,$1,$FC,$15,'START',$FD,$1,$FA,$1,'= Exit',$F9,$0,$0
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.0
	bsr.w	CalendarBg
	bsr.w	DrawCalendar
.1
	bsr.w	ReadAnyPad4
	tst.w	d1
	beq.w	.6
	btst	#7,d1
	bne.w	.7
	btst	#2,d1
	beq.w	.2
	tst.w	(CalMonth).w
	beq.s	.1
	subq.w	#1,(CalMonth).w
	bra.s	.0
.2
	btst	#3,d1
	beq.w	.3
	move.w	(CalMonths).w,d0
	cmp.w	(CalMonth).w,d0
	ble.s	.1
	addq.w	#1,(CalMonth).w
	bra.s	.0
.3
	btst	#1,d1
	beq.w	.4
	move.w	(CalTeam).w,d0
	subq.w	#1,d0
	bpl.w	.5
	move.w	#$19,d0
	bra.w	.5
.4
	btst	#0,d1
	beq.s	.1
	move.w	(CalTeam).w,d0
	addq.w	#1,d0
	cmp.w	#$1A,d0
	blt.w	.5
	clr.w	d0
.5
	move.w	d0,(CalTeam).w
	bra.s	.0
.6
	jmp	(Opening2).l
.7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadAnyPad4	;no IDA label. 95 only. As ReadAnyPad
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

CalendarGfx	;no IDA label. 95 only. Calendar screen video set up and graphics
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
	dc.b	$0B,$83,$44,$67,$89,$AB,$CD,$EF;remap table
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$4C,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(teamblocksmapptr).w
	movea.l	#Teamblocksmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padiconchars1).w
	movea.l	#CalOpponentMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padiconchars2).w
	movea.l	#CalDayMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padiconchars3).w
	movea.l	#CalMonthMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(padiconchars4).w
	movea.l	#CalCheckMap,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(calresultchars).w
	movea.l	#CalResultMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$21,$23,$45,$67,$89,$AB,$CD;remap table
	move.w	d4,(calbgchars).w
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	#CalendarBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#7,d5
	jsr	(dobitmap).l
	rts

CountSeasonMonths	;no IDA label. 95 only. CalMonths = last month of the season
	clr.w	d0
	movea.l	#MonthDays,a0
	clr.w	d1
	move.b	(SeasonLength).w,d1
	addq.w	#4,d1
.0
	clr.w	d2
	move.b	(a0,d0.w),d2
	addq.w	#1,d2
	sub.w	d2,d1
	bmi.w	.1
	beq.w	.1
	addq.w	#1,d0
	bra.s	.0
.1
	move.w	d0,(CalMonths).w
	rts

DrawCalendar	;no IDA label. 95 only. Draw the month of CalTeam: day numbers, opponents, results
	move.w	#$16,d0
	move.w	#$16,d1
	move.w	#$7FF,d2
	jsr	(printz).l
	String	$FF,$9,$5,$0
	jsr	(eraser).l
	bsr.w	DrawCalendarTeam
	bsr.w	DrawCalendarMonth
	bsr.w	CalendarFirstDay
	bsr.w	CalendarFirstX
	clr.w	(CalFirst).w
	tst.w	(CalMonth).w
	bne.w	.0
	move.w	#4,(CalFirst).w
.0
	clr.w	d0
	move.b	(SeasonLength).w,d0
	movea.l	#MonthDays,a0
	move.w	(CalMonth).w,d1
	cmp.w	(CalMonths).w,d1
	beq.w	.1
	clr.w	(CalLast).w
	move.b	(a0,d1.w),(CalLast+1).w
	bra.w	.4
.1
	clr.w	d1
.2
	sub.b	(a0,d1.w),d0
	subq.w	#1,d0
	cmp.w	#$1C,d0
	blt.w	.3
	addq.w	#1,d1
	bra.s	.2
.3
	subq.w	#1,d0
	addq.w	#4,d0
	move.w	d0,(CalLast).w
.4
	movea.l	#MonthDays,a0
	move.w	(CalMonth).w,d1
	clr.w	d7
	move.b	(a0,d1.w),d7
	clr.w	d6
.5
	cmp.w	(CalFirst).w,d6
	blt.w	.19
	cmp.w	(CalLast).w,d6
	bgt.w	.19
	movea.l	#CalGames,a2
	move.w	(CalDay).w,d1
	clr.w	d2
	move.b	(SeasonStartDay).w,d2
	jsr	(ReadDayGames).l
	movea.l	#CalGames,a0
	clr.w	d0
	move.b	1(a0),d0
	move.w	(CalTeam).w,d1
	addq.w	#2,a0
	move.w	#$FFFF,(TempWord1).w
	bra.w	.9
.6
	cmp.b	(a0),d1
	bne.w	.8
.7
	clr.w	(TempWord1).w
	bra.w	.10
.8
	cmp.b	1(a0),d1
	beq.s	.7
	addq.w	#5,a0
.9
	dbf	d0,.6
.10
	tst.w	(TempWord1).w
	bmi.w	.19
	move.l	a0,(CalGamePtr).w
	movea.l	(CalGamePtr).w,a0
	move.w	(CalTeam).w,d0
	cmp.b	(a0),d0
	bne.w	.11
	jsr	(printz).l
	String	$FE,$0,$0,$0
	move.w	(CalX).w,(printx).w
	move.w	(CalY).w,(printy).w
	move.w	#$3A,d2
	add.w	(calbgchars).w,d2
	move.w	#3,d0
	move.w	#3,d1
	jsr	(eraser).l
.11
	bsr.w	DrawCalendarDay
	movea.l	(CalGamePtr).w,a0
	btst	#0,4(a0)
	bne.w	.12
	move.w	(CalX).w,(printx).w
	addq.w	#2,(printx).w
	move.w	(CalY).w,(printy).w
	move.w	(padiconchars4).w,d2
	move.w	#1,d0
	move.w	#1,d1
	jsr	(eraser).l
.12
	movea.l	(CalGamePtr).w,a0
	clr.w	d0
	move.b	(a0),d0
	cmp.w	(CalTeam).w,d0
	bne.w	.13
	move.b	1(a0),d0
.13
	bsr.w	DrawCalendarOpponent
	movea.l	(CalGamePtr).w,a0
	btst	#1,4(a0)
	beq.w	.18
	move.w	#2,d1
	move.w	(CalTeam).w,d0
	cmp.b	(a0),d0
	beq.w	.14
	move.b	3(a0),d0
	cmp.b	2(a0),d0
	beq.w	.17
	bgt.w	.16
	bra.w	.15
.14
	move.b	2(a0),d0
	cmp.b	3(a0),d0
	beq.w	.17
	bgt.w	.16
.15
	move.w	#0,d1
	bra.w	.17
.16
	move.w	#1,d1
.17
	bsr.w	DrawCalendarResult
.18
	bra.w	.20
.19
	bsr.w	DrawCalendarDay
.20
	cmpi.w	#$1C,(CalX).w
	blt.w	.21
	move.w	#$A,(CalX).w
	addq.w	#3,(CalY).w
	bra.w	.22
.21
	addq.w	#3,(CalX).w
.22
	addq.w	#1,(CalDay).w
	addq.w	#1,d6
	dbf	d7,.5
	rts

CalendarFirstX	;no IDA label. 95 only. CalX / CalY of the first day of CalMonth
	move.w	(CalMonth).w,d0
	add.w	d0,d0
	movea.l	#CalendarFirstXTbl,a0
	move.w	#9,(CalY).w
	move.w	(a0,d0.w),(CalX).w
	rts

CalendarFirstXTbl	;no IDA label. 95 only. Column of the first day of each month
	dc.w	$19,$D,$13,$1C,$10,$10,$19

DrawCalendarTeam	;no IDA label. 95 only. Draw the CalTeam name
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(CalTeam).w,d1
	jsr	(printz).l
	String	$FF,$F,$5,$0
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

DrawCalendarMonth	;no IDA label. 95 only. Draw the CalMonth name
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(CalMonth).w,d1
	jsr	(printz).l
	String	$FF,$10,$7,$0
	clr.w	d0
	asl.w	#1,d1
	move.w	(padiconchars3).w,d4
	movea.l	#CalMonthMap,a0
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

DrawCalendarDay	;no IDA label. 95 only. Draw day number d6 at CalX / CalY
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d6,d1
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	(CalX).w,(printx).w
	move.w	(CalY).w,(printy).w
	clr.w	d0
	move.w	(padiconchars2).w,d4
	movea.l	#CalDayMap,a0
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	moveq	#1,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawCalendarOpponent	;no IDA label. 95 only. Draw opponent d0
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,d1
	move.w	(CalX).w,(printx).w
	move.w	(CalY).w,(printy).w
	addq.w	#1,(printy).w
	clr.w	d0
	move.w	(padiconchars1).w,d4
	movea.l	#CalOpponentMap,a0
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	moveq	#1,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawCalendarResult	;no IDA label. 95 only. Draw result d1 (0 loss, 1 win, 2 tie)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(CalX).w,(printx).w
	move.w	(CalY).w,(printy).w
	addq.w	#2,(printy).w
	clr.w	d0
	move.w	(calresultchars).w,d4
	movea.l	#CalResultMap,a0
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	moveq	#1,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CalendarFirstDay	;no IDA label. 95 only. CalDay = schedule day of the 1st of CalMonth
	movea.l	#CalendarFirstDayTbl,a0
	move.w	(CalMonth).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),(CalDay).w
	rts

CalendarFirstDayTbl	;no IDA label. 95 only. Schedule day of the 1st of each month
	dc.w	$FFFC,$1B,$39,$58,$77,$93,$B2

CalendarBg	;no IDA label. 95 only. Draw the calendar background
	move.w	(calbgchars).w,d4
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	#CalendarBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	movea.w	#$69A,a2
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#0,d5
	jsr	(dobitmap).l
	rts

StandingsScreen	;IDA: sub_916B8. 95 only. NHL STANDINGS: {} conference / division, [] the other group; start exits
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#ControllerBgMap,(screenarg).l
	bsr.w	StandingsGfx
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	jsr	(PrintStandingsHelp).l
	jsr	(printbigz).l
	String	$BF,$8,$2,'NHL STANDINGS'
	jsr	(printz).l
	String	$BF,$10,$9,'W  L  T  Pts  GP  GR',$0
	clr.w	(StandingsMode).w
.0
	bsr.w	StandingsGroups
	movea.l	#StandingsBuf,a0
	bsr.w	ReadStandings
	bsr.w	StandingsPoints
	bsr.w	SortStandings
	bsr.w	DrawStandings
.1
	bsr.w	ReadAnyPad5
	tst.w	d1
	beq.w	.6
	btst	#7,d1
	beq.w	.2
	jsr	(forceblack).l
	bra.w	.7
.2
	btst	#2,d1
	beq.w	.3
	eori.w	#1,(StandingsMode).w
	bra.s	.0
.3
	btst	#3,d1
	beq.w	.4
	eori.w	#1,(StandingsMode).w
	bra.s	.0
.4
	btst	#0,d1
	beq.w	.5
	eori.w	#2,(StandingsMode).w
	bra.s	.0
.5
	btst	#1,d1
	beq.s	.1
	eori.w	#2,(StandingsMode).w
	bra.s	.0
.6
	jmp	Opening2
.7
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReadAnyPad5	;IDA: sub_91798. 95 only. As ReadAnyPad
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

SortStandings	;IDA: sub_91818. 95 only. Sort StandingsList by points, then games
	movea.l	#StandingsList,a0
	movea.l	#CalMonth,a1
	movea.l	#StandingsOrder,a2
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
	cmp.w	(CalTeam).w,d7
	bge.w	.4
	subq.w	#1,d7
	bra.s	.1
.4
	btst	#6,(sflags6).w
	bne.s	.0
	rts

StandingsPoints	;IDA: sub_9188E. 95 only. Points and games of the 26 teams from StandingsBuf
	move.w	#$1A,d0
	movea.l	#StandingsBuf,a1
	movea.l	#CalMonth,a2
	movea.l	#StandingsOrder,a3
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

StandingsGroups	;IDA: sub_918DA. 95 only. StandingsList = the teams of group StandingsMode
	movea.l	#StandingsGroupTbl,a5
	move.w	(StandingsMode).w,d0
	asl.w	#2,d0
	movea.l	(a5,d0.w),a5
	clr.w	(CalTeam).w
	move.b	(a5)+,(CalTeam+1).w
	move.w	(CalTeam).w,d0
	movea.l	#StandingsList,a4
	bra.w	.1
.0
	move.b	(a5)+,(a4)+
.1
	dbf	d0,.0
	rts

StandingsGroupTbl	;IDA: unk_91908. 95 only. Team lists of the 4 divisions (count, teams)
	dc.l	StandingsGroup0,StandingsGroup1,StandingsGroup2,StandingsGroup3

StandingsGroup0	;no IDA label
	dc.b	6,0,3,7,$A,$13,$17

StandingsGroup1	;no IDA label
	dc.b	6,4,5,6,$14,$16,$19

StandingsGroup2	;no IDA label
	dc.b	7,1,2,9,$B,$F,$11,$12

StandingsGroup3	;no IDA label
	dc.b	7,8,$C,$D,$E,$10,$15,$18

StandingsGfx	;IDA: sub_91936. 95 only. Standings screen video set up and graphics
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
	dc.b	$0B,$83,$44,$67,$89,$AB,$CD,$EF;remap table
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$4C,$67,$89,$AB,$CD,$EF;remap table
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(teamblocksmapptr).w
	movea.l	#Teamblocksmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	(screenarg).w,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#$B,d5
	jsr	(dobitmap).l
	rts

DrawStandings	;IDA: sub_91A1C. 95 only. Draw the group title and the standings lines
	move.w	#$28,d0
	move.w	#2,d1
	move.w	#$7FF,d2
	jsr	(printz).l
	String	$FF,$0,$16,$0
	jsr	(eraser).l
	movea.l	#StandingsTitles,a1
	move.w	(StandingsMode).w,d0
	jsr	(PrintListItem).l
	move.w	(CalTeam).w,d7
	clr.w	d6
	movea.l	#StandingsList,a4
	jsr	(printz).l
	String	$FF,$2,$A,$0
	bra.w	.1
.0
	clr.w	d1
	move.b	(a4,d6.w),d1
	bsr.w	DrawStandingsLogo
	bsr.w	PrintStandingsLine
	addq.w	#2,(printy).w
	move.w	#2,(printx).w
	addq.w	#1,d6
.1
	dbf	d7,.0
	rts

PrintStandingsLine	;IDA: sub_91A86. 95 only. Print a standings line
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(printy).w,-(sp)
	move.w	d1,d2
	jsr	(printz).l
	String	$FF,$0,$B,$0
	move.w	d6,d1
	add.w	d1,d1
	add.w	d1,(printy).w
	movea.l	#StandingsBuf,a4
	move.w	d2,d5
	mulu.w	#3,d5
	clr.w	d0
	move.w	#2,d1
	move.b	(a4,d5.w),d0
	jsr	(PushNumberWidth).l
	move.w	#$F,(printx).w
	jsr	(print).l
	move.b	2(a4,d5.w),d0
	jsr	(PushNumberWidth).l
	move.w	#$12,(printx).w
	jsr	(print).l
	move.b	1(a4,d5.w),d0
	jsr	(PushNumberWidth).l
	move.w	#$15,(printx).w
	jsr	(print).l
	move.b	(a4,d5.w),d0
	add.b	d0,d0
	add.b	1(a4,d5.w),d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	move.w	#$19,(printx).w
	jsr	(print).l
	move.b	(a4,d5.w),d0
	add.b	1(a4,d5.w),d0
	add.b	2(a4,d5.w),d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	move.w	#$1E,(printx).w
	jsr	(print).l
	move.w	d0,-(sp)
	move.w	d0,d1
	move.w	d2,d0
	jsr	(CountTeamGames).l
	sub.w	(sp)+,d1
	move.w	d1,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	move.w	#$22,(printx).w
	jsr	(print).l
	move.w	(sp)+,(printy).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawStandingsLogo	;IDA: sub_91B6A. 95 only. Draw team d1's block
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

StandingsTitles	;IDA: unk_91B9A. 95 only. Conference / division titles
	String	$FF,$3,$7,'WESTERN CONFERENCE',$FF,$17,$7,'PACIFIC DIV.  '
	String	$FF,$3,$7,'WESTERN CONFERENCE',$FF,$17,$7,'CENTRAL DIV.  '
	String	$FF,$3,$7,'EASTERN CONFERENCE',$FF,$17,$7,'NORTHEAST DIV.'
	String	$FF,$3,$7,'EASTERN CONFERENCE',$FF,$17,$7,'ATLANTIC DIV. '

PrintStandingsHelp	;IDA: loc_91C3A. 95 only. Standings help line
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(smallfontchars).w,-(sp)
	move.w	(smallfont2chars).w,(smallfontchars).w
	jsr	(printz).l
	String	$FF,$2,$19,'{} For Conference',$FF,$18,$19,'[] For Division'
	move.w	(sp)+,(smallfontchars).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SimGoalsHome	;IDA: unk_91C80. 95 only. 26 x 10 goal weights (0-9 goals): home offense
	dc.b	3,3,$F,$A,5,4,2,0,0,0
	dc.b	3,4,9,6,3,7,7,2,1,0
	dc.b	1,4,$B,8,7,5,5,1,0,0
	dc.b	1,3,7,$A,$A,5,2,2,1,1
	dc.b	1,4,$B,9,8,5,3,0,0,1
	dc.b	2,4,8,5,$E,3,3,1,1,1
	dc.b	1,2,8,9,2,7,6,2,2,3
	dc.b	0,6,7,$B,5,6,5,2,0,0
	dc.b	0,7,$F,$A,5,4,0,0,1,0
	dc.b	2,8,9,8,8,2,4,1,0,0
	dc.b	2,3,6,8,7,4,6,2,2,2
	dc.b	0,4,6,$C,8,7,0,2,1,2
	dc.b	2,2,$A,3,9,8,3,5,0,0
	dc.b	2,5,7,5,7,$B,4,1,0,0
	dc.b	1,3,6,$E,6,8,4,0,0,0
	dc.b	4,$D,$A,5,3,4,3,0,0,0
	dc.b	1,4,8,8,$A,4,3,0,3,1
	dc.b	0,1,$B,$A,8,5,3,2,1,1
	dc.b	2,5,9,6,4,8,4,2,2,0
	dc.b	0,9,7,9,$A,1,3,1,1,1
	dc.b	1,0,5,$F,9,5,5,2,0,0
	dc.b	5,8,4,$A,$E,1,0,0,0,0
	dc.b	4,3,5,8,$A,4,5,3,0,0
	dc.b	0,5,9,$D,8,3,4,0,0,0
	dc.b	2,4,$B,$D,5,2,5,0,0,0
	dc.b	4,4,6,$B,8,3,3,1,1,1

SimGoalsAwayDef	;IDA: loc_91D84. 95 only. 26 x 10: away defense
	dc.b	6,5,9,$A,5,2,4,1,0,0
	dc.b	2,6,6,$A,8,5,3,1,1,0
	dc.b	3,4,4,$F,4,6,3,3,0,0
	dc.b	0,3,9,$A,$B,4,4,1,0,0
	dc.b	2,8,8,$E,4,3,1,2,0,0
	dc.b	3,2,$C,$A,3,6,4,1,0,1
	dc.b	0,2,5,$A,$B,4,6,2,1,1
	dc.b	1,$B,8,8,9,4,0,1,0,0
	dc.b	1,6,$A,$F,4,5,1,0,0,0
	dc.b	3,7,$E,9,5,2,2,0,0,0
	dc.b	4,4,$A,9,8,4,2,1,0,0
	dc.b	3,5,8,$C,8,4,0,1,1,0
	dc.b	0,9,8,8,2,5,7,2,1,0
	dc.b	1,7,5,$E,6,6,1,1,1,0
	dc.b	0,6,8,5,$D,7,0,2,1,0
	dc.b	4,8,$F,6,3,3,1,2,0,0
	dc.b	4,2,8,9,9,5,4,0,0,1
	dc.b	0,4,7,$F,$A,2,3,1,0,0
	dc.b	3,7,$A,8,6,6,1,1,1,0
	dc.b	3,4,$F,9,6,3,0,1,1,0
	dc.b	4,7,9,$D,5,3,0,0,0,1
	dc.b	3,9,3,$C,$A,4,1,0,0,0
	dc.b	1,3,$B,$D,6,4,4,0,0,0
	dc.b	1,5,7,9,9,5,4,1,1,0
	dc.b	4,9,7,7,7,5,1,0,1,1
	dc.b	1,5,8,7,$D,5,3,0,0,0

SimGoalsAway	;no IDA label. 95 only. 26 x 10: away offense
	dc.b	1,7,7,$C,7,5,2,1,0,0
	dc.b	1,6,8,$10,6,3,0,0,2,0
	dc.b	5,$A,6,$A,3,5,3,0,0,0
	dc.b	4,4,$D,7,7,5,2,0,0,0
	dc.b	4,8,7,6,7,5,4,0,0,1
	dc.b	4,6,8,$C,5,2,4,1,0,0
	dc.b	3,6,9,$A,7,3,3,1,0,0
	dc.b	1,3,6,$E,6,7,4,1,0,0
	dc.b	1,8,$B,$A,7,4,0,1,0,0
	dc.b	3,3,7,$F,7,4,2,1,0,0
	dc.b	2,5,7,6,7,9,5,0,1,0
	dc.b	2,7,$B,$A,6,5,1,0,0,0
	dc.b	4,7,$C,$A,7,2,0,0,0,0
	dc.b	4,4,$C,7,9,5,1,0,0,0
	dc.b	5,7,9,9,8,1,2,1,0,0
	dc.b	0,4,2,6,$B,7,5,4,2,1
	dc.b	1,2,8,$D,8,7,0,2,0,1
	dc.b	1,6,$C,9,6,4,1,2,0,1
	dc.b	1,5,7,7,$C,5,5,0,0,0
	dc.b	3,4,$B,$B,6,0,4,0,2,1
	dc.b	0,7,8,7,$A,8,2,0,0,0
	dc.b	1,5,$A,$D,7,3,2,1,0,0
	dc.b	1,8,9,$E,6,2,1,1,0,0
	dc.b	2,6,6,$C,7,4,3,1,1,0
	dc.b	2,4,8,9,6,5,0,6,2,0
	dc.b	1,6,$A,$B,7,2,4,1,0,0

SimGoalsHomeDef	;IDA: loc_91F8C. 95 only. 26 x 10: home defense
	dc.b	2,6,9,9,$A,5,1,0,0,0
	dc.b	4,7,6,$B,3,5,4,2,0,0
	dc.b	4,1,$10,$C,6,1,1,1,0,0
	dc.b	1,6,6,$C,9,1,5,1,1,0
	dc.b	3,6,$B,9,7,5,1,0,0,0
	dc.b	1,2,$A,$B,9,6,1,0,0,2
	dc.b	1,5,4,$B,$B,3,5,0,1,1
	dc.b	0,3,6,7,$F,5,5,1,0,0
	dc.b	1,8,$A,9,$A,2,1,1,0,0
	dc.b	0,6,9,3,9,6,6,1,1,1
	dc.b	0,1,5,$A,$C,5,5,2,2,0
	dc.b	5,6,$A,5,3,7,2,0,2,2
	dc.b	1,6,$D,$C,4,1,4,0,1,0
	dc.b	1,3,7,$A,$A,7,2,2,0,0
	dc.b	3,5,8,$D,8,2,3,0,0,0
	dc.b	0,1,4,5,8,$A,7,2,3,2
	dc.b	2,1,6,$A,7,8,5,1,1,1
	dc.b	2,4,7,$A,7,3,2,5,1,1
	dc.b	2,1,$D,6,7,9,4,1,0,0
	dc.b	0,6,$B,$B,4,6,3,1,0,0
	dc.b	1,7,9,8,7,2,3,1,1,3
	dc.b	4,7,$B,6,3,5,3,1,2,0
	dc.b	2,6,6,$C,8,6,2,0,0,0
	dc.b	1,5,$A,$A,5,5,2,3,1,0
	dc.b	0,2,4,7,7,8,9,4,0,1
	dc.b	3,7,9,7,4,3,6,2,1,0

SimTieTbl	;IDA: loc_92090. 95 only. Tie break weights, 3 a team (26 teams)
	dc.b	6,4,0
	dc.b	3,7,5
	dc.b	4,$A,4
	dc.b	4,$B,4
	dc.b	3,$C,1
	dc.b	0,$A,0
	dc.b	0,9,2
	dc.b	4,8,5
	dc.b	6,4,0
	dc.b	9,6,3
	dc.b	1,$A,2
	dc.b	3,6,5
	dc.b	0,7,4
	dc.b	3,7,3
	dc.b	4,$B,2
	dc.b	6,4,0
	dc.b	2,$B,4
	dc.b	0,7,3
	dc.b	1,$A,4
	dc.b	5,2,3
	dc.b	4,$B,2
	dc.b	4,7,3
	dc.b	1,$B,1
	dc.b	0,9,1
	dc.b	2,7,2
	dc.b	2,7,2
