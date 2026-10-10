;
;	Top level of the full NHL 95 ROM build (build95.bat, npm run build:retail). The listing is output\nhl95 .lst.
;	The includes are in 95 ROM order, from the fingerprint map tools/segmap95.json (tools/fingerprint_map.py).
;	The address on each include line is the mapped lst/nhl95.bin start. It is provisional until the segment matches.
;	The org for a segment build goes in its _stub.asm. Do not put an org in a file this list includes.
;	ram95.asm has no bytes. The ports, VDP status bits and RAM names are in stubinc.
;
	include	stubinc\ports.inc	;IO_* / VDP_* ports. Equates only
	include	stubinc\equals.inc	;VDP status bits. Equates only
	include	stubinc\ram_addrs.inc	;RAM names. Equates only

	include	main95.asm		; $000000  Adapted from main94.asm: header, startup, vectors
	include	teamdata95.asm		; $000772  Adapted from teamdata94.asm: teams, palettes, credits text
	include	frames95.asm		; $005A34  Adapted from frames94.asm: sprite animation tables
	include	schedule95.asm		; $008DD8  New in 95: season schedule data
	include	ram95.asm		;          Adapted from ram94.asm: equates only
	include	sram95.asm		; $009722  Adapted from sram94.asm: save data
	include	hockey95.asm		; $009AC8  Adapted from hockey94.asm: game flow: StartGame, StartPer
	include	display95_01.asm		; $00A204  Adapted from display94.asm: vblank, clock, crowd, rink scroll
	include	replay95_01.asm		; $00A536  Adapted from replay94.asm: replay
	include	setup95_01.asm		; $00A656  Adapted from setup94.asm: ice setup, intermission, playoff screen
	include	sounddrv95.asm		; $00AF44  New in 95: sound driver, Z80 program, sound bank
	include	sound95_01.asm		; $0676D8  Adapted from sound94.asm: sound calls, the 94 driver remnant, then the 94 samples and patches
	include	video95_01.asm		; $079902  Adapted from video94.asm: display helpers
	include	display95_02.asm		; $079D80  Adapted from display94.asm: vblank, clock, crowd, rink scroll
	include	video95_02.asm		; $07A02A  Adapted from video94.asm: display helpers
	include	collide95_01.asm		; $07A762  Adapted from collide94.asm: puck, players, walls, fights, goals
	include	video95_03.asm		; $07C512  Adapted from video94.asm: display helpers
	include	fourway95.asm		; $07DEA0  Adapted from fourway94.asm: four-player adaptor
	include	sound95_02.asm		; $07E0E0  Adapted from sound94.asm: sound driver, then the sound data
	include	hockey95_02.asm		; $07E36C  Adapted from hockey94.asm: pause mode
	include	menu95.asm		; $07E4D6  Adapted from menu94.asm: menu core
	include	checks95_01.asm		; $07F97E  Adapted from checks94.asm: checks before the display code
	include	assign95_01.asm		; $0807EC  Adapted from assign94.asm: player assignments
	include	checks95_02.asm		; $080BEA  Adapted from checks94.asm: checks before the display code
	include	assign95_02.asm		; $08282E  Adapted from assign94.asm: player assignments
	include	onetimer95.asm		; $082BD0  Adapted from onetimer94.asm: one-timer
	include	checks95_08.asm		; $082FC2  Adapted from checks94.asm: assshoot
	include	checks95_03.asm		; $082FFA  Adapted from checks94.asm: checks before the display code
	include	collide95_02.asm		; $0836AC  Adapted from collide94.asm: puck, players, walls, fights, goals
	include	input95_01.asm		; $083EB2  Adapted from input94.asm: controller input and line changes
	include	data95_01.asm		; $084FE6  Adapted from data94.asm: menus, season results, string tables
	include	setup95_02.asm		; $087BA2  Adapted from setup94.asm: ice setup, intermission, playoff screen
	include	checks95_04.asm		; $088046  Adapted from checks94.asm: checks before the display code
	include	penalty95.asm		; $088F06  Adapted from penalty94.asm: penalties, scoreboard, highlights
	include	data95_02.asm		; $08996E  Adapted from data94.asm: menus, season results, string tables
	include	input95_02.asm		; $08A056  Adapted from input94.asm: controller input and line changes
	include	checks95_05.asm		; $08A3FE  Adapted from checks94.asm: checks before the display code
	include	input95_03.asm		; $08B734  Adapted from input94.asm: controller input and line changes
	include	checks95_06.asm		; $08B9A8  Adapted from checks94.asm: checks before the display code
	include	replay95.asm		; $08D39A  Adapted from replay94.asm: replay
	include	season95.asm		; $08DF5A  New in 95: season mode
	include	period95.asm		; $0920DE  Adapted from period94.asm: period stats and game statistics
	include	stats95_01.asm		; $0925AE  Adapted from stats94.asm: scores, line editor, roster, scoring and penalty summaries, player stats, crowd meter, goalie select
	include	trade95.asm		; $0962EE  New in 95: schedule and trades
	include	create95.asm		; $097C54  New in 95: create player
	include	cards95_01.asm		; $09ACE6  Adapted from cards94.asm: player cards and matchup palettes
	include	records95.asm		; $09B6F4  Adapted from records94.asm: name entry and record holders
	include	cards95_02.asm		; $09C01A  Adapted from cards94.asm: player cards and matchup palettes
	include	awards95.asm		; $09C6F0  New in 95: end of season awards
	include	title95_01.asm		; $09DA50  Adapted from title94.asm: song select, title, credits
	include	shootout95.asm		; $09DD3E  Adapted from shootout94.asm: shootout
	include	checks95_07.asm		; $09E5F0  Adapted from checks94.asm: checks before the display code
	include	scout95.asm		; $09F590  Adapted from scout94.asm: matchups and scouting report
	include	setup95_03.asm		; $0A00D6  Adapted from setup94.asm: ice setup, intermission, playoff screen
	include	stats95_02.asm		; $0A0B3E  Adapted from stats94.asm: scores, line editor, roster, scoring and penalty summaries, player stats, crowd meter, goalie select
	include	title95_02.asm		; $0A12AA  Adapted from title94.asm: song select, title, credits
	include	graphics95_01.asm		; $0A1A5A  Adapted from graphics94.asm: graphics only
	include	title95_03.asm		; $1A169A  Adapted from title94.asm: song select, title, credits
	include	graphics95_02.asm		; $1A1A1A  Adapted from graphics94.asm: graphics only
	include	credits95.asm		; $1A6C28  Adapted from teamdata94.asm: credits text and list
	include	checksum95.asm		; $1A72C0  Adapted from checksum94.asm: checksum
	dcb.b	$200000-*,$FF		;fill to the 2 MB ROM end
