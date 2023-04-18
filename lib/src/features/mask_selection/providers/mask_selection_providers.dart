import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:satreelight/src/features/mask_selection/mask_selection.dart';

part 'mask_selection_providers.g.dart';

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

/// Provider for whether the coverage values are absolute or relative.
@riverpod
class ShowRelative extends _$ShowRelative {
  @override
  bool build() => false;

  void update({required bool newState}) => state = newState;
}
