	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	penalty95 segment stub. Retail $088F06-$08996D.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$88F06

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $088F06-$08996D, read from lst/nhl95.bin.
sfx = $677AC			;IDA: sub_677AC. used at $890EA, $89600 (sound95_01)
song = $678C2			;IDA: sub_678C2. used at $891A0 (sound95_01)
play_new_song = $67938		;IDA: sub_67938. used at $890E0 (sound95_01)
ChooseSong = $679C4		;IDA: sub_679C4. used at $88FE6, $89002 (sound95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $892F6 (video95_01)
Framer = $7A270			;IDA: sub_7A270. used at $89906 (video95_02)
printz = $7C810			;IDA: sub_7C810. used at $89242, $898AC, $898CA, $89924, $8994A (video95_03)
print = $7C822			;IDA: sub_7C822. used at $89914 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $89266, $898C0 (video95_03)
GetPeriodTimeRemaining = $7D762	;IDA: sub_7D762. used at $893B8 (video95_03)
Setplass = $81540		;IDA: sub_81540. used at $89684 (checks95_02)
assinsert = $81570		;IDA: sub_81570. used at $89306 (checks95_02)
assreplace = $8157A		;IDA: sub_8157A. used at $894A0, $89508 (checks95_02)
setplayer = $83960		;IDA: sub_83960. used at $8968A (collide95_02)
priolist = $83E16		;IDA: unk_83E16. used at $8966A (collide95_02)
PenaltyNames = $89C2E		;IDA: unk_89C2E. used at $891BC, $892B2, $89388, $896BE, $896FA, $897CC, $898D6, $89930 (data95_02)
chkatop = $8AB7E		;IDA: sub_8AB7E. used at $89572 (checks95_05)
updatePPTeamTime = $8ABB4	;IDA: sub_8ABB4. used at $89578 (checks95_05)
DisplayPlayerAttributeMenu = $8C6B0	;IDA: loc_8C6B0. used at $8977C (checks95_06)
DisplayPeriodOver = $95B1E	;IDA: sub_95B1E. used at $89748 (stats95_01)
ShootoutWonBy = $9DFE6		;IDA: sub_9DFE6. used at $89796 (shootout95)
PenaltyShotBox = $9EDD2		;IDA: sub_9EDD2. used at $89274 (checks95_07)
RefTiles = $14EB04		;IDA: unk_14EB04. used at $89830 (graphics95_01)
RefTilesHor = $14FBA2		;IDA: unk_14FBA2. used at $892F0, $89840 (graphics95_01)

; Main segment code
	include	penalty95.asm
