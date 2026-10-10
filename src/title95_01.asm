;	NHL 95 title95_01. Retail $09DA50-$09DD3D (750 bytes).
;	Mapped to title94 (77%): ShootoutInit (94 ClearShootout, shootout94) and InitShooters (shootout94), then the title94 shootout
;	routines PSandSOpassdir, passdirlist, StartShootoutPath, ShootoutPaths, NextPathPoint, SkatePath and ShootoutShootCheck.
;	The segment map started this file at $09D9C0 (data of awards95); the confirmed start is $09DA50.
;	IDA left passdirlist ... ShootoutShootCheck ($09DAF8-$09DD3D) as dc.b; it is transcribed from the retail bytes.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches
;	the cmp encoding after assembly.

ShootoutInit	;IDA: sub_9DA50. shootout94 ClearShootout. Clear the player structs (SortCords) and the shootout state, then the shooter
	;lists of both teams (InitShooters)
	movea.l	#SortCords,a0
	move.w	#$3FF,d0
.loop
	clr.w	(a0)+
	dbf	d0,.loop
	clr.w	(shootoutdelay).w
	move.w	#1,(playoffround).w
	bclr	#3,(gmode2).w
	clr.w	(sohomegoals).w
	clr.w	(soawaygoals).w
	clr.w	(homeshootnum).w
	clr.w	(shootoutteam).w
	bsr.w	InitShooters
	move.w	#1,(shootoutteam).w
	bsr.w	InitShooters
	clr.w	(shootoutteam).w
	rts
InitShooters	;IDA: sub_9DA94. shootout94 InitShooters. The 6 starters of the home (shootoutteam 0) or away team (save RAM roster
	;$207C28, $82 bytes a team) as the shooter list below homeshootnum / shootoutteam
	movea.l	#homeshootnum,a0
	move.w	(HomeTeam).w,d0
	tst.w	(shootoutteam).w
	beq.w	.0
	move.w	(VisTeam).w,d0
	movea.l	#shootoutteam,a0
.0
	movea.l	#$207C28,a1
	mulu.w	#$82,d0
	adda.l	d0,a1
	move.w	#5,d0
.loop
	move.w	(a1)+,d1
	andi.w	#$FF,d1
	subq.w	#1,d1
	move.w	d1,-(a0)
	dbf	d0,.loop
	rts
PSandSOpassdir	;IDA: sub_9DAD0. title94 PSandSOpassdir. Penalty shot / shootout: passdir = sopathdir (the end of the skate path,
	;NextPathPoint), turned by passdirlist for the bottom net
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(sopathdir).w,d0
	btst	#7,$62(a3)	;check what net shooting at
	bne.w	.0	;branch if top net
	movea.l	#passdirlist,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
.0
	move.w	d0,(passdir).w	;move d0 into passdir
	movem.l	(sp)+,d0-d7/a0-a6
	rts
passdirlist	;IDA: unk_9DAF8. title94 passdirlist. PSandSOpassdir: passdir for the other net
	dc.w	0,7,6,5,4,3,2,1,8
StartShootoutPath	;no IDA label. title94 StartShootoutPath. Shootout: pick one of the 7 skate paths (ShootoutPaths) at random (sopath) and start
	;it (NextPathPoint)
	movem.l	d0-d7/a0-a6,-(sp)
.loop
	move.w	#7,d0
	jsr	(randomd0).l
	cmp.w	#6,d0
	bgt.s	.loop
	move.w	d0,(sopath).w
	bclr	#3,(sflags7).w
	move.w	#$FFFF,(sopathpoint).w
	clr.w	(sopathx).w
	bsr.w	NextPathPoint
	movem.l	(sp)+,d0-d7/a0-a6
	rts
ShootoutPaths	;no IDA label. title94 ShootoutPaths. The 7 shootout skate paths (NextPathPoint)
	dc.l	ShootoutPath1
	dc.l	ShootoutPath2
	dc.l	ShootoutPath3
	dc.l	ShootoutPath4
	dc.l	ShootoutPath5
	dc.l	ShootoutPath6
	dc.l	ShootoutPath7
ShootoutPath1	;no IDA label. ShootoutPaths path: x, y points; $80 in the high byte ends it (low byte: sopathend, then sopathdir)
	dc.w	$10,$E2,$10,$D0,$8020,5
ShootoutPath2	;no IDA label. ShootoutPaths path
	dc.w	$FFC9,$A0,$FFFF,$C8,$FFE0,$D0,$8020,5
ShootoutPath3	;no IDA label. ShootoutPaths path
	dc.w	$FFB0,$40,$1A,$BC,$8020,5
ShootoutPath4	;no IDA label. ShootoutPaths path
	dc.w	$FFCE,$58,$14,$D0,$802C,5
ShootoutPath5	;no IDA label. ShootoutPaths path
	dc.w	$FFCE,8,$20,$D0,$8028,6
ShootoutPath6	;no IDA label. ShootoutPaths path
	dc.w	$1C,$F4,8,$E0,$8020,6
ShootoutPath7	;no IDA label. ShootoutPaths path
	dc.w	$FFE6,$F8,0,$E0,$8020,2
NextPathPoint	;no IDA label. title94 NextPathPoint. Next point of shootout path sopath (sopathpoint): sopathx / sopathy = x (turned by bit 0
	;of $76(a3)) / y; at the end ($80) sflags7 bit 3, sopathend and sopathdir (passdir)
	movem.l	d0-d7/a0-a6,-(sp)
	cmpi.b	#$80,(sopathx).w
	beq.w	.x
	addq.w	#1,(sopathpoint).w
	move.w	(sopathpoint).w,d0
	asl.w	#2,d0
	movea.l	#ShootoutPaths,a0
	move.w	(sopath).w,d1
	asl.w	#2,d1
	movea.l	(a0,d1.w),a0
	move.w	(a0,d0.w),(sopathx).w
	btst	#0,$76(a3)
	beq.w	.0
	neg.w	(sopathx).w
.0
	move.w	2(a0,d0.w),(sopathy).w
	cmpi.b	#$80,4(a0,d0.w)
	bne.w	.x
	bset	#3,(sflags7).w
	clr.w	(sopathend).w
	move.b	5(a0,d0.w),(sopathend+1).w
	move.w	6(a0,d0.w),(sopathdir).w
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts
SkatePath	;no IDA label. title94 SkatePath. Shootout skate path: d0 / d1 = the point (mirrored for the bottom net); within $A of it ($12
	;while $28 / $2A(a3) are 0) take the next one (NextPathPoint)
	movem.l	d2-d7/a0-a6,-(sp)
	cmpi.b	#$80,(sopathx).w
	beq.w	.x
	move.w	(sopathx).w,d0
	move.w	(sopathy).w,d1
	btst	#7,$62(a3)
	bne.w	.0
	neg.w	d0
	neg.w	d1
.0
	sub.w	(a3),d0
	bpl.w	.1
	neg.w	d0
.1
	tst.w	$28(a3)
	bne.w	.2
	tst.w	$2A(a3)
	bne.w	.2
	cmp.w	#$12,d0
	ble.w	.3
.2
	cmp.w	#$A,d0
	bgt.w	.7
.3
	sub.w	$14(a3),d1
	bpl.w	.4
	neg.w	d1
.4
	tst.w	$28(a3)
	bne.w	.5
	tst.w	$2A(a3)
	bne.w	.5
	cmp.w	#$12,d1
	ble.w	.6
.5
	cmp.w	#$A,d1
	bgt.w	.7
.6
	bsr.w	NextPathPoint
.7
	move.w	(sopathx).w,d0
	move.w	(sopathy).w,d1
.x
	movem.l	(sp)+,d2-d7/a0-a6
	rts
ShootoutShootCheck	;no IDA label. title94 ShootoutShootCheck. Shootout, skater a3 has the puck (gmode2 bit 1): Z set (d0 is restored) = shoot now:
	;after 3 (shootoutclock) at the path end, within sopathend of its last point, or with the puck stopped before $F
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#1,(gmode2).w
	beq.w	.5
	move.w	$52(a3),d0
	cmp.w	(puckc).w,d0
	bne.w	.5
	cmpi.w	#3,(shootoutclock).w
	ble.w	.4
	cmpi.b	#$80,(sopathx).w
	beq.w	.4
	btst	#3,(sflags7).w
	bne.w	.0
	tst.w	(puckvx).w
	bne.w	.5
	tst.w	(puckvy).w
	bne.w	.5
	cmpi.w	#$F,(shootoutclock).w
	blt.w	.4
	bra.w	.5
.0
	move.w	(sopathx).w,d0
	move.w	(sopathy).w,d1
	btst	#7,$62(a3)
	bne.w	.1
	neg.w	d0
	neg.w	d1
.1
	sub.w	(a3),d0
	bpl.w	.2
	neg.w	d0
.2
	sub.w	$14(a3),d1
	bpl.w	.3
	neg.w	d1
.3
	cmp.w	(sopathend).w,d0
	bgt.w	.5
	cmp.w	(sopathend).w,d1
	bgt.w	.5
.4
	clr.w	d0
	bra.w	.x
.5
	move.w	#1,d0
.x
	movem.l	(sp)+,d0-d7/a0-a6
	rts
