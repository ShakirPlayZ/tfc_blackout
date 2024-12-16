local QBCore = exports['qb-core']:GetCoreObject()
local powerState = true
local requiredRepairs = 0 -- Anzahl der zu reparierenden Sicherungen

-- Event zum Umschalten des Stroms
RegisterNetEvent("power:toggle")
AddEventHandler("power:toggle", function(state)
    powerState = state
    TriggerClientEvent("power:updateState", -1, powerState) -- Synchronisiere mit allen Clients
end)

-- Sporadische Stromausfälle
-- Event zum Starten eines Stromausfalls
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(math.random(MIN_WAIT_TIMER, MAX_WAIT_TIMER)) -- Warte min. 1 Minute
        if powerState then
            powerState = false
            requiredRepairs = math.random(5, MAX_REPAIR_FUSES) -- Zufällige Anzahl an Sicherungen
            print("[DEBUG] Stromausfall ausgelöst. Es müssen " .. requiredRepairs .. " Sicherungen repariert werden.")
            TriggerClientEvent("power:startBlackout", -1, requiredRepairs)
        end
    end
end)

-- Event, wenn ein Spieler eine Sicherung repariert
RegisterNetEvent("power:repairFuse")
AddEventHandler("power:repairFuse", function()
    requiredRepairs = requiredRepairs - 1
    print("[DEBUG] Eine Sicherung wurde repariert. Verbleibend: " .. requiredRepairs)
    
    if requiredRepairs <= 0 then
        powerState = true
        print("[DEBUG] Alle Sicherungen repariert. Strom wird wieder eingeschaltet.")
        TriggerClientEvent("power:endBlackout", -1)
    end
end)

RegisterCommand('blackouton', function(source, args)
    powerState = false
    requiredRepairs = math.random(5, MAX_REPAIR_FUSES)
    TriggerClientEvent("power:startBlackout", -1, requiredRepairs)
end, false)

RegisterCommand('blackoutoff', function(source, args)
    powerState = true
    TriggerClientEvent("power:endBlackout", -1)
end, false)