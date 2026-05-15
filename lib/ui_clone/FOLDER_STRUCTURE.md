# UI Clone Folder Structure

## Overview

This document provides a detailed explanation of the UI clone folder structure, file organization, and naming conventions.

## Complete Directory Tree

```
weddingzon/
├── lib/
│   ├── ui_clone/                          # UI Clone root directory
│   │   ├── screens/                       # Screen widgets (40+ files)
│   │   │   ├── splash_screen_ui.dart
│   │   │   ├── login_choice_screen_ui.dart
│   │   │   ├── mobile_login_screen_ui.dart
│   │   │   ├── google_login_screen_ui.dart
│   │   │   ├── otp_screen_ui.dart
│   │   │   ├── role_selection_screen_ui.dart
│   │   │   ├── profile_basic_details_ui.dart
│   │   │   ├── profile_location_ui.dart
│   │   │   ├── profile_education_ui.dart
│   │   │   ├── profile_family_ui.dart
│   │   │   ├── profile_religious_background_ui.dart
│   │   │   ├── profile_lifestyle_ui.dart
│   │   │   ├── profile_habits_ui.dart
│   │   │   ├── profile_additional_details_ui.dart
│   │   │   ├── profile_property_assets_ui.dart
│   │   │   ├── profile_contact_details_ui.dart
│   │   │   ├── profile_about_me_ui.dart
│   │   │   ├── profile_photos_upload_ui.dart
│   │   │   ├── feed_screen_ui.dart
│   │   │   ├── explore_screen_ui.dart
│   │   │   ├── connections_screen_ui.dart
│   │   │   ├── chat_list_screen_ui.dart
│   │   │   ├── chat_conversation_screen_ui.dart
│   │   │   ├── profile_screen_ui.dart
│   │   │   ├── profile_view_screen_ui.dart
│   │   │   ├── settings_screen_ui.dart
│   │   │   ├── photo_manager_screen_ui.dart
│   │   │   ├── membership_plans_screen_ui.dart
│   │   │   ├── vendor_browse_screen_ui.dart
│   │   │   ├── vendor_detail_screen_ui.dart
│   │   │   ├── vendor_listing_basic_details_ui.dart
│   │   │   ├── vendor_listing_working_details_ui.dart
│   │   │   ├── vendor_listing_bank_details_ui.dart
│   │   │   ├── vendor_listing_social_links_ui.dart
│   │   │   ├── vendor_services_management_ui.dart
│   │   │   ├── franchise_dashboard_ui.dart
│   │   │   ├── franchise_listing_form_ui.dart
│   │   │   ├── login_screen_ui.dart
│   │   │   └── components_demo_screen.dart
│   │   │
│   │   ├── widgets/                       # Reusable components
│   │   │   ├── wz_buttons.dart           # Button components
│   │   │   ├── wz_inputs.dart            # Input field components
│   │   │   ├── wz_cards.dart             # Card components
│   │   │   └── wz_navigation.dart        # Navigation components
│   │   │
│   │   ├── navigation/                    # UI clone navigation
│   │   │   ├── ui_clone_home.dart        # Home screen listing all screens
│   │   │   └── ui_clone_routes.dart      # Route definitions
│   │   │
│   │   ├── COMPONENTS.md                  # Component usage guide
│   │   ├── HOW_TO_VIEW.md                 # Viewing instructions
│   │   ├── INTEGRATION_REFERENCE.md       # Reference integration strategy
│   │   ├── INTEGRATION_REPLACE.md         # Replace integration strategy
│   │   ├── INTEGRATION_GRADUAL.md         # Gradual adoption strategy
│   │   ├── INTEGRATION_TROUBLESHOOTING.md # Troubleshooting guide
│   │   ├── FOLDER_STRUCTURE.md            # This file
│   │   ├── DESIGN_SYSTEM.md               # Design system documentation
│   │   └── README.md                      # Main documentation
│   │
│   ├── core/
│   │   ├── theme/                         # Design system
│   │   │   ├── wz_colors.dart            # Color constants
│   │   │   ├── wz_text_styles.dart       # Typography constants
│   │   │   ├── wz_spacing.dart           # Spacing constants
│   │   │   └── wz_theme.dart             # ThemeData configuration
│   │   │
│   │   └── ... (other core modules)
│   │
│   └── ... (other app modules)
│
├── assets/
│   ├── ui_clone/                          # UI clone assets
│   │   ├── icons/                         # SVG icons
│   │   │   ├── ic_search.svg
│   │   │   ├── ic_heart.svg
│   │   │   ├── ic_chat.svg
│   │   │   ├── ic_profile.svg
│   │   │   ├── ic_settings.svg
│   │   │   ├── ic_notification.svg
│   │   │   ├── ic_filter.svg
│   │   │   ├── ic_location_pin.svg
│   │   │   ├── ic_phone.svg
│   │   │   ├── ic_call.svg
│   │   │   ├── ic_video_call.svg
│   │   │   ├── ic_camera.svg
│   │   │   ├── ic_attachment.svg
│   │   │   ├── ic_mic.svg
│   │   │   ├── ic_send.svg
│   │   │   ├── ic_edit.svg
│   │   │   ├── ic_share.svg
│   │   │   ├── ic_star.svg
│   │   │   ├── ic_ring.svg
│   │   │   ├── ic_shopping.svg
│   │   │   ├── ic_google.svg
│   │   │   ├── ic_chevron_backward.svg
│   │   │   ├── ic_dropdown.svg
│   │   │   ├── ic_cross.svg
│   │   │   ├── ic_menu_dots.svg
│   │   │   ├── ic_info.svg
│   │   │   ├── ic_play.svg
│   │   │   ├── ic_pause.svg
│   │   │   ├── ICON_STRATEGY.md
│   │   │   └── README.md
│   │   │
│   │   ├── illustrations/                 # SVG illustrations
│   │   │   └── README.md
│   │   │
│   │   └── images/                        # Raster images
│   │       ├── backgrounds/
│   │       │   ├── .gitkeep
│   │       │   └── README.md
│   │       ├── logos/
│   │       │   └── README.md
│   │       └── profile_photos/
│   │           └── README.md
│   │
│   └── ... (other app assets)
│
├── test/
│   ├── ui_clone/                          # UI clone tests
│   │   ├── screens/
│   │   │   ├── widget_tree_structure_test.dart
│   │   │   └── visual_property_accuracy_test.dart
│   │   ├── widgets/
│   │   │   ├── wz_buttons_test.dart
│   │   │   ├── wz_inputs_test.dart
│   │   │   ├── wz_cards_test.dart
│   │   │   ├── wz_navigation_test.dart
│   │   │   └── component_reusability_test.dart
│   │   ├── asset_loading_test.dart
│   │   └── asset_path_validity_test.dart
│   │
│   └── ... (other app tests)
│
└── .kiro/
    └── specs/
        └── figma-ui-extraction/           # Extraction specification
            ├── requirements.md
            ├── design.md
            ├── tasks.md
            ├── screen_inventory.md
            ├── button_patterns.md
            ├── input_patterns.md
            ├── card_navigation_patterns.md
            └── ... (other spec files)
```

## Directory Descriptions

### `/lib/ui_clone/`

**Purpose**: Root directory for all UI clone code

**Contents**:
- Screen widgets
- Reusable components
- Navigation system
- Documentation files

**Isolation**: This directory is completely isolated from the main application. No files outside this directory should import from it (except for integration purposes).

### `/lib/ui_clone/screens/`

**Purpose**: Complete screen widgets extracted from Figma

**Naming Convention**: `*_screen_ui.dart` or `*_ui.dart`
- The `_ui` suffix distinguishes UI clone screens from existing app screens
- Example: `login_screen_ui.dart` vs existing `login_screen.dart`

**File Structure**: Each screen file contains:
```dart
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';

class LoginScreenUI extends StatelessWidget {
  const LoginScreenUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pure UI code only
    );
  }
}
```

**Categories**:
- **Authentication**: Splash, Login, OTP screens
- **Onboarding**: Role selection, Profile forms
- **Main Features**: Feed, Explore, Connections, Chat, Profile
- **Vendor**: Browse, Detail, Listing forms
- **Franchise**: Dashboard, Listing forms
- **Settings**: Profile settings, Photo manager, Membership plans

### `/lib/ui_clone/widgets/`

**Purpose**: Reusable UI components extracted from common patterns

**Naming Convention**: `wz_*.dart`
- The `wz_` prefix stands for "WeddingZon" and identifies design system components
- Example: `wz_buttons.dart`, `wz_inputs.dart`

**File Organization**:
- `wz_buttons.dart`: All button variants (Primary, Secondary, Text, Icon, Chip, Filter)
- `wz_inputs.dart`: All input field variants (Text, Password, Dropdown, Date picker)
- `wz_cards.dart`: All card variants (Profile, Vendor, Connection)
- `wz_navigation.dart`: Navigation components (Bottom nav, App bar, Tab bar)

**Component Structure**:
```dart
class WzPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  
  const WzPrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Component implementation
  }
}
```

### `/lib/ui_clone/navigation/`

**Purpose**: Navigation system for the UI clone demo

**Files**:
- `ui_clone_home.dart`: Home screen listing all extracted screens with navigation
- `ui_clone_routes.dart`: Route definitions for all UI clone screens

**Isolation**: This navigation system is separate from the main app's navigation. It only handles navigation within the UI clone demo.

### `/lib/core/theme/`

**Purpose**: Design system constants and theme configuration

**Files**:
- `wz_colors.dart`: Color palette (primary, secondary, neutral, semantic)
- `wz_text_styles.dart`: Typography system (headings, body, captions)
- `wz_spacing.dart`: Spacing scale (4, 8, 16, 24, 32, 48, 64)
- `wz_theme.dart`: Complete ThemeData configuration

**Usage**: These files are shared between the UI clone and can be adopted by the main app.

### `/assets/ui_clone/`

**Purpose**: Assets extracted from Figma for the UI clone

**Subdirectories**:
- `icons/`: SVG icons (30+ files)
- `illustrations/`: SVG illustrations (placeholder structure)
- `images/`: Raster images organized by type
  - `backgrounds/`: Background images
  - `logos/`: Logo variations
  - `profile_photos/`: Profile photo placeholders

**Asset Declaration**: All assets are declared in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/ui_clone/icons/
    - assets/ui_clone/illustrations/
    - assets/ui_clone/images/backgrounds/
    - assets/ui_clone/images/logos/
    - assets/ui_clone/images/profile_photos/
```

### `/test/ui_clone/`

**Purpose**: Tests for UI clone components and screens

**Organization**:
- `screens/`: Tests for screen widgets
- `widgets/`: Tests for reusable components
- Root level: Asset and integration tests

**Test Types**:
- Unit tests: Specific examples and edge cases
- Property-based tests: Universal correctness properties
- Asset tests: Asset loading and path validity

### `/.kiro/specs/figma-ui-extraction/`

**Purpose**: Specification documents for the extraction process

**Files**:
- `requirements.md`: Functional requirements
- `design.md`: Architecture and design decisions
- `tasks.md`: Implementation task list
- `screen_inventory.md`: Complete list of screens
- Pattern documentation: Button, input, card patterns

## File Naming Conventions

### Screens
- **Pattern**: `*_screen_ui.dart` or `*_ui.dart`
- **Examples**: 
  - `login_screen_ui.dart`
  - `feed_screen_ui.dart`
  - `profile_basic_details_ui.dart`
- **Rationale**: The `_ui` suffix distinguishes UI clone screens from existing app screens

### Components
- **Pattern**: `wz_*.dart`
- **Examples**:
  - `wz_buttons.dart`
  - `wz_inputs.dart`
  - `wz_cards.dart`
- **Rationale**: The `wz_` prefix identifies WeddingZon design system components

### Theme Files
- **Pattern**: `wz_*.dart`
- **Examples**:
  - `wz_colors.dart`
  - `wz_text_styles.dart`
  - `wz_spacing.dart`
- **Rationale**: Consistent with component naming, identifies design system files

### Assets
- **Pattern**: `ic_*.svg` for icons, `snake_case` for all assets
- **Examples**:
  - `ic_search.svg`
  - `ic_heart.svg`
  - `background_gradient.png`
- **Rationale**: `ic_` prefix identifies icons, snake_case is Flutter convention

## Import Patterns

### Importing Design System
```dart
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
```

### Importing Components
```dart
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/ui_clone/widgets/wz_inputs.dart';
import 'package:weddingzon/ui_clone/widgets/wz_cards.dart';
```

### Importing Screens
```dart
import 'package:weddingzon/ui_clone/screens/login_screen_ui.dart';
import 'package:weddingzon/ui_clone/screens/feed_screen_ui.dart';
```

### Loading Assets
```dart
// SVG icons
SvgPicture.asset('assets/ui_clone/icons/ic_search.svg')

// Images
Image.asset('assets/ui_clone/images/backgrounds/login_bg.png')
```

## Organization Principles

### 1. Separation of Concerns
- **Screens**: Complete page layouts
- **Widgets**: Reusable components
- **Theme**: Design tokens
- **Navigation**: UI clone demo navigation

### 2. Isolation
- UI clone is completely separate from main app
- No cross-dependencies with existing code
- Can be removed without affecting main app

### 3. Consistency
- All files follow naming conventions
- All components use design system
- All screens have similar structure

### 4. Discoverability
- Clear directory structure
- Descriptive file names
- Comprehensive documentation

### 5. Maintainability
- One component per concern
- Logical grouping
- Easy to locate files

## Adding New Files

### Adding a New Screen
1. Create file in `lib/ui_clone/screens/`
2. Use naming pattern: `*_screen_ui.dart`
3. Import design system and components
4. Add route to `ui_clone_routes.dart`
5. Add entry to `ui_clone_home.dart`

### Adding a New Component
1. Determine component category (button, input, card, navigation)
2. Add to appropriate `wz_*.dart` file
3. Use design system constants
4. Add usage example to `COMPONENTS.md`
5. Write unit tests

### Adding a New Asset
1. Place in appropriate subdirectory
2. Use naming convention (snake_case, ic_ prefix for icons)
3. Update `pubspec.yaml` if needed
4. Document in asset README if needed

## File Size Guidelines

- **Screens**: 200-500 lines typical
- **Components**: 50-200 lines per component
- **Theme files**: 50-150 lines
- **Documentation**: As needed for clarity

## Best Practices

1. **Keep screens pure**: No business logic, state management, or API calls
2. **Use design system**: Always import and use `WzColors`, `WzTextStyles`, `WzSpacing`
3. **Reuse components**: Use extracted components instead of duplicating code
4. **Follow conventions**: Stick to naming patterns and file organization
5. **Document changes**: Update relevant markdown files when adding features
6. **Test thoroughly**: Add tests for new components and screens

---

**Questions about file organization?** Refer to the main [README.md](./README.md) or the [Figma UI Extraction Spec](../../.kiro/specs/figma-ui-extraction/).
