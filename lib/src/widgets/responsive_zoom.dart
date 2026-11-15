import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/screen_ratio.dart';
import 'zoom_widget.dart';

class ResponsiveZoom extends StatelessWidget {
  /// Used when no reference size has been configured.
  static const Size defaultReferenceSize = Size(450, 960);

  /// Legacy single reference size.
  @Deprecated('Use ResponsiveZoom.setReferenceSizesByDevice instead.')
  static Size? referenceSize;

  /// Reference sizes sorted by aspect ratio (width / height).
  static List<MapEntry<double, Size>> _entries = const [];

  /// Returns the current screen size in logical pixels.
  /// Real screen size is the physical size divided by the device pixel ratio.
  static Size get realScreenSize {
    final views = WidgetsBinding.instance.platformDispatcher.views;
    if (views.isEmpty) return Size.zero;

    final view = views.first;
    return view.physicalSize / view.devicePixelRatio;
  }

  /// Prefer to call once in main(), before runApp.
  ///
  /// Keys are aspect ratios (width / height). The zoom blends smoothly
  /// between neighboring keys as the screen's aspect ratio changes.
  ///
  /// ```dart
  /// ResponsiveZoom.setReferenceSizes({
  ///   9 / 16: Size(450, 960),  // portrait
  ///   1: Size(700, 700),       // square-ish (tablets, foldables)
  ///   16 / 9: Size(960, 450),  // landscape
  /// });
  /// ```
  static void setReferenceSizes(Map<double, Size> sizes) {
    assert(
      sizes.keys.every((ratio) => ratio.isFinite && ratio > 0),
      'Aspect ratios must be positive and finite.',
    );
    assert(
      sizes.values.every((s) => s.width > 0 && s.height > 0),
      'Reference sizes must have positive width and height.',
    );

    _entries = List.unmodifiable(
      sizes.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
  }

  /// Same as [setReferenceSizes], but keyed by [ScreenRatio].
  ///
  /// ```dart
  /// ResponsiveZoom.setReferenceSizesByDevice({
  ///   ScreenRatio.phoneTall: Size(390, 844),
  ///   ScreenRatio.phone: Size(450, 960),
  ///   ScreenRatio.iPad: Size(820, 1180),
  /// });
  /// ```
  static void setReferenceSizesByDevice(Map<ScreenRatio, Size> sizes) {
    setReferenceSizes({for (final e in sizes.entries) e.key.value: e.value});
  }

  /// Removes all configured reference sizes (falls back to the legacy
  /// [referenceSize] or [defaultReferenceSize]).
  static void clearReferenceSizes() => _entries = const [];

  /// Sets a single reference size (used regardless of aspect ratio).
  @Deprecated('Use ResponsiveZoom.setReferenceSizesByDevice instead.')
  static void setReferenceSize({Size? referenceSize}) {
    // ignore: deprecated_member_use_from_same_package
    ResponsiveZoom.referenceSize = referenceSize;
  }

  /// Zoom for the current screen.
  static double get zoom => zoomFor(realScreenSize);

  /// Zoom a single reference size would give for [real].
  static double _zoomWith(Size real, Size reference) {
    return math.min(real.width, real.height) /
        math.min(reference.width, reference.height);
  }

  /// Calculates the zoom for [real].
  ///
  /// With reference sizes set, the zoom is blended between the two reference
  /// sizes whose aspect ratios surround the screen's aspect ratio. Outside
  /// the range of keys, the nearest end is used.
  ///
  /// Priority: [setReferenceSizes] > deprecated [referenceSize] > default.
  static double zoomFor(Size real) {
    // Can be zero before the first frame / view is attached.
    if (real.isEmpty) return 1.0;

    final entries = _entries;

    if (entries.isEmpty) {
      // ignore: deprecated_member_use_from_same_package
      return _zoomWith(real, referenceSize ?? defaultReferenceSize);
    }

    final ratio = real.width / real.height;

    // Clamp outside the configured range.
    if (ratio <= entries.first.key) {
      return _zoomWith(real, entries.first.value);
    }
    if (ratio >= entries.last.key) {
      return _zoomWith(real, entries.last.value);
    }

    // Find the two surrounding entries and blend between them.
    for (var i = 0; i < entries.length - 1; i++) {
      final lower = entries[i];
      final upper = entries[i + 1];

      if (ratio <= upper.key) {
        // Position in log space so 9/16 -> 1 -> 16/9 is symmetric.
        final logLower = math.log(lower.key);
        final logUpper = math.log(upper.key);
        final t = (math.log(ratio) - logLower) / (logUpper - logLower);

        final zoomLower = _zoomWith(real, lower.value);
        final zoomUpper = _zoomWith(real, upper.value);

        return zoomLower + (zoomUpper - zoomLower) * t;
      }
    }

    // Unreachable because of the clamps above.
    return _zoomWith(real, entries.last.value);
  }

  final Widget child;

  const ResponsiveZoom({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ZoomWidget(calculateZoom: () => zoom, child: child);
  }
}
