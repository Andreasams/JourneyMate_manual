# GalleryTabWidget — Master Documentation

**File:** `lib/custom_code/widgets/gallery_tab_widget.dart`
**Type:** Custom StatefulWidget
**Phase:** FlutterFlow export (to be migrated in Phase 3)

---

## Purpose

The `GalleryTabWidget` is a tabbed gallery component for displaying categorized restaurant images. It provides a tab-based interface for navigating between four image categories (Food, Menu, Interior, Outdoor) with a grid layout displaying up to 8 images per category. The widget includes:

- Four predefined image categories with localized tab labels
- Tab-based navigation via taps or swipe gestures
- 4-column × 2-row grid layout with 4px spacing
- Image preloading for smooth performance
- Full translation system integration (15 languages)
- Analytics tracking for tab interactions
- Optional image limiting to first 8 images per category
- Tap handler for full-screen image viewing
- Automatic rebuild when translations change

**Design context:** This widget is used on the Business Profile page (inline preview) and the View All Gallery page (full-screen view). It implements the design system's orange accent color (#E8751A) for selected tabs and follows the established grid layout patterns.

---

## Function Signature

```dart
class GalleryTabWidget extends StatefulWidget {
  const GalleryTabWidget({
    super.key,
    this.width,
    this.height,
    required this.galleryData,
    required this.languageCode,
    required this.translationsCache,
    this.onImageTap,
    this.limitToEightImages = false,
  });

  final double? width;
  final double? height;
  final dynamic galleryData;
  final String languageCode;
  final dynamic translationsCache;
  final Future Function(List<String> imageUrls, int index, String categoryKey)? onImageTap;
  final bool limitToEightImages;
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `galleryData` | `dynamic` | JSON object containing categorized image URLs with keys: `food`, `menu`, `interior`, `outdoor`. Each key maps to a list of image URL strings. If a category is missing or empty, it won't appear in the tabs. |
| `languageCode` | `String` | ISO language code for translation (e.g., `'en'`, `'da'`, `'de'`). Must match one of the 15 supported languages. |
| `translationsCache` | `dynamic` | JSON object containing all UI translations keyed by `translationKey`. Passed through to `getTranslations()` function. |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `double?` | `null` | Widget width. If null, uses parent width constraints. |
| `height` | `double?` | `null` | Widget height. If null, uses parent height constraints. |
| `onImageTap` | `Future Function(List<String>, int, String)?` | `null` | Callback when user taps an image. Receives: image URLs list, tapped index, category key. Typically used to open full-screen viewer. |
| `limitToEightImages` | `bool` | `false` | If true, limits display to first 8 images per category. Used on Business Profile page to show preview. Set to false on View All Gallery page. |

### Gallery Data Structure

```dart
{
  "food": ["url1", "url2", "url3", ...],
  "menu": ["url1", "url2", ...],
  "interior": ["url1", "url2", ...],
  "outdoor": ["url1", "url2", ...]
}
```

**Notes:**
- Categories with no images or missing keys are automatically excluded from tabs
- If all categories are empty, displays a single placeholder tab with empty state message
- Category order is always: Food → Menu → Interior → Outdoor (regardless of data order)

---

## Dependencies

### Flutter/Dart Packages
- `flutter/material.dart` — Core UI framework
- `SingleTickerProviderStateMixin` — For TabController animation

### Custom Imports
- `/flutter_flow/flutter_flow_theme.dart` — Not actively used (FlutterFlow artifact)
- `/flutter_flow/flutter_flow_util.dart` — Not actively used (FlutterFlow artifact)
- `/flutter_flow/custom_functions.dart` — Provides `getTranslations()` function

### Custom Actions
- `markUserEngaged()` — Marks user as engaged (custom action import)
- `trackAnalyticsEvent(String eventName, Map<String, dynamic> properties)` — Analytics tracking

### Translation Function
```dart
String getTranslations(
  String languageCode,
  String translationKey,
  dynamic translationsCache
)
```

---

## FFAppState Usage

### State Variables Read

**None.** This widget does NOT directly access FFAppState.

All data is passed via parameters from parent pages:
- Business Profile page passes: `FFAppState().mostRecentlyViewedBusiness.gallery`
- View All Gallery page passes: `widget.gallery` (passed as page parameter)
- Both pages pass: `FFAppState().translationsCache`, `FFLocalizations.of(context).languageCode`

### State Variables Written

**None.** This widget is purely presentational and does not modify app state.

### State Management Pattern

**Stateful widget with local state only:**
- `_tabController` — TabController for tab selection state
- `_pageController` — PageController for swipe gesture handling
- `_categories` — Parsed list of GalleryCategory objects
- `_hasTrackedOpened` — Boolean flag to track if gallery opened event fired

**No persistent state.** Tab selection resets on widget disposal.

---

## Translation Keys

The widget uses 5 translation keys via `getTranslations()`:

| Translation Key | Usage | Example (English) |
|----------------|-------|-------------------|
| `gallery_food` | Food tab label | "Food" |
| `gallery_menu` | Menu tab label | "Menu" |
| `gallery_interior` | Interior tab label | "Interior" |
| `gallery_outdoor` | Outdoor tab label | "Outdoor" |
| `gallery_no_images` | Empty state message | "No images available" |

### Translation System Integration

```dart
String _getUIText(String key) {
  return getTranslations(widget.languageCode, key, widget.translationsCache);
}

String _getCategoryLabel(String categoryKey) {
  final translationKey = _getTranslationKey(categoryKey);
  return _getUIText(translationKey);
}
```

**Translation reactivity:**
- Widget rebuilds automatically when `translationsCache` or `languageCode` changes
- Implemented via `didUpdateWidget()` lifecycle method
- Gallery data is re-parsed with new translations to update tab labels

---

## Analytics Tracking

### Event: `gallery_tab_opened`

**Fired:** On first user interaction (tap, swipe, or image tap)

**Purpose:** Records which tabs are available so usage rates can be calculated for tabs that aren't clicked.

**Properties:**
```dart
{
  'available_tabs': ['food', 'menu', 'interior', 'outdoor'],
  'available_tab_names': ['Food', 'Menu', 'Interior', 'Outdoor'],
  'tab_count': 4,
  'initial_tab': 'food',
  'initial_tab_name': 'Food',
  'language': 'en'
}
```

**Important:** NOT fired on widget initialization. Only fires when user actually interacts with the gallery. This prevents false "opened" events when the widget is rendered but not used.

### Event: `gallery_tab_changed`

**Fired:** When user navigates between tabs (excludes same-tab taps)

**Properties:**
```dart
{
  'from_tab': 'food',
  'to_tab': 'menu',
  'from_tab_name': 'Food',
  'to_tab_name': 'Menu',
  'from_index': 0,
  'to_index': 1,
  'navigation_method': 'tap', // or 'swipe'
  'available_tabs': ['food', 'menu', 'interior', 'outdoor'],
  'tab_count': 4,
  'language': 'en'
}
```

**Navigation methods:**
- `'tap'` — User tapped on a tab label
- `'swipe'` — User swiped horizontally on the PageView

**Analytics pattern:** Includes `available_tabs` in every event so analysts can calculate:
- Which tabs were NOT selected (denominator for conversion rates)
- Tab usage distribution relative to what was available
- Language-specific tab preferences

---

## Widget Layout & Styling

### Overall Structure

```
Container (background: white)
├─ Column
   ├─ TabBar Container (bottom border, 12px margin)
   │  └─ Row (equal-width tabs, 25% each)
   │     ├─ Tab 1: Food
   │     ├─ Tab 2: Menu
   │     ├─ Tab 3: Interior
   │     └─ Tab 4: Outdoor
   └─ Expanded PageView
      └─ GridView (4 columns × 2 rows)
```

### Layout Constants

```dart
// Tab bar spacing
static const double _tabBarBottomMargin = 12.0;
static const double _tabBarBorderWidth = 2.0;
static const double _tabPaddingTop = 12.0;
static const double _tabIndicatorHeight = 2.0;
static const double _tabIndicatorSpacing = 6.0;
static const double _tabIndicatorWidthPerChar = 10.0;
static const double _tabWidth = 0.25; // 25% of parent width

// Grid layout
static const int _gridColumnCount = 4;
static const int _gridRowCount = 2;
static const double _gridSpacing = 4.0;
static const double _gridHorizontalPadding = 2.0;
static const double _imageBorderRadius = 4.0;
```

### Visual Styling

```dart
// Colors
static const Color _backgroundColor = Colors.white;
static const Color _tabBarBorderColor = Color(0xFFE0E0E0);
static const Color _selectedTabColor = Color(0xFFE9874B); // Orange accent
static const Color _unselectedTabColor = Color(0xFF14181B); // Near-black

// Typography
static const double _selectedTabFontSize = 18.0;
static const FontWeight _selectedTabFontWeight = FontWeight.w400;
static const FontWeight _unselectedTabFontWeight = FontWeight.w300;

// Tab indicator (underline)
Container(
  height: 2.0,
  width: label.length * 10.0, // Dynamic width based on text length
  color: Color(0xFFE9874B),
)
```

### Tab Indicator Behavior

The tab indicator (orange underline) width is **dynamically calculated** based on label length:
```dart
width: label.length * _tabIndicatorWidthPerChar
```

This ensures proper visual balance across different languages where tab labels have varying lengths.

### Grid Height Calculation

Grid height is calculated to fit exactly 2 rows:
```dart
double _calculateGridHeight() {
  final containerWidth = widget.width ?? MediaQuery.of(context).size.width;
  final imageWidth = (containerWidth - (_gridColumnCount - 1) * _gridSpacing) / _gridColumnCount;
  return (imageWidth * _gridRowCount) + _gridSpacing;
}
```

---

## Image Loading & Performance

### Image Preloading

**When:** Scheduled after first frame via `WidgetsBinding.instance.addPostFrameCallback`

**What:** Preloads first 8 images of each category using `precacheImage()`

**Why:** Ensures smooth display when user navigates between tabs, especially important for network images.

```dart
void _preloadImages() {
  for (var category in _categories) {
    final imagesToPreload = category.images.take(_maxImagesToPreload);
    for (var imageUrl in imagesToPreload) {
      precacheImage(NetworkImage(imageUrl), context);
    }
  }
}
```

**Note:** Only first 8 images per category are preloaded to balance performance with memory usage. Additional images load on-demand as user scrolls.

### Image Loading States

**Loading state:**
```dart
Container(
  color: Colors.grey[200],
  child: CircularProgressIndicator(
    value: loadingProgress, // Shows actual progress
    strokeWidth: 1.0,
    color: Color(0xFFE9874B), // Orange accent
  ),
)
```

**Error state:**
```dart
Container(
  color: Colors.grey[300],
  child: Icon(Icons.broken_image, color: Colors.grey),
)
```

**Both states** maintain grid aspect ratio and don't cause layout shifts.

---

## User Interaction Handling

### Tab Selection (Tap)

```dart
void _handleTabTap(int index) {
  final previousIndex = _tabController.index;
  _ensureOpenedTracking(); // Track gallery opened on first tap
  markUserEngaged(); // Mark user as engaged

  _pageController.animateToPage(
    index,
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  _trackTabChange(previousIndex, index, 'tap');
}
```

**Behavior:**
- Updates TabController state
- Animates PageView to selected page (300ms ease-in-out)
- Marks user as engaged
- Tracks analytics event

### Page Swipe

```dart
void _handlePageChanged(int index) {
  final previousIndex = _tabController.index;
  _ensureOpenedTracking(); // Track gallery opened on first swipe

  setState(() {
    _tabController.animateTo(index);
  });

  _trackTabChange(previousIndex, index, 'swipe');
}
```

**Behavior:**
- Updates tab indicator to match swiped page
- Tracks analytics event with `'swipe'` method
- No `markUserEngaged()` call (swipe is implicit engagement)

### Image Tap

```dart
Future<void> _handleImageTap(List<String> images, int index) async {
  _ensureOpenedTracking(); // Track gallery opened on first image tap
  markUserEngaged(); // Mark user as engaged

  final currentCategory = _categories[_tabController.index];
  if (widget.onImageTap != null) {
    await widget.onImageTap!(images, index, currentCategory.key);
  }
}
```

**Callback receives:**
- `images` — Full list of images in current category
- `index` — Index of tapped image (0-based)
- `categoryKey` — Category identifier (`'food'`, `'menu'`, `'interior'`, `'outdoor'`)

**Typical usage:** Open full-screen image viewer dialog starting at tapped image.

---

## Usage Examples

### Example 1: Business Profile Page (Inline Preview)

**Context:** Show first 8 images of each category in a compact preview on Business Profile page. Tapping an image opens full-screen viewer which then navigates to View All Gallery page.

```dart
// From: lib/profile/business_information/business_profile/business_profile_widget.dart

custom_widgets.GalleryTabWidget(
  width: double.infinity,
  height: double.infinity, // Fills parent container (290px fixed height)
  languageCode: FFLocalizations.of(context).languageCode,
  galleryData: getJsonField(
    FFAppState().mostRecentlyViewedBusiness,
    r'$.gallery',
  ),
  limitToEightImages: true, // Show only first 8 images
  translationsCache: FFAppState().translationsCache,
  onImageTap: (imageUrls, index, categoryKey) async {
    // Navigate to full-screen viewer
    await Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        child: FlutterFlowExpandedImageView(
          image: Image.network(
            imageUrls[index],
            fit: BoxFit.contain,
          ),
          allowRotation: false,
          useHeroAnimation: false,
        ),
      ),
    );

    // Then navigate to View All Gallery page
    context.pushNamed(
      'viewAllGallery',
      queryParameters: {
        'gallery': serializeParam(
          getJsonField(
            FFAppState().mostRecentlyViewedBusiness,
            r'$.gallery',
          ),
          ParamType.JSON,
        ),
        'initialCategory': serializeParam(categoryKey, ParamType.String),
      }.withoutNulls,
    );
  },
)
```

**Key points:**
- `limitToEightImages: true` — Shows compact preview (8 images max per category)
- Fixed height container (290px set by parent)
- Gallery data comes from `FFAppState().mostRecentlyViewedBusiness.gallery`
- Two-step navigation: full-screen viewer → View All Gallery page

---

### Example 2: View All Gallery Page (Full View)

**Context:** Show all images in a dedicated full-screen gallery page. Tapping an image opens a modal dialog with the full-screen viewer.

```dart
// From: lib/profile/gallery/view_all_gallery/view_all_gallery_widget.dart

custom_widgets.GalleryTabWidget(
  width: double.infinity,
  height: double.infinity, // Fills entire screen (minus app bar)
  languageCode: FFLocalizations.of(context).languageCode,
  galleryData: widget.gallery!, // Passed as page parameter
  limitToEightImages: false, // Show all images
  translationsCache: FFAppState().translationsCache,
  onImageTap: (imageUrls, index, categoryKey) async {
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: AlignmentDirectional(0.0, 0.0),
          child: FlutterFlowExpandedImageView(
            image: Image.network(
              imageUrls[index],
              fit: BoxFit.contain,
            ),
            allowRotation: false,
            useHeroAnimation: false,
          ),
        );
      },
    );
  },
)
```

**Key points:**
- `limitToEightImages: false` — Shows all images (no limit)
- Full-screen height (fills SafeArea minus app bar)
- Gallery data passed as page parameter from previous page
- Modal dialog for full-screen viewer (stays on same page)
- `initialCategory` page parameter can be used to set starting tab (not shown in widget usage)

---

### Example 3: Custom Gallery Data Structure

**Context:** Building gallery data dynamically from API response.

```dart
// Example API response transformation
final apiResponse = await BuildShipService.getRestaurantDetails(restaurantId);
final rawGallery = apiResponse['gallery'];

// Transform to expected structure
final galleryData = {
  'food': (rawGallery['food_images'] as List?)
      ?.map((img) => img['url'] as String)
      .toList() ?? [],
  'menu': (rawGallery['menu_images'] as List?)
      ?.map((img) => img['url'] as String)
      .toList() ?? [],
  'interior': (rawGallery['interior_images'] as List?)
      ?.map((img) => img['url'] as String)
      .toList() ?? [],
  'outdoor': (rawGallery['outdoor_images'] as List?)
      ?.map((img) => img['url'] as String)
      .toList() ?? [],
};

// Use in widget
GalleryTabWidget(
  galleryData: galleryData,
  languageCode: currentLanguage,
  translationsCache: translationsCache,
  limitToEightImages: false,
)
```

**Important:** Category keys MUST be exactly `'food'`, `'menu'`, `'interior'`, `'outdoor'` (lowercase, no typos).

---

## State Management Details

### Local State Variables

```dart
class _GalleryTabWidgetState extends State<GalleryTabWidget>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  late PageController _pageController;
  late List<GalleryCategory> _categories;
  bool _hasTrackedOpened = false;
}
```

### Tab and Page Synchronization

The widget maintains **two-way synchronization** between TabController and PageController:

**Tab tap → Page change:**
```dart
void _handleTabTap(int index) {
  _pageController.animateToPage(index, ...);
  // TabController updates implicitly via PageView.onPageChanged
}
```

**Page swipe → Tab update:**
```dart
void _handlePageChanged(int index) {
  setState(() {
    _tabController.animateTo(index);
  });
}
```

**Why both controllers?**
- `TabController` — Manages tab selection state and indicator position
- `PageController` — Handles swipe gesture and page animation
- Both are needed for smooth tab/swipe interaction

### Gallery Data Parsing

**When:** Called in `initState()` and `didUpdateWidget()` (when translations change)

**Process:**
1. Iterates through category order: `['food', 'menu', 'interior', 'outdoor']`
2. For each category:
   - Check if `galleryData[categoryKey]` exists and has images
   - Extract image URLs as string list
   - Apply `limitToEightImages` if enabled
   - Create `GalleryCategory` object with translated label
3. If no categories have images, add placeholder category with empty state

**Result:** `_categories` list containing only categories with images, in fixed order.

### Lifecycle: Translation Changes

```dart
@override
void didUpdateWidget(covariant GalleryTabWidget oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.languageCode != oldWidget.languageCode) {
    _parseGalleryData(); // Re-parse with new translations
    setState(() {}); // Trigger rebuild
  }
}
```

**Why:** Tab labels need to update immediately when user changes language in app settings, without requiring page navigation.

---

## Error Handling

### Missing or Invalid Gallery Data

```dart
void _parseGalleryData() {
  _categories = [];
  // ... parse categories ...

  _ensureAtLeastOneCategory(); // Fallback to empty state
}

void _ensureAtLeastOneCategory() {
  if (_categories.isEmpty) {
    _categories.add(GalleryCategory(
      key: _emptyKey,
      label: 'Gallery',
      images: [],
    ));
  }
}
```

**Behavior:** If all categories are empty or missing, shows single tab with "Gallery" label and empty state message.

### Image Load Failures

**Error widget displayed:**
```dart
Container(
  color: Colors.grey[300],
  child: Icon(Icons.broken_image, color: Colors.grey),
)
```

**Graceful degradation:** Failed images don't crash the widget, they just show broken image icon in grid.

### Null Safety

**Parameter validation:**
- `width` / `height` — Optional, falls back to `MediaQuery` / parent constraints
- `onImageTap` — Optional, images are non-interactive if null
- `galleryData` — Required but validated before access
- `languageCode` / `translationsCache` — Required, passed through to translation function

**Image URL validation:** Assumes all URLs in `galleryData` are valid strings. No URL format validation.

### Analytics Error Handling

```dart
trackAnalyticsEvent(
  'gallery_tab_opened',
  { ... },
).catchError((error) {
  debugPrint('⚠️ Failed to track gallery opened: $error');
});
```

**Strategy:** Analytics errors are caught and logged but don't interrupt user experience. Silent failure with debug logging only.

---

## Testing Checklist

### Unit Tests

- [ ] **Gallery data parsing:**
  - [ ] All four categories present with images
  - [ ] Some categories missing or empty (tabs should exclude them)
  - [ ] All categories empty (should show placeholder tab)
  - [ ] Invalid data types (non-list values, non-string URLs)

- [ ] **Image limiting:**
  - [ ] `limitToEightImages: true` with 10 images → shows 8
  - [ ] `limitToEightImages: false` with 10 images → shows all 10
  - [ ] `limitToEightImages: true` with 5 images → shows 5

- [ ] **Translation key mapping:**
  - [ ] `'food'` → `'gallery_food'`
  - [ ] `'menu'` → `'gallery_menu'`
  - [ ] `'interior'` → `'gallery_interior'`
  - [ ] `'outdoor'` → `'gallery_outdoor'`
  - [ ] Unknown key → returns key unchanged

### Widget Tests

- [ ] **Tab bar rendering:**
  - [ ] Correct number of tabs matches non-empty categories
  - [ ] Tab labels use translated strings
  - [ ] Selected tab has orange color (#E9874B)
  - [ ] Unselected tabs have dark color (#14181B)
  - [ ] Tab indicator appears only under selected tab
  - [ ] Tab indicator width scales with label length

- [ ] **Grid layout:**
  - [ ] Shows 4 columns × 2 rows
  - [ ] Image spacing is 4px
  - [ ] Images have 4px border radius
  - [ ] Grid height calculated correctly for aspect ratio

- [ ] **Empty state:**
  - [ ] Shows "No images available" message (translated)
  - [ ] Message centered in grid area

- [ ] **Tab interaction:**
  - [ ] Tapping tab updates indicator
  - [ ] Tapping tab animates to page (300ms)
  - [ ] Same-tab tap doesn't trigger analytics

- [ ] **Swipe interaction:**
  - [ ] Swiping changes page
  - [ ] Tab indicator follows swipe
  - [ ] Swipe triggers analytics with `'swipe'` method

- [ ] **Image interaction:**
  - [ ] Tapping image calls `onImageTap` callback
  - [ ] Callback receives correct image URLs list
  - [ ] Callback receives correct index
  - [ ] Callback receives correct category key

- [ ] **Translation updates:**
  - [ ] Changing `languageCode` updates tab labels
  - [ ] Changing `translationsCache` updates tab labels
  - [ ] Widget doesn't rebuild when other props change

### Integration Tests

- [ ] **Business Profile page usage:**
  - [ ] Gallery renders below opening hours section
  - [ ] Shows maximum 8 images per category
  - [ ] Tapping image opens full-screen viewer
  - [ ] Closing viewer navigates to View All Gallery page
  - [ ] Correct gallery data passed from FFAppState

- [ ] **View All Gallery page usage:**
  - [ ] Gallery fills screen (minus app bar)
  - [ ] Shows all images (no 8-image limit)
  - [ ] Tapping image opens modal dialog
  - [ ] Closing dialog stays on same page
  - [ ] `initialCategory` parameter sets starting tab

- [ ] **Image preloading:**
  - [ ] First 8 images of each category are preloaded
  - [ ] Preloading doesn't block UI render
  - [ ] Switching tabs shows preloaded images instantly

- [ ] **Analytics tracking:**
  - [ ] `gallery_tab_opened` fires on first user interaction
  - [ ] `gallery_tab_opened` includes all available tabs
  - [ ] `gallery_tab_changed` fires on tab/swipe navigation
  - [ ] `gallery_tab_changed` includes navigation method
  - [ ] No analytics events fire on page load (only on interaction)

### Visual Regression Tests

- [ ] **Tab bar appearance:**
  - [ ] Screenshot: All 4 tabs visible, Food selected
  - [ ] Screenshot: Interior tab selected
  - [ ] Screenshot: 2 tabs only (some categories empty)
  - [ ] Screenshot: Empty state (no images)

- [ ] **Grid layout:**
  - [ ] Screenshot: Full grid (8 images)
  - [ ] Screenshot: Partial grid (5 images)
  - [ ] Screenshot: Loading states (progress indicators)
  - [ ] Screenshot: Error states (broken image icons)

- [ ] **Responsive behavior:**
  - [ ] Screenshot: iPhone SE (small width)
  - [ ] Screenshot: iPhone 14 Pro Max (large width)
  - [ ] Screenshot: iPad (tablet width)

### Localization Tests

Test with all 15 supported languages to verify tab label translations:

- [ ] English (en)
- [ ] Danish (da)
- [ ] German (de)
- [ ] French (fr)
- [ ] Spanish (es)
- [ ] Italian (it)
- [ ] Dutch (nl)
- [ ] Swedish (sv)
- [ ] Norwegian (no)
- [ ] Finnish (fi)
- [ ] Polish (pl)
- [ ] Portuguese (pt)
- [ ] Russian (ru)
- [ ] Turkish (tr)
- [ ] Arabic (ar)

**Verify for each language:**
- [ ] Tab labels display correctly (no missing translations)
- [ ] Tab indicator width scales appropriately
- [ ] Empty state message displays correctly

---

## Migration Notes (Phase 3)

### Current FlutterFlow Patterns to Migrate

**1. FFAppState → Riverpod:**
```dart
// Current (FlutterFlow):
galleryData: getJsonField(
  FFAppState().mostRecentlyViewedBusiness,
  r'$.gallery',
)

// Migrate to (Riverpod):
galleryData: ref.watch(mostRecentlyViewedBusinessProvider.select(
  (business) => business?.gallery,
))
```

**2. FFLocalizations → flutter_localizations:**
```dart
// Current (FlutterFlow):
languageCode: FFLocalizations.of(context).languageCode

// Migrate to (Standard):
languageCode: Localizations.localeOf(context).languageCode
```

**3. Translation system:**

Keep the `getTranslations()` function approach (centralized translation lookup). This is a good pattern that doesn't need to change.

**4. Analytics tracking:**

Replace `trackAnalyticsEvent()` custom action with proper analytics service:
```dart
// Current (FlutterFlow):
trackAnalyticsEvent('gallery_tab_opened', {...});

// Migrate to (Firebase Analytics):
await FirebaseAnalytics.instance.logEvent(
  name: 'gallery_tab_opened',
  parameters: {...},
);
```

### Widget API Changes

**No breaking changes needed.** The widget API is well-designed and can remain the same during migration:

```dart
// This signature works for both FlutterFlow and pure Flutter:
GalleryTabWidget({
  required this.galleryData,
  required this.languageCode,
  required this.translationsCache,
  this.onImageTap,
  this.limitToEightImages = false,
})
```

### State Management Strategy

**Current approach (local state) is appropriate for this widget.** No need to lift state to Riverpod because:

- Tab selection is ephemeral (doesn't need to persist)
- No other widgets need to access tab state
- Widget is self-contained

**Keep local state management with TabController + PageController.**

### File Organization

**Current location:** `lib/custom_code/widgets/gallery_tab_widget.dart`

**Migrate to:** `lib/widgets/gallery_tab_widget.dart`

**Also create:** `lib/widgets/gallery_category.dart` (extract model to separate file)

```dart
// lib/widgets/gallery_category.dart
class GalleryCategory {
  const GalleryCategory({
    required this.key,
    required this.label,
    required this.images,
  });

  final String key;
  final String label;
  final List<String> images;
}
```

### Dependencies to Update

**Remove FlutterFlow artifacts:**
```dart
// REMOVE these imports:
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
```

**Add proper imports:**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../utils/translations.dart'; // getTranslations function
import '../services/analytics_service.dart'; // Centralized analytics
import '../widgets/gallery_category.dart';
```

### Analytics Service Pattern

**Create centralized analytics service:**

```dart
// lib/services/analytics_service.dart
class AnalyticsService {
  static Future<void> trackGalleryOpened({
    required List<String> availableTabs,
    required List<String> availableTabNames,
    required int tabCount,
    required String? initialTab,
    required String? initialTabName,
    required String language,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'gallery_tab_opened',
        parameters: {
          'available_tabs': availableTabs.join(','),
          'available_tab_names': availableTabNames.join(','),
          'tab_count': tabCount,
          'initial_tab': initialTab,
          'initial_tab_name': initialTabName,
          'language': language,
        },
      );
    } catch (error) {
      debugPrint('⚠️ Failed to track gallery opened: $error');
    }
  }

  static Future<void> trackGalleryTabChanged({
    required String fromTab,
    required String toTab,
    required String fromTabName,
    required String toTabName,
    required int fromIndex,
    required int toIndex,
    required String navigationMethod,
    required List<String> availableTabs,
    required int tabCount,
    required String language,
  }) async {
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: 'gallery_tab_changed',
        parameters: {
          'from_tab': fromTab,
          'to_tab': toTab,
          'from_tab_name': fromTabName,
          'to_tab_name': toTabName,
          'from_index': fromIndex,
          'to_index': toIndex,
          'navigation_method': navigationMethod,
          'available_tabs': availableTabs.join(','),
          'tab_count': tabCount,
          'language': language,
        },
      );
    } catch (error) {
      debugPrint('⚠️ Failed to track tab change: $error');
    }
  }
}
```

**Usage in widget:**
```dart
void _trackGalleryOpened() {
  AnalyticsService.trackGalleryOpened(
    availableTabs: _categories.map((c) => c.key).toList(),
    availableTabNames: _categories.map((c) => c.label).toList(),
    tabCount: _categories.length,
    initialTab: _categories.isNotEmpty ? _categories[0].key : null,
    initialTabName: _categories.isNotEmpty ? _categories[0].label : null,
    language: widget.languageCode,
  );
}
```

### Visual Design Validation

**No changes needed.** The widget correctly implements the design system:

✅ Orange accent color (`#E9874B`) for selected tabs
✅ Dark text color (`#14181B`) for unselected tabs
✅ White background (`#FFFFFF`)
✅ Light gray border (`#E0E0E0`)
✅ 4px spacing and border radius (matches design system)
✅ Roboto font family
✅ Font weights: 300 (unselected), 400 (selected)

### Known Issues & Limitations

**1. Tab indicator width calculation:**

Uses character count (`label.length * 10.0`) which assumes monospaced font width. This works reasonably well for Roboto but could be improved:

```dart
// Better approach (calculate actual text width):
final textPainter = TextPainter(
  text: TextSpan(text: label, style: textStyle),
  textDirection: TextDirection.ltr,
)..layout();
final indicatorWidth = textPainter.width;
```

**2. Fixed grid layout (4×2):**

Grid is hardcoded to 4 columns × 2 rows. Consider making this responsive:

```dart
// Responsive grid based on screen width:
int _calculateColumnCount() {
  final width = MediaQuery.of(context).size.width;
  if (width < 375) return 3; // Small phones
  if (width < 768) return 4; // Normal phones
  return 6; // Tablets
}
```

**3. Image preloading limit (8 images):**

Hardcoded limit could be dynamic based on device memory:

```dart
// Adaptive preloading:
final deviceMemory = await DeviceInfo.getTotalMemory();
final maxPreload = deviceMemory > 4 ? 12 : 8;
```

**4. No hero animations:**

Tapping images could use Hero widget for smooth transitions to full-screen viewer.

**5. No image caching strategy:**

Uses Flutter's default image caching. Consider implementing:
- Cache headers handling
- Explicit cache size limits
- Offline image support

### Testing Strategy for Migration

**Step 1: Create feature branch**
```bash
git checkout -b feature/migrate-gallery-tab-widget
```

**Step 2: Extract to new file location**
- Move widget to `lib/widgets/gallery_tab_widget.dart`
- Extract model to `lib/widgets/gallery_category.dart`

**Step 3: Update imports**
- Replace FlutterFlow imports with standard Flutter
- Update custom action imports to use services

**Step 4: Update parent pages**
- Business Profile page
- View All Gallery page

**Step 5: Run widget tests**
```bash
flutter test test/widgets/gallery_tab_widget_test.dart
```

**Step 6: Run integration tests**
```bash
flutter test integration_test/gallery_flow_test.dart
```

**Step 7: Visual regression testing**
- Use `golden` files to ensure no visual changes
- Test all supported languages

**Step 8: Verify analytics**
- Use Firebase Analytics DebugView
- Verify event structure matches expectations

---

## Additional Context

### Design System Compliance

From `_reference/journeymate-design-system.md`:

**Colors used correctly:**
- ✅ Orange (`#E8751A` / `#E9874B`) for interactive tabs (selected state)
- ✅ No green used (green is reserved for match status only)
- ✅ Near-black (`#14181B`) for text (not pure black)
- ✅ White background for content areas

**Typography:**
- ✅ Roboto font family (system default)
- ✅ Font weight 300-400 range (within 420-460 → FontWeight.w400 guideline)
- ✅ 18px tab labels (readable, not too small)

**Spacing:**
- ✅ 12px margins (consistent with design system's 8/12/16 scale)
- ✅ 4px grid spacing (fine-grained detail spacing)

### Performance Considerations

**Image preloading tradeoff:**
- **Pros:** Smooth tab switching, no loading flicker
- **Cons:** Memory usage, network bandwidth
- **Mitigation:** Limit to 8 images per category (64 images max across 4 categories)

**Grid layout calculation:**
- Runs on every build (could be expensive on low-end devices)
- Consider caching calculated height in local variable

**PageView + GridView:**
- Two scrollable widgets nested (PageView horizontal, GridView disabled scroll)
- GridView uses `NeverScrollableScrollPhysics()` to prevent scroll conflict
- This is correct pattern for tab-based gallery

### Accessibility Notes

**Potential improvements for Phase 3:**

1. **Semantic labels for tabs:**
```dart
Semantics(
  label: 'Food gallery tab',
  selected: isSelected,
  child: _buildTabItem(label, index),
)
```

2. **Image descriptions:**
```dart
Semantics(
  label: 'Restaurant food image ${index + 1} of ${images.length}',
  child: _buildImageTile(images, index),
)
```

3. **Swipe hints:**
```dart
Semantics(
  hint: 'Swipe left or right to view other categories',
  child: PageView.builder(...),
)
```

4. **Empty state accessibility:**
```dart
Semantics(
  label: 'No images available in this category',
  child: _buildEmptyState(),
)
```

---

## Related Documentation

**Pages that use this widget:**
- `MASTER_README_business_profile.md` — Business Profile page
- `MASTER_README_view_all_gallery.md` — View All Gallery page (when created)

**Related widgets:**
- `ExpandedImageView` — Full-screen image viewer (FlutterFlow component)
- `FullScreenGalleryWidget` — Custom full-screen gallery (if exists)

**Related custom actions:**
- `markUserEngaged()` — User engagement tracking
- `trackAnalyticsEvent()` — Analytics event logging
- `getTranslations()` — Translation lookup function

**Related services:**
- Translation system (`getTranslations` function)
- Analytics service (to be created in Phase 3)
- Image caching service (to be created in Phase 3)

---

**Document version:** 1.0
**Last updated:** 2026-02-19
**FlutterFlow export date:** [Check file modification date]
**Migration status:** ❌ Not migrated (Phase 3 pending)
