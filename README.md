# Toepnacht

Toepnacht is een mobiele singleplayer kaartgame in Godot 4.7. De game combineert
de Nederlandse regels van Toepen met een studentikoze roguelite-campagne.

## Huidige status

- Vier locaties: Studentenhuis, Kroeg, Huisfeest en Sociëteit
- Drie potjes per locatie, inclusief eindbaas
- Zeven optionele tutorials
- Optionele open-kaartenleerstand voor Studentenhuis potje 1
- Kloppen, Vuile Was, Witte Was, Toep, Kans op Toep en Armoede
- De Avondwinkel, bierdopjes en acht eenmalige power-ups
- Locatiegebonden AI-profielen met een foutmarge
- Lokale savegame
- Mobiele basisresolutie: 390 x 844

De precieze spelregels en scope staan in `docs/GDD.md`. Dat document is leidend.

## Project openen

1. Installeer Godot 4.7.x Standard.
2. Importeer `project.godot` vanuit de Godot Project Manager.
3. Start het project met F6/F5.

## Tests uitvoeren

```text
godot --headless --path . -s res://tests/run_tests.gd
```

De meest recente GitHub Actions-run bevat 509 geslaagde tests. Zie
`tasks/TASK_06_BEGINNER_TABLE_PRESENTATION.md` voor de bijbehorende status.

Bij iedere push en pull request voert GitHub Actions dezelfde tests uit met
Godot 4.7.2, gevolgd door een korte rooktest van de hoofdscene.

## Ontwikkelafspraken

Lees `AGENTS.md` voordat je code wijzigt. Belangrijke uitgangspunten:

- verander Toepenregels nooit stilzwijgend;
- houd spelregels los van de interface;
- laat AI nooit verborgen kaarten bekijken;
- voeg tests toe bij gewijzigde logica;
- maak kleine, speelbare checkpoints.

