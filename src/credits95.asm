;	NHL 95 credits95. Retail $1A6C28-$1A72BF (1688 bytes).
;	The title screen credits (94 teamdata94 Credits / CreditsList): length-prefixed Strings, String -1 ends a screen; newTitleScreen
;	prints Credits first, then CreditsList (CreditsPrintRow).

	include	macros\genesis.mac	;String (main95.asm includes it in the full build)

Credits	;no IDA label. 94 / 93 Credits. Title screen scroller: the copyright and trademark lines
	String	'$ 1994 Electronic Arts'
	String	'Licensed by'
	String	'Sega Enterprises, Ltd.'
	String	-1

CreditsList	;no IDA label. 94 / 93 CreditsList. The credits after the copyright lines
	String	'NHL and NHL logo are'
	String	'registered trademarks of the'
	String	'National Hockey League.'
	String	-1

	String	'The Stanley Cup is a'
	String	'registered trademark of the'
	String	'National Hockey League.'
	String	-1

	String	'NHLPA, National Hockey League'
	String	'Players',$27,' Association and the'
	String	'logo of the NHLPA are'
	String	'Trademarks of NHLPA.'
	String	-1

	String	'Officially Licensed Product'
	String	'of the National Hockey League'
	String	'Players',$27,' Association.'
	String	-1

	String	'Team names and logos depicted'
	String	'are Officially Licensed'
	String	'Trademarks of the National'
	String	'Hockey League. $ NHL 1994.'
	String	-1

	String	'Used under license by'
	String	'Electronic Arts, Inc.'
	String	-1

	String	'EA Sports and the EA Sports'
	String	'Logo are trademarks of'
	String	'Electronic Arts.'
	String	-1

	String	'Programmed by'
	String	'Mark Lesser'
	String	-1

	String	'Design by'
	String	'Michael Brook and'
	String	'Scott Probin'
	String	-1

	String	'Art by'
	String	'Doug Wike'
	String	'Lori Champney'
	String	-1

	String	'Art by'
	String	'Cynthia Hamilton'
	String	'Terry Falls'
	String	'Ian House'
	String	-1

	String	'Art by'
	String	'Kendra Lammas'
	String	'Alyson Markell'
	String	-1

	String	'Music by'
	String	'Russell Lieblich'
	String	-1

	String	'Sound Design by'
	String	'Rob Hubbard'
	String	-1

	String	'Organ Music by'
	String	'Dieter Ruehle'
	String	-1

	String	'Executive Producer'
	String	'Scott Orr'
	String	-1

	String	'Producer'
	String	'Rob Martyn'
	String	-1

	String	'Associate Producer'
	String	'Scott Probin'
	String	-1

	String	'Technical Directors'
	String	'Colin McLaughlan'
	String	'Rob Harris'
	String	-1

	String	'Lead Tester'
	String	'Ted Fitzgerald'
	String	-1

	String	'Testing by'
	String	'Craig Wike'
	String	'Michael Streim'
	String	-1

	String	'Testing by'
	String	'Dave Newhouse'
	String	'Mike Graben'
	String	'Chip Lange'
	String	-1

	String	'Testing by'
	String	'Ken Rogers'
	String	-1

	String	'Mastered by'
	String	'John Williams'
	String	-1

	String	'Player Ratings by'
	String	'John Rosasco and'
	String	'Neil Smith of the'
	String	'New York Rangers'
	String	-1

	String	'Player Portraits by'
	String	'Steve Babineau'
	String	-1

	String	'Special Thanks to'
	String	'Chip Lange'
	String	'Kyra Woody'
	String	-1

	String	'Special Thanks to'
	String	'Kevin Hogan'
	String	'Keith Francart'
	String	'Jim Sproul'
	String	-1

	String	'Developed by'
	String	'InPlay Sports'
	String	-1

	String	'EA Hockey'
	String	'League Champion'
	String	'Ken Rogers'
	String	-1

	dc.w	2	;empty String (93: String '')
	String	-1

	String	-1

	dc.w	-1	;the end of the credits
