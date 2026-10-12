<div align="center">

<img src="shared-color-ui/icons/shared_color.png" alt="Logos Shared Color logo" width="128" height="128">

# Logos Shared Color

</div>

Pick a colour from a palette and every peer's background changes to match. The colour is synced peer-to-peer over Logos Messaging (`logos-delivery-module`). It's a small end-to-end example of the messaging pattern for [Logos Basecamp](https://logos.co), and a good template to copy.

## Quick start

Download `shared-color-core` and `shared-color-ui` `.lgx` files from [Releases](https://github.com/hackyguru/logos-shared-color/releases) and install them in Basecamp (core first) via **Modules → Install LGX Package**. To build them yourself, read on.

## Prerequisites

- [Nix](https://nixos.org/download/) with flakes enabled (`experimental-features = nix-command flakes` in `~/.config/nix/nix.conf`)
- [Logos Basecamp](https://github.com/logos-co/logos-basecamp/releases)

The first build pulls the whole `logos-delivery-module` closure (Nim, libp2p, zerokit, libpq), so budget 15–30 minutes. Later builds take seconds.

## What's here

- [`shared-color-core/`](shared-color-core/): `core` module (C++) that publishes and subscribes to colour changes through `delivery_module`.
- [`shared-color-ui/`](shared-color-ui/): `ui_qml` module (QML) with the palette. Edit the palette list at the top of [`Main.qml`](shared-color-ui/Main.qml).

`core` modules are C++ Qt plugins that expose `Q_INVOKABLE` methods; they run in the background and have no UI. `ui_qml` modules are QML-only sidebar tabs that call into core modules via `logos.callModule(...)`.

## Build

```bash
cd shared-color-core
nix flake update        # first time only
nix build '.#lgx-portable' --out-link result-portable

cd ../shared-color-ui
nix build --override-input shared_color path:../shared-color-core '.#lgx-portable' --out-link result-portable
```

## Install in Basecamp

Each build produces an `.lgx` file at `result-portable/*.lgx`. In [Logos Basecamp](https://github.com/logos-co/logos-basecamp/releases), open **Modules → Install LGX Package** and pick the file. Install the core first, then the UI. `delivery_module` is pre-installed in Basecamp.

## Try it with two instances on one machine

Each instance needs its own P2P ports. The core reads `SHARED_COLOR_TCPPORT`: unset uses 60000/9000 (TCP/UDP), `60001` uses 60001/9001, and the two instances dial each other directly over loopback.

```bash
open -n "/Applications/LogosBasecamp.app"
open -n "/Applications/LogosBasecamp.app" --env SHARED_COLOR_TCPPORT=60001
```

Between runs, kill leftovers so stale `logos_host` processes don't hold old libraries:

```bash
pkill -9 -f "LogosBasecamp.bin"; pkill -9 -f "logos_host"
```
