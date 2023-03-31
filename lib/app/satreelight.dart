import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/screens/splash/spalsh_page.dart';

/// The main app of the program. It is essentially a themed [MaterialApp].
class SaTreeLight extends ConsumerWidget {
  SaTreeLight({super.key});
  final fontFamily = GoogleFonts.notoSansMono().fontFamily;

  // Helpful website for theming
  // https://rydmike.com/flexcolorschemeV4Tut5/#/

  /// Gets the light theme for the given color scheme.
  ThemeData _lightTheme(FlexScheme scheme) {
    return FlexThemeData.light(
      scheme: scheme,
      blendLevel: 9,
      appBarOpacity: 0.90,
      fontFamily: fontFamily,
      tabBarStyle: FlexTabBarStyle.forBackground,
      tooltipsMatchBackground: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        navigationBarHeight: 80,
      ),
      swapLegacyOnMaterial3: true,
    );
  }

  /// Gets the dark theme for the given color scheme.
  ThemeData _darkTheme(FlexScheme scheme) {
    return FlexThemeData.dark(
      scheme: scheme,
      blendLevel: 15,
      appBarOpacity: 0.90,
      fontFamily: fontFamily,
      tabBarStyle: FlexTabBarStyle.forBackground,
      tooltipsMatchBackground: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      useMaterial3ErrorColors: true,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        navigationBarHeight: 80,
      ),
      swapLegacyOnMaterial3: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FlexScheme scheme = ref.watch(colorSchemeProvider);
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'SaTreeLight',
      theme: _lightTheme(scheme),
      darkTheme: _darkTheme(scheme),
      themeMode: themeMode,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
