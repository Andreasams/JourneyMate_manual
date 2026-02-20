# Localization Page — Implementation Bundle

**Page:** Localization Settings Hub
**Route:** `/Localization` (path: `localization`)
**FlutterFlow Source:** `lib/app_settings/localization/localization_widget.dart`
**Status:** Ready for Migration

---

## Overview

The Localization page serves as a settings hub that provides access to two critical localization-related settings:
1. Language & Currency settings
2. Location Sharing permissions

This is a **navigation hub page** — it does not contain the actual settings UI, but instead provides links to dedicated sub-pages for each setting.

---

## FlutterFlow Source Analysis

### File Location
```
_flutterflow_export/lib/app_settings/localization/
├── localization_widget.dart       # Main widget
└── localization_model.dart        # Model (minimal, no state)
```

### Imports Required

```dart
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:async';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
```

### Custom Actions Used

| Action | Purpose | Called When |
|--------|---------|-------------|
| `markUserEngaged()` | Track user interaction | Back button tapped, navigation item tapped |

### Navigation Targets

| Target Widget | Route Name | User Action |
|---------------|------------|-------------|
| `LanguageAndCurrencyWidget` | `LanguageAndCurrency` | Tap "Language & currency" row |
| `LocationSharingWidget` | `LocationSharing` | Tap "Location sharing" row |

---

## Page Structure

### App Bar
- **Background:** `primaryBackground` theme color
- **Leading:** Back button (iOS-style arrow)
  - Icon: `Icons.arrow_back_ios`, size 30px
  - Action: `markUserEngaged()` → `context.safePop()`
- **Title:** Translated text "Settings" (key: `'3dn3iu2l'`)
  - Font size: 22px
  - Style: `headlineMedium` with theme overrides
  - Centered

### Body Content

**Container:**
- Padding: `EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 0.0)`
- Layout: Column with `mainAxisSize: min`, `crossAxisAlignment: start`

**Content Structure:**
```
Column (expanded)
  ├── Divider (top border)
  ├── Language & Currency Row (tappable)
  ├── Divider (separator)
  ├── Location Sharing Row (tappable)
  └── Divider (bottom border)
```

### Navigation Rows

**Common Properties:**
- Width: `double.infinity`
- Height: 40px
- Background: Transparent
- Layout: Row with space-between alignment
- Tap behavior: Transparent splash/focus/hover/highlight colors

**Row Content:**
- **Left:** Text label (16px, `bodyMedium` font)
- **Right:** Chevron icon (`Icons.keyboard_arrow_right_outlined`, 22px, `secondaryText` color)

**Row 1: Language & Currency**
- **Label:** Translated "Language & currency" (key: `'n5kw731s'`)
- **Action:**
  1. `await actions.markUserEngaged()`
  2. `context.pushNamed(LanguageAndCurrencyWidget.routeName)`

**Row 2: Location Sharing**
- **Label:** Translated "Location sharing" (key: `'fojleyaf'`)
- **Action:**
  1. `unawaited(() async { await actions.markUserEngaged(); }())`
  2. `context.pushNamed(LocationSharingWidget.routeName)`

### Dividers
- Height: 0px
- Thickness: 1px
- Color: `#ADBECA` (hardcoded, not from theme)

---

## Translation Keys

| Key | English Text | Usage |
|-----|--------------|-------|
| `'3dn3iu2l'` | "Settings" | App bar title |
| `'n5kw731s'` | "Language & currency" | First navigation row |
| `'fojleyaf'` | "Location sharing" | Second navigation row |

**Translation System:**
- Uses `FFLocalizations.of(context).getText(key)`
- Requires `languageCode` and `translationsCache` from context

---

## State Management

### Model Class
```dart
class LocalizationModel extends FlutterFlowModel<LocalizationWidget> {
  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
```

**Note:** Model is minimal — no local state, no controllers. This is a pure navigation page.

### FFAppState Usage
- **None directly** — This page does not read or write FFAppState
- Child pages (Language & Currency, Location Sharing) manage their own state

---

## Analytics Events

**None tracked on this page itself.**

Analytics are tracked on the child pages:
- Language & Currency page tracks `page_viewed` with duration on dispose
- Location Sharing page tracks `page_viewed` with duration on dispose

---

## User Interactions

### 1. Back Navigation
**Trigger:** Tap back button (top-left arrow)
**Actions:**
1. Call `markUserEngaged()` to track interaction
2. Execute `context.safePop()` to return to previous page (likely Settings hub)

### 2. Navigate to Language & Currency
**Trigger:** Tap "Language & currency" row
**Actions:**
1. Call `markUserEngaged()` (awaited)
2. Navigate to `LanguageAndCurrencyWidget` via `context.pushNamed()`

### 3. Navigate to Location Sharing
**Trigger:** Tap "Location sharing" row
**Actions:**
1. Call `markUserEngaged()` (unawaited, fire-and-forget)
2. Navigate to `LocationSharingWidget` via `context.pushNamed()`

**Note:** The second action uses `unawaited()` pattern while the first uses `await`. This inconsistency exists in FlutterFlow source and should be preserved initially, then standardized during refactoring.

---

## Design Implementation Notes

### Differences from v2 JSX Design

The v2 JSX design (documented in `DESIGN_README_localization.md`) shows a **completely different UI**:
- JSX design: Inline language/currency dropdowns + location status card on one page
- FlutterFlow: Simple navigation hub with two links to separate pages

**Decision:** Follow FlutterFlow implementation for initial migration, as this represents the production behavior users are accustomed to. The v2 JSX design is a future enhancement.

### Visual Styling

**Current FlutterFlow Styling:**
- Clean, minimal design with dividers separating options
- Standard iOS-style chevron arrows for navigation affordance
- No icons next to row labels (text-only)
- Divider color `#ADBECA` is hardcoded (should be replaced with theme color in migration)

**v2 Design Enhancements (Future):**
- Add icons next to labels (language flag emoji, location pin SVG)
- Show current settings preview (selected language/currency, location status)
- Inline controls instead of navigation (dropdowns, toggle)
- Status indicators (colored dots for location on/off)

---

## Dependencies

### Child Pages Required

This page is non-functional without:

1. **LanguageAndCurrencyWidget** (`lib/app_settings/language_and_currency/`)
   - Contains language selection dropdown
   - Contains currency selection dropdown
   - Contains custom widgets: `LanguageSelectorButton`, `CurrencySelectorButton`
   - Uses custom actions: `updateCurrencyForLanguage`, `updateCurrencyWithExchangeRate`, `getTranslationsWithUpdate`
   - Uses custom functions: `getLanguageOptions`, `getCurrencyOptionsForLanguage`, `getLocalizedCurrencyName`

2. **LocationSharingWidget** (`lib/app_settings/location_sharing/`)
   - Shows current location permission status
   - Provides enable/disable location toggle
   - Explains location usage and privacy
   - Uses custom actions: `checkLocationPermission`, `requestLocationPermissionAndTrack`, `openLocationSettings`
   - Uses custom functions: `hasLocationPermission`

### Custom Actions Required

| Action File | Purpose |
|-------------|---------|
| `mark_user_engaged.dart` | Track user activity timestamp |

---

## Migration Checklist

### Phase 1: Basic Implementation
- [ ] Create `lib/pages/settings/localization_page.dart`
- [ ] Create corresponding model file
- [ ] Implement back button with `markUserEngaged()` call
- [ ] Implement two navigation rows with proper spacing
- [ ] Add dividers with correct styling
- [ ] Test navigation to child pages
- [ ] Verify translation keys work for all supported languages

### Phase 2: Integration
- [ ] Ensure `LanguageAndCurrencyWidget` is migrated first
- [ ] Ensure `LocationSharingWidget` is migrated first
- [ ] Verify `markUserEngaged()` custom action is available
- [ ] Test navigation flow: Settings → Localization → Language/Location → Back
- [ ] Verify back navigation returns to correct parent

### Phase 3: Refinement
- [ ] Replace hardcoded divider color with theme color
- [ ] Standardize `markUserEngaged()` call pattern (await vs unawaited)
- [ ] Add hover states for web/desktop builds
- [ ] Verify accessibility (screen reader labels, focus order)

### Phase 4: v2 Design Enhancement (Future)
- [ ] Implement inline dropdowns from v2 JSX design
- [ ] Add status card for location sharing
- [ ] Add icons to navigation rows
- [ ] Implement state-dependent button behavior (v2 design)
- [ ] Add privacy note (v2 design)

---

## Testing Requirements

### Unit Tests
- [ ] Model initialization and disposal
- [ ] Route name constants match FlutterFlow

### Widget Tests
- [ ] Page renders without errors
- [ ] Back button calls `markUserEngaged()` and pops navigation
- [ ] Language & Currency row navigates to correct route
- [ ] Location Sharing row navigates to correct route
- [ ] Translation keys render correctly for all languages

### Integration Tests
- [ ] Full navigation flow from Settings hub through Localization to child pages
- [ ] Back navigation returns to correct screen
- [ ] Settings persistence across navigation (language/currency remain selected)

---

## Related Documentation

- **FlutterFlow Source:** `_flutterflow_export/lib/app_settings/localization/localization_widget.dart`
- **v2 JSX Design:** `DESIGN_README_localization.md` (this folder)
- **Page Audit:** `PAGE_README.md` (this folder)
- **Child Page - Language & Currency:** `../language_and_currency/` (needs BUNDLE.md)
- **Child Page - Location Sharing:** `../location_sharing/` (needs BUNDLE.md)
- **Design System:** `_reference/journeymate-design-system.md`

---

## Notes for Implementer

### Key Implementation Details

1. **Simple Navigation Hub:** This page has no complex logic — just two tappable rows that navigate elsewhere.

2. **Translation System:** All visible text uses translation keys via `FFLocalizations.of(context).getText()`. Do not hardcode English strings.

3. **Analytics Note:** No analytics on this page itself. Parent and child pages handle their own tracking.

4. **Model Simplicity:** The model class is essentially empty. Do not add unnecessary state management here.

5. **Divider Color:** The hardcoded `#ADBECA` should be replaced with a theme color during migration for consistency.

6. **Async Inconsistency:** FlutterFlow source uses `await` for first navigation action but `unawaited()` for second. Preserve initially, document for future cleanup.

### Common Pitfalls to Avoid

- **Do not** implement inline settings controls on this page (that's the v2 design, not current production)
- **Do not** add state management for language/currency/location (child pages handle that)
- **Do not** add analytics tracking here (it belongs on child pages)
- **Do not** forget `markUserEngaged()` calls on navigation actions (important for user activity tracking)

### Future Enhancements (Post-Migration)

Once the basic FlutterFlow-equivalent implementation is complete and tested, consider these v2 design improvements:

1. **Consolidate Language & Currency inline** (remove navigation to separate page)
2. **Add location status preview** with enable/disable button
3. **Add icons** to navigation rows for visual interest
4. **Progressive disclosure** pattern for location settings (primary action: enable, secondary: manage)

See `DESIGN_README_localization.md` for full v2 design specifications.

---

**Bundle Created:** 2026-02-19
**Last Updated:** 2026-02-19
**Status:** Ready for implementation

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
None. This page is a purely navigational hub — it renders static rows that navigate to sub-pages. No provider state is needed to render the settings list.

### Writes
None. `markUserEngaged()` and `trackAnalyticsEvent()` are fire-and-forget BuildShip calls that do not mutate any Riverpod provider.

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation on dispose |
