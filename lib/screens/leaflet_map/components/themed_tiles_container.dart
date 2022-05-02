import 'package:flutter/material.dart';
import 'package:themed/themed.dart';

class ThemedTilesContainer extends StatelessWidget {
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
