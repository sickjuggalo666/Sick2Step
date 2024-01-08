local Core = nil
local Object = nil
local Inventory = exports.ox_inventory


if Config.ESX then
	Core = exports['es_extended']:getSharedObject()
	Object = 'ESX'
else
	Core = exports['qb-core']:GetCoreObject()
	Object = 'QBCore'
end

if not Config.UseOxInv then
	if Config.ESX then
		Core.RegisterUsableItem(Config.modules.module, function(playerId)
			TriggerClientEvent('Sick-2Step:GetPlateFromClient', playerId, false)
		end)

		Core.RegisterUsableItem(Config.modules.checker, function(playerId)
			local xPlayer = Core.GetPlayerFromId(playerId)
			if xPlayer.getJob().name == 'police' then
				TriggerClientEvent('Sick-2Step:GetPlateFromClient', playerId, true)
			end
		end)
	else
		Core.Functions.CreateUseableItem(Config.modules.module, function(source, item)
			local Player = Core.Functions.GetPlayer(source)
			if not Player.Functions.GetItemByName(item.name) then return end
			TriggerClientEvent('Sick-2Step:GetPlateFromClient', source, false)
		end)
		
		Core.Functions.CreateUseableItem(Config.modules.checker, function(source, item)
			local Player = Core.Functions.GetPlayer(source)
			if not Player.Functions.GetItemByName(item.name) then return end
			if Player.PlayerData.job.name == 'police' then
				TriggerClientEvent('Sick-2Step:GetPlateFromClient', source, true)
			end
		end)
	end
end

RegisterServerEvent("eff_flames")
AddEventHandler("eff_flames", function(entity)
	TriggerClientEvent("c_eff_flames", -1, entity)
end)

lib.addCommand('2step', {
    help = 'Set 2Step Modules as Active/Inactive',
    params = {},
}, function(source, args, raw)
	TriggerClientEvent("2step:Anti-lag", source)
end)

RegisterNetEvent('Sick-2Step:Set2StepVeh')
AddEventHandler('Sick-2Step:Set2StepVeh',function(plate)
	local src = source
	if Object == 'ESX' then
		MySQL.query('SELECT `twostep` FROM `owned_vehicles` WHERE `plate` = ?', {
			plate
		}, function(response)
			for i = 1, #response do
				local row = response[i]
				if row.twostep == 1 then
					TriggerClientEvent('Sick-2Step:UninstallClient', src, plate)
					SNotify(src, 3, 'Veh already Has 2Step!')
				else
					MySQL.update('UPDATE `owned_vehicles` SET `twostep` = ? WHERE `plate` = ?', {
						1, plate
					})
					SNotify(src, 1, 'Installed Successfully! { /2step } to use')
					Inventory:RemoveItem(src, '2step', 1)
					SNotify(1, '2 Step Was Added To Veh!')
				end
			end
		end)
	elseif Object == 'QBCore' then
		MySQL.query('SELECT `twostep` FROM `player_vehicles` WHERE `plate` = ?', {
			plate
		}, function(response)
			for i = 1, #response do
				local row = response[i]
				if row.twostep == 1 then
					TriggerClientEvent('Sick-2Step:UninstallClient', src, plate)
					SNotify(src, 3, 'Veh already Has 2Step!')
				else
					MySQL.update('UPDATE `player_vehicles` SET `twostep` = 1 WHERE `plate` = ?', {
						plate
					})
					SNotify(src, 1, 'Installed Successfully! { /2step } to use')
					Inventory:RemoveItem(src, '2step', 1)
					SNotify(1, '2 Step Was Added To Veh!')
				end
			end
		end)
	end
end)

RegisterNetEvent('Sick-2Step:Police2Step')
AddEventHandler('Sick-2Step:Police2Step',function(plate)
	local src = source
	if Object == 'ESX' then
		MySQL.query('SELECT `twostep` FROM `owned_vehicles` WHERE `plate` = ?', {
			plate
		}, function(response)
			for i = 1, #response do
				local row = response[i]
				if row.twostep == 1 then
					SNotify(src, 2, 'Vehicle Has 2Step Module Installed!')
					TriggerClientEvent('Sick-2Step:UninstallClient', src, plate)
				else
					Snotify(src, 2, 'Vehicle Doesn\'t Have a 2Step Module Installed!')
				end
			end
		end)
	elseif Object == 'QBCore' then
		MySQL.query('SELECT `twostep` FROM `player_vehicles` WHERE `plate` = ?', {
			plate
		}, function(response)
			for i = 1, #response do
				local row = response[i]
				if row.twostep == 1 then
					SNotify(src, 2, 'Vehicle Has 2Step Module Installed!')
					TriggerClientEvent('Sick-2Step:UninstallClient', src, plate)
				else
					Snotify(src, 2, 'Vehicle Doesn\'t Have a 2Step Module Installed!')
				end
			end
		end)
	end
end)

lib.callback.register('2step:Anti-lagCheck', function(source,plate)
	local src = source
	local return_var = nil
	if Object == 'ESX' then
		MySQL.query('SELECT `twostep` FROM `owned_vehicles` WHERE `plate` = ?', {
			plate
		}, function(response)
			if response then
				for i = 1, #response do
					local row = response[i]
					if row.twostep == 1 then
						return_var = true
					else
						return_var = false
					end
				end
			else
				return_var = false
			end
		end)
	elseif Object == 'QBCore' then
		MySQL.query('SELECT `twostep` FROM `player_vehicles` WHERE `plate` = ?', {
			plate
		}, function(response)
			if response then
				for i = 1, #response do
					local row = response[i]
					if row.twostep == 1 then
						return_var = true
					else
						return_var = false
					end
				end
			else
				return_var = false
			end
		end)
	end
	while return_var == nil do
		Wait(10)
	end
	return return_var
end)

function SNotify(source,type,text)
	if Config.Noty == 'ox' then
		if type == 1 then
			TriggerClientEvent('ox_lib:notify', source, {
				title = '2Step Module',
				description = text,
				type = 'success'
			})
		elseif type == 2 then
			TriggerClientEvent('ox_lib:notify', source, {
				title = '2Step Module',
				description = text,
				type = 'inform'
			})
		elseif type == 3 then
			TriggerClientEvent('ox_lib:notify', source, {
				title = '2Step Module',
				description = text,
				type = 'error'
			})
		end
	elseif Config.Noty == 'custom' then

	end
end

RegisterNetEvent('Sick-2Step:UninstallServer')
AddEventHandler('Sick-2Step:UninstallServer',function(plate)
	local src = source
	if Config.Framework == 'ESX' then
		MySQL.update('UPDATE `owned_vehicles` SET `twostep` = ? WHERE `plate` = ?', {
			0, plate
		})
		local info = {
			owner = plate
		}
		Inventory:AddItem(src, '2step', 1, info)
		SNotif(src, 2,'2Step Module Successfully Removed!')
	elseif Config.Framework == 'QBCore' then
		MySQL.update('UPDATE `player_vehicles` SET `twostep` = ? WHERE `plate` = ?', {
			0, plate
		})
		local info = {
			owner = plate
		}
		Inventory:AddItem(src, '2step', 1, info)
		SNotif(src, 2,'2Step Module Successfully Removed!')
	end
end)

RegisterNetEvent('Sick-2StepSV:PlayWithinDistance')
AddEventHandler('Sick-2StepSV:PlayWithinDistance', function(maxDistance, soundFile, soundVolume)
    local src = source
    local DistanceLimit = 300
    if maxDistance < DistanceLimit then
		TriggerClientEvent('Sick-2StepCL:PlayWithinDistance', -1, GetEntityCoords(GetPlayerPed(src)), maxDistance, soundFile, soundVolume)
    else
        print(('[interact-sound] [^3WARNING^7] %s attempted to trigger Sick-2StepSV:PlayWithinDistance over the distance limit ' .. DistanceLimit):format(GetPlayerName(src)))
    end
end)