# Figma UI Extraction Methodology

## Overview

This document explains the systematic process used to extract the WeddingZon mobile UI from Figma and convert it into pixel-perfect Flutter code. The methodology ensures consistency, accuracy, and maintainability throughout the extraction process.

## Extraction Workflow

The extraction follows a five-phase approach:

```
Phase 1: Design System Extraction
    ↓
Phase 2: Screen Discovery & Inventory
    ↓
Phase 3: Component Extraction
    ↓
Phase 4: Screen Generation
    ↓
Phase 5: Asset Extraction & Documentation
```

## Phase 1: Design System Extraction

### Objective
Extract all design tokens (colors, typography, spacing) from Figma to establish a consistent design foundation.

### Process

#### Step 1.1: Extract Design Variables
```
Tool: get_variable_defs(nodeId: "129:2318")
Input: Root Figma node ID
Output: JSON with all design variables
```

**What we extract**:
- Color definitions with hex codes
- Typography specifications (font family, size, weight, line height, letter spacing)
- Spacing values (padding, margins, gaps)
- Border radius values
- Shadow/elevation specifications

#### Step 1.2: Parse and Organize Variables

**Color Organization**:
```
Figma Variables → Parse → Group by Usage → Generate Dart Constants

Example:
{
  "primary-500": "#6C63FF",
  "primary-400": "#8B84FF",
  "primary-600": "#4D44CC"
}
↓
class WzColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8B84FF);
  static const Color primaryDark = Color(0xFF4D44CC);
}
```

**Typography Organization**:
```
Figma Text Styles → Parse Properties → Generate TextStyle Constants

Example:
{
  "Heading 1": {
    "fontSize": 32,
    "fontWeight": "Bold",
    "letterSpacing": -0.5
  }
}
↓
static const TextStyle heading1 = TextStyle(
  fontSize: 32,
  fontWeight: FontWeight.bold,
  letterSpacing: -0.5,
);
```

**Spacing Organization**:
```
Figma Spacing Patterns → Identify Common Values → Generate Constants

Observed: 4, 8, 12, 16, 24, 32, 48, 64
↓
static const double space4 = 4.0;
static const double space8 = 8.0;
// ... etc
```

#### Step 1.3: Generate Design System Files

**Output Files**:
1. `lib/core/theme/wz_colors.dart` - Color constants
2. `lib/core/theme/wz_text_styles.dart` - Typography constants
3. `lib/core/theme/wz_spacing.dart` - Spacing constants
4. `lib/core/theme/wz_theme.dart` - ThemeData configuration

#### Step 1.4: Validate Design System

**Validation Checks**:
- ✅ All colors have valid hex codes
- ✅ All text styles have required properties
- ✅ Spacing values follow consistent scale
- ✅ Theme compiles without errors
- ✅ Property test: Design Token Consistency passes

## Phase 2: Screen Discovery & Inventory

### Objective
Identify all mobile screens in the Figma file and create a comprehensive inventory.

### Process

#### Step 2.1: Get Figma File Structure
```
Tool: get_metadata(nodeId: "129:2318")
Input: Root node ID
Output: XML structure of all frames
```

**What we look for**:
- Frames with mobile dimensions (typically 375x812, 390x844, 414x896)
- Frame names indicating screens (e.g., "Login Screen", "Feed", "Profile")
- Nested frames representing screen variants

#### Step 2.2: Traverse and Identify Screens

**Identification Criteria**:
1. Frame dimensions match mobile screen sizes
2. Frame name suggests a complete screen
3. Frame contains complete UI layout (not just a component)
4. Frame is at appropriate hierarchy level

**Example Traversal**:
```
Root (129:2318)
├── Authentication Flows
│   ├── Splash Screen (129:2319) ✓ Mobile screen
│   ├── Login Choice (129:2320) ✓ Mobile screen
│   └── OTP Screen (129:2321) ✓ Mobile screen
├── Main Features
│   ├── Feed (129:2400) ✓ Mobile screen
│   └── Profile (129:2450) ✓ Mobile screen
└── Components
    └── Button (129:3000) ✗ Component, not screen
```

#### Step 2.3: Document Screen Inventory

**Inventory Format**:
```markdown
## [Category Name]

### [Screen Name]
- **Node ID**: [Figma node ID]
- **Dimensions**: [width x height]
- **Purpose**: [Brief description]
- **Navigation**: [Related screens]
- **Variants**: [Different states if any]
- **Status**: [Not started / In progress / Completed]
```

**Output**: `.kiro/specs/figma-ui-extraction/screen_inventory.md`

#### Step 2.4: Prioritize Screens

**Priority Order**:
1. Authentication screens (critical path)
2. Onboarding screens (user journey)
3. Main feature screens (core functionality)
4. Secondary feature screens
5. Settings and utility screens

## Phase 3: Component Extraction

### Objective
Identify common UI patterns and extract them as reusable components.

### Process

#### Step 3.1: Pattern Recognition

**Method**: Review multiple screens to identify repeated patterns

**Common Patterns**:
- Buttons appearing across screens
- Input fields with similar styling
- Cards with consistent layout
- Navigation elements

**Documentation**:
- Create pattern analysis documents (e.g., `button_patterns.md`)
- Document variants and customization parameters
- Note usage contexts

#### Step 3.2: Component Design

**For each component, define**:
1. **Variants**: Different visual styles (primary, secondary, outlined, etc.)
2. **Parameters**: Customization options (text, colors, sizes, callbacks)
3. **States**: Different states (default, hover, pressed, disabled, loading)
4. **Constraints**: Size constraints and responsive behavior

**Example - Button Component Design**:
```
Component: WzPrimaryButton

Variants:
- Primary (filled, brand color)
- Secondary (outlined, brand color)
- Text (no background)
- Icon (icon only)

Parameters:
- text: String (required)
- onPressed: VoidCallback? (optional)
- isLoading: bool (default: false)
- width: double? (optional)
- icon: Widget? (optional)

States:
- Default: Full color, enabled
- Pressed: Darker shade
- Disabled: Gray, no interaction
- Loading: Spinner, disabled interaction
```

#### Step 3.3: Component Implementation

**Implementation Pattern**:
```dart
class WzPrimaryButton extends StatelessWidget {
  // 1. Define parameters
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  
  // 2. Constructor with named parameters
  const WzPrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
  }) : super(key: key);
  
  // 3. Build method using design system
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: WzColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(text, style: WzTextStyles.button),
      ),
    );
  }
}
```

**Key Principles**:
- Use design system constants (WzColors, WzTextStyles, WzSpacing)
- Use const constructors where possible
- Provide sensible defaults
- Make components flexible but not overly complex

#### Step 3.4: Component Testing

**Test Coverage**:
1. **Rendering tests**: Component renders correctly with different parameters
2. **Interaction tests**: Callbacks fire correctly
3. **State tests**: Different states display correctly
4. **Accessibility tests**: Component is accessible

**Example Test**:
```dart
testWidgets('WzPrimaryButton renders with text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: WzPrimaryButton(
          text: 'Click Me',
          onPressed: () {},
        ),
      ),
    ),
  );
  
  expect(find.text('Click Me'), findsOneWidget);
});
```

#### Step 3.5: Component Documentation

**Documentation includes**:
- Component description and purpose
- Usage examples with code
- Parameter descriptions
- Visual examples (screenshots)
- Best practices

**Output**: `lib/ui_clone/COMPONENTS.md`

## Phase 4: Screen Generation

### Objective
Generate complete Flutter screen widgets from Figma designs.

### Process

#### Step 4.1: Get Screen Design Context
```
Tool: get_design_context(nodeId: "[screen-node-id]")
Input: Specific screen node ID
Output: Complete design information including:
  - Layout structure (hierarchy)
  - Visual properties (colors, sizes, spacing)
  - Text content
  - Asset references
```

#### Step 4.2: Parse Design Context

**Extract Information**:
1. **Layout Structure**: Parent-child relationships, nesting
2. **Widget Types**: Identify appropriate Flutter widgets
3. **Visual Properties**: Colors, sizes, borders, shadows
4. **Text Content**: Actual text and styling
5. **Assets**: Icons, images, illustrations

**Example Parsing**:
```
Figma Layer: Frame (Column layout)
  ├── Text "Welcome"
  ├── Text "Find your match"
  └── Frame (Row layout)
      ├── Button "Login"
      └── Button "Sign Up"

↓ Maps to ↓

Flutter Widget: Column
  ├── Text("Welcome", style: WzTextStyles.heading1)
  ├── SizedBox(height: WzSpacing.space8)
  ├── Text("Find your match", style: WzTextStyles.body1)
  ├── SizedBox(height: WzSpacing.space24)
  └── Row
      ├── WzPrimaryButton(text: "Login")
      ├── SizedBox(width: WzSpacing.space12)
      └── WzSecondaryButton(text: "Sign Up")
```

#### Step 4.3: Widget Mapping

**Figma Layer → Flutter Widget Mapping**:

| Figma Layer Type | Flutter Widget | Notes |
|-----------------|----------------|-------|
| Frame (Auto Layout: Vertical) | Column | Use mainAxisAlignment, crossAxisAlignment |
| Frame (Auto Layout: Horizontal) | Row | Use mainAxisAlignment, crossAxisAlignment |
| Frame (Absolute positioning) | Stack | Use Positioned for children |
| Text | Text | Apply TextStyle from design system |
| Rectangle (filled) | Container | Use BoxDecoration for styling |
| Rectangle (border only) | Container | Use border in BoxDecoration |
| Vector/Icon | SvgPicture.asset | Reference extracted SVG |
| Image | Image.asset | Reference extracted image |
| Button | WzPrimaryButton/etc | Use extracted component |
| Input | WzTextField/etc | Use extracted component |

#### Step 4.4: Generate Widget Code

**Code Generation Template**:
```dart
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
// ... other imports

class [ScreenName]UI extends StatelessWidget {
  const [ScreenName]UI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.background,
      appBar: [AppBar if needed],
      body: SafeArea(
        child: [Screen content],
      ),
    );
  }
}
```

**Code Generation Rules**:
1. Use design system constants, never hardcoded values
2. Use extracted components where applicable
3. Add SafeArea for screen boundaries
4. Use MediaQuery for responsive sizing when needed
5. Add const constructors where possible
6. Include comments referencing Figma layer names
7. No business logic, state management, or navigation

#### Step 4.5: Visual Property Conversion

**Color Conversion**:
```
Figma: #6C63FF → Flutter: Color(0xFF6C63FF)
Figma: rgba(108, 99, 255, 0.5) → Flutter: Color(0xFF6C63FF).withOpacity(0.5)
```

**Size Conversion**:
```
Figma: 375 x 812 → Flutter: MediaQuery or fixed sizes
Figma: width: 100% → Flutter: double.infinity or Expanded
```

**Spacing Conversion**:
```
Figma: padding: 16 → Flutter: EdgeInsets.all(WzSpacing.space16)
Figma: gap: 12 → Flutter: SizedBox(height: WzSpacing.space12)
```

**Border Radius Conversion**:
```
Figma: corner radius: 12 → Flutter: BorderRadius.circular(12)
```

**Shadow Conversion**:
```
Figma: drop shadow (blur: 8, offset: 0,4, color: #000 10%)
↓
Flutter: BoxShadow(
  color: Colors.black.withOpacity(0.1),
  blurRadius: 8,
  offset: Offset(0, 4),
)
```

#### Step 4.6: Save and Validate

**Save**:
- File location: `lib/ui_clone/screens/[screen_name]_ui.dart`
- Naming: Use snake_case with `_ui` suffix

**Validate**:
1. ✅ File compiles without errors
2. ✅ All imports resolve correctly
3. ✅ Design system constants used throughout
4. ✅ No hardcoded values
5. ✅ No business logic
6. ✅ Widget tree structure matches Figma hierarchy
7. ✅ Visual properties match Figma exactly

#### Step 4.7: Visual Comparison

**Method**:
1. Generate screenshot from Figma using `get_screenshot(nodeId)`
2. Run Flutter app and capture screenshot
3. Compare side-by-side
4. Identify and document discrepancies
5. Make adjustments if needed

## Phase 5: Asset Extraction & Documentation

### Objective
Extract all visual assets (icons, illustrations, images) and create comprehensive documentation.

### Process

#### Step 5.1: Identify Assets

**Asset Types**:
1. **Icons**: Small vector graphics (search, heart, settings, etc.)
2. **Illustrations**: Larger vector graphics (empty states, onboarding)
3. **Images**: Raster graphics (photos, backgrounds, logos)

**Identification Method**:
- Review all screens
- Note all vector and image layers
- Document node IDs
- Categorize by type and usage

#### Step 5.2: Extract SVG Assets

**For Icons**:
```
Tool: get_design_context(nodeId: "[icon-node-id]")
Extract: SVG XML content
Save to: assets/ui_clone/icons/ic_[name].svg
Naming: ic_ prefix, snake_case
```

**For Illustrations**:
```
Tool: get_design_context(nodeId: "[illustration-node-id]")
Extract: SVG XML content
Save to: assets/ui_clone/illustrations/[name].svg
Naming: snake_case
```

**SVG Optimization**:
- Remove unnecessary metadata
- Simplify paths where possible
- Ensure viewBox is set correctly
- Test rendering at different sizes

#### Step 5.3: Extract Image Assets

**For Images**:
```
Tool: get_design_context(nodeId: "[image-node-id]")
Extract: Image data or create placeholder
Save to: assets/ui_clone/images/[category]/[name].png
Naming: snake_case
```

**Image Categories**:
- `backgrounds/`: Background images
- `logos/`: Logo variations
- `profile_photos/`: Profile photo placeholders

**Image Specifications**:
- Document required dimensions
- Note if multiple resolutions needed (@2x, @3x)
- Create placeholder structure
- Document in ASSETS.md

#### Step 5.4: Update pubspec.yaml

**Add Asset Declarations**:
```yaml
flutter:
  assets:
    - assets/ui_clone/icons/
    - assets/ui_clone/illustrations/
    - assets/ui_clone/images/backgrounds/
    - assets/ui_clone/images/logos/
    - assets/ui_clone/images/profile_photos/
```

**Add Dependencies**:
```yaml
dependencies:
  flutter_svg: ^2.0.0  # For SVG rendering
```

#### Step 5.5: Asset Usage in Code

**SVG Icons**:
```dart
SvgPicture.asset(
  'assets/ui_clone/icons/ic_search.svg',
  width: 24,
  height: 24,
  color: WzColors.gray700,
)
```

**Images**:
```dart
Image.asset(
  'assets/ui_clone/images/backgrounds/login_bg.png',
  fit: BoxFit.cover,
)
```

#### Step 5.6: Create Documentation

**Documentation Files**:
1. `lib/ui_clone/README.md` - Main documentation
2. `lib/ui_clone/FOLDER_STRUCTURE.md` - File organization
3. `lib/ui_clone/DESIGN_SYSTEM.md` - Design token usage
4. `lib/ui_clone/EXTRACTION_METHODOLOGY.md` - This file
5. `lib/ui_clone/COMPONENTS.md` - Component usage
6. `lib/ui_clone/HOW_TO_VIEW.md` - Viewing instructions
7. `lib/ui_clone/INTEGRATION_*.md` - Integration strategies
8. `ASSETS.md` - Asset documentation

## Quality Assurance

### Automated Testing

**Property-Based Tests** (Universal properties):
1. Design Token Consistency
2. Widget Tree Structure Preservation
3. Visual Property Accuracy
4. Component Reusability
5. Asset Path Validity
6. Screen Completeness
7. Code Quality Standards
8. Design System Organization

**Unit Tests** (Specific examples):
- Component rendering tests
- Asset loading tests
- Widget interaction tests

### Manual Verification

**Visual Comparison**:
- Side-by-side comparison with Figma
- Test on multiple device sizes
- Verify colors, spacing, typography
- Check responsive behavior

**Code Review**:
- Verify design system usage
- Check for hardcoded values
- Ensure no business logic
- Validate naming conventions
- Review code organization

### Checkpoints

**Checkpoint 1**: After design system extraction
- All design files compile
- All tests pass
- Design tokens validated

**Checkpoint 2**: After component extraction
- All components compile
- Component tests pass
- Components documented

**Checkpoint 3**: After screen batches
- Screens compile and render
- Visual comparison complete
- Discrepancies documented

**Checkpoint 4**: Final verification
- All tests pass
- All documentation complete
- Integration guides ready

## Tools and Technologies

### Figma MCP Tools

1. **get_design_context**: Extract complete design information
2. **get_variable_defs**: Extract design variables
3. **get_screenshot**: Generate visual references
4. **get_metadata**: Get structural overview

### Flutter Tools

1. **Dart Analyzer**: Code quality verification
2. **Flutter Test**: Unit and widget testing
3. **Flutter Doctor**: Environment validation

### Development Tools

1. **VS Code / Android Studio**: IDE
2. **Git**: Version control
3. **Markdown**: Documentation

## Best Practices

### During Extraction

1. **Work systematically**: Follow the phase order
2. **Validate frequently**: Run tests after each phase
3. **Document as you go**: Don't leave documentation for the end
4. **Use checkpoints**: Verify before moving to next phase
5. **Keep it pure**: No business logic in UI clone

### Code Generation

1. **Use design system**: Always use WzColors, WzTextStyles, WzSpacing
2. **Reuse components**: Use extracted components instead of duplicating
3. **Add comments**: Reference Figma layer names
4. **Follow conventions**: Consistent naming and structure
5. **Optimize performance**: Use const constructors

### Documentation

1. **Be comprehensive**: Cover all aspects
2. **Provide examples**: Show, don't just tell
3. **Keep updated**: Update docs when code changes
4. **Make it accessible**: Clear structure and navigation
5. **Include visuals**: Screenshots and diagrams help

## Troubleshooting

### Common Issues

**Issue**: Colors don't match Figma exactly
- **Cause**: Incorrect hex code conversion or opacity
- **Solution**: Verify hex codes, check for opacity/alpha values

**Issue**: Layout doesn't match Figma
- **Cause**: Wrong widget choice or incorrect constraints
- **Solution**: Review Figma auto-layout settings, use correct Flutter widgets

**Issue**: Spacing looks off
- **Cause**: Missing spacing or wrong spacing values
- **Solution**: Check Figma padding/gap values, use WzSpacing constants

**Issue**: Assets not loading
- **Cause**: Incorrect path or missing pubspec.yaml declaration
- **Solution**: Verify asset paths, check pubspec.yaml configuration

**Issue**: Text overflow
- **Cause**: Fixed width constraints or long text
- **Solution**: Use Expanded, Flexible, or maxLines with overflow handling

## Maintenance

### Updating from Figma

When designs change:

1. Identify changed screens/components
2. Get updated node IDs from screen inventory
3. Re-run extraction for those nodes
4. Replace generated files
5. Run tests to verify no regressions
6. Update documentation if needed

### Adding New Screens

To add new screens:

1. Identify screen in Figma
2. Add to screen inventory
3. Extract using get_design_context
4. Generate Flutter widget
5. Add to navigation system
6. Test and document

### Refactoring

When refactoring:

1. Update design system files first
2. Update components next
3. Update screens last
4. Run tests after each change
5. Update documentation

## Metrics and Statistics

### Extraction Statistics

- **Total Screens**: 40+
- **Total Components**: 4 component files (buttons, inputs, cards, navigation)
- **Total Assets**: 30+ icons, placeholder structures for illustrations and images
- **Design Tokens**: 50+ colors, 15+ text styles, 10+ spacing values
- **Lines of Code**: ~10,000+ lines of Flutter code
- **Documentation**: 8 markdown files

### Time Estimates

- **Design System**: 2-3 hours
- **Screen Discovery**: 1-2 hours
- **Component Extraction**: 4-6 hours
- **Screen Generation**: 15-30 minutes per screen (10-20 hours total)
- **Asset Extraction**: 2-3 hours
- **Documentation**: 3-4 hours
- **Testing**: 4-6 hours
- **Total**: 30-45 hours

## Conclusion

This methodology provides a systematic, repeatable process for extracting UI designs from Figma and converting them into high-quality Flutter code. By following these phases and best practices, we ensure:

- **Consistency**: Design system used throughout
- **Accuracy**: Pixel-perfect replication of designs
- **Maintainability**: Well-organized, documented code
- **Quality**: Comprehensive testing and validation
- **Reusability**: Components can be adopted into main app

The result is a complete UI clone that serves as a reference, component library, and development accelerator for the WeddingZon application.

---

**Questions about the extraction process?** Refer to the [README.md](./README.md) or the [Figma UI Extraction Spec](../../.kiro/specs/figma-ui-extraction/).
