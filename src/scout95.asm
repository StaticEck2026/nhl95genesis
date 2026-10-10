;	NHL 95 scout95. Retail $09F590-$0A00D5 (2886 bytes).
;	Mapped to scout94 (85%): ScoutingReport, PageMatchup ... MatchupLineSlots; moved in: BuildHotColdLists and SortHotColdStarters (crowd94).
;	IDA hid the printz / printbigz Strings and the remap bytes after DecompressGraphicsWithCallback as instructions; they are written from
;	the retail bytes.
;	$20xxxx addresses are save RAM (odd bytes).
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

ScoutingReport	;IDA: loc_9F590. scout94 ScoutingReport (93 name). Pregame scouting report: the Ron Barr picture, the text box and the matchups (0 the
	;teams, 1-6 the players by position) with their ratings and the advantage marks; the text player (ScoutTextPlayer) types
	;the paragraph list, with the user names of each team (GetHomeUsers / GetAwayUsers). A / C page the matchups, down types fast, start leaves
	jsr	(ReadNameLog).l
	jsr	(BuildHotColdLists).l
	clr.w	(advframe).w
	jsr	(play_new_song).l
	move.w	#9,d0
	jsr	(SoundCmd).l
	move.w	#0,d0
	move.w	#$1B63,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#0,d1
	jsr	(SoundCmd).l
	move.w	#3,-(sp)
	jsr	(song).l
	move.l	#vb2,(vbint).w
	jsr	(clearTeamStats).l
	move.l	a0,-(sp)
	movea.l	#HmShots,a0
	jsr	(Create_HotCold_Table).l
	movea.l	#AwShots,a0
	jsr	(Create_HotCold_Table).l
	movea.l	(sp)+,a0
	jsr	(BuildHotColdLists).l
	bclr	#1,(disflags).w
	move.w	#6,(Map1col1).w
	move.w	#6,(Map2col1).w
	move.w	#0,d0
	jsr	(setvram).l
	move.w	#2,d4
	move.w	d4,(homepicchars).w
	addi.w	#$24,d4
	move.w	d4,(vispicchars).w
	addi.w	#$24,d4
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	d4,(smallfontchars).w
	movea.l	(smallfontptr).w,a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$44,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$83,$4C,$67,$89,$AB,$CD,$EF
	jsr	(printz).l
	String	$FE,0,0,0
	movea.l	#ScoutReportMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#1,d5
	jsr	(dobitmap).l
	move.w	#0,(printfontset).w
	jsr	(printz).l
	String	$FF,$10,$11,'ADVANTAGE:',0
	jsr	(printz).l
	String	$DE,6,3,0
	moveq	#$21,d0
	moveq	#9,d1
	jsr	(printz).l
	String	$DE,3,$10,0
	move.w	#8,d0
	move.w	#8,d1
	jsr	(printz).l
	String	$DE,$1E,$10,0
	move.w	#8,d0
	move.w	#8,d1
	jsr	(printz).l
	String	$FF,0,0,0
	movea.l	#RonBarrMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	movea.l	#HotIconMap+8,a2
	move.w	d4,(hoticonchars).w
	jsr	(DoDMA_clearCallbackPointer).l
	movea.l	#ColdIconMap+8,a2
	move.w	d4,(coldiconchars).w
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(printbigz).l
	String	$BF,9,2,'Scouting Report'
	clr.w	(matchup).w
	clr.w	(scoutunused).w
	move.w	#$10D,(matchuptimer).l
	bsr.w	GetMatchupPlayers
	bsr.w	DrawMatchupPictures
.0
	bsr.w	PrintMatchupRatings
	move.w	#$18,(palcount).w
	move.l	#vb2,(vbint).w
	move	#$2500,sr
	jsr	(StartScoutText).l
	cmpi.w	#$1A,(HomeTeam).w
	beq.w	.1
	cmpi.w	#$1B,(HomeTeam).w
	bne.w	.2
.1
	move.w	#$A,(a0)+
	bra.w	.3
.2
	move.w	#1,(a0)+
.3
	move.w	#2,(a0)+
	bsr.w	GetHomeUsers
	tst.b	(homeusers).w
	beq.w	.5
.4
	move.w	#6,(a0)+
	move.w	#7,(a0)+
	cmpi.b	#2,(homeusers).w
	blt.w	.5
	move.w	#7,(a0)+
	cmpi.b	#3,(homeusers).w
	blt.w	.5
	move.w	#7,(a0)+
	cmpi.b	#4,(homeusers).w
	blt.w	.5
	move.w	#7,(a0)+
.5
	bsr.w	GetAwayUsers
	tst.b	(awayusers).w
	beq.w	.6
	move.w	#8,(a0)+
	move.w	#9,(a0)+
	cmpi.b	#2,(awayusers).w
	blt.w	.6
	move.w	#9,(a0)+
	cmpi.b	#3,(awayusers).w
	blt.w	.6
	move.w	#9,(a0)+
	cmpi.b	#4,(awayusers).w
	blt.w	.6
	move.w	#9,(a0)+
.6
	move.w	#3,(a0)+
	move.w	#2,(a0)+
	move.w	#4,(a0)+
	move.w	#2,(a0)+
	move.w	#5,(a0)+
	move.w	#$FFFF,(a0)
	clr.w	(asv).w
	move.w	#$7F00,(screentimer).w
	move.l	#$E10,(scoutwait).w
.7
	moveq	#0,d0
	jsr	(waitx).l
	subq.w	#1,(matchuptimer).w
	bpl.w	.8
	move.w	#$10E,(matchuptimer).l
.8
	bsr.w	PrintAdvantageMarks
	btst	#7,d1
	bne.w	.14
	cmpi.w	#$10E,(matchuptimer).w
	beq.w	.9
	btst	#5,d1
	beq.w	.10
	move.w	#$7F00,(screentimer).w
	move.l	#$E10,(scoutwait).w
.9
	bsr.w	RestartAdvantageMarks
	move.w	#1,d0
	bsr.w	PageMatchup
	bra.w	.12
.10
	btst	#6,d1
	beq.w	.11
	move.w	#$7F00,(screentimer).w
	move.l	#$E10,(scoutwait).w
	bsr.w	RestartAdvantageMarks
	move.w	#$FFFF,d0
	bsr.w	PageMatchup
	bra.w	.12
.11
	clr.w	(asv).w
	btst	#1,d1
	beq.w	.12
	st	(asv).w
.12
	btst	#1,(waitxpad+1).w
	beq.w	.13
	st	(asv).w
.13
	jsr	(ScoutTextPlayer).l
	subq.w	#1,(screentimer).w
	bpl.w	.7
	tst.w	(OptNOP).w
	beq.w	.14
	move.w	#$FFFF,(screentimer).w
	jsr	(AnyPadAssigned).l
	bne.w	.7
	subq.l	#1,(scoutwait).w
	bpl.w	.7
.14
	move.w	#0,(printfontset).w
	rts

PageMatchup	;IDA: sub_9F950. scout94 PageMatchup. Page the matchup by d0 (+1 / -1, 0-6 wrapping), restart the page timer and redraw
	move.w	#$10E,(matchuptimer).w
	add.w	(matchup).w,d0
	bmi.w	.0
	cmp.w	#7,d0
	blt.w	.1
	clr.w	d0
	bra.w	.1
.0
	move.w	#6,d0
.1
	move.w	d0,(matchup).w
	bsr.w	GetMatchupPlayers
	bsr.w	DrawMatchupPictures
	bsr.w	PrintMatchupRatings
	rts

PrintMatchupRating	;IDA: sub_9F982. scout94 PrintMatchupRating. Print the team rating of team a0 (GetTeamRating) as 2 digits; d0 = the rating
	bsr.w	PrintTwoSpaces
	move.l	a2,-(sp)
	movea.l	a0,a2
	bsr.w	GetTeamRating
	movea.l	(sp)+,a2
	move.l	d0,-(sp)
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	move.l	(sp)+,d0
	rts

PrintTwoSpaces	;IDA: sub_9F9A6. scout94 PrintTwoSpaces. Print 2 spaces at printx / printy (TwoSpacesTxt) and keep printx
	move.l	a1,-(sp)
	move.w	(printx).w,-(sp)
	movea.l	#TwoSpacesTxt,a1
	jsr	(printsmall).l
	move.w	(sp)+,(printx).w
	movea.l	(sp)+,a1
	rts

TwoSpacesTxt	;IDA: unk_9F9C0. scout94 TwoSpacesTxt. A two space String
	String	'  '

StatsText	;no IDA label. scout94 StatsText (93 name). The rating names; -1 ends the list (PrintMatchupRatings)
	String	'Shooting'
	String	'Skating',0
	String	'Passing',0
	String	'Defense',0
	String	'Checking'
	String	'Fighting'
	String	'Goalkeeping',0
	String	'Power Play Adv.',0
	String	'-    Home Team Adv.    ',0
	String	'    Overall     '
	dc.w	-1

DrawMatchupPictures	;IDA: sub_9FA4E. scout94 DrawMatchupPictures. The matchup 6 x 6 pictures, visitors left, home right: matchup 0 the team logos, 1-6 the two players (MatchupLineSlots slot)
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(matchup).w
	bne.w	.0
	move.w	(VisTeam).w,d3
	bsr.w	GetMatchupLogo
	move.w	#4,(printx).w
	move.w	#$11,(printy).w
	move.w	(vispicchars).w,d4
	move.w	#4,d5
	move.w	#$6000,(printa).w
	bsr.w	DrawMatchupLogo
	move.w	(HomeTeam).w,d3
	bsr.w	GetMatchupLogo
	move.w	#$1F,(printx).w
	move.w	#$11,(printy).w
	move.w	(homepicchars).w,d4
	move.w	#0,(printa).w
	move.w	#2,d5
	bsr.w	DrawMatchupLogo
	move.w	#$64,(palcount).w
	bra.w	.1
.0
	move.w	(VisTeam).w,d1
	movea.l	#MatchupLineSlots,a0
	move.w	(matchup).w,d0
	move.b	(a0,d0.w),d0
	ext.w	d0
	jsr	(GetPlayerPicture).l
	move.w	#4,(printx).w
	move.w	#$11,(printy).w
	move.w	(vispicchars).w,d4
	move.w	#2,d5
	move.w	#0,(printa).w
	bsr.w	DrawMatchupPicture
	move.w	(HomeTeam).w,d1
	movea.l	#MatchupLineSlots,a0
	move.w	(matchup).w,d0
	move.b	(a0,d0.w),d0
	ext.w	d0
	jsr	(GetPlayerPicture).l
	move.w	#$1F,(printx).w
	move.w	#$11,(printy).w
	move.w	(homepicchars).w,d4
	move.w	#0,d5
	move.w	#0,(printa).w
	bsr.w	DrawMatchupPicture
	move.w	#$64,(palcount).w
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawMatchupPicture	;IDA: sub_9FB2C. scout94 DrawMatchupPicture. Draw player picture a0 at printx / printy with the NoPlayerPicture palettes; falls into DrawMatchupBitmap
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	movea.l	#NoPlayerPicture,a0
	adda.l	(a0),a0
	tst.l	(a2)
	bne.w	.0
	movea.l	#NoPlayerPicture,a1
	adda.l	4(a1),a1
	tst.l	(a2)+
	bra.w	.1
.0
	adda.l	(a2)+,a1
.1
	jsr	(UnpackPicture).l
	movea.l	#picturebuf,a2
	bra.w	DrawMatchupBitmap

DrawMatchupLogo	;IDA: sub_9FB62. scout94 DrawMatchupLogo. Draw team logo a0, palette TeamLogoPalettes + team d3 * 8 - $20 (d5 = 4: - $40); falls into DrawMatchupBitmap
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	asl.w	#3,d3
	cmp.w	#4,d5
	beq.w	.0
	subi.w	#$20,d3
	bra.w	.1
.0
	subi.w	#$40,d3
.1
	movea.l	#TeamLogoPalettes,a0
	adda.w	d3,a0
	adda.l	(a2)+,a1

DrawMatchupBitmap	;IDA: loc_9FB88. scout94 DrawMatchupBitmap. 6 x 6 dobitmap, then erase the name area at y $11 on that side (x 1 or $1C)
	move.w	#6,d3
	move.w	#6,d2
	clr.w	d0
	clr.w	d1
	jsr	(dobitmap).l
	cmpi.w	#$14,(printx).w
	bgt.w	.0
	move.w	#1,(printx).l
	bra.w	.1
.0
	move.w	#$1C,(printx).l
.1
	move.w	#$11,(printy).l
	move.w	#2,d0
	move.w	#6,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	rts

GetMatchupLogo	;IDA: sub_9FBD4. scout94 GetTeamLogo (video95_03 has the hockey94 GetTeamLogo). a0 = the logo bitmap of team d3 (TeamLogoBitmaps)
	asl.w	#2,d3
	movea.l	#TeamLogoBitmaps,a0
	movea.l	(a0,d3.w),a0
	rts

PrintMatchupRatings	;IDA: sub_9FBE2. scout94 PrintMatchupRatings. Matchup 0: the rating names (StatsText) and both team ratings;
	;1-6: the position (MatchupPosNames), the two players and their ratings
	tst.w	(matchup).w
	bne.w	.3
	jsr	(printz2).l
	String	$F8,$0,$1,$16,$16,$F9,$1,$0
	lea	StatsText(pc),a1
	move.w	#0,d7
.0
	move.w	(a1),d0
	asr.w	#1,d0
	neg.w	d0
	addi.w	#$16,d0
	move.w	d0,(printx).w
	cmp.w	#9,d7
	beq.w	.1
	adda.w	(a1),a1
	bra.w	.2
.1
	move.w	#2,(printfontset).w
	move.w	(printy).w,-(sp)
	subq.w	#3,(printy).w
	jsr	(printsmall).l
	move.w	(sp)+,(printy).w
.2
	addq.w	#1,d7
	tst.w	(a1)
	bpl.s	.0
	move.w	#2,(printfontset).w
	jsr	(printz).l
	String	$FF,$0,$19,'                                        ',$0
	jsr	(printz).l
	String	$FF,'!',$18,$0
	movea.l	#HmShots,a0
	movea.l	#AwShots,a2
	bsr.w	PrintMatchupRating
	move.w	d0,(homerating).w
	move.w	#2,(printfontset).w
	jsr	(printz).l
	String	$FF,$6,$18,$0
	exg	a0,a2
	bsr.w	PrintMatchupRating
	move.w	d0,(visrating).w
	bra.w	.8
.3
	move.w	(matchup).w,d0
	subq.w	#1,d0
	movea.l	#MatchupPosNames,a1
	bra.w	.5
.4
	adda.w	(a1),a1
.5
	dbf	d0,.4
	jsr	(printz2).l
	String	$F8,$0,$1,$C,$13,$F9,$1,$0
	jsr	(printsmall).l
	move.w	#$18,(printy).w
	move.w	#2,(printfontset).w
	movea.l	#HmShots,a2
	move.l	(PAttribOverallMask).l,d4
	tst.w	(matchupslot).w
	bne.w	.6
	move.l	(GAttribOverallMask).l,d4
.6
	move.w	(matchuphome).w,d0
	jsr	(printz).l
	String	$FF,$0,$19,'                                        ',$0
	jsr	(printz).l
	String	$FF,'"',$19,$0
	bsr.w	PrintPlayerNameRight
	jsr	(CalcAttrib).l
	mulu.w	#$64,d0
	divu.w	d1,d0
	jsr	(ScaleAttrib).l
	move.w	#2,d1
	move.w	d0,(homerating).w
	jsr	(PushNumberWidth).l
	jsr	(printz).l
	String	$FF,'!',$18,$0
	bsr.w	PrintTwoSpaces
	jsr	(printsmall).l
	movea.l	#AwShots,a2
	move.l	(PAttribOverallMask).l,d4
	tst.w	(matchupslot).w
	bne.w	.7
	move.l	(GAttribOverallMask).l,d4
.7
	move.w	(matchupvis).w,d0
	jsr	(printz).l
	String	$FF,$2,$19,$0
	bsr.w	PrintPlayerNameRight
	jsr	(CalcAttrib).l
	mulu.w	#$64,d0
	divu.w	d1,d0
	jsr	(ScaleAttrib).l
	move.w	d0,(visrating).w
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printz).l
	String	$FF,$6,$18,$0
	bsr.w	PrintTwoSpaces
	jsr	(printsmall).l
.8
	rts

MatchupPosNames	;IDA: unk_9FDEC. scout94 MatchupPosNames. Position names of matchups 1-6
	String	'     center     '
	String	' left forward   '
	String	' right forward  '
	String	'left defenseman '
	String	'right defenseman'
	String	'     goalie     '

GetMatchupPlayers	;IDA: sub_9FE58. scout94 GetMatchupPlayers. matchuphome / matchupvis = the home / visitors player of the matchup (GetMatchupPlayer)
	movem.l	d0/a0-a1,-(sp)
.0
	movea.l	#HmShots,a0
	btst	#6,(sflags11).w
	beq.w	.1
	movea.l	$1E(a0),a0
	adda.w	6(a0),a0
	bra.w	.2
.1
	move.w	$28(a0),d0
	mulu.w	#$82,d0
	movea.l	#$207C28,a0
	adda.l	d0,a0
.2
	bsr.w	GetMatchupPlayer
	move.w	d0,(matchuphome).w
	movea.l	#AwShots,a0
	btst	#6,(sflags11).w
	beq.w	.3
	movea.l	$1E(a0),a0
	adda.w	6(a0),a0
	bra.w	.4
.3
	move.w	$28(a0),d0
	mulu.w	#$82,d0
	movea.l	#$207C28,a0
	adda.l	d0,a0
.4
	bsr.w	GetMatchupPlayer
	move.w	d0,(matchupvis).w
	movem.l	(sp)+,d0/a0-a1
	rts

GetMatchupPlayer	;IDA: sub_9FECA. scout94 GetMatchupPlayer. d0 = the roster index of the matchup slot (MatchupLineSlots, matchupslot) in the first line set of team a0
	move.w	(matchup).w,d0
	movea.l	#MatchupLineSlots,a1
	move.b	(a1,d0.w),d0
	ext.w	d0
	move.w	d0,(matchupslot).w
	btst	#6,(sflags11).w
	beq.w	.0
	move.b	(a0,d0.w),d0
	ext.w	d0
	bra.w	.1
.0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	ext.w	d0
.1
	subq.w	#1,d0
	rts

RestartAdvantageMarks	;IDA: sub_9FEFE. scout94 RestartAdvantageMarks. Restart the advantage marks (advcount / advframe)
	clr.w	(advcount).w
	clr.w	(advframe).w
	rts

PrintAdvantageMarks	;IDA: sub_9FF08. scout94 PrintAdvantageMarks. Every frame: the advantage marks at x $13, y $16 grow toward the better rated side (HomeAdvMarks / VisAdvMarks); even: EvenAdvTxt
	movem.l	d0-d7/a0-a6,-(sp)
	addq.w	#1,(advcount).w
	cmpi.w	#7,(advcount).w
	blt.w	.0
	clr.w	(advcount).w
	addq.w	#1,(advframe).w
	cmpi.w	#6,(advframe).w
	blt.w	.0
	move.w	#5,(advframe).w
.0
	move.w	(advframe).w,d1
	asl.w	#2,d1
	movea.l	#HomeAdvMarks,a1
	move.w	(homerating).w,d0
	cmp.w	(visrating).w,d0
	bgt.w	.1
	beq.w	.2
	movea.l	#VisAdvMarks,a1
.1
	movea.l	(a1,d1.w),a1
	bra.w	.3
.2
	movea.l	#EvenAdvTxt,a1
.3
	move.w	#2,(printfontset).w
	jsr	(printz).l
	String	$FF,$13,$18,$0
	jsr	(printsmall).l
	move.w	#0,(printfontset).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

HomeAdvMarks	;IDA: unk_9FF86. scout94 HomeAdvMarks. Home advantage marks by advframe (0-5)
	dc.l	HomeAdv0Txt,HomeAdv1Txt,HomeAdv2Txt,HomeAdv3Txt,HomeAdv3Txt,HomeAdv3Txt

VisAdvMarks	;IDA: unk_9FF9E. scout94 VisAdvMarks. Visitors advantage marks by advframe
	dc.l	VisAdv0Txt,VisAdv1Txt,VisAdv2Txt,VisAdv3Txt,VisAdv3Txt,VisAdv3Txt

HomeAdv0Txt	;no IDA label. scout94 HomeAdv0Txt
	String	'   ',$0

HomeAdv1Txt	;no IDA label. scout94 HomeAdv1Txt
	String	']  ',$0

HomeAdv2Txt	;no IDA label. scout94 HomeAdv2Txt
	String	']] ',$0

HomeAdv3Txt	;no IDA label. scout94 HomeAdv3Txt
	String	']]]',$0

VisAdv0Txt	;no IDA label. scout94 VisAdv0Txt
	String	'   ',$0

VisAdv1Txt	;no IDA label. scout94 VisAdv1Txt
	String	'  [',$0

VisAdv2Txt	;no IDA label. scout94 VisAdv2Txt
	String	' [[',$0

VisAdv3Txt	;no IDA label. scout94 VisAdv3Txt
	String	'[[[',$0

EvenAdvTxt	;IDA: unk_9FFE6. scout94 EvenAdvTxt. Even teams
	String	'   ',$0

MatchupLineSlots	;IDA: unk_9FFEC. scout94 MatchupLineSlots. Line slot by matchup 0-6 (0 for the teams, then center, left wing, right wing, left defense, right defense, goalie)
	dc.b	0,4,3,5,1,2,0,$FF

BuildHotColdLists	;IDA: sub_9FFF4. crowd94 BuildHotColdLists. The hot / cold player lists of both teams (SortHotColdStarters, CopyHottestPlayer, CopyColdestPlayer)
	clr.w	(awayhotidx).w
	clr.w	(homehotidx).w
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#HmShots,a0
	bsr.w	SortHotColdStarters
	movea.l	#homehotplayer,a0
	bsr.w	CopyHottestPlayer
	movea.l	#homecoldplayer,a0
	bsr.w	CopyColdestPlayer
	movea.l	#AwShots,a0
	bsr.w	SortHotColdStarters
	movea.l	#awayhotplayer,a0
	bsr.w	CopyHottestPlayer
	movea.l	#awaycoldplayer,a0
	bsr.w	CopyColdestPlayer
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SortHotColdStarters	;IDA: sub_A0042. crowd94 SortHotColdStarters. Sum the hot / cold values of the 6 starters of team a0 (save RAM roster $207C28) into TempBuffer (byte pairs: player, sum), then sort them by sum
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	a0,a2
	adda.l	#$1A4,a2
	move.w	$28(a0),d0
	mulu.w	#$82,d0
	movea.l	#$207C28,a0
	adda.l	d0,a0
	movea.l	#TempBuffer,a1
	move.w	#5,d0
.0
	move.w	(a0)+,d1
	subq.b	#1,d1
	move.b	d1,(a1)+
	ext.w	d1
	asl.w	#4,d1
	clr.b	(a1)
	addq.w	#3,d1
	move.w	#3,d7
.1
	clr.w	d2
	move.b	(a2,d1.w),d2
	cmp.b	#9,d7
	beq.w	.2
	cmp.b	#$D,d7
	beq.w	.2
	add.b	d2,(a1)
.2
	addq.w	#1,d1
	addq.w	#1,d7
	cmp.b	#$10,d7
	bne.s	.1
	tst.b	(a1)+
	dbf	d0,.0
.3
	movea.l	#TempBuffer,a1
	clr.w	d1
	move.w	#4,d0
.4
	move.b	3(a1),d6
	cmp.b	1(a1),d6
	ble.w	.5
	st	d1
	move.w	2(a1),d2
	move.w	(a1),2(a1)
	move.w	d2,(a1)
.5
	tst.w	(a1)+
	dbf	d0,.4
	tst.w	d1
	bne.s	.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts
