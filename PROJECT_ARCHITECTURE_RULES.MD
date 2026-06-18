# ADZ MAVALL Project Architecture Rules

This file is the living source of truth for architecture and implementation rules.

## Core principles
- Use Clean Architecture across the project.
- Use feature-first module organization.
- Keep UI separated into grouped widgets by design section.
- Keep business logic in Cubits.
- Use Dio for networking.
- Use ScreenUtil for responsive dimensions.
- Use GoRouter for navigation.
- Keep strings in dedicated localization files.
- Support Arabic and English, with English as default.

## Folder structure (target)
```text
lib/
  app/
  core/
    localization/
    network/
    routes/
    theme/
  features/
    splash/
      data/
      domain/
      presentation/
    onboarding/
      data/
      domain/
      presentation/
assets/
  images/
  fonts/
  lang/
```

## UI composition rules
- `main.dart` must not contain feature UI.
- Each screen is composed from small UI groups in `presentation/widgets`.
- Each visual group from Figma should have a dedicated widget file when possible.

## Localization rules
- Default locale is English.
- Arabic must be supported for every user-facing string.
- No hard-coded user-facing strings in page widgets (move to localization map/files).

## Splash rules
- Use `flutter_native_splash` for platform splash screen.
- Keep logical splash flow in `features/splash` (timer/init/navigation decision).

## Implementation phases
1. Foundation setup (structure, packages, routing, localization baseline).
2. Onboarding implementation (UI + logic).
3. Remaining features implementation.
4. Refactor and optimize.
