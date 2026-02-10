local myNPCs = {}
local isInteracting = false
local isDashboardOpen = false
local isCapturingCoords = false

ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent("safenpc:spawnAllNPCs", function(cfgs)
    -- Lösche alte NPCs
    for idx, ped in pairs(myNPCs) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    myNPCs = {}

    for idx, cfg in ipairs(cfgs) do
        local model = GetHashKey(cfg.pedModel)
        RequestModel(model)
        local timeout = GetGameTimer() + 5000 -- max 5 Sekunden warten
        while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(10) end
        if not HasModelLoaded(model) then
            print("[SafeNPC] Model konnte nicht geladen werden:", cfg.pedModel)
            goto continue
        end
        local ped = CreatePed(4, model, cfg.position.x, cfg.position.y, cfg.position.z - 1.0, cfg.heading, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        if cfg.scenario then
            TaskStartScenarioInPlace(ped, cfg.scenario, 0, true)
        end
        myNPCs[idx] = ped
        -- Patrouille
        if cfg.enablePatrol and cfg.patrolRadius > 0 then
            Citizen.CreateThread(function()
                while DoesEntityExist(ped) do
                    local target = getRandomPointInRadius(cfg.position, cfg.patrolRadius)
                    TaskGoToCoordAnyMeans(ped, target.x, target.y, target.z, 1.0, 0, 0, 786603, 0)
                    local steps, arrived = 0, false
                    while not arrived and DoesEntityExist(ped) do
                        Citizen.Wait(500)
                        steps = steps + 1
                        local pedCoords = GetEntityCoords(ped)
                        local distance = #(pedCoords - target)
                        if distance < 1.0 then
                            arrived = true
                        elseif steps > 50 then
                            target = getRandomPointInRadius(cfg.position, cfg.patrolRadius)
                            TaskGoToCoordAnyMeans(ped, target.x, target.y, target.z, 1.0, 0, 0, 786603, 0)
                            steps = 0
                        end
                    end
                    if DoesEntityExist(ped) and cfg.scenario then
                        TaskStartScenarioInPlace(ped, cfg.scenario, 0, true)
                        Citizen.Wait(5000)
                    end
                end
            end)
        end
        ::continue::
    end
    
    -- Update dashboard if open
    if isDashboardOpen then
        SendNUIMessage({
            action = 'updateNPCs',
            npcs = cfgs
        })
    end
end)

function getRandomPointInRadius(center, radius)
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * radius
    local offsetX = math.cos(angle) * distance
    local offsetY = math.sin(angle) * distance
    return vector3(center.x + offsetX, center.y + offsetY, center.z)
end

AddEventHandler("onClientResourceStart", function(res)
    if res == GetCurrentResourceName() then
        TriggerServerEvent("safenpc:requestSync")
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for idx, ped in pairs(myNPCs) do
            if ped and DoesEntityExist(ped) then
                local pedCoords = GetEntityCoords(ped)
                local dist = #(playerCoords - pedCoords)
                if dist < 3.0 and not isInteracting then
                    drawTextAbovePlayer(ped, "Drücke ~g~E~s~, um zu sprechen", 0.726)
                    if IsControlJustReleased(0, 38) then
                        isInteracting = true
                        TriggerServerEvent("safenpc:interact", idx)
                    end
                end
            end
        end
    end
end)

RegisterNetEvent("safenpc:showDialog", function(idx)
    local cfg = NPCConfigs[idx]
    if not cfg then isInteracting = false return end
    displayMessagesAbovePlayer(cfg.messages, function() isInteracting = false end)
end)

function drawTextAbovePlayer(entity, text, scale)
    local entityCoords = GetEntityCoords(entity)
    local onScreen, _x, _y = World3dToScreen2d(entityCoords.x, entityCoords.y, entityCoords.z + 1.0)
    if onScreen then
        SetTextFont(7)
        SetTextScale(scale, scale)
        SetTextCentre(true)
        SetTextEdge(2, 0, 0, 0, 255)
        SetTextOutline()
        SetTextColour(255, 223, 0, 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

function displayMessagesAbovePlayer(messages, callback)
    Citizen.CreateThread(function()
        for _, message in ipairs(messages) do
            local startTime = GetGameTimer()
            local duration = 3000
            while GetGameTimer() - startTime < duration do
                Citizen.Wait(0)
                drawTextAbovePlayer(PlayerPedId(), message, 0.968)
            end
        end
        if callback then callback() end
    end)
end

-- Dashboard Commands
RegisterCommand('npcdashboard', function()
    if not isDashboardOpen then
        openDashboard()
    else
        closeDashboard()
    end
end, false)

RegisterCommand('npcadmin', function()
    if not isDashboardOpen then
        openDashboard()
    else
        closeDashboard()
    end
end, false)

RegisterCommand('npc', function()
    if not isDashboardOpen then
        openDashboard()
    else
        closeDashboard()
    end
end, false)

function openDashboard()
    isDashboardOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open'
    })
end

function closeDashboard()
    isDashboardOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = 'close'
    })
end

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    closeDashboard()
    cb('ok')
end)

RegisterNUICallback('getNPCs', function(data, cb)
    ESX.TriggerServerCallback('safenpc:getNPCs', function(npcs)
        cb({npcs = npcs})
    end)
end)

RegisterNUICallback('saveNPC', function(data, cb)
    TriggerServerEvent('safenpc:saveNPC', data.npc, data.index)
    cb('ok')
end)

RegisterNUICallback('deleteNPC', function(data, cb)
    TriggerServerEvent('safenpc:deleteNPC', data.index)
    cb('ok')
end)

RegisterNUICallback('spawnNPC', function(data, cb)
    TriggerServerEvent('safenpc:spawnSingleNPC', data.index)
    cb('ok')
end)

RegisterNUICallback('captureCoords', function(data, cb)
    isCapturingCoords = true
    cb('ok')
end)

-- Coordinate capture on Enter key
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if isCapturingCoords and IsControlJustReleased(0, 191) then -- ENTER key
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local heading = GetEntityHeading(playerPed)
            
            SendNUIMessage({
                action = 'coordsCaptured',
                coords = {
                    x = coords.x,
                    y = coords.y,
                    z = coords.z,
                    heading = heading
                }
            })
            
            isCapturingCoords = false
            
            -- Notification
            ESX.ShowNotification('Position gesetzt!')
        end
    end
end)

-- Re-spawn single NPC event
RegisterNetEvent('safenpc:respawnSingleNPC', function(idx, cfg)
    -- Delete old NPC if exists
    if myNPCs[idx] and DoesEntityExist(myNPCs[idx]) then
        DeleteEntity(myNPCs[idx])
        myNPCs[idx] = nil
    end
    
    -- Spawn new NPC
    local model = GetHashKey(cfg.pedModel)
    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(10) end
    if not HasModelLoaded(model) then
        print("[SafeNPC] Model konnte nicht geladen werden:", cfg.pedModel)
        return
    end
    
    local ped = CreatePed(4, model, cfg.position.x, cfg.position.y, cfg.position.z - 1.0, cfg.heading, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    
    if cfg.scenario then
        TaskStartScenarioInPlace(ped, cfg.scenario, 0, true)
    end
    
    myNPCs[idx] = ped
    
    -- Patrouille
    if cfg.enablePatrol and cfg.patrolRadius > 0 then
        Citizen.CreateThread(function()
            while DoesEntityExist(ped) do
                local target = getRandomPointInRadius(cfg.position, cfg.patrolRadius)
                TaskGoToCoordAnyMeans(ped, target.x, target.y, target.z, 1.0, 0, 0, 786603, 0)
                local steps, arrived = 0, false
                while not arrived and DoesEntityExist(ped) do
                    Citizen.Wait(500)
                    steps = steps + 1
                    local pedCoords = GetEntityCoords(ped)
                    local distance = #(pedCoords - target)
                    if distance < 1.0 then
                        arrived = true
                    elseif steps > 50 then
                        target = getRandomPointInRadius(cfg.position, cfg.patrolRadius)
                        TaskGoToCoordAnyMeans(ped, target.x, target.y, target.z, 1.0, 0, 0, 786603, 0)
                        steps = 0
                    end
                end
                if DoesEntityExist(ped) and cfg.scenario then
                    TaskStartScenarioInPlace(ped, cfg.scenario, 0, true)
                    Citizen.Wait(5000)
                end
            end
        end)
    end
end)