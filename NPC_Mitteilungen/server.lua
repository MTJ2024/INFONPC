ESX = exports["es_extended"]:getSharedObject()

local spawnedBoats = {}
local lastSpawnTimestamps = {}
local playerBoatCounts = {}

local function isPlayerAllowed(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false, "no_esx" end

    -- Gruppenprüfung
    local allowed = false
    for _, group in ipairs(Config.AllowedGroups) do
        if xPlayer.getGroup() == group then
            allowed = true
            break
        end
    end
    if not allowed then return false, "group" end

    -- Cooldown
    local now = os.time()
    if lastSpawnTimestamps[source] and now - lastSpawnTimestamps[source] < Config.SpawnCooldown then
        return false, "cooldown"
    end

    -- Max Boats per Player
    playerBoatCounts[source] = playerBoatCounts[source] or 0
    if playerBoatCounts[source] >= Config.MaxBoatsPerPlayer then
        return false, "maxboats"
    end

    return true, ""
end

-- Boot anfordern (Callback! KEIN Event!)
ESX.RegisterServerCallback("mtj_boats:requestSpawnBoat", function(source, cb, point)
    local allowed, reason = isPlayerAllowed(source)
    if not allowed then
        cb(false, "Du darfst aktuell kein Boot spawnen. Grund: "..reason)
        return
    end

    -- Boot am selben Punkt prüfen
    for _, boat in ipairs(spawnedBoats) do
        if boat.point and point and boat.point.x == point.x and boat.point.y == point.y and boat.point.z == point.z then
            cb(false, "An diesem Punkt existiert bereits ein Boot!")
            return
        end
    end

    -- Boot registrieren
    table.insert(spawnedBoats, {point = point, owner = source, time = os.time()})
    lastSpawnTimestamps[source] = os.time()
    playerBoatCounts[source] = (playerBoatCounts[source] or 0) + 1

    cb(true, "Boot erfolgreich gespawnt!")
end)

-- Boot entfernen (Callback! KEIN Event!)
ESX.RegisterServerCallback("mtj_boats:deleteBoat", function(source, cb, point)
    local xPlayer = ESX.GetPlayerFromId(source)
    local isAdmin = false
    for _, group in ipairs(Config.AllowedGroups) do
        if xPlayer and xPlayer.getGroup() == group then isAdmin = true break end
    end
    for i = #spawnedBoats, 1, -1 do
        local boat = spawnedBoats[i]
        if boat.point and point and boat.point.x == point.x and boat.point.y == point.y and boat.point.z == point.z then
            if boat.owner == source or isAdmin then
                table.remove(spawnedBoats, i)
                playerBoatCounts[boat.owner] = math.max((playerBoatCounts[boat.owner] or 1) - 1, 0)
                cb(true, "Boot entfernt!")
                return
            else
                cb(false, "Keine Berechtigung, dieses Boot zu löschen!")
                return
            end
        end
    end
    cb(false, "Kein Boot an diesem Punkt gefunden!")
end)

-- SERVER-SEITIG: Bootsliste für Clients bereitstellen (Callback! KEIN Event!)
ESX.RegisterServerCallback("mtj_boats:getSpawnedBoats", function(source, cb)
    cb(spawnedBoats)
end)

-- Aufräumen beim Disconnect
AddEventHandler("playerDropped", function(reason)
    local src = source
    for i = #spawnedBoats, 1, -1 do
        if spawnedBoats[i].owner == src then
            table.remove(spawnedBoats, i)
        end
    end
    playerBoatCounts[src] = nil
    lastSpawnTimestamps[src] = nil
end)