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
puckscnum equ $E	;the puck sort object (SortCords + puckscnum * SCstruct = puckx); the shadow is puckscnum+1
Xpos equ $0
attribute equ $4		;frame attribute switch bits
frame equ $6		;alice frame number
oldframe equ $8		;last frame
VRoffs equ $A		;offsets to find each sprites start char. (max of 6 sprites / frame)
VRchar equ $12		;vram char for graphic
Ypos equ $14
Zpos equ $18
OldXpos equ $1C
OldYpos equ $20
OldZpos equ $24
Xvel equ $28
Yvel equ $2A
Zvel equ $2C
impactp equ $2E		;last player to cause impact
limpact equ $30		;last impact value
impact equ $32		;impact value
position equ $34		;player's position (0=goalie,1=l.def,2=r.def,3=l.wing,4=center,5=r.wing)
assnum equ $36		;index to current assignment
asslist equ $38		;list of assignments in order of execution
temp1 equ $40
temp2 equ $42
temp3 equ $44
temp4 equ $46
temp5 equ $48
radiusx equ $4A		;width of this graphic
radiusy equ $4C		;height of this graphic
Wallcos equ $4E		;cos of angle of last collision
Wallsin equ $50		;sin of angle of last collision
SCnum equ $52		;index number for this struct
facedir equ $54		;direction of facing
SPA equ $58		;animation (frames95 SPA offset)
SPAnum equ $5A		;index into animation
SPAcnt equ $5C		;count down to next frame of animation
nopuck equ $5E		;no puck coll until zero
newpos equ $60		;requested next position of this player
newpnum equ $61		;requested next player (from roster) for this player
pflags equ $62
pfdoff equ 0		;bit0-deceleration off
pfnc equ 2		;bit2-no collision mode
pfna equ 1		;bit1-new assignment
pfjoycon equ 3		;is player joystick controlled
pfteam equ 6		;0-home(sprite0-5)/1-visitors(sprite6-11)
pfgoal equ 7		;0=bottom, 1=top (to shoot at)
pfalock equ 5		;lock out until anim is done
pflags2 equ $63
pf2aip equ 1		;animation in progress wait
pf2fight equ 0		;player is fighting (93; 94 has no fights)
glitch equ $65		;counter to eliminate quick frame changes (de-glitch graphics)
rostnum equ $6F
pnum equ $66		;player's team location number
aioff equ $6A		;offense rating
aidef equ $6B		;defense rating
spodds equ $70
weight equ $67
shotspd equ $6C
stickhand equ $71
handed equ $76		;bit0 set is left handed

;bit numbers in gmode
gmclock equ 0		;game clock is stopped
gmdir equ 1		;0 = home team goes up
gmpen equ 2		;penalty has been called
gmpendel equ 3		;delayed penalty has been called
gmhl equ 4		;hilight mode
gmoffs equ 5		;offsides on
;bit numbers in disflags
dfok equ 0		;graphics are ready for transfer
df32c equ 1		;32 column mode on
dfng equ 2		;don't int graphics
dfclock equ 3		;clock needs update
;bit numbers in sflags
sfpz equ 0		;pause mode
sfspdir equ 2		;set pass dir mode
sfssdir equ 3		;set shot dir mode
sfslock equ 6		;scroll lock to xc1/yc1
sfscrl equ 5		;replay scroll is manual cont
sfwrap equ 4		;replay has wrapped around
sfhor equ 7		;screen is in horizontal mode
;bit numbers in sflags2
sf2faceoff equ 0		;face off in progress
sf2drec equ 2		;disable replay record
sf2replay equ 3		;replay in progress
sf2shot equ 4		;shot was taken
sf2pwrplay equ 5		;power play in progress
sf2pwrtm equ 6		;0 for team 1 in power play
sf2offsig equ 7		;offsides little ref on
sf3rmplay equ 1		;play mode on for replay (sflags3)

;team variables (HmShots / AwShots = the home / away team struct). 94 names; setup95_01 confirms these 95 values
tmscore equ $C		;score
tmline equ $16		;current line
tmap equ $24		;active players on ice 4-6
tmdata equ $1E		;team data address
tmsort equ $22		;address of first sort obj (word)
tmgoalie equ $26		;goalie 1/2/none
tmpde equ $34		;energy level of each roster player (94: $32)
tmpdst equ $68		;-2=bench/-1=ice/0+=penalty box (94: $66)
tmflags equ $30		;flags
tmsize equ $366		;94: $364
