import 'package:flutter/material.dart';

class WzSpacing {
  WzSpacing._();

  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  static const double screenPadding = 24.0;
  static const double cardPadding = 16.0;
  static const double buttonPaddingVertical = 12.0;
  static const double buttonPaddingHorizontal = 24.0;
  static const double listItemSpacing = 16.0;

  static const double space150 = 6.0;
  static const double space200 = 8.0;
  static const double space400 = 16.0;

  static const double scale06 = 32.0;
}

class WzBorderRadius {
  WzBorderRadius._();

  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusRound = 999.0;

  static BorderRadius get small => BorderRadius.circular(radiusSmall);
  static BorderRadius get medium => BorderRadius.circular(radiusMedium);
  static BorderRadius get large => BorderRadius.circular(radiusLarge);
  static BorderRadius get xLarge => BorderRadius.circular(radiusXLarge);
  static BorderRadius get round => BorderRadius.circular(radiusRound);

  static const double radius200 = 8.0;
  static const double radius400 = 16.0;

  static BorderRadius get radius200Circular => BorderRadius.circular(radius200);
  static BorderRadius get radius400Circular => BorderRadius.circular(radius400);
}

class WzStroke {
  WzStroke._();

  static const double border = 1.0;
}

class WzShadows {
  WzShadows._();

  static const List<BoxShadow> shadow1 = [
    BoxShadow(color: Color(0x1F000000), offset: Offset(0, 1), blurRadius: 3),
  ];

  static const List<BoxShadow> shadow2 = [
    BoxShadow(color: Color(0x29000000), offset: Offset(0, 2), blurRadius: 6),
  ];

  static const List<BoxShadow> shadow3 = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 4), blurRadius: 12),
  ];

  static const List<BoxShadow> m3ElevationLight2 = [
    BoxShadow(
      color: Color(0x26000000),
      offset: Offset(0, 2),
      blurRadius: 6,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: Color(0x4D000000),
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: 0,
    ),
  ];
}
