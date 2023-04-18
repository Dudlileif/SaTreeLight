import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:satreelight/src/features/map/map.dart';

part 'map_providers.g.dart';

/// A provider for notifying when the map hasn't moved/changed for a
/// certain amount of time.
///
/// It triggers from false to true after a certain
/// amount of time after [restart] has been called. It starts of as true
/// and gets set to false when [restart] gets called.
@Riverpod(keepAlive: false)
class LastMapEventDelay extends _$LastMapEventDelay {
  Timer? timer;
  @override
  bool build() => true;

  void restart({Duration waitTime = const Duration(milliseconds: 500)}) {
    state = false;
    if (timer != null) {
      timer!.cancel();
    }
    timer = Timer(waitTime, () {
      state = true;
    });
  }
}

/// Provider for the map in background boolean state.
@riverpod
class MapInBackground extends _$MapInBackground {
  @override
  bool build() => true;

  void update({required bool newState}) => state = newState;
  void invert() => state = !state;
}

/// A stream controller provider for controlling the [MapView] zoom
/// in/out events.
@Riverpod(keepAlive: true)
class ZoomStreamController extends _$ZoomStreamController {
  @override
  StreamController<Zoom> build() => StreamController<Zoom>.broadcast();

  void zoomIn() => state.add(Zoom.zoomIn);
  void zoomOut() => state.add(Zoom.zoomOut);
}

/// A stream provider for the [MapView] zoom events.
@Riverpod(dependencies: [ZoomStreamController])
Stream<Zoom> zoomStream(ZoomStreamRef ref) =>
    ref.watch(zoomStreamControllerProvider).stream;
