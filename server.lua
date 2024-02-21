local QBCore = exports['qb-core']:GetCoreObject()
local attachedCarts = {}

RegisterServerEvent('kg-taser:server:SendCart', function(id)
	TriggerClientEvent('kg-taser:client:GetTased', id)
	attachedCarts[id] = true
end)

RegisterServerEvent('kg-taser:server:RemoveBarbs', function(id)
	local src = source
	if attachedCarts[id] ~= nil then
		TriggerClientEvent('kg-taser:client:RemoveBarbs', id, false)
		TriggerClientEvent('kg-taser:client:RemoveBarbs', src, true)
		attachedCarts[id] = nil
	end
end)