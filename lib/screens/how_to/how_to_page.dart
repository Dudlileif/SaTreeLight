import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/screens/leaflet_map/components/city_pin.dart';

/// A page that shows the user how to use the map.
class HowToPage extends ConsumerWidget {
  const HowToPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(citiesProvider).when(
          data: (data) => data,
          error: (error, stackTrace) => null,
          loading: () => null,
        );
    final city = cities?.firstWhere(
      (element) => element.name == 'Los Angeles',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('How it works'),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Click on the location pin',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 100),
            if (city != null)
              CityPin(
                city: city,
                numberOfCities: cities?.length,
                size: 60,
                textStyle: Theme.of(context).primaryTextTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}
