# Business Profile Page

**Route:** `/BusinessProfile/:businessId/:businessName`
**Route Name:** `BusinessProfile`
**Status:** ✅ Production Ready

---

## Purpose

The detailed business profile page where users view comprehensive business information including menu, gallery, opening hours, contact details, payment options, and matching filters. Central hub for all business-related information before making a visit decision.

**Primary User Task:** Evaluate if this business matches their needs and get information for visiting.

---

## Page Structure

```
┌─────────────────────────────────────────────────┐
│ [Back] Business Name [Share]                    │
├─────────────────────────────────────────────────┤
│ [Profile Image - hero]                          │
│ Business Name                                   │
│ Open • til 22:00                                │
│ Restaurant • 100-200 kr • 1 km                  │
│ [Why this match: Vegan, Gluten-free, ...]      │ ← Match indicators
├─────────────────────────────────────────────────┤
│ [Menu] [Gallery] [Information]                  │ ← Tab buttons
├─────────────────────────────────────────────────┤
│ Menu Section (if tab selected)                  │
│   ┌─────────────────────────┐                  │
│   │ [Starters] [Mains] ...  │ ← Categories     │
│   ├─────────────────────────┤                  │
│   │ [Dietary filters icon]  │                  │
│   ├─────────────────────────┤                  │
│   │ Menu Item 1             │                  │
│   │ Menu Item 2             │                  │
│   └─────────────────────────┘                  │
│                                                 │
│ Gallery Section (if tab selected)               │
│   [Photo grid - 2 columns]                     │
│                                                 │
│ Information Section (if tab selected)           │
│   ▼ Opening hours & contact                    │ ← Expandable
│      [Hours] [Address] [Phone] [Email]         │
│   Payment options                               │
│   [Report missing info]                         │
├─────────────────────────────────────────────────┤
│ [Bottom Navigation]                             │
└─────────────────────────────────────────────────┘
```

---

## JSX Design Files

Located in: `pages/02_business_profile/design/`

| File | Purpose | Lines |
|------|---------|-------|
| `business_profile.jsx` | Main profile page layout | ~800 lines |
| `information_page.jsx` | Detailed info tab | ~400 lines |
| `contact_copy_popup.jsx` | Copy success toast | ~50 lines |
| `report_missing_info_modal.jsx` | Report form modal | ~200 lines |

---

## FlutterFlow Files

### Source Files
**FlutterFlow Export Location:** `_flutterflow_export/lib/profile/business_information/business_profile/`

| File | Purpose | Lines |
|------|---------|-------|
| `business_profile_widget.dart` | Main page widget | 1750+ lines |
| `business_profile_model.dart` | Page state model | 200+ lines |

### Profile Component Widgets (from `/profile/` directory)

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

---

## Custom Widgets Used

Located in: `pages/02_business_profile/custom_code/widgets/`

All custom widgets are accessed via `custom_widgets.WidgetName`.

| Widget | Usage Line | Purpose | Priority | README |
|--------|------------|---------|----------|--------|
| `UnifiedFiltersWidget` | 1117 | Menu dietary filter panel | ⭐⭐⭐⭐⭐ | ⏳ Pending |
| `MenuCategoriesRows` | 1167 | Menu category horizontal chips | ⭐⭐⭐⭐⭐ | ⏳ Pending |
| `MenuDishesListView` | 1221 | Menu items scrollable list | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| `GalleryTabWidget` | 675 | Gallery photo grid with tabs | ⭐⭐⭐⭐ | ⏳ Pending |
| `BusinessFeatureButtons` | 1453 | Feature section toggle buttons (Menu/Gallery/Info) | ⭐⭐⭐⭐⭐ | ⏳ Pending |
| `PaymentOptionsWidget` | 1555 | Payment methods display | ⭐⭐⭐ | ⏳ Pending |
| `ExpandableTextWidget` | 1622 | Expandable description text | ⭐⭐⭐ | ⏳ Pending |
| `RestaurantShimmerWidget` | 1733 | Loading skeleton (profile) | ⭐⭐⭐ | ⏳ Pending |

---

## Custom Actions Used

All custom actions are accessed via `actions.actionName()`.

| Action | Usage Lines | Purpose | Called When | README |
|--------|-------------|---------|-------------|--------|
| `startMenuSession` | 102 | Initialize menu browsing session | Page load (post-frame) | ⏳ Pending |
| `endMenuSession` | 133 | End menu browsing session | Page dispose | ⏳ Pending |
| `trackAnalyticsEvent` | 138, 301 | Track analytics events | Page dispose, interactions | ✅ Done |
| `markUserEngaged` | 202, 228, 259, 294, 341, 454, 749, 1356 | Mark user engagement | User interactions | ⏳ Pending |

---

## Custom Functions Used

All custom functions are accessed via `functions.functionName()`.

| Function | Usage Lines | Purpose | Return Type | README |
|----------|-------------|---------|-------------|--------|
| `getSessionDurationSeconds` | 143 (widget) | Calculate page duration | int | ✅ Done |
| `generateFilterSummary` | 960 | Generate filter summary text | String | ⏳ Pending |
| `getTranslations` | 1694 | Get localized text | String | ✅ Done |

**Note:** Functions like `openClosesAt`, `daysDayOpeningHour`, and `returnDistance` are used in child component `ProfileTopBusinessBlockWidget`, not directly in the main page widget.

---

## API Calls

### BusinessProfileCall
**Endpoint:** BuildShip business profile API
**Method:** POST
**Called:** Page load (parallel with menu items)

**Parameters:**
```dart
{
  'businessId': 123,
  'languageCode': 'da',
}
```

**Response Stored:**
```dart
FFAppState().mostRecentlyViewedBusiness = apiResult.jsonBody;
```

### MenuItemsCall
**Endpoint:** BuildShip menu items API
**Method:** POST
**Called:** Page load (parallel with business profile)

**Parameters:**
```dart
{
  'businessId': 123,
  'languageCode': 'da',
}
```

**Response Stored:**
```dart
FFAppState().mostRecentlyViewedBusinesMenuItems = apiResult.jsonBody;
FFAppState().mostRecentlyViewedBusinessAvailableDietaryPreferences = [...];
FFAppState().mostRecentlyViewedBusinessAvailableDietaryRestrictions = [...];
```

### FilterDescriptionsCall
**Endpoint:** BuildShip filter descriptions API
**Method:** POST
**Called:** Page load

**Parameters:**
```dart
{
  'languageCode': 'da',
  'businessId': 123,
}
```

**Purpose:** Get filter explanations for "Why this match?" section

---

## FFAppState Usage

### Read Properties
```dart
// Business data (from API responses, stored by page)
FFAppState().mostRecentlyViewedBusiness                          // dynamic (JSON)
FFAppState().mostRecentlyViewedBusinesMenuItems                 // dynamic (JSON)
FFAppState().mostRecentlyViewedBusinessAvailableDietaryPreferences  // List<int>
FFAppState().mostRecentlyViewedBusinessAvailableDietaryRestrictions // List<int>

// From Search page (passed via navigation)
FFAppState().openingHours                                        // dynamic (JSON)
FFAppState().filtersOfSelectedBusiness                          // List<int>
FFAppState().filtersForUserLanguage                             // dynamic (JSON) - MISSING from BUNDLE
FFAppState().filtersUsedForSearch                               // List<int> - MISSING from BUNDLE

// User settings
FFAppState().fontScale                                          // double
FFAppState().isBoldTextEnabled                                  // bool
FFAppState().locationStatus                                     // String

// Currency & exchange
FFAppState().exchangeRate                                       // double
FFAppState().userCurrencyCode                                  // String ('DKK', 'EUR', etc.)

// Translation system
FFAppState().translationsCache                                  // dynamic (JSON)

// Menu filtering (menu session state) - MISSING from BUNDLE
FFAppState().selectedDietaryRestrictionId                       // List<int>
FFAppState().excludedAllergyIds                                 // List<int>
FFAppState().selectedDietaryPreferenceId                        // int
FFAppState().visibleItemCount                                   // int

// Favorites (like/unlike button) - MISSING from BUNDLE
FFAppState().restaurantIsFavorited                              // bool

// Analytics tracking
FFAppState().currentFilterSessionId                            // String
FFAppState().sessionStartTime                                  // DateTime
```

### Write Properties
```dart
// API responses stored
FFAppState().mostRecentlyViewedBusiness = apiResult.jsonBody;
FFAppState().mostRecentlyViewedBusinesMenuItems = apiResult.jsonBody;
FFAppState().mostRecentlyViewedBusinessAvailableDietaryPreferences = [...];
FFAppState().mostRecentlyViewedBusinessAvailableDietaryRestrictions = [...];

// Menu filtering state cleared on back button
FFAppState().selectedDietaryRestrictionId = [];
FFAppState().excludedAllergyIds = [];
FFAppState().selectedDietaryPreferenceId = 0;
FFAppState().visibleItemCount = 0;

// Favorites state toggled by like/unlike button
FFAppState().restaurantIsFavorited = true;  // or false
```

---

## Lifecycle Events

### initState (lines 54-125)

**Sequence:**
1. Create model
2. **Post-frame callback** (page load actions):
   - **Parallel API calls:**
     - Call MenuItemsAPI → Store available dietary options
     - Call BusinessProfileAPI → Store business data
     - Call FilterDescriptionsAPI → Get filter explanations
   - Start menu session (non-blocking)
3. Set page load flags:
   - `_model.pageLoadDone = true`
   - `_model.isOpen = false`
   - `_model.pageStartTime = getCurrentTimestamp`
4. Get user location (cached)
5. Initialize expandable controller for hours section

**Critical Details:**
- API calls run in parallel using `Future.wait()`
- Menu session starts immediately (analytics tracking)
- Business data stored in FFAppState for menu/gallery tabs
- Dietary options extracted from menu response

### dispose (lines 128-150)

**Sequence:**
1. **Page dispose action:**
   - End menu session (non-blocking)
   - Track analytics: `business_profile_viewed`
     - Event data: `pageName`, `durationSeconds`, `businessId`
2. Dispose model
3. Dispose expandable controller

**Critical Details:**
- Menu session end calculates time spent browsing
- Analytics tracks full page duration
- Business ID included in analytics

---

## User Interactions

### Tab Button Tap (Menu/Gallery/Information)
**Trigger:** User taps one of the three feature buttons

**Actions:**
1. Mark user engaged
2. Update selected tab state
3. Rebuild UI to show selected section
4. Track analytics: `tab_viewed` event

### Menu Item Tap
**Trigger:** User taps menu item in list

**Actions:**
1. Show `ItemBottomSheet` modal
2. Track analytics: `menu_item_viewed`
3. Mark user engaged

### Gallery Photo Tap
**Trigger:** User taps photo in gallery

**Actions:**
1. Show `ImageGalleryOverlaySwipable` full-screen
2. Track analytics: `gallery_photo_viewed`
3. Mark user engaged

### Opening Hours Expand/Collapse
**Trigger:** User taps hours section header

**Actions:**
1. Toggle `hoursAndContactExpandableController`
2. Animate expansion
3. Track analytics: `hours_expanded`

### Contact Copy (Phone/Email)
**Trigger:** User taps phone number or email

**Actions:**
1. Copy to clipboard
2. Show success toast
3. Track analytics: `contact_copied`
4. Mark user engaged

### Share Button
**Trigger:** User taps share icon

**Actions:**
1. Open system share sheet
2. Share business name + URL
3. Track analytics: `business_shared`

### "Report Missing Info" Button
**Trigger:** User taps report button

**Actions:**
1. Show `ModalSubmitErroneousInfo` modal
2. Track analytics: `report_form_opened`

### Filter Badge Tap ("Why this match?")
**Trigger:** User taps filter explanation badge

**Actions:**
1. Show `FilterDescriptionSheet` modal
2. Display filter details
3. Track analytics: `filter_explanation_viewed`

---

## Navigation

### Entry Points
1. **Search Results** - Tap business card → Business Profile
2. **Deep Link** - Direct URL with businessId parameter

### Exit Points
1. **Back Button** - Returns to Search Results
2. **Bottom Nav** - Navigate to other pages
3. **View on Map** - Opens `ViewOnMapSingleBusiness` modal
4. **Contact Details** - Opens `ContactDetail` modal

### State Preservation
Business data is **cached** in FFAppState:
- Business profile persists when navigating away
- Menu items persist for quick return
- No re-fetch needed on return visit

---

## Analytics Events

### business_profile_viewed
**Tracked:** Page dispose (every exit)

**Event Data:**
```dart
{
  'pageName': 'businessProfile',
  'durationSeconds': '120',
  'businessId': '123',
}
```

### tab_viewed
**Tracked:** Tab button tap

**Event Data:**
```dart
{
  'tabName': 'menu', // or 'gallery', 'information'
  'businessId': '123',
}
```

### menu_item_viewed
**Tracked:** Menu item tap

**Event Data:**
```dart
{
  'itemId': '456',
  'businessId': '123',
  'itemType': 'dish', // or 'package'
}
```

### menu_session_ended
**Tracked:** Page dispose (via endMenuSession)

**Event Data:**
```dart
{
  'businessId': '123',
  'sessionDuration': '180',
  'itemsViewed': '5',
  'filtersUsed': 'true',
}
```

---

## Translation Keys

### FlutterFlow UI Translations
Used for static UI elements (buttons, labels)

### Supabase Dynamic Translations
- Filter names: "Vegan", "Gluten-free"
- Payment method names
- Business type names
- Status text: "til", "opens at"

---

## Dependencies

### pub.dev Packages
```yaml
provider: ^6.1.5          # State management
expandable: ^5.0.1        # Expandable sections
share_plus: ^10.2.0       # Share functionality
```

---

## Display States

### 1. Loading (Initial)
**Condition:** API calls in progress

**Display:**
- Skeleton/shimmer for business card
- Empty sections for tabs
- No user interactions available

### 2. Loaded (Success)
**Condition:** All API calls successful

**Display:**
- Business card with all data
- Tab buttons enabled
- Default tab selected (Menu)
- All interactions available

### 3. Error (API Failure)
**Condition:** API call failed

**Display:**
- Error message
- Retry button
- Previous data shown if cached

---

## Testing Checklist

- [ ] **Page Load**
  - [ ] Business profile API called
  - [ ] Menu items API called
  - [ ] Filter descriptions API called
  - [ ] Menu session started
  - [ ] Page start time recorded
- [ ] **Tab Switching**
  - [ ] Menu tab shows menu items
  - [ ] Gallery tab shows photos
  - [ ] Information tab shows hours/contact
  - [ ] Analytics tracked on each switch
- [ ] **Menu Section**
  - [ ] Categories displayed
  - [ ] Items load correctly
  - [ ] Dietary filters work
  - [ ] Item tap opens detail sheet
- [ ] **Gallery Section**
  - [ ] Photos displayed in grid
  - [ ] Photo tap opens full-screen
  - [ ] Swipe navigation works
- [ ] **Information Section**
  - [ ] Hours displayed correctly
  - [ ] Contact info shown
  - [ ] Payment options visible
  - [ ] Report button works
- [ ] **Analytics**
  - [ ] business_profile_viewed on dispose
  - [ ] menu_session_ended on dispose
  - [ ] tab_viewed on each switch
  - [ ] item_viewed on menu tap
- [ ] **Navigation**
  - [ ] Back returns to search
  - [ ] Bottom nav works
  - [ ] State preserved on return

---

## Migration Notes

### Phase 3 Changes

1. **API Calls** - Keep BuildShip endpoints
2. **State Management** - Migrate FFAppState to Riverpod
3. **Navigation** - Use go_router with same parameters
4. **Tabs** - Implement with TabController
5. **Expandable Sections** - Keep expandable package

---

## Related Pages

| Page | Relationship | Navigation |
|------|--------------|------------|
| **Search Results** | Parent page | Back button returns |
| **Menu Full Page** | Child page | "See full menu" button |
| **Gallery Full Page** | Child page | "See all photos" button |
| **Contact Details** | Modal | Contact info button |

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Priority:** ⭐⭐⭐⭐⭐ Critical (main business page)
