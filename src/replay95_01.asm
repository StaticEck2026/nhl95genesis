; $00A536  Adapted from replay94.asm: replay
;	NHL 95 segment $A536-$A655, from lst/nhl95.bin.lst. 94 updateanim (replay94), split from the display95_01 placeholder.
;	setup95_01 (94 defaultsprites) follows at $A656.

updateanim	;IDA: sub_A536. frame switch control on struct a3. Called from updateplayers (hockey95). 95: no horizontal rink case, and an
	;animation whose flag has bits 0 and 1 set loops back to the pair in the flag's high byte (frames95 SPAskate $1003)
	tst.w	SPA(a3)	;test SPA
	bne.w	.ia	;branch if not 0
	bclr	#pfalock,pflags(a3)	;clear anim lock
	bclr	#pf2aip,pflags2(a3)	;clear anim in progress
	rts
.ia
	movea.l	#SPAlist,a0	;animation data tables (frames95)
	adda.w	SPA(a3),a0	;add SPA to a0 address
	move.w	Ypos(a3),d0	;left over from the 94 horizontal rink check
	move.w	#0,d0
	move.w	$10(a0),d1	;16 dec - attributes for anim
	move.w	facedir(a3),d0	;facedir into d0
	btst	#3,attribute(a3)	;x flip flag
	beq.w	.nox	;branch if no flip
	neg.w	d0	;negate d0
	addq.w	#8,d0	;add 8 to d0 for flipping
	andi.w	#7,d0	;pass first 3 bits
.nox
	asl.w	#1,d0	;mult by 2
	adda.w	(a0,d0.w),a0	;add the direction offset: a0 = this direction's frame,time pairs
	move.w	SPAnum(a3),d0	;SPANum into d0 (index into animation)
	move.w	(a0,d0.w),d2	;the new SPF frame of this animation
	tst.w	SPAcnt(a3)	;check if SPAcnt is 0 (time for a new frame)
	bmi.w	.1	;branch if so (SPAcnt is negative)
	sub.w	d7,SPAcnt(a3)	;sub frames elasped from SPAcnt
	bpl.w	.cframe	;branch if SPAcnt is positive
	addq.w	#4,SPAnum(a3)	;add 4 to SPAnum (set for next index)
	addq.w	#4,d0	;add 4 to d0 (currently holds current index)
	tst.w	-2(a0,d0.w)	;the frame time for the previous frame
	bpl.w	.1	;branch if positive (not the end of the animation)
	btst	#0,d1	;check if anim attribute loops
	beq.w	.end
	btst	#1,d1	;95: loop to the pair in the flag's high byte
	bne.w	.again
	clr.w	d0	;loop from the start
	clr.w	SPAnum(a3)
	bclr	#pfalock,pflags(a3)	;clear animation lock
	bclr	#pf2aip,pflags2(a3)	;clear animation in progress
	bclr	#5,$64(a3)	;clear fall down flag
	bra.w	.1
.again
	lsr.w	#8,d1
	andi.w	#$FF,d1
	asl.w	#2,d1
	move.w	d1,SPAnum(a3)
	cmpi.w	#SPAinjuryfall,SPA(a3)	;the injured player stays locked
	beq.w	.1
	bclr	#pfalock,pflags(a3)
	bclr	#pf2aip,pflags2(a3)
	bclr	#5,$64(a3)
	bra.w	.1
.end	;the animation is over
	clr.w	d0
	clr.w	SPAnum(a3)
	bclr	#pfalock,pflags(a3)
	bclr	#pf2aip,pflags2(a3)
	bclr	#5,$64(a3)
	cmpi.w	#SPAfallback,SPA(a3)	;95: a fall back ends facing the other way
	bne.w	.clr
	eori.w	#4,facedir(a3)
.clr
	clr.w	SPA(a3)	;clear SPA
.1
	move.w	2(a0,d0.w),d0	;move frame time for animation frame into d0
	bpl.w	.0	;branch if positive
	neg.w	d0	;make d0 positive (this is the case if final frame)
.0
	move.w	d0,SPAcnt(a3)	;move d0 into SPAcnt
.cframe
	sub.b	d7,glitch(a3)	;sub frames elapsed from glitch - limit minimum time between frame switches
	bpl.w	.rtss	;branch if glitch is positive still
	clr.b	glitch(a3)	;clear glitch
	cmp.w	frame(a3),d2	;compare frame to d2
	beq.w	.rtss	;branch if equal
	move.w	d2,frame(a3)	;move d2 into frame
	move.b	#4,glitch(a3)	;move 4 into glitch - /60 sec min frame switch time
.rtss
	rts
