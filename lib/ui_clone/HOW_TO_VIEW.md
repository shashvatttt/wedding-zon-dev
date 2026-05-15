# How to View UI Clone Components

## Quick Access Methods

### Method 1: Navigate to Demo Screen (Easiest)

The demo screen showcases all UI clone components in one place.

**From anywhere in your app:**

```dart
Navigator.pushNamed(context, '/ui-clone/demo');
```

**Or using the route constant:**

```dart
import 'package:weddingzon/core/routes/app_routes.dart';

Navigator.pushNamed(context, AppRoutes.uiCloneDemo);
```

### Method 2: Change Initial Route (For Testing)

Temporarily change the initial route in `lib/main.dart`:

```dart
MaterialApp(
  // ... other properties
  initialRoute: AppRoutes.uiCloneDemo,  // Change this line
  routes: AppRoutes.routes,
)
```

### Method 3: Add Debug Button (Recommended for Development)

Add a floating action button to any screen:

```dart
Scaffold(
  // ... your existing code
  floatingActionButton: FloatingActionButton(
    onPressed: () {
      Navigator.pushNamed(context, AppRoutes.uiCloneDemo);
    },
    child: const Icon(Icons.palette),
    tooltip: 'View UI Components',
  ),
)
```

### Method 4: Use Individual Components

Import and use components directly in your screens:

```dart
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/ui_clone/widgets/wz_inputs.dart';
import 'package:weddingzon/ui_clone/widgets/wz_cards.dart';
import 'package:weddingzon/ui_clone/widgets/wz_navigation.dart';

// Then use them:
WzPrimaryButton(
  text: 'Click Me',
  onPressed: () {
    // Handle press
  },
)
```

## Available Components

### Buttons
- `WzPrimaryButton` - Filled button with primary color
- `WzSecondaryButton` - Outlined button
- `WzTextButton` - Text-only button
- `WzIconButton` - Circular icon button

### Input Fields
- `WzTextField` - Standard text input
- `WzPasswordField` - Password input with visibility toggle
- `WzDropdown` - Dropdown selection
- `WzDatePicker` - Date picker field
- `WzSearchBar` - Search input with clear button

### Cards
- `WzProfileCard` - Large profile card with photo carousel
- `WzUserCard` - Medium user card for lists
- `WzNotificationCard` - Notification item
- `WzRequestCard` - Connection/access request card
- `WzConversationTile` - Chat conversation item

### Navigation
- `WzAppBar` - Standard app bar
- `WzStatusBar` - iOS-style status bar
- `WzBottomNav` - Bottom navigation bar
- `WzTabBar` - Horizontal tab bar
- `WzDrawer` - Side drawer menu

## Design System

All components use the centralized design system:

```dart
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/core/theme/wz_theme.dart';

// Use design tokens:
Container(
  color: WzColors.primary,
  padding: EdgeInsets.all(WzSpacing.space16),
  child: Text('Hello', style: WzTextStyles.heading1),
)
```

## Running the App

1. Make sure you're in the project directory
2. Run: `flutter run`
3. Navigate to the demo screen using any method above

## Troubleshooting

**Issue: Route not found**
- Make sure you've saved all files
- Try hot restart (press 'R' in terminal or click restart button)

**Issue: Components not displaying correctly**
- Check that you've imported the correct widget
- Verify you're using the design system colors/styles

**Issue: Can't find the demo screen**
- The route is: `/ui-clone/demo`
- Or use: `AppRoutes.uiCloneDemo`

## Next Steps

Once you've viewed the components:
1. Use them in your existing screens
2. Customize them by passing different parameters
3. Extract more screens from Figma (see tasks.md)
4. Build your UI using these reusable components

For more details, see:
- `lib/ui_clone/COMPONENTS.md` - Component documentation
- `.kiro/specs/figma-ui-extraction/tasks.md` - Implementation tasks
- `.kiro/specs/figma-ui-extraction/design.md` - Design documentation
