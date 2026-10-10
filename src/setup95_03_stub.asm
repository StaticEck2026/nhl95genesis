;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	setup95_03 segment stub. Retail $0A00D6-$0A0B3D.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$A00D6

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $0A00D6-$0A0B3D, read from lst/nhl95.bin.
TeamList = $772			;no IDA label. used at $A0A3E, $A0AAE (main95)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $A054E (video95_01)
printz = $7C810			;IDA: sub_7C810. used at $A0244 (video95_03)
print = $7C822			;IDA: sub_7C822. used at $A0260, $A047C (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $A0508 (video95_03)
ReadAttributeNibbleD7 = $7CB60	;IDA: sub_7CB60. used at $A0A76 (video95_03)
FormatPlayerName = $7CDC2	;IDA: sub_7CDC2. used at $A0448 (video95_03)
DoDMA_nd2 = $7D35E		;IDA: sub_7D35E. used at $A03A6 (video95_03)
GetRosterId = $96454		;IDA: sub_96454. used at $A0A8E (trade95)
GetCreatedName = $96494		;IDA: sub_96494. used at $A0AF8 (trade95)
GetLogName = $9B50E		;IDA: sub_9B50E. used at $A0A04 (cards95_01)
SortHotColdStarters = $A0042	;IDA: sub_A0042. used at $A041E (scout95)
NoPicSkater2 = $A1E90		;IDA: unk_A1E90. used at $A0B24 (graphics95_01)
NoPicSkater1 = $A21FA		;IDA: unk_A21FA. used at $A0B0C (graphics95_01)
NoPicGoalie2 = $A2564		;IDA: unk_A2564. used at $A0B1A (graphics95_01)
NoPicGoalie1 = $A28CE		;IDA: unk_A28CE. used at $A0B32 (graphics95_01)
FeaturedPicIdx = $C4754		;IDA: unk_C4754. used at $A0AD4 (graphics95_01)
FeaturedPictures = $C47FC	;IDA: unk_C47FC. used at $A0AEA (graphics95_01)
HotIconMap = $18A5C6		;IDA: unk_18A5C6. used at $A0516 (graphics95_01)
ColdIconMap = $18A78C		;IDA: unk_18A78C. used at $A0524 (graphics95_01)

; Main segment code
	include	setup95_03.asm
