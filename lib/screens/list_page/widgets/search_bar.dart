import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/constants/screen_size_breakpoints.dart';
import 'package:satreelight/providers/providers.dart';

/// A search bar for searching in the city list page.
///
/// Will search in the strings for city name,
/// state name and state abbreviation.
class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  String initSearchString = '';
  late final TextEditingController textController;

  @override
  void initState() {
    super.initState();
    initSearchString = ref.read(searchStringProvider);
    textController = TextEditingController(text: initSearchString);
  }

  @override
  Widget build(BuildContext context) {
    final searchString = ref.watch(searchStringProvider);

    final textSearch = TextField(
      onChanged: (value) => ref.read(searchStringProvider.notifier).set(value),
      controller: textController,
      maxLength: 27,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search),
            Text(
              'Search',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        counterText: '',
        constraints: const BoxConstraints(maxWidth: 300),
        suffixIcon: searchString != ''
            ? IconButton(
                onPressed: () {
                  textController.clear();
                  ref.read(searchStringProvider.notifier).clear();
                },
                icon: const Icon(Icons.close),
              )
            : null,
      ),
      textAlignVertical: TextAlignVertical.top,
    );

    return MediaQuery.of(context).size.width < slimWidthBreakpoint + 30
        ? Row(
            children: [
              IconButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (context) {
                    return SimpleDialog(
                      children: [
                        textSearch,
                      ],
                    );
                  },
                ),
                icon: const Icon(Icons.search),
              ),
              if (searchString != '')
                IconButton(
                  onPressed: () {
                    textController.clear();
                    ref.read(searchStringProvider.notifier).clear();
                  },
                  icon: const Icon(Icons.search_off),
                )
            ],
          )
        : textSearch;
  }
}
