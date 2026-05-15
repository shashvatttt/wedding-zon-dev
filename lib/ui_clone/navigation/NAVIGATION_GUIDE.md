# UI Clone Navigation Guide

## Overview

This document describes the navigation system for the UI Clone layer, which provides isolated navigation for all 39 extracted Figma screens without interfering with the main WeddingZon application.

## Architecture

### Navigation Isolation

The UI Clone navigation system is completely isolated from the main app:

- **Separate Route Prefix**: All UI clone routes use the `/ui-clone` prefix
- **Dedicated Navigation Files**: Navigation logic is contained in `lib/ui_clone/navigation/`
- **No Main App Dependencies**: UI clone screens don't depend on main app navigation
- **Debug-Only Access**: UI clone is accessible only in debug mode via a floating action button

### File Structure

```
lib/ui_clone/navigation/
├── ui_clone_routes.dart      # Route definitions and screen metadata
├── ui_clone_home.dart         # Navigation hub/gallery screen
└── NAVIGATION_GUIDE.md        # This file
```

## Components

### 1. UiCloneRoutes (`ui_clone_routes.dart`)

Central route management class that defines all 39 screen routes.

#### Key Features:

- **Route Constants**: Named constants for all routes (e.g., `UiCloneRoutes.splash`)
- **Screen Metadata**: `ScreenInfo` model with title, route, category, and description
- **Route Map**: `getRoutes()` method returns a map of route names to widget builders
- **Screen List**: `allScreens` provides a complete list of all screens with metadata

#### Screen Categories:

| Category | Count | Description |
|----------|-------|-------------|
| Authentication | 7 | Login, signup, OTP, role selection screens |
| Profile Creation | 12 | Multi-step profile creation forms |
| Main Features | 9 | Feed, explore, chat, profile, settings |
| Vendor/Franchise | 10 | Vendor/franchise listing and management |
| Components | 1 | Component demo and testing screen |
| **TOTAL** | **39** | All extracted screens |

#### Usage Example:

```dart
// Navigate to a specific screen
Navigator.of(context).pushNamed(UiCloneRoutes.splash);

// Get all screens in a category
final authScreens = UiCloneRoutes.allScreens
    .where((s) => s.category == 'Authentication')
    .toList();

// Get route map for MaterialApp
routes: {
  ...UiCloneRoutes.getRoutes(),
  UiCloneRoutes.home: (context) => const UiCloneHomeScreen(),
}
```

### 2. UiCloneHomeScreen (`ui_clone_home.dart`)

Navigation hub that provides a gallery view of all extracted screens.

#### Features:

- **Search Functionality**: Filter screens by title or description
- **Category Filtering**: Filter by Authentication, Profile Creation, Main Features, etc.
- **Screen Cards**: Visual cards with icons, descriptions, and navigation
- **Screen Count**: Displays total count (39 screens) and per-category counts
- **Responsive Design**: Adapts to different screen sizes

#### UI Components:

1. **App Bar**: Title and close button
2. **Info Banner**: Shows total screen count
3. **Search Bar**: Text input for filtering screens
4. **Category Chips**: Horizontal scrollable list of category filters
5. **Screen List**: Scrollable list of screen cards

#### Usage:

```dart
// Open UI clone home from anywhere
Navigator.of(context).pushNamed(UiCloneRoutes.home);

// Or use the debug floating action button (automatically available in debug mode)
```

### 3. Debug Access Point (`main.dart`)

A floating action button that appears only in debug mode.

#### Implementation:

```dart
class _DebugUiCloneWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    bool isDebugMode = false;
    assert(() {
      isDebugMode = true;
      return true;
    }());

    if (!isDebugMode || child == null) {
      return child ?? const SizedBox.shrink();
    }

    return Stack(
      children: [
        child!,
        Positioned(
          right: 16,
          bottom: 80,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.deepPurple,
            onPressed: () {
              Navigator.of(context).pushNamed(UiCloneRoutes.home);
            },
            tooltip: 'Open UI Clone Gallery',
            child: const Icon(Icons.palette),
          ),
        ),
      ],
    );
  }
}
```

#### Characteristics:

- **Debug-Only**: Automatically hidden in release builds
- **Non-Intrusive**: Small mini FAB positioned at bottom-right
- **Easy Access**: One tap to open UI clone gallery
- **Visual Indicator**: Palette icon clearly indicates design/UI functionality

## All 39 Screen Routes

### Authentication (7 screens)

1. `/ui-clone/splash` - Splash Screen
2. `/ui-clone/login-choice` - Login Choice Screen
3. `/ui-clone/mobile-login` - Mobile Login Screen
4. `/ui-clone/google-login` - Google Login Screen
5. `/ui-clone/otp` - OTP Verification Screen
6. `/ui-clone/role-selection` - Role Selection Screen
7. `/ui-clone/login` - Login Screen (Generic)

### Profile Creation (12 screens)

8. `/ui-clone/profile-basic-details` - Profile Basic Details
9. `/ui-clone/profile-additional-details` - Profile Additional Details
10. `/ui-clone/profile-education` - Profile Education
11. `/ui-clone/profile-religious-background` - Profile Religious Background
12. `/ui-clone/profile-lifestyle` - Profile Lifestyle
13. `/ui-clone/profile-habits` - Profile Habits
14. `/ui-clone/profile-property-assets` - Profile Property & Assets
15. `/ui-clone/profile-family` - Profile Family
16. `/ui-clone/profile-contact-details` - Profile Contact Details
17. `/ui-clone/profile-about-me` - Profile About Me
18. `/ui-clone/profile-photos-upload` - Profile Photos Upload
19. `/ui-clone/profile-location` - Profile Location

### Main Features (9 screens)

20. `/ui-clone/feed` - Feed Screen
21. `/ui-clone/explore` - Explore Screen
22. `/ui-clone/connections` - Connections Screen
23. `/ui-clone/chat-list` - Chat List Screen
24. `/ui-clone/chat-conversation` - Chat Conversation Screen
25. `/ui-clone/profile-view` - Profile View Screen
26. `/ui-clone/profile` - Profile Screen
27. `/ui-clone/settings` - Settings Screen
28. `/ui-clone/photo-manager` - Photo Manager Screen

### Vendor/Franchise (10 screens)

29. `/ui-clone/vendor-browse` - Vendor Browse Screen
30. `/ui-clone/vendor-detail` - Vendor Detail Screen
31. `/ui-clone/vendor-listing-basic-details` - Vendor Listing - Basic Details
32. `/ui-clone/vendor-listing-bank-details` - Vendor Listing - Bank Details
33. `/ui-clone/vendor-listing-social-links` - Vendor Listing - Social Links
34. `/ui-clone/vendor-listing-working-details` - Vendor Listing - Working Details
35. `/ui-clone/vendor-services-management` - Vendor Services Management
36. `/ui-clone/franchise-listing-form` - Franchise Listing Form
37. `/ui-clone/franchise-dashboard` - Franchise Dashboard
38. `/ui-clone/membership-plans` - Membership Plans Screen

### Components (1 screen)

39. `/ui-clone/components-demo` - Components Demo Screen

## Integration with Main App

### Route Registration

In `main.dart`, UI clone routes are registered alongside main app routes:

```dart
MaterialApp(
  routes: {
    ...AppRoutes.routes,              // Main app routes
    ...UiCloneRoutes.getRoutes(),     // UI clone routes
    UiCloneRoutes.home: (context) => const UiCloneHomeScreen(),
  },
  builder: (context, child) {
    return _DebugUiCloneWrapper(child: child);  // Add debug button
  },
)
```

### Navigation Isolation

UI clone routes are isolated from main app routes:

- **Different Prefix**: `/ui-clone` vs main app routes
- **No Conflicts**: Route names don't overlap with main app
- **Independent Navigation**: UI clone screens don't affect main app navigation stack
- **Debug-Only Access**: Production builds don't include debug button

## Testing

Comprehensive test suite in `test/ui_clone/navigation_test.dart`:

### Test Coverage:

1. ✅ **Route Count**: Verifies all 39 screens have routes defined
2. ✅ **Route Uniqueness**: Ensures all routes are unique
3. ✅ **Route Map Completeness**: Verifies route map contains all screens
4. ✅ **Category Organization**: Validates correct screen counts per category
5. ✅ **UI Clone Home Display**: Tests home screen renders correctly
6. ✅ **Search Functionality**: Tests search filtering works
7. ✅ **Category Filtering**: Tests category filter works
8. ✅ **Navigation Isolation**: Verifies routes don't conflict with main app

### Running Tests:

```bash
# Run all navigation tests
flutter test test/ui_clone/navigation_test.dart

# Run specific test
flutter test test/ui_clone/navigation_test.dart --name "All 39 screens"
```

## Usage Guide

### For Developers

#### Viewing UI Clone Screens:

1. Run the app in debug mode: `flutter run`
2. Look for the purple palette icon (mini FAB) at bottom-right
3. Tap the icon to open UI Clone Gallery
4. Browse, search, or filter screens by category
5. Tap any screen card to view that screen

#### Adding New Screens:

1. Create screen widget in `lib/ui_clone/screens/`
2. Add import in `ui_clone_routes.dart`
3. Add route constant (e.g., `static const String newScreen = '/ui-clone/new-screen'`)
4. Add `ScreenInfo` entry to `allScreens` list
5. Add route mapping in `getRoutes()` method
6. Update tests to reflect new screen count

#### Navigating Programmatically:

```dart
// From any screen, navigate to a UI clone screen
Navigator.of(context).pushNamed(UiCloneRoutes.splash);

// Navigate with arguments (if needed)
Navigator.of(context).pushNamed(
  UiCloneRoutes.profileView,
  arguments: {'userId': '123'},
);

// Pop back to previous screen
Navigator.of(context).pop();
```

### For Designers/QA

#### Visual Verification:

1. Open UI Clone Gallery in debug mode
2. Navigate to each screen to verify pixel-perfect implementation
3. Compare with Figma designs side-by-side
4. Report any visual discrepancies

#### Testing Flows:

1. Use UI Clone Gallery to test complete user flows
2. Navigate between related screens (e.g., login flow, profile creation flow)
3. Verify all UI elements render correctly
4. Test on different device sizes

## Best Practices

### Do's ✅

- Use route constants from `UiCloneRoutes` instead of hardcoded strings
- Keep UI clone screens pure UI without business logic
- Use the debug button for easy access during development
- Update tests when adding new screens
- Document new screens in screen inventory

### Don'ts ❌

- Don't add business logic to UI clone screens
- Don't modify main app navigation from UI clone screens
- Don't hardcode route strings
- Don't remove the `/ui-clone` prefix from routes
- Don't make UI clone accessible in production builds

## Troubleshooting

### Issue: Debug button not appearing

**Solution**: Ensure you're running in debug mode. The button is automatically hidden in release builds.

```bash
# Run in debug mode
flutter run

# NOT in release mode
flutter run --release
```

### Issue: Screen not found when navigating

**Solution**: Verify the route is registered in `getRoutes()` method and the screen widget is imported.

### Issue: Navigation conflicts with main app

**Solution**: Ensure all UI clone routes use the `/ui-clone` prefix. Check for route name collisions.

### Issue: Tests failing after adding new screen

**Solution**: Update test expectations to reflect new screen count and category distribution.

## Future Enhancements

Potential improvements for the navigation system:

1. **Deep Linking**: Support deep links to specific UI clone screens
2. **Screen Variants**: Support multiple variants per screen (empty state, loading, error)
3. **Navigation History**: Track and display recently viewed screens
4. **Favorites**: Allow marking screens as favorites for quick access
5. **Screen Comparison**: Side-by-side comparison with Figma designs
6. **Screenshot Generation**: Automated screenshot generation for documentation
7. **Accessibility Testing**: Built-in accessibility checker for each screen
8. **Performance Metrics**: Display render time and performance metrics per screen

## Related Documentation

- [Screen Inventory](../../.kiro/specs/figma-ui-extraction/screen_inventory.md) - Complete list of all screens
- [Integration Guide](../INTEGRATION_GRADUAL.md) - How to integrate UI clone into main app
- [Components Guide](../COMPONENTS.md) - Reusable UI components
- [How to View](../HOW_TO_VIEW.md) - Detailed viewing instructions

## Maintenance

### Last Updated

- **Date**: 2025-01-31
- **Version**: 1.0.0
- **Total Screens**: 39
- **Test Coverage**: 8/8 tests passing

### Change Log

- **2025-01-31**: Initial navigation system implementation
  - Created `ui_clone_routes.dart` with all 39 screen routes
  - Created `ui_clone_home.dart` with gallery view
  - Added debug access point in `main.dart`
  - Implemented comprehensive test suite
  - Fixed import errors in 4 screen files
  - All tests passing (8/8)

---

**Status**: ✅ Complete and Verified

All 39 screens have properly configured navigation routes. The system is fully tested and ready for use.
