import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/constants/us_states_map.dart';
import 'package:satreelight/models/coverage_type.dart';

/// A class containing all necessary data for each city.
class City {
  /// City name with abbreviated state name,
  final String nameAndState;

  /// Amount of vegetation within [bounds].
  final double vegFrac;

  /// Happiness score of the city.
  final double happinessScore;

  /// Rank in the emotional and physical category.
  final int emoPhysRank;

  /// Rank in the income and employment category.
  final int incomeEmpRank;

  /// Rank in the community and evnironment category.
  final int communityEnvRank;

  /// Geographic center of the city.
  final LatLng center;

  /// The bounds of the city.
  final LatLngBounds bounds;

  /// Rank in the happiness category, set late.
  int? happinessRank;

  /// Whether all data files have been loaded.
  bool loaded = false;

  /// Combination of all [polygonsPoints], used to find [bounds].
  List<LatLng> combinedPolygonPoints = [];

  /// Polygons the city is made of.
  List<List<LatLng>> polygonsPoints = [];

  /// Polygon holes in the city.
  Map<int, List<List<LatLng>>> polygonHolesPoints = {};

  /// Mapped coverage percentage for each mask layer.
  Map<CoverageType, double> coveragePercent = {};

  City({
    required this.nameAndState,
    required this.vegFrac,
    required this.happinessScore,
    required this.emoPhysRank,
    required this.incomeEmpRank,
    required this.communityEnvRank,
    required this.center,
    required this.bounds,
    Map<String, dynamic> coveragePercentMap = const {},
  }) {
    coveragePercent = coveragePercentMap.map((key, value) =>
        MapEntry<CoverageType, double>(
            CoverageType.values.firstWhere((element) => element.string == key),
            value));
  }

  /// Set the happiness rank.
  set rank(int rank) {
    happinessRank = rank;
  }

  /// Get the city name.
  String get name {
    return nameAndState.split(',')[0];
  }

  /// Get the state abbreviation.
  String get stateShort {
    return nameAndState.split(', ')[1];
  }

  /// Get the state name.
  String get stateLong {
    // Finds the abbreviation for the state
    final abbr = nameAndState.split(', ')[1];
    return usStates[abbr] ?? abbr;
  }

  /// The most north-eastern point of the city.
  LatLng? get northEast {
    return LatLngBounds.fromPoints(combinedPolygonPoints).northEast;
  }

  /// The most south-western point of the city.
  LatLng? get southWest {
    return LatLngBounds.fromPoints(combinedPolygonPoints).southWest;
  }

  /// Creates polygons from [polygonsPoints] with [polygonHolesPoints] as holes.
  ///
  /// Enabling [isDotted] will severely hamper performance at high zoom levels.
  List<Polygon> polygons({
    Color? borderColor,
    Color? fillColor,
    bool? isFilled,
    bool? isDotted,
    double? borderStrokeWidth,
  }) {
    return List<Polygon>.generate(
      polygonsPoints.length,
      (index) => Polygon(
        points: polygonsPoints[index],
        holePointsList: polygonHolesPoints[index] ?? [],
        color: fillColor ?? Colors.grey.withAlpha(100),
        isFilled: isFilled ?? true,
        borderColor: borderColor ?? Colors.black,
        borderStrokeWidth: borderStrokeWidth ?? 1,
        isDotted: isDotted ?? false,
      ),
    );
  }

  /// Gets the coverage percent for the selected [type] compared to the [others]
  double coverage({
    CoverageType type = CoverageType.vegetation,
    List<CoverageType> others = const [
      CoverageType.notVegetated,
      CoverageType.water
    ],
  }) {
    double total = coveragePercent[type]!;
    for (final other in others) {
      total += coveragePercent[other]!;
    }
    return coveragePercent[type]! / total;
  }

  /// Gets the [CenterZoom] for the city with the given [MapController].
  CenterZoom centerZoom(
    MapController mapController, {
    FitBoundsOptions options =
        const FitBoundsOptions(padding: EdgeInsets.all(20)),
  }) {
    return mapController.centerZoomFitBounds(
      bounds,
      options: options,
    );
  }

  /// Loads all the necessarry data for the city, before it returns the loaded city object.
  Future<City> loadWithData() async {
    if (!loaded) {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> assetMap = jsonDecode(manifest);

      final String path = 'assets/data/polygons/$name, $stateLong.json';

      if (assetMap.containsKey(path)) {
        // path.replaceAll(' ', '%20')
        final polygonString = await rootBundle.loadString(path);
        final Map<String, dynamic> jsonMap = jsonDecode(polygonString);
        List<dynamic> polygonList = [];
        if (jsonMap.containsKey('geometries')) {
          polygonList = jsonMap['geometries'][0]['coordinates'];
        } else {
          polygonList = jsonMap['coordinates'];
        }

        if (jsonMap['type'] == 'Polygon') {
          int index = 0;
          int subIndex = 0;
          for (List polygon in polygonList) {
            List<LatLng> polygonLatLngs = List.generate(
              polygon.length,
              (index) {
                final point = polygon[index];
                double lat = point[1].toDouble();
                double lon = point[0].toDouble();
                return LatLng(lat, lon);
              },
            );
            if (subIndex == 0) {
              polygonsPoints.add(polygonLatLngs);
            } else {
              polygonHolesPoints.update(
                index,
                (value) => [...value, polygonLatLngs],
                ifAbsent: () => [polygonLatLngs],
              );
            }
            combinedPolygonPoints.addAll(polygonLatLngs);
            subIndex++;
          }
        } else {
          int index = 0;
          for (List polygon in polygonList) {
            int subIndex = 0;
            for (List points in polygon) {
              List<LatLng> polygonLatLngs = List.generate(
                points.length,
                (index) {
                  final point = points[index];
                  double lat = point[1].toDouble();
                  double lon = point[0].toDouble();
                  return LatLng(lat, lon);
                },
              );
              if (subIndex == 0) {
                polygonsPoints.add(polygonLatLngs);
              } else {
                polygonHolesPoints.update(
                  index,
                  (value) => [...value, polygonLatLngs],
                  ifAbsent: () => [polygonLatLngs],
                );
              }
              combinedPolygonPoints.addAll(polygonLatLngs);
              subIndex++;
            }
            index++;
          }
        }
      }
      loaded = true;
    }
    return this;
  }

  /// A JSON-friendly version of the city object.
  Map<String, dynamic> toMap() {
    return {
      'City': nameAndState,
      'Vegetation Fraction': vegFrac,
      'Happiness Score': happinessScore,
      'Emotional and Physical Well-Being Rank': emoPhysRank,
      'Income and Employment Rank': incomeEmpRank,
      'Community and Environment Rank': communityEnvRank,
      'Center': center.toJson(),
      'Coverage':
          coveragePercent.map((key, value) => MapEntry(key.string, value)),
    };
  }
}

class CitiesUtilities {
  /// Initializes the cities from asset storage.
  static Future<List<City>> loadCities() async {
    final dataFile = await rootBundle.loadString('assets/city_data.json');
    List<dynamic> data = await jsonDecode(dataFile);

    final newDataFile = await rootBundle
        .loadString('assets/data/coverage_percent_bands_1-11.json');
    Map<String, dynamic> newData = await jsonDecode(newDataFile);

    String bboxFile = await rootBundle.loadString('assets/data/bbox.json');
    Map<String, dynamic> bboxData = await jsonDecode(bboxFile);

    List<City> cities = [];
    for (Map<String, dynamic> cityData in data) {
      var coords = bboxData[cityData['City'].split(',')[0] +
          ', ' +
          usStates[cityData['City'].split(', ')[1]]];

      LatLng sw = LatLng(coords[2], coords[0]);
      LatLng ne = LatLng(coords[3], coords[1]);

      final LatLngBounds bounds = LatLngBounds(sw, ne);
      final center = cityData['Center']['coordinates'];

      final city = City(
        nameAndState: cityData['City'],
        vegFrac: cityData['Vegetation Fraction'],
        happinessScore: cityData['Happiness Score'].toDouble(),
        emoPhysRank: cityData['Emotional and Physical Well-Being Rank'],
        incomeEmpRank: cityData['Income and Employment Rank'],
        communityEnvRank: cityData['Community and Environment Rank'],
        center: LatLng(center.last, center.first),
        bounds: bounds,
        coveragePercentMap: newData[cityData['City'].split(',')[0] +
            ', ' +
            usStates[cityData['City'].split(', ')[1]]],
      );

      cities.add(city);
    }

    cities.sort(
      (a, b) => b.happinessScore.compareTo(a.happinessScore),
    );

    for (final city in cities) {
      city.rank = cities.indexOf(city) + 1;
    }

    return cities;
  }

  /// Gets a JSON map of all the cities.
  static String getDataString(List<City> cities) {
    List<dynamic> jsonMap = [];
    for (final city in cities) {
      jsonMap.add(city.toMap());
    }
    const encoder = JsonEncoder.withIndent('    ');
    return encoder.convert(jsonMap);
  }
}
