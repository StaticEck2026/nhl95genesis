;	NHL 95 segment $676D8-$79901, from lst/nhl95.bin.lst. The 95 sound calls (SoundCmd ... ChooseSong, hockey94 / display94 / video94 /
;	title94 routines moved in), then what is left of the 94 sound driver (sound94): z80_bus_release_delay ... p_initialZ80 as 94, IDA dc.b and
;	no caller in 95, with the RAM moved by -$3FC, each Z80 bus request but p_initialZ80's replaced by a SoundCmd $D (pause the 95 driver) and
;	ClearAllTrackAndSFXSlots cut down; collide94 newcheck; then the 94 PCM samples and FM patches (the 94 files). The 95 sound driver
;	itself is sounddrv95 ($AF44-$676D7, split from this placeholder).
;	EA's compiler emits cmp #imm,Dn as CMP (Bxxx), SNASM emits CMPI (0Cxx). The source has the real cmp; fixopcodes.js patches the
;	cmp encoding after assembly.

SoundCmd	;IDA: sub_676D8. Send command d0 to the 95 sound driver (SndDriver, sounddrv95). Called from Begin, Opening2, StartGame ...
	jsr	(SndDriver).l
	bcc.w	.0
	nop
	nop
.0
	rts

UpdateCwdExcite	;IDA: sub_676E8 (hockey94). called once per second. Track peak and running total of crowd excitement, then decay the level by 1
	move.w	(CwdExciteLvl).w,d0
	cmp.w	(MaxCwdExciteLvl).w,d0
	bls.w	.0
	move.w	d0,(MaxCwdExciteLvl).w
.0
	ext.l	d0
	add.l	d0,(SumCwdExciteLvl).w
	addq.w	#1,(NumCwdExciteLvl).w
	subq.w	#1,(CwdExciteLvl).w
	bpl.w	.1
	clr.w	(CwdExciteLvl).w
.1
	rts

updatesound	;IDA: sub_67710 (display94). move the crowd noise volume (psg noise channel, asv) toward crowdlevel. Called from DoGameFrame
	move.w	(crowdlevel).w,d0
	asl.w	#3,d0
	addi.w	#$400,d0
	cmp.w	#$EFF,d0
	bls.w	.0
	move.w	#$EFF,d0
.0
	moveq	#$28,d2
	sub.w	(asv).w,d0
	cmp.w	d2,d0
	bgt.w	.1
	neg.w	d2
	cmp.w	d2,d0
	bge.w	.2
.1
	add.w	d2,(asv).w
	bpl.w	.2
	clr.w	(asv).w
.2
	move.b	#$C8,(VDP_PSG).l
	move.b	#1,(VDP_PSG).l
	move.b	(asv).w,d0
	eori.b	#$F,d0
	ori.b	#$F0,d0
	move.b	d0,(VDP_PSG).l
	rts

CheckPeriodEnd	;IDA: sub_6776A (hockey94). Called once per second. 3rd period: choose and play a song once at the random trigger time set by ResetClock
	cmpi.w	#2,(gsp).w
	bne.w	.0
	btst	#4,(gmode).w
	bne.w	.0
	move.w	(gameclock).w,d0
	cmp.w	(periodendtime).w,d0
	bgt.w	.0
	st	(periodendtime).w
	move.w	(HomeTeam).w,(HmTeam).w
	move.w	#5,(SongIndex).w
	jsr	(ChooseSong).l
	move.w	(SongNum).w,-(sp)
	jsr	(song).l
.0
	rts

sfx	;IDA: sub_677AC (video94). play sound effect number, one word passed on stack. 95: through SfxTable to a sound driver song (command 4)
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d0
	move.w	$40(sp),d0
	bpl.w	sfxplay
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(sp),2(sp)
	addq.w	#2,sp
	rts

sfxplay	;IDA: loc_677C6. 95 only: play sound d0 ($32-$55 are songs, PlayingSong; below, SfxTable). Sound $2D / $2E: a nop. song branches here
	cmp.w	#$2E,d0
	beq.w	.0
	cmp.w	#$2D,d0
	bne.w	.1
.0
	nop
.1
	cmp.w	#$55,d0
	bgt.w	.9
	cmp.w	#$32,d0
	blt.w	.2
	move.w	d0,(PlayingSong).w
	bra.w	.8
.2
	movea.l	#SfxTable,a1
	tst.b	(a1,d0.w)
	bmi.w	.9
	cmpi.b	#$26,(a1,d0.w)
	bne.w	.6
	movem.l	d0-d4/a0-a1,-(sp)
	movea.l	#SndSeqPtr,a0
	movea.w	#(SndSeqId-M68K_RAM),a1
	move.w	#7,d4
	clr.w	d3
.3
	cmpi.l	#$FFFFFFFF,(a0)
	beq.w	.4
	cmpi.w	#$31,(a1,d3.w)
	ble.w	.4
	move.w	(a1,d3.w),d1
	move.w	#5,d0
	move.w	#$FFFF,d2
	jsr	(SndDriver).l
	bra.w	.5
.4
	addq.w	#4,a0
	addq.w	#2,d3
	dbf	d4,.3
.5
	movem.l	(sp)+,d0-d4/a0-a1
.6
	cmp.w	#$B,d0
	beq.w	.7
	cmp.w	#$C,d0
	beq.w	.7
	move.w	d0,(lastsfx).w
.7
	move.b	(a1,d0.w),d0
.8
	ext.w	d0
	move.w	d0,d1
	move.w	#4,d0
	move.w	#$FFFF,d2
	move.w	#$7F,d3
	move.w	#$100,d4
	jsr	(SoundCmd).l
.9
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(sp),2(sp)
	addq.w	#2,sp
	rts

SfxTable	;IDA: unk_67890. 95 only: sound driver song for sound effects 0-$31 (sfx), $FF = none. $26 first stops the songs above $31
	dc.b	$26,$1C,$1D,$17,$16,$FF,$09,$25	;sounds $00-$07
	dc.b	$04,$FF,$FF,$10,$1E,$13,$20,$0E	;sounds $08-$0F
	dc.b	$0B,$0B,$0B,$0B,$08,$08,$08,$08	;sounds $10-$17
	dc.b	$08,$08,$08,$08,$21,$23,$23,$22	;sounds $18-$1F
	dc.b	$18,$15,$15,$15,$25,$04,$04,$04	;sounds $20-$27
	dc.b	$18,$18,$18,$18,$11,$1A,$1A,$FF	;sounds $28-$2F
	dc.b	$FF,$FF	;sounds $30-$31

song	;IDA: sub_678C2 (video94). play song number, one word passed on stack. 95: songs 0-3 through StartSong, the rest through sfxplay
	movem.l	d0-d7/a0-a6,-(sp)
	clr.l	d0
	move.w	$40(sp),d0
	bmi.w	.2
	cmp.w	#$32,d0
	blt.w	.0
	cmp.w	#$55,d0
	bgt.w	.0
	jsr	(play_new_song).l
	move.w	d0,(PlayingSong).w
.0
	cmp.w	#3,d0
	ble.w	.1
	bra.w	sfxplay
.1
	jsr	(StartSong).l
.2
	movem.l	(sp)+,d0-d7/a0-a6
	move.l	(sp),2(sp)
	addq.w	#2,sp
	rts

StartSong	;IDA: sub_67908. 95 only: stop the song (play_new_song), then song d0 (command 4, tempo $100)
	tst.w	d0
	bmi.w	rtsfx
	movem.l	d0-d7/a0-a6,-(sp)
	bsr.w	play_new_song
	move.w	d0,(PlayingSong).w
	move.w	d0,d1
	move.w	#4,d0
	move.w	#$FFFF,d2
	move.w	#$7F,d3
	move.w	#$100,d4
	jsr	(SoundCmd).l
	movem.l	(sp)+,d0-d7/a0-a6
	rts

play_new_song	;IDA: sub_67938. 93 name. Stop the song in progress (PlayingSong, sound driver command 5)
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#5,d0
	move.w	(PlayingSong).w,d1
	bmi.w	.0
	move.w	#$FFFF,d2
	jsr	(SoundCmd).l
	move.w	#$FFFF,(PlayingSong).w
.0
	movem.l	(sp)+,d0-d7/a0-a6
	rts

play_new_song2	;$6795E. IDA dc.b, no xref. 95 only: a copy of play_new_song that skips the saving when no song plays
	tst.w	(PlayingSong).w
	bmi.w	.0	;no song playing
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#5,d0
	move.w	(PlayingSong).w,d1
	move.w	#$FFFF,d2
	jsr	(SoundCmd).l
	movem.l	(sp)+,d0-d7/a0-a6
	move.w	#$FFFF,(PlayingSong).w
.0
	rts

KillCrowd	;IDA: sub_67988 (display94). silence the crowd noise (psg)
	move.b	#$E7,(VDP_PSG).l
	move.b	#$DF,(VDP_PSG).l
	move.b	#$C8,(VDP_PSG).l
	move.b	#1,(VDP_PSG).l
	move.b	#$FF,(VDP_PSG).l
	rts

SoundOff	;IDA: sub_679B2. 95 only (94 p_turnoff): sound driver command $F, every song off
	movem.l	d0-d7/a0-a6,-(sp)
	move.w	#$F,d0
	bsr.w	SoundCmd
	movem.l	(sp)+,d0-d7/a0-a6
	rts

ChooseSong	;IDA: sub_679C4 (title94). SongNum = byte SongIndex of the 6 song bytes of team HmTeam (TeamSongs), or one of the 8 of RandomSongs
	;at random when 0; $FFFF with gmode bit 4
	movem.l	d0-d1/a0-a1,-(sp)
	btst	#4,(gmode).w
	beq.w	.0
	move.w	#$FFFF,d1
	bra.w	.1
.0
	bclr	#6,(sflags8).w
	movea.l	#TeamSongs,a0
	movea.l	#RandomSongs,a1
	move.w	(HmTeam).w,d0
	mulu.w	#6,d0
	add.w	(SongIndex).w,d0
	clr.w	d1
	move.b	(a0,d0.w),d1
	bne.w	.1
	move.w	#8,d0
	jsr	(randomd0).l
	andi.w	#7,d0
	move.b	(a1,d0.w),d1
.1
	ext.w	d1
	move.w	d1,(SongNum).w
	movem.l	(sp)+,d0-d1/a0-a1
	rts

TeamSongs	;IDA: unk_67A20 (title94). 6 song bytes per team (TeamList order), by SongIndex. 0 = a RandomSongs song
	dc.b	$3A,$40,$49,$54,$46,$00	;0 ANH
	dc.b	$51,$42,$40,$00,$46,$51	;1 BOS
	dc.b	$33,$32,$32,$33,$46,$00	;2 BUF
	dc.b	$34,$35,$34,$35,$49,$49	;3 CGY
	dc.b	$36,$39,$37,$36,$46,$4E	;4 CHI
	dc.b	$51,$42,$42,$00,$46,$00	;5 DAL
	dc.b	$38,$3F,$39,$00,$46,$3F	;6 DET
	dc.b	$3B,$51,$51,$00,$46,$00	;7 EDM
	dc.b	$45,$48,$3C,$55,$46,$00	;8 FLA
	dc.b	$3D,$3E,$45,$3E,$46,$3D	;9 HFD
	dc.b	$3F,$3F,$39,$35,$46,$40	;10 LA
	dc.b	$3F,$55,$3F,$44,$46,$43	;11 MTL
	dc.b	$32,$37,$32,$00,$46,$38	;12 NJ
	dc.b	$32,$42,$32,$41,$46,$41	;13 NYI
	dc.b	$51,$42,$32,$00,$46,$00	;14 NYR
	dc.b	$4A,$35,$39,$52,$46,$00	;15 OTW
	dc.b	$45,$37,$45,$33,$00,$33	;16 PHI
	dc.b	$34,$45,$34,$47,$46,$47	;17 PIT
	dc.b	$48,$49,$48,$00,$46,$49	;18 QUE
	dc.b	$4A,$4A,$4B,$4C,$4D,$4E	;19 SJ
	dc.b	$50,$42,$42,$50,$46,$43	;20 STL
	dc.b	$51,$52,$52,$00,$46,$00	;21 TB
	dc.b	$34,$34,$53,$00,$46,$00	;22 TOR
	dc.b	$43,$42,$54,$00,$46,$00	;23 VAN
	dc.b	$3F,$32,$3F,$00,$46,$4A	;24 WSH
	dc.b	$32,$3F,$55,$00,$46,$00	;25 WPG
	dc.b	$51,$42,$32,$00,$46,$00	;26 ASE
	dc.b	$51,$42,$32,$00,$46,$00	;27 ASW
RandomSongs	;IDA: unk_67AC8 (title94). 8 songs ChooseSong picks from at random
	dc.b	$33,$3D,$3E,$41,$33,$47,$4E,$4F

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	The 94 sound driver as 95 keeps it ($67AD0-$682AF, IDA dc.b, nothing calls it). The 94 source (sound94) with the 95 changes
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

z80_bus_release_delay	;93 name. Z80 busy: give the bus back, wait, then falls into UploadCommandBufferToZ80 to retry
	clr.w	(IO_Z80BUS).l
	moveq	#$64,d0
.delay
	dbf	d0,.delay
UploadCommandBufferToZ80	;93 name. Copy the 33 byte command buffer (Z80_command_buffer) to Z80 RAM $02 once the Z80 is idle (Z80 RAM $97 = 0, $96 = $7D)
	move.w	d0,-(sp)	;95: pause the 95 sound driver (SndPauseZ80) where 94 took the Z80 bus
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	movea.l	#Z80_RAM,a0
	cmpi.b	#0,$97(a0)
	bne.s	z80_bus_release_delay
	cmpi.b	#$7D,$96(a0)
	bne.s	z80_bus_release_delay
	move.b	#$D1,$96(a0)
	move.b	#0,$97(a0)
	adda.w	#2,a0
	movea.w	#(Z80_command_buffer-M68K_RAM),a1
	moveq	#$20,d0
.copy
	move.b	(a1)+,(a0)+
	dbf	d0,.copy
	clr.w	(IO_Z80BUS).l
rtscmd10	;The shared rts; handle_command_10 branches to it
	rts
ProcessOneMusicTrack	;93 name. Count down track slot a5 (track d7) and run every event that is due through command_jump_table. A 0
	;status ends the stream; a non-negative long at +2 is a loop pointer. Called from p_music_vblank
	subq.w	#1,4(a5)
	bpl.w	rtsfx
.event
	tst.w	(a5)
	bmi.w	rtsfx
	movea.l	(a5),a0
	addq.l	#4,(a5)
	clr.w	4(a5)
	move.b	4(a0),5(a5)
	move.b	1(a0),d0
	bne.w	.cmd
	st	(a5)
	tst.w	2(a0)
	bmi.w	rtsfx
	move.l	2(a0),(a5)
	bra.s	.event
.cmd
	move.b	1(a0),d0
	andi.w	#$70,d0	;status bits 6-4
	lsr.w	#3,d0
	lea	command_jump_table(pc),a2
	adda.w	0(a2,d0.w),a2
	jsr	(a2)
	bra.s	ProcessOneMusicTrack
command_jump_table	;93 name. Event handlers by status bits 6-4, as offsets from the table. 94 adds handle_command_30
	dc.w	handle_command_00-command_jump_table
	dc.w	handle_command_10-command_jump_table
	dc.w	handle_command_skip-command_jump_table
	dc.w	handle_command_30-command_jump_table
	dc.w	handle_command_40-command_jump_table
	dc.w	handle_command_skip-command_jump_table
	dc.w	handle_command_60-command_jump_table
	dc.w	handle_command_skip-command_jump_table
handle_command_00	;93 name. Event $0x: key off note +2 on channel +1 bits 3-0 of track d7. Also entered from handle_command_10 (volume 0). Falls into ReleaseChannelAndNote
	move.b	1(a0),d0
	andi.w	#$F,d0
	asl.w	#3,d0
	or.w	d7,d0
	asl.w	#8,d0
	move.b	2(a0),d0
	movea.w	#(fm_track_slots-M68K_RAM),a2
	moveq	#5,d1
.find
	subq.w	#8,a2
	cmp.w	(a2),d0
	dbeq	d1,.find
	bne.w	rtsfx
	btst	#0,6(a2)
	dbne	d1,.find
	beq.w	rtsfx
ReleaseChannelAndNote	;93 name. Key off channel struct a2 if it is on. The PCM patches ($60 up) stop the PCM channel (ClearZ80SpecialEffectsFlags)
	bclr	#0,6(a2)
	beq.w	rtsfx
	cmpi.b	#$60,3(a2)
	bge.w	ClearZ80SpecialEffectsFlags
	move.b	4(a2),d0
	bset	d0,(Z80_command_buffer).w
	st	(music_needs_z80_update).w
	rts
ClearZ80SpecialEffectsFlags	;93 name. Clear Z80 RAM $8E (Z80_RAM+$8E, the PCM rate byte written by UpdateChannelFrequencyAndVolume): stops the PCM channel
	move.w	d0,-(sp)	;95: pause the 95 sound driver (SndPauseZ80) where 94 took the Z80 bus
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	clr.b	(Z80_RAM+$8E).l
	clr.w	(IO_Z80BUS).l
rtsfx	;95: the shared rts (94 had it in play_sfx_or_music_track, not in 95). ProcessOneMusicTrack, handle_command_00 and StartSong branch here
	rts
handle_command_10	;93 name. Event $1x: key on note +2 at volume +3 on channel +1 bits 3-0 of track d7 (volume 0 = key off). An FM
	;patch takes a free channel or the oldest one; a PCM patch ($60 up) sets the sample start / end (pcm_sample_table, 93 name) in Z80 RAM
	;$23-$28. Then the volume (SetChannelVolume) and the frequency (UpdateChannelFrequencyAndVolume)
	tst.b	3(a0)
	beq.s	handle_command_00	;volume 0: key off
	movea.w	#(fm_channel_struct6-M68K_RAM),a2
	lea	(fm_voice_usage_table).w,a3
	move.b	1(a0),d0
	andi.w	#$F,d0
	asl.w	#3,d0
	or.w	d7,d0
	move.w	d0,d6
	asl.w	#3,d0
	move.b	3(a3,d0.w),d0
	cmp.b	#$60,d0
	bge.w	.pcm	;PCM patch
	subq.w	#8,a2
	moveq	#4,d1
	bra.w	.setold
.old
	cmp.b	5(a2),d2
	bhi.w	.nextold
.setold
	movea.w	a2,a4
	move.b	5(a4),d2
.nextold
	subq.w	#8,a2
	dbf	d1,.old
	moveq	#4,d1
	movea.w	#(fm_channel_struct6-M68K_RAM),a2
.free
	subq.w	#8,a2
	btst	#0,6(a2)
	dbeq	d1,.free
	bne.w	.0
	movea.w	a2,a4
	cmp.b	3(a4),d0
	dbeq	d1,.free
	beq.w	.keyon
	bra.w	.patch
.0
	cmp.b	3(a4),d0
	beq.w	.keyon
.patch
	movea.w	a4,a2
.1
	move.b	d0,3(a2)
	clr.w	d1
	move.b	4(a2),d1
	bset	d1,(Z80_command_buffer+4).w
	movea.w	#(per_channel_patch_table-M68K_RAM),a4
	move.b	d0,0(a4,d1.w)
	st	(music_needs_z80_update).w
.keyon
	clr.b	5(a2)
	bset	#0,6(a2)
	move.b	d6,(a2)
	move.b	2(a0),1(a2)
	move.b	3(a0),2(a2)
	clr.w	d1
	move.b	4(a2),d1
	bset	d1,(Z80_command_buffer).w
	bset	d1,(Z80_command_buffer+1).w
	bsr.w	SetChannelVolume
	bra.w	UpdateChannelFrequencyAndVolume
.pcm
	bset	#0,6(a2)
	beq.w	.pcmon
	cmp.b	3(a2),d0
	ble.w	rtscmd10
.pcmon
	move.b	d0,3(a2)
	clr.b	5(a2)
	move.b	d6,(a2)
	move.b	2(a0),1(a2)
	move.b	3(a0),2(a2)
	ext.w	d0
	subi.w	#$60,d0
	asl.w	#3,d0
	lea	pcm_sample_table(pc),a1	;PCM sample start, end longs by patch - $60
	move.l	4(a1,d0.w),d1
	move.l	0(a1,d0.w),d0
	move.w	d0,-(sp)	;95: pause the 95 sound driver (SndPauseZ80) where 94 took the Z80 bus
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	movea.l	#Z80_RAM,a1
	move.b	d0,$25(a1)
	lsr.w	#8,d0
	move.b	d0,$24(a1)
	swap	d0
	move.b	d0,$23(a1)
	move.b	d1,$28(a1)
	lsr.w	#8,d1
	move.b	d1,$27(a1)
	swap	d1
	move.b	d1,$26(a1)
	move.b	#$29,$96(a1)
	move.b	#0,$97(a1)
	clr.w	(IO_Z80BUS).l
	bsr.w	SetChannelVolume
UpdateChannelFrequencyAndVolume	;93 name. Set the frequency of channel struct a2 from its note and the pitch bend of its key (a3 =
	;voice table, word +0 = bend). Called from handle_command_60 and handle_command_10
	clr.l	d3
	move.b	1(a2),d3
	divu.w	#$C,d3	;d3 = octave, high word = note in the octave
	move.w	d3,-(sp)
	swap	d3
	add.w	d3,d3
	lea	.fnum(pc),a4
	move.w	0(a4,d3.w),d2
	clr.w	d1
	move.b	(a2),d1
	asl.w	#3,d1
	move.w	0(a3,d1.w),d3
	beq.w	.nobend
	moveq	#$C,d1
	cmpi.b	#$60,3(a2)
	bge.w	.0
	move.b	3(a2),d1
	asl.w	#5,d1
	lea	(fm_instrument_patches).l,a4	;32 bytes per patch
	move.b	$1E(a4,d1.w),d1	;byte $1E = pitch bend scale
	ext.w	d1
.0
	muls.w	d1,d3
	asr.l	#2,d3
	asr.w	#7,d3
	addi.w	#$C0,d3	;centre of .bendtab
	add.w	d3,d3
	lea	.bendtab(pc),a4
	mulu.w	0(a4,d3.w),d2
	asl.l	#1,d2
	swap	d2
.nobend
	move.w	(sp)+,d3
	cmpi.b	#$60,3(a2)
	bge.w	.1
	asl.w	#3,d3
	asl.w	#8,d3
	or.w	d3,d2
	clr.w	d3
	move.b	4(a2),d3
	bset	d3,(Z80_command_buffer+3).w
	add.w	d3,d3
	movea.w	#(per_channel_frequency_table-M68K_RAM),a4
	move.w	d2,0(a4,d3.w)
	st	(music_needs_z80_update).w
	rts
.1
	btst	#0,6(a2)
	beq.w	.x
	move.w	d0,-(sp)	;95: pause the 95 sound driver (SndPauseZ80) where 94 took the Z80 bus
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	neg.w	d3
	addq.w	#8,d3
	lsr.w	d3,d2
	move.b	d2,(Z80_RAM+$8E).l
	clr.w	(IO_Z80BUS).l
.x
	rts
.fnum	;frequency number of each note in the octave
	dc.w	$0146,$0159,$016E,$0184,$019B,$01B3,$01CD,$01E8,$0205,$0224,$0245,$0268
.bendtab	;385 factors, entry $C0 = $8000 (no bend)
	dc.w	$4000,$403B,$4076,$40B2,$40EE,$412A,$4166,$41A3,$41E0,$421D
	dc.w	$425A,$4297,$42D5,$4313,$4351,$438F,$43CE,$440D,$444C,$448B
	dc.w	$44CA,$450A,$454A,$458A,$45CA,$460B,$464C,$468D,$46CE,$4710
	dc.w	$4752,$4794,$47D6,$4818,$485B,$489E,$48E1,$4925,$4969,$49AD
	dc.w	$49F1,$4A35,$4A7A,$4ABF,$4B04,$4B4A,$4B8F,$4BD5,$4C1B,$4C62
	dc.w	$4CA9,$4CF0,$4D37,$4D7E,$4DC6,$4E0E,$4E56,$4E9F,$4EE8,$4F31
	dc.w	$4F7A,$4FC4,$500E,$5058,$50A2,$50ED,$5138,$5183,$51CE,$521A
	dc.w	$5266,$52B2,$52FF,$534C,$5399,$53E6,$5434,$5482,$54D0,$551F
	dc.w	$556E,$55BD,$560C,$565C,$56AC,$56FC,$574C,$579D,$57EE,$5840
	dc.w	$5891,$58E3,$5936,$5988,$59DB,$5A2E,$5A82,$5AD6,$5B2A,$5B7E
	dc.w	$5BD3,$5C28,$5C7D,$5CD3,$5D29,$5D7F,$5DD6,$5E2D,$5E84,$5EDB
	dc.w	$5F33,$5F8B,$5FE4,$603D,$6096,$60EF,$6149,$61A3,$61FD,$6258
	dc.w	$62B3,$630E,$636A,$63C6,$6423,$647F,$64DC,$653A,$6597,$65F6
	dc.w	$6654,$66B3,$6712,$6771,$67D1,$6831,$6892,$68F2,$6954,$69B5
	dc.w	$6A17,$6A79,$6ADC,$6B3F,$6BA2,$6C06,$6C6A,$6CCE,$6D33,$6D98
	dc.w	$6DFD,$6E63,$6EC9,$6F30,$6F97,$6FFE,$7066,$70CE,$7136,$719F
	dc.w	$7208,$7272,$72DC,$7346,$73B1,$741C,$7488,$74F4,$7560,$75CD
	dc.w	$763A,$76A7,$7715,$7783,$77F2,$7861,$78D0,$7940,$79B0,$7A21
	dc.w	$7A92,$7B04,$7B76,$7BE8,$7C5B,$7CCE,$7D41,$7DB5,$7E2A,$7E9F
	dc.w	$7F14,$7F89,$8000,$8076,$80ED,$8164,$81DC,$8254,$82CD,$8346
	dc.w	$83C0,$843A,$84B4,$852F,$85AA,$8626,$86A2,$871F,$879C,$881A
	dc.w	$8898,$8916,$8995,$8A14,$8A94,$8B14,$8B95,$8C16,$8C98,$8D1A
	dc.w	$8D9D,$8E20,$8EA4,$8F28,$8FAC,$9031,$90B7,$913D,$91C3,$924A
	dc.w	$92D2,$935A,$93E2,$946B,$94F4,$957E,$9609,$9694,$971F,$97AB
	dc.w	$9837,$98C4,$9952,$99E0,$9A6E,$9AFD,$9B8D,$9C1D,$9CAD,$9D3E
	dc.w	$9DD0,$9E62,$9EF5,$9F88,$A01C,$A0B0,$A145,$A1DA,$A270,$A306
	dc.w	$A39D,$A435,$A4CD,$A565,$A5FE,$A698,$A732,$A7CD,$A868,$A904
	dc.w	$A9A1,$AA3E,$AADC,$AB7A,$AC18,$ACB8,$AD58,$ADF8,$AE99,$AF3B
	dc.w	$AFDD,$B080,$B123,$B1C7,$B26C,$B311,$B3B7,$B45D,$B504,$B5AC
	dc.w	$B654,$B6FD,$B7A7,$B851,$B8FB,$B9A6,$BA52,$BAFF,$BBAC,$BC5A
	dc.w	$BD08,$BDB7,$BE67,$BF17,$BFC8,$C07A,$C12C,$C1DF,$C292,$C346
	dc.w	$C3FB,$C4B1,$C567,$C61D,$C6D5,$C78D,$C846,$C8FF,$C9B9,$CA74
	dc.w	$CB2F,$CBEC,$CCA8,$CD66,$CE24,$CEE3,$CFA2,$D063,$D124,$D1E5
	dc.w	$D2A8,$D36B,$D42E,$D4F3,$D5B8,$D67E,$D744,$D80C,$D8D4,$D99D
	dc.w	$DA66,$DB30,$DBFB,$DCC7,$DD93,$DE60,$DF2E,$DFFD,$E0CC,$E19D
	dc.w	$E26D,$E33F,$E411,$E4E5,$E5B9,$E68D,$E763,$E839,$E910,$E9E8
	dc.w	$EAC0,$EB9A,$EC74,$ED4F,$EE2A,$EF07,$EFE4,$F0C2,$F1A1,$F281
	dc.w	$F361,$F443,$F525,$F608,$F6EC,$F7D0,$F8B6,$F99C,$FA83,$FB6B
	dc.w	$FC54,$FD3E,$FE28,$FF13,$FF13
SetChannelVolume	;94 only. Set the volume of channel struct a2: note volume (+2) * the voice volume (voice table +4) / 128. FM: attenuation from
	;.veltab (volume / 8); PCM: Z80 RAM $83 (Z80_RAM+$83, at least 3). Called from handle_command_10 and handle_command_30
	movem.l	d0,-(sp)
	clr.w	d0
	move.b	2(a2),d0
	clr.w	d1
	move.b	(a2),d1
	asl.w	#3,d1
	mulu.w	4(a3,d1.w),d0
	lsr.w	#7,d0
	cmpi.b	#$60,3(a2)
	bge.w	.0
	lea	.veltab(pc),a4
	lsr.w	#3,d0
	move.b	0(a4,d0.w),d0
	clr.w	d3
	move.b	4(a2),d3
	movea.w	#(per_channel_attenuation_table-M68K_RAM),a4
	move.b	d0,0(a4,d3.w)
	bset	d3,(Z80_command_buffer+2).w
	st	(music_needs_z80_update).w
	movem.l	(sp)+,d0
	rts
.veltab	;attenuation by volume / 8 (93 handle_command_10 .veltab)
	dc.b	$1A,$18,$16,$14,$12,$10,$0E,$0C,$0A,$08,$06,$04,$03,$02,$01,$00
.0
	move.w	d0,-(sp)	;95: pause the 95 sound driver (SndPauseZ80) where 94 took the Z80 bus
	move.w	#$D,d0
	jsr	(SoundCmd).l
	move.w	(sp)+,d0
	lsr.b	#2,d0
	cmp.w	#3,d0
	bgt.w	.1
	moveq	#3,d0
.1
	move.b	d0,(Z80_RAM+$83).l
	clr.w	(IO_Z80BUS).l
	movem.l	(sp)+,d0
	rts
handle_command_40	;93 name. Event $4x: set the patch of channel +1 bits 3-0 of track d7 to +2 (voice table +3)
	lea	(fm_voice_usage_table).w,a3
	move.b	1(a0),d0
	andi.w	#$F,d0
	asl.w	#3,d0
	or.w	d7,d0
	asl.w	#3,d0
	move.b	2(a0),3(a3,d0.w)
	rts
handle_command_60	;93 name. Event $6x: set the pitch bend of channel +1 bits 3-0 of track d7 to word +2 - $2000, and update the frequency of every channel with that key
	lea	(fm_voice_usage_table).w,a3
	move.b	1(a0),d0
	andi.w	#$F,d0
	asl.w	#3,d0
	or.w	d7,d0
	move.w	d0,d4
	asl.w	#3,d0
	move.w	2(a0),0(a3,d0.w)
	subi.w	#$2000,0(a3,d0.w)
	movea.w	#(fm_channel_structs-M68K_RAM),a2
	moveq	#5,d0
.loop
	cmp.b	(a2),d4
	bne.w	.next
	bsr.w	UpdateChannelFrequencyAndVolume
.next
	addq.w	#8,a2
	dbf	d0,.loop
	rts
handle_command_30	;IDA dc.b. 94 only: event $3x, controller +2 = +3 on channel +1 bits 3-0 of track d7. Only controller 7
	;(volume) is used: set the voice volume (voice table +5) and update the volume of every channel with that key (SetChannelVolume)
	cmpi.b	#7,2(a0)
	beq.w	.0
	rts
.0
	lea	(fm_voice_usage_table).w,a3
	move.b	1(a0),d0
	andi.w	#$F,d0
	asl.w	#3,d0
	or.w	d7,d0
	move.w	d0,d4
	asl.w	#3,d0
	move.b	3(a0),5(a3,d0.w)
	movea.w	#(fm_channel_structs-M68K_RAM),a2
	moveq	#5,d0
.loop
	cmp.b	(a2),d4
	bne.w	.1
	bsr.w	SetChannelVolume
.1
	addq.w	#8,a2
	dbf	d0,.loop
	rts
handle_command_skip	;93 name. Events $2x, $5x and $7x: ignored
	rts
p_initialZ80	;IDA: Z80_LoadROM. 92 name (initialization). Free all slots, load the Z80 program (Z80_Program_Code, $295 bytes) into Z80 RAM, build 29
	;tables of 256 bytes below Z80 RAM $2000 (Z80_RAM+$2000; (x - $80) * 8 / n + $80 for n = 8-$24), then reset and start the Z80. Called from Begin
	movem.l	d0-d2/a0-a2,-(sp)
	bsr.w	ClearAllTrackAndSFXSlots
	move.w	#$100,(IO_Z80RES).l
	move.w	#$100,(IO_Z80BUS).l	;95 keeps the 94 bus request here
.loop
	btst	#0,(IO_Z80BUS).l
	bne.s	.loop
	movea.l	#Z80_Program_Code,a1
	movea.l	#Z80_RAM,a2
	move.w	#$294,d0	;$295 bytes
.loop2
	move.b	(a1)+,(a2)+
	dbf	d0,.loop2
	movea.l	#Z80_RAM+$2000,a2
	moveq	#8,d2
	move.l	#$1C,d3
.loop3
	move.w	#$FF,d0
.loop4
	move.w	d0,d1
	subi.w	#$80,d1
	asl.w	#3,d1
	ext.l	d1
	divs.w	d2,d1
	addi.w	#$80,d1
	move.b	d1,-(a2)
	dbf	d0,.loop4
	clr.b	(a2)
	addq.w	#1,d2
	dbf	d3,.loop3
	move.w	#0,(IO_Z80RES).l
	move.w	#0,(IO_Z80BUS).l
	move.w	#$1F4,d0
.loop5
	dbf	d0,.loop5
	move.w	#$100,(IO_Z80RES).l
	clr.b	(music_needs_z80_update).w
	movem.l	(sp)+,d0-d2/a0-a2
	rts
ClearAllTrackAndSFXSlots	;$682A8. 93 name. 95 cuts it down to PlayingSong = -1 (94 freed the 8 track slots and reset the 6 channel structs)
	move.w	#$FFFF,(PlayingSong).w
	rts

newcheck	;IDA: sub_682B0 (collide94). start a new check sound: one of 4 sounds $1C-$1F, never the last one again. Called from checkcx and FallDown
	move.l	d0,-(sp)
	moveq	#3,d0
	jsr	(randomd0).l	;94: bsr.w
	addq.w	#1,d0	;1-3 sounds on from the last one
	add.w	(ltack).w,d0	;last tackle sound (92 ltack)
	andi.w	#3,d0
	move.w	d0,(ltack).w
	addi.w	#$1C,d0	;first check sound (92 SFXcheck = 18)
	move.w	d0,-(sp)
	bsr.w	sfx
	move.l	(sp)+,d0
	rts

;	The 94 PCM samples and FM patches, the same bytes as 94 (the 94 files) at $682D6-$79901. The old driver above points at them
pcm_sample_table	;93 name: (sample address, 0) for PCM patches $60-$6E (lea in handle_command_10)
	dc.l	sfx_puckget_pcm,0		;patch $60
	dc.l	sfx_pass_pcm,0		;patch $61
	dc.l	sfx_shotbh_pcm,0		;patch $62
	dc.l	sfx_shotfh_pcm,0		;patch $63
	dc.l	sfx_check2_pcm,0		;patch $64
	dc.l	sfx_check_pcm,0		;patch $65
	dc.l	sfx_playerwall_pcm,0		;patch $66
	dc.l	sfx_hithigh_pcm,0		;patch $67
	dc.l	0,0		;patch $68
	dc.l	0,0		;patch $69
	dc.l	sfx_hithigh_pcm,0		;patch $6A
	dc.l	sfx_crowdboo_pcm,0		;patch $6B
	dc.l	sfx_oooh_pcm,0		;patch $6C
	dc.l	sfx_crowdcheer_pcm,0		;patch $6D
	dc.l	sfx_id_0E_pcm,0		;patch $6E
sfx_shotbh_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_shotbh_pcm.bin	;$6834E-$68541 (94 $1B094-$1B287). sample 2: shotbh
	even
sfx_pass_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_pass_pcm.bin	;$68542-$6926E (94 $1B288-$1BFB4). sample 1: pass
	dc.b	$FF			;pad: retail leftover byte
sfx_oooh_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_oooh_pcm.bin	;$69270-$6C4B3 (94 $1BFB6-$1F1F9). sample 12: oooh, sfx_id_0D, sfx_id_0E
	even
sfx_crowdboo_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_crowdboo_pcm.bin	;$6C4B4-$6EA00 (94 $1F1FA-$21746). sample 11: crowdboo
	dc.b	$FF			;pad: retail leftover byte
sfx_check_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_check_pcm.bin	;$6EA02-$70953 (94 $21748-$23699). sample 5: check1, check3
	even
sfx_crowdcheer_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_crowdcheer_pcm.bin	;$70954-$73833 (94 $2369A-$26579). sample 13: crowdcheer, homewin
	even
sfx_id_0E_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_id_0E_pcm.bin	;$73834-$772B2 (94 $2657A-$29FF8). sample 14: sfx_id_0E
	dc.b	$FF			;pad: retail leftover byte
sfx_playerwall_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_playerwall_pcm.bin	;$772B4-$77763 (94 $29FFA-$2A4A9). sample 6: playerwall, sfx_id_21-23
	even
sfx_check2_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_check2_pcm.bin	;$77764-$78192 (94 $2A4AA-$2AED8). sample 4: check2, check4
	dc.b	$FF			;pad: retail leftover byte
sfx_hithigh_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_hithigh_pcm.bin	;$78194-$786E9 (94 $2AEDA-$2B42F). samples 7 and 10: hithigh, hitlow, check1-4, songs $32 and $35-$37
	even
sfx_shotfh_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_shotfh_pcm.bin	;$786EA-$792A1 (94 $2B430-$2BFE7). sample 3: shotfh
	even
sfx_puckget_pcm
	incbin	..\Extracted\NHL95\Sound\sfx_puckget_pcm.bin	;$792A2-$79501 (94 $2BFE8-$2C247). sample 0: puckget
	even
fm_instrument_patches	;93 name: 32 FM patches x 32 bytes, byte $1E = pitch bend scale (UpdateChannelFrequencyAndVolume)
	incbin	..\Extracted\NHL95\Sound\fm_instrument_patches.bin	;$79502-$79901 (94 $2C248-$2C647). 32 FM patches x 32 bytes (byte $1E = pitch bend scale)
	even
