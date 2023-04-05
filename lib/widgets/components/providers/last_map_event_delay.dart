import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'last_map_event_delay.g.dart';

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
