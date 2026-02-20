# Language & Currency Settings — Complete Bundle

**FlutterFlow Widget:** `LanguageAndCurrencyWidget`
**Route:** `LanguageAndCurrency` (path: `languageCurrency`)
**Status:** ✅ Production Ready

---

## Purpose

Settings page for selecting app language and currency preferences. Allows users to change localization settings after initial onboarding. Auto-suggests default currency based on selected language.

**Primary User Tasks:**
- Change interface language
- Change currency for price display
- Understand when exchange rates update

---

## User Flow

```
Settings → Localization → Language & currency
  │
  ├─ Page loads (initState):
  │    ├─ Check location permission ('languagecurrency')
  │    └─ Record page start time
  │
  ├─ User views:
  │    ├─ App bar: "Settings"
  │    ├─ Language section:
  │    │    ├─ Heading: "Language"
  │    │    ├─ Description: "Select your preferred language..."
  │    │    └─ LanguageSelectorButton (current language)
  │    │
  │    └─ Currency section:
  │         ├─ Heading: "Currency"
  │         ├─ Description: "We can display prices..."
  │         ├─ CurrencySelectorButton (current currency)
  │         └─ Exchange rate note: "Exchange rates are updated once per 24 hours..."
  │
  ├─ User interactions:
  │    ├─ Back button:
  │    │    └─ Mark engagement, navigate back
  │    │
  │    ├─ Language selector:
  │    │    ├─ Tap → LanguageSelectorButton expands
  │    │    ├─ Select language:
  │    │    │    ├─ Updates FFAppState().userLanguageCode
  │    │    │    ├─ Triggers updateCurrencyForLanguage() (auto-suggest)
  │    │    │    └─ Reloads translations
  │    │    └─ Collapses selector
  │    │
  │    └─ Currency selector:
  │         ├─ Tap → CurrencySelectorButton expands
  │         ├─ Select currency:
  │         │    ├─ Updates FFAppState().userCurrencyCode
  │         │    └─ Fetches latest exchange rate
  │         └─ Collapses selector
  │
  └─ Page dispose → Track analytics (page_viewed with duration)
```

---

## Page Structure

### App Bar

**Configuration:**
- White background
- Back button (left): iOS style arrow
- Title: Translation key `'rct7k6pr'` ("Settings" / "Indstillinger")
- Center title: Yes

**Back Button Action:**
- `await actions.markUserEngaged()`
- `context.safePop()`

### Scrollable Content Area

**Layout:** SingleChildScrollView with padding (12px left/right)

**Elements (Top to Bottom):**

1. **Language Section**
   - Heading: Translation key `'phfch9og'` ("Language" / "Sprog")
     - Font: 20px, 600 weight
     - Padding: 16px top, 8px bottom
   - Description: Translation key `'gl71ej9n'` ("Select your preferred language..." / "Vælg dit foretrukne sprog...")
     - Font: 14px, 400 weight
     - Color: Secondary text
     - Padding: 4px bottom
   - LanguageSelectorButton custom widget
     - Width: `double.infinity`
     - Height: 90px

2. **Currency Section**
   - Heading: Translation key `'y0gzdnsp'` ("Currency" / "Valuta")
     - Font: 20px, 600 weight
     - Padding: 16px top, 8px bottom
   - Description (Part 1): Translation key `'n4pzujqg'` ("We can display prices..." / "Vi kan vise priser...")
     - Font: 14px, 400 weight
     - Color: Secondary text
     - Padding: 4px bottom
   - CurrencySelectorButton custom widget
     - Width: `double.infinity`
     - Height: 90px
   - Exchange Rate Note: Translation key `'82y059ik'` ("Exchange rates are updated onc..." / "Valutakurser opdateres én gang...")
     - Font: 12px, 400 weight
     - Color: Tertiary text
     - Padding: 12px top

---

## Translation Keys

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `'rct7k6pr'` | App bar title | Settings | Indstillinger |
| `'phfch9og'` | Language section heading | Language | Sprog |
| `'gl71ej9n'` | Language description | Select your preferred language... | Vælg dit foretrukne sprog... |
| `'y0gzdnsp'` | Currency section heading | Currency | Valuta |
| `'n4pzujqg'` | Currency description | We can display prices... | Vi kan vise priser... |
| `'82y059ik'` | Exchange rate note | Exchange rates are updated onc... | Valutakurser opdateres én gang... |

**Custom Widget Keys:**
- LanguageSelectorButton and CurrencySelectorButton have their own internal translation keys for:
  - Language names (English, Danish, German, etc.)
  - Currency names (US Dollar, Danish Krone, British Pound)
  - Dropdown labels
  - Selection indicators
  - etc.

---

## Custom Widgets Used

### 1. LanguageSelectorButton
- **Location:** Custom widget (shared with App Settings Initiate Flow)
- **Purpose:** Language selection dropdown with flag emojis and translated names
- **Props:**
  - `currentLanguage`: `FFAppState().userLanguageCode`
  - `translationsCache`: `FFAppState().translationsCache`
  - `width`: `double.infinity`
  - `height`: `90.0`
- **Languages Supported:** 7 languages
  - English (🇬🇧 en)
  - Danish (🇩🇰 da)
  - German (🇩🇪 de)
  - Swedish (🇸🇪 sv)
  - Norwegian (🇳🇴 no)
  - Italian (🇮🇹 it)
  - French (🇫🇷 fr)
- **On Selection:**
  - Updates `FFAppState().userLanguageCode`
  - Triggers `updateCurrencyForLanguage()` (auto-suggest currency)
  - Reloads translations via `getTranslationsWithUpdate()`
- **Documentation:** See App Settings Initiate Flow BUNDLE

### 2. CurrencySelectorButton
- **Location:** Custom widget (shared with App Settings Initiate Flow)
- **Purpose:** Currency selection dropdown with currency symbols and names
- **Props:**
  - `currentCurrency`: `FFAppState().userCurrencyCode`
  - `translationsCache`: `FFAppState().translationsCache`
  - `width`: `double.infinity`
  - `height`: `90.0`
- **Currencies Supported:** 3 currencies
  - US Dollar ($ USD)
  - Danish Krone (kr. DKK)
  - British Pound (£ GBP)
- **On Selection:**
  - Updates `FFAppState().userCurrencyCode`
  - Fetches latest exchange rate via `updateCurrencyWithExchangeRate()`
- **Documentation:** See App Settings Initiate Flow BUNDLE

---

## Custom Actions Used

### 1. updateCurrencyForLanguage()
- **Called:** When user selects a new language (triggered by LanguageSelectorButton)
- **Purpose:** Auto-suggest default currency based on language
- **Parameters:** Language code (e.g., 'da', 'en', 'de')
- **Logic (Expected):**
  - Danish (da) → Danish Krone (DKK)
  - German (de) → Euro (EUR) or suggest based on region
  - English (en) → US Dollar (USD) or British Pound (GBP)
  - Swedish (sv) → Swedish Krona (SEK)
  - Norwegian (no) → Norwegian Krone (NOK)
  - etc.
- **Side Effects:** Updates `FFAppState().userCurrencyCode`

### 2. updateCurrencyWithExchangeRate()
- **Called:** When user selects a new currency (triggered by CurrencySelectorButton)
- **Purpose:** Fetch latest exchange rate for selected currency
- **Parameters:** Currency code (e.g., 'DKK', 'USD', 'GBP')
- **Side Effects:** Updates `FFAppState().exchangeRate` with conversion rate

### 3. getTranslationsWithUpdate()
- **Called:** When user changes language
- **Purpose:** Reload translations cache for new language
- **Parameters:** Language code
- **Returns:** Translations cache object
- **Side Effects:** Updates `FFAppState().translationsCache`

### 4. checkLocationPermission()
- **Called:** On page load (`initState`)
- **Purpose:** Check current location permission status
- **Parameters:** Page identifier (`'languagecurrency'`)
- **Side Effects:** Updates `FFAppState().locationStatus`

### 5. markUserEngaged()
- **Called:** On back button tap
- **Purpose:** Track user engagement
- **Parameters:** None

### 6. trackAnalyticsEvent()
- **Called:** On page dispose
- **Purpose:** Track page view with duration
- **Parameters:**
  - Event name: `'page_viewed'`
  - Event data: `{ 'pageName': 'languageAndCurrency', 'durationSeconds': calculated }`

---

## FFAppState Usage

### Read
- `userLanguageCode` - Displayed in LanguageSelectorButton
- `userCurrencyCode` - Displayed in CurrencySelectorButton
- `translationsCache` - Passed to both selector widgets
- `exchangeRate` - May be displayed or used (not visible in page code)

### Write (via custom widgets and actions)
- `userLanguageCode` - Updated by LanguageSelectorButton
- `userCurrencyCode` - Updated by CurrencySelectorButton and `updateCurrencyForLanguage()`
- `exchangeRate` - Updated by `updateCurrencyWithExchangeRate()`
- `translationsCache` - Updated by `getTranslationsWithUpdate()`
- `locationStatus` - Updated by `checkLocationPermission()`

---

## Model State Variables

### _model Fields

| Field | Type | Purpose |
|-------|------|---------|
| `pageStartTime` | DateTime | Records when page loaded (for analytics) |

**Note:** Minimal state on page itself. Custom widgets manage their own internal state (expansion, selection, etc.).

---

## Lifecycle Events

### initState

**Sequence:**
1. Create model
2. Post-frame callback:
   - Check location permission: `await actions.checkLocationPermission('languagecurrency')`
   - Record page start time: `_model.pageStartTime = getCurrentTimestamp`

### dispose

**Sequence:**
1. Track analytics:
   ```dart
   await actions.trackAnalyticsEvent('page_viewed', {
     'pageName': 'languageAndCurrency',
     'durationSeconds': calculated,
   });
   ```
2. Dispose model: `_model.dispose()`
3. Call super: `super.dispose()`

---

## Analytics Events

### page_viewed

**Triggered:** On page dispose
**Event Data:**
- `pageName`: `'languageAndCurrency'`
- `durationSeconds`: Time spent on page

**Potential Enhancements:**
- Add `languageChanged: true/false`
- Add `currencyChanged: true/false`
- Add `oldLanguage` and `newLanguage`
- Add `oldCurrency` and `newCurrency`

---

## Navigation

### Entry Points

**From:** Settings → Localization hub
**Method:** User taps "Language & currency" row
**Route:** `context.pushNamed('LanguageAndCurrency')`

### Exit Points

**Back Button:**
- Action: `await actions.markUserEngaged()` → `context.safePop()`
- Returns to Localization hub

---

## Design Specifications

### Colors

- Background: `primaryBackground` (white)
- App bar background: White
- Text primary: `primaryText` (near-black)
- Text secondary: Secondary text color (grey)
- Text tertiary: Tertiary text color (light grey)

### Typography

- App bar title: 16px, 400 weight, center
- Section headings: 20px, 600 weight
- Descriptions: 14px, 400 weight
- Exchange rate note: 12px, 400 weight

### Spacing

- Section padding: 16px top, 8px below heading
- Description padding: 4px bottom
- Exchange rate note: 12px top
- Content padding: 12px horizontal

### Selector Widget Sizes

- Height: 90px
- Width: Full width (`double.infinity`)
- Border radius: Defined in custom widget
- Background: Defined in custom widget

---

## Comparison with JSX Design

**JSX Design Note:** The JSX design shows language and currency selection as part of a larger "Localization" page with inline controls and location sharing settings all on one page.

**FlutterFlow Implementation:** Uses a multi-page architecture with a navigation hub. This page is one of the child pages accessed from the Localization hub.

### Architectural Difference

| Aspect | JSX Design | FlutterFlow Implementation |
|--------|-----------|---------------------------|
| **Structure** | Single page with inline controls | Dedicated page accessed from hub |
| **Navigation** | One level deep | Two levels deep (hub → sub-page) |
| **Complexity** | Higher (all controls on one page) | Lower (focused single-purpose page) |

**Decision:** FlutterFlow's approach provides better:
- Code organization (separation of concerns)
- Testability (each page can be tested independently)
- Maintainability (changes to one setting don't affect others)

### Component Reuse

**Shared with App Settings Initiate Flow:**
- LanguageSelectorButton (same widget)
- CurrencySelectorButton (same widget)
- Translation keys for exchange rate note

**Benefit:** Consistent behavior and appearance across onboarding and settings.

---

## Known Issues

None identified. Implementation is clean and functional.

---

## Testing Checklist

### Page Load
- [ ] Page loads correctly
- [ ] App bar shows "Settings" title
- [ ] Back button present and functional
- [ ] Language section displays with current language
- [ ] Currency section displays with current currency
- [ ] Exchange rate note displays
- [ ] Location permission checked on load
- [ ] Page start time recorded

### Language Selection
- [ ] LanguageSelectorButton displays current language correctly
- [ ] Tapping selector expands dropdown
- [ ] All 7 languages available
- [ ] Selecting new language:
  - [ ] Updates `FFAppState().userLanguageCode`
  - [ ] Triggers `updateCurrencyForLanguage()` (auto-suggest)
  - [ ] Reloads translations cache
  - [ ] UI updates to show new language text
  - [ ] Currency may auto-update based on language

### Currency Selection
- [ ] CurrencySelectorButton displays current currency correctly
- [ ] Tapping selector expands dropdown
- [ ] All 3 currencies available
- [ ] Selecting new currency:
  - [ ] Updates `FFAppState().userCurrencyCode`
  - [ ] Fetches latest exchange rate
  - [ ] UI updates to show new currency

### Navigation
- [ ] Back button marks engagement
- [ ] Back button returns to Localization hub

### Analytics
- [ ] page_viewed event tracked on dispose
- [ ] Duration calculated correctly

---

## Migration Priority

⭐⭐⭐⭐ **High** - Essential settings page for changing localization after onboarding

---

## Related Documentation

- **Gap Analysis:** `pages/07_settings/GAP_ANALYSIS_language_currency.md`
- **PAGE README:** `pages/07_settings/PAGE_README.md` (expand section)
- **FlutterFlow Source:** User provided complete source code
- **Related Pages:**
  - Localization hub (parent)
  - Location Sharing (sibling page)
  - App Settings Initiate Flow (uses same widgets)
- **Custom Widgets:**
  - LanguageSelectorButton (shared widget)
  - CurrencySelectorButton (shared widget)

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete documentation

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(localizationProvider)` | `currencyCode` | LanguageSelectorButton and CurrencySelectorButton display current selections |
| `ref.watch(localizationProvider)` | `exchangeRate` | Exchange rate note displayed below CurrencySelectorButton |
| `ref.watch(translationsCacheProvider)` | `translationsCache` | Section headings + labels |
| `ref.watch(locationProvider)` | `hasPermission` | Checked on page load (not displayed but stored for search) |

### Writes
| Provider | Notifier method | Trigger |
|----------|----------------|---------|
| `ref.read(localizationProvider.notifier).setCurrency(...)` | `setCurrency` | LanguageSelectorButton selection → updateCurrencyForLanguage (auto-suggest) |
| `ref.read(localizationProvider.notifier).setExchangeRate(...)` | `setExchangeRate` | CurrencySelectorButton selection → updateCurrencyWithExchangeRate |
| `ref.read(translationsCacheProvider.notifier).setCache(...)` | `setCache` | LanguageSelectorButton selection → getTranslationsWithUpdate |
| `ref.read(locationProvider.notifier).setPermission(...)` | `setPermission` | checkLocationPermission on page load |

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation on dispose |
