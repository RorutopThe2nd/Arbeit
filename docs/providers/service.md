# Services

A Service is a **server-only** provider. It's a singleton ModuleScript that returns `Service.new(lifecycles, def, config?)`.

## Quick start

```luau
-- src/server/services/EnemyService.luau
local Lifecycles = require(path.to.Arbeit.Lifecycles)
local Service = require(path.to.Arbeit.Providers.Service)

local def: Service.ServiceDef = {}

function def.OnStart()
	print("Enemy service started")
end

function def.OnTick(dt: number)
	-- runs every Heartbeat
end

function def.OnPhysics(time: number, dt: number)
	-- runs every Stepped
end

return Service.new({ Lifecycles.OnStart, Lifecycles.OnTick, Lifecycles.OnPhysics }, def)
```

The mouthful `Service.new({ Lifecycles.X, ... }, def, config?)` is what replaces Flamework's `@Service()` + `implements OnTick, ...` decorators: the first argument is your **explicit lifecycle opt-in list**. See [Lifecycles](../lifecycles.md) for the full list and scheduling.

## Real example from this repo

```luau
-- src/server/services/ECSService.luau (trimmed)
local Lifecycles = require("@features/Arbeit/Lifecycles")
local Service = require("@features/Arbeit/Providers/Service")

local def: Service.ServiceDef = {}

function def.OnStart()
	print("START SERVER")

	for _, sys in serverSystemBarrel do
		scheduler.add(sys)
	end

	serverHooks()
	scheduler.start()
	PathSingleton.compute(TestMap.pathPoints, 3)
end

return Service.new({ Lifecycles.OnStart }, def)
```

## API

### `Service.new(lifecycles: { Lifecycle<a...> }, def: ServiceDef, config?: ServiceConfig): Service`

| Arg | Type | Description |
|---|---|---|
| `lifecycles` | `{ Lifecycle<a...> }` | Lifecycles the def table implements — see [Lifecycles](../lifecycles.md) |
| `def` | `ServiceDef` | Methods matching the lifecycle names, plus arbitrary state/methods of your own (the singleton public API) |
| `config` | `ServiceConfig` (optional) | see below |

### `ServiceDef`

```luau
type ServiceDef = {
	[string]: any,                       -- your normal methods / state (the singleton public API)
	OnStart: (() -> ())?,                -- after init, scheduled
	OnTick: ((dt: number) -> ())?,
	OnPhysics: ((time: number, dt: number) -> ())?,
	OnRender: ((dt: number) -> ())?,
	OnDestroy: (() -> ())?,
	-- OnInit: (() -> ())? is consulted but noted in the work loader only
}
```

### `ServiceConfig`

All fields optional (`types.Partial` of the internal config).

| Field | Type | Default | Notes |
|---|---|---|---|
| `loadOrder` | `number` | `1` | Bucket rank for boot ordering. Must be `> 0` (asserted). |
| `studioOnly` | `boolean` | `false` | Skipped outside Studio. |

### Runtime behaviour

- **Server-only.** `init` asserts `RunService:IsServer()` — requiring a Service on the client errors out.
- `init` executes `OnInit` synchronously, if the def table defines it and it was opted into via `lifecycles`.
- `OnStart` is deferred (`task.spawn`) by the [loader](../api/arbeit.md#arbeitwork), grouped per-`loadOrder` bucket.
- `OnDestroy` is **not** auto-fired for services — teardown is your responsibility here (see [Lifecycle notes →](../lifecycles.md#ondestroy-is-component-only)).

Related: [Controllers](controller.md) · [Components](component.md) · [Singleton usage](../singleton.md)
