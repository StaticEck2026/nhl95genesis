;	NHL 95 collide95_02. Retail $0836AC-$083EB1 (2054 bytes).
;	The 95 PuckcIsGoalie, then collide94 SetPersonel, SetPlList, TryAddPlayerToList, forcepldata, stats94 GetPlayerCount (moved in;
;	95: by team number, GetPlayerCountD7), collide94 setplayer, ClampNibble, the 95 StickHandTable and BoostAttribute, crowd94
;	AttributeCalc (moved in), hockey94 restoreteams (moved in), collide94 ResetBench, setup94 resetplstuff (moved in), data94 priolist and
;	sublist (moved in), crowd94 Create_HotCold_Table / HotColdLoop (moved in).
;	The start moved to $0836AC: loc_8369E ... $0836AB is the end of CPgoalie (checks95_03). The end moved to $083EB1: sub_83EB2 is the
;	start of 95 doinput (input95_01; loc_83EC0, the mapped start, is inside it).
;	IDA left PuckcIsGoalie, forcepldata, resetplstuff and the tables as dc.b; they are code / data here, read from the retail bytes.
;	95 changes: SetPersonel marks the season injuries first (GameFlags bit 3, SetSeasonInjuries); setplayer reads the roster by team
;	number (rosterteam, GetRosterName / GetJerseyNumber), maps the stick handling nibble through StickHandTable and pulls some ratings
;	toward 30 (BoostAttribute); forcepldata lost the Set4WayPlayerStub call; the 95 asstab numbers and SPA values.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


PuckcIsGoalie	;no IDA label (IDA dc.b). 95 only. Z set (eq) when the puck carrier is a goalie (a minus puckc returns ne). Called from assdefo
	;(checks95_02)
	movem.l	d0/a0,-(sp)
	move.w	(puckc).w,d0
	bmi.w	.x
	movea.l	#SortCords,a0
	asl.w	#7,d0
	adda.w	d0,a0
	tst.w	position(a0)
.x
	movem.l	(sp)+,d0/a0
	rts

SetPersonel	;IDA: sub_836CC. IDA name (93 setpersonel). Set personnel on team a2 by PlList (SetPlList): players already on the ice stay,
	;the others take the free sort objects. 95: SetSeasonInjuries first with GameFlags bit 3
	movem.l	d0-d5/a0-a4,-(sp)
	btst	#3,(GameFlags).w
	beq.w	.0
	jsr	(SetSeasonInjuries).l
.0
	movea.w	$22(a2),a3
	moveq	#5,d4
.1
	st	$60(a3)
	st	$61(a3)
	adda.w	#$80,a3
	dbf	d4,.1
	bsr.w	SetPlList
	moveq	#5,d4
	movea.w	#(PlList-M68K_RAM),a4
.2
	clr.w	d5
	move.b	(a4,d4.w),d5
	beq.w	.4
	subq.w	#1,d5
	moveq	#5,d3
	movea.w	$22(a2),a3
	suba.w	#$80,a3
.3
	adda.w	#$80,a3
	cmp.b	$66(a3),d5
	dbeq	d3,.3
	bne.w	.4
	move.b	6(a4,d4.w),$60(a3)
	move.b	d5,$61(a3)
	clr.b	(a4,d4.w)
.4
	dbf	d4,.2
	moveq	#5,d4
	movea.w	#(PlList-M68K_RAM),a4
.5
	clr.w	d5
	move.b	(a4,d4.w),d5
	beq.w	.8
	subq.w	#1,d5
	moveq	#5,d3
	movea.w	$22(a2),a3
	suba.w	#$80,a3
.6
	adda.w	#$80,a3
	tst.b	$61(a3)
	dbmi	d3,.6
	bpl.w	.7
	movea.w	a3,a0
.7
	tst.w	$34(a3)
	dbpl	d3,.6
	move.b	6(a4,d4.w),$60(a0)
	move.b	d5,$61(a0)
	clr.b	(a4,d4.w)
.8
	dbf	d4,.5
	movem.l	(sp)+,d0-d5/a0-a4
	rts

SetPlList	;IDA: sub_83786. Create PlList of players who we want on the ice now. a2 = team struct. Takes the current line (tmline) by
	;priolist; an unavailable player is replaced from sublist (TryAddPlayerToList), else by roster order (GetPlayerCount)
	movea.w	#(PlList-M68K_RAM),a4
	clr.l	(a4)
	clr.w	4(a4)
	movea.l	#priolist,a0
	tst.w	$26(a2)
	bpl.w	.0
	addq.w	#1,a0
.0
	lea	$16C(a2),a1
	move.w	$16(a2),d0
	asl.w	#3,d0
	adda.w	d0,a1
	move.w	$24(a2),d4
	bra.w	.2
.1
	clr.w	d5
	move.b	(a0,d4.w),d5
	move.b	(a1,d5.w),(a4,d4.w)
	move.b	d5,6(a4,d4.w)
	bne.w	.2
	moveq	#1,d3
	add.w	$26(a2),d3
	move.b	d3,(a4,d4.w)
.2
	dbf	d4,.1
	moveq	#5,d4
.3
	move.b	(a4,d4.w),d3
	beq.w	.6
	ext.w	d3
	subq.w	#1,d3
	add.w	d3,d3
	cmpi.w	#$FFFD,$68(a2,d3.w)
	beq.w	.4
	cmpi.w	#$FFFC,$68(a2,d3.w)
	beq.w	.4
	tst.w	$68(a2,d3.w)
	ble.w	.6
.4
	lea	$16C(a2),a1
	move.b	6(a4,d4.w),d0
	ext.w	d0
	asl.w	#1,d0
	movea.l	#sublist,a0
	adda.w	(a0,d0.w),a0
.5
	clr.w	d0
	move.b	(a0)+,d0
	bmi.w	.7
	move.b	(a1,d0.w),d0
	bsr.w	TryAddPlayerToList
	beq.s	.5
.6
	dbf	d4,.3
	rts
.7
	jsr	(GetPlayerCount).l
	move.w	d0,d3
.8
	move.w	d3,d0
	subq.w	#1,d3
	bmi.s	.6
	bsr.w	TryAddPlayerToList
	beq.s	.8
	bra.s	.6

TryAddPlayerToList	;IDA: sub_83846. IDA 94 findAvailablePlayer. d0 = player number (1 based), d4 = PlList slot. Put d0 in the slot if he is on
	;the bench and not in PlList yet (eq when taken)
	move.w	d0,d1
	subq.w	#1,d0
	add.w	d0,d0
	tst.w	$68(a2,d0.w)
	bgt.w	.1
	cmpi.w	#$FFFD,$68(a2,d0.w)
	beq.w	.1
	cmpi.w	#$FFFC,$68(a2,d0.w)
	beq.w	.1
	moveq	#5,d0
.0
	cmp.b	(a4,d0.w),d1
	dbeq	d0,.0
	beq.w	.1
	move.b	d1,(a4,d4.w)
	rts
.1
	clr.w	d1
	rts

forcepldata	;no IDA label (IDA dc.b). no skating on/off: force players to correct data (for faceoffs only). a2 = team struct. 95: no
	;Set4WayPlayerStub call (its SCnum push / pop stays)
	movem.l	d0-d4/a0-a3,-(sp)
	movea.w	tmsort(a2),a3	;22 offset of team struct is tmsort (address of first sort obj)
	moveq	#5,d4	;will run the loop 6 times
.top
	move.b	newpos(a3),d0	;newpos = requested next pos of player
	ext.w	d0
	tst.w	$34(a3)	;check for goalie
	bne.w	.0
	tst.w	d0	;is he staying as a goalie?
	beq.w	.0
	move.w	$52(a3),-(sp)	;push SCNum to stack
	move.w	#$F,$52(a3)	;put F into SCNum
	move.w	(sp)+,$52(a3)	;pop original SCNum back into SCNum
.0
	move.w	d0,position(a3)	;move newpos(d0) into position
	bmi.w	.next
	bsr.w	Setplass
	cmpi.w	#4,position(a3)	;check if C
	bne.w	.notnear	;branch if not
	moveq	#$E,d0	;assnearest (94 $11)
	bsr.w	assinsert
.notnear
	clr.w	d3
	move.b	newpnum(a3),d3	;move newpnum into d3
	add.w	d3,d3	;add d3 to itself
	move.w	#$FFFF,tmpdst(a2,d3.w)	;move -1 into tmpdst
	lsr.w	#1,d3	;divide d3 by 2
	bsr.w	setplayer	;put player on the ice
.next
	st	newpnum(a3)	;set newpnum to FF
	st	newpos(a3)	;set newpos to FF
	adda.w	#SCstruct,a3	;move to next sortobj (player struct)
	dbf	d4,.top
	movem.l	(sp)+,d0-d4/a0-a3
	rts

GetPlayerCount	;IDA: sub_838F2. stats94 GetPlayerCount (moved in). d0 = players on team a2. 95: by team number ($28 of the team struct, GetPlayerCountD7)
	movem.l	d7-a0,-(sp)
	move.w	$28(a2),d7
	bsr.w	GetPlayerCountD7
	movem.l	(sp)+,d7-a0
	rts

GetPlayerCountD7	;IDA: sub_83904. 95 only. d0 = players on team d7: in a season (sflags11 bit 6 clear) the sum of three save RAM bytes
	;(ReadSRAM at $1B80 + $38 * team), else from the roster in TeamList (records until a length word of 2)
	btst	#6,(sflags11).w
	bne.w	.0
	movem.l	d1-d7/a0,-(sp)
	move.w	d7,d0
	mulu.w	#$38,d0
	addi.l	#$1B80,d0
	moveq	#3,d1
	movea.l	#SRAMbyte,a0
	jsr	(ReadSRAM).l
	clr.w	d0
	move.b	(a0)+,d0
	add.b	(a0)+,d0
	add.b	(a0)+,d0
	movem.l	(sp)+,d1-d7/a0
	rts
.0
	movem.l	d7-a0,-(sp)
	movea.l	#TeamList,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	adda.w	(a0),a0
	clr.w	d0
.1
	addq.w	#1,d0
	adda.w	(a0),a0
	addq.w	#8,a0
	cmpi.w	#2,(a0)
	bne.s	.1
	movem.l	(sp)+,d7-a0
	rts

setplayer	;IDA: sub_83960. Bring player onto the ice and set his attributes. d3 = offset of player on roster, a3 = sortcord of player.
	;Reads the roster bytes through AttributeCalc (attribute number in TempWord2), adds the PP / PK, home / away and third period bonuses
	;and clamps them (ClampNibble). 95: the name / jersey number by team number (rosterteam), StickHandTable, BoostAttribute
	bclr	#6,$63(a3)
	movea.w	#(HmShots-M68K_RAM),a0
	btst	#6,$62(a3)
	beq.w	.0
	adda.w	#$366,a0
.0
	move.b	d3,$66(a3)
	moveq	#$16,d0
	ext.w	d3
	add.w	d3,d3
	move.w	$68(a0,d3.w),d1
	bpl.w	.1
	moveq	#$13,d0
	cmp.w	#$FFFE,d1
	bne.w	.2
.1
	bsr.w	assinsert
	bclr	#5,$62(a3)
	clr.w	$58(a3)
.2
	move.w	#$FFFF,$68(a0,d3.w)
	lsr.w	#1,d3
	move.w	$28(a0),(rosterteam).w
	movea.l	$1E(a0),a0
	adda.w	8(a0),a0
	clr.l	(PPBonus).w
	tst.w	$34(a3)
	beq.w	.9
	btst	#5,(sflags2).w
	beq.w	.4
	jsr	(chkpk2).l
	beq.w	.3
	move.b	1(a0),(PPBonus).w
	andi.b	#$F,(PPBonus).w
	bra.w	.4
.3
	move.b	1(a0),d0
	lsr.b	#4,d0
	neg.b	d0
	move.b	d0,(PKBonus).w
.4
	move.b	2(a0),d0
	andi.b	#$F,d0
	neg.b	d0
	btst	#6,$62(a3)
	bne.w	.5
	move.b	2(a0),d0
	lsr.b	#4,d0
.5
	move.b	d0,(HmAwBonus).w
	cmpi.w	#2,(gsp).w
	blt.w	.9
	bgt.w	.6
	jsr	(GetPeriodTime).l
	lsr.w	#1,d0
	cmp.w	(gameclock).w,d0
	bgt.w	.9
.6
	move.w	(HmShots+tmscore).w,d0
	sub.w	(AwShots+tmscore).w,d0
	beq.w	.8
	btst	#6,$62(a3)
	beq.w	.7
	eori	#8,ccr
.7
	bpl.w	.9
.8
	move.b	#2,(ThirdPBonus).w
.9
	movem.l	d0/d7/a1,-(sp)
	move.w	d3,d0
	move.w	(rosterteam).w,d7
	jsr	(GetRosterName).l
	movea.l	a1,a0
	adda.w	(a0),a0
	addq.w	#8,a0
	movem.l	(sp)+,d0/d7/a1
	subq.w	#8,a0
	movem.w	d0/d7,-(sp)
	move.w	(rosterteam).w,d7
	move.w	d3,d0
	jsr	(GetJerseyNumber).l
	move.b	(jerseynum).w,$6F(a3)
	movem.w	(sp)+,d0/d7
	move.b	1(a0),d3
	andi.w	#$F0,d3
	lsr.w	#1,d3
	move.b	d3,$67(a3)
	move.b	1(a0),d3
	andi.b	#$F,d3
	move.w	#3,(TempWord2).w
	jsr	(AttributeCalc).l
	move.b	d3,$68(a3)
	move.b	2(a0),d3
	lsr.b	#4,d3
	move.w	#4,(TempWord2).w
	jsr	(AttributeCalc).l
	bsr.w	BoostAttribute
	move.b	d3,$69(a3)
	move.b	2(a0),d3
	andi.b	#$F,d3
	move.w	#5,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus).w,d3
	add.b	(PKBonus).w,d3
	add.b	(HmAwBonus).w,d3
	add.b	(ThirdPBonus).w,d3
	bsr.w	ClampNibble
	lsr.b	#1,d3
	eori.b	#$F,d3
	addi.b	#$F,d3
	lsr.b	#1,d3
	move.b	d3,$6A(a3)
	move.b	3(a0),d3
	lsr.b	#4,d3
	move.w	#6,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(HmAwBonus).w,d3
	bsr.w	ClampNibble
	lsr.b	#1,d3
	eori.b	#$F,d3
	addi.b	#$F,d3
	lsr.b	#1,d3
	move.b	d3,$6B(a3)
	move.b	3(a0),$6C(a3)
	andi.b	#$F,$6C(a3)
	move.b	$6C(a3),d3
	move.w	#7,(TempWord2).w
	jsr	(AttributeCalc).l
	bsr.w	BoostAttribute
	move.b	d3,$6C(a3)
	move.b	4(a0),d3
	lsr.b	#4,d3
	move.w	#8,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(ThirdPBonus).w,d3
	bsr.w	ClampNibble
	bsr.w	BoostAttribute
	move.b	d3,$75(a3)
	bclr	#3,4(a3)
	move.b	4(a0),$76(a3)
	andi.b	#1,$76(a3)
	beq.w	.10
	bset	#3,4(a3)
.10
	move.b	4(a0),$74(a3)
	andi.b	#$E,$74(a3)
	move.b	5(a0),d3
	lsr.b	#4,d3
	movem.l	d0/a0,-(sp)
	movea.l	#StickHandTable,a0
	move.b	d3,d0
	ext.w	d0
	move.b	(a0,d0.w),d3
	movem.l	(sp)+,d0/a0
	move.w	#$A,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus).w,d3
	add.b	(PKBonus).w,d3
	add.b	(HmAwBonus).w,d3
	bsr.w	ClampNibble
	bsr.w	BoostAttribute
	move.b	d3,$71(a3)
	move.b	5(a0),d3
	andi.b	#$F,d3
	move.w	#$B,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus).w,d3
	add.b	(PKBonus).w,d3
	add.b	(HmAwBonus).w,d3
	bsr.w	ClampNibble
	move.b	d3,$6D(a3)
	move.b	6(a0),d3
	lsr.b	#4,d3
	move.w	#$C,(TempWord2).w
	jsr	(AttributeCalc).l
	move.b	d3,$72(a3)
	move.b	6(a0),d3
	andi.b	#$F,d3
	move.w	#$D,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(ThirdPBonus).w,d3
	add.b	(ThirdPBonus).w,d3
	bsr.w	ClampNibble
	move.b	d3,$70(a3)
	move.b	7(a0),d3
	lsr.b	#4,d3
	move.w	#$E,(TempWord2).w
	jsr	(AttributeCalc).l
	add.b	(PPBonus).w,d3
	add.b	(HmAwBonus).w,d3
	bsr.w	BoostAttribute
	bsr.w	ClampNibble
	move.b	d3,$6E(a3)
	move.b	7(a0),$73(a3)
	move.b	$73(a3),d3
	andi.b	#$F,d3
	move.w	#$F,(TempWord2).w
	jsr	(AttributeCalc).l
	move.b	d3,$73(a3)
	andi.b	#$F,$73(a3)
	rts

ClampNibble	;IDA: sub_83C88. IDA 94 checkattriblimits. Clamp byte d3 to 0-$1E. Called by setplayer
	tst.b	d3
	bpl.w	.0
	clr.w	d3
.0
	cmp.b	#$1E,d3
	ble.w	.1
	move.w	#$1E,d3
.1
	rts

StickHandTable	;IDA: unk_83C9E. 95 only. setplayer: the stick handling nibble 0-15 to 0-6, before AttributeCalc
	dc.b	0,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6	;Stk nibble 0-15 to 0-6
	dc.b	0,1,3,6,9,$C,$F,$FF	;unused

BoostAttribute	;IDA: sub_83CB6. 95 only. d3 += ($1E - d3) / 4, kept in $F ... $1E. setplayer runs it on some ratings
	movem.w	d0,-(sp)
	move.b	#$1E,d0
	sub.b	d3,d0
	asr.b	#2,d0
	add.b	d0,d3
	bpl.w	.0
	move.b	#$F,d3
.0
	cmp.b	#$1E,d3
	ble.w	.1
	move.b	#$1E,d3
.1
	movem.w	(sp)+,d0
	rts

AttributeCalc	;IDA: sub_83CDE. crowd94 AttributeCalc (moved in; IDA name). Attribute d3 of player a3 * 5 plus his hot / cold value / 3,
	;limited to 0 ... $1E
	movem.l	d0-d2/a1,-(sp)
	move.w	(TempWord2).w,d1
	movea.l	#HmShots,a1
	btst	#6,$62(a3)
	beq.w	.0
	adda.l	#$366,a1
.0
	clr.w	d1
	move.b	$66(a3),d1
	asl.w	#4,d1
	adda.l	#$1A4,a1
	move.b	(a1,d1.w),d1
	ext.w	d1
	ext.l	d1
	divs.w	#3,d1
	move.w	d3,-(sp)
	asl.w	#2,d3
	add.w	(sp)+,d3
	add.w	d1,d3
	bmi.w	.1
	cmp.w	#$1E,d3
	blt.w	.2
	move.w	#$1E,d3
	bra.w	.2
.1
	clr.w	d3
.2
	andi.w	#$FF,d3
	movem.l	(sp)+,d0-d2/a1
	rts

restoreteams	;IDA: sub_83D3E. hockey94 restoreteams (moved in). Put both teams' rosters on the bench (tmap 6, every tmpdst -2)
	movea.w	#(HmShots-M68K_RAM),a2
	bsr.w	.0
	adda.w	#$366,a2
.0
	move.w	#6,$24(a2)
	moveq	#$32,d0
.1
	move.w	#$FFFE,$68(a2,d0.w)
	subq.w	#2,d0
	bpl.s	.1
	rts

ResetBench	;IDA: sub_83D5E. Remove all players from penalty box / put all players on their own bench (not the injured, -3 / -4). Counts the
	;players left in the box in PBnum (home in the high nibble)
	clr.b	(PBnum).w
	moveq	#$10,d1
	movea.w	#(HmShots-M68K_RAM),a0
	bsr.w	.0
	moveq	#1,d1
	adda.w	#$366,a0
.0
	moveq	#$32,d0
.1
	add.b	d1,(PBnum).w
	tst.w	$68(a0,d0.w)
	ble.w	.2
	btst	#4,$68(a0,d0.w)
	beq.w	.3
	move.w	$68(a0,d0.w),d2
	andi.w	#$7FF,d2
	bne.w	.3
	sub.b	d1,(PBnum).w
	bra.w	.3
.2
	sub.b	d1,(PBnum).w
	cmpi.w	#$FFFD,$68(a0,d0.w)
	beq.w	.3
	cmpi.w	#$FFFC,$68(a0,d0.w)
	beq.w	.3
	move.w	#$FFFE,$68(a0,d0.w)
.3
	subq.w	#2,d0
	bpl.s	.1
	rts

resetplstuff	;no IDA label (IDA dc.b). setup94 resetplstuff (moved in). Reset team variables and players on both teams. 95 SPA $B5C
	;(94 $50C)
	movem.l	d0-d2/a0-a3,-(sp)
	movea.w	#(HmShots-M68K_RAM),a2
	bsr.w	.top
	movea.w	#(AwShots-M68K_RAM),a2
	bsr.w	.top
	movem.l	(sp)+,d0-d2/a0-a3
	rts
.top
	bclr	#4,tmflags(a2)	;clear team offside bit
	moveq	#5,d2
	movea.w	tmsort(a2),a3	;tmsort
.loop
	clr.b	pflags2(a3)	;pflags2
	tst.w	position(a3)	;check for goalie
	bmi.w	.next
	move.w	#$B5C,d1
	jsr	(SetSPA).l
	clr.w	impact(a3)	;impact
	clr.b	nopuck(a3)	;nopuck
	andi.b	#$C2,pflags(a3)	;2^pfteam + 2^pfgoal +2^pfna, pflags
.next
	adda.w	#SCstruct,a3	;SCstruct size
	dbf	d2,.loop
	rts

priolist	;IDA: unk_83E16. data94 priolist (moved in). Positions in order of importance. Used by SetPlList
	dc.b	0,1,2,4,3,5,6
	dc.b	$FF	;pad

sublist	;IDA: unk_83E1E. data94 sublist (moved in). Substitution lists by position (goalie, LD, RD, LW, C, RW, extra attacker), word
	;offsets from sublist. Used by SetPlList
	dc.w	.defl-sublist		;goalie
	dc.w	.defl-sublist
	dc.w	.defr-sublist
	dc.w	.wingl-sublist
	dc.w	.center-sublist
	dc.w	.wingr-sublist
	dc.w	.center-sublist
.defl	dc.b	0+1,8+1,16+1,24+1,32+1,40+1,48+1	;list of players in there lines/each line = 8 bytes
	dc.b	0+2,8+2,16+2,24+2,32+2,40+2,48+2
.defr	dc.b	0+2,8+2,16+2,24+2,32+2,40+2,48+2
	dc.b	0+1,8+1,16+1,24+1,32+1,40+1,48+1
.wingl	dc.b	0+3,8+3,16+3,24+3,32+3,40+3,48+3
	dc.b	0+5,8+5,16+5,24+5,32+5,40+5,48+5
	dc.b	0+4,8+4,16+4,24+4,32+4,40+4,48+4
.wingr	dc.b	0+5,8+5,16+5,24+5,32+5,40+5,48+5
	dc.b	0+3,8+3,16+3,24+3,32+3,40+3,48+3
	dc.b	0+4,8+4,16+4,24+4,32+4,40+4,48+4
.center	dc.b	0+4,8+4,16+4,24+4,32+4,40+4,48+4
	dc.b	0+3,8+3,16+3,24+3,32+3,40+3,48+3
	dc.b	0+5,8+5,16+5,24+5,32+5,40+5,48+5
	dc.b	-1

Create_HotCold_Table	;IDA: sub_83E88. crowd94 Create_HotCold_Table (moved in; IDA name). Fill the hot / cold table at $1A4 of team struct a0 (94
	;$1A2) with 416 random values
	movem.l	d0-d7,-(sp)
	move.w	#$19F,d1

HotColdLoop	;IDA: loc_83E90. IDA name. The Create_HotCold_Table loop
	move.w	#9,d0
	jsr	(randomd0s).l
	move.l	a0,-(sp)
	adda.l	#$1A4,a0
	move.b	d0,(a0,d1.w)
	movea.l	(sp)+,a0
	dbf	d1,HotColdLoop
	movem.l	(sp)+,d0-d7
	rts
