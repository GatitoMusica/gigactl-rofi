# Contributing to GigaControl Plasma

GigaControl Plasma is a native KDE Plasma 6 frontend for the upstream
gigactld daemon. Contributions, bug reports and hardware reports are welcome.

## Development setup

The project uses QML, Qt 6 and a C++ QML plugin. Build requirements are
documented in [Installation](docs/INSTALLATION.md). A local build can be
configured and installed with:

    cmake -S . -B build -DCMAKE_INSTALL_PREFIX="$HOME/.local"
    cmake --build build
    cmake --install build

The upstream gigactld service and gfan command are needed for live hardware
interaction. UI and build work should be possible without changing hardware.

## Guidelines

- Keep QML presentation separate from daemon and telemetry code.
- Use the upstream D-Bus API for fan profiles, keyboard controls and Turbo
  Boost.
- Use the upstream gfan utility for telemetry.
- Do not implement an EC protocol, direct register access or a second hardware
  authorization path.
- Preserve upstream safety checks and report errors clearly.
- Keep changes focused and avoid generated build files or local configuration.
- Add tests for new behavior when practical.

## Validation

Choose checks that match the change:

- Build the C++ QML module.
- Validate QML and inspect the applet in Plasma.
- Test daemon communication with a mock or test service when available.
- Use live hardware only for a specific, controlled check, and state what was
  tested.

Never present one laptop's result as support for every model. Hardware reports
should include the laptop model, operating system, Plasma version, GigaControl
revision, steps taken and relevant non-sensitive errors.

## Pull requests

Describe the change, affected components, validation performed and any hardware
involved. Keep unrelated changes separate. Ensure contributed code and assets
are compatible with GNU GPL-3.0-only and provide attribution for third-party
materials.
