import 'package:flutter/material.dart';
import 'package:satreelight/src/features/city/city.dart';

class WideLayout extends StatefulWidget {
  const WideLayout({
    required this.cityMap,
    required this.coveragePieChart,
    required this.happinessEmoji,
    required this.happinessRanks,
    super.key,
  });
  final CityMap cityMap;
  final CoveragePieChart coveragePieChart;
  final HappinessEmoji happinessEmoji;
  final HappinessRanks happinessRanks;

  @override
  State<WideLayout> createState() => _WideLayoutState();
}

class _WideLayoutState extends State<WideLayout> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final showScrollBar = screenSize.height < 795;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: widget.cityMap,
          ),
        ),
        const VerticalDivider(),
        SizedBox(
          width: 220,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: showScrollBar,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRect(
                    child: SizedBox(
                      height: 200,
                      child: widget.coveragePieChart,
                    ),
                  ),
                  const Divider(),
                  SizedBox(
                    height: 200,
                    child: widget.happinessRanks,
                  ),
                  const Divider(),
                  SizedBox(
                    height: 200,
                    child: widget.happinessEmoji,
                  ),
                ]
                    .map(
                      (widget) => showScrollBar
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: 4,
                                bottom: 4,
                                left: 8,
                                right: 16,
                              ),
                              child: widget,
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: widget,
                            ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
