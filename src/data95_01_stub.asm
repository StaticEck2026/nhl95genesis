	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	data95_01 segment stub. Retail $084FE6-$087BA1.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$84FE6

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $084FE6-$087BA1, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $86542 (teamdata95)
playoffseats = $5834		;no IDA label. used at $87A02, $87A6C (teamdata95)
WriteSRAM = $98E6		;IDA: sub_98E6. used at $87B7C (sram95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $87B82 (sram95)
ReadSRAM = $9952		;IDA: sub_9952. used at $87B46 (sram95)
setvram = $79936		;IDA: sub_79936. used at $86998 (video95_01)
Vmaddr = $79A22			;IDA: sub_79A22. used at $856CA, $856EA (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $85728, $8575C, $86A16, $86A40, $86F82, $8715A, $872C8 (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $86A50 (video95_01)
SetScroll2 = $79CCA		;IDA: sub_79CCA. used at $856A4 (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $8546E, $8568E (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $85780, $85798, $8580E, $869C8, $869E0 (video95_02)
VBlank_SetOptions = $7A418	;IDA: unk_7A418. used at $86946 (video95_02)
orjoy = $7A448			;IDA: sub_7A448. used at $8699E (video95_02)
nodiag = $7A488			;IDA: sub_7A488. used at $85120 (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $85DC6 (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $85DFA (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $85E36 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $85E6A (video95_02)
ReadMenuJoy = $7A6AA		;IDA: sub_7A6AA. used at $85104 (video95_02)
ProcessInputWithRepeat = $7A762	;IDA: sub_7A762. used at $8510A, $85DCC, $85E00, $85E3C, $85E70 (video95_02)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $8749A, $878D0, $879F4 (video95_03)
vcountwait = $7C6BE		;IDA: sub_7C6BE. used at $850FE (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $85086, $851E0, $85264, $85278, $85284, $852C8, $8532A, $85348, $8567A (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $851FE, $852C0, $8541C, $85492, $85530, $85632, $85674 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $8502A, $85066, $850E6, $85638, $85700, $8572E, $857A6, $8636C, $8638A, $86676, $866BA, $869F2, $86A1C, $86EFE, $86F2C, $87068, $87088, $870B2, $870D2, $871AE, $871FE, $87396 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $8668E, $866D2 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $852EA, $857BA, $8637C, $8639A, $871E2, $873C0, $873D4 (video95_03)
PrintSmallListItem = $7CB38	;IDA: sub_7CB38. used at $85504, $85514, $85546, $8564E (video95_03)
SkipStrings = $7CB42		;IDA: sub_7CB42. used at $851F8 (video95_03)
ReadAttributeNibble = $7CB4E	;IDA: sub_7CB4E. used at $8522E, $8524A (video95_03)
GetDefenseStart = $7CBC8	;no IDA label. used at $85216, $8523A (video95_03)
getname = $7CC90		;IDA: sub_7CC90. used at $8548C (video95_03)
d0toascii = $7CEF6		;IDA: sub_7CEF6. used at $87330 (video95_03)
CalcAttrib = $7CF16		;IDA: sub_7CF16. used at $854A6 (video95_03)
PushTime = $7D0BC		;IDA: sub_7D0BC. used at $8552A (video95_03)
PushNumber = $7D120		;IDA: sub_7D120. used at $8566E (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $8562C (video95_03)
appstring = $7D214		;IDA: sub_7D214. used at $8733E (video95_03)
ScaleAttrib = $7D258		;IDA: sub_7D258. used at $85624 (video95_03)
PutTeamBlock = $7D268		;IDA: sub_7D268. used at $85080 (video95_03)
setupTeamBlocksMap = $7D2AE	;IDA: sub_7D2AE. used at $85000 (video95_03)
GetTeamLogo = $7D3EA		;no IDA label. used at $85024 (video95_03)
TeamLogoBitmaps = $7D3F8	;IDA: unk_7D3F8. used at $87102 (video95_03)
DrawTeamLogo = $7D468		;no IDA label. used at $85042, $85052 (video95_03)
UnpackPicture = $7DA78		;IDA: sub_7DA78. used at $8729A (video95_03)
SeasonPlayerOut = $7DBD8	;IDA: sub_7DBD8. used at $85616 (video95_03)
DrawMenuScreen = $7E536		;IDA: loc_7E536. used at $85474 (menu95)
GetPlayerCount = $838F2		;IDA: sub_838F2. used at $85222 (collide95_02)
RandomSetupTeams = $8DFF8	;IDA: sub_8DFF8. used at $85B2E (season95)
ReadSeasonHeader = $8E228	;IDA: sub_8E228. used at $85AC6, $860EE (season95)
BuildSeasonTeamList = $8E2AC	;IDA: sub_8E2AC. used at $85AF4 (season95)
NextSeasonTeam = $8E556		;IDA: sub_8E556. used at $8740C (season95)
PrevSeasonTeam = $8E5A2		;IDA: sub_8E5A2. used at $87416 (season95)
GetRosterName = $9649E		;IDA: sub_9649E. used at $8730E (trade95)
ReadCreatedPlayers = $988E4	;IDA: sub_988E4. used at $86092 (create95)
CheckCreateSlots = $98C64	;IDA: sub_98C64. used at $86088 (create95)
ShootoutInit = $9DA50		;IDA: sub_9DA50. used at $85D74 (title95_01)
GetInjuryGames = $9F232		;IDA: sub_9F232. used at $854FA (checks95_07)
GetPlayerPicture = $A0A30	;IDA: sub_A0A30. used at $8726E (setup95_03)
NoPlayerPicture = $A1A5A	;IDA: unk_A1A5A. used at $8727A, $87288 (title95_02)
RosterFont = $1383C6		;IDA: unk_1383C6. used at $85766, $8577A, $85792 (graphics95_01)
RosterBitmap = $14000A		;no IDA label. used at $8570C, $85742 (graphics95_01)
Teamblocksmap = $142906	;IDA: unk_142906. used at $84FF6 (graphics95_01)
SetupFont = $151760		;IDA: unk_151760. used at $8665E, $866A2, $869C2, $869DA (graphics95_01)
SetupBgMap2 = $1524CE		;no IDA label. used at $86A28 (graphics95_01)
SetupBgMap1 = $1588FC		;no IDA label. used at $869FE (graphics95_01)
TeamBitmaps = $15974A		;IDA: unk_15974A. used at $86A4A, $86F6A (graphics95_01)
TeamLogoPalettes = $1A169A	;IDA: unk_1A169A. used at $86F12, $86F40, $87114 (graphics95_01)

; Main segment code
	include	data95_01.asm
