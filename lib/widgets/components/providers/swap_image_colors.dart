import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image_lib;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_colors.dart';
import 'package:satreelight/providers/providers.dart';

part 'swap_image_colors.g.dart';

@riverpod
FutureOr<Uint8List> swapImageColors(
  SwapImageColorsRef ref,
  City city, {
  bool isDarkMode = false,
}) async {
  final masks = ref.watch(imageMasksProvider);

  if (Platform.isLinux || Platform.isWindows) {
    final dirPath = Platform.isLinux
        ? '/home/gaute/Documents/Projects/SaTreeLight/Sentinelsat/images/masked'
        : 'E:/Projects/SaTreeLight-data-processing/images/masked';
    final file = File(
      '$dirPath/${city.name}, ${city.stateLong}.png',
    );

    final imageBytes = await file.readAsBytes();

    final image = image_lib.decodePng(imageBytes);
    if (image != null) {
      final convertedImage = image.convert(
        numChannels: 4,
        alpha: 0,
        noAnimation: true,
      );

      for (final pixel in convertedImage) {
        if (masks.any((mask) => pixel.r - 1 == mask.index)) {
          pixel.set(
            CoverageColors.colorFromMaskIndex(
              pixel.r.toInt() - 1,
              dark: isDarkMode,
            ),
          );
        }
      }
      return image_lib.encodeBmp(
        convertedImage,
      );
    }
  }
  return Uint8List(0);
}
