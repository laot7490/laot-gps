--[[

	██╗░░░░░░█████╗░░█████╗░████████╗░░░██╗░██╗░██████╗░███████╗░█████╗░░█████╗░
	██║░░░░░██╔══██╗██╔══██╗╚══██╔══╝██████████╗╚════██╗██╔════╝██╔══██╗██╔══██╗
	██║░░░░░███████║██║░░██║░░░██║░░░╚═██╔═██╔═╝░░███╔═╝██████╗░╚██████║╚██████║
	██║░░░░░██╔══██║██║░░██║░░░██║░░░██████████╗██╔══╝░░╚════██╗░╚═══██║░╚═══██║
	███████╗██║░░██║╚█████╔╝░░░██║░░░╚██╔═██╔══╝███████╗██████╔╝░█████╔╝░█████╔╝
	╚══════╝╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░░╚═╝░╚═╝░░░╚══════╝╚═════╝░░╚════╝░░╚════╝░

	Kod çalmaya geldiysen hoşgeldin yar : ) - laot
	
]]

local Keys = {["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57, ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177, ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70, ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118}

ESX = nil
PlayerData = nil

LAOT = nil

LAOTGPS = {}
LAOTGPS.Using = false
LAOTGPS.Blips = {}
LAOTGPS.RealBlips = {}

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
	while LAOT == nil do
		TriggerEvent('LAOTCore:getSharedObject', function(obj) LAOT = obj end)
		Citizen.Wait(0)
	end

	WarMenu.CreateMenu("laot-gps", "GPS UYGULAMASI", "Lütfen işlem seçiniz.", 0, 0, 200)
	WarMenu.SetMenuX('laot-gps', 0.77)
	WarMenu.SetMenuY('laot-gps', 0.025)
	WarMenu.SetMenuWidth('laot-gps', 0.22)
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('laot-gps:client:UseGPS')
AddEventHandler('laot-gps:client:UseGPS', function()
	while ESX == nil do
		Citizen.Wait(10)
	end

	while ESX.GetPlayerData().job.name == nil do
		Citizen.Wait(10)
	end

	local playerjobname = ESX.GetPlayerData().job.name
	
	for jobname, jobdata in pairs(C.Jobs) do

		if playerjobname == jobname then
			UseGPS()
			return
		end

	end

	LAOT.Notification("error", _U("LAOT_GPS_YOUDONTKNOW"))
end)

UseGPS = function()

	WarMenu.OpenMenu("laot-gps")
	while WarMenu.IsMenuOpened("laot-gps") do

		WarMenu.Display()
		if not LAOTGPS.Using then
			if WarMenu.Button(_U("LAOT_GPS_OPENGPS")) then
				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'laotgpson',
				{
					title = ('Kodunuzu yazın.')
				},
				function(data, menu)
					local code = data.value
					if code then
						LAOTGPS.Using = true
						EnableGPS(code)
					end
					menu.close()
				end,
				function(data, menu)
					menu.close()
				end)
			end
		else
			if WarMenu.Button(_U("LAOT_GPS_DISABLEGPS")) then
				LAOTGPS.Using = false
				DisableGPS()
			end
		end

		Citizen.Wait(2)
	end
end

EnableGPS = function(code)
	ESX.TriggerServerCallback("laot-gps:callback:GetCharacterName", function(firstname, lastname) 
		if firstname and lastname then
			TriggerServerEvent("laot-gps:server:AddGPS", firstname, lastname, code, ESX.GetPlayerData().job.name)
		end
	end)
end

Citizen.CreateThread(
	function()
		
		while ESX == nil do
			Citizen.Wait(10)
		end
	
		while PlayerData == nil do
			Citizen.Wait(10)
		end

		while LAOT == nil do
			Citizen.Wait(10)
		end

		while true do

			local playerjobname = PlayerData.job.name

			for jobname, jobdata in pairs(C.Jobs) do

				if playerjobname == jobname then
					ESX.TriggerServerCallback('laot-gps:callback:CheckItem', function(amount)
						if amount > 0 then
							RefreshBlips()
						else
							DisableGPS()
						end
					end, "laot_gps")
				end

			end

			Citizen.Wait(5000)
		end

end)

RefreshBlips = function()
	if LAOTGPS.Blips and LAOTGPS.Using then

		for existingblipid, existingblip in pairs(LAOTGPS.RealBlips) do
			RemoveBlip(existingblip)
		end
		Citizen.Wait(10)

		for blipid, data in pairs(LAOTGPS.Blips) do
			if C.Jobs[data.jobname] then
				local color = C.Jobs[data.jobname]["color"]
				local player = GetPlayerFromServerId(data.id)

				if NetworkIsPlayerActive(player) and GetPlayerPed(player) ~= PlayerPedId() then
					CreateBlip(player, data.firstname, data.lastname, data.code, color)
				end
				
			end
		end

	end
end

DisableGPS = function()
	print("laot#2599 disabling gps.")

	for existingblipid, existingblip in pairs(LAOTGPS.RealBlips) do
		RemoveBlip(existingblip)
	end
	TriggerServerEvent("laot-gps:server:DeleteMyBlip")
	
	LAOTGPS.Using = false
end

CreateBlip = function(player, firstname, lastname, code, color)
	local ped = GetPlayerPed(player)
	local pblip = GetBlipFromEntity(ped)

	if not DoesBlipExist(pblip) then

		pblip = AddBlipForEntity(ped)
		if IsPedInAnyVehicle(ped, true) then
			SetBlipSprite(pblip, C.VehicleBlipSprite)
		else
			SetBlipSprite(pblip, C.BlipSprite)
		end
		SetBlipColour(pblip, color)
		SetBlipRotation(pblip, math.ceil(GetEntityHeading(ped)))
		SetBlipScale(pblip, C.BlipScale)
		SetBlipAsShortRange(pblip, true)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString("[".. code .."] ".. firstname .." ".. lastname .."")
		EndTextCommandSetBlipName(pblip)

		table.insert(LAOTGPS.RealBlips, pblip)

	end
end

RegisterNetEvent("laot-gps:client:RequestSync")
AddEventHandler("laot-gps:client:RequestSync", function(data)
	local playerjobname = ESX.GetPlayerData().job.name
	
	for jobname, jobdata in pairs(C.Jobs) do

		if playerjobname == jobname then
			LAOTGPS.Blips = data
			RefreshBlips()
		end

	end
end)

