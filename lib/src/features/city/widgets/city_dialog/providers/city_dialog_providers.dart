import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'city_dialog_providers.g.dart';

/// Provider for whether the CityDialog should show next/previous arrow buttons.
@Riverpod(keepAlive: true)
class ShowNextPrevArrows extends _$ShowNextPrevArrows {
  @override
  bool build() => false;

  void update({required bool newState}) => state = newState;
  void invert() => state = !state;
}

/// Provider for whether the mask images should be clipped by the
/// city polygons.
@Riverpod(keepAlive: true)
class UsePolygonClipper extends _$UsePolygonClipper {
  @override
  bool build() => true;

  void update({required bool value}) => state = value;
}
