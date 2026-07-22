# Implementation Plan - ReadRift 5-Star Polish

This plan outlines the steps to elevate ReadRift from a functional app to a high-quality, 5-star experience by adding gamification, improved navigation, and polished UI components.

## User Review Required

> [!IMPORTANT]
> - **Onboarding Content**: I will use placeholder copy for the 3-step onboarding (Import, Sync, Customize). Let me know if you have specific taglines in mind.
> - **Daily Goal**: I'll set a default daily goal of 20 minutes. We can make this adjustable in settings later.

## Proposed Changes

### [Component] Onboarding Experience
#### [MODIFY] [welcome_screen.dart](file:///C:/Projects/readrift/lib/screens/welcome_screen.dart)
- Replace the static layout with a `PageView.builder`.
- Add 3 onboarding slides with unique illustrations (using existing assets where possible).
- Add a "Get Started" button on the final slide.

### [Component] Reader Enhancements
#### [MODIFY] [reader_screen.dart](file:///C:/Projects/readrift/lib/screens/reader_screen.dart)
- Implement the **Table of Contents (TOC)**:
    - Open a `ModalBottomSheet` when the menu icon is tapped.
    - List all chapters from the EPUB document.
    - Enable `controller.gotoEpubCfi(chapter.Cfi)` to jump to sections.

### [Component] Gamification (Home Screen)
#### [MODIFY] [home_screen.dart](file:///C:/Projects/readrift/lib/screens/home_screen.dart)
- Add a **Daily Reading Goal** widget:
    - A circular progress indicator showing "X / 20 mins".
    - Use a persistent streak counter (stored in Firestore/Local).
- Use `AppColors.accentOrange` consistently instead of hardcoded `Colors.orange`.

### [Component] Search & Discovery
#### [MODIFY] [search_screen.dart](file:///C:/Projects/readrift/lib/screens/search_screen.dart)
- Add **Category Chips** for quick discovery (e.g., Fiction, Science, History).
- Implement a "Trending Books" section when the search bar is empty.

### [Component] Visual Polish (Skeletons)
#### [NEW] [skeleton_loader.dart](file:///C:/Projects/readrift/lib/widgets/skeleton_loader.dart)
- Create a reusable shimmer-based skeleton for book cards.
#### [MODIFY] [home_screen.dart](file:///C:/Projects/readrift/lib/screens/home_screen.dart) & [search_screen.dart](file:///C:/Projects/readrift/lib/screens/search_screen.dart)
- Replace `CircularProgressIndicator` with the new skeleton loaders during data fetching.

## Verification Plan

### Automated Tests
- Run `flutter test` to ensure no breaking changes in existing widgets.

### Manual Verification
- **Onboarding**: Swipe through slides and verify the "Sign Up/Login" buttons work on the final slide.
- **Reader**: Open an EPUB, use the TOC to jump to Chapter 3, and verify it navigates correctly.
- **Home**: Verify the daily goal progress bar updates when a book is read (simulated via progress updates).
