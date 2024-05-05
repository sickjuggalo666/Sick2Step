--[[
	Antilag & 2-Step Script
		By Silence & Samuel_
	But Client stuff...
]]
RegisterNetEvent("2step:Anti-lag")
RegisterNetEvent("c_eff_flames")
local bones = {}
local activated = false
local antilag = false
local AntilagDisplay = false
local currentGear = 0

exports.ox_inventory:displayMetadata({
    owner = 'Original Owner',
})

local function Start2StepLoop()
	Citizen.CreateThread(function()
		while antilag do
			local ped = PlayerPedId()
			if IsControlPressed(1, Config.twoStepControl) and antilag then
				if IsPedInAnyVehicle(ped) then
					local pedVehicle = GetVehiclePedIsIn(ped)
					local pedPos = GetEntityCoords(ped)
					local vehiclePos = GetEntityCoords(pedVehicle)
					local RPM = GetVehicleCurrentRpm(GetVehiclePedIsIn(PlayerPedId()))

					if GetPedInVehicleSeat(pedVehicle, -1) == ped then
						if not IsEntityInAir(pedVehicle) then
							local vehicleModel = GetEntityModel(GetVehiclePedIsIn(PlayerPedId()))
							local BackFireDelay = (math.random(100, 500))
							if RPM > 0.3 and RPM < 0.5 then
								local backfire = math.random(#Config.Backfires)
								local file = Config.Backfires[backfire]
								TriggerServerEvent("eff_flames", VehToNet(pedVehicle))
								TriggerServerEvent('Sick-2StepSV:PlayWithinDistance', 25,file,1.0)
								activated = true
								Wait(BackFireDelay)
							else
								activated = false
							end
						end
					end
				else
					activated = false
				end
			else
				activated = false
				if not IsControlPressed(1, 71) and not IsControlPressed(1, 72) then
					if antilag == true then
						if IsPedInAnyVehicle(ped) then
							local pedVehicle = GetVehiclePedIsIn(ped)
							local pedPos = GetEntityCoords(ped)
							local vehiclePos = GetEntityCoords(pedVehicle)
							local RPM = GetVehicleCurrentRpm(GetVehiclePedIsIn(PlayerPedId()))
							local AntiLagDelay = (math.random(25, 200))
							if GetPedInVehicleSeat(pedVehicle, -1) == ped then
								if RPM > 0.75 then
									local vehicleModel = GetEntityModel(GetVehiclePedIsIn(PlayerPedId()))
									local backfire = math.random(#Config.Backfires)
									local file = Config.Backfires[backfire]
									TriggerServerEvent("eff_flames", VehToNet(pedVehicle))
									TriggerServerEvent('Sick-2StepSV:PlayWithinDistance', 25,file,1.0)
									SetVehicleTurboPressure(pedVehicle, 25)
									Wait(AntiLagDelay)
								end
							end
						else
							antilag = false
						end
					end
				end
			end
			if antilag then
				local ped = PlayerPedId()
				local pedVehicle = GetVehiclePedIsIn(ped)
			
				if pedVehicle ~= 0 then
					local newGear = GetVehicleCurrentGear(pedVehicle)
			
					if newGear ~= currentGear then
						currentGear = newGear
						local backfire = math.random(#Config.Backfires)
						local file = Config.Backfires[backfire]
						TriggerServerEvent("eff_flames", VehToNet(pedVehicle))
						TriggerServerEvent('Sick-2StepSV:PlayWithinDistance', 25,file,1.0)
					end
				else
					if currentGear ~= 0 then
						currentGear = 0
					end
				end
			end
			if IsControlJustReleased(1, Config.twoStepControl) then
				if IsPedInAnyVehicle(ped, true) then
					local pedVehicle = GetVehiclePedIsIn(ped)
					SetVehicleTurboPressure(pedVehicle, 25)
				end
			end
			Wait(1)
		end
	end)
end

AddEventHandler("2step:Anti-lag", function()
	local ped = PlayerPedId()
	if not antilag then
		local pedVehicle = GetVehiclePedIsIn(ped)
		if IsPedInAnyVehicle(ped) then
			local plate = GetVehicleNumberPlateText(pedVehicle)
			print(plate)
			local twostep = lib.callback.await('2step:Anti-lagCheck', 1000,plate)
			print(twostep)
			if twostep then
				antilag = true
				Start2StepLoop()
				Notif(2, "Anti-Lag has been Enabled!")
			else
				Notif(3, 'Need 2Step Module In order to use!')
			end
		end
	else
		antilag = false
		Notif(2, "Anti-Lag has been Disabled!")
	end
end)

for i = 1, 16 do
    if i == 1 then
        table.insert(bones, "exhaust")
    else
        table.insert(bones, "exhaust_"..tostring(i))
    end
end

AddEventHandler("c_eff_flames", function(vehicle)
	print("Vehicle: "..vehicle)
	for _,boneName in pairs(Config.p_flame_location) do
		local boneIndex = GetEntityBoneIndexByName(vehicle, boneName )
		print('BoneIndex is: '..boneIndex)
        if boneIndex ~= -1 then
			print('BoneIndex is 2: '..boneIndex)
            local fireOffset = GetOffsetFromEntityGivenWorldCoords(vehicle, GetWorldPositionOfEntityBone(vehicle, boneIndex))
            UseParticleFxAssetNextCall('core')
            StartNetworkedParticleFxNonLoopedOnEntity('veh_backfire', vehicle, fireOffset, 0.0, 0.0, 0.0, 1.3, false, false, false)
		else
			print('BoneIndex is 3: '..boneIndex)
			UseParticleFxAssetNextCall(Config.p_flame_particle_asset)
			createdPart = StartParticleFxLoopedOnEntityBone(Config.p_flame_particle,vehicle, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, GetEntityBoneIndexByName(NetToVeh(c_veh), bones), Config.p_flame_size, 0.0, 0.0, 0.0)
			StopParticleFxLooped(createdPart, 1)
		end
	end
end)

function Notif( type, text )
	if type == 1 then
		lib.notify({
			title = '2Step System',
			description = text,
			position = 'top',
			type = 'success'
		})
	elseif type == 2 then
		lib.notify({
			title = '2Step System',
			description = text,
			position = 'top',
			type = 'inform'
		})
	elseif type == 3 then
		lib.notify({
			title = '2Step System',
			description = text,
			position = 'top',
			type = 'error',
		})
	end
end

RegisterNetEvent('Sick-2Step:GetPlateFromClient')
AddEventHandler('Sick-2Step:GetPlateFromClient',function(police)
	if not police then
		local ped = PlayerPedId()
		local pedVehicle = GetVehiclePedIsIn(ped)
		if not IsPedInAnyVehicle(ped, false) then
			Notif(3, 'You Need to be in a Vehicle!')
			return
		else
			local plate = GetVehicleNumberPlateText(pedVehicle)
			if lib.progressBar({
				duration = 5000,
				label = 'Checking 2Step',
				useWhileDead = false,
				canCancel = true,
				disable = {
					move = true,
					combat = true,
					car = true,
				}
				})
			then
				TriggerServerEvent('Sick-2Step:Set2StepVeh', plate)
			else
				print('Do stuff when cancelled')
			end

		end
	else
		local ped = PlayerPedId()
		local pedVehicle = GetVehiclePedIsIn(ped)
		if not IsPedInAnyVehicle(ped, false) then
			Notif(3, 'You Need to be in a Vehicle!')
			return
		else
			local plate = GetVehicleNumberPlateText(pedVehicle)
			if lib.progressBar({
				duration = 5000,
				label = 'Checking 2Step',
				useWhileDead = false,
				canCancel = true,
				disable = {
					move = true,
					combat = true,
					car = true,
				}
				})
			then
				TriggerServerEvent('Sick-2Step:Police2Step', plate)
			else
				print('Do stuff when cancelled')
			end

		end
	end
	local ped = PlayerPedId()
	local pedVehicle = GetVehiclePedIsIn(ped)
	if not IsPedInAnyVehicle(ped, false) then
		Notif(3, 'You Need to be in a Vehicle!')
		return
	else
		local plate = GetVehicleNumberPlateText(pedVehicle)
		if lib.progressBar({
			duration = 5000,
			label = 'Checking 2Step',
			useWhileDead = false,
			canCancel = true,
			disable = {
				move = true,
				combat = true,
				car = true,
			}
			})
		then
			TriggerServerEvent('Sick-2Step:Set2StepVeh', plate)
		else
			print('Do stuff when cancelled')
		end

	end
end)

RegisterNetEvent('Sick-2Step:UninstallClient')
AddEventHandler('Sick-2Step:UninstallClient',function(plate)
	local alert = lib.alertDialog({
		header = '2Step Module',
		content = 'Do you want to remove the 2 Step Module In Vehicle? \n Plate: '..plate,
		centered = true,
		cancel = true
	})
	if alert == 'confirm' then
		if lib.progressBar({
			duration = 5000,
			label = 'Removing 2Step',
			useWhileDead = false,
			canCancel = true,
			disable = {
				move = true,
				combat = true,
				car = true,
			}
			})
		then
			TriggerServerEvent('Sick-2Step:UninstallServer', plate)
		else
			print('Do stuff when cancelled')
		end
	end
end)

local standardVolumeOutput = 0.3;
local hasPlayerLoaded = false
Citizen.CreateThread(function()
	Wait(15000)
	hasPlayerLoaded = true
end)

RegisterNetEvent('Sick-2StepCL:PlayWithinDistance')
AddEventHandler('Sick-2StepCL:PlayWithinDistance', function(otherPlayerCoords, maxDistance, soundFile, soundVolume)
	if hasPlayerLoaded then
		local myCoords = GetEntityCoords(PlayerPedId())
		local distance = #(myCoords - otherPlayerCoords)

		if distance < maxDistance then
			SendNUIMessage({
				transactionType = 'playSound',
				transactionFile  = soundFile,
				transactionVolume = soundVolume or standardVolumeOutput
			})
		end
	end
end)


exports('2step', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			local ped = PlayerPedId()
			local pedVehicle = GetVehiclePedIsIn(ped)
			if not IsPedInAnyVehicle(ped, false) then 
				Notif(3, 'You Need to be in a Vehicle!')
				return 
			else
				print('Here 1')
				local plate = GetVehicleNumberPlateText(pedVehicle)
				if lib.progressBar({
					duration = 5000,
					label = 'Checking 2Step',
					useWhileDead = false,
					canCancel = true,
					disable = {
						move = true,
						combat = true,
						car = true,
					}
					}) 
				then 
					TriggerServerEvent('Sick-2Step:Set2StepVeh', plate)
				else 
					return
				end
			end
		end
	end)
end)

exports('2step_checker', function(data, slot)
	exports.ox_inventory:useItem(data, function(data)
		if data then
			local ped = PlayerPedId()
			local pedVehicle = GetVehiclePedIsIn(ped)
			if not IsPedInAnyVehicle(ped, false) then 
				Notif(3, 'You Need to be in a Vehicle!')
				return 
			else
				local plate = GetVehicleNumberPlateText(pedVehicle)
				if lib.progressBar({
					duration = 5000,
					label = 'Checking 2Step',
					useWhileDead = false,
					canCancel = true,
					disable = {
						move = true,
						combat = true,
						car = true,
					}
					}) 
				then 
					TriggerServerEvent('Sick-2Step:Police2Step', plate)
				else 
					return
				end
			end
		end
	end)
end)