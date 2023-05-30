// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sorting_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$sortedCitiesHash() => r'486433f8346c546454217909fa22e94a6de27fda';

/// Provider for the sorted city list.
///
/// Copied from [sortedCities].
@ProviderFor(sortedCities)
final sortedCitiesProvider = AutoDisposeProvider<List<City>>.internal(
  sortedCities,
  name: r'sortedCitiesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sortedCitiesHash,
  dependencies: <ProviderOrFamily>{
    citiesProvider,
    activeSortingProvider,
    searchStringProvider,
    reverseSortingProvider
  },
  allTransitiveDependencies: <ProviderOrFamily>{
    citiesProvider,
    ...?citiesProvider.allTransitiveDependencies,
    activeSortingProvider,
    ...?activeSortingProvider.allTransitiveDependencies,
    searchStringProvider,
    ...?searchStringProvider.allTransitiveDependencies,
    reverseSortingProvider,
    ...?reverseSortingProvider.allTransitiveDependencies
  },
);

typedef SortedCitiesRef = AutoDisposeProviderRef<List<City>>;
String _$activeSortingHash() => r'c2b2b4b2543ecd79a20acc8f8a86f5d5300ed1bc';

/// Provider for the city sorting state.
///
/// Copied from [ActiveSorting].
@ProviderFor(ActiveSorting)
final activeSortingProvider = NotifierProvider<ActiveSorting, Sorting>.internal(
  ActiveSorting.new,
  name: r'activeSortingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeSortingHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

typedef _$ActiveSorting = Notifier<Sorting>;
String _$reverseSortingHash() => r'003aa5b73de8dfa45fdfc28d783c05ec8e955cb1';

/// A provider for whether the city list should be reversed.
///
/// Copied from [ReverseSorting].
@ProviderFor(ReverseSorting)
final reverseSortingProvider = NotifierProvider<ReverseSorting, bool>.internal(
  ReverseSorting.new,
  name: r'reverseSortingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reverseSortingHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

typedef _$ReverseSorting = Notifier<bool>;
String _$searchStringHash() => r'87ad42dda920b9a46e2c6106aa22fdfa35d913ea';

/// Provider for the search string state.
///
/// Copied from [SearchString].
@ProviderFor(SearchString)
final searchStringProvider = NotifierProvider<SearchString, String>.internal(
  SearchString.new,
  name: r'searchStringProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$searchStringHash,
  dependencies: const <ProviderOrFamily>[],
  allTransitiveDependencies: const <ProviderOrFamily>{},
);

typedef _$SearchString = Notifier<String>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
