import 'package:flutter/material.dart';

class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static const double maxContentWidth = 1200;
  static const double maxMobileContentWidth = 600;

  static const double minDeviceWidth = 320;
  static const double minCardWidth = 160;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tablet;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isVerySmall(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }
}
