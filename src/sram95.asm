; $009722  Adapted from sram94.asm: save data
;	NHL 95 segment $9722-$9AC7, from lst/nhl95.bin.lst. The battery save RAM: 95 keeps $8000 bytes (94: $2000) on the odd bytes at
;	$200000, copies them to M68K_RAM at power on (InitSaveRAM) and protects them with a sum / complement checksum in bytes $7FFE-$7FFF.
;	94 InitSaveRAM, SRAMWaitVblank, VBcount, ValidateSRAM, ClearSRAM, WriteSRAM, MakeSRAMChecksum, ReadSRAM, then three routines new in 95
;	that build the season leader lists from the save RAM stats. Opening (hockey95) follows at $9AC8.
;	95 addresses RAM with (x).l here where 94 used (x).w, and indexes the save RAM with a long (d0.l). The IDA dc.b at $981E (VBcount)
;	and $9972-$9AC7 (the leader list routines, no xref) are written as instructions.

InitSaveRAM	;IDA: sub_9722. Called from Begin. Copy the $8000 byte save RAM (the odd bytes at $200000) to M68K_RAM and check its checksum
	;(ValidateSRAM; ValidSRAM 0 = good, -1 = bad). A bad save RAM is cleared (ClearSRAM) and read again. Two power-on tests that never return:
	;Start+A+C held writes and reads back every bit of every byte, writes $12,$34,$56,$78 to bytes 0-3 and flashes the screen green, or red at the
	;first bad byte; Start+B+C held flashes green if bytes 0-3 are $12345678, else red
	move.l	#VBcount,(vbint).l
	move	#$2500,sr
	clr.w	(ValidSRAM).l	;good until checked
	jsr	(ReadJoy1).l	;get joypad buttons held
	move.w	d3,d0	;d3 = buttons held
	movea.l	#$200000,a0	;move SRAM address into a0
	move.w	#$E,d3	;red ($00E), fading by 2 a frame
	move.w	#2,d4	;move 2 into d4
	cmp.b	#$E0,d0	;Start+A+C button held down
	beq.w	.setiterator	;branch if held down
	cmp.b	#$B0,d0	;Start+B+C buttons held down
	beq.w	.setiterator2	;branch if held down
	moveq	#0,d0	;move 0 into d0
	move.l	#$8000,d1	;$8000 bytes (94: $2000)
	movea.l	#M68K_RAM,a0	;start of RAM into a0
	bsr.w	ReadSRAM	;Writes SRAM to RAM
	bsr.w	ValidateSRAM
	tst.w	(ValidSRAM).l
	bpl.w	.ex
	bsr.w	ClearSRAM
	moveq	#0,d0
	move.l	#$8000,d1
	movea.l	#M68K_RAM,a0
	bsr.w	ReadSRAM	;Writes SRAM to RAM
	bsr.w	ValidateSRAM
.ex
	rts
.setiterator
	move.w	#$7FFF,d2	;$8000 bytes (94: $2000)
.SRAMloop
	move.w	#1,d1	;bit 0, then up to bit 7
	move.w	#7,d0
.setto80
	move.w	d1,(a0)
	cmp.b	1(a0),d1
	bne.w	.loadcolor
	lsl.w	#1,d1
	dbf	d0,.setto80
	adda.w	#2,a0
	dbf	d2,.SRAMloop
	movea.l	#$200000,a0
	move.l	#$120034,(a0)+	;bytes 0-3 = $12,$34,$56,$78 (word writes: the low byte goes to the odd SRAM byte)
	move.l	#$560078,(a0)+
	move.w	#$E0,d3	;green ($0E0), fading by $20 a frame
	move.w	#$20,d4
.loadcolor
	move.w	d3,d0	;move d3 (color of flashing screen) to d0
.flashscreen
	move.l	#$C0000000,(VDP_CTRL).l	;cram write 0: the background colour
	move.w	d0,d1
	and.w	d3,d1
	move.w	d1,(VDP_DATA).l
	bsr.w	SRAMWaitVblank	;wait a vblank
	sub.w	d4,d0
	bra.s	.flashscreen
.setiterator2
	move.w	#3,d1
.SRAMloop2
	adda.w	#1,a0	;odd byte
	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.SRAMloop2
	cmp.l	#$12345678,d0
	bne.s	.loadcolor	;branch if not equal (screen flashes red)
	move.w	#$E0,d3	;green
	move.w	#$20,d4
	bra.s	.loadcolor	;branch (screen flashes green)

SRAMWaitVblank	;IDA: sub_9816. Wait for the next vblank (vcountwait). Called from InitSaveRAM
	jsr	(vcountwait).l
	rts

VBcount	;IDA dc.b at $981E. vbint handler while InitSaveRAM runs: vcount + 1 only. 95 writes addi.w #1 (94: addq.w)
	opt	oaq-	;keep the addi (SNASM would make it addq)
	addi.w	#1,(vcount).l	;vblank with counter only
	opt	oaq+
	rte

ValidateSRAM	;IDA: sub_9828. Check the save RAM copy in M68K_RAM: byte $7FFF must be the sum of bytes 0-$7FFD, byte $7FFE its complement,
	;and (95) the first word must be $64. ValidSRAM = 0 if they match, -1 if not. Called from InitSaveRAM
	move.w	#$7FFD,d1	;set iterator to $7FFD (94: $1FFD)
	clr.w	d0	;clear d0
	lea	(M68K_RAM).l,a0	;set a0 to start of RAM
.loop
	add.b	(a0)+,d0	;add value at a0 to d0 and increment a0
	dbf	d1,.loop	;loop through RAM d1 times
	clr.w	d1	;clear d1
	cmpi.w	#$64,(M68K_RAM).l	;95: ClearSRAM writes $64 to the first word
	beq.w	.chk
	addq.w	#1,d1
.chk
	cmp.b	1(a0),d0	;compare data at 1+a0 ($7FFF RAM address) to d0
	beq.w	.0	;branch if equal
	addq.w	#1,d1	;add 1 to d1
.0
	not.w	d0	;toggle bits in d0 from 1->0 and vice-versa
	cmp.b	(a0),d0	;compare byte at a0 ($7FFE) with d0
	beq.w	.1	;branch if equal
	addq.w	#1,d1	;add 1 to d1 if not
.1
	swap	d0	;swap d0 word size
	move.b	(a0),d0	;move data at a0 into d0
	not.b	d0	;toggle bits
	cmp.b	1(a0),d0	;compare data a0+1 with d0
	beq.w	.2	;branch if equal
	addq.w	#1,d1	;add 1 to d1 if not
.2
	swap	d0	;swap d0 word size
	tst.w	d1	;test d1
	bne.w	.3	;branch if d1 not 0
	clr.w	(ValidSRAM).l	;clear
	bra.w	.x	;branch to exit
.3
	st	(ValidSRAM).l	;set
.x
	rts

ClearSRAM	;IDA: sub_9888. Clear the $8000 bytes of RAM and save RAM: zero M68K_RAM $0-$7FFF, put the 95 defaults in it (rosters, lines,
	;created players), write it to the save RAM, then write the $64 version word to bytes 0-1 and MakeSRAMChecksum. Called from InitSaveRAM
	lea	(M68K_RAM).l,a0
	move.l	#$1FFF,d0	;$2000 longs (94: $2000 bytes)
	clr.l	d1
.loop
	move.l	d1,(a0)+
	dbf	d0,.loop
	jsr	(DefaultRosters).l	;95 only
	jsr	(DefaultLineData).l	;95 only
	jsr	(ClearCreatedPlayers).l	;95 only
	jsr	(NullSaveClear).l	;95 only, an rts
	moveq	#0,d0
	move.l	#$8000,d1
	movea.l	#M68K_RAM,a0
	bsr.w	WriteSRAM
	move.l	#0,d0
	moveq	#2,d1
	move.w	#$64,(M68K_RAM).l	;version word: ValidateSRAM wants $64 here
	movea.l	#M68K_RAM,a0
	bsr.w	WriteSRAM
	bsr.w	MakeSRAMChecksum
	rts

WriteSRAM	;IDA: sub_98E6. Write data from a0 into SaveRAM: d1 = number of bytes, d0 = first save RAM byte (each byte is the odd byte of a word at
	;$200000 + d0 * 2). Called from ClearSRAM, MakeSRAMChecksum and the save code
	movem.l	d0-d2/a0-a1,-(sp)
	movea.l	#$200000,a1
	add.l	d0,d0
	subq.l	#1,d1
	clr.w	d2
.loop
	move.b	(a0)+,d2
	move.w	d2,(a1,d0.l)
	addq.l	#2,d0
	dbf	d1,.loop
	movem.l	(sp)+,d0-d2/a0-a1
	rts

MakeSRAMChecksum	;IDA: sub_9908. Sum save RAM bytes 0-$7FFD (read in place; 94 read them to M68K_RAM first), put the sum in SRAMChecksum+1 and
	;its complement in SRAMChecksum, and write those two bytes to save RAM bytes $7FFE-$7FFF. Skipped while GameFlags bit 7 is set (a batch of
	;save RAM writes in progress). Called from ClearSRAM and the save code (ReadLineData, the season code ...)
	btst	#7,(GameFlags).l
	bne.w	.x
	movem.l	d0-d2/a0-a1,-(sp)
	movea.l	#$200000,a1
	move.l	#$7FFD,d1
	clr.l	d0
	clr.l	d2
.loop
	add.b	1(a1,d0.l),d2
	addq.l	#2,d0
	dbf	d1,.loop
	move.w	d2,d0
	movea.l	#SRAMChecksum,a0
	move.b	d0,1(a0)
	not.w	d0
	move.b	d0,(a0)
	moveq	#2,d1
	move.l	#$7FFE,d0
	bsr.s	WriteSRAM
	movem.l	(sp)+,d0-d2/a0-a1
.x
	rts

ReadSRAM	;IDA: sub_9952. move into a0 location and increment: copy d1 save RAM bytes from byte d0 (the odd bytes at $200000 + d0 * 2) to (a0)+.
	;Called from InitSaveRAM and the save code
	movem.l	d0-d2/a0-a1,-(sp)
	movea.l	#$200000,a1
	add.l	d0,d0
	subq.l	#1,d1
.loop
	move.b	1(a1,d0.l),d2
	move.b	d2,(a0)+
	addq.l	#2,d0
	dbf	d1,.loop
	movem.l	(sp)+,d0-d2/a0-a1
	rts

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Season leader lists. New in 95 (IDA dc.b, no xref). The Individual Leaders screen (stats95_01) runs one of these through a5
;	(movea.l #x,a5 at $949EC-$94A46). Save RAM stats are words (2 save RAM bytes, the odd bytes of 2 words) at byte d0 + 2 * player.
;	In: d0 = first save RAM byte of the stat, d1 = 2 * players ($548: 26 teams of 26), a0 = value list, a3 = player number list,
;	a2 = count word. Out: one value / player number pair per listed player, (a2) = the number listed
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

BuildLeaderList	;$9972. One stat: list each player whose stat is above 0 (goals $21A4, assists $2720)
	movem.l	d0-d3/a0-a3,-(sp)
	movea.l	#$200000,a1
	add.l	d0,d0	;save RAM byte -> word offset
	asr.w	#1,d1	;players
	subq.l	#1,d1
	clr.w	(a2)	;none listed
	clr.l	d3	;player number
.loop
	move.b	1(a1,d0.l),d2	;stat high byte
	lsl.w	#8,d2
	move.b	3(a1,d0.l),d2	;stat low byte
	tst.w	d2
	beq.w	.next	;0: not listed
	bmi.w	.next	;negative: not listed
	move.w	d3,(a3)+
	addq.w	#1,(a2)
	move.w	d2,(a0)+
.next
	addq.l	#4,d0	;next player's stat
	addq.l	#1,d3
	dbf	d1,.loop
	movem.l	(sp)+,d0-d3/a0-a3
	rts

BuildLeaderListSum	;$99AE. Two stats added: the stat at d0 (a negative one counts 0) plus the stat $57C save RAM bytes on
	;(goals $21A4 + assists $2720 = points). Lists each player whose sum is not 0
	movem.l	d0-d5/a0-a3,-(sp)
	movea.l	#$200000,a1
	move.l	d0,d4
	addi.l	#$57C,d4	;the second stat
	add.l	d4,d4
	add.l	d0,d0
	asr.w	#1,d1
	subq.l	#1,d1
	clr.w	(a2)
	clr.l	d3
.loop
	move.b	1(a1,d0.l),d2
	lsl.w	#8,d2
	move.b	3(a1,d0.l),d2
	tst.w	d2
	bpl.w	.add
	clr.w	d2	;negative counts 0
.add
	move.b	1(a1,d4.l),d5
	lsl.w	#8,d5
	move.b	3(a1,d4.l),d5
	add.w	d5,d2
	beq.w	.next
	move.w	d3,(a3)+
	addq.w	#1,(a2)
	move.w	d2,(a0)+
.next
	addq.l	#4,d0
	addq.l	#4,d4
	addq.l	#1,d3
	dbf	d1,.loop
	movem.l	(sp)+,d0-d5/a0-a3
	rts

BuildLeaderListPct	;$9A04. A ratio: 100 * the stat $2BE0 save RAM bytes after d0 (low 15 bits) / the stat $1074 bytes after d0. A player is
	;listed when the stat word at d0 is negative (bit 15 set), the stat $15F0 bytes after d0 (low 15 bits) is not 0, and the divisor is not 0 and
	;at least the minimum: (SeasonDay - SeasonStartDay) * 25 / (SeasonLength * 84)
	movem.l	d0-d7/a0-a3,-(sp)
	movea.l	#$200000,a1
	move.l	d0,d4
	addi.l	#$1074,d4	;the divisor stat
	add.l	d4,d4
	add.l	d0,d0
	asr.w	#1,d1
	subq.l	#1,d1
	clr.w	(a2)
	clr.w	d6
	move.b	(SeasonDay).l,d6
	sub.b	(SeasonStartDay).l,d6
	clr.w	d3
	move.b	(SeasonLength).l,d3
	mulu.w	#$19,d6
	mulu.w	#$54,d3
	divu.w	d3,d6	;d6 = minimum divisor
	clr.l	d3
.loop
	move.b	1(a1,d0.l),d2
	lsl.w	#8,d2
	move.b	3(a1,d0.l),d2
	tst.w	d2
	bpl.w	.next	;bit 15 clear: not listed
	move.l	d0,-(sp)
	movem.l	d0-d1,-(sp)
	move.l	d0,d1
	addi.l	#$15F0,d1
	clr.w	d0
	move.b	1(a1,d1.l),d0
	asl.w	#8,d0
	move.b	3(a1,d1.l),d0
	andi.w	#$7FFF,d0
	movem.l	(sp)+,d0-d1
	bne.w	.get
	move.l	(sp)+,d0
	bra.w	.next
.get
	addi.l	#$2BE0,d0	;the dividend stat
	move.b	1(a1,d0.l),d2
	lsl.w	#8,d2
	move.b	3(a1,d0.l),d2
	move.l	(sp)+,d0
	andi.l	#$7FFF,d2
	move.b	1(a1,d4.l),d5
	lsl.w	#8,d5
	move.b	3(a1,d4.l),d5
	tst.w	d5
	beq.w	.next
	cmp.w	d6,d5
	blt.w	.next	;below the minimum
	mulu.w	#$64,d2
	divu.w	d5,d2	;100 * dividend / divisor
	move.w	d3,(a3)+
	addq.w	#1,(a2)
	move.w	d2,(a0)+
.next
	addq.l	#4,d0
	addq.l	#4,d4
	addq.l	#1,d3
	dbf	d1,.loop
	movem.l	(sp)+,d0-d7/a0-a3
	rts
