local Arbeit = require("@shared/features/Arbeit/init")
-- local ContextActionService = game:GetService("ContextActionService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local clientHooks = require("@ecs/clientHooks")
-- local clientSystemBarrel = require("@ecs/clientSystemBarrel")
-- local Jabby = require("@pkg/Jabby")
-- local TestMap = require("@shared/features/Maps/list/TestMap")
-- local PathSingleton = require("@shared/features/other/PathSingleton")
-- local scheduler = require(ReplicatedStorage.Shared.ecs.scheduler)
-- local EnemiesNetworkHook = require("@shared/networking/hooks/EnemiesNetworkClientHook")
-- local TowerNetworkClientHook = require("@shared/networking/hooks/TowerNetworkClientHook")

-- for _, sys in clientSystemBarrel do
-- 	scheduler.add(sys)
-- end

-- clientHooks()
-- scheduler.start()
-- EnemiesNetworkHook()
-- TowerNetworkClientHook()

-- PathSingleton.compute(TestMap.pathPoints, 3)

-- local client = Jabby.obtain_client()

-- local function create_widget(_, state: Enum.UserInputState)
-- 	if state ~= Enum.UserInputState.Begin then
-- 		return
-- 	end
-- 	client.spawn_app(client.apps.home, nil)
-- end

-- ContextActionService:BindAction("Open Jabby Home", create_widget, false, Enum.KeyCode.F4)

Arbeit.addDir(script.Parent.controller)
Arbeit.work()
