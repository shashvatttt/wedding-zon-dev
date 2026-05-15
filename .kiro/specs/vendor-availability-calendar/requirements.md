# Requirements Document

## Introduction

The Vendor Availability Calendar feature enables vendors to manage their booking schedule by marking dates as "Booked" or "Unavailable" and adding optional notes. This feature integrates with the existing backend API to read availability data from the user profile and update it through a dedicated endpoint. The calendar provides visual indicators for different availability states and prevents editing of past dates.

## Glossary

- **Vendor**: A user with role 'vendor' who provides services and needs to manage their availability
- **Calendar_Widget**: The visual calendar component that displays availability status for dates
- **Availability_Entry**: A record containing a date, status, and optional note
- **Status**: The availability state of a date, which can be 'booked', 'unavailable', or 'available'
- **Edit_Sheet**: A modal bottom sheet that allows vendors to modify availability for a selected date
- **Backend_API**: The REST API endpoints for reading and updating vendor availability data
- **User_Profile**: The authenticated user's profile data containing vendor_details.availability array
- **Past_Date**: Any date before the current date, which should be non-editable

## Requirements

### Requirement 1: Display Vendor Availability Calendar

**User Story:** As a vendor, I want to view a calendar showing my availability status for each date, so that I can see my booking schedule at a glance.

#### Acceptance Criteria

1. WHEN a vendor accesses the calendar screen, THE Calendar_Widget SHALL display a monthly calendar view
2. THE Calendar_Widget SHALL fetch availability data from the User_Profile on initialization
3. WHEN an Availability_Entry has status 'booked', THE Calendar_Widget SHALL display the date with a red visual indicator
4. WHEN an Availability_Entry has status 'unavailable', THE Calendar_Widget SHALL display the date with a gray visual indicator
5. WHEN an Availability_Entry has status 'available' or no entry exists, THE Calendar_Widget SHALL display the date with default styling
6. WHEN a date is selected by the user, THE Calendar_Widget SHALL display a highlight ring around the date

### Requirement 2: Restrict Calendar Access to Vendors

**User Story:** As a system administrator, I want only users with vendor role to access the availability calendar, so that the feature is restricted to authorized users.

#### Acceptance Criteria

1. WHEN a user attempts to access the calendar screen, THE System SHALL verify the user's role is 'vendor'
2. IF the user's role is not 'vendor', THEN THE System SHALL prevent access to the calendar screen
3. THE System SHALL display an appropriate error message when non-vendor users attempt access

### Requirement 3: Edit Availability for Future Dates

**User Story:** As a vendor, I want to mark future dates as booked or unavailable with optional notes, so that I can manage my schedule.

#### Acceptance Criteria

1. WHEN a vendor taps on a future date, THE Calendar_Widget SHALL open the Edit_Sheet
2. THE Edit_Sheet SHALL display the selected date in a readable format
3. THE Edit_Sheet SHALL provide buttons for selecting 'booked' status with red styling
4. THE Edit_Sheet SHALL provide buttons for selecting 'unavailable' status with gray styling
5. THE Edit_Sheet SHALL provide a text input field for adding an optional note
6. WHEN the vendor saves changes, THE System SHALL call the Backend_API with action 'add', the selected status, and the note
7. WHEN the Backend_API returns success, THE System SHALL update the local User_Profile with the returned availability array
8. WHEN the Backend_API returns success, THE System SHALL display a confirmation message to the vendor
9. IF the Backend_API returns an error, THEN THE System SHALL display an error message to the vendor

### Requirement 4: Remove Availability Entry

**User Story:** As a vendor, I want to clear availability status for a date, so that it returns to the default available state.

#### Acceptance Criteria

1. WHEN a vendor opens the Edit_Sheet for a date with an existing Availability_Entry, THE Edit_Sheet SHALL display a clear/remove button
2. WHEN the vendor taps the clear/remove button, THE System SHALL call the Backend_API with action 'remove' for the selected date
3. WHEN the Backend_API returns success, THE System SHALL update the local User_Profile with the returned availability array
4. WHEN the Backend_API returns success, THE System SHALL display a confirmation message to the vendor
5. IF the Backend_API returns an error, THEN THE System SHALL display an error message to the vendor

### Requirement 5: Prevent Editing Past Dates

**User Story:** As a vendor, I want past dates to be non-editable, so that historical availability data remains accurate.

#### Acceptance Criteria

1. WHEN a vendor taps on a Past_Date, THE Calendar_Widget SHALL not open the Edit_Sheet
2. THE Calendar_Widget SHALL display Past_Date entries with reduced opacity to indicate they are non-editable
3. WHEN a vendor attempts to interact with a Past_Date, THE System SHALL provide visual feedback that the date cannot be edited

### Requirement 6: Integrate with Backend API for Reading Availability

**User Story:** As a vendor, I want my availability data to be loaded from the server, so that I see consistent data across devices.

#### Acceptance Criteria

1. WHEN the calendar screen initializes, THE System SHALL call the Backend_API endpoint GET /api/auth/me
2. THE System SHALL parse the vendor_details.availability array from the response
3. FOR ALL entries in the availability array, THE System SHALL create Availability_Entry objects with date, status, and note
4. THE System SHALL handle ISO date string format from the Backend_API
5. IF the Backend_API call fails, THEN THE System SHALL display an error message and show an empty calendar

### Requirement 7: Integrate with Backend API for Updating Availability

**User Story:** As a vendor, I want my availability changes to be saved to the server, so that my schedule is persisted.

#### Acceptance Criteria

1. WHEN the vendor saves an availability change, THE System SHALL call the Backend_API endpoint PATCH /api/vendor-features/availability
2. THE System SHALL include the Authorization header with the bearer token
3. THE System SHALL send the date in ISO date string format
4. THE System SHALL send the status as one of 'booked', 'unavailable', or 'available'
5. THE System SHALL send the note if provided by the vendor
6. THE System SHALL send the action as 'add' for setting or updating an entry
7. THE System SHALL send the action as 'remove' for clearing an entry
8. THE System SHALL parse the returned availability array and update the local User_Profile

### Requirement 8: Maintain State Consistency

**User Story:** As a vendor, I want the calendar to reflect my changes immediately, so that I have confidence my updates were saved.

#### Acceptance Criteria

1. WHEN the Backend_API returns a successful response, THE System SHALL update the User_Profile state with the new availability data
2. THE Calendar_Widget SHALL re-render to display the updated availability status
3. THE System SHALL maintain consistency between the local state and the server state
4. IF the local state and server state diverge, THEN THE System SHALL prioritize the server state from the Backend_API response

### Requirement 9: Display Availability Notes

**User Story:** As a vendor, I want to see notes I've added to dates, so that I can remember details about bookings or unavailability.

#### Acceptance Criteria

1. WHEN a vendor taps on a date with an existing Availability_Entry that has a note, THE Edit_Sheet SHALL display the note in the text input field
2. THE Edit_Sheet SHALL allow the vendor to edit or remove the note
3. WHEN the vendor saves changes, THE System SHALL update the note in the Backend_API

### Requirement 10: Handle Network Errors Gracefully

**User Story:** As a vendor, I want to see clear error messages when network issues occur, so that I understand why my changes didn't save.

#### Acceptance Criteria

1. IF the Backend_API call fails due to network connectivity, THEN THE System SHALL display a user-friendly error message
2. IF the Backend_API call fails due to authentication, THEN THE System SHALL display an authentication error message
3. IF the Backend_API call fails due to server error, THEN THE System SHALL display a server error message
4. THE System SHALL not update the local state when the Backend_API call fails
5. THE System SHALL allow the vendor to retry the operation after a failure
