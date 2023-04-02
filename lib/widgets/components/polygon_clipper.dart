import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';

class PolygonClipper extends CustomClipper<Path> {

  const PolygonClipper({
    this.map,
    this.polygons,
  });
  final FlutterMapState? map;
  final List<Polygon>? polygons;

  @override
  Path getClip(Size size) {
    if (polygons != null && map != null) {
      final path = Path();
      for (final polygon in polygons!) {
        final offsets = <Offset>[];
        for (final point in polygon.points) {
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
