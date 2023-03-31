import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/constants/size_breakpoints.dart';
import 'package:satreelight/models/sorting.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/widgets/stat_popup.dart';

/// A page that shows the cities in a sorted list/grid.
class ListPage extends ConsumerStatefulWidget {
  const ListPage({
    super.key,
  });

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  String initSearchString = '';
  late TextEditingController textController;

  void sortByVeg() {
    ref.read(sortingProvider.notifier).set(Sorting.vegetation);
  }

  void sortAlphabetically() {
    ref.read(sortingProvider.notifier).set(Sorting.alphabetically);
  }

  void sortByHappiness() {
    ref.read(sortingProvider.notifier).set(Sorting.happiness);
  }

  void sort(int index) {
    index == 0
        ? sortByVeg()
        : index == 1
            ? sortByHappiness()
            : sortAlphabetically();
  }

  void reverse() {
    ref.read(reverseSortingProvider.notifier).reverse();
  }

  @override
  void initState() {
    super.initState();
    initSearchString = ref.read(searchStringProvider);
    textController = TextEditingController(text: initSearchString);
  }

  @override
  Widget build(BuildContext context) {
    final cities = ref.watch(sortedCitiesProvider);
    final sortedBy = ref.watch(sortingProvider);
    final searchString = ref.watch(searchStringProvider);

    final textSearch = TextField(
      onChanged: (value) => setState(
        () {
          ref.read(searchStringProvider.notifier).set(value);
        },
      ),
      controller: textController,
      maxLines: 1,
      maxLength: 27,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search,
            ),
            Text('Search', style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
        counterText: '',
        constraints: const BoxConstraints(maxWidth: 300),
        suffixIcon: searchString != ''
            ? IconButton(
                onPressed: () {
                  textController.clear();
                  ref.read(searchStringProvider.notifier).clear();
                },
                icon: const Icon(Icons.close),
                splashRadius: 20,
              )
            : null,
      ),
      textAlignVertical: TextAlignVertical.top,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cities',
        ),
        leading: BackButton(onPressed: () {
          ref.read(showArrowsOnPopupProvider.notifier).set(false);
          Navigator.of(context).pop();
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: MediaQuery.of(context).size.width < slimWidthBreakpoint + 30
                ? Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return SimpleDialog(
                                  children: [
                                    textSearch,
                                  ],
                                );
                              });
                        },
                        icon: const Icon(Icons.search),
                      ),
                      if (searchString != '')
                        IconButton(
                            onPressed: () {
                              textController.clear();
                              ref.read(searchStringProvider.notifier).clear();
                            },
                            icon: const Icon(Icons.search_off))
                    ],
                  )
                : textSearch,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              onPressed: (index) => sort(index),
              isSelected: List.generate(
                Sorting.values.length,
                (index) => ref.watch(sortingProvider) == Sorting.values[index],
              ),
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
            ),
          ),
          IconButton(
            tooltip: 'Reverse list',
            onPressed: reverse,
            icon: const Icon(Icons.import_export),
            padding: const EdgeInsets.all(8),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          final sortByText = sortedBy == Sorting.vegetation
              ? '\nVegetation: ${(100 * city.vegFrac).toStringAsPrecision(3)}%'
              : sortedBy == Sorting.happiness
                  ? '\nHappiness score: ${city.happinessScore}'
                  : '';
          final buttonText = city.nameAndState + sortByText;
          return ElevatedButton(
            key: UniqueKey(),
            onPressed: () {
              ref.read(selectedCityProvider.notifier).set(city);
              showDialog(
                context: context,
                builder: (context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: const StatPopup(),
                  );
                },
              );
            },
            child: Text(buttonText),
          );
        },
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
