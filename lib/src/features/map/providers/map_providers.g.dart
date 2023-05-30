// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$zoomStreamHash() => r'dc8ea53c52065dc6a917cbe07b72c5559b8a9788';

/// A stream provider for the [MapView] zoom events.
///
/// Copied from [zoomStream].
@ProviderFor(zoomStream)
final zoomStreamProvider = AutoDisposeStreamProvider<Zoom>.internal(
  zoomStream,
  name: r'zoomStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$zoomStreamHash,
  dependencies: <ProviderOrFamily>[zoomStreamControllerProvider],
  allTransitiveDependencies: <ProviderOrFamily>{
    zoomStreamControllerProvider,
    ...?zoomStreamControllerProvider.allTransitiveDependencies
  },
);

typedef ZoomStreamRef = AutoDisposeStreamProviderRef<Zoom>;
String _$lastMapEventDelayHash() => r'6ec3d5e7bf3c81664ca70e7d7d004e34fcc4c9c3';

/// A provider for notifying when the map hasn't moved/changed for a
/// certain amount of time.
///
/// It triggers from false to true after a certain
/// amount of time after [restart] has been called. It starts of as true
/// and gets set to false when [restart] gets called.
///
/// Copied from [LastMapEventDelay].
@ProviderFor(LastMapEventDelay)
final lastMapEventDelayProvider =
    AutoDisposeNotifierProvider<LastMapEventDelay, bool>.internal(
  LastMapEventDelay.new,
  name: r'lastMapEventDelayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastMapEventDelayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LastMapEventDelay = AutoDisposeNotifier<bool>;
String _$mapInBackgroundHash() => r'e7a8212672a4a2f0b3e529fb7a35d13ba77b543f';

/// Provider for the map in background boolean state.
///
/// Copied from [MapInBackground].
@ProviderFor(MapInBackground)
final mapInBackgroundProvider =
    AutoDisposeNotifierProvider<MapInBackground, bool>.internal(
  MapInBackground.new,
  name: r'mapInBackgroundProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mapInBackgroundHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MapInBackground = AutoDisposeNotifier<bool>;
String _$zoomStreamControllerHash() =>
    r'6191b9a8bf10745d5b0af638b33764c324f046ed';

/// A stream controller provider for controlling the [MapView] zoom
/// in/out events.
///
/// Copied from [ZoomStreamController].
@ProviderFor(ZoomStreamController)
final zoomStreamControllerProvider =
    NotifierProvider<ZoomStreamController, StreamController<Zoom>>.internal(
  ZoomStreamController.new,
  name: r'zoomStreamControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$zoomStreamControllerHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

typedef _$ZoomStreamController = Notifier<StreamController<Zoom>>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
