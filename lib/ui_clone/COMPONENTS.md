# WeddingZon UI Components Documentation

This document provides comprehensive documentation for all reusable UI components extracted from the Figma design. Each component is designed to match the Figma specifications pixel-perfectly while maintaining Flutter best practices.

## Table of Contents

1. [Button Components](#button-components)
2. [Input Components](#input-components)
3. [Card Components](#card-components)
4. [Navigation Components](#navigation-components)
5. [Design System](#design-system)
6. [Usage Guidelines](#usage-guidelines)

---

## Button Components

All button components are located in `lib/ui_clone/widgets/wz_buttons.dart`.

### WzPrimaryButton

Primary action button with solid background color.

**Parameters:**
- `text` (String, required): Button label text
- `onPressed` (VoidCallback?, optional): Callback when button is tapped
- `isLoading` (bool, default: false): Shows loading spinner when true
- `icon` (Widget?, optional): Leading icon widget
- `width` (double?, optional): Custom button width (defaults to parent width)

**Visual Specifications:**
- Height: 48px
- Background: Primary color (#D4AF37)
- Text: White, button text style
- Border radius: 8px
- Padding: 16px horizontal, 12px vertical

**Code Example:**
```dart
import 'package:weddingzon/ui_clone/widgets/wz_buttons.dart';

// Basic usage
WzPrimaryButton(
  text: 'Continue',
  onPressed: () {
    print('Button pressed');
  },
)


// With loading state
WzPrimaryButton(
  text: 'Submit',
  isLoading: true,
  onPressed: () {
    // This won't be called while loading
  },
)

// With icon
WzPrimaryButton(
  text: 'Sign in with Google',
  icon: Icon(Icons.g_mobiledata, color: Colors.white),
  onPressed: () {
    // Handle Google sign in
  },
)

// Custom width
WzPrimaryButton(
  text: 'Next',
  width: 200,
  onPressed: () {
    // Navigate to next screen
  },
)

// Disabled state
WzPrimaryButton(
  text: 'Submit',
  onPressed: null, // null disables the button
)
```

---

### WzSecondaryButton

Outlined button for secondary actions.

**Parameters:**
- `text` (String, required): Button label text
- `onPressed` (VoidCallback?, optional): Callback when button is tapped
- `isLoading` (bool, default: false): Shows loading spinner when true
- `icon` (Widget?, optional): Leading icon widget
- `width` (double?, optional): Custom button width

**Visual Specifications:**
- Height: 48px
- Background: Transparent
- Border: 1px solid primary color
- Text: Primary color, button text style
- Border radius: 8px


**Code Example:**
```dart
// Basic usage
WzSecondaryButton(
  text: 'Cancel',
  onPressed: () {
    Navigator.pop(context);
  },
)

// With icon
WzSecondaryButton(
  text: 'Share Profile',
  icon: Icon(Icons.share, color: WzColors.primary),
  onPressed: () {
    // Handle share
  },
)
```

---

### WzTextButton

Text-only button for tertiary actions and links.

**Parameters:**
- `text` (String, required): Button label text
- `onPressed` (VoidCallback?, optional): Callback when button is tapped
- `textStyle` (TextStyle?, optional): Custom text style
- `underline` (bool, default: false): Adds underline decoration

**Visual Specifications:**
- No background or border
- Text: Primary color, body1 text style
- Minimal padding: 8px horizontal, 4px vertical

**Code Example:**
```dart
// Basic usage
WzTextButton(
  text: 'Forgot Password?',
  onPressed: () {
    // Navigate to password reset
  },
)

// With underline
WzTextButton(
  text: 'Terms and Conditions',
  underline: true,
  onPressed: () {
    // Show terms
  },
)

// Custom style
WzTextButton(
  text: 'Skip',
  textStyle: WzTextStyles.body2.copyWith(color: WzColors.muted),
  onPressed: () {
    // Skip action
  },
)
```


---

### WzIconButton

Circular button with icon, typically used for actions like like, reject, chat.

**Parameters:**
- `icon` (Widget, required): Icon widget to display
- `onPressed` (VoidCallback?, optional): Callback when button is tapped
- `size` (double, default: 64): Button diameter
- `backgroundColor` (Color?, optional): Custom background color
- `iconColor` (Color?, optional): Custom icon color

**Visual Specifications:**
- Shape: Circle
- Default size: 64x64px
- Background: Surface color with 28% opacity
- Border: 1px solid border color
- Icon size: 50% of button size

**Code Example:**
```dart
// Basic usage
WzIconButton(
  icon: Icon(Icons.favorite),
  onPressed: () {
    // Handle like
  },
)

// Custom size and colors
WzIconButton(
  icon: Icon(Icons.close),
  size: 48,
  backgroundColor: Colors.red.withOpacity(0.1),
  iconColor: Colors.red,
  onPressed: () {
    // Handle reject
  },
)

// Chat button
WzIconButton(
  icon: Icon(Icons.chat_bubble),
  backgroundColor: WzColors.primary.withOpacity(0.1),
  iconColor: WzColors.primary,
  onPressed: () {
    // Open chat
  },
)
```

---

## Input Components

All input components are located in `lib/ui_clone/widgets/wz_inputs.dart`.

### WzTextField

Standard text input field with label and validation support.


**Parameters:**
- `label` (String?, optional): Label text above input
- `hint` (String?, optional): Placeholder text
- `controller` (TextEditingController?, optional): Text controller
- `obscureText` (bool, default: false): Hides text for passwords
- `keyboardType` (TextInputType?, optional): Keyboard type
- `prefixIcon` (Widget?, optional): Leading icon
- `suffixIcon` (Widget?, optional): Trailing icon
- `errorText` (String?, optional): Error message to display
- `maxLines` (int?, default: 1): Maximum number of lines
- `onChanged` (ValueChanged<String>?, optional): Callback on text change

**Visual Specifications:**
- Height: Auto (based on content)
- Border: 1px solid border color
- Focus border: 2px solid primary color
- Border radius: 8px
- Padding: 12px horizontal and vertical

**Code Example:**
```dart
// Basic usage
WzTextField(
  label: 'Email',
  hint: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
)

// With controller and validation
final emailController = TextEditingController();

WzTextField(
  label: 'Email',
  hint: 'Enter your email',
  controller: emailController,
  errorText: 'Please enter a valid email',
  keyboardType: TextInputType.emailAddress,
  onChanged: (value) {
    // Validate on change
  },
)

// With icons
WzTextField(
  label: 'Search',
  hint: 'Search users...',
  prefixIcon: Icon(Icons.search, color: WzColors.muted),
  suffixIcon: IconButton(
    icon: Icon(Icons.clear),
    onPressed: () {
      // Clear text
    },
  ),
)


// Multi-line text area
WzTextField(
  label: 'About Me',
  hint: 'Tell us about yourself...',
  maxLines: 5,
)
```

---

### WzPasswordField

Password input field with visibility toggle.

**Parameters:**
- `label` (String?, optional): Label text above input
- `hint` (String?, optional): Placeholder text
- `controller` (TextEditingController?, optional): Text controller
- `errorText` (String?, optional): Error message to display
- `onChanged` (ValueChanged<String>?, optional): Callback on text change
- `validator` (FormFieldValidator<String>?, optional): Validation function

**Visual Specifications:**
- Same as WzTextField
- Includes eye icon for toggling visibility
- Text is obscured by default

**Code Example:**
```dart
// Basic usage
WzPasswordField(
  label: 'Password',
  hint: 'Enter your password',
)

// With validation
final passwordController = TextEditingController();

WzPasswordField(
  label: 'Password',
  hint: 'Enter your password',
  controller: passwordController,
  errorText: _passwordError,
  onChanged: (value) {
    setState(() {
      _passwordError = _validatePassword(value);
    });
  },
)
```

---

### WzDropdown

Dropdown selection field for choosing from predefined options.

**Parameters:**
- `label` (String?, optional): Label text above dropdown
- `hint` (String?, optional): Placeholder text
- `initialValue` (String?, optional): Initially selected value
- `items` (List<String>, required): List of options
- `onChanged` (ValueChanged<String?>?, optional): Callback on selection
- `validator` (FormFieldValidator<String>?, optional): Validation function
- `errorText` (String?, optional): Error message to display


**Code Example:**
```dart
// Basic usage
WzDropdown(
  label: 'Gender',
  hint: 'Select your gender',
  items: ['Male', 'Female', 'Other'],
  onChanged: (value) {
    print('Selected: $value');
  },
)

// With initial value
WzDropdown(
  label: 'Religion',
  initialValue: 'Hindu',
  items: ['Hindu', 'Muslim', 'Christian', 'Sikh', 'Other'],
  onChanged: (value) {
    // Handle selection
  },
)

// With validation
WzDropdown(
  label: 'Marital Status',
  hint: 'Select status',
  items: ['Never Married', 'Divorced', 'Widowed'],
  errorText: _maritalStatusError,
  onChanged: (value) {
    // Validate and update
  },
)
```

---

### WzDatePicker

Date picker field that opens a calendar dialog.

**Parameters:**
- `label` (String?, optional): Label text above field
- `hint` (String?, optional): Placeholder text
- `selectedDate` (DateTime?, optional): Currently selected date
- `firstDate` (DateTime?, optional): Earliest selectable date (default: 1900)
- `lastDate` (DateTime?, optional): Latest selectable date (default: 2100)
- `onDateSelected` (ValueChanged<DateTime>?, optional): Callback on date selection
- `errorText` (String?, optional): Error message to display
- `dateFormatter` (String Function(DateTime)?, optional): Custom date format function

**Code Example:**
```dart
DateTime? _birthDate;

WzDatePicker(
  label: 'Date of Birth',
  hint: 'Select your birth date',
  selectedDate: _birthDate,
  lastDate: DateTime.now(),
  onDateSelected: (date) {
    setState(() {
      _birthDate = date;
    });
  },
)


// Custom date format
WzDatePicker(
  label: 'Anniversary',
  selectedDate: _anniversary,
  dateFormatter: (date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  },
  onDateSelected: (date) {
    setState(() {
      _anniversary = date;
    });
  },
)
```

---

### WzSearchBar

Rounded search input with search icon.

**Parameters:**
- `hint` (String?, optional): Placeholder text (default: 'Search')
- `controller` (TextEditingController?, optional): Text controller
- `onChanged` (ValueChanged<String>?, optional): Callback on text change
- `onClear` (VoidCallback?, optional): Callback when clear button is pressed

**Visual Specifications:**
- Height: 40px
- Background: Surface color
- Border radius: 20px (fully rounded)
- Leading icon: Search icon
- Trailing icon: Clear button (when text is present)

**Code Example:**
```dart
final searchController = TextEditingController();

WzSearchBar(
  hint: 'Search users...',
  controller: searchController,
  onChanged: (query) {
    // Perform search
    _searchUsers(query);
  },
  onClear: () {
    searchController.clear();
    // Clear search results
  },
)
```

---

## Card Components

All card components are located in `lib/ui_clone/widgets/wz_cards.dart`.

### WzProfileCard

Large profile card with photo carousel and user details.

**Parameters:**
- `fullName` (String, required): User's full name
- `age` (int?, optional): User's age
- `location` (String?, optional): User's location
- `occupation` (String?, optional): User's occupation
- `religion` (String?, optional): User's religion
- `aboutMe` (String?, optional): User's bio (max 3 lines)
- `photoUrls` (List<String>, default: []): List of photo URLs
- `onTap` (VoidCallback?, optional): Callback when card is tapped
- `onShare` (VoidCallback?, optional): Callback for share button
- `readOnly` (bool, default: false): Disables interactions


**Visual Specifications:**
- Photo carousel height: 400px
- Card elevation: 4
- Border radius: 16px
- Padding: 16px
- Photo indicators: White dots at bottom
- Share button: Top-right overlay

**Code Example:**
```dart
WzProfileCard(
  fullName: 'Priya Sharma',
  age: 28,
  location: 'Mumbai, Maharashtra',
  occupation: 'Software Engineer',
  religion: 'Hindu',
  aboutMe: 'Looking for a life partner who shares similar values...',
  photoUrls: [
    'https://example.com/photo1.jpg',
    'https://example.com/photo2.jpg',
    'https://example.com/photo3.jpg',
  ],
  onTap: () {
    // Navigate to full profile
  },
  onShare: () {
    // Share profile
  },
)

// Without photos (shows placeholder)
WzProfileCard(
  fullName: 'Rahul Verma',
  age: 30,
  location: 'Delhi',
  occupation: 'Business Owner',
  photoUrls: [], // Empty list shows placeholder
  onTap: () {
    // Navigate to profile
  },
)
```

---

### WzUserCard

Medium-sized horizontal card for user lists.

**Parameters:**
- `fullName` (String, required): User's full name
- `age` (int?, optional): User's age
- `location` (String?, optional): User's location
- `aboutMe` (String?, optional): User's bio (max 2 lines)
- `avatarUrl` (String?, optional): Avatar image URL
- `onTap` (VoidCallback?, optional): Callback when card is tapped
- `showChevron` (bool, default: true): Shows right arrow icon

**Visual Specifications:**
- Card elevation: 2
- Border radius: 16px
- Padding: 16px
- Avatar size: 80px diameter
- Margin bottom: 16px


**Code Example:**
```dart
// In a ListView
ListView.builder(
  itemCount: users.length,
  itemBuilder: (context, index) {
    final user = users[index];
    return WzUserCard(
      fullName: user.name,
      age: user.age,
      location: user.location,
      aboutMe: user.bio,
      avatarUrl: user.avatarUrl,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(userId: user.id),
          ),
        );
      },
    );
  },
)

// Without chevron
WzUserCard(
  fullName: 'Amit Kumar',
  age: 32,
  location: 'Bangalore',
  showChevron: false,
  onTap: () {
    // Handle tap
  },
)
```

---

### WzNotificationCard

Card for displaying notifications with avatar and action text.

**Parameters:**
- `name` (String, required): Name of the person who triggered notification
- `action` (String, required): Action description (e.g., "sent you a")
- `typeText` (String, required): Type of notification (e.g., "connection request")
- `avatarUrl` (String?, optional): Avatar image URL
- `onTap` (VoidCallback?, optional): Callback when card is tapped

**Visual Specifications:**
- Card elevation: 0
- Border: 1px solid border color
- Border radius: 12px
- Padding: 16px
- Avatar size: 48px diameter
- Margin bottom: 12px

**Code Example:**
```dart
WzNotificationCard(
  name: 'Sneha Patel',
  action: 'sent you a',
  typeText: 'connection request',
  avatarUrl: 'https://example.com/avatar.jpg',
  onTap: () {
    // Navigate to connection request
  },
)

WzNotificationCard(
  name: 'Vikram Singh',
  action: 'viewed your',
  typeText: 'profile',
  onTap: () {
    // Show profile viewer details
  },
)
```


---

### WzRequestCard

Card for displaying connection/access requests with accept/reject buttons.

**Parameters:**
- `displayName` (String, required): Requester's name
- `occupation` (String, required): Requester's occupation
- `requestType` (String, required): Type of request ('connection', 'photo', 'details')
- `avatarUrl` (String?, optional): Avatar image URL
- `onAccept` (VoidCallback, required): Callback for accept button
- `onReject` (VoidCallback, required): Callback for reject button
- `isLoading` (bool, default: false): Disables buttons during processing

**Visual Specifications:**
- Card elevation: 0
- Border: 1px solid border color
- Border radius: 12px
- Padding: 12px
- Avatar size: 56px diameter
- Button height: 32px
- Margin bottom: 12px

**Code Example:**
```dart
WzRequestCard(
  displayName: 'Anjali Mehta',
  occupation: 'Doctor',
  requestType: 'connection',
  avatarUrl: 'https://example.com/avatar.jpg',
  onAccept: () async {
    setState(() => _isLoading = true);
    await _acceptRequest(requestId);
    setState(() => _isLoading = false);
  },
  onReject: () async {
    setState(() => _isLoading = true);
    await _rejectRequest(requestId);
    setState(() => _isLoading = false);
  },
  isLoading: _isLoading,
)

// Photo access request
WzRequestCard(
  displayName: 'Rohan Gupta',
  occupation: 'Engineer',
  requestType: 'photo',
  onAccept: () {
    // Grant photo access
  },
  onReject: () {
    // Deny photo access
  },
)
```

---

### WzConversationTile

List tile for chat conversations with unread badge.

**Parameters:**
- `displayName` (String, required): Contact's name
- `lastMessage` (String?, optional): Preview of last message
- `timestamp` (DateTime?, optional): Time of last message
- `unreadCount` (int, default: 0): Number of unread messages
- `avatarUrl` (String?, optional): Avatar image URL
- `onTap` (VoidCallback?, optional): Callback when tile is tapped


**Visual Specifications:**
- Avatar size: 56px diameter
- Padding: 16px horizontal, 4px vertical
- Unread badge: Primary color, rounded
- Time format: HH:MM for today, "Yesterday", day name, or DD/MM

**Code Example:**
```dart
// In a ListView
ListView.builder(
  itemCount: conversations.length,
  itemBuilder: (context, index) {
    final conv = conversations[index];
    return WzConversationTile(
      displayName: conv.userName,
      lastMessage: conv.lastMessage,
      timestamp: conv.timestamp,
      unreadCount: conv.unreadCount,
      avatarUrl: conv.avatarUrl,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(conversationId: conv.id),
          ),
        );
      },
    );
  },
)

// With unread messages
WzConversationTile(
  displayName: 'Priya Sharma',
  lastMessage: 'Hi! How are you?',
  timestamp: DateTime.now().subtract(Duration(minutes: 5)),
  unreadCount: 3,
  onTap: () {
    // Open chat
  },
)
```

---

## Navigation Components

All navigation components are located in `lib/ui_clone/widgets/wz_navigation.dart`.

### WzAppBar

Standard app bar matching Figma design.

**Parameters:**
- `title` (String?, optional): Title text
- `leading` (Widget?, optional): Leading widget (usually back button)
- `actions` (List<Widget>?, optional): Action buttons on the right
- `centerTitle` (bool, default: false): Centers the title
- `backgroundColor` (Color?, optional): Custom background color
- `foregroundColor` (Color?, optional): Custom text/icon color

**Visual Specifications:**
- Height: 56px
- Background: White
- Elevation: 0
- System overlay: Dark (for status bar)

**Code Example:**
```dart
Scaffold(
  appBar: WzAppBar(
    title: 'Profile',
    leading: IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Navigator.pop(context),
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          // Edit profile
        },
      ),
    ],
  ),
  body: // Your content
)


// Centered title
WzAppBar(
  title: 'Settings',
  centerTitle: true,
)

// Custom colors
WzAppBar(
  title: 'Messages',
  backgroundColor: WzColors.primary,
  foregroundColor: WzColors.white,
)
```

---

### WzBottomNav

Main bottom navigation bar.

**Parameters:**
- `currentIndex` (int, required): Currently selected tab index
- `onTap` (ValueChanged<int>, required): Callback when tab is tapped
- `items` (List<WzBottomNavItem>, required): Navigation items

**WzBottomNavItem Parameters:**
- `icon` (IconData, required): Tab icon
- `label` (String, required): Tab label

**Visual Specifications:**
- Height: 56px + safe area
- Background: White
- Shadow: Top shadow for elevation
- Selected color: Primary
- Unselected color: Muted

**Code Example:**
```dart
int _currentIndex = 0;

Scaffold(
  body: _pages[_currentIndex],
  bottomNavigationBar: WzBottomNav(
    currentIndex: _currentIndex,
    onTap: (index) {
      setState(() {
        _currentIndex = index;
      });
    },
    items: [
      WzBottomNavItem(icon: Icons.home, label: 'Home'),
      WzBottomNavItem(icon: Icons.explore, label: 'Explore'),
      WzBottomNavItem(icon: Icons.people, label: 'Connections'),
      WzBottomNavItem(icon: Icons.chat, label: 'Chat'),
      WzBottomNavItem(icon: Icons.person, label: 'Profile'),
    ],
  ),
)
```

---

### WzTabBar

Horizontal tab navigation for switching between sections.

**Parameters:**
- `tabs` (List<String>, required): Tab labels
- `currentIndex` (int, required): Currently selected tab index
- `onTap` (ValueChanged<int>, required): Callback when tab is tapped
- `isScrollable` (bool, default: false): Makes tabs scrollable

**Visual Specifications:**
- Height: 48px
- Background: White
- Border bottom: 1px solid border color
- Selected indicator: 2px bottom border in primary color


**Code Example:**
```dart
int _selectedTab = 0;

Column(
  children: [
    WzTabBar(
      tabs: ['All', 'Pending', 'Accepted'],
      currentIndex: _selectedTab,
      onTap: (index) {
        setState(() {
          _selectedTab = index;
        });
      },
    ),
    Expanded(
      child: _buildTabContent(_selectedTab),
    ),
  ],
)

// Scrollable tabs
WzTabBar(
  tabs: ['All', 'Matches', 'Requests', 'Viewed Me', 'Favorites', 'Blocked'],
  currentIndex: _selectedTab,
  isScrollable: true,
  onTap: (index) {
    setState(() {
      _selectedTab = index;
    });
  },
)
```

---

### WzDrawer

Side menu drawer for navigation and settings.

**Parameters:**
- `header` (Widget?, optional): Header widget (usually user profile)
- `items` (List<WzDrawerItem>, required): Menu items
- `onItemTap` (ValueChanged<int>?, optional): Callback when item is tapped

**WzDrawerItem Parameters:**
- `title` (String, required): Item title
- `icon` (IconData?, optional): Leading icon
- `trailing` (Widget?, optional): Trailing widget
- `isDivider` (bool, default: false): Renders as divider

**Code Example:**
```dart
Scaffold(
  drawer: WzDrawer(
    header: UserAccountsDrawerHeader(
      accountName: Text('Priya Sharma'),
      accountEmail: Text('priya@example.com'),
      currentAccountPicture: CircleAvatar(
        backgroundImage: NetworkImage('https://example.com/avatar.jpg'),
      ),
    ),
    items: [
      WzDrawerItem(
        title: 'My Profile',
        icon: Icons.person,
      ),
      WzDrawerItem(
        title: 'Settings',
        icon: Icons.settings,
      ),
      WzDrawerItem.divider(),
      WzDrawerItem(
        title: 'Help & Support',
        icon: Icons.help,
      ),
      WzDrawerItem(
        title: 'Logout',
        icon: Icons.logout,
      ),
    ],
    onItemTap: (index) {
      Navigator.pop(context); // Close drawer
      _handleDrawerItemTap(index);
    },
  ),
  body: // Your content
)
```


---

### WzStatusBar

iOS-style status bar showing time and status icons.

**Parameters:**
- `time` (String, default: '9:41'): Time to display

**Visual Specifications:**
- Height: 58px
- Padding: 16px horizontal
- Shows time on left, status icons on right

**Code Example:**
```dart
Column(
  children: [
    WzStatusBar(time: '10:30'),
    // Rest of your screen content
  ],
)

// With custom time
WzStatusBar(
  time: DateFormat('HH:mm').format(DateTime.now()),
)
```

---

## Design System

The design system provides centralized design tokens for consistent styling.

### Colors (WzColors)

Located in `lib/core/theme/wz_colors.dart`.

**Primary Colors:**
- `primary`: #D4AF37 (Gold)
- `secondary`: #FF6B9D (Pink)
- `accent`: #4CAF50 (Green)

**Neutral Colors:**
- `white`: #FFFFFF
- `black`: #000000
- `text`: #1A1A1A (Dark gray for text)
- `muted`: #757575 (Gray for secondary text)
- `border`: #E0E0E0 (Light gray for borders)
- `surface`: #F5F5F5 (Background for cards/surfaces)
- `background`: #FAFAFA (Page background)

**Semantic Colors:**
- `error`: #F44336 (Red)
- `success`: #4CAF50 (Green)
- `warning`: #FF9800 (Orange)
- `info`: #2196F3 (Blue)

**Icon Colors:**
- `iconDefault`: #757575
- `iconActive`: #D4AF37

**Usage:**
```dart
import 'package:weddingzon/core/theme/wz_colors.dart';

Container(
  color: WzColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: WzColors.white),
  ),
)
```

---

### Typography (WzTextStyles)

Located in `lib/core/theme/wz_text_styles.dart`.

**Heading Styles:**
- `heading1`: 32px, bold, -0.5 letter spacing
- `heading2`: 24px, bold, -0.5 letter spacing
- `heading3`: 20px, bold
- `heading4`: 18px, semi-bold

**Body Styles:**
- `body1`: 16px, regular
- `body2`: 14px, regular
- `caption`: 12px, regular
- `small`: 10px, regular

**Special Styles:**
- `button`: 16px, semi-bold


**Usage:**
```dart
import 'package:weddingzon/core/theme/wz_text_styles.dart';

Text('Welcome', style: WzTextStyles.heading1)
Text('Description', style: WzTextStyles.body1)
Text('Caption text', style: WzTextStyles.caption)

// With color override
Text(
  'Error message',
  style: WzTextStyles.body2.copyWith(color: WzColors.error),
)
```

---

### Spacing (WzSpacing)

Located in `lib/core/theme/wz_spacing.dart`.

**Spacing Values:**
- `space4`: 4.0
- `space8`: 8.0
- `space12`: 12.0
- `space16`: 16.0
- `space20`: 20.0
- `space24`: 24.0
- `space32`: 32.0
- `space40`: 40.0
- `space48`: 48.0

**Component-Specific:**
- `buttonPaddingHorizontal`: 16.0
- `buttonPaddingVertical`: 12.0
- `cardPadding`: 16.0
- `screenPadding`: 16.0

**Usage:**
```dart
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

---

## Usage Guidelines

### Best Practices

1. **Always use design system tokens**
   - Use `WzColors` instead of hardcoded colors
   - Use `WzTextStyles` instead of inline TextStyle
   - Use `WzSpacing` instead of magic numbers

2. **Component composition**
   - Combine components to build complex UIs
   - Don't modify component internals
   - Use parameters for customization

3. **Responsive design**
   - Components adapt to different screen sizes
   - Use `MediaQuery` for screen-specific layouts
   - Test on multiple device sizes

4. **Accessibility**
   - All components support semantic labels
   - Maintain sufficient color contrast
   - Ensure touch targets are at least 48x48

### Common Patterns

**Form Layout:**
```dart
Padding(
  padding: EdgeInsets.all(WzSpacing.space16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      WzTextField(
        label: 'Name',
        hint: 'Enter your name',
      ),
      SizedBox(height: WzSpacing.space16),
      WzTextField(
        label: 'Email',
        hint: 'Enter your email',
        keyboardType: TextInputType.emailAddress,
      ),
      SizedBox(height: WzSpacing.space16),
      WzPasswordField(
        label: 'Password',
        hint: 'Enter your password',
      ),
      SizedBox(height: WzSpacing.space24),
      WzPrimaryButton(
        text: 'Sign Up',
        onPressed: _handleSignUp,
      ),
    ],
  ),
)
```


**List with Cards:**
```dart
ListView.builder(
  padding: EdgeInsets.all(WzSpacing.space16),
  itemCount: users.length,
  itemBuilder: (context, index) {
    return WzUserCard(
      fullName: users[index].name,
      age: users[index].age,
      location: users[index].location,
      avatarUrl: users[index].avatarUrl,
      onTap: () => _viewProfile(users[index]),
    );
  },
)
```

**Action Buttons Row:**
```dart
Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    WzIconButton(
      icon: Icon(Icons.close),
      backgroundColor: Colors.red.withOpacity(0.1),
      iconColor: Colors.red,
      onPressed: _handleReject,
    ),
    WzIconButton(
      icon: Icon(Icons.favorite),
      backgroundColor: WzColors.primary.withOpacity(0.1),
      iconColor: WzColors.primary,
      onPressed: _handleLike,
    ),
    WzIconButton(
      icon: Icon(Icons.chat_bubble),
      backgroundColor: Colors.blue.withOpacity(0.1),
      iconColor: Colors.blue,
      onPressed: _handleChat,
    ),
  ],
)
```

**Screen with AppBar and BottomNav:**
```dart
Scaffold(
  appBar: WzAppBar(
    title: 'Explore',
    actions: [
      IconButton(
        icon: Icon(Icons.filter_list),
        onPressed: _showFilters,
      ),
    ],
  ),
  body: _buildContent(),
  bottomNavigationBar: WzBottomNav(
    currentIndex: _currentIndex,
    onTap: _onNavTap,
    items: [
      WzBottomNavItem(icon: Icons.home, label: 'Home'),
      WzBottomNavItem(icon: Icons.explore, label: 'Explore'),
      WzBottomNavItem(icon: Icons.people, label: 'Connections'),
      WzBottomNavItem(icon: Icons.chat, label: 'Chat'),
      WzBottomNavItem(icon: Icons.person, label: 'Profile'),
    ],
  ),
)
```

### Integration with Existing App

The UI clone components can be integrated into the existing WeddingZon app in three ways:

1. **Reference Mode**: Use UI clone screens for visual comparison during development
2. **Replace Mode**: Replace existing screens entirely with UI clone versions
3. **Gradual Adoption**: Incrementally adopt components in existing screens

See the main README for detailed integration strategies.

### Troubleshooting

**Component not rendering correctly:**
- Ensure all design system files are imported
- Check that parent widget provides sufficient constraints
- Verify asset paths in pubspec.yaml

**Colors look different:**
- Confirm using WzColors constants
- Check theme configuration in MaterialApp
- Verify no parent widgets override colors

**Spacing inconsistent:**
- Use WzSpacing constants throughout
- Avoid mixing hardcoded values with design tokens
- Check for conflicting padding/margin

**Images not loading:**
- Verify network connectivity for remote images
- Check asset paths for local images
- Ensure pubspec.yaml includes asset declarations

---

## Component Summary

| Component | File | Purpose |
|-----------|------|---------|
| WzPrimaryButton | wz_buttons.dart | Primary action button |
| WzSecondaryButton | wz_buttons.dart | Secondary action button |
| WzTextButton | wz_buttons.dart | Text-only button |
| WzIconButton | wz_buttons.dart | Circular icon button |
| WzTextField | wz_inputs.dart | Standard text input |
| WzPasswordField | wz_inputs.dart | Password input with toggle |
| WzDropdown | wz_inputs.dart | Dropdown selection |
| WzDatePicker | wz_inputs.dart | Date picker field |
| WzSearchBar | wz_inputs.dart | Search input |
| WzProfileCard | wz_cards.dart | Large profile card |
| WzUserCard | wz_cards.dart | Medium user card |
| WzNotificationCard | wz_cards.dart | Notification card |
| WzRequestCard | wz_cards.dart | Request card with actions |
| WzConversationTile | wz_cards.dart | Chat conversation tile |
| WzAppBar | wz_navigation.dart | App bar |
| WzBottomNav | wz_navigation.dart | Bottom navigation |
| WzTabBar | wz_navigation.dart | Tab bar |
| WzDrawer | wz_navigation.dart | Side drawer |
| WzStatusBar | wz_navigation.dart | Status bar |

---

## Additional Resources

- **Design System**: See `lib/core/theme/` for all design tokens
- **Screen Examples**: See `lib/ui_clone/screens/` for complete screen implementations
- **Figma Design**: Original designs at node ID 129:2318
- **Integration Guide**: See main README.md for integration strategies

For questions or issues, please refer to the main project documentation or contact the development team.
