import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:satreelight/models/city.dart';
import 'package:satreelight/models/coverage_colors.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:satreelight/providers/providers.dart';

final compactDouble = NumberFormat.compact();

/// A circular chart/gauge for showing the amount of coverage for the masks.
class VegetationGauge extends ConsumerWidget {
  final City city;
  final List<CoverageType> keys;
  const VegetationGauge(
      {Key? key, required this.city, this.keys = CoverageType.values})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int hasValue = 0;
    CoverageType? coverageWithValue;
    if (hasValue < 2) {
      for (final key in keys) {
        if ((city.coveragePercent[key] ?? 0) > 0) {
          hasValue++;
          coverageWithValue = key;
        }
      }
    }
    return hasValue >= 1
        ? LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return hasValue == 1
                  ? Text(
                      '${coverageWithValue?.capitalizedString() ?? ''}: ${compactDouble.format(city.coveragePercent[coverageWithValue])}%')
                  : Chart(
                      data: List.generate(
                          keys.length,
                          (index) => {
                                'type': keys[index].capitalizedString(),
                                'coverage': city.coveragePercent[keys[index]]
                              }),
                      variables: {
                        'type': Variable(
                            accessor: (Map datum) => datum['type'] as String),
                        'coverage': Variable(
                          accessor: (Map datum) => datum['coverage'] as num,
                          scale: LinearScale(min: 0),
                        )
                      },
                      transforms: [
                        Proportion(
                          variable: 'coverage',
                          as: 'percent',
                        )
                      ],
                      elements: [
                        IntervalElement(
                          color: ColorAttr(
                              values: CoverageColors.colorsFromKeys(
                                keys,
                                dark: Theme.of(context).brightness ==
                                    Brightness.dark,
                              ),
                              variable: 'type'),
                          position: Varset('percent') / Varset('type'),
                          modifiers: [StackModifier()],
                          label: LabelAttr(
                            encoder: (tuple) => Label(
                                tuple['percent'] > 0.05
                                    ? '${compactDouble.format(ref.watch(relativeProvider) ? tuple['percent'] * 100 : tuple['coverage'])}% ${tuple['type']}'
                                    : ' ',
                                LabelStyle(
                                  style: Theme.of(context).textTheme.subtitle2,
                                  minWidth: 50,
                                  maxWidth: 85,
                                  maxLines: 3,
                                )),
                          ),
                          size: SizeAttr(
                              value: constraints.smallest.longestSide / 10),
                        ),
                      ],
                      coord: PolarCoord(
                        transposed: true,
                        startRadius: 0.45,
                        endRadius: 0.6,
                        dimCount: 1,
                        dimFill: 1.2,
                      ),
                    );
            },
          )
        : const SizedBox.shrink();
  }
}
