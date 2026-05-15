# Authentication Flow Demo

## Overview

A complete authentication flow has been created in the UI Clone section to demonstrate the user journey from app launch to the main feed screen.

## Flow Diagram

```
Splash Screen (2s auto-navigate)
    ↓
Auth Choice Screen
    ├─→ Login Button → Login Choice Screen → Feed Screen
    └─→ Sign Up Button → Google Login Screen → Mobile Login Screen → Feed Screen
```

## Detailed Flow

### 1. Splash Screen
- **Route**: `/ui-clone/splash`
- **Duration**: 2 seconds
- **Action**: Auto-navigates to Auth Choice Screen
- **Design**: White background with centered WeddingZon logo

### 2. Auth Choice Screen (NEW)
- **Route**: `/ui-clone/auth-choice`
- **Purpose**: Initial choice between Login and Sign Up
- **Design**: Same visual style as Login Choice Screen
  - Background image with blur overlay
  - WeddingZon logo at top
  - Tagline: "Your one-stop wedding solution"
  - Two buttons:
    - **Login** (Red button) → Goes to Login Choice Screen
    - **Sign Up** (Pink outlined button) → Goes to Google Login Screen
  - Terms & conditions at bottom

### 3A. Login Flow
**Auth Choice → Login Choice → Feed**

#### Login Choice Screen
- **Route**: `/ui-clone/login-choice`
- **Options**:
  - Continue with OTP → Navigates to Feed
  - Continue with Google → Navigates to Feed
- **Design**: Background image with blur, logo, tagline, two login options

### 3B. Sign Up Flow
**Auth Choice → Google Login → Mobile Login → Feed**

#### Google Login Screen
- **Route**: `/ui-clone/google-login`
- **Purpose**: Google authentication step
- **Design**: 
  - Back button
  - Google icon
  - "Sign In with Google" title
  - Description text
  - Continue with Google button → Navigates to Mobile Login

#### Mobile Login Screen
- **Route**: `/ui-clone/mobile-login`
- **Purpose**: Mobile number verification
- **Design**:
  - Back button
  - "Enter Your Mobile Number" title
  - Country code selector (+91 🇮🇳)
  - Mobile number input field
  - Continue button → Navigates to Feed

### 4. Feed Screen
- **Route**: `/ui-clone/feed`
- **Purpose**: Main app screen after authentication
- **Design**: Browse matches based on partner preferences

## How to Access

### Option 1: From UI Clone Gallery
1. Open the app
2. Tap "View Sample UI (39 Screens)" button on landing screen
3. Tap the prominent "Start Demo Flow" button at the top
4. Experience the complete authentication flow

### Option 2: Direct Navigation
Navigate directly to any screen using the routes:
- `/ui-clone/splash` - Start from splash
- `/ui-clone/auth-choice` - Start from auth choice
- `/ui-clone/login-choice` - Start from login choice
- `/ui-clone/google-login` - Start from Google login
- `/ui-clone/mobile-login` - Start from mobile login
- `/ui-clone/feed` - Go directly to feed

## Screen Count Update

Total screens in UI Clone: **40 screens** (was 39)
- Authentication: **8 screens** (was 7)
  - Added: Auth Choice Screen

## Technical Details

### Files Created
- `lib/ui_clone/screens/auth_choice_screen_ui.dart` - New auth choice screen

### Files Modified
- `lib/ui_clone/screens/splash_screen_ui.dart` - Added auto-navigation
- `lib/ui_clone/screens/google_login_screen_ui.dart` - Added navigation to mobile login
- `lib/ui_clone/screens/mobile_login_screen_ui.dart` - Added navigation to feed
- `lib/ui_clone/screens/login_choice_screen_ui.dart` - Added navigation to feed
- `lib/ui_clone/navigation/ui_clone_routes.dart` - Added auth choice route
- `lib/ui_clone/navigation/ui_clone_home.dart` - Added "Start Demo Flow" button

## Design Consistency

All screens follow the WeddingZon design system:
- **Primary Color**: `#EF2F55` (Red/Pink)
- **Background**: Blur overlay on background image
- **Typography**: SF Pro font family
- **Button Style**: Rounded corners (34px radius)
- **Spacing**: Consistent padding and margins

## User Experience

The flow demonstrates:
1. **App Launch** - Professional splash screen
2. **Choice** - Clear decision between login and sign up
3. **Authentication** - Multiple auth methods (OTP, Google)
4. **Verification** - Mobile number verification for sign up
5. **Success** - Seamless transition to main app (Feed)

## Testing

To test the complete flow:
1. Hot restart the app: Press `R` in terminal
2. Navigate to UI Clone Gallery
3. Tap "Start Demo Flow (Splash → Auth → Feed)"
4. Follow the authentication journey
5. Test both Login and Sign Up paths

## Notes

- All screens are **pure UI** - no actual authentication logic
- Navigation is hardcoded for demo purposes
- Buttons are functional and navigate between screens
- Back buttons are present but may not have navigation logic
- This is a visual demonstration of the user journey
