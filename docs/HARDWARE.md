# Hardware compatibility and testing

## Hardware support

GigaControl Plasma depends on the hardware support provided by the upstream
[gigactl project](https://github.com/smairio/gigactl). Check its README for
the current model list and distinguish maintainer-verified hardware from
community reports. Those upstream reports do not by themselves validate this
Plasma frontend.

Development and interactive testing for this frontend have used a Gigabyte
G5 KF running CachyOS and KDE Plasma 6.

## Tested through the widget

On the development system, the following interactions have been tried with
gigactld running:

- CPU/GPU temperature, fan RPM and fan duty are displayed and refresh.
- Fan profile selection, including Balanced and Maximum, changes the active
  daemon profile.
- Keyboard color, brightness and power controls work through the interface.
- The Turbo Boost switch changes the daemon and kernel-reported state when no
  competing CPU manager re-enables it.
- When the daemon is stopped, the widget reports unavailable and clears live
  readings.

These are interactive checks on one laptop, not a compatibility guarantee or
a complete automated regression suite. Hardware write operations should be
validated carefully on each supported model.

## Runtime requirements

- KDE Plasma 6.
- The upstream gigactld system service, installed and running.
- The upstream gfan command for telemetry.
- A laptop supported by the installed upstream gigactl version.

The daemon owns EC access and applies upstream model checks and safety rules.
GigaControl does not implement its own EC communication protocol.

## Turbo Boost conflicts

Turbo Boost can also be managed by firmware controls or other software. If
another program periodically enforces its own setting, the state selected in
GigaControl may change again. Disable or reconfigure the competing control if
you want GigaControl to retain ownership of this setting.
