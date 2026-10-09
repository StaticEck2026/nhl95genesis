; ------------- equals -------------
; VDP status register bits (hardware, the same as 94)
PAL_MODE equ 0
DMA_IN_PROGRESS equ 1
HBLANKING equ 2
VBLANKING equ 3
ODD_FRAME equ 4
SPRITE_COLLISION equ 5
SPRITE_OVERFLOW equ 6
VBLANK_PENDING equ 7
FIFO_FULL equ 8
FIFO_EMPTY equ 9
; ----------------------------------
; Structure and flag equates. Empty until the first segment confirms the 95 values.

;the sort object structure (SCstruct = $80 bytes each, from SortCords). 93 / 94 names; hockey95 updateplayers confirms these 95 values
SCstruct equ $80
Xpos equ $0
attribute equ $4		;frame attribute switch bits
Ypos equ $14
Zpos equ $18
OldXpos equ $1C
OldYpos equ $20
OldZpos equ $24
Xvel equ $28
Yvel equ $2A
SCnum equ $52		;index number for this struct
SPA equ $58		;animation (frames95 SPA offset)
SPAnum equ $5A		;index into animation
nopuck equ $5E		;no puck coll until zero
pnum equ $66		;player's team location number

;bit numbers in gmode
gmoffs equ 5		;offsides on
;bit numbers in sflags
sfpz equ 0		;pause mode
sfwrap equ 4		;replay has wrapped around
;bit numbers in sflags2
sf2faceoff equ 0		;face off in progress
sf2drec equ 2		;disable replay record
