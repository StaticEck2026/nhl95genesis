; $07E0E0  Adapted from sound94.asm: the 94 Z80 program
;	NHL 95 segment $7E0E0-$7E36B, from lst/nhl95.bin.lst (IDA dc.b, no label). The 94 Z80 program (93 / 94 Z80_Program_Code), still
;	loaded by p_initialZ80 (sound95_01, no caller in 95). The same bytes as 94 except the bank window address of the FM patches, which 95
;	keeps at the end of sound95_01. The tail of the old placeholder ($7E36C-$7E4D5, 94 Pausemode) is split out as hockey95_02.

Z80_Program_Code	;$7E0E0. IDA dc.b. First byte of the Z80 program (movea.l in p_initialZ80); the rest is the 94 Z80 driver. p_initialZ80 copies $295
	;bytes from here (through $7E374, into hockey95_02 in 95; 94 read into pcm_sample_table)
	dc.b	$18
	incbin	..\Extracted\NHL95\Sound\z80_snd_drv93.bin	;$7E0E1-$7E357 (94 $1AD91-$1B007). the 93 / 94 Z80 driver after its first byte, up to the ld bc of the FM patch bank address
	dc.b	fm_instrument_patches&$FF,((fm_instrument_patches>>8)&$7F)|$80	;Z80 ld bc,$8000+(fm_instrument_patches&$7FFF): bank window address of the FM patches
	dc.b	$09,$3E,fm_instrument_patches>>15	;Z80 add hl,bc / ld a,bank (32K bank) of the FM patches
	incbin	..\Extracted\NHL95\Sound\z80_snd_drv93_end.bin	;$7E35D-$7E36A (94 $1B00D-$1B01A). rest of the Z80 driver
	dc.b	$FF			;pad: retail leftover byte (94 $FF)
