;	NHL 95 checks95_08. Retail $082FC2-$082FF9 (56 bytes).
;	94 checks94 assshoot, split from the onetimer95 placeholder (the tail of its range). checks95_03 (94 assgoaliectrl) follows at $082FFA.
;	IDA left it as dc.b; it is code here, read from the retail bytes. 95: rtsskate (checks95_02) in place of rtss2, jmp .l to SetShotMode
;	and ShotMode (input95_01).

; assignment for computer shooting
assshoot	;no IDA label (IDA dc.b), asstab entry $1A. checks94 assshoot
	btst	#pfalock,pflags(a3)	;pfalock - animation locked
	bne.w	rtsskate	;94 rtss2
	bclr	#pfna,pflags(a3)	;clear pfna
	beq.w	.nna
	jmp	(SetShotMode).l	;95 jmp (94 bra)
.nna
	btst	#sfssdir,(sflags).w	;#sfssdir
	beq.w	assexit
	clr.w	d2
	sub.w	d7,temp2(a3)
	bpl.w	.sm	;95: the bra.w ShotMode is now a shared jmp
	bset	#5,d2	;#cbut
.sm
	jmp	(ShotMode).l
