;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	hockey95_02 segment stub. Retail $07E36C-$07E4D5.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$7E36C

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $07E36C-$07E4D5, read from lst/nhl95.bin.
setvideo = $A204		;IDA: sub_A204. used at $7E49A (display95_01)
Z80Program = $BD86		;movea.l #x at $7E44C. The 95 Z80 sound program (sounddrv95)
SoundBanks = $D8EC		;movea.l #x at $7E45E. The sound bank (sounddrv95)
SoundCmd = $676D8		;IDA: sub_676D8. used at $7E43E, $7E452, $7E464, $7E472 (sound95_01)
play_new_song = $67938		;IDA: sub_67938. used at $7E434 (sound95_01)
KillCrowd = $67988		;IDA: sub_67988. used at $7E4CE (sound95_01)
SoundOff = $679B2		;IDA: sub_679B2. used at $7E3A0 (sound95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $7E378, $7E414 (video95_02)
ReadMenuJoy = $7A6AA		;IDA: sub_7A6AA. used at $7E3E0 (video95_02)
ProcessInputWithRepeat = $7A762	;IDA: sub_7A762. used at $7E406 (collide95_01)
vcountwait = $7C6BE		;IDA: sub_7C6BE. used at $7E3DA (video95_03)
AnyPadAssigned = $7DFAC		;IDA: sub_7DFAC. used at $7E3F4 (fourway95)
seta2 = $7E4D6			;IDA: sub_7E4D6. used at $7E3AE (menu95)
InitMenuState = $7E526		;IDA: sub_7E526. used at $7E3CC (menu95)
HandleMenuInput = $7E560	;IDA: sub_7E560. used at $7E40C (menu95)
SetPauseMenuItems = $7E6CA	;IDA: sub_7E6CA. used at $7E3C0. 95: menulist / menuitemoffset by game mode (menu95)
PauseScreenDraw = $7E816	;no IDA label. jsr (x).l at $7E4C8. The pause screen draw code (menu95)
ClrHor = $7EBBE			;IDA: sub_7EBBE. used at $7E47C. Rebuild the vertical rink screen (menu95)
PracticeGoalies = $8CADE	;IDA: sub_8CADE. used at $7E424 (checks95_06)

; Main segment code
	include	hockey95_02.asm
