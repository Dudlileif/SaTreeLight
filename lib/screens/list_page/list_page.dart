import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:satreelight/constants/size_breakpoints.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/widgets/stat_popup.dart';

class ListPage extends StatefulWidget {
  final List<City> cities;
  const ListPage({Key? key, required this.cities}) : super(key: key);

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<City> _cities = [];
  List<String> sortings = ['Vegetation', 'Happiness', 'Alphabetically'];
  String sortedBy = 'Alphabetically';
  String searchString = '';
  final searchController = TextEditingController();

  void sortByVeg() {
    setState(() {
      sortedBy = 'Vegetation';
      _cities.sort(
        (a, b) => b.vegFrac.compareTo(a.vegFrac),
      );
    });
  }

  void sortAlphabetically() {
    setState(() {
      sortedBy = 'Alphabetically';
      _cities.sort(
        (a, b) => a.name.compareTo(b.name),
      );
    });
  }

  void sortByHappiness() {
    setState(() {
      sortedBy = 'Happiness';
      _cities.sort(
        (a, b) => b.happyScore.compareTo(a.happyScore),
      );
    });
  }

  void sort(int index) {
    index == 0
        ? sortByVeg()
        : index == 1
            ? sortByHappiness()
            : sortAlphabetically();
  }

  void reverse() {
    setState(() {
      _cities = _cities.reversed.toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _cities.addAll(widget.cities);
    sortAlphabetically();
  }

  @override
  Widget build(BuildContext context) {
    final citiesToList = searchString == ''
        ? _cities
        : _cities
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

    final textSearch = TextField(
      onChanged: (value) => setState(
        () {
          searchString = value;
        },
      ),
      controller: searchController,
      maxLines: 1,
      maxLength: 27,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),
      cursorColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : null,
      decoration: InputDecoration(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search,
            ),
            Text(
              'Search',
              style: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).primaryTextTheme.bodyLarge
                  : null,
            ),
          ],
        ),
        fillColor: Theme.of(context).brightness == Brightness.light
            ? Theme.of(context).primaryColor
            : null,
        counterText: '',
        constraints: const BoxConstraints(maxWidth: 300),
        suffixIcon: searchString != ''
            ? IconButton(
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    searchString = '';
                  });
                },
                icon: const Icon(
                  Icons.close,
                ),
                splashRadius: 20,
                color: Theme.of(context).brightness == Brightness.light
                    ? Theme.of(context).primaryIconTheme.color
                    : null,
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
                                  backgroundColor:
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Theme.of(context).primaryColor
                                          : null,
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
                              searchController.clear();
                              setState(() {
                                searchString = '';
                              });
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
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              fillColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : null,
              selectedColor: Theme.of(context).brightness == Brightness.light
                  ? Theme.of(context).primaryColor
                  : null,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : null,
              borderColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : null,
              selectedBorderColor:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.white
                      : null,
              onPressed: (index) => sort(index),
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
              isSelected: List.generate(
                sortings.length,
                (index) => sortedBy == sortings[index],
              ),
            ),
          ),
          IconButton(
            tooltip: 'Reverse list',
            onPressed: reverse,
            icon: const Icon(Icons.import_export),
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.white
                : Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(8),
          )
        ],
      ),
      body: GridView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: citiesToList.length,
        itemBuilder: (context, index) {
          final city = citiesToList[index];
          final sortByText = sortedBy == 'Vegetation'
              ? '\nVegetation: ' +
                  (100 * city.vegFrac).toStringAsPrecision(3) +
                  '%'
              : sortedBy == 'Happiness'
                  ? '\nHappiness score: ' + city.happyScore.toString()
                  : '';
          final buttonText = city.nameAndState + sortByText;
          return ElevatedButton(
            key: UniqueKey(),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                    child: StatPopup(
                      city: city,
                      cities: _cities,
                    ),
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
