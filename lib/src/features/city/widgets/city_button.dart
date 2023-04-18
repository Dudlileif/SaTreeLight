import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/sorting/sorting.dart';

/// An [ElevatedButton] for opening the [CityDialog] for
/// a [City].
///
/// Can show values for vegetation coverage or happiness score
/// if the list is sorted by them.
class CityButton extends ConsumerWidget {
  const CityButton({
    required this.city,
    super.key,
  });

  final City city;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortedBy = ref.watch(activeSortingProvider);

    final sortByText = sortedBy == Sorting.vegetation
        ? '\nVegetation: ${(100 * city.vegFrac).toStringAsPrecision(3)}%'
        : sortedBy == Sorting.happiness
            ? '\nHappiness score: ${city.happinessScore}'
            : '';
    final buttonText = city.nameAndState + sortByText;

    return ElevatedButton(
      key: ValueKey(city),
      onPressed: () {
        ref.read(selectedCityProvider.notifier).update(city);
        showDialog<void>(
          context: context,
          builder: (context) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: const CityDialog(),
            );
          },
        );
      },
      child: Text(
        buttonText,
        softWrap: true,
        maxLines: 3,
      ),
    );
  }
}
