import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/animation/animation.dart';
import 'package:satreelight/src/features/city/city.dart';

/// A widget with all the separate ranks for the city,
/// out of the number of cities.
class HappinessRanks extends ConsumerStatefulWidget {
  const HappinessRanks({
    required this.city,
    this.numberOfCities,
    super.key,
  });

  /// The city to show ranks for.
  final City city;

  /// The total number of cities.
  final int? numberOfCities;

  @override
  ConsumerState<HappinessRanks> createState() => _HappinessRanksState();
}

class _HappinessRanksState extends ConsumerState<HappinessRanks>
    with SingleTickerProviderStateMixin {
  City? prevCity;
  late City city;

  late final AnimationController animationController;

  late int? happinessRank;
  late int? emoPhysRank;
  late int? incomeEmpRank;
  late int? communityEnvRank;

  late Animation<int> happinessAnimation;
  late Animation<int> emoPhysAnimation;
  late Animation<int> incomeEmpAnimation;
  late Animation<int> communityEnvAnimation;

  void animationListener() => setState(() {
        happinessRank = happinessAnimation.value;
        emoPhysRank = emoPhysAnimation.value;
        incomeEmpRank = incomeEmpAnimation.value;
        communityEnvRank = communityEnvAnimation.value;
      });

  void animateTransition() {
    animationController
      ..reset()
      ..removeListener(animationListener);
    if (prevCity != null) {
      happinessAnimation = IntTween(
        begin: prevCity!.happinessRank,
        end: city.happinessRank,
      ).animate(animationController);

      emoPhysAnimation = IntTween(
        begin: prevCity!.emoPhysRank,
        end: city.emoPhysRank,
      ).animate(animationController);

      incomeEmpAnimation = IntTween(
        begin: prevCity!.incomeEmpRank,
        end: city.incomeEmpRank,
      ).animate(animationController);

      communityEnvAnimation = IntTween(
        begin: prevCity!.communityEnvRank,
        end: city.communityEnvRank,
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
    happinessRank = city.happinessRank;
    emoPhysRank = city.emoPhysRank;
    incomeEmpRank = city.incomeEmpRank;
    communityEnvRank = city.communityEnvRank;

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
        happinessRank = prevCity?.happinessRank ?? city.happinessRank;
        emoPhysRank = prevCity?.emoPhysRank ?? city.emoPhysRank;
        incomeEmpRank = prevCity?.incomeEmpRank ?? city.incomeEmpRank;
        communityEnvRank = prevCity?.communityEnvRank ?? city.communityEnvRank;

        animateTransition();
      }),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ranking',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (widget.numberOfCities != null)
                  Text(
                    ' (of ${widget.numberOfCities})',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Total rank',
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '$happinessRank',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ImageIcon(
                        Image.asset(
                          'assets/graphics/Emotional and Physical Well-Being.png',
                          cacheHeight: 100,
                          cacheWidth: 100,
                        ).image,
                        size: 35,
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth * 0.6,
                      child: Text(
                        'Emotional and Physical Well-being',
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$emoPhysRank',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ImageIcon(
                        Image.asset(
                          'assets/graphics/Income and Employer.png',
                          cacheHeight: 100,
                          cacheWidth: 100,
                        ).image,
                        size: 35,
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth * 0.6,
                      child: Text(
                        'Income and Employment',
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$incomeEmpRank',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ImageIcon(
                        Image.asset(
                          'assets/graphics/Community and Environment.png',
                          cacheHeight: 100,
                          cacheWidth: 100,
                        ).image,
                        size: 35,
                      ),
                    ),
                    SizedBox(
                      width: constraints.maxWidth * 0.6,
                      child: Text(
                        'Community and Enviorment',
                        softWrap: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$communityEnvRank',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
