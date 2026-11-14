# GigaControl Plasma

GigaControl Plasma is a KDE Plasma 6 widget for monitoring cooling and
controlling supported Gigabyte laptop features through the upstream
[gigactld](https://github.com/smairio/gigactl) daemon.

The widget is called **GigaControl** in Plasma. The **GigaControl Plasma**
project name distinguishes this frontend from the upstream daemon and CLI
project. The GitHub repository is GatitoMusica/gigactl-plasma.

## What it provides

- **Cooling:** CPU/GPU temperatures, fan RPM and duty, and upstream fan profile
  selection (Silent, Balanced, Performance, Maximum and Auto/firmware).
- **RGB Keyboard:** power, brightness and color controls.
- **Settings:** Turbo Boost, temperature units, monitoring interval, daemon
  information and a link to the built-in user guide.

The popup uses the active Plasma colors. Hardware controls are disabled when
gigactld is unavailable. Turbo Boost may be changed by other CPU management
software; the Settings page explains this limitation.

## Architecture

This repository contains the Plasma interface and its C++ QML plugin. The
plugin reads telemetry with the upstream gfan command and communicates with
gigactld over the system D-Bus for fan profiles, keyboard controls and Turbo
Boost. GigaControl does not implement an EC protocol; the upstream project
owns hardware access and its safety checks.

The daemon and its CLI are maintained separately in
[smairio/gigactl](https://github.com/smairio/gigactl). Install and enable
gigactld before using the widget.

## Compatibility and testing

Development and interactive testing use a Gigabyte G5 KF running CachyOS and
KDE Plasma 6. Cooling telemetry, fan profile selection, keyboard color and
brightness controls, keyboard power, and the Turbo Boost switch have been
tried through the widget on that system. This does not establish compatibility
with every G5 KF configuration or other laptop models.

See [Hardware compatibility](docs/HARDWARE.md) and the upstream project for
the current hardware support status.

## Build and install from source

There is not yet a distro package or a published release artifact. A local
user installation can be built with CMake. Requirements:

- KDE Plasma 6 and its development CMake files
- CMake 3.20 or newer and a C++17 compiler
- ECM 6.0 or newer
- Qt 6.5 or newer with Core, QML and D-Bus development components
- gigactld and the upstream gfan command at runtime

From the repository root:

    cmake -S . -B build -DCMAKE_INSTALL_PREFIX="$HOME/.local"
    cmake --build build
    cmake --install build

Then add **GigaControl** from Plasma's widget selector. The daemon and its
system integration are installed separately from the upstream project; this
build does not install a system service or change system permissions.

The CMake installation prefix can be changed when needed. Keep the same prefix
for configure, build and install so Plasma can find the QML plugin and widget.

## Repository layout

    gigactl-plasma/
    ├── docs/                         Project, installation and safety docs
    ├── plasma/package/               Widget, settings, icon and user guide
    ├── plugin/                       C++ QML plugin and D-Bus client
    ├── CMakeLists.txt                Build and install configuration
    ├── CHANGELOG.md
    ├── CONTRIBUTING.md
    └── LICENSE

## License

GigaControl Plasma is licensed under GNU GPL-3.0-only. See [LICENSE](LICENSE).
