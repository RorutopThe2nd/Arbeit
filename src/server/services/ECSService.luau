-- local Lifecycles = require("@features/Arbeit/Lifecycles")
-- local Service = require("@features/Arbeit/Providers/Service")

-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local TestMap = require("@shared/features/Maps/list/TestMap")
-- local PathSingleton = require("@shared/features/other/PathSingleton")
-- local EnemiesNetworkServerHook = require("@shared/networking/hooks/EnemiesNetworkServerHook")
-- local TowerNetworkServerHook = require("@shared/networking/hooks/TowerNetworkServerHook")
-- local scheduler = require(ReplicatedStorage.Shared.ecs.scheduler)
-- local serverHooks = require(ReplicatedStorage.Shared.ecs.serverHooks)
-- local serverSystemBarrel = require(ReplicatedStorage.Shared.ecs.serverSystemBarrel)

-- local def: Service.ServiceDef = {}

-- function def.OnStart()
-- 	print("START SERVER")

-- 	for _, sys in serverSystemBarrel do
-- 		scheduler.add(sys)
-- 	end

-- 	serverHooks()
-- 	scheduler.start()
-- 	EnemiesNetworkServerHook()
-- 	TowerNetworkServerHook()

-- 	PathSingleton.compute(TestMap.pathPoints, 3)
-- end

-- return Service.new({ Lifecycles.OnStart }, def)
