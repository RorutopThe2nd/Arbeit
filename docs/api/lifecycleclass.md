# API: `LifecycleClass` (`LifecycleClass.luau`) → `Lifecycle<A...>`

The typing/primitive used for every lifecycle, incl. custom ones:

```luau
local LifecycleClass = require(path.to.Arbeit.LifecycleClass)
```

## `LifecycleClass.new<A...>(name: string): Lifecycle<A...>`

Builds a bucket-aware lifecycle. The preset `Lifecycles.*` table is just seven of these:

```luau
Lifecycles.OnInit           -- Lifecycle<() -> ()>
Lifecycles.OnComponentInit  -- Lifecycle<() -> ()>
Lifecycles.OnStart          -- Lifecycle<() -> ()>
Lifecycles.OnTick           -- Lifecycle<(dt: number) -> ()>
Lifecycles.OnPhysics        -- Lifecycle<(time: number, dt: number) -> ()>
Lifecycles.OnRender         -- Lifecycle<(dt: number) -> ()>
Lifecycles.OnDestroy        -- Lifecycle<() -> ()>
```

The `name` string corresponds to the def-table key the loader matches callbacks against (`def[name]`), so a custom lifecycle's name must match its def method's name to actually hook up.

## Methods

| Method | Signature | Behaviour |
|---|---|---|
| `initBucket` | `(self, bucket: number)` | Lazily creates a bucket (a `SparseMap` of callbacks). Called by the Component loader during `init` for the configured `loadOrder`. |
| `subscribe` | `(self, bucket: number, fn: (A...) -> ())` | Adds `fn` to a bucket. Used by the loader per-`loadOrder` and by Component instances per tagged instance. |
| `unsubscribe` | `(self, bucket: number, fn: (A...) -> ())` | Removes `fn`; asserts the bucket and entry exist. Used on tag removal (no dangling listeners when a tag churns). |
| `fireAll` | `(self, ...: A...)` | Walks buckets in ascending index order; each callback gets its own `task.spawn` and `pcall` (`warn` on error). |
| `rebuildBuckets` | `(self)` | Recomputes the sorted bucket-index list. The loader calls it once boot completes. |

## `fireAll` semantics

```
for each bucket in ascending bucket-index order:
	for each entry in the bucket's dense list:
		task.spawn(pcall-callback, ...)
		on error: warn(`Lifecycle {self.name} callback error: {err}`)
```

- Per-callback isolation: one poisoned callback can't break the frame or its neighbours.
- Dispatch across buckets is ordered; within a bucket, insertion order (dense-list order), which shifts as entries are removed/added (sparse-map swap pattern — not insertion-stable).

## Underlying storage

Callbacks are stored in a [sparse set](../Utils/Sparse.luau) (`SparseMap`), the standard layout for fast add/remove of identically-typed callbacks — which is what powers cheap per-instance unsubscribe on tag churn.

Related: [`Arbeit` root API](arbeit.md) · [Lifecycles guide](../lifecycles.md)
