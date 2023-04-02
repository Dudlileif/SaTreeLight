import 'package:flutter/material.dart';
import 'package:satreelight/models/city.dart';

/// A widget with all the separate ranks for the city,
/// out of the number of cities.
class HappinessRanks extends StatefulWidget {
  const HappinessRanks({
    required this.city,
    this.prevCity,
    this.numberOfCities,
    super.key,
  });

  /// The city to show ranks for.
  final City city;

  /// The previous city to animate from, if there is one.
  final City? prevCity;

  /// The total number of cities.
  final int? numberOfCities;

  @override
  State<HappinessRanks> createState() => _HappinessRanksState();
}

class _HappinessRanksState extends State<HappinessRanks>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  late int? happinessRank = widget.prevCity != null
      ? widget.prevCity?.happinessRank
      : widget.city.happinessRank;
  late int? emoPhysRank = widget.prevCity != null
      ? widget.prevCity?.emoPhysRank
      : widget.city.emoPhysRank;
  late int? incomeEmpRank = widget.prevCity != null
      ? widget.prevCity?.incomeEmpRank
      : widget.city.incomeEmpRank;
  late int? communityEnvRank = widget.prevCity != null
      ? widget.prevCity?.communityEnvRank
      : widget.city.communityEnvRank;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      value: 0,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.prevCity != null) {
      final happinessTween = IntTween(
        begin: happinessRank,
        end: widget.city.happinessRank,
      ).animate(animationController);

      final emoPhysTween = IntTween(
        begin: emoPhysRank,
        end: widget.city.emoPhysRank,
      ).animate(animationController);

      final incomeEmpTween = IntTween(
        begin: incomeEmpRank,
        end: widget.city.incomeEmpRank,
      ).animate(animationController);

      final communityEnvTween = IntTween(
        begin: communityEnvRank,
        end: widget.city.communityEnvRank,
      ).animate(animationController);

      animationController
        ..addListener(
          () => setState(
            () {
              happinessRank = happinessTween.value;
              emoPhysRank = emoPhysTween.value;
              incomeEmpRank = incomeEmpTween.value;
              communityEnvRank = communityEnvTween.value;
            },
          ),
        )
        ..animateTo(
          1,
          duration: const Duration(milliseconds: 500),
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
              '#$happinessRank',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (widget.numberOfCities != null)
              Text(
                ' of ${widget.numberOfCities}',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              )
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 6),
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
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            Text(
              '#$emoPhysRank',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 6),
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
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            Text(
              '#$incomeEmpRank',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 6),
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
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '#$communityEnvRank',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
