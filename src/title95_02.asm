;	NHL 95 title95_02. Retail $0A12AA-$0A1A59 (1968 bytes).
;	Mapped to title94 (53%): newTitleScreen, CreditsPrintRow, CreditsWait, TitleVBlank, CreditsLineScroll, CreditsScrollStep, HiScoreScreen;
;	95 only: the Stanley Cup screen (StanleyCupScreen ... AddSpriteFrame).
;	IDA left TitleVBlank, CreditsScrollStep and CupVBlank as dc.b and hid the printz Strings and remap bytes; they are written from the retail
;	bytes.
;	Local labels are numbered; the IDA local names are not kept.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp / cmpi / exg; fixopcodes.js patches
;	the cmp and exg encodings after assembly.

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

newTitleScreen	;IDA: sub_A12AA. title94 newTitleScreen. The title screen (TitleScreenImg, TitleImg) with the vblank TitleVBlank and the song, then the scrolling credits (Credits, CreditsList, CreditsPrintRow) until start
	move	#$2700,sr
	move.w	(VDP_CNTR).l,(RNGseed).w
	move.w	(VDP_CNTR).l,(RNGseed+2).w
	move.l	#TitleVBlank,(vbint).l
	bset	#1,(disflags).w
	move.w	#5,(Map3col1).w
	move.w	#$A000,(VmMap2).w
	move.w	#7,(Map2col1).w
	move.w	#$C000,(VmMap1).w
	move.w	#7,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#$F800,(VSPRITES).w
	move.w	#$FC00,(VSCRLPM).w
	move.w	#0,d0
	jsr	(setvram).l
	movea.l	#VDP_DATA,a0
	move.w	#$9100,4(a0)
	move.w	#$9217,4(a0)
	move.w	#$8B03,4(a0)
	clr.w	(Vscroll).w
	jsr	(printz).l
	String	$FF,0,0,0
	move.l	#$80,d0
	moveq	#$20,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	jsr	(printz).l
	String	$FE,0,0,0
	move.l	#$80,d0
	moveq	#$20,d1
	move.l	#$7FF,d2
	jsr	(eraser).l
	clr.w	d4
	move.w	d4,-(sp)
	jsr	(printz).l
	String	$FD,0,0,0
	movea.l	#TitleScreenImg,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	#$17,d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	move.w	d4,(TempWord1).w
	move.w	(sp)+,d4
	jsr	(printz).l
	String	$FE,0,$17,0
	movea.l	#TitleScreenImg,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	move.w	#$17,d1
	move.w	(a1),d2
	move.w	#5,d3
	moveq	#0,d5
	bset	#0,(sflags6).w
	jsr	(dobitmap).l
	bclr	#0,(sflags6).w
	move.w	(TempWord1).w,d4
	jsr	(printz).l
	String	$BE,1,$A,0
	movea.l	#TitleImg,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#8,d5
	jsr	(dobitmap).l
	clr.w	(palfadenew).w
	clr.l	(fofdata2).w
	clr.w	(palfadenew+$84).w
	move.w	d4,(smallfontchars).w
	move.l	#RosterFont,(smallfontptr).l
	movea.l	#RosterFont+8,a2
	jsr	(DecompressGraphicsWithCallback).l
	dc.b	$0D,$10,$45,$67,$89,$AB,$CD,$EF;remap bytes
	clr.w	(TempWord1).w
	jsr	(printz).l
	String	$EF,0,0,0
	movea.l	#Credits,a1
	jsr	(CreditsPrintRow).l
	addi.w	#$20,(Vscroll).w
	move.w	#$104,(clampcounter).w
	move.w	#$120,(playoffspritex).w
	move.w	#$D0,(playoffspritey).w
	clr.w	(asv).w
	move.w	#$FFCE,(DispAttribCtr).w
	move.w	#$20,(palcount).w
	jsr	(play_new_song).l
	move.w	#9,d0
	jsr	(SoundCmd).l
	move.w	#0,d0
	move.w	#$1B63,d1
	movea.l	#$BD86,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#$D8EC,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#0,d1
	jsr	(SoundCmd).l
	move.w	#0,-(sp)
	jsr	(song).l
	bsr.w	CreditsLineScroll
	clr.w	(TempWord1).w
	move	#$2500,sr
.0
	jsr	(CreditsWait).l
	tst.w	(clampcounter).w
	bne.s	.0
	move.w	#$3C,d3
.1
	jsr	(CreditsWait).l
	dbf	d3,.1
	jsr	(printz).l
	String	$EF,0,0,0
	movea.l	#CreditsList,a1
.2
	jsr	(CreditsPrintRow).l
	adda.w	(a1),a1
	moveq	#$27,d4
.3
	jsr	(CreditsWait).l
	jsr	(CreditsWait).l
	addq.w	#1,(Vscroll).w
	dbf	d4,.3
	move.w	#$3C,d4
.4
	jsr	(CreditsWait).l
	dbf	d4,.4
	addq.w	#1,(TempWord1).w
	tst.w	2(a1)
	bpl.s	.2
	rts

CreditsPrintRow	;IDA: sub_A1534. title94 CreditsPrintRow. Credits: clear the row below the screen (Vscroll / 8 + $1C) and print the Strings from a1 centred there
	move.w	(Vscroll).w,d0
	asr.w	#3,d0
	addi.w	#$1C,d0
	andi.w	#$1F,d0
	move.w	d0,(printy).w
	move.w	d0,-(sp)
	clr.w	(printx).w
	moveq	#$20,d0
	moveq	#6,d1
	move.w	#$7FF,d2
	jsr	(eraser).l
	move.w	(sp)+,(printy).w
.0
	move.w	(a1),d0
	asr.w	#1,d0
	neg.w	d0
	addi.w	#$11,d0
	move.w	d0,(printx).w
	jsr	(print).l
	addq.w	#1,(printy).w
	andi.w	#$1F,(printy).w
	tst.w	2(a1)
	bpl.s	.0
	rts

CreditsWait	;IDA: sub_A1584. title94 CreditsWait. Credits: wait one frame, run the clampcounter count down; from TempWord1 5 on, start returns from the caller
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	(vcount).w,d0
.0
	cmp.w	(vcount).w,d0
	beq.s	.0
	subq.w	#2,(clampcounter).w
	bpl.w	.1
	clr.w	(clampcounter).w
.1
	jsr	(orjoy).l
	cmpi.w	#5,(TempWord1).w
	blt.w	.3
	btst	#7,d1
	movem.l	(sp)+,d0-d7/a0-a6
	beq.w	.2
	addq.w	#4,sp
.2
	rts
.3
	movem.l	(sp)+,d0-d7/a0-a6
	rts

TitleVBlank	;IDA: unk_A15C4. title94 TitleVBlank. newTitleScreen vblank: the line scroll table and Vscroll, the sprites, cramfade, CreditsScrollStep, the music; rte
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#2,(disflags).w
	bne.w	.1
	movea.w	#$AC62,a0
	move.w	(VSCRLPM).w,d1
	move.w	#$1C0,d0
	jsr	(DoDMA).l
	movea.l	#VDP_DATA,a0
	move.l	#$40000010,4(a0)
	move.w	(Vscroll).w,(a0)
	movea.w	#$BC1E,a0
	move.w	(Sattsize).w,d0
	beq.w	.0
	clr.w	(Sattsize).w
	move.w	(VSPRITES).w,d1
	jsr	(DoDMA).l
.0
	jsr	(cramfade).l
.1
	addq.w	#1,(vcount).w
	jsr	(CreditsScrollStep).l
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte

CreditsLineScroll	;IDA: sub_A162C. title94 CreditsLineScroll. Credits: the line scroll table at SortCords
	movem.l	d0-d1,-(sp)
	move.w	#$14,(Hscroll).w
	move.w	#$50,(TempWord2).w
	move.w	#$50,d0
	movea.l	#SortCords,a0
	move.l	#$FD80,d1
.0
	move.l	d1,(a0)+
	btst	#0,d0
	bne.w	.1
	subq.w	#1,d1
.1
	dbf	d0,.0
	move.w	#$60,d0
	move.l	#$100,d1
.2
	move.l	d1,(a0)+
	addq.l	#4,d1
	dbf	d0,.2
	movem.l	(sp)+,d0-d1
	rts

CreditsScrollStep	;no IDA label. title94 CreditsScrollStep. Credits: line scroll step, every TempWord2 frames
	subq.w	#1,(TempWord2).w
	bmi.w	.0
	rts
.0
	clr.w	(TempWord2).w
	movem.l	d0-d2/a0,-(sp)
	move.w	#$DF,d0
	movea.w	#(SortCords-M68K_RAM),a0
.1
	tst.l	(a0)+
	cmp.w	#$28,d0
	ble.w	.3
	move.w	(Hscroll).w,d1
	cmp.w	#$8F,d0
	blt.w	.2
	move.w	-2(a0),d2
	beq.w	.3
	add.w	d1,d2
	move.w	d2,-2(a0)
	andi.w	#$FC00,d2
	cmp.w	#$FC00,d2
	beq.w	.3
	move.w	#0,-2(a0)
	bra.w	.3
.2
	sub.w	d1,-2(a0)
	bpl.w	.3
	clr.w	-2(a0)
.3
	dbf	d0,.1
	movem.l	(sp)+,d0-d2/a0
	rts

HiScoreScreen	;IDA: sub_A16DE. title94 HiScoreScreen. vb2, the HiScoreBgMap and HiScoreImg bitmaps, then wait up to $50 * 4 frames or a button (waitx)
	move.l	#vb2,(vbint).w
	bclr	#1,(disflags).w
	move.w	#5,(Map3col1).w
	move.w	#$A000,(VmMap2).w
	move.w	#7,(Map2col1).w
	move.w	#$C000,(VmMap1).w
	move.w	#7,(Map1col1).w
	move.w	#$F000,(VmMap3).w
	move.w	#$F800,(VSPRITES).w
	move.w	#$FC00,(VSCRLPM).w
	jsr	(forceblack).l
	movea.w	#(palfadenew-M68K_RAM),a0
	moveq	#$1F,d1
.0
	clr.l	(a0)+
	dbf	d1,.0
	jsr	(setVram_0).l
	jsr	(printz).l
	String	$BE,$E,$3,$0
	movea.l	#HiScoreBgMap,a2
	movea.l	a2,a0
	movea.l	a2,a1
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	clr.w	d4
	moveq	#$F,d5
	jsr	(dobitmap).l
	jsr	(printz).l
	String	$BE,$10,$10,$0
	movea.l	#HiScoreImg,a2
	movea.l	a2,a0
	movea.l	a2,a1
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#0,d5
	jsr	(dobitmap).l
	move.w	#$18,(palcount).w
	move	#$2500,sr
	move.w	#$50,(RNGseed).w
.1
	moveq	#4,d0
	jsr	(waitx).l
	tst.w	d1
	bne.w	.2
	subq.w	#1,(RNGseed).w
	bpl.s	.1
.2
	move	#$2700,sr
	rts

StanleyCupScreen	;IDA: sub_A17B8. 95 only. The Stanley Cup screen: the vblank CupVBlank, the cup (StanleyCupImg), the winner team block (CupDrawTeam), the song, then the animated sprites (CupBuildSprites) until start (CupReadPads)
	movem.l	d0-d7/a0-a6,-(sp)
	move.l	#CupVBlank,(vbint).l
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
	clr.w	(cupframe).w
	move.w	#1,d4
	move.w	d4,(teamblocksmapptr).w
	movea.l	#Teamblocksmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	movea.l	#CupSprites,a1
	lea	8(a1),a2
	adda.l	(a1),a1
	move.w	d4,(energybarchars).w
	jsr	(DoDMA_clearCallbackPointer).l
	jsr	(printz).l
	String	$FE,$0,$0,$0
	movea.l	#StanleyCupImg,a0
	movea.l	a0,a1
	movea.l	a0,a2
	adda.l	(a2)+,a0
	adda.l	(a2)+,a1
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2
	move.w	2(a1),d3
	moveq	#$F,d5
	jsr	(dobitmap).l
	bsr.w	CupDrawTeam
	move.w	#$18,(palcount).w
	jsr	(play_new_song).l
	move.w	#9,d0
	jsr	(SoundCmd).l
	move.w	#0,d0
	move.w	#$1B63,d1
	movea.l	#$BD86,a0
	jsr	(SoundCmd).l
	move.w	#6,d0
	clr.w	d1
	movea.l	#$D8EC,a0
	jsr	(SoundCmd).l
	move.w	#7,d0
	move.w	#0,d1
	jsr	(SoundCmd).l
	move.w	#3,-(sp)
	jsr	(song).l
.0
	jsr	(CupWaitFrame).l
	jsr	(CupBuildSprites).l
	jsr	(CupReadPads).l
	bra.s	.0

CupReadPads	;IDA: sub_A18CC. 95 only. StanleyCupScreen: the buttons of all pads; start leaves StanleyCupScreen (drops the return address)
	jsr	(ReadJoy1).l
	move.w	d3,-(sp)
	jsr	(ReadJoy2).l
	or.w	d3,(sp)
	tst.w	(FourWayPlay).w
	beq.w	.0
	jsr	(ReadJoy3).l
	or.w	d3,(sp)
	jsr	(ReadJoy4).l
	or.w	d3,(sp)
.0
	move.w	(sp)+,d3
	btst	#7,d3
	bne.w	CupExit
	rts

CupWaitFrame	;IDA: sub_A1900. 95 only. StanleyCupScreen: wait for the next vblank (vcount)
	move.w	(vcount).w,d0
.0
	cmp.w	(vcount).w,d0
	beq.s	.0
	rts

CupExit	;95 only. Leave StanleyCupScreen (CupReadPads on start: drop its return address). 95 only. Leave StanleyCupScreen (CupReadPads on start: drop its return address)
	addq.w	#4,sp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

CupVBlank	;IDA: unk_A1914. 95 only. StanleyCupScreen vblank: the sprites (Sattsize), cramfade, vcount, the music; nothing with disflags bit 2; rte
	movem.l	d0-d7/a0-a6,-(sp)
	btst	#2,(disflags).w
	bne.w	.1
	movea.w	#(Satt-M68K_RAM),a0
	move.w	(Sattsize).w,d0
	beq.w	.0
	clr.w	(Sattsize).w
	move.w	(VSPRITES).w,d1
	jsr	(DoDMA).l
.0
	jsr	(cramfade).l
.1
	addq.w	#1,(vcount).w
	jsr	(p_music_vblank).l
	movem.l	(sp)+,d0-d7/a0-a6
	rte

CupDrawTeam	;IDA: sub_A1952. 95 only. StanleyCupScreen: the team block of the winner (cupwinner, Teamblocksmap)
	movem.l	d0-d7/a0-a3,-(sp)
	jsr	(printz).l
	String	$FE,$17,$16,$0
	move.w	(cupwinner).w,d1
	add.w	d1,d1
	movea.l	#Teamblocksmap,a1
	adda.l	4(a1),a1
	movea.w	#$69A,a2
	clr.w	d0
	move.w	(a1),d2
	moveq	#2,d3
	move.w	(teamblocksmapptr).w,d4
	moveq	#0,d5
	jsr	(dobitmap).l
	movem.l	(sp)+,d0-d7/a0-a3
	rts

CupBuildSprites	;IDA: sub_A198E. 95 only. StanleyCupScreen: the sprite list at Satt from the animated CupSprites frame (cupframe, one step every $A cupticks over $E frames), Sattsize
	movea.w	#(Satt-M68K_RAM),a6
	moveq	#1,d6
	movea.l	#CupSprites,a0
	move.w	(energybarchars).w,d3
	ori.w	#$8000,d3
	move.w	#$80,d0
	move.w	#$80,d1
	move.w	(cupframe).w,d2
	addq.w	#1,(cupticks).w
	cmpi.w	#$A,(cupticks).w
	blt.w	.0
	clr.w	(cupticks).w
	addq.w	#1,(cupframe).w
	cmpi.w	#$E,(cupframe).w
	blt.w	.0
	clr.w	(cupframe).w
.0
	jsr	(AddSpriteFrame).l
	cmpa.w	#$BC1E,a6
	bne.w	.1
	clr.l	(a6)+
	clr.l	(a6)+
.1
	clr.b	-5(a6)
	move.l	a6,d0
	subi.l	#Satt,d0
	lsr.w	#1,d0
	move.w	d0,(Sattsize).w
	rts

AddSpriteFrame	;IDA: sub_A19F8. 95 only. Add the sprites of frame d2 of a0, offset by d0 / d1, to the sprite list at a6 (d6 sprites, at most $40)
	cmp.w	#$40,d6
	bge.w	.2
	movem.l	d0-d5/a0,-(sp)
	adda.l	4(a0),a0
	add.w	d2,d2
	move.w	2(a0,d2.w),d4
	sub.w	(a0,d2.w),d4
	lsr.w	#3,d4
	subq.w	#1,d4
	adda.w	(a0,d2.w),a0
.0
	move.w	2(a0),d2
	andi.w	#$F000,d2
	lsr.w	#1,d2
	move.w	d2,-(sp)
	move.w	4(a0),d2
	andi.w	#$7FF,d2
	or.w	(sp)+,d2
	add.w	d3,d2
	move.w	(a0),(a6)
	add.w	d1,(a6)+
	move.b	2(a0),(a6)+
	move.b	d6,(a6)+
	move.w	d2,(a6)+
	move.w	6(a0),(a6)
	add.w	d0,(a6)+
	addq.w	#1,d6
	cmp.w	#$40,d6
	beq.w	.1
	addq.w	#8,a0
	dbf	d4,.0
.1
	movem.l	(sp)+,d0-d5/a0
.2
	rts
