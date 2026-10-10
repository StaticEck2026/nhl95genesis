;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	cards95_02 segment stub. Retail $09C01A-$09C6EF.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$9C01A

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $09C01A-$09C6EF, read from lst/nhl95.bin.
WriteSRAM = $98E6		;IDA: sub_98E6. used at $9C484, $9C4C2, $9C50C (sram95)
MakeSRAMChecksum = $9908	;IDA: sub_9908. used at $9C140 (sram95)
ReadSRAM = $9952		;IDA: sub_9952. used at $9C48E, $9C4CC, $9C516 (sram95)
Vmaddr = $79A22			;IDA: sub_79A22. used at $9C5F8, $9C618 (video95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $9C65C (video95_01)
DoDMA_clearCallbackPointer = $79AC0	;IDA: sub_79AC0. used at $9C6BE (video95_01)
SetScroll2 = $79CCA		;IDA: sub_79CCA. used at $9C5D2 (video95_01)
forceblack = $7A02A		;IDA: sub_7A02A. used at $9C5BC (display95_02)
DecompressGraphicsWithCallback = $7A264	;IDA: sub_7A264. used at $9C66C, $9C684, $9C69C (video95_02)
printz = $7C810			;IDA: sub_7C810. used at $9C632, $9C6C4 (video95_03)
eraser = $7C8CC			;IDA: sub_7C8CC. used at $9C6D8 (video95_03)
ReadAttributeNibble = $7CB4E	;IDA: sub_7CB4E. used at $9C56E, $9C57E (video95_03)
GetPlayerCount = $838F2		;IDA: sub_838F2. used at $9C598, $9C5A8 (collide95_02)
GetTeamUser = $9C6F0		;IDA: sub_9C6F0. used at $9C07E, $9C08C, $9C0B8, $9C0C6, $9C440 (awards95)
SmallFontMap = $139094		;IDA: unk_139094. used at $9C666, $9C67E, $9C696, $9C6AA (graphics95_01)
BigFontMap2 = $15F46C		;IDA: unk_15F46C. used at $9C6B8 (graphics95_01)
ControllerBgMap = $164AC8	;IDA: unk_164AC8. used at $9C642 (graphics95_01)

; Main segment code
	include	cards95_02.asm
