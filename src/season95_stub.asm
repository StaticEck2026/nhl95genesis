;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	season95 segment stub. Retail $08DF5A-$0920DD.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$8DF5A

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $08DF5A-$0920DD, read from lst/nhl95.bin.
SeasonSchedule = $8DD8		;IDA: byte_8DD8. used at $8E286, $8E2F2, $8E38C, $8E474, $8F31E (frames95)
SeasonScheduleEnd = $9721	;no IDA label. used at $8F314 (sram95)
WriteSRAM = $98E6		;IDA: sub_98E6. used at $8E258, $8E3D8, $8EFFC, $8F036, $8F05C, $8F082, $8F0AE, $8F15A (sram95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $8E08A, $8E0BA, $8E158, $8E16A, $8E25E, $8E3F0, $8E54A, $8EFB4, $8F002, $8F0B4, $8F0D2 (sram95)
ReadSRAM = $9952		;IDA: sub_9952. used at $8E23A, $8E340, $8EFD4, $8F148, $8F352, $8F4C0 (sram95)
Opening2 = $9ADA		;IDA: loc_9ADA. used at $8E220, $8FC2E, $9051C, $910EC, $9178C (hockey95)
setvram = $79936		;IDA: sub_79936. used at $8F826, $903B2, $90EB2, $911CA, $91988 (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $8F89A, $901D0, $90224, $902CA, $9033E, $90486, $90F6A, $90FA6, $912BC, $91550, $91590, $915D8, $91618, $91656, $916B0, $91A14, $91B8E (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $8F870, $90406, $9045E, $90F1E, $91236, $91246, $91256, $91266, $91276, $919DC, $919EC (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $8F686, $8FE10, $90718, $91744 (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $8F840, $8F858, $903CC, $903E4, $90416, $9042E, $90446, $90ECC, $90EE4, $90EFC, $90F38, $911E4, $91206, $9121E, $91286, $919A2, $919BA (video95_02)
Framer = $7A270			;IDA: sub_7A270. used at $9074A, $90808, $90A36 (video95_02)
VBlank_SetOptions = $7A418	;IDA: unk_7A418. used at $8F7D4, $90360, $90E60, $91178, $91936 (video95_02)
orjoy = $7A448			;IDA: sub_7A448. used at $8F82C, $903B8, $90EB8, $911D0, $9198E (video95_02)
orjoy4way = $7A456		;IDA: loc_7A456. used at $907E2, $908F4 (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $8DF7A, $8F6BC, $8FE64, $90B06, $91112, $917B2 (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $8DF92, $8F6D2, $8FE7A, $90B1C, $91128, $917C8 (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $8DFAE, $8F6F0, $8FE98, $90B3A, $91146, $917E6 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $8DFC6, $8F706, $8FEAE, $90B50, $9115C, $917FC (video95_02)
ProcessInputWithRepeat = $7A762	;IDA: sub_7A762. used at $8F6C2, $8F6D8, $8F6F6, $8F70C, $8FE6A, $8FE80, $8FE9E, $8FEB4, $90B0C, $90B22, $90B40, $90B56, $91118, $9112E, $9114C, $91162, $917B8, $917CE, $917EC, $91802 (video95_02)
randomd0s = $7C62E		;IDA: sub_7C62E. used at $8E722, $8E74E (video95_03)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $8DFFC, $8E020, $8E05E, $8E28E, $8E686, $8E82C, $8E8A2, $8E8E6, $8E938, $8EECA, $8F402, $8F464 (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $9075C, $90796, $9081A, $9084A, $90870, $90894, $908B4, $90A48, $90AA8, $90ADC, $91008, $91046 (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $90AD6 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $8F876, $8F962, $8F9A6, $8FF28, $8FF56, $8FF8E, $8FF9E, $8FFB2, $8FFC2, $8FFF8, $90012, $90072, $900C8, $90138, $90164, $90192, $901EA, $9022E, $9028A, $902D4, $90464, $9049C, $90736, $90750, $907F4, $9080E, $909FE, $90A22, $90A3C, $90A98, $90B72, $90F46, $90F7E, $90FAC, $90FB8, $90FFC, $91298, $912FC, $913FA, $91524, $91564, $915A2, $91688, $916F4, $919F2, $91A28, $91A56, $91A90, $91C48 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $8F97A, $8F9BE, $9003C, $90064, $90154, $9024C, $902F2, $90BA6, $90BBA, $91AC6, $91ADC, $91AF2, $91B12, $91B34, $91B5A (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $8FF40, $8FF62, $9018C, $90268, $9030E, $90A16, $91308, $91422, $91456, $91A34 (video95_03)
PrintListItem = $7CB2E		;IDA: sub_7CB2E. used at $91A44 (video95_03)
ReadAttributeNibbleD7 = $7CB60	;IDA: sub_7CB60. used at $8E7E0, $8E848 (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $8F1CC, $90036, $9014E, $91ABA, $91AD0, $91AE6, $91B06, $91B28, $91B4E (video95_03)
appstring = $7D214		;IDA: sub_7D214. used at $8F1D8 (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $8F582, $8FECA, $8FEE2, $904E8, $90FE8, $916DC (video95_03)
startpause1 = $7E7F8		;IDA: loc_7E7F8. used at $8DF88 (menu95)
startpause2 = $7E7FE		;IDA: loc_7E7FE. used at $8DFA0 (menu95)
startpause3 = $7E806		;IDA: loc_7E806. used at $8DFBC (menu95)
startpause4 = $7E80E		;IDA: loc_7E80E. used at $8DFD4 (menu95)
GetPlayerCountD7 = $83904	;IDA: sub_83904. used at $8E854 (collide95_02)
GameSetUp = $85A9E		;IDA: sub_85A9E. used at $8E194 (data95_01)
ExitToOpening = $8CD02		;IDA: loc_8CD02. used at $8DFF0 (checks95_06)
InitSeasonStats = $92BEC	;IDA: sub_92BEC. used at $8F696 (stats95_01)
SaveSimGame = $92CAE		;IDA: sub_92CAE. used at $8E76E, $8EFA8 (stats95_01)
SeasonPlayerStats = $9348A	;no IDA label. used at $906C4, $906D4 (stats95_01)
SeasonTeamStats = $93BD2	;no IDA label. used at $906A4, $906B4 (stats95_01)
LeagueLeadersScreen = $94110	;no IDA label. used at $90694 (stats95_01)
HighlightsScreen = $95D28	;no IDA label. used at $906DE (stats95_01)
SeasonAwards = $9C766		;IDA: sub_9C766. used at $8E21A (awards95)
InitPlayoffs = $9D4CE		;IDA: sub_9D4CE. used at $8E1CA (awards95)
SetupPlayoffs = $9D662		;IDA: sub_9D662. used at $8E1D6 (awards95)
NextPlayoffRound = $9D748	;IDA: sub_9D748. used at $8E52E (awards95)
PlayoffRoundDone = $9D7C0	;IDA: sub_9D7C0. used at $8E50E (awards95)
ReadPlayoffSchedule = $9D8AE	;IDA: sub_9D8AE. used at $8E2E2, $8E37C, $8E434 (awards95)
RecordPlayoffGame = $9D8D2	;IDA: sub_9D8D2. used at $8E652, $8EF8A (awards95)
PlayoffTreeScreen = $9D9CE	;no IDA label. used at $906FC (title95_01)
StanleyCupScreen = $A17B8	;IDA: sub_A17B8. used at $8E214 (title95_02)
SmallFontMap = $139094		;IDA: unk_139094. used at $8F83A, $8F852, $8F94A, $8F98E, $903C6, $903DE, $903F2, $90EC6, $90EDE, $90EF6, $90F0A, $911DE, $911F2, $91200, $9199C, $919B4, $919C8 (graphics95_01)
Teamblocksmap = $142906		;IDA: unk_142906. used at $90326, $90458, $91230, $91538, $919E6, $91B76 (graphics95_01)
Framermap = $14C148		;IDA: unk_14C148. used at $90F24, $90F2A (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $8F86A, $90400, $90F18, $91218, $919D6 (graphics95_01)
ControllerBgMap = $164AC8	;IDA: unk_164AC8. used at $8F882, $90F52, $916BC (graphics95_01)
GamesTodayLogoMap = $165A36	;IDA: unk_165A36. used at $8FBD2 (graphics95_01)
GamesTodayMap1 = $167524	;IDA: unk_167524. used at $901B2, $90410 (graphics95_01)
GamesTodayMap2 = $16767E	;IDA: unk_16767E. used at $9020A, $90428 (graphics95_01)
GamesTodayMap3 = $16781E	;IDA: unk_16781E. used at $902B0, $90440 (graphics95_01)
CalendarBgMap = $167A44		;no IDA label. used at $912A4, $91694 (graphics95_01)
CalOpponentMap = $168E72	;no IDA label. used at $91240, $91600 (graphics95_01)
CalDayMap = $1696DC		;no IDA label. used at $91250, $915C0 (graphics95_01)
CalMonthMap = $169CE6		;no IDA label. used at $91260, $91578 (graphics95_01)
CalCheckMap = $16A814		;no IDA label. used at $91270 (graphics95_01)
CalResultMap = $16A8BC		;no IDA label. used at $91280, $9163E (graphics95_01)
WaitBoxMap = $16CC82		;no IDA label. used at $90F8A (graphics95_01)

; Main segment code
	include	season95.asm
