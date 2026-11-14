# Safety

GigaControl Plasma is a graphical client for the upstream gigactld service.
The daemon owns Embedded Controller access and remains responsible for
hardware model checks, authorization, locking and write verification.

## Rules followed by the frontend

- Monitoring is read-only and runs only while the popup is open.
- Fan profiles, keyboard settings and Turbo Boost change only after a user
  action.
- The applet does not implement EC register access or its own EC protocol.
- Hardware controls are disabled when the daemon is unavailable.
- Daemon and command errors are surfaced to the user.
- The frontend does not request, store or embed an administrator password.

Install and configure gigactld using the upstream project's instructions.
Do not add unrestricted sudoers rules for the Plasmoid.

## Fan control

Fan profile requests are sent to gigactld over system D-Bus. Use the
**Auto (firmware)** profile to return fan management to the laptop firmware.
The daemon's state is authoritative; check the status after a profile change.

## Keyboard controls

Keyboard power, brightness and color requests are sent to gigactld. The
frontend accepts explicit user selections and reports daemon errors.

## Turbo Boost

The switch changes the state exposed by gigactld. Other CPU management
software or firmware policies may enforce a different state later. The widget
displays this limitation next to the control.
