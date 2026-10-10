;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	stats95_02 segment stub. Retail $0A0B3E-$0A12A9.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$A0B3E

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $0A0B3E-$0A12A9, read from lst/nhl95.bin.
ReadMenuJoy = $7A6AA		;IDA: sub_7A6AA. used at $A0DE0, $A10E0 (video95_02)
vcountwait = $7C6BE		;IDA: sub_7C6BE. used at $A0DC0, $A0DDA, $A10C0, $A10DA (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $A0D64, $A0FC2, $A1064 (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $A0F9A, $A129E (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $A0E9A, $A0EC8, $A11A2, $A11D0 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $A0F3A, $A1242, $A126C, $A1284 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $A0EFA, $A1202 (video95_03)
PrintSmallListItem = $7CB38	;IDA: sub_7CB38. used at $A0F52, $A0FEE (video95_03)
FormatPlayerNameWithAttrib = $7CD38	;IDA: sub_7CD38. used at $A0F94, $A127E (video95_03)
PushNumber = $7D120		;IDA: sub_7D120. used at $A1260 (video95_03)
PutTeamBlock = $7D268		;IDA: sub_7D268. used at $A0D52, $A0D5E, $A1052, $A105E (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $A0D2E, $A1036 (video95_03)
FormatAndPrintTime = $7DF7C	;no IDA label. used at $A0F12, $A121A (fourway95)
ExitAttributeScreen2 = $8546E	;IDA: loc_8546E. used at $A0DEE, $A10EE (data95_01)
PenaltyNames = $89C2E		;IDA: unk_89C2E. used at $A1250 (data95_02)
DrawTeamScreen2 = $8ACEC	;IDA: sub_8ACEC. used at $A0D28, $A1030 (checks95_05)
ControllerBgMap = $164AC8	;IDA: unk_164AC8. used at $A0D1E, $A1026 (graphics95_01)
CrowdFrameList = $18B628		;IDA: unk_18B628. used at $A0C02 (graphics95_01)

; Main segment code
	include	stats95_02.asm
