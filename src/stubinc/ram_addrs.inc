; RAM map. Add each new RAM name here as you transcribe code segments that use it.
; Do not copy 94 IDA names. Use the 94 name only when the address and the using routine match.
; The final consolidation pass will organize these into src/ram95.asm.
M68K_RAM equ $FFFF0000
VSCRLPM equ $FFFFAC00	;94 $FFFFB000. Hscroll table vram address (VDP reg $0D); first long Begin clears
OptPlayMode equ $FFFFCC4C	;94 $FFFFD048. Start of the menu options
OptLine equ $FFFFCC5C	;94 $FFFFD058
music_global_tick_counter equ $FFFFCC72	;94 $FFFFD06E. Begin stores the VDP PAL bit here
TmpOptLine2 equ $FFFFCC76	;94 $FFFFD072
TempOptPlayMode equ $FFFFCC78	;94 $FFFFD074
PlayingSong equ $FFFFCFD8	;95 only. Song the sound driver is playing ($32-$55), -1 = none
PALflag equ $FFFFDBBC	;94 $FFFFDEF2. Bit 0 set on a PAL (50 Hz) machine
Stack equ $FFFFFDFA	;94 $FFFFFFFE. Begin's stack pointer; the sound driver uses $FFFFFDFC-$FFFFFDFF above it
vbint equ $FFFFAC52	;94 $FFFFB03A. Vertical blank handler address (VBjsr jumps through it)
vcount equ $FFFFAC56	;94 $FFFFB03E. Vertical blank counter
GameFlags equ $FFFFBF08	;95 only. Flag byte: bit 7 holds MakeSRAMChecksum during a batch of save RAM writes; bits 0, 1 pick the second shot / pass tables
SeasonStartDay equ $FFFFD1A4	;95 only. Schedule day the season starts on (sub_8E26A picks it at random)
SeasonLength equ $FFFFD1A5	;95 only. Days in the season ($C0 = the whole schedule)
SeasonDay equ $FFFFD1A6	;95 only. Days played; the byte after it is the season flags
ValidSRAM equ $FFFFDC3A	;94 $FFFFD458. 0 = save RAM checksum good, -1 = bad
SRAMChecksum equ $FFFFDC5E	;95 only. The complement and sum bytes MakeSRAMChecksum writes to save RAM bytes $7FFE-$7FFF
recbpr equ $FFFFAC4E	;94 $FFFFB036. Replay record pointer
oldvcount equ $FFFFAC58	;94 $FFFFB040
lldisp equ $FFFFAC5E	;94 $FFFFB046. Count down to the once a second updates
SortCords equ $FFFFAC62	;94 $FFFFB04A. 16 sort objects of SCstruct bytes
puckx equ $FFFFB362	;94 $FFFFB74A. SortCords+(puckscnum*SCstruct)
puckc equ $FFFFB3C2	;94 $FFFFB7AA. Puck carrier SCnum, -1 = none
CwdExciteLvl equ $FFFFB4BA	;94 $FFFFB8A2
palcount equ $FFFFB940	;94 $FFFFBD26
PadControlBits equ $FFFFBA76	;94 $FFFFBE78 (a word; PadControlBits34 $FFFFBE86). 95 keeps the 4 pads' nibbles in one long
bholdtimer equ $FFFFBB04	;94 $FFFFBF06. B button hold timers of pads 1 / 2
bholdtimer34 equ $FFFFBB06	;94 $FFFFBF08. Pads 3 / 4
fox equ $FFFFBB9A	;94 $FFFFBF94. Face off x
foy equ $FFFFBB9C	;94 $FFFFBF96. Face off y
lastsfx equ $FFFFBC1C	;94 $FFFFC016
gmode equ $FFFFBEF0	;94 $FFFFC2EA
sflags equ $FFFFBEF2	;94 $FFFFC2EC
sflags2 equ $FFFFBEF4	;94 $FFFFC2EE
sflags3 equ $FFFFBEF6	;94 $FFFFC2F0
gmode2 equ $FFFFBF00	;94 $FFFFC2FA. Bit 0 shootout (main menu Shootout)
sflags7 equ $FFFFBF02	;94 $FFFFC2FC. Bit 1 overtime
sflags9 equ $FFFFBF06	;95 only. Bit 7 Practice Mode (main menu item 2)
sflags10 equ $FFFFBF0A	;95 only. Main menu: bit 2 Trade Players, bit 4 Create Player, bit 5 Sign Free Agents, bit 6 Release Players
sflags11 equ $FFFFBF0C	;95 only. Bit 6 Regular Game (main menu item 1; kept over the Opening2 RAM clear), bit 5 set around IntermissionMenu
sflags12 equ $FFFFBF0E	;95 only. Bit 7 Opening2 skips the sound restart (set by Opening), bit 0 set while IntermissionMenu runs Pausemode
lastpuckc equ $FFFFBF1C	;95 only. The puck carrier CheckNewCarrier saw last
CurCrowdMeter equ $FFFFBF34	;94 $FFFFC30E. StartPer clears it as 94 does
joypuckcarrier equ $FFFFBF3C	;94 $FFFFC318
c1playernum equ $FFFFBF44	;94 $FFFFC320
c2playernum equ $FFFFBF46	;94 $FFFFC322
c3playernum equ $FFFFBF48	;94 $FFFFC324
c4playernum equ $FFFFBF4A	;94 $FFFFC326
HomeTeam equ $FFFFBF54	;94 $FFFFC330
gsp equ $FFFFC020	;94 $FFFFC466. Period: 0-2, 3 overtime, 4 game over
gameclock equ $FFFFC022	;94 $FFFFC468
ChkCnt equ $FFFFC028	;94 $FFFFC46E
ScoreSumbytes equ $FFFFC02C	;94 $FFFFC472
PenSumLength equ $FFFFC196	;94 $FFFFC5DC
HmShots equ $FFFFC288	;94 $FFFFC6CE. Home team struct
AwShots equ $FFFFC5EE	;94 $FFFFCA32. Away team struct (tmsize $366, 94: $364)
gamelevel equ $FFFFCAAA	;94 $FFFFCEEC
OptPerlen equ $FFFFCC54	;94 $FFFFD050
OptPen equ $FFFFCC5A	;94 $FFFFD056
BA_Goalie_SCnum equ $FFFFD00C	;94 $FFFFD408
BA_Skater_Offset equ $FFFFD00E	;94 $FFFFD40A
holdreset equ $FFFFD016	;94 $FFFFD412
FallXPos equ $FFFFD020	;94 $FFFFD41C. Xpos of the player falling into the boards (FallDown)
SongNum equ $FFFFD392	;94 $FFFFD6C8
HmTeam equ $FFFFD394	;94 $FFFFD6CA
SongIndex equ $FFFFD396	;94 $FFFFD6CC
songdelay equ $FFFFDB96	;94 $FFFFDECC
delayedsong equ $FFFFDB98	;94 $FFFFDECE
HmGoalieOpt equ $FFFFDC62	;95 only. Home team word goaliesave compares with 1 (IDA $808D4); Opening2 sets it to 1
AwGoalieOpt equ $FFFFDC64	;95 only. Away team word, as HmGoalieOpt
ShotTimer equ $FFFFDC7A	;95 only. Set to $1E by doshot, counted down by DoGameFrame
