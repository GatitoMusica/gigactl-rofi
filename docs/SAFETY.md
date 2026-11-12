# Safety guidelines

## Purpose

GigaControl is a native KDE Plasma 6 widget that provides an
interface for monitoring and controlling laptop fans and
keyboard backlighting.

The application interacts with existing hardware utilities
without implementing its own Embedded Controller (EC) protocol.

The project must prioritize safe hardware interaction over convenience.

The original `gigactl` utilities remain responsible for all
Embedded Controller (EC) operations and hardware-specific safeguards.

## Core principles

1. Never implement direct EC writes in this project.
2. Never bypass the original hardware compatibility checks.
3. Never weaken or replace upstream safety mechanisms.
4. Never execute hardware actions just by opening or navigating a menu.
5. Validate every argument before invoking an external command.
6. Report failures instead of silently assuming an operation succeeded.
7. Test application logic with mocks before testing physical hardware.

## Hardware access

The frontend must use the installed command-line utilities:

- `gfan`
- `gkbd`

It must not:

- Write directly to EC registers.
- Implement the EC mailbox protocol.
- Invoke `ec_probe` to create an alternative hardware backend.
- Modify kernel interfaces or EC permissions automatically.
- Circumvent model checks or command safety limits.

Do not use unsafe overrides such as `GFAN_UNSAFE=1` or `GKBD_UNSAFE=1`
from the frontend.

## Fan control

Fan control can affect laptop temperatures and hardware behavior.

The application must:

- Make fan changes explicit user actions.
- Clearly show which fan is being changed.
- Validate percentage values before execution.
- Keep values within the range supported by the installed utility.
- Preserve upstream temperature safeguards.
- Provide an explicit way to restore firmware automatic mode.
- Report whether the command completed successfully.

The frontend must not silently select a low fan speed.

It must not expose upstream force overrides as ordinary interface
controls.

Opening the application, switching menus or refreshing status must
never change fan speeds.

Monitoring should be read-only.

## RGB keyboard control

Keyboard backlight operations are delegated to `gkbd`.

The application must validate:

- Named color values against supported options.
- Hexadecimal colors before passing them to the utility.
- Brightness values against the supported range.
- Power actions against the supported command set.

RGB operations should only run after an explicit user selection.

The frontend must not assume that a command succeeded merely because
it was launched. It must inspect the command exit status and present
errors when appropriate.

## Permissions and privileges

The application must never:

- Embed administrator passwords.
- Request or store passwords inside the Plasmoid.
- Silently invoke privileged operations.
- Attempt to bypass system authorization mechanisms.

Hardware utilities must handle their own privilege requirements.

Any authorization mechanism introduced by GigaControl must
be explicitly documented and designed with least privilege.

Development-machine permissions must not be assumed to exist
on other installations.

Local sudoers rules must never be distributed as general
installation configuration.

## Command execution safety

All hardware commands must be executed through a controlled
command execution layer.

The application must:

- Use fixed executable paths or validated executable discovery.
- Accept only explicitly supported commands.
- Validate every argument before execution.
- Never evaluate arbitrary shell expressions.
- Never construct executable commands from untrusted user input.
- Avoid passing unrestricted user input to external utilities.
- Handle command output and exit status independently.
- Prevent overlapping hardware operations where necessary.
- Apply timeouts to operations that could otherwise remain blocked.

## Error handling

The application should detect and report:

- Missing `gfan` or `gkbd`.
- Permission errors.
- Unsupported hardware.
- Invalid arguments.
- Failed command execution.
- Unexpected command output.

A failed operation must not be reported as successful.

The application should not repeatedly retry a failed hardware write
without user intervention.

## Testing strategy

### Unit and navigation tests

Use mock implementations of `gfan` and `gkbd`.

These tests must not access physical hardware.

### Read-only hardware tests

Start with status and monitoring commands.

Check that values are displayed correctly and that refreshing the
interface does not modify hardware state.

### Write-operation tests

Test one operation at a time.

For fan controls, monitor temperatures and confirm that firmware
automatic mode can be restored.

For RGB controls, test individual operations and verify that the
result matches the requested state.

Do not combine several unverified hardware operations into one test.

### Plasmoid interface tests

Test the native KDE Plasma widget independently from hardware.

Verify:

- Widget installation and removal.
- Panel icon visibility.
- Popup opening and closing.
- Navigation between application sections.
- Behavior when the popup loses focus.
- Correct handling of unavailable hardware utilities.

These tests must not modify hardware state.

### Regression tests

After hardware integration changes, run the mock-based test suite again.

## Recovery

If fan behavior becomes unexpected during manual testing:

1. Stop further experiments.
2. Restore firmware automatic control with the original utility's
   supported automatic-mode command, when available.
3. Check temperatures and fan readings.
4. Follow the original project's recovery instructions if the command
   does not work as expected.

Do not assume that the frontend can recover hardware behavior if the
underlying utility or EC has stopped responding.

## Disclaimer

This project is an independent frontend and is not an official
Gigabyte utility.

Hardware behavior may differ between laptop models, firmware versions,
kernel versions and backend configurations.

Use the original `gigactl` documentation for hardware-specific
warnings and compatibility information.

Hardware operations are performed at the user's own risk.

