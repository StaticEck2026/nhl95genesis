;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	main95 segment stub. Retail $000000-$000771.
;	main95.asm includes macros\genesis.mac itself (it is the first file in nhl95.asm), so this stub does not.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	0

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $000000-$000771, read from lst/nhl95.bin.
; The vector longs carry the address itself; jsr / jmp (x).l carry it too; movea.l #x carries it as the immediate.
IRQ7 = $7A416			;IDA: IRQ7 (an rte). Vectors $60-$70 and $7C (video95_02)
VBjsr = $7A32C			;IDA: VBLANK. Vector $78 (video95_02)
ValidationRoutine = $1A72C0	;IDA: sub_1A72C0. jsr (x).l at $690 (checksum95)
SoundCmd = $676D8		;IDA: sub_676D8. jsr (x).l at $6F2, $6FC, $70E, $71C (sound95_01)
SoundOff = $679B2		;IDA: sub_679B2. jsr (x).l at $722 (sound95_01)
KillCrowd = $67988		;IDA: sub_67988. jsr (x).l at $728 (sound95_01)
Detect4WayPlay = $7DFC6		;IDA: sub_7DFC6. jsr (x).l at $72E (fourway95)
EASportsScreen = $8AAC8		;IDA: sub_8AAC8. jsr (x).l at $734 (checks95_05)
InitSaveRAM = $9722		;IDA: sub_9722. jsr (x).l at $73A (sram95)
HiScoreScreen = $A16DE		;IDA: sub_A16DE. jsr (x).l at $740 (title95_02)
ReadLineData = $87B30		;IDA: sub_87B30. jsr (x).l at $746 (data95_01)
DefaultMenus = $866DE		;IDA: sub_866DE. jsr (x).l at $74C (data95_01)
orjoy = $7A448			;IDA: sub_7A448. jsr (x).l at $766 (video95_02)
Opening = $9AC8			;IDA: loc_9AC8. jmp (x).l at $76C (hockey95)
Z80Program = $BD86		;movea.l #x at $6EC. The 95 Z80 sound program (sounddrv95)
SoundBanks = $D8EC		;movea.l #x at $708. The sound data after the Z80 program (sounddrv95)

; Main segment code
	include	main95.asm
