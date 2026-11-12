# Architecture

## 1. Project overview

GigaControl is a native KDE Plasma 6 widget designed to provide
quick access to laptop fan monitoring, fan control and RGB keyboard
backlight management.

The application will be accessible through a symbolic icon in
the KDE Plasma panel.

Clicking the icon opens a compact popup containing the main
application interface.

The project is an independent frontend for the existing
`gfan` and `gkbd` command-line utilities.

## 2. Architecture principles

The application follows four main principles:

- Native integration with KDE Plasma 6.
- A single interface for all user interactions.
- Reuse of existing hardware utilities.
- Separation between presentation and hardware operations.

The application must not implement its own Embedded Controller
(EC) communication protocol.

## 3. High-level architecture

```text
                 KDE Plasma 6
                      |
                      v
                GigaControl
                  Plasmoid
                      |
             +--------+--------+
             |                 |
             v                 v
       QML Interface      Application
                          configuration
             |
             v
         Hardware Bridge
             |
       Plasma5Support
         DataSource
             |
       +-----+-----+
       |           |
       v           v
      gfan        gkbd
       |           |
       +-----+-----+
             |
             v
       Laptop hardware
             |
             v
       Embedded Controller
```

This describes the initial implementation approach.
The hardware communication layer may evolve if a more suitable
Plasma 6 integration method becomes available.

## 4. Plasma widget structure

The application will be implemented as a Plasma 6 Plasmoid.

Its package will contain:

- `metadata.json`: widget identity, description and icon.
- `contents/ui/main.qml`: main widget entry point.
- Additional QML components for individual sections.
- QML service components for hardware integration.

The root QML element must be `PlasmoidItem`.

### Compact representation

The compact representation will display a symbolic icon
provided by the KDE icon theme.

The initial icon will be `utilities-system-monitor`.

No custom image or logo is required for the panel icon.

### Full representation

The full representation will be the main GigaControl popup.

It will contain three sections:

1. Cooling
2. RGB Keyboard
3. Settings

The popup will be managed by Plasma rather than by a
separate desktop window.

## 5. Interface components

### Cooling

Responsibilities:

- Display CPU temperature.
- Display GPU temperature.
- Display CPU fan RPM.
- Display GPU fan RPM.
- Display fan duty percentages.
- Provide access to fan control profiles.
- Provide manual fan speed controls.
- Restore firmware automatic mode.

Monitoring will use periodic read-only queries.

### RGB Keyboard

Responsibilities:

- Display keyboard backlight state.
- Enable and disable keyboard lighting.
- Adjust brightness.
- Select predefined colors.
- Set custom hexadecimal colors.
- Restore the previously saved color.

### Settings

Responsibilities:

- Application preferences.
- Startup behavior.
- Background execution behavior.
- Panel icon visibility.
- Appearance and theme preferences.

The tray or panel icon should be enabled by default.

Automatic startup after KDE login should also be enabled by default.

## 6. Hardware integration

The application will reuse the external command-line utilities
provided by the original project:

- `gfan`
- `gkbd`

These utilities remain responsible for:

- Hardware model detection.
- Embedded Controller access.
- Hardware locking.
- Permission handling.
- Safety checks.
- Communication with the original gigactl daemon,
  when available.

The frontend must never reproduce these mechanisms.

### Initial command integration

The first implementation will investigate using
`Plasma5Support.DataSource` with the executable data engine.

A dedicated QML hardware bridge will isolate command execution
from the presentation layer.

The bridge will:

- Invoke fixed, validated commands.
- Execute operations asynchronously.
- Capture standard output and error output.
- Check exit status.
- Report unavailable commands and permission failures.
- Prevent overlapping monitoring requests.

Plasma5Support is a compatibility layer in Plasma 6.
Its use will be isolated so it can be replaced without redesigning
the complete interface if necessary.

### Monitoring

Monitoring should use periodic read-only queries.

The initial target refresh interval is two seconds.

A QML timer will schedule status requests and update the interface
when new results become available.

A long-running terminal process must not be required.

### Hardware control

Hardware changes must be explicit user actions.

The application must preserve the safety mechanisms of
the original utilities.

Monitoring permissions must not automatically grant
permission to modify fan speeds.

The initial read-only `sudoers` configuration is specific
to the development machine and must not be assumed to exist
on other installations.

A secure authorization model for hardware writes remains
to be designed.

## 7. Technology stack

### Interface

- KDE Plasma 6
- QML
- Qt Quick
- Plasma Components

### Hardware utilities

- `gfan`
- `gkbd`

### Development

- Visual Studio Code
- Git
- CachyOS
- KDE Plasma 6

A separate Python backend is not required in the initial
implementation.

It may be introduced later if the application requires
a persistent service or more complex hardware coordination.

## 8. Configuration

User preferences will be stored separately from application code.

The project will initially investigate Plasma's native
configuration facilities.

The configuration must not store:

- Passwords.
- Privileged credentials.
- Sensitive authentication information.

Machine-specific paths and settings should not be hardcoded
when a configurable alternative is appropriate.

## 9. Testing strategy

Testing will be divided into independent areas.

### Interface tests

- Widget installation.
- Panel icon visibility.
- Popup opening and closing.
- Navigation between sections.
- Appearance and resizing behavior.

### Hardware bridge tests

- Command availability.
- Standard output handling.
- Error handling.
- Exit status handling.
- Invalid argument rejection.

### Hardware tests

Testing against physical hardware must be deliberate.

Start with read-only monitoring before introducing
fan or keyboard write operations.

Mock commands should be used wherever possible.

## 10. Future development

1. Create and install a minimal Plasma 6 Plasmoid.
2. Verify the symbolic panel icon and popup.
3. Implement the main navigation.
4. Implement the hardware bridge.
5. Integrate read-only fan monitoring.
6. Integrate RGB keyboard controls.
7. Introduce safe fan control.
8. Add persistent application preferences.
9. Implement automatic startup.
10. Refine the Tokyo Midnight visual design.
