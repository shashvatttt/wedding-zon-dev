import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static const double maxContentWidth = 1200;
  static const double maxMobileContentWidth = 600;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  static bool isVerySmallDevice(BuildContext context) {
    return MediaQuery.of(context).size.width < 360;
  }

  static bool isVeryLargeDevice(BuildContext context) {
    return MediaQuery.of(context).size.width > desktopBreakpoint;
  }

  static T getResponsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) return desktop ?? tablet ?? mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return mobile;
  }

  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double textScaleFactor(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor;
  }

  static bool hasLargeTextScale(BuildContext context) {
    return MediaQuery.of(context).textScaleFactor > 1.3;
  }

  static double getResponsiveFontSize(
    BuildContext context, {
    required double baseFontSize,
    double? mobileFontSize,
    double? tabletFontSize,
    double? desktopFontSize,
    double maxScale = 2.0,
  }) {
    final deviceBaseFontSize = getResponsiveValue(
      context,
      mobile: mobileFontSize ?? baseFontSize,
      tablet: tabletFontSize ?? baseFontSize * 1.1,
      desktop: desktopFontSize ?? baseFontSize * 1.2,
    );

    final textScale = textScaleFactor(context).clamp(1.0, maxScale);

    return deviceBaseFontSize * textScale;
  }

  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets mobile,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }

  static double getResponsiveHorizontalPadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 24.0,
      desktop: 32.0,
    );
  }

  static double getResponsiveVerticalPadding(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
  }

  static int getGridColumns(
    BuildContext context, {
    int mobile = 2,
    int tablet = 3,
    int desktop = 4,
    double minCardWidth = 160,
  }) {
    final width = screenWidth(context);
    final padding = getResponsiveHorizontalPadding(context) * 2;
    final availableWidth = width - padding;

    final calculatedColumns = (availableWidth / minCardWidth).floor();

    final defaultColumns = getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );

    return calculatedColumns.clamp(1, defaultColumns);
  }

  static double getConstrainedWidth(BuildContext context) {
    final width = screenWidth(context);
    if (isMobile(context)) {
      return width;
    } else if (isTablet(context)) {
      return width.clamp(0, maxMobileContentWidth);
    } else {
      return width.clamp(0, maxContentWidth);
    }
  }

  static double getSpacing(BuildContext context, {required double base}) {
    return getResponsiveValue(
      context,
      mobile: base,
      tablet: base * 1.2,
      desktop: base * 1.5,
    );
  }

  static double getIconSize(
    BuildContext context, {
    double mobile = 24,
    double? tablet,
    double? desktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      tablet: tablet ?? mobile * 1.2,
      desktop: desktop ?? mobile * 1.4,
    );
  }

  static double getButtonHeight(BuildContext context) {
    final baseHeight = 48.0;
    final textScale = textScaleFactor(context).clamp(1.0, 1.5);
    return baseHeight * textScale;
  }

  static double getCardAspectRatio(BuildContext context) {
    return getResponsiveValue(
      context,
      mobile: 0.75,
      tablet: 0.8,
      desktop: 0.85,
    );
  }

  static bool shouldUseCompactLayout(BuildContext context) {
    return isVerySmallDevice(context) ||
        (isLandscape(context) && isMobile(context));
  }

  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  static double getAvailableHeight(
    BuildContext context, {
    bool hasAppBar = true,
    bool hasBottomNav = false,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final padding = MediaQuery.of(context).padding;

    double usedHeight = padding.top + padding.bottom;
    if (hasAppBar) usedHeight += kToolbarHeight;
    if (hasBottomNav) usedHeight += kBottomNavigationBarHeight;

    return screenHeight - usedHeight;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets? padding;
  final bool centerOnLargeScreens;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.centerOnLargeScreens = true,
  });

  @override
  Widget build(BuildContext context) {
    final constrainedWidth =
        maxWidth ?? ResponsiveUtils.getConstrainedWidth(context);
    final screenWidth = ResponsiveUtils.screenWidth(context);

    final shouldCenter = centerOnLargeScreens && screenWidth > constrainedWidth;

    return Container(
      width: double.infinity,
      padding: padding,
      alignment: shouldCenter ? Alignment.center : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constrainedWidth),
        child: child,
      ),
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double maxScale;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.baseFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.maxScale = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      baseFontSize: baseFontSize,
      maxScale: maxScale,
    );

    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double minCardWidth;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 2,
    this.tabletColumns = 3,
    this.desktopColumns = 4,
    this.minCardWidth = 160,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.childAspectRatio = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveUtils.getGridColumns(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
      minCardWidth: minCardWidth,
    );

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}
