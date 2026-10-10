	include	macros\genesis.mac	;String (main95.asm includes it in the full build)
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
;
;	checks95_01 segment stub. Retail $07F97E-$0807EB.
;
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

; .region code
	org	$7F97E

; includes for stubs to replace removed code
	include	stubinc\ports.inc	;IO_* / VDP_* ports
	include	stubinc\equals.inc	;VDP status bits
	include	stubinc\ram_addrs.inc	;RAM names

; External addresses outside $07F97E-$0807EB, read from lst/nhl95.bin.
setc1player = $AD80		;IDA: loc_AD80. used at $7FA1E (setup95_01)
setc2player = $AD8A		;IDA: loc_AD8A. used at $7FA5A (setup95_01)
sfx = $677AC			;IDA: sub_677AC. used at $7FDEA (sound95_01)
dobitmap = $79A3C		;IDA: sub_79A3C. used at $7FCAA (video95_01)
rtss2 = $79CC8			;IDA: locret_79CC8. used at $7FCFC. asstab entry 0, the shared rts (video95_01)
WaitVSyncAndReadInput = $7A79C	;IDA dc.b, no label. used at $7FA94 (collide95_01)
sroot = $7C512			;IDA: sub_7C512. used at $8021A (video95_03)
vtoa = $7C586			;IDA: sub_7C586. used at $800FE, $801B4, $80352, $80482 (video95_03)
randomd0 = $7C63A		;IDA: sub_7C63A. used at $7FE6C, $80654 (video95_03)
printz2 = $7C6D4		;IDA: sub_7C6D4. used at $7FB2A, $7FB4E, $7FBB4 (video95_03)
printsmall = $7C6E6		;IDA: sub_7C6E6. used at $7FB84, $7FBDA (video95_03)
printz = $7C810			;IDA: sub_7C810. used at $7FC08, $7FC40 (video95_03)
loadTeamStruct = $7CAF0		;IDA: sub_7CAF0. used at $7FD9A (video95_03)
ReadAttributeNibble = $7CB4E	;IDA: sub_7CB4E. used at $7FA72 (video95_03)
GetTempPlayerNameAttrib = $7CCD2	;IDA: sub_7CCD2. used at $7FB78 (video95_03)
waitx = $7D706			;IDA: sub_7D706. used at $7FBF4 (video95_03)
RestoreTeamEnergy = $7DB7C	;IDA dc.b, no label. used at $7FBE2, $7FBEC (video95_03)
RedrawMenu = $7E540		;no IDA label (inside loc_7E536). used at $7F99E, $7F9AE, $7FAFC, $7FBFE. DrawMenuScreen after the draw routine: print the items and fade in (menu95)
ClearMenuBox = $7F020		;IDA: sub_7F020. used at $7FA6E, $7FAF8, $7FB9C, $7FBFA (menu95)
assdefd = $807EC		;no IDA label. asstab entry 7, used at $7FD18 (assign95_01)
asswingd = $809FE		;no IDA label. asstab entry 8, used at $7FD1C (assign95_01)
asswingo = $80BEA		;no IDA label. asstab entry 9, used at $7FD20 (checks95_02)
asscenterd = $80D64		;no IDA label. asstab entry $A, used at $7FD24 (checks95_02)
asscentero = $80EF2		;no IDA label. asstab entry $B, used at $7FD28 (checks95_02)
assdefo = $81024		;no IDA label. asstab entry $C, used at $7FD2C. 95 starts with bclr #7,$64(a3) (checks95_02)
assfight = $8121E		;no IDA label. asstab entry $19, used at $7FD60. An rts (94 assfight and assfwatch are rts only) (checks95_02)
pucknorm = $81220		;no IDA label. asstab entry 1, used at $7FD00 (checks95_02)
puckunflip = $8130C		;no IDA label. asstab entry 5, used at $7FD10 (checks95_02)
puckshadow = $81352		;no IDA label. asstab entry 2, used at $7FD04 (checks95_02)
assexit = $8155E		;IDA: sub_8155E. used at $8075C, $80766, $807A2, $807B8, $807D8, $807E4 (checks95_02)
assinsert = $81570		;IDA: sub_81570. used at $7FFBC, $803F8 (checks95_02)
skateto = $8162C		;no IDA label. used at $7FF02, $7FF08 (checks95_02)
asspassrec = $81958		;no IDA label. asstab entry $D, used at $7FD30 (checks95_02)
rtsskate = $81A5C		;IDA: locret_81A5C. used at $7FE92, $7FEEA, $7FF12, $7FF3C, $8042C. The second rts after SkateToTempTarget; 94 branched to rtss2 here (checks95_02)
assbreakaway = $81A5E		;no IDA label. asstab entry $21, used at $7FD80 (checks95_02)
assnearest = $81A84		;no IDA label. asstab entry $E, used at $7FD34 (checks95_02)
skatetopuck = $81E5E		;no IDA label. used at $807E8 (checks95_02)
chkpuckc = $8213C		;no IDA label. asstab entry $1E, used at $7FD74 (checks95_02)
asspuckc = $82166		;no IDA label. asstab entry $F, used at $7FD38 (checks95_02)
chk4pass = $82638		;no IDA label. used at $80082 (checks95_02)
check4bench = $82790		;no IDA label. used at $7FE96, $8076A (checks95_02)
assbench = $8282E		;no IDA label. asstab entry $12, used at $7FD44 (assign95_02)
asspenalty = $829A6		;no IDA label. asstab entry $15, used at $7FD50 (assign95_02)
assdopen = $82B0A		;no IDA label. asstab entry $17, used at $7FD58 (assign95_02)
assepen = $82B3E		;no IDA label. asstab entry $16, used at $7FD54 (assign95_02)
assonetimer = $82BD0		;no IDA label. asstab entry $18, used at $7FD5C (onetimer95)
assshoot = $82FC2		;no IDA label. asstab entry $1A, used at $7FD64 (checks95_03)
assgoaliectrl = $82FFA		;no IDA label. asstab entry $1B, used at $7FD68, $7FDAA (checks95_03)
asseben = $831AC		;no IDA label. asstab entry $13, used at $7FD48 (checks95_03)
assscore = $83452		;no IDA label. asstab entry $1C, used at $7FD6C (checks95_03)
assgoaliebreakwait = $8356C	;no IDA label. asstab entry $1D, used at $7FD70 (checks95_03)
SetPersonel = $836CC		;IDA: sub_836CC. used at $7FAEA (checks95_03)
puckfaceoff = $883C8		;no IDA label. asstab entry 3, used at $7FD08 (checks95_04)
puckfaceoff2 = $886AE		;no IDA label. asstab entry 4, used at $7FD0C (checks95_04)
assfaceoff = $88AF6		;no IDA label. asstab entry $10, used at $7FD3C (checks95_04)
assfaceoffp1 = $88B0C		;no IDA label. asstab entry $11, used at $7FD40 (checks95_04)
AddPenalty2 = $8916E		;IDA: sub_8916E. used at $7FF7E (penalty95)
GoalieReadySPA = $8B9A8	;IDA: sub_8B9A8. used at $7FF20. 95 only: d1 = the goalie ready animation by the puck distance (input95_03)
stopna = $8BB1A			;IDA: sub_8BB1A. used at $8036A (checks95_06)
SetSPA = $8BC9A			;IDA: sub_8BC9A. used at $7FE80, $7FF26, $80112, $80710 (checks95_06)
playeracc = $8C086		;IDA: loc_8C086. used at $80370 (checks95_06)
puckshootout = $9E5F0		;no IDA label. asstab entry $1F, used at $7FD78 (checks95_07)
puckpenshot = $9E8E0		;no IDA label. asstab entry $20, used at $7FD7C (checks95_07)
ClockDigitsBitmap = $13FC18	;IDA: unk_13FC18. used at $7FC82 (graphics95_01)

; Main segment code
	include	checks95_01.asm
