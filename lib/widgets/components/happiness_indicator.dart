import 'package:flutter/material.dart';
import 'package:satreelight/constants/animation_config.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/screens/emoji_page/animated_emoji.dart';

/// An indicator for the happiness score of the city.
class HappinessIndicator extends StatefulWidget {
  const HappinessIndicator({
    required this.city,
    this.initValue,
    super.key,
  });

  /// The city to show the happiness score for.
  final City city;
  final double? initValue;

  @override
  State<HappinessIndicator> createState() => _HappinessIndicatorState();
}

class _HappinessIndicatorState extends State<HappinessIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  late double? happinessScore = widget.initValue ?? widget.city.happinessScore;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      lowerBound: 32,
      upperBound: 78,
      value: widget.initValue ?? happinessScore,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.initValue != null) {
      animationController
        ..addListener(
          () => setState(
            () => happinessScore = animationController.value,
          ),
        )
        ..animateTo(
          widget.city.happinessScore,
          duration: AnimationConfig.duration,
          curve: AnimationConfig.curve,
        );
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Total Happiness Score',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                happinessScore?.toStringAsFixed(2) ?? '',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox.square(
                dimension: 50,
                child: CustomPaint(
                  painter: EmojiPainter(
                    // Normalized over min and max scores
                    value: ((happinessScore ?? 50) - 32) / (78 - 32),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
