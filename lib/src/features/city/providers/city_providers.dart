import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:satreelight/src/features/city/models/city.dart';

part 'city_providers.g.dart';

/// Provider for the cities.
@Riverpod(keepAlive: true, dependencies: [])
FutureOr<List<City>> cities(CitiesRef ref) async =>
    await CitiesUtilities.loadCities();

/// Provider for the selected city, if there is one.
@Riverpod(keepAlive: true)
class SelectedCity extends _$SelectedCity {
  @override
  City? build() => null;

  void update(City newCity) => state = newCity;
  void clear() => state = null;
}

/// Provider for loading the city data.
@riverpod
FutureOr<City?> loadCityData(LoadCityDataRef ref, City? city) async =>
    await city?.loadWithData();
