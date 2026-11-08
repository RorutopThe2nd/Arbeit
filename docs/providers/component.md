# Components

A Component binds behaviour to instances via `collectionService` tags. Each tagged instance gets its own lifecycle subscription that receives the `ComponentInstance` as the first argument — the closest thing this framework has to Flamework's `@Component()` + Flint tags.

## Quick start

```luau
local Lifecycles = require(path.to.Arbeit.Lifecycles)
local Component = require(path.to.Arbeit.Providers.Component)

local def: Component.ComponentDef<BasePart, { Health: number }> = {}

-- Once when the comp instance is constructed (before guards/resolution):
function def.OnComponentInit(comp) end

-- Once per instance after guards succeed (synchronous; not scheduled):
function def.OnStart(comp)
	print(comp.instance, "spawned with", comp.attributes.Health, "HP")
end

-- Recurring, per-instance, in the component's configured loadOrder bucket:
function def.OnTick(comp, dt) end
function def.OnPhysics(comp, time, dt) end
function def.OnRender(comp, dt) end

-- When the tag is removed from the instance:
function def.OnDestroy(comp) end

local HealthComponent = Component.new(
	{
		Lifecycles.OnComponentInit,
		Lifecycles.OnStart,
		Lifecycles.OnTick,
		Lifecycles.OnDestroy,
	},
	def,
	{
		tag = "Enemy",
		defaultAttributes = { Health = 100 },
		instanceGuard = function(inst)
			return inst:IsA("BasePart"), "Must be a BasePart"
		end,
		attributeGuard = function(attrs)
			return attrs.Health ~= nil, "Health attribute missing"
		end,
		waitTimeout = 10,
	}
)

return HealthComponent
```

## Looking up a live instance

From anywhere:

```luau
local comp = HealthComponent.get(workspace.Zombie1)
if comp then
	print(comp.instance, comp.attributes.Health, comp.user)
end
```

## API

### `Component.new<T, Attrs, U>(lifecycles, def, config): Component<T, Attrs>`

```luau
Component.new<T, Attrs, U>(
	lifecycles: { Lifecycle<a...> },
	def: ComponentDef<T, Attrs>,
	config: ComponentConfig<Attrs>
): Component<T, Attrs>
```

Unlike `Service`/`Controller`, `config` is **not** optional here (it carries the `tag`).

### `ComponentDef<T, Attrs>`

Every per-instance lifecycle is passed `comp` first:

```luau
{
	[string]: any,

	OnInit: (() -> ())?,                                   -- global, once, at boot
	OnComponentInit: ((comp: ComponentInstance<...>) -> ())?,  -- per instance
	OnStart: ((comp: ComponentInstance<...>) -> ())?,          -- per instance, synchronous
	OnTick: ((comp: ComponentInstance<...>, dt: number) -> ())?,
	OnPhysics: ((comp: ComponentInstance<...>, time: number, dt: number) -> ())?,
	OnRender: ((comp: ComponentInstance<...>, dt: number) -> ())?,
	OnDestroy: ((comp: ComponentInstance<...>) -> ())?,    -- per instance teardown
}
```

### `ComponentConfig<Attrs>`

All fields optional:

| Field | Default | Notes |
|---|---|---|
| `tag: string` | `nil` | The `collectionService` tag to bind to. Without it, the component is constructed but never self-drives. |
| `loadOrder: number` | `1` | Which repeating-lifecycle bucket this component's instances subscribe into. |
| `studioOnly: boolean` | `false` | (reserved by the shared config) |
| `waitTimeout: number` | `60` | How long `instanceGuard` retries before timing out. |
| `defaultAttributes: Partial<Attrs>?` | `nil` | Fallback attribute values merged in when the instance lacks them. |
| `instanceGuard: ((Instance) -> (boolean, string?))?` | `nil` | Precondition that gates spawning the comp instance (re-checked until it passes or `waitTimeout` expires; errors on timeout). |
| `attributeGuard: ((attrs: { [string]: any }) -> (boolean, string?))?` | `nil` | Validates resolved attributes; a hard `assert` failure rejects the tagging. |

### `Component:get(instance)` → `ComponentInstance<T, Attrs, U>?`

Gets the live `ComponentInstance` bound to a tagged instance (or `nil`).

## `ComponentInstance<T, Attrs, U>` fields

| Field | Description |
|---|---|
| `instance: T & { Name, Parent }` | The tagged Instance |
| `attributes: Attrs` | Resolved attributes (instance attrs, falling back to `defaultAttributes`) |
| `user: U` | Free space for you (initialized to `{}`) — per-instance module-local state |
| `_componentType` | Reference back to the owning Component (internal) |

## Per-instance lifecycle flow (on tag add)

1. Construct `ComponentInstance`, merging instance attributes over `defaultAttributes`.
2. Call `OnComponentInit(comp)` (if opted in).
3. Resolve guards — `instanceGuard` (waits up to `waitTimeout`, erroring on timeout) then `attributeGuard` (hard `assert`).
4. Call `OnStart(comp)` synchronously.
5. Subscribe every remaining opted-in lifecycle (everything besides `OnDestroy`) to the shared lifecycle buckets, wrapping each so `comp` is always the first argument.

## Useful detail: churn

Because each instance's repeating callbacks occupy their own subscriptions, tag churn is cheap: tag removal unsubscribes each wrapped callback and fires `OnDestroy(comp)` exactly once — no listener leakage even for sim-game-style add/remove storms.

Related: [Services](service.md) · [Controllers](controller.md)
