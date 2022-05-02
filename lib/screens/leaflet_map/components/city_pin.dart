import 'dart:ui';

import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/widgets/stat_popup.dart';

class CityPin extends StatefulWidget {
  final City city;
  final int? numberOfCities;
  final double size;
  final TextStyle? textStyle;
  const CityPin({
    Key? key,
    required this.city,
    this.numberOfCities,
    this.size = 40,
    this.textStyle,
  }) : super(key: key);

  @override
  State<CityPin> createState() => _CityPinState();
}

class _CityPinState extends State<CityPin> {
  bool hovering = false;

  showStatPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: StatPopup(
            city: widget.city,
            numberOfCities: widget.numberOfCities,
          ),
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
            margin: const EdgeInsets.all(0),
            elevation: 4,
            color: pinColor,
            child: GestureDetector(
              onTap: showStatPopup,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
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
            onTap: showStatPopup,
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
