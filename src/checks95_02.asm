;	NHL 95 checks95_02. Retail $080BEA-$08282D (7236 bytes).
;	94 checks94 asswingo, asscenterd, asscentero, assign94 assdefo and assnothing (moved in), checks94 pucknorm, puckunflip, puckflip,
;	puckshadow, findpc, a2touchpuck, collide94 Setplass (moved in), checks94 assexit / assinsert / assreplace, EvadePC, skateto,
;	check4check (and the 95 check4check2), asspassrec / SkateToTempTarget, assbreakaway, assnearest, skatetopuckinit, skatetopuck,
;	avdgoal, breakaway / BreakawayOffsidesFlagSet, chkpuckc, asspuckc, chk4shot, chk4pass, then input94 check4bench (moved in).
;	checks95_03 follows at $08282E.
;	IDA left nearly the whole range as dc.b (unk_80742 to $81335, $8158E-$81A5B, $81A5E-$82E87); it is code here, read from the retail
;	bytes with the 94 source as the guide. IDA code: puckflip (sub_81336), Setplass (sub_81540), assexit / assinsert / assreplace.
;	95 changes, besides the moves: the 95 asstab numbers (assreplace / assinsert d0, .alist, the asslist compares; the comments give the
;	94 number), jsr / jmp .l to the routines 95 moved out of range, the y limits moved 2 or 3 out (blue line $58 to $56, goal line $108
;	to $10B; the comments give the 94 values), the team defense mode code (HmDefMode / AwDefMode: asscenterd .cover), Practice Mode
;	(sflags9 bit 7) shortcuts, the 95 checking start for joystick players (check4check), and the shared rts labels rtss6 / rtsskate /
;	rtsskateto in place of rtss2.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

asswingo	;no IDA label (IDA dc.b), asstab entry 9. Winger on offense: a random spot in the puck zone (.dedata). 95: a new spot each time with sflags2 bit 7, and then y at most $4C, else $1E further up
	btst	#pfalock,pflags(a3)	;check if locked in animation
	bne.w	rtss21	;exit if so
	btst	#gmclock,(gmode).w	;check game clock
	bne.w	assnothing	;assnothing if stopped
	bsr.w	check4bench	;check if player going to bench
	btst	#pfjoycon,pflags(a3)	;check if joystick controlled
	bne.w	rtss21	;exit if so
	bclr	#pfna,pflags(a3)	;clear new assignment bit
	beq.w	.nna	;branch if it was already cleared
	st	temp5(a3)	;set old zone # (temp5)
	clr.w	temp1(a3)	;clear temp1
	move.w	#8,temp2(a3)	;move 8 into temp2
.nna
	sub.b	d7,temp1(a3)	;subtract frames elapsed from temp1
	bpl.w	.nodec	;branch if positive
	move.b	aidef(a3),temp1(a3)	;move DfA into temp1
	btst	#6,(sflags7).w	;check if crowd meter currently broken
	beq.w	.noboost
	tst.b	$40(a3)	;check if temp1 is 0
	beq.w	.noboost
	subq.b	#1,$40(a3)	;subtract 1 from temp1
.noboost
	moveq	#8,d0	;asswingd (94 3)
	move.w	(puckc).w,d1	;move puckc SCnum into d1
	bmi.w	.de0	;branch if no puckc
	subq.w	#6,d1	;sub 6 from d1
	move.w	SCnum(a3),d2	;move SCnum into d2
	subq.w	#6,d2	;sub 6 from d2
	eor.w	d2,d1	;EOR d2 with d1. Checks if puckc on same team
	bmi.w	assreplace	;if not, branch to assreplace
.de0
	move.w	(pucky).w,d0	;pucky into d0
	move.w	(puckvy).w,d3	;puckvy into d3
	asr.w	#6,d3	;divide d3 by 64
	add.w	d0,d3	;add d0 to d3
	btst	#pfgoal,pflags(a3)	;check which goal shooting on
	bne.w	.de1	;branch if top goal
	neg.w	d0	;negate d0
	neg.w	d3	;negate d3
.de1
	clr.w	d2	;clear zone number
	cmp.w	#$FFAA,d3	;compare bottom blue line with d3 (94 $FFA8)
	blt.w	.de2	;branch if in defensive zone
	addq.w	#8,d2	;add 8 to d2 (d2 = 8)
	cmp.w	#$56,d0	;compare top blue line with d0 (94 $58)
	blt.w	.de2	;branch if in neutral zone
	btst	#4,tmflags(a2)	;check bit 4 of offset 30 (currently offside)
	;(C6FE Home, CA62 Away)
	bne.w	.de2	;branch if set
	addq.w	#8,d2	;add 8 to d2 (d2 = $10)
	cmp.w	#$10B,d3	;compare top goal line with d3 (94 $108)
	blt.w	.de2	;branch if in offensive zone
	addq.w	#8,d2	;add 8 to d2 (d2 = $18)
.de2
	cmp.w	temp5(a3),d2	;compare temp5 with d2
	bne.w	.de3	;branch if different zone
	btst	#7,(sflags2).w	;95: a new spot every time with sflags2 bit 7
	bne.w	.de3
	move.w	(VDP_CNTR).l,d0	;move frame counter into d0
	andi.w	#$7F,d0	;pass first 7 bits
	bne.w	.nodec	;branch if not equal to 0 - this allows random movement in zone while waiting
.de3
	move.w	d2,temp5(a3)	;move d2 into temp5
	lea	.dedata(pc),a0	;move zonedata address into a0
	move.w	2(a0,d2.w),d0	;move X Coord into d0
	jsr	(randomd0s).l	;RNG d0
	add.w	0(a0,d2.w),d0	;add X Coord offset to d0
	move.w	d0,temp3(a3)	;move d0 into temp3
	move.w	6(a0,d2.w),d0	;move Y Coord into d0
	jsr	(randomd0s).l	;RNG d0
	add.w	4(a0,d2.w),d0	;add Y Coord offset into d0
	btst	#7,(sflags2).w	;95: with sflags2 bit 7 at most $4C, else $1E further up
	beq.w	.de4
	cmp.w	#$4C,d0
	blt.w	.de4
	move.w	#$4C,d0
.de4
	btst	#7,(sflags2).w
	bne.w	.de5
	addi.w	#$1E,d0
.de5
	move.w	d0,temp4(a3)	;move d0 into temp4
	bra.w	.nodec
.dedata
	dc.w	$50	;Skating zones:
	;Defensive zone
	dc.w	$14
	dc.w	$FFBA
	dc.w	$A
	dc.w	$64	;neutral zone
	dc.w	$14
	dc.w	$38	;94 $3A
	dc.w	5
	dc.w	$50	;offensive zone (94 $3C)
	dc.w	$32
	dc.w	$CD	;94 $E6
	dc.w	$14
	dc.w	$50	;past goalline
	dc.w	$1E
	dc.w	$FA
	dc.w	$14
.nodec
	move.w	temp3(a3),d0	;move temp3 into d0
	cmpi.w	#5,position(a3)	;compare 5 (RW) to position
	beq.w	.1	;branch if RW
	neg.w	d0	;negate d0
.1
	move.w	temp4(a3),d1	;move temp4 into d1
	btst	#7,pflags(a3)	;check if shooting up or down
	bne.w	.0	;branch if shooting up
	neg.w	d0	;negate d0
	neg.w	d1	;negate d1
.0
	lea	EvadePC(pc),a0	;add EvadePC as aux routine
	bra.w	skateto	;skate to d0/d1 position
rtss11	;no IDA label. Shared rts of asswingo / asscenterd
	rts
; player a3 is center on defense
; d7 = elapsed frames

asscenterd	;no IDA label (IDA dc.b), asstab entry $A. Center on defense. 95: with the team defense mode at 1 and a carrier, .cover
	btst	#5,$62(a3)	;pfalock - locked animation
	bne.s	rtss11	;exit if locked
	btst	#0,(gmode).w	;gmclock - check if clock is running
	bne.w	assnothing	;exit if stoppage
	bsr.w	check4bench
	btst	#3,pflags(a3)	;pfjoycon - check if joystick controlled
	bne.s	rtss11	;exit if joystick controlled
	bclr	#1,pflags(a3)	;pfna - new assignment
	beq.w	.nna	;branch if no new assignment
	clr.w	temp1(a3)	;clear temp1
	move.w	#8,temp2(a3)	;move 8 into temp2
.nna
	sub.b	d7,temp1(a3)	;subtract d7 from temp1
	bpl.w	.nodec
	move.b	aidef(a3),temp1(a3)	;move aidef into temp1
	btst	#6,(sflags7).w	;check for crowd record flag
	beq.w	.puckcarrier	;jump if not set
	tst.b	$40(a3)	;check if 0
	beq.w	.puckcarrier
	subq.b	#1,$40(a3)	;subtract 1 from temp1
.puckcarrier
	move.w	(puckc).w,d1	;move puck carrier SCnum into d1
	bmi.w	.nodec
	moveq	#$B,d0	;asscentero (94 6)
	subq.w	#6,d1	;subtract 6 from d1
	move.w	SCnum(a3),d2	;move player's SCnum into d2
	subq.w	#6,d2	;subtract 6 from d2
	eor.w	d2,d1	;compare d2 and d1
	bpl.w	assreplace	;if team has puck, replace assignment with acentero
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
	move.w	(puckx).w,d0	;Xpos of puck
	asr.w	#1,d0	;divide by 2
	move.w	(pucky).w,d2	;Ypos of puck
	btst	#7,pflags(a3)	;pfgoal - check which net to shoot on
	bne.w	.1	;branch if top net
	neg.w	d2	;negate d2 if shooting on bottom net
.1
	moveq	#-$7E,d1	;own high slot (94 -$80)
	cmp.w	#$FFAA,d2	;own blue line (94 $FFA8)
	blt.w	.chkgoal	;branch if puck in defensive zone
	add.w	(pucky).w,d1	;add pucky position to d1
	asr.w	#1,d1	;divide by 2
.chkgoal
	btst	#7,pflags(a3)	;pfgoal - check which net to shoot at
	bne.w	.z1	;branch if top net
	neg.w	d1	;shooting at bottom net
.z1
	lea	rtss11(pc),a0	;no extra collision routine
	bra.w	skateto	;d0/d1 - x/y coord for skating to
.cover	;95 only. Puck in the defensive zone ($56 from the blue line): within $47 of the middle, skate at the puck y in the slot (x 0) and
	;check (check4check), else skate at the puck; y kept off the goal (.clamp). Puck further out: hold the slot at y $B0 at most
	move.w	#$56,d0
	add.w	(pucky).w,d0
	btst	#7,pflags(a3)
	bne.w	.c1
	move.w	#$56,d0
	sub.w	(pucky).w,d0
.c1
	tst.w	d0
	bmi.w	.c4
	move.w	(puckx).w,d0
	bpl.w	.c2
	neg.w	d0
.c2
	cmp.w	#$47,d0
	blt.w	.c3
	move.w	(pucky).w,d1
	bsr.w	.clamp
	move.w	#0,d0
	lea	rtss21(pc),a0
	jsr	(skateto).l
	bra.w	check4check
.c3
	move.w	(puckx).w,d0
	move.w	(pucky).w,d1
	bsr.w	.clamp
	lea	rtss21(pc),a0
	jmp	(skateto).l
.c4
	clr.w	d0
	move.w	(pucky).w,d1
	cmp.w	#$B0,d1
	blt.w	.c5
	move.w	#$B0,d1
.c5
	btst	#7,pflags(a3)
	beq.w	.c6
	clr.w	d0
	move.w	(pucky).w,d1
	cmp.w	#$FF50,d1
	bgt.w	.c6
	move.w	#$FF50,d1
.c6
	lea	rtss21(pc),a0
	bsr.w	skateto
	bra.w	check4check
.clamp	;d1 at most $65 from the own goal line side: -$65 / $65 by net
	btst	#7,pflags(a3)
	bne.w	.cl1
	cmp.w	#$FF9B,d1
	bgt.w	.cl2
	move.w	#$FF9B,d1
	bra.w	.cl2
.cl1
	cmp.w	#$65,d1
	blt.w	.cl2
	move.w	#$65,d1
.cl2
	rts

asscentero	;no IDA label (IDA dc.b), asstab entry $B. Center on offense: a random spot in the puck zone
	btst	#5,pflags(a3)	;pfalock
	bne.w	rtss11	;exit if anim locked
	btst	#0,(gmode).w	;#gmclock
	bne.w	assnothing	;do nothing
	bsr.w	check4bench
	btst	#3,pflags(a3)	;pfjoycon - check if joystick controlled
	bne.w	rtss11	;exit if controlled
	bclr	#1,pflags(a3)	;clear pfna
	beq.w	.nna
	st	temp5(a3)	;old zone number - temp5
	clr.w	temp1(a3)	;clear temp1
	move.w	#8,temp2(a3)	;move 8 into temp2
.nna
	sub.b	d7,temp1(a3)	;subtract d7 from temp1 (d7 = elapsed frames)
	bpl.w	.nodec	;branch if temp1 not zero or neg
	move.b	aidef(a3),temp1(a3)	;move aidef into temp1
	btst	#6,(sflags7).w	;check if crowd record broken
	beq.w	.noboost
	tst.b	$40(a3)	;check if temp1 is 0
	beq.w	.noboost
	subq.b	#1,$40(a3)	;sub 1 from temp1
.noboost
	move.w	(puckc).w,d1	;move puck carrier SCnum into d1
	bmi.w	.de0
	moveq	#$A,d0	;asscenterd (94 5)
	subq.w	#6,d1
	move.w	SCnum(a3),d2	;move SCnum into d2
	subq.w	#6,d2
	eor.w	d2,d1	;checks to see if puck carrier is on team
	bmi.w	assreplace	;if not switch to acenterd
.de0
	move.w	(pucky).w,d0	;pucky in d0
	btst	#7,pflags(a3)	;#pfgoal - check what goal shooting on
	bne.w	.de1	;branch if top
	neg.w	d0	;negate if bottom net
.de1
	clr.w	d2	;d2 = zone number
	cmp.w	#$FFAA,d0	;check if own blue line (94 $FFA8)
	blt.w	.de2	;branch if in def zone
	addq.w	#8,d2	;set zone to 8
	cmp.w	#$56,d0	;check opponents blue line (94 $58)
	blt.w	.de2	;branch if in neutral zone
	btst	#4,tmflags(a2)	;Checks if currently offside
	;C6FE - Home
	;CA62 - Away
	bne.w	.de2	;branch if offside
	addq.w	#8,d2
	cmp.w	#$10B,d0	;check opponents goal line (94 $108)
	blt.w	.de2	;branch if in offensive zone
	addq.w	#8,d2	;add if past goal line
.de2
	cmp.w	temp5(a3),d2	;compare temp5 to d2
	bne.w	.de3
	move.w	(VDP_CNTR).l,d0	;move frame counter into d0.
	;This allows a chance for random movement in zone when waiting
	andi.w	#$7F,d0	;pass bottom 7 bits
	bne.w	.nodec
.de3
	move.w	d2,temp5(a3)	;move zone into temp5
	lea	.dedata(pc),a0
	move.w	2(a0,d2.w),d0	;move zone into d0
	jsr	(randomd0s).l	;randomize d0
	add.w	0(a0,d2.w),d0	;add to d0
	move.w	d0,temp3(a3)	;move into temp3 (X coord)
	move.w	6(a0,d2.w),d0	;move into d0
	jsr	(randomd0s).l	;randomize d0
	add.w	4(a0,d2.w),d0	;add into d0
	move.w	d0,temp4(a3)	;move into temp4 (Y coord)
	bra.w	.nodec
.dedata
	dc.w	0	;Skating Zones
	;puck location = defensive zone
	dc.w	$3C
	dc.w	$FFBA
	dc.w	$A
	dc.w	0	;neutral zone
	dc.w	$3C
	dc.w	$3C
	dc.w	$A
	dc.w	0	;offensive zone
	dc.w	$28
	dc.w	$AA
	dc.w	$1E
	dc.w	0	;below offensive goal line
	dc.w	$50
	dc.w	$AA
	dc.w	$14
.nodec
	move.w	temp3(a3),d0	;move temp3 into d0 (x coord to skate to)
	move.w	temp4(a3),d1	;move temp4 into d1 (y coord to skate to)
	btst	#7,pflags(a3)	;pfgoal
	bne.w	.0	;branch if top
	neg.w	d1	;negate if bottom
.0
	lea	EvadePC(pc),a0
	bra.w	skateto
; joypad controlled goalie control
; a3 = goalie

assdefo	;no IDA label (IDA dc.b), asstab entry $C. assign94 assdefo (moved in). Defenseman on offense. 95: back to assdefd at once when the other team has the puck (or nobody), no blue line test; holds no deeper than the other forwards (.lim), and at -$C0 when the other goalie has the puck (PuckcIsGoalie)
	bclr	#7,$64(a3)	;95: assdefdchase sets it
	btst	#5,$62(a3)
	bne.w	rtsskate
	btst	#0,(gmode).w	;#gmclock
	bne.w	assnothing	;Whistle blown, do nothing
	bsr.w	check4bench	;check if player should go to bench
	btst	#3,pflags(a3)	;#pfjoycon - is player joystick controlled
	bne.w	rtsskate	;yes, then exit
	bclr	#1,pflags(a3)	;#pfna - checks if theres a new assignment
	beq.w	.nna
	clr.w	temp1(a3)	;clears temp1 if new assignment
	move.w	#8,temp2(a3)	;moves 8 into temp2 if new assignment
.nna
	move.w	#7,d0	;95: back to assdefd (94 2) when the other team has the puck, or nobody
	move.w	(puckc).w,d1
	bmi.w	.ass
	subq.w	#6,d1
	move.w	SCnum(a3),d2
	subq.w	#6,d2
	eor.w	d2,d1
.ass
	bmi.w	assreplace
	sub.b	d7,temp1(a3)	;subtract frames elapsed since last call from temp1
	bpl.w	.nodec	;temp1 not zero or negative
	move.b	aioff(a3),temp1(a3)	;Loads aioff into temp1
	jsr	(ReadGoaliePulled).l
	bmi.w	.boost	;branch if goalie is pulled
	btst	#6,(sflags7).w	;check if crowd meter broken
	beq.w	.noboost	;branch if not
	tst.b	$40(a3)	;check if temp1 is 0
	beq.w	.noboost	;branch if so
.boost
	subq.b	#1,$40(a3)	;sub 1 from temp1
.noboost
	moveq	#7,d0	;assdefd (94 2)
	btst	#4,tmflags(a2)	;check if team is offsides
	bne.w	assreplace	;if so, assreplace (assdefd)
	move.w	(pucky).w,d1	;move pucky into d1
	btst	#7,pflags(a3)	;#pfgoal - check which net to score on
	bne.w	.de1	;branch if top
	neg.w	d1	;Negates d1- shooting on bottom net
.de1
	move.w	(puckc).w,d1	;puck carrier (SCnum) into d1
	bmi.w	.nodec	;branch if no puckc
	subq.w	#6,d1	;sub 6 from d1
	move.w	SCnum(a3),d2	;move SCnum into d2
	subq.w	#6,d2	;sub 6 from d2
	eor.w	d2,d1	;EOR d2 with d1
	bmi.w	assreplace	;ass replace if puckc not on same team
.nodec
	lea	EvadePC(pc),a0	;EvadePC, extra collision routine for skateto
	move.w	#$50,d0	;move 80 dec into d0
	cmpi.w	#2,position(a3)	;position(a3) - checks that player is RD
	beq.w	.1	;branch if RD
	neg.w	d0	;player is LD, so negates d0
.1
	move.w	#$74,d1	;inside of blueline (94 $62)
	btst	#7,pflags(a3)	;#pfgoal
	bne.w	.0	;branch if top net shooting
	neg.w	d0	;shooting on bottom net, so negate d0 and d1
	neg.w	d1
.0
	move.w	(puckx).w,d2	;move puckx into d2
	eor.w	d0,d2	;XOR d0 with d2
	bmi.w	.2	;branch if puck on the other side of X center
	move.w	(puckx).w,d0	;move puckx to d0
	bsr.w	.lim
	bsr.w	PuckcIsGoalie	;95: y -$C0 (by net) when the other goalie has the puck
	bne.w	.3
	move.w	#$FF40,d1
	btst	#7,pflags(a3)
	bne.w	.3
	neg.w	d1
.3
	jmp	(skateto).l	;d0/d1 are x/y positions, a0 is extra collision routine
.2
	move.w	(puckx).w,d2	;move puckx into d2
	asr.w	#1,d2	;divide by 2
	add.w	d2,d0	;add d2 to d0
	bsr.w	.lim
	bsr.w	PuckcIsGoalie
	bne.w	.4
	move.w	#$FF40,d1
	btst	#7,pflags(a3)
	bne.w	.4
	neg.w	d1
.4
	jmp	(skateto).l	;skateto routine
.lim	;95 only. Keep y d1 no deeper than the deepest of the other team's forwards (position 3 and up, available), at most $74 out
	move.l	a2,-(sp)
	clr.w	(recwins).w
	move.w	#$FF8C,(TempLegSpd).w
	btst	#7,pflags(a3)
	beq.w	.l0
	neg.w	(TempLegSpd).w
.l0
	movea.l	#SortCords,a2
	btst	#6,pflags(a3)
	beq.w	.l1
	movea.l	#SortCords+(6*SCstruct),a2
.l1
	move.w	#5,d2
.l2
	cmpi.w	#3,position(a2)
	blt.w	.l4
	btst	#2,pflags2(a2)
	bne.w	.l4
	move.w	Ypos(a2),d3
	btst	#7,pflags(a3)
	beq.w	.l3
	cmp.w	(TempLegSpd).w,d3
	bgt.w	.l4
	move.w	Ypos(a2),(TempLegSpd).w
	bra.w	.l4
.l3
	cmp.w	(TempLegSpd).w,d3
	blt.w	.l4
	move.w	Ypos(a2),(TempLegSpd).w
.l4
	adda.w	#SCstruct,a2
	dbf	d2,.l2
	btst	#7,pflags(a3)
	bne.w	.l5
	cmp.w	(TempLegSpd).w,d1
	bgt.w	.l6
	move.w	(TempLegSpd).w,d1
	bra.w	.l6
.l5
	cmp.w	(TempLegSpd).w,d1
	blt.w	.l6
	move.w	(TempLegSpd).w,d1
.l6
	movea.l	(sp)+,a2
	rts
; player a3 is defensive player on defense

assnothing	;no IDA label (IDA dc.b). assign94 assnothing (moved in): no assignment, just skate (doplayeracc 8)
	btst	#5,$62(a3)	;#pfalock
	bne.w	rtss21
	btst	#3,$62(a3)	;#pfjoycon
	bne.w	rtss21
	moveq	#8,d0
	jmp	(doplayeracc).l
assfight	;no IDA label. asstab entry $19: an rts (94 assfight and assfwatch are rts only)
	rts

pucknorm	;no IDA label (IDA dc.b), asstab entry 1. The puck: follow the carrier, icing / offsides checks, a stoppage when it sits still
	btst	#2,(BA_PS_flags).w	;check if flag is clear (normal play)
	beq.w	.normalplay
	jsr	(UpdatePenaltyShotEnd).l
.normalplay
	bclr	#pfna,pflags(a3)	;#pfna clear
	beq.w	.nna
	clr.w	temp1(a3)	;temp1
	move.w	#$78,temp2(a3)	;'x' ; temp2
.nna
	movea.w	#(puckcross-M68K_RAM),a1	;table for puck crossing lines
	sub.w	d7,2(a1)	;sub elapse frames from time til crossing
	sub.w	d7,6(a1)
	sub.w	d7,temp1(a3)	;temp1
	bpl.w	.0
	addq.w	#5,temp1(a3)
	bsr.w	findpc
.0
	move.w	(puckc).w,d0
	bmi.w	.nothandled
	asl.w	#7,d0	;#scsize
	movea.w	#(SortCords-M68K_RAM),a2
	adda.w	d0,a2
	bsr.w	a2touchpuck
	move.l	a2,-(sp)
	jsr	(GetHot).l
	add.w	(a2),d0	;Xpos - bungie the puck towards the hot spot on player a2
	sub.w	(a3),d0
	asr.w	#2,d0
	add.w	d0,(a3)
	add.w	Ypos(a2),d1	;Ypos
	sub.w	Ypos(a3),d1
	asr.w	#2,d1
	add.w	d1,Ypos(a3)
	move.w	Xvel(a2),Xvel(a3)	;Xvel
	move.w	Yvel(a2),Yvel(a3)	;Yvel
.nothandled
	jsr	(puckIChk).l
	jsr	(ChkOffsides).l
	btst	#0,(gmode).w	;check for play stoppage
	bne.w	.end
	tst.w	(puckc).w
	bpl.w	.resetstilltimer
	move.w	(a3),d0	;Xpos
	cmp.w	OldXpos(a3),d0	;oldXpos
	bne.w	.resetstilltimer
	move.w	Ypos(a3),d0	;Ypos
	cmp.w	OldYpos(a3),d0	;oldYpos
	bne.w	.resetstilltimer
	move.l	#6,d0
	subq.w	#1,temp2(a3)	;temp3
.maybepenalty
	bpl.w	.stillpuckdone
	jsr	(AddPenalty2).l
.stillpuckdone
	bra.w	.end
.resetstilltimer
	move.w	#$78,temp2(a3)	;'x' ; move 78 hex into temp2
.end
	tst.b	Zvel(a3)	;Zvel
	bne.w	.coll
	tst.w	Zpos(a3)	;Zpos
	bne.w	.coll
	jsr	(puckunflip).l
.coll
	jmp	(checkpuckcoll).l

puckunflip	;no IDA label (IDA dc.b), asstab entry 5. Stop the spinning puck
	cmpi.w	#8,SPAnum(a3)
	blt.w	.k
	cmpi.w	#$18,SPAnum(a3)
	bge.w	.k
	eori.w	#2,facedir(a3)	;facedir
.k
	ori.w	#4,facedir(a3)
	clr.w	SPAnum(a3)	;SPAnum
	st	SPAcnt(a3)	;SPAcnt
	rts
; start puck spinning
; a3 = puck

puckflip	;IDA: sub_81336. Flip the puck (95 SPA $12C0)
	andi.w	#1,d0
	eor.w	d0,facedir(a3)	;facedir
	andi.w	#3,facedir(a3)
	st	SPAcnt(a3)	;SPAcnt
	move.w	#$12C0,d1	;#SPApflip (95 SPA; 94 $46A)
	jmp	(SetSPA).l

; assignment for puck shadow
; a3 = puck shadow
puckshadow	;no IDA label (IDA dc.b), asstab entry 2. The puck shadow, a siren on goals (95: no horizontal mode)
	cmpi.w	#$1B3,frame(a3)	;#SPFpuck, frame (94 $18A)
	bne.w	.siren	;shadow turns into siren on goals
	move.w	Xpos-SCstruct(a3),(a3)	;Xpos-SCstruct, Xpos
	move.w	Ypos-SCstruct(a3),Ypos(a3)	;Ypos-SCstruct, Ypos
	clr.w	Zpos(a3)	;Zpos
	moveq	#Ypos,d0	;Ypos (95 has no horizontal mode check)
	addq.w	#1,0(a3,d0.w)
	rts
.siren
	tst.w	frame(a3)	;frame
	beq.w	.s0	;94 rtss2
	clr.w	(a3)	;Xpos
	move.w	#$13C,Ypos(a3)	;Ypos (94 $12C)
	move.w	#$E,Zpos(a3)	;Zpos
	tst.w	Ypos-SCstruct(a3)	;Ypos-SCstruct
	bpl.w	.s0
	move.w	#$8000,attribute(a3)	;attribute
	neg.w	Ypos(a3)	;Ypos
	subq.w	#1,Zpos(a3)	;Zpos
.s0
	rts

findpc	;no IDA label (IDA dc.b). Where and when the puck crosses each goal line (puckcross). 95: 4 frames earlier
	movem.l	d0-d4/a1-a2,-(sp)
	movea.w	#(puckcross-M68K_RAM),a1
	move.w	#$98,d1	;sideline (94 $88) - distance from center to side boards
	move.w	#$10B,d4	;goaline (94 $108)
	bsr.w	.calc
	neg.w	d4	;make d4 negative to check bottom goal line
	bsr.w	.calc
	movem.l	(sp)+,d0-d4/a1-a2
	rts
.calc
	move.w	d4,d0	;move goaline into d0
	sub.w	(pucky).w,d0	;sub pucky from d0
	tst.w	(puckvy).w	;check puckvy
	beq.w	.nocross	;branch if 0
	move.w	d0,d2	;move d0 into d2
	swap	d2	;swap upper and lower word of d2
	clr.w	d2	;clear bottom word of d2
	asr.l	#4,d2	;shift 4 bits right (divide by 16)
	divs.w	(puckvy).w,d2	;divide puckvy into d2
	bmi.w	.nocross	;branch if negative
	cmp.w	#4,d2	;95: 4 frames earlier, when more than 4
	ble.w	.t
	subq.w	#4,d2
.t
	move.w	d2,2(a1)	;time until crossing in frames (puckcross y)
	muls.w	(puckvx).w,d0	;mult puckvx with d0
	divs.w	(puckvy).w,d0	;divide puckvy into d0
	bvs.w	.nocross	;branch if overflow set
	add.w	(puckx).w,d0	;add puckx to d0
	cmp.w	d1,d0	;compare d1 (sideline) to d0
	blt.w	.o1	;branch if less than (in play)
	neg.w	d0	;negate d0
	add.w	d1,d0	;add d1 3 times to d0
	add.w	d1,d0
	add.w	d1,d0
.o1
	neg.w	d1	;negate d1
	cmp.w	d1,d0	;compare d1 (other sideline) to d0
	bgt.w	.o2	;branch if greater than (in play)
	neg.w	d0	;negate d0
	add.w	d1,d0	;add d1 to d0 3 times
	add.w	d1,d0
	add.w	d1,d0
.o2
	neg.w	d1	;negate d1
	move.w	d0,(a1)	;move d0 into puckcross
	bra.w	.next
.nocross
	move.w	#$FFFF,2(a1)	;move -1 into puckcross y
.next
	addq.w	#4,a1	;add 4 to puckcross (to move to the other goal line)
	rts

a2touchpuck	;no IDA label (IDA dc.b). Player a2 touched the puck: last touch, scorer / assist slots, offsides, icing. 95: no icing in Practice Mode
	move.w	(a2),(ltx).w	;move Xpos to last touch X
	move.w	Ypos(a2),(lty).w	;move Ypos to last touch Y
	move.w	SCnum(a2),(ltplayer).w	;move SCnum to last touch player
	movea.w	#(HmShots-M68K_RAM),a0	;move Home Shots into a0
	btst	#pfteam,pflags(a2)	;check if home or away
	beq.w	.t	;branch if home
	lea	tmsize(a0),a0	;add to a0 if away
.t
	clr.w	d0
	move.b	pnum(a2),d0	;move pnum into d0
	btst	#3,$64(a2)	;check if one timer
	beq.w	.checklast	;branch if not
	bset	#7,(sflags8).w	;set if one timer
.checklast
	cmp.w	$18(a0),d0	;compare value in C6E6 (home) to d0
	beq.w	.same	;branch if equal
	bclr	#3,tmflags(a0)	;clear bit 3
	bne.w	.st	;branch if not cleared before
	move.w	$1A(a0),$1C(a0)	;move current player to assist slot
	move.w	$18(a0),$1A(a0)	;move current player to last player slot
.st
	move.w	d0,$18(a0)	;move pnum into current player
	cmp.w	$1C(a0),d0	;compare if same player as assist slot
	bne.w	.same	;branch if not
	st	$1C(a0)	;set FFFF to assist slot
.same
	bclr	#sf2shot,(sflags2).w	;clear shot taken
	bsr.w	a2offsides
	btst	#2,(iflags).w	;check if icing
	beq.w	.notice	;branch if not
	btst	#0,(iflags).w	;test if crossed goalline
	beq.w	.notice	;branch if not
	tst.w	position(a2)	;check if goalie
	beq.w	.notice	;branch if so
	btst	#1,(iflags).w	;check if must cross top line
	bne.w	.up	;branch if so
	btst	#pfgoal,pflags(a2)	;check if top or bottom shooting goal
	beq.w	.notice	;branch if bottom
.icing
	clr.w	d0
	move.b	(icingPlayer).w,d0	;move iflags+1 into d0
	asl.w	#7,d0
	move.l	a3,-(sp)	;push on stack
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3	;a3 now player struct
	move.w	#$C,d0	;#PenIcing
	jsr	(AddPenalty).l
	movea.l	(sp)+,a3
	rts
.up
	btst	#pfgoal,pflags(a2)	;check top or bottom shooting goal
	beq.s	.icing	;branch if bottom
.notice
	clr.b	(iflags).w
	move.b	SCnum+1(a2),(icingPlayer).w	;move SCnum+1 into icingPlayer
	move.w	(pucky).w,d0	;move pucky into d0
	btst	#pfgoal,pflags(a2)	;check if shooting up or down
	beq.w	.0	;branch if down
	bset	#1,(iflags).w	;set icing direction up
	neg.w	d0	;negate d0
.0
	bmi.w	.x	;exit if minus
	move.w	(HmShots+tmap).w,d0	;IDA (tmap).w
	sub.w	(AwShots+tmap).w,d0	;IDA (tmsize).w
	btst	#pfteam,pflags(a2)	;check home or away
	beq.w	.1	;branch if home
	neg.w	d0	;negate d0
.1
	bmi.w	.x	;exit if minus
	btst	#7,(sflags9).w	;95: no icing in Practice Mode
	bne.w	.x
	bset	#2,(iflags).w	;set icing flag
.x
	rts

Setplass	;IDA: sub_81540. collide94 Setplass (moved in). Set player a3's first assignment by position (95 numbers). 94: set players (a3) initial assignment from .alist by position
	move.w	position(a3),d0
	bmi.w	.x
	lea	.alist(pc),a0
	move.b	0(a0,d0.w),d0
	bra.w	assreplace
.x
	rts
.alist	;95 assignment numbers by position
	dc.b	6	;assgoaliecpu (94 $E)
	dc.b	7	;assdefd (94 2)
	dc.b	7	;assdefd
	dc.b	8	;asswingd (94 3)
	dc.b	$A	;asscenterd (94 5)
	dc.b	8	;asswingd
	dc.b	$A	;95: asscenterd
	dc.b	$FF

assexit	;IDA: sub_8155E. Exit the current assignment of player a3
	addq.w	#1,assnum(a3)	;add 1 to current assignment index
	andi.w	#7,assnum(a3)	;mask passing first 3 bits
	bset	#pfna,pflags(a3)	;signal next assignment
	rts
; insert new assignment on player a3
assinsert	;IDA: sub_81570. Insert assignment d0 on player a3
	subq.w	#1,$36(a3)	;$36 = assnum
	andi.w	#7,$36(a3)
; replace current assignment on player a3
assreplace	;IDA: sub_8157A. Replace the current assignment of player a3 with d0
	move.l	d1,-(sp)	;push on stack
	move.w	assnum(a3),d1	;$36 = assnum
	move.b	d0,asslist(a3,d1.w)	;replace current assignment with d0 on asslist
	bset	#pfna,pflags(a3)	;set flag to start new assignment
	move.l	(sp)+,d1	;pop on stack
	rts
; d0/d1 are x/y distances which are converted into direction 0-7 and returned in d0

EvadePC	;no IDA label (IDA dc.b). skateto extra routine: steer around the puck carrier
	tst.w	(puckc).w
	bmi.w	.ex	;no puck carrier
	move.b	Xvel(a3),d2	;Xvel
	sub.b	(puckvx).w,d2	;sub puckvx from Xvel
	ext.w	d2
	add.w	(a3),d2	;add Xpos
	sub.w	(puckx).w,d2	;Sub puckx
	cmp.w	#$28,d2	;'('   ; compare to 40 decimal
	bgt.w	.ex	;exit if greater than 40
	cmp.w	#$FFD8,d2	;compare to -40
	blt.w	.ex	;exit if less than -40
	move.b	Yvel(a3),d1	;Yvel
	sub.b	(puckvy).w,d1	;sub puckvy from Yvel
	ext.w	d1
	add.w	Ypos(a3),d1	;add Ypos to d1
	sub.w	(pucky).w,d1	;Sub pucky
	cmp.w	#$28,d1	;'('   ; compare to 40 dec
	bgt.w	.ex	;exit if greater than
	cmp.w	#$FFD8,d1	;compare to -40 dec
	blt.w	.ex	;exit if less than
	move.w	(a3),d0	;Xpos
	sub.w	(puckx).w,d0	;Sub puckx from Xpos
	move.w	Ypos(a3),d1	;Ypos
	sub.w	(pucky).w,d1	;Sub pucky from Ypos
	jsr	(vtoa).l	;find direction and convert to 0-7
	btst	#5,(gmode).w	;check if offsides is on
	beq.w	.ex	;exit if not
	move.w	Ypos(a3),d1	;Ypos
	btst	#7,pflags(a3)	;check what net shooting at
	bne.w	.0	;branch if top
	neg.w	d1	;negate d1 (Ypos)
.0
	subi.w	#$56,d1	;sub the top blue line from Ypos (94 $58)
	cmp.w	#$A,d1	;compare to 10 decimal
	bgt.w	.ex	;exit if greater
	cmp.w	#$FFCE,d1	;compare to -50
	blt.w	.ex	;branch if less than
	moveq	#2,d0
	move.w	(a3),d1	;Xpos
	cmp.w	(puckx).w,d1	;compare puckx with Ypos difference
	bgt.w	.ex	;exit if greater
	moveq	#6,d0
.ex
	rts
rtsskateto	;95: skateto's exit
	rts

skateto	;no IDA label (IDA dc.b). Skate a3 to d0 / d1, a0 = extra routine. 95: nothing while locked in an animation
	btst	#5,pflags(a3)	;95: nothing while locked in an animation
	bne.s	rtsskateto
	sub.b	d7,temp2(a3)	;sub d7 from temp2
	bpl.w	.ex	;exit if not 0 or less
	addi.b	#$C,temp2(a3)	;add 12 - only execute every 12 frames
	bsr.w	avdgoal	;avoid the goal nets
	movem.w	d0-d1,-(sp)
	move.w	Xvel(a3),d0	;Xvel
	asr.w	#8,d0	;divide by 256
	neg.w	d0	;make negative
	add.w	(sp)+,d0	;add new x coord from stack
	sub.w	(a3),d0	;sub Xpos
	move.w	Yvel(a3),d1	;Yvel
	asr.w	#8,d1	;divide by 256
	neg.w	d1	;make negative
	add.w	(sp)+,d1	;add new y coord from stack
	sub.w	Ypos(a3),d1	;sub Ypos
	cmp.w	#$C,d0	;compare 12 to d0
	bgt.w	.vt
	cmp.w	#$FFF4,d0	;cmp -12
	blt.w	.vt
	cmp.w	#$C,d1	;compare 12 to d1
	bgt.w	.vt
	cmp.w	#$FFF4,d1	;cmp -12
	blt.w	.vt
	moveq	#9,d0
	bra.w	.nvt
.vt
	jsr	(vtoa).l
.nvt
	jsr	(a0)	;extra collision routine
	move.b	d0,temp2+1(a3)	;move d0 into temp2+1
	cmp.w	#7,d0	;compare to 7
	ble.w	.ex
	move.w	Xvel(a3),d0	;Xvel
	or.w	Yvel(a3),d0	;Yvel
	bne.w	.ex
	move.w	(puckx).w,d0	;move puckx into d0
	move.w	(pucky).w,d1	;move pucky into d1
	btst	#pf2fight,(puck_pflags2).w	;#pf2fight, puckx+pflags2
	beq.w	.nf
	move.w	(xc1).w,d0	;scroll lock x coord
	move.w	(yc1).w,d1	;scroll lock y coord
.nf
	sub.w	(a3),d0	;Xpos
	sub.w	Ypos(a3),d1	;Ypos - face towards puck
	jsr	(vtoa).l
	sub.w	facedir(a3),d0	;facedir
	beq.w	.ex
	neg.w	d0
	andi.w	#4,d0
	lsr.w	#1,d0	;divide by 2
	subq.w	#1,d0
	add.w	facedir(a3),d0	;facedir
	andi.w	#7,d0
	move.w	d0,facedir(a3)	;facedir
.ex
	clr.w	d0
	move.b	temp2+1(a3),d0	;temp2+1
	jmp	(doplayeracc).l

check4check	;no IDA label (IDA dc.b). Check an opponent in front of a3. 95: a joystick player starts the check animation (CanCheckStart, SPAcheckstart); sflags10 bit 7 always looks; burstchk / Acheck
	tst.w	$34(a3)	;check if goalie
	bne.w	.player	;branch if not
	rts
.player
	btst	#3,pflags(a3)	;95: a joystick player starts the check animation when CanCheckStart allows
	bne.w	.cpu
	jsr	(CanCheckStart).l
	beq.w	.cpu
	move.w	#$1E6C,d1	;SPAcheckstart
	bset	#2,(GameFlags).w
	jsr	(SetSPA).l
	bset	#5,pflags(a3)	;lock the animation
	rts
.cpu
	btst	#7,(sflags10).w	;95: always look with sflags10 bit 7
	bne.w	.look
	move.w	#$28,d0	;'('   ; start with 28 hex (40 decimal)
	sub.b	$75(a3),d0	;subtract Chk from d0 (Chk max is 1E or 30 decimal)
	tst.w	(OptPen).w	;check for penalties option
	beq.w	.nopen	;branch if not on
	asl.w	#1,d0	;mult by 2
.nopen
	jsr	(randomd0).l	;RNG d0
	cmp.w	#6,d0	;compare 6 to d0
	bhi.w	.x	;exit if d0 higher than 6
.look
	moveq	#5,d2	;move 5 into d2
	movea.w	#(SortCords-M68K_RAM),a0
	cmpi.w	#6,SCnum(a3)	;check if player on home team
	bge.w	.0	;branch if away
	adda.w	#6*SCstruct,a0	;add if home (checks opposite team in loop)
.0
	tst.w	position(a0)	;check if goalie
	beq.w	.next	;branch if goalie
	btst	#pfalock,pflags(a0)	;check if locked in anim
	bne.w	.next	;branch if locked
	btst	#pf2fight,pflags2(a0)	;check if fighting
	bne.w	.next	;branch if fighting
	move.w	(a0),d0	;move Xpos into d0
	sub.w	(a3),d0	;sub a3 from a0
	cmp.w	#$1E,d0	;compare to 30 decimal
	bgt.w	.next	;branch if more than 30 decimal
	cmp.w	#$FFE2,d0	;compare to -30 decimal
	blt.w	.next	;branch if less than -30
	move.w	Ypos(a0),d1	;Ypos
	sub.w	Ypos(a3),d1	;subtract checker Ypos from d1
	cmp.w	#$1E,d1	;compare to 30 decimal
	bgt.w	.next	;branch if more
	cmp.w	#$FFE2,d1	;check with -30 decimal
	blt.w	.next	;branch if less
	jsr	(vtoa).l	;determine direction
	cmp.w	facedir(a3),d0	;compare facedir with vtoa result
	bne.w	.next	;branch if not facing in that direction
	tst.w	d1	;95: within $1E in y (always here): the check (burstchk)
	bpl.w	.1
	neg.w	d1
.1
	cmp.w	#$1E,d1
	bgt.w	.2
.burst
	jmp	(burstchk).l
.2
	tst.w	d1
	bpl.w	.3
	neg.w	d1
.3
	cmp.w	#$1E,d1
	bgt.s	.burst
	btst	#5,(sflags6).w	;check if puckc in slot
	bne.w	.check	;branch if in slot
	move.w	(VDP_CNTR).l,d0	;move HVcounter into d0
	andi.w	#3,d0	;pass first 2 bits
	bne.s	.burst	;throw check
.check
	jmp	(Acheck).l
.next
	adda.w	#SCstruct,a0	;move to next SCstruct
	dbf	d2,.0
.x
	rts

check4check2	;no IDA label (IDA dc.b). 95 only. check4check with a puck y test before the check (burstchk) or Acheck
	;(or $A beyond it), else on vcount bit 8. Called from assdefdchase (checks95_03)
	tst.w	$34(a3)	;check if goalie
	bne.w	.player	;branch if not
	rts
.player
	btst	#3,pflags(a3)
	bne.w	.cpu
	jsr	(CanCheckStart).l
	beq.w	.cpu
	move.w	#$1E6C,d1	;SPAcheckstart
	bset	#2,(GameFlags).w
	jsr	(SetSPA).l
	bset	#5,pflags(a3)
	rts
.cpu
	btst	#7,(sflags10).w
	bne.w	.look
	move.w	#$28,d0
	sub.b	$75(a3),d0
	tst.w	(OptPen).w
	beq.w	.nopen
	asl.w	#1,d0
.nopen
	jsr	(randomd0).l
	cmp.w	#6,d0
	bhi.w	.x
.look
	moveq	#5,d2
	movea.w	#(SortCords-M68K_RAM),a0
	cmpi.w	#6,SCnum(a3)
	bge.w	.0
	adda.w	#6*SCstruct,a0
.0
	tst.w	position(a0)
	beq.w	.next
	btst	#pfalock,pflags(a0)
	bne.w	.next
	btst	#pf2fight,pflags2(a0)
	bne.w	.next
	move.w	(a0),d0
	sub.w	(a3),d0
	cmp.w	#$1E,d0
	bgt.w	.next
	cmp.w	#$FFE2,d0
	blt.w	.next
	move.w	Ypos(a0),d1
	sub.w	Ypos(a3),d1
	cmp.w	#$1E,d1
	bgt.w	.next
	cmp.w	#$FFE2,d1
	blt.w	.next
	jsr	(vtoa).l
	cmp.w	facedir(a3),d0
	bne.w	.next
	tst.w	d1
	bpl.w	.1
	neg.w	d1
.1
	cmp.w	#$1E,d1
	bgt.w	.2
.side
	move.w	(pucky).w,d0	;check when the puck is past a3 in y, or $A past it toward his goal
	move.w	Ypos(a3),d1
	eor.w	d1,d0
	bmi.w	.burst
	move.w	#$FFF6,d0
	btst	#7,pflags(a3)
	bne.w	.4
	move.w	#$A,d0
.4
	move.w	(pucky).w,d1
	eor.w	d1,d0
	bmi.w	.burst
	move.w	(vcount).w,d0	;else a check on vcount bit 8
	andi.w	#$100,d0
	beq.w	.check
.burst
	jmp	(burstchk).l
.2
	tst.w	d1
	bpl.w	.3
	neg.w	d1
.3
	cmp.w	#$1E,d1
	bgt.s	.side
	btst	#5,(sflags6).w
	bne.w	.check
	move.w	(VDP_CNTR).l,d0
	andi.w	#3,d0
	bne.s	.side
.check
	jmp	(Acheck).l
.next
	adda.w	#SCstruct,a0
	dbf	d2,.0
.x
	rts

asspassrec	;no IDA label (IDA dc.b), asstab entry $D. Catch a pass; a one timer (assonetimer) for a computer player in the zone
	btst	#pfalock,pflags(a3)	;pfalock - animation lock
	bne.w	rtss6	;exit if locked
	btst	#gmclock,(gmode).w	;gmclock - check if clock running
	bne.w	assnothing	;exit if clock stopped
	btst	#pfjoycon,pflags(a3)	;pfjoycon - joystick controlled?
	bne.w	assexit	;exit if controlled
	bclr	#pfna,pflags(a3)	;#pfna - clear new assignment
	beq.w	.nna
	bset	#pfdoff,pflags(a3)	;#pfdoff - set decceleration off
	move.b	#8,temp2+1(a3)	;move into temp2+1
	clr.b	temp2(a3)	;clear temp2 byte
	move.w	#$FFFE,$46(a3)	;move into temp4
.nna
	tst.w	(puckc).w	;check if there is a puck carrier
	bpl.w	.exit	;exit if puck still in possession
	addq.w	#1,$46(a3)	;add to temp4
	beq.w	.0	;branch if temp4 is zero
	bpl.w	.ex2	;branch if temp4 is positive
.0
	tst.w	(onetimerplayer).w
	bpl.w	.ex2
	tst.w	$34(a3)	;test if goalie
	beq.w	.ex2	;exit if goalie
	move.w	d0,-(sp)	;push d0 on stack
	clr.w	$46(a3)	;clear temp4
	move.w	#1,d0
	btst	#6,$62(a3)	;check if home or away
	beq.w	.1
	move.w	#2,d0	;away team
.1
	cmp.w	(cont1team).w,d0	;check if player on cont 1 team
	beq.w	.pop	;branch if so
	cmp.w	(cont2team).w,d0	;check if player on cont 2 team
	beq.w	.pop	;branch if so
	jsr	(PuckOnAttackHalf).l
	beq.w	.pop
	move.w	$14(a3),d0	;Ypos
	btst	#7,$62(a3)	;pfgoal
	bne.w	.chkpos	;branch if shooting at top
	neg.w	d0
.chkpos
	cmp.w	#$56,d0	;blueline (94 $58)
	blt.w	.nozone
	cmp.w	#$10B,d0	;goalline (94 $108)
	bgt.w	.nozone
	bra.w	.atkzone
.nozone
	move.w	#8,d0	;outside of attack zone
	jsr	(randomd0).l
	tst.w	d0	;check if d0 is zero
	bne.w	.pop
.atkzone
	move.w	(sp)+,d0
	move.w	#$FFFF,(inputjoy).w
	move.w	#$18,d0	;assonetimer (94 $23)
	jmp	(assreplace).l
.pop
	move.w	(sp)+,d0
.ex2
	sub.b	d7,temp1(a3)
	bpl.w	rtss6
.exit
	bclr	#pfdoff,pflags(a3)
	jmp	(assexit).l
SkateToTempTarget	;no IDA label (IDA dc.b). Skate to temp3 / temp4
	move.w	$44(a3),d0		;temp3
	move.w	$46(a3),d1		;temp4
	lea	rtss6(pc),a0
	jmp	(skateto).l
rtss6	;the SkateToTempTarget exit, also asspassrec's and assdefo's (94 rtss6 is before assdefo)
	rts
rtsskate	;95: a second rts. assgoaliecpu, AdjustFacingDirection, assdefo and others branch here
	rts

assbreakaway	;no IDA label (IDA dc.b), asstab entry $21. Breakaway; falls into assnearest
	move.w	$52(a3),d0	;Move SCnum into d0
	cmp.w	(puckc).w,d0	;compare puck carrier SCnum with d0
	beq.w	.puckc	;branch if puck carrier
.notpuckc
	bclr	#1,$64(a3)	;clear breakaway bit
	move.w	#$E,d0	;assnearest (94 $11)
	bsr.w	assreplace
	bra.w	assnearest
.puckc
	jsr	(breakaway).l
	bmi.s	.notpuckc

assnearest	;no IDA label (IDA dc.b), asstab entry $E. The player nearest the puck without it. 95: skates at the future puck spot, no crowd meter boost
	bclr	#2,(sflags5).w
	bne.w	.chkpuck
	bclr	#1,$64(a3)	;clear breakaway bit
.chkpuck
	move.w	$52(a3),d0	;move SCnum into d0
	cmp.w	(puckc).w,d0	;compare with puck carrier SCnum
	bne.w	.chkbreak	;jump if not puck carrier
	btst	#1,$64(a3)	;check breakaway bit
	bne.w	.chkbreak	;jump if set
	btst	#2,(BA_PS_flags).w	;check if bit 2 set (cleared on Faceoffs)
	bne.w	.chkbreak	;jump if set
	jsr	(BreakawayOffsidesFlagSet).l
	beq.w	.chkbreak
	move.w	#$21,d0	;assbreakaway if flag set (94 $22)
	bsr.w	assreplace	;assreplace with assbreakaway
	bra.w	*+4
.chkbreak
	bclr	#1,$62(a3)	;pfna - clear new assignment
	beq.w	.nna
	btst	#1,$64(a3)	;check if breakaway
	beq.w	.chkbreak2	;jump if not
	move.w	#1,-(sp)	;ding SFX
	jsr	(sfx).l
.chkbreak2
	btst	#1,$64(a3)	;check if breakaway
	beq.w	.nobreak	;jump if not
	movem.l	a2,-(sp)	;push a2 to stack
	movea.l	#HmShots,a2	;put Home Team Struct into a2
	btst	#6,$62(a3)	;pfteam - check home or away
	beq.w	.addcrowd	;jump if home
	movea.l	#AwShots,a2	;put Away Team Struct into a2
.addcrowd
	addq.w	#1,$35A(a2)	;add to breakaway attempt (94 $358)
	addi.w	#$14,(CwdExciteLvl).w	;add to excite level
	addi.w	#$C8,(crowdlevel).w	;add to crowd level
	movem.l	(sp)+,a2	;pop off stack into a2
.nobreak
	clr.w	temp3(a3)	;clear temp3
	move.w	#8,temp2(a3)	;move 8 into temp2
	clr.w	temp1(a3)	;clear temp1
.nna
	move.w	SCnum(a3),d1	;checks if puck carrier
	cmp.w	(puckc).w,d1
	bne.w	.nopc	;jumps if not
	tst.w	position(a3)	;check if goalie
	beq.w	assgoaliecpu	;branch if goalie
	moveq	#$F,d0	;asspuckc (94 $10)
	btst	#pfjoycon,pflags(a3)	;pfjoycon - check if controlled
	beq.w	assinsert	;jump if not
	rts
.nopc
	sub.b	d7,temp1(a3)	;subtract d7 (elapsed frames) from temp1
	bpl.w	.nodec	;jump if positive
	move.b	aioff(a3),temp1(a3)	;move aioff into temp1
	jsr	(ReadGoaliePulled).l	;check if goalie is pulled
	bmi.w	.bonus
	btst	#6,(sflags7).w	;check if crowd meter currently broken
	beq.w	.nopc2	;jump if not broken
	tst.b	$40(a3)	;check if temp1 is 0
	beq.w	.nopc2	;jump if so
.bonus
	subq.b	#1,$40(a3)	;subtract 1 from temp1
.nopc2
	btst	#5,(sflags6).w	;check if slot bit is set (puckc in slot)
	beq.w	.nopc3	;branch if not set
	move.w	(puckc).w,d1	;move puck carrier SCnum
	cmp.w	#5,d1	;check if its home (5 or less) or away (6-11)
	bgt.w	.pcaway	;jump if away
	btst	#6,$62(a3)	;pfteam
	beq.w	.nopc3	;jump if home
.tmnopc
	move.b	$40(a3),d1	;temp1 into d1
	ext.w	d1	;extend d1
	asr.w	#1,d1	;divide by 2
	move.b	d1,$40(a3)	;move d1 into temp1 - cutting the timer in half
	bne.w	.nopc3	;jump if not zero
	move.b	#1,$40(a3)	;move 1 into temp1
	bra.w	.nopc3
.pcaway
	btst	#6,$62(a3)	;pfteam - 0 home, 1 away
	beq.s	.tmnopc	;jump if home
.nopc3
	clr.l	$2A(a2)	;Calculated future Ypos of the player closest to the puck
	move.w	(puckc).w,d1	;move puck carrier SCnum into d1
	bmi.w	.np	;branch if no puck carrier
	asl.w	#7,d1	;scsize
	movea.w	#(SortCords-M68K_RAM),a1	;Move SortCords into a1
	adda.w	d1,a1	;use d1 as offset
	move.b	pflags(a1),d0	;pflags of puck carrier
	move.b	pflags(a3),d1	;pflags of current player
	eor.b	d0,d1	;XOR pflags
	btst	#pfteam,d1	;check pfteam
	beq.w	.switch	;branch if on same team
.np
	moveq	#-1,d2	;-1
	moveq	#5,d4	;5 = # of players on team
	movea.w	tmsort(a2),a0	;SortCord start value for team
.de0
	tst.w	position(a0)	;check if goalie
	ble.w	.next	;branch if goalie
	tst.b	nopuck(a0)	;check if nopuck (cant touch puck)
	bne.w	.next	;branch if nopuck timer not 0
	btst	#2,pflags2(a0)	;pf2unav - unavailable
	bne.w	.next	;branch if unavailable
	move.w	assnum(a0),d0	;assnum - current assignment
	cmpi.b	#$D,asslist(a0,d0.w)	;check if current assignment is asspassrec (94 $13)
	beq.w	.next	;branch if a0 is going to receive puck
	move.l	a0,-(sp)	;push onto stack
	jsr	(GetHot).l	;get hot spot
	add.w	(a0),d0	;Xpos to d0
	sub.w	(puckx).w,d0	;sub puck Xpos
	add.w	Ypos(a0),d1	;add Ypos to d1
	sub.w	(pucky).w,d1	;sub puck Ypos
	move.w	(puckvx).w,d3	;puckvx into d3
	asr.w	#6,d3	;divide by 64
	sub.w	d3,d0	;sub d3 from d0 (X distance between player and puck)
	move.w	(puckvy).w,d3	;puckvy into d3
	asr.w	#6,d3	;divide by 64
	sub.w	d3,d1	;sub d3 from d1 (Y distance between player and puck)
	muls.w	d0,d0	;square d0
	muls.w	d1,d1	;square d1
	add.l	d1,d0	;add d1 to d0
	cmp.l	d2,d0	;compare d2 to d0
	bhi.w	.next	;branch if d0 higher than d2 (0 or a positive # first run)
	move.l	d0,d2	;move d0 into d2
	movea.w	a0,a1	;move a0 address into a1
.next
	adda.w	#SCstruct,a0	;SCstruct size
	dbf	d4,.de0	;iterate through loop
	tst.l	d2	;check if 0
	bmi.w	.de1	;branch if less (no one near puck)
	move.l	d2,$2A(a2)	;moves d2 into $2A(a2)
.switch
	cmpa.w	a1,a3	;a1 = closest to the puck, or puckc (if on same team)
	beq.w	.de1	;branch if same
	btst	#gmclock,(gmode).w	;gmclock - 1 if stopped
	bne.w	.de1	;jump if stopped
	btst	#2,pflags2(a1)	;pf2unav
	bne.w	.de1	;jump if unavailable
	btst	#3,$64(a1)	;shooting one timer
	bne.w	.de1	;jump if shooting
	btst	#7,$64(a1)	;95: with bit 7 (assdefdchase) only when a1 has the puck, and clear it
	beq.w	.x1
	movem.w	d0,-(sp)
	move.w	SCnum(a1),d0
	cmp.w	(puckc).w,d0
	movem.w	(sp)+,d0
	bne.w	.de1
	bclr	#7,$64(a1)
.x1
	exg	a1,a3	;swap addresses
	bclr	#pfdoff,pflags(a3)	;clear pfdoff
	moveq	#$E,d0	;assnearest (94 $11)
	bsr.w	assinsert
	exg	a1,a3
	bra.w	assexit
.de1
	btst	#pfalock,pflags(a3)	;pfalock - check if locked in animation
	bne.w	rtsskate	;exit if locked
	moveq	#2,d1	;move 2 into d1
	cmp.w	#$190,d2	;compare $190 (20^2) to d2. d2 = distance to puck^2
	bhi.w	.nfar	;branch if d2 higher
	subq.w	#2,d1
	cmpi.w	#2,position(a3)	;compare if position is F or D (1 and 2 are D)
	bls.w	.nodec	;jump if D
.nfar
	btst	#sf2pwrplay,(sflags2).w	;sf2pwrplay - check if PP
	beq.w	.x	;branch if no PP
	subq.w	#2,d1	;sub 2 from d1
	bsr.w	chkpk2
	bne.w	.x	;branch if on PK
	addq.w	#4,d1	;add 4 to d1
.x
	move.w	#$28,d0	;'('   ; move $28 into d0 (40 dec)
	sub.b	$75(a3),d0	;sub checking from d0
	asl.w	d1,d0	;shift d0 by value of d1
	jsr	(randomd0).l	;RNG
	cmp.w	#2,d0	;compare 2 to d0
	bhi.w	.nodec	;branch if d0 more than 2
	move.w	#$F0,temp3(a3)	;move 240 dec into temp3
.nodec
	btst	#pfalock,pflags(a3)	;pfalock - check if anim lock
	bne.w	rtsskate	;exit if locked
	btst	#2,(BA_PS_flags).w	;check bit 2
	beq.w	.gmclock	;jump if not set
	btst	#5,(BA_PS_flags).w	;check bit 5
	beq.w	.nodec2	;jump if not set
.gmclock	;IDA: gmclock (a 92 equate name; local so it does not split assnearest or clash with the equate)
	btst	#0,(gmode).w	;check if clock running
	bne.w	assnothing	;branch if not
.nodec2
	btst	#pfjoycon,pflags(a3)	;pfjoycon - check if controlled
	bne.w	rtsskate	;jump if controlled
	btst	#2,tmflags(a2)	;check bit 2 of $30(a2)
	bne.w	.nodec22
	tst.w	(puckc).w	;check if theres a puck carrier
	bmi.w	.topuck	;jump if no puck carrier
	sub.w	d7,temp3(a3)	;subtract frames from temp3
	bpl.w	.topuck	;jump if positive
	clr.w	temp3(a3)	;clear temp3
.nodec22
	bsr.w	skatetopuckinit	;95: the future puck spot itself (94 took the middle of it and the goal)
	btst	#2,tmflags(a2)	;?? - doesn't seem to be set anywhere
	beq.w	.spdboost
	btst	#pfgoal,pflags(a3)	;pfgoal
	beq.w	.botshoot	;branch if bottom
	cmp.w	#$51,d1	;check if y pos of puck near blue line (94 $53)
	blt.w	.spdboost	;branch if in neutral zone or D zone
	move.w	#$42,d1	;94 $44
	bra.w	.spdboost
.botshoot
	cmp.w	#$FFAF,d1	;check if pucky near bottom blue line (94 $FFAD)
	bgt.w	.spdboost	;branch if in neutral zone or D zone
	move.w	#$FFBE,d1	;94 $FFBC
.spdboost
	btst	#5,(sflags6).w	;check if puckc is in the slot
	beq.w	.noslot	;branch if not
	move.b	$69(a3),(TempLegSpd).w	;legspd into TempLegSpd
	addq.b	#6,$69(a3)	;add 6 to legspd (95: no crowd meter boost)
	cmpi.b	#$1E,$69(a3)	;check speed limit
	ble.w	.cont
	move.b	#$1E,$69(a3)	;limit legspd to $1E (30 decimal)
.cont
	lea	rtsskate(pc),a0
	bsr.w	skateto
	move.b	(TempLegSpd).w,$69(a3)	;move original legpsd back into player
	bra.w	.chkslot
.noslot
	lea	rtsskate(pc),a0
	bsr.w	skateto
.chkslot
	btst	#5,(sflags6).w
	beq.w	.chkcont
	move.w	(pucky).w,d0
	move.w	$14(a3),d2	;Ypos into d2
	tst.w	d0	;check if d0 is 0
	bpl.w	.pospuck	;branch if positive
	neg.w	d0	;make d0 negative
	neg.w	d2	;make d2 negative
.pospuck
	sub.w	d0,d2	;sub d0 from d2 (equals how far puck is from player Ypos)
	cmp.w	#$A,d2	;check difference with A (10 decimal)
	blt.w	.exit
	move.w	(a3),d0	;Xpos of player (gets here if player is between net and puck carrier)
	sub.w	(puckx).w,d0	;sub puckx from Xpos
	bpl.w	.chkx	;branch if positive difference
	neg.w	d0	;make d0 negative
.chkx
	cmp.w	#$F,d0	;compare F (15 dec) with Xpos difference
	blt.w	.chkcont	;branch if less than (within 15 pix in X direction)
.exit
	rts
.chkcont
	btst	#5,(sflags6).w	;check if puckc is in the slot
	beq.w	check4check	;branch if not in slot
	move.b	$75(a3),d0	;move Chk into d0
	ext.w	d0	;clear top byte of d0
	movem.l	d0/a3,-(sp)	;push to stack
	add.b	d0,d0	;add d0 to itself
	cmp.b	#$1E,d0	;compare max Chk to d0
	blt.w	.chkcont2	;branch if less
	move.b	#$1E,d0	;move 1E into d0
.chkcont2
	move.b	d0,$75(a3)	;move d0 into Chk
	bsr.w	check4check
	movem.l	(sp)+,d0/a3	;pop off stack
	move.b	d0,$75(a3)	;move original Chk into player
	rts
.topuck
	bsr.w	skatetopuck

skatetopuckinit	;no IDA label (IDA dc.b). d0 / d1 = puck x / y half a step ahead
	move.b	(puckvx).w,d0
	asr.b	#1,d0
	ext.w	d0
	add.w	(puckx).w,d0
	move.b	(puckvy).w,d1
	asr.b	#1,d1
	ext.w	d1
	add.w	(pucky).w,d1
	rts

skatetopuck	;no IDA label (IDA dc.b). Skate a3 to the puck; a sweep check (Sweepcheck) close up. assgoalietopuck (checks95_01) enters here
	bsr.s	skatetopuckinit
	sub.b	d7,temp2(a3)	;temp2
	bpl.w	.ex
	addi.b	#$A,temp2(a3)	;temp2
	bsr.w	avdgoal
	movem.w	d0-d1,-(sp)
	move.l	a3,-(sp)
	jsr	(GetHot).l
	neg.b	d0
	neg.b	d1
	sub.b	Xvel(a3),d0	;Xvel
	ext.w	d0
	add.w	(sp)+,d0
	sub.w	(a3),d0	;Xpos
	sub.b	Yvel(a3),d1	;Yvel
	ext.w	d1
	add.w	(sp)+,d1
	sub.w	Ypos(a3),d1	;Ypos
	jsr	(vtoa).l
	move.b	d0,temp2+1(a3)	;temp2 lower byte
	tst.w	position(a3)
	beq.w	.ex
	move.w	(puckvx).w,d0
	move.w	(puckvy).w,d1
	jsr	(vtoa).l
	eori.w	#4,d0
	cmp.w	facedir(a3),d0	;facedir
	beq.w	.ex
	move.w	(puckx).w,d0
	sub.w	(a3),d0	;Xpos
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1	;Ypos
	movem.w	d0-d1,-(sp)
	jsr	(vtoa).l
	cmp.w	facedir(a3),d0	;$54 = facedir
	movem.w	(sp)+,d0-d1
	bne.w	.ex
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	cmp.l	#$384,d0	;#30^2
	bls.w	.ex
	cmp.l	#$5A4,d0	;#38^2
	bls.w	.sweep
.ex
	move.b	temp2+1(a3),d0
	jmp	(doplayeracc).l
.sweep
	jmp	(Sweepcheck).l

avdgoal	;no IDA label (IDA dc.b). Do not skate through the goal: correct d0 / d1. 95 goal line $101 (94 $FE)
	clr.w	(deltax).w
	clr.w	(deltay).w
	tst.w	position(a3)	;goalie? If so, quit
	beq.w	rtsskate	;94 rtss2
	move.w	(a3),d2	;Xpos
	eor.w	d0,d2
	bpl.w	.chbar
	move.w	d1,d2
	sub.w	Ypos(a3),d2	;Ypos
	move.w	(a3),d3	;Xpos
	muls.w	d3,d2
	sub.w	d0,d3
	divs.w	d3,d2
	add.w	Ypos(a3),d2	;Ypos
	cmp.w	#$124,d2	;.gl+.yr (95 .gl $101; 94 $FE)
	bgt.w	.chbar
	cmp.w	#$DE,d2	;.gl-.yr
	blt.w	.lower
	move.w	#$147,d3	;.gl+.yr+.ye
	cmp.w	#$101,d2	;.gl
	bgt.w	.2
	blt.w	.1
	cmpi.w	#$101,Ypos(a3)	;.gl, Ypos
	bgt.w	.2
.1
	move.w	#$BB,d3	;.gl-.yr-.ye
.2
	sub.w	d2,d3
	move.w	d3,(deltay).w
	bra.w	.chbar
.lower
	cmp.w	#$FF22,d2	;-.gl+.yr
	bgt.w	.chbar
	cmp.w	#$FEDC,d2	;-.gl-.yr
	blt.w	.chbar
	move.w	#$FF45,d3	;-.gl+.yr+.ye
	cmp.w	#$FEFF,d2	;-.gl
	bgt.w	.4
	blt.w	.3
	cmpi.w	#$FEFF,Ypos(a3)	;-.gl, Ypos
	bgt.w	.4
.3
	move.w	#$FEB9,d3	;-.gl-.yr-.ye
.4
	sub.w	d2,d3
	move.w	d3,(deltay).w
.chbar
	move.w	d1,d3
	subi.w	#$101,d3
	move.w	Ypos(a3),d2
	subi.w	#$101,d2
	bsr.w	.ch1
	move.w	d1,d3
	addi.w	#$101,d3
	move.w	Ypos(a3),d2
	addi.w	#$101,d2
	bsr.w	.ch1
	add.w	(deltax).w,d0
	add.w	(deltay).w,d1
	rts
.ch1
	move.w	d3,d4
	eor.w	d2,d4
	bpl.w	rtsskate	;94 rtss2
	move.w	d0,d4
	sub.w	(a3),d4	;Xpos
	muls.w	d2,d4
	sub.w	d3,d2
	divs.w	d2,d4
	add.w	(a3),d4	;Xpos
	cmp.w	#$50,d4	;'P'   ; #.xr
	bgt.w	rtsskate
	cmp.w	#$FFB0,d4	;#-.xr
	blt.w	rtsskate
	moveq	#$50,d3	;'P'   ; #.xr
	tst.w	d4
	bne.w	.ch2
	tst.w	(a3)	;Xpos
.ch2
	bpl.w	.ch3
	neg.w	d3
.ch3
	sub.w	d4,d3
	move.w	d3,(deltax).w
	rts

breakaway	;no IDA label (IDA dc.b). Breakaway for the carrier
	bset	#2,(sflags5).w
	bclr	#1,$62(a3)	;pfna - clear new assignment
	beq.w	.nna	;jump if no new assignment
	move.w	#1,-(sp)	;ding SFX
	jsr	(sfx).l
	movem.l	a2,-(sp)	;push a2 on stack
	movea.l	#HmShots,a2	;move Home Team Struct into a2
	btst	#6,$62(a3)	;pfteam - check if home or away
	beq.w	.c0	;jump if home
	movea.l	#AwShots,a2	;move Away Team Struct into a2
.c0
	addq.w	#1,$35A(a2)	;add one to breakaway attempt (94 $358)
	addi.w	#$14,(CwdExciteLvl).w	;add to CwdExcite
	addi.w	#$C8,(crowdlevel).w	;add to crowdlevel
	movem.l	(sp)+,a2
.nna
	movem.w	d1,-(sp)	;push d1 on stack
	move.w	$14(a3),d0	;move Ypos into d0
	move.w	$2A(a3),d1	;move Yvel into d1
	beq.w	.yvel0	;jump if Yvel = 0
	eor.w	d1,d0	;EOR d1 with d0. d0 will be negative if skating opposite direction of net
.exit
	movem.w	(sp)+,d1	;pop d1 off stack
	rts
.yvel0
	move.w	#$FFFF,d1
	bra.s	.exit
BreakawayOffsidesFlagSet	;no IDA label (IDA dc.b). 94 name: the breakaway / offsides flags of a3 ($64 bits 1 and 0)
	btst	#1,$62(a3)	;check for new assignment
	beq.w	.loadYpos	;branch if no new assignment
	bclr	#0,$64(a3)	;clear player offsides flag
	bclr	#1,$64(a3)	;clear player breakaway flag
.loadYpos
	movem.w	d0-d1/a0,-(sp)
	move.w	#$10B,d0	;top goal line Y pos (94 $108)
	move.w	$14(a3),d1	;Ypos
	bpl.w	.cmpgoalline	;branch if Ypos is positive
	neg.w	d1	;negate d1
.cmpgoalline
	cmp.w	d0,d1	;compare position to top goal line
	bge.w	.nogood	;Branch if above it
	move.w	#$56,d0	;top blue line Y pos (94 $58)
	move.w	$14(a3),d1	;Ypos
	btst	#7,$62(a3)	;check goal to shoot on (0=bottom, 1=top)
	bne.w	.top	;branch if top goal
	neg.w	d0	;bottom goal, so negate d0
	cmp.w	d1,d0	;compare Ypos to blue line Y
	blt.w	.setoffside	;branch if not in attack zone
	bra.w	.offzone	;branch if in attack zone
.top
	cmp.w	d1,d0	;compare Ypos to blue line Y
	blt.w	.offzone	;branch if in offensive zone
.setoffside
	bset	#0,$64(a3)	;set offsides flag
	bra.w	.nogood
.offzone
	bclr	#0,$64(a3)	;clear offside bit
	beq.w	.nogood	;branch if on the blue line
	movea.l	#SortCords+(11*SCstruct),a0	;loads last SCScruct player struct (Away pos #6)
	move.w	#$B,d0	;B = # of player structs to check (12)
	tst.w	d1	;checks if d1 is negative (determines what zone to check)
	bmi.w	.checkYpos
.checkYpos2
	cmp.w	$14(a0),d1	;compare Ypos of a0 player to d1 (Ypos puckc)
	bge.w	.substruct2	;branch if d1 greater than or equal
	tst.w	$34(a0)	;check if goalie
	beq.w	.substruct2	;branch if goalie
	bra.w	.nogood
.substruct2
	suba.w	#$80,a0
	dbf	d0,.checkYpos2
.setBAbit
	bset	#1,$64(a3)	;set breakaway bit
	move.w	#1,d0	;moves 1 into d0 (used by returned subroutine)
.exit
	movem.w	(sp)+,d0-d1/a0
	rts
.nogood
	move.w	#0,d0	;move 0 into d0 (used on return to subroutine)
	bra.s	.exit
.checkYpos
	cmp.w	$14(a0),d1	;check Ypos with d1 (d1 = blue line Y)
	ble.w	.substruct
	tst.w	$34(a0)	;checks if goalie (who would be below blue line)
	beq.w	.substruct
	bra.s	.nogood
.substruct
	suba.w	#$80,a0	;subtract SCstruct size (80 hex)
	dbf	d0,.checkYpos
	bra.s	.setBAbit

chkpuckc	;no IDA label (IDA dc.b), asstab entry $1E. Breakaway carrier check, then asspuckc
	btst	#0,(gmode2).w
	bne.w	.0
	btst	#2,(BA_PS_flags).w
	bne.w	.0
	bsr.w	breakaway
	bpl.w	asspuckc	;currently skating towards net in Y
.0
	bclr	#1,$64(a3)	;clear breakaway bit
	move.w	#$F,d0	;asspuckc (94 $10)
	bsr.w	assreplace

asspuckc	;no IDA label (IDA dc.b), asstab entry $F. The puck carrier. 95: a penalty shot SPA while a message is up, Practice Mode breakaways
	bclr	#2,(sflags5).w
	bne.w	.0
	bclr	#1,$64(a3)
.0
	move.w	(puckc).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	assexit
	btst	#2,(BA_PS_flags).w
	beq.w	.1
	cmpi.w	#1,(msgtimer).w
	ble.w	.1
	move.w	#$B5C,d1	;95: in a penalty shot with a message up, this SPA
	jsr	(SetSPA).l
	bra.w	.x
.1
	btst	#1,$64(a3)
	bne.w	.2
	btst	#2,(BA_PS_flags).w
	bne.w	.2
	btst	#7,(sflags9).w	;95: always a breakaway in Practice Mode
	bne.w	.br
	jsr	(BreakawayOffsidesFlagSet).l
	beq.w	.2	;branch if breakaway flag not set
.br
	move.w	#$1E,d0	;chkpuckc assignment (94 $21)
	bsr.w	assreplace
	bra.w	*+4
.2
	btst	#5,$62(a3)
	bne.w	rtsskate	;94 rtss2
	btst	#2,(BA_PS_flags).w
	bne.w	.3
	btst	#0,(gmode).w
	bne.w	assnothing
.3
	btst	#3,$62(a3)
	bne.w	assexit
	bclr	#1,$62(a3)
	beq.w	.7
	btst	#1,$64(a3)
	beq.w	.4
	move.w	#1,-(sp)
	jsr	(sfx).l
.4
	btst	#1,$64(a3)
	beq.w	.6
	movem.l	a2,-(sp)
	movea.l	#HmShots,a2
	btst	#6,$62(a3)
	beq.w	.5
	movea.l	#AwShots,a2
.5
	addq.w	#1,$35A(a2)	;94 $358
	addi.w	#$14,(CwdExciteLvl).w
	addi.w	#$C8,(crowdlevel).w
	movem.l	(sp)+,a2
.6
	clr.w	temp1(a3)
	move.w	#8,temp2(a3)
	move.w	(VDP_CNTR).l,d0
	andi.w	#3,d0
	move.w	d0,temp3(a3)
.7
	sub.b	d7,temp1(a3)
	bpl.w	.nodec
	move.b	aioff(a3),temp1(a3)
	jsr	(ReadGoaliePulled).l
	bmi.w	.8
	btst	#6,(sflags7).w
	beq.w	.9
	tst.b	$40(a3)
	beq.w	.9
.8
	subq.b	#1,$40(a3)
.9
	btst	#2,(BA_PS_flags).w
	bne.w	.12
	btst	#0,(gmode2).w
	bne.w	.12
	jsr	(checkob).l
	jsr	(AutoLineChange).l
	btst	#0,(gmode2).w
	bne.w	.12
	btst	#2,(BA_PS_flags).w
	bne.w	.12
	btst	#1,$64(a3)
	bne.w	.11
	move.w	#1,d0
	btst	#6,$62(a3)
	beq.w	.10
	move.w	#2,d0
.10
	cmp.w	(cont1team).w,d0
	beq.w	.11
	cmp.w	(cont2team).w,d0
	beq.w	.11
	btst	#1,(vcount+1).w
	bne.w	.13
.11
	bsr.w	chk4shot
	bra.w	.13
.12
	jsr	(ShootoutShootCheck).l
	bne.w	.nodec
	jsr	(compshoot).l
.13
	bsr.w	chk4pass
.nodec
	moveq	#6,d0
	add.w	temp3(a3),d0	;add temp3 to d0
	lea	.postab2(pc),a0
	btst	#sf2offsig,(sflags2).w	;#sf2offsig
	beq.w	.nd1
	move.w	position(a3),d0	;position
.nd1
	asl.w	#2,d0
	move.w	2(a0,d0.w),d1
	move.w	0(a0,d0.w),d0
	btst	#2,(BA_PS_flags).w
	bne.w	.14
	btst	#0,(gmode2).w
	beq.w	.15
.14
	jsr	(SkatePath).l
	cmpi.b	#$80,(sopathx).w
	beq.w	.x
.15
	btst	#7,pflags(a3)	;pfgoal - 0 for bottom 1 for top
	bne.w	.nd0
	neg.w	d0
	neg.w	d1
.nd0
	lea	.chkdir(pc),a0
	btst	#2,(BA_PS_flags).w
	bne.w	.16
	btst	#0,(gmode2).w
	beq.w	.17
.16
	lea	.x(pc),a0
.17
	bra.w	skateto
.chkdir
	ext.w	d0
	move.b	Xvel(a3),d2	;Xvel
	ext.w	d2
	add.w	(puckx).w,d2
	move.b	Yvel(a3),d3	;Yvel
	ext.w	d3
	add.w	(pucky).w,d3
	clr.w	(threat).w
	moveq	#5,d4
	movea.w	#(SortCords-M68K_RAM),a0
	cmpi.w	#6,SCnum(a3)
	bge.w	.loop
	adda.w	#6*SCstruct,a0	;away team SCstruct start
.loop
	move.b	Xvel(a0),d1	;Xvel
	ext.w	d1
	add.w	(a0),d1	;Xpos
	sub.w	d2,d1
	cmp.w	#$14,d1
	bgt.w	.next
	cmp.w	#$FFEC,d1
	blt.w	.next
	move.b	Yvel(a0),d1	;Yvel
	ext.w	d1
	add.w	Ypos(a0),d1	;Ypos
	sub.w	d3,d1
	cmp.w	#$14,d1
	bgt.w	.next
	cmp.w	#$FFEC,d1
	blt.w	.next
	addq.w	#1,(threat).w
	move.w	(a3),d0	;Xpos
	sub.w	(a0),d0
	move.w	Ypos(a3),d1	;Ypos
	sub.w	Ypos(a0),d1
	jsr	(vtoa).l
	move.w	facedir(a3),d1	;facedir
	eori.w	#4,d1
	cmp.w	d0,d1
	bne.w	.next
	move.w	(VDP_CNTR).l,d1
	andi.w	#1,d1
	add.w	d1,d0
	andi.w	#7,d0
.next
	adda.w	#SCstruct,a0	;SCstruct size
	dbf	d4,.loop
.x
	rts
.postab2	dc.w	$FF9C
	dc.w	$FFEC
	dc.w	$64
	dc.w	$FFEC
	dc.w	$FF88
	dc.w	$28
	dc.w	$14
	dc.w	$28
	dc.w	$78
	dc.w	$28
	dc.w	$FFEC
	dc.w	$28
	dc.w	$FFD8
	dc.w	$F3	;94 $F0
	dc.w	0
	dc.w	$DF	;94 $DC
	dc.w	$14
	dc.w	$E9	;94 $E6
	dc.w	$1E
	dc.w	$E9	;94 $E6

chk4shot	;no IDA label (IDA dc.b). Shoot or clear the puck; compshoot is in input95_01. 95: the breakaway deke always in Practice Mode
	jsr	(chkpk).l
	bne.w	.pkill	;killing penalty
	tst.w	(threat).w
	beq.w	.pkill	;no threat
	move.w	(VDP_CNTR).l,d0
	andi.w	#3,d0
	bne.w	.pkill
	move.w	#$56,d0	;top blue line Y position (94 $58)
	btst	#7,$62(a3)
	beq.w	.cmphome
	move.w	#$FFAA,d0	;bottom blue line Y pos (94 $FFA8)
	cmp.w	$14(a3),d0
	bge.w	.0
.clear
	jmp	(compshoot).l	;clear puck
.cmphome
	cmp.w	$14(a3),d0
	bgt.s	.clear	;clear puck
.0
	bset	#3,(sflags5).w
	jmp	(dopass).l
.pkill
	btst	#7,(sflags9).w	;95: the breakaway deke always in Practice Mode
	bne.w	.dk
	btst	#1,$64(a3)
	beq.w	.npk
.dk
	move.w	#$1E,d0
	jsr	(randomd0).l
	addi.w	#$82,d0
	cmp.w	(pucky).w,d0
	blt.w	.1
	neg.w	d0
	cmp.w	(pucky).w,d0
	bgt.w	.1
	bra.w	.npk
.1
	move.w	#2,d0
	jsr	(randomd0s).l
	add.w	$54(a3),d0
	andi.w	#7,d0
	move.w	d0,$54(a3)
	bra.w	compshoot
.npk
	moveq	#$20,d4
	clr.w	d1
	move.b	$70(a3),d1
	lsr.w	#1,d1
	sub.b	d1,d4
	asl.w	#4,d4
	move.w	#$10B,d1	;top goal line Y (94 $108)
	btst	#7,pflags(a3)
	bne.w	.c0
	neg.w	d1
.c0
	sub.w	(pucky).w,d1
	move.w	(puckx).w,d0
	neg.w	d0
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1
	cmp.l	#$2710,d1
	movem.w	(sp)+,d0-d1
	bhi.w	.no1
	lsr.w	#4,d4
	jsr	(vtoa).l
	move.w	d0,d5
	moveq	#5,d3
	movea.w	#(SortCords-M68K_RAM),a1
	cmpi.w	#6,SCnum(a3)
	bge.w	.loop
	adda.w	#6*SCstruct,a1
.loop
	tst.w	position(a1)
	beq.w	.2
	move.w	(a1),d0
	sub.w	(puckx).w,d0
	move.w	Ypos(a1),d1
	sub.w	(pucky).w,d1
	jsr	(vtoa).l
	cmp.w	d5,d0
	bne.w	.co1
	asl.w	#1,d4
	bra.w	.co1
.2
	btst	#1,pflags2(a1)
	beq.w	.g0
	bra.w	.g1
.g0
	bra.w	.co1	;95: the goalie position checks after this are dead
	cmpi.w	#$1A,(a1)
	bgt.w	.g1
	cmpi.w	#$FFE6,(a1)
	blt.w	.g1
	cmpi.w	#$10B,Ypos(a1)
	bgt.w	.g1
	cmpi.w	#$FEF5,Ypos(a1)
	blt.w	.g1
	cmpi.w	#$CF,Ypos(a1)
	bgt.w	.co1
	cmpi.w	#$FF31,Ypos(a1)
	blt.w	.co1
.g1
	clr.w	d3
	move.w	#1,d4
.co1
	adda.w	#SCstruct,a1
	dbf	d3,.loop
.no1
	move.w	d4,d0
	jsr	(randomd0).l
	btst	#0,$70(a3)
	beq.w	.3
	cmp.w	#7,d0
	bgt.w	rtsskate
	bra.w	.4
.3
	cmp.w	#8,d0
	bgt.w	rtsskate
.4
	move.w	(pucky).w,d0
	btst	#7,pflags(a3)
	bne.w	.ds0
	neg.w	d0
.ds0
	tst.w	d0
	bmi.w	rtsskate
	move.w	#$10B,d1	;94 $108
	sub.w	d0,d1
	bmi.w	rtsskate
	btst	#sf2offsig,(sflags2).w
	bne.w	rtsskate
	jmp	(compshoot).l

chk4pass	;no IDA label (IDA dc.b). Pass to a free teammate (dopass)
	tst.w	(threat).w
	bne.w	.dp0
	moveq	#$10,d0
	add.b	spodds(a3),d0
	jsr	(randomd0).l
	cmp.w	#$C,d0
	bgt.w	rtsskate
.dp0
	moveq	#6,d0
	jsr	(randomd0).l
	cmpi.w	#6,SCnum(a3)
	blt.w	.0
	addq.w	#6,d0
.0
	tst.w	position(a3)
	beq.w	.1
	cmpi.w	#$28,(puckx).w
	bgt.w	.1
	cmpi.w	#$FFD8,(puckx).w
	blt.w	.1
	cmpi.w	#$CF,(pucky).w
	bgt.w	rtsskate
	cmpi.w	#$FF31,(pucky).w
	blt.w	rtsskate
.1
	cmp.w	SCnum(a3),d0
	beq.w	rtsskate
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a0
	adda.w	d0,a0
	tst.w	position(a0)
	ble.w	rtsskate
	btst	#2,pflags2(a0)
	bne.w	rtsskate
	btst	#pfalock,pflags(a0)
	bne.w	rtsskate
	move.w	Ypos(a0),d0
	move.w	Ypos(a3),d1
	btst	#7,pflags(a3)
	bne.w	.f0
	neg.w	d0
	neg.w	d1
.f0
	btst	#gmoffs,(gmode).w
	beq.w	.oko
	movem.w	d0-d1,-(sp)
	subi.w	#$56,d0	;blue line (94 $58)
	subi.w	#$56,d1
	eor.w	d0,d1
	movem.w	(sp)+,d0-d1
	bmi.w	rtsskate
.oko
	cmp.w	#$56,d0	;94 $58
	bgt.w	.ok
	sub.w	d1,d0
	cmp.w	#$FFF1,d0
	blt.w	rtsskate
.ok
	move.w	(a0),d0
	sub.w	(puckx).w,d0
	move.w	Ypos(a0),d1
	sub.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	jsr	(vtoa).l
	move.w	d0,(passdir).w
	movem.w	(sp)+,d1-d2
	muls.w	d1,d1
	muls.w	d2,d2
	add.l	d1,d2
	moveq	#5,d3
	movea.w	#(SortCords-M68K_RAM),a1
	cmpi.w	#6,SCnum(a3)
	bge.w	.co0
	adda.w	#6*SCstruct,a1
.co0
	move.w	(a1),d0
	sub.w	(puckx).w,d0
	move.w	Ypos(a1),d1
	sub.w	(pucky).w,d1
	movem.w	d0-d1,-(sp)
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d0,d1
	cmp.l	d2,d1
	movem.w	(sp)+,d0-d1
	bhi.w	.co1
	jsr	(vtoa).l
	cmp.w	(passdir).w,d0
	beq.w	rtsskate
.co1
	adda.w	#SCstruct,a1
	dbf	d3,.co0
	bsr.w	dopass
	tst.w	position(a3)
	beq.w	rtsskate
	addq.w	#4,sp
	bra.w	assexit

check4bench	;no IDA label (IDA dc.b). input94 check4bench (moved in): go to the bench for a line change, or take the new position
	btst	#2,(BA_PS_flags).w
	bne.w	rtsskate
	btst	#3,$62(a3)
	bne.w	rtsskate
	btst	#4,$63(a3)
	bne.w	rtsskate
	tst.b	newpos(a3)
	bpl.w	.0
	tst.b	newpnum(a3)
	bmi.w	rtsskate
.0
	move.b	newpnum(a3),d0
	cmp.b	pnum(a3),d0
	beq.w	.samepl
	move.w	assnum(a3),d0
	cmpi.b	#$12,asslist(a3,d0.w)	;assbench (94 $B)
	beq.w	rtsskate
	move.w	$52(a3),d0
	cmp.w	(puckc).w,d0
	beq.w	rtsskate
	addq.w	#4,sp
	bset	#2,pflags2(a3)	;set player unavailable (pf2unav)
	clr.w	temp1(a3)
	moveq	#$12,d0	;assbench (94 $B)
	bra.w	assreplace
.samepl
	addq.w	#4,sp
	bclr	#2,pflags2(a3)
	bclr	#pfnc,pflags(a3)
	st	newpnum(a3)
	st	newpos(a3)
	move.w	position(a3),d0
	tst.b	newpos(a3)
	bpl.w	.1
	jmp	(Setplass).l
.1
	move.b	newpos(a3),d0
	ext.w	d0
	move.w	d0,position(a3)
	jmp	(Setplass).l
