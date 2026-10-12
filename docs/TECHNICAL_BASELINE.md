# Technische nulmeting

Datum: 12 oktober 2026

## Gecontroleerd

- De aangeleverde ZIP bevat een volledig Godot-project en de lokale Git-geschiedenis.
- `project.godot` gebruikt Godot 4.7 en start bij `scenes/menu.tscn`.
- Kernlogica, AI, campagnesystemen, tutorials en interfacecode zijn gescheiden.
- De game gebruikt geen netwerkverbindingen of shellcommando's.
- Alleen de savegame schrijft lokaal via Godots `FileAccess`.
- Alle GDScript-bestanden kunnen door de parser van `gdtoolkit` worden gelezen.
- De werkmap was schoon bij ontvangst.

## Teststatus

`tasks/TASK_05_RESULT.md` registreert 496 geslaagde Godot-tests en succesvolle
smoketests op 390 x 844. Deze omgeving bevat geen Godot-runtime. Daarom zijn de
Godot-tests bij deze import niet opnieuw uitgevoerd.

## Linter

`gdlint` rapporteert 93 onderhoudspunten. Het grootste deel bestaat uit regels
langer dan 100 tekens. Daarnaast zijn enkele grote functies en klassen gemeld.
Dit zijn op zichzelf geen runtimefouten en ze worden niet mechanisch aangepast,
omdat zulke wijzigingen zonder Godot-testuitvoer onnodig risico geven.

## Bekende technische punten

1. Live spelstatus midden in een hand wordt nog niet opgeslagen.
2. Sommige UI- en spelcontrollers zijn groot en kunnen later worden opgesplitst.
3. Headless smoketests melden volgens Task 05 nog enkele resource-leakwaarschuwingen.
4. Definitieve pixel-art, audio, haptics en animatiepolish ontbreken nog.
5. Mobiele bediening moet op een echt iPhone-scherm worden getest.

## Aanbevolen volgende checkpoint

Maak eerst een rustige visuele vertical slice van het Studentenhuis:

- tafel gezien vanuit de speler;
- drie zichtbare tegenstanders: Feut, Sjaars en Huisoudste;
- duidelijke kaartanimatie van hand naar tafel;
- optionele kaarttips en mee/pas-advies;
- beginner-AI die herkenbare fouten maakt;
- retro pixelstijl zonder extra interfacechaos;
- mobiele test op 390 x 844 en een volledige regressietest.

De spelregels en campagneflow blijven daarbij ongewijzigd.
