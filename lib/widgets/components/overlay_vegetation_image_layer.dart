import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/plugin_api.dart';

class OverlayVegetationImageLayerOptions extends LayerOptions {
  final List<OverlayVegetationImage> overlayImages;

  OverlayVegetationImageLayerOptions({
    Key? key,
    this.overlayImages = const [],
    Stream<void>? rebuild,
  }) : super(key: key, rebuild: rebuild);
}

class OverlayVegetationImage {
  final LatLngBounds bounds;
  final Image image;

  OverlayVegetationImage({
    required this.bounds,
    required this.image,
  });
}

class OverlayVegetationImageLayerWidget extends StatelessWidget {
  final OverlayVegetationImageLayerOptions options;

  const OverlayVegetationImageLayerWidget({Key? key, required this.options})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapState = MapState.maybeOf(context)!;
    return OverlayVegetationImageLayer(options, mapState, mapState.onMoved);
  }
}

class OverlayVegetationImageLayer extends StatelessWidget {
  final OverlayVegetationImageLayerOptions overlayImageOpts;
  final MapState map;
  final Stream<void>? stream;

  OverlayVegetationImageLayer(this.overlayImageOpts, this.map, this.stream)
      : super(key: overlayImageOpts.key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<void>(
      stream: stream,
      builder: (BuildContext context, _) {
        return ClipRect(
          child: Stack(
            children: <Widget>[
              for (var overlayImage in overlayImageOpts.overlayImages)
                _positionedForOverlay(overlayImage),
            ],
          ),
        );
      },
    );
  }

  Positioned _positionedForOverlay(OverlayVegetationImage overlayImage) {
    final zoomScale =
        map.getZoomScale(map.zoom, map.zoom); // TODO replace with 1?
    final pixelOrigin = map.getPixelOrigin();
    final upperLeftPixel =
        map.project(overlayImage.bounds.northWest).multiplyBy(zoomScale) -
            pixelOrigin;
    final bottomRightPixel =
        map.project(overlayImage.bounds.southEast).multiplyBy(zoomScale) -
            pixelOrigin;
    return Positioned(
      left: upperLeftPixel.x.toDouble(),
      top: upperLeftPixel.y.toDouble(),
      width: (bottomRightPixel.x - upperLeftPixel.x).toDouble(),
      height: (bottomRightPixel.y - upperLeftPixel.y).toDouble(),
      child: overlayImage.image,
    );
  }
}
