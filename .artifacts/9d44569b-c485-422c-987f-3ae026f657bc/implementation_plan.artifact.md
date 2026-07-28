# Implementation Plan - "No More Mocks"

This plan removes all remaining mock data and hardcoded strings, ensuring that every data point in the app is derived from a real source (Firestore, Firebase Storage, or Calculated Logic).

## User Review Required

> [!IMPORTANT]
> - **Total Reading Time**: I will begin tracking **cumulative reading minutes** in Firestore. Historical data (before this change) won't be available, so everyone will start at 0 hours.
> - **Notifications**: I will clear the mock notification list. Real notifications will be triggered by events (e.g., Book Synced, Achievement Unlocked).

## Proposed Changes

### [Component] Persistence & Insights
#### [MODIFY] [auth_service.dart](file:///C:/Projects/readrift/lib/security/auth_service.dart)
- Update `recordReadingSession` to increment `totalMinutesRead` globally.
- Add `getNotificationsStream` and `markNotificationAsRead`.
- Add `updateUserPreferences` to sync Dark Mode and Notification toggles.

### [Component] Real-Time Notifications
#### [MODIFY] [notifications_screen.dart](file:///C:/Projects/readrift/lib/screens/notifications_screen.dart)
- Replace hardcoded list with a `StreamBuilder` from Firestore.
- Add logic to generate a "Book Synced" notification when a file is imported.

### [Component] Home & Profile Data
#### [MODIFY] [home_screen.dart](file:///C:/Projects/readrift/lib/screens/home_screen.dart)
- Calculate `_getRemainingReadingTime` using the user's calculated reading speed and the `progressPercent` of the active book.
#### [MODIFY] [profile_screen.dart](file:///C:/Projects/readrift/lib/screens/profile_screen.dart)
- Replace mock `readingHours = 158` with a calculated value from `totalMinutesRead`.

### [Component] User Settings
#### [MODIFY] [account_settings_screen.dart](file:///C:/Projects/readrift/lib/screens/account_settings_screen.dart)
- Connect all toggles (Notifications, Reminders) to Firestore.
- Remove "Coming soon" toasts for settings that can be implemented now.

### [Component] Audio Assets
#### [MODIFY] [audio_service.dart](file:///C:/Projects/readrift/lib/services/audio_service.dart)
- Replace `SoundHelix` placeholder URLs with reliable royalty-free audio sources for Rain, Café, and Focus.

---

## Verification Plan

### Manual Verification
1. **Notifications**: Import a book and verify a notification appears in the tray.
2. **Reading Time**: Read for 5 minutes and verify the Profile screen reflects the increase in total reading hours.
3. **Settings**: Toggle "Reading Reminders" and verify the change persists after an app restart.
4. **Audio**: Verify ambient sounds play correctly from the new URLs.
