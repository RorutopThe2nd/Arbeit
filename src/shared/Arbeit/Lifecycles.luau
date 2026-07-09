local LifecycleClass = require("./LifecycleClass")
local lifecycles = {
	OnInit = LifecycleClass.new<<() -> ()>>("OnInit"),
	OnComponentInit = LifecycleClass.new<<() -> ()>>("OnInit"),
	OnStart = LifecycleClass.new<<() -> ()>>("OnStart"),
	OnTick = LifecycleClass.new<<(dt:number) -> ()>>("OnStart"),
	OnDestroy = LifecycleClass.new<<() -> ()>>("OnStart"),
}

return lifecycles
