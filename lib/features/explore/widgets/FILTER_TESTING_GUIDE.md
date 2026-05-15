# Filter Testing Guide

## Overview
The Advanced Filter system is fully integrated and working. This guide helps verify that filters are functioning correctly.

## Filter Flow

```
User Selects Filters
    ↓
AdvancedFilterBottomSheet._applyFilters()
    ↓
Creates Map<String, dynamic> with selected filters
    ↓
Calls widget.onApply(filters)
    ↓
Feed/Explore Screen receives filters
    ↓
MatchProvider.search(filters)
    ↓
MatchRepository.searchMatches(filters)
    ↓
GET /api/matches/search?filter1=value1&filter2=value2
    ↓
Backend returns filtered results
    ↓
Results displayed in Feed/Explore
```

## Filter Parameters Sent to Backend

When filters are applied, the following parameters are sent as query parameters to `/api/matches/search`:

### Single Value Filters
- `typeOfMatches`: String (e.g., "Verified", "Just Joined", "Nearby")
- `minAge`: Integer (e.g., 25)
- `maxAge`: Integer (e.g., 35)
- `minIncome`: Double (e.g., 500000)
- `maxIncome`: Double (e.g., 1000000)

### Array Filters (Multiple Selection)
- `basedOutOf`: List<String> (e.g., ["Delhi", "Mumbai"])
- `postedBy`: List<String> (e.g., ["Parent", "Self"])
- `activityOnSite`: List<String> (e.g., ["Online", "Active in last week"])
- `religion`: List<String> (e.g., ["Hindu", "Sikh"])
- `caste`: List<String> (e.g., ["Brahmins", "Kayastha"])
- `subcaste`: List<String> (e.g., ["Gaur", "Saxena"])
- `motherTongue`: List<String> (e.g., ["Hindi-Delhi", "Punjabi"])
- `country`: List<String> (e.g., ["India", "Australia"])
- `employedIn`: List<String> (e.g., ["Private Sector", "Government/Public Sector"])
- `education`: List<String> (e.g., ["B.A", "M.Sc"])
- `drinking`: List<String> (e.g., ["Non-Drinker", "Occasionally"])
- `smoking`: List<String> (e.g., ["Non-Smoker", "No"])
- `eatingHabits`: List<String> (e.g., ["Vegetarian", "Eggetarian"])
- `maritalStatus`: List<String> (e.g., ["Never Married"])
- `familyTypes`: List<String> (e.g., ["Nuclear", "Joint"])
- `siblings`: List<String> (e.g., ["2-3 Siblings"])
- `propertyTypes`: List<String> (e.g., ["Self-Acquired property"])
- `landArea`: List<String> (e.g., ["1000 - 2000 sq ft"])

## Testing Steps

### 1. Test Single Filter
1. Open Feed or Explore screen
2. Tap "Filters" button
3. Select "Religion" → Check "Hindu"
4. Tap "Apply Filters"
5. **Expected**: API call to `/api/matches/search?religion=["Hindu"]`
6. **Expected**: Feed shows only Hindu users

### 2. Test Multiple Filters
1. Open Filters
2. Select "Age" → Set 25-35
3. Select "Religion" → Check "Hindu"
4. Select "Based Out Of" → Check "Delhi"
5. Tap "Apply Filters"
6. **Expected**: API call with `minAge=25&maxAge=35&religion=["Hindu"]&basedOutOf=["Delhi"]`
7. **Expected**: Feed shows Hindu users aged 25-35 from Delhi

### 3. Test Filter Reset
1. Apply some filters
2. Tap "Reset" in filter sheet
3. **Expected**: All selections cleared
4. Tap "Apply Filters"
5. **Expected**: Shows all users (no filters applied)

### 4. Test Clear All
1. Apply filters
2. Tap "Clear All" button
3. **Expected**: All filters removed
4. **Expected**: Feed refreshes with all users

### 5. Test Filter Persistence
1. Apply filters in Explore screen
2. Navigate away and come back
3. **Expected**: Filter indicator (red dot) still visible
4. **Expected**: Filtered results still showing

### 6. Test Save as Preferences
1. Open Filters from Profile → Partner Preferences
2. Select multiple filters
3. Check "Save these filters as my partner preferences"
4. Tap "Apply Filters"
5. **Expected**: Toast message "Preferences saved successfully"
6. **Expected**: PUT request to `/api/users/preferences`

## Debugging

### Check Filter Values in Console
The app logs filter operations:
```
[FILTER] Filter options loaded successfully
[EXPLORE_REPO] ========== GET FILTERED FEED ==========
[EXPLORE_REPO] Filters: {religion: [Hindu], minAge: 25, maxAge: 35}
```

### Verify API Request
Use network inspector to verify:
1. Endpoint: `/api/matches/search`
2. Method: GET
3. Query Parameters: All selected filters
4. Response: Array of filtered users

### Common Issues

#### Issue: No results after applying filters
**Cause**: Backend might not have users matching all criteria
**Solution**: Try fewer filters or broader criteria

#### Issue: Filters not being sent
**Cause**: Empty arrays or null values are filtered out
**Solution**: Check `_applyFilters()` - only non-empty values are sent

#### Issue: Filter values not matching backend expectations
**Cause**: Backend expects different format (e.g., lowercase, different field names)
**Solution**: Update filter keys in `_applyFilters()` to match backend schema

## Backend Requirements

The backend `/api/matches/search` endpoint must:

1. **Accept Query Parameters**: All filter fields as query params
2. **Handle Arrays**: Parse array parameters (e.g., `religion=["Hindu","Sikh"]`)
3. **Handle Ranges**: Support minAge/maxAge, minIncome/maxIncome
4. **Return Filtered Results**: Array of users matching ALL criteria (AND logic)
5. **Response Format**:
```json
{
  "success": true,
  "data": [
    {
      "id": "user123",
      "name": "John Doe",
      "age": 28,
      "religion": "Hindu",
      // ... other user fields
    }
  ]
}
```

## Filter Options (Without Numbers)

All filter options now display clean labels without counts:

- **Based Out Of**: Uttar Pradesh, Madhya Pradesh, Bihar, Delhi, etc.
- **Religion**: Hindu, Muslim, Sikh, Christian
- **Caste**: Brahmins, Kayastha, Yadav, Rajput, Jaat
- **Education**: Arts/Science, B.A, B.Sc, M.Sc, M.A., etc.
- **Employed In**: Not working currently, Private Sector, Business/Self Employed, etc.

## Notes

- Age filter always sends minAge and maxAge (defaults: 18-70)
- Empty arrays are not sent to backend
- Filter values are case-sensitive
- Multiple selections in same category use OR logic (e.g., Hindu OR Muslim)
- Multiple categories use AND logic (e.g., Hindu AND Delhi AND Age 25-35)
