import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

/// A [CustomClipper] clipping by a list of polygons.
///
/// Be aware the it can be quite compute-heavy if there are many
/// polygons, especially ones with many holes.
/// By adding a delay after the last [MapEvent] or movement and then
/// triggering the clipper can make a decent compromise, as we don't have to
/// compute on the fly whilst moving.
class PolygonClipper extends CustomClipper<Path> {
  const PolygonClipper({
    this.map,
    this.polygons,
    this.withHoles = true,
    this.zoomThreshold = 13,
    this.zoomHoleThreshold,
  });

  /// The state of the currently shown map. Used to get offsets and bounds
  /// for the polygons.
  final FlutterMapState? map;

  /// The list of polygons to clip by. The area within the polygons are kept.
  final List<Polygon>? polygons;

  /// Whether to clip out the holes in the polygons.
  final bool withHoles;

  /// At which zoom level the clipper should engage.
  /// Limit to higher zoom levels for better performance.
  /// Usually at lower levels there is negligible visual difference.
  final double zoomThreshold;

  /// At which zoom level the clipper should cut out polygon holes.
  /// If not set the holes will be cut at the [zoomThreshold].
  /// Holes will only be cut out if [zoomHoleThreshold] >= [zoomThreshold].
  final double? zoomHoleThreshold;

  @override
  Path getClip(Size size) {
    if (polygons != null && map != null) {
      if (map!.zoom >= zoomThreshold) {
        final polygonPaths = Path();
        final holePaths = Path();
        for (final polygon in polygons!) {
          // Only check polygons within the map bounds
          if (LatLngBounds.fromPoints(polygon.points)
              .isOverlapping(map!.bounds)) {
            final offsets = <Offset>[];
            for (final point in polygon.points) {
              final screenPoint = map!.getOffsetFromOrigin(point);
              offsets.add(screenPoint);
            }
            polygonPaths.addPolygon(offsets, false);

            // Polygon holes
            if (withHoles &&
                map!.zoom >= (zoomHoleThreshold ?? zoomThreshold)) {
              if (polygon.holePointsList != null) {
                for (final hole in polygon.holePointsList!) {
                  if (LatLngBounds.fromPoints(hole)
                      .isOverlapping(map!.bounds)) {
                    final holeOffsets = <Offset>[];
                    for (final point in hole) {
                      final screenPoint = map!.getOffsetFromOrigin(point);
                      holeOffsets.add(screenPoint);
                    }
                    holePaths.addPolygon(holeOffsets, true);
                  }
                }
              }
            }
          }
        }
        return Path.combine(PathOperation.difference, polygonPaths, holePaths);
      }
    }

    return Path()..addRect(Rect.largest);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
