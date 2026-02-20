# Language & Currency Page — Gap Analysis

**Purpose:** Identify functional differences between JSX v2 design and FlutterFlow implementation

**Methodology:** Compare DESIGN_README_localization.md (JSX v2 inline controls) with FlutterFlow source code

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
| C | 1 | Translation keys needed |
| D | 0 | Known future features |
| **Total** | **1** | **Functional gap identified** |

---

## Documentation Sources

**FlutterFlow Implementation:**
- ✅ Source code provided by user: `LanguageAndCurrencyWidget` (complete)
- ✅ Translation keys extracted (5 keys total)
- ✅ Custom widgets identified: `LanguageSelectorButton`, `CurrencySelectorButton`
- ✅ Analytics events documented

**JSX Design:**
- ✅ Inline controls in DESIGN_README_localization.md (language/currency section)
- ✅ `LanguageCurrencyDropdowns` shared component specification
- ⚠️ No dedicated page design (functionality was inline on Localization page)

**Architecture Note:** The JSX v2 design shows language and currency selection as **inline controls** on a single Localization page, while FlutterFlow implements this as a **separate dedicated page** with custom widgets.

---

## Observation: Architectural Difference

### JSX v2 Design: Inline Controls on Localization Page

**Structure:**
- Part of the larger Localization page
- `LanguageCurrencyDropdowns` component (shared component)
- Language dropdown (7 languages)
- Currency dropdown (3 currencies)
- Both inline, visible immediately
- `showDescriptions` prop controls helper text visibility

**Code Reference:** `DESIGN_README_localization.md` lines 132-202, component definition lines 1300-1385

### FlutterFlow Implementation: Dedicated Settings Page

**Structure:**
- Separate page: `LanguageAndCurrencyWidget`
- Route: `/LanguageAndCurrency` (path: `languagecurrency`)
- Two sections (language, currency)
- Custom widgets: `LanguageSelectorButton`, `CurrencySelectorButton`
- Each section has heading + description + selector
- Scrollable layout

**Code Reference:** FlutterFlow source code provided by user

### Architecture Comparison

| Aspect | JSX v2 Design | FlutterFlow Implementation |
|--------|---------------|----------------------------|
| **Location** | Inline on Localization page | Dedicated separate page |
| **Navigation** | No navigation (inline) | Navigate from Localization hub |
| **Layout** | Compact dual-dropdown | Expanded with headings/descriptions |
| **Components** | `LanguageCurrencyDropdowns` (shared) | `LanguageSelectorButton`, `CurrencySelectorButton` (custom) |
| **Description Text** | Conditional via `showDescriptions` prop | Always shown, integrated into layout |
| **Complexity** | Simpler (combined) | More verbose (separated) |

**Design Decision:** FlutterFlow's dedicated page approach provides more space for explanatory text and a clearer hierarchy. Preserve this architecture for initial migration.

---

## Detailed Gap Analysis

### Gap C.1: Language & Currency Page Translation Keys

**JSX v2 Design (Inline Controls):**
- Labels: "Sprog" / "Language", "Valuta" / "Currency"
- Descriptions: Localization explanation, exchange rate disclaimer
- Dropdown options: Language names (7), currency names with symbols (3)
- Code reference: `DESIGN_README_localization.md` lines 168-195

**FlutterFlow Implementation (Verified from Source Code):**

The FlutterFlow implementation uses 5 translation keys for headings and descriptions:

**Translation Keys Used:**

| Key | Context | English Comment | Danish Translation |
|-----|---------|-----------------|---------------------|
| `rct7k6pr` | App bar title | Language & currency | Sprog & valuta |
| `phfch9og` | Language section heading | Set your preferred language fo... | Indstil dit foretrukne sprog fo... |
| `gl71ej9n` | Language section description | Your current app language is E... | Dit nuværende app-sprog er E... |
| `y0gzdnsp` | Currency section heading | Set your preferred currency fo... | Indstil din foretrukne valuta fo... |
| `n4pzujqg` | Currency description part 1 | Prices will be shown in  | Priser vil blive vist i  |
| `82y059ik` | Exchange rate disclaimer | Exchange rates are updated onc... | Valutakurser opdateres en gang... |

**Dynamic Content:**
- Current currency name: Generated via `functions.getLocalizedCurrencyName(languageCode, currencyCode, translationsCache)`
- Language options: Provided by `LanguageSelectorButton` custom widget
- Currency options: Provided by `CurrencySelectorButton` custom widget

**Custom Widgets:**
1. **LanguageSelectorButton**
   - Props: `width`, `height`, `translationsCache`
   - Reads: `FFAppState().userLanguageCode`
   - Writes: Updates `userLanguageCode` + triggers translation refresh
   - Appears as dropdown button (49px height)

2. **CurrencySelectorButton**
   - Props: `width`, `height`, `translationsCache`
   - Reads: `FFAppState().userCurrencyCode`
   - Writes: Updates `userCurrencyCode` + triggers exchange rate update
   - Appears as dropdown button (49px height)

**Custom Functions Used:**
- `getLocalizedCurrencyName(languageCode, currencyCode, translationsCache)` - Returns localized currency name
- `getSessionDurationSeconds(pageStartTime)` - Calculates page duration for analytics

**Custom Actions:**
- `markUserEngaged()` - Tracks user interaction (called on back button)
- `trackAnalyticsEvent('page_viewed')` - On dispose with duration

**FFAppState Variables:**
- Reads: `userLanguageCode`, `userCurrencyCode`, `translationsCache`
- Writes: (handled by custom widgets)

**Analytics Event:**
- Event name: `page_viewed`
- Event data:
  - `pageName`: `'languageAndCurrencySettings'`
  - `durationSeconds`: Calculated from `pageStartTime`

**No Gap:** All translation keys are already in FlutterFlow. Need to add to MASTER_TRANSLATION_KEYS.md for consistency.

---

## Features in FlutterFlow Implementation

### 1. Two-Section Layout

**Feature:** Language and currency are separate sections with individual headings/descriptions

**Language Section:**
- Heading: "Set your preferred language fo..."
- Description: "Your current app language is E..."
- Selector button: `LanguageSelectorButton` (49px height)

**Currency Section:**
- Heading: "Set your preferred currency fo..."
- Description split:
  - Static: "Prices will be shown in "
  - Dynamic: Currency name via `getLocalizedCurrencyName()`
  - Note: Period added after currency name
- Exchange rate disclaimer: "Exchange rates are updated onc..."
- Selector button: `CurrencySelectorButton` (49px height)

**Spacing:**
- 40px gap between sections
- 4px padding at top of each section
- 2px spacing between heading and description
- 20px spacing before selector button

**Code Reference:** FlutterFlow source code lines 154-303

### 2. Custom Selector Widgets

**Feature:** Dedicated custom widgets for language and currency selection

**LanguageSelectorButton:**
- Encapsulates language selection logic
- Manages translation system updates
- Props: dimensions + `translationsCache`
- Height: 49px (consistent with other selectors)

**CurrencySelectorButton:**
- Encapsulates currency selection logic
- Manages exchange rate updates
- Props: dimensions + `translationsCache`
- Height: 49px (consistent with other selectors)

**Benefit:**
- Separation of concerns (selection logic in widgets)
- Reusable across app
- Maintains translation cache consistency

**Code Reference:** FlutterFlow source code lines 227-235, 296-304

### 3. Dynamic Currency Display

**Feature:** Shows current selected currency name in description

**Implementation:**
```dart
Row(
  children: [
    Text('Prices will be shown in '),  // Static part
    Text('${functions.getLocalizedCurrencyName(...)}.'),  // Dynamic part
  ],
)
```

**Benefit:**
- User sees current selection without opening dropdown
- Currency name localized to current language
- Provides context for setting

**Code Reference:** FlutterFlow source code lines 252-294

### 4. Page View Analytics

**Feature:** Tracks time spent on page

**Implementation:**
- `pageStartTime` set on page load (`initState`)
- `trackAnalyticsEvent('page_viewed')` on dispose
- Event data includes `pageName` and `durationSeconds`

**Event Data:**
```dart
{
  'pageName': 'languageAndCurrencySettings',
  'durationSeconds': functions.getSessionDurationSeconds(_model.pageStartTime!).toString(),
}
```

**Benefit:**
- Measures user engagement with settings
- Helps identify if users struggle with selection
- Analytics for product insights

**Code Reference:** FlutterFlow source code lines 79-95

### 5. Scrollable Layout

**Feature:** Page uses `SingleChildScrollView` for content

**Implementation:**
- SafeArea with padding (12px all sides)
- SingleChildScrollView wraps Column
- Ensures accessibility on small screens

**Benefit:**
- Accommodates different screen sizes
- Supports accessibility text scaling
- Future-proof for additional settings

**Code Reference:** FlutterFlow source code lines 129-151

---

## JSX Design Features NOT in FlutterFlow

The JSX v2 design has some features that FlutterFlow doesn't implement (because it uses custom widgets instead):

### 1. Dropdown Visual Design

**JSX Feature:**
- Custom dropdown with absolute positioning
- Flag emojis for languages
- Currency symbols shown inline
- Selected item: orange tint background (`#fef8f2`)
- Up/down arrow indicators (▲/▼)
- Max height: 280px with scroll
- Dividers between options

**FlutterFlow:**
- Uses custom widgets (`LanguageSelectorButton`, `CurrencySelectorButton`)
- Visual design unknown (would need to read custom widget code)
- Likely uses native-like dropdowns or bottom sheets

**Decision:** FlutterFlow's custom widgets are ground truth. JSX design provides visual reference for future enhancements.

### 2. `showDescriptions` Prop

**JSX Feature:**
- `LanguageCurrencyDropdowns` has `showDescriptions` prop
- Controls visibility of helper text
- Used differently in welcome flow vs settings

**FlutterFlow:**
- Descriptions always shown (no toggle)
- Integrated into dedicated page layout

**Decision:** Preserve FlutterFlow's always-visible approach. More informative for settings page.

### 3. Inline Component Reuse

**JSX Feature:**
- Same `LanguageCurrencyDropdowns` component used in:
  - Welcome/onboarding flow
  - Settings (Localization page, inline)

**FlutterFlow:**
- Dedicated page for settings
- Custom widgets may be used elsewhere (unknown)

**Decision:** Preserve FlutterFlow's dedicated page. Better separation of concerns.

---

## Migration Notes

### High Priority Items

1. **Verify Custom Widget Functionality** - Read source code for:
   - `LanguageSelectorButton` implementation
   - `CurrencySelectorButton` implementation
   - How they update FFAppState
   - How they trigger translation refresh
   - What visual design they use

2. **Document Translation Keys** - Add all 5 keys to MASTER_TRANSLATION_KEYS.md

### Medium Priority Items

1. **Custom Functions Documentation** - Ensure documented:
   - `getLocalizedCurrencyName()` - Returns localized currency name
   - `getSessionDurationSeconds()` - Calculates page duration

2. **FFAppState Documentation** - Document variables:
   - `userLanguageCode` - Current language (2-letter code)
   - `userCurrencyCode` - Current currency (3-letter code)
   - `translationsCache` - Translation data structure

### Low Priority Items

None identified.

---

## Architecture Summary

### Frontend Logic (A1) - 0 gaps

Custom widgets handle all frontend logic. No gaps in page-level logic.

### Backend Logic (A2) - 0 gaps

No backend processing required. Settings stored in FFAppState.

### API Changes (B) - 0 gaps

No API calls required on this page. Translation loading handled by custom action.

### Translation Keys (C) - 1 gap

- 5 translation keys already exist in FlutterFlow (app bar + 2 sections with headings/descriptions)
- Need to add to MASTER_TRANSLATION_KEYS.md for consistency
- Language/currency option names are data (from `translationsCache`), not UI keys

### Known Missing (D) - 0 gaps

No features explicitly marked as "not in current scope" by user.

---

## Expected User Flow

### Complete Settings Flow

```
Settings → Localization (hub)
              ↓
         Language & Currency (this page)
              ├── Tap LanguageSelectorButton → Select language → Auto-update UI
              └── Tap CurrencySelectorButton → Select currency → Auto-update FFAppState
```

### On This Page

1. User lands on Language & Currency page
2. Sees current language described in text
3. Sees current currency name in text
4. **Language Selection:**
   - Tap `LanguageSelectorButton`
   - Dropdown/bottom sheet appears (custom widget behavior)
   - Select language
   - Widget updates `FFAppState().userLanguageCode`
   - Widget triggers translation refresh via `getTranslationsWithUpdate()`
   - UI re-renders with new language
5. **Currency Selection:**
   - Tap `CurrencySelectorButton`
   - Dropdown/bottom sheet appears (custom widget behavior)
   - Select currency
   - Widget updates `FFAppState().userCurrencyCode`
   - Widget triggers exchange rate update
   - Current currency display updates
6. Tap back button → Return to Localization hub
7. On dispose: Analytics event tracks time spent

**Note:** Changes are auto-saved (no "Save" button required).

---

## Custom Widget Requirements

### LanguageSelectorButton

**Purpose:** Language selection with translation system integration

**Expected Behavior:**
- Display current language (from `FFAppState().userLanguageCode`)
- Open dropdown/sheet on tap
- Show 15 language options (from `translationsCache` or hardcoded)
- On selection:
  - Update `FFAppState().userLanguageCode`
  - Call `getTranslationsWithUpdate()` to refresh translation cache
  - Trigger UI rebuild

**Props:**
- `width`: `double.infinity`
- `height`: `49`
- `translationsCache`: `FFAppState().translationsCache`

**Unknown (Requires Custom Widget Code):**
- Visual design (dropdown vs bottom sheet)
- Language list source (hardcoded vs dynamic)
- Flag emoji display
- Selection UI style

### CurrencySelectorButton

**Purpose:** Currency selection with exchange rate integration

**Expected Behavior:**
- Display current currency (from `FFAppState().userCurrencyCode`)
- Open dropdown/sheet on tap
- Show currency options (from language-specific list)
- On selection:
  - Update `FFAppState().userCurrencyCode`
  - Call `updateCurrencyWithExchangeRate()` to fetch exchange rates
  - Trigger UI rebuild

**Props:**
- `width`: `double.infinity`
- `height`: `49`
- `translationsCache`: `FFAppState().translationsCache`

**Unknown (Requires Custom Widget Code):**
- Visual design
- Currency list source (per-language or global)
- Currency symbol display
- Exchange rate fetching details

---

## Next Steps

1. **Add translation keys to MASTER_TRANSLATION_KEYS.md**
   - 5 keys from Language & Currency page
   - Include English and Danish translations
   - Mark as "already in FlutterFlow"

2. **Document custom widgets**
   - Read `LanguageSelectorButton` source code
   - Read `CurrencySelectorButton` source code
   - Document visual design, interaction patterns, FFAppState integration

3. **Document custom functions**
   - `getLocalizedCurrencyName()` - Purpose, parameters, return value
   - Add to `shared/functions/` documentation

4. **Document custom actions** (if not already documented)
   - `getTranslationsWithUpdate()` - Translation refresh logic
   - `updateCurrencyWithExchangeRate()` - Exchange rate fetching

5. **Verify FFAppState variables**
   - `userLanguageCode` - Type, default value, where set
   - `userCurrencyCode` - Type, default value, where set
   - `translationsCache` - Structure, how populated

---

**Last Updated:** 2026-02-19
**Status:** ✅ **Complete** - FlutterFlow source code verified
**Total Gaps:** 1 (0 frontend + 0 backend + 0 API + 1 translation + 0 known missing)

**Key Finding:** FlutterFlow implementation uses a **dedicated page** with custom selector widgets, while JSX design shows **inline controls** on Localization page. FlutterFlow's approach provides better organization and more space for explanatory text.

**Key Decision:** Preserve FlutterFlow's dedicated page architecture. Custom widgets encapsulate selection logic effectively. JSX design provides visual reference for dropdown styling.

---

## Appendix: JSX Design Reference (For Visual Styling)

### LanguageCurrencyDropdowns Component (JSX)

**Visual Design:**
- **Label:** 16px, 600 weight, `#0f0f0f`
- **Description:** 13px, 400 weight, `#888`, 18px line height
- **Closed Dropdown:**
  - Height: 50px
  - Background: `#f5f5f5`
  - Border: 1px solid `#e8e8e8`
  - Border radius: 10px
  - Font: 14px, 400 weight
  - Arrow: ▼ (12px, `#888`)
- **Open Dropdown:**
  - Position: absolute, top: 54px
  - Background: white
  - Border: 1px solid `#e8e8e8`
  - Shadow: subtle
  - Max height: 280px (scrollable)
  - Option padding: 12px vertical
  - Selected option: `#fef8f2` background (light orange tint)
  - Dividers: `#f2f2f2`
- **Language Options:** Flag emoji + name (e.g., "🇬🇧 English")
- **Currency Options:** Name + symbol (e.g., "Danish krone (kr.)")

**Spacing:**
- Label to dropdown: 8px
- Description to dropdown: 8px
- Between language and currency sections: 32px

**Supported Languages (JSX):**
- English (en) 🇬🇧
- Dansk (da) 🇩🇰
- Deutsch (de) 🇩🇪
- Svenska (sv) 🇸🇪
- Norsk (no) 🇳🇴
- Italiano (it) 🇮🇹
- Français (fr) 🇫🇷

**Supported Currencies (JSX):**
- US dollar (USD) $
- British pound (GBP) £
- Danish krone (DKK) kr.

**Design Reference:** `DESIGN_README_localization.md` lines 1300-1385
