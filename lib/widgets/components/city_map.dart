import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/constants/animation_config.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/screens/leaflet_map/components/cached_tile_provider.dart';
import 'package:satreelight/screens/leaflet_map/components/osm_contribution.dart';
import 'package:satreelight/screens/leaflet_map/components/themed_tiles_container.dart';
import 'package:satreelight/utilities/lat_lng_bounds_tween.dart';
import 'package:satreelight/utilities/lat_lng_tween.dart';
import 'package:satreelight/widgets/components/city_layer.dart';
import 'package:satreelight/widgets/components/mask_selector.dart';
import 'package:satreelight/widgets/components/providers/city_layer_options.dart';
import 'package:satreelight/widgets/components/providers/last_map_event_delay.dart';

/// A map of the widget.city, with a bounds polygon and selected masks.
class CityMap extends ConsumerStatefulWidget {
  const CityMap({
    required this.city,
    super.key,
  });
  final City city;

  @override
  ConsumerState<CityMap> createState() => _CityMapState();
}

class _CityMapState extends ConsumerState<CityMap>
    with SingleTickerProviderStateMixin {
  final mapController = MapController();
  final boundsOptions = const FitBoundsOptions(
    padding: EdgeInsets.all(20),
  );

  City? prevCity;
  late City city;

  late final AnimationController animationController;

  late LatLngBoundsTween boundsTween;

  late LatLngBounds bounds;

  late LatLngTween centerTween;

  late LatLng center;

  LatLng? swPanBoundary;
  LatLng? nePanBoundary;

  double? _initZoom;
  double? _endZoom;
  double? _midZoom;

  late double? _maxZoom;

  void boundsAnimationListener() => setState(() {
        final value = animationController.value;
        bounds = boundsTween.evaluate(
          value < 1
              ? 0
              : value < 2
                  ? 3 * (value - 1)
                  : 3,
          maxValue: 3,
        );

        _maxZoom = value < 1
            ? _midZoom! * value + _initZoom! * (1 - value)
            : value < 2
                ? _midZoom
                : _endZoom! * (value - 2) + _midZoom! * (3 - value);

        mapController.fitBounds(
          bounds,
          options: FitBoundsOptions(
            padding: const EdgeInsets.all(20),
            maxZoom: _maxZoom!,
          ),
        );
        if (value == 3) {
          nePanBoundary = city.bounds.northEast;
          swPanBoundary = city.bounds.southWest;
        }
      });

  void animateBoundsTransition() {
    animationController
      ..reset()
      ..removeListener(boundsAnimationListener);

    if (prevCity != null) {
      boundsTween = LatLngBoundsTween(
        begin: prevCity!.bounds,
        end: city.bounds,
      );

      _initZoom = mapController
          .centerZoomFitBounds(
            prevCity!.bounds,
            options: boundsOptions,
          )
          .zoom;
      _endZoom = mapController
          .centerZoomFitBounds(
            city.bounds,
            options: boundsOptions,
          )
          .zoom;
      _midZoom = mapController
          .centerZoomFitBounds(
            LatLngBounds.fromPoints([
              prevCity!.bounds.northWest,
              prevCity!.bounds.southEast,
              city.bounds.northWest,
              city.bounds.southEast,
            ]),
            options: boundsOptions,
          )
          .zoom;
      animationController
        ..addListener(boundsAnimationListener)
        ..animateTo(
          3,
          duration: AnimationConfig.duration,
          curve: AnimationConfig.curve,
        );
    }
  }

  @override
  void initState() {
    super.initState();
    city = widget.city;
    bounds = city.bounds;
    swPanBoundary = city.bounds.southWest;
    nePanBoundary = city.bounds.northEast;
    animationController = AnimationController(
      vsync: this,
      value: 0,
      upperBound: 3,
      duration: AnimationConfig.duration,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      selectedCityProvider,
      (previous, next) => setState(() {
        prevCity = previous ?? prevCity;
        city = next ?? city;
        swPanBoundary = LatLng(-90, -180);
        nePanBoundary = LatLng(90, 180);
        animateBoundsTransition();
      }),
    );

    final map = FlutterMap(
      mapController: mapController,
      options: MapOptions(
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        maxZoom: 18.25,
        swPanBoundary: swPanBoundary,
        nePanBoundary: nePanBoundary,
        bounds: bounds,
        boundsOptions: boundsOptions,
        slideOnBoundaries: true,
        keepAlive: true,
        onMapEvent: (event) {
          ref.read(lastMapEventDelayProvider.notifier).restart();
        },
        onPositionChanged: (position, hasGesture) {
          ref.read(lastMapEventDelayProvider.notifier).restart();
        },
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          tilesContainerBuilder: (context, tilesContainer, tiles) =>
              ThemedTilesContainer(tilesContainer: tilesContainer),
          backgroundColor: Theme.of(context).cardColor,
          tileProvider: CachedTileProvider(),
          userAgentPackageName: 'satreelight',
        ),
        if (prevCity != null && animationController.isAnimating)
          CityLayer(
            city: prevCity!,
          ),
        CityLayer(
          city: city,
        ),
      ],
    );

    return Stack(
      children: [
        map,
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: FilledButton.tonal(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const MaskSelector(),
              ),
              child: const Text('Masks'),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.bottomRight,
          child: OSMContribution(),
        ),
        const Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: _CityMapTestSettings(),
          ),
        ),
      ],
    );
  }
}

class _CityMapTestSettings extends ConsumerWidget {
  const _CityMapTestSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Use polygon clipper'),
                Checkbox(
                  value: ref.watch(usePolygonClipperProvider),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(usePolygonClipperProvider.notifier)
                          .update(value: value);
                    }
                  },
                )
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Use images'),
                Checkbox(
                  value: ref.watch(useImagesProvider),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(useImagesProvider.notifier).update(value: value);
                    }
                  },
                )
              ],
            ),
            if (ref.watch(useImagesProvider))
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Use combined image'),
                  Checkbox(
                    value: ref.watch(useCombinedImageProvider),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(useCombinedImageProvider.notifier)
                            .update(value: value);
                      }
                    },
                  )
                ],
              ),
          ],
        ),
      ),
    );
  }
}
