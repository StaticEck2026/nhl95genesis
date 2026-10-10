;	NHL 95 input95_03. Retail $08B734-$08B9A7 (628 bytes).
;	94 input94 doinput_cbut, ClampTargetY (with the 10 SPA offsets after it), doinput_chkanim and getGoalieSCnum (95 FindGoalie). The
;	row map started this file at $8B748, inside doinput_cbut; it starts at doinput_cbut ($8B734). doinput_onetimer / doinput_ispc are
;	not in 95 here; doinput_islocked is in input95_01. checks95_06 follows at $08B9A8.
;	IDA code; local labels are numbered, the IDA local names are not kept.
;	95 changes: the y limits $106 / $FEFA, the goalie box in doinput_chkanim, the 95 SPA values.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


doinput_cbut	;IDA: loc_8B734. (input94) Global: doinput branches here across the global rtss15. Button C (bit 5): new press: face the puck
	;(vtoa) and go on below; held: hold the SPA frame (SPAcnt $A) at the end of a frame list (SPAlist)
	btst	#5,d1
	bne.w	.2
	btst	#5,d3
	bne.w	.0
	bra.w	doinput_chkanim
.0
	movem.l	d0-d3/a0-a3,-(sp)
	movea.l	#SPAlist,a0
	adda.w	SPA(a3),a0
	move.w	facedir(a3),d0
	btst	#3,attribute(a3)
	beq.w	.1
	neg.w	d0
	addq.w	#8,d0
	andi.w	#7,d0
.1
	asl.w	#1,d0
	adda.w	(a0,d0.w),a0
	tst.b	SPAnum+1(a3)
	movem.l	(sp)+,d0-d3/a0-a3
	bpl.s	rtss15
	move.w	#$A,SPAcnt(a3)
	rts
.2
	btst	#5,pflags(a3)
	bne.w	doinput_chkanim
	movem.w	d0-d1,-(sp)
	move.w	(puckx).w,d0
	sub.w	(a3),d0
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	jsr	(vtoa).l
	move.w	d0,facedir(a3)
	movem.w	(sp)+,d0-d1
	move.w	(TempWord1).w,d0
	bclr	#0,(BA_PS_flags).w
	move.w	(gameclock).w,d0
	andi.w	#7,d0
	asl.w	#4,d0
	addi.w	#$A0,d0
	cmpi.w	#$DE,(pucky).w
	bgt.w	.3
	cmpi.w	#$FF22,(pucky).w
	bgt.w	.4
.3
	subi.w	#$40,d0
.4
	move.w	d0,d1
	muls.w	(puckvx).w,d0
	swap	d0
	add.w	(puckx).w,d0
	muls.w	(puckvy).w,d1
	swap	d1
	add.w	(pucky).w,d1
	bsr.w	ClampTargetY
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	cmp.l	#$384,d0
	bhi.w	.5
	movem.w	(sp)+,d0-d1
	bra.w	.7
.5
	jsr	(sroot).l
	moveq	#1,d2
	add.w	d0,d2
	moveq	#$12,d4
	btst	#3,(sflags).w
	beq.w	.6
	addq.w	#8,d4
.6
	movem.w	(sp)+,d0-d1
	muls.w	d4,d1
	addq.w	#8,d4
	muls.w	d4,d0
	divs.w	d2,d0
	divs.w	d2,d1
.7
	add.w	d3,d1
	move.w	d1,d2
	cmpi.w	#$22,2(a0)
	cmpi.w	#$18,(a0)
	cmpi.w	#$FFE8,(a0)
	cmpi.w	#$C,2(a0)
	cmpi.w	#$10B,(pucky).w
	cmpi.w	#$FEF5,(pucky).w
	bset	#1,pflags2(a3)
	bne.w	doinput_chkanim
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#puckcross,a0
	move.w	#$10B,d3
	btst	#7,pflags(a3)
	beq.w	.8
	neg.w	d3
	addq.w	#4,a0
.8
	jsr	(goaliesave).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClampTargetY	;IDA: sub_8B890. (input94) Clamp target y d1 to $106 / $FEFA (94 $103 / $FEFD), then d1 - d3; d0 = 0 for the puck carrier.
	;10 SPA offsets follow
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
	;10 SPA offsets, no reference in the listing (94 the same table): SPAgglover, SPAgglovel, SPAgstackr, SPAgstackl, SPAgstickr,
	;SPAgstickl, then SPAgglover, SPAgglovel, SPAgstickr, SPAgstickl where 94 has SPAghighr, SPAghighl, SPAgstick2r, SPAgstick2l
	dc.w	$1C86,$1CB8,$205E,$200C,$1CEA,$1D1C,$1C86,$1CB8,$1CEA,$1D1C

doinput_chkanim	;IDA: loc_8B8CE. (input94) Global: doinput branches here across ClampTargetY. Animation in progress (pflags2 bit 1): rts. A
	;goalie (position 0) is held inside x $24 / y $E7 of his net (BA_PS_flags bit 1), then playeracc with TempWord1
	btst	#1,pflags2(a3)
	beq.w	.0
	rts
.0
	tst.w	position(a3)
	bne.w	doplayeracc
	bclr	#1,(BA_PS_flags).w
	cmpi.w	#$24,(a3)
	ble.w	.1
	tst.w	Xvel(a3)
	bmi.w	.1
	beq.w	.1
	bset	#1,(BA_PS_flags).w
	clr.w	Xvel(a3)
.1
	cmpi.w	#$FFDC,(a3)
	bge.w	.2
	tst.w	Xvel(a3)
	bpl.w	.2
	bset	#1,(BA_PS_flags).w
	clr.w	Xvel(a3)
.2
	cmpi.w	#$E7,Ypos(a3)
	bgt.w	.4
	cmpi.w	#$FF19,Ypos(a3)
	ble.w	.4
	bra.w	*+4	;to the next instruction
.3
	movem.w	d0-d1,-(sp)
	move.w	Ypos(a3),d0
	move.w	Yvel(a3),d1
	eor.w	d1,d0
	movem.w	(sp)+,d0-d1
	bpl.w	.4
	tst.w	Yvel(a3)
	beq.w	.4
	bset	#1,(BA_PS_flags).w
	clr.w	Yvel(a3)
.4
	btst	#1,(BA_PS_flags).w
	bne.w	rtss15
	move.w	(TempWord1).w,d0
	jmp	doplayeracc

FindGoalie	;IDA: sub_8B974. (input94 getGoalieSCnum) 95: d0 = SCnum of the goalie of the team of player d0 (the first position 0 going down
	;from player d0), -1 none
	movem.l	d1/a0,-(sp)
	movea.l	#SortCords,a0
	asl.w	#7,d0
	adda.w	d0,a0
	move.w	#5,d1
.0
	tst.w	position(a0)
	beq.w	.1
	suba.w	#SCstruct,a0
	dbf	d1,.0
	move.w	#$FFFF,d0
	bra.w	.2
.1
	move.w	SCnum(a0),d0
.2
	movem.l	(sp)+,d1/a0
	rts

