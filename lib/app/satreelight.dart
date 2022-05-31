import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:satreelight/main.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/screens/splash/spalsh_page.dart';

class SaTreeLight extends ConsumerWidget {
  SaTreeLight({Key? key, required this.cities}) : super(key: key);
  final List<City> cities;
  final fontFamily = GoogleFonts.notoSansMono().fontFamily;

  // Helpful website for theming
  // https://rydmike.com/flexcolorschemeV4Tut5/#/

  ThemeData _lightTheme(FlexScheme scheme) {
    return FlexThemeData.light(
      scheme: scheme,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 18,
      appBarStyle: FlexAppBarStyle.primary,
      appBarOpacity: 0.95,
      appBarElevation: 0,
      transparentStatusBar: true,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      tooltipsMatchBackground: true,
      swapColors: false,
      lightIsWhite: false,
      useMaterial3: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: fontFamily,
      subThemesData: const FlexSubThemesData(),
    );
  }

  ThemeData _darkTheme(FlexScheme scheme) {
    return FlexThemeData.dark(
      scheme: scheme,
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      blendLevel: 18,
      appBarStyle: FlexAppBarStyle.background,
      appBarOpacity: 0.95,
      appBarElevation: 0,
      transparentStatusBar: true,
      tabBarStyle: FlexTabBarStyle.forAppBar,
      tooltipsMatchBackground: true,
      swapColors: false,
      darkIsTrueBlack: false,
      useMaterial3: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      fontFamily: fontFamily,
      subThemesData: const FlexSubThemesData(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FlexScheme scheme = ref.watch(colorSchemeProvider).scheme;
    final ThemeMode themeMode = ref.watch(themeModeProvider).themeMode;

    return MaterialApp(
      title: 'SaTreeLight',
      theme: _lightTheme(scheme),
      darkTheme: _darkTheme(scheme),
      themeMode: themeMode,
      home: SplashPage(cities: cities),
      debugShowCheckedModeBanner: false,
    );
  }
}
