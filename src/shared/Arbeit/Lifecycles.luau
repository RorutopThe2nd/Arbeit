local LifecycleClass = require("./LifecycleClass")
local lifecycles = {
	OnInit = LifecycleClass.new<<() -> ()>>("OnInit"),
	OnComponentInit = LifecycleClass.new<<() -> ()>>("OnComponentInit"),
	OnStart = LifecycleClass.new<<() -> ()>>("OnStart"),
	OnTick = LifecycleClass.new<<(dt:number) -> ()>>("OnTick"),
	OnPhysics = LifecycleClass.new<<(time:number,dt:number) -> ()>>("OnPhysics"),
	OnRender = LifecycleClass.new<<(dt:number) -> ()>>("OnRender"),
	OnDestroy = LifecycleClass.new<<() -> ()>>("OnDestroy"),
}

return lifecycles
