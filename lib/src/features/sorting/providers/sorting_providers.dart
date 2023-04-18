import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/sorting/sorting.dart';

part 'sorting_providers.g.dart';

/// Provider for the city sorting state.
@Riverpod(keepAlive: true)
class ActiveSorting extends _$ActiveSorting {
  @override
  Sorting build() => Sorting.alphabetically;

  void update(Sorting newSorting) => state = newSorting;
}

/// A provider for whether the city list should be reversed.
@Riverpod(keepAlive: true)
class ReverseSorting extends _$ReverseSorting {
  @override
  bool build() => false;

  void reverse() => state = !state;
  void setTrue() => state = true;
  void setFalse() => state = false;
}

/// Provider for the search string state.
@Riverpod(keepAlive: true)
class SearchString extends _$SearchString {
  @override
  String build() => '';

  void update(String string) => state = string;
  void clear() => state = '';
}

/// Provider for the sorted city list.
@Riverpod(
  dependencies: [
    cities,
    ActiveSorting,
    SearchString,
    ReverseSorting,
  ],
)
List<City> sortedCities(SortedCitiesRef ref) {
  var cities = ref.watch(citiesProvider).when(
        data: (data) => data,
        error: (error, stackTrace) => <City>[],
        loading: () => <City>[],
      );
  switch (ref.watch(activeSortingProvider)) {
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
}
