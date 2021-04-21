-- laot baba 46 16
-- kod çalmaya geldiysen hoşgeldin kardeşim al hepsi senin olsun

ESX = nil
LAOT = nil

TriggerEvent('LAOTCore:GetObject', function(obj) LAOT = obj end)
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

LAOTGPS = {}
LAOTGPS.ServerBlips = {}

ESX.RegisterUsableItem('laot_gps', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob()
    local scriptadi = GetCurrentResourceName()
    local used = false

    if scriptadi == 'laot-gps' then
        TriggerClientEvent("laot-gps:client:UseGPS", source)
    else TriggerClientEvent("LAOTCore:Client:Notify", source, "error", "Scriptin adını (laot-gps) olarak ayarlayınız.") end
end)

RegisterNetEvent("laot-gps:server:RequestSync")
AddEventHandler("laot-gps:server:RequestSync", function()
    TriggerClientEvent("laot-gps:client:RequestSync", -1, LAOTGPS.ServerBlips)
end)

Citizen.CreateThread(function()
    print('^1laot-gps ^0 - Baslatildi!')
end)

RegisterNetEvent("laot-gps:server:AddGPS")
AddEventHandler("laot-gps:server:AddGPS", function(firstname, lastname, code, jobname)
    local src = source

    table.insert(LAOTGPS.ServerBlips, { id = src, firstname = firstname, lastname = lastname, code = code, jobname = jobname })
    TriggerEvent("laot-gps:server:RequestSync")
end)

RegisterNetEvent("laot-gps:server:DeleteMyBlip")
AddEventHandler("laot-gps:server:DeleteMyBlip", function()
    local src = source

    for blipID, blipdata in pairs(LAOTGPS.ServerBlips) do
        if blipdata.id == src then
            table.remove(LAOTGPS.ServerBlips, blipID)
        end
    end

    TriggerEvent("laot-gps:server:RequestSync")
end)

RegisterNetEvent("laot-gps:server:DropBlip")
AddEventHandler("laot-gps:server:DropBlip", function(source)
    local src = source

    for blipID, blipdata in pairs(LAOTGPS.ServerBlips) do
        if blipdata.id == src then
            table.remove(LAOTGPS.ServerBlips, blipID)
        end
    end

    TriggerEvent("laot-gps:server:RequestSync")
end)

ESX.RegisterServerCallback("laot-gps:callback:CheckItem", function(source, cb, item)
    local src = source
    local Player = ESX.GetPlayerFromId(src)
    local amount = Player.getInventoryItem(item).count

    cb(amount)
end)

ESX.RegisterServerCallback("laot-gps:callback:GetCharacterName", function(source, cb)
    local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

    if xPlayer ~= nil then
        
		MySQL.Async.fetchAll('SELECT * FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier,
        }, function(mysqlresult)
            
			if mysqlresult[1] ~= nil then
				cb(mysqlresult[1].firstname, mysqlresult[1].lastname)
			else
				cb(nil)
            end
            
        end)
        
	end
end)

AddEventHandler('playerDropped', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)

	if src ~= nil then
		Citizen.Wait(5000)
		TriggerEvent('laot-gps:server:DropBlip', src)
	end
end)
