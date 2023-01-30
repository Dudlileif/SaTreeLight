import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:satreelight/models/sorting.dart';
import 'package:satreelight/providers/notifiers/notifiers.dart';
import 'package:satreelight/screens/leaflet_map/components/themed_tiles_container.dart';

/// Provider for the theme mode state.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
    (ref) => ThemeModeNotifier());

/// Provider for the color scheme state.
final colorSchemeProvider =
    StateNotifierProvider<ColorSchemeNotifier, FlexScheme>(
        (ref) => ColorSchemeNotifier());

/// Provider for the map in background boolean state.
final mapInBackgroundProvider =
    StateNotifierProvider<MapBackgroundNotifier, bool>(
        (ref) => MapBackgroundNotifier());

/// Provider for starting home map zoom in.
final mapZoomInProvider = ChangeNotifierProvider((ref) => MapZoomInNotifier());

/// Provider for starting home map zoom out.
final mapZoomOutProvider =
    ChangeNotifierProvider((ref) => MapZoomOutNotifier());

/// Provider for whether the StatPopup should show next/previous arrow buttons.
final showArrowsOnPopupProvider =
    StateNotifierProvider<ShowArrowsOnPopupNotifier, bool>(
        (ref) => ShowArrowsOnPopupNotifier());

/// Provider for the selected mask state.
final maskSelectionProvider =
    ChangeNotifierProvider((ref) => MaskSelectionNotifier());

/// Provider for the cities.
final citiesProvider = FutureProvider<List<City>>(
    (ref) async => await CitiesUtilities.loadCities());

/// Provider for the city sorting state.
final sortingProvider =
    StateNotifierProvider<SortingNotifier, Sorting>((ref) => SortingNotifier());

/// Provider for whether to reverse the sorting.
final reverseSortingProvider =
    StateNotifierProvider<ReverseSortingNotifier, bool>(
        (ref) => ReverseSortingNotifier());

/// Provider for the search string state.
final searchStringProvider =
    StateNotifierProvider<SearchStringNotifier, String>((ref) {
  return SearchStringNotifier();
});

/// Provider for the sorted city list.
final sortedCitiesProvider = Provider<List<City>>((ref) {
  List<City> cities = ref.watch(citiesProvider).when(
        data: (data) => data,
        error: (error, stackTrace) => [],
        loading: () => [],
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
    default:
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
    (ref) => SelectedCityNotifier());

/// Provider for loading the city data.
final loadCityDataProvider = FutureProvider.autoDispose<City?>(
    (ref) async => await ref.watch(selectedCityProvider)?.loadWithData());

/// Provider for the selected image masks.
final imageMasksProvider = Provider<List<CoverageType>>((ref) {
  List<CoverageType> masks = [];
  final selectedMasks = ref.watch(maskSelectionProvider).masks;
  for (int i = 0; i < selectedMasks.length; i++) {
    if (selectedMasks[i]) {
      masks.add(CoverageType.values[i]);
    }
  }
  return masks;
});

/* final cityImagesProvider = FutureProvider.autoDispose
    .family<List<OverlayVegetationImage>, BuildContext>((ref, context) async {
  final city = ref.watch(loadCityDataProvider).when(
      data: (data) => data,
      error: (error, stackTrace) => null,
      loading: () => null);
  final List<OverlayVegetationImage> images = [];
  if (city != null) {
    final List<CoverageType> masks = ref.watch(imageMasksProvider);
    final overlayImages = await city.getImages(
      masks: masks,
      colors: CoverageColors().colorMapWithOpacity(
        dark: Theme.of(context).brightness == Brightness.dark,
        opacity: 0.5,
      ),
    );
    images.addAll(overlayImages);
  }

  return images;
}); */

/// Provider for the selected masks' tile servers.
final cityMasksProvider =
    FutureProvider.autoDispose<List<TileLayerWidget>>((ref) async {
  final city = ref.watch(loadCityDataProvider).when(
      data: (data) => data,
      error: (error, stackTrace) => null,
      loading: () => null);
  final List<CoverageType> masks = ref.watch(imageMasksProvider);

  if (city != null) {
    return List.generate(masks.length, (index) {
      final mask = masks[index];
      return TileLayerWidget(
        options: TileLayerOptions(
          tileProvider: FileTileProvider(),
          urlTemplate:
              '/home/gaute/Documents/Projects/SaTreeLight/Sentinelsat/export/tiles/separate/${city.name}, ${city.stateLong}/${mask.string}/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          backgroundColor: Colors.transparent,
          tms: true,
          maxNativeZoom: 14,
          minNativeZoom: 0,
          tileBounds: city.boundsNew,
          tilesContainerBuilder: (context, tilesContainer, tiles) =>
              MaskTilesContainer(tilesContainer: tilesContainer, mask: mask),
        ),
      );
    });
  }
  return [];
});

/// Provider for whether the coverage is absolute or relative.
final relativeProvider = StateProvider<bool>((ref) => false);

/// Provider for notifying that the mask selection has changed.
final updatedMasks = StateProvider<bool>((ref) => false);

/* final imagesInsteadOfMasksProvider = StateProvider<bool>((ref) => false);
 */