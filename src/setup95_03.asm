;	NHL 95 setup95_03. Retail $0A00D6-$0A0B3D (2664 bytes).
;	Mapped to setup94 (58%): StartScoutText, ScoutTextPlayer, ScoutTextNextLine; moved in: CompareHotColdTotals, GetHotColdTotal, the hot / cold
;	player lists (crowd94), PrintPlayerNameRight, GetTeamRating / TeamRatings (period94), HotColdIcon (title94), GetTeamArena / GetTeamNickname
;	(scout94), ScoutTextScript (graphics94), GetPlayerPicture (94 DrawPlayerPicture, cards94); 95 only: the users lists of the scouting text
;	(GetHomeUsers ... UserNameString).
;	IDA left CompareHotColdTotals / GetHotColdTotal and ScoutTextScript as dc.b and hid printz Strings; they are written from the retail bytes.
;	$20xxxx addresses are save RAM (odd bytes).
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

StartScoutText	;IDA: sub_A00D6. setup94 StartScoutText. Start the text player ScoutTextPlayer: VertLineScrolling = -1, PlayerScrollCtr = -1, clear SelectedPlayerIdx / typedelay; a0 = TestList (the script line list)
	move.w	#$FFFF,(VertLineScrolling).w
	st	(PlayerScrollCtr).w
	clr.w	(SelectedPlayerIdx).w
	clr.w	(typedelay).w
	movea.l	#setupvalues,a0
	rts

ScoutTextPlayer	;IDA: sub_A00F0. setup94 ScoutTextPlayer. Text player of ScoutingReport: types the ScoutTextScript lines of TestList word by word with a
	;typing delay (typedelay, longer after , and .); $D ends a line; the special characters insert Strings (team names, arena, hot / cold players,
	;user names); line breaks scroll the text box (ScoutTextNextLine)
	cmpi.w	#$1000,(typedelay).w
	bgt.w	.13
	tst.w	(asv).w
	bmi.w	.0
	subq.w	#1,(typedelay).w
	bpl.w	.13
.0
	movea.l	#ScoutTextScript,a1
	move.w	(PlayerScrollCtr).w,d0
	bpl.w	.4
	clr.w	(DispAttribCtr).w
	move.w	(SelectedPlayerIdx).w,d0
	addq.w	#2,(SelectedPlayerIdx).w
	movea.w	#(setupvalues-M68K_RAM),a0
	move.w	(a0,d0.w),d0
	bpl.w	.1
	move.w	#$7FFF,(typedelay).w
	move.w	#$1E0,(screentimer).w
	rts
.1
	bsr.w	ScoutTextNextLine
	movea.l	a1,a2
	bra.w	.3
.2
	cmpi.b	#$D,(a2)+
	bne.s	.2
.3
	dbf	d0,.2
	suba.l	a1,a2
	move.w	a2,d0
.4
	lea	(a1,d0.w),a2
	move.w	#$A,(typedelay).w
	move.w	(DispAttribCtr).w,d0
	cmpi.b	#$24,(a2)
	beq.w	.24
	cmpi.b	#$7B,(a2)
	beq.w	.34
	cmpi.b	#$7D,(a2)
	beq.w	.33
	cmpi.b	#$5B,(a2)
	beq.w	.27
	cmpi.b	#$5D,(a2)
	beq.w	.26
	cmpi.b	#$3C,(a2)
	beq.w	.20
	cmpi.b	#$3E,(a2)
	beq.w	.21
	cmpi.b	#$7C,(a2)
	beq.w	.22
	cmpi.b	#$5C,(a2)
	beq.w	.23
	cmpi.b	#$23,(a2)
	beq.w	.14
	cmpi.b	#$25,(a2)
	beq.w	.15
	cmpi.b	#$3D,(a2)
	beq.w	.16
	cmpi.b	#$2A,(a2)
	beq.w	.17
	cmpi.b	#$5E,(a2)
	beq.w	.18
	cmpi.b	#$3B,(a2)
	beq.w	.19
	st	(PlayerScrollCtr).w
	movea.w	#(TextBuffer-M68K_RAM),a0
	clr.w	d1
.5
	cmpi.b	#$D,(a2)
	beq.w	.9
	addq.w	#1,d0
.6
	move.b	(a2),(a0)+
	addq.w	#1,d1
	cmpi.b	#$2C,(a2)
	beq.w	.7
	cmpi.b	#$2E,(a2)
	bne.w	.8
.7
	addi.w	#$28,(typedelay).w
.8
	cmpi.b	#$20,(a2)+
	bne.s	.5
	cmpi.b	#$20,(a2)
	beq.s	.6
	subq.w	#1,d0
	suba.w	a1,a2
	move.w	a2,(PlayerScrollCtr).w
.9
	move.w	d1,(mesarea).w
	addq.w	#2,(mesarea).w
	btst	#0,d1
	beq.w	.10
	clr.b	(a0)
	addq.w	#1,(mesarea).w
.10
	movea.w	#(mesarea-M68K_RAM),a1
.11
	cmp.w	#$18,d0
	ble.w	.12
	bsr.w	ScoutTextNextLine
.12
	jsr	(printz).l
	String	$FF,$B,$6,$0
	move.w	(DispAttribCtr).w,d0
	add.w	d0,(printx).w
	move.w	(VertLineScrolling).w,d0
	add.w	d0,(printy).w
	jsr	(print).l
	add.w	d1,(DispAttribCtr).w
rtsScoutText	equ	*	;IDA: locret_A026A. setup94 rtss2. Shared rts of ScoutTextPlayer / ScoutTextNextLine
.13
	rts
.14
	bsr.w	NextHomeUser
	bra.w	.36
.15
	bsr.w	NextAwayUser
	bra.w	.36
.16
	move.l	a2,-(sp)
	movea.l	#HmShots,a2
	jsr	(GetTeamNickname).l
	movea.l	(sp)+,a2
	bra.w	.36
.17
	move.l	a2,-(sp)
	movea.l	#AwShots,a2
	jsr	(GetTeamNickname).l
	movea.l	(sp)+,a2
	bra.w	.36
.18
	move.l	a2,-(sp)
	movea.l	#HmShots,a2
	jsr	(GetTeamArena).l
	movea.l	(sp)+,a2
	bra.w	.36
.19
	move.l	a2,-(sp)
	movea.l	#AwShots,a2
	jsr	(GetTeamArena).l
	movea.l	(sp)+,a2
	bra.w	.36
.20
	jsr	(NextHomeHotPlayer).l
	bra.w	.29
.21
	jsr	(NextAwayHotPlayer).l
	bra.w	.29
.22
	jsr	(NextHomeColdPlayer).l
	bra.w	.29
.23
	jsr	(NextAwayColdPlayer).l
	bra.w	.29
.24
	movea.l	#HmShots,a1
	tst.w	(awayhotter).w
	beq.w	.25
	movea.l	#AwShots,a1
.25
	movea.l	$1E(a1),a1
	adda.w	4(a1),a1
	bra.w	.36
.26
	movea.w	#(AwShots-M68K_RAM),a1
	bra.w	.28
.27
	movea.w	#(HmShots-M68K_RAM),a1
.28
	move.w	$26(a1),d1
.29
	movea.l	$1E(a1),a1
	adda.w	(a1),a1
	bra.w	.31
.30
	adda.w	(a1),a1
	addq.w	#8,a1
.31
	dbf	d1,.30
	bra.w	.36
.32
	movea.l	(AwayTeamRosterPtr).w,a1
	adda.w	4(a1),a1
	bra.w	.36
.33
	movea.l	(AwayTeamRosterPtr).w,a1
	bra.w	.35
.34
	movea.l	(HomeTeamRosterPtr).w,a1
.35
	adda.w	4(a1),a1
.36
	addq.w	#1,(PlayerScrollCtr).w
	add.w	(a1),d0
	subq.w	#1,d0
	move.w	(a1),d1
	subq.w	#2,d1
	tst.b	1(a1,d1.w)
	bne.w	.11
	subq.w	#1,d1
	bra.w	.11

ScoutTextNextLine	;IDA: sub_A0370. setup94 ScoutTextNextLine. Next text line of ScoutTextPlayer; at 7 lines scroll the 8 rows up
	clr.w	(DispAttribCtr).w
	addq.w	#1,(VertLineScrolling).w
	cmpi.w	#7,(VertLineScrolling).l
	blt.w	rtsScoutText
	subq.w	#1,(VertLineScrolling).w
	movem.l	d0-d3,-(sp)
	move.l	#7,d3
	move.w	(VmMap1).w,d1
	addi.w	#$316,d1
.0
	move.l	#$30,d0
	move.w	d1,d2
	addi.w	#$80,d2
	jsr	(DoDMA_nd2).l
	move.w	d2,d1
	dbf	d3,.0
	movem.l	(sp)+,d0-d3
	rts

CompareHotColdTotals	;no IDA label. crowd94 CompareHotColdTotals. Compare the hot / cold totals of the teams (GetHotColdTotal): d0 = $22 / $23 (the better team, awayhotter) when they differ enough, else -1
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	#HmShots,a0
	bsr.w	GetHotColdTotal
	move.w	d1,(TempWord1).w
	movea.l	#AwShots,a0
	bsr.w	GetHotColdTotal
	move.w	d1,(TempWord2).w
	move.w	(TempWord1).w,d1
	move.w	(TempWord2).w,d2
	sub.w	d1,d2
	move.w	#0,(awayhotter).w
	tst.w	d2
	bmi.w	.0
	move.w	#1,(awayhotter).w
.0
	tst.w	d2
	bpl.w	.1
	neg.w	d2
.1
	move.w	#$FFFF,d0
	cmp.w	#$5E,d2
	blt.w	.2
	move.w	#$22,d0
	cmp.w	#$BD,d2
	blt.w	.2
	move.w	#$23,d0
.2
	movem.l	(sp)+,d1-d7/a0-a6
	rts

GetHotColdTotal	;no IDA label. crowd94 GetHotColdTotal. d1 = the hot / cold total of the starters of team a0 (SortHotColdStarters, TempBuffer)
	bsr.w	SortHotColdStarters
	move.w	#6,d0
	movea.l	#linemarkbuf,a0
	clr.w	d1
.0
	move.b	1(a0),d2
	ext.w	d2
	add.w	d2,d1
	tst.w	(a0)+
	dbf	d0,.0
	rts

PrintPlayerNameRight	;IDA: sub_A043E. period94 PrintPlayerNameRight. Print the name of player d0 of team a2 ending before column $29, then HotColdIcon
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	d0,(iconplayer).w
	move.l	a2,-(sp)
	jsr	(FormatPlayerName).l
	movea.l	a1,a0
	move.w	(a0),d0
	move.w	d0,d5
	tst.b	-1(a0,d5.w)
	bne.w	.0
	subq.w	#1,d0
	tst.b	-2(a0,d5.w)
	bne.w	.0
	subq.w	#1,d0
.0
	add.w	(printx).w,d0
	subi.w	#$29,d0
	bmi.w	.1
	neg.w	d0
	add.w	d0,(printx).w
.1
	movea.l	a0,a1
	jsr	(print).l
	movea.l	(sp)+,a2
	jsr	(HotColdIcon).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

HotColdIcon	;IDA: sub_A0490. title94 HotColdIcon. The hot or cold icon by player iconplayer of team a2, or erase it
	movem.l	d0/a0-a1,-(sp)
	movea.l	#awayhotplayer,a0
	move.w	#1,(iconplayer+$2).w
	cmpa.l	#HmShots,a2
	bne.w	.0
	movea.l	#homehotplayer,a0
	move.w	#$1C,(iconplayer+$2).w
.0
	move.w	#0,d0
.1
	move.w	(a0)+,d1
	cmp.w	(iconplayer).w,d1
	beq.w	.4
	dbf	d0,.1
	movea.l	#awaycoldplayer,a0
	cmpa.l	#HmShots,a2
	bne.w	.2
	movea.l	#homecoldplayer,a0
.2
	move.w	#0,d0
.3
	move.w	(a0)+,d1
	cmp.w	(iconplayer).w,d1
	beq.w	.5
	dbf	d0,.3
	move.w	(iconplayer+$2).w,(printx).w
	move.w	#$11,(printy).w
	move.w	#2,d0
	move.w	#6,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	bra.w	.7
.4
	move.w	(hoticonchars).w,d4
	movea.l	#HotIconMap,a0
	bra.w	.6
.5
	move.w	(coldiconchars).w,d4
	movea.l	#ColdIconMap,a0
.6
	move.w	(iconplayer+$2).w,(printx).w
	move.w	#$11,(printy).w
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	movea.w	#$69A,a2
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
.7
	movem.l	(sp)+,d0/a0-a1
	rts

NextHomeHotPlayer	;IDA: sub_A055A. crowd94 NextHomeHotPlayer. d1 = the next home hot player (homehotidx, homehotplayer)
	movem.l	d0/a0,-(sp)
	movea.l	#homehotplayer,a0
	move.w	(homehotidx).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	cmpi.w	#0,(homehotidx).w
	bge.w	.0
	addq.w	#1,(homehotidx).w
.0
	movem.l	(sp)+,d0/a0
	movea.l	#HmShots,a1
	rts

NextAwayHotPlayer	;IDA: sub_A0588. crowd94 NextAwayHotPlayer. The same for the away team (awayhotidx, awayhotplayer)
	movem.l	d0/a0,-(sp)
	movea.l	#awayhotplayer,a0
	move.w	(awayhotidx).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	cmpi.w	#0,(awayhotidx).w
	bge.w	.0
	addq.w	#1,(awayhotidx).w
.0
	movem.l	(sp)+,d0/a0
	movea.l	#AwShots,a1
	rts

NextHomeColdPlayer	;IDA: sub_A05B6. crowd94 NextHomeColdPlayer. d1 = the next home cold player (homecoldidx, homecoldplayer)
	movem.l	d0/a0,-(sp)
	movea.l	#homecoldplayer,a0
	move.w	(homecoldidx).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	cmpi.w	#0,(homecoldidx).w
	bge.w	.0
	addq.w	#1,(homecoldidx).w
.0
	movem.l	(sp)+,d0/a0
	movea.l	#HmShots,a1
	rts

NextAwayColdPlayer	;IDA: sub_A05E4. crowd94 NextAwayColdPlayer. The same for the away team (awaycoldidx, awaycoldplayer)
	movem.l	d0/a0,-(sp)
	movea.l	#awaycoldplayer,a0
	move.w	(awaycoldidx).w,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d1
	cmpi.w	#0,(awaycoldidx).w
	bge.w	.0
	addq.w	#1,(awaycoldidx).w
.0
	movem.l	(sp)+,d0/a0
	movea.l	#AwShots,a1
	rts

GetTeamArena	;IDA: sub_A0612. scout94 GetTeamArena. a1 = the arena String of team a2
	movem.l	d0/a0/a2,-(sp)
	movea.l	a2,a1
	movea.l	$1E(a1),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	movem.l	(sp)+,d0/a0/a2
	rts

GetTeamNickname	;IDA: sub_A062C. scout94 GetTeamNickname. a1 = the nickname String of team a2, or HomeTxt / VisitorsTxt when it is empty
	movem.l	d0/a0/a2,-(sp)
	movea.l	a2,a1
	movea.l	$1E(a1),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	adda.w	(a1),a1
	cmpi.w	#2,(a1)
	bne.w	.0
	movea.l	#HomeTxt,a1
	cmpa.l	#HmShots,a2
	beq.w	.0
	movea.l	#VisitorsTxt,a1
.0
	movem.l	(sp)+,d0/a0/a2
	rts

HomeTxt	;IDA: unk_A0662. scout94 HomeTxt
	String	'Home'

VisitorsTxt	;IDA: unk_A0668. scout94 VisitorsTxt
	String	'Visitors'

CopyHottestPlayer	;IDA: sub_A0672. crowd94 CopyHottestPlayer. Copy the hottest player of TempBuffer to the list a0
	movem.l	d0-d1/a0-a1,-(sp)
	movea.l	#linemarkbuf,a1
	move.w	#0,d0
.0
	clr.b	(a0)+
	move.b	(a1),d1
	move.b	d1,(a0)+
	tst.w	(a1)+
	dbf	d0,.0
	movem.l	(sp)+,d0-d1/a0-a1
	rts

CopyColdestPlayer	;IDA: sub_A0692. crowd94 CopyColdestPlayer. Copy the coldest player of TempBuffer to the list a0
	movem.l	d0/a0-a1,-(sp)
	movea.l	#TempBuffer+$A,a1
	move.w	#0,d0
.0
	clr.b	(a0)+
	move.b	(a1),(a0)+
	tst.w	-(a1)
	dbf	d0,.0
	movem.l	(sp)+,d0/a0-a1
	rts

GetTeamRating	;IDA: sub_A06B0. period94 GetTeamRating. d0 = the rating byte of team $28(a2): TeamRatingsLine with OptLine 1, else TeamRatings
	movem.l	d1-d7/a0-a6,-(sp)
	move.w	$28(a2),d0
	movea.l	#TeamRatingsLine,a0
	cmpi.w	#1,(OptLine).w
	beq.w	.0
	movea.l	#TeamRatings,a0
.0
	clr.w	d1
	move.b	(a0,d0.w),d1
	move.w	d1,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

TeamRatingsLine	;IDA: unk_A06DC. 95 only. GetTeamRating values with OptLine 1, one byte per team
	dc.b	$3A,$4D,$4E,$4D,$53,$47,$4F,$45,$41,$40,$49,$4C,$49,$42,$4F
	dc.b	$3A,$47,$4E,$45,$46,$4F,$40,$4B,$4B,$46,$46,$58,$58,$63,$63

TeamRatings	;IDA: unk_A06FA. period94 TeamRatings. GetTeamRating values, one byte per team (TeamList order)
	dc.b	$32,$45,$4C,$46,$48,$42,$45,$3C,$3B,$3E,$3D,$40,$45,$3B,$4D
	dc.b	$30,$3F,$48,$43,$3F,$41,$37,$45,$45,$42,$40,$4E,$50,$63,$63

ScoutTextScript	;IDA: unk_A0718. graphics94 ScoutTextScript. The scouting text lines, each ended by $D, $FF after the last; ScoutTextPlayer skips n $D for line n
	;substitution chars: ^ arena  = home team  * away team  } away (alt intro)  < > | \ hot/cold players  # home user name (sub_A09DA)  % away user name (sub_A09CC)
	dc.b	$D;line 0
	dc.b	'Hi, I',$27,'m John Shrader for EA Sports.  Welcome to a sold out ^, home of the =.  Tonight the = take on the *.',$D;line 1
	dc.b	$D;line 2
	dc.b	'For the =, < is on a hot streak, but | is off his game. ',$D;line 3
	dc.b	'For the *, > is on a hot streak, but \ is off his game. ',$D;line 4
	dc.b	'Hit the start button to begin.  Use the A and C buttons to cycle through matchups.',$D;line 5
	dc.b	'The = are played by:',$D;line 6
	dc.b	' # ',$D;line 7
	dc.b	'The * are played by...',$D;line 8
	dc.b	' % ',$D;line 9
	dc.b	'Hi, I',$27,'m John Shrader for EA Sports.  Welcome to a sold out ^.  Tonight the = take on the }.',$D;line 10
	dc.b	$D;line 11
	dc.b	$FF;end of script

GetHomeUsers	;IDA: sub_A08DC. 95 only. homeusers = the count, then the name log entries of the pads on the home team (pad1user ... pad4user)
	move.l	a0,-(sp)
	movea.l	#homeusers+1,a0
	clr.b	(ThreeStars).w
	cmpi.w	#1,(cont1team).w
	bne.w	.0
	tst.w	(pad1user).w
	beq.w	.0
	addq.b	#1,(ThreeStars).w
	move.b	(pad1user+1).w,(a0)+
.0
	cmpi.w	#1,(cont2team).w
	bne.w	.1
	tst.w	(pad2user).w
	beq.w	.1
	addq.b	#1,(ThreeStars).w
	move.b	(pad2user+1).w,(a0)+
.1
	cmpi.w	#1,(cont3team).w
	bne.w	.2
	tst.w	(pad3user).w
	beq.w	.2
	addq.b	#1,(ThreeStars).w
	move.b	(pad3user+1).w,(a0)+
.2
	cmpi.w	#1,(cont4team).w
	bne.w	.3
	tst.w	(pad4user).w
	beq.w	.3
	addq.b	#1,(ThreeStars).w
	move.b	(pad4user+1).w,(a0)+
.3
	movea.l	(sp)+,a0
	rts

GetAwayUsers	;IDA: sub_A0954. 95 only. awayusers: the same for the away team
	move.l	a0,-(sp)
	movea.l	#awayusers+1,a0
	clr.b	(CalMonths).w
	cmpi.w	#2,(cont1team).w
	bne.w	.0
	tst.w	(pad1user).w
	beq.w	.0
	addq.b	#1,(CalMonths).w
	move.b	(pad1user+1).w,(a0)+
.0
	cmpi.w	#2,(cont2team).w
	bne.w	.1
	tst.w	(pad2user).w
	beq.w	.1
	addq.b	#1,(CalMonths).w
	move.b	(pad2user+1).w,(a0)+
.1
	cmpi.w	#2,(cont3team).w
	bne.w	.2
	tst.w	(pad3user).w
	beq.w	.2
	addq.b	#1,(CalMonths).w
	move.b	(pad3user+1).w,(a0)+
.2
	cmpi.w	#2,(cont4team).w
	bne.w	.3
	tst.w	(pad4user).w
	beq.w	.3
	addq.b	#1,(CalMonths).w
	move.b	(pad4user+1).w,(a0)+
.3
	movea.l	(sp)+,a0
	rts

NextAwayUser	;IDA: sub_A09CC. 95 only. Scout text %: a1 = the name String of the last away user (UserNameString), the count down one
	movem.l	d0-d1/a0,-(sp)
	movea.l	#CalMonths,a0
	bra.w	PopUserName

NextHomeUser	;IDA: sub_A09DA. 95 only. Scout text #: the same for the home users
	movem.l	d0-d1/a0,-(sp)
	movea.l	#ThreeStars,a0

PopUserName	;IDA: loc_A09E4. 95 only. NextHomeUser / NextAwayUser: pop the last entry of the list a0 (count byte first) as a name String (UserNameString)
	move.b	(a0),d0
	ext.w	d0
	subq.b	#1,(a0)
	move.b	(a0,d0.w),d1
	ext.w	d1
	bsr.w	UserNameString
	movem.l	(sp)+,d0-d1/a0
	rts

UserNameString	;IDA: sub_A09FA. 95 only. a1 = NameEntryBuf: the name of name log entry d1 (GetLogName) as a String
	movea.l	#NameEntryBuf+2,a1
	move.w	d1,(CreateListRow).w
	jsr	(GetLogName).l
	adda.w	(NameEntryLen).w,a1
	move.b	#0,(a1)
	addq.w	#1,(NameEntryLen).w
	andi.w	#$FFFE,(NameEntryLen).w
	addq.w	#2,(NameEntryLen).w
	move.w	(NameEntryLen).w,(NameEntryBuf).w
	movea.l	#NameEntryBuf,a1
	rts

NullSaveClear	;IDA: nullsub_7. 95 only. Does nothing (sram95 calls it)
	rts

GetPlayerPicture	;IDA: sub_A0A30. cards94 DrawPlayerPicture. 95: only the picture: a0 = the picture of player d0 of team d1 (the team picture by jersey number, else a generic one)
	movem.l	d0-d7/a1-a6,-(sp)
	btst	#6,(sflags11).w
	beq.w	.0
	movea.l	#TeamList,a0
	move.w	d1,d7
	asl.w	#2,d1
	movea.l	(a0,d1.w),a0
	adda.w	6(a0),a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	subq.w	#1,d0
	bra.w	.1
.0
	movea.l	#$207C28,a0
	move.w	d1,d7
	mulu.w	#$82,d1
	adda.l	d1,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	ext.w	d0
	subq.w	#1,d0
.1
	move.w	d0,-(sp)
	jsr	(ReadAttributeNibbleD7).l
	clr.w	(rosterteam).w
	cmp.w	(sp),d0
	bgt.w	.2
	move.w	#$FFFF,(rosterteam).w
.2
	move.w	(sp)+,d0
	jsr	(GetRosterId).l
	move.w	d0,d1
	lsr.w	#8,d1
	andi.w	#$1F,d1
	cmp.w	#$1E,d1
	beq.w	.5
	move.w	d0,d5
	andi.w	#$FF,d0
	addq.w	#1,d0
	move.w	d1,d2
	movea.l	#TeamList,a0
	asl.w	#2,d2
	movea.l	(a0,d2.w),a0
	adda.w	6(a0),a0
	clr.w	d4
.3
	cmp.b	(a0)+,d0
	beq.w	.4
	addq.w	#1,d4
	cmp.w	#6,d4
	blt.s	.3
	move.w	d5,d0
	bra.w	.5
.4
	movea.l	#FeaturedPicIdx,a0
	mulu.w	#6,d1
	adda.l	d1,a0
	move.b	(a0,d4.w),d4
	andi.w	#$FF,d4
	asl.w	#2,d4
	movea.l	#FeaturedPictures,a0
	movea.l	(a0,d4.w),a0
	bra.w	.7
.5
	jsr	(GetCreatedName).l
	adda.w	(a1),a1
	move.b	4(a1),d3
	btst	#0,d3
	bne.w	.6
	movea.l	#NoPicSkater1,a0
	tst.w	(rosterteam).w
	bne.w	.7
	movea.l	#NoPicGoalie2,a0
	bra.w	.7
.6
	movea.l	#NoPicSkater2,a0
	tst.w	(rosterteam).w
	bne.w	.7
	movea.l	#NoPicGoalie1,a0
.7
	movem.l	(sp)+,d0-d7/a1-a6
	rts
