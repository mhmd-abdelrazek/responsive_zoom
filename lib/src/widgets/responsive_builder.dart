import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/widgets.dart';

import 'responsive_zoom.dart';

/// Screen shape, decided by the real screen's aspect ratio only.
enum ScreenType {
  /// Taller than wide (phones, most tablets in portrait).
  portrait,

  /// Wider than tall.
  landscape,

  /// Close to 1:1 (width / height between 0.9 and 1.1).
  square;

  bool get isPortrait => this == portrait;
  bool get isLandscape => this == landscape;
  bool get isSquare => this == square;

  /// Picks a value by screen type. Missing values fall back
  /// (square -> landscape -> portrait).
  ///
  /// ```dart
  /// final columns = type.pick(portrait: 1, landscape: 3, square: 2);
  /// ```
  T pick<T>({required T portrait, T? landscape, T? square}) {
    switch (this) {
      case ScreenType.square:
        return square ?? landscape ?? portrait;
      case ScreenType.landscape:
        return landscape ?? portrait;
      case ScreenType.portrait:
        return portrait;
    }
  }
}

/// Rebuilds when the real screen's [ScreenType] may have changed.
/// Place it under [ResponsiveZoom].
class ResponsiveBuilder extends StatelessWidget {
  /// Full control: arrange widgets from the [ScreenType].
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ScreenType type) builder;

  // ---------------------------------------------------------------------
  // Ready blocks
  // ---------------------------------------------------------------------

  /// [children] in a column on portrait screens and in a row on landscape.
  /// Square screens use [squareAxis]. When the screen type changes, the
  /// children glide to their new positions and sizes.
  ///
  /// Children fill their cell, so don't wrap them in [Expanded]. Use
  /// [flexes] to give children different shares (default: all equal).
  /// Needs bounded width and height, like a [Row] with [Expanded] children.
  factory ResponsiveBuilder.columnOnPortraitRowOnLandscape({
    Key? key,
    required List<Widget> children,
    List<int>? flexes,
    Axis squareAxis = Axis.horizontal,
    double spacing = 0,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeInOutCubic,
  }) {
    assert(
      flexes == null || flexes.length == children.length,
      'flexes must have one entry per child.',
    );
    assert(
      flexes == null || flexes.every((f) => f > 0),
      'Every flex must be greater than 0.',
    );

    return ResponsiveBuilder(
      key: key,
      builder: (context, type) => _AnimatedFlex(
        axis: type.pick(
          portrait: Axis.vertical,
          landscape: Axis.horizontal,
          square: squareAxis,
        ),
        flexes: flexes ?? List.filled(children.length, 1),
        spacing: spacing,
        duration: duration,
        curve: curve,
        children: children,
      ),
    );
  }

  /// A different layout per [ScreenType], with a crossfade between them.
  /// Missing layouts fall back (square -> landscape -> portrait).
  ///
  /// Layouts fill the available space, so this needs bounded constraints.
  /// Set [duration] to [Duration.zero] to switch instantly.
  factory ResponsiveBuilder.layoutPerScreenType({
    Key? key,
    required WidgetBuilder portrait,
    WidgetBuilder? landscape,
    WidgetBuilder? square,
    Duration duration = const Duration(milliseconds: 300),
    AnimatedSwitcherTransitionBuilder transitionBuilder =
        AnimatedSwitcher.defaultTransitionBuilder,
  }) {
    return ResponsiveBuilder(
      key: key,
      builder: (context, type) {
        // The layout actually used after fallback. It is the key, so two
        // screen types that share a layout don't trigger a transition.
        final effective = type.pick<ScreenType>(
          portrait: ScreenType.portrait,
          landscape: landscape == null ? null : ScreenType.landscape,
          square: square == null ? null : ScreenType.square,
        );
        final selected = type.pick<WidgetBuilder>(
          portrait: portrait,
          landscape: landscape,
          square: square,
        );

        return AnimatedSwitcher(
          duration: duration,
          transitionBuilder: transitionBuilder,
          // The default layoutBuilder loosens constraints. Expand instead,
          // so layouts get the same space they would get without animation.
          layoutBuilder: (current, previous) => Stack(
            fit: StackFit.expand,
            children: [...previous, if (current != null) current],
          ),
          child: KeyedSubtree(
            key: ValueKey(effective),
            child: Builder(builder: selected),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------
  // Square range
  // ---------------------------------------------------------------------

  // A screen is square when _squareMin <= width / height <= _squareMax.
  static const double _squareMin = 0.9;
  static const double _squareMax = 1.1;

  static ScreenType _typeFor(double ratio) {
    if (ratio < _squareMin) return ScreenType.portrait;
    if (ratio > _squareMax) return ScreenType.landscape;
    return ScreenType.square;
  }

  @override
  Widget build(BuildContext context) {
    // Subscribes this widget to window changes (rotation, foldables, desktop
    // resize). The value is ignored: the real size is read below.
    MediaQuery.sizeOf(context);

    final real = ResponsiveZoom.realScreenSize;

    // Zero before the first frame / when no view is attached.
    final ratio = real.isEmpty ? 1.0 : real.width / real.height;

    return builder(context, _typeFor(ratio));
  }
}

/// Lays children out as a row (t = 0) or a column (t = 1) and animates
/// between the two by interpolating every child's rect.
class _AnimatedFlex extends StatefulWidget {
  const _AnimatedFlex({
    required this.axis,
    required this.children,
    required this.flexes,
    required this.spacing,
    required this.duration,
    required this.curve,
  });

  final Axis axis;
  final List<Widget> children;
  final List<int> flexes;
  final double spacing;
  final Duration duration;
  final Curve curve;

  @override
  State<_AnimatedFlex> createState() => _AnimatedFlexState();
}

class _AnimatedFlexState extends State<_AnimatedFlex>
    with SingleTickerProviderStateMixin {
  double get _target => widget.axis == Axis.vertical ? 1.0 : 0.0;

  // Starts at the target, so the first build doesn't animate.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    value: _target,
  );

  late Animation<double> _curved = CurvedAnimation(
    parent: _controller,
    curve: widget.curve,
  );

  @override
  void didUpdateWidget(_AnimatedFlex oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.curve != widget.curve) {
      _curved = CurvedAnimation(parent: _controller, curve: widget.curve);
    }

    if (oldWidget.axis != widget.axis) {
      if (widget.duration == Duration.zero) {
        _controller.value = _target;
      } else {
        // Starts from the current value, so reversing mid-animation is smooth.
        _controller.animateTo(_target, duration: widget.duration);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomMultiChildLayout(
      delegate: _FlexDelegate(
        t: _curved,
        flexes: widget.flexes,
        spacing: widget.spacing,
      ),
      children: [
        for (var i = 0; i < widget.children.length; i++)
          LayoutId(id: i, child: widget.children[i]),
      ],
    );
  }
}

class _FlexDelegate extends MultiChildLayoutDelegate {
  // Relayouts on every animation tick without rebuilding any widgets.
  _FlexDelegate({
    required this.t,
    required this.flexes,
    required this.spacing,
  }) : super(relayout: t);

  final Animation<double> t;
  final List<int> flexes;
  final double spacing;

  @override
  void performLayout(Size size) {
    final count = flexes.length;
    if (count == 0) return;

    final totalFlex = flexes.fold<int>(0, (a, b) => a + b);
    final gaps = spacing * (count - 1);
    final freeWidth = math.max(0.0, size.width - gaps);
    final freeHeight = math.max(0.0, size.height - gaps);

    // Clamped so curves that overshoot can't produce negative sizes.
    final progress = t.value.clamp(0.0, 1.0);

    var x = 0.0;
    var y = 0.0;
    for (var i = 0; i < count; i++) {
      final share = flexes[i] / totalFlex;

      final asRow = Rect.fromLTWH(x, 0, freeWidth * share, size.height);
      final asColumn = Rect.fromLTWH(0, y, size.width, freeHeight * share);
      final rect = Rect.lerp(asRow, asColumn, progress)!;

      layoutChild(i, BoxConstraints.tight(rect.size));
      positionChild(i, rect.topLeft);

      x += asRow.width + spacing;
      y += asColumn.height + spacing;
    }
  }

  @override
  bool shouldRelayout(_FlexDelegate old) =>
      spacing != old.spacing || !listEquals(flexes, old.flexes);
}