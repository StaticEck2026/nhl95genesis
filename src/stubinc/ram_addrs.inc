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
