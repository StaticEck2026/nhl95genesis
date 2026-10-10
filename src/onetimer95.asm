;	NHL 95 onetimer95. Retail $082BD0-$082FC1 (1010 bytes).
;	94 onetimer94 assonetimer, setonetimeranim, PuckOnAttackHalf, onetimershot, then title94 EndOneTimer (moved in) and the 95
;	CheckOneTimerFacing. The tail of the old placeholder ($082FC2-$082FF9) is checks94 assshoot: it is split out to checks95_08.
;	94 puckvzadj, OneTimerPass, OneTimerTarget and its tables (onetimer94) are elsewhere in 95.
;	IDA left $082BD0-$082E87 and $082EFE-$082F5F as dc.b; they are code here, read from the retail bytes. IDA code: PuckOnAttackHalf
;	(sub_82E88), EndOneTimer (sub_82F60); CheckOneTimerFacing ($082FB2) is dc.b again.
;	95 changes: each pad takes the one-timer shooter itself (setc1player ... setc4player by inputjoy; 94 swapped pads 3 / 4 into 1 / 2),
;	the 95 SPA values and goal line $10B (the comments give the 94 values), the PAL speed $18 (94 $16), the one-timer count at $35E of
;	the team struct (94 $35C), and CheckOneTimerFacing now calls Findhittype.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

assonetimer	;no IDA label (IDA dc.b), asstab entry $18 (94 $23). 94 IDA name. Player a3 shooting a one-timer: the passer's pad (inputjoy) takes
	;control of him (setc1player ... setc4player), start the animation (setonetimeranim), then shoot when the puck arrives (EndOneTimer)
	bclr	#1,$62(a3)	;pfna - clear new assignment
	beq.w	.checkxpos	;branch if not new assignment
	bset	#3,$64(a3)	;set one timer bit
	bne.w	.checkxpos	;branch if already set
	bclr	#0,(onetimerflags).w
	bclr	#5,(sflags8).w
	clr.w	(onetimerflags).w
	clr.w	(onetimerclock).w
	st	(passplayer).w
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	$52(a3),d0	;move a3 SCnum into d0
	move.w	d0,(onetimerplayer).w	;move d0
	btst	#3,$62(a3)	;check if joystick controlled
	bne.w	.setanim	;branch if so
	tst.w	(inputjoy).w	;check input controller (95: the pad number 0 / 2 / 4 / 6 of the passer)
	bmi.w	.setanim	;branch if minus (no control)
	beq.w	.p1	;pad 1
	cmpi.w	#2,(inputjoy).w
	beq.w	.p2
	cmpi.w	#4,(inputjoy).w
	beq.w	.p3
	jsr	(setc4player).l	;95: each pad takes the shooter itself (94 swapped pads 3 / 4 into 1 / 2)
	bra.w	.setanim
.p1
	jsr	(setc1player).l
	bra.w	.setanim
.p2
	jsr	(setc2player).l
	bra.w	.setanim
.p3
	jsr	(setc3player).l
	bra.w	.setanim	;IDA: *+4
.setanim
	move.w	d0,-(sp)
	bsr.w	setonetimeranim	;sets the one timer animation
	clr.w	$5A(a3)	;clear SPAnum
	jsr	(SetSPA).l
	bset	#5,$62(a3)	;lock animation
	bset	#1,$63(a3)	;set anim in progress
	move.w	(sp)+,d0
	movem.l	(sp)+,d0-d7/a0-a6
	bra.w	.ex
.checkxpos
	btst	#0,(onetimerflags).w	;check if shot initiated
	bne.w	.chkcarrier	;branch if set
	movem.w	d0-d1,-(sp)	;push to stack
	move.w	(puckx).w,d0	;move puckx to d0
	sub.w	(a3),d0	;sub Xpos from d0
	cmp.w	#$3C,d0	;'<'   ; compare diff to 3C (60 pixels)
	bgt.w	.chkxvel	;branch if greater than
	cmp.w	#$FFC4,d0	;compare to -60 pixels
	bgt.w	.chkypos	;branch if greater than
.chkxvel
	move.w	(puckvx).w,d1	;move puckvx into d1
	eor.w	d1,d0	;EOR d1 with d0
	bmi.w	.chkypos	;branch if minus
.notcoming
	movem.w	(sp)+,d0-d1	;pop from stack d0 and d1
	bra.w	.cancel
.chkypos
	move.w	(pucky).w,d0	;move pucky into d0
	sub.w	$14(a3),d0	;sub Ypos from d0
	cmp.w	#$3C,d0	;'<'   ; compare diff to 60 pix
	bgt.w	.chkyvel	;branch if greater than
	cmp.w	#$FFC4,d0	;check with -60 pix
	bgt.w	.coming	;branch if greater than
.chkyvel
	move.w	(puckvy).w,d1	;move puckvy into d0
	eor.w	d1,d0	;EOR d1 with d0
	bpl.s	.notcoming	;branch if positive
.coming
	movem.w	(sp)+,d0-d1	;pop d0 and d1 from stack
.chkcarrier
	tst.w	(puckc).w	;check if puck carrier
	bmi.w	.loose	;branch if no puck carrier
.cancel
	bclr	#7,(sflags8).w	;clear bit 7
	bra.w	.shoot
.loose
	btst	#0,(gmode).w	;check if game clock
	bne.w	.shoot	;branch if clock stopped
	movem.l	d0-d1,-(sp)	;push to stack
	cmpi.w	#$10,$5A(a3)	;compare 10 to SPAnum
	bge.w	.windup	;branch if greater than or equal
	btst	#2,(onetimerflags).w	;check bit 2
	bne.w	.windup	;branch if set
	move.w	(a3),d0	;move Xpos into d0
	move.w	(puckx).w,d1	;move puckx into d1
	sub.w	d1,d0	;sub d1 from d0
	bpl.w	.dy	;branch if positive
	neg.w	d0	;negate d0
.dy
	move.w	$14(a3),d1	;move Ypos into d1
	move.w	(pucky).w,d2	;move pucky into d2
	sub.w	d2,d1	;sub d2 from d1
	bpl.w	.vel	;branch if positive
	neg.w	d1	;negate d1
.vel
	move.w	(puckvx).w,d2	;move puckvx into d2
	beq.w	.usey	;branch if d2 is 0
	cmp.w	d0,d1	;compare d0 to d1
	ble.w	.frames	;branch if less than or equal
.usey
	move.w	(puckvy).w,d2
	move.w	d1,d0
.frames
	swap	d0
	andi.l	#$FFFF0000,d0
	tst.w	d2
	bpl.w	.speed
	neg.w	d2
.speed
	move.w	#$11,d1
	tst.w	(music_global_tick_counter).w
	beq.w	.chkzero
	move.w	#$18,d1	;PAL (94 $16)
.chkzero
	tst.w	d2
	bne.w	.div
	move.w	#1,d2
.div
	divu.w	d2,d0
	andi.l	#$FFFF,d0
	divu.w	d1,d0
	move.w	$5A(a3),d2
	lsr.w	#2,d2
	subq.w	#6,d2
	neg.w	d2
	asl.w	#2,d2
	cmp.w	d2,d0
	bgt.w	.wait
	neg.w	$5A(a3)
	addi.w	#$18,$5A(a3)
	bra.w	.chkanim
.wait
	add.w	d7,(onetimerclock).w
	bra.w	.chkhold
.windup
	bset	#2,(onetimerflags).w
	btst	#1,(onetimerflags).w
	bne.w	.chkhold
	cmpi.w	#$18,$5A(a3)
	bne.w	.chkhold
	addi.w	#$30,$5C(a3)
	bset	#1,(onetimerflags).w
.chkhold
	btst	#1,(onetimerflags).w
	beq.w	.chkshot
	cmpi.w	#$18,$5A(a3)
	ble.w	.chkshot
	btst	#0,(onetimerflags).w
	bne.w	.chkshot
	movem.l	(sp)+,d0-d1
	bra.w	.shoot
.chkshot
	btst	#0,(onetimerflags).w
	beq.w	.chkanim
	cmpi.w	#$18,$5A(a3)
	bne.w	.chkanim
	cmpi.w	#1,$5C(a3)
	ble.w	.chkanim
	move.w	#1,$5C(a3)
.chkanim
	btst	#1,$63(a3)
	bne.w	.animon
	movem.l	(sp)+,d0-d1
	bra.w	.chkdone
.animon
	move.w	$5A(a3),d0
	movem.l	(sp)+,d0-d1
	btst	#0,(onetimerflags).w
	beq.w	.nop
	bclr	#5,$62(a3)
	bra.w	.chkdone
.nop
	nop
.chkdone
	btst	#1,$63(a3)
	bne.w	.ex
.shoot
	jsr	(EndOneTimer).l
.ex
	rts

setonetimeranim	;no IDA label (IDA dc.b). 94 IDA name. The one-timer animation: d1 = $150A or $176E (94 $7FC / $92E) from the angle to the goal
	;(vtoa, CheckOneTimerFacing)
	move.w	#$150A,d1	;95 SPA (94 $7FC)
	movem.w	d0-d1,-(sp)	;push to stack d0 and d1
	move.w	(a3),d0	;move XPos of a3 into d0
	neg.w	d0	;negate d0
	move.w	#$10B,d1	;move top goal line into d1 (94 $108)
	btst	#7,$62(a3)	;check which goal shooting at
	bne.w	.top	;branch if top
	neg.w	d1	;negate d1
.top
	sub.w	$14(a3),d1	;sub Ypos from d1
	jsr	(vtoa).l
	jsr	(CheckOneTimerFacing).l	;95: Z from Findhittype
	movem.w	(sp)+,d0-d1	;pop from stack d0 and d1
	beq.w	.ex
	move.w	#$176E,d1	;95 SPA (94 $92E)
.ex
	rts

PuckOnAttackHalf	;IDA: sub_82E88. 94 name. d0 = 1 when the puck is on the half of the goal player a3 shoots at, else 0 (the code after the bra is
	;never used). Called from doinput (input95) and asspassrec (checks95_02)
	movem.w	d0-d1,-(sp)
	move.w	(pucky).w,d0
	btst	#7,$62(a3)	;pfgoal - check which goal shooting at
	bne.w	.cont	;branch if top goal
	neg.w	d0
.cont
	tst.w	d0	;check if d0 is 0
	bpl.w	.plus	;branch if higher
	bra.w	.0
	move.w	(passdir).w,d0	;code never used from here up to _0
	addq.w	#4,d0
	andi.w	#7,d0
	move.w	$54(a3),d1
	cmp.w	d0,d1
	bra.w	.plus
	beq.w	.plus
	addq.w	#1,d1
	andi.w	#7,d1
	cmp.w	d0,d1
	beq.w	.plus
	addq.w	#1,d1
	andi.w	#7,d1
	cmp.w	d0,d1
	beq.w	.plus
	subq.w	#3,d1
	andi.w	#7,d1
	cmp.w	d0,d1
	beq.w	.plus
	subq.w	#1,d1
	andi.w	#7,d1
	beq.w	.plus
.0
	move.w	#0,d0
	bra.w	.ex
.plus
	move.w	#1,d0
.ex
	movem.w	(sp)+,d0-d1
	rts

onetimershot	;no IDA label (IDA dc.b). 94 IDA name. Do the one-timer shot (doshot), credit the last two passers as the assists, add to crowdlevel /
	;CwdExciteLvl and to the one-timer attempts ($35E of the team struct; 94 $35C). Called from puckstick (collide95_01)
	move.w	#4,(passdir).w
	jsr	(doshot).l
	movem.l	d0/a0,-(sp)
	movea.l	#HmShots,a0	;Home Stats
	btst	#6,$62(a3)	;check if home or away
	beq.w	.home	;branch if home
	lea	tmsize(a0),a0	;add if away
.home
	clr.w	d0
	move.b	$66(a3),d0	;player offset in roster
	move.w	$1A(a0),$1C(a0)	;move assist 1 player to assist 2
	move.w	$18(a0),$1A(a0)	;move last player to touch puck to assist 1
	move.w	d0,$18(a0)	;move d0 into player touching puck
	bset	#7,(sflags8).w	;set bit 7
	addi.w	#$96,(crowdlevel).w	;add to crowdlevel
	addi.w	#$A,(CwdExciteLvl).w	;add to Excite Level
	addq.w	#1,$35E(a0)	;add to one timer attempt (94 $35C)
	movem.l	(sp)+,d0/a0
	bset	#0,(onetimerflags).w	;set bit 0
	bset	#1,$63(a3)	;set animation in progress (95: no sflags6 bit 1)
	rts

EndOneTimer	;IDA: sub_82F60. title94 EndOneTimer (moved in). End a one-timer for a3: bits cleared, onetimerplayer = -1, SetSPA $B5C (94 $50C),
	;then assexit (goalie) or Setplass. Called from assonetimer and from $8C606 (checks95_06)
	movem.l	d0/a0,-(sp)
	bclr	#3,$64(a3)
	bclr	#5,$62(a3)
	bclr	#1,$63(a3)
	clr.w	(onetimerflags).w
	st	(onetimerplayer).w
	move.w	d1,-(sp)
	move.w	#$B5C,d1	;95 SPA (94 $50C)
	jsr	(SetSPA).l
	tst.w	$34(a3)
	bpl.w	.0
	jsr	(assexit).l
	bra.w	.1
.0
	jsr	(Setplass).l
.1
	clr.w	$5A(a3)
	st	$5C(a3)
	move.w	(sp)+,d1
	movem.l	(sp)+,d0/a0
	rts

CheckOneTimerFacing	;no IDA label (IDA dc.b). 94 name. 95: Findhittype (input95_01) on direction d0 (the angle to the goal), d0 kept. The Z flag
	;picks the one-timer animation in setonetimeranim (94 did nothing here)
	movem.w	d0,-(sp)
	jsr	(Findhittype).l
	movem.w	(sp)+,d0
	rts
