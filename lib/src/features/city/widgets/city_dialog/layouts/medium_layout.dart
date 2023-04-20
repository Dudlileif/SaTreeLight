import 'package:flutter/material.dart';
import 'package:satreelight/src/features/city/city.dart';

class MediumLayout extends StatefulWidget {
  const MediumLayout({
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
  State<MediumLayout> createState() => _MediumLayoutState();
}

class _MediumLayoutState extends State<MediumLayout> {
  final scrollController = ScrollController();
  bool canScroll = true;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: ListView(
        controller: scrollController,
        physics: canScroll ? null : const NeverScrollableScrollPhysics(),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: screenSize.height * 0.6 - 16,
              child: MouseRegion(
                onEnter: (event) => setState(() => canScroll = false),
                onExit: (event) => setState(() => canScroll = true),
                child: widget.cityMap,
              ),
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                flex: 5,
                child: ClipRect(
                  child: SizedBox(
                    height: 200,
                    child: widget.coveragePieChart,
                  ),
                ),
              ),
              const VerticalDivider(),
              Expanded(
                flex: 6,
                child: SizedBox(
                  height: 200,
                  child: widget.happinessRanks,
                ),
              ),
              const VerticalDivider(),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 200,
                  child: widget.happinessEmoji,
                ),
              ),
            ],
          ),
        ]
            .map(
              (widget) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: widget,
              ),
            )
            .toList(),
      ),
    );
  }
}
