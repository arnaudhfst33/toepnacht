# Task 06 — Rustige beginnerstafel

## Doel

Maak het eerste Studentenhuis-potje begrijpelijker en levendiger zonder de
spelregels of campagneflow te veranderen.

## Opgeleverd in dit checkpoint

- Studentenhuis potje 1 gebruikt Feut, Sjaars en Huisoudste.
- Drie zichtbare pixelpersonages zitten tegenover de speler.
- De actieve speler krijgt een duidelijke lichte rand.
- De achtergrond toont een eenvoudige pixelachtige studentenkamer en tafel.
- Kaarten hebben een rustiger retro uiterlijk en reageren subtiel op hover/touch.
- Gespeelde kaarten bewegen vanuit de betreffende speler naar de tafel.
- De hand krijgt een eenvoudige sterktescore met uitleg.
- De tip benoemt een concrete legale kaart en legt de reden uit.
- Bij een klop verschijnt contextueel advies over MEE of PAS.
- Kaartuitleg verschijnt bij hover; ongeldige kaarten leggen kleur bekennen uit.
- Alle leerhulp volgt de bestaande instelling `tips_on`.
- Vier nieuwe regressietests controleren advies en de Studentenhuis-cast.
- GitHub Actions voert voortaan Godot 4.7.2-tests en een rooktest uit.

## Bewuste beperkingen

- De kaartadviseur is een uitlegfunctie, geen perfecte Toepen-AI.
- De adviseur gebruikt alleen de eigen hand en openbare tafelgegevens.
- Definitieve illustraties, muziek en geluidseffecten vallen buiten deze taak.
- De eerste visuele controle moet nog plaatsvinden in Godot op 390 x 844.

## Lokale validatie in deze omgeving

- Alle GDScript-bestanden zijn succesvol geparset met `gdparse`.
- De vier nieuwe scripts/tests zijn lint-schoon.
- De volledige Godot-tests draaien na push in GitHub Actions omdat lokaal geen
  Godot-runtime beschikbaar is.

