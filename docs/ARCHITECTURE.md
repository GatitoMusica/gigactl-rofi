# Architecture

## Overview

`gigactl-rofi` is designed as a lightweight graphical frontend for the
existing `gfan` and `gkbd` command-line utilities.

The application will use Rofi Script Mode for menu presentation and
navigation. Bash will handle application flow, configuration and the
invocation of external commands.

The project will not implement the laptop's Embedded Controller protocol.

## High-level data flow

```text
                    User
                     |
                     v
                Rofi interface
                     |
                     v
                  main.sh
                     |
          +----------+----------+
          |          |          |
          v          v          v
       cooling    keyboard   settings
        module     module     module
          |          |
          +-----+----+
                |
                v
          hardware.sh
                |
         +------+------+
         |             |
         v             v
        gfan          gkbd
         |             |
         +------+------+
                |
                v
       Original gigactl
       hardware backend
                |
                v
       Laptop Embedded
        Controller (EC)
```

The diagram represents the intended architecture. Not all components
have been implemented yet.

## Directory responsibilities

### `src/main.sh`

Application entry point.

Responsibilities:

- Start the main menu.
- Handle navigation between sections.
- Dispatch selections to the appropriate module.
- Preserve navigation state.
- Handle application exit.

### `src/modules/`

Contains the individual menu sections.

- `cooling.sh`: fan monitoring and fan controls.
- `keyboard.sh`: keyboard backlight controls.
- `settings.sh`: visual and application preferences.

Each module should focus on its own interface and user actions.

### `src/lib/`

Contains reusable application functions.

- `common.sh`: shared utilities and validation.
- `rofi.sh`: Rofi menu generation and interaction helpers.
- `hardware.sh`: controlled invocation of the external hardware utilities.

Hardware-specific communication must remain outside this library.
The library must call `gfan` and `gkbd`, not reproduce their EC logic.

### `src/themes/`

Contains Rofi theme definitions.

The initial theme will be `tokyo-midnight.rasi`.

### `config/`

Contains default application configuration:

- `fans.conf`: fan-related interface preferences.
- `colors.conf`: keyboard color presets.
- `settings.conf`: general application settings.

Machine-specific preferences should not be committed to the public
repository.

### `tests/`

Contains tests for menu navigation and configuration handling.

The `tests/mocks/` directory will provide mock implementations of
`gfan` and `gkbd`, allowing application logic to be tested without
changing hardware state.

## Hardware integration

The application will interact with the hardware exclusively through
the installed command-line utilities:

- `gfan`
- `gkbd`

These tools are responsible for their own hardware checks, permissions,
locking, daemon communication and EC operations.

The frontend must not:

- Write directly to EC registers.
- Invoke `ec_probe` to implement its own hardware protocol.
- Bypass the original model checks.
- Replace or weaken the safety checks provided by the original tools.
- Assume that every version of the original tools has identical behavior.

The frontend should check that the required commands exist before
attempting to use them.

## Rofi interaction model

The intended interface uses Rofi Script Mode.

The application will separate:

1. Menu rendering.
2. Selection identification.
3. Navigation state.
4. Hardware action execution.
5. Error reporting.

Menu entries should use stable internal identifiers rather than relying
on their visible labels.

This allows labels and theme presentation to change without breaking
the application's navigation logic.

## Configuration

Configuration will be separated from application logic.

Defaults will be stored in the repository under `config/`.

User-specific configuration will eventually be stored under:

```text
~/.config/gigactl-rofi/
```

Application resources will eventually be installed under:

```text
~/.local/share/gigactl-rofi/
```

The command-line launcher will eventually be available under:

```text
~/.local/bin/
```

The development repository must remain separate from the installed
application files.

## Safety and error handling

Hardware operations must be explicit user actions.

Opening a menu or navigating between sections must never change fan
speeds, keyboard colors or brightness.

Before invoking a hardware command, the frontend should:

- Verify that the required executable is available.
- Validate the requested operation and its arguments.
- Invoke the command without shell `eval`.
- Capture the exit status and relevant error output.
- Inform the user when the operation fails.

Tests should use mock commands by default. Real hardware tests must be
performed separately and deliberately.

## Development stages

1. Implement navigation and menu rendering.
2. Test navigation with mock commands.
3. Add read-only fan status and monitoring.
4. Integrate fan control actions.
5. Integrate keyboard backlight actions.
6. Add user configuration and installation.
7. Validate behavior and document hardware testing.