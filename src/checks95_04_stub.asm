	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	checks95_04 segment stub. Retail $088046-$088F05.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$88046

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $088046-$088F05, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $88322, $88348 (teamdata95)
SprSort = $A8E6			;IDA: sub_A8E6. used at $8898C (setup95_01)
sfx = $677AC			;IDA: sub_677AC. used at $88C40 (sound95_01)
song = $678C2			;IDA: sub_678C2. used at $88A76 (sound95_01)
ChooseSong = $679C4		;IDA: sub_679C4. used at $88498 (sound95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $88E9C (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $889A4, $889B4, $88C5C (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $886E6 (display95_02)
Framer = $7A270			;IDA: sub_7A270. used at $88EC0 (video95_02)
vtoa = $7C586			;IDA: sub_7C586. used at $88964 (video95_03)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $889E4, $88B92, $88CA2, $88CDE, $88D30 (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $88EB0, $88EDA (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $88BF0, $88E42 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $88C2A (video95_03)
PrintSmallListItem = $7CB38	;IDA: sub_7CB38. used at $88EEC, $88EFE (video95_03)
ClrHor = $7D4E2			;no IDA label. used at $88776 (video95_03)
AssignPads = $7D540		;no IDA label. used at $88994 (video95_03)
PrintScores1 = $7D776		;IDA: sub_7D776. used at $885B0, $88A7C, $88C36 (video95_03)
WeightedRandomSelect = $7DC0A	;IDA: loc_7DC0A. used at $88372 (video95_03)
assexit = $8155E		;IDA: sub_8155E. used at $88B06, $88BB4 (checks95_02)
assinsert = $81570		;IDA: sub_81570. used at $888D0 (checks95_02)
assreplace = $8157A		;IDA: sub_8157A. used at $883E4, $88650, $88D46 (checks95_02)
ReturnGoalies = $8362E		;no IDA label. used at $884A4 (checks95_03)
SetPersonel = $836CC		;IDA: sub_836CC. used at $885AA, $88842, $88852 (collide95_02)
forcepldata = $83880		;no IDA label. used at $88848, $88858 (collide95_02)
ResetBench = $83D5E		;IDA: sub_83D5E. used at $88838 (collide95_02)
resetplstuff = $83DC2		;no IDA label. used at $8885E (collide95_02)
GetShifter = $876FC		;IDA: sub_876FC. used at $8827C (data95_01)
LeadSong = $88F70		;no IDA label. used at $88A52 (penalty95)
Stop4Pen = $8901C		;IDA: sub_8901C. used at $88452 (penalty95)
linelist = $8A02C		;IDA: unk_8A02C. used at $88EE6, $88EF8 (data95_02)
SetLCmode = $8A056		;IDA: loc_8A056. used at $885D0 (data95_02)
SetLCmode2 = $8A094		;IDA: sub_8A094. used at $88684, $886A6 (input95_02)
lcfound = $8A2CA		;IDA: loc_8A2CA. used at $886A2 (input95_02)
CompLine = $8A3FE		;no IDA label. used at $885A4 (input95_02)
dirtab = $8B9D6			;IDA: unk_8B9D6. used at $88D10 (checks95_06)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $8897E, $88BA8 (checks95_06)
checkwindow = $8C900		;IDA: sub_8C900. used at $88828 (checks95_06)
SetGoaliesCtl = $8CA38		;no IDA label. used at $8886E (checks95_06)
PeriodOver = $8CB5A		;no IDA label. used at $88428, $88432 (checks95_06)
clockcont_0 = $8CBC2		;IDA: loc_8CBC2. used at $88448 (checks95_06)
FaceOffMap = $149E32		;IDA: unk_149E32. used at $8899E, $88E7E (graphics95_01)
FaceOffSprites = $14A490	;IDA: unk_14A490. used at $889AE, $88D76 (graphics95_01)
RefTiles = $14EB04		;IDA: unk_14EB04. used at $88C56 (graphics95_01)
PlayoffSprite = $1842DA		;IDA: unk_1842DA. used at $881B6 (graphics95_01)

; Main segment code
	include	checks95_04.asm
