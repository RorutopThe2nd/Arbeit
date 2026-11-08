# API: types

## `types.luau` → `types.Partial<T>`

A Luau **type function** that gives a TS-flavoured `Partial<T>` of any table type:

```luau
local types = require(path.to.Arbeit.types)

type MyConfig = { name: string, retries: number }
type MyConfigPartial = types.Partial<MyConfig>  -- { name: string?, retries: number? }
```

- Table-only — using it with a non-table type errors.
- Walks every property of `T` and makes both the read and write types optional.
- Preserves read/write symmetry when possible (so Luau doesn't needlessly split a property into separate read/write sides).
- Table indexers and metatables can't be inspected via the current type API, so those aren't preserved (edge-case only).

This is how `ServiceConfig`, `ControllerConfig` and `ComponentConfig<Attrs>` are all optional-field config tables despite being derived from stricter internal representations (`IServiceConfig`, `IControllerConfig`, `IComponentConfig<Attrs>`).

## Re-exported type surface

The package root (`init.luau`) re-exports the four workhorse types:

```luau
export type Service                    = Service.Service
export type Controller                 = Controller.Controller
export type Component<T, Attrs>        = Component.Component<T, Attrs>
export type Lifecycle<A...>            = LifecycleClass.Lifecycle<A...>
```

Each provider module also exports its own def/config/instance types, which are what you'll mostly annotate with:

```luau
Service.ServiceDef / Service.ServiceConfig
Controller.ControllerDef / Controller.ControllerConfig
Component.ComponentDef<T, Attrs> / Component.ComponentConfig<Attrs> / Component.ComponentInstance<T, Attrs, U>
```

Related: [`Arbeit` root API](arbeit.md) · [`LifecycleClass` API](lifecycleclass.md)
