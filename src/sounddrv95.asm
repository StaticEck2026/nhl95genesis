;	NHL 95 sound driver. Retail $00AF44-$0676D7, from lst/nhl95.bin.lst. New in 95: 94 has the sound94 driver (most of it still
;	sits in sound95_01, unused). The 68000 side of a song player: SndDriver takes a command in d0 (95 calls it through SoundCmd), runs
;	up to 8 songs of MIDI style events, and keeps the Z80 program fed. Then the Z80 program (Z80Program) and the sound bank
;	(SoundBanks, $D8EC to the end). Split from the sound95_01 placeholder: sound95_01 now starts at $676D8.
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp; fixopcodes.js patches the
;	cmp encoding after assembly.

	opt	oaq-,osq-,oz-	;the driver writes addi / subi #1-8 and 0(An) (SNASM would make them addq / subq and (An))

SndDriver	;IDA: sub_AF44. 95 sound driver entry (SoundCmd, sound95_01). d0 = command 0-$F, branch to its handler; carry set and d0 = 1
	;for a bad command. 0 SndLoadZ80, 1 SndUpdate, 2 off, 3 on, 4 SndStartSeq, 5 SndStopSeq, 6 SndSetBank, 7 SndLoadList, 8 SndFreeBlocks,
	;9 SndResetBlocks, $A SndSendZ80, $B SndReadBlock, $C SndWriteBlock, $D SndPauseZ80, $E SndResumeZ80, $F SndStopAll
	tst.w	d0
	bne.s	.0
	bra.w	SndLoadZ80
.0
	subi.w	#1,d0
	bne.s	.1
	bra.w	SndUpdate
.1
	subi.w	#1,d0
	bne.s	.2
	move.l	a0,-(sp)
	lea	(SndDrvRAM).l,a0
	clr.w	(a0)
	movea.l	(sp)+,a0
	clr.w	d0
	rts
.2
	subi.w	#1,d0
	bne.s	.3
	move.l	a0,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	#$1234,(a0)
	movea.l	(sp)+,a0
	clr.w	d0
	rts
.3
	subi.w	#1,d0
	bne.s	.4
	bra.w	SndStartSeq
.4
	subi.w	#1,d0
	bne.s	.5
	bra.w	SndStopSeq
.5
	subi.w	#1,d0
	bne.s	.6
	bra.w	SndSetBank
.6
	subi.w	#1,d0
	bne.s	.7
	bra.w	SndLoadList
.7
	subi.w	#1,d0
	bne.s	.8
	bra.w	SndFreeBlocks
.8
	subi.w	#1,d0
	bne.s	.9
	bra.w	SndResetBlocks
.9
	subi.w	#1,d0
	bne.s	.10
	bra.w	SndSendZ80
.10
	subi.w	#1,d0
	bne.s	.11
	bra.w	SndReadBlock
.11
	subi.w	#1,d0
	bne.s	.12
	bra.w	SndWriteBlock
.12
	subi.w	#1,d0
	bne.s	.13
	bra.w	SndPauseZ80
.13
	subi.w	#1,d0
	bne.s	.14
	bra.w	SndResumeZ80
.14
	subi.w	#1,d0
	bne.s	.15
	bra.w	SndStopAll
.15
	move.w	#1,d0
	ori	#1,ccr
	rts

SndLoadZ80	;IDA: loc_B006. Command 0: copy the Z80 program a0 (d1 bytes; it must start with JP $00xx) to Z80 RAM, reset the Z80, wait
	;for it to set Z80_RAM+$4F, clear the song slots and notes, and turn the driver on. Carry set and d0 = 6 for a bad program
	movem.l	d1/a0-a2,-(sp)
	move	sr,-(sp)
	move	#$2700,sr
	move.w	#$100,(IO_Z80BUS).l
	move.w	#$100,(IO_Z80RES).l
	cmpi.b	#$C3,(a0)
	bne.s	.1
	cmpi.b	#0,1(a0)
	bne.s	.1
	lea	(Z80_RAM).l,a1
	subi.w	#1,d1
.0
	move.b	(a0)+,(a1)+
	dbf	d1,.0
	bra.s	.2
.1
	move.w	#6,d0
	bra.w	.12
.2
	move.w	#0,(IO_Z80RES).l
	move.w	#0,(IO_Z80BUS).l
	move.w	#$1F4,d0
.3
	dbf	d0,.3
	move.w	#$100,(IO_Z80RES).l
.4
	bsr.w	Z80BusRequest
	cmpi.b	#$FF,(Z80_RAM+$4F).l
	beq.s	.6
	bsr.w	Z80BusRelease
	move.w	#$1388,d0
.5
	dbf	d0,.5
	bra.s	.4
.6
	bsr.w	Z80BusRelease
	lea	(SndBanks).l,a0
	move.w	#3,d0
.7
	move.l	#$FFFFFFFF,(a0)+
	dbf	d0,.7
	lea	(SndSeqPtr).l,a0
	move.w	#7,d0
.8
	move.l	#$FFFFFFFF,(a0)+
	dbf	d0,.8
	lea	(SndSeqPos).l,a0
	move.w	#7,d0
.9
	move.l	#0,(a0)+
	dbf	d0,.9
	lea	(SndSeqId).l,a0
	move.w	#7,d0
.10
	move.w	#$FFFF,(a0)+
	dbf	d0,.10
	lea	(SndSeqState).l,a0
	move.w	#7,d0
.11
	move.l	#0,(a0)+
	dbf	d0,.11
	bsr.w	SndClearNotes
	lea	(SndDrvRAM).l,a0
	move.w	#$1234,(a0)
	andi	#$FE,ccr
	clr.w	d0
	bra.s	.13
.12
	ori	#1,ccr
.13
	move	(sp)+,sr
	movem.l	(sp)+,d1/a0-a2
	rts

SndUpdate	;IDA: loc_B10C. Command 1, once a frame: note timers (SndUpdateNotes), sample streaming (SndStreamZ80), then step the 8 song
	;slots: wait out each slot's delay, then send its events ($9x note on, $Bx controller, $Cx program, $Ex pitch bend) to the Z80 until the
	;next delay. Controller $75 loops the song; status $FF ends it
	movem.l	d0-d7/a0-a6,-(sp)
	lea	(SndDrvRAM).l,a0
	cmpi.w	#$1234,(a0)
	bne.w	.22
	bsr.w	SndUpdateNotes
	bsr.w	SndStreamZ80
	lea	(SndSeqIndex).l,a0
	move.w	#0,(a0)
	lea	(SndSeqPtr).l,a6
	lea	(SndSeqPos).l,a5
	lea	(SndSeqWait).l,a4
	lea	(SndSeqTempo).l,a3
	lea	(SndSeqFrac).l,a2
	lea	(SndSeqState).l,a1
.0
	move.w	(SndSeqIndex).l,d6
	lsl.w	#1,d6
	move.w	d6,d7
	lsl.w	#1,d7
	cmpi.l	#$FFFFFFFF,(a6,d7.w)
	beq.w	.21
	tst.w	(a4,d6.w)
	beq.s	.2
	move.w	(a3,d6.w),d1
	add.w	(a2,d6.w),d1
	move.w	d1,d2
	andi.w	#$FF,d2
	lsr.w	#8,d1
	add.w	(a1,d7.w),d1
	move.w	#0,(a1,d7.w)
	cmp.w	(a4,d6.w),d1
	bge.s	.1
	move.w	(a4,d6.w),d3
	sub.w	d1,d3
	move.w	d3,(a4,d6.w)
	move.w	d2,(a2,d6.w)
	bra.w	.21
.1
	sub.w	(a4,d6.w),d1
	lsl.w	#8,d1
	or.w	d2,d1
	move.w	d1,(a2,d6.w)
	clr.w	(a4,d6.w)
.2
	movea.l	(a6,d7.w),a0
	move.l	(a5,d7.w),d5
.3
	tst.b	(a0,d5.l)
	bpl.s	.4
	addi.l	#1,d5
	bra.s	.3
.4
	addi.l	#1,d5
	tst.b	(a0,d5.l)
	bpl.s	.5
	move.b	(a0,d5.l),2(a1,d7.w)
	addi.l	#1,d5
.5
	move.b	2(a1,d7.w),d0
	andi.b	#$F0,d0
	cmpi.b	#$90,d0
	bne.w	.10
	move.w	(SndSeqIndex).l,d0
	lsl.w	#8,d0
	lsl.w	#4,d0
	move.b	1(a0,d5.l),d0
	swap	d0
	move.b	(a0,d5.l),d0
	lsl.w	#8,d0
	move.b	2(a1,d7.w),d0
	bsr.w	SndPutZ80Cmd
	tst.w	d0
	beq.s	.6
	addi.w	#1,(a1,d7.w)
	bra.w	.21
.6
	clr.l	d0
	move.b	2(a0,d5.l),d0
	bpl.s	.7
	andi.l	#$7F,d0
	lsl.l	#7,d0
	or.b	3(a0,d5.l),d0
.7
	lsl.l	#8,d0
	move.w	(a3,d6.w),d3
	divu.w	d3,d0
	swap	d0
	move.b	(a0,d5.l),d0
	lsl.w	#8,d0
	move.w	(SndSeqIndex).l,d1
	lsl.w	#4,d1
	move.b	2(a1,d7.w),d0
	andi.b	#$F,d0
	or.b	d1,d0
	bsr.w	SndAddNote
	addi.l	#2,d5
.8
	tst.b	(a0,d5.l)
	bpl.s	.9
	addi.l	#1,d5
	bra.s	.8
.9
	addi.l	#1,d5
	bra.w	.19
.10
	cmpi.b	#$B0,d0
	bne.w	.14
	cmpi.b	#$12,(a0,d5.l)
	bne.s	.11
	bra.s	.12
.11
	cmpi.b	#$75,(a0,d5.l)
	bne.s	.12
	clr.l	d0
	move.b	1(a0,d5.l),d0
	lsl.l	#1,d0
	addi.l	#2,d0
	movea.l	(a6,d7.w),a0
	clr.l	d1
	move.b	(a0,d0.l),d1
	lsl.l	#8,d1
	move.b	1(a0,d0.l),d1
	clr.l	d0
	move.b	(a0),d0
	lsl.l	#8,d0
	move.b	1(a0),d0
	lsl.l	#1,d0
	addi.l	#2,d0
	add.l	d0,d1
	move.l	d1,d5
	move.l	d5,(a5,d7.w)
	bra.w	.0
.12
	move.w	(SndSeqIndex).l,d0
	lsl.w	#8,d0
	lsl.w	#4,d0
	move.b	1(a0,d5.l),d0
	swap	d0
	move.b	(a0,d5.l),d0
	lsl.w	#8,d0
	move.b	2(a1,d7.w),d0
	bsr.w	SndPutZ80Cmd
	tst.w	d0
	beq.s	.13
	addi.w	#1,(a1,d7.w)
	bra.w	.21
.13
	addi.l	#2,d5
	bra.s	.19
.14
	cmpi.b	#$C0,d0
	bne.s	.16
	move.w	(SndSeqIndex).l,d0
	lsl.w	#8,d0
	lsl.w	#4,d0
	swap	d0
	move.b	(a0,d5.l),d0
	lsl.w	#8,d0
	move.b	2(a1,d7.w),d0
	bsr.w	SndPutZ80Cmd
	tst.w	d0
	beq.s	.15
	addi.w	#1,(a1,d7.w)
	bra.s	.21
.15
	addi.l	#1,d5
	bra.s	.19
.16
	cmpi.b	#$E0,d0
	bne.s	.18
	move.w	(SndSeqIndex).l,d0
	lsl.w	#8,d0
	lsl.w	#4,d0
	swap	d0
	move.b	(a0,d5.l),d0
	lsl.w	#8,d0
	move.b	2(a1,d7.w),d0
	bsr.w	SndPutZ80Cmd
	tst.w	d0
	beq.s	.17
	addi.w	#1,(a1,d7.w)
	bra.s	.21
.17
	addi.l	#1,d5
	bra.s	.19
.18
	cmpi.b	#$FF,2(a1,d7.w)
	bne.s	.19
	move.l	#$FFFFFFFF,(a6,d7.w)
	bra.s	.21
.19
	move.l	d5,(a5,d7.w)
	clr.w	d2
	move.b	(a0,d5.l),d2
	bpl.s	.20
	andi.b	#$7F,d2
	lsl.w	#7,d2
	or.b	1(a0,d5.l),d2
.20
	move.w	d2,(a4,d6.w)
	tst.w	d2
	bne.s	.21
	bra.w	.0
.21
	lea	(SndSeqIndex).l,a0
	addi.w	#1,(a0)
	cmpi.w	#8,(a0)
	blt.w	.0
.22
	andi	#$FE,ccr
	movem.l	(sp)+,d0-d7/a0-a6
	rts

SndStartSeq	;IDA: loc_B3B8. Command 4: play song d1 (bank item type 3) in the first free slot, with d2-d4 (d4 = tempo). Carry set for no
	;free slot (d0 = 7) or no such song
	movem.l	d1-d4/a0-a1,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	d1,SndSeqArg1-SndDrvRAM(a0)
	move.w	d2,$134(a0)
	move.w	d3,$136(a0)
	move.w	d4,$138(a0)
	lea	(SndSeqPtr).l,a1
	clr.w	d0
.0
	cmpi.l	#$FFFFFFFF,(a1)+
	beq.s	.1
	addi.w	#1,d0
	cmpi	#8,d0	;retail CMPI (0C40). No .w, so fixopcodes.js leaves it
	bne.s	.0
	move.w	#7,d0
	bra.s	.2
.1
	move.w	d0,$130(a0)
	lsl.w	#8,d0
	lsl.w	#4,d0
	swap	d0
	move.w	#$1FF,d0
	bsr.w	SndPutZ80Cmd
	move.w	#3,d0
	bsr.w	SndFindBankItem
	bcs.s	.2
	clr.l	d1
	move.b	(a0),d1
	lsl.w	#8,d1
	move.b	1(a0),d1
	lsl.w	#1,d1
	addi.w	#2,d1
	lea	(SndDrvRAM).l,a1
	move.w	0(a1),-(sp)
	move.w	#0,0(a1)
	move.w	$130(a1),d0
	lsl.w	#2,d0
	move.l	a0,2(a1,d0.w)
	move.l	d1,$22(a1,d0.w)
	lea	(SndSeqState).l,a0
	move.l	#0,(a0,d0.w)
	move.w	$130(a1),d0
	lsl.w	#1,d0
	move.w	$138(a1),$62(a1,d0.w)
	move.w	#0,$52(a1,d0.w)
	move.w	#0,$72(a1,d0.w)
	move.w	$132(a1),$42(a1,d0.w)
	move.w	(sp)+,0(a1)
	clr.w	d0
	bra.s	.3
.2
	ori	#1,ccr
.3
	movem.l	(sp)+,d1-d4/a0-a1
	rts

SndStopSeq	;IDA: loc_B47A. Command 5: stop the slot playing song id d1 and release its notes. Carry set and d0 = 3 when none plays it
	movem.l	d1-d2/a0,-(sp)
	lea	(SndSeqId).l,a0
	clr.w	d0
.0
	cmp.w	(a0)+,d1
	beq.s	.1
	addi.w	#1,d0
	cmpi	#8,d0	;retail CMPI (0C40). No .w, so fixopcodes.js leaves it
	bne.s	.0
	move.w	#3,d0
	ori	#1,ccr
	bra.s	.2
.1
	lea	(SndDrvRAM).l,a0
	move.w	d0,SndStopSlot-SndDrvRAM(a0)
	lsl.w	#1,d0
	lea	(SndSeqId).l,a0
	move.w	#$FFFF,(a0,d0.w)
	lsl.w	#1,d0
	lea	(SndSeqPtr).l,a0
	move.l	#$FFFFFFFF,(a0,d0.w)
	lea	(SndDrvRAM).l,a0
	move.w	SndStopSlot-SndDrvRAM(a0),d0
	bsr.w	SndReleaseNotes
	clr.w	d0
.2
	movem.l	(sp)+,d1-d2/a0
	rts

SndPutZ80Cmd	;IDA: sub_B4DC. Queue the 4 byte Z80 command d0 (Z80_RAM+$D + 4 * count, count at +$C, waits while +$B is busy). d0 = -1 when it is full
	movem.l	d1/a0,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	0(a0),-(sp)
	move.w	#0,0(a0)
.0
	bsr.w	Z80BusRequest
	lea	(Z80_RAM+$B).l,a0
	tst.b	(a0)
	beq.s	.2
	move.w	#0,(IO_Z80BUS).l
	move.w	#$64,d1
.1
	subi.w	#1,d1
	bne.s	.1
	bra.s	.0
.2
	adda.l	#1,a0
	cmpi.b	#$10,(a0)
	blt.s	.3
	move.w	#$FFFF,d0
	bra.s	.4
.3
	clr.w	d1
	move.b	(a0),d1
	lsl.w	#2,d1
	move.b	d0,1(a0,d1.w)
	lsr.w	#8,d0
	move.b	d0,2(a0,d1.w)
	swap	d0
	move.b	d0,3(a0,d1.w)
	lsr.w	#8,d0
	move.b	d0,4(a0,d1.w)
	move.b	(a0),d1
	addi.b	#1,d1
	move.b	d1,(a0)
	clr.w	d0
.4
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a0
	move.w	(sp)+,0(a0)
	movem.l	(sp)+,d1/a0
	rts

SndUploadBlock	;IDA: sub_B55E. Copy d1 bytes from a0 to free Z80 RAM as block d0 (the 42 six byte entries at Z80_RAM+$100). Carry set: no room
	;(d0 = 4), already there (d0 = 3) or no free entry (d0 = 7)
	movem.l	d1-d2/a0-a1,-(sp)
	lea	(SndDrvRAM).l,a1
	move.w	(a1),-(sp)
	move.w	#0,(a1)
	bsr.w	Z80BusRequest
	move.b	(Z80_RAM+5).l,d2
	lsl.w	#8,d2
	move.b	(Z80_RAM+6).l,d2
	add.w	d1,d2
	cmpi.w	#$1F00,d2
	bcs.s	.0
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	move.w	#4,d0
	ori	#1,ccr
	bra.w	.6
.0
	lea	(Z80_RAM+$100).l,a1
	move.w	#$29,d2
.1
	cmpi.b	#0,(a1)
	bne.s	.2
	cmp.b	1(a1),d0
	bne.s	.2
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	move.w	#3,d0
	ori	#1,ccr
	bra.w	.6
.2
	adda.l	#6,a1
	dbf	d2,.1
	lea	(Z80_RAM+$100).l,a1
	move.w	#$29,d2
.3
	cmpi.b	#$FF,(a1)
	beq.s	.4
	adda.l	#6,a1
	dbf	d2,.3
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	move.w	#7,d0
	ori	#1,ccr
	bra.w	.6
.4
	move.b	#0,(a1)
	move.b	d0,1(a1)
	move.w	d1,d2
	move.b	d2,3(a1)
	lsr.w	#8,d2
	move.b	d2,2(a1)
	move.b	(Z80_RAM+5).l,d2
	move.b	d2,4(a1)
	move.b	(Z80_RAM+6).l,d2
	move.b	d2,5(a1)
	lea	(Z80_RAM).l,a1
	clr.l	d2
	move.b	(Z80_RAM+5).l,d2
	lsl.w	#8,d2
	move.b	(Z80_RAM+6).l,d2
	subi.w	#1,d1
.5
	move.b	(a0)+,(a1,d2.w)
	addi.w	#1,d2
	dbf	d1,.5
	move.b	d2,(Z80_RAM+6).l
	lsr.w	#8,d2
	move.b	d2,(Z80_RAM+5).l
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	clr.w	d0
.6
	movem.l	(sp)+,d1-d2/a0-a1
	rts

SndReadBlock	;IDA: loc_B67A. Command $B: copy Z80 block d1 to a0. Carry set and d0 = 3 when there is no such block
	movem.l	d1-d3/a0-a1,-(sp)
	lea	(SndDrvRAM).l,a1
	move.w	(a1),-(sp)
	move.w	#0,(a1)
	bsr.w	Z80BusRequest
	lea	(Z80_RAM+$100).l,a1
	move.w	#$29,d2
.0
	cmpi.b	#0,(a1)
	bne.s	.1
	cmp.b	1(a1),d1
	beq.s	.2
.1
	adda.l	#6,a1
	dbf	d2,.0
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	move.w	#3,d0
	ori	#1,ccr
	bra.w	.4
.2
	move.b	3(a1),d2
	lsl.w	#8,d2
	move.b	2(a1),d2
	subi.w	#1,d2
	move.b	4(a1),d3
	lsl.w	#8,d3
	move.b	5(a1),d3
	lea	(Z80_RAM).l,a1
.3
	move.b	(a1,d3.w),(a0)+
	addi.w	#1,d3
	dbf	d2,.3
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	clr.w	d0
.4
	movem.l	(sp)+,d1-d3/a0-a1
	rts

SndWriteBlock	;IDA: loc_B704. Command $C: copy a0 over Z80 block d1. Carry set and d0 = 3 when there is no such block
	movem.l	d1-d3/a0-a1,-(sp)
	lea	(SndDrvRAM).l,a1
	move.w	(a1),-(sp)
	move.w	#0,(a1)
	bsr.w	Z80BusRequest
	lea	(Z80_RAM+$100).l,a1
	move.w	#$29,d2
.0
	cmpi.b	#0,(a1)
	bne.s	.1
	cmp.b	1(a1),d1
	beq.s	.2
.1
	adda.l	#6,a1
	dbf	d2,.0
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	move.w	#3,d0
	ori	#1,ccr
	bra.w	.4
.2
	move.b	3(a1),d2
	lsl.w	#8,d2
	move.b	2(a1),d2
	subi.w	#1,d2
	move.b	4(a1),d3
	lsl.w	#8,d3
	move.b	5(a1),d3
	lea	(Z80_RAM).l,a1
.3
	move.b	(a0)+,(a1,d3.w)
	addi.w	#1,d3
	dbf	d2,.3
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	clr.w	d0
.4
	movem.l	(sp)+,d1-d3/a0-a1
	rts

SndPauseZ80	;IDA: loc_B78E. Command $D: Z80_RAM+$50 = $FF (pause)
	move.l	a0,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	(a0),-(sp)
	move.w	#0,(a0)
	btst	#8,(IO_Z80BUS).l
	bne.s	.0
	move.b	#$FF,(Z80_RAM+$50).l
	move.w	(sp)+,(a0)
	movea.l	(sp)+,a0
	rts
.0
	bsr.w	Z80BusRequest
	move.b	#$FF,(Z80_RAM+$50).l
	bsr.w	Z80BusRelease
	move.w	(sp)+,(a0)
	movea.l	(sp)+,a0
	rts

SndResumeZ80	;IDA: loc_B7CA. Command $E: Z80_RAM+$50 = 0 (resume)
	move.l	a0,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	(a0),-(sp)
	move.w	#0,(a0)
	btst	#8,(IO_Z80BUS).l
	bne.s	.0
	move.b	#0,(Z80_RAM+$50).l
	move.w	(sp)+,(a0)
	movea.l	(sp)+,a0
	rts
.0
	bsr.w	Z80BusRequest
	move.b	#0,(Z80_RAM+$50).l
	bsr.w	Z80BusRelease
	move.w	(sp)+,(a0)
	movea.l	(sp)+,a0
	rts

SndStopAll	;IDA: loc_B806. Command $F (SoundOff): free every song slot, send Z80 command $FF and clear the notes
	movem.l	d0/a0-a1,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	(a0),-(sp)
	move.w	#0,(a0)
	lea	(SndSeqPtr).l,a1
	move.w	#7,d0
.0
	move.l	#$FFFFFFFF,(a1)+
	dbf	d0,.0
	move.w	#$FF,d0
	bsr.w	SndPutZ80Cmd
	bsr.w	SndClearNotes
	move.w	(sp)+,(a0)
	movem.l	(sp)+,d0/a0-a1
	rts

SndClearNotes	;IDA: sub_B83E. No notes: SndNoteCount 0, SndNotes all -1
	movem.l	d0-d1/a0-a1,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	0(a0),-(sp)
	move.w	#0,0(a0)
	move.w	#0,$122(a0)
	lea	(SndNotes).l,a1
	move.w	#$1F,d1
	move.l	#$FFFFFFFF,d0
.0
	move.l	d0,(a1)+
	dbf	d1,.0
	move.w	(sp)+,0(a0)
	movem.l	(sp)+,d0-d1/a0-a1
	rts

SndReleaseNotes	;IDA: sub_B878. Set the timer of every note of slot d0 to 1 (released next frame)
	movem.l	d0-d2/a0-a1,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	0(a0),-(sp)
	move.w	#0,0(a0)
	lea	(SndNotes).l,a1
	move.w	$122(a0),d1
	clr.w	d2
.0
	cmpi.w	#0,d1
	beq.s	.2
	move.b	3(a1),d2
	lsr.b	#4,d2
	cmp.w	d0,d2
	bne.s	.1
	move.w	#1,(a1)
.1
	adda.l	#4,a1
	subi.w	#1,d1
	bra.s	.0
.2
	move.w	(sp)+,0(a0)
	movem.l	(sp)+,d0-d2/a0-a1
	rts

SndAddNote	;IDA: sub_B8C2. Add note d0 (timer word, then the note) to SndNotes
	movem.l	d0-d1/a0,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	SndNoteCount-SndDrvRAM(a0),d1
	lsl.w	#2,d1
	lea	(SndNotes).l,a0
	move.l	d0,(a0,d1.w)
	lea	(SndDrvRAM).l,a0
	addi.w	#1,SndNoteCount-SndDrvRAM(a0)
	movem.l	(sp)+,d0-d1/a0
	rts

SndUpdateNotes	;IDA: sub_B8EE. Count down the note timers; at 0 send the note off ($8x) and remove the note
	movem.l	d0-d1/a0-a2,-(sp)
	lea	(SndDrvRAM).l,a2
	cmpi.w	#0,SndNoteCount-SndDrvRAM(a2)
	beq.s	.3
	lea	(SndNotes).l,a0
.0
	cmpi.w	#$FFFF,(a0)
	beq.s	.3
	subi.w	#1,(a0)
	bne.s	.2
	move.b	3(a0),d0
	andi.b	#$F0,d0
	lsl.w	#8,d0
	swap	d0
	move.w	2(a0),d0
	andi.b	#$F,d0
	ori.b	#$80,d0
	bsr.w	SndPutZ80Cmd
	tst.w	d0
	beq.s	.1
	addi.w	#1,(a0)
	bra.s	.2
.1
	lea	(SndNotes).l,a1
	move.w	(SndNoteCount).l,d0
	subi.w	#1,d0
	lsl.w	#2,d0
	move.l	(a1,d0.w),(a0)
	move.l	#$FFFFFFFF,(a1,d0.w)
	subi.w	#1,$122(a2)
	bra.s	.0
.2
	adda.w	#4,a0
	bra.s	.0
.3
	movem.l	(sp)+,d0-d1/a0-a2
	rts

SndStreamZ80	;IDA: sub_B96A. Answer the Z80's sample request (Z80_RAM+$4D: 1 start sample Z80_RAM+$4E, 2 / 3 next 256 bytes) by copying
	;from the sample (bank item type 1) to the Z80 buffer, looping or ending it
	movem.l	d1-d2/a0,-(sp)
	bsr.w	Z80BusRequest
	tst.b	(Z80_RAM+$4D).l
	beq.w	.8
	cmpi.b	#1,(Z80_RAM+$4D).l
	bne.s	.2
	clr.w	d1
	move.b	(Z80_RAM+$4E).l,d1
	move.w	#1,d0
	bsr.w	SndFindBankItem
	bcs.w	.8
	cmpa.l	#$FFFFFFFF,a0
	beq.w	.8
	lea	(SndDrvRAM).l,a1
	move.l	a0,SndStreamBase-SndDrvRAM(a1)
.0
	move.b	(a0),d0
	cmp.b	(a0),d0
	bne.s	.0
	lsl.w	#8,d0
	adda.l	#1,a0
.1
	move.b	(a0),d0
	cmp.b	(a0),d0
	bne.s	.1
	move.w	d0,$12E(a1)
	adda.l	#1,a0
	movea.l	$126(a1),a0
	adda.l	#2,a0
	move.l	a0,$12A(a1)
	clr.l	d0
	move.b	(Z80_RAM+7).l,d0
	lsl.w	#8,d0
	move.b	(Z80_RAM+8).l,d0
	addi.l	#Z80_RAM,d0
	movea.l	d0,a1
	bra.w	.4
.2
	cmpi.b	#2,(Z80_RAM+$4D).l
	bne.s	.3
	movea.l	(SndStreamPtr).l,a0
	cmpa.l	#0,a0
	beq.w	.8
	clr.l	d0
	move.b	(Z80_RAM+7).l,d0
	lsl.w	#8,d0
	move.b	(Z80_RAM+8).l,d0
	addi.l	#Z80_RAM,d0
	movea.l	d0,a1
	bra.s	.4
.3
	cmpi.b	#3,(Z80_RAM+$4D).l
	bne.w	.8
	movea.l	(SndStreamPtr).l,a0
	cmpa.l	#0,a0
	beq.w	.8
	clr.l	d0
	move.b	(Z80_RAM+9).l,d0
	lsl.w	#8,d0
	move.b	(Z80_RAM+$A).l,d0
	addi.l	#Z80_RAM,d0
	movea.l	d0,a1
.4
	move.w	#$FF,d1
.5
	move.b	(a0)+,(a1)+
	dbeq	d1,.5
	beq.s	.6
	lea	(SndDrvRAM).l,a1
	addi.l	#$100,SndStreamPtr-SndDrvRAM(a1)
	bra.s	.8
.6
	suba.l	#1,a1
	clr.l	d0
	move.w	(SndStreamLoop).l,d0
	cmpi	#$FFFF,d0	;retail CMPI (0C40). No .w, so fixopcodes.js leaves it
	beq.s	.7
	move.b	#$FF,(a1)
	lea	(SndDrvRAM).l,a1
	movea.l	SndStreamBase-SndDrvRAM(a1),a0
	adda.l	#2,a0
	adda.l	d0,a0
	move.l	a0,$12A(a1)
	bra.s	.8
.7
	lea	(SndDrvRAM).l,a1
	move.l	#0,SndStreamPtr-SndDrvRAM(a1)
.8
	move.b	#0,(Z80_RAM+$4D).l
	bsr.w	Z80BusRelease
	movem.l	(sp)+,d1-d2/a0
	rts

SndFindBankItem	;IDA: sub_BACA. Find bank item type d0, id d1 in the 4 banks (SndBanks): a0 = its data, d0 = its size. Carry set and d0 = 3 when
	;there is none
	movem.l	d1-d4/a1-a2,-(sp)
	lea	(SndBanks).l,a1
	move.w	#3,d2
.0
	cmpi.l	#$FFFFFFFF,(a1)
	beq.w	.3
	movea.l	(a1),a0
	movea.l	a0,a2
	clr.l	d3
	move.b	(a0)+,d3
	lsl.w	#8,d3
	move.b	(a0)+,d3
	move.l	d3,d4
	lsl.w	#2,d4
	adda.l	d4,a2
	adda.l	#2,a2
.1
	cmp.b	(a0),d0
	bne.s	.2
	cmp.b	1(a0),d1
	bne.s	.2
	move.b	2(a0),d0
	lsl.w	#8,d0
	move.b	3(a0),d0
	movea.l	a2,a0
	andi	#$FE,ccr
	bra.s	.4
.2
	clr.l	d4
	move.b	2(a0),d4
	lsl.w	#8,d4
	move.b	3(a0),d4
	adda.l	d4,a2
	adda.l	#4,a0
	subi.w	#1,d3
	bne.s	.1
.3
	adda.l	#4,a1
	dbf	d2,.0
	move.w	#3,d0
	ori	#1,ccr
.4
	movem.l	(sp)+,d1-d4/a1-a2
	rts

SndSetBank	;IDA: loc_BB48. Command 6: bank d1 (0-3) is at a0; tell the Z80 too (Z80_RAM+$51). Carry set and d0 = 3 for d1 above 3
	movem.l	d1/a1-a2,-(sp)
	cmpi.w	#4,d1
	bcs.s	.0
	move.w	#3,d0
	ori	#1,ccr
	bra.s	.1
.0
	lsl.w	#2,d1
	lea	(SndBanks).l,a1
	move.l	a0,(a1,d1.w)
	lea	(SndDrvRAM).l,a1
	move.w	(a1),-(sp)
	move.w	#0,(a1)
	bsr.w	Z80BusRequest
	lea	(Z80_RAM+$51).l,a2
	move.l	a0,d0
	move.b	d0,(a2,d1.w)
	lsr.l	#8,d0
	move.b	d0,1(a2,d1.w)
	lsr.l	#8,d0
	move.b	d0,2(a2,d1.w)
	lsr.l	#8,d0
	move.b	d0,3(a2,d1.w)
	bsr.w	Z80BusRelease
	move.w	(sp)+,(a1)
	clr.w	d0
.1
	movem.l	(sp)+,d1/a1-a2
	rts

SndLoadList	;IDA: loc_BBA4. Command 7: upload the patches (types 0 and 4) of load list d1 (bank item type $B, pairs ended by $FF) to the Z80
	movem.l	d1/a0-a1,-(sp)
	move.w	#$B,d0
	bsr.w	SndFindBankItem
	bcs.w	.4
	movea.l	a0,a1
.0
	cmpi.b	#$FF,(a1)
	bne.s	.1
	clr.w	d0
	bra.s	.4
.1
	clr.w	d0
	move.b	(a1),d0
	clr.w	d1
	move.b	1(a1),d1
	bsr.w	SndFindBankItem
	bcs.s	.4
	cmpi.b	#0,(a1)
	beq.s	.2
	cmpi.b	#4,(a1)
	bne.s	.3
.2
	move.w	d0,d1
	clr.w	d0
	move.b	1(a1),d0
	bsr.w	SndUploadBlock
	bcs.s	.4
.3
	adda.l	#2,a1
	bra.s	.0
.4
	movem.l	(sp)+,d1/a0-a1
	rts

SndFreeBlocks	;IDA: loc_BBF8. Command 8: free the Z80 blocks of list a0 (word pairs ended by -1) and move the blocks after them down
	movem.l	d1-d3/a0-a2,-(sp)
	lea	(SndDrvRAM).l,a1
	move.w	(a1),-(sp)
	move.w	#0,(a1)
	bsr.w	Z80BusRequest
.0
	cmpi.w	#$FFFF,(a0)
	beq.w	.9
	lea	(Z80_RAM+$100).l,a1
	move.w	(a0),d0
	move.w	2(a0),d1
	move.w	#$29,d2
.1
	cmp.b	(a1),d0
	bne.s	.2
	cmp.b	1(a1),d1
	beq.s	.3
.2
	adda.l	#6,a1
	dbf	d2,.1
	bra.w	.8
.3
	move.b	2(a1),d0
	lsl.w	#8,d0
	move.b	3(a1),d0
	clr.w	d1
	move.b	4(a1),d1
	lsl.w	#8,d1
	move.b	5(a1),d1
	move.w	d1,d2
	add.w	d0,d2
	lea	(Z80_RAM).l,a2
.4
	cmpi.w	#$1F00,d2
	beq.s	.5
	move.b	(a2,d2.w),(a2,d1.w)
	addi.w	#1,d2
	addi.w	#1,d1
	bra.s	.4
.5
	clr.w	d1
	move.b	4(a1),d1
	lsl.w	#8,d1
	move.b	5(a1),d1
	move.b	#$FF,(a1)
	move.b	#$FF,1(a1)
	move.b	#$FF,2(a1)
	move.b	#$FF,3(a1)
	move.b	#$FF,4(a1)
	move.b	#$FF,5(a1)
	lea	(Z80_RAM+$100).l,a1
	move.w	#$29,d2
.6
	cmpi.b	#$FF,(a1)
	beq.s	.7
	clr.w	d3
	move.b	4(a1),d3
	lsl.w	#8,d3
	move.b	5(a1),d3
	cmp.w	d1,d3
	bcs.s	.7
	sub.w	d0,d3
	move.b	d3,5(a1)
	lsr.w	#8,d3
	move.b	d3,4(a1)
.7
	adda.l	#6,a1
	dbf	d2,.6
	lea	(Z80_RAM+5).l,a1
	clr.w	d1
	move.b	(a1),d1
	lsl.w	#8,d1
	move.b	1(a1),d1
	sub.w	d0,d1
	move.b	d1,1(a1)
	lsr.w	#8,d1
	move.b	d1,(a1)
.8
	adda.l	#4,a0
	bra.w	.0
.9
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a1
	move.w	(sp)+,(a1)
	clr.w	d0
	movem.l	(sp)+,d1-d3/a0-a2
	rts

SndResetBlocks	;IDA: loc_BD0E. Command 9: free all Z80 blocks (Z80_RAM+$100 all $FF, free pointer back to the start at Z80_RAM+3)
	movem.l	a0-a1,-(sp)
	lea	(SndDrvRAM).l,a0
	move.w	(a0),-(sp)
	move.w	#0,(a0)
	bsr.w	Z80BusRequest
	lea	(Z80_RAM+$100).l,a0
	move.w	#$FB,d0
.0
	move.b	#$FF,(a0)+
	dbf	d0,.0
	lea	(Z80_RAM+3).l,a0
	lea	(Z80_RAM+5).l,a1
	move.b	(a0)+,(a1)+
	move.b	(a0),(a1)
	bsr.w	Z80BusRelease
	lea	(SndDrvRAM).l,a0
	move.w	(sp)+,(a0)
	clr.w	d0
	movem.l	(sp)+,a0-a1
	rts

SndSendZ80	;IDA: loc_BD58. Command $A: queue Z80 command d1 with interrupts off
	move	sr,-(sp)
	move	#$2700,sr
	move.l	d1,d0
	bsr.w	SndPutZ80Cmd
	move	(sp)+,sr
	rts

Z80BusRequest	;IDA: sub_BD68. Stop the Z80 and wait for the bus
	move.w	#$100,(IO_Z80BUS).l
.0
	btst	#8,(IO_Z80BUS).l
	bne.s	.0
	rts

Z80BusRelease	;IDA: sub_BD7C. Give the bus back to the Z80
	move.w	#0,(IO_Z80BUS).l
	rts
	opt	oaq+,osq+,oz+

Z80Program	;$BD86. The Z80 sound program (main95 Begin and hockey95 Opening2 load it with SndLoadZ80, d1 = $1B63). Starts JP $0600
	incbin	..\Extracted\NHL95\Sound\z80_snd_drv95.bin
	nop	;$D8EA. Pad to $D8EC (retail 4E71)

SoundBanks	;$D8EC. IDA: no label (movea.l #$D8EC). Bank 0 (SndSetBank, Begin and Opening2): the item count, then 4 bytes per item
	;(type, id, size), then the items in that order. Type 0 = patch (uploaded to the Z80 by a load list), 1 = sample (streamed),
	;3 = song (SndStartSeq), $B = load list (SndLoadList). SndFindBankItem finds an item by type and id
	dc.w	141	;items
	dc.b	$0,$00
	dc.w	$5	;patch 0
	dc.b	$0,$01
	dc.w	$5	;patch 1
	dc.b	$0,$02
	dc.w	$5	;patch 2
	dc.b	$0,$03
	dc.w	$5	;patch 3
	dc.b	$0,$04
	dc.w	$5	;patch 4
	dc.b	$0,$05
	dc.w	$5	;patch 5
	dc.b	$0,$06
	dc.w	$5	;patch 6
	dc.b	$0,$07
	dc.w	$5	;patch 7
	dc.b	$0,$08
	dc.w	$5	;patch 8
	dc.b	$0,$09
	dc.w	$5	;patch 9
	dc.b	$0,$0A
	dc.w	$5	;patch 10
	dc.b	$0,$0B
	dc.w	$27	;patch 11
	dc.b	$0,$0C
	dc.w	$5	;patch 12
	dc.b	$0,$0D
	dc.w	$27	;patch 13
	dc.b	$0,$0E
	dc.w	$27	;patch 14
	dc.b	$0,$11
	dc.w	$27	;patch 17
	dc.b	$0,$13
	dc.w	$10	;patch 19
	dc.b	$0,$14
	dc.w	$10	;patch 20
	dc.b	$0,$15
	dc.w	$27	;patch 21
	dc.b	$0,$16
	dc.w	$27	;patch 22
	dc.b	$0,$18
	dc.w	$27	;patch 24
	dc.b	$0,$19
	dc.w	$27	;patch 25
	dc.b	$0,$1B
	dc.w	$27	;patch 27
	dc.b	$0,$1C
	dc.w	$27	;patch 28
	dc.b	$0,$1D
	dc.w	$27	;patch 29
	dc.b	$0,$33
	dc.w	$5	;patch 51
	dc.b	$0,$36
	dc.w	$5	;patch 54
	dc.b	$0,$38
	dc.w	$5	;patch 56
	dc.b	$0,$39
	dc.w	$5	;patch 57
	dc.b	$0,$3B
	dc.w	$5	;patch 59
	dc.b	$0,$3D
	dc.w	$5	;patch 61
	dc.b	$0,$3E
	dc.w	$27	;patch 62
	dc.b	$0,$3F
	dc.w	$27	;patch 63
	dc.b	$0,$40
	dc.w	$27	;patch 64
	dc.b	$0,$41
	dc.w	$5	;patch 65
	dc.b	$0,$42
	dc.w	$5	;patch 66
	dc.b	$0,$43
	dc.w	$5	;patch 67
	dc.b	$0,$44
	dc.w	$5	;patch 68
	dc.b	$0,$45
	dc.w	$27	;patch 69
	dc.b	$0,$46
	dc.w	$5	;patch 70
	dc.b	$0,$47
	dc.w	$27	;patch 71
	dc.b	$0,$48
	dc.w	$5	;patch 72
	dc.b	$0,$49
	dc.w	$27	;patch 73
	dc.b	$1,$00
	dc.w	$2143	;sample 0
	dc.b	$1,$01
	dc.w	$227	;sample 1
	dc.b	$1,$02
	dc.w	$20CB	;sample 2
	dc.b	$1,$03
	dc.w	$863	;sample 3
	dc.b	$1,$04
	dc.w	$A03	;sample 4
	dc.b	$1,$05
	dc.w	$F09	;sample 5
	dc.b	$1,$06
	dc.w	$F23	;sample 6
	dc.b	$1,$07
	dc.w	$EC3	;sample 7
	dc.b	$1,$08
	dc.w	$10D3	;sample 8
	dc.b	$1,$09
	dc.w	$32F	;sample 9
	dc.b	$1,$0A
	dc.w	$353	;sample 10
	dc.b	$1,$0B
	dc.w	$15C2	;sample 11
	dc.b	$1,$0C
	dc.w	$1045	;sample 12
	dc.b	$1,$0E
	dc.w	$9BC3	;sample 14
	dc.b	$1,$10
	dc.w	$EC29	;sample 16
	dc.b	$1,$11
	dc.w	$2528	;sample 17
	dc.b	$1,$13
	dc.w	$57CE	;sample 19
	dc.b	$1,$15
	dc.w	$1EC9	;sample 21
	dc.b	$1,$16
	dc.w	$D083	;sample 22
	dc.b	$1,$17
	dc.w	$47D0	;sample 23
	dc.b	$1,$18
	dc.w	$1503	;sample 24
	dc.b	$1,$19
	dc.w	$1B43	;sample 25
	dc.b	$1,$1B
	dc.w	$1822	;sample 27
	dc.b	$1,$1D
	dc.w	$232	;sample 29
	dc.b	$3,$00
	dc.w	$46FB	;song 0
	dc.b	$3,$01
	dc.w	$2B82	;song 1
	dc.b	$3,$02
	dc.w	$3587	;song 2
	dc.b	$3,$03
	dc.w	$3F33	;song 3
	dc.b	$3,$04
	dc.w	$C	;song 4
	dc.b	$3,$05
	dc.w	$C	;song 5
	dc.b	$3,$06
	dc.w	$C	;song 6
	dc.b	$3,$07
	dc.w	$C	;song 7
	dc.b	$3,$08
	dc.w	$C	;song 8
	dc.b	$3,$09
	dc.w	$C	;song 9
	dc.b	$3,$0A
	dc.w	$C	;song 10
	dc.b	$3,$0B
	dc.w	$C	;song 11
	dc.b	$3,$0E
	dc.w	$E	;song 14
	dc.b	$3,$10
	dc.w	$E	;song 16
	dc.b	$3,$11
	dc.w	$C	;song 17
	dc.b	$3,$13
	dc.w	$C	;song 19
	dc.b	$3,$15
	dc.w	$C	;song 21
	dc.b	$3,$16
	dc.w	$64	;song 22
	dc.b	$3,$17
	dc.w	$54	;song 23
	dc.b	$3,$18
	dc.w	$C	;song 24
	dc.b	$3,$19
	dc.w	$C	;song 25
	dc.b	$3,$1A
	dc.w	$C	;song 26
	dc.b	$3,$1B
	dc.w	$C	;song 27
	dc.b	$3,$1C
	dc.w	$C	;song 28
	dc.b	$3,$1D
	dc.w	$C	;song 29
	dc.b	$3,$1E
	dc.w	$E	;song 30
	dc.b	$3,$20
	dc.w	$C	;song 32
	dc.b	$3,$21
	dc.w	$C	;song 33
	dc.b	$3,$22
	dc.w	$C	;song 34
	dc.b	$3,$23
	dc.w	$C	;song 35
	dc.b	$3,$24
	dc.w	$C	;song 36
	dc.b	$3,$25
	dc.w	$C	;song 37
	dc.b	$3,$26
	dc.w	$31B	;song 38
	dc.b	$3,$27
	dc.w	$14	;song 39
	dc.b	$3,$28
	dc.w	$14	;song 40
	dc.b	$3,$29
	dc.w	$C	;song 41
	dc.b	$3,$32
	dc.w	$1F2	;song 50
	dc.b	$3,$33
	dc.w	$4E4	;song 51
	dc.b	$3,$34
	dc.w	$254	;song 52
	dc.b	$3,$35
	dc.w	$2AE	;song 53
	dc.b	$3,$36
	dc.w	$31C	;song 54
	dc.b	$3,$37
	dc.w	$2A8	;song 55
	dc.b	$3,$38
	dc.w	$29C	;song 56
	dc.b	$3,$39
	dc.w	$1AC	;song 57
	dc.b	$3,$3A
	dc.w	$3E4	;song 58
	dc.b	$3,$3B
	dc.w	$244	;song 59
	dc.b	$3,$3C
	dc.w	$30	;song 60
	dc.b	$3,$3D
	dc.w	$404	;song 61
	dc.b	$3,$3E
	dc.w	$341	;song 62
	dc.b	$3,$3F
	dc.w	$208	;song 63
	dc.b	$3,$40
	dc.w	$27E	;song 64
	dc.b	$3,$41
	dc.w	$358	;song 65
	dc.b	$3,$42
	dc.w	$12C	;song 66
	dc.b	$3,$43
	dc.w	$3C4	;song 67
	dc.b	$3,$44
	dc.w	$20C	;song 68
	dc.b	$3,$45
	dc.w	$274	;song 69
	dc.b	$3,$46
	dc.w	$158	;song 70
	dc.b	$3,$47
	dc.w	$3BC	;song 71
	dc.b	$3,$48
	dc.w	$424	;song 72
	dc.b	$3,$49
	dc.w	$400	;song 73
	dc.b	$3,$4A
	dc.w	$315	;song 74
	dc.b	$3,$4B
	dc.w	$365	;song 75
	dc.b	$3,$4C
	dc.w	$363	;song 76
	dc.b	$3,$4D
	dc.w	$2C9	;song 77
	dc.b	$3,$4E
	dc.w	$41C	;song 78
	dc.b	$3,$4F
	dc.w	$48C	;song 79
	dc.b	$3,$50
	dc.w	$255	;song 80
	dc.b	$3,$51
	dc.w	$22A	;song 81
	dc.b	$3,$52
	dc.w	$F0	;song 82
	dc.b	$3,$53
	dc.w	$274	;song 83
	dc.b	$3,$54
	dc.w	$D4	;song 84
	dc.b	$3,$55
	dc.w	$429	;song 85
	dc.b	$B,$00
	dc.w	$19	;list 0
	dc.b	$B,$01
	dc.w	$3F	;list 1
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_00.bin	;$DB22
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_01.bin	;$DB27
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_02.bin	;$DB2C
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_03.bin	;$DB31
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_04.bin	;$DB36
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_05.bin	;$DB3B
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_06.bin	;$DB40
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_07.bin	;$DB45
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_08.bin	;$DB4A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_09.bin	;$DB4F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_0A.bin	;$DB54
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_0B.bin	;$DB59
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_0C.bin	;$DB80
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_0D.bin	;$DB85
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_0E.bin	;$DBAC
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_11.bin	;$DBD3
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_13.bin	;$DBFA
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_14.bin	;$DC0A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_15.bin	;$DC1A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_16.bin	;$DC41
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_18.bin	;$DC68
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_19.bin	;$DC8F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_1B.bin	;$DCB6
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_1C.bin	;$DCDD
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_1D.bin	;$DD04
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_33.bin	;$DD2B
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_36.bin	;$DD30
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_38.bin	;$DD35
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_39.bin	;$DD3A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_3B.bin	;$DD3F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_3D.bin	;$DD44
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_3E.bin	;$DD49
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_3F.bin	;$DD70
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_40.bin	;$DD97
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_41.bin	;$DDBE
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_42.bin	;$DDC3
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_43.bin	;$DDC8
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_44.bin	;$DDCD
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_45.bin	;$DDD2
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_46.bin	;$DDF9
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_47.bin	;$DDFE
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_48.bin	;$DE25
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_patch_49.bin	;$DE2A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_00.bin	;$DE51
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_01.bin	;$FF94
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_02.bin	;$101BB
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_03.bin	;$12286
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_04.bin	;$12AE9
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_05.bin	;$134EC
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_06.bin	;$143F5
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_07.bin	;$15318
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_08.bin	;$161DB
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_09.bin	;$172AE
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_0A.bin	;$175DD
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_0B.bin	;$17930
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_0C.bin	;$18EF2
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_0E.bin	;$19F37
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_10.bin	;$23AFA
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_11.bin	;$32723
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_13.bin	;$34C4B
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_15.bin	;$3A419
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_16.bin	;$3C2E2
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_17.bin	;$49365
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_18.bin	;$4DB35
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_19.bin	;$4F038
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_1B.bin	;$50B7B
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_sample_1D.bin	;$5239D
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_00.bin	;$525CF
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_01.bin	;$56CCA
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_02.bin	;$5984C
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_03.bin	;$5CDD3
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_04.bin	;$60D06
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_05.bin	;$60D12
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_06.bin	;$60D1E
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_07.bin	;$60D2A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_08.bin	;$60D36
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_09.bin	;$60D42
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_0A.bin	;$60D4E
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_0B.bin	;$60D5A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_0E.bin	;$60D66
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_10.bin	;$60D74
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_11.bin	;$60D82
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_13.bin	;$60D8E
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_15.bin	;$60D9A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_16.bin	;$60DA6
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_17.bin	;$60E0A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_18.bin	;$60E5E
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_19.bin	;$60E6A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_1A.bin	;$60E76
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_1B.bin	;$60E82
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_1C.bin	;$60E8E
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_1D.bin	;$60E9A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_1E.bin	;$60EA6
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_20.bin	;$60EB4
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_21.bin	;$60EC0
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_22.bin	;$60ECC
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_23.bin	;$60ED8
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_24.bin	;$60EE4
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_25.bin	;$60EF0
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_26.bin	;$60EFC
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_27.bin	;$61217
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_28.bin	;$6122B
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_29.bin	;$6123F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_32.bin	;$6124B
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_33.bin	;$6143D
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_34.bin	;$61921
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_35.bin	;$61B75
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_36.bin	;$61E23
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_37.bin	;$6213F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_38.bin	;$623E7
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_39.bin	;$62683
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_3A.bin	;$6282F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_3B.bin	;$62C13
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_3C.bin	;$62E57
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_3D.bin	;$62E87
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_3E.bin	;$6328B
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_3F.bin	;$635CC
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_40.bin	;$637D4
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_41.bin	;$63A52
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_42.bin	;$63DAA
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_43.bin	;$63ED6
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_44.bin	;$6429A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_45.bin	;$644A6
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_46.bin	;$6471A
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_47.bin	;$64872
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_48.bin	;$64C2E
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_49.bin	;$65052
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_4A.bin	;$65452
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_4B.bin	;$65767
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_4C.bin	;$65ACC
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_4D.bin	;$65E2F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_4E.bin	;$660F8
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_4F.bin	;$66514
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_50.bin	;$669A0
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_51.bin	;$66BF5
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_52.bin	;$66E1F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_53.bin	;$66F0F
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_54.bin	;$67183
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_song_55.bin	;$67257
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_list_00.bin	;$67680
	incbin	..\Extracted\NHL95\Sound\Bank\snd95_list_01.bin	;$67699
