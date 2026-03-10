-- NPC Mitteilungen Server

RegisterNetEvent("safenpc:requestSync", function()
    TriggerClientEvent("safenpc:spawnAllNPCs", source, NPCConfigs)
end)

RegisterNetEvent("safenpc:interact", function(idx)
    TriggerClientEvent("safenpc:showDialog", source, idx)
end)