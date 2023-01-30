import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/constants/us_states_map.dart';
import 'package:satreelight/models/coverage_type.dart';
import 'package:satreelight/widgets/components/overlay_vegetation_image_layer.dart';

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

  /// Bounds from the new polygons.
  late LatLngBounds boundsNew;

  /// Combination of all [polygonsPointsNew], used to find [boundsNew].
  List<LatLng> combinedPolygonPointsNew = [];

  /// Polygons the city is made of, new data.
  List<List<LatLng>> polygonsPointsNew = [];

  /// Polygon holes in the city, new data.
  Map<int, List<List<LatLng>>> polygonHolesPointsNew = {};

  City({
    required this.nameAndState,
    required this.vegFrac,
    required this.happinessScore,
    required this.emoPhysRank,
    required this.incomeEmpRank,
    required this.communityEnvRank,
    required this.center,
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

  /// Gets the polygons made from [polygonsPoints] with [polygonHolesPoints] as holes.
  List<Polygon> get polygons {
    return List<Polygon>.generate(
      polygonsPoints.length,
      (index) => Polygon(
        points: polygonsPoints[index],
        holePointsList: polygonHolesPoints[index] ?? [],
        color: Colors.grey.withAlpha(100),
        isFilled: true,
        borderColor: Colors.black,
        borderStrokeWidth: 1,
        isDotted: true,
      ),
    );
  }

  /// Gets the polygons made from [polygonsPointsNew] with [polygonHolesPointsNew] as holes.
  List<Polygon> get polygonsNew {
    return List<Polygon>.generate(
      polygonsPointsNew.length,
      (index) => Polygon(
        points: polygonsPointsNew[index],
        holePointsList: polygonHolesPointsNew[index] ?? [],
        color: Colors.grey.withAlpha(100),
        isFilled: true,
        borderColor: Colors.black,
        borderStrokeWidth: 1,
        isDotted: true,
      ),
    );
  }

  /// Gets the bounds of the city.
  LatLngBounds get bounds {
    return LatLngBounds.fromPoints(combinedPolygonPoints);
  }

  /// Gets the coverage percent for the selected [type] compared to the [others]
  double coverage(
      {CoverageType type = CoverageType.vegetation,
      List<CoverageType> others = const [
        CoverageType.notVegetated,
        CoverageType.water
      ]}) {
    double total = coveragePercent[type]!;
    for (final other in others) {
      total += coveragePercent[other]!;
    }
    return coveragePercent[type]! / total;
  }

  /// Gets the [CenterZoom] for the city with the given [MapController].
  CenterZoom centerZoom(MapController mapController,
      {FitBoundsOptions options =
          const FitBoundsOptions(padding: EdgeInsets.all(20))}) {
    return mapController.centerZoomFitBounds(bounds, options: options);
  }

  /// Gets the [OverlayVegetationImage] of the city.
  Future<OverlayVegetationImage> getImage({
    /// Whether to use the new data
    bool newData = false,

    /// Which mask to get, only used with new data.
    CoverageType mask = CoverageType.vegetation,

    /// Color to override the mask with.
    Color? color,
  }) async {
    String path = 'assets/images_hl_veg_only/$nameAndState hl_veg_only.png';
    if (newData) {
      path = 'assets/new/masks/${mask.string}/$name, $stateLong.png';
    }
    final manifest = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> assetMap = jsonDecode(manifest);
    if (!assetMap.containsKey(path.replaceAll(' ', '%20'))) {
      path = 'assets/transparent.png';
    }
    final imageBounds = newData ? boundsNew : bounds;
    return OverlayVegetationImage(
      bounds: imageBounds,
      image: Image.asset(
        path,
        color: color,
        fit: BoxFit.fill,
      ),
    );
  }

  /// Gets the list of [OverlayVegetationImage] for all of the selected masks.
  Future<List<OverlayVegetationImage>> getImages({
    /// Masks to get.
    required List<CoverageType> masks,

    /// Colors to override the masks with.
    required Map<CoverageType, Color> colors,
  }) async {
    List<OverlayVegetationImage> images = [];
    for (final mask in masks) {
      String path = 'assets/new/masks/${mask.string}/$name, $stateLong.png';
      final manifest = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> assetMap = jsonDecode(manifest);
      if (!assetMap.containsKey(path.replaceAll(' ', '%20'))) {
        path = 'assets/transparent.png';
      }
      images.add(OverlayVegetationImage(
        bounds: boundsNew,
        image: Image.asset(
          path,
          color: colors[mask],
          fit: BoxFit.fill,
        ),
      ));
    }
    return images;
  }

  /// Loads all the necessarry data for the city, before it returns the loaded city object.
  Future<City> loadWithData() async {
    if (!loaded) {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> assetMap = jsonDecode(manifest);
      final path = 'assets/american_cities/$nameAndState.json';

      if (assetMap.containsKey(path.replaceAll(' ', '%20'))) {
        final polygonString = await rootBundle.loadString(path);
        final Map<String, dynamic> jsonMap = jsonDecode(polygonString);
        List<dynamic> polygonList = [];
        if (jsonMap.containsKey('geometries')) {
          polygonList = jsonMap['geometries'][0]['coordinates'];
        } else {
          polygonList = jsonMap['coordinates'];
        }

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

      final pathNew = 'assets/new/polygons/$name, $stateLong.json';

      if (assetMap.containsKey(pathNew.replaceAll(' ', '%20'))) {
        final polygonString = await rootBundle.loadString(pathNew);
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
              polygonsPointsNew.add(polygonLatLngs);
            } else {
              polygonHolesPointsNew.update(
                index,
                (value) => [...value, polygonLatLngs],
                ifAbsent: () => [polygonLatLngs],
              );
            }
            combinedPolygonPointsNew.addAll(polygonLatLngs);
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
                polygonsPointsNew.add(polygonLatLngs);
              } else {
                polygonHolesPointsNew.update(
                  index,
                  (value) => [...value, polygonLatLngs],
                  ifAbsent: () => [polygonLatLngs],
                );
              }
              combinedPolygonPointsNew.addAll(polygonLatLngs);
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
    };
  }
}

class CitiesUtilities {
  /// Initializes the cities from asset storage.
  static Future<List<City>> loadCities() async {
    final dataFile = await rootBundle.loadString('assets/city_data.json');
    List<dynamic> data = await jsonDecode(dataFile);

    final newDataFile = await rootBundle
        .loadString('assets/new/coverage_percent_bands_1-11.json');
    Map<String, dynamic> newData = await jsonDecode(newDataFile);

    List<City> cities = [];
    for (Map<String, dynamic> cityData in data) {
      final center = cityData['Center']['coordinates'];
      final city = City(
        nameAndState: cityData['City'],
        vegFrac: cityData['Vegetation Fraction'],
        happinessScore: cityData['Happiness Score'].toDouble(),
        emoPhysRank: cityData['Emotional and Physical Well-Being Rank'],
        incomeEmpRank: cityData['Income and Employment Rank'],
        communityEnvRank: cityData['Community and Environment Rank'],
        center: LatLng(center.last, center.first),
        coveragePercentMap: newData[cityData['City'].split(',')[0] +
            ', ' +
            usStates[cityData['City'].split(', ')[1]]],
      );

      String bboxFile = await rootBundle.loadString('assets/new/bbox.json');
      Map<String, dynamic> bboxData = await jsonDecode(bboxFile);

      var coords = bboxData[cityData['City'].split(',')[0] +
          ', ' +
          usStates[cityData['City'].split(', ')[1]]];

      LatLng sw = LatLng(coords[2], coords[0]);
      LatLng ne = LatLng(coords[3], coords[1]);

      city.boundsNew = LatLngBounds(sw, ne);

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
