# Integration Strategy: Replace Mode

## Overview

The **Replace Mode** integration strategy involves completely replacing existing screens with UI clone screens. This provides the fastest path to a pixel-perfect UI but requires careful planning and testing.

## Use Cases

- ✅ Complete UI redesign
- ✅ Screens with significant visual discrepancies
- ✅ New features without existing implementation
- ✅ Screens with minimal business logic
- ✅ Prototyping and demos
- ✅ Screens that need urgent visual updates

## How It Works

You replace your existing screen widget with the UI clone version, then add back the business logic, state management, and navigation.

## Implementation

### Step 1: Identify Candidate Screens

Good candidates for replacement:
- ✅ Screens with simple business logic
- ✅ Screens with significant visual issues
- ✅ Screens that are rarely changed
- ✅ Screens with clear separation of UI and logic

Poor candidates:
- ❌ Screens with complex state management
- ❌ Screens with heavy business logic
- ❌ Screens with many integrations
- ❌ Critical user flows (until tested)

### Step 2: Backup Existing Code

```bash
# Create a backup branch
git checkout -b backup/old-splash-screen

# Or copy the file
cp lib/features/splash/screens/splash_screen.dart \
   lib/features/splash/screens/splash_screen.backup.dart
```

### Step 3: Replace the Screen

**Option A: Direct Replacement**

```dart
// BEFORE: lib/features/splash/screens/splash_screen.dart
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Your existing implementation
    return Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
  }
}

// AFTER: Replace with UI clone
import 'package:flutter/material.dart';
import 'package:weddingzon/ui_clone/screens/splash_screen_ui.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use UI clone directly
    return const SplashScreenUI();
  }
}
```

**Option B: Wrapper with Logic**

```dart
// lib/features/splash/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/ui_clone/screens/splash_screen_ui.dart';
import '../providers/splash_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final provider = context.read<SplashProvider>();
    await provider.initialize();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI clone handles all visual aspects
    return const SplashScreenUI();
  }
}
```

### Step 4: Add Business Logic

Integrate your business logic around the UI clone:

```dart
// Example: Login screen with business logic
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/ui_clone/screens/mobile_login_screen_ui.dart';
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/ui_clone/widgets/wz_inputs.dart';
import '../providers/auth_provider.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({Key? key}) : super(key: key);

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.sendOTP(_phoneController.text);
      
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/auth/otp',
          arguments: _phoneController.text,
        );
      }
    } catch (e) {
      setState(() {
        _errorText = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use UI clone as base, add interactive elements
    return MobileLoginScreenUI(
      phoneController: _phoneController,
      errorText: _errorText,
      isLoading: _isLoading,
      onSubmit: _handleLogin,
    );
  }
}
```

### Step 5: Update UI Clone to Accept Callbacks

Modify the UI clone screen to accept callbacks:

```dart
// lib/ui_clone/screens/mobile_login_screen_ui.dart
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import '../widgets/wz_buttons.dart';
import '../widgets/wz_inputs.dart';

class MobileLoginScreenUI extends StatelessWidget {
  final TextEditingController? phoneController;
  final String? errorText;
  final bool isLoading;
  final VoidCallback? onSubmit;

  const MobileLoginScreenUI({
    Key? key,
    this.phoneController,
    this.errorText,
    this.isLoading = false,
    this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.backgroundDefault,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(WzSpacing.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Logo
              Center(
                child: Text(
                  'WeddingZon',
                  style: WzTextStyles.heading1,
                ),
              ),
              
              SizedBox(height: WzSpacing.space48),
              
              // Phone input
              WzTextField(
                label: 'Mobile Number',
                hint: 'Enter your mobile number',
                controller: phoneController,
                keyboardType: TextInputType.phone,
                errorText: errorText,
                prefixIcon: const Icon(Icons.phone),
              ),
              
              SizedBox(height: WzSpacing.space24),
              
              // Submit button
              WzPrimaryButton(
                text: 'Continue',
                onPressed: onSubmit,
                isLoading: isLoading,
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Step 6: Test Thoroughly

```dart
// Test the replaced screen
flutter test test/features/splash/splash_screen_test.dart

// Manual testing checklist:
// ✅ Screen renders correctly
// ✅ Business logic works
// ✅ Navigation works
// ✅ State management works
// ✅ Error handling works
// ✅ Loading states work
// ✅ Responsive on different devices
```

## Complete Examples

### Example 1: Simple Screen Replacement

**Splash Screen** (No user interaction)

```dart
// lib/features/splash/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:weddingzon/ui_clone/screens/splash_screen_ui.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreenUI();
  }
}
```

### Example 2: Form Screen Replacement

**Profile Form** (With state management)

```dart
// lib/features/onboarding/screens/profile_basic_details_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/ui_clone/screens/profile_basic_details_ui.dart';
import '../providers/onboarding_provider.dart';

class ProfileBasicDetailsScreen extends StatefulWidget {
  const ProfileBasicDetailsScreen({Key? key}) : super(key: key);

  @override
  State<ProfileBasicDetailsScreen> createState() =>
      _ProfileBasicDetailsScreenState();
}

class _ProfileBasicDetailsScreenState extends State<ProfileBasicDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  DateTime? _dateOfBirth;
  String? _gender;
  String? _profileFor;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<OnboardingProvider>();
    await provider.saveBasicDetails(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      dateOfBirth: _dateOfBirth!,
      gender: _gender!,
      profileFor: _profileFor!,
    );

    if (mounted) {
      Navigator.pushNamed(context, '/onboarding/location');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ProfileBasicDetailsUI(
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        profileFor: _profileFor,
        onDateOfBirthChanged: (date) => setState(() => _dateOfBirth = date),
        onGenderChanged: (value) => setState(() => _gender = value),
        onProfileForChanged: (value) => setState(() => _profileFor = value),
        onSubmit: _handleSubmit,
      ),
    );
  }
}
```

### Example 3: List Screen Replacement

**Feed Screen** (With data loading)

```dart
// lib/features/feed/screens/feed_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weddingzon/ui_clone/screens/feed_screen_ui.dart';
import '../providers/feed_provider.dart';
import '../models/feed_user.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    final provider = context.read<FeedProvider>();
    await provider.loadFeed();
  }

  void _handleLike(FeedUser user) {
    final provider = context.read<FeedProvider>();
    provider.likeUser(user.id);
  }

  void _handleReject(FeedUser user) {
    final provider = context.read<FeedProvider>();
    provider.rejectUser(user.id);
  }

  void _handleViewProfile(FeedUser user) {
    Navigator.pushNamed(
      context,
      '/profile/user',
      arguments: user.username,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FeedProvider>(
      builder: (context, provider, child) {
        return FeedScreenUI(
          users: provider.users,
          isLoading: provider.isLoading,
          onLike: _handleLike,
          onReject: _handleReject,
          onViewProfile: _handleViewProfile,
          onRefresh: _loadFeed,
        );
      },
    );
  }
}
```

## Migration Checklist

### Pre-Replacement

- [ ] Identify screen to replace
- [ ] Review business logic complexity
- [ ] Create backup of existing code
- [ ] Review UI clone screen
- [ ] Plan state management approach
- [ ] Identify required callbacks
- [ ] Plan testing strategy

### During Replacement

- [ ] Replace screen widget
- [ ] Add callback parameters to UI clone
- [ ] Integrate business logic
- [ ] Add state management
- [ ] Implement navigation
- [ ] Handle error states
- [ ] Handle loading states
- [ ] Add form validation (if applicable)

### Post-Replacement

- [ ] Test all functionality
- [ ] Test on multiple devices
- [ ] Test error scenarios
- [ ] Test edge cases
- [ ] Update tests
- [ ] Update documentation
- [ ] Code review
- [ ] QA approval

## Pros and Cons

### ✅ Advantages

1. **Pixel Perfect**: Guaranteed visual accuracy
2. **Fast**: Quicker than rebuilding from scratch
3. **Consistent**: Uses design system throughout
4. **Maintainable**: Single source of truth for UI
5. **Testable**: UI and logic separated
6. **Scalable**: Easy to update design

### ⚠️ Disadvantages

1. **Risky**: Complete replacement can break things
2. **Time Consuming**: Requires careful integration
3. **Testing Required**: Extensive testing needed
4. **Learning Curve**: Team needs to understand UI clone
5. **Coupling**: Creates dependency on UI clone
6. **Migration Effort**: All screens need updating

## Best Practices

### DO ✅

- ✅ Start with simple screens
- ✅ Test thoroughly before deploying
- ✅ Keep business logic separate
- ✅ Use callbacks for interactions
- ✅ Maintain backward compatibility
- ✅ Document changes
- ✅ Get QA approval

### DON'T ❌

- ❌ Replace critical screens first
- ❌ Skip testing
- ❌ Mix business logic with UI
- ❌ Modify UI clone directly
- ❌ Deploy without review
- ❌ Forget to update tests

## Troubleshooting

### Issue: Business logic not working

**Solution:**
```dart
// Ensure callbacks are properly connected
FeedScreenUI(
  onLike: _handleLike,  // ✅ Connected
  onReject: _handleReject,  // ✅ Connected
)
```

### Issue: State not updating

**Solution:**
```dart
// Use StatefulWidget and setState
setState(() {
  _isLoading = true;
});
```

### Issue: Navigation broken

**Solution:**
```dart
// Pass navigation callbacks
ProfileScreenUI(
  onEditProfile: () {
    Navigator.pushNamed(context, '/profile/edit');
  },
)
```

### Issue: Form validation not working

**Solution:**
```dart
// Wrap in Form widget
Form(
  key: _formKey,
  child: ProfileBasicDetailsUI(...),
)
```

## Rollback Plan

If replacement causes issues:

```dart
// Option 1: Revert to backup
git checkout backup/old-splash-screen -- lib/features/splash/screens/splash_screen.dart

// Option 2: Use backup file
cp lib/features/splash/screens/splash_screen.backup.dart \
   lib/features/splash/screens/splash_screen.dart

// Option 3: Conditional rendering
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use feature flag
    if (useNewUI) {
      return const SplashScreenUI();
    } else {
      return const OldSplashScreen();
    }
  }
}
```

## Performance Considerations

### Optimization Tips

1. **Lazy Loading**: Load UI clone screens on demand
2. **Code Splitting**: Use deferred loading
3. **Caching**: Cache UI clone widgets
4. **Profiling**: Profile performance before/after

```dart
// Deferred loading example
import 'package:weddingzon/ui_clone/screens/feed_screen_ui.dart' deferred as feed_ui;

Future<void> _navigateToFeed() async {
  await feed_ui.loadLibrary();
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => feed_ui.FeedScreenUI()),
  );
}
```

## Conclusion

Replace mode provides the fastest path to a pixel-perfect UI but requires careful planning and testing. Start with simple screens, test thoroughly, and gradually replace more complex screens as you gain confidence.

## Next Steps

- ✅ Identify candidate screens for replacement
- ✅ Create backup of existing code
- ✅ Replace one screen at a time
- ✅ Test thoroughly
- ⏭️ Consider gradual adoption for complex screens (see INTEGRATION_GRADUAL.md)

## Related Documentation

- [Reference Strategy](INTEGRATION_REFERENCE.md)
- [Gradual Adoption Strategy](INTEGRATION_GRADUAL.md)
- [Troubleshooting Guide](INTEGRATION_TROUBLESHOOTING.md)
- [Component Documentation](COMPONENTS.md)
