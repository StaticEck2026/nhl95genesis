;	NHL 95 setup95_02. Retail $087BA2-$088045 (1188 bytes).
;	94 setup94 PlayoffScreen, HandlePlayoffInput, UpdatePlayoffScroll, PlayoffScreenExit, PlayoffScreen_waitvsync, FormatScore,
;	DrawPlayoffBracket, DrawTeamBlocks, PlayoffScreenDataTable and PlayoffScreenText. checks95_04 follows at $088046 (PlayoffTreeSetup).
;	IDA code except PlayoffScreenDataTable (dc.b, read from the retail bytes). IDA hid the printz / printz2 Strings and the
;	DecompressGraphicsWithCallback remap bytes as instructions; they are String / dc.b here. Local labels are numbered; the IDA local
;	names are not kept.
;	95 changes: PlayoffScreen returns at once in Shootout (gmode2 bit 0) and also runs for sflags11 bit 2; the shared rts is
;	rtsLineData (data95_01, 94 rtss2). AddTeamBlock and AddSmallFont are inline, the title uses printbig with the BigFontMap2
;	tiles, HandlePlayoffInput reads all four pads, the song is 3 (94 $79), the map chars start at $69A (94 $30A).
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.


PlayoffScreen	;IDA: sub_87BA2. Bring up the playoff screen if in playoff mode (not Shootout; OptPlayMode nonzero or sflags11 bit 2).
	;Called from GameOver and Opening2 (setup95_01). Runs its own vblank (PlayoffScreenDataTable) and scrolls the tree a page ($70
	;pixels) at a time. Returns when start is pressed (PlayoffScreenExit)
	btst	#0,(gmode2).w
	bne.s	rtsLineData
	btst	#2,(sflags11).w
	bne.w	.0
	tst.w	(OptPlayMode).w
	beq.s	rtsLineData
.0
	move.l	#PlayoffScreenDataTable,(vbint).l
	bclr	#1,(disflags).w
	move.w	#0,(VSCRLPM).w
	move.w	#$BC00,(VSPRITES).w
	move.w	#$B000,(VmMap3).w
	move.w	#6,(Map3col1).w
	move.w	#$C000,(VmMap2).w
	move.w	#7,(Map2col1).w
	move.w	#$E000,(VmMap1).w
	move.w	#7,(Map1col1).w
	move.w	#0,d0
	jsr	(setvram).l
	jsr	(printz).l
	String	$FF,0,0,0
	move.l	#$80,d0
	moveq	#$1C,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$FD,0,0,0
	moveq	#$28,d0
	moveq	#2,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	#1,d4	;94 AddTeamBlock: the team block tiles from char 1
	move.w	d4,(teamblocksmapptr).w
	movea.l	#Teamblocksmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.l	#SmallFontMap,(smallfontptr).l	;94 AddSmallFont
	move.w	d4,(smallfontchars).w
	movea.l	(smallfontptr).w,a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$EF	;remap table
	move.w	d4,(BigFontChars).w
	movea.l	#BigFontMap2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	movea.l	#Arrowsmap+8,a2
	move.w	d4,(ExtraChars).w
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(printz).l
	String	$CE,0,0,0
	movea.l	#ScoutMap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#3,d5
	jsr	(dobitmap).l
	movea.l	#PlayoffSprite,a1
	lea	8(a1),a2
	adda.l	(a1),a1
	moveq	#7,d0
	movea.w	#(palfadenew+$40-M68K_RAM),a0
.1
	move.l	-$40(a0),$20(a0)
	move.l	(a1)+,-$40(a0)
	move.l	-$20(a0),(a0)+
	dbf	d0,.1
	move.w	d4,(energybarchars).w
	jsr	(DoDMA_clearCallbackPointer).l
	clr.w	(pausetimeout).w
	clr.w	(picturebits).w
	move.w	#$104,(clampcounter).w
	move.w	#$A0,(playoffspritey).w
	movea.l	#VDP_CTRL,a0
	move.w	#$9202,(a0)
	movea.w	#(potree-M68K_RAM),a1
	movea.l	#PlayoffTreeSetup,a0	;playoff tree layout by gamelevel
	move.w	(gamelevel).w,d0
	asl.w	#1,d0
	adda.w	(a0,d0.w),a0
	clr.w	d4
	move.b	(a0)+,d4
.2
	jsr	(printz).l
	String	$FF,0,0,0
	move.b	(a0)+,(printx+1).w
	move.b	(a0)+,(printy+1).w
	clr.w	d1
	move.b	(a1)+,d1
	add.w	d1,d1
	jsr	(DrawTeamBlocks).l
	dbf	d4,.2
	clr.w	d4
	move.b	(a0)+,d4
.3
	jsr	(printz).l
	String	$FF,0,2,0
	move.b	(a0)+,(printx+1).w
	clr.w	d0
	move.b	(a0)+,d0
	jsr	(DrawPlayoffBracket).l
	dbf	d4,.3
	jsr	(printz).l
	String	$EF,0,0,0
	cmpi.w	#7,(bosgames).w	;best of 7
	beq.w	.5
	clr.w	d4
	move.b	(a0)+,d4
	bmi.w	.5
	movea.w	#(gsstruct-M68K_RAM),a2
.4
	move.b	(a0)+,(printx+1).w
	move.b	(a0)+,(printy+1).w
	jsr	(printz2).l
	String	$FE,3
	jsr	(FormatScore).l
	adda.w	#$10,a2
	dbf	d4,.4
.5
	jsr	(printz2).l
	String	$F8,0,1,$41,1,0
	lea	PlayoffScreenText(pc),a1
	move.w	(gamelevel).w,d0
	jsr	(SkipStrings).l
	jsr	(printbig).l
	tst.w	(gamelevel).w
	beq.w	.6
	jsr	(printz).l
	String	$CD,$A,1,'Press [ or ] to page'
.6
	move.w	#$18,(palcount).w
	move.w	#3,-(sp)
	jsr	(song).l
	clr.w	d0
	clr.w	d4
	move.w	#$FFFF,(PlayerScrollCtr).w
	move.w	#1,(DispAttribCtr).w
	jsr	(UpdatePlayoffScroll).l
.7
	jsr	(PlayoffScreen_waitvsync).l
	movea.l	#rtss2,a0
	jsr	(DrawPlayoffSprite).l
	jsr	(HandlePlayoffInput).l
	bra.s	.7

HandlePlayoffInput	;IDA: sub_87E34. 93 name. Read the four pads: start leaves PlayoffScreen (PlayoffScreenExit), right / left set the
	;scroll step, then falls into UpdatePlayoffScroll
	jsr	(ReadJoy1).l
	move.w	d3,-(sp)
	jsr	(ReadJoy2).l
	or.w	d3,(sp)
	jsr	(ReadJoy3).l
	or.w	d3,(sp)
	jsr	(ReadJoy4).l
	or.w	(sp)+,d3
	btst	#7,d3
	bne.w	PlayoffScreenExit
	btst	#3,d3
	beq.w	.0
	move.w	#$FFFE,(PlayerScrollCtr).w
.0
	btst	#2,d3
	beq.w	UpdatePlayoffScroll
	move.w	#2,(PlayerScrollCtr).w

UpdatePlayoffScroll	;IDA: sub_87E78. 93 name. Move the tree one step (PlayerScrollCtr) and stop on a page boundary ($70). The
	;position is DispAttribCtr; playoffspritex is the sprite x offset while it is on screen
	move.w	(PlayerScrollCtr).w,d0
	beq.w	rtsLineData
	add.w	(DispAttribCtr).w,d0
	move.w	(gamelevel).w,d1
	cmp.w	#3,d1
	bls.w	.0
	moveq	#3,d1
.0
	mulu.w	#$70,d1
	cmp.w	d1,d0
	bgt.w	rtsLineData
	neg.w	d1
	cmp.w	d1,d0
	blt.w	rtsLineData
	move.w	d0,(DispAttribCtr).w
	clr.w	(playoffspritex).w
	move.w	d0,d1
	addi.w	#$100,d1
	cmp.w	#$40,d1
	blt.w	.1
	cmp.w	#$200,d1
	bgt.w	.1
	move.w	d1,(playoffspritex).w
.1
	ext.l	d0
	divs.w	#$70,d0
	swap	d0
	tst.w	d0
	bne.w	rtsLineData
	clr.w	(PlayerScrollCtr).w
	rts

PlayoffScreenExit	;IDA: loc_87EDA. 93 name. Drop HandlePlayoffInput's return address and return from PlayoffScreen
	addq.w	#4,sp
	rts

PlayoffScreen_waitvsync	;IDA: sub_87EDE. 93 name. Each time palcount runs out, eor the color word at palfadenew+$42 with $EE and
	;restart palcount at $18; then wait for the next vblank
	tst.w	(palcount).w
	bpl.w	.0
	eori.w	#$EE,(palfadenew+$42).w
	move.w	#$18,(palcount).w
.0
	move.w	(vcount).w,d0
	cmp.w	(oldvcount).w,d0
	beq.s	.0
	move.w	d0,(oldvcount).w
	rts

FormatScore	;IDA: sub_87F02. 93 name. Print best of 7 wins "t-b" for game struct a2 at printx / printy
	movea.w	#(mesarea-M68K_RAM),a1
	move.w	#6,(a1)+
	move.w	4(a2),d0
	addi.w	#$30,d0
	move.b	d0,(a1)+
	move.b	#$2D,(a1)+
	move.w	6(a2),d0
	addi.w	#$30,d0
	move.b	d0,(a1)+
	clr.b	(a1)+
	movea.w	#(mesarea-M68K_RAM),a1
	jmp	print

DrawPlayoffBracket	;IDA: sub_87F2E. 93 name. Draw tree arrow d0 from the arrows map (Arrowsmap) at printx / printy
	movem.l	d0-d7/a0-a3,-(sp)
	movea.l	#Arrowsmap,a0
	movea.l	a0,a1
	adda.l	(a0),a0
	adda.l	4(a1),a1
	movea.w	#$69A,a2	;a zero long (main95 $69A): no palettes
	clr.w	d1
	moveq	#2,d2
	moveq	#$17,d3
	move.w	(ExtraChars).w,d4
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a3
	rts

DrawTeamBlocks	;IDA: sub_87F5C. 93 name. Draw team block d1 (team * 2) from Teamblocksmap at printx / printy; the user's team
	;(potreeteam entry of potree) is highlighted (printa $6000) unless sflags11 bit 2 is set
	movem.l	d0-d7/a0-a3,-(sp)
	movea.w	#(potree-M68K_RAM),a0
	move.w	(potreeteam).w,d0
	move.b	(a0,d0.w),d0
	add.b	d0,d0
	cmp.b	d0,d1
	bne.w	.0
	btst	#2,(sflags11).w
	bne.w	.0
	move.w	#$6000,(printa).w
.0
	movea.l	#Teamblocksmap,a1
	adda.l	4(a1),a1
	movea.w	#$69A,a2	;a zero long (main95 $69A): no palettes
	clr.w	d0
	move.w	(a1),d2
	moveq	#2,d3
	move.w	(teamblocksmapptr).w,d4	;the team block chars (set by PlayoffScreen)
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a3
	rts

PlayoffScreenDataTable	;IDA: unk_87FAA, dc.b. 93 name. The PlayoffScreen vblank handler (vbint): dma the sprite table, write
	;$FEA0+DispAttribCtr to the hscroll, cramfade. Always vcount+1, p_music_vblank, rte
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#2,(disflags).w
	bne.w	.1
	movea.w	#(Satt-M68K_RAM),a0
	move.w	(Sattsize).w,d0
	beq.w	.0
	clr.w	(Sattsize).w
	move.w	(VSPRITES).w,d1
	jsr	(DoDMA).l
	move.w	(VSCRLPM).w,d0
	jsr	(Vmaddr).l
	move.w	#$FEA0,d0
	add.w	(DispAttribCtr).w,d0
	move.w	d0,(a0)
.0
	jsr	(cramfade).l
.1
	addq.w	#1,(vcount).w
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte

PlayoffScreenText	;IDA: unk_87FFC. 93 name. Round titles by gamelevel, printbig Strings with their position
	String	$CF,$39,$19,'Playoffs'
	String	$CF,$33,$19,'Quarterfinals'
	String	$CF,$37,$19,'Semifinals'
	String	$CF,$3B,$19,'Finals'
	String	$CF,$37,$19,'Champions'
