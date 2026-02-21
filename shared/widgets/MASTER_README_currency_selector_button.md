# CurrencySelectorButton Widget Documentation

**FlutterFlow Source:** `_flutterflow_export/lib/custom_code/widgets/currency_selector_button.dart`
**Migration Target:** `journey_mate/lib/widgets/currency_selector_button.dart` (COMPLETED)
**Test Coverage:** `journey_mate/test/widgets/currency_selector_button_test.dart` (COMPLETED)
**Last Updated:** 2026-02-19

---

## Purpose

A custom stateful widget that displays the currently selected currency and opens an overlay selector on tap. The widget provides language-aware currency selection with automatic currency updates when language changes, exchange rate integration, and analytics tracking.

**Key Features:**
- Displays currency name and symbol (e.g., "Danish Krone (kr.)")
- Opens overlay with available currencies for current language
- Updates AppState.userCurrencyCode on selection
- Fetches exchange rates via updateCurrencyWithExchangeRate action
- Automatically updates currency when language changes (smart fallback logic)
- Overlay dismisses on selection or outside tap
- Smart positioning with 4px gap between button and overlay
- Analytics tracking for currency changes
- User engagement marking

---

## Function Signature

```dart
class CurrencySelectorButton extends StatefulWidget {
  const CurrencySelectorButton({
    super.key,
    this.width,
    this.height,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final dynamic translationsCache;

  @override
  State<CurrencySelectorButton> createState() => _CurrencySelectorButtonState();
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `translationsCache` | `dynamic` | Translation cache from AppState (or FFAppState), used to retrieve localized currency names via `getTranslations()` function |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `double?` | `null` | Width of the button container. If null, uses constraints from parent |
| `height` | `double?` | `null` | Height of the button container. If null, uses constraints from parent |
| `key` | `Key?` | `null` | Widget key for testing and identification |

### Typical Usage Values

From FlutterFlow export:
```dart
CurrencySelectorButton(
  width: double.infinity,  // Full width in Language & Currency settings page
  height: 49.0,           // Standard button height (matches LanguageSelectorButton)
  translationsCache: FFAppState().translationsCache,
)
```

---

## Dependencies

### State Dependencies

**AppState (or FFAppState):**
- `userCurrencyCode` (String) - Currently selected currency code (e.g., "DKK", "EUR")
- `translationsCache` (dynamic) - Translation cache for localized currency names
- `exchangeRate` (double?) - Current exchange rate (updated via custom action)
- `userLanguageCode` (String) - Current language code (for smart currency fallback)

### Custom Actions

**updateCurrencyWithExchangeRate(String newCurrencyCode)**
- Updates `AppState.userCurrencyCode` to new currency
- Triggers exchange rate API call (configured in FlutterFlow)
- Updates `AppState.exchangeRate` with latest rate
- Returns `bool` indicating success/failure

**markUserEngaged()**
- Marks user as engaged in current session
- Used for analytics and session tracking
- No parameters, no return value

**trackAnalyticsEvent(String eventName, Map<String, String> properties)**
- Tracks analytics events to backend
- Returns `Future<void>`
- Event: `'currency_changed'` with properties:
  - `from_currency`: Previous currency code
  - `to_currency`: New currency code
  - `language`: Current language code

### Custom Functions

**getCurrencyFormattingRules(String currencyCode)**
- Returns JSON string with currency formatting rules
- Format: `{"symbol": "kr.", "isPrefix": false, "decimals": 0}`
- Returns `null` if currency code not found
- Location: `flutter_flow/custom_functions.dart`

**getTranslations(String languageCode, String key, dynamic translationsCache)**
- Retrieves localized string from translation cache
- Returns translated string or fallback value
- Location: `shared/internationalization.dart`

### Flutter/Dart Packages

```dart
import 'dart:convert';           // For JSON parsing (currency formatting rules)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // For context.watch<AppState>()
```

### Internal Dependencies

**Localization System:**
- `FFLocalizations.of(context).languageCode` - Gets current language code
- Fallback to `AppState.userLanguageCode` if FFLocalizations not available

---

## FFAppState Usage

### State Variables Read

```dart
// Current currency code (empty string defaults to 'DKK')
FFAppState().userCurrencyCode

// Translation cache (passed as widget parameter)
FFAppState().translationsCache

// Current language code (via FFLocalizations or AppState)
FFLocalizations.of(context).languageCode
```

### State Variables Modified

```dart
// Updated via updateCurrencyWithExchangeRate action:
FFAppState().userCurrencyCode   // Set to new currency code
FFAppState().exchangeRate       // Set to latest exchange rate from API
```

### State Change Triggers

| Action | State Change | Side Effects |
|--------|--------------|--------------|
| Tap overlay currency option | Updates `userCurrencyCode` | Fetches exchange rate, tracks analytics, marks user engaged |
| Language change detected | Updates `userCurrencyCode` (if needed) | Fetches exchange rate for new currency |
| Widget build with empty currency | Uses default 'DKK' | Display only, no state modification |

---

## Translation Keys

The widget uses translation keys to display localized currency names. Keys follow the pattern:

```
currency_{code}_cap
```

### Required Translation Keys by Currency

| Currency Code | Translation Key | Example (Danish) | Example (English) |
|---------------|-----------------|------------------|-------------------|
| DKK | `currency_dkk_cap` | "Danske kroner" | "Danish Krone" |
| EUR | `currency_eur_cap` | "Euro" | "Euro" |
| GBP | `currency_gbp_cap` | "Britiske pund" | "British Pound" |
| USD | `currency_usd_cap` | "Amerikanske dollars" | "US Dollar" |
| SEK | `currency_sek_cap` | "Svenske kroner" | "Swedish Krona" |
| NOK | `currency_nok_cap` | "Norske kroner" | "Norwegian Krone" |
| PLN | `currency_pln_cap` | "Polske złoty" | "Polish Złoty" |

### Translation Retrieval

```dart
String _getCurrencyName(BuildContext context, String currencyCode) {
  final languageCode = _getCurrentLanguageCode(context);
  final key = 'currency_${currencyCode.toLowerCase()}_cap';
  return getTranslations(languageCode, key, widget.translationsCache);
}
```

### Fallback Behavior

If translation not found:
- Returns empty string or string starting with '⚠️'
- Widget displays: `"{CODE} ({SYMBOL})"` (e.g., "DKK (kr.)")

---

## Analytics Events

### currency_changed

**Event Name:** `'currency_changed'`

**When Triggered:**
- User selects a different currency from overlay
- Only triggered if new currency differs from current

**Event Properties:**

| Property | Type | Description | Example |
|----------|------|-------------|---------|
| `from_currency` | String | Previous currency code | "DKK" |
| `to_currency` | String | Newly selected currency code | "EUR" |
| `language` | String | Current language code | "da" |

**Implementation:**

```dart
await trackAnalyticsEvent(
  'currency_changed',
  {
    'from_currency': currentCurrency,
    'to_currency': newCurrencyCode,
    'language': _getCurrentLanguageCode(context),
  },
).catchError((error) {
  debugPrint('⚠️ Failed to track currency change: $error');
});
```

**Error Handling:**
- Errors caught and logged via `debugPrint`
- Failed analytics tracking does not prevent currency change
- Widget continues normal operation

---

## State Management

### Local State Variables

```dart
class _CurrencySelectorButtonState extends State<CurrencySelectorButton> {
  /// Global key to get button position for overlay placement
  final GlobalKey _buttonKey = GlobalKey();

  /// Tracks overlay entry for manual dismissal
  OverlayEntry? _overlayEntry;

  /// Tracks if overlay is currently visible
  bool _isOverlayVisible = false;

  /// Tracks the last known language to detect changes
  String? _lastKnownLanguage;
}
```

### Language Change Detection

The widget monitors language changes in the `build()` method:

```dart
@override
Widget build(BuildContext context) {
  context.watch<AppState>();
  final currentLanguageCode = _getCurrentLanguageCode(context);

  // Check if language has changed since last build
  if (_lastKnownLanguage != null && _lastKnownLanguage != currentLanguageCode) {
    // Update currency for new language asynchronously
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrencyForLanguageChange(currentLanguageCode);
    });
  }

  // Update last known language
  _lastKnownLanguage = currentLanguageCode;

  // ... build UI
}
```

### Smart Currency Update Logic

When language changes, the widget applies smart fallback logic:

**Algorithm:**
1. Get current currency code
2. Get available currencies for new language
3. **If** current currency is available in new language → **keep it**
4. **Otherwise** → switch to default currency for that language

**Example Scenarios:**

| Scenario | Current Currency | New Language | Available Currencies | Result | Reason |
|----------|------------------|--------------|---------------------|--------|--------|
| Danish → English | DKK | en | DKK, EUR, GBP, SEK, NOK, PLN, USD | **DKK** (kept) | DKK available in English |
| English → Danish | USD | da | DKK, EUR, GBP, SEK, NOK, PLN, USD | **USD** (kept) | USD available in Danish |
| German → Danish | EUR | da | DKK, EUR, GBP, SEK, NOK, PLN, USD | **EUR** (kept) | EUR available in Danish |

**Implementation:**

```dart
String _determineTargetCurrency({
  required String currentCurrency,
  required List<String> availableCodes,
  required String languageCode,
}) {
  // Check if current currency is available
  if (availableCodes.contains(currentCurrency)) {
    return currentCurrency;
  }

  // Fall back to default currency for this language
  return _getDefaultCurrencyForLanguage(languageCode);
}
```

---

## Currency Configuration

### Available Currencies by Language

**FlutterFlow Original Configuration:**

```dart
// From FlutterFlow export - language-specific currencies
const currencyOptions = {
  'en': ['USD', 'GBP', 'DKK'],
  'de': ['EUR', 'DKK'],
  'sv': ['SEK', 'DKK'],
  'no': ['NOK', 'DKK'],
  'it': ['EUR', 'DKK'],
  'fr': ['EUR', 'DKK'],
  'da': ['DKK'],
  'es': ['EUR', 'DKK'],
  'fi': ['EUR', 'DKK'],
  'nl': ['EUR', 'DKK'],
  'pl': ['PLN', 'EUR', 'DKK'],
  'uk': ['UAH', 'EUR', 'DKK'],
  'ja': ['JPY', 'USD', 'DKK'],
  'ko': ['KRW', 'USD', 'DKK'],
  'zh': ['CNY', 'USD', 'DKK'],
};
```

**Migration Update - Universal Currency Support:**

```dart
// From migrated version - all languages support same currencies
List<String> _getCurrenciesForLanguage(String languageCode) {
  // All languages now support the same set of currencies
  return ['DKK', 'EUR', 'GBP', 'SEK', 'NOK', 'PLN', 'USD'];
}
```

**Note:** The migration expanded currency support to be uniform across all languages, allowing users to select any major currency regardless of language.

### Default Currencies by Language

```dart
String _getDefaultCurrencyForLanguage(String languageCode) {
  const defaults = {
    'da': 'DKK',   // Danish → Danish Krone
    'en': 'GBP',   // English → British Pound (migrated from USD)
    'de': 'EUR',   // German → Euro
    'sv': 'SEK',   // Swedish → Swedish Krona
    'no': 'NOK',   // Norwegian → Norwegian Krone
    'pl': 'PLN',   // Polish → Polish Złoty
    'es': 'EUR',   // Spanish → Euro
  };

  return defaults[languageCode] ?? 'DKK';
}
```

**Fallback:** If language not in map, defaults to `'DKK'`

### Currency Formatting Rules

Extracted via `getCurrencyFormattingRules()` custom function:

| Currency Code | Symbol | Is Prefix? | Decimals | Example Display |
|---------------|--------|------------|----------|-----------------|
| CNY | ¥ | true | 0 | ¥150 |
| DKK | kr. | false | 0 | 150 kr. |
| EUR | € | true | 2 | €15.50 |
| GBP | £ | true | 1 | £15.5 |
| JPY | ¥ | false | 0 | 150¥ |
| KRW | ₩ | false | 0 | 15000₩ |
| NOK | kr. | false | 0 | 150 kr. |
| PLN | zł | false | 0 | 150 zł |
| SEK | kr. | false | 0 | 150 kr. |
| UAH | ₴ | false | 0 | 150₴ |
| USD | $ | true | 2 | $15.50 |

**Display Format in Widget:**
```
{Currency Name} ({Symbol})

Examples:
- Danish Krone (kr.)
- Euro (€)
- British Pound (£)
```

---

## UI Structure

### Button Layout

```
┌─────────────────────────────────────────┐
│  Danish Krone (kr.)              ▼      │  ← Closed state
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Danish Krone (kr.)              ▲      │  ← Open state
└─────────────────────────────────────────┘
    │ 4px gap
    ▼
┌─────────────────────────────────────────┐
│  Danish Krone (kr.)                     │
│  Euro (€)                               │
│  British Pound (£)                      │
│  Swedish Krona (kr.)                    │
│  Norwegian Krone (kr.)                  │
│  Polish Złoty (zł)                      │
│  US Dollar ($)                          │
└─────────────────────────────────────────┘
```

### Button Styling

```dart
// Button container
Color: #F2F3F5 (light gray)
Border radius: 8.0
Padding: 12.0 (horizontal), 8.0 (vertical)

// Button text
Color: #14181B (dark gray)
Font size: 14.0
Font weight: FontWeight.w300 (light)

// Button icon (arrow)
Color: #57636C (medium gray)
Size: 24.0
Icon: keyboard_arrow_down_rounded (closed)
      keyboard_arrow_up_rounded (open)
```

### Overlay Styling

```dart
// Overlay container
Color: #F2F3F5 (matches button)
Border radius: 8.0
Padding: 12.0 (left/right), 4.0 (top/bottom)
Shadow: Color(0x33000000), blur: 4.0, spread: 1.0, offset: (0, 2)

// Overlay items
Color: #14181B (dark gray)
Font size: 14.0
Font weight: FontWeight.w300
Padding: 4.0 (left), 12.0 (top/bottom)

// Positioning
Gap from button: 4.0
Width: Same as button width
Position: Below button, aligned to left edge
```

### Overlay Positioning Logic

```dart
void _showOverlay(BuildContext context) {
  final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;

  final buttonSize = renderBox.size;
  final buttonPosition = renderBox.localToGlobal(Offset.zero);

  _overlayEntry = OverlayEntry(
    builder: (overlayContext) => Stack(
      children: [
        // Invisible barrier to detect outside taps
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismissOverlay,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Currency selection overlay
        Positioned(
          left: buttonPosition.dx,
          top: buttonPosition.dy + (widget.height ?? 0) + 4.0,  // 4px gap
          child: _buildOverlayContent(context, buttonSize.width),
        ),
      ],
    ),
  );

  Overlay.of(context).insert(_overlayEntry!);
  setState(() => _isOverlayVisible = true);
}
```

---

## Usage Examples

### Example 1: Language & Currency Settings Page (FlutterFlow)

```dart
// From: app_settings/language_and_currency/language_and_currency_widget.dart
// Line: 320-325

SizedBox(
  width: double.infinity,
  height: 49.0,
  child: custom_widgets.CurrencySelectorButton(
    width: double.infinity,
    height: 49.0,
    translationsCache: FFAppState().translationsCache,
  ),
),
```

**Context:**
- Full-width button in settings page
- Placed below LanguageSelectorButton
- Part of a column with 40.0 spacing between items
- Same height as LanguageSelectorButton for visual consistency

### Example 2: Initiate Flow App Settings (FlutterFlow)

```dart
// From: initiate_flow/app_settings_initiate_flow/app_settings_initiate_flow_widget.dart
// Similar usage in onboarding flow

SizedBox(
  width: double.infinity,
  height: 49.0,
  child: custom_widgets.CurrencySelectorButton(
    width: double.infinity,
    height: 49.0,
    translationsCache: FFAppState().translationsCache,
  ),
),
```

**Context:**
- Used in onboarding/initiate flow
- Same dimensions and styling as settings page
- Allows currency selection before user completes onboarding

### Example 3: Migrated Pure Flutter Version

```dart
// From: journey_mate/lib/widgets/currency_selector_button.dart
// Usage in a settings page:

import 'package:journey_mate/widgets/currency_selector_button.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Column(
      children: [
        // Language selector...

        SizedBox(height: 40),

        // Currency selector
        CurrencySelectorButton(
          width: double.infinity,
          height: 49.0,
          translationsCache: appState.translationsCache,
        ),
      ],
    );
  }
}
```

**Migration Changes:**
- Uses `AppState` instead of `FFAppState`
- Same parameters and behavior
- Updated import paths
- Compatible with Provider state management

### Example 4: Custom Width/Height

```dart
// Compact version for toolbar or header
CurrencySelectorButton(
  width: 180.0,   // Fixed width
  height: 36.0,   // Compact height
  translationsCache: appState.translationsCache,
)

// Flexible width with constraints
ConstrainedBox(
  constraints: BoxConstraints(
    minWidth: 150.0,
    maxWidth: 300.0,
  ),
  child: CurrencySelectorButton(
    height: 40.0,
    translationsCache: appState.translationsCache,
  ),
)
```

### Example 5: Testing Setup

```dart
// From: journey_mate/test/widgets/currency_selector_button_test.dart

Widget createTestWidget({
  double? width,
  double? height,
  String? initialLanguage,
  String? initialCurrency,
}) {
  final appState = AppState();

  if (initialLanguage != null) {
    appState.userLanguageCode = initialLanguage;
  }
  if (initialCurrency != null) {
    appState.userCurrencyCode = initialCurrency;
  }

  return ChangeNotifierProvider<AppState>.value(
    value: appState,
    child: MaterialApp(
      localizationsDelegates: const [
        FFLocalizationsDelegate(),
      ],
      supportedLocales: const [
        Locale('da'),
        Locale('en'),
        Locale('de'),
        // ... other locales
      ],
      locale: Locale(initialLanguage ?? 'da'),
      home: Scaffold(
        body: Center(
          child: CurrencySelectorButton(
            width: width ?? 200,
            height: height ?? 40,
            translationsCache: <String, dynamic>{},
          ),
        ),
      ),
    ),
  );
}

// Usage in tests:
testWidgets('renders with current currency label', (WidgetTester tester) async {
  await tester.pumpWidget(createTestWidget());
  await tester.pumpAndSettle();

  expect(find.text('DKK (kr.)'), findsOneWidget);
});
```

---

## Error Handling

### Currency Selection Errors

**Scenario:** Exchange rate API call fails during currency selection

```dart
try {
  final success = await updateCurrencyWithExchangeRate(newCurrencyCode);

  if (!success) {
    debugPrint('⚠️ Failed to update currency to: $newCurrencyCode');
  }

  if (mounted) {
    setState(() {});
  }
} catch (e) {
  debugPrint('❌ Error in currency selection: $e');
  // Widget will continue showing previous currency on error
}
```

**Behavior:**
- Overlay dismissed immediately (responsive UX)
- Error logged to console
- Widget continues showing previous currency
- No error UI shown to user (graceful degradation)

### Language Change Errors

**Scenario:** Exchange rate API call fails during language change

```dart
try {
  // Determine target currency...

  if (newCurrency != currentCurrency) {
    final success = await updateCurrencyWithExchangeRate(newCurrency);

    if (!success) {
      debugPrint('⚠️ Failed to update currency for language: $newLanguageCode');
    }

    if (mounted) {
      setState(() {});
    }
  }
} catch (e) {
  debugPrint('❌ Error updating currency for language change: $e');
  // Fallback to DKK on error
  await updateCurrencyWithExchangeRate('DKK');
}
```

**Behavior:**
- Error logged to console
- Falls back to DKK (default currency)
- Widget continues to function
- Second API call made for fallback (DKK)

### Analytics Tracking Errors

**Scenario:** Analytics backend unavailable

```dart
await trackAnalyticsEvent(
  'currency_changed',
  {
    'from_currency': currentCurrency,
    'to_currency': newCurrencyCode,
    'language': _getCurrentLanguageCode(context),
  },
).catchError((error) {
  debugPrint('⚠️ Failed to track currency change: $error');
});
```

**Behavior:**
- Error caught and logged
- Currency change proceeds normally
- No impact on user experience
- Analytics failure is non-blocking

### Translation Missing

**Scenario:** Translation key not found in cache

```dart
String _getCurrencyDisplayLabel(BuildContext context, String currencyCode) {
  final currencyName = _getCurrencyName(context, currencyCode);
  final currencySymbol = _getCurrencySymbol(currencyCode);

  // If translation not found, use code as fallback
  if (currencyName.isEmpty || currencyName.startsWith('⚠️')) {
    return '$currencyCode ($currencySymbol)';
  }

  return '$currencyName ($currencySymbol)';
}
```

**Behavior:**
- Falls back to currency code (e.g., "DKK (kr.)")
- Widget continues to display and function
- Symbol still retrieved from formatting rules

### Overlay Positioning Errors

**Scenario:** Button not yet rendered when overlay requested

```dart
void _showOverlay(BuildContext context) {
  if (_isOverlayVisible) return;

  final renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
  if (renderBox == null) return;  // Early exit if button not rendered

  // ... proceed with overlay creation
}
```

**Behavior:**
- Early exit if button not rendered
- No error thrown
- User can tap again once button is rendered

### Widget Disposal During Async Operation

**Scenario:** Widget disposed while currency update in progress

```dart
if (mounted) {
  setState(() {});
}
```

**Behavior:**
- Checks `mounted` flag before calling `setState()`
- Prevents "setState called after dispose" error
- Graceful cleanup in disposal method

```dart
@override
void dispose() {
  _dismissOverlay();  // Clean up overlay if open
  super.dispose();
}
```

---

## Testing Checklist

### Unit Tests

- [ ] **Widget Creation**
  - [ ] Creates with all required parameters
  - [ ] Creates with optional width/height parameters
  - [ ] Creates without optional parameters (null handling)

- [ ] **Display Tests**
  - [ ] Displays current currency label correctly
  - [ ] Displays currency symbol correctly (for each supported currency)
  - [ ] Falls back to currency code when translation missing
  - [ ] Shows correct icon (down arrow when closed, up arrow when open)
  - [ ] Respects width and height parameters

- [ ] **Default Behavior**
  - [ ] Shows 'DKK' by default if userCurrencyCode is empty
  - [ ] Uses effective currency code logic correctly

- [ ] **Overlay Tests**
  - [ ] Opens overlay on button tap
  - [ ] Closes overlay on outside tap
  - [ ] Closes overlay after currency selection
  - [ ] Does not re-open overlay when already visible
  - [ ] Overlay positioned 4px below button
  - [ ] Overlay matches button width
  - [ ] Overlay contains correct currencies for current language

- [ ] **Language-Specific Currency Lists**
  - [ ] Danish: DKK, EUR, GBP, SEK, NOK, PLN, USD
  - [ ] English: DKK, EUR, GBP, SEK, NOK, PLN, USD
  - [ ] German: DKK, EUR, GBP, SEK, NOK, PLN, USD
  - [ ] Swedish: DKK, EUR, GBP, SEK, NOK, PLN, USD
  - [ ] Norwegian: DKK, EUR, GBP, SEK, NOK, PLN, USD
  - [ ] Polish: DKK, EUR, GBP, SEK, NOK, PLN, USD

- [ ] **Currency Change Tests**
  - [ ] Calls updateCurrencyWithExchangeRate on selection
  - [ ] Calls markUserEngaged on selection
  - [ ] Tracks analytics event with correct properties
  - [ ] Skips update if selecting same currency
  - [ ] Rebuilds widget after currency change
  - [ ] Handles API call failure gracefully

- [ ] **Language Change Tests**
  - [ ] Detects language change in build method
  - [ ] Keeps current currency if available in new language
  - [ ] Switches to default currency if current not available
  - [ ] Updates display after language change
  - [ ] Handles API call failure during language change

- [ ] **Cleanup Tests**
  - [ ] Cleans up overlay on widget disposal
  - [ ] No errors when disposing with overlay open
  - [ ] No setState after dispose errors

### Integration Tests

- [ ] **With AppState**
  - [ ] Reads userCurrencyCode from AppState
  - [ ] Updates userCurrencyCode via custom action
  - [ ] Watches AppState for changes
  - [ ] Reads userLanguageCode from AppState

- [ ] **With Translation System**
  - [ ] Retrieves currency names from translation cache
  - [ ] Handles missing translations gracefully
  - [ ] Updates display when language changes

- [ ] **With Custom Actions**
  - [ ] updateCurrencyWithExchangeRate called correctly
  - [ ] markUserEngaged called on selection
  - [ ] trackAnalyticsEvent called with correct parameters

- [ ] **With Custom Functions**
  - [ ] getCurrencyFormattingRules returns correct symbols
  - [ ] Handles missing currency codes in formatting rules

### Widget Tests

- [ ] **Interaction Tests**
  - [ ] Tap button opens overlay
  - [ ] Tap overlay item selects currency and closes overlay
  - [ ] Tap outside overlay closes overlay
  - [ ] Multiple rapid taps handled correctly
  - [ ] Overlay position updates on screen rotation (if applicable)

- [ ] **Visual Tests**
  - [ ] Button matches design specifications
  - [ ] Overlay matches design specifications
  - [ ] Icon animates correctly (up/down arrow)
  - [ ] Spacing between button and overlay correct
  - [ ] Shadow on overlay renders correctly

### End-to-End Tests

- [ ] **Settings Flow**
  - [ ] Currency selector appears in settings page
  - [ ] Selecting currency updates throughout app
  - [ ] Currency persists after app restart
  - [ ] Currency reflects in price displays

- [ ] **Onboarding Flow**
  - [ ] Currency selector appears in initiate flow
  - [ ] Default currency set correctly
  - [ ] User can change currency before completing onboarding

- [ ] **Language + Currency Flow**
  - [ ] Changing language updates currency selector
  - [ ] Smart fallback logic works correctly
  - [ ] Currency display updates with new translations
  - [ ] Exchange rate updates when currency changes

### Performance Tests

- [ ] **Rendering Performance**
  - [ ] Widget builds without lag
  - [ ] Overlay appears instantly on tap
  - [ ] No frame drops during overlay animation
  - [ ] Memory usage stable during overlay open/close cycles

- [ ] **API Call Efficiency**
  - [ ] Exchange rate API called only when needed
  - [ ] No duplicate API calls on same currency selection
  - [ ] API calls don't block UI

### Error Handling Tests

- [ ] **API Failures**
  - [ ] Currency update fails gracefully
  - [ ] Exchange rate API timeout handled
  - [ ] Analytics tracking failure doesn't block currency change

- [ ] **Translation Failures**
  - [ ] Missing translation key falls back to currency code
  - [ ] Malformed translation cache handled
  - [ ] Empty translationsCache handled

- [ ] **Edge Cases**
  - [ ] Empty userCurrencyCode defaults to DKK
  - [ ] Unknown language code defaults to DKK currencies
  - [ ] Widget disposal during async operation handled

---

## Migration Notes

### Phase 3: Flutter Migration

**Status:** ✅ COMPLETED (2026-02-19)

**Migration Path:**
1. ✅ Copy widget structure from FlutterFlow export
2. ✅ Replace `FFAppState` with `AppState` (Provider)
3. ✅ Replace `FFLocalizations` with `FFLocalizations` (compatible)
4. ✅ Update import paths for custom actions and functions
5. ✅ Add comprehensive tests
6. ✅ Update currency list to universal support (all languages support all currencies)

### Key Differences: FlutterFlow vs Pure Flutter

| Aspect | FlutterFlow | Pure Flutter Migration |
|--------|-------------|------------------------|
| State Management | `FFAppState()` | `context.watch<AppState>()` |
| Localization | `FFLocalizations.of(context).languageCode` | Same, with fallback to `AppState.userLanguageCode` |
| Custom Actions | Direct import from `/custom_code/actions/` | Import from `../actions/` |
| Custom Functions | Direct import from `/flutter_flow/custom_functions.dart` | Import from `../actions/custom_functions.dart` |
| Currency Lists | Language-specific (varied by language) | Universal (all languages support all currencies) |
| Default Currency | Language-specific defaults | Updated English default from USD to GBP |

### Breaking Changes from FlutterFlow

**None** - The migration maintains full API compatibility with FlutterFlow version.

### Behavioral Changes

**Currency Availability:**
- **Before:** Language-specific currency lists (e.g., Danish only had DKK)
- **After:** Universal currency support (all languages support: DKK, EUR, GBP, SEK, NOK, PLN, USD)
- **Reason:** User feedback indicated need for flexibility to select any major currency regardless of language

**English Default Currency:**
- **Before:** USD (United States Dollar)
- **After:** GBP (British Pound)
- **Reason:** Better alignment with European market focus

### State Management Migration

**AppState Structure Required:**

```dart
class AppState extends ChangeNotifier {
  // Currency selection
  String _userCurrencyCode = 'DKK';
  String get userCurrencyCode => _userCurrencyCode;
  set userCurrencyCode(String value) {
    _userCurrencyCode = value;
    notifyListeners();
  }

  // Exchange rate
  double? _exchangeRate;
  double? get exchangeRate => _exchangeRate;
  set exchangeRate(double? value) {
    _exchangeRate = value;
    notifyListeners();
  }

  // Language
  String _userLanguageCode = 'da';
  String get userLanguageCode => _userLanguageCode;
  set userLanguageCode(String value) {
    _userLanguageCode = value;
    notifyListeners();
  }

  // Translation cache
  dynamic _translationsCache = {};
  dynamic get translationsCache => _translationsCache;
  set translationsCache(dynamic value) {
    _translationsCache = value;
    notifyListeners();
  }
}
```

### Custom Actions Migration

**updateCurrencyWithExchangeRate:**

Original location: `_flutterflow_export/lib/custom_code/actions/update_currency_with_exchange_rate.dart`

Migration requirements:
- Replace `FFAppState` with `AppState` (Provider)
- Update API call endpoints (if using direct Supabase, migrate to BuildShip)
- Ensure exchange rate API integration configured correctly
- Return `bool` indicating success/failure

**markUserEngaged:**

Original location: `_flutterflow_export/lib/custom_code/actions/mark_user_engaged.dart`

Migration requirements:
- Update analytics backend integration
- No parameters or return value needed
- Non-blocking implementation

**trackAnalyticsEvent:**

Original location: `_flutterflow_export/lib/custom_code/actions/track_analytics_event.dart`

Migration requirements:
- Update analytics backend integration (BuildShip or other)
- Accept `String eventName` and `Map<String, String> properties`
- Return `Future<void>`
- Implement error handling (use `.catchError()`)

### Custom Functions Migration

**getCurrencyFormattingRules:**

Original location: `_flutterflow_export/lib/flutter_flow/custom_functions.dart`

Migration target: `journey_mate/lib/actions/custom_functions.dart`

No changes required - static function with no external dependencies.

### Testing Migration

**Test File:** `journey_mate/test/widgets/currency_selector_button_test.dart`

**Coverage:** 18 test cases covering:
- Widget creation and display
- Overlay interaction
- Language-specific currency lists
- Currency selection
- Language change detection
- Cleanup and disposal

**Test Infrastructure Required:**
- Mock AppState
- Mock SharedPreferences (for persistent state)
- FFLocalizations setup
- MaterialApp with supported locales

### UI/UX Considerations

**No Visual Changes:**
- All styling constants preserved exactly
- Button and overlay dimensions unchanged
- Color scheme identical to FlutterFlow version
- Icon animations preserved

**Interaction Improvements:**
- Overlay dismisses immediately on selection (already in FlutterFlow)
- Outside tap handling via transparent barrier (already in FlutterFlow)
- Responsive state updates via `context.watch<AppState>()`

### Performance Considerations

**Optimization Maintained:**
- Overlay uses `OverlayEntry` for efficient rendering
- Smart language change detection avoids unnecessary API calls
- Async operations use `WidgetsBinding.instance.addPostFrameCallback`
- No rebuild thrashing

**Memory Management:**
- Overlay cleaned up in `dispose()`
- No memory leaks from unclosed overlays
- State change listeners properly managed via Provider

### Future Enhancements (Post-Migration)

**Potential Riverpod Migration:**

Current state management uses Provider (`ChangeNotifierProvider`). Future migration to Riverpod would require:

```dart
// Define providers
final currencyCodeProvider = StateProvider<String>((ref) => 'DKK');
final exchangeRateProvider = StateProvider<double?>((ref) => null);
final languageCodeProvider = StateProvider<String>((ref) => 'da');
final translationsCacheProvider = StateProvider<dynamic>((ref) => {});

// Update widget
class _CurrencySelectorButtonState extends State<CurrencySelectorButton> {
  @override
  Widget build(BuildContext context) {
    final currencyCode = ref.watch(currencyCodeProvider);
    final languageCode = ref.watch(languageCodeProvider);

    // ... rest of build method
  }
}
```

**Benefits:**
- More granular state updates (only rebuild when specific values change)
- Better testability (mock individual providers)
- Compile-time safety for provider access

**Trade-offs:**
- Increased complexity
- Learning curve for team
- Migration effort for all widgets

**Recommendation:** Defer Riverpod migration until all pages are functional and stable.

---

## Related Documentation

- **Design System:** `_reference/journeymate-design-system.md` (color scheme, spacing, typography)
- **Page Audit:** `_reference/page-audit.md` (FlutterFlow functionality analysis)
- **Translation System:** `shared/internationalization.dart` (getTranslations implementation)
- **Custom Actions:** `_flutterflow_export/lib/custom_code/actions/` (action implementations)
- **Custom Functions:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart` (currency formatting)

---

## Revision History

| Date | Version | Changes | Author |
|------|---------|---------|--------|
| 2026-02-19 | 1.0 | Initial documentation from FlutterFlow export | Claude Code |
| 2026-02-19 | 1.1 | Added migration notes and test coverage | Claude Code |

---

**End of Documentation**
