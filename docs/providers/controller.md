# Controllers

A Controller is a **client-only** provider. Same shape as a [Service](service.md) but bound to the client.

## Quick start

```luau
-- src/client/controllers/HudController.luau
local Lifecycles = require(path.to.Arbeit.Lifecycles)
local Controller = require(path.to.Arbeit.Providers.Controller)

local def: Controller.ControllerDef = {}

function def.OnStart()
	print("Client started")
end

function def.OnRender(dt: number)
	-- runs every RenderStepped (client only)
end

function def.OnTick(dt: number) end

return Controller.new(
	{ Lifecycles.OnStart, Lifecycles.OnTick, Lifecycles.OnRender },
	def
)
```

## Real example from this repo

```luau
-- src/client/controller/ECSController.luau (trimmed)
local def: Controller.ControllerDef = {}

function def.OnStart()
	print("STARTED")

	for _, sys in clientSystemBarrel do
		scheduler.add(sys)
	end

	clientHooks()
	scheduler.start()
end

function def.OnTick(dt: number)
	-- print(dt)
end

return Controller.new({ Lifecycles.OnStart, Lifecycles.OnTick }, def)
```

## API

### `Controller.new(lifecycles: { Lifecycle<a...> }, def: ControllerDef, config?: ControllerConfig): Controller`

| Arg | Type | Description |
|---|---|---|
| `lifecycles` | `{ Lifecycle<a...> }` | Lifecycles the def table implements |
| `def` | `ControllerDef` | Lifecycle methods plus arbitrary state/methods of your own |
| `config` | `ControllerConfig` (optional) | see below |

### `ControllerDef`

```luau
type ControllerDef = {
	[string]: any,

	OnInit: (() -> ())?,
	OnStart: (() -> ())?,
	OnTick: ((dt: number) -> ())?,
	OnPhysics: ((time: number, dt: number) -> ())?,
	OnRender: ((dt: number) -> ())?,
	OnDestroy: (() -> ())?,
}
```

### `ControllerConfig`

Mirrors [`ServiceConfig`](service.md#serviceconfig) — all fields optional:

| Field | Type | Default | Notes |
|---|---|---|---|
| `loadOrder` | `number` | `1` | Bucket rank for boot ordering. Must be `> 0` (asserted). |
| `studioOnly` | `boolean` | `false` | Skipped outside Studio. |

### Runtime behaviour

- **Client-only.** `init` asserts `RunService:IsClient()` — requiring a Controller on the server errors out.
- `RenderStepped` wiring (`OnRender`) is client-only; the server only connects `Heartbeat`/`Stepped`. See [Lifecycles ▸ scheduling](../lifecycles.md#scheduling-semantics).
- Singletons work identically to Services — see [Singleton usage](../singleton.md).

Related: [Services](service.md) · [Components](component.md)
