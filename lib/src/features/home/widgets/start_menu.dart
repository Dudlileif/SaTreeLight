import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/city/city.dart';
import 'package:satreelight/src/features/credits/credits.dart';
import 'package:satreelight/src/features/emoji_painter/emoji_painter.dart';
import 'package:satreelight/src/features/map/map.dart';
import 'package:satreelight/src/features/sorting/screens/list_page.dart';
import 'package:satreelight/src/features/tutorial/screens/tutorial_page.dart';

/// The start menu of the app.
class StartMenu extends ConsumerWidget {
  const StartMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logo = Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/graphics/satreelight_logo_sat.png',
          height: 300,
          color: Theme.of(context).brightness == Brightness.light
              ? Theme.of(context).primaryColorLight
              : Theme.of(context).primaryColorDark,
        ),
        Image.asset(
          'assets/graphics/satreelight_logo_veg.png',
          height: 300,
          color: Theme.of(context).primaryColor,
        ),
      ],
    );

    final textShadowColor = Theme.of(context).brightness == Brightness.light
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColorDark;

    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 50),
        ),
        logo,
        Text(
          'SaTreeLight',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                shadows: List.generate(4, (index) {
                  const offsets = [
                    Offset(1, 0),
                    Offset(-1, 0),
                    Offset(0, 1),
                    Offset(0, -1)
                  ];
                  return Shadow(
                    color: textShadowColor,
                    blurRadius: 0.5,
                    offset: offsets[index],
                  );
                }),
              ),
        ),
        Align(
          heightFactor: 1.1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 250, maxHeight: 400),
            child: ListView(
              shrinkWrap: true,
              children: [
                Card(
                  elevation: 8,
                  child: Tooltip(
                    message: 'Open and explore the map',
                    waitDuration: const Duration(milliseconds: 250),
                    child: ListTile(
                      title: const Text('Start'),
                      leading: const Icon(Icons.map),
                      onTap: () {
                        ref
                            .read(mapInBackgroundProvider.notifier)
                            .update(newState: false);
                        ref
                            .read(zoomStreamControllerProvider.notifier)
                            .zoomIn();
                      },
                    ),
                  ),
                ),
                Card(
                  elevation: 8,
                  child: Tooltip(
                    message: 'How to use the app',
                    waitDuration: const Duration(milliseconds: 250),
                    child: ListTile(
                      title: const Text('How it works'),
                      leading: const Icon(Icons.help),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const TutorialPage(),
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 8,
                  child: Tooltip(
                    message: 'Browse a sortable list of cities',
                    waitDuration: const Duration(milliseconds: 250),
                    child: ListTile(
                      title: const Text('Cities'),
                      leading: const Icon(Icons.list_alt),
                      onTap: () {
                        ref
                            .read(showNextPrevArrowsProvider.notifier)
                            .update(newState: true);
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) => const ListPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Card(
                  elevation: 8,
                  child: Tooltip(
                    message: 'View the honourable contributors',
                    waitDuration: const Duration(milliseconds: 250),
                    child: ListTile(
                      title: const Text('Credits'),
                      leading: const Icon(Icons.people),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (context) => const CreditsPage(),
                        ),
                      ),
                    ),
                  ),
                ),
                Card(
                  elevation: 8,
                  child: ListTile(
                    title: const Text('Emoji test'),
                    leading: const Icon(Icons.emoji_emotions),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => const EmojiTestingPage(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
      ],
    );
  }
}
