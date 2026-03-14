local myNPCs = {}
local isInteracting = false
local isUIOpen = false
local currentNPCConfigs = {} -- Cache der aktuellen NPC-Konfigurationen

-- NUI Management Command
RegisterCommand('npc_info', function()
    TriggerServerEvent('safenpc:requestUIAccess')
end, false)

-- Alias für einfacheren Zugriff
RegisterCommand('npc', function()
    TriggerServerEvent('safenpc:requestUIAccess')
end, false)

-- Open UI from server
RegisterNetEvent('safenpc:openUI', function(npcs)
    isUIOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        npcs = npcs
    })
end)

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    isUIOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('saveNPC', function(data, cb)
    TriggerServerEvent('safenpc:saveNPC', data.index, data.npc)
    cb('ok')
end)

RegisterNUICallback('deleteNPC', function(data, cb)
    TriggerServerEvent('safenpc:deleteNPC', data.index)
    cb('ok')
end)

RegisterNUICallback('getCurrentPosition', function(data, cb)
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    SendNUIMessage({
        action = 'setPosition',
        coords = { x = coords.x, y = coords.y, z = coords.z }
    })
    cb('ok')
end)

RegisterNUICallback('getCurrentHeading', function(data, cb)
    local playerPed = PlayerPedId()
    local heading = GetEntityHeading(playerPed)
    SendNUIMessage({
        action = 'setHeading',
        heading = heading
    })
    cb('ok')
end)

-- Update NPC list in UI
RegisterNetEvent('safenpc:updateUIList', function(npcs)
    if isUIOpen then
        SendNUIMessage({
            action = 'updateNPCs',
            npcs = npcs
        })
    end
end)

RegisterNetEvent("safenpc:spawnAllNPCs", function(cfgs)
    -- Speichere die aktuellen Konfigurationen
    currentNPCConfigs = cfgs
    
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
                local patrolSpeed = (Config and Config.PatrolSpeed) or 1.0
                local patrolWait = (Config and Config.PatrolWaitTime) or 5000
                local patrolMaxSteps = (Config and Config.PatrolMaxSteps) or 50
                while DoesEntityExist(ped) do
                    local target = getRandomPointInRadius(cfg.position, cfg.patrolRadius)
                    TaskGoToCoordAnyMeans(ped, target.x, target.y, target.z, patrolSpeed, 0, 0, 786603, 0)
                    local steps, arrived = 0, false
                    while not arrived and DoesEntityExist(ped) do
                        Citizen.Wait(500)
                        steps = steps + 1
                        local pedCoords = GetEntityCoords(ped)
                        local distance = #(pedCoords - target)
                        if distance < 1.0 then
                            arrived = true
                        elseif steps > patrolMaxSteps then
                            target = getRandomPointInRadius(cfg.position, cfg.patrolRadius)
                            TaskGoToCoordAnyMeans(ped, target.x, target.y, target.z, patrolSpeed, 0, 0, 786603, 0)
                            steps = 0
                        end
                    end
                    if DoesEntityExist(ped) and cfg.scenario then
                        TaskStartScenarioInPlace(ped, cfg.scenario, 0, true)
                        Citizen.Wait(patrolWait)
                    end
                end
            end)
        end
        ::continue::
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
        -- Wenn UI offen ist, längere Wartezeit (kein NPC-Checking nötig)
        if isUIOpen then
            Citizen.Wait(1000)
        else
            local sleep = 500 -- Standard-Wartezeit wenn weit weg
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local nearNPC = false
            
            for idx, ped in pairs(myNPCs) do
                if ped and DoesEntityExist(ped) then
                    local pedCoords = GetEntityCoords(ped)
                    local dist = #(playerCoords - pedCoords)
                    local drawDist = (Config and Config.DrawDistance) or 10.0
                    local interactDist = (Config and Config.InteractDistance) or 3.0
                    local interactKey = (Config and Config.InteractKey) or 38
                    
                    -- Nur in der Nähe genauer prüfen
                    if dist < drawDist then
                        nearNPC = true
                        
                        -- Interaktions-Range
                        if dist < interactDist and not isInteracting then
                            sleep = 0 -- Schnelle Updates für Interaktion
                            local cfg = currentNPCConfigs[idx]
                            local font = cfg and cfg.textFont or "pricedown"
                            local color = cfg and cfg.textColor or "gold"
                            drawTextAboveEntity(ped, "Drücke ~g~E~s~, um zu sprechen", 0.726, font, color)
                            if IsControlJustReleased(0, interactKey) then
                                isInteracting = true
                                TriggerServerEvent("safenpc:interact", idx)
                            end
                        end
                    end
                end
            end
            
            -- Dynamische Wartezeit basierend auf Nähe zu NPCs
            if nearNPC and sleep > 0 then
                sleep = 100 -- Mittlere Wartezeit wenn in der Nähe
            end
            
            Citizen.Wait(sleep)
        end
    end
end)

RegisterNetEvent("safenpc:showDialog", function(npcData)
    if not npcData or not npcData.messages then 
        isInteracting = false 
        return 
    end
    
    local dialogStyle = npcData.dialogStyle or "classic"
    
    if dialogStyle == "panel" then
        -- Professionelles NUI Info-Panel anzeigen
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = 'showInfoPanel',
            npcData = npcData
        })
    elseif dialogStyle == "ticker" then
        -- Laufschrift (Ticker) — NUI ohne Fokus, Spieler bleibt frei
        SendNUIMessage({
            action = 'showTicker',
            npcData = npcData
        })
    else
        -- Klassischer schwebender Text
        local textScale = npcData.textScale or 0.968
        local textFont = npcData.textFont or "pricedown"
        local textColor = npcData.textColor or "gold"
        displayMessagesAbovePlayer(npcData.messages, textScale, textFont, textColor, function() isInteracting = false end)
    end
end)

-- NUI Callback: Info-Panel geschlossen
RegisterNUICallback('closeInfoPanel', function(data, cb)
    SetNuiFocus(false, false)
    isInteracting = false
    cb('ok')
end)

-- NUI Callback: Ticker (Laufschrift) fertig
RegisterNUICallback('tickerDone', function(data, cb)
    isInteracting = false
    cb('ok')
end)

-- Hint-Text über dem NPC (3D-Welt-Koordinaten)
function drawTextAboveEntity(entity, text, scale, fontName, colorName)
    local entityCoords = GetEntityCoords(entity)
    local onScreen, _x, _y = World3dToScreen2d(entityCoords.x, entityCoords.y, entityCoords.z + 1.0)
    if onScreen then
        local fontId = (TextFonts and TextFonts[fontName]) or 7
        local color = (TextColors and TextColors[colorName]) or {255, 223, 0, 255}
        SetTextFont(fontId)
        SetTextScale(scale, scale)
        SetTextCentre(true)
        SetTextEdge(2, 0, 0, 0, 255)
        SetTextOutline()
        SetTextColour(color[1], color[2], color[3], color[4])
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(text)
        EndTextCommandDisplayText(_x, _y)
    end
end

-- Zentrierter Text auf dem Bildschirm (feste Position, nicht 3D-gebunden)
-- Unterstützt ## Prefix für größere Überschriften (1.5× Größe)
function drawTextCentered(text, scale, fontName, colorName, yOffset)
    local fontId = (TextFonts and TextFonts[fontName]) or 7
    local color = (TextColors and TextColors[colorName]) or {255, 223, 0, 255}

    -- ## Prefix = Überschrift (größerer Text)
    local displayText = text
    local displayScale = scale
    if string.sub(text, 1, 2) == "##" then
        displayText = string.sub(text, 3)
        -- Leerzeichen am Anfang und Ende entfernen
        displayText = displayText:match("^%s*(.-)%s*$") or displayText
        displayScale = scale * 1.5
    end

    local screenY = yOffset or 0.30

    SetTextFont(fontId)
    SetTextScale(displayScale, displayScale)
    SetTextCentre(true)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextOutline()
    SetTextColour(color[1], color[2], color[3], color[4])
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(displayText)
    EndTextCommandDisplayText(0.5, screenY)
end

-- Nachrichten zentriert auf dem Bildschirm anzeigen (eine nach der anderen)
function displayMessagesAbovePlayer(messages, scale, fontName, colorName, callback)
    Citizen.CreateThread(function()
        local duration = (Config and Config.MessageDuration) or 3000
        for _, message in ipairs(messages) do
            local startTime = GetGameTimer()
            while GetGameTimer() - startTime < duration do
                Citizen.Wait(0)
                drawTextCentered(message, scale, fontName, colorName, 0.30)
            end
        end
        if callback then callback() end
    end)
end