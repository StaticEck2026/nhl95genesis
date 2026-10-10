;	NHL 95 assign95_01. Retail $0807EC-$080BE9 (1022 bytes).
;	94 assign94 assdefd, rtss21 and asswingd (the defense assignments of the defensemen and the wingers). checks95_02 (94 asswingo) follows
;	at $080BEA.
;	IDA left the whole range as dc.b (unk_80742 runs to $081335); it is code here, read from the retail bytes.
;	95 changes: assdefd also checks for a puck carrier of the other team before the timer (assdefo, now asstab $C), halves aidef for the
;	timer, and with the team defense mode (HmDefMode / AwDefMode) at 1 leaves for assdefdchase when the other team has the puck; asswingd
;	then covers the carrier with its own 95 code (.cover). Some y limits move by 2 or 3 ($58 to $56, $9E to $9C, $108 to $10B ...); the
;	comments give the 94 values.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

; player a3 is defensive player on defense
assdefd	;no IDA label (IDA dc.b), asstab entry 7
	btst	#5,pflags(a3)	;check if locked in animiation
	bne.w	rtss21	;exit if so (94 rtss6)
	btst	#0,(gmode).w	;check if clock running
	bne.w	assnothing	;assnothing if no clock
	bsr.w	check4bench	;check if going to bench
	btst	#3,pflags(a3)	;check if joystick controlled
	bne.w	rtss21	;exit if so
	bclr	#1,pflags(a3)	;clear new assignment bit
	beq.w	.nna	;branch if no new assignment
	clr.w	temp1(a3)	;clear temp1
	move.w	#8,temp2(a3)	;move 8 into temp2
.nna
	move.w	(puckc).w,d1	;95: the other team's carrier check, every frame
	bmi.w	.t
	bsr.w	chkpk	;check if theres a PK
	beq.w	.t	;branch if on PK
	moveq	#$C,d0	;assdefo into d0 (94 1)
	subq.w	#6,d1	;sub 6 from d1
	move.w	SCnum(a3),d2	;move SCnum into d2
	subq.w	#6,d2	;sub 6 from d2
	eor.w	d2,d1	;EOR d2 and d1
	bpl.w	assreplace	;assreplace if puckc on same team
.t
	sub.b	d7,temp1(a3)	;sub frames elapsed from temp1
	bpl.w	.nodec	;branch if not 0
	clr.w	d1
	move.b	aidef(a3),d1	;DfA / 2 into temp1 (94 DfA)
	asr.w	#1,d1
	move.b	d1,temp1(a3)
	btst	#6,(sflags7).w	;check if crowd meter currently broken
	beq.w	.noboost	;branch if not
	tst.b	$40(a3)	;check if temp1 is 0
	beq.w	.noboost	;branch if so
	subq.b	#1,$40(a3)	;sub 1 from temp1
.noboost
	move.w	(pucky).w,d1	;move pucky into d1
	move.w	(puckvy).w,d3	;move puckvy into d3
	asr.w	#6,d3	;divide by 64
	btst	#7,pflags(a3)	;check which net shooting on
	bne.w	.de00	;branch if top
	neg.w	d1	;negate d1 and d3 if bottom
	neg.w	d3
.de00
	tst.w	d3	;check if d3 is zero
	bpl.w	.de000	;branch if positive
	clr.w	d3	;clear d3
.de000
	add.w	d1,d3	;add d1 to d3
	cmp.w	#$56,d3	;compare top blueline to d3 (94 $58)
	blt.w	.de0
	btst	#4,tmflags(a2)	;check if team is offsides
	bne.w	.de0	;branch if offsides
	move.w	(puckc).w,d1	;move puckc into d1
	bmi.w	.de0	;branch if no puckc
	bsr.w	chkpk	;check if theres a PK
	beq.w	.de0	;branch if on PK
	moveq	#$C,d0	;assdefo into d0 (94 1)
	subq.w	#6,d1	;sub 6 from d1
	move.w	SCnum(a3),d2	;move SCnum into d2
	subq.w	#6,d2	;sub 6 from d2
	eor.w	d2,d1	;EOR d2 and d1
	bpl.w	assreplace	;assreplace if puckc on same team
.de0
	move.w	(puckc).w,d1	;95: the other team has the puck and the team defense mode is 1: assdefdchase
	bmi.w	assdefdchase
	move.w	SCnum(a3),d2
	subq.w	#6,d1
	subq.w	#6,d2
	eor.w	d1,d2
	bpl.w	.de01	;branch if puckc on same team
	move.w	(HmDefMode).w,d0
	cmpa.l	#HmShots,a2
	beq.w	.de02
	move.w	(AwDefMode).w,d0
.de02
	cmp.w	#1,d0
	beq.w	assdefdchase
.de01
	bclr	#7,$64(a3)	;95: assdefdchase sets it
	move.w	#$41,temp3(a3)	;'A' ; move 65 dec into temp3
	cmpi.w	#2,position(a3)	;compare if player is RD
	beq.w	.de1	;branch if RD
	neg.w	temp3(a3)	;negate temp3 if LD
.de1
	movea.w	#(SortCords-M68K_RAM),a0	;move SC struct start into a0
	cmpi.w	#6,SCnum(a3)	;compare 6 with player SCnum
	bge.w	.de2	;branch if away team
	adda.w	#6*SCstruct,a0	;add 300 to a0 (start at away SC Struct)
.de2
	moveq	#5,d2	;move 5 into d2
	move.w	#$FC18,d0	;move -1000 dec into d0
	btst	#7,pflags(a3)	;check what net shooting at
	beq.w	.gdwn	;branch if bottom net
	neg.w	d0	;negate d0
.gup
	btst	#2,pflags2(a0)	;check if a0 player unavailable
	bne.w	.gu0	;branch if so
	tst.w	position(a0)	;check a0 position
	bmi.w	.gu0	;branch if empty position
	move.w	Yvel(a0),d1	;move Yvel of a0 into d1
	bmi.w	.gu2	;branch if Yvel was negative
	clr.w	d1	;clear d1
.gu2
	asr.w	#4,d1	;divide d1 by 16
	add.w	Ypos(a0),d1	;add Ypos of a0 player to d1
	cmp.w	d0,d1	;compare d0 to d1
	bgt.w	.gu0	;branch if d1 is greater
	move.w	d1,d0	;move d1 into d0
.gu0
	adda.w	#SCstruct,a0	;add 80 (offset to next player struct) to a0
	dbf	d2,.gup	;loop
	subi.w	#$32,d0	;'2'   ; sub $32 (50 dec) from d0
	cmp.w	#$FF42,d0	;compare to $FF42 (-190 dec)
	bgt.w	.gu1	;branch if greater than
	move.w	#$FF24,d0	;move -220 dec into d0
.gu1
	move.w	d0,temp4(a3)	;move d0 into temp4
	move.w	(puckx).w,d0	;move puckx into d0
	move.w	temp3(a3),d1	;move temp3 into d1
	eor.w	d0,d1	;EOR d0 and d1
	bpl.w	.nodec	;branch if puck on same side
	clr.w	temp3(a3)	;clear temp3 if not
	bra.w	.nodec
.gdwn
	btst	#2,pflags2(a0)	;check if player a0 unavail
	bne.w	.gd0	;branch if so
	tst.w	position(a0)	;check a0 position
	bmi.w	.gd0	;branch if empty (goalie)
	move.w	Yvel(a0),d1	;move Yvel of a0 into d1
	bpl.w	.gd2	;branch if positive
	clr.w	d1	;clear d1
.gd2
	asr.w	#4,d1	;divide d1 by 16
	add.w	Ypos(a0),d1	;add Ypos of a0 to d1
	cmp.w	d0,d1	;compare d0 to d1
	blt.w	.gd0	;branch if less than d0
	move.w	d1,d0	;move d1 into d0
.gd0
	adda.w	#SCstruct,a0	;add offset to next player struct
	dbf	d2,.gdwn	;loop
	addi.w	#$32,d0	;'2'   ; add 32 to d0
	cmp.w	#$BE,d0	;compare 190 dec to d0
	blt.w	.gd1	;branch if d0 less than
	move.w	#$DC,d0	;move 220 dec into d0
.gd1
	move.w	d0,temp4(a3)	;move d0 into temp4
	neg.w	temp3(a3)	;negate temp3
	move.w	(puckx).w,d0	;move puckx into d0
	move.w	temp3(a3),d1	;move temp3 into d1
	eor.w	d0,d1	;EOR d0 and d1
	bpl.w	.nodec	;branch if puck on same side
	clr.w	temp3(a3)	;clear temp3 if not
.nodec
	move.w	temp3(a3),d0	;move temp3 to d0
	move.w	temp4(a3),d1	;move temp4 to d1
	movea.l	#EvadePC,a0	;EvadePC to a0
	bsr.w	skateto
	bra.w	check4check
rtss21	;no IDA label. Shared rts of assdefd and asswingd
	rts

; player a3 is winger on defense
asswingd	;no IDA label (IDA dc.b), asstab entry 8
	btst	#5,$62(a3)	;check if locked in animation
	bne.s	rtss21	;exit if so
	btst	#0,(gmode).w	;check if clock is running
	bne.w	assnothing	;assnothing if its stopped
	bsr.w	check4bench	;check if going to bench
	btst	#3,pflags(a3)	;check if joystick controlled
	bne.s	rtss21	;exit if so
	bclr	#1,pflags(a3)	;clear new assignment bit
	beq.w	.nna	;branch if cleared already (no new assignment)
	clr.w	temp1(a3)	;clear temp1
	move.w	#8,temp2(a3)	;move 8 into temp2
.nna
	sub.b	d7,temp1(a3)	;sub frames elapsed from temp1
	bpl.w	.nodec	;branch if not 0
	move.b	aidef(a3),temp1(a3)	;move DfA into temp1
	btst	#6,(sflags7).w	;check if crowd meter currently broken
	beq.w	.noboost	;branch if not
	tst.b	$40(a3)	;check if temp1 is 0
	beq.w	.noboost	;branch if 0
	subq.b	#1,$40(a3)	;sub 1 from temp1
.noboost
	move.w	(puckc).w,d1	;move puckc into d1
	bmi.w	.nodec	;branch if no puck carrier
	moveq	#9,d0	;asswingo into d0 (94 4)
	subq.w	#6,d1	;sub 6 from d1
	move.w	SCnum(a3),d2	;move SCnum into d2
	subq.w	#6,d2	;sub 6 from d2
	eor.w	d2,d1	;EOR d2 with d1. Checks if player on same team
	bpl.w	assreplace	;branch if team has puck
.nodec
	tst.w	(puckc).w	;95: with a carrier and the team defense mode at 1: .cover
	bmi.w	.2
	move.w	(HmDefMode).w,d0
	cmpa.l	#HmShots,a2
	beq.w	.3
	move.w	(AwDefMode).w,d0
.3
	cmp.w	#1,d0
	beq.w	.cover
.2
	moveq	#$64,d0	;'d'   ; move 64 (100 dec) into d0
	cmpi.w	#5,position(a3)	;check if player is RW
	bne.w	.1	;branch if not
	neg.w	d0	;make d0 negative
.1
	move.l	#$9C,d1	;move $9C into d1 (94 $9E)
	btst	#7,pflags(a3)	;check which goal shooting at
	beq.w	.0	;branch if bottom goal
	neg.w	d0	;negate d0
	neg.w	d1	;negate d1
	moveq	#-$4C,d2	;slightly above bottom blue line (94 -$4E)
	btst	#4,tmflags(a2)	;check bit 4 of offset 30 (currently offside)
	bne.w	.dg11	;branch if set
	cmp.w	(pucky).w,d2	;compare pucky to d2
	bgt.w	.ug1	;branch if puck in defensive zone
	move.w	(pucky).w,d1	;move pucky into d1
	bra.w	.z1
.ug1
	move.w	#$FEF5,d2	;move bottom goal line into d2 (94 $FEF8)
	cmp.w	(pucky).w,d2	;compare pucky to d2
	blt.w	.z1	;branch if puck in defensive zone
	move.w	d2,d1	;move d2 into d1 if puck behind goal line
	bra.w	.z1
.0
	moveq	#$4C,d2	;slightly below top blue line (94 $4E)
	btst	#4,tmflags(a2)	;check bit 4 of offset 30
	bne.w	.dg11	;branch if set
	cmp.w	(pucky).w,d2	;compare pucky to d2
	blt.w	.dg1	;branch if puck in defensive zone
	move.w	(pucky).w,d1	;move pucky into d1
	bra.w	.z1
.dg1
	move.w	#$10B,d2	;move top goal line into d2 (94 $108)
	cmp.w	(pucky).w,d2	;compare pucky to d2
	bgt.w	.z1	;branch if puck in between goal line and blue line
.dg11
	move.w	d2,d1	;move d2 into d1 if puck behind goal line
.z1
	lea	rtss21(pc),a0
	move.w	(puckx).w,d2	;move puckx into d2
	eor.w	d0,d2	;EOR d0 and d2
	bmi.w	skateto	;branch if minus - skate to d0/d1, no extra routine
	move.w	(puckx).w,d0	;move puckx into d0
	bra.w	skateto	;skate to d0/d1 no extra routine
.cover	;95 only. The right wing takes the carrier when the puck is on his side (x past $16 / -$16), else holds near the far post side
	;($64, -$B2 / -$64, $B2); the left wing the same mirrored. Checks (check4check) when the target is not puckx
	cmpi.w	#5,position(a3)	;check if player is RW
	bne.w	.lw
	btst	#7,pflags(a3)	;check which goal shooting at
	beq.w	.rwdn
	move.w	(puckx).w,d1
	cmp.w	#$16,d1
	bgt.w	.carrier
	move.w	#$FF4E,d1
	move.w	#$64,d0
	bra.w	.go
.carrier	;skate at the carrier: puckx, and pucky (or $64 toward his goal from it when the carrier is the goalie)
	move.w	(puckc).w,d0
	asl.w	#7,d0
	movea.l	#SortCords,a0
	adda.w	d0,a0
	tst.w	position(a0)
	bne.w	.c2	;branch if not the goalie
	move.w	(pucky).w,d1
	tst.w	d1
	bmi.w	.c1
	subi.w	#$64,d1
	bra.w	.c3
.c1
	addi.w	#$64,d1
	bra.w	.c3
.c2
	move.w	(pucky).w,d1
.c3
	move.w	(puckx).w,d0
	bra.w	.go
.rwdn
	move.w	(puckx).w,d1
	cmp.w	#$FFEA,d1
	blt.s	.carrier
	move.w	#$B2,d1
	move.w	#$FF9C,d0
	bra.w	.go
.go
	lea	rtss21(pc),a0
	move.w	d0,-(sp)
	bsr.w	skateto
	move.w	(sp)+,d0
	cmp.w	(puckx).w,d0
	beq.w	.x	;no check when skating at the carrier
	bsr.w	check4check
.x
	rts
.lw
	btst	#7,pflags(a3)	;check which goal shooting at
	beq.w	.lwdn
	move.w	(puckx).w,d1
	cmp.w	#$FFEA,d1
	blt.s	.carrier
	move.w	#$FF6E,d1
	move.w	#$FF9C,d0
	bra.s	.go
.lwdn
	move.w	(puckx).w,d1
	cmp.w	#$16,d1
	bgt.w	.carrier
	move.w	#$92,d1
	move.w	#$64,d0
	bra.s	.go
