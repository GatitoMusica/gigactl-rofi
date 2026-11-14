# Installation

## Current release state

GigaControl Plasma is under active development. The repository does not yet
provide an AUR package, distro package or published release artifact. The
instructions below build and install the widget for the current user.

## Requirements

Build dependencies:

- KDE Plasma 6 development files
- CMake 3.20 or newer
- A C++17 compiler
- ECM 6.0 or newer
- Qt 6.5 or newer, with Core, QML and D-Bus development components

Runtime dependencies:

- KDE Plasma 6
- The upstream gigactld system service
- The upstream gfan command
- Hardware supported by the installed upstream gigactl version

## Build and install for the current user

From the root of the repository:

    cmake -S . -B build -DCMAKE_INSTALL_PREFIX="$HOME/.local"
    cmake --build build
    cmake --install build

Open Plasma's widget selector, search for **GigaControl**, and add it to a
panel. If Plasma was already running during installation and does not list the
widget, reload the Plasma shell or sign in again.

The CMake install prefix must be used consistently. The example installs the
widget, its QML module and icon under ~/.local; it does not need sudo and
does not install or configure the upstream system daemon.

## Install the daemon

Install gigactld separately by following the instructions in the
[upstream repository](https://github.com/smairio/gigactl). The service must be
running for telemetry and controls to be available in the applet. GigaControl
does not install privileged policy, change kernel modules or create local
sudoers rules.

## Uninstallation

Use the same build directory and install prefix as for installation:

    cmake --build build --target uninstall

This removes the files listed in that build's CMake install manifest. It does
not uninstall or stop the upstream daemon.
