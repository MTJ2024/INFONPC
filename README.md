# INFONPC - NPC Mitteilungen Resource

Eine FiveM Resource für interaktive NPC-Informationspunkte mit Live-Management-UI.

## Beschreibung

Diese Resource fügt NPCs als interaktive Informationsquellen zu deinem FiveM GTA V RP Server hinzu. Spieler können sich NPCs nähern und durch Drücken der E-Taste Informationen abrufen. Mit dem neuen UI-Management-System können Admins NPCs live erstellen, bearbeiten und löschen - ohne Server-Neustart!

## Features

- 🎭 **Live NPC Management** - NPCs erstellen, bearbeiten und löschen ohne Neustart
- 📍 **Position Helper** - Aktuelle Position und Heading mit einem Klick übernehmen
- 🚶 **Patrol-Funktion** - NPCs können in einem konfigurierbaren Radius patrouillieren
- 💬 **Interaktive Nachrichten** - Mehrzeilige Informationen für Spieler
- 💾 **Automatisches Speichern** - Alle Änderungen werden persistent gespeichert
- 🎨 **Modernes UI** - Benutzerfreundliche Oberfläche für einfache Verwaltung
- 🔒 **Admin-System** - Nur berechtigte Spieler können NPCs verwalten

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

3. (Optional) Gib Admins die Berechtigung für den NPC Manager:
   ```
   add_ace group.admin npc.admin allow
   ```

4. Starte deinen Server neu

## Verwendung

### Für Spieler:
- Nähere dich einem NPC (< 3 Meter Entfernung)
- Der Text "Drücke E, um zu sprechen" erscheint
- Drücke `E` um die Informationen zu lesen
- Nachrichten werden nacheinander über deinem Kopf angezeigt

### Für Admins - NPC Manager:

#### UI öffnen:
```
/npc_info   - Öffnet das NPC Management UI
/npc        - Kurzbefehl (Alias für /npc_info)
```

#### NPCs erstellen:
1. Öffne das UI mit `/npc_info`
2. Klicke auf "Neuer NPC"
3. Gehe zur gewünschten Position im Spiel
4. Klicke auf "Aktuelle Position" um die Koordinaten zu übernehmen
5. Klicke auf "Aktuelles Heading" für die Blickrichtung
6. Wähle ein Ped Model (z.B. `a_m_y_hipster_01`)
7. Optional: Aktiviere Patrol und stelle den Radius ein
8. Gib Nachrichten ein (eine pro Zeile)
9. Klicke auf "Speichern"

#### NPCs bearbeiten:
1. Öffne das UI mit `/npc_info`
2. Wähle einen NPC aus der Liste links
3. Bearbeite die Einstellungen
4. Klicke auf "Speichern"

#### NPCs löschen:
1. Öffne das UI mit `/npc_info`
2. Wähle einen NPC aus der Liste
3. Klicke auf "Löschen"
4. Bestätige die Aktion

## Konfiguration

### Statische Konfiguration (config.lua)
Die `config.lua` dient als Basis-Konfiguration mit 8 vorkonfigurierten NPCs. Diese werden beim ersten Start verwendet.

### Dynamische Konfiguration (npcs_dynamic.json)
Sobald du NPCs über das UI bearbeitest, werden sie in `npcs_dynamic.json` gespeichert. Diese Datei hat Vorrang vor der `config.lua` und wird automatisch erstellt.

### Admin-Berechtigungen
Standardmäßig können Spieler mit folgenden ACE-Permissions das UI nutzen:
- `npc.admin`
- `command` (alle Command-Berechtigungen)

Du kannst dies in der `server.lua` anpassen oder Gruppen wie folgt berechtigen:
```
add_ace group.admin npc.admin allow
add_ace group.moderator npc.admin allow
```

## NPC Einstellungen

- **Ped Model**: Das Aussehen des NPCs (z.B. `a_m_y_hipster_01`, `s_m_m_pilot_01`)
- **Position**: X, Y, Z Koordinaten im Spiel
- **Heading**: Blickrichtung (0-360 Grad)
- **Szenario**: Animation des NPCs (z.B. `WORLD_HUMAN_CLIPBOARD`)
- **Patrol aktivieren**: Ob der NPC umherlaufen soll
- **Patrol Radius**: Wie weit der NPC vom Startpunkt patrouilliert (in Metern)
- **Nachrichten**: Informationen, die der NPC dem Spieler mitteilt

## Beliebte Ped Models

- `a_m_y_hipster_01` - Junger männlicher Hipster
- `a_m_m_business_01` - Geschäftsmann
- `s_m_m_pilot_01` - Pilot
- `a_m_y_business_01` - Junger Geschäftsmann
- `a_m_m_indian_01` - Männlich, indisch
- `a_m_m_bevhills_02` - Beverly Hills Bewohner

Vollständige Liste: [GTA V Ped Models](https://wiki.rage.mp/index.php?title=Peds)

## Beliebte Szenarien

- `WORLD_HUMAN_CLIPBOARD` - Mit Klemmbrett
- `WORLD_HUMAN_GUARD_STAND` - Wachposten
- `WORLD_HUMAN_AA_SMOKE` - Rauchen
- `WORLD_HUMAN_DRINKING` - Trinken
- `WORLD_HUMAN_SMOKING` - Rauchen (stehend)

## Troubleshooting

**UI öffnet sich nicht:**
- Prüfe ob du Admin-Berechtigungen hast
- Schaue in die Server-Konsole für Fehlermeldungen
- Stelle sicher dass die Resource korrekt gestartet wurde

**NPCs spawnen nicht:**
- Prüfe die Server-Konsole für Fehler
- Stelle sicher dass die Koordinaten valide sind
- Prüfe ob das Ped Model korrekt geschrieben ist

**Änderungen werden nicht gespeichert:**
- Stelle sicher dass der Server Schreibrechte im Resource-Ordner hat
- Prüfe die `npcs_dynamic.json` Datei

## Credits

- Author: MTJ2024
- Version: 2.0.0
- Mit UI Management System für Live-Bearbeitung
