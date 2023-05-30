// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$citiesHash() => r'09899ca92c166d8873dd72c61aaa94e5699cbb86';

/// Provider for the cities.
///
/// Copied from [cities].
@ProviderFor(cities)
final citiesProvider = FutureProvider<List<City>>.internal(
  cities,
  name: r'citiesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$citiesHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

typedef CitiesRef = FutureProviderRef<List<City>>;
String _$loadCityDataHash() => r'6e1170805781fcd7a9558d04f48ea3d9d2d5df75';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

typedef LoadCityDataRef = AutoDisposeFutureProviderRef<City?>;

/// Provider for loading the city data.
///
/// Copied from [loadCityData].
@ProviderFor(loadCityData)
const loadCityDataProvider = LoadCityDataFamily();

/// Provider for loading the city data.
///
/// Copied from [loadCityData].
class LoadCityDataFamily extends Family<AsyncValue<City?>> {
  /// Provider for loading the city data.
  ///
  /// Copied from [loadCityData].
  const LoadCityDataFamily();

  /// Provider for loading the city data.
  ///
  /// Copied from [loadCityData].
  LoadCityDataProvider call(
    City? city,
  ) {
    return LoadCityDataProvider(
      city,
    );
  }

  @override
  LoadCityDataProvider getProviderOverride(
    covariant LoadCityDataProvider provider,
  ) {
    return call(
      provider.city,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'loadCityDataProvider';
}

/// Provider for loading the city data.
///
/// Copied from [loadCityData].
class LoadCityDataProvider extends AutoDisposeFutureProvider<City?> {
  /// Provider for loading the city data.
  ///
  /// Copied from [loadCityData].
  LoadCityDataProvider(
    this.city,
  ) : super.internal(
          (ref) => loadCityData(
            ref,
            city,
          ),
          from: loadCityDataProvider,
          name: r'loadCityDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$loadCityDataHash,
          dependencies: LoadCityDataFamily._dependencies,
          allTransitiveDependencies:
              LoadCityDataFamily._allTransitiveDependencies,
        );

  final City? city;

  @override
  bool operator ==(Object other) {
    return other is LoadCityDataProvider && other.city == city;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, city.hashCode);

    return _SystemHash.finish(hash);
  }
}

String _$selectedCityHash() => r'd48338cf3ef5d9035be6ff13f8fa4fe10c946f53';

/// Provider for the selected city, if there is one.
///
/// Copied from [SelectedCity].
@ProviderFor(SelectedCity)
final selectedCityProvider = NotifierProvider<SelectedCity, City?>.internal(
  SelectedCity.new,
  name: r'selectedCityProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedCityHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCity = Notifier<City?>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
