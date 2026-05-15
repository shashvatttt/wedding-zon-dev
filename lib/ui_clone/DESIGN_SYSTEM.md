# WeddingZon Design System

## Overview

The WeddingZon design system is a comprehensive collection of design tokens (colors, typography, spacing) extracted from Figma and implemented as Dart constants. It ensures visual consistency across the application and provides a single source of truth for all design decisions.

## Design Tokens

Design tokens are named design values that can be reused throughout the application. They provide:

- **Consistency**: Same values used everywhere
- **Maintainability**: Change once, update everywhere
- **Scalability**: Easy to extend with new values
- **Communication**: Shared language between design and development

## Color System

### File: `lib/core/theme/wz_colors.dart`

The color system includes primary, secondary, neutral, and semantic colors.

### Primary Colors

Used for main brand identity and primary actions.

```dart
import 'package:weddingzon/core/theme/wz_colors.dart';

// Primary brand color
WzColors.primary          // #6C63FF - Main brand purple
WzColors.primaryLight     // #8B84FF - Lighter variant
WzColors.primaryDark      // #4D44CC - Darker variant
```

**Usage**:
- Primary buttons
- Active states
- Key UI elements
- Brand touchpoints

### Secondary Colors

Used for secondary actions and accents.

```dart
// Secondary accent color
WzColors.secondary        // #FF6584 - Accent pink/red
WzColors.secondaryLight   // #FF8BA3 - Lighter variant
WzColors.secondaryDark    // #CC5169 - Darker variant
```

**Usage**:
- Secondary buttons
- Highlights
- Accents
- Call-to-action elements

### Neutral Colors

Used for text, backgrounds, borders, and general UI elements.

```dart
// Neutral grays
WzColors.black            // #000000 - Pure black
WzColors.gray900          // #1A1A1A - Darkest gray
WzColors.gray800          // #333333 - Very dark gray
WzColors.gray700          // #4D4D4D - Dark gray
WzColors.gray600          // #666666 - Medium-dark gray
WzColors.gray500          // #808080 - Medium gray
WzColors.gray400          // #999999 - Medium-light gray
WzColors.gray300          // #CCCCCC - Light gray
WzColors.gray200          // #E5E5E5 - Very light gray
WzColors.gray100          // #F5F5F5 - Almost white
WzColors.white            // #FFFFFF - Pure white
```

**Usage**:
- Text colors (gray900, gray800, gray700)
- Borders (gray300, gray200)
- Backgrounds (gray100, white)
- Disabled states (gray400, gray300)

### Semantic Colors

Used for status messages and feedback.

```dart
// Success
WzColors.success          // #4CAF50 - Green
WzColors.successLight     // #81C784 - Light green
WzColors.successDark      // #388E3C - Dark green

// Error
WzColors.error            // #F44336 - Red
WzColors.errorLight       // #E57373 - Light red
WzColors.errorDark        // #D32F2F - Dark red

// Warning
WzColors.warning          // #FF9800 - Orange
WzColors.warningLight     // #FFB74D - Light orange
WzColors.warningDark      // #F57C00 - Dark orange

// Info
WzColors.info             // #2196F3 - Blue
WzColors.infoLight        // #64B5F6 - Light blue
WzColors.infoDark         // #1976D2 - Dark blue
```

**Usage**:
- Success messages and confirmations
- Error messages and validation
- Warning alerts
- Informational messages

### Background Colors

```dart
WzColors.background       // #FAFAFA - Main background
WzColors.surface          // #FFFFFF - Card/surface background
WzColors.surfaceVariant   // #F5F5F5 - Alternate surface
```

### Example Usage

```dart
// Container with primary color
Container(
  decoration: BoxDecoration(
    color: WzColors.primary,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Primary Button',
    style: TextStyle(color: WzColors.white),
  ),
)

// Text with semantic colors
Text(
  'Success!',
  style: TextStyle(color: WzColors.success),
)

Text(
  'Error occurred',
  style: TextStyle(color: WzColors.error),
)

// Border with neutral color
Container(
  decoration: BoxDecoration(
    border: Border.all(color: WzColors.gray300),
    borderRadius: BorderRadius.circular(8),
  ),
)
```

## Typography System

### File: `lib/core/theme/wz_text_styles.dart`

The typography system defines text styles for all text elements in the application.

### Headings

```dart
import 'package:weddingzon/core/theme/wz_text_styles.dart';

// Large headings
WzTextStyles.heading1     // 32px, Bold, -0.5 letter spacing
WzTextStyles.heading2     // 28px, Bold, -0.3 letter spacing
WzTextStyles.heading3     // 24px, SemiBold, -0.2 letter spacing
WzTextStyles.heading4     // 20px, SemiBold, 0 letter spacing
WzTextStyles.heading5     // 18px, SemiBold, 0 letter spacing
WzTextStyles.heading6     // 16px, SemiBold, 0 letter spacing
```

**Usage**:
- Page titles (heading1, heading2)
- Section headers (heading3, heading4)
- Card titles (heading5, heading6)

### Body Text

```dart
// Regular body text
WzTextStyles.body1        // 16px, Regular, 0.15 letter spacing
WzTextStyles.body2        // 14px, Regular, 0.1 letter spacing

// Medium weight body text
WzTextStyles.body1Medium  // 16px, Medium, 0.15 letter spacing
WzTextStyles.body2Medium  // 14px, Medium, 0.1 letter spacing
```

**Usage**:
- Main content text (body1)
- Secondary content (body2)
- Emphasized text (body1Medium, body2Medium)

### Captions and Labels

```dart
// Small text
WzTextStyles.caption      // 12px, Regular, 0.4 letter spacing
WzTextStyles.overline     // 10px, Regular, 1.5 letter spacing

// Labels
WzTextStyles.label        // 14px, Medium, 0.1 letter spacing
WzTextStyles.labelSmall   // 12px, Medium, 0.5 letter spacing
```

**Usage**:
- Helper text (caption)
- Timestamps (caption)
- Form labels (label)
- Tags and badges (labelSmall)
- Overlines (overline)

### Button Text

```dart
WzTextStyles.button       // 16px, SemiBold, 0.5 letter spacing
WzTextStyles.buttonSmall  // 14px, SemiBold, 0.5 letter spacing
```

**Usage**:
- Button labels
- Call-to-action text

### Example Usage

```dart
// Page title
Text(
  'Welcome to WeddingZon',
  style: WzTextStyles.heading1,
)

// Section header
Text(
  'Recent Matches',
  style: WzTextStyles.heading3,
)

// Body content
Text(
  'Find your perfect match with our advanced matching algorithm.',
  style: WzTextStyles.body1,
)

// Caption
Text(
  'Last updated 2 hours ago',
  style: WzTextStyles.caption.copyWith(
    color: WzColors.gray600,
  ),
)

// Button
ElevatedButton(
  onPressed: () {},
  child: Text(
    'Get Started',
    style: WzTextStyles.button,
  ),
)
```

### Typography Customization

You can customize text styles using `copyWith()`:

```dart
// Change color
Text(
  'Error message',
  style: WzTextStyles.body1.copyWith(
    color: WzColors.error,
  ),
)

// Change weight
Text(
  'Important',
  style: WzTextStyles.body1.copyWith(
    fontWeight: FontWeight.bold,
  ),
)

// Multiple properties
Text(
  'Custom text',
  style: WzTextStyles.heading3.copyWith(
    color: WzColors.primary,
    fontStyle: FontStyle.italic,
    decoration: TextDecoration.underline,
  ),
)
```

## Spacing System

### File: `lib/core/theme/wz_spacing.dart`

The spacing system provides consistent spacing values for padding, margins, and gaps.

### Spacing Scale

```dart
import 'package:weddingzon/core/theme/wz_spacing.dart';

WzSpacing.space4          // 4.0
WzSpacing.space8          // 8.0
WzSpacing.space12         // 12.0
WzSpacing.space16         // 16.0
WzSpacing.space20         // 20.0
WzSpacing.space24         // 24.0
WzSpacing.space32         // 32.0
WzSpacing.space40         // 40.0
WzSpacing.space48         // 48.0
WzSpacing.space64         // 64.0
```

### Usage Guidelines

- **space4**: Minimal spacing, tight layouts
- **space8**: Small spacing, compact elements
- **space12**: Small-medium spacing
- **space16**: Standard spacing (most common)
- **space20**: Medium spacing
- **space24**: Medium-large spacing
- **space32**: Large spacing, section separation
- **space40**: Extra large spacing
- **space48**: Very large spacing
- **space64**: Maximum spacing, major sections

### Example Usage

```dart
// Padding
Container(
  padding: EdgeInsets.all(WzSpacing.space16),
  child: Text('Content'),
)

// Margin
Container(
  margin: EdgeInsets.symmetric(
    horizontal: WzSpacing.space24,
    vertical: WzSpacing.space16,
  ),
  child: Text('Content'),
)

// Gap in Column
Column(
  children: [
    Text('First'),
    SizedBox(height: WzSpacing.space12),
    Text('Second'),
    SizedBox(height: WzSpacing.space12),
    Text('Third'),
  ],
)

// Gap in Row
Row(
  children: [
    Icon(Icons.star),
    SizedBox(width: WzSpacing.space8),
    Text('Rating'),
  ],
)

// Complex spacing
Container(
  padding: EdgeInsets.only(
    left: WzSpacing.space16,
    right: WzSpacing.space16,
    top: WzSpacing.space24,
    bottom: WzSpacing.space32,
  ),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: WzSpacing.space16),
      Text('Content'),
    ],
  ),
)
```

## Theme Configuration

### File: `lib/core/theme/wz_theme.dart`

The theme file combines all design tokens into a complete ThemeData configuration.

### Light Theme

```dart
import 'package:weddingzon/core/theme/wz_theme.dart';

// Apply theme to MaterialApp
MaterialApp(
  theme: WzTheme.lightTheme,
  // ...
)
```

### Theme Properties

The theme includes:

- **Primary color**: `WzColors.primary`
- **Secondary color**: `WzColors.secondary`
- **Background color**: `WzColors.background`
- **Surface color**: `WzColors.surface`
- **Error color**: `WzColors.error`
- **Text theme**: All `WzTextStyles` mapped to TextTheme
- **Button theme**: Configured with design system values
- **Input decoration theme**: Consistent input field styling
- **Card theme**: Standard card styling
- **App bar theme**: Consistent app bar styling

### Using Theme in Widgets

```dart
// Access theme colors
Container(
  color: Theme.of(context).primaryColor,
)

// Access text styles
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineMedium,
)

// Access theme properties
Container(
  decoration: BoxDecoration(
    color: Theme.of(context).scaffoldBackgroundColor,
  ),
)
```

## Border Radius

Common border radius values:

```dart
// Small radius
BorderRadius.circular(4)   // Subtle rounding

// Medium radius (most common)
BorderRadius.circular(8)   // Standard cards, inputs
BorderRadius.circular(12)  // Buttons, prominent cards

// Large radius
BorderRadius.circular(16)  // Large cards, modals
BorderRadius.circular(24)  // Very rounded elements

// Circular
BorderRadius.circular(999) // Fully circular (pills, avatars)
```

## Shadows

Common elevation values:

```dart
// Light shadow
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 4,
  offset: Offset(0, 2),
)

// Medium shadow (cards)
BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 4),
)

// Heavy shadow (modals)
BoxShadow(
  color: Colors.black.withOpacity(0.15),
  blurRadius: 16,
  offset: Offset(0, 8),
)
```

## Best Practices

### 1. Always Use Design Tokens

❌ **Don't**:
```dart
Container(
  color: Color(0xFF6C63FF),
  padding: EdgeInsets.all(16),
  child: Text(
    'Title',
    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  ),
)
```

✅ **Do**:
```dart
Container(
  color: WzColors.primary,
  padding: EdgeInsets.all(WzSpacing.space16),
  child: Text(
    'Title',
    style: WzTextStyles.heading3,
  ),
)
```

### 2. Use Semantic Colors

❌ **Don't**:
```dart
Text('Error', style: TextStyle(color: Colors.red))
```

✅ **Do**:
```dart
Text('Error', style: TextStyle(color: WzColors.error))
```

### 3. Maintain Consistency

- Use the same spacing values throughout
- Use the same text styles for similar content
- Use the same colors for similar purposes

### 4. Customize with copyWith()

When you need variations, use `copyWith()` instead of creating new styles:

```dart
Text(
  'Custom',
  style: WzTextStyles.body1.copyWith(color: WzColors.primary),
)
```

### 5. Document Custom Values

If you need to add custom values, document them and consider adding to the design system:

```dart
// Custom spacing for specific use case
const double customSpacing = 18.0; // Between space16 and space20
```

## Extending the Design System

### Adding New Colors

1. Add to `wz_colors.dart`:
```dart
static const Color tertiary = Color(0xFF00BCD4);
```

2. Document usage in this file
3. Update theme configuration if needed

### Adding New Text Styles

1. Add to `wz_text_styles.dart`:
```dart
static const TextStyle customStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  letterSpacing: 0.2,
);
```

2. Document usage in this file
3. Consider if it should be part of the theme

### Adding New Spacing

1. Add to `wz_spacing.dart`:
```dart
static const double space28 = 28.0;
```

2. Document usage guidelines
3. Ensure it fits the spacing scale

## Design System Checklist

When building UI, ensure:

- ✅ All colors come from `WzColors`
- ✅ All text uses `WzTextStyles`
- ✅ All spacing uses `WzSpacing`
- ✅ Border radius values are consistent
- ✅ Shadows follow elevation guidelines
- ✅ Theme is applied to MaterialApp
- ✅ No hardcoded values in widgets

## Resources

- **Color Palette**: See `lib/core/theme/wz_colors.dart`
- **Typography**: See `lib/core/theme/wz_text_styles.dart`
- **Spacing**: See `lib/core/theme/wz_spacing.dart`
- **Theme**: See `lib/core/theme/wz_theme.dart`
- **Components**: See [COMPONENTS.md](./COMPONENTS.md)
- **Figma**: Original design file (Node: 129:2318)

---

**Questions about the design system?** Refer to the main [README.md](./README.md) or check the source files in `lib/core/theme/`.
