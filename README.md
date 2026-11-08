# Arbeit

Arbeit is a Luau framework for Roblox, inspired by [Flamework](https://flamework.dev/) from Roblox-TS. There is no transpiler involved: a provider is an ordinary ModuleScript that returns `Service.new(...)`, `Controller.new(...)`, or `Component.new(...)`, and `Arbeit.work()` discovers them at runtime and drives their lifecycles.

All code runs in `--!strict` Luau.

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

## Building from source

The project maintains its toolchain with [Rokit](https://github.com/rojo-rbx/rokit). Install it once, then from the repo root:

```sh
rokit install     # wally 0.3.2, rojo 7.7.1, darklua 0.19.0
wally install     # zero dependencies, but creates the Packages/ tree build.project.json expects
darklua process src dist
rojo build -o Arbeit.rbxlx
```

`build.project.json` compiles `dist/` into a place — it's for developing the library against its own demo scripts (`ECSService`, `ECSController`), not something you need as a consumer.

The toolchain is defined in [`rokit.toml`](rokit.toml); adjust it with `rokit add <tool>`.

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
