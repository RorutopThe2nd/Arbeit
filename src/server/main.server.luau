local Arbeit = require("@features/Arbeit/init")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local EnemyEntityUtils = require("@ecs/ecsUtils/EnemyEntityUtils")
-- local world = require("@ecs/world")
-- local TestMap = require("@shared/features/Maps/list/TestMap")
-- local PathSingleton = require("@shared/features/other/PathSingleton")
-- local EnemiesNetworkServerHook = require("@shared/networking/hooks/EnemiesNetworkServerHook")
-- local TowerNetworkServerHook = require("@shared/networking/hooks/TowerNetworkServerHook")
-- local scheduler = require(ReplicatedStorage.Shared.ecs.scheduler)
-- local serverHooks = require(ReplicatedStorage.Shared.ecs.serverHooks)
-- local serverSystemBarrel = require(ReplicatedStorage.Shared.ecs.serverSystemBarrel)

-- for _, sys in serverSystemBarrel do
-- 	scheduler.add(sys)
-- end

-- serverHooks()
-- scheduler.start()
-- EnemiesNetworkServerHook()
-- TowerNetworkServerHook()

-- PathSingleton.compute(TestMap.pathPoints, 3)
Arbeit.addDir(script.Parent.services)
Arbeit.work()
