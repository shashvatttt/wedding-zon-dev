# Responsive Migration Guide

**SIMPLIFIED APPROACH** - Focus on practical, production-ready patterns.

This guide shows how to migrate existing screens to be fully responsive and handle edge cases.

## New Structure

```
lib/core/responsive/
  ├─ breakpoints.dart       # Constants and device checks
  ├─ responsive_grid.dart   # Adaptive grid layouts
  ├─ layout_helpers.dart    # Simple utilities
  └─ responsive.dart        # Barrel file (import this)
```

**Import once, use everywhere:**
```dart
import 'package:weddingzon/core/responsive/responsive.dart';
```

## Core Principles

### ✅ DO:
1. Use `Theme.of(context).textTheme` for text styles (Flutter handles scaling)
2. Use `Breakpoints` for device detection
3. Use `ResponsiveContainer` to constrain width on tablets
4. Use `ResponsiveGrid` for card layouts
5. Use `LayoutBuilder` for complex parent-dependent layouts
6. Use `TextOverflow.ellipsis` for long text
7. Use `SingleChildScrollView` for forms

### ❌ DON'T:
1. Manually scale font sizes (Flutter does this automatically)
2. Use fixed widths/heights without constraints
3. Over-engineer with too many utilities
4. Fight the framework - work with it

### ✅ User Increases Display Size (200% text)
- Text scales properly with system settings
- Containers adapt to larger text
- Buttons remain usable

### ✅ Very Small Device (320px width)
- Content adapts to narrow screens
- Grid columns reduce automatically
- Fixed widths become flexible

### ✅ Very Large Device/Tablet (1024px+)
- Content width is constrained for readability
- Multi-column layouts on tablets
- Proper spacing and sizing

### ✅ Landscape Orientation
- Layouts adapt to available space
- Compact mode for small landscape screens

---

## Migration Examples

### 1. Text Styles → Use Theme (NOT manual scaling)

**❌ Before (Breaks with text scaling):**
```dart
Text(
  'Welcome to WeddingZon',
  style: TextStyle(
    fontSize: 24,  // Fixed size!
    fontWeight: FontWeight.w600,
  ),
)
```

**✅ After (Flutter handles scaling automatically):**
```dart
Text(
  'Welcome to WeddingZon',
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.w600,
  ),
)
```

**Why?** Flutter's theme system automatically respects user's text size settings.

### 2. Fixed Container Widths → Flexible Layouts

**❌ Before (Overflows on small screens):**
```dart
Container(
  width: 348,  // Fixed! Breaks on 320px screens
  height: 578,
  child: ProfileCard(),
)
```

**✅ After (Adapts to screen):**
```dart
ResponsiveContainer(
  maxWidth: 400,  // Max width for large screens
  child: Container(
    width: double.infinity,  // Flexible
    constraints: BoxConstraints(
      maxHeight: ResponsiveUtils.getResponsiveValue(
        context,
        mobile: 500,
        tablet: 600,
        desktop: 700,
      ),
    ),
    child: ProfileCard(),
  ),
)
```

### 3. Fixed Grid Columns → Adaptive Grid

**❌ Before (Too cramped on small screens, too sparse on large):**
```dart
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,  // Always 2 columns!
    childAspectRatio: 0.75,
  ),
  itemBuilder: (context, index) => VendorCard(),
)
```

**✅ After (Adapts to screen size):**
```dart
GridView.builder(
  gridDelegate: ResponsiveGridDelegate.adaptive(
    context,
    mobileColumns: 2,
    tabletColumns: 3,
    desktopColumns: 4,
  ),
  itemBuilder: (context, index) => VendorCard(),
)
```

### 4. Fixed Padding → Responsive Padding

**❌ Before (Same padding on all devices):**
```dart
Padding(
  padding: EdgeInsets.all(24),  // Fixed!
  child: Column(children: [...]),
)
```

**✅ After (Adapts to device):**
```dart
Padding(
  padding: EdgeInsets.all(LayoutHelpers.padding(context)),
  child: Column(children: [...]),
)
```

### 5. Device-Specific Layouts → Use LayoutBuilder

**❌ Before (Using MediaQuery everywhere):**
```dart
Widget build(BuildContext context) {
  if (MediaQuery.of(context).size.width > 600) {
    return TabletLayout();
  }
  return MobileLayout();
}
```

**✅ After (Better with LayoutBuilder):**
```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > Breakpoints.tablet) {
        return TabletLayout();
      }
      return MobileLayout();
    },
  );
}
```

**Why?** `LayoutBuilder` responds to parent constraints, not just screen size.

---

## Complete Screen Example

### Before: Fixed Dimensions
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),  // Fixed
        child: Column(
          children: [
            Text(
              'My Profile',
              style: TextStyle(fontSize: 24),  // Fixed
            ),
            SizedBox(height: 20),  // Fixed
            Container(
              width: 348,  // Fixed - breaks on small screens!
              height: 400,  // Fixed
              child: ProfileCard(),
            ),
          ],
        ),
      ),
    );
  }
}
```

### After: Fully Responsive
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveContainer(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getResponsiveHorizontalPadding(context),
          vertical: ResponsiveUtils.getResponsiveVerticalPadding(context),
        ),
        child: Column(
          children: [
            ResponsiveText(
              'My Profile',
              baseFontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(
              height: ResponsiveUtils.getSpacing(context, base: 20),
            ),
            Container(
              width: double.infinity,  // Flexible
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.getResponsiveValue(
                  context,
                  mobile: double.infinity,
                  tablet: 400,
                  desktop: 500,
                ),
              ),
              child: ProfileCard(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Priority Migration List

### High Priority (User-facing issues)
1. ✅ **Feed Screen** - Profile cards need responsive sizing
2. ✅ **Vendor Browse** - Grid needs to adapt to screen size
3. ✅ **Profile Forms** - Text inputs need to handle large text
4. ✅ **Chat Screen** - Message bubbles need proper constraints
5. ✅ **Login/Signup** - Forms must work on small screens

### Medium Priority
6. Settings screens
7. Notification screens
8. Connection screens

### Low Priority
9. Admin/franchise screens
10. Coming soon screens

---

## Testing Checklist

### Test on Different Devices
- [ ] Small phone (320px width) - e.g., iPhone SE
- [ ] Standard phone (375-414px) - e.g., iPhone 12
- [ ] Large phone (428px+) - e.g., iPhone 14 Pro Max
- [ ] Tablet (768px+) - e.g., iPad
- [ ] Large tablet (1024px+) - e.g., iPad Pro

### Test with Accessibility Settings
- [ ] Text size: Small (0.85x)
- [ ] Text size: Default (1.0x)
- [ ] Text size: Large (1.3x)
- [ ] Text size: Extra Large (1.5x)
- [ ] Text size: Maximum (2.0x)

### Test Orientations
- [ ] Portrait mode
- [ ] Landscape mode (especially on phones)

### Test Edge Cases
- [ ] Very long names/text
- [ ] Missing images
- [ ] Empty states
- [ ] Loading states

---

## Quick Wins

### 1. Add to Theme
```dart
// In your theme file
class WzTextStyles {
  static TextStyle heading1(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(
      context,
      baseFontSize: 32,
    ),
    fontWeight: FontWeight.bold,
  );
  
  static TextStyle body1(BuildContext context) => TextStyle(
    fontSize: ResponsiveUtils.getResponsiveFontSize(
      context,
      baseFontSize: 16,
    ),
  );
}
```

### 2. Wrap Main Content
```dart
// Wrap your main content areas
ResponsiveContainer(
  child: YourContent(),
)
```

### 3. Use Responsive Grids
```dart
// Replace fixed grids
ResponsiveGrid(
  children: items.map((item) => ItemCard(item)).toList(),
)
```

---

## Common Patterns

### Pattern 1: Responsive Card
```dart
Widget buildResponsiveCard(BuildContext context) {
  return Container(
    width: double.infinity,
    constraints: BoxConstraints(
      maxWidth: ResponsiveUtils.getResponsiveValue(
        context,
        mobile: double.infinity,
        tablet: 400,
      ),
    ),
    padding: EdgeInsets.all(
      ResponsiveUtils.getSpacing(context, base: 16),
    ),
    child: Column(
      children: [
        ResponsiveText(
          'Title',
          baseFontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        // ... more content
      ],
    ),
  );
}
```

### Pattern 2: Responsive Form Field
```dart
Widget buildResponsiveTextField(BuildContext context) {
  return Container(
    height: ResponsiveUtils.getButtonHeight(context),
    child: TextField(
      style: TextStyle(
        fontSize: ResponsiveUtils.getResponsiveFontSize(
          context,
          baseFontSize: 16,
        ),
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.getSpacing(context, base: 16),
          vertical: ResponsiveUtils.getSpacing(context, base: 12),
        ),
      ),
    ),
  );
}
```

### Pattern 3: Responsive Layout Switch
```dart
Widget buildResponsiveLayout(BuildContext context) {
  if (ResponsiveUtils.shouldUseCompactLayout(context)) {
    return CompactLayout();
  } else if (ResponsiveUtils.isTablet(context)) {
    return TabletLayout();
  } else {
    return StandardLayout();
  }
}
```

---

## Performance Tips

1. **Cache responsive values** in build method if used multiple times
2. **Use const constructors** where possible
3. **Avoid rebuilding** entire tree on orientation change
4. **Use LayoutBuilder** for complex responsive logic

---

## Need Help?

Check these files for examples:
- `lib/ui_clone/screens/vendor_browse_screen_ui.dart` - Has some responsive grid logic
- `lib/core/utils/responsive_utils.dart` - All utility functions
- This guide - Complete migration examples
