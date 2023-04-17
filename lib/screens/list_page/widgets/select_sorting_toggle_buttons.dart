import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/models/sorting.dart';
import 'package:satreelight/providers/providers.dart';

/// [ToggleButtons] for selecting which [Sorting] to
/// sort by.
class SelectSortingToggleButtons extends ConsumerWidget {
  const SelectSortingToggleButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ToggleButtons(
      onPressed: (index) =>
          ref.read(sortingProvider.notifier).set(Sorting.values[index]),
      isSelected: Sorting.values
          .map((sorting) => sorting == ref.watch(sortingProvider))
          .toList(),
      children: const [
        Tooltip(
          message: 'Vegetation',
          child: Icon(Icons.grass),
        ),
        Tooltip(
          message: 'Happiness',
          child: Icon(Icons.sentiment_satisfied),
        ),
        Tooltip(
          message: 'Alphabetically',
          child: Icon(Icons.sort_by_alpha),
        ),
      ],
    );
  }
}
