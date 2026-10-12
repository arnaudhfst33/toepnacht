# Toepnacht — Game Design Document v1.0

## Visie
Toepnacht is een mobiele singleplayer kaartgame rond Toepen, met een roguelite-achtige campagne. Doelplatform v1.0: iPhone. Engine: Godot 4.x Standard + GDScript.

## Campagne
Locaties:
1. Studentenhuis
2. Kroeg
3. Huisfeest
4. Sociëteit

Iedere locatie heeft 3 potjes; potje 3 is de boss-tafel.
Bosses:
- Studentenhuis — De Huisoudste
- Kroeg — De Barman
- Huisfeest — De Regelaar
- Sociëteit — De Praeses

Een vrijgespeelde locatie blijft beschikbaar. Verlies binnen een locatie = terug naar potje 1 van die locatie.

## Basisregels
- Iedereen start op 0 strafpunten.
- Bij 15 strafpunten is een speler af.
- Laatste overgebleven speler wint het potje.
- Iedere speler krijgt 4 kaarten, één voor één.
- In het allereerste echte potje begint de menselijke speler.
- Daarna begint de winnaar van de vorige ronde.
- Kaartvolgorde laag → hoog: Boer, Vrouw, Heer, Aas, 7, 8, 9, 10.
- Kleur bekennen is verplicht wanneer mogelijk.
- De vierde/laatste slag bepaalt de winnaar van de ronde.

## Uitkomst
- De menselijke speler komt uit in het allereerste echte potje.
- Daarna komt de winnaar van de vorige ronde uit in de volgende ronde.

## Scoring
- De inzet van een ronde start op 1.
- Een normale rondeverlies (geen extra kloppen) geeft +1 strafpunt.
- Elke klop verhoogt de huidige inzet van de ronde met +1.
- Wie PAS zegt na een klop krijgt meteen strafpunten gelijk aan de huidige inzet (ná de verhoging) en verlaat de huidige ronde.
- Wie MEE gaat blijft in de ronde voor de verhoogde inzet.
- Elke volgende klop verhoogt de inzet opnieuw met +1.
- De rondewinnaar krijgt 0 strafpunten.
- Actieve niet-winnaars aan het einde van de ronde krijgen strafpunten gelijk aan de uiteindelijke huidige inzet.

## Kloppen
- Kloppen gebeurt vóór het spelen van een kaart.
- Eén druk op KLOP activeert direct het klopmoment.
- Andere actieve spelers kiezen MEE of PAS.
- PAS mag alleen als antwoord op een klop, niet als vrije actie.
- Wie in de huidige slag al een kaart heeft gespeeld, mag in diezelfde klopronde niet meer PAS zeggen.
- Tips adviseren eventueel, maar beslissen nooit voor de speler.

## Armoede
- Armoede bij 14/15.
- 15 punten = af.

## Vuile Was / Witte Was
Vuile Was:
- Call aan het begin van de ronde, vóór de eerste kaart.
- 3 plaatjes (Boer/Vrouw/Heer/Aas) + 1 zeven.
- Een ander kan de claim betwisten.
- Bluf: caller +1 strafpunt en houdt zijn kaarten.
- Echt: caller krijgt 4 nieuwe kaarten; betwister +1 strafpunt.

Witte Was:
- 4 plaatjes.
- Zelfde call/betwist-flow als Vuile Was.
- Bluf: caller +1 strafpunt en houdt zijn kaarten.
- Echt: caller krijgt 4 nieuwe kaarten; betwister +1 strafpunt.

Als een Vuile Was- of Witte Was-claim niet wordt betwist, geldt de claim als geloofd en krijgt de caller 4 nieuwe kaarten.

Kaarten die bij Vuile Was, Witte Was of Kans op Toep worden weggelegd of vervangen, gaan tijdens die hand niet terug in de trekstapel.

Aan het begin van een nieuwe ronde wordt het volledige 32-kaarten-deck opnieuw opgebouwd en geschud.

Delen gebeurt één kaart tegelijk, met de klok mee, te beginnen bij de speler die deze ronde uitkomt.

## Toep
- 4 kaarten van dezelfde waarde = Toep.
- Alle andere spelers +3 strafpunten.
- Daarna opnieuw delen.
- Detectie automatisch; declaratie door de speler.

## Kans op Toep
- 3 kaarten van dezelfde waarde.
- Afwijkende kaart wordt ingeruild voor 1 nieuwe kaart.
- Vierde gelijke kaart = Toep.
- Zo niet: verder spelen met de nieuwe kaart.
- Geen blufmechanisme.

## Tutorial
Optioneel en herhaalbaar:
1. Blanco Toepen met open kaarten
2. Kloppen
3. Bluffen
4. Vuile Was
5. Toep + Kans op Toep
6. Armoede
7. De Avondwinkel

Open kaarten worden geleidelijk afgebouwd.

## Tips
- Altijd aan/uit.
- Leg uit waarom iets slim of riskant is.
- De speler houdt controle.

## AI
AI gebruikt alleen informatie die een menselijke speler kan kennen en kijkt nooit naar verborgen kaarten.
- Studentenhuis: duidelijke foutmarge.
- Kroeg: betere risico-inschatting.
- Huisfeest: sterkere persoonlijkheden en meer onvoorspelbaarheid.
- Sociëteit: sterkste AI, goed kaartgeheugen, patroonherkenning.
Zelfs de beste AI speelt niet perfect.

## Bierdopjes
Run-valuta voor De Avondwinkel.
Startwaarden:
- Ronde winnen: +1
- Ronde winnen nadat jij hebt geklopt: +1 extra
- Potje winnen: +3
- Toep maken: +3 extra
- Boss verslaan: +5 extra

## De Avondwinkel
- Na gewonnen potje 1 en 2.
- Niet na de boss.
- 3 willekeurige power-ups.
- Maximaal 2 tegelijk bewaren.
- Eenmalig gebruik.
- Tijdens het spel activeren.
- Bij verlies verdwijnen alle bierdopjes en power-ups van die run.

Power-ups v1.0:
1. Kaartje Ruilen
2. Even Spieken
3. Op het Randje
4. Rondje van de Zaak
5. Wasdag
6. Dubbel Kloppen
7. Huisvoordeel
8. Stalen Zenuwen

## Speelscherm
- 3 tegenstanders boven/om tafel.
- Per tegenstander: naam, strafpunten, aantal kaarten.
- Gespeelde kaarten centraal.
- Eigen 4 kaarten groot onderin.
- Ongeldige kaarten gedimd en niet klikbaar.
- KLOP zichtbaar wanneer mogelijk.
- Bij een klop van een ander: tijdelijk MEE en PAS.
- 2 power-upslots.
- Compacte TIP-knop.
- Eigen strafpunten x/15.
- Kleine bierdoppenteller.

## Feedback
- Kaarten delen: snelle één-voor-één animatie.
- Kaart spelen: korte schuif/tik.
- KLOP: BONK, tafelbeweging, haptic, groot moment.
- Strafpunten: duidelijke update.
- Muziek per locatie.
- Muziek, SFX en haptics afzonderlijk instelbaar.

## Savegame
- Automatisch lokaal opslaan.
- Vrijgespeelde locaties blijven behouden.
- Actieve run, bierdopjes en ongebruikte power-ups worden bewaard.
- Definitief verlies wordt direct opgeslagen.
- Geen account/cloud-save in v1.0.

## Hoofdmenu
- SPELEN / DOORGAAN
- HOE WERKT TOEPEN?
- INSTELLINGEN

## Instellingen
- Muziek aan/uit + volume
- SFX aan/uit + volume
- Haptics aan/uit
- Tips aan/uit
- Animatiesnelheid normaal/snel

## Scope v1.0
Wel:
- Singleplayer Toepen-engine
- 15 punten = af
- Tutorials
- 4 locaties / 12 campagnepotjes
- 4 bosses
- AI-persoonlijkheden
- De Avondwinkel
- Bierdopjes
- 8 eenmalige power-ups
- 2 power-upslots
- Lokale autosave
- Tips, audio, haptics, basisanimaties

Niet:
- Online multiplayer
- Accounts
- Leaderboards
- Dagelijkse challenges
- Uitgebreide achievements
- Betaalde in-game aankopen

## Bron van waarheid
Dit document is leidend voor gameplay en scope. Bij conflict met oude prompts, concept-art of prototypes heeft dit document voorrang.
