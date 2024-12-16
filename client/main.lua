local powerState = true

local fusesToRepair = 0
local fusePositions = {}
local possibleFusePositions = POSSIBLE_FUSE_POS
local minRepairTime = MIN_REPAIR_TIME
local maxRepairTime = MAX_REPAIR_TIME

-- Event zum Aktualisieren des Stromzustands
RegisterNetEvent("power:updateState")
AddEventHandler("power:updateState", function(state)
    powerState = state
    if not powerState then
        TriggerEvent("power:applyBlackout")
    else
        TriggerEvent("power:restorePower")
    end
end)

function GenerateFusePositions(count)
    -- Zufällige Auswahl von Positionen
    local selectedPositions = {}
    local selectedIndices = {}

    for i = 1, count do
        local index
        repeat
            index = math.random(1, #possibleFusePositions)
        until not selectedIndices[index] -- Stelle sicher, dass Position nicht doppelt ausgewählt wird

        table.insert(selectedPositions, possibleFusePositions[index])
        selectedIndices[index] = true -- Markiere die Position als ausgewählt
    end

    return selectedPositions
end

-- Blackout starten und Sicherungen generieren
RegisterNetEvent("power:startBlackout")
AddEventHandler("power:startBlackout", function(requiredRepairs)
    powerState = false
    fusesToRepair = requiredRepairs
    fusePositions = GenerateFusePositions(fusesToRepair) -- Generiere Positionen der Sicherungen
    TriggerEvent("power:applyBlackout")
    --print("[DEBUG] Blackout gestartet. " .. fusesToRepair .. " Sicherungen müssen repariert werden.")
end)

-- Blackout beenden
RegisterNetEvent("power:endBlackout")
AddEventHandler("power:endBlackout", function()
    powerState = true
    TriggerEvent("power:restorePower")
    --print("[DEBUG] Strom wiederhergestellt.")
end)

RegisterNetEvent("power:applyBlackout")
AddEventHandler("power:applyBlackout", function()
    if powerState == false then
        SetArtificialLightsState(true) -- Schalte Lichter aus
        SetArtificialLightsStateAffectsVehicles(false)
        TriggerServerEvent("qb-weathersync:server:toggleBlackout", true)
        PlaySoundFrontend(-1, "Power_Down", "DLC_HEIST_HACKING_SNAKE_SOUNDS", 1)
        TriggerEvent("chat:addMessage", { args = { "[Strom]", "Der Strom ist ausgefallen!" } })
    end
end)

RegisterNetEvent("power:restorePower")
AddEventHandler("power:restorePower", function()
    if powerState == true then
        SetArtificialLightsState(false) -- Schalte Lichter ein
        TriggerServerEvent("qb-weathersync:server:toggleBlackout", false)
        PlaySoundFrontend(-1, "police_notification", "DLC_AS_VNT_Sounds", 1)
        TriggerEvent("chat:addMessage", { args = { "[Strom]", "Der Strom wurde wiederhergestellt!" } })
    end
end)

-- Interaktionspunkt für die Sicherung
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not powerState and fusesToRepair > 0 then
            for i, pos in ipairs(fusePositions) do
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = #(playerCoords - pos)

                if distance < 3.0 then
                    DrawMarker(1, pos.x, pos.y, pos.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                    if IsControlJustReleased(0, 38) then -- "E" drücken
                        local repairTime = math.random(minRepairTime, maxRepairTime) -- Reparaturzeit
                        StartFuseRepair(i, repairTime)

                        local startTime = GetGameTimer()
                        while GetGameTimer() - startTime < repairTime do
                            Citizen.Wait(0)
                            local progress = math.floor(((GetGameTimer() - startTime) / repairTime) * 100)
                            DrawText3D(pos.x, pos.y, pos.z + 1.0, "Warte auf Ok vom System... " .. progress .. "%")
                        end

                        StopRepairAnimation()
                    end
                end
            end
        end
    end
end)

function StartFuseRepair(index, repairTime)
    local playerPed = PlayerPedId()
    local pos = fusePositions[index]
    fusesToRepair = fusesToRepair - 1

    --print("[DEBUG] Reparatur gestartet für Sicherung " .. index .. ". Dauer: " .. repairTime / 1000 .. " Sekunden.")
    
    PlayRepairAnimation()

    -- Reparatur starten
    local startTime = GetGameTimer()
    while GetGameTimer() - startTime < repairTime do
        Citizen.Wait(0)

        -- Fortschrittsanzeige
        local progress = math.floor(((GetGameTimer() - startTime) / repairTime) * 100)
        DrawText3D(pos.x, pos.y, pos.z + 1.0, "Reparatur: Setze Sicherung ein... " .. progress .. "%")
    end

    --print("[DEBUG] Sicherung " .. index .. " repariert.")
    TriggerServerEvent("power:repairFuse")
    table.remove(fusePositions, index) -- Entferne reparierte Sicherung
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function PlayRepairAnimation()
    local playerPed = PlayerPedId()
    local animDict = "mini@repair" -- Animationsbibliothek
    local animName = "fixing_a_ped" -- Animationsname

    -- Lade die Animation
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end

    -- Animation abspielen
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 1, 0, false, false, false)
end

function StopRepairAnimation()
    local playerPed = PlayerPedId()
    ClearPedTasks(playerPed)
end