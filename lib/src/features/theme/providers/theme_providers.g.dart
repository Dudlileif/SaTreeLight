// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$activeThemeModeHash() => r'f5b5cc7c176c2994867585e28cd225e432976fdb';

/// A provider that contains the current theme mode state.
///
/// Copied from [ActiveThemeMode].
@ProviderFor(ActiveThemeMode)
final activeThemeModeProvider =
    AutoDisposeNotifierProvider<ActiveThemeMode, ThemeMode>.internal(
  ActiveThemeMode.new,
  name: r'activeThemeModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeThemeModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveThemeMode = AutoDisposeNotifier<ThemeMode>;
String _$colorSchemeHash() => r'9a80de9d084fb4159b0085dcb3aaa1ee19bcca4f';

/// A provider that contains theme color state.
///
/// Copied from [ColorScheme].
@ProviderFor(ColorScheme)
final colorSchemeProvider =
    AutoDisposeNotifierProvider<ColorScheme, FlexScheme>.internal(
  ColorScheme.new,
  name: r'colorSchemeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$colorSchemeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ColorScheme = AutoDisposeNotifier<FlexScheme>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
