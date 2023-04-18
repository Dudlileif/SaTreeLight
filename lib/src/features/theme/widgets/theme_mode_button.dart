import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/theme/theme.dart';

class ThemeModeButton extends ConsumerWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      padding: const EdgeInsets.all(8),
      tooltip: 'Light/Dark mode',
      onPressed: () {
        ref.read(activeThemeModeProvider.notifier).update(
              Theme.of(context).brightness == Brightness.light
                  ? ThemeMode.dark
                  : ThemeMode.light,
            );
      },
      icon: Icon(
        Theme.of(context).brightness == Brightness.light
            ? Icons.light_mode
            : Icons.dark_mode,
      ),
    );
  }
}
