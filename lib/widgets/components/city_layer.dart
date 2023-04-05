import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_colors.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/widgets/components/polygon_clipper.dart';
import 'package:satreelight/widgets/components/providers/city_layer_options.dart';
import 'package:satreelight/widgets/components/providers/last_map_event_delay.dart';
import 'package:satreelight/widgets/components/providers/swap_image_colors.dart';

/// A congregated map layer with all the layers for one city.
class CityLayer extends ConsumerWidget {
  const CityLayer({
    required this.city,
    super.key,
  });
  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useImages = ref.watch(useImagesProvider);
    final useCombinedImage = ref.watch(useCombinedImageProvider);
    final usePolygonClipper = ref.watch(usePolygonClipperProvider);

    final imageLayers = Stack(
      children: <Widget>[
        if (useImages && useCombinedImage)
          ref
              .watch(
                swapImageColorsProvider(
                  city,
                  isDarkMode: Theme.of(context).brightness == Brightness.dark,
                ),
              )
              .when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
                data: (data) => OverlayImageLayer(
                  overlayImages: [
                    OverlayImage(
                      bounds: city.bounds,
                      opacity: 0.5,
                      imageProvider: MemoryImage(data),
                    )
                  ],
                ),
              ),
        if (useImages && !useCombinedImage) CityImageStack(city: city),
        if (!useImages) // Use tiles
          Stack(
            children: ref.watch(cityMasksTilesProvider).when(
                  error: (error, stackTrace) => <Widget>[],
                  loading: () => <Widget>[],
                  data: (data) => data,
                ),
          ),
      ],
    );

    return Stack(
      children: [
        if (usePolygonClipper && ref.watch(lastMapEventDelayProvider))
          ClipPath(
            clipper: PolygonClipper(
              map: FlutterMapState.maybeOf(context, nullOk: true),
              polygons: city.polygons(),
            ),
            child: imageLayers,
          )
        else
          imageLayers,
        PolygonLayer(
          polygonCulling: true,
          polygons: city.polygons(
            fillColor: Theme.of(context).brightness == Brightness.light
                ? null
                : Colors.grey.withAlpha(75),
          ),
        ),
      ],
    );
  }
}

/// An image stack of all the individual images for the
/// selected masks.
class CityImageStack extends ConsumerWidget {
  const CityImageStack({
    required this.city,
    super.key,
  });

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        ...ref.watch(imageMasksProvider).map(
              (mask) => ColorFiltered(
                colorFilter: ColorFilter.mode(
                  CoverageColors.colorMapWithOpacity(
                    dark: Theme.of(context).brightness == Brightness.dark,
                  )[mask]!,
                  BlendMode.srcIn,
                ),
                child: OverlayImageLayer(
                  overlayImages: [
                    OverlayImage(
                      bounds: city.bounds,
                      opacity: 0.5,
                      imageProvider: kIsWeb
                          ? Image.network(
                              '../data/masks/${mask.string}/${city.name}, ${city.stateLong}.png',
                            ).image
                          : FileImage(
                              File(
                                '${Platform.isLinux ? '/home/gaute/Documents/Projects/SaTreeLight/Sentinelsat/export/masks' : 'E:/Projects/SaTreeLight-data-processing/export/masks'}/${mask.string}/${city.name}, ${city.stateLong}.png',
                              ),
                            ),
                    )
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
