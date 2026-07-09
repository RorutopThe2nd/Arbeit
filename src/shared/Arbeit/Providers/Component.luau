--!strict
local CollectionService = game:GetService("CollectionService")
local Lifecycles = require("../Lifecycles")
local LifecycleClass = require("../LifecycleClass")
local types = require("../types")

local Component = {}
Component.className = "Component"
Component.__index = Component

type Fn<A...> = (A...) -> ()

type BaseInstance = {
	Name: string,
	Parent: Instance?,
}

type IComponentConfig<Attrs> = {
	loadOrder: number,
	studioOnly: boolean,
	tag: string?,
	waitTimeout: number,
	defaultAttributes: types.Partial<Attrs>?,
	instanceGuard: (Instance) -> (boolean, string?)?,
	attributeGuard: ({ [string]: any }) -> (boolean, string?)?,
}

export type ComponentConfig<Attrs> = {
	loadOrder: number?,
	studioOnly: boolean?,
	tag: string?,
	waitTimeout: number?,
	defaultAttributes: types.Partial<Attrs>?,
	instanceGuard: ((Instance) -> (boolean, string?)?)?,
	attributeGuard: (({ [string]: any }) -> (boolean, string?)?)?,
}
export type ComponentDef<T, Attrs> = {
	[string]: any,

	OnInit: (() -> ())?,
	OnComponentInit: ((component: ComponentInstance<T, Attrs, any>) -> ())?,
	OnStart: ((component: ComponentInstance<T, Attrs, any>) -> ())?,
	OnTick: ((component: ComponentInstance<T, Attrs, any>, dt: number) -> ())?,
	OnPhysics: ((component: ComponentInstance<T, Attrs, any>, time: number, dt: number) -> ())?,
	OnRender: ((component: ComponentInstance<T, Attrs, any>, dt: number) -> ())?,
	OnDestroy: ((component: ComponentInstance<T, Attrs, any>) -> ())?,
}
type IComponent<T, Attrs> = {
	_lifecycles: { LifecycleClass.Lifecycle<...any> },
	def: ComponentDef<T, Attrs>,
	config: IComponentConfig<Attrs>,
	_map: { [Instance]: ComponentInstance<T, Attrs, any> },
}
export type Component<T, Attrs> = IComponent<T, Attrs> & {
	get: (instance: Instance) -> ComponentInstance<T, Attrs, any>,
}

export type ComponentInstance<T, Attrs, U> = {
	_componentType: Component<T, Attrs>,
	instance: T & BaseInstance,
	attributes: Attrs,
	_lifecycleFuncs: { [LifecycleClass.Lifecycle<...any>]: Fn<...any> },
	user: U,
}

function getConfig<Attrs>(merge: ComponentConfig<Attrs>?): IComponentConfig<Attrs>
	merge = merge or {} :: ComponentConfig<Attrs>
	return {
		loadOrder = merge.loadOrder or 1,
		studioOnly = merge.studioOnly or false,
		tag = merge.tag,
		waitTimeout = merge.waitTimeout or 60,
		defaultAttributes = merge.defaultAttributes,
		instanceGuard = merge.instanceGuard,
		attributeGuard = merge.attributeGuard,
	}
end

function Component.new<T, Attrs>(
	lifecycles: { LifecycleClass.Lifecycle<...any> },
	def: ComponentDef<T, Attrs>,
	config: ComponentConfig<Attrs>
)
	local self = setmetatable(
		{
			_lifecycles = lifecycles,
			def = def,
			config = getConfig(config),
			_map = {},
		} :: IComponent<T, Attrs>,
		Component
	) :: Component<T, Attrs>
	return self
end

local function guardWait(fn: () -> boolean, timeout: number)
	local await = 0
	while not fn() do
		await += task.wait()
		if await >= timeout then
			return
		end
	end
end

local function instAdded<T, Attrs>(self: Component<T, Attrs>, inst: Instance)
	local compInst: ComponentInstance<T, Attrs, any> = {
		_componentType = self,
		instance = inst,
		attributes = {},
		_lifecycleFuncs = {},
		user = {},
	}

	local default: { [string]: any } = self.config.defaultAttributes or {}
	local attrs = inst:GetAttributes()
	for k, v in default do
		if not attrs[k] and v ~= nil then
			attrs[k] = v
		end
	end

	local lifecycleSubs: { LifecycleClass.Lifecycle<...any> } = {}
	local OnStartLf: typeof(Lifecycles.OnStart)?

	for _, lifecycle in self._lifecycles do
		local fn: any = self.def[lifecycle.name]
		if type(fn) == "function" then
			if lifecycle == Lifecycles.OnComponentInit then
				(fn :: any)(compInst)
			elseif lifecycle == Lifecycles.OnStart then
				OnStartLf = lifecycle
			else
				table.insert(lifecycleSubs, lifecycle)
			end
		end
	end

	if self.config.instanceGuard then
		local succ, err
		guardWait(function(): boolean
			succ, err = self.config.instanceGuard(inst)
			return succ
		end, self.config.waitTimeout)
		if not succ then
			error(
				`Instance {inst} timeout past {self.config.waitTimeout}s from waiting the instance guard. \n Error: {err}`
			)
		end
	end

	if self.config.attributeGuard then
		local succ, err = self.config.attributeGuard(attrs)
		assert(succ, `Component Error: {err}`)
	elseif self.config.defaultAttributes then
		for k, v in self.config.defaultAttributes :: { [string]: any } do
			(compInst.attributes :: { [string]: any })[k] = v
		end
	end

	compInst.attributes = attrs :: Attrs

	if OnStartLf then
		local fn: any = self.def[OnStartLf.name]
		if fn then
			(fn :: any)(compInst)
		end
	end

	for _, lifecycle in lifecycleSubs do
		local fn: any = self.def[lifecycle.name]
		local wrappedFn = function(...)
			(fn :: any)(compInst, ...)
		end
		compInst._lifecycleFuncs[lifecycle] = wrappedFn
		if type(fn) == "function" and lifecycle ~= Lifecycles.OnDestroy then
			lifecycle:subscribe(self.config.loadOrder, function(...)
				(wrappedFn :: any)(compInst, ...)
			end)
		end
	end

	self._map[inst] = compInst
end

local function instRemoved<T, Attrs>(self: Component<T, Attrs>, inst: Instance)
	local comp = self._map[inst]
	assert(comp)
	for lifecycle, fn in comp._lifecycleFuncs do
		if lifecycle ~= Lifecycles.OnDestroy then
			lifecycle:unsubscribe(self.config.loadOrder, fn)
		else
			fn(comp)
		end
	end

	self._map[inst] = nil
end

function Component.init<T, Attrs>(self: Component<T, Attrs>)
	for _, lifecycle in self._lifecycles do
		local fn: any = self.def[lifecycle.name]
		if lifecycle == Lifecycles.OnInit then
			fn()
		elseif
			lifecycle ~= Lifecycles.OnComponentInit
			and lifecycle ~= Lifecycles.OnStart
			and lifecycle ~= Lifecycles.OnDestroy
		then
			lifecycle:initBucket(self.config.loadOrder)
		end
	end
	if self.config.tag then
		CollectionService:GetInstanceAddedSignal(self.config.tag):Connect(function(inst: Instance)
			instAdded(self, inst)
		end)
		CollectionService:GetInstanceRemovedSignal(self.config.tag):Connect(function(inst: Instance)
			instRemoved(self, inst)
		end)
	end
end

function Component.get<T, Attrs, U>(self: Component<T, Attrs>, instance: Instance): ComponentInstance<T, Attrs, U>?
	return self._map[instance]
end
return Component
