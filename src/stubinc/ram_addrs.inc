; RAM map. Add each new RAM name here as you transcribe code segments that use it.
; Do not copy 94 IDA names. Use the 94 name only when the address and the using routine match.
; The final consolidation pass will organize these into src/ram95.asm.
M68K_RAM equ $FFFF0000
VSCRLPM equ $FFFFAC00	;94 $FFFFB000. Hscroll table vram address (VDP reg $0D); first long Begin clears
VSPRITES equ $FFFFAC02	;94 $FFFFB002. Sprite table vram address (VDP reg $05)
VmMap1 equ $FFFFAC04	;94 $FFFFB004. Plane A vram address, then the map size shift (xyVmMap reads printm(VmMap1))
Map1col1 equ $FFFFAC06	;94 $FFFFB006
VmMap2 equ $FFFFAC08	;94 $FFFFB008. Plane B vram address
VmMap3 equ $FFFFAC0C	;94 $FFFFB00C. Window vram address
smallfontchars equ $FFFFAC16	;94 $FFFFB012. First vram char of the small font (AddSmallFont)
smallfontptr equ $FFFFAC1E	;95 only. Address of the small font map AddSmallFont loads
framercset equ $FFFFAC30	;94 $FFFFB01E. First vram char of the framer tiles (AddFramer)
framermapptr equ $FFFFAC3C	;95 only. Address of the framer map Framer reads (AddFramer, AddFramer2)
OptPlayMode equ $FFFFCC4C	;94 $FFFFD048. Start of the menu options
OptLine equ $FFFFCC5C	;94 $FFFFD058
music_global_tick_counter equ $FFFFCC72	;94 $FFFFD06E. Begin stores the VDP PAL bit here
TmpOptLine2 equ $FFFFCC76	;94 $FFFFD072
TempOptPlayMode equ $FFFFCC78	;94 $FFFFD074
PlayingSong equ $FFFFCFD8	;95 only. Song the sound driver is playing ($32-$55), -1 = none
PALflag equ $FFFFDBBC	;94 $FFFFDEF2. Bit 0 set on a PAL (50 Hz) machine
Stack equ $FFFFFDFA	;94 $FFFFFFFE. Begin's stack pointer; the sound driver RAM (SndDrvRAM) is above it
printx equ $FFFFAC40	;94 $FFFFB028
printy equ $FFFFAC42	;94 $FFFFB02A
printa equ $FFFFAC44	;94 $FFFFB02C. Print attribute (palette / priority bits)
printm equ $FFFFAC46	;94 $FFFFB02E. Print map offset from VmMap1
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
Hscroll equ $FFFFB938	;94 $FFFFBD1E
Vscroll equ $FFFFB93A	;94 $FFFFBD20
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
sflags4 equ $FFFFBEFA	;94 $FFFFC2F4. Bit 4: reverse angle replay
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
OOlist equ $FFFFB4A2	;94 $FFFFB88A. Sort objects in draw order (SprSort)
DMAList equ $FFFFB4CE	;94 $FFFFB8B4. Dma transfer list
DMAlistend equ $FFFFB92E	;94 $FFFFBD14
Vpos equ $FFFFB932	;94 $FFFFBD18
Oldrow equ $FFFFB934	;94 $FFFFBD1A. Rink map row of the last updatescroll
Hpos equ $FFFFB936	;94 $FFFFBD1C
pads equ $FFFFB9CE	;94 $FFFFBDB4. 6 pad objects of $1C bytes (95 has no glove object; 94: 7 with glovestruct)
Joy1Struct equ $FFFFB9EA	;94 $FFFFBDD0. pads+$1C
Joy3Struct equ $FFFFBA22	;94 $FFFFBE24. pads+$54 (94: pads+$70)
Joy4Struct equ $FFFFBA3E	;94 $FFFFBE40. pads+$70 (94: pads+$8C)
padcont equ $FFFFBA7A	;94 $FFFFBE7A. Label code of each pad object
sso equ $FFFFBA86	;94 $FFFFBE88. Off screen arrow objects, $14 bytes each
disflags equ $FFFFBB7E	;94 $FFFFBF78
Satt equ $FFFFBC1E	;94 $FFFFC018. Sprite attribute table
Sattsize equ $FFFFBEEE	;94 $FFFFC2E8
BA_PS_flags equ $FFFFBEF8	;94 $FFFFC2F2
cont3team equ $FFFFBF50	;94 $FFFFC32C
cont4team equ $FFFFBF52	;94 $FFFFC32E
puckvx equ $FFFFB38A	;94 $FFFFB772
puckvy equ $FFFFB38C	;94 $FFFFB774
pucky equ $FFFFB376	;94 $FFFFB75E
palfadenew equ $FFFFB942	;94 $FFFFBD28
Ylist equ $FFFFB462	;94 $FFFFB84A
OOlistpos equ $FFFFB482	;94 $FFFFB86A
sflags5 equ $FFFFBEFC	;94 $FFFFC2F6
cont1team equ $FFFFBF4C	;94 $FFFFC328
cont2team equ $FFFFBF4E	;94 $FFFFC32A
VisTeam equ $FFFFBF56	;94 $FFFFC332
goaliemode1 equ $FFFFCC5E	;94 $FFFFD05A
goaliemode2 equ $FFFFCC60	;94 $FFFFD05C
BA_Sktr_SCnum equ $FFFFD00A	;94 $FFFFD406
homehotcoldsave equ $FFFFD39C	;94 $FFFFD6D2. clearTeamStats keeps the first $1A0 bytes of the home hot / cold table (HmShots+$1A4) here
awayhotcoldsave equ $FFFFD53C	;94 $FFFFD872. The same for AwShots+$1A4
SndDrvRAM equ $FFFFFDFC	;95 only. Sound driver (sounddrv95) RAM base: word $1234 = driver ready, 0 = busy (SndUpdate does nothing)
SndSeqPtr equ $FFFFFDFE	;95 only. 8 song slots: song data (-1 = free)
SndSeqPos equ $FFFFFE1E	;95 only. 8 longs: offset of the next event in the song
SndSeqId equ $FFFFFE3E	;95 only. 8 words: the id SndStartSeq gave the slot (SndStopSeq finds it)
SndSeqWait equ $FFFFFE4E	;95 only. 8 words: ticks to the next event
SndSeqTempo equ $FFFFFE5E	;95 only. 8 words: tempo
SndSeqFrac equ $FFFFFE6E	;95 only. 8 words: tick fraction
SndSeqState equ $FFFFFE7E	;95 only. 8 longs: tick carry (word), running status (byte 2)
SndNotes equ $FFFFFE9E	;95 only. 32 note timers (long: count word, then the note), -1 = free
SndNoteCount equ $FFFFFF1E	;95 only. Notes in SndNotes
SndSeqIndex equ $FFFFFF20	;95 only. Slot SndUpdate is working on
SndStreamBase equ $FFFFFF22	;95 only. Sample being streamed to the Z80 (SndStreamZ80)
SndStreamPtr equ $FFFFFF26	;95 only. Next 256 bytes to stream, 0 = done
SndStreamLoop equ $FFFFFF2A	;95 only. Loop offset of the sample, -1 = none
SndStopSlot equ $FFFFFF2C	;95 only. Slot SndStopSeq frees
SndSeqArg1 equ $FFFFFF2E	;95 only. SndStartSeq d1 (d2-d4 follow at SndDrvRAM+$134-$138)
SndBanks equ $FFFFFF36	;95 only. 4 sound banks (SndSetBank), -1 = none
asv equ $FFFFAC5C	;94 $FFFFB044. Crowd noise volume (updatesound)
crowdlevel equ $FFFFB4B4	;94 $FFFFB89C
MaxCwdExciteLvl equ $FFFFB4BC	;94 $FFFFB8A4
NumCwdExciteLvl equ $FFFFB4BE	;94 $FFFFB8A6
SumCwdExciteLvl equ $FFFFB4C0	;94 $FFFFB8A8
ltack equ $FFFFBC1A	;94 $FFFFC014. Last tackle sound
sflags8 equ $FFFFBF04	;94 $FFFFC2FE
music_needs_z80_update equ $FFFFCD84	;94 $FFFFD180. The 94 sound driver RAM below (sound95_01), unused by 95
Z80_command_buffer equ $FFFFCD86	;94 $FFFFD182
per_channel_attenuation_table equ $FFFFCD8B	;94 $FFFFD187
per_channel_frequency_table equ $FFFFCD92	;94 $FFFFD18E
per_channel_patch_table equ $FFFFCDA0	;94 $FFFFD19C
fm_voice_usage_table equ $FFFFCDA8	;94 $FFFFD1A4
fm_channel_structs equ $FFFFCFA8	;94 $FFFFD3A4
fm_channel_struct6 equ $FFFFCFD0	;94 $FFFFD3CC
fm_track_slots equ $FFFFCFD8	;94 $FFFFD3D4. 95 uses the first word as PlayingSong
periodendtime equ $FFFFAC60	;94 $FFFFB048. 3rd-period song trigger time (CheckPeriodEnd)
callbackPtr equ $FFFFCAF4	;94 $FFFFCF32. DecompressGraphics: remap table, or 0 to dma the chars
dmaram equ $FFFFCC6E	;94 $FFFFD06A. Dma command long, written to the vdp as two words
lj1 equ $FFFFBAEC	;94 $FFFFBEEE. Last buttons read by ReadJoy1
lj2 equ $FFFFBAEE	;94 $FFFFBEF0
lj3 equ $FFFFBAF0	;94 $FFFFBEF2
lj4 equ $FFFFBAF2	;94 $FFFFBEF4
pad4way1 equ $FFFFBAF4	;94 $FFFFBEF6. Pad 1 byte read each vblank (ReadJoyData)
pad4way2 equ $FFFFBAF5	;94 $FFFFBEF7
pad4way3 equ $FFFFBAF6	;94 $FFFFBEF8
pad4way4 equ $FFFFBAF7	;94 $FFFFBEF9
menupadnum equ $FFFFBF26	;95 only. Pad (0-3) ReadMenuJoy reads
ThreeStars equ $FFFFCAF8	;94 $FFFFCF36. 256 byte ring buffer of DecompressBytecode
FourWayPlay equ $FFFFCC4A	;94 $FFFFD046. Four way adaptor in use
shootoutclock equ $FFFFD05C	;94 $FFFFD454
shootoutjiffy equ $FFFFD05E	;94 $FFFFD456
repeatdelayframes equ $FFFFAC5A	;94 $FFFFB042. Key repeat count down (ProcessInputWithRepeat)
puckz equ $FFFFB37A	;94 $FFFFB762
wcradiusx equ $FFFFB93C	;94 $FFFFBD22. Wall collision radius x (checkwallcoll)
wcradiusy equ $FFFFB93E	;94 $FFFFBD24
TempWord1 equ $FFFFBB10	;94 $FFFFBF12. A scratch word
ChkBodyG equ $FFFFBB6A	;94 $FFFFBF64. Goalie body reach (checkpuckcoll)
ChkBodySqG equ $FFFFBB6C	;94 $FFFFBF66. Long: reach squared
NegChkBodyG equ $FFFFBB70	;94 $FFFFBF6A
ltplayer equ $FFFFBB80	;94 $FFFFBF7A
xc1 equ $FFFFBB94	;94 $FFFFBF8E. Scroll lock x (sfslock)
yc1 equ $FFFFBB96	;94 $FFFFBF90. Scroll lock y
collflag equ $FFFFBBA6	;94 $FFFFBFA0. Set by a player collision (checkcx)
lastplayer equ $FFFFBAD8	;94 $FFFFBEDA
passplayer equ $FFFFBADE	;94 $FFFFBEE0
sflags6 equ $FFFFBEFE	;94 $FFFFC2F8
InjCntDown equ $FFFFC016	;94 $FFFFC3EC
FallYPos equ $FFFFD01E	;94 $FFFFD41A. Ypos of the player falling into the boards
PlayerChked equ $FFFFDBA4	;94 $FFFFDEDC. Last player FallDown made fall
PlayerChking equ $FFFFDBA8	;94 $FFFFDEE0. The player who hit him
ChkBodyP equ $FFFFDC6C	;95 only. Skater body reach for the puck (checkpuckcoll)
ChkStickP equ $FFFFDC6E	;95 only. Skater stick reach
NegChkBodyP equ $FFFFDC70	;95 only
NegChkStickP equ $FFFFDC72	;95 only
ChkBodySqP equ $FFFFDC74	;95 only. Body reach squared
ChkStickSqP equ $FFFFDC76	;95 only. Stick reach squared
CreatePoints equ $FFFF7536	;95 only. Create player: unallocated attribute points (IDA word_FF7536)
bigfontptr equ $FFFFAC10	;95 only. Address of the big font map printbig uses
BigFontChars equ $FFFFAC14	;94 $FFFFB010. First vram char of the big font
clockdigitchars equ $FFFFAC26	;95 only. First vram char of the big clock digits (PutClockDigit)
energybarchars equ $FFFFAC28	;94 $FFFFB016
rinkvrcset equ $FFFFAC2A	;94 $FFFFB018. First vram char of the rink tiles
gamesetuptilesetindex equ $FFFFAC2C	;94 $FFFFB01A. Crowd tiles 1st vram char
EASNcset equ $FFFFAC32	;94 $FFFFB020
basetileoffset equ $FFFFAC34	;94 $FFFFB022. Team block chars (setupTeamBlocksMap)
spritechars equ $FFFFAC36	;94 $FFFFB024
ExtraChars equ $FFFFAC38	;94 $FFFFB026
printfontset equ $FFFFAC48	;94 $FFFFB030. Char set index of printsmall (ControlCode_SetFont)
zamx equ $FFFFB4C6	;94 $FFFFB8AC
SRAMbyte equ $FFFFBB46	;95 only. Save RAM byte read by ReadAttributeNibbleD7 / ProcessNibbleSeason (ReadSRAM)
clockram equ $FFFFBB8C	;94 $FFFFBF86. The clock chars for the dma list (showclockdma)
mesarea equ $FFFFBBAA	;94 $FFFFBFA4. Message String: length word, then TextBuffer
TextBuffer equ $FFFFBBAC	;94 $FFFFBFA6
PushWidthBuf equ $FFFFBC0E	;94 $FFFFC008. PushNumberWidth String
PushNumberBuf equ $FFFFBC16	;94 $FFFFC010. End of the PushNumber digits
homegoaliectl equ $FFFFBF1E	;95 only. Home goalie control (AssignPads: nonzero = pad does not take the goalie)
awaygoaliectl equ $FFFFBF20	;95 only. Away goalie control
crowdnoisedelay equ $FFFFBF2A	;94 $FFFFC304
TeamBlockMaps equ $FFFFBF58	;95 only. Map words of the home and visitor team blocks (setupTeamBlocksMap, PutTeamBlock)
teamblocksmapptr equ $FFFFBFC8	;95 only. Address of the team blocks map
teamblockwidth equ $FFFFBFCC	;95 only. Team block width in chars
PerTimeTotal equ $FFFFC026	;94 $FFFFC46C. Period length in seconds (ResetClock)
TempPlOffset equ $FFFFC02A	;94 $FFFFC470. Player for GetTempPlayerName (bit 15: away team)
nibblebuffer equ $FFFFCC24	;94 $FFFFD036. Word weights for WeightedRandomSelect
RNGseed equ $FFFFCC6A	;94 $FFFFD066
attribsum equ $FFFFD398	;95 only. CalcAttribRating: sum of the attribute bytes
attribcount equ $FFFFD39A	;95 only. CalcAttribRating: count of them
namelog equ $FFFFD060	;94 $FFFFD45A. The user name log, 12 bytes per name
picturebuf equ $FFFFD6E8	;94 $FFFFDA1E. UnpackPicture output
picturebits equ $FFFFDB6A	;94 $FFFFDEA0. UnpackPicture: the 3 packed bytes of the row
waitxpad equ $FFFFDB9E	;94 $FFFFDED4. waitx: buttons held
framerchars equ $FFFFDC30	;95 only. Char start of the framer tiles (setupice, before AddFramer2)
jerseynum equ $FFFFDC3D	;95 only. Jersey number byte from GetJerseyNumber
Map2col1 equ $FFFFAC0A	;94 $FFFFB00A
Map3col1 equ $FFFFAC0E	;94 $FFFFB00E
pad4wayword equ $FFFFBAF8	;94 $FFFFBEFA. The pad word the unused Read4WayPad1-4 swap a pad's saved word into (Read4WayPort1)
pad4wayword2 equ $FFFFBAFA	;95 only. The same for Read4WayPort2
pad4waysave1 equ $FFFFBAFC	;94 $FFFFBEFE. Read4WayPad1 saved pad word
pad4waysave2 equ $FFFFBAFE	;94 $FFFFBF00
pad4waysave3 equ $FFFFBB00	;94 $FFFFBF02
pad4waysave4 equ $FFFFBB02	;94 $FFFFBF04
menuitem equ $FFFFCADE	;94 $FFFFCF20. Menu state: selected item, then (+2) first item shown
menulist equ $FFFFCAE2	;94 $FFFFCF24. Menu item list (InitMenuState)
menudraw equ $FFFFCAE6	;94 $FFFFCF28. Menu screen draw routine
menuitemoffset equ $FFFFCAEA	;95 only. Long: offset of the shown items in menulist (SetPauseMenuItems)
pausetimeout equ $FFFFDBB4	;95 only. Long: Pausemode frames left without a button while no pad is on a team
menutimer equ $FFFFDC2E	;95 only. Set to $3C by Pausemode
menucursor equ $FFFFDC68	;95 only. Pause menu column (Pausemode sets 2)
smallfont2chars equ $FFFFAC18	;94 $FFFFB014. Second small font chars (the pause font with another remap)
pauselogochars equ $FFFFAC22	;95 only. Pause screen: chars of the info page bitmap
tabchars equ $FFFFAC24	;95 only. Pause screen: chars of the tab bitmap (DrawTab)
faceoffvrcset equ $FFFFAC2E	;94 $FFFFB01C
demoflag equ $FFFFCC68	;94 $FFFFD064
penaltymsgs equ $FFFFDC82	;95 only. Queue of penalty messages, a word each (penalty, player), 0 ends (ShowPenaltyMessages)
OptNOP equ $FFFFCC4E	;94 $FFFFD04A. Options menu: number of players
TmpPuckX equ $FFFFDB80	;94 $FFFFDEB6. Goalie AI: the puck x it plays (assgoaliecpu)
puckvz equ $FFFFB38E	;94 $FFFFB776
threat equ $FFFFBAE2	;94 $FFFFBEE4. Direction of the threat on the puck handler (chk4pass)
puckcross equ $FFFFBAE4	;94 $FFFFBEE6. Puck crossing x and frames at each goal line, for the goalies
iflags equ $FFFFBB86	;94 $FFFFBF80
