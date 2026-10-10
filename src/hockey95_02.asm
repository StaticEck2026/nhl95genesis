; $07E36C  Adapted from hockey94.asm: game flow
;	NHL 95 segment $7E36C-$7E4D5, from lst/nhl95.bin.lst. 94 Pausemode and SetupPauseScreen (hockey94), split from the sound95_02
;	placeholder (the 94 Z80 program ends at $7E36B). menu95 (94 seta2) follows at $7E4D6.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp; fixopcodes.js patches the
;	cmp encoding after assembly.

Pausemode	;IDA: sub_7E36C (hockey94 PauseMode). Game is in pause mode now: fade out, stop the sound (unless sflags9 bit 5), run the pause menu
	;(SetPauseMenuItems, InitMenuState, HandleMenuInput) until it ends or, with no pad on a team, $708 frames pass without a button; then reload
	;the sound driver (SoundCmd 9, 0 Z80Program, 6 SoundBanks, 7) and restore the screen (ClrHor, setvideo) and fade in. Called from DoGameFrame
	move.w	(smallfontchars).w,-(sp)
	clr.w	(menucursor).w
	clr.l	(menuitemoffset).w
	jsr	(forceblack).l	;fade screen to black
	move.w	d0,-(sp)
	move.w	(vcount).w,d0
.0
	cmp.w	(vcount).w,d0
	beq.s	.0	;wait for the next vblank
	move.w	(sp)+,d0
	btst	#sfpz,(sflags).w
	beq.w	.1
	btst	#5,(sflags9).w
	bne.w	.1
	jsr	(SoundOff).l
	bra.w	.1	;95: to the next instruction
.1
	move.w	(sflags).w,-(sp)
	jsr	(seta2).l	;a2 = team of pausing controller
	move.w	#$3C,(menutimer).w
	move.w	#2,(menucursor).w
	bsr.w	SetPauseMenuItems
	movea.l	(menulist).w,a0
	lea	SetupPauseScreen(pc),a1	;screen draw routine
	jsr	(InitMenuState).l
	move.l	#$708,(pausetimeout).w
.2
	jsr	(vcountwait).l
	jsr	(ReadMenuJoy).l
	tst.w	d1
	beq.w	.3
	move.l	#$708,(pausetimeout).w
.3
	jsr	(AnyPadAssigned).l
	bne.w	.4
	subq.l	#1,(pausetimeout).w
	bmi.w	.5
.4
	jsr	(ProcessInputWithRepeat).l
	jsr	(HandleMenuInput).l
	bne.s	.2	;eq = leave pause
.5
	jsr	(forceblack).l
	btst	#7,(sflags9).w
	beq.w	.6
	jsr	(PracticeGoalies).l
.6
	btst	#5,(sflags9).w
	bne.w	.7
	jsr	(play_new_song).l
	move.w	#9,d0
	jsr	(SoundCmd).l
	move.w	#0,d0
	move.w	#$1B63,d1
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#1,d1
	jsr	(SoundCmd).l
.7
	move.w	(sp)+,(sflags).w
	jsr	(ClrHor).l
	movea.l	#VDP_DATA,a0
	move.w	#$9100,4(a0)
	move.w	#$9200,4(a0)
	bclr	#sfpz,(sflags).w
	jsr	(setvideo).l
	move.w	#$18,(palcount).w
	btst	#5,(sflags11).w
	beq.w	.8
	move.w	#$FFFF,(palcount).w
.8
	tst.w	(palcount).w
	bpl.s	.8
	move.w	(vcount).w,(oldvcount).w
	move.w	(sp)+,(smallfontchars).w
	rts

SetupPauseScreen	;IDA: unk_7E4C8 (dc.b). Draw routine for the pause menu (92 Pausemode .pall / .top): PauseScreenDraw, then KillCrowd
	jsr	(PauseScreenDraw).l
	jsr	(KillCrowd).l
	rts
