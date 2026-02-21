# DietaryRestrictionsFilterWidget

**Type:** Custom Widget
**File:** `dietary_restrictions_filter_widget.dart` (618 lines)
**Category:** Filters & Menu
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Critical menu filtering)

---

## Purpose

A horizontal scrollable widget that displays dietary restriction filter buttons for filtering menu items based on dietary needs (gluten-free, lactose-free) and religious requirements (halal, kosher). Features intelligent auto-selection when allergen exclusions match restriction requirements and automatic deselection when requirements are no longer satisfied.

**Key Features:**
- 4 dietary restriction options (gluten-free, lactose-free, halal, kosher)
- Single-select radio-style functionality (one restriction at a time)
- Smart auto-selection based on allergen exclusions
- Automatic deselection when allergen requirements no longer met
- Custom display order: dietary needs first, then religious restrictions
- Updates FFAppState.selectedDietaryRestrictionId
- Integration with allergen filter widget
- Translation support for 15 languages
- Analytics tracking for each toggle interaction
- 200ms animation duration for state changes

---

## Parameters

```dart
DietaryRestrictionsFilterWidget({
  super.key,
  this.width,
  this.height,
  required this.onDietaryRestrictionChanged,
  required this.availableDietaryRestrictions,
  required this.currentLanguage,
  required this.translationsCache,
  this.initialSelectedRestrictionId,
  required this.currentlyExcludedAllergyIdsFromParent,
  required this.currentResultCount,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (defaults to parent width) |
| `height` | `double?` | No | Container height (defaults to 32px) |
| `onDietaryRestrictionChanged` | `Future Function(int?, List<int>)` | **Yes** | Callback when restriction changes, receives selected restriction ID and implied allergen exclusions |
| `availableDietaryRestrictions` | `List<int>` | **Yes** | List of restriction IDs available for selection (1,3,4,5) |
| `currentLanguage` | `String` | **Yes** | Current UI language code (e.g., 'en', 'da') |
| `translationsCache` | `dynamic` | **Yes** | Translation cache containing localized restriction names |
| `initialSelectedRestrictionId` | `int?` | No | Initially selected restriction ID from FFAppState |
| `currentlyExcludedAllergyIdsFromParent` | `List<int>?` | **Yes** | Current allergen exclusion list from parent (for auto-selection) |
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
| `markUserEngaged()` | Extends user engagement window by 15s | 411 |
| `trackAnalyticsEvent()` | Tracks dietary restriction toggle events | 466-479 |
| `updateMenuSessionFilterMetrics()` | Updates session-level filter impact metrics | 420 |

### Custom Functions Used

| Function | Purpose | Line Reference |
|----------|---------|----------------|
| `getTranslations()` | Retrieves localized restriction names | 170-172 |

---

## FFAppState Usage

### Read Properties

| Property | Purpose | Read Location |
|----------|---------|---------------|
| N/A | Widget receives state via props | - |

### Write Properties

| Property | Purpose | Write Location |
|----------|---------|---------------|
| `selectedDietaryRestrictionId` | Stored via callback (parent updates) | 375, 449 (via `onDietaryRestrictionChanged`) |

### State Listening

Widget does NOT directly read/write FFAppState. All state flows through:
1. Parent provides `initialSelectedRestrictionId` from FFAppState
2. Parent provides `currentlyExcludedAllergyIdsFromParent` from FFAppState
3. Widget calls `onDietaryRestrictionChanged` callback with updated restriction ID and implied allergens
4. Parent updates FFAppState.selectedDietaryRestrictionId
5. Parent may update FFAppState.excludedAllergyIds based on implied allergens

---

## Lifecycle Events

### initState (lines 130-140)
```dart
@override
void initState() {
  super.initState();
  _scrollController = ScrollController();
  _selectedDietaryRestrictionId = widget.initialSelectedRestrictionId;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) {
      _validateCurrentRestrictionAgainstParentAllergens(isInitialSync: true);
    }
  });
}
```

**Actions:**
- Creates scroll controller for horizontal list
- Initializes selected restriction from parent
- Schedules post-frame validation to check if restriction should be auto-selected/deselected

### didUpdateWidget (lines 142-156)
**Triggers Handled:**
- `translationsCache` change → Rebuild UI (line 147-151)
- `currentLanguage` change → Rebuild UI (line 148-151)
- `initialSelectedRestrictionId` change → Handle restriction prop changes (line 154)
- `currentlyExcludedAllergyIdsFromParent` change → Handle allergen prop changes (line 155)

**Optimization:** Uses `DeepCollectionEquality` to prevent unnecessary state changes

### dispose (lines 158-162)
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

### onTap Restriction Button (Selected State)
**Trigger:** User taps a selected dietary restriction button (e.g., "Gluten-free" when orange)
**Line:** 549 (via `onPressed`)

**Actions:**
1. Deselects the restriction (sets to null)
2. Marks user as engaged (`markUserEngaged`)
3. Tracks analytics event with "deselected" action
4. Calls `onDietaryRestrictionChanged` callback with null and empty allergen list
5. Updates menu session filter metrics with current result count

**Visual Feedback:**
- Button animates from orange to grey over 200ms
- Text changes from white to dark grey
- Border appears on button

### onTap Restriction Button (Unselected State)
**Trigger:** User taps an unselected dietary restriction button (e.g., "Lactose-free" when grey)
**Line:** 549 (via `onPressed`)

**Actions:**
1. Selects the new restriction (replaces any previous selection)
2. Marks user as engaged (`markUserEngaged`)
3. Tracks analytics event with "selected" action and implied allergens
4. Calls `onDietaryRestrictionChanged` callback with restriction ID and implied allergen list
5. Updates menu session filter metrics with current result count

**Visual Feedback:**
- Previous button (if any) animates to grey
- New button animates to orange over 200ms
- Text changes to white
- Border disappears

---

## Display States

### Selected State (Restriction Active)
**Condition:** `_selectedDietaryRestrictionId == restrictionId`

**Visual:**
- Orange background (`#FFEE8B60`)
- White text
- No border
- Menu items meeting this restriction ARE shown
- Implied allergens ARE excluded from menu

### Unselected State (Restriction Inactive)
**Condition:** `_selectedDietaryRestrictionId != restrictionId`

**Visual:**
- Light grey background (`#FFF2F3F5`)
- Dark grey text (`#FF242629`)
- Grey border (`Colors.grey[500]`)
- Restriction is NOT applied to menu filtering

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
- Custom sort order: dietary needs first, then religious restrictions
- No scroll indicators (iOS/Android default)
- Buttons sized to content width (min 0px)

---

## Dietary Restriction Data

### Restriction IDs and Allergen Mappings

| ID | Restriction | Translation Key | Implied Allergen Exclusions | Auto-Selectable |
|----|-------------|----------------|----------------------------|-----------------|
| 1 | Gluten-free | `dietary_1_cap` | Gluten (ID: 2) | ✅ Yes |
| 4 | Lactose-free | `dietary_4_cap` | Milk (ID: 7) | ✅ Yes |
| 3 | Halal | `dietary_3_cap` | None | ❌ No |
| 5 | Kosher | `dietary_5_cap` | None | ❌ No |

### Custom Display Order (line 119-124)
```dart
static const List<int> _preferredOrder = [
  _glutenFreeId,    // 1
  _lactoseFreeId,   // 4
  _halalId,         // 3
  _kosherId,        // 5
];
```

**Rationale:** Dietary needs (gluten-free, lactose-free) appear before religious restrictions (halal, kosher)

---

## Auto-Selection Logic

### When Auto-Selection Triggers (lines 318-346)

**Condition:** Parent's excluded allergen list EXACTLY matches a restriction's required allergens

**Algorithm:**
1. User excludes allergens using AllergiesFilterWidget
2. DietaryRestrictionsFilterWidget receives updated allergen list via `currentlyExcludedAllergyIdsFromParent`
3. Widget checks if allergen exclusions exactly match any auto-selectable restriction:
   - **Gluten (ID: 2) excluded** → Auto-select "Gluten-free" (ID: 1)
   - **Milk (ID: 7) excluded** → Auto-select "Lactose-free" (ID: 4)
4. If exact match found, restriction is auto-selected
5. Callback fires with new restriction ID and implied allergens

**Example Flow:**
```
User excludes "Gluten" → currentlyExcludedAllergyIdsFromParent = [2]
→ Exact match with gluten-free requirement
→ Auto-select "Gluten-free" button (turns orange)
→ onDietaryRestrictionChanged(1, [2]) fires
```

### When Auto-Deselection Triggers (lines 282-308)

**Condition:** Currently selected restriction's required allergens are no longer all excluded

**Algorithm:**
1. User has "Gluten-free" selected (requires gluten excluded)
2. User re-includes gluten allergen (removes from exclusion list)
3. Widget detects gluten (ID: 2) is no longer in `currentlyExcludedAllergyIdsFromParent`
4. "Gluten-free" requirement no longer satisfied
5. Widget auto-deselects restriction
6. Callback fires with null restriction ID and empty allergen list

**Example Flow:**
```
"Gluten-free" selected → User clicks "Gluten" allergen to include it
→ currentlyExcludedAllergyIdsFromParent = []
→ Gluten-free requirement NOT satisfied
→ Auto-deselect "Gluten-free" button (turns grey)
→ onDietaryRestrictionChanged(null, []) fires
```

### Restrictions Excluded from Auto-Selection (line 113-116)

**Halal and Kosher are NOT auto-selectable** because:
- They have no allergen requirements (`_restrictionToImpliedAllergensMap[3] = []`)
- They represent user intent/religious preference, not allergen-derived filtering
- User must explicitly select these restrictions

---

## State Management

### Internal State
```dart
int? _selectedDietaryRestrictionId;
```
**Purpose:** Tracks currently selected dietary restriction ID (null if none selected)
**Lifecycle:** Initialized from `initialSelectedRestrictionId`, updated on toggle or auto-selection

### Synchronization Points

#### 1. Widget Prop Changes (lines 217-230)
**Trigger:** `initialSelectedRestrictionId` changes from parent
**Actions:**
- Update internal state if different from widget prop
- Validate restriction against current allergen exclusions
- Trigger callback if state changed

#### 2. Allergen Prop Changes (lines 232-245)
**Trigger:** `currentlyExcludedAllergyIdsFromParent` changes from parent
**Actions:**
- Validate current restriction still meets allergen requirements
- Auto-select restriction if allergens exactly match requirements
- Auto-deselect restriction if requirements no longer met
- Trigger callback if state changed

**Optimization:** Uses `DeepCollectionEquality` to prevent unnecessary validation (line 234)

### Validation Flow (lines 252-280)

```dart
void _validateCurrentRestrictionAgainstParentAllergens({
  bool triggerCallbackIfChanged = false,
  bool isInitialSync = false,
}) {
  final validationResult = _performValidation();
  final restrictionChanged = _applyValidationResult(validationResult);
  _triggerCallbackIfNeeded(
    validationResult,
    restrictionChanged,
    isInitialSync,
    triggerCallbackIfChanged
  );
}
```

**Three-Phase Process:**
1. **Validation** - Check allergen match, validate existing selection
2. **Application** - Update internal state if changed
3. **Notification** - Trigger callback if conditions met

---

## Translation System

### Translation Key Format
```dart
final translationKey = 'dietary_${restrictionId}_cap';
```

**Examples:**
- `dietary_1_cap` → "Gluten-free" / "Glutenfri"
- `dietary_4_cap` → "Lactose-free" / "Laktosefri"
- `dietary_3_cap` → "Halal" / "Halal"
- `dietary_5_cap` → "Kosher" / "Kosher"

### Translation Retrieval (lines 184-201)
```dart
String? _getRestrictionNameSafe(int? restrictionId) {
  // Guard: null or zero ID
  if (restrictionId == null || restrictionId == 0) {
    return null;
  }

  final translationKey = 'dietary_${restrictionId}_cap';
  final restrictionName = _getUIText(translationKey);

  // Return null if translation not found (indicated by empty or ⚠️ prefix)
  if (restrictionName.isEmpty || restrictionName.startsWith('⚠️')) {
    debugPrint(
      '⚠️ Missing translation for $translationKey in ${widget.currentLanguage}'
    );
    return null;
  }

  return restrictionName;
}
```

### Missing Translation Handling
- If translation missing → Returns `null` (line 187-188, 194-199)
- Missing translations skipped from display (line 494-496)
- Warning logged to console: `⚠️ Missing translation for dietary_X in {language}` (line 195-196)
- Fallback used for internal logging: `'Restriction $restrictionId'` (line 209)

---

## Analytics Tracking

### Event: dietary_restriction_toggled
**Tracked on:** Every dietary restriction button tap (line 466)

**Event Data:**
```dart
{
  'restriction_id': 1,                           // The restriction ID (1,3,4,5)
  'restriction_name': 'Gluten-free',             // Localized restriction name
  'action': 'selected',                          // 'selected' or 'deselected'
  'is_now_selected': true,                       // Boolean selection state
  'implied_allergen_exclusions': [2],            // Allergen IDs this restriction hides
  'implied_allergen_count': 1,                   // Number of implied allergens
  'language': 'en',                              // Current language code
}
```

**Fire-and-Forget Pattern:** Tracking failures caught and logged (line 477-479), won't impact UX

**Use Cases:**
- Understand which dietary restrictions are most commonly used
- Track gluten-free vs lactose-free usage patterns
- Identify religious restriction adoption rates
- Correlate allergen exclusions with restriction selections
- Measure feature engagement by language/region

---

## Integration with Allergen Filter Widget

### Bidirectional Synchronization

#### Parent → DietaryRestrictionsFilterWidget
**Flow:** AllergiesFilterWidget changes → Parent updates state → DietaryRestrictionsFilterWidget receives new allergen list

```dart
// Parent receives allergen changes
onAllergiesChanged: (excludedIds) async {
  FFAppState().update(() {
    FFAppState().excludedAllergyIds = excludedIds;
  });

  // Widget auto-validates and may auto-select/deselect restriction
  // via currentlyExcludedAllergyIdsFromParent prop
}
```

#### DietaryRestrictionsFilterWidget → Parent
**Flow:** Restriction selected → Parent receives implied allergens → May update allergen filter

```dart
onDietaryRestrictionChanged: (restrictionId, impliedAllergens) async {
  FFAppState().update(() {
    FFAppState().selectedDietaryRestrictionId = restrictionId;

    // Parent may choose to sync allergen exclusions with implied allergens
    // (This depends on parent implementation logic)
  });
}
```

### Example Scenarios

#### Scenario 1: User Selects "Gluten-free"
1. User taps "Gluten-free" button
2. Widget calls `onDietaryRestrictionChanged(1, [2])`
3. Parent updates `FFAppState.selectedDietaryRestrictionId = 1`
4. Parent MAY add gluten (ID: 2) to `FFAppState.excludedAllergyIds`
5. AllergiesFilterWidget receives updated exclusion list and greys out "Gluten"

#### Scenario 2: User Excludes Milk Allergen
1. User taps "Milk" in AllergiesFilterWidget
2. Parent updates `FFAppState.excludedAllergyIds = [7]`
3. DietaryRestrictionsFilterWidget receives `currentlyExcludedAllergyIdsFromParent = [7]`
4. Widget detects exact match with lactose-free requirement
5. Widget auto-selects "Lactose-free" (turns orange)
6. Widget calls `onDietaryRestrictionChanged(4, [7])`
7. Parent updates `FFAppState.selectedDietaryRestrictionId = 4`

#### Scenario 3: User Deselects Gluten While "Gluten-free" Active
1. "Gluten-free" is selected (orange)
2. User taps "Gluten" in AllergiesFilterWidget to include it
3. Parent updates `FFAppState.excludedAllergyIds = []`
4. DietaryRestrictionsFilterWidget receives `currentlyExcludedAllergyIdsFromParent = []`
5. Widget detects gluten-free requirement no longer satisfied
6. Widget auto-deselects "Gluten-free" (turns grey)
7. Widget calls `onDietaryRestrictionChanged(null, [])`
8. Parent updates `FFAppState.selectedDietaryRestrictionId = null`

---

## Helper Classes

### _ValidationResult (lines 598-606)
```dart
class _ValidationResult {
  final int? restrictionId;
  final List<int> impliedAllergens;

  _ValidationResult({
    required this.restrictionId,
    required this.impliedAllergens,
  });
}
```

**Purpose:** Encapsulates validation result from auto-selection/deselection logic
**Fields:**
- `restrictionId` - Restriction ID to select (null if none)
- `impliedAllergens` - Allergen IDs implied by this restriction

### _SelectionResult (lines 609-617)
```dart
class _SelectionResult {
  final int? restrictionId;
  final List<int> impliedAllergens;

  _SelectionResult({
    required this.restrictionId,
    required this.impliedAllergens,
  });
}
```

**Purpose:** Encapsulates user selection result for callback
**Fields:**
- `restrictionId` - Selected restriction ID (null if deselected)
- `impliedAllergens` - Allergen IDs implied by this restriction

---

## Performance Optimizations

1. **DeepCollectionEquality Checks**
   - Prevents unnecessary validation when parent passes same allergen list (line 234)
   - Uses `collection` package for efficient list comparison

2. **SetEquality for Exact Match**
   - Efficient set comparison for auto-selection logic (line 337)
   - Prevents false positives from partial matches

3. **Null-Safe Translation Lookup**
   - Returns early if translation missing (line 187-188)
   - Skips restrictions without valid translations (line 494-496)

4. **Custom Sort Order**
   - Pre-defined order prevents runtime sorting logic (line 119-124)
   - Sorted once during build, not on every validation

5. **Post-Frame Callback for Initial Validation**
   - Defers validation until after first frame (line 135-139)
   - Prevents unnecessary work during widget construction

6. **Optimistic UI Updates**
   - Button state changes immediately (no async wait)
   - Callback and analytics run async without blocking

7. **Minimal State**
   - Only tracks selected restriction ID (int?)
   - No redundant state for implied allergens or button colors

8. **ListView.separated**
   - Efficient horizontal list rendering
   - Only builds visible items
   - Consistent spacing with `separatorBuilder`

---

## Usage Example

### In FlutterFlow Page Widget (Full Menu Page)

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
custom_widgets.DietaryRestrictionsFilterWidget(
  width: double.infinity,
  height: 32,
  onDietaryRestrictionChanged: (restrictionId, impliedAllergens) async {
    FFAppState().update(() {
      FFAppState().selectedDietaryRestrictionId = restrictionId;

      // Optionally sync allergen exclusions with implied allergens
      if (restrictionId != null && impliedAllergens.isNotEmpty) {
        // Add implied allergens to exclusion list
        final currentExclusions = Set<int>.from(
          FFAppState().excludedAllergyIds
        );
        currentExclusions.addAll(impliedAllergens);
        FFAppState().excludedAllergyIds = currentExclusions.toList();
      }
    });

    // Trigger menu filtering
    setState(() {
      // Menu list will rebuild with new restriction
    });
  },
  availableDietaryRestrictions: [1, 3, 4, 5], // All 4 restrictions
  currentLanguage: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
  initialSelectedRestrictionId: FFAppState().selectedDietaryRestrictionId,
  currentlyExcludedAllergyIdsFromParent: FFAppState().excludedAllergyIds,
  currentResultCount: _filteredMenuItems.length,
)
```

### Required Setup
1. FFAppState must have `selectedDietaryRestrictionId` (nullable int, null OK)
2. FFAppState must have `excludedAllergyIds` list for synchronization
3. FFAppState must have `translationsCache` populated with restriction translations
4. Parent page must re-filter menu items when `onDietaryRestrictionChanged` fires
5. Parent page should pass allergen exclusions to enable auto-selection logic

---

## Edge Cases Handled

1. **Null initialSelectedRestrictionId** - Defaults to no selection (line 134)
2. **Null currentlyExcludedAllergyIdsFromParent** - Defaults to empty list (line 265)
3. **Missing translation** - Restriction skipped with warning (line 195-196, 494-496)
4. **Empty translation** - Treated as missing (line 194)
5. **Translation with ⚠️ prefix** - Treated as missing (line 194)
6. **Zero or invalid restriction ID** - Returns null from translation lookup (line 186-188)
7. **Partial allergen match** - No auto-selection (requires exact match, line 336-342)
8. **Halal/Kosher auto-selection** - Blocked by auto-selectable whitelist (line 333)
9. **Rapid toggling** - Each toggle tracked separately, no debounce
10. **Language change mid-session** - Rebuilds with new translations (line 147-151)
11. **Translation cache update** - Rebuilds with new data (line 147-151)
12. **Parent restriction prop change** - Syncs internal state and validates (line 217-230)
13. **Parent allergen prop change** - Validates and may auto-select/deselect (line 232-245)
14. **Scroll controller disposal** - Properly disposed to prevent leaks (line 161)
15. **Analytics tracking failure** - Logged but doesn't crash (line 477-479)
16. **Implied allergens callback** - Empty list for halal/kosher (line 108-109)
17. **Initial sync validation** - Triggers callback even if state unchanged (line 366-377)

---

## Testing Checklist

When implementing in Flutter:

- [ ] Display all 4 dietary restriction buttons with correct translations
- [ ] Sort restrictions by preferred order (gluten-free, lactose-free, halal, kosher)
- [ ] Tap restriction - verify button changes to orange (selected)
- [ ] Tap selected restriction - verify button returns to grey (deselected)
- [ ] Tap restriction - verify `onDietaryRestrictionChanged` callback fires
- [ ] Select restriction - verify menu items update correctly
- [ ] Select different restriction - verify previous deselects and new selects
- [ ] Deselect restriction - verify all buttons return to grey
- [ ] Exclude gluten allergen - verify "Gluten-free" auto-selects (orange)
- [ ] Include gluten allergen - verify "Gluten-free" auto-deselects (grey)
- [ ] Exclude milk allergen - verify "Lactose-free" auto-selects (orange)
- [ ] Include milk allergen - verify "Lactose-free" auto-deselects (grey)
- [ ] Exclude multiple allergens - verify no auto-selection (not exact match)
- [ ] Exclude gluten+milk - verify no auto-selection (neither is exact match)
- [ ] Select halal - verify no allergen exclusions implied
- [ ] Select kosher - verify no allergen exclusions implied
- [ ] Exclude gluten with halal selected - verify halal stays selected (no auto-deselect)
- [ ] Change language - verify button text updates
- [ ] Scroll horizontally - verify all buttons accessible
- [ ] Missing translation - verify restriction skipped gracefully
- [ ] Null initialSelectedRestrictionId - verify defaults to no selection
- [ ] Null currentlyExcludedAllergyIdsFromParent - verify defaults to empty
- [ ] Rapid toggling - verify each toggle tracked separately
- [ ] Parent restriction prop change - verify internal state syncs
- [ ] Parent allergen prop change - verify validation runs
- [ ] Widget disposal - verify no memory leaks
- [ ] Analytics tracking - verify events logged correctly
- [ ] Menu session metrics - verify currentResultCount used
- [ ] 200ms animation - verify smooth color transitions
- [ ] Button spacing - verify 8px gaps between buttons
- [ ] Button height - verify 32px constraint
- [ ] Implied allergens callback - verify correct list passed (gluten/milk)
- [ ] Empty implied allergens - verify empty list for halal/kosher

---

## Known Issues

None currently documented.

---

## Related Elements

### Used By Pages
- **FullMenu** (`full_menu_widget.dart`) - Primary implementation for menu filtering

### Related Widgets
- `AllergiesFilterWidget` - Allergen exclusion filter (bidirectional sync)
- `MenuItemCard` - Displays individual menu items (filtered by this widget)
- `FilterOverlayWidget` - Main filter interface (different filter type)

### Related Actions
- `markUserEngaged` - User engagement tracking
- `trackAnalyticsEvent` - Event logging
- `updateMenuSessionFilterMetrics` - Session-level metrics
- `startMenuSession` - Initializes menu session with dietary restriction context
- `endMenuSession` - Finalizes menu session with restriction usage stats

### Related Functions
- `getTranslations` - Localization

---

## Migration Notes

### Phase 3 Strategy

**FlutterFlow → Pure Flutter**

#### 1. State Management
```dart
// Before (FlutterFlow):
FFAppState().selectedDietaryRestrictionId
FFAppState().excludedAllergyIds

// After (Riverpod):
final selectedRestrictionProvider = StateNotifierProvider<SelectedRestrictionNotifier, int?>(...);
final excludedAllergiesProvider = StateNotifierProvider<ExcludedAllergiesNotifier, List<int>>(...);
```

#### 2. Translation System
```dart
// Before:
getTranslations(languageCode, key, translationsCache)

// After:
AppLocalizations.of(context)!.dietary1Cap
```

#### 3. Analytics Tracking
```dart
// Before:
trackAnalyticsEvent('dietary_restriction_toggled', {...})

// After:
ref.read(analyticsProvider.notifier).trackEvent(
  'dietary_restriction_toggled',
  properties: {...},
);
```

#### 4. Callback Pattern
```dart
// Before (async callback):
onDietaryRestrictionChanged: (restrictionId, impliedAllergens) async { ... }

// After (synchronous state update):
onDietaryRestrictionChanged: (restrictionId, impliedAllergens) {
  ref.read(selectedRestrictionProvider.notifier).update(restrictionId);
  // Handle implied allergens synchronization if needed
}
```

#### 5. Auto-Selection Validation
```dart
// Before (prop-based):
currentlyExcludedAllergyIdsFromParent: FFAppState().excludedAllergyIds

// After (provider watch):
ref.watch(excludedAllergiesProvider) // Auto-rebuilds on change
```

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with Riverpod State Management
