# API: `Arbeit` (package root, `init.luau`)

```luau
local Arbeit = require(ReplicatedStorage.Packages.Arbeit)
```

All provider/lifecycle types are re-exported on the root table:

```luau
Arbeit.Service              -- type Service
Arbeit.Controller           -- type Controller
Arbeit.Component<T, Attrs>  -- type Component
Arbeit.Lifecycle<A...>      -- type Lifecycle
```

## `Arbeit.addDir(folder: Folder): ()`

Registers a Folder for scanning. Every descendant `ModuleScript` of every registered folder will be `require`d during `work()`. Call as many times as you need (server and client each have their own folders).

## `Arbeit.register(decoratorType: string, obj: any): ()`

Internal registration surface — appends `obj` to the registry bucket for `decoratorType` (e.g. `"Service"`, `"Controller"`, `"Component"`, or your own custom decorator `className`). Exposed for tooling/custom loaders; you normally never call this.

## `Arbeit.getRegistered<T>(decoratorType: string): { T }`

Returns every object registered under a decorator type. Handy for post-boot reflection — e.g. listing every discovered service:

```luau
for _, svc in Arbeit.getRegistered("Service") do
	print(svc.def, svc.config)
end
```

## `Arbeit.work(): ()`

The boot loader (idempotent — a second call returns immediately):

1. Scans each registered folder for ModuleScripts and requires them.
2. For each module whose metatable matches a provider decorator, registers it, records any `_lifecycles` it opts into, and calls its `init()` (`OnInit` fires here, synchronously).
3. Groups `Service`/`Controller` modules into buckets keyed by `config.loadOrder`.
4. Iterating buckets low → high: `task.spawn`s each `OnStart`, and subscribes every other lifecycle (`OnTick`, `OnPhysics`, `OnRender`, custom ones) to its lifecycle bucket — leaving `OnInit` and `OnDestroy` untouched.
5. `rebuildBuckets()` on every lifecycle that was referenced.
6. Wires `Heartbeat → OnTick:fireAll(dt)`, `Stepped → OnPhysics:fireAll(time, dt)` and (client only) `RenderStepped → OnRender:fireAll(dt)`.

### `studioOnly` note

If a module has `config.studioOnly == true`, `work()` returns immediately (bails the entire boot) when that module is found outside Studio — live-game suppression.

### `OnInit` / `OnDestroy` aren't scheduled by `work()`

`OnInit` runs synchronously inside step 2 as each module is discovered. `OnDestroy` is intentionally left unscheduled for services/controllers — see [Lifecycles ▸ OnDestroy is component-only](../lifecycles.md#ondestroy-is-component-only).

Related: [Lifecycles API](lifecycleclass.md) · [Types](types.md)
