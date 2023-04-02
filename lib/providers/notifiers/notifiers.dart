import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:satreelight/models/sorting.dart';

/// A [StateNotifier] that containts theme mode state.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void set(ThemeMode themeMode) => state = themeMode;
}

/// A [StateNotifier] that contains theme color state.
class ColorSchemeNotifier extends StateNotifier<FlexScheme> {
  ColorSchemeNotifier() : super(FlexScheme.green);

  void setScheme(FlexScheme scheme) => state = scheme;

  void setSchemeIndex(int index) => state = FlexScheme.values[index];
}

/// A [StateNotifier] that says whether the home map is in the background.
class MapBackgroundNotifier extends StateNotifier<bool> {
  MapBackgroundNotifier() : super(true);

  void set(bool value) => state = value;
  void invert() => state = !state;
}

/// A notifier for triggering the home map to zoom in.
class MapZoomInNotifier extends ChangeNotifier {
  void start() {
    notifyListeners();
  }
}

/// A notifier for triggering the home map to zoom out.
class MapZoomOutNotifier extends ChangeNotifier {
  void start() {
    notifyListeners();
  }
}

/// Whether the CityDialog should show next/prev arrows in the top bar.
class ShowArrowsOnPopupNotifier extends StateNotifier<bool> {
  ShowArrowsOnPopupNotifier() : super(false);

  void set(bool value) => state = value;
  void invert() => state = !state;
}

/// A notifier keeping track of the selected masks.
class MaskSelectionNotifier extends ChangeNotifier {
  final List<bool> _masks =
      List.generate(CoverageType.values.length, (index) => true);

  List<bool> get masks => _masks;

  void updateMask(int index, bool value) {
    _masks[index] = value;
    notifyListeners();
  }

  void enableAll() {
    _masks.clear();
    _masks.addAll(List.generate(CoverageType.values.length, (index) => true));
    notifyListeners();
  }

  void disableAll() {
    _masks.clear();
    _masks.addAll(List.generate(CoverageType.values.length, (index) => false));
    notifyListeners();
  }
}

/// A notifier that keeps track of the selected city, if there is one.
class SelectedCityNotifier extends StateNotifier<City?> {
  SelectedCityNotifier() : super(null);

  void clear() => state = null;
  void set(City city) => state = city;
}

/// A notifier for keeping the city sorting state.
class SortingNotifier extends StateNotifier<Sorting> {
  SortingNotifier() : super(Sorting.alphabetically);

  void set(Sorting sorting) => state = sorting;
}

/// A notifier that keeps the state for whether the city list should be reversed.
class ReverseSortingNotifier extends StateNotifier<bool> {
  ReverseSortingNotifier() : super(false);

  void reverse() => state = !state;
  void setTrue() => state = true;
  void setFalse() => state = false;
}

/// A notifier containing the search string state.
class SearchStringNotifier extends StateNotifier<String> {
  SearchStringNotifier() : super('');

  void set(String string) => state = string;
  void clear() => state = '';
}
