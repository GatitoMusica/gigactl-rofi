# GigaControl — Project Status

Last updated: 2026-11-12

## 1. Project identity

Application name: GigaControl

Repository: gigactl-rofi

Visibility: Public

License: GNU GPL-3.0-only

GigaControl is an independent KDE Plasma 6 widget for managing
fan monitoring, fan control and RGB keyboard backlighting on
supported Gigabyte laptops.

The repository is currently transitioning from experimental
interfaces to a native Plasma 6 Plasmoid.

## 2. Current architecture

The selected application architecture is:

- KDE Plasma 6
- QML
- Plasma Components
- Existing `gfan` and `gkbd` command-line utilities

The system tray and popup will be managed natively by KDE Plasma.

A Python backend is not currently required for the initial version.

The hardware integration mechanism is still to be validated.

## 3. Repository organization

Previous prototypes have been moved to:

- `archive/rofi-prototype/`
- `archive/pyside6-prototype/`

These are preserved for reference and are no longer the target
application architecture.

The existing documentation, configuration and hardware tests
remain under review.

## 4. Development environment

Development machine:

- Laptop: Gigabyte G5 KF
- Operating system: CachyOS
- Desktop environment: KDE Plasma 6
- IDE: Visual Studio Code
- Shell: Fish

## 5. Hardware testing

### Fan monitoring

The following operations have been tested successfully:

- CPU temperature readings.
- GPU temperature readings.
- CPU fan duty readings.
- GPU fan duty readings.
- Fan RPM readings.

Manual fan speed writes still require further validation.

### RGB keyboard

Some RGB keyboard operations have been tested manually
on the development laptop.

Initial results have been successful, but complete operation
coverage and repeatability have not yet been validated.

### Hardware backend

The application will delegate hardware operations to:

- `gfan`
- `gkbd`

No independent EC communication protocol will be implemented.

## 6. Permissions and daemon status

The original gigactl daemon is not installed on the
development machine.

The current utilities use direct EC access and request
privileges through sudo.

A local sudoers rule has been configured to permit
passwordless execution of `gfan` without arguments
for read-only monitoring.

This configuration is specific to the development machine.

It must not be distributed as a general installation rule
or included in the public repository.

A secure authorization strategy for hardware write operations
has not yet been selected.

## 7. Completed work

- Public GitHub repository created.
- GPL-3.0-only license added.
- Initial project documentation created.
- Rofi navigation prototype implemented and tested.
- PySide6 desktop prototype implemented.
- Both prototypes moved to the archive directory.
- Project README updated for the Plasma 6 direction.
- Architecture documentation rewritten.
- Initial hardware monitoring tested on the G5 KF.
- Read-only sudoers authorization configured locally.

## 8. Current development status

The first native KDE Plasma 6 Plasmoid prototype has been
successfully implemented and tested.

Completed:

- Created the initial Plasma package structure.
- Added valid widget metadata.
- Implemented the initial QML entry point.
- Validated the QML file with `qmllint`.
- Tested the package using `plasmoidviewer`.
- Installed the widget locally using `kpackagetool6`.
- Registered GigaControl in the Plasma widget selector.
- Added the widget to the KDE Plasma panel.
- Verified popup opening and closing behavior.

The current interface only displays the initial GigaControl
popup. Navigation and hardware integration are not implemented.

## 9. Next milestones

1. Implement navigation between Cooling, RGB Keyboard and Settings.
2. Implement native KDE Plasma theme integration.
3. Validate the widget layout and behavior in Plasma.
4. Investigate safe hardware command execution.
5. Implement read-only fan monitoring.
6. Implement RGB keyboard controls.
7. Design and validate safe fan control.
8. Add persistent preferences.
9. Complete installation and release documentation.

## 10. Development principles

- Work incrementally, validating each milestone.
- Keep the interface native to KDE Plasma.
- Keep all normal interactions inside one popup.
- Do not open external terminals for normal hardware operations.
- Never modify hardware state when opening or closing the widget.
- Keep monitoring read-only.
- Require explicit user actions for hardware changes.
- Preserve upstream hardware safety checks.
- Test using mocks before physical hardware operations.
