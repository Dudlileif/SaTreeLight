import 'package:flutter/material.dart';

class CityPinCluster extends StatefulWidget {
  final int count;
  const CityPinCluster({Key? key, required this.count}) : super(key: key);

  @override
  State<CityPinCluster> createState() => _CityPinClusterState();
}

class _CityPinClusterState extends State<CityPinCluster> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    final pinColor = hovering
        ? Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).primaryColorDark
            : Theme.of(context).primaryColorLight
        : Theme.of(context).primaryColor;

    return MouseRegion(
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
        child: Text(
          widget.count.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).primaryTextTheme.headline6,
        ),
      ),
    );
  }
}
