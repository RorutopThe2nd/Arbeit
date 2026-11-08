## Singletons in Arbeit

Services and Controllers are **singletons by construction**: a ModuleScript can only be required once, so the table it returns — the instance you built with `Service.new()` / `Controller.new()` — *is* the singleton shared by the entire server or client. Other code simply `require`s the module and uses it directly. No construction, no dependency injection, no locator.

## The idiomatic single-file singleton pattern

A single module can hold **both** the importable namespace for other code *and* the lifecycle singleton for the framework:

```luau
-- src/shared/features/singleton/PathSingleton.luau
local Lifecycles = require(path.to.Arbeit.Lifecycles)
local Service = require(path.to.Arbeit.Providers.Service)

local PathSingleton = {}

-- Importable namespace: other requires of this file always get the
-- same table, so calling PathSingleton.compute() is a true singleton call.
function PathSingleton.compute(points: { Vector3 }, subdivisions: number)
	-- ... always operates on the same shared state ...
end

-- Framework singleton: same module also declares the lifecycle def.
local def: Service.ServiceDef = {}

function def.OnStart()
	print("PathSingleton service started")

	-- Boot order is determined by config.loadOrder, and OnStart is deferred,
	-- so by the time this runs every provider in previous buckets has finished.
	PathSingleton.compute({ Vector3.zero }, 3)
end

return Service.new(
	{ Lifecycles.OnStart },   -- which lifecycles this provider opts into
	def,                      -- the lifecycle implementations
	{ loadOrder = 2 }         -- optional config
)
```

## Consuming it from another service

Just require the module and use it — the instance is always there:

```luau
-- src/server/services/EnemyService.luau
local PathSingleton = require(path.to.PathSingleton)
local Lifecycles = require(path.to.Arbeit.Lifecycles)
local Service = require(path.to.Arbeit.Providers.Service)

local def: Service.ServiceDef = {}

function def.OnStart()
	-- Same singleton table, already initialized (bucket ordering guarantees it):
	PathSingleton.compute(map.pathPoints, 3)
end

return Service.new({ Lifecycles.OnStart }, def)
```

You can also pull in the *def* namespace as a local before boot (`local def = Service.new(...)` and access `def.foo`) — `def` is just a plain table of state/methods, so it's a fine surface for shared mutable state.

## Verifying discovery at runtime

Want to inspect what the loader actually discovered? Use the registry API:

```luau
for _, svc in Arbeit.getRegistered("Service") do
	print(svc.def, svc.config)
end
```

Back to [Getting started](getting-started.md) · Next: [Services →](providers/service.md)
