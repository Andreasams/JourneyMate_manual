# Welcome Page — Complete Bundle

**FlutterFlow Widget:** `WelcomePageWidget`
**Route:** `WelcomePage` (path: `welcomePage`)
**JSX Files:** `welcome_new_user.jsx`, `welcome_returning_user.jsx`
**Status:** ✅ Production Ready

---

## Purpose

Entry point for both new and returning users. Intelligently detects user type based on stored language preference and adapts UI accordingly. For new users, provides language selection. For returning users, provides quick continue button.

**Primary User Tasks:**
- **New User:** Choose to set up in English or Danish
- **Returning User:** Continue to app quickly

---

## User Flow

```
App Launch
  │
  ├─ WelcomePageWidget loads
  │
  ├─ initState checks: FFAppState().userLanguageCode set?
  │    ├─ YES → Returning user flow
  │    └─ NO → New user flow
  │
  ├─ Preloading (both flows):
  │    ├─ getTranslationsWithUpdate() - If language set
  │    ├─ checkLocationPermission('welcomepage')
  │    ├─ detectAccessibilitySettings()
  │    └─ Record page start time
  │
  ├─ NEW USER FLOW (_model.returningUser = false):
  │    │
  │    ├─ Shows TWO buttons:
  │    │    ├─ "Continue" (primary filled button)
  │    │    └─ "Fortsæt på dansk" (outlined button)
  │    │
  │    ├─ User taps "Continue":
  │    │    └─ Navigate to → AppSettingsInitiateFlow
  │    │
  │    └─ User taps "Fortsæt på dansk":
  │         ├─ Set language: FFAppState().userLanguageCode = 'da'
  │         ├─ Update currency: await actions.updateCurrencyForLanguage('da')
  │         ├─ Load translations: FFAppState().translationsCache = await actions.getTranslationsWithUpdate('da')
  │         ├─ Call SearchAPI:
  │         │    └─ Parameters: language='da', lat/lng, businessCountToReturn=50
  │         ├─ Store results: FFAppState().businesses = response data
  │         └─ Navigate to → SearchResults
  │
  └─ RETURNING USER FLOW (_model.returningUser = true):
       │
       ├─ Shows ONE button:
       │    └─ "Continue" (primary filled button)
       │
       └─ User taps "Continue":
            └─ Navigate to → SearchResults
```

---

## Page Structure

### Full-Screen Layout (No App Bar)

**Content:**
- Centered vertically and horizontally
- White background
- No navigation chrome

### Elements (Top to Bottom)

1. **Heading**
   - Text: Translation key `'6dww9uct'` ("Welcome to JourneyMate" / "Velkommen til JourneyMate")
   - Font: 28px, 700 weight (based on JSX)
   - Alignment: Center
   - Color: Near-black (`#0f0f0f`)

2. **Mascot Image** (if implemented in FlutterFlow)
   - Size: 180×180px (from JSX design)
   - Position: Below heading with 40px gap
   - Purpose: Brand personality and warmth

3. **Tagline**
   - Text: Translation key `'z6e1v2g7'` ("Go out, your way." / "Gå ud, på din måde.")
   - Font: 18px, 500 weight (based on JSX)
   - Alignment: Center
   - Gap: 40px above, 12px below

4. **Description**
   - Text: Translation key `'0eehrkgn'` ("Discover restaurants, cafés, a..." / "Opdag restauranter, caféer og...")
   - Font: 14px, 400 weight, 20px line-height
   - Alignment: Center
   - Gap: 48px below

5. **Button(s)** - Conditional based on user type

**New User (No Language Set):**
```dart
// Shows TWO buttons
Column(
  children: [
    FFButtonWidget(
      text: '${getTranslations('d2mrwxr4', cache)}', // "Continue"
      options: FFButtonOptions(
        // Primary filled button (orange)
        width: 270,
        height: 50,
        color: accent,
      ),
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppSettingsInitiateFlowWidget(),
          ),
        );
      },
    ),
    SizedBox(height: 12),
    FFButtonWidget(
      text: '${getTranslations('cuy6esxb', cache)}', // "Fortsæt på dansk"
      options: FFButtonOptions(
        // Secondary outlined button
        width: 270,
        height: 50,
        color: Colors.white,
        borderSide: BorderSide(color: primaryText),
      ),
      onPressed: () async {
        // Direct Danish onboarding path
        FFAppState().userLanguageCode = 'da';
        await actions.updateCurrencyForLanguage('da');
        FFAppState().translationsCache = await actions.getTranslationsWithUpdate('da');
        setState(() {});

        _model.searchAPIResult = await SearchAPICall.call(
          language: 'da',
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
      },
    ),
  ],
)
```

**Returning User (Has Language):**
```dart
// Shows ONE button
FFButtonWidget(
  text: '${getTranslations('d2mrwxr4', cache)}', // "Continue"
  options: FFButtonOptions(
    width: 270,
    height: 50,
    color: accent,
  ),
  onPressed: () async {
    context.pushNamed('SearchResults');
  },
)
```

---

## Translation Keys

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `'6dww9uct'` | Heading | Welcome to JourneyMate | Velkommen til JourneyMate |
| `'z6e1v2g7'` | Tagline | Go out, your way. | Gå ud, på din måde. |
| `'0eehrkgn'` | Description | Discover restaurants, cafés, a... | Opdag restauranter, caféer og... |
| `'d2mrwxr4'` | Primary button | Continue | Fortsæt |
| `'cuy6esxb'` | Secondary button | Fortsæt på dansk | Fortsæt på dansk |

**Button Visibility:**
- New user: Shows BOTH `'d2mrwxr4'` and `'cuy6esxb'`
- Returning user: Shows ONLY `'d2mrwxr4'`

---

## Custom Actions Used

### 1. getTranslationsWithUpdate()
- **Called:** On page load (if language set)
- **Purpose:** Load translations cache for current language
- **Parameters:** Language code (from `FFAppState().userLanguageCode`)
- **Returns:** Translations cache object
- **Stores:** In `FFAppState().translationsCache`

### 2. updateCurrencyForLanguage()
- **Called:** When user taps "Fortsæt på dansk" button
- **Purpose:** Set default currency for Danish (DKK)
- **Parameters:** Language code (`'da'`)
- **Side Effects:** Updates `FFAppState().userCurrencyCode`

### 3. checkLocationPermission()
- **Called:** On page load
- **Purpose:** Check current location permission status
- **Parameters:** Page identifier (`'welcomepage'`)
- **Side Effects:** Updates `FFAppState().locationStatus`

### 4. detectAccessibilitySettings()
- **Called:** On page load
- **Purpose:** Detect system accessibility settings (font scale, high contrast)
- **Side Effects:** Updates `FFAppState().fontScale` and `FFAppState().highContrast`

### 5. trackAnalyticsEvent()
- **Called:** On page dispose
- **Purpose:** Track page view with duration
- **Parameters:**
  - Event name: `'page_viewed'`
  - Event data: `{ 'pageName': 'homepage', 'durationSeconds': calculated }`

---

## API Calls

### SearchAPICall (Conditional)

**Triggered:** Only when user taps "Fortsæt på dansk" button
**Purpose:** Preload restaurant data with Danish locale

**Input Parameters:**
- `language`: `'da'` (hardcoded for Danish quick path)
- `lat`: `FFAppState().userlatitude`
- `lng`: `FFAppState().userlongitude`
- `businessCountToReturn`: `50`

**Response Handling:**
```dart
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
- `userLanguageCode` - Check if user has language set (determines new vs returning)
- `userlatitude`, `userlongitude` - Location for SearchAPI call
- `translationsCache` - For displaying translated text

### Write
- `userLanguageCode` - Set to `'da'` on "Fortsæt på dansk"
- `translationsCache` - Updated with Danish translations
- `userCurrencyCode` - Updated to `'DKK'` via `updateCurrencyForLanguage()`
- `businesses` - Populated with SearchAPI results
- `locationStatus` - Updated by `checkLocationPermission()`
- `fontScale`, `highContrast` - Updated by `detectAccessibilitySettings()`

---

## Model State Variables

### _model Fields

| Field | Type | Purpose |
|-------|------|---------|
| `returningUser` | bool | Determines if user has language set (true = returning user) |
| `pageStartTime` | DateTime | Records when page loaded (for analytics) |
| `searchAPIResult` | ApiCallResponse | Stores SearchAPI response (for Danish quick path) |

---

## Lifecycle Events

### initState

**Sequence:**
1. Create model
2. Detect user type:
   ```dart
   if (FFAppState().userLanguageCode != null &&
       FFAppState().userLanguageCode != '') {
     _model.returningUser = true;
   } else {
     _model.returningUser = false;
   }
   ```
3. Load translations if returning user:
   ```dart
   if (_model.returningUser) {
     FFAppState().translationsCache = await actions.getTranslationsWithUpdate(
       FFAppState().userLanguageCode
     );
   }
   ```
4. Check location permission: `await actions.checkLocationPermission('welcomepage')`
5. Detect accessibility: `await actions.detectAccessibilitySettings()`
6. Record page start time: `_model.pageStartTime = getCurrentTimestamp`

### dispose

**Sequence:**
1. Track analytics:
   ```dart
   await actions.trackAnalyticsEvent('page_viewed', {
     'pageName': 'homepage', // or 'welcomepage'
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
- `pageName`: `'homepage'` (note: inconsistency - sometimes `'welcomepage'`)
- `durationSeconds`: Time spent on page

**User Type Tracking:**
- Could add `userType: 'new'` or `'returning'` for better analytics
- Could add `actionTaken: 'english' | 'danish' | 'continue'` to track user choice

---

## Navigation Paths

### Entry Points

**From:** App launch
**Method:** Initial route
**Route:** `WelcomePage`

### Exit Points

**Three possible paths:**

1. **New User → English Setup**
   - Trigger: Tap "Continue" (no language set)
   - Destination: `AppSettingsInitiateFlow`
   - Method: `Navigator.push()`

2. **New User → Danish Direct**
   - Trigger: Tap "Fortsæt på dansk"
   - Actions: Set language='da', currency='DKK', load translations, call SearchAPI
   - Destination: `SearchResults`
   - Method: `context.pushNamed('SearchResults')`

3. **Returning User → Continue**
   - Trigger: Tap "Continue" (language already set)
   - Destination: `SearchResults`
   - Method: `context.pushNamed('SearchResults')`

---

## Design Specifications

### Colors (from JSX)

- Background: `#fff` (white)
- Heading: `#0f0f0f` (near-black)
- Tagline: `#0f0f0f`
- Description: `#555` (grey)
- Primary button: `#e8751a` (ACCENT orange) with white text
- Secondary button: White background with `#0f0f0f` border and text

### Typography (from JSX)

- Heading: 28px, 700 weight
- Tagline: 18px, 500 weight
- Description: 14px, 400 weight, 20px line-height
- Buttons: 16px, 600 weight

### Spacing (from JSX)

- Heading → Mascot: 40px
- Mascot → Tagline: 40px
- Tagline → Description: 12px
- Description → Buttons: 48px
- Between buttons: 12px

### Button Specs (from JSX)

- Width: 270px (full width with margin)
- Height: 50px
- Border radius: 12px
- Primary: Filled orange background
- Secondary: Outlined white background

---

## Comparison with JSX Design

### Similarities

- Centered layout
- Welcome message + tagline + description
- Two buttons for new users
- Clean, minimal design

### Differences (FlutterFlow Advantages)

| Feature | JSX Design | FlutterFlow Implementation |
|---------|-----------|---------------------------|
| **User Detection** | Separate static screens | Single page with intelligent conditional logic ✓ |
| **Returning Users** | Separate screen | Automatic one-button flow ✓ |
| **Danish Quick Path** | Not documented | One-tap → set language, fetch data, navigate ✓ |
| **Preloading** | None | Translations, location, accessibility ✓ |
| **Analytics** | None | Page view tracking with duration ✓ |
| **Internationalization** | Static text | Translation keys for all text ✓ |

---

## Known Issues

### Issue 1: Analytics Page Name Inconsistency

⚠️ **Inconsistent page name in analytics:**
- Sometimes uses `'homepage'`
- Sometimes uses `'welcomepage'`

**Resolution:** Standardize to `'welcomePage'` (matches route name).

### Issue 2: Optimistic API Error Handling

⚠️ **SearchAPI call assumes success:**
```dart
if ((_model.searchAPIResult?.succeeded ?? true)) {
  // Proceeds even if API failed
}
```

**Impact:** If API fails, user navigates to SearchResults with no data.

**Resolution:** Add proper error handling with user-facing error message.

---

## Testing Checklist

### New User Flow
- [ ] Page loads correctly for user with no language set
- [ ] Shows TWO buttons ("Continue" + "Fortsæt på dansk")
- [ ] "Continue" button navigates to AppSettingsInitiateFlow
- [ ] "Fortsæt på dansk" button:
  - [ ] Sets language to 'da'
  - [ ] Sets currency to 'DKK'
  - [ ] Loads Danish translations
  - [ ] Calls SearchAPI with Danish language
  - [ ] Stores restaurant data
  - [ ] Navigates to SearchResults

### Returning User Flow
- [ ] Page loads correctly for user with language set
- [ ] Shows ONE button ("Continue")
- [ ] Translations loaded on page load
- [ ] "Continue" button navigates directly to SearchResults

### Preloading
- [ ] Location permission checked on page load
- [ ] Accessibility settings detected on page load
- [ ] Page start time recorded

### Analytics
- [ ] page_viewed event tracked on dispose
- [ ] Duration calculated correctly

---

## Migration Priority

⭐⭐⭐⭐⭐ **Critical** - First user experience, entry point for app

---

## Related Documentation

- **JSX Designs:**
  - `pages/06_welcome_onboarding/DESIGN_README_welcome_new_user.md`
  - `pages/06_welcome_onboarding/DESIGN_README_welcome_returning_user.md`
- **Gap Analysis:** `pages/06_welcome_onboarding/GAP_ANALYSIS_welcome_page.md`
- **PAGE README:** `pages/06_welcome_onboarding/PAGE_README.md`
- **Related Page:** `BUNDLE_app_settings_initiate_flow.md` (next step for English setup)

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete documentation

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(localizationProvider)` | `currencyCode` | Detect returning user (`currencyCode != ''` → returning user branch) |
| `ref.watch(translationsCacheProvider)` | `translationsCache` | Translated button text for returning users |
| `ref.watch(locationProvider)` | `hasPermission` | Stored by checkLocationPermission for search distance sorting |
| `ref.watch(accessibilityProvider)` | `fontScaleLarge` | Detect font scale on load |
| `ref.watch(accessibilityProvider)` | `isBoldTextEnabled` | Detect bold text on load |

### Writes
| Provider | Notifier method | Trigger |
|----------|----------------|---------|
| `ref.read(translationsCacheProvider.notifier).setCache(...)` | `setCache` | "Fortsæt på dansk" tapped → getTranslationsWithUpdate called for `da` |
| `ref.read(localizationProvider.notifier).setCurrency(...)` | `setCurrency` | "Fortsæt på dansk" tapped → updateCurrencyForLanguage sets DKK |
| `ref.read(locationProvider.notifier).setPermission(...)` | `setPermission` | checkLocationPermission called on page init |
| `ref.read(accessibilityProvider.notifier).setFontScale(...)` | `setFontScale` | detectAccessibilitySettings called on page init |
| `ref.read(accessibilityProvider.notifier).setBoldText(...)` | `setBoldText` | detectAccessibilitySettings called on page init |

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_returningUser` | `bool` | `false` = show two language buttons, `true` = show one "Continue" button |
| `_pageStartTime` | `DateTime` | Analytics duration calculation |
