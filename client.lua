local myNPCs = {}
local isInteracting = false
local isUIOpen = false
local currentNPCConfigs = {} -- Cache der aktuellen NPC-Konfigurationen
local headingPlacementActive = false -- Heading-Platzierungsmodus aktiv

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
    -- Kamera-Heading verwenden statt Entity-Heading
    -- So schaut der NPC exakt in die Blickrichtung des Spielers (Maus/Kamera)
    local camRot = GetGameplayCamRot(0)
    -- +360 % 360 normalisiert negative Kamera-Werte auf 0-360 Bereich
    local heading = (camRot.z + 360.0) % 360.0
    SendNUIMessage({
        action = 'setHeading',
        heading = heading
    })
    cb('ok')
end)

-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │  🧭  INGAME HEADING-PLATZIERUNG                                            │
-- │  Dashboard blendet aus, Spieler schaut frei mit der Maus,                   │
-- │  ENTER bestätigt Blickrichtung, BACKSPACE bricht ab.                        │
-- └──────────────────────────────────────────────────────────────────────────────┘

-- NUI Callback: Heading-Platzierung starten
RegisterNUICallback('startHeadingPlacement', function(data, cb)
    headingPlacementActive = true
    isUIOpen = false
    SendNUIMessage({ action = 'hideForPlacement' })
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Heading-Platzierungs-Thread
Citizen.CreateThread(function()
    while true do
        if headingPlacementActive then
            Citizen.Wait(0)

            -- Aktuelle Kamera-Richtung als Heading
            local camRot = GetGameplayCamRot(0)
            local liveHeading = (camRot.z + 360.0) % 360.0

            -- Kompass-Richtung
            local compass = "N"
            if liveHeading >= 22.5 and liveHeading < 67.5 then compass = "NW"
            elseif liveHeading >= 67.5 and liveHeading < 112.5 then compass = "W"
            elseif liveHeading >= 112.5 and liveHeading < 157.5 then compass = "SW"
            elseif liveHeading >= 157.5 and liveHeading < 202.5 then compass = "S"
            elseif liveHeading >= 202.5 and liveHeading < 247.5 then compass = "SO"
            elseif liveHeading >= 247.5 and liveHeading < 292.5 then compass = "O"
            elseif liveHeading >= 292.5 and liveHeading < 337.5 then compass = "NO"
            end

            -- Richtungslinie zeichnen (goldene Linie in Blickrichtung)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local rad = math.rad(liveHeading)
            local dirX = -math.sin(rad) * 4.0
            local dirY = math.cos(rad) * 4.0
            DrawLine(
                playerCoords.x, playerCoords.y, playerCoords.z + 0.3,
                playerCoords.x + dirX, playerCoords.y + dirY, playerCoords.z + 0.3,
                255, 223, 0, 200
            )

            -- Endpunkt-Marker (flacher goldener Ring am Boden)
            DrawMarker(1,
                playerCoords.x + dirX, playerCoords.y + dirY, playerCoords.z - 0.98,
                0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                0.5, 0.5, 0.1,
                255, 223, 0, 120,
                false, true, 2, false, nil, nil, false
            )

            -- Heading-Anzeige + Anleitung
            drawTextCentered(string.format("~y~%s  %.1f°", compass, liveHeading), 0.55, "chalet", "gold", 0.82)
            drawTextCentered("Schaue in die gewünschte NPC-Richtung", 0.40, "chalet", "weiss", 0.87)
            drawTextCentered("~g~ENTER~s~ = Bestätigen    ~r~BACKSPACE~s~ = Abbrechen", 0.35, "chalet", "weiss", 0.92)

            -- Tasten abfangen
            DisableControlAction(0, 191, true)
            DisableControlAction(0, 177, true)

            -- ENTER = Heading bestätigen
            if IsDisabledControlJustReleased(0, 191) then
                headingPlacementActive = false
                PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                SendNUIMessage({ action = 'setHeading', heading = liveHeading })
                SendNUIMessage({ action = 'showAfterPlacement' })
                SetNuiFocus(true, true)
                isUIOpen = true
            end

            -- BACKSPACE = Abbrechen
            if IsDisabledControlJustReleased(0, 177) then
                headingPlacementActive = false
                PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                SendNUIMessage({ action = 'showAfterPlacement' })
                SetNuiFocus(true, true)
                isUIOpen = true
            end
        else
            Citizen.Wait(500)
        end
    end
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
        -- Intelligentes Patrol-System
        if cfg.enablePatrol and cfg.patrolRadius > 0 then
            Citizen.CreateThread(function()
                local patrolSpeed = (Config and Config.PatrolSpeed) or 1.0
                local idleChance = (Config and Config.PatrolIdleChance) or 70
                local idleTimeMin = (Config and Config.PatrolIdleTimeMin) or 3000
                local idleTimeMax = (Config and Config.PatrolIdleTimeMax) or 10000
                local stuckInterval = (Config and Config.PatrolStuckCheckInterval) or 1500
                local stuckThreshold = (Config and Config.PatrolStuckThreshold) or 0.3
                local maxRetries = (Config and Config.PatrolStuckMaxRetries) or 3
                local arrivalDist = (Config and Config.PatrolArrivalThreshold) or 2.0
                local maxHeightDiff = (Config and Config.PatrolMaxHeightDiff) or 3.0
                local idleScenarios = (Config and Config.PatrolIdleScenarios) or {
                    "WORLD_HUMAN_STAND_MOBILE",
                    "WORLD_HUMAN_SMOKING",
                    "WORLD_HUMAN_HANG_OUT_STREET",
                }

                local stuckCount = 0

                -- Kurze Startpause: NPC spielt zuerst sein Szenario
                if cfg.scenario then
                    Citizen.Wait(math.random(3000, 6000))
                end

                while DoesEntityExist(ped) do
                    -- 1) Sicheren Zielpunkt finden (Bodenhöhe geprüft)
                    local target = findSafePatrolPoint(cfg.position, cfg.patrolRadius, maxHeightDiff)

                    -- 2) NavMesh-Pathfinding (folgt dem Navigationsnetz, nicht durch Wände)
                    ClearPedTasks(ped)
                    TaskFollowNavMeshToCoord(ped, target.x, target.y, target.z, patrolSpeed, -1, 1.0, 0, 0.0)

                    -- 3) Bewegung überwachen mit Stuck-Erkennung
                    local arrived = false
                    local stuckChecks = 0
                    local lastPos = GetEntityCoords(ped)

                    while not arrived and DoesEntityExist(ped) do
                        Citizen.Wait(stuckInterval)

                        if not DoesEntityExist(ped) then break end

                        local currentPos = GetEntityCoords(ped)
                        local distToTarget = #(currentPos - vector3(target.x, target.y, target.z))
                        local moved = #(currentPos - lastPos)

                        -- Angekommen?
                        if distToTarget < arrivalDist then
                            arrived = true
                            stuckCount = 0
                        -- Stuck-Erkennung: NPC hat sich kaum bewegt
                        elseif moved < stuckThreshold then
                            stuckChecks = stuckChecks + 1
                            if stuckChecks >= 2 then
                                -- NPC steckt fest → sofort abbrechen
                                stuckCount = stuckCount + 1
                                ClearPedTasks(ped)
                                if stuckCount >= maxRetries then
                                    -- Hard Reset: Teleport zur Startposition
                                    SetEntityCoords(ped, cfg.position.x, cfg.position.y, cfg.position.z - 1.0, false, false, false, true)
                                    SetEntityHeading(ped, cfg.heading or 0.0)
                                    stuckCount = 0
                                    Citizen.Wait(1000)
                                end
                                break -- Neues Ziel wählen
                            end
                        else
                            stuckChecks = 0 -- Bewegt sich → Stuck-Zähler zurücksetzen
                        end

                        lastPos = currentPos
                    end

                    -- 4) Natürliches Idle-Verhalten am Zielpunkt
                    if arrived and DoesEntityExist(ped) then
                        ClearPedTasks(ped)

                        -- Zufällige Idle-Animation (Handy, Rauchen, Stehen, etc.)
                        if math.random(100) <= idleChance and #idleScenarios > 0 then
                            local scenario = idleScenarios[math.random(#idleScenarios)]
                            TaskStartScenarioInPlace(ped, scenario, 0, true)
                            local waitTime = math.random(idleTimeMin, idleTimeMax)
                            Citizen.Wait(waitTime)
                            ClearPedTasks(ped)
                        else
                            -- Nur kurz stehen bleiben und umschauen
                            local lookHeading = math.random(0, 360) + 0.0
                            SetEntityHeading(ped, lookHeading)
                            Citizen.Wait(math.random(1500, 4000))
                        end
                    else
                        -- War stuck → kurze Pause vor erneutem Versuch
                        Citizen.Wait(500)
                    end
                end
            end)
        end
        ::continue::
    end
end)

-- Finde einen sicheren, begehbaren Punkt innerhalb des Patrol-Radius
-- Prüft Bodenhöhe und Höhendifferenz zur Startposition
function findSafePatrolPoint(center, radius, maxHeightDiff)
    maxHeightDiff = maxHeightDiff or 3.0
    for attempt = 1, 6 do
        -- Zufälliger Punkt (15-90% des Radius: nicht zu nah am Zentrum, nicht am Rand)
        local angle = math.random() * 2 * math.pi
        local dist = radius * 0.15 + math.random() * radius * 0.75
        local x = center.x + math.cos(angle) * dist
        local y = center.y + math.sin(angle) * dist

        -- Bodenhöhe ermitteln
        local found, groundZ = GetGroundZFor_3dCoord(x, y, center.z + 50.0, false)
        if found and groundZ > 0 then
            -- Höhendifferenz prüfen (kein Abgrund/Dach)
            if math.abs(groundZ - center.z) < maxHeightDiff then
                return vector3(x, y, groundZ)
            end
        end
    end
    -- Fallback: leicht versetzte Position nahe Zentrum
    local angle = math.random() * 2 * math.pi
    return vector3(center.x + math.cos(angle) * 2.0, center.y + math.sin(angle) * 2.0, center.z)
end

AddEventHandler("onClientResourceStart", function(res)
    if res == GetCurrentResourceName() then
        TriggerServerEvent("safenpc:requestSync")
    end
end)

Citizen.CreateThread(function()
    while true do
        -- Wenn UI offen oder Heading-Platzierung aktiv, längere Wartezeit
        if isUIOpen or headingPlacementActive then
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