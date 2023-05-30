import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:satreelight/src/features/animation/animation.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/common_widgets/loading_indicator.dart';
import 'package:satreelight/src/features/map/map.dart';
import 'package:satreelight/src/features/mask_selection/mask_selection.dart';

/// A map of the widget.city, with bounds polygons and selected masks.
class CityMap extends ConsumerStatefulWidget {
  const CityMap({super.key});

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
  City? city;

  late final AnimationController animationController;

  Animation<LatLngBounds>? boundsAnimation;
  Animation<double>? maxZoomAnimation;

  LatLngBounds? bounds;

  LatLng? swPanBoundary;
  LatLng? nePanBoundary;

  void boundsAnimationListener() => setState(() {
        bounds = boundsAnimation?.value;
        if (bounds != null && maxZoomAnimation != null) {
          mapController.fitBounds(
            bounds!,
            options: FitBoundsOptions(
              padding: const EdgeInsets.all(20),
              maxZoom: maxZoomAnimation!.value,
            ),
          );
        }
        if (animationController.value == 1 && city != null) {
          nePanBoundary = city!.bounds.northEast;
          swPanBoundary = city!.bounds.southWest;
        }
      });

  void animateBoundsTransition() {
    animationController
      ..reset()
      ..removeListener(boundsAnimationListener);

    if (city != null && prevCity != null) {
      boundsAnimation = LatLngBoundsTween(
        begin: prevCity!.bounds,
        end: city!.bounds,
      ).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Interval(
            1 / 3,
            2 / 3,
            curve: AnimationConfig.curve,
          ),
        ),
      );

      final initZoom = mapController
          .centerZoomFitBounds(
            prevCity!.bounds,
            options: boundsOptions,
          )
          .zoom;
      final endZoom = mapController
          .centerZoomFitBounds(
            city!.bounds,
            options: boundsOptions,
          )
          .zoom;
      final midZoom = mapController
          .centerZoomFitBounds(
            LatLngBounds.fromPoints([
              prevCity!.bounds.northWest,
              prevCity!.bounds.southEast,
              city!.bounds.northWest,
              city!.bounds.southEast,
            ]),
            options: boundsOptions,
          )
          .zoom;

      maxZoomAnimation = TweenSequence(
        [
          TweenSequenceItem(
            tween: Tween<double>(begin: initZoom, end: midZoom),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: midZoom, end: midZoom),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: midZoom, end: endZoom),
            weight: 1,
          )
        ],
      ).animate(animationController);

      animationController
        ..addListener(boundsAnimationListener)
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
    city = ref.read(selectedCityProvider);
    bounds = city?.bounds;
    swPanBoundary = city?.bounds.southWest;
    nePanBoundary = city?.bounds.northEast;
    animationController = AnimationController(
      vsync: this,
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

    final map = city != null
        ? FlutterMap(
            mapController: mapController,
            options: MapOptions(
              interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              maxZoom: 20,
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
              themedTileLayerBuilder(
                context,
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  backgroundColor: Theme.of(context).cardColor,
                  tileProvider: CachedTileProvider(),
                  userAgentPackageName: 'satreelight',
                  maxNativeZoom: 19,
                  maxZoom: 20,
                ),
              ),
              if (prevCity != null && animationController.isAnimating)
                CityLayer(city: prevCity!),
              CityLayer(city: city!),
            ],
          )
        : const LoadingIndicator();

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
                builder: (context) => const MaskSelectionDialog(),
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
          ],
        ),
      ),
    );
  }
}
