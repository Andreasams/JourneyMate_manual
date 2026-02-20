# Business Profile Page — Gap Analysis

**Purpose:** Identify functional differences between JSX v2 design and FlutterFlow implementation

**Methodology:** Compare DESIGN_README_business_profile.md (JSX v2) with PAGE_README.md + BUNDLE.md (FlutterFlow)

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
| A1 | 3 | Frontend display logic |
| A2 | 0 | Backend processing logic |
| B | 2 | API endpoint changes |
| C | 12 | Translation keys needed |
| D | 0 | Known future features |
| **Total** | **17** | **Functional gaps identified** |

---

## Detailed Gap Analysis

### Gap A1.1: Facility Highlighting Based on User Needs

**JSX v2 Design:**
- Facility pills have green background (`GREEN_BG = "#f0f9f3"`) if they match user's active needs
- Matching logic: Bidirectional substring matching, case-insensitive
- Example: Need "Kørestol" matches facility "Kørestolsvenlig"
- Code reference: `DESIGN_README_business_profile.md` lines 860-877

**FlutterFlow Implementation:**
- `ProfileTopBusinessBlockWidget` displays facilities
- Unknown if highlighting logic is implemented
- Requires access to `FFAppState().filtersUsedForSearch` (user's active needs)

**Gap:**
Verify if facility highlighting is implemented. If not, add logic to:
1. Compare facility strings against user's active needs
2. Apply green background styling to matched facilities
3. Use same matching logic as JSX (bidirectional substring, case-insensitive)

**Architecture Recommendation:** Frontend (A1)
- Simple display logic comparing two string arrays
- Should happen in ProfileTopBusinessBlockWidget
- No heavy computation, no API changes needed

**Implementation Notes:**
- Facility strings come from business profile API
- User needs come from `FFAppState().filtersUsedForSearch`
- Match detection: `facility.toLowerCase().includes(need.toLowerCase()) || need.toLowerCase().includes(facility.toLowerCase())`

---

### Gap A1.2: Menu Item Description Truncation

**JSX v2 Design:**
- Menu item descriptions truncated to 2 lines with ellipsis
- CSS: `-webkit-line-clamp: 2`, `-webkit-box-orient: vertical`
- Full description visible in ItemBottomSheet detail overlay
- Code reference: `DESIGN_README_business_profile.md` lines 744-747

**FlutterFlow Implementation:**
- `MenuDishesListView` displays menu items
- Unknown if 2-line truncation is implemented

**Gap:**
Verify if MenuDishesListView implements description truncation. If not, add:
1. Text widget with `maxLines: 2`
2. Overflow: `TextOverflow.ellipsis`
3. Full description shown in ItemBottomSheet when tapped

**Architecture Recommendation:** Frontend (A1)
- Pure display logic in Flutter widget
- No API changes needed

**Implementation Notes:**
- Use Flutter's built-in `Text` widget with `maxLines` and `overflow` properties
- Full description already available in ItemBottomSheet

---

### Gap A1.3: Empty State for Filtered Menu

**JSX v2 Design:**
- When all menu items filtered out: `currentItems.length === 0`
- Shows info icon with message: "Ingen retter matcher dine filtre"
- Suggestion text: "Prøv at fjerne nogle filtre eller vælg 'Ryd alle' for at se hele menuen."
- Code reference: `DESIGN_README_business_profile.md` lines 841-847

**FlutterFlow Implementation:**
- `MenuDishesListView` handles menu filtering
- Unknown if empty state is implemented

**Gap:**
Verify if MenuDishesListView shows empty state when no items match filters. If not, add:
1. Check if filtered item count is 0
2. Show empty state widget with icon
3. Display localized message with suggestion to clear filters

**Architecture Recommendation:** Frontend (A1)
- Pure display logic based on filtered results count
- No API changes needed

**Translation Keys Needed:**
- `menu_empty_state_title`: "Ingen retter matcher dine filtre"
- `menu_empty_state_body`: "Prøv at fjerne nogle filtre eller vælg 'Ryd alle' for at se hele menuen."

---

### Gap B.1: Multiple Opening Hours Slots Per Day

**JSX v2 Design:**
- Supports 3 formats:
  1. String: `"10:00–22:00"` or `"Lukket"`
  2. Single slot: `[{time: "10:00–22:00"}]`
  3. Multiple slots: `[{time: "07:00–10:00", note: "Køkken lukker 09:30"}, {time: "11:30–14:30"}]`
- Rendering: One row per slot, note shown right-aligned in gray
- Code reference: `DESIGN_README_business_profile.md` lines 848-859

**FlutterFlow Implementation:**
- Opening hours passed from Search page via `FFAppState().openingHours`
- Unknown if multiple slots per day are supported in API response

**Gap:**
Verify if BusinessProfileAPI returns multiple slots per day for split shifts. If not:
1. Update API to return array of time slots per day
2. Include optional `note` field for each slot
3. Update ProfileTopBusinessBlockWidget to render multiple slots

**Architecture Recommendation:** Backend (B)
- API change required to support multiple slots
- Business logic (parsing restaurant hours) belongs in BuildShip
- Frontend just renders whatever structure is provided

**BuildShip Changes:**
```typescript
// Current structure (assumed):
{
  "business_hours": {
    "Mandag": "10:00–22:00",
    "Tirsdag": "10:00–22:00"
  }
}

// New structure (needed):
{
  "business_hours": {
    "Mandag": [
      { "time": "07:00–10:00", "note": "Køkken lukker 09:30" },
      { "time": "11:30–14:30" }
    ],
    "Tirsdag": "10:00–22:00"  // Still support string for single slot
  }
}
```

---

### Gap B.2: Menu Item Detail Availability

**JSX v2 Design:**
- Only first 3 items in entire menu have full detail data
- Hardcoded in `menuItemDetails` object keyed by exact item name
- Other items don't have nutritional info, ingredients, allergens
- Code reference: `DESIGN_README_business_profile.md` lines 931-936

**FlutterFlow Implementation:**
- `ItemBottomSheetWidget` shows menu item details
- Unknown if all items have full detail data or just subset

**Gap:**
Verify if MenuItemsAPI returns full detail for all items or just subset. Ensure:
1. API returns complete data for all menu items
2. If data is incomplete for some items, gracefully hide unavailable fields
3. Don't show "tap for details" if no details available

**Architecture Recommendation:** Backend (B)
- Menu item detail data should be complete in API
- If not all items have details, mark which items are "detail-ready"
- Frontend hides tap gesture for items without details

**BuildShip Changes:**
- Ensure MenuItemsAPI returns complete nutritional data for all items
- If not available, add `hasDetailData: boolean` field to each item
- Frontend checks `hasDetailData` before allowing item tap

---

### Gap C.1: Match Card Translations

**JSX v2 Design:**
- Match card header: "Why this match?" / "Hvorfor matcher det?"
- Matched needs: Green check icon + need name
- Missed needs: Red X icon + need name
- "See full list" button (when >3 needs)
- Code reference: `DESIGN_README_business_profile.md` lines 111-138

**FlutterFlow Implementation:**
- ProfileTopBusinessBlockWidget shows match card
- Unknown what translation keys are used

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `match_card_header` | Match card title | Why this match? | Hvorfor matcher det? |
| `match_see_full_list` | Button to expand all needs | See full list | Se hele listen |
| `match_matched_needs` | Section label for matched needs | Matches your needs | Matcher dine behov |
| `match_missed_needs` | Section label for missed needs | Doesn't match | Matcher ikke |

---

### Gap C.2: Quick Action Pills Translations

**JSX v2 Design:**
- Four quick action pills at top of page
- "Ring op", "Hjemmeside", "Bestil bord", "Se på kort"
- Pills only shown if corresponding data exists
- Code reference: `DESIGN_README_business_profile.md` lines 140-154

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `action_call` | Call restaurant button | Call | Ring op |
| `action_website` | Visit website button | Website | Hjemmeside |
| `action_book_table` | Book table button | Book table | Bestil bord |
| `action_view_map` | View on map button | View on map | Se på kort |

---

### Gap C.3: Menu Section Translations (Shared with Menu Full Page)

**CRITICAL NOTE:** The menu section on Business Profile uses the **SAME WIDGETS** as Menu Full page:
- `UnifiedFiltersWidget` (collapsible filter panel)
- `MenuCategoriesRows` (category navigation chips)
- `MenuDishesListView` (menu items scrollable list)

**Source:** BUNDLE.md lines 119-164 shows these widgets are used on Business Profile page.

Therefore, ALL translation keys from Menu Full page are also needed on Business Profile page.

**JSX v2 Design:**
- Menu filter toggle: "Filtrer" / "Skjul filtre"
- Filter labels: "Kostrestriktioner", "Allergener", "Kostpræferencer"
- "Ryd alle" button to clear filters
- "Vis på hel side →" button to open full menu page
- Code reference: `DESIGN_README_business_profile.md` lines 202-269

**Translation Keys Needed (Shared with Menu Full Page):**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `menu_filter_show` | Show filters button | Filter | Filtrer |
| `menu_filter_hide` | Hide filters button | Hide filters | Skjul filtre |
| `filter_restrictions_label` | Dietary restrictions section header | Dietary Restrictions | Kostrestriktioner |
| `filter_restrictions_explain` | Explainer text for restrictions | Show only dishes that meet the selected dietary restriction. | Vis kun retter, der overholder den valgte kostrestriktion. |
| `filter_preferences_label` | Dietary preferences section header | Dietary Preferences | Kostpræferencer |
| `filter_preferences_explain` | Explainer text for preferences | Show only dishes that meet the selected diet. | Vis kun retter, der overholder den valgte diæt. |
| `filter_allergens_label` | Allergens section header | Allergens | Allergener |
| `filter_allergens_explain` | Explainer text for allergens | Hide dishes that contain the selected allergen. | Skjul retter, der indeholder det valgte allergen. |
| `menu_filter_clear_all` | Clear all filters button | Clear all | Ryd alle |
| `menu_view_full_page` | Open full menu page button | View full menu → | Vis på hel side → |
| `menu_showing_count` | Filter summary text | Showing {count} items | Viser {count} retter |
| `menu_showing_count_filtered` | Filter summary with filters active | Showing {count} items matching your filters | Viser {count} retter der matcher dine filtre |
| `menu_no_items_title` | Empty state heading when no items match | No dishes found | Ingen retter fundet |
| `menu_no_items_body` | Empty state description | Try adjusting your filters or select 'Clear all' to see the full menu. | Prøv at justere dine filtre eller vælg 'Ryd alle' for at se hele menuen. |

**Note:** Filter names themselves (Vegan, Gluten-free, etc.) are already in Supabase `translations` table.

**Note:** These keys are documented in Menu Full page gap analysis and should be counted only ONCE in the grand total.

---

### Gap C.4: Gallery Section Translations

**JSX v2 Design:**
- Three gallery tabs: "Mad", "Drikkevarer", "Lokale"
- "Se alle billeder →" button to open full gallery page
- Code reference: `DESIGN_README_business_profile.md` lines 271-320

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `gallery_tab_food` | Food photos tab | Food | Mad |
| `gallery_tab_drinks` | Drinks photos tab | Drinks | Drikkevarer |
| `gallery_tab_ambiance` | Ambiance photos tab | Ambiance | Lokale |
| `gallery_view_all` | Open full gallery button | View all photos → | Se alle billeder → |

---

### Gap C.5: Information Section Translations

**JSX v2 Design:**
- Opening hours section: "Åbningstider" header, "I dag: [hours]" preview
- Facilities section: "Faciliteter" header
- Payment section: "Betalingsmuligheder" header
- About section: "Om" header
- "Rapportér fejl" button at bottom
- Code reference: `DESIGN_README_business_profile.md` lines 322-433

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `info_hours_header` | Opening hours section title | Opening hours | Åbningstider |
| `info_hours_today` | Today's hours preview | Today: {hours} | I dag: {hours} |
| `info_facilities_header` | Facilities section title | Facilities | Faciliteter |
| `info_payments_header` | Payment options section title | Payment options | Betalingsmuligheder |
| `info_about_header` | About section title | About | Om |
| `info_report_error` | Report error button | Report incorrect info | Rapportér fejl |

**Parameters:**
- `{hours}`: Today's opening hours (e.g., "10:00–22:00")

**Usage Example:**
```dart
final text = getTranslations(lang, 'info_hours_today', cache)
  .replaceAll('{hours}', '10:00–22:00');
// Result: "I dag: 10:00–22:00"
```

---

### Gap C.6: Menu Empty State Translations

**Covered in Gap A1.3**

Translation Keys:
- `menu_empty_state_title`: "Ingen retter matcher dine filtre"
- `menu_empty_state_body`: "Prøv at fjerne nogle filtre eller vælg 'Ryd alle' for at se hele menuen."

---

### Gap C.7: Contact Info Translations

**JSX v2 Design:**
- Contact rows in information section
- Phone, email, Instagram, address
- Copy-to-clipboard confirmation toast
- Code reference: Lines 362-398 (not fully documented in excerpt)

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `contact_phone` | Phone label | Phone | Telefon |
| `contact_email` | Email label | Email | Email |
| `contact_instagram` | Instagram label | Instagram | Instagram |
| `contact_address` | Address label | Address | Adresse |
| `contact_copied` | Copy success toast | Copied to clipboard | Kopieret til udklipsholder |

---

### Gap C.8: Share Button Translation

**JSX v2 Design:**
- Share button in hero section
- Opens native share sheet with restaurant name + URL
- Code reference: `DESIGN_README_business_profile.md` lines 883-886

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `share_message` | Share sheet message template | Check out {name}: {url} | Tjek {name} ud: {url} |

**Parameters:**
- `{name}`: Restaurant name
- `{url}`: Restaurant profile URL

---

### Gap C.9: Opening Hours Day Names

**JSX v2 Design:**
- Danish day names: "Søndag", "Mandag", "Tirsdag", "Onsdag", "Torsdag", "Fredag", "Lørdag"
- Order matters for "I dag" calculation
- Code reference: `DESIGN_README_business_profile.md` lines 921-930

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `day_sunday` | Sunday | Sunday | Søndag |
| `day_monday` | Monday | Monday | Mandag |
| `day_tuesday` | Tuesday | Tuesday | Tirsdag |
| `day_wednesday` | Wednesday | Wednesday | Onsdag |
| `day_thursday` | Thursday | Thursday | Torsdag |
| `day_friday` | Friday | Friday | Fredag |
| `day_saturday` | Saturday | Saturday | Lørdag |

**Note:** These may already exist in FFLocalizations. Verify before adding to Supabase.

---

### Gap C.10: Status Text Translations

**JSX v2 Design:**
- Open status: "Åben til [time]"
- Closed status: "Lukket"
- Opens at: "Åbner kl. [time]"
- Closes tomorrow: "Lukker i morgen kl. [time]"

**Translation Keys Needed:**

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `status_open_until` | Open until time | Open until {time} | Åben til {time} | `{time}` |
| `status_closed` | Closed now | Closed | Lukket | - |
| `status_opens_at` | Opens at time | Opens at {time} | Åbner kl. {time} | `{time}` |
| `status_closes_tomorrow` | Closes tomorrow at time | Closes tomorrow at {time} | Lukker i morgen kl. {time} | `{time}` |

**Note:** These may already exist in Search page translations. Verify before duplicating.

---

### Gap C.11: Menu Category Translations

**JSX v2 Design:**
- Menu categories are data-driven (from API)
- Category names like "Forretter", "Hovedretter", "Desserter"
- Code reference: `DESIGN_README_business_profile.md` lines 211-220

**Implementation Note:**
Category names should already be in Supabase `translations` table as part of menu data structure. Verify with BuildShip MenuItemsAPI response. If missing, add to translations table as data, not UI keys.

---

### Gap C.12: ExpandableTextWidget Translations

**JSX v2 Design:**
- "Read more" / "Read less" buttons for long descriptions
- Used in "Om" section
- Code reference: `BUNDLE.md` lines 206-227

**FlutterFlow Implementation:**
- Already has translation keys: `read_more` and `read_less`
- Used in ExpandableTextWidget

**No Gap:** These keys already exist in FlutterFlow. Verify they're in Supabase translations table.

---

## Features in FlutterFlow NOT in JSX Design

These are enhancements that exist in FlutterFlow but weren't specified in the JSX v2 design. They should be preserved during migration.

### Enhancement 1: Category Description Sheet
- **Widget:** `CategoryDescriptionSheetWidget`
- **Purpose:** Shows explanation modal when user taps info icon next to menu category
- **Usage:** Lines 1334-1342 in BUNDLE.md
- **Keep:** Yes, this improves UX by explaining menu categories

### Enhancement 2: Package Bottom Sheet
- **Widget:** `PackageBottomSheetWidget`
- **Purpose:** Shows menu package details (multi-course meals)
- **Usage:** Lines 1291-1299 in BUNDLE.md
- **Keep:** Yes, packages are a valid menu item type

### Enhancement 3: Filter Description Sheet
- **Widget:** `FilterDescriptionSheetWidget`
- **Purpose:** "Why this match?" explanation for each filter
- **Usage:** Lines 1496-1505 in BUNDLE.md (from PAGE_README lines 362-369)
- **Keep:** Yes, helps users understand matching logic

### Enhancement 4: Menu Session Analytics
- **Actions:** `startMenuSession`, `endMenuSession`
- **Purpose:** Track time spent browsing menu
- **Usage:** Lines 102 (start), 133 (end) in BUNDLE.md
- **Keep:** Yes, valuable analytics for understanding user behavior

### Enhancement 5: Contact Detail Modal
- **Widget:** `ContactDetailWidget`
- **Purpose:** Full-screen modal with copy-to-clipboard for contact info
- **Usage:** Lines 520-536 in BUNDLE.md
- **Keep:** Yes, better UX than inline contact display

### Enhancement 6: Like/Unlike Button
- **State:** `FFAppState().restaurantIsFavorited`
- **Purpose:** Save restaurant to favorites
- **Usage:** Lines 229, 260 in BUNDLE.md (PAGE_README)
- **Keep:** Yes, common feature for restaurant apps

### Enhancement 7: View on Map Modal
- **Modal:** `ViewOnMapSingleBusiness`
- **Purpose:** Shows restaurant location on map
- **Usage:** Line 294 in PAGE_README.md
- **Keep:** Yes, essential for location-based app

### Enhancement 8: Parallel API Optimization
- **Pattern:** `Future.wait()` for parallel API calls
- **Purpose:** Load business profile + menu items simultaneously
- **Usage:** Lines 64-107 in BUNDLE.md
- **Keep:** Yes, significant performance improvement

### Enhancement 9: Report Error Form
- **Widget:** `ModalSubmitErroneousInfoWidget`
- **Purpose:** User feedback form for incorrect business data
- **Usage:** Lines 1674-1684 in BUNDLE.md
- **Keep:** Yes, essential for data quality

---

## Migration Notes

### High Priority Gaps
1. **Gap B.1**: Multiple opening hours slots (affects restaurants with split shifts)
2. **Gap A1.1**: Facility highlighting (core matching feature)
3. **Gap C.1-C.12**: All translation keys (blocking international launch)

### Medium Priority Gaps
1. **Gap B.2**: Menu item detail availability (affects UX consistency)
2. **Gap A1.2**: Menu description truncation (visual polish)
3. **Gap A1.3**: Menu empty state (UX improvement)

### Low Priority Gaps
None identified. All gaps are functional or translation-related.

---

## Architecture Summary

### Frontend Logic (A1) - 3 gaps
- Facility highlighting based on user needs
- Menu description truncation to 2 lines
- Empty state when menu filters return no results

### Backend Logic (A2) - 0 gaps
No gaps requiring backend processing before returning data to Flutter.

### API Changes (B) - 2 gaps
- Support multiple opening hours slots per day
- Ensure all menu items have complete detail data

### Translation Keys (C) - 12 gaps
- 44 total translation keys needed across all sections
- **Note:** Menu section keys (13 keys) are SHARED with Menu Full page - they use the same widgets (UnifiedFiltersWidget, MenuCategoriesRows, MenuDishesListView)
- These shared keys should be counted only ONCE in the grand total
- Follow naming convention: `section_subsection_element`
- Add to MASTER_TRANSLATION_KEYS.md for SQL generation

### Known Missing (D) - 0 gaps
No features explicitly marked as "not in current scope" by user.

---

## Next Steps

1. **Add translation keys to MASTER_TRANSLATION_KEYS.md**
   - All 48 keys identified in gaps C.1-C.12
   - Include English and Danish translations
   - Note parameters for dynamic text

2. **Verify FlutterFlow implementations**
   - Read ProfileTopBusinessBlockWidget source for facility highlighting
   - Read MenuDishesListView source for description truncation + empty state
   - Confirm which translation keys already exist

3. **Plan BuildShip API modifications**
   - Multiple opening hours slots structure
   - Menu item detail completeness validation

4. **Continue gap analysis for remaining pages**
   - Menu Full page
   - Gallery Full page
   - Settings page

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete
**Total Gaps:** 17 (3 frontend + 0 backend + 2 API + 12 translation + 0 known missing)
