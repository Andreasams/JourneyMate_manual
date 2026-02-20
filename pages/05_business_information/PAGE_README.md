# Business Information Page

**Route:** `/BusinessInformation`
**Route Name:** `BusinessInformation`
**FlutterFlow Widget:** `BusinessInformationWidget`
**JSX File:** `information_page.jsx`
**Status:** ✅ Production Ready

---

## Purpose

Full-screen dedicated information page showing comprehensive restaurant details including location map, opening hours, facilities, payment methods, and business description.

**Primary User Task:** View detailed restaurant information beyond what's shown on the main business profile.

**Accessed From:** Business Profile page → "Se alle informationer →" link

---

## Key Features

- **Google Maps Integration:** Interactive map showing business location
- **Business Header:** Name displayed in app bar
- **Status Display:** Current open/closed status with colored indicator
- **Expandable Hours:** Opening hours section with expand/collapse
- **Filter Descriptions:** Detailed descriptions of restaurant features
- **Contact Details Modal:** Tappable button to show ContactDetailWidget modal
- **Analytics Tracking:** Page view duration

---

## Custom Widgets Used

| Widget | Purpose | Priority |
|--------|---------|----------|
| `FilterDescriptionSheet` | Bottom sheet with filter explanations | ⭐⭐⭐⭐ |
| `ContactDetailWidget` | Modal showing phone/email/address with copy actions | ⭐⭐⭐⭐ |

---

## Custom Actions Used

| Action | Purpose |
|--------|---------|
| `determineStatusAndColor` | Calculate current open/closed status |
| `getFiltersWithUpdate` | Load filter descriptions |
| `markUserEngaged` | Track user engagement |
| `trackAnalyticsEvent` | Track page views |

---

## Custom Functions Used

| Function | Purpose |
|----------|---------|
| `latLongcombine` | Combine latitude/longitude for map marker |
| `getSessionDurationSeconds` | Calculate time spent on page |
| `getTranslations` | Get translated strings |

---

## FFAppState Usage

### Read
- `mostRecentlyViewedBusiness` - Business data to display
- `openingHours` - Opening hours data for status calculation
- `translationsCache` - Translations cache

### Write
- None (read-only page)

---

## Props Received

| Prop | Type | Purpose |
|------|------|---------|
| `filterDescriptions` | dynamic | Filter data for descriptions |

---

## Lifecycle Events

**initState:**
1. Record page start time
2. Calculate current open/closed status
3. Load filter descriptions

**dispose:**
1. Track analytics: `page_viewed` with duration

---

## User Interactions

**Back Button:** Mark engagement → Navigate back
**Map Marker Tap:** Mark engagement (opens map directions)
**Hours Section:** Expand/collapse opening hours
**Contact Button:** Open ContactDetailWidget modal
**Filter Description Tap:** Open FilterDescriptionSheet bottom sheet

---

## Page Structure

### Header (AppBar)
- Back button (left)
- Business name (center)
- White background

### Body (Scrollable)
- Google Maps (200px height) showing business location
- Expandable hours and contact section
- Filter descriptions sections
- Contact details button

---

## Analytics Events

- `page_viewed` - Page name: 'businessInformation', duration seconds

---

## Translation Keys

**Note:** This page uses `FFAppState().translationsCache` and `getTranslations()` function for dynamic content. Translation keys need to be extracted from source code.

---

## Known Issues

**Directory Naming:**
⚠️ Directory is called "05_contact_details" but contains `BusinessInformationWidget` (the full information page).
- **Recommendation:** Rename directory to "05_business_information" or "05_information_page" for clarity
- ContactDetailWidget is a separate modal component (should be documented in shared/widgets)

---

## Migration Priority

⭐⭐⭐⭐ **High** - Essential detail view for business information

---

## Related Pages

- **Business Profile** - Links to this page via "Se alle informationer →"
- **ContactDetailWidget** (modal) - Shown as overlay on this page
- **FilterDescriptionSheet** (bottom sheet) - Shown as overlay on this page

---

**Last Updated:** 2026-02-19

**Note:** This page was previously misidentified as just a "Contact Details" modal. It is actually the full Business Information page. Gap analysis needed.
