// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mask_selection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedMasksHash() => r'71b8a6a29c0f014f710f4c19931a88fea9253080';

/// See also [SelectedMasks].
@ProviderFor(SelectedMasks)
final selectedMasksProvider =
    NotifierProvider<SelectedMasks, List<CoverageType>>.internal(
  SelectedMasks.new,
  name: r'selectedMasksProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedMasksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedMasks = Notifier<List<CoverageType>>;
String _$showRelativeHash() => r'55f81031fc7afa96dc6514abd428c46113b1ed4b';

/// Provider for whether the coverage values are absolute or relative.
///
/// Copied from [ShowRelative].
@ProviderFor(ShowRelative)
final showRelativeProvider =
    AutoDisposeNotifierProvider<ShowRelative, bool>.internal(
  ShowRelative.new,
  name: r'showRelativeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$showRelativeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowRelative = AutoDisposeNotifier<bool>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
