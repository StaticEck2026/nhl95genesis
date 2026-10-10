;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	shootout95 segment stub. Retail $09DD3E-$09E5EF.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9DD3E

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $09DD3E-$09E5EF, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $9E038 (main95)
Framer = $7A270			;IDA: sub_7A270. used at $9DEA8, $9DFFE (video95_02)
ReadMenuJoy = $7A6AA		;IDA: sub_7A6AA. used at $9E0BC, $9E1D6 (video95_02)
ProcessInputWithRepeat = $7A762	;IDA: sub_7A762. used at $9E0C2, $9E1DC (video95_02)
vcountwait = $7C6BE		;IDA: sub_7C6BE. used at $9E0B6, $9E1D0 (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $9E07E, $9E18A, $9E19C, $9E1AC, $9E31E, $9E44E, $9E45E, $9E468, $9E47C, $9E48C, $9E49C, $9E4AC and 6 more (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $9E562, $9E5D0 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $9DE98, $9DEEC, $9DF30, $9DF6A, $9DFA4, $9DFEA, $9E29A, $9E3EC, $9E42A (video95_03)
print = $7C822			;IDA: sub_7C822. used at $9DEDA, $9DF2A, $9DF4A, $9DF64, $9DF84, $9DF9E, $9DFC4, $9E2F8 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $9E094, $9E43E (video95_03)
ReadAttributeNibble = $7CB4E	;IDA: sub_7CB4E. used at $9E134 (video95_03)
getname = $7CC90		;IDA: sub_7CC90. used at $9E550 (video95_03)
FormatPlayerNameWithAttrib = $7CD38	;IDA: sub_7CD38. used at $9DED0, $9DF24 (video95_03)
FormatPlayerNameShort = $7CE16	;no IDA label. used at $9E5A4 (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $9DF5E, $9DF98, $9DFBE (video95_03)
PutTeamBlock = $7D268		;IDA: sub_7D268. used at $9E424 (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $9E3FC (video95_03)
printbigz1 = $7D8F6		;IDA: sub_7D8F6. used at $9E004 (video95_03)
printbig1 = $7D908		;IDA: sub_7D908. used at $9DEB2, $9E04C (video95_03)
assinsert = $81570		;IDA: sub_81570. used at $9DE5E (checks95_02)
GetPlayerCount = $838F2		;IDA: sub_838F2. used at $9E13C (collide95_02)
setplayer = $83960		;IDA: sub_83960. used at $9DE32 (collide95_02)
ExitAttributeScreen2 = $8546E	;IDA: loc_8546E. used at $9E10A (data95_01)
getNameandAttrib = $8547A	;no IDA label. used at $9E36E (data95_01)
PAttribOverall = $85834		;no IDA label. used at $9E2A6, $9E2D8 (data95_01)
GAttribOverall = $85996		;no IDA label. used at $9E2B6, $9E2E8 (data95_01)
prefmes = $89898		;IDA: sub_89898. used at $9DE92 (penalty95)
DrawTeamScreen6 = $8B32A	;no IDA label. used at $9E070 (checks95_05)
LockScroll = $8C8EC		;IDA: sub_8C8EC. used at $9DDF8 (checks95_06)
ExitToOpening = $8CD02		;IDA: loc_8CD02. used at $9DD48 (checks95_06)
LineEditorBg = $95998		;no IDA label. used at $9E09A, $9E1EA, $9E290 (stats95_01)
PlayerSelectBg = $959E4		;no IDA label. used at $9E17E (stats95_01)
StartShootoutPath = $9DB0A	;no IDA label. used at $9DD52 (title95_01)
PlayerSelectMap1 = $16FA70	;no IDA label. used at $9E066 (graphics95_01)

; Main segment code
	include	shootout95.asm
