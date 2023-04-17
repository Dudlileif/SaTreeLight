import 'dart:async';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:satreelight/models/sorting.dart';
import 'package:satreelight/providers/notifiers/notifiers.dart';

part 'providers.g.dart';

/// Provider for the theme mode state.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Provider for the color scheme state.
final colorSchemeProvider =
    StateNotifierProvider<ColorSchemeNotifier, FlexScheme>(
  (ref) => ColorSchemeNotifier(),
);

/// Provider for the map in background boolean state.
final mapInBackgroundProvider =
    StateNotifierProvider<MapBackgroundNotifier, bool>(
  (ref) => MapBackgroundNotifier(),
);

/// Provider for starting home map zoom in.
final mapZoomInProvider = ChangeNotifierProvider((ref) => MapZoomInNotifier());

/// Provider for starting home map zoom out.
final mapZoomOutProvider =
    ChangeNotifierProvider((ref) => MapZoomOutNotifier());

/// Provider for whether the CityDialog should show next/previous arrow buttons.
final showArrowsOnCityDialogProvider =
    StateNotifierProvider<ShowArrowsOnPopupNotifier, bool>(
  (ref) => ShowArrowsOnPopupNotifier(),
);

/// Provider for the cities.
final citiesProvider = FutureProvider<List<City>>(
  (ref) async => CitiesUtilities.loadCities(),
);

/// Provider for the city sorting state.
final sortingProvider =
    StateNotifierProvider<SortingNotifier, Sorting>((ref) => SortingNotifier());

/// Provider for whether to reverse the sorting.
final reverseSortingProvider =
    StateNotifierProvider<ReverseSortingNotifier, bool>(
  (ref) => ReverseSortingNotifier(),
);

/// Provider for the search string state.
final searchStringProvider =
    StateNotifierProvider<SearchStringNotifier, String>((ref) {
  return SearchStringNotifier();
});

/// Provider for the sorted city list.
final sortedCitiesProvider = Provider<List<City>>((ref) {
  var cities = ref.watch(citiesProvider).when(
        data: (data) => data,
        error: (error, stackTrace) => <City>[],
        loading: () => <City>[],
      );
  switch (ref.watch(sortingProvider)) {
    case Sorting.alphabetically:
      cities.sort((a, b) => a.name.compareTo(b.name));
      break;
    case Sorting.happiness:
      cities.sort((a, b) => a.happinessScore.compareTo(b.happinessScore));
      break;
    case Sorting.vegetation:
      cities.sort((a, b) => a.vegFrac.compareTo(b.vegFrac));
      break;
  }
  final searchString = ref.watch(searchStringProvider);
  if (searchString != '') {
    cities = cities
        .where(
          (city) =>
              city.nameAndState.toLowerCase().contains(
                    searchString.toLowerCase(),
                  ) ||
              city.stateLong.toLowerCase().contains(
                    searchString.toLowerCase(),
                  ),
        )
        .toList();
  }

  if (ref.watch(reverseSortingProvider)) {
    return cities.reversed.toList();
  }
  return cities;
});

/// Provider for the selected city.
final selectedCityProvider = StateNotifierProvider<SelectedCityNotifier, City?>(
  (ref) => SelectedCityNotifier(),
);

/// Provider for loading the city data.
@riverpod
FutureOr<City?> loadCityData(LoadCityDataRef ref, City? city) async =>
    await city?.loadWithData();

/// Provider for whether the coverage is absolute or relative.
final relativeProvider = StateProvider<bool>((ref) => false);

@Riverpod(keepAlive: true)
class SelectedMasks extends _$SelectedMasks {
  @override
  List<CoverageType> build() => CoverageType.values;

  void add(CoverageType type) => state = [...state..add(type)]..sort(
      (a, b) => a.index.compareTo(b.index),
    );

  void remove(CoverageType type) =>
      state = [...state.where((element) => element != type)]..sort(
          (a, b) => a.index.compareTo(b.index),
        );

  void update(CoverageType type) =>
      state.contains(type) ? remove(type) : add(type);

  void addAll(List<CoverageType> types) => state = [
        ...state,
        ...types.where((element) => !state.contains(element))
      ]..sort((a, b) => a.index.compareTo(b.index));

  void removeMany(List<CoverageType> types) => state = [
        ...state.where((element) => !state.contains(element))
      ]..sort((a, b) => a.index.compareTo(b.index));

  void disableAll() => state = [];

  void enableAll() => state = CoverageType.values;
}

@Riverpod(keepAlive: true)
class UsePolygonClipper extends _$UsePolygonClipper {
  @override
  bool build() => true;

  void update({required bool value}) => state = value;
}

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
