TextFonts = {
    ["pricedown"] = 7,
    ["chalet"]    = 0,
    ["condensed"] = 4,
}

TextColors = {
    ["gold"]  = {255, 223, 0, 255},
    ["weiss"] = {255, 255, 255, 255},
    ["rot"]   = {255, 50, 50, 255},
    ["gruen"] = {50, 255, 50, 255},
    ["blau"]  = {100, 150, 255, 255},
}

ScenarioList = {
    ["WORLD_HUMAN_CLIPBOARD"]       = "Klemmbrett",
    ["WORLD_HUMAN_GUARD_STAND"]     = "Wache stehen",
    ["WORLD_HUMAN_SMOKING"]         = "Rauchen",
    ["WORLD_HUMAN_DRINKING"]        = "Trinken",
    ["WORLD_HUMAN_AA_COFFEE"]       = "Kaffee trinken",
    ["WORLD_HUMAN_STAND_MOBILE"]    = "Am Handy",
    ["WORLD_HUMAN_HANG_OUT_STREET"] = "Herumstehen",
    ["WORLD_HUMAN_LEANING"]         = "Anlehnen",
    ["WORLD_HUMAN_BUM_STANDING"]    = "Bettler",
    ["WORLD_HUMAN_TOURIST_MAP"]     = "Karte lesen",
}

PedModels = {
    ["a_m_y_hipster_01"]    = "Hipster",
    ["a_m_m_indian_01"]     = "Inder",
    ["a_m_m_bevhills_02"]   = "Beverly Hills",
    ["s_m_m_pilot_01"]      = "Pilot",
    ["a_m_y_business_01"]   = "Geschäftsmann",
    ["a_m_y_surfer_01"]     = "Surfer",
    ["a_f_y_business_01"]   = "Geschäftsfrau",
    ["s_m_y_cop_01"]        = "Polizist",
    ["s_m_m_doctor_01"]     = "Arzt",
    ["s_m_y_fireman_01"]    = "Feuerwehrmann",
    ["u_m_y_tattoo_01"]     = "Tätowierer",
    ["s_f_y_bartender_01"]  = "Barkeeperin",
}

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
        pedModel = "a_m_y_business_01",
        patrolRadius = 15.0,
        enablePatrol = true,
        scenario = "WORLD_HUMAN_CLIPBOARD",
        textFont = "chalet",
        textColor = "weiss",
        textScale = 0.90,
        messages = {
            "Willkommen bei STO Motors!",
            "Hier finden Sie die besten LKWs der Stadt.",
            "Unsere Fahrzeuge sind bereit für Besichtigungen,",
            "und Sie können sie auch gerne Probe fahren!",
            "Viel Spaß bei STO Motors!"
        }
    }
}