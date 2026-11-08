## Bootstrapping

A game bootstrap looks the same on server and client:

```luau
-- src/server/main.server.luau
local Arbeit = require(path.to.Arbeit)

Arbeit.addDir(script.Parent.services)  -- folder containing service modules
Arbeit.work()
```

- **`Arbeit.addDir(folder)`** registers a folder whose descendants will be scanned.
- **`Arbeit.work()`** performs the one-time boot (calling it twice is a no-op). For the full step-by-step of what it does, see the [API reference](api/arbeit.md#arbeitwork).

The exact code from this repo's own bootstrap:

```luau
-- src/server/main.server.luau
local Arbeit = require("@features/Arbeit/init")

Arbeit.addDir(script.Parent.services)
Arbeit.work()
```

```luau
-- src/client/main.client.luau (same shape on the other side)
local Arbeit = require("@features/Arbeit/init")

Arbeit.addDir(script.Parent.controllers)
Arbeit.work()
```

## How discovery works

During `work()`, every descendant `ModuleScript` of every registered folder is `require`d. A module qualifies as a provider iff:

```luau
getmetatable(module) == one of the provider decorator tables (Service | Controller | Component)
```

so returning `Service.new(...)` / `Controller.new(...)` / `Component.new(...)` from your ModuleScript *is* the decorator — there's no transpiler, no annotation step, no build output to commit.

Environment rules applied during discovery:

| Decorator | Runs on |
|---|---|
| `Service` | server only (`RunService:IsServer()`) |
| `Controller` | client only (`RunService:IsClient()`) |
| `Component` | both (tag-driven) |

Modules that fail the environment check are silently skipped rather than erroring. Additionally, if a module declares `config.studioOnly == true` and the game isn't in Studio, boot bails out — see [studioOnly config note](api/arbeit.md#studioonly-note).

## Boot order

Providers are grouped into buckets by [`config.loadOrder`](providers/service.md#loadordernumber) and processed in increasing bucket order — that's your declarative initialization order. Details in [Lifecycles ▸ scheduling semantics](lifecycles.md#scheduling-semantics).

Next: [Singleton usage →](singleton.md)
