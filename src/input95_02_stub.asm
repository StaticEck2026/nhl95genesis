	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	input95_02 segment stub. Retail $08A056-$08A3FD.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$8A056

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $08A056-$08A3FD, read from lst/nhl95.bin.
dobitmap = $79A3C		;IDA: sub_79A3C. used at $8A372 (video95_01)
Framer = $7A270			;IDA: sub_7A270. used at $8A0BA (video95_02)
printz = $7C810			;IDA: sub_7C810. used at $8A156 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $8A0FA, $8A12E (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $8A324 (video95_03)
loadTeamStruct = $7CAF0		;IDA: sub_7CAF0. used at $8A068, $8A2E6 (video95_03)
PrintSmallListItem = $7CB38	;IDA: sub_7CB38. used at $8A108 (video95_03)
PrintScores1 = $7D776		;IDA: sub_7D776. used at $8A32A (video95_03)
SetPersonel = $836CC		;IDA: sub_836CC. used at $8A2F6 (collide95_02)
priolist = $83E16		;IDA: unk_83E16. used at $8A392 (collide95_02)
linelist = $8A02C		;IDA: unk_8A02C. used at $8A102 (data95_02)
doplayeracc = $8BCFA		;IDA: loc_8BCFA. used at $8A2C4 (checks95_06)
box = $8C694			;IDA: sub_8C694. used at $8A0B0 (checks95_06)
EnergyBarMap = $14C4C8		;IDA: unk_14C4C8. used at $8A35A (graphics95_01)

; Main segment code
	include	input95_02.asm
