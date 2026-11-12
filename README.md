# GigaControl

A native KDE Plasma 6 widget for monitoring and managing fan
performance and RGB keyboard backlighting on supported
Gigabyte laptops.

GigaControl provides a compact, permanently accessible interface
through the KDE Plasma panel.

## Project status

**Status: Early development**

The project is transitioning from experimental Rofi and PySide6
prototypes to a native KDE Plasma 6 Plasmoid.

The previous prototypes are preserved in `archive/` for reference.

The new interface and hardware integration are not yet implemented.

## Goals

- Provide a native KDE Plasma system panel widget.
- Offer a compact popup accessible directly from the Plasma panel.
- Monitor CPU and GPU temperatures.
- Display fan speed (RPM) and duty percentage.
- Provide fan control and firmware automatic mode restoration.
- Manage RGB keyboard power, brightness and colors.
- Keep the interface lightweight and visually consistent with KDE.
- Provide configurable application preferences.

## Application design

The application will have three main sections:

| Section | Purpose |
|---|---|
| Cooling | Temperature monitoring and fan control |
| RGB Keyboard | Keyboard backlight management |
| Settings | Application preferences and behavior |

The popup will open directly on Cooling.

The system tray / Plasma panel icon will use a native KDE icon
from the installed icon theme rather than a custom image.


## Technology

### Interface

- KDE Plasma 6
- QML
- Qt Quick
- Plasma Components

### Hardware integration

- `gfan`
- `gkbd`
- Plasma-compatible command execution

The QML interface will handle presentation, navigation and
user interaction.

Hardware operations will be delegated to the existing
command-line utilities.

The initial implementation will investigate Plasma's
`Plasma5Support.DataSource` as a command execution mechanism.

A separate Python backend is not required for the initial version.

GigaControl will never implement its own Embedded Controller
communication protocol.


## Hardware compatibility

Initial development and testing are focused on a Gigabyte G5 KF.

Current local testing:

- Fan temperature readings: tested.
- Fan duty readings: tested.
- Fan RPM readings: tested.
- RGB keyboard: preliminary operations tested successfully.
- Manual fan speed writes: further validation required.

These observations do not establish official hardware compatibility.

See [docs/HARDWARE.md](docs/HARDWARE.md) for more information.

## Original project

GigaControl is an independent companion project for:

[smairio/gigactl](https://github.com/smairio/gigactl)

It uses the original project's `gfan` and `gkbd` utilities
as external hardware interfaces.

GigaControl is not an official Gigabyte application or an
official component of the original project.

## Repository structure

```text
gigactl-rofi/
├── archive/
│   ├── rofi-prototype/
│   └── pyside6-prototype/
│
├── docs/
│
├── plasma/
│   └── package/
│       ├── metadata.json
│       └── contents/
│           ├── config/
│           │   └── main.xml
│           └── ui/
│               └── main.qml
│
├── tests/
│
├── .gitignore
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

The structure above describes the intended architecture.
Some directories and components are still under development.

## Development environment

Initial development is being performed on:

- Laptop: Gigabyte G5 KF
- Operating system: CachyOS
- Desktop environment: KDE Plasma 6

Development will use Visual Studio Code.

## Safety

Hardware operations will remain delegated to the original
`gfan` and `gkbd` utilities.

The application must preserve upstream safety checks and
hardware compatibility restrictions.

Monitoring should be read-only.

Hardware changes must always be explicit user actions.

See [docs/SAFETY.md](docs/SAFETY.md).

## License

GigaControl is licensed under the GNU General Public License
v3.0 only.

See [LICENSE](LICENSE).
