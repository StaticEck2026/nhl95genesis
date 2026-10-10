;	NHL 95 data95_01. Retail $084FE6-$087BA1 (11196 bytes).
;	Mapped to data94 (34%), but most of the row is other 94 files moved together: stats94 TeamRosterScreen, DisplayPlayerList,
;	getNameandAttrib and its column handlers, DrawTeamScreen; data94 PAttribColumns / GAttribColumns, PlayerPositionText; the 95 game
;	setup screen (optsetup94 GameSetUp ... setoptions, attract94 DrawTeamBitmap, SetPojoyMode, rewritten for the 13 95 play modes,
;	the season and the player cards); data94 DefaultMenus, FigureJoy and the playoff routines InitializeGameStructures ... MakeTree;
;	title94 ReadLineData / WriteLineData. setup95_02 follows at $087BA2.
;	IDA hid code as dc.b at $84FE6-$8546D (TeamRosterScreen ... PrintPlayerLines), $8547A-$8581D (getNameandAttrib ...
;	LoadRosterFont), $861CE and $87468-$874A5 (InitializeGameStructures, OptionRNG); these are read from the retail bytes. IDA also
;	hid the printz / printz2 Strings and the DecompressGraphicsWithCallback remap bytes as instructions. Local labels are numbered;
;	the IDA local names are not kept.
;	New RAM names are in stubinc/ram_addrs.inc: the 94 setup and card words (logoteam ... cardteamnum, DispAttribCtr,
;	setupprevline), the playoff words (gsstruct ... potree), and the 95 setup words (SelectedPlayerIdx, setupvalues, setupdir ...).
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

	rts	;unused (the byte after compshoot)

TeamRosterScreen	;IDA: sub_84FE8. 93 name (94 stats94). "Team Roster" screen for team a2: DrawTeamScreen, then the player list (DisplayPlayerList)
	;with page (SelectedPlayerIdx: goalies, offense, defense; C), column (DispAttribCtr: left / right) and row scroll (rosterscroll: up / down).
	;B goes to the other team; start exits (ExitAttributeScreen2). 95 rewrote the 94 scrolling screen. Called from the menu95 item lists
	moveq	#0,d0
	moveq	#$1C,d1
	jsr	(DrawTeamScreen).l
	movem.l	a0-a6,-(sp)
	move.l	#Teamblocksmap,(teamblocksmapptr).l
	jsr	(setupTeamBlocksMap).l
	movem.l	(sp)+,a0-a6
	moveq	#0,d0
	move.w	d0,(SelectedPlayerIdx).w
	move.w	d4,(homepicchars).w
	addi.w	#$24,d4
	clr.w	(DispAttribCtr).w
.0
	movem.l	a0-a6,-(sp)
	move.w	$28(a2),d3
	jsr	(GetTeamLogo).l
	jsr	(printz).l
	String	$8D,2,1,0
	move.w	(homepicchars).w,d4
	move.w	#4,d5
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(DrawTeamLogo).l
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	#$20,(printx).w
	jsr	(DrawTeamLogo).l
	move.w	#$64,(palcount).w
	movem.l	(sp)+,a0-a6
	clr.w	(rosterscroll).w
	jsr	(printz).l
	String	$BD,$E,1,0
	clr.w	d0
	cmpa.w	#$C288,a2
	beq.w	.1
	move.w	#$2C,d0
.1
	jsr	(PutTeamBlock).l
	jsr	(printz2).l
	dc.w	$5A
	dc.b	$F8,$4,$2,$1,$B,$F9,$2,$5E,$23,$5E,$5E,$50
	dc.b	$6C,$61,$79,$65,$72,$FD,$19,$4C,$69,$6E,$65,$73
	dc.b	$FD,$17,$FC,$C,$52,$65,$67,$5E,$50,$50,$5E,$50
	dc.b	$4B,$FD,$21,$FC,$B,$52,$61,$74,$69,$6E,$67,$FD
	dc.b	$3,$FC,$1A,$41,$2D,$54,$65,$61,$6D,$73,$20,$20
	dc.b	$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	dc.b	$20,$20,$43,$2D,$50,$6F,$73,$69,$74,$69,$6F,$6E
	dc.b	$73,$F9,$0,$0
	jsr	(printz).l
	String	$BD,1,8,0
	bsr.w	DisplayPlayerList
	clr.w	(VertLineScrolling).w
	clr.w	(PlayerScrollCtr).w
.2
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	jsr	(ProcessInputWithRepeat).l
	btst	#7,d3
	bne.w	ExitAttributeScreen2
	btst	#6,d1
	bne.w	.8
	jsr	(nodiag).l
	moveq	#1,d0
	btst	#3,d1
	bne.w	.7
	neg.w	d0
	btst	#2,d1
	bne.w	.7
	tst.w	(PlayerScrollCtr).w
	bne.w	.6
	moveq	#-2,d0
	neg.w	d0
	btst	#5,d1
	beq.w	.4
	clr.w	(rosterscroll).w
	addq.w	#1,(SelectedPlayerIdx).w
	cmpi.w	#2,(SelectedPlayerIdx).w
	ble.w	.3
	clr.w	(SelectedPlayerIdx).w
.3
	jsr	(DisplayPlayerList).l
	bra.s	.2
.4
	btst	#1,d1
	beq.w	.5
	move.w	(rosterscroll).w,d0
	addq.w	#1,d0
	cmp.w	(TempWord1).w,d0
	bge.w	.5
	move.w	d0,(rosterscroll).w
	jsr	(DisplayPlayerList).l
	bra.w	.2
.5
	btst	#0,d1
	beq.w	.6
	move.w	(rosterscroll).w,d0
	subq.w	#1,d0
	bmi.w	.6
	move.w	d0,(rosterscroll).w
	jsr	(DisplayPlayerList).l
	bra.w	.2
.6
	bra.w	.2
.7
	add.w	(DispAttribCtr).w,d0
	bmi.s	.6
	move.w	d0,(DispAttribCtr).w
	bsr.w	DisplayPlayerList
	bra.s	.6
.8
	lea	$366(a2),a2
	cmpa.w	#$C5EE,a2
	beq.w	.0
	movea.w	#$C288,a2
	bra.w	.0
	rts	;unused
	clr.w	(PlayerScrollCtr).w	;unused
	rts

DisplayPlayerList	;IDA: sub_851E0. 93 name (94 stats94). Draw roster page SelectedPlayerIdx: the title (PlayerStatMenuTxt), the scroll marks, the column header
	;(PAttribColumns, or GAttribColumns for goalies) and up to 5 rows from rosterscroll: getNameandAttrib, then the lines the player
	;is on (PrintPlayerLines); the first row is highlighted
	jsr	(printz2).l
	String	$F8,4,3,2,8,$F9,1,0
	move.w	(SelectedPlayerIdx).w,d0
	lea	PlayerStatMenuTxt(pc),a1
	jsr	(SkipStrings).l
	jsr	(printsmall).l
	tst.w	(SelectedPlayerIdx).w
	beq.w	.1
	cmpi.w	#1,(SelectedPlayerIdx).w
	beq.w	.0
	jsr	(GetDefenseStart).l
	move.w	d0,(TempWord2).w
	move.w	d0,-(sp)
	jsr	(GetPlayerCount).l
	sub.w	(sp)+,d0
	bra.w	.2
.0
	jsr	(ReadAttributeNibble).l
	move.w	d0,-(sp)
	move.w	d0,(TempWord2).w
	jsr	(GetDefenseStart).l
	sub.w	(sp)+,d0
	bra.w	.2
.1
	clr.w	(TempWord2).w
	jsr	(ReadAttributeNibble).l
.2
	move.w	d0,(TempWord1).w
	move.w	(TempWord1).w,d0
	sub.w	(rosterscroll).w,d0
	cmp.w	#1,d0
	ble.w	.3
	jsr	(printz2).l
	String	$FD,$10,$7D,0
.3
	tst.w	(rosterscroll).w
	beq.w	.4
	jsr	(printz2).l
	String	$FD,3,$7B,0
.4
	jsr	(printz2).l
	String	$FD,$16,$FC,8
.5
	movea.l	#PAttribColumns,a1
	move.w	(DispAttribCtr).w,d0
	tst.w	(SelectedPlayerIdx).w
	bne.w	.7
	movea.l	#GAttribColumns,a1
	bra.w	.7
.6
	adda.w	(a1),a1
	addq.w	#4,a1
.7
	tst.w	(a1)
	dbmi	d0,.6
	bpl.w	.8
	subq.w	#1,(DispAttribCtr).w
	bra.s	.5
.8
	jsr	(printsmall).l
	move.l	(a1),d4
	jsr	(printz2).l
	String	$F8,4,2,0,0,$F9,0,0
	move.w	#$E,(printy).w
	move.w	(printy).w,-(sp)
	moveq	#$28,d0
	moveq	#$A,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
	move.w	(TempWord1).w,d0
	move.w	d0,d1
	sub.w	(rosterscroll).w,d1
	subq.w	#1,d1
	cmp.w	#4,d1
	ble.w	.9
	move.w	#4,d1
.9
	move.w	(TempWord2).w,d0
	add.w	(rosterscroll).w,d0
	move.w	d0,(recwins).w
.10
	move.w	#1,(printx).w
	movem.w	d0-d1,-(sp)
	cmp.w	(recwins).w,d0
	bne.w	.11
	jsr	(printz2).l
	String	$F9,2
.11
	jsr	(getNameandAttrib).l
	move.w	#$17,(printx).w
	bsr.w	PrintPlayerLines
	movem.w	(sp)+,d0-d1
	jsr	(printz2).l
	String	$F9,0
	addq.w	#1,d0
	addq.w	#2,(printy).w
	dbf	d1,.10
	rts

PrintPlayerLines	;IDA: sub_8535E. 95 only. Print at printx the lines player d0 of team a2 is on (FindPlayerLine for the 7 line slots at $16C(a2)...):
	;linemarkbuf "123 12 12", a ^ where he is not on that line
	movem.l	d1/a1,-(sp)
	movea.l	#linemarkbuf,a1
	move.w	#$C,(a1)+
	move.l	#$5E5E5E5E,(a1)+
	move.l	#$5E5E5E5E,(a1)+
	move.l	#$5E000000,(a1)
	move.l	a3,-(sp)
	movea.l	#linemarkbuf+2,a1
	lea	$16C(a2),a3
	bsr.w	FindPlayerLine
	tst.w	d1
	bmi.w	.s0
	move.b	#'1',(a1)
.s0
	tst.b	(a1)+
	lea	$174(a2),a3
	bsr.w	FindPlayerLine
	tst.w	d1
	bmi.w	.s1
	move.b	#'2',(a1)
.s1
	tst.b	(a1)+
	lea	$17C(a2),a3
	bsr.w	FindPlayerLine
	tst.w	d1
	bmi.w	.s2
	move.b	#'3',(a1)
.s2
	tst.b	(a1)+
	tst.b	(a1)+
	lea	$184(a2),a3
	bsr.w	FindPlayerLine
	tst.w	d1
	bmi.w	.s3
	move.b	#'1',(a1)
.s3
	tst.b	(a1)+
	lea	$18C(a2),a3
	bsr.w	FindPlayerLine
	tst.w	d1
	bmi.w	.s4
	move.b	#'2',(a1)
.s4
	tst.b	(a1)+
	tst.b	(a1)+
	lea	$194(a2),a3
	bsr.w	FindPlayerLine
	tst.w	d1
	bmi.w	.s5
	move.b	#'1',(a1)
.s5
	tst.b	(a1)+
	lea	$19C(a2),a3
	bsr.w	FindPlayerLine
	tst.w	d1
	bmi.w	.s6
	move.b	#'2',(a1)
.s6
	movea.l	(sp)+,a3
	movea.l	#linemarkbuf,a1
	jsr	(printsmall).l
	movem.l	(sp)+,d1/a1
	rts
	String	'G'	;not read (93 GoalieRowText)
	String	'G'
	String	'G'
	String	'G'

PlayerStatMenuTxt	;IDA: unk_85438. 93 name. Roster page titles (SkipStrings by SelectedPlayerIdx). The four String 'G' before it (93 GoalieRowText) are not read
	String	'    Goalies     '
	String	'    Offense     '
	String	'    Defense     '

ExitAttributeScreen2	;IDA: loc_8546E. 94 stats94 name. TeamRosterScreen start: forceblack and back to the menu (DrawMenuScreen, menu95)
	jsr	(forceblack).l
	jmp	DrawMenuScreen

getNameandAttrib	;IDA: sub_8547A (93 GetNameandAttrib). Print player d0's name, then at x $21 (94 $1E) the column d4 picks (attribjmp; above 2
	;a rating through CalcAttrib, the jump offset in the low word). 95 keeps the team and player in screenarg / attribplayer
	movem.l	d0-d4/a0-a1/a4-a5,-(sp)
	move.w	$28(a2),(screenarg).w
	move.w	d0,(attribplayer).w
	pea	.1(pc)
	jsr	(getname).l
	jsr	(printsmall).l
	move.w	#$21,(printx).w
	cmp.w	#2,d4
	bls.w	.0
	jsr	(CalcAttrib).l
	swap	d4
.0
	lea	attribjmp(pc),a0
	adda.w	0(a0,d4.w),a0
	jmp	(a0)
.1
	movem.l	(sp)+,d0-d4/a0-a1/a4-a5
	rts

attribjmp	;IDA: off_854BE. getNameandAttrib column handlers, offsets from attribjmp: status, energy, handed, weight, fighting, rating
	dc.w	AttribStatus-attribjmp
	dc.w	AttribEnergy-attribjmp
	dc.w	AttribHanded-attribjmp
	dc.w	AttribWeight-attribjmp
	dc.w	AttribFighting-attribjmp
	dc.w	AttribRating-attribjmp

AttribStatus	;IDA: loc_854CA. 93 name. Player d0's status word at $68(a2) (94 $66): Ice, Bench, Inj. P, Inj. G, or penalty time. 95: an injured player
	;(status 3) shows his games out from InjuryGamesTbl (GetInjuryGames)
	add.w	d0,d0
	move.w	tmpdst(a2,d0.w),d0
	bpl.w	.3
	not.w	d0
	cmp.w	#3,d0
	bls.w	.1
	moveq	#1,d0
	bra.w	.1
.0
	moveq	#3,d0
.1
	cmp.w	#3,d0
	bne.w	.2
	movem.l	d0-d1/d7,-(sp)
	move.w	(attribplayer).w,d1
	move.w	$28(a2),d7
	jsr	(GetInjuryGames).l
	lea	InjuryGamesTbl(pc),a1
	jsr	(PrintSmallListItem).l
	movem.l	(sp)+,d0-d1/d7
	rts
.2
	lea	StatusTextTbl(pc),a1
	jmp	PrintSmallListItem
.3
	btst	#$C,d0
	bne.s	.0
	subq.w	#1,(printx).w
	move.w	d0,d1
	andi.w	#$FFF,d0
	jsr	(PushTime).l
	jsr	(printsmall).l
	moveq	#4,d0
	bclr	#$E,d1
	beq.w	.4
	moveq	#5,d0
.4
	lea	StatusTextTbl(pc),a1
	jmp	PrintSmallListItem

StatusTextTbl	;IDA: unk_8554C. 93 name. AttribStatus Strings (94 'Injury P' / 'Injury G')
	String	'Ice     '
	String	'Bench   '
	String	'Inj. P  '
	String	'Inj. G  '
	String	'    '
	String	' C  '

InjuryGamesTbl	;IDA: unk_85580. 95 only. AttribStatus Strings for an injury of 0-9 games
	String	'Inj. G  '
	String	'Inj.1G  '
	String	'Inj.2G  '
	String	'Inj.3G  '
	String	'Inj.4G  '
	String	'Inj.5G  '
	String	'Inj.6G  '
	String	'Inj.7G  '
	String	'Inj.8G  '
	String	'Inj.9G  '

AttribEnergy	;IDA: loc_855E4. 93 name. Energy: word $34(a2) (94 $32) / 40, at most 100 (AttribPrintPct)
	add.w	d0,d0
	move.w	tmpde(a2,d0.w),d0
	ext.l	d0
	divu.w	#$28,d0
	cmp.w	#$64,d0
	ble.w	AttribPrintPct
	moveq	#$64,d0
	bra.w	AttribPrintPct

AttribFighting	;IDA: loc_855FE. 93 name. Bit 0 of the nibble is the handedness: drop it, then a rating out of d1 - 1
	andi.w	#$E,d0
	subq.w	#1,d1

AttribRating	;IDA: loc_85604. IDA: DispAttribValue (94). d0 * 100 / d1; 95 scales it (ScaleAttrib, 94 AttribAdjust) only when SeasonPlayerOut returns nonzero.
	;Falls into AttribPrintPct
	mulu.w	#$64,d0
	divu.w	d1,d0
	movem.l	d0/d7,-(sp)
	move.w	(screenarg).w,d7
	move.w	(attribplayer).w,d0
	jsr	(SeasonPlayerOut).l
	movem.l	(sp)+,d0/d7
	beq.w	AttribPrintPct
	jsr	(ScaleAttrib).l

AttribPrintPct	;IDA: loc_8562A. 93 name. Print d0 4 wide, then 4 blanks
	moveq	#4,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	jsr	(printz).l
	String	'    '
	rts

AttribHanded	;IDA: loc_85646. 93 name. Bit 0 of the sum: Righty / Lefty (HandedTextTbl)
	andi.w	#1,d0
	lea	HandedTextTbl(pc),a1
	jmp	PrintSmallListItem

HandedTextTbl	;IDA: unk_85654. IDA: Handedlist (94). AttribHanded Strings
	String	'Righty  '
	String	'Lefty   '

AttribWeight	;IDA: loc_85668. 93 name. Weight: 140 + 8 * rating lb
	asl.w	#3,d0
	addi.w	#$8C,d0
	jsr	(PushNumber).l
	jsr	(printsmall).l
	jsr	(printz2).l
	String	' lb  '
	rts

DrawTeamScreen	;IDA: sub_8568A. 93 name (94 stats94). Roster screen background: wait for the dma (disflags bit 0), clear the scroll, set the window plane
	;registers, the roster bitmap (RosterBitmap) on map 2 and map 1, the RosterFont tiles (LoadRosterFont, then two remaps at
	;smallfont2chars / smallfont3chars), clear map 1 and fade in. d0 / d1 = first row / row count of the bitmap
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
	jsr	(printz).l
	String	$BD,0,0,0
	movea.l	#RosterBitmap,a1
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#1,d4
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FD,0,0,0
	movem.l	(sp),d0-d1/a2
	add.w	d0,(printy).w
	movea.l	#RosterBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	move.w	d1,d3
	sub.w	d0,d3
	move.w	d0,d1
	clr.w	d0
	moveq	#$28,d2
	moveq	#$F,d5
	jsr	(dobitmap).l
	move.w	d4,(smallfontchars).w
	move.l	#RosterFont,(smallfontptr).l
	jsr	(LoadRosterFont).l
	move.w	d4,(smallfont2chars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$06,$83,$45,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont3chars).w
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0C,$83,$45,$67,$89,$AB,$CD,$EF
	jsr	(printz).l
	String	$FE,0,0,0
	moveq	#$40,d0
	moveq	#$20,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	#$18,(palcount).w
	movem.l	(sp)+,d0-d1/a2
	rts

FindPlayerLine	;IDA: sub_857CC. 95 only. Find player d0 (0 based) in the 6 slots of line a3: d1 = the line (counted by 8 bytes), -1 not found
	movem.l	d0/d2-d3/a3,-(sp)
	move.w	#8,d2
	clr.w	d3
	addq.w	#1,d0
	clr.w	d1
.0
	cmp.w	#6,d3
	bge.w	.1
	cmp.b	(a3),d0
	beq.w	.3
.1
	tst.b	(a3)+
	addq.w	#1,d3
	andi.w	#7,d3
	bne.w	.2
	addq.w	#1,d1
.2
	dbf	d2,.0
	move.w	#-1,d1
.3
	movem.l	(sp)+,d0/d2-d3/a3
	rts

LoadRosterFont	;IDA: sub_85804. 95 only. Load the small font tiles (smallfontptr + 8) at char d4 with the remap below; d4 = next char
	move.w	d4,(smallfontchars).w
	movea.l	(smallfontptr).w,a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$04,$83,$45,$67,$89,$AB,$CD,$EF
	rts

PAttribColumns	;IDA: unk_8581E (93 PAttribColumns). Skater attribute columns for DisplayPlayerList and getNameandAttrib. String header, then a
	;long: high word = mask of rating nibbles to average, low word = attribjmp offset (0 status, 2 energy, 4 handed, 6 weight, 8
	;fighting, $A rating). A negative word ends the list. The same table as 94
	String	'     Status    ]'
	dc.w	$0000,$0

PAttribOverall	;IDA: unk_85834. The Overall entry; PAttribOverallMask is read by video95_03
	String	'[   Overall    ]'

PAttribOverallMask	;IDA: dword_85846
	dc.w	$1FBA,$A
	String	'[   Energy     ]'
	dc.w	$0000,$2
	String	'[   Agility    ]'
	dc.w	$1000,$A
	String	'[    Speed     ]'
	dc.w	$0800,$A
	String	'[   Handed     ]'
	dc.w	$0040,$4
	String	'[Off. Awareness]'
	dc.w	$0400,$A
	String	'[Def. Awareness]'
	dc.w	$0200,$A
	String	'[  Shot Power  ]'
	dc.w	$0100,$A
	String	'[Shot  Accuracy]'
	dc.w	$0010,$A
	String	'[Pass  Accuracy]'
	dc.w	$0002,$A
	String	'[Stick Handling]'
	dc.w	$0020,$A
	String	'[    Weight    ]'
	dc.w	$2000,$6
	String	'[  Endurance   ]'
	dc.w	$0008,$A
	String	'[Aggressiveness]'
	dc.w	$0001,$A
	String	'[   Checking    '
	dc.w	$0080,$A
	dc.w	-1

GAttribColumns	;IDA: unk_85980 (93 GAttribColumns). Goalie attribute columns, same format as PAttribColumns
	String	'     Status    ]'
	dc.w	$0000,$0

GAttribOverall	;IDA: unk_85996. The Overall entry; GAttribOverallMask is read by video95_03
	String	'[   Overall    ]'

GAttribOverallMask	;IDA: dword_859A8
	dc.w	$130F,$A
	String	'[   Agility    ]'
	dc.w	$1000,$A
	String	'[    Speed     ]'
	dc.w	$0800,$A
	String	'[  Glove Hand  ]'
	dc.w	$0040,$4
	String	'[Def. Awareness]'
	dc.w	$0200,$A
	String	'[ Puck Control ]'
	dc.w	$0100,$A
	String	'[ Stick  Right ]'
	dc.w	$0008,$A
	String	'[  Stick Left  ]'
	dc.w	$0004,$A
	String	'[ Glove  Right ]'
	dc.w	$0002,$A
	String	'[  Glove Left  ]'
	dc.w	$0001,$A
	String	'[    Weight     '
	dc.w	$2000,$6
	dc.w	-1

PlayerPositionText	;IDA: unk_85A8A. 93 name. Position names for the line slots (no xref in IDA)
	String	'LD'
	String	'RD'
	String	'LW'
	String	'C'
	String	'RW'

GameSetUp	;IDA: sub_85A9E (94 optsetup94). The game setup screen, rewritten for 95: ReadLineData, ReadPassBits, the options from TmpOptLine2 /
	;TempOptPlayMode. In a season (GameFlags bit 5) take the season options (ReadSeasonHeader) and the matchup (StepSeasonTeam).
	;Then setoptions, and the line cursor loop: FixModeOptions, PrintOptions, the logos or matchup bitmaps, GameSetUp_2 for a key;
	;up / down move SelectedPlayerIdx, left / right step setupvalues (WrapOptionUp / Down), start stores them (SetupStart) and sets the
	;pads (SetPojoyMode, FigureJoy). Called from hockey95
	jsr	(ReadLineData).l
	movea.l	#pwddatabuffer,a3
	jsr	(ReadPassBits).l
	move.w	(TmpOptLine2).w,(OptLine).w
	move.w	(TempOptPlayMode).w,(OptPlayMode).w
	btst	#5,(GameFlags).w
	beq.w	.0
	jsr	(ReadSeasonHeader).l
	clr.w	(OptPerlen).w
	move.b	(SeasonPerlen).w,(OptPerlen+1).w
	clr.w	(OptPen).w
	move.b	(SeasonPen).w,(OptPen+1).w
	clr.w	(OptLine).w
	move.b	(SeasonLine).w,(OptLine+1).w
	bset	#4,(setupcardflags).w
	st	(seasonteamsel).w
	jsr	(BuildSeasonTeamList).l
	move.w	#0,(OptPlayMode).w
	move.w	#$FFFF,(setupdir).w
	movea.l	#setupvalues,a0
	jsr	(StepSeasonTeam).l
	clr.w	(Opt1Team).w
	clr.w	(Opt2Team).w
	move.b	1(a0),(Opt1Team+1).w
	move.b	2(a0),(Opt2Team+1).w
.0
	tst.w	(demoflag).w
	bmi.w	.1
	jsr	(RandomSetupTeams).l
	clr.w	(demoflag).w
.1
	cmpi.w	#4,(OptPlayMode).w
	bne.w	.2
	bra.w	.4
.2
	cmpi.w	#2,(OptPlayMode).w
	blt.w	.3
	bsr.w	.11
.3
	cmpi.w	#1,(OptPlayMode).w
	bne.w	.4
	bsr.w	.12
.4
	bsr.w	GetSetupValues
	btst	#5,(GameFlags).w
	bne.w	.6
	tst.w	(seasonsetupreq).w
	bne.w	.5
	bra.w	.7
.5
	clr.w	(seasonsetupreq).w
.6
	movea.l	#setupvalues,a0
	move.b	#7,(a0)
.7
	bsr.w	setoptions
	clr.w	(SelectedPlayerIdx).w
	clr.w	(setupprevline).w
	clr.w	(DispAttribCtr).w
	move.w	#7,(setupshown).w
	move.w	(setupshown).w,(VertLineScrolling).w
	subq.w	#1,(VertLineScrolling).w
	move.w	#$FFFF,(setupdir).w
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
.8
	bsr.w	FixModeOptions
	bsr.w	PrintOptions
	cmpi.w	#1,(setupshown).w
	bne.w	.9
	move.w	#$B4,(carddelay).l
	bset	#6,(setupcardflags).w
	bsr.w	EraseCard
	bsr.w	ClearLogoPalettes
	bra.w	.10
.9
	bsr.w	UpdateSetupLogos
	bsr.w	DrawMatchupBitmaps
.10
	bsr.w	GameSetUp_2
	move.w	(SelectedPlayerIdx).w,(setupprevline).w
	tst.w	d1
	bne.w	.13
	bra.w	.23
.11
	jmp	NewPO
.12
	jmp	ContinuePlayoffs
.13
	move.w	#$FFFF,(setupdir).w
	btst	#7,d1
	bne.w	.24
	btst	#1,d1
	beq.w	.14
	bra.w	.20
.14
	btst	#0,d1
	beq.w	.15
	bra.w	.18
.15
	btst	#2,d1
	beq.w	.16
	bra.w	.17
.16
	btst	#3,d1
	beq.w	.8
	move.w	#3,(setupdir).w
	move.w	(SelectedPlayerIdx).w,d0
	movea.l	#setupvalues,a0
	addq.b	#1,(a0,d0.w)
	bsr.w	WrapOptionUp
	bra.w	.8
.17
	move.w	#2,(setupdir).w
	move.w	(SelectedPlayerIdx).w,d0
	movea.l	#setupvalues,a0
	subq.b	#1,(a0,d0.w)
	bsr.w	WrapOptionDown
	bra.w	.8
.18
	move.w	#0,(setupdir).w
	tst.w	(SelectedPlayerIdx).w
	beq.w	.8
	subq.w	#1,(SelectedPlayerIdx).w
	cmpi.b	#$C,(setupvalues).w
	bne.w	.19
	cmpi.w	#3,(SelectedPlayerIdx).w
	bne.w	.19
	subq.w	#1,(SelectedPlayerIdx).w
.19
	btst	#4,(setupcardflags).w
	beq.w	.8
	cmpi.w	#2,(SelectedPlayerIdx).w
	bne.w	.8
	subq.w	#1,(SelectedPlayerIdx).w
	bra.w	.8
.20
	move.w	#$FFFF,(setupdir).w
	movem.w	d0,-(sp)
	move.w	(setuplines).w,d0
	subq.w	#1,d0
	cmp.w	(SelectedPlayerIdx).w,d0
	movem.w	(sp)+,d0
	beq.w	.8
	move.w	#1,(setupdir).w
	addq.w	#1,(SelectedPlayerIdx).w
	cmpi.b	#$C,(setupvalues).w
	bne.w	.21
	cmpi.w	#3,(SelectedPlayerIdx).w
	beq.w	.22
	cmpi.w	#5,(SelectedPlayerIdx).w
	bne.w	.21
	subq.w	#1,(SelectedPlayerIdx).w
	bra.w	.8
.21
	btst	#4,(setupcardflags).w
	beq.w	.8
	cmpi.w	#2,(SelectedPlayerIdx).w
	bne.w	.8
.22
	addq.w	#1,(SelectedPlayerIdx).w
	bra.w	.8
.23
	clr.w	(demoflag).w
	move.w	(VDP_CNTR).l,(RNGseed).w
	move.w	(VDP_CNTR).l,(RNGseed+2).w
	clr.w	(OptPlayMode).w
	clr.w	(OptNOP).w
	clr.w	(OptLine).w
	move.w	#1,(OptPen).w
.24
	bsr.w	SetupStart
	bclr	#5,(GameFlags).w
	move.w	#4,(OptNOP).w
	btst	#0,(gmode2).w
	beq.w	.25
	clr.w	(OptPlayMode).w
	jsr	(ShootoutInit).l
.25
	move.w	#7,(pojoy).w
	jsr	(SetPojoyMode).l
	jmp	FigureJoy

GameSetUp_2	;IDA: sub_85D8C (94 optsetup94). Wait up to $E10 frames (94 $5460) for a key on pad 1 / 2 (pads 3 / 4 with FourWayPlay):
	;d1 = new keys, 0 when time ran out. C held repeats faster (setupcardflags bit 5). Runs PlayerCardTimer each frame
	move.l	#$E10,d6
.0
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.0
	move.w	(vcount).w,(oldvcount).w
	tst.w	(carddelay).w
	bmi.w	.1
	cmpi.w	#1,(setupshown).w
	beq.w	.1
	sub.w	d1,(carddelay).w
	bpl.w	.1
	bsr.w	ResetCardTimer
.1
	bclr	#5,(setupcardflags).w
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	btst	#5,d3
	beq.w	.2
	bset	#5,(setupcardflags).w
	cmpi.w	#$A,(cardtimer).w
	ble.w	.2
	move.w	#$A,(cardtimer).w
.2
	tst.w	d1
	beq.w	.3
	bra.w	.10
.3
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	btst	#5,d3
	beq.w	.4
	bset	#5,(setupcardflags).w
	cmpi.w	#$A,(cardtimer).w
	ble.w	.4
	move.w	#$A,(cardtimer).w
.4
	tst.w	d1
	beq.w	.5
	bra.w	.10
.5
	tst.w	(FourWayPlay).w
	beq.w	.9
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	btst	#5,d3
	beq.w	.6
	bset	#5,(setupcardflags).w
	cmpi.w	#$A,(cardtimer).w
	ble.w	.6
	move.w	#$A,(cardtimer).w
.6
	tst.w	d1
	beq.w	.7
	bra.w	.10
.7
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	btst	#5,d3
	beq.w	.8
	bset	#5,(setupcardflags).w
	cmpi.w	#$A,(cardtimer).w
	ble.w	.8
	move.w	#$A,(cardtimer).w
.8
	tst.w	d1
	beq.w	.9
	bra.w	.10
.9
	jsr	(PlayerCardTimer).l
	dbf	d6,.0
.10
	rts

OptionLimits	;IDA: unk_85EAA. 93 setoptions .pslim. Number of values of each setup line (mode, team 1, team 2, length, goalies, user records, penalties,
	;line changes)
	dc.w	$D1C,$1C03,$202,$303

WrapOptionUp	;IDA: sub_85EB2. 93 setoptions .iilimit, the up half: setupvalues(d0) past OptionLimits(d0) goes to 0
	movea.l	#OptionLimits,a1
	clr.w	d2
	move.b	(a1,d0.w),d2
	cmp.b	(a0,d0.w),d2
	bgt.w	.0
	clr.b	(a0,d0.w)
.0
	rts

WrapOptionDown	;IDA: sub_85ECC. The down half: a negative setupvalues(d0) goes to OptionLimits(d0) - 1
	tst.b	(a0,d0.w)
	bpl.w	.0
	movea.l	#OptionLimits,a1
	move.b	(a1,d0.w),d2
	subq.b	#1,d2
	move.b	d2,(a0,d0.w)
.0
	rts

MoveMenuFrame	;IDA: sub_85EE6. 93 setoptions .nms. Keep SelectedPlayerIdx inside DispAttribCtr ... VertLineScrolling; in a season (GameFlags bit 5) line 0 is skipped
	move.w	(SelectedPlayerIdx).w,d0
	sub.w	(DispAttribCtr).w,d0
	bpl.w	.0
	add.w	d0,(DispAttribCtr).w
	add.w	d0,(VertLineScrolling).w
	bra.w	.1
.0
	move.w	(SelectedPlayerIdx).w,d0
	sub.w	(VertLineScrolling).w,d0
	bmi.w	.1
	beq.w	.1
	add.w	d0,(VertLineScrolling).w
	add.w	d0,(DispAttribCtr).w
.1
	btst	#5,(GameFlags).w
	beq.w	.2
	tst.w	(SelectedPlayerIdx).w
	bne.w	.2
	addq.w	#1,(SelectedPlayerIdx).w
.2
	rts

FixModeOptions	;IDA: sub_85F2E. 94 only (rewritten). Set setuplines / setupshown for the mode in setupvalues (Trade, Create, Sign, Release and Shootout
	;show fewer lines), keep the two teams 0-$19 and different in Trade Players, skip the modes save RAM or the season do not allow
	;(ValidSRAM, ReadSeasonHeader, CheckCreateSlots, ReadCreatedPlayers), step a season matchup (StepSeasonTeam) and start new /
	;continue playoffs (NewPO, ContinuePlayoffs) when line 1 changes
	movea.l	#setupvalues,a0
	move.w	#8,(setuplines).w
	move.w	#7,(setupshown).w
	cmpi.b	#3,(a0)
	beq.w	.0
	cmpi.b	#4,(a0)
	beq.w	.0
	cmpi.b	#6,(a0)
	beq.w	.0
	cmpi.b	#7,(a0)
	beq.w	.0
	cmpi.b	#8,(a0)
	beq.w	.0
	cmpi.b	#$A,(a0)
	beq.w	.0
	cmpi.b	#$B,(a0)
	bne.w	.9
.0
	cmpi.w	#1,(SelectedPlayerIdx).w
	beq.w	.1
	cmpi.w	#2,(SelectedPlayerIdx).w
	beq.w	.2
	bra.w	.7
.1
	cmpi.b	#$1A,1(a0)
	bge.w	.5
	bra.w	.7
.2
	cmpi.b	#$1A,2(a0)
	bge.w	.3
	bra.w	.7
.3
	cmpi.w	#3,(setupdir).w
	beq.w	.4
	move.b	#$19,2(a0)
	bra.w	.7
.4
	clr.b	2(a0)
	bra.w	.7
.5
	cmpi.w	#3,(setupdir).w
	beq.w	.6
	move.b	#$19,1(a0)
	bra.w	.7
.6
	clr.b	1(a0)
.7
	cmpi.b	#$1A,1(a0)
	blt.w	.8
	clr.b	1(a0)
.8
	cmpi.b	#$1A,2(a0)
	blt.w	.9
	clr.b	2(a0)
.9
	cmpi.b	#$C,(a0)
	bne.w	.10
	move.b	#1,7(a0)
	move.b	#0,6(a0)
	move.b	#1,5(a0)
.10
	cmpi.b	#8,(a0)
	bne.w	.15
	move.w	#3,(setuplines).w
	move.w	#3,(setupshown).w
	movem.w	d0,-(sp)
	move.b	1(a0),d0
	cmp.b	2(a0),d0
	bne.w	.14
	cmpi.w	#2,(setupdir).w
	beq.w	.11
	addq.b	#1,d0
	cmp.b	#$1A,d0
	bne.w	.12
	clr.w	d0
	bra.w	.12
.11
	subq.b	#1,d0
	bpl.w	.12
	move.w	#$19,d0
.12
	cmpi.w	#2,(SelectedPlayerIdx).w
	bne.w	.13
	move.b	d0,2(a0)
	move.b	d0,(Opt2Team+1).w
	bra.w	.14
.13
	move.b	d0,1(a0)
	move.b	d0,(Opt1Team+1).w
.14
	movem.w	(sp)+,d0
.15
	cmpi.b	#9,(a0)
	bne.w	.17
	jsr	(CheckCreateSlots).l
	bpl.w	.16
	jsr	(ReadCreatedPlayers).l
	tst.w	(createdcount).l
	beq.w	.20
.16
	move.w	#1,(setuplines).w
	move.w	#1,(setupshown).w
.17
	cmpi.b	#$B,(a0)
	bne.w	.18
	move.w	#1,(setuplines).w
	move.w	#1,(setupshown).w
.18
	cmpi.b	#$A,(a0)
	bne.w	.19
	move.w	#1,(setuplines).w
	move.w	#1,(setupshown).w
.19
	cmpi.b	#6,(a0)
	beq.w	.22
	cmpi.b	#7,(a0)
	bne.w	.23
	tst.w	(ValidSRAM).w
	bmi.w	.22
	jsr	(ReadSeasonHeader).l
	tst.b	(SeasonLength).w
	bne.w	.22
.20
	move.w	#0,d0
	cmpi.w	#2,(setupdir).w
	beq.w	.21
	addq.b	#1,(a0)
	bsr.w	WrapOptionUp
	bra.w	FixModeOptions
.21
	subq.b	#1,(a0)
	bsr.w	WrapOptionDown
	bra.w	FixModeOptions
.22
	btst	#5,(GameFlags).w
	bne.w	.23
	move.w	#1,(setuplines).w
	move.w	#1,(setupshown).w
.23
	btst	#5,(GameFlags).w
	beq.w	.25
	cmpi.w	#1,(SelectedPlayerIdx).w
	bne.w	.25
	cmpi.w	#3,(setupdir).w
	bne.w	.24
	bsr.w	StepSeasonTeam
	bra.w	.25
.24
	cmpi.w	#2,(setupdir).w
	bne.w	.25
	bsr.w	StepSeasonTeam
.25
	btst	#5,(GameFlags).w
	bne.w	.26
	bclr	#4,(setupcardflags).w
.26
	cmpi.b	#5,(a0)
	bne.w	.31
	tst.w	(ValidSRAM).w
	bmi.w	.29
	jsr	(CheckPlayoffsStarted).l
	beq.w	.29
	bsr.w	SetupStart
	bset	#4,(setupcardflags).w
	cmpi.w	#0,(SelectedPlayerIdx).w
	beq.w	.27
	cmpi.w	#1,(SelectedPlayerIdx).w
	bne.w	.31
.27
	cmpi.w	#2,(setupdir).w
	beq.w	.28
	cmpi.w	#3,(setupdir).w
	bne.w	.31
.28
	bsr.w	ContinuePlayoffs
	bsr.w	GetSetupValues
	rts
	bra.w	.31	;unused (IDA dc.b)
.29
	move.w	#0,d0
	cmpi.w	#2,(setupdir).w
	beq.w	.30
	addq.b	#1,(a0)
	bsr.w	WrapOptionUp
	bra.w	FixModeOptions
.30
	subq.b	#1,(a0)
	bsr.w	WrapOptionDown
	bra.w	FixModeOptions
.31
	cmpi.b	#3,(a0)
	bne.w	.34
	bsr.w	SetupStart
	bset	#4,(setupcardflags).w
	cmpi.w	#0,(SelectedPlayerIdx).w
	beq.w	.32
	cmpi.w	#1,(SelectedPlayerIdx).w
	bne.w	.34
.32
	cmpi.w	#2,(setupdir).w
	beq.w	.33
	cmpi.w	#3,(setupdir).w
	bne.w	.34
.33
	bsr.w	NewPO
	bsr.w	GetSetupValues
	rts
.34
	cmpi.b	#4,(a0)
	bne.w	.36
	bsr.w	SetupStart
	bset	#4,(setupcardflags).w
	cmpi.w	#3,(SelectedPlayerIdx).w
	bge.w	.36
	cmpi.w	#2,(setupdir).w
	beq.w	.35
	cmpi.w	#3,(setupdir).w
	bne.w	.36
.35
	bsr.w	NewPO
	bsr.w	GetSetupValues
	move.b	#4,(a0)
	rts
.36
	cmpi.b	#2,(a0)
	bne.w	.44
	move.b	#1,5(a0)
	move.b	#0,6(a0)
	move.b	#1,7(a0)
	cmpi.w	#1,(setupdir).w
	bne.w	.40
.37
	cmpi.w	#5,(SelectedPlayerIdx).w
	bne.w	.39
.38
	addq.w	#1,(SelectedPlayerIdx).w
	movem.w	d0,-(sp)
	move.w	(SelectedPlayerIdx).w,d0
	cmp.w	(setuplines).w,d0
	movem.w	(sp)+,d0
	blt.s	.37
	move.w	(setupprevline).w,(SelectedPlayerIdx).w
	bra.s	.37
.39
	cmpi.w	#6,(SelectedPlayerIdx).w
	beq.s	.38
	cmpi.w	#7,(SelectedPlayerIdx).w
	beq.s	.38
	bra.w	.44
.40
	cmpi.w	#0,(setupdir).w
	bne.w	.44
.41
	cmpi.w	#5,(SelectedPlayerIdx).w
	bne.w	.43
.42
	subq.w	#1,(SelectedPlayerIdx).w
	bra.s	.41
.43
	cmpi.w	#6,(SelectedPlayerIdx).w
	beq.s	.42
	cmpi.w	#7,(SelectedPlayerIdx).w
	beq.s	.42
	bra.w	*+4	;to the next instruction
.44
	tst.w	(ValidSRAM).w
	beq.w	.47
	cmpi.b	#8,(a0)
	beq.w	.45
	cmpi.b	#9,(a0)
	beq.w	.45
	cmpi.b	#$B,(a0)
	beq.w	.45
	cmpi.b	#$A,(a0)
	beq.w	.45
	cmpi.b	#6,(a0)
	beq.w	.45
	cmpi.b	#7,(a0)
	bne.w	.47
.45
	move.w	#0,d0
	cmpi.w	#2,(setupdir).w
	beq.w	.46
	addq.b	#1,(a0)
	bsr.w	WrapOptionUp
	bra.w	FixModeOptions
.46
	subq.b	#1,(a0)
	bsr.w	WrapOptionDown
	bra.w	FixModeOptions
.47
	rts

EraseCardText	;IDA: sub_86360. 95 only. Erase the card text areas: 5 rows at $FF,8,3 and 1 row at $FF,9,9 with GetBlankChar
	movem.l	d0-d2/a0,-(sp)
	move.w	#$18,d0
	move.w	#5,d1
	jsr	(printz).l
	String	$FF,$8,$3,$0
	bsr.w	GetBlankChar
	jsr	(eraser).l
	move.w	#$16,d0
	move.w	#1,d1
	jsr	(printz).l
	String	$FF,$9,$9,$0
	bsr.w	GetBlankChar
	jsr	(eraser).l
	movem.l	(sp)+,d0-d2/a0
	rts

PrintOptions	;IDA: sub_863A6. 93 setoptions .ps (94 PrintOptions). Print the option names (PrintOptionName) and values (GameSetUp_4) of lines
	;DispAttribCtr ... VertLineScrolling from row $B, then the scroll marks at x 2: '{' when lines are above, '}' when more follow
	bsr.w	MoveMenuFrame
	move.w	(DispAttribCtr).w,d0
	move.w	#$B,(printy).w
.0
	move.w	#4,(printx).w
	bsr.w	PrintOptionName
	move.w	#$13,(printx).w
	bsr.w	GameSetUp_4
	addq.w	#2,(printy).w
	addq.w	#1,d0
	cmp.w	(VertLineScrolling).w,d0
	ble.s	.0
	move.w	#2,(printx).w
	move.w	#$B,(printy).w
	movea.l	#ScrollClearTxt,a1
	tst.w	(DispAttribCtr).w
	beq.w	.1
	movea.l	#ScrollUpTxt,a1
.1
	bsr.w	PrintSetupText
	move.w	#2,(printx).w
	move.w	#$17,(printy).w
	movea.l	#ScrollClearTxt,a1
	movem.w	d0,-(sp)
	move.w	(setuplines).w,d0
	subq.w	#1,d0
	cmp.w	(VertLineScrolling).w,d0
	movem.w	(sp)+,d0
	beq.w	.2
	cmpi.w	#1,(setupshown).w
	beq.w	.2
	cmpi.w	#3,(setupshown).w
	beq.w	.2
	cmpi.b	#2,(setupvalues).w
	beq.w	.2
	cmpi.b	#$C,(setupvalues).w
	beq.w	.2
	movea.l	#ScrollDownTxt,a1
.2
	bsr.w	PrintSetupText
	rts

ScrollDownTxt	;IDA: unk_86454. 94 names. Scroll marks for PrintOptions
	String	'}'

ScrollClearTxt	;IDA: unk_86458
	String	' '

ScrollUpTxt	;IDA: unk_8645C
	String	'{'

GameSetUp_4	;IDA: sub_86460 (93 setoptions .psd). Print the value of setup line d0 at printx (OptionValueOffsets / the value Strings);
	;teams 1 / 2 go to the team name (TeamList city, IslandersTxt / RangersTxt for teams $D / $E), lines not shown print
	;BlankValueTxt, Shootout prints N/A for the length. The cursor line is highlighted (PrintSetupTextHi)
	movem.l	d0-d2/a0-a1,-(sp)
	movea.l	#setupvalues,a0
	clr.w	d1
	cmpi.w	#3,(setupshown).w
	bne.w	.0
	cmp.w	#2,d0
	ble.w	.1
	movea.l	#BlankValueTxt,a1
	bra.w	.4
.0
	cmpi.w	#1,(setupshown).w
	bne.w	.1
	tst.w	d0
	beq.w	.1
	movea.l	#BlankValueTxt,a1
	bra.w	.4
.1
	move.b	(a0,d0.w),d1
	cmp.w	#1,d0
	beq.w	.11
	cmp.w	#2,d0
	beq.w	.11
	move.w	d0,d2
	add.w	d2,d2
	movea.l	#OptionValueOffsets,a1
	adda.w	(a1,d2.w),a1
	bra.w	.3
.2
	adda.w	(a1),a1
.3
	dbf	d1,.2
.4
	cmpi.b	#$C,(setupvalues).w
	bne.w	.5
	cmp.w	#6,d2
	bne.w	.5
	movea.l	#.10,a1
.5
	cmp.w	(SelectedPlayerIdx).w,d0
	bne.w	.7
.6
	bsr.w	PrintSetupTextHi
	bra.w	.9
.7
	btst	#4,(setupcardflags).w
	beq.w	.8
	cmpi.w	#1,(SelectedPlayerIdx).w
	bne.w	.8
	cmp.w	#2,d0
	beq.s	.6
.8
	bsr.w	PrintSetupText
.9
	movem.l	(sp)+,d0-d2/a0-a1
	rts
.10
	String	'N/A                 '
.11
	movea.l	#BlankValueTxt,a1
	move.w	(printx).w,-(sp)
	bsr.w	PrintSetupText
	move.w	(sp)+,(printx).w
	movea.l	#TeamList,a1
	asl.w	#2,d1
	movea.l	(a1,d1.w),a1
	lsr.w	#2,d1
	adda.w	4(a1),a1
	cmp.w	#$E,d1
	bne.w	.12
	movea.l	#RangersTxt,a1
	bra.w	.13
.12
	cmp.w	#$D,d1
	bne.w	.13
	movea.l	#IslandersTxt,a1
.13
	bra.w	.4

IslandersTxt	;IDA: unk_86578. Full names for the two New York teams (TeamList has only the city)
	String	'New York Islanders'

RangersTxt	;IDA: unk_8658C
	String	'New York Rangers  '

BlankValueTxt	;IDA: unk_865A0. A blank value
	String	'                    '

NATxt	;IDA: unk_865B6. Not read in 95 (GameSetUp_4 has its own N/A String)
	String	'N/A                 '

PrintOptionName	;IDA: sub_865CC. 94 PrintOptionNames, one line. Print option name d0 (OptionNames) at printx; lines not shown print BlankNameTxt
	movem.l	d0/a1,-(sp)
	move.w	d0,-(sp)
	movea.l	#OptionNames,a1
	bra.w	.1
.0
	adda.w	(a1),a1
.1
	dbf	d0,.0
	move.w	(sp)+,d0
	cmpi.w	#3,(setupshown).w
	bne.w	.2
	cmp.w	#2,d0
	ble.w	.3
	movea.l	#BlankNameTxt,a1
.2
	cmpi.w	#1,(setupshown).w
	bne.w	.3
	tst.w	d0
	beq.w	.3
	movea.l	#BlankNameTxt,a1
.3
	cmp.w	(SelectedPlayerIdx).w,d0
	bne.w	.5
.4
	bsr.w	PrintSetupTextHi
	bra.w	.7
.5
	btst	#4,(setupcardflags).w
	beq.w	.6
	cmpi.w	#1,(SelectedPlayerIdx).w
	bne.w	.6
	cmp.w	#2,d0
	beq.s	.4
.6
	bsr.w	PrintSetupText
.7
	movem.l	(sp)+,d0/a1
	rts

BlankNameTxt	;IDA: unk_86646. A blank option name
	String	'              '

PrintSetupText	;IDA: sub_86656. 95 only. Print String a1 at printx / printy with the SetupFont chars at smallfont2chars
	move.w	(smallfontchars).w,-(sp)
	movem.l	a1,-(sp)
	move.l	#SetupFont,(smallfontptr).l
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

PrintSetupTextHi	;IDA: sub_8669A. 95 only. The same with the highlight chars (smallfont3chars)
	move.w	(smallfontchars).w,-(sp)
	movem.l	a1,-(sp)
	move.l	#SetupFont,(smallfontptr).l
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

DefaultMenus	;IDA: sub_866DE. IDA: LoadDefMenuOptions (94). Set the default menu choices for the beginning of the game: the 9 option words from
	;defmenuoptions to OptPlayMode... Sets sflags11 bit 6 and demoflag. Called once from Begin (main95)
	bset	#6,(sflags11).w
	st	(demoflag).w
	movea.l	#OptPlayMode,a0
	movea.l	#defmenuoptions,a1
	move.w	#8,d0
.0
	move.w	(a1)+,(a0)+
	dbf	d0,.0
	rts

defmenuoptions	;IDA: unk_86700 (93 DefaultMenus .defom). Mode 0, players 0, teams $E and $17, length 1, goalies 0, user records 1, penalties 0,
	;line changes 1
	dc.w	$0,$0,$E,$17,$1,$0,$1,$0
	dc.w	$1

GetSetupValues	;IDA: sub_86712. 95 only. setupvalues from the options: line 0 from ModeToSetupMode(OptPlayMode); in Regular Game (sflags11 bit 6) all 8
	;from Opt1Team ... OptLine
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(OptPlayMode).w,d0
	movea.l	#ModeToSetupMode,a0
	move.b	(a0,d0.w),(setupvalues).w
	bne.w	.0
	btst	#6,(sflags11).w
	beq.w	.0
	move.b	#1,(setupvalues).w
.0
	move.b	(Opt1Team+1).w,(setupvalues+1).w
	move.b	(Opt2Team+1).w,(setupvalues+2).w
	move.b	(OptPerlen+1).w,(setupvalues+3).w
	move.b	(OptGoalie+1).w,(setupvalues+4).w
	move.b	(OptUserRec+1).w,(setupvalues+4+1).w
	move.b	(OptPen+1).w,(setupvalues+4+2).w
	move.b	(OptLine+1).w,(setupvalues+4+3).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ModeToSetupMode	;IDA: unk_8676A. OptPlayMode 0-4 to the setup mode list (OptionValueOffsets line 0)
	dc.w	$5,$304,$CFF

SetupStart	;IDA: sub_86770. 93 setoptions .ex (94 SetupStart). Store setupvalues in the options: OptPlayMode (SetupModeToMode), the mode flags
	;(sflags10 bits 2 / 4-6 Trade / Create / Sign / Release, gmode2 bit 0 Shootout, sflags11 bit 6 Regular Game, sflags9 bit 7
	;Practice, GameFlags bits 3 / 4 season), the teams, then the other options; line changes 2 (Auto) sets sflags7 bit 4.
	;Playoff modes set sflags10 bit 0
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#setupvalues,a1
	clr.w	(OptPlayMode).w
	tst.w	(demoflag).w
	bne.w	.0
	bclr	#3,(GameFlags).w
	bclr	#5,(GameFlags).w
	bra.w	.9
.0
	movea.l	#SetupModeToMode,a0
	clr.w	d0
	move.b	(a1),d0
	move.b	(a0,d0.w),(OptPlayMode+1).w
	bclr	#2,(sflags10).w
	cmpi.b	#8,(a1)
	bne.w	.1
	bset	#2,(sflags10).w
.1
	bclr	#4,(sflags10).w
	cmpi.b	#9,(a1)
	bne.w	.2
	bset	#4,(sflags10).w
.2
	bclr	#5,(sflags10).w
	cmpi.b	#$A,(a1)
	bne.w	.3
	bset	#5,(sflags10).w
.3
	bclr	#6,(sflags10).w
	cmpi.b	#$B,(a1)
	bne.w	.4
	bset	#6,(sflags10).w
.4
	bclr	#0,(gmode2).w
	cmpi.b	#$C,(a1)
	bne.w	.5
	bset	#0,(gmode2).w
.5
	bclr	#6,(sflags11).w
	cmpi.b	#1,(a1)
	bne.w	.6
	bset	#6,(sflags11).w
.6
	bclr	#7,(sflags9).w
	cmpi.b	#2,(a1)
	bne.w	.7
	bset	#7,(sflags9).w
	move.w	#2,(homegoaliectl).w
	move.w	#2,(awaygoaliectl).w
.7
	cmp.b	#6,d0
	bne.w	.8
	bset	#3,(GameFlags).w
	bset	#4,(GameFlags).w
.8
	cmp.b	#7,d0
	bne.w	.9
	bset	#3,(GameFlags).w
	bclr	#4,(GameFlags).w
.9
	clr.w	(Opt1Team).w
	clr.w	(Opt2Team).w
	move.b	1(a1),(Opt1Team+1).w
	move.b	2(a1),(Opt2Team+1).w
	tst.w	(OptPlayMode).w
	bne.w	.10
	move.w	(Opt1Team).w,(HomeTeam).w
	move.w	(Opt2Team).w,(VisTeam).w
.10
	move.b	3(a1),(OptPerlen+1).w
	tst.w	(demoflag).w
	bne.w	.11
	move.w	#1,(OptGoalie).w
	move.w	#1,(goaliemode1).w
	move.w	#1,(goaliemode2).w
	move.w	#1,(OptUserRec).w
	move.w	#0,(OptPen).w
	move.w	#1,(OptLine).w
	bra.w	.12
.11
	move.b	4(a1),(OptGoalie+1).w
	move.w	(OptGoalie).w,(goaliemode1).w
	move.w	(OptGoalie).w,(goaliemode2).w
	move.b	5(a1),(OptUserRec+1).w
	move.b	6(a1),(OptPen+1).w
	bclr	#4,(sflags7).w
	move.b	7(a1),(OptLine+1).w
	move.w	(OptLine).w,(TmpOptLine2).w
	cmpi.w	#2,(OptLine).w
	bne.w	.12
	clr.w	(OptLine).w
	bset	#4,(sflags7).w
.12
	bclr	#0,(sflags10).w
	cmpi.w	#1,(OptPlayMode).w
	beq.w	.13
	cmpi.w	#2,(OptPlayMode).w
	beq.w	.13
	cmpi.w	#3,(OptPlayMode).w
	bne.w	.14
.13
	bset	#0,(sflags10).w
.14
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SetupModeToMode	;IDA: unk_86938. Setup mode 0-$C to OptPlayMode ($FF ends)
	dc.w	$0,$2,$301,$0,$0,$0,$4FF

setoptions	;IDA: sub_86946. options screen display (IDA comment, 94). Build the game setup screen: vbint VBlank_SetOptions, the vram map, the team
	;bitmap tiles (LoadSetupTiles), the SetupFont tiles at smallfont2chars / smallfont3chars, then the SetupBgMap1 / SetupBgMap2
	;bitmaps on maps 1 and 2
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
	jsr	(LoadSetupTiles).l
	move.w	d4,(vispicchars).w
	addi.w	#$24,d4
	move.w	d4,(homepicchars).w
	addi.w	#$24,d4
	move.w	d4,(smallfont2chars).w
	movea.l	#SetupFont+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EB;remap table
	move.w	d4,(smallfont3chars).w
	movea.l	#SetupFont+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EA;remap table
	move.w	d4,(recwins).w
	jsr	(printz).l
	String	$FF,0,0,0
	movea.l	#SetupBgMap1,a0
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
	jsr	(printz).l
	String	$FE,0,0,0
	movea.l	#SetupBgMap2,a0
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

LoadSetupTiles	;IDA: sub_86A48. IDA dc.b and code (94). Load the TeamBitmaps+8 tiles from char d4 (2)
	moveq	#2,d4
	movea.l	#TeamBitmaps+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	rts

FigureJoy	;IDA: sub_86A58 (92 / 93 FigureJoy). Set cont1team ... cont4team. In the playoffs (not Shootout, gmode2 bit 0) find this
	;round's game of the po team and set the teams and pads from .9 (94 .pojoylist; .10 with FourWayPlay); otherwise from
	;NOPJoyTbl by OptNOP. 95 has no InitializeGameStructures call here. Called from MakeTree and GameSetUp
	movem.l	d0-d3/a0-a1,-(sp)
	clr.w	(cont1team).w
	clr.w	(cont2team).w
	clr.w	(cont3team).w
	clr.w	(cont4team).w
	tst.w	(demoflag).w
	beq.w	.12
	tst.w	(OptPlayMode).w
	beq.w	.11
	btst	#0,(gmode2).w
	bne.w	.11
	bsr.w	GetShifter
	movea.w	#(potree-M68K_RAM),a0
	move.w	(potreeteam).w,d2
	move.b	(a0,d2.w),d2
	movea.w	#(gsstruct-M68K_RAM),a1
	moveq	#$10,d4
	mulu.w	d1,d4
	adda.w	d4,a1
	st	(gamenum).w
	clr.w	d0
.0
	cmp.w	(a1),d2
	beq.w	.3
	cmp.w	2(a1),d2
	beq.w	.1
	suba.w	#$10,a1
	dbf	d1,.0
	bra.w	.12
.1
	moveq	#4,d0
	tst.w	(FourWayPlay).w
	beq.w	.2
	move.w	#5,d0
.2
	move.w	(a1),(Opt2Team).w
	move.w	2(a1),(Opt1Team).w
	bra.w	.4
.3
	clr.w	d0
	move.w	2(a1),(Opt2Team).w
	move.w	(a1),(Opt1Team).w
.4
	add.w	(pojoy).w,d0
	move.w	d1,(gamenum).w
	move.w	(a1),(HomeTeam).w
	move.w	2(a1),(VisTeam).w
	asl.w	#2,d0
	lea	.9(pc),a0
	tst.w	(FourWayPlay).w
	beq.w	.5
	lea	.10(pc),a0
.5
	move.w	(a0,d0.w),(cont1team).w
	move.w	2(a0,d0.w),(cont2team).w
	tst.w	(FourWayPlay).w
	beq.w	.12
	cmp.w	#4,d0
	beq.w	.6
	cmp.w	#$18,d0
	beq.w	.6
	bra.w	.7
.6
	move.w	(cont1team).w,(cont3team).w
	move.w	(cont2team).w,(cont4team).w
	bra.w	.12
.7
	cmp.w	#8,d0
	beq.w	.8
	cmp.w	#$1C,d0
	beq.w	.8
	bra.w	.12
.8
	move.w	(cont1team).w,(cont3team).w
	move.w	#0,(cont4team).w
	bra.w	.12
.9
	dc.w	$1,$0,$1,$1,$1,$2,$2,$1
	dc.w	$2,$0,$2,$2,$2,$1,$1,$2
.10
	dc.w	$1,$0,$1,$2,$1,$2,$1,$1
	dc.w	$1,$2,$2,$0,$2,$1,$2,$1
	dc.w	$2,$2,$2,$1
.11
	move.w	(OptNOP).w,d0
	asl.w	#2,d0
	lea	NOPJoyTbl(pc),a0
	move.w	(a0,d0.w),(cont1team).w
	move.w	2(a0,d0.w),(cont2team).w
.12
	movem.l	(sp)+,d0-d3/a0-a1
	rts

NOPJoyTbl	;IDA: unk_86BCC. IDA: _noplist (94 FigureJoy .noplist). cont1team, cont2team by OptNOP
	dc.w	$0,$0,$1,$0,$2,$0,$1,$1
	dc.w	$1,$2,$1,$2,$1,$2

OptionNames	;IDA: unk_86BE8. Option names (93 setoptions .text); 95 adds no Players line
	String	'Play Mode    '
	String	'Team 1       '
	String	'Team 2       '
	String	'Per. Length  '
	String	'Goalies      '
	String	'User Records '
	String	'Penalties    '
	String	'Line Changes '

OptionValueOffsets	;IDA: unk_86C68. Offsets of each option's value Strings from OptionValueOffsets (93 setoptions .pl): mode, the two teams (not read), length,
	;goalies, user records, penalties, line changes. 95 has 13 modes
	dc.w	$10,$1F0,$1F0,$12A,$182,$1F0,$1AE,$21C
	String	'Game With Trades    '
	String	'Regular Game        '
	String	'Practice Mode       '
	String	'New Playoffs        '
	String	'New Playoffs/7 game '
	String	'Continue Playoffs   '
	String	'New Season          '
	String	'Continue Season     '
	String	'Trade Players       '
	String	'Create Player',$9,$9,' '
	String	'Sign Free Agents    '
	String	'Release Players     '
	String	'Shootout            '
	String	'5 Minutes           '
	String	'10 Minutes          '
	String	'20 Minutes          '
	String	'30 Seconds          '
	String	'Manual Control      '
	String	'Auto Control        '
	String	'Off                 '
	String	'On                  '
	String	'On, Except Off-sides'
	String	'On                  '
	String	'Off                 '
	String	'On                  '
	String	'Off                 '
	String	'Auto                '

DrawMatchupBitmaps	;IDA: sub_86EC6. 94 only (attract94). For the modes after Practice draw the VisTeam bitmap at $DF,8,1 and the HomeTeam bitmap at
	;$CF,$15,1 (DrawTeamBitmap) with their TeamLogoPalettes colors
	movem.l	d0-d7/a0-a2,-(sp)
	cmpi.b	#2,(setupvalues).w
	ble.w	.0
	cmpi.b	#3,(setupvalues).w
	beq.w	.1
	cmpi.b	#4,(setupvalues).w
	beq.w	.1
	cmpi.b	#5,(setupvalues).w
	beq.w	.1
.0
	move.b	(setupvalues+1).w,(HomeTeam+1).w
	move.b	(setupvalues+2).w,(VisTeam+1).w
.1
	jsr	(printz).l
	String	$DF,$8,$1,$0
	move.w	(VisTeam).w,d1
	move.w	d1,d0
	asl.w	#5,d0
	movea.l	#TeamLogoPalettes,a0
	move.l	2(a0,d0.w),(palfadenew+$62).w
	move.w	#$EEE,(palfadenew+$6A).w
	move.w	#2,d4
	bsr.w	DrawTeamBitmap
	jsr	(printz).l
	String	$CF,$15,$1,$0
	move.w	(HomeTeam).w,d1
	move.w	d1,d0
	asl.w	#5,d0
	movea.l	#TeamLogoPalettes,a0
	move.l	2(a0,d0.w),(palfadenew+$42).w
	move.w	#$EEE,(palfadenew+$4A).w
	move.w	#2,d4
	bsr.w	DrawTeamBitmap
	move.w	#$64,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a2
	rts

DrawTeamBitmap	;IDA: sub_86F66. 94 only (attract94). dobitmap entry d1 of TeamBitmaps (d4 from the caller)
	clr.w	d0
	asl.w	#1,d1
	movea.l	#TeamBitmaps,a0
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	move.w	(a1),d2
	moveq	#2,d3
	moveq	#0,d5
	jmp	dobitmap

UpdateSetupLogos	;IDA: sub_86F88. 95 only. When a team changed (setuphome / setupvis against setupvalues 1 / 2) erase the card text (EraseCardText),
	;restart carddelay and draw the changed team's block (DrawHomeBlock / DrawVisBlock)
	bclr	#6,(setupcardflags).w
	bne.w	.0
	move.b	(setuphome+1).w,d0
	cmp.b	(setupvalues+1).w,d0
	bne.w	.0
	move.b	(setupvis+1).w,d0
	cmp.b	(setupvalues+2).w,d0
	beq.w	.7
.0
	tst.w	(carddelay).w
	bpl.w	.1
	bsr.w	EraseCardText
.1
	move.w	#$B4,(carddelay).l
	move.b	(setupvalues+1).w,(logoteam+1).w
	move.w	(logoteam).w,(setuphome).w
	cmpi.b	#3,(setupvalues).w
	beq.w	.2
	cmpi.b	#4,(setupvalues).w
	beq.w	.2
	cmpi.b	#5,(setupvalues).w
	bne.w	.3
.2
	movem.w	d0,-(sp)
	move.w	(logoteam).w,d0
	cmp.w	(HomeTeam).w,d0
	movem.w	(sp)+,d0
	beq.w	.3
	bsr.w	DrawVisBlock
	bra.w	.4
.3
	bsr.w	DrawHomeBlock
.4
	move.b	(setupvalues+2).w,(logoteam+1).w
	move.w	(logoteam).w,(setupvis).w
	cmpi.b	#3,(setupvalues).w
	beq.w	.5
	cmpi.b	#4,(setupvalues).w
	beq.w	.5
	cmpi.b	#5,(setupvalues).w
	bne.w	.6
.5
	movem.w	d0,-(sp)
	move.w	(logoteam).w,d0
	cmp.w	(VisTeam).w,d0
	movem.w	(sp)+,d0
	beq.w	.6
	bsr.w	DrawHomeBlock
	bra.w	.7
.6
	bsr.w	DrawVisBlock
.7
	rts

DrawHomeBlock	;IDA: sub_87054. 94 only (rewritten). Erase the right logo (setupcardflags bit 3 was set) and draw logo logoteam at x $21
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#2,(setupcardflags).w
	bclr	#3,(setupcardflags).w
	beq.w	.0
	jsr	(printz).l
	String	$EF,$0,$0,$0
	move.w	#0,(printx).w
	move.w	#0,(printy).w
	moveq	#8,d0
	moveq	#8,d1
	move.w	#$7FF,d2
.0
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	#$21,(printx).w
	bra.w	DrawSetupLogo

DrawVisBlock	;IDA: sub_8709E. 94 only (rewritten). Erase the left logo (setupcardflags bit 2 was set) and draw logo logoteam at x 1
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#3,(setupcardflags).w
	bclr	#2,(setupcardflags).w
	beq.w	.0
	jsr	(printz).l
	String	$EF,$0,$0,$0
	move.w	#$20,(printx).w
	move.w	#0,(printy).w
	moveq	#8,d0
	moveq	#8,d1
	move.w	#$7FF,d2
.0
	jsr	(printz).l
	String	$CF,$0,$0,$0
	move.w	#1,(printx).w

DrawSetupLogo	;IDA: loc_870E4. 94 optsetup94 DrawTeamLogo. Draw the logo of team logoteam (TeamLogoBitmaps) at printx, 6 x 6, palette TeamLogoPalettes
	;+ team * $20 - $20 (bit 2: home) or - $40. Branched to from DrawHomeBlock; the name DrawTeamLogo is video95_03's
	move.w	#1,(printy).w
	move.w	(homepicchars).w,d4
	btst	#2,(setupcardflags).w
	bne.w	.0
	move.w	(vispicchars).w,d4
.0
	move.w	(logoteam).w,d3
	asl.w	#2,d3
	movea.l	#TeamLogoBitmaps,a0
	movea.l	(a0,d3.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	asl.w	#3,d3
	movea.l	#TeamLogoPalettes,a0
	btst	#2,(setupcardflags).w
	beq.w	.1
	subi.w	#$20,d3
	bra.w	.2
.1
	subi.w	#$40,d3
.2
	adda.w	d3,a0
	adda.l	(a2)+,a1
	move.w	#6,d3
	move.w	#6,d2
	clr.w	d0
	clr.w	d1
	move.l	(palfadenew+$22).w,-(sp)
	move.l	(palfadenew+$26).w,-(sp)
	move.w	#4,d5
	btst	#2,(setupcardflags).w
	beq.w	.3
	move.w	#2,d5
.3
	jsr	(dobitmap).l
	move.l	(sp)+,(palfadenew+$26).w
	move.l	(sp)+,(palfadenew+$22).w
	move.w	#$64,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PlayerCardTimer	;IDA: sub_87174. 94 only. Player cards, called each frame from GameSetUp_2 while carddelay has run out: every cardtimer frames switch
	;sides (setupcardflags bit 1), erase the card (GetBlankChar) and draw the next of 6 featured players of HomeTeam / VisTeam:
	;the picture (GetPlayerPicture, NoPlayerPicture) unpacked to picturebuf and drawn, then the name (GetRosterName) and number
	cmpi.w	#1,(setupshown).w
	beq.w	.0
	tst.w	(carddelay).w
	bmi.w	.1
.0
	rts
.1
	subq.w	#1,(cardtimer).w
	bpl.s	.0
	move.w	#$B4,(cardtimer).w
	btst	#5,(setupcardflags).w
	beq.w	.2
	move.w	#$A,(cardtimer).w
.2
	movem.l	d0-d7/a0-a6,-(sp)
	bchg	#1,(setupcardflags).w
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	#$21,(printx).w
	btst	#1,(setupcardflags).w
	bne.w	.3
	move.w	#1,(printx).w
.3
	move.w	#1,(printy).w
	move.w	#6,d0
	move.w	#6,d1
	bsr.w	GetBlankChar
	jsr	(eraser).l
	bsr.w	EraseCardText
	btst	#1,(setupcardflags).w
	bne.w	.4
	bra.w	.5
.4
	addq.w	#1,(featuredplayer).w
.5
	jsr	(printz).l
	String	$FF,$0,$0,$0
	cmpi.w	#6,(featuredplayer).l
	blt.w	.6
	clr.w	(featuredplayer).w
.6
	move.w	(HomeTeam).w,d0
	move.w	#$21,(printx).w
	btst	#1,(setupcardflags).w
	beq.w	.7
	move.w	(VisTeam).w,d0
	move.w	#1,(printx).w
.7
	move.w	#1,(printy).w
	move.w	(homepicchars).w,d4
	move.w	d0,d1
	move.w	(featuredplayer).w,d0
	movea.l	#$207C28,a0
	move.w	d7,-(sp)
	move.w	d1,d7
	mulu.w	#$82,d7
	adda.l	d7,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	andi.w	#$FF,d0
	subq.w	#1,d0
	move.w	d0,(cardroster).w
	move.w	(sp)+,d7
	move.w	(featuredplayer).w,d0
	jsr	(GetPlayerPicture).l
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	movea.l	#NoPlayerPicture,a0
	adda.l	(a0),a0
	tst.l	(a2)
	bne.w	.8
	movea.l	#NoPlayerPicture,a1
	adda.l	4(a1),a1
	tst.l	(a2)+
	bra.w	.9
.8
	adda.l	(a2)+,a1
.9
	jsr	(UnpackPicture).l
	movea.l	#picturebuf,a2
	move.w	(vcount).w,d3
.10
	cmp.w	(vcount).w,d3
	beq.s	.10
	move.w	#6,d3
	move.w	#6,d2
	clr.w	d0
	clr.w	d1
	move.l	(palfadenew+$22).w,-(sp)
	move.l	(palfadenew+$26).w,-(sp)
	move.w	#2,d5
	jsr	(dobitmap).l
	move.l	(sp)+,(palfadenew+$26).w
	move.l	(sp)+,(palfadenew+$22).w
	move.w	#9,(cardprintx).w
	move.w	#9,(cardprinty).w
	move.w	(cardprintx).w,(printx).w
	move.w	(cardprinty).w,(printy).w
	move.w	(HomeTeam).w,d0
	btst	#1,(setupcardflags).w
	beq.w	.11
	move.w	(VisTeam).w,d0
.11
	move.w	d0,(cardteamnum).w
	movem.l	d0/d7/a1,-(sp)
	move.w	d0,d7
	move.w	(cardroster).w,d0
	jsr	(GetRosterName).l
	movea.l	a1,a2
	movem.l	(sp)+,d0/d7/a1
	movea.l	#mesarea,a3
	lea	2(a3),a1
	move.w	#6,(a3)
	move.l	a2,-(sp)
	adda.w	(a2),a2
	move.b	(a2),d0
	ext.w	d0
	jsr	(d0toascii).l
	move.w	#$2000,4(a3)
	movea.l	(sp)+,a1
	jsr	(appstring).l
	movea.l	a3,a1
	jsr	(PrintSetupTextHi).l
	move.w	#$A,(cardprintx).w
	move.w	#4,(cardprinty).w
	movea.l	#mesarea,a1
	move.w	(cardteamnum).w,d0
	move.w	(cardroster).w,d1
	tst.w	(ValidSRAM).w
	bmi.w	*+4	;to the next instruction
.12
	move.w	#$64,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ResetCardTimer	;IDA: sub_8737A. 94 only. Card timer cardtimer = $2D, featuredplayer 0, setupcardflags bit 1 clear
	move.w	#$2D,(cardtimer).w
	clr.w	(featuredplayer).w
	bclr	#1,(setupcardflags).w
	rts

GetBlankChar	;IDA: sub_8738C. 95 only. d2 = the blank char of the setup font (recwins + $C)
	move.w	(recwins).w,d2
	addi.w	#$C,d2
	rts

EraseCard	;IDA: sub_87396. 94 only. Erase both card areas (6 x 6 at x $21 and x 1), then the card text (EraseCardText)
	jsr	(printz).l
	String	$FF,$0,$0,$0
	move.w	#$21,(printx).w
	move.w	#1,(printy).w
	move.w	#6,d0
	move.w	#6,d1
	bsr.s	GetBlankChar
	movem.w	d0-d2,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
	movem.w	(sp)+,d0-d2
	move.w	#1,(printx).w
	jsr	(eraser).l
	jsr	(EraseCardText).l
	rts

ClearLogoPalettes	;IDA: sub_873E2. 95 only. Clear the two logo palette longs and set palcount
	move.l	#0,(palfadenew+$62).w
	clr.w	(palfadenew+$6A).w
	move.l	#0,(palfadenew+$42).w
	clr.w	(palfadenew+$4A).w
	move.w	#$64,(palcount).w
	rts

StepSeasonTeam	;IDA: sub_87402. 95 only. Step the season matchup (setupdir 2: PrevSeasonTeam, else NextSeasonTeam) until one is found; setupvalues
	;1 / 2 = its two teams from SeasonTeams
	cmpi.w	#2,(setupdir).w
	beq.w	.0
	jsr	(NextSeasonTeam).l
	bra.w	.1
.0
	jsr	(PrevSeasonTeam).l
.1
	tst.w	(seasonteamsel).w
	bmi.s	StepSeasonTeam
	move.l	a1,-(sp)
	movea.l	#SeasonTeams,a1
	adda.w	(seasonteamsel).w,a1
	move.b	(a1),1(a0)
	move.b	1(a1),2(a0)
	movea.l	(sp)+,a1
	rts

SetPojoyMode	;IDA: sub_8743C. 94 only (attract94). Set pojoy from the number of players for play modes 2 and 3 (7, or $B with FourWayPlay, - OptNOP)
	cmpi.w	#2,(OptPlayMode).w
	blt.w	.1
	cmpi.w	#4,(OptPlayMode).w
	beq.w	.1
	moveq	#7,d0
	tst.w	(FourWayPlay).w
	beq.w	.0
	move.w	#$B,d0
.0
	sub.w	(OptNOP).w,d0
	move.w	d0,(pojoy).w
.1
	rts

InitializeGameStructures	;IDA: sub_87468. 93 name. Random team pairs for all 8 gsstruct games, none of them HomeTeam or VisTeam. IDA dc.b. No caller
	st	(gamenum).w
	clr.l	d3
	move.w	(HomeTeam).w,d1
	bset	d1,d3
	move.w	(VisTeam).w,d1
	bset	d1,d3
	movea.w	#$CA24,a1
	moveq	#7,d2
.0
	bsr.w	OptionRNG
	move.w	d0,(a1)
	bsr.w	OptionRNG
	move.w	d0,2(a1)
	adda.w	#$10,a1
	dbf	d2,.0
	rts

OptionRNG	;IDA: sub_87498 (93 GetRandomUnusedTeam). d0 = a random team 0-25 not yet set in d3, and set its bit
	moveq	#$1A,d0
	jsr	(randomd0).l
	bset	d0,d3
	bne.s	OptionRNG
	rts

ReadPassBits	;IDA: sub_874A6. 93 name. Translate the saved bits at a3 (5 words) to the playoff variables; the 5 words are kept
	moveq	#4,d0
	lea	$A(a3),a0
.0
	move.w	-(a0),-(sp)
	dbf	d0,.0
	moveq	#7,d2
	movea.w	#(gsstruct+$70-M68K_RAM),a1
.1
	bclr	#2,$E(a1)
	moveq	#5,d0
	bsr.w	SuperDiv
	move.w	d0,6(a1)
	cmp.w	#4,d0
	bne.w	.2
	bset	#2,$E(a1)
.2
	moveq	#5,d0
	bsr.w	SuperDiv
	move.w	d0,4(a1)
	cmp.w	#4,d0
	bne.w	.3
	bset	#2,$E(a1)
.3
	suba.w	#$10,a1
	dbf	d2,.1
	move.w	#$4000,d0
	bsr.w	SuperDiv
	move.w	d0,(WinBits).w
	move.w	#8,d0
	bsr.w	SuperDiv
	move.w	d0,(pojoy).w
	tst.w	(FourWayPlay).w
	beq.w	.5
	cmpi.w	#1,(pojoy).w
	bne.w	.4
	move.w	#3,(pojoy).w
	bra.w	.5
.4
	cmpi.w	#2,(pojoy).w
	bne.w	.5
	move.w	#4,(pojoy).w
.5
	moveq	#$10,d0
	bsr.w	SuperDiv
	move.w	d0,(potreeteam).w
	moveq	#4,d0
	bsr.w	SuperDiv
	move.w	d0,(gamelevel).w
	moveq	#8,d0
	bsr.w	SuperDiv
	move.w	d0,(bosgames).w
	moveq	#$20,d0
	bsr.w	SuperDiv
	move.w	d0,(postarts).w
	moveq	#4,d0
	lea	(a3),a0
.6
	move.w	(sp)+,(a0)+
	dbf	d0,.6
	rts

EncodePW	;IDA: sub_8756E. 93 name. After a playoff game compute winners and save the bits if needed
	tst.w	(OptNOP).w
	beq.w	.1
	tst.w	(OptPlayMode).w
	beq.w	.1
	cmpi.w	#4,(OptPlayMode).w
	beq.w	.1
	move.w	#1,(OptPlayMode).w
	move.w	#1,(TempOptPlayMode).w
	bsr.w	ResolveGames
	bsr.w	MakeTree
	cmpi.w	#4,(gamelevel).w
	beq.w	.0
	tst.w	(gamenum).w
	bmi.w	.0
	movea.w	#(pwddatabuffer-M68K_RAM),a3
	bsr.w	WritePassBits
	jsr	(WriteLineData).l
	btst	#2,(sflags3).w
	beq.w	.1
	movea.w	#(tpassbits-M68K_RAM),a3
	bsr.w	ReadPassBits
	bra.w	MakeTree
.0
	movea.w	#(pwddatabuffer-M68K_RAM),a3
	bsr.w	ClrPassBits
	jsr	(WriteLineData).l
	move.w	#2,(OptPlayMode).w
	move.w	#2,(TempOptPlayMode).w
	cmpi.w	#7,(bosgames).w
	beq.w	.1
	move.w	#3,(OptPlayMode).w
	move.w	#3,(TempOptPlayMode).w
.1
	rts

WritePassBits	;IDA: sub_87604. 93 name. Transfer the game variables to the bits at a3
	bsr.w	ClrPassBits
	move.w	(postarts).w,d0
	moveq	#$20,d1
	bsr.w	PushBits
	move.w	(bosgames).w,d0
	moveq	#8,d1
	bsr.w	PushBits
	move.w	(gamelevel).w,d0
	moveq	#4,d1
	bsr.w	PushBits
	move.w	(potreeteam).w,d0
	moveq	#$10,d1
	bsr.w	PushBits
	move.w	(pojoy).w,d0
	moveq	#8,d1
	bsr.w	PushBits
	move.w	(WinBits).w,d0
	move.w	#$4000,d1
	bsr.w	PushBits
	moveq	#5,d1
	moveq	#7,d2
	movea.w	#(gsstruct-M68K_RAM),a1
.0
	move.w	4(a1),d0
	bsr.w	PushBits
	move.w	6(a1),d0
	bsr.w	PushBits
	adda.w	#$10,a1
	dbf	d2,.0
	rts

PushBits	;IDA: sub_87668. 93 name. bits = bits * d1 + d0. d1 = range 2^1-2^15, d0 = data
	movem.l	d0-d1,-(sp)
	exg	d0,d1
	bsr.w	SuperMult
	clr.l	d0
	move.w	d1,d0
	bsr.w	SuperAdd
	movem.l	(sp)+,d0-d1
	rts

ClrPassBits	;IDA: sub_87680. 93 name. Clear the 5 words of bits at a3
	movea.w	a3,a0
	moveq	#4,d0
.0
	clr.w	(a0)+
	dbf	d0,.0
	rts

SuperAdd	;IDA: sub_8768C. 93 name. 1 long (d0.L) added to the 5 words at a3
	movem.l	d1/a0,-(sp)
	lea	$A(a3),a0
	moveq	#3,d1
	add.l	d0,-(a0)
	bra.w	.1
.0
	addq.w	#1,-(a0)
.1
	dbcc	d1,.0
	movem.l	(sp)+,d1/a0
	rts

SuperMult	;IDA: sub_876A8. 93 name. 1 word (d0) multiplied by the 5 words at a3
	movem.l	d1-d4/a0,-(sp)
	movea.w	a3,a0
	moveq	#4,d4
.0
	move.w	(a0),-(sp)
	clr.w	(a0)+
	dbf	d4,.0
	moveq	#4,d4
.1
	move.w	d0,d1
	mulu.w	(sp)+,d1
	lea	2(a3),a0
	adda.w	d4,a0
	adda.w	d4,a0
	move.w	d4,d2
	add.l	d1,-(a0)
	bra.w	.3
.2
	addq.w	#1,-(a0)
.3
	dbcc	d2,.2
	dbf	d4,.1
	movem.l	(sp)+,d1-d4/a0
	rts

SuperDiv	;IDA: sub_876DE. 93 name. 5 words at a3 divided by 1 word (d0); d0 = remainder on exit
	movem.l	d1-d2/a0,-(sp)
	movea.w	a3,a0
	moveq	#4,d1
	clr.l	d2
.0
	move.w	(a0),d2
	divu.w	d0,d2
	move.w	d2,(a0)+
	dbf	d1,.0
	swap	d2
	move.w	d2,d0
	movem.l	(sp)+,d1-d2/a0
	rts

GetShifter	;IDA: sub_876FC (92 / 93 GetShifter). Returns d1 = number of games - 1, d2 = first bit of WinBits
	move.l	d0,-(sp)
	moveq	#-$10,d2
	moveq	#$10,d1
	move.w	(gamelevel).w,d0
.0
	add.w	d1,d2
	lsr.w	#1,d1
	dbf	d0,.0
	subq.w	#1,d1
	move.l	(sp)+,d0
	rts

AddPOStats	;IDA: sub_87714 (93 DisplayTeamStatsForPlayoffs). Add the po team's game stats to its packed playoff totals. Called from hockey95
	cmpi.w	#1,(OptPlayMode).w
	blt.w	.4
	bsr.w	ReadTeamStats
	movea.w	#(potree-M68K_RAM),a0
	move.w	(potreeteam).w,d2
	move.b	(a0,d2.w),d2
	movea.w	#(HmShots-M68K_RAM),a2
	cmp.w	$28(a2),d2
	beq.w	.0
	adda.w	#$366,a2
.0
	adda.w	#$B6,a2
	moveq	#$67,d0
	movea.w	#(statsbuffer-M68K_RAM),a1
.1
	clr.w	d1
	move.b	(a2)+,d1
	add.w	d1,(a1)+
	dbf	d0,.1
	movea.w	#(statsbuffer-M68K_RAM),a0
	movea.l	#BitWidthTable,a1
	movea.w	#(outputbuffer-M68K_RAM),a2
	moveq	#$67,d0
	clr.w	d4
.2
	clr.l	d1
	move.w	(a0)+,d1
	move.w	d0,d2
	andi.w	#3,d2
	move.b	(a1,d2.w),d2
	clr.l	d3
	bset	d2,d3
	subq.w	#1,d3
	cmp.w	d3,d1
	ble.w	.3
	move.w	d3,d1
.3
	not.l	d3
	move.w	d4,d5
	andi.w	#$F,d5
	rol.l	d5,d3
	rol.l	d5,d1
	move.w	d4,d5
	lsr.w	#4,d5
	add.w	d5,d5
	neg.w	d5
	addi.w	#$100,d5
	and.l	d3,-$22(a2,d5.w)
	or.l	d1,-$22(a2,d5.w)
	add.w	d2,d4
	dbf	d0,.2
.4
	rts

BitWidthTable	;IDA: unk_877A8. 93 name. Playoff stat bit widths, indexed by stat number & 3
	dc.w	$C0E,$A0A

ReadTeamStats	;IDA: sub_877AC. 93 name. Unpack the playoff stat totals from the bit stream into statsbuffer words
	movea.w	#(statsbuffer-M68K_RAM),a0
	movea.l	#BitWidthTable,a1
	movea.w	#(outputbuffer-M68K_RAM),a2
	moveq	#$67,d0
	clr.w	d4
.0
	move.w	d4,d5
	lsr.w	#4,d5
	add.w	d5,d5
	neg.w	d5
	addi.w	#$100,d5
	move.l	-$22(a2,d5.w),d1
	move.w	d4,d5
	andi.w	#$F,d5
	lsr.l	d5,d1
	move.w	d0,d2
	andi.w	#3,d2
	move.b	(a1,d2.w),d2
	add.w	d2,d4
	clr.w	d3
	bset	d2,d3
	subq.w	#1,d3
	and.w	d3,d1
	move.w	d1,(a0)+
	dbf	d0,.0
	rts

ResolveGames	;IDA: sub_877F2. 93 name. Compute winners and losers for playoff matchups
	move.w	(gamenum).w,d0
	mulu.w	#$10,d0
	movea.w	#(gsstruct-M68K_RAM),a0
	move.w	(HmGoals).w,$A(a0,d0.w)
	move.w	(AwGoals).w,$C(a0,d0.w)
	bsr.w	GetShifter
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d3
	mulu.w	d1,d3
	adda.w	d3,a0
	cmpi.w	#7,(bosgames).w
	beq.w	.11
.0
	cmpi.w	#4,4(a0)
	beq.w	.3
	cmpi.w	#4,6(a0)
	beq.w	.3
	clr.w	d3
	btst	#0,$E(a0)
	beq.w	.1
	eori.w	#2,d3
.1
	move.w	$A(a0),d0
	sub.w	$C(a0),d0
	bpl.w	.2
	eori.w	#2,d3
.2
	addq.w	#1,4(a0,d3.w)
.3
	suba.w	#$10,a0
	dbf	d1,.0
	addq.w	#1,(bosgames).w
	cmpi.w	#7,(bosgames).w
	beq.w	.7
	move.w	(gamenum).w,d0
	mulu.w	#$10,d0
	movea.w	#(gsstruct-M68K_RAM),a0
	adda.w	d0,a0
	cmpi.w	#4,4(a0)
	beq.w	.4
	cmpi.w	#4,6(a0)
	bne.w	.10
.4
	cmpi.w	#3,(gamelevel).w
	bge.w	.7
	bsr.w	GetShifter
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d3
	mulu.w	d1,d3
	adda.w	d3,a0
.5
	cmp.w	(gamenum).w,d1
	beq.w	.6
	cmpi.w	#4,4(a0)
	beq.w	.6
	cmpi.w	#4,6(a0)
	beq.w	.6
	addq.w	#1,4(a0)
	move.l	#$C8,d0
	jsr	(randomd0).l
	andi.w	#1,d0
	beq.s	.5
	subq.w	#1,4(a0)
	addq.w	#1,6(a0)
	bra.s	.5
.6
	suba.w	#$10,a0
	dbf	d1,.5
	movea.w	#(tpassbits-M68K_RAM),a3
	bsr.w	WritePassBits
	bset	#2,(sflags3).w
.7
	clr.w	(bosgames).w
	bsr.w	GetShifter
	movea.w	#(gsstruct-M68K_RAM),a0
	moveq	#$10,d3
	mulu.w	d1,d3
	adda.w	d3,a0
	clr.w	d3
.8
	cmpi.w	#4,4(a0)
	beq.w	.9
	bset	d1,d3
.9
	clr.w	4(a0)
	clr.w	6(a0)
	suba.w	#$10,a0
	dbf	d1,.8
	moveq	#1,d1
	asl.w	d2,d1
	subq.w	#1,d1
	and.w	d1,(WinBits).w
	asl.w	d2,d3
	or.w	d3,(WinBits).w
	addq.w	#1,(gamelevel).w
.10
	rts
.11
	clr.w	d3
.12
	move.w	$A(a0),d0
	cmp.w	$C(a0),d0
	bhi.w	.13
	bset	d1,d3
.13
	btst	#0,$E(a0)
	beq.w	.14
	bchg	d1,d3
.14
	suba.w	#$10,a0
	dbf	d1,.12
	moveq	#1,d1
	asl.w	d2,d1
	subq.w	#1,d1
	and.w	d1,(WinBits).w
	asl.w	d2,d3
	or.w	d3,(WinBits).w
	addq.w	#1,(gamelevel).w
	rts

ContinuePlayoffs	;IDA: sub_8797C (93 NewPO). Continue playoffs: read the saved bits (ReadPassBits from pwddatabuffer); after the first
	;game rebuild the tree (MakeTree) and set OptNOP = 7 (or $B with FourWayPlay) - pojoy, pojoy moved to the 95 values
	movem.l	d0-d7/a0-a3,-(sp)
	movea.w	#(pwddatabuffer-M68K_RAM),a3
	bsr.w	ReadPassBits
	move.w	(gamelevel).w,d0
	or.w	(bosgames).w,d0
	beq.w	.4
	bsr.w	MakeTree
	moveq	#7,d0
	tst.w	(FourWayPlay).w
	beq.w	.0
	move.w	#$B,d0
.0
	tst.w	(FourWayPlay).w
	bne.w	.1
	cmpi.w	#2,(pojoy).w
	ble.w	.3
	subq.w	#2,(pojoy).w
	bra.w	.3
.1
	cmpi.w	#1,(pojoy).w
	bne.w	.2
	move.w	#3,(pojoy).w
	bra.w	.3
.2
	cmpi.w	#2,(pojoy).w
	bne.w	.3
	move.w	#4,(pojoy).w
.3
	sub.w	(pojoy).w,d0
	move.w	d0,(OptNOP).w
.4
	movem.l	(sp)+,d0-d7/a0-a3
	rts

NewPO	;IDA: sub_879F2 (93 SelectRandomPlayoffTree). New playoff tree with Opt1Team (a random
	;playoffseats row that has it), bosgames 7 and MakeTree for OptPlayMode 2; otherwise bosgames 0, the gsstruct wins cleared, and falls into MakeTree
	moveq	#$20,d0
	jsr	(randomd0).l
.0
	addq.w	#1,d0
	andi.w	#$1F,d0
	asl.w	#4,d0
	movea.l	#playoffseats,a0
	adda.w	d0,a0
	lsr.w	#4,d0
	moveq	#$F,d1
	move.w	(Opt1Team).w,d2
	cmp.w	#$19,d2
	bls.w	.1
	moveq	#$19,d2
.1
	cmp.b	(a0)+,d2
	dbeq	d1,.1
	bne.s	.0
	eori.w	#$F,d1
	move.w	d1,(potreeteam).w
	move.w	d0,(postarts).w
	clr.w	(gamelevel).w
	move.w	#7,(bosgames).w
	cmpi.w	#2,(OptPlayMode).w
	beq.w	MakeTree
	clr.w	(bosgames).w
	moveq	#7,d0
	movea.w	#(gsstruct-M68K_RAM),a0
.2
	clr.w	4(a0)
	clr.w	6(a0)
	adda.w	#$10,a0
	dbf	d0,.2

MakeTree	;IDA: sub_87A5E (93 maketree). Make the playoff tree (potree) from playoffseats and WinBits, then FigureJoy
	movem.l	d0-d4/a0-a3,-(sp)
	move.w	(postarts).w,d1
	asl.w	#4,d1
	movea.w	#(potree-M68K_RAM),a0
	movea.l	#playoffseats,a1
	adda.w	d1,a1
	move.l	(a1),(a0)
	move.l	4(a1),4(a0)
	move.l	8(a1),8(a0)
	move.l	$C(a1),$C(a0)
	lea	$10(a0),a1
	moveq	#$E,d2
	move.w	(WinBits).w,d0
.0
	move.w	d0,d1
	andi.w	#1,d1
	move.b	(a0,d1.w),(a1)+
	addq.w	#2,a0
	lsr.w	#1,d0
	dbf	d2,.0
	bsr.w	GetShifter
	tst.w	d1
	bmi.w	.2
	movea.w	#(potree-M68K_RAM),a0
	adda.w	d2,a0
	adda.w	d2,a0
	movea.w	#(gsstruct-M68K_RAM),a1
.1
	clr.w	$A(a1)
	clr.w	$C(a1)
	clr.w	8(a1)
	bclr	#1,$E(a1)
	bsr.w	SetTreeGameTeams
	adda.w	#$10,a1
	dbf	d1,.1
	bsr.w	FigureJoy
.2
	movem.l	(sp)+,d0-d4/a0-a3
	rts

SetTreeGameTeams	;IDA: sub_87AE2. 95 only (94 MakeTree inline). Put the two teams at a0 in game a1: flipped (gsstruct flags bit 0) except for
	;bosgames 2, 3 and 5
	cmpi.w	#2,(bosgames).w
	beq.w	.0
	cmpi.w	#3,(bosgames).w
	beq.w	.0
	cmpi.w	#5,(bosgames).w
	beq.w	.0
	bset	#0,$E(a1)
	move.b	(a0)+,3(a1)
	move.b	(a0)+,1(a1)
	rts
.0
	bclr	#0,$E(a1)
	move.b	(a0)+,1(a1)
	move.b	(a0)+,3(a1)
	rts

CheckPlayoffsStarted	;IDA: sub_87B20. 95 only. ContinuePlayoffs, then d0 = gamelevel | bosgames (0 = no game played yet). Called from FixModeOptions
	jsr	(ContinuePlayoffs).l
	move.w	(gamelevel).w,d0
	or.w	(bosgames).w,d0
	rts

ReadLineData	;IDA: sub_87B30 (94 title94). Read the saved lines from save RAM. Called from GameSetUp and main95
	movem.l	d0-d1/a0,-(sp)
	move.l	#$100,d1
	move.l	#$7EF6,d0
	movea.l	#databuffer,a0
	jsr	(ReadSRAM).l
	bclr	#4,(sflags).w
	move.w	#$FFFF,(lastsfx).w
	move.l	#$FFFF0000,(recbpr).w
	movem.l	(sp)+,d0-d1/a0
	rts

WriteLineData	;IDA: sub_87B66 (94 title94). Write the lines to save RAM and the checksum
	movem.l	d0-d1/a0,-(sp)
	move.l	#$100,d1
	move.l	#$7EF6,d0
	movea.l	#databuffer,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	bclr	#4,(sflags).w
	move.w	#$FFFF,(lastsfx).w
	move.l	#$FFFF0000,(recbpr).w
	movem.l	(sp)+,d0-d1/a0
rtsLineData	;The shared rts; PlayoffScreen (setup95_02) branches to it
	rts
