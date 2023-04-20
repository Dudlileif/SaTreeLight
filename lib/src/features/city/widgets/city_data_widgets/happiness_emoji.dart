import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/animation/animation.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/emoji_painter/emoji_painter.dart';

/// An indicator for the happiness score of the city.
class HappinessEmoji extends ConsumerStatefulWidget {
  const HappinessEmoji({super.key});

  @override
  ConsumerState<HappinessEmoji> createState() => _HappinessEmojiState();
}

class _HappinessEmojiState extends ConsumerState<HappinessEmoji>
    with SingleTickerProviderStateMixin {
  double min = 0;
  double max = 100;

  City? prevCity;
  City? city;

  late final AnimationController animationController;

  double? happinessScore;

  Animation<double>? happinessAnimation;

  void animationListener() => setState(
        () => happinessScore = happinessAnimation?.value,
      );

  void animateTransition() {
    animationController
      ..reset()
      ..removeListener(animationListener);

    if (city != null && prevCity != null) {
      happinessAnimation = Tween<double>(
        begin: prevCity!.happinessScore,
        end: city!.happinessScore,
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
    city = ref.read(selectedCityProvider);
    happinessScore = city?.happinessScore;
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
    ref
      ..listen(
        selectedCityProvider,
        (previous, next) => setState(() {
          prevCity = previous ?? prevCity;
          city = next ?? city;
          happinessScore = prevCity?.happinessScore ?? city?.happinessScore;
          animateTransition();
        }),
      )
      ..watch(
        citiesProvider.select(
          (cities) => cities.when(
            data: (data) {
              setState(() {
                min = minBy(data, (city) => city.happinessScore)
                        ?.happinessScore ??
                    0;
                max = maxBy(data, (city) => city.happinessScore)
                        ?.happinessScore ??
                    100;
              });
            },
            error: (error, stackTrace) {},
            loading: () {},
          ),
        ),
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomPaint(
              size: Size.infinite,
              painter: EmojiPainter(
                // Normalized over min and max scores
                value: ((happinessScore ?? 50) - min) / (max - min),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
