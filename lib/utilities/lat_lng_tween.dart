import 'package:latlong2/latlong.dart';

/// A class for tweening two [LatLng].
///
/// Get the [LatLng] at any given fraction value with [evaluate].
class LatLngTween {
  const LatLngTween({required this.begin, required this.end});

  /// The starting position.
  final LatLng begin;

  /// The ending position.
  final LatLng end;

  /// Returns the [LatLng] in-between position for the fraction [value].
  /// [value] is clamped between 0 and 1.
  LatLng evaluate(double value) {
    final clampedValue = value.clamp(0, 1);

    final latitude =
        begin.latitude * (1 - clampedValue) + end.latitude * clampedValue;

    final longitude =
        begin.longitude * (1 - clampedValue) + end.longitude * clampedValue;

    return LatLng(latitude, longitude);
  }
}
