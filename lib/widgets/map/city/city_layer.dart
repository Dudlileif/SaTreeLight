import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_colors.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/widgets/map/polygon_clipper.dart';

/// A congregated map layer with all the layers for one city.
class CityLayer extends ConsumerWidget {
  const CityLayer({
    required this.city,
    super.key,
  });
  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usePolygonClipper = ref.watch(usePolygonClipperProvider);

    return Stack(
      children: [
        if (usePolygonClipper && ref.watch(lastMapEventDelayProvider))
          ClipPath(
            clipper: PolygonClipper(
              map: FlutterMapState.maybeOf(context, nullOk: true),
              polygons: city.polygons(),
            ),
            child: CityImageStack(city: city),
          )
        else
          CityImageStack(city: city),
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
      children: ref
          .watch(selectedMasksProvider)
          .map(
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
          )
          .toList(),
    );
  }
}
