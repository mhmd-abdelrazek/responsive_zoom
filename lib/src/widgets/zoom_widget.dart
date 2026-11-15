import 'package:flutter/material.dart';

class ZoomWidget extends StatelessWidget {
  final Widget child;
  final double Function()? calculateZoom;
  final double? staticZoom;

  const ZoomWidget({
    super.key,
    required this.child,
    this.calculateZoom,
    this.staticZoom,
  });

  @override
  Widget build(BuildContext context) {
    final zoom = calculateZoom?.call() ?? staticZoom;

    if (zoom == null) {
      // No zoom value provided, return the child as is
      return child;
    }

    final mediaQuery = MediaQuery.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: const TextScaler.linear(1),
            size: Size(
              mediaQuery.size.width / zoom,
              mediaQuery.size.height / zoom,
            ),
            viewInsets: mediaQuery.viewInsets / zoom,
            viewPadding: mediaQuery.padding / zoom,
            padding: mediaQuery.padding / zoom,
            systemGestureInsets: mediaQuery.systemGestureInsets / zoom,
          ),
          child: SizedBox(
            width: double.maxFinite,
            height: double.maxFinite,
            child: FittedBox(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth / zoom,
                  maxHeight: constraints.maxHeight / zoom,
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
