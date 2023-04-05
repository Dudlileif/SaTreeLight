import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

/// A [TileProvider] for network images that will be cached.
class CachedTileProvider extends TileProvider {
  CachedTileProvider({super.headers});

  @override
  ImageProvider getImage(Coords<num> coords, TileLayer options) {
    final url = getTileUrl(coords, options);

    return FastCachedImageProvider(
      url,
      headers: headers,
    );
  }
}
