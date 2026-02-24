# ItemDetailSheet

**Type:** Custom Widget
**File:** `item_detail_sheet.dart` (1765 lines)
**Category:** Menu & Restaurant Details
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Core menu functionality)

---

## Purpose

A comprehensive modal bottom sheet that displays detailed information about a single menu item from a restaurant's menu. Provides rich content including item images, descriptions, pricing, dietary information, allergens, and modifier groups (variations, options, add-ons). Features self-contained language switching and currency conversion capabilities without affecting parent widget state.

**Key Features:**
- Full-height draggable modal sheet with image header
- Item name, description, and base price display
- "From" pricing prefix for items with variations
- Modifier groups with hierarchical ordering (Variation → Option → Ingredient → Add-on)
- Selection constraints display (required, optional, choose exactly, choose up to, etc.)
- Dietary preferences and allergen information
- Currency conversion with inline exchange rate fetching
- Language switching with API data fetching and caching
- Three-dot menu for language/currency options
- Information source disclaimer (business + JourneyMate)
- Self-contained state management (doesn't affect FFAppState)

---

## Parameters

```dart
ItemDetailSheet({
  super.key,
  this.width,
  this.height,
  required this.itemData,
  required this.chosenCurrency,
  required this.originalCurrencyCode,
  required this.exchangeRate,
  required this.currentLanguage,
  required this.businessName,
  required this.translationsCache,
  this.formattedPrice,
  this.hasVariations,
  this.formattedVariationPrice,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (typically full screen) |
| `height` | `double?` | No | Container height (default: 90% screen height) |
| `itemData` | `dynamic` | **Yes** | Menu item data from API (menu_item_id, item_name, item_description, base_price, etc.) |
| `chosenCurrency` | `String` | **Yes** | User's selected currency (e.g., 'DKK', 'USD', 'GBP') |
| `originalCurrencyCode` | `String` | **Yes** | Restaurant's native currency |
| `exchangeRate` | `double` | **Yes** | Exchange rate from original to chosen currency |
| `currentLanguage` | `String` | **Yes** | User's app language code (e.g., 'en', 'da') |
| `businessName` | `String` | **Yes** | Restaurant name (for disclaimer text) |
| `translationsCache` | `dynamic` | **Yes** | App-level translation cache |
| `formattedPrice` | `String?` | No | Pre-formatted price string (not used internally) |
| `hasVariations` | `bool?` | No | Whether item has variation modifiers (for "From" prefix) |
| `formattedVariationPrice` | `String?` | No | Pre-formatted variation price (not used internally) |

---

## Dependencies

### pub.dev Packages
- `http: ^0.13.x` - For language/currency data fetching

### Internal Dependencies
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Custom Actions Used

| Action | Purpose | Line Reference |
|--------|---------|----------------|
| `markUserEngaged()` | Tracks user interaction | 516, 718, 834, 1667 |

### Custom Functions Used

| Function | Purpose |
|----------|---------|
| `getTranslations()` | Retrieves localized UI text |
| `getLocalizedCurrencyName()` | Gets currency display name |
| `getCurrencyFormattingRules()` | Gets currency symbol and formatting |
| `convertAndFormatPrice()` | Converts and formats prices |
| `convertDietaryPreferencesToString()` | Formats dietary tags |
| `convertAllergiesToString()` | Formats allergen list |

---

## FFAppState Usage

### Read Properties
None. Widget is completely self-contained.

### Write Properties
None. Widget does NOT modify FFAppState.

### State Isolation
This widget intentionally does NOT interact with FFAppState. All language and currency switching occurs within local state (`_currentlyDisplayedLanguage`, `_overrideCurrency`, `_overrideExchangeRate`) and does not propagate changes to the parent context.

---

## API Endpoints

### Language Switching
**Endpoint:** `https://wvb8ww.buildship.run/menuItem`
**Method:** GET
**Lines:** 669-676

**Query Parameters:**
- `menu_item_id` - The menu item ID
- `language_code` - Target language code (e.g., 'en', 'da', 'it')

**Response Format:**
```json
{
  "menu_item_id": 123,
  "item_name": "...",
  "item_description": "...",
  "base_price": 100.0,
  "item_modifier_groups": [...],
  "dietary_type_ids": [1, 2],
  "allergy_ids": [3, 4],
  "authentic_languages": ["da", "en"],
  "ui_translations": {
    "info_header_additional": "...",
    "info_header_dietary": "...",
    ...
  }
}
```

### Currency Conversion
**Endpoint:** `https://wvb8ww.buildship.run/getExchangeRates`
**Method:** GET
**Lines:** 731-737

**Query Parameters:**
- `from_currency` - Always 'DKK' (base currency)
- `to_currency` - Target currency code

**Response Format:**
```json
[
  {
    "rate": 0.146
  }
]
```

---

## State Management

### Local State Variables

| Variable | Type | Purpose | Initial Value |
|----------|------|---------|---------------|
| `_currentlyDisplayedLanguage` | `String` | Language code of displayed data | `widget.currentLanguage` |
| `_isLoadingLanguage` | `bool` | Loading state during switches | `false` |
| `_languageDataCache` | `Map<String, dynamic>` | Cached language data by code | `{currentLanguage: itemData}` |
| `_overrideCurrency` | `String?` | Local currency override | `null` |
| `_overrideExchangeRate` | `double?` | Local exchange rate override | `null` |

### Computed Properties

| Property | Formula | Purpose |
|----------|---------|---------|
| `_effectiveCurrency` | `_overrideCurrency ?? widget.chosenCurrency` | Active currency (local override priority) |
| `_effectiveExchangeRate` | `_overrideExchangeRate ?? widget.exchangeRate` | Active exchange rate (local override priority) |
| `_currentItemData` | `_languageDataCache[_currentlyDisplayedLanguage] ?? widget.itemData` | Active item data (cached or prop) |

---

## Lifecycle Events

### initState (lines 224-227)
```dart
@override
void initState() {
  super.initState();
  _initializeState();
}
```

**Actions:**
- Calls `_initializeState()` to set up language and currency state

### _initializeState (lines 240-250)
```dart
void _initializeState() {
  _currentlyDisplayedLanguage = widget.currentLanguage;
  _languageDataCache = {
    widget.currentLanguage: widget.itemData,
  };
  _isLoadingLanguage = false;

  _overrideCurrency = null;
  _overrideExchangeRate = null;
}
```

**Actions:**
- Sets initial language to app language
- Caches initial item data
- Resets loading state
- Clears currency overrides

### didUpdateWidget (lines 230-237)
```dart
@override
void didUpdateWidget(covariant ItemDetailSheet oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (_hasItemChanged(oldWidget)) {
    _initializeState();
  }
}
```

**Actions:**
- Detects item change (different `menu_item_id`)
- Resets all state if item changed
- Clears language cache and currency overrides

### dispose
Not explicitly overridden (uses default Flutter dispose)

---

## User Interactions

### onTap Close Button
**Trigger:** User taps X button in top-left corner
**Line:** 979 (via `_handleClose`)

**Actions:**
1. Marks user as engaged
2. Closes sheet with `Navigator.pop()`
3. Uses `rootNavigator: true` to ensure proper dismissal

---

### onTap Three-Dot Menu
**Trigger:** User taps menu button in top-right corner
**Line:** 1004 (via `_showActionMenu`)

**Actions:**
1. Marks user as engaged
2. Computes available menu options (language + currency)
3. Shows popup menu at top-right position
4. Returns selected option code (e.g., 'language:da', 'currency:USD')

**Menu Logic:**
- Combines language and currency options
- Separated by dividers
- Disabled during loading state

---

### onSelect Language
**Trigger:** User selects language from menu
**Line:** 640 (via `_handleLanguageSwitch`)

**Actions:**
1. **If cached:** Updates `_currentlyDisplayedLanguage` immediately
2. **If not cached:**
   - Shows loading overlay
   - Fetches data from `/menuItem` endpoint
   - Caches fetched data in `_languageDataCache`
   - Updates `_currentlyDisplayedLanguage`
   - Clears loading state
3. **On error:** Shows error snackbar

**Caching Strategy:**
- Data fetched once per language per item
- Persists until widget disposed
- Instant switching between cached languages

---

### onSelect Currency
**Trigger:** User selects currency from menu
**Line:** 642 (via `_handleCurrencySwitch`)

**Actions:**
1. **If DKK:** Sets override to DKK with rate 1.0 immediately
2. **If USD/GBP/Other:**
   - Shows loading state
   - Fetches exchange rate from API
   - Updates `_overrideCurrency` and `_overrideExchangeRate`
   - Clears loading state
3. **On error:** Shows error snackbar

**Self-Contained Conversion:**
- Does NOT update FFAppState
- All prices recalculated using `_effectiveCurrency` and `_effectiveExchangeRate`
- Modifier prices also updated

---

### onTap Information Source
**Trigger:** User taps "Information source" accordion header
**Line:** 1686 (via `_InformationSourceSection._toggleExpanded`)

**Actions:**
1. Marks user as engaged
2. Toggles `_isExpanded` state
3. Animates content reveal (100ms linear)

**Accordion Content:**
- Business disclaimer (mentions restaurant name)
- JourneyMate disclaimer

---

## Translation Keys

### UI Text Keys

| Key | Purpose | Example |
|-----|---------|---------|
| `info_header_additional` | Additional info section header | "Additional Information" |
| `info_header_dietary` | Dietary preferences label | "Dietary Preferences" |
| `info_header_allergens` | Allergens label | "Allergens" |
| `info_header_source` | Information source header | "Information source" |
| `info_disclaimer_business` | Business disclaimer text | "Information from [businessName]..." |
| `info_disclaimer_journeymate` | JourneyMate disclaimer | "JourneyMate does not guarantee..." |
| `price_per_person` | Per person suffix | "per person" |
| `price_from` | From prefix for variations | "From" |
| `menu_view_dish_in_param` | Language menu template | "View dish in {language}" |
| `menu_view_price_in_param` | Currency menu template | "View price in {currency}" |
| `lang_name_en` / `lang_name_da` / etc. | Language names | "English" / "Danish" |
| `modifier_required` | Required modifier label | "Required" |
| `modifier_optional` | Optional modifier label | "Optional" |
| `modifier_choose_exactly` | Exact selection constraint | "Choose exactly" |
| `modifier_choose_up_to` | Maximum selection constraint | "Choose up to" |
| `modifier_choose_at_least` | Minimum selection constraint | "Choose at least" |
| `modifier_choose_between` | Range selection constraint | "Choose between" |
| `modifier_type_variation` | Variation group label | "Variation" |
| `modifier_type_option` | Option group label | "Option" |
| `modifier_type_ingredient` | Ingredient group label | "Ingredient" |
| `modifier_type_addon` | Add-on group label | "Add-on" |

### Translation Sources
1. **API ui_translations** (preferred for switched languages)
2. **translationsCache** (fallback for app language)

---

## Menu Option Rules

### Language Options (lines 402-454)

**Rule 1: App Language = English**
- If displayed ≠ 'en': Offer return to English
- If displayed = 'en': Offer Danish
- No authentic language offers

**Rule 2: App Language = Danish**
- If displayed ≠ 'da': Offer return to Danish
- If displayed = 'da': Offer English
- No authentic language offers

**Rule 3: App Language = Other (e.g., Italian, German)**
- If displayed ≠ app language: Offer return to app language
- Offer up to 3 authentic languages (from item data)
- Excludes currently displayed language

**Rule 4: Viewing Non-App Language**
- Always offer return to app language (priority)
- Then apply rules 1-3 based on app language

---

### Currency Options (lines 456-508)

**Rule 1: User Chose USD**
- Offer DKK only

**Rule 2: User Chose GBP**
- Offer DKK only

**Rule 3: User Chose English + DKK**
- Offer USD and GBP

**Rule 4: Other Currencies**
- If not DKK: Offer DKK

---

## Modifier Groups

### Type Hierarchy (lines 780-785)
Modifier groups sorted by priority:

| Priority | Type | Purpose |
|----------|------|---------|
| 1 | Variation | Size/portion options (e.g., Small/Medium/Large) |
| 2 | Option | Choice alternatives (e.g., dressing type) |
| 3 | Ingredient | Ingredient swaps (e.g., remove onions) |
| 4 | Add-on | Extra items (e.g., extra cheese) |

### Selection Constraints

**Constraint Types:**

| Min | Max | Display Text |
|-----|-----|--------------|
| 1 | 1 | "Required • Choose exactly 1" |
| 2 | 2 | "Required • Choose exactly 2" |
| 1 | 3 | "Required • Choose between 1-3" |
| 1 | 0 | "Required • Choose at least 1" |
| 0 | 2 | "Optional • Choose up to 2" |
| 0 | 5 | "Optional • Choose up to 5" |
| 0 | 0 | "Optional" |

### Modifier Display (lines 1562-1615)

**Structure:**
```
Variation                     ← Group type (localized)
Required • Choose exactly 1   ← Constraints (if applicable)
Small                  20 kr. ← Modifier name + price
Medium                 25 kr.
Large                  30 kr.
```

**Price Display Rules:**
- Variation groups: Show price only (e.g., "20 kr.")
- Other groups: Show "+ price" (e.g., "+ 5 kr.")
- Zero prices: Hidden
- Uses effective currency/exchange rate

---

## Layout & Styling

### Dimensions

| Element | Size |
|---------|------|
| Default sheet height | 90% of screen height |
| Sheet border radius | 20px (top corners) |
| Image height | 200px |
| No-image header height | 64px |
| Swipe bar width | 80px |
| Swipe bar height | 4px |
| Close button size | 40px × 40px |
| Menu button size | 40px × 40px |
| Button border radius | 20px |
| Content horizontal padding | 28px |

### Typography

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Item name | 22px | 600 | Black |
| Base price | 16px | 500 | Orange (#E9874B) |
| Description | 16px | 300 | #2D3236 |
| Section header | 15px | 500 | Black |
| Modifier group header | 16px | 500 | Black |
| Modifier constraints | 14px | 400 | Black54 |
| Modifier item | 14px | 400 | Black87 |
| Modifier price | 14px | 400 | Orange (#E9874B) |
| Info label | 14px | 400 | Black |
| Info text | 14px | 300 | Black87 |

### Colors

| Element | Color |
|---------|-------|
| Sheet background | White |
| Swipe bar | #14181B (dark grey) |
| Close button background | #F2F3F5 (light grey) |
| Menu button background | #F2F3F5 (light grey) |
| Price badge background | Orange 10% opacity |
| Price text | #E9874B (orange) |
| Divider | #E0E0E0 (light grey) |
| Menu item background | #F2F3F5 (light grey) |

### Spacing

| Gap | Size |
|-----|------|
| Title to price | 2px |
| Price to description | 4px |
| Description to modifiers | 16px |
| Modifiers to divider | 24px |
| Divider to info | 20px |
| Info header spacing | 4px |
| Dietary to allergen | 12px |
| Allergen to source | 12px |
| Bottom padding | 30px |
| Modifier groups spacing | 12px |

---

## Data Extraction Helpers

### Safe Data Access (lines 333-383)

| Method | Return Type | Purpose |
|--------|-------------|---------|
| `_getStringValue(key, [default])` | `String` | Safely extracts string, returns default if missing |
| `_getBoolValue(key, [default])` | `bool` | Safely extracts boolean, returns default if missing |
| `_getListValue(key)` | `List<dynamic>` | Safely extracts list, returns empty if missing |
| `_getIntListValue(key)` | `List<int>` | Extracts integer list, filters non-integers |
| `_getAuthenticLanguages()` | `List<String>` | Gets authentic_languages array |

**Data Source:**
All methods read from `_currentItemData` (cached language data, not widget props).

---

## Price Formatting

### Zero Price Detection (lines 809-826)
Handles multiple currency formats:

**Patterns Detected:**
- `"0"` (plain zero)
- `"€ 0"`, `"$ 0.00"`, `"£ 0"` (prefix currencies)
- `"0 kr."`, `"0 zł"` (suffix currencies)

**Behavior:**
- Zero prices hidden from UI
- Applies to base price and modifier prices

### Currency Conversion (lines 1108-1135)

**Process:**
1. Extracts `base_price` from current item data
2. Calls `convertAndFormatPrice()` with:
   - Price amount
   - Original currency code
   - Effective exchange rate
   - Effective currency
3. Adds "From" prefix if `hasVariations = true`
4. Adds "per person" suffix if `is_price_per_person = true`

---

## Image Handling

### Image Loading (lines 914-936)

**Success Path:**
- Displays image at 200px height
- Uses `BoxFit.cover` (fill width, crop height)

**Error Path:**
- Shows grey background (`Colors.grey[200]`)
- Displays image icon placeholder (50px)

**No Image:**
- Skips image section
- Shows only 64px header with swipe bar

---

## Loading States

### Language Switch Loading (lines 858-877)

**Visual Overlay:**
- Full-sheet black overlay (30% opacity)
- White circular progress indicator
- Blocks all interaction

**Trigger:**
- Fetching language data from API
- Fetching exchange rate from API

**Duration:**
- Until API response received
- Until error occurs

---

## Error Handling

### Language Switch Error (lines 694-709)

**Trigger:**
- API request fails
- Invalid menu_item_id
- Network error

**Actions:**
1. Clears loading state
2. Shows red snackbar (3 seconds)
3. Message: "Could not load language: {error}"
4. Keeps current language displayed

### Currency Switch Error (lines 758-773)

**Trigger:**
- API request fails
- Invalid currency code
- Network error

**Actions:**
1. Clears loading state
2. Shows red snackbar (3 seconds)
3. Message: "Could not update currency"
4. Keeps current currency displayed

---

## Analytics Tracking

### Events Tracked
None directly. Parent widget should track:
- Sheet opened (item view)
- Language switched
- Currency switched
- Sheet closed

**Note:** Widget calls `markUserEngaged()` on interactions but does not fire analytics events directly.

---

## Information Source Section

### Accordion Behavior (lines 1634-1764)

**Header:**
- Text: Localized "Information source" key
- Icon: Down arrow (collapsed) / Up arrow (expanded)
- Tappable full width

**Expanded Content:**
- Business disclaimer: "Information from [businessName]..."
- JourneyMate disclaimer: "JourneyMate does not guarantee..."
- Animation: 100ms linear expand/collapse

**Styling:**
- Header: 14px, weight 400, black
- Content: 14px, weight 300, black87
- Spacing: 8px between paragraphs

---

## Sub-Components

### _ModifierGroupsDisplay (lines 1370-1616)

**Purpose:** Displays a single modifier group with all options

**Props:**
- `modifierGroup` - Group data (type, modifiers, constraints)
- `chosenCurrency` - Effective currency
- `originalCurrencyCode` - Restaurant currency
- `exchangeRate` - Effective exchange rate
- `uiTranslations` - API translations for switched language
- `translationsCache` - App-level translations
- `currentLanguage` - Displayed language code

**Structure:**
1. Group type header (e.g., "Variation")
2. Constraint text (e.g., "Required • Choose exactly 1")
3. Modifier list:
   - Name (+ description if present)
   - Price badge (if price > 0)

**Price Display:**
- Variation type: Show price only
- Other types: Show "+ price"

---

### _InformationSourceSection (lines 1634-1764)

**Purpose:** Collapsible disclaimer section

**Props:**
- `headerText` - Section header
- `disclaimerText` - Business disclaimer
- `journeymateText` - JourneyMate disclaimer

**State:**
- `_isExpanded` - Toggle state

**Animation:**
- Duration: 100ms
- Curve: Linear
- Uses `AnimatedAlign` with `heightFactor`

---

### _MenuOption (lines 1353-1363)

**Purpose:** Data class for menu items

**Fields:**
- `type` - 'language' or 'currency'
- `code` - Language code or currency code
- `displayName` - Human-readable name

---

### _SelectionConstraints (lines 1618-1628)

**Purpose:** Data class for modifier selection rules

**Fields:**
- `isRequired` - Whether selection is mandatory
- `minSelections` - Minimum items to select
- `maxSelections` - Maximum items to select

---

## Performance Considerations

### Language Data Caching
- Fetched once per language per item
- Stored in `_languageDataCache` map
- Instant switching between cached languages
- Cache cleared when item changes

### Exchange Rate Fetching
- Fetched on-demand when currency changed
- NOT cached (always fresh rate)
- DKK is instant (rate = 1.0)

### Image Loading
- Network image with error fallback
- No explicit caching strategy (relies on Flutter's network image cache)

### Rendering Optimization
- No explicit `mayLoad` performance flag
- All content rendered immediately
- Modifier groups built dynamically
- No pagination or lazy loading

---

## Usage Example

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => ItemDetailSheet(
    itemData: menuItem,
    chosenCurrency: FFAppState().chosenCurrency,
    originalCurrencyCode: restaurant['currency_code'],
    exchangeRate: FFAppState().exchangeRate,
    currentLanguage: FFAppState().currentLanguage,
    businessName: restaurant['business_name'],
    translationsCache: FFAppState().translationsCache,
    hasVariations: menuItem['has_variations'] ?? false,
  ),
);
```

---

## Known Limitations

1. **No State Persistence:** Language/currency changes lost when sheet closed
2. **No Analytics:** Does not track language/currency switches
3. **No Offline Support:** Requires network for language/currency fetching
4. **No Image Caching Control:** Relies on Flutter's default behavior
5. **No Variation Selection:** Display only (no add-to-cart functionality)
6. **Fixed Height:** 90% screen height, not dynamic based on content

---

## Related Widgets

| Widget | Relationship |
|--------|--------------|
| `MenuDishesListView` | Parent - triggers ItemDetailSheet on item tap |
| `FilterDescriptionSheet` | Sibling - similar bottom sheet pattern |
| `FullGalleryViewerWidget` | Sibling - similar modal presentation |

---

## Migration Notes

### From FlutterFlow
This widget is production-ready and directly exported from FlutterFlow. No migration needed.

### To v2 Design
When migrating to v2 design system:
1. Update color constants to match design tokens
2. Review spacing constants against design system
3. Update font weights to match v2 hierarchy
4. Consider extracting sheet pattern to shared component

---

## Testing Checklist

- [ ] Sheet opens to 90% height
- [ ] Image displays or shows fallback
- [ ] Close button dismisses sheet
- [ ] Menu button shows available options
- [ ] Language switch fetches and displays new data
- [ ] Currency switch updates all prices
- [ ] Modifier groups display in correct order
- [ ] Selection constraints show correctly
- [ ] Zero prices are hidden
- [ ] Dietary info displays correctly
- [ ] Allergen info displays correctly
- [ ] Information source expands/collapses
- [ ] Loading overlay shows during API calls
- [ ] Error snackbars show on API failure
- [ ] Price per person suffix displays
- [ ] "From" prefix shows for variations
- [ ] Menu dividers render between options
- [ ] Language options follow rules 1-4
- [ ] Currency options follow rules 1-4
- [ ] Authentic languages offered correctly
- [ ] Cache works for repeated language switches
- [ ] Exchange rates fetch for new currencies
- [ ] DKK currency switch is instant
- [ ] Sheet state resets when item changes
- [ ] Swipe bar displays at top

---

**Last Updated:** 2026-02-19
**FlutterFlow Export Version:** Current production version
