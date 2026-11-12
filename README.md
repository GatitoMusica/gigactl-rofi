# gigactl-rofi

A lightweight Rofi interface for managing fan control and RGB keyboard
backlighting on supported Gigabyte G-series laptops running Linux.

`gigactl-rofi` is an independent companion project for
[`smairio/gigactl`](https://github.com/smairio/gigactl).

It aims to provide an accessible graphical menu on top of the existing
`gfan` and `gkbd` command-line utilities.

> **Project status: Early development**
>
> The repository currently contains the initial project structure and
> documentation. The interface is not yet functional. Do not use it to
> control hardware until the relevant features have been implemented
> and tested.

## Goals

- Provide a simple Rofi-based interface.
- Organize fan and keyboard controls into separate menus.
- Offer fan monitoring and access to the existing fan profiles and controls.
- Provide RGB keyboard presets, brightness and custom colors.
- Keep user preferences and visual settings configurable.
- Avoid implementing or duplicating the laptop's Embedded Controller protocol.
- Keep the interface lightweight and suitable for Linux desktop environments.

## Planned interface

The main menu will provide three sections:

| Section | Purpose |
|---|---|
| Cooling | Fan monitoring and fan control |
| RGB Keyboard | Backlight power, brightness and colors |
| Settings | Appearance and application preferences |

The visual theme will initially be based on a Tokyo Midnight-inspired
dark palette.

## Architecture

The application will use the existing command-line tools as its hardware
backend:

- `gfan` — fan status, monitoring and fan control.
- `gkbd` — keyboard backlight status, color and brightness.

The Rofi interface will invoke these utilities rather than communicating
directly with the Embedded Controller (EC).

This keeps hardware-specific operations and their safety checks within
the original project.

See [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for more details.

## Requirements

Planned runtime requirements:

- Linux
- Bash
- Rofi (Script Mode)
- `gfan` and `gkbd` from the original `gigactl` project

The exact dependency versions and installation instructions will be
documented once the first working version is available.

The original `gigactl` utilities may have additional requirements depending
on their version and operating mode.

## Hardware compatibility

The original project documents the Gigabyte G6 KF as maintainer-verified
and the Gigabyte G5 KF as reported working by a user.

Hardware compatibility must not be assumed solely because the laptop
belongs to the G5/G6 family.

Development and testing are initially focused on a Gigabyte G5 KF.

Local test status:

- Fan temperature, duty and RPM readings have been tested.
- Manual fan speed changes still require deliberate validation.
- Some RGB keyboard operations have been tried and appeared to work,
  but full operation coverage and repeatability are not yet documented.
- The Rofi interface is not implemented yet.

These are local development observations, not maintainer-verified
hardware compatibility claims. See
[docs/HARDWARE.md](docs/HARDWARE.md) for the test matrix and details.

Check the original project's documentation for its current compatibility
information:

https://github.com/smairio/gigactl

## Development

Clone the repository:

```bash
git clone https://github.com/YOUR_USERNAME/gigactl-rofi.git
cd gigactl-rofi
```

Replace `YOUR_USERNAME` with the GitHub account that hosts the repository.

The current development plan is:

1. Implement menu navigation without hardware actions.
2. Add mock versions of `gfan` and `gkbd` for safe tests.
3. Integrate fan monitoring and controls.
4. Integrate keyboard backlight controls.
5. Add persistent settings and installation scripts.
6. Validate safety and hardware behavior.

## Safety

This application interacts with utilities that can modify laptop hardware
behavior.

- Never bypass hardware compatibility checks.
- Do not implement direct EC writes in this project.
- Do not invoke hardware commands through `eval`.
- Do not silently change fan settings when opening the interface.
- Preserve the original utilities' safety mechanisms.
- Test application logic with mocks before testing on physical hardware.

Use the original `gigactl` project for hardware-specific instructions,
warnings and compatibility information.

## Relationship with gigactl

`gigactl-rofi` is an independent interface project, not an official
component of `smairio/gigactl`.

The original `gigactl` project is distributed under the MIT License.
This project does not currently copy or redistribute its source code;
it invokes the installed command-line utilities as external programs.

Original project:
https://github.com/smairio/gigactl

## License

This project is licensed under the GNU General Public License v3.0 only.
See [LICENSE](LICENSE) for the complete license text.