	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	video95_03 segment stub. Retail $07C512-$07DE9F.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$7C512

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $07C512-$07DE9F, read from lst/nhl95.bin.
TeamList = $772			;movea.l #x at $7CB96, $7DC3E (teamdata95)
defaultsprites = $A656		;IDA: sub_A656. used at $7DDC2 (setup95_01)
SprSort = $A8E6			;IDA: sub_A8E6. used at $7D512 (setup95_01)
chgplayer = $AB4E		;IDA: sub_AB4E. used at $7D5B6, $7D61C, $7D682, $7D6E8 (setup95_01)
setc1player = $AD80		;IDA: loc_AD80. used at $7D5A6 (setup95_01)
setc2player = $AD8A		;IDA: loc_AD8A. used at $7D60C (setup95_01)
setc3player = $AD96		;IDA: loc_AD96. used at $7D672 (setup95_01)
setc4player = $ADA2		;IDA: loc_ADA2. used at $7D6D8 (setup95_01)
setplayercolors = $AF1A		;IDA: sub_AF1A. used at $7DE00 (setup95_01)
ReadSRAM = $9952		;IDA: sub_9952. used at $7CB82, $7CC36 (sram95)
SoundCmd = $676D8		;IDA: sub_676D8. used at $7D3BA, $7D3DA (sound95_01)
DoFill = $79902			;IDA: sub_79902. used at $7DD76 (video95_01)
setvram = $79936		;IDA: sub_79936. used at $7DD42 (video95_01)
Vmaddr = $79A22			;IDA: sub_79A22. used at $7DA30 (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $7C9C0, $7D49A (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $7D2D2, $7D4FC, $7D862, $7D87C, $7DD88, $7DDA8, $7DDB8 (video95_01)
WaitDMA = $79B12		;IDA: sub_79B12. used at $7D3CA (video95_01)
xyVmMap = $79C18		;IDA: sub_79C18. used at $7C6F8, $7C76C, $7C7B6, $7C7D4, $7C7E2, $7C7F0, $7C7FE, $7C830, $7C878, $7C8C6, $7C8DE, $7D27E (video95_01)
DoDMAlist = $79CA8		;IDA: sub_79CA8. used at $7DE78 (video95_01)
rtss2 = $79CC8			;IDA: locret_79CC8. used at $7C514. An rts (video95_01)
addframe2 = $79DA8		;IDA: addframe2. used at $7DE3C, $7DE46, $7DE50, $7DE5A, $7DE64, $7DE6E (display95_02)
AddSmallFont = $7A256		;IDA dc.b. used at $7D852 (video95_02)
Framer = $7A270			;IDA: sub_7A270. used at $7D7A2, $7D7F4 (video95_02)
AddFramer = $7A2EC		;IDA dc.b. used at $7D848 (video95_02)
AddFramer2 = $7A310		;IDA: sub_7A310. used at $7DDD2 (video95_02)
VBlank = $7A332			;IDA: unk_7A332. used at $7DE82 (video95_02)
ReadJoy1 = $7A4B0		;IDA: sub_7A4B0. used at $7D710 (video95_02)
ReadJoy2 = $7A4C8		;IDA: sub_7A4C8. used at $7D720 (video95_02)
ReadJoy3 = $7A4E0		;IDA: sub_7A4E0. used at $7D736 (video95_02)
ReadJoy4 = $7A50C		;IDA: sub_7A50C. used at $7D744 (video95_02)
LoadHomeTeamGfx = $7DEA0	;IDA: sub_7DEA0. used at $7D502, $7DD8E (fourway95)
EASNLogo = $7DF32		;IDA: sub_7DF32. used at $7D7D8 (fourway95)
setupEASNmap = $7DF6A		;IDA: sub_7DF6A. used at $7D50C, $7DD98 (fourway95)
AttribScaleTable = $83C9E	;IDA: unk_83C9E. used at $7CFBC. CalcAttribRating, attribute 5 scale (data95_01)
PAttribOverallMask = $85846	;IDA: dword_85846. used at $7CF26 (data95_01)
GAttribOverallMask = $859A8	;IDA: dword_859A8. used at $7CF36 (data95_01)
FindGoalie = $8B974		;IDA: sub_8B974. used at $7D59E, $7D602, $7D668, $7D6CE. 95: d0 = SCnum of the goalie of the team of player d0
GetCreatedName = $96494		;IDA: sub_96494. used at $7CE7E (create95)
GetRosterName = $9649E		;IDA: sub_9649E. used at $7CEE8, $7CF60. a1 = name String of player d0 of team d7 (season roster aware)
GetJerseyNumber = $965A8	;IDA: sub_965A8. used at $7CCAC, $7CD4C, $7CD92, $7CDD6. jerseynum = the jersey number byte of player d0 of team d7
Rinktilelist = $C4A7C		;IDA: unk_C4A7C. used at $7D4F6, $7D6F0, $7DD82 (graphics95_01)
SmallFontMap2 = $139E02		;IDA: unk_139E02. used at $7D85C, $7D868 (graphics95_01)
HotSpotList = $137B66		;IDA: unk_137B66. used at $7C686. Hot spot x / y bytes by frame (GetHot; graphics95_01)
ClockDigitsBitmap = $13FC18	;IDA: unk_13FC18. used at $7C998. Big clock digits (PutClockDigit; graphics95_01)
EnergyBarMap = $14C4C8		;#x+8 at $7DDA2 (graphics95_01)
BigFontMap3 = $15CE68		;IDA dc.b. used at $7D924 (graphics95_01)
BigFontMap = $15E18A		;IDA: unk_15E18A. used at $7D876, $7D908 (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $7D916 (graphics95_01)
CrowdFrameList = $18B628	;#x+8 at $7DDB2 (graphics95_01)
TeamLogoPalettes = $1A169A	;#x at $7D484 (graphics95_01)
logoANA = $19A992		;dc.l x at $7D3F8 (TeamLogoBitmaps row) (graphics95_01)
logoBOS = $19AE28		;dc.l x at $7D3F8 (TeamLogoBitmaps row) (graphics95_01)
logoBUF = $19B17E		;dc.l x at $7D3F8 (TeamLogoBitmaps row) (graphics95_01)
logoCGY = $19B4D4		;dc.l x at $7D3F8 (TeamLogoBitmaps row) (graphics95_01)
logoCHI = $19B96A		;dc.l x at $7D3F8 (TeamLogoBitmaps row) (graphics95_01)
logoDAL = $19D304		;dc.l x at $7D3F8 (TeamLogoBitmaps row) (graphics95_01)
logoDET = $19BDA0		;dc.l x at $7D3F8 (TeamLogoBitmaps row) (graphics95_01)
logoEDM = $19C0F6		;dc.l x at $7D3F8 (TeamLogoBitmaps row) (graphics95_01)
logoFLA = $19C4EC		;dc.l x at $7D418 (TeamLogoBitmaps row) (graphics95_01)
logoHFD = $19C8A2		;dc.l x at $7D418 (TeamLogoBitmaps row) (graphics95_01)
logoLA = $19CF8E		;dc.l x at $7D418 (TeamLogoBitmaps row) (graphics95_01)
logoMTL = $19D71A		;dc.l x at $7D418 (TeamLogoBitmaps row) (graphics95_01)
logoNJ = $19DA90		;dc.l x at $7D418 (TeamLogoBitmaps row) (graphics95_01)
logoNYI = $19CB38		;dc.l x at $7D418 (TeamLogoBitmaps row) (graphics95_01)
logoNYR = $19DF46		;dc.l x at $7D418 (TeamLogoBitmaps row) (graphics95_01)
logoOTW = $19E41C		;dc.l x at $7D418 (TeamLogoBitmaps row) (graphics95_01)
logoPHI = $19E832		;dc.l x at $7D438 (TeamLogoBitmaps row) (graphics95_01)
logoPIT = $19EBE8		;dc.l x at $7D438 (TeamLogoBitmaps row) (graphics95_01)
logoQUE = $19EF5E		;dc.l x at $7D438 (TeamLogoBitmaps row) (graphics95_01)
logoSJ = $19F2B4		;dc.l x at $7D438 (TeamLogoBitmaps row) (graphics95_01)
logoSTL = $19F6EA		;dc.l x at $7D438 (TeamLogoBitmaps row) (graphics95_01)
logoTB = $19FAC0		;dc.l x at $7D438 (TeamLogoBitmaps row) (graphics95_01)
logoTOR = $19FED6		;dc.l x at $7D438 (TeamLogoBitmaps row) (graphics95_01)
logoVAN = $1A022C		;dc.l x at $7D438 (TeamLogoBitmaps row) (graphics95_01)
logoWSH = $1A0642		;dc.l x at $7D458 (TeamLogoBitmaps row) (graphics95_01)
logoWPG = $1A08B8		;dc.l x at $7D458 (TeamLogoBitmaps row) (graphics95_01)
logoASE = $1A0D2E		;dc.l x at $7D458 (TeamLogoBitmaps row) (graphics95_01)
logoASW = $1A11E4		;dc.l x at $7D458 (TeamLogoBitmaps row) (graphics95_01)

; Main segment code
	include	video95_03.asm
