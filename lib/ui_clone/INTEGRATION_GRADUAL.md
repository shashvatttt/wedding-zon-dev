# Integration Strategy: Gradual Adoption

## Overview

The **Gradual Adoption** integration strategy allows you to incrementally adopt UI clone components into your existing screens without replacing entire screens. This is the safest and most flexible approach, letting you migrate at your own pace while maintaining full control over your application.

## Use Cases

- ✅ Incremental UI improvements
- ✅ Screens with complex business logic
- ✅ Risk-averse migration
- ✅ Learning the design system gradually
- ✅ Testing components before full adoption
- ✅ Maintaining existing functionality while improving UI
- ✅ Team onboarding and training

## How It Works

You keep your existing screen structure but gradually replace individual widgets with UI clone components. Start with simple components (buttons, inputs) and progressively adopt more complex ones (cards, lists).

## Implementation

### Step 1: Import Design System

Start by importing the design system into your existing screens:

```dart
// Add these imports to your existing screen
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
```

### Step 2: Replace Hardcoded Values

Replace hardcoded values with design system constants:

```dart
// BEFORE
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Color(0xFFE63E62),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
  ),
)

// AFTER
Container(
  padding: EdgeInsets.all(WzSpacing.space16),
  decoration: BoxDecoration(
    color: WzColors.primary,
    borderRadius: BorderRadius.circular(WzBorderRadius.radiusMedium),
  ),
  child: Text(
    'Hello',
    style: WzTextStyles.body1Semibold,
  ),
)
```

### Step 3: Replace Simple Components

Start with buttons - they're the easiest to replace:

```dart
// BEFORE
ElevatedButton(
  onPressed: _handleSubmit,
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFE63E62),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  child: Text('Submit'),
)

// AFTER
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';

WzPrimaryButton(
  text: 'Submit',
  onPressed: _handleSubmit,
)
```

### Step 4: Replace Input Fields

Next, replace input fields:

```dart
// BEFORE
TextField(
  controller: _emailController,
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
    border: OutlineInputBorder(),
  ),
)

// AFTER
import 'package:weddingzon/ui_clone/widgets/wz_inputs.dart';

WzTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: _emailController,
  keyboardType: TextInputType.emailAddress,
)
```

### Step 5: Replace Complex Components

Finally, replace cards and other complex components:

```dart
// BEFORE
Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(user.photoUrl)),
        SizedBox(height: 8),
        Text(user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(user.bio, style: TextStyle(fontSize: 14)),
      ],
    ),
  ),
)

// AFTER
import 'package:weddingzon/ui_clone/widgets/wz_cards.dart';

WzProfileCard(
  photoUrl: user.photoUrl,
  name: user.name,
  bio: user.bio,
  onTap: () => _viewProfile(user),
)
```

## Migration Levels

### Level 1: Design Tokens Only (Easiest)

Replace hardcoded values with design system constants. No component changes.

**Effort**: Low (1-2 hours per screen)
**Risk**: Minimal
**Benefit**: Consistency, easier maintenance

```dart
// Your existing widgets, but with design tokens
Container(
  padding: EdgeInsets.all(WzSpacing.space16),  // ✅ Design token
  decoration: BoxDecoration(
    color: WzColors.primary,  // ✅ Design token
  ),
  child: Text(
    'Hello',
    style: WzTextStyles.body1,  // ✅ Design token
  ),
)
```

### Level 2: Simple Components (Easy)

Replace buttons and inputs with UI clone components.

**Effort**: Medium (2-4 hours per screen)
**Risk**: Low
**Benefit**: Consistent interactions, less code

```dart
// Replace buttons
WzPrimaryButton(text: 'Submit', onPressed: _handleSubmit)
WzSecondaryButton(text: 'Cancel', onPressed: _handleCancel)

// Replace inputs
WzTextField(label: 'Email', controller: _emailController)
WzPasswordField(label: 'Password', controller: _passwordController)
```

### Level 3: Complex Components (Medium)

Replace cards, lists, and navigation elements.

**Effort**: High (4-8 hours per screen)
**Risk**: Medium
**Benefit**: Significant code reduction, better UX

```dart
// Replace cards
WzProfileCard(user: user, onTap: _viewProfile)
WzProductCard(product: product, onAddToCart: _addToCart)

// Replace navigation
WzBottomNavBar(currentIndex: _currentIndex, onTap: _onNavTap)
WzAppBar(title: 'Profile', actions: [_buildMenuButton()])
```

### Level 4: Screen Sections (Advanced)

Replace entire sections of screens with UI clone sections.

**Effort**: Very High (8-16 hours per screen)
**Risk**: High
**Benefit**: Near pixel-perfect UI, minimal custom code

```dart
// Replace entire sections
WzProfileHeader(user: user, onEdit: _editProfile)
WzFeedList(users: users, onLike: _handleLike, onReject: _handleReject)
WzChatMessageList(messages: messages, onSend: _sendMessage)
```

## Complete Examples

### Example 1: Login Screen (Level 2 Migration)

**Original Code:**
```dart
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 48),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    // Login logic...
    setState(() => _isLoading = false);
  }
}
```

**After Gradual Migration:**
```dart
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';
import 'package:weddingzon/ui_clone/widgets/wz_inputs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.backgroundDefault,  // ✅ Design token
      body: Padding(
        padding: EdgeInsets.all(WzSpacing.space24),  // ✅ Design token
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back',
              style: WzTextStyles.heading1,  // ✅ Design token
            ),
            SizedBox(height: WzSpacing.space48),  // ✅ Design token
            
            // ✅ UI clone component
            WzTextField(
              label: 'Email',
              hint: 'Enter your email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            
            SizedBox(height: WzSpacing.space16),  // ✅ Design token
            
            // ✅ UI clone component
            WzPasswordField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
            ),
            
            SizedBox(height: WzSpacing.space24),  // ✅ Design token
            
            // ✅ UI clone component
            WzPrimaryButton(
              text: 'Login',
              onPressed: _handleLogin,
              isLoading: _isLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    // Login logic remains unchanged
    setState(() => _isLoading = false);
  }
}
```

**Changes Made:**
- ✅ Replaced hardcoded colors with `WzColors`
- ✅ Replaced hardcoded text styles with `WzTextStyles`
- ✅ Replaced hardcoded spacing with `WzSpacing`
- ✅ Replaced `TextField` with `WzTextField` and `WzPasswordField`
- ✅ Replaced `ElevatedButton` with `WzPrimaryButton`
- ✅ Business logic remains unchanged
- ✅ State management remains unchanged

### Example 2: Profile Screen (Level 3 Migration)

**Original Code:**
```dart
class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(user.photoUrl),
                  ),
                  SizedBox(height: 16),
                  Text(
                    user.name,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.bio,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Age', user.age.toString()),
                _buildStat('Height', user.height),
                _buildStat('Location', user.city),
              ],
            ),
            
            // Details sections
            _buildSection('About', user.about),
            _buildSection('Education', user.education),
            _buildSection('Profession', user.profession),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(content, style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile/edit');
  }
}
```

**After Gradual Migration:**
```dart
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/core/theme/wz_text_styles.dart';
import 'package:weddingzon/core/theme/wz_spacing.dart';
import 'package:weddingzon/ui_clone/widgets/wz_cards.dart';
import 'package:weddingzon/ui_clone/widgets/wz_navigation.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.backgroundDefault,  // ✅ Design token
      
      // ✅ UI clone component
      appBar: WzAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: WzColors.iconPrimary),
            onPressed: () => _editProfile(context),
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ UI clone component
            WzProfileHeader(
              photoUrl: user.photoUrl,
              name: user.name,
              bio: user.bio,
              onPhotoTap: () => _viewPhotos(context),
            ),
            
            SizedBox(height: WzSpacing.space16),  // ✅ Design token
            
            // ✅ UI clone component
            WzProfileStats(
              stats: [
                ProfileStat(label: 'Age', value: user.age.toString()),
                ProfileStat(label: 'Height', value: user.height),
                ProfileStat(label: 'Location', value: user.city),
              ],
            ),
            
            SizedBox(height: WzSpacing.space16),  // ✅ Design token
            
            // ✅ UI clone component
            WzInfoCard(
              title: 'About',
              content: user.about,
              icon: Icons.person,
            ),
            
            // ✅ UI clone component
            WzInfoCard(
              title: 'Education',
              content: user.education,
              icon: Icons.school,
            ),
            
            // ✅ UI clone component
            WzInfoCard(
              title: 'Profession',
              content: user.profession,
              icon: Icons.work,
            ),
          ],
        ),
      ),
    );
  }

  void _editProfile(BuildContext context) {
    Navigator.pushNamed(context, '/profile/edit');
  }

  void _viewPhotos(BuildContext context) {
    Navigator.pushNamed(context, '/profile/photos');
  }
}
```

**Changes Made:**
- ✅ Replaced custom AppBar with `WzAppBar`
- ✅ Replaced profile header section with `WzProfileHeader`
- ✅ Replaced stats row with `WzProfileStats`
- ✅ Replaced custom cards with `WzInfoCard`
- ✅ Removed custom `_buildStat` and `_buildSection` methods
- ✅ Reduced code by ~40%
- ✅ Business logic remains unchanged

### Example 3: Feed Screen (Level 4 Migration)

**Original Code:**
```dart
class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await UserRepository.getFeedUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Discover')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Image.network(user.photoUrl, height: 300, fit: BoxFit.cover),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('${user.age}, ${user.city}'),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _handleReject(user),
                                ),
                                IconButton(
                                  icon: Icon(Icons.favorite, color: Colors.pink),
                                  onPressed: () => _handleLike(user),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _handleLike(User user) async {
    await UserRepository.likeUser(user.id);
    setState(() => _users.remove(user));
  }

  void _handleReject(User user) {
    setState(() => _users.remove(user));
  }
}
```

**After Gradual Migration:**
```dart
import 'package:flutter/material.dart';
import 'package:weddingzon/core/theme/wz_colors.dart';
import 'package:weddingzon/ui_clone/widgets/wz_navigation.dart';
import 'package:weddingzon/ui_clone/widgets/wz_cards.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await UserRepository.getFeedUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WzColors.backgroundDefault,  // ✅ Design token
      
      // ✅ UI clone component
      appBar: WzAppBar(
        title: 'Discover',
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: WzColors.iconPrimary),
            onPressed: _showFilters,
          ),
        ],
      ),
      
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: WzColors.primary))
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                
                // ✅ UI clone component - replaces entire card structure
                return WzFeedCard(
                  user: user,
                  onLike: () => _handleLike(user),
                  onReject: () => _handleReject(user),
                  onViewProfile: () => _viewProfile(user),
                );
              },
            ),
    );
  }

  void _handleLike(User user) async {
    await UserRepository.likeUser(user.id);
    setState(() => _users.remove(user));
  }

  void _handleReject(User user) {
    setState(() => _users.remove(user));
  }

  void _viewProfile(User user) {
    Navigator.pushNamed(context, '/profile/user', arguments: user.username);
  }

  void _showFilters() {
    // Show filter bottom sheet
  }
}
```

**Changes Made:**
- ✅ Replaced custom AppBar with `WzAppBar`
- ✅ Replaced entire card structure with `WzFeedCard`
- ✅ Removed all custom card building code
- ✅ Reduced code by ~60%
- ✅ Business logic remains unchanged
- ✅ State management remains unchanged
- ✅ Pixel-perfect match with Figma design

## Migration Workflow

### Week-by-Week Migration Plan

**Week 1: Design Tokens**
- Day 1-2: Import design system into all screens
- Day 3-4: Replace hardcoded colors with `WzColors`
- Day 5: Replace hardcoded text styles with `WzTextStyles`

**Week 2: Simple Components**
- Day 1-2: Replace all buttons with `WzButton` components
- Day 3-4: Replace all input fields with `WzTextField` components
- Day 5: Test and fix issues

**Week 3: Complex Components**
- Day 1-2: Replace cards with `WzCard` components
- Day 3-4: Replace navigation with `WzNavigation` components
- Day 5: Test and fix issues

**Week 4: Screen Sections**
- Day 1-3: Replace large screen sections with UI clone sections
- Day 4-5: Final testing and polish

### Component Priority Order

1. **High Priority** (Replace first)
   - Buttons (WzPrimaryButton, WzSecondaryButton)
   - Input fields (WzTextField, WzPasswordField)
   - Colors (WzColors.*)
   - Text styles (WzTextStyles.*)
   - Spacing (WzSpacing.*)

2. **Medium Priority** (Replace second)
   - Cards (WzProfileCard, WzProductCard)
   - Navigation (WzAppBar, WzBottomNavBar)
   - Lists (WzUserList, WzProductList)

3. **Low Priority** (Replace last)
   - Complex sections (WzProfileHeader, WzFeedList)
   - Custom components
   - Edge cases

### Screen Priority Order

1. **Start with simple screens:**
   - Splash screen
   - About screen
   - Settings screen

2. **Then move to form screens:**
   - Login screen
   - Signup screen
   - Profile edit screens

3. **Finally tackle complex screens:**
   - Feed screen
   - Chat screen
   - Explore screen

## Best Practices

### DO ✅

- ✅ Start with design tokens before components
- ✅ Migrate one component type at a time
- ✅ Test after each migration step
- ✅ Keep business logic separate
- ✅ Document changes as you go
- ✅ Get team buy-in before starting
- ✅ Create a migration checklist
- ✅ Use feature flags for gradual rollout
- ✅ Maintain backward compatibility
- ✅ Review with designers regularly

### DON'T ❌

- ❌ Try to migrate everything at once
- ❌ Skip testing between steps
- ❌ Mix business logic with UI components
- ❌ Modify UI clone components directly
- ❌ Ignore design system guidelines
- ❌ Deploy without QA approval
- ❌ Forget to update documentation
- ❌ Rush the migration process

## Component Replacement Guide

### Buttons

| Old Code | New Code | Notes |
|----------|----------|-------|
| `ElevatedButton` | `WzPrimaryButton` | Primary actions |
| `OutlinedButton` | `WzSecondaryButton` | Secondary actions |
| `TextButton` | `WzTextButton` | Tertiary actions |
| `IconButton` | `WzIconButton` | Icon-only actions |

**Example:**
```dart
// Before
ElevatedButton(
  onPressed: _submit,
  child: Text('Submit'),
)

// After
WzPrimaryButton(
  text: 'Submit',
  onPressed: _submit,
)
```

### Input Fields

| Old Code | New Code | Notes |
|----------|----------|-------|
| `TextField` | `WzTextField` | Standard text input |
| `TextField(obscureText: true)` | `WzPasswordField` | Password input |
| `DropdownButton` | `WzDropdown` | Dropdown selection |
| Date picker | `WzDatePicker` | Date selection |

**Example:**
```dart
// Before
TextField(
  controller: _controller,
  decoration: InputDecoration(labelText: 'Email'),
)

// After
WzTextField(
  label: 'Email',
  controller: _controller,
  keyboardType: TextInputType.emailAddress,
)
```

### Cards

| Old Code | New Code | Notes |
|----------|----------|-------|
| Custom profile card | `WzProfileCard` | User profiles |
| Custom product card | `WzProductCard` | Products/services |
| Custom info card | `WzInfoCard` | Information display |
| Custom list tile | `WzListTile` | List items |

**Example:**
```dart
// Before
Card(
  child: ListTile(
    leading: CircleAvatar(backgroundImage: NetworkImage(user.photo)),
    title: Text(user.name),
    subtitle: Text(user.bio),
    onTap: () => _viewProfile(user),
  ),
)

// After
WzProfileCard(
  photoUrl: user.photo,
  name: user.name,
  bio: user.bio,
  onTap: () => _viewProfile(user),
)
```

### Navigation

| Old Code | New Code | Notes |
|----------|----------|-------|
| `AppBar` | `WzAppBar` | Top app bar |
| `BottomNavigationBar` | `WzBottomNavBar` | Bottom navigation |
| `Drawer` | `WzDrawer` | Side drawer |
| `TabBar` | `WzTabBar` | Tabs |

**Example:**
```dart
// Before
AppBar(
  title: Text('Profile'),
  actions: [IconButton(icon: Icon(Icons.settings), onPressed: _settings)],
)

// After
WzAppBar(
  title: 'Profile',
  actions: [
    IconButton(
      icon: Icon(Icons.settings, color: WzColors.iconPrimary),
      onPressed: _settings,
    ),
  ],
)
```

## Testing Strategy

### Unit Testing

Test each migrated component:

```dart
testWidgets('WzPrimaryButton displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
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
```

### Integration Testing

Test migrated screens:

```dart
testWidgets('Login screen works with UI clone components', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Navigate to login
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  
  // Test UI clone components
  expect(find.byType(WzTextField), findsNWidgets(2));
  expect(find.byType(WzPrimaryButton), findsOneWidget);
  
  // Test functionality
  await tester.enterText(find.byType(WzTextField).first, 'test@example.com');
  await tester.enterText(find.byType(WzTextField).last, 'password123');
  await tester.tap(find.byType(WzPrimaryButton));
  await tester.pumpAndSettle();
  
  // Verify navigation
  expect(find.text('Home'), findsOneWidget);
});
```

### Visual Regression Testing

Compare before and after:

```dart
testWidgets('Profile screen matches golden file', (tester) async {
  await tester.pumpWidget(ProfileScreen(user: mockUser));
  await expectLater(
    find.byType(ProfileScreen),
    matchesGoldenFile('profile_screen_after_migration.png'),
  );
});
```

## Migration Checklist

### Pre-Migration

- [ ] Review UI clone components documentation
- [ ] Identify screens to migrate
- [ ] Create migration plan with timeline
- [ ] Get team approval
- [ ] Set up feature flags (optional)
- [ ] Create backup branch
- [ ] Document current state

### During Migration

**For Each Screen:**

- [ ] Import design system
- [ ] Replace hardcoded colors with `WzColors`
- [ ] Replace hardcoded text styles with `WzTextStyles`
- [ ] Replace hardcoded spacing with `WzSpacing`
- [ ] Replace buttons with `WzButton` components
- [ ] Replace inputs with `WzTextField` components
- [ ] Replace cards with `WzCard` components
- [ ] Replace navigation with `WzNavigation` components
- [ ] Test functionality
- [ ] Test on multiple devices
- [ ] Get designer approval
- [ ] Get QA approval
- [ ] Update tests
- [ ] Update documentation

### Post-Migration

- [ ] Run all tests
- [ ] Verify no regressions
- [ ] Update style guide
- [ ] Train team on new components
- [ ] Monitor for issues
- [ ] Gather feedback
- [ ] Plan next migration phase

## Troubleshooting

### Issue: Component doesn't match design

**Solution:**
```dart
// Check if you're using the correct component variant
WzPrimaryButton(...)  // For primary actions
WzSecondaryButton(...)  // For secondary actions

// Check if you're passing all required parameters
WzTextField(
  label: 'Email',  // ✅ Required
  hint: 'Enter email',  // ✅ Recommended
  controller: _controller,  // ✅ Required
)
```

### Issue: Spacing looks wrong

**Solution:**
```dart
// Use design system spacing constants
SizedBox(height: WzSpacing.space16)  // ✅ Correct
SizedBox(height: 16)  // ❌ Wrong

// Check spacing scale
WzSpacing.space4   // 4px
WzSpacing.space8   // 8px
WzSpacing.space12  // 12px
WzSpacing.space16  // 16px
WzSpacing.space24  // 24px
WzSpacing.space32  // 32px
WzSpacing.space48  // 48px
```

### Issue: Colors don't match

**Solution:**
```dart
// Use design system colors
color: WzColors.primary  // ✅ Correct
color: Color(0xFFE63E62)  // ❌ Wrong

// Check color palette
WzColors.primary
WzColors.secondary
WzColors.backgroundDefault
WzColors.textPrimary
WzColors.textSecondary
```

### Issue: Text styles don't match

**Solution:**
```dart
// Use design system text styles
style: WzTextStyles.heading1  // ✅ Correct
style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)  // ❌ Wrong

// Check text style hierarchy
WzTextStyles.heading1  // 32px, bold
WzTextStyles.heading2  // 24px, bold
WzTextStyles.heading3  // 20px, semibold
WzTextStyles.body1     // 16px, regular
WzTextStyles.body2     // 14px, regular
WzTextStyles.caption   // 12px, regular
```

### Issue: Component callback not working

**Solution:**
```dart
// Ensure callbacks are properly connected
WzPrimaryButton(
  text: 'Submit',
  onPressed: _handleSubmit,  // ✅ Pass function reference
  // onPressed: _handleSubmit(),  // ❌ Don't call function
)

// For async callbacks
onPressed: () async {
  await _handleSubmit();
}
```

### Issue: State not updating

**Solution:**
```dart
// Use setState for StatefulWidget
void _handleChange(String value) {
  setState(() {
    _value = value;
  });
}

// Or use state management (Provider, Riverpod, etc.)
final provider = context.read<MyProvider>();
provider.updateValue(value);
```

## Performance Considerations

### Optimization Tips

1. **Use const constructors:**
```dart
// ✅ Good - const constructor
const WzPrimaryButton(
  text: 'Submit',
  onPressed: null,  // Static callback
)

// ❌ Avoid - non-const when possible
WzPrimaryButton(
  text: 'Submit',
  onPressed: _handleSubmit,  // Dynamic callback
)
```

2. **Avoid rebuilding entire screens:**
```dart
// ✅ Good - only rebuild what changes
Consumer<MyProvider>(
  builder: (context, provider, child) {
    return WzPrimaryButton(
      text: 'Submit',
      isLoading: provider.isLoading,
      onPressed: _handleSubmit,
    );
  },
)

// ❌ Avoid - rebuilds entire screen
setState(() {
  _isLoading = true;
});
```

3. **Cache expensive widgets:**
```dart
// ✅ Good - cache static widgets
late final _header = WzAppBar(
  title: 'Profile',
  actions: [_buildMenuButton()],
);

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _header,
    body: _buildBody(),
  );
}
```

### Memory Management

1. **Dispose controllers:**
```dart
@override
void dispose() {
  _emailController.dispose();
  _passwordController.dispose();
  super.dispose();
}
```

2. **Use keys for lists:**
```dart
ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    return WzProfileCard(
      key: ValueKey(users[index].id),  // ✅ Add key
      user: users[index],
      onTap: _viewProfile,
    );
  },
)
```

## Rollback Strategy

If migration causes issues, you can rollback:

### Option 1: Git Revert

```bash
# Revert specific commit
git revert <commit-hash>

# Revert to previous state
git reset --hard HEAD~1
```

### Option 2: Feature Flag

```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use feature flag to toggle between old and new UI
    if (FeatureFlags.useNewUI) {
      return _buildNewUI();  // With UI clone components
    } else {
      return _buildOldUI();  // Original implementation
    }
  }

  Widget _buildNewUI() {
    return Scaffold(
      body: Column(
        children: [
          WzTextField(label: 'Email', controller: _emailController),
          WzPrimaryButton(text: 'Login', onPressed: _handleLogin),
        ],
      ),
    );
  }

  Widget _buildOldUI() {
    return Scaffold(
      body: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          ElevatedButton(
            onPressed: _handleLogin,
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

### Option 3: Gradual Rollout

```dart
// Use A/B testing to gradually roll out
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().userId;
    final useNewUI = _shouldUseNewUI(userId);
    
    if (useNewUI) {
      return _buildNewUI();
    } else {
      return _buildOldUI();
    }
  }

  bool _shouldUseNewUI(String userId) {
    // Roll out to 10% of users
    return userId.hashCode % 10 == 0;
  }
}
```

## Pros and Cons

### ✅ Advantages

1. **Low Risk**: Incremental changes reduce risk
2. **Flexible**: Migrate at your own pace
3. **Reversible**: Easy to rollback if needed
4. **Learning**: Team learns gradually
5. **Testing**: Test each step thoroughly
6. **Control**: Full control over migration
7. **Compatibility**: Maintains existing functionality
8. **Budget Friendly**: Spread cost over time

### ⚠️ Limitations

1. **Time Consuming**: Takes longer than full replacement
2. **Inconsistency**: Mixed old/new UI during migration
3. **Maintenance**: Two codebases to maintain temporarily
4. **Complexity**: More complex than full replacement
5. **Discipline Required**: Need consistent approach
6. **Documentation**: More documentation needed

## Success Metrics

Track these metrics during migration:

### Code Quality
- Lines of code reduced
- Code duplication reduced
- Dart analyzer warnings reduced
- Test coverage maintained/improved

### Visual Quality
- Design system adoption rate
- Pixel-perfect match percentage
- Designer approval rate
- User feedback scores

### Performance
- Build time
- App size
- Frame rate
- Memory usage

### Team Productivity
- Development time per screen
- Bug count
- Code review time
- Team satisfaction

## Conclusion

Gradual adoption is the **safest and most flexible** integration strategy. It allows you to migrate at your own pace while maintaining full control and minimizing risk. Start with design tokens, move to simple components, then tackle complex components and screen sections.

## Next Steps

1. ✅ Review this guide thoroughly
2. ✅ Create your migration plan
3. ✅ Start with design tokens
4. ✅ Migrate simple components
5. ✅ Test after each step
6. ✅ Get team feedback
7. ⏭️ Consider full replacement for new screens (see INTEGRATION_REPLACE.md)

## Related Documentation

- [Reference Strategy](INTEGRATION_REFERENCE.md) - Use UI clone as visual reference
- [Replace Strategy](INTEGRATION_REPLACE.md) - Complete screen replacement
- [Component Documentation](COMPONENTS.md) - All available components
- [How to View UI Clone](HOW_TO_VIEW.md) - Accessing the UI clone
- [Design System Guide](../core/theme/README.md) - Design tokens reference

## Support

If you encounter issues during migration:

1. Check this troubleshooting guide
2. Review component documentation
3. Compare with UI clone reference
4. Ask team for help
5. Create issue in project tracker

Happy migrating! 🚀
