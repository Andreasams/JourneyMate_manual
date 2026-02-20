# Gallery Full Page

**Route:** `/ViewAllGallery/:businessId/:businessName`
**Route Name:** `ViewAllGallery`
**Route Path:** `viewAllGallery`
**Status:** ✅ Production Ready

---

## Purpose

Full-screen photo gallery with tabbed categories and swipeable full-screen image viewing. Users can browse all business photos organized by category (Food, Menu, Interior, Outdoor) and view them at full resolution with infinite scroll navigation.

**Primary User Task:** Explore visual representation of business atmosphere and food through categorized photo browsing.

---

## Key Features

- **Tabbed Categories:** Four photo categories (Food, Menu, Interior, Outdoor)
- **Grid Layout:** 4 columns × 2 rows (8 images visible per category)
- **Tab Navigation:** Tap tabs or swipe between categories
- **Full-Screen Overlay:** Tap photo → swipeable full-screen viewer
- **Infinite Scroll:** Seamless navigation between images in both directions
- **Arrow Navigation:** Left/right arrow buttons in full-screen view
- **Single Image Mode:** Drag bounce effect for single photos
- **Translation Support:** All UI text localized (15 languages)

---

## Page Parameters

### Route Parameters
```dart
required int businessID
required String businessName
required int galleryIndex
required dynamic gallery
```

### Gallery Data Structure
```dart
{
  'food': ['url1', 'url2', ...],
  'menu': ['url1', 'url2', ...],
  'interior': ['url1', 'url2', ...],
  'outdoor': ['url1', 'url2', ...]
}
```

---

## Custom Widgets Used

| Widget | Purpose | Priority |
|--------|---------|----------|
| `GalleryTabWidget` | Tabbed gallery with 4 categories, 4×2 grid layout | ⭐⭐⭐⭐⭐ |
| `ImageGalleryWidget` | Full-screen swipeable image viewer with navigation | ⭐⭐⭐⭐⭐ |
| `ImageGalleryOverlaySwipableWidget` | Dialog wrapper for ImageGalleryWidget | ⭐⭐⭐⭐ |

---

## Custom Functions Used

| Function | Purpose |
|----------|---------|
| `getSessionDurationSeconds` | Calculate page viewing time |
| `getTranslations` | Retrieve localized text for UI elements |

---

## Custom Actions Used

| Action | Purpose | When Called |
|--------|---------|-------------|
| `trackAnalyticsEvent` | Log analytics events | Page dispose, tab changes, image views, navigation |
| `markUserEngaged` | Mark user interaction | Back button, tab tap, image tap, arrow navigation |

---

## FFAppState Usage

### Read
- `translationsCache` - Translation cache for localized UI text
- `mostRecentlyViewedBusiness` - Business data with photos array (implicit)

### Write
None

---

## Lifecycle Events

### initState
1. Create page model
2. Record page start time (`pageStartTime = getCurrentTimestamp`)
3. Initialize GalleryTabWidget (TabController, PageController)
4. Schedule image preloading (first 8 per category)

### dispose
1. Track analytics event: `page_viewed`
   - `pageName`: `'viewFullGallery'`
   - `durationSeconds`: Calculated from `pageStartTime`
2. Dispose page model
3. Dispose custom widget controllers (TabController, PageController)

---

## User Interactions

### 1. Back Button
**Trigger:** Tap back arrow (top-left)
**Action:**
```dart
await actions.markUserEngaged();
context.safePop();
```
**Result:** Navigate back to Business Profile page

### 2. Tab Switch (Tap)
**Trigger:** Tap category tab (Mad, Menu, Inde, Ude)
**Action:** `GalleryTabWidget._handleTabTap(index)`
**Result:**
- Updates active tab indicator
- Animates PageView to selected category
- Tracks `gallery_tab_changed` event with method: `'tap'`
- Tracks `gallery_tab_opened` on first interaction

### 3. Tab Switch (Swipe)
**Trigger:** Horizontal swipe on gallery grid
**Action:** `GalleryTabWidget._handlePageChanged(index)`
**Result:**
- Updates tab indicator
- Tracks `gallery_tab_changed` event with method: `'swipe'`
- Tracks `gallery_tab_opened` on first interaction

### 4. Image Tap
**Trigger:** Tap any image tile in grid
**Action:** Opens full-screen dialog with `ImageGalleryOverlaySwipableWidget`
**Result:**
- Shows full-screen image viewer
- Enables swipe navigation between images
- Tracks `image_gallery_opened` event
- Tracks `gallery_tab_opened` on first interaction

### 5. Image Swipe (in overlay)
**Trigger:** Horizontal swipe in full-screen viewer
**Action:** PageView navigation
**Result:**
- Shows next/previous image
- Tracks `image_gallery_navigation` event with method: `'swipe'`

### 6. Arrow Button (in overlay)
**Trigger:** Tap left/right arrow button
**Action:** `ImageGalleryWidget._navigateToPreviousImage()` or `_navigateToNextImage()`
**Result:**
- Animated page transition
- Tracks `image_gallery_navigation` event with method: `'arrow_left'` or `'arrow_right'`

### 7. Close Overlay
**Trigger:** Tap close button (X) or tap backdrop
**Action:** `ImageGalleryWidget._handleClose()`
**Result:**
- Dismisses dialog
- Tracks `image_gallery_closed` event
- Returns to gallery grid

---

## Translation Keys Required

### Page Elements
| Key | Default (Danish) | Purpose |
|-----|------------------|---------|
| `9wk6mbas` | "Gallery" | Page subtitle/label |

### Gallery Categories (via GalleryTabWidget)
| Key | Default | Purpose |
|-----|---------|---------|
| `gallery_food` | "Mad" | Food photos tab |
| `gallery_menu` | "Menu" | Menu photos tab |
| `gallery_interior` | "Inde" | Interior photos tab |
| `gallery_outdoor` | "Ude" | Outdoor photos tab |
| `gallery_no_images` | "Ingen billeder i denne kategori" | Empty state message |

---

## Analytics Events

### Page Level
- **`page_viewed`** (on dispose)
  - `pageName`: `'viewFullGallery'`
  - `durationSeconds`: Time spent on page

### Gallery Tab Widget
- **`gallery_tab_opened`** (first user interaction)
  - `available_tabs` - Array of category keys present
  - `available_tab_names` - Array of translated names
  - `tab_count` - Number of categories
  - `initial_tab` - Starting category key
  - `initial_tab_name` - Starting category translated name
  - `language` - Current language code

- **`gallery_tab_changed`** (tab switch)
  - `from_tab` - Previous category key
  - `to_tab` - New category key
  - `from_tab_name` - Previous translated name
  - `to_tab_name` - New translated name
  - `from_index` - Previous tab index
  - `to_index` - New tab index
  - `navigation_method` - `'tap'` or `'swipe'`
  - `available_tabs` - All available category keys
  - `tab_count` - Total number of categories
  - `language` - Current language code

### Image Gallery Widget
- **`image_gallery_opened`** (overlay opened)
  - `category` - Category name
  - `total_images` - Number of images in gallery
  - `initial_image_index` - Starting image index
  - `gallery_type` - `'carousel'` or `'single'`

- **`image_gallery_navigation`** (image swipe/arrow)
  - `category` - Category name
  - `navigation_method` - `'arrow_left'`, `'arrow_right'`, or `'swipe'`
  - `from_index` - Previous image index
  - `to_index` - New image index
  - `total_images` - Total number of images

- **`image_gallery_closed`** (overlay closed)
  - `category` - Category name
  - `close_method` - `'close_button'` or `'backdrop_tap'`
  - `final_image_index` - Last viewed image index
  - `total_images` - Total number of images

---

## App Bar Configuration

```dart
AppBar(
  backgroundColor: primaryBackground,
  automaticallyImplyLeading: false,
  leading: FlutterFlowIconButton(
    icon: Icons.arrow_back_ios_sharp,
    size: 30.0,
    onPressed: () async {
      await actions.markUserEngaged();
      context.safePop();
    },
  ),
  title: Text(businessName), // From route parameter
  centerTitle: true,
  elevation: 0.0,
)
```

---

## Migration Priority

⭐⭐⭐⭐ **High Priority** - Visual feature that enhances restaurant evaluation. Not on critical path but significantly improves user experience when viewing business details.

**Dependencies:**
- Business Profile page must exist (parent page)
- Translation system must be functional
- Analytics tracking must be set up
- Gallery data structure must match expected format

---

## Edge Cases Handled

1. **Empty category** - Shows localized empty state message
2. **Single image** - Drag bounce effect, no arrow buttons
3. **Multi-image** - Infinite scroll with virtual pages
4. **Image load error** - Shows broken image icon
5. **Image loading** - Shows progress indicator
6. **No categories** - Fallback to empty placeholder category
7. **Language switching** - Dynamic rebuild with new translations
8. **Rapid navigation** - Drag state tracking prevents accidental closes

---

## Known Limitations

1. **Image preloading limited to 8 per category** - Prevents memory issues with large galleries
2. **Grid shows only 2 rows (8 images)** - Even when `limitToEightImages: false`
3. **No image counter in overlay** - FlutterFlow implementation doesn't show "3 / 12" indicator
4. **No zoom controls** - Uses BoxFit.contain only, no pinch-to-zoom
5. **No image captions** - Data structure doesn't support per-image metadata

---

## Related Documentation

- **Implementation Bundle:** `BUNDLE.md`
- **Design Spec:** `DESIGN_README_gallery_full_page.md`
- **Parent Page:** `../02_business_profile/PAGE_README.md`
- **Translation System:** `/_reference/translation-system.md`
- **Analytics Spec:** `/_reference/analytics-events.md`

---

**Last Updated:** 2026-02-19
