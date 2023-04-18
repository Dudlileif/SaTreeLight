import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/home/widgets/start_menu.dart';
import 'package:satreelight/src/features/map/map.dart';
import 'package:satreelight/src/features/theme/theme.dart';

/// The landing/start page of the app. Contains the start menu with the map
/// in the background.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapInBackground = ref.watch(mapInBackgroundProvider);

    return Scaffold(
      appBar: AppBar(
        title: mapInBackground ? const Text('Home') : const Text('Map'),
        leading: mapInBackground
            ? null
            : BackButton(
                onPressed: () {
                  ref
                      .read(mapInBackgroundProvider.notifier)
                      .update(newState: true);
                  ref.read(zoomStreamControllerProvider.notifier).zoomOut();
                },
              ),
        actions: const [
          ThemeModeButton(),
          ColorThemeSelector(),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          const MapView(),
          if (mapInBackground)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: const StartMenu(),
            ),
        ],
      ),
    );
  }
}
