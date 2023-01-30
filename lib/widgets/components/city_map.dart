import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/screens/leaflet_map/components/osm_contribution.dart';
import 'package:satreelight/screens/leaflet_map/components/themed_tiles_container.dart';

/// Provider for the map bounds, used to keep position on mask selection update.
final boundsProvider = StateProvider.autoDispose<LatLngBounds?>((ref) => null);

/// Provider for the map zoom, used to keep position on mask selection update.
final zoomProvider = StateProvider.autoDispose.family<double, MapController>(
    (ref, controller) =>
        ref.read(selectedCityProvider)?.centerZoom(controller).zoom ?? 7);

/// Provider for the map center, used to keep position on mask selection update.
final centerProvider = StateProvider.autoDispose<LatLng>(
    (ref) => ref.read(selectedCityProvider)?.center ?? LatLng(0, 0));

/// A map of the city, with a bounds polygon and selected masks.
class CityMap extends ConsumerStatefulWidget {
  const CityMap({Key? key}) : super(key: key);

  @override
  ConsumerState<CityMap> createState() => _CityMapState();
}

class _CityMapState extends ConsumerState<CityMap> {
  final MapController mapController = MapController();
  final boundsOptions = const FitBoundsOptions(padding: EdgeInsets.all(20));

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
            ref.watch(centerProvider), ref.watch(zoomProvider(mapController)));
      }
    });

    final city = ref.watch(loadCityDataProvider).when(
        error: (error, stackTrace) => null,
        loading: () => null,
        data: (data) {
          if (data != null) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              final bounds = data.boundsNew;
              ref.read(boundsProvider.notifier).update((state) => bounds);
              mapController.fitBounds(bounds, options: boundsOptions);
            });
          }
          return data;
        });

    final bounds = ref.watch(boundsProvider);

    /* final List<OverlayVegetationImage> overlayImages =
        ref.watch(cityImagesProvider(context)).when(
            loading: () => [],
            error: (error, stackTrace) => [],
            data: (data) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                ref.read(updatedMasks.notifier).update((state) => true);
              });
              return data;
            }); */

    final List<TileLayerWidget> maskLayers = ref.watch(cityMasksProvider).when(
        error: (error, stackTrace) => [],
        loading: () => [],
        data: (data) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            ref.read(updatedMasks.notifier).update((state) => true);
          });
          return data;
        });

/*     final imagesInsteadOfMasks = ref.watch(imagesInsteadOfMasksProvider);
 */
    final map = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        center: city?.center,
        maxZoom: 18.25,
        swPanBoundary: bounds?.southWest,
        nePanBoundary: bounds?.northEast,
        enableScrollWheel: true,
        bounds: bounds,
        boundsOptions: boundsOptions,
        slideOnBoundaries: true,
      ),
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
            tilesContainerBuilder: (context, tilesContainer, tiles) =>
                ThemedTilesContainer(tilesContainer: tilesContainer),
            backgroundColor: Colors.transparent,
          ),
        ),
        PolygonLayerWidget(
          options: PolygonLayerOptions(
            polygons: city?.polygonsNew ?? [],
          ),
        ),
        /*  if (imagesInsteadOfMasks)
          OverlayVegetationImageLayerWidget(
            options: OverlayVegetationImageLayerOptions(
                overlayImages: overlayImages),
          ), */
        /*         if (!imagesInsteadOfMasks)  */ ...maskLayers,
      ],
    );

    return Stack(
      children: [
        map,
        const Align(
          alignment: Alignment.bottomRight,
          child: OSMContribution(),
        ),
      ],
    );
  }
}
