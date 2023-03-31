import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as image_lib;
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_colors.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:satreelight/providers/providers.dart';

final swapImageColorsProvider =
    FutureProvider.autoDispose.family<Uint8List, bool>((ref, isDarkMode) async {
  final City? city = ref.watch(selectedCityProvider);
  final List<CoverageType> masks = ref.watch(imageMasksProvider);

  if (city != null) {
    final File file = File(
        'E:/Projects/SaTreeLight-data-processing/images/masked/${city.name}, ${city.stateLong}.png');

    final Uint8List imageBytes = await file.readAsBytes();

    final image_lib.Image? image = image_lib.decodePng(imageBytes);
    if (image != null) {
      final convertedImage = image.convert(
        numChannels: 4,
        alpha: 0,
      );

      for (final pixel in convertedImage) {
        if (masks.any((mask) => pixel.r - 1 == mask.index)) {
          pixel.set(CoverageColors.colorFromMaskIndex(
            pixel.r.toInt() - 1,
            dark: isDarkMode,
          ));
        }
      }
      return image_lib.encodePng(convertedImage);
    }
  }
  return Uint8List(0);
});
