import 'package:flutter/material.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/screens/leaflet_map/components/city_pin.dart';

class HowToPage extends StatelessWidget {
  final City city;
  final int? numberOfCities;
  const HowToPage({required this.city, this.numberOfCities, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How it works'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Click on the location pin',
                style: Theme.of(context).textTheme.headline3),
            const SizedBox(height: 100),
            CityPin(
              city: city,
              numberOfCities: numberOfCities,
              size: 60,
              textStyle: Theme.of(context).primaryTextTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }
}
