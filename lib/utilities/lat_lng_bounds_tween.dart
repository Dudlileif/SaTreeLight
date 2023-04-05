import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';

/// A class for tweening two [LatLngBounds].
///
/// Get the [LatLngBounds] at any given fraction value with [evaluate].
class LatLngBoundsTween {
  const LatLngBoundsTween({required this.begin, required this.end});

  /// The starting bounds/position.
  final LatLngBounds begin;

  /// The ending bounds/position.
  final LatLngBounds end;

  /// Returns the [LatLngBounds] in-between position for the fraction [value].
  /// [value] is clamped between 0 and 1.
  LatLngBounds evaluate(double value) {
    final clampedValue = value.clamp(0, 1);
    final northWest = LatLng(
      begin.northWest.latitude * (1 - clampedValue) +
          end.northWest.latitude * clampedValue,
      begin.northWest.longitude * (1 - clampedValue) +
          end.northWest.longitude * clampedValue,
    );
    final southEast = LatLng(
      begin.southEast.latitude * (1 - clampedValue) +
          end.southEast.latitude * clampedValue,
      begin.southEast.longitude * (1 - clampedValue) +
          end.southEast.longitude * clampedValue,
    );

    return LatLngBounds(
      northWest,
      southEast,
    );
  }
}
