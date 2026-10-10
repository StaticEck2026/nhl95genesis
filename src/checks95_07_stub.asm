;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	checks95_07 segment stub. Retail $09E5F0-$09F58F.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9E5F0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $09E5F0-$09F58F, read from lst/nhl95.bin.
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $9F1A0, $9F296 (sram95)
SprSort = $A8E6			;IDA: sub_A8E6. used at $9EB68 (setup95_01)
setc1player = $AD80		;IDA: loc_AD80. used at $9EBBA (setup95_01)
setc2player = $AD8A		;IDA: loc_AD8A. used at $9EBCC (setup95_01)
sfx = $677AC			;IDA: sub_677AC. used at $9F030 (sound95_01)
song = $678C2			;IDA: sub_678C2. used at $9E6CC (sound95_01)
ChooseSong = $679C4		;IDA: sub_679C4. used at $9E6A8, $9E6C2 (sound95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $9E91C (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $9E8EE (display95_02)
Framer = $7A270			;IDA: sub_7A270. used at $9EE06, $9F2B0 (video95_02)
vtoa = $7C586			;IDA: sub_7C586. used at $9EB3E (video95_03)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $9F0DE, $9F118, $9F272 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $9EDF6, $9EE4A, $9EE76, $9F2A0, $9F2CA, $9F2F8, $9F324, $9F362, $9F376, $9F39E, $9F4CA, $9F52A (video95_03)
print = $7C822			;IDA: sub_7C822. used at $9EE44, $9EE6C, $9EEA2, $9F352, $9F38E, $9F4EC, $9F51A (video95_03)
GetTempPlayerNameAttrib = $7CCD2	;IDA: sub_7CCD2. used at $9F388 (video95_03)
FormatPlayerNameWithAttrib = $7CD38	;IDA: sub_7CD38. used at $9EE3E, $9EE9C (video95_03)
PushTime = $7D0BC		;IDA: sub_7D0BC. used at $9F4E6 (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $9F34C (video95_03)
appendz = $7D20C		;IDA: sub_7D20C. used at $9F4FE (video95_03)
appstring = $7D214		;IDA: sub_7D214. used at $9F512 (video95_03)
AssignPads = $7D540		;no IDA label. used at $9EB70 (video95_03)
printbig1 = $7D908		;IDA: sub_7D908. used at $9EE10 (video95_03)
EASNLogo = $7DF32		;IDA: sub_7DF32. used at $9F536 (fourway95)
RestoreGameScreen = $7EBBE	;IDA: sub_7EBBE. used at $9E94A (menu95)
Setplass = $81540		;IDA: sub_81540. used at $9ED80, $9ED9C (checks95_02)
assinsert = $81570		;IDA: sub_81570. used at $9EA22, $9EAA4 (checks95_02)
assreplace = $8157A		;IDA: sub_8157A. used at $9E724, $9E7A0, $9EBD6, $9EC1A, $9ED76 (checks95_02)
ReturnGoalies = $8362E		;no IDA label. used at $9E6EC (checks95_03)
SetPersonel = $836CC		;IDA: sub_836CC. used at $9E9D8, $9E9E6 (collide95_02)
setplayer = $83960		;IDA: sub_83960. used at $9EA48, $9EAEC, $9EDB6 (collide95_02)
ResetBench = $83D5E		;IDA: sub_83D5E. used at $9E9CE (collide95_02)
resetplstuff = $83DC2		;no IDA label. used at $9E9F0 (collide95_02)
Stop4Pen = $8901C		;IDA: sub_8901C. used at $9E676 (penalty95)
AddPenalty2 = $8916E		;IDA: sub_8916E. used at $9ECE0 (penalty95)
prefmes = $89898		;IDA: sub_89898. used at $9EDF0 (penalty95)
PenaltyNames = $89C2E		;IDA: unk_89C2E. used at $9EE5E (data95_02)
PenShotPenalties = $89FFC	;IDA: unk_89FFC. used at $9EF02 (data95_02)
FindGoalie = $8B974		;IDA: sub_8B974. used at $9EF6C (input95_03)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $9EB58 (checks95_06)
LockScroll = $8C8EC		;IDA: sub_8C8EC. used at $9ECE6 (checks95_06)
checkwindow = $8C900		;IDA: sub_8C900. used at $9E9BE (checks95_06)
StartShootoutPath = $9DB0A	;no IDA label. used at $9E62C (title95_01)
NextShooter = $9DD3E		;no IDA label. used at $9E622 (title95_01)
CountShootoutGoals = $9DD94	;IDA: sub_9DD94. used at $9ED46 (shootout95)
PlayoffRoundScreen = $9DE8A	;IDA: loc_9DE8A. used at $9EDE2 (shootout95)
RefTiles = $14EB04		;IDA: unk_14EB04. used at $9E916 (graphics95_01)

; Main segment code
	include	checks95_07.asm
