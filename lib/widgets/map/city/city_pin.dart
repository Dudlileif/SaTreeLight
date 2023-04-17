import 'dart:ui';

import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/providers/providers.dart';
import 'package:satreelight/widgets/city_dialog/city_dialog.dart';

/// A widget width the city name pinned to the city location.
class CityPin extends ConsumerStatefulWidget {
  const CityPin({
    required this.city,
    this.numberOfCities,
    this.size = 40,
    this.textStyle,
    super.key,
  });

  /// The city this pin attaches to.
  final City city;

  /// The total number of cities.
  final int? numberOfCities;

  /// The size of the widget.
  final double size;

  /// The text style of the city name.
  final TextStyle? textStyle;

  @override
  ConsumerState<CityPin> createState() => _CityPinState();
}

class _CityPinState extends ConsumerState<CityPin> {
  bool hovering = false;

  void showCityDialog() {
    ref.read(selectedCityProvider.notifier).set(widget.city);
    showDialog<void>(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: const CityDialog(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinColor = hovering
        ? Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).primaryColorDark
            : Theme.of(context).primaryColorLight
        : Theme.of(context).primaryColor;

    return Column(
      children: [
        MouseRegion(
          onEnter: (event) => setState(() {
            hovering = true;
          }),
          onExit: (event) => setState(() {
            hovering = false;
          }),
          cursor: SystemMouseCursors.click,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 4,
            color: pinColor,
            child: GestureDetector(
              onTap: showCityDialog,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  widget.city.name,
                  textAlign: TextAlign.center,
                  style: widget.textStyle ??
                      Theme.of(context).primaryTextTheme.bodySmall,
                ),
              ),
            ),
          ),
        ),
        MouseRegion(
          onEnter: (event) => setState(() {
            hovering = true;
          }),
          onExit: (event) => setState(() {
            hovering = false;
          }),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: showCityDialog,
            child: DecoratedIcon(
              Icons.pin_drop,
              color: pinColor,
              size: widget.size,
              shadows: [
                Shadow(
                  offset: const Offset(1, 1),
                  blurRadius:
                      Theme.of(context).brightness == Brightness.dark ? 2 : 1,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
