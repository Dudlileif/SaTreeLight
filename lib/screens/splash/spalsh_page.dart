import 'dart:ui';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/screens/leaflet_map/leaflet_map.dart';
import 'package:satreelight/screens/splash/components/start_menu.dart';

/// The landing/start page of the app. Contains the start menu with the map
/// in the background.
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapInBackground = ref.watch(mapInBackgroundProvider);

    return Scaffold(
      appBar: AppBar(
        title: mapInBackground ? const Text('Home') : const Text('Map'),
        leading: mapInBackground
            ? null
            : BackButton(onPressed: () {
                ref.read(mapInBackgroundProvider.notifier).set(true);
                ref.read(mapZoomOutProvider).start();
              }),
        actions: [
          IconButton(
            padding: const EdgeInsets.all(8),
            tooltip: 'Light/Dark mode',
            onPressed: () {
              ref.read(themeModeProvider.notifier).set(
                    Theme.of(context).brightness == Brightness.light
                        ? ThemeMode.dark
                        : ThemeMode.light,
                  );
            },
            icon: Icon(Theme.of(context).brightness == Brightness.light
                ? Icons.light_mode
                : Icons.dark_mode),
          ),
          PopupMenuButton<int>(
            onSelected: (int index) {
              ref.read(colorSchemeProvider.notifier).setSchemeIndex(index);
            },
            initialValue:
                FlexScheme.values.indexOf(ref.read(colorSchemeProvider)),
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              for (int colorSchemeIndex = 0;
                  colorSchemeIndex < FlexColor.schemesList.length;
                  colorSchemeIndex++)
                PopupMenuItem<int>(
                  value: colorSchemeIndex,
                  child: ListTile(
                    leading: Icon(Icons.lens,
                        color: Theme.of(context).brightness == Brightness.light
                            ? FlexColor
                                .schemesList[colorSchemeIndex].light.primary
                            : FlexColor
                                .schemesList[colorSchemeIndex].dark.primary,
                        size: 35),
                    title: Text(FlexColor.schemesList[colorSchemeIndex].name),
                  ),
                )
            ],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.lens,
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Theme.of(context).appBarTheme.backgroundColor,
                    size: 40,
                  ),
                  Icon(
                    Icons.color_lens,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          const LeafletMap(),
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
