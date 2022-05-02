import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/constants/us_states_map.dart';

class City {
  final String nameAndState;
  final double vegFrac;
  final double happyScore;
  final int emoPhysRank;
  final int incomeEmpRank;
  final int communityEnvRank;
  final LatLng center;
  int? happinessRank;
  bool loaded = false;
  List<LatLng> combinedPolygonPoints = [];
  List<List<LatLng>> polygonsPoints = [];
  Map<int, List<List<LatLng>>> polygonHolesPoints = {};

  City({
    required this.nameAndState,
    required this.vegFrac,
    required this.happyScore,
    required this.emoPhysRank,
    required this.incomeEmpRank,
    required this.communityEnvRank,
    required this.center,
  });

  set rank(int rank) {
    happinessRank = rank;
  }

  String get name {
    return nameAndState.split(',')[0];
  }

  String get stateShort {
    return nameAndState.split(', ')[1];
  }

  String get stateLong {
    // Finds the abbreviation for the state
    final abbr = nameAndState.split(', ')[1];
    return usStates[abbr] ?? abbr;
  }

  LatLng? get northEast {
    return LatLngBounds.fromPoints(combinedPolygonPoints).northEast;
  }

  LatLng? get southWest {
    return LatLngBounds.fromPoints(combinedPolygonPoints).southWest;
  }

  Polygon get polygon {
    return Polygon(
      points: polygon.points,
      color: Colors.grey.withAlpha(100),
      borderColor: Colors.black,
      borderStrokeWidth: 1,
      isDotted: true,
    );
  }

  List<Polygon> get polygons {
    return List<Polygon>.generate(
      polygonsPoints.length,
      (index) => Polygon(
        points: polygonsPoints[index],
        holePointsList: polygonHolesPoints[index] ?? [],
        color: Colors.grey.withAlpha(100),
        borderColor: Colors.black,
        borderStrokeWidth: 1,
        isDotted: true,
      ),
    );
  }

  LatLngBounds get bounds {
    return LatLngBounds.fromPoints(combinedPolygonPoints);
  }

  CenterZoom centerZoom(MapController mapController) {
    return mapController.centerZoomFitBounds(bounds);
  }

  Future<OverlayImage> getImage({String type = 'veg_overlay'}) async {
    String path =
        'assets/images_hl_veg_only/' + nameAndState + ' hl_veg_only.png';
    final manifest = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> assetMap = jsonDecode(manifest);
    if (!assetMap.containsKey(path.replaceAll(' ', '%20'))) {
      path = 'assets/transparent.png';
    }
    return OverlayImage(
      bounds: bounds,
      opacity: 0.5,
      imageProvider: AssetImage(path),
    );
  }

  Future<City> loadWithData() async {
    if (!loaded) {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      Map<String, dynamic> assetMap = jsonDecode(manifest);
      final path = 'assets/american_cities/' + nameAndState + '.json';

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
      loaded = true;
    }
    return this;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map['City'] = nameAndState;
    map['Vegetation Fraction'] = vegFrac;
    map['Happiness Score'] = happyScore;
    map['Emotional and Physical Well-Being Rank'] = emoPhysRank;
    map['Income and Employment Rank'] = incomeEmpRank;
    map['Community and Environment Rank'] = communityEnvRank;
    map['Center'] = center.toJson();
    return map;
  }
}

Future<List<City>> loadCities() async {
  final dataFile = await rootBundle.loadString('assets/city_data.json');
  List<dynamic> data = await jsonDecode(dataFile);
  List<City> cities = [];
  for (Map<String, dynamic> cityData in data) {
    final center = cityData['Center']['coordinates'];
    final city = City(
      nameAndState: cityData['City'],
      vegFrac: cityData['Vegetation Fraction'],
      happyScore: cityData['Happiness Score'].toDouble(),
      emoPhysRank: cityData['Emotional and Physical Well-Being Rank'],
      incomeEmpRank: cityData['Income and Employment Rank'],
      communityEnvRank: cityData['Community and Environment Rank'],
      center: LatLng(center.last, center.first),
    );
    cities.add(city);
  }

  cities.sort(
    (a, b) => b.happyScore.compareTo(a.happyScore),
  );

  for (final city in cities) {
    city.rank = cities.indexOf(city) + 1;
  }

  return cities;
}

String getDataString(List<City> cities) {
  List<dynamic> jsonMap = [];
  for (final city in cities) {
    jsonMap.add(city.toMap());
  }
  const encoder = JsonEncoder.withIndent('    ');
  return encoder.convert(jsonMap);
}
