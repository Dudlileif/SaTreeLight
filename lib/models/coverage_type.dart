import 'package:flutter/material.dart';

/// An enumerator with all of the mask layers.
enum CoverageType {
  saturatedOrDefective('saturated_or_defective', Icons.close),
  darkAreaPixels('dark_area_pixels', Icons.dark_mode),
  cloudShadows('cloud_shadows', Icons.cloud),
  vegetation('vegetation', Icons.grass),
  notVegetated('not_vegetated', Icons.business_outlined),
  water('water', Icons.water_drop),
  unclassified('unclassified', Icons.question_mark),
  cloudMediumProbability('cloud_medium_probability', Icons.cloud),
  cloudHighProbability('cloud_high_probability', Icons.cloud),
  thinCirrus('thin_cirrus', Icons.cloud),
  snow('snow', Icons.snowing);

  const CoverageType(this.string, this.icon);

  /// Useful for texts, paths and data.
  final String string;

  /// An icon to help visualize the coverage type.
  final IconData icon;

  /// A more usable version of [string].
  String capitalizedString() => string
      .replaceAll('_', ' ')
      .replaceFirst(string[0], string[0].toUpperCase());
}
