-- --!strict

-- local Lifecycles = require("@shared/features/Arbeit/Lifecycles")
-- local Controller = require("@features/Arbeit/Providers/Controller")

-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local clientHooks = require("@ecs/clientHooks")
-- local clientSystemBarrel = require("@ecs/clientSystemBarrel")
-- local scheduler = require(ReplicatedStorage.Shared.ecs.scheduler)
-- local EnemiesNetworkHook = require("@shared/networking/hooks/EnemiesNetworkClientHook")
-- local TowerNetworkClientHook = require("@shared/networking/hooks/TowerNetworkClientHook")
-- local TestMap = require("@features/Maps/list/TestMap")
-- local PathSingleton = require("@features/other/PathSingleton")
-- local def: Controller.ControllerDef = {}

-- function def.OnStart()
-- 	print("STARTED")

-- 	for _, sys in clientSystemBarrel do
-- 		scheduler.add(sys)
-- 	end

-- 	clientHooks()
-- 	scheduler.start()
-- 	EnemiesNetworkHook()
-- 	TowerNetworkClientHook()

-- 	PathSingleton.compute(TestMap.pathPoints, 3)
-- end

-- function def.OnTick(dt: number)
-- 	-- print(dt)
-- end

-- return Controller.new({ Lifecycles.OnStart, Lifecycles.OnTick }, def)
