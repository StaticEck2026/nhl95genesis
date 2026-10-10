;	NHL 95 checks95_01. Retail $07F97E-$0807EB (3694 bytes).
;	The first half of 94 checks94 (from assgoaliecpu) with the 95 pause menu items that 95 put in front of it:
;	goalie94 ManualGoalieMenu, stats94 SelectGoalieMenu / DisplayPlayerSelectMenu / TimeoutMenu (95: the three tab pause menu), the 95
;	PauseScores / PutScoreDigit and SetMenuPadSide, then the 95 asstab (95 order, 34 entries; 94 kept it in data94) and doassignment (94
;	updateplayers did the asstab call in line), then checks94 assgoaliecpu ... ClampYPosition, AdjustFacingDirection, goaliesave and its
;	animation list, assgoalietopuck. assign95_01 (94 assdefd) follows at $0807EC.
;	IDA left $07F97E-$07FCB9, $07FDA4-$080425 and $080742-$0807EB as dc.b; they are code here, read from the retail bytes. IDA also lost
;	the btst Dn,#imm lines of AdjustFacingDirection and the dead lines in goaliesave.
;	95 moves most goalie y limits 3 further out ($E4 to $E7, $104 to $107, $108 to $10B ...); the comments give the 94 values.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

ManualGoalieMenu	;no IDA label (IDA dc.b). goalie94 ManualGoalieMenu. Pause menu MANUAL GOALIE / AUTO GOALIE: with OptNOP set, toggle goaliemode2
	;when the team of the menu pad is above 1 (SetMenuPadSide, sflags bit 1), else goaliemode1, and redraw the items (RedrawMenu; 94 matched
	;cont1team / cont2team instead). In a penalty shot or shootout (gmode2 bit 0, BA_PS_flags bit 2) the pad then takes player 0 / 6 or
	;5 / $B by its mode, when BA_Sktr_SCnum is on its side (setc1player / setc2player)
	movem.l	d0-d7/a0-a6,-(sp)
	tst.w	(OptNOP).w
	beq.w	.2
	bsr.w	SetMenuPadSide
	btst	#1,(sflags).w
	beq.w	.1
	eori.w	#1,(goaliemode2).w
	jsr	(RedrawMenu).l
	bra.w	.2
.1
	eori.w	#1,(goaliemode1).w
	bsr.w	RedrawMenu	;the same call as a bsr
.2
	btst	#0,(gmode2).w
	bne.w	.3
	btst	#2,(BA_PS_flags).w
	beq.w	.x
.3
	btst	#1,(sflags).w
	bne.w	.8
	cmpi.w	#2,(OptNOP).w
	bne.w	.4
	cmpi.w	#5,(BA_Sktr_SCnum).w
	bgt.w	.x
	bra.w	.5
.4
	cmpi.w	#5,(BA_Sktr_SCnum).w
	ble.w	.x
.5
	move.w	#0,d0
	cmpi.w	#2,(OptNOP).w
	bne.w	.6
	move.w	#6,d0
.6
	tst.w	(goaliemode1).w
	bne.w	.7
	move.w	#5,d0
	cmpi.w	#2,(OptNOP).w
	bne.w	.7
	move.w	#$B,d0
.7
	jsr	(setc1player).l
	bra.w	.x
.8
	cmpi.w	#2,(OptNOP).w
	bne.w	.9
	cmpi.w	#5,(BA_Sktr_SCnum).w
	ble.w	.x
	bra.w	.10
.9
	cmpi.w	#5,(BA_Sktr_SCnum).w
	bgt.w	.x
.10
	move.w	#6,d0
	tst.w	(goaliemode2).w
	bne.w	.11
	move.w	#$B,d0
.11
	jsr	(setc2player).l
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SelectGoalieMenu	;no IDA label (IDA dc.b). stats94 SelectGoalieMenu. Pause menu CHANGE GOALIE: pick team a2's goalie (or no goalie) from a list
	;(DisplayPlayerSelectMenu) with up / down, C or start; sets tmgoalie and SetPersonel. 95 clears the menu box first (ClearMenuBox) and
	;redraws the menu after (RedrawMenu), where 94 drew a frame (Framer)
	move.w	(menuitem).w,-(sp)
	move.w	(menuitem+2).w,-(sp)
	bsr.w	ClearMenuBox
	jsr	(ReadAttributeNibble).l
	move.w	d0,(menuitem+2).w
	add.w	(menuitem+2).w,d1	;94 Framer height. Nothing reads it in 95
	move.w	tmgoalie(a2),d0
	bpl.w	.0
	moveq	#-1,d0
.0
	addq.w	#1,d0
	move.w	d0,(menuitem).w
.loop
	bsr.w	DisplayPlayerSelectMenu
.pad
	bsr.w	WaitVSyncAndReadInput
	btst	#7,d1
	bne.w	.done
	btst	#5,d1
	bne.w	.done
	btst	#1,d1
	beq.w	.up
	move.w	(menuitem).w,d0
	addq.w	#1,d0
	cmp.w	(menuitem+2).w,d0
	bgt.s	.loop
	move.w	d0,(menuitem).w
.up
	btst	#0,d1
	beq.s	.loop
	subq.w	#1,(menuitem).w
	bpl.s	.loop
	clr.w	(menuitem).w
	bra.s	.loop
.done
	move.w	(menuitem).w,d0
	subq.w	#1,d0
	bpl.w	.set
	cmpi.w	#$FFFF,tmgoalie(a2)
	blt.w	.x
.set
	move.w	d0,tmgoalie(a2)
	jsr	(SetPersonel).l
.x
	move.w	(sp)+,(menuitem+2).w
	move.w	(sp)+,(menuitem).w
	bsr.w	ClearMenuBox
	jsr	(RedrawMenu).l
	rts

DisplayPlayerSelectMenu	;no IDA label (IDA dc.b). stats94 DisplayPlayerSelectMenu. Draw the goalie list at row $E, x $C, row menuitem in
	;font set 2: "no goalie", then each goalie by name (95: GetTempPlayerNameAttrib for TempPlOffset, -1 for the away team; 94 printed
	;the roster name and the two digit number)
	move.w	#$E,(printy).w
	move.w	(menuitem+2).w,d1
	moveq	#0,d0
.0
	move.w	#$C,(printx).w
	move.w	#0,(printfontset).w
	cmp.w	(menuitem).w,d0
	bne.w	.1
	move.w	#2,(printfontset).w
.1
	bsr.w	printz2
	String	'                 '	;clear the row
	tst.w	d0
	bne.w	.player
	move.w	#$C,(printx).w
	bsr.w	printz2
	String	'no goalie'
	bra.w	.next
.player
	move.w	d0,d2
	subq.w	#1,d2
	move.w	d2,(TempPlOffset).w
	cmpa.l	#HmShots,a2
	beq.w	.2
	st	(TempPlOffset).w
.2
	jsr	(GetTempPlayerNameAttrib).l
	move.w	#$C,(printx).w
	bsr.w	printsmall
.next
	addq.w	#1,(printy).w
	addq.w	#1,d0
	dbf	d1,.0
	rts

TimeoutMenu	;no IDA label (IDA dc.b). stats94 TimeoutMenu. Pause menu TIMEOUT for team a2: drop the item (menuitemoffset $23A: the pause
	;list without TIMEOUT; 94 set menulist to PauseText2), set tmflags bit 2 (timeout used), print TIMEOUT and the team name centred at
	;y $14 in the cleared menu box, rest both teams (RestoreTeamEnergy), wait $78 frames (waitx), redraw the menu
	subq.w	#1,(menuitem).w
	subq.w	#1,(menuitem+2).w
	bsr.w	ClearMenuBox
	move.l	#$23A,(menuitemoffset).w
	bset	#2,tmflags(a2)
	move.w	#0,(printfontset).w
	bsr.w	printz2
	String	$FD,$10,$FC,$E,'Timeout',$FD,$14,$FC,$10	;$FD x, $FC y
	movea.l	tmdata(a2),a1
	adda.w	4(a1),a1	;team name String
	move.w	(a1),d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	bsr.w	printsmall
	movea.w	#(HmShots-M68K_RAM),a2
	jsr	(RestoreTeamEnergy).l
	adda.w	#tmsize,a2
	jsr	(RestoreTeamEnergy).l
	moveq	#$78,d0
	jsr	(waitx).l
	bsr.w	ClearMenuBox
	jmp	(RedrawMenu).l

PauseScores	;no IDA label (IDA dc.b). 95 only. The two scores in big digits on the pause screen (PutScoreDigit): home at printz position
	;$1E, 6, away at 6, 6; no tens digit under 10. Called from PauseScreenDraw (menu95)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BE,$1E,6,0
	movea.l	#HmShots,a2
	move.w	tmscore(a2),d0
	ext.l	d0
	divu.w	#$A,d0
	move.l	d0,-(sp)
	tst.w	d0
	bne.w	.0
	addq.w	#2,(printx).w
	bra.w	.1
.0
	bsr.w	PutScoreDigit
.1
	move.l	(sp)+,d0
	swap	d0
	bsr.w	PutScoreDigit
	jsr	(printz).l
	String	$BE,6,6,0
	movea.l	#AwShots,a2
	move.w	tmscore(a2),d0
	ext.l	d0
	divu.w	#$A,d0
	move.l	d0,-(sp)
	tst.w	d0
	bne.w	.2
	addq.w	#2,(printx).w
	bra.w	.3
.2
	bsr.w	PutScoreDigit
.3
	move.l	(sp)+,d0
	swap	d0
	bsr.w	PutScoreDigit
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PutScoreDigit	;no IDA label (IDA dc.b). 95 only. The same code as PutClockDigit (video95_03): big digit d0 at printx / printy from
	;ClockDigitsBitmap (dobitmap, chars clockdigitchars), then printx + 2
	movem.w	d0-d7,-(sp)
	movea.l	#ClockDigitsBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	asl.w	#1,d0
	move.w	#0,d1
	move.w	#2,d2
	move.w	#3,d3
	movea.l	#$69A,a2
	move.w	(clockdigitchars).w,d4
	moveq	#0,d5
	jsr	(dobitmap).l
	addq.w	#2,(printx).w
	movem.w	(sp)+,d0-d7
	rts

SetMenuPadSide	;IDA: sub_7FCBA. 95 only. sflags bit 1 set when the team of pad menupadnum (padteams) is above 1, else cleared. Called from
	;ManualGoalieMenu and PrintMenuItem (menu95)
	movem.l	d0/a0-a1,-(sp)
	movea.l	#padteams,a0
	move.w	(menupadnum).w,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	cmpi.w	#1,(a0)
	movem.l	(sp)+,d0/a0-a1
	ble.w	.0
	bset	#1,(sflags).w
	bra.w	.1
.0
	bclr	#1,(sflags).w
.1
	rts

padteams	;IDA: unk_7FCEC. 95 only. The team word of each pad (SetMenuPadSide)
	dc.l	cont1team,cont2team,cont3team,cont4team

asstab	;IDA: unk_7FCFC. Jump table of the player logic assignments (92 / 93 / 94 asstab). 95 keeps it here, in a new order: the
	;assignment numbers in asslist and in assinsert d0 are 95 numbers. The comment gives the 95 number, then the 94 one
	dc.l	rtss2		;0 (94 0)
	dc.l	pucknorm	;1 (94 $18)
	dc.l	puckshadow	;2 (94 $19)
	dc.l	puckfaceoff	;3 (94 $1B)
	dc.l	puckfaceoff2	;4 (94 $1C)
	dc.l	puckunflip	;5 (94 $1A)
	dc.l	assgoaliecpu	;6 (94 $E)
	dc.l	assdefd		;7 (94 2)
	dc.l	asswingd	;8 (94 3)
	dc.l	asswingo	;9 (94 4)
	dc.l	asscenterd	;$A (94 5)
	dc.l	asscentero	;$B (94 6)
	dc.l	assdefo		;$C (94 1)
	dc.l	asspassrec	;$D (94 $13)
	dc.l	assnearest	;$E (94 $11)
	dc.l	asspuckc	;$F (94 $10)
	dc.l	assfaceoff	;$10 (94 $16)
	dc.l	assfaceoffp1	;$11 (94 $17)
	dc.l	assbench	;$12 (94 $B)
	dc.l	asseben		;$13 (94 9)
	dc.l	assgoalietopuck	;$14 (94 $F)
	dc.l	asspenalty	;$15 (94 $C)
	dc.l	assepen		;$16 (94 $A)
	dc.l	assdopen	;$17 (94 $D)
	dc.l	assonetimer	;$18 (94 $23)
	dc.l	assfight	;$19 (94 $14)
	dc.l	assshoot	;$1A (94 $12)
	dc.l	assgoaliectrl	;$1B (94 $1D)
	dc.l	assscore	;$1C (94 7)
	dc.l	assgoaliebreakwait	;$1D (94 $20)
	dc.l	chkpuckc	;$1E (94 $21)
	dc.l	puckshootout	;$1F (94 $1E)
	dc.l	puckpenshot	;$20 (94 $1F)
	dc.l	assbreakaway	;$21 (94 $22)

doassignment	;IDA: sub_7FD84. 95 only. Run the current assignment of player a3 (asslist entry assnum, asstab) with a2 / a1 = its team / the
	;other team (loadTeamStruct). Called from updateplayers (setup95_01); 94 did this in line there
	move.w	$36(a3),d0
	clr.w	d1
	move.b	$38(a3,d0.w),d1
	asl.w	#2,d1
	movea.l	#asstab,a0
	movea.l	(a0,d1.w),a0
	jsr	(loadTeamStruct).l
	jsr	(a0)
	rts

; a3 = goalie
assgoaliecpu	;no IDA label (IDA dc.b), asstab entry 6. Also branched to from checks95_02
	btst	#3,$62(a3)	;is goalie joystick controlled?
	bne.w	assgoaliectrl	;branch if so
checkanim	;no IDA label. A local of assgoaliecpu in 94; global here: assgoaliectrl branches to it
	move.w	(puckx).w,(TmpPuckX).w
	btst	#0,(sflags4).w	;test bit 0
	beq.w	.assstart
	btst	#1,$63(a3)	;check if animation in progress
	bne.w	.assstart	;branch if so
	btst	#1,(sflags4).w	;test bit 1
	beq.w	.0	;branch if 0
	btst	#3,(sflags4).w	;test bit 3
	bne.w	.assstart	;branch if set
	bra.w	.assstart	;95: always. 94 played the slam sound at two frames here; the next 4 lines are dead
	bset	#3,(sflags4).w	;set bit 3
	move.w	#$1C,-(sp)	;SFX
	jsr	(sfx).l
	bra.w	.assstart
.0
	movem.w	d0-d1,-(sp)
	move.w	(pucky).w,d0	;pucky to d0
	move.w	$14(a3),d1	;move Ypos to d1
	eor.w	d1,d0	;XOR d1 to d0
	movem.w	(sp)+,d0-d1
	bmi.w	.assstart	;branch if d0 is negative
	cmpi.w	#0,$54(a3)	;95: by facedir (94: Xpos within $14): face up for 7, 0, 1, down for 3, 4, 5
	beq.w	.up
	cmpi.w	#1,$54(a3)
	beq.w	.up
	cmpi.w	#7,$54(a3)
	beq.w	.up
	cmpi.w	#4,$54(a3)
	beq.w	.down
	cmpi.w	#5,$54(a3)
	beq.w	.down
	cmpi.w	#3,$54(a3)
	bne.w	.assstart
.down
	move.w	#4,$54(a3)
	bra.w	.slam
.up
	move.w	#0,$54(a3)
.slam
	bset	#1,(sflags4).w	;set bit 1
	bclr	#3,(sflags4).w	;clear bit 3
	move.w	#$2A82,d1	;95 goalie celebration SPA; $2B38 one time in 10 (94: SPAgslamtop / SPAgslambot by net)
	move.w	d0,-(sp)
	move.w	#$64,d0
	jsr	(randomd0).l
	cmp.w	#$A,d0
	move.w	(sp)+,d0
	blt.w	.1
	move.w	#$2B38,d1
.1
	jsr	(SetSPA).l
	bset	#1,$63(a3)	;set anim in progress
.assstart
	btst	#5,$62(a3)	;check if locked in animation
	bne.w	rtsskate	;exit if so
	bsr.w	check4bench
	bclr	#1,$62(a3)	;clear new assignment
	beq.w	.nna	;jump if it was cleared already
	clr.w	$40(a3)	;clear temp1
	move.w	#8,$42(a3)	;move 8 into temp2
	st	$46(a3)	;set temp5 (FFFF)
.nna
	cmpi.w	#$34,(a3)	;'4' ; compare 34 hex with Xpos
	bgt.w	.nna2	;branch if greater
	cmpi.w	#$FFCC,(a3)	;compare -34 hex with Xpos
	blt.w	.nna2	;branch if less than
	cmpi.w	#$111,$14(a3)	;compare 111 with Ypos (94 $10E)
	bgt.w	.nna2
	cmpi.w	#$FEEF,$14(a3)
	blt.w	.nna2
	cmpi.w	#$D5,$14(a3)	;94 $D2
	bgt.w	.noskate
	cmpi.w	#$FF2B,$14(a3)
	blt.w	.noskate
.nna2
	lea	rtsskate(pc),a0	;goalie will skate back to middle position
	moveq	#4,d0
	tst.w	(a3)	;test Xpos
	bpl.w	.2	;branch if positive
	neg.w	d0
.2
	move.w	#$E7,d1	;94 $E4
	btst	#7,$62(a3)	;check what goal shooting at
	beq.w	skateto	;branch if bottom
	neg.w	d1
	bra.w	skateto
.noskate
	btst	#1,$63(a3)	;check if anim in progress
	bne.w	rtsskate	;exit if so
	btst	#0,(sflags4).w	;check bit 0
	beq.w	.noskate3	;branch if not set (95: the next line either way; 94 set facedir by the alice frame)
.noskate3
	jsr	(GoalieReadySPA).l	;95: ready SPA by the puck distance (94: 2 = SPAgready)
	jsr	(SetSPA).l
	btst	#2,(BA_PS_flags).w	;check bit 2
	bne.w	.noskate4	;branch if set
	btst	#0,(gmode).w	;check if clock
	bne.w	rtsskate	;exit if clock stopped
.noskate4
	tst.w	$48(a3)	;temp5
	bmi.w	.nofo	;branch if minus
	move.w	$52(a3),d0	;move SCnum to d0
	cmp.w	(puckc).w,d0	;check if puckc
	beq.w	.mbfo	;branch if so
	st	$48(a3)	;set temp5 to FFFF
	bra.w	.nofo
.mbfo
	sub.w	d7,$48(a3)	;subtract frames from temp5
	bpl.w	.nofo	;branch if positive
	btst	#2,(BA_PS_flags).w	;check if bit 2 set
	beq.w	.mbfo2	;branch if not
	bset	#4,(BA_PS_flags).w	;set bit 4
	bra.w	.nofo
.mbfo2
	move.l	#8,d0	;PenGhold
	jsr	(AddPenalty2).l	;blow whistle for FO
.nofo
	sub.b	d7,$40(a3)	;sub d7 from temp1
	bpl.w	.nodec	;branch if still positive
	move.b	$6B(a3),d0	;move aidef into d0 (DfA)
	beq.w	.nofo2	;branch if 0
	btst	#6,(sflags7).w	;check if crowd meter broken
	beq.w	.nofo2	;branch if not
	subq.b	#1,d0	;sub from d0
.nofo2
	lsr.b	#2,d0	;divide by 4
	move.b	d0,$40(a3)	;move d0 into temp1
	btst	#3,$62(a3)	;check if joy controlled
	beq.w	.nocontrol	;branch if not
	btst	#2,$64(a3)	;check bit 2
	bne.w	.nocontrol	;branch if set
	moveq	#$1B,d0	;assignment assgoaliectrl (94 $1D)
	bra.w	assinsert
.nocontrol
	move.w	(pucky).w,d0	;move pucky into d0
	move.w	$14(a3),d1	;move Ypos into d1
	eor.w	d0,d1	;XOR
	bpl.w	.3	;branch if positive
	clr.w	d0
	move.w	#$F7,d2	;94 $F4
	btst	#7,$62(a3)	;check which net shooting at
	beq.w	.de5	;branch if bottom
	neg.w	d2
	bra.w	.de5
.3
	subq.w	#1,$46(a3)	;sub 1 from temp4
	bpl.w	.4	;branch if positive
	move.w	#$FFFF,$46(a3)	;move -1 into temp4
.4
	move.w	$52(a3),d0	;SCnum into d0
	cmp.w	(puckc).w,d0	;check if puckc
	bne.w	.notpuckc	;branch if not
	tst.w	$48(a3)	;check temp5
	bpl.w	.5	;branch if positive
	move.w	#$5A,$48(a3)	;'Z' ; move 5A into temp5
.5
	st	$46(a3)	;FFFF into temp4
	cmpi.w	#$5A,$48(a3)	;'Z' ; compare to temp5
	bgt.w	.de1	;branch if greater
	move.w	(VDP_CNTR).l,d0
	andi.w	#3,d0	;pass first 2 bits
	bne.w	.de1	;branch if not 0
	moveq	#5,d0
	movea.w	#(SortCords-M68K_RAM),a0
	btst	#6,$62(a3)	;check home or away
	bne.w	.opploop	;branch if away
	adda.w	#$300,a0
.opploop
	btst	#2,$63(a0)	;check if player unavailable
	bne.w	.opploop2	;branch if so
	move.w	(pucky).w,d1	;pucky into d1
	sub.w	$14(a0),d1	;sub Ypos a0 from d1
	cmp.w	#$1C,d1	;compare 1C to difference
	bgt.w	.opploop2	;branch if greater
	cmp.w	#$FFE4,d1	;compare -1C
	blt.w	.opploop2	;branch if less than
	move.w	(puckx).w,d1	;puckx into d1
	sub.w	(a0),d1	;sub Xpos a0 from d1
	cmp.w	#$19,d1	;compare 19 to difference
	bgt.w	.opploop2	;branch if greater
	cmp.w	#$FFE7,d1	;compare -19 to diff
	bgt.w	.de1	;branch if greater
.opploop2
	adda.w	#$80,a0	;move to next struct
	dbf	d0,.opploop
	move.w	#1,(threat).w	;dir of threat on puck handler
	bsr.w	chk4pass
	bra.w	.de1
.notpuckc
	tst.w	$46(a3)	;check temp4
	bne.w	.de1	;branch if not 0
	tst.w	(puckc).w	;check puckc
	bpl.w	.de1	;branch if there is a puckc
	move.w	(puckx).w,d0
	sub.w	(a3),d0	;sub Xpos
	cmp.w	#$A,d0	;94 $14
	bgt.w	.de1	;branch if greater
	cmp.w	#$FFF6,d0
	blt.w	.de1	;branch if less
	move.w	(pucky).w,d1
	cmp.w	#$10B,d1	;check goalline
	bgt.w	.de1	;branch if past goalline
	cmp.w	#$FEF5,d1	;check other goalline
	blt.w	.de1	;branch if past
	sub.w	$14(a3),d1	;sub Ypos from d1
	cmp.w	#$F,d1	;94 $1E
	bgt.w	.de1	;branch if greater
	cmp.w	#$FFF1,d1
	blt.w	.de1	;branch if less
	movem.w	d0-d1,-(sp)
	move.w	(puckvx).w,d0
	bpl.w	.6
	neg.w	d0
.6
	move.w	(puckvy).w,d1
	bpl.w	.7
	neg.w	d1
.7
	add.w	d1,d0	;add puckvx and vy
	cmp.w	#$1000,d0	;compare to 1000
	movem.w	(sp)+,d0-d1
	bgt.w	.de1	;branch if greater
	jsr	(vtoa).l
	move.w	d0,$54(a3)	;d0 into facedir. Goalie will face puck
	move.b	#8,$5E(a3)	;move 8 to nopuck collision
	move.w	#$1D4E,d1	;goalie dive anim (94 $2F4)
	jsr	(SetSPA).l	;set animation
	bset	#1,$63(a3)	;set anim in progress
	addi.w	#$96,(crowdlevel).w
	rts
.de1
	movea.w	#(puckcross-M68K_RAM),a0	;puckcross = xcord/frames top to bottom for goalies to react to
	move.w	#$107,d3
	btst	#7,$62(a3)	;check what net shooting at
	beq.w	.8	;branch if bottom
	addq.w	#4,a0
	neg.w	d3
.8
	cmpi.w	#$107,$14(a3)
	bgt.w	.9
	cmpi.w	#$FEF9,$14(a3)
	bgt.w	.10
.9
	clr.w	d2
	clr.w	d0
	cmpi.w	#$2C,(a3)
	bgt.w	.de5
	cmpi.w	#$FFD4,(a3)
	blt.w	.de5
	move.w	#$98,d0	;94 $88
	tst.w	(a3)
	bpl.w	.de5
	neg.w	d0
	bra.w	.de5
.10
	tst.w	(puckc).w
	bmi.w	.11
	move.w	$52(a3),d0
	cmp.w	(puckc).w,d0
	beq.w	.11
	move.l	a0,-(sp)
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	asl.w	#7,d0
	adda.w	d0,a0
	move.w	(puckx).w,d0
	sub.w	(a0),d0
	asr.w	#1,d0
	add.w	(a0),d0
	move.w	d0,(TmpPuckX).w
	movea.l	(sp)+,a0
.11
	move.w	(TmpPuckX).w,d0
	move.w	(pucky).w,d1
	bsr.w	ClampYPosition
	jsr	(vtoa).l
	bsr.w	AdjustFacingDirection
	move.w	(gameclock).w,d0
	andi.w	#7,d0
	asl.w	#4,d0
	addi.w	#$A0,d0
	cmpi.w	#$DE,(pucky).w
	bgt.w	.12
	cmpi.w	#$FF22,(pucky).w
	bgt.w	.13
.12
	subi.w	#$40,d0
.13
	move.w	d0,d1
	muls.w	(puckvx).w,d0
	swap	d0
	add.w	(TmpPuckX).w,d0
	muls.w	(puckvy).w,d1
	swap	d1
	add.w	(pucky).w,d1
	bsr.w	ClampYPosition
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	cmp.l	#$384,d0
	bhi.w	.14
	movem.w	(sp)+,d0-d1
	bra.w	.16
.14
	jsr	(sroot).l
	moveq	#1,d2
	add.w	d0,d2
	moveq	#$12,d4
	btst	#3,(sflags).w
	beq.w	.15
	addq.w	#8,d4
.15
	movem.w	(sp)+,d0-d1
	muls.w	d4,d1
	addq.w	#8,d4
	muls.w	d4,d0
	divs.w	d2,d0
	divs.w	d2,d1
.16
	add.w	d3,d1
	move.w	d1,d2
	btst	#0,(gmode2).w
	bne.w	.18
	btst	#2,(BA_PS_flags).w
	bne.w	.18
	btst	#3,(sflags).w
	bra.w	.18	;95: always (94 beq). The lines to .18 are dead
	cmpi.w	#$D0,(pucky).w
	bgt.w	.17
	cmpi.w	#$FF30,(pucky).w
	blt.w	.17
	bra.w	.18
.17
	cmpi.w	#$14,(a3)
	bgt.w	.18
	cmpi.w	#$FFEC,(a3)
	blt.w	.18
	btst	#3,(gameclock+1).w	;94 bit 1, bne
	beq.w	.18
	bra.w	.19
.18
	cmpi.w	#$22,2(a0)
	bhi.w	.de5
	cmpi.w	#$18,(a0)
	bgt.w	.22
	cmpi.w	#$FFE8,(a0)
	blt.w	.22
	cmpi.w	#$D,2(a0)
	bhi.w	.20
.19
	cmpi.w	#$10B,(pucky).w
	bgt.w	.20
	cmpi.w	#$FEF5,(pucky).w
	blt.w	.20
	bset	#1,$63(a3)
	bne.w	.20
	jsr	(goaliesave).l
.20
	move.w	(a0),d0
	cmpi.w	#$FF,(pucky).w
	bgt.w	.21
	cmpi.w	#$FF01,(pucky).w
	bgt.w	.de5
.21
	moveq	#$18,d0
	tst.w	(TmpPuckX).w
	bpl.w	.de5
	neg.w	d0
.de5
	move.w	d2,d1
	movem.w	d0-d1,-(sp)
	move.b	$28(a3),d0
	ext.w	d0
	neg.w	d0
	add.w	(sp)+,d0
	sub.w	(a3),d0
	move.b	$2A(a3),d1
	ext.w	d1
	neg.w	d1
	add.w	(sp)+,d1
	sub.w	$14(a3),d1
	cmp.w	#4,d0
	bgt.w	.vt
	cmp.w	#$FFFC,d0
	blt.w	.vt
	cmp.w	#4,d1
	bgt.w	.vt
	cmp.w	#$FFFC,d1
	blt.w	.vt
	clr.w	d0
	clr.w	d1
.vt
	btst	#3,$62(a3)	;95: half the y step unless joystick controlled
	bne.w	.vt2
	asr.w	#1,d1
.vt2
	jsr	(vtoa).l
	move.b	d0,$43(a3)	;move d0 into temp2+1
.nodec
	move.b	$43(a3),d2	;temp2+1
	ext.w	d2
	cmp.w	#7,d2
	ble.w	.pa
	jmp	(stopna).l	;95 jmp: both are far now (94 bra)
.pa
	jmp	(playeracc).l
.22
	tst.w	(puckc).w
	bpl.s	.de5
	btst	#2,(iflags).w
	bne.w	.de5
	movea.w	#(HmShots-M68K_RAM),a1
	lea	tmsize(a1),a2
	btst	#6,$62(a3)
	beq.w	.23
	exg	a1,a2
.23
	cmpi.l	#$1324,$2A(a1)
	blt.w	.de5
	cmpi.l	#$9C4,$2A(a2)
	blt.w	.de5
	cmpi.w	#$E3,(pucky).w
	bgt.w	.24
	cmpi.w	#$FF1D,(pucky).w
	bgt.w	.de5
.24
	tst.w	(puckvy).w
	btst	#7,$62(a3)
	beq.w	.25
	eori	#8,ccr
.25
	bmi.w	.de5
	move.w	(puckvx).w,d0
	bpl.w	.26
	neg.w	d0
.26
	move.w	(puckvy).w,d1
	bpl.w	.27
	neg.w	d1
.27
	cmp.w	d0,d1
	blt.w	.de5
	moveq	#$14,d0	;assignment assgoalietopuck (94 $F)
	bra.w	assinsert
ClampYPosition	;no IDA label (IDA dc.b). 93 name. d1 = y clamped to +-$106 (94 $103), minus goal line d3. d0 = 0 if a3 has the puck
	move.w	(puckc).w,d2
	cmp.w	SCnum(a3),d2
	bne.w	.0
	clr.w	d0
.0
	cmp.w	#$106,d1
	blt.w	.1
	move.w	#$106,d1
.1
	cmp.w	#$FEFA,d1
	bgt.w	.2
	move.w	#$FEFA,d1
.2
	sub.w	d3,d1
	rts
AdjustFacingDirection	;IDA: sub_80426. 93 name. Turn facedir one step toward direction d0. IDA cannot show btst Dn,#imm, so it lost the
	;three btst lines and the .t / .set targets; written from the retail bytes as 93. Also called from checks95_06
	move.w	facedir(a3),d1		;facedir
	sub.w	d1,d0
	beq.w	rtsskate	;94 rtss2
	neg.w	d0
	andi.w	#4,d0
	lsr.w	#1,d0
	subq.w	#1,d0			;d0 = +1/-1
	btst	#3,$62(a3)		;pfjoycon
	bne.w	.add
	btst	d1,#$42			;facing 1 or 6
	beq.w	.add
	add.w	d0,d1
	btst	#pfgoal,pflags(a3)		;pfgoal
	bne.w	.dn
	btst	d1,#$83			;0, 1 or 7
	bra.w	.t
.dn	btst	d1,#$38	;3, 4 or 5
.t	beq.w	.set
	neg.w	d0
	add.w	d0,d1
.add	add.w	d0,d1
.set	andi.w	#7,d1
	move.w	d1,facedir(a3)		;facedir
	rts
; set save animation for goalie depending on puck location
; a3 = goalie
; a0 = puckcross
; d3 = goalline of goalie
goaliesave	;IDA: sub_80478. checks94 goaliesave. 95 first aims the goalie: Xvel from where the puck crosses his y (puckvx / puckvy), and the
	;save side from that, then picks the save from saveanim as 94; 95 adds the dive saves (a top shelf shot with sflags bit 3) and the
	;stack saves ($2AE4 / $2B0E by side and hand when puckz is 3 or more). Also called from checks95_06
	move.w	(a0),d0	;puckcross x frames into d0
	sub.w	(a3),d0	;sub goalie Xpos from d0
	move.w	d3,d1	;move goalline into d1
	sub.w	$14(a3),d1	;sub goalie Ypos from d1
	jsr	(vtoa).l
	sub.w	$54(a3),d0	;sub facedir from d0
	andi.w	#7,d0
	move.w	d0,d3	;direction to the crossing, for the glove check
	movem.l	d1-d4,-(sp)	;95: frames until the puck reaches the goalie y
	move.w	$14(a3),d1
	sub.w	(pucky).w,d1
	ext.l	d1
	tst.w	(puckvy).w
	bne.w	.0
	moveq	#1,d1
	bra.w	.1
.0
	divs.w	(puckvy).w,d1
.1
	move.w	d1,-(sp)	;puck x then, minus goalie Xpos
	move.w	(puckvx).w,d2
	muls.w	d2,d1
	add.w	(puckx).w,d1
	sub.w	(a3),d1
	move.w	(sp)+,d2
	bne.w	.2
	move.w	#1,d2
.2
	move.w	d1,d3
	ext.l	d3
	divs.w	d2,d3
	asl.w	#8,d3
	move.w	d3,$28(a3)	;Xvel to get there
	btst	#7,$62(a3)
	bne.w	.3
	neg.w	d1
.3
	move.w	#0,d0	;save side: 0 or 4 by the side the puck passes
	tst.w	d1
	bpl.w	.4
	move.w	#4,d0
.4
	movem.l	(sp)+,d1-d4
	lsr.w	#2,d0	;divide d0 by 4
	btst	#3,4(a3)
	beq.w	.5
	eori.w	#1,d0
.5
	cmpi.w	#8,(puckz).w	;high shot: shoulder saves
	bgt.w	.6
	cmpi.w	#$800,(puckvz).w
	bgt.w	.6
	bra.w	.8
.6
	movem.l	d0,-(sp)
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$10,d0
	bgt.w	.7
	cmp.w	#$FFF0,d0
	blt.w	.7
	movem.l	(sp)+,d0
	addq.w	#6,d0
	bra.w	.18
.7
	movem.l	(sp)+,d0
	bra.w	.18
.8
	addq.w	#4,d0
	cmpi.w	#8,2(a0)	;puckcross frames
	bls.w	.15
	cmpi.w	#2,$54(a3)
	beq.w	.18
	cmpi.w	#6,$54(a3)
	beq.w	.18
	tst.w	(puckc).w
	bmi.w	.18
	subq.w	#2,d0
	bsr.w	.9
	bra.w	.18
.9	;pad stack: slide the goalie 6 toward the middle, d0 by net and hand
	move.w	d1,-(sp)
	move.w	#$1000,d1
	move.w	d1,$28(a3)
	ori.w	#1,d0
	btst	#7,$62(a3)
	bne.w	.10
	eori.w	#1,d0
.10
	move.w	#$FFFA,d1
	tst.w	$28(a3)
	bmi.w	.11
	neg.w	$28(a3)
.11
	tst.w	(a3)
	bpl.w	.13
	tst.w	$28(a3)
	bpl.w	.12
	neg.w	$28(a3)
.12
	move.w	#6,d1
	eori.w	#1,d0
.13
	add.w	d1,(a3)
	btst	#0,$76(a3)	;check hand of goalie
	beq.w	.14
	eori.w	#1,d0
.14
	move.w	(sp)+,d1
	rts
.15
	movem.l	d0,-(sp)
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$10,d0
	ble.w	.16
	movem.l	(sp)+,d0
	bra.w	.17
.16
	cmp.w	#$FFF0,d0
	movem.l	(sp)+,d0
	bgt.w	.18
.17
	addq.w	#4,d0
.18
	add.w	d0,d0
	lea	saveanim(pc),a1
	move.w	(a1,d0.w),d1	;SPA of the save
	cmp.w	#$1CB8,d1
	bne.w	.19
	andi.w	#3,d3
	beq.w	.19
	cmpi.b	#$B,$73(a3)	;73 = Glove Left
	blt.w	.19	;95 dropped the reach out glove save line; the branch stays
.19
	cmp.w	#$205E,d1	;95: a pad stack facing up or down, with sflags bit 3: dive ($23E8, or $23BE 40 times in 100)
	beq.w	.20
	cmp.w	#$200C,d1
	bne.w	.24
.20
	tst.w	$54(a3)
	beq.w	.21
	cmpi.w	#4,$54(a3)
	bne.w	.24
.21
	btst	#3,(sflags).w
	beq.w	.24
	movem.w	d0,-(sp)
	move.w	#$23E8,d1
	move.w	#$64,d0
	jsr	(randomd0).l
	cmp.w	#$3C,d0
	bgt.w	.22
	bra.w	.23
.22
	move.w	#$23BE,d1
	bra.w	.23
	move.w	#2,d0	;dead: never reached
	bsr.w	.9
	add.w	d0,d0
	lea	saveanim(pc),a1
	move.w	0(a1,d0.w),d1
	bra.w	.23
.23
	movem.w	(sp)+,d0
.24
	cmpi.w	#3,(puckz).w	;95: a raised puck facing up or down: stack save $2AE4 / $2B0E by side and hand
	blt.w	.31
	cmpi.w	#0,$54(a3)
	beq.w	.25
	cmpi.w	#4,$54(a3)
	bne.w	.31
.25
	btst	#7,$62(a3)
	beq.w	.29
	movem.w	d0,-(sp)
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$12,d0
	bgt.w	.26
	cmp.w	#$FFEE,d0
	bgt.w	.30
	bra.w	.28
.26
	move.w	#$2B0E,d1
	btst	#0,$76(a3)
	beq.w	.27
	move.w	#$2AE4,d1
.27
	bra.w	.30
.28
	move.w	#$2AE4,d1
	btst	#0,$76(a3)
	beq.w	.30
	move.w	#$2B0E,d1
	bra.w	.30
.29
	movem.w	d0,-(sp)
	move.w	(a3),d0
	sub.w	(a0),d0
	cmp.w	#$12,d0
	bgt.s	.28
	cmp.w	#$FFEE,d0
	blt.s	.26
.30
	movem.w	(sp)+,d0
.31
	jsr	(SetSPA).l
	addi.w	#$96,(crowdlevel).w
	addi.w	#$A,(CwdExciteLvl).w
	asr.w	$28(a3)
	asr.w	$28(a3)
	asr.w	$2A(a3)
	asr.w	$2A(a3)
	btst	#3,(sflags).w	;95: no Xvel with sflags bit 3
	beq.w	.32
	clr.w	$28(a3)
.32
	rts

saveanim	;IDA: unk_80742. 94 _saveanim (93 GoalieSaveList): SPA per save type, 95 SPA values (10 words; 94: blocker, glove, pad stack right /
	;left, kick, butterfly, high shoulder right / left, stick right / left)
	dc.w	$1C86,$1CB8,$205E,$200C,$1CEA,$1D1C,$1C86,$1CB8,$1CEA,$1D1C

; assignment to have goalie skate to the puck when it is loose
assgoalietopuck	;no IDA label (IDA dc.b), asstab entry $14. The same as 94
	btst	#3,pflags(a3)
	bne.w	assexit	;exit if joystick controlled
	btst	#0,(gmode).w
	bne.w	assexit	;exit if clock stopped
	bsr.w	check4bench
	bclr	#1,pflags(a3)	;new assignment
	beq.w	.0
	clr.w	temp1(a3)
.0
	sub.b	d7,temp1(a3)
	bpl.w	.go
	move.b	aidef(a3),d0	;aidef
	beq.w	.1
	btst	#6,(sflags7).w
	beq.w	.1
	subq.b	#1,d0
.1
	lsr.b	#2,d0
	move.b	d0,temp1(a3)
	tst.w	(puckc).w
	bpl.w	assexit
	tst.w	(puckvy).w
	btst	#7,pflags(a3)
	beq.w	.dir
	eori	#8,ccr
.dir
	bmi.w	assexit
	movea.w	#(HmShots-M68K_RAM),a1	;load home team struct into a1
	lea	tmsize(a1),a2	;load away team struct into a2
	btst	#6,pflags(a3)	;check if player is home or away
	beq.w	.t0	;branch if home
	exg	a1,a2	;swap if away
.t0
	cmpi.l	#$E10,$2A(a1)
	blt.w	assexit
	cmpi.l	#$640,$2A(a2)
	blt.w	assexit
.go
	bra.w	skatetopuck
