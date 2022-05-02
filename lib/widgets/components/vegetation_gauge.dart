import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:satreelight/models/city.dart';

class VegetationGauge extends StatelessWidget {
  final City city;
  const VegetationGauge({Key? key, required this.city}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return CircularPercentIndicator(
          curve: Curves.easeInOutSine,
          animation: true,
          animationDuration: 1000,
          radius: constraints.smallest.shortestSide / 2,
          lineWidth: constraints.smallest.shortestSide / 10,
          circularStrokeCap: CircularStrokeCap.round,
          percent: city.vegFrac,
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text((city.vegFrac * 100).toStringAsFixed(1) + "%"),
              Text(
                "Vegetation",
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
          progressColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).dialogBackgroundColor,
        );
      },
    );
  }
}
