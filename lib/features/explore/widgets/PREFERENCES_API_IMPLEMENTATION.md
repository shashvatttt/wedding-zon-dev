# Partner Preferences API Implementation

## Overview
Implemented the `PUT /api/users/preferences` endpoint integration with the advanced filter bottom sheet, allowing users to save their filter selections as partner preferences.

## API Endpoint

### Update Preferences
- **Method**: `PUT`
- **Endpoint**: `/api/users/preferences`
- **Body**:
```json
{
  "preferences": {
    "typeOfMatches": "string",
    "basedOutOf": ["string"],
    "postedBy": ["string"],
    "activityOnSite": ["string"],
    "religion": ["string"],
    "caste": ["string"],
    "subcaste": ["string"],
    "minAge": 18,
    "maxAge": 70,
    "motherTongue": ["string"],
    "country": ["string"],
    "minIncome": 0,
    "maxIncome": 0,
    "employedIn": ["string"],
    "education": ["string"],
    "drinking": ["string"],
    "smoking": ["string"],
    "eatingHabits": ["string"],
    "maritalStatus": ["string"],
    "familyTypes": ["string"],
    "siblings": ["string"],
    "propertyTypes": ["string"],
    "landArea": ["string"]
  }
}
```

### Get Preferences
- **Method**: `GET`
- **Endpoint**: `/api/users/preferences`
- **Response**: Returns the saved preferences object

## Implementation Details

### 1. Repository Methods (Already Existed)
Located in `lib/features/profile/repositories/user_repository.dart`:

```dart
Future<ApiResponse<Map<String, dynamic>>> getMyPreferences()
Future<ApiResponse<bool>> updateMyPreferences(Map<String, dynamic> preferences)
```

### 2. Advanced Filter Bottom Sheet Enhancement

**File**: `lib/features/explore/widgets/advanced_filter_bottom_sheet.dart`

**New Features**:
- Added `saveAsPreferences` parameter to enable/disable preference saving
- Added checkbox option "Save these filters as my partner preferences"
- Integrated with `UserRepository` to call the API
- Shows toast notifications for success/failure

**Usage**:
```dart
AdvancedFilterBottomSheet(
  saveAsPreferences: true, // Enable preference saving
  onApply: (filters) {
    // Handle filter application
  },
)
```

### 3. Partner Preferences Screen Integration

**File**: `lib/features/profile/screens/user_partner_preferences_screen.dart`

**Enhancements**:
- Added "Advanced Filters" button in app bar
- Added info card promoting advanced filters
- Opens advanced filter bottom sheet with `saveAsPreferences: true`
- Updates form fields when filters are applied

## User Flow

### Scenario 1: Save Preferences from Feed/Explore
1. User opens Feed or Explore screen
2. Taps "Filters" button
3. Selects filter options in the advanced filter sheet
4. Checks "Save these filters as my partner preferences" checkbox
5. Taps "Apply Filters"
6. Filters are applied AND saved as preferences via API
7. Toast notification confirms success

### Scenario 2: Edit Preferences from Profile
1. User navigates to Settings → Partner Preferences
2. Sees traditional form with basic fields
3. Taps "Advanced Filters" button (app bar or info card)
4. Advanced filter sheet opens with `saveAsPreferences: true`
5. Selects comprehensive filter options
6. Checkbox is automatically shown
7. Taps "Apply Filters" to save preferences
8. Returns to preferences screen with updated values

## Features

### 1. Automatic Preference Saving
- When `saveAsPreferences: true` and checkbox is checked
- Calls `UserRepository.updateMyPreferences()`
- Sends all filter selections to backend
- Shows success/error toast notifications

### 2. Comprehensive Filter Options
All 21 filter categories can be saved as preferences:
- Type of Matches
- Location filters (Based Out Of, Country)
- Demographics (Age, Religion, Caste, Subcaste)
- Personal (Mother Tongue, Marital Status)
- Professional (Education, Employment, Income)
- Lifestyle (Drinking, Smoking, Eating Habits)
- Family (Family Types, Siblings)
- Property (Property Types, Land Area)

### 3. Error Handling
- Try-catch blocks for API calls
- User-friendly error messages
- Graceful degradation if save fails
- Filters still apply even if save fails

### 4. Toast Notifications
- **Success**: Green toast "Preferences saved successfully"
- **Failure**: Orange toast with error message
- **Error**: Red toast "Error saving preferences"

## API Integration

### Request Example
```dart
final userRepo = context.read<UserRepository>();
final response = await userRepo.updateMyPreferences({
  'minAge': 25,
  'maxAge': 35,
  'religion': ['Hindu', 'Sikh'],
  'education': ['Bachelor\'s Degree', 'Master\'s Degree'],
  'eatingHabits': ['Vegetarian'],
});

if (response.success) {
  // Show success message
} else {
  // Show error: response.message
}
```

### Response Handling
- **Success**: `response.success == true`
- **Failure**: `response.success == false` with `response.message`
- **Exception**: Caught and logged with debug print

## Testing

### Manual Testing Steps

1. **Test Preference Saving from Feed**:
   ```
   - Open Feed screen
   - Tap "Filters" chip
   - Select various filters
   - Check "Save as preferences" checkbox
   - Tap "Apply Filters"
   - Verify toast notification
   - Check network logs for PUT request
   ```

2. **Test Preference Saving from Profile**:
   ```
   - Go to Settings → Partner Preferences
   - Tap "Advanced Filters" icon
   - Select filters
   - Checkbox should be visible
   - Apply and verify save
   ```

3. **Test Error Handling**:
   ```
   - Disconnect network
   - Try to save preferences
   - Verify error toast appears
   - Verify filters still apply locally
   ```

### Network Debugging
Check logs for:
```
[USER_REPO] 🔵 updateMyPreferences - Updating: /api/users/preferences
[USER_REPO] 🟢 updateMyPreferences - Status: 200
[USER_REPO] ❌ updateMyPreferences - Error: <error message>
```

## Code Changes Summary

### Modified Files
1. `lib/features/explore/widgets/advanced_filter_bottom_sheet.dart`
   - Added `saveAsPreferences` parameter
   - Added `_savePreferences` state variable
   - Added checkbox in bottom action bar
   - Integrated API call in `_applyFilters()`
   - Added toast notifications

2. `lib/features/profile/screens/user_partner_preferences_screen.dart`
   - Added "Advanced Filters" button in app bar
   - Added info card promoting advanced filters
   - Added `_openAdvancedFilters()` method
   - Integrated with advanced filter sheet

### Existing Files (No Changes Needed)
- `lib/features/profile/repositories/user_repository.dart` - Already had the methods

## Future Enhancements

1. **Load Saved Preferences**:
   - Fetch preferences on filter sheet open
   - Pre-populate filter selections
   - Show "Saved Preferences" indicator

2. **Preference Presets**:
   - Allow multiple saved preference sets
   - Quick switch between presets
   - Name and manage presets

3. **Smart Recommendations**:
   - Suggest preferences based on profile
   - Learn from user interactions
   - Auto-adjust preferences

4. **Preference Sync**:
   - Real-time sync across devices
   - Conflict resolution
   - Offline support with queue

## Notes

- The API endpoint structure matches the backend expectation
- All filter values are properly serialized
- The implementation is backward compatible
- Old `FilterBottomSheet` still works for basic filtering
- Preferences are user-specific and stored server-side
