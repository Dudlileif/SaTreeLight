import 'package:flutter/material.dart';
import 'package:satreelight/src/features/emoji_painter/emoji_painter.dart';
import 'package:satreelight/src/features/mask_selection/mask_selection.dart';

class EmojiTestingPage extends StatefulWidget {
  const EmojiTestingPage({super.key});

  @override
  State<EmojiTestingPage> createState() => _EmojiTestingPageState();
}

class _EmojiTestingPageState extends State<EmojiTestingPage> {
  double value = 0.5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji test'),
      ),
      body: Stack(
        children: [
          Align(
            child: FractionallySizedBox(
              heightFactor: 0.9,
              widthFactor: 0.9,
              child: CustomPaint(
                painter: EmojiPainter(
                  value: value,
                  minColor: CoverageColors.colorFromKey(
                    CoverageType.saturatedOrDefective,
                    dark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  midColor: CoverageColors.colorFromKey(
                    CoverageType.notVegetated,
                    dark: Theme.of(context).brightness == Brightness.dark,
                  ),
                  maxColor: CoverageColors.colorFromKey(
                    CoverageType.vegetation,
                    dark: Theme.of(context).brightness == Brightness.dark,
                  ),
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
                label: value.toStringAsFixed(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
