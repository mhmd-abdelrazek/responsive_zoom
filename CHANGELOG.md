# Changelog

All notable changes to this project will be documented in this file.

## 1.0.3

- Fixed zoom calculation to prevent excessive scaling by removing the extra square root.

## 1.0.2

* Removed the custom `devicePixelRatio` modification from the zoomed `MediaQuery`.
* Improved compatibility with Flutter APIs that rely on the device pixel ratio.

## 1.0.1

* Fixed README image links for proper display on pub.dev.
* Improved README documentation and examples.

## 1.0.0

* Initial release of `responsive_zoom`.
* Added `ResponsiveZoom` widget for scaling an entire Flutter widget tree.
* Added configurable reference screen size.
* Added automatic zoom calculation based on screen size and aspect ratio.
* Added `MediaQuery` adjustment to keep screen size, padding, and view insets consistent with the scaled layout.
* Dependency-free implementation.
* Supports responsive scaling of layouts, text, icons, spacing, radii, and other UI elements without per-widget extensions.
