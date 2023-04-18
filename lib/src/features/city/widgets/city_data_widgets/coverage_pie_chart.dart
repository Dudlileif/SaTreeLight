import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:satreelight/src/features/animation/animation.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/mask_selection/mask_selection.dart';

final compactDouble = NumberFormat.compact();

/// A circular chart/gauge for showing the amount of coverage for the masks.
class CoveragePieChart extends ConsumerStatefulWidget {
  const CoveragePieChart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CoveragePieChartState();
}

class _CoveragePieChartState extends ConsumerState<CoveragePieChart>
    with SingleTickerProviderStateMixin {
  String? touchedString;
  bool useShortAnimDuration = false;

  @override
  Widget build(BuildContext context) {
    final city = ref.watch(selectedCityProvider);
    final selectedMasks = ref.watch(selectedMasksProvider);

    final coveragePercent = <CoverageType, double>{};

    for (final coverageType in CoverageType.values) {
      if (selectedMasks.contains(coverageType)) {
        coveragePercent[coverageType] =
            city?.coveragePercent[coverageType] ?? 0;
      } else {
        coveragePercent[coverageType] = 0;
      }
    }
    final showRelative = selectedMasks.isNotEmpty &&
        selectedMasks.length != CoverageType.values.length;
    final useRelative = showRelative && ref.watch(showRelativeProvider);

    final relativeTotal =
        coveragePercent.values.reduce((value, element) => value + element);

    return selectedMasks.isEmpty
        ? const SizedBox.shrink()
        : LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final baseSize = constraints.minWidth > constraints.minHeight
                  ? constraints.minWidth
                  : constraints.minHeight;
              return PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedString = null;
                          Future.delayed(
                            PieChart.defaultDuration,
                            () => setState(
                              () => useShortAnimDuration = false,
                            ),
                          );
                          return;
                        }
                        touchedString = pieTouchResponse
                            .touchedSection!.touchedSection?.title;
                        useShortAnimDuration = true;
                      });
                    },
                  ),
                  sections: selectedMasks.isNotEmpty
                      ? selectedMasks.map(
                          (coverageType) {
                            final relativeValue = 100 *
                                coveragePercent[coverageType]! /
                                relativeTotal;
                            final value = useRelative
                                ? relativeValue
                                : coveragePercent[coverageType]!;

                            final highlighted = touchedString ==
                                coverageType.capitalizedString();

                            return PieChartSectionData(
                              title: coverageType.capitalizedString(),
                              badgePositionPercentageOffset: -1,
                              badgeWidget: highlighted
                                  ? Card(
                                      color: CoverageColors.colorMapWithOpacity(
                                        opacity: 0.6,
                                        dark: Theme.of(context).brightness ==
                                            Brightness.dark,
                                      )[coverageType],
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Text(
                                          '${coverageType.capitalizedString()}\n${compactDouble.format(value)} %',
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                            shadows: [
                                              const Shadow(blurRadius: 2)
                                            ],
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  : null,
                              titleStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                shadows: [const Shadow(blurRadius: 2)],
                                color: Colors.white,
                              ),
                              showTitle: !highlighted && relativeValue > 5,
                              value: value,
                              color: CoverageColors.colorMapWithOpacity(
                                dark: Theme.of(context).brightness ==
                                    Brightness.dark,
                              )[coverageType],
                              radius: highlighted ? baseSize / 4 : baseSize / 5,
                            );
                          },
                        ).toList()
                      : null,
                  centerSpaceRadius: baseSize / 4,
                ),
                swapAnimationCurve: AnimationConfig.curve,
                swapAnimationDuration: useShortAnimDuration
                    ? PieChart.defaultDuration
                    : AnimationConfig.duration,
              );
            },
          );
  }
}
