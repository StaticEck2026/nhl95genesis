;	NHL 95 data95_02. Retail $08996E-$08A055 (1768 bytes).
;	Mapped to data94, but only the tables are data94 (PenaltyNames = 94 PenaltyList, PenShotPenalties, linelist); the code is moved in:
;	collide94 checkagr, display94 showref, penalty94 ClearPenaltyBuffer, title94 ClearPenalties / clrTmPdst, checks94 puckIChk,
;	ChkOffsides and checkob. Each routine comment names its 94 file. input95_02 follows at $08A056.
;	IDA code except puckIChk and ChkOffsides (dc.b, read from the retail bytes with the 94 source as the guide). Local labels are numbered;
;	the IDA local names are not kept.
;	95 changes: the goal line $10B (94 $108), the blue line $52 (94 $54), checkagr's base $32 and the sflags9 penalty options.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


checkagr	;IDA: sub_8996E (collide94) Aggression check: d0 = randomd0((($32 - Agr) / 2) * 13) (94 $28), doubled for a pad player, halved within
	;$28 of the puck; a2 on a breakaway ($64 bit 1) rolls again (8 / 7 / 4 / 3 by his distance from the goal line). 95: d0 = $7F (no
	;penalty) when sflags9 bit 2 (home checker) / bit 1 (away) is set. The callers call a penalty when d0 is small
	move.w	#$32,d0
	sub.b	$73(a3),d0
	lsr.b	#1,d0
	mulu.w	#$D,d0
	btst	#3,pflags(a3)
	beq.w	.0
	asl.w	#1,d0
.0
	move.w	(a3),d1
	sub.w	(puckx).w,d1
	cmp.w	#$28,d1
	bgt.w	.1
	cmp.w	#$FFD8,d1
	blt.w	.1
	move.w	Ypos(a3),d1
	sub.w	(pucky).w,d1
	cmp.w	#$28,d1
	bgt.w	.1
	cmp.w	#$FFD8,d1
	blt.w	.1
	asr.w	#1,d0
.1
	jsr	(randomd0).l
	btst	#1,$64(a2)
	beq.w	.4
	move.w	$14(a2),d1
	bpl.w	.2
	neg.w	d1
.2
	subi.w	#$10B,d1
	neg.w	d1
	move.w	#8,d0
	cmp.w	#$78,d1
	bgt.w	.3
	move.w	#7,d0
	cmp.w	#$3C,d1
	bgt.w	.3
	move.w	#4,d0
	cmp.w	#$2D,d1
	bgt.w	.3
	move.w	#3,d0
.3
	jsr	(randomd0).l
.4
	btst	#6,pflags(a3)
	bne.w	.5
	btst	#2,(sflags9).w
	bne.w	.6
	bra.w	.7
.5
	btst	#1,(sflags9).w
	beq.w	.7
.6
	move.w	#$7F,d0
.7
	rts

showref	;IDA: sub_89A2E (display94) Ref window: when sflags2 bit 1 is set add the 8 RefRamMap rows to the dma list at a5 (VmMap1)
	bclr	#1,(sflags2).w
	beq.w	rtspen
	movea.w	#(RefRamMap-M68K_RAM),a0
	movea.w	#(VmMap1-M68K_RAM),a1
	move.w	2(a1),d2
	moveq	#2,d0
	btst	#7,(sflags).w
	beq.w	*+4
.0
	asl.w	d2,d0
	moveq	#2,d1
	asl.w	d2,d1
	addq.w	#2,d0
	btst	#7,(sflags).w
	beq.w	*+4
.1
	asl.w	#1,d0
	add.w	(a1),d0
	moveq	#7,d2
.2
	move.l	a0,(a5)+
	move.w	#7,(a5)+
	move.w	d0,(a5)+
	adda.w	#$E,a0
	add.w	d1,d0
	dbf	d2,.2
	rts

ClearPenaltyBuffer	;IDA: sub_89A7C (penalty94) IDA: clrPenBuf (94). Clear PenBuf
	moveq	#$1F,d0
	movea.w	#(PenBuf-M68K_RAM),a0
.0
	clr.w	(a0)+
	dbf	d0,.0
	rts

ClearPenalties	;IDA: sub_89A8A (title94) Clear the penalties: PBnum, Penaltytimer, Pencntdwn, PenBuf and both teams' penalty slots (clrTmPdst)
	movem.l	d0/a0,-(sp)
	clr.w	(PBnum).w
	clr.w	(Penaltytimer).w
	clr.w	(Pencntdwn).w
	move.w	#$10,d0
	movea.l	#PenBuf,a0
.0
	clr.l	(a0)+
	dbf	d0,.0
	movea.l	#HmShots,a0
	bsr.w	clrTmPdst
	movea.l	#AwShots,a0
	bsr.w	clrTmPdst
	movem.l	(sp)+,d0/a0
	rts

clrTmPdst	;IDA: sub_89AC4 (title94) Set the 26 tmpdst words of team a0 to -2 (bench), then -1
	move.w	#$19,d0
	adda.w	#$68,a0
.0
	move.w	#$FFFE,(a0)+
	dbf	d0,.0
	move.w	#$FFFF,(a0)
	rts

puckIChk	;IDA dc.b (checks94) Icing check: once the puck is loose (puckc negative) past the goal line ($10B, 94 $108) set iflags bit 0
	;(ifcgl), unless it went in the crease ($2C either side), which clears bit 2 (ifok)
	btst	#2,(iflags).w
	beq.w	.0
	btst	#0,(iflags).w
	bne.w	.0
	tst.w	(puckc).w
	bpl.w	.0
	move.w	#$10B,d0
	btst	#1,(iflags).w
	bne.w	.1
	neg.w	d0
	cmp.w	(pucky).w,d0
	bgt.w	.2
.0
	rts
.1
	cmp.w	(pucky).w,d0
	bgt.s	.0
.2
	cmpi.w	#$2C,(puckx).w
	bgt.w	.3
	cmpi.w	#$FFD4,(puckx).w
	blt.w	.3
	bclr	#2,(iflags).w
	rts
.3
	bset	#0,(iflags).w
	rts

ChkOffsides	;IDA dc.b (checks94) Offsides: clear the flag of a team that is all back onside (.8, 94 ClearOffsidesIfAllPlayers), then when
	;puck a3 crosses a blue line ($52, 94 $54) set tmflags bit 4 of the team with a player ahead of it
	btst	#5,(gmode).w
	beq.w	.3
	btst	#2,(BA_PS_flags).w
	bne.w	.3
	movea.w	#(HmShots-M68K_RAM),a1
	lea	tmsize(a1),a2
	bsr.w	.8
	exg	a1,a2
	bsr.w	.8
	move.w	#$52,d0
	cmp.w	Ypos(a3),d0
	bgt.w	.4
	cmp.w	OldYpos(a3),d0
	ble.w	.3
	addi.w	#$A,d0
	btst	#1,(gmode).w
	beq.w	.0
	exg	a2,a1
.0
	moveq	#5,d2
	movea.w	tmsort(a2),a0
.1
	tst.w	position(a0)
	bmi.w	.2
	cmp.w	Ypos(a0),d0
	bge.w	.2
	bset	#4,tmflags(a2)
	rts
.2
	adda.w	#SCstruct,a0
	dbf	d2,.1
.3
	rts
.4
	neg.w	d0
	cmp.w	Ypos(a3),d0
	blt.s	.3
	cmp.w	OldYpos(a3),d0
	bge.s	.3
	subi.w	#$A,d0
	btst	#1,(gmode).w
	bne.w	.5
	exg	a2,a1
.5
	moveq	#5,d2
	movea.w	tmsort(a2),a0
.6
	tst.w	position(a0)
	bmi.w	.7
	cmp.w	Ypos(a0),d0
	ble.w	.7
	bset	#4,tmflags(a2)
	rts
.7
	adda.w	#SCstruct,a0
	dbf	d2,.6
	rts
.8	;94 ClearOffsidesIfAllPlayers
	btst	#4,tmflags(a2)
	beq.s	.3
	movea.w	tmsort(a2),a0
	moveq	#5,d1
.9
	tst.w	position(a0)
	bmi.w	.10
	move.w	Ypos(a0),d0
	btst	#7,pflags(a0)
	bne.w	.10
	neg.w	d0
.10
	adda.w	#SCstruct,a0
	cmp.w	#$65,d0
	dbgt	d1,.9
	bgt.s	.3
	bclr	#4,tmflags(a2)
	rts

PenaltyNames	;IDA: unk_89C2E (data94) 92 Penaltylist, 94 PenaltyList. Penalty number = word offset into this table; the same entries as 94.
	;Used by AddPenalty, SetPA2, prefmes, PenaltyShotBox
	dc.w	$0000
	dc.w	.eop-PenaltyNames;$2 period over
	dc.w	.eog-PenaltyNames;$4 game over
	dc.w	.ghold-PenaltyNames;$6
	dc.w	.ghold-PenaltyNames;$8
	dc.w	.whistle-PenaltyNames;$A whistle
	dc.w	.ice-PenaltyNames;$C icing
	dc.w	.goal-PenaltyNames;$E goal
	dc.w	.offsides-PenaltyNames;$10 offsides
	dc.w	.rough2-PenaltyNames;$12 roughing, slow down time $A
	dc.w	.p14-PenaltyNames;$14 no text
	dc.w	.charge-PenaltyNames;$16
	dc.w	.slash-PenaltyNames;$18
	dc.w	.rough-PenaltyNames;$1A
	dc.w	.cross-PenaltyNames;$1C
	dc.w	.hook-PenaltyNames;$1E
	dc.w	.trip-PenaltyNames;$20
	dc.w	.int-PenaltyNames;$22
	dc.w	.hold-PenaltyNames;$24
	dc.w	.fight-PenaltyNames;$26
	dc.w	.fight2-PenaltyNames;$28
	dc.w	.inst-PenaltyNames;$2A
	dc.w	.delay-PenaltyNames;$2C delay
	dc.w	.hookps-PenaltyNames;$2E penalty shot
	dc.w	.tripps-PenaltyNames;$30 penalty shot
	dc.w	.ghold2-PenaltyNames;$32 face off, no slow down
	dc.w	.intps-PenaltyNames;$34 penalty shot
	dc.w	.roughps-PenaltyNames;$36 penalty shot
	dc.w	.chargeps-PenaltyNames;$38 penalty shot
	dc.w	.crossps-PenaltyNames;$3A penalty shot
	dc.w	.slashps-PenaltyNames;$3C penalty shot
.eop	dc.w	$0100
	String	'Period Over'
	dc.w	-$0510
.eog	dc.w	$0100
	String	'Game Over'
	dc.w	$0510,-$4060
.goal	dc.w	$0100
	dc.w	2;String with no text
	dc.w	$050A,-$4018
.p14	dc.w	$0100
	dc.w	2;String with no text
	dc.w	$0510,-$4018
.ice	dc.w	$0100
	String	'Icing'
	dc.w	$0002,$0101,-$0206
.offsides	dc.w	$0100
	String	'Off-side'
	dc.w	$0002,$0301,-$040F
.ghold	dc.w	$0100
	String	'Face Off'
	dc.w	-$050A
.ghold2	dc.w	$0000
	String	'Face Off'
	dc.w	-$050A
.delay	dc.w	$0000
	String	'Penalty'
	dc.w	$0003,$0301,-$0408
.whistle	dc.w	$0000
	dc.w	2;String with no text
	dc.w	-$050A
.charge	dc.w	$0402
	String	'Charging'
	dc.w	$0004,$0101,$0A01,$0B01,$0A01,$0B01,$0A01,$0B01,$0A01,$0B01,-$0101
.chargeps	dc.w	$04FF
	String	'Charging'
	dc.w	$0004,$0101,$0A01,$0B01,$0A01,$0B01,$0A01,$0B01,$0A01,$0B01,-$0101
.slash	dc.w	$0402
	String	'Slashing'
	dc.w	$0004,$0101,$0201,$0301,$0201,$0301,$0201,$0301,$0201,$0301,-$0101
.slashps	dc.w	$04FF
	String	'Slashing'
	dc.w	$0004,$0101,$0201,$0301,$0201,$0301,$0201,$0301,$0201,$0301,-$0101
.trip	dc.w	$0402
	String	'Tripping'
	dc.w	$0004,$0401,$0501,$0401,$0501,$0401,$0501,$0401,$0501,-$0101
.tripps	dc.w	$04FF
	String	'Tripping'
	dc.w	$0004,$0401,$0501,$0401,$0501,$0401,$0501,$0401,$0501,-$0101
.rough2	dc.w	$0A02
	String	'Roughing'
	dc.w	$0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
.rough	dc.w	$0402
	String	'Roughing'
	dc.w	$0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
.roughps	dc.w	$04FF
	String	'Roughing'
	dc.w	$0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
.hook	dc.w	$0402
	String	'Hooking'
	dc.w	$0004,$0101,$0901,$0801,$0901,$0801,$0901,$0801,$0901,$0801,-$0101
.hookps	dc.w	$04FF
	String	'Hooking'
	dc.w	$0004,$0101,$0901,$0801,$0901,$0801,$0901,$0801,$0901,$0801,-$0101
.cross	dc.w	$0402
	String	'Cross Check'
	dc.w	$0004,$0601,$0F01,$1001,$0F01,$1001,$0F01,$1001,$0F01,$1001,-$0101
.crossps	dc.w	$04FF
	String	'Cross Check'
	dc.w	$0004,$0601,$0F01,$1001,$0F01,$1001,$0F01,$1001,$0F01,$1001,-$0101
.int	dc.w	$0402
	String	'Interference'
	dc.w	$0004,$0101,$0C06,-$0101
.intps	dc.w	$04FF
	String	'Interference'
	dc.w	$0004,$0101,$0C06,-$0101
.hold	dc.w	$0402
	String	'Holding'
	dc.w	$0004,$0101,$0706,-$0101
.fight	dc.w	$2805
	String	'Fighting'
	dc.w	$0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
.fight2	dc.w	$2805
	String	'Fighting *'
	dc.w	$0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101
.inst	dc.w	$2802
	String	'Fight Instigator'
	dc.w	$0004,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,$0D01,$0E01,-$0101

checkob	;IDA: sub_89F5C (checks94) Offside watch (gmode bit 5): with a player of the attacking side past the blue line ($5A) ahead of the puck
	;the ref raises his arm (PushRef 6, sflags2 bit 7), back to $40 when they are onside
	btst	#5,(gmode).w
	beq.w	rtspen
	btst	#2,(BA_PS_flags).w
	bne.w	rtspen
	movem.l	d0-d1/a0,-(sp)
	moveq	#5,d0
	movea.w	#(SortCords-M68K_RAM),a0
	cmpi.w	#6,SCnum(a3)
	blt.w	.0
	adda.w	#$300,a0
.0
	moveq	#$5A,d1
	btst	#7,pflags(a3)
	bne.w	.7
	neg.w	d1
	cmp.w	(pucky).w,d1
	bgt.w	.3
.1
	tst.w	position(a0)
	bmi.w	.2
	cmp.w	Ypos(a0),d1
	bgt.w	.5
.2
	adda.w	#$80,a0
	dbf	d0,.1
.3
	moveq	#$40,d0
	bclr	#7,(sflags2).w
	bne.w	.6
.4
	movem.l	(sp)+,d0-d1/a0
	rts
.5
	moveq	#6,d0
	bset	#7,(sflags2).w
	bne.s	.4
.6
	tst.w	(RefCnt).w
	bpl.s	.4
	bsr.w	PushRef
	bra.s	.4
.7
	cmp.w	(pucky).w,d1
	blt.s	.3
.8
	tst.w	position(a0)
	bmi.w	.9
	cmp.w	Ypos(a0),d1
	blt.s	.5
.9
	adda.w	#$80,a0
	dbf	d0,.8
	bra.s	.3

PenShotPenalties	;IDA: unk_89FFC (data94) The penalty shot penalty number for penalty number d0 (word offset), -1 none. Used by PenShotChk
	dc.w	-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,$38,$3C
	dc.w	$36,$3A,$2E,$30,$34,-1,-1,-1,-1,-1,-1,-1

linelist	;IDA: unk_8A02C (data94) IDA: FaceOffsprites (94). Text list for the line choices. Used by SetLCmode2 and DrawFaceoffWindow
	String	'Sc1'
	String	'Sc2'
	String	'Chk'
	String	'PP1'
	String	'PP2'
	String	'PK1'
	String	'PK2'

