-- Server-seitige NPC-Synchronisation
-- NPCs dienen nur als Informationsquelle, keine zusätzliche Funktionalität

RegisterNetEvent("safenpc:requestSync", function()
    local src = source
    -- Sende alle NPC-Konfigurationen an den anfragenden Client
    TriggerClientEvent("safenpc:spawnAllNPCs", src, NPCConfigs)
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
        -- Synchronisiere alle Clients
        TriggerClientEvent("safenpc:spawnAllNPCs", -1, NPCConfigs)
    end
end)