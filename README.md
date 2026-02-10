# INFONPC - NPC Mitteilungen Resource

Eine FiveM Resource für interaktive NPC-Informationspunkte.

## Beschreibung

Diese Resource fügt NPCs als interaktive Informationsquellen zu deinem FiveM GTA V RP Server hinzu. Spieler können sich NPCs nähern und durch Drücken der E-Taste Informationen abrufen.

## Features

- 8 vorkonfigurierte NPCs an verschiedenen Standorten
- Interaktive Informationsanzeige
- Server-seitige NPC-Synchronisation
- Patrol-Funktionalität für ausgewählte NPCs
- Native GTA Text-Anzeige (kein HTML/NUI benötigt)

## Installation

1. Lade das Repository herunter oder klone es:
   ```bash
   cd resources
   git clone https://github.com/MTJ2024/INFONPC.git
   ```

2. Füge die Resource in deiner `server.cfg` hinzu:
   ```
   ensure INFONPC
   ```

3. Starte deinen Server neu

## Konfiguration

Alle NPC-Konfigurationen befinden sich in `config.lua`. Dort kannst du:
- Position und Heading der NPCs ändern
- Ped-Models anpassen
- Patrol-Radius einstellen
- Szenarien (Animationen) ändern
- Nachrichten bearbeiten

## Verwendung

- Nähere dich einem NPC (< 3 Meter Entfernung)
- Der Text "Drücke E, um zu sprechen" erscheint
- Drücke `E` um die Informationen zu lesen
- Nachrichten werden nacheinander über deinem Kopf angezeigt

## Credits

- Author: MTJ2024
- Version: 1.0.0
