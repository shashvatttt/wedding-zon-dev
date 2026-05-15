# UI Clone Integration Troubleshooting Guide

## Overview

This guide provides solutions to common issues encountered when integrating the UI clone into your existing WeddingZon application. Whether you're using Reference, Replace, or Gradual Adoption strategies, this guide will help you resolve integration challenges quickly.

## Table of Contents

1. [Design System Issues](#design-system-issues)
2. [Component Issues](#component-issues)
3. [Navigation Issues](#navigation-issues)
4. [Asset Issues](#asset-issues)
5. [Build and Compilation Issues](#build-and-compilation-issues)
6. [Visual Discrepancies](#visual-discrepancies)
7. [Performance Issues](#performance-issues)
8. [State Management Issues](#state-management-issues)
9. [Testing Issues](#testing-issues)
10. [Frequently Asked Questions](#frequently-asked-questions)

---

## Design System Issues

### Issue 1: Colors Don't Match Figma Design

**Symptoms:**
- Colors appear different from Figma
- Inconsistent color usage across screens
- Wrong color values

**Causes:**
- Using hardcoded color values instead of design tokens
- Incorrect color constant imported
- Color opacity/alpha channel issues

**Solutions:**

```dart
// ❌ WRONG - Hardcoded color
Container(
  color: Color(0xFFE63E62),
)

// ✅ CORRECT - Use design token
import 'package:weddingzon/core/theme/wz_colors.dart';

Container(
  color: WzColors.primary,
)
```

**Verification:**
```dart
// Check available colors
print(WzColors.primary);  // Color(0xffe63e62)
print(WzColors.secondary);  // Color(0xff6c63ff)
```

**Related Files:**
- `lib/core/theme/wz_colors.dart`

---

### Issue 2: Typography Doesn't Match Design

**Symptoms:**
- Font sizes are incorrect
- Font weights don't match
- Line height or letter spacing is off

**Causes:**
- Using hardcoded TextStyle instead of design tokens
- Incorrect text style constant
- Missing font family configuration

**Solutions:**

```dart
// ❌ WRONG - Hardcoded text style
Text(
  'Hello World',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  ),
)

// ✅ CORRECT - Use design token
import 'package:weddingzon/core/theme/wz_text_styles.dart';

Text(
  'Hello World',
  style: WzTextStyles.heading2,
)
```

**Available Text Styles:**
- `WzTextStyles.heading1` - 32px, bold
- `WzTextStyles.heading2` - 24px, bold
- `WzTextStyles.heading3` - 20px, semibold
- `WzTextStyles.heading4` - 18px, semibold
- `WzTextStyles.body1` - 16px, regular
- `WzTextStyles.body2` - 14px, regular
- `WzTextStyles.caption` - 12px, regular
- `WzTextStyles.button` - 16px, semibold

**Related Files:**
- `lib/core/theme/wz_text_styles.dart`

---

### Issue 3: Spacing Is Inconsistent

**Symptoms:**
- Padding and margins don't match design
- Inconsistent spacing between elements
- Layout looks cramped or too spacious

**Causes:**
- Using hardcoded spacing values
- Incorrect spacing constant
- Missing spacing between elements

**Solutions:**

```dart
// ❌ WRONG - Hardcoded spacing
Padding(
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: 8),
      Text('Subtitle'),
    ],
  ),
)

// ✅ CORRECT - Use design tokens
import 'package:weddingzon/core/theme/wz_spacing.dart';

Padding(
  padding: EdgeInsets.all(WzSpacing.space16),
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: WzSpacing.space8),
      Text('Subtitle'),
    ],
  ),
)
```

**Available Spacing:**
- `WzSpacing.space4` - 4px
- `WzSpacing.space8` - 8px
- `WzSpacing.space12` - 12px
- `WzSpacing.space16` - 16px
- `WzSpacing.space24` - 24px
- `WzSpacing.space32` - 32px
- `WzSpacing.space48` - 48px

**Related Files:**
- `lib/core/theme/wz_spacing.dart`

---

## Component Issues

### Issue 4: Button Not Responding to Taps

**Symptoms:**
- Button doesn't respond when tapped
- onPressed callback not firing
- Button appears disabled

**Causes:**
- Callback function called instead of passed
- Button is in loading state
- onPressed is null

**Solutions:**

```dart
// ❌ WRONG - Calling function instead of passing reference
WzPrimaryButton(
  text: 'Submit',
  onPressed: _handleSubmit(),  // ❌ Don't call the function
)

// ✅ CORRECT - Pass function reference
WzPrimaryButton(
  text: 'Submit',
  onPressed: _handleSubmit,  // ✅ Pass reference
)

// ✅ CORRECT - For async functions
WzPrimaryButton(
  text: 'Submit',
  onPressed: () async {
    await _handleSubmit();
  },
)

// ✅ CORRECT - Check loading state
WzPrimaryButton(
  text: 'Submit',
  onPressed: _handleSubmit,
  isLoading: false,  // Ensure not loading
)
```

**Debugging:**
```dart
WzPrimaryButton(
  text: 'Submit',
  onPressed: () {
    print('Button tapped!');  // Add debug print
    _handleSubmit();
  },
)
```

---

### Issue 5: Input Field Not Accepting Text

**Symptoms:**
- Can't type in input field
- Text doesn't appear
- Cursor doesn't show

**Causes:**
- Missing TextEditingController
- Controller not properly initialized
- Field is disabled or read-only

**Solutions:**

```dart
// ❌ WRONG - No controller
WzTextField(
  label: 'Email',
  // Missing controller
)

// ✅ CORRECT - With controller
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();  // Don't forget to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WzTextField(
      label: 'Email',
      controller: _emailController,
    );
  }
}
```

**Debugging:**
```dart
// Check controller value
print(_emailController.text);

// Listen to changes
_emailController.addListener(() {
  print('Text changed: ${_emailController.text}');
});
```

---

### Issue 6: Card Component Not Displaying Correctly

**Symptoms:**
- Card appears empty
- Card content is cut off
- Card doesn't match design

**Causes:**
- Missing required parameters
- Incorrect data passed
- Layout constraints issues

**Solutions:**

```dart
// ❌ WRONG - Missing required parameters
WzProfileCard(
  // Missing required fields
)

// ✅ CORRECT - All required parameters
WzProfileCard(
  photoUrl: user.photoUrl,
  name: user.name,
  age: user.age,
  location: user.location,
  bio: user.bio,
  onTap: () => _viewProfile(user),
)

// ✅ CORRECT - Handle null values
WzProfileCard(
  photoUrl: user.photoUrl ?? '',
  name: user.name ?? 'Unknown',
  age: user.age ?? 0,
  location: user.location ?? 'Unknown',
  bio: user.bio ?? '',
  onTap: () => _viewProfile(user),
)
```

**Debugging:**
```dart
// Check data
print('Photo URL: ${user.photoUrl}');
print('Name: ${user.name}');

// Wrap in Container to see bounds
Container(
  color: Colors.red.withOpacity(0.1),
  child: WzProfileCard(...),
)
```

---

## Navigation Issues

### Issue 7: Can't Access UI Clone Screens

**Symptoms:**
- UI clone gallery doesn't open
- Debug button not visible
- Navigation error when accessing UI clone

**Causes:**
- Not in debug mode
- Routes not registered
- Import path incorrect

**Solutions:**

```dart
// ✅ Check if in debug mode
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  // UI clone access should be visible
  print('Debug mode enabled');
}

// ✅ Navigate to UI clone gallery
import 'package:weddingzon/ui_clone/navigation/ui_clone_routes.dart';

Navigator.pushNamed(context, UiCloneRoutes.home);

// ✅ Navigate to specific screen
Navigator.pushNamed(context, UiCloneRoutes.splash);
Navigator.pushNamed(context, UiCloneRoutes.feed);
Navigator.pushNamed(context, UiCloneRoutes.profile);

// ✅ Check available routes
print(UiCloneRoutes.allScreens);
```

**Verification:**
```dart
// Test navigation
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, UiCloneRoutes.home);
  },
  child: Text('Open UI Clone'),
)
```

**Related Files:**
- `lib/ui_clone/navigation/ui_clone_routes.dart`
- `lib/ui_clone/navigation/ui_clone_home.dart`

---

### Issue 8: Navigation Between UI Clone Screens Broken

**Symptoms:**
- Can't navigate between UI clone screens
- Back button doesn't work
- Navigation stack issues

**Causes:**
- Routes not properly configured
- Using wrong navigation method
- Context issues

**Solutions:**

```dart
// ✅ Use named routes
Navigator.pushNamed(context, UiCloneRoutes.profile);

// ✅ Use MaterialPageRoute for custom navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProfileScreenUI(),
  ),
);

// ✅ Pop back
Navigator.pop(context);

// ✅ Replace current screen
Navigator.pushReplacementNamed(context, UiCloneRoutes.home);
```

---

## Asset Issues

### Issue 9: SVG Icons Not Displaying

**Symptoms:**
- Icons appear as blank spaces
- SVG rendering errors
- Icon colors incorrect

**Causes:**
- Missing flutter_svg dependency
- Incorrect asset path
- Asset not declared in pubspec.yaml
- SVG file malformed

**Solutions:**

```dart
// ✅ Check pubspec.yaml
dependencies:
  flutter_svg: ^2.0.0

flutter:
  assets:
    - assets/ui_clone/icons/

// ✅ Correct SVG usage
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/ui_clone/icons/ic_heart.svg',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(
    WzColors.iconPrimary,
    BlendMode.srcIn,
  ),
)

// ❌ WRONG - Missing assets/ prefix
SvgPicture.asset('ui_clone/icons/ic_heart.svg')

// ❌ WRONG - Wrong path
SvgPicture.asset('assets/icons/ic_heart.svg')
```

**Debugging:**
```dart
// Check if file exists
import 'dart:io';
final file = File('assets/ui_clone/icons/ic_heart.svg');
print('File exists: ${file.existsSync()}');

// Use error builder
SvgPicture.asset(
  'assets/ui_clone/icons/ic_heart.svg',
  placeholderBuilder: (context) => CircularProgressIndicator(),
)
```

**Related Files:**
- `pubspec.yaml`
- `assets/ui_clone/icons/`

---

### Issue 10: Images Not Loading

**Symptoms:**
- Images don't appear
- Placeholder images shown
- Image loading errors

**Causes:**
- Incorrect asset path
- Asset not declared in pubspec.yaml
- Network image URL issues
- Image file missing

**Solutions:**

```dart
// ✅ Local asset image
Image.asset(
  'assets/ui_clone/images/logo.png',
  width: 100,
  height: 100,
)

// ✅ Network image with error handling
Image.network(
  user.photoUrl,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.person, size: 100);
  },
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator();
  },
)

// ✅ Cached network image (recommended)
import 'package:cached_network_image/cached_network_image.dart';

CachedNetworkImage(
  imageUrl: user.photoUrl,
  width: 100,
  height: 100,
  fit: BoxFit.cover,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)
```

**Verification:**
```dart
// Check pubspec.yaml
flutter:
  assets:
    - assets/ui_clone/images/
    - assets/ui_clone/images/backgrounds/
    - assets/ui_clone/images/logos/
```

---

## Build and Compilation Issues

### Issue 11: Compilation Errors After Adding UI Clone

**Symptoms:**
- Build fails
- Import errors
- Type errors
- Missing dependencies

**Causes:**
- Missing dependencies
- Import path errors
- Dart version incompatibility
- Cache issues

**Solutions:**

```bash
# ✅ Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter run

# ✅ Check dependencies
flutter pub deps

# ✅ Analyze code
flutter analyze

# ✅ Fix formatting
dart format lib/

# ✅ Clear cache
flutter pub cache repair
```

**Common Import Errors:**

```dart
// ❌ WRONG - Incorrect import path
import 'package:weddingzon/ui_clone/wz_colors.dart';

// ✅ CORRECT - Full path
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/ui_clone/widgets/wz_inputs.dart';
import 'package:weddingzon/ui_clone/widgets/wz_cards.dart';
import 'package:weddingzon/ui_clone/widgets/wz_navigation.dart';
```

**Check Dependencies:**
```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
```

---

### Issue 12: Hot Reload Not Working

**Symptoms:**
- Changes don't appear after hot reload
- Need to restart app for changes
- Hot reload errors

**Causes:**
- Const constructors preventing rebuild
- State not updating
- Build method not being called

**Solutions:**

```dart
// ✅ Remove const for development
// During development
WzPrimaryButton(
  text: 'Submit',
  onPressed: _handleSubmit,
)

// In production (add const back)
const WzPrimaryButton(
  text: 'Submit',
  onPressed: null,
)

// ✅ Force rebuild with setState
setState(() {
  // Trigger rebuild
});

// ✅ Use hot restart instead
// Press Shift + R in terminal
// Or click hot restart button in IDE
```

---

## Visual Discrepancies

### Issue 13: Layout Doesn't Match Figma

**Symptoms:**
- Elements positioned incorrectly
- Spacing is off
- Alignment issues
- Overflow errors

**Causes:**
- Missing constraints
- Incorrect layout widgets
- Wrong flex values
- Missing Expanded/Flexible widgets

**Solutions:**

```dart
// ❌ WRONG - No constraints
Row(
  children: [
    Container(width: 1000, child: Text('Long text')),  // Overflow!
  ],
)

// ✅ CORRECT - With Expanded
Row(
  children: [
    Expanded(
      child: Text('Long text', overflow: TextOverflow.ellipsis),
    ),
  ],
)

// ✅ CORRECT - With Flexible
Row(
  children: [
    Flexible(
      flex: 2,
      child: Text('Longer text'),
    ),
    Flexible(
      flex: 1,
      child: Text('Short'),
    ),
  ],
)
```

**Debugging Layout:**
```dart
// Enable debug paint
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true;  // Show layout bounds
  runApp(MyApp());
}

// Use Flutter Inspector
// DevTools > Flutter Inspector > Select Widget Mode
```

---

### Issue 14: Colors Look Different on Device

**Symptoms:**
- Colors appear washed out
- Colors too bright or dark
- Inconsistent colors across devices

**Causes:**
- Device color profile differences
- Dark mode interference
- Theme not applied correctly

**Solutions:**

```dart
// ✅ Ensure theme is applied
MaterialApp(
  theme: WzTheme.lightTheme,
  darkTheme: WzTheme.darkTheme,
  themeMode: ThemeMode.light,  // Force light mode
  home: MyHomePage(),
)

// ✅ Disable dark mode for specific widget
Theme(
  data: ThemeData.light(),
  child: MyWidget(),
)

// ✅ Use exact color values
Container(
  color: WzColors.primary,  // Uses exact hex value
)
```

---

## Performance Issues

### Issue 15: Slow Rendering or Lag

**Symptoms:**
- App feels sluggish
- Animations stutter
- Scrolling is janky
- High memory usage

**Causes:**
- Too many rebuilds
- Large images not optimized
- Missing const constructors
- Expensive operations in build method

**Solutions:**

```dart
// ✅ Use const constructors
const WzPrimaryButton(
  text: 'Submit',
  onPressed: null,
)

// ✅ Cache expensive widgets
class MyWidget extends StatelessWidget {
  static const _header = Text('Title', style: WzTextStyles.heading1);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _header,  // Reused, not rebuilt
        _buildBody(),
      ],
    );
  }
}

// ✅ Use RepaintBoundary for complex widgets
RepaintBoundary(
  child: ComplexWidget(),
)

// ✅ Optimize images
CachedNetworkImage(
  imageUrl: url,
  memCacheWidth: 400,  // Limit memory usage
  memCacheHeight: 400,
)
```

**Profiling:**
```bash
# Run with performance overlay
flutter run --profile

# Use DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

### Issue 16: Large App Size After Adding UI Clone

**Symptoms:**
- APK/IPA size increased significantly
- Download size too large
- Storage warnings

**Causes:**
- Unoptimized assets
- Duplicate assets
- Debug symbols included

**Solutions:**

```bash
# ✅ Build release version
flutter build apk --release
flutter build appbundle --release
flutter build ios --release

# ✅ Analyze app size
flutter build apk --analyze-size
flutter build appbundle --analyze-size

# ✅ Optimize images
# Use tools like:
# - ImageOptim (Mac)
# - TinyPNG (Web)
# - pngquant (CLI)

# ✅ Remove unused assets
# Check pubspec.yaml and remove unused asset declarations
```

**Asset Optimization:**
```yaml
# pubspec.yaml - Only include needed assets
flutter:
  assets:
    - assets/ui_clone/icons/  # Only if using icons
    # - assets/ui_clone/illustrations/  # Comment out if not used
```

---

## State Management Issues

### Issue 17: State Not Updating in UI Clone Components

**Symptoms:**
- Component doesn't reflect state changes
- UI doesn't update after data changes
- Stale data displayed

**Causes:**
- Missing setState call
- State management not connected
- Component not listening to changes

**Solutions:**

```dart
// ✅ StatefulWidget with setState
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  bool _isLoading = false;

  void _handleSubmit() {
    setState(() {
      _isLoading = true;
    });
    
    // Do work...
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WzPrimaryButton(
      text: 'Submit',
      isLoading: _isLoading,
      onPressed: _handleSubmit,
    );
  }
}
```

**With Provider:**
```dart
// ✅ Using Provider
import 'package:provider/provider.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyProvider>(
      builder: (context, provider, child) {
        return WzPrimaryButton(
          text: 'Submit',
          isLoading: provider.isLoading,
          onPressed: provider.submit,
        );
      },
    );
  }
}
```

---

### Issue 18: Form Validation Not Working

**Symptoms:**
- Validation errors not showing
- Form submits with invalid data
- Error messages not displayed

**Causes:**
- Missing Form widget
- Validation not implemented
- Error text not passed to component

**Solutions:**

```dart
// ✅ Wrap in Form widget
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _emailError;

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      print('Valid!');
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@')) {
      return 'Invalid email format';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          WzTextField(
            label: 'Email',
            controller: _emailController,
            errorText: _emailError,
            keyboardType: TextInputType.emailAddress,
          ),
          WzPrimaryButton(
            text: 'Submit',
            onPressed: _handleSubmit,
          ),
        ],
      ),
    );
  }
}
```

---

## Testing Issues

### Issue 19: Widget Tests Failing After Integration

**Symptoms:**
- Tests that worked before now fail
- Can't find UI clone widgets in tests
- Theme errors in tests

**Causes:**
- Missing MaterialApp wrapper
- Theme not provided in tests
- Widget not pumped correctly

**Solutions:**

```dart
// ✅ Proper widget test setup
testWidgets('Button displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: WzTheme.lightTheme,  // Provide theme
      home: Scaffold(
        body: WzPrimaryButton(
          text: 'Submit',
          onPressed: () {},
        ),
      ),
    ),
  );

  expect(find.text('Submit'), findsOneWidget);
  expect(find.byType(WzPrimaryButton), findsOneWidget);
});

// ✅ Test with provider
testWidgets('Screen works with provider', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: WzTheme.lightTheme,
      home: ChangeNotifierProvider(
        create: (_) => MyProvider(),
        child: MyScreen(),
      ),
    ),
  );

  await tester.pumpAndSettle();
  expect(find.byType(MyScreen), findsOneWidget);
});
```

---

## Frequently Asked Questions

### Q1: Can I modify UI clone components?

**A:** It's not recommended to modify UI clone components directly. Instead:

1. **Create a wrapper component** in your own codebase
2. **Extend the component** if you need custom behavior
3. **Request changes** to the UI clone if it's a common need

```dart
// ✅ Create wrapper
class MyCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const MyCustomButton({
    Key? key,
    required this.text,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WzPrimaryButton(
      text: text,
      onPressed: onPressed,
      // Add your custom logic here
    );
  }
}
```

---

### Q2: How do I handle dark mode?

**A:** The UI clone currently supports light mode. For dark mode:

```dart
// Option 1: Force light mode
MaterialApp(
  theme: WzTheme.lightTheme,
  themeMode: ThemeMode.light,
)

// Option 2: Create dark theme (future)
// Wait for dark mode design system
MaterialApp(
  theme: WzTheme.lightTheme,
  darkTheme: WzTheme.darkTheme,  // When available
  themeMode: ThemeMode.system,
)
```

---

### Q3: Can I use UI clone components with my existing state management?

**A:** Yes! UI clone components are stateless and work with any state management:

```dart
// With Provider
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return WzPrimaryButton(
      text: 'Submit',
      isLoading: provider.isLoading,
      onPressed: provider.submit,
    );
  },
)

// With Riverpod
final isLoadingProvider = StateProvider<bool>((ref) => false);

Consumer(
  builder: (context, ref, child) {
    final isLoading = ref.watch(isLoadingProvider);
    return WzPrimaryButton(
      text: 'Submit',
      isLoading: isLoading,
      onPressed: () => ref.read(isLoadingProvider.notifier).state = true,
    );
  },
)

// With BLoC
BlocBuilder<MyBloc, MyState>(
  builder: (context, state) {
    return WzPrimaryButton(
      text: 'Submit',
      isLoading: state.isLoading,
      onPressed: () => context.read<MyBloc>().add(SubmitEvent()),
    );
  },
)
```

---

### Q4: What if a component I need doesn't exist?

**A:** You have several options:

1. **Check if it exists** in the UI clone
2. **Compose existing components** to create what you need
3. **Create your own component** following the design system
4. **Request the component** to be added to UI clone

```dart
// Example: Compose existing components
class MyCustomCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(WzSpacing.space16),
      decoration: BoxDecoration(
        color: WzColors.backgroundCard,
        borderRadius: BorderRadius.circular(WzBorderRadius.radiusMedium),
      ),
      child: Column(
        children: [
          Text('Title', style: WzTextStyles.heading3),
          SizedBox(height: WzSpacing.space8),
          Text('Content', style: WzTextStyles.body2),
        ],
      ),
    );
  }
}
```

---

### Q5: How do I debug visual discrepancies?

**A:** Follow this debugging process:

1. **Compare with Figma** - Open the design side-by-side
2. **Check design tokens** - Verify colors, spacing, typography
3. **Use Flutter Inspector** - Check widget tree and properties
4. **Enable debug paint** - See layout bounds
5. **Take screenshots** - Compare pixel-by-pixel

```dart
// Enable debug tools
import 'package:flutter/rendering.dart';

void main() {
  debugPaintSizeEnabled = true;
  debugPaintBaselinesEnabled = true;
  debugPaintPointersEnabled = true;
  runApp(MyApp());
}
```

---

### Q6: Can I use UI clone in production?

**A:** Yes, but consider:

1. **Test thoroughly** - Ensure all functionality works
2. **Performance test** - Check app performance
3. **QA approval** - Get designer/QA sign-off
4. **Gradual rollout** - Use feature flags
5. **Monitor** - Watch for issues after deployment

```dart
// Use feature flag
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (FeatureFlags.useNewUI) {
      return _buildWithUIClone();
    } else {
      return _buildOldUI();
    }
  }
}
```

---

### Q7: How do I handle responsive design?

**A:** UI clone components are responsive by default, but you can customize:

```dart
// Use MediaQuery for responsive sizing
final screenWidth = MediaQuery.of(context).size.width;
final isTablet = screenWidth > 600;

WzPrimaryButton(
  text: 'Submit',
  width: isTablet ? 400 : double.infinity,
)

// Use LayoutBuilder
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return _buildTabletLayout();
    } else {
      return _buildMobileLayout();
    }
  },
)
```

---

### Q8: What about accessibility?

**A:** UI clone components follow Flutter accessibility best practices:

```dart
// Components have semantic labels
WzPrimaryButton(
  text: 'Submit',  // Automatically has semantic label
  onPressed: _submit,
)

// Add custom semantics if needed
Semantics(
  label: 'Submit form',
  button: true,
  child: WzPrimaryButton(
    text: 'Submit',
    onPressed: _submit,
  ),
)
```

---

### Q9: How do I update the UI clone?

**A:** The UI clone is part of your codebase:

1. **Pull latest changes** from repository
2. **Review changelog** for breaking changes
3. **Update your code** if needed
4. **Test thoroughly** after update
5. **Deploy** when ready

```bash
# Update from repository
git pull origin main

# Check for breaking changes
git log --oneline lib/ui_clone/

# Run tests
flutter test
```

---

### Q10: Where can I get help?

**A:** Resources for help:

1. **This troubleshooting guide** - Common issues and solutions
2. **Component documentation** - `lib/ui_clone/COMPONENTS.md`
3. **Integration guides** - Reference, Replace, Gradual strategies
4. **Team members** - Ask developers who've used UI clone
5. **Code examples** - Check existing implementations
6. **Issue tracker** - Report bugs or request features

---

## Quick Reference

### Common Import Paths

```dart
// Design System
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/core/theme/wz_theme.dart';

// Components
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/ui_clone/widgets/wz_inputs.dart';
import 'package:weddingzon/ui_clone/widgets/wz_cards.dart';
import 'package:weddingzon/ui_clone/widgets/wz_navigation.dart';

// Screens
import 'package:weddingzon/ui_clone/screens/splash_screen_ui.dart';
import 'package:weddingzon/ui_clone/screens/feed_screen_ui.dart';
import 'package:weddingzon/ui_clone/screens/profile_screen_ui.dart';

// Navigation
import 'package:weddingzon/ui_clone/navigation/ui_clone_routes.dart';
import 'package:weddingzon/ui_clone/navigation/ui_clone_home.dart';
```

### Common Commands

```bash
# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Analyze code
flutter analyze

# Format code
dart format lib/

# Run tests
flutter test

# Build release
flutter build apk --release
flutter build appbundle --release
flutter build ios --release

# Check app size
flutter build apk --analyze-size
```

### Debugging Checklist

When something doesn't work:

- [ ] Check import paths
- [ ] Verify design tokens used correctly
- [ ] Check required parameters passed
- [ ] Verify callbacks connected properly
- [ ] Check state management
- [ ] Run `flutter clean && flutter pub get`
- [ ] Check Flutter/Dart version
- [ ] Review error messages carefully
- [ ] Check this troubleshooting guide
- [ ] Ask for help if stuck

---

## Conclusion

This troubleshooting guide covers the most common issues encountered when integrating the UI clone. If you encounter an issue not covered here:

1. Check the related documentation
2. Review code examples in the UI clone
3. Ask team members for help
4. Create an issue in the project tracker

Remember: Integration is a gradual process. Take your time, test thoroughly, and don't hesitate to ask for help!

## Related Documentation

- [Component Documentation](COMPONENTS.md)
- [Reference Integration Strategy](INTEGRATION_REFERENCE.md)
- [Replace Integration Strategy](INTEGRATION_REPLACE.md)
- [Gradual Adoption Strategy](INTEGRATION_GRADUAL.md)
- [How to View UI Clone](HOW_TO_VIEW.md)

---

**Last Updated:** February 2026  
**Version:** 1.0.0
