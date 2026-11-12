# Contributing to GigaControl

Thank you for your interest in contributing to GigaControl!

GigaControl is an independent, community-oriented project
focused on providing a native KDE Plasma interface for
Gigabyte laptop fan and RGB keyboard management.

Contributions, bug reports and suggestions are welcome.

## 1. Before contributing

Before starting substantial work:

- Check existing issues and discussions.
- Avoid duplicating ongoing work.
- Discuss significant architectural changes before implementing them.
- Keep changes focused and independently reviewable.

## 2. Development environment

The project targets:

- Linux
- KDE Plasma 6
- QML
- Qt 6
- Existing `gfan` and `gkbd` utilities

Visual Studio Code is the recommended development environment.

## 3. Code guidelines

### QML

- Keep interface components modular.
- Separate presentation from hardware operations.
- Prefer reusable components.
- Avoid unnecessary dependencies.
- Follow KDE Plasma conventions where possible.

### Hardware integration

- Reuse the original `gfan` and `gkbd` utilities.
- Never implement independent EC communication.
- Preserve upstream safety checks.
- Validate command arguments.
- Handle errors explicitly.
- Never introduce unrestricted privileged execution.

### General development

- Keep changes small and understandable.
- Document non-obvious behavior.
- Avoid committing generated files and local configuration.
- Include tests when introducing new functionality.

## 4. Testing

Contributions should be tested before submission.

Depending on the changes, testing may include:

- QML validation.
- Plasmoid installation and interaction.
- Mock-based hardware command tests.
- Read-only hardware monitoring.
- Regression testing.

Never use physical hardware as the only testing environment.

## 5. Reporting issues

When reporting a problem, include:

- Operating system and version.
- KDE Plasma version.
- Laptop model.
- Relevant GigaControl version or commit.
- Steps to reproduce the issue.
- Relevant error messages or logs.

Do not include passwords, authentication information
or other sensitive system data.

## 6. Pull requests

Pull requests should:

- Explain the purpose of the change.
- Describe relevant implementation decisions.
- Identify affected components.
- Include testing information.
- Avoid unrelated changes.

Architectural changes should be discussed before implementation.

## 7. Hardware compatibility reports

Hardware compatibility reports are particularly valuable.

Please distinguish between:

- Maintainer-verified hardware.
- User-reported compatibility.
- Hardware that has not been tested.

Include hardware and software details when reporting
successful or unsuccessful operations.

## 8. Licensing

By submitting a contribution, you agree that your contribution
will be distributed under the project's GNU General Public
License v3.0 only.

Ensure that contributed code and resources are compatible
with the project's licensing requirements.

Third-party code and assets must be properly attributed.

## 9. Project philosophy

GigaControl aims to remain:

- Lightweight.
- Accessible.
- Open source.
- Maintainable.
- Safe when interacting with hardware.

Contributions should support these principles.
