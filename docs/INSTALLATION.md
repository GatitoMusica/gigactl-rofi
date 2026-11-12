# Installation

## 1. Project status

GigaControl is currently in early development.

The native KDE Plasma 6 Plasmoid is not yet implemented.
Therefore, a complete end-user installation procedure
is not currently available.

These instructions describe the intended development
environment and future installation process.

## 2. Requirements

### Desktop environment

- Linux
- KDE Plasma 6
- Compatible Qt 6 and QML runtime

### Development tools

- Visual Studio Code (recommended)
- Git
- KDE Plasma development tools
- QML development support

### Hardware utilities

The application will use the following utilities
from the original gigactl project:

- `gfan`
- `gkbd`

These utilities must be installed separately.

Original project:

https://github.com/smairio/gigactl

## 3. Development environment

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/gigactl-rofi.git
cd gigactl-rofi
```

Open the project directory in Visual Studio Code.

The current development environment is CachyOS
with KDE Plasma 6.

## 4. Local Plasmoid installation

The widget will eventually be installable locally
using KDE's Plasma package management tools.

The exact installation command and required dependencies
will be documented after the first working Plasmoid
has been validated.

Development installation instructions must be tested
on KDE Plasma 6 before publication.

## 5. Adding the widget to the panel

Once installed, GigaControl should be available
in KDE Plasma's widget selector.

The user will be able to add it to a Plasma panel
and access the popup through its symbolic icon.

## 6. Hardware permissions

Hardware permissions must be handled separately
from the Plasmoid installation.

GigaControl must not automatically modify system
permissions or install unrestricted sudoers rules.

The application must preserve the original utilities'
hardware compatibility checks and safety mechanisms.

## 7. Uninstallation

The final installation procedure will include
instructions for removing the Plasmoid without
deleting user configuration or modifying unrelated
KDE Plasma settings.

These instructions will be added once the installation
method has been implemented and tested.
