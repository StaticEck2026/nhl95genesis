;	NHL 95 main segment. Retail $000000-$000771 (1906 bytes), from the IDA listing lst/nhl95.bin.lst.
;	Vectors, cartridge header and SegaInit as in main94.asm. 95 then adds a region lock (CHECK_VDP to RegionHang), keeps the
;	checksum call, and holds Begin itself (94 Begin is in hockey94). TeamList (teamdata95) starts at $772.
	include	macros\genesis.mac

;	68000
;	ABSOLUTE
;	A4OFF
;	llchar	'.'	; Change the local label character to '.'.
;	mlchar	'@'	; Change the macro label character to '@'.

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Equates
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

InitialSP = $FFFFF6	;reset vector 0. 93 / 94 name, 24-bit form of $FFFFFFF6. Begin moves the stack to Stack (ram_addrs.inc)

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Vectors
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

	dc.l	InitialSP	; 0 initial stack pointer (IDA: Trap3)
	dc.l	Start		; 1 initial program counter (IDA: Reset, $200)
	dc.l	BusErr		; 2 bus error. 95 has its own (an rts); 94 pointed bus and address error at AddError
	dc.l	AdrErr		; 3 address error (an rts)
	dc.l	InvOpCode	; 4 illegal instruction (an rts)
	dc.l	DivBy0		; 5 zero divide (an rts)
	dcb.b	72,$FF		; 6-23 ($18-$5F): CHK ... reserved, not used. $FF as in 94

	dc.l	IRQ7		; 24 ($60) spurious interrupt. IRQ7 is an rte
	dc.l	IRQ7		; 25 ($64) level 1, not used
	dc.l	IRQ7		; 26 ($68) level 2 (external), not used
	dc.l	IRQ7		; 27 ($6C) level 3, not used
	dc.l	IRQ7		; 28 ($70) level 4: horizontal retrace (not used)
	dc.l	0		; 29 ($74) level 5: not used
	dc.l	VBjsr		; 30 ($78) level 6: vertical retrace, jumps through vbint (IDA: VBLANK)
	dc.l	IRQ7		; 31 ($7C) level 7

	dc.l	0,0,0,0		; 32-35 ($80-$8F): trap #0-#3, not used. 0 in retail
	dcb.b	112,$FF		; 36-63 ($90-$FF): trap #4-#15 and reserved, not used

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Cartridge header ($100-$1FF). 94 includes it as sega\SegaIDTable94.asm
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;					Data	  	No.		Address	Description
	dc.b	'SEGA GENESIS    '	; 01	$100	Sega Genesis ID (16 bytes)
	dc.b	'(C)T-50 1994.JUL'	; 02	$110	company ID / release date (YYYY.MMM) (16 bytes). 94: 1993.JUL
	dc.b	'NHL ''95                                         '	; 03	$120	game title for US market (48 bytes)
	dc.b	'NHL ''95                                         '	; 04	$150	game title for Japanese market (48 bytes)
	dc.b	'GM T-50856 -00'	; 05	$180	cartridge cat., product no., version no. (14 bytes). 94: T-50656
	IF CHECKSUM=1 ; Security check enabled
		IF REV=0 ; RETAIL
			dc.w	$3C61		; 06	$18E	check sum data (installed by checsum program) (2 bytes)
		ELSE ; REV A
			dc.w	$0000		; 06	$18E	check sum data (installed by checsum program) (2 bytes)
		ENDIF
	ELSE ; Security check disabled
		dc.w	$0000			; 06	$18E	check sum data (installed by checsum program) (2 bytes)
	ENDIF
	dc.b	'J               '	; 07	$190	I/O peripheral info. (J=Control Pad) (16 bytes)
	dc.l	$00000000,$001FFFFF	; 08	$1A0	cartridge size (start and end address) (8 bytes). 2 MB (94: $FFFFF)
	dc.l	$00FF0000,$00FFFFFF	; 09	$1A8	RAM size (start and end address) (8 bytes)
	dc.b	'RA',$F8,$20		; 10	$1B0	external RAM info. (12 bytes): backup RAM, odd bytes
	dc.l	$00200001,$0020FFFF	; 		$1B4	backup RAM start and end address (94: $203FFF)
	dc.b	'            '		; 11	$1BC	modem info. (12 bytes)
	dc.b	'                                        '	; 12	$1C8	inhibit to use (40 bytes)
CountryCode	;$1F0. IDA name. The region lock (CHECK_VDP) reads these letters
	dc.b	'EUJ             '	; 13	$1F0	contry code for release (16 bytes). E = Europe, U = USA, J = Japan (94: UE)

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Start ($200). 94 includes SegaInit as sega\SegaInit.asm
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
;****************************************************************
;																*
;	GENESIS / MEGA DRIVE HARD INITIAL PROGRAM					*
;																*
;		1989 11/30												*
;																*
;	HOT_START is GAME_PROGRAM start_address						*
;		 = START + $100											*
;		because this program size is 256 bytes.					*
;																*
;       June 21'90                                              *
;****************************************************************
; No programs are permited to run before this program.

Start	;IDA: Reset ($200). Power on: the Sega hardware init, then the region lock, the checksum and Begin
SegaInit
	tst.l	$a10008		; POWER ON check cntroller A,B
	bne.s	h_s
	tst.w	$a1000c		; POWER ON check cntroller C
h_s
	bne.s	hot_start
cold_start
	lea.l	reg_set(pc),a5	; initial data address set
	movem.w	(a5)+,d5-d7		; regster initialize d5-d7.word
	movem.l	(a5)+,a0-a4		; regster initialize a0-a4.long
security
	move.b	-$10ff(a1),d0	; ** a1 = $a11100 **
	andi.b	#$000f,d0		;  -$10ff(a1) = $a10000
	beq.s	japan		; Ver. No. check
	move.l	#'SEGA',$2f00(a1)	; "SEGA" moved to SECURITY part
japan				; 2f00(a1) = $a14000
reg_init
	move	(a4),d0		; vdp status dummy read
	moveq	#0,d0
	move.l	d0,a6
	move.l	a6,usp		; user stack pointer set (94 writes it as dc.w $4E66)
	moveq	#23,d1		; d1 = counter

;------<<< VDP REG. initialize >>>------
;    d5 = $8000 / d7 = $100
r_int1
	move.b	(a5)+,d5		; vdp reg. 0-23 set
	move.w	d5,(a4)		;    (DMA fill set)
	add	d7,d5
	dbra	d1,r_int1

;------<<< DMA FILL >>>---------
dma_fill				; already sat reg. #18,19,23
	move.l	(a5)+,(a4)
	move	d0,(a3)		; set fill data ($0) to $c00000

;-------<<< Z80 initialize >>>----
;	a0 = $a00000 / a1 = $a11100 / a2 = $a11200
; 	d0 = $0      / d7 = $100
z80_clr
	move	d7,(a1)		; z80_busreq on
	move	d7,(a2)		; z80_reset off
z801
	btst	d0,(a1)		; z80_bgack ok ?
	bne.s	z801
	moveq	#37,d2		; counter set
z802
	move.b	(a5)+,(a0)+		; z80 program set to z80 sram
	dbra	d2,z802
	move	d0,(a2)		; z80_reset on
	move	d0,(a1)		; z80_busreq off
	move	d7,(a2)		; z80_reset off ( z80 start )

;--------<<< work ram clear >>>------------
; a6 = $0 / d0 = $0 / d6 = $3fff
clr_wk
c_wk1
	move.l	d0,-(a6)
	dbra	d6,c_wk1

;-------<<< VDP color clear >>>-------------
; a3 = $c00000 / a4 = $c00004 / d0 = $0
clr_col
	move.l	(a5)+,(a4)		; vdp reg #1 = 4, #15 = 2
	move.l	(a5)+,(a4)
	moveq	#$1f,d3		; d3 = color ram size-1
c_col1
	move.l	d0,(a3)
	dbra	d3,c_col1

; -------<<< V SCROLL clear >>>---------------
; a3 = $c00000 / a4 = $c00004 / d0 = $0
clr_vsc
	move.l	(a5)+,(a4)
	moveq	#19,d4		; d4 = vscroll ram size-1
c_vsc1
	move.l	d0,(a3)
	dbra	d4,c_vsc1

;---------<<< PSG clear >>>-------------------
; a3 = $c00000 / a4 = $c00004 / d0 = $0
; a5 = psg_dat (clear data) point
clr_psg
	moveq	#3,d5		; counter set
c_psg1
	move.b	(a5)+,$11(a3)
	dbra	d5,c_psg1

;-----------<<< regstars initial >>>------------
	move	d0,(a2)		; z80 reset
	movem.l	(a6),d0-d7/a0-a6	; initialize all registers
	move	#$2700,sr
hot_start
	bra.s	CHECK_VDP


;*************************************************
;	tables

reg_set					; registers set data table
	dc.w	$008000,$003fff,$000100		; d5 / d6 / d7
	dc.l	$a00000,$a11100,$a11200,$c00000	; a0 - a3
	dc.l	$c00004			; a4
vreg_dt
	dc.b	$04,$14,$30,$3c,$07,$6c,$00,$00
	dc.b	$00,$00,$ff,$00,$81,$37,$00,$01
	dc.b	$01,$00,$00,$ff,$ff,$00,$00,$80
dma_fill_mode
	dc.l	$40000080		; vdp_reg set data.dma_fill_mod
z80_reg
	dc.b	$af		; xor	a
	dc.b	$01,$d9,$1f		; ld	bc,1fd9h
	dc.b	$11,$27,$00		; ld	de,0027h
	dc.b	$21,$26,$00		; ld	hl,0026h
	dc.b	$f9		; ld	sp,hl
	dc.b	$77		; ld	(hl),a
	dc.b	$ed,$b0		; ldir
	dc.b	$dd,$e1		; pop	ix
	dc.b	$fd,$e1		; pop	iy
	dc.b	$ed,$47		; ld	i,a
	dc.b	$ed,$4f		; ld	r,a
	dc.b	$d1		; pop	de
	dc.b	$e1		; pop	hl
	dc.b	$f1		; pop	af
	dc.b	$08		; ex	af,af'
	dc.b	$d9		; exx
	dc.b	$c1		; pop	bc
	dc.b	$d1		; pop	de
	dc.b	$e1		; pop	hl
	dc.b	$f1		; pop	af
	dc.b	$f9		; ld	sp,hl
	dc.b	$f3		; di
	dc.b	$ed,$56		; im1
	dc.b	$36,$e9		; ld	(hl),e9h
	dc.b	$e9		; jp (hl)
new_reg_data
	dc.l	$81048f02		; vdp reg#1=04,#15=02
clr_col_data
	dc.l	$c0000000		; color_ram address data
clr_vsc_data
	dc.l	$40000010		; v_scroll ram address data
psg_dat
	dc.b	$9f,$bf,$df,$ff

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Region lock. New in 95 (94 CHECK_VDP is only the tst, then the checksum and Begin)
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

CHECK_VDP	;IDA: loc_2FA. Hot start lands here. Match the console region to the CountryCode letters; on a mismatch draw the
	;"DEVELOPED FOR USE ONLY WITH ... SYSTEMS." screen and hang
	tst.w	(VDP_CTRL).l		; this is protect to push. start_bottum rapid_firely (94 comment)
	clr.l	d0
	move.b	(IO_PCBVER+1).l,d0	;version register: bit 7 = overseas, bit 6 = PAL
	lsr.b	#6,d0
	andi.b	#3,d0			;0 Japan NTSC, 1 Japan PAL, 2 overseas NTSC, 3 overseas PAL
	lea	RegionLetters(pc),a0
	move.b	(a0,d0.w),d0		;region letter J / U / E, 0 for Japan PAL
	tst.b	d0
	beq.w	RegionHang		;Japan PAL: hang with a blank screen
	lea	(CountryCode).l,a0
	move.w	#$F,d1			;16 country code letters
.find
	cmp.b	(a0),d0
	beq.w	RegionOK		;the cartridge lists this region: start the game
	addq.l	#1,a0
	dbf	d1,.find
	;wrong region: set the VDP up and load RegionFont as tiles 0-$3A
	lea	(VDP_DATA).l,a4
	lea	(VDP_CTRL).l,a5
	move.w	#$8164,(a5)		;reg 1: display on, vblank int, DMA off
	move.w	#$8230,(a5)		;reg 2: plane A at $C000
	move.w	#$8C81,(a5)		;reg 12: 40 cell mode
	move.w	#$8F02,(a5)		;reg 15: auto increment 2
	move.w	#$9001,(a5)		;reg 16: 64 x 32 cell planes
	move.l	#$C0020000,(a5)		;cram write, address 2 (colour 1)
	move.w	#$EEE,(a4)		;colour 1 = white
	move.l	#$40000000,(a5)		;vram write, address 0
	lea	RegionFont(pc),a0
	move.w	#$3A,d0			;59 characters, space to Z
	move.l	#$10000000,d2		;pixel mask: colour 1 in the nibble rol.l moves into place
.char
	move.w	#7,d6			;8 rows
.row
	move.b	(a0)+,d1		;1 bit per pixel, left pixel in bit 7
	move.l	#0,d4
	move.w	#7,d5			;8 pixels
.pixel
	rol.l	#4,d2
	ror.b	#1,d1
	bcc.s	.clear
	or.l	d2,d4			;set the pixel to colour 1
.clear
	dbf	d5,.pixel
	move.l	d4,(a4)			;one 4 bpp tile row
	dbf	d6,.row
	dbf	d0,.char
	move.b	#8,d1			;row 8
	lea	DevelopedTxt(pc),a0
	move.b	(a0)+,d0		;column
	bsr.w	RegionPrint
	lea	(CountryCode).l,a1
.letter	;one line for each country code letter, up to the first space
	cmpi.b	#$20,(a1)
	beq.s	.done
	lea	RegionSystems(pc),a2
.look
	move.w	(a2)+,d4		;letter, 0 = end of RegionSystems
	tst.b	d4
	beq.s	.next
	cmp.b	(a1),d4
	bne.s	.skip
	cmpi.b	#$20,1(a1)
	bne.s	.name			;not the last letter
	cmpa.l	#CountryCode,a1
	beq.s	.name			;the only letter
	lea	AndTxt(pc),a0		;"&" before the last system
	move.b	(a0)+,d0
	addq.w	#1,d1
	bsr.w	RegionPrint
.name
	lea	RegionLetters(pc),a0
	adda.l	(a2)+,a0		;system name text
	move.b	(a0)+,d0
	addq.w	#1,d1
	bsr.w	RegionPrint
	bra.s	.next
.skip
	addq.l	#4,a2
	bra.s	.look
.next
	addq.l	#1,a1
	bra.s	.letter
.done
	lea	SystemsTxt(pc),a0
	move.b	(a0)+,d0
	addq.w	#1,d1
	bsr.w	RegionPrint
RegionHang	;IDA: loc_3FE. Wrong region (or Japan PAL): hang
	bra.s	RegionHang

RegionPrint	;IDA: sub_400. Print the 0 terminated text at a0 on plane A ($C000), row d1, column d0. Tile = character - $20
	move.b	d1,d2
	andi.l	#$FF,d2
	swap	d2
	lsl.l	#7,d2			;row * $80, in the address half of the vram command
	move.b	d0,d3
	andi.l	#$FF,d3
	swap	d3
	asl.l	#1,d3			;column * 2
	add.l	d3,d2
	addi.l	#$40000003,d2		;vram write at $C000 + row * $80 + column * 2
	move.l	d2,(a5)
.0
	tst.b	(a0)
	beq.s	.1
	move.b	(a0)+,d2
	subi.b	#$20,d2
	andi.w	#$FF,d2
	move.w	d2,(a4)
	bra.s	.0
.1
	rts

RegionLetters	;IDA: unk_436. Letter for each version register region (0 Japan NTSC ... 3 overseas PAL). 0 = hang
	dc.b	'J',0,'U','E'
RegionSystems	;IDA: unk_43A. Country code letter (word), then its system name as an offset from RegionLetters (long). 0 ends
	dc.w	'J'
	dc.l	NtscMegaDriveTxt-RegionLetters
	dc.w	'U'
	dc.l	NtscGenesisTxt-RegionLetters
	dc.w	'E'
	dc.l	PalMegaDriveTxt-RegionLetters
	dc.w	0
;region lock text: column, then the characters, 0 terminated
DevelopedTxt	;IDA: unk_44E
	dc.b	6,'DEVELOPED FOR USE ONLY WITH',0
AndTxt	;IDA: unk_46B
	dc.b	$12,'&',0
SystemsTxt	;IDA: unk_46E
	dc.b	$F,'SYSTEMS.',0
NtscMegaDriveTxt	;J
	dc.b	$C,'NTSC MEGA DRIVE',0
NtscGenesisTxt	;U
	dc.b	$D,'NTSC GENESIS',0
PalMegaDriveTxt	;E
	dc.b	4,'PAL AND FRENCH SECAM MEGA DRIVE',0
RegionFont	;IDA: unk_4B8. 8 x 8, 1 bit per pixel, characters $20-$5A
	dc.b	$00,$00,$00,$00,$00,$00,$00,$00	;' '
	dc.b	$18,$18,$18,$18,$00,$18,$18,$00	;'!'
	dc.b	$36,$36,$48,$00,$00,$00,$00,$00	;'"'
	dc.b	$12,$12,$7F,$12,$7F,$24,$24,$00	;'#'
	dc.b	$08,$3F,$48,$3E,$09,$7E,$08,$00	;'$'
	dc.b	$71,$52,$74,$08,$17,$25,$47,$00	;'%'
	dc.b	$18,$24,$18,$29,$45,$46,$39,$00	;'&'
	dc.b	$30,$30,$40,$00,$00,$00,$00,$00	;'''
	dc.b	$0C,$10,$20,$20,$20,$10,$0C,$00	;'('
	dc.b	$30,$08,$04,$04,$04,$08,$30,$00	;')'
	dc.b	$00,$08,$2A,$1C,$2A,$08,$00,$00	;'*'
	dc.b	$08,$08,$08,$7F,$08,$08,$08,$00	;'+'
	dc.b	$00,$00,$00,$00,$00,$30,$30,$40	;','
	dc.b	$00,$00,$00,$7F,$00,$00,$00,$00	;'-'
	dc.b	$00,$00,$00,$00,$00,$30,$30,$00	;'.'
	dc.b	$01,$02,$04,$08,$10,$20,$40,$00	;'/'
	dc.b	$1E,$33,$33,$33,$33,$33,$1E,$00	;'0'
	dc.b	$18,$38,$18,$18,$18,$18,$3C,$00	;'1'
	dc.b	$3E,$63,$63,$0E,$38,$60,$7F,$00	;'2'
	dc.b	$3E,$63,$03,$1E,$03,$63,$3E,$00	;'3'
	dc.b	$06,$0E,$1E,$36,$66,$7F,$06,$00	;'4'
	dc.b	$7E,$60,$7E,$63,$03,$63,$3E,$00	;'5'
	dc.b	$3E,$63,$60,$7E,$63,$63,$3E,$00	;'6'
	dc.b	$3F,$63,$06,$06,$0C,$0C,$18,$00	;'7'
	dc.b	$3E,$63,$63,$3E,$63,$63,$3E,$00	;'8'
	dc.b	$3E,$63,$63,$3F,$03,$63,$3E,$00	;'9'
	dc.b	$00,$18,$18,$00,$00,$18,$18,$00	;':'
	dc.b	$00,$18,$18,$00,$00,$18,$18,$20	;';'
	dc.b	$03,$0C,$30,$40,$30,$0C,$03,$00	;'<'
	dc.b	$00,$00,$7F,$00,$7F,$00,$00,$00	;'='
	dc.b	$60,$18,$06,$01,$06,$18,$60,$00	;'>'
	dc.b	$3E,$63,$03,$1E,$18,$00,$18,$00	;'?'
	dc.b	$3C,$42,$39,$49,$49,$49,$36,$00	;'@'
	dc.b	$1C,$1C,$36,$36,$7F,$63,$63,$00	;'A'
	dc.b	$7E,$63,$63,$7E,$63,$63,$7E,$00	;'B'
	dc.b	$3E,$73,$60,$60,$60,$73,$3E,$00	;'C'
	dc.b	$7E,$63,$63,$63,$63,$63,$7E,$00	;'D'
	dc.b	$3F,$30,$30,$3E,$30,$30,$3F,$00	;'E'
	dc.b	$3F,$30,$30,$3E,$30,$30,$30,$00	;'F'
	dc.b	$3E,$73,$60,$67,$63,$73,$3E,$00	;'G'
	dc.b	$66,$66,$66,$7E,$66,$66,$66,$00	;'H'
	dc.b	$18,$18,$18,$18,$18,$18,$18,$00	;'I'
	dc.b	$0C,$0C,$0C,$0C,$CC,$CC,$78,$00	;'J'
	dc.b	$63,$66,$6C,$78,$6C,$66,$63,$00	;'K'
	dc.b	$60,$60,$60,$60,$60,$60,$7F,$00	;'L'
	dc.b	$63,$77,$7F,$6B,$6B,$63,$63,$00	;'M'
	dc.b	$63,$73,$7B,$7F,$6F,$67,$63,$00	;'N'
	dc.b	$3E,$63,$63,$63,$63,$63,$3E,$00	;'O'
	dc.b	$7E,$63,$63,$7E,$60,$60,$60,$00	;'P'
	dc.b	$3E,$63,$63,$63,$6F,$63,$3F,$00	;'Q'
	dc.b	$7E,$63,$63,$7E,$68,$66,$67,$00	;'R'
	dc.b	$3E,$63,$70,$3E,$07,$63,$3E,$00	;'S'
	dc.b	$7E,$18,$18,$18,$18,$18,$18,$00	;'T'
	dc.b	$66,$66,$66,$66,$66,$66,$3C,$00	;'U'
	dc.b	$63,$63,$63,$36,$36,$1C,$1C,$00	;'V'
	dc.b	$6B,$6B,$6B,$6B,$6B,$7F,$36,$00	;'W'
	dc.b	$63,$63,$36,$1C,$36,$63,$63,$00	;'X'
	dc.b	$66,$66,$66,$3C,$18,$18,$18,$00	;'Y'
	dc.b	$7F,$07,$0E,$1C,$38,$70,$7F,$00	;'Z'

RegionOK	;IDA: loc_690. The region is listed: checksum, then the game
	IF CHECKSUM=1
		jsr	(ValidationRoutine).l	;IDA: sub_1A72C0 (checksum95). jsr (x).l, 4EB9. Red screen and hang if the ROM sum is wrong
	ELSE
		nop
		nop
		nop
	ENDIF
	bra.w	Begin

	dc.l	0	;$69A. Not code. 94 has the same long at the start of teamdata94, before TeamList

;exception vectors 2-5. 95 returns; 94 printed the error (AddError, Illinst, ZeroDiv in data94) and hung
BusErr	;IDA name. Vector 2
	rts
AdrErr	;IDA name. Vector 3
	rts
InvOpCode	;IDA name. Vector 4
	rts
DivBy0	;IDA name. Vector 5
	rts

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	Begin. 94 has it in hockey94
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

Begin	;IDA: loc_6A6. cold start, entered from RegionOK. Clear RAM, init sound and menus, go to title
	move	#$2700,sr		;interrupts off
	movea.w	#(Stack-M68K_RAM),sp	;stack pointer to RAM $FDFA (94: $FFFE)
	movea.w	#(VSCRLPM-M68K_RAM),a0	;clear out ram
.0	clr.l	(a0)+			;clear RAM $AC00-$DC7F (94: $B000-$DEF3)
	cmpa.w	#$DC80,a0
	blt.s	.0
	clr.w	(PALflag).l		;clear the PAL flag (IDA: DMA flag)
	move.w	(VDP_CTRL).l,d0
	andi.w	#1<<PAL_MODE,d0		;VDP status bit 0 = PAL (50 Hz)
	move.w	d0,(music_global_tick_counter).l
	beq.w	.ntsc
	bset	#0,(PALflag).l	;PAL
.ntsc	move.w	#$FFFF,(PlayingSong).l	;no song playing
	;sound stuff. 94 calls p_initialZ80, p_turnoff, p_music_vblank; 95 sends commands to its own driver
	move.w	#0,d0			;command 0: load the Z80 program
	move.w	#$1B63,d1		;length
	movea.l	#Z80Program,a0
	jsr	(SoundCmd).l
	move.w	#9,d0			;command 9
	jsr	(SoundCmd).l
	move.w	#6,d0			;command 6: the sound data
	clr.w	d1
	movea.l	#SoundBanks,a0
	jsr	(SoundCmd).l
	move.w	#7,d0			;command 7
	move.w	#0,d1
	jsr	(SoundCmd).l
	jsr	(SoundOff).l		;command $F
	jsr	(KillCrowd).l
	jsr	(Detect4WayPlay).l
	;94 sets PadControlBits34 to -1 here
	jsr	(EASportsScreen).l
	jsr	(InitSaveRAM).l
	jsr	(HiScoreScreen).l	;94 calls ReadLineData first
	jsr	(ReadLineData).l
	jsr	(DefaultMenus).l
	move.w	(OptLine).l,(TmpOptLine2).l
	move.w	(OptPlayMode).l,(TempOptPlayMode).l
	jsr	(orjoy).l		;clear any previous button presses
	jmp	(Opening).l		;goto title screen and options etc. Last instruction of main95 ($76C-$771). TeamList is $772
