--!strict
local LifecycleClass = require("@self/LifecycleClass")
local Controller = require("@self/Providers/Controller")
local Service = require("@self/Providers/Service")
local RunService = game:GetService("RunService")
local Lifecycles = require("@self/Lifecycles")
local Component = require("@self/Providers/Component")
local utils = require("@self/Utils/utils")
local INCLUDE = require("@self/internal/INCLUDE")

export type Service = Service.Service
export type Controller = Controller.Controller
export type Component<T, Attrs> = Component.Component<T, Attrs>
export type Lifecycle<A...> = LifecycleClass.Lifecycle<A...>

local Arbeit = {}

local _paths: { Folder } = {}
local _workers = {}
local _registry: { [string]: { any } } = {}
local _working = false

function Arbeit.addDir(folder: Folder)
	table.insert(_paths, folder)
end

function Arbeit.register(decoratorType: string, obj: any)
	_registry[decoratorType] = _registry[decoratorType] or {}
	table.insert(_registry[decoratorType], obj)
end

function Arbeit.getRegistered<T>(decoratorType: string): { T }
	return _registry[decoratorType] or {}
end

function Arbeit.work()
	if _working then
		return
	end
	_working = true

	local providersBucket: { [number]: { Controller.Controller | Service.Service } } = {}

	for _, dir in _paths do
		for _, inst in dir:GetDescendants() do
			if inst:IsA("ModuleScript") then
				local mod = require(inst) :: any

				for _, decor in INCLUDE do
					if getmetatable(mod) == decor and decor.init then
						if
							decor == Controller and not RunService:IsClient()
							or decor == Service and not RunService:IsServer()
						then
							continue
						end

						Arbeit.register(decor.className, mod)

						mod:init()

						if decor == Controller or decor == Service then
							local loadOrder = (mod.config :: { loadOrder: number }).loadOrder -- fuck this
							providersBucket[loadOrder] = providersBucket[loadOrder] or {}
							table.insert(providersBucket[loadOrder], mod)
						end
					end
				end
			end
		end
	end

	local bucketIndices = utils.getActiveIndices(providersBucket)
	for _, bucket in bucketIndices do
		local curBucket = providersBucket[bucket]
		for _, provider in curBucket do
			for _, lifecycle in provider._lifecycles do
				local fn: any = provider.def[lifecycle.name]

				if lifecycle == Lifecycles.OnStart then
					fn()
				elseif lifecycle ~= Lifecycles.OnInit and lifecycle ~= Lifecycles.OnDestroy then
					lifecycle:subscribe(bucket, fn)
				end
			end
		end
	end
end

return Arbeit
