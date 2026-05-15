# Responsive System - Quick Reference

## Import
```dart
import 'package:weddingzon/core/responsive/responsive.dart';
```

## Common Patterns

### Check Device Type
```dart
if (Breakpoints.isMobile(context)) { ... }
if (Breakpoints.isTablet(context)) { ... }
if (Breakpoints.isDesktop(context)) { ... }
if (Breakpoints.isVerySmall(context)) { ... }
```

### Get Responsive Value
```dart
final padding = LayoutHelpers.value(
  context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);
```

### Constrain Width on Large Screens
```dart
ResponsiveContainer(
  child: YourContent(),
)
```

### Adaptive Grid
```dart
ResponsiveGrid(
  mobileColumns: 2,
  tabletColumns: 3,
  desktopColumns: 4,
  children: items.map((item) => ItemCard(item)).toList(),
)
```

### For SliverGrid
```dart
SliverGrid(
  gridDelegate: ResponsiveGridDelegate.adaptive(
    context,
    mobileColumns: 2,
    tabletColumns: 3,
  ),
  delegate: SliverChildBuilderDelegate(...),
)
```

### Responsive Padding
```dart
Padding(
  padding: EdgeInsets.all(LayoutHelpers.padding(context)),
  child: ...,
)
```

### Responsive Spacing
```dart
SizedBox(height: LayoutHelpers.spacing(context, base: 16))
```

## Text Styles (Use Theme!)
```dart
// ✅ DO THIS
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineMedium,
)

// ❌ NOT THIS
Text(
  'Title',
  style: TextStyle(fontSize: 24),
)
```

## Layout Builder for Complex Cases
```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return WideLayout();
    }
    return NarrowLayout();
  },
)
```

## Breakpoint Values
- Mobile: < 600px
- Tablet: 600px - 900px
- Desktop: > 900px
- Very Small: < 360px

## Max Content Width
- Mobile: Full width
- Tablet+: 600px (constrained for readability)
