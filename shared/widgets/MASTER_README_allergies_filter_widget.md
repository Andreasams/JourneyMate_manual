# AllergiesFilterWidget

**Type:** Custom Widget
**File:** `allergies_filter_widget.dart` (356 lines)
**Category:** Filters & Menu
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Critical menu filtering)

---

## Purpose

A horizontal scrollable widget that displays 14 allergen filter buttons for filtering menu items. Users can toggle allergens to show/hide menu items containing specific allergens. Provides visual feedback with color-coded button states and includes comprehensive analytics tracking.

**Key Features:**
- 14 allergen filter options (IDs 1-14)
- Multi-select checkbox-style functionality
- Orange selected state (allergen visible), grey unselected state (allergen hidden)
- Alphabetical sorting by localized allergen name
- Real-time updates to FFAppState.excludedAllergyIds
- Analytics tracking for each toggle interaction
- Translation support for 15 languages
- 200ms animation duration for state changes

---

## Parameters

```dart
AllergiesFilterWidget({
  super.key,
  this.width,
  this.height,
  required this.onAllergiesChanged,
  required this.currentLanguage,
  this.initiallyExcludedAllergyIds,
  required this.translationsCache,
  required this.currentResultCount,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (defaults to parent width) |
| `height` | `double?` | No | Container height (defaults to 32px) |
| `onAllergiesChanged` | `Future Function(List<int>)` | **Yes** | Callback when allergen selection changes, receives excluded allergen IDs |
| `currentLanguage` | `String` | **Yes** | Current UI language code (e.g., 'en', 'da') |
| `initiallyExcludedAllergyIds` | `List<int>?` | No | Initially excluded allergen IDs from FFAppState |
| `translationsCache` | `dynamic` | **Yes** | Translation cache containing localized allergen names |
| `currentResultCount` | `int` | **Yes** | Current number of visible menu items (for analytics) |

---

## Dependencies

### pub.dev Packages
- `collection: ^1.17.0` (for `DeepCollectionEquality` and `SetEquality`)

### Internal Dependencies
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart';
import '/custom_code/widgets/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Custom Actions Used

| Action | Purpose | Line Reference |
|--------|---------|----------------|
| `markUserEngaged()` | Extends user engagement window by 15s | 162 |
| `trackAnalyticsEvent()` | Tracks allergen toggle events | 194-207 |
| `updateMenuSessionFilterMetrics()` | Updates session-level filter impact metrics | 174 |

### Custom Functions Used

| Function | Purpose | Line Reference |
|----------|---------|----------------|
| `getTranslations()` | Retrieves localized allergen names | 226-230 |

---

## FFAppState Usage

### Read Properties

| Property | Purpose | Read Location |
|----------|---------|---------------|
| N/A | Widget receives state via props | - |

### Write Properties

| Property | Purpose | Write Location |
|----------|---------|---------------|
| `excludedAllergyIds` | Stored via callback (parent updates) | 171 (via `onAllergiesChanged`) |

### State Listening

Widget does NOT directly read/write FFAppState. All state flows through:
1. Parent provides `initiallyExcludedAllergyIds` from FFAppState
2. Widget calls `onAllergiesChanged` callback with updated list
3. Parent updates FFAppState.excludedAllergyIds

---

## Lifecycle Events

### initState (lines 88-92)
```dart
@override
void initState() {
  super.initState();
  _scrollController = ScrollController();
  _syncStateFromParent(widget.initiallyExcludedAllergyIds);
}
```

**Actions:**
- Creates scroll controller for horizontal list
- Syncs internal exclusion state from parent-provided list
- Initializes `_excludedAllergyIds` set

### didUpdateWidget (lines 95-114)
**Triggers Handled:**
- `initiallyExcludedAllergyIds` change → Sync internal state (line 109-110)
- `currentLanguage` change → Rebuild UI (line 112)
- `translationsCache` change → Rebuild UI (line 112)

**Optimization:** Uses `DeepCollectionEquality` to prevent unnecessary rebuilds

### dispose (lines 117-120)
```dart
@override
void dispose() {
  _scrollController.dispose();
  super.dispose();
}
```

**Actions:**
- Disposes scroll controller to prevent memory leaks

---

## User Interactions

### onTap Allergen Button
**Trigger:** User taps an allergen button (e.g., "Gluten")
**Line:** 334 (via `onPressed`)

**Actions:**
1. Toggles allergen in `_excludedAllergyIds` set:
   - **Was visible** → Add to exclusion set (grey out button)
   - **Was hidden** → Remove from exclusion set (highlight orange)
2. Marks user as engaged (`markUserEngaged`)
3. Tracks analytics event with allergen details
4. Calls `onAllergiesChanged` callback with updated list
5. Updates menu session filter metrics with current result count

**Visual Feedback:**
- Button animates color change over 200ms
- Text color changes: white (selected) ↔ dark grey (unselected)
- Border appears on unselected state

---

## Display States

### Selected State (Allergen Visible)
**Condition:** `!_excludedAllergyIds.contains(allergyId)`

**Visual:**
- Orange background (`#FFEE8B60`)
- White text
- No border
- Menu items WITH this allergen ARE shown

### Unselected State (Allergen Hidden)
**Condition:** `_excludedAllergyIds.contains(allergyId)`

**Visual:**
- Light grey background (`#FFF2F3F5`)
- Dark grey text (`#FF242629`)
- Grey border (`Colors.grey[500]`)
- Menu items WITH this allergen ARE hidden

---

## Button Layout

### Visual Styling Constants

| Property | Value | Description |
|----------|-------|-------------|
| Selected color | `#FFEE8B60` | Orange (brand accent) |
| Unselected color | `#FFF2F3F5` | Light grey |
| Selected text | `Colors.white` | White |
| Unselected text | `#FF242629` | Dark grey |
| Border color | `Colors.grey[500]` | Grey border (unselected only) |
| Animation duration | `200ms` | Smooth state transitions |
| Button padding | `16px horizontal` | Consistent spacing |
| Button min size | `0px width × 32px height` | Height constraint only |
| Border radius | `15px` | Rounded corners |
| Font size | `14px` | Readable size |
| Button spacing | `8px` | Gap between buttons |

### Horizontal Scroll Behavior
- Left-to-right scroll
- Alphabetically sorted by translated name
- No scroll indicators (iOS/Android default)
- Buttons sized to content width (min 0px)

---

## Allergen Data

### Allergen IDs (1-14)
Widget supports 14 allergens by ID:

| ID | Translation Key | Example (English) |
|----|----------------|-------------------|
| 1 | `allergen_1_cap` | "Gluten" |
| 2 | `allergen_2_cap` | "Crustaceans" |
| 3 | `allergen_3_cap` | "Eggs" |
| 4 | `allergen_4_cap` | "Fish" |
| 5 | `allergen_5_cap` | "Peanuts" |
| 6 | `allergen_6_cap` | "Soy" |
| 7 | `allergen_7_cap` | "Milk" |
| 8 | `allergen_8_cap` | "Nuts" |
| 9 | `allergen_9_cap` | "Celery" |
| 10 | `allergen_10_cap` | "Mustard" |
| 11 | `allergen_11_cap` | "Sesame" |
| 12 | `allergen_12_cap` | "Sulphites" |
| 13 | `allergen_13_cap` | "Lupin" |
| 14 | `allergen_14_cap` | "Molluscs" |

### Alphabetical Sorting
Allergens are sorted alphabetically by the translated name (line 265):
```dart
allergyEntries..sort((a, b) => a.value.compareTo(b.value));
```

**Example:** In English: "Celery" appears before "Gluten"

---

## State Management

### Internal State
```dart
Set<int> _excludedAllergyIds = {};
```
**Purpose:** Tracks allergen IDs that are currently excluded (hidden)
**Lifecycle:** Initialized from `initiallyExcludedAllergyIds`, updated on toggle

### Synchronization Logic (lines 130-143)
```dart
void _syncStateFromParent(List<int>? exclusionListFromParent) {
  final newExclusionSet = exclusionListFromParent?.toSet() ?? <int>{};

  final hasStateChanged = !SetEquality().equals(
    _excludedAllergyIds,
    newExclusionSet,
  );

  if (hasStateChanged) {
    setState(() {
      _excludedAllergyIds = newExclusionSet;
    });
  }
}
```

**Optimization:** Uses `SetEquality` to prevent unnecessary rebuilds when parent passes same list

### Toggle Logic (lines 151-175)
1. Create copy of current exclusion set
2. Check if allergen was excluded
3. Toggle exclusion state (add/remove from set)
4. Mark user engaged (extends session window)
5. Track analytics event
6. Call parent callback with updated list
7. Update session filter metrics

---

## Translation System

### Translation Key Format
```dart
final translationKey = 'allergen_${allergenId}_cap';
```

**Examples:**
- `allergen_1_cap` → "Gluten"
- `allergen_7_cap` → "Milk"
- `allergen_14_cap` → "Molluscs"

### Translation Retrieval (lines 224-238)
```dart
String? _getAllergenName(int allergenId) {
  final translationKey = 'allergen_${allergenId}_cap';
  final allergenName = getTranslations(
    widget.currentLanguage,
    translationKey,
    widget.translationsCache,
  );

  // Return null if translation not found (indicated by ⚠️ prefix or empty)
  if (allergenName.isEmpty || allergenName.startsWith('⚠️')) {
    return null;
  }

  return allergenName;
}
```

### Missing Translation Handling
- If translation missing → Returns `null`
- Missing translations skipped from display (line 255-258)
- Warning logged to console: `⚠️ Missing translation for allergen_X in {language}`

---

## Analytics Tracking

### Event: allergen_filter_toggled
**Tracked on:** Every allergen button tap (line 194)

**Event Data:**
```dart
{
  'allergen_id': 7,                              // The allergen ID (1-14)
  'allergen_name': 'Milk',                       // Localized allergen name
  'action': 'excluded',                          // 'excluded' or 'included'
  'is_now_excluded': true,                       // Boolean exclusion state
  'current_excluded_allergens': [1, 7, 12],     // Full exclusion list
  'excluded_count': 3,                           // Number of excluded allergens
  'language': 'en',                              // Current language code
}
```

**Fire-and-Forget Pattern:** Tracking failures caught and logged (line 205-207), won't impact UX

---

## Performance Optimizations

1. **SetEquality Checks**
   - Prevents unnecessary rebuilds when parent passes same list
   - Uses `collection` package for efficient set comparison

2. **Null-Safe Translation Lookup**
   - Returns early if translation missing
   - Skips allergens without valid translations

3. **Alphabetical Pre-Sort**
   - Sorted once during build, not on every button tap
   - Uses efficient `compareTo` for sorting

4. **Optimistic UI Updates**
   - Button state changes immediately (no async wait)
   - Callback and analytics run async without blocking

5. **Minimal State**
   - Only tracks excluded allergen IDs (Set<int>)
   - No redundant state for button colors/text

6. **ListView.separated**
   - Efficient horizontal list rendering
   - Only builds visible items
   - Consistent spacing with `separatorBuilder`

---

## Usage Example

### In FlutterFlow Page Widget (Full Menu Page)

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
custom_widgets.AllergiesFilterWidget(
  width: double.infinity,
  height: 32,
  onAllergiesChanged: (excludedIds) async {
    FFAppState().update(() {
      FFAppState().excludedAllergyIds = excludedIds;
    });

    // Trigger menu filtering
    setState(() {
      // Menu list will rebuild with new exclusions
    });
  },
  currentLanguage: FFLocalizations.of(context).languageCode,
  initiallyExcludedAllergyIds: FFAppState().excludedAllergyIds,
  translationsCache: FFAppState().translationsCache,
  currentResultCount: _filteredMenuItems.length,
)
```

### Required Setup
1. FFAppState must have `excludedAllergyIds` list initialized (empty list OK)
2. FFAppState must have `translationsCache` populated with allergen translations
3. Parent page must re-filter menu items when `onAllergiesChanged` fires
4. Menu items must have allergen ID arrays for matching

---

## Edge Cases Handled

1. **Null initiallyExcludedAllergyIds** - Defaults to empty set (line 131)
2. **Missing translation** - Allergen skipped with warning (line 256-258)
3. **Empty translation** - Treated as missing (line 233)
4. **Translation with ⚠️ prefix** - Treated as missing (line 233)
5. **Rapid toggling** - Each toggle tracked separately, no debounce
6. **Language change mid-session** - Rebuilds with new translations (line 103-112)
7. **Translation cache update** - Rebuilds with new data (line 106-112)
8. **Parent state change** - Syncs internal state without rebuild if unchanged (line 130-143)
9. **Scroll controller disposal** - Properly disposed to prevent leaks (line 119)
10. **Analytics tracking failure** - Logged but doesn't crash (line 205-207)

---

## Integration with Menu Filtering

### Data Flow
1. **User taps allergen button** → Widget toggles internal state
2. **Widget calls `onAllergiesChanged`** → Parent receives updated exclusion list
3. **Parent updates FFAppState.excludedAllergyIds** → Persists user selection
4. **Parent re-filters menu items** → Hides items with excluded allergens
5. **Parent updates `currentResultCount`** → Passed back to widget for analytics

### Menu Item Matching Pattern
```dart
// Example: Filtering menu items by allergen exclusions
final filteredItems = allMenuItems.where((item) {
  // If user has excluded allergens
  if (FFAppState().excludedAllergyIds.isNotEmpty) {
    // Check if item contains any excluded allergen
    final hasExcludedAllergen = item.allergenIds.any(
      (allergenId) => FFAppState().excludedAllergyIds.contains(allergenId)
    );

    // Hide item if it contains excluded allergen
    return !hasExcludedAllergen;
  }

  return true; // No exclusions, show all items
}).toList();
```

---

## Migration Notes

### Phase 3 Strategy

**FlutterFlow → Pure Flutter**

#### 1. State Management
```dart
// Before (FlutterFlow):
FFAppState().excludedAllergyIds

// After (Riverpod):
final excludedAllergiesProvider = StateNotifierProvider<ExcludedAllergiesNotifier, List<int>>(...);
```

#### 2. Translation System
```dart
// Before:
getTranslations(languageCode, key, translationsCache)

// After:
AppLocalizations.of(context)!.allergen1Cap
```

#### 3. Analytics Tracking
```dart
// Before:
trackAnalyticsEvent('allergen_filter_toggled', {...})

// After:
ref.read(analyticsProvider.notifier).trackEvent(
  'allergen_filter_toggled',
  properties: {...},
);
```

#### 4. Callback Pattern
```dart
// Before (async callback):
onAllergiesChanged: (ids) async { ... }

// After (synchronous state update):
onAllergiesChanged: (ids) {
  ref.read(excludedAllergiesProvider.notifier).update(ids);
}
```

---

## Related Elements

### Used By Pages
- **FullMenu** (`full_menu_widget.dart`) - Primary implementation for menu filtering

### Related Widgets
- `MenuItemCard` - Displays individual menu items (filtered by this widget)
- `FilterOverlayWidget` - Main filter interface (different filter type)

### Related Actions
- `markUserEngaged` - User engagement tracking
- `trackAnalyticsEvent` - Event logging
- `updateMenuSessionFilterMetrics` - Session-level metrics
- `startMenuSession` - Initializes menu session with allergen context
- `endMenuSession` - Finalizes menu session with allergen usage stats

### Related Functions
- `getTranslations` - Localization
- `generateFilterSummary` - May include allergen exclusion info

---

## Testing Checklist

When implementing in Flutter:

- [ ] Display all 14 allergen buttons with correct translations
- [ ] Sort allergens alphabetically by localized name
- [ ] Tap allergen - verify button changes to grey (excluded)
- [ ] Tap again - verify button returns to orange (included)
- [ ] Tap allergen - verify `onAllergiesChanged` callback fires
- [ ] Exclude allergen - verify menu items update correctly
- [ ] Exclude multiple allergens - verify cumulative filtering
- [ ] Clear all exclusions - verify all buttons return to orange
- [ ] Change language - verify button text updates
- [ ] Scroll horizontally - verify all buttons accessible
- [ ] Missing translation - verify allergen skipped gracefully
- [ ] Empty initiallyExcludedAllergyIds - verify defaults to empty
- [ ] Rapid toggling - verify each toggle tracked separately
- [ ] Parent state change - verify internal state syncs
- [ ] Widget disposal - verify no memory leaks
- [ ] Analytics tracking - verify events logged correctly
- [ ] Menu session metrics - verify currentResultCount used
- [ ] 200ms animation - verify smooth color transitions
- [ ] Button spacing - verify 8px gaps between buttons
- [ ] Button height - verify 32px constraint

---

## Known Issues

None currently documented.

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with Riverpod State Management
