# LanguageSelectorButton Widget - Master Documentation

**Source:** `_flutterflow_export/lib/custom_code/widgets/language_selector_button.dart`
**Widget Type:** Custom StatefulWidget
**Category:** Settings / Localization / User Preferences
**Phase 3 Status:** Ready for migration
**Last Updated:** 2026-02-19

---

## Table of Contents

1. [Purpose](#purpose)
2. [Function Signature](#function-signature)
3. [Parameters](#parameters)
4. [Dependencies](#dependencies)
5. [FFAppState Usage](#ffappstate-usage)
6. [Supported Languages](#supported-languages)
7. [State Management](#state-management)
8. [Translation Keys](#translation-keys)
9. [Analytics Events](#analytics-events)
10. [Custom Actions Called](#custom-actions-called)
11. [UI Behavior](#ui-behavior)
12. [Usage Examples](#usage-examples)
13. [Error Handling](#error-handling)
14. [Testing Checklist](#testing-checklist)
15. [Migration Notes](#migration-notes)

---

## Purpose

The `LanguageSelectorButton` is a sophisticated custom widget that provides a complete language selection and switching interface for JourneyMate. It displays the currently selected language with a flag emoji and native name, opens an overlay selector on tap, and orchestrates a complete language change sequence including:

- Persisting the language preference
- Updating the app's locale immediately
- Switching the currency to match the new language
- Fetching fresh translations from the backend
- Fetching fresh filter labels for the new language
- Triggering rebuilds across the app

**Key Capabilities:**
- Self-contained overlay positioning (no external modals needed)
- Prevents double-tap issues during language switching
- Automatic rollback on errors
- Fire-and-forget analytics tracking
- Integration with FlutterFlow's native localization system

**Where Used:**
- Language & Currency Settings page (primary)
- App Settings Initiate Flow (onboarding)

---

## Function Signature

```dart
class LanguageSelectorButton extends StatefulWidget {
  const LanguageSelectorButton({
    super.key,
    this.width,
    this.height,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final dynamic translationsCache;

  @override
  State<LanguageSelectorButton> createState() => _LanguageSelectorButtonState();
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `translationsCache` | `dynamic` | Reference to `FFAppState().translationsCache`. Contains all loaded UI translations. Required for displaying language names using the current locale. |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `double?` | `null` | Button width. If null, uses intrinsic size. Typically set to `double.infinity` for full-width display. |
| `height` | `double?` | `null` | Button height. Typically set to `49.0` for consistent sizing with other settings buttons. |

---

## Dependencies

### Flutter Packages
```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
```

### FlutterFlow Imports
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
```

### Custom Code Dependencies
```dart
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

**Custom Actions Used:**
- `getTranslationsWithUpdate(languageCode)` - Fetches UI translations for the new language
- `getFiltersWithUpdate(languageCode)` - Fetches filter labels for the new language
- `updateCurrencyForLanguage(languageCode)` - Updates currency to match language region
- `saveUserPreference(key, value)` - Mirrors language preference to user settings
- `markUserEngaged()` - Tracks user interaction
- `trackAnalyticsEvent(eventName, properties)` - Logs analytics events

**Custom Functions Used:**
- `getTranslations(languageCode, key, translationsCache)` - Retrieves translated strings

**FlutterFlow Utilities Used:**
- `setAppLanguage(context, languageCode)` - Updates locale and triggers rebuild
- `FFLocalizations.of(context).languageCode` - Gets current language code

---

## FFAppState Usage

### State Variables Read

| Variable | Type | Usage |
|----------|------|-------|
| `translationsCache` | `dynamic` | Passed to `getTranslations()` for retrieving UI text. Updated by `getTranslationsWithUpdate()` action. |

### State Modifications

The widget triggers `FFAppState().update(() {})` after successfully changing languages to force rebuilds throughout the app.

### SharedPreferences Storage

| Key | Type | Description |
|-----|------|-------------|
| `'ff_language'` | `String` | Persists selected language code (e.g., `'en'`, `'da'`). Used by FlutterFlow's localization system on app startup. |

---

## Supported Languages

### Active Languages (Displayed in Overlay)

The widget supports 7 active languages, displayed in this order:

| Language Code | Flag | Native Name | Display Order |
|---------------|------|-------------|---------------|
| `da` | 🇩🇰 | Dansk | 1 |
| `en` | 🇬🇧 | English | 2 |
| `de` | 🇩🇪 | Deutsch | 3 |
| `sv` | 🇸🇪 | Svenska | 4 |
| `no` | 🇳🇴 | Norsk | 5 |
| `it` | 🇮🇹 | Italiano | 6 |
| `fr` | 🇫🇷 | Français | 7 |

### Inactive Languages (Not Currently Displayed)

These languages have metadata defined but are not shown in the selector:

| Language Code | Flag | Native Name |
|---------------|------|-------------|
| `es` | 🇪🇸 | Español |
| `fi` | 🇫🇮 | Suomi |
| `ja` | 🇯🇵 | 日本語 |
| `ko` | 🇰🇷 | 한국어 |
| `nl` | 🇳🇱 | Nederlands |
| `pl` | 🇵🇱 | Polski |
| `uk` | 🇺🇦 | Українська |
| `zh` | 🇨🇳 | 中文 |

**Activation Logic:**
```dart
static const Map<String, Map<String, dynamic>> _languageMetadata = {
  'da': {'flag': '🇩🇰', 'is_active': true, 'display_order': 1},
  'es': {'flag': '🇪🇸', 'is_active': false, 'display_order': 999},
  // ...
};
```

To activate a language, set `'is_active': true` and assign a `display_order` between 1-100.

---

## State Management

### Local Widget State

| State Variable | Type | Purpose |
|---------------|------|---------|
| `_buttonKey` | `GlobalKey` | Tracks button position for overlay placement. Used to calculate overlay offset. |
| `_overlayEntry` | `OverlayEntry?` | Reference to overlay for manual dismissal. Null when overlay is not shown. |
| `_isOverlayVisible` | `bool` | Tracks overlay visibility. Used to show up/down chevron icon. |
| `_isBusy` | `bool` | Prevents double-taps during language change operation. Locks interactions until complete. |

### State Flow During Language Change

```
User taps language → _isBusy = true
                   ↓
            Dismiss overlay
                   ↓
      Save to SharedPreferences
                   ↓
         Apply locale change
                   ↓
    Fetch translations + filters (parallel)
                   ↓
      Trigger FFAppState rebuild
                   ↓
         Trigger widget rebuild
                   ↓
            _isBusy = false
```

**Error Handling:** If any step fails, the widget attempts to rollback the language change by restoring the previous language code to SharedPreferences and calling `setAppLanguage()` again.

---

## Translation Keys

The widget uses the following translation keys to retrieve UI text:

| Translation Key | Purpose | Example (EN) |
|----------------|---------|--------------|
| `lang_name_da` | Display "Danish" in current language | "Danish" (EN), "Dänisch" (DE) |
| `lang_name_en` | Display "English" in current language | "English" (EN), "Engelsk" (DA) |
| `lang_name_de` | Display "German" in current language | "German" (EN), "Tysk" (DA) |
| `lang_name_sv` | Display "Swedish" in current language | "Swedish" (EN), "Svensk" (DA) |
| `lang_name_no` | Display "Norwegian" in current language | "Norwegian" (EN), "Norsk" (DA) |
| `lang_name_it` | Display "Italian" in current language | "Italian" (EN), "Italiensk" (DA) |
| `lang_name_fr` | Display "French" in current language | "French" (EN), "Fransk" (DA) |

**Note:** Native language names (Dansk, English, Deutsch, etc.) are hardcoded in the widget and do **not** require translation. They always display in their native form regardless of the current app language.

### Translation Retrieval Pattern

```dart
String _getLanguageName(BuildContext context, String languageCode) {
  final currentLanguageCode = _getCurrentLanguageCode(context);
  return getTranslations(
    currentLanguageCode,
    'lang_name_$languageCode',
    FFAppState().translationsCache,
  );
}
```

This pattern retrieves the **localized** name (e.g., "Danish" vs "Dansk") but is not currently used in the display. The button shows only native names via `_getNativeLanguageName()`.

---

## Analytics Events

### Event: `language_changed`

**Triggered:** When user selects a new language (different from current).

**Tracking Call:**
```dart
trackAnalyticsEvent(
  'language_changed',
  {
    'from_language': fromLanguage,        // e.g., 'en'
    'to_language': toLanguage,            // e.g., 'da'
    'from_language_name': fromLanguageName, // e.g., 'English'
    'to_language_name': toLanguageName,     // e.g., 'Dansk'
  },
);
```

**Properties:**

| Property | Type | Description |
|----------|------|-------------|
| `from_language` | `String` | Language code before change (e.g., `'en'`) |
| `to_language` | `String` | Language code after change (e.g., `'da'`) |
| `from_language_name` | `String` | Native language name before change (e.g., `'English'`) |
| `to_language_name` | `String` | Native language name after change (e.g., `'Dansk'`) |

**Error Handling:** Analytics failures are caught and logged to console but do not block language change operation (fire-and-forget pattern).

---

## Custom Actions Called

### Language Change Sequence

When a user selects a new language, the following actions execute in sequence:

#### 1. Mark User Engagement
```dart
markUserEngaged();
```
- Fire-and-forget call (no await)
- Tracks active user session

#### 2. Track Analytics
```dart
_trackLanguageChange(currentLanguageCode, newLanguageCode);
```
- Fire-and-forget call (no await)
- Logs `language_changed` event

#### 3. Persist Language
```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('ff_language', languageCode);
```
- Saves to device storage
- Used by FlutterFlow on app restart

#### 4. Apply Language Immediately
```dart
setAppLanguage(context, languageCode);
```
- Updates `FFLocalizations` provider
- Triggers rebuild of dependent widgets

#### 5. Mirror to User Preferences (Optional)
```dart
await saveUserPreference('user_language_code', languageCode);
```
- Stores in backend user profile
- Used for cross-device sync (if implemented)

#### 6. Update Currency
```dart
await updateCurrencyForLanguage(languageCode);
```
- Sets currency based on language region
- Updates `FFAppState().selectedCurrency`

#### 7. Fetch Fresh Translations and Filters (Parallel)
```dart
await Future.wait([
  getTranslationsWithUpdate(languageCode),
  getFiltersWithUpdate(languageCode),
]);
```
- Fetches UI strings for new language
- Fetches filter labels for new language
- Both run in parallel for performance

#### 8. Trigger Rebuilds
```dart
if (mounted) {
  FFAppState().update(() {});
  setState(() {});
}
```
- Forces app-wide rebuild
- Updates all displayed text

---

## UI Behavior

### Button Appearance

**Closed State:**
```
┌──────────────────────────────┐
│ 🇬🇧  English            ▼   │  ← Grey background (#F2F3F5)
└──────────────────────────────┘    8px border radius
```

**Open State (Overlay Visible):**
```
┌──────────────────────────────┐
│ 🇬🇧  English            ▲   │  ← Chevron points up
└──────────────────────────────┘
         4px gap
┌──────────────────────────────┐
│  🇩🇰  Dansk                  │  ← Overlay positioned below
│  🇬🇧  English                │
│  🇩🇪  Deutsch                │
│  🇸🇪  Svenska                │
│  🇳🇴  Norsk                  │
│  🇮🇹  Italiano               │
│  🇫🇷  Français               │
└──────────────────────────────┘
```

### Styling Constants

#### Button Styling
```dart
Color:           #F2F3F5 (light grey)
TextColor:       #14181B (near-black)
IconColor:       #57636C (medium grey)
BorderRadius:    8.0px
HorizontalPad:   12.0px
VerticalPad:     8.0px
FontSize:        14.0px
FontWeight:      w300
IconSize:        24.0px
```

#### Overlay Styling
```dart
Color:           #F2F3F5 (matches button)
BorderRadius:    8.0px
PaddingLeftRight: 12.0px
PaddingTop:      4.0px
ItemPaddingLeft: 4.0px
ItemVerticalPad: 12.0px
GapFromButton:   4.0px (positioning)
Shadow:          0px 2px 4px rgba(0,0,0,0.2)
```

### Interaction Patterns

| User Action | Widget Response |
|-------------|-----------------|
| Tap button | Opens overlay below button with 4px gap |
| Tap outside overlay | Dismisses overlay |
| Tap same language | Dismisses overlay (no action) |
| Tap different language | Dismisses overlay → language change sequence → rebuilds app |
| Double-tap during change | Ignored (_isBusy lock prevents) |
| Widget disposed during change | Safe (mounted checks prevent errors) |

### Overlay Positioning Logic

```dart
// Get button position
final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
final buttonSize = renderBox.size;
final buttonPosition = renderBox.localToGlobal(Offset.zero);

// Position overlay
Positioned(
  left: buttonPosition.dx,
  top: buttonPosition.dy + (widget.height ?? 0) + _overlayGapFromButton,
  child: _buildOverlayContent(context, buttonWidth),
)
```

The overlay is inserted into the root `Overlay` widget, ensuring it appears above all other content.

---

## Usage Examples

### Example 1: Language & Currency Settings Page

**File:** `_flutterflow_export/lib/app_settings/language_and_currency/language_and_currency_widget.dart`

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// Inside widget tree:
Container(
  width: double.infinity,
  height: 49.0,
  child: custom_widgets.LanguageSelectorButton(
    width: double.infinity,
    height: 49.0,
    translationsCache: FFAppState().translationsCache,
  ),
),
```

**Context:**
- Full-width button (matches screen width minus padding)
- Fixed height of 49px for consistent sizing
- Displays below heading "Set your preferred language for the app"
- Part of a vertical column with currency selector below

### Example 2: App Settings Initiate Flow (Onboarding)

**File:** `_flutterflow_export/lib/initiate_flow/app_settings_initiate_flow/app_settings_initiate_flow_widget.dart`

```dart
Container(
  width: double.infinity,
  height: 49.0,
  child: custom_widgets.LanguageSelectorButton(
    width: double.infinity,
    height: 49.0,
    translationsCache: FFAppState().translationsCache,
  ),
),
```

**Context:**
- Used during first-run onboarding
- Appears after welcome screen
- User sets language before seeing main app content

### Example 3: Dynamic Width (Flexible Layout)

```dart
// Button adapts to available space
custom_widgets.LanguageSelectorButton(
  width: null,  // or omit parameter
  height: 49.0,
  translationsCache: FFAppState().translationsCache,
),
```

**Behavior:** Button uses intrinsic width based on content (flag + language name + chevron icon).

---

## Error Handling

### Language Change Errors

**Scenario:** Network failure, API error, or invalid language code during change sequence.

**Handling:**
```dart
try {
  // Language change sequence...
} catch (e) {
  debugPrint('❌ Error changing language: $e');

  // Attempt rollback
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ff_language', currentLanguageCode);
    setAppLanguage(context, currentLanguageCode);
  } catch (_) {}
} finally {
  _isBusy = false;
}
```

**Rollback Logic:**
1. Restores previous language code to SharedPreferences
2. Calls `setAppLanguage()` to revert locale
3. Silently fails if rollback itself fails (prevents infinite error loops)
4. Always unlocks `_isBusy` in finally block

**User Experience:**
- Language remains unchanged if error occurs
- No error dialog shown (silent failure)
- User can try again immediately

### Analytics Errors

**Scenario:** Analytics tracking fails (network issue, backend unavailable).

**Handling:**
```dart
trackAnalyticsEvent('language_changed', {...})
  .catchError((error) {
    debugPrint('⚠️ Failed to track language change: $error');
  });
```

**Behavior:** Error logged to console but does not interrupt language change operation.

### Missing Translation Keys

**Scenario:** A language name translation key doesn't exist in `translationsCache`.

**Handling:**
```dart
String _getNativeLanguageName(String languageCode) {
  const nativeNames = {
    'da': 'Dansk',
    // ...
  };
  return nativeNames[languageCode] ?? languageCode.toUpperCase();
}
```

**Fallback:** If native name not found, displays uppercase language code (e.g., `'DA'`).

### Overlay Positioning Errors

**Scenario:** Button context not available when trying to open overlay.

**Handling:**
```dart
final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
if (renderBox == null) return;  // Early exit, no overlay shown
```

**Behavior:** Overlay fails to open silently. User can try again.

---

## Testing Checklist

### Functional Testing

- [ ] **Display Current Language**
  - [ ] Button shows correct flag emoji for current language
  - [ ] Button shows correct native language name
  - [ ] Chevron points down when overlay closed

- [ ] **Open Overlay**
  - [ ] Tapping button opens overlay
  - [ ] Overlay positioned 4px below button
  - [ ] Overlay matches button width
  - [ ] All 7 active languages displayed in correct order
  - [ ] Chevron points up when overlay open

- [ ] **Close Overlay**
  - [ ] Tapping outside overlay dismisses it
  - [ ] Tapping same language dismisses overlay without action
  - [ ] Chevron returns to down position

- [ ] **Language Change - Success**
  - [ ] Tapping different language dismisses overlay
  - [ ] Language persists to SharedPreferences
  - [ ] App locale updates immediately
  - [ ] All UI text updates to new language
  - [ ] Currency updates to match language region
  - [ ] Filter labels update to new language
  - [ ] Analytics event fires with correct properties

- [ ] **Language Change - Each Language**
  - [ ] Danish (da): 🇩🇰 Dansk
  - [ ] English (en): 🇬🇧 English
  - [ ] German (de): 🇩🇪 Deutsch
  - [ ] Swedish (sv): 🇸🇪 Svenska
  - [ ] Norwegian (no): 🇳🇴 Norsk
  - [ ] Italian (it): 🇮🇹 Italiano
  - [ ] French (fr): 🇫🇷 Français

- [ ] **Double-Tap Prevention**
  - [ ] Double-tapping button doesn't create multiple overlays
  - [ ] Tapping multiple languages rapidly processes only one
  - [ ] Button disabled (_isBusy) during language change

- [ ] **Error Handling**
  - [ ] Network failure during translation fetch: language reverts
  - [ ] Invalid language code: language reverts
  - [ ] Analytics failure: doesn't block language change

### UI/UX Testing

- [ ] **Visual Consistency**
  - [ ] Button background color matches design (#F2F3F5)
  - [ ] Overlay background matches button
  - [ ] Font sizes and weights correct
  - [ ] Spacing consistent with design system

- [ ] **Responsive Behavior**
  - [ ] Button width respects `width` parameter
  - [ ] Overlay width matches button width
  - [ ] Layout works on narrow screens (320px+)
  - [ ] Layout works on wide screens (tablet)

- [ ] **Animation & Transitions**
  - [ ] Overlay appears instantly (no animation)
  - [ ] Chevron icon switches up/down smoothly
  - [ ] Language change feels responsive (parallel fetches)

### Integration Testing

- [ ] **Language & Currency Settings Page**
  - [ ] Widget displays correctly
  - [ ] Full-width button (double.infinity)
  - [ ] 49px height matches design
  - [ ] Currency selector updates when language changes

- [ ] **App Settings Initiate Flow**
  - [ ] Widget appears during onboarding
  - [ ] Language selection persists through onboarding
  - [ ] Main app loads with selected language

- [ ] **App Restart**
  - [ ] Selected language persists after app restart
  - [ ] SharedPreferences correctly restored

- [ ] **State Management**
  - [ ] FFAppState().translationsCache updates after change
  - [ ] context.watch<FFAppState>() triggers rebuilds
  - [ ] All pages update without requiring navigation

### Edge Cases

- [ ] **Rapid Interactions**
  - [ ] Tapping button repeatedly doesn't break overlay
  - [ ] Switching languages back and forth works correctly

- [ ] **Widget Lifecycle**
  - [ ] Overlay dismisses if widget disposed
  - [ ] No memory leaks from overlay entries
  - [ ] Mounted checks prevent setState errors

- [ ] **Missing Data**
  - [ ] Unknown language code shows uppercase code as fallback
  - [ ] Missing flag emoji shows 🌐 as fallback
  - [ ] Empty translationsCache doesn't crash

- [ ] **Network Conditions**
  - [ ] Slow network: language change waits for completion
  - [ ] Offline: language change fails gracefully
  - [ ] Timeout: language reverts to previous

---

## Migration Notes

### Phase 3 Migration Requirements

#### 1. State Management Migration (Riverpod)

**Current (FlutterFlow):**
```dart
context.watch<FFAppState>();
FFAppState().translationsCache;
FFAppState().update(() {});
```

**Phase 3 (Riverpod):**
```dart
final translationsCache = ref.watch(translationsCacheProvider);
ref.read(translationsCacheProvider.notifier).update(...);
```

**Migration Steps:**
1. Create `translationsCacheProvider` in `lib/providers/app_state_providers.dart`
2. Replace `context.watch<FFAppState>()` with `ref.watch(translationsCacheProvider)`
3. Replace `FFAppState().update(() {})` with provider notifications
4. Convert widget to `ConsumerStatefulWidget`

#### 2. SharedPreferences Migration

**Consider:** Move from direct SharedPreferences access to a repository pattern.

**Suggested Pattern:**
```dart
// lib/repositories/language_repository.dart
class LanguageRepository {
  Future<void> saveLanguageCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ff_language', code);
  }

  Future<String?> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ff_language');
  }
}
```

#### 3. Custom Actions Migration

**FlutterFlow Actions to Port:**
```dart
// Current:
await getTranslationsWithUpdate(languageCode);
await getFiltersWithUpdate(languageCode);
await updateCurrencyForLanguage(languageCode);

// Phase 3: Move to services
final translationService = ref.read(translationServiceProvider);
await translationService.fetchTranslations(languageCode);

final filterService = ref.read(filterServiceProvider);
await filterService.fetchFilters(languageCode);

final currencyService = ref.read(currencyServiceProvider);
await currencyService.updateForLanguage(languageCode);
```

#### 4. Analytics Migration

**Current:**
```dart
import '/custom_code/actions/index.dart';
trackAnalyticsEvent('language_changed', {...});
```

**Phase 3:**
```dart
import 'package:journeymate/services/analytics_service.dart';
final analytics = ref.read(analyticsServiceProvider);
analytics.trackLanguageChange(from: '...', to: '...');
```

#### 5. Localization System Migration

**Current (FlutterFlow):**
```dart
FFLocalizations.of(context).languageCode;
setAppLanguage(context, languageCode);
```

**Phase 3 (flutter_localizations + custom):**
```dart
import 'package:flutter_localizations/flutter_localizations.dart';

// Option A: Use Locale directly
Localizations.localeOf(context).languageCode;

// Option B: Use custom LocaleProvider
final locale = ref.read(localeProvider);
ref.read(localeProvider.notifier).setLocale(Locale(languageCode));
```

#### 6. Testing Migration

**Add Widget Tests:**
```dart
// test/widgets/language_selector_button_test.dart
void main() {
  testWidgets('displays current language', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationsCacheProvider.overrideWith((ref) => mockCache),
        ],
        child: MaterialApp(
          home: LanguageSelectorButton(
            width: 200,
            height: 49,
          ),
        ),
      ),
    );

    expect(find.text('🇬🇧  English'), findsOneWidget);
  });
}
```

#### 7. Code Quality Improvements

**Suggested Improvements for Phase 3:**

1. **Extract Language Metadata to Separate File**
   ```dart
   // lib/models/language_metadata.dart
   class LanguageMetadata {
     final String flag;
     final bool isActive;
     final int displayOrder;

     const LanguageMetadata({...});
   }
   ```

2. **Use Enum for Language Codes**
   ```dart
   enum LanguageCode {
     da('da', '🇩🇰', 'Dansk'),
     en('en', '🇬🇧', 'English'),
     // ...

     final String code;
     final String flag;
     final String nativeName;
   }
   ```

3. **Separate Overlay into Own Widget**
   ```dart
   class _LanguageSelectorOverlay extends StatelessWidget {
     // Cleaner separation of concerns
   }
   ```

4. **Add Loading State**
   ```dart
   bool _isChangingLanguage = false;

   // Show loading indicator during language change
   if (_isChangingLanguage)
     CircularProgressIndicator()
   ```

#### 8. Breaking Changes to Consider

**None.** The widget API can remain the same. Only internal implementation changes for state management.

**Deprecation Path:**
1. Add `@Deprecated` annotations to FlutterFlow-specific parameters
2. Add new `onLanguageChanged` callback parameter for reactive updates
3. Phase out `translationsCache` parameter in favor of provider access

---

## File Dependencies

### Modified Files During Language Change
```
SharedPreferences:
  - ff_language (String)

FFAppState:
  - translationsCache (updated by getTranslationsWithUpdate)
  - filtersCache (updated by getFiltersWithUpdate)
  - selectedCurrency (updated by updateCurrencyForLanguage)
  - user_language_code (updated by saveUserPreference)
```

### Related Documentation
- `MASTER_README_get_translations_with_update.md` - Translation fetching logic
- `MASTER_README_update_currency_for_language.md` - Currency update logic
- `MASTER_README_get_filters_with_update.md` - Filter fetching logic
- `MASTER_README_currency_selector_button.md` - Companion widget

---

## Architecture Notes

### Design Decisions

1. **Overlay vs. Modal Bottom Sheet**
   - **Chosen:** Overlay with Positioned widget
   - **Rationale:** Better control over positioning, no route push, faster dismiss

2. **Parallel Fetching (Future.wait)**
   - **Chosen:** Fetch translations and filters simultaneously
   - **Rationale:** Reduces total wait time by ~50% (network-bound operations)

3. **Fire-and-Forget Analytics**
   - **Chosen:** No await on analytics calls
   - **Rationale:** Analytics failure should not block user action

4. **Rollback on Error**
   - **Chosen:** Attempt to restore previous language
   - **Rationale:** Better UX than leaving app in partial state

5. **Native Language Names (Not Translated)**
   - **Chosen:** Always show "Deutsch" for German, not "German"/"Tysk"
   - **Rationale:** Users searching for their language recognize native name better

### Performance Considerations

**Optimization 1: Parallel Fetching**
```dart
await Future.wait([
  getTranslationsWithUpdate(lc),
  getFiltersWithUpdate(lc),
]);
```
Saves ~500ms compared to sequential fetching.

**Optimization 2: Busy Lock**
```dart
if (_isBusy) return;
_isBusy = true;
```
Prevents redundant API calls from double-taps.

**Optimization 3: Early Exit for Same Language**
```dart
if (newLanguageCode == currentLanguageCode) {
  _isBusy = false;
  return;
}
```
Avoids unnecessary work when user taps current language.

---

## Known Issues / Limitations

### Issue 1: No Loading Indicator
**Description:** User gets no visual feedback during language change (can take 1-3 seconds).

**Workaround:** None currently.

**Phase 3 Fix:** Add loading indicator or disable button during change.

### Issue 2: No Error Toast/Dialog
**Description:** If language change fails, user has no feedback. Language silently remains unchanged.

**Workaround:** User can try again.

**Phase 3 Fix:** Show snackbar on error: "Unable to change language. Please try again."

### Issue 3: Hardcoded Overlay Width
**Description:** Overlay always matches button width, even if content is narrower.

**Impact:** Minor. Looks fine in practice.

**Phase 3 Fix:** Use `IntrinsicWidth` for overlay if desired.

### Issue 4: No Keyboard Support
**Description:** Overlay cannot be navigated with keyboard (accessibility issue).

**Phase 3 Fix:** Implement focus management and arrow key navigation.

---

## Change History

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-19 | 1.0 | Initial documentation from FlutterFlow export |

---

## Questions for Product Team

1. **Inactive Languages:** When will Spanish, Finnish, etc. be activated? Do we have translations ready?
2. **Currency Mapping:** Is the `updateCurrencyForLanguage()` logic correct for all language/region mappings?
3. **Loading UX:** Should we add a loading spinner during language change, or is instant (no feedback) preferred?
4. **Error UX:** Should errors be silent, or show a snackbar/toast?
5. **Analytics:** Are the current properties sufficient, or do we need additional metadata (device locale, timestamp, etc.)?

---

**End of Documentation**
