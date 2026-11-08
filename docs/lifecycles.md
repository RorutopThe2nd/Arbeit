## The built-in lifecycles

All presets live in the `Lifecycles` table:

```luau
local Lifecycles = require(path.to.Arbeit.Lifecycles)

Lifecycles.OnInit
Lifecycles.OnComponentInit
Lifecycles.OnStart
Lifecycles.OnTick
Lifecycles.OnPhysics
Lifecycles.OnRender
Lifecycles.OnDestroy
```

| Lifecycle | Fires | Server service | Client controller | Component instance |
|---|---|---|---|---|
| `OnInit` | Immediately, as each module is discovered | ✓ | ✓ | ✓ (no `comp` arg — a plain `fn()`) |
| `OnComponentInit` | Per instance as it's constructed | — | — | ✓ |
| `OnStart` | After all providers in your `loadOrder` bucket init (spawned thread) | ✓ | ✓ | ✓ (per instance, synchronous) |
| `OnTick` | Every `Heartbeat` | ✓ | ✓ | ✓ |
| `OnPhysics` | Every `Stepped` | ✓ | ✓ | ✓ |
| `OnRender` | Every `RenderStepped` | — | ✓ | ✓ |
| `OnDestroy` | When tag removed from instance | — | — | ✓ (auto-fires for components only) |

## Scheduling semantics

Worth knowing:

- Providers are grouped into buckets by `config.loadOrder`, iterated from low to high — that's your declarative initialization order. Two providers in the same bucket have no ordering guarantee relative to each other.
- `OnStart` for services/controllers runs via `task.spawn` (a separate thread), while a Component's `OnStart` runs synchronously during tag handling.
- **Every `fireAll` callback** (both built-ins and custom lifecycles) runs in its own `task.spawn` wrapped in a `pcall` — errors `warn()` out (`Lifecycle {name} callback error: ...`) instead of crashing the frame.
- `RunService` wiring done by [`Arbeit.work()`](api/arbeit.md) is exactly:

  ```luau
  Heartbeat      → OnTick:fireAll(dt)
  Stepped        → OnPhysics:fireAll(time, dt)
  RenderStepped  → OnRender:fireAll(dt)   -- client only
  ```

  On a dedicated server only Heartbeat/Stepped are connected.

- Callbacks always dispatch in bucket-index order, so a `loadOrder = 1` component's `OnTick` runs before every `loadOrder = 3` component's `OnTick` in the same heartbeat.

## `OnDestroy` is component-only

`OnDestroy` is not scheduled for Services or Controllers by `work()` — only Components fire it (on tag removal). If you need server singleton teardown on shutdown, wire it yourself:

```luau
local def: Service.ServiceDef = {}

function def.OnStart()
	return game:BindToClose(function() ... end)
end
```

## Custom lifecycles

You're not restricted to the built-ins. `LifecycleClass.new` builds a named, typed, bucket-aware event you can drive yourself:

```luau
local LifecycleClass = require(path.to.Arbeit.LifecycleClass)

local OnRoundStart: LifecycleClass.Lifecycle<(roundId: number) -> ()> =
	LifecycleClass.new("OnRoundStart")

-- Any provider may opt into it:
return Service.new({ OnRoundStart }, def)

-- Somewhere else, fire it:
OnRoundStart:fireAll(roundId)
```

`fireAll` deliveries remain bucket-ordered and error-isolated like the built-ins. Full lifecycle API in [LifecycleClass reference →](api/lifecycleclass.md)

Related: [Services](providers/service.md) · [Controllers](providers/controller.md) · [Components](providers/component.md)
