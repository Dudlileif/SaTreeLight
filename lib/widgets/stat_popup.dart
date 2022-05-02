import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:satreelight/constants/size_breakpoints.dart';
import 'package:satreelight/models/city.dart';
import 'package:satreelight/widgets/components/city_map.dart';
import 'package:satreelight/widgets/components/happiness_indicator.dart';
import 'package:satreelight/widgets/components/happiness_ranks.dart';
import 'package:satreelight/widgets/components/vegetation_gauge.dart';

class StatPopup extends StatefulWidget {
  final List<City> cities;
  final City city;
  final int? numberOfCities;

  const StatPopup({
    required this.city,
    this.cities = const [],
    this.numberOfCities,
    Key? key,
  }) : super(key: key);

  @override
  State<StatPopup> createState() => _StatPopupState();
}

class _StatPopupState extends State<StatPopup> {
  bool mapHover = false;
  late City city;
  late int cityIndex;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    city = widget.city;
    cityIndex = widget.cities.indexOf(city);
  }

  @override
  Widget build(BuildContext context) {
    Color cardColor = Theme.of(context).dividerColor;
    var screenSize = MediaQuery.of(context).size;

    final loadingDialog = Dialog(
      insetPadding: EdgeInsets.symmetric(
        vertical: screenSize.width < mediumWidthBreakpoint
            ? screenSize.height * 0.03
            : screenSize.height * 0.1,
        horizontal: screenSize.width * 0.1,
      ),
      child: const Center(
        child: CircularProgressIndicator.adaptive(),
      ),
    );

    return FutureBuilder<City>(
      future: city.loadWithData(),
      initialData: city,
      builder: (BuildContext context, AsyncSnapshot<City> snapshot) {
        city = snapshot.data ?? city;

        if (!city.loaded) {
          return loadingDialog;
        } else {
          return FutureBuilder<OverlayImage>(
            future: city.getImage(),
            initialData: null,
            builder: (BuildContext context, AsyncSnapshot imageSnapshot) {
              if (imageSnapshot.data == null) {
                return loadingDialog;
              } else {
                final dataWidgets = <Widget>[
                  Card(
                    elevation: 4,
                    child: Container(
                      color: cardColor,
                      height: screenSize.height * 0.2,
                      width: screenSize.width < slimWidthBreakpoint
                          ? screenSize.width * 0.8
                          : screenSize.width * 0.15,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: VegetationGauge(
                          city: city,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: Container(
                      color: cardColor,
                      height: screenSize.height * 0.2,
                      width: screenSize.width < slimWidthBreakpoint
                          ? screenSize.width * 0.8
                          : screenSize.width < mediumWidthBreakpoint
                              ? screenSize.width * 0.25
                              : screenSize.width * 0.15,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: HappinessRanks(
                          city: city,
                          numberOfCities: widget.cities.isNotEmpty
                              ? widget.cities.length
                              : widget.numberOfCities,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 4,
                    child: Container(
                      color: cardColor,
                      height: screenSize.height * 0.2,
                      width: screenSize.width < slimWidthBreakpoint
                          ? screenSize.width * 0.8
                          : screenSize.width < mediumWidthBreakpoint
                              ? screenSize.width * 0.25
                              : screenSize.width * 0.15,
                      child: HappinessIndicator(city: city),
                    ),
                  ),
                ];

                final cityMap = CityMap(
                  city: city,
                  overlayImage: imageSnapshot.data,
                );

                final widgets = [
                  Card(
                    elevation: 4,
                    child: Container(
                      height: screenSize.height * 0.6 + 16,
                      width: screenSize.width < slimWidthBreakpoint
                          ? screenSize.width * 0.8
                          : screenSize.width < mediumWidthBreakpoint
                              ? screenSize.width * 0.7
                              : screenSize.width * 0.52,
                      color: cardColor,
                      child: MouseRegion(
                        onEnter: (event) {
                          if (!mapHover &&
                              screenSize.width < mediumWidthBreakpoint) {
                            setState(() {
                              mapHover = true;
                            });
                          }
                        },
                        onExit: (event) {
                          if (mapHover &&
                              screenSize.width < mediumWidthBreakpoint) {
                            setState(() {
                              mapHover = false;
                            });
                          }
                        },
                        child: cityMap,
                      ),
                    ),
                  ),
                  if (screenSize.width < slimWidthBreakpoint)
                    ...dataWidgets
                  else if (screenSize.width < mediumWidthBreakpoint)
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: screenSize.width * 0.7 + 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(
                          dataWidgets.length,
                          (index) => index == 1
                              ? Expanded(child: dataWidgets[index])
                              : dataWidgets[index],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: dataWidgets,
                    ),
                ];

                final layout = screenSize.width < mediumWidthBreakpoint
                    ? Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ListView(
                            children: widgets,
                            physics: mapHover
                                ? const NeverScrollableScrollPhysics()
                                : null,
                          ),
                        ),
                      )
                    : Row(
                        children: List.generate(
                          widgets.length,
                          (index) => index == 0
                              ? Expanded(child: widgets[index])
                              : widgets[index],
                        ),
                      );

                return Dialog(
                  insetPadding: EdgeInsets.symmetric(
                    vertical: screenSize.width < mediumWidthBreakpoint
                        ? screenSize.height * 0.03
                        : screenSize.height * 0.1,
                    horizontal: screenSize.width * 0.1,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: RichText(
                                text: TextSpan(
                                  text: city.name + '\n',
                                  style: Theme.of(context).textTheme.headline4,
                                  children: [
                                    TextSpan(
                                      text: city.stateLong,
                                      style:
                                          Theme.of(context).textTheme.headline5,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                if (cityIndex > 0 && widget.cities.isNotEmpty)
                                  IconButton(
                                    onPressed: () {
                                      if (!loading) {
                                        loading = true;
                                        cityIndex--;
                                        city = widget.cities[cityIndex];

                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 3, sigmaY: 3),
                                              child: StatPopup(
                                                city: city,
                                                cities: widget.cities,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.keyboard_arrow_left),
                                  ),
                                if (cityIndex < widget.cities.length - 1 &&
                                    widget.cities.isNotEmpty)
                                  IconButton(
                                    onPressed: () {
                                      if (!loading) {
                                        loading = true;
                                        cityIndex++;
                                        city = widget.cities[cityIndex];
                                        Navigator.of(context).pop();
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 3, sigmaY: 3),
                                              child: StatPopup(
                                                city: city,
                                                cities: widget.cities,
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    icon:
                                        const Icon(Icons.keyboard_arrow_right),
                                  ),
                                const SizedBox(
                                  width: 16,
                                ),
                                const CloseButton()
                              ],
                            ),
                          ],
                        ),
                        layout,
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }
}
