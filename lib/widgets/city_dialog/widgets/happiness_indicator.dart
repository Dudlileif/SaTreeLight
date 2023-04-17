import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/constants/animation_config.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/widgets/emoji_painter.dart';

/// An indicator for the happiness score of the city.
class HappinessIndicator extends ConsumerStatefulWidget {
  const HappinessIndicator({
    required this.city,
    super.key,
  });

  /// The city to show the happiness score for.
  final City city;

  @override
  ConsumerState<HappinessIndicator> createState() => _HappinessIndicatorState();
}

class _HappinessIndicatorState extends ConsumerState<HappinessIndicator>
    with SingleTickerProviderStateMixin {
  City? prevCity;
  late City city;

  late final AnimationController animationController;

  late double? happinessScore;

  late Animation<double> happinessAnimation;

  void animationListener() => setState(
        () => happinessScore = happinessAnimation.value,
      );

  void animateTransition() {
    animationController
      ..reset()
      ..removeListener(animationListener);

    if (prevCity != null) {
      happinessAnimation = Tween<double>(
        begin: prevCity!.happinessScore,
        end: city.happinessScore,
      ).animate(animationController);

      animationController
        ..addListener(animationListener)
        ..animateTo(
          1,
          duration: AnimationConfig.duration,
          curve: AnimationConfig.curve,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    city = widget.city;
    happinessScore = city.happinessScore;
    animationController = AnimationController(
      vsync: this,
      duration: AnimationConfig.duration,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      selectedCityProvider,
      (previous, next) => setState(() {
        prevCity = previous ?? prevCity;
        city = next ?? city;
        happinessScore = prevCity?.happinessScore ?? city.happinessScore;
        animateTransition();
      }),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Total Happiness Score: ${happinessScore?.toStringAsFixed(2) ?? ''}',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8),
              child: LayoutBuilder(
                builder: (context, constraints) => SizedBox.square(
                  dimension: constraints.biggest.shortestSide / 2.5,
                  child: CustomPaint(
                    painter: EmojiPainter(
                      // Normalized over min and max scores
                      value: ((happinessScore ?? 50) - 32) / (78 - 32),
                    ),
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
