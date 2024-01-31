local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('kg-tazer:Log', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local color = Config.WebhookColour
    local name = "Tazer Webhook"
    local message = Player.PlayerData.citizenid .. " Discharged There Taser"

    local embed = {
        {
            ["color"] = color,
            ["title"] = "**".. name .."**",
            ["description"] = message,
        }
    }
    
    PerformHttpRequest(Config.TazerWebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end)

RegisterServerEvent('kg-tazer:server:bounce', function(playerId)
    TriggerClientEvent('kg-tazer:client:getTazed', playerId)
end)