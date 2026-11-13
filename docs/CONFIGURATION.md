
# Configuration

## 1. Overview

GigaControl will use the native KDE Plasma configuration
system for widget preferences.

Configuration will be managed through KConfig and exposed
to QML using `Plasmoid.configuration`.

A separate application-wide settings file is not required
for the initial implementation.

## 2. Configuration storage

The widget configuration schema will be defined in:

`contents/config/main.xml`

QML components will access stored preferences through:

`Plasmoid.configuration`

Plasma will handle persistence of widget-specific settings.

## 3. Default behavior

The initial application behavior is:

| Setting | Default behavior |
|---|---|
| Panel icon | Always available while the widget is installed |
| Popup | Opened through the panel icon |
| Monitoring | Active only while the popup is open |
| Refresh interval | 2000 milliseconds |
| Monitoring while closed | Disabled |
| Theme | Active KDE Plasma color scheme |

## 4. Monitoring lifecycle

Hardware monitoring must follow the visibility state
of the full Plasmoid representation.

When the popup opens:

- Start the monitoring timer.
- Request read-only hardware status.
- Update the displayed values when new results arrive.

When the popup closes:

- Stop the monitoring timer.
- Do not issue new periodic hardware queries.
- Preserve the last displayed values until the next opening.

Closing the popup must never terminate the widget.

## 5. KDE integration

The Plasmoid is loaded and managed by KDE Plasma.

When the widget is installed in a Plasma panel,
it becomes available as part of the user's Plasma session.

No separate application autostart entry is required
for the initial implementation.

The panel icon is part of the widget itself
and is not an independent system tray application.

## 6. Future preferences

The following options may be introduced later:

- Configurable monitoring interval.
- Alternative visual themes.
- Additional monitoring display preferences.

These options should only be added when they provide
a meaningful benefit to the user.

Avoid duplicating functionality already managed by KDE Plasma.
