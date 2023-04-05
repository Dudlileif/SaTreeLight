import 'package:flutter_map/plugin_api.dart';
import 'package:satreelight/utilities/lat_lng_tween.dart';

/// A class for tweening two [LatLngBounds].
///
/// Get the [LatLngBounds] at any given fraction value with [evaluate].
class LatLngBoundsTween {
  const LatLngBoundsTween({required this.begin, required this.end});

  /// The starting bounds/position.
  final LatLngBounds begin;

  /// The ending bounds/position.
  final LatLngBounds end;

  /// Returns the [LatLngBounds] in-between bounds/position for [value].
  /// [value] is divided by [maxValue] and then clamped between 0 and 1
  /// in case maxValue isn't set.
  LatLngBounds evaluate(double value, {double maxValue = 1}) {
    final clampedValue = (value / maxValue).clamp(0.0, 1.0);

    final northWest = LatLngTween(
      begin: begin.northWest,
      end: end.northWest,
    ).evaluate(clampedValue);

    final southEast = LatLngTween(
      begin: begin.southEast,
      end: end.southEast,
    ).evaluate(clampedValue);

    return LatLngBounds(
      northWest,
      southEast,
    );
  }
}
