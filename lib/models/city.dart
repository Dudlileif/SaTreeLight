import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/constants/us_states_map.dart';
import 'package:satreelight/models/coverage_type.dart';

/// A class containing all necessary data for each city.
class City {
  City({
    required this.nameAndState,
    required this.vegFrac,
    required this.happinessScore,
    required this.emoPhysRank,
    required this.incomeEmpRank,
    required this.communityEnvRank,
    required this.center,
    required this.bounds,
    Map<String, double> coveragePercentMap = const {},
  }) {
    coveragePercent = coveragePercentMap.map(
      (key, value) => MapEntry<CoverageType, double>(
        CoverageType.values.firstWhere((element) => element.string == key),
        value,
      ),
    );
  }

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

  /// Set the happiness rank.
  set rank(int? rank) {
    happinessRank = rank;
  }

  int? get rank => happinessRank;

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
    var total = coveragePercent[type]!;
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
      final assetMap = Map<String, dynamic>.from(jsonDecode(manifest) as Map);

      final path = 'assets/data/polygons/$name, $stateLong.json';

      if (assetMap.containsKey(path)) {
        // path.replaceAll(' ', '%20')
        final polygonString = await rootBundle.loadString(path);
        final jsonMap =
            Map<String, dynamic>.from(jsonDecode(polygonString) as Map);
        var polygonList = <List<dynamic>>[];
        if (jsonMap.containsKey('geometries')) {
          polygonList = List.from(
            (List<dynamic>.from(jsonMap['geometries'] as List)[0]
                as Map)['coordinates'] as List,
          );
        } else {
          polygonList = List.from(jsonMap['coordinates'] as List);
        }

        if (jsonMap['type'] == 'Polygon') {
          const index = 0;
          var subIndex = 0;
          for (final polygon in polygonList) {
            final polygonLatLngs = List<LatLng>.generate(
              polygon.length,
              (index) {
                final point = List<double>.from(polygon[index] as List);
                final lat = point[1];
                final lon = point[0];
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
          var index = 0;
          for (final polygon in polygonList) {
            var subIndex = 0;
            for (final points in List<List<dynamic>>.from(polygon)) {
              final polygonLatLngs = List<LatLng>.generate(
                points.length,
                (index) {
                  final point = List<double>.from(points[index] as List);
                  final lat = point[1];
                  final lon = point[0];
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
    final data =
        List<Map<String, dynamic>>.from(await jsonDecode(dataFile) as List);

    final coveragePercentFile = await rootBundle
        .loadString('assets/data/coverage_percent_bands_1-11.json');
    final coveragePercentData =
        Map<String, dynamic>.from(await jsonDecode(coveragePercentFile) as Map);

    final bboxFile = await rootBundle.loadString('assets/data/bbox.json');
    final bboxData =
        Map<String, dynamic>.from(await jsonDecode(bboxFile) as Map);

    final cities = <City>[];
    for (final cityData in data) {
      final cityName = (cityData['City'] as String).split(',')[0];
      final state = usStates[(cityData['City'] as String).split(', ')[1]];
      final cityAndState = '$cityName, $state';
      final coords = List<double>.from(
        bboxData[cityAndState] as List,
      );

      final sw = LatLng(coords[2], coords[0]);
      final ne = LatLng(coords[3], coords[1]);

      final bounds = LatLngBounds(sw, ne);
      final center =
          List<double>.from((cityData['Center'] as Map)['coordinates'] as List);

      final city = City(
        nameAndState: cityData['City'] as String,
        vegFrac: cityData['Vegetation Fraction'] as double,
        happinessScore: cityData['Happiness Score'] as double,
        emoPhysRank: cityData['Emotional and Physical Well-Being Rank'] as int,
        incomeEmpRank: cityData['Income and Employment Rank'] as int,
        communityEnvRank: cityData['Community and Environment Rank'] as int,
        center: LatLng(center.last, center.first),
        bounds: bounds,
        coveragePercentMap:
            Map<String, double>.from(coveragePercentData[cityAndState] as Map),
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
    final jsonMap = <dynamic>[];
    for (final city in cities) {
      jsonMap.add(city.toMap());
    }
    const encoder = JsonEncoder.withIndent('    ');
    return encoder.convert(jsonMap);
  }
}
