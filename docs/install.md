## Installing via Wally

Arbeit is published to the public Wally index as **`rorutop/arbeit`** (realm: `shared`).

### 1. Add the dependency

In `wally.toml`:

```toml
[dependencies]
Arbeit = "rorutopthe2nd/arbeit@0.1.0"
```

### 2. Install

```sh
wally install
```

### 3. Wire it into Rojo

Wally packages install under `ReplicatedStorage.Packages` by default. Reference it in your `.project.json`:

```jsonc
{
  "ReplicatedStorage": {
    "Packages": {
      "$className": "Folder",
      "Arbeit": {
        "$path": "Packages/Arbeit"
      }
    }
  }
}
```

### 4. Require it

```luau
local Arbeit = require(ReplicatedStorage.Packages.Arbeit)
```

The package root (`init.luau`) exposes the four types you mostly work with:

```luau
export type Service = Service.Service
export type Controller = Controller.Controller
export type Component<T, Attrs> = Component.Component<T, Attrs>
export type Lifecycle<A...> = LifecycleClass.Lifecycle<A...>
```

For provider constructors & lifecycle presets, require the sub-modules directly (more convenient than walking the package root):

```luau
local Arbeit = require(ReplicatedStorage.Packages.Arbeit)
local Lifecycles = require(ReplicatedStorage.Packages.Arbeit.Lifecycles)
local Service = require(ReplicatedStorage.Packages.Arbeit.Providers.Service)
local Controller = require(ReplicatedStorage.Packages.Arbeit.Providers.Controller)
local Component = require(ReplicatedStorage.Packages.Arbeit.Providers.Component)
```

Next: [Getting started →](getting-started.md)
