; $079D80  Adapted from display94.asm: sprite frames, rink scroll
;	NHL 95 segment $79D80-$7A029, from lst/nhl95.bin.lst. 94 addframe, addframe2, then sizetab (94 kept it in data94), then
;	updatescroll. 95 reads a new 8 byte sprite record (Y, size / tile high bits, tile / flags, X) and has no horizontal rink case.
;	video95_02 (94 forceblack) follows at $7A02A.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp; fixopcodes.js patches the
;	cmp encoding after assembly.

addframe	;IDA: sub_79D80. a3 = sort cord object. Project it with find3d, then addframe2. a5 = dma trans, a6 = sprite attribute table.
	;Called from setsortcords (display95_01)
	movem.l	d0-d2,-(sp)
	move.w	(a3),d0	;Xpos into d0
	move.w	Ypos(a3),d1	;Ypos into d1
	move.w	Zpos(a3),d2	;Zpos into d2
	bmi.w	.exit	;exit if Zpos minus
	bsr.w	find3d	;get position on screen
	cmp.w	#$4E20,d1	;#osflag into d1
	beq.w	.exit	;exit if Sort Cord is off screen
	bsr.w	addframe2
.exit
	movem.l	(sp)+,d0-d2
	rts

addframe2	;d0/d1 = x/y coord on screen, a3 = object, a5 = dma trans, a6 = sprite attribute table, d6 = link counter. Queue the sprite tiles of
	;the frame (once per frame change, sharing tiles already sent) and write its sprites. Also jumped to from setffo (display95_01).
	;95 sprite record: 0 Y global, 2 size byte (low nibble) and tile bits 11-14 (high nibble), 4 tile (11 bits) and flags (top 5), 6 X global
	move.w	attribute(a3),-(sp)	;push attribute to stack
	movem.l	d0-d5/a0-a2,-(sp)	;push to stack
	move.w	frame(a3),d4	;move frame into d4
	bmi.w	.exit	;exit if minus
	beq.w	.exit	;exit if 0
	andi.w	#$F800,d4	;pass highest 5 bits
	eor.w	d4,attribute(a3)	;EOR d4 with attribute
	move.w	frame(a3),d4	;move frame back into d4
	andi.w	#$7FF,d4	;pass first 11 bits
	movea.l	#Sprites,a2	;sprite frame list
	adda.l	4(a2),a2	;add long word at offset 4 to a2 address
	asl.w	#1,d4	;frame * 2
	cmp.w	(a2),d4	;95: the offset count is at 0 (94: 2)
	bge.w	.exit	;branch if greater than or equal
	move.w	2(a2,d4.w),d5	;next frame's offset
	sub.w	(a2,d4.w),d5	;minus this frame's offset
	lsr.w	#3,d5	;divide d5 by 8
	subq.w	#1,d5	;d5 now total sprites in frame -1(SprStrnum)
	adda.w	(a2,d4.w),a2	;a2 now at SprStrdat - sprite data
	clr.w	d3	;clear d3
	clr.w	d4	;clear d4
.sloop
	move.w	d0,-(sp)	;push d0 on stack
	move.w	frame(a3),d0	;move frame into d0
	andi.w	#$7FF,d0	;pass first 11 bits
	cmp.w	oldframe(a3),d0	;compare old frame to d0 (current frame)
	beq.w	.noref	;branch if equal (no change)
	tst.w	d5	;check if d5 is 0
	bne.w	.nn	;branch if not
	move.w	d0,oldframe(a3)	;move frame into old frame
.nn
	movem.w	d0-d4,-(sp)	;push to stack
	move.w	2(a2),d2	;tile bits 11-14 from the high nibble of word 2
	andi.w	#$F000,d2
	lsr.w	#1,d2
	move.w	d2,-(sp)
	move.w	4(a2),d2	;tile bits 0-10
	andi.w	#$7FF,d2
	or.w	(sp)+,d2	;d2 = 15 bit pointer to sprite tiles
	clr.w	d4	;clear d4
	move.b	2(a2),d4	;size byte
	andi.w	#$F,d4
.chk
	cmp.w	#$F,d4	;never true after the andi
	bgt.s	.chk
	movea.l	#sizetab,a0	;move address into a0
	move.b	(a0,d4.w),d4	;tiles used in sprite
	cmp.w	8(sp),d4	;compare current d4 to previous d4
	bgt.w	.nodup	;branch if d4 greater - more data in prev sprite so no dup
	;d0 = frame
	;d2 = pointer to sprite tiles
	;d4 = # of tiles in sprite
	;d5 = # of sprites in frame-1
	cmp.w	4(sp),d2	;compare current d2 to previous d2
	blt.w	.nodup	;branch if less than
	move.w	4(sp),d0	;move previous d2 into d0
	add.w	8(sp),d0	;add previous d4 to d0 - end of last data
	sub.w	d2,d0	;sub d2 from d0
	sub.w	d4,d0	;sub d4 from d0
	bmi.w	.nodup	;branch if d0 negative
	movem.w	(sp)+,d0-d1	;pop d0 and d1 from stack
	addq.w	#6,sp	;add 6 to stack pointer
	bra.w	.dup	;branch
.nodup
	add.w	8(sp),d3	;add old d4 to d3 - both of these are 0 if first sprite in frame
	movem.w	(sp)+,d0-d1	;pop d0 and d1 from stack (d0=Xpos, d1=Ypos)
	addq.w	#6,sp	;add 6 to stack pointer (moves past old d4 spot on stack)
	movem.w	d0-d4,-(sp)	;push d0-d4 to stack (all new values are on stack)
	add.w	VRchar(a3),d3	;add VRChar of player struct to d3
	ext.l	d2	;extend d2 (clears out upper word)
	asl.l	#5,d2	;mult d2 by 32
	movem.l	d0/a2,-(sp)	;95: the tiles start at Sprites+$A
	movea.l	#Sprites,a2
	move.l	a2,d0
	addi.l	#$A,d0
	add.l	d0,d2
	movem.l	(sp)+,d0/a2
	asl.w	#4,d4	;mult by 16 (# of sprite tiles by 16)
	asl.w	#5,d3	;mult by 32 (# of prev sprite tiles+VrChar by 32)
	move.l	d2,(a5)+
	move.w	d4,(a5)+	;words to transfer
	move.w	d3,(a5)+	;vram destination
	movem.w	(sp)+,d0-d4	;pop from stack
.dup
	move.b	d3,VRoffs(a3,d5.w)	;move d3 into VRoffs of sprite
	;This and VRChar are for VRAM access
.noref
	move.w	(sp)+,d0	;pop from stack
	movem.w	d0-d2,-(sp)	;push to stack
	move.w	(a2),d2	;Y global
	btst	#4,attribute(a3)	;check for Y flip
	beq.w	.noyflip	;branch if no y flip
	move.b	2(a2),d2	;size byte
	andi.w	#3,d2	;pass bit 1 and 2
	addq.w	#1,d2	;add 1
	asl.w	#3,d2	;mult by 8
	neg.w	d2	;negate d2
	sub.w	(a2),d2	;sub Y global from d2
.noyflip
	add.w	d2,d1	;add d2 to d1 (d1=Ypos of Sort Cord)
	move.w	d1,(a6)	;move sprite's Ypos into a6 data (Satt)
	move.w	6(a2),d2	;X global
	btst	#3,attribute(a3)	;check for x flip
	beq.w	.noxflip	;branch if no x flip
	move.b	2(a2),d2	;size byte
	andi.w	#$C,d2	;pass bit 3 and 4
	addq.w	#4,d2	;add 4
	asl.w	#1,d2	;mult by 2
	neg.w	d2	;negate d2
	sub.w	6(a2),d2	;sub X global from d2
.noxflip
	add.w	d2,d0	;add d2 to d0 (d0 = Xpos of Sort Cord)
	move.w	d0,6(a6)	;move sprite's Xpos into 6+a6 position (Satt)
	move.b	2(a2),2(a6)	;move size byte into 2+a6
	move.b	d6,3(a6)	;move d6 (link counter) into 3+a6
	move.b	4(a2),d2	;flags (top 5 bits of the tile word) to the high byte
	andi.w	#$F8,d2
	lsl.w	#8,d2
	move.b	2(a2),d2
	move.w	attribute(a3),d0	;move attribute into d0
	eor.w	d0,d2	;EOR d0 with d2
	andi.w	#$F800,d2	;pass top 5 bits
	btst	#0,attribute+1(a3)	;check if bit 0 of attribute+1 is 0
	beq.w	.nospec	;branch if zero
	btst	#$E,d2	;check if bit 14 is 0
	beq.w	.nospec	;branch if zero
	bset	#$D,d2	;set bit 13 - team 2 color
.nospec
	or.b	VRoffs(a3,d5.w),d2	;OR Vroffs of a3+d5 to d2
	add.w	VRchar(a3),d2	;add VRchar to d2
	move.w	d2,4(a6)	;move d2 into 4+a6 (Satt)
	movem.w	(sp)+,d0-d2	;pop from stack
	addq.w	#1,d6	;add 1 to d6
	addq.w	#8,a6	;add 8 to a6
	addq.w	#8,a2	;add 8 to a2
	dbf	d5,.sloop	;loop if still sprites in frame
.exit
	movem.l	(sp)+,d0-d5/a0-a2
	move.w	(sp)+,attribute(a3)
	rts

sizetab	;sprite size code to tile count. 92 video.asm sizetab, used by addframe2 (94 kept it in data94)
	dc.b	1,2,3,4,2,4,6,8,3,6,9,$C,4,8,$C,$10

updatescroll	;IDA: sub_79F64. 92 name; 93 show_rink. Using hpos and vpos set scroll cords; queue rink map rows on the dma list (a5) when vertical
	;scrolling needs new rows. Called from setvideo (display95_01). Rows from Rinktilelist, or RevRinkTilelist in a reverse angle replay
	;(sflags4 bit 4). 95 has no horizontal rink check
	moveq	#-$40,d0	;-192+128 (IDA #$FFFFFFC0)
	sub.w	(Hpos).w,d0
	move.w	(Vpos).w,d1
	addi.w	#$10,d1	;95: rink 16 lines lower
	move.w	d0,(Hscroll).w
	move.w	d1,(Vscroll).w
	neg.w	(Vscroll).w
	move.w	(Oldrow).w,d4
	asr.w	#3,d1
	move.w	d1,(Oldrow).w
	moveq	#$1F,d3	;max lines to update
	cmp.w	d4,d1
	beq.w	rtss2	;same row as last frame
	movea.l	#Rinktilelist,a0
	adda.l	4(a0),a0	;a0 = map header: (a0) = chars per row, data at 4(a0) (the movea / adda leave the cmp flags)
	blt.w	.su0	;row went up
	btst	#4,(sflags4).w	;reverse angle replay
	beq.w	.sd
	movea.l	#RevRinkTilelist,a0	;95 does not add the header offset here
.sd
	move.w	d1,d0
	neg.w	d0
	addi.w	#$1E,d0
	andi.w	#$1F,d0
	asl.w	#7,d0
	add.w	(VmMap2).w,d0
	move.w	d0,6(a5)
	move.w	#$1E,d0
	sub.w	d1,d0
	move.w	(a0),4(a5)
	mulu.w	(a0),d0
	add.w	d0,d0
	lea	4(a0,d0.w),a1
	move.l	a1,(a5)
	addq.w	#8,a5
	subq.w	#1,d1
	cmp.w	d4,d1
	dbeq	d3,.sd
	rts
.su0
	btst	#4,(sflags4).w	;reverse angle replay
	beq.w	.su
	movea.l	#RevRinkTilelist,a0
.su
	move.w	d1,d0
	neg.w	d0
	addi.w	#$1D,d0
	andi.w	#$1F,d0
	asl.w	#7,d0
	add.w	(VmMap2).w,d0
	move.w	d0,6(a5)
	move.w	#$3D,d0
	sub.w	d1,d0
	move.w	(a0),4(a5)
	mulu.w	(a0),d0
	add.w	d0,d0
	lea	4(a0,d0.w),a1
	move.l	a1,(a5)
	addq.w	#8,a5
	addq.w	#1,d1
	cmp.w	d4,d1
	dbeq	d3,.su
	rts
