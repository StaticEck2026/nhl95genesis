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
frame equ $6		;alice frame number
VRchar equ $12		;vram char for graphic
Ypos equ $14
Zpos equ $18
OldXpos equ $1C
OldYpos equ $20
OldZpos equ $24
Xvel equ $28
Yvel equ $2A
SCnum equ $52		;index number for this struct
facedir equ $54		;direction of facing
SPA equ $58		;animation (frames95 SPA offset)
SPAnum equ $5A		;index into animation
SPAcnt equ $5C		;count down to next frame of animation
nopuck equ $5E		;no puck coll until zero
pflags equ $62
pfalock equ 5		;lock out until anim is done
pflags2 equ $63
pf2aip equ 1		;animation in progress wait
glitch equ $65		;counter to eliminate quick frame changes (de-glitch graphics)
pnum equ $66		;player's team location number

;bit numbers in gmode
gmoffs equ 5		;offsides on
;bit numbers in disflags
dfok equ 0		;graphics are ready for transfer
;bit numbers in sflags
sfpz equ 0		;pause mode
sfwrap equ 4		;replay has wrapped around
sfhor equ 7		;screen is in horizontal mode
;bit numbers in sflags2
sf2faceoff equ 0		;face off in progress
sf2drec equ 2		;disable replay record
