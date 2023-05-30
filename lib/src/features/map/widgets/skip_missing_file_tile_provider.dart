import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

/// [TileProvider] that uses [FileImage] internally on platforms other than web.
/// It will replace missing files with a transparent image.
class SkipMissingFileTileProvider extends TileProvider {
  SkipMissingFileTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final file = File(getTileUrl(coordinates, options));
    if (file.existsSync()) {
      return FileImage(file);
    }

    return Image.asset('assets/transparent.png').image;
  }
}
