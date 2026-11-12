# Hardware compatibility and testing

## Overview

`gigactl-rofi` is designed as a frontend for the `gfan` and `gkbd`
utilities from the original project:

https://github.com/smairio/gigactl

Hardware compatibility depends on the original utilities, the laptop
model, its Embedded Controller (EC), and the installed software version.

This document distinguishes upstream compatibility reports from local
testing performed during development.

## Upstream compatibility

The original project currently documents the following hardware status:

| Laptop model | Upstream status |
|---|---|
| Gigabyte G6 KF | Verified by the maintainer |
| Gigabyte G5 KF | Reported working by a user |
| Gigabyte G5 MF5 | Reported working by a user |
| Gigabyte G5 KF5 | Reported working by a user |
| Gigabyte G5 GE | Reported working by a user |
| Other G5 / G6 / G7 models | Expected to work, but untested |
| Other Gigabyte models | Refused by the built-in model guard |

These statuses belong to the original project and must not be confused
with independent testing of this frontend.

Always consult the upstream README for the latest compatibility details.

## Local development hardware

Initial development and testing are being performed on:

- Laptop: Gigabyte G5 KF
- Operating system: CachyOS
- Kernel recorded during initial testing: 7.3.1-1-cachyos

This is a local development environment, not a claim of universal
compatibility with every G5 KF configuration.

## Local test status

The following table records what has actually been tested locally.

| Feature | Status | Notes |
|---|---|---|
| Fan temperature readings | Tested | Temperature readings obtained successfully |
| Fan duty readings | Tested | Fan percentage readings obtained |
| Fan RPM readings | Tested | RPM readings obtained |
| Manual fan speed changes | Pending | Writes still require deliberate validation |
| RGB keyboard control | Preliminary testing | Some operations have been tried and appeared to work |
| RGB full test coverage | Pending | Individual operations and repeatability need documentation |
| Rofi interface | Not implemented | Navigation and hardware integration are pending |

Preliminary RGB testing is encouraging, but it does not establish that
every color, brightness level, power state, boot restore or suspend
restore operation works reliably.

## External utilities

The application relies on two commands supplied by the original project.

### gfan

Used for fan monitoring and control.

Examples documented by the upstream project:

```bash
gfan
gfan watch
gfan auto
gfan 70
gfan 40 90
gfan max
```

The exact behavior and safety checks depend on the installed version.

### gkbd

Used for keyboard backlight control.

Examples documented by the upstream project:

```bash
gkbd status
gkbd red
gkbd ff6600
gkbd brightness 40
gkbd off
gkbd on
```

The original utility supports named colors and hexadecimal colors.

The frontend must not assume that all installed versions expose identical
features or behavior.

## Backend operating modes

Depending on the installed `gigactl` version and configuration, the
utilities may communicate with a daemon over D-Bus or access the EC
directly.

The frontend must delegate these details to the original utilities.

It must not implement its own EC communication, locking, privilege
handling or hardware model detection.

## Compatibility policy

The frontend should:

- Check that `gfan` and `gkbd` are available.
- Report missing commands clearly.
- Preserve the original hardware model checks.
- Never bypass upstream safety mechanisms.
- Avoid claiming support for hardware that has not been tested.
- Distinguish upstream reports from local test results.

## Future testing

Before declaring hardware support more complete, test and document:

### Fans
- Read both fan temperatures, duty and RPM.
- Confirm firmware automatic mode.
- Test manual speed changes under controlled conditions.
- Confirm that automatic mode can be restored.
- Observe behavior after reboot.

### RGB keyboard
- Test named colors.
- Test custom hexadecimal colors.
- Test brightness changes.
- Test keyboard on/off.
- Test state restoration after reboot and suspend, where supported.

Every result should include the laptop model, operating system, kernel
and installed `gigactl` version whenever possible.

