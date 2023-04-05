import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'city_layer_options.g.dart';

@Riverpod(keepAlive: true)
class UsePolygonClipper extends _$UsePolygonClipper {
  @override
  bool build() => true;

  void update({required bool value}) => state = value;
}

@Riverpod(keepAlive: true)
class UseCombinedImage extends _$UseCombinedImage {
  @override
  bool build() => false;

  void update({required bool value}) => state = value;
}

@Riverpod(keepAlive: true)
class UseImages extends _$UseImages {
  @override
  bool build() => true;

  void update({required bool value}) => state = value;
}
