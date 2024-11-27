# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Changed

- Upgraded various dependencies on the Flutter side.
- Instead of having a hardcoded base url, let the user decide where to connect.

## 0.4.0 - 2022-11-17

### Added

- Dedicated brightness slider in the app.
- Server uses brightness setting to adjust rgb values, including for previously only "full-brightness" rainbow patterns.
- List of color palettes, whose colors can be picked from individually, or set wholesale.

### Changed

- Now using bespoke UI for color selection instead of existing color picker libraries.
- Use dedicated provider for saved colors feature.
- Word choice updates for clarity, such as "Add to Favorites" instead of "Save Current Color".
- Hex color display are now in uppercase.

### Fixed

- Breathing pattern now actually prevents runs of the same color if there's more than one color set.
- Scroll pattern now actually uses all colors provided to it.

### Removed

- Color picker libraries.

## 0.3.0 - 2022-11-10

### Added

- This changelog. :)
- Top-level README.
- Ability to set an animation speed for certain patterns.

### Changed

- Rewrite server and patterns in Rust, using axum as the framework.
- Upgrade Flutter version.
- Upgrade Dart version.
- Upgrade Flutter packages.
- Update look and feel for app, including a dark mode.
- **Breaking**: New format for api response and request data.

## 0.2.0 - 2021-12-10

### Added

- Set up Python Flask server.
- Set up Flutter app to use REST api to control the light patterns.
- Flutter app has ability to save color choices locally.
- Certain light patterns can have their colors set by the user.
