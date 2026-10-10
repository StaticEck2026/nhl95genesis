;	NHL 95 checksum95. Retail $1A72C0-$1A730F (80 bytes).
;	Mapped to checksum94 (100%): ValidationRoutine, the last code in the ROM. The $FF fill $1A7310-$1FFFFF follows (nhl95.asm dcb.b after
;	this include). The same code as 94 with the 95 long count and sum.

ValidationRoutine	;IDA: sub_1A72C0. checksum94 ValidationRoutine (92 / 93 Calc_Checksum). Called once at power on from main95 ($690). Adds every ROM
	;long from 0 up to this routine, skipping the header long at $18C. Returns if the sum is right, else turns the screen red and hangs.
	;Uses d0-d1/a0/a4
	moveq	#0,d0			;sum
	suba.l	a0,a0			;a0 = ROM address 0
	move.l	#ValidationRoutine/4,d1	;number of longs below this routine ($69CB0)
.loop	cmpa.w	#$18C,a0		;92 ValidationLoop. header long $18C-$18F holds the checksum word $18E
	bne.s	.add
	addq.w	#4,a0			;skip it, not summed
	bra.s	.next
.add	add.l	(a0)+,d0		;92 SkipIncrement
.next	subq.l	#1,d1			;92 ContinueValidation
	bgt.s	.loop
	cmpi.l	#$366A73F5,d0		;95 retail sum (94 $8AB9F121). Real CMPI (0C80), not EA cmp
	bne.s	.bad			;wrong sum: red screen
	rts
.bad	movea.l	#VDP_CTRL,a4		;92 VDPErrorSetup
	move.w	#$8F02,(a4)		;auto increment 2
	move.w	#$8004,(a4)		;mode 1: h interrupt off
	move.w	#$8700,(a4)		;backdrop = colour 0
	move.w	#$8144,(a4)		;mode 2: display on, v interrupt off, dma off
	move.w	#$C000,(a4)		;cram write, colour 0 (first command word only)
	move.w	#$3F,d1			;64 colours
.fill	move.w	#$E,(VDP_DATA).l	;92 VRAMWriteLoop. colour = $00E, full red
	dbf	d1,.fill
.halt	bra.s	.halt			;92 Halt. hang
