import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/models/coverage_colors.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:themed/themed.dart';

/// A class for theming the map tiles, used to get a dark mode map.
class ThemedTilesContainer extends StatelessWidget {
  /// The tiles containter to apply a theme to.
  final Widget tilesContainer;
  const ThemedTilesContainer({Key? key, required this.tilesContainer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        // Rotate hue by 180 deg, lower saturation
        ? ChangeColors(
            hue: 1,
            saturation: -0.2,

            // Invert colors
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.difference,
              ),
              child: tilesContainer,
            ),
          )
        : tilesContainer;
  }
}

/// A class for coloring the mask tiles.
class MaskTilesContainer extends ConsumerWidget {
  /// The tiles container to apply a color to.
  final Widget tilesContainer;

  /// Which mask the tiles contain, used to set the right color.
  final CoverageType mask;
  const MaskTilesContainer(
      {Key? key, required this.tilesContainer, required this.mask})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
          CoverageColors.colorMapWithOpacity(
                dark: Theme.of(context).brightness == Brightness.dark,
                opacity: 0.5,
              )[mask] ??
              Colors.white,
          BlendMode.srcIn),
      child: tilesContainer,
    );
  }
}
