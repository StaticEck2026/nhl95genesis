;	NHL 95 replay95. Retail $08D39A-$08DF59 (3008 bytes).
;	Mapped to replay94 (80%): updatereplay, ReplayMode, ShowReplayIcon / EraseReplayIcon / ShowReplayBanner / EraseReplayBanner,
;	suba4, adda4, UpdateCameraPos, RevReplayAdj, RestoreReplayFrame and ClampReplayView. 95 adds chkcheckstart and CanCheckStart
;	(the 95 check start tests) ahead of updatereplay, and a sound driver restart at the top of ReplayMode. replay94 checkwindow is in
;	checks95_06. Each routine comment names its 94 routine or says 95 only. season95 follows at $08DF5A.
;	95 packs a replay frame object as 9-bit x and 11-bit frame (94: 10-bit x, 12-bit frame) and saves both PadControlBits words.
;	Local labels follow replay94 where the code is 94 code and are numbered in the 95 only routines; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
chkcheckstart	;IDA: sub_8D39A. 95 only. Called with d1 = SPAhook for a player a3 about to check: d1 becomes
	;SPAcheckstart ($1E6C) when the puck carrier (shot dir mode set) or the last shooter (ShotTimer running)
	;is on the other team
	btst	#sfssdir,(sflags).w
	bne.w	.carrier
	tst.w	(ShotTimer).w
	bmi.w	.rts
	movem.l	d0/d2/a0,-(sp)
	move.b	pflags(a3),d0
	move.b	(shotpflags).w,d1
	eor.b	d1,d0
	btst	#pfteam,d0
	beq.w	.done
	bra.w	.start
	btst	#sfssdir,(sflags).w	;not reached
	beq.w	.rts
	tst.w	(puckc).w
	bmi.w	.rts
.carrier
	movem.l	d0/d2/a0,-(sp)
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	asl.w	#7,d0
	adda.w	d0,a0
	move.b	pflags(a0),d0
	move.b	pflags(a3),d2
	eor.b	d2,d0
	btst	#pfteam,d0
	beq.w	.done
.start
	move.w	#$1E6C,d1	;SPAcheckstart
	bra.w	.done
	movem.w	d1,-(sp)	;not reached: the same facing test as CanCheckStart
	move.w	(puckx).w,d0
	sub.w	Xpos(a3),d0
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	jsr	(vtoa).l
	move.w	d0,-(sp)
	move.w	(puckx).w,d0
	move.w	#$10B,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.p
	neg.w	d1
.p
	sub.w	(pucky).w,d1
	neg.w	d1
	jsr	(vtoa).l
	cmp.w	(sp)+,d0
	movem.w	(sp)+,d1
	bne.w	.done
	move.w	#$1E6C,d1
.done
	movem.l	(sp)+,d0/d2/a0
.rts
	rts

CanCheckStart	;IDA: sub_8D452. 95 only. ne when joystick player a3 may start a check: pfalock clear, sflags sfssdir
	;set and GameFlags bit 2 clear (cleared while sfssdir is clear), a3 at y $56 or more toward the goal it shoots
	;at, the puck carrier on the other team, the direction (vtoa) from a3 to the puck the same as from the goal at
	;y $10B to the puck, a3 on the puck's side of x 0 and within y $B2 of it, and a3 facing that direction or one
	;next to it. d0 is restored
	movem.l	d0-d3/a0-a2,-(sp)
	btst	#pfalock,pflags(a3)
	bne.w	.no
	btst	#sfssdir,(sflags).w
	bne.w	.0
	bclr	#2,(GameFlags).w
.0
	btst	#2,(GameFlags).w
	bne.w	.no
	move.w	Ypos(a3),d0
	btst	#pfgoal,pflags(a3)
	beq.w	.1
	neg.w	d0
.1
	cmp.w	#$56,d0
	blt.w	.no
	tst.w	(puckc).w
	bmi.w	.no
	movea.l	#SortCords,a0
	move.w	(puckc).w,d0
	asl.w	#7,d0
	adda.w	d0,a0
	move.b	pflags(a0),d0
	move.b	pflags(a3),d1
	eor.b	d1,d0
	btst	#pfteam,d0
	beq.w	.no
	btst	#sfssdir,(sflags).w
	beq.w	.no
	move.w	(puckx).w,d0	;d0 = direction from a3 to the puck
	sub.w	Xpos(a3),d0
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	jsr	(vtoa).l
	move.w	d0,-(sp)
	move.w	(puckx).w,d0	;direction from the goal at y $10B to the puck
	move.w	#$10B,d1
	btst	#pfgoal,pflags(a3)
	beq.w	.2
	neg.w	d1
.2
	sub.w	(pucky).w,d1
	neg.w	d1
	jsr	(vtoa).l
	cmp.w	(sp)+,d0
	bne.w	.no
	movem.w	d0,-(sp)
	move.w	Xpos(a3),d1
	move.w	(puckx).w,d0
	eor.w	d0,d1
	movem.w	(sp)+,d0
	bmi.w	.no
	move.w	(pucky).w,d1
	sub.w	Ypos(a3),d1
	bpl.w	.3
	neg.w	d1
.3
	cmp.w	#$B2,d1
	bgt.w	.no
	cmp.w	facedir(a3),d0
	beq.w	.yes
	addq.w	#1,d0
	andi.w	#3,d0
	cmp.w	facedir(a3),d0
	beq.w	.yes
	subq.w	#2,d0
	andi.w	#3,d0
	cmp.w	facedir(a3),d0
	bne.w	.no
.yes
	move.w	#1,d0
	bra.w	.out
.no
	clr.w	d0
.out
	movem.l	(sp)+,d0-d3/a0-a2
	rts

updatereplay	;IDA: sub_8D55E. Called every frame to save replay events, d7 = elapsed frames. 95 packs x in 9 bits
	;and frame in 11 bits, and saves both pad words
	btst	#gmhl,(gmode).w	;check if highlight
	bne.w	rtss8	;exit if so
	btst	#sf2drec,(sflags2).w	;check if replay record disabled
	beq.w	.0	;branch if not
	tst.w	(replaydelay).w
	beq.w	.rec
	subq.w	#1,(replaydelay).w
	bpl.w	.0
	clr.w	(replaydelay).w
	bra.w	.rec
.0
	addi.l	#$62,(recbpr).w
	cmpi.l	#replayend,(recbpr).w
	bne.w	.rec
	bset	#sfwrap,(sflags).w
	move.l	#M68K_RAM,(recbpr).w
.rec
	movea.l	(recbpr).w,a0
	moveq	#$F,d2
	movea.w	#(SortCords-M68K_RAM),a3
.top
	clr.l	(a0)
	move.w	Xpos(a3),d1
	andi.w	#$1FF,d1
	move.w	d1,2(a0)
	clr.l	d1
	move.w	Ypos(a3),d1
	asl.w	#6,d1
	asl.l	#3,d1
	or.l	d1,(a0)
	move.w	frame(a3),d1
	asl.w	#3,d1
	or.w	d1,(a0)
	move.w	attribute(a3),d1
	andi.w	#$1800,d1
	asl.w	#3,d1
	or.w	d1,(a0)
	addq.w	#4,a0
	adda.w	#SCstruct,a3
	dbf	d2,.top
	moveq	#5,d2
	movea.w	#(SortCords-M68K_RAM),a3
.loop
	move.b	rostnum(a3),(a0)+
	move.w	position(a3),d0
	bpl.w	.n0
	moveq	#$F,d0
.n0
	andi.w	#$F,d0
	move.b	d0,(a0)
	adda.w	#SCstruct,a3
	move.b	rostnum(a3),d0
	asl.w	#4,d0
	or.b	d0,(a0)+
	move.b	rostnum(a3),d0
	lsr.b	#4,d0
	move.b	d0,(a0)
	move.w	position(a3),d0
	bpl.w	.n1
	moveq	#$F,d0
.n1
	asl.w	#4,d0
	or.b	d0,(a0)+
	adda.w	#SCstruct,a3
	dbf	d2,.loop
	move.b	(puckz+1).w,(a0)+
	move.b	(SortCords+((puckscnum+1)*SCstruct)+Zpos+1).w,(a0)+
	move.b	(lastsfx+1).w,(a0)+
	bset	#7,(lastsfx+1).w
	move.b	d7,(a0)+
	move.w	(PadControlBits+2).w,(a0)+
	move.w	(crowdframe).w,(a0)+
	move.w	(glovecords).w,(a0)+
	move.b	(PBnum).w,(a0)+
	move.w	d0,-(sp)
	move.w	(PadControlBits).w,d0
	move.b	d0,(a0)+
	move.w	(sp)+,d0
	move.w	(Hpos).w,(a0)+
	move.w	(Vpos).w,(a0)+
rtss8	;IDA: locret_8D666
	rts

ReplayMode	;Instant replay play-back control and display code (94 ReplayMode). Called from the pause menu.
	;95 first restarts the sound driver: load the Z80 program and the sound banks
	jsr	(SoundOff).l
	move.w	#$FFFF,(PlayingSong).w
	move.w	#0,d0
	move.w	#$1B63,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#9,d0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#1,d1
	jsr	(SoundCmd).l
	;94 ReplayMode starts here. As 93: a d-pad press picks the nearest object in that direction
	;and the camera follows it
	bclr	#0,(sflags5).w
	jsr	(forceblack).l
	move.w	(disflags).w,-(sp)
	bset	#sf2replay,(sflags2).w
	bclr	#4,(sflags4).w
	jsr	(RestoreGameScreen).l
	movea.l	#VDP_DATA,a0
	move.w	#$9100,4(a0)
	move.w	#$921C,4(a0)
	move.w	#$400,d0
	move.w	(VmMap3).w,d1
	move.w	#$7FF,d2
	jsr	(DoFill).l
	move.w	(ExtraChars).w,d4
	movea.l	#ReplayMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(ReplayIconChars).w
	movea.l	#ReplayIconMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(ShowReplayIcon).l
	bclr	#sfscrl,(sflags).w
	bclr	#5,(sflags3).w
	st	(replayactive).w
	movea.l	(recbpr).w,a4
.rwd
	bsr.w	suba4
	tst.w	d7
	bne.s	.rwd
	jsr	(SprSort).l
	jsr	(setvideo).l
	bclr	#1,(sflags3).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	move.w	#$18,(palcount).w
	moveq	#1,d7
.top
	move.w	(vcount).w,d0
	sub.w	(oldvcount).w,d0
	cmp.w	d0,d7
	bhi.s	.top
	move.w	(vcount).w,(oldvcount).w
	tst.w	(replayicontimer).w
	bmi.w	.0
	sub.w	d7,(replayicontimer).w
	bpl.w	.0
	clr.w	(replayicontimer).w
	jsr	(EraseReplayIcon).l
.0
	movem.l	d0/a3,-(sp)
	movea.l	#SortCords+(12*SCstruct),a3
	move.w	#1,8(a3)
	movea.l	#SortCords+(13*SCstruct),a3
	move.w	#1,8(a3)
	movem.l	(sp)+,d0/a3
	moveq	#1,d7
	jsr	(ReadMenuJoy).l
	btst	#0,(sflags5).w
	beq.w	.2
	andi.w	#$FFF0,d0
	ori.w	#8,d0
	andi.w	#$FFF0,d1
	andi.w	#$FFF0,d3
.2
	movea.w	#(ReplayStarStruct-M68K_RAM),a5
	btst	#5,(sflags3).w
	beq.w	.dir
	move.w	d1,d5
	andi.w	#$F,d5
	beq.w	.nomans
.dir
	btst	#3,d0
	bne.w	.nomans
	cmpi.w	#$FF60,(a5)
	bgt.w	.3
	move.w	#0,(a5)
	bra.w	*+4
.3
	cmpi.w	#$FED0,$14(a5)
	bgt.w	.4
	move.w	#0,$14(a5)
.4
	bset	#sfscrl,(sflags).w
	bne.w	.man
	move.w	(Hpos).w,(a5)
	move.w	(Vpos).w,$14(a5)
.man
	move.w	d0,d5
	andi.w	#7,d5
	eori.w	#4,d5
	movea.w	#(SortCords-M68K_RAM),a1
	st	d3
	bclr	#5,(sflags3).w
	beq.w	.find
	move.w	$16(a5),d3
.find
	move.w	(a5),d0
	move.w	$14(a5),d1
	moveq	#$B,d2
	move.l	#$100,d4
	movem.w	d0-d1,-(sp)
.loop
	cmp.w	SCnum(a1),d3
	beq.w	.skip
	movem.w	(sp),d0-d1
	sub.w	(a1),d0
	sub.w	Ypos(a1),d1
	jsr	(vtoa).l
	btst	#3,d0
	bne.w	.skip
	sub.w	d5,d0
	addq.w	#1,d0
	andi.w	#7,d0
	cmp.w	#2,d0
	bhi.w	.skip
	movem.w	(sp),d0-d1
	sub.w	(a1),d0
	sub.w	Ypos(a1),d1
	muls.w	d0,d0
	muls.w	d1,d1
	add.l	d1,d0
	cmp.l	#4,d0
	bls.w	.skip
	cmp.l	d4,d0
	bhi.w	.skip
	move.l	d0,d4
	move.w	SCnum(a1),$16(a5)
	bset	#5,(sflags3).w
.skip
	adda.w	#SCstruct,a1
	dbf	d2,.loop
	addq.w	#4,sp
	btst	#5,(sflags3).w
	beq.w	.scrl
	move.w	$16(a5),d0
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
	moveq	#8,d4
	jsr	(setpads).l
	bsr.w	UpdateCameraPos
	jsr	(setvideo).l
	bra.w	.top
.scrl
	bset	#5,(sflags).w
	eori.w	#4,d5
	asl.w	#2,d5
	lea	.dirtab(pc),a0
	move.w	0(a0,d5.w),d0
	add.w	(a5),d0
	cmp.w	#$98,d0
	bgt.w	.nox
	cmp.w	#$FF68,d0
	blt.w	.nox
	move.w	d0,(a5)
.nox
	move.w	2(a0,d5.w),d1
	add.w	$14(a5),d1
	cmp.w	#$129,d1
	bgt.w	.noy
	cmp.w	#$FED7,d1
	blt.w	.noy
	move.w	d1,$14(a5)
.noy
	movea.w	a5,a3
	clr.w	$18(a5)
	andi.l	#$FFFFF,(PadControlBits).w
	ori.l	#$E00000,(PadControlBits).w
	jsr	(UpdateCameraPos).l
	jsr	(setvideo).l
	bra.w	.top
.dirtab;scroll step per d-pad direction 0-7: x, y
	dc.w	0,2, 2,2
	dc.w	2,0, 2,-2
	dc.w	0,-2, -2,-2
	dc.w	-2,0, -2,2
.nomans
	st	$18(a5)
	btst	#5,d1
	beq.w	.00
	btst	#0,(sflags5).w
	bne.w	.00
	bchg	#sf3rmplay,(sflags3).w
.00
	btst	#6,d3
	beq.w	.5
	btst	#0,(sflags5).w
	bne.w	.5
	bsr.w	suba4
	bsr.w	suba4
	bsr.w	suba4
	bsr.w	suba4
	jsr	(SprSort).l
	jsr	(setvideo).l
	moveq	#1,d7
	bclr	#1,(sflags3).w
.5
	btst	#0,(sflags5).w
	bne.w	.1
	btst	#4,d3
	beq.w	.1
	btst	#6,d3
	beq.w	.f1
	bclr	#5,(sflags3).w
	bclr	#5,(sflags).w
	move.w	d0,-(sp)
	move.l	(PadControlBits).w,d0
	andi.l	#$FFFFF,d0
	ori.l	#$E00000,d0
	move.l	d0,(PadControlBits).w
	move.w	(sp)+,d0
	bra.w	.top
.f1
	bsr.w	adda4
	jsr	(SprSort).l
	jsr	(setvideo).l
	asl.w	#1,d7
	bclr	#1,(sflags3).w
.1
	btst	#sf3rmplay,(sflags3).w
	beq.w	.noplay
	st	(lastsfx).w
	bsr.w	adda4
	move.w	(lastsfx).w,-(sp)
	jsr	(sfx).l
	jsr	(SprSort).l
.noplay
	jsr	(setvideo).l
	btst	#0,(sflags5).w
	bne.w	.6
	btst	#7,d1
	beq.w	.top
	jsr	(ShowReplayBanner).l
	bclr	#1,(sflags3).w
	bset	#0,(sflags5).w
	bne.w	.6
	bra.w	.top
.6
	btst	#7,d1
	bne.w	.8
	btst	#6,d1
	bne.w	.7
	btst	#4,d1
	bne.w	.9
	btst	#5,d1
	beq.w	.top
	bset	#6,(sflags4).w
	bclr	#0,(sflags5).w
	jsr	(EraseReplayBanner).l
	bsr.w	adda4
	jsr	(SprSort).l
	bra.w	.top
.7
	jmp	.top
.8
	clr.w	(menuitem).w
	bset	#3,(sflags9).w
.9
	jsr	(forceblack).l
	ori.l	#$F0000000,(PadControlBits).w
	bclr	#5,(sflags).w
	movea.l	(recbpr).w,a4
	bclr	#4,(sflags4).w
	jsr	(RestoreReplayFrame).l
	jsr	(SprSort).l
	bclr	#3,(sflags2).w
	move.w	(sp)+,(disflags).w
	movea.l	(menulist).w,a0
	movea.l	(menudraw).w,a1
	jsr	(InitMenuState).l
	move.w	#$18,(palcount).w
	rts

ShowReplayIcon
	move.w	#$F0,(replayicontimer).w
	jsr	(printz).l
	String	$BD,2,2,0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#$A,d2
	moveq	#5,d3
	move.w	(ReplayIconChars).w,d4
	move.w	#0,d5
	movea.l	#ReplayIconMap,a1
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	jmp	dobitmap

EraseReplayIcon
	jsr	(printz).l
	String	$BD,2,2,0
	move.w	#$A,d0
	move.w	#5,d1
	move.w	#$7FF,d2
	jmp	eraser

ShowReplayBanner
	st	(replayicontimer).w
	jsr	(printz).l
	String	$BD,2,2,0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#$A,d2
	moveq	#6,d3
	move.w	(ExtraChars).w,d4
	move.w	#0,d5
	movea.l	#ReplayMap,a1
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	jmp	dobitmap

EraseReplayBanner
	jsr	(printz).l
	String	$BD,2,2,0
	move.w	#$A,d0
	move.w	#6,d1
	move.w	#$7FF,d2
	jmp	eraser

suba4	;a4 = current replay frame. Back up 1 frame and set video parameters for display.
	;d7 = delay between frames, or zero at the end of the replay
	cmpa.l	#M68K_RAM,a4
	bne.w	.1
	btst	#sfwrap,(sflags).w
	beq.w	.end
	movea.l	#replayend,a4
.1
	suba.w	#$62,a4
	cmpa.l	(recbpr).w,a4
	bne.w	RestoreReplayFrame
	adda.w	#$62,a4
.end
	bsr.w	RestoreReplayFrame
	clr.w	d7
	rts

adda4	;Step forward 1 frame (93 adda4). 94 first handles a reverse angle switch (sflags4 bit 6)
	bclr	#6,(sflags4).w
	beq.w	.1
	movem.l	d0-d7/a0-a6,-(sp)
	bchg	#4,(sflags4).w
	move.w	(Hpos).w,-(sp)
	move.w	(Vpos).w,-(sp)
	jsr	(forceblack2).l
	jsr	(vcountwait).l
	jsr	(vcountwait).l
	clr.w	(Hpos).w
	clr.w	(Vpos).w
	move.w	#$7D0,(Oldrow).w
	move.w	#1,d0
.loop
	jsr	(setvideo).l
	jsr	(vcountwait).l
	dbf	d0,.loop
	move.w	(sp)+,(Vpos).w
	move.w	(sp)+,(Hpos).w
	move.w	#1,d0
	jsr	(setvideo).l
.loop2
	jsr	(vcountwait).l
	dbf	d0,.loop2
	movem.l	a0,-(sp)
	movea.l	#SortCords+(12*SCstruct),a0
	move.w	#1,8(a0)
	adda.w	#$80,a0
	move.w	#1,8(a0)
	movem.l	(sp)+,a0
	bsr.w	RevReplayAdj
	btst	#5,(sflags).w
	beq.w	*+4
.0
	jsr	(ShowReplayIcon).l
	move.w	#$64,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
.1
	clr.w	d7
	btst	#sf2drec,(sflags2).w
	beq.w	adda42
	movem.l	a4,-(sp)
	bsr.w	adda43
	cmpa.l	(recbpr).w,a4
	movem.l	(sp)+,a4
	beq.w	rtsAdda4

adda42	;adda4 without the sf2drec look-ahead: stop at the record point, else show the frame and
	;fall into adda43
	cmpa.l	(recbpr).w,a4
	beq.w	rtsAdda4
	bsr.w	RestoreReplayFrame

adda43	;a4 += replay frame size ($62), wrapping from replayend to M68K_RAM (92 replaystart)
	adda.w	#$62,a4
	cmpa.l	#replayend,a4
	bne.w	rtsAdda4
	movea.l	#M68K_RAM,a4

rtsAdda4	rts

UpdateCameraPos	;Camera struct a5 = object a3 x/y (negated for the reverse angle), Hpos/Vpos clamped
	movem.l	d0-d2,-(sp)
	move.w	(a3),d0
	btst	#7,(sflags4).w
	beq.w	.0
	neg.w	d0
.0
	move.w	d0,(a5)
	move.w	$14(a3),d1
	btst	#7,(sflags4).w
	beq.w	.2
	neg.w	d1
.2
	move.w	d1,$14(a5)
	cmp.w	#$3C,d0
	blt.w	.4
	move.w	#$3C,d0
.4
	cmp.w	#$FFC4,d0
	bgt.w	.1
	move.w	#$FFC4,d0
.1
	move.w	d0,(Hpos).w
	cmp.w	#$F0,d1
	blt.w	.5
	move.w	#$F0,d1
.5
	cmp.w	#$FF38,d1
	bgt.w	.3
	move.w	#$FF38,d1
.3
	move.w	d1,(Vpos).w
	movem.l	(sp)+,d0-d2
	rts
	; set flag for reverse replay setup if needed

RevReplayAdj	;94 only. Set sflags4 bit 7 for a reverse angle replay, then fall into RestoreReplayFrame
	btst	#4,(sflags4).w;check if reverse angle replay
	beq.w	RestoreReplayFrame;branch if not
	bset	#7,(sflags4).w;set bit 7
	; a4 = current replay frame address to convert into normal coordinates

RestoreReplayFrame	;IDA: SetRCords (92 name). a4 = current replay frame address to convert into normal cordinates (92
	;SetRCords), then the other replay variables (92 nonshift). 94 flips x/y and frames for the reverse angle
	movem.l	d0-d2/a0/a6,-(sp)
	movea.l	#revframetbl,a6
	movea.l	a4,a0
	moveq	#$F,d1;16 objects to convert (12 players/2 nets/puck/puck shadow)
	movea.w	#(SortCords-M68K_RAM),a3
.top
	move.w	2(a0),d2
	andi.w	#$1FF,d2
	btst	#8,d2
	beq.w	.chkrevx
	ori.w	#$FE00,d2
.chkrevx
	btst	#4,(sflags4).w
	beq.w	.p
	neg.w	d2
.p
	move.w	d2,(a3)
	move.l	(a0),d2
	asr.l	#3,d2
	asr.w	#6,d2
	btst	#9,d2
	beq.w	.chkrevy
	ori.w	#$FC00,d2
.chkrevy
	btst	#4,(sflags4).w
	beq.w	.p1
	neg.w	d2
	cmp.w	#0,d1
	bne.w	.p1
	addq.w	#2,d2
.p1
	move.w	d2,Ypos(a3)
	move.w	(a0),d2
	asr.w	#3,d2
	andi.w	#$7FF,d2
	btst	#4,(sflags4).w
	beq.w	.2
	asl.w	#1,d2
	move.w	(a6,d2.w),d2
	cmpi.w	#$F,SCnum(a3)
	bne.w	.0
	cmp.w	#$1B3,d2
	beq.w	.0
	move.w	#$FC00,Ypos(a3)
.0
	cmp.w	#1,d2
	blt.w	.1
	cmp.w	#$420,d2
	bge.w	.1
	bra.w	.2
.1
	move.w	(a0),d2
	asr.w	#3,d2
	andi.w	#$7FF,d2
.2
	move.w	d2,frame(a3)
	cmp.w	#$3E8,d2
	blt.w	.3
	cmp.w	#$3ED,d2
	bge.w	.3
	btst	#4,(sflags4).w
	beq.w	.3
	move.w	#$190,Ypos(a3)
.3
	move.w	(a0),d2
	asr.w	#3,d2
	andi.w	#$1800,d2
	andi.w	#$E7FF,attribute(a3)
	or.w	d2,attribute(a3)
	btst	#4,(sflags4).w
	beq.w	.4
.4
	addq.w	#4,a0
	adda.w	#SCstruct,a3
	dbf	d1,.top
	moveq	#5,d2
	movea.w	#(SortCords-M68K_RAM),a3
.loop
	move.b	(a0)+,rostnum(a3)
	move.b	(a0),d0
	andi.w	#$F,d0
	cmp.w	#$F,d0
	bne.w	.5
	moveq	#-1,d0
.5
	move.w	d0,position(a3)
	adda.w	#SCstruct,a3
	move.b	(a0)+,d0
	lsr.b	#4,d0
	move.b	d0,rostnum(a3)
	move.b	(a0),d0
	asl.b	#4,d0
	or.b	d0,rostnum(a3)
	move.b	(a0)+,d0
	lsr.b	#4,d0
	andi.w	#$F,d0
	cmp.w	#$F,d0
	bne.w	.6
	moveq	#-1,d0
.6
	move.w	d0,position(a3)
	adda.w	#SCstruct,a3
	dbf	d2,.loop
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,(puckz).w
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,(SortCords+((puckscnum+1)*SCstruct)+Zpos).w
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,(lastsfx).w
	clr.w	d7
	move.b	(a0)+,d7
	move.w	(a0)+,d0
	move.w	d0,(PadControlBits+2).w
	move.w	(a0)+,(crowdframe).w
	move.w	(a0)+,(glovecords).w
	move.b	(a0)+,(PBnum).w
	clr.w	d0
	move.b	(a0)+,d0
	ori.w	#$FF00,d0
	move.w	d0,(PadControlBits).w
	btst	#sfscrl,(sflags).w
	beq.w	.pos
	movea.w	a5,a3
	btst	#5,(sflags3).w
	beq.w	.cam
	clr.w	$18(a5)
	move.w	$16(a5),d0
	asl.w	#7,d0
	movea.w	#(SortCords-M68K_RAM),a3
	adda.w	d0,a3
.cam
	bsr.w	UpdateCameraPos
	bra.w	.7
.pos
	move.w	(a0)+,(Hpos).w
	move.w	(a0)+,(Vpos).w
	btst	#4,(sflags4).w
	beq.w	.7
	neg.w	(Hpos).w
	neg.w	(Vpos).w
	jsr	(ClampReplayView).l
.7
	bclr	#7,(sflags4).w
	movem.l	(sp)+,d0-d2/a0/a6
	rts

ClampReplayView	;94 only. Clamp Hpos to -$3C..$3C and Vpos to -$C8..$100
	move.w	d0,-(sp)
	move.w	#$3C,d0
	cmp.w	(Hpos).w,d0
	blt.w	.0
	move.w	#$FFC4,d0
	cmp.w	(Hpos).w,d0
	ble.w	.1
.0
	move.w	d0,(Hpos).w
.1
	move.w	#$100,d0
	cmp.w	(Vpos).w,d0
	blt.w	.2
	move.w	#$FF38,d0
	cmp.w	(Vpos).w,d0
	ble.w	.3
.2
	move.w	d0,(Vpos).w
.3
	move.w	(sp)+,d0
	rts
	; called every frame to save replay events
	; d7 = elapsed frames
