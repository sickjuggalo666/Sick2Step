Config = {
	UseOxInv = false, -- this is checked first (if set true ESX/QBCore wont matter)
	ESX = false, -- false for QBCore
	Noty = 'ox', -- 'ox' or 'custom' change in client.lua/server.lua
		-- 21 (Left Shift by default)
	twoStepControl = 21,

	Backfires = {
		[1] = "backfire1",
		[2] = "backfire2",
		[3] = "backfire3",
		[4] = "backfire4",
		[5] = "backfire5",
	},

	p_flame_location = {
		"exhaust",
		"exhaust_2",
		"exhaust_3",
		"exhaust_4",
		"exhaust_5",
		"exhaust_6",
		"exhaust_7",
		"exhaust_8",
		"exhaust_9",
		"exhaust_10",
		"exhaust_11",
		"exhaust_12",
		"exhaust_13",
		"exhaust_14",
		"exhaust_15",
		"exhaust_16",
	},

	p_flame_particle = "veh_backfire",

	p_flame_particle_asset = "core" ,
	p_flame_size = 3.0,

	modules = {
		module = '2step',
		checker = '2step_checker'
	}

}