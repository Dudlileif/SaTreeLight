import 'package:flutter/material.dart';
import 'package:satreelight/models/city.dart';

/// A widget with all the separate ranks for the city, out of the number of cities.
class HappinessRanks extends StatelessWidget {
  /// The city to show ranks for.
  final City city;

  /// The total number of cities.
  final int? numberOfCities;
  const HappinessRanks({Key? key, required this.city, this.numberOfCities})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Row(
          children: [
            Flexible(
              child: Text(
                'Happiness Rank: ',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              '#${city.happinessRank}',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (numberOfCities != null)
              Text(
                ' of $numberOfCities',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    ?.copyWith(fontWeight: FontWeight.bold),
              )
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ImageIcon(
                Image.asset(
                  'assets/graphics/Emotional and Physical Well-Being.png',
                  cacheHeight: 100,
                  cacheWidth: 100,
                ).image,
                size: 35,
              ),
            ),
            Flexible(
              child: Text(
                'Emotional and Physical \nWell-being Rank ',
                style: Theme.of(context).textTheme.overline,
              ),
            ),
            Text(
              '#${city.emoPhysRank}',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ImageIcon(
                Image.asset(
                  'assets/graphics/Income and Employer.png',
                  cacheHeight: 100,
                  cacheWidth: 100,
                ).image,
                size: 35,
              ),
            ),
            Flexible(
              child: Text(
                'Income and Employment Rank ',
                style: Theme.of(context).textTheme.overline,
              ),
            ),
            Text(
              '#${city.incomeEmpRank}',
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: ImageIcon(
                Image.asset(
                  'assets/graphics/Community and Environment.png',
                  cacheHeight: 100,
                  cacheWidth: 100,
                ).image,
                size: 35,
              ),
            ),
            Flexible(
              child: Text(
                'Community and Enviorment Rank ',
                style: Theme.of(context).textTheme.overline,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '#${city.communityEnvRank}',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
