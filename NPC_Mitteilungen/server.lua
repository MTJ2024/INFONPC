-- Server-seitige NPC-Synchronisation
-- NPCs dienen nur als Informationsquelle, keine zusätzliche Funktionalität

RegisterNetEvent("safenpc:requestSync", function()
    local src = source
    -- Sende alle NPC-Konfigurationen an den anfragenden Client
    if NPCConfigs and type(NPCConfigs) == 'table' and #NPCConfigs > 0 then
        TriggerClientEvent("safenpc:spawnAllNPCs", src, NPCConfigs)
    else
        print("^1[NPC-Mitteilungen Server]^7 FEHLER: NPCConfigs nicht gefunden!")
    end
end)

RegisterNetEvent("safenpc:interact", function(idx)
    local src = source
    -- Spieler interagiert mit NPC, sende Dialog zurück
    TriggerClientEvent("safenpc:showDialog", src, idx)
end)

-- Optional: Bei Serverstart alle Clients synchronisieren
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        print("^2[NPC-Mitteilungen Server]^7 Resource gestartet - NPCs werden synchronisiert")
        if NPCConfigs and type(NPCConfigs) == 'table' and #NPCConfigs > 0 then
            -- Synchronisiere alle Clients
            TriggerClientEvent("safenpc:spawnAllNPCs", -1, NPCConfigs)
            print("^2[NPC-Mitteilungen Server]^7 " .. #NPCConfigs .. " NPCs synchronisiert")
        else
            print("^1[NPC-Mitteilungen Server]^7 FEHLER: NPCConfigs nicht gefunden!")
        end
    end
end)