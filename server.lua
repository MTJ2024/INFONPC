-- Server-seitige NPC-Synchronisation
-- NPCs dienen nur als Informationsquelle, keine zusätzliche Funktionalität

-- Dynamische NPC-Konfigurationen (werden beim Start aus Datei geladen)
local DynamicNPCs = {}
local configFilePath = "npcs_dynamic.json"

-- Funktion zum Prüfen, ob ein Spieler Admin ist (liest Config.PermissionMode)
local function isPlayerAdmin(source)
    local mode = Config and Config.PermissionMode or "none"

    -- "none" = Jeder darf /npc nutzen (kein Berechtigungs-Check)
    if mode == "none" then
        return true
    end

    -- "ace" = Prüfe ACE-Berechtigung (muss in server.cfg eingerichtet sein)
    if mode == "ace" then
        local perm = Config.AcePermission or "npc.admin"
        return IsPlayerAceAllowed(source, perm)
    end

    -- "steamids" = Prüfe ob Steam-ID in der Whitelist steht
    if mode == "steamids" then
        local allowed = Config.AllowedSteamIDs or {}
        for _, id in ipairs(GetPlayerIdentifiers(source)) do
            for _, steamId in ipairs(allowed) do
                if id == steamId then
                    return true
                end
            end
        end
        return false
    end

    -- Unbekannter Modus → sicherheitshalber Zugriff verweigern + Warnung
    print("^1[NPC Manager]^7 FEHLER: Unbekannter PermissionMode '" .. tostring(mode) .. "' — Zugriff verweigert! Bitte config.lua prüfen.")
    return false
end

-- NPCs aus Datei laden
local function loadNPCsFromFile()
    local file = LoadResourceFile(GetCurrentResourceName(), configFilePath)
    if file then
        local success, data = pcall(function() return json.decode(file) end)
        if success and data then
            DynamicNPCs = data
            print("^2[NPC Manager]^7 " .. #DynamicNPCs .. " NPCs aus Datei geladen")
            return true
        end
    end
    print("^3[NPC Manager]^7 Keine gespeicherten NPCs gefunden, verwende config.lua")
    return false
end

-- NPCs in Datei speichern
local function saveNPCsToFile()
    local json = json.encode(DynamicNPCs, {indent = true})
    SaveResourceFile(GetCurrentResourceName(), configFilePath, json, -1)
    print("^2[NPC Manager]^7 " .. #DynamicNPCs .. " NPCs gespeichert")
end

-- Aktuelle NPC-Liste abrufen (dynamisch oder aus config.lua)
local function getCurrentNPCs()
    if #DynamicNPCs > 0 then
        return DynamicNPCs
    else
        return NPCConfigs or {}
    end
end

-- UI-Zugriff anfragen
RegisterNetEvent("safenpc:requestUIAccess", function()
    local src = source
    
    if not isPlayerAdmin(src) then
        TriggerClientEvent('chat:addMessage', src, {
            color = {255, 0, 0},
            multiline = true,
            args = {"NPC Manager", "Du hast keine Berechtigung für diesen Befehl!"}
        })
        return
    end
    
    local npcs = getCurrentNPCs()
    TriggerClientEvent('safenpc:openUI', src, npcs)
end)

-- NPC speichern (erstellen oder aktualisieren)
RegisterNetEvent("safenpc:saveNPC", function(index, npcData)
    local src = source
    
    if not isPlayerAdmin(src) then
        return
    end
    
    -- Konvertiere Position zu Tabelle falls nötig
    if npcData.position.x and npcData.position.y and npcData.position.z then
        npcData.position = {
            x = tonumber(npcData.position.x),
            y = tonumber(npcData.position.y),
            z = tonumber(npcData.position.z)
        }
    end
    
    -- Wenn DynamicNPCs leer ist, kopiere aus NPCConfigs
    if #DynamicNPCs == 0 and NPCConfigs then
        DynamicNPCs = {}
        for i, npc in ipairs(NPCConfigs) do
            table.insert(DynamicNPCs, {
                position = {x = npc.position.x, y = npc.position.y, z = npc.position.z},
                heading = npc.heading,
                pedModel = npc.pedModel,
                patrolRadius = npc.patrolRadius,
                enablePatrol = npc.enablePatrol,
                scenario = npc.scenario,
                textFont = npc.textFont,
                textColor = npc.textColor,
                textScale = npc.textScale,
                dialogStyle = npc.dialogStyle,
                header = npc.header,
                subheader = npc.subheader,
                messages = npc.messages
            })
        end
    end
    
    if index == nil then
        -- Neuer NPC
        table.insert(DynamicNPCs, npcData)
        print("^2[NPC Manager]^7 Neuer NPC erstellt (ID: " .. #DynamicNPCs .. ")")
    else
        -- Bestehender NPC aktualisieren
        local luaIndex = index + 1
        if luaIndex < 1 or luaIndex > #DynamicNPCs then
            print("^1[NPC Manager]^7 Ungültiger Index: " .. tostring(index))
            return
        end
        DynamicNPCs[luaIndex] = npcData
        print("^2[NPC Manager]^7 NPC #" .. luaIndex .. " aktualisiert")
    end
    
    -- Speichern und alle Clients aktualisieren
    saveNPCsToFile()
    TriggerClientEvent('safenpc:spawnAllNPCs', -1, DynamicNPCs)
    
    -- UI aktualisieren
    TriggerClientEvent('safenpc:updateUIList', src, DynamicNPCs)
    
    TriggerClientEvent('chat:addMessage', src, {
        color = {0, 255, 0},
        multiline = true,
        args = {"NPC Manager", "NPC erfolgreich gespeichert!"}
    })
end)

-- NPC löschen
RegisterNetEvent("safenpc:deleteNPC", function(index)
    local src = source
    
    if not isPlayerAdmin(src) then
        return
    end
    
    local luaIndex = index ~= nil and (index + 1) or nil
    if luaIndex and luaIndex >= 1 and luaIndex <= #DynamicNPCs then
        table.remove(DynamicNPCs, luaIndex)
        print("^2[NPC Manager]^7 NPC #" .. luaIndex .. " gelöscht")
        
        -- Speichern und alle Clients aktualisieren
        saveNPCsToFile()
        TriggerClientEvent('safenpc:spawnAllNPCs', -1, DynamicNPCs)
        
        -- UI aktualisieren
        TriggerClientEvent('safenpc:updateUIList', src, DynamicNPCs)
        
        TriggerClientEvent('chat:addMessage', src, {
            color = {0, 255, 0},
            multiline = true,
            args = {"NPC Manager", "NPC erfolgreich gelöscht!"}
        })
    end
end)

RegisterNetEvent("safenpc:requestSync", function()
    local src = source
    -- Sende alle NPC-Konfigurationen an den anfragenden Client
    local npcs = getCurrentNPCs()
    if npcs and type(npcs) == 'table' and #npcs > 0 then
        TriggerClientEvent("safenpc:spawnAllNPCs", src, npcs)
    else
        print("^1[NPC-Mitteilungen Server]^7 FEHLER: NPCConfigs nicht gefunden!")
    end
end)

RegisterNetEvent("safenpc:interact", function(idx)
    local src = source
    -- Spieler interagiert mit NPC, sende Dialog zurück
    local npcs = getCurrentNPCs()
    if npcs and npcs[idx] then
        TriggerClientEvent("safenpc:showDialog", src, npcs[idx])
    end
end)

-- Optional: Bei Serverstart alle Clients synchronisieren
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("^2[NPC-Mitteilungen Server]^7 Resource gestartet")
        
        -- Versuche dynamische NPCs zu laden
        if not loadNPCsFromFile() then
            -- Fallback auf config.lua
            DynamicNPCs = {}
        end
        
        local npcs = getCurrentNPCs()
        if npcs and type(npcs) == 'table' and #npcs > 0 then
            -- Synchronisiere alle Clients
            TriggerClientEvent("safenpc:spawnAllNPCs", -1, npcs)
            print("^2[NPC-Mitteilungen Server]^7 " .. #npcs .. " NPCs synchronisiert")
        else
            print("^1[NPC-Mitteilungen Server]^7 FEHLER: NPCConfigs nicht gefunden!")
        end
    end
end)