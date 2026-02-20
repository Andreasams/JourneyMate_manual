# Gallery Full Page — Implementation Bundle

**Page:** `ViewAllGallery`
**Route:** `/ViewAllGallery/:businessId/:businessName`
**Status:** ✅ Production Ready
**Last Updated:** 2026-02-19

---

## Purpose

Full-screen photo gallery viewer with tabbed categories and swipeable full-screen image overlay. Users can browse all business photos organized by category (Food, Menu, Interior, Outdoor) and view them at full resolution with swipe navigation.

**Primary User Task:** Explore visual representation of business atmosphere and food through categorized photo browsing.

---

## FlutterFlow Source Files

### Main Page Widget
- **File:** `lib/profile/gallery/view_all_gallery/view_all_gallery_widget.dart`
- **Model:** `lib/profile/gallery/view_all_gallery/view_all_gallery_model.dart`

### Custom Widgets Used
1. **GalleryTabWidget**
   - **File:** `lib/custom_code/widgets/gallery_tab_widget.dart`
   - **Purpose:** Tabbed gallery with 4 categories, 4x2 grid layout per category
   - **Priority:** ⭐⭐⭐⭐⭐ (Core feature)

2. **ImageGalleryWidget**
   - **File:** `lib/custom_code/widgets/image_gallery_widget.dart`
   - **Purpose:** Full-screen swipeable image viewer with navigation controls
   - **Priority:** ⭐⭐⭐⭐⭐ (Core feature)

### Overlay Widget
- **File:** `lib/profile/gallery/image_gallery_overlay_swipable/image_gallery_overlay_swipable_widget.dart`
- **Model:** `lib/profile/gallery/image_gallery_overlay_swipable/image_gallery_overlay_swipable_model.dart`
- **Purpose:** Dialog wrapper for ImageGalleryWidget

---

## Imports & Dependencies

### Standard FlutterFlow Imports
```dart
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
```

### Custom Code Imports
```dart
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
```

### Specific Component Imports
```dart
import '/profile/gallery/image_gallery_overlay_swipable/image_gallery_overlay_swipable_widget.dart';
```

### Flutter SDK Imports
```dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
```

---

## Custom Widgets Deep Dive

### 1. GalleryTabWidget

**Location:** `lib/custom_code/widgets/gallery_tab_widget.dart`

#### Parameters
```dart
GalleryTabWidget({
  required double width,
  required double height,
  required String languageCode,
  required dynamic galleryData,
  required bool limitToEightImages,
  required dynamic translationsCache,
  required Future Function(List<String> imageUrls, int index, String categoryKey)? onImageTap,
})
```

#### Features
- **Four photo categories:** Food, Menu, Interior, Outdoor
- **Tab-based navigation** with PageView
- **Grid layout:** 4 columns × 2 rows (8 images visible per category)
- **Image precaching** for smooth loading
- **Localized category names** via translation system (15 languages)
- **Optional limiting** to first 8 images per category
- **Tap handler** for full-screen viewing
- **Automatic rebuild** when translations change

#### Category Keys & Translation Keys
| Category Key | Translation Key | Default Label |
|--------------|----------------|---------------|
| `food` | `gallery_food` | Mad |
| `menu` | `gallery_menu` | Menu |
| `interior` | `gallery_interior` | Inde |
| `outdoor` | `gallery_outdoor` | Ude |

#### Analytics Events Tracked
1. **`gallery_tab_opened`** (on first user interaction)
   - `available_tabs` - Array of category keys present
   - `available_tab_names` - Array of translated names
   - `tab_count` - Number of categories
   - `initial_tab` - Starting category key
   - `initial_tab_name` - Starting category translated name
   - `language` - Current language code

2. **`gallery_tab_changed`** (on tab switch)
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

#### Layout Constants
```dart
// Tab bar
_tabBarBottomMargin: 12.0
_tabBarBorderWidth: 2.0
_tabPaddingTop: 12.0
_tabIndicatorHeight: 2.0
_tabIndicatorSpacing: 6.0
_tabIndicatorWidthPerChar: 10.0
_tabWidth: 0.25 // 25% of parent width

// Grid layout
_gridColumnCount: 4
_gridRowCount: 2
_gridSpacing: 4.0
_gridHorizontalPadding: 2.0
_imageBorderRadius: 4.0
_maxImagesToPreload: 8
```

#### Visual Styling Constants
```dart
_backgroundColor: Colors.white
_tabBarBorderColor: Color(0xFFE0E0E0)
_selectedTabColor: Color(0xFFE9874B) // Orange accent
_unselectedTabColor: Color(0xFF14181B)
_selectedTabFontSize: 18.0
_selectedTabFontWeight: FontWeight.w400
_unselectedTabFontWeight: FontWeight.w300
```

#### State Management
- **TabController** for category switching
- **PageController** for swipe navigation
- **Image preloading** for first 8 images per category
- **Translation cache** integration for dynamic language switching

---

### 2. ImageGalleryWidget

**Location:** `lib/custom_code/widgets/image_gallery_widget.dart`

#### Parameters
```dart
ImageGalleryWidget({
  required double width,
  required double height,
  required List<String> imageUrls,
  required int currentIndex,
  required String categoryName,
  required Future Function(bool? closeAction)? onClose,
})
```

#### Features
- **Full-screen image viewer** with semi-transparent backdrop
- **Swipe navigation** between images (infinite scroll for multi-image)
- **Zoom capability** (via Image.network fit: BoxFit.contain)
- **Gesture-based navigation** with custom arrow buttons
- **Single image mode** with horizontal drag bounce effect
- **Multi-image carousel** with infinite scroll

#### Analytics Events Tracked
1. **`image_gallery_opened`**
   - `category` - Category name
   - `total_images` - Number of images in gallery
   - `initial_image_index` - Starting image index
   - `gallery_type` - `'carousel'` or `'single'`

2. **`image_gallery_navigation`**
   - `category` - Category name
   - `navigation_method` - `'arrow_left'`, `'arrow_right'`, or `'swipe'`
   - `from_index` - Previous image index
   - `to_index` - New image index
   - `total_images` - Total number of images

3. **`image_gallery_closed`**
   - `category` - Category name
   - `close_method` - `'close_button'` or `'backdrop_tap'`
   - `final_image_index` - Last viewed image index
   - `total_images` - Total number of images

#### Visual Constants
```dart
_backdropOpacity: 0.3
_closeButtonOpacity: 0.5
_closeButtonSize: 24.0
_closeButtonPadding: 8.0
_closeButtonMargin: 16.0
_maxDragOffset: 100.0
_dragAnimationDuration: Duration(milliseconds: 300)
_dragAnimationCurve: Curves.easeOutBack
```

#### Infinite Scroll Implementation
```dart
_virtualMultiplier: 1000 // Creates virtual page space for seamless looping
```

The widget calculates a virtual page index to allow infinite scrolling in both directions without visible jumps:
```dart
int _calculateVirtualPageIndex(int actualIndex) {
  final totalImages = widget.imageUrls.length;
  final virtualCenter = totalImages * (_virtualMultiplier ~/ 2);
  return (actualIndex + virtualCenter) % (totalImages * _virtualMultiplier);
}
```

#### Gesture Handling
- **Single image:** Horizontal drag with bounce effect and snap-back animation
- **Multi-image:** PageView with swipe detection and arrow button navigation
- **Drag state tracking** to prevent accidental closes during navigation
- **Reset delay** after navigation gestures (300ms)

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

## Custom Functions Used

| Function | Purpose | File |
|----------|---------|------|
| `getSessionDurationSeconds` | Calculate page viewing time | `/flutter_flow/custom_functions.dart` |
| `getTranslations` | Retrieve localized text | `/flutter_flow/custom_functions.dart` |

---

## Custom Actions Used

| Action | Purpose | When Called |
|--------|---------|-------------|
| `trackAnalyticsEvent` | Log analytics events | Page dispose, tab changes, image views |
| `markUserEngaged` | Mark user interaction | Tab tap, image tap, back button |

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
3. Initialize custom widget controllers (TabController, PageController)
4. Schedule image preloading (first 8 per category)

### dispose
1. Track analytics event: `page_viewed`
   - `pageName`: `'viewFullGallery'`
   - `durationSeconds`: Calculated from `pageStartTime`
2. Dispose page model
3. Dispose custom widget controllers

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

### 2. Tab Switch
**Trigger:** Tap category tab (Mad, Menu, Inde, Ude)
**Action:** `GalleryTabWidget._handleTabTap(index)`
**Result:**
- Updates active tab indicator
- Animates PageView to selected category
- Tracks `gallery_tab_changed` event

### 3. Tab Swipe
**Trigger:** Horizontal swipe on gallery grid
**Action:** `GalleryTabWidget._handlePageChanged(index)`
**Result:**
- Updates tab indicator
- Tracks `gallery_tab_changed` event with method: `'swipe'`

### 4. Image Tap
**Trigger:** Tap any image tile in grid
**Action:** Opens full-screen dialog with `ImageGalleryOverlaySwipableWidget`
**Result:**
- Shows full-screen image viewer
- Enables swipe navigation between images
- Tracks `image_gallery_opened` event

### 5. Image Swipe (in overlay)
**Trigger:** Horizontal swipe in full-screen viewer
**Action:** PageView navigation
**Result:**
- Shows next/previous image
- Tracks `image_gallery_navigation` event

### 6. Arrow Button (in overlay)
**Trigger:** Tap left/right arrow button
**Action:** `ImageGalleryWidget._navigateToPreviousImage()` or `_navigateToNextImage()`
**Result:**
- Animated page transition
- Tracks `image_gallery_navigation` event

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

## Analytics Events Summary

### Page Level
- **`page_viewed`** (on dispose)
  - `pageName`: `'viewFullGallery'`
  - `durationSeconds`: Time spent on page

### Gallery Tab Widget
- **`gallery_tab_opened`** (first user interaction)
- **`gallery_tab_changed`** (tab switch)

### Image Gallery Widget
- **`image_gallery_opened`** (overlay opened)
- **`image_gallery_navigation`** (image swipe/arrow)
- **`image_gallery_closed`** (overlay closed)

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

## Layout Structure

```
┌────────────────────────────────────┐
│  AppBar                            │
│  ← [businessName]                  │
├────────────────────────────────────┤
│  SafeArea                          │
│  ┌──────────────────────────────┐ │
│  │ "Gallery" label              │ │
│  ├──────────────────────────────┤ │
│  │ GalleryTabWidget             │ │
│  │ ┌──────────────────────────┐ │ │
│  │ │ Mad │Menu│Inde│ Ude      │ │ │
│  │ ├──────────────────────────┤ │ │
│  │ │ [4x2 Image Grid]         │ │ │
│  │ │ ┌───┬───┬───┬───┐        │ │ │
│  │ │ │ 1 │ 2 │ 3 │ 4 │        │ │ │
│  │ │ ├───┼───┼───┼───┤        │ │ │
│  │ │ │ 5 │ 6 │ 7 │ 8 │        │ │ │
│  │ │ └───┴───┴───┴───┘        │ │ │
│  │ └──────────────────────────┘ │ │
│  └──────────────────────────────┘ │
└────────────────────────────────────┘
```

### Dimensions
- **Gallery Container:** `width: double.infinity, height: 650.0`
- **Grid:** 4 columns, 2 rows, 4px spacing
- **Tab Bar:** Bottom margin 12px, border width 2px
- **Images:** Aspect ratio 1:1 (square), border radius 4px

---

## Full-Screen Overlay Structure

```
┌────────────────────────────────────┐
│  [X]                               │ ← Close button (top-left)
│                                    │
│        ┌────────────────┐          │
│        │                │          │
│    ←   │  Full Image    │   →      │ ← Arrow buttons (multi-image)
│        │                │          │
│        └────────────────┘          │
│                                    │
│     [Semi-transparent backdrop]    │
└────────────────────────────────────┘
```

---

## Implementation Checklist

### Core Functionality
- [x] Route with businessID, businessName, galleryIndex, gallery params
- [x] GalleryTabWidget with 4 categories
- [x] 4×2 grid layout per category
- [x] Tab navigation (tap and swipe)
- [x] Image tap opens full-screen overlay
- [x] Full-screen swipe navigation
- [x] Arrow button navigation
- [x] Close button and backdrop tap
- [x] Back button navigation

### Translation System
- [x] languageCode parameter passed to GalleryTabWidget
- [x] translationsCache from FFAppState
- [x] getTranslations() for all UI text
- [x] Dynamic rebuild on language change
- [x] Category labels localized
- [x] Empty state message localized

### Analytics Tracking
- [x] page_viewed event on dispose
- [x] gallery_tab_opened on first interaction
- [x] gallery_tab_changed on tab switch
- [x] image_gallery_opened on overlay open
- [x] image_gallery_navigation on swipe/arrow
- [x] image_gallery_closed on overlay close
- [x] All events include relevant context (language, counts, etc.)

### State Management
- [x] pageStartTime tracked
- [x] TabController initialized and disposed
- [x] PageController initialized and disposed
- [x] Image preloading for smooth UX
- [x] Drag state tracking to prevent accidental closes
- [x] markUserEngaged() on all interactive elements

### Edge Cases
- [x] Empty category handling (shows empty state message)
- [x] Single image mode (drag bounce effect, no arrows)
- [x] Multi-image mode (infinite scroll with virtual pages)
- [x] Image load error handling (broken image icon)
- [x] Image loading state (progress indicator)

---

## Migration Priority

⭐⭐⭐⭐ **High Priority** - Visual feature that enhances restaurant evaluation. Not on critical path but significantly improves user experience when viewing business details.

**Dependencies:**
- Business Profile page must exist (parent page)
- Translation system must be functional
- Analytics tracking must be set up
- Gallery data structure must match expected format

---

## Testing Requirements

### Unit Tests
- [ ] Gallery data parsing for all four categories
- [ ] Empty category handling
- [ ] Translation key mapping
- [ ] Virtual page index calculation for infinite scroll

### Widget Tests
- [ ] Tab switching (tap and swipe)
- [ ] Image tap opens overlay
- [ ] Overlay navigation (swipe and arrows)
- [ ] Close button dismisses overlay
- [ ] Backdrop tap dismisses overlay
- [ ] Back button navigation

### Integration Tests
- [ ] Full user flow: Profile → Gallery → Tab Switch → Image View → Close → Back
- [ ] Language switching updates all UI text
- [ ] Analytics events fire correctly
- [ ] Image loading and error states
- [ ] Multi-device layout (different screen sizes)

### Edge Case Tests
- [ ] Gallery with only 1 category
- [ ] Gallery with only 1 image
- [ ] Category with no images (empty state)
- [ ] Category with 100+ images (performance)
- [ ] Rapid tab switching
- [ ] Rapid image swiping

---

## Known Limitations

1. **Image preloading limited to 8 per category** - Prevents memory issues with large galleries
2. **Grid shows only 8 images per category** - When `limitToEightImages: false`, still shows only 2 rows (8 images) per view
3. **No image counter in overlay** - FlutterFlow implementation doesn't show "3 / 12" indicator
4. **No zoom controls** - Uses BoxFit.contain only, no pinch-to-zoom
5. **No image captions** - Data structure doesn't support per-image metadata

---

## Future Enhancements

1. Add image counter display in full-screen overlay ("3 / 12")
2. Add pinch-to-zoom in full-screen view
3. Add image captions/descriptions support
4. Add "Share" button for individual images
5. Add lazy loading for categories with many images
6. Add thumbnail optimization (separate thumbnail URLs)
7. Add image download option
8. Add "Report inappropriate image" option

---

## Related Documentation

- **Design Spec:** `DESIGN_README_gallery_full_page.md`
- **Page Overview:** `PAGE_README.md`
- **Parent Page:** `../02_business_profile/PAGE_README.md`
- **Translation System:** `/_reference/translation-system.md`
- **Analytics Spec:** `/_reference/analytics-events.md`

---

**Document Version:** 1.0
**Created:** 2026-02-19
**Author:** Claude Code

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(translationsCacheProvider)` | `translationsCache` | Gallery category labels (food, menu, interior, outdoor) in GalleryTabWidget |

### Writes
None. Gallery tab/photo state is local. Analytics events are fire-and-forget POST calls that do not mutate any provider.

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation on dispose |
