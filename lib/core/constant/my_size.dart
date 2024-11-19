import 'package:flutter/material.dart';

class MySize {
  static double deviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double deviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static const double appBarHeight = 75.0;

  static const double quarterPadding = 4.0;
  static const double halfPadding = 8.0;
  static const double threeQuartersPadding = 12.0;
  static const double defaultPadding = 16.0;
  static const double sixQuartersPadding = 24.0;
  static const double doublePadding = 32.0;
  static const double tenQuartersPadding = 40.0;

  static const double quarterRadius = 8.0;
  static const double halfRadius = 16.0;
  static const double defaultRadius = 32.0;
  static const double doubleRadius = 64.0;

  static const double iconSizeTiny = 20.0;
  static const double iconSizeSmall = 32.0;
  static const double iconSizeMedium = 48.0;
  static const double iconSizeBig = 64.0;

  static const double gridSize = 54.0;
  static const double cardHeight = 150.0;
  static const double cardWidth = 275.0;

  static const double welcomeImageSize = 240.0;
  static const double natalChartSize = 230.0;
}
