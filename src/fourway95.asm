; $07DEA0  Adapted from fourway94.asm: four-player adaptor
;	NHL 95 segment $7DEA0-$7E0DF, from lst/nhl95.bin.lst. title94 LoadHomeTeamGfx and TeamGfxList, penalty94 EASNLogo and setupEASNmap,
;	video94 FormatAndPrintTime and PeriodLabelTable, the 95 AnyPadAssigned, then fourway94 Detect4WayPlay and the unused Read4WayPad1-4,
;	which 95 reads through its own Read4WayPort1 / Read4WayPort2 (the 94 Set4WayPlayerStub / Set4WayPlayer are gone). sound95_02 (the 94
;	Z80 program) follows at $7E0E0.
;	IDA dc.b written as instructions: TeamGfxList, FormatAndPrintTime, PeriodLabelTable, Read4WayPad1 ... ReadJoyJmp ($7E02E-$7E0DF).
;	IDA hid the printz String in EASNLogo as instructions.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp; fixopcodes.js patches the
;	cmp encoding after assembly.

LoadHomeTeamGfx	;IDA: sub_7DEA0 (title94). Load the HomeTeam graphics of TeamGfxList to VRAM d4 - $18 (DoDMA_clearCallbackPointer). Called from setupice
	;and ReloadIceGfx (video95_03)
	move.w	d0,-(sp)
	subi.w	#$18,d4
	movea.l	#TeamGfxList,a2
	move.w	(HomeTeam).w,d0
	asl.w	#2,d0
	movea.l	(a2,d0.w),a2
	addq.w	#8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	move.w	(sp)+,d0
	rts
TeamGfxList	;IDA: unk_7DEC2 (dc.b). LoadHomeTeamGfx: one address per team (TeamList order) in the 95 ArenaGfxBank (ASE and ASW share one)
	dc.l	ArenaGfxBank,ArenaGfxBank+$4BFA,ArenaGfxBank+$30A,ArenaGfxBank+$614
	dc.l	ArenaGfxBank+$91E,ArenaGfxBank+$C28,ArenaGfxBank+$F32,ArenaGfxBank+$123C
	dc.l	ArenaGfxBank+$1546,ArenaGfxBank+$1850,ArenaGfxBank+$1B5A,ArenaGfxBank+$1E64
	dc.l	ArenaGfxBank+$216E,ArenaGfxBank+$2478,ArenaGfxBank+$2782,ArenaGfxBank+$2A8C
	dc.l	ArenaGfxBank+$2D96,ArenaGfxBank+$30A0,ArenaGfxBank+$33AA,ArenaGfxBank+$36B4
	dc.l	ArenaGfxBank+$39BE,ArenaGfxBank+$3CC8,ArenaGfxBank+$3FD2,ArenaGfxBank+$42DC
	dc.l	ArenaGfxBank+$45E6,ArenaGfxBank+$48F0,ArenaGfxBank+$4F04,ArenaGfxBank+$4F04

EASNLogo	;IDA: sub_7DF32 (penalty94). 93 name. Draw the EASN logo map at x 2, y $19 (94: x 1) on the vertical ice rink if no power play. Called
	;from PrintScores1 (video95_03)
	btst	#5,(sflags2).w	;sf2pwrplay
	bne.w	.x
	bsr.w	printz
	String	$BF,2,$19	;IDA: ori.b / move.b d0,-(a4)
	movea.l	#EASNmap,a1	;93 EASNmap
	adda.l	4(a1),a1
	movea.w	#$69A,a2	;a zero long (main95 $69A): no palettes
	clr.w	d0
	clr.w	d1
	move.w	(a1),d2	;width and height from the map header
	move.w	2(a1),d3
	move.w	(EASNcset).w,d4	;93 EASNcset
	clr.w	d5
	bra.w	dobitmap
.x
	rts

setupEASNmap	;IDA: sub_7DF6A (penalty94 EASNLogo+$14). Load the EASN logo tiles at EASNcset. Called from setupice and ReloadIceGfx (video95_03)
	move.w	(EASNcset).w,d4
	movea.l	#EASNmap+8,a2
	jsr	(DoDMA_clearCallbackPointer).l
	rts

FormatAndPrintTime	;$7DF7C. IDA dc.b, no xref. 93 name. d0 bits 14-15 = period, bits 0-13 = seconds
	swap	d0
	clr.w	d0
	rol.l	#2,d0
	movea.l	#PeriodLabelTable,a1
	bsr.w	PrintSmallListItem	;94 PrintStringFromList
	addq.w	#2,(printx).w
	swap	d0
	lsr.w	#2,d0
	bsr.w	PushTime
	bra.w	print
PeriodLabelTable	;$7DF9C. IDA dc.b. 93 name. String list for FormatAndPrintTime: " 1", " 2", " 3", "OT"
	String	' 1'
	String	' 2'
	String	' 3'
	String	'OT'

AnyPadAssigned	;IDA: sub_7DFAC. 95 only. Z clear when any pad is on a team (cont1team ... cont4team). Called from menu95
	movem.w	d0,-(sp)
	move.w	(cont1team).w,d0
	or.w	(cont2team).w,d0
	or.w	(cont3team).w,d0
	or.w	(cont4team).w,d0
	movem.w	(sp)+,d0
	rts

Detect4WayPlay	;IDA: sub_7DFC6. detect the 4 way play adaptor (EA 4 Way Play) on port 2: FourWayPlay = 1 when found. Called from Begin (main95)
	move.w	#0,(IO_Z80RES).l
	move.b	#$40,(IO_CT1_CTRL+1).l
	move.b	#$43,(IO_CT2_CTRL+1).l
	nop
	move.b	#$7C,(IO_CT2_DATA+1).l
	nop
	move.b	#$7F,(IO_CT2_CTRL+1).l
	nop
	move.b	#$7C,(IO_CT2_DATA+1).l
	nop
	move.b	(IO_CT1_DATA+1).l,d0
	andi.b	#3,d0
	cmp.b	#0,d0
	bne.s	.none
	move.w	#1,(FourWayPlay).w
	bra.s	.x
.none
	move.w	#0,(FourWayPlay).w
	move.b	#$40,(IO_CT2_CTRL+1).l
.x
	move.w	#$100,(IO_Z80RES).l
	rts

Read4WayPad1	;$7E02E. IDA dc.b, no xref. unused: read 4 way play pad 1 (95: Read4WayPort1 with the pad word swapped in)
	move.b	#0,(IO_CT2_DATA+1).l	;4 way play: select pad
	move.w	(pad4waysave1).w,(pad4wayword).w
	jsr	(Read4WayPort1).l
	move.w	(pad4wayword).w,(pad4waysave1).w
	rts
Read4WayPad2	;IDA dc.b, no xref. unused: the same for pad 2
	move.b	#$10,(IO_CT2_DATA+1).l	;4 way play: select pad
	move.w	(pad4waysave2).w,(pad4wayword).w
	jsr	(Read4WayPort1).l
	move.w	(pad4wayword).w,(pad4waysave2).w
	rts
Read4WayPad3	;IDA dc.b, no xref. unused: the same for pad 3
	move.b	#$20,(IO_CT2_DATA+1).l	;4 way play: select pad
	move.w	(pad4waysave3).w,(pad4wayword).w
	jsr	(Read4WayPort1).l
	move.w	(pad4wayword).w,(pad4waysave3).w
	rts
Read4WayPad4	;IDA dc.b, no xref. unused: the same for pad 4
	move.b	#$30,(IO_CT2_DATA+1).l	;4 way play: select pad
	move.w	(pad4waysave4).w,(pad4wayword).w
	jsr	(Read4WayPort1).l
	move.w	(pad4wayword).w,(pad4waysave4).w
	rts
Read4WayPort1	;$7E09E. IDA dc.b. 95 only. ReadJoy1 for the pad on port 1 (a0 = its data port): d1 = new presses against pad4wayword
	move.l	a0,-(sp)
	movea.l	#IO_CT1_DATA+1,a0
	bsr.w	ReadJoyJmp
	movea.l	(sp)+,a0
	move.w	(pad4wayword).w,d2
	move.w	d1,(pad4wayword).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts
Read4WayPort2	;$7E0BC. IDA dc.b, no xref. 95 only. The same for port 2, against pad4wayword2
	move.l	a0,-(sp)
	movea.l	#IO_CT2_DATA+1,a0
	bsr.w	ReadJoyJmp
	movea.l	(sp)+,a0
	move.w	(pad4wayword2).w,d2
	move.w	d1,(pad4wayword2).w
	move.w	d1,d3
	eor.w	d1,d2
	and.w	d2,d1
	rts
ReadJoyJmp	;$7E0DA. IDA dc.b. 95 only. jmp ReadJoy (video95_02)
	jmp	(ReadJoy).l
