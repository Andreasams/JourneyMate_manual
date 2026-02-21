# ExpandableTextWidget — Master Documentation

**Source:** `_flutterflow_export/lib/custom_code/widgets/expandable_text_widget.dart`
**Type:** Custom StatefulWidget
**Phase:** FlutterFlow Export (Phase 2)
**Status:** Production code, ready for Phase 3 migration

---

## Purpose

A reusable widget that displays long text in a collapsed state (maximum 4 lines) with a gradient fade-out effect and a "Show more" button. When expanded, shows the full text with a "Show less" button.

**Used for:** Restaurant business descriptions on the Business Profile page.

**Key behaviors:**
- Automatically detects if text will overflow beyond 4 lines using character estimation
- Applies gradient overlay at bottom of collapsed text (fade to background color)
- Smooth animation when expanding/collapsing
- Tracks analytics events for expand/collapse interactions
- Fully internationalized toggle button text
- If text fits within 4 lines, no expand/collapse UI appears

---

## Function Signature

```dart
class ExpandableTextWidget extends StatefulWidget {
  const ExpandableTextWidget({
    super.key,
    this.width,
    this.height,
    required this.text,
    required this.languageCode,
    required this.translationsCache,
    this.businessId,
  });

  final double? width;
  final double? height;
  final String text;
  final String languageCode;
  final dynamic translationsCache;
  final int? businessId;

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `text` | `String` | The text content to display (e.g., restaurant description) |
| `languageCode` | `String` | Current language code (e.g., "da", "en") for translation |
| `translationsCache` | `dynamic` | FFAppState translations cache for UI text lookup |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `double?` | `null` | Fixed width constraint (not actively used internally) |
| `height` | `double?` | `null` | Initial height hint (not actively used internally) |
| `businessId` | `int?` | `null` | Business ID for analytics tracking |

**Note on width/height:** These parameters exist for FlutterFlow compatibility but the widget calculates its own height dynamically based on text content and expansion state. The widget always uses `double.infinity` width in practice.

---

## Translation Keys

The widget uses two translation keys retrieved via `getTranslations()`:

| Key | Purpose | Example (DA) | Example (EN) |
|-----|---------|--------------|--------------|
| `expandable_show_more` | Button text when collapsed | "Vis mere" | "Show more" |
| `expandable_show_less` | Button text when expanded | "Vis mindre" | "Show less" |

**Translation lookup:**
```dart
String _getUIText(String key) {
  return getTranslations(widget.languageCode, key, widget.translationsCache);
}

String _getShowMoreText() => _getUIText('expandable_show_more');
String _getShowLessText() => _getUIText('expandable_show_less');
```

**Migration Note:** These keys must exist in the Supabase translations table. See Business Profile page audit for full translation requirements.

---

## Dependencies

### FlutterFlow Imports
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Flutter Framework
```dart
import 'package:flutter/material.dart';
```

### Custom Functions Used
- `getTranslations(languageCode, key, translationsCache)` — retrieves translated UI text
- `trackAnalyticsEvent(eventName, properties)` — logs expand/collapse actions
- `markUserEngaged()` — updates user engagement timestamp

### Theme Access
- `FlutterFlowTheme.of(context).primaryBackground` — retrieves background color for gradient overlay

---

## FFAppState Usage

The widget **reads** from FFAppState but does not modify it:

| Field | Access | Purpose |
|-------|--------|---------|
| `translationsCache` | Read | Passed as parameter, used for UI text translation |

**Note:** The widget receives `translationsCache` as a parameter from the parent (Business Profile page), which pulls it from `FFAppState().translationsCache`.

---

## Constants & Configuration

### Display Constants
```dart
static const int _maxLinesWhenCollapsed = 4;
static const int _charsPerLineEstimate = 50;
```

**Overflow detection logic:**
- Estimates 50 characters per line
- Text is considered overflowing if `text.length > (4 * 50) = 200 characters`
- This is a heuristic — actual line breaks depend on word wrapping and font metrics

### Typography
```dart
static const double _baseFontSize = 15.0;
static const double _lineHeightMultiplier = 1.5;

static const TextStyle _textStyle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 15,
  fontWeight: FontWeight.w300,  // Light weight for body text
  color: Colors.black,
  height: 1.5,                   // Line height multiplier
);

static const TextStyle _buttonTextStyle = TextStyle(
  fontFamily: 'Roboto',
  fontSize: 16,
  fontWeight: FontWeight.w500,  // Medium weight for button text
  color: Colors.black,
);
```

**Design Note:** Button text is slightly larger (16px) and medium weight to ensure visibility and tap affordance.

### Layout Spacing
```dart
static const double _buttonVerticalPadding = 12.0;      // Top/bottom padding for buttons
static const double _buttonIconSpacing = 6.0;           // Space between text and icon
static const double _expandedButtonTopSpacing = 16.0;   // Space above "Show less" button
static const double _arrowIconSize = 20.0;              // Size of up arrow icon
```

### Gradient Overlay Configuration
```dart
static const double _gradientHeightMultiplier = 1.2;    // Gradient is 1.2x line height
static const double _gradientStartOpacity = 0.0;        // Fully transparent at top
static const double _gradientMidOpacity = 0.8;          // 80% opaque at midpoint
static const double _gradientEndOpacity = 1.0;          // Fully opaque at bottom
static const List<double> _gradientStops = [0.0, 0.5, 1.0];
```

**Gradient calculation:**
- Single line height: `15 * 1.5 = 22.5px`
- Gradient height: `22.5 * 1.2 = 27px`
- Gradient appears at bottom of collapsed text, fading text into background color

### Animation
```dart
static const Duration _animationDuration = Duration(milliseconds: 300);
```

Uses `AnimatedSize` with `Curves.easeInOut` for smooth height transitions.

---

## State Management

### Local State Variables

| Variable | Type | Initial Value | Purpose |
|----------|------|---------------|---------|
| `_isExpanded` | `bool` | `false` | Tracks whether text is currently expanded |
| `_isOverflown` | `bool` | `false` | Tracks whether text exceeds 4 lines (set once in initState) |

**State flow:**
1. `initState()` calls `_determineIfTextOverflows()` to set `_isOverflown`
2. If `_isOverflown == false`, widget renders as plain text (no expand/collapse UI)
3. User taps "Show more" → `setState(() => _isExpanded = true)`
4. User taps "Show less" → `setState(() => _isExpanded = false)`

### Widget Lifecycle

```dart
@override
void initState() {
  super.initState();
  _determineIfTextOverflows();  // Check if text needs expand/collapse UI
}

@override
void didUpdateWidget(ExpandableTextWidget oldWidget) {
  super.didUpdateWidget(oldWidget);
  // Rebuild if translations or language changes
  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.languageCode != oldWidget.languageCode) {
    setState(() {});
  }
}
```

**Why `didUpdateWidget` is critical:** If user changes language while viewing a business profile, the widget must rebuild to show "Show more" / "Show less" in the new language.

---

## UI Structure

### Collapsed State (when `!_isExpanded`)

```
Column
├─ SizedBox (height: 90px = 4 lines * 22.5px)
│  └─ Stack
│     ├─ Text (maxLines: 4, overflow: clip)
│     └─ Positioned (gradient overlay at bottom)
│        └─ Container with LinearGradient
└─ GestureDetector ("Show more" button)
   └─ Container (background color, padding)
      └─ Center
         └─ Text (_getShowMoreText())
```

### Expanded State (when `_isExpanded`)

```
Column
├─ Text (full text, no maxLines restriction)
└─ (if _isOverflown)
   ├─ SizedBox (height: 16px)
   └─ GestureDetector ("Show less" button)
      └─ Padding
         └─ Center
            └─ Row
               ├─ Text (_getShowLessText())
               ├─ SizedBox (width: 6px)
               └─ Icon (keyboard_arrow_up)
```

**Key difference:** "Show less" button includes an up arrow icon, "Show more" button does not have an icon.

### No Overflow State (when `!_isOverflown`)

```
Text(widget.text, style: _textStyle)
```

Simple plain text widget with no expand/collapse UI.

---

## Analytics Tracking

### Event: `expandable_text_toggled`

Fired whenever user expands or collapses text.

**Properties:**

| Property | Type | Value | Purpose |
|----------|------|-------|---------|
| `action` | `String` | `"expand"` or `"collapse"` | Tracks which direction the toggle went |
| `text_id` | `String` | `"description"` (hardcoded) | Identifies which text section (for future multi-section support) |
| `business_id` | `int?` | `widget.businessId` | Tracks which business the interaction occurred on |
| `language` | `String` | `widget.languageCode` | Tracks which language was active |

**Implementation:**
```dart
void _trackTextInteraction(String action) {
  trackAnalyticsEvent(
    'expandable_text_toggled',
    {
      'action': action,
      'text_id': 'description',
      'business_id': widget.businessId,
      'language': widget.languageCode,
    },
  ).catchError((error) {
    debugPrint('⚠️ Failed to track text interaction: $error');
  });
}
```

**Called from:**
- `_expandText()` with `action: "expand"`
- `_collapseText()` with `action: "collapse"`

**User engagement:** Both expand and collapse actions also call `markUserEngaged()` to update the user's last activity timestamp.

---

## Usage Examples

### 1. Business Profile Page (Real-World Usage)

**Location:** `business_profile_widget.dart` line 1622

```dart
custom_widgets.ExpandableTextWidget(
  width: double.infinity,
  height: 50.0,
  text: getJsonField(
    FFAppState().mostRecentlyViewedBusiness,
    r'''$.businessInfo.description''',
  ).toString(),
  languageCode: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  businessId: widget!.businessId,
)
```

**Context:**
- Part of the "About" section on Business Profile page
- Text comes from `mostRecentlyViewedBusiness.businessInfo.description`
- Language code retrieved from FlutterFlow's localization system
- Business ID passed from page widget parameters for analytics

**Spacing:** Followed by `SizedBox(height: 6.0)` divider

### 2. Minimal Example (No Analytics)

```dart
ExpandableTextWidget(
  text: "This is a long restaurant description that will be collapsed...",
  languageCode: "da",
  translationsCache: FFAppState().translationsCache,
)
```

**Note:** `businessId` is optional — if omitted, analytics will still fire but with `business_id: null`.

### 3. Dynamic Language Switching

```dart
// Widget rebuilds automatically when language changes
ExpandableTextWidget(
  text: restaurantDescription,
  languageCode: currentLanguage,  // "da" or "en"
  translationsCache: translationsCache,
  businessId: restaurantId,
)
```

The widget's `didUpdateWidget` method detects language changes and triggers a rebuild to update button text.

---

## Edge Cases & Error Handling

### 1. Empty or Null Text

**Scenario:** `text` parameter is empty string or whitespace

**Behavior:**
- `_determineIfTextOverflows()` calculates `text.length = 0`
- Since `0 < 200`, `_isOverflown = false`
- Widget renders as plain `Text(widget.text, style: _textStyle)`
- No "Show more" button appears

**Fix Required?** No, widget handles gracefully. However, calling page should avoid rendering the widget at all if description is empty.

### 2. Missing Translation Keys

**Scenario:** `expandable_show_more` or `expandable_show_less` not in translations cache

**Behavior:**
- `getTranslations()` returns the key itself as fallback (e.g., "expandable_show_more")
- Button displays untranslated key name
- Widget still functions, but UX is broken

**Fix Required:** Ensure translation keys exist in Supabase translations table for all supported languages.

### 3. Very Short Text

**Scenario:** Text is 50 characters or less (1 line)

**Behavior:**
- `_isOverflown = false` (50 < 200)
- Widget renders as plain text
- No expand/collapse UI

**Correct behavior.** No fix needed.

### 4. Extremely Long Text

**Scenario:** Text is 5000+ characters

**Behavior:**
- `_isOverflown = true` (5000 > 200)
- Collapsed view shows first 4 lines with gradient
- Expanded view shows all 5000 characters (may be very tall)
- "Show less" button appears at bottom

**Performance:** Flutter handles long text rendering efficiently. No pagination needed.

### 5. Analytics Tracking Failure

**Scenario:** `trackAnalyticsEvent()` throws an error (network failure, etc.)

**Behavior:**
- Error caught by `.catchError()` handler
- Error logged to console: `⚠️ Failed to track text interaction: $error`
- Widget state still updates (expand/collapse still works)
- User experience unaffected

**Correct behavior.** Analytics failure should not break UI.

### 6. Language Change While Expanded

**Scenario:** User expands text, then changes language from DA to EN

**Behavior:**
1. `didUpdateWidget` detects language change
2. `setState(() {})` triggers rebuild
3. Button text updates from "Vis mindre" to "Show less"
4. Text remains expanded (`_isExpanded` not reset)

**Correct behavior.** User's expansion state is preserved across language changes.

---

## Testing Checklist

### Unit Tests

- [ ] Widget renders plain text when `text.length <= 200`
- [ ] Widget shows "Show more" button when `text.length > 200`
- [ ] `_isOverflown` set correctly in `initState()`
- [ ] "Show more" button text matches translation key
- [ ] "Show less" button text matches translation key
- [ ] Gradient overlay applies correct background color
- [ ] Gradient height calculated correctly (line height * 1.2)

### Integration Tests

- [ ] Tapping "Show more" expands text
- [ ] Tapping "Show less" collapses text
- [ ] Expansion animates smoothly (300ms, ease-in-out)
- [ ] "Show less" button includes up arrow icon
- [ ] "Show more" button has no icon
- [ ] Analytics event fires on expand with correct properties
- [ ] Analytics event fires on collapse with correct properties
- [ ] `markUserEngaged()` called on both expand and collapse

### Edge Case Tests

- [ ] Empty text (`""`) renders without error
- [ ] Whitespace-only text (`"   "`) renders without error
- [ ] Missing translation keys display fallback (key name)
- [ ] Language change updates button text while expanded
- [ ] Language change updates button text while collapsed
- [ ] Analytics failure does not crash widget
- [ ] Very long text (5000+ chars) renders and expands correctly

### Visual Regression Tests

- [ ] Collapsed state matches design (4 lines visible, gradient at bottom)
- [ ] Expanded state matches design (full text, "Show less" button at bottom)
- [ ] Button padding matches spec (12px vertical)
- [ ] Icon spacing matches spec (6px between text and icon)
- [ ] Button text size (16px) and weight (500) correct
- [ ] Body text size (15px) and weight (300) correct
- [ ] Line height (1.5) matches design

### Accessibility Tests

- [ ] Button tap target at least 48x48 logical pixels
- [ ] Text readable at default system font size
- [ ] Color contrast meets WCAG AA standards (black on background)
- [ ] Screen reader announces button labels correctly

---

## Known Issues & Limitations

### 1. Fixed 4-Line Collapse Height

**Issue:** All text collapses to exactly 4 lines, regardless of content.

**Limitation:** Cannot customize `maxLinesWhenCollapsed` per instance.

**Workaround:** Modify constant in widget code if different collapse height needed.

### 2. Character Estimation Not Perfect

**Issue:** Overflow detection uses `50 chars/line * 4 lines = 200 chars` heuristic.

**Problem:** Some 190-character strings may actually wrap to 5 lines (due to long words), but widget will not show expand UI.

**Impact:** Minor — rare edge case where slightly-overflowing text appears cut off without expand button.

**Better Solution (Phase 3):** Use `TextPainter` to measure actual rendered height and compare to 4-line height.

### 3. Hardcoded `text_id` in Analytics

**Issue:** All analytics events use `text_id: "description"` (line 216).

**Limitation:** Cannot track expand/collapse actions for different text sections separately.

**Future Enhancement:** Make `text_id` a parameter (e.g., `"description"`, `"menu_note"`, `"special_instructions"`).

### 4. Gradient Color Not Customizable

**Issue:** Gradient always uses `FlutterFlowTheme.of(context).primaryBackground`.

**Limitation:** Widget assumes it's always on primary background color. If used on a different background, gradient will not match.

**Workaround:** Pass background color as optional parameter in Phase 3 migration.

---

## Migration Notes (Phase 3)

### Dart-to-Dart Migration (No Changes Needed)

This widget is **already pure Dart** — it does not rely on FlutterFlow-specific UI builders or custom components. Migration primarily involves:

1. **Import path updates** (change `/flutter_flow/` to local paths)
2. **Theme system migration** (replace `FlutterFlowTheme.of(context)` with app theme)
3. **State management** (replace `FFAppState()` with Riverpod providers)

### Critical Dependencies to Migrate

| FlutterFlow Dependency | Phase 3 Replacement |
|------------------------|---------------------|
| `getTranslations(languageCode, key, cache)` | `TranslationService.get(key)` with Riverpod provider |
| `trackAnalyticsEvent(name, props)` | `AnalyticsService.track(name, props)` |
| `markUserEngaged()` | `UserEngagementService.markActive()` |
| `FlutterFlowTheme.of(context).primaryBackground` | `Theme.of(context).scaffoldBackgroundColor` |

### State Management Changes

**Current (FlutterFlow):**
```dart
translationsCache: FFAppState().translationsCache,
languageCode: FFLocalizations.of(context).languageCode,
```

**Phase 3 (Riverpod):**
```dart
// Remove translationsCache parameter entirely
// Widget will call TranslationService.get() directly

final languageCode = ref.watch(languageProvider);

ExpandableTextWidget(
  text: businessDescription,
  languageCode: languageCode,
  businessId: businessId,
)
```

**Benefits:**
- Widget automatically rebuilds when translations change
- No need to pass large cache object as parameter
- Cleaner API with fewer parameters

### Suggested Improvements (Phase 3)

1. **Make `text_id` a parameter:**
   ```dart
   final String textId;  // Add to constructor

   void _trackTextInteraction(String action) {
     trackAnalyticsEvent('expandable_text_toggled', {
       'action': action,
       'text_id': textId,  // Use parameter instead of hardcoded "description"
       'business_id': widget.businessId,
       'language': widget.languageCode,
     });
   }
   ```

2. **Add custom background color support:**
   ```dart
   final Color? backgroundColor;  // Add to constructor

   Widget _buildGradientOverlay() {
     final bgColor = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
     // ... rest of method
   }
   ```

3. **Use `TextPainter` for precise overflow detection:**
   ```dart
   void _determineIfTextOverflows() {
     final textPainter = TextPainter(
       text: TextSpan(text: widget.text, style: _textStyle),
       maxLines: _maxLinesWhenCollapsed,
       textDirection: TextDirection.ltr,
     )..layout(maxWidth: MediaQuery.of(context).size.width - 32); // Account for padding

     _isOverflown = textPainter.didExceedMaxLines;
   }
   ```

4. **Make `maxLines` configurable:**
   ```dart
   final int? maxLinesWhenCollapsed;  // Add to constructor, default to 4

   int get _effectiveMaxLines => maxLinesWhenCollapsed ?? 4;
   ```

### Files to Create (Phase 3)

```
lib/
  widgets/
    expandable_text_widget.dart           ← Migrated widget
  services/
    translation_service.dart               ← getTranslations() replacement
    analytics_service.dart                 ← trackAnalyticsEvent() replacement
    user_engagement_service.dart           ← markUserEngaged() replacement
  test/
    widgets/
      expandable_text_widget_test.dart     ← Unit tests
```

### Translation Keys Migration

Ensure these keys exist in Supabase `translations` table:

| Key | DA | EN |
|-----|----|----|
| `expandable_show_more` | "Vis mere" | "Show more" |
| `expandable_show_less` | "Vis mindre" | "Show less" |

**Query to verify:**
```sql
SELECT * FROM translations
WHERE key IN ('expandable_show_more', 'expandable_show_less');
```

### Analytics Schema Verification

Ensure `expandable_text_toggled` event is documented in analytics schema with properties:

- `action` (string: "expand" | "collapse")
- `text_id` (string: e.g., "description")
- `business_id` (integer, nullable)
- `language` (string: e.g., "da", "en")

---

## Related Documentation

- **Business Profile Page Audit** — `_reference/page-audit.md` section on Business Profile
- **FlutterFlow Export** — `_flutterflow_export/lib/custom_code/widgets/expandable_text_widget.dart`
- **Design System** — `_reference/journeymate-design-system.md` (typography rules)
- **Translation System** — (to be documented separately)
- **Analytics System** — (to be documented separately)

---

## Summary

The ExpandableTextWidget is a **production-ready, well-architected custom widget** that:

- ✅ Handles text overflow gracefully with automatic detection
- ✅ Provides smooth animated expand/collapse transitions
- ✅ Fully internationalized with translation key support
- ✅ Tracks user interactions for analytics
- ✅ Adapts to theme background colors for gradient overlay
- ✅ Handles edge cases (empty text, language changes, analytics failures)

**Migration difficulty:** Low — widget is already pure Dart with minimal FlutterFlow dependencies.

**Testing priority:** Medium — critical for Business Profile UX, but logic is straightforward.

**Reusability:** High — can be used for any long-text content (restaurant descriptions, menu notes, etc.).

---

**Last Updated:** 2026-02-19
**Phase:** 2 (FlutterFlow Export Documentation)
**Next Step:** Migrate to Phase 3 with Riverpod state management and app theme system
