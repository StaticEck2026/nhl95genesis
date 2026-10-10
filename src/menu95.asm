; $07E4D6  Adapted from menu94.asm: menu core
;	NHL 95 segment $7E4D6-$7F97D, from lst/nhl95.bin.lst. The 95 pause menu: hockey94 seta2, menu94 InitMenuState / DrawMenuScreen /
;	HandleMenuInput (95: three tabs, INFO / STATS / PAUSE, each with item lists by game mode), the hockey94 startpause entries, the 95
;	PauseScreenDraw and its penalty boxes, RestoreGameScreen (after the pause), menu94 SetMenuPrintX / UpdateMenuSelection / PrintMenuItem,
;	the 95 info page, penalty messages and tabs, then the item lists (InfoMenus, StatsMenus, PauseMenus) and their AbortGame / PlayGame.
;	checks95_01 (94 ManualGoalieMenu) follows at $7F97E.
;	IDA dc.b written as instructions: PauseScreenDraw ($7E816-$7EAC7), ListPenaltyBox, MenuInfoList ... PrintLines, a second rts ($7F366),
;	the item lists and AbortGame / PlayGame ($7F368-$7F97D). IDA hid the printz / printz2 Strings as instructions; they are String here (the
;	40 byte menu box String as dc.w / dc.b, the String macro takes 15 values).
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi; fixopcodes.js patches the
;	cmp encoding after assembly.
seta2	;IDA: sub_7E4D6 (hockey94). Set a2 to the team struct of the pause pad (menupadnum: cont1team ... cont4team). Called from Pausemode and
	;HandleMenuInput
	movea.l	#HmShots,a2
	tst.w	(menupadnum).w
	beq.w	.2
	cmpi.w	#1,(menupadnum).w
	beq.w	.1
	cmpi.w	#2,(menupadnum).w
	beq.w	.0
	cmpi.w	#1,(cont4team).w
	bra.w	.3
.0
	cmpi.w	#1,(cont3team).w
	bra.w	.3
.1
	cmpi.w	#1,(cont2team).w
	bra.w	.3
.2
	cmpi.w	#1,(cont1team).w
.3
	beq.w	.4
	adda.w	#tmsize,a2
.4
	rts

InitMenuState	;IDA: sub_7E526. 93 name. Start a menu: a0 = item list, a1 = screen draw routine; selection and first shown item 0. Falls into
	;DrawMenuScreen. Called from Pausemode
	move.l	a0,(menulist).w
	move.l	a1,(menudraw).w
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w

DrawMenuScreen	;IDA: loc_7E536. 93 name. Call the draw routine, clear the menu box, print the items (UpdateMenuSelection) and fade in
	movea.l	(menudraw).w,a0
	jsr	(a0)
	bsr.w	ClearMenuBox
RedrawMenu	;95 only, no IDA label. Print the menu items and fade in. Called from the checks95_01 menu items after they clear the box
	jsr	(printz2).l
	String	$FE,4,$FC,$C
	jsr	(SetMenuPrintX).l
	jsr	(UpdateMenuSelection).l
	move.w	#$18,(palcount).w
	rts

HandleMenuInput	;IDA: sub_7E560. 93 name. Pause menu pad d1: right / left move between the three tabs (menucursor: INFO, STATS, PAUSE; SetInfoMenuItems ...),
	;down / up the item, C (bit 5) runs the item routine (seta2 first); ne = stay in the menu (PlayGame sets sflags9 bit 3 to leave). With
	;sflags9 bit 5 only ShowPenaltyMessages runs
	btst	#7,d1
	bne.w	.11
	btst	#5,(sflags9).w
	beq.w	.0
	bsr.w	ShowPenaltyMessages
	bra.w	.11
.0
	btst	#3,d1
	beq.w	.2
	addq.w	#1,(menucursor).w
	cmpi.w	#3,(menucursor).w
	blt.w	.1
	clr.w	(menucursor).w
.1
	bra.w	.12
.2
	btst	#2,d1
	beq.w	.4
	subq.w	#1,(menucursor).w
	bpl.w	.3
	move.w	#2,(menucursor).w
.3
	bra.w	.12
.4
	btst	#1,d1
	beq.w	.5
	addq.w	#1,(menuitem).w
	bra.w	UpdateMenuSelection
.5
	btst	#0,d1
	beq.w	.6
	subq.w	#1,(menuitem).w
	bra.w	UpdateMenuSelection
.6
	btst	#5,d1
	bne.w	.7
	beq.w	.11
.7
	cmpi.l	#$69A,(menulist).w
	beq.w	.11
	bsr.w	seta2
	move.w	(menuitem).w,d0
	movea.l	(menulist).w,a0
	adda.l	(menuitemoffset).w,a0
	adda.w	(a0),a0
	adda.w	(a0),a0
	cmpi.l	#$4FF00,(a0)	;the $FF String: no items
	beq.w	.10
	bra.w	.9
.8
	addq.w	#4,a0
.9
	adda.w	(a0),a0
	dbf	d0,.8
	movea.l	(a0),a0
	bclr	#3,(sflags9).w
	move.b	(sflags12).w,-(sp)
	bclr	#0,(sflags12).w
	jsr	(a0)
	move.b	(sp)+,(sflags12).w
	btst	#3,(sflags9).w
	eori	#4,ccr
.10
	rts
.11
	eori	#4,ccr
	rts
.12
	tst.w	(menucursor).w
	beq.w	.14
	cmpi.w	#1,(menucursor).w
	beq.w	.13
	cmpi.l	#PauseMenus,(menulist).l
	beq.w	.15
	bsr.w	SelectPauseTab
	bsr.w	SetPauseMenuItems
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	jsr	(ClearMenuBox).l
	bra.w	UpdateMenuSelection
.13
	cmpi.l	#StatsMenus,(menulist).l
	beq.w	.15
	bsr.w	SelectStatsTab
	bsr.w	SetStatsMenuItems
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	jsr	(ClearMenuBox).l
	bra.w	UpdateMenuSelection
.14
	cmpi.l	#InfoMenus,(menulist).l
	beq.w	.15
	bsr.w	SelectInfoTab
	bsr.w	SetInfoMenuItems
	clr.w	(menuitem).w
	clr.w	(menuitem+2).w
	jsr	(ClearMenuBox).l
	bra.w	UpdateMenuSelection
.15
	rts

SetPauseMenuItems	;IDA: sub_7E6CA. 95 only. menulist = PauseMenus, menuitemoffset by mode: tmflags bit 2 (no timeout left) $23A, shootout $2CE,
	;Practice Mode $13E ($1D2 when paused), game over with GameFlags bit 3 $AA
	clr.l	(menuitemoffset).w
	move.l	#PauseMenus,(menulist).l
	btst	#2,$30(a2)
	beq.w	.0
	move.l	#$23A,(menuitemoffset).l
.0
	btst	#0,(gmode2).w
	beq.w	.1
	move.l	#$2CE,(menuitemoffset).l
.1
	btst	#7,(sflags9).w
	beq.w	.2
	move.l	#$13E,(menuitemoffset).l
	btst	#0,(sflags).w
	beq.w	.2
	move.l	#$1D2,(menuitemoffset).l
.2
	btst	#3,(GameFlags).w
	beq.w	.3
	cmpi.w	#4,(gsp).w
	bne.w	.3
	move.l	#$AA,(menuitemoffset).l
.3
	rts

SetStatsMenuItems	;IDA: sub_7E748. 95 only. menulist = StatsMenus, menuitemoffset by mode: GameFlags bit 3 $F0, sflags10 bit 0 $74, shootout or Practice
	;Mode $66
	clr.l	(menuitemoffset).w
	btst	#3,(GameFlags).w
	beq.w	.0
	move.l	#$F0,(menuitemoffset).l
	bra.w	.3
.0
	btst	#0,(sflags10).w
	beq.w	.1
	move.l	#$74,(menuitemoffset).l
	bra.w	.3
.1
	btst	#0,(gmode2).w
	beq.w	.2
	move.l	#$66,(menuitemoffset).l
	bra.w	.3
.2
	btst	#7,(sflags9).w
	beq.w	.3
	move.l	#$66,(menuitemoffset).l
.3
	move.l	#StatsMenus,(menulist).l
	rts

SetInfoMenuItems	;IDA: sub_7E7B4. 95 only. menulist = InfoMenus, menuitemoffset $7E in a shootout, $D0 in Practice Mode
	clr.l	(menuitemoffset).w
	move.l	#InfoMenus,(menulist).l
	btst	#0,(gmode2).w
	beq.w	.0
	move.l	#$7E,(menuitemoffset).l
	bra.w	.1
.0
	btst	#7,(sflags9).w
	beq.w	.1
	move.l	#$D0,(menuitemoffset).l
.1
	rts

startpause	;IDA: loc_7E7F0 (hockey94). Pause on (sfpz)
	bset	#0,(sflags).w
	rts

startpause1	;IDA: loc_7E7F8 (hockey94). pause initiated by cont 1 (95: menupadnum = 0 for ReadMenuJoy)
	clr.w	(menupadnum).w
	bra.s	startpause

startpause2	;IDA: loc_7E7FE. pause initiated by cont 2
	move.w	#1,(menupadnum).w
	bra.s	startpause

startpause3	;IDA: loc_7E806 (hockey94). pause initiated by cont 3 (4 way play)
	move.w	#2,(menupadnum).w
	bra.s	startpause

startpause4	;IDA: loc_7E80E. pause initiated by cont 4 (4 way play)
	move.w	#3,(menupadnum).w
	bra.s	startpause

PauseScreenDraw	;$7E816. IDA dc.b. 95 only. Draw the pause screen (SetupPauseScreen): wait out the dma, plane B off, window 3 rows, clear the rink map,
	;the pause background (PauseBgBitmap at 0, 0 / 0, 3 / 0, $19), the period number (not in a shootout or overtime), load the pause fonts,
	;clock digits and tab tiles, the team blocks of both teams, the three tabs (the one of menulist selected), showclock, the penalty boxes
	;(ShowPenaltyBoxes) and fade in
	movem.l	d0-d7/a0-a6,-(sp)
.wait
	btst	#dfok,(disflags).w
	bne.s	.wait
	clr.w	(Hscroll).w
	clr.w	(Vscroll).w
	jsr	(SetScroll2).l
	move.w	(disflags).w,-(sp)
	bset	#dfng,(disflags).w
	movea.l	#VDP_DATA,a0
	move.w	#$9100,4(a0)	;no window
	move.w	#$9200,4(a0)
	move.w	(VSPRITES).w,d0
	jsr	(Vmaddr).l
	move.l	#0,(a0)	;first sprite off
	move.w	#$8C81,4(a0)	;40 col mode
	move.w	#6,(Map2col1).w
	move.w	#$8D00,4(a0)	;hscroll table at 0
	clr.w	d0
	jsr	(Vmaddr).l
	move.l	#0,(a0)
	move.w	(sp)+,(disflags).w
	bclr	#df32c,(disflags).w
	move.w	#$800,d0
	move.w	(VmMap1).w,d1
	move.w	#$7FF,d2
	jsr	(DoFill).l
	jsr	(printz).l
	String	$BE,0,0,0
	movea.l	#PauseBgBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	#3,d3
	moveq	#1,d4
	moveq	#$F,d5
	jsr	(dobitmap).l
	move.w	d4,-(sp)
	jsr	(printz).l
	String	$BE,0,3,0
	movea.l	#PauseBgBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	move.w	#3,d1
	move.w	(a1),d2
	move.w	#$16,d3
	moveq	#1,d4
	moveq	#0,d5
	movea.l	#$69A,a2	;a zero long (main95 $69A): no palettes
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$BE,0,$19,0
	movea.l	#PauseBgBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	move.w	#$19,d1
	move.w	(a1),d2
	move.w	#3,d3
	moveq	#1,d4
	moveq	#0,d5
	movea.l	#$69A,a2
	jsr	(dobitmap).l
	move.w	(sp)+,d4
	jsr	(printz).l
	String	$9E,$10,7,0
	btst	#0,(gmode2).w	;shootout: no period number
	bne.w	.fonts
	cmpi.w	#3,(gsp).w
	bge.w	.fonts
	move.w	(gsp).w,d0
	mulu.w	#3,d0
	add.w	d0,(printx).w
	move.w	d4,(TempPlOffset).w
	movea.l	#PeriodNumberBitmap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$02,$23,$45,$15,$4D,$A8,$CD,$E3	;remap table
	move.w	d4,-(sp)
	move.w	(TempPlOffset).w,d4
	movea.l	#PeriodNumberBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	move.w	(printx).w,d0
	subi.w	#$10,d0
	clr.w	d1
	move.w	#2,d2
	move.w	#1,d3
	moveq	#0,d5
	movea.l	#$69A,a2
	jsr	(dobitmap).l
	move.w	(sp)+,d4
.fonts
	move.w	d4,(smallfontchars).w
	move.l	#PauseFontMap,(smallfontptr).l
	movea.l	(smallfontptr).w,a2
	addq.w	#8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CD,$9F	;remap table
	move.w	d4,(smallfont2chars).w
	movea.l	#PauseFontMap+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$01,$23,$45,$67,$89,$AB,$CB,$EF	;remap table
	move.w	d4,(clockdigitchars).w
	movea.l	#ClockDigitsBitmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(pauselogochars).w
	addi.w	#$32,d4
	move.w	d4,(tabchars).w
	movea.l	#TabBitmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.l	#PauseTeamBlocksMap,(teamblocksmapptr).l
	jsr	(setupTeamBlocksMap).l
	move.w	#$30,d0
	move.w	#2,(printx).w
	move.w	#4,(printy).w
	jsr	(PutTeamBlock).l
	move.w	#$1A,(printx).w
	clr.w	d0
	jsr	(PutTeamBlock).l
	jsr	(ClearInfoTab).l
	jsr	(ClearStatsTab).l
	jsr	(ClearPauseTab).l
	btst	#5,(sflags9).w
	bne.w	.tabs
	cmpi.l	#InfoMenus,(menulist).l
	bne.w	.0
	bsr.w	SelectInfoTab
	bra.w	.tabs
.0
	cmpi.l	#StatsMenus,(menulist).l
	bne.w	.1
	bsr.w	SelectStatsTab
	bra.w	.tabs
.1
	cmpi.l	#PauseMenus,(menulist).l
	bne.w	.tabs
	bsr.w	SelectPauseTab
.tabs
	jsr	(showclock).l
	jsr	(PauseScores).l
	bsr.w	ShowPenaltyBoxes
	jsr	(printz).l
	String	$FE,0,0,0
	move.w	#$18,(palcount).w
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ShowPenaltyBoxes	;IDA: sub_7EAC8. 95 only. The pause screen penalty boxes: home at $1F, $E, away at 2, $E (ShowPenaltyBox)
	movem.l	d0-d7/a0-a3,-(sp)
	jsr	(printz).l
	String	$BE,$1F,$E,0
	movea.l	#HmShots,a2
	bsr.w	ShowPenaltyBox
	jsr	(printz).l
	String	$BE,2,$E,0
	movea.l	#AwShots,a2
	bsr.w	ShowPenaltyBox
	movem.l	(sp)+,d0-d7/a0-a3
	rts

ShowPenaltyBox	;IDA: sub_7EAFE. 95 only. The players in the penalty box list of team a2 ($9C, -1 ends; with sflags9 bit 5 less the impact count),
	;ShowPenaltyBoxPlayer each
	lea	$9C(a2),a0
	clr.w	d7
.0
	tst.b	(a0)+
	bmi.w	.1
	addq.w	#1,d7
	bra.s	.0
.1
	btst	#5,(sflags9).w
	beq.w	.2
	sub.w	$32(a2),d7
.2
	lea	$9C(a2),a0
.3
	clr.w	d0
	subq.w	#1,d7
	bmi.w	rtsmenu
	move.b	(a0)+,d0
	bmi.w	rtsmenu
	bsr.w	ShowPenaltyBoxPlayer
	bra.s	.3

ListPenaltyBox	;$7EB34. IDA dc.b, no xref. 95 only. ShowPenaltyBox without the count: every player in the box list of team a2
	lea	$9C(a2),a0
.0
	clr.w	d0
	move.b	(a0)+,d0
	bmi.w	rtsmenu
	bsr.w	ShowPenaltyBoxPlayer
	bra.w	.1
.1
	subq.w	#1,d7
	bmi.w	rtsmenu
	bra.s	.0

ShowPenaltyBoxPlayer	;IDA: sub_7EB50. 95 only. Print player d0 / 2 + 1 of team a2: jersey number and penalty time left (tmpdst), one line down, up to
	;printy $13
	move.w	d7,-(sp)
	cmpi.w	#$13,(printy).w
	bhi.w	.0
	move.w	$68(a2,d0.w),d2
	andi.w	#$7FF,d2
	lsr.w	#1,d0
	addq.w	#1,d0
	move.l	d7,-(sp)
	move.w	$28(a2),d7
	jsr	(GetRosterName).l
	move.w	$28(a2),d7
	subq.w	#1,d0
	jsr	(GetJerseyNumber).l
	move.l	(sp)+,d7
	clr.w	d0
	move.b	(jerseynum).w,d0
	move.w	(printx).w,-(sp)
	movea.w	#(TextBuffer-M68K_RAM),a1
	jsr	(d0toascii).l
	movea.w	#(mesarea-M68K_RAM),a1
	move.w	#4,(a1)
	jsr	(print).l
	move.w	d2,d0
	jsr	(PushTime).l
	jsr	(print).l
	move.w	(sp)+,(printx).w
	addq.w	#1,(printy).w
.0
	move.w	(sp)+,d7

rtsmenu	;IDA: locret_7EBBC. An rts branched to from ShowPenaltyBox and ListPenaltyBox
	rts

RestoreGameScreen	;IDA: sub_7EBBE. 95 only (in the 94 Pausemode ClrHor place). Rebuild the game screen after the pause screen: the vdp maps, palettes,
	;vram, framer, fonts, energy bar, crowd and EASN tiles, the face off screen (disflags bit 4) or the ref tiles, the rink tiles and home team
	;graphics, then PrintScores1. Called from Pausemode (hockey95_02)
	movem.l	d0-d7/a0-a6,-(sp)
	clr.w	(printfontset).w
	bclr	#5,(sflags9).w
	clr.w	(HmShots+$32).w
	clr.w	(AwShots+$32).w
	move.l	#VBlank,(vbint).w
	bset	#1,(disflags).w
	move.w	#$C000,(VmMap2).w
	move.w	#6,(Map2col1).w
	move.w	#$DC00,(VSPRITES).w
	move.w	#$E000,(VmMap1).w
	move.w	#6,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#5,(Map3col1).w
	move.w	#$FC00,(VSCRLPM).w
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d1
.0
	clr.l	(a0)+
	dbf	d1,.0
	jsr	(setplayercolors).l
	jsr	(SetRinkPalette).l
	jsr	(setVram_0).l
	jsr	(ClearOldFrames).l
	move.w	#$800,d0
	move.w	(VmMap1).w,d1
	move.w	#$7FF,d2
	jsr	(DoFill).l
	move.w	(framerchars).w,d4
	jsr	(AddFramer2).l
	jsr	(AddFonts).l
	move.w	(energybarchars).w,d4
	movea.l	#EnergyBarMap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	(gamesetuptilesetindex).w,d4
	movea.l	#CrowdFrameList+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(setupEASNmap).l
	btst	#4,(disflags).w
	beq.w	.1
	btst	#3,(sflags2).w
	bne.w	.1
	move.w	(ExtraChars).w,d4
	movea.l	#FaceoffTiles+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	d4,(faceoffvrcset).w
	movea.l	#FaceoffTiles2+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(FaceoffScreen).l
	bra.w	.4
.1
	move.w	(ExtraChars).w,d4
	btst	#7,(sflags).w
	beq.w	.2
	movea.l	#RefTilesHor+8,a2
	bra.w	.3
.2
	movea.l	#RefTiles+8,a2
.3
	jsr	(DoDMA_clearCallbackPointer).l
.4
	move.w	(disflags).w,-(sp)
	bset	#2,(disflags).w
	move.w	#$7D0,(Oldrow).w
	clr.w	d4
	move.w	d4,(rinkvrcset).w
	movea.l	#Rinktilelist+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(LoadHomeTeamGfx).l
	jsr	(setplayercolors).l
	jsr	(SetRinkPalette).l
	move.w	(sp)+,(disflags).w
	bclr	#0,(disflags).w
	bclr	#2,(disflags).w
	move	#$2300,sr
	jsr	(SprSort).l
	move.w	(vcount).w,d0
.5
	cmp.w	(vcount).w,d0
	beq.s	.5
	bset	#3,(disflags).w
	jsr	(PrintScores1).l
	btst	#3,(sflags2).w
	bne.w	.6
	move.w	#$64,(palcount).w
.6
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearOldFrames	;IDA: sub_7ED5A. 95 only. oldframe = -1 for the 16 sort objects, the 4 sso and the 6 pads, so addframe2 sends their tiles again
	movem.l	d0-d1/a0-a3,-(sp)
	movea.l	#SortCords,a0
	move.w	#$80,d0
	move.w	#$F,d1
.0
	st	8(a0)
	adda.w	d0,a0
	dbf	d1,.0
	movea.l	#sso,a0
	move.w	#$14,d0
	move.w	#3,d1
.1
	st	8(a0)
	adda.w	d0,a0
	dbf	d1,.1
	movea.l	#pads,a0
	move.w	#$1C,d0
	move.w	#5,d1
.2
	st	8(a0)
	adda.w	d0,a0
	dbf	d1,.2
	movem.l	(sp)+,d0-d1/a0-a3
	rts

SetMenuPrintX	;IDA: sub_7EDAC. 93 name. printx = $A (95; 94 4)
	move.w	#$A,(printx).w
	rts

UpdateMenuSelection	;IDA: sub_7EDB4. 93 name. Clamp menuitem to the list, scroll menuitem+2 to show it, and print 4 items from printy $C (the
	;selected one in the highlight attribute) with the up / down arrows; no menu (menulist $69A): DrawMenuInfo
	btst	#5,(sflags9).w
	bne.w	.11
	cmpi.l	#$69A,(menulist).w
	bne.w	.0
	jmp	(DrawMenuInfo).l
.0
	move.w	(menuitem).w,d0
	bpl.w	.1
	clr.w	(menuitem).w
	clr.w	d0
.1
	movea.l	(menulist).w,a0
	adda.l	(menuitemoffset).w,a0
	adda.w	(a0),a0
	adda.w	(a0),a0
	bra.w	.3
.2
	adda.w	(a0),a0
	addq.w	#4,a0
	tst.w	2(a0)
.3
	dbmi	d0,.2
	addq.w	#1,d0
	sub.w	d0,(menuitem).w
	move.w	(menuitem).w,d0
	cmp.w	(menuitem+2).w,d0
	bge.w	.4
	move.w	d0,(menuitem+2).w
.4
	subq.w	#3,d0
	cmp.w	(menuitem+2).w,d0
	ble.w	.5
	move.w	d0,(menuitem+2).w
.5
	bsr.s	SetMenuPrintX
	move.w	#$D,(printy).w
	movea.l	(menulist).w,a1
	adda.l	(menuitemoffset).w,a1
	jsr	(printsmall).l
	jsr	(printz2).l
	dc.w	$28	;String: menu box top, rows of blanks
	dc.b	$F9,$00,$FB,$01,$20,$FB,$FF,$FA,$01,$20,$FB,$FF,$FA,$01,$20,$FB
	dc.b	$FF,$FA,$01,$20,$FB,$12,$20,$FB,$FF,$FA,$FF,$20,$FB,$FF,$FA,$FF
	dc.b	$20,$FB,$FF,$FA,$FF,$20
	adda.w	(a1),a1
	move.w	(menuitem+2).w,d0
	bra.w	.7
.6
	adda.w	(a1),a1
	addq.w	#4,a1
.7
	dbf	d0,.6
	moveq	#3,d1
	move.w	#$C,(printy).w
	bsr.w	SetMenuPrintX
	move.w	(menuitem+2).w,d0
	beq.w	.8
	jsr	(printz2).l
	String	$FE,0,$F9,0,$FB,1,$FA,1,$7B,$FA,$FF,0	;the up arrow
.8
	bsr.w	SetMenuPrintX
	jsr	(printz2).l
	String	$F9,0,$FB,2,$FA,2
	move.l	a1,-(sp)
	movea.l	(menulist).w,a1
	adda.l	(menuitemoffset).w,a1
	jsr	(printsmall).l
	cmp.w	(menuitem).w,d0
	bne.w	.9
	jsr	(printsmall).l
.9
	movea.l	(sp)+,a1
	bsr.w	PrintMenuItem
	addq.w	#1,d0
	addq.w	#4,a1
	tst.w	2(a1)
	dbmi	d1,.8
	bpl.w	.10
	bsr.w	SetMenuPrintX
	addq.w	#1,(printy).w
	move	sr,-(sp)
	jsr	(printz2).l
	String	$FE,0,$FB,1
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#1,d0
	move.w	#1,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	movem.l	(sp)+,d0-d7/a0-a6
	move	(sp)+,sr
	subq.w	#1,(printy).w
	rts
.10
	bsr.w	SetMenuPrintX
	addq.w	#1,(printy).w
	jsr	(printz2).l
	String	$F9,0,$FE,0,$FB,1,$7D,0	;the down arrow
	subq.w	#1,(printy).w
.11
	rts

PrintMenuItem	;IDA: sub_7EF38. 93 name. printsmall item String a1 (advanced past it). y: START GAME, RESUME GAME or EXIT GAME by gsp and sfpz;
	;x: MANUAL GOALIE or AUTO GOALIE by the pad team's goaliemode1 / goaliemode2
	cmpi.b	#$79,2(a1)
	beq.w	.0
	cmpi.b	#$78,2(a1)
	bne.w	.9
	move.l	a1,-(sp)
	movea.l	#.11,a1
	bsr.w	SetMenuPadSide
	btst	#1,(sflags).w
	beq.w	.6
	tst.w	(goaliemode2).w
	bra.w	.7
.0
	move.l	a1,-(sp)
	cmpi.w	#4,(gsp).w
	beq.w	.1
	movea.l	#.4,a1
	btst	#0,(sflags).w
	bne.w	.2
	tst.w	(gsp).w
	bne.w	.2
	movea.l	#.3,a1
	bra.w	.2
.1
	movea.l	#.5,a1
.2
	bra.w	.8
.3
	String	'   START GAME   '
.4
	String	'  RESUME GAME   '
.5
	String	'   EXIT GAME    '
.6
	tst.w	(goaliemode1).w
.7
	beq.w	.8
	movea.l	#.12,a1
.8
	jsr	(printsmall).l
	movea.l	(sp)+,a1
	adda.w	(a1),a1
	bra.w	.10
.9
	jsr	(printsmall).l
.10
	rts
.11
	String	' MANUAL GOALIE  '
.12
	String	'  AUTO GOALIE   '

ClearMenuBox	;IDA: sub_7F020. 95 only. eraser $12 x $C at $B, $B
	jsr	(printz2).l
	String	$FE,4,$FD,$B,$FC,$B
	moveq	#$12,d0
	moveq	#$C,d1
	move.w	#$7FF,d2
	jmp	(eraser).l

DrawMenuInfo	;IDA: loc_7F03C. 95 only. With no menu list: clear the box and run draw routine menuitem of MenuInfoList (wrapping at 0)
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(ClearMenuBox).l
	btst	#5,(sflags9).w
	bne.w	.3
.0
	move.w	(menuitem).w,d0
	bpl.w	.1
	clr.w	(menuitem).w
	clr.w	d0
.1
	asl.w	#2,d0
	movea.l	#MenuInfoList,a0
	movea.l	(a0,d0.w),a0
	cmpa.l	#0,a0
	bne.w	.2
	clr.w	(menuitem).w
	bra.s	.0
.2
	jsr	(a0)
.3
	movem.l	(sp)+,d0-d7/a0-a6
	andi	#$FB,ccr
	rts

MenuInfoList	;IDA: unk_7F086 (dc.b). 95 only. The info page draw routines for DrawMenuInfo (0 ends)
	dc.l	PauseInfo,0
PauseInfo	;$7F08E. IDA dc.b. 95 only. The info page: a bitmap at $11, $B (a0 is whatever printz left: the vdp data port) and
	;PauseInfoText (PrintLines)
	jsr	(printz).l
	String	$BE,$11,$B,0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	move.w	(pauselogochars).w,d4
	move.w	#0,d5
	jsr	(dobitmap).l
	movea.l	#PauseInfoText,a1
	jsr	(PrintLines).l
	rts
PauseInfoText	;$7F0C8. The info page text (a placeholder in retail)
	String	$BE,$B,$12,'Lots of good text:'
	String	$BE,$B,$14,'stats and other'
	String	$BE,$B,$16,'stuff.'
	String	$FF,0
PrintLines	;$7F104. IDA dc.b. 95 only. print the Strings at a1 up to a $FF String
	cmpi.b	#$FF,2(a1)
	beq.w	.x
	jsr	(print).l
	bra.s	PrintLines
.x
	rts

ShowPenaltyMessages	;IDA: sub_7F118. 95 only. Every $78 frames show the next queued penalty (penaltymsgs): its name (PenaltyNames) and the player
	;(FormatPlayerNameWithAttrib) centred at $14, $F / $11, and take him off the penalty box count. d1 = 1 when the queue is empty
	movem.l	d0-d6/a0-a3,-(sp)
	subq.w	#1,(menutimer).w
	bpl.w	.8
.0
	movea.l	#penaltymsgs,a0
	tst.w	(a0)
	beq.w	.7
	move.l	a0,-(sp)
	jsr	(printz).l
	String	$BF,$A,$F,'                    '	;clear the two message lines
	jsr	(printz).l
	String	$BF,$A,$11,'                    '
	movea.l	(sp)+,a0
.1
	tst.w	(a0)+
	bne.s	.1
	subq.l	#4,a0
	clr.w	d0
	move.b	(a0),d0
	movea.l	#PenaltyNames,a1
	adda.w	(a1,d0.w),a1
	clr.w	d2
	move.b	1(a1),d2
	beq.w	.6
	bmi.w	.6
	move.w	#$78,(menutimer).w
	clr.w	d0
	move.b	1(a0),d0
	move.w	d0,-(sp)
	addq.l	#2,a1
	jsr	(printz).l
	String	$BF,$14,$F,0
	move.w	(a1),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jsr	(print).l
	move.w	(sp),d0
	movea.l	#HmShots,a2
	bclr	#7,d0
	beq.w	.2
	adda.l	#tmsize,a2
.2
	move.l	a2,-(sp)
	jsr	(FormatPlayerNameWithAttrib).l
	jsr	(printz).l
	String	$BF,$14,$11,0
	move.w	(a1),d0
	subq.w	#2,d0
	lsr.w	#1,d0
	sub.w	d0,(printx).w
	jsr	(print).l
	movea.l	(sp)+,a2
	move.w	(sp)+,d0
	movem.l	d0-d7/a0-a6,-(sp)
	bclr	#7,d0
	add.w	d0,d0
	lea	$9C(a2),a4
.3
	cmp.b	(a4)+,d0
	beq.w	.4
	tst.b	-1(a4)
	bmi.w	.5
	bra.s	.3
.4
	subq.w	#1,$32(a2)
	bsr.w	ShowPenaltyBoxes
.5
	movem.l	(sp)+,d0-d7/a0-a6
	clr.w	(a0)
	bra.w	.8
.6
	clr.w	(a0)
	bra.w	.0
.7
	move.w	#1,d1
	bra.w	.9
.8
	move.w	#0,d1
.9
	movem.l	(sp)+,d0-d6/a0-a3
	rts

SelectInfoTab	;IDA: sub_7F248. 95 only. Draw the INFO tab selected (x 1), the others plain
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	ClearStatsTab
	bsr.w	ClearPauseTab
	jsr	(printz).l
	String	$BE,1,1,0
	move.w	#1,d0
	bsr.w	DrawTabSelected
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearInfoTab	;IDA: sub_7F26E. 95 only. Draw the INFO tab plain
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BE,1,1,0
	move.w	#1,d0
	bsr.w	DrawTab
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SelectStatsTab	;IDA: sub_7F28C. 95 only. Draw the STATS tab selected (x $E), the others plain
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.s	ClearInfoTab
	bsr.w	ClearPauseTab
	jsr	(printz).l
	String	$BE,$E,1,0
	move.w	#$E,d0
	bsr.w	DrawTabSelected
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearStatsTab	;IDA: sub_7F2B0. 95 only. Draw the STATS tab plain
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BE,$E,1,0
	move.w	#$E,d0
	bsr.w	DrawTab
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SelectPauseTab	;IDA: sub_7F2CE. 95 only. Draw the PAUSE tab selected (x $1B), the others plain
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.s	ClearStatsTab
	bsr.s	ClearInfoTab
	jsr	(printz).l
	String	$BE,$1B,1,0
	move.w	#$1B,d0
	bsr.w	DrawTabSelected
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ClearPauseTab	;IDA: sub_7F2F0. 95 only. Draw the PAUSE tab plain
	movem.l	d0-d7/a0-a6,-(sp)
	jsr	(printz).l
	String	$BE,$1B,1,0
	move.w	#$1B,d0
	bsr.w	DrawTab
	movem.l	(sp)+,d0-d7/a0-a6
	rts

DrawTabSelected	;IDA: sub_7F30E. 95 only. The selected tab: $D x 2 of PauseBgBitmap from row 1 at printx / printy
	movea.l	#PauseBgBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	move.w	#1,d1
	move.w	#$D,d2
	move.w	#2,d3
	movea.l	#$69A,a2
	move.w	#1,d4
	moveq	#0,d5
	jmp	(dobitmap).l

DrawTab	;IDA: sub_7F33A. 95 only. The plain tab: $D x 3 of TabBitmap at printx / printy (chars tabchars)
	movea.l	#TabBitmap,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	move.w	#1,d1
	move.w	#$D,d2
	move.w	#3,d3
	movea.l	#$69A,a2
	move.w	(tabchars).w,d4
	moveq	#0,d5
	jmp	(dobitmap).l
	rts	;$7F366. IDA dc.b: a second rts, no xref

InfoMenus	;IDA: unk_7F368 (dc.b). The pause INFO tab lists (SetInfoMenuItems: menuitemoffset 0, $7E, $D0): a String header, then items of a
	;String and a routine (y = the play / resume item, x = the manual goalie toggle; PrintMenuItem), ended by a $FF String
	String	$FE,0,$F9,0
	String	$FE,0,$F9,1
	String	'y  PLAY GAME    '
	dc.l	PlayGame
	String	'  TEAM ROSTER   '
	dc.l	TeamRosterScreen
	String	'SCORING SUMMARY '
	dc.l	ScoringSummaryScreen
	String	'PENALTY SUMMARY '
	dc.l	PenaltySummaryScreen
	String	' RECORD HOLDERS '
	dc.l	RecordHoldersScreen
	String	$FF,0
	;InfoMenus+$7E
	String	$FE,0,$F9,0
	String	$FE,0,$F9,1
	String	'y  PLAY GAME    '
	dc.l	PlayGame
	String	'  TEAM ROSTER   '
	dc.l	TeamRosterScreen
	String	' RECORD HOLDERS '
	dc.l	RecordHoldersScreen
	String	$FF,0
	;InfoMenus+$D0
	String	$FE,0,$F9,0
	String	$FE,0,$F9,1
	String	'y  PLAY GAME    '
	dc.l	PlayGame
	String	'  TEAM ROSTER   '
	dc.l	TeamRosterScreen
	String	' RECORD HOLDERS '
	dc.l	RecordHoldersScreen
	String	$FF,0
StatsMenus	;IDA: unk_7F48A (dc.b). The pause STATS tab lists (SetStatsMenuItems: menuitemoffset 0, $66, $74, $F0)
	String	$FE,0
	String	$FE,0,$F9,1
	String	'y  PLAY GAME    '
	dc.l	PlayGame
	String	'   GAME STATS   '
	dc.l	GameStatisticsScreen
	String	'  PERIOD STATS  '
	dc.l	PeriodStatsScreen
	String	'  PLAYER STATS  '
	dc.l	PlayerStatsScreen
	String	$FF,0
	;StatsMenus+$66
	String	$FE,0
	String	$FE,0,$F9,1
	String	$FF,0
	;StatsMenus+$74
	String	$FE,0
	String	$FE,0,$F9,1
	String	'y  PLAY GAME    '
	dc.l	PlayGame
	String	'   GAME STATS   '
	dc.l	GameStatisticsScreen
	String	'  PERIOD STATS  '
	dc.l	PeriodStatsScreen
	String	'  PLAYER STATS  '
	dc.l	PlayerStatsScreen
	String	' PLAYOFF STATS  '
	dc.l	PlayoffStatsScreen
	String	$FF,0
	;StatsMenus+$F0
	String	$FE,0
	String	$FE,0,$F9,1
	String	'y  PLAY GAME    '
	dc.l	PlayGame
	String	'   GAME STATS   '
	dc.l	GameStatisticsScreen
	String	'  PERIOD STATS  '
	dc.l	PeriodStatsScreen
	String	'  PLAYER STATS  '
	dc.l	PlayerStatsScreen
	String	' SEASON PLAYERS '
	dc.l	SeasonPlayersScreen
	String	'  SEASON TEAMS  '
	dc.l	SeasonTeamsScreen
	String	$FF,0
PauseMenus	;IDA: unk_7F60C (dc.b). The pause PAUSE tab lists (SetPauseMenuItems: menuitemoffset 0, $AA, $13E, $1D2, $23A, $2CE)
	String	$FE,0
	String	$FE,0,$F9,1
	String	'y   PLAY GAME   '
	dc.l	PlayGame
	String	' INSTANT REPLAY '
	dc.l	ReplayMode
	String	'   EDIT LINES   '
	dc.l	LineEditor
	String	' CHANGE GOALIE  '
	dc.l	SelectGoalieMenu
	String	'x MANUAL GOALIE  '
	dc.l	ManualGoalieMenu
	String	'    TIMEOUT     '
	dc.l	TimeoutMenu
	String	'   ABORT GAME   '
	dc.l	AbortGame
	String	$FF,0
	;PauseMenus+$AA
	String	$FE,0
	String	$FE,0,$F9,1
	String	'y   PLAY GAME   '
	dc.l	PlayGame
	String	' INSTANT REPLAY '
	dc.l	ReplayMode
	String	'   EDIT LINES   '
	dc.l	LineEditor
	String	' CHANGE GOALIE  '
	dc.l	SelectGoalieMenu
	String	'x MANUAL GOALIE  '
	dc.l	ManualGoalieMenu
	String	'    TIMEOUT     '
	dc.l	TimeoutMenu
	String	$FF,0
	;PauseMenus+$13E
	String	$FE,0
	String	$FE,0,$F9,1
	String	'y   PLAY GAME   '
	dc.l	PlayGame
	String	' INSTANT REPLAY '
	dc.l	ReplayMode
	String	'   EDIT LINES   '
	dc.l	LineEditor
	String	' CHANGE GOALIE  '
	dc.l	SelectGoalieMenu
	String	'x MANUAL GOALIE  '
	dc.l	ManualGoalieMenu
	String	'   ABORT GAME   '
	dc.l	AbortGame
	String	$FF,0
	;PauseMenus+$1D2
	String	$FE,0
	String	$FE,0,$F9,1
	String	'y   PLAY GAME   '
	dc.l	PlayGame
	String	' INSTANT REPLAY '
	dc.l	ReplayMode
	String	'x MANUAL GOALIE  '
	dc.l	ManualGoalieMenu
	String	'   ABORT GAME   '
	dc.l	AbortGame
	String	$FF,0
	;PauseMenus+$23A
	String	$FE,0
	String	$FE,0,$F9,1
	String	'y   PLAY GAME   '
	dc.l	PlayGame
	String	' INSTANT REPLAY '
	dc.l	ReplayMode
	String	'   EDIT LINES   '
	dc.l	LineEditor
	String	' CHANGE GOALIE  '
	dc.l	SelectGoalieMenu
	String	'x MANUAL GOALIE  '
	dc.l	ManualGoalieMenu
	String	'   ABORT GAME   '
	dc.l	AbortGame
	String	$FF,0
	;PauseMenus+$2CE
	String	$FE,0
	String	$FE,0,$F9,1
	String	'   PLAY GAME    '
	dc.l	PlayGame
	String	' INSTANT REPLAY '
	dc.l	ReplayMode
	String	'x MANUAL GOALIE  '
	dc.l	ManualGoalieMenu
	String	' SHOOTOUT SETUP '
	dc.l	ShootoutSetup
	String	'   ABORT GAME   '
	dc.l	AbortGame
	String	$FF,0

AbortGame	;$7F958. IDA dc.b. 95 only. Pause menu ABORT GAME: stop the replay (recbpr), demoflag on, back to Opening2
	bclr	#4,(sflags).w
	move.w	#$FFFF,(lastsfx).w
	move.l	#$FFFF0000,(recbpr).w
	st	(demoflag).w
	jmp	(Opening2).l
PlayGame	;$7F976. IDA dc.b. 95 only. Pause menu PLAY GAME: sflags9 bit 3 ends the pause menu (HandleMenuInput)
	bset	#3,(sflags9).w
	rts
