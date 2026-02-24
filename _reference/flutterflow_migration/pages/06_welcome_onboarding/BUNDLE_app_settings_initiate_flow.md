# App Settings Initiate Flow — Complete Bundle

**FlutterFlow Widget:** `AppSettingsInitiateFlowWidget`
**Route:** `AppSettingsInitiateFlow` (path: `setLanguageCurrency`)
**JSX File:** `welcome_language_currency_setup.jsx`
**Status:** ✅ Production Ready

---

## Purpose

Language and currency selection page for new users who tapped "Continue" without language set. Final step before entering main app. Required selections to ensure proper localization throughout app.

**Primary User Task:** Select preferred language and currency before completing onboarding.

---

## User Flow

```
WelcomePageWidget (new user, no language)
  │
  ├─ User taps "Continue" button
  │
  ├─ Navigate to → AppSettingsInitiateFlowWidget
  │
  ├─ Page loads (initState):
  │    ├─ Check location permission ('setLanguageCurrency')
  │    ├─ Detect accessibility settings
  │    └─ Record page start time
  │
  ├─ User views:
  │    ├─ App bar: "App setup"
  │    ├─ Section heading: "Localization"
  │    ├─ Section description
  │    ├─ Language selector (custom widget)
  │    ├─ Currency selector (custom widget)
  │    ├─ Exchange rate disclaimer
  │    └─ "Complete setup" button
  │
  ├─ User interactions:
  │    ├─ Language selector:
  │    │    ├─ Tap → LanguageSelectorButton expands/collapses
  │    │    ├─ Select language → Updates FFAppState().userLanguageCode
  │    │    └─ Auto-suggests currency based on language
  │    │
  │    └─ Currency selector:
  │         ├─ Tap → CurrencySelectorButton expands/collapses
  │         └─ Select currency → Updates FFAppState().userCurrencyCode
  │
  ├─ User taps "Complete setup":
  │    ├─ Call SearchAPI:
  │    │    └─ Parameters: selected language, user lat/lng, 50 businesses
  │    ├─ Store results: FFAppState().businesses = response data
  │    └─ Navigate to → SearchResults
  │
  └─ Page dispose → Track analytics (page_viewed with duration)
```

---

## Page Structure

### App Bar

**Configuration:**
- White background
- Automatic back button: NO (cannot go back from required setup)
- Title: Translation key `'opycnrvy'` ("App setup" / "App-opsætning")
- Center title: Yes
- Font: `titleLarge`, 400 weight

### Scrollable Content Area

**Layout:** SingleChildScrollView with padding (6px left/right)

**Elements (Top to Bottom):**

1. **Section Heading**
   - Text: Translation key `'0aq8qo7g'` ("Localization" / "Lokalisering")
   - Font: 22px, 700 weight (based on JSX)
   - Padding: 32px below divider

2. **Section Description**
   - Text: Translation key `'lup5v7ii'` ("Select your preferred language..." / "Vælg dit foretrukne sprog og...")
   - Font: 14px, 400 weight
   - Color: `#555` (secondary text)
   - Padding: 8px below heading

3. **Language Section**
   - Label: Translation key `'s3movlvc'` ("Language" / "Sprog")
   - Font: 16px, 600 weight
   - LanguageSelectorButton custom widget (90px height)

4. **Currency Section**
   - Label: Translation key `'elv468gp'` ("Currency" / "Valuta")
   - Font: 16px, 600 weight
   - CurrencySelectorButton custom widget (90px height)

5. **Exchange Rate Note**
   - Text: Translation key `'6kxja9sp'` ("Exchange rates are updated onc..." / "Valutakurser opdateres én gang...")
   - Font: 13px, 400 weight
   - Color: Tertiary text
   - Purpose: User expectation management

6. **Complete Setup Button**
   - Text: Translation key `'9nldb2d7'` ("Complete setup" / "Fuldfør opsætning")
   - Style: Primary filled button (orange)
   - Width: Full width
   - Height: 50px
   - Padding: 40px above button

---

## Translation Keys

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `'opycnrvy'` | App bar title | App setup | App-opsætning |
| `'0aq8qo7g'` | Section heading | Localization | Lokalisering |
| `'lup5v7ii'` | Section description | Select your preferred language... | Vælg dit foretrukne sprog og... |
| `'s3movlvc'` | Language label | Language | Sprog |
| `'elv468gp'` | Currency label | Currency | Valuta |
| `'6kxja9sp'` | Exchange rate note | Exchange rates are updated onc... | Valutakurser opdateres én gang... |
| `'9nldb2d7'` | Complete button | Complete setup | Fuldfør opsætning |

**Custom Widget Keys:**
- LanguageSelectorButton and CurrencySelectorButton have their own translation keys (shared with Language & Currency settings page, documented separately).

---

## Custom Widgets Used

### 1. LanguageSelectorButton
- **Location:** Custom widget (shared with Language & Currency settings page)
- **Purpose:** Language selection dropdown with flag emojis
- **Props:**
  - `currentLanguage`: `FFAppState().userLanguageCode`
  - `translationsCache`: `FFAppState().translationsCache`
  - `width`: `double.infinity`
  - `height`: `90.0`
- **Languages Supported:** 7 languages (en, da, de, sv, no, it, fr)
- **Selection:** Updates `FFAppState().userLanguageCode`
- **Auto-suggest:** Triggers currency suggestion based on language

### 2. CurrencySelectorButton
- **Location:** Custom widget (shared with Language & Currency settings page)
- **Purpose:** Currency selection dropdown with currency symbols
- **Props:**
  - `currentCurrency`: `FFAppState().userCurrencyCode`
  - `translationsCache`: `FFAppState().translationsCache`
  - `width`: `double.infinity`
  - `height`: `90.0`
- **Currencies Supported:** 3 currencies (USD, GBP, DKK)
- **Selection:** Updates `FFAppState().userCurrencyCode`

---

## Custom Actions Used

### 1. checkLocationPermission()
- **Called:** On page load (`initState`)
- **Purpose:** Check current location permission status
- **Parameters:** Page identifier (`'setLanguageCurrency'`)
- **Side Effects:** Updates `FFAppState().locationStatus`

### 2. detectAccessibilitySettings()
- **Called:** On page load (`initState`)
- **Purpose:** Detect system accessibility settings (font scale, high contrast)
- **Side Effects:** Updates `FFAppState().fontScale` and `FFAppState().highContrast`

### 3. trackAnalyticsEvent()
- **Called:** On page dispose
- **Purpose:** Track page view with duration
- **Parameters:**
  - Event name: `'page_viewed'`
  - Event data: `{ 'pageName': 'appSettingsInitiateFlow', 'durationSeconds': calculated }`

---

## API Calls

### SearchAPICall

**Triggered:** When user taps "Complete setup" button
**Purpose:** Preload restaurant data with selected language

**Input Parameters:**
- `language`: `FFAppState().userLanguageCode` (selected by user)
- `lat`: `FFAppState().userlatitude`
- `lng`: `FFAppState().userlongitude`
- `businessCountToReturn`: `50`

**Response Handling:**
```dart
_model.searchAPIResult = await SearchAPICall.call(
  language: FFAppState().userLanguageCode,
  lat: FFAppState().userlatitude,
  lng: FFAppState().userlongitude,
  businessCountToReturn: 50,
);

if ((_model.searchAPIResult?.succeeded ?? true)) {
  FFAppState().businesses = SearchAPICall.apiDataToModelList(
    (_model.searchAPIResult?.jsonBody ?? ''),
  ).toList().cast<BusinessesDataModelStruct>();

  context.pushNamed('SearchResults');
}
```

**Note:** Optimistic error handling (`?? true`) - proceeds even if API fails.

---

## FFAppState Usage

### Read
- `userLanguageCode` - Passed to LanguageSelectorButton, used in SearchAPI call
- `userCurrencyCode` - Passed to CurrencySelectorButton
- `translationsCache` - Passed to both selector widgets
- `userlatitude`, `userlongitude` - Used in SearchAPI call

### Write (via custom widgets)
- `userLanguageCode` - Updated by LanguageSelectorButton on language selection
- `userCurrencyCode` - Updated by CurrencySelectorButton on currency selection
- `exchangeRate` - Updated by CurrencySelectorButton when currency selected
- `businesses` - Populated with SearchAPI results on "Complete setup"
- `locationStatus` - Updated by `checkLocationPermission()`
- `fontScale`, `highContrast` - Updated by `detectAccessibilitySettings()`

---

## Model State Variables

### _model Fields

| Field | Type | Purpose |
|-------|------|---------|
| `pageStartTime` | DateTime | Records when page loaded (for analytics) |
| `searchAPIResult` | ApiCallResponse | Stores SearchAPI response |

---

## Lifecycle Events

### initState

**Sequence:**
1. Create model
2. Post-frame callback:
   - Check location permission: `await actions.checkLocationPermission('setLanguageCurrency')`
   - Detect accessibility: `await actions.detectAccessibilitySettings()`
   - Record page start time: `_model.pageStartTime = getCurrentTimestamp`

### dispose

**Sequence:**
1. Track analytics:
   ```dart
   await actions.trackAnalyticsEvent('page_viewed', {
     'pageName': 'appSettingsInitiateFlow',
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
- `pageName`: `'appSettingsInitiateFlow'`
- `durationSeconds`: Time spent on page

**Potential Enhancements:**
- Add `languageSelected: selectedLanguage`
- Add `currencySelected: selectedCurrency`
- Add `setupCompleted: true/false`

---

## Navigation

### Entry Points

**From:** WelcomePageWidget
**Method:** User taps "Continue" (new user, no language set)
**Route:** `Navigator.push(context, MaterialPageRoute(builder: (context) => AppSettingsInitiateFlowWidget()))`

### Exit Points

**Complete Setup Button:**
- Trigger: User taps button after selecting language and currency
- Actions:
  1. Call SearchAPI with selected language
  2. Store restaurant data in `FFAppState().businesses`
  3. Navigate to SearchResults
- Method: `context.pushNamed('SearchResults')`

**No Back Button:**
- User cannot go back to Welcome Page
- Setup is required to proceed

---

## Design Specifications

### Colors (from JSX)

- Background: `#fff` (white)
- Divider: `#f2f2f2` (subtle)
- Section heading: `#0f0f0f` (near-black)
- Description text: `#555` (grey)
- Labels: `#0f0f0f`
- Dropdown background: `#f5f5f5` (light grey)
- Button: `#e8751a` (ACCENT orange)
- Button text: `#fff` (white)

### Typography (from JSX)

- App bar title: 16px, 600 weight
- Section heading: 22px, 700 weight
- Description: 14px, 400 weight
- Labels: 16px, 600 weight
- Exchange rate note: 13px, 400 weight
- Button: 16px, 600 weight

### Spacing (from JSX)

- StatusBar → Divider: 0px
- Divider → Heading: 32px
- Heading → Description: 8px
- Description → Language: 16px
- Language → Currency: 16px
- Currency → Button: 40px
- Content padding: 24px horizontal

### Component Sizes (from JSX)

- Divider: 1px height
- Selector widgets: 90px height (FlutterFlow), 50px (JSX dropdowns)
- Button: 50px height
- Border radius: 12px

---

## Comparison with JSX Design

### Similarities

- Clean, focused setup flow
- Language + Currency selection
- Exchange rate disclaimer
- Single "Complete setup" button
- No skip option (required selections)

### Differences (FlutterFlow Advantages)

| Feature | JSX Design | FlutterFlow Implementation |
|---------|-----------|---------------------------|
| **Selector Widgets** | Static dropdowns (50px) | Custom widgets (90px) with richer UI ✓ |
| **Component Reuse** | Static implementation | Same widgets as Settings → Language & Currency ✓ |
| **Preloading** | None | Location permission + accessibility detection ✓ |
| **API Integration** | Not documented | SearchAPI preloads restaurant data ✓ |
| **Analytics** | None | Page view tracking with duration ✓ |
| **Navigation** | Static | Direct to SearchResults with preloaded data ✓ |

---

## Known Issues

### Issue 1: Optimistic API Error Handling

⚠️ **SearchAPI call assumes success:**
```dart
if ((_model.searchAPIResult?.succeeded ?? true)) {
  // Proceeds even if API failed
}
```

**Impact:** If API fails, user navigates to SearchResults with no data.

**Resolution:** Add proper error handling:
- Show error message to user
- Allow retry
- Don't navigate if API fails

---

## Testing Checklist

### Page Load
- [ ] Page loads correctly for new users
- [ ] App bar shows "App setup" title
- [ ] Section heading and description display
- [ ] Location permission checked on load
- [ ] Accessibility settings detected on load
- [ ] Page start time recorded

### Language Selection
- [ ] LanguageSelectorButton displays correctly
- [ ] Shows current language or default
- [ ] Tap expands/collapses selector
- [ ] All 7 languages available
- [ ] Selecting language updates `FFAppState().userLanguageCode`
- [ ] Language selection triggers currency suggestion

### Currency Selection
- [ ] CurrencySelectorButton displays correctly
- [ ] Shows current currency or default
- [ ] Tap expands/collapses selector
- [ ] All 3 currencies available
- [ ] Selecting currency updates `FFAppState().userCurrencyCode`
- [ ] Exchange rate fetched when currency selected

### Exchange Rate Note
- [ ] Disclaimer text displays correctly
- [ ] Translation shows correct text for language

### Complete Setup Button
- [ ] Button displays correctly
- [ ] Tapping button:
  - [ ] Calls SearchAPI with selected language
  - [ ] Uses correct lat/lng from user location
  - [ ] Requests 50 businesses
  - [ ] Stores results in `FFAppState().businesses`
  - [ ] Navigates to SearchResults

### Analytics
- [ ] page_viewed event tracked on dispose
- [ ] Duration calculated correctly
- [ ] Event data includes page name

---

## Migration Priority

⭐⭐⭐⭐⭐ **Critical** - Required onboarding step for new users choosing English

---

## Related Documentation

- **JSX Design:** `pages/06_welcome_onboarding/DESIGN_README_welcome_language_currency_setup.md`
- **Gap Analysis:** `pages/06_welcome_onboarding/GAP_ANALYSIS_app_settings_initiate_flow.md`
- **PAGE README:** `pages/06_welcome_onboarding/PAGE_README.md`
- **Related Page:** `BUNDLE_welcome_page.md` (previous step in flow)
- **Custom Widgets:**
  - LanguageSelectorButton (shared with Language & Currency settings)
  - CurrencySelectorButton (shared with Language & Currency settings)

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete documentation

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(localizationProvider)` | `currencyCode` | LanguageSelectorButton and CurrencySelectorButton display current values |
| `ref.watch(localizationProvider)` | `exchangeRate` | CurrencySelectorButton displays current exchange rate note |
| `ref.watch(translationsCacheProvider)` | `translationsCache` | Section headings and labels |
| `ref.watch(locationProvider)` | `hasPermission` | Stored by checkLocationPermission for search distance sorting |
| `ref.watch(accessibilityProvider)` | `fontScaleLarge` | Detect font scale on load |
| `ref.watch(accessibilityProvider)` | `isBoldTextEnabled` | Detect bold text on load |

### Writes
| Provider | Notifier method | Trigger |
|----------|----------------|---------|
| `ref.read(localizationProvider.notifier).setCurrency(...)` | `setCurrency` | LanguageSelectorButton selection → updateCurrencyForLanguage |
| `ref.read(localizationProvider.notifier).setExchangeRate(...)` | `setExchangeRate` | CurrencySelectorButton selection → updateCurrencyWithExchangeRate |
| `ref.read(translationsCacheProvider.notifier).setCache(...)` | `setCache` | LanguageSelectorButton selection → getTranslationsWithUpdate |
| `ref.read(locationProvider.notifier).setPermission(...)` | `setPermission` | checkLocationPermission called on page init |
| `ref.read(accessibilityProvider.notifier).setFontScale(...)` | `setFontScale` | detectAccessibilitySettings called on page init |
| `ref.read(accessibilityProvider.notifier).setBoldText(...)` | `setBoldText` | detectAccessibilitySettings called on page init |

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation |
