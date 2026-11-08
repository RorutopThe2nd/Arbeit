# Arbeit

**Arbeit** is a lightweight, pure-Luau framework for Roblox that mirrors the developer experience of [Flamework](https://flamework.dev/) (from Roblox-TS) — but without TypeScript. Instead of `@Service()` / `@Controller()` decorators that a transpiler reads, providers are just ModuleScripts returning `Service.new(...)`, `Controller.new(...)` or `Component.new(...)`.

- **Server-only** code → a [Service](providers/service.md)
- **Client-only** code → a [Controller](providers/controller.md)
- **Tag-bound per-instance behaviour** → a [Component](providers/component.md)
- **Lifecycle opt-in** replaces `implements OnTick, ...` → see [Lifecycles](lifecycles.md)

Everything runs in `--!strict` mode with full Luau type support.

## Table of contents

| Doc | Contents |
|---|---|
| [Installation](install.md) | Installing via Wally + wiring it into your Rojo project |
| [Getting started](getting-started.md) | Bootstrapping with `addDir` + `work`, and how discovery works |
| [Singleton usage](singleton.md) | The idiomatic single-file singleton pattern, and consuming it |
| [Services](providers/service.md) | Writing a server provider (with config reference) |
| [Controllers](providers/controller.md) | Writing a client provider (with config reference) |
| [Components](providers/component.md) | Tag-driven per-instance behaviour (guards, attributes, teardown) |
| [Lifecycles](lifecycles.md) | Built-in lifecycle list, scheduling semantics, custom lifecycles |
| [API: `Arbeit` root](api/arbeit.md) | `addDir`, `register`, `getRegistered`, `work` |
| [API: `LifecycleClass`](api/lifecycleclass.md) | Building & interacting with lifecycles (`subscribe`, `fireAll`, ...) |
| [API: types](api/types.md) | `types.Partial<T>` and the re-exported type surface |
| [Flamework comparison](flamework-comparison.md) | Side-by-side for Roblox-TS users |
