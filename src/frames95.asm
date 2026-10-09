;	NHL 95 sprite animation tables (92 / 93 Frames.asm, 94 frames94.asm), then revframetbl. Retail $005A34-$008DD7 (13220 bytes),
;	from lst/nhl95.bin.lst (all dc.b there).
;	SPAlist is a word, then one table per animation. A table is 8 direction offsets (from .t), a flag word, then
;	frame,time word pairs per direction; a negative time ends the direction. SPA<name> is the table offset from
;	SPAlist, which the code uses (movea.l #SPAlist,a0 is $5A34). 95 has 78 tables (94: 66) in a new order and new frame
;	numbers (frames 1-1055; 94: 1-837). Most player animations have a second table for the puck carrier (SCnum =
;	word_FFB3C2), named with the 94 wp (with puck) suffix. Each table's comment gives the 94 table and the 95 code that
;	uses it. A direction can hold more than one terminated sequence; the extra pairs are not reached through .t.
;	The frames are written as numbers: the 95 SPF bases (94 SPFskatewp ...) are not confirmed yet.

SPAlist	;$5A34. 94 name. movea.l #SPAlist (IDA #$5A34) in the replay and input code
	dc.w	0

SPAskate	=	*-SPAlist	; $0002. 94 SPAskate ($5D0): noturn0 (IDA $8C014) move.w #2,d1. Table 0 in 95 (94 put gready here)
SPAskate_table:	;$5A36. Frames 1-330
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	$1003

.0	dc.w	1,8,2,8,3,8,4,8,5,8,6,8,7,8,8,8
	dc.w	1,7,2,7,3,7,4,7,5,7,6,7,7,7,8,7
	dc.w	267,6,268,6,269,6,270,6,271,6,272,6,273,6,274,-6
.1	dc.w	9,8,10,8,11,8,12,8,13,8,14,8,15,8,16,8
	dc.w	9,7,10,7,11,7,12,7,13,7,14,7,15,7,16,7
	dc.w	275,6,276,6,277,6,278,6,279,6,280,6,281,6,282,-6
.2	dc.w	17,8,18,8,19,8,20,8,21,8,22,8,23,8,24,8
	dc.w	17,7,18,7,19,7,20,7,21,7,22,7,23,7,24,7
	dc.w	283,6,284,6,285,6,286,6,287,6,288,6,289,6,290,-6
.3	dc.w	25,8,26,8,27,8,28,8,29,8,30,8,31,8,32,8
	dc.w	25,7,26,7,27,7,28,7,29,7,30,7,31,7,32,7
	dc.w	291,6,292,6,293,6,294,6,295,6,296,6,297,6,298,-6
.4	dc.w	33,8,34,8,35,8,36,8,37,8,38,8,39,8,40,8
	dc.w	33,7,34,7,35,7,36,7,37,7,38,7,39,7,40,7
	dc.w	299,6,300,6,301,6,302,6,303,6,304,6,305,6,306,-6
.5	dc.w	41,4,42,4,43,4,44,4,45,4,46,4,47,4,48,4
	dc.w	41,7,42,7,43,7,44,7,45,7,46,7,47,7,48,7
	dc.w	307,6,308,6,309,6,310,6,311,6,312,6,313,6,314,-6
.6	dc.w	49,4,50,4,51,4,52,4,53,4,54,4,55,4,56,4
	dc.w	49,7,50,7,51,7,52,7,53,7,54,7,55,7,56,7
	dc.w	315,6,316,6,317,6,318,6,319,6,320,6,321,6,322,-6
.7	dc.w	57,4,58,4,59,4,60,4,61,4,62,4,63,4,64,4
	dc.w	57,7,58,7,59,7,60,7,61,7,62,7,63,7,64,7
	dc.w	323,6,324,6,325,6,326,6,327,6,328,6,329,6,330,-6

SPAskateturn	=	*-SPAlist	; $0314. 95 only. noturn0 (IDA loc_8C066) sets it in place of the skate tables when the current SPA is a turn
SPAskateturn_table:	;$5D48. Frames 267-330
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	267,6,268,6,269,6,270,6,271,6,272,6,273,6,274,-6
.1	dc.w	275,6,276,6,277,6,278,6,279,6,280,6,281,6,282,-6
.2	dc.w	283,6,284,6,285,6,286,6,287,6,288,6,289,6,290,-6
.3	dc.w	291,6,292,6,293,6,294,6,295,6,296,6,297,6,298,-6
.4	dc.w	299,6,300,6,301,6,302,6,303,6,304,6,305,6,306,-6
.5	dc.w	307,6,308,6,309,6,310,6,311,6,312,6,313,6,314,-6
.6	dc.w	315,6,316,6,317,6,318,6,319,6,320,6,321,6,322,-6
.7	dc.w	323,6,324,6,325,6,326,6,327,6,328,6,329,6,330,-6

SPAskate2	=	*-SPAlist	; $0426. 95 only. noturn0 (IDA $8C022) uses it in place of SPAskate when word_FFBEF2 bit 7 is set
SPAskate2_table:	;$5E5A. Frames 1-64
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	1,8,2,8,3,8,4,8,5,8,6,8,7,8,8,8
	dc.w	1,7,2,7,3,7,4,7,5,7,6,7,7,7,8,7
	dc.w	1,6,2,6,3,6,4,6,5,6,6,6,7,6,8,-6
.1	dc.w	9,8,10,8,11,8,12,8,13,8,14,8,15,8,16,8
	dc.w	9,7,10,7,11,7,12,7,13,7,14,7,15,7,16,7
	dc.w	9,6,10,6,11,6,12,6,13,6,14,6,15,6,16,-6
.2	dc.w	17,8,18,8,19,8,20,8,21,8,22,8,23,8,24,8
	dc.w	17,7,18,7,19,7,20,7,21,7,22,7,23,7,24,7
	dc.w	17,6,18,6,19,6,20,6,21,6,22,6,23,6,24,-6
.3	dc.w	25,8,26,8,27,8,28,8,29,8,30,8,31,8,32,8
	dc.w	25,7,26,7,27,7,28,7,29,7,30,7,31,7,32,7
	dc.w	25,6,26,6,27,6,28,6,29,6,30,6,31,6,32,-6
.4	dc.w	33,8,34,8,35,8,36,8,37,8,38,8,39,8,40,8
	dc.w	33,7,34,7,35,7,36,7,37,7,38,7,39,7,40,7
	dc.w	33,6,34,6,35,6,36,6,37,6,38,6,39,6,40,-6
.5	dc.w	41,8,42,8,43,8,44,8,45,8,46,8,47,8,48,8
	dc.w	41,7,42,7,43,7,44,7,45,7,46,7,47,7,48,7
	dc.w	41,6,42,6,43,6,44,6,45,6,46,6,47,6,48,-6
.6	dc.w	49,8,50,8,51,8,52,8,53,8,54,8,55,8,56,8
	dc.w	49,7,50,7,51,7,52,7,53,7,54,7,55,7,56,7
	dc.w	49,6,50,6,51,6,52,6,53,6,54,6,55,6,56,-6
.7	dc.w	57,8,58,8,59,8,60,8,61,8,62,8,63,8,64,8
	dc.w	57,7,58,7,59,7,60,7,61,7,62,7,63,7,64,7
	dc.w	57,6,58,6,59,6,60,6,61,6,62,6,63,6,64,-6

SPAskatewp	=	*-SPAlist	; $0738. 94 SPAskatewp ($53E): noturn0 (IDA $8C03A) for the puck carrier. input burst (IDA loc_AADA) compares it
SPAskatewp_table:	;$616C. Frames 331-394
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	$1003

.0	dc.w	331,8,332,8,333,8,334,8,335,8,336,8,337,8,338,8
	dc.w	331,7,332,7,333,7,334,7,335,7,336,7,337,7,338,7
	dc.w	331,6,332,6,333,6,334,6,335,6,336,6,337,6,338,-6
.1	dc.w	339,8,340,8,341,8,342,8,343,8,344,8,345,8,346,8
	dc.w	339,7,340,7,341,7,342,7,343,7,344,7,345,7,346,7
	dc.w	339,6,340,6,341,6,342,6,343,6,344,6,345,6,346,-6
.2	dc.w	347,8,348,8,349,8,350,8,351,8,352,8,353,8,354,8
	dc.w	347,7,348,7,349,7,350,7,351,7,352,7,353,7,354,7
	dc.w	347,6,348,6,349,6,350,6,351,6,352,6,353,6,354,-6
.3	dc.w	355,8,356,8,357,8,358,8,359,8,360,8,361,8,362,8
	dc.w	355,7,356,7,357,7,358,7,359,7,360,7,361,7,362,7
	dc.w	355,6,356,6,357,6,358,6,359,6,360,6,361,6,362,-6
.4	dc.w	363,8,364,8,365,8,366,8,367,8,368,8,369,8,370,8
	dc.w	363,7,364,7,365,7,366,7,367,7,368,7,369,7,370,7
	dc.w	363,6,364,6,365,6,366,6,367,6,368,6,369,6,370,-6
.5	dc.w	371,8,372,8,373,8,374,8,375,8,376,8,377,8,378,8
	dc.w	371,7,372,7,373,7,374,7,375,7,376,7,377,7,378,7
	dc.w	371,6,372,6,373,6,374,6,375,6,376,6,377,6,378,-6
.6	dc.w	379,8,380,8,381,8,382,8,383,8,384,8,385,8,386,8
	dc.w	379,7,380,7,381,7,382,7,383,7,384,7,385,7,386,7
	dc.w	379,6,380,6,381,6,382,6,383,6,384,6,385,6,386,-6
.7	dc.w	387,8,388,8,389,8,390,8,391,8,392,8,393,8,394,8
	dc.w	387,7,388,7,389,7,390,7,391,7,392,7,393,7,394,7
	dc.w	387,6,388,6,389,6,390,6,391,6,392,6,393,6,394,-6

SPAskatewp2	=	*-SPAlist	; $0A4A. 95 only. No reference found; frames 331-394 as SPAskatewp (the with puck partner of SPAskate2)
SPAskatewp2_table:	;$647E. Frames 331-394
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	331,6,332,6,333,6,334,6,335,6,336,6,337,6,338,-6
.1	dc.w	339,6,340,6,341,6,342,6,343,6,344,6,345,6,346,-6
.2	dc.w	347,6,348,6,349,6,350,6,351,6,352,6,353,6,354,-6
.3	dc.w	355,6,356,6,357,6,358,6,359,6,360,6,361,6,362,-6
.4	dc.w	363,6,364,6,365,6,366,6,367,6,368,6,369,6,370,-6
.5	dc.w	371,6,372,6,373,6,374,6,375,6,376,6,377,6,378,-6
.6	dc.w	379,6,380,6,381,6,382,6,383,6,384,6,385,6,386,-6
.7	dc.w	387,6,388,6,389,6,390,6,391,6,392,6,393,6,394,-6

SPAglide	=	*-SPAlist	; $0B5C. 94 SPAglide ($50C): doplayeracc, dostop
SPAglide_table:	;$6590. Frames 65-72
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	65,-8
.1	dc.w	66,-8
.2	dc.w	67,-8
.3	dc.w	68,-8
.4	dc.w	69,-8
.5	dc.w	70,-8
.6	dc.w	71,-8
.7	dc.w	72,-8

SPAglidewp	=	*-SPAlist	; $0B8E. 95 only. SPAglide for the puck carrier (SCnum = word_FFB3C2): doplayeracc, dostop, doshot
SPAglidewp_table:	;$65C2. Frames 395-402
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	395,-8
.1	dc.w	396,-8
.2	dc.w	397,-8
.3	dc.w	398,-8
.4	dc.w	399,-8
.5	dc.w	400,-8
.6	dc.w	401,-8
.7	dc.w	402,-8

SPAturnl	=	*-SPAlist	; $0BC0. 94 SPAturnl ($662): doplayeracc SPAturnr eori -$52
SPAturnl_table:	;$65F4. Frames 97-104
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	97,4,97,-4
.1	dc.w	98,4,98,-4
.2	dc.w	99,4,99,-4
.3	dc.w	100,4,100,-4
.4	dc.w	101,4,101,-4
.5	dc.w	102,4,102,-4
.6	dc.w	103,4,103,-4
.7	dc.w	104,4,104,-4

SPAturnr	=	*-SPAlist	; $0C12. 94 SPAturnr ($694): doplayeracc addi.w #SPAturnr
SPAturnr_table:	;$6646. Frames 89-96
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	89,4,89,-4
.1	dc.w	90,4,90,-4
.2	dc.w	91,4,91,-4
.3	dc.w	92,4,92,-4
.4	dc.w	93,4,93,-4
.5	dc.w	94,4,94,-4
.6	dc.w	95,4,95,-4
.7	dc.w	96,4,96,-4

SPAturnlwp	=	*-SPAlist	; $0C64. 95 only. SPAturnl + $A4 for the puck carrier (doplayeracc)
SPAturnlwp_table:	;$6698. Frames 427-434
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	427,4,427,-4
.1	dc.w	428,4,428,-4
.2	dc.w	429,4,429,-4
.3	dc.w	430,4,430,-4
.4	dc.w	431,4,431,-4
.5	dc.w	432,4,432,-4
.6	dc.w	433,4,433,-4
.7	dc.w	434,4,434,-4

SPAturnrwp	=	*-SPAlist	; $0CB6. 95 only. SPAturnr + $A4 for the puck carrier (doplayeracc)
SPAturnrwp_table:	;$66EA. Frames 419-426
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	419,4,419,-4
.1	dc.w	420,4,420,-4
.2	dc.w	421,4,421,-4
.3	dc.w	422,4,422,-4
.4	dc.w	423,4,423,-4
.5	dc.w	424,4,424,-4
.6	dc.w	425,4,425,-4
.7	dc.w	426,4,426,-4

SPAstop	=	*-SPAlist	; $0D08. 94 SPAstop ($6C6): dostop
SPAstop_table:	;$673C. Frames 73-88
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	$103

.0	dc.w	73,4,74,-4
.1	dc.w	75,4,76,-4
.2	dc.w	77,4,78,-4
.3	dc.w	79,4,80,-4
.4	dc.w	81,4,82,-4
.5	dc.w	83,4,84,-4
.6	dc.w	85,4,86,-4
.7	dc.w	87,4,88,-4

SPAstopwp	=	*-SPAlist	; $0D5A. 95 only. SPAstop for the puck carrier (dostop)
SPAstopwp_table:	;$678E. Frames 403-418
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	$103

.0	dc.w	403,4,404,-4
.1	dc.w	405,4,406,-4
.2	dc.w	407,4,408,-4
.3	dc.w	409,4,410,-4
.4	dc.w	411,4,412,-4
.5	dc.w	413,4,414,-4
.6	dc.w	415,4,416,-4
.7	dc.w	417,4,418,-4

SPAshoulderchkl	=	*-SPAlist	; $0DAC. 94 SPAshoulderchkl ($B96). checkinglist ($7AF06) uses it for the 94 shoulderchkl and hipchkl slots
SPAshoulderchkl_table:	;$67E0. Frames 123-130
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	123,-24
.1	dc.w	124,-24
.2	dc.w	125,-24
.3	dc.w	126,-24
.4	dc.w	127,-24
.5	dc.w	128,-24
.6	dc.w	129,-24
.7	dc.w	130,-24

SPAshoulderchkr	=	*-SPAlist	; $0DDE. 94 SPAshoulderchkr ($BC8). checkinglist ($7AF06) uses it for the 94 shoulderchkr and hipchkr slots
SPAshoulderchkr_table:	;$6812. Frames 131-138
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	131,-24
.1	dc.w	132,-24
.2	dc.w	133,-24
.3	dc.w	134,-24
.4	dc.w	135,-24
.5	dc.w	136,-24
.6	dc.w	137,-24
.7	dc.w	138,-24

SPAHold	=	*-SPAlist	; $0E10. 94 SPAHold ($C90): Acheck, holdcheck, CCStart
SPAHold_table:	;$6844. Frames 155-162
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	155,-30
.1	dc.w	156,-30
.2	dc.w	157,-30
.3	dc.w	158,-30
.4	dc.w	159,-30
.5	dc.w	160,-30
.6	dc.w	161,-30
.7	dc.w	162,-30

SPAHold2	=	*-SPAlist	; $0E42. 94 SPAHold2 ($CC2): holdcheck
SPAHold2_table:	;$6876. Frames 155-162
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	155,-55
.1	dc.w	156,-55
.2	dc.w	157,-55
.3	dc.w	158,-55
.4	dc.w	159,-55
.5	dc.w	160,-55
.6	dc.w	161,-55
.7	dc.w	162,-55

SPAhook	=	*-SPAlist	; $0E74. 94 SPAhook ($1122): holdplayer, Acheck, CCStart
SPAhook_table:	;$68A8. Frames 139-153
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	139,-30
.1	dc.w	141,-30
.2	dc.w	143,-30
.3	dc.w	145,-30
.4	dc.w	147,-30
.5	dc.w	149,-30
.6	dc.w	151,-30
.7	dc.w	153,-30

SPAhook2	=	*-SPAlist	; $0EA6. 94 SPAhook2 ($1154): holdcheck
SPAhook2_table:	;$68DA. Frames 139-154
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	139,12,140,12,139,12,140,-12
.1	dc.w	141,12,142,12,141,12,142,-12
.2	dc.w	143,12,144,12,143,12,144,-12
.3	dc.w	145,12,146,12,145,12,146,-12
.4	dc.w	147,12,148,12,147,12,148,-12
.5	dc.w	149,12,150,12,149,12,150,-12
.6	dc.w	151,12,152,12,151,12,152,-12
.7	dc.w	153,12,154,12,153,12,154,-12

SPAsweepchk	=	*-SPAlist	; $0F38. 94 SPAsweepchk ($B24): CCStart, B check
SPAsweepchk_table:	;$696C. Frames 163-178
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	163,4,164,8,163,-4
.1	dc.w	165,4,166,8,165,-4
.2	dc.w	167,4,168,8,167,-4
.3	dc.w	169,4,170,8,169,-4
.4	dc.w	171,4,172,8,171,-4
.5	dc.w	173,4,174,8,173,-4
.6	dc.w	175,4,176,8,175,-4
.7	dc.w	177,4,178,8,177,-4

SPAfallfwd	=	*-SPAlist	; $0FAA. 94 SPAfallfwd ($D26): FallDown
SPAfallfwd_table:	;$69DE. Frames 65-226
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	179,6,180,6,181,8,182,100,183,8,184,8,65,-8
.1	dc.w	185,6,186,6,187,8,188,100,189,8,190,8,66,-8
.2	dc.w	191,6,192,6,193,8,194,100,195,8,196,8,67,-8
.3	dc.w	197,6,198,6,199,8,200,100,201,8,202,8,68,-8
.4	dc.w	203,6,204,6,205,8,206,100,207,8,208,8,69,-8
.5	dc.w	209,6,210,6,211,8,212,100,213,8,214,8,70,-8
.6	dc.w	215,6,216,6,217,8,218,100,219,8,220,8,71,-8
.7	dc.w	221,6,222,6,223,8,224,100,225,8,226,8,72,-8

SPAfallback	=	*-SPAlist	; $109C. 94 SPAfallback ($DD8): FallDown
SPAfallback_table:	;$6AD0. Frames 65-266
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	227,6,228,6,229,8,230,100,231,8,207,8,208,8,69,-8
.1	dc.w	232,6,233,6,234,8,235,100,236,8,213,8,214,8,70,-8
.2	dc.w	237,6,238,6,239,8,240,100,241,8,219,8,220,8,71,-8
.3	dc.w	242,6,243,6,244,8,245,100,246,8,225,8,226,8,72,-8
.4	dc.w	247,6,248,6,249,8,250,100,251,8,183,8,184,8,65,-8
.5	dc.w	252,6,253,6,254,8,255,100,256,8,189,8,190,8,66,-8
.6	dc.w	257,6,258,6,259,8,260,100,261,8,195,8,196,8,67,-8
.7	dc.w	262,6,263,6,264,8,265,100,266,8,201,8,202,8,68,-8

SPAburst	=	*-SPAlist	; $11AE. 94 SPAburst ($C5E): burst (IDA loc_AAFE), CCStart
SPAburst_table:	;$6BE2. Frames 267-330
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	267,3,268,3,269,3,270,3,271,-3,272,3,273,3,274,-3
.1	dc.w	275,3,276,3,277,3,278,3,279,-3,280,3,281,3,282,-3
.2	dc.w	283,3,284,3,285,3,286,3,287,-3,288,3,289,3,290,-3
.3	dc.w	291,3,292,3,293,3,294,3,295,-3,296,3,297,3,298,-3
.4	dc.w	299,3,300,3,301,3,302,3,303,-3,304,3,305,3,306,-3
.5	dc.w	307,3,308,3,309,3,310,3,311,-3,312,3,313,3,314,-3
.6	dc.w	315,3,316,3,317,3,318,3,319,-3,320,3,321,3,322,-3
.7	dc.w	323,3,324,3,325,3,326,3,327,-3,328,3,329,3,330,-3

SPApflip	=	*-SPAlist	; $12C0. 94 SPApflip ($46A): puckflip
SPApflip_table:	;$6CF4. Frames 436-445
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1

.0	dc.w	437,4,438,4,439,4,440,4,441,4,438,4,442,4,436,-4
.1	dc.w	444,2,436,2,443,2,440,2,445,2,440,2,443,2,436,-2
.2	dc.w	439,2,438,2,437,2,436,2,442,2,438,2,441,2,440,-2
.3	dc.w	443,4,436,4,444,4,436,4,443,4,440,4,445,4,440,-4
.4	dc.w	436,-4096
.5	dc.w	436,-4096
.6	dc.w	440,-4096
.7	dc.w	440,-4096

SPApassf	=	*-SPAlist	; $1362. 94 SPApassf ($718): dopass
SPApassf_table:	;$6D96. Frames 451-495
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	451,4,452,4,453,-20
.1	dc.w	457,4,458,4,459,-20
.2	dc.w	463,4,464,4,465,-20
.3	dc.w	469,4,470,4,471,-20
.4	dc.w	475,4,476,4,477,-20
.5	dc.w	481,4,482,4,483,-20
.6	dc.w	487,4,488,4,489,-20
.7	dc.w	493,4,494,4,495,-20

SPApassf2	=	*-SPAlist	; $13D4. 95 only. dopass uses it in place of SPApassf when byte_FFBF08 bit 1 is set
SPApassf2_table:	;$6E08. Frames 450-493
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	450,4,451,-20
.1	dc.w	456,4,457,-20
.2	dc.w	462,4,463,-20
.3	dc.w	468,4,469,-20
.4	dc.w	474,4,475,-20
.5	dc.w	480,4,481,-20
.6	dc.w	486,4,487,-20
.7	dc.w	492,4,493,-20

SPApassb	=	*-SPAlist	; $1426. 94 SPApassb ($78A): dopass after Findhittype
SPApassb_table:	;$6E5A. Frames 576-599
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	576,4,577,4,578,-20
.1	dc.w	579,4,580,4,581,-20
.2	dc.w	582,4,583,4,584,-20
.3	dc.w	585,4,586,4,587,-20
.4	dc.w	588,4,589,4,590,-20
.5	dc.w	591,4,592,4,593,-20
.6	dc.w	594,4,595,4,596,-20
.7	dc.w	597,4,598,4,599,-20

SPApassb2	=	*-SPAlist	; $1498. 95 only. dopass uses it in place of SPApassb when byte_FFBF08 bit 1 is set
SPApassb2_table:	;$6ECC. Frames 576-598
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	576,4,577,4,577,-10
.1	dc.w	579,4,580,4,580,-10
.2	dc.w	582,4,583,4,583,-10
.3	dc.w	585,4,586,4,586,-10
.4	dc.w	588,4,589,4,589,-10
.5	dc.w	591,4,592,4,592,-10
.6	dc.w	594,4,595,4,595,-10
.7	dc.w	597,4,598,4,598,-10

SPAshotf	=	*-SPAlist	; $150A. 94 SPAshotf ($7FC): SetShotMode
SPAshotf_table:	;$6F3E. Frames 448-495
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	450,4,449,4,448,4,448,4,449,4,450,4,451,4,452,4
	dc.w	453,-20
.1	dc.w	456,4,455,4,454,4,454,4,455,4,456,4,457,4,458,4
	dc.w	459,-20
.2	dc.w	462,4,461,4,460,4,460,4,461,4,462,4,463,4,464,4
	dc.w	465,-20
.3	dc.w	468,4,467,4,466,4,466,4,467,4,468,4,469,4,470,4
	dc.w	471,-20
.4	dc.w	474,4,473,4,472,4,472,4,473,4,474,4,475,4,476,4
	dc.w	477,-20
.5	dc.w	480,4,479,4,478,4,478,4,479,4,480,4,481,4,482,4
	dc.w	483,-20
.6	dc.w	486,4,485,4,484,4,484,4,485,4,486,4,487,4,488,4
	dc.w	489,-20
.7	dc.w	492,4,491,4,490,4,490,4,491,4,492,4,493,4,494,4
	dc.w	495,-20

SPAshotf2	=	*-SPAlist	; $163C. 95 only. SetShotMode uses it in place of SPAshotf when byte_FFBF08 bit 0 is set
SPAshotf2_table:	;$7070. Frames 448-495
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	450,3,449,3,448,3,448,3,449,3,450,3,451,3,452,3
	dc.w	453,-8
.1	dc.w	456,3,455,3,454,3,454,3,455,3,456,3,457,3,458,3
	dc.w	459,-8
.2	dc.w	462,3,461,3,460,3,460,3,461,3,462,3,463,3,464,3
	dc.w	465,-8
.3	dc.w	468,3,467,3,466,3,466,3,467,3,468,3,469,3,470,3
	dc.w	471,-8
.4	dc.w	474,3,473,3,472,3,472,3,473,3,474,3,475,3,476,3
	dc.w	477,-8
.5	dc.w	480,3,479,3,478,3,478,3,479,3,480,3,481,3,482,3
	dc.w	483,-8
.6	dc.w	486,3,485,3,484,3,484,3,485,3,486,3,487,3,488,3
	dc.w	489,-8
.7	dc.w	492,3,491,3,490,3,490,3,491,3,492,3,493,3,494,3
	dc.w	495,-8

SPAshotb	=	*-SPAlist	; $176E. 94 SPAshotb ($92E): SetShotMode, doshot
SPAshotb_table:	;$71A2. Frames 576-599
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	576,2,576,2,576,2,576,2,576,2,576,2,577,2,578,2
	dc.w	578,-10
.1	dc.w	579,2,579,2,579,2,579,2,579,2,579,2,580,2,581,2
	dc.w	581,-10
.2	dc.w	582,2,582,2,582,2,582,2,582,2,582,2,583,2,584,2
	dc.w	584,-10
.3	dc.w	585,2,585,2,585,2,585,2,585,2,585,2,586,2,587,2
	dc.w	587,-10
.4	dc.w	588,2,588,2,588,2,588,2,588,2,588,2,589,2,590,2
	dc.w	590,-10
.5	dc.w	591,2,591,2,591,2,591,2,591,2,591,2,592,2,593,2
	dc.w	593,-10
.6	dc.w	594,2,594,2,594,2,594,2,594,2,594,2,595,2,596,2
	dc.w	596,-10
.7	dc.w	597,2,597,2,597,2,597,2,597,2,597,2,598,2,599,2
	dc.w	599,-10

SPAshotb2	=	*-SPAlist	; $18A0. 95 only. SetShotMode uses it in place of SPAshotb when byte_FFBF08 bit 0 is set
SPAshotb2_table:	;$72D4. Frames 449-495
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	451,3,452,3,453,3,453,3,453,3,452,3,451,3,450,3
	dc.w	449,-8
.1	dc.w	457,3,458,3,459,3,459,3,459,3,458,3,457,3,456,3
	dc.w	455,-8
.2	dc.w	463,3,464,3,465,3,465,3,465,3,464,3,463,3,462,3
	dc.w	461,-8
.3	dc.w	469,3,470,3,471,3,471,3,471,3,470,3,469,3,468,3
	dc.w	467,-8
.4	dc.w	475,3,476,3,477,3,477,3,477,3,476,3,475,3,474,3
	dc.w	473,-8
.5	dc.w	481,3,482,3,483,3,483,3,483,3,482,3,481,3,480,3
	dc.w	479,-8
.6	dc.w	487,3,488,3,489,3,489,3,489,3,488,3,487,3,486,3
	dc.w	485,-8
.7	dc.w	493,3,494,3,495,3,495,3,495,3,494,3,493,3,492,3
	dc.w	491,-8

SPAskateback	=	*-SPAlist	; $19D2. 94 SPAskateback ($A92): noturn0 when skating backwards
SPAskateback_table:	;$7406. Frames 496-543
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	496,8,497,8,498,8,499,8,500,8,501,-8
.1	dc.w	502,8,503,8,504,8,505,8,506,8,507,-8
.2	dc.w	508,8,509,8,510,8,511,8,512,8,513,-8
.3	dc.w	514,8,515,8,516,8,517,8,518,8,519,-8
.4	dc.w	520,8,521,8,522,8,523,8,524,8,525,-8
.5	dc.w	526,8,527,8,528,8,529,8,530,8,531,-8
.6	dc.w	532,8,533,8,534,8,535,8,536,8,537,-8
.7	dc.w	538,8,539,8,540,8,541,8,542,8,543,-8

SPAstumble	=	*-SPAlist	; $1AA4. 94 SPAstumble ($11E6): FallDown
SPAstumble_table:	;$74D8. Frames 544-575
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	544,8,545,8,546,8,547,-6
.1	dc.w	548,8,549,8,550,8,551,-6
.2	dc.w	552,8,553,8,554,8,555,-6
.3	dc.w	556,8,557,8,558,8,559,-6
.4	dc.w	560,8,561,8,562,8,563,-6
.5	dc.w	564,8,565,8,566,8,567,-6
.6	dc.w	568,8,569,8,570,8,571,-6
.7	dc.w	572,8,573,8,574,8,575,-6

SPAfaceoff	=	*-SPAlist	; $1B36. 94 SPAfaceoff ($FEA): faceoffinput
SPAfaceoff_table:	;$756A. Frames 1050-1055
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	1050,2,1051,10,1052,-6
.1
.2
.3
.4
.5
.6
.7	dc.w	1053,2,1054,10,1055,-6

SPAfaceoffr	=	*-SPAlist	; $1B60. 94 SPAfaceoffr ($1014): faceoffinput
SPAfaceoffr_table:	;$7594. Frames 334-366
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	334,-5
.1
.2
.3
.4
.5
.6
.7	dc.w	366,-5

SPAgready	=	*-SPAlist	; $1B7A. 94 SPAgready ($2): the goalie ready anim (IDA sub_8B9A8) near the puck or when byte_FFBEF0 bit 0 is set
SPAgready_table:	;$75AE. Frames 606-921
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1

.0	dc.w	606,180,904,10,905,10,906,10,606,340,906,10,905,10,904,-10
.1	dc.w	607,180,907,10,908,10,909,10,607,340,909,10,908,10,907,-10
.2	dc.w	608,-700
.3	dc.w	609,180,910,10,911,10,912,10,609,340,912,10,911,10,910,-10
.4	dc.w	610,180,913,10,914,10,915,10,610,340,915,10,914,10,913,-10
.5	dc.w	611,180,916,10,917,10,918,10,611,340,918,10,917,10,916,-10
.6	dc.w	612,-700
.7	dc.w	613,180,919,10,920,10,921,10,613,340,921,10,920,10,919,-10

SPAgready2	=	*-SPAlist	; $1C54. 94 SPAgready2 ($114): the goalie ready anim (IDA sub_8B9A8) otherwise
SPAgready2_table:	;$7688. Frames 606-613
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1

.0	dc.w	606,-700
.1	dc.w	607,-700
.2	dc.w	608,-700
.3	dc.w	609,-700
.4	dc.w	610,-700
.5	dc.w	611,-700
.6	dc.w	612,-700
.7	dc.w	613,-700

SPAgglover	=	*-SPAlist	; $1C86. 94 SPAgglover ($146): goaliesave .saveanim 0 and 6
SPAgglover_table:	;$76BA. Frames 622-629
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	622,-32
.1	dc.w	623,-32
.2	dc.w	624,-32
.3	dc.w	625,-32
.4	dc.w	626,-32
.5	dc.w	627,-32
.6	dc.w	628,-32
.7	dc.w	629,-32

SPAgglovel	=	*-SPAlist	; $1CB8. 94 SPAgglovel ($178): goaliesave .saveanim 1 and 7
SPAgglovel_table:	;$76EC. Frames 614-621
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	614,-32
.1	dc.w	615,-32
.2	dc.w	616,-32
.3	dc.w	617,-32
.4	dc.w	618,-32
.5	dc.w	619,-32
.6	dc.w	620,-32
.7	dc.w	621,-32

SPAgstickr	=	*-SPAlist	; $1CEA. 94 SPAgstickr ($1EC): goaliesave .saveanim 4 and 8
SPAgstickr_table:	;$771E. Frames 638-645
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	638,-36
.1	dc.w	639,-36
.2	dc.w	640,-36
.3	dc.w	641,-36
.4	dc.w	642,-36
.5	dc.w	643,-36
.6	dc.w	644,-36
.7	dc.w	645,-36

SPAgstickl	=	*-SPAlist	; $1D1C. 94 SPAgstickl ($21E): goaliesave .saveanim 5 and 9
SPAgstickl_table:	;$7750. Frames 630-637
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	630,-36
.1	dc.w	631,-36
.2	dc.w	632,-36
.3	dc.w	633,-36
.4	dc.w	634,-36
.5	dc.w	635,-36
.6	dc.w	636,-36
.7	dc.w	637,-36

SPAgdive	=	*-SPAlist	; $1D4E. 94 SPAgdive ($2F4): doinput (IDA loc_8B6F8)
SPAgdive_table:	;$7782. Frames 646-669
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	646,8,647,8,648,48,646,-8
.1	dc.w	649,8,650,8,651,48,649,-8
.2	dc.w	652,8,653,8,654,48,652,-8
.3	dc.w	655,8,656,8,657,48,655,-8
.4	dc.w	658,8,659,8,660,48,658,-8
.5	dc.w	661,8,662,8,663,48,661,-8
.6	dc.w	664,8,665,8,666,48,664,-8
.7	dc.w	667,8,668,8,669,48,667,-8

SPAwallright	=	*-SPAlist	; $1DE0. 94 SPAwallright ($F6E): asspenalty (penalty box door)
SPAwallright_table:	;$7814. Frames 1005-1011
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2	dc.w	1005,8,1006,8,1007,8,1008,8,1009,8,1010,8,1011,-8
.3
.4
.5
.6
.7	dc.w	1011,8,1010,8,1009,8,1008,8,1007,8,1006,8,1005,-8

SPAwallleft	=	*-SPAlist	; $1E2A. 94 SPAwallleft ($FAC): assbench, asseben, assepen (penalty box door)
SPAwallleft_table:	;$785E. Frames 1005-1008
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2	dc.w	1008,8,1007,8,1006,8,1005,-8
.3
.4
.5
.6	dc.w	1005,8,1006,8,1007,8,1008,-8
.7	dc.w	1005,8,1006,8,1007,8,1008,-8

SPAcheckstart	=	*-SPAlist	; $1E6C. 95 only. Set by check4check (computer player checks) and IDA loc_8D3FC
SPAcheckstart_table:	;$78A0. Frames 183-697
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	674,4,675,4,676,40,225,8,184,-8
.1	dc.w	677,4,678,4,679,40,183,8,190,-8
.2	dc.w	680,4,681,4,682,40,189,8,196,-8
.3	dc.w	683,4,684,4,685,40,195,8,202,-8
.4	dc.w	686,4,687,4,688,40,201,8,208,-8
.5	dc.w	689,4,690,4,691,40,219,8,214,-8
.6	dc.w	692,4,693,4,694,40,225,8,220,-8
.7	dc.w	695,4,696,4,697,40,183,8,226,-8

SPAsiren	=	*-SPAlist	; $1F1E. 94 SPAsiren ($102E): checkgoal, on the struct after the goal (IDA loc_8C59A)
SPAsiren_table:	;$7952. Frames 698-711
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	1

.0
.1
.2
.3
.4
.5
.6
.7	dc.w	698,3,699,3,700,3,701,3,702,3,703,3,704,3,705,3
	dc.w	706,3,707,3,708,3,709,3,710,3,711,-3

SPAflail	=	*-SPAlist	; $1F68. 94 SPAflail ($CF4): holdcheck
SPAflail_table:	;$799C. Frames 1-36
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	1,-40
.1	dc.w	6,-40
.2	dc.w	11,-40
.3	dc.w	16,-40
.4	dc.w	21,-40
.5	dc.w	26,-40
.6	dc.w	31,-40
.7	dc.w	36,-40

SPAgswing	=	*-SPAlist	; $1F9A. 94 SPAgswing ($366): dopass for the goalie
SPAgswing_table:	;$79CE. Frames 736-751
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	736,5,737,8,736,-16
.1	dc.w	738,5,739,8,738,-16
.2	dc.w	740,5,741,8,740,-16
.3	dc.w	742,5,743,8,742,-16
.4	dc.w	744,5,745,8,744,-16
.5	dc.w	746,5,747,8,746,-16
.6	dc.w	748,5,749,8,748,-16
.7	dc.w	750,5,751,8,750,-16

SPAgstackl	=	*-SPAlist	; $200C. 94 SPAgstackl ($2A2): goaliesave .saveanim 3
SPAgstackl_table:	;$7A40. Frames 724-735
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	724,8,725,-32
.1	dc.w	726,8,727,-32
.2	dc.w	726,8,727,-32
.3	dc.w	728,8,729,-32
.4	dc.w	730,8,731,-32
.5	dc.w	732,8,733,-32
.6	dc.w	732,8,733,-32
.7	dc.w	734,8,735,-32

SPAgstackr	=	*-SPAlist	; $205E. 94 SPAgstackr ($250): goaliesave .saveanim 2
SPAgstackr_table:	;$7A92. Frames 712-723
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	712,8,713,-32
.1	dc.w	714,8,715,-32
.2	dc.w	714,8,715,-32
.3	dc.w	716,8,717,-32
.4	dc.w	718,8,719,-32
.5	dc.w	720,8,721,-32
.6	dc.w	720,8,721,-32
.7	dc.w	722,8,723,-32

SPAboardtop	=	*-SPAlist	; $20B0. 94 SPAboardtop ($1776): FallDown .FallList
SPAboardtop_table:	;$7AE4. Frames 183-766
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1	dc.w	752,6,753,6,754,6,755,60,231,8,207,32,208,-32
.2
.3	dc.w	756,6,757,6,758,6,195,68,196,-8
.4
.5	dc.w	760,6,761,6,762,6,763,60,251,6,183,6,184,-6
.6
.7	dc.w	764,6,765,6,766,6,219,68,220,-8

SPAboardright	=	*-SPAlist	; $2122. 94 SPAboardright ($17E8): FallDown .FallList
SPAboardright_table:	;$7B56. Frames 195-781
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1	dc.w	766,6,767,6,768,6,769,60,225,8,226,-8
.2
.3	dc.w	770,6,771,6,772,6,773,60,241,6,219,6,220,-6
.4
.5	dc.w	774,6,775,6,776,6,777,60,213,8,214,-8
.6
.7	dc.w	778,6,779,6,780,6,781,60,261,6,195,6,196,-6

SPAboardbot	=	*-SPAlist	; $219C. 94 SPAboardbot ($185A): FallDown .FallList
SPAboardbot_table:	;$7BD0. Frames 183-793
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1	dc.w	782,6,783,6,784,6,755,60,231,6,207,6,208,-6
.2
.3	dc.w	785,6,786,6,787,6,195,60,196,-8
.4
.5	dc.w	788,6,789,6,790,6,762,60,251,6,183,6,184,-6
.6
.7	dc.w	791,6,792,6,793,6,219,60,220,-8

SPAboardleft	=	*-SPAlist	; $220E. 94 SPAboardleft ($18CC): FallDown .FallList
SPAboardleft_table:	;$7C42. Frames 189-807
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1	dc.w	794,6,795,6,796,6,797,60,189,8,190,-8
.2
.3	dc.w	798,6,799,6,800,6,773,60,241,8,219,8,220,-8
.4
.5	dc.w	801,6,802,6,803,6,804,60,201,8,202,-8
.6
.7	dc.w	805,6,806,6,807,6,781,60,261,6,195,6,196,-6

SPAboardchk	=	*-SPAlist	; $2288. 94 SPAboardchk ($1AC2): FallDown, on the hitter
SPAboardchk_table:	;$7CBC. Frames 808-815
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	808,-24
.1	dc.w	809,-24
.2	dc.w	810,-24
.3	dc.w	811,-24
.4	dc.w	812,-24
.5	dc.w	813,-24
.6	dc.w	814,-24
.7	dc.w	815,-24

SPAgskate	=	*-SPAlist	; $22BA. 94 SPAgskate ($3D8): goalieacc
SPAgskate_table:	;$7CEE. Frames 852-875
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	852,12,853,8,854,12,853,-8
.1	dc.w	855,12,856,8,857,12,856,-8
.2	dc.w	858,12,859,8,860,12,859,-8
.3	dc.w	861,12,862,8,863,12,862,-8
.4	dc.w	864,12,865,8,866,12,865,-8
.5	dc.w	867,12,868,8,869,12,868,-8
.6	dc.w	870,12,871,8,872,12,871,-8
.7	dc.w	873,12,874,8,875,12,874,-8

SPAcelebrate	=	*-SPAlist	; $234C. 94 SPAcelebrate ($E8A): the 94 assscore step (IDA $83518)
SPAcelebrate_table:	;$7D80. Frames 836-851
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	836,12,837,40,836,-5
.1	dc.w	838,12,839,40,838,-5
.2	dc.w	840,12,841,40,840,-5
.3	dc.w	842,12,843,40,842,-5
.4	dc.w	844,12,845,40,844,-5
.5	dc.w	846,12,847,40,846,-5
.6	dc.w	848,12,849,40,848,-5
.7	dc.w	850,12,851,40,850,-5

SPAgstackalt1	=	*-SPAlist	; $23BE. 95 only. goaliesave: a pad stack save becomes this or SPAgstackalt2 (random) when word_FFBEF2 bit 3 is set
SPAgstackalt1_table:	;$7DF2. Frames 880-883
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.6
.7	dc.w	880,20,881,20,880,-8
.3
.4
.5	dc.w	882,20,883,20,882,-8

SPAgstackalt2	=	*-SPAlist	; $23E8. 95 only. goaliesave: see SPAgstackalt1
SPAgstackalt2_table:	;$7E1C. Frames 884-885
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.6
.7	dc.w	884,-40
.3
.4
.5	dc.w	885,-40

SPAcatch	=	*-SPAlist	; $2402. 94 SPAcatch ($10D0): puckbody
SPAcatch_table:	;$7E36. Frames 816-831
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	816,6,817,-6
.1	dc.w	818,6,819,-6
.2	dc.w	820,6,821,-6
.3	dc.w	822,6,823,-6
.4	dc.w	824,6,825,-6
.5	dc.w	826,6,827,-6
.6	dc.w	828,6,829,-6
.7	dc.w	830,6,831,-6

SPAinjuryfall	=	*-SPAlist	; $2454. 94 SPAinjuryfall ($145C): FallDown
SPAinjuryfall_table:	;$7E88. Frames 227-896
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	$303

.0
.1
.2
.7	dc.w	227,6,228,6,229,8,890,6,891,6,892,-6
.3
.4
.5
.6	dc.w	247,6,248,6,249,8,894,6,895,6,896,-6

SPAinjury1	=	*-SPAlist	; $2496. 94 SPAinjury1 ($1AF4): FallDown
SPAinjury1_table:	;$7ECA. Frames 227-896
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.7	dc.w	227,6,228,6,229,8,890,6,891,6,892,-1000
.3
.4
.5
.6	dc.w	247,6,248,6,249,8,894,6,895,6,896,-1000

SPAinjury2	=	*-SPAlist	; $24D8. 95 only. FallDown uses it in place of SPAinjury1 when byte_FFBF0E bit 1 is set
SPAinjury2_table:	;$7F0C. Frames 227-897
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.7	dc.w	227,6,228,6,229,8,893,-1024
.3
.4
.5
.6	dc.w	247,6,248,6,249,8,897,-1024

SPAbglass	=	*-SPAlist	; $250A. 94 SPAbglass ($1078): wallcollb
SPAbglass_table:	;$7F3E. Frames 1000-1004
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.3
.4
.5
.6
.7	dc.w	1000,8,1001,8,1002,8,1003,8,1004,-1000

SPAshoulderchkl2	=	*-SPAlist	; $2530. 95 only. The second checking list ($7AF16) left check; FallDown skips the flip after it
SPAshoulderchkl2_table:	;$7F64. Frames 832-834
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.6
.7	dc.w	832,-24
.3
.4
.5	dc.w	834,-24

SPAshoulderchkr2	=	*-SPAlist	; $254A. 95 only. The second checking list ($7AF16) right check; FallDown skips the flip after it
SPAshoulderchkr2_table:	;$7F7E. Frames 833-835
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.6
.7	dc.w	833,-24
.3
.4
.5	dc.w	835,-24

SPAglideback	=	*-SPAlist	; $2564. 94 SPAglideback ($A60): doplayeracc when skating backwards
SPAglideback_table:	;$7F98. Frames 496-538
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	496,-8
.1	dc.w	502,-8
.2	dc.w	508,-8
.3	dc.w	514,-8
.4	dc.w	520,-8
.5	dc.w	526,-8
.6	dc.w	532,-8
.7	dc.w	538,-8

SPAflip	=	*-SPAlist	; $2596. 94 SPAflip ($136A): FallDown
SPAflip_table:	;$7FCA. Frames 183-605
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	227,6,600,6,600,6,601,6,602,6,230,100,231,8,183,8
	dc.w	184,-8
.1	dc.w	232,6,600,6,600,6,601,6,602,6,235,100,236,8,189,8
	dc.w	190,-8
.2	dc.w	237,6,600,6,600,6,601,6,602,6,240,100,241,8,195,8
	dc.w	196,-8
.3	dc.w	242,6,603,6,603,6,604,6,605,6,245,100,246,8,201,8
	dc.w	202,-8
.4	dc.w	247,6,603,6,603,6,604,6,605,6,250,100,251,8,207,8
	dc.w	208,-8
.5	dc.w	252,6,603,6,603,6,604,6,605,6,255,100,256,8,213,8
	dc.w	214,-8
.6	dc.w	257,6,603,6,603,6,604,6,605,6,260,100,261,8,219,8
	dc.w	220,-8
.7	dc.w	262,6,600,6,600,6,601,6,602,6,265,100,266,8,225,8
	dc.w	226,-8

SPAboardmidl	=	*-SPAlist	; $26C8. 94 SPAboardmidl ($193E): FallDown
SPAboardmidl_table:	;$80FC. Frames 67-1025
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	794,6,1012,6,1013,6,1014,6,1015,6,1016,80,1015,6,1014,6
	dc.w	1013,6,72,-8
.1
.2
.3	dc.w	1017,6,1018,6,1019,6,1020,80,1019,6,1017,6,67,-8
.4	dc.w	801,6,1021,6,1022,6,1023,6,1024,6,1025,80,1024,6,1023,6
	dc.w	1022,6,71,-8
.5
.6
.7	dc.w	805,6,1022,6,1023,6,1024,6,1025,80,1024,6,1023,6,1022,6
	dc.w	71,-8

SPAboardmidr	=	*-SPAlist	; $276A. 94 SPAboardmidr ($1A00): FallDown
SPAboardmidr_table:	;$819E. Frames 66-1039
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	766,6,1026,6,1027,6,1028,6,1029,6,1030,80,1029,6,1028,6
	dc.w	1027,6,66,-8
.1
.2
.3	dc.w	770,6,1031,6,1032,6,1033,6,1034,80,1033,6,1032,6,1031,6
	dc.w	67,-8
.4	dc.w	774,6,1035,6,1031,6,1032,6,1033,6,1034,80,1033,6,1032,6
	dc.w	1031,6,67,-8
.5
.6
.7	dc.w	1036,6,1037,6,1038,6,1039,80,1038,6,1036,6,71,-8

SPApump	=	*-SPAlist	; $280C. 94 SPApump ($EFC), inferred: the word list at $83564 after SPAcelebrate (IDA no label), with SPApump2
SPApump_table:	;$8240. Frames 922-937
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	922,12,923,12,922,12,923,12,922,12,923,-12
.1	dc.w	924,12,925,12,924,12,925,12,924,12,925,-12
.2	dc.w	926,12,927,12,926,12,927,12,926,12,927,-12
.3	dc.w	928,12,929,12,928,12,929,12,928,12,929,-12
.4	dc.w	930,12,931,12,930,12,931,12,930,12,931,-12
.5	dc.w	932,12,933,12,932,12,933,12,932,12,933,-12
.6	dc.w	934,12,935,12,934,12,935,12,934,12,935,-12
.7	dc.w	936,12,937,12,936,12,937,12,936,12,937,-12

SPAstanley	=	*-SPAlist	; $28DE. 94 SPAstanley ($109E), inferred: set at $834C0 (IDA no label), before the celebrate step
SPAstanley_table:	;$8312. Frames 938-953
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	938,12,939,12,938,12,939,12,938,12,939,-12
.1	dc.w	940,12,941,12,940,12,941,12,940,12,941,-12
.2	dc.w	942,12,943,12,942,12,943,12,942,12,943,-12
.3	dc.w	944,12,945,12,944,12,945,12,944,12,945,-12
.4	dc.w	946,12,947,12,946,12,947,12,946,12,947,-12
.5	dc.w	948,12,949,12,948,12,949,12,948,12,949,-12
.6	dc.w	950,12,951,12,950,12,951,12,950,12,951,-12
.7	dc.w	952,12,953,12,952,12,953,12,952,12,953,-12

SPApump2	=	*-SPAlist	; $29B0. 95 only, inferred: the word list at $83564 alternates it with SPApump
SPApump2_table:	;$83E4. Frames 954-969
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0	dc.w	954,12,955,12,954,12,955,12,954,12,955,-12
.1	dc.w	956,12,957,12,956,12,957,12,956,12,957,-12
.2	dc.w	958,12,959,12,958,12,959,12,958,12,959,-12
.3	dc.w	960,12,961,12,960,12,961,12,960,12,961,-12
.4	dc.w	962,12,963,12,962,12,963,12,962,12,963,-12
.5	dc.w	964,12,965,12,964,12,965,12,964,12,965,-12
.6	dc.w	966,12,967,12,966,12,967,12,966,12,967,-12
.7	dc.w	968,12,969,12,968,12,969,12,968,12,969,-12

SPAgslamtop	=	*-SPAlist	; $2A82. 94 SPAgslamtop ($1596): checkanim (IDA $7FE62)
SPAgslamtop_table:	;$84B6. Frames 898-903
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.6
.7	dc.w	898,8,899,8,900,8,899,8,898,8,898,8,899,8,900,8
	dc.w	899,8,898,-8
.3
.4
.5	dc.w	901,8,902,8,903,8,902,8,901,8,901,8,902,8,903,8
	dc.w	902,8,901,-8

SPAgextra1	=	*-SPAlist	; $2AE4. 95 only. goaliesave (IDA loc_806CC): with SPAgextra2, picked by the goalie side of the puck and the glove hand ($76 bit 0)
SPAgextra1_table:	;$8518. Frames 1040-1043
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.6
.7	dc.w	1040,4,1041,-24,1040,-4
.3
.4
.5	dc.w	1042,4,1043,-24,1042,-4

SPAgextra2	=	*-SPAlist	; $2B0E. 95 only. goaliesave (IDA loc_806CC): see SPAgextra1. puckgoalie compares SPAgextra1
SPAgextra2_table:	;$8542. Frames 876-879
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.6
.7	dc.w	876,4,877,-24,876,-4
.3
.4
.5	dc.w	878,4,879,-24,878,-4

SPAgslambot	=	*-SPAlist	; $2B38. 94 SPAgslambot ($1684): checkanim (IDA $7FE7C)
SPAgslambot_table:	;$856C. Frames 1044-1049
.t	;offset to each direction of animation (0-7)
	dc.w	.0-.t
	dc.w	.1-.t
	dc.w	.2-.t
	dc.w	.3-.t
	dc.w	.4-.t
	dc.w	.5-.t
	dc.w	.6-.t
	dc.w	.7-.t
	dc.w	0

.0
.1
.2
.6
.7	dc.w	1044,10,1045,12,1046,-8
.3
.4
.5	dc.w	1047,10,1048,12,1049,-8

; End of animation list

revframetbl	;$8596-$8DD7 (2114 bytes). 94 name (94 kept it at the end of graphics94). One word per sprite frame (1057, frame 0-1056):
	;the frame for a reverse angle replay. RestoreReplayFrame (replay95, IDA $8DD46) movea.l #revframetbl,a6
	incbin	..\Extracted\NHL95\Graphics\revframetbl.bin
	even
