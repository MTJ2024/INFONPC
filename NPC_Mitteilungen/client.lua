local myNPCs = {}
local isInteracting = false

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
        -- Nicht-Patrouille-NPCs einfrieren, damit sie nicht weglaufen
        if not cfg.enablePatrol then
            FreezeEntityPosition(ped, true)
            SetPedKeepTask(ped, true)
        end
        myNPCs[idx] = ped
        -- Patrouille mit Radius-Begrenzung
        if cfg.enablePatrol and cfg.patrolRadius > 0 then
            Citizen.CreateThread(function()
                while DoesEntityExist(ped) do
                    local pedCoords = GetEntityCoords(ped)
                    local distFromCenter = #(pedCoords - cfg.position)

                    -- NPC ist außerhalb des Radius -> sofort zurück zum Zentrum
                    if distFromCenter > cfg.patrolRadius then
                        ClearPedTasks(ped)
                        TaskGoToCoordAnyMeans(ped, cfg.position.x, cfg.position.y, cfg.position.z, 1.0, 0, 0, 786603, 0)
                        local returnSteps = 0
                        while DoesEntityExist(ped) do
                            Citizen.Wait(500)
                            returnSteps = returnSteps + 1
                            pedCoords = GetEntityCoords(ped)
                            distFromCenter = #(pedCoords - cfg.position)
                            if distFromCenter <= cfg.patrolRadius * 0.5 then
                                break
                            end
                            -- Sicherheit: Wenn NPC zu lange draußen ist, teleportieren
                            if returnSteps > 30 then
                                SetEntityCoords(ped, cfg.position.x, cfg.position.y, cfg.position.z - 1.0, false, false, false, true)
                                break
                            end
                        end
                    end

                    -- Ziel innerhalb 70% des Radius wählen um Überlaufen zu vermeiden
                    local target = getRandomPointInRadius(cfg.position, cfg.patrolRadius * 0.7)
                    TaskGoToCoordAnyMeans(ped, target.x, target.y, target.z, 1.0, 0, 0, 786603, 0)
                    local steps, arrived = 0, false
                    while not arrived and DoesEntityExist(ped) do
                        Citizen.Wait(500)
                        steps = steps + 1
                        pedCoords = GetEntityCoords(ped)
                        local distance = #(pedCoords - target)
                        distFromCenter = #(pedCoords - cfg.position)

                        if distance < 1.5 then
                            arrived = true
                        elseif distFromCenter > cfg.patrolRadius then
                            -- NPC hat Radius verlassen, sofort abbrechen
                            ClearPedTasks(ped)
                            break
                        elseif steps > 40 then
                            ClearPedTasks(ped)
                            break
                        end
                    end
                    if DoesEntityExist(ped) and cfg.scenario then
                        pedCoords = GetEntityCoords(ped)
                        distFromCenter = #(pedCoords - cfg.position)
                        if distFromCenter <= cfg.patrolRadius then
                            TaskStartScenarioInPlace(ped, cfg.scenario, 0, true)
                            Citizen.Wait(math.random(3000, 6000))
                        end
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
    displayMessagesAbovePlayer(cfg.messages, function() isInteracting = false end, cfg.textScale, cfg.textFont, cfg.textColor)
end)

function drawTextAbovePlayer(entity, text, scale, fontName, colorName)
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

function displayMessagesAbovePlayer(messages, callback, textScale, textFont, textColor)
    Citizen.CreateThread(function()
        local scale = textScale or 0.968
        local font = textFont or "pricedown"
        local color = textColor or "gold"
        for _, message in ipairs(messages) do
            local startTime = GetGameTimer()
            local duration = 3000
            while GetGameTimer() - startTime < duration do
                Citizen.Wait(0)
                drawTextAbovePlayer(PlayerPedId(), message, scale, font, color)
            end
        end
        if callback then callback() end
    end)
end