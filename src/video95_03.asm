; $07C512  Adapted from video94.asm: display helpers
;	NHL 95 segment $7C512-$7DE9F, from lst/nhl95.bin.lst. Helpers from many 94 files: video94 sroot, checks94 vtoa, display94 find3d, video94
;	randomd0s / randomd0, checks94 GetHot, menu94 vcountwait, video94 printz2, printsmall (ControlCodeJumpTable and the control codes),
;	printz, print, eraser, display94 showclock (95: big digits when paused, PutClockDigit), data94 PerLabels / PenShotPenalties2, collide94
;	makepde / getpde, title94 ReadGoaliePulled, stats94 ReadAttributeNibble / GetDefenseStart / ProcessNibble (95: season data versions),
;	data94 player name formatting (95: by team struct a2 or team number d7), cards94 CalcAttrib and its weight lists, video94 PushTime,
;	PushNumber, PushNumberWidth, appendz, appstring, setup94 setupTeamBlocksMap / CopyTeamBlockMapData, video94 DoDMA_nd2, TeamLogoBitmaps,
;	hockey94 ResetClock / GetPeriodTime, penalty94 ClrHor, the 95 AssignPads, video94 waitx, penalty94 PrintScores1 / PrintTeamNameAndScore,
;	checks94 chkpk / chkpk2, video94 printbigz ... PutBigTile, data94 bfasciicon, title94 UnpackPicture, penalty94 RestoreTeamEnergy,
;	checks94 WeightedRandomSelect, cards94 AppendTeamName ... TrimSpaces, then setup94 setupice. fourway95 (94 LoadHomeTeamGfx) follows at $7DEA0.
;	IDA dc.b written as instructions: the ControlCodeJumpTable code, GetDefenseStart, GetForwards, ProcessNibble ... getnameD7,
;	FormatPlayerNameLast ... FormatLastName, FormatLastNameAlt, PushNumberWidthZero, GetTeamLogo, DrawTeamLogo, ClrHor, AssignPads,
;	ReAddFramer, ReAddSmallFont, chkpk, printbigz2, printbig2, RestoreTeamEnergy, AppendTeamName ... TrimSpaces. IDA hid the printz Strings
;	in showclock, getname and PrintScores1 as instructions; they are String here.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.

sroot	;IDA: sub_7C512. d0 = square root of d0 (long). Small values by odd subtraction, else Newton steps, else a binary search
	tst.l	d0
	beq.w	rtss2
	cmp.l	#$640,d0
	bhi.w	.1
	move.l	d1,-(sp)
	moveq	#-1,d1
.0
	addq.w	#2,d1
	sub.w	d1,d0
	bcc.s	.0
	lsr.w	#1,d1
	move.w	d1,d0
	move.l	(sp)+,d1
	rts
.1
	movem.l	d1-d4,-(sp)
	moveq	#9,d3
	move.w	#$8000,d1
	cmp.l	#$F00000,d0
	bhi.w	.4
	move.l	d0,d1
	lsr.l	#8,d1
	addq.w	#2,d1
.2
	move.w	d1,d2
	move.l	d0,d1
	divu.w	d2,d1
	add.w	d2,d1
	lsr.w	#1,d1
	cmp.w	d1,d2
	dbeq	d3,.2
.3
	move.w	d1,d0
	movem.l	(sp)+,d1-d4
	rts
.4
	moveq	#0,d1
	moveq	#-1,d2
.5
	move.w	d1,d3
	add.w	d2,d3
	roxr.w	#1,d3
	cmp.w	d3,d1
	beq.s	.3
	move.w	d3,d4
	mulu.w	d3,d3
	cmp.l	d3,d0
	bcc.w	.6
	move.w	d4,d2
	bra.s	.5
.6
	move.w	d4,d1
	bra.s	.5

vtoa	;IDA: sub_7C586. 93 name. d0/d1 = vector: return d0 = direction 0-7 (8 for no vector) through .dt
	movem.l	d2/a0,-(sp)
	move.w	d0,d2
	or.w	d1,d2
	beq.w	.4
	clr.w	d2
	tst.w	d0
	bpl.w	.0
	neg.w	d0
	bset	#0,d2
.0
	tst.w	d1
	bpl.w	.1
	neg.w	d1
	bset	#1,d2
.1
	asl.w	#1,d1
	cmp.w	d1,d0
	bhi.w	.2
	bset	#2,d2
.2
	lsr.w	#1,d0
	cmp.w	d0,d1
	bhi.w	.3
	bset	#3,d2
.3
	movea.l	#.dt,a0
	clr.w	d0
	move.b	(a0,d2.w),d0
	movem.l	(sp)+,d2/a0
	rts
.4
	moveq	#8,d0
	movem.l	(sp)+,d2/a0
	rts
.dt
	dc.b	1,7,3,5,0,0,4,4,2,6,2,6,1,7,3,5

find3d	;IDA: sub_7C5EE. input: d0 = xfield, d1 = yfield, d2 = height off field. Output: d0 = xscreen, d1 = yscreen, or d1 = $4E20 (92 osflag) when off screen. 95: no horizontal rink
	;case, range x +-$98, y -$D0..$79
	sub.w	(Hpos).w,d0
	sub.w	(Vpos).w,d1
	cmp.w	#$98,d0
	bgt.w	.0
	cmp.w	#$FF70,d0
	blt.w	.0
	addi.w	#$100,d0
	add.w	d2,d1
	asr.w	#1,d2
	add.w	d2,d1
	cmp.w	#$79,d1
	bgt.w	.0
	cmp.w	#$FF30,d1
	blt.w	.0
	neg.w	d1
	addi.w	#$F0,d1
	rts
.0
	move.w	#$4E20,d1
	rts

randomd0s	;IDA: sub_7C62E. d0 = random number from -d0 to d0-1 (randomd0(d0*2) - d0)
	move.w	d0,-(sp)
	asl.w	#1,d0
	bsr.w	randomd0
	sub.w	(sp)+,d0
	rts

randomd0	;IDA: sub_7C63A. d0 = random number 0 to d0-1 (RNGseed * $BB40E62D + 1)
	movem.l	d0-d2,-(sp)
	move.w	(RNGseed+2).w,d0
	move.w	d0,d1
	move.w	(RNGseed).w,d2
	mulu.w	#$E62D,d0
	mulu.w	#$BB40,d1
	mulu.w	#$E62D,d2
	add.w	d2,d1
	swap	d0
	add.w	d1,d0
	swap	d0
	addq.l	#1,d0
	move.l	d0,(RNGseed).w
	asr.l	#8,d0
	mulu.w	2(sp),d0
	swap	d0
	addq.w	#4,sp
	movem.l	(sp)+,d1-d2
	rts

GetHot	;IDA: sub_7C672. Push long address of structure to get hot spot from; hot spot x/y returned in d0/d1 (HotSpotList by frame, flipped with the attribute)
	movem.l	a0-a1,-(sp)
	movea.l	$C(sp),a0
	clr.w	d0
	clr.w	d1
	tst.w	6(a0)
	ble.w	.1
	movea.l	#HotSpotList,a1
	move.w	6(a0),d0
	add.w	d0,d0
	move.b	1(a1,d0.w),d1
	ext.w	d1
	move.b	(a1,d0.w),d0
	ext.w	d0
	btst	#3,4(a0)
	beq.w	.0
	neg.w	d0
.0
	btst	#4,4(a0)
	bne.w	.1
	neg.w	d1
.1
	movem.l	(sp)+,a0-a1
	move.l	(sp)+,(sp)
	rts

vcountwait	;IDA: sub_7C6BE. IDA name and comment (93 MenuWaitVblank): waits till vcount changes, then resyncs vcount. Saves d0. 94 reads oldvcount twice. Called from PauseMode, sram94,
	;hockey94_02 and the stats code
	move.w	d0,-(sp)
	move.w	(oldvcount).w,d0
.0
	cmp.w	(vcount).w,d0
	beq.s	.0
	move.w	(vcount).w,(oldvcount).w
	move.w	(sp)+,d0
	rts

printz2	;IDA: sub_7C6D4. printsmall with the String after the call (93 printsmallz)
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printsmall
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printsmall	;IDA: sub_7C6E6. print String a1 with the small font at printx / printy (control codes < 0 through ControlCodeJumpTable, $40 a blank, $5E a new line). 95 takes the map from
	;smallfontptr
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movem.l	d0-d3/a0/a2-a3,-(sp)
	movea.w	#(smallfontchars-M68K_RAM),a3
	bsr.w	xyVmMap
	move.w	(printa).w,d2
	move.w	(a1)+,d3
	subq.w	#2,d3
	bra.w	.4
.0
	move.b	(a1)+,d0
	ext.w	d0
	bgt.w	.1
	neg.w	d0
	asl.w	#2,d0
	movea.l	#ControlCodeJumpTable,a2
	movea.l	(a2,d0.w),a2
	jsr	(a2)
	bra.w	.4
.1
	cmp.b	#$40,d0
	bne.w	.2
	move.w	#$7FF,d0
	bra.w	.3
.2
	cmp.b	#$5E,d0
	beq.w	.5
	asl.w	#1,d0
	movea.l	(smallfontptr).w,a2
	adda.l	4(a2),a2
	move.w	4(a2,d0.w),d0
	move.w	(printfontset).w,d1
	add.w	(a3,d1.w),d0
.3
	add.w	d2,d0
	move.w	d0,(a0)
	addq.w	#1,(printx).w
.4
	dbf	d3,.0
	movem.l	(sp)+,d0-d3/a0/a2-a3
	move.w	(sp)+,(disflags).w
	rts
.5
	addq.w	#1,(printx).w
	bsr.w	xyVmMap
	bra.s	.4

ControlCodeJumpTable	;IDA: unk_7C772 (dc.b). 93 name. printsmall control codes, indexed by -byte
	dc.l	ControlCode_None	;0: padding, no-op (the rts of ControlCode_SetFont)
	dc.l	ControlCode_SetMap	;-1: map
	dc.l	ControlCode_SetAttribute	;-2: palette/priority
	dc.l	ControlCode_SetX	;-3: x
	dc.l	ControlCode_SetY	;-4: y
	dc.l	ControlCode_AddX	;-5: x offset
	dc.l	ControlCode_AddY	;-6: y offset
	dc.l	ControlCode_SetFont	;-7: char set
	dc.l	ControlCode_SetMapAndPosition	;-8: attribute, map, x, y
ControlCode_SetMapAndPosition	;$7C796. 93: printsmall control code -8, next 4 bytes = attribute, map, x, y
	bsr.w	ControlCode_SetAttribute
	bsr.w	ControlCode_SetMap
	bsr.w	ControlCode_SetX
	bra.w	ControlCode_SetY
ControlCode_SetMap	;93 name. Control code -1, next byte = map number -> printm
	move.b	(a1)+,d0
	subq.w	#1,d3
	andi.w	#3,d0
	asl.w	#2,d0
	subq.w	#4,d0
	move.w	d0,(printm).w
	bra.w	xyVmMap
ControlCode_SetAttribute	;93 name. Control code -2, next byte = palette/priority -> printa
	move.b	(a1)+,d2
	andi.w	#7,d2
	subq.w	#1,d3
	ror.w	#3,d2
	move.w	d2,(printa).w
	rts
ControlCode_SetX	;93 name. Control code -3, next byte = printx
	clr.w	d0
	move.b	(a1)+,d0
	subq.w	#1,d3
	move.w	d0,(printx).w
	bra.w	xyVmMap
ControlCode_SetY	;93 name. Control code -4, next byte = printy
	clr.w	d0
	move.b	(a1)+,d0
	subq.w	#1,d3
	move.w	d0,(printy).w
	bra.w	xyVmMap
ControlCode_AddX	;93: control code -5, add the next (signed) byte to printx
	move.b	(a1)+,d0
	ext.w	d0
	subq.w	#1,d3
	add.w	d0,(printx).w
	bra.w	xyVmMap
ControlCode_AddY	;93: control code -6, add the next (signed) byte to printy
	move.b	(a1)+,d0
	ext.w	d0
	subq.w	#1,d3
	add.w	d0,(printy).w
	bra.w	xyVmMap
ControlCode_SetFont	;93: control code -7, next byte = char set index
	clr.w	d0
	move.b	(a1)+,d0
	subq.w	#1,d3
	asl.w	#1,d0
	move.w	d0,(printfontset).w
ControlCode_None	;control code 0: no-op
	rts

printz	;IDA: sub_7C810. see print. String macro should follow jsr to this routine
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	print
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

print	;IDA: sub_7C822. print String a1 at printx / printy with the small font (smallfontptr): a negative byte sets printa / printm / printx / printy from the next bytes, $40 a blank,
	;$5E a new line
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movem.l	d0-d3/a0/a2,-(sp)
	bsr.w	xyVmMap
	move.w	(printa).w,d2
	move.w	(a1)+,d3
	subq.w	#2,d3
	bra.w	.4
.0
	move.b	(a1)+,d0
	beq.w	.4
	ext.w	d0
	bpl.w	.1
	neg.w	d0
	move.w	d0,d2
	asl.w	#8,d2
	asl.w	#1,d2
	andi.w	#$F800,d2
	move.w	d2,(printa).w
	andi.w	#3,d0
	asl.w	#2,d0
	subq.w	#4,d0
	move.w	d0,(printm).w
	move.b	(a1)+,d0
	ext.w	d0
	move.w	d0,(printx).w
	move.b	(a1)+,d1
	ext.w	d1
	move.w	d1,(printy).w
	bsr.w	xyVmMap
	subq.w	#2,d3
	bra.w	.4
.1
	cmp.b	#$40,d0
	bne.w	.2
	move.w	#$7FF,d0
	bra.w	.3
.2
	cmp.b	#$5E,d0
	beq.w	.5
	asl.w	#1,d0
	movea.l	(smallfontptr).w,a2
	adda.l	4(a2),a2
	move.w	4(a2,d0.w),d0
	add.w	(smallfontchars).w,d0
.3
	add.w	d2,d0
	move.w	d0,(a0)
	addq.w	#1,(printx).w
.4
	dbf	d3,.0
	movem.l	(sp)+,d0-d3/a0/a2
	move.w	(sp)+,(disflags).w
	rts
.5
	addq.w	#1,(printx).w
	bsr.w	xyVmMap
	bra.s	.4

eraser	;IDA: sub_7C8CC. fill a d0 x d1 rectangle with char d2 at printx / printy / printm
	movem.l	d0-d2/a0,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movem.w	d0-d1,-(sp)
.0
	jsr	(xyVmMap).l
	move.w	(sp),d0
	subq.w	#1,d0
.1
	move.w	d2,(a0)
	dbf	d0,.1
	addq.w	#1,(printy).w
	andi.w	#$1F,(printy).w
	subq.w	#1,2(sp)
	bne.s	.0
	addq.w	#4,sp
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0-d2/a0
	rts

showclock	;IDA: sub_7C90A. put the game clock on screen. Called from setvideo (display95_01) and PauseMode. 95: paused (sfpz), the clock is drawn
	;as big digits with PutClockDigit at printz position $10, 4 (no colon when under 10 minutes); else showclockdma
	btst	#sfpz,(sflags).w
	beq.w	showclockdma
	move.l	a1,-(sp)
	jsr	(printz).l
	String	$BE,$10,4,0
	move.w	(gameclock).w,d0
	ext.l	d0
	divu.w	#$258,d0	;tens of minutes
	move.l	d0,-(sp)
	tst.w	d0
	bne.w	.0
	addq.w	#2,(printx).w
	bra.w	.1
.0
	jsr	(PutClockDigit).l
.1
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	divu.w	#$3C,d0	;minutes
	move.l	d0,-(sp)
	jsr	(PutClockDigit).l
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	move.l	d0,-(sp)
	move.w	#$A,d0	;the colon
	jsr	(PutClockDigit).l
	subq.w	#1,(printx).w
	move.l	(sp)+,d0
	divu.w	#$A,d0	;tens of seconds
	move.l	d0,-(sp)
	jsr	(PutClockDigit).l
	move.l	(sp)+,d0
	swap	d0
	ext.l	d0
	jsr	(PutClockDigit).l	;seconds
	movea.l	(sp)+,a1
	jsr	(printz).l
	String	$BD,$D,5,0
	rts

PutClockDigit	;IDA: sub_7C994. 95 only. Draw big clock digit d0 (0-9, $A the colon) at printx / printy from ClockDigitsBitmap (dobitmap, chars clockdigitchars), then printx + 2
	movem.w	d0-d7,-(sp)
	movea.l	#ClockDigitsBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	asl.w	#1,d0
	move.w	#0,d1
	move.w	#2,d2
	move.w	#3,d3
	movea.l	#$69A,a2
	move.w	(clockdigitchars).w,d4
	moveq	#0,d5
	jsr	(dobitmap).l
	addq.w	#2,(printx).w
	movem.w	(sp)+,d0-d7
	rts

showclockdma	;IDA: loc_7C9D0. 94 showclock vertical rink body (.3): when dfclock is set queue the clock chars in the dma list (a5); with gmode2 bit 1 shootoutclock is shown. Not in a
	;stoppage (sflags2 bit 3) or game over (gsp 4)
	bclr	#3,(disflags).w
	beq.w	.2
	btst	#3,(sflags2).w
	bne.w	.2
	cmpi.w	#4,(gsp).w
	beq.w	.2
	movea.w	#(clockram+6-M68K_RAM),a0
	movea.l	(smallfontptr).w,a1
	adda.l	4(a1),a1
	move.w	$78(a1),d0
	add.w	(smallfontchars).w,d0
	ori.w	#$8000,d0
	move.w	d0,(clockram).w
	move.w	(gameclock).w,d0
	btst	#1,(gmode2).w
	beq.w	.0
	move.w	(shootoutclock).w,d0
.0
	ext.l	d0
	divu.w	#$A,d0
	bsr.w	ClockDigitChar
	divu.w	#6,d0
	bsr.w	ClockDigitChar
	subq.w	#2,a0
	divu.w	#$A,d0
	bsr.w	ClockDigitChar
	swap	d0
	tst.l	d0
	bne.w	.1
	moveq	#-$10,d0
	swap	d0
.1
	bsr.w	ClockDigitChar
	move.l	a0,(a5)+
	move.w	#5,(a5)+
	movea.w	#(VmMap1-M68K_RAM),a1
	moveq	#$18,d0
	moveq	#3,d2
	move.w	2(a1),d1
	asl.w	d1,d0
	add.w	d2,d0
	asl.w	#1,d0
	add.w	(a1),d0
	move.w	d0,(a5)+
.2
	rts

ClockDigitChar	;IDA: sub_7CA66. showclockdma helper: next digit of d0 (divu remainder) as a clock char word to -(a0)
	swap	d0
	asl.w	#1,d0
	move.w	$64(a1,d0.w),d0
	add.w	(smallfontchars).w,d0
	ori.w	#$8000,d0
	move.w	d0,-(a0)
	swap	d0
	ext.l	d0
	rts

PerLabels	;IDA: unk_7CA7E (dc.b). 93 name. text list for periods; 94 ' F' (93 'Final'). Used by PrintScores1
	String	'1',$12
	String	'2',$13
	String	'3',$14
	String	'OT'
	String	' F'

PenShotPenalties2	;IDA: unk_7CA92 (dc.b). 94 only: the same with a blank last entry. Used by PrintScores1
	String	'1',$12
	String	'2',$13
	String	'3',$14
	String	'OT'
	String	'  '

makepde	;IDA: sub_7CAA6. pass d0 as value to be scaled by player a0's energy level (full energy while sflags7 bit 4 is set). Return d0 as result
	ext.w	d0
	move.w	d0,-(sp)
	movem.l	d1/a2-a3,-(sp)
	movea.l	a0,a3
	bsr.w	getpde
	btst	#4,(sflags7).w
	beq.w	.0
	move.w	#$1000,d0
.0
	movem.l	(sp)+,d1/a2-a3
	muls.w	(sp)+,d0
	asl.l	#4,d0
	swap	d0
	ext.l	d0
	rts

getpde	;IDA: sub_7CAD0. get player a3's energy level into d0. Return a2 = his team struct, d1 = pnum*2
	movea.w	#(HmShots-M68K_RAM),a2
	btst	#6,pflags(a3)
	beq.w	.0
	adda.w	#$366,a2
.0
	move.b	pnum(a3),d1
	ext.w	d1
	add.w	d1,d1
	move.w	$34(a2,d1.w),d0
	rts

loadTeamStruct	;IDA: sub_7CAF0. 95 only. a2 = team struct of player a3, a1 = the other team
	movea.w	#(HmShots-M68K_RAM),a2
	movea.w	#(HmShots-M68K_RAM),a2
	lea	$366(a2),a1
	btst	#6,pflags(a3)
	beq.w	.0
	exg	a1,a2
.0
	rts

ReadGoaliePulled	;IDA: sub_7CB0A. IDA name (and comments). 94 only: Z clear when the team of a3 pulled its goalie ($26 of the team struct). Called from doshot (logic94_1), assdefo
	;(logic94_2), asspuckc (logic94_3) and assnearest (logic94_4)
	movem.l	a1,-(sp)
	movea.l	#HmShots,a1
	btst	#6,pflags(a3)
	beq.w	.0
	movea.l	#AwShots,a1
.0
	tst.w	$26(a1)
	movem.l	(sp)+,a1
	rts

PrintListItem	;IDA: sub_7CB2E. 95 only. printz String d0 of the list a1 (SkipStrings)
	bsr.w	SkipStrings
	jmp	print

PrintSmallListItem	;IDA: sub_7CB38. 95 only. printsmall String d0 of the list a1 (SkipStrings)
	bsr.w	SkipStrings
	jmp	printsmall

SkipStrings	;IDA: sub_7CB42. 95 only. a1 = String d0 of a String list
	bra.w	.1
.0
	adda.w	(a1),a1
.1
	dbf	d0,.0
	rts

ReadAttributeNibble	;IDA: sub_7CB4E. 93 name. d0 = goalies on team a2 (ReadAttributeNibbleD7 with d7 = the team number)
	movem.l	d7-a0,-(sp)
	move.w	$28(a2),d7
	bsr.w	ReadAttributeNibbleD7
	movem.l	(sp)+,d7-a0
	rts

ReadAttributeNibbleD7	;IDA: sub_7CB60. 95 only. d0 = goalies on team d7: from the season data in save RAM ($1B80 + team * $38), or with sflags11 bit 6 from the team data nibbles
	btst	#6,(sflags11).w
	bne.w	.0
	movem.l	d1-d7/a0,-(sp)
	move.w	d7,d0
	mulu.w	#$38,d0
	addi.l	#$1B80,d0
	moveq	#1,d1
	movea.l	#SRAMbyte,a0
	jsr	(ReadSRAM).l
	clr.w	d0
	move.b	(a0),d0
	movem.l	(sp)+,d1-d7/a0
	rts
.0
	movem.l	d1/d7-a0,-(sp)
	movea.l	#TeamList,a0
	asl.w	#2,d7
	movea.l	(a0,d7.w),a0
	adda.w	$A(a0),a0
	move.w	(a0),d1
	clr.w	d0
.1
	addq.w	#1,d0
	asl.w	#4,d1
	bne.s	.1
	movem.l	(sp)+,d1/d7-a0
	rts

GetDefenseStartD7	;IDA: sub_7CBB6. 95 only. GetDefenseStart for team d7
	jsr	(ReadAttributeNibbleD7).l
	move.w	d0,-(sp)
	jsr	(ProcessNibbleD7).l
	add.w	(sp)+,d0
	rts

GetDefenseStart	;$7CBC8. IDA dc.b. 94 GetDefenseStart: d0 = goalies + forwards of team a2, the roster index of the first defenseman. 95: from the
	;season data unless sflags11 bit 6 (Regular Game)
	btst	#6,(sflags11).w
	bne.w	.team
	jsr	(ReadAttributeNibble).l
	move.w	d0,-(sp)
	jsr	(GetForwards).l
	add.w	(sp)+,d0
	rts
.team	;the 94 routine (team data)
	movem.l	a0,-(sp)
	bsr.w	ReadAttributeNibble
	move.w	d0,-(sp)
	movea.l	tmdata(a2),a0
	adda.w	8(a0),a0
	move.b	3(a0),d0
	lsr.w	#4,d0
	andi.w	#$F,d0
	add.w	(sp)+,d0
	movem.l	(sp)+,a0
	rts

ProcessNibbleD7	;IDA: sub_7CC08. 95 only. d0 = forwards on team d7 from the season data (save RAM $1B82 + team * $38)
	movem.l	d1-d7/a0,-(sp)
	move.w	d7,d0
	bra.w	ProcessNibbleSeason

GetForwards	;$7CC12. IDA dc.b. 95 only. d0 = forwards on team a2: ProcessNibble (team data) with sflags11 bit 6, else from the season data
	btst	#6,(sflags11).w
	bne.w	ProcessNibble
	movem.l	d1-d7/a0,-(sp)
	move.w	$28(a2),d0

ProcessNibbleSeason	;IDA: loc_7CC24. 95 only. Shared tail of GetForwards / ProcessNibbleD7: read the save RAM byte for team d0
	mulu.w	#$38,d0
	addi.l	#$1B82,d0
	moveq	#1,d1
	movea.l	#SRAMbyte,a0
	jsr	(ReadSRAM).l
	clr.w	d0
	move.b	(a0),d0
	movem.l	(sp)+,d1-d7/a0
	rts

ProcessNibble	;$7CC46. IDA dc.b. 93 name. d0 = forwards on team a2 (high nibble of team data byte 3 at +8)
	movem.l	a0,-(sp)
	movea.l	tmdata(a2),a0
	adda.w	8(a0),a0
	move.b	3(a0),d0
	lsr.w	#4,d0
	andi.w	#$F,d0
	movem.l	(sp)+,a0
	rts
GetTempPlayerName	;$7CC62. IDA dc.b. 93 GetPlayerName. a1 = mesarea "NN First Last" (getname) for player TempPlOffset (bit 15 set: away team)
	movem.l	d0/a2,-(sp)
	movea.w	#(HmShots-M68K_RAM),a2
	move.w	(TempPlOffset).w,d0
	bpl.w	.0
	andi.w	#$FF,d0
	adda.w	#tmsize,a2	;away team
.0
	bsr.w	getname
	movem.l	(sp)+,d0/a2
	rts
getnameD7	;$7CC84. IDA dc.b. 95 only. getname for player d0 of team number d7
	movem.l	d0-d3/d7-a0/a2-a3,-(sp)
	bsr.w	getplayernameD7
	bra.w	getnamebody

getname	;IDA: sub_7CC90. IDA name (93 getname). a1 = mesarea "NN First Last" for player d0 of team struct a2. 95 reads the number with GetJerseyNumber
	movem.l	d0-d3/d7-a0/a2-a3,-(sp)
	move.w	$28(a2),d7
	bsr.w	getplayername
getnamebody	;getnameD7 joins here
	move.l	a0,-(sp)
	movea.w	#(mesarea-M68K_RAM),a3
	move.w	#4,(a3)
	lea	2(a3),a1
	adda.w	(a0),a0
	jsr	(GetJerseyNumber).l
	move.b	(jerseynum).w,d0
	bsr.w	d0toascii
	bsr.w	appendz	;add space after JNo
	String	' '
	movea.l	(sp)+,a1
	bsr.w	appstring
	movea.w	#(mesarea-M68K_RAM),a1
	movem.l	(sp)+,d0-d3/d7-a0/a2-a3
	rts

GetTempPlayerNameAttrib	;IDA: sub_7CCD2. 95 only. GetTempPlayerName with FormatPlayerNameWithAttrib ("NN F. Last")
	movem.l	d0/a2,-(sp)
	movea.w	#(HmShots-M68K_RAM),a2
	move.w	(TempPlOffset).w,d0
	bpl.w	.0
	andi.w	#$FF,d0
	adda.w	#$366,a2
.0
	bsr.w	FormatPlayerNameWithAttrib
	movem.l	(sp)+,d0/a2
	rts

FormatPlayerInitialD7	;IDA: sub_7CCF4. 95 only. a1 = mesarea "F. Last" for player d0 of team d7
	movem.l	d0-d3/d7-a0/a2,-(sp)
	bsr.w	getplayernameD7
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
	move.b	(a0)+,(a1)+
	move.b	#$2E,(a1)+
	move.b	#$20,(a1)+
.0
	cmpi.b	#$20,(a0)+
	bne.s	.0
.1
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.1
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

FormatPlayerNameWithAttribD7	;IDA: sub_7CD2C. 95 only. FormatPlayerNameWithAttrib for team d7
	movem.l	d0-d3/d7-a0/a2,-(sp)
	bsr.w	getplayernameD7
	bra.w	NameWithAttrib

FormatPlayerNameWithAttrib	;IDA: sub_7CD38. 93 name. a1 = mesarea string "NN F. Last" for player d0 of team a2, built in TextBuffer (93 name). Called from PenaltyShotBox and others
	movem.l	d0-d3/d7-a0/a2,-(sp)
	move.w	$28(a2),d7
	bsr.w	getplayername

NameWithAttrib	;IDA: loc_7CD44. shared body of FormatPlayerNameWithAttrib
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	jsr	(GetJerseyNumber).l
	move.b	(jerseynum).w,d0
	bsr.w	d0toascii
	move.b	#$20,(a1)+
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
	move.b	(a0)+,(a1)+
	move.w	#$2E20,(a1)+
.0
	cmpi.b	#$20,(a0)+
	bne.s	.0
.1
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.1
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

FormatPlayerNameD7	;IDA: sub_7CD82. 95 only. FormatPlayerName for team d7
	movem.l	d0-d3/d7-a0/a2,-(sp)
	bsr.w	getplayernameD7
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	jsr	(GetJerseyNumber).l
	move.b	(jerseynum).w,d0
	bsr.w	d0toascii
	move.b	#$20,(a1)+
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
.0
	cmpi.b	#$20,(a0)+
	bne.s	.0
.1
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.1
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

FormatPlayerName	;IDA: sub_7CDC2. 93 name. a1 = mesarea string "NN Last" for player d0 of team a2, built in TextBuffer. Called from DisplayPlayerAttributeMenu and others
	movem.l	d0-d3/d7-a0/a2,-(sp)
	move.w	$28(a2),d7
	bsr.w	getplayername
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	jsr	(GetJerseyNumber).l
	move.b	(jerseynum).w,d0
	bsr.w	d0toascii
	move.b	#$20,(a1)+
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
.0
	cmpi.b	#$20,(a0)+
	bne.s	.0
.1
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.1
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

FormatPlayerNameLast	;$7CE06. IDA dc.b. 94 only. FormatPlayerNameShort without the leading space ("Last", space padded). Branches into FormatLastName
	movem.l	d0-d3/a0/a2,-(sp)
	bsr.w	getplayername
	movea.w	#(TextBuffer-M68K_RAM),a1
	bra.w	FormatLastName
FormatPlayerNameShort	;$7CE16. IDA dc.b. 93 name. a1 = mesarea string " Last" for player d0 of team a2, space padded to 12 characters
	movem.l	d0-d3/a0/a2,-(sp)
	bsr.w	getplayername
	movea.w	#(TextBuffer-M68K_RAM),a1
	move.b	#$20,(a1)+
FormatLastName	;$7CE26. IDA dc.b. Skip the first name, copy the last name, pad; branched to from FormatPlayerNameLast, so global
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
.loop
	cmpi.b	#$20,(a0)+
	bne.s	.loop
.loop2
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	beq.w	.0
	tst.b	(a0)
	bne.s	.loop2
	bra.w	.0
.loop3
	move.b	#$20,(a1)+
.0
	cmpa.w	#(TextBuffer+12-M68K_RAM),a1
	blt.s	.loop3
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/a0/a2
	rts

FormatFirstNameD7	;IDA: sub_7CE56. 95 only. a1 = mesarea "First" for player d0 of team d7
	movem.l	d0-d3/d7-a0/a2,-(sp)
	bsr.w	getplayernameD7
	movea.w	#(TextBuffer-M68K_RAM),a1
	addq.w	#2,a0
.0
	move.b	(a0)+,(a1)+
	cmpi.b	#$20,(a0)
	bne.s	.0
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

FormatLastNameAlt	;$7CE76. IDA dc.b. 95 only. FormatLastNameD7 with the name string from GetCreatedName
	movem.l	d0-d3/d7/a0/a2,-(sp)
	movem.l	d0/d7/a2,-(sp)
	jsr	(GetCreatedName).l
	movea.l	a1,a0
	movem.l	(sp)+,d0/d7/a2
	bra.w	formatlastbody

FormatLastNameD7	;IDA: sub_7CE8E. 95 only. a1 = mesarea "Last" for player d0 of team d7
	movem.l	d0-d3/d7-a0/a2,-(sp)
	bsr.w	getplayernameD7
formatlastbody	;FormatLastNameAlt joins here
	move.l	a0,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	adda.w	(a0),a0
	move.b	(a0),d0
	movea.l	(sp)+,a0
	move.w	(a0)+,d0
	lea	-2(a0,d0.w),a2
.0
	cmpi.b	#$20,(a0)+
	bne.s	.0
.1
	move.b	(a0)+,(a1)+
	cmpa.l	a0,a2
	bne.s	.1
	bsr.w	FinalizeTextBuffer
	movem.l	(sp)+,d0-d3/d7-a0/a2
	rts

FinalizeTextBuffer	;IDA: sub_7CEBE. 93 name. mesarea length word = a1 - mesarea, with a 0 pad byte when odd. Returns a1 = mesarea. Called from the FormatPlayerName routines
	move.w	a1,d0
	subi.w	#$BBAA,d0
	btst	#0,d0
	beq.w	.0
	clr.b	(a1)+
	addq.w	#1,d0
.0
	movea.w	#(mesarea-M68K_RAM),a1
	move.w	d0,(a1)
	rts

getplayernameD7	;IDA: sub_7CED8. 95 only. getplayername for team d7
	movem.l	d0/d7/a2,-(sp)
	bra.w	getnamea0

getplayername	;IDA: sub_7CEE0. IDA name (93 GetPlayerNamePointer). loops through team roster to get to d0 player: a0 = name string of player d0 (roster offset) of team struct a2. Each
	;record is a length word String and 8 more bytes
	movem.l	d0/d7/a2,-(sp)
	move.w	$28(a2),d7

getnamea0	;IDA: loc_7CEE8. shared tail of getplayername: GetRosterName, a0 = the name
	jsr	(GetRosterName).l
	movea.l	a1,a0
	movem.l	(sp)+,d0/d7/a2
	rts

d0toascii	;IDA: sub_7CEF6. IDA name (93 ConverByteToDigits). converts decimal number in d0 to ascii: two ascii digits of bcd byte d0 to (a1)+, a leading 0 becomes a space ($F0 + '0')
	move.w	d0,-(sp)
	lsr.b	#4,d0
	bne.w	.0
	move.b	#$F0,d0
.0
	addi.b	#$30,d0
	move.b	d0,(a1)+
	move.w	(sp)+,d0
	andi.w	#$F,d0
	addi.b	#$30,d0
	move.b	d0,(a1)+
	rts

CalcAttrib	;IDA: sub_7CF16. IDA name (and comments). 94 only: the overall rating of player d0: his attributes weighted by OvrPlayerWgtList (skaters) or OvrGoalWgtList (goalies), and by
	;AttribWgtList. Called from getNameandAttrib (stats94) and PrintOverallRating
	move.l	a6,-(sp)
	clr.w	(attribsum).w
	clr.w	(attribcount).w
	movea.l	#AttribWgtList,a6
	cmp.l	(PAttribOverallMask).l,d4
	bne.w	.0
	movea.l	#OvrPlayerWgtList,a6
.0
	cmp.l	(GAttribOverallMask).l,d4
	bne.w	.1
	movea.l	#OvrGoalWgtList,a6
.1
	lea	$1A4(a2),a4
	clr.l	d1
	move.w	d0,d1
	asl.w	#4,d1
	adda.l	d1,a4
	adda.l	#$10,a4
	movem.l	d7/a1,-(sp)
	move.w	$28(a2),d7
	jsr	(GetRosterName).l
	adda.w	(a1),a1
	addq.w	#8,a1
	movea.l	a1,a0
	movem.l	(sp)+,d7/a1
	bsr.w	CalcAttribRating
	movea.l	(sp)+,a6
	rts

CalcAttribRating	;IDA: sub_7CF78. 95 only. The rating sum of CalcAttrib: d0 / d1 = weighted sum of the attributes in d4 bits (weights a6), d1 the maximum. With AttribWgtList (create
	;player) it clamps the attribute to 0-$63 and adjusts CreatePoints
	clr.w	(attribsum).w
	clr.w	(attribcount).w
	clr.w	d0
	clr.w	d1
	moveq	#$F,d2
	swap	d4
.0
	btst	d2,d4
	beq.w	.10
	move.w	d2,d3
	lsr.w	#1,d3
	neg.w	d3
	move.b	-1(a0,d3.w),d3
	btst	#0,d2
	beq.w	.1
	lsr.w	#4,d3
.1
	andi.w	#$F,d3
	cmp.w	#$D,d2
	bne.w	.2
	bra.w	.9
.2
	cmp.w	#5,d2
	bne.w	.3
	move.l	a0,-(sp)
	movea.l	#AttribScaleTable,a0
	move.b	(a0,d3.w),d3
	movea.l	(sp)+,a0
.3
	cmp.w	#6,d2
	beq.w	.9
	movem.l	d5-d7,-(sp)
	move.b	(a6,d2.w),d5
	ext.w	d5
	cmp.w	#2,d5
	beq.w	.5
	move.w	d3,-(sp)
	subq.w	#2,d5
.4
	add.w	(sp),d3
	dbf	d5,.4
	asr.w	#1,d3
	tst.w	(sp)+
.5
	movem.l	(sp)+,d5-d7
	cmpa.l	#AttribWgtList,a6
	beq.w	.6
	neg.w	d2
	move.w	d7,-(sp)
	move.b	-1(a4,d2.w),d7
	ext.w	d7
	add.w	d7,(attribsum).w
	addq.w	#1,(attribcount).w
	move.w	(sp)+,d7
	neg.w	d2
	bra.w	.9
.6
	move.w	d3,-(sp)
	asl.w	#4,d3
	add.w	(sp),d3
	add.w	(sp)+,d3
	neg.w	d2
	add.b	-1(a4,d2.w),d3
	bpl.w	.7
	clr.b	d3
	addq.b	#1,-1(a4,d2.w)
	opt	osq-	;keep the retail subi / addi (SNASM would make subq / addq)
	subi.w	#1,(CreatePoints).l
	opt	osq+
.7
	cmp.b	#$63,d3
	ble.w	.8
	move.b	#$63,d3
	subq.b	#1,-1(a4,d2.w)
	opt	oaq-
	addi.w	#1,(CreatePoints).l
	opt	oaq+
.8
	neg.w	d2
.9
	add.w	d3,d0
	addi.w	#$64,d1
.10
	dbf	d2,.0
	cmpa.l	#AttribWgtList,a6
	beq.w	.11
	move.w	#$64,d1
	movem.l	d6-d7,-(sp)
	move.w	(attribsum).w,d6
	ext.l	d6
	move.w	(attribcount).w,d7
	divs.w	d7,d6
	add.w	d6,d0
	movem.l	(sp)+,d6-d7
.11
	cmp.w	d1,d0
	blt.w	.12
	move.w	d0,d1
	subq.w	#1,d0
.12
	rts

OvrPlayerWgtList	;IDA: unk_7D08C (dc.b). Skater attribute weights for the overall rating (CalcAttrib)
	dc.b	$02,$02,$02,$02,$04,$06,$02,$04,$02,$04,$06,$06,$04,$02,$02,$02

OvrGoalWgtList	;IDA: unk_7D09C (dc.b). Goalie attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$09,$09,$02,$02,$09,$02,$02,$02

AttribWgtList	;IDA: unk_7D0AC (dc.b). Single attribute weights
	dc.b	$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02

PushTime	;IDA: sub_7D0BC. a1 = String "M:SS" of the time d0 (seconds), built back from mesarea+30
	movea.w	#(mesarea+30-M68K_RAM),a1
	move.l	d0,-(sp)
	move.l	a1,-(sp)
	ext.l	d0
	divu.w	#$A,d0
	swap	d0
	addi.w	#$30,d0
	move.b	d0,-(a1)
	swap	d0
	ext.l	d0
	divu.w	#6,d0
	swap	d0
	addi.w	#$30,d0
	move.b	d0,-(a1)
	swap	d0
	move.b	#$3A,-(a1)
	ext.l	d0
	divu.w	#$A,d0
	swap	d0
	addi.w	#$30,d0
	move.b	d0,-(a1)
	swap	d0
	move.b	#$20,-(a1)
	tst.w	d0
	beq.w	.0
	addi.w	#$30,d0
	move.b	d0,(a1)
.0
	move.l	(sp)+,d0
	sub.l	a1,d0
	addq.w	#2,d0
	btst	#0,d0
	beq.w	.1
	clr.b	-(a1)
	addq.w	#1,d0
.1
	move.w	d0,-(a1)
	move.l	(sp)+,d0
	rts

PushNumber	;IDA: sub_7D120. a1 = String of the decimal number d0, built back from PushNumberBuf
	movea.w	#(PushNumberBuf-M68K_RAM),a1
	move.l	d0,-(sp)
	move.l	a1,-(sp)
.0
	ext.l	d0
	divu.w	#$A,d0
	swap	d0
	addi.w	#$30,d0
	move.b	d0,-(a1)
	swap	d0
	tst.w	d0
	bne.s	.0
	move.l	(sp)+,d0
	sub.l	a1,d0
	addq.w	#2,d0
	btst	#0,d0
	beq.w	.1
	clr.b	-(a1)
	addq.w	#1,d0
.1
	move.w	d0,-(a1)
	move.l	(sp)+,d0
	rts

PushNumberWidth	;IDA: sub_7D154. IDA: DeterStrLength? (93 name). Right-justified number
	movem.l	d0-d3,-(sp)
	movea.w	#(PushWidthBuf+2-M68K_RAM),a1
	moveq	#1,d2
	sub.w	d2,d1
	bra.w	.1
.0
	mulu.w	#$A,d2
.1
	dbf	d1,.0
	moveq	#$20,d3
.2
	ext.l	d0
	divu.w	d2,d0
	bne.w	.3
	cmp.w	#1,d2
	beq.w	.3
	move.w	d3,d0
	bra.w	.4
.3
	moveq	#$30,d3
	add.w	d3,d0
.4
	move.b	d0,(a1)+
	swap	d0
	divu.w	#$A,d2
	bne.s	.2
	move.l	a1,d0
	subi.w	#$BC0E,d0
	btst	#0,d0
	beq.w	.5
	clr.b	(a1)+
	addq.w	#1,d0
.5
	movea.w	#(PushWidthBuf-M68K_RAM),a1
	move.w	d0,(a1)
	movem.l	(sp)+,d0-d3
	rts

PushNumberWidthZero	;$7D1B0. IDA dc.b. 95 only. PushNumberWidth with leading zeros: d0 as d1 digits to PushWidthBuf (a String)
	movem.l	d0-d3,-(sp)
	movea.w	#(PushWidthBuf+2-M68K_RAM),a1
	moveq	#1,d2
	sub.w	d2,d1
	bra.w	.1
.0
	mulu.w	#$A,d2
.1
	dbf	d1,.0
	moveq	#$30,d3
.2
	ext.l	d0
	divu.w	d2,d0
	bne.w	.3
	cmp.w	#1,d2
	beq.w	.3
	move.w	d3,d0
	bra.w	.4
.3
	moveq	#$30,d3
	add.w	d3,d0
.4
	move.b	d0,(a1)+
	swap	d0
	divu.w	#$A,d2
	bne.s	.2
	move.l	a1,d0
	subi.w	#(PushWidthBuf-M68K_RAM),d0
	btst	#0,d0
	beq.w	.5
	clr.b	(a1)+
	addq.w	#1,d0
.5
	movea.w	#(PushWidthBuf-M68K_RAM),a1
	move.w	d0,(a1)
	movem.l	(sp)+,d0-d3
	rts

appendz	;IDA: sub_7D20C. appstring with the String after the call
	movea.l	(sp)+,a1
	bsr.w	appstring
	jmp	(a1)

appstring	;IDA: sub_7D214. Append String a1 to String a3 (the 0 pad byte dropped, the result padded to an even length)
	movem.l	d0/a0,-(sp)
	lea	2(a3),a0
	move.w	(a3),d0
	subq.w	#3,d0
	bmi.w	.1
.0
	addq.w	#1,a0
	tst.b	(a0)
	dbeq	d0,.0
.1
	move.w	(a1)+,d0
	subq.w	#3,d0
	bmi.w	.5
.2
	move.b	(a1)+,(a0)+
	bne.w	.3
	subq.w	#1,a0
.3
	dbf	d0,.2
	move.l	a0,d0
	btst	#0,d0
	beq.w	.4
	clr.b	(a0)+
	addq.l	#1,d0
.4
	sub.l	a3,d0
	move.w	d0,(a3)
.5
	movem.l	(sp)+,d0/a0
	rts

ScaleAttrib	;IDA: sub_7D258. 95 only. d0 below $32: d0 / 2 + $19
	cmp.w	#$32,d0
	bge.w	.0
	asr.w	#1,d0
	addi.w	#$19,d0
.0
	rts

PutTeamBlock	;IDA: sub_7D268. 95 only. Draw team block d0 (TeamBlockMaps, teamblockwidth wide, 2 rows) at printx / printy
	movem.l	d0-d2/a0-a1,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movea.w	#(TeamBlockMaps-M68K_RAM),a1
	adda.w	d0,a1
	moveq	#1,d2
.0
	jsr	(xyVmMap).l
	move.w	(teamblockwidth).w,d1
	subq.w	#1,d1
.1
	move.w	(a1)+,(a0)
	dbf	d1,.1
	addq.w	#1,(printy).w
	dbf	d2,.0
	move.w	(teamblockwidth).w,d0
	add.w	d0,(printx).w
	subq.w	#2,(printy).w
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0-d2/a0-a1
	rts

setupTeamBlocksMap	;IDA: sub_7D2AE. 93 name. Load the TeamBlocks map tiles (Teamblocksmap) at d4+$2C (93 $30) and copy the home and visitor team blocks to vram at basetileoffset and
	;basetileoffset+$16. d4 = 1st vram char; return d4 = basetileoffset+$2C. Called from setupice
	move.w	d4,(basetileoffset).w
	movea.l	(teamblocksmapptr).w,a0
	adda.l	4(a0),a0
	move.w	(a0),(teamblockwidth).w
	move.w	(teamblockwidth).w,d0
	asl.w	#2,d0
	add.w	d0,d4
	movea.w	#(TeamBlockMaps-M68K_RAM),a1
	movea.l	(teamblocksmapptr).w,a0
	lea	8(a0),a2
	bsr.w	DoDMA_clearCallbackPointer
	adda.l	4(a0),a0
	move.l	a0,-(sp)
	move.w	(HomeTeam).w,d0
	move.w	(basetileoffset).w,d1
	asl.w	#5,d1
	bsr.w	CopyTeamBlockMapData
	movea.l	(sp)+,a0
	move.w	(VisTeam).w,d0
	move.w	(basetileoffset).w,d1
	add.w	(teamblockwidth).w,d1
	add.w	(teamblockwidth).w,d1
	asl.w	#5,d1
	bsr.w	CopyTeamBlockMapData
	move.w	(basetileoffset).w,d4
	move.w	d0,-(sp)
	move.w	(teamblockwidth).w,d0
	asl.w	#2,d0
	add.w	d0,d4
	move.w	(sp)+,d0
	rts

CopyTeamBlockMapData	;IDA: sub_7D314. 93 name. Copy one team's 22 block chars (94; 93 24) from the loaded tile set to vram at d1 by vram dma (DoDMA_nd2), and store their map words at
	;(a1)+. a0 = map data, d0 = team, d1 = vram address
	move.w	(teamblockwidth).w,d3
	asl.w	#2,d3
	mulu.w	d3,d0
	lea	4(a0,d0.w),a0
	lsr.w	#1,d3
	subq.w	#1,d3
.0
	moveq	#$20,d0
	move.w	d1,-(sp)
	move.b	(a0),(a1)
	andi.w	#$F800,(a1)
	lsr.w	#5,d1
	ori.w	#$8000,d1
	or.w	d1,(a1)+
	move.w	(sp)+,d1
	move.w	(a0)+,d2
	andi.w	#$7FF,d2
	add.w	(basetileoffset).w,d2
	move.w	d0,-(sp)
	move.w	(teamblockwidth).w,d0
	asl.w	#2,d0
	add.w	d0,d2
	move.w	(sp)+,d0
	asl.w	#5,d2
	bsr.w	DoDMA_nd2
	addi.w	#$20,d1
	dbf	d3,.0
	rts

DoDMA_nd2	;IDA: sub_7D35E. 93 name. vram to vram copy by dma, protected from vblank
	movem.l	d0-d3/a1,-(sp)
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	lea	(VDP_CTRL).l,a1
	move.w	#$8154,(a1)
	move.w	#$8F01,(a1)
	move.w	#$9300,d3
	move.b	d0,d3
	move.w	d3,(a1)
	move.w	#$9400,d3
	lsr.w	#8,d0
	move.b	d0,d3
	move.w	d3,(a1)
	move.w	#$9500,d3
	move.b	d2,d3
	move.w	d3,(a1)
	move.w	#$9600,d3
	lsr.w	#8,d2
	move.b	d2,d3
	move.w	d3,(a1)
	move.w	#$97C0,(a1)
	clr.l	d0
	move.w	d1,d0
	asl.l	#2,d0
	lsr.w	#2,d0
	swap	d0
	ori.w	#$C0,d0
	move.l	d0,(dmaram).w
	move.w	d0,-(sp)
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	move.w	(dmaram).w,(a1)
	move.w	(dmaram+2).w,(a1)
	bsr.w	WaitDMA
	move.w	#$8164,(a1)
	move.w	#$8F02,(a1)
	move.w	#$E,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,(disflags).w
	movem.l	(sp)+,d0-d3/a1
	rts

GetTeamLogo	;$7D3EA. IDA dc.b. 94 hockey94_07 name. a0 = logo bitmap of team d3 (TeamLogoBitmaps); returns d3 = team * 4
	asl.w	#2,d3
	movea.l	#TeamLogoBitmaps,a0
	movea.l	0(a0,d3.w),a0
	rts

TeamLogoBitmaps	;IDA: unk_7D3F8 (dc.b). Team logo bitmaps by team number (TeamList order)
	dc.l	logoANA,logoBOS,logoBUF,logoCGY,logoCHI,logoDAL,logoDET,logoEDM
	dc.l	logoFLA,logoHFD,logoLA,logoMTL,logoNJ,logoNYI,logoNYR,logoOTW
	dc.l	logoPHI,logoPIT,logoQUE,logoSJ,logoSTL,logoTB,logoTOR,logoVAN
	dc.l	logoWSH,logoWPG,logoASE,logoASW
DrawTeamLogo	;$7D468. IDA dc.b. 94 DrawTeamLogo (optsetup94) body: draw logo a0 (GetTeamLogo, d3 = team * 4) at printx / printy, 6 x 6, palette
	;TeamLogoPalettes + team * 8 - $20 (d5 = 4) or - $40 (d5 = 2), through dobitmap
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	asl.w	#3,d3
	cmp.w	#4,d5
	beq.w	.1
	subi.w	#$20,d3
	bra.w	.2
.1
	subi.w	#$40,d3
.2
	movea.l	#TeamLogoPalettes,a0
	adda.w	d3,a0
	adda.l	(a2)+,a1
	move.w	#6,d3
	move.w	#6,d2
	clr.w	d0
	clr.w	d1
	jmp	(dobitmap).l

ResetClock	;IDA: sub_7D4A0. gameclock = PerTimeTotal = the period length (GetPeriodTime; $258 in overtime unless OptPlayMode), clock stopped
	;(gmclock). Called from StartPer (hockey95)
	bsr.w	GetPeriodTime
	cmpi.w	#3,(gsp).w
	blt.w	.0
	tst.w	(OptPlayMode).w
	bne.w	.0
	move.w	#$258,d0
.0
	move.w	d0,(gameclock).w
	move.w	d0,(PerTimeTotal).w
	bset	#0,(gmode).w
	rts

GetPeriodTime	;IDA: sub_7D4CA. IDA: ClockLength. Return d0 = period length in seconds for the period length option
	move.w	(OptPerlen).w,d0
	asl.w	#1,d0
	lea	.times(pc),a0
	move.w	(a0,d0.w),d0
	rts
.times	;period length in seconds by OptPerlen
	dc.w	$12C,$258,$4B0,$1E

ClrHor	;$7D4E2. IDA dc.b, no xref. 94 ClrHor (penalty94): revert the graphics back to vertical ice rink mode: the rink tiles, LoadHomeTeamGfx
	;and the EASN map at their chars, SprSort, and unless paused clear the screen (eraser). 95 no longer prints the scores here
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#7,(sflags).w
	move.w	#$3E8,(Oldrow).w
	move.w	(rinkvrcset).w,d4
	movea.l	#Rinktilelist+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(LoadHomeTeamGfx).l
	move.w	d4,(EASNcset).w
	jsr	(setupEASNmap).l
	jsr	(SprSort).l
	btst	#sfpz,(sflags).w
	bne.w	.0
	bsr.w	printz
	String	$FF,0,0,0
	moveq	#$20,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

AssignPads	;$7D540. IDA dc.b, no xref. 95 only. Clear c1playernum-c4playernum, then give each pad on a team a player: in Practice Mode
	;(sflags9 bit 7) with its team's goalie control (homegoaliectl / awaygoaliectl) clear, the team's goalie (FindGoalie, setc1player ...),
	;else chgplayer
	move.w	#$FFFF,(c1playernum).w
	move.w	#$FFFF,(c2playernum).w
	move.w	#$FFFF,(c3playernum).w
	move.w	#$FFFF,(c4playernum).w
	tst.w	(cont1team).w
	beq.w	.p2
	btst	#7,(sflags9).w
	beq.w	.c1
	cmpi.w	#1,(cont1team).w
	beq.w	.h1
	tst.w	(awaygoaliectl).w
	bne.w	.c1
	beq.w	.g1
.h1
	tst.w	(homegoaliectl).w
	bne.w	.c1
.g1
	movem.l	d0/a0/a3,-(sp)
	move.w	#5,d0
	cmpi.w	#1,(cont1team).w
	beq.w	.s1
	move.w	#$B,d0
.s1
	jsr	(FindGoalie).l
	clr.w	d4
	jsr	(setc1player).l
	movem.l	(sp)+,d0/a0/a3
	bra.w	.p2
.c1
	clr.w	d4
	jsr	(chgplayer).l
.p2
	tst.w	(cont2team).w
	beq.w	.p3
	btst	#7,(sflags9).w
	beq.w	.c2
	cmpi.w	#2,(cont2team).w
	beq.w	.h2
	tst.w	(homegoaliectl).w
	bne.w	.c2
	bra.w	.g2
.h2
	tst.w	(awaygoaliectl).w
	bne.w	.c2
.g2
	movem.l	d0/a0/a3,-(sp)
	move.w	#$B,d0
	cmpi.w	#2,(cont2team).w
	beq.w	.s2
	move.w	#5,d0
.s2
	jsr	(FindGoalie).l
	move.w	#2,d4
	jsr	(setc2player).l
	movem.l	(sp)+,d0/a0/a3
	bra.w	.p3
.c2
	moveq	#2,d4
	jsr	(chgplayer).l
.p3
	tst.w	(cont3team).w
	beq.w	.p4
	btst	#7,(sflags9).w
	beq.w	.c3
	cmpi.w	#2,(cont3team).w
	beq.w	.h3
	tst.w	(homegoaliectl).w
	bne.w	.c3
	bra.w	.g3
.h3
	tst.w	(awaygoaliectl).w
	bne.w	.c3
.g3
	movem.l	d0/a0/a3,-(sp)
	move.w	#$B,d0
	cmpi.w	#2,(cont3team).w
	beq.w	.s3
	move.w	#5,d0
.s3
	jsr	(FindGoalie).l
	move.w	#4,d4
	jsr	(setc3player).l
	movem.l	(sp)+,d0/a0/a3
	bra.w	.p4
.c3
	moveq	#4,d4
	jsr	(chgplayer).l
.p4
	tst.w	(cont4team).w
	beq.w	.x
	btst	#7,(sflags9).w
	beq.w	.c4
	cmpi.w	#2,(cont4team).w
	beq.w	.h4
	tst.w	(homegoaliectl).w
	bne.w	.c4
	bra.w	.g4
.h4
	tst.w	(awaygoaliectl).w
	bne.w	.c4
.g4
	movem.l	d0/a0/a3,-(sp)
	move.w	#$B,d0
	cmpi.w	#2,(cont4team).w
	beq.w	.s4
	move.w	#5,d0
.s4
	jsr	(FindGoalie).l
	move.w	#6,d4
	jsr	(setc4player).l
	movem.l	(sp)+,d0/a0/a3
	bra.w	.x
.c4
	moveq	#6,d4
	jsr	(chgplayer).l
.x
	rts

SetRinkPalette	;IDA: sub_7D6F0. 95 only. Copy the rink palette (16 longs at the Rinktilelist header) to palfadenew
	movea.l	#Rinktilelist,a0
	adda.l	(a0),a0
	moveq	#$F,d0
	movea.w	#(palfadenew-M68K_RAM),a1
.0
	move.l	(a0)+,(a1)+
	dbf	d0,.0
	rts

waitx	;IDA: sub_7D706. wait d0 frames (negative: until a button) for a button on any pad; waitxpad = the buttons held
	clr.w	(waitxpad).w
	neg.w	d0
	move.w	d0,(vcount).w
.0
	jsr	(ReadJoy1).l
	move.w	d3,(waitxpad).w
	tst.w	d1
	bne.w	.3
	bsr.w	ReadJoy2
	or.w	d3,(waitxpad).w
	tst.w	d1
	bne.w	.3
	tst.w	(FourWayPlay).w
	beq.w	.1
	bsr.w	ReadJoy3
	or.w	d3,(waitxpad).w
	tst.w	d1
	bne.w	.3
	bsr.w	ReadJoy4
	or.w	d3,(waitxpad).w
	tst.w	d1
	bne.w	.3
.1
	move.w	(vcount).w,d0
.2
	cmp.w	(vcount).w,d0
	beq.s	.2
	tst.w	d0
	bmi.s	.0
.3
	rts

GetPeriodTimeRemaining	;IDA: sub_7D762. 93 name. Return d0 = (gsp << 14 | PerTimeTotal) - gameclock
	move.w	(gsp).w,d0
	swap	d0
	clr.w	d0
	lsr.l	#2,d0
	or.w	(PerTimeTotal).w,d0
	sub.w	(gameclock).w,d0
	rts

PrintScores1	;IDA: sub_7D776. 93 printscores1. Draw scoreboard: the period box (Framer 9 x 5 at 0, $17; period name gsp of PerLabels, or name 4
	;of PenShotPenalties2 with gmode2 bit 1) and EASNLogo, then unless sflags3 bit 0 the score box (Framer 8 x 5 at $17, $17) with both team
	;names and scores (PrintTeamNameAndScore). sflags5 bit 7 sets crowdnoisedelay = $78. 95 has no horizontal rink scoreboard
	movem.l	d0-d2/a0-a3,-(sp)
	bclr	#7,(sflags5).w
	beq.w	.0
	move.w	#$78,(crowdnoisedelay).w
.0
	btst	#3,(sflags2).w
	bne.w	.x
	bsr.w	printz
	String	$BF,0,$17,0
	moveq	#9,d0
	moveq	#5,d1
	bsr.w	Framer
	bset	#dfclock,(disflags).w
	bsr.w	printz
	String	$BF,1,$18,0
	move.w	(gsp).w,d0
	movea.l	#PerLabels,a1
	btst	#1,(gmode2).w
	beq.w	.1
	move.w	#4,d0
	movea.l	#PenShotPenalties2,a1
.1
	bsr.w	PrintSmallListItem
	bsr.w	EASNLogo
	btst	#0,(sflags3).w
	bne.w	.x
	bsr.w	printz
	String	$BF,$17,$17,0
	moveq	#8,d0
	moveq	#5,d1
	bsr.w	Framer
	bsr.w	printz
	String	$BF,$18,$1A,0
	movea.w	#(HmShots-M68K_RAM),a2
	bsr.w	PrintTeamNameAndScore
	bsr.w	printz
	String	$BF,$18,$18,0
	adda.w	#tmsize,a2
	bsr.w	PrintTeamNameAndScore
.x
	movem.l	(sp)+,d0-d2/a0-a3
	rts

PrintTeamNameAndScore	;IDA: sub_7D822. 93 name. Print the team name of team a2 at printx/printy, then its score as 2 digits at x $1C. Called twice from PrintScores1
	movea.l	$1E(a2),a1
	adda.w	4(a1),a1
	adda.w	(a1),a1
	bsr.w	print
	move.w	#$1C,(printx).w
	move.w	$C(a2),d0
	moveq	#2,d1
	bsr.w	PushNumberWidth
	bra.w	print

ReAddFramer	;$7D844. IDA dc.b, no xref. 95 only. AddFramer again at framercset
	move.w	(framercset).w,d4
	jmp	(AddFramer).l
ReAddSmallFont	;$7D84E. IDA dc.b, no xref. 95 only. AddSmallFont again at smallfontchars
	move.w	(smallfontchars).w,d4
	jmp	(AddSmallFont).l

AddFonts	;IDA: sub_7D858. 95 only. Load the small font at d4 (smallfontchars, smallfontptr = SmallFontMap2) and the big font after it
	;(BigFontChars, BigFontMap). Called from setupice
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.l	#SmallFontMap2,(smallfontptr).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	rts

chkpk	;$7D884. IDA dc.b, no xref. 94 chkpk: with a power play (sflags2 bit 5) chkpk2, else Z set
	btst	#5,(sflags2).w	;#sf2pwrplay - check if power play in progress
	bne.w	chkpk2
	eori	#4,ccr	;Z flag
	rts

chkpk2	;IDA: sub_7D894. Z set when a3's team is on the power play (sflags2 bit 6 against pfteam)
	movem.l	d0-d1,-(sp)
	btst	#6,(sflags2).w
	move	sr,d0
	btst	#6,pflags(a3)
	move	sr,d1
	eor.w	d1,d0
	move	d0,ccr
	movem.l	(sp)+,d0-d1
	rts

CheckNewCarrier	;IDA: sub_7D8B2. 95 only: clear GameFlags bits 0-1 when puckc changes (lastpuckc)
	move.w	(lastpuckc).w,d0
	cmp.w	(puckc).w,d0
	beq.w	.0
	bclr	#0,(GameFlags).w
	bclr	#1,(GameFlags).w
.0
	move.w	(puckc).w,(lastpuckc).w
	rts

printbigz	;IDA: sub_7D8D2. 93 name. String macro follows the call
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printbig
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printbigz2	;$7D8E4. IDA dc.b, no xref. 95 only. printbigz with the third big font (printbig2). String macro follows the call
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printbig2
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printbigz1	;IDA: sub_7D8F6. 95 only. printbigz with BigFontMap (printbig1)
	move.l	a1,-(sp)
	movea.l	4(sp),a1
	bsr.w	printbig1
	move.l	a1,4(sp)
	movea.l	(sp)+,a1
	rts

printbig1	;IDA: sub_7D908. 95 only. printbig with BigFontMap (the AddFonts big font)
	move.l	#BigFontMap,(bigfontptr).l
	bra.w	printbigtext

printbig	;IDA: sub_7D916. print String a1 with the big font at printx / printy. 95: BigFontMap2 (bigfontptr)
	move.l	#BigFontMap2,(bigfontptr).l
	bra.w	printbigtext

printbig2	;$7D924. IDA dc.b. 95 only. printbig with BigFontMap3. Falls into printbigtext
	move.l	#BigFontMap3,(bigfontptr).l

printbigtext	;IDA: loc_7D92E. the 94 printbig body, with the font map at bigfontptr. Lower case is printed as upper case
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	movem.l	d0-d7/a0/a2,-(sp)
	move.w	(printx).w,d4
	move.w	(printy).w,d5
	move.w	(printa).w,d6
	add.w	(BigFontChars).w,d6
	move.w	(a1)+,d3
	subq.w	#2,d3
	bra.w	.3
.0
	move.b	(a1)+,d0
	beq.w	.3
	ext.w	d0
	bpl.w	.1
	neg.w	d0
	move.w	d0,d6
	asl.w	#8,d6
	asl.w	#1,d6
	andi.w	#$F800,d6
	move.w	d6,(printa).w
	add.w	(BigFontChars).w,d6
	andi.w	#3,d0
	asl.w	#2,d0
	subq.w	#4,d0
	move.w	d0,(printm).w
	move.b	(a1)+,d4
	ext.w	d4
	move.w	d4,(printx).w
	move.b	(a1)+,d5
	ext.w	d5
	move.w	d5,(printy).w
	subq.w	#2,d3
	bra.w	.3
.1
	cmp.b	#$61,d0
	blt.w	.2
	cmp.b	#$7A,d0
	bgt.w	.2
	addi.b	#-$20,d0
.2
	move.w	d3,-(sp)
	bsr.w	PrintBigChar
	move.w	(sp)+,d3
.3
	dbf	d3,.0
	move.w	d4,(printx).w
	move.w	d5,(printy).w
	movem.l	(sp)+,d0-d7/a0/a2
	move.w	(sp)+,(disflags).w
	rts

PrintBigChar	;IDA: sub_7D9C8. Draw big font char d0 (bfasciicon) at d4 / d5: one or two columns of two tiles (PutBigTile)
	subi.w	#$20,d0
	movea.l	#bfasciicon,a0
	moveq	#1,d2
	move.b	(a0,d0.w),d1
	ext.w	d1
	bpl.w	.0
	neg.w	d1
	clr.w	d2
.0
	asl.w	#1,d1
	movea.l	(bigfontptr).w,a0
	adda.l	4(a0),a0
.1
	move.w	4(a0,d1.w),d3
	bsr.w	PutBigTile
	move.w	(a0),d7
	asl.w	#1,d7
	add.w	d7,d1
	move.w	4(a0,d1.w),d3
	sub.w	d7,d1
	addq.w	#1,d5
	bsr.w	PutBigTile
	subq.w	#1,d5
	addq.w	#1,d4
	addq.w	#2,d1
	dbf	d2,.1
	rts

PutBigTile	;IDA: sub_7DA12. Write tile d3 + d6 at column d4, row d5 of the map at VmMap1 + printm
	add.w	d6,d3
	movem.l	d1/a0,-(sp)
	move.w	d5,d0
	movea.l	#VmMap1,a0
	adda.w	(printm).w,a0
	move.w	2(a0),d1
	asl.w	d1,d0
	add.w	d4,d0
	asl.w	#1,d0
	add.w	(a0),d0
	bsr.w	Vmaddr
	move.w	d3,(a0)
	movem.l	(sp)+,d1/a0
	rts

bfasciicon	;IDA: unk_7DA3C (dc.b). Char definitions for the big font, indexed by ascii - $20 (PrintBigChar); negative = one tile wide
	dc.b	$B4,$B7,$00,$00,$00,$00,$00,$B9,$00,$00,$00,$00,$00,$00,$B8,$00
	dc.b	$33,$35,$37,$39,$3B,$3D,$3F,$41,$43,$45,$B9,$00,$00,$00,$00,$4A
	dc.b	$4A,$00,$02,$04,$06,$08,$0A,$0C,$0E,$F0,$11,$13,$15,$17,$19,$1B
	dc.b	$1D,$1F,$21,$23,$25,$27,$29,$2B,$2D,$2F,$31,$FF

UnpackPicture	;IDA: sub_7DA78. 94 only. Unpack a picture a2: count.w, then 3 bytes per row of 8 pixels to 4 bit pixels + 5 at picturebuf (count first). Called from DrawPictureBox
	;(high94_2), DrawMatchupPicture (hockey94_07) and PlayerCardScreen (hockey94_08)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#picturebuf,a0
	movea.l	#picturebits,a1
	move.w	(a2)+,d0
	move.w	d0,(a0)+
	asl.w	#3,d0
	subq.w	#1,d0
.0
	clr.l	(a0)
	clr.l	(a1)
	move.b	(a2)+,(a1)
	move.b	(a2)+,1(a1)
	move.b	(a2)+,2(a1)
	move.l	#0,-(sp)
	move.l	(a1),d2
	andi.l	#$E0000000,d2
	lsr.l	#1,d2
	addi.l	#$50000000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$1C000000,d2
	lsr.l	#2,d2
	addi.l	#$5000000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$3800000,d2
	lsr.l	#3,d2
	addi.l	#$500000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$700000,d2
	lsr.l	#4,d2
	addi.l	#$50000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$E0000,d2
	lsr.l	#5,d2
	addi.l	#$5000,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$1C000,d2
	lsr.l	#6,d2
	addi.l	#$500,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$3800,d2
	lsr.l	#7,d2
	addi.l	#$50,d2
	or.l	d2,(sp)
	move.l	(a1),d2
	andi.l	#$700,d2
	move.w	#8,d5
	lsr.l	d5,d2
	addq.l	#5,d2
	or.l	d2,(sp)
	move.l	(sp)+,(a0)+
	dbf	d0,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

UpdateLineChange	;IDA: sub_7DB40. 94 name (periodicevents, once a second). Unless OptLine: bench players (tmpdst -2) of both teams get 9 energy, up to $1000 (.team)
	tst.w	(OptLine).w
	bne.w	.3
	movea.w	#(HmShots-M68K_RAM),a2
	bsr.w	.0
	lea	$366(a2),a2
.0
	moveq	#$32,d0
.1
	cmpi.w	#$FFFE,$68(a2,d0.w)
	bne.w	.2
	addi.w	#9,$34(a2,d0.w)
	cmpi.w	#$1000,$34(a2,d0.w)
	blt.w	.2
	move.w	#$1000,$34(a2,d0.w)
.2
	subq.w	#2,d0
	bpl.s	.1
.3
	rts

RestoreTeamEnergy	;$7DB7C. IDA dc.b, no xref. 94 only. a2 = team: max energy (tmpde $1000) for every player. The skip needs tmpdst to be both -3 and
	;-4, so it never happens
	moveq	#$32,d0	;(MaxRos-1)*2
.loop
	cmpi.w	#$FFFD,tmpdst(a2,d0.w)
	bne.w	.0
	cmpi.w	#$FFFC,tmpdst(a2,d0.w)
	bne.w	.0
	bra.w	.1
.0
	move.w	#$1000,tmpde(a2,d0.w)
.1
	subq.w	#2,d0
	bpl.s	.loop
	rts

ResetTeamEnergy	;IDA: sub_7DBA2. 95 only. a2 = team: full energy for every player not injured for the game (tmpdst -4); period injuries (-3) go back to the bench (-2)
	moveq	#$32,d0
.0
	cmpi.w	#$FFFC,$68(a2,d0.w)
	beq.w	.1
	move.w	#$1000,$34(a2,d0.w)
	cmpi.w	#$FFFD,$68(a2,d0.w)
	bne.w	.1
	move.w	#$FFFE,$68(a2,d0.w)
.1
	subq.w	#2,d0
	bpl.s	.0
	rts

setpde	;IDA: sub_7DBCA. d1 = rostnum of player * 2, a2 = team struct, d0 = new energy level (0 if negative)
	tst.w	d0
	bpl.w	.0
	clr.w	d0
.0
	move.w	d0,$34(a2,d1.w)
	rts

SeasonPlayerOut	;IDA: sub_7DBD8. 95 only. Unless sflags11 bit 6: Z set when player d0 of team d7 is out in the season data (save RAM $203698, low 5 bits $1E)
	btst	#6,(sflags11).w
	bne.w	.0
	movem.l	d0/d7-a0,-(sp)
	asl.w	#2,d0
	ext.l	d0
	movea.l	#$203698,a0
	mulu.w	#$38,d7
	add.l	d7,d7
	add.l	d0,d7
	move.w	(a0,d7.l),d0
	andi.w	#$1F,d0
	cmp.w	#$1E,d0
	movem.l	(sp)+,d0/d7-a0
.0
	rts

WeightedRandomSelect	;IDA: loc_7DC0A. 93 name. d0 = number of word weights at nibblebuffer: return a weighted random index
	movem.l	d1/a1,-(sp)
	movea.w	#(nibblebuffer-M68K_RAM),a1
	clr.w	d1
	bra.w	.1
.0
	add.w	(a1)+,d1
.1
	dbf	d0,.0
	move.w	d1,d0
	bsr.w	randomd0
.2
	sub.w	-(a1),d0
	bpl.s	.2
	suba.w	#$CC24,a1
	move.w	a1,d0
	lsr.w	#1,d0
	movem.l	(sp)+,d1/a1
	rts

AppendTeamName	;$7DC36. IDA dc.b. 94 only. Append the city name of team d0 (TeamList block Strings) to a1 (appstring)
	movem.l	d0/a0-a3,-(sp)
	ext.w	d0
	asl.w	#2,d0
	movea.l	#TeamList,a0
	movea.l	0(a0,d0.w),a0
	move.w	4(a0),d0
	ext.l	d0
	adda.l	d0,a0
	adda.w	(a0),a0
	movea.l	a1,a3
	movea.l	a0,a1
	jsr	(appstring).l
	movem.l	(sp)+,d0/a0-a3
	rts
StartText	;$7DC62. IDA dc.b. 94 only. Copy String a1 (length word first) to a3
	movem.l	d0,-(sp)
	move.w	(a1),d0
	subq.w	#1,d0
.loop
	move.b	(a1)+,(a3)+
	dbf	d0,.loop
	movem.l	(sp)+,d0
	rts
AppendUserName	;$7DC76. IDA dc.b. 94 only. Append user name d2 (12 bytes of the name log at namelog, spaces for 0) to a1, or NoNameTxt when d2 is 0;
	;trailing spaces trimmed (TrimSpaces)
	movem.l	d0-d3/a0-a3,-(sp)
	movea.l	a1,a2
	tst.w	d2
	beq.w	.2
	move.w	#$B,d0
	clr.w	d3
	movea.l	#namelog,a0
	mulu.w	#$C,d2
	adda.l	d2,a0
.loop
	move.b	0(a0,d3.w),d1
	bne.w	.0
	move.b	#$20,d1
.0
	move.b	d1,2(a1)
	tst.b	(a1)+
	addq.w	#1,d3
	dbf	d0,.loop
	move.w	#$E,(a2)
	btst	#7,(sflags6).w
	beq.w	.1
	bsr.w	TrimSpaces
.1
	bra.w	.x
.2
	movea.l	a1,a3
	move.l	a3,-(sp)
	movea.l	#NoNameTxt,a1
	jsr	(StartText).l
	movea.l	(sp)+,a2
	bsr.w	TrimSpaces
.x
	movem.l	(sp)+,d0-d3/a0-a3
	rts
NoNameTxt	;$7DCDE. An empty String (94 NoNameTxt)
	dc.w	2
TrimSpaces	;$7DCE0. IDA dc.b. 94 only. Trim the trailing spaces of String a2 and pad it to an even length
	movem.l	a3,-(sp)
	movea.l	a2,a3
	adda.w	(a2),a3
.loop
	move.b	-(a3),d0
	cmp.b	#$20,d0
	bne.w	.0
	move.b	#0,(a3)
	subq.w	#1,(a2)
	bra.s	.loop
.0
	addq.w	#1,(a2)
	andi.w	#$FE,(a2)
	movem.l	(sp)+,a3
	rts

setupice	;IDA: sub_7DD06. set all variables, send non purgeable graphics, build sprite frame lists for ice rink (94 setup94 setupice). 95 has no reverse rink tiles, loads AddFramer2 and
	;AddFonts, and clears c3playernum / c4playernum too
	movem.l	d0-d7/a0-a6,-(sp)
	bset	#1,(disflags).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$DC00,(VSPRITES).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$FC00,(VSCRLPM).w
	moveq	#0,d0
	jsr	(setvram).l
	bclr	#0,(sflags).w
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	clr.w	(Hpos).w
	clr.w	(Vpos).w
	move.w	#$7D0,(Oldrow).w
	st	(zamx).w
	move.w	#$800,d0
	move.w	(VmMap1).w,d1
	move.w	#$7FF,d2
	jsr	(DoFill).l
	clr.w	d4
	move.w	d4,(rinkvrcset).w
	movea.l	#Rinktilelist+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(LoadHomeTeamGfx).l
	move.w	d4,(EASNcset).w
	jsr	(setupEASNmap).l
	move.w	d4,(energybarchars).w
	movea.l	#EnergyBarMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(gamesetuptilesetindex).w
	movea.l	#CrowdFrameList+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(spritechars).w
	jsr	(defaultsprites).l
	jsr	(SetRinkPalette).l
	move.w	d4,(framerchars).w
	jsr	(AddFramer2).l
	jsr	(AddFonts).l
	move.w	d4,(ExtraChars).w
	btst	#1,(gmode).w
	beq.w	.1
	movea.w	#(SortCords-M68K_RAM),a3
	moveq	#$B,d0
.0
	bchg	#7,pflags(a3)
	adda.w	#$80,a3
	dbf	d0,.0
.1
	jsr	(setplayercolors).l
	move.l	#$FFFFFFFF,(PadControlBits).w
	clr.l	(padcont).w
	clr.l	(padcont+4).w
	clr.l	(padcont+8).w
	st	(c1playernum).w
	st	(c2playernum).w
	st	(c3playernum).w
	st	(c4playernum).w
	movea.w	#(DMAList-M68K_RAM),a5
	movea.w	#(Satt-M68K_RAM),a6
	moveq	#1,d6
	movea.w	#(pads-M68K_RAM),a3
	clr.w	d0
	clr.w	d1
	jsr	(addframe2).l
	adda.w	#$1C,a3
	jsr	(addframe2).l
	adda.w	#$1C,a3
	jsr	(addframe2).l
	adda.w	#$1C,a3
	jsr	(addframe2).l
	adda.w	#$1C,a3
	jsr	(addframe2).l
	adda.w	#$1C,a3
	jsr	(addframe2).l
	move.l	a5,(DMAlistend).w
	jsr	(DoDMAlist).l
	move.w	(sp)+,(disflags).w
	move.l	#VBlank,(vbint).w
	bclr	#0,(disflags).w
	bclr	#2,(disflags).w
	move	#$2300,sr
	movem.l	(sp)+,d0-d7/a0-a6
	rts