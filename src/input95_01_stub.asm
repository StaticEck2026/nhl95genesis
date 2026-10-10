;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	input95_01 segment stub. Retail $083EB2-$084FE5.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$83EB2

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $083EB2-$084FE5, read from lst/nhl95.bin.
holdplayer = $AA18		;IDA: loc_AA18. used at $8402C (setup95_01)
burstchk = $AA7A		;IDA: loc_AA7A. used at $84282 (setup95_01)
setpads = $AB2A			;IDA: sub_AB2A. used at $83F3A (setup95_01)
chgplayer = $AB4E		;IDA: sub_AB4E. used at $8407C, $8440E (setup95_01)
setc1player = $AD80		;IDA: loc_AD80. used at $841D2 (setup95_01)
setc2player = $AD8A		;IDA: loc_AD8A. used at $841E0 (setup95_01)
setc3player = $AD96		;IDA: loc_AD96. used at $841EE (setup95_01)
setc4player = $ADA2		;IDA: loc_ADA2. used at $841F4 (setup95_01)
sfx = $677AC			;IDA: sub_677AC. used at $8470E, $84E0A (sound95_01)
sroot = $7C512			;IDA: sub_7C512. used at $847AA, $849C0, $84CA4, $84E9E (video95_03)
vtoa = $7C586			;IDA: sub_7C586. used at $845C6, $846A8, $84A8A (video95_03)
randomd0s = $7C62E		;IDA: sub_7C62E. used at $84D20, $84D42 (video95_03)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $8464E, $848FC, $84908, $84CE0, $84D50 (video95_03)
GetHot = $7C672			;IDA: sub_7C672. used at $84748 (video95_03)
makepde = $7CAA6		;IDA: sub_7CAA6. used at $84C2A (video95_03)
loadTeamStruct = $7CAF0		;IDA: sub_7CAF0. used at $84724 (video95_03)
ReadGoaliePulled = $7CB0A	;IDA: sub_7CB0A. used at $84CC6 (video95_03)
startpause1 = $7E7F8		;IDA: loc_7E7F8. used at $83F4A (menu95)
startpause2 = $7E7FE		;IDA: loc_7E7FE. used at $83F52 (menu95)
startpause3 = $7E806		;IDA: loc_7E806. used at $83F5A (menu95)
startpause4 = $7E80E		;IDA: loc_7E80E. used at $83F62 (menu95)
puckflip = $81336		;IDA: sub_81336. used at $84A0A (checks95_02)
assinsert = $81570		;IDA: sub_81570. used at $8473E (checks95_02)
assreplace = $8157A		;IDA: sub_8157A. used at $83FDE, $8426C, $84FE0 (checks95_02)
PuckOnAttackHalf = $82E88	;IDA: sub_82E88. used at $84258 (onetimer95)
checkob = $89F5C		;IDA: sub_89F5C. used at $84288 (data95_02)
SetLCmode = $8A056		;IDA: loc_8A056. used at $8435A (input95_02)
lineinput = $8A202		;IDA: loc_8A202. used at $83F76 (input95_02)
doinput_goaliedive = $8B6F8	;IDA: loc_8B6F8. used at $84202. 94 doinput .33: the goalie dive on A (checks95_05)
FindGoalie = $8B974		;IDA: sub_8B974. used at $841A4 (input95_03)
dirtab = $8B9D6			;IDA: unk_8B9D6. used at $84616 (checks95_06)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $844B0, $844BA, $846E6, $84AC8, $84B86 (checks95_06)
doplayeracc = $8BCFA		;IDA: loc_8BCFA. used at $8421A, $843E0, $843E8 (checks95_06)
PSandSOpassdir = $9DAD0		;IDA: sub_9DAD0. used at $84F12 (title95_01)
ShortenMsgTimer = $9EFE4	;IDA: sub_9EFE4. used at $83F2A (checks95_07)

; Main segment code
	include	input95_01.asm
