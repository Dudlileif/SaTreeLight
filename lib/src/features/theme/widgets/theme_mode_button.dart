import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/theme/theme.dart';

class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(activeThemeModeProvider);

    return IconButton(
      padding: const EdgeInsets.all(8),
      tooltip: 'Light/Dark/System theme mode',
      onPressed: () {
        ref.read(activeThemeModeProvider.notifier).update(
              switch (themeMode) {
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
                ThemeMode.system => ThemeMode.light,
              },
            );
      },
      icon: Icon(
        switch (themeMode) {
          ThemeMode.light => Icons.light_mode,
          ThemeMode.dark => Icons.dark_mode,
          ThemeMode.system => Icons.settings_brightness,
        },
      ),
    );
  }
}
