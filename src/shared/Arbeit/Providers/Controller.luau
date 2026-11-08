--!strict
local RunService = game:GetService("RunService")
local Lifecycles = require("../Lifecycles")
local LifecycleClass = require("../LifecycleClass")
local types = require("../types")

local Controller = {}
Controller.className = "Controller"
Controller.__index = Controller

type IControllerConfig = {
	loadOrder: number,
	studioOnly: boolean,
}
export type ControllerConfig = types.Partial<IControllerConfig>

export type ControllerDef = {
	[string]: any,

	OnInit: (() -> ())?,
	OnStart: (() -> ())?,
	OnTick: ((dt: number) -> ())?,
	OnPhysics: ((time: number, dt: number) -> ())?,
	OnRender: ((dt: number) -> ())?,
	OnDestroy: (() -> ())?,
}

type IController = {
	_lifecycles: { LifecycleClass.Lifecycle<...any> },
	def: ControllerDef,
	config: IControllerConfig,
}

export type Controller = IController & {
	init: (self: Controller) -> (),
}

function getConfig(merge: ControllerConfig?): IControllerConfig
	merge = merge or {} :: ControllerConfig
	return {
		loadOrder = merge.loadOrder or 1,
		studioOnly = merge.studioOnly or false,
	}
end

function Controller.new(
	lifecycles: { LifecycleClass.Lifecycle<...any> },
	def: ControllerDef,
	config: ControllerConfig?
): Controller
	local conf = getConfig(config)
	assert(conf.loadOrder > 0, "Load order must be >0 !")

	local self = setmetatable(
		{
			_lifecycles = lifecycles,
			def = def,
			config = conf,
		} :: IController,
		Controller
	) :: Controller

	return self
end

function Controller.init(self: Controller)
	if self.config.studioOnly and not RunService:IsStudio() then
		return
	end

	assert(RunService:IsClient(), "This Controller must be run on the client.")
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

return Controller
