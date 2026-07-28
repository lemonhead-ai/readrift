# ReadRift Universal Expansion Phase 2 Walkthrough

The ReadRift experience has been upgraded with advanced utility, professional document handling, and accessibility features.

## Key Enhancements

### 1. Professional PDF Reader
- **[SfPdfViewer Integration](file:///C:/Projects/readrift/lib/screens/reader_screen.dart)**: Migrated from a basic PDF viewer to `syncfusion_flutter_pdfviewer`.
- **Advanced Controls**: Users now have access to high-performance zooming, native text selection, and smooth scrolling.
- **Search Support**: Native PDF search is fully integrated with a "Previous/Next" navigation UI.

### 2. In-Book Search (EPUB & PDF)
- **Unified Search UI**: A new sleek search bar appears in the reader header.
- **EPUB Search**: Logic implemented to scan chapters and jump to the first matching section.
- **PDF Search**: Direct integration with the Syncfusion search engine for instance-level jumping.

### 3. Yearly Reading Challenge
- **[Reading Challenge Card](file:///C:/Projects/readrift/lib/screens/profile_screen.dart)**: A beautiful new progress card in the Profile screen.
- **Goal Setting**: Users can set a yearly goal (e.g., "50 books in 2026") and track their progress via a dynamic progress bar.
- **Firestore Persistence**: Goals are saved globally and follow the user across devices.

### 4. Accessibility Suite
- **Reading Ruler**: A draggable focus bar helps readers with ADHD or dyslexia maintain focus on the current line. It can be toggled in the Audio/Focus menu.
- **OpenDyslexic Support**: Added a font toggle in the reader settings to switch between Poppins and OpenDyslexic.

---

## 🛠️ Important Setup Note

> [!CAUTION]
> **OpenDyslexic Font**: The logic is implemented, but you must add the `OpenDyslexic-Regular.otf` file to your `fonts/` directory and register it in `pubspec.yaml` for the font toggle to render correctly.

---

## Verification Results
- **PDF Viewer**: Smooth loading and interaction verified.
- **Search**: Search results correctly jump to positions in both file formats.
- **Goals**: The Set Goal dialog correctly updates the Firestore document and UI.
- **Ruler**: The ruler appears and is draggable vertically across the screen.
