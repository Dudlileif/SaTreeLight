import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

/// A provider that contains the current theme mode state.
@riverpod
class ActiveThemeMode extends _$ActiveThemeMode {
  @override
  ThemeMode build() => ThemeMode.system;

  void update(ThemeMode newMode) => state = newMode;
}

/// A provider that contains theme color state.
@riverpod
class ColorScheme extends _$ColorScheme {
  @override
  FlexScheme build() => FlexScheme.green;

  void update(FlexScheme newScheme) => state = newScheme;

  void updateByIndex(int index) => state = FlexScheme.values[index];
}
