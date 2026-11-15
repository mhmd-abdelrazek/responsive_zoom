# Changelog

All notable changes to this project will be documented in this file.

## 1.1.0

### Added

- Multiple reference sizes, one per aspect ratio, with `ResponsiveZoom.setReferenceSizes(Map<double, Size>)`. Keys are aspect ratios (`width / height`).
- Smooth zoom blending. The zoom is interpolated between the two reference sizes whose aspect ratios surround the screen's ratio, so changing the aspect ratio no longer makes the zoom jump (for example from 0.75 to 1.5). Outside the configured range the nearest reference size is used.
- `ScreenRatio` enum with common portrait aspect ratios (`phone`, `phoneTall`, `phoneUltraTall`, `tablet`, `iPad`, `iPadPro`, `foldable`, `dualScreen`, `square`). Each ratio documents the devices it applies to and has `value` (portrait) and `landscape` (rotated) helpers.
- `ResponsiveZoom.setReferenceSizesByDevice(Map<ScreenRatio, Size>)` to set reference sizes using `ScreenRatio` instead of raw doubles.
- `ResponsiveZoom.clearReferenceSizes()` to reset to the default reference size (useful in tests).
- `ResponsiveZoom.zoomFor(Size)` to calculate the zoom for any screen size.
- `ResponsiveZoom.defaultReferenceSize` (`450x960`).
- `ScreenType` enum (`portrait`, `landscape`, `square`) with `isPortrait`, `isLandscape`, `isSquare` and `pick(...)`. A screen is `square` when `width / height` is between 0.9 and 1.1.
- `ResponsiveBuilder` widget that builds different widget arrangements for each `ScreenType`. It uses the real screen size from `ResponsiveZoom` and rebuilds on rotation and window resize.
- `ResponsiveBuilder.columnOnPortraitRowOnLandscape` ready block. Children are laid out in a column on portrait screens and in a row on landscape screens, and glide to their new positions and sizes when the screen type changes. Supports `flexes`, `spacing`, `squareAxis`, `duration` and `curve`.
- `ResponsiveBuilder.layoutPerScreenType` ready block. Provides a different layout per screen type with a crossfade between them. Missing layouts fall back (square, then landscape, then portrait).

### Changed

- `ResponsiveZoom.referenceSize` is now nullable and deprecated.
- `ResponsiveZoom.setReferenceSize` is deprecated. Use `setReferenceSizes` or `setReferenceSizesByDevice` instead. Both still work.
- Priority when calculating zoom: `setReferenceSizes` / `setReferenceSizesByDevice`, then the deprecated `referenceSize`, then `defaultReferenceSize`.
- Simplified the zoom calculation to `shortSide / referenceShortSide`. The previous size and aspect-ratio steps cancelled out, so results with a single reference size are unchanged.
- Reference sizes are validated and sorted once when they are set, not on every zoom calculation.

### Fixed

- Zoom no longer produces `NaN` or infinity when the screen size is zero before the first frame. It returns `1.0` instead.
- `realScreenSize` no longer throws when no view is attached. It returns `Size.zero` instead.

### Notes

- The `spacing` parameter of `ResponsiveBuilder.columnOnPortraitRowOnLandscape` is applied by the package's own layout, so it does not depend on Flutter's `Flex.spacing`.
- Set reference sizes once in `main()`, before `runApp`.

## 1.0.5

- Added support for disabling system font scaling using TextScaler.linear(1).
- Improved screen scaling consistency across different devices.
- Updated MediaQuery scaling to handle screen dimensions, padding, and insets.

## 1.0.3

- Fixed zoom calculation to prevent excessive scaling by removing the extra square root.

## 1.0.2

- Removed the custom `devicePixelRatio` modification from the zoomed `MediaQuery`.
- Improved compatibility with Flutter APIs that rely on the device pixel ratio.

## 1.0.1

- Fixed README image links for proper display on pub.dev.
- Improved README documentation and examples.

## 1.0.0

- Initial release of `responsive_zoom`.
- Added `ResponsiveZoom` widget for scaling an entire Flutter widget tree.
- Added configurable reference screen size.
- Added automatic zoom calculation based on screen size and aspect ratio.
- Added `MediaQuery` adjustment to keep screen size, padding, and view insets consistent with the scaled layout.
- Dependency-free implementation.
- Supports responsive scaling of layouts, text, icons, spacing, radii, and other UI elements without per-widget extensions.
