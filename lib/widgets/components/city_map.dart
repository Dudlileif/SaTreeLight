import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/models/coverage_colors.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/screens/leaflet_map/components/osm_contribution.dart';
import 'package:satreelight/screens/leaflet_map/components/themed_tiles_container.dart';
import 'package:satreelight/widgets/components/mask_selector.dart';
import 'package:satreelight/widgets/components/polygon_clipper.dart';
import 'package:satreelight/widgets/components/providers/swap_image_colors.dart';

/// Provider for the map bounds, used to keep position on mask selection update.
final boundsProvider = StateProvider.autoDispose<LatLngBounds?>((ref) => null);

/// Provider for the map zoom, used to keep position on mask selection update.
final zoomProvider = StateProvider.autoDispose.family<double, MapController>(
  (ref, controller) =>
      ref.read(selectedCityProvider)?.centerZoom(controller).zoom ?? 7,
);

/// Provider for the map center, used to keep position on mask selection update.
final centerProvider = StateProvider.autoDispose<LatLng>(
  (ref) => ref.read(selectedCityProvider)?.center ?? LatLng(0, 0),
);

/// A map of the city, with a bounds polygon and selected masks.
class CityMap extends ConsumerStatefulWidget {
  const CityMap({super.key});

  @override
  ConsumerState<CityMap> createState() => _CityMapState();
}

class _CityMapState extends ConsumerState<CityMap> {
  final MapController mapController = MapController();
  final FitBoundsOptions boundsOptions =
      const FitBoundsOptions(padding: EdgeInsets.all(20));

  bool useImages = true;
  bool useCombinedImages = true;
  bool useClipper = true;

  @override
  void initState() {
    super.initState();

    mapController.mapEventStream.listen((event) {
      final update = ref.read(updatedMasks);
      if (update) {
        ref.read(updatedMasks.notifier).update((state) => false);
      } else {
        ref.read(centerProvider.notifier).update((state) => event.center);
        ref
            .read(zoomProvider(mapController).notifier)
            .update((state) => event.zoom);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(updatedMasks, (previous, next) {
      if (next) {
        mapController.move(
          ref.watch(centerProvider),
          ref.watch(zoomProvider(mapController)),
        );
      }
    });

    final city = ref.watch(loadCityDataProvider).when(
          error: (error, stackTrace) => null,
          loading: () => null,
          data: (data) {
            if (data != null) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                ref
                    .read(boundsProvider.notifier)
                    .update((state) => data.bounds);
                mapController.fitBounds(data.bounds, options: boundsOptions);
              });
            }
            return data;
          },
        );

    final bounds = ref.watch(boundsProvider);

    final maskLayers = ref.watch(cityMasksProvider).when(
          error: (error, stackTrace) => <Widget>[],
          loading: () => <Widget>[],
          data: (data) {
            // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            //   ref.read(updatedMasks.notifier).update((state) => true);
            // });
            return data;
          },
        );

    final map = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        center: city?.center,
        maxZoom: 18.25,
        swPanBoundary: bounds?.southWest,
        nePanBoundary: bounds?.northEast,
        bounds: bounds,
        boundsOptions: boundsOptions,
        slideOnBoundaries: true,
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tilesContainerBuilder: (context, tilesContainer, tiles) =>
              ThemedTilesContainer(tilesContainer: tilesContainer),
          backgroundColor: Colors.transparent,
        ),
        if (city != null && useImages && useCombinedImages)
          ref
              .watch(
                swapImageColorsProvider(
                  Theme.of(context).brightness == Brightness.dark,
                ),
              )
              .when(
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
                data: (data) => useClipper
                    ? Builder(
                        builder: (context) => ClipPath(
                          clipper: PolygonClipper(
                            map: FlutterMapState.maybeOf(
                              context,
                              nullOk: true,
                            ),
                            polygons: city.polygons(),
                          ),
                          child: OverlayImageLayer(
                            overlayImages: [
                              OverlayImage(
                                bounds: city.bounds,
                                opacity: 0.5,
                                imageProvider: MemoryImage(data),
                              )
                            ],
                          ),
                        ),
                      )
                    : OverlayImageLayer(
                        overlayImages: [
                          OverlayImage(
                            bounds: city.bounds,
                            opacity: 0.5,
                            imageProvider: MemoryImage(data),
                          )
                        ],
                      ),
              ),
        if (city != null && useImages && !useCombinedImages)
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
                        opacity: 0.75,
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
        PolygonLayer(
          polygonCulling: true,
          polygons: city?.polygons(
                fillColor: Theme.of(context).brightness == Brightness.light
                    ? null
                    : Colors.grey.withAlpha(75),
              ) ??
              [],
        ),
        if (!useImages)
          Builder(
            builder: (context) => useClipper
                ? ClipPath(
                    clipper: PolygonClipper(
                      map: FlutterMapState.maybeOf(context, nullOk: true),
                      polygons: city?.polygons(),
                    ),
                    child: Stack(children: maskLayers),
                  )
                : Stack(children: maskLayers),
          ),
      ],
    );

    return Stack(
      children: [
        map,
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton.tonal(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const MaskSelector(),
              ),
              child: const Text('Masks'),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: OSMContribution(),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Use polygon clipper'),
                        Checkbox(
                          value: useClipper,
                          onChanged: (value) =>
                              setState(() => useClipper = value ?? useClipper),
                        )
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Use images'),
                        Checkbox(
                          value: useImages,
                          onChanged: (value) =>
                              setState(() => useImages = value ?? useImages),
                        )
                      ],
                    ),
                    if (useImages)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Use combined images'),
                          Checkbox(
                            value: useCombinedImages,
                            onChanged: (value) => setState(
                              () => useCombinedImages =
                                  value ?? useCombinedImages,
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
