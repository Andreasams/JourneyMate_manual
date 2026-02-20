# Business Information Page — Gap Analysis

**Purpose:** Identify functional differences between JSX v2 design and FlutterFlow implementation

**Methodology:** Compare information_page.jsx (JSX v2) with FlutterFlow BusinessInformationWidget source code

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
| A1 | 0 | Frontend display logic |
| A2 | 0 | Backend processing logic |
| B | 0 | API endpoint changes |
| C | 1 | Translation keys needed (verification only) |
| D | 0 | Known future features |
| **Total** | **1** | **Functional gap identified** |

---

## CRITICAL NOTE: Naming Confusion Resolved

**Directory Name:** `05_contact_details` ❌ (Misleading)
**FlutterFlow Widget:** `BusinessInformationWidget` ✓ (Correct)
**JSX File:** `information_page.jsx` ✓ (Correct)
**Route:** `'BusinessInformation'` (path: `'businessInformation'`)

**Recommendation:** Rename directory to `05_business_information` or `05_information_page` for clarity.

**Note:** `ContactDetailWidget` is a separate custom widget that appears as an expandable section within this page (shows hours, phone, email, address with copy actions).

---

## Documentation Sources

**FlutterFlow Implementation:**
- ✅ Source code provided by user: `BusinessInformationWidget` (complete, 662 lines)
- ✅ Translation keys extracted (3 keys total)
- ✅ Google Maps integration verified
- ✅ Custom widgets documented (ContactDetailWidget, BusinessFeatureButtons, PaymentOptionsWidget)
- ✅ Analytics events documented

**JSX Design:**
- ✅ Complete information_page.jsx (202 lines)
- ✅ Full visual specifications
- ✅ Simple, focused design

**Gap Analysis Status:** Complete with actual FlutterFlow source code.

---

## Page Overview

### FlutterFlow Implementation (Verified)

**File:** `lib/profile/business_information/business_information_widget.dart`
**Route:** `BusinessInformation` (path: `businessInformation`)
**Purpose:** Full-screen dedicated information page showing comprehensive restaurant details

**Page Structure:**
1. **App Bar**
   - Back button (left) → marks engagement, navigates back
   - Business name (center) - dynamically from `FFAppState().mostRecentlyViewedBusiness`

2. **Google Maps Section (200px height)**
   - Shows business location with marker
   - Interactive map (allow zoom, interaction)
   - Marker tap marks user engagement
   - Initial zoom: 12

3. **Business Name & Status (Overlay on Map)**
   - Business name (20px font, 500 weight)
   - Status indicator: colored dot (12px) + dynamic status text
   - Positioned at top of content

4. **Scrollable Content Area**
   - **Description** (if available) - Business description text
   - **Hours & Contact** (expandable) - Uses ContactDetailWidget
   - **Features, services & amenities** - Uses BusinessFeatureButtons custom widget
   - **Payment options** - Uses PaymentOptionsWidget custom widget

**Translation Keys Used (3 keys total):**

| Key | Context | English Comment | Danish Translation |
|-----|---------|-----------------|------------------------|
| `'c9r4q0c8'` | Expandable hours section header | Hours & contact | Timer & kontakt |
| `'7pk0thnp'` | Features section header | Features, services & amenities | Faciliteter, services og... |
| `'zlgcyzrw'` | Payment section header | Payment options | Betalingsmuligheder |

**Custom Widgets Used:**
1. **ContactDetailWidget** - Expandable section showing:
   - Opening hours display
   - Phone, email, address
   - Website, social media links
   - Copy-to-clipboard actions
   - All props passed from `FFAppState().mostRecentlyViewedBusiness`

2. **BusinessFeatureButtons** - Dynamic filter chips:
   - Shows filters/features the business has
   - Tappable to show FilterDescriptionSheet bottom sheet
   - Height calculated dynamically
   - Highlights filters used in search

3. **PaymentOptionsWidget** - Payment method chips:
   - Shows accepted payment methods
   - Height calculated dynamically
   - Highlights payment filters used in search

**Custom Actions Used:**
1. `determineStatusAndColor()` - On page load, calculates open/closed status
2. `getFiltersWithUpdate()` - On page load, fetches filter descriptions
3. `markUserEngaged()` - On back button, map marker tap, hours section expand
4. `trackAnalyticsEvent('page_viewed')` - On dispose with duration

**Custom Functions Used:**
1. `latLongcombine()` - Combines latitude/longitude for map marker
2. `daysDayOpeningHour()` - Calculates dynamic status text
3. `getSessionDurationSeconds()` - Calculates time on page

**FFAppState Usage:**
- Read: `mostRecentlyViewedBusiness`, `openingHours`, `translationsCache`, `filtersForUserLanguage`, `filtersUsedForSearch`, `filtersOfSelectedBusiness`

**Props Received:**
- `filterDescriptions` (dynamic) - Filter data for BusinessFeatureButtons

**Analytics Event:**
- Event name: `page_viewed`
- Event data: `pageName: 'businessInformation'`, `durationSeconds`

**Code Reference:** FlutterFlow source code provided by user

---

## JSX Design Overview

### Information Page Design (information_page.jsx)

**Purpose:** Full-screen detail view with comprehensive restaurant information

**Visual Structure:**
- StatusBar (20px)
- Fixed header (60px) with back button and restaurant name
- Scrollable content (790px):
  1. Hero image placeholder (180px, grey background `#d0d0d0`)
  2. Restaurant name (24px, 750 weight)
  3. Status indicator (6px dot + 13px text)
  4. About description (14px, if available)
  5. Opening hours section (expandable) - Uses OpeningHoursSection component
  6. Facilities chips (if available)
  7. Payment methods chips (if available)

**Design Philosophy:**
- Content hierarchy: name/status → description → hours → facilities → payments
- Expandable sections for opening hours
- Visual consistency with business profile page
- Information density balanced with whitespace

**Key Differences from FlutterFlow:**
- JSX uses grey hero image placeholder (180px)
- FlutterFlow uses Google Maps (200px) ← More functional
- JSX uses shared OpeningHoursSection component
- FlutterFlow uses ContactDetailWidget with more features (phone/email copy, social links)
- JSX shows hardcoded Danish text ("Åbningstider m.m.", "Faciliteter og services", "Betalingsmuligheder")
- FlutterFlow uses translation keys for internationalization

**Code Reference:** `information_page.jsx` lines 1-202

---

## Detailed Gap Analysis

### Gap C.1: Business Information Page Translation Keys

**JSX v2 Design:**
- Hardcoded text (not internationalized):
  - "Åbningstider m.m." (Hours etc.)
  - "Faciliteter og services" (Facilities and services)
  - "Betalingsmuligheder" (Payment options)
- Code reference: `information_page.jsx` lines 121, 136, 172

**FlutterFlow Implementation (Verified from Source Code):**

The FlutterFlow implementation uses **3 translation keys** for section headers:

| Key | Context | English Comment | Danish Translation |
|-----|---------|-----------------|------------------------|
| `'c9r4q0c8'` | Expandable section header | Hours & contact | Timer & kontakt |
| `'7pk0thnp'` | Features section header | Features, services & amenities | Faciliteter, services og... |
| `'zlgcyzrw'` | Payment section header | Payment options | Betalingsmuligheder |

**Additional Translation Keys:**

The custom widgets used on this page have their own translation keys:
- **ContactDetailWidget** - Has internal translation keys for labels (hours, phone, email, address, website, social media, etc.)
- **BusinessFeatureButtons** - Uses filter names from `filtersForUserLanguage` (dynamically translated)
- **PaymentOptionsWidget** - Uses filter names from `filtersForUserLanguage` (dynamically translated)

**No Gap:** All page-level translation keys are already in FlutterFlow. Need to add to MASTER_TRANSLATION_KEYS.md for consistency.

**Note:** Custom widget translation keys documented separately in shared/widgets documentation.

---

## FlutterFlow Features NOT in JSX Design

### 1. Google Maps Integration

**Feature:** Interactive Google Maps showing business location (200px height)

**Implementation:**
- Shows business marker at lat/long
- Initial zoom level: 12
- Allows user interaction and zoom
- Marker tap marks user engagement
- Red marker color

**Design Rationale:**
- More useful than static grey placeholder image
- Users can see exact location visually
- Supports orientation and nearby landmarks

**Not in JSX:** JSX shows grey placeholder image (180px)

### 2. ContactDetailWidget Integration

**Feature:** Expandable "Hours & contact" section with comprehensive contact information

**Implementation:**
- Opening hours display (using openingHours data)
- Phone number with copy action
- Email with copy action
- Full address with map link
- Website URL
- Social media links (Instagram, Facebook)
- Reservation URL
- All props passed from `FFAppState().mostRecentlyViewedBusiness`

**Design Rationale:**
- One-tap copy for phone/email
- Direct links to external resources
- More comprehensive than JSX OpeningHoursSection

**Not in JSX:** JSX uses simpler OpeningHoursSection component (hours + basic contact)

### 3. Dynamic Filter Feature Buttons

**Feature:** BusinessFeatureButtons custom widget showing restaurant features/filters

**Implementation:**
- Shows only filters/features the business actually has
- Highlights filters that match user's search criteria
- Tappable to show FilterDescriptionSheet bottom sheet
- Height calculated dynamically based on content
- Callbacks: `onInitialCount`, `onFilterTap`, `onHeightCalculated`

**Design Rationale:**
- Interactive filter descriptions
- Visual indication of search match
- Dynamic layout (no wasted space)

**Not in JSX:** JSX shows static chips with facility names

### 4. Dynamic Payment Options Widget

**Feature:** PaymentOptionsWidget custom widget showing payment methods

**Implementation:**
- Shows accepted payment methods as chips
- Highlights payment filters used in search
- Height calculated dynamically
- Similar pattern to BusinessFeatureButtons

**Design Rationale:**
- Consistent with filter features display
- Dynamic layout
- Search match indication

**Not in JSX:** JSX shows static chips with payment method names

### 5. Filter Description Bottom Sheets

**Feature:** Tappable filter chips open FilterDescriptionSheet modal

**Implementation:**
- On filter tap → shows bottom sheet with filter name and detailed description
- Uses `FilterDescriptionSheetWidget`
- Full-screen modal overlay

**Design Rationale:**
- Users can learn what each filter means
- Educational feature
- Helps users understand restaurant features

**Not in JSX:** No interaction with filter chips

### 6. Preloading on Page Load

**Feature:** Multiple actions triggered on `initState`

**Implementation:**
- `determineStatusAndColor()` - Calculate current open/closed status
- `getFiltersWithUpdate()` - Load filter descriptions
- Record page start time for analytics

**Design Rationale:**
- Prepares all data before display
- No loading delays during user interaction

**Not in JSX:** JSX is static, doesn't document initialization

### 7. Analytics Tracking

**Feature:** Page view analytics with duration tracking

**Implementation:**
- Records `pageStartTime` on initState
- Tracks `page_viewed` event on dispose
- Event data: `pageName: 'businessInformation'`, `durationSeconds`

**Not in JSX:** No analytics documented

---

## Architecture Summary

### Frontend Logic (A1) - 0 gaps

All logic implemented correctly:
- Google Maps integration
- Expandable hours section
- Dynamic filter and payment widgets
- Filter description bottom sheets
- Status calculation
- User engagement tracking

### Backend Logic (A2) - 0 gaps

No backend processing required. All data comes from `FFAppState().mostRecentlyViewedBusiness`.

### API Changes (B) - 0 gaps

No API calls on this page. Data already loaded from previous page.

### Translation Keys (C) - 1 gap

- 3 page-level translation keys already exist in FlutterFlow
- Custom widget translation keys documented separately
- Need to add to MASTER_TRANSLATION_KEYS.md for consistency

### Known Missing (D) - 0 gaps

No features explicitly marked as "not in current scope" by user.

---

## Migration Notes

### High Priority Items

1. **Add translation keys to MASTER_TRANSLATION_KEYS.md**
   - 3 page-level keys
   - Include English and Danish translations
   - Mark as "already in FlutterFlow"
   - Note custom widget keys documented separately

2. **Consider directory rename**
   - Current: `05_contact_details`
   - Proposed: `05_business_information`
   - Reason: Matches FlutterFlow widget name and actual purpose

### Medium Priority Items

1. **Document Custom Widgets**
   - ContactDetailWidget - Already has MASTER_README in shared/widgets
   - BusinessFeatureButtons - Needs documentation
   - PaymentOptionsWidget - Needs documentation
   - FilterDescriptionSheet - Needs documentation

2. **Document FFAppState Variables**
   - `mostRecentlyViewedBusiness` - Contains all business data
   - `openingHours` - Opening hours data
   - `filtersForUserLanguage` - Translated filter names
   - `filtersUsedForSearch` - Filters used in current search
   - `filtersOfSelectedBusiness` - Filters this business has

### Low Priority Items

1. **Hero Image vs Maps** - JSX shows grey placeholder, FlutterFlow uses Google Maps (decision: keep Google Maps, more functional)

---

## Known Issues

None identified. FlutterFlow implementation is comprehensive and functional.

---

## Next Steps

1. **Add translation keys to MASTER_TRANSLATION_KEYS.md**
   - 3 keys from Business Information Page
   - Include English and Danish translations
   - Mark as "already in FlutterFlow"

2. **Create BUNDLE_information_page.md**
   - Full widget specification
   - User flows diagram
   - Custom widget integration details
   - Google Maps integration

3. **Update PAGE_README.md** ✅ Already done
   - Corrected description from "contact modal" to "full information page"

4. **Consider directory rename**
   - Discuss with user: rename `05_contact_details` → `05_business_information`

5. **Document remaining custom widgets**
   - BusinessFeatureButtons
   - PaymentOptionsWidget

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete
**Total Gaps:** 1 (0 frontend + 0 backend + 0 API + 1 translation verification + 0 missing)

**Key Finding:** FlutterFlow implementation is **significantly MORE comprehensive** than JSX design:
- **JSX Design:** Static page with grey image placeholder, simple component reuse
- **FlutterFlow:** Interactive Google Maps, comprehensive ContactDetailWidget, dynamic filter/payment widgets, filter description bottom sheets, analytics tracking
- **Translation Keys:** 3 page-level keys (JSX has hardcoded Danish text)
- **Custom Widgets:** 3 specialized widgets (ContactDetail, BusinessFeatureButtons, PaymentOptions)
- **Interactivity:** Filter chips tappable for descriptions (JSX: static chips)

**Key Decision:** Preserve FlutterFlow's comprehensive implementation. The interactive features (maps, filter descriptions, dynamic widgets) provide significantly better UX than JSX's static design.

---

## Appendix: JSX Design Features (For Reference)

### Visual Design Elements

**Layout:**
- 390 × 844px canvas (iPhone standard)
- StatusBar: 20px
- Header: 60px fixed
- Scrollable content: 790px with 40px bottom padding
- Content padding: 24px horizontal (from line 73)

**Typography:**
- Restaurant name (header): 16px, 600 weight (line 57)
- Restaurant name (content): 24px, 750 weight (line 76)
- Status text: 13px, 460 weight (line 98)
- About text: 14px, 400 weight, 20px line-height (line 109)
- Section headers: 15px, 600 weight (lines 132, 167)
- Chip text: 12.5px, 540 weight (lines 149, 186)

**Colors:**
- Background: `#fff` (white)
- Header border: `#f2f2f2` (subtle)
- Text primary: `#0f0f0f` (near-black)
- Text secondary: `#555` (grey)
- Status dot open: `GREEN` (`#1a9456`)
- Status dot closed: `#c9403a` (red)
- Hero placeholder: `#d0d0d0` (grey)
- Chip border: `#e8e8e8` (light grey)

**Component Sizes:**
- Hero image: 180px height (line 68)
- Status dot: 6px diameter (line 93)
- Chips: 7px vertical padding, 12px horizontal padding, 10px border-radius (lines 147, 184)

**Spacing:**
- Name → Status: 6px margin (line 79)
- Status → About: 16px margin (line 89)
- About → Hours: 24px margin (line 113)
- Sections: 24px margin bottom (lines 129, 161)
- Section header → Content: 12px margin (lines 135, 170)
- Chips: 8px gap (lines 141, 176)

**Design Reference:** `information_page.jsx` full specification
