import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/src/features/sorting/sorting.dart';

/// An [IconButton] for selecting the sorting order.
///
/// The button will show the current order, and
/// show the other while hovered over.
class FlipSortingOrderButton extends ConsumerStatefulWidget {
  const FlipSortingOrderButton({
    super.key,
    this.ascendingIcon = Icons.arrow_upward,
    this.descendingIcon = Icons.arrow_downward,
  });

  final IconData ascendingIcon;
  final IconData descendingIcon;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FlipSortingOrderButtonState();
}

class _FlipSortingOrderButtonState extends ConsumerState<FlipSortingOrderButton>
    with SingleTickerProviderStateMixin {
  bool isHovered = false;

  // By setting the hover icon after hover entry
  // the icon won't instantly flip back when clicking.
  late IconData hoverIcon = widget.ascendingIcon;

  @override
  Widget build(BuildContext context) {
    final reverseOrder = ref.watch(reverseSortingProvider);
    final sortingIcon =
        reverseOrder ? widget.descendingIcon : widget.ascendingIcon;

    return MouseRegion(
      onEnter: (event) => setState(() {
        isHovered = true;
        hoverIcon = reverseOrder ? widget.ascendingIcon : widget.descendingIcon;
      }),
      onExit: (event) => setState(
        () => isHovered = false,
      ),
      child: IconButton(
        tooltip: reverseOrder ? 'Sort Ascending' : 'Sort Descending',
        onPressed: ref.read(reverseSortingProvider.notifier).reverse,
        icon: Icon(
          isHovered ? hoverIcon : sortingIcon,
        ),
      ),
    );
  }
}
