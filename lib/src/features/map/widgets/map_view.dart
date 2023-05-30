import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/src/features/animation/animation.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/map/map.dart';
import 'package:satreelight/src/features/mask_selection/mask_selection.dart';

/// The map used behind the main menu.
/// The map can be brought out of the background.
class MapView extends ConsumerStatefulWidget {
  const MapView({super.key});

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView>
    with TickerProviderStateMixin {
  double get initZoom => 3;
  double get endZoom => 4;
  LatLng get usaCenter => LatLng(38, -97);

  final MapController mapController = MapController();
  late AnimationController animationController =
      AnimationController(vsync: this);

  List<City> cities = [];
  List<Marker> markers = [];

  bool mapReady = false;
  bool inBackground = true;

  void zoomOutListener() {
    final pos = LatLngTween(begin: mapController.center, end: usaCenter)
        .evaluate(animationController);
    final zoom = Tween<double>(begin: mapController.zoom, end: initZoom)
        .evaluate(animationController);
    mapController.move(pos, zoom);
  }

  void zoomInListener() {
    mapController.move(
      usaCenter,
      Tween<double>(begin: initZoom, end: endZoom)
          .evaluate(animationController),
    );
  }

  void setMarkers() {
    markers = cities
        .map(
          (city) => Marker(
            key: ValueKey(city),
            point: city.center,
            anchorPos: AnchorPos.align(AnchorAlign.center),
            height: 110,
            width: 110,
            builder: (context) => CityPin(
              city: city,
              numberOfCities: cities.length,
            ),
          ),
        )
        .toList();
  }

  void zoom(Zoom zoomAction) {
    animationController.dispose();
    animationController = AnimationController(vsync: this);
    animationController
      ..addListener(
        zoomAction == Zoom.zoomIn ? zoomInListener : zoomOutListener,
      )
      ..animateTo(
        1,
        duration: AnimationConfig.duration,
        curve: AnimationConfig.curve,
      );
  }

  @override
  void dispose() {
    animationController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(citiesProvider).when(
          data: (data) {
            cities = data;
            setMarkers();
          },
          error: (error, stackTrace) {},
          loading: () {},
        );

    inBackground = ref.watch(mapInBackgroundProvider);

    ref.watch(zoomStreamProvider).when(
          data: zoom,
          error: (error, stackTrace) {},
          loading: () {},
        );

    return Stack(
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return FlutterMap(
              mapController: mapController,
              options: MapOptions(
                interactiveFlags: !inBackground
                    ? InteractiveFlag.all & ~InteractiveFlag.rotate
                    : InteractiveFlag.none,
                enableScrollWheel: !inBackground,
                center: usaCenter,
                zoom: initZoom,
                maxZoom: 20,
                slideOnBoundaries: true,
              ),
              children: [
                themedTileLayerBuilder(
                  context,
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    tileProvider: CachedTileProvider(),
                    userAgentPackageName: 'satreelight',
                    maxNativeZoom: 19,
                    maxZoom: 20,
                  ),
                ),
                if (!inBackground)
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      showPolygon: false,
                      maxClusterRadius: 120,
                      size: Size(
                        MediaQuery.of(context).textScaleFactor * 55,
                        MediaQuery.of(context).textScaleFactor * 30,
                      ),
                      markers: markers,
                      builder: (context, localMarkers) {
                        return CityPinCluster(
                          count: localMarkers.length,
                        );
                      },
                      fitBoundsOptions: FitBoundsOptions(
                        padding: EdgeInsets.symmetric(
                          vertical: constraints.biggest.height * 0.2,
                          horizontal: constraints.biggest.width * 0.2,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton.tonal(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const MaskSelectionDialog(),
              ),
              child: const Text('Masks'),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: OSMContribution(),
        )
      ],
    );
  }
}
