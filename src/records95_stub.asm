;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	records95 segment stub. Retail $09B6F4-$09C019.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9B6F4

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $09B6F4-$09C019, read from lst/nhl95.bin.
WriteSRAM = $98E6		;IDA: sub_98E6. used at $9B89C, $9C008 (sram95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $9C00E (sram95)
ReadSRAM = $9952		;IDA: sub_9952. used at $9B8A6, $9BF48 (sram95)
ReadMenuJoy = $7A6AA		;IDA: sub_7A6AA. used at $9B99A (video95_02)
ProcessInputWithRepeat = $7A762	;IDA: sub_7A762. used at $9B9A0 (video95_02)
vcountwait = $7C6BE		;IDA: sub_7C6BE. used at $9B994 (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $9B976, $9BB4C, $9BC54, $9BC8A (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $9BA4E, $9BBD6, $9BBF0, $9BC0A, $9BC30, $9BD0E, $9BD9A, $9BE0E, $9BE2E (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $9B8B6, $9B93C (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $9B8CA, $9B954, $9BC6E (video95_03)
PushNumberWidth = $7D154	;IDA: sub_7D154. used at $9BBD0, $9BBEA, $9BC04, $9BC1E, $9BD08 (video95_03)
appstring = $7D214		;IDA: sub_7D214. used at $9BD62 (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $9B95A (video95_03)
AppendTeamName = $7DC36		;no IDA label. used at $9BD50, $9BD8A (video95_03)
StartText = $7DC62		;no IDA label. used at $9BD28 (video95_03)
AppendUserName = $7DC76		;no IDA label. used at $9BE28 (video95_03)
ExitAttributeScreen2 = $8546E	;IDA: loc_8546E. used at $9B9AE (data95_01)
ReadTeamStats = $877AC		;IDA: sub_877AC. used at $9B8DA (data95_01)
DisplayAttributeScreen = $925B2	;no IDA label. used at $9B902 (stats95_01)
NameEntryScreen = $9ACE6	;IDA: sub_9ACE6. used at $9B72A, $9B748, $9B766, $9B784 (cards95_01)
SetupScreen = $9C5B8		;no IDA label. used at $9B936 (cards95_02)

; Main segment code
	include	records95.asm
