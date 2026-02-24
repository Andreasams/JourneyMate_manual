# Settings Main Page - Migration Bundle

**Page:** Settings & Account (Main Hub)
**Route:** `/Account`
**FlutterFlow Source:** `lib/app_settings/account/account_widget.dart`
**Status:** ✅ Production Ready

**Last Updated:** 2026-02-19

---

## Purpose

This bundle consolidates all implementation details from the FlutterFlow Settings page for efficient Phase 3 migration. It serves as a quick reference for developers implementing the Settings hub in pure Flutter.

**Primary User Task:** Access app settings, submit feedback, and view legal information.

---

## Documentation References

### Required Reading (In Order):

1. **PAGE_README.md** — Functionality overview
   - Location: `pages/07_settings/PAGE_README.md`
   - Purpose: Complete functional specification, FFAppState usage, analytics events
   - Priority: ⭐⭐⭐⭐⭐ **Read First**

2. **DESIGN_README_settings_main.md** — Design specification
   - Location: `pages/07_settings/DESIGN_README_settings_main.md`
   - Purpose: Visual layout, components, spacing, interaction patterns
   - Priority: ⭐⭐⭐⭐⭐ **Read Second**

3. **FlutterFlow Source Code** — Ground truth
   - Location: `_flutterflow_export/lib/app_settings/account/account_widget.dart`
   - Purpose: Exact implementation, all functionality
   - Priority: ⭐⭐⭐⭐⭐ **Review Before Coding**

---

## FlutterFlow Implementation Analysis

### File Structure

```
lib/app_settings/account/
├── account_widget.dart       # Main settings hub page
└── account_model.dart        # Page model (timer state)
```

### Imports Used

**Flutter/Dart Core:**
```dart
import 'dart:ui';                                // For UI effects
import 'package:flutter/material.dart';          // Core Flutter widgets
import 'package:flutter/scheduler.dart';         // For page load callback
import 'package:google_fonts/google_fonts.dart'; // Typography
import 'package:provider/provider.dart';         // State management
```

**FlutterFlow Framework:**
```dart
import '/flutter_flow/flutter_flow_theme.dart';  // Theme system
import '/flutter_flow/flutter_flow_util.dart';   // Utilities (launchURL, navigation)
import '/flutter_flow/flutter_flow_widgets.dart'; // FF widget wrappers
import '/flutter_flow/custom_functions.dart' as functions; // Custom functions
```

**Custom Code:**
```dart
import '/custom_code/actions/index.dart' as actions; // Custom actions
```

**Local Widgets:**
```dart
import '/widgets/nav_bar/nav_bar_widget.dart';   // Bottom navigation bar
```

**Generated:**
```dart
import '/index.dart';                            // Route index
import 'account_model.dart';                     // Page model
export 'account_model.dart';                     // Export model
```

---

## Custom Actions Used

| Action | Purpose | Import Path | Priority |
|--------|---------|-------------|----------|
| `markUserEngaged` | Track user engagement on tap | `actions.markUserEngaged()` | ⭐⭐⭐⭐⭐ |
| `trackAnalyticsEvent` | Track page view duration | `actions.trackAnalyticsEvent()` | ⭐⭐⭐⭐⭐ |

### Action Usage Details

**1. markUserEngaged()**
- **When Called:** On every setting row tap (6 taps total)
- **Purpose:** Track user interaction for engagement analytics
- **Timing:** Called immediately before navigation
- **Documentation:** `shared/actions/MASTER_README_mark_user_engaged.md`

**2. trackAnalyticsEvent()**
- **When Called:** Page dispose (user leaves settings)
- **Event Name:** `page_viewed`
- **Event Data:**
  - `pageName`: `'settingsAndAccount'`
  - `durationSeconds`: Time spent on page (calculated)
- **Documentation:** `shared/actions/MASTER_README_track_analytics_event.md`

---

## Custom Functions Used

| Function | Purpose | Usage | Priority |
|----------|---------|-------|----------|
| `getSessionDurationSeconds` | Calculate page duration | `functions.getSessionDurationSeconds(_model.pageStartTime!)` | ⭐⭐⭐⭐ |

### Function Usage Details

**1. getSessionDurationSeconds()**
- **Purpose:** Calculate seconds between page load and dispose
- **Input:** `_model.pageStartTime` (DateTime)
- **Output:** Duration as int (seconds)
- **Documentation:** `shared/functions/MASTER_README_get_session_duration_seconds.md`

---

## FlutterFlow Widgets Used

| Widget | Purpose | Usage Count | Priority |
|--------|---------|-------------|----------|
| `NavBarWidget` | Bottom tab navigation | 1 | ⭐⭐⭐⭐⭐ |

### Widget Usage Details

**1. NavBarWidget**
- **Purpose:** Bottom navigation bar with tab selection
- **Location:** `widgets/nav_bar/nav_bar_widget.dart`
- **Props:**
  - `pageIsSearchResults`: `false` (not search page)
- **Active Tab:** Implicitly "profil" (settings is under profile section)
- **Documentation:** `shared/widgets/MASTER_README_nav_bar_widget.md`

---

## Custom Widgets Used

**None.** This page uses only standard Flutter widgets and the NavBar component. No custom form widgets or complex UI components are needed for the main settings hub.

---

## Translation Keys Used

| Key | English Text | Context |
|-----|--------------|---------|
| `cpiiq0im` | Settings & account | Page title |
| `3tlbn2an` | My JourneyMate | Section header 1 |
| `290fbi5g` | Localization | Setting row 1 |
| `pb7qrt34` | Reach out | Section header 2 |
| `297ogtn9` | Are we missing a place? | Setting row 2 |
| `uz83tnpj` | Share feedback | Setting row 3 |
| `dme8eg1t` | Contact us | Setting row 4 |
| `d952v5y4` | Resources | Section header 3 |
| `2v106a6z` | Terms of use | Setting row 5 |
| `gtmo283r` | Privacy policy | Setting row 6 |

**All translations use:**
```dart
FFLocalizations.of(context).getText('key')
```

**Location:** `lib/flutter_flow/internationalization.dart`
**Languages:** 7 (en, da, de, es, fr, it, sv)

---

## Navigation Map

### Setting Rows → Routes

| Row Label | Tap Action | Target Route | Target Widget |
|-----------|------------|--------------|---------------|
| Localization | Navigate | `LocalizationWidget.routeName` | `lib/app_settings/localization/localization_widget.dart` |
| Are we missing a place? | Navigate | `MissingPlaceWidget.routeName` | `lib/app_settings/missing_place/missing_place_widget.dart` |
| Share feedback | Navigate | `ShareFeedbackWidget.routeName` | `lib/app_settings/share_feedback/share_feedback_widget.dart` |
| Contact us | Navigate | `ContactUsWidget.routeName` | `lib/app_settings/contact_us/contact_us_widget.dart` |
| Terms of use | External URL | `launchURL()` | Google Docs (external) |
| Privacy policy | External URL | `launchURL()` | Google Docs (external) |

### External URLs

**Terms of Use:**
```dart
await launchURL('https://docs.google.com/document/d/1CAjvjWt73BgvBZSMUKiIyPbz2sZ5RiqCMGuD0R6KVpc/edit?usp=sharing');
```

**Privacy Policy:**
```dart
await launchURL('https://docs.google.com/document/d/1nO_TaK-HB8-CV9FM8zs3uu0mYgCT4taO0nBSv2iHw3A/edit?usp=sharing');
```

**⚠️ Note:** Both open in external browser. No in-app web view.

---

## FFAppState Usage

### Read

| State Variable | Purpose | Usage |
|----------------|---------|-------|
| None | No state read | Main settings hub is stateless |

### Write

| State Variable | Purpose | Usage |
|----------------|---------|-------|
| None | No state write | Main settings hub is stateless |

### Notes

- **Stateless Navigation:** Settings hub only provides navigation links
- **No Preferences Displayed:** Current language/currency not shown (displayed on sub-pages)
- **No Persistent State:** Page model only tracks `pageStartTime` for analytics

---

## Analytics Events

### Page View Tracking

**Event Name:** `page_viewed`

**Event Data:**
```dart
{
  'pageName': 'settingsAndAccount',
  'durationSeconds': functions.getSessionDurationSeconds(_model.pageStartTime!).toString(),
}
```

**Trigger:** Page dispose (user navigates away)

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

### Engagement Tracking

**Event:** Called via `markUserEngaged()` action
**Trigger:** Every setting row tap (6 total taps possible)
**Purpose:** Track active user interactions

---

## UI Component Breakdown

### Page Structure

```
SafeArea
├── Stack
│   ├── Padding (main content)
│   │   └── Column
│   │       ├── Text (page title)
│   │       ├── Section 1: My JourneyMate
│   │       │   ├── Text (section header)
│   │       │   └── Column (setting rows)
│   │       │       ├── Divider
│   │       │       ├── Container (Localization row)
│   │       │       │   └── InkWell → Row
│   │       │       │       ├── Icon + Text (leading)
│   │       │       │       └── Icon (chevron trailing)
│   │       │       └── Divider
│   │       ├── Section 2: Reach out
│   │       │   ├── Text (section header)
│   │       │   └── Column (setting rows)
│   │       │       ├── Divider
│   │       │       ├── Container (Missing place row)
│   │       │       ├── Divider (with indent)
│   │       │       ├── Container (Share feedback row)
│   │       │       ├── Divider (with indent)
│   │       │       ├── Container (Contact us row)
│   │       │       └── Divider
│   │       └── Section 3: Resources
│   │           ├── Text (section header)
│   │           └── Column (setting rows)
│   │               ├── Divider
│   │               ├── Container (Terms row)
│   │               ├── Divider (with indent)
│   │               ├── Container (Privacy row)
│   │               └── Divider
│   └── Align (bottom)
│       └── NavBarWidget
```

### Setting Row Pattern

Each setting row follows this structure:

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
            Text(label, style: bodyMedium.override(...)),
          ].divide(SizedBox(width: 6.0)),
        ),
        Icon(Icons.keyboard_arrow_right_outlined, color: secondaryText, size: 22.0),
      ],
    ),
  ),
),
```

### Icons Used

| Setting | Material Icon | Size |
|---------|--------------|------|
| Localization | `Icons.location_on` | 18px |
| Missing place | `Icons.add_circle` | 18px |
| Share feedback | `Icons.feedback_rounded` | 18px |
| Contact us | `Icons.email_rounded` | 18px |
| Terms of use | `Icons.checklist_rtl_rounded` | 18px |
| Privacy policy | `Icons.privacy_tip` | 18px |
| Chevron (all) | `Icons.keyboard_arrow_right_outlined` | 22px |

---

## Spacing & Layout

### Page Padding

```dart
EdgeInsetsDirectional.fromSTEB(12.0, 20.0, 12.0, 0.0)
```
- **Left:** 12px
- **Top:** 20px
- **Right:** 12px
- **Bottom:** 0px (NavBar handles bottom space)

### Section Spacing

**Section Headers:**
- Top margin: 20px (from previous section)
- Bottom padding: 8px (from header to divider)

**Between Sections:**
```dart
.divide(SizedBox(height: 8.0))
```

**Within Rows:**
```dart
.divide(SizedBox(width: 6.0))  // Icon-to-text gap
```

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

## Typography Styles

### Page Title

```dart
style: FlutterFlowTheme.of(context).titleLarge.override(
  fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
  color: FlutterFlowTheme.of(context).tertiary,  // ACCENT orange
  fontSize: 24.0,
  letterSpacing: 0.0,
  useGoogleFonts: !FlutterFlowTheme.of(context).titleLargeIsCustom,
)
```

**Visual Specs:**
- Size: 24px
- Color: Tertiary (ACCENT #e8751a)
- Weight: titleLarge default (700)

### Section Headers

```dart
style: FlutterFlowTheme.of(context).bodyLarge.override(
  fontFamily: FlutterFlowTheme.of(context).bodyLargeFamily,
  color: FlutterFlowTheme.of(context).primaryText,
  fontSize: 18.0 - 20.0,  // Varies: 20px for "My JM", 18px for others
  letterSpacing: 0.0,
  fontWeight: FontWeight.w500 - FontWeight.normal,
  useGoogleFonts: !FlutterFlowTheme.of(context).bodyLargeIsCustom,
)
```

**Visual Specs:**
- Size: 18-20px (inconsistent in FF)
- Color: primaryText
- Weight: 400-500 (inconsistent in FF)

**⚠️ Design System Discrepancy:**
- DESIGN_README specifies: 14px, weight 600
- FlutterFlow uses: 18-20px, weight 400-500
- **Migration Note:** Use DESIGN_README specs (14px, 600) for v2

### Setting Row Labels

```dart
style: FlutterFlowTheme.of(context).bodyMedium.override(
  fontFamily: FlutterFlowTheme.of(context).bodyMediumFamily,
  fontSize: 16.0,
  letterSpacing: 0.0,
  useGoogleFonts: !FlutterFlowTheme.of(context).bodyMediumIsCustom,
)
```

**Visual Specs:**
- Size: 16px
- Color: bodyMedium default
- Weight: bodyMedium default (400)

**⚠️ Design System Discrepancy:**
- DESIGN_README specifies: 14px, weight 400, color #555
- FlutterFlow uses: 16px, weight 400, theme color
- **Migration Note:** Use DESIGN_README specs (14px) for v2

---

## Colors Used

### Theme Colors

| Element | Color Reference | Hex (Typical) |
|---------|----------------|---------------|
| Page title | `tertiary` | #e8751a (ACCENT orange) |
| Section headers | `primaryText` | #0f0f0f (darkest) |
| Row labels | `bodyMedium` default | #555 (dark gray) |
| Icons | `secondaryText` | #666 (medium gray) |
| Dividers | Hardcoded | #ADBECA (light blue-gray) |

### Hardcoded Colors

```dart
Color(0xFFADBECA)  // Divider lines
```

**⚠️ Design System Discrepancy:**
- DESIGN_README specifies: #f2f2f2 (light gray)
- FlutterFlow uses: #ADBECA (light blue-gray)
- **Migration Note:** Use DESIGN_README specs (#f2f2f2) for v2

---

## Page Lifecycle

### initState()

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

**Actions:**
1. Initialize model
2. Set `pageStartTime` for duration tracking

### dispose()

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

**Actions:**
1. Track page view with duration
2. Dispose model
3. Call super.dispose()

---

## Interaction Flow

### User Taps Setting Row

```
User taps row
  ↓
InkWell.onTap fires
  ↓
await actions.markUserEngaged()
  ↓
context.pushNamed(TargetWidget.routeName)
  OR
await launchURL('https://...')
  ↓
Navigate to target page/URL
```

### Page View Tracking

```
User opens settings page
  ↓
initState() sets pageStartTime
  ↓
User interacts/reads
  ↓
User navigates away
  ↓
dispose() calculates duration
  ↓
trackAnalyticsEvent('page_viewed') sent
```

---

## Migration Notes for Phase 3

### What to Keep Identical

✅ **Page Structure:**
- Three-section layout (My JM, Reach out, Resources)
- Setting row component pattern
- Icon + label + chevron structure

✅ **Functionality:**
- Navigation to sub-pages
- External URL launching for legal docs
- markUserEngaged() on all taps
- Page view duration tracking

✅ **Translation System:**
- FFLocalizations.of(context).getText()
- All 10 translation keys

### What to Update (Design System Alignment)

⚠️ **Typography:**
- Page title: 24px (keep)
- Section headers: Change from 18-20px/400-500 → **14px/600**
- Row labels: Change from 16px → **14px**

⚠️ **Colors:**
- Dividers: Change from #ADBECA → **#f2f2f2**
- Row label color: Ensure **#555** (dark gray)
- Icon color: Ensure **#666** (medium gray)

⚠️ **Spacing:**
- Page padding: Change from 12px sides → **20px sides**
- Row height: Change from 40px → **~47px** (14px vertical padding)
- Section header bottom: Change from 8px → **8px** (same, good)
- Icon-to-text gap: Change from 6px → **12px**

### What to Implement Fresh

🆕 **Hover State (Desktop/Tablet):**
- Not present in FlutterFlow mobile app
- Add background color change on hover (#f9f9f9)
- Add transition (0.2s ease)

🆕 **Design System Component:**
- Extract SettingsRow as reusable component
- Define in `shared_widgets.dart` if used elsewhere

### What to Remove

❌ **FF-Specific Imports:**
- Remove `/flutter_flow/flutter_flow_theme.dart` (use AppTheme)
- Remove `/flutter_flow/flutter_flow_util.dart` (use Flutter/Dart core)
- Remove `/flutter_flow/flutter_flow_widgets.dart` (use Flutter core)
- Remove `export 'account_model.dart'` (unnecessary in clean architecture)

❌ **FlutterFlow Utilities:**
- Replace `safeSetState()` with `setState()`
- Replace `getCurrentTimestamp` with `DateTime.now()`
- Replace `context.pushNamed()` with Go Router or Navigator

### State Management Migration

**Current (FlutterFlow):**
```dart
// No FFAppState usage on this page
```

**Phase 3 (Riverpod):**
```dart
// Still no state needed - purely navigational page
// Page duration tracking can stay in local model
```

**No migration complexity.** Settings hub is stateless.

---

## Testing Checklist

### Functional Tests

- [ ] Page loads without errors
- [ ] Page title displays correctly in all 7 languages
- [ ] All 6 setting rows display correctly
- [ ] All 3 section headers display correctly
- [ ] Tap "Localization" → navigates to LocalizationWidget
- [ ] Tap "Missing place" → navigates to MissingPlaceWidget
- [ ] Tap "Share feedback" → navigates to ShareFeedbackWidget
- [ ] Tap "Contact us" → navigates to ContactUsWidget
- [ ] Tap "Terms of use" → opens Google Docs in browser
- [ ] Tap "Privacy policy" → opens Google Docs in browser
- [ ] `markUserEngaged()` called on all 6 taps
- [ ] Page view duration tracked on dispose
- [ ] NavBar displays with "profil" tab active

### Visual Tests

- [ ] Page title is ACCENT orange (#e8751a)
- [ ] Section headers are dark (#0f0f0f)
- [ ] Row labels are readable (#555)
- [ ] Icons are visible (#666)
- [ ] Dividers are subtle (#ADBECA in FF, #f2f2f2 in v2)
- [ ] Chevron icons are light gray (#bbb)
- [ ] Row height is 40px (FF) or 47px (v2)
- [ ] Icon-to-text gap is 6px (FF) or 12px (v2)
- [ ] Page padding is 12px (FF) or 20px (v2)

### Analytics Tests

- [ ] Page view event sent on dispose
- [ ] Event includes correct `pageName` ('settingsAndAccount')
- [ ] Event includes duration in seconds (calculated correctly)
- [ ] Engagement tracked on all row taps

### Translation Tests

- [ ] Test all 10 translation keys in all 7 languages:
  - English (en)
  - Danish (da)
  - German (de)
  - Spanish (es)
  - French (fr)
  - Italian (it)
  - Swedish (sv)

### Edge Cases

- [ ] Page disposed before postFrameCallback → duration calculation handles null
- [ ] Rapid taps on setting row → only one navigation occurs
- [ ] External URLs fail to launch → error handled gracefully
- [ ] NavBar hidden/shown correctly based on page context

---

## Sub-Pages to Document

The Settings hub links to 6 sub-pages. Each needs its own BUNDLE.md:

1. **Localization** (`lib/app_settings/localization/localization_widget.dart`)
   - Language selection
   - Currency selection
   - Real-time preview
   - **DESIGN_README:** `DESIGN_README_localization.md` ✅

2. **Location Sharing** (`lib/app_settings/location_sharing/location_sharing_widget.dart`)
   - Permission toggle
   - Location status display
   - Open device settings
   - **DESIGN_README:** `DESIGN_README_location_sharing.md` ✅

3. **Missing Place** (`lib/app_settings/missing_place/missing_place_widget.dart`)
   - Form to report missing restaurants
   - Custom widget: MissingLocationFormWidget
   - **DESIGN_README:** `DESIGN_README_missing_place_form.md` ✅

4. **Share Feedback** (`lib/app_settings/share_feedback/share_feedback_widget.dart`)
   - Feedback form with topic selection
   - Custom widget: FeedbackFormWidget
   - **DESIGN_README:** `DESIGN_README_share_feedback_form.md` ✅

5. **Contact Us** (`lib/app_settings/contact_us/contact_us_widget.dart`)
   - Support contact form
   - Custom widget: ContactUsFormWidget
   - **DESIGN_README:** `DESIGN_README_contact_us_form.md` ✅

6. **Privacy Policy** (`lib/app_settings/privacy_policy/privacy_policy_widget.dart`)
   - Full privacy policy text
   - ⚠️ **Only English** - blank in other languages (see TRANSLATION_ANALYSIS.md)

**Next Steps:** Create BUNDLE.md for each sub-page following this same pattern.

---

## Related Documentation

### Master Documentation

| Document | Purpose | Location |
|----------|---------|----------|
| PAGE_README.md | Functional spec | `pages/07_settings/PAGE_README.md` |
| DESIGN_README_settings_main.md | Visual design spec | `pages/07_settings/DESIGN_README_settings_main.md` |
| TRANSLATION_ANALYSIS.md | Translation system details | Root directory |
| journeymate-design-system.md | Design tokens & rationale | `_reference/` |
| CLAUDE.md | Project rules & workflows | Root directory |

### Custom Actions Documentation

| Action | Documentation | Priority |
|--------|--------------|----------|
| markUserEngaged | `shared/actions/MASTER_README_mark_user_engaged.md` | ⭐⭐⭐⭐⭐ |
| trackAnalyticsEvent | `shared/actions/MASTER_README_track_analytics_event.md` | ⭐⭐⭐⭐⭐ |

### Custom Functions Documentation

| Function | Documentation | Priority |
|----------|--------------|----------|
| getSessionDurationSeconds | `shared/functions/MASTER_README_get_session_duration_seconds.md` | ⭐⭐⭐⭐ |

### Custom Widgets Documentation

| Widget | Documentation | Priority |
|--------|--------------|----------|
| NavBarWidget | `shared/widgets/MASTER_README_nav_bar_widget.md` | ⭐⭐⭐⭐⭐ |

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
- Sub-page navigation routing (must set up)
- Translation system (must implement FFLocalizations equivalent)

**Estimated Effort:** 2-3 hours
- Simple navigation hub (no complex state)
- Main complexity in sub-pages (forms, selectors)
- Design system alignment (spacing/typography updates)

---

## Known Issues & Warnings

### FlutterFlow Inconsistencies

1. **Typography Inconsistency:**
   - Section headers vary (20px vs 18px, weight 400 vs 500)
   - Row labels don't match design system (16px vs 14px)
   - **Solution:** Use DESIGN_README specs for v2 migration

2. **Color Inconsistency:**
   - Dividers use #ADBECA (light blue-gray) instead of #f2f2f2 (light gray)
   - **Solution:** Use DESIGN_README specs (#f2f2f2) for v2 migration

3. **Spacing Inconsistency:**
   - Page padding 12px instead of 20px
   - Icon-to-text gap 6px instead of 12px
   - **Solution:** Use DESIGN_README specs for v2 migration

### Translation Issues

1. **Privacy Policy:**
   - Only available in English
   - Other 6 languages show blank text
   - **Solution:** Document clearly, decide on hardcoded English vs translation

### External Dependencies

1. **Legal Documents on Google Docs:**
   - Terms: `https://docs.google.com/document/d/1CAjvjWt73BgvBZSMUKiIyPbz2sZ5RiqCMGuD0R6KVpc/edit?usp=sharing`
   - Privacy: `https://docs.google.com/document/d/1nO_TaK-HB8-CV9FM8zs3uu0mYgCT4taO0nBSv2iHw3A/edit?usp=sharing`
   - **Risk:** External URLs may change or break
   - **Solution:** Consider in-app legal text or web view

---

## Phase 3 Implementation Strategy

### Step 1: Review Documentation (30 min)
1. Read PAGE_README.md
2. Read DESIGN_README_settings_main.md
3. Read FlutterFlow source code
4. Review this BUNDLE.md

### Step 2: Set Up Page Structure (1 hour)
1. Create `lib/pages/settings_page.dart`
2. Implement StatefulWidget with model
3. Set up page lifecycle (initState, dispose)
4. Add SafeArea + Stack layout
5. Implement page title
6. Add NavBarWidget at bottom

### Step 3: Implement Setting Rows (1 hour)
1. Create SettingsRow widget component
2. Add section headers (My JM, Reach out, Resources)
3. Implement all 6 setting rows with correct icons
4. Add dividers (standard + indented)
5. Wire up navigation (pushNamed for 4, launchURL for 2)

### Step 4: Add Analytics (30 min)
1. Implement page start time tracking
2. Add markUserEngaged() to all row taps
3. Add page view duration tracking on dispose
4. Test analytics events fire correctly

### Step 5: Apply Design System (30 min)
1. Update typography to design system specs
2. Update colors to design system specs
3. Update spacing to design system specs
4. Add hover states (desktop/tablet)
5. Verify visual alignment with design

### Step 6: Test & Polish (30 min)
1. Run functional tests (navigation, analytics)
2. Run visual tests (colors, spacing, typography)
3. Test all 7 languages
4. Test edge cases (rapid taps, failed URLs)
5. Run `flutter analyze` and fix issues

---

**End of Bundle**

This bundle consolidates all implementation details for the Settings hub page. For sub-page implementations, refer to individual BUNDLE.md files for each sub-page.

**Next:** Create BUNDLE.md files for the 6 sub-pages listed above.

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
None. The Settings Main page (AccountWidget) is a purely navigational hub. All six setting rows navigate to sub-pages via `context.pushNamed()` or `launchURL()`. No provider state is read to render the page.

### Writes
None. `markUserEngaged()` and `trackAnalyticsEvent()` are fire-and-forget BuildShip POST calls. They do not write to any Riverpod provider. `getSessionDurationSeconds()` reads local `pageStartTime` (not a provider).

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation on dispose |
