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
class VegetationGauge extends ConsumerStatefulWidget {
  final City city;
  final City? prevCity;
  final List<CoverageType> keys;
  final List<CoverageType>? prevKeys;
  const VegetationGauge({
    super.key,
    required this.city,
    this.prevCity,
    this.keys = CoverageType.values,
    this.prevKeys,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _VegetationGaugeState();
}

class _VegetationGaugeState extends ConsumerState<VegetationGauge>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  late Map<CoverageType, double> coveragePercent = {}..addAll(
      widget.prevCity != null
          ? widget.prevCity!.coveragePercent
          : widget.city.coveragePercent,
    );

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 500),
    );

    if (widget.prevCity != null) {
      Map<CoverageType, Animation<double>> coverageAnimMap = {};
      for (final coverageType in CoverageType.values) {
        coverageAnimMap[coverageType] = Tween<double>(
          begin: widget.prevCity!.coveragePercent[coverageType],
          end: widget.city.coveragePercent[coverageType],
        ).animate(animationController);
      }
      animationController.addListener(
        () => setState(
          () {
            for (final coverageType in CoverageType.values) {
              coveragePercent[coverageType] =
                  coverageAnimMap[coverageType]!.value;
            }
          },
        ),
      );

      animationController.animateTo(1,
          duration: const Duration(milliseconds: 500));
    }

    if (widget.prevKeys != null) {
      if (widget.prevKeys!.join() != widget.keys.join()) {
        Map<CoverageType, Animation<double>> coverageAnimMap = {};
        for (final coverageType in widget.keys) {
          if (widget.prevKeys!.contains(coverageType)) {
            coverageAnimMap[coverageType] = Tween<double>(
              begin: 0,
              end: widget.city.coveragePercent[coverageType],
            ).animate(animationController);
          }
        }
        for (final coverageType in widget.prevKeys!) {
          if (!widget.keys.contains(coverageType)) {
            coverageAnimMap[coverageType] = Tween<double>(
              begin: widget.city.coveragePercent[coverageType],
              end: 0,
            ).animate(animationController);
          }
        }
        animationController.animateTo(1,
            duration: const Duration(milliseconds: 500));
      }
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int hasValue = 0;
    CoverageType? coverageWithValue;
    if (hasValue < 2) {
      for (final key in widget.keys) {
        if ((coveragePercent[key] ?? 0) > 0) {
          hasValue++;
          coverageWithValue = key;
        }
      }
    }

    final useRelative = ref.watch(relativeProvider);

    return hasValue >= 1
        ? LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return hasValue == 1
                  ? Text(
                      '${coverageWithValue?.capitalizedString() ?? ''}: ${compactDouble.format(coveragePercent[coverageWithValue])}%')
                  : Chart(
                      data: List.generate(
                          widget.keys.length,
                          (index) => {
                                'type': widget.keys[index].capitalizedString(),
                                'coverage': coveragePercent[widget.keys[index]]
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
                                widget.keys,
                                dark: Theme.of(context).brightness ==
                                    Brightness.dark,
                              ),
                              variable: 'type'),
                          position: Varset('percent') / Varset('type'),
                          modifiers: [StackModifier()],
                          label: LabelAttr(
                            encoder: (tuple) => Label(
                                tuple['percent'] > 0.05
                                    ? '${compactDouble.format(useRelative ? tuple['percent'] * 100 : tuple['coverage'])}% ${tuple['type']}'
                                    : ' ',
                                LabelStyle(
                                  style: Theme.of(context).textTheme.labelSmall,
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
