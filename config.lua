--[[
╔══════════════════════════════════════════════════════════════════════════════════╗
║                     🎭  NPC MANAGER — KONFIGURATION                            ║
║                            Version 2.2.0                                       ║
║                                                                                ║
║   Alle Einstellungen für den NPC Manager.                                      ║
║   Rechts findest du die Erklärung zu jeder Einstellung.                        ║
║                                                                                ║
║   Befehle:  /npc  oder  /npc_info  (öffnet das Admin-Panel)                    ║
╚══════════════════════════════════════════════════════════════════════════════════╝
]]

Config = {}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  🔐  BERECHTIGUNGEN                                                         │
-- │  Wer darf den /npc Befehl benutzen?                                         │
-- └──────────────────────────────────────────────────────────────────────────────┘

Config.PermissionMode = "none"                  -- "none"     = Jeder Spieler darf /npc nutzen (kein Check)
                                                -- "ace"      = Nur Spieler mit ACE-Berechtigung
                                                --              → In server.cfg: add_ace group.admin npc.admin allow
                                                -- "steamids" = Nur bestimmte Steam-IDs dürfen /npc nutzen

Config.AcePermission = "npc.admin"              -- ACE-Berechtigung (nur wenn PermissionMode = "ace")
                                                -- Beispiel server.cfg:
                                                --   add_ace group.admin npc.admin allow
                                                --   add_principal identifier.steam:xxxxx group.admin

Config.AllowedSteamIDs = {                      -- Erlaubte Steam Hex-IDs (nur wenn PermissionMode = "steamids")
    "steam:110000xxxxxxxxx",                    -- ← Ersetze mit deiner echten Steam Hex-ID
    -- "steam:110000yyyyyyyyy",                 -- ← Weitere Admins hier eintragen
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  📏  ENTFERNUNGEN & INTERAKTION                                             │
-- │  Wie nah muss der Spieler am NPC sein?                                      │
-- └──────────────────────────────────────────────────────────────────────────────┘

Config.InteractDistance = 3.0                    -- Entfernung in Metern, ab der "Drücke E" erscheint
Config.DrawDistance = 10.0                       -- Entfernung in Metern, ab der der NPC-Check beginnt
Config.InteractKey = 38                         -- Taste zum Interagieren (38 = E)
                                                -- Andere Tasten: 47 = G, 74 = H, 311 = K
                                                -- Volle Liste: https://docs.fivem.net/docs/game-references/controls/

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  💬  TEXT-ANZEIGE STANDARDWERTE                                             │
-- │  Werden für neue NPCs als Default verwendet.                                │
-- └──────────────────────────────────────────────────────────────────────────────┘

Config.DefaultTextFont = "pricedown"            -- Standard-Schriftart für neue NPCs
                                                -- Optionen: "pricedown", "chalet", "condensed"

Config.DefaultTextColor = "gold"                -- Standard-Textfarbe für neue NPCs
                                                -- Optionen: "gold", "weiss", "rot", "gruen", "blau"

Config.DefaultTextScale = 0.968                 -- Standard-Textgröße (0.4 bis 1.5)

Config.MessageDuration = 3000                   -- Wie lange jede Nachricht angezeigt wird (in ms)
                                                -- 3000 = 3 Sekunden pro Nachricht

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  🪟  DIALOG-STIL                                                            │
-- │  Wie werden NPC-Nachrichten angezeigt?                                      │
-- └──────────────────────────────────────────────────────────────────────────────┘

Config.DefaultDialogStyle = "panel"             -- Standard Dialog-Stil für neue NPCs
                                                -- "classic" = Schwebender Text über dem NPC (alt)
                                                -- "panel"   = Professionelles Info-Panel (NEU!)
                                                --              mit Header, Untertitel & formatiertem Text
                                                --              Perfekt für Autohäuser, Shops, etc.
                                                -- "ticker"  = Laufschrift / Scrolling Text (NEU!)
                                                --              Scrollt Nachrichten am unteren Bildschirmrand
                                                --              Spieler bleibt frei beweglich

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  🚶  PATROL STANDARDWERTE                                                   │
-- │  Werden für neue NPCs als Default verwendet.                                │
-- └──────────────────────────────────────────────────────────────────────────────┘

Config.DefaultPatrolEnabled = false             -- Soll Patrol bei neuen NPCs aktiviert sein?
Config.DefaultPatrolRadius = 10.0               -- Standard Patrol-Radius in Metern
Config.PatrolSpeed = 1.0                        -- Laufgeschwindigkeit beim Patrouillieren
                                                -- 1.0 = normales Gehen, 2.0 = schnelles Gehen

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  🧠  INTELLIGENTES PATROL-VERHALTEN                                         │
-- │  NPCs verhalten sich natürlich: stehen bleiben, Handy checken, umschauen.   │
-- │  Automatische Stuck-Erkennung verhindert gegen Wände laufen.                │
-- └──────────────────────────────────────────────────────────────────────────────┘

Config.PatrolIdleChance = 70                    -- % Wahrscheinlichkeit für Idle-Animation nach Ankunft
                                                -- 70 = 70% Chance auf Handy/Rauchen/etc., 30% nur kurz stehen

Config.PatrolIdleTimeMin = 3000                 -- Minimale Idle-Zeit in ms (3000 = 3 Sek.)
Config.PatrolIdleTimeMax = 10000                -- Maximale Idle-Zeit in ms (10000 = 10 Sek.)

Config.PatrolStuckCheckInterval = 1500          -- Wie oft Stuck-Prüfung (ms). 1500 = alle 1.5 Sek.
Config.PatrolStuckThreshold = 0.3               -- Min. Meter die NPC sich bewegen muss pro Check
                                                -- Unter 0.3m = NPC steckt fest → sofort Richtungswechsel

Config.PatrolStuckMaxRetries = 3                -- Nach X fehlgeschlagenen Versuchen: Reset zur Startposition
                                                -- Verhindert endloses Steckenbleiben

Config.PatrolArrivalThreshold = 2.0             -- Entfernung in Metern ab der NPC als "angekommen" gilt
Config.PatrolMaxHeightDiff = 3.0                -- Max. Höhendifferenz in Metern zum Startpunkt
                                                -- Verhindert dass NPCs in Abgründe/auf Dächer laufen

Config.PatrolIdleScenarios = {                  -- Zufällige Animationen zwischen Wanderungen
    "WORLD_HUMAN_STAND_MOBILE",                 -- Am Handy schauen
    "WORLD_HUMAN_SMOKING",                      -- Rauchen
    "WORLD_HUMAN_AA_COFFEE",                    -- Kaffee trinken
    "WORLD_HUMAN_HANG_OUT_STREET",              -- Locker herumstehen
    "WORLD_HUMAN_CLIPBOARD",                    -- Klemmbrett lesen
    "WORLD_HUMAN_TOURIST_MAP",                  -- Karte anschauen
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  🔤  SCHRIFTARTEN                                                           │
-- │  GTA V interne Font-IDs für die Textanzeige über dem NPC.                   │
-- └──────────────────────────────────────────────────────────────────────────────┘

TextFonts = {
    ["pricedown"] = 7,                          -- GTA-Standardschrift (fett, markant)
    ["chalet"]    = 0,                          -- Saubere Standardschrift
    ["condensed"] = 4,                          -- Schmale, kompakte Schrift
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  🎨  TEXTFARBEN                                                             │
-- │  RGBA-Werte: {Rot, Grün, Blau, Alpha}  (jeweils 0-255)                     │
-- └──────────────────────────────────────────────────────────────────────────────┘

TextColors = {
    ["gold"]  = {255, 223, 0, 255},             -- Goldgelb (Standard)
    ["weiss"] = {255, 255, 255, 255},           -- Weiß
    ["rot"]   = {255, 50, 50, 255},             -- Rot (Warnung)
    ["gruen"] = {50, 255, 50, 255},             -- Grün (Erfolg)
    ["blau"]  = {100, 150, 255, 255},           -- Blau (Info)
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  🎬  SZENARIEN                                                              │
-- │  Animationen die der NPC im Leerlauf abspielt.                              │
-- └──────────────────────────────────────────────────────────────────────────────┘

ScenarioList = {
    ["WORLD_HUMAN_CLIPBOARD"]       = "Klemmbrett",         -- Schreibt auf Klemmbrett
    ["WORLD_HUMAN_GUARD_STAND"]     = "Wache stehen",       -- Steht stramm als Wache
    ["WORLD_HUMAN_SMOKING"]         = "Rauchen",            -- Raucht eine Zigarette
    ["WORLD_HUMAN_DRINKING"]        = "Trinken",            -- Trinkt aus einer Flasche
    ["WORLD_HUMAN_AA_COFFEE"]       = "Kaffee trinken",     -- Trinkt Kaffee
    ["WORLD_HUMAN_STAND_MOBILE"]    = "Am Handy",           -- Schaut aufs Handy
    ["WORLD_HUMAN_HANG_OUT_STREET"] = "Herumstehen",        -- Steht locker herum
    ["WORLD_HUMAN_LEANING"]         = "Anlehnen",           -- Lehnt sich an
    ["WORLD_HUMAN_BUM_STANDING"]    = "Bettler",            -- Bettler-Animation
    ["WORLD_HUMAN_TOURIST_MAP"]     = "Karte lesen",        -- Liest eine Karte
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  👤  PED-MODELLE                                                            │
-- │  Verfügbare NPC-Modelle mit deutschem Namen.                                │
-- └──────────────────────────────────────────────────────────────────────────────┘

PedModels = {
    -- 👩 Frauen (Business & Luxus)
    ["a_f_y_business_01"]   = "Geschäftsfrau (Blazer)",     -- Frau im dunklen Blazer
    ["a_f_y_business_02"]   = "Geschäftsfrau (Elegant)",    -- Elegante Business-Frau
    ["a_f_y_business_03"]   = "Geschäftsfrau (Modern)",     -- Moderne Business-Frau
    ["a_f_y_business_04"]   = "Geschäftsfrau (Chic)",       -- Schicke Business-Frau
    ["a_f_y_bevhills_01"]   = "Beverly Hills Lady",         -- Reiche Frau, elegant
    ["a_f_y_bevhills_02"]   = "Beverly Hills Dame",         -- Reiche Dame, luxuriös
    ["a_f_y_bevhills_03"]   = "Beverly Hills Schönheit",    -- Glamouröse Frau
    ["a_f_y_bevhills_04"]   = "Beverly Hills Stil",         -- Stilvolle Dame
    ["a_f_m_bevhills_01"]   = "Reife Beverly Hills",        -- Reife elegante Frau
    ["a_f_m_bevhills_02"]   = "Nobelfrau",                  -- Wohlhabende Dame
    ["a_f_y_vinewood_01"]   = "Vinewood Schauspielerin",    -- Vinewood-Frau
    ["a_f_y_vinewood_02"]   = "Vinewood Stylistin",         -- Vinewood-Style
    ["a_f_y_vinewood_03"]   = "Vinewood Eleganz",           -- Vinewood-Elegant
    ["a_f_y_vinewood_04"]   = "Vinewood Glamour",           -- Vinewood-Glamourös
    ["s_f_y_bartender_01"]  = "Barkeeperin",                -- Barkeeperin
    ["a_f_y_fitness_01"]    = "Fitness-Frau",               -- Sportliche Frau
    ["a_f_y_fitness_02"]    = "Fitness-Lady",               -- Sportliche Dame
    ["a_f_y_hipster_01"]    = "Hipster-Frau",               -- Junge Frau, hip
    -- 👔 Männer (Business & Luxus)
    ["a_m_y_business_01"]   = "Geschäftsmann (Anzug)",      -- Mann im Anzug
    ["a_m_y_business_02"]   = "Geschäftsmann (Modern)",     -- Moderner Geschäftsmann
    ["a_m_y_business_03"]   = "Geschäftsmann (Elegant)",    -- Eleganter Geschäftsmann
    ["a_m_m_bevhills_01"]   = "Beverly Hills Mann",         -- Reicher Mann
    ["a_m_m_bevhills_02"]   = "Beverly Hills Gentleman",    -- Gentleman
    ["a_m_y_bevhills_01"]   = "Junger Beverly Hills",       -- Junger reicher Mann
    ["a_m_y_bevhills_02"]   = "Beverly Hills Dresscode",    -- Schicker junger Mann
    ["a_m_y_vinewood_01"]   = "Vinewood Star",              -- Vinewood-Mann
    -- 🎖️ Berufe & Andere
    ["a_m_y_hipster_01"]    = "Hipster",                    -- Junger Mann mit Bart
    ["a_m_m_indian_01"]     = "Inder",                      -- Indischer Mann
    ["s_m_m_pilot_01"]      = "Pilot",                      -- Flugzeugpilot
    ["a_m_y_surfer_01"]     = "Surfer",                     -- Surfer-Typ
    ["s_m_y_cop_01"]        = "Polizist",                   -- LSPD Beamter
    ["s_m_m_doctor_01"]     = "Arzt",                       -- Arzt in Weiß
    ["s_m_y_fireman_01"]    = "Feuerwehrmann",              -- Feuerwehrmann
    ["u_m_y_tattoo_01"]     = "Tätowierer",                 -- Tattoo-Künstler
}

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  📋  NPC-KONFIGURATIONEN                                                    │
-- │  Standard-NPCs die beim ersten Start geladen werden.                        │
-- │  Danach werden NPCs aus npcs_dynamic.json geladen (über das Admin-Panel).   │
-- └──────────────────────────────────────────────────────────────────────────────┘

NPCConfigs = {
    {
        position = vector3(5328.949219, -5249.182617, 32.632935),
        heading = 110.19,
        pedModel = "a_m_y_hipster_01",
        patrolRadius = 10.0,
        enablePatrol = true,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "pricedown",
        textColor = "gold",
        textScale = 0.968,
        dialogStyle = "classic",
        header = "",
        subheader = "",
        messages = {
            "Willkommen, Bürger...",
            "Wie ich sehe, bist du hier, um Geld zu machen!",
            "Aber denk daran: Du musst eine Urkunde zum Ernten kaufen,",
            "sonst geht es nicht gut für dich aus.",
            "Sicherheit bekommst du trotzdem nicht, halte deine Augen offen.",
            "Verlässt du die Insel, bist du auf dich selbst gestellt."
        }
    },
    {
        position = vector3(346.7691, 6511.5366, 28.8469),
        heading = 45.19,
        pedModel = "a_m_y_hipster_01",
        patrolRadius = 10.0,
        enablePatrol = false,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "chalet",
        textColor = "weiss",
        textScale = 0.80,
        dialogStyle = "classic",
        header = "",
        subheader = "",
        messages = {
            "Willkommen, Bürger...",
            "Wie ich sehe, bist du hier, um Geld zu machen!",
            "Aber denk daran: Du musst einen KORB im Baumarkt kaufen,",
            "sonst geht es nicht, danach kannst du wählen",
            "entweder du verkauft die Äpfel direkt",
            " oder du lässt Sie weiter verarbeiten!!",
            "jetzt hab viel Erfolg beim Ernten"
        }
    },
    {
        position = vector3(275.6882, 6632.5288, 29.4859),
        heading = 240.19,
        pedModel = "a_m_y_hipster_01",
        patrolRadius = 10.0,
        enablePatrol = false,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "condensed",
        textColor = "gruen",
        textScale = 0.85,
        dialogStyle = "classic",
        header = "",
        subheader = "",
        messages = {
            "Willkommen, Bürger...",
            "Wie ich sehe, bist du hier, um Geld zu machen!",
            "Aber denk daran: Du musst einen KORB im Baumarkt kaufen,",
            "sonst geht es nicht, danach kannst du den Salat direkt verkaufen",
            "jetzt hab viel Erfolg beim Ernten"
        }
    },
    {
        position = vector3(-1828.6095, 2213.1106, 87.1562),
        heading = 15.1306,
        pedModel = "a_m_m_indian_01",
        patrolRadius = 5.0,
        enablePatrol = false,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "pricedown",
        textColor = "rot",
        textScale = 0.90,
        dialogStyle = "classic",
        header = "",
        subheader = "",
        messages = {
            "Hallo Bürger...",
            "Willkommen auf Petros Weinfelder!",
            "Ihr könnt hier Weintrauben für eure Produktion ernten,",
            "oder sie für den Obstverkauf verwenden.",
            "Wenn ihr einen Schritt weiter gehen wollt,",
            "könnt ihr euren Wein zu Champagner verarbeiten.",
            "Euer Gewinn wird steigen – viel Spaß beim Ernten!"
        }
    },
    {
        position = vector3(-296.8923, 2799.7532, 59.4185),
        heading = 30.9560,
        pedModel = "a_m_m_bevhills_02",
        patrolRadius = 8.0,
        enablePatrol = true,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "chalet",
        textColor = "blau",
        textScale = 0.85,
        dialogStyle = "classic",
        header = "",
        subheader = "",
        messages = {
            "Hallo Bienenfreund...",
            "Willkommen auf Peters Bienenstock!",
            "Hier könnt ihr Honigwaben ernten.",
            "Zum Schutz braucht ihr einen Anzug – den gibt's im Baumarkt.",
            "Verkauft die Waben direkt in der Stadt,",
            "oder bringt sie zur Honigproduktion.",
            "Mehr Aufwand bringt mehr Geld!",
            "Viel Spaß beim Ernten!"
        }
    },
    {
        position = vector3(2855.2056, 4633.4712, 48.8716),
        heading = 97.9560,
        pedModel = "a_m_m_bevhills_02",
        patrolRadius = 18.0,
        enablePatrol = true,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "condensed",
        textColor = "gold",
        textScale = 0.95,
        dialogStyle = "classic",
        header = "",
        subheader = "",
        messages = {
            "Hallo Kartoffelfreund...",
            "Willkommen auf Manfreds Kartoffelfeld!",
            "Hier könnt ihr Kartoffeln ernten.",
            "Zum Ernten benötigst du eine Schaufel die gibt's im Baumarkt.",
            "Verkaufe die Kartoffeln direkt in der Stadt oder Am Strassenankauf,",
            "oder bringt sie zur Pommes verarbeitung.",
            "Mehr Aufwand bringt mehr Geld!",
            "Viel Spaß beim Ernten!"
        }
    },
    {
        position = vector3(-1045.4845, -2751.6497, 21.3617),
        heading = 136.1743,
        pedModel = "s_m_m_pilot_01",
        patrolRadius = 3.0,
        enablePatrol = false,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "pricedown",
        textColor = "gruen",
        textScale = 1.0,
        dialogStyle = "classic",
        header = "",
        subheader = "",
        messages = {
            "Willkommen in GreenZone420!",
            "Hier startet dein Abenteuer in einer pulsierenden Stadt,",
            "voller Chancen und Herausforderungen.",
            "es ist easy bei uns an Geld zu kommen wenn du willst",
            "wir stellen dir erstmal ein Auto damit du schneller am Ziel bist",
            "jetzt hab eine geile Zeit !!"
        }
    },
    {
        position = vector3(50.0846, -1712.6447, 29.3088),
        heading = 226.3262,
        pedModel = "a_f_y_business_01",
        patrolRadius = 0,
        enablePatrol = false,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "chalet",
        textColor = "gold",
        textScale = 0.90,
        dialogStyle = "panel",
        header = "🏎️ Luxus Autohaus Prestige",
        subheader = "Premium Fahrzeuge — Exklusiver Service",
        messages = {
            "## Herzlich willkommen bei Prestige Motors!",
            "Wir bieten Ihnen die exklusivsten Fahrzeuge der Stadt.",
            "Von eleganten Sportwagen bis hin zu luxuriösen Limousinen.",
            "## Unser Service",
            "Vereinbaren Sie eine Probefahrt oder lassen Sie sich beraten.",
            "Unser Team steht Ihnen jederzeit zur Verfügung!",
        }
    }
}