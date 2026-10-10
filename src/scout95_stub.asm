;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	scout95 segment stub. Retail $09F590-$0A00D5.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9F590

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $09F590-$0A00D5, read from lst/nhl95.bin.
clearTeamStats = $AE48		;IDA: sub_AE48. used at $9F5F6 (setup95_01)
Z80Program = $BD86		;no IDA label. used at $9F5B8 (sound95_01)
SoundBanks = $D8EC		;no IDA label. used at $9F5CA (sound95_01)
SoundCmd = $676D8		;IDA: sub_676D8. used at $9F5AA, $9F5BE, $9F5D0, $9F5DE (sound95_01)
song = $678C2			;IDA: sub_678C2. used at $9F5E8 (sound95_01)
play_new_song = $67938		;IDA: sub_67938. used at $9F5A0 (sound95_01)
setvram = $79936		;IDA: sub_79936. used at $9F634 (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $9F6C4, $9F744, $9FB94 (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $9F754, $9F764 (video95_01)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $9F658, $9F67A, $9F692 (video95_02)
vb2 = $7A3F6			;IDA: unk_7A3F6. used at $9F5EE, $9F7A6 (video95_02)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $9FBEA, $9FCCC (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $9F99C, $9F9B2, $9FC2C, $9FCDC, $9FD80, $9FDE4, $9FF74 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $9F6A0, $9F6D0, $9F6E6, $9F6F6, $9F70A, $9F71E, $9FC42, $9FC76, $9FC9C, $9FD0C, $9FD40, $9FD70 and 3 more (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $9FBCC (video95_03)
CalcAttrib = $7CF16		;IDA: sub_7CF16. used at $9FD50, $9FDB4 (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $9F996, $9FD6A, $9FDCE (video95_03)
ScaleAttrib = $7D258		;IDA: sub_7D258. used at $9FD5C, $9FDC0 (video95_03)
TeamLogoBitmaps = $7D3F8	;IDA: unk_7D3F8. used at $9FBD6 (video95_03)
waitx = $7D706			;IDA: sub_7D706. used at $9F884 (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $9F76A (video95_03)
UnpackPicture = $7DA78		;IDA: sub_7DA78. used at $9FB52 (video95_03)
AnyPadAssigned = $7DFAC		;IDA: sub_7DFAC. used at $9F936 (fourway95)
Create_HotCold_Table = $83E88	;IDA: sub_83E88. used at $9F604, $9F610 (collide95_02)
PAttribOverallMask = $85846	;IDA: dword_85846. used at $9FCF4, $9FD8C (data95_01)
GAttribOverallMask = $859A8	;IDA: dword_859A8. used at $9FD02, $9FD9A (data95_01)
ReadNameLog = $9B876		;IDA: sub_9B876. used at $9F590 (records95)
StartScoutText = $A00D6		;IDA: sub_A00D6. used at $9F7B2 (setup95_03)
ScoutTextPlayer = $A00F0	;IDA: sub_A00F0. used at $9F91A (setup95_03)
PrintPlayerNameRight = $A043E	;IDA: sub_A043E. used at $9FD4C, $9FDB0 (setup95_03)
CopyHottestPlayer = $A0672	;IDA: sub_A0672. used at $A0010, $A002E (setup95_03)
CopyColdestPlayer = $A0692	;IDA: sub_A0692. used at $A001A, $A0038 (setup95_03)
GetTeamRating = $A06B0		;IDA: sub_A06B0. used at $9F98A (setup95_03)
GetHomeUsers = $A08DC		;IDA: sub_A08DC. used at $9F7DC (setup95_03)
GetAwayUsers = $A0954		;IDA: sub_A0954. used at $9F81A (setup95_03)
GetPlayerPicture = $A0A30	;IDA: sub_A0A30. used at $9FAC4, $9FAFC (setup95_03)
NoPlayerPicture = $A1A5A	;IDA: unk_A1A5A. used at $9FB32, $9FB40 (title95_02)
SmallFontMap = $139094		;IDA: unk_139094. used at $9F666, $9F68C (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $9F652 (graphics95_01)
ScoutReportMap = $1891F8	;no IDA label. used at $9F6AC (graphics95_01)
HotIconMap = $18A5C6		;IDA: unk_18A5C6. used at $9F74A (graphics95_01)
ColdIconMap = $18A78C		;IDA: unk_18A78C. used at $9F75A (graphics95_01)
RonBarrMap = $18A9B2		;no IDA label. used at $9F72A (graphics95_01)
TeamLogoPalettes = $1A169A	;IDA: unk_1A169A. used at $9FB7E (graphics95_01)

; Main segment code
	include	scout95.asm
