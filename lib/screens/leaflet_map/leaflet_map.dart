import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_controller/map_controller.dart';
import 'package:satreelight/main.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/screens/leaflet_map/components/city_pin.dart';
import 'package:satreelight/screens/leaflet_map/components/city_pin_cluster.dart';
import 'package:satreelight/screens/leaflet_map/components/osm_contribution.dart';
import 'package:satreelight/screens/leaflet_map/components/themed_tiles_container.dart';

class LeafletMap extends ConsumerStatefulWidget {
  final List<City> cities;
  const LeafletMap({required this.cities, Key? key}) : super(key: key);

  @override
  ConsumerState<LeafletMap> createState() => _LeafletMapState();
}

class _LeafletMapState extends ConsumerState<LeafletMap>
    with TickerProviderStateMixin {
  bool mapReady = false;
  bool inBackground = true;
  double initZoom = 3;
  double endZoom = 4;
  final LatLng usaCenter = LatLng(38, -97);
  MapController mapController = MapController();
  List<Marker> markers = [];

  late StatefulMapController statefulMapController;
  late StreamSubscription<StatefulMapControllerStateChange> mapStateChange;
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
    markers = List.generate(widget.cities.length, (index) {
      return Marker(
        point: widget.cities[index].center,
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 110,
        width: 110,
        builder: (context) => CityPin(
          city: widget.cities[index],
          size: 40,
          numberOfCities: widget.cities.length,
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
    setMarkers();
    initZoomAnim();
    statefulMapController = StatefulMapController(mapController: mapController);
    mapStateChange = statefulMapController.changeFeed.listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    inBackground = ref.watch(mapInBackgroundProvider).mapInBackground;
    ref.listen(mapZoomInProvider, (_old, _new) {
      toForeground();
    });
    ref.listen(mapZoomOutProvider, (_old, _new) {
      toBackground();
    });

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
                plugins: [
                  MarkerClusterPlugin(),
                ],
                slideOnBoundaries: true,
              ),
              children: [
                TileLayerWidget(
                  options: TileLayerOptions(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    tilesContainerBuilder: (context, tilesContainer, tiles) =>
                        ThemedTilesContainer(tilesContainer: tilesContainer),
                  ),
                ),
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
        const Align(
          alignment: Alignment.bottomRight,
          child: OSMContribution(),
        )
      ],
    );
  }
}
