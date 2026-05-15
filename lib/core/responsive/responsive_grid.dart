import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.childAspectRatio = 0.75,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  @override
  Widget build(BuildContext context) {
    final columns = _getColumns(context);

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      shrinkWrap: shrinkWrap,
      physics: physics,
      children: children,
    );
  }

  int _getColumns(BuildContext context) {
    if (Breakpoints.isDesktop(context)) return desktopColumns;
    if (Breakpoints.isTablet(context)) return tabletColumns;
    return mobileColumns;
  }
}

class ResponsiveGridDelegate {
  static SliverGridDelegate adaptive(
    BuildContext context, {
    int mobileColumns = 2,
    int tabletColumns = 3,
    int desktopColumns = 4,
    double crossAxisSpacing = 16,
    double mainAxisSpacing = 16,
    double childAspectRatio = 0.75,
  }) {
    final columns = _getColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
    );
  }

  static int _getColumns(
    BuildContext context, {
    required int mobile,
    required int tablet,
    required int desktop,
  }) {
    if (Breakpoints.isDesktop(context)) return desktop;
    if (Breakpoints.isTablet(context)) return tablet;
    return mobile;
  }
}
