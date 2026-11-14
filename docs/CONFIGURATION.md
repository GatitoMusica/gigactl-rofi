# Configuration

GigaControl stores widget preferences through Plasma's per-applet
configuration. The schema is in
plasma/package/contents/config/main.xml; QML reads and updates it through
Plasmoid.configuration.

## Current preferences

| Preference | Values | Default |
|---|---|---|
| Temperature unit | Celsius or Fahrenheit | Celsius |
| Monitoring interval | 2, 5 or 10 seconds | 2 seconds |

Monitoring runs while the popup is open and gigactld is available. It stops
when the popup closes. Settings are stored by Plasma for each widget instance.

The Turbo Boost switch reflects the daemon's current state; it is a hardware
control rather than a saved Plasmoid preference. Other CPU management software
may change that state after GigaControl applies it.
