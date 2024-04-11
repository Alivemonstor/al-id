local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('showid:CID', function(source, id)
    local Player = QBCore.Functions.GetPlayer(id)
    return Player.PlayerData.citizenid
end)