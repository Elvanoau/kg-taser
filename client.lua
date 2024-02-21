local QBCore = exports['qb-core']:GetCoreObject()
local HasBarbs = false
local TasedPerson = nil
local retazeAmount = 0

RegisterNetEvent('kg-taser:client:GetTased', function()
	local ped = PlayerPedId()
	SetPedToRagdoll(ped, 5000, 5000, 0, true, true, false)
end)

RegisterNetEvent('kg-taser:client:RemoveBarbs', function(isSender)
	if isSender == true then
		TasedPerson = nil
		HasBarbs = false
		QBCore.Functions.Notify('The Taser Barbs Ripped Out Of The Suspect!', 'error')
	else
		QBCore.Functions.Notify('Ouch! The Taser Barbs Ripped Out', 'error')
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 2000
	    local hasWeapon, weapon = GetCurrentPedWeapon(PlayerPedId())
		if hasWeapon == 1 and weapon == 911657153 then
			sleep = 1
			if IsPedShooting(PlayerPedId()) then
				local isAim, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
				if DoesEntityExist(entity) then
					if IsEntityAPed(entity) then
						if not IsPedInAnyVehicle(entity) then
							if not IsPedAPlayer(entity) then
								local netId = NetworkGetNetworkIdFromEntity(entity)
							else
								local id = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
								TriggerServerEvent('kg-taser:server:SendCart', id)
								TasedPerson = id
								HasBarbs = true
							end
						end
					end
				end
			end
		end
		Wait(sleep)
	end
end)

Citizen.CreateThread(function()
	while true do
		local sleep = 1000
		if HasBarbs then
			sleep = 5
			local pCoords = GetEntityCoords(PlayerPedId())
			local sPlayer = GetPlayerFromServerId(TasedPerson)
			local sPlayerPed = GetPlayerPed(sPlayer)
			local rCoords = GetEntityCoords(sPlayerPed)
			local check1 = rCoords.x - pCoords.x
			local check2 = rCoords.y - pCoords.y
			if check1 >= Config.RemoveRange or check2 >= Config.RemoveRange or check1 <= Config.RemoveRange2 or check2 <= Config.RemoveRange2 then
				TriggerServerEvent('kg-taser:server:RemoveBarbs', TasedPerson)
				TasedPerson = nil
				HasBarbs = false
                retazeAmount = 0
			end
		end
		Wait(sleep)
	end
end)

RegisterCommand(Config.ReTazeCommand, function(source)
    if HasBarbs then
        if TasedPerson ~= nil and retazeAmount < 3 then
            TriggerServerEvent('kg-taser:server:SendCart', TasedPerson)
            retazeAmount = retazeAmount + 1
        end
    end
end)

RegisterKeyMapping(Config.ReTazeCommand, "Retaze Key", "keyboard", Config.RetazeKey)