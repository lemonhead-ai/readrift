# Implementation Plan - Universal Expansion Phase 2

This plan adds advanced utility, accessibility, and deeper gamification to ReadRift, completing the feature set for a world-class reading experience.

## User Review Required

> [!IMPORTANT]
> - **PDF Viewer Upgrade**: I will migrate the PDF reader from `flutter_pdfview` to `syncfusion_flutter_pdfviewer`. This adds robust text selection, native search, and high-performance zooming.
> - **OpenDyslexic Font**: I will implement the logic for this font. You will need to add `OpenDyslexic-Regular.otf` to the `fonts/` directory for it to be fully functional.
> - **Search Logic**: For EPUBs, search will jump to the first matching chapter. For PDFs, it will use the native Syncfusion search result jumping.

## Proposed Changes

### [Component] Advanced PDF Reader
#### [MODIFY] [reader_screen.dart](file:///C:/Projects/readrift/lib/screens/reader_screen.dart)
- Replace `PDFView` with `SfPdfViewer.file`.
- Initialize `PdfViewerController` for programmatic control.
- Enable text selection and standard interactions.

### [Component] In-Book Search
#### [MODIFY] [reader_screen.dart](file:///C:/Projects/readrift/lib/screens/reader_screen.dart)
- Add a search icon to the Reader Header.
- Implement a search overlay that appears when the icon is tapped.
- **EPUB Search**: Logic to scan `EpubDocument` and jump to the matching chapter.
- **PDF Search**: Logic to use `SfPdfViewer.searchText` and jump to results.

### [Component] Yearly Reading Goals
#### [MODIFY] [auth_service.dart](file:///C:/Projects/readrift/lib/services/auth_service.dart)
- Add `updateYearlyGoal(int goal)` to update user metadata.
#### [MODIFY] [profile_screen.dart](file:///C:/Projects/readrift/lib/screens/profile_screen.dart)
- Add a "2026 Reading Challenge" card.
- Show a progress bar: (Completed Books / Yearly Goal).
- Add a dialog to set/edit the yearly goal.

### [Component] Accessibility Suite
#### [MODIFY] [reader_screen.dart](file:///C:/Projects/readrift/lib/screens/reader_screen.dart)
- **Reading Ruler**: Add a draggable, semi-transparent horizontal bar overlay to help users focus on specific lines.
- **Font Selection**: Add an option in the "Aa" menu for "OpenDyslexic".
#### [MODIFY] [theme.dart](file:///C:/Projects/readrift/lib/theme.dart)
- Register `OpenDyslexic` in the `fonts` section of the `ThemeData` logic (if applicable) or handle it locally in the Reader.

## Verification Plan

### Manual Verification
1. **Search**: Open "1984", search for "Winston", and verify the reader jumps to the correct page/chapter.
2. **PDF Selection**: Long-press text in a PDF and verify the native selection toolbar appears.
3. **Goals**: Set a goal of 50 books in Profile and verify the progress bar updates correctly.
4. **Reading Ruler**: Toggle the ruler in the reader and verify it can be moved vertically.
