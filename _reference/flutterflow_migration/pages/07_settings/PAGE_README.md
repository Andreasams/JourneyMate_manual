# Settings Pages - Functional Specification

**Routes:** `/Account`, `/LanguageAndCurrency`, `/LocationSharing`, `/MissingPlace`, `/ContactUs`, `/ShareFeedback`, `/PrivacyPolicy`
**FlutterFlow Source:** `lib/app_settings/account/account_widget.dart`
**Status:** ✅ Production Ready
**Last Updated:** 2026-02-19

---

## Purpose

Settings hub for language/currency changes, location permissions, feedback forms, and privacy policy access.

**Primary User Task:** Access app settings, submit feedback, and view legal information.

---

## Account Page (Settings Hub) - Main Implementation

### Page Structure

**Widget Type:** StatefulWidget
**Route Name:** `Account`
**Route Path:** `account`

**Layout:**
```
SafeArea
├── Stack
│   ├── Padding (main scrollable content)
│   │   └── Column
│   │       ├── Page Title: "Settings & account"
│   │       ├── Section 1: My JourneyMate
│   │       │   └── Localization
│   │       ├── Section 2: Reach out
│   │       │   ├── Are we missing a place?
│   │       │   ├── Share feedback
│   │       │   └── Contact us
│   │       └── Section 3: Resources
│   │           ├── Terms of use (external)
│   │           └── Privacy policy (external)
│   └── Align (bottom)
│       └── NavBarWidget
```

---

## Navigation Map (Ground Truth from FlutterFlow)

### Internal Navigation (4 routes)

| Row Label | Translation Key | Target Route | Target Widget | Line in FF Source |
|-----------|----------------|--------------|---------------|-------------------|
| Localization | `290fbi5g` | `LocalizationWidget.routeName` | `lib/app_settings/localization/localization_widget.dart` | 153 |
| Are we missing a place? | `297ogtn9` | `MissingPlaceWidget.routeName` | `lib/app_settings/missing_place/missing_place_widget.dart` | 263 |
| Share feedback | `uz83tnpj` | `ShareFeedbackWidget.routeName` | `lib/app_settings/share_feedback/share_feedback_widget.dart` | 339 |
| Contact us | `dme8eg1t` | `ContactUsWidget.routeName` | `lib/app_settings/contact_us/contact_us_widget.dart` | 415 |

**Navigation Method:**
```dart
await actions.markUserEngaged();
context.pushNamed(TargetWidget.routeName);
```

### External URLs (2 routes)

| Row Label | Translation Key | URL | Line in FF Source |
|-----------|----------------|-----|-------------------|
| Terms of use | `2v106a6z` | `https://docs.google.com/document/d/1CAjvjWt73BgvBZSMUKiIyPbz2sZ5RiqCMGuD0R6KVpc/edit?usp=sharing` | 527-528 |
| Privacy policy | `gtmo283r` | `https://docs.google.com/document/d/1nO_TaK-HB8-CV9FM8zs3uu0mYgCT4taO0nBSv2iHw3A/edit?usp=sharing` | 602-603 |

**Navigation Method:**
```dart
await actions.markUserEngaged();
await launchURL('https://...');
```

⚠️ **Note:** Both open in external browser. No in-app web view.

---

## Translation Keys (All 10 Keys from FFLocalizations)

| Key | English Text | Context | Line in FF Source |
|-----|--------------|---------|-------------------|
| `cpiiq0im` | Settings & account | Page title | 91 |
| `3tlbn2an` | My JourneyMate | Section header 1 | 116 |
| `290fbi5g` | Localization | Setting row 1 | 171 |
| `pb7qrt34` | Reach out | Section header 2 | 221 |
| `297ogtn9` | Are we missing a place? | Setting row 2 | 281 |
| `uz83tnpj` | Share feedback | Setting row 3 | 357 |
| `dme8eg1t` | Contact us | Setting row 4 | 433 |
| `d952v5y4` | Resources | Section header 3 | 487 |
| `2v106a6z` | Terms of use | Setting row 5 | 546 |
| `gtmo283r` | Privacy policy | Setting row 6 | 621 |

**Translation System:**
```dart
FFLocalizations.of(context).getText('key')
```

**Supported Languages:** 7 (en, da, de, es, fr, it, sv)

---

## Custom Actions Used (Account Page Only)

### 1. markUserEngaged()

**Purpose:** Track user engagement on every interaction
**When Called:** On every setting row tap (6 total)
**Lines in FF Source:** 150, 260, 336, 411, 526, 601
**Documentation:** `shared/actions/MASTER_README_mark_user_engaged.md`

**Implementation Pattern:**
```dart
onTap: () async {
  await actions.markUserEngaged();
  context.pushNamed(TargetWidget.routeName);
}
```

### 2. trackAnalyticsEvent()

**Purpose:** Track page view duration
**When Called:** Page dispose (user leaves settings)
**Lines in FF Source:** 49-57
**Documentation:** `shared/actions/MASTER_README_track_analytics_event.md`

**Event Name:** `page_viewed`

**Event Data:**
```dart
{
  'pageName': 'settingsAndAccount',
  'durationSeconds': functions.getSessionDurationSeconds(_model.pageStartTime!).toString(),
}
```

**Implementation:**
```dart
@override
void dispose() {
  () async {
    await actions.trackAnalyticsEvent(
      'page_viewed',
      <String, String>{
        'pageName': 'settingsAndAccount',
        'durationSeconds': functions.getSessionDurationSeconds(_model.pageStartTime!).toString(),
      },
    );
  }();

  _model.dispose();
  super.dispose();
}
```

---

## Custom Functions Used

### getSessionDurationSeconds()

**Purpose:** Calculate seconds between page load and dispose
**Input:** `_model.pageStartTime` (DateTime)
**Output:** Duration as int (seconds)
**Documentation:** `shared/functions/MASTER_README_get_session_duration_seconds.md`

**Usage:**
```dart
functions.getSessionDurationSeconds(_model.pageStartTime!).toString()
```

---

## Custom Widgets Used

### NavBarWidget

**Purpose:** Bottom tab navigation bar
**Location:** `widgets/nav_bar/nav_bar_widget.dart`
**Lines in FF Source:** 672-678
**Documentation:** `shared/widgets/MASTER_README_nav_bar_widget.md`

**Props:**
- `pageIsSearchResults`: `false` (not search page)

**Implementation:**
```dart
wrapWithModel(
  model: _model.navBarModel,
  updateCallback: () => safeSetState(() {}),
  child: NavBarWidget(
    pageIsSearchResults: false,
  ),
)
```

---

## FFAppState Usage (Account Page Only)

### Read

**None.** The main settings hub is stateless.

### Write

**None.** The main settings hub is stateless.

### Notes

- **Stateless Navigation:** Settings hub only provides navigation links
- **No Preferences Displayed:** Current language/currency not shown (displayed on sub-pages)
- **No Persistent State:** Page model only tracks `pageStartTime` for analytics

---

## Page Lifecycle

### initState()

**Actions:**
1. Create page model
2. Set `pageStartTime` for duration tracking

**Implementation (Lines 32-42):**
```dart
@override
void initState() {
  super.initState();
  _model = createModel(context, () => AccountModel());

  // On page load action
  SchedulerBinding.instance.addPostFrameCallback((_) async {
    _model.pageStartTime = getCurrentTimestamp;
    safeSetState(() {});
  });

  WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
}
```

### dispose()

**Actions:**
1. Track page view with duration
2. Dispose model
3. Call super.dispose()

**Implementation (Lines 46-63):**
```dart
@override
void dispose() {
  // On page dispose action
  () async {
    await actions.trackAnalyticsEvent(
      'page_viewed',
      <String, String>{
        'pageName': 'settingsAndAccount',
        'durationSeconds': functions.getSessionDurationSeconds(_model.pageStartTime!).toString(),
      },
    );
  }();

  _model.dispose();
  super.dispose();
}
```

---

## Analytics Events (Account Page Only)

### Page View Tracking

**Event Name:** `page_viewed`

**Trigger:** Page dispose (user navigates away)

**Event Data:**
- `pageName`: `'settingsAndAccount'`
- `durationSeconds`: Time spent on page (calculated from `pageStartTime`)

### Engagement Tracking

**Event:** Implicit via `markUserEngaged()` action
**Trigger:** Every setting row tap (6 total possible)
**Purpose:** Track active user interactions

---

## UI Component Details

### Setting Row Pattern (Repeated 6 times)

**Structure:**
```dart
Container(
  height: 40.0,
  decoration: BoxDecoration(),
  child: InkWell(
    splashColor: Colors.transparent,
    focusColor: Colors.transparent,
    hoverColor: Colors.transparent,
    highlightColor: Colors.transparent,
    onTap: () async {
      await actions.markUserEngaged();
      context.pushNamed(TargetWidget.routeName); // Or launchURL()
    },
    child: Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.icon_name, color: secondaryText, size: 18.0),
            Text(translatedLabel, style: bodyMedium),
          ].divide(SizedBox(width: 6.0)),
        ),
        Icon(Icons.keyboard_arrow_right_outlined, color: secondaryText, size: 22.0),
      ],
    ),
  ),
)
```

### Icons Used

| Setting | Material Icon | Size | Line in FF Source |
|---------|--------------|------|-------------------|
| Localization | `Icons.location_on` | 18px | 163 |
| Missing place | `Icons.add_circle` | 18px | 274 |
| Share feedback | `Icons.feedback_rounded` | 18px | 350 |
| Contact us | `Icons.email_rounded` | 18px | 426 |
| Terms of use | `Icons.checklist_rtl_rounded` | 18px | 539 |
| Privacy policy | `Icons.privacy_tip` | 18px | 614 |
| Chevron (all) | `Icons.keyboard_arrow_right_outlined` | 22px | 194, 305, 381, 457, 570, 645 |

### Dividers

**Standard Divider:**
```dart
Divider(
  height: 0.0,
  thickness: 1.0,
  color: Color(0xFFADBECA),
)
```

**Divider with Indent (between sub-items):**
```dart
Divider(
  height: 0.0,
  thickness: 1.0,
  indent: 25.0,  // Aligns with text, not icon
  color: Color(0xFFADBECA),
)
```

---

## Sub-Pages Overview

The Settings hub links to 6 sub-pages. Each needs detailed documentation:

### 1. Localization
- **Route:** `LocalizationWidget.routeName`
- **File:** `lib/app_settings/localization/localization_widget.dart`
- **Purpose:** Language and currency selection
- **Custom Widgets:** `LanguageSelectorButton`, `CurrencySelectorButton`
- **Custom Actions:** `updateCurrencyForLanguage`, `updateCurrencyWithExchangeRate`, `getTranslationsWithUpdate`
- **FFAppState:** Reads/writes `userLanguageCode`, `userCurrencyCode`, `exchangeRate`, `translationsCache`

### 2. Location Sharing
- **Route:** Not directly linked from Account page (navigation hierarchy unclear)
- **File:** `lib/app_settings/location_sharing/location_sharing_widget.dart`
- **Purpose:** Location permission management
- **Custom Actions:** `checkLocationPermissionAndTrack`, `requestLocationPermissionAndTrack`, `openLocationSettings`, `debugLocationStatus`, `checkLocationByFetching`
- **FFAppState:** Reads/writes `locationStatus`

### 3. Missing Place
- **Route:** `MissingPlaceWidget.routeName`
- **File:** `lib/app_settings/missing_place/missing_place_widget.dart`
- **Purpose:** Report missing restaurants
- **Custom Widgets:** `MissingLocationFormWidget`
- **Analytics:** `missing_place_reported` event

### 4. Share Feedback
- **Route:** `ShareFeedbackWidget.routeName`
- **File:** `lib/app_settings/share_feedback/share_feedback_widget.dart`
- **Purpose:** User feedback form with topic selection
- **Custom Widgets:** `FeedbackFormWidget`, `UserFeedbackButtonsPage`, `UserFeedbackButtonsTopic`
- **Analytics:** `feedback_submitted` event

### 5. Contact Us
- **Route:** `ContactUsWidget.routeName`
- **File:** `lib/app_settings/contact_us/contact_us_widget.dart`
- **Purpose:** General support contact form
- **Custom Widgets:** `ContactUsFormWidget`

### 6. Privacy Policy
- **Route:** External URL (Google Docs)
- **File:** `lib/app_settings/privacy_policy/privacy_policy_widget.dart` (if exists)
- **Purpose:** Full privacy policy text
- **⚠️ Warning:** Only available in English. Other languages show blank text (see TRANSLATION_ANALYSIS.md)

---

## Shared Custom Actions (Used Across Sub-Pages)

| Action | Purpose | Used By |
|--------|---------|---------|
| `saveUserPreference` | Save to SharedPreferences | Localization, Location Sharing |
| `getUserPreference` | Load from SharedPreferences | Localization, Location Sharing |
| `trackAnalyticsEvent` | Track interactions | All sub-pages |
| `markUserEngaged` | Track engagement | All sub-pages |

---

## Shared Custom Functions (Used Across Sub-Pages)

| Function | Purpose | Used By |
|----------|---------|---------|
| `getLanguageOptions` | Language list | Localization |
| `getCurrencyOptionsForLanguage` | Currency list | Localization |
| `getLocalizedCurrencyName` | Currency names | Localization |
| `formatLocalizedDate` | Date formatting | Multiple |
| `hasLocationPermission` | Location status | Location Sharing |
| `getSnackbarMessage` | Success/error messages | Forms |
| `getTranslations` | Dynamic text | All sub-pages |

---

## Migration Priority

⭐⭐⭐⭐ **High Priority**

**Rationale:**
- Essential user preferences (language, currency)
- User feedback channels (critical for product improvement)
- Legal requirements (terms, privacy policy)
- Gateway to all settings functionality

**Dependencies:**
- NavBarWidget (must migrate first)
- Translation system (must implement FFLocalizations equivalent)
- Sub-page routing (must set up navigation)

**Estimated Effort:** 2-3 hours for Account hub, 8-12 hours for all sub-pages

---

## Known Issues

### Translation Issue
⚠️ **Privacy Policy Only in English:**
Currently only available in English. Other languages show blank text.
**Action Required:** Translate or hard-code in English with language notice.

### External Dependencies
⚠️ **Legal Documents on Google Docs:**
- Terms and Privacy Policy hosted externally
- Risk: URLs may change or break
- Solution: Consider in-app legal text or web view

---

## Related Documentation

| Document | Location | Priority |
|----------|----------|----------|
| BUNDLE_settings_main.md | `pages/07_settings/` | ⭐⭐⭐⭐⭐ |
| DESIGN_README_settings_main.md | `pages/07_settings/` | ⭐⭐⭐⭐⭐ |
| FlutterFlow Source | `_flutterflow_export/lib/app_settings/account/` | ⭐⭐⭐⭐⭐ |
| NavBarWidget docs | `shared/widgets/MASTER_README_nav_bar_widget.md` | ⭐⭐⭐⭐⭐ |
| markUserEngaged docs | `shared/actions/MASTER_README_mark_user_engaged.md` | ⭐⭐⭐⭐⭐ |
| trackAnalyticsEvent docs | `shared/actions/MASTER_README_track_analytics_event.md` | ⭐⭐⭐⭐⭐ |

---

**End of Functional Specification**

This document provides complete functional details for the Settings hub page. For visual specifications, see DESIGN_README_settings_main.md. For implementation details, see BUNDLE_settings_main.md.
