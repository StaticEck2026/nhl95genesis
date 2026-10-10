;	NHL 95 team data. Retail $000772-$005A33 (21186 bytes), from the IDA listing lst/nhl95.bin.lst (all dc.b there).
;	Layout of 94 teamdata94.asm: the team address table, one block per team, playoffseats. 95 still has 26 teams plus the
;	two all star teams, in the 94 TeamList order. Not here: the dc.l 0 94 kept before TeamList (main95, $69A) and Credits /
;	CreditsList (credits95, $1A6C28).

TeamList	;$772 (94 $30E). IDA: no label. Team number = index (ANH 0 ... WPG 25, ASE 26, ASW 27), the 94 order
	dc.l	Anaheim	;0 ANH
	dc.l	Boston	;1 BOS
	dc.l	Buffalo	;2 BUF
	dc.l	Calgary	;3 CGY
	dc.l	Chicago	;4 CHI
	dc.l	Dallas	;5 DAL
	dc.l	Detroit	;6 DET
	dc.l	Edmonton	;7 EDM
	dc.l	Florida	;8 FLA
	dc.l	Hartford	;9 HFD
	dc.l	LosAngeles	;10 LA
	dc.l	Montreal	;11 MTL
	dc.l	NewJersey	;12 NJ
	dc.l	LongIsland	;13 NYI
	dc.l	NewYork	;14 NYR
	dc.l	Ottawa	;15 OTW
	dc.l	Philadelphia	;16 PHI
	dc.l	Pittsburgh	;17 PIT
	dc.l	Quebec	;18 QUE
	dc.l	SanJose	;19 SJ
	dc.l	StLouis	;20 STL
	dc.l	TampaBay	;21 TB
	dc.l	Toronto	;22 TOR
	dc.l	Vancouver	;23 VAN
	dc.l	Washington	;24 WSH
	dc.l	Winnipeg	;25 WPG
	dc.l	AllStarsEast	;26 ASE
	dc.l	AllStarsWest	;27 ASW

NumofTeams	=	(*-TeamList)/4
Playerdata	=	0
Palettedata	=	2
Teamname	=	4
LineSets	=	6
ScoutReport	=	8
ScoreOdds	=	10

;------------------------
; Team block: 6 offset words (the equates above), .pad home and visitor palettes (16 colours each, incbin <team>h95.pal / <team>v95.pal
; from extractAssets95.js; every 95 palette differs from 94), .sr, .sodds, .ls 8 lines of 8 player numbers (1 = first .pld entry),
; .pld players ended by an empty String, then 4 Strings: city, abbreviation, nickname, arena. Same layout as 94.
; Blocks are in ROM order (ASE and ASW first), not TeamList order. 94 put FLA and ANH last; 95 sorts them in by name,
; and Dallas sits between LA and MTL where 94 had Minnesota. WPG comes before WSH.
;------------------------
; Player ratings, 93 names (Player macro: name, then 16 nibbles unwl,sodp,chga,eytm):
;u - uniform # x10
;n - uniform # x1
;w - weight
;l - leg power
;s - speed
;o - offensive awareness
;d - defensive awareness
;p - shot power / NA for goalie
;c - checking strength / NA
;h - shooting hand / glove hand
;g - stickhandling / glove left saves
;a - shooting accuracy / glove right saves
;e - endurance / stick right saves
;y - shot/pass decision / stick left saves
;t - passing accuracy / consistency
;m - aggressiveness (PIM) / NA
;------------------------
AllStarsEast	;ASE, $7E2 (94 $37E)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\ASEh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\ASEv95.pal
.sr	;4 bytes
	dc.w	$7720,$00E6
.sodds
	dc.b	204,176
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,21,18,07,05,17,04,00	;line 1
	dc.b	01,21,18,12,10,15,04,00	;line 2
	dc.b	01,19,23,14,04,17,05,00	;line 3
	dc.b	01,20,22,07,05,06,10,00	;line 4
	dc.b	01,21,22,16,08,11,12,00	;line 5
	dc.b	01,18,19,10,13,09,17,00	;line 6
	dc.b	01,20,23,12,15,16,11,00	;line 7
	dc.b	01,21,18,17,04,13,09,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Patrick Roy',	3366,4355,0000,5666	;1
	Player	'Mike Richter',	3575,4344,0000,5555	;2
	Player	'John Vanbiesbrk',	3454,3453,0000,4455	;3
	Player	'Mark Messier',	1195,4433,4993,4253	;4
	Player	'Adam Oates',	1275,4653,3A54,5061	;5
	Player	'Pierre Turgeon',	7794,4534,0995,4140	;6
	Player	'Joe Sakic',	1964,3543,29C5,5262	;7
	Player	'Brian Bradley',	1944,4434,2A64,4243	;8
	Player	'Alexei Yashin',	1974,4414,1AC4,3242	;9
	Player	'Eric Lindros',	88C4,3445,56A6,5344	;10
	Player	'Joe Mullen',	0764,3433,3A65,4431	;11
	Player	'Adam Graves',	0994,4433,5D73,4535	;12
	Player	'Geoff Sanderson',	0864,5434,2B64,4331	;13
	Player	'Mark Recchi',	0865,4534,3D95,4343	;14
	Player	'Jaromir Jagr',	68A5,4534,4BC3,6152	;15
	Player	'Bob Kudelski',	2292,3434,2C64,3432	;16
	Player	'Alexnder Mogilny',	8976,6634,1794,4451	;17
	Player	'Brian Leetch',	0266,3544,2DC2,5252	;18
	Player	'Scott Stevens',	04B4,4464,5D73,5145	;19
	Player	'Garry Galley',	0373,3342,3BA1,3233	;20
	Player	'Ray Bourque',	77A5,4555,49C5,6452	;21
	Player	'Al Iafrate',	43B4,4446,49A2,3344	;22
	Player	'Larry Murphy',	55A4,3554,3C92,5152	;23
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'All Stars East'
.ta	;abbreviation
	String	'ASE'
.tm	;nickname. 94 left it empty for the all star teams
	String	'All Stars East'
.ar	;arena
	String	'San Jose Arena'

AllStarsWest	;ASW, $AB2 (94 $674)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\ASWh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\ASWv95.pal
.sr	;4 bytes
	dc.w	$7720,$00C6
.sodds
	dc.b	172,176
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,21,20,08,04,12,05,00	;line 1
	dc.b	01,21,20,08,05,07,04,00	;line 2
	dc.b	01,17,16,04,12,13,05,00	;line 3
	dc.b	01,19,20,15,14,10,04,00	;line 4
	dc.b	01,21,16,04,05,12,15,00	;line 5
	dc.b	01,17,19,06,08,13,04,00	;line 6
	dc.b	01,18,19,09,12,10,05,00	;line 7
	dc.b	01,21,16,08,14,06,04,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Curtis Joseph',	3165,4564,0000,4444	;1
	Player	'Arturs Irbe',	3253,4443,0000,4444	;2
	Player	'Felix Potvin',	2964,4664,0000,5454	;3
	Player	'Doug Gilmour',	9345,4554,4BC4,6043	;4
	Player	'Wayne Gretzky',	9946,4643,19C4,6160	;5
	Player	'Joe Nieuwendyk',	2584,3534,3795,4342	;6
	Player	'Jeremy Roenick',	2745,5545,3CD5,5253	;7
	Player	'Sergei Fedorov',	9176,6654,2BC5,5253	;8
	Player	'Shayne Corson',	0993,3344,4773,4334	;9
	Player	'Dave Andreychuk',	14B3,2534,3A95,5432	;10
	Player	'Brendan Shanahan',	19A3,3545,3AA5,4244	;11
	Player	'Pavel Bure',	1056,6625,29C5,4542	;12
	Player	'Teemu Selanne',	1365,6524,38C5,5442	;13
	Player	'Brett Hull',	1694,4536,3A94,4432	;14
	Player	'Russ Courtnall',	2665,6434,2C93,4342	;15
	Player	'Rob Blake',	04A4,4444,4AA2,4344	;16
	Player	'Al MacInnis',	0284,4446,3892,5343	;17
	Player	'Alexei Kasatonov',	07A4,3233,3761,3142	;18
	Player	'Sandis Ozolinsh',	0673,4434,2B94,4242	;19
	Player	'Chris Chelios',	0774,4465,4AA2,6245	;20
	Player	'Paul Coffey',	7796,5434,2BC2,5163	;21
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'All Stars West'
.ta	;abbreviation
	String	'ASW'
.tm	;nickname. 94 left it empty for the all star teams
	String	'All Stars West'
.ar	;arena
	String	'San Jose Arena'

Anaheim	;ANH, $D66 (94 $5330)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\ANHh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\ANHv95.pal
.sr	;4 bytes
	dc.w	$0500,$01E7
.sodds
	dc.b	180,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,21,18,13,03,08,05,00	;line 1
	dc.b	01,21,18,13,03,08,05,00	;line 2
	dc.b	01,19,23,15,05,09,03,00	;line 3
	dc.b	01,17,22,12,04,11,03,00	;line 4
	dc.b	01,21,18,05,04,08,03,00	;line 5
	dc.b	01,19,23,13,03,09,08,00	;line 6
	dc.b	01,19,23,13,03,08,09,00	;line 7
	dc.b	01,21,18,15,06,09,03,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Guy Hebert',	3164,3332,0000,3333	;1
	Player	'Mikhail Shtalenkov',	3562,2223,0000,2222	;2
	Player	'Bob Corkum',	20A3,3333,3863,3522	;3
	Player	'Stephan Lebeau',	4753,3433,2664,4231	;4
	Player	'Anatoli Semenov',	1973,4343,2763,4032	;5
	Player	'Shaun VanAllen',	2292,2222,3B62,3122	;6
	Player	'Joe Sacco',	1483,3323,3B63,3322	;7
	Player	'Terry Yake',	2563,4423,3A64,4232	;8
	Player	'Peter Douris',	1683,3233,2832,2421	;9
	Player	'Todd Ewen',	36B1,1212,3852,2315	;10
	Player	'Steven King',	1772,2322,2663,3422	;11
	Player	'Troy Loney',	24A2,3232,4971,3212	;12
	Player	'Garry Valk',	1872,2233,3973,3323	;13
	Player	'Stu Grimson',	32B1,1021,2B21,2515	;14
	Player	'Tim Sweeney',	0873,2333,1B63,3421	;15
	Player	'Patrik Carnback',	2172,2322,0762,2322	;16
	Player	'David Williams',	0482,2222,2832,2423	;17
	Player	'Sean Hill',	0683,3222,2662,3324	;18
	Player	'Bobby Dollas',	02A3,2243,3962,3222	;19
	Player	'Don McSween',	3982,1223,2762,2222	;20
	Player	'Bill Houlder',	23B1,2223,2B63,3422	;21
	Player	'Mark Ferner',	0382,1222,2732,2322	;22
	Player	'Randy Ladouceur',	29B3,2141,3971,4514	;23
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Anaheim'
.ta	;abbreviation
	String	'ANH'
.tm	;nickname
	String	'Mighty Ducks'
.ar	;arena
	String	'Arrowhead Pond'

Boston	;BOS, $102A (94 $966)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\BOSh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\BOSv95.pal
.sr	;4 bytes
	dc.w	$4520,$10E8
.sodds
	dc.b	178,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,18,20,06,03,08,06,00	;line 1
	dc.b	01,18,21,14,03,08,06,00	;line 2
	dc.b	01,20,22,15,06,10,03,00	;line 3
	dc.b	01,19,23,16,07,12,03,00	;line 4
	dc.b	01,18,20,14,03,08,06,00	;line 5
	dc.b	01,19,22,15,06,10,03,00	;line 6
	dc.b	01,18,21,15,03,08,06,00	;line 7
	dc.b	01,19,23,16,06,10,03,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Jon Casey',	3024,3343,0000,4343	;1
	Player	'Vincent Riendeau',	3763,3222,0000,3222	;2
	Player	'Adam Oates',	1275,4653,3A54,5061	;3
	Player	'Jozef Stumpel',	2252,2222,1863,3231	;4
	Player	'Andrew McKim',	4582,2221,1832,2321	;5
	Player	'Bryan Smolinski',	2004,4433,2A93,3433	;6
	Player	'Dan Marois',	3373,3213,1463,2423	;7
	Player	'Cam Neely',	08A3,3545,4045,5444	;8
	Player	'Stephen Leach',	2763,2334,3473,4433	;9
	Player	'Stephen Heinze',	2363,4333,3A33,3431	;10
	Player	'Glen Murray',	4404,3323,2A64,3422	;11
	Player	'Mariusz Czerkawski',	1973,3322,1262,3332	;12
	Player	'Brent Hughes',	1863,3232,3972,2534	;13
	Player	'Dmitri Kvartalnov',	1064,4413,1794,4241	;14
	Player	'Ted Donato',	2143,4343,2D33,3332	;15
	Player	'Dave Reid',	1793,3233,2B24,4220	;16
	Player	'Paul Stanton',	2583,3234,3921,3543	;17
	Player	'Ray Bourque',	77A5,4555,49C5,6452	;18
	Player	'David Shaw',	3492,2242,3672,4523	;19
	Player	'Al Iafrate',	43B4,4446,49A2,3344	;20
	Player	'Don Sweeney',	3244,3343,46A1,4142	;21
	Player	'Glen Wesley',	2685,4444,3B42,4442	;22
	Player	'Gordie Roberts',	1473,2131,3723,3023	;23
	Player	'Glen Feathrston',	06B3,3122,4743,2325	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Boston'
.ta	;abbreviation
	String	'BOS'
.tm	;nickname
	String	'Bruins'
.ar	;arena
	String	'Boston Garden'

Buffalo	;BUF, $1304 (94 $C4C)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\BUFh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\BUFv95.pal
.sr	;4 bytes
	dc.w	$5320,$10F7
.sodds
	dc.b	91,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,19,23,05,04,14,09,00	;line 1
	dc.b	01,19,24,09,04,14,05,00	;line 2
	dc.b	01,20,22,10,05,16,14,00	;line 3
	dc.b	01,18,23,13,08,15,04,00	;line 4
	dc.b	01,19,24,09,04,14,05,00	;line 5
	dc.b	01,21,23,10,05,16,14,00	;line 6
	dc.b	01,23,24,08,05,16,04,00	;line 7
	dc.b	01,20,22,09,03,15,05,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Dominik Hasek',	3945,3554,0000,5656	;1
	Player	'Grant Fuhr',	3175,4555,0100,3455	;2
	Player	'Dave Hannan',	1463,2232,2B63,2122	;3
	Player	'Pat LaFontaine',	1655,4644,24C4,6252	;4
	Player	'Dale Hawerchuk',	1066,4544,2BC3,4052	;5
	Player	'Bob Sweeney',	2093,2353,3734,4233	;6
	Player	'Rob Ray',	32A3,4121,4B52,1515	;7
	Player	'Randy Wood',	1982,5342,3D33,4423	;8
	Player	'Yuri Khmylev',	1374,3444,3694,4332	;9
	Player	'Brad May',	2792,2323,4B43,3524	;10
	Player	'Craig Simpson',	2283,3434,2364,3132	;11
	Player	'Jason Dawe',	4383,3323,2964,3431	;12
	Player	'Derek Plante',	2644,4433,2B93,3241	;13
	Player	'Alexnder Mogilny',	8976,6634,1794,4451	;14
	Player	'Wayne Presley',	1863,3343,3673,3423	;15
	Player	'Donald Audette',	2853,3434,2664,3532	;16
	Player	'Matthew Barnaby',	3672,2212,3952,3324	;17
	Player	'Randy Moller',	24A3,2212,3841,1124	;18
	Player	'Doug Bodger',	08A4,3342,2991,4132	;19
	Player	'Ken Sutton',	4183,2242,1932,3232	;20
	Player	'Philippe Boucher',	0473,3323,2892,3243	;21
	Player	'Craig Muni',	0592,2152,4B61,4223	;22
	Player	'Petr Svoboda',	0754,4243,3970,4033	;23
	Player	'Richard Smehlik',	42A3,2344,3D63,3332	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Buffalo'
.ta	;abbreviation
	String	'BUF'
.tm	;nickname
	String	'Sabres'
.ar	;arena
	String	'Memorial Auditorium'

Calgary	;CGY, $15E0 (94 $F3A)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\CGYh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\CGYv95.pal
.sr	;4 bytes
	dc.w	$6521,$21CA
.sodds
	dc.b	196,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,16,18,09,03,12,14,00	;line 1
	dc.b	01,16,18,09,03,14,12,00	;line 2
	dc.b	01,17,21,08,04,12,03,00	;line 3
	dc.b	01,19,20,10,05,11,03,00	;line 4
	dc.b	01,16,18,09,03,12,14,00	;line 5
	dc.b	01,17,21,08,04,11,03,00	;line 6
	dc.b	01,16,18,08,12,04,03,00	;line 7
	dc.b	01,17,21,09,03,07,14,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Mike Vernon',	3043,4444,0000,4444	;1
	Player	'Trevor Kidd',	3733,3222,0000,3322	;2
	Player	'Joe Nieuwendyk',	2584,3534,3795,4342	;3
	Player	'Robert Reichel',	2664,3435,2D95,3342	;4
	Player	'Joel Otto',	29B3,2253,5A74,4225	;5
	Player	'Michael Nylander',	9254,4433,2792,3142	;6
	Player	'Kelly Kisio',	1163,2343,4263,4133	;7
	Player	'German Titov',	1373,3333,3964,3532	;8
	Player	'Gary Roberts',	1073,4544,49A5,5345	;9
	Player	'Paul Kruse',	1292,2222,3952,3424	;10
	Player	'Wes Walz',	1762,3332,1663,3131	;11
	Player	'Theoren Fleury',	1435,5444,4CA4,4333	;12
	Player	'Sandy McCarthy',	1571,1222,3A52,3425	;13
	Player	'Ronnie Stern',	2282,2212,3852,2325	;14
	Player	'Brad Schlegel',	2172,2122,2631,3422	;15
	Player	'Zarley Zalapski',	33A5,4434,3792,5332	;16
	Player	'James Patrick',	0695,4343,3692,3242	;17
	Player	'Al MacInnis',	0284,4446,3892,5343	;18
	Player	'Dan Keczmer',	3972,2131,2762,2513	;19
	Player	'Trent Yawney',	1873,3242,2762,3232	;20
	Player	'Frank Musil',	0393,4142,3941,3323	;21
	Player	'Michel Petit',	0793,3234,4671,3223	;22
	Player	'Kevin Dahl',	0473,2141,3461,3132	;23
	Player	'Chris Dahlquist',	0583,2142,3971,3323	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Calgary'
.ta	;abbreviation
	String	'CGY'
.tm	;nickname
	String	'Flames'
.ar	;arena
	String	'Olympic Saddledome'

Chicago	;CHI, $18BE (94 $1234)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\CHIh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\CHIv95.pal
.sr	;4 bytes
	dc.w	$2310,$11E8
.sodds
	dc.b	196,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,19,18,09,03,16,14,00	;line 1
	dc.b	01,19,18,11,03,14,16,00	;line 2
	dc.b	01,24,23,08,04,16,03,00	;line 3
	dc.b	01,17,20,09,05,13,03,00	;line 4
	dc.b	01,18,23,14,03,16,08,00	;line 5
	dc.b	01,24,19,08,04,13,11,00	;line 6
	dc.b	01,19,18,04,03,14,11,00	;line 7
	dc.b	01,24,23,05,13,11,14,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Ed Belfour',	3066,4665,0000,6655	;1
	Player	'Jeff Hackett',	3152,3112,0000,2222	;2
	Player	'Jeremy Roenick',	2745,5545,3CD5,5253	;3
	Player	'Christan Ruuttu',	2284,4343,4762,4243	;4
	Player	'Brent Sutter',	1263,2353,47A3,5134	;5
	Player	'Jeff Shantz',	1172,3312,2662,3232	;6
	Player	'Steve Dubinsky',	3273,3223,1962,3221	;7
	Player	'Paul Ysebaert',	1474,4343,2963,3342	;8
	Player	'Michel Goulet',	1684,3332,2564,3312	;9
	Player	'Randy Cunnyworth',	1962,3233,3972,3533	;10
	Player	'Patrick Poulin',	44A3,3323,3963,5232	;11
	Player	'Darin Kimble',	2091,1211,3624,1315	;12
	Player	'Dirk Graham',	3384,3353,4872,4534	;13
	Player	'Tony Amonte',	1064,5434,1D63,4532	;14
	Player	'Rich Sutter',	1573,3241,2A42,4424	;15
	Player	'Joe Murphy',	1774,5434,3B73,4343	;16
	Player	'Eric Weinrich',	02A3,4333,3962,4132	;17
	Player	'Chris Chelios',	0774,4465,4AA2,6245	;18
	Player	'Steve Smith',	05B4,4343,4772,5244	;19
	Player	'Neil Wilkinson',	2373,3132,3870,4433	;20
	Player	'Keith Carney',	0492,3212,3962,1424	;21
	Player	'Greg Smyth',	03A1,1110,1621,1405	;22
	Player	'Gary Suter',	0675,4444,47A2,5244	;23
	Player	'Cam Russell',	0853,3132,3951,3525	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Chicago'
.ta	;abbreviation
	String	'CHI'
.tm	;nickname
	String	'Blackhawks'
.ar	;arena
	String	'United Center'

Detroit	;DET, $1B9E (94 $152E)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\DETh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\DETv95.pal
.sr	;4 bytes
	dc.w	$7621,$20E8
.sodds
	dc.b	138,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,19,18,04,03,13,14,00	;line 1
	dc.b	01,21,18,05,03,14,04,00	;line 2
	dc.b	01,19,23,08,04,13,03,00	;line 3
	dc.b	01,22,20,09,06,07,03,00	;line 4
	dc.b	01,21,18,05,03,14,04,00	;line 5
	dc.b	01,19,23,08,04,13,03,00	;line 6
	dc.b	01,19,23,09,04,03,14,00	;line 7
	dc.b	01,21,20,05,03,14,04,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Bob Essensa',	3533,4433,0000,3333	;1
	Player	'Chris Osgood',	3034,3343,0000,3333	;2
	Player	'Steve Yzerman',	1966,5644,18C4,6151	;3
	Player	'Sergei Fedorov',	9176,6654,2BC5,5253	;4
	Player	'Keith Primeau',	55B2,2433,3975,3224	;5
	Player	'Kris Draper',	3373,4242,2962,4232	;6
	Player	'Greg Johnson',	2363,3322,2962,3322	;7
	Player	'Vachslav Kozlov',	1354,3423,1B94,3532	;8
	Player	'Shawn Burr',	1162,2242,3772,3124	;9
	Player	'Bob Probert',	24B4,3223,4952,4236	;10
	Player	'Micah Aivazoff',	2772,2222,2763,3221	;11
	Player	'Mike Sillinger',	1273,3222,2762,4021	;12
	Player	'Dino Ciccarelli',	2255,3525,2675,4344	;13
	Player	'Ray Sheppard',	2662,2513,1865,3421	;14
	Player	'Darren McCarty',	25A2,2232,4A52,4326	;15
	Player	'Sheldon Kennedy',	1543,5222,1833,2521	;16
	Player	'Sergei Bautin',	2973,2133,1931,2221	;17
	Player	'Paul Coffey',	7796,5434,2BC2,5163	;18
	Player	'Steve Chiasson',	0393,3444,3B72,4234	;19
	Player	'Terry Carkner',	02A1,2132,3741,3024	;20
	Player	'Nicklas Lidstrom',	0554,3344,2B61,4241	;21
	Player	'Mark Howe',	0463,2343,2361,3031	;22
	Player	'Vladimir Konstantov',	1664,4243,4A71,4235	;23
	Player	'Bob Halkidis',	2191,2122,3742,3224	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Detroit'
.ta	;abbreviation
	String	'DET'
.tm	;nickname
	String	'Red Wings'
.ar	;arena
	String	'Joe Louis Sports Arena'

Edmonton	;EDM, $1E9C (94 $1848)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\EDMh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\EDMv95.pal
.sr	;4 bytes
	dc.w	$2511,$02F6
.sodds
	dc.b	181,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,19,22,10,03,13,05,00	;line 1
	dc.b	01,19,24,10,03,14,05,00	;line 2
	dc.b	01,22,20,13,05,16,03,00	;line 3
	dc.b	01,23,21,12,07,17,03,00	;line 4
	dc.b	01,19,20,10,03,14,05,00	;line 5
	dc.b	01,22,18,13,05,16,03,00	;line 6
	dc.b	01,23,22,10,03,05,14,00	;line 7
	dc.b	01,19,24,17,05,03,14,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Bill Ranford',	3045,3435,0000,4455	;1
	Player	'Fred Brathwaite',	3152,2222,0000,2122	;2
	Player	'Doug Weight',	3963,3433,3DA3,3243	;3
	Player	'Todd Marchant',	3674,4223,0263,3232	;4
	Player	'Jason Arnott',	0783,3444,3AA4,3343	;5
	Player	'Dean McAmmond',	3773,4243,2962,3221	;6
	Player	'Scott Thornton',	1793,3132,2742,3223	;7
	Player	'Mike Stapleton',	2563,3222,2A62,2530	;8
	Player	'Brent Grieve',	3493,4223,3974,3322	;9
	Player	'Shayne Corson',	0993,3344,4773,4334	;10
	Player	'Louie DeBrusk',	29C1,1212,3753,1515	;11
	Player	'Scott Pearson',	3393,3122,3542,3123	;12
	Player	'Zdeno Ciger',	0873,3334,2D64,3230	;13
	Player	'Steven Rice',	12B2,2322,2742,2223	;14
	Player	'Shjon Podein',	2692,2322,2734,2512	;15
	Player	'Kirk Maltby',	1873,2232,3872,4323	;16
	Player	'Kelly Buchberger',	16A3,3232,4C72,3214	;17
	Player	'Ilya Byakin',	1073,2322,0763,2240	;18
	Player	'Igor Kravchuk',	2195,3344,3B92,4332	;19
	Player	'Fredrik Olausson',	1594,3434,1892,3141	;20
	Player	'Adam Bennett',	3592,2121,2640,1312	;21
	Player	'Bob Beers',	0293,3233,3A72,3323	;22
	Player	'Luke Richardson',	22B3,3132,4970,2434	;23
	Player	'Boris Mironov',	2064,3223,3871,2323	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Edmonton'
.ta	;abbreviation
	String	'EDM'
.tm	;nickname
	String	'Oilers'
.ar	;arena
	String	'Northlands Coliseum'

Florida	;FLA, $218E (94 $50E6)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\FLAh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\FLAv95.pal
.sr	;4 bytes
	dc.w	$1200,$00E8
.sodds
	dc.b	196,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,17,20,10,06,15,03,00	;line 1
	dc.b	01,17,20,10,06,15,03,00	;line 2
	dc.b	01,23,18,08,03,13,06,00	;line 3
	dc.b	01,24,21,09,04,14,06,00	;line 4
	dc.b	01,24,20,10,06,15,03,00	;line 5
	dc.b	01,17,21,09,04,14,06,00	;line 6
	dc.b	01,23,21,08,03,10,06,00	;line 7
	dc.b	01,17,18,13,04,06,03,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'John Vanbiesbrk',	3454,3453,0000,4455	;1
	Player	'Mark Fitzpatrik',	3073,4223,0000,3434	;2
	Player	'Brian Skrudland',	2084,3252,4973,4334	;3
	Player	'Stu Barnes',	1452,3433,2893,3431	;4
	Player	'Rob Neidrmayer',	4494,5223,3773,3422	;5
	Player	'Jesse Belanger',	2653,4433,2894,3241	;6
	Player	'Tom Fitzgerald',	2182,3233,3A63,3222	;7
	Player	'Mike Hough',	1873,2233,3972,3233	;8
	Player	'Dave Lowry',	1082,3332,3B72,3424	;9
	Player	'Andrei Lomakin',	1974,3333,1993,3242	;10
	Player	'Bill Lindsay',	1161,2232,2D41,2322	;11
	Player	'Jeff Daniels',	2392,2122,2933,2421	;12
	Player	'Jody Hull',	1292,2232,3432,3321	;13
	Player	'Scott Mellanby',	2791,1333,4A74,3324	;14
	Player	'Bob Kudelski',	2292,3434,2C64,3432	;15
	Player	'Mike Foligno',	1782,2232,4243,3423	;16
	Player	'Brian Benning',	0783,2323,2762,4234	;17
	Player	'Geoff Smith',	2594,3131,2491,3231	;18
	Player	'Brent Severyn',	24A2,2133,4752,3325	;19
	Player	'Gord Murphy',	0585,4334,3C62,3333	;20
	Player	'Joe Cirella',	02A2,2133,3642,3323	;21
	Player	'Paul Laus',	0393,2022,4621,3325	;22
	Player	'Keith Brown',	0472,2232,3441,3433	;23
	Player	'Peter Andersson',	0693,3322,2992,3342	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Florida'
.ta	;abbreviation
	String	'FLA'
.tm	;nickname
	String	'Panthers'
.ar	;arena
	String	'Miami Arena'

Hartford	;HFD, $246E (94 $1B44)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\HFDh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\HFDv95.pal
.sr	;4 bytes
	dc.w	$1102,$02E7
.sodds
	dc.b	196,16
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,19,23,09,04,15,06,00	;line 1
	dc.b	01,20,18,09,04,15,06,00	;line 2
	dc.b	01,19,23,13,06,17,08,00	;line 3
	dc.b	01,22,24,12,08,14,04,00	;line 4
	dc.b	01,20,23,09,04,15,06,00	;line 5
	dc.b	01,22,18,08,06,17,04,00	;line 6
	dc.b	01,20,23,15,04,09,06,00	;line 7
	dc.b	01,22,18,10,05,09,06,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Sean Burke',	01A4,3223,0000,3344	;1
	Player	'Jeff Reese',	3542,3322,0000,2222	;2
	Player	'Frank Pietrngelo',	4063,3113,0000,2222	;3
	Player	'Andrew Cassels',	2173,3442,2B33,4142	;4
	Player	'Mark Janssens',	22B3,2243,4D73,4124	;5
	Player	'Ted Drury',	1774,4232,3592,3232	;6
	Player	'Igor Chibirev',	3253,4323,1763,3231	;7
	Player	'Darren Turcotte',	8964,4434,2792,4331	;8
	Player	'Geoff Sanderson',	0864,5434,2B64,4331	;9
	Player	'Brian Propp',	2683,3233,3532,2530	;10
	Player	'Kevin Smyth',	20B3,3232,3933,4224	;11
	Player	'Jim Storm',	2493,3232,3972,4332	;12
	Player	'Jocelyn Lemieux',	2394,4334,3B72,3314	;13
	Player	'Paul Ranheim',	1484,5333,1A62,3431	;14
	Player	'Pat Verbeek',	1673,4434,3CA4,4444	;15
	Player	'Jim Sandlak',	41B1,2233,2442,3324	;16
	Player	'Robert Kron',	1853,4342,2993,3330	;17
	Player	'Bryan Marchment',	2783,3242,4741,3215	;18
	Player	'Alexnder Godynyuk',	05A2,3232,3972,3512	;19
	Player	'Adam Burt',	0674,3234,4771,4334	;20
	Player	'Brad McCrimmon',	1083,2142,4430,3133	;21
	Player	'Frantsek Kucera',	0493,3243,2961,3422	;22
	Player	'Chris Pronger',	4473,3332,3BA2,3334	;23
	Player	'Ted Crowley',	3373,3232,2872,3322	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Hartford'
.ta	;abbreviation
	String	'HFD'
.tm	;nickname
	String	'Whalers'
.ar	;arena
	String	'Hartford Civic Center'

LosAngeles	;LA, $2762 (94 $1E52)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\LAh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\LAv95.pal
.sr	;4 bytes
	dc.w	$4621,$02D8
.sodds
	dc.b	168,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,16,17,08,03,11,04,00	;line 1
	dc.b	01,16,18,10,03,11,04,00	;line 2
	dc.b	01,17,22,08,04,15,03,00	;line 3
	dc.b	01,19,20,07,05,12,03,00	;line 4
	dc.b	01,16,18,08,03,11,04,00	;line 5
	dc.b	01,17,19,10,04,12,03,00	;line 6
	dc.b	01,16,19,07,11,03,08,00	;line 7
	dc.b	01,18,20,10,03,11,08,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Kelly Hrudey',	3263,3343,0000,2223	;1
	Player	'Robb Stauber',	3562,3443,0000,2222	;2
	Player	'Wayne Gretzky',	9946,4643,19C4,6160	;3
	Player	'Robert Lang',	1363,3322,1664,3240	;4
	Player	'Kevin Todd',	1452,3333,2742,3332	;5
	Player	'Brian McReynolds',	2683,3132,3B33,3232	;6
	Player	'Pat Conacher',	1572,2232,2963,2432	;7
	Player	'Luc Robitaille',	2074,4535,2B96,5443	;8
	Player	'Warren Rychel',	1073,2211,3B52,1415	;9
	Player	'Mike Donnelly',	1164,4332,3B63,4332	;10
	Player	'Jari Kurri',	1784,3444,2B94,4232	;11
	Player	'Tony Granato',	2164,5443,36A4,3335	;12
	Player	'Dixon Ward',	0993,3333,3864,3123	;13
	Player	'Gary Shuchuk',	1462,2211,2632,1322	;14
	Player	'John Druce',	1992,2342,3633,3322	;15
	Player	'Rob Blake',	04A4,4444,4AA2,4344	;16
	Player	'Marty McSorley',	33C2,2243,4782,5436	;17
	Player	'Alex Zhitnik',	0265,4333,3B92,4143	;18
	Player	'Darryl Sydor',	2594,3323,3DA1,3332	;19
	Player	'Charlie Huddy',	22A3,2243,3972,3132	;20
	Player	'Jim Paek',	0782,3122,2731,3122	;21
	Player	'Doug Houda',	0672,2122,3631,2414	;22
	Player	'Tim Watters',	0562,2121,2510,2122	;23
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Los Angeles'
.ta	;abbreviation
	String	'LA'
.tm	;nickname
	String	'Kings'
.ar	;arena
	String	'The Great Western Forum'

Dallas	;DAL, $2A24 (94 $214E, after LA as 94 Minnesota)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\MINh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\MINv95.pal
.sr	;4 bytes
	dc.w	$5310,$20F7
.sodds
	dc.b	181,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,19,20,04,03,16,08,00	;line 1
	dc.b	01,19,23,08,03,16,04,00	;line 2
	dc.b	01,24,20,10,04,14,03,00	;line 3
	dc.b	01,21,18,11,05,17,03,00	;line 4
	dc.b	01,19,23,09,03,16,08,00	;line 5
	dc.b	01,24,20,10,04,14,03,00	;line 6
	dc.b	01,19,24,11,05,03,16,00	;line 7
	dc.b	01,21,20,17,07,03,16,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Andy Moog',	3543,3123,0000,3233	;1
	Player	'Darcy Wakaluk',	3463,3334,0000,3344	;2
	Player	'Mike Modano',	0975,5645,29C4,5342	;3
	Player	'Dave Gagner',	1564,4433,2994,4444	;4
	Player	'Neal Broten',	0743,4353,2962,4241	;5
	Player	'Dave Barr',	1082,2132,3472,3222	;6
	Player	'Dean Evason',	1662,2232,2A73,3133	;7
	Player	'Trent Klatt',	2993,3322,1863,3321	;8
	Player	'Pelle Eklund',	0655,3433,2593,4041	;9
	Player	'Brent Gilchrist',	4164,3323,3973,2532	;10
	Player	'Mike McPhee',	1794,3343,4B73,4422	;11
	Player	'Alan May',	2393,2233,3851,3425	;12
	Player	'Shane Churla',	2792,2221,4852,2125	;13
	Player	'Mike Craig',	2063,3323,3673,3323	;14
	Player	'Mike Needham',	3062,2222,2843,2421	;15
	Player	'Russ Courtnall',	2665,6434,2C93,4342	;16
	Player	'Paul Broten',	2172,2241,2662,3314	;17
	Player	'Doug Zmolek',	0584,3232,3571,3235	;18
	Player	'Mark Tinordi',	2493,3344,5773,4325	;19
	Player	'Derian Hatcher',	0293,2242,4B72,4224	;20
	Player	'Craig Ludwig',	03C2,2142,3B40,3324	;21
	Player	'Richard Matvichuk',	0473,3133,3931,3522	;22
	Player	'Grant Ledyard',	1294,3331,3960,2232	;23
	Player	'Paul Cavallini',	14A3,3243,3962,3532	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Dallas'
.ta	;abbreviation
	String	'DAL'
.tm	;nickname
	String	'Stars'
.ar	;arena
	String	'Reunion Arena'

Montreal	;MTL, $2CF8 (94 $243E)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\MTLh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\MTLv95.pal
.sr	;4 bytes
	dc.w	$3620,$21E8
.sodds
	dc.b	211,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,18,17,09,03,14,04,00	;line 1
	dc.b	01,24,17,09,03,14,04,00	;line 2
	dc.b	01,18,23,08,04,13,03,00	;line 3
	dc.b	01,21,19,10,05,15,03,00	;line 4
	dc.b	01,18,17,09,03,14,04,00	;line 5
	dc.b	01,21,19,08,06,13,03,00	;line 6
	dc.b	01,24,17,10,05,03,09,00	;line 7
	dc.b	01,18,23,04,03,09,14,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Patrick Roy',	3366,4355,0000,5666	;1
	Player	'Ron Tugnutt',	0122,3231,0000,1122	;2
	Player	'Kirk Muller',	1194,4444,4BA3,4144	;3
	Player	'John Leclair',	17B3,4335,3962,3122	;4
	Player	'Guy Carbonneau',	2164,3252,4861,4241	;5
	Player	'Paul DiPietro',	1563,3323,2862,3221	;6
	Player	'Ron Wilson',	0863,2241,2732,4222	;7
	Player	'Gilbert Dionne',	4583,2422,3994,3232	;8
	Player	'Vincent Damphousse',	2564,4524,1DC5,4242	;9
	Player	'Benoit Brunet',	2262,2322,2323,2222	;10
	Player	'Mario Roberge',	3261,1112,3742,1314	;11
	Player	'Pierre Sevigny',	2072,2212,1772,1223	;12
	Player	'Mike Keane',	1253,4342,4A62,4033	;13
	Player	'Brian Bellows',	2384,4424,2994,4342	;14
	Player	'Oleg Petrov',	0643,2332,1762,3330	;15
	Player	'Ed Ronan',	3182,2212,3222,1421	;16
	Player	'Eric Desjardins',	2894,3354,4C72,4333	;17
	Player	'Matt Schneider',	2774,4444,2762,4343	;18
	Player	'Patrice Brisebois',	4353,2333,2663,3322	;19
	Player	'Kevin Haller',	1463,2232,2772,4523	;20
	Player	'Bryan Fogarty',	4481,1211,2760,1011	;21
	Player	'J.J. Daigneault',	4864,3233,1762,4221	;22
	Player	'Lyle Odelein',	2493,2243,4B52,3425	;23
	Player	'Peter Popovic',	34A2,2123,3661,2211	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Montreal'
.ta	;abbreviation
	String	'MTL'
.tm	;nickname
	String	'Canadiens'
.ar	;arena
	String	'Montreal Forum'

NewJersey	;NJ, $2FE8 (94 $2740)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\NJh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\NJv95.pal
.sr	;4 bytes
	dc.w	$6411,$20F7
.sodds
	dc.b	92,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,21,18,16,05,15,04,00	;line 1
	dc.b	01,21,18,16,04,15,05,00	;line 2
	dc.b	01,20,22,08,05,14,04,00	;line 3
	dc.b	01,19,23,11,06,13,04,00	;line 4
	dc.b	01,21,18,16,04,15,05,00	;line 5
	dc.b	01,20,23,08,05,14,04,00	;line 6
	dc.b	01,21,18,16,04,15,05,00	;line 7
	dc.b	01,20,22,11,06,15,04,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Chris Terreri',	3124,4443,0000,4433	;1
	Player	'Martin Brodeur',	3075,3344,0000,5555	;2
	Player	'Alexnder Semak',	2063,2333,2693,3232	;3
	Player	'Bernie Nicholls',	0963,2443,2893,4143	;4
	Player	'Corey Millen',	1043,5422,1494,3233	;5
	Player	'Bob Carpenter',	1973,2242,2931,3333	;6
	Player	'Jim Dowd',	1173,4322,1862,3132	;7
	Player	'Valeri Zelepukin',	2564,4443,1B94,3232	;8
	Player	'Bobby Holik',	16A2,3224,3862,3323	;9
	Player	'Randy McKay',	2163,2233,4A83,3425	;10
	Player	'Tom Chorske',	1794,4332,3A63,3322	;11
	Player	'Mike Peluso',	0891,2222,4921,4415	;12
	Player	'Claude Lemieux',	22B4,4334,4872,4334	;13
	Player	'Bill Guerin',	1294,3335,4A74,3524	;14
	Player	'John MacLean',	1593,2544,3873,4524	;15
	Player	'Stephane Richer',	4494,4435,2AC4,4432	;16
	Player	'Jason Smith',	2683,3132,3871,3232	;17
	Player	'Scott Stevens',	04B4,4464,5D73,5145	;18
	Player	'Vachslav Fetisov',	02B4,2132,2931,3133	;19
	Player	'Bruce Driver',	2364,3342,3B62,4232	;20
	Player	'Scott Niedrmayer',	2793,3333,3992,3142	;21
	Player	'Ken Daneyko',	03A3,2151,5D40,4414	;22
	Player	'Tommy Albelin',	0673,2232,2960,3232	;23
	Player	'Jaroslav Modry',	0583,3132,2961,3221	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'New Jersey'
.ta	;abbreviation
	String	'NJ'
.tm	;nickname
	String	'Devils'
.ar	;arena
	String	'Brendan Byrne Arena'

LongIsland	;NYI, $32DA (94 $2A58)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\LIh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\LIv95.pal
.sr	;4 bytes
	dc.w	$5221,$12F7
.sodds
	dc.b	181,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,18,19,08,03,13,10,00	;line 1
	dc.b	01,19,20,10,03,13,08,00	;line 2
	dc.b	01,18,24,08,04,14,03,00	;line 3
	dc.b	01,21,22,09,06,15,03,00	;line 4
	dc.b	01,18,20,10,03,13,08,00	;line 5
	dc.b	01,21,22,08,04,14,03,00	;line 6
	dc.b	01,19,20,08,03,10,13,00	;line 7
	dc.b	01,18,24,09,04,03,13,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Ron Hextall',	7273,4443,0000,2233	;1
	Player	'Jamie McLennan',	2973,3222,0000,2222	;2
	Player	'Pierre Turgeon',	7794,4534,0995,4140	;3
	Player	'Ray Ferraro',	2063,3334,2993,4433	;4
	Player	'Keith Acton',	2442,2243,3972,4233	;5
	Player	'Travis Green',	3983,2324,3A62,3422	;6
	Player	'Claude Loiselle',	1083,2211,3363,1524	;7
	Player	'Benoit Hogue',	3374,5433,1964,4143	;8
	Player	'Marty McInnis',	1843,3342,2A64,3022	;9
	Player	'Derek King',	2793,2414,0965,4421	;10
	Player	'David Maley',	0881,1112,3750,1414	;11
	Player	'Dave Volek',	2564,4322,1262,4532	;12
	Player	'Steve Thomas',	3264,4434,4974,4234	;13
	Player	'Brad Dalgarno',	15B2,2231,3664,2123	;14
	Player	'Patrick Flatley',	2683,2342,4242,4144	;15
	Player	'Mick Vukota',	1282,2011,3A51,2415	;16
	Player	'Yan Kaminsky',	1763,2212,1562,2421	;17
	Player	'Vladimir Malakhov',	23A4,3434,2962,4333	;18
	Player	'Darius Kasparitis',	1174,3233,4961,2234	;19
	Player	'Uwe Krupp',	04E3,2334,2662,4132	;20
	Player	'Tom Kurvers',	2883,3424,2961,4132	;21
	Player	'Scott Lachance',	0782,2243,3962,4133	;22
	Player	'Dennis Vaske',	37A1,1212,2741,1113	;23
	Player	'Richard Pilon',	4794,2023,3571,2515	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'New York'
.ta	;abbreviation
	String	'NYI'
.tm	;nickname
	String	'Islanders'
.ar	;arena
	String	'Nassau Coliseum'

NewYork	;NYR, $35C6 (94 $2D5C)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\NYh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\NYv95.pal
.sr	;4 bytes
	dc.w	$5620,$20F7
.sodds
	dc.b	196,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,18,20,08,03,15,13,00	;line 1
	dc.b	01,18,21,08,03,13,15,00	;line 2
	dc.b	01,22,20,14,06,15,03,00	;line 3
	dc.b	01,24,19,10,04,17,03,00	;line 4
	dc.b	01,18,20,08,03,13,15,00	;line 5
	dc.b	01,22,19,10,06,15,03,00	;line 6
	dc.b	01,18,21,08,03,15,13,00	;line 7
	dc.b	01,22,20,10,05,03,08,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Mike Richter',	3575,4344,0000,5555	;1
	Player	'Glenn Healy',	3053,4433,0000,3322	;2
	Player	'Mark Messier',	1195,4433,4993,4253	;3
	Player	'Sergei Nemchinov',	1364,3353,4D64,6232	;4
	Player	'Craig MacTavish',	1484,3352,4B62,5223	;5
	Player	'Alexei Kovalev',	2776,5425,2BC4,3433	;6
	Player	'Ed Olczyk',	1293,3334,2A63,3442	;7
	Player	'Adam Graves',	0994,4433,5D73,4535	;8
	Player	'Nick Kypreos',	1982,2222,3B54,3415	;9
	Player	'Esa Tikkanen',	1095,4345,4A92,4444	;10
	Player	'Greg Gilbert',	1772,2242,3763,3112	;11
	Player	'Mike Hudson',	1573,3233,4972,4223	;12
	Player	'Glenn Anderson',	3674,4433,2B63,4143	;13
	Player	'Stephane Matteau',	3283,3342,3B63,3233	;14
	Player	'Steve Larmer',	2874,4464,4B64,6342	;15
	Player	'Joey Kocur',	2682,2132,3851,2424	;16
	Player	'Brian Noonan',	1673,3444,3A64,4533	;17
	Player	'Brian Leetch',	0266,3544,2DC2,5252	;18
	Player	'Alex Karpotsev',	2563,3232,3862,3232	;19
	Player	'Sergei Zubov',	2174,4544,3D92,3242	;20
	Player	'Jeff Beukeboom',	23B2,2242,4A71,3024	;21
	Player	'Kevin Lowe',	0483,3242,3961,3133	;22
	Player	'Doug Lidster',	0693,3233,3A61,4142	;23
	Player	'Jay Wells',	24A2,2132,4B40,2124	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'New York'
.ta	;abbreviation
	String	'NYR'
.tm	;nickname
	String	'Rangers'
.ar	;arena
	String	'Madison Square Garden'

Ottawa	;OTW, $38A8 (94 $3054)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\OTWh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\OTWv95.pal
.sr	;4 bytes
	dc.w	$0002,$02E8
.sodds
	dc.b	197,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,19,20,06,04,03,12,00	;line 1
	dc.b	01,19,21,06,04,12,03,00	;line 2
	dc.b	01,23,20,07,03,14,04,00	;line 3
	dc.b	01,22,24,11,05,13,04,00	;line 4
	dc.b	01,19,23,06,04,03,12,00	;line 5
	dc.b	01,22,20,07,05,14,12,00	;line 6
	dc.b	01,19,21,11,05,04,12,00	;line 7
	dc.b	01,24,20,12,04,03,06,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Craig Billington',	0143,4221,0000,2222	;1
	Player	'Mark LaForest',	3582,2121,0000,1111	;2
	Player	'Alexnder Daigle',	9154,4314,2DA3,3242	;3
	Player	'Alexei Yashin',	1974,4414,1AC4,3242	;4
	Player	'Troy Murray',	3384,3242,4471,3533	;5
	Player	'Sylvain Turgeon',	6194,4424,0533,3523	;6
	Player	'David Archibald',	1573,2333,1763,3522	;7
	Player	'Darcy Loewen',	1062,2122,2531,2424	;8
	Player	'Troy Mallette',	1872,2222,2953,2414	;9
	Player	'Brad Lauer',	1682,2212,2762,2432	;10
	Player	'Phil Bourque',	2783,4232,3972,5322	;11
	Player	'Dave McLlwain',	1773,2332,3663,3532	;12
	Player	'Andrew McBain',	2092,2323,2462,2122	;13
	Player	'Evgeny Davydov',	1165,4324,1863,3531	;14
	Player	'Scott Levins',	2692,2212,2632,3222	;15
	Player	'Rob Burakowsky',	2461,1202,0232,2210	;16
	Player	'Dennis Vial',	2192,1132,4951,3414	;17
	Player	'Steve Konroyd',	2483,2232,4531,3222	;18
	Player	'Norm Maciver',	2263,3423,2792,4133	;19
	Player	'Brad Shaw',	0473,2323,2661,5232	;20
	Player	'Darren Rumble',	3491,2212,3B40,3423	;21
	Player	'Kerry Huffman',	0593,3223,3961,3322	;22
	Player	'Dimitri Filmanov',	5593,2122,2661,2221	;23
	Player	'Gord Dineen',	0681,1221,2A30,2513	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Ottawa'
.ta	;abbreviation
	String	'OTW'
.tm	;nickname
	String	'Senators'
.ar	;arena
	String	'Ottawa Civic Centre'

Philadelphia	;PHI, $3B9E (94 $3348)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\PHIh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\PHIv95.pal
.sr	;4 bytes
	dc.w	$6121,$01D9
.sodds
	dc.b	90,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,16,17,04,03,12,08,00	;line 1
	dc.b	01,16,17,08,03,12,04,00	;line 2
	dc.b	01,18,19,09,04,13,03,00	;line 3
	dc.b	01,20,22,10,05,14,03,00	;line 4
	dc.b	01,16,17,09,03,12,04,00	;line 5
	dc.b	01,20,19,10,04,13,03,00	;line 6
	dc.b	01,18,19,04,03,08,12,00	;line 7
	dc.b	01,16,17,05,06,03,04,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Dominic Roussel',	3363,3333,0000,3322	;1
	Player	'Tommy Soderstrom',	3033,3342,0000,2323	;2
	Player	'Eric Lindros',	88C4,3445,56A6,5344	;3
	Player	'Rod BrindAmour',	1794,3444,3D94,4243	;4
	Player	'Mark Lamb',	2264,3242,3D61,3333	;5
	Player	'Dave Tippett',	1462,3132,2932,3122	;6
	Player	'Rob DiMaio',	2072,3232,3662,4223	;7
	Player	'Brent Fedyk',	1883,3333,2863,3122	;8
	Player	'Mikael Renberg',	1974,3534,3D95,3242	;9
	Player	'Josef Beranek',	4263,3433,1994,3433	;10
	Player	'Andre Faust',	3672,2222,2964,3322	;11
	Player	'Mark Recchi',	0865,4534,3D95,4343	;12
	Player	'Kevin Dineen',	1174,4343,2873,4534	;13
	Player	'Dave Brown',	2191,1031,2650,2514	;14
	Player	'Allan Conroy',	1552,2232,2862,3222	;15
	Player	'Garry Galley',	0373,3342,3BA1,3233	;16
	Player	'Dimitri Yushkevich',	0274,4343,3971,5333	;17
	Player	'Jason Bowen',	28A3,3133,4572,3322	;18
	Player	'Yves Racine',	2964,4334,3762,4232	;19
	Player	'Rob Zettler',	2673,2122,2941,3434	;20
	Player	'Jeff Finley',	2592,2122,2760,2422	;21
	Player	'Stewart Malgunas',	2352,2121,3960,3422	;22
	Player	'Rob Ramage',	0592,2133,4641,3424	;23
	Player	'Ryan McGill',	2782,2232,3841,3414	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Philadelphia'
.ta	;abbreviation
	String	'PHI'
.tm	;nickname
	String	'Flyers'
.ar	;arena
	String	'The Spectrum'

Pittsburgh	;PIT, $3E7C (94 $3646)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\PITh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\PITv95.pal
.sr	;4 bytes
	dc.w	$6311,$20D9
.sodds
	dc.b	197,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,18,19,07,03,13,12,00	;line 1
	dc.b	01,18,17,07,03,12,13,00	;line 2
	dc.b	01,20,19,08,04,13,03,00	;line 3
	dc.b	01,21,22,09,05,14,03,00	;line 4
	dc.b	01,18,19,07,03,13,12,00	;line 5
	dc.b	01,20,17,14,04,12,13,00	;line 6
	dc.b	01,18,19,13,03,12,07,00	;line 7
	dc.b	01,20,17,07,04,03,12,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Tom Barrasso',	35A4,4554,0100,4344	;1
	Player	'Ken Wregget',	3182,3332,0000,3232	;2
	Player	'Mario Lemieux',	66A5,4635,24C6,6162	;3
	Player	'Ron Francis',	1094,3553,4B93,5152	;4
	Player	'Shawn McEachern',	1573,4334,1B63,4432	;5
	Player	'Bryan Trottier',	1983,2222,2362,2122	;6
	Player	'Kevin Stevens',	25B3,3525,3B75,5444	;7
	Player	'Joe Mullen',	0764,3433,3A65,4431	;8
	Player	'Martin Straka',	8253,4433,1D93,3241	;9
	Player	'Jim McKenzie',	33A1,1112,3951,3315	;10
	Player	'Doug Brown',	2463,3242,3863,4333	;11
	Player	'Rick Tocchet',	2292,3434,4674,3334	;12
	Player	'Jaromir Jagr',	68A5,4534,4BC3,6152	;13
	Player	'Tomas Sandstrom',	1794,4535,2763,4434	;14
	Player	'Markus Naslund',	2964,3223,2962,2221	;15
	Player	'Chris Tamer',	0274,3222,3972,2321	;16
	Player	'Kjell Samuelsson',	28E2,2134,4641,4523	;17
	Player	'Ulf Samuelsson',	0584,4243,5B70,4136	;18
	Player	'Larry Murphy',	55A4,3554,3C92,5152	;19
	Player	'Peter Taglianeti',	3291,2133,4440,4424	;20
	Player	'Mike Ramsey',	0683,1032,4741,3123	;21
	Player	'Greg Brown',	3473,3322,2862,3222	;22
	Player	'Greg Hawgood',	0473,3323,2962,3132	;23
	Player	'Grant Jennings',	0392,2132,3970,2414	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Pittsburgh'
.ta	;abbreviation
	String	'PIT'
.tm	;nickname
	String	'Penguins'
.ar	;arena
	String	'Pittsburgh Civic Arena'

Quebec	;QUE, $416C (94 $393C)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\QUEh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\QUEv95.pal
.sr	;4 bytes
	dc.w	$5202,$12F7
.sodds
	dc.b	166,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,20,19,09,03,05,15,00	;line 1
	dc.b	01,20,18,09,05,15,03,00	;line 2
	dc.b	01,19,22,08,03,16,05,00	;line 3
	dc.b	01,23,24,12,04,17,05,00	;line 4
	dc.b	01,19,22,09,03,05,15,00	;line 5
	dc.b	01,20,24,08,04,15,03,00	;line 6
	dc.b	01,20,18,07,04,03,05,00	;line 7
	dc.b	01,19,22,06,05,03,09,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Stephane Fiset',	3553,3332,0000,3222	;1
	Player	'Jocelyn Thibault',	4153,3222,0000,2222	;2
	Player	'Joe Sakic',	1964,3543,29C5,5262	;3
	Player	'Mike Ricci',	0974,3433,3975,3245	;4
	Player	'Mats Sundin',	1374,4544,1C95,4143	;5
	Player	'Ron Sutter',	2263,3342,4473,4244	;6
	Player	'Claude Lapointe',	4753,4342,3B62,3124	;7
	Player	'Martin Rucinsky',	2553,2323,1763,3132	;8
	Player	'Valeri Kamensky',	3184,4425,2694,4152	;9
	Player	'Chris Simon',	12D2,1121,3751,0525	;10
	Player	'Tony Twist',	15A1,1101,3920,1414	;11
	Player	'Iain Fraser',	3873,3333,2763,3222	;12
	Player	'Chris Lindberg',	1773,4232,2733,2321	;13
	Player	'Bob Bassen',	2844,3222,3B33,3323	;14
	Player	'Owen Nolan',	1183,4425,2625,4334	;15
	Player	'Andrei Kovalenko',	5133,4433,3694,4232	;16
	Player	'Scott Young',	4873,5345,1863,3431	;17
	Player	'Garth Butcher',	5592,3142,5681,4335	;18
	Player	'Curtis Leschyshyn',	0793,4342,3764,5132	;19
	Player	'Alexei Gusarov',	0563,3333,3763,4132	;20
	Player	'Brad Werenka',	2793,3322,1963,2522	;21
	Player	'Dave Karpa',	5982,2232,3642,3324	;22
	Player	'Steven Finn',	2982,2233,3B72,3424	;23
	Player	'Tommy Sjodin',	0264,3324,2892,3331	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Quebec'
.ta	;abbreviation
	String	'QUE'
.tm	;nickname
	String	'Nordiques'
.ar	;arena
	String	'Colisee de Quebec'

SanJose	;SJ, $4452 (94 $3C42)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\SJh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\SJv95.pal
.sr	;4 bytes
	dc.w	$2402,$12E7
.sodds
	dc.b	212,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,17,19,14,03,16,10,00	;line 1
	dc.b	01,17,19,10,03,16,14,00	;line 2
	dc.b	01,18,20,08,04,14,03,00	;line 3
	dc.b	01,21,23,09,05,15,03,00	;line 4
	dc.b	01,17,19,10,03,16,14,00	;line 5
	dc.b	01,18,20,14,04,15,03,00	;line 6
	dc.b	01,21,23,09,05,03,14,00	;line 7
	dc.b	01,18,19,08,03,16,10,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Arturs Irbe',	3254,4443,0000,4444	;1
	Player	'Jim Waite',	2962,3222,0000,2222	;2
	Player	'Igor Larionov',	0745,3433,1795,3441	;3
	Player	'Todd Elik',	2773,4333,2963,3223	;4
	Player	'Jamie Baker',	1373,3343,3963,4232	;5
	Player	'Dale Craigwell',	3363,3232,3932,3221	;6
	Player	'Vachslav Butsayev',	0963,2323,2962,2123	;7
	Player	'Bob Errey',	1265,4242,4762,4523	;8
	Player	'Gaetan Duchesne',	1193,4242,3D63,4521	;9
	Player	'Johan Garpenlov',	1063,3332,1B64,3231	;10
	Player	'Ray Whitney',	1442,2323,1864,3231	;11
	Player	'Jeff Odgers',	3691,2222,2A53,3415	;12
	Player	'Rob Gaudreau',	3763,3332,3C63,4431	;13
	Player	'Ulf Dahlen',	2284,3434,3B94,5340	;14
	Player	'Pat Falloon',	1774,4423,1A63,4530	;15
	Player	'Sergei Makarov',	2465,4433,1B95,3252	;16
	Player	'Jeff Norton',	0885,4432,1762,4132	;17
	Player	'Vlastmil Kroupa',	2663,3322,1962,3221	;18
	Player	'Sandis Ozolinsh',	0673,4434,2B94,4242	;19
	Player	'Tom Pederson',	4141,2332,2862,2332	;20
	Player	'Shawn Cronin',	44A1,1011,2722,1514	;21
	Player	'Mike Rathje',	4083,2132,3971,3323	;22
	Player	'Jay More',	0473,2133,4642,3534	;23
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'San Jose'
.ta	;abbreviation
	String	'SJ'
.tm	;nickname
	String	'Sharks'
.ar	;arena
	String	'San Jose Arena'

StLouis	;STL, $4716 (94 $3F30)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\STLh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\STLv95.pal
.sr	;4 bytes
	dc.w	$3421,$21F7
.sodds
	dc.b	212,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,22,18,08,03,11,05,00	;line 1
	dc.b	01,24,18,08,03,11,05,00	;line 2
	dc.b	01,22,21,09,05,12,11,00	;line 3
	dc.b	01,20,23,07,04,13,11,00	;line 4
	dc.b	01,22,18,08,03,11,05,00	;line 5
	dc.b	01,24,19,05,04,12,11,00	;line 6
	dc.b	01,24,18,08,12,11,03,00	;line 7
	dc.b	01,20,21,13,11,03,08,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Curtis Joseph',	3165,4564,0000,4444	;1
	Player	'Jim Hrivnak',	2962,3222,0000,2222	;2
	Player	'Craig Janney',	1574,3543,27C4,4060	;3
	Player	'Peter Stastny',	2694,3433,3794,3241	;4
	Player	'Petr Nedved',	9353,3433,19C5,4342	;5
	Player	'Jim Montgomery',	1073,2322,2A62,3232	;6
	Player	'Basil McRae',	1792,2122,3751,3415	;7
	Player	'Brendan Shanahan',	19A3,3545,3AA5,4244	;8
	Player	'Vitali Prokhorov',	2573,3312,1763,2431	;9
	Player	'Dave Mackey',	2392,2223,2732,2323	;10
	Player	'Brett Hull',	1694,4536,3A94,4432	;11
	Player	'Kevin Miller',	1474,3443,3863,4333	;12
	Player	'Philippe Bozon',	3662,2232,1961,2523	;13
	Player	'Vitali Karamnov',	1272,2222,2762,3321	;14
	Player	'Igor Korolev',	3872,2232,2961,3021	;15
	Player	'Kelly Chase',	3981,1111,2851,2415	;16
	Player	'Denny Felsner',	0982,2222,2933,2422	;17
	Player	'Phil Housley',	0666,5533,27C2,4062	;18
	Player	'Doug Crossman',	3272,2322,2762,4031	;19
	Player	'Murray Baron',	34A3,3122,2971,2513	;20
	Player	'Rick Zombo',	0483,3133,3860,4022	;21
	Player	'Steve Duchesne',	2884,4444,1B92,4242	;22
	Player	'Tom Tilley',	2072,2121,2832,2421	;23
	Player	'Alexei Kasatonov',	07A4,3233,3761,3142	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'St. Louis'
.ta	;abbreviation
	String	'STL'
.tm	;nickname
	String	'Blues'
.ar	;arena
	String	'St. Louis Arena'

TampaBay	;TB, $49FE (94 $4216)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\TBYh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\TBYv95.pal
.sr	;4 bytes
	dc.w	$1000,$01D7
.sodds
	dc.b	196,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,18,17,03,04,14,10,00	;line 1
	dc.b	01,18,16,10,04,14,03,00	;line 2
	dc.b	01,17,19,08,03,13,04,00	;line 3
	dc.b	01,21,20,11,05,12,04,00	;line 4
	dc.b	01,17,16,03,04,14,10,00	;line 5
	dc.b	01,18,19,09,05,12,04,00	;line 6
	dc.b	01,18,19,08,05,04,10,00	;line 7
	dc.b	01,17,16,10,03,04,14,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Daren Puppa',	9394,4453,0100,3344	;1
	Player	'Wendell Young',	0163,3223,0000,2222	;2
	Player	'Chris Gratton',	7792,3324,3D72,3334	;3
	Player	'Brian Bradley',	1944,4434,2A64,4243	;4
	Player	'Denis Savard',	0955,3433,28C3,3043	;5
	Player	'Marc Bureau',	2872,2232,2862,3323	;6
	Player	'Gerard Gallant',	1762,2232,4742,3134	;7
	Player	'Danton Cole',	2473,3333,2A63,4421	;8
	Player	'Adam Creighton',	10A3,2322,2962,3432	;9
	Player	'Mikael Andersson',	3462,4232,2962,4531	;10
	Player	'Rob Zamuner',	0792,2232,3762,4323	;11
	Player	'Pat Elynuik',	1562,3313,1665,3321	;12
	Player	'John Tucker',	1492,3343,3663,4233	;13
	Player	'Petr Klima',	8575,5414,1895,4533	;14
	Player	'Jim Cummins',	1291,1111,2821,2415	;15
	Player	'Chris Joseph',	23A3,3313,3872,3234	;16
	Player	'Roman Hamrlik',	4473,2223,3761,3423	;17
	Player	'Shawn Chambers',	2292,2332,2762,3222	;18
	Player	'Marc Bergevin',	2562,3232,1B60,3322	;19
	Player	'Rudy Poeschek',	20A2,2122,3851,3324	;20
	Player	'Enrico Ciccone',	3992,1121,2921,3415	;21
	Player	'Eric Charron',	0382,1121,2911,2414	;22
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Tampa Bay'
.ta	;abbreviation
	String	'TB'
.tm	;nickname
	String	'Lightning'
.ar	;arena
	String	'Thunderdome'

Toronto	;TOR, $4CB6 (94 $4518)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\TORh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\TORv95.pal
.sr	;4 bytes
	dc.w	$5111,$10E8
.sodds
	dc.b	212,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,21,18,09,04,10,15,00	;line 1
	dc.b	01,17,18,09,04,15,10,00	;line 2
	dc.b	01,21,19,10,03,16,04,00	;line 3
	dc.b	01,23,22,11,07,14,04,00	;line 4
	dc.b	01,17,18,10,04,14,09,00	;line 5
	dc.b	01,21,19,09,03,15,04,00	;line 6
	dc.b	01,21,19,10,04,09,15,00	;line 7
	dc.b	01,17,18,15,07,04,09,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Felix Potvin',	2964,4664,0000,5454	;1
	Player	'Damian Rhodes',	0152,3223,0000,3322	;2
	Player	'Mike Eastwood',	3273,4332,2862,3222	;3
	Player	'Doug Gilmour',	9345,4554,4BC4,6043	;4
	Player	'John Cullen',	1974,3333,2664,4143	;5
	Player	'Mike Krushelski',	2693,3342,3763,4322	;6
	Player	'Peter Zezel',	2593,3243,4773,4141	;7
	Player	'Ken Baumgartnr',	2292,2022,3721,2325	;8
	Player	'Wendel Clark',	1783,3436,4774,4444	;9
	Player	'Dave Andreychuk',	14B3,2534,3A95,5432	;10
	Player	'Bill Berg',	1073,2232,4B73,4424	;11
	Player	'Kent Mandrville',	1883,3232,2962,3321	;12
	Player	'Mark Osborne',	2192,2242,3972,4423	;13
	Player	'Nikolai Borshevsky',	1664,4423,2594,4241	;14
	Player	'Mike Gartner',	2275,5425,2C63,5552	;15
	Player	'Rob Pearson',	1262,2333,2473,4525	;16
	Player	'Todd Gill',	2363,3332,3562,4123	;17
	Player	'Dave Ellett',	0495,4345,3991,4242	;18
	Player	'Dmitri Mironov',	1573,3333,1862,3132	;19
	Player	'Drake Berehowsky',	55A2,2232,3842,3123	;20
	Player	'Jamie Macoun',	3483,3244,4B71,4442	;21
	Player	'Bob Rouse',	03A3,3142,4871,4424	;22
	Player	'Sylvain Lefebvre',	0292,2131,3D70,4433	;23
	Player	'Matt Martin',	3372,2222,2962,3232	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Toronto'
.ta	;abbreviation
	String	'TOR'
.tm	;nickname
	String	'Maple Leafs'
.ar	;arena
	String	'Maple Leaf Gardens'

Vancouver	;VAN, $4FA8 (94 $481C)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\VANh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\VANv95.pal
.sr	;4 bytes
	dc.w	$5111,$10E8
.sodds
	dc.b	196,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,18,19,07,03,13,14,00	;line 1
	dc.b	01,24,19,07,03,13,14,00	;line 2
	dc.b	01,18,23,09,05,14,13,00	;line 3
	dc.b	01,21,22,08,04,11,13,00	;line 4
	dc.b	01,18,19,07,03,13,14,00	;line 5
	dc.b	01,17,23,09,04,14,13,00	;line 6
	dc.b	01,24,19,13,05,14,09,00	;line 7
	dc.b	01,18,22,14,06,09,07,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Kirk McLean',	0164,4444,0000,4444	;1
	Player	'Kay Whitmore',	3553,3452,0000,2323	;2
	Player	'Cliff Ronning',	0755,5432,19C3,5141	;3
	Player	'Jimmy Carson',	1794,4423,1964,4331	;4
	Player	'Murray Craven',	3263,3333,3964,3131	;5
	Player	'John McIntyre',	1572,2132,3771,4222	;6
	Player	'Geoff Courtnall',	1475,5444,1B62,3344	;7
	Player	'Gino Odjick',	29A3,2233,4982,3326	;8
	Player	'Greg Adams',	0874,4433,3564,4132	;9
	Player	'Shawn Antoski',	18C1,1112,3921,2325	;10
	Player	'Sergio Momesso',	27A4,3334,5772,4424	;11
	Player	'Tim Hunter',	2692,2122,3652,2325	;12
	Player	'Pavel Bure',	1056,6625,29C5,4542	;13
	Player	'Trevor Linden',	1693,3444,3CA4,4342	;14
	Player	'Martin Gelinas',	2383,3223,2763,2432	;15
	Player	'Jose Charboneau',	2082,3223,2874,2423	;16
	Player	'Bret Hedican',	0382,2222,2760,3322	;17
	Player	'Jyrki Lumme',	2174,3443,1B91,4142	;18
	Player	'Jeff Brown',	2294,3445,2693,5152	;19
	Player	'Adrien Plavsic',	0672,2232,3762,3123	;20
	Player	'Jiri Slegr',	2494,4333,2961,4134	;21
	Player	'Dave Babych',	44A2,2343,2960,4232	;22
	Player	'Dana Murzyn',	0592,2234,3B61,4423	;23
	Player	'Gerald Diduck',	0494,4132,4871,3234	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Vancouver'
.ta	;abbreviation
	String	'VAN'
.tm	;nickname
	String	'Canucks'
.ar	;arena
	String	'General Motors Place'

Winnipeg	;WPG, $528E (94 $4B0A)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\WPGh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\WPGv95.pal
.sr	;4 bytes
	dc.w	$2012,$02E8
.sodds
	dc.b	166,0
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,22,19,08,03,13,04,00	;line 1
	dc.b	01,22,19,08,03,13,04,00	;line 2
	dc.b	01,20,21,11,04,15,13,00	;line 3
	dc.b	01,17,23,09,05,16,13,00	;line 4
	dc.b	01,22,19,08,03,13,04,00	;line 5
	dc.b	01,20,21,05,04,15,13,00	;line 6
	dc.b	01,20,21,08,15,03,13,00	;line 7
	dc.b	01,22,19,09,05,03,13,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Tim Cheveldae',	2963,4443,0000,3333	;1
	Player	'Mike O''Neill',	0142,2222,0000,2212	;2
	Player	'Alexei Zhamnov',	1075,3443,2793,4142	;3
	Player	'Thomas Steen',	2583,3333,3794,3053	;4
	Player	'Dallas Drake',	1844,4343,2993,4134	;5
	Player	'Mike Eagles',	3673,3142,4962,5123	;6
	Player	'Randy Gilhen',	1572,2142,3761,4422	;7
	Player	'Keith Tkachuk',	0793,3444,4DA4,4434	;8
	Player	'Kris King',	17A3,3242,4B92,4324	;9
	Player	'Russ Romaniuk',	2163,2122,3963,2522	;10
	Player	'Darrin Shannon',	3493,2333,3B73,4232	;11
	Player	'John LeBlanc',	3772,2213,2963,2422	;12
	Player	'Teemu Selanne',	1365,6524,38C5,5442	;13
	Player	'Luciano Borsato',	3843,3232,2863,3231	;14
	Player	'Nelson Emerson',	1944,4434,2A94,4242	;15
	Player	'Tie Domi',	2093,2233,3A83,4126	;16
	Player	'Wayne McBean',	0672,2213,2931,3322	;17
	Player	'Darryl Shannon',	2492,1012,3930,3322	;18
	Player	'Teppo Numminen',	2774,3333,3662,4132	;19
	Player	'Stephane Quintal',	04B2,2132,4A71,4433	;20
	Player	'Igor Ulanov',	0593,2242,4860,4024	;21
	Player	'Dave Manson',	0394,4325,4981,5434	;22
	Player	'Dean Kennedy',	2692,2132,3840,4423	;23
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Winnipeg'
.ta	;abbreviation
	String	'WPG'
.tm	;nickname
	String	'Jets'
.ar	;arena
	String	'Winnipeg Arena'

Washington	;WSH, $5556 (94 $4DFC)
.0
	dc.w	.pld-.0
	dc.w	.pad-.0
	dc.w	.tn-.0
	dc.w	.ls-.0
	dc.w	.sr-.0
	dc.w	.sodds-.0
.pad
	incbin	..\Extracted\NHL95\Graphics\Pals\WSHh95.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\WSHv95.pal
.sr	;4 bytes
	dc.w	$2711,$11E7
.sodds
	dc.b	164,32
.ls	;		-G,LD,RD,LW,-C,RW,XA,00. 8 lines
	dc.b	01,20,18,10,04,05,13,00	;line 1
	dc.b	01,21,18,10,05,13,04,00	;line 2
	dc.b	01,20,22,12,04,17,05,00	;line 3
	dc.b	01,23,19,09,06,07,05,00	;line 4
	dc.b	01,21,18,07,05,13,04,00	;line 5
	dc.b	01,20,22,10,04,06,05,00	;line 6
	dc.b	01,24,18,09,04,05,10,00	;line 7
	dc.b	01,21,20,12,06,05,10,00	;line 8
.pld	;							unwl,sodp,chga,eytm
	Player	'Don Beaupre',	3343,4333,0000,4343	;1
	Player	'Rick Tabaracci',	3163,3112,0000,3332	;2
	Player	'Byron Dafoe',	3542,2102,0000,2222	;3
	Player	'Mike Ridley',	1794,4433,2B95,4042	;4
	Player	'Joe Juneau',	9054,5534,28C3,4051	;5
	Player	'Dale Hunter',	3282,2443,4974,4146	;6
	Player	'Michal Pivonka',	2083,4433,3793,3042	;7
	Player	'Dave Poulin',	0973,2242,3762,3132	;8
	Player	'Kelly Miller',	1084,4333,2D63,4142	;9
	Player	'Dimitri Khristich',	0873,3433,3896,4242	;10
	Player	'Craig Berube',	2792,2212,3B52,2415	;11
	Player	'Randy Burridge',	1873,2333,3965,3333	;12
	Player	'Peter Bondra',	1264,6433,1794,4432	;13
	Player	'Steve Konowlchuk',	2262,2222,3962,2322	;14
	Player	'Todd Krygier',	2162,4232,2942,3512	;15
	Player	'Keith Jones',	2672,3332,4873,3235	;16
	Player	'Pat Peake',	1484,3323,1463,3421	;17
	Player	'Kevin Hatcher',	04B3,3445,5872,4444	;18
	Player	'Joe Reekie',	29A3,2232,3D72,3323	;19
	Player	'Sylvain Cote',	0363,3343,3C72,4333	;20
	Player	'Calle Johansson',	0694,4343,2D62,4142	;21
	Player	'Jim Johnson',	0273,2143,3772,4233	;22
	Player	'Shawn Anderson',	3692,2122,3961,2321	;23
	Player	'Jon Slaney',	2873,3223,2963,2521	;24
	dc.w	2	;end of the player list: an empty String
.tn	;city
	String	'Washington'
.ta	;abbreviation
	String	'WSH'
.tm	;nickname
	String	'Capitals'
.ar	;arena
	String	'US Air Arena'

playoffseats	;$5834 (94 $5576). 93 / 94 name. movea.l #$5834 in the playoff tree setup (IDA loc_879FA, sub_87A5E). 32 rows of 16 team numbers, as 94
	dc.b	19,22,10,6, 23,5,3,4, 1,14,11,12, 17,16,2,8
	dc.b	7,25,19,6, 10,22,23,4, 18,13,9,21, 15,14,1,12
	dc.b	3,5,0,25, 7,20,19,5, 1,13,11,15, 17,24,2,12
	dc.b	19,25,10,20, 23,4,3,5, 1,21,11,13, 17,8,2,16
	dc.b	7,22,0,6, 3,5,23,25, 18,24,9,12, 15,14,2,17
	dc.b	3,25,23,22, 10,4,19,20, 1,8,17,13, 9,12,14,2
	dc.b	19,10,23,3, 0,7,22,6, 1,11,17,2, 18,9,15,14
	dc.b	5,4,20,25, 6,19,10,22, 12,24,16,8, 13,21,14,1

	dc.b	23,7,3,0, 19,5,10,4, 17,9,2,18, 14,21,12,13
	dc.b	25,5,20,6, 4,22,23,3, 1,13,11,8, 17,16,15,18
	dc.b	19,4,22,3, 10,23,6,5, 1,8,14,2, 11,17,12,16
	dc.b	6,19,3,23, 22,4,5,20, 14,13,17,24, 12,2,1,11
	dc.b	6,20,19,5, 3,22,23,4, 14,11,13,1, 17,12,24,2
	dc.b	6,4,20,23, 5,22,3,19, 14,2,11,24, 13,17,1,12
	dc.b	6,23,4,3, 20,22,5,19, 14,12,2,1, 11,13,24,17
	dc.b	6,19,23,5, 4,20,3,22, 14,17,12,24, 2,11,1,13

	dc.b	6,22,19,3, 23,4,5,20, 14,13,17,1, 12,2,24,11
	dc.b	6,20,22,5, 19,23,3,4, 14,11,13,24, 17,12,1,2
	dc.b	6,4,20,3, 22,19,5,23, 14,2,11,1, 13,17,24,12
	dc.b	6,23,4,5, 20,22,3,19, 14,12,2,24, 11,13,1,17
	dc.b	6,19,23,3, 4,20,5,22, 14,17,12,1, 2,11,24,13
	dc.b	6,22,19,5, 23,4,3,20, 14,13,17,24, 12,1,11,2
	dc.b	7,22,19,5, 0,4,25,23, 21,11,15,1, 17,8,14,18
	dc.b	7,23,22,25, 19,0,5,4, 21,18,11,14, 15,17,1,8

	dc.b	7,4,23,5, 22,19,25,0, 21,8,18,1, 11,15,14,17
	dc.b	7,0,4,25, 23,22,5,19, 21,17,8,14, 18,11,1,15
	dc.b	3,10,6,19, 23,5,4,0, 13,9,2,16, 17,18,14,1
	dc.b	3,0,10,4, 6,23,19,5, 13,1,9,14, 2,17,16,18
	dc.b	3,5,0,19, 10,6,4,23, 13,18,16,1, 9,2,14,17
	dc.b	3,23,5,4, 0,10,19,6, 13,17,18,14, 16,9,1,2
	dc.b	3,6,23,19, 5,0,4,10, 13,2,17,1, 18,16,14,9
	dc.b	3,10,6,4, 23,5,19,0, 13,9,2,14, 17,18,1,16
