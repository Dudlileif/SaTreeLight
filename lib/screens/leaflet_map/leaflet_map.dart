import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/skip_missing_file_tile_provider.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/screens/leaflet_map/components/city_pin.dart';
import 'package:satreelight/screens/leaflet_map/components/city_pin_cluster.dart';
import 'package:satreelight/screens/leaflet_map/components/osm_contribution.dart';
import 'package:satreelight/screens/leaflet_map/components/themed_tiles_container.dart';
import 'package:satreelight/widgets/components/mask_selector.dart';

/// The map used behind the main menu. The map can be brought out of the background.
class LeafletMap extends ConsumerStatefulWidget {
  const LeafletMap({super.key});

  @override
  ConsumerState<LeafletMap> createState() => _LeafletMapState();
}

class _LeafletMapState extends ConsumerState<LeafletMap>
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
      lowerBound: 0,
      upperBound: 1,
      duration: const Duration(
        milliseconds: 500,
      ),
    );
    final zoomAnim = CurvedAnimation(
        parent: zoomController,
        curve: zoomOut ? Curves.fastOutSlowIn.flipped : Curves.fastOutSlowIn);
    zoomAnim.addListener(() {
      if (zoomOut) {
        final pos = LatLng(
            usaCenter.latitude -
                (1 - zoomAnim.value) *
                    (usaCenter.latitude - mapController.center.latitude),
            usaCenter.longitude -
                (1 - zoomAnim.value) *
                    (usaCenter.longitude - mapController.center.longitude));
        final zoom =
            initZoom + (1 - zoomAnim.value) * (mapController.zoom - initZoom);
        mapController.move(pos, zoom);
      } else {
        mapController.move(
            usaCenter, initZoom + zoomAnim.value * (endZoom - initZoom));
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
          size: 40,
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
    ref.listen(mapZoomInProvider, (old, _) {
      toForeground();
    });
    ref.listen(mapZoomOutProvider, (old, _) {
      toBackground();
    });

    final String path = kIsWeb
        ? '../SaTreeLight-data-processing/export'
        : Platform.isLinux
            ? '/home/gaute/Documents/Projects/SaTreeLight/Sentinelsat/export'
            : 'E:/Projects/SaTreeLight-data-processing/export';

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
                  tilesContainerBuilder: (context, tilesContainer, tiles) =>
                      ThemedTilesContainer(tilesContainer: tilesContainer),
                ),
                ...ref
                    .watch(imageMasksProvider)
                    .map(
                      (mask) => TileLayer(
                        tileProvider:
                            !kIsWeb ? SkipMissingFileTileProvider() : null,
                        urlTemplate:
                            '$path/tiles/merged/${mask.string}/{z}/{x}/{y}.png',
                        backgroundColor: Colors.transparent,
                        minNativeZoom: 0,
                        maxNativeZoom: 14,
                        tms: true,
                        tilesContainerBuilder:
                            (context, tilesContainer, tiles) =>
                                MaskTilesContainer(
                          tilesContainer: tilesContainer,
                          mask: mask,
                        ),
                      ),
                    )
                    .toList(),
                if (!inBackground)
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      showPolygon: false,
                      maxClusterRadius: 120,
                      size: Size(MediaQuery.of(context).textScaleFactor * 55,
                          MediaQuery.of(context).textScaleFactor * 30),
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
                      zoomToBoundsOnClick: true,
                      centerMarkerOnClick: true,
                    ),
                  ),
              ],
            );
          },
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton.tonal(
              onPressed: () => showDialog(
                  context: context, builder: (context) => const MaskSelector()),
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
