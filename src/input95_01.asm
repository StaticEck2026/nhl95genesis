;	NHL 95 input95_01. Retail $083EB2-$084FE5 (4404 bytes).
;	94 input94 doinput (95: its start is sub_83EB2; the mapped start loc_83EC0 is inside it), doinput_islocked, rtss7, faceoffinput,
;	setpassmode, passmode, dopass, passtoa0, then onetimer94 OneTimerTarget and its tables and OneTimerPass (moved in), input94
;	Findhittype, SetShotMode, ShotMode, prepshot, doshot, shotsets, shotdiradj, shotdirmath, onetimer94 puckvzadj and checks94
;	compshoot (moved in). data95_01 follows at $084FE6.
;	The 94 doinput parts doinput_cbut ... doinput_ispc, getGoalieSCnum are in input95_03; the goalie dive (doinput .33) is
;	doinput_goaliedive (checks95_05); burst, Acheck, changeplayer (95 chgplayer), setc1player ... are in setup95_01; SetLCmode, lineinput
;	in input95_02.
;	IDA code except puckvzadj and compshoot (dc.b, read from the retail bytes) and the dead / data bytes noted below. Local labels are
;	numbered; the IDA local names are not kept.
;	95 changes: four pads (doinput_islocked marks the player of pad c1 ... c4playernum), the 95 asstab numbers and SPA values, the y
;	limits moved 3 out ($108 to $10B ...), the PAL speed $18 (94 $16), the one-timer table offsets, Findhittype's two masks swapped,
;	shotsets $E / $FFF2 (94 $10 / $FFF0), jsr / jmp .l to the routines 95 moved out of range.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


doinput	;IDA: sub_83EB2. Process controller input for player a3: d0 = dpad, d1 = new buttons, d2 = changed buttons, d3 = held buttons,
	;d4 = pad 0 / 2 / 4 / 6. 95: button A clears pflags2 bit 7 first
	btst	#6,d1
	beq.w	.0
	bclr	#7,$63(a3)
.0
	btst	#4,d1
	beq.w	.1
	btst	#5,d1
	beq.w	.1
	bclr	#4,d1
	bset	#6,$64(a3)
	bra.w	.5
.1
	btst	#4,d1
	beq.w	.2
	bclr	#6,$64(a3)
.2
	btst	#4,d2
	beq.w	.5
	bclr	#6,$64(a3)
	beq.w	.5
	tst.w	d4
	bne.w	.3
	move.b	#$11,(bholdtimer).w
	bra.w	.4
.3
	move.b	#$11,(bholdtimer+1).w
.4
	bclr	#4,d2
.5
	btst	#7,(gmode2).w
	beq.w	.6
	cmp.b	#8,d0
	beq.w	.6
	jsr	(ShortenMsgTimer).l
.6
	move.w	d0,(TempWord1).w
	andi.w	#$F,(TempWord1).w
	jsr	(setpads).l
	btst	#7,d1
	beq.w	.7
	tst.w	d4
	beq.w	startpause1
	cmp.w	#2,d4
	beq.w	startpause2
	cmp.w	#4,d4
	beq.w	startpause3
	cmp.w	#6,d4
	beq.w	startpause4
.7
	btst	#0,(sflags2).w
	bne.w	faceoffinput
	btst	#3,$63(a3)
	bne.w	lineinput
	btst	#3,$62(a3)
	beq.w	rtss7
	movem.l	d0-d2/a0/a3,-(sp)
	move.w	(lastplayer).w,d0
	cmp.w	$52(a3),d0
	bne.w	.8
	tst.w	(passplayer).w
	bmi.w	.8
	tst.w	(onetimerplayer).w
	bpl.w	.8
	btst	#5,d1
	beq.w	.8
	move.w	(passplayer).w,d0
	asl.w	#7,d0
	movea.l	#$FFFFAC62,a3
	adda.w	d0,a3
	tst.w	$34(a3)
	beq.w	.8
	btst	#3,$62(a3)
	bne.w	.8
	btst	#3,$64(a3)
	bne.w	.8
	move.w	d4,(inputjoy).w
	move.w	#$18,d0
	jsr	(assreplace).l
	movem.l	(sp)+,d0-d2/a0/a3
	rts
.8
	movem.l	(sp)+,d0-d2/a0/a3
	btst	#3,$64(a3)
	bne.w	.9
	btst	#5,$62(a3)
	bne.w	doinput_islocked
.9
	move.w	(puckc).w,d5
	cmp.w	$52(a3),d5
	beq.w	.41
	tst.w	$34(a3)
	beq.w	.11
	btst	#3,$64(a3)
	beq.w	.10
	bra.w	.11
.10
	btst	#6,d1
	beq.w	.11
	jmp	holdplayer
.11
	tst.w	$34(a3)
	beq.w	.12
	btst	#2,(BA_PS_flags).w
	bne.w	.37
	bra.w	.16
.12
	btst	#6,(sflags5).w
	bne.w	.16
	tst.w	d4
	beq.w	.13
	tst.w	(goaliemode2).w
	bra.w	.14
.13
	tst.w	(goaliemode1).w
.14
	beq.w	.16
	movem.w	d0,-(sp)
	move.w	$52(a3),d0
	cmp.w	(puckc).w,d0
	movem.w	(sp)+,d0
	beq.w	.16
.15
	jmp	chgplayer
.16
	btst	#4,d3
	beq.w	.24
	tst.w	(holdreset).w
	bne.w	.24
	tst.w	d4
	beq.w	.20
	tst.b	(bholdtimer+1).w
	beq.w	.37
	subq.b	#1,(bholdtimer+1).w
	bpl.w	.17
	move.b	#0,(bholdtimer+1).w
.17
	tst.b	(bholdtimer+1).w
	bne.w	.24
	tst.w	d4
	beq.w	.18
	tst.w	(goaliemode2).w
	bra.w	.19
.18
	tst.w	(goaliemode1).w
.19
	bne.w	.24
	bra.w	.32
.20
	tst.b	(bholdtimer).w
	beq.w	.37
	subq.b	#1,(bholdtimer).w
	bpl.w	.21
	move.b	#0,(bholdtimer).w
.21
	tst.w	d4
	beq.w	.22
	tst.w	(goaliemode2).w
	bra.w	.23
.22
	tst.w	(goaliemode1).w
.23
	bne.w	.24
	tst.b	(bholdtimer).w
	beq.w	.32
.24
	btst	#4,d1
	beq.w	.26
	tst.w	d4
	bne.w	.25
	move.b	#$11,(bholdtimer).w
	bra.w	.37
.25
	move.b	#$11,(bholdtimer+1).w
	bra.w	.37
.26
	btst	#4,d2
	beq.w	.37
	btst	#4,d3
	bne.w	.37
	move.w	(bholdtimer).w,d0
	tst.w	d4
	beq.w	.29
	move.b	#$11,(bholdtimer+1).w
	andi.w	#$FF,d0
	bne.w	.15
	tst.w	d4
	beq.w	.27
	tst.w	(goaliemode2).w
	bra.w	.28
.27
	tst.w	(goaliemode1).w
.28
	bne.w	.15
	bra.w	.32
.29
	move.b	#$11,(bholdtimer).w
	andi.w	#$FF00,d0
	bne.w	.15
	tst.w	d4
	beq.w	.30
	tst.w	(goaliemode2).w
	bra.w	.31
.30
	tst.w	(goaliemode1).w
.31
	bne.w	.15
.32
	tst.w	(holdreset).w
	bne.w	.15
	move.w	#5,d0
	cmp.w	#5,d6
	ble.w	.33
	move.w	#$B,d0
.33
	jsr	(FindGoalie).l
	tst.w	d0
	bmi.w	rtss7
	movem.l	d0/a3,-(sp)
	movea.l	#$FFFFAC62,a3
	asl.w	#7,d0
	adda.w	d0,a3
	btst	#3,$62(a3)
	movem.l	(sp)+,d0/a3
	bne.w	rtss7
	tst.w	d4
	bne.w	.34
	jmp	setc1player
.34
	cmp.w	#2,d4
	bne.w	.35
	jmp	setc2player
.35
	cmp.w	#4,d4
	bne.w	.36
	jmp	setc3player
.36
	jmp	setc4player
.37
	tst.w	$34(a3)
	bne.w	.38
	jmp	doinput_goaliedive
.38
	move.w	(TempWord1).w,d0
	btst	#3,$64(a3)
	bne.w	rtss7
	btst	#5,d1
	beq.w	doplayeracc
	movem.l	d7-a0,-(sp)
	move.w	(lastplayer).w,d7
	asl.w	#7,d7
	movea.l	#$FFFFAC62,a0
	adda.w	d7,a0
	tst.w	$34(a0)
	movem.l	(sp)+,d7-a0
	beq.w	.39
	movem.w	d7,-(sp)
	move.w	$52(a3),d7
	cmp.w	(passplayer).w,d7
	movem.w	(sp)+,d7
	bne.w	.39
	tst.w	(puckc).w
	bpl.w	.39
	jsr	(PuckOnAttackHalf).l
	beq.w	.39
	move.w	d0,-(sp)
	move.w	d4,(inputjoy).w
	move.w	#$18,d0
	jsr	(assreplace).l
	move.w	(sp)+,d0
	rts
.39
	cmp.w	#7,d0
	bgt.w	.40
	move.w	d0,$54(a3)
.40
	jmp	burstchk
.41
	bsr.w	checkob
	tst.w	$34(a3)
	bne.w	.42
	btst	#1,$63(a3)
	bne.w	rtss7
.42
	btst	#2,(sflags).w
	bne.w	passmode
	btst	#3,(sflags).w
	bne.w	ShotMode
	btst	#4,d1
	beq.w	.43
	bra.w	setpassmode
.43
	movem.l	a0,-(sp)
	movea.l	#$FFFFD022,a0
	btst	#6,d1
	beq.w	.49
	movem.l	d5-d6/a1-a4,-(sp)
	move.w	d3,d5
	andi.w	#$F,d5
	btst	#7,$62(a3)
	bne.w	.44
	btst	#0,d5
	beq.w	.46
	bra.w	.45
.44
	btst	#1,d5
	beq.w	.46
.45
	move.w	#1,d6
	bra.w	.47
.46
	clr.w	d6
.47
	movem.l	(sp)+,d5-d6/a1-a4
	beq.w	.48
	bset	#1,(GameFlags).w
	movem.l	(sp)+,a0
	bra.w	setpassmode
	dc.b	8,0,4,8,6,7,5,8,2,1,3,8,8,8,8,8	;unused: dpad bits to a direction (8 = none)
.48
	move.w	#$F,(a0,d4.w)
.49
	btst	#6,d3
	beq.w	.51
	subq.w	#1,(a0,d4.w)
	bpl.w	.50
	clr.w	(a0,d4.w)
.50
	tst.w	(a0,d4.w)
	bne.w	.51
	movea.l	#$FFFFBF14,a0
	move.w	#1,(a0,d4.w)
	movem.l	(sp)+,a0
	jmp	SetLCmode
.51
	movem.l	(sp)+,a0
	btst	#6,d3
	bne.w	.56
	btst	#6,d2
	beq.w	.56
	bclr	#7,$63(a3)
	bne.w	.56
	btst	#3,$63(a3)
	bne.w	.56
	movem.w	d0,-(sp)
	move.w	(pucky).w,d0
	bpl.w	.52
	neg.w	d0
.52
	cmp.w	#$56,d0
	blt.w	.55
	move.w	(pucky).w,d0
	btst	#7,$62(a3)
	bne.w	.53
	neg.w	d0
.53
	tst.w	d0
	bmi.w	.55
	movem.w	(sp)+,d0
	bset	#0,(GameFlags).w
	bne.w	.54
	jmp	SetShotMode
.54
	rts
.55
	movem.w	(sp)+,d0
	bset	#3,(sflags5).w
	bra.w	setpassmode
.56
	tst.w	$34(a3)
	bne.w	.57
	bra.w	doplayeracc
.57
	btst	#5,d1
	beq.w	doplayeracc
	bra.w	SetShotMode

doinput_islocked	;IDA: loc_843F0. 94 global (doinput branches across). B with the player not the carrier: change player (chgplayer) and
	;set $64 bit 6 of the pad's new player (95: pads 1 to 4)
	move.w	(puckc).w,d5
	cmp.w	$52(a3),d5
	beq.w	rtss7
	btst	#4,d1
	beq.w	rtss7
	btst	#6,(sflags5).w
	bne.w	rtss7
	jsr	(chgplayer).l
	movem.l	d0/a0,-(sp)
	tst.w	d4
	beq.w	.3
	cmp.w	#2,d4
	beq.w	.2
	cmp.w	#4,d4
	beq.w	.1
	bra.w	.0
.0
	move.w	(c4playernum).w,d0
	bra.w	.4
.1
	move.w	(c3playernum).w,d0
	bra.w	.4
.2
	move.w	(c2playernum).w,d0
	bra.w	.4
.3
	move.w	(c1playernum).w,d0
.4
	tst.w	d0
	bmi.w	.5
	asl.w	#7,d0
	movea.l	#$FFFFAC62,a0
	adda.w	d0,a0
	bset	#6,$64(a0)
.5
	movem.l	(sp)+,d0/a0

rtss7	;IDA: locret_84468. The doinput_islocked rts
	rts

faceoffinput	;IDA: loc_8446A. The faceoff player (assignment $11, 94 $17): store the dpad pull (fodir1 / fodir2) and start the faceoff
	;swipe on B (95 SPA $1B36 / $1B60; 94 $FEA / $1014)
	btst	#6,(sflags5).w
	beq.w	.1
.0
	rts
.1
	move.w	$36(a3),d4
	cmpi.b	#$11,$38(a3,d4.w)
	bne.s	.0
	movea.w	#(fodir1-M68K_RAM),a0
	btst	#7,$62(a3)
	beq.w	.2
	movea.w	#(fodir2-M68K_RAM),a0
.2
	move.w	d0,(a0)
	btst	#1,$63(a3)
	bne.s	.0
	btst	#4,d1
	beq.w	.3
	move.w	#$1B36,d1
	bset	#1,$63(a3)
	jmp	SetSPA
.3
	move.w	#$1B60,d1
	jmp	SetSPA

setpassmode	;IDA: loc_844C0. Pass direction mode: passdir = facedir, sflags bit 2 (95 drops the 94 penalty shot part)
	move.w	$54(a3),(passdir).w
	andi.w	#7,(passdir).w
	bset	#2,(sflags).w

rtss	;IDA: locret_844D2. The setpassmode rts
	rts

passmode	;IDA: loc_844D4. Start passing: on a B change (or sflags5 bit 3) dopass, else a new pass direction from the dpad
	btst	#4,d2
	bne.w	dopass
	btst	#3,(sflags5).w
	bne.w	dopass
	btst	#3,d0
	bne.s	rtss
	andi.w	#7,d0
	move.w	d0,(passdir).w
	bset	#3,d0

dopass	;IDA: loc_844F8. Pass the puck from a3 in passdir: pick the receiver (passtoa0), set the puck speed
	movem.l	d0-d5/a0-a1,-(sp)
	bclr	#2,(sflags).w
	st	(puckc).w
	move.b	#$10,$5E(a3)
	btst	#1,(GameFlags).w
	beq.w	.0
	move.b	#$18,$5E(a3)
.0
	move.w	$52(a3),(lastplayer).w
	bclr	#3,(sflags5).w
	beq.w	.2
	jsr	(OneTimerTarget).l
	move.w	#9,(onetimerheight).w
	btst	#2,(sflags6).w
	beq.w	.1
	move.w	#$20,(onetimerheight).w
.1
	jsr	(OneTimerPass).l
	bra.w	.8
.2
	moveq	#8,d0
	tst.w	$34(a3)
	beq.w	.3
	move.b	$6E(a3),d0
.3
	asl.w	#2,d0
	asr.w	#1,d0
	addi.w	#$A0,d0
	move.w	d0,(passspeed).w
	btst	#0,$6E(a3)
	beq.w	.4
	asr.w	#4,d0
	add.w	d0,(passspeed).w
.4
	moveq	#$FFFFFFFF,d4
	moveq	#5,d3
	movea.w	#(SortCords-M68K_RAM),a1
	cmpi.w	#6,$52(a3)
	blt.w	.5
	adda.w	#$300,a1
	btst	#2,(BA_PS_flags).w
	bne.w	.7
.5
	cmpa.l	a1,a3
	beq.w	.6
	tst.w	$34(a1)
	ble.w	.6
	btst	#2,$63(a1)
	bne.w	.6
	move.w	(a1),d0
	sub.w	(puckx).w,d0
	move.w	$14(a1),d1
	sub.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	jsr	(vtoa).l
	movem.w	(sp)+,d1-d2
	sub.w	(passdir).w,d0
	andi.w	#7,d0
	asl.b	#5,d0
	ext.w	d0
	asl.w	#3,d0
	muls.w	d0,d0
	cmp.l	#$10000,d0
	bhi.w	.6
	muls.w	d1,d1
	muls.w	d2,d2
	add.l	d1,d2
	cmp.l	d4,d2
	bhi.w	.6
	move.l	d2,d4
	movea.l	a1,a0
.6
	adda.w	#$80,a1
	dbf	d3,.5
	tst.l	d4
	bmi.w	.7
	bsr.w	passtoa0
	bra.w	.8
.7
	move.w	(passdir).w,d0
	asl.w	#2,d0
	movea.l	#dirtab,a0
	move.w	2(a0,d0.w),d1
	muls.w	(passspeed).w,d1
	moveq	#$A,d2
	asl.l	d2,d1
	divs.w	#$B40,d1
	add.w	$2A(a3),d1
	move.w	d1,(puckvy).w
	move.w	(a0,d0.w),d1
	muls.w	(passspeed).w,d1
	asl.l	d2,d1
	divs.w	#$B40,d1
	add.w	$28(a3),d1
	move.w	d1,(puckvx).w
	move.w	#$1000,d0
	jsr	(randomd0).l
	move.w	d0,(puckvz).w
	btst	#1,(GameFlags).w
	beq.w	.8
	clr.w	(puckvz).w
	move.w	(puckvx).w,d0
	asr.w	#2,d0
	move.w	d0,(puckvx).w
	move.w	(puckvy).w,d0
	asr.w	#2,d0
	move.w	d0,(puckvy).w
.8
	tst.w	$34(a3)
	bne.w	.11
	tst.w	(puckvy).w
	btst	#7,$62(a3)
	beq.w	.9
	bmi.w	.10
	bra.w	.11
.9
	bmi.w	.11
.10
	neg.w	(puckvy).w
.11
	move.w	(puckvx).w,d0
	move.w	(puckvy).w,d1
	jsr	(vtoa).l
	move.w	#$1F9A,d1
	tst.w	$34(a3)
	beq.w	.13
	move.w	#$1362,d1
	btst	#1,(GameFlags).w
	beq.w	.12
	move.w	#$13D4,d1
.12
	bsr.w	Findhittype
	beq.w	.13
	move.w	#$1426,d1
	btst	#1,(GameFlags).w
	beq.w	.13
	move.w	#$1498,d1
.13
	jsr	(SetSPA).l
	bset	#5,$62(a3)
	moveq	#$C,d0
	sub.b	(puckvz).w,d0
	lsr.w	#2,d0
	btst	#1,(GameFlags).w
	bne.w	.14
	andi.w	#3,d0
	addi.w	#$10,d0
	move.w	d0,-(sp)
	jsr	(sfx).l
.14
	movem.l	(sp)+,d0-d5/a0-a1
	rts

passtoa0	;IDA: sub_8471A. Pass to player a0
	btst	#3,$62(a3)
	beq.w	.0
.0
	jsr	(loadTeamStruct).l
	addq.w	#1,$12(a2)
	move.w	$52(a0),(passplayer).w
	move.w	(passspeed).w,d5
	asr.w	#2,d5
	exg	a0,a3
	moveq	#$D,d0
	jsr	(assinsert).l
	exg	a0,a3
	move.l	a0,-(sp)
	jsr	(GetHot).l
	add.w	(a0),d0
	sub.w	(puckx).w,d0
	add.w	$14(a0),d1
	sub.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	movem.w	(sp),d2-d3
	asr.w	#2,d2
	asr.w	#2,d3
	move.w	$28(a0),d0
	muls.w	#$F0,d0
	swap	d0
	move.w	$2A(a0),d1
	muls.w	#$F0,d1
	swap	d1
	movem.w	d0-d1,-(sp)
	muls.w	d2,d0
	muls.w	d3,d1
	add.w	d1,d0
	asl.w	#1,d0
	move.w	d0,d4
	movem.w	(sp),d0-d1
	muls.w	d0,d0
	muls.w	d1,d1
	muls.w	d5,d5
	neg.l	d5
	add.l	d0,d5
	add.l	d1,d5
	muls.w	d2,d2
	muls.w	d3,d3
	add.l	d2,d3
	muls.w	d5,d3
	asl.l	#2,d3
	move.w	d4,d0
	muls.w	d0,d0
	sub.l	d3,d0
	jsr	(sroot).l
	moveq	#1,d3
	asr.w	#2,d5
	bne.w	.1
	moveq	#1,d5
.1
	move.w	d0,d2
	neg.w	d0
	sub.w	d4,d2
	ext.l	d2
	divs.w	d5,d2
	dbpl	d3,.1
	bne.w	.2
	addq.w	#1,d2
.2
	cmp.w	#$18,d2
	bls.w	.3
	moveq	#$18,d2
.3
	btst	#1,(GameFlags).w
	beq.w	.4
	asl.w	#2,d2
.4
	move.b	d2,(puckvz).w
	cmp.w	#$C,d2
	blt.w	.5
	move.b	#$C,(puckvz).w
	btst	#1,(GameFlags).w
	beq.w	.5
	clr.w	(puckvz).w
.5
	move.w	d2,d0
	asl.w	#3,d0
	subi.w	#$A,d0
	move.b	d0,$40(a0)
	subq.w	#6,d0
	move.b	d0,(puckx+nopuck).w
	movem.w	(sp)+,d0-d1
	muls.w	d2,d0
	asr.l	#1,d0
	add.w	(sp)+,d0
	move.w	(puckx).w,$44(a0)
	add.w	d0,$44(a0)
	muls.w	d2,d1
	asr.l	#1,d1
	add.w	(sp)+,d1
	move.w	(pucky).w,$46(a0)
	add.w	d1,$46(a0)
	mulu.w	#$78,d2
	swap	d0
	divs.w	d2,d0
	move.w	d0,(puckvx).w
	swap	d1
	divs.w	d2,d1
	move.w	d1,(puckvy).w
	rts

OneTimerTarget	;IDA: sub_84850. onetimer94 OneTimerTarget (moved in). One-timer pass target for receiver a3: an offset by facing from
	;OneTimerNearTbl / OneTimerFarTbl (skater, near or far from the goal) or OneTimerGoalieTbl
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#2,(sflags6).w
	tst.w	$34(a3)
	bne.w	.0
	movea.l	#OneTimerGoalieTbl,a0
	bra.w	.2
.0
	move.w	$14(a3),d0
	btst	#7,$62(a3)
	bne.w	.1
	neg.w	d0
.1
	bset	#2,(sflags6).w
	movea.l	#OneTimerNearTbl,a0
	cmp.w	#$56,d0
	blt.w	.2
	movea.l	#OneTimerFarTbl,a0
	bclr	#2,(sflags6).w
.2
	move.w	$54(a3),d0
	btst	#7,$62(a3)
	bne.w	.3
	addq.w	#4,d0
	andi.w	#7,d0
.3
	asl.w	#2,d0
	move.w	(a0,d0.w),d1
	move.w	2(a0,d0.w),d2
	cmpa.l	#OneTimerFarTbl,a0
	bne.w	.6
	move.w	$14(a3),d0
	bpl.w	.4
	neg.w	d0
.4
	cmp.w	#$88,d0
	blt.w	.6
	move.w	(a3),d0
	bpl.w	.5
	neg.w	d0
.5
	cmp.w	#$37,d0
	bgt.w	.6
	move.w	#$106,d2
.6
	btst	#7,$62(a3)
	bne.w	.7
	neg.w	d1
	neg.w	d2
.7
	move.w	#$A,d0
	jsr	(randomd0).l
	add.w	d0,d1
	move.w	#$A,d0
	jsr	(randomd0).l
	add.w	d0,d2
	move.w	d1,(onetimertargetx).w
	tst.w	$34(a3)
	beq.w	.9
	sub.w	(a3),d1
	bmi.w	.8
	subi.w	#$3C,d1
	bpl.w	.9
	neg.w	d1
	add.w	d1,(onetimertargetx).w
	bra.w	.9
.8
	addi.w	#$3C,d1
	bmi.w	.9
	sub.w	d1,(onetimertargetx).w
.9
	move.w	d2,(onetimertargety).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

OneTimerNearTbl	;IDA: unk_8494A. OneTimerTarget target offsets (x, y) by facing, receiver near the goal
	dc.w	$70,$C5,$70,$C5,$70,$C5,$70,$C5	;94 $74, $C2
	dc.w	$FF90,$C5,$FF90,$C5,$FF90,$C5,$FF90,$C5

OneTimerFarTbl	;IDA: unk_8496A. OneTimerTarget target offsets (x, y) by facing, receiver far from the goal
	dc.w	$FFFB,$AB,$FFFB,$AB,$FFFB,$AB,$FFFB,$AB
	dc.w	$FFFB,$AB,$FFFB,$AB,$FFFB,$AB,$FFFB,$AB

OneTimerGoalieTbl	;IDA: unk_8498A. OneTimerTarget target offsets (x, y) by facing, goalie
	dc.w	$FFFB,$FFF4,$32,$FFF4,$32,$FFF4,$32,$FFF4	;94 $FFF7
	dc.w	$FFFB,$FFF4,$FFCE,$FFF4,$FFCE,$FFF4,$FFCE,$FFF4

OneTimerPass	;IDA: sub_849AA. onetimer94 OneTimerPass (moved in). One-timer pass: puckvz = sqrt(12 * onetimerheight), then puckvx / puckvy
	;toward the target onetimertargetx / onetimertargety in puckvz
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$C,d0
	move.w	(onetimerheight).w,d1
	mulu.w	d1,d0
	swap	d0
	andi.l	#$FFFF0000,d0
	jsr	(sroot).l
	move.w	d0,(puckvz).w
	ext.l	d0
	move.w	#3,d4
	divu.w	d4,d0
	clr.l	d1
	move.w	(onetimertargetx).w,d1
	sub.w	(puckx).w,d1
	swap	d1
	tst.w	d0
	bne.w	.0
	move.w	#1,d0
.0
	divs.w	d0,d1
	move.w	d1,(puckvx).w
	clr.l	d1
	move.w	(onetimertargety).w,d1
	sub.w	(pucky).w,d1
	swap	d1
	divs.w	d0,d1
	move.w	d1,(puckvy).w
	movea.l	#$FFFFB362,a3
	move.w	(puckvz).w,d0
	jsr	(puckflip).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

Findhittype	;IDA: sub_84A16. 94 name. Z by direction d0 from facedir and the hand (attribute bit 3): btst Dn,#imm (IDA cannot show it).
	;95 swaps the two masks of 94
	neg.w	d0
	add.w	facedir(a3),d0
	andi.w	#7,d0
	btst	#3,attribute(a3)	;attribute bit 3
	beq.w	.1
	btst	d0,#$1E	;%00011110 (94 %11110000)
	rts
.1
	btst	d0,#$F0	;%11110000 (94 %00011110)
	rts

SetShotMode	;IDA: loc_84A36. Initiate a shot by player a3
	btst	#2,(BA_PS_flags).w
	beq.w	.0
	btst	#0,(GameFlags).w
	bne.w	.0
	bclr	#2,(gmode2).w
	bset	#5,(BA_PS_flags).w
	bne.w	.5
	bclr	#5,(gmode2).w
	move.w	#$64,(passmodetimer).w
.0
	move.w	#8,(passdir).w
	bset	#3,(sflags).w
	clr.w	d0
	move.w	#$128,d1
	btst	#7,$62(a3)
	bne.w	.1
	neg.w	d1
.1
	sub.w	(a3),d0
	sub.w	$14(a3),d1
	jsr	(vtoa).l
	move.w	#$F,(passspeed).w
	move.w	#$150A,d1
	btst	#0,(GameFlags).w
	beq.w	.2
	move.w	#$163C,d1
.2
	bsr.w	Findhittype
	beq.w	.4
	move.w	#$176E,d1
	btst	#0,(GameFlags).w
	beq.w	.3
	move.w	#$18A0,d1
.3
	move.w	#$13,(passspeed).w
.4
	jmp	SetSPA
.5
	rts

ShotMode	;IDA: loc_84AD0. The shot wind up: aim with the dpad until released
	cmpi.w	#$1C,$5A(a3)
	bge.w	prepshot
	btst	#3,d0
	bne.w	.0
	andi.w	#7,d0
	move.w	d0,(passdir).w
.0
	cmpi.w	#$10,$5A(a3)
	bge.w	.3
	add.w	d7,(passspeed).w
	cmpi.b	#$14,$6C(a3)
	bge.w	.1
	cmpi.w	#8,$5A(a3)
	bgt.w	.2
.1
	btst	#5,d2
	beq.w	.3
.2
	neg.w	$5A(a3)
	addi.w	#$18,$5A(a3)
.3
	rts

prepshot	;IDA: loc_84B20. Prepare the shot (shot direction), then doshot
	bclr	#4,(sflags5).w
	move.w	#$B,d0
	btst	#6,$62(a3)
	beq.w	.0
	move.w	#5,d0
.0
	cmpi.w	#1,(passdir).w
	ble.w	.1
	cmpi.w	#7,(passdir).w
	bne.w	.3
.1
	move.w	(pucky).w,d0
	btst	#7,$62(a3)
	bne.w	.2
	neg.w	d0
.2
	cmp.w	#$D8,d0
	blt.w	.3
	bset	#4,(sflags5).w
.3
	bra.w	doshot

doshot	;IDA: loc_84B6E. Shoot the puck: speed and direction from the shooter's ratings, shotsets, shotdiradj; puckvz. 95: shotpflags,
	;ShotTimer
	movem.l	d0-d7/a0-a3,-(sp)
	bclr	#0,(GameFlags).w
	beq.w	.0
	bclr	#3,(sflags).w
	move.w	#$B8E,d1
	jsr	(SetSPA).l
	jmp	.21
.0
	move.w	#$1E,(ShotTimer).w
	move.b	$62(a3),(shotpflags).w
	bclr	#4,(gmode2).w
	btst	#1,$64(a3)
	beq.w	.1
	bset	#4,(gmode2).w
.1
	bsr.w	shotdiradj
	move.w	#5,-(sp)
	move.w	$52(a3),(shotplayer).w
	bclr	#3,(sflags).w
	bset	#5,$62(a3)
	btst	#3,$64(a3)
	bne.w	.2
	move.w	(puckc).w,d0
	cmp.w	$52(a3),d0
	bne.w	.20
.2
	move.w	#$18,(sp)
	bset	#4,(sflags2).w
	cmpi.w	#$176E,$58(a3)
	bne.w	.3
	move.w	#$14,(sp)
	move.w	(passspeed).w,d0
	lsr.w	#2,d0
	sub.w	d0,(passspeed).w
.3
	btst	#3,$64(a3)
	beq.w	.4
	movem.l	d0-d1,-(sp)
	move.w	#$1F,d0
	move.w	d0,(passspeed).w
	movem.l	(sp)+,d0-d1
.4
	clr.w	d0
	move.b	$6C(a3),d0
	lsr.b	#1,d0
	movea.l	a3,a0
	jsr	(makepde).l
	addi.w	#$14,d0
	mulu.w	(passspeed).w,d0
	mulu.w	#$5249,d0
	swap	d0
	move.w	d0,(passspeed).w
	btst	#0,$6C(a3)
	beq.w	.5
	asr.w	#4,d0
	add.w	(passspeed).w,d0
.5
	lsr.w	#4,d0
	neg.w	d0
	addq.w	#3,d0
	bpl.w	.6
	clr.w	d0
.6
	add.w	d0,(sp)
	st	(puckc).w
	move.b	#$10,$5E(a3)
	move.w	$52(a3),(lastplayer).w
	move.w	#$10B,d1
	btst	#7,$62(a3)
	bne.w	.7
	neg.w	d1
.7
	move.w	(passdir).w,d2
	asl.w	#2,d2
	lea	shotsets(pc),a0
	move.w	(a0,d2.w),d0
	move.w	2(a0,d2.w),d2
	sub.w	(puckx).w,d0
	sub.w	(pucky).w,d1
	movem.w	d0-d2,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	jsr	(sroot).l
	tst.w	d0
	bne.w	.8
	addq.w	#1,d0
.8
	move.w	d0,d3
	btst	#4,(gmode).w
	bne.w	.14
	cmp.w	#$C8,d3
	bhi.w	.9
	jsr	(ReadGoaliePulled).l
	bmi.w	.14
	btst	#0,(gmode2).w
	bne.w	.14
	moveq	#$10,d0
	add.b	$6D(a3),d0
	jsr	(randomd0).l
	cmp.w	#$E,d0
	bgt.w	.14
.9
	clr.w	d0
	move.b	$6D(a3),d0
	lsr.w	#1,d0
	move.b	d0,-(sp)
	move.w	(passspeed).w,d0
	lsr.w	#4,d0
	sub.b	(sp)+,d0
	addi.b	#$10,d0
	mulu.w	d3,d0
	lsr.w	#6,d0
	cmp.w	#$FA,d3
	bhi.w	.10
	lsr.w	#1,d0
.10
	cmp.w	#$98,d0
	blt.w	.11
	move.w	#$98,d0
.11
	move.w	d0,-(sp)
	jsr	(randomd0s).l
	add.w	d0,2(sp)
	move.w	(sp),d0
	cmp.w	#$3C,d0
	bls.w	.12
	moveq	#$3C,d0
	move.w	d0,(sp)
.12
	tst.w	4(sp)
	bpl.w	.13
	lsr.w	#1,d0
.13
	jsr	(randomd0s).l
	add.w	d0,4(sp)
	move.w	(sp)+,d0
	lsr.w	#1,d0
	jsr	(randomd0).l
	add.w	d0,4(sp)
.14
	move.w	(passspeed).w,d2
	muls.w	#$44,d2
	muls.w	(sp)+,d2
	divs.w	d3,d2
	move.w	d2,(puckvx).w
	move.w	(passspeed).w,d2
	muls.w	#$44,d2
	muls.w	(sp)+,d2
	divs.w	d3,d2
	move.w	d2,(puckvy).w
	move.w	#$8000,d1
	btst	#7,$62(a3)
	beq.w	.15
	clr.w	d1
.15
	eor.w	d2,d1
	bpl.w	.16
	move.w	#$3810,(puckvy).w
	btst	#7,$62(a3)
	bne.w	.16
	move.w	#$C7F0,(puckvy).w
.16
	move.w	(sp)+,d1
	beq.w	.20
	mulu.w	(passspeed).w,d1
	mulu.w	#$44,d1
	divu.w	d3,d1
	mulu.w	#$B33,d3
	divu.w	(passspeed).w,d3
	add.w	d1,d3
	cmp.w	#$1800,d3
	bls.w	.17
	move.w	#$1800,d3
.17
	cmpi.w	#$10B,(pucky).w
	bgt.w	.18
	cmpi.w	#$FEF5,(pucky).w
	bge.w	.19
.18
	clr.w	(puckvz).w
	bra.w	.20
.19
	move.w	d3,(puckvz).w
	bra.w	.20
	bclr	#4,(sflags5).w	;dead (the bra above skips it): the 94 top shelf call
	beq.w	.20
	btst	#3,$64(a3)
	bne.w	.20
	jsr	(puckvzadj).l
.20
	jsr	(sfx).l
.21
	movem.l	(sp)+,d0-d7/a0-a3
	rts

shotsets	;IDA: unk_84E16. Offsets (x, z) for the different shot directions (passdir 0 ... 8)
	dc.w	0,$C	;offsets for different directions on the shot: passdir 0 (x, z)
	dc.w	$E,$C	;passdir 1 (94 $10)
	dc.w	$E,6	;passdir 2
	dc.w	$E,0	;passdir 3
	dc.w	0,0	;passdir 4
	dc.w	$FFF2,0	;passdir 5 (94 $FFF0)
	dc.w	$FFF2,6	;passdir 6
	dc.w	$FFF2,$C	;passdir 7
	dc.w	0,6	;passdir 8

shotdiradj	;IDA: sub_84E3A. a3 = shooter. Where to shoot for a computer player or a one timer
	btst	#3,$64(a3)
	bne.w	.0
	btst	#3,$62(a3)
	bne.w	.6
.0
	moveq	#8,d0
	moveq	#5,d1
	movea.w	#(SortCords-SCstruct-M68K_RAM),a0
	btst	#6,$62(a3)
	bne.w	.1
	adda.w	#$300,a0
.1
	adda.w	#$80,a0
	tst.w	$34(a0)
	dbeq	d1,.1
	bne.w	.4
	move.b	$28(a0),d0
	ext.w	d0
	asr.w	#1,d0
	add.w	(a0),d0
	sub.w	(puckx).w,d0
	move.b	$2A(a0),d1
	ext.w	d1
	asr.w	#1,d1
	add.w	$14(a0),d1
	sub.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	addq.l	#1,d0
	jsr	(sroot).l
	move.w	d0,d2
	movem.w	(sp)+,d0-d1
	moveq	#$12,d3
	move.w	#$10B,d4
	btst	#7,$62(a3)
	bne.w	.2
	neg.w	d4
.2
	movem.w	d3-d4,-(sp)
	bsr.w	shotdirmath
	move.w	d4,d5
	movem.w	(sp)+,d3-d4
	neg.w	d3
	bsr.w	shotdirmath
	add.w	d5,d4
	clr.w	d0
	cmp.w	#$2C,d4
	bgt.w	.4
	cmp.w	#$FFD4,d4
	blt.w	.4
	btst	#7,$62(a3)
	beq.w	.3
	neg.w	d4
.3
	moveq	#2,d0
	tst.w	d4
	bpl.w	.4
	moveq	#6,d0
.4
	move.w	d0,(passdir).w
	btst	#2,(BA_PS_flags).w
	bne.w	.5
	btst	#0,(gmode2).w
	beq.w	.6
.5
	jsr	(PSandSOpassdir).l
.6
	rts

shotdirmath	;IDA: sub_84F1A. shotdiradj helper
	sub.w	(puckx).w,d3
	sub.w	(pucky).w,d4
	muls.w	d0,d4
	muls.w	d1,d3
	sub.l	d3,d4
	divs.w	d2,d4
	rts

puckvzadj	;no IDA label (IDA dc.b). onetimer94 puckvzadj (moved in; IDA name). Set puckvz for a top shelf shot from the distance to the goal
	;line ($10B; 94 $108) over puckvy, at most $7FFF. Called from doshot
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(pucky).w,d0	;move pucky into d0
	bpl.w	.dist	;branch if positive
	neg.w	d0	;negate d0
.dist
	subi.w	#$10B,d0	;sub top goal line from d0
	bpl.w	.0	;branch if positive
	neg.w	d0	;negate d0
.0
	swap	d0	;swap d0 words
	andi.l	#$FFFF0000,d0	;pass upper word of d0
	move.w	(puckvy).w,d1	;move puckvy into d1
	beq.w	.x	;branch if zero
	bpl.w	.speed	;branch if positive
	neg.w	d1	;negate d1
.speed
	move.w	#$11,d2	;move 11 into d2
	tst.w	(music_global_tick_counter).w	;PAL
	beq.w	.div
	move.w	#$18,d2	;PAL (94 $16)
.div
	divu.w	d1,d0	;divide d1 into d0
	andi.l	#$FFFF,d0	;pass lower word of d0
	divu.w	d2,d0	;divide d2 into d0
	tst.w	d0	;check d0
	bne.w	.calc	;branch if not zero
	move.w	#1,d0	;move 1 into d0
.calc
	move.l	#$A0000,d1
	move.w	d0,d3	;move d0 into d3
	mulu.w	d2,d0	;mult d2 and d0
	divu.w	d0,d1	;divide d0 into d1
	move.w	d2,d4	;move d2 into d4
	add.w	d2,d2	;double d2
	add.w	d4,d2	;add d4 to d2 (now d2 is d2 x 3)
	mulu.w	d3,d2	;multiply d3 and d2
	cmp.l	#$7FFF,d2	;compare to d2
	blt.w	.addvz	;branch if less than
	move.w	#$7FFF,d2	;move 7FFF into d2
.addvz
	add.w	d2,d1	;add d2 to d1
	tst.w	d1	;test d1
	bpl.w	.setvz	;branch if positive
	move.w	#$7FFF,d1	;move 7FFF into d1
.setvz
	move.w	d1,(puckvz).w	;move d1 into puckvz
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts

compshoot	;no IDA label (IDA dc.b). checks94 compshoot (moved in). Computer player shoots: drop the caller's return, temp2 from the
	;distance to the goal line, then assshoot. Jumped to from asspuckc, chk4shot (checks95_02) and checks95_05
	addq.w	#4,sp
	move.w	(pucky).w,d0
	btst	#7,pflags(a3)
	bne.w	.ds0
	neg.w	d0
.ds0
	move.w	#$10B,d1	;94 $108
	sub.w	d0,d1
	lsr.w	#3,d1
	cmp.w	#$14,d1
	blt.w	.0
	moveq	#$14,d1
.0
	move.w	d1,temp2(a3)
	moveq	#$1A,d0	;assshoot (94 $12)
	jmp	(assreplace).l
