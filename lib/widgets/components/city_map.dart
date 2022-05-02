import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/screens/leaflet_map/components/osm_contribution.dart';
import 'package:satreelight/screens/leaflet_map/components/themed_tiles_container.dart';

class CityMap extends StatefulWidget {
  final City city;
  final OverlayImage? overlayImage;
  const CityMap({Key? key, required this.city, this.overlayImage})
      : super(key: key);

  @override
  State<CityMap> createState() => _CityMapState();
}

class _CityMapState extends State<CityMap> {
  final MapController mapController = MapController();
  double minZoom = 3;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance?.addPostFrameCallback(
      (timeStamp) {
        minZoom = widget.city.centerZoom(mapController).zoom;
      },
    );

    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            center: widget.city.center,
            maxZoom: 18.25,
            minZoom: minZoom,
            swPanBoundary: widget.city.southWest,
            nePanBoundary: widget.city.northEast,
            enableScrollWheel: true,
            bounds: widget.city.bounds,
            boundsOptions: const FitBoundsOptions(
              padding: EdgeInsets.all(20),
            ),
          ),
          children: [
            TileLayerWidget(
              options: TileLayerOptions(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                tilesContainerBuilder: (context, tilesContainer, tiles) =>
                    ThemedTilesContainer(tilesContainer: tilesContainer),
              ),
            ),
            PolygonLayerWidget(
              options: PolygonLayerOptions(
                polygons: widget.city.polygons,
              ),
            ),
            OverlayImageLayerWidget(
              options: OverlayImageLayerOptions(
                overlayImages: widget.overlayImage != null
                    ? [widget.overlayImage!]
                    : const [],
              ),
            ),
          ],
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: OSMContribution(),
        ),
      ],
    );
  }
}
