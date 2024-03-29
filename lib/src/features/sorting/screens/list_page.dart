import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/sorting/sorting.dart';

/// A page that shows the cities in a sorted list/grid.
class ListPage extends ConsumerWidget {
  const ListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(sortedCitiesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cities'),
        leading: BackButton(
          onPressed: () {
            ref
                .read(showNextPrevArrowsProvider.notifier)
                .update(newState: false);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.all(8),
            child: CitySearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                'Sort by',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: SelectSortingToggleButtons(),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: FlipSortingOrderButton(),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: cities.length,
        itemBuilder: (context, index) => CityButton(city: cities[index]),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          childAspectRatio: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
      ),
    );
  }
}
