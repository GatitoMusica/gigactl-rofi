# Architecture

## Overview

GigaControl Plasma is a native KDE Plasma 6 applet. QML presents the Cooling,
RGB Keyboard and Settings pages. A C++ QML module separates the interface from
the daemon and telemetry calls.

    KDE Plasma 6
        |
        +-- GigaControl QML applet
                |
                +-- org.gigactl.hardware QML module
                        |
                        +-- HardwareController -- gfan status query
                        |
                        +-- GigactlDaemonClient -- system D-Bus -- gigactld
                                                                   |
                                                                   +-- EC access

The hardware daemon and CLI utilities are maintained by
[smairio/gigactl](https://github.com/smairio/gigactl). This repository does
not implement the EC protocol.

## Components

### Plasma package

plasma/package contains the Plasmoid metadata, QML interface, configuration
schema, symbolic icon and English user guide. Plasma owns the applet lifecycle,
panel representation and popup.

The popup has three pages:

- **Cooling:** live CPU/GPU temperatures, fan RPM and duty, plus the upstream
  profile selector.
- **RGB Keyboard:** keyboard power, brightness and color controls.
- **Settings:** Turbo Boost, temperature unit, refresh interval, daemon
  information and the user guide link.

### C++ QML module

plugin builds the org.gigactl.hardware QML module.

- HardwareController runs the read-only gfan status command asynchronously,
  parses its output and reports readings or errors to QML. The popup polls only
  while expanded and the daemon is available.
- GigactlDaemonClient connects to the upstream system D-Bus service. It reads
  daemon properties and sends supported profile, keyboard and Turbo Boost
  requests.

### Daemon and hardware

gigactld is a separate upstream dependency. It owns EC access and exposes
hardware controls over system D-Bus. The upstream gfan utility performs the
telemetry query and follows its own daemon-aware behavior and safety checks.
GigaControl does not run privileged commands or access EC registers directly.

## Monitoring and state

The Plasmoid configuration stores the temperature unit and monitoring
interval. Supported polling intervals are 2, 5 and 10 seconds. Monitoring
starts when the popup opens and stops when it closes. The UI keeps the latest
successful reading while a refresh is in progress.

The daemon's reported state is authoritative for fan profiles, keyboard
settings and Turbo Boost. When the daemon is unavailable, hardware controls
are disabled and telemetry is shown as unavailable.

## Build

The root CMakeLists.txt finds KDE ECM, Qt 6 and Plasma, builds the QML module,
and installs the Plasmoid and symbolic icon. See [Installation](INSTALLATION.md)
for requirements and commands.
