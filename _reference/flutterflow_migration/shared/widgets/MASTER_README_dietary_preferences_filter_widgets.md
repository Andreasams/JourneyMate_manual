# DietaryPreferencesFilterWidgets

**Type:** Custom Widget
**File:** `dietary_preferences_filter_widgets.dart` (649 lines)
**Category:** Filters & Menu
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Critical menu filtering)

---

## Purpose

A horizontal scrollable widget that displays dietary preference filter buttons for filtering menu items. Users can select ONE dietary preference at a time (single-select), which automatically excludes certain allergens from the menu based on the preference requirements. Provides intelligent validation against parent allergen states and includes comprehensive analytics tracking.

**Key Features:**
- 3 dietary preference options (Vegan, Vegetarian, Pescetarian)
- Single-select radio-button-style functionality (only one active at a time)
- Orange selected state, grey unselected state
- Automatic allergen exclusion based on preference
- Intelligent validation against parent allergen/restriction states
- Real-time updates to FFAppState.selectedDietaryPreferenceId
- Analytics tracking for each toggle interaction
- Translation support for 15 languages
- 200ms animation duration for state changes
- Alphabetical sorting by localized preference name

---

## Parameters

```dart
DietaryPreferencesFilterWidgets({
  super.key,
  this.width,
  this.height,
  required this.onDietaryPreferenceChanged,
  required this.availableDietaryPreferences,
  required this.currentLanguage,
  required this.translationsCache,
  this.initialSelectedPreferenceId,
  required this.currentlyExcludedAllergyIdsFromParent,
  required this.currentResultCount,
  this.currentSelectedRestrictionId,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (defaults to parent width) |
| `height` | `double?` | No | Container height (defaults to 32px) |
| `onDietaryPreferenceChanged` | `Future Function(int?, List<int>)` | **Yes** | Callback when preference changes, receives preference ID and implied allergen exclusions |
| `availableDietaryPreferences` | `List<int>` | **Yes** | List of available preference IDs (typically [2, 6, 7]) |
| `currentLanguage` | `String` | **Yes** | Current UI language code (e.g., 'en', 'da') |
| `translationsCache` | `dynamic` | **Yes** | Translation cache containing localized preference names |
| `initialSelectedPreferenceId` | `int?` | No | Initially selected preference ID from FFAppState |
| `currentlyExcludedAllergyIdsFromParent` | `List<int>?` | **Yes** | Current allergen exclusions from parent (for validation) |
| `currentResultCount` | `int` | **Yes** | Current number of visible menu items (for analytics) |
| `currentSelectedRestrictionId` | `int?` | No | Current restriction ID from parent (for implied allergen calculation) |

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
| `markUserEngaged()` | Extends user engagement window by 15s | 452 |
| `trackAnalyticsEvent()` | Tracks preference toggle events | 507-520 |
| `updateMenuSessionFilterMetrics()` | Updates session-level filter impact metrics | 461 |

### Custom Functions Used

| Function | Purpose | Line Reference |
|----------|---------|----------------|
| `getTranslations()` | Retrieves localized preference names | 176-178 |

---

## FFAppState Usage

### Read Properties

| Property | Purpose | Read Location |
|----------|---------|---------------|
| N/A | Widget receives state via props | - |

### Write Properties

| Property | Purpose | Write Location |
|----------|---------|---------------|
| `selectedDietaryPreferenceId` | Stored via callback (parent updates) | 416-417 (via `onDietaryPreferenceChanged`) |

### State Listening

Widget does NOT directly read/write FFAppState. All state flows through:
1. Parent provides `initialSelectedPreferenceId` from FFAppState
2. Widget calls `onDietaryPreferenceChanged` callback with updated preference ID and implied allergens
3. Parent updates FFAppState.selectedDietaryPreferenceId and handles allergen exclusions

---

## Lifecycle Events

### initState (lines 136-145)
```dart
@override
void initState() {
  super.initState();
  _scrollController = ScrollController();
  _selectedDietaryPreferenceId = widget.initialSelectedPreferenceId;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _validateCurrentPreferenceAgainstParentAllergens(isInitialSync: true);
    }
  });
}
```

**Actions:**
- Creates scroll controller for horizontal list
- Initializes internal preference selection from parent
- Schedules post-frame validation to check if preference is still valid against parent allergens
- Validation runs AFTER first frame to ensure parent state is available

### didUpdateWidget (lines 148-162)
**Triggers Handled:**
- `initialSelectedPreferenceId` change → Update internal state and validate (line 159-234)
- `currentlyExcludedAllergyIdsFromParent` change → Re-validate preference (line 238-249)
- `currentSelectedRestrictionId` change → Re-validate preference (line 254-261)
- `currentLanguage` change → Rebuild UI (line 152-156)
- `translationsCache` change → Rebuild UI (line 152-156)

**Optimization:** Uses `DeepCollectionEquality` to prevent unnecessary rebuilds

### dispose (lines 164-168)
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

### onTap Preference Button
**Trigger:** User taps a dietary preference button (e.g., "Vegan")
**Line:** 580 (via `onPressed`)

**Actions:**
1. Determines selection result:
   - **Same preference tapped** → Deselect (clear preference)
   - **Different preference tapped** → Select new preference (replace old)
2. Marks user as engaged (`markUserEngaged`)
3. Tracks analytics event with preference details and implied allergens
4. Updates internal state immediately
5. Calls `onDietaryPreferenceChanged` callback with preference ID and implied allergen list
6. Updates menu session filter metrics with current result count

**Visual Feedback:**
- Button animates color change over 200ms
- Text color changes: white (selected) ↔ dark grey (unselected)
- Border appears on unselected state
- Only ONE button can be selected at a time

---

## Display States

### Selected State (Preference Active)
**Condition:** `_selectedDietaryPreferenceId == preferenceId`

**Visual:**
- Orange background (`#FFEE8B60`)
- White text
- No border
- Allergens implied by preference ARE excluded from menu

### Unselected State (Preference Inactive)
**Condition:** `_selectedDietaryPreferenceId != preferenceId`

**Visual:**
- Light grey background (`#FFF2F3F5`)
- Dark grey text (`#FF242629`)
- Grey border (`Colors.grey[500]`)
- No allergen exclusions from this preference

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

## Dietary Preference Data

### Preference IDs and Implied Allergen Exclusions

Widget supports 3 dietary preferences:

| ID | Translation Key | Example (English) | Implied Allergen Exclusions |
|----|----------------|-------------------|----------------------------|
| 6 | `dietary_6_cap` | "Vegan" | Milk (7), Eggs (4), Fish (5), Crustaceans (3), Molluscs (8) |
| 7 | `dietary_7_cap` | "Vegetarian" | Fish (5), Crustaceans (3), Molluscs (8) |
| 2 | `dietary_2_cap` | "Pescetarian" | None (no allergen exclusions) |

### Allergen ID Constants (lines 98-109)

```dart
static const int _milkAllergenId = 7;
static const int _eggsAllergenId = 4;
static const int _fishAllergenId = 5;
static const int _crustaceansAllergenId = 3;
static const int _molluscsAllergenId = 8;

static const int _veganId = 6;
static const int _vegetarianId = 7;
static const int _pescetarianId = 2;
```

### Preference to Allergen Mapping (lines 111-125)

```dart
static const Map<int, List<int>> _preferenceToImpliedAllergensMap = {
  _veganId: [
    _milkAllergenId,
    _eggsAllergenId,
    _fishAllergenId,
    _crustaceansAllergenId,
    _molluscsAllergenId
  ],
  _vegetarianId: [
    _fishAllergenId,
    _crustaceansAllergenId,
    _molluscsAllergenId
  ],
  _pescetarianId: [],
};
```

### Auto-Selection Eligibility (lines 128-129)

```dart
static const Set<int> _autoSelectablePreferenceIds = <int>{};
```

**Note:** Currently empty - no automatic selection of preferences to avoid conflicts with user intent. Preferences are only selected via explicit user tap.

### Alphabetical Sorting
Preferences are sorted alphabetically by the translated name (line 546):
```dart
return entries..sort((a, b) => a.value.compareTo(b.value));
```

**Example:** In English: "Pescetarian" → "Vegan" → "Vegetarian"

---

## State Management

### Internal State
```dart
int? _selectedDietaryPreferenceId;
```
**Purpose:** Tracks the currently selected dietary preference ID (null if none selected)
**Lifecycle:** Initialized from `initialSelectedPreferenceId`, updated on toggle or validation

### Validation & Auto-Selection Logic (lines 269-441)

The widget implements sophisticated validation to ensure the selected preference remains valid as parent state changes:

#### Validation Trigger Points
1. **Initial sync** (post-frame in initState)
2. **Preference prop changes** from parent
3. **Allergen exclusion list changes** from parent
4. **Restriction selection changes** from parent

#### Validation Process (lines 269-277)

```dart
void _validateCurrentPreferenceAgainstParentAllergens({
  bool triggerCallbackIfChanged = false,
  bool isInitialSync = false,
}) {
  final validationResult = _performValidation();
  final preferenceChanged = _applyValidationResult(validationResult);
  _triggerCallbackIfNeeded(validationResult, preferenceChanged, isInitialSync,
      triggerCallbackIfChanged);
}
```

**Steps:**
1. Perform validation logic
2. Apply result to internal state
3. Trigger parent callback if necessary

#### Validation Logic Sequence (lines 280-296)

1. **Check for auto-selection opportunity** - Currently disabled (empty set)
2. **Validate existing preference** - If one is selected
3. **Return null result** - If no selection and no auto-selection

#### Existing Preference Validation (lines 299-326)

**For each selected preference:**
1. Get required allergen exclusions for this preference
2. Check if ALL required allergens are still excluded in parent
3. If YES → Keep preference selected
4. If NO → Clear preference (deselect)

**Example:** If Vegan is selected, but user manually re-includes Milk (ID 7) via allergen filter, Vegan preference will auto-deselect because Vegan requires Milk to be excluded.

#### Restriction-Aware Auto-Selection (lines 336-368)

**Logic:**
1. Calculate allergens implied by current restriction (if any)
2. Calculate "extra" allergens (excluded but NOT from restriction)
3. Check if extra allergens EXACTLY match a preference's requirements
4. If exact match → Auto-select that preference

**Example:** If Gluten-free restriction is active (implies Gluten allergen), and user ALSO excludes Fish, Crustaceans, Molluscs (the exact Vegetarian requirements), then Vegetarian preference is auto-selected.

**Note:** Currently disabled via empty `_autoSelectablePreferenceIds` set (line 129) to avoid conflicts.

#### Restriction Allergen Mappings (lines 378-386)

```dart
const restrictionAllergens = {
  1: [2], // Gluten-free → gluten
  4: [7], // Lactose-free → milk
  3: [], // Halal → none
  5: [], // Kosher → none
};
```

**Purpose:** Calculate which allergens are implied by restrictions vs. preferences to determine "extra" allergens for auto-selection logic.

### User Selection Logic (lines 448-492)

**Simple Single-Select Pattern:**
1. Determine if user is deselecting (tapping same preference) or selecting new
2. Mark user engaged
3. Track analytics
4. Update internal state immediately
5. Notify parent with preference ID and implied allergen list
6. Update session metrics

---

## Translation System

### Translation Key Format
```dart
final translationKey = 'dietary_${preferenceId}_cap';
```

**Examples:**
- `dietary_2_cap` → "Pescetarian"
- `dietary_6_cap` → "Vegan"
- `dietary_7_cap` → "Vegetarian"

### Translation Retrieval (lines 175-178)

```dart
String _getUIText(String key) {
  return getTranslations(
      widget.currentLanguage, key, widget.translationsCache);
}
```

### Safe Translation Lookup (lines 190-207)

```dart
String? _getPreferenceNameSafe(int? preferenceId) {
  // Guard: null or zero ID
  if (preferenceId == null || preferenceId == 0) {
    return null;
  }

  final translationKey = 'dietary_${preferenceId}_cap';
  final preferenceName = _getUIText(translationKey);

  // Return null if translation not found (indicated by empty or ⚠️ prefix)
  if (preferenceName.isEmpty || preferenceName.startsWith('⚠️')) {
    debugPrint(
        '⚠️ Missing translation for $translationKey in ${widget.currentLanguage}');
    return null;
  }

  return preferenceName;
}
```

### Non-Null Variant (lines 213-216)

```dart
String _getPreferenceName(int preferenceId) {
  return _getPreferenceNameSafe(preferenceId) ??
      'Preference $preferenceId'; // Fallback
}
```

**Usage:** Only called when preference ID is known to be valid (from `availableDietaryPreferences`)

### Missing Translation Handling
- If translation missing → Returns `null` from safe variant
- Missing translations skipped from display (line 537)
- Warning logged to console: `⚠️ Missing translation for dietary_X in {language}`
- Fallback string used for analytics: `Preference X`

---

## Analytics Tracking

### Event: dietary_preference_toggled
**Tracked on:** Every preference button tap (line 507)

**Event Data:**
```dart
{
  'preference_id': 6,                              // The preference ID (2, 6, or 7)
  'preference_name': 'Vegan',                      // Localized preference name
  'action': 'selected',                            // 'selected' or 'deselected'
  'is_now_selected': true,                         // Boolean selection state
  'implied_allergen_exclusions': [3, 4, 5, 7, 8], // Allergens excluded by preference
  'implied_allergen_count': 5,                     // Number of implied allergens
  'language': 'en',                                // Current language code
}
```

**Fire-and-Forget Pattern:** Tracking failures caught and logged (line 518-520), won't impact UX

---

## Validation & Synchronization Patterns

### Widget Update Handlers (lines 220-262)

Three separate handlers monitor different aspects of parent state:

#### 1. Preference Prop Changes (lines 223-234)
**Monitors:** `initialSelectedPreferenceId`
**Action:** Update internal state and re-validate

#### 2. Allergen Prop Changes (lines 238-249)
**Monitors:** `currentlyExcludedAllergyIdsFromParent`
**Action:** Re-validate preference if allergen list changes
**Protection:** Only triggers if preference ID hasn't changed (to avoid double-validation)

#### 3. Restriction Prop Changes (lines 253-261)
**Monitors:** `currentSelectedRestrictionId`
**Action:** Re-validate preference when restriction changes
**Reason:** Restriction change affects implied allergen calculation

### Callback Triggering Logic (lines 404-441)

**Determines when to call parent callback:**

```dart
bool _shouldTriggerCallback(bool preferenceChanged, bool isInitialSync,
    bool triggerCallbackIfChanged) {
  return (preferenceChanged && triggerCallbackIfChanged) || isInitialSync;
}
```

**Scenarios:**
1. **Initial sync** → Always trigger (parent needs initial state)
2. **Preference changed + explicit trigger flag** → Trigger (validation cleared preference)
3. **No change** → Don't trigger (avoid unnecessary parent updates)

**Implied Allergen Calculation for Callback (lines 428-441):**
- **Initial sync + no change** → Look up allergens from map (preference was valid)
- **All other cases** → Use allergens from validation result

---

## Performance Optimizations

1. **SetEquality Checks**
   - Uses `DeepCollectionEquality` to detect allergen list changes
   - Prevents unnecessary validation when parent passes same list

2. **Null-Safe Translation Lookup**
   - Returns early if preference ID is null/zero
   - Skips preferences without valid translations
   - Filters out null entries before building UI

3. **Alphabetical Pre-Sort**
   - Sorted once during build, not on every button tap
   - Uses efficient `compareTo` for sorting

4. **Optimistic UI Updates**
   - Button state changes immediately (no async wait)
   - Callback and analytics run async without blocking

5. **Minimal State**
   - Only tracks selected preference ID (int?)
   - No redundant state for button colors/text

6. **ListView.separated**
   - Efficient horizontal list rendering
   - Only builds visible items
   - Consistent spacing with `separatorBuilder`

7. **Post-Frame Validation**
   - Initial validation deferred until after first frame
   - Ensures parent state is available before validating

8. **Selective Validation Triggers**
   - Separate handlers prevent duplicate validation
   - Protection flags prevent cascading re-validations

---

## Usage Example

### In FlutterFlow Page Widget (Full Menu Page)

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
custom_widgets.DietaryPreferencesFilterWidgets(
  width: double.infinity,
  height: 32,
  onDietaryPreferenceChanged: (preferenceId, impliedAllergens) async {
    FFAppState().update(() {
      FFAppState().selectedDietaryPreferenceId = preferenceId;

      // Add implied allergens to exclusion list (merge with existing)
      final currentExclusions = Set<int>.from(FFAppState().excludedAllergyIds);
      final newExclusions = Set<int>.from(impliedAllergens);
      FFAppState().excludedAllergyIds =
          currentExclusions.union(newExclusions).toList();
    });

    // Trigger menu filtering
    setState(() {
      // Menu list will rebuild with new exclusions
    });
  },
  availableDietaryPreferences: [2, 6, 7], // Pescetarian, Vegan, Vegetarian
  currentLanguage: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  initialSelectedPreferenceId: FFAppState().selectedDietaryPreferenceId,
  currentlyExcludedAllergyIdsFromParent: FFAppState().excludedAllergyIds,
  currentResultCount: _filteredMenuItems.length,
  currentSelectedRestrictionId: FFAppState().selectedDietaryRestrictionId,
)
```

### Required Setup
1. FFAppState must have `selectedDietaryPreferenceId` int? initialized (null OK)
2. FFAppState must have `excludedAllergyIds` list initialized (empty list OK)
3. FFAppState must have `selectedDietaryRestrictionId` int? initialized (null OK)
4. FFAppState must have `translationsCache` populated with preference translations
5. Parent page must re-filter menu items when `onDietaryPreferenceChanged` fires
6. Parent page must merge implied allergen exclusions with existing allergen exclusions
7. Menu items must have allergen ID arrays for matching

---

## Edge Cases Handled

1. **Null initialSelectedPreferenceId** - Defaults to no selection (line 139)
2. **Missing translation** - Preference skipped with warning (line 537)
3. **Empty translation** - Treated as missing (line 200)
4. **Translation with ⚠️ prefix** - Treated as missing (line 200)
5. **Rapid toggling** - Each toggle tracked separately, no debounce
6. **Language change mid-session** - Rebuilds with new translations (line 152-156)
7. **Translation cache update** - Rebuilds with new data (line 152-156)
8. **Parent allergen state change** - Re-validates preference validity (line 238-249)
9. **Parent restriction state change** - Re-calculates implied allergens (line 253-261)
10. **Preference becomes invalid** - Auto-deselects and notifies parent (line 321-324)
11. **Same preference tapped twice** - Deselects preference (line 467-469)
12. **Scroll controller disposal** - Properly disposed to prevent leaks (line 167)
13. **Analytics tracking failure** - Logged but doesn't crash (line 518-520)
14. **Null currentlyExcludedAllergyIdsFromParent** - Treated as empty list (line 282)
15. **Preference without allergen requirements** - Handled gracefully (line 305-309)

---

## Integration with Menu Filtering

### Data Flow
1. **User taps preference button** → Widget toggles internal state
2. **Widget calls `onDietaryPreferenceChanged`** → Parent receives preference ID and implied allergens
3. **Parent updates FFAppState.selectedDietaryPreferenceId** → Persists selection
4. **Parent merges implied allergens into FFAppState.excludedAllergyIds** → Applies exclusions
5. **Parent re-filters menu items** → Hides items with excluded allergens
6. **Parent updates `currentResultCount`** → Passed back to widget for analytics

### Menu Item Matching Pattern
```dart
// Example: Filtering menu items by allergen exclusions (including dietary preferences)
final filteredItems = allMenuItems.where((item) {
  // If user has excluded allergens (from direct selection or dietary preference)
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

### Coordination with AllergiesFilterWidget
**Important:** Both widgets affect `FFAppState().excludedAllergyIds`, so coordination is critical:

1. **Dietary preference selected** → Adds implied allergens to exclusion list
2. **User manually de-selects required allergen** → Dietary preference auto-deselects
3. **Dietary preference deselected** → Implied allergens remain (don't auto-remove)
4. **Restriction selected** → May auto-select dietary preference if exact match

**Example Flow:**
```
1. User selects Vegan → excludes [3, 4, 5, 7, 8]
2. User manually re-includes Milk (7) via allergen filter
3. Vegan preference auto-deselects (validation failed)
4. Other allergens [3, 4, 5, 8] remain excluded
```

---

## Validation State Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Initial Validation                       │
│                    (Post-Frame in initState)                 │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
                 ┌───────────────────────┐
                 │  Preference Selected? │
                 └───────────────────────┘
                      │              │
                   Yes│              │No
                      ▼              ▼
        ┌─────────────────────┐   ┌──────────────────┐
        │ Check if all        │   │ No action needed │
        │ required allergens  │   │ (no preference)  │
        │ still excluded      │   └──────────────────┘
        └─────────────────────┘
                │          │
             Valid│        │Invalid
                  ▼        ▼
        ┌──────────────┐  ┌────────────────────┐
        │ Keep         │  │ Clear preference   │
        │ preference   │  │ Notify parent      │
        └──────────────┘  └────────────────────┘
                             │
                             ▼
                  ┌─────────────────────┐
                  │ User sees button    │
                  │ change to grey      │
                  └─────────────────────┘
```

---

## Migration Notes

### Phase 3 Strategy

**FlutterFlow → Pure Flutter**

#### 1. State Management
```dart
// Before (FlutterFlow):
FFAppState().selectedDietaryPreferenceId
FFAppState().excludedAllergyIds

// After (Riverpod):
final selectedPreferenceProvider = StateNotifierProvider<SelectedPreferenceNotifier, int?>(...);
final excludedAllergensProvider = StateNotifierProvider<ExcludedAllergensNotifier, List<int>>(...);
```

#### 2. Translation System
```dart
// Before:
getTranslations(languageCode, key, translationsCache)

// After:
AppLocalizations.of(context)!.dietary6Cap
```

#### 3. Analytics Tracking
```dart
// Before:
trackAnalyticsEvent('dietary_preference_toggled', {...})

// After:
ref.read(analyticsProvider.notifier).trackEvent(
  'dietary_preference_toggled',
  properties: {...},
);
```

#### 4. Callback Pattern
```dart
// Before (async callback):
onDietaryPreferenceChanged: (id, allergens) async { ... }

// After (synchronous state update):
onDietaryPreferenceChanged: (id, allergens) {
  ref.read(selectedPreferenceProvider.notifier).update(id);
  ref.read(excludedAllergensProvider.notifier).addImplied(allergens);
}
```

#### 5. Validation Logic
**Keep identical:** The validation logic is complex and well-tested. Port it as-is to pure Flutter.

---

## Related Elements

### Used By Pages
- **FullMenu** (`full_menu_widget.dart`) - Primary implementation for menu filtering

### Related Widgets
- `AllergiesFilterWidget` - Direct allergen selection (multi-select)
- `RestrictionFiltersWidget` - Dietary restrictions (single-select, different concept)
- `MenuItemCard` - Displays individual menu items (filtered by this widget)

### Related Actions
- `markUserEngaged` - User engagement tracking
- `trackAnalyticsEvent` - Event logging
- `updateMenuSessionFilterMetrics` - Session-level metrics
- `startMenuSession` - Initializes menu session with dietary context
- `endMenuSession` - Finalizes menu session with dietary usage stats

### Related Functions
- `getTranslations` - Localization

---

## Testing Checklist

When implementing in Flutter:

- [ ] Display all 3 dietary preference buttons with correct translations
- [ ] Sort preferences alphabetically by localized name
- [ ] Tap preference - verify button changes to orange (selected)
- [ ] Tap same preference - verify button returns to grey (deselected)
- [ ] Tap different preference - verify only one selected at a time
- [ ] Select Vegan - verify implied allergens [3,4,5,7,8] passed to callback
- [ ] Select Vegetarian - verify implied allergens [3,5,8] passed to callback
- [ ] Select Pescetarian - verify empty allergen list passed to callback
- [ ] Select Vegan, then manually re-include Milk - verify Vegan auto-deselects
- [ ] Select preference - verify `onDietaryPreferenceChanged` callback fires
- [ ] Deselect preference - verify callback receives null and empty list
- [ ] Change language - verify button text updates
- [ ] Scroll horizontally - verify all buttons accessible
- [ ] Missing translation - verify preference skipped gracefully
- [ ] Null initialSelectedPreferenceId - verify defaults to no selection
- [ ] Rapid toggling - verify each toggle tracked separately
- [ ] Parent allergen state change - verify preference re-validated
- [ ] Parent restriction state change - verify implied allergens recalculated
- [ ] Widget disposal - verify no memory leaks
- [ ] Analytics tracking - verify events logged correctly
- [ ] Menu session metrics - verify currentResultCount used
- [ ] 200ms animation - verify smooth color transitions
- [ ] Button spacing - verify 8px gaps between buttons
- [ ] Button height - verify 32px constraint
- [ ] Initial sync validation - verify runs post-frame
- [ ] Validation callback - verify only triggers when appropriate

---

## Known Issues

None currently documented.

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with Riverpod State Management
