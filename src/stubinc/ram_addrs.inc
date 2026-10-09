; RAM map. Add each new RAM name here as you transcribe code segments that use it.
; Do not copy 94 IDA names. Use the 94 name only when the address and the using routine match.
; The final consolidation pass will organize these into src/ram95.asm.
M68K_RAM equ $FFFF0000
VSCRLPM equ $FFFFAC00	;94 $FFFFB000. Hscroll table vram address (VDP reg $0D); first long Begin clears
OptPlayMode equ $FFFFCC4C	;94 $FFFFD048. Start of the menu options
OptLine equ $FFFFCC5C	;94 $FFFFD058
music_global_tick_counter equ $FFFFCC72	;94 $FFFFD06E. Begin stores the VDP PAL bit here
TmpOptLine2 equ $FFFFCC76	;94 $FFFFD072
TempOptPlayMode equ $FFFFCC78	;94 $FFFFD074
PlayingSong equ $FFFFCFD8	;95 only. Song the sound driver is playing ($32-$55), -1 = none
PALflag equ $FFFFDBBC	;94 $FFFFDEF2. Bit 0 set on a PAL (50 Hz) machine
Stack equ $FFFFFDFA	;94 $FFFFFFFE. Begin's stack pointer; the sound driver uses $FFFFFDFC-$FFFFFDFF above it
vbint equ $FFFFAC52	;94 $FFFFB03A. Vertical blank handler address (VBjsr jumps through it)
vcount equ $FFFFAC56	;94 $FFFFB03E. Vertical blank counter
GameFlags equ $FFFFBF08	;95 only. Flag byte: bit 7 holds MakeSRAMChecksum during a batch of save RAM writes; bits 0, 1 pick the second shot / pass tables
SeasonStartDay equ $FFFFD1A4	;95 only. Schedule day the season starts on (sub_8E26A picks it at random)
SeasonLength equ $FFFFD1A5	;95 only. Days in the season ($C0 = the whole schedule)
SeasonDay equ $FFFFD1A6	;95 only. Days played; the byte after it is the season flags
ValidSRAM equ $FFFFDC3A	;94 $FFFFD458. 0 = save RAM checksum good, -1 = bad
SRAMChecksum equ $FFFFDC5E	;95 only. The complement and sum bytes MakeSRAMChecksum writes to save RAM bytes $7FFE-$7FFF
