;	NHL 95 graphics95_01. Retail $0A1A5A-$1A1699 (1047616 bytes).
;	graphics94 data: the player pictures (FeaturedPicIdx / FeaturedPictures), the rink, the sprites, the fonts and the screen maps and
;	bitmaps, up to the team logos. incbin only (plus the two FeaturedPictures tables), no gap and no overlap. Each file is a slice of
;	lst/nhl95.bin written by npm run extractassets (extractAssets95.js) into Extracted\NHL95\Graphics. One slice per asset referenced by
;	the code (the names the code segments use), one per FeaturedPictures picture (Card<player>, the line 1 starter of the first team that
;	lists it). A map starts with its 8-byte header (palette and map offsets): a reference to its tiles is Label+8.

NoPlayerPicture	;retail $A1A5A-$A1E8F (1078 bytes). 94 PicturePalette: the player picture palette, then the picture of a player with none (DrawMatchupPicture, PlayerCardScreen)
	incbin	..\Extracted\NHL95\Graphics\NoPlayerPicture.map.jim
NoPicSkater2	;retail $A1E90-$A21F9 (874 bytes). generic skater picture (GetPlayerPicture, hand bit 0 set)
	incbin	..\Extracted\NHL95\Graphics\NoPicSkater2.bin
NoPicSkater1	;retail $A21FA-$A2563 (874 bytes). generic skater picture (GetPlayerPicture, hand bit 0 clear)
	incbin	..\Extracted\NHL95\Graphics\NoPicSkater1.bin
NoPicGoalie2	;retail $A2564-$A28CD (874 bytes). generic goalie picture (GetPlayerPicture, hand bit 0 clear)
	incbin	..\Extracted\NHL95\Graphics\NoPicGoalie2.bin
NoPicGoalie1	;retail $A28CE-$A2C37 (874 bytes). generic goalie picture (GetPlayerPicture, hand bit 0 set)
	incbin	..\Extracted\NHL95\Graphics\NoPicGoalie1.bin
CardGuyHebert	;retail $A2C38-$A2FA1 (874 bytes). Guy Hebert player picture (FeaturedPictures ANH 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardGuyHebert.bin
CardBobCorkum	;retail $A2FA2-$A330B (874 bytes). Bob Corkum player picture (FeaturedPictures ANH 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBobCorkum.bin
CardTerryYake	;retail $A330C-$A3675 (874 bytes). Terry Yake player picture (FeaturedPictures ANH 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardTerryYake.bin
CardGarryValk	;retail $A3676-$A39DF (874 bytes). Garry Valk player picture (FeaturedPictures ANH 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardGarryValk.bin
CardSeanHill	;retail $A39E0-$A3D49 (874 bytes). Sean Hill player picture (FeaturedPictures ANH 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSeanHill.bin
CardBillHoulder	;retail $A3D4A-$A40B3 (874 bytes). Bill Houlder player picture (FeaturedPictures ANH 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBillHoulder.bin
CardJonCasey	;retail $A40B4-$A441D (874 bytes). Jon Casey player picture (FeaturedPictures BOS 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJonCasey.bin
CardAdamOates	;retail $A441E-$A4787 (874 bytes). Adam Oates player picture (FeaturedPictures BOS 4, ASE 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAdamOates.bin
CardBryanSmolinski	;retail $A4788-$A4AF1 (874 bytes). Bryan Smolinski player picture (FeaturedPictures BOS 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBryanSmolinski.bin
CardCamNeely	;retail $A4AF2-$A4E5B (874 bytes). Cam Neely player picture (FeaturedPictures BOS 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardCamNeely.bin
CardRayBourque	;retail $A4E5C-$A51C5 (874 bytes). Ray Bourque player picture (FeaturedPictures BOS 1, ASE 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardRayBourque.bin
CardAlIafrate	;retail $A51C6-$A552F (874 bytes). Al Iafrate player picture (FeaturedPictures BOS 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAlIafrate.bin
CardDominikHasek	;retail $A5530-$A5899 (874 bytes). Dominik Hasek player picture (FeaturedPictures BUF 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDominikHasek.bin
CardPatLaFontaine	;retail $A589A-$A5C03 (874 bytes). Pat LaFontaine player picture (FeaturedPictures BUF 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPatLaFontaine.bin
CardDaleHawerchuk	;retail $A5C04-$A5F6D (874 bytes). Dale Hawerchuk player picture (FeaturedPictures BUF 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDaleHawerchuk.bin
CardAlexnderMogilny	;retail $A5F6E-$A62D7 (874 bytes). Alexnder Mogilny player picture (FeaturedPictures BUF 5, ASE 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAlexnderMogilny.bin
CardDougBodger	;retail $A62D8-$A6641 (874 bytes). Doug Bodger player picture (FeaturedPictures BUF 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDougBodger.bin
CardPetrSvoboda	;retail $A6642-$A69AB (874 bytes). Petr Svoboda player picture (FeaturedPictures BUF 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPetrSvoboda.bin
CardMikeVernon	;retail $A69AC-$A6D15 (874 bytes). Mike Vernon player picture (FeaturedPictures CGY 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMikeVernon.bin
CardJoeNieuwendyk	;retail $A6D16-$A707F (874 bytes). Joe Nieuwendyk player picture (FeaturedPictures CGY 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJoeNieuwendyk.bin
CardGaryRoberts	;retail $A7080-$A73E9 (874 bytes). Gary Roberts player picture (FeaturedPictures CGY 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardGaryRoberts.bin
CardTheorenFleury	;retail $A73EA-$A7753 (874 bytes). Theoren Fleury player picture (FeaturedPictures CGY 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardTheorenFleury.bin
CardZarleyZalapski	;retail $A7754-$A7ABD (874 bytes). Zarley Zalapski player picture (FeaturedPictures CGY 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardZarleyZalapski.bin
CardAlMacInnis	;retail $A7ABE-$A7E27 (874 bytes). Al MacInnis player picture (FeaturedPictures CGY 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAlMacInnis.bin
CardEdBelfour	;retail $A7E28-$A8191 (874 bytes). Ed Belfour player picture (FeaturedPictures CHI 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardEdBelfour.bin
CardJeremyRoenick	;retail $A8192-$A84FB (874 bytes). Jeremy Roenick player picture (FeaturedPictures CHI 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJeremyRoenick.bin
CardMichelGoulet	;retail $A84FC-$A8865 (874 bytes). Michel Goulet player picture (FeaturedPictures CHI 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMichelGoulet.bin
CardJoeMurphy	;retail $A8866-$A8BCF (874 bytes). Joe Murphy player picture (FeaturedPictures CHI 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJoeMurphy.bin
CardChrisChelios	;retail $A8BD0-$A8F39 (874 bytes). Chris Chelios player picture (FeaturedPictures CHI 2, ASW 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardChrisChelios.bin
CardSteveSmith	;retail $A8F3A-$A92A3 (874 bytes). Steve Smith player picture (FeaturedPictures CHI 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSteveSmith.bin
CardAndyMoog	;retail $A92A4-$A960D (874 bytes). Andy Moog player picture (FeaturedPictures DAL 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAndyMoog.bin
CardMikeModano	;retail $A960E-$A9977 (874 bytes). Mike Modano player picture (FeaturedPictures DAL 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMikeModano.bin
CardDaveGagner	;retail $A9978-$A9CE1 (874 bytes). Dave Gagner player picture (FeaturedPictures DAL 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDaveGagner.bin
CardRussCourtnall	;retail $A9CE2-$AA04B (874 bytes). Russ Courtnall player picture (FeaturedPictures DAL 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardRussCourtnall.bin
CardMarkTinordi	;retail $AA04C-$AA3B5 (874 bytes). Mark Tinordi player picture (FeaturedPictures DAL 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMarkTinordi.bin
CardDerianHatcher	;retail $AA3B6-$AA71F (874 bytes). Derian Hatcher player picture (FeaturedPictures DAL 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDerianHatcher.bin
CardBobEssensa	;retail $AA720-$AAA89 (874 bytes). Bob Essensa player picture (FeaturedPictures DET 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBobEssensa.bin
CardSteveYzerman	;retail $AAA8A-$AADF3 (874 bytes). Steve Yzerman player picture (FeaturedPictures DET 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSteveYzerman.bin
CardSergeiFedorov	;retail $AADF4-$AB15D (874 bytes). Sergei Fedorov player picture (FeaturedPictures DET 3, ASW 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSergeiFedorov.bin
CardDinoCiccarelli	;retail $AB15E-$AB4C7 (874 bytes). Dino Ciccarelli player picture (FeaturedPictures DET 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDinoCiccarelli.bin
CardPaulCoffey	;retail $AB4C8-$AB831 (874 bytes). Paul Coffey player picture (FeaturedPictures DET 2, ASW 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPaulCoffey.bin
CardSteveChiasson	;retail $AB832-$ABB9B (874 bytes). Steve Chiasson player picture (FeaturedPictures DET 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSteveChiasson.bin
CardBillRanford	;retail $ABB9C-$ABF05 (874 bytes). Bill Ranford player picture (FeaturedPictures EDM 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBillRanford.bin
CardDougWeight	;retail $ABF06-$AC30B (1030 bytes). Doug Weight player picture (FeaturedPictures EDM 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDougWeight.bin
CardShayneCorson	;retail $AC30C-$AC675 (874 bytes). Shayne Corson player picture (FeaturedPictures EDM 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardShayneCorson.bin
CardZdenoCiger	;retail $AC676-$ACA7B (1030 bytes). Zdeno Ciger player picture (FeaturedPictures EDM 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardZdenoCiger.bin
CardIgorKravchuk	;retail $ACA7C-$ACDE5 (874 bytes). Igor Kravchuk player picture (FeaturedPictures EDM 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardIgorKravchuk.bin
CardBobBeers	;retail $ACDE6-$AD14F (874 bytes). Bob Beers player picture (FeaturedPictures EDM 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBobBeers.bin
CardJohnVanbiesbrk	;retail $AD150-$AD4B9 (874 bytes). John Vanbiesbrk player picture (FeaturedPictures FLA 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJohnVanbiesbrk.bin
CardJesseBelanger	;retail $AD4BA-$AD823 (874 bytes). Jesse Belanger player picture (FeaturedPictures FLA 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJesseBelanger.bin
CardAndreiLomakin	;retail $AD824-$ADB8D (874 bytes). Andrei Lomakin player picture (FeaturedPictures FLA 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAndreiLomakin.bin
CardBobKudelski	;retail $ADB8E-$ADFAB (1054 bytes). Bob Kudelski player picture (FeaturedPictures FLA 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBobKudelski.bin
CardBrianBenning	;retail $ADFAC-$AE315 (874 bytes). Brian Benning player picture (FeaturedPictures FLA 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBrianBenning.bin
CardGordMurphy	;retail $AE316-$AE67F (874 bytes). Gord Murphy player picture (FeaturedPictures FLA 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardGordMurphy.bin
CardSeanBurke	;retail $AE680-$AE9E9 (874 bytes). Sean Burke player picture (FeaturedPictures HFD 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSeanBurke.bin
CardAndrewCassels	;retail $AE9EA-$AED53 (874 bytes). Andrew Cassels player picture (FeaturedPictures HFD 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAndrewCassels.bin
CardGeoffSanderson	;retail $AED54-$AF0BD (874 bytes). Geoff Sanderson player picture (FeaturedPictures HFD 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardGeoffSanderson.bin
CardPatVerbeek	;retail $AF0BE-$AF427 (874 bytes). Pat Verbeek player picture (FeaturedPictures HFD 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPatVerbeek.bin
CardAlexnderGodynyuk	;retail $AF428-$AF791 (874 bytes). Alexnder Godynyuk player picture (FeaturedPictures HFD 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAlexnderGodynyuk.bin
CardChrisPronger	;retail $AF792-$AFAFB (874 bytes). Chris Pronger player picture (FeaturedPictures HFD 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardChrisPronger.bin
CardKellyHrudey	;retail $AFAFC-$AFEE9 (1006 bytes). Kelly Hrudey player picture (FeaturedPictures LA 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardKellyHrudey.bin
CardWayneGretzky	;retail $AFEEA-$B0253 (874 bytes). Wayne Gretzky player picture (FeaturedPictures LA 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardWayneGretzky.bin
CardLucRobitaille	;retail $B0254-$B05BD (874 bytes). Luc Robitaille player picture (FeaturedPictures LA 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardLucRobitaille.bin
CardJariKurri	;retail $B05BE-$B0927 (874 bytes). Jari Kurri player picture (FeaturedPictures LA 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJariKurri.bin
CardRobBlake	;retail $B0928-$B0C91 (874 bytes). Rob Blake player picture (FeaturedPictures LA 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardRobBlake.bin
CardMartyMcSorley	;retail $B0C92-$B0FFB (874 bytes). Marty McSorley player picture (FeaturedPictures LA 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMartyMcSorley.bin
CardPatrickRoy	;retail $B0FFC-$B1365 (874 bytes). Patrick Roy player picture (FeaturedPictures MTL 0, ASE 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPatrickRoy.bin
CardKirkMuller	;retail $B1366-$B16CF (874 bytes). Kirk Muller player picture (FeaturedPictures MTL 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardKirkMuller.bin
CardVincentDamphousse	;retail $B16D0-$B1A39 (874 bytes). Vincent Damphousse player picture (FeaturedPictures MTL 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardVincentDamphousse.bin
CardBrianBellows	;retail $B1A3A-$B1DA3 (874 bytes). Brian Bellows player picture (FeaturedPictures MTL 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBrianBellows.bin
CardEricDesjardins	;retail $B1DA4-$B210D (874 bytes). Eric Desjardins player picture (FeaturedPictures MTL 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardEricDesjardins.bin
CardMattSchneider	;retail $B210E-$B24E3 (982 bytes). Matt Schneider player picture (FeaturedPictures MTL 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMattSchneider.bin
CardChrisTerreri	;retail $B24E4-$B284D (874 bytes). Chris Terreri player picture (FeaturedPictures NJ 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardChrisTerreri.bin
CardCoreyMillen	;retail $B284E-$B2BB7 (874 bytes). Corey Millen player picture (FeaturedPictures NJ 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardCoreyMillen.bin
CardJohnMacLean	;retail $B2BB8-$B2F21 (874 bytes). John MacLean player picture (FeaturedPictures NJ 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJohnMacLean.bin
CardStephaneRicher	;retail $B2F22-$B328B (874 bytes). Stephane Richer player picture (FeaturedPictures NJ 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardStephaneRicher.bin
CardScottStevens	;retail $B328C-$B35F5 (874 bytes). Scott Stevens player picture (FeaturedPictures NJ 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardScottStevens.bin
CardScottNiedrmayer	;retail $B35F6-$B395F (874 bytes). Scott Niedrmayer player picture (FeaturedPictures NJ 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardScottNiedrmayer.bin
CardRonHextall	;retail $B3960-$B3D35 (982 bytes). Ron Hextall player picture (FeaturedPictures NYI 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardRonHextall.bin
CardPierreTurgeon	;retail $B3D36-$B409F (874 bytes). Pierre Turgeon player picture (FeaturedPictures NYI 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPierreTurgeon.bin
CardBenoitHogue	;retail $B40A0-$B4409 (874 bytes). Benoit Hogue player picture (FeaturedPictures NYI 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBenoitHogue.bin
CardSteveThomas	;retail $B440A-$B4773 (874 bytes). Steve Thomas player picture (FeaturedPictures NYI 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSteveThomas.bin
CardDariusKasparitis	;retail $B4774-$B4B79 (1030 bytes). Darius Kasparitis player picture (FeaturedPictures NYI 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDariusKasparitis.bin
CardVladimirMalakhov	;retail $B4B7A-$B4EE3 (874 bytes). Vladimir Malakhov player picture (FeaturedPictures NYI 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardVladimirMalakhov.bin
CardMikeRichter	;retail $B4EE4-$B524D (874 bytes). Mike Richter player picture (FeaturedPictures NYR 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMikeRichter.bin
CardMarkMessier	;retail $B524E-$B55B7 (874 bytes). Mark Messier player picture (FeaturedPictures NYR 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMarkMessier.bin
CardAdamGraves	;retail $B55B8-$B59D5 (1054 bytes). Adam Graves player picture (FeaturedPictures NYR 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAdamGraves.bin
CardSteveLarmer	;retail $B59D6-$B5D3F (874 bytes). Steve Larmer player picture (FeaturedPictures NYR 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSteveLarmer.bin
CardBrianLeetch	;retail $B5D40-$B60A9 (874 bytes). Brian Leetch player picture (FeaturedPictures NYR 1, ASE 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBrianLeetch.bin
CardSergeiZubov	;retail $B60AA-$B6413 (874 bytes). Sergei Zubov player picture (FeaturedPictures NYR 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSergeiZubov.bin
CardCraigBillington	;retail $B6414-$B677D (874 bytes). Craig Billington player picture (FeaturedPictures OTW 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardCraigBillington.bin
CardAlexnderDaigle	;retail $B677E-$B6AE7 (874 bytes). Alexnder Daigle player picture (FeaturedPictures OTW 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAlexnderDaigle.bin
CardAlexeiYashin	;retail $B6AE8-$B6E51 (874 bytes). Alexei Yashin player picture (FeaturedPictures OTW 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAlexeiYashin.bin
CardSylvainTurgeon	;retail $B6E52-$B71BB (874 bytes). Sylvain Turgeon player picture (FeaturedPictures OTW 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSylvainTurgeon.bin
CardNormMaciver	;retail $B71BC-$B7525 (874 bytes). Norm Maciver player picture (FeaturedPictures OTW 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardNormMaciver.bin
CardBradShaw	;retail $B7526-$B788F (874 bytes). Brad Shaw player picture (FeaturedPictures OTW 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBradShaw.bin
CardDominicRoussel	;retail $B7890-$B7BF9 (874 bytes). Dominic Roussel player picture (FeaturedPictures PHI 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDominicRoussel.bin
CardEricLindros	;retail $B7BFA-$B7F63 (874 bytes). Eric Lindros player picture (FeaturedPictures PHI 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardEricLindros.bin
CardRodBrindAmour	;retail $B7F64-$B82CD (874 bytes). Rod BrindAmour player picture (FeaturedPictures PHI 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardRodBrindAmour.bin
CardMarkRecchi	;retail $B82CE-$B8637 (874 bytes). Mark Recchi player picture (FeaturedPictures PHI 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMarkRecchi.bin
CardGarryGalley	;retail $B8638-$B89A1 (874 bytes). Garry Galley player picture (FeaturedPictures PHI 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardGarryGalley.bin
CardDimitriYushkevich	;retail $B89A2-$B8D0B (874 bytes). Dimitri Yushkevich player picture (FeaturedPictures PHI 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDimitriYushkevich.bin
CardTomBarrasso	;retail $B8D0C-$B9075 (874 bytes). Tom Barrasso player picture (FeaturedPictures PIT 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardTomBarrasso.bin
CardMarioLemieux	;retail $B9076-$B93DF (874 bytes). Mario Lemieux player picture (FeaturedPictures PIT 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMarioLemieux.bin
CardKevinStevens	;retail $B93E0-$B9749 (874 bytes). Kevin Stevens player picture (FeaturedPictures PIT 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardKevinStevens.bin
CardJaromirJagr	;retail $B974A-$B9AB3 (874 bytes). Jaromir Jagr player picture (FeaturedPictures PIT 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJaromirJagr.bin
CardUlfSamuelsson	;retail $B9AB4-$B9E1D (874 bytes). Ulf Samuelsson player picture (FeaturedPictures PIT 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardUlfSamuelsson.bin
CardLarryMurphy	;retail $B9E1E-$BA187 (874 bytes). Larry Murphy player picture (FeaturedPictures PIT 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardLarryMurphy.bin
CardStephaneFiset	;retail $BA188-$BA4F1 (874 bytes). Stephane Fiset player picture (FeaturedPictures QUE 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardStephaneFiset.bin
CardJoeSakic	;retail $BA4F2-$BA85B (874 bytes). Joe Sakic player picture (FeaturedPictures QUE 4, ASE 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJoeSakic.bin
CardMatsSundin	;retail $BA85C-$BABC5 (874 bytes). Mats Sundin player picture (FeaturedPictures QUE 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMatsSundin.bin
CardValeriKamensky	;retail $BABC6-$BAF2F (874 bytes). Valeri Kamensky player picture (FeaturedPictures QUE 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardValeriKamensky.bin
CardCurtisLeschyshyn	;retail $BAF30-$BB299 (874 bytes). Curtis Leschyshyn player picture (FeaturedPictures QUE 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardCurtisLeschyshyn.bin
CardAlexeiGusarov	;retail $BB29A-$BB603 (874 bytes). Alexei Gusarov player picture (FeaturedPictures QUE 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAlexeiGusarov.bin
CardArtursIrbe	;retail $BB604-$BB96D (874 bytes). Arturs Irbe player picture (FeaturedPictures SJ 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardArtursIrbe.bin
CardIgorLarionov	;retail $BB96E-$BBCD7 (874 bytes). Igor Larionov player picture (FeaturedPictures SJ 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardIgorLarionov.bin
CardUlfDahlen	;retail $BBCD8-$BC041 (874 bytes). Ulf Dahlen player picture (FeaturedPictures SJ 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardUlfDahlen.bin
CardSergeiMakarov	;retail $BC042-$BC3AB (874 bytes). Sergei Makarov player picture (FeaturedPictures SJ 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSergeiMakarov.bin
CardJeffNorton	;retail $BC3AC-$BC715 (874 bytes). Jeff Norton player picture (FeaturedPictures SJ 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJeffNorton.bin
CardSandisOzolinsh	;retail $BC716-$BCA7F (874 bytes). Sandis Ozolinsh player picture (FeaturedPictures SJ 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSandisOzolinsh.bin
CardCurtisJoseph	;retail $BCA80-$BCDE9 (874 bytes). Curtis Joseph player picture (FeaturedPictures STL 0, ASW 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardCurtisJoseph.bin
CardCraigJanney	;retail $BCDEA-$BD153 (874 bytes). Craig Janney player picture (FeaturedPictures STL 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardCraigJanney.bin
CardBrendanShanahan	;retail $BD154-$BD4BD (874 bytes). Brendan Shanahan player picture (FeaturedPictures STL 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBrendanShanahan.bin
CardBrettHull	;retail $BD4BE-$BD827 (874 bytes). Brett Hull player picture (FeaturedPictures STL 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBrettHull.bin
CardPhilHousley	;retail $BD828-$BDB91 (874 bytes). Phil Housley player picture (FeaturedPictures STL 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPhilHousley.bin
CardSteveDuchesne	;retail $BDB92-$BDEFB (874 bytes). Steve Duchesne player picture (FeaturedPictures STL 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSteveDuchesne.bin
CardDarenPuppa	;retail $BDEFC-$BE265 (874 bytes). Daren Puppa player picture (FeaturedPictures TB 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDarenPuppa.bin
CardChrisGratton	;retail $BE266-$BE5CF (874 bytes). Chris Gratton player picture (FeaturedPictures TB 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardChrisGratton.bin
CardBrianBradley	;retail $BE5D0-$BE939 (874 bytes). Brian Bradley player picture (FeaturedPictures TB 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardBrianBradley.bin
CardPetrKlima	;retail $BE93A-$BECA3 (874 bytes). Petr Klima player picture (FeaturedPictures TB 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPetrKlima.bin
CardRomanHamrlik	;retail $BECA4-$BF00D (874 bytes). Roman Hamrlik player picture (FeaturedPictures TB 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardRomanHamrlik.bin
CardShawnChambers	;retail $BF00E-$BF377 (874 bytes). Shawn Chambers player picture (FeaturedPictures TB 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardShawnChambers.bin
CardFelixPotvin	;retail $BF378-$BF6E1 (874 bytes). Felix Potvin player picture (FeaturedPictures TOR 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardFelixPotvin.bin
CardDougGilmour	;retail $BF6E2-$BFA4B (874 bytes). Doug Gilmour player picture (FeaturedPictures TOR 4, ASW 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDougGilmour.bin
CardWendelClark	;retail $BFA4C-$BFDB5 (874 bytes). Wendel Clark player picture (FeaturedPictures TOR 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardWendelClark.bin
CardDaveAndreychuk	;retail $BFDB6-$C01BB (1030 bytes). Dave Andreychuk player picture (FeaturedPictures TOR 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDaveAndreychuk.bin
CardJamieMacoun	;retail $C01BC-$C0525 (874 bytes). Jamie Macoun player picture (FeaturedPictures TOR 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJamieMacoun.bin
CardDaveEllett	;retail $C0526-$C088F (874 bytes). Dave Ellett player picture (FeaturedPictures TOR 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDaveEllett.bin
CardKirkMcLean	;retail $C0890-$C0BF9 (874 bytes). Kirk McLean player picture (FeaturedPictures VAN 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardKirkMcLean.bin
CardCliffRonning	;retail $C0BFA-$C0F63 (874 bytes). Cliff Ronning player picture (FeaturedPictures VAN 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardCliffRonning.bin
CardGeoffCourtnall	;retail $C0F64-$C12CD (874 bytes). Geoff Courtnall player picture (FeaturedPictures VAN 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardGeoffCourtnall.bin
CardPavelBure	;retail $C12CE-$C1637 (874 bytes). Pavel Bure player picture (FeaturedPictures VAN 5, ASW 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardPavelBure.bin
CardJyrkiLumme	;retail $C1638-$C19A1 (874 bytes). Jyrki Lumme player picture (FeaturedPictures VAN 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJyrkiLumme.bin
CardJeffBrown	;retail $C19A2-$C1D0B (874 bytes). Jeff Brown player picture (FeaturedPictures VAN 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJeffBrown.bin
CardDonBeaupre	;retail $C1D0C-$C2075 (874 bytes). Don Beaupre player picture (FeaturedPictures WSH 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDonBeaupre.bin
CardMikeRidley	;retail $C2076-$C23DF (874 bytes). Mike Ridley player picture (FeaturedPictures WSH 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardMikeRidley.bin
CardJoeJuneau	;retail $C23E0-$C2749 (874 bytes). Joe Juneau player picture (FeaturedPictures WSH 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardJoeJuneau.bin
CardDimitriKhristich	;retail $C274A-$C2AB3 (874 bytes). Dimitri Khristich player picture (FeaturedPictures WSH 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDimitriKhristich.bin
CardKevinHatcher	;retail $C2AB4-$C2E1D (874 bytes). Kevin Hatcher player picture (FeaturedPictures WSH 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardKevinHatcher.bin
CardSylvainCote	;retail $C2E1E-$C3187 (874 bytes). Sylvain Cote player picture (FeaturedPictures WSH 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardSylvainCote.bin
CardTimCheveldae	;retail $C3188-$C34F1 (874 bytes). Tim Cheveldae player picture (FeaturedPictures WPG 0)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardTimCheveldae.bin
CardAlexeiZhamnov	;retail $C34F2-$C385B (874 bytes). Alexei Zhamnov player picture (FeaturedPictures WPG 4)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardAlexeiZhamnov.bin
CardKeithTkachuk	;retail $C385C-$C3C61 (1030 bytes). Keith Tkachuk player picture (FeaturedPictures WPG 3)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardKeithTkachuk.bin
CardTeemuSelanne	;retail $C3C62-$C3FCB (874 bytes). Teemu Selanne player picture (FeaturedPictures WPG 5)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardTeemuSelanne.bin
CardTeppoNumminen	;retail $C3FCC-$C43E9 (1054 bytes). Teppo Numminen player picture (FeaturedPictures WPG 2)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardTeppoNumminen.bin
CardDaveManson	;retail $C43EA-$C4753 (874 bytes). Dave Manson player picture (FeaturedPictures WPG 1)
	incbin	..\Extracted\NHL95\Graphics\PlayerCards\CardDaveManson.bin
FeaturedPicIdx	;retail $C4754-$C47FB (168 bytes). The FeaturedPictures index of the line 1 starters (G, LD, RD, LW, C, RW) of each team (GetPlayerPicture)
	dc.b	0,5,4,3,1,2	;ANH
	dc.b	6,10,11,8,7,9	;BOS
	dc.b	12,16,17,14,13,15	;BUF
	dc.b	18,22,23,20,19,21	;CGY
	dc.b	24,29,28,26,25,27	;CHI
	dc.b	30,34,35,32,31,33	;DAL
	dc.b	36,41,40,38,37,39	;DET
	dc.b	42,46,47,44,43,45	;EDM
	dc.b	48,52,53,50,49,51	;FLA
	dc.b	54,58,59,56,55,57	;HFD
	dc.b	60,64,65,62,61,63	;LA
	dc.b	66,71,70,68,67,69	;MTL
	dc.b	72,77,76,75,73,74	;NJ
	dc.b	78,83,82,80,79,81	;NYI
	dc.b	84,88,89,86,85,87	;NYR
	dc.b	90,94,95,93,92,91	;OTW
	dc.b	96,100,101,98,97,99	;PHI
	dc.b	102,106,107,104,103,105	;PIT
	dc.b	108,113,112,111,109,110	;QUE
	dc.b	114,118,119,116,115,117	;SJ
	dc.b	120,125,124,122,121,123	;STL
	dc.b	126,131,130,127,128,129	;TB
	dc.b	132,136,137,134,133,135	;TOR
	dc.b	138,142,143,140,139,141	;VAN
	dc.b	144,149,148,147,145,146	;WSH
	dc.b	150,155,154,152,151,153	;WPG
	dc.b	66,10,88,109,7,15	;ASE
	dc.b	120,40,28,38,133,141	;ASW
FeaturedPictures	;retail $C47FC-$C4A7B (640 bytes). The 160 player pictures (GetPlayerPicture)
	dc.l	CardGuyHebert,CardBobCorkum,CardTerryYake,CardGarryValk
	dc.l	CardSeanHill,CardBillHoulder,CardJonCasey,CardAdamOates
	dc.l	CardBryanSmolinski,CardCamNeely,CardRayBourque,CardAlIafrate
	dc.l	CardDominikHasek,CardPatLaFontaine,CardDaleHawerchuk,CardAlexnderMogilny
	dc.l	CardDougBodger,CardPetrSvoboda,CardMikeVernon,CardJoeNieuwendyk
	dc.l	CardGaryRoberts,CardTheorenFleury,CardZarleyZalapski,CardAlMacInnis
	dc.l	CardEdBelfour,CardJeremyRoenick,CardMichelGoulet,CardJoeMurphy
	dc.l	CardChrisChelios,CardSteveSmith,CardAndyMoog,CardMikeModano
	dc.l	CardDaveGagner,CardRussCourtnall,CardMarkTinordi,CardDerianHatcher
	dc.l	CardBobEssensa,CardSteveYzerman,CardSergeiFedorov,CardDinoCiccarelli
	dc.l	CardPaulCoffey,CardSteveChiasson,CardBillRanford,CardDougWeight
	dc.l	CardShayneCorson,CardZdenoCiger,CardIgorKravchuk,CardBobBeers
	dc.l	CardJohnVanbiesbrk,CardJesseBelanger,CardAndreiLomakin,CardBobKudelski
	dc.l	CardBrianBenning,CardGordMurphy,CardSeanBurke,CardAndrewCassels
	dc.l	CardGeoffSanderson,CardPatVerbeek,CardAlexnderGodynyuk,CardChrisPronger
	dc.l	CardKellyHrudey,CardWayneGretzky,CardLucRobitaille,CardJariKurri
	dc.l	CardRobBlake,CardMartyMcSorley,CardPatrickRoy,CardKirkMuller
	dc.l	CardVincentDamphousse,CardBrianBellows,CardEricDesjardins,CardMattSchneider
	dc.l	CardChrisTerreri,CardCoreyMillen,CardJohnMacLean,CardStephaneRicher
	dc.l	CardScottStevens,CardScottNiedrmayer,CardRonHextall,CardPierreTurgeon
	dc.l	CardBenoitHogue,CardSteveThomas,CardDariusKasparitis,CardVladimirMalakhov
	dc.l	CardMikeRichter,CardMarkMessier,CardAdamGraves,CardSteveLarmer
	dc.l	CardBrianLeetch,CardSergeiZubov,CardCraigBillington,CardAlexnderDaigle
	dc.l	CardAlexeiYashin,CardSylvainTurgeon,CardNormMaciver,CardBradShaw
	dc.l	CardDominicRoussel,CardEricLindros,CardRodBrindAmour,CardMarkRecchi
	dc.l	CardGarryGalley,CardDimitriYushkevich,CardTomBarrasso,CardMarioLemieux
	dc.l	CardKevinStevens,CardJaromirJagr,CardUlfSamuelsson,CardLarryMurphy
	dc.l	CardStephaneFiset,CardJoeSakic,CardMatsSundin,CardValeriKamensky
	dc.l	CardCurtisLeschyshyn,CardAlexeiGusarov,CardArtursIrbe,CardIgorLarionov
	dc.l	CardUlfDahlen,CardSergeiMakarov,CardJeffNorton,CardSandisOzolinsh
	dc.l	CardCurtisJoseph,CardCraigJanney,CardBrendanShanahan,CardBrettHull
	dc.l	CardPhilHousley,CardSteveDuchesne,CardDarenPuppa,CardChrisGratton
	dc.l	CardBrianBradley,CardPetrKlima,CardRomanHamrlik,CardShawnChambers
	dc.l	CardFelixPotvin,CardDougGilmour,CardWendelClark,CardDaveAndreychuk
	dc.l	CardJamieMacoun,CardDaveEllett,CardKirkMcLean,CardCliffRonning
	dc.l	CardGeoffCourtnall,CardPavelBure,CardJyrkiLumme,CardJeffBrown
	dc.l	CardDonBeaupre,CardMikeRidley,CardJoeJuneau,CardDimitriKhristich
	dc.l	CardKevinHatcher,CardSylvainCote,CardTimCheveldae,CardAlexeiZhamnov
	dc.l	CardKeithTkachuk,CardTeemuSelanne,CardTeppoNumminen,CardDaveManson
	dc.l	NoPicSkater2,NoPicSkater1,NoPicGoalie1,NoPicGoalie2
Rinktilelist	;retail $C4A7C-$CA569 (23278 bytes). the ice rink map (94 Rinktilelist, 93 IceRinkMap); Rinktilelist+8 = the rink tiles
	incbin	..\Extracted\NHL95\Graphics\Rinktilelist.map.jim
Sprites	;retail $CA56A-$CA573 (10 bytes). the sprite header (94 / 93 Sprites; addframe2): long offsets from here $6730A and $6738A (to frameSprData), then a word
	incbin	..\Extracted\NHL95\Graphics\Sprites.bin
Spritetiles	;retail $CA574-$1318F3 (422784 bytes). the sprite tiles (94 Spritetiles, 93 Sprites+$A; addframe2 adds the frame tile offset)
	incbin	..\Extracted\NHL95\Graphics\Spritetiles.bin
frameSprData	;retail $1318F4-$137B65 (25202 bytes). the sprite frame data at Sprites + $6738A (94 frameSprData)
	incbin	..\Extracted\NHL95\Graphics\frameSprData.bin
HotSpotList	;retail $137B66-$1383C5 (2144 bytes). the hot spot byte pair of each frame (94 Hotlist; GetHot)
	incbin	..\Extracted\NHL95\Graphics\HotSpotList.bin
RosterFont	;retail $1383C6-$139093 (3278 bytes). data
	incbin	..\Extracted\NHL95\Graphics\RosterFont.bin
SmallFontMap	;retail $139094-$139E01 (3438 bytes). the SmallFontMap map
	incbin	..\Extracted\NHL95\Graphics\SmallFontMap.map.jim
SmallFontMap2	;retail $139E02-$13AC6F (3694 bytes). the SmallFontMap2 map
	incbin	..\Extracted\NHL95\Graphics\SmallFontMap2.map.jim
PauseBgBitmap	;retail $13AC70-$13E09D (13358 bytes). the PauseBgBitmap map
	incbin	..\Extracted\NHL95\Graphics\PauseBgBitmap.map.jim
PeriodNumberBitmap	;retail $13E09E-$13E21B (382 bytes). the PeriodNumberBitmap map
	incbin	..\Extracted\NHL95\Graphics\PeriodNumberBitmap.map.jim
TabBitmap	;retail $13E21C-$13EEA9 (3214 bytes). the TabBitmap map
	incbin	..\Extracted\NHL95\Graphics\TabBitmap.map.jim
PauseFontMap	;retail $13EEAA-$13FC17 (3438 bytes). the PauseFontMap map
	incbin	..\Extracted\NHL95\Graphics\PauseFontMap.map.jim
ClockDigitsBitmap	;retail $13FC18-$140009 (1010 bytes). the ClockDigitsBitmap map
	incbin	..\Extracted\NHL95\Graphics\ClockDigitsBitmap.map.jim
RosterBitmap	;retail $14000A-$142905 (10492 bytes). the RosterBitmap map
	incbin	..\Extracted\NHL95\Graphics\RosterBitmap.map.jim
Teamblocksmap	;retail $142906-$146D23 (17438 bytes). the Teamblocksmap map
	incbin	..\Extracted\NHL95\Graphics\Teamblocksmap.map.jim
PauseTeamBlocksMap	;retail $146D24-$149E31 (12558 bytes). the PauseTeamBlocksMap map
	incbin	..\Extracted\NHL95\Graphics\PauseTeamBlocksMap.map.jim
FaceOffMap	;retail $149E32-$14A48F (1630 bytes). the face-off map (94 / 93 FaceOffMap; FaceoffTiles); +8 the tiles
	incbin	..\Extracted\NHL95\Graphics\FaceOffMap.map.jim
FaceoffTiles	equ	FaceOffMap	;the same address
FaceOffSprites	;retail $14A490-$14C147 (7352 bytes). the face-off sprites (94 / 93 FaceOffSprites; FaceoffTiles2); +8 the tiles
	incbin	..\Extracted\NHL95\Graphics\FaceOffSprites.map.jim
FaceoffTiles2	equ	FaceOffSprites	;the same address
Framermap	;retail $14C148-$14C307 (448 bytes). the Framermap map
	incbin	..\Extracted\NHL95\Graphics\Framermap.map.jim
Framermap2	;retail $14C308-$14C4C7 (448 bytes). the Framermap2 map
	incbin	..\Extracted\NHL95\Graphics\Framermap2.map.jim
EnergyBarMap	;retail $14C4C8-$14C795 (718 bytes). the EnergyBarMap map
	incbin	..\Extracted\NHL95\Graphics\EnergyBarMap.map.jim
EASportsMap	;retail $14C796-$14EB03 (9070 bytes). the EASportsMap map
	incbin	..\Extracted\NHL95\Graphics\EASportsMap.map.jim
RefTiles	;retail $14EB04-$14FBA1 (4254 bytes). the RefTiles map
	incbin	..\Extracted\NHL95\Graphics\RefTiles.map.jim
RefTilesHor	;retail $14FBA2-$15175F (7102 bytes). the RefTilesHor map
	incbin	..\Extracted\NHL95\Graphics\RefTilesHor.map.jim
SetupFont	;retail $151760-$1524CD (3438 bytes). the SetupFont map
	incbin	..\Extracted\NHL95\Graphics\SetupFont.map.jim
SetupBgMap2	;retail $1524CE-$1588FB (25646 bytes). the SetupBgMap2 map
	incbin	..\Extracted\NHL95\Graphics\SetupBgMap2.map.jim
SetupBgMap1	;retail $1588FC-$159749 (3662 bytes). the SetupBgMap1 map
	incbin	..\Extracted\NHL95\Graphics\SetupBgMap1.map.jim
TeamBitmaps	;retail $15974A-$15CE67 (14110 bytes). the TeamBitmaps map
	incbin	..\Extracted\NHL95\Graphics\TeamBitmaps.map.jim
BigFontMap3	;retail $15CE68-$15E189 (4898 bytes). the BigFontMap3 map
	incbin	..\Extracted\NHL95\Graphics\BigFontMap3.map.jim
BigFontMap	;retail $15E18A-$15F46B (4834 bytes). the BigFontMap map
	incbin	..\Extracted\NHL95\Graphics\BigFontMap.map.jim
BigFontMap2	;retail $15F46C-$16060D (4514 bytes). the BigFontMap2 map
	incbin	..\Extracted\NHL95\Graphics\BigFontMap2.map.jim
RevRinkTilelist	;retail $16060E-$1625F1 (8164 bytes). data
	incbin	..\Extracted\NHL95\Graphics\RevRinkTilelist.bin
ReplayMap	;retail $1625F2-$162D17 (1830 bytes). the ReplayMap map
	incbin	..\Extracted\NHL95\Graphics\ReplayMap.map.jim
ReplayIconMap	;retail $162D18-$163349 (1586 bytes). the ReplayIconMap map
	incbin	..\Extracted\NHL95\Graphics\ReplayIconMap.map.jim
HiScoreBgMap	;retail $16334A-$164309 (4032 bytes). the HiScoreBgMap map
	incbin	..\Extracted\NHL95\Graphics\HiScoreBgMap.map.jim
HiScoreImg	;retail $16430A-$164AC7 (1982 bytes). the HiScoreImg map
	incbin	..\Extracted\NHL95\Graphics\HiScoreImg.map.jim
ControllerBgMap	;retail $164AC8-$165A35 (3950 bytes). the ControllerBgMap map
	incbin	..\Extracted\NHL95\Graphics\ControllerBgMap.map.jim
GamesTodayLogoMap	;retail $165A36-$167523 (6894 bytes). the GamesTodayLogoMap map
	incbin	..\Extracted\NHL95\Graphics\GamesTodayLogoMap.map.jim
GamesTodayMap1	;retail $167524-$16767D (346 bytes). the GamesTodayMap1 map
	incbin	..\Extracted\NHL95\Graphics\GamesTodayMap1.map.jim
GamesTodayMap2	;retail $16767E-$16781D (416 bytes). the GamesTodayMap2 map
	incbin	..\Extracted\NHL95\Graphics\GamesTodayMap2.map.jim
GamesTodayMap3	;retail $16781E-$167A43 (550 bytes). the GamesTodayMap3 map
	incbin	..\Extracted\NHL95\Graphics\GamesTodayMap3.map.jim
CalendarBgMap	;retail $167A44-$168E71 (5166 bytes). the CalendarBgMap map
	incbin	..\Extracted\NHL95\Graphics\CalendarBgMap.map.jim
CalOpponentMap	;retail $168E72-$1696DB (2154 bytes). the CalOpponentMap map
	incbin	..\Extracted\NHL95\Graphics\CalOpponentMap.map.jim
CalDayMap	;retail $1696DC-$169CE5 (1546 bytes). the CalDayMap map
	incbin	..\Extracted\NHL95\Graphics\CalDayMap.map.jim
CalMonthMap	;retail $169CE6-$16A813 (2862 bytes). the CalMonthMap map
	incbin	..\Extracted\NHL95\Graphics\CalMonthMap.map.jim
CalCheckMap	;retail $16A814-$16A8BB (168 bytes). data
	incbin	..\Extracted\NHL95\Graphics\CalCheckMap.bin
CalResultMap	;retail $16A8BC-$16AA7B (448 bytes). the CalResultMap map
	incbin	..\Extracted\NHL95\Graphics\CalResultMap.map.jim
ControllerTitleMap	;retail $16AA7C-$16AD59 (734 bytes). the ControllerTitleMap map
	incbin	..\Extracted\NHL95\Graphics\ControllerTitleMap.map.jim
PadCursorMap	;retail $16AD5A-$16B0B1 (856 bytes). the PadCursorMap map
	incbin	..\Extracted\NHL95\Graphics\PadCursorMap.map.jim
PadIconMap1	;retail $16B0B2-$16B1C7 (278 bytes). the PadIconMap1 map
	incbin	..\Extracted\NHL95\Graphics\PadIconMap1.map.jim
PadIconMap2	;retail $16B1C8-$16B2DD (278 bytes). the PadIconMap2 map
	incbin	..\Extracted\NHL95\Graphics\PadIconMap2.map.jim
PadIconMap3	;retail $16B2DE-$16B3F3 (278 bytes). the PadIconMap3 map
	incbin	..\Extracted\NHL95\Graphics\PadIconMap3.map.jim
PadIconMap4	;retail $16B3F4-$16B509 (278 bytes). the PadIconMap4 map
	incbin	..\Extracted\NHL95\Graphics\PadIconMap4.map.jim
PlayerStatsBgMap	;retail $16B50A-$16C437 (3886 bytes). the PlayerStatsBgMap map
	incbin	..\Extracted\NHL95\Graphics\PlayerStatsBgMap.map.jim
PlayerStatsTitleMap	;retail $16C438-$16C775 (830 bytes). the PlayerStatsTitleMap map
	incbin	..\Extracted\NHL95\Graphics\PlayerStatsTitleMap.map.jim
PeriodStatsMap	;retail $16C776-$16C9FB (646 bytes). the PeriodStatsMap map
	incbin	..\Extracted\NHL95\Graphics\PeriodStatsMap.map.jim
HighlightsBgMap	;retail $16C9FC-$16CC81 (646 bytes). the HighlightsBgMap map
	incbin	..\Extracted\NHL95\Graphics\HighlightsBgMap.map.jim
WaitBoxMap	;retail $16CC82-$16EAB3 (7730 bytes). the WaitBoxMap map
	incbin	..\Extracted\NHL95\Graphics\WaitBoxMap.map.jim
LineEditorBgMap	;retail $16EAB4-$16F7D1 (3358 bytes). the LineEditorBgMap map
	incbin	..\Extracted\NHL95\Graphics\LineEditorBgMap.map.jim
Screen6Tiles1	equ	LineEditorBgMap+8	;retail $16EABC. the tiles
PlayerSelectMap2	;retail $16F7D2-$16FA6F (670 bytes). the PlayerSelectMap2 map
	incbin	..\Extracted\NHL95\Graphics\PlayerSelectMap2.map.jim
Screen6Tiles2	equ	PlayerSelectMap2+8	;retail $16F7DA. the tiles
PlayerSelectMap1	;retail $16FA70-$1703FD (2446 bytes). the PlayerSelectMap1 map
	incbin	..\Extracted\NHL95\Graphics\PlayerSelectMap1.map.jim
CreateBgMap	;retail $1703FE-$172CCB (10446 bytes). the CreateBgMap map
	incbin	..\Extracted\NHL95\Graphics\CreateBgMap.map.jim
TradeBgMap	;retail $172CCC-$174099 (5070 bytes). the TradeBgMap map
	incbin	..\Extracted\NHL95\Graphics\TradeBgMap.map.jim
AwardsBgMap	;retail $17409A-$1787C7 (18222 bytes). the AwardsBgMap map
	incbin	..\Extracted\NHL95\Graphics\AwardsBgMap.map.jim
FinalistsPanelMap	;retail $1787C8-$178B11 (842 bytes). the FinalistsPanelMap map
	incbin	..\Extracted\NHL95\Graphics\FinalistsPanelMap.map.jim
WinnerPanelMap	;retail $178B12-$178EC5 (948 bytes). the WinnerPanelMap map
	incbin	..\Extracted\NHL95\Graphics\WinnerPanelMap.map.jim
HartPic	;retail $178EC6-$17968F (1994 bytes). the HartPic map
	incbin	..\Extracted\NHL95\Graphics\HartPic.map.jim
NorrisPic	;retail $179690-$17A949 (4794 bytes). the NorrisPic map
	incbin	..\Extracted\NHL95\Graphics\NorrisPic.map.jim
VezinaPic	;retail $17A94A-$17B2E7 (2462 bytes). the VezinaPic map
	incbin	..\Extracted\NHL95\Graphics\VezinaPic.map.jim
ArtRossPic	;retail $17B2E8-$17BEFF (3096 bytes). the ArtRossPic map
	incbin	..\Extracted\NHL95\Graphics\ArtRossPic.map.jim
SelkePic	;retail $17BF00-$17E0D5 (8662 bytes). the SelkePic map
	incbin	..\Extracted\NHL95\Graphics\SelkePic.map.jim
JenningsPic	;retail $17E0D6-$17EE8D (3512 bytes). the JenningsPic map
	incbin	..\Extracted\NHL95\Graphics\JenningsPic.map.jim
PresidentsPic	;retail $17EE8E-$17F76B (2270 bytes). the PresidentsPic map
	incbin	..\Extracted\NHL95\Graphics\PresidentsPic.map.jim
ConnSmythePic	;retail $17F76C-$180229 (2750 bytes). the ConnSmythePic map
	incbin	..\Extracted\NHL95\Graphics\ConnSmythePic.map.jim
PearsonPic	;retail $18022A-$180B4D (2340 bytes). the PearsonPic map
	incbin	..\Extracted\NHL95\Graphics\PearsonPic.map.jim
EASNmap	;retail $180B4E-$180D53 (518 bytes). the EASNmap map
	incbin	..\Extracted\NHL95\Graphics\EASNmap.map.jim
GMDecisionMap	;retail $180D54-$181077 (804 bytes). the GMDecisionMap map
	incbin	..\Extracted\NHL95\Graphics\GMDecisionMap.map.jim
FreeAgentMap2	;retail $181078-$181485 (1038 bytes). the FreeAgentMap2 map
	incbin	..\Extracted\NHL95\Graphics\FreeAgentMap2.map.jim
FreeAgentMap1	;retail $181486-$181B03 (1662 bytes). the FreeAgentMap1 map
	incbin	..\Extracted\NHL95\Graphics\FreeAgentMap1.map.jim
TradeAdvantageMap2	;retail $181B04-$18277B (3192 bytes). the TradeAdvantageMap2 map
	incbin	..\Extracted\NHL95\Graphics\TradeAdvantageMap2.map.jim
TradeAdvantageMap1	;retail $18277C-$1834F3 (3448 bytes). the TradeAdvantageMap1 map
	incbin	..\Extracted\NHL95\Graphics\TradeAdvantageMap1.map.jim
NameEntryBgMap	;retail $1834F4-$1835D5 (226 bytes). the NameEntryBgMap map
	incbin	..\Extracted\NHL95\Graphics\NameEntryBgMap.map.jim
Arrowsmap	;retail $1835D6-$18394B (886 bytes). the Arrowsmap map
	incbin	..\Extracted\NHL95\Graphics\Arrowsmap.map.jim
ScoutMap	;retail $18394C-$1842D9 (2446 bytes). the ScoutMap map
	incbin	..\Extracted\NHL95\Graphics\ScoutMap.map.jim
PlayoffSprite	;retail $1842DA-$1891F7 (20254 bytes). the PlayoffSprite map
	incbin	..\Extracted\NHL95\Graphics\PlayoffSprite.map.jim
ScoutReportMap	;retail $1891F8-$18A5C5 (5070 bytes). the ScoutReportMap map
	incbin	..\Extracted\NHL95\Graphics\ScoutReportMap.map.jim
HotIconMap	;retail $18A5C6-$18A78B (454 bytes). the HotIconMap map
	incbin	..\Extracted\NHL95\Graphics\HotIconMap.map.jim
ColdIconMap	;retail $18A78C-$18A9B1 (550 bytes). the ColdIconMap map
	incbin	..\Extracted\NHL95\Graphics\ColdIconMap.map.jim
RonBarrMap	;retail $18A9B2-$18B627 (3190 bytes). the RonBarrMap map
	incbin	..\Extracted\NHL95\Graphics\RonBarrMap.map.jim
CrowdFrameList	;retail $18B628-$18DAA7 (9344 bytes). the crowd sprites (94 CrowdFrameList, 93 CrowdSprites; showcrowd); +8 the tiles
	incbin	..\Extracted\NHL95\Graphics\CrowdFrameList.map.jim
TitleScreenImg	;retail $18DAA8-$1960D5 (34350 bytes). the TitleScreenImg map
	incbin	..\Extracted\NHL95\Graphics\TitleScreenImg.map.jim
TitleImg	;retail $1960D6-$196C4B (2934 bytes). the TitleImg map
	incbin	..\Extracted\NHL95\Graphics\TitleImg.map.jim
StanleyCupImg	;retail $196C4C-$19A0F9 (13486 bytes). the StanleyCupImg map
	incbin	..\Extracted\NHL95\Graphics\StanleyCupImg.map.jim
CupSprites	;retail $19A0FA-$19A991 (2200 bytes). the CupSprites map
	incbin	..\Extracted\NHL95\Graphics\CupSprites.map.jim
logoANA	;retail $19A992-$19AE27 (1174 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoANA.map.jim
logoBOS	;retail $19AE28-$19B17D (854 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoBOS.map.jim
logoBUF	;retail $19B17E-$19B4D3 (854 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoBUF.map.jim
logoCGY	;retail $19B4D4-$19B969 (1174 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoCGY.map.jim
logoCHI	;retail $19B96A-$19BD9F (1078 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoCHI.map.jim
logoDET	;retail $19BDA0-$19C0F5 (854 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoDET.map.jim
logoEDM	;retail $19C0F6-$19C4EB (1014 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoEDM.map.jim
logoFLA	;retail $19C4EC-$19C8A1 (950 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoFLA.map.jim
logoHFD	;retail $19C8A2-$19CB37 (662 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoHFD.map.jim
logoNYI	;retail $19CB38-$19CF8D (1110 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoNYI.map.jim
logoLA	;retail $19CF8E-$19D303 (886 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoLA.map.jim
logoDAL	;retail $19D304-$19D719 (1046 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoDAL.map.jim
logoMTL	;retail $19D71A-$19DA8F (886 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoMTL.map.jim
logoNJ	;retail $19DA90-$19DF45 (1206 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoNJ.map.jim
logoNYR	;retail $19DF46-$19E41B (1238 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoNYR.map.jim
logoOTW	;retail $19E41C-$19E831 (1046 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoOTW.map.jim
logoPHI	;retail $19E832-$19EBE7 (950 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoPHI.map.jim
logoPIT	;retail $19EBE8-$19EF5D (886 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoPIT.map.jim
logoQUE	;retail $19EF5E-$19F2B3 (854 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoQUE.map.jim
logoSJ	;retail $19F2B4-$19F6E9 (1078 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoSJ.map.jim
logoSTL	;retail $19F6EA-$19FABF (982 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoSTL.map.jim
logoTB	;retail $19FAC0-$19FED5 (1046 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoTB.map.jim
logoTOR	;retail $19FED6-$1A022B (854 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoTOR.map.jim
logoVAN	;retail $1A022C-$1A0641 (1046 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoVAN.map.jim
logoWSH	;retail $1A0642-$1A08B7 (630 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoWSH.map.jim
logoWPG	;retail $1A08B8-$1A0D2D (1142 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoWPG.map.jim
logoASE	;retail $1A0D2E-$1A11E3 (1206 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoASE.map.jim
logoASW	;retail $1A11E4-$1A1699 (1206 bytes). team logo (TeamLogoBitmaps)
	incbin	..\Extracted\NHL95\Graphics\logoASW.map.jim
