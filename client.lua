local QBCore = exports['qb-core']:GetCoreObject()
local tazeEnt = nil
local tazeAmount = 0

local function PullBarbCheck(last, current)
    if last.x + 3 <= current.x then
        if last.y + 3 <= current.y then
            return true
        end
    elseif last.x - 3 >= current.x then
        if last.y - 3 >= current.y then
            return true
        end
    end

    return false
end

local function ReTaze()
    if tazeEnt ~= nil then
        local closestPlayer, distance = QBCore.Functions.GetClosestPlayer()
        local ped = PlayerPedId()
        if distance ~= -1 and distance > 1 then
            TriggerServerEvent("kg-tazer:server:bounce", GetPlayerServerId(closestPlayer))
        end
        --SetPedToRagdoll(ped, 3000, 5000, 0, 0, 0, 0)
    elseif tazeAmount >= 3 then
        QBCore.Functions.Notify('Tazer Out Of Charges', 'error')
    end
end

Citizen.CreateThread(function()
    while true do
        local sleep = 2000

        if tazeEnt ~= nil then
            sleep = 100
            local hasWeapon, weapon = GetCurrentPedWeapon(PlayerPedId())
            if IsEntityDead(NetworkGetEntityFromNetworkId(tazeEnt)) then
                tazeEnt = nil
                tazeAmount = 0
            elseif weapon ~= 911657153 then
                tazeEnt = nil
                tazeAmount = 0
            end
        end

        Wait(sleep)
    end
end)

RegisterCommand(Config.ReTazeCommand, function(source)
    ReTaze()
end)

RegisterKeyMapping(Config.ReTazeCommand, "Retaze Key", "keyboard", Config.RetazeKey)

RegisterCommand("shoot_taze", function(source)
    local hasWeapon, weapon = GetCurrentPedWeapon(PlayerPedId())
    if hasWeapon == 1 and weapon == 911657153 then
        local found, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if found ~= false and entity ~= 0 then
            if IsEntityAPed(entity) ~= false then
                tazeEnt = NetworkGetNetworkIdFromEntity(entity)
                if Config.UseWebhook == true then
                    TriggerServerEvent('kg-tazer:Log')
                end
            end
        end
    end
end)

RegisterKeyMapping("shoot_taze", "Taze Send", "MOUSE_BUTTON", "MOUSE_LEFT")

RegisterNetEvent('kg-tazer:client:getTazed', function()
    SetPedToRagdoll(PlayerPedId(), 5000, 7500, 0, false, false, false)
    TimerEnabled = true
    Wait(1500)
    TimerEnabled = false
end)