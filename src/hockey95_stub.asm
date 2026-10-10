	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	hockey95 segment stub. Retail $009AC8-$00A203.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9AC8

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $009AC8-$00A203, read from lst/nhl95.bin: jsr / jmp (x).l and movea.l / move.l #x carry the address;
; bsr.w is the displacement word address + displacement. 94 names where the 95 body is the 94 routine.
KillCrowd = $67988		;IDA: sub_67988. jsr (x).l at $9AC8 (sound95_01)
newTitleScreen = $A12AA		;IDA: sub_A12AA. jsr (x).l at $9ACE (title95_02)
play_new_song = $67938		;IDA: sub_67938. Stop the song in progress. jsr (x).l at $9AE4 (sound95_01)
SoundCmd = $676D8		;IDA: sub_676D8. jsr (x).l at $9AEE (sound95_01)
song = $678C2			;IDA: sub_678C2. jsr (x).l at $9B2C (sound95_01)
Z80Program = $BD86		;movea.l #x at $9AFC (sounddrv95)
SoundBanks = $D8EC		;movea.l #x at $9B0E (sounddrv95)
GameSetUp = $85A9E		;IDA: sub_85A9E. The main menu. jsr (x).l at $9B5A (data95_01)
PracticeGoalies = $8CADE	;IDA: sub_8CADE. 95 only. jsr (x).l at $9B6A (checks95_06)
SeasonMain = $8E06E		;IDA: sub_8E06E. 95 only. jsr (x).l at $9B7C (season95)
TradePlayers = $96C14		;IDA: loc_96C14. 95 only. jmp (x).l at $9B8C (trade95)
CreatePlayer = $97D9A		;IDA: loc_97D9A. 95 only. jmp (x).l at $9B9C (create95)
SignFreeAgents = $99E8C		;IDA: loc_99E8C. 95 only. jmp (x).l at $9BAC (create95)
ReleasePlayers = $9A5C8		;IDA: loc_9A5C8. 95 only. jmp (x).l at $9BBC (create95)
SetContTeams = $8CD3C		;IDA: sub_8CD3C. 95 only: set cont1team-cont4team. jsr (x).l at $9BC2 (checks95_06)
UserNameEntry = $9B6F4		;IDA: sub_9B6F4. jsr (x).l at $9BD8 (cards95_01)
PlayoffScreen = $87BA2		;IDA: sub_87BA2. jsr (x).l at $9BDE (setup95_02)
vb2 = $7A3F6			;IDA: unk_7A3F6. move.l #x at $9BE4 (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. jsr (x).l at $9BF2 (video95_02)
ClearShotData = $883B8		;IDA: sub_883B8. jsr (x).l at $9C2E (checks95_04)
clearTeamStats = $AE48		;IDA: sub_AE48. jsr (x).l at $9C34 (setup95_01)
ResetTeamEnergy = $7DBA2	;IDA: sub_7DBA2. 95 only: a2 team, energy $1000, -3 slots to -2. jsr (x).l at $9C56 (video95_03)
Create_HotCold_Table = $83E88	;IDA: sub_83E88. jsr (x).l at $9C72 (collide95_02)
ScoutingReport = $9F590		;IDA: loc_9F590. jsr (x).l at $9C9A (scout95)
restoreteams = $83D3E		;IDA: sub_83D3E. jsr (x).l at $9CB0 (collide95_02)
setupice = $7DD06		;IDA: sub_7DD06. jsr (x).l at $9D12 (video95_03)
ResetClock = $7D4A0		;IDA: sub_7D4A0. jsr (x).l at $9D18 (video95_03)
SoundOff = $679B2		;IDA: sub_679B2. jsr (x).l at $9D2A (sound95_01)
UpdateScores = $8827C		;IDA: sub_8827C. jsr (x).l at $9D8C (checks95_04)
AddPOStats = $87714		;IDA: sub_87714. jsr (x).l at $9D9C (data95_01)
GameOver = $8CCE6		;IDA: loc_8CCE6. jmp (x).l at $9DBC (checks95_06)
assreplace = $8157A		;IDA: sub_8157A. jsr (x).l at $9E30 (checks95_02)
ChooseSong = $679C4		;IDA: sub_679C4. jsr (x).l at $9ECC (sound95_01)
demoread = $8DF5A		;IDA: sub_8DF5A. jsr (x).l at $9EF4 (season95)
Pausemode = $7E36C		;IDA: sub_7E36C. jsr (x).l at $9F02 (hockey95_02)
CheckNewCarrier = $7D8B2	;IDA: sub_7D8B2. 95 only: clear GameFlags bits 0-1 when puckc changes. jsr (x).l at $9F3E (video95_03)
PenaltyManager = $891FE		;IDA: sub_891FE. jsr (x).l at $9F44 (penalty95)
updatecrowdf = $A0B3E		;IDA: sub_A0B3E. jsr (x).l at $9F4A (stats95_02)
updatesound = $67710		;IDA: sub_67710. jsr (x).l at $9F50 (sound95_01)
clockcont = $8CD08		;IDA: sub_8CD08. jsr (x).l at $9F56 (checks95_06)
ChkGoalies = $835C6		;IDA: sub_835C6. jsr (x).l at $9F6A (checks95_03)
UpdateCwdExcite = $676E8	;IDA: sub_676E8. jsr (x).l at $9F70 (sound95_01)
CheckPeriodEnd = $6776A		;IDA: sub_6776A. jsr (x).l at $9F76 (sound95_01)
UpdateLineChange = $7DB40	;IDA: sub_7DB40. jsr (x).l at $9F7C (video95_03)
CheckInjury = $9F282		;IDA: sub_9F282. jsr (x).l at $9F82 (checks95_07)
updatepwrplay = $9F45E		;IDA: sub_9F45E. jsr (x).l at $9F88 (checks95_07)
checkwindow = $8C900		;IDA: sub_8C900. jsr (x).l at $9F8E (checks95_06)
setSlotBit = $833FE		;IDA: sub_833FE. jsr (x).l at $9FB8 (checks95_03)
SprSort = $A8E6			;IDA: sub_A8E6. jsr (x).l at $9FBE (setup95_01)
updatereplay = $8D55E		;IDA: sub_8D55E. jsr (x).l at $9FC4 (replay95)
setvideo = $A204		;IDA: sub_A204. jmp (x).l at $9FCA (display95_01)
UpdateRecords = $9C01A		;IDA: sub_9C01A. jsr (x).l at $9FE2 (cards95_02)
SetupTeamForIntermission = $8A572	;IDA: sub_8A572. jsr (x).l at $9FF2 (checks95_05)
PlaceBoardFall = $8C1FA		;IDA: sub_8C1FA. jsr (x).l at $A056 (checks95_06)
updateanim = $A536		;IDA: sub_A536. bsr.w at $A13C (display95_01)
loadTeamStruct = $7CAF0		;IDA: sub_7CAF0. jsr (x).l at $A172 (video95_03)
updatevel = $8BB6C		;IDA: sub_8BB6C. 95 only: the velocity update 94 updateplayers does in line. jsr (x).l at $A1A8 (checks95_06)
setpads = $AB2A			;IDA: sub_AB2A. bsr.w at $A1BC (setup95_01)
updatepadinput = $A95C		;IDA: sub_A95C. 95 only: the pad input 94 updateplayers does in line (.tp2). jsr (x).l at $A1EE (setup95_01)
; frames95 SPA tables (frames95.asm defines them in the full build)
SPAboardtop = $20B0
SPAboardright = $2122
SPAboardbot = $219C
SPAboardleft = $220E
SPAinjuryfall = $2454
SPAinjury1 = $2496
SPAinjury2 = $24D8
SPAboardmidl = $26C8
SPAboardmidr = $276A

; Main segment code
	include	hockey95.asm
