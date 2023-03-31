import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedEmoji extends StatefulWidget {
  const AnimatedEmoji({super.key});

  @override
  State<AnimatedEmoji> createState() => _AnimatedEmojiState();
}

class _AnimatedEmojiState extends State<AnimatedEmoji>
    with SingleTickerProviderStateMixin {
  double value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            heightFactor: 0.9,
            widthFactor: 0.9,
            child: CustomPaint(
              painter: EmojiPainter(
                value: value,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: FractionallySizedBox(
            heightFactor: 0.1,
            widthFactor: 0.3,
            child: Slider(
              value: value,
              onChanged: (value) => setState(() => this.value = value),
              // divisions: 20,

              label: value.toStringAsFixed(2),
            ),
          ),
        ),
      ],
    );
  }
}

class EmojiPainter extends CustomPainter {
  const EmojiPainter({
    this.value = 0.5,
  });

  /// A value between 0.0 and 1.0 to determine the state of the face.
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    drawFace(canvas, size);
    drawEyes(canvas, size);
    drawMouth(canvas, size);
  }

  void drawEyes(Canvas canvas, Size size) {
    final leftEye = eyePath(
        size,
        Offset(
          -size.shortestSide * 0.2,
          -size.shortestSide * 0.1,
        ));

    final rightEye = eyePath(
        size,
        Offset(
          size.shortestSide * 0.2,
          -size.shortestSide * 0.1,
        ));
    final eyes = leftEye..addPath(rightEye, Offset.zero);

    canvas.drawPath(
      eyes,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );

    canvas.drawShadow(eyes, Colors.black, 10, true);

    canvas.drawPath(
      eyes,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5 * size.shortestSide * 0.025
        ..style = PaintingStyle.stroke,
    );
  }

  Path eyePath(Size size, Offset offset) {
    final eyePath = Path()
      ..addOval(Rect.fromCenter(
        center: size.center(offset),
        width: size.shortestSide * 0.25,
        height: size.shortestSide * 0.175,
      ));
    return eyePath;
  }

  void drawMouth(Canvas canvas, Size size) {
    final mouthValue = pow(0.5 - value, 2) * 4;

    Path mouth = value < 0.5
        ? invertedMouthPath(size, mouthValue)
        : mouthPath(size, mouthValue);

    canvas.drawPath(
      mouth,
      Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill,
    );

    canvas.drawShadow(mouth, Colors.black, 10, true);

    canvas.drawPath(
      mouth,
      Paint()
        ..color = Colors.white
        ..strokeWidth =
            2.5 * size.shortestSide * 0.025 < mouth.getBounds().height
                ? 1.5 * size.shortestSide * 0.025
                : 2.5 * size.shortestSide * 0.025
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
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
          width: size.shortestSide * 0.6 * (0.5 + value / (value + 0.2)),
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
          width: size.shortestSide * 0.6 * (0.5 + value / (value + 0.2)),
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
              0.6 *
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
              0.6 *
              (0.3 + (value / (value + 0.2)).clamp(0.2, double.infinity)),
          height: size.shortestSide * 0.35 * value,
        ),
        0,
        -pi,
        true,
      );
  }

  void drawFace(Canvas canvas, Size size) {
    final faceColor = TweenSequence(
          [
            TweenSequenceItem(
              tween: ColorTween(begin: Colors.red, end: Colors.yellow),
              weight: 1,
            ),
            TweenSequenceItem(
              tween: ColorTween(begin: Colors.yellow, end: Colors.green),
              weight: 1,
            ),
          ],
        ).transform(value) ??
        Colors.yellow;

    canvas.drawShadow(
      Path()
        ..addArc(
            Rect.fromCircle(
                center: size.center(Offset.zero),
                radius: size.shortestSide / 2),
            0,
            2 * pi),
      Colors.black,
      10,
      false,
    );

    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2,
      Paint()..color = faceColor,
    );
  }

  @override
  bool shouldRepaint(EmojiPainter oldDelegate) => value != oldDelegate.value;

  @override
  bool shouldRebuildSemantics(EmojiPainter oldDelegate) => false;
}