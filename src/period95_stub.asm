;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	period95 segment stub. Retail $0920DE-$0925AD.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$920DE

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $0920DE-$0925AD, read from lst/nhl95.bin.
nodiag = $7A488			;IDA: sub_7A488. used at $92154 (video95_02)
ReadMenuJoy = $7A6AA		;IDA: sub_7A6AA. used at $92140 (video95_02)
vcountwait = $7C6BE		;IDA: sub_7C6BE. used at $9213A (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $92212, $92224, $92238, $92254, $92268, $92278 (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $92288, $9229E, $922B6 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $922E6, $923FC (video95_03)
PushTime = $7D0BC		;IDA: sub_7D0BC. used at $92408 (video95_03)
PushNumber = $7D120		;IDA: sub_7D120. used at $92342, $923A6, $923DC, $92402 (video95_03)
appendz = $7D20C		;IDA: sub_7D20C. used at $9234E, $92398, $923BA, $923E8 (video95_03)
appstring = $7D214		;IDA: sub_7D214. used at $92348, $9238A, $923AC, $923E2 (video95_03)
PutTeamBlock = $7D268		;IDA: sub_7D268. used at $92298, $922AC (video95_03)
printbigz = $7D8D2		;IDA: sub_7D8D2. used at $920F2 (video95_03)
ExitAttributeScreen2 = $8546E	;IDA: loc_8546E. used at $9214E (data95_01)
DrawTeamScreen2 = $8ACEC	;IDA: sub_8ACEC. used at $920EC (checks95_05)
rtsStatTables = $925AE		;IDA: locret_925AE. used at $92182, $9218A, $92192 (stats95_01)
ControllerBgMap = $164AC8	;IDA: unk_164AC8. used at $920E2 (graphics95_01)

; Main segment code
	include	period95.asm
