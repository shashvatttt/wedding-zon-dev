# Advanced Filter Bottom Sheet Implementation

## Overview
Implemented a new advanced filter bottom sheet based on the Figma design with a two-column layout featuring a sidebar navigation and content area.

## Design Reference
- **Figma Node**: 123-1349
- **Design**: WeddingZon Filters Section

## Implementation Details

### File Created
- `lib/features/explore/widgets/advanced_filter_bottom_sheet.dart`

### Key Features

#### 1. **Two-Column Layout**
- **Left Sidebar**: Pink background (#FFF9FA) with filter categories
- **Right Content Area**: White background showing filter options for selected category

#### 2. **Filter Categories** (21 total)
1. Type of Matches (Radio buttons)
2. Based Out Of (Checkboxes with state selection)
3. Posted By (Checkboxes)
4. Activity On Site (Checkboxes)
5. Religion (Checkboxes)
6. Caste (Checkboxes)
7. Subcaste (Checkboxes)
8. Age (Dual sliders for min/max)
9. Mother Tongue (Checkboxes)
10. Country (Checkboxes)
11. Income (INR/USD input fields)
12. Employed In (Checkboxes)
13. Education (Checkboxes)
14. Drinking (Checkboxes)
15. Smoking (Checkboxes)
16. Eating Habits (Checkboxes)
17. Marital Status (Checkboxes)
18. Family Types (Checkboxes)
19. Siblings (Checkboxes)
20. Property Types (Checkboxes)
21. Land Area (Checkboxes)

#### 3. **UI Components**
- **Radio Buttons**: For single-selection filters (Type of Matches)
- **Checkboxes**: For multi-selection filters (most categories)
- **Sliders**: For age range selection
- **"All" Checkbox**: Select/deselect all options in checkbox lists

#### 4. **Header**
- Large "Filters" title (40px, bold)
- "Reset" button (red color #EF2F55)
- Close icon button

#### 5. **Bottom Action Bar**
- "Clear All" button (outlined, red)
- "Apply Filters" button (filled, red background)

### Design Specifications

#### Colors
- Primary Red: `#EF2F55`
- Text Gray: `#374151`
- Sidebar Background: `#FFF9FA`
- Border Gray: `#9CA3AF`

#### Typography
- Header: 40px, Bold
- Category Labels: 20px, Semi-bold
- Options: 18px, Regular
- Reset Button: 20px, Semi-bold

#### Spacing
- Sidebar Width: 224px
- Padding: 24-32px
- Item Spacing: 16px

### Integration

#### Updated Files
1. `lib/features/feed/screens/feed_screen.dart`
   - Replaced `FilterBottomSheet` with `AdvancedFilterBottomSheet`
   - Removed unused import

2. `lib/features/explore/screens/explore_screen.dart`
   - Replaced `FilterBottomSheet` with `AdvancedFilterBottomSheet`

### Usage

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => AdvancedFilterBottomSheet(
    initialFilters: existingFilters, // Optional
    onApply: (filters) {
      // Handle filter application
      print('Applied filters: $filters');
    },
  ),
);
```

### Filter Data Structure

The `onApply` callback returns a `Map<String, dynamic>` with the following possible keys:

```dart
{
  'typeOfMatches': String?,
  'basedOutOf': List<String>,
  'postedBy': List<String>,
  'activityOnSite': List<String>,
  'religion': List<String>,
  'caste': List<String>,
  'subcaste': List<String>,
  'minAge': int,
  'maxAge': int,
  'motherTongue': List<String>,
  'country': List<String>,
  'minIncome': double,
  'maxIncome': double,
  'employedIn': List<String>,
  'education': List<String>,
  'drinking': List<String>,
  'smoking': List<String>,
  'eatingHabits': List<String>,
  'maritalStatus': List<String>,
  'familyTypes': List<String>,
  'siblings': List<String>,
  'propertyTypes': List<String>,
  'landArea': List<String>,
}
```

### Features

1. **Persistent State**: Filter selections are maintained while navigating between categories
2. **Reset Functionality**: Clear all filters with one tap
3. **Responsive**: Adapts to 90% of screen height
4. **Scrollable Content**: Both sidebar and content area are scrollable
5. **Visual Feedback**: Selected category highlighted in sidebar with white background

### Future Enhancements

1. **Backend Integration**: Map filter values to actual API parameters
2. **Filter Counts**: Show number of active filters per category
3. **Saved Filters**: Allow users to save and load filter presets
4. **Smart Defaults**: Pre-populate based on user preferences
5. **Filter Validation**: Ensure min/max values are logical

## Testing

To test the implementation:
1. Navigate to Feed screen
2. Tap the "Filters" chip
3. Select different categories from the sidebar
4. Choose filter options
5. Tap "Apply Filters" to see results
6. Use "Reset" to clear all selections

## Notes

- The old `FilterBottomSheet` is still available for backward compatibility
- Filter options include sample counts (e.g., "Hindu(250)") from Figma design
- The implementation follows Flutter best practices with StatefulWidget
- All UI measurements match the Figma design specifications
