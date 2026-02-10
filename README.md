# INFONPC - NPC Dashboard System

Ein dynamisches NPC-Verwaltungssystem für ESX Legacy FiveM Server mit Live-Dashboard zur einfachen Erstellung und Verwaltung von NPCs mit Nachrichten.

## 🎯 Features

- ✅ **Live Dashboard** - Moderne, responsive UI zur NPC-Verwaltung in Echtzeit
- ✅ **Koordinaten-Erfassung** - Gehe zur Position und drücke ENTER zum Setzen
- ✅ **NPC-Liste** - Übersicht aller gesetzten NPCs mit Nachrichten
- ✅ **Edit, Spawn & Delete** - Einzelne NPCs bearbeiten, spawnen und löschen
- ✅ **File-Based Storage** - Datenspeicherung in JSON für optimale Performance (0.01ms)
- ✅ **Live-Synchronisation** - Alle Clients werden sofort bei Änderungen aktualisiert
- ✅ **ESX Legacy Kompatibel** - Vollständig integriert mit ESX
- ✅ **Admin-Only** - Nur Admins/Superadmins können NPCs verwalten

## 📦 Installation

1. Kopiere den `NPC_Mitteilungen` Ordner in dein `resources` Verzeichnis
2. Füge `ensure NPC_Mitteilungen` zu deiner `server.cfg` hinzu
3. Starte den Server neu
4. Die NPCs aus `config.lua` werden automatisch importiert

## 🎮 Verwendung

### Dashboard öffnen
```
/npc          (Kurzbefehl)
/npcadmin
/npcdashboard
```

### NPC erstellen
1. Öffne das Dashboard mit `/npc`
2. Klicke auf **"+ Neuer NPC"**
3. Gehe zur gewünschten Position im Spiel
4. Drücke **ENTER** um die Koordinaten zu setzen
5. Wähle ein Ped-Model und Szenario aus den Dropdown-Menüs
6. Aktiviere optional die Patrouille mit Radius
7. Füge Nachrichten hinzu (eine pro Zeile)
8. Klicke auf **"Speichern"**

### NPC bearbeiten
1. Wähle einen NPC aus der Liste (linke Seite)
2. Klicke auf **"Edit"**
3. Ändere die gewünschten Einstellungen
4. Klicke auf **"Speichern"**

### NPC löschen
- Klicke auf das **✕** Button neben einem NPC in der Liste

### NPC spawnen
- Klicke auf den **"Spawn"** Button um einen NPC zu re-spawnen

## 🔐 Berechtigungen

Nur Spieler mit **Admin-** oder **Superadmin-Rechten** können NPCs verwalten.

## 💾 Datenspeicherung

NPCs werden in `npcs_data.json` gespeichert (wird automatisch erstellt).
Beim ersten Start werden die Standard-NPCs aus `config.lua` importiert.

## ⚡ Performance

- Optimierte File-based Datenspeicherung
- Keine Datenbank-Queries nötig
- Koordinaten-Erfassung nur aktiv wenn Dashboard offen
- Live-Updates nur an geöffnete Dashboards
- Ziel: **~0.01ms** Performance Impact

## 🎨 Dashboard Features

### Linke Seite - NPC Liste
- Zeigt alle NPCs mit Nummer und Model-Name
- Preview der ersten Nachricht
- Schnellzugriff auf Spawn, Edit und Delete

### Rechte Seite - NPC Editor
- Koordinaten-Anzeige mit Live-Erfassung
- Ped-Model Auswahl (8 vordefinierte Models)
- Szenario Auswahl (6 verschiedene Szenarien)
- Patrouille Ein/Aus mit Radius-Einstellung
- Mehrzeilige Nachrichten-Eingabe

## 🛠️ Technische Details

- **Client-Server Architektur** mit ESX Integration
- **NUI (HTML/CSS/JS)** für das Dashboard
- **File-based JSON Storage** statt Datenbank
- **Echtzeit-Synchronisation** über alle Clients
- **Performance-optimiert** mit bedingten Waits

## 📝 Changelog

### Version 2.0.0
- ✨ Komplett neues Dashboard-System
- ✨ Live-Koordinaten-Erfassung
- ✨ Einzelne Delete-Buttons pro NPC
- ✨ Echtzeit-Synchronisation aller Clients
- ✨ File-based Storage System
- 🐛 Array-Bounds Fehler behoben
- ⚡ Performance-Optimierungen

### Version 1.0.0
- Initial Release mit statischer Config
