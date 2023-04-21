import 'dart:math';

import 'package:flutter/material.dart';

export 'screens/emoji_testing_page.dart';

/// A custom emoji painter that can go dynamically from
/// happy to angry/sad.
class EmojiPainter extends CustomPainter {
  const EmojiPainter({
    this.value = 0.5,
    this.minColor = Colors.red,
    this.midColor = Colors.yellow,
    this.maxColor = Colors.green,
    this.eyeColor = Colors.white,
    this.eyeFillColor = Colors.black,
    this.mouthColor = Colors.black,
    this.mouthFillColor = Colors.white,
    this.shadowColor = Colors.black,
  });

  /// A value between 0.0 and 1.0 to determine the state of the face.
  final double value;

  /// The color of the face at value 0.
  final Color minColor;

  /// The color of the face at value 0.5.
  final Color midColor;

  /// The color of the face at value 1.
  final Color maxColor;

  /// The outer color of the eyes.
  final Color eyeColor;

  /// The fill color of the eyes.
  final Color eyeFillColor;

  /// The outer color of the mouth.
  final Color mouthColor;

  /// The fill color of the mouth.
  final Color mouthFillColor;

  /// The color of the shadow around the face.
  final Color shadowColor;

  double get _mouthWidthFraction => 0.5;

  Color get _faceColor =>
      TweenSequence(
        [
          TweenSequenceItem(
            tween: ColorTween(begin: minColor, end: midColor),
            weight: 1,
          ),
          TweenSequenceItem(
            tween: ColorTween(begin: midColor, end: maxColor),
            weight: 1,
          ),
        ],
      ).transform(value) ??
      midColor;

  @override
  void paint(Canvas canvas, Size size) {
    drawFace(canvas, size);
    drawEyes(canvas, size);
    drawMouth(canvas, size);
  }

  void drawFace(Canvas canvas, Size size) {
    canvas
      ..drawShadow(
        Path()
          ..addArc(
            Rect.fromCircle(
              center: size.center(Offset.zero),
              radius: size.shortestSide / 2,
            ),
            0,
            2 * pi,
          ),
        shadowColor,
        10,
        false,
      )
      ..drawCircle(
        size.center(Offset.zero),
        size.shortestSide / 2,
        Paint()..color = _faceColor,
      );
  }

  void drawEyes(Canvas canvas, Size size) {
    final leftEyePos = Offset(
      -size.shortestSide * 0.2,
      -size.shortestSide * 0.15,
    );

    final rightEyePos = Offset(
      size.shortestSide * 0.2,
      -size.shortestSide * 0.15,
    );

    final leftEye = Path.combine(
      PathOperation.difference,
      eyePath(
        size,
        leftEyePos,
      ),
      Path.combine(
        PathOperation.union,
        topEyelid(size, leftEyePos),
        bottomEyelid(size, leftEyePos),
      ),
    );

    final rightEye = Path.combine(
      PathOperation.difference,
      eyePath(
        size,
        rightEyePos,
      ),
      Path.combine(
        PathOperation.union,
        topEyelid(size, rightEyePos),
        bottomEyelid(size, rightEyePos),
      ),
    );
    final eyes = leftEye..addPath(rightEye, Offset.zero);

    canvas
      ..drawShadow(eyes, shadowColor, 10, false)
      ..drawPath(
        eyes,
        Paint()
          ..color = eyeFillColor
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        eyes,
        Paint()
          ..color = eyeColor
          ..strokeWidth = 1.75 * size.shortestSide * 0.025
          ..style = PaintingStyle.stroke,
      );
  }

  void drawMouth(Canvas canvas, Size size) {
    final mouthValue = pow(0.5 - value, 2) * 4;

    final mouth = value < 0.5
        ? invertedMouthPath(size, mouthValue)
        : mouthPath(size, mouthValue);

    final mouthOpen = (0.5 - value).abs() > 0.2;

    canvas
      ..drawShadow(mouth, shadowColor, 10, false)
      ..drawPath(
        mouth,
        Paint()
          ..color = mouthFillColor
          ..style = PaintingStyle.fill,
      )
      ..drawPath(
        mouth,
        Paint()
          ..color = mouthOpen ? mouthFillColor : mouthColor
          ..strokeWidth = 2.5 * size.shortestSide * 0.025
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
  }

  Path eyePath(Size size, Offset offset) {
    final eyePath = Path()
      ..addOval(
        Rect.fromCenter(
          center: size.center(offset),
          width: size.shortestSide * 0.25,
          height: size.shortestSide * 0.225,
        ),
      );
    return eyePath;
  }

  Path mouthPath(Size size, num value) {
    return Path()
      ..arcTo(
        Rect.fromCenter(
          center: size.center(
            Offset(
              0,
              size.shortestSide * (0.2 - 0.2 * value / 2),
            ),
          ),
          width: size.shortestSide *
              _mouthWidthFraction *
              (0.5 + value / (value + 0.2)),
          height: size.shortestSide * 0.5 * value,
        ),
        0,
        pi,
        true,
      )
      ..arcTo(
        Rect.fromCenter(
          center: size.center(
            Offset(
              0,
              size.shortestSide * (0.2 - 0.2 * value / 2),
            ),
          ),
          width: size.shortestSide *
              _mouthWidthFraction *
              (0.5 + value / (value + 0.2)),
          height: size.shortestSide * 0.075 * value,
        ),
        0,
        -pi,
        true,
      );
  }

  Path invertedMouthPath(Size size, num value) {
    return Path()
      ..arcTo(
        Rect.fromCenter(
          center: size.center(
            Offset(
              0,
              size.shortestSide * (0.2 + 0.2 * value / 2),
            ),
          ),
          width: size.shortestSide *
              _mouthWidthFraction *
              (0.3 + (value / (value + 0.2)).clamp(0.2, double.infinity)),
          height: size.shortestSide * 0.075 * value,
        ),
        0,
        pi,
        true,
      )
      ..arcTo(
        Rect.fromCenter(
          center: size.center(
            Offset(
              0,
              size.shortestSide * (0.2 + 0.2 * value / 2),
            ),
          ),
          width: size.shortestSide *
              _mouthWidthFraction *
              (0.3 + (value / (value + 0.2)).clamp(0.2, double.infinity)),
          height: size.shortestSide * 0.35 * value,
        ),
        0,
        -pi,
        true,
      );
  }

  Path topEyelid(Size size, Offset offset) {
    final eyeLid = Path()
      ..addArc(
        Rect.fromCenter(
          center: size.center(offset).translate(
                0,
                value > 0.7
                    ? ((0.175 + 0.225 * (0.7 - value) / 0.7) *
                        size.shortestSide)
                    : 0,
              ),
          width: value > 0.7 ? size.shortestSide * 0.3 : 0,
          height: value > 0.7 ? (value - 0.7) * size.shortestSide : 0,
        ),
        0,
        -pi,
      )
      ..arcToPoint(
        size
            .center(offset)
            .translate(-0.15 * size.shortestSide, 0.15 * size.shortestSide),
      )
      ..arcToPoint(
        size
            .center(offset)
            .translate(0.15 * size.shortestSide, 0.15 * size.shortestSide),
      );
    return value > 0.7 ? eyeLid : Path();
  }

  Path bottomEyelid(Size size, Offset offset) {
    final eyeLid = Path()
      ..addArc(
        Rect.fromCenter(
          center: size.center(offset).translate(
                0,
                value < 0.3
                    ? (-(0.175 + 0.1 * (value - 0.3) / 0.3) * size.shortestSide)
                    : 0,
              ),
          width: value < 0.3 ? size.shortestSide * 0.3 : 0,
          height: value < 0.3 ? (0.3 - value) * size.shortestSide : 0,
        ),
        0,
        pi,
      )
      ..arcToPoint(
        size
            .center(offset)
            .translate(-0.15 * size.shortestSide, -0.15 * size.shortestSide),
      )
      ..arcToPoint(
        size
            .center(offset)
            .translate(0.15 * size.shortestSide, -0.15 * size.shortestSide),
      );
    return value < 0.3 ? eyeLid : Path();
  }

  @override
  bool shouldRepaint(EmojiPainter oldDelegate) => value != oldDelegate.value;

  @override
  bool shouldRebuildSemantics(EmojiPainter oldDelegate) => false;
}
