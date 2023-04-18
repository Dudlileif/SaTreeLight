import 'package:flutter/material.dart';

/// Animated loading indicator, a dynamically sized
/// [CircularProgressIndicator.adaptive]
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    super.key,
    this.sizeFraction = 0.05,
    this.strokeWidthFraction = 0.005,
    this.backgroundColor,
  });

  /// Size of the [CircularProgressIndicator.adaptive] child,
  /// as a fraction of the longest side constraint
  final double sizeFraction;

  /// Stroke width of the [CircularProgressIndicator.adaptive] child,
  /// as a fraction of the longest side constraint
  final double strokeWidthFraction;

  /// Background color of the [CircularProgressIndicator.adaptive] child
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: SizedBox.square(
            dimension: constraints.biggest.longestSide * sizeFraction,
            child: CircularProgressIndicator.adaptive(
              backgroundColor:
                  backgroundColor ?? Theme.of(context).colorScheme.background,
              strokeWidth:
                  constraints.biggest.longestSide * strokeWidthFraction,
            ),
          ),
        );
      },
    );
  }
}
