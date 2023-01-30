import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:satreelight/models/city.dart';

/// An indicator for the happiness score of the city.
class HappinessIndicator extends StatelessWidget {
  /// The city to show the happiness score for.
  final City city;
  const HappinessIndicator({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Total Happiness Score',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                city.happinessScore.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            DecoratedIcon(
              city.happinessScore > 64
                  ? Icons.sentiment_very_satisfied_rounded
                  : city.happinessScore > 57
                      ? Icons.sentiment_satisfied_alt_rounded
                      : city.happinessScore > 47
                          ? Icons.sentiment_neutral_rounded
                          : city.happinessScore > 40
                              ? Icons.sentiment_dissatisfied
                              : Icons.sentiment_very_dissatisfied_rounded,
              size: 50,
              color: city.happinessScore > 64
                  ? Colors.green
                  : city.happinessScore > 57
                      ? Colors.lightGreen
                      : city.happinessScore > 47
                          ? Colors.yellow
                          : city.happinessScore > 40
                              ? Colors.orange
                              : Colors.red,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  offset: Offset(0, 1),
                  blurRadius: 1,
                )
              ],
            ),
          ],
        ),
      ],
    );
  }
}
