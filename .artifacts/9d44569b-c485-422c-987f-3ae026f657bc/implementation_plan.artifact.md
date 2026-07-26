# Implementation Plan - Streak Polish & AI Refinement

This plan focuses on making the Reading Streak real, adding a high-end sharing feature, and refining the AI's "voice" to match the ReadRift universe.

## User Review Required

> [!IMPORTANT]
> - **New Dependencies**: I will add `share_plus` and `screenshot` to `pubspec.yaml` to enable the "Universe Card" sharing feature.
> - **Streak Logic**: I will implement a "soft streak" where a user has a 24-hour grace period to maintain their streak.

## Proposed Changes

### [Component] Persistence & Streak Logic
#### [MODIFY] [auth_service.dart](file:///C:/Projects/readrift/lib/security/auth_service.dart)
- Add `updateStreak` method to handle incrementing/resetting streaks in Firestore.
- Add `lastReadTimestamp` and `streakCount` to user metadata.

### [Component] UI: Universe Streak Card
#### [NEW] [universe_share_card.dart](file:///C:/Projects/readrift/lib/widgets/universe_share_card.dart)
- A specialized Glassmorphism widget designed for social sharing.
- Displays the user's streak, active book, and a generated "Reading Persona" (e.g., "Universal Voyager").
#### [MODIFY] [home_screen.dart](file:///C:/Projects/readrift/lib/screens/home_screen.dart)
- Integrate a "Share" icon into the `DailyGoalWidget`.
- Connect the real streak data from Firestore.

### [Component] AI "Universe" Refinement
#### [MODIFY] [ai_service.dart](file:///C:/Projects/readrift/lib/services/ai_service.dart)
- Update prompts to use a "Universal Librarian" persona.
- Add a `getPreviouslyIn` method for chapter-by-chapter summaries.

### [Component] Dependencies
#### [MODIFY] [pubspec.yaml](file:///C:/Projects/readrift/pubspec.yaml)
- Add `share_plus: ^10.0.0`
- Add `screenshot: ^3.0.0`

---

## Verification Plan

### Automated Tests
- Unit tests for streak calculation (yesterday vs today).

### Manual Verification
- **Sharing**: Trigger the "Universe Card" and verify the screenshot is generated and the share sheet opens.
- **Streak**: Simulate a "last read" date of yesterday and verify the streak increments today.
- **AI**: Verify the new poetic summary style.
