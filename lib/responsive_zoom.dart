import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveZoom extends StatelessWidget {
  /// Returns the current screen size in logical pixels.
  /// Real screen size is the physical size divided by the device pixel ratio.
  static Size get realScreenSize {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    return view.physicalSize / view.devicePixelRatio;
  }

  static double get zoom {
    final real = realScreenSize;
    final reference = referenceSize;

    final shortSide = math.min(real.width, real.height);
    final longSide = math.max(real.width, real.height);

    final referenceShortSide = math.min(reference.width, reference.height);

    final referenceLongSide = math.max(reference.width, reference.height);

    final sizeScale = math.sqrt(
      (shortSide / referenceShortSide) * (longSide / referenceLongSide),
    );

    final aspectRatio = longSide / shortSide;
    final referenceAspectRatio = referenceLongSide / referenceShortSide;

    final aspectScale = math.sqrt(aspectRatio / referenceAspectRatio);

    return math.sqrt(sizeScale / aspectScale);
  }

  static Size referenceSize = Size(450, 960);

  /// Prefer to just call once in main() to set the reference sizes for your app.
  /// referenceSize: The reference size for phones (portrait).
  /// Default values are 450x960
  /// No need to call this method if you are happy with the default values.
  static void setReferenceSize({Size referenceSize = const Size(450, 960)}) {
    ResponsiveZoom.referenceSize = referenceSize;
  }

  final Widget child;

  const ResponsiveZoom({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentZoom = zoom;

        return _ZoomMediaQuery(
          zoom: currentZoom,
          child: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: FittedBox(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth / currentZoom,
                  maxHeight: constraints.maxHeight / currentZoom,
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ZoomMediaQuery extends StatelessWidget {
  final Widget child;
  final double zoom;

  const _ZoomMediaQuery({required this.child, required this.zoom});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(
        size: Size(mediaQuery.size.width / zoom, mediaQuery.size.height / zoom),
        viewInsets: mediaQuery.viewInsets / zoom,
        viewPadding: mediaQuery.padding / zoom,
        padding: mediaQuery.padding / zoom,
        systemGestureInsets: mediaQuery.systemGestureInsets / zoom,
      ),
      child: child,
    );
  }
}
