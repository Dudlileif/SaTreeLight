import 'package:flutter/animation.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:satreelight/models/tweens/lat_lng_tween.dart';

/// A class for tweening two [LatLngBounds].
///
/// Get the [LatLngBounds] at any given fraction value with [evaluate].
class LatLngBoundsTween extends Tween<LatLngBounds> {
  /// Creates a [LatLngBounds] tween.
  ///
  /// The [begin] and [end] properties must be non-null before the tween is
  /// first used, but the arguments can be null if the values are going to be
  /// filled in later.
  LatLngBoundsTween({super.begin, super.end});

  // The inherited lerp() function doesn't work with LatLngBounds because it is
  // a complex object with two LatLng objects that individually needs to be
  // interpolated.
  @override
  LatLngBounds lerp(double t) {
    final northWest = LatLngTween(
      begin: begin!.northWest,
      end: end!.northWest,
    ).transform(t);

    final southEast = LatLngTween(
      begin: begin!.southEast,
      end: end!.southEast,
    ).transform(t);

    return LatLngBounds(
      northWest,
      southEast,
    );
  }
}
