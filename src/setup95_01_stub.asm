;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	setup95_01 segment stub. Retail $00A656-$00AF43.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$A656

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $00A656-$00AF43, read from lst/nhl95.bin: jsr / jmp (x).l and movea.l / movea.w #x carry the address.
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. jsr (x).l at $A964 (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. jsr (x).l at $A984 (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. jsr (x).l at $A9A2 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. jsr (x).l at $A9C0 (video95_02)
doinput = $83EB2		;IDA: sub_83EB2. jsr (x).l at $A972 (collide95_02)
doassignment = $7FD84		;IDA: sub_7FD84. 95 only: run a3's assignment (94 updateplayers does the asstab call in line). jsr (x).l at $A9D6 (checks95_01)
checkcoll = $7A7B4		;IDA: sub_7A7B4. jsr (x).l at $A9FA (collide95_01)
chkcheckstart = $8D39A		;IDA: sub_8D39A. 95 only: may change d1 to SPAcheckstart. jsr (x).l at $AA3A (replay95)
SetSPA = $8BC9A			;IDA: sub_8BC9A. jmp (x).l at $AA40 (checks95_06)
getpde = $7CAD0			;IDA: sub_7CAD0. jsr (x).l at $AA86 (video95_03)
setpde = $7DBCA			;IDA: sub_7DBCA. jsr (x).l at $AA98 (video95_03)
dirtab = $8B9D6			;IDA: unk_8B9D6. movea.l #x at $AAB6 (checks95_06)
Sweepcheck = $7B08A		;IDA: loc_7B08A. jmp (x).l at $AD54 (collide95_01)
LoadTeamLines = $8A622		;IDA: loc_8A622. 95 only: the line sets of team struct a2 (save RAM or the team data). jmp (x).l at $AF14 (checks95_05)
TeamList = $772			;movea.w #x at $AF08 (teamdata95)
; frames95 SPA tables (frames95.asm defines them in the full build)
SPAskate = $2
SPAskatewp = $738
SPAHold = $E10
SPAhook = $E74
SPAburst = $11AE

; Main segment code
	include	setup95_01.asm
