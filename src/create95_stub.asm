;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	create95 segment stub. Retail $097C54-$09ACE5.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$97C54

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $097C54-$09ACE5, read from lst/nhl95.bin.
WriteSRAM = $98E6		;IDA: sub_98E6. used at $98AE2, $98D1E, $98E20, $99DCE (sram95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $980DC, $98DC8, $99DFA, $9A952 (sram95)
ReadSRAM = $9952		;IDA: sub_9952. used at $988FC, $98AB8, $98CF4, $98E08 (sram95)
Opening2 = $9ADA		;IDA: loc_9ADA. used at $98110, $9915A, $9A50E, $9AC88 (hockey95)
clearTeamStats = $AE48		;IDA: sub_AE48. used at $9A66C, $9A6A8 (setup95_01)
setvram = $79936		;IDA: sub_79936. used at $97CA6, $98B54, $98E82 (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $97D8E, $982DC, $98C5C, $98F70, $99EBE, $99EEA (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $97D42, $97DCA (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $99E8C, $9A5C8 (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $97CC0, $97CD8, $97CF0, $97D08, $97D2A, $97D5C, $97DB2, $98B78, $98B90, $98BA8, $98BC0, $98BD8, $98BF0, $98EA6, $98EBE, $98ED6, $98EEE, $98F06, $98F1E, $98F80 (video95_02)
Framer = $7A270			;IDA: sub_7A270. used at $986C0, $9885E, $9A2E2, $9A530, $9AA76, $9ACAA (video95_02)
VBlank_SetOptions = $7A418	;IDA: unk_7A418. used at $97C54, $98B06, $98E34 (video95_02)
orjoy = $7A448			;IDA: sub_7A448. used at $97CAC, $98B5E, $98E8C (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $97EC4, $988C0, $9902A, $9A4D6, $9AC1C (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $9A4EC, $9AC32 (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $9AC50 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $9AC66 (video95_02)
ProcessInputWithRepeat = $7A762	;IDA: sub_7A762. used at $99030, $9A4DC, $9A4F2, $9AC22, $9AC38, $9AC56, $9AC6C (video95_02)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $98198, $981AE, $981D0, $981F4, $98212, $98230, $9824E, $9826C, $9828A, $982A0, $9832E, $98344 and 45 more (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $9867C, $992B8, $992FA, $9935A, $99392, $993B8, $993DE, $99406, $9942E, $9945C, $99484, $994AC and 17 more (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $97D6A, $97E7E, $97E92, $97FD6, $97FE6, $980E8, $9811A, $98146, $98188, $981A2, $981C4, $982B8 and 29 more (video95_03)
print = $7C822			;IDA: sub_7C822. used at $98174, $98488, $98570, $98580, $98630, $991C6, $99218 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $98000, $9806E, $980FC, $98132, $9830A, $98C1C, $98F40, $99CEC, $9A1DE, $9A338, $9A970, $9AACC (video95_03)
PrintSmallListItem = $7CB38	;IDA: sub_7CB38. used at $99692, $996B4, $997DA, $9A430, $9A53E, $9ABB8, $9ACB8 (video95_03)
ReadAttributeNibbleD7 = $7CB60	;IDA: sub_7CB60. used at $9A1FC, $9A214, $9A98E, $9A9A6 (video95_03)
GetDefenseStartD7 = $7CBB6	;IDA: sub_7CBB6. used at $9A200, $9A22C, $9A98E, $9A9BE (video95_03)
ProcessNibbleD7 = $7CC08	;IDA: sub_7CC08. used at $9A220, $9A9B2 (video95_03)
FormatPlayerNameD7 = $7CD82	;IDA: sub_7CD82. used at $9A408, $9AB96 (video95_03)
CalcAttribRating = $7CF78	;IDA: sub_7CF78. used at $992A2, $9934A, $99382, $993A8, $993CE, $993F6, $9941E, $99446, $99474, $9949C, $994C4, $994EC, $99514, $99576, $9959E, $995C6, $995EE, $99616, $9963E, $99666, $9A474 (video95_03)
OvrPlayerWgtList = $7D08C	;IDA: unk_7D08C. used at $99296, $9A468 (video95_03)
OvrGoalWgtList = $7D09C		;IDA: unk_7D09C. used at $99280, $9A454 (video95_03)
AttribWgtList = $7D0AC		;IDA: unk_7D0AC. used at $9936E (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $992B2, $992F4, $99354, $9938C, $993B2, $993D8, $99400, $99428, $99456, $9947E, $994A6, $994CE and 12 more (video95_03)
SetRinkPalette = $7D6F0		;IDA: sub_7D6F0. used at $98C22, $98F46 (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $97DDC, $98F8E, $99EF0, $9A5D4 (video95_03)
GetPlayerCountD7 = $83904	;IDA: sub_83904. used at $9A0CA, $9A204, $9A234, $9A6AE, $9A76E, $9A80E, $9A98E, $9A9C6, $9AA24 (collide95_02)
AttribScaleTable = $83C9E	;IDA: unk_83C9E. used at $99E76 (collide95_02)
PAttribOverallMask = $85846	;IDA: dword_85846. used at $9929C, $99344, $9937C, $993A2, $993C8, $993F0, $99418, $99440, $9946E, $99496, $994BE, $994E6 and 13 more (data95_01)
GAttribOverallMask = $859A8	;IDA: dword_859A8. used at $99286, $99570, $99598, $995C0, $995E8, $99610, $99638, $99660, $99AD8, $99B36, $99B3E, $99B76, $99B80, $99B8A, $99B94, $9A45A (data95_01)
CheckSavedLines = $8A79A	;IDA: sub_8A79A. used at $9A890 (checks95_05)
ReadTeamPlayerStats = $93226	;IDA: sub_93226. used at $98D7A, $9A8E4 (stats95_01)
WriteTeamPlayerStats = $932F8	;IDA: sub_932F8. used at $98DB8, $9A92C (stats95_01)
MarkSeasonRosters = $93430	;IDA: sub_93430. used at $99F7E (stats95_01)
GetCreatedName = $96494		;IDA: sub_96494. used at $98934, $9A43E (trade95)
GetJerseyNumber = $965A8	;IDA: sub_965A8. used at $98CCE, $9A130 (trade95)
MoveTradedPlayer = $9684A	;IDA: sub_9684A. used at $9A87A (trade95)
RemoveTradedPlayer = $96A54	;IDA: sub_96A54. used at $9A1B4 (trade95)
TradeRulesText = $97338		;IDA: unk_97338. used at $9A310, $9AAA4 (trade95)
TradeGfx = $9743A		;IDA: sub_9743A. used at $99E92, $9A5CE (trade95)
DrawTradeLogo = $9757C		;IDA: sub_9757C. used at $9A362, $9AAF6 (trade95)
DrawTradeTeam = $975AC		;IDA: sub_975AC. used at $9A6D4 (trade95)
SmallFontMap = $139094		;IDA: unk_139094. used at $97CBA, $97CD2, $97CEA, $97D02, $97D16, $98BA2, $98BBA, $98BD2, $98BEA, $98BFE, $98ED0, $98EE8, $98F00, $98F18 (graphics95_01)
Teamblocksmap = $142906		;IDA: unk_142906. used at $97D3C (graphics95_01)
Framermap = $14C148		;IDA: unk_14C148. used at $97D48, $97D52, $98B68, $98B6E, $98B8A, $98E96, $98EA0, $98EB8 (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $97D24, $97DAC, $98F7A (graphics95_01)
ControllerBgMap = $164AC8	;IDA: unk_164AC8. used at $98C34, $98F58 (graphics95_01)
CreateBgMap = $1703FE		;no IDA label. used at $97D76 (graphics95_01)
TradeBgMap = $172CCC		;IDA: unk_172CCC. used at $98C44 (graphics95_01)
FreeAgentMap2 = $181078		;IDA: unk_181078. used at $99ED0 (graphics95_01)
FreeAgentMap1 = $181486		;no IDA label. used at $99EA4 (graphics95_01)
NameEntryBgMap = $1834F4	;IDA: unk_1834F4. used at $97DC4, $982C4 (graphics95_01)

; Main segment code
	include	create95.asm
