import 'package:flutter/material.dart';
import 'package:satreelight/src/features/city/city.dart';

class SlimLayout extends StatefulWidget {
  const SlimLayout({
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
  State<SlimLayout> createState() => _SlimLayoutState();
}

class _SlimLayoutState extends State<SlimLayout> {
  final scrollController = ScrollController();
  bool canScroll = true;

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              height: 440,
              child: MouseRegion(
                onEnter: (event) => setState(() => canScroll = false),
                onExit: (event) => setState(() => canScroll = true),
                child: widget.cityMap,
              ),
            ),
          ),
          const Divider(),
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
