import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:satreelight/models/city.dart';

class HappinessIndicator extends StatelessWidget {
  final City city;
  const HappinessIndicator({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text("Total Happiness Score",
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
                city.happyScore.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            DecoratedIcon(
              city.happyScore > 64
                  ? Icons.sentiment_very_satisfied_rounded
                  : city.happyScore > 57
                      ? Icons.sentiment_satisfied_alt_rounded
                      : city.happyScore > 47
                          ? Icons.sentiment_neutral_rounded
                          : city.happyScore > 40
                              ? Icons.sentiment_dissatisfied
                              : Icons.sentiment_very_dissatisfied_rounded,
              size: 50,
              color: city.happyScore > 64
                  ? Colors.green
                  : city.happyScore > 57
                      ? Colors.lightGreen
                      : city.happyScore > 47
                          ? Colors.yellow
                          : city.happyScore > 40
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
