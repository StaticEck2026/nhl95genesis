;	NHL 95 create95. Retail $097C54-$09ACE5 (12434 bytes).
;	New in 95: the season Create Player screens (the created player list, name entry with the letter grid, Modify Ratings
;	with the attribute points pool, the save RAM create records), Sign Free Agents and Release Players. Moved in: cards94
;	NameEntryFramer. Each routine comment says 95 only or names its 94 routine. NameEntryScreen follows at $09ACE6.
;	IDA hid printz / printz2 / printbigz Strings and DecompressGraphicsWithCallback remap bytes as instructions and left the
;	Modify Ratings field routines, the attribute handlers and several tables as dc.b; they are written from the retail bytes.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

CreateScreenGfx	;IDA: sub_97C54. set up VDP planes and load create-player graphics/palettes
	move.l	#VBlank_SetOptions,(vbint).w
	move	#$2500,sr
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
.0
	move.w	#$B800,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0
	jsr	(setvram).l
	jsr	(orjoy).l
	move.w	#1,d4
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$44,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$4C,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont3chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$47,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont4chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$BB,$23,$44,$67,$89,$AB,$CD,$EF
	move.l	#SmallFontMap,(smallfontptr).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	move.w	d4,(teamblocksmapptr).w
	movea.l	#Teamblocksmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	movea.l	#Framermap+8,a2
	move.w	d4,(framercset).w
	move.l	#Framermap,(framermapptr).l
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	jsr	(printz).l
	String	$FE,0,0,0
	movea.l	#CreateBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	move.w	d4,(StatWork+$3C).w
	rts

CreatePlayer	;IDA: loc_97D9A. Create Player screen entry: load graphics, draw title, init player list and name editor
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#1,(BA_PS_flags).w
	bsr.w	CreateRatingsGfx
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	move.w	d4,(spritechars).w
	movea.l	#NameEntryBgMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w

CreatePlayerRedraw	;IDA: loc_97DDC. (re)draw "Create Player" title and player list
	jsr	(printbigz).l
	String	$BF,7,2,'Create Player'
	bsr.w	ReadCreatedPlayers
	clr.w	(CreateListOldRow).w
	move.w	#1,(CreateListRow).w
	clr.w	d0
	move.w	(createdcount).l,d0
	subq.w	#1,d0
.0
	move.w	d0,(CreateListSel).l
	subq.w	#6,d0
	bpl.w	.1
	clr.w	d0
.1
	move.w	d0,(CreateListTop).l
	move.w	(CreateListSel).l,d0
	addq.w	#1,d0
	move.w	d0,(CreateListRow).w
	movea.l	#NameEntryBuf,a1
	bsr.w	GetCreateName
	bsr.w	DrawCreateList
	clr.w	d4
	bsr.w	FixFirstLetter
	bsr.w	rtsCreate2
	bsr.w	GridLetterPos
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(NameEntryFramer).l
	move.w	(sp)+,(printy).w
	addq.w	#1,(printy).w
.2
	move.w	(sp)+,(printx).w
	addq.w	#1,(printx).w
.3
	bsr.w	PrintGridLetter
	move.w	#1,(NameEntryMode).w
	bsr.w	NameEntry
	clr.w	d0
	bra.w	NameCursorMove

CreatePlayerLoop	;IDA: loc_97E7A. main input loop: list mode scrolls players, edit mode moves name/char cursors
	bsr.w	CountNameLength
	jsr	(printz).l
	String	$BF,5,$12,0
	tst.w	(NameEntryMode).w
	beq.w	.0
	jsr	(printz).l
	String	$BF,9,5,0
	move.w	(CreateListRow).w,d0
	sub.w	(CreateListTop).l,d0
	add.w	d0,(printy).w
	movea.l	#NameEntryBuf,a1
	bsr.w	PrintEditName
.0
	bsr.w	MoveListMarkers
.1
	move.w	(vcount).w,d0
.2
	cmp.w	(vcount).w,d0
	beq.s	.2
	jsr	(ReadJoy1).l
	tst.w	d1
	beq.s	.1
	tst.w	(NameEntryMode).w
	bne.w	.3
	move.w	#1,d0
	btst	#7,d1
	bne.w	CreatePlayerExit
	btst	#1,d1
	bne.w	CreateListMove
	move.w	#$FFFF,d0
	btst	#0,d1
	bne.w	CreateListMove
	btst	#4,d1
	beq.w	CreatePlayerLoop
	clr.w	d4
	clr.w	d5
	bsr.w	NameEntry
	clr.w	d0
	bra.w	CreateListMove
.3
	moveq	#$FFFFFFFF,d0
	btst	#7,d1
	bne.w	CreateNameDone
	btst	#6,d1
	bne.w	NameCursorMove
	neg.w	d0
	btst	#5,d1
	bne.w	NameCursorMove
	btst	#3,d1
	bne.w	GridCursorMove
	neg.w	d0
	btst	#2,d1
	bne.w	GridCursorMove
	moveq	#6,d0
	btst	#1,d1
	bne.w	GridCursorMove
	neg.w	d0
	btst	#0,d1
	bne.w	GridCursorMove
	btst	#4,d1
	beq.w	CreatePlayerLoop
	bsr.w	NameEntry
	bra.w	CreatePlayerLoop

CreateListMove	;IDA: loc_97F5E. move player-list selection by d0 and scroll the list window
	add.w	d0,(CreateListRow).w
	move.w	(CreateListRow).w,d1
	cmp.w	(createdcount).l,d1
	ble.w	.0
	sub.w	d0,(CreateListRow).w
.0
	tst.w	(CreateListRow).w
	bne.w	.1
	sub.w	d0,(CreateListRow).w
.1
	move.w	(CreateListRow).w,d0
	subq.w	#1,d0
	cmp.w	(CreateListTop).l,d0
	bge.w	.2
	subq.w	#1,(CreateListTop).l
	subq.w	#1,(CreateListSel).l
	bsr.w	DrawCreateList
.2
	cmp.w	(CreateListSel).l,d0
	ble.w	.3
	addq.w	#1,(CreateListTop).l
	addq.w	#1,(CreateListSel).l
	bsr.w	DrawCreateList
.3
	movea.l	#NameEntryBuf,a1
	bsr.w	GetCreateName
	tst.w	(NameEntryMode).w
	bne.w	.4
	jsr	(NameListHelp).l
	bra.w	CreatePlayerLoop
.4
	jsr	(printz).l
	String	$BF,4,$13,0
	add.w	d4,(printx).w
	jsr	(printz).l
	String	'   ',0
	bsr.w	GridLetterPos
	moveq	#1,d2
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
	addq.w	#1,(printy).w
	move.w	(sp)+,(printx).w
	addq.w	#1,(printx).w
	bsr.w	PrintGridLetter
	bsr.w	FixFirstLetter
	move.w	d4,d0
	neg.w	d0
	bra.w	NameCursorMove

NameCursorMove	;IDA: loc_98026. move name cursor (d4, 0-$11) by d0
	add.w	d4,d0
	cmp.w	#$11,d0
	bhi.w	CreatePlayerLoop
	move.w	d0,d4
	bsr.w	rtsCreate2
	movea.l	#NameEntryBuf,a0
	clr.w	d0
	cmpi.b	#$2D,(a0,d4.w)
	beq.w	GridCursorMove
	move.b	(a0,d4.w),d0
	ext.w	d0
	bsr.w	FindGridLetter
	sub.w	d5,d0

GridCursorMove	;IDA: loc_98054. move character-grid cursor (d5, 0-$1D) by d0 and write char into name buffer
	add.w	d5,d0
	cmp.w	#$1D,d0
	bhi.w	CreatePlayerLoop
	move.w	d0,-(sp)
	bsr.w	GridLetterPos
	moveq	#1,d2
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
	addq.w	#1,(printy).w
	move.w	(sp)+,(printx).w
	addq.w	#1,(printx).w
	bsr.w	PrintGridLetter
	move.w	(sp)+,d5
	bsr.w	GridLetterPos
	move.w	(printx).w,-(sp)
	move.w	(printy).w,-(sp)
	tst.w	(NameEntryMode).w
	beq.w	.0
	jsr	(NameEntryFramer).l
.0
	move.w	(sp)+,(printy).w
	addq.w	#1,(printy).w
	move.w	(sp)+,(printx).w
	addq.w	#1,(printx).w
	bsr.w	PrintGridLetter
	movea.l	#NameEntryBuf,a0
	movea.l	#CreateLetterGrid,a1
	move.b	(a1,d5.w),d0
	move.b	d0,(a0,d4.w)
	bra.w	CreatePlayerLoop

CreateNameDone	;IDA: loc_980D0. Start in edit mode: validate name, save player and continue, else clear and redraw
	bsr.w	SaveCreateName
	bmi.w	.0
	bsr.w	InitCreateRecord
	jsr	(MakeSRAMChecksum).l
	jmp	(ModifyRatings).l
.0
	jsr	(printz).l
	String	$FF,0,0,0
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	bra.w	CreatePlayerRedraw

CreatePlayerExit	;IDA: loc_98106. Start in list mode: leave create-player screen back to main flow
	movem.l	(sp)+,d0-d7/a0-a6
	bset	#6,(setupcardflags).w
	jmp	(Opening2).l

NameEntry	;IDA: sub_98116. Create Player name entry: toggle grid/edit mode, draw letter grid + help text, or the name list + arrow help
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$0,$D,$0
	move.w	#$28,d0
	move.w	#9,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	bchg	#0,(NameEntryMode+1).w
	bne.w	NameListMode
	bsr.w	NameEntryBg
	jsr	(printz).l
	String	$BF,$A,$F,$0
	movea.l	#CreateLetterGrid,a0
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
	jsr	(print).l
	addq.w	#2,(printy).w
	subi.w	#$C,(printx).w
	dbf	d0,.0
	jsr	(printz).l
	String	$FE,$16,$E,$0
	moveq	#$16,d0
	moveq	#7,d1
	jsr	(printz2).l
	String	$F9,$2
	jsr	(printz).l
	String	$BF,$17,$F,$0
	jsr	(printz2).l
	String	'D-Pad to a   ',$0
	jsr	(printz).l
	String	$BF,$17,$10,$0
	jsr	(printz2).l
	String	'letter.      ',$0
	move.w	#$17,(printx).w
	addq.w	#1,(printy).w
	move.w	(printx).w,-(sp)
	jsr	(printz2).l
	String	'C to select   '
	move.w	(sp),(printx).w
	addq.w	#1,(printy).w
	jsr	(printz2).l
	String	'letter.       '
	move.w	(sp),(printx).w
	addq.w	#1,(printy).w
	jsr	(printz2).l
	String	'A to go back. '
	move.w	(sp),(printx).w
	addq.w	#1,(printy).w
.2
	jsr	(printz2).l
	String	'B to cancel.  '
	move.w	(sp),(printx).w
.3
	addq.w	#2,(printy).w
	jsr	(printz2).l
	String	'START when    '
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
	jsr	(printz2).l
	String	'done.         '
.4
	jsr	(printz2).l
	String	$F9,$2

NameEntryDone	;IDA: loc_982AA. 95 only. NameEntry: return
	movem.l	(sp)+,d0-d7/a0-a6
.0
	rts

NameEntryBg	;IDA: sub_982B0. Draw name entry background graphic (unk_1834F4) at the printz position
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(spritechars).w,d4
	jsr	(printz).l
	String	$FF,$16,$E,$0
.0
	movea.l	#NameEntryBgMap,a0
	movea.l	a0,a1

NameEntryBgTail	;IDA: sub_982CC. (IDA label, mid-routine of sub_982B0) map draw tail
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#1,d2
	moveq	#$A,d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

NameListMode	;IDA: loc_982E8. 95 only. NameEntry: name list mode (list and arrow help)
	movea.l	#NameEntryBuf,a1
	bsr.w	GetCreateName
	move.w	#0,(printx).w
.0
	move.w	#$F,(printy).w
	move.w	#$28,d0
	move.w	#$D,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$FE,$16,$E,$0
	moveq	#$16,d0
	moveq	#7,d1
	bsr.w	DrawCreateList
	bsr.w	NameListHelp
	bra.s	NameEntryDone

NameListHelp	;IDA: sub_9832A. Print help text for name list mode (D-Pad up/down / START exit / B edit)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz2).l
	String	$F9,$2
	jsr	(printz).l
	String	$BF,$17,$F,$0
	jsr	(printz2).l
	String	'D-Pad up/down '
	jsr	(printz).l
	String	$BF,$17,$10,$0
	jsr	(printz2).l
	String	'moves arrows. '
	move.w	#$17,(printx).w
	move.w	(printx).w,-(sp)
	addq.w	#2,(printy).w
	jsr	(printz2).l
	String	'Press START to'
	addq.w	#1,(printy).w
	move.w	(sp),(printx).w
	jsr	(printz2).l
	String	'exit.         '
	addq.w	#2,(printy).w
	move.w	(sp),(printx).w
	jsr	(printz2).l
	String	'Press B to    '
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
.0
	jsr	(printz2).l
	String	'edit.         '
	jsr	(printz2).l
	String	$F9,$0
	movem.l	(sp)+,d0-d7/a0-a6
.1
	rts

FixFirstLetter	;IDA: sub_9840A. Normalize first letter of name buffer to a letter grid char (unknown -> A)
	movem.l	d0-d4/a0-a6,-(sp)
	move.b	(NameEntryBuf).w,d0
	bsr.w	FindGridLetter
	cmp.w	#$1E,d0
	blt.w	.0
	clr.w	d5
	bra.w	.2
.0
	move.w	d0,d5
.1
	movea.l	#CreateLetterGrid,a0
	move.b	(a0,d5.w),(NameEntryBuf).w
.2
	movem.l	(sp)+,d0-d4/a0-a6
	rts

FindGridLetter	;IDA: sub_98438. Find char d0 in letter grid table, return index in d0 ($1E if not found)
	movem.l	d1-d3/a0-a6,-(sp)
	movea.l	#CreateLetterGrid,a0
	move.b	d0,d1
.0
	clr.w	d0
	move.w	#$1E,d3
.1
	cmp.b	(a0,d0.w),d1
	beq.w	.2
	addq.w	#1,d0
	dbf	d3,.1
	move.w	#$1E,d0
.2
	movem.l	(sp)+,d1-d3/a0-a6
	rts

rtsCreate2	;IDA: nullsub_2. Empty return
	rts

PrintGridLetter	;IDA: sub_98464. If grid mode, print letter d5 of the grid table (cursor letter)
	tst.w	(NameEntryMode).w
	beq.s	rtsCreate2
	movea.l	#StatBuf,a1
	move.w	#4,(a1)
	move.b	#0,3(a1)
	movea.l	#CreateLetterGrid,a0
	move.b	(a0,d5.w),d0
	move.b	d0,2(a1)
	jmp	(print).l

GridLetterPos	;IDA: sub_9848E. Set print position for letter grid cell d5 (6 per row), d0/d1 = frame size
	jsr	(printz).l
	String	$BF,$9,$E,$0
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

DrawCreateList	;IDA: sub_984B6. Draw list of up to 6 player names starting at player FF55F4
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(NameEntryLen).w,-(sp)
	move.w	(CreateListRow).w,-(sp)
	jsr	(printz).l
	String	$BF,$9,$6,$0
	move.w	#6,d7
	cmp.w	(createdcount).l,d7
	blt.w	.0
	move.w	(createdcount).l,d7
	subq.w	#1,d7
.0
	move.w	(CreateListTop).l,(CreateListRow).w
	addq.w	#1,(CreateListRow).w
	movea.l	#StatWork,a1
.1
	bsr.w	GetCreateName
	move.w	(printx).w,-(sp)
	bsr.w	PrintEditName
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
	addq.w	#1,(CreateListRow).w
	dbf	d7,.1
	move.w	(sp)+,(CreateListRow).w
	move.w	(sp)+,(NameEntryLen).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

MoveListMarkers	;IDA: sub_98520. Move selection arrows to the current list row if it changed
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(CreateListRow).w,d0
	cmp.w	(CreateListOldRow).w,d0
	beq.w	.0
	movea.l	#ListMarkersOff,a1
	bsr.w	PrintListMarkers
	movea.l	#ListMarkers,a1
	bsr.w	PrintListMarkers
.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintListMarkers	;IDA: sub_9854A. Print the 2 strings at a1 on old list row (left and x=$1C), then old row = current
	tst.w	(CreateListOldRow).w
	beq.w	.0
	jsr	(printz).l
	String	$BF,$7,$6,$0
	move.w	(CreateListOldRow).w,d0
	subq.w	#1,d0
	sub.w	(CreateListTop).l,d0
	add.w	d0,(printy).w
	move.l	a1,-(sp)
	jsr	(print).l
	movea.l	(sp)+,a1
	adda.w	(a1),a1
	move.w	#$1C,(printx).w
	jsr	(print).l
.0
	move.w	(CreateListRow).w,(CreateListOldRow).w
	rts

ListMarkers	;IDA: unk_9858E. 95 only. Row markers ] and [
	String	']',$0;row marker chars (left of name, at x=$1C)
	String	'[',$0

ListMarkersOff	;IDA: unk_98596. 95 only. Blanks that erase the row markers
	String	' ',$0;blanks (erase arrows)
	String	' ',$0

CountNameLength	;IDA: sub_9859E. Count name length of name buffer FFD0E0 into FFD0F4
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$11,d3
	movea.l	#NameEntryBuf,a0
	clr.w	(NameEntryLen).w
.0
	cmpi.b	#$2D,(a0)
	bne.w	.1
	tst.b	(a0)+
	bra.w	.2
.1
	tst.b	(a0)+
	beq.w	.3
	addq.w	#1,(NameEntryLen).w
.2
	dbf	d3,.0
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintEditName	;IDA: sub_985D2. Print 18-char name from a1 with - padding, highlight cursor char d4 in grid mode
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(NameEntryLen).w,-(sp)
	move.w	#$12,(NameEntryLen).w
	movea.l	#StatBuf,a0
	move.w	(NameEntryLen).w,d0
	move.w	#0,d3
	move.w	#$16,(a0)+
.0
	cmp.w	#8,d3
	bne.w	.1
	move.b	#$20,(a0)+
.1
	move.b	(a1,d3.w),d1
	cmp.w	(NameEntryLen).w,d3
	blt.w	.2
	move.b	#$2D,d1
.2
	cmp.b	#$20,d1
	bne.w	.3
	move.b	#$2D,d1
.3
	move.b	d1,(a0)+
	addq.w	#1,d3
	cmp.w	#$12,d3
	blt.s	.0
	movea.l	#StatBuf,a1
	move.w	(printx).w,d7
	move.l	a1,-(sp)
	jsr	(print).l
	movea.l	(sp)+,a1
	tst.w	(NameEntryMode).w
	beq.w	.6
	adda.w	d4,a1
	cmp.w	#8,d4
	blt.w	.4
	addq.w	#1,a1
.4
	addq.w	#2,a1
	movea.l	#StatWork,a0
	move.w	#4,(a0)
	move.b	(a1),2(a0)
	clr.b	3(a0)
	movea.l	a0,a1
	jsr	(printz2).l
	String	$F9,$1
	add.w	d4,d7
	cmp.w	#8,d4
	blt.w	.5
	addq.w	#1,d7
.5
	move.w	d7,(printx).w
	jsr	(printsmall).l
	jsr	(printz2).l
	String	$F9,$0
.6
	move.w	(sp)+,(NameEntryLen).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CreateLetterGrid	;IDA: unk_98696. 95 only. Name entry letter grid (6 per row), $FF end
	dc.b	'ABCDEFGHIJKLMNOPQRSTUVWXYZ.12 -',$FF;letter grid characters (5 rows of 6)

NameEntryFramer	;IDA: sub_986B6. cards94 NameEntryFramer. Framer with the name entry frame charset (nameframechars)
	move.w	(framercset).w,-(sp)
	move.w	(nameframechars).w,(framercset).w
	jsr	(Framer).l
	move.w	(sp)+,(framercset).w
	rts

GetCreateName	;IDA: sub_986CC. Copy player name (FFD0F6-1)*18 from FFFF0000 to a1, 0->-, length to FFD0F4 (like 94 GetLogName)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#M68K_RAM,a0
	move.w	(CreateListRow).w,d2
	subq.w	#1,d2
	mulu.w	#$12,d2
	move.w	#0,(NameEntryLen).w
	move.w	#$11,d3
.0
	move.b	(a0,d2.w),d0
	beq.w	.1
	bra.w	.2
.1
	move.b	#$2D,d0
	subq.w	#1,(NameEntryLen).w
	move.b	d0,(a1)+
	bra.w	.4
.2
	cmp.b	#$2D,d0
	bne.w	.3
	move.b	#$20,d0
.3
	move.b	d0,(a1)+
.4
	addq.w	#1,(NameEntryLen).w
	addq.w	#1,d2
	dbf	d3,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SaveCreateName	;IDA: sub_98722. Save entered name to the created-player record (new or existing); invalid name -> message; d0=0 ok/-1
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	BuildEnteredName
	bmi.w	InvalidName
	move.w	(CreateListRow).w,d0
	subq.w	#1,d0
	add.w	d0,d0
	movea.l	#CreatedIds,a0
	tst.w	(a0,d0.w)
	bmi.w	SaveNameNext
	movem.l	d1-d3/a1,-(sp)
	movea.l	#$20BA44,a1
	move.w	#0,d2
.0
	move.w	(a1,d2.w),d3
	andi.w	#$FF,d3
	lsl.w	#8,d3
	move.w	2(a1,d2.w),d1
	andi.w	#$FF,d1
	or.w	d1,d3
	cmp.w	(a0,d0.w),d3
	beq.w	.1
	addq.w	#4,d2
	cmp.w	#$68,d2
	blt.s	.0
	clr.w	d2
.1
	asr.w	#2,d2
	move.w	d2,(CreateWork).l
	movem.l	(sp)+,d1-d3/a1
	move.w	(a0,d0.w),d1
	andi.w	#$FF,d1
	move.w	d1,(CreateIndex).l
	asl.w	#5,d1
	add.w	d1,d1
	movea.l	#$20B540,a0
	adda.w	d1,a0
	bsr.w	CopyNameWords
	bra.w	SaveNameOk

CopyNameWords	;IDA: sub_987A6. Copy length-prefixed name at FFBB1E into a0 as words
	movea.l	#StatWork,a1
	move.w	(a1),d0
	subq.w	#1,d0
	clr.w	d1
.0
	move.b	(a1)+,d1
	move.w	d1,(a0)+
	dbf	d0,.0
	rts

SaveNameNext	;IDA: loc_987BC. 95 only. SaveCreateName: next name character
	bsr.w	CheckCreateSlots
	bmi.w	SaveNameEnd
	movea.l	#$20B540,a0
	clr.w	d6
	move.w	#$13,d5
.0
	tst.b	1(a0)
	bne.w	.1
	tst.b	3(a0)
	beq.w	.2
.1
	adda.l	#$40,a0
	addq.w	#1,d6
	dbf	d5,.0
	bra.w	SaveNameEnd
.2
	bsr.s	CopyNameWords
	addq.w	#1,($20BA42).l
	movea.l	#$20BA44,a0
	move.w	($20BAAE).l,d0
	cmp.b	#$1A,d0
	bge.w	SaveNameLoop2
	clr.w	(CreateWork).l
.3
	tst.b	1(a0)
	bmi.w	.4
	addq.l	#4,a0
	addq.w	#1,(CreateWork).l
	bra.s	.3
.4
	move.b	d6,3(a0)
	andi.w	#$FF,d6
	move.w	d6,(CreateIndex).l
	move.b	#$1E,1(a0)
	addq.w	#1,($20BAAE).l

SaveNameOk	;IDA: loc_9883E. 95 only. SaveCreateName: name valid, store it
	bra.w	SaveNameFail

SaveNameLoop2	;IDA: loc_98842. 95 only. SaveCreateName: copy loop
	bra.w	InvalidNameWait

SaveNameEnd	;IDA: loc_98846. 95 only. SaveCreateName: done, d0 = 0
	bra.w	InvalidNameWait

InvalidName	;IDA: loc_9884A. 95 only. SaveCreateName: "Invalid Name. Make sure player has both a first and last name." box
	jsr	(printz).l
	String	$BF,$5,$5,$0
	move.w	#$1E,d0
	move.w	#$F,d1
	jsr	(Framer).l
	jsr	(printz2).l
	dc.w	$4C;String length
	dc.b	$F9,$3,$FD,$6,$FC,$6,'Invalid Name.',$FD
	dc.b	$6,$FA,$1,'Make sure player has',$FD,$6,$FA,$1
	dc.b	'both a first and last name.'
	move.w	(vcount).w,d0
.0
	cmp.w	(vcount).w,d0
	beq.s	.0
.1
	jsr	(ReadJoy1).l
	tst.w	d1
	beq.s	.0

InvalidNameWait	;IDA: loc_988CA. 95 only. SaveCreateName: wait for a key, close the box
	jsr	(printz2).l
	String	$F9,$0
	move.w	#$FFFF,d0
	bra.w	SaveNameRet

SaveNameFail	;IDA: loc_988DC. 95 only. SaveCreateName: d0 = -1
	clr.w	d0

SaveNameRet	;IDA: loc_988DE. 95 only. SaveCreateName: return
	movem.l	(sp)+,d0-d7/a0-a6
.0
	rts

ReadCreatedPlayers	;IDA: sub_988E4. read created players: load $36-byte list from save RAM $5D22, build 18-byte name records at $FFFF0000 and ids at $FFFF4E20, count in word_FF55F0, add an empty slot if room
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(createdcount).l
.0
	movea.l	#TradeBuf,a0
.1
	move.l	#$5D22,d0
	moveq	#$36,d1
	jsr	(ReadSRAM).l
	move.w	#$1A,d6
	movea.l	#CreatedIds,a3
.2
	movea.l	#M68K_RAM,a2
.3
	move.w	#$FFFF,d5
.4
	bra.w	.6
.5
	tst.w	(a0)+
	bmi.w	.6
	move.w	-2(a0),d0
	andi.w	#$1F00,d0
	cmp.w	#$1E00,d0
	bne.w	.6
	move.w	-2(a0),d0
	jsr	(GetCreatedName).l
	bsr.w	FormatNameRecord
	adda.w	#$12,a2
	move.w	-2(a0),d0
	move.w	d0,(a3)+
	addq.w	#1,(createdcount).l
.6
	addq.w	#1,d5
	dbf	d6,.5
	cmpi.w	#$14,(createdcount).l
	bge.w	.8
	move.w	($20BA42).l,d0
	cmp.b	#$14,d0
	bge.w	.8
	move.w	#$11,d0
.7
	move.b	#0,(a2)+
	dbf	d0,.7
	move.w	#$8000,(a3)
	addq.w	#1,(createdcount).l
.8
	movem.l	(sp)+,d0-d7/a0-a6
	rts

BuildEnteredName	;IDA: sub_9898A. build the entered name (from $FFFFD0E0, spaces/dashes dropped, space after first name) as a length-word string at dword_FFBB1E and check it
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#linemarkbuf+2,a0
	movea.l	#NameEntryBuf,a1
	move.w	(NameEntryLen).w,d0
	subq.w	#1,d0
	clr.w	d5
	clr.w	d6
.0
	cmp.w	#8,d6
	bne.w	.1
	move.b	#$20,(a0)+
	addq.w	#1,d5
.1
	move.b	(a1)+,d1
	cmp.b	#$20,d1
	beq.w	.2
	cmp.b	#$2D,d1
	beq.w	.2
	move.b	d1,(a0)+
	addq.w	#1,d5
.2
	addq.w	#1,d6
	dbf	d0,.0
	btst	#0,d5
	beq.w	.3
	move.b	#0,(a0)
	addq.w	#1,d5
.3
	addq.w	#2,d5
	move.w	d5,(StatWork).w
	cmp.w	#6,d5
	blt.w	.7
	movea.l	#StatWork,a0
	adda.w	(a0),a0
	move.b	-(a0),d0
	tst.b	d0
	bne.w	.4
	move.b	-(a0),d0
.4
	cmp.b	#$20,d0
	beq.w	.7
	movea.w	#(StatWork-M68K_RAM),a0
	move.w	(a0)+,d0
	subq.w	#1,d0
.5
	cmpi.b	#$20,(a0)+
	beq.w	.6
	dbf	d0,.5
	bra.w	.7
.6
	clr.w	d0
	bra.w	.8
.7
	move.w	#$FFFF,d0
.8
	movem.l	(sp)+,d0-d7/a0-a6
	rts

FormatNameRecord	;IDA: sub_98A2C. format name string at a1 into an 18-byte record at a2: first name padded to 8 and last name to 10 with dashes
	movem.l	d0-d7/a1-a2,-(sp)
	move.w	(a1)+,d7
	subq.w	#3,d7
	move.w	#7,d6
.0
	cmpi.b	#$20,(a1)
	beq.w	.1
	move.b	(a1)+,d0
	move.b	d0,(a2)+
	subq.w	#1,d7
	dbf	d6,.0
.1
	tst.w	d6
	bmi.w	.3
.2
	move.b	#$2D,(a2)+
	dbf	d6,.2
.3
	addq.w	#1,a1
	subq.w	#1,d7
	move.w	#9,d6
.4
	move.b	(a1)+,d0
	move.b	d0,(a2)+
	subq.w	#1,d6
	dbf	d7,.4
	tst.w	d6
	bmi.w	.6
.5
	move.b	#$2D,(a2)+
	dbf	d6,.5
.6
	movem.l	(sp)+,d0-d7/a1-a2
	rts

NewCreateRecord	;no IDA label. same as sub_98A88 but with bit 2 of byte_FFBF04 set (skips the read)
	bset	#2,(sflags8).w
	bra.w	InitCreateRecord2

InitCreateRecord	;IDA: sub_98A88. read 32-byte create record #word_FF55FE from save RAM ($5AA0) to $FFFF7538, put an 8-byte tail on it by flag $1F, write it back
	bclr	#2,(sflags8).w

InitCreateRecord2	;no IDA label. 95 only. InitCreateRecord without the bset (NewCreateRecord enters here)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#CreateRecord,a0
	clr.l	d0
	move.w	(CreateIndex).l,d0
	asl.w	#5,d0
	addi.l	#$5AA0,d0
	moveq	#$20,d1
	movem.l	d0-d1/a0,-(sp)
	btst	#2,(sflags8).w
	bne.w	.0
	jsr	(ReadSRAM).l
.0
	movea.l	#CreateRecordTail2,a1
	tst.b	$1F(a0)
	bne.w	.1
	movea.l	#CreateRecordTail1,a1
.1
	adda.w	(a0),a0
	move.w	#7,d0
.2
	move.b	(a1)+,(a0)+
	dbf	d0,.2
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CreateRecordTail1	;IDA: unk_98AEE. 95 only. 8 byte record tail (record byte $1F clear)
	dc.b	$20
	dc.b	$82
	dc.b	$22
	dc.b	$22
	dc.b	0
	dc.b	0
	dc.b	$22
	dc.b	$22

CreateRecordTail2	;IDA: unk_98AF6. 95 only. 8 byte record tail (record byte $1F set)
	dc.b	$20
	dc.b	$82
	dc.b	$22
	dc.b	$22
	dc.b	$22
	dc.b	$42
	dc.b	$22
	dc.b	$22

CreateRatingsGfx	;IDA: sub_98AFE. set up the create player screen: VDP setup, decompress graphics, print, draw background map
	move	#$2700,sr
	move.w	#2,d4
	move.l	#VBlank_SetOptions,(vbint).w
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0
	jsr	(setvram).l
	move	#$2500,sr
	jsr	(orjoy).l
	move.w	d4,(framercset).w
	movea.l	#Framermap+8,a2
	move.l	#Framermap,(framermapptr).l
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	move.w	d4,(nameframechars).w
	movea.l	#Framermap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$60,$89,$AB,$CD,$EF
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$44,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$4C,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont3chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$47,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont4chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$BB,$23,$44,$67,$89,$AB,$CD,$EF
	move.l	#SmallFontMap,(smallfontptr).l
	jsr	(printz).l
	String	$FF,$0,$0,$0
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(SetRinkPalette).l
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	#ControllerBgMap,a0
	btst	#1,(BA_PS_flags).w
	beq.w	.0
	movea.l	#TradeBgMap,a0
.0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	rts

CheckCreateSlots	;IDA: sub_98C64. check free create slots: d0/flags = -1 (N set) if 20 created players exist, else 1
	movem.w	d0,-(sp)
	move.w	($20BA42).l,d0
	cmp.b	#$14,d0
	blt.w	.0
	move.w	#$FFFF,d0
	bra.w	.1
.0
	move.w	#1,d0
.1
	movem.w	(sp)+,d0
	rts

ClearCreatedPlayers	;IDA: sub_98C88. clear the created players list at $FFFF5D22 (26 x $8000 + 0 terminator)
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#CreatedList,a0
	move.w	#$19,d6
.0
	move.w	#$8000,(a0)+
	dbf	d6,.0
	move.b	#0,(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DeleteCreatedPlayer	;IDA: sub_98CA8. delete created player #word_FFBB10: remove it from the save RAM records, roster list and team lines
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$1C,d7
	bset	#7,(GameFlags).w
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	movem.w	d0/d7,-(sp)
	jsr	(GetCreatedId).l
	move.w	d0,(a2)+
	movem.w	(sp)+,d0/d7
	jsr	(GetJerseyNumber).l
	move.w	(CreatedPlayerBuf).w,(a2)+
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#StatBuf,a0
	move.w	d7,d0
	asl.w	#5,d0
	ext.l	d0
	addi.l	#$5700,d0
	moveq	#$20,d1
	movem.l	d0-d1/a0,-(sp)
	jsr	(ReadSRAM).l
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	move.w	#$19,d1
	sub.w	d0,d1
	beq.w	.1
.0
	move.b	1(a0,d0.w),d2
	move.b	d2,(a0,d0.w)
	addq.w	#1,d0
	dbf	d1,.0
.1
	movem.l	(sp)+,d0-d1/a0
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d7/a0-a6
	movea.l	#StatBuf,a0
	jsr	(ReadCreateList).l
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	cmp.w	#$32,d0
	bne.w	.2
	move.w	#$8000,(StatBuf+$32).w
	bra.w	.4
.2
	move.w	#$32,d3
.3
	move.w	2(a0,d0.w),d1
	move.w	d1,(a0,d0.w)
	addq.w	#2,d0
	cmp.w	d3,d0
	blt.s	.3
	move.w	#$8000,(a0,d0.w)
.4
	subq.b	#1,$35(a0)
	jsr	(WriteCreateList).l
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$1A,d7
	jsr	(ReadTeamPlayerStats).l
	movea.l	#StatBuf,a3
	move.w	#4,d6
.5
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	move.w	(a3,d0.w),d3
	move.w	d3,(a2)+
	move.w	#$32,d3
.6
	move.w	2(a3,d0.w),d1
	move.w	d1,(a3,d0.w)
	addq.w	#2,d0
	cmp.w	d3,d0
	blt.s	.6
	clr.w	(a3,d0.w)
	adda.w	#$34,a3
	dbf	d6,.5
	jsr	(WriteTeamPlayerStats).l
	movem.l	(sp)+,d0-d7/a0-a6
	bclr	#7,(GameFlags).w
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

GetCreatedId	;IDA: sub_98DD4. return player id word for created entry d0 from table $20BA44 (4-byte entries)
	movem.l	d1-d7/a0-a6,-(sp)
	movea.l	#$20BA44,a0
	add.w	d0,d0
	add.w	d0,d0
	adda.w	d0,a0
	move.w	2(a0),d0
	andi.w	#$FF,d0
	move.w	(a0),d7
	lsl.w	#8,d7
	andi.w	#$FF00,d7
	or.w	d7,d0
	movem.l	(sp)+,d1-d7/a0-a6
	rts

ReadCreateList	;IDA: sub_98DFC. read the $36-byte created player list from save RAM $5D22 into a0
	movem.l	d0-d1,-(sp)
	move.l	#$5D22,d0
	moveq	#$36,d1
	jsr	(ReadSRAM).l
	movem.l	(sp)+,d0-d1
	rts

WriteCreateList	;IDA: sub_98E14. calls sub_98E6 with d0=$5D22, d1=$36 (saves d0-d1)
	movem.l	d0-d1,-(sp)
	move.l	#$5D22,d0
	moveq	#$36,d1
	jsr	(WriteSRAM).l
	movem.l	(sp)+,d0-d1
	rts

ModifyRatings	;IDA: loc_98E2C. Create Player "Modify Ratings" screen: load graphics/text, then joypad loop (up/down/left/right pick rating, A/B change it, START done)
	move	#$2700,sr
	move.w	#2,d4
	move.l	#VBlank_SetOptions,(vbint).w
	bclr	#0,(disflags).w
	bset	#2,(disflags).w
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$B400,(VSPRITES).w
	move.w	#$B800,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#0,d0
	jsr	(setvram).l
	move	#$2500,sr
	jsr	(orjoy).l
	move.w	d4,(framercset).w
	move.l	#Framermap,(framermapptr).l
	movea.l	#Framermap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	move.w	d4,(nameframechars).w
	movea.l	#Framermap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$60,$89,$AB,$CD,$EF
	move.w	d4,(smallfontchars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$44,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont2chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$4C,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont3chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0B,$23,$47,$67,$89,$AB,$CD,$EF
	move.w	d4,(smallfont4chars).w
	movea.l	#SmallFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$BB,$23,$44,$67,$89,$AB,$CD,$EF
	jsr	(printz).l
	String	$FF,$0,$0,$0
	moveq	#$28,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(SetRinkPalette).l
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	#ControllerBgMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	moveq	#$28,d2
	moveq	#$1C,d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF
	jsr	(printbigz).l
	String	$BF,$7,$2,'Modify Ratings',$0
	jsr	(printz2).l
	dc.w	$44;String length
	dc.b	$F9,$1,$FD,$9,$FC,$19,'{}[] = Select Rating',$FA
	dc.b	$1,$FD,$4,'A,B=Decrease/Increase',$FD,$1C,'START=Done',$F9
	dc.b	$0,$0
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w
	bsr.w	ClearAttribDeltas
	bsr.w	LoadCreateTemplate
	bsr.w	SetPointsPool
	bsr.w	PrintCreateName
	clr.w	(CreateCursorY).l
	move.w	#2,(CreateCursorX).l
.0
	bsr.w	DrawRatings
.1
	move.w	(vcount).w,d0
.2
	cmp.w	(vcount).w,d0
	beq.s	.2
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.s	.1
	btst	#7,d1
	beq.w	.3
	jsr	(CommitCreatedPlayer).l
	bra.w	.17
.3
	btst	#0,d1
	beq.w	.6
	tst.w	(CreateCursorY).l
	bne.w	.5
	cmpi.w	#1,(CreateCursorX).l
	beq.w	.4
	bra.s	.1
.4
	move.w	#2,(CreateCursorX).l
	move.w	#1,(CreateCursorY).l
	bra.s	.0
.5
	subq.w	#1,(CreateCursorY).l
	bra.s	.0
.6
	btst	#1,d1
	beq.w	.9
	move.w	(CreateCursorX).l,d6
	bsr.w	LastFieldRow
	cmp.w	(CreateCursorY).l,d4
	ble.w	.7
	addq.w	#1,(CreateCursorY).l
	bra.w	.0
.7
	cmpi.w	#2,(CreateCursorX).l
	beq.w	.8
	cmpi.w	#3,(CreateCursorX).l
	bne.w	.1
.8
	move.w	#1,(CreateCursorX).l
	clr.w	(CreateCursorY).l
	bra.w	.0
.9
	btst	#3,d1
	beq.w	.13
	move.w	(CreateCursorX).l,d6
	addq.w	#1,d6
	cmp.w	#4,d6
	blt.w	.10
	clr.w	d6
.10
	bsr.w	LastFieldRow
.11
	cmp.w	(CreateCursorY).l,d4
	bge.w	.12
	subq.w	#1,(CreateCursorY).l
	bra.s	.11
.12
	move.w	d6,(CreateCursorX).l
	bra.w	.0
.13
	btst	#2,d1
	beq.w	.14
	move.w	(CreateCursorX).l,d6
	subq.w	#1,d6
	bpl.s	.10
	move.w	#3,d6
	bra.s	.10
.14
	btst	#6,d1
	beq.w	.15
	move.w	#$FFFF,d0
	bsr.w	EditField
	bra.w	.0
.15
	btst	#4,d1
	beq.w	.16
	move.w	#1,d0
	bsr.w	EditField
	bra.w	.0
.16
	bra.w	.1
.17
	bset	#6,(setupcardflags).w
	jmp	Opening2

PrintCreateName	;IDA: sub_99160. prints Name First:/Last: from name buffer $FFFF753A (split at the space) via string buffer $FFFFBBAA
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,$4,$6,'Name',$BF,$4,$7,'First:',$BF,$4,$8,'Last:'
	movea.l	#TextBuffer,a0
	movea.l	#CreateRecord+$2,a1
	move.w	#2,(mesarea).w
.0
	move.b	(a1)+,d0
	cmp.b	#$20,d0
	beq.w	.1
	move.b	d0,(a0)+
	addq.w	#1,(mesarea).w
	bra.s	.0
.1
	clr.b	(a0)
	addq.w	#1,(mesarea).w
	andi.w	#$FFFE,(mesarea).w
	movea.l	#mesarea,a1
	jsr	(printz).l
	String	$BF,$A,$7,$0
	jsr	(print).l
	movea.l	#TextBuffer,a0
	movea.l	#CreateRecord+$2,a1
	move.w	#2,(mesarea).w
	move.w	(CreateRecord).l,d6
	subq.w	#3,d6
.2
	move.b	(a1)+,d0
	subq.w	#1,d6
	cmp.b	#$20,d0
	bne.s	.2
.3
	move.b	(a1)+,(a0)+
	addq.w	#1,(mesarea).w
	dbf	d6,.3
	clr.b	(a0)
	addq.w	#1,(mesarea).w
	andi.w	#$FFFE,(mesarea).w
	movea.l	#mesarea,a1
	jsr	(printz).l
	String	$BF,$A,$8,$0
	jsr	(print).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawRatings	;IDA: sub_99224. redraws every rating cell (4 columns x rows from sub_9998E, each via sub_99774), then Max Unallocated Points
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	d6
	clr.w	d7
.0
	bsr.w	LastFieldRow
.1
	bsr.w	DrawField
	addq.w	#1,d7
	cmp.w	d4,d7
	ble.s	.1
	clr.w	d7
	addq.w	#1,d6
	cmp.w	#4,d6
	blt.s	.0
	bsr.w	rtsCreate3
	bsr.w	PrintUnallocated
	movem.l	(sp)+,d0-d7/a0-a6
	rts

rtsCreate3	;IDA: nullsub_3. empty stub (called from sub_99224)
	rts

PrintOverallRating	;no IDA label. unreferenced: prints OVERALL RTG. (player overall from sub_7CF78, *100/d1)
	jsr	(printz2).l
	String	$F9,$0,$FD,$4,$FC,$16,'OVERALL RTG.',$FD,$13
	movea.l	#CreateRecord,a0
	adda.w	(a0),a0
	addq.w	#8,a0
	movea.l	#FieldTextBuf,a4
	movea.l	#OvrGoalWgtList,a6
	move.l	(GAttribOverallMask).l,d4
	tst.w	(CreateType).l
	beq.w	.0
	movea.l	#OvrPlayerWgtList,a6
	move.l	(PAttribOverallMask).l,d4
.0
	jsr	(CalcAttribRating).l
	mulu.w	#$64,d0
	divu.w	d1,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	rts

PrintUnallocated	;IDA: sub_992C0. prints "Maximum Unallocated Points" and its value word_FF7536
	jsr	(printz2).l
	String	$F9,$0,$FD,$4,$FC,$17,'Maximum Unallocated Points',$FD,'"'
	move.w	(CreatePoints).l,d0
	move.w	#4,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	rts

DrawRatingValue	;IDA: sub_99302. calls the cell routine for column d6 / row d7 from table unk_996FC (unk_9970C if word_FF7534=0), a2 = player record
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#SkaterFieldTbls,a0
	tst.w	(CreateType).l
	bne.w	.0
	movea.l	#GoalieFieldTbls,a0
.0
	move.w	d6,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	move.w	d7,d0
	asl.w	#2,d0
	movea.l	(a0,d0.w),a0
	movea.l	#CreateRecord,a2
	adda.w	(a2),a2
	jsr	(a0)
	movem.l	(sp)+,d0-d7/a0-a6
	rts

FieldValue0	;no IDA label. 95 only. Field value: draw the cursor and print a rating (PAttribOverallMask+$42)
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$42).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldPrintSetup	;no IDA label. set print target a4/a0 (record+8) and number-print table a6 for a field value
	movea.l	#FieldTextBuf,a4
	movea.l	a2,a0
	addq.w	#8,a0
	movea.l	#AttribWgtList,a6
	rts

FieldValue1	;no IDA label. field: draw cursor, print rating from record via dword_85872
	bsr.w	FieldHighlight
	bsr.s	FieldPrintSetup
	move.l	(PAttribOverallMask+$2C).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue2	;no IDA label. field: draw cursor, print rating from record via dword_8594E
	bsr.w	FieldHighlight
	bsr.s	FieldPrintSetup
	move.l	(PAttribOverallMask+$108).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue3	;no IDA label. field: draw cursor, print rating from record via dword_858B4
	bsr.w	FieldHighlight
	bsr.s	FieldPrintSetup
	move.l	(PAttribOverallMask+$6E).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue4	;no IDA label. field: draw cursor, print rating from record via dword_858CA
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$84).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue5	;no IDA label. field: draw cursor, print rating from record via dword_85922
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$DC).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldWeight	;no IDA label. field Wt.: print weight = value*8+140 (via dword_85938)
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$F2).l,d4
	jsr	(CalcAttribRating).l
	asl.w	#3,d0
	addi.w	#$8C,d0
	move.w	#3,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue6	;no IDA label. field: draw cursor, print rating from record via dword_858E0
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$9A).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue7	;no IDA label. field: draw cursor, print rating from record via dword_858F6
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$B0).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue8	;no IDA label. field: draw cursor, print rating from record via dword_8590C
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$C6).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue9	;no IDA label. field: draw cursor, print rating from record via dword_85964
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$11E).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue10	;no IDA label. field: draw cursor, print rating from record via dword_8597A
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(PAttribOverallMask+$134).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldBlank1	;no IDA label. field with no value: draw cursor only (unreferenced)
	bsr.w	FieldHighlight
	bra.w	FieldDone

FieldBlank2	;no IDA label. field with no value: draw cursor only (unreferenced)
	bsr.w	FieldHighlight
	bra.w	FieldDone

FieldJersey	;no IDA label. field Unif.: print BCD jersey byte at (a2) as decimal
	bsr.w	FieldHighlight
	clr.w	d4
	move.b	(a2),d4
	lsr.w	#4,d4
	mulu.w	#$A,d4
	move.b	(a2),d0
	andi.b	#$F,d0
	add.b	d4,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue11	;no IDA label. field: draw cursor, print rating from record via dword_859BE
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(GAttribOverallMask+$16).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue12	;no IDA label. field: draw cursor, print rating from record via dword_85A00
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(GAttribOverallMask+$58).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue13	;no IDA label. field: draw cursor, print rating from record via dword_85A16
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(GAttribOverallMask+$6E).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue14	;no IDA label. field: draw cursor, print rating from record via dword_85A2C
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(GAttribOverallMask+$84).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue15	;no IDA label. field: draw cursor, print rating from record via dword_85A42
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(GAttribOverallMask+$9A).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue16	;no IDA label. field: draw cursor, print rating from record via dword_85A58
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(GAttribOverallMask+$B0).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldValue17	;no IDA label. field: draw cursor, print rating from record via dword_85A6E
	bsr.w	FieldHighlight
	bsr.w	FieldPrintSetup
	move.l	(GAttribOverallMask+$C6).l,d4
	jsr	(CalcAttribRating).l
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	bra.w	FieldDone

FieldHand	;no IDA label. field Hand: print R/L from bit 0 of record byte 4
	bsr.w	FieldHighlight
	move.b	4(a2),d0
	andi.w	#1,d0
	movea.l	#HandText,a1
	jsr	(PrintSmallListItem).l
	bra.w	FieldDone

HandText	;no IDA label. 95 only. R, L
	String	'R',0
	String	'L',0

FieldPos	;no IDA label. field Pos.: print G/F/D indexed by word_FF7534
	bsr.w	FieldHighlight
	move.w	(CreateType).l,d0
	movea.l	#PosText,a1
	jsr	(PrintSmallListItem).l

FieldDone	;no IDA label. common field exit: reset text color (printz2 $F9,0)
	jsr	(printz2).l
	String	$F9,0
	rts

PosText	;no IDA label. 95 only. G, F, D
	String	'G',0
	String	'F',0
	String	'D',0

FieldHighlight	;no IDA label. set normal text color, highlight if (d6,d7) is the cursor (word_FF7530/2)
	jsr	(printz2).l
	String	$F9,0
	cmp.w	(CreateCursorX).l,d6
	bne.w	.0
	cmp.w	(CreateCursorY).l,d7
	bne.w	.0
	jsr	(printz2).l
	String	$F9,1
.0
	rts

SkaterFieldTbls	;IDA: unk_996FC. skater field-routine tables by column
	dc.l	FieldTbl1,FieldTbl2,FieldTbl3,FieldTbl4

GoalieFieldTbls	;IDA: unk_9970C. goalie field-routine tables by column
	dc.l	FieldTbl5,FieldTbl6,FieldTbl3,FieldTbl4

FieldTbl1	;no IDA label. 95 only. Field routines of a column
	dc.l	FieldValue0,FieldValue1,FieldValue2,FieldValue3,FieldValue4,FieldValue5

FieldTbl2	;no IDA label. 95 only. Field routines of a column
	dc.l	FieldValue6,FieldValue7,FieldValue8,FieldValue9,FieldValue10

FieldTbl3	;no IDA label. 95 only. Field routines of a column
	dc.l	FieldPos,FieldWeight

FieldTbl4	;no IDA label. 95 only. Field routines of a column
	dc.l	FieldHand,FieldJersey

FieldTbl5	;no IDA label. 95 only. Field routines of a column
	dc.l	FieldValue11,FieldValue12,FieldValue13

FieldTbl6	;no IDA label. 95 only. Field routines of a column
	dc.l	FieldValue14,FieldValue15,FieldValue16,FieldValue17

DrawField	;IDA: sub_99774. draw one Create Player field (d6=column,d7=row): label then value, all regs saved
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	PrintFieldLabel
	bsr.w	DrawRatingValue
	movem.l	(sp)+,d0-d7/a0-a6
	rts

PrintFieldLabel	;IDA: sub_99786. print field label: pick skater/goalie label list, highlight if cursor, print entry d7
	movem.l	d0-d1/a0-a1,-(sp)
	movea.l	#SkaterLabelLists,a1
	tst.w	(CreateType).l
	bne.w	.0
	movea.l	#GoalieLabelLists,a1
.0
	move.w	d6,d0
	asl.w	#2,d0
	movea.l	(a1,d0.w),a1
	move.w	d7,d0
	movem.l	d0/a1,-(sp)
	jsr	(printz2).l
	String	$F9,0
	cmp.w	(CreateCursorX).l,d6
	bne.w	.1
	cmp.w	(CreateCursorY).l,d7
	bne.w	.1
	jsr	(printz2).l
	String	$F9,1
.1
	movem.l	(sp)+,d0/a1
	jsr	(PrintSmallListItem).l
	movem.l	(sp)+,d0-d1/a0-a1
	rts

SkaterLabelLists	;IDA: unk_997E6. skater attribute-label lists by column
	dc.l	LabelList1,LabelList2,LabelList3,LabelList4

GoalieLabelLists	;IDA: unk_997F6. goalie attribute-label lists by column
	dc.l	LabelList5,LabelList6,LabelList3,LabelList4

LabelList1	;no IDA label. 95 only. Field labels of a column
	String	$FD,$4,$FC,$A,'Speed',$FD,$13,$0
	String	$FD,$4,$FC,$C,'Agility',$FD,$13,$0
	String	$FD,$4,$FC,$E,'Endurance',$FD,$13,$0
	String	$FD,$4,$FC,$10,'Off.Awareness',$FD,$13,$0
	String	$FD,$4,$FC,$12,'Def.Awareness',$FD,$13,$0
	String	$FD,$4,$FC,$14,'Stickhandling',$FD,$13,$0

LabelList2	;no IDA label. 95 only. Field labels of a column
	String	$FD,$16,$FC,$A,'Shot Power',$FD,'$'
	String	$FD,$16,$FC,$C,'Shot Accuracy',$FD,'$',$0
	String	$FD,$16,$FC,$E,'Pass Accuracy',$FD,'$',$0
	String	$FD,$16,$FC,$10,'Aggression',$FD,'$'
	String	$FD,$16,$FC,$12,'Checking',$FD,'$'

LabelList3	;no IDA label. 95 only. Field labels of a column
	String	$FD,$16,$FC,$7,'Pos. ',$0
	String	$FD,$16,$FC,$8,'Wt. '

LabelList4	;no IDA label. 95 only. Field labels of a column
	String	$FD,$1E,$FC,$7,'Hand',$FD,'$'
	String	$FD,$1E,$FC,$8,'Unif.',$FD,'$',$0

LabelList5	;no IDA label. 95 only. Field labels of a column
	String	$FD,$4,$FC,$B,'Agility',$FD,$13,$0
	String	$FD,$4,$FC,$D,'Def.Awareness',$FD,$13,$0
	String	$FD,$4,$FC,$F,'Puck Control',$FD,$13

LabelList6	;no IDA label. 95 only. Field labels of a column
	String	$FD,$16,$FC,$B,'Stick Right',$FD,'"',$0
	String	$FD,$16,$FC,$D,'Stick Left',$FD,'"'
	String	$FD,$16,$FC,$F,'Glove Right',$FD,'"',$0
	String	$FD,$16,$FC,$11,'Glove Left',$FD,'"'

LastFieldRow	;IDA: sub_9998E. d4 = last row index for column d6 (skater or goalie table)
	movem.l	d6/a0,-(sp)
	movea.l	#SkaterLastRows,a0
	tst.w	(CreateType).l
	bne.w	.0
	movea.l	#GoalieLastRows,a0
.0
	add.w	d6,d6
	move.w	(a0,d6.w),d4
	movem.l	(sp)+,d6/a0
	rts

SkaterLastRows	;IDA: unk_999B4. skater last row index per column
	dc.w	5,4,1,1

GoalieLastRows	;IDA: unk_999BC. goalie last row index per column
	dc.w	2,3,1,1

EditField	;IDA: sub_999C4. dispatch create-player edit: call handler [word_FF7530][word_FF7532] from table chosen by word_FF7534
	movea.l	#SkaterEditTbl,a0
	tst.w	(CreateType).l
	beq.w	.0
	movea.l	#GoalieEditTbl,a0
.0
	move.w	(CreateCursorX).l,d1
	asl.w	#2,d1
	movea.l	(a0,d1.w),a0
	move.w	(CreateCursorY).l,d1
	asl.w	#2,d1
	movea.l	(a0,d1.w),a0
	jsr	(a0)
	rts

SkaterEditTbl	;IDA: unk_999F6. create-player menu handler table (word_FF7534 == 0): rows by word_FF7530
	dc.l	EditRow1
	dc.l	EditRow2
	dc.l	EditRow3
	dc.l	EditRow4

EditRow1	;no IDA label. row 0 handlers by word_FF7532
	dc.l	EditAttrib1
	dc.l	EditAttrib2
	dc.l	EditAttrib3

EditRow2	;no IDA label. row 1 handlers
	dc.l	EditAttrib4
	dc.l	EditAttrib5
	dc.l	EditAttrib6
	dc.l	EditAttrib7

EditRow3	;no IDA label. row 2 handlers (shared)
	dc.l	EditPlayerType
	dc.l	EditNibble

EditRow4	;no IDA label. row 3 handlers (shared)
	dc.l	EditHand
	dc.l	EditJersey

GoalieEditTbl	;IDA: unk_99A32. handler table (word_FF7534 != 0)
	dc.l	EditRow5
	dc.l	EditRow6
	dc.l	EditRow3
	dc.l	EditRow4

EditRow5	;no IDA label. row 0 handlers
	dc.l	EditAttrib8
	dc.l	EditAttrib9
	dc.l	EditAttrib10
	dc.l	EditAttrib11
	dc.l	EditAttrib12
	dc.l	EditAttrib13

EditRow6	;no IDA label. row 1 handlers
	dc.l	EditAttrib14
	dc.l	EditAttrib15
	dc.l	EditAttrib16
	dc.l	EditAttrib17
	dc.l	EditAttrib18
	dc.l	EditNone

EditPlayerType	;no IDA label. toggle player type (word_FF7534) by d0, clamp 0..2, reset attribute record when changed
	add.w	(CreateType).l,d0
	bpl.w	.0
	move.w	#2,d0
.0
	cmp.w	#2,d0
	ble.w	.1
	clr.w	d0
.1
	move.w	(CreateType).l,d1
	tst.w	d1
	beq.w	.2
	tst.w	d0
	bne.w	.3
.2
	bsr.w	ClearAttribDeltas
	movea.l	#CreateRecord,a0
	move.b	d0,$1F(a0)
	jsr	(NewCreateRecord).l
	bsr.w	LoadCreateTemplate
	bsr.w	ClearCreateArea
	bsr.w	PrintCreateName
	move.w	d0,(CreateType).l
	bsr.w	SetPointsPool
.3
	move.w	d0,(CreateType).l
	movea.l	#CreateRecord,a0
	move.b	d0,$1F(a0)
	rts

EditAttrib1	;no IDA label. attribute handler: d4 = bit mask record, then common adjust
	move.l	(GAttribOverallMask+$16).l,d4

AdjustAttrib	;no IDA label. adjust attribute selected by d4 bit by d0, paying from points pool word_FF7536
	move.w	(CreatePoints).l,d1
	move.w	d1,(TempPlOffset).w
	move.w	d0,d2
	neg.w	d2
	add.w	d2,d1
	bmi.w	rtsAdjustAttrib
	move.w	d1,(CreatePoints).l
	movea.l	#AttribDeltas,a0
	swap	d4
.0
	btst	#$F,d4
	bne.w	.1
	addq.w	#1,a0
	asl.w	#1,d4
	bra.s	.0
.1
	tst.w	d0
	bpl.w	.2
	movem.w	d2-d3,-(sp)
	move.b	(a0),d2
	cmp.b	#0,d2
	movem.w	(sp)+,d2-d3
	ble.w	.3
.2
	add.b	d0,(a0)
	bra.w	rtsAdjustAttrib
.3
	move.w	(TempPlOffset).w,(CreatePoints).l

rtsAdjustAttrib	;no IDA label. 95 only. rts of AdjustAttrib
	rts

EditAttrib2	;no IDA label. attribute handler
	move.l	(GAttribOverallMask+$58).l,d4
	bra.s	AdjustAttrib

EditAttrib3	;no IDA label. attribute handler
	move.l	(GAttribOverallMask+$6E).l,d4
	bra.s	AdjustAttrib

EditNibble	;no IDA label. adjust high nibble of record byte 1 by d0 (0..15)
	movea.l	#CreateRecord,a0
	adda.w	(a0),a0
	clr.w	d1
	move.b	1(a0),d1
	lsr.w	#4,d1
	andi.w	#$F,d1
	add.w	d0,d1
	bmi.s	rtsAdjustAttrib
	cmp.w	#$F,d1
	bgt.s	rtsAdjustAttrib
	lsl.w	#4,d1
	move.b	1(a0),d0
	andi.w	#$F,d0
	or.w	d1,d0
	move.b	d0,1(a0)
	rts

EditAttrib4	;no IDA label. attribute handler
	move.l	(GAttribOverallMask+$84).l,d4
	bra.w	AdjustAttrib

EditAttrib5	;no IDA label. attribute handler
	move.l	(GAttribOverallMask+$9A).l,d4
	bra.w	AdjustAttrib

EditAttrib6	;no IDA label. attribute handler
	move.l	(GAttribOverallMask+$B0).l,d4
	bra.w	AdjustAttrib

EditAttrib7	;no IDA label. attribute handler
	move.l	(GAttribOverallMask+$C6).l,d4
	bra.w	AdjustAttrib

EditHand	;no IDA label. toggle bit 0 of record byte 4 (probably handedness)
	movea.l	#CreateRecord,a0
	adda.w	(a0),a0
	eori.b	#1,4(a0)
	rts

EditJersey	;no IDA label. adjust BCD jersey number in record byte 0 by d0, wrap 1..99
	movea.l	#CreateRecord,a0
	adda.w	(a0),a0
	clr.w	d1
	move.b	(a0),d1
	andi.w	#$F,d1
	clr.w	d2
	move.b	(a0),d2
	lsr.w	#4,d2
	mulu.w	#$A,d2
	add.w	d2,d1
	add.b	d1,d0
	bpl.w	.0
	move.w	#$63,d0
.0
	tst.b	d0
	bne.w	.1
	move.w	#$63,d0
.1
	cmp.b	#$63,d0
	ble.w	.2
	move.w	#1,d0
.2
	tst.b	d0
	bne.w	.3
	move.w	#1,d0
.3
	andi.l	#$FF,d0
	divu.w	#$A,d0
	move.w	d0,d1
	lsl.w	#4,d1
	swap	d0
	or.b	d0,d1
	move.b	d1,(a0)
	rts

EditAttrib8	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$42).l,d4
	bra.w	AdjustAttrib

EditAttrib9	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$2C).l,d4
	bra.w	AdjustAttrib

EditAttrib10	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$108).l,d4
	bra.w	AdjustAttrib

EditAttrib11	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$6E).l,d4
	bra.w	AdjustAttrib

EditAttrib12	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$84).l,d4
	bra.w	AdjustAttrib

EditAttrib13	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$DC).l,d4
	bra.w	AdjustAttrib

EditAttrib14	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$9A).l,d4
	bra.w	AdjustAttrib

EditAttrib15	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$B0).l,d4
	bra.w	AdjustAttrib

EditAttrib16	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$C6).l,d4
	bra.w	AdjustAttrib

EditAttrib17	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$11E).l,d4
	bra.w	AdjustAttrib

EditAttrib18	;no IDA label. attribute handler
	move.l	(PAttribOverallMask+$134).l,d4
	bra.w	AdjustAttrib

EditNone	;no IDA label. no-op handler
	rts

ClearAttribDeltas	;IDA: sub_99C7A. clear 16-byte attribute buffer at FFC42C
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#AttribDeltas,a0
	move.w	#3,d0
.0
	clr.l	(a0)+
	dbf	d0,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

LoadCreateTemplate	;IDA: sub_99C94. copy 32-word player template (index word_FF55FE) from $20B540 into byte record FF7538, set word_FF7534 from last byte
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$1F,d0
	movea.l	#$20B540,a0
	move.w	(CreateIndex).l,d1
	asl.w	#5,d1
	add.w	d1,d1
	adda.w	d1,a0
	movea.l	#CreateRecord,a1
.0
	move.w	(a0)+,d2
	move.b	d2,(a1)+
	dbf	d0,.0
	clr.w	(CreateType).l
	move.b	-1(a1),(CreateType+1).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearCreateArea	;no IDA label. print control string ($BF,0,5,0) then call sub_7C8CC with d0=$28,d1=$14,d2=$7FF (clear/draw a text area)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BF,0,5,0
	move.w	#$28,d0
	move.w	#$14,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SetPointsPool	;IDA: sub_99CF8. set points pool word_FF7536 to 300 (or 450 if word_FF7534 != 0)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$12C,(CreatePoints).l
	tst.w	(CreateType).l
	beq.w	.0
	move.w	#$1C2,(CreatePoints).l
.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CommitCreatedPlayer	;IDA: sub_99D1C. commit created player: store type bits, add attribute deltas into record via unk_99E06 handlers, save record via sub_98E6 and sub_9908
	movem.l	d0-d7/a0-a6,-(sp)
	movea.l	#$20BA44,a0
	move.w	(CreateWork).l,d0
	asl.w	#2,d0
	adda.w	d0,a0
	move.w	(a0),d0
	andi.w	#$1F,d0
	move.w	(CreateType).l,d1
	lsl.w	#5,d1
	or.w	d1,d0
	move.w	d0,(a0)
	movea.l	#CreateRecord,a0
	adda.w	(a0),a0
	movea.l	#AttribDeltas,a2
	move.w	#$F,d0
.0
	move.w	d0,d1
	lsr.w	#1,d1
	movem.l	d1/a0,-(sp)
	clr.w	d2
	clr.w	d3
	move.b	(a0,d1.w),d3
	move.b	(a2,d0.w),d2
	btst	#0,d0
	bne.w	.1
	lsr.w	#4,d3
.1
	andi.w	#$F,d3
	movea.l	#CommitAttribJumps,a1
	move.w	d0,d1
	asl.w	#2,d1
	movea.l	(a1,d1.w),a1
	jsr	(a1)
	movem.l	(sp)+,d1/a0
	move.b	(a0,d1.w),d2
	btst	#0,d0
	bne.w	.2
	andi.w	#$F,d2
	lsl.w	#4,d3
	andi.w	#$F0,d3
	bra.w	.3
.2
	andi.w	#$F0,d2
	andi.w	#$F,d3
.3
	or.w	d3,d2
	move.b	d2,(a0,d1.w)
	dbf	d0,.0
	movea.l	#CreateRecord,a0
	clr.l	d0
	move.w	(CreateIndex).l,d0
	asl.w	#5,d0
	addi.l	#$5AA0,d0
	moveq	#$20,d1
	jsr	(WriteSRAM).l
	movea.l	#CreateRecord,a0
	adda.w	(a0),a0
	clr.w	d6
	move.b	(a0),d6
	move.w	(CreateWork).l,d0
	ext.l	d0
	moveq	#$1C,d1
	asl.l	#5,d1
	add.l	d0,d1
	add.l	d1,d1
	movea.l	#$20AE00,a0
	move.w	d6,(a0,d1.l)
	jsr	(MakeSRAMChecksum).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CommitAttribJumps	;IDA: unk_99E06. jump table indexed by mode (16 entries)
	dc.l	CommitNone1
	dc.l	CommitNone1
	dc.l	CommitNone2
	dc.l	CrScale
	dc.l	CrScale
	dc.l	CrScale
	dc.l	CrScale
	dc.l	CrScale
	dc.l	CrScale
	dc.l	CrScaleEven
	dc.l	CrScaleTable
	dc.l	CrScale
	dc.l	CrScale
	dc.l	CrScale
	dc.l	CrScale
	dc.l	CrScale

CrScale	;no IDA label. d3 += d2/14 (signed)
	ext.l	d2
	divs.w	#$E,d2
	add.w	d2,d3
	rts

CommitNone1	;no IDA label. no-op
	rts

CommitNone2	;no IDA label. no-op
	rts

CrScaleEven	;no IDA label. scale even part of d3 via loc_99E46, keep low bit of d3
	move.w	d3,-(sp)
	andi.w	#$FE,d3
	jsr	(CrScale).l
	move.w	d3,d2
	move.w	(sp)+,d3
	andi.w	#1,d3
	andi.w	#$FE,d2
	or.w	d2,d3
	rts

CrScaleTable	;no IDA label. loc_99E46, then d3 = byte lookup in AttribScaleTable+$10[d3]
	bsr.s	CrScale
	movem.l	d0/a0,-(sp)
	movea.l	#AttribScaleTable+$10,a0
	move.b	d3,d0
	ext.w	d0
	move.b	(a0,d0.w),d3
	ext.w	d3
	movem.l	(sp)+,d0/a0
	rts

SignFreeAgents	;IDA: loc_99E8C. Sign Free Agents screen: draw, input loop
	jsr	(forceblack).l
	jsr	(TradeGfx).l
	jsr	(printz).l
	String	$FE,$9,$6,$0
	movea.l	#FreeAgentMap1,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$FE,$9,$15,$0
	movea.l	#FreeAgentMap2,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	jsr	(printbigz).l
	String	$BF,$7,$2,'Sign Free Agent'
	jsr	(printz2).l
	dc.w	$18;String length
	dc.b	$F9,$1,$FD,$7,$FC,$19,'A,B',$FD
	dc.b	$17,'C',$FD,$1F,'Start',$FA,$1,$0
	jsr	(printz2).l
	String	$FD,$3,'Switch Team',$FD,$12,'Sign Player',$FD,' Exit',$F9,$0
	move.w	#3,d0
	movea.l	#AttribDeltas,a0
.0
	clr.l	(a0)+
	dbf	d0,.0
.1
	clr.w	(TradeData+$C).l
.2
	clr.w	(TradeData).l
	bsr.w	FreeAgentTeamBlock
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w

FreeAgentRedraw	;IDA: loc_99F7E. 95 only. SignFreeAgents: redraw the lists
	jsr	(MarkSeasonRosters).l
	bsr.w	TestFreeAgents
	beq.w	FreeAgentsEmpty
	clr.w	(TradeData+$4).l
	move.w	($20BAAE).l,d0
	subq.b	#1,d0
.0
	andi.w	#$FF,d0
.1
	cmp.w	#5,d0
	ble.w	.3
.2
	move.w	#5,d0
.3
	move.w	d0,(TradeData+$6).l
	movea.l	#TradeRoster1,a0
	bsr.w	BuildFreeAgentList
.4
	bsr.w	rtsCreate4
	move.w	#$FFFF,(setupdir).w

FreeAgentLoop	;IDA: loc_99FC4. 95 only. SignFreeAgents: input loop
	bsr.w	FreeAgentTeamBlock
	bsr.w	DrawFreeAgents
	bsr.w	FreeAgentArrows
.0
	cmpi.w	#$FFFF,(setupdir).w
	beq.w	.1
	bsr.w	FreeAgentTeamBlock
	bsr.w	DrawFreeAgents
	bsr.w	FreeAgentArrows
.1
	move.w	#$FFFF,(setupdir).w
	bsr.w	ReadFreeAgentPads
	tst.w	d1
	beq.w	FreeAgentExit
	btst	#0,d1
	beq.w	.3
	tst.w	(TradeData).l
	beq.w	.2
	subq.w	#1,(TradeData).l
	bra.s	FreeAgentLoop
.2
	tst.w	(TradeData+$4).l
	beq.s	.1
	subq.w	#1,(TradeData+$4).l
	subq.w	#1,(TradeData+$6).l
	bra.s	FreeAgentLoop
.3
	btst	#1,d1
	beq.w	.5
	move.w	(TradeData).l,d0
	add.w	(TradeData+$4).l,d0
	cmp.w	(TradeData+$6).l,d0
	beq.w	.4
	addq.w	#1,(TradeData).l
	bra.w	FreeAgentLoop
.4
	move.w	($20BAAE).l,d0
	andi.w	#$FF,d0
	subq.w	#1,d0
	cmp.w	(TradeData+$6).l,d0
	ble.s	.1
	addq.w	#1,(TradeData+$4).l
	addq.w	#1,(TradeData+$6).l
	bra.w	FreeAgentLoop
.5
	btst	#4,d1
	beq.w	.6
	addq.w	#1,(TradeData+$C).l
	cmpi.w	#$1A,(TradeData+$C).l
	blt.w	FreeAgentLoop
	clr.w	(TradeData+$C).l
	bra.w	FreeAgentLoop
.6
	btst	#6,d1
	beq.w	.7
	subq.w	#1,(TradeData+$C).l
	bpl.w	FreeAgentLoop
	move.w	#$19,(TradeData+$C).l
	bra.w	FreeAgentLoop
.7
	btst	#7,d1
	bne.w	FreeAgentExit
	btst	#5,d1
	beq.w	.9
	move.w	(TradeData+$C).l,d7
	jsr	(GetPlayerCountD7).l
	cmp.w	#$19,d0
	beq.w	FreeAgentViolation
	movea.l	#TradeRoster1,a0
	move.w	(TradeData+$4).l,d0
	add.w	(TradeData).l,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	move.w	#$D,d2
	lsr.w	d2,d0
	andi.w	#3,d0
	asl.w	#2,d0
	movea.l	#PositionMaxChecks,a0
	movea.l	(a0,d0.w),a0
	jsr	(a0)
	beq.w	FreeAgentViolation
	movea.l	#TradeRoster2,a0
	move.w	(TradeData+$4).l,d0
	add.w	(TradeData).l,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	move.w	d0,(TempWord1).w
	move.w	#$1C,d7
	move.w	(TempWord1).w,d0
	jsr	(GetJerseyNumber).l
	move.b	(jerseynum).w,(TempWord1).w
	movea.l	#M68K_RAM,a2
	move.w	(TempWord1).w,-(sp)
	jsr	(DeleteCreatedPlayer).l
	move.w	(sp)+,(TempWord1).w
	move.w	(TradeData+$C).l,(TempMaxSpd).w
	move.w	(TempWord1).w,d0
	andi.w	#$FF,d0
	movea.l	#TradeRoster1,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	move.w	#$D,d2
	lsr.w	d2,d0
	andi.w	#3,d0
	move.w	d0,(PenBuf).w
	move.w	(TradeData+$C).l,d7
	asl.w	#2,d0
	movea.l	#PositionCountFns,a0
	movea.l	(a0,d0.w),a0
	jsr	(a0)
	move.w	(PenBuf).w,d1
	lsl.w	#8,d1
	or.w	d1,d0
	move.w	d0,(TempWord2).w
	move.w	(TradeData+$C).l,(TempMaxSpd).w
	movea.l	#M68K_RAM,a2
	move.w	(TempWord1).w,-(sp)
	move.w	(TempWord2).w,-(sp)
	move.w	(TempMaxSpd).w,-(sp)
	jsr	(RemoveTradedPlayer).l
	move.w	(sp)+,(TempMaxSpd).w
	move.w	(sp)+,(TempWord2).w
	move.w	(sp)+,(TempWord1).w
	jsr	(printz).l
	String	$BF,$B,$9,$0
	move.w	#$7FF,d2
	move.w	#$1C,d0
	move.w	#$B,d1
	jsr	(eraser).l
	tst.w	(TradeData).l
	beq.w	.8
	subq.w	#1,(TradeData).l
.8
	bra.w	FreeAgentRedraw
.9
	bra.w	.0

PositionCountFns	;IDA: unk_9A1FC. per-position rating routines
	dc.l	ReadAttributeNibbleD7
	dc.l	GetDefenseStartD7
	dc.l	GetPlayerCountD7

PositionMaxChecks	;IDA: unk_9A208. per-position check routines
	dc.l	CheckMaxGoalies
	dc.l	CheckMaxForwards
	dc.l	CheckMaxDefense

CheckMaxGoalies	;no IDA label. compare sub_7CB60 result with 3
	jsr	(ReadAttributeNibbleD7).l
	cmp.w	#3,d0
	rts

CheckMaxForwards	;no IDA label. compare sub_7CC08 result with $F
	jsr	(ProcessNibbleD7).l
	cmp.w	#$F,d0
	rts

CheckMaxDefense	;no IDA label. compare sub_83904 - sub_7CBB6 with $F
	jsr	(GetDefenseStartD7).l
	move.w	d0,-(sp)
	jsr	(GetPlayerCountD7).l
	sub.w	(sp)+,d0
	cmp.w	#$F,d0
	rts

FreeAgentArrows	;IDA: sub_9A242. draw scroll up/down arrows for the list
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz2).l
	String	$F9,$1
	move.w	(TradeData+$4).l,d0
	add.w	(TradeData).l,d0
	beq.w	.0
	jsr	(printz2).l
	String	$FD,$9,$FC,$9,'{',$0
	bra.w	.1
.0
	jsr	(printz2).l
	String	$FD,$9,$FC,$9,' ',$0
.1
	move.w	(TradeData).l,d1
	add.w	(TradeData+$4).l,d1
	move.w	($20BAAE).l,d0
	andi.w	#$FF,d0
	subq.w	#1,d0
	cmp.w	d0,d1
	bge.w	.2
	jsr	(printz2).l
	String	$FD,$9,$FC,$13,'}',$0
	bra.w	.3
.2
	jsr	(printz2).l
	String	$FD,$9,$FC,$13,' ',$0
.3
	jsr	(printz2).l
	String	$F9,$0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

FreeAgentViolation	;IDA: loc_9A2CE. show VIOLATION OF ROSTER RULES message, wait, erase
	jsr	(printz).l
	String	$BF,$5,$A,$0
	move.w	#$1F,d0
	move.w	#$E,d1
	jsr	(Framer).l
	jsr	(printz2).l
	String	$F9,$3,$FD,$7,$FC,$B,'VIOLATION OF ROSTER RULES',$0
	movea.l	#TradeRulesText,a1
	jsr	(printsmall).l
	bsr.w	ReadFreeAgentPads
	move.w	#$7FF,d2
	jsr	(printz).l
	String	$BF,$5,$A,$0
	move.w	#$1F,d0
	move.w	#$E,d1
	jsr	(eraser).l
	jsr	(printz2).l
	String	$F9,$0
	bra.w	FreeAgentLoop

FreeAgentTeamBlock	;IDA: sub_9A34C. draw team header (sub_9757C) for team word_FF271C
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(TradeData+$C).l,d1
	jsr	(printz).l
	String	$BF,$19,$15,$0
	jsr	(DrawTradeLogo).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawFreeAgents	;IDA: sub_9A36E. draw visible free agent rows (pos, name, rating)
	move.w	(TradeData).l,d5
	movea.l	#TradeData+$4,a5
	movea.l	#TradeRoster1,a4
	movea.l	#TradeRoster2,a3
	move.w	#9,(printy).w
	move.w	#$1C,d7
	move.w	(printy).w,-(sp)
	jsr	(printz).l
	String	$BF,$0,$0,$0
	move.w	(sp)+,(printy).w
	clr.w	d6
	move.w	(a5),d0
	asl.w	#1,d0
	ext.l	d0
	adda.l	d0,a4
	adda.l	d0,a3
.0
	jsr	(printz2).l
	String	$FD,$0,'                                       ',$0
	move.w	#$B,(printx).w
	jsr	(printz2).l
	String	$F9,$0
	cmp.w	d5,d6
	bne.w	.1
	jsr	(printz2).l
	String	$F9,$1
.1
	move.w	(a3)+,d0
	move.w	#$1C,d7
	jsr	(FormatPlayerNameD7).l
	jsr	(printsmall).l
	move.w	#$1C,(printx).w
	movea.l	#PositionLetters3,a1
	move.w	(a4),d0
	move.w	#$D,d2
	lsr.w	d2,d0
	andi.w	#3,d0
	move.w	d0,(PenBuf).w
	jsr	(PrintSmallListItem).l
	move.w	#$21,(printx).w
	move.w	(a4),d0
	jsr	(GetCreatedName).l
	adda.w	(a1),a1
	addq.w	#8,a1
	movea.l	a1,a0
	movem.l	a4,-(sp)
	movea.l	#FieldTextBuf,a4
	movea.l	#OvrGoalWgtList,a6
	move.l	(GAttribOverallMask).l,d4
	tst.w	(PenBuf).w
	beq.w	.2
	movea.l	#OvrPlayerWgtList,a6
	move.l	(PAttribOverallMask).l,d4
.2
	jsr	(CalcAttribRating).l
	movem.l	(sp)+,a4
	mulu.w	#$64,d0
	divu.w	d1,d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	addq.l	#2,a4
	addq.w	#2,(printy).w
	addq.w	#1,d6
	move.w	(TradeData+$4).l,d0
	add.w	d6,d0
	cmp.w	(TradeData+$6).l,d0
	ble.w	.0
	rts

PositionLetters3	;IDA: unk_9A4B0. position letters G/F/D
	String	'G',0
	String	'F',0
	String	'D',0

ReadFreeAgentPads	;IDA: sub_9A4BC. Wait for a joypad press (polls both pads via sub_7A4B0/sub_7A4C8 + sub_7A762 each frame); d1 = buttons
	move.l	#$5460,d6
.0
	move.w	#$64,d6
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.0
	move.w	(vcount).w,(oldvcount).w
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	bra.w	.3
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.3
.2
	dbf	d6,.0
.3
	rts

FreeAgentExit	;IDA: loc_9A508. Exit free-agent screen: set bit 6 of byte_FFD036, jump to loc_9ADA
	bset	#6,(setupcardflags).w
	jmp	Opening2

FreeAgentsEmpty	;IDA: loc_9A514. "Free agent list is now empty." message box, wait for a key, then exit
	clr.w	d0
	bra.w	FreeAgentMessage

FreeAgentMessage	;IDA: loc_9A51A. Show message box (string list unk_9A54A, index d0), wait for key, exit via loc_9A508
	move.w	d0,-(sp)
	jsr	(printz).l
	String	$BF,5,$A,0
	move.w	#$1F,d0
	move.w	#$E,d1
	jsr	(Framer).l
	move.w	(sp)+,d0
	movea.l	#FreeAgentMsgText,a1
	jsr	(PrintSmallListItem).l
	bsr.w	ReadFreeAgentPads
	bra.s	FreeAgentExit

FreeAgentMsgText	;IDA: unk_9A54A. Message string list for sub_7CB38
	String	$F9,3,$FD,6,$FC,$D,'Free agent list is now empty.',0
	rts

BuildFreeAgentList	;IDA: sub_9A572. Copy free-agent list at $20BA44 (count in $20BAAE) to work table $FFFF3A98 and index list $FFFF88B8
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	($20BAAE).l,d0
	andi.w	#$FF,d0
	subq.w	#1,d0
	movea.l	#$20BA44,a0
	movea.l	#TradeRoster1,a1
	movea.l	#TradeRoster2,a5
	clr.w	d6
.0
	move.l	(a0)+,d1
	move.b	d1,d2
	andi.w	#$FF,d2
	swap	d1
	lsl.w	#8,d1
	or.w	d1,d2
	move.w	d2,(a1)+
	move.w	d6,(a5)+
	addq.w	#1,d6
	dbf	d0,.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

rtsCreate4	;IDA: nullsub_4. Empty routine
	rts

TestFreeAgents	;IDA: sub_9A5B6. Test free-agent count byte ($20BAAE+1), flags only, d0 preserved
	movem.w	d0,-(sp)
	move.w	($20BAAE).l,d0
	tst.b	d0
	movem.w	(sp)+,d0
	rts

ReleasePlayers	;IDA: loc_9A5C8. Release Player screen: up/down scroll roster, switch team, release highlighted player to the free-agent list (exits if list full)
	jsr	(forceblack).l
	jsr	(TradeGfx).l
	jsr	(printbigz).l
	String	$BF,7,2,'Release Player',0
	jsr	(printz2).l
	String	$F9,1,$FD,6,$FC,$19,'A,B',$FD,$16,'C',$FD,' Start',$FA,1,0
	jsr	(printz2).l
	String	$FD,2,'Switch Team',$FD,$10,'Release Player',$FD,'!Exit',$F9,0,0
	jsr	(printz2).l
	String	$F9,2,$FD,$1B,$FC,7,'POS.',$FD,' RTG.',$F9,0
	clr.w	(TradeData+$C).l
	clr.w	(TradeData).l
	move.w	#0,(HomeTeam).w
	move.w	#0,(VisTeam).w
	jsr	(clearTeamStats).l
	bsr.w	ReleaseTeamBlock
	move.w	#$18,(palcount).w
	bclr	#2,(disflags).w

ReleaseRedraw	;IDA: loc_9A682. 95 only. ReleasePlayers: redraw the roster
	move.w	($20BAAE).l,d0
	andi.w	#$FF,d0
	cmp.w	#$1A,d0
	bge.w	FreeAgentsFull
	clr.w	(TradeData+$4).l
	move.w	(TradeData+$C).l,d7
	move.w	d7,(HomeTeam).w
	move.w	d7,(VisTeam).w
	jsr	(clearTeamStats).l
	jsr	(GetPlayerCountD7).l
	subq.w	#1,d0
	cmp.w	#5,d0
	ble.w	.0
	move.w	#5,d0
.0
	move.w	d0,(TradeData+$6).l
	movea.l	#TradeRoster1,a0
	movea.l	#TradeWork,a1
	bsr.w	DrawTradeTeam
	bsr.w	rtsCreate5
	move.w	#$FFFF,(setupdir).w

ReleaseLoop	;IDA: loc_9A6E2. 95 only. ReleasePlayers: input loop
	bsr.w	ReleaseTeamBlock
	bsr.w	DrawReleaseRoster
	bsr.w	ReleaseArrows
.0
	cmpi.w	#$FFFF,(setupdir).w
	beq.w	.1
	bsr.w	ReleaseTeamBlock
	bsr.w	DrawReleaseRoster
.1
	move.w	#$FFFF,(setupdir).w
	bsr.w	ReadReleasePads
	tst.w	d1
	beq.w	ReleaseExit
	btst	#0,d1
	beq.w	.3
	tst.w	(TradeData).l
	beq.w	.2
	subq.w	#1,(TradeData).l
	bra.s	ReleaseLoop
.2
	tst.w	(TradeData+$4).l
	beq.s	.1
	subq.w	#1,(TradeData+$4).l
	subq.w	#1,(TradeData+$6).l
	bra.s	ReleaseLoop
.3
	btst	#1,d1
	beq.w	.5
	move.w	(TradeData).l,d0
	add.w	(TradeData+$4).l,d0
	cmp.w	(TradeData+$6).l,d0
	beq.w	.4
	addq.w	#1,(TradeData).l
	bra.w	ReleaseLoop
.4
	move.w	(TradeData+$C).l,d7
	jsr	(GetPlayerCountD7).l
	subq.w	#1,d0
	cmp.w	(TradeData+$6).l,d0
	ble.s	.1
	addq.w	#1,(TradeData+$4).l
	addq.w	#1,(TradeData+$6).l
	bra.w	ReleaseLoop
.5
	btst	#4,d1
	beq.w	.6
	clr.w	(TradeData).l
	clr.w	(TradeData+$4).l
	move.w	#5,(TradeData+$6).l
	addq.w	#1,(TradeData+$C).l
	cmpi.w	#$1A,(TradeData+$C).l
	blt.w	ReleaseRedraw
	clr.w	(TradeData+$C).l
	bra.w	ReleaseRedraw
.6
	btst	#6,d1
	beq.w	.7
	clr.w	(TradeData).l
	clr.w	(TradeData+$4).l
	move.w	#5,(TradeData+$6).l
	subq.w	#1,(TradeData+$C).l
	bpl.w	ReleaseRedraw
	move.w	#$19,(TradeData+$C).l
	bra.w	ReleaseRedraw
.7
	btst	#7,d1
	bne.w	ReleaseExit
	btst	#5,d1
	beq.w	.16
	move.w	(TradeData+$C).l,d7
	jsr	(GetPlayerCountD7).l
	cmp.w	#$11,d0
	beq.w	ReleaseViolation
	movea.l	#TradeRoster1,a0
	move.w	(TradeData+$4).l,d0
	add.w	(TradeData).l,d0
	asl.w	#2,d0
	adda.w	d0,a0
	clr.w	d0
	move.b	1(a0),d0
	asl.w	#2,d0
	movea.l	#PositionMinChecks,a0
	movea.l	(a0,d0.w),a0
	jsr	(a0)
	beq.w	ReleaseViolation
	movea.l	#TradeRoster1,a0
	move.w	(TradeData+$4).l,d0
	add.w	(TradeData).l,d0
	asl.w	#2,d0
	adda.w	d0,a0
	move.b	1(a0),(TempWord1).w
	move.b	2(a0),(TempWord1+1).w
	move.w	(TradeData+$C).l,(TempRawSpd).w
	movea.l	#M68K_RAM,a2
	jsr	(MoveTradedPlayer).l
	move.w	(TradeData+$C).l,(tradeteam1).w
	move.w	(TradeData+$C).l,(tradeteam2).w
	jsr	(CheckSavedLines).l
	movea.l	#$20BA44,a0
	clr.w	(rosterscroll).w
.8
	tst.b	1(a0)
	bmi.w	.9
	addq.l	#4,a0
	addq.w	#1,(rosterscroll).w
	bra.s	.8
.9
	move.w	(M68K_RAM).l,d0
	andi.w	#$1FFF,d0
	move.b	(TempWord1).w,d1
	andi.w	#3,d1
	move.w	#$D,d2
	lsl.w	d2,d1
	or.w	d1,d0
	move.w	d0,d1
	lsr.w	#8,d1
	andi.w	#$FF,d1
	move.w	d1,(a0)
	andi.w	#$FF,d0
	move.w	d0,2(a0)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$1A,d7
	jsr	(ReadTeamPlayerStats).l
	movea.l	#StatBuf,a3
	movea.l	#$FFFF0004,a2
.10
	move.w	#4,d6
.11
	move.w	(rosterscroll).w,d0
	andi.w	#$FF,d0
	add.w	d0,d0
	move.w	#$34,d3
	bra.w	.13
.12
	move.w	-2(a3,d3.w),d1
	move.w	d1,(a3,d3.w)
.13
	subq.w	#2,d3
	cmp.w	d0,d3
	ble.w	.14
	bra.s	.12
.14
	move.w	(a2)+,d1
	move.w	d1,(a3,d3.w)
	adda.w	#$34,a3
	dbf	d6,.11
	jsr	(WriteTeamPlayerStats).l
	movem.l	(sp)+,d0-d7/a0-a6
	movea.l	#$20B500,a0
	move.w	(rosterscroll).w,d0
	add.w	d0,d0
	adda.w	d0,a0
	move.w	(M68K_RAM+2).l,d1
	move.w	d1,(a0)
	addq.w	#1,($20BAAE).l
	jsr	(MakeSRAMChecksum).l
	jsr	(printz).l
	String	$BF,$B,9,0
	move.w	#$7FF,d2
	move.w	#$1C,d0
	move.w	#6,d1
	jsr	(eraser).l
	tst.w	(TradeData).l
	beq.w	.15
	subq.w	#1,(TradeData).l
.15
	bra.w	ReleaseRedraw
.16
	bra.w	.0
	dc.l	ReadAttributeNibbleD7,GetDefenseStartD7,GetPlayerCountD7;unused pointers

PositionMinChecks	;IDA: unk_9A99A. Roster-minimum check per position code (0 G, 1 F, 2 D); Z set = cannot release
	dc.l	CheckMinGoalies,CheckMinForwards,CheckMinDefense

CheckMinGoalies	;no IDA label. Position 0 (G): count from sub_7CB60, Z if == 2
	jsr	(ReadAttributeNibbleD7).l
	cmp.w	#2,d0
	rts

CheckMinForwards	;no IDA label. Position 1 (F): count from sub_7CC08, Z if == 9
	jsr	(ProcessNibbleD7).l
	cmp.w	#9,d0
	rts

CheckMinDefense	;no IDA label. Position 2 (D): sub_83904 roster size minus sub_7CBB6 count, Z if == 6
	jsr	(GetDefenseStartD7).l
	move.w	d0,-(sp)
	jsr	(GetPlayerCountD7).l
	sub.w	(sp)+,d0
	cmp.w	#6,d0
	rts

ReleaseArrows	;IDA: sub_9A9D4. Draw scroll arrows ({ above / } below) beside the roster list
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz2).l
	String	$F9,1
	move.w	(TradeData+$4).l,d0
	add.w	(TradeData).l,d0
	beq.w	.0
	jsr	(printz2).l
	String	$FD,9,$FC,9,'{',0
	bra.w	.1
.0
	jsr	(printz2).l
	String	$FD,9,$FC,9,' ',0
.1
	move.w	(TradeData).l,d1
	add.w	(TradeData+$4).l,d1
	move.w	(TradeData+$C).l,d7
	jsr	(GetPlayerCountD7).l
	subq.w	#1,d0
	cmp.w	d0,d1
	bge.w	.2
	jsr	(printz2).l
	String	$FD,9,$FC,$15,'}',0
	bra.w	.3
.2
	jsr	(printz2).l
	String	$FD,9,$FC,$15,' ',0
.3
	jsr	(printz2).l
	String	$F9,0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ReleaseViolation	;IDA: loc_9AA62. "VIOLATION OF ROSTER RULES" message box, wait for key, close it, back to the screen loop
	jsr	(printz).l
	String	$BF,5,$A,0
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(Framer).l
	jsr	(printz2).l
	String	$F9,3,$FD,7,$FC,$B,'VIOLATION OF ROSTER RULES',0
	movea.l	#TradeRulesText,a1
	jsr	(printsmall).l
	bsr.w	ReadReleasePads
	move.w	#$7FF,d2
	jsr	(printz).l
	String	$BF,5,$A,0
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(eraser).l
	jsr	(printz2).l
	String	$F9,0
	bra.w	ReleaseLoop

ReleaseTeamBlock	;IDA: sub_9AAE0. Print team block for team word_FF271C (sub_9757C)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(TradeData+$C).l,d1
	jsr	(printz).l
	String	$BF,$B,6,0
	jsr	(DrawTradeLogo).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawReleaseRoster	;IDA: sub_9AB02. Draw the visible roster rows (pos letter, name, rating) with highlight on cursor row
	move.w	(TradeData).l,d5
	movea.l	#TradeData+$4,a5
	movea.l	#TradeRoster1,a4
	move.w	#9,(printy).w
	move.w	(TradeData+$C).l,d7
	move.w	(printy).w,-(sp)
	jsr	(printz).l
	String	$BF,0,0,0
	move.w	(sp)+,(printy).w
	clr.w	d6
	move.w	(a5),d0
	asl.w	#2,d0
	ext.l	d0
	adda.l	d0,a4
.0
	jsr	(printz2).l
	String	$FD,0,'                                       ',0
	move.w	#$B,(printx).w
	jsr	(printz2).l
	String	$F9,0
	cmp.w	d5,d6
	bne.w	.1
	jsr	(printz2).l
	String	$F9,1
.1
	clr.w	d0
	move.b	2(a4),d0
	jsr	(FormatPlayerNameD7).l
	jsr	(printsmall).l
	move.w	#$1C,(printx).w
	movea.l	#PositionLetters4,a1
	clr.w	d0
	move.b	1(a4),d0
	move.w	d0,(PenBuf).w
	jsr	(PrintSmallListItem).l
	move.w	#$21,(printx).w
	clr.w	d0
	move.b	3(a4),d0
	move.w	#2,d1
	jsr	(PushNumberWidth).l
	jsr	(printsmall).l
	addq.l	#4,a4
	addq.w	#2,(printy).w
	addq.w	#1,d6
	move.w	(TradeData+$4).l,d0
	add.w	d6,d0
	cmp.w	(TradeData+$6).l,d0
	ble.w	.0
	rts

PositionLetters4	;IDA: unk_9ABF6. Position letter strings G/F/D for sub_7CB38
	String	'G',0
	String	'F',0
	String	'D',0

ReadReleasePads	;IDA: sub_9AC02. Wait for a joypad press on any of up to 4 pads (4-way play if word_FFCC4A); d1 = buttons
	move.l	#$5460,d6
.0
	move.w	#$64,d6
	move.w	(vcount).w,d1
	sub.w	(oldvcount).w,d1
	beq.s	.0
	move.w	(vcount).w,(oldvcount).w
	jsr	(ReadJoy1).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.1
	bra.w	.5
.1
	jsr	(ReadJoy2).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.2
	bra.w	.5
.2
	tst.w	(FourWayPlay).w
	beq.w	.4
	jsr	(ReadJoy3).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.3
	bra.w	.5
.3
	jsr	(ReadJoy4).l
	jsr	(ProcessInputWithRepeat).l
	tst.w	d1
	beq.w	.4
	bra.w	.5
.4
	dbf	d6,.0
.5
	rts

ReleaseExit	;IDA: loc_9AC82. Exit Release Player screen: set bit 6 of byte_FFD036, jump to loc_9ADA
	bset	#6,(setupcardflags).w
	jmp	Opening2

FreeAgentsFull	;IDA: loc_9AC8E. "Free agent list is full." message box, wait for key, then exit
	clr.w	d0
	bra.w	ReleaseMessage

ReleaseMessage	;IDA: loc_9AC94. Show message box (string list unk_9ACC4, index d0), wait for key, exit via loc_9AC82
	move.w	d0,-(sp)
	jsr	(printz).l
	String	$BF,5,$A,0
	move.w	#$1E,d0
	move.w	#$E,d1
	jsr	(Framer).l
	move.w	(sp)+,d0
	movea.l	#ReleaseMsgText,a1
	jsr	(PrintSmallListItem).l
	bsr.w	ReadReleasePads
	bra.s	ReleaseExit

ReleaseMsgText	;IDA: unk_9ACC4. Message string list for sub_7CB38
	String	$F9,3,$FD,6,$FC,$D,'Free agent list is full.'

rtsCreate5	;IDA: nullsub_5. Empty routine
	rts
