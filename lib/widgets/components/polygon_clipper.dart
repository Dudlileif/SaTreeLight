import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart' show LatLng;

class PolygonClipper extends CustomClipper<Path> {
  final FlutterMapState? map;
  final List<Polygon>? polygons;

  const PolygonClipper({
    this.map,
    this.polygons,
  });

  @override
  Path getClip(Size size) {
    if (polygons != null && map != null) {
      final Path path = Path();
      for (Polygon polygon in polygons!) {
        final List<Offset> offsets = [];
        for (LatLng point in polygon.points) {
          final screenPoint = map!.getOffsetFromOrigin(point);
          offsets.add(screenPoint);
        }
        path.addPolygon(offsets, true);
      }
      return path;
    }

    return Path()..addRect(Rect.largest);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) =>
      oldClipper != this;
}
