;
;	Top level of the full NHL 95 ROM build (build95.bat, npm run build:retail). The listing is output\nhl95 .lst.
;	The includes are in the 94 ROM order. No 95 org is confirmed. Confirm each start against lst/nhl95.bin.lst before a segment build.
;	The org for a segment build goes in its _stub.asm. Do not put an org in a file this list includes.
;	ram95.asm has no bytes. The ports, VDP status bits and RAM names are in stubinc.
;
	include	stubinc\ports.inc	;IO_* / VDP_* ports. Equates only
	include	stubinc\equals.inc	;VDP status bits. Equates only
	include	stubinc\ram_addrs.inc	;RAM names. Equates only

	include	main95.asm		;          Adapted from main94.asm: header, startup, vectors
	include	teamdata95.asm		;          Adapted from teamdata94.asm: teams, palettes, credits text
	include	frames95.asm		;          Adapted from frames94.asm: sprite animation tables
	include	ram95.asm		;          Adapted from ram94.asm: equates only
	include	hockey95.asm		;          Adapted from hockey94.asm: game loop, pause
	include	menu95.asm		;          Adapted from menu94.asm: menu core
	include	stats95.asm		;          Adapted from stats94.asm: scores, line editor, roster, scoring and penalty summaries, player stats, crowd meter, goalie select
	include	replay95.asm		;          Adapted from replay94.asm: replay
	include	input95.asm		;          Adapted from input94.asm: controller input and line changes
	include	assign95.asm		;          Adapted from assign94.asm: player assignments
	include	checks95.asm		;          Adapted from checks94.asm: checks before the display code
	include	video95.asm		;          Adapted from video94.asm: display helpers
	include	penalty95.asm		;          Adapted from penalty94.asm: penalties, scoreboard, highlights
	include	collide95.asm		;          Adapted from collide94.asm: puck, players, walls, fights, goals
	include	display95.asm		;          Adapted from display94.asm: vblank, clock, crowd, rink scroll
	include	setup95.asm		;          Adapted from setup94.asm: ice setup, intermission, playoff screen
	include	attract95.asm		;          Adapted from attract94.asm: EA Sports attract screen
	include	data95.asm		;          Adapted from data94.asm: menus, season results, string tables
	include	sram95.asm		;          Adapted from sram94.asm: save data
	include	sound95.asm		;          Adapted from sound94.asm: sound driver, then the sound data
	include	graphics95.asm		;          Adapted from graphics94.asm: graphics only
	include	onetimer95.asm		;          Adapted from onetimer94.asm: one-timer
	include	fourway95.asm		;          Adapted from fourway94.asm: four-player adaptor
	include	crowd95.asm		;          Adapted from crowd94.asm: crowd meter and hot / cold players
	include	optsetup95.asm		;          Adapted from optsetup94.asm: game setup and options
	include	cards95.asm		;          Adapted from cards94.asm: player cards and matchup palettes
	include	records95.asm		;          Adapted from records94.asm: name entry and record holders
	include	shootout95.asm		;          Adapted from shootout94.asm: shootout
	include	scout95.asm		;          Adapted from scout94.asm: matchups and scouting report
	include	period95.asm		;          Adapted from period94.asm: period stats and game statistics
	include	goalie95.asm		;          Adapted from goalie94.asm: manual goalie
	include	title95.asm		;          Adapted from title94.asm: song select, title, credits
	include	checksum95.asm		;          Adapted from checksum94.asm: checksum
	dcb.b	$200000-*,$FF		;fill to the 2 MB ROM end
