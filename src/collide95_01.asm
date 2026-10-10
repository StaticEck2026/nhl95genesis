; $07A762  Adapted from collide94.asm: puck, players, walls, fights, goals
;	NHL 95 segment $7A762-$7C511, from lst/nhl95.bin.lst. video94 ProcessInputWithRepeat, stats94 WaitVSyncAndReadInput, then the 94 collide94
;	collision code in a new order: checkcoll, checkwallcoll, wallcollb, wallcoll, checkplcoll, checkcx, checkcheck, CCStart (checkinglist, the 95
;	checkinglist2, Bcheck, holdcheck, the 95 Sweepcheck), FallDown, checkpuckcoll, puckstick, puckglue, puckbody, rtspuck (the 94 rtss2 place),
;	deflect, checkpuckcoll_sfx, checkgoal (the 94 .goal code is elsewhere: Goal), checkgoalp, CheckBump, cards94 wallcollduringcheck, crowd94
;	checkcornercoll94 / cornercollb94, puckgoalie, checkint, the 95 DropPuck. video95_03 (94 sroot) follows at $7C512.
;	IDA dc.b written as instructions: WaitVSyncAndReadInput, a second rts after checkwallcoll ($7A976), checkpuckcoll ... checkpuckcoll_sfx
;	($7B51A-$7BD8B) and puckgoalie ($7C154-$7C3FB).
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.
;	Sort struct (SortCords, $80 each): $40 temp1, $64 bit 3 one-timer, bit 4 wall collision, bit 5 fell, $68 Agl, $73 aggres, $74 Fgt, $75 Chk.
ProcessInputWithRepeat	;IDA: sub_7A762 (video94). 93 name. nodiag, then key repeat on d1-d3. 95: first repeat after $19 frames, then every 4 (every $14 with sflags12
	;bit 0)
	bsr.w	nodiag
	tst.w	d3
	beq.w	.2
	tst.w	d2
	bne.w	.1
	subq.w	#1,(repeatdelayframes).w
	bpl.w	.2
	move.w	#4,(repeatdelayframes).w
	btst	#0,(sflags12).w
	beq.w	.0
	move.w	#$14,(repeatdelayframes).w
.0
	move.w	d3,d1
	rts
.1
	move.w	#$19,(repeatdelayframes).w
.2
	rts

WaitVSyncAndReadInput	;$7A79C. IDA dc.b (stats94). Wait for the next vblank, read the menu pad (ReadMenuJoy, nodiag) until a new button press
	move.w	(vcount).w,d1
.0
	cmp.w	(vcount).w,d1
	beq.s	.0
	bsr.w	ReadMenuJoy
	bsr.w	nodiag
	tst.b	d1
	beq.s	WaitVSyncAndReadInput
	rts

checkcoll	;IDA: sub_7A7B4. d2 = new x coord, d3 = new y coord, a3 = struct of object. Check wall collision (around the hot spot and the end of the
	;stick) and player collisions, then move a3 in the OOlist sort order by its y. If a player collision set collflag, restore the old x/y instead.
	;Called from updateplayers. 95 has no horizontal rink case
	clr.w	(collflag).w
	btst	#pfnc,pflags(a3)
	bne.w	.1
	movem.l	d0-d7,-(sp)
	move.w	(a3),d2
	move.w	Ypos(a3),d3
	move.w	radiusx(a3),(wcradiusx).w
	move.w	radiusy(a3),(wcradiusy).w
	bsr.w	checkwallcoll
	move.w	Wallcos(a3),d0
	or.w	Wallsin(a3),d0
	bne.w	.0
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.0
	movem.l	(sp),d0-d7
	move.l	a3,-(sp)
	bsr.w	GetHot
	move.w	(a3),d2
	move.w	Ypos(a3),d3
	add.w	d0,d2
	add.w	d1,d3
	move.w	#1,(wcradiusx).w
	move.w	#1,(wcradiusy).w
	bsr.w	checkwallcoll
.0
	movem.l	(sp)+,d0-d7
	bsr.w	checkplcoll
.1
	tst.w	(collflag).w
	bne.w	.6
	move.w	SCnum(a3),d0
	asl.w	#1,d0
	movea.w	#(OOlistpos-M68K_RAM),a0
	movea.w	#(OOlist-M68K_RAM),a1
	movea.w	#(Ylist-M68K_RAM),a2
	move.w	(a0,d0.w),d1
.2
	cmp.w	#$F,d1
	beq.w	.3
	clr.w	d4
	move.b	1(a1,d1.w),d4
	cmp.w	(a2,d4.w),d3
	ble.w	.3
	addq.w	#1,(a0,d0.w)
	subq.w	#1,(a0,d4.w)
	move.b	d4,(a1,d1.w)
	move.b	d0,1(a1,d1.w)
	addq.w	#1,d1
	bra.s	.2
.3
	move.w	(a0,d0.w),d1
	beq.w	.5
.4
	clr.w	d4
	move.b	-1(a1,d1.w),d4
	cmp.w	(a2,d4.w),d3
	bge.w	.5
	subq.w	#1,(a0,d0.w)
	addq.w	#1,(a0,d4.w)
	move.b	d4,(a1,d1.w)
	move.b	d0,-1(a1,d1.w)
	subq.w	#1,d1
	bne.s	.4
.5
	move.w	d3,(a2,d0.w)
	rts
.6
	move.w	OldXpos(a3),(a3)
	move.w	OldYpos(a3),Ypos(a3)
	rts

checkwallcoll	;IDA: sub_7A8A2. 93 name. d2/d3 = x/y to test, a3 = object, wcradiusx/wcradiusy = radius. Check the corner circles, the goals (checkgoal
	;with a2 = SortCords+(13*SCstruct) top, SortCords+(12*SCstruct) bottom) and then the side and end boards. Calls wallcollb on a hit, with
	;d0/d1 = cos/sin of the wall. 95 rink: sideline $98, end boards $138, corner radius $4C (94: $88, $12A, $40)
	bclr	#4,$64(a3)
	move.w	#$98,d4
	sub.w	(wcradiusx).w,d4
	move.w	#$138,d5
	sub.w	(wcradiusy).w,d5
	movem.w	d2-d5,-(sp)
	neg.w	d4
	neg.w	d5
	addi.w	#$4C,d4
	addi.w	#$4C,d5
	cmp.w	d5,d3
	bgt.w	.0
	cmp.w	d4,d2
	blt.w	.1
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.1
	movea.w	#(SortCords+(13*SCstruct)-M68K_RAM),a2
	bsr.w	checkgoal
	bra.w	.2
.0
	neg.w	d5
	cmp.w	d5,d3
	blt.w	.2
	cmp.w	d4,d2
	blt.w	.1
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.1
	movea.w	#(SortCords+(12*SCstruct)-M68K_RAM),a2
	bsr.w	checkgoal
	bra.w	.2
.1
	sub.w	d4,d2
	sub.w	d5,d3
	move.w	d3,d0
	move.w	d2,d1
	neg.w	d1
	muls.w	d3,d3
	muls.w	d2,d2
	add.l	d2,d3
	cmp.l	#$1690,d3
	bls.w	.2
	exg	d0,d3
	bsr.w	sroot
	exg	d0,d3
	ext.l	d0
	asl.l	#8,d0
	divs.w	d3,d0
	ext.l	d1
	asl.l	#8,d1
	divs.w	d3,d1
	bsr.w	wallcollb
.2
	movem.w	(sp)+,d2-d5
	move.w	Wallcos(a3),d0
	or.w	Wallsin(a3),d0
	bne.w	rtspuck
	move.w	#$100,d0
	clr.w	d1
	cmp.w	d5,d3
	bge.w	wallcollb
	neg.w	d5
	neg.w	d0
	cmp.w	d5,d3
	ble.w	wallcollb
	exg	d0,d1
	cmp.w	d4,d2
	bge.w	wallcollb
	neg.w	d4
	neg.w	d1
	cmp.w	d4,d2
	ble.w	wallcollb
	rts
	rts	;$7A976. IDA dc.b: a second rts, no xref

wallcollb	;IDA: sub_7A978. 93 name. Check for puck over wall. a3 = object, d0/d1 = cos/sin of the wall. Not the puck: wallcoll. 95: Zpos above $15
	;locks the scroll (LockScroll) and goes out of play; above $12 only at x $28-$2A behind the goal line ($110) with Yvel >= $FA0 (SPA $250A on the
	;next struct, sfx $E, crowd). Out of play: sfslock, pfnc, and while the clock runs penalty 6 (PenOOP) for ltplayer
	cmpi.w	#$E,SCnum(a3)
	bne.w	wallcoll
	cmpi.w	#$15,Zpos(a3)
	ble.w	.0
	jsr	(LockScroll).l
	bra.w	.1
.0
	cmpi.w	#$12,Zpos(a3)
	bls.w	wallcoll
	cmpi.w	#$110,Ypos(a3)
	blt.w	.1
	cmpi.w	#$28,(a3)
	blt.w	wallcoll
	cmpi.w	#$2A,(a3)
	bgt.w	wallcoll
	cmpi.w	#$FA0,Yvel(a3)
	blt.w	wallcoll
	move.l	a3,-(sp)
	asr	Yvel(a3)
	adda.w	#$80,a3
	move.w	#$250A,d1
	jsr	(SetSPA).l
	movea.l	(sp)+,a3
	move.w	#$E,-(sp)
	jsr	(sfx).l
	addi.w	#$258,(crowdlevel).w
	addi.w	#$F,(CwdExciteLvl).w
.1
	bset	#sfslock,(sflags).w
	bset	#pfnc,pflags(a3)
	tst.w	Ypos(a3)
	bpl.w	.2
	ori.w	#$8000,attribute(a3)
.2
	clr.w	$86(a3)
	btst	#gmclock,(gmode).w
	bne.w	.3
	move.l	a3,-(sp)
	move.w	(ltplayer).w,d0
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	move.l	#6,d0
	jsr	(AddPenalty2).l
	movea.l	(sp)+,a3
.3
	rts

wallcoll	;IDA: sub_7AA36. d0 = cosine, d1 = sine of angle of incidence with wall, a3 = object. Bounce a3 off the wall: the puck loses speed, flips
	;and plays sfx $28-$2B; a player sets the wall collision bit (unless sflags6 bit 4) and plays SFXplayerwall on a hard hit
	move.w	d0,Wallcos(a3)
	move.w	d1,Wallsin(a3)
	movem.l	d2-d3,-(sp)
	movem.w	d0-d1,-(sp)
	muls.w	Yvel(a3),d0
	muls.w	Xvel(a3),d1
	sub.l	d1,d0
	asr.l	#8,d0
	move.w	d0,d2
	movem.w	(sp),d0-d1
	muls.w	Xvel(a3),d0
	muls.w	Yvel(a3),d1
	add.l	d1,d0
	asr.l	#8,d0
	move.w	d0,d3
	neg.w	d2
	cmpi.w	#$E,SCnum(a3)
	bne.w	.2
	bclr	#4,(sflags2).w
	tst.w	d2
	bpl.w	.6
	asr.w	#2,d2
	cmp.w	#$FC00,d2
	bgt.w	.1
	move.w	#$800,d0
	bsr.w	randomd0
	neg.w	d0
	move.w	d0,Zvel(a3)
	bsr.w	puckflip
	move.w	d2,d0
	asr.w	#8,d0
	asr.w	#2,d0
	addq.w	#4,d0
	bpl.w	.0
	clr.w	d0
.0
	andi.w	#3,d0
	addi.w	#$28,d0
	move.w	d0,-(sp)
	jsr	(sfx).l
.1
	move.w	d3,d0
	asr.w	#6,d0
	sub.w	d0,d3
	asr.w	#1,d0
	sub.w	d0,d3
	bra.w	.5
.2
	cmp.w	#$3E8,d2
	bgt.w	.6
	bclr	#4,(sflags6).w
	bne.w	.3
	bset	#4,$64(a3)
.3
	cmp.w	#$F000,d2
	bgt.w	.4
	cmpi.w	#$A,impact(a3)
	blt.w	.4
	move.w	#$20,-(sp)
	jsr	(sfx).l
.4
	asr.w	#2,d2
	cmp.w	#$FC7C,d2
	blt.w	.5
	move.w	#$FC18,d2
.5
	movem.w	(sp),d0-d1
	movem.w	d2-d3,-(sp)
	muls.w	d0,d3
	muls.w	d1,d2
	sub.l	d2,d3
	asr.l	#8,d3
	move.w	d3,Xvel(a3)
	movem.w	(sp)+,d2-d3
	movem.w	(sp),d0-d1
	muls.w	d1,d3
	muls.w	d0,d2
	add.l	d2,d3
	asr.l	#8,d3
	move.w	d3,Yvel(a3)
	tst.w	Zvel(a3)
	bmi.w	.6
	clr.w	Zvel(a3)
.6
	addq.w	#4,sp
	movem.l	(sp)+,d2-d3
	rts

checkplcoll	;IDA: sub_7AB44. check collision with other players. d2/d3 = x/y cords, a3 = struct. Walk up and down the OOlist from a3 and call
	;checkcx for each object within $10 in y (92 collrad*2). Called from checkcoll
	btst	#5,pflags2(a3)
	bne.w	.3
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.3
	move.w	SCnum(a3),d0
	asl.w	#1,d0
	movea.w	#(OOlistpos-M68K_RAM),a0
	movea.w	#(OOlist-M68K_RAM),a1
	movea.w	#(Ylist-M68K_RAM),a2
	move.w	(a0,d0.w),d1
.0
	cmp.w	#$F,d1
	beq.w	.1
	clr.w	d4
	move.b	1(a1,d1.w),d4
	move.w	(a2,d4.w),d5
	sub.w	d3,d5
	cmp.w	#$10,d5
	bgt.w	.1
	bsr.w	checkcx
	addq.w	#1,d1
	bra.s	.0
.1
	move.w	(a0,d0.w),d1
	beq.w	.3
.2
	clr.w	d4
	move.b	-1(a1,d1.w),d4
	move.w	d3,d5
	sub.w	(a2,d4.w),d5
	cmp.w	#$10,d5
	bgt.w	.3
	bsr.w	checkcx
	subq.w	#1,d1
	bne.s	.2
.3
	rts

checkcx	;IDA: sub_7ABB8. d4 = obj. # * 2 for possible collision so check x range and distance for collision. d2 = x, d5 = delta y, a3 = moving
	;object. Opposing players add impact and run newcheck, checkint and checkcheck; then momentum moves from a3 to a2 (95: no elasticity term,
	;a goalie weighs $DC, and no momentum when either player has pflags2 bit 5 after the checks)
	movem.l	d0-d7/a0-a3,-(sp)
	asl.w	#6,d4
	movea.l	#SortCords,a2
	adda.w	d4,a2
	btst	#pfnc,pflags(a2)
	bne.w	.7
	btst	#5,pflags2(a2)
	bne.w	.7
	cmpi.w	#$B,SCnum(a2)
	bgt.w	.7
	move.w	(a2),d0
	sub.w	d2,d0
	cmp.w	#$FFF0,d0
	blt.w	.7
	cmp.w	#$10,d0
	bgt.w	.7
	muls.w	d5,d5
	muls.w	d0,d0
	add.l	d5,d0
	cmp.l	#$100,d0
	bgt.w	.7
	move.b	pflags(a3),d6
	move.b	pflags(a2),d0
	eor.b	d0,d6
	move.w	Xvel(a3),d0
	sub.w	Xvel(a2),d0
	move.w	Yvel(a3),d1
	sub.w	Yvel(a2),d1
	move.w	(a3),d2
	sub.w	(a2),d2
	neg.w	d2
	move.w	Ypos(a3),d3
	sub.w	Ypos(a2),d3
	neg.w	d3
	movem.w	d0-d1,-(sp)
	muls.w	d3,d1
	muls.w	d2,d0
	add.l	d0,d1
	bmi.w	.8
	asr.l	#4,d1
	btst	#pfteam,d6
	beq.w	.4
	move.w	d1,d4
	lsr.w	#8,d4
	cmp.w	#5,d4
	bgt.w	.0
	moveq	#5,d4
.0
	add.w	d4,impact(a3)
	add.w	d4,impact(a2)
	move.w	SCnum(a3),impactp(a2)
	move.w	SCnum(a2),impactp(a3)
	cmp.w	#$14,d4
	blt.w	.2
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	beq.w	.1
	cmp.w	SCnum(a2),d0
	bne.w	.2
.1
	jsr	(newcheck).l
.2
	movem.l	a2-a3,-(sp)
	bsr.w	checkint
	bsr.w	checkcheck
	movem.l	(sp)+,a2-a3
	btst	#5,pflags2(a3)
	bne.w	.3
	btst	#5,pflags2(a2)
	beq.w	.4
.3
	movem.w	(sp)+,d0-d1
	bra.w	.7
.4
	move.w	d1,d4
	movem.w	(sp)+,d0-d1
	tst.w	(collflag).w
	bmi.w	.7
	muls.w	d2,d1
	muls.w	d3,d0
	sub.l	d1,d0
	asr.l	#4,d0
	move.w	d0,d5
	clr.w	d0
	move.b	weight(a3),d0
	tst.w	position(a3)
	bne.w	.5
	move.w	#$DC,d0
.5
	addi.w	#$8C,d0
	clr.w	d1
	move.b	weight(a2),d1
	tst.w	position(a2)
	bne.w	.6
	move.w	#$DC,d1
.6
	addi.w	#$8C,d1
	add.w	d0,d1
	muls.w	d4,d0
	divs.w	d1,d0
	move.w	d0,d1
	movem.w	d2-d3,-(sp)
	muls.w	d5,d3
	muls.w	d0,d2
	add.l	d2,d3
	asr.l	#4,d3
	add.w	Xvel(a2),d3
	move.w	d3,Xvel(a3)
	movem.w	(sp),d2-d3
	muls.w	d5,d2
	muls.w	d0,d3
	sub.l	d2,d3
	asr.l	#4,d3
	add.w	Yvel(a2),d3
	move.w	d3,Yvel(a3)
	movem.w	(sp)+,d2-d3
	muls.w	d1,d2
	asr.l	#4,d2
	add.w	d2,Xvel(a2)
	muls.w	d1,d3
	asr.l	#4,d3
	add.w	d3,Yvel(a2)
	st	(collflag).w
.7
	movem.l	(sp)+,d0-d7/a0-a3
	rts
.8
	addq.w	#4,sp
	bra.s	.7

checkcheck	;IDA: sub_7AD50. player is in contact: look for various contact events. Runs CCStart for a3 on a2, then for a2 on a3. d4 = impact.
	;Called from checkcx
	movem.l	d0-d4/a0-a3,-(sp)
	bsr.w	CCStart
	exg	a2,a3
	bsr.w	CCStart
	movem.l	(sp)+,d0-d4/a0-a3
	rts

CCStart	;IDA: sub_7AD64. Player a3 is checking player a2. Holds (95 SPA $E10, $E74) go to holdcheck, SPA $F38 (94 SPAsweepchk) to Bcheck;
	;otherwise only a3 in SPA $11AE (94 SPAburst) checks. Sets a3's check anim from checkinglist (95: 1 in 5 from checkinglist2 when the two
	;face each other); a big enough hit on a skater makes a2 fall, with a charging ($16 / $18) or roughing ($1A / $1C) roll from checkagr
	cmpi.w	#$E10,SPA(a2)
	beq.w	holdcheck
	cmpi.w	#$E74,SPA(a2)
	beq.w	holdcheck
	cmpi.w	#$F38,SPA(a2)
	beq.w	Bcheck
	cmpi.w	#$11AE,SPA(a3)
	beq.w	.0
	rts
.0
	move.w	(a2),d0
	sub.w	(a3),d0
	move.w	Ypos(a2),d1
	sub.w	Ypos(a3),d1
	bsr.w	vtoa
	sub.w	facedir(a3),d0
	andi.w	#7,d0
	btst	#3,attribute(a3)
	beq.w	.1
	neg.w	d0
	addq.w	#8,d0
	andi.w	#7,d0
.1
	asl.w	#1,d0
	lea	checkinglist(pc),a0
	cmpi.w	#2,facedir(a3)
	beq.w	.2
	cmpi.w	#6,facedir(a3)
	beq.w	.2
	movem.w	d0,-(sp)
	move.w	facedir(a3),d0
	addq.w	#4,d0
	andi.w	#7,d0
	cmp.w	facedir(a2),d0
	movem.w	(sp)+,d0
	bne.w	.2
	movem.w	d0,-(sp)
	move.w	#$64,d0
	jsr	(randomd0).l
	cmp.w	#$14,d0
	movem.w	(sp)+,d0
	bgt.w	.2
	lea	checkinglist2(pc),a0
	move.w	(a2),d0
	sub.w	(a3),d0
	move.w	Ypos(a2),d1
	sub.w	Ypos(a3),d1
	jsr	(vtoa).l
	add.w	d0,d0
.2
	move.w	(a0,d0.w),d1
	bset	#pfalock,pflags(a3)
	jsr	(SetSPA).l
	tst.w	position(a2)
	beq.w	.7
	cmp.w	#$14,d4
	blt.w	.7
	moveq	#$78,d0
	btst	#pfjoycon,pflags(a3)
	beq.w	.3
	subi.w	#$20,d0
.3
	move.w	d1,-(sp)
	clr.w	d1
	move.b	$75(a3),d1
	sub.w	d1,d0
	move.w	(sp)+,d1
	exg	a2,a3
	jsr	(wallcollduringcheck).l
	exg	a2,a3
	movem.w	d1,-(sp)
	move.w	impact(a2),d1
	sub.w	d1,d0
	movem.w	(sp)+,d1
	beq.w	.5
	bmi.w	.5
	andi.w	#$FF,d0
	move.w	SCnum(a2),d1
	cmp.w	(puckc).w,d1
	bne.w	.4
	asr.w	#1,d0
.4
	btst	#4,$64(a3)
	bne.w	.5
	bsr.w	randomd0
	clr.w	(TempWord1).w
	move.b	$75(a3),(TempWord1+1).w
	lsr	(TempWord1).w
	cmp.b	(TempWord1+1).w,d0
	ble.w	.5
	jsr	(checkagr).l
	cmp.w	#4,d0
	bhi.w	rtspuck
	move.b	(VDP_CNTR).l,d0
	andi.w	#2,d0
	addi.w	#$16,d0
	jsr	(PenShotChk).l
	jmp	(AddPenalty).l
.5
	jsr	(checkagr).l
	cmp.w	#3,d0
	bhi.w	.6
	move.b	(VDP_CNTR).l,d0
	andi.w	#2,d0
	addi.w	#$1A,d0
	jsr	(PenShotChk).l
	jsr	(AddPenalty).l
.6
	bra.w	FallDown
.7
	rts

checkinglist	;IDA: unk_7AF06. Check anim by direction from a3 to a2, SPA offsets
	dc.w	$DAC,$DDE,$DDE,$DDE,$DDE,$DAC,$DAC,$DAC

checkinglist2	;IDA: unk_7AF16. 95 only. Check anims for two players facing each other
	dc.w	$2530,$254A,$254A,$254A,$254A,$2530,$2530,$2530

Bcheck	;IDA: loc_7AF26. a2 = player that is B checking (SPA $F38), a3 = player being checked. Entered from CCStart. If OptPen is 0 and a2 is
	;joystick controlled, a2 needs randomd0($20 + a2 Chk - a3 Agl) >= $18 (95: no roll against a3 the puck carrier). If a3 is within 1 direction
	;of where a2 faces, a3 falls and checkagr may call penalty $20 (tripping) on a2. Sets collflag
	btst	#pfalock,pflags(a3)
	bne.w	.2
	tst.w	position(a3)
	beq.w	.2
	tst.w	(OptPen).w
	bne.w	.0
	btst	#pfjoycon,pflags(a2)
	beq.w	.0
	move.w	#$20,d0
	add.b	$75(a2),d0
	sub.b	$68(a3),d0
	move.w	SCnum(a3),d1
	cmp.w	(puckc).w,d1
	beq.w	.0
	bsr.w	randomd0
	cmp.w	#$18,d0
	blt.w	.2
.0
	move.w	(a3),d0
	sub.w	(a2),d0
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1
	bsr.w	vtoa
	sub.w	facedir(a2),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	.2
	exg	a2,a3
	bsr.w	FallDown
	jsr	(checkagr).l
	cmp.w	#4,d0
	bhi.w	.1
	move.w	#$20,d0
	jsr	(PenShotChk).l
	jsr	(AddPenalty).l
.1
	exg	a2,a3
	st	(collflag).w
.2
	rts

holdcheck	;IDA: loc_7AFBC. player a2 is in a hold animation looking to hold opponent a3. Entered from CCStart. a3 must be within 1 direction of
	;where a2 faces. Both get the average velocity, a3 goes to SPA $1F68, a2 to $E42 or $EA6, and checkagr rolls penalty $24 or $1E
	btst	#pfalock,pflags(a3)
	bne.w	.4
	tst.w	position(a3)
	beq.w	rtss2
	move.w	(a3),d0
	sub.w	(a2),d0
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1
	bsr.w	vtoa
	sub.w	facedir(a2),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	.4
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	.0
	bclr	#sfssdir,(sflags).w
.0
	move.w	Xvel(a3),d0
	add.w	Xvel(a2),d0
	asr.w	#1,d0
	move.w	d0,Xvel(a3)
	move.w	d0,Xvel(a2)
	move.w	Yvel(a3),d0
	add.w	Yvel(a2),d0
	asr.w	#1,d0
	move.w	d0,Yvel(a3)
	move.w	d0,Yvel(a2)
	bset	#pfalock,pflags(a3)
	move.w	#$1F68,d1
	jsr	(SetSPA).l
	exg	a2,a3
	bset	#pfalock,pflags(a3)
	move.w	#$E42,d1
	cmpi.w	#$E10,SPA(a3)
	beq.w	.1
	move.w	#$EA6,d1
.1
	jsr	(SetSPA).l
	jsr	(checkagr).l
	cmp.w	#6,d0
	bhi.w	.3
	move.w	#$24,d0
	cmpi.w	#$E42,SPA(a3)
	beq.w	.2
	move.w	#$1E,d0
.2
	jsr	(PenShotChk).l
	jsr	(AddPenalty).l
.3
	exg	a2,a3
	st	(collflag).w
.4
	rts

Sweepcheck	;IDA: loc_7B08A. 95 only. Lock a3 in SPA $F38 (the sweep check). Jumped to from chgplayer (setup95_01)
	bset	#pfalock,pflags(a3)
	move.w	#$F38,d1
	jmp	(SetSPA).l

FallDown	;IDA: sub_7B09A. player a2 falls down, player a3 is the hitting player. Skips a2 in some anims, or the same pair as the last call. A skater
	;hitter adds check stats (team $10, player $11E, ChkCnt). A hit into the wall picks a fall anim from .FallList by where a2 is, a strong Stk player
	;may just stumble (95: and drop the puck, DropPuck), and an injury (setInjuryType) adds penalty $12 (or $14) and stops play. Then the crowd and
	;a check sound (newcheck). Called from checkint, CCStart, Bcheck and puckbody
	cmpi.w	#$B,SCnum(a2)
	bgt.w	.33
	cmpi.w	#$2454,SPA(a2)
	beq.w	.33
	cmpi.w	#$2496,SPA(a2)
	beq.w	.33
	cmpi.w	#$24D8,SPA(a2)
	beq.w	.33
	cmpi.w	#$1AA4,SPA(a2)
	beq.w	.33
	cmpi.w	#$FAA,SPA(a2)
	beq.w	.33
	cmpi.w	#$109C,SPA(a2)
	beq.w	.33
	move.l	a2,(PlayerChked).w
	move.l	a3,(PlayerChking).w
	btst	#3,$64(a2)
	bne.w	rtss2
	btst	#3,$64(a3)
	bne.w	rtss2
	move.w	#$1AA4,d1
	btst	#4,$64(a3)
	bne.w	.0
	cmpi.b	#$10,stickhand(a2)
	blt.w	.0
	tst.b	$5F(a2)
	bne.w	.0
	move.w	(VDP_CNTR).l,d0
	andi.w	#$F,d0
	addi.w	#$20,d0
	cmp.w	impact(a2),d0
	ble.w	.0
	move.b	#$3C,$5F(a2)
	cmpi.b	#$14,stickhand(a2)
	bgt.w	.26
	bsr.w	DropPuck
	bra.w	.26
.0
	tst.w	position(a3)
	beq.w	.2
	movea.w	#(HmShots-M68K_RAM),a0
	btst	#pfteam,pflags(a3)
	beq.w	.1
	adda.w	#$366,a0
.1
	addq.w	#1,$10(a0)
	clr.w	d0
	move.b	pnum(a3),d0
	adda.w	d0,a0
	addq.b	#1,$11E(a0)
	addq.w	#1,(ChkCnt).w
	tst.b	$74(a3)
	bne.w	.2
	addq.w	#2,(ChkCnt).w
.2
	move.b	#$78,nopuck(a2)
	move.w	(a3),d0
	sub.w	(a2),d0
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1
	jsr	(vtoa).l
	tst.w	position(a2)
	beq.w	.24
	jsr	(wallcollduringcheck).l
	btst	#4,$64(a2)
	beq.w	.24
	movem.l	d1-d4,-(sp)
	move.w	Xvel(a2),d1
	bpl.w	.3
	neg.w	d1
.3
	move.w	Yvel(a2),d2
	bpl.w	.4
	neg.w	d2
.4
	move.w	(a2),d3
	sub.w	(a3),d3
	move.w	Ypos(a2),d4
	sub.w	Ypos(a3),d4
	cmpi.w	#$10B,Ypos(a3)
	bgt.w	.7
	cmpi.w	#$FEF5,Ypos(a3)
	blt.w	.6
	tst.w	(a3)
	bpl.w	.5
	tst.w	d3
	bpl.w	.8
	cmp.w	#$FFFD,d3
	bgt.w	.8
	bra.w	.9
.5
	tst.w	d3
	bmi.w	.8
	cmp.w	#3,d3
	blt.w	.8
	bra.w	.9
.6
	tst.w	d4
	bpl.w	.8
	bra.w	.9
.7
	tst.w	d4
	bmi.w	.8
	bra.w	.9
.8
	movem.l	(sp)+,d1-d4
	bra.w	.24
.9
	movem.l	(sp)+,d1-d4
	bra.w	*+4
.10
	cmpi.w	#$10F,Ypos(a2)
	bgt.w	.11
	cmpi.w	#$FEF1,Ypos(a2)
	blt.w	.11
	cmpi.w	#$78,(a2)
	bgt.w	.11
	cmpi.w	#$FF88,(a2)
	blt.w	.11
	bra.w	.24
.11
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.12
	addi.w	#$A,(CwdExciteLvl).w
	addi.w	#$96,(crowdlevel).w
	move.w	d1,-(sp)
	move.b	#0,$40(a3)
	move.b	#0,$65(a3)
	move.w	#$2288,d1
	jsr	(SetSPA).l
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	clr.w	impact(a2)
	clr.w	impact(a3)
	move.w	(sp)+,d1
.12
	movem.l	d0/a0,-(sp)
	cmpi.w	#$10F,Ypos(a2)
	bgt.w	.14
	cmpi.w	#$FEF1,Ypos(a2)
	blt.w	.15
	tst.w	(a2)
	bmi.w	.13
	move.w	#2,d0
	bra.w	.16
.13
	move.w	#6,d0
	bra.w	.16
.14
	move.w	#0,d0
	bra.w	.16
.15
	move.w	#4,d0
.16
	add.w	d0,d0
	movea.l	#.23,a0
	move.w	(a0,d0.w),d1
	move.w	Ypos(a2),(FallYPos).w
	move.w	(a2),(FallXPos).w
	cmp.w	#$220E,d1
	bne.w	.17
	cmpi.w	#$59,Ypos(a2)
	bgt.w	.17
	cmpi.w	#$FFA7,Ypos(a2)
	blt.w	.17
	move.w	#$26C8,d1
	btst	#3,attribute(a2)
	beq.w	.20
	move.w	#$276A,d1
	bra.w	.20
.17
	cmp.w	#$2122,d1
	bne.w	.18
	cmpi.w	#$38,Ypos(a2)
	bgt.w	.18
	cmpi.w	#$FFC8,Ypos(a2)
	blt.w	.18
	move.w	#$276A,d1
	btst	#3,attribute(a2)
	beq.w	.20
	move.w	#$26C8,d1
	bra.w	.20
.18
	btst	#3,attribute(a2)
	beq.w	.20
	cmp.w	#$2122,d1
	beq.w	.19
	cmp.w	#$220E,d1
	bne.w	.20
	move.w	#$2122,d1
	bra.w	.20
.19
	move.w	#$220E,d1
.20
	clr.w	Xvel(a2)
	clr.w	Yvel(a2)
	btst	#5,$64(a2)
	bne.w	.22
	move.w	#$2D,-(sp)
	btst	#pfteam,pflags(a2)
	beq.w	.21
	move.w	#$2E,(sp)
.21
	jsr	(sfx).l
.22
	bset	#5,$64(a2)
	bset	#pfdoff,pflags(a2)
	movem.l	(sp)+,d0/a0
	bra.w	.25
.23
	dc.w	$20B0,$20B0,$2122,$2122,$219C,$219C,$220E,$220E
.24
	move.w	#$109C,d1
	sub.w	facedir(a2),d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bls.w	.26
	move.w	#$FAA,d1
.25
	move.w	facedir(a2),d0
	andi.w	#3,d0
	bne.w	.26
	cmpi.w	#$2530,SPA(a3)
	beq.w	.26
	cmpi.w	#$254A,SPA(a3)
	beq.w	.26
	cmpi.b	#$14,$75(a3)
	blt.w	.26
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.26
	btst	#5,$64(a2)
	bne.w	.26
	move.w	#$2596,d1
.26
	exg	a2,a3
	bset	#pfalock,pflags(a3)
	jsr	(SetSPA).l
	exg	a2,a3
	move.w	(puckc).w,d0
	bmi.w	.34
	cmp.w	SCnum(a2),d0
	bne.w	.34
	st	(puckc).w
	btst	#gmhl,(gmode).w
	bne.w	.31
	cmpi.w	#$109C,SPA(a2)
	bne.w	.31
	move.w	facedir(a2),d0
	andi.w	#3,d0
	bne.w	.31
	btst	#4,pflags2(a2)
	bne.w	.31
	move.w	#$190,d0
	bsr.w	randomd0
	cmp.w	impact(a2),d0
	bgt.w	.31
	btst	#gmclock,(gmode).w
	bne.w	.31
	exg	a2,a3
	move.w	#$2454,d1
	jsr	(SetSPA).l
	exg	a2,a3
	jsr	(setInjuryType).l
	btst	#5,(sflags7).w
	beq.w	.28
	exg	a2,a3
	move.w	#$2496,d1
	btst	#1,(sflags12).w
	beq.w	.27
	move.w	#$24D8,d1
.27
	jsr	(SetSPA).l
	exg	a2,a3
.28
	move.w	#4,(InjCntDown).w
	move.l	#$14,d0
	tst.w	position(a3)
	bne.w	.30
.29
	jmp	(AddPenalty2).l
.30
	tst.w	(OptPen).w
	beq.s	.29
	move.l	#$12,d0
	jsr	(AddPenalty2).l
	jmp	(Stop4Pen).l
.31
	move.w	#$B,-(sp)
	btst	#pfteam,pflags(a2)
	bne.w	.32
	move.w	#$C,(sp)
.32
	jsr	(song).l
.33
	rts
.34
	jmp	(newcheck).l

checkpuckcoll	;$7B51A. IDA dc.b. look for puck coll with players. a3 = puck. Clears Yvel past the back boards, then walks up and down the OOlist from
	;the puck and runs .ccx on each object within $1D in y: stick (puckstick), body (puckbody) or goalie (puckgoalie). 95 keeps the skater
	;reach in RAM: stick $12 (x and y, squared $144) and body $B (squared $79), or $E / $A ($C4 / $64) unless a2 is in a one-timer.
	;95 bugs kept: the stick distance compares against the address of ChkStickSqP, not its value, and the body y test is a move, so
	;puckbody is never reached from here
	move.w	#$B,(ChkBodyP).w
	move.w	#$12,(ChkStickP).w
	move.w	#$FFF5,(NegChkBodyP).w
	move.w	#$FFEE,(NegChkStickP).w
	move.w	#$79,(ChkBodySqP).w
	move.w	#$144,(ChkStickSqP).w
	cmpi.w	#$190,Ypos(a3)	;compare 190 hex to Ypos (back board?)
	bgt.w	.resetYvel	;branch if greater than
	cmpi.w	#$FE70,Ypos(a3)	;compare -190 to Ypos (back board?)
	bgt.w	.setup	;branch if greater than
.resetYvel
	clr.w	Yvel(a3)	;clear Yvel
.setup
	cmpi.w	#$10,Zpos(a3)	;compare 10 hex to Zpos (feet in air)
	bgt.w	checkpuckcoll_sfx
	move.w	SCnum(a3),d0	;move SCnum into d0
	asl.w	#1,d0	;current obj number
	movea.w	#(OOlistpos-M68K_RAM),a0
	movea.w	#(OOlist-M68K_RAM),a1
	movea.w	#(Ylist-M68K_RAM),a2
	move.w	0(a0,d0.w),d1	;current obj position in OOlist
.0
	cmp.w	#$F,d1	;15 = Total sprites -1
	beq.w	.cl	;it is top sprite on screen
	clr.w	d4
	move.b	1(a1,d1.w),d4	;next higher object number
	move.w	0(a2,d4.w),d5	;Y pos of next higher object
	sub.w	Ypos(a3),d5	;sub Ypos from d5
	cmp.w	#$1D,d5	;95: $1D (94: $16 = cbody + cstick)
	bgt.w	.cl	;no higher sprite coll
	bsr.w	.ccx
	addq.w	#1,d1
	bra.s	.0
.cl
	move.w	0(a0,d0.w),d1
	beq.w	.ex
.1
	clr.w	d4
	move.b	-1(a1,d1.w),d4	;next lower object number
	move.w	Ypos(a3),d5	;move Ypos into d5
	sub.w	0(a2,d4.w),d5	;sub Y pos of next lower object
	cmp.w	#$1D,d5
	bgt.w	.ex
	bsr.w	.ccx
	subq.w	#1,d1
	bne.s	.1
.ex
	rts
.ccx
	movem.l	d0-d7/a0-a3,-(sp)
	lsr.w	#1,d4	;divide by 2
	cmp.w	(puckc).w,d4	;compare puckc to d4
	beq.w	.exit
	cmp.w	#$B,d4	;compare 11 to d4
	bgt.w	.exit
	asl.w	#7,d4	;#scsize
	movea.w	#(SortCords-M68K_RAM),a2
	adda.w	d4,a2	;a2 now has address of player struct
	btst	#2,(BA_PS_flags).w	;check bit 2
	beq.w	.ccx2	;branch if not set
	asr.w	#7,d4	;change d4 back to SCnum of puckc
	cmp.w	(BA_Sktr_SCnum).w,d4	;check d4 with SCnum of breakaway skater
	beq.w	.ccx2	;branch if the same
	cmp.w	(BA_Goalie_SCnum).w,d4	;check d4 with SCnum of breakaway goalie
	bne.w	.exit	;exit if not equal
.ccx2
	btst	#pfnc,pflags(a2)	;check if no player collision
	bne.w	.exit	;exit if set
	tst.b	nopuck(a2)	;check if nopuck collision
	bne.w	.exit	;branch if nopuck
	btst	#3,$64(a2)	;95: a one-timer keeps the long reach
	bne.w	.reach
	move.w	#$A,(ChkBodyP).w
	move.w	#$E,(ChkStickP).w
	move.w	#$FFF6,(NegChkBodyP).w
	move.w	#$FFF2,(NegChkStickP).w
	move.w	#$64,(ChkBodySqP).w
	move.w	#$C4,(ChkStickSqP).w
.reach
	btst	#2,pflags2(a2)	;check if player unavailable
	bne.w	.chkbody	;branch if so
	cmpi.w	#5,Zpos(a3)	;compare 5 to Zpos
	bgt.w	.chkbody	;branch if higher
	cmpi.w	#$200,Zvel(a3)	;compare 200 hex to Zvel
	bgt.w	.chkbody	;branch if higher
	move.l	a2,-(sp)
	bsr.w	GetHot	;Get Hot Spot d0/d1 = x/y
	btst	#3,$64(a2)	;95: half the hot spot offset in a one-timer
	beq.w	.hot
	asr.w	#1,d0
	asr.w	#1,d1
.hot
	add.w	(a2),d0	;add Xpos a2
	sub.w	(a3),d0	;sub Xpos a3
	cmp.w	(ChkStickP).w,d0	;compare to cstick
	bgt.w	.chkbody	;branch if greater
	cmp.w	(NegChkStickP).w,d0	;compare to -cstick
	blt.w	.chkbody	;branch if less than
	add.w	Ypos(a2),d1	;add Ypos a2
	sub.w	Ypos(a3),d1	;sub Ypos a3
	cmp.w	(ChkStickP).w,d1	;compare to cstick
	bgt.w	.chkbody	;branch if greater
	cmp.w	(NegChkStickP).w,d1	;compare to -cstick
	blt.w	.chkbody	;branch if less than
	muls.w	d0,d0	;square d0
	muls.w	d1,d1	;square d1
	add.l	d1,d0	;add d1 to d0
	move.l	#ChkStickSqP,d1	;cstick squared (95: the address, see above)
	tst.b	nopuck(a3)	;check nopuck - puck not ready to be caught
	ble.w	.lo	;branch if less than or equal
	lsr.w	#2,d1	;divide d1 by 4
.lo
	cmp.l	d1,d0	;compare d1 to d0
	bhi.w	.chkbody	;branch if higher
	bsr.w	puckstick
	bra.w	.exit
.chkbody
	tst.w	position(a2)	;check if goalie
	beq.w	.chkgoalie	;branch if goalie
	btst	#3,$64(a2)	;check if doing one timer
	bne.w	.exit	;exit if so
	move.w	(a2),d0	;Xpos into d0
	sub.w	(a3),d0	;sub Xpos a3
	cmp.w	(ChkBodyP).w,d0	;compare to cbody
	bgt.w	.exit	;exit if greater
	cmp.w	(NegChkBodyP).w,d0	;compare to -cbody
	blt.w	.exit	;exit if less than
	move.w	Ypos(a2),d1	;Ypos into d1
	sub.w	Ypos(a3),d1	;sub Ypos a3
	cmp.w	(ChkBodyP).w,d1	;compare cbody
	bgt.w	.exit	;exit if greater
	move.w	(NegChkBodyP).w,d1	;95: a move, not a cmp (always negative, so the blt exits)
	blt.w	.exit	;exit if less than
	muls.w	d0,d0	;square d0
	muls.w	d1,d1	;square d1
	add.l	d1,d0	;add d1 to d0
	cmp.l	(ChkBodySqP).w,d0	;compare cbody squared to d0 (95: a long read of ChkBodySqP and ChkStickSqP)
	bhi.w	.exit	;exit if higher
	bsr.w	puckbody
.exit
	movem.l	(sp)+,d0-d7/a0-a3
	rts
.cbg	;Goalie body reach by Agl/2 (words, 0-$1E)
	dc.w	$E,$10,$10,$10,$10,$11,$11,$11,$11,$11
	dc.w	$12,$12,$12,$12,$13,$13,$13,$13,$13,$13
.cbgsq	;Reach squared
	dc.w	$C4,$100,$100,$100,$A9,$121,$121,$121,$121,$121
	dc.w	$144,$144,$144,$144,$169,$169,$169,$169,$169,$169
.chkgoalie
	move.l	a0,-(sp)	;push on stack
	movea.l	#.cbg,a0
	clr.w	d0
	move.b	$68(a2),d0	;move Agl into d0
	btst	#1,(sflags8).w	;check if cwd meter broken (always is)
	bne.w	.boost
	btst	#6,(sflags7).w	;check if crowd meter currently broken
	beq.w	.joycont	;branch if not
.boost
	addq.b	#2,d0
.joycont
	lsr.w	#1,d0	;divide by 2
	btst	#pfjoycon,pflags(a2)	;check if joystick controlled
	beq.w	.anim	;branch if not
	move.w	#$F,d0	;move F into d0 (remove Agl)
	bra.w	.calcagl
.anim
	cmpi.w	#$1C54,SPA(a2)	;95: two goalie anims use the smallest reach
	beq.w	.min
	cmpi.w	#$1B7A,SPA(a2)
	bne.w	.calcagl
.min
	move.w	#0,d0
.calcagl
	add.w	d0,d0	;add d0 to itself
	btst	#0,(gmode2).w	;check if shootout
	beq.w	.maxagl	;branch if not
	tst.w	d0	;check that d0 is 0
	beq.w	.maxagl	;branch if zero
	subq.w	#2,d0	;sub 2 from d0
.maxagl
	cmp.w	#$1E,d0	;compare to 1E
	blt.w	.checkbody	;branch if less than
	move.w	#$1E,d0	;move 1E into d0
.checkbody
	move.w	0(a0,d0.w),(ChkBodyG).w
	movea.l	#.cbgsq,a0
	clr.l	(ChkBodySqG).w
	move.w	0(a0,d0.w),(ChkBodySqG+2).w
	move.w	(ChkBodyG).w,(NegChkBodyG).w
	neg.w	(NegChkBodyG).w
	btst	#1,(sflags6).w	;check if one timer
	beq.w	.2	;branch if not set
	move.w	#$C,(ChkBodyG).w
	move.l	#$90,(ChkBodySqG).w
	move.w	#$FFF4,(NegChkBodyG).w
.2
	cmpi.w	#$23E8,SPA(a2)	;check animation (pad stack; 95 has four)
	beq.w	.3	;branch if equal
	cmpi.w	#$205E,SPA(a2)
	beq.w	.3
	cmpi.w	#$200C,SPA(a2)
	beq.w	.3
	cmpi.w	#$23BE,SPA(a2)
	bne.w	.4	;branch if not equal
.3
	move.w	#$13,(ChkBodyG).w
	move.l	#$169,(ChkBodySqG).w
	move.w	#$FFED,(NegChkBodyG).w
.4
	movea.l	(sp)+,a0	;pop stack into a0
	cmpi.w	#$F,(puckz).w	;compare F to puckz
	bgt.w	.exit2	;exit if higher
	move.w	(a2),d0	;Xpos into d0
	cmpi.w	#$205E,SPA(a2)	;compare animation (pad stack)
	beq.w	.neg	;branch if equal
	cmpi.w	#$200C,SPA(a2)	;compare animation (pad stack)
	bne.w	.8	;branch if not equal
	move.w	#6,d1	;move 6 into d1
	bra.w	.5
.neg
	move.w	#$FFFA,d1	;move -6 into d1
.5
	btst	#pfgoal,pflags(a2)	;check which goal shooting at
	bne.w	.6	;branch if top
	neg.w	d1	;negate d1
.6
	btst	#0,handed(a2)	;check bit zero of handedness
	beq.w	.7	;branch if equal
	neg.w	d1	;negate d1
.7
	add.w	d1,d0	;add d1 to d0
.8
	sub.w	(a3),d0	;sub Xpos a3 from d0
	cmp.w	(ChkBodyG).w,d0	;compare to d0
	bgt.w	.exit2	;exit if greater than
	cmp.w	(NegChkBodyG).w,d0	;compare to d0
	blt.w	.exit2	;exit if less than
	move.w	Ypos(a2),d1	;move Ypos into d1
	sub.w	Ypos(a3),d1	;sub Ypos a3 from d1
	cmp.w	(ChkBodyG).w,d1	;compare to d1
	bgt.w	.exit2	;exit if greater
	cmp.w	(NegChkBodyG).w,d1	;compare to d1
	blt.w	.exit2	;exit if less than
	movem.w	d0-d1,-(sp)	;push to stack
	muls.w	d0,d0	;square d0
	muls.w	d1,d1	;square d1
	add.l	d1,d0	;add d1 to d0
	cmp.l	(ChkBodySqG).w,d0	;compare to d0
	movem.w	(sp)+,d0-d1	;pop from stack
	bhi.w	.exit2	;exit if higher
	bsr.w	puckgoalie
	bra.w	.exit
.exit2
	bclr	#2,(sflags4).w	;clear bit 2
	beq.w	.exit	;exit if it was cleared already
	move.w	(puckc).w,d0	;move puckc into d0
	cmp.w	SCnum(a2),d0	;compare SCnum to d0
	beq.w	.exit	;branch if equal
	move.w	#5,-(sp)	;sound
	jsr	(sfx).l
	bra.w	.exit

puckstick	;$7B904. IDA dc.b. puck collides with stick. a2 = player who collided, a3 = puck, d0 = distance^2 (from checkpuckcoll .ccx). A stick
	;check on the puck carrier can steal the puck (Stk rolls, smaller ranges when the carrier is in the slot, sflags6 bit 5), else a slow enough
	;puck is caught (puckglue); a one-timer shoots it (onetimershot). 95: no highlight exit for the goalie, no steal roll against SPA $B8E
	tst.w	position(a2)	;a2 = player who collided
	bne.w	.0	;95: branches to the next instruction (94 skipped the highlight check here)
.0
	bclr	#pfdoff,pflags(a2)	;clear offside bit
	move.w	(puckc).w,d1	;move puckc into d1
	bmi.w	.nosteal	;branch if no puck carrier
	asl.w	#7,d1
	movea.w	#(SortCords-M68K_RAM),a0
	adda.w	d1,a0	;a0 = Struct of puck carrier
	move.b	pflags(a0),d1
	move.b	pflags(a2),d2
	eor.w	d1,d2	;compare pflags of each player
	btst	#pfteam,d2	;check if on same team
	beq.w	rtspuck	;no stealing from teammate
	btst	#5,(sflags6).w	;check if puckc is in slot
	beq.w	.noslot	;branch if not
	cmp.l	#$40,d0
	bhi.w	rtspuck
	bra.w	.1
.noslot
	cmp.l	#$24,d0
	bhi.w	rtspuck
.1
	tst.w	position(a2)	;check if colliding player is goalie
	beq.w	.steal	;branch if goalie
	tst.w	position(a0)	;check if goalie
	beq.w	rtspuck	;no stealing from goalie
	cmpi.w	#$B8E,SPA(a0)	;95: the carrier in SPA $B8E always loses the puck
	beq.w	.steal
	move.b	stickhand(a0),d0	;Stk for puckc
	lsr.b	#1,d0	;divide by 2
	jsr	(makepde).l	;adjust for energy level
	move.w	d0,-(sp)	;push onto stack
	exg	a0,a2	;swap a2 and a0 (a0 now collider)
	move.b	stickhand(a0),d0	;Stk for collider
	lsr.b	#1,d0	;divie by 2
	jsr	(makepde).l	;adjust for energy
	exg	a0,a2	;swap back (a0 now puckc)
	neg.w	d0	;negate d0
	add.w	(sp)+,d0	;add puckc modified Stk
	addi.w	#$24,d0	;add 24 hex (36 decimal)
	jsr	(randomd0).l	;RNG
	btst	#5,(sflags6).w	;check if puckc is in slot
	beq.w	.2	;branch if not
	cmp.w	#4,d0	;compare 4 to d0
	bhi.w	rtspuck	;exit if higher (not losing puck)
	bra.w	.steal
.2
	cmp.w	#2,d0	;compare 2 to d0
	bhi.w	rtspuck	;exit if higher (not losing puck)
.steal
	move.b	stickhand(a0),d0	;Stk of puckc
	lsr.b	#1,d0	;divide by 2
	jsr	(makepde).l	;adj for energy
	addi.w	#$14,d0	;add 14 hex (20 dec)
	move.b	d0,nopuck(a0)	;move result into nopuck (cant get puck timer)
	exg	a0,a2	;swap a0 and a2 (a0 now collider)
	move.b	stickhand(a0),d0	;Stk of collider
	lsr.b	#1,d0	;divide by 2
	jsr	(makepde).l	;adj for energy
	addi.w	#$14,d0	;add 14 hex (20 dec)
	move.b	d0,nopuck(a0)	;move result into nopuck
	exg	a0,a2	;swap back
	move.w	SCnum(a0),(lastplayer).w	;SCNum of puckc into lastplayer
	bclr	#sfspdir,(sflags).w	;clear pass dir mode
	bclr	#sfssdir,(sflags).w	;clear shot dir mode
.stdef
	move.w	#6,-(sp)	;#SFXstdef
	jsr	(sfx).l
	jsr	(a2touchpuck).l
	bra.w	deflect
.nosteal
	tst.w	position(a2)	;check if goalie
	bne.w	.onetimerchk	;branch if not
	cmp.l	#$40,d0
	bhi.w	rtspuck	;smaller range for stealing puck
.onetimerchk
	btst	#3,$64(a2)	;check if onetimer
	beq.w	.nosteal2	;branch if not
	cmp.l	#$100,d0	;95: $100 (94: $64)
	bhi.w	.3
	cmpi.w	#$18,SPAnum(a2)
	bge.w	.nosteal2
	move.w	#$18,SPAnum(a2)
	bset	#7,(sflags8).w
.nosteal2
	move.w	(puckvx).w,d0
	move.w	(puckvy).w,d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	clr.w	d1
	btst	#sf2shot,(sflags2).w	;check if shot was taken
	bne.w	.nohand	;branch if so
	btst	#3,$64(a2)	;check if one timer
	bne.w	.onetimer	;branch if so
	move.b	stickhand(a2),d1
	mulu.w	#$15E,d1
.nohand
	addi.w	#$32C8,d1
	mulu.w	d1,d1
	cmp.l	d1,d0
	bls.w	puckglue
	move.b	#8,nopuck(a2)
	bra.w	.stdef
.onetimer
	exg	a2,a3
	jsr	(onetimershot).l
	exg	a2,a3
	rts
.3
	cmp.l	#$144,d0
	bhi.w	.ex2
	cmpi.w	#$18,SPAnum(a2)
	bge.w	.ex2
	move.w	#$18,SPAnum(a2)
.ex2
	rts

puckglue	;$7BAB2. IDA dc.b. 93 name. Player a2 takes the puck (92 puckstick .glue): faceoff and pass stats, crowd song, goalie hold time (temp5),
	;then .setd0player. 95 also sets pflags2 bit 7 on a2
	move.w	#7,-(sp)	;SFXpuckget (song)
	move.w	SCnum(a2),d0	;move SCnum into d0
	move.w	d0,(puckc).w	;move d0 into puckc
	bset	#7,pflags2(a2)
	movea.w	#(HmShots-M68K_RAM),a0	;Move Home Stats struct into a0
	lea	tmsize(a0),a1	;tmsize
	btst	#pfteam,pflags(a2)	;check if player is home or away
	bne.w	.tm	;branch if away
	exg	a0,a1	;swap struct addresses
.tm
	st	$1A(a0)	;FF into assist 1
	st	$1C(a0)	;FF into assist 2
	bset	#3,tmflags(a0)	;set a flag (not sure what)
	bclr	#4,(sflags3).w	;clear flag (not sure what, might have to do with faceoff)
	beq.w	.snd	;branch if it was cleared already
	addq.w	#1,$E(a1)	;add 1 to faceoff won
	addi.w	#$C8,(crowdlevel).w	;add to crowdlevel
	move.w	#$C,(sp)	;move C to stack
	cmpa.w	#(HmShots-M68K_RAM),a1	;compare if a1 is home
	bne.w	.snd	;branch if not
	addi.w	#$A,(CwdExciteLvl).w	;add to CwdExciteLvl
	move.w	#$B,(sp)	;Move B into stack
.snd
	jsr	(song).l
	move.w	SCnum(a2),d0	;move SCnum into d0
	cmp.w	(passplayer).w,d0	;compare to d0
	bne.w	.nrec	;branch if not equal
	addq.w	#1,$14(a1)	;add 1 to pass completed
.nrec
	st	(passplayer).w	;set to FFFF
	bclr	#sfspdir,(sflags).w	;clear pass dir mode
	bclr	#sfssdir,(sflags).w	;clear shot dir mode
	tst.w	position(a2)	;check if a2 is goalie
	bne.w	.setd0player	;branch if not
	jsr	(ChkShotStat).l
	move.w	#$8C,temp5(a2)	;move 8C to temp5 - countdown for faceoff?
	cmpi.w	#$1D4E,SPA(a2)	;goalie dive animation (94 SPAgdive)
	bne.w	.setd0player	;branch if not equal
	move.w	#5,temp5(a2)	;set temp5 to 5
.setd0player	;93 setd0player. Give control of player d0 to a controller if his team is controlled. 95 tries the pad that had lastplayer first
	cmp.w	(c1playernum).w,d0
	beq.w	rtspuck	;exit if player controlled
	cmp.w	(c2playernum).w,d0
	beq.w	rtspuck	;exit if player controlled
	cmp.w	(c3playernum).w,d0
	beq.w	rtspuck	;exit if player controlled
	cmp.w	(c4playernum).w,d0
	beq.w	rtspuck	;exit if player controlled
	movem.l	d0/a3,-(sp)
	asl.w	#7,d0
	movea.l	#SortCords,a3
	tst.w	$34(a3,d0.w)	;check if goalie
	bne.w	.2	;branch if not
	btst	#pfjoycon,$62(a3,d0.w)	;check if d0 player controlled
	beq.w	.2	;branch if not
	movem.l	(sp)+,d0/a3	;exit if player controlled
	rts
.2
	movem.l	(sp)+,d0/a3
	cmp.w	#6,d0
	slt	d1
	ext.w	d1
	addq.w	#2,d1	;d1 = team of player d0 (1 home, 2 away)
	move.w	(lastplayer).w,d2
	cmp.w	(c1playernum).w,d2
	beq.w	.c1
	cmp.w	(c2playernum).w,d2
	beq.w	.c2
	cmp.w	(c3playernum).w,d2
	beq.w	.c3
	cmp.w	(cont4team).w,d1
	bne.w	.40
	jmp	(setc4player).l
.40
	cmp.w	(cont1team).w,d1
	bne.w	.41
	jmp	(setc1player).l
.41
	cmp.w	(cont2team).w,d1
	bne.w	.42
	jmp	(setc2player).l
.42
	cmp.w	(cont3team).w,d1
	bne.w	rtspuck
	jmp	(setc3player).l
.c3
	cmp.w	(cont3team).w,d1
	bne.w	.30
	jmp	(setc3player).l
.30
	cmp.w	(cont1team).w,d1
	bne.w	.31
	jmp	(setc1player).l
.31
	cmp.w	(cont2team).w,d1
	bne.w	.32
	jmp	(setc2player).l
.32
	cmp.w	(cont4team).w,d1
	bne.w	rtspuck
	jmp	(setc4player).l
.c2
	cmp.w	(cont2team).w,d1
	bne.w	.20
	jmp	(setc2player).l
.20
	cmp.w	(cont1team).w,d1
	bne.w	.21
	jmp	(setc1player).l
.21
	cmp.w	(cont3team).w,d1
	bne.w	.22
	jmp	(setc3player).l
.22
	cmp.w	(cont4team).w,d1
	bne.w	rtspuck
	jmp	(setc4player).l
.c1
	cmp.w	(cont1team).w,d1
	bne.w	.10
	jmp	(setc1player).l
.10
	cmp.w	(cont2team).w,d1
	bne.w	.11
	jmp	(setc2player).l
.11
	cmp.w	(cont3team).w,d1
	bne.w	.12
	jmp	(setc3player).l
.12
	cmp.w	(cont4team).w,d1
	bne.w	rtspuck
	jmp	(setc4player).l

puckbody	;$7BCA8. IDA dc.b. puck hits player a2. a3 = puck, d0 = distance^2 (from checkpuckcoll .ccx). The puck bounces off. A high puck
	;(Zpos > 8) that is fast makes a2 fall (FallDown, Zpos > $C); a slower one starts SPA $2402 (94 SPAcatch) on a2
	btst	#3,$64(a2)
	bne.w	rtspuck
	cmpi.w	#8,Zpos(a3)
	bgt.w	.hit
	move.w	d0,d1
	andi.w	#$F,d1
	bne.w	rtspuck
.hit
	jsr	(a2touchpuck).l
	move.w	#$24,-(sp)	;SFXpuckbody
	jsr	(sfx).l
	clr.w	Zvel(a3)
	move.b	#8,nopuck(a2)
	move.w	(a3),d0
	sub.w	(a2),d0
	move.w	Ypos(a3),d1
	sub.w	Ypos(a2),d1
	bne.w	.0
	move.l	a2,-(sp)
	bsr.w	GetHot
.0
	move.w	Xvel(a3),d2
	move.w	Yvel(a3),d3
	move.b	d0,Xvel(a3)
	move.b	d1,Yvel(a3)
	jsr	(puckflip).l
	cmpi.w	#8,Zpos(a3)
	ble.w	rtspuck
	muls.w	d2,d2
	muls.w	d3,d3
	add.l	d3,d2
	cmp.l	#$9000000,d2	;fast puck
	bls.w	.1
	cmpi.w	#$C,Zpos(a3)
	bgt.w	FallDown
	rts
.1
	bset	#pfalock,pflags(a2)
	bne.w	rtspuck
	move.w	#$2402,d1	;94 SPAcatch
	exg	a2,a3
	jsr	(SetSPA).l
	exg	a2,a3
rtspuck	;IDA: locret_7BD4A. Shared rts in the 94 rtss2 place (after puckbody), branched to from this segment
	rts

deflect	;$7BD4C. IDA dc.b. random puck direction on deflection, puck = a3. Entered from puckstick. 95: Zvel = randomd0($400)
	st	(puckc).w
	move.w	#$1000,d0
	bsr.w	randomd0s
	move.w	d0,Yvel(a3)
	move.w	#$1000,d0
	bsr.w	randomd0s
	move.w	d0,Xvel(a3)
	move.w	#$400,d0
	bsr.w	randomd0
	move.w	d0,Zvel(a3)
	jmp	(puckflip).l

checkpuckcoll_sfx	;$7BD78. IDA dc.b. Puck in the air: sfx 5 once when sflags4 bit 2 is set. Entered from checkpuckcoll
	bclr	#2,(sflags4).w
	beq.s	rtspuck
	move.w	#5,-(sp)
	jmp	(sfx).l

checkgoal	;IDA: sub_7BD8C. look for coll with goal/net. a2 = goal struct, a3 = object, d2/d3 = x/y. A puck under the crossbar hits a post or the net
	;(ChkShotStat, sfx $25 or 8 and crowd) or goes in (Goal); a player goes to checkgoalp. Called from checkwallcoll
	cmpi.w	#$D,Zpos(a3)
	bgt.w	.8
	cmpi.w	#$E,SCnum(a3)
	bne.w	checkgoalp
	sub.w	(a2),d2
	moveq	#$C,d4
	add.w	(wcradiusx).w,d4
	cmp.w	d4,d2
	bgt.w	.8
	neg.w	d4
	cmp.w	d4,d2
	blt.w	.8
	sub.w	Ypos(a2),d3
	move.w	#6,d5
	add.w	(wcradiusy).w,d5
	cmp.w	d5,d3
	bgt.w	.8
	neg.w	d5
	cmp.w	d5,d3
	blt.w	.8
	st	(collflag).w
	cmpi.w	#$D,OldZpos(a3)
	blt.w	.0
	move.w	OldZpos(a3),Zpos(a3)
	bra.w	.7
.0
	bclr	#pfgoal,pflags(a3)
	move.w	(puckc).w,d0
	bmi.w	.2
	st	(puckc).w
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a0
	move.b	#8,$5E(a0,d0.w)
	move.w	(pucky).w,d1
	btst	#7,$62(a0,d0.w)
	bne.w	.1
	neg.w	d1
.1
	tst.w	d1
	bpl.w	.2
	bset	#pfgoal,pflags(a3)
.2
	move.w	#$FF00,d0
	move.l	Ypos(a3),d1
	sub.l	OldYpos(a3),d1
	asr.l	#8,d1
	beq.w	.9
	bmi.w	.3
	neg.w	d0
	neg.w	d5
.3
	add.w	d3,d5
	move.l	(a3),d3
	sub.l	OldXpos(a3),d3
	asr.l	#8,d3
	muls.w	d3,d5
	divs.w	d1,d5
	bvs.w	.9
	sub.w	d5,d2
	cmp.w	d4,d2
	blt.w	.9
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.9
	clr.w	d1
	move.w	Ypos(a3),d3
	eor.w	d0,d3
	bmi.w	wallcoll
	neg.w	d0
	btst	#pfgoal,pflags(a3)
	bne.w	wallcoll
	cmpi.w	#$D,Zpos(a3)
	beq.w	.4
	subq.w	#1,d4
	cmp.w	d4,d2
	bgt.w	.4
	neg.w	d4
	cmp.w	d4,d2
	blt.w	.4
	jmp	(Goal).l
.4
	jsr	(ChkShotStat).l
	move.w	#$25,-(sp)
	btst	#gmclock,(gmode).w
	bne.w	.5
	move.w	#8,(sp)
	addi.w	#$12C,(crowdlevel).w
	addi.w	#$28,(CwdExciteLvl).w
.5
	jsr	(sfx).l
	move.w	#$1000,d0
	jsr	(randomd0).l
	tst.w	Ypos(a3)
	bmi.w	.6
	neg.w	d0
.6
	move.w	d0,Yvel(a3)
	move.w	#$1000,d0
	jsr	(randomd0s).l
	move.w	d0,Xvel(a3)
	move.w	#$1000,d0
	jsr	(randomd0s).l
	move.w	d0,Zvel(a3)
	jmp	(puckflip).l
.7
	neg.w	Zvel(a3)
	bpl.w	.8
	neg.w	Zvel(a3)
.8
	rts
.9
	clr.w	d0
	move.w	#$100,d1
	move.w	(a3),d2
	sub.w	OldXpos(a3),d2
	bmi.w	wallcoll
	neg.w	d1
	bra.w	wallcoll

checkgoalp	;IDA: loc_7BF1E. check for player a3 collision with goal/net a2. Entered from checkgoal. Oval goal (95: $640 by $121, 94: $400 by $79);
	;skipped for no player coll (pflags2 bit 5), a high player or a non-player. CheckBump, then wallcoll with sflags6 bit 4 set
	btst	#5,pflags2(a3)
	bne.w	.1
	cmpi.w	#$A,Zpos(a3)
	bgt.w	.1
	cmpi.w	#$B,SCnum(a3)
	bgt.w	.1
	movem.w	d2-d3,-(sp)
	sub.w	Ypos(a2),d3
	move.w	d3,d0
	sub.w	(a2),d2
	move.w	d2,d1
	neg.w	d0
	asl.w	#4,d2
	muls.w	d2,d2
	divu.w	#$640,d2
	cmp.w	#$100,d2
	bhi.w	.0
	asl.w	#4,d3
	muls.w	d3,d3
	divu.w	#$121,d3
	add.w	d2,d3
	cmp.w	#$100,d3
	bhi.w	.0
	movem.w	(sp)+,d2-d3
	bsr.w	CheckBump
	movem.w	d2-d3,-(sp)
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	bsr.w	sroot
	move.w	d0,d2
	movem.w	(sp)+,d0-d1
	addq.w	#1,d2
	asl.l	#8,d0
	divs.w	d2,d0
	asl.l	#8,d1
	divs.w	d2,d1
	bset	#4,(sflags6).w
	bsr.w	wallcoll
	bclr	#4,(sflags6).w
.0
	movem.w	(sp)+,d2-d3
.1
	rts

CheckBump	;IDA: sub_7BFAE. supply minimum separation velocity for coll with walls/goal/net. a2 = goal, a3 = player. On one frame in 32, a player
	;near the puck in y moving faster than $24CC knocks the net (a2 gets a quarter of a3's velocity, a3 stops, scroll lock at Vpos) and, while the
	;clock runs, calls penalty 8. Called from checkgoalp
	movem.l	d0-d1,-(sp)
	move.w	(VDP_CNTR).l,d0
	andi.w	#$1F,d0
	bne.w	.0
	move.w	(pucky).w,d0
	sub.w	Ypos(a2),d0
	cmp.w	#$28,d0
	bgt.w	.0
	cmp.w	#$FFD8,d0
	blt.w	.0
	move.w	Xvel(a3),d0
	move.w	Yvel(a3),d1
	cmp.w	#$24CC,d0
	bgt.w	.1
	cmp.w	#$DB34,d0
	blt.w	.1
	cmp.w	#$24CC,d1
	bgt.w	.1
	cmp.w	#$DB34,d1
	blt.w	.1
.0
	movem.l	(sp)+,d0-d1
	rts
.1
	adda.w	#$C,sp
	asr.w	#2,d0
	asr.w	#2,d1
	move.w	d0,Xvel(a2)
	move.w	d1,Yvel(a2)
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	move.w	(Vpos).w,(yc1).w
	bset	#sfslock,(sflags).w
	btst	#gmclock,(gmode).w
	bne.w	.2
	move.l	#8,d0
	jmp	(AddPenalty2).l
.2
	rts

wallcollduringcheck	;IDA: sub_7C042 (cards94). during a check, a skater a2 (not a goalie) near the wall: test the wall at his position with his size +
	;$17 (checkcornercoll94). Called from CCStart and FallDown
	tst.w	position(a2)
	beq.w	.0
	movem.l	d0-d7,-(sp)
	move.w	(a2),d2
	move.w	Ypos(a2),d3
	move.w	radiusx(a2),(wcradiusx).w
	addi.w	#$17,(wcradiusx).l
	move.w	radiusy(a2),(wcradiusy).w
	addi.w	#$17,(wcradiusy).l
	movem.l	a0-a6,-(sp)
	exg	a2,a3
	jsr	(checkcornercoll94).l
	exg	a2,a3
	movem.l	(sp)+,a0-a6
	movem.l	(sp)+,d0-d7
.0
	rts

checkcornercoll94	;IDA: sub_7C088 (crowd94). Corner circles and side walls for object a3 at d2 / d3 (wcradiusx / wcradiusy); a hit goes to
	;cornercollb94. 95: end boards $128
	bclr	#4,$64(a3)
	move.w	#$98,d4
	sub.w	(wcradiusx).w,d4
	move.w	#$128,d5
	sub.w	(wcradiusy).w,d5
	movem.w	d2-d5,-(sp)
	neg.w	d4
	neg.w	d5
	addi.w	#$40,d4
	addi.w	#$40,d5
	cmp.w	d5,d3
	bgt.w	.0
	cmp.w	d4,d2
	blt.w	.1
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.1
	bra.w	.2
.0
	neg.w	d5
	cmp.w	d5,d3
	blt.w	.2
	cmp.w	d4,d2
	blt.w	.1
	neg.w	d4
	cmp.w	d4,d2
	bgt.w	.1
	bra.w	.2
.1
	sub.w	d4,d2
	sub.w	d5,d3
	move.w	d3,d0
	move.w	d2,d1
	neg.w	d1
	muls.w	d3,d3
	muls.w	d2,d2
	add.l	d2,d3
	cmp.l	#$1000,d3
	bls.w	.2
	exg	d0,d3
	jsr	(sroot).l
	exg	d0,d3
	ext.l	d0
	asl.l	#8,d0
	divs.w	d3,d0
	ext.l	d1
	asl.l	#8,d1
	divs.w	d3,d1
	bsr.w	cornercollb94
.2
	movem.w	(sp)+,d2-d5
	move.w	Wallcos(a3),d0
	or.w	Wallsin(a3),d0
	bne.w	.3
	move.w	#$100,d0
	clr.w	d1
	cmp.w	d5,d3
	bge.w	cornercollb94
	neg.w	d5
	neg.w	d0
	cmp.w	d5,d3
	ble.w	cornercollb94
	exg	d0,d1
	cmp.w	d4,d2
	bge.w	cornercollb94
	neg.w	d4
	neg.w	d1
	cmp.w	d4,d2
	ble.w	cornercollb94
.3
	rts

cornercollb94	;IDA: sub_7C14E (crowd94). 95: straight to wallcollb
	jmp	(wallcollb).l


puckgoalie	;$7C154. IDA dc.b. puck hits goalie a2. a3 = puck, d0/d1 = goalie - puck x/y. A save bounces the puck off (.bounceoff), a slow puck
	;near the crease is held (puckglue). 95 picks the save attribute (.list) but no longer reads the save odds from the frame tables
	;(.list2 is left unread)
	btst	#gmhl,(gmode).w	;check if highlight
	bne.w	rtss2	;exit if highlight
	clr.w	d2	;puck region
	cmpi.w	#8,Zpos(a3)	;compare to Zpos
	bgt.w	.1
	addq.w	#2,d2	;add 2 to d2
.1
	neg.w	d0	;negate d0
	neg.w	d1	;negate d1
	bsr.w	vtoa	;convert directions
	sub.w	facedir(a2),d0	;sub facedir into d0
	andi.w	#7,d0	;pass first 3 bits to d0
	;0 = puck straight in front of G
	;1-3 = puck to G right
	;4 = puck straight behind G
	;5-7 = puck to G left
	move.w	d0,d1	;move d0 into d1
	andi.w	#3,d1	;pass first 2 bits of d1
	bne.w	.2	;will branch if puck is to the left or right of G
	move.w	(VDP_CNTR).l,d0	;just for random bit
.2
	andi.w	#4,d0	;pass 3rd bit of d0. d0 will be either 4 (left) or 0 (right)
	lsr.w	#2,d0	;divide by 4. d0 will be either 1 (left) or 0 (right)
	eori.w	#1,d0	;XOR d0 - will make 1 a 0 (left), and 0 a 1 (right)
	add.w	d0,d2	;add to d2. d2 will now be 0 or 1 (Zpos > 8) or 2 or 3 (Zpos <= 8)
	add.w	d2,d2	;add d2 to itself. 0 Glove L, 2 Glove R, 4 Stick L, 6 Stick R
	lea	.list(pc),a0	;contains offsets for save attributes
	move.w	0(a0,d2.w),d0	;move from list into d0
	moveq	#$F,d1	;move F into d1
	add.b	0(a2,d0.w),d1	;save odds = save attribute + F (15 dec)
	lea	.list2(pc),a0
	btst	#3,attribute(a2)	;attribute a2 - x flip?
	beq.w	.3
	eori.w	#2,d2	;XOR d2 with 2
.3
	move.w	frame(a2),d0	;move frame into d0 (95: not used)
	bclr	#2,(sflags4).w	;clear bit 2 - this is not used anywhere, might have been a debug flag
	jsr	(ChkShotStat).l
	jsr	(a2touchpuck).l
	cmpi.w	#$3000,(puckvy).w	;compare with puck velocity y
	bgt.w	.setsfx	;branch if greater
	cmpi.w	#$D000,(puckvy).w	;compare -3000 with puckvy
	bgt.w	.nosong	;branch if greater
.setsfx
	move.w	#$B,-(sp)	;home song
	btst	#pfteam,pflags(a2)	;check home or away
	beq.w	.song	;branch if home
	move.w	#$D,(sp)	;away song
.song
	jsr	(song).l
.nosong
	move.w	#$24,-(sp)	;#SFXpuckbody
	jsr	(sfx).l
	move.w	(puckc).w,d2	;move puckc into d2
	bmi.w	.chkanim	;branch if no puckc
	st	(puckc).w
	asl.w	#7,d2
	movea.w	#(SortCords-M68K_RAM),a0
	adda.w	d2,a0
	move.b	#$14,nopuck(a0)
	move.w	SCnum(a0),(lastplayer).w
	bclr	#sfspdir,(sflags).w
	bclr	#sfssdir,(sflags).w
.bounceoff
	clr.w	Zvel(a3)	;clear puck Zvel
	move.b	#$A,nopuck(a2)	;move A into nopuck collision
	move.w	#4,temp4(a2)	;move 4 into temp4
	move.w	(a3),d0	;move puck Xpos into d0
	sub.w	(a2),d0	;sub Xpos of goalie from d0
	move.w	Ypos(a3),d1	;move puck Ypos into d1
	sub.w	Ypos(a2),d1	;sub Ypos of goalie from d1
	bne.w	.0	;branch if not equal
	move.l	a2,-(sp)	;pop onto stack
	bsr.w	GetHot
.0
	move.b	d0,Xvel(a3)	;move d0 into puck Xvel
	move.b	d1,Yvel(a3)	;move d1 into puck Yvel
	jmp	(puckflip).l	;flip puck
	bset	#2,(sflags4).w	;not reached (after jmp puckflip)
	rts
.chkanim
	cmpi.w	#$1D4E,SPA(a2)	;goalie dive animation (94 SPAgdive)
	beq.s	.bounceoff	;branch if equal
	cmpi.w	#$1C86,SPA(a2)	;95: two more goalie anims bounce the puck
	beq.s	.bounceoff
	cmpi.w	#$2AE4,SPA(a2)
	beq.s	.bounceoff
	moveq	#2,d0	;move 2 into d0
	add.b	shotspd(a2),d0	;add puck control to d0
	asl.w	#8,d0	;mult by 256
	asl.w	#1,d0	;mult by 2
	bsr.w	randomd0	;random
	addi.w	#$C00,d0	;add C00 to d0
	cmpi.w	#$23E8,SPA(a2)	;95: more in SPA $23E8
	bne.w	.dbl
	addi.w	#$300,d0
.dbl
	add.w	d0,d0	;double d0
	bpl.w	.pos	;branch if positive
	move.w	#$7FFF,d0	;make max positive
.pos
	btst	#1,pflags2(a2)	;check if in animation
	bne.w	.chkpuckv	;branch if so
	cmpi.w	#$2C,(a3)	;compare 2C to Xpos of puck
	bgt.w	.chkpuckv	;branch if greater than
	cmpi.w	#$FFD4,(a3)
	blt.w	.chkpuckv	;branch if less than -2C
	cmpi.w	#$111,Ypos(a3)	;compare 111 to puck Ypos (94: $10E)
	bgt.w	.chkpuckv	;branch if greater than
	cmpi.w	#$FEEF,Ypos(a3)	;compare to -111
	blt.w	.chkpuckv	;branch if less than
	cmpi.w	#$D5,Ypos(a3)	;compare D5 to Ypos (94: $D2)
	bgt.w	.closepuck	;branch if greater than
	cmpi.w	#$FF2B,Ypos(a3)	;compare -D5 to Ypos
	bgt.w	.chkpuckv	;branch if greater than
.closepuck
	asr.w	#2,d0	;divide by 4
.chkpuckv
	cmp.w	(puckvx).w,d0	;compare puckvx with d0
	blt.w	.bounceoff	;branch if less than
	cmp.w	(puckvy).w,d0	;compare puckvy to d0
	blt.w	.bounceoff	;branch if less than
	neg.w	d0	;negate d0, compare if shot going down
	cmp.w	(puckvx).w,d0
	bgt.w	.bounceoff	;branch if greater than
	cmp.w	(puckvy).w,d0
	bgt.w	.bounceoff	;branch if greater than
	btst	#2,pflags2(a2)	;check if player unavailable
	bne.w	.bounceoff	;branch if so
	clr.w	Zvel(a3)	;clear puck Zvel
	bra.w	puckglue
.list	;Save attribute offsets: GGSleft, GGSright, GSSleft, GSSright
	dc.w	$73,$6E,$70,$72
.list2	;2 bit save odds per quadrant, one byte per goalie frame (93 / 94 table; 95 does not read it)
	dc.b	$55,$9D,$67,$55,$9D,$67,$55,$9D,$67,$55,$9D,$67,$55,$9D,$67,$55
	dc.b	$9D,$67,$55,$9D,$67,$55,$9D,$67,$55,$55,$55,$55,$55,$55,$55,$55
	dc.b	$55,$55,$55,$55,$55,$55,$55,$55,$55,$F0,$55,$F0,$55,$F0,$55,$F0
	dc.b	$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0,$55,$F0
	dc.b	$D5,$75,$D5,$75,$D5,$75,$D5,$75,$D5,$75,$D5,$75,$D5,$75,$D5,$75
	dc.b	$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	dc.b	$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55,$55
	dc.b	$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$F0
	dc.b	$57,$57,$57,$57,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5
	dc.b	$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$A5,$9D,$67,$9D,$67
	dc.b	$9D,$67,$9D,$67,$9D,$67,$9D,$67,$9D,$67,$9D,$67,$D5,$D5,$75,$75
	dc.b	$D5,$D5,$75,$75,$D5,$D5,$75,$75,$D5,$D5,$75,$75,$D5,$D5,$75,$75
	dc.b	$D5,$D5,$75,$75,$D5,$D5,$75,$75,$D5,$D5,$75,$75

checkint	;IDA: sub_7C3FC. check for interference penalty. player a2 interferes with a3 or vice-versa; goalie is only player who can cause an
	;interference call. Called from checkcx. .ci (IDA sub_7C40E): a2 = goalie, a3 = player interfering with goalie. a3 falls. The penalty ($22)
	;needs a3 in the crease area, a CPU player or a pad player's joystick player, and randomd0($1E - aggres) <= 5
	move.l	d0,-(sp)
	bsr.w	.1
	exg	a2,a3
	bsr.w	.1
	exg	a2,a3
	move.l	(sp)+,d0
.0
	rts
.1
	tst.w	position(a2)
	bne.s	.0
	btst	#gmclock,(gmode).w
	bne.s	.0
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	beq.w	.2
	cmpi.w	#$19,impact(a3)
	ble.s	.0
.2
	cmpi.w	#2,impact(a3)
	ble.s	.0
	exg	a2,a3
	bsr.w	FallDown
	exg	a2,a3
	cmpi.w	#$1A,impact(a2)
	ble.s	.0
	btst	#4,pflags2(a3)
	bne.w	.7
	tst.w	position(a2)
	bne.w	.7
	move.w	#1,d0
	btst	#pfteam,pflags(a3)
	beq.w	.3
	move.w	#2,d0
.3
	cmp.w	(cont1team).w,d0
	beq.w	.4
	cmp.w	(cont2team).w,d0
	beq.w	.4
	cmp.w	(cont3team).w,d0
	beq.w	.4
	cmp.w	(cont4team).w,d0
	bne.w	.5
.4
	btst	#pfjoycon,pflags(a3)
	beq.w	.7
.5
	move.w	Ypos(a2),d0
	btst	#pfgoal,pflags(a2)
	beq.w	.6
	neg.w	d0
.6
	cmp.w	#$EF,d0
	blt.w	.7
	cmp.w	#$10A,d0
	bgt.w	.7
	move.w	(a2),d0
	cmp.w	#$14,d0
	bgt.w	.7
	cmp.w	#$FFEC,d0
	blt.w	.7
	move.w	#$1E,d0
	sub.b	$73(a3),d0
	jsr	(randomd0).l
	cmp.w	#5,d0
	bhi.w	.7
	btst	#gmhl,(gmode).w
	bne.w	.7
	move.l	#$22,d0
	jmp	(AddPenalty).l
.7
	rts

DropPuck	;IDA: sub_7C4F6. 95 only. a2 loses the puck (puckc = -1 if he had it) and cannot touch it for $1E frames. Called from FallDown
	move.w	d0,-(sp)
	move.w	SCnum(a2),d0
	cmp.w	(puckc).w,d0
	bne.w	.0
	st	(puckc).w
.0
	move.b	#$1E,nopuck(a2)
	move.w	(sp)+,d0
	rts