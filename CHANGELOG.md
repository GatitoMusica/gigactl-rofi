# Changelog

All notable changes to GigaControl will be documented in this file.

The format is based on Keep a Changelog.

## [Unreleased]

### Added

- Initial public project structure.
- GPL-3.0-only license.
- Project documentation covering architecture, hardware compatibility,
  safety, configuration and installation.
- Initial Rofi navigation prototype.
- Initial PySide6 desktop prototype.
- Development hardware testing on Gigabyte G5 KF.

### Changed

- Transitioned the application architecture from Rofi and PySide6
  to a native KDE Plasma 6 Plasmoid.
- Selected QML and Plasma Components for the application interface.
- Selected KDE's native symbolic icon system for panel integration.
- Defined popup-based navigation with Cooling, RGB Keyboard and Settings.
- Defined monitoring behavior: hardware polling runs only while
  the popup is open.
- Archived the previous Rofi and PySide6 prototypes.

### Security

- Documented hardware access restrictions and local development
  permissions.
- Established that hardware operations must continue to use
  the original `gfan` and `gkbd` utilities.
- Defined the requirement for explicit user actions before
  modifying hardware state.
