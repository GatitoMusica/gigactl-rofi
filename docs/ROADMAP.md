# Development Roadmap

## Project direction

GigaControl is evolving into a native KDE Plasma 6 widget.

The roadmap prioritizes a stable interface, safe hardware
integration and a maintainable project structure.

## Phase 1 — Project foundation

- [x] Create public GitHub repository.
- [x] Establish GPL-3.0-only licensing.
- [x] Create initial project documentation.
- [x] Implement Rofi navigation prototype.
- [x] Implement PySide6 desktop prototype.
- [x] Archive previous prototypes.
- [x] Define native Plasma 6 architecture.
- [ ] Finalize documentation and repository organization.

## Phase 2 — Native Plasma widget

- [ ] Create the minimal Plasma 6 Plasmoid package.
- [ ] Register the widget in KDE Plasma.
- [ ] Display a native symbolic panel icon.
- [ ] Implement the popup representation.
- [ ] Implement Cooling, RGB Keyboard and Settings navigation.
- [ ] Validate popup behavior and panel integration.

**Milestone:** GigaControl is accessible from the KDE Plasma panel.

## Phase 3 — Hardware integration foundation

- [ ] Investigate supported command execution mechanisms.
- [ ] Select a secure hardware integration approach.
- [ ] Implement controlled command execution.
- [ ] Handle command output and errors.
- [ ] Introduce mock-based integration tests.

**Milestone:** The Plasmoid can communicate with the existing
hardware utilities without compromising their safety checks.

## Phase 4 — Cooling monitoring

- [ ] Integrate read-only `gfan` status queries.
- [ ] Display CPU and GPU temperatures.
- [ ] Display CPU and GPU fan RPM.
- [ ] Display fan duty percentages.
- [ ] Implement periodic monitoring.
- [ ] Start monitoring when the popup opens.
- [ ] Stop monitoring when the popup closes.

Initial monitoring interval: 2000 milliseconds.

**Milestone:** Live fan monitoring works entirely inside
the GigaControl popup.

## Phase 5 — RGB keyboard controls

- [ ] Integrate `gkbd`.
- [ ] Display keyboard backlight status.
- [ ] Implement keyboard power controls.
- [ ] Implement brightness adjustment.
- [ ] Implement predefined color presets.
- [ ] Implement custom hexadecimal colors.
- [ ] Validate state restoration behavior.

**Milestone:** RGB keyboard management works entirely
inside the GigaControl popup.

## Phase 6 — Fan control

- [ ] Design a secure authorization model.
- [ ] Implement explicit manual fan controls.
- [ ] Validate CPU and GPU fan adjustments.
- [ ] Implement supported fan profiles.
- [ ] Implement firmware automatic mode restoration.
- [ ] Validate safety and recovery behavior.

**Milestone:** Fan control is available without bypassing
the original hardware safeguards.

## Phase 7 — Application preferences

- [ ] Implement native Plasma configuration.
- [ ] Add configurable monitoring interval.
- [ ] Add appearance preferences.
- [ ] Implement persistent user settings.
- [ ] Document installation and removal.

## Phase 8 — Visual refinement

- [ ] Refine Tokyo Midnight styling.
- [ ] Improve layout and spacing.
- [ ] Add useful visual indicators.
- [ ] Validate different panel sizes and screen positions.
- [ ] Review usability and accessibility.

## Phase 9 — Release preparation

- [ ] Complete hardware compatibility documentation.
- [ ] Run regression tests.
- [ ] Validate installation on a clean environment.
- [ ] Review licensing and third-party attribution.
- [ ] Prepare the first public release.

---

## Development principles

- Complete and validate each phase before progressing.
- Keep the interface native to KDE Plasma.
- Avoid unnecessary background hardware polling.
- Never perform hardware changes without explicit user action.
- Preserve the original utilities' safety mechanisms.
- Prefer small, independently testable components.
