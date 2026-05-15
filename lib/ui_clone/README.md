# WeddingZon UI Clone

## Overview

This directory contains a pixel-perfect UI clone of the WeddingZon mobile application, extracted from Figma designs and converted into Flutter code. The UI clone is a **pure presentation layer** with no business logic, state management, or backend integration.

## Purpose

The UI clone serves multiple purposes:

1. **Visual Reference**: Compare existing screens with the Figma design to identify discrepancies
2. **Component Library**: Reusable UI components that can be adopted into the main application
3. **Design System**: Centralized design tokens (colors, typography, spacing) for consistency
4. **Development Accelerator**: Pre-built screens that can be integrated to speed up development
5. **Design Handoff**: Bridge between design and development teams

## What's Included

### 📱 Screens (40+ mobile screens)
- **Authentication**: Splash, Login Choice, Mobile Login, Google Login, OTP Verification
- **Onboarding**: Role Selection, Profile Forms (Basic, Location, Education, Family, etc.)
- **Main Features**: Feed, Explore, Connections, Chat, Profile
- **Vendor**: Browse, Detail, Listing Forms (Basic, Working, Bank, Social)
- **Franchise**: Dashboard, Listing Forms
- **Settings**: Profile Settings, Photo Manager, Membership Plans

### 🎨 Design System
- **Colors**: Primary, secondary, neutral, and semantic color palette
- **Typography**: Text styles for headings, body text, captions, and buttons
- **Spacing**: Consistent spacing values (4, 8, 16, 24, 32, 48, 64)
- **Theme**: Complete ThemeData configuration

### 🧩 Reusable Components
- **Buttons**: Primary, Secondary, Text, Icon, Chip, Filter buttons
- **Inputs**: Text fields, Password fields, Dropdowns, Date pickers
- **Cards**: Profile cards, Vendor cards, Connection cards
- **Navigation**: Bottom navigation, App bars, Tab bars

### 🎭 Assets
- **Icons**: 30+ SVG icons for common UI elements
- **Illustrations**: Placeholder structure for illustrations
- **Images**: Placeholder structure for photos and backgrounds

## Directory Structure

```
lib/ui_clone/
├── screens/              # Complete screen widgets
│   ├── splash_screen_ui.dart
│   ├── login_choice_screen_ui.dart
│   ├── feed_screen_ui.dart
│   └── ... (40+ screens)
├── widgets/              # Reusable components
│   ├── wz_buttons.dart
│   ├── wz_inputs.dart
│   ├── wz_cards.dart
│   └── wz_navigation.dart
├── navigation/           # UI clone navigation system
│   ├── ui_clone_home.dart
│   └── ui_clone_routes.dart
├── COMPONENTS.md         # Component usage guide
├── HOW_TO_VIEW.md        # Viewing instructions
├── INTEGRATION_*.md      # Integration strategies
└── README.md             # This file

lib/core/theme/
├── wz_colors.dart        # Color constants
├── wz_text_styles.dart   # Typography constants
├── wz_spacing.dart       # Spacing constants
└── wz_theme.dart         # ThemeData configuration

assets/ui_clone/
├── icons/                # SVG icons
├── illustrations/        # SVG illustrations
└── images/               # Raster images
    ├── backgrounds/
    ├── logos/
    └── profile_photos/
```

See [FOLDER_STRUCTURE.md](./FOLDER_STRUCTURE.md) for detailed organization.

## Quick Start

### Viewing the UI Clone

1. **Run the application** in debug mode
2. **Look for the debug button** (usually a floating action button with a palette icon)
3. **Tap the button** to open the UI Clone Home screen
4. **Browse and navigate** to any extracted screen

See [HOW_TO_VIEW.md](./HOW_TO_VIEW.md) for detailed instructions.

### Using Components

```dart
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';

// Use a primary button
WzPrimaryButton(
  text: 'Continue',
  onPressed: () {
    // Your action
  },
)

// Use a secondary button
WzSecondaryButton(
  text: 'Skip',
  onPressed: () {
    // Your action
  },
)
```

See [COMPONENTS.md](./COMPONENTS.md) for complete component documentation.

### Using the Design System

```dart
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';

// Use design tokens
Container(
  padding: EdgeInsets.all(WzSpacing.space16),
  decoration: BoxDecoration(
    color: WzColors.primary,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Welcome',
    style: WzTextStyles.heading2,
  ),
)
```

See [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md) for complete design system documentation.

## Integration Strategies

The UI clone can be integrated into the existing application using three strategies:

### 1. Reference Strategy
Use the UI clone as a visual reference while building screens in the main app.
- **Pros**: No code changes to existing app, safe
- **Cons**: Manual comparison required
- **Best for**: Quality assurance, design verification

### 2. Replace Strategy
Replace entire existing screens with UI clone screens.
- **Pros**: Fast, pixel-perfect UI
- **Cons**: Requires adding business logic
- **Best for**: New features, complete redesigns

### 3. Gradual Adoption Strategy
Incrementally adopt components and design tokens.
- **Pros**: Low risk, incremental improvement
- **Cons**: Takes longer
- **Best for**: Existing features, ongoing development

See integration guides:
- [INTEGRATION_REFERENCE.md](./INTEGRATION_REFERENCE.md)
- [INTEGRATION_REPLACE.md](./INTEGRATION_REPLACE.md)
- [INTEGRATION_GRADUAL.md](./INTEGRATION_GRADUAL.md)
- [INTEGRATION_TROUBLESHOOTING.md](./INTEGRATION_TROUBLESHOOTING.md)

## Key Principles

### ✅ What the UI Clone IS

- **Pure UI**: Only visual presentation code
- **Pixel-perfect**: Matches Figma designs exactly
- **Isolated**: Completely separate from main app
- **Reusable**: Components can be used anywhere
- **Documented**: Comprehensive usage examples

### ❌ What the UI Clone IS NOT

- **Not functional**: No business logic or state management
- **Not connected**: No API calls or backend integration
- **Not navigable**: No real navigation (except within UI clone demo)
- **Not production-ready**: Requires integration work

## File Naming Convention

All UI clone files follow a consistent naming pattern:

- **Screens**: `*_screen_ui.dart` (e.g., `login_screen_ui.dart`)
- **Components**: `wz_*.dart` (e.g., `wz_buttons.dart`)
- **Theme**: `wz_*.dart` (e.g., `wz_colors.dart`)

The `_ui` suffix distinguishes UI clone screens from existing app screens.

## Testing

The UI clone includes comprehensive tests:

- **Unit Tests**: Component behavior and rendering
- **Property-Based Tests**: Universal correctness properties
- **Asset Tests**: Asset loading and path validity
- **Visual Tests**: Widget tree structure and visual accuracy

Run tests:
```bash
flutter test test/ui_clone/
```

## Extraction Methodology

The UI clone was extracted using the following process:

1. **Design System Extraction**: Extract colors, typography, and spacing from Figma variables
2. **Screen Discovery**: Identify all mobile screens in the Figma file
3. **Component Extraction**: Identify and extract reusable UI patterns
4. **Screen Generation**: Generate Flutter widgets for each screen
5. **Asset Extraction**: Export SVG icons and image placeholders
6. **Documentation**: Create usage guides and integration strategies

See the [Figma UI Extraction Spec](.kiro/specs/figma-ui-extraction/) for complete details.

## Maintenance

### Updating from Figma

When designs change in Figma:

1. Identify the changed screen or component
2. Get the Figma node ID from the screen inventory
3. Re-run the extraction process for that node
4. Replace the generated file
5. Run tests to verify no regressions

### Adding New Screens

To add a new screen:

1. Identify the screen in Figma and get its node ID
2. Use Figma MCP tools to extract design context
3. Generate the Flutter widget code
4. Save to `lib/ui_clone/screens/`
5. Add route to `ui_clone_routes.dart`
6. Add entry to UI Clone Home screen

### Modifying Components

To modify a component:

1. Update the component file in `lib/ui_clone/widgets/`
2. Update usage examples in `COMPONENTS.md`
3. Run tests to verify no breaking changes
4. Update any screens using the component

## Troubleshooting

### Common Issues

**Issue**: Colors don't match Figma
- **Solution**: Check `wz_colors.dart` for correct hex values

**Issue**: Spacing looks off
- **Solution**: Verify `wz_spacing.dart` values match design system

**Issue**: Assets not loading
- **Solution**: Check `pubspec.yaml` has correct asset paths

**Issue**: Screen doesn't compile
- **Solution**: Check for missing imports or incorrect widget usage

See [INTEGRATION_TROUBLESHOOTING.md](./INTEGRATION_TROUBLESHOOTING.md) for more solutions.

## Contributing

When contributing to the UI clone:

1. **Follow naming conventions**: Use `*_ui.dart` suffix for screens
2. **Use design system**: Always use `WzColors`, `WzTextStyles`, `WzSpacing`
3. **Keep it pure**: No business logic, state management, or API calls
4. **Add documentation**: Update relevant markdown files
5. **Write tests**: Add unit tests for new components
6. **Match Figma**: Ensure pixel-perfect accuracy

## Resources

- **Figma File**: [WeddingZon Mobile Designs](https://figma.com/...) (Node: 129:2318)
- **Design System**: [DESIGN_SYSTEM.md](./DESIGN_SYSTEM.md)
- **Components**: [COMPONENTS.md](./COMPONENTS.md)
- **Integration**: [INTEGRATION_*.md](./INTEGRATION_*.md)
- **Spec**: [.kiro/specs/figma-ui-extraction/](.kiro/specs/figma-ui-extraction/)

## License

This UI clone is part of the WeddingZon application and follows the same license.

---

**Questions or Issues?** Check the integration guides or refer to the Figma UI Extraction specification.
