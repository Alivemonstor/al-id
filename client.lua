local QBCore = exports['qb-core']:GetCoreObject()
local idOn = false
local animDict = 'amb@world_human_tourist_map@male@base'
local anim = 'base'
local model = 'prop_fib_clipboard'
local prop = nil
local holdingclip = false
local playerOptin = {}
local CID = {}

-- Functions


function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

function loadModel(model)
    while (not HasModelLoaded(model)) do
        RequestModel(model)
        Wait(5)
    end
end


local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        -- Calculate text scale to use
        local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
        local scale = 1 * (1 / dist) * (1 / GetGameplayCamFov()) * 100

        -- Draw text on screen
        SetTextScale(scale, scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropShadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextEdge(4, 0, 0, 0, 255)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function GetPlayers()
    local players = {}
    local activePlayers = GetActivePlayers()
    for i = 1, #activePlayers do
        local player = activePlayers[i]
        local ped = GetPlayerPed(player)
        if DoesEntityExist(ped) then
            players[#players+1] = player
        end
    end
    return players
end

local function GetPlayersFromCoords(coords, distance)
    local players = GetPlayers()
    local closePlayers = {}

	coords = coords or GetEntityCoords(PlayerPedId())
    distance = distance or  5.0

    for i = 1, #players do
        local player = players[i]
		local target = GetPlayerPed(player)
		local targetCoords = GetEntityCoords(target)
		local targetdistance = #(targetCoords - vector3(coords.x, coords.y, coords.z))
		if targetdistance <= distance then
            closePlayers[#closePlayers+1] = player
		end
    end

    return closePlayers
end



RegisterCommand('ids', function()
    if not idOn then
        idOn = true
        Wait(2000)
        idOn = false
        holdingclip = false
        DeleteObject(prop)
        prop = nil
        ClearPedTasks(PlayerPedId())
    end
end, false)

RegisterKeyMapping('ids', 'Show Id\'s', 'keyboard', Config.OpenKey)


CreateThread(function()
    while true do
        local loop = 100
        if idOn then
            PickUp()
            for _, player in pairs(GetPlayersFromCoords(GetEntityCoords(PlayerPedId()), 10.0)) do
                local playerId = GetPlayerServerId(player)
                local playerPed = GetPlayerPed(player)
                local playerCoords = GetEntityCoords(playerPed)
                loop = 1
                if CID[playerId] == nil then
                    while CID[playerId] == nil do
                        Wait(10)
                        GetId(playerId)
                    end
                end
                DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z + 1.0, '['..CID[playerId]..']')
            end

        end
        Wait(loop)
    end
end)


function PickUp()
    holdingclip = true
    loadModel(model)
    loadAnimDict(animDict)
    if prop == nil then
        prop = CreateObject(model, GetEntityCoords(PlayerPedId()), true)
    end
    CreateThread(function()
        while holdingclip do
            if not IsEntityPlayingAnim(PlayerPedId(), animDict, anim, 3) then
                TaskPlayAnim(PlayerPedId(), animDict, anim, 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
            if not IsEntityAttachedToEntity(prop, PlayerPedId()) then  AttachEntityToEntity(prop, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 0x6F06), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, false, 0, true) end
            Wait(100)
        end
    end)
end

function GetId(id)
    lib.callback('showid:CID', false, function(Id)
        if CID[id] == nil then
            CID[id] = Id
        end
    end,id)
end
