;	NHL 95 assign95_02. Retail $08282E-$082BCF (930 bytes).
;	94 assign94 assbench and rtss4, asspenalty, assdopen, assepen (94 asseben, between rtss4 and asspenalty, is in checks95_03 in 95).
;	onetimer95 (94 assonetimer) follows at $082BD0.
;	IDA left the whole range as dc.b (it runs from $81A5E to sub_82E88); it is code here, read from the retail bytes.
;	95 changes: the 95 asstab numbers (assdopen $17; 94 $D), the 95 SPA values (the comments give the 94 ones), the bench and box
;	x $98 / $96 (94 $88 / $86), the goalie bench ready animation from GoalieReadySPA, jsr / jmp .l to the routines 95 moved out of
;	range, the shared rtsskate (checks95_02) in place of rtss3 / rtss4 / rtss2, asspenalty .clrplayer for pads 3 and 4, and the
;	attribute byte kept over the penalty box (penboxattr).
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

assbench	;no IDA label (IDA dc.b), asstab entry $12. Player a3 goes to the bench: skate to the bench door, hop over (SPA), then setplayer the new player
	btst	#pfalock,pflags(a3)
	bne.w	rtsskate	;94 rtss3
	cmpi.w	#$64,temp1(a3)
	beq.w	.done
	bsr.w	check4bench
	btst	#4,pflags2(a3)
	bne.w	assexit
	bclr	#pfna,pflags(a3)
	beq.w	.nna
	move.w	#8,temp2(a3)
	moveq	#$50,d0
	btst	#pfteam,pflags(a3)
	bne.w	.0
	neg.w	d0
.0
	move.w	d0,temp4(a3)
	move.w	#$98,temp3(a3)	;sideline (94 $88)
	neg.w	temp3(a3)
	subq.w	#8,temp3(a3)
	clr.w	temp1(a3)
.nna
	move.b	newpnum(a3),d0
	cmp.b	pnum(a3),d0
	beq.w	.nobench
	sub.w	d7,temp1(a3)
	bpl.w	.nodec
	addq.w	#8,temp1(a3)
	move.w	Ypos(a3),d0
	sub.w	temp4(a3),d0
	cmp.w	#$28,d0
	bgt.w	.nodec
	cmp.w	#$FFD8,d0
	blt.w	.nodec
	move.w	(a3),d0
	sub.w	temp3(a3),d0
	cmp.w	#$20,d0
	bgt.w	.nodec
	move.w	#$B5C,d1	;95 SPA (94 $50C)
	tst.w	position(a3)
	bne.w	.gli
	jsr	(GoalieReadySPA).l	;95 (94: 2, SPAgready)
.gli
	jsr	(SetSPA).l
	bset	#pfnc,pflags(a3)
	cmpi.w	#4,facedir(a3)
	beq.w	.ok
	addq.w	#1,facedir(a3)
	andi.w	#7,facedir(a3)
.ok
	clr.w	Yvel(a3)
	move.w	#$F800,Xvel(a3)
	cmp.w	#$10,d0
	bgt.w	.x
	clr.w	Xvel(a3)
	cmpi.w	#4,facedir(a3)
	bne.w	.x
	move.w	#$F800,Xvel(a3)
	move.w	#2,facedir(a3)
	move.w	#$1E2A,d1	;95 SPA (94 $FAC)
	jsr	(SetSPA).l
	bset	#pfalock,pflags(a3)
	move.w	#$64,temp1(a3)
.x
	rts
.done
	clr.w	frame(a3)
	clr.w	d0
	move.b	pnum(a3),d0
	add.w	d0,d0
	movea.l	#HmShots,a0
	btst	#6,pflags(a3)
	beq.w	.t0
	adda.w	#tmsize,a0
.t0
	move.w	#$FFFE,tmpdst(a0,d0.w)
	move.b	newpnum(a3),d3
	bsr.w	.nobench2
	jmp	(setplayer).l
.nodec
	btst	#pfnc,pflags(a3)
	bne.s	.x
	move.w	temp3(a3),d0
	move.w	temp4(a3),d1
	movea.l	#EvadePC,a0
	bra.w	skateto
.nobench
	bclr	#2,pflags2(a3)
.nobench2
	move.b	newpos(a3),d0
	ext.w	d0
	move.w	d0,position(a3)
	jsr	(Setplass).l
	st	$61(a3)
	st	$60(a3)
rtss4	;no IDA label. The end of assbench (94 rtss4; 95 branches go to rtsskate)
	rts

asspenalty	;no IDA label (IDA dc.b), asstab entry $15. Player a3 goes to the penalty box and hops in, then assdopen
	btst	#5,$62(a3)
	bne.w	rtsskate	;94 rtss4
	bclr	#1,pflags(a3)
	beq.w	.nna
	bset	#2,pflags2(a3)	;set player unavailable (pf2unav)
	bsr.w	.clrplayer
	moveq	#-2,d4	;move -2 into d4
	jsr	(setpads).l	;moves player number into a temp value so graphics know who it is
	move.w	#8,temp2(a3)	;move 8 into temp2
	moveq	#$B,d0	;move 11 dec into d0
	move.b	(PBnum).w,d1	;gets number of players in PB. 00HV (H=Home, V=Visitors)
	btst	#6,pflags(a3)	;checks if player is home or away
	bne.w	.0	;branch if away
	lsr.w	#4,d1	;shift 4 bits to get Home players in PB
	neg.w	d0	;make d0 negative (different box)
.0
	andi.w	#$F,d1	;pass the first 4 bits of d1 (the team's player total in PB)
	cmp.w	#2,d1	;compare to 2
	bls.w	.1	;branch if less than (1 player in box or less)
	moveq	#2,d1	;add 2 if more than 1 player in box
.1
	addq.w	#3,d1	;add 3 to d1
	muls.w	d0,d1	;mult d0 with d1, store result in d1
	move.w	d1,temp4(a3)	;move d1 into temp4 (skateto YPos)
	move.w	#$98,temp3(a3)	;sideline: skateto XPos (94 $88)
	clr.w	temp1(a3)	;clear temp1
	bset	#5,pflags2(a3)	;set bit for no player collision
	clr.w	Wallcos(a3)	;clear wallCos (angle of last collision)
	clr.w	Wallsin(a3)	;clear wallSin (angle of last collision)
.nna
	move.w	Ypos(a3),d0	;Current Ypos of player
	sub.w	temp4(a3),d0	;sub temp4 (Y pos to skate to) from Ypos
	cmp.w	#$C,d0	;compare to 13 decimal
	bgt.w	.st	;branch if greater than (still skateto)
	;If its within 13 decimal, it will start the animation for hopping over the board
	cmp.w	#$FFF4,d0
	blt.w	.st
	move.w	(a3),d0
	sub.w	temp3(a3),d0
	cmp.w	#$FFE8,d0
	blt.w	.st
	sub.w	d7,temp1(a3)
	bpl.w	rtsskate
	addq.w	#8,temp1(a3)
	bset	#pfnc,pflags(a3)
	move.w	#$B5C,d1	;95 SPA (94 $50C)
	jsr	(SetSPA).l
	moveq	#6,d2
	tst.b	handed(a3)
	beq.w	.left
	moveq	#2,d2
.left
	cmp.w	facedir(a3),d2
	beq.w	.ok
	addq.w	#1,facedir(a3)
	andi.w	#7,facedir(a3)
.ok
	clr.w	Yvel(a3)
	move.w	#$1000,Xvel(a3)
	cmp.w	#$FFF8,d0
	blt.w	rtsskate
	clr.w	Xvel(a3)
	cmp.w	facedir(a3),d2
	bne.w	rtsskate
	bset	#5,pflags(a3)
	move.w	#2,facedir(a3)
	move.b	attribute(a3),(penboxattr).w	;95: keep the attribute, without bit 3, for assdopen
	bclr	#3,attribute(a3)
	move.w	#$1DE0,d1	;95 SPA (94 $F6E)
	jsr	(SetSPA).l
	bclr	#4,pflags2(a3)
	moveq	#$17,d0	;assdopen (94 $D)
	bra.w	assreplace
.st
	move.w	temp3(a3),d0
	move.w	temp4(a3),d1
	movea.l	#rtsskate,a0	;94 rtss2
	bra.w	skateto
.clrplayer	;take the joystick off player a3 (92 asspenalty .clrplayer, 93 global clrplayer)
	btst	#3,$62(a3)
	beq.w	rtsskate
	clr.w	d4
	move.w	$52(a3),d0
	cmp.w	(c1playernum).w,d0
	beq.w	.chg
	moveq	#2,d4
	cmp.w	(c2playernum).w,d0	;95: pads 3 and 4 too
	beq.w	.chg
	move.w	#4,d4
	cmp.w	(c3playernum).w,d0
	beq.w	.chg
	move.w	#6,d4
.chg
	jmp	(chgplayer).l	;94 changeplayer

assdopen	;no IDA label (IDA dc.b), asstab entry $17. Add player a3 to the penalty box (PBnum)
	btst	#5,pflags(a3)
	bne.w	rtsskate	;94 rtss4
	tst.w	position(a3)	;95: only once, and give the attribute back
	bmi.w	rtsskate
	move.b	(penboxattr).w,attribute(a3)
	moveq	#$10,d0
	btst	#6,pflags(a3)
	beq.w	.1
	moveq	#1,d0
.1
	add.b	d0,(PBnum).w
	st	position(a3)
	clr.w	frame(a3)
	rts

assepen	;no IDA label (IDA dc.b), asstab entry $16. Player a3 leaves the penalty box
	btst	#5,pflags(a3)
	bne.w	rtsskate	;94 rtss4
	bclr	#1,pflags(a3)
	beq.w	.nna
	bset	#pfnc,pflags(a3)	;set player in no collision mode
	bset	#2,pflags2(a3)	;set player unavailable
	moveq	#$10,d0
	moveq	#$FFFFFFC4,d1
	btst	#6,pflags(a3)
	beq.w	.0
	moveq	#1,d0
	neg.w	d1
.0
	sub.b	d0,(PBnum).w
	move.w	d1,Ypos(a3)
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	move.w	#$96,(a3)	;94 $86
	move.w	#2,facedir(a3)
	bset	#5,pflags(a3)
	move.w	#$1E2A,d1	;95 SPA (94 $FAC)
	jsr	(SetSPA).l
	jmp	(SprSort).l
.nna
	move.w	#4,facedir(a3)
	st	newpnum(a3)
	st	newpos(a3)
	bclr	#pfjoycon,pflags(a3)
	bclr	#pfnc,pflags(a3)
	bclr	#5,pflags2(a3)
	bclr	#2,pflags2(a3)
	move.w	#$F000,Xvel(a3)
	bra.w	assexit
