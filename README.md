# INFONPC - NPC Dashboard System

Ein dynamisches NPC-Verwaltungssystem für ESX Legacy FiveM Server mit Live-Dashboard zur einfachen Erstellung und Verwaltung von NPCs mit Nachrichten.

## Features

- ✅ **Live Dashboard** - Einfache UI zur NPC-Verwaltung in Echtzeit
- ✅ **Koordinaten-Erfassung** - Gehe zur Position und drücke ENTER zum Setzen
- ✅ **NPC-Liste** - Übersicht aller gesetzten NPCs mit Nachrichten
- ✅ **Edit & Spawn** - Bearbeiten und Spawnen einzelner NPCs
- ✅ **File-Based Storage** - Datenspeicherung in JSON für optimale Performance (0.01ms)
- ✅ **ESX Legacy Kompatibel** - Vollständig integriert mit ESX
- ✅ **Admin-Only** - Nur Admins können NPCs verwalten

## Installation

1. Kopiere den `NPC_Mitteilungen` Ordner in dein `resources` Verzeichnis
2. Füge `ensure NPC_Mitteilungen` zu deiner `server.cfg` hinzu
3. Starte den Server neu

## Verwendung

### Dashboard öffnen
```
/npcdashboard
oder
/npcadmin
```

### NPC erstellen
1. Öffne das Dashboard mit `/npcdashboard`
2. Klicke auf "Neuer NPC"
3. Gehe zur gewünschten Position im Spiel
4. Drücke **ENTER** um die Koordinaten zu setzen
5. Wähle ein Ped-Model und Szenario
6. Füge Nachrichten hinzu (eine pro Zeile)
7. Klicke auf "Speichern"

### NPC bearbeiten
1. Wähle einen NPC aus der Liste
2. Klicke auf "Edit"
3. Ändere die gewünschten Einstellungen
4. Klicke auf "Speichern"

### NPC spawnen
- Klicke auf den "Spawn" Button neben einem NPC in der Liste

## Berechtigungen

Nur Spieler mit Admin- oder Superadmin-Rechten können NPCs verwalten.

## Datenspeicherung

NPCs werden in `npcs_data.json` gespeichert (automatisch erstellt).
Beim ersten Start werden die Standard-NPCs aus `config.lua` importiert.

## Performance

- Optimierte File-based Datenspeicherung
- Keine Datenbank-Queries nötig
- Ziel: ~0.01ms Performance Impact
