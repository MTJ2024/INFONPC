ESX = exports["es_extended"]:getSharedObject()

local NPCData = {}
local dataFile = "npcs_data.json"

-- Load NPCs from file
function LoadNPCsFromFile()
    local file = LoadResourceFile(GetCurrentResourceName(), dataFile)
    if file then
        local success, data = pcall(json.decode, file)
        if success and data then
            NPCData = data
            print("[SafeNPC] Loaded " .. #NPCData .. " NPCs from file")
            return NPCData
        else
            print("[SafeNPC] Error parsing JSON file, using default config")
        end
    else
        print("[SafeNPC] No data file found, using default config")
    end
    
    -- If no file or error, use config
    NPCData = NPCConfigs
    SaveNPCsToFile()
    return NPCData
end

-- Save NPCs to file
function SaveNPCsToFile()
    local success = SaveResourceFile(GetCurrentResourceName(), dataFile, json.encode(NPCData, {indent = true}), -1)
    if success then
        print("[SafeNPC] Saved " .. #NPCData .. " NPCs to file")
    else
        print("[SafeNPC] Error saving NPCs to file!")
    end
end

-- Initialize
Citizen.CreateThread(function()
    LoadNPCsFromFile()
end)

-- Sync NPCs to clients
RegisterNetEvent("safenpc:requestSync", function()
    TriggerClientEvent("safenpc:spawnAllNPCs", source, NPCData)
end)

-- Get NPCs callback
ESX.RegisterServerCallback('safenpc:getNPCs', function(source, cb)
    cb(NPCData)
end)

-- Save NPC
RegisterNetEvent('safenpc:saveNPC', function(npcData, index)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Check permissions (admin only)
    if xPlayer.getGroup() ~= 'admin' and xPlayer.getGroup() ~= 'superadmin' then
        TriggerClientEvent('esx:showNotification', source, 'Keine Berechtigung!')
        return
    end
    
    if index >= 0 and index < #NPCData then
        -- Edit existing NPC
        NPCData[index + 1] = npcData
        print("[SafeNPC] Updated NPC #" .. (index + 1))
    else
        -- Add new NPC
        table.insert(NPCData, npcData)
        print("[SafeNPC] Added new NPC #" .. #NPCData)
    end
    
    SaveNPCsToFile()
    
    -- Update all clients
    TriggerClientEvent("safenpc:spawnAllNPCs", -1, NPCData)
    TriggerClientEvent('esx:showNotification', source, 'NPC gespeichert!')
end)

-- Delete NPC
RegisterNetEvent('safenpc:deleteNPC', function(index)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Check permissions (admin only)
    if xPlayer.getGroup() ~= 'admin' and xPlayer.getGroup() ~= 'superadmin' then
        TriggerClientEvent('esx:showNotification', source, 'Keine Berechtigung!')
        return
    end
    
    if index >= 0 and index < #NPCData then
        table.remove(NPCData, index + 1)
        print("[SafeNPC] Deleted NPC #" .. (index + 1))
        SaveNPCsToFile()
        
        -- Update all clients
        TriggerClientEvent("safenpc:spawnAllNPCs", -1, NPCData)
        TriggerClientEvent('esx:showNotification', source, 'NPC gelöscht!')
    end
end)

-- Spawn single NPC
RegisterNetEvent('safenpc:spawnSingleNPC', function(index)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Check permissions (admin only)
    if xPlayer.getGroup() ~= 'admin' and xPlayer.getGroup() ~= 'superadmin' then
        TriggerClientEvent('esx:showNotification', source, 'Keine Berechtigung!')
        return
    end
    
    if index >= 0 and index < #NPCData then
        local cfg = NPCData[index + 1]
        TriggerClientEvent('safenpc:respawnSingleNPC', source, index + 1, cfg)
        TriggerClientEvent('esx:showNotification', source, 'NPC gespawnt!')
    end
end)

-- Interact with NPC
RegisterNetEvent("safenpc:interact", function(idx)
    TriggerClientEvent("safenpc:showDialog", source, idx)
end)