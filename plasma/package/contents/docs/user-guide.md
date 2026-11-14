# GigaControl User Guide

GigaControl monitors cooling and controls the fan profiles, Turbo Boost, and
single-zone RGB keyboard lighting on supported Gigabyte laptops.

## Getting started

The `gigactld` system service must be installed and running for live readings and
hardware controls. If **Control Service** says **Unavailable**, the applet
cannot reach the service; ask the system administrator to check its
installation and status. After the one-time administrator installation, a user
with an active desktop session can normally use the controls without entering an
administrator password.

The applet keeps the last successful sensor reading on screen while it fetches
the next one. A **Monitoring error** means a refresh failed; the displayed
reading may then be from the previous successful refresh.

## Cooling

- **CPU Temperature** and **GPU Temperature** show the latest readings in the
  unit selected under Settings.
- **CPU Fan** and **GPU Fan** show fan speed in RPM and reported fan duty as a
  percentage. RPM is the measured rotation speed; duty is the fan drive level.
- **Fan Profile** selects the fan-control behavior. A selected profile is applied
  immediately and saved by the service.

  - **Silent** uses a gentler fan curve to reduce noise.
  - **Balanced** uses an intermediate curve for everyday use.
  - **Performance** increases fan duty more quickly as temperatures rise.
  - **Maximum** requests full fan duty.
  - **Auto (firmware)** hands both fans back to the laptop firmware's automatic
    fan curve.

If the profile selector is disabled or says **Daemon unavailable**, the service
is not connected. **EC Status** and **Daemon error** provide more detail when the
service reports a problem.

## RGB Keyboard

The keyboard uses single-zone lighting, so one color applies to the whole
keyboard.

- **Keyboard on/off** enables or disables the backlight.
- **Choose color** opens the color picker. The hexadecimal value below the
  preview shows the selected color.
- **Brightness** ranges from 0% to 100%. The percentage follows the slider while
  it moves; the chosen value is sent when you release it.

Changing the color or brightness turns the keyboard lighting on. The service
remembers the keyboard state and restores it at startup and resume.

## Settings

### Performance

**Turbo Boost** allows the CPU to run above its base frequency for short bursts.
Disabling it can reduce peak performance, heat, and fan noise. Other system
utilities may also manage Turbo Boost and can override this switch; if its state
changes unexpectedly, check for another CPU or power-management tool.

If the control is unavailable, this system does not expose a Turbo Boost switch
that GigaControl can use.

### Monitoring

- **Temperature unit** changes how temperatures are displayed; it does not
  change hardware behavior.
- **Update interval** sets how often readings refresh while the applet is open
  and connected to `gigactld`. A longer interval means fewer refreshes.

### Daemon and system status

This section shows whether the control service is connected, its version, and
whether the Embedded Controller is ready. Any reported service error appears
below the status.
