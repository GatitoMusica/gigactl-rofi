# GigaControl - Project Status

Last updated: 2026-11-12

## 1. Project vision

GigaControl is a lightweight desktop utility for managing fan
monitoring, fan control and RGB keyboard backlighting on Gigabyte
G-series laptops running Linux.

The main objective is to provide a permanently accessible system
tray application in KDE Plasma.

The user should be able to open a compact popup from the system tray
and manage everything inside that single interface.

No external terminal windows should be required.

## 2. Technology decision

The original Rofi-based interface was implemented as a navigation
prototype.

The project direction has now changed:

- Python
- PySide6 / Qt
- QSystemTrayIcon
- Custom QWidget popup
- QTimer for periodic hardware monitoring
- QSS for the Tokyo Midnight-inspired visual theme

Rofi remains a functional prototype, but Qt will be the target for
the main application.

Do not delete the existing prototype until its useful functionality
has been transferred or deliberately archived.

## 3. Intended application behavior

### System tray

- Permanent tray icon by default.
- Clicking the icon opens the control popup.
- Clicking outside the popup hides it.
- Closing the popup does not terminate the application.
- Right-click menu provides Settings and Exit.
- Application starts automatically after KDE login by default.

### Settings

Planned preferences:

- Start with system: ON by default.
- Keep running in background: ON by default.
- Show tray icon: ON by default.
- Appearance and theme preferences.

Autostart should eventually use XDG Autostart.

### Main popup

The popup should open directly on Cooling.

Sections:

1. Cooling
2. RGB Keyboard
3. Settings

Cooling should expose live temperatures, fan RPM and duty readings,
as well as fan controls.

RGB Keyboard should expose power, brightness, presets and custom colors.

## 4. Hardware backend

The application will use the existing external utilities:

- gfan
- gkbd

Never implement direct EC communication in GigaControl.

The original utilities must retain responsibility for hardware
access, permissions, compatibility checks and safety mechanisms.

## 5. Development hardware

Laptop: Gigabyte G5 KF
Operating system: CachyOS
Kernel recorded during initial testing: 7.3.1-1-cachyos

### Fan testing

- Temperature readings: tested successfully.
- Fan duty readings: tested successfully.
- Fan RPM readings: tested successfully.
- Manual fan speed writes: pending further validation.

### RGB testing

- Some RGB keyboard operations have been tested manually.
- Initial results appear successful.
- Full operation coverage and repeatability remain to be validated.

## 6. Permissions and daemon status

The original gigactl daemon is not installed.

D-Bus check:
- Service: io.github.smairio.gigactl
- NameHasOwner result: false

No gigactl systemd unit was found.

The current gfan direct mode relaunches itself through sudo.

### Current read-only sudoers rule

A local rule has been created:

/etc/sudoers.d/gigactl-rofi-gfan-status

It allows passwordless execution of:

/usr/local/bin/gfan ""

The rule was validated with visudo.

The following command works without prompting for a password:

sudo -n /usr/local/bin/gfan

This authorization is limited to gfan without arguments.
Do not extend permissions for fan writes or other operations without
reviewing the security implications first.

The gfan executable and shared library are owned by root:

- /usr/local/bin/gfan
- /usr/lib/gigactl/gigactl-cli-lib.sh

Their containing directories are also root-owned.

The current sudoers rule is local machine configuration and must
never be committed to the public repository.

## 7. Repository

Repository: gigactl-rofi
Visibility: Public
License: GPL-3.0-only

Original backend project:
https://github.com/smairio/gigactl

The original project uses MIT licensing.

GigaControl is an independent companion frontend and currently
uses the original utilities as external programs rather than
copying their source code.

The current repository name may need reconsideration because the
main application is moving from Rofi to Qt.

## 8. Completed work

- Public GitHub repository created.
- Local Git repository connected to GitHub.
- GPL-3.0-only license added.
- README and initial documentation created.
- Architecture and safety documentation started.
- Rofi navigation prototype implemented.
- Cooling, RGB Keyboard and Settings menus implemented.
- Tokyo Midnight initial theme created.
- Search bar removed from the prototype.
- Navigation prototype tested.
- Initial fan telemetry tested on the G5 KF.
- Restricted read-only sudoers authorization configured.

## 9. Next development steps

1. Review current Git status and commit any pending prototype work.
2. Decide whether to rename the repository to reflect the Qt application.
3. Adapt the documentation to the new application architecture.
4. Establish the Python and PySide6 project structure.
5. Implement the system tray icon.
6. Implement the popup attached to the tray icon.
7. Implement Cooling live monitoring using safe read-only operations.
8. Integrate RGB controls.
9. Design and implement fan control with an appropriate permission model.
10. Add XDG Autostart and persistent settings.
11. Refine the Tokyo Midnight visual theme.

## 10. Important development principles

- Everything must work inside one application interface.
- No external terminal windows for normal operation.
- Opening or closing the popup must never modify hardware state.
- Monitoring must be read-only.
- Hardware operations must be explicit user actions.
- Never bypass upstream hardware safety checks.
- Use mock commands for tests wherever possible.
