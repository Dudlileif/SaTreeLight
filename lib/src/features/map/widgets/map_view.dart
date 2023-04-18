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
  List<City> cities = [];
  bool mapReady = false;
  bool inBackground = true;
  double initZoom = 3;
  double endZoom = 4;
  final LatLng usaCenter = LatLng(38, -97);
  MapController mapController = MapController();
  List<Marker> markers = [];

  late AnimationController zoomController;

  void initZoomAnim({bool zoomOut = false}) {
    zoomController = AnimationController(
      vsync: this,
      duration: AnimationConfig.duration,
    );
    final zoomAnim = CurvedAnimation(
      parent: zoomController,
      curve: zoomOut ? Curves.fastOutSlowIn.flipped : Curves.fastOutSlowIn,
    );
    zoomAnim.addListener(() {
      if (zoomOut) {
        final pos = LatLng(
          usaCenter.latitude -
              (1 - zoomAnim.value) *
                  (usaCenter.latitude - mapController.center.latitude),
          usaCenter.longitude -
              (1 - zoomAnim.value) *
                  (usaCenter.longitude - mapController.center.longitude),
        );
        final zoom =
            initZoom + (1 - zoomAnim.value) * (mapController.zoom - initZoom);
        mapController.move(pos, zoom);
      } else {
        mapController.move(
          usaCenter,
          initZoom + zoomAnim.value * (endZoom - initZoom),
        );
      }
    });
  }

  void setMarkers() {
    markers = List.generate(cities.length, (index) {
      return Marker(
        key: ValueKey(cities[index]),
        point: cities[index].center,
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 110,
        width: 110,
        builder: (context) => CityPin(
          city: cities[index],
          numberOfCities: cities.length,
        ),
      );
    });
  }

  void toBackground() {
    zoomController.dispose();
    initZoomAnim(zoomOut: true);
    zoomController.forward();
  }

  void toForeground() {
    zoomController.dispose();
    initZoomAnim();
    zoomController.forward();
  }

  @override
  void initState() {
    super.initState();
    initZoomAnim();
  }

  @override
  void dispose() {
    zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(citiesProvider).when(
          data: (data) {
            cities = data;
            setMarkers();
          },
          error: (error, stackTrace) => null,
          loading: () => null,
        );

    inBackground = ref.watch(mapInBackgroundProvider);

    ref.watch(zoomStreamProvider).when(
          data: (zoom) {
            switch (zoom) {
              case Zoom.zoomIn:
                toForeground();
                break;
              case Zoom.zoomOut:
                toBackground();
                break;
            }
          },
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
                maxZoom: 18.25,
                slideOnBoundaries: true,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  tilesContainerBuilder: themedTilesContainerBuilder,
                  tileProvider: CachedTileProvider(),
                  userAgentPackageName: 'satreelight',
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
