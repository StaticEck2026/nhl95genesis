	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	menu95 segment stub. Retail $07E4D6-$07F97D.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$7E4D6

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $07E4D6-$07F97D, read from lst/nhl95.bin.
Opening2 = $9ADA		;IDA: loc_9ADA. used at $7F970 (hockey95)
SprSort = $A8E6			;IDA: sub_A8E6. used at $7ED28 (setup95_01)
setplayercolors = $AF1A		;IDA: sub_AF1A. used at $7EC1E, $7ED08 (setup95_01)
DoFill = $79902			;IDA: sub_79902. used at $7E892, $7EC42 (video95_01)
setVram_0 = $7994C		;IDA: sub_7994C. used at $7EC2A (video95_01)
Vmaddr = $79A22			;IDA: sub_79A22. used at $7E850, $7E870 (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $7E8C0, $7E8F8, $7E92E, $7E9A8, $7F0B4, $7F334, $7F360 (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $7E9F4, $7EA0C, $7EC62, $7EC72, $7EC9C, $7ECAC, $7ECDA, $7ECFC (video95_01)
SetScroll2 = $79CCA		;IDA: sub_79CCA. used at $7E82A (video95_01)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $7E96C, $7E9C4, $7E9DC (video95_02)
AddFramer2 = $7A310		;IDA: sub_7A310. used at $7EC4C (video95_02)
VBlank = $7A332			;IDA: unk_7A332. used at $7EBD4 (video95_02)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $7E540, $7EE34, $7EE88, $7EEA0, $7EEEC, $7EF22, $7F020 (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $7EE2E, $7EEB8, $7EEC6, $7EFE6, $7EFF4 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $7E898, $7E8C8, $7E8FE, $7E936, $7EAB0, $7EACC, $7EAE2, $7F08E, $7F132, $7F152, $7F1A6, $7F1E0, $7F254, $7F272, $7F296, $7F2B4, $7F2D6, $7F2F4 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $7EB9E, $7EBAC, $7F10E, $7F1BC, $7F1F6 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $7EF08, $7F036 (video95_03)
showclock = $7C90A		;IDA: sub_7C90A. used at $7EAA0 (video95_03)
FormatPlayerNameWithAttrib = $7CD38	;IDA: sub_7CD38. used at $7F1DA (video95_03)
d0toascii = $7CEF6		;IDA: sub_7CEF6. used at $7EB90 (video95_03)
PushTime = $7D0BC		;IDA: sub_7D0BC. used at $7EBA6 (video95_03)
PutTeamBlock = $7D268		;IDA: sub_7D268. used at $7EA32, $7EA40 (video95_03)
setupTeamBlocksMap = $7D2AE	;IDA: sub_7D2AE. used at $7EA1C (video95_03)
SetRinkPalette = $7D6F0		;IDA: sub_7D6F0. used at $7EC24, $7ED0E (video95_03)
PrintScores1 = $7D776		;IDA: sub_7D776. used at $7ED3E (video95_03)
AddFonts = $7D858		;IDA: sub_7D858. used at $7EC52 (video95_03)
LoadHomeTeamGfx = $7DEA0	;IDA: sub_7DEA0. used at $7ED02 (fourway95)
setupEASNmap = $7DF6A		;IDA: sub_7DF6A. used at $7EC78 (fourway95)
ManualGoalieMenu = $7F97E	;no IDA label. used at $7F682, $7F72C, $7F7C0, $7F828, $7F8BC, $7F924. Pause menu MANUAL GOALIE (checks95_01)
SelectGoalieMenu = $7FA66	;no IDA label. used at $7F66A, $7F714, $7F7A8, $7F8A4. Pause menu CHANGE GOALIE (checks95_01)
TimeoutMenu = $7FB94		;no IDA label. used at $7F698, $7F742. Pause menu TIMEOUT (checks95_01)
PauseScores = $7FC04		;no IDA label. used at $7EAA6. 95: both team scores in big digits on the pause screen (checks95_01)
PrintPadMenuItem = $7FCBA	;IDA: sub_7FCBA. used at $7EF54. 95: the pad's menu item variant (checks95_01)
TeamRosterScreen = $84FE8	;no IDA label. used at $7F39C, $7F41A, $7F46C. Pause menu TEAM ROSTER (data95_01)
FaceoffScreen = $88E42		;IDA: sub_88E42. used at $7ECB2. 95: the face off screen
PenaltyNames = $89C2E		;IDA: unk_89C2E. used at $7F17E. Penalty name Strings by penalty number (ShowPenaltyMessages)
ReplayMode = $8D668		;no IDA label. used at $7F63E, $7F6E8, $7F77C, $7F810, $7F878, $7F90C. Pause menu INSTANT REPLAY
GameStatisticsScreen = $920DE	;no IDA label. used at $7F4BC, $7F530, $7F5AC. Pause menu GAME STATS
PlayerStatsScreen = $925B0	;no IDA label. used at $7F4E8, $7F55C, $7F5D8. Pause menu PLAYER STATS
SeasonPlayersScreen = $934CC	;no IDA label. used at $7F5EE. Pause menu SEASON PLAYERS
SeasonTeamsScreen = $93C14	;no IDA label. used at $7F604. Pause menu SEASON TEAMS
PeriodStatsScreen = $94ED2	;no IDA label. used at $7F4D2, $7F546, $7F5C2. Pause menu PERIOD STATS
LineEditor = $95220		;no IDA label. used at $7F654, $7F6FE, $7F792, $7F88E. Pause menu EDIT LINES
GetRosterName = $9649E		;IDA: sub_9649E. used at $7EB6E
GetJerseyNumber = $965A8	;IDA: sub_965A8. used at $7EB7A
PlayoffStatsScreen = $9B8D6	;no IDA label. used at $7F572. Pause menu PLAYOFF STATS
RecordHoldersScreen = $9B90E	;no IDA label. used at $7F3DE, $7F430, $7F482. Pause menu RECORD HOLDERS
ShootoutSetup = $9E058		;no IDA label. used at $7F93A. Pause menu SHOOTOUT SETUP
ScoringSummaryScreen = $A0D1A	;no IDA label. used at $7F3B2. Pause menu SCORING SUMMARY
PenaltySummaryScreen = $A1022	;no IDA label. used at $7F3C8. Pause menu PENALTY SUMMARY
Rinktilelist = $C4A7C		;IDA: unk_C4A7C. used at $7ECF6 (graphics95_01)
PauseBgBitmap = $13AC70		;IDA: unk_13AC70. used at $7E8A4, $7E8D4, $7E90A, $7F30E (graphics95_01)
PeriodNumberBitmap = $13E09E	;IDA dc.b. used at $7E966, $7E980 (graphics95_01)
TabBitmap = $13E21C		;IDA: unk_13E21C. used at $7EA06, $7F33A (graphics95_01)
PauseFontMap = $13EEAA		;IDA dc.b. used at $7E9B4, $7E9D6 (graphics95_01)
ClockDigitsBitmap = $13FC18	;IDA: unk_13FC18. used at $7E9EE (graphics95_01)
PauseTeamBlocksMap = $146D24	;IDA dc.b. used at $7EA12 (graphics95_01)
FaceoffTiles = $149E32		;#x+8 at $7EC96 (graphics95_01)
FaceoffTiles2 = $14A490		;#x+8 at $7ECA6 (graphics95_01)
EnergyBarMap = $14C4C8		;#x+8 at $7EC5C (graphics95_01)
RefTiles = $14EB04		;#x+8 at $7ECD4 (graphics95_01)
RefTilesHor = $14FBA2		;#x+8 at $7ECCA (graphics95_01)
CrowdFrameList = $18B628	;#x+8 at $7EC6C (graphics95_01)

; Main segment code
	include	menu95.asm
