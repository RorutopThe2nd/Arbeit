# Arbeit

**Arbeit** is a lightweight, pure-Luau framework for Roblox that mirrors the developer experience of [Flamework](https://flamework.dev/) (Roblox-TS) — without TypeScript. No transpiler, no decorator annotations: providers are just ModuleScripts returning a preset, and one loader call boots your game.

- **Server-only** code → a `Service`
- **Client-only** code → a `Controller`
- **Tag-bound per-instance behaviour** → a `Component`
- Lifecycle opt-in replaces `implements OnTick, ...`

Everything ships in `--!strict` mode with full Luau typing.

```luau
-- src/server/main.server.luau
local Arbeit = require(ReplicatedStorage.Packages.Arbeit)

Arbeit.addDir(script.Parent.services)
Arbeit.work()
```

```luau
-- src/server/services/EnemyService.luau
local Lifecycles = require(ReplicatedStorage.Packages.Arbeit.Lifecycles)
local Service = require(ReplicatedStorage.Packages.Arbeit.Providers.Service)

local def: Service.ServiceDef = {}

function def.OnStart()
	print("Enemy service started")
end

function def.OnTick(dt: number)
	-- runs every Heartbeat
end

return Service.new({ Lifecycles.OnStart, Lifecycles.OnTick }, def)
```

## Installation

**Wally:**

```toml
[dependencies]
Arbeit = "rorutop/arbeit@0.1.0"
```

```sh
wally install
```

Full setup (Rojo wiring into `ReplicatedStorage.Packages`) in [docs/install.md](docs/install.md).

## Documentation

| Doc | Description |
|---|---|
| [Installation](docs/install.md) | Installing via Wally + Rojo wiring |
| [Getting started](docs/getting-started.md) | `addDir` + `work`, discovery rules, boot order |
| [Singleton usage](docs/singleton.md) | The idiomatic single-file singleton pattern |
| [Services](docs/providers/service.md) | Server providers — guide + API |
| [Controllers](docs/providers/controller.md) | Client providers — guide + API |
| [Components](docs/providers/component.md) | Tag-driven per-instance behaviour — guide + API |
| [Lifecycles](docs/lifecycles.md) | Built-ins, scheduling semantics, custom lifecycles |
| [API: `Arbeit` root](docs/api/arbeit.md) | `addDir`, `register`, `getRegistered`, `work` |
| [API: `LifecycleClass`](docs/api/lifecycleclass.md) | `subscribe`, `fireAll`, custom lifecycle primitives |
| [API: types](docs/api/types.md) | `types.Partial<T>` + re-exported type surface |
| [Flamework comparison](docs/flamework-comparison.md) | Side-by-side for Roblox-TS users |

## Development

This repo is a [Rojo](https://github.com/rojo-rbx/rojo) project (generated with Rojo 7.7.1). Source lives under [`src/`](src), with the framework itself in [`src/shared/Arbeit`](src/shared/Arbeit).

To build the place from scratch:

```bash
rojo build -o "Arbeit.rbxlx"
```

Then open `Arbeit.rbxlx` in Roblox Studio and start the Rojo server:

```bash
rojo serve
```

For more help with Rojo, check out [the Rojo documentation](https://rojo.space/docs).
