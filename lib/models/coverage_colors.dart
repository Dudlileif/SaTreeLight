import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:satreelight/models/coverage_type.dart';

/// A class with lists and maps of colors tailored to the mask layers.
class CoverageColors {
  /// Colors meant for light mode maps.
  static List<Color> colorsLight = const [
    Color.fromRGBO(255, 0, 0, 1),
    Color.fromRGBO(47, 47, 47, 1),
    Color.fromRGBO(100, 50, 0, 1),
    Color.fromRGBO(0, 225, 0, 1),
    Color.fromRGBO(222, 188, 0, 1),
    Color.fromRGBO(0, 0, 225, 1),
    Color.fromRGBO(128, 128, 128, 1),
    Color.fromRGBO(192, 192, 192, 1),
    Color.fromRGBO(255, 255, 255, 1),
    Color.fromRGBO(100, 200, 255, 1),
    Color.fromRGBO(255, 150, 255, 1),
  ];

  /// Colors meant for dark mode maps.
  static List<Color> colorsDark = const [
    Color.fromRGBO(255, 0, 0, 1),
    Color.fromRGBO(47, 47, 47, 1),
    Color.fromRGBO(100, 50, 0, 1),
    Color.fromRGBO(0, 125, 0, 1),
    Color.fromRGBO(175, 150, 0, 1),
    Color.fromRGBO(0, 0, 155, 1),
    Color.fromRGBO(128, 128, 128, 1),
    Color.fromRGBO(192, 192, 192, 1),
    Color.fromRGBO(255, 255, 255, 1),
    Color.fromRGBO(100, 200, 255, 1),
    Color.fromRGBO(200, 100, 200, 1),
  ];

  /// Light mode colors mapped to their respective mask layer.
  static Map<CoverageType, Color> colorMapLight = const {
    CoverageType.saturatedOrDefective: Color.fromRGBO(255, 0, 0, 1),
    CoverageType.darkAreaPixels: Color.fromRGBO(47, 47, 47, 1),
    CoverageType.cloudShadows: Color.fromRGBO(100, 50, 0, 1),
    CoverageType.vegetation: Color.fromRGBO(0, 225, 0, 1),
    CoverageType.notVegetated: Color.fromRGBO(222, 188, 0, 1),
    CoverageType.water: Color.fromRGBO(0, 0, 225, 1),
    CoverageType.unclassified: Color.fromRGBO(128, 128, 128, 1),
    CoverageType.cloudMediumProbability: Color.fromRGBO(192, 192, 192, 1),
    CoverageType.cloudHighProbability: Color.fromRGBO(255, 255, 255, 1),
    CoverageType.thinCirrus: Color.fromRGBO(100, 200, 255, 1),
    CoverageType.snow: Color.fromRGBO(255, 150, 255, 1),
  };

  /// Dark mode colors mapped to their respective mask layer.
  static Map<CoverageType, Color> colorMapDark = const {
    CoverageType.saturatedOrDefective: Color.fromRGBO(255, 0, 0, 1),
    CoverageType.darkAreaPixels: Color.fromRGBO(47, 47, 47, 1),
    CoverageType.cloudShadows: Color.fromRGBO(100, 50, 0, 1),
    CoverageType.vegetation: Color.fromRGBO(0, 125, 0, 1),
    CoverageType.notVegetated: Color.fromRGBO(175, 150, 0, 1),
    CoverageType.water: Color.fromRGBO(0, 0, 155, 1),
    CoverageType.unclassified: Color.fromRGBO(128, 128, 128, 1),
    CoverageType.cloudMediumProbability: Color.fromRGBO(192, 192, 192, 1),
    CoverageType.cloudHighProbability: Color.fromRGBO(255, 255, 255, 1),
    CoverageType.thinCirrus: Color.fromRGBO(100, 200, 255, 1),
    CoverageType.snow: Color.fromRGBO(200, 100, 200, 1),
  };

  /// Gets mapped light/dark mode colors, with the ability to adjust opacity.
  static Map<CoverageType, Color> colorMapWithOpacity(
      {double opacity = 1, bool dark = false,}) {
    final colorMap = dark ? colorMapDark : colorMapLight;
    return colorMap
        .map((key, value) => MapEntry(key, value.withOpacity(opacity)));
  }

  /// Gets light/dark mode colors, with the ability to adjust opacity.
  static List<Color> colorsWithOpacity(
      {double opacity = 1, bool dark = false,}) {
    final colors = dark ? colorsDark : colorsLight;
    return List.generate(
        colors.length, (index) => colors[index].withOpacity(opacity),);
  }

  /// Gets only the requested light/dark mode colors for the keys, with the ability to adjust opacity.
  static List<Color> colorsFromKeys(List<CoverageType> keys,
      {bool dark = false, double opacity = 1,}) {
    final colorMap = dark ? colorMapDark : colorMapLight;
    return List.generate(
        keys.length, (index) => colorMap[keys[index]]!.withOpacity(opacity),);
  }

  static image_lib.Color colorFromMaskIndex(
    int index, {
    bool dark = false,
  }) {
    return dark
        ? image_lib.ColorUint8.rgba(
            colorsDark[index].red,
            colorsDark[index].green,
            colorsDark[index].blue,
            colorsDark[index].alpha,)
        : image_lib.ColorUint8.rgba(
            colorsLight[index].red,
            colorsLight[index].green,
            colorsLight[index].blue,
            colorsLight[index].alpha,);
  }
}
