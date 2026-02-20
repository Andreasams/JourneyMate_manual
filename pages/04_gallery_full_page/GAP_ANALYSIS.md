# Gallery Full Page — Gap Analysis

**Purpose:** Identify functional differences between JSX v2 design and FlutterFlow implementation

**Methodology:** Compare DESIGN_README_gallery_full_page.md (JSX v2) with PAGE_README.md + BUNDLE.md (FlutterFlow)

**Date:** 2026-02-19

---

## Gap Categories

- **A1**: Buildable with existing data (Frontend logic after API response)
- **A2**: Buildable with existing data (Backend logic in BuildShip before return)
- **B**: Requires BuildShip API changes
- **C**: Translation infrastructure gaps (new keys needed)
- **D**: Known missing features (user-identified, not in current scope)

---

## Summary

| Category | Count | Description |
|----------|-------|-------------|
| A1 | 2 | Frontend display logic |
| A2 | 0 | Backend processing logic |
| B | 0 | API endpoint changes |
| C | 2 | Translation keys needed |
| D | 0 | Known future features |
| **Total** | **4** | **Functional gaps identified** |

---

## Observation: FlutterFlow Far More Comprehensive Than JSX Design

The FlutterFlow implementation is **significantly more feature-rich** than the JSX v2 design. Features in FlutterFlow but NOT in JSX:

1. **Full-screen image viewer** - `ImageGalleryOverlaySwipableWidget` with swipe navigation
2. **Arrow button navigation** - Left/right arrows in full-screen view
3. **Infinite scroll** - Virtual page system for seamless looping
4. **Single image mode** - Drag bounce effect for galleries with one photo
5. **Tab swipe navigation** - Swipe between categories (JSX only shows tap)
6. **Image preloading** - First 8 images per category for smooth UX
7. **Comprehensive analytics** - 6 different events tracked (tab opened, tab changed, image opened, navigation, closed)
8. **Translation system** - All UI text localized (15 languages)
9. **Empty state handling** - Shows "Ingen billeder i denne kategori" message
10. **Image loading states** - Progress indicators and error handling

**All of these enhancements should be preserved during migration.**

---

## Visual Layout Differences (Not Gaps, But Design Decisions)

The JSX design and FlutterFlow implementation have different grid layouts:

| Aspect | JSX v2 Design | FlutterFlow Implementation |
|--------|---------------|----------------------------|
| **Grid Columns** | 3 columns | 4 columns |
| **Grid Rows Visible** | Scrollable (many rows) | 2 rows (8 images) - INCORRECT FOR FULL PAGE |
| **Gap Size** | 8px | 4px |
| **Image Size** | ~111px × 111px | Calculated from 4-col layout |
| **Page Title** | "Galleri" (static) | Business name (dynamic) |

**CRITICAL: Gallery Full Page vs Business Profile Gallery Section:**

The GalleryTabWidget is used in TWO different contexts with DIFFERENT requirements:

1. **Business Profile page (gallery section):**
   - 4 columns × 2 rows = 8 images FIXED ✓ CORRECT
   - Preview/teaser to encourage clicking "Se alle billeder →"

2. **Gallery Full page (this page):**
   - 4 columns × UNLIMITED rows (scrollable) ✓ REQUIRED
   - Shows ALL images, user scrolls vertically

**Current Issue:** FlutterFlow limits to 8 images on BOTH pages. Gallery Full page needs unlimited scrolling.

**Recommendation:**
- Keep 4-column layout (correct)
- Add `maxRows` parameter to GalleryTabWidget
- Business Profile passes `maxRows: 2` (preview)
- Gallery Full passes `maxRows: null` (unlimited)

---

## Detailed Gap Analysis

### Gap A1.1: Grid Column Count

**JSX v2 Design:**
- 3-column grid layout
- Calculated tile size: 111px × 111px (from 390px width - 40px margins - 16px gaps)
- Code reference: `DESIGN_README_gallery_full_page.md` lines 122-146

**FlutterFlow Implementation:**
- 4-column grid layout
- 4×2 = 8 images visible per category
- 4px gap spacing
- Code reference: `BUNDLE.md` lines 134-150

**Gap:**
Visual design difference, not a functional gap. FlutterFlow's 4-column layout provides better mobile UX by:
- Showing more images in limited vertical space
- Creating cleaner visual rhythm with even number of columns
- Matching common mobile gallery patterns

**Architecture Recommendation:** Frontend (A1) - Visual adjustment
- Keep FlutterFlow's 4-column layout (ground truth)
- Can be adjusted via `_gridColumnCount` constant if user requests 3-column
- No API changes needed

**Implementation Notes:**
- This is a design preference, not a bug
- User should decide if they want 3-column (JSX) or 4-column (FlutterFlow)
- Both are valid mobile gallery patterns

---

### Gap A1.2: Visible Image Count (Scrollable vs Fixed)

**JSX v2 Design:**
- Scrollable grid showing "many" rows
- User can scroll through all photos in one continuous view
- No explicit limit on visible images
- Code reference: `DESIGN_README_gallery_full_page.md` lines 71-83

**FlutterFlow Implementation:**
- Fixed 2-row display (8 images visible)
- Even when `limitToEightImages: false` parameter exists, only shows 8 images
- Code reference: `BUNDLE.md` lines 581-582 (Known Limitations)

**User Clarification (2026-02-19):**
The 8-image limit behavior is DIFFERENT between pages:

1. **Business Profile page (gallery section):**
   - 4 columns × 2 rows = **8 images FIXED** per category ✓ CORRECT
   - This is a preview/teaser
   - Tap "Se alle billeder →" button to go to Gallery Full page

2. **Gallery Full page:**
   - 4 columns × **UNLIMITED rows** (scrollable)
   - Shows ALL images for the category
   - User scrolls vertically to see everything
   - This is the complete gallery experience

**Gap:**
FlutterFlow's GalleryTabWidget currently limits to 8 images even on the Gallery Full page. This is incorrect for the full-page context.

**Architecture Recommendation:** Frontend (A1) - Required Fix
- GalleryTabWidget needs a parameter to control row limit behavior:
  - `maxRows: 2` (Business Profile usage)
  - `maxRows: null` (Gallery Full page usage - unlimited scrolling)
- Modify GalleryTabWidget to support unlimited rows when maxRows is null
- Ensure vertical scrolling works correctly for many images
- Keep 4-column layout as-is (correct)

**Implementation Notes:**
- The widget is used in TWO contexts with different requirements
- Business Profile: Preview (fixed 8)
- Gallery Full: Complete view (scrollable all)
- Solution: Make row limit configurable via parameter

---

### Gap C.1: Page Heading Translation

**JSX v2 Design:**
- Static heading: "Galleri"
- Code reference: `DESIGN_README_gallery_full_page.md` lines 66, 102

**FlutterFlow Implementation:**
- App bar shows `businessName` parameter (e.g., "Restaurant Name")
- Separate "Gallery" label shown below app bar using key `9wk6mbas`
- Code reference: `PAGE_README.md` lines 172-176

**No Gap:** Translation key `9wk6mbas` already exists for "Gallery" label. FlutterFlow design is more informative by showing business name in app bar.

---

### Gap C.2: Gallery Category Translations

**JSX v2 Design:**
- Four category tabs: "Mad", "Menu", "Inde", "Ude"
- Hardcoded in JSX as Danish strings
- Code reference: `DESIGN_README_gallery_full_page.md` lines 238-249

**FlutterFlow Implementation:**
- Same four categories with translation keys
- Translation keys: `gallery_food`, `gallery_menu`, `gallery_interior`, `gallery_outdoor`
- Empty state key: `gallery_no_images`
- Code reference: `PAGE_README.md` lines 177-185

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `gallery_food` | Food photos tab | Food | Mad |
| `gallery_menu` | Menu photos tab | Menu | Menu |
| `gallery_interior` | Interior photos tab | Interior | Inde |
| `gallery_outdoor` | Outdoor photos tab | Outdoor | Ude |
| `gallery_no_images` | Empty state message | No images in this category | Ingen billeder i denne kategori |

**Note:** Key `9wk6mbas` ("Gallery" label) already exists in FlutterFlow.

---

### Gap C.3: Page Label Translation

**Covered in Gap C.1**

Translation key `9wk6mbas` already exists for "Gallery" / "Galleri" label.

---

## Features in FlutterFlow NOT in JSX Design

These are enhancements that exist in FlutterFlow but weren't specified in the JSX v2 design. They should be preserved during migration.

### Enhancement 1: Full-Screen Image Viewer
- **Widget:** `ImageGalleryOverlaySwipableWidget` + `ImageGalleryWidget`
- **Purpose:** Full-screen swipeable image viewing with navigation controls
- **Features:**
  - Swipe navigation between images
  - Left/right arrow buttons
  - Close button and backdrop tap
  - Infinite scroll for multi-image galleries
  - Drag bounce effect for single images
  - Semi-transparent backdrop
- **Keep:** Yes, essential feature for image galleries

### Enhancement 2: Tab Swipe Navigation
- **Feature:** Swipe horizontally on grid to change categories
- **Implementation:** PageView with PageController
- **Analytics:** Tracks `gallery_tab_changed` with method: `'swipe'`
- **Keep:** Yes, improves mobile UX and matches user expectations

### Enhancement 3: Image Preloading
- **Feature:** Preloads first 8 images per category for smooth display
- **Purpose:** Prevents loading delays when switching tabs
- **Constant:** `_maxImagesToPreload: 8`
- **Keep:** Yes, essential for performance

### Enhancement 4: Comprehensive Analytics
- **Events tracked:**
  1. `page_viewed` - Page duration on dispose
  2. `gallery_tab_opened` - First user interaction
  3. `gallery_tab_changed` - Tab switching with method (tap/swipe)
  4. `image_gallery_opened` - Full-screen overlay opened
  5. `image_gallery_navigation` - Image navigation with method (swipe/arrow)
  6. `image_gallery_closed` - Overlay closed with method (button/backdrop)
- **Keep:** Yes, valuable insights for UX optimization

### Enhancement 5: Translation System Integration
- **Feature:** All UI text localized via translation keys
- **Languages:** 15 languages supported
- **Dynamic updates:** Widget rebuilds when language changes
- **Parameters:** `languageCode`, `translationsCache` passed to all widgets
- **Keep:** Yes, critical for international launch

### Enhancement 6: Empty State Handling
- **Feature:** Shows "Ingen billeder i denne kategori" when category has no images
- **Translation key:** `gallery_no_images`
- **Keep:** Yes, prevents confusion when categories are empty

### Enhancement 7: Loading & Error States
- **Features:**
  - Progress indicator during image loading
  - Broken image icon on load error
  - Graceful degradation
- **Keep:** Yes, essential for production robustness

### Enhancement 8: Infinite Scroll Implementation
- **Feature:** Virtual page system for seamless looping in full-screen viewer
- **Implementation:** `_virtualMultiplier: 1000` creates virtual page space
- **Purpose:** Swipe endlessly in both directions without visible jumps
- **Keep:** Yes, improves UX for browsing many images

---

## Migration Notes

### High Priority Gaps
1. **Gap C.2**: Gallery category translations (5 keys needed)

### Medium Priority Gaps
1. **Gap A1.2**: Visible image count (decide if scrollable grid is needed)
2. **Gap A1.1**: Grid column count (3 vs 4 columns - design decision)

### Low Priority Gaps
None identified.

---

## Architecture Summary

### Frontend Logic (A1) - 2 gaps
- Grid column count (3 vs 4) - visual design decision
- Visible image count (scrollable vs 8-image fixed) - UX decision

### Backend Logic (A2) - 0 gaps
No gaps requiring backend processing before returning data to Flutter.

### API Changes (B) - 0 gaps
Gallery data structure is sufficient. No BuildShip modifications needed.

### Translation Keys (C) - 2 gaps
- 5 translation keys needed for gallery categories
- 1 existing key documented for completeness (`9wk6mbas`)

### Known Missing (D) - 0 gaps
No features explicitly marked as "not in current scope" by user.

---

## Design Decisions to Make

### Decision 1: Grid Layout (3-column vs 4-column)

**Option A: Keep FlutterFlow's 4-column layout**
- Pros: Tested, optimized for mobile, shows 8 images clearly
- Cons: Deviates from JSX design
- Recommendation: ✅ **Keep 4-column** (ground truth)

**Option B: Change to JSX's 3-column layout**
- Pros: Matches JSX design specification
- Cons: May not fit mobile screens as well, requires refactoring
- Recommendation: ❌ Not recommended unless explicitly requested

### Decision 2: Visible Image Count (Fixed 8 vs Scrollable All)

**Option A: Keep 8-image fixed display**
- Pros: Clean preview, full-screen overlay for browsing all
- Cons: Users must tap image to see more than 8
- Recommendation: ⚠️ **Verify intent** - Is this a preview or full gallery?

**Option B: Make grid scrollable to show all images**
- Pros: Matches JSX design, immediate access to all photos
- Cons: May overwhelm users, increases page height
- Recommendation: ⚠️ **User decides** - Both approaches are valid

---

## Next Steps

1. **Add translation keys to MASTER_TRANSLATION_KEYS.md**
   - 5 gallery category keys
   - Include English and Danish translations

2. **Clarify design decisions with user**
   - Confirm 3-column vs 4-column grid preference
   - Confirm fixed 8 images vs scrollable all images

3. **Verify FlutterFlow implementations**
   - Test GalleryTabWidget with different image counts
   - Test ImageGalleryWidget with single/multiple images
   - Confirm analytics events fire correctly

4. **Continue gap analysis for remaining pages**
   - Settings page
   - Welcome/Onboarding
   - Contact Details
   - User Profile
   - Map View

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete
**Total Gaps:** 4 (2 frontend design decisions + 0 backend + 0 API + 2 translation + 0 known missing)

**Key Finding:** FlutterFlow implementation is FAR more comprehensive than JSX design with full-screen viewer, infinite scroll, swipe navigation, analytics, and translation system. All enhancements should be preserved.

**Design Decisions Required:** Grid layout (3 vs 4 columns) and visible image count (fixed vs scrollable).
