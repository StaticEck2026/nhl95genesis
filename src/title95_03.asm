;	NHL 95 title95_03. Retail $1A169A-$1A1A19 (896 bytes).
;	Mapped to title94 (100%): TeamLogoPalettes, one 32 byte palette per team in TeamList order. 25 are the same bytes as the 94 files
;	and keep their 94 names; DAL, ASE and ASW differ and are the 94 stem with 95 added.

TeamLogoPalettes	;IDA: unk_1A169A. title94 TeamLogoPalettes. Team logo palettes, 16 colors per team (DrawMatchupLogo, NameEntryScreen, DrawTeamBitmap)
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalANHA.pal	;ANH, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\TeamLogoPalBOS.pal	;BOS, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalBUFA.pal	;BUF, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalCGYA.pal	;CGY, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalCHIA.pal	;CHI, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalDALA95.pal	;DAL, differs from 94 MatchupPalDALA.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalDETA.pal	;DET, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalEDMA.pal	;EDM, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\TeamLogoPalFLA.pal	;FLA, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\TeamLogoPalHFD.pal	;HFD, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalLAA.pal	;LA, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalMTLA.pal	;MTL, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalNJA.pal	;NJ, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalNYIA.pal	;NYI, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalNYRA.pal	;NYR, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalOTWA.pal	;OTW, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalPHIA.pal	;PHI, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalPITA.pal	;PIT, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalQUEA.pal	;QUE, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\TeamLogoPalSJ.pal	;SJ, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalSTLA.pal	;STL, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalTBA.pal	;TB, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalTORA.pal	;TOR, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalVANA.pal	;VAN, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalWSHA.pal	;WSH, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalWPGA.pal	;WPG, 94 file, same bytes
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalASEA95.pal	;ASE, differs from 94 MatchupPalASEA.pal
	incbin	..\Extracted\NHL95\Graphics\Pals\MatchupPalASWA95.pal	;ASW, differs from 94 MatchupPalASWA.pal
