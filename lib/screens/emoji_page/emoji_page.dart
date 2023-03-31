import 'package:flutter/material.dart';
import 'package:satreelight/screens/emoji_page/animated_emoji.dart';

class EmojiPage extends StatelessWidget {
  const EmojiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emoji test'),
      ),
      body: const AnimatedEmoji(),
    );
  }
}
