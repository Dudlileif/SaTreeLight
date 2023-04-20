import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/constants/screen_size_breakpoints.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/city/widgets/city_dialog/layouts/medium_layout.dart';
import 'package:satreelight/src/features/city/widgets/city_dialog/layouts/slim_layout.dart';
import 'package:satreelight/src/features/city/widgets/city_dialog/layouts/wide_layout.dart';
import 'package:satreelight/src/features/common_widgets/loading_indicator.dart';
import 'package:satreelight/src/features/sorting/sorting.dart';

export 'providers/city_dialog_providers.dart';

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
    final screenSize = MediaQuery.of(context).size;

    cities = ref.watch(sortedCitiesProvider);

    city = ref.watch(selectedCityProvider);

    if (city == null) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(
          vertical: screenSize.width < mediumWidthBreakpoint
              ? screenSize.height * 0.03
              : screenSize.height * 0.1,
          horizontal: screenSize.width * 0.1,
        ),
        clipBehavior: Clip.hardEdge,
        child: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: LoadingIndicator(),
        ),
      );
    }

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

    const cityMap = CityMap();
    const coveragePieChart = CoveragePieChart();
    const happinessRanks = HappinessRanks();
    const happinessEmoji = HappinessEmoji();

    final layout = screenSize.width < slimWidthBreakpoint
        ? const SlimLayout(
            cityMap: cityMap,
            coveragePieChart: coveragePieChart,
            happinessEmoji: happinessEmoji,
            happinessRanks: happinessRanks,
          )
        : screenSize.width < mediumWidthBreakpoint
            ? const MediumLayout(
                cityMap: cityMap,
                coveragePieChart: coveragePieChart,
                happinessEmoji: happinessEmoji,
                happinessRanks: happinessRanks,
              )
            : const WideLayout(
                cityMap: cityMap,
                coveragePieChart: coveragePieChart,
                happinessEmoji: happinessEmoji,
                happinessRanks: happinessRanks,
              );

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        vertical: screenSize.width < mediumWidthBreakpoint
            ? screenSize.height * 0.03
            : screenSize.height * 0.05,
        horizontal: screenSize.width < mediumWidthBreakpoint
            ? screenSize.width * 0.03
            : screenSize.width * 0.05,
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: 20,
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
                    if (cityIndex > 0 && ref.watch(showNextPrevArrowsProvider))
                      IconButton(
                        tooltip: 'Previous',
                        onPressed: () {
                          cityIndex--;
                          prevCity = city;
                          final newCity = cities[cityIndex];
                          ref
                              .read(selectedCityProvider.notifier)
                              .update(newCity);
                        },
                        icon: const Icon(Icons.keyboard_arrow_left),
                      ),
                    if (cityIndex < cities.length - 1 &&
                        ref.watch(showNextPrevArrowsProvider))
                      IconButton(
                        tooltip: 'Next',
                        onPressed: () {
                          cityIndex++;
                          prevCity = city;
                          final newCity = cities[cityIndex];
                          ref
                              .read(selectedCityProvider.notifier)
                              .update(newCity);
                        },
                        icon: const Icon(Icons.keyboard_arrow_right),
                      ),
                    const SizedBox(width: 16),
                    const CloseButton(),
                  ],
                ),
              ],
            ),
            Expanded(child: layout),
          ],
        ),
      ),
    );
  }
}
