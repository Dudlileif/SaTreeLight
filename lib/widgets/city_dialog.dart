import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/constants/size_breakpoints.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/widgets/components/city_map.dart';
import 'package:satreelight/widgets/components/coverage_pie_chart.dart';
import 'package:satreelight/widgets/components/happiness_indicator.dart';
import 'package:satreelight/widgets/components/happiness_ranks.dart';

/// A large dialog that shows details for the selected city. This includes a map
/// with masks, ranks and coverage details.
class CityDialog extends ConsumerStatefulWidget {
  const CityDialog({super.key});

  @override
  ConsumerState<CityDialog> createState() => _CityDialogState();
}

class _CityDialogState extends ConsumerState<CityDialog> {
  bool mapHover = false;
  List<City> cities = [];
  City? city;
  int cityIndex = 0;

  City? prevCity;

  @override
  Widget build(BuildContext context) {
    cities = ref.watch(sortedCitiesProvider);

    city = ref.watch(selectedCityProvider);

    if (prevCity != null) {
      if (!prevCity!.loaded) {
        prevCity = ref.watch(loadCityDataProvider(prevCity)).when(
              data: (data) => data,
              error: (error, stackTrace) => prevCity,
              loading: () => prevCity,
            );
      }
    }

    if (city != null) {
      if (!city!.loaded) {
        city = ref.watch(loadCityDataProvider(city)).when(
              data: (data) => data,
              error: (error, stackTrace) => city,
              loading: () => city,
            );
      }
    }

    cityIndex = city != null ? cities.indexOf(city!) : 0;

    final cardColor = Theme.of(context).dividerColor;
    final screenSize = MediaQuery.of(context).size;

    final dataWidgets = <Widget>[
      Card(
        elevation: 4,
        child: Container(
          color: cardColor,
          height: screenSize.height * 0.2,
          width: screenSize.width < slimWidthBreakpoint
              ? screenSize.width * 0.8
              : screenSize.width * 0.15,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                if (ref.watch(selectedMasksProvider).length <
                        CoverageType.values.length &&
                    ref.watch(selectedMasksProvider).isNotEmpty)
                  DropdownButton<bool>(
                    value: ref.watch(relativeProvider) &&
                        ref.watch(selectedMasksProvider).length <
                            CoverageType.values.length,
                    isDense: true,
                    items: [
                      DropdownMenuItem(
                        value: false,
                        child: Text(
                          'Absolute area coverage',
                          softWrap: true,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text(
                          'Relative area coverage',
                          softWrap: true,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                    onChanged: (value) => value != null
                        ? ref
                            .read(relativeProvider.notifier)
                            .update((state) => value)
                        : {},
                  )
                else
                  Text(
                    'Area coverage',
                    softWrap: true,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                const Expanded(child: CoveragePieChart()),
              ],
            ),
          ),
        ),
      ),
      Card(
        elevation: 4,
        child: Container(
          color: cardColor,
          height: screenSize.height * 0.2,
          width: screenSize.width < slimWidthBreakpoint
              ? screenSize.width * 0.8
              : screenSize.width < mediumWidthBreakpoint
                  ? screenSize.width * 0.25
                  : screenSize.width * 0.15,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: HappinessRanks(
              city: city!,
              numberOfCities: cities.isNotEmpty ? cities.length : 0,
            ),
          ),
        ),
      ),
      Card(
        elevation: 4,
        child: Container(
          color: cardColor,
          height: screenSize.height * 0.2,
          width: screenSize.width < slimWidthBreakpoint
              ? screenSize.width * 0.8
              : screenSize.width < mediumWidthBreakpoint
                  ? screenSize.width * 0.25
                  : screenSize.width * 0.15,
          child: HappinessIndicator(city: city!),
        ),
      ),
    ];

    final widgets = [
      Card(
        elevation: 4,
        child: Container(
          height: screenSize.height * 0.6 + 16,
          width: screenSize.width < slimWidthBreakpoint
              ? screenSize.width * 0.8
              : screenSize.width < mediumWidthBreakpoint
                  ? screenSize.width * 0.7
                  : screenSize.width * 0.52,
          color: cardColor,
          child: MouseRegion(
            onEnter: (event) {
              if (!mapHover && screenSize.width < mediumWidthBreakpoint) {
                setState(() {
                  mapHover = true;
                });
              }
            },
            onExit: (event) {
              if (mapHover && screenSize.width < mediumWidthBreakpoint) {
                setState(() {
                  mapHover = false;
                });
              }
            },
            child: CityMap(city: city!),
          ),
        ),
      ),
      if (screenSize.width < slimWidthBreakpoint)
        ...dataWidgets
      else if (screenSize.width < mediumWidthBreakpoint)
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: screenSize.width * 0.7 + 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              dataWidgets.length,
              (index) => index == 1
                  ? Expanded(child: dataWidgets[index])
                  : dataWidgets[index],
            ),
          ),
        )
      else
        Column(
          children: dataWidgets,
        ),
    ];

    final layout = screenSize.width < mediumWidthBreakpoint
        ? Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ListView(
                physics: mapHover ? const NeverScrollableScrollPhysics() : null,
                children: widgets,
              ),
            ),
          )
        : Row(
            children: List.generate(
              widgets.length,
              (index) =>
                  index == 0 ? Expanded(child: widgets[index]) : widgets[index],
            ),
          );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        vertical: screenSize.width < mediumWidthBreakpoint
            ? screenSize.height * 0.03
            : screenSize.height * 0.1,
        horizontal: screenSize.width * 0.1,
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: RichText(
                    text: TextSpan(
                      text: '${city?.name}\n',
                      style: Theme.of(context).textTheme.headlineMedium,
                      children: [
                        TextSpan(
                          text: city?.stateLong,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (cityIndex > 0 && ref.watch(showArrowsOnPopupProvider))
                      IconButton(
                        tooltip: 'Previous',
                        onPressed: () {
                          cityIndex--;
                          prevCity = city;
                          final newCity = cities[cityIndex];
                          ref.read(selectedCityProvider.notifier).set(newCity);
                        },
                        icon: const Icon(Icons.keyboard_arrow_left),
                      ),
                    if (cityIndex < cities.length - 1 &&
                        ref.watch(showArrowsOnPopupProvider))
                      IconButton(
                        tooltip: 'Next',
                        onPressed: () {
                          cityIndex++;
                          prevCity = city;
                          final newCity = cities[cityIndex];
                          ref.read(selectedCityProvider.notifier).set(newCity);
                        },
                        icon: const Icon(Icons.keyboard_arrow_right),
                      ),
                    const SizedBox(
                      width: 16,
                    ),
                    const CloseButton()
                  ],
                ),
              ],
            ),
            layout,
          ],
        ),
      ),
    );
  }
}
