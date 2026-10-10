;	NHL 95 cards95_01. Retail $09ACE6-$09B6F3 (2574 bytes).
;	Mapped to cards94 (81%): NameEntryScreen, NameLetterGrid, NameEntryHelp, PrintNamePrompt, SyncLetterCursor, FindLetter,
;	PrintNameCursor, PrintCurLetter, LetterGridPos, EnterNameTxt / SelectNameTxt, PrintNameLog, MoveLogArrows, PrintLogArrows,
;	GetNameLength, PrintNameField, LetterGrid, GetLogName, StoreUserName and WriteNameRecord (the user records name entry).
;	The segment map ended this file at $09B72F, inside records94 UserNameEntry ($09B6F4); records95 starts at $09B6F4.
;	IDA hid printz / printz2 / printbigz Strings as instructions; they are written from the retail bytes.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

NameEntryScreen	;IDA: sub_9ACE6. Name Entry screen: draw team logo, NAME ENTRY title and Name Log, then edit the name with the pad (cards94 NameEntryScreen)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a5,-(sp)
	bset	#1,(BA_PS_flags).w
	jsr	(CreateRatingsGfx).l
	move.w	d4,(homepicchars).w
	addi.w	#$24,d4
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(spritechars).w
	movea.l	#NameEntryBgMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	jsr	(printz).l
	String	$8F,$1B,$8,$0
	move.w	(HomeTeam).w,d3
	tst.w	(nameentryvis).w
	beq.w	.0
	move.w	(VisTeam).w,d3
.0
	asl.w	#2,d3
	movea.l	#TeamLogoBitmaps,a0
	movea.l	(a0,d3.w),a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	asl.w	#3,d3
	movea.l	#TeamLogoPalettes,a0
	subi.w	#$40,d3
	adda.w	d3,a0
	adda.l	(a2)+,a1
	move.w	#6,d3
	move.w	#6,d2
	clr.w	d0
	clr.w	d1
	move.w	#4,d5
	move.w	(homepicchars).w,d4
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$BF,$1E,$6,$0
	move.w	(HomeTeam).w,d0
	tst.w	(nameentryvis).w
	beq.w	.1
	move.w	(VisTeam).w,d0
.1
	movea.l	#TeamList,a1
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	adda.w	4(a1),a1
	move.w	(a1),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jsr	(printsmall).l
	jsr	(printbigz).l
	String	$BF,$A,$2,'NAME   ENTRY',$0
	movea.l	(sp)+,a5
	bsr.w	ReadNameLog
	clr.w	(CreateListOldRow).w
	move.w	#1,(CreateListRow).w
	clr.w	d0
	bsr.w	NameInUse
	movea.l	#NameEntryBuf,a1
	bsr.w	GetLogName
	bsr.w	PrintNameLog
	jsr	(printz).l
	String	$BF,$C,$6,'Name Log',$0
	clr.w	d4
	bsr.w	SyncLetterCursor
	bsr.w	PrintNameCursor
	bsr.w	LetterGridPos
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(NameEntryFramer).l
.2
	move.w	(sp)+,(printy).w
	addq.w	#1,(printy).w
	move.w	(sp)+,(printx).w
	addq.w	#1,(printx).w
	bsr.w	PrintCurLetter
	move.w	#1,(NameEntryMode).w
	bsr.w	NameLetterGrid
	clr.w	d0
	bra.w	.18
.3
	bsr.w	GetNameLength
	jsr	(printz).l
	String	$BF,$A,$7,$0
	move.w	(CreateListRow).w,d0
	add.w	d0,(printy).w
	tst.w	(NameEntryMode).w
	beq.w	.4
	movea.l	#NameEntryBuf,a1
	bsr.w	PrintNameField
	bsr.w	PrintNamePrompt
.4
	bsr.w	MoveLogArrows
.5
	move.w	(vcount).w,d0
.6
	cmp.w	(vcount).w,d0
	beq.s	.6
	cmpa.l	#$FFFFCC42,a5
	beq.w	.9
	cmpa.l	#$FFFFCC44,a5
	beq.w	.8
	cmpa.l	#$FFFFCC46,a5
	beq.w	.7
	jsr	(ReadJoy4).l
	tst.w	d1
	beq.s	.5
	bra.w	.10
.7
	jsr	(ReadJoy3).l
	tst.w	d1
	beq.s	.5
	bra.w	.10
.8
	jsr	(ReadJoy2).l
	tst.w	d1
	beq.s	.5
	bra.w	.10
.9
	jsr	(ReadJoy1).l
	tst.w	d1
	beq.s	.5
.10
	btst	#7,d1
	bne.w	NameEntryExit
	tst.w	(NameEntryMode).w
	bne.w	.11
	move.w	#1,d0
	btst	#1,d1
	bne.w	.13
	move.w	#$FFFF,d0
	btst	#0,d1
	bne.w	.13
	btst	#4,d1
	beq.w	.3
	bsr.w	NameLetterGrid
	clr.w	d0
	bra.w	.13
.11
	moveq	#$FFFFFFFF,d0
	btst	#6,d1
	bne.w	.18
	neg.w	d0
	btst	#5,d1
	bne.w	.18
	btst	#3,d1
	bne.w	.19
	neg.w	d0
	btst	#2,d1
	bne.w	.19
	moveq	#6,d0
	btst	#1,d1
	bne.w	.19
	neg.w	d0
	btst	#0,d1
	bne.w	.19
	btst	#4,d1
	beq.w	.3
	bsr.w	NameLetterGrid
	tst.w	(NameEntryMode).w
	bne.w	.12
	bsr.w	PrintNameLog
.12
	bra.w	.3
.13
	add.w	d0,(CreateListRow).w
.14
	cmpi.w	#7,(CreateListRow).w
	ble.w	.15
	move.w	#1,(CreateListRow).w
.15
	tst.w	(CreateListRow).w
	bne.w	.16
	move.w	#7,(CreateListRow).w
.16
	bsr.w	NameInUse
	beq.s	.14
	movea.l	#NameEntryBuf,a1
	bsr.w	GetLogName
	tst.w	(NameEntryMode).w
	bne.w	.17
	jsr	(NameEntryHelp).l
	bra.w	.3
.17
	jsr	(printz).l
	String	$BF,$4,$13,$0
	add.w	d4,(printx).w
	jsr	(printz).l
	String	'   ',$0
	bsr.w	LetterGridPos
	moveq	#1,d2
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
	addq.w	#1,(printy).w
	move.w	(sp)+,(printx).w
	addq.w	#1,(printx).w
	bsr.w	PrintCurLetter
	bsr.w	SyncLetterCursor
	move.w	d4,d0
	neg.w	d0
	bra.w	.18
.18
	add.w	d4,d0
	cmp.w	#$B,d0
	bhi.w	.3
	move.w	d0,d4
	bsr.w	PrintNameCursor
	movea.l	#NameEntryBuf,a0
	clr.w	d0
	cmpi.b	#$2D,(a0,d4.w)
	beq.w	.19
	move.b	(a0,d4.w),d0
	ext.w	d0
	bsr.w	FindLetter
	sub.w	d5,d0
.19
	add.w	d5,d0
	cmp.w	#$1D,d0
	bhi.w	.3
	move.w	d0,-(sp)
	bsr.w	LetterGridPos
	moveq	#1,d2
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
	addq.w	#1,(printy).w
	move.w	(sp)+,(printx).w
	addq.w	#1,(printx).w
	bsr.w	PrintCurLetter
	move.w	(sp)+,d5
	bsr.w	LetterGridPos
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	tst.w	(NameEntryMode).w
	beq.w	.20
	jsr	(NameEntryFramer).l
.20
	move.w	(sp)+,(printy).w
	addq.w	#1,(printy).w
	move.w	(sp)+,(printx).w
	addq.w	#1,(printx).w
	bsr.w	PrintCurLetter
	movea.l	#NameEntryBuf,a0
	movea.l	#LetterGrid,a1
	move.b	(a1,d5.w),d0
	move.b	d0,(a0,d4.w)
	bra.w	.3

NameEntryExit	;IDA: loc_9B0AC. NameEntryScreen exit (restore and return)
	bsr.w	StoreUserName
	movem.l	(sp)+,d0-d7/a0-a6
	rts

NameLetterGrid	;IDA: sub_9B0B6. Name entry: letter grid and its key help (cards94 NameLetterGrid); on the second call the name log help (NameEntryHelp)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$18,$12,$0
	move.w	#$16,d0
	move.w	#7,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	bchg	#0,(NameEntryMode+1).w
	bne.w	.3
	jsr	(printz).l
	String	$BF,$A,$11,$0
	movea.l	#LetterGrid,a0
	moveq	#4,d0
.0
	moveq	#5,d1
	movea.l	#mesarea,a1
	move.w	#$E,(a1)+
.1
	move.b	(a0)+,(a1)+
	move.b	#$20,(a1)+
	dbf	d1,.1
	movea.w	#(mesarea-M68K_RAM),a1
	jsr	(printsmall).l
	addq.w	#2,(printy).w
	subi.w	#$C,(printx).w
	dbf	d0,.0
	jsr	(ClearNameHelp).l
	jsr	(printz).l
	String	$BF,$18,$11,$0
	jsr	(printz2).l
	dc.w	$44;String length
	dc.b	'{}[]',$FA,$1,$FD,$18,'=Select letter',$FA,$2
	dc.b	$FD,$18,'C=Enter letter',$FA,$2,$FD,$18,'A=Go back'
	dc.b	$FA,$2,$FD,$18,'B=Cancel',$0
.2
	movem.l	(sp)+,d0-d7/a0-a6
	rts
.3
	movea.l	#NameEntryBuf,a1
	bsr.w	GetLogName
	move.w	#0,(printx).w
	move.w	#$F,(printy).w
	move.w	#$28,d0
	move.w	#$D,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
.4
	jsr	(printz).l
	String	$FE,$18,$12,$0
	moveq	#$16,d0
	moveq	#7,d1
	bsr.w	NameEntryHelp
	bra.s	.2

NameEntryHelp	;IDA: sub_9B1C4. Name entry: name log key help text (cards94 NameEntryHelp)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ClearNameHelp).l
	jsr	(printz).l
	String	$BF,$18,$11,$0
	jsr	(printz2).l
	dc.w	$42;String length
	dc.b	'{}=Select',$FA,$1,$FD,$1B,'name',$FA,$2
	dc.b	$FD,$19,'B=Enter/edit',$FA,$1,$FD,$1B,'name'
	dc.b	$FA,$2,$FD,$19,'START',$FA,$1,$FD
	dc.b	$1A,'=Use name',$0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintNamePrompt	;IDA: sub_9B228. Name entry: print "Enter new name." for an empty name log slot word_FFD0F6, else "Select or replace." (cards94 PrintNamePrompt)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(CreateListRow).w,d0
	mulu.w	#$C,d0
	movea.l	#namelog,a0
	movea.l	#EnterNameTxt,a1
	tst.b	(a0,d0.w)
	beq.w	.1
.0
	movea.l	#SelectNameTxt,a1
.1
	jsr	(print).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SyncLetterCursor	;IDA: sub_9B25A. Name entry: grid cursor d5 = grid index of the current letter (sub_9B288), 0 if not in the grid (cards94 SyncLetterCursor)
	movem.l	d0-d4/a0-a6,-(sp)
	move.b	(NameEntryBuf).w,d0
	bsr.w	FindLetter
	cmp.w	#$1E,d0
	blt.w	.1
	clr.w	d5
.0
	bra.w	.2
.1
	move.w	d0,d5
	movea.l	#LetterGrid,a0
	move.b	(a0,d5.w),(NameEntryBuf).w
.2
	movem.l	(sp)+,d0-d4/a0-a6
	rts

FindLetter	;IDA: sub_9B288. d0 = index of letter d0 in the letter grid, $1E when not found (cards94 FindLetter)
	movem.l	d1-d3/a0-a6,-(sp)
	movea.l	#LetterGrid,a0
	move.b	d0,d1
	clr.w	d0
	move.w	#$1E,d3
.0
	cmp.b	(a0,d0.w),d1
	beq.w	.1
	addq.w	#1,d0
	dbf	d3,.0
	move.w	#$1E,d0
.1
	movem.l	(sp)+,d1-d3/a0-a6
	rts

PrintNameCursor	;IDA: sub_9B2B2. Name entry: position the name cursor (95 prints no " < "; cards94 PrintNameCursor)
	jsr	(printz).l
	String	$BF,5,$12,$0
	add.w	d4,(printx).w
	tst.w	(NameEntryMode).w
	beq.w	rtsNameCursor

rtsNameCursor	;IDA: locret_9B2CA. Shared rts of sub_9B2B2 (cards94 rtsNameCursor)
	rts

PrintCurLetter	;IDA: sub_9B2CC. Name entry: print grid letter d5 when the cursor is on (cards94 PrintCurLetter)
	tst.w	(NameEntryMode).w
	beq.s	rtsNameCursor
	movea.l	#ThreeStars,a1
	move.w	#4,(a1)
	move.b	#0,3(a1)
	movea.l	#LetterGrid,a0
	move.b	(a0,d5.w),d0
	move.b	d0,2(a1)
	jmp	(printsmall).l

LetterGridPos	;IDA: sub_9B2F6. Name entry: printx/printy of grid letter d5 (6 a row, 2 cells apart), d0/d1 = 3x3 box (cards94 LetterGridPos)
	jsr	(printz).l
	String	$BF,9,$10,$0
	move.w	d5,d0
	ext.l	d0
	divu.w	#6,d0
	asl.w	#1,d0
	add.w	d0,(printy).w
	swap	d0
	asl.w	#1,d0
	add.w	d0,(printx).w
	moveq	#3,d0
	moveq	#3,d1
	rts

EnterNameTxt	;IDA: unk_9B31E. Name entry prompt for an empty name log slot (cards94 EnterNameTxt)
	String	$BF,6,$F,'  Enter new name. ',$0

SelectNameTxt	;IDA: unk_9B336. Name entry prompt for a used name log slot (cards94 SelectNameTxt)
	String	$BF,6,$F,'Select or replace.',$0

PrintNameLog	;IDA: sub_9B34E. Name entry: print the 7-row name log list (cards94 PrintNameLog)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(NameEntryLen).w,-(sp)
	move.w	(CreateListRow).w,-(sp)
	jsr	(printz).l
	String	$BF,$A,8,$0
	move.w	#6,d7
	move.w	#1,(CreateListRow).w
	movea.l	#linemarkbuf,a1
.0
	bsr.w	GetLogName
	move.w	(printx).w,-(sp)
	bsr.w	PrintNameField
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
	addq.w	#1,(CreateListRow).w
	dbf	d7,.0
	move.w	(sp)+,(CreateListRow).w
	move.w	(sp)+,(NameEntryLen).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

MoveLogArrows	;IDA: sub_9B3A0. Name entry: move the ] [ arrows when the name log selection changed (cards94 MoveLogArrows)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(CreateListRow).w,d0
	cmp.w	(CreateListOldRow).w,d0
	beq.w	.0
	movea.l	#LogArrowsClrTxt,a1
	bsr.w	PrintLogArrows
	movea.l	#LogArrowsTxt,a1
	bsr.w	PrintLogArrows
.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintLogArrows	;IDA: sub_9B3CA. Name entry: print the two arrow Strings at a1 on name log row word_FFD0F8, then word_FFD0F8 = selection (cards94 PrintLogArrows)
	tst.w	(CreateListOldRow).w
	beq.w	.0
	jsr	(printz).l
	String	$BF,8,8,$0
	move.w	(CreateListOldRow).w,d0
	subq.w	#1,d0
	add.w	d0,(printy).w
	move.l	a1,-(sp)
	jsr	(printsmall).l
	movea.l	(sp)+,a1
	adda.w	(a1),a1
	move.w	#$17,(printx).w
	jsr	(printsmall).l
.0
	move.w	(CreateListRow).w,(CreateListOldRow).w
	rts

LogArrowsTxt	;IDA: unk_9B408. Name log arrows "]" and "[" (cards94 LogArrowsTxt)
	String	']',$0
	String	'[',$0

LogArrowsClrTxt	;IDA: unk_9B410. Blanks that erase the name log arrows (cards94 LogArrowsClrTxt)
	String	' ',$0
	String	' ',$0

GetNameLength	;IDA: sub_9B418. Name entry: word_FFD0F4 = length of the name in the entry buffer (cards94 GetNameLength)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$B,d3
	movea.l	#NameEntryBuf,a0
	clr.w	(NameEntryLen).w
.0
	cmpi.b	#$2D,(a0)
	beq.w	.1
	tst.b	(a0)+
	beq.w	.1
	addq.w	#1,(NameEntryLen).w
	dbf	d3,.0
.1
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintNameField	;IDA: sub_9B446. Name entry: print the 12-char name field at a1 ("-" pads) and the current letter when the cursor is on (cards94 PrintNameField)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#ThreeStars,a0
	move.w	(NameEntryLen).w,d0
	move.w	#0,d3
	move.w	#$E,(a0)+
.0
	move.b	(a1,d3.w),d1
	cmp.w	(NameEntryLen).w,d3
	blt.w	.1
	move.b	#$2D,d1
.1
	move.b	d1,(a0)+
	addq.w	#1,d3
	cmp.w	#$C,d3
	blt.s	.0
	movea.l	#ThreeStars,a1
	move.w	(printx).w,-(sp)
	jsr	(printsmall).l
	move.w	(sp)+,(printx).w
	add.w	d4,(printx).w
	tst.w	(NameEntryMode).w
	beq.w	.3
	movem.l	a0-a1,-(sp)
	movea.l	#NameEntryBuf,a0
	movea.l	#M68K_RAM,a1
	move.w	#4,(a1)
	move.b	(a0,d4.w),2(a1)
	move.b	#0,3(a1)
	jsr	(printz2).l
	String	$F9,1
	cmpi.b	#$20,2(a1)
	bne.w	.2
	jsr	(printz2).l
	String	$F9,3
.2
	jsr	(printsmall).l
	jsr	(printz2).l
	String	$F9,0
	movem.l	(sp)+,a0-a1
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

LetterGrid	;IDA: unk_9B4EE. Name entry letter grid, 5 rows of 6, $FF end (cards94 LetterGrid)
	dc.b	'ABCDEFGHIJKLMNOPQRSTUVWXYZ.12  ',$FF

GetLogName	;IDA: sub_9B50E. Copy name log entry word_FFD0F6 to a1 ("-" for blanks), word_FFD0F4 = its length (cards94 GetLogName)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#namelog,a0
	move.w	(CreateListRow).w,d2
	mulu.w	#$C,d2
	move.w	#0,(NameEntryLen).w
	move.w	#$B,d3
.0
	move.b	(a0,d2.w),d0
	beq.w	.1
	bra.w	.2
.1
	move.b	#$2D,d0
	subq.w	#1,(NameEntryLen).w
.2
	move.b	d0,(a1)+
	addq.w	#1,(NameEntryLen).w
	addq.w	#1,d2
	dbf	d3,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

StoreUserName	;IDA: sub_9B550. Name entry: store the edited name in the name log slot; if changed, save and clear its old records (cards94 StoreUserName)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	a5,-(sp)
	movea.l	#namelog,a0
	move.w	(CreateListRow).w,d0
	mulu.w	#$C,d0
	adda.w	d0,a0
	movea.l	#NameEntryBuf,a1
	move.w	#$B,d4
.0
	cmpi.b	#$2D,(a1)
	bne.w	.1
	move.b	#0,(a1)
.1
	move.b	(a1)+,d1
	cmp.b	(a0)+,d1
	bne.w	.2
	dbf	d4,.0
	bra.w	.5
.2
	movea.l	#namelog,a0
	move.w	(CreateListRow).w,d0
	mulu.w	#$C,d0
	adda.w	d0,a0
	movea.l	#NameEntryBuf,a1
	move.w	#$B,d4
.3
	move.b	(a1)+,d1
	cmp.b	#$2D,d1
	bne.w	.4
	move.b	#0,d1
.4
	move.b	d1,(a0)+
	dbf	d4,.3
	bsr.w	WriteNameLog
	jsr	(WriteNameRecord).l
	jsr	(MakeSRAMChecksum).l
.5
	movea.l	(sp)+,a5
	tst.b	(NameEntryBuf).w
	bne.w	.6
	clr.w	(CreateListRow).w
.6
	move.w	(CreateListRow).w,(a5)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

WriteNameRecord	;IDA: sub_9B5E2. Clear name slot word_FFD0F6 from every saved record (read sub_9952, write sub_98E6), zero its 16-byte entry at $D22, then sub_9908 (cards94 WriteNameRecord)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$2D7,d7
	moveq	#2,d0
	moveq	#4,d1
	movea.l	#ThreeStars,a0
	move.w	(CreateListRow).w,d6
.0
	clr.w	d5
	jsr	(ReadSRAM).l
	cmp.b	1(a0),d6
	bne.w	.1
	clr.b	1(a0)
	st	d5
.1
	cmp.b	3(a0),d6
	bne.w	.2
	clr.b	3(a0)
	st	d5
.2
	tst.w	d5
	beq.w	.3
	jsr	(WriteSRAM).l
.3
	addq.l	#4,d0
	dbf	d7,.0
	move.w	#$1B,d7
	move.l	#$B62,d0
	moveq	#$10,d1
	movea.l	#ThreeStars,a0
	move.w	(CreateListRow).w,d6
.4
	clr.w	d5
	jsr	(ReadSRAM).l
	cmp.b	1(a0),d6
	bne.w	.5
	clr.b	1(a0)
	st	d5
.5
	cmp.b	3(a0),d6
	bne.w	.6
	clr.b	3(a0)
	st	d5
.6
	cmp.b	5(a0),d6
	bne.w	.7
	clr.b	5(a0)
	st	d5
.7
	cmp.b	7(a0),d6
	bne.w	.8
	clr.b	7(a0)
	st	d5
.8
	cmp.b	9(a0),d6
	bne.w	.9
	clr.b	9(a0)
	st	d5
.9
	cmp.b	$B(a0),d6
	bne.w	.10
	clr.b	$B(a0)
	st	d5
.10
	tst.w	d5
	beq.w	.11
	jsr	(WriteSRAM).l
.11
	addi.l	#$10,d0
	dbf	d7,.4
	move.l	#$D22,d0
	move.w	(CreateListRow).w,d3
	asl.w	#4,d3
	ext.l	d3
	add.l	d3,d0
	moveq	#$10,d1
	movea.l	#ThreeStars,a0
	jsr	(ReadSRAM).l
	move.l	a0,-(sp)
	move.w	#$F,d3
.12
	clr.b	(a0)+
	dbf	d3,.12
	movea.l	(sp)+,a0
	jsr	(WriteSRAM).l
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts
