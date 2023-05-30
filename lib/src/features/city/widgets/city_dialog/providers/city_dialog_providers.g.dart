// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_dialog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$showNextPrevArrowsHash() =>
    r'410967e4296bbd9a2a258c36a69a4cba34a8db60';

/// Provider for whether the CityDialog should show next/previous arrow buttons.
///
/// Copied from [ShowNextPrevArrows].
@ProviderFor(ShowNextPrevArrows)
final showNextPrevArrowsProvider =
    NotifierProvider<ShowNextPrevArrows, bool>.internal(
  ShowNextPrevArrows.new,
  name: r'showNextPrevArrowsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showNextPrevArrowsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowNextPrevArrows = Notifier<bool>;
String _$usePolygonClipperHash() => r'44dafc7ba1222373f191f2166c14f341822ced08';

/// Provider for whether the mask images should be clipped by the
/// city polygons.
///
/// Copied from [UsePolygonClipper].
@ProviderFor(UsePolygonClipper)
final usePolygonClipperProvider =
    NotifierProvider<UsePolygonClipper, bool>.internal(
  UsePolygonClipper.new,
  name: r'usePolygonClipperProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$usePolygonClipperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UsePolygonClipper = Notifier<bool>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
