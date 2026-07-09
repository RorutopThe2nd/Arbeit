--!strict
local RunService = game:GetService("RunService")
local Lifecycles = require("../Lifecycles")
local LifecycleClass = require("../LifecycleClass")
local types = require("../types")

local Service = {}
Service.className = "Service"
Service.__index = Service

type IServiceConfig = {
	loadOrder: number,
	studioOnly: boolean,
}
export type ServiceConfig = types.Partial<IServiceConfig>

export type ServiceDef = {
	[string]: any,
	OnStart: (() -> ())?,
	OnTick: ((dt: number) -> ())?,
	OnPhysics: ((time: number, dt: number) -> ())?,
	OnRender: ((dt: number) -> ())?,
	OnDestroy: (() -> ())?,
}

type IService = {
	_lifecycles: { LifecycleClass.Lifecycle<...any> },
	def: ServiceDef,
	config: IServiceConfig,
}

export type Service = IService & {
	init: (self: Service) -> (),
}

function getConfig(merge: ServiceConfig?): IServiceConfig
	merge = merge or {} :: ServiceConfig
	return {
		loadOrder = merge.loadOrder or 1,
		studioOnly = merge.studioOnly or false,
	}
end

function Service.new(lifecycles: { LifecycleClass.Lifecycle<...any> }, def: ServiceDef, config: ServiceConfig?): Service
	local conf = getConfig(config)
	assert(conf.loadOrder > 0, "Load order must be >0 !")

	local self = setmetatable(
		{
			_lifecycles = lifecycles,
			def = def,
			config = conf,
		} :: IService,
		Service
	) :: Service

	return self
end

function Service.init(self: Service) -- The loader will collect all Services' OnStart lifecycle and they will be executed depending on the load order
	if self.config.studioOnly and not RunService:IsStudio() then
		return
	end

	assert(RunService:IsServer(), "This service must be run on the server.")
	for _, lifecycle in self._lifecycles do
		local fn: any = self.def[lifecycle.name]
		if type(fn) == "function" then
			if lifecycle == Lifecycles.OnInit then
				(fn :: any)()
				-- elseif lifecycle ~= Lifecycles.OnStart then
				-- 	lifecycle:subscribe(self.config.loadOrder, fn)
			end
		end
	end
end

return Service
