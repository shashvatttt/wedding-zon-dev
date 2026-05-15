import 'package:flutter/material.dart';
import 'breakpoints.dart';

class LayoutHelpers {
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (Breakpoints.isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (Breakpoints.isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  static double padding(BuildContext context) {
    return value(context, mobile: 16.0, tablet: 24.0, desktop: 32.0);
  }

  static double spacing(BuildContext context, {double base = 16.0}) {
    return value(
      context,
      mobile: base,
      tablet: base * 1.2,
      desktop: base * 1.5,
    );
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool center;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    final constrainedWidth =
        maxWidth ??
        (Breakpoints.isMobile(context)
            ? double.infinity
            : Breakpoints.maxMobileContentWidth);

    return Container(
      width: double.infinity,
      padding: padding,
      alignment: center ? Alignment.center : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constrainedWidth),
        child: child,
      ),
    );
  }
}
