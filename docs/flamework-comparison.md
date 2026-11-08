# Arbeit vs Flamework (for Roblox-TS users)

Arbeit's pitch is "Flamework but pure Luau". Here's where the concepts map.

| Flamework (Roblox-TS) | Arbeit (Luau) |
|---|---|
| `@Service()` / `@Controller()` TS decorators | Return `Service.new()` / `Controller.new()` from the ModuleScript |
| `implements OnTick, OnInit` | Lifecycle list as the first `.new()` argument: `{ Lifecycles.OnInit, Lifecycles.OnTick }` |
| `flamework.build()` transpile + pre-compilation step | `Arbeit.work()` — pure runtime `require`-scan of registered folders |
| `mod.OnTick:fireAll(...)` / event cross-listening | `Lifecycle:subscribe/unsubscribe/fireAll` on any bucket you declare (per-`loadOrder` buckets, custom lifecycles supported) |
| `@Component()` + Flint tags | `Component.new(...)` + `CollectionService` tag config (`tag`, `instanceGuard`, `attributeGuard`, `defaultAttributes`, `waitTimeout`) |
| `Partial<T>` mapped type | `types.Partial<T>` (type function) |
| `Modding.scanWorkspace` / reflections | `Arbeit.getRegistered("Service")` etc. |

## Deliberate differences

- **No transpiler step at all.** Boots straight from source: the loader requires ModuleScripts and matches their metatable against the three provider decorator tables (see [Getting started ▸ how discovery works](getting-started.md)).
- **Lifecycle opt-in is explicit and per-provider** instead of interface-implied, so which callbacks a module handles is visible at a glance on the return line.
- **Components reuse the same bucket machinery** as services/controllers rather than bringing their own runner — per-instance callbacks get merged into the same ascending-`loadOrder` frame dispatch. See [Lifecycles ▸ scheduling semantics](lifecycles.md#scheduling-semantics).
- **`OnDestroy` is component-only.** Service/Controller teardown isn't auto-fired — see [Lifecycles ▸ OnDestroy is component-only](lifecycles.md#ondestroy-is-component-only).
- **Built-in `Trove` and `Sparse` utilities** ship under `Arbeit/Utils` ([Trove](../src/shared/Arbeit/Utils/Trove.luau), [SparseSet](../src/shared/Arbeit/Utils/Sparse.luau)) for cleanup and fast callback-list add/remove.

Back to [index](index.md).
