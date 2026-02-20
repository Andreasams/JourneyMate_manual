# Business Profile Page — Implementation Bundle

**Page:** `BusinessProfile`
**Route:** `/BusinessProfile/:businessId/:businessName`
**Status:** ⏳ Ready for Implementation

This document lists ALL dependencies required to implement the Business Profile page. Every import, widget, action, function, and API call from the FlutterFlow source is documented here.

---

## Table of Contents

1. [Core Files](#core-files)
2. [Package Dependencies](#package-dependencies)
3. [FlutterFlow Framework Imports](#flutterflow-framework-imports)
4. [Custom Widgets](#custom-widgets)
5. [Custom Actions](#custom-actions)
6. [Custom Functions](#custom-functions)
7. [API Calls](#api-calls)
8. [Profile Component Widgets](#profile-component-widgets)
9. [FFAppState Properties](#ffappstate-properties)
10. [Implementation Checklist](#implementation-checklist)

---

## Core Files

### Source Files
**FlutterFlow Export Location:** `_flutterflow_export/lib/profile/business_information/business_profile/`

| File | Purpose | Lines |
|------|---------|-------|
| `business_profile_widget.dart` | Main page widget | 1750+ |
| `business_profile_model.dart` | Page state model | 200+ |

### Design Files
**Design Location:** `JourneyMate-Organized/pages/02_business_profile/`

| File | Purpose |
|------|---------|
| `PAGE_README.md` | Functional specification |
| `DESIGN_README_business_profile.md` | Visual design documentation |
| `BUNDLE.md` | This file — dependency manifest |

---

## Package Dependencies

### pub.dev Packages Required

```yaml
# pubspec.yaml additions

dependencies:
  # State management
  flutter_riverpod: ^2.x  # ⚠️ Corrected: was `provider: ^6.1.5`

  # UI components
  expandable: ^5.0.1              # Collapsible sections (hours, about)

  # Sharing functionality
  share_plus: ^10.2.0             # Share button

  # Google Fonts
  google_fonts: ^6.2.1            # Typography

  # Already in project (from other pages):
  # - flutter/material.dart
  # - flutter/scheduler.dart (SchedulerBinding)
  # - dart:async (unawaited, Future.wait)
  # - dart:ui (ImageFilter for backdrop blur)
```

**Package Purpose:**
- **provider** — Watch FFAppState changes (context.watch<FFAppState>())
- **expandable** — Hours section collapse/expand (ExpandableController)
- **share_plus** — Share business via system share sheet
- **google_fonts** — Custom typography (if not using default fonts)

---

## FlutterFlow Framework Imports

### Required FlutterFlow Imports

```dart
import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
```

**Purpose of Each:**
- **api_calls.dart** — BuildShip API clients (MenuItemsCall, BusinessProfileCall, FilterDescriptionsCall)
- **flutter_flow_icon_button.dart** — Back button, info button, share button
- **flutter_flow_theme.dart** — ThemeData (colors, text styles)
- **flutter_flow_util.dart** — LatLng, getCurrentUserLocation, getCurrentTimestamp, safeSetState
- **flutter_flow_widgets.dart** — FFButton (if needed for CTAs)
- **custom_functions.dart** — Shared utility functions
- **index.dart** — FlutterFlow routing/navigation

---

## Custom Widgets

### Custom Widgets Used (from `/custom_code/widgets/`)

All custom widgets are accessed via `custom_widgets.WidgetName`.

| Widget | Usage Line | Purpose | README Status | Priority |
|--------|------------|---------|---------------|----------|
| `UnifiedFiltersWidget` | 1117 | Menu dietary filter panel | ⏳ Pending | ⭐⭐⭐⭐⭐ |
| `MenuCategoriesRows` | 1167 | Menu category horizontal chips | ⏳ Pending | ⭐⭐⭐⭐⭐ |
| `MenuDishesListView` | 1221 | Menu items scrollable list | ⏳ Pending | ⭐⭐⭐⭐⭐ |
| `GalleryTabWidget` | 675 | Gallery photo grid with tabs | ⏳ Pending | ⭐⭐⭐⭐ |
| `BusinessFeatureButtons` | 1453 | Feature section toggle buttons (Menu/Gallery/Info) | ⏳ Pending | ⭐⭐⭐⭐⭐ |
| `PaymentOptionsWidget` | 1555 | Payment methods display | ⏳ Pending | ⭐⭐⭐ |
| `ExpandableTextWidget` | 1622 | Expandable description text | ⏳ Pending | ⭐⭐⭐ |
| `RestaurantShimmerWidget` | 1733 | Loading skeleton (profile) | ⏳ Pending | ⭐⭐⭐ |

### Widget Parameters (from FlutterFlow source)

#### UnifiedFiltersWidget (line 1117)
```dart
custom_widgets.UnifiedFiltersWidget(
  width: double.infinity,
  height: valueOrDefault<double>(
    FFAppState().isBoldTextEnabled ? 385.0 : 350.0,
    340.0,
  ),
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  onFiltersUpdated: () async {
    // Refresh menu items when filters change
  },
)
```

#### MenuCategoriesRows (line 1167)
```dart
custom_widgets.MenuCategoriesRows(
  width: double.infinity,
  height: 40.0,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
)
```

#### MenuDishesListView (line 1221)
```dart
custom_widgets.MenuDishesListView(
  width: double.infinity,
  height: double.infinity,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  fontScale: FFAppState().fontScale,
  onItemTap: (itemId, itemType) async {
    // Open item/package bottom sheet
  },
)
```

#### GalleryTabWidget (line 675)
```dart
custom_widgets.GalleryTabWidget(
  width: double.infinity,
  height: double.infinity,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  businessData: FFAppState().mostRecentlyViewedBusiness,
  onPhotoTap: (photoIndex, photoCategory) async {
    await showModalBottomSheet(
      // Open ImageGalleryOverlaySwipable
    );
  },
)
```

#### BusinessFeatureButtons (line 1453)
```dart
custom_widgets.BusinessFeatureButtons(
  width: double.infinity,
  height: 100.0,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  onFeatureTap: (featureName) async {
    // Switch tab (menu/gallery/info)
  },
)
```

#### PaymentOptionsWidget (line 1555)
```dart
custom_widgets.PaymentOptionsWidget(
  width: double.infinity,
  height: 60.0,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  businessData: FFAppState().mostRecentlyViewedBusiness,
)
```

#### ExpandableTextWidget (line 1622)
```dart
custom_widgets.ExpandableTextWidget(
  width: double.infinity,
  height: 100.0,
  text: getJsonField(
    FFAppState().mostRecentlyViewedBusiness,
    r'''$.description''',
  ).toString(),
  maxLines: 3,
  expandText: functions.getTranslations(
    FFAppState().translationsCache,
    'read_more',
    FFLocalizations.of(context).languageCode,
  ),
  collapseText: functions.getTranslations(
    FFAppState().translationsCache,
    'read_less',
    FFLocalizations.of(context).languageCode,
  ),
)
```

#### RestaurantShimmerWidget (line 1733)
```dart
custom_widgets.RestaurantShimmerWidget(
  width: double.infinity,
  height: double.infinity,
)
```

---

## Custom Actions

### Custom Actions Used (from `/custom_code/actions/`)

All custom actions are accessed via `actions.actionName()`.

| Action | Usage Lines | Purpose | When Called | README Status |
|--------|-------------|---------|-------------|---------------|
| `startMenuSession` | 102 | Initialize menu browsing session | Page load (post-frame) | ⏳ Pending |
| `endMenuSession` | 133 | End menu browsing session | Page dispose | ⏳ Pending |
| `trackAnalyticsEvent` | 138, 301 | Track analytics events | Page dispose, interactions | ✅ Done |
| `markUserEngaged` | 202, 228, 259, 294, 341, 454, 749, 1356 | Mark user engagement | User interactions | ⏳ Pending |

### Action Parameters (from FlutterFlow source)

#### startMenuSession (line 102)
```dart
await actions.startMenuSession(
  widget.businessId!,  // int
);
```

**Called:** Page load (inside SchedulerBinding.instance.addPostFrameCallback)
**Purpose:** Track menu session start time for analytics

---

#### endMenuSession (line 133)
```dart
await actions.endMenuSession(
  widget.businessId!,  // int
);
```

**Called:** Page dispose
**Purpose:** Calculate and track menu session duration

---

#### trackAnalyticsEvent (line 138)
```dart
await actions.trackAnalyticsEvent(
  'business_profile_viewed',  // String eventName
  <String, String>{           // Map<String, String> eventData
    'pageName': 'businessProfile',
    'durationSeconds': functions
        .getSessionDurationSeconds(_model.pageStartTime!)
        .toString(),
    'businessId': widget.businessId!.toString(),
  },
);
```

**Called:** Page dispose
**Purpose:** Track page view with duration

---

#### markUserEngaged (multiple lines)
```dart
await actions.markUserEngaged();
```

**Called:**
- Line 202: Back button press
- Line 228: Share button press
- Line 259: Info button press
- Line 294: "View on Map" button press
- Line 341: Contact detail tap
- Line 454: Gallery photo tap
- Line 749: Menu item tap
- Line 1356: Filter description tap

**Purpose:** Track user engagement for analytics

---

## Custom Functions

### Custom Functions Used (from `/flutter_flow/custom_functions.dart`)

All custom functions are accessed via `functions.functionName()`.

| Function | Usage Lines | Purpose | Return Type | README Status |
|----------|-------------|---------|-------------|---------------|
| `getSessionDurationSeconds` | 143 | Calculate page duration | int | ✅ Done |
| `generateFilterSummary` | 960 | Generate filter summary text | String | ⏳ Pending |
| `getTranslations` | 1694 | Get localized text | String | ✅ Done |

### Function Parameters (from FlutterFlow source)

#### getSessionDurationSeconds (line 143)
```dart
functions.getSessionDurationSeconds(
  _model.pageStartTime!,  // DateTime
)
```

**Returns:** `int` (seconds)
**Purpose:** Calculate seconds since page load for analytics

---

#### generateFilterSummary (line 960)
```dart
functions.generateFilterSummary(
  FFAppState().selectedFilters,                    // List<int>
  FFLocalizations.of(context).languageCode,        // String
  FFAppState().translationsCache,                  // dynamic (JSON)
)
```

**Returns:** `String` (e.g., "Vegan, Gluten-free, Outdoor seating")
**Purpose:** Generate human-readable filter summary for display

---

#### getTranslations (line 1694)
```dart
functions.getTranslations(
  FFAppState().translationsCache,                  // dynamic (JSON)
  'read_more',                                     // String key
  FFLocalizations.of(context).languageCode,        // String
)
```

**Returns:** `String` (translated text)
**Purpose:** Get translated text for dynamic content

---

## API Calls

### API Calls Made (from `/backend/api_requests/api_calls.dart`)

| API Call | Usage Line | Method | Endpoint | When Called |
|----------|------------|--------|----------|-------------|
| `MenuItemsCall` | 64 | POST | BuildShip menu items API | Page load (parallel) |
| `BusinessProfileCall` | 88 | POST | BuildShip business profile API | Page load (parallel) |
| `FilterDescriptionsCall` | 107 | POST | BuildShip filter descriptions API | Page load |

### API Parameters & Response Handling

#### MenuItemsCall (line 64)
```dart
_model.apiResultMenuItems = await MenuItemsCall.call(
  businessId: widget.businessId,                      // int
  languageCode: FFLocalizations.of(context).languageCode,  // String
);

// Store results in FFAppState
FFAppState().mostRecentlyViewedBusinessAvailableDietaryPreferences =
    MenuItemsCall.availableDietaryPreferences(
      (_model.apiResultMenuItems?.jsonBody ?? ''),
    )!.toList().cast<int>();

FFAppState().mostRecentlyViewedBusinesMenuItems =
    (_model.apiResultMenuItems?.jsonBody ?? '');

FFAppState().mostRecentlyViewedBusinessAvailableDietaryRestrictions =
    MenuItemsCall.availableRestrictions(
      (_model.apiResultMenuItems?.jsonBody ?? ''),
    )!.toList().cast<int>();
```

**Request Parameters:**
```json
{
  "businessId": 123,
  "languageCode": "da"
}
```

**Response Structure:**
```json
{
  "menu_items": [...],
  "available_dietary_preferences": [1, 2, 3],
  "available_restrictions": [4, 5, 6]
}
```

---

#### BusinessProfileCall (line 88)
```dart
_model.businessProfileAPI = await BusinessProfileCall.call(
  businessId: widget.businessId,                      // int
  languageCode: FFLocalizations.of(context).languageCode,  // String
);

// Store results in FFAppState
FFAppState().mostRecentlyViewedBusiness =
    (_model.businessProfileAPI?.jsonBody ?? '');
```

**Request Parameters:**
```json
{
  "businessId": 123,
  "languageCode": "da"
}
```

**Response Structure:**
```json
{
  "business_id": 123,
  "business_name": "Restaurant Name",
  "description": "...",
  "profile_picture_url": "https://...",
  "business_hours": {...},
  "contact": {...},
  "payment_options": [...],
  "filters": [...]
}
```

---

#### FilterDescriptionsCall (line 107)
```dart
_model.filterDescriptions = await FilterDescriptionsCall.call(
  languageCode: FFLocalizations.of(context).languageCode,  // String
  businessId: widget.businessId,                           // int
);
```

**Request Parameters:**
```json
{
  "languageCode": "da",
  "businessId": 123
}
```

**Response Structure:**
```json
{
  "filter_descriptions": [
    {
      "filter_id": 1,
      "title": "Vegan",
      "description": "All dishes are plant-based..."
    }
  ]
}
```

**Purpose:** Get filter explanations for "Why this match?" section

---

## Profile Component Widgets

### Profile Subdirectory Widgets (from `/profile/` directory)

These are FlutterFlow-generated component widgets (NOT custom_widgets).

| Widget | Import Path | Usage Line | Purpose |
|--------|------------|------------|---------|
| `ProfileTopBusinessBlockWidget` | `/profile/business_information/profile_top_business_block/` | 398 | Top business card (hero section) |
| `ContactDetailWidget` | `/profile/contact_details/contact_detail/` | 520 | Contact detail modal |
| `ImageGalleryOverlaySwipableWidget` | `/profile/gallery/image_gallery_overlay_swipable/` | 722 | Full-screen gallery overlay |
| `ItemBottomSheetWidget` | `/profile/menu/item_bottom_sheet/` | 1252 | Menu item detail sheet |
| `PackageBottomSheetWidget` | `/profile/menu/package_bottom_sheet/` | 1291 | Menu package detail sheet |
| `CategoryDescriptionSheetWidget` | `/profile/menu/category_description_sheet/` | 1334 | Category description modal |
| `FilterDescriptionSheetWidget` | `/profile/business_information/filter_description_sheet/` | 1496 | Filter explanation sheet |
| `ModalSubmitErroneousInfoWidget` | `/profile/business_information/modal_submit_erroneous_info/` | 1674 | Report error form modal |

### Component Parameters (from FlutterFlow source)

#### ProfileTopBusinessBlockWidget (line 398)
```dart
ProfileTopBusinessBlockWidget(
  businessData: FFAppState().mostRecentlyViewedBusiness,
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  userLocation: currentUserLocationValue,
)
```

**Purpose:** Hero section with business name, status, address, "Why this match?" section

---

#### ContactDetailWidget (line 520)
```dart
await showModalBottomSheet(
  isScrollControlled: true,
  builder: (context) {
    return ContactDetailWidget(
      businessData: FFAppState().mostRecentlyViewedBusiness,
      languageCode: FFLocalizations.of(context).languageCode,
      translationsCache: FFAppState().translationsCache,
    );
  },
);
```

**Purpose:** Contact info modal with copy-to-clipboard functionality

---

#### ImageGalleryOverlaySwipableWidget (line 722)
```dart
await showModalBottomSheet(
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) {
    return ImageGalleryOverlaySwipableWidget(
      businessData: FFAppState().mostRecentlyViewedBusiness,
      initialIndex: photoIndex,
      initialCategory: photoCategory,
    );
  },
);
```

**Purpose:** Full-screen swipeable gallery

---

#### ItemBottomSheetWidget (line 1252)
```dart
await showModalBottomSheet(
  isScrollControlled: true,
  builder: (context) {
    return ItemBottomSheetWidget(
      menuItem: selectedMenuItem,
      languageCode: FFLocalizations.of(context).languageCode,
      translationsCache: FFAppState().translationsCache,
      exchangeRate: FFAppState().exchangeRate,
      userCurrencyCode: FFAppState().userCurrencyCode,
    );
  },
);
```

**Purpose:** Menu dish detail with allergens, dietary info, price

---

#### PackageBottomSheetWidget (line 1291)
```dart
await showModalBottomSheet(
  isScrollControlled: true,
  builder: (context) {
    return PackageBottomSheetWidget(
      packageData: selectedPackage,
      languageCode: FFLocalizations.of(context).languageCode,
      translationsCache: FFAppState().translationsCache,
      exchangeRate: FFAppState().exchangeRate,
      userCurrencyCode: FFAppState().userCurrencyCode,
    );
  },
);
```

**Purpose:** Menu package detail with courses, pricing

---

#### CategoryDescriptionSheetWidget (line 1334)
```dart
await showModalBottomSheet(
  isScrollControlled: true,
  builder: (context) {
    return CategoryDescriptionSheetWidget(
      categoryData: selectedCategory,
      languageCode: FFLocalizations.of(context).languageCode,
      translationsCache: FFAppState().translationsCache,
    );
  },
);
```

**Purpose:** Menu category explanation modal

---

#### FilterDescriptionSheetWidget (line 1496)
```dart
await showModalBottomSheet(
  isScrollControlled: true,
  builder: (context) {
    return FilterDescriptionSheetWidget(
      filterData: _model.filterDescriptions,
      filterId: selectedFilterId,
      languageCode: FFLocalizations.of(context).languageCode,
      translationsCache: FFAppState().translationsCache,
    );
  },
);
```

**Purpose:** "Why this match?" filter explanation

---

#### ModalSubmitErroneousInfoWidget (line 1674)
```dart
await showModalBottomSheet(
  isScrollControlled: true,
  builder: (context) {
    return ModalSubmitErroneousInfoWidget(
      businessId: widget.businessId!,
      businessName: widget.businessName!,
      languageCode: FFLocalizations.of(context).languageCode,
      translationsCache: FFAppState().translationsCache,
    );
  },
);
```

**Purpose:** Report missing/incorrect info form

---

## FFAppState Properties

### Read Properties
Properties read from `FFAppState()` in the Business Profile page.

```dart
// Business data (from API responses, stored by page)
FFAppState().mostRecentlyViewedBusiness                          // dynamic (JSON)
FFAppState().mostRecentlyViewedBusinesMenuItems                 // dynamic (JSON)
FFAppState().mostRecentlyViewedBusinessAvailableDietaryPreferences  // List<int>
FFAppState().mostRecentlyViewedBusinessAvailableDietaryRestrictions // List<int>

// From Search page (passed via navigation)
FFAppState().openingHours                                        // dynamic (JSON)
FFAppState().filtersOfSelectedBusiness                          // List<int>
FFAppState().filtersForUserLanguage                             // dynamic (JSON)
FFAppState().filtersUsedForSearch                               // List<int>

// User settings
FFAppState().fontScale                                          // double
FFAppState().isBoldTextEnabled                                  // bool
FFAppState().locationStatus                                     // String

// Currency & exchange
FFAppState().exchangeRate                                       // double
FFAppState().userCurrencyCode                                  // String ('DKK', 'EUR', etc.)

// Translation system
FFAppState().translationsCache                                  // dynamic (JSON)

// Menu filtering (menu session state)
FFAppState().selectedDietaryRestrictionId                       // List<int>
FFAppState().excludedAllergyIds                                 // List<int>
FFAppState().selectedDietaryPreferenceId                        // int
FFAppState().visibleItemCount                                   // int

// Favorites (like/unlike button)
FFAppState().restaurantIsFavorited                              // bool

// Analytics tracking
FFAppState().currentFilterSessionId                            // String
FFAppState().sessionStartTime                                  // DateTime
```

### Write Properties
Properties written to `FFAppState()` by the Business Profile page.

```dart
// API responses stored
FFAppState().mostRecentlyViewedBusiness = apiResult.jsonBody;
FFAppState().mostRecentlyViewedBusinesMenuItems = apiResult.jsonBody;
FFAppState().mostRecentlyViewedBusinessAvailableDietaryPreferences = [...];
FFAppState().mostRecentlyViewedBusinessAvailableDietaryRestrictions = [...];

// Menu filtering state cleared on back button (lines 205-208)
FFAppState().selectedDietaryRestrictionId = [];
FFAppState().excludedAllergyIds = [];
FFAppState().selectedDietaryPreferenceId = 0;
FFAppState().visibleItemCount = 0;

// Favorites state toggled by like/unlike button (lines 229, 260)
FFAppState().restaurantIsFavorited = true;  // or false
```

---

## Implementation Checklist

### Phase 3 Migration Checklist

When implementing Business Profile page in Flutter:

#### 1. Package Setup
- [ ] Add `expandable: ^5.0.1` to pubspec.yaml
- [ ] Add `share_plus: ^10.2.0` to pubspec.yaml
- [ ] Add `flutter_riverpod: ^2.x` to pubspec.yaml (⚠️ corrected: was `provider: ^6.1.5`)
- [ ] Verify `google_fonts: ^6.2.1` is installed

#### 2. Custom Widgets (Priority Order)
- [ ] Implement `UnifiedFiltersWidget` (menu dietary filters)
- [ ] Implement `MenuCategoriesRows` (category chips)
- [ ] Implement `MenuDishesListView` (menu items list)
- [ ] Implement `BusinessFeatureButtons` (Menu/Gallery/Info tabs)
- [ ] Implement `GalleryTabWidget` (photo gallery)
- [ ] Implement `PaymentOptionsWidget` (payment methods)
- [ ] Implement `ExpandableTextWidget` (description collapse/expand)
- [ ] Implement `RestaurantShimmerWidget` (loading skeleton)

#### 3. Profile Component Widgets
- [ ] Port `ProfileTopBusinessBlockWidget` (hero section)
- [ ] Port `ContactDetailWidget` (contact modal)
- [ ] Port `ImageGalleryOverlaySwipableWidget` (full-screen gallery)
- [ ] Port `ItemBottomSheetWidget` (menu item detail)
- [ ] Port `PackageBottomSheetWidget` (menu package detail)
- [ ] Port `CategoryDescriptionSheetWidget` (category explanation)
- [ ] Port `FilterDescriptionSheetWidget` (filter explanation)
- [ ] Port `ModalSubmitErroneousInfoWidget` (report error form)

#### 4. Custom Actions
- [ ] Port `startMenuSession` action
- [ ] Port `endMenuSession` action
- [ ] Verify `trackAnalyticsEvent` action works
- [ ] Port `markUserEngaged` action

#### 5. Custom Functions
- [ ] Verify `getSessionDurationSeconds` function
- [ ] Port `generateFilterSummary` function
- [ ] Verify `getTranslations` function

#### 6. API Integration
- [ ] Test `MenuItemsCall` API
- [ ] Test `BusinessProfileCall` API
- [ ] Test `FilterDescriptionsCall` API
- [ ] Verify parallel API calls work (Future.wait)

#### 7. State Management
- [ ] Set up FFAppState properties (or Riverpod providers)
- [ ] Implement business data caching
- [ ] Implement menu data caching
- [ ] Handle API response storage

#### 8. Lifecycle Events
- [ ] Implement initState with SchedulerBinding post-frame callback
- [ ] Implement parallel API calls on page load
- [ ] Implement menu session start on page load
- [ ] Implement dispose with menu session end
- [ ] Implement analytics tracking on dispose

#### 9. User Interactions
- [ ] Implement back button with markUserEngaged
- [ ] Implement share button with share_plus
- [ ] Implement info button navigation
- [ ] Implement tab switching (Menu/Gallery/Info)
- [ ] Implement menu item tap → ItemBottomSheet
- [ ] Implement package tap → PackageBottomSheet
- [ ] Implement category tap → CategoryDescriptionSheet
- [ ] Implement filter badge tap → FilterDescriptionSheet
- [ ] Implement gallery photo tap → ImageGalleryOverlay
- [ ] Implement contact tap → ContactDetailWidget
- [ ] Implement report tap → ModalSubmitErroneousInfo

#### 10. Navigation
- [ ] Set up route: `/BusinessProfile/:businessId/:businessName`
- [ ] Pass businessId and businessName parameters
- [ ] Handle back navigation to Search page
- [ ] Store business data before navigation (from Search page)

#### 11. Translation System
- [ ] Pass languageCode to all widgets
- [ ] Pass translationsCache to all widgets
- [ ] Use getTranslations for dynamic content
- [ ] Implement FFLocalizations.of(context).languageCode

#### 12. Analytics Events
- [ ] Track `business_profile_viewed` on dispose
- [ ] Track `menu_session_ended` on dispose
- [ ] Track `tab_viewed` on tab switch
- [ ] Track `menu_item_viewed` on item tap
- [ ] Track `gallery_photo_viewed` on photo tap
- [ ] Track `contact_copied` on contact tap
- [ ] Track `business_shared` on share tap
- [ ] Track `report_form_opened` on report tap

#### 13. Display States
- [ ] Implement location loading state (CircularProgressIndicator)
- [ ] Implement shimmer loading state (RestaurantShimmerWidget)
- [ ] Implement loaded state with all data
- [ ] Implement error state for API failures

#### 14. Testing
- [ ] Test page load with parallel API calls
- [ ] Test tab switching between Menu/Gallery/Info
- [ ] Test menu filtering with UnifiedFiltersWidget
- [ ] Test menu category switching
- [ ] Test menu item tap → detail sheet
- [ ] Test gallery photo tap → full-screen overlay
- [ ] Test share button functionality
- [ ] Test contact modal
- [ ] Test report form modal
- [ ] Test analytics tracking
- [ ] Test with different languages
- [ ] Test with different currency settings
- [ ] Test with accessibility settings (font scale)

---

## Critical Implementation Notes

### 1. Parallel API Calls
The page makes **3 API calls in parallel** using `Future.wait()`:
- MenuItemsCall + BusinessProfileCall (inner parallel)
- FilterDescriptionsCall + startMenuSession (outer parallel)

**DO NOT** make these sequential — performance degrades significantly.

### 2. Menu Session Tracking
- `startMenuSession` must be called on page load (non-blocking with `unawaited`)
- `endMenuSession` must be called on dispose (non-blocking with `unawaited`)
- Analytics depend on session duration calculation

### 3. Translation System
- **Every custom widget** receives `languageCode` and `translationsCache`
- **Every profile component widget** receives `languageCode` and `translationsCache`
- Use `functions.getTranslations()` for dynamic content
- Use `FFLocalizations.of(context).languageCode` for language code

### 4. FFAppState Caching
Business data is cached in FFAppState for performance:
- `mostRecentlyViewedBusiness` persists across navigation
- `mostRecentlyViewedBusinesMenuItems` persists across navigation
- No re-fetch needed when returning to this page from child pages

### 5. Custom Widget Dependencies
Several custom widgets depend on each other:
- `MenuDishesListView` depends on `UnifiedFiltersWidget` filter state
- `MenuCategoriesRows` depends on `MenuDishesListView` category state
- `GalleryTabWidget` depends on business data structure

Implement in priority order shown in Custom Widgets section.

---

## Related Documentation

| Document | Location | Purpose |
|----------|----------|---------|
| **PAGE_README.md** | `02_business_profile/` | Functional specification |
| **DESIGN_README_business_profile.md** | `02_business_profile/` | Visual design documentation |
| **FlutterFlow Source** | `_flutterflow_export/lib/profile/business_information/business_profile/` | Original implementation |
| **Custom Widget READMEs** | `shared/widgets/MASTER_README_*.md` | Individual widget documentation |
| **Custom Action READMEs** | `shared/actions/MASTER_README_*.md` | Individual action documentation |
| **Custom Function READMEs** | `shared/functions/MASTER_README_*.md` | Individual function documentation |

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete — Ready for Implementation
**Total Dependencies:** 8 custom widgets + 4 actions + 3 functions + 3 API calls + 8 profile components + 3 packages

**Next Step:** Begin Phase 3 implementation following the Three-Source Method:
1. Read FlutterFlow source (business_profile_widget.dart)
2. Read PAGE_README.md specifications
3. Read DESIGN_README_business_profile.md
4. Implement following priority order in checklist above

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`
> **Note on pubspec:** This file previously listed `provider: ^6.1.5` — the correct package is `flutter_riverpod: ^2.x`.

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(businessProvider)` | `currentBusiness` | Business info, gallery, menu categories (mostRecentlyViewedBusiness) |
| `ref.watch(businessProvider)` | `menuItems` | Menu data (mostRecentlyViewedBusinesMenuItems) |
| `ref.watch(businessProvider)` | `businessFilterIds` | Business's filter IDs (filtersOfSelectedBusiness) |
| `ref.watch(businessProvider)` | `openingHours` | Opening hours passed to ContactDetailWidget |
| `ref.watch(businessProvider)` | `availableDietaryPreferences` | Filter options in UnifiedFiltersWidget |
| `ref.watch(businessProvider)` | `availableDietaryRestrictions` | Filter options in UnifiedFiltersWidget |
| `ref.watch(translationsCacheProvider)` | `translationsCache` | All translated text; passed to all custom widgets |
| `ref.watch(filterProvider)` | `filtersForLanguage` | Filter descriptions (filtersForUserLanguage) |
| `ref.watch(localizationProvider)` | `currencyCode` | Currency display in menu price formatting |
| `ref.watch(localizationProvider)` | `exchangeRate` | Price conversion for non-DKK currencies |
| `ref.watch(analyticsProvider)` | `menuSessionData` | Menu session analytics (read by endMenuSession) |
| `ref.watch(accessibilityProvider)` | `fontScaleLarge` | Font size adjustments throughout |
| `ref.watch(accessibilityProvider)` | `isBoldTextEnabled` | Bold text rendering throughout |

### Writes
| Provider | Notifier method | Trigger |
|----------|----------------|---------|
| `ref.read(businessProvider.notifier).setMenuItems(...)` | `setMenuItems` | GET_RESTAURANT_MENU API response |
| `ref.read(businessProvider.notifier).setAvailableDietary(...)` | `setAvailableDietary` | UnifiedFiltersWidget receives API response |
| `ref.read(analyticsProvider.notifier).setMenuSessionData(...)` | `setMenuSessionData` | startMenuSession called on page init |
| `ref.read(analyticsProvider.notifier).clearMenuSession()` | `clearMenuSession` | endMenuSession called on page dispose |
