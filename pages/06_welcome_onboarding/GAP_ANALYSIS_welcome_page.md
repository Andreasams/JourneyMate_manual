# Welcome Page — Gap Analysis

**Purpose:** Identify functional differences between JSX v2 design and FlutterFlow implementation

**Methodology:** Compare DESIGN_README_welcome_new_user.md + DESIGN_README_welcome_returning_user.md (JSX v2) with FlutterFlow WelcomePageWidget source code

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

## Documentation Sources

**FlutterFlow Implementation:**
- ✅ Source code provided by user: `WelcomePageWidget` (complete)
- ✅ Translation keys extracted (5 keys total)
- ✅ Complex conditional logic for new vs returning users
- ✅ Analytics events documented

**JSX Design:**
- ✅ Complete DESIGN_README_welcome_new_user.md (~26,000 bytes)
- ✅ Complete DESIGN_README_welcome_returning_user.md (~27,000 bytes)
- ✅ Full visual specifications and component details

**Gap Analysis Status:** Complete with actual FlutterFlow source code.

---

## CRITICAL OBSERVATION: Intelligent User Detection Flow

### FlutterFlow Implementation: Smart Conditional Logic (Verified)

**File:** `lib/onboarding/welcome_page/welcome_page_widget.dart`
**Purpose:** Entry point that intelligently routes new vs returning users

**User Detection Logic:**
```dart
// On initState
if (FFAppState().userLanguageCode != null && FFAppState().userLanguageCode != '') {
  _model.returningUser = true;  // User has language set = returning
} else {
  _model.returningUser = false;  // No language = new user
}

// Also loads translations and checks location permission on page load
```

**State-Dependent UI:**

**New User (No Language Set):**
- Shows TWO buttons:
  1. "Continue" (primary filled button) → navigates to `AppSettingsInitiateFlow`
  2. "Fortsæt på dansk" (outlined button) → sets language='da', currency='DKK', loads Danish translations, navigates to `SearchResults`

**Returning User (Has Language):**
- Shows ONE button:
  - "Continue" (primary filled button) → navigates directly to `SearchResults`

**Translation Keys Used (5 keys total):**

| Key | Context | English Comment | Danish Translation |
|-----|---------|-----------------|---------------------|
| `'6dww9uct'` | Heading | Welcome to JourneyMate | Velkommen til JourneyMate |
| `'z6e1v2g7'` | Tagline | Go out, your way. | Gå ud, på din måde. |
| `'0eehrkgn'` | Description | Discover restaurants, cafés, a... | Opdag restauranter, caféer og... |
| `'d2mrwxr4'` | Button (primary) | Continue | Fortsæt |
| `'cuy6esxb'` | Button (secondary) | Fortsæt på dansk | Fortsæt på dansk |

**Custom Actions Used:**
1. `getTranslationsWithUpdate()` - On page load, loads translations if language set
2. `updateCurrencyForLanguage('da')` - When "Fortsæt på dansk" tapped
3. `checkLocationPermission('welcomepage')` - On page load
4. `detectAccessibilitySettings()` - On page load
5. `trackAnalyticsEvent('page_viewed')` - On dispose with duration

**API Calls:**
1. **SearchAPICall** - Called on "Fortsæt på dansk" tap with parameters:
   - `language: 'da'`
   - `lat: FFAppState().userlatitude`
   - `lng: FFAppState().userlongitude`
   - `businessCountToReturn: 50`
   - Response stored in `FFAppState().businesses`

**Analytics Events:**
- Event name: `page_viewed`
- Event data:
  - `pageName`: `'homepage'` (also called `'welcomepage'` in some events)
  - `durationSeconds`: Calculated from `pageStartTime`

**Navigation Logic:**

**New User (No Language) - "Continue" Button:**
```dart
await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => AppSettingsInitiateFlowWidget()),
);
```

**New User - "Fortsæt på dansk" Button:**
```dart
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
```

**Returning User (Has Language) - "Continue" Button:**
```dart
context.pushNamed('SearchResults');
```

**Code Reference:** FlutterFlow source code provided by user

---

## JSX Design Overview

### New User Design (DESIGN_README_welcome_new_user.md)

**Purpose:** First-time user introduction with language selection

**Visual Structure:**
- Centered content layout (no header/navigation)
- Vertical hierarchy:
  1. "Welcome to JourneyMate" heading (28px, bold)
  2. Mascot image (180×180px) ← **Visual element**
  3. "Go out, your way." tagline (18px, medium)
  4. Description text (14px, 4 lines)
  5. TWO buttons:
     - "Continue" (filled orange, primary)
     - "Fortsæt på dansk" (outlined, secondary)

**Design Philosophy:**
- Minimalist, centered, welcoming
- Mascot provides personality and warmth
- Language-first approach (immediate choice)
- Clear hierarchy with generous spacing

### Returning User Design (DESIGN_README_welcome_returning_user.md)

**Purpose:** Quick re-entry for users who have used app before

**Visual Structure:**
- Similar to new user but with contextual differences
- ONE button instead of two:
  - "Continue" → proceeds directly to search

**Design Philosophy:**
- Faster flow for returning users
- Recognizes user's existing preferences
- Reduces friction on subsequent visits

---

## Detailed Gap Analysis

### Gap C.1: Welcome Page Translation Keys

**JSX v2 Design:**
- Heading: "Welcome to JourneyMate"
- Tagline: "Go out, your way."
- Description: "Discover restaurants, cafés, and bars filtered by your lifestyle, preferences, and dietary needs."
- Button 1: "Continue"
- Button 2: "Fortsæt på dansk"
- Code reference: `DESIGN_README_welcome_new_user.md` lines 55-87

**FlutterFlow Implementation (Verified from Source Code):**

The FlutterFlow implementation uses **5 translation keys**:

| Key | Context | English Comment | Danish Translation |
|-----|---------|-----------------|------------------------|
| `'6dww9uct'` | Heading | Welcome to JourneyMate | Velkommen til JourneyMate |
| `'z6e1v2g7'` | Tagline | Go out, your way. | Gå ud, på din måde. |
| `'0eehrkgn'` | Description | Discover restaurants, cafés, a... | Opdag restauranter, caféer og... |
| `'d2mrwxr4'` | Button (primary) | Continue | Fortsæt |
| `'cuy6esxb'` | Button (secondary) | Fortsæt på dansk | Fortsæt på dansk |

**Button Visibility Logic:**
- New user (`!_model.returningUser`): Shows BOTH buttons
- Returning user (`_model.returningUser`): Shows ONLY primary "Continue" button

**No Gap:** All translation keys are already in FlutterFlow. Need to add to MASTER_TRANSLATION_KEYS.md for consistency.

---

## FlutterFlow Features NOT in JSX Design

### 1. Intelligent User Detection

**Feature:** Automatic detection of new vs returning users based on stored language preference

**Implementation:**
- Checks `FFAppState().userLanguageCode` on page load
- Sets `_model.returningUser` boolean
- Conditionally renders one or two buttons

**Design Rationale:**
- Reduces friction for returning users
- No need for separate screens (JSX shows two separate designs)
- Single page handles both user types

**Not in JSX:** JSX shows two separate static designs

### 2. Direct Danish Onboarding Path

**Feature:** "Fortsæt på dansk" button that:
- Sets language to Danish
- Sets currency to DKK
- Loads Danish translations
- Fetches restaurant data
- Navigates directly to search results
- **Skips** the `AppSettingsInitiateFlow` page entirely

**Design Rationale:**
- One-tap onboarding for Danish users
- Reduces steps in onboarding flow
- Assumes smart defaults (DKK for Danish)

**Not in JSX:** JSX shows static button, doesn't document this advanced flow

### 3. Preloading on Page Load

**Feature:** Multiple actions triggered on `initState`:
- `getTranslationsWithUpdate()` - Loads translations if language set
- `checkLocationPermission('welcomepage')` - Checks location status
- `detectAccessibilitySettings()` - Detects font scale/contrast

**Design Rationale:**
- Prepares app state before user interaction
- Smoother experience when transitioning to next screen
- No loading spinners after button tap

**Not in JSX:** JSX is static design, doesn't document initialization logic

### 4. Analytics Tracking

**Feature:** Page view analytics with duration tracking

**Implementation:**
- Records `pageStartTime` on initState
- Tracks `page_viewed` event on dispose
- Event data: `pageName: 'homepage'`, `durationSeconds`

**Not in JSX:** JSX doesn't document analytics

---

## Architecture Summary

### Frontend Logic (A1) - 0 gaps

All conditional logic implemented correctly:
- User detection based on stored language
- Conditional button rendering
- Three different navigation paths
- Preloading on page load

### Backend Logic (A2) - 0 gaps

No backend processing required. All logic is frontend state management and API calls.

### API Changes (B) - 0 gaps

SearchAPI already exists and is called correctly with proper parameters.

### Translation Keys (C) - 1 gap

- 5 translation keys already exist in FlutterFlow
- Need to add to MASTER_TRANSLATION_KEYS.md for consistency
- All English and Danish translations verified

### Known Missing (D) - 0 gaps

No features explicitly marked as "not in current scope" by user.

---

## Migration Notes

### High Priority Items

1. **Verify Translation Keys in MASTER_TRANSLATION_KEYS.md**
   - Add 5 welcome page keys
   - Include English and Danish translations
   - Mark as "already in FlutterFlow"

2. **Document Custom Actions**
   - `getTranslationsWithUpdate()` - Loads translations
   - `checkLocationPermission()` - Checks location status
   - `detectAccessibilitySettings()` - Detects accessibility settings

### Medium Priority Items

1. **Document FFAppState Variables**
   - `userLanguageCode` - Stores selected language
   - `userCurrencyCode` - Stores selected currency
   - `translationsCache` - Stores loaded translations
   - `businesses` - Stores search results
   - `userlatitude`, `userlongitude` - Location coordinates

2. **Document SearchAPI Integration**
   - Endpoint details
   - Input parameters
   - Response structure
   - Error handling

### Low Priority Items

1. **Mascot Image** - JSX shows 180×180px mascot image, verify if FlutterFlow uses it

---

## Known Issues

### Issue 1: Page Name Inconsistency

⚠️ **Analytics event page name inconsistency:**
- Some events use `'homepage'`
- Some events use `'welcomepage'`
- **Solution:** Standardize to one name (likely `'welcomePage'` to match route name)

**Code Reference:** WelcomePageWidget analytics tracking

---

## Next Steps

1. **Add translation keys to MASTER_TRANSLATION_KEYS.md**
   - 5 keys from Welcome Page
   - Include English and Danish translations
   - Mark as "already in FlutterFlow"

2. **Update/create BUNDLE.md**
   - Full widget specification
   - User flows diagram
   - Navigation paths
   - API integration details

3. **Update PAGE_README.md**
   - Expand with verified details from source code
   - Document all custom actions used
   - Document FFAppState variables

4. **Verify Mascot Image**
   - Check if FlutterFlow implementation includes mascot
   - If not, add to design implementation task

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete
**Total Gaps:** 1 (0 frontend + 0 backend + 0 API + 1 translation + 0 known missing)

**Key Finding:** FlutterFlow implementation is **MORE sophisticated** than JSX design:
- **JSX Design:** Two separate static screens (new user + returning user)
- **FlutterFlow:** Single intelligent page with conditional logic and three navigation paths
- **Translation Keys:** 5 keys covering all UI text
- **Custom Actions:** 4 actions for preloading and state management
- **Analytics:** Page view tracking with duration
- **Direct Danish Path:** One-tap onboarding for Danish users (skips settings flow)

**Key Decision:** Preserve FlutterFlow's intelligent single-page approach. JSX's two separate designs are less efficient than the dynamic implementation.

---

## Appendix: JSX Design Features (For Reference)

### Visual Design Elements

**Layout:**
- 390 × 844px canvas (iPhone standard)
- Centered content with 32px horizontal padding
- Vertical centering of all elements

**Typography:**
- Heading: 28px, 700 weight (Welcome to JourneyMate)
- Tagline: 18px, 500 weight (Go out, your way.)
- Description: 14px, 400 weight, 20px line height
- Button: 16px, 600 weight

**Colors:**
- Primary text: `#0f0f0f` (heading, tagline)
- Secondary text: `#555` (description)
- Primary CTA: `#e8751a` (ACCENT orange)
- Secondary CTA: `#0f0f0f` border with white background
- Button text: White (primary), `#0f0f0f` (secondary)

**Mascot Image:**
- Size: 180×180px
- Position: Between heading and tagline
- Purpose: Personality and warmth
- Note: Verify if FlutterFlow uses this

**Spacing:**
- Heading → Mascot: 40px gap
- Mascot → Tagline: 40px gap
- Tagline → Description: 12px gap
- Description → Buttons: 48px gap
- Between buttons: 12px gap

**Buttons:**
- Primary: Full width, 50px height, 12px border radius, orange background
- Secondary: Full width, 50px height, 12px border radius, white background with dark border

**Design Reference:** `DESIGN_README_welcome_new_user.md` full specification
