/// An enumerator with all of the mask layers.
enum CoverageType {
  saturatedOrDefective('saturated_or_defective'),
  darkAreaPixels('dark_area_pixels'),
  cloudShadows('cloud_shadows'),
  vegetation('vegetation'),
  notVegetated('not_vegetated'),
  water('water'),
  unclassified('unclassified'),
  cloudMediumProbability('cloud_medium_probability'),
  cloudHighProbability('cloud_high_probability'),
  thinCirrus('thin_cirrus'),
  snow('snow');

  /// Useful for texts, paths and data.
  final String string;
  const CoverageType(this.string);

  /// A more usable version of [string].
  String capitalizedString() => string
      .replaceAll('_', ' ')
      .replaceFirst(string[0], string[0].toUpperCase());
}
