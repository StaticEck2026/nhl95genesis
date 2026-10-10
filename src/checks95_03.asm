;	NHL 95 checks95_03. Retail $082FFA-$0836AB (1714 bytes).
;	94 checks94 assgoaliectrl, a2offsides, assign94 asseben (moved in), the 95 assdefdchase, cards94 setSlotBit (moved in), assign94
;	assscore and assgoaliebreakwait (moved in), then checks94 ChkGoalies, ReturnGoalies, CPgoalie. 94 assgoaliecpu is in checks95_01.
;	CPgoalie runs to $0836AB, past the mapped end $08369D (IDA loc_8369E is its .0): collide95_02 starts at $0836AC.
;	IDA left most of the range as dc.b; it is code here, read from the retail bytes. IDA code: setSlotBit (sub_833FE), ChkGoalies
;	(sub_835C6), ReturnGoalies and CPgoalie (sub_835E2 ... loc_8369E).
;	95 changes: the 95 asstab numbers, SPA values and limits (the comments give the 94 values), jsr / jmp .l to the routines 95 moved out
;	of range, the shared rtsskate (checks95_02) in place of rtss2 / rtss4, the team defense mode (assdefdchase), the scorer's
;	celebration in assscore.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

assgoaliectrl	;no IDA label (IDA dc.b), asstab entry $1B (94 $1D). The joystick goalie: a stoppage when he leaves his area, else
	;checkanim (checks95_01) when out of the screen box. 95: rtsskate in place of rtss2
	btst	#3,$62(a3)	;is player joystick controlled?
	bne.w	.goaliectrl	;branch is so
	bra.w	assexit
.goaliectrl
	btst	#1,$62(a3)	;check if new assignment
	bne.w	.na	;branch if new assignment
	movem.w	d0-d1,-(sp)	;push to stack
	move.w	(a3),d0	;Xpos
	move.w	$14(a3),d1	;Ypos
	cmp.w	#$AA,d1	;compare $AA to Ypos
	bgt.w	.cont
	cmp.w	#$FF56,d1	;check -$AA to Ypos
	blt.w	.cont	;branch if less than
	btst	#0,(gmode).w	;check if clock stopped
	bne.w	.cont	;branch if so
	move.w	d0,-(sp)	;push to stack
	move.w	#8,d0	;clock stoppage due to goalie out of range
	jsr	(AddPenalty2).l
	move.w	(sp)+,d0	;pop from stack
.cont
	sub.w	(Hpos).w,d0	;sub ice rink horiz position from Xpos
	sub.w	(Vpos).w,d1	;sub ice rink vert position from Ypos
	bclr	#2,$64(a3)	;clear goalie control bit?
	cmp.w	#$74,d0	;'t'   ; compare $74 to Xpos diff
	blt.w	.0	;branch if less than
	bset	#2,$64(a3)	;set goalie control bit?
	bra.w	.cont2
.0
	cmp.w	#$FF8C,d0	;compare -$74 to Xpos diff
	bgt.w	.1	;branch if greater than
	bset	#2,$64(a3)	;set goalie control bit?
	bra.w	.cont2
.1
	cmp.w	#$64,d1	;'d'   ; compare $64 to Ypos diff
	blt.w	.2	;branch if less than
	bset	#2,$64(a3)	;set goalie control bit?
	bra.w	.cont2
.2
	cmp.w	#$FF9C,d1	;compare -$64 to Ypos diff
	bgt.w	.cont2	;branch if greater than
	bset	#2,$64(a3)	;set goalie control bit?
.cont2
	movem.w	(sp)+,d0-d1	;pop from stack
	btst	#2,$64(a3)	;check goalie ctrl bit
	bne.w	checkanim	;branch if set
.na
	btst	#5,$62(a3)	;check if anim lock
	bne.w	rtsskate	;exit if so
	bsr.w	check4bench
	bclr	#1,$62(a3)	;clear new assignment bit
	beq.w	.nna	;branch if already cleared
	clr.w	$40(a3)	;clear temp1
	move.w	#8,$42(a3)	;move 8 into temp2
	st	$46(a3)	;FFFF to temp4
.nna
	btst	#1,$63(a3)	;check if anim in progress
	bne.w	rtsskate	;exit if so
	btst	#0,(gmode).w	;check if clock stopped
	bne.w	rtsskate	;exit if so
	tst.w	$48(a3)	;test temp5
	bmi.w	.nofo	;branch if less than 0
	move.w	$52(a3),d0	;move SCnum into d0
	cmp.w	(puckc).w,d0	;check if puckc is goalie
	beq.w	.mbfo	;branch if equal
	st	$48(a3)	;set temp5 to -1
	bra.w	.nofo
.mbfo
	sub.w	d7,$48(a3)	;subtract d7(frames elapsed) from temp5
	bpl.w	.nofo	;branch if more than 0
	btst	#2,(BA_PS_flags).w	;check bit 2
	beq.w	.stoppage	;branch if not set
	bset	#4,(BA_PS_flags).w
	bra.w	.nofo
.stoppage
	move.l	#8,d0
	jsr	(AddPenalty2).l
.nofo
	sub.b	d7,$40(a3)	;sub d7(frames elapsed) from temp1
	bpl.w	.ex	;branch if positive
	move.b	$6B(a3),d0	;DfA into d0
	beq.w	.3	;branch if value was 0
	btst	#6,(sflags7).w	;check if crowd meter broken
	beq.w	.3	;jump if not
	subq.b	#1,d0	;sub 1 from d0
.3
	lsr.b	#2,d0	;divide by 4
	move.b	d0,$40(a3)	;move d0 into temp1
	move.w	$52(a3),d0	;move SCnum into d0
	cmp.w	(puckc).w,d0	;compare puckc to d0
	beq.w	*+4	;jump to assgoaliecpu if the same
.ex
	rts
; a3 = goalie

a2offsides	;no IDA label (IDA dc.b). Offsides on a2 (AddPenalty $10) when his team is offside and the puck is past the blue line ($6A;
	;94 $68). Called from a2touchpuck (checks95_02)
	btst	#gmoffs,(gmode).w
	beq.w	.x
	move.w	(pucky).w,d0
	btst	#pfgoal,pflags(a2)
	bne.w	.0
	neg.w	d0
.0
	cmp.w	#$6A,d0	;94 $68
	blt.w	.x
	movea.w	#(HmShots-M68K_RAM),a0
	btst	#pfteam,pflags(a2)
	beq.w	.1
	adda.w	#tmsize,a0
.1
	btst	#4,tmflags(a0)
	beq.w	.x
	btst	#gmhl,(gmode).w
	bne.w	.x
	exg	a2,a3
	move.l	#$10,d0
	jsr	(AddPenalty).l
	exg	a2,a3
.x
	rts

asseben	;no IDA label (IDA dc.b), asstab entry $13 (94 9). assign94 asseben (moved in; IDA 94 assben). Player a3 should exit the bench area.
	;95: x $98 (94 $88), facedir 7 (94 2), SPA $1E2A (94 $F6E)
	btst	#5,$62(a3)
	bne.w	.x	;94 rtss4
	bclr	#1,pflags(a3)
	beq.w	.1
	clr.w	Xvel(a3)
	clr.w	Yvel(a3)
	move.w	SCnum(a3),d0
	subq.w	#6,d0
	bmi.w	.0
	addq.w	#1,d0
.0
	muls.w	#$E,d0
	move.w	d0,Ypos(a3)
	move.w	#$98,(a3)	;94 $88
	neg.w	(a3)
	move.w	#7,facedir(a3)	;94 2
	bset	#5,pflags(a3)
	move.w	#$1E2A,d1	;95 SPA (94 $F6E)
	jmp	(SetSPA).l
.1
	move.w	#4,facedir(a3)
	bclr	#pfnc,pflags(a3)
	bclr	#5,pflags2(a3)
	bclr	#2,pflags2(a3)
	clr.w	SPA(a3)
	move.w	#$1000,Xvel(a3)
	bra.w	assexit
.x
	rts

assdefdchase	;no IDA label (IDA dc.b). 95 only. assdefd with the team defense mode at 1 and the other team on the puck: set $64 bit 7
	;(assnearest takes that). Within $1E of the puck with the carrier in the slot (sflags6 bit 5): skate at the carrier (or the loose
	;puck) half a step ahead. Puck in the defensive zone: the right defenseman takes the slot ($D9 out), the left one the middle between
	;the puck and the goal line. Else hold $26 off the middle at $C8 from the puck toward his goal, no deeper than the other forwards
	;(.lim). Then skateto and check4check2 with sflags10 bit 7 set
	bset	#7,$64(a3)
	move.w	(puckx).w,d0
	sub.w	(a3),d0
	bpl.w	.0
	neg.w	d0
.0
	cmp.w	#$1E,d0
	bgt.w	.far
	move.w	(pucky).w,d0
	sub.w	Ypos(a3),d0
	bpl.w	.1
	neg.w	d0
.1
	cmp.w	#$1E,d0
	bgt.w	.far
	btst	#5,(sflags6).w	;puck carrier in the slot
	beq.w	.far
	move.l	a2,-(sp)
	movea.l	#SortCords,a2
	move.w	(puckc).w,d0
	bpl.w	.2
	adda.l	#$E*SCstruct,a2	;no carrier: the puck
	bra.w	.3
.2
	asl.w	#7,d0
	adda.w	d0,a2
.3
	move.b	Xvel(a2),d0	;half a step ahead of it
	asr.b	#1,d0
	ext.w	d0
	add.w	(a2),d0
	move.b	Yvel(a2),d1
	asr.b	#1,d1
	ext.w	d1
	add.w	Ypos(a2),d1
	movea.l	(sp)+,a2
	move.w	#0,temp2(a3)
	bra.w	.go
.far
	move.w	#$56,d0	;puck inside the own blue line?
	add.w	(pucky).w,d0
	btst	#7,pflags(a3)
	beq.w	.4
	move.w	#$56,d0
	sub.w	(pucky).w,d0
.4
	tst.w	d0
	bmi.w	.out
	subq.b	#5,temp1(a3)
	cmpi.w	#2,position(a3)
	beq.w	.rd
	move.w	#$10B,d1	;left defenseman: halfway between the puck and the goal line
	sub.w	(pucky).w,d1
	btst	#7,pflags(a3)
	beq.w	.5
	move.w	#$FEF5,d1
	sub.w	(pucky).w,d1
.5
	asr.w	#1,d1
	add.w	(pucky).w,d1
	move.w	(puckx).w,d0
	asr.w	#1,d0
	bra.w	.go
.rd
	move.w	#$D9,d1	;right defenseman: the slot
	clr.w	d0
	btst	#7,pflags(a3)
	beq.w	.6
	neg.w	d1
.6
	bra.w	.go
	dc.w	0,-1,-1,-1,-1,1,1,1	;unused
.out
	move.w	#$26,d0
	cmpi.w	#2,position(a3)
	beq.w	.7
	neg.w	d0
.7
	move.w	#$FF38,d1
	tst.w	(pucky).w
	bpl.w	.8
	neg.w	d0
	neg.w	d1
.8
	add.w	(pucky).w,d1
	bsr.w	.lim
	bra.w	.go
.go
	lea	rtss21(pc),a0
	move.w	d0,temp3(a3)
	move.w	d1,temp4(a3)
	bsr.w	skateto
	bset	#7,(sflags10).w
	bsr.w	check4check2
	bclr	#7,(sflags10).w
	rts
	lea	rtss21(pc),a0	;unused
	move.w	d0,temp3(a3)
	move.w	d1,temp4(a3)
	bra.w	skateto
.lim	;d1 no deeper than $32 past the deepest available player of the other team (by net)
	move.w	d2,-(sp)
	move.w	d1,d3
	move.w	#5,d4
	btst	#7,pflags(a3)
	bne.w	.dn
	movea.l	#SortCords,a0
	btst	#6,pflags(a3)
	bne.w	.l0
	adda.w	#6*SCstruct,a0
.l0
	btst	#pfnc,pflags(a0)
	bne.w	.l1
	move.w	Ypos(a0),d2
	addi.w	#$32,d2
	cmp.w	d2,d3
	bgt.w	.l1
	move.w	d2,d3
.l1
	adda.w	#SCstruct,a0
	dbf	d4,.l0
	bra.w	.lx
.dn
	movea.l	#SortCords,a0
	btst	#6,pflags(a3)
	bne.w	.l2
	adda.w	#6*SCstruct,a0
.l2
	btst	#pfnc,pflags(a0)
	bne.w	.l3
	move.w	Ypos(a0),d2
	subi.w	#$32,d2
	cmp.w	d2,d3
	blt.w	.l3
	move.w	d2,d3
.l3
	adda.w	#SCstruct,a0
	dbf	d4,.l2
.lx
	move.w	d3,d1
	move.w	(sp)+,d2
	rts

setSlotBit	;IDA: sub_833FE. cards94 setSlotBit (moved in; IDA name and comments). sflags6 bit 5 (the slot) = the puck carrier is in the slot
	;in front of the goal (blue line $56; 94 $58). Called from DoGameFrame (hockey95)
	bclr	#5,(sflags6).w	;clears Slot Bit
	tst.w	(puckc).w
	bmi.w	.ex	;exit if no puckc
	movem.l	d0/a0,-(sp)
	movea.l	#SortCords,a0	;start of SCStructs
	move.w	(puckc).w,d0	;move puckc SCnum into d0
	asl.w	#7,d0	;mult by 128 decimal
	adda.w	d0,a0	;move to start of puckc SCstruct
	move.w	$14(a0),d0	;Ypos
	btst	#7,$62(a0)	;pfgoal - which goal shooting at
	bne.w	.checkpos	;jump if top goal
	neg.w	d0	;negative d0
.checkpos
	cmp.w	#$56,d0	;compare to blueline (94 $58)
	blt.w	.restore	;branch if not in off zone
	cmpi.w	#$47,(a0)	;'G' ; compare X position to $47
	bgt.w	.restore	;branch if greater than 47
	cmpi.w	#$FFB9,(a0)	;compare X position to -$47
	blt.w	.restore	;branch if less than -47
	bset	#5,(sflags6).w	;set bit
.restore
	movem.l	(sp)+,d0/a0
.ex
	rts

assscore	;no IDA label (IDA dc.b), asstab entry $1C (94 7). assign94 assscore (moved in). Players after a goal: skate to the scoring end,
	;celebrate. 95: the scorer, still skating fast ($5000 or more), does the celebration SPA $28DE at once; the scorer's pump is one of
	;two SPAs (.pumps)
	btst	#5,$62(a3)
	bne.w	.x	;94 assfwatch
	bclr	#1,pflags(a3)
	beq.w	.nna
	bsr.w	.1
	move.w	#8,temp2(a3)
	move.w	#$5A,temp3(a3)
	tst.w	(Hpos).w
	bpl.w	.0
	neg.w	temp3(a3)
.0
	move.w	(Vpos).w,temp4(a3)
	move.w	(shotplayer).w,d0	;95: the scorer at speed
	cmp.w	SCnum(a3),d0
	bne.w	.nna
	move.w	Xvel(a3),d1
	bpl.w	.5
	neg.w	d1
.5
	move.w	Yvel(a3),d0
	bpl.w	.6
	neg.w	d0
.6
	add.w	d0,d1
	cmp.w	#$5000,d1
	blt.w	.nna
	move.w	#$78,temp1(a3)
	bset	#5,pflags(a3)
	move.w	#$28DE,d1
	jsr	(SetSPA).l
.nna
	movea.l	#.x,a0	;94 rtss2
	move.w	temp3(a3),d0
	move.w	temp4(a3),d1
	btst	#0,(gmode2).w	;start of code not in 92
	beq.w	.4
	tst.w	(shootoutdelay).w
	beq.w	.2
	subq.w	#1,(shootoutdelay).w
	bne.w	.2
	bset	#2,(sflags2).w
.2
	cmpi.w	#$98,(a3)	;94 $88
	bgt.w	.3
	cmpi.w	#$FF68,(a3)	;94 $FF78
	bgt.w	.4
.3
	clr.w	d1	;end of code not in 92
.4
	sub.w	d7,temp1(a3)
	bpl.w	.ckcon
	bset	#5,pflags(a3)
	move.w	#$234C,d1	;95 SPA (94 $E8A)
	move.w	(shotplayer).w,d0
	cmp.w	SCnum(a3),d0
	bne.w	.nopump
	move.w	#2,d0	;95: the scorer's pump, one of two (94 $EFC)
	jsr	(randomd0).l
	add.w	d0,d0
	movem.l	a0,-(sp)
	movea.l	#.pumps,a0
	move.w	0(a0,d0.w),d1
	movem.l	(sp)+,a0
.nopump
	jsr	(SetSPA).l
.1
	moveq	#$78,d0
	jsr	(randomd0).l
	move.w	d0,temp1(a3)
	rts
.ckcon
	btst	#3,pflags(a3)
	beq.w	skateto
.x
	rts
.pumps	;95 SPAs
	dc.w	$29B0,$280C,$29B0,$280C

assgoaliebreakwait	;no IDA label (IDA dc.b), asstab entry $1D (94 $20). assign94 assgoaliebreakwait (moved in)
	btst	#5,$62(a3)	;check if animation locked
	bne.w	.exit	;exit if so
	btst	#2,(BA_PS_flags).w	;check if pen shot
	bne.w	.1	;branch if so
	btst	#0,(gmode2).w	;check for shootout
	bne.w	.1	;branch if so
	nop
	bra.w	assexit
.1
	clr.w	$28(a3)	;clear Xvel
	clr.w	$2A(a3)	;clear Yvel
	movem.l	d0/a0,-(sp)	;push d0 and a0 on stack
	movea.l	#SortCords,a0	;Home SC Sctruct start
	move.w	(BA_Goalie_SCnum).w,d0	;move Goalie SCNum into d0
	asl.w	#7,d0	;shift d0 7 bits left
	adda.w	d0,a0	;add d0 to address a0
	move.w	#$191,$14(a3)	;move 401 decimal into Ypos
	btst	#7,$62(a0)	;check if shooting up or down (a0 is goalie being shot on)
	bne.w	.popstack	;branch if shooting up
	move.w	#$FE6F,$14(a3)	;move -191 decimal into Ypos (goalie not being shot on)
.popstack
	movem.l	(sp)+,d0/a0
.exit
	rts
; players do nothing until faceoff is over

ChkGoalies	;IDA: sub_835C6. A computer team down with its goalie in: pull him on a delayed penalty, else CPgoalie. Called from DoGameFrame (hockey95)
	btst	#gmclock,(gmode).w	;check if clock running
	bne.w	rtsskate
	movea.w	#(HmShots-M68K_RAM),a2
	lea	tmsize(a2),a1
	moveq	#1,d0
	bsr.w	.chkgoalie
	moveq	#2,d0
	exg	a1,a2
.chkgoalie
	tst.w	tmgoalie(a2)	;check for goalie
	bmi.w	rtsskate	;no goalie, exit
	move.w	(puckc).w,d1	;move puck carrier SCnum into d1
	bmi.w	rtsskate
	subq.w	#6,d1
	cmpa.w	#(HmShots-M68K_RAM),a2
	beq.w	.chkpen
	not.w	d1	;makes d1 negative if away team
.chkpen
	tst.w	d1
	bpl.w	rtsskate
	btst	#gmpendel,(gmode).w	;#gmpendel - delayed penalty called
	beq.w	.nopen
	st	tmgoalie(a2)	;sets to FFFF (no goalie)
	bra.w	SetPersonel
.nopen
	cmp.w	(cont1team).w,d0
	beq.w	rtsskate	;exit if team is joy controlled
	cmp.w	(cont2team).w,d0
	beq.w	rtsskate	;exit if team is joy controlled
	move.w	(pucky).w,d1
	bra.w	CPgoalie

ReturnGoalies	;no IDA label (inside sub_835E2). If the computer pulled its goalie, see if it should return him (CPgoalie on foy)
	movea.w	#(HmShots-M68K_RAM),a2
	lea	tmsize(a2),a1
	moveq	#1,d0
	bsr.w	.r
	moveq	#2,d0
	exg	a1,a2
.r
	cmpi.w	#$FFFF,tmgoalie(a2)
	beq.w	rtsskate	;still no goalie
	clr.b	tmgoalie(a2)	;clear for goalie return
	cmp.w	(cont1team).w,d0
	beq.w	rtsskate	;exit if team is joy controlled
	cmp.w	(cont2team).w,d0
	beq.w	rtsskate	;exit if team is joy controlled
	move.w	(foy).w,d1

CPgoalie	;IDA: loc_83662. See if the computer should pull its goalie: third period, behind by 2, a minute left, the faceoff in the other
	;zone (d1 = faceoff y). IDA loc_8369E (.0) is the label collide95_02 was mapped to; the routine ends at $0836AB
	cmpi.w	#2,(gsp).w	;check if 3rd period
	bne.w	rtsskate	;exit if not
	move.w	tmscore(a1),d0	;tmscore
	sub.w	tmscore(a2),d0
	bmi.w	rtsskate	;exit if leading in the game
	cmp.w	#2,d0
	bne.w	rtsskate	;exit if behind by more than 2
	cmpi.w	#$3C,(gameclock).w	;'<' ; #60
	bgt.w	rtsskate	;exit if more than 1 min left
	move.l	a0,-(sp)
	movea.w	tmsort(a2),a0	;moves a player struct address into a0
	btst	#pfgoal,pflags(a0)	;#pfgoal
	movea.l	(sp)+,a0
	bne.w	.0
	neg.w	d1	;if shooting on bottom goal, make d1 negative
.0
	tst.w	d1
	bmi.w	rtsskate	;exit if d1 negative (faceoff in own zone)
	st	tmgoalie(a2)	;set to FFFF (no goalie)
	bra.w	SetPersonel
