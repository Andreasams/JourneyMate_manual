# Business Feature Buttons Widget — Master Documentation

**Widget Name:** `BusinessFeatureButtons`
**Source File:** `_flutterflow_export/lib/custom_code/widgets/business_feature_buttons.dart`
**Migrated File:** `journey_mate/lib/widgets/business_feature_buttons.dart`
**Type:** StatefulWidget (Custom Widget)
**Category:** Business Profile Components
**Complexity:** High (849 lines, complex filter logic)

---

## Purpose

Displays a business's features and preferences as interactive filter buttons on the Business Profile page. This widget is responsible for:

1. **Visual Filter Representation** — Shows which filters match between user's search needs and business offerings
2. **Smart Display Logic** — Implements complex rules for hiding/showing/synthesizing parent filters
3. **Dynamic Height Calculation** — Precisely calculates required height based on text measurements and wrap layout
4. **Info Icon Integration** — Displays info icons for filters with descriptions
5. **Selection State Display** — Highlights filters that match user's active search

The widget is critical for helping users understand WHY a restaurant matched their search criteria.

---

## Function Signature

```dart
class BusinessFeatureButtons extends StatefulWidget {
  const BusinessFeatureButtons({
    super.key,
    this.width,
    this.height,
    required this.containerWidth,
    required this.filters,
    this.filtersUsedForSearch,
    this.filtersOfThisBusiness,
    this.filterDescriptions,
    required this.onInitialCount,
    this.onFilterTap,
    this.onHeightCalculated,
  });

  final double? width;
  final double? height;
  final double containerWidth;
  final dynamic filters;                              // Hierarchical filter structure
  final List<int>? filtersUsedForSearch;              // User's active filters
  final List<int>? filtersOfThisBusiness;             // Business's filters
  final dynamic filterDescriptions;                   // Filter ID -> description map
  final Future Function(int count) onInitialCount;    // Callback with filter count
  final Future Function(
      int filterId,
      String filterName,
      String? filterDescription
  )? onFilterTap;                                     // Info icon tap handler
  final Future Function(double height)? onHeightCalculated; // Height callback

  @override
  State<BusinessFeatureButtons> createState() => _BusinessFeatureButtonsState();
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `containerWidth` | `double` | Width of the container for wrap layout calculations. Used for precise height calculation. Pass `MediaQuery.of(context).size.width - 32` for full width minus padding. |
| `filters` | `dynamic` | Hierarchical filter structure from BuildShip API. Can be `Map` with `filters` key or direct `List`. Contains full filter hierarchy with IDs, names, types, and children. |
| `onInitialCount` | `Future Function(int)` | Called after filter count is calculated. Passes count of visible filters. Used for analytics or conditional rendering. |

### Optional Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `width` | `double?` | Widget width. If null, uses available width. |
| `height` | `double?` | Widget height. Should be set based on `onHeightCalculated` callback. |
| `filtersUsedForSearch` | `List<int>?` | List of filter IDs from user's active search. Used to highlight matching filters with orange border/background. |
| `filtersOfThisBusiness` | `List<int>?` | List of filter IDs that this business has. Only these filters are displayed. |
| `filterDescriptions` | `dynamic` | Filter descriptions for info icons. Can be `List<Map>` with `filter_id` and `description`, or `Map<int, String>`. |
| `onFilterTap` | `Future Function(int, String, String?)?` | Called when filter button with description is tapped. Receives `filterId`, `filterName`, and `filterDescription`. Use to show FilterDescriptionSheet. |
| `onHeightCalculated` | `Future Function(double)?` | Called with precisely calculated height needed for wrap layout. Parent should use this to update widget height. |

---

## Dependencies

### External Packages
- `flutter/material.dart` — Core Flutter widgets
- `dart:ui` — For `TextPainter` text measurement

### Internal Services
- **FlutterFlow Version:** `markUserEngaged()`, `trackAnalyticsEvent()`
- **Migrated Version:** `AnalyticsService` — For engagement tracking and analytics

### Data Sources
- **Hierarchical Filter Structure** — From BuildShip API (`filtersData` endpoint)
- **Filter Descriptions** — From BuildShip API (`filterDescriptions` endpoint)
- **User's Active Filters** — From `FFAppState.filtersUsedForSearch`
- **Business Filters** — From business record's `filter_ids` array

---

## State Management

### FlutterFlow Version
```dart
// No local state variables
// Relies on widget properties passed from parent
```

### Migrated Version
```dart
class _BusinessFeatureButtonsState extends State<BusinessFeatureButtons> {
  late AnalyticsService _analyticsService;

  @override
  void initState() {
    super.initState();
    _analyticsService = AnalyticsService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndNotifyMetrics();
    });
  }
}
```

**State Notes:**
- Widget is stateful but has minimal mutable state
- Most logic is in computed methods that process widget properties
- Height calculation happens post-frame to ensure accurate measurements

---

## Filter Business Logic

### Filter Configuration Constants

#### Special Parent Filters
Filters that display as aggregate labels instead of showing individual children:

```dart
static const List<int> _specialParentFilters = [
  100,  // Shared Menu
  101,  // Multi-course Menu
  20,   // Outdoor Seating
  22,   // Private Seating
  4,    // Michelin Rated
  543,  // Group bookings (with dynamic label)
];

static const Map<int, List<int>> _specialParentChildren = {
  100: [110, 111, 112, 113, 114],              // Shared Menu children
  101: [116, 117, 118, 119, 120],              // Multi-course Menu children
  20: [133, 136, 137, 138],                    // Outdoor Seating children
  22: [143, 144, 145, 146, 147, 148, 149],     // Private Seating children
  4: [24, 25, 26, 27],                         // Michelin star levels
  543: [544, 545, 546, 547, 548, 549, 550],    // Group size ranges
};
```

**Special Handling:**
- If any child exists on business, parent button is synthesized
- Parent displays instead of individual children
- Group bookings (543) shows dynamic label like "Group bookings: 10-19" or "Group bookings: 40+"

#### Excluded Filters
Filters that should never be displayed:

```dart
// Payment filters (entire category 21 + all payment methods)
static const int _paymentCategoryId = 21;
static const List<int> _allPaymentFilters = [
  _paymentCategoryId,
  139, 140, 141, 142, 423, 434, 435, 445,    // Payment methods
  425, 426, 427, 428, 429, 430, 431, 432,    // Card types
];

// Category 11 and all its children/grandchildren
static const int _excludedCategoryId = 11;
static const List<int> _excludedCategoryChildren = [
  90, 91, 92, 93, 94, 95, 96, 97,
];
```

**Exclusion Rules:**
- Payment filters excluded because payment methods aren't a search criteria
- Category 11 excluded by product decision
- Composite dietary filters (6-digit IDs like 592057) excluded

#### Mutually Exclusive Pairs
If second filter exists, hide first:

```dart
static const Map<int, int> _mutuallyExclusivePairs = {
  109: 110,  // If 110 exists, hide 109
  174: 173,
  176: 175,
  181: 180,
  183: 182,
};
```

### Filter Visibility Algorithm

The widget implements a sophisticated visibility algorithm:

1. **Flatten Hierarchy** — Convert nested filter structure to flat list
2. **Exclude Categories** — Remove payment filters and category 11
3. **Synthesize Parents** — Create parent buttons for special parents if any child exists
4. **Apply Exclusion Rules** — Hide mutually exclusive pairs
5. **Hide Children** — Hide children under special parents
6. **Filter by Business** — Only show filters business actually has
7. **Sort Results** — Sort by parent_id, then by name

**Key Methods:**
- `_flattenFilters()` — Traverses hierarchy and builds flat list
- `_isExcludedFilter()` — Checks if filter should be excluded
- `_shouldHideFilter()` — Applies visibility business rules
- `_shouldSynthesizeParent()` — Checks if special parent should be created
- `_getOrganizedFilters()` — Main orchestrator, returns final filter list

### Dynamic Label Generation

#### Group Bookings Display Name

```dart
String _getGroupBookingsDisplayName(String baseLabel) {
  // For filter 543 (Group bookings), generates dynamic labels:
  // - "Group bookings: 10-14" (single range)
  // - "Group bookings: 10-19" (multiple ranges)
  // - "Group bookings: 40+" (includes 40+ option)
  // - "Group bookings: 10+" (multiple ranges with 40+)
}
```

**Logic:**
1. Get all selected group booking child filters (544-550)
2. Extract numbers from filter names (e.g., "10-14 personer" → 10)
3. Find min and max
4. Check if "40+" (ID 550) is selected
5. Format appropriately

---

## Height Calculation System

### Precision Text Measurement

The widget uses `TextPainter` for exact text width measurement:

```dart
double _measureTextWidth(String text) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: _buttonTextStyle),
    maxLines: 1,
    textDirection: ui.TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);

  return textPainter.size.width;
}
```

### Button Width Calculation

```dart
double _calculateButtonWidth(int filterId, String filterName) {
  double width = _measureTextWidth(filterName);
  width += _buttonHorizontalPadding * 2;  // 16px each side = 32px

  if (_hasFilterDescription(filterId)) {
    width += _iconSpacing + _iconSize;     // 6px + 16px = 22px
  }

  width += _textMeasurementSafetyMargin;   // 4px safety margin
  return width;
}
```

### Height Calculation Algorithm

Simulates wrap layout to calculate exact height:

```dart
double _calculateRequiredHeight(
  List<Map<String, dynamic>> filters,
  double containerWidth,
) {
  if (filters.isEmpty) return 0.0;

  double currentRowWidth = 0;
  int rowCount = 1;

  for (final filter in filters) {
    final buttonWidth = _calculateButtonWidth(filterId, filterName);
    final spaceNeeded = currentRowWidth > 0
        ? buttonWidth + _buttonSpacing
        : buttonWidth;

    if (currentRowWidth + spaceNeeded > containerWidth) {
      rowCount++;
      currentRowWidth = buttonWidth;
    } else {
      currentRowWidth += spaceNeeded;
    }
  }

  double totalHeight = rowCount * _buttonRowHeight;
  if (rowCount > 1) {
    totalHeight += (rowCount - 1) * _buttonRunSpacing;
  }

  return totalHeight;
}
```

**Constants:**
- Button row height: 32px
- Button spacing: 8px
- Button run spacing: 8px
- Horizontal padding: 16px per side

**Flow:**
1. Iterate through all filters
2. Calculate exact button width including text + padding + icon
3. Simulate wrap layout, tracking when buttons wrap to next row
4. Calculate final height: `(rows × 32px) + ((rows - 1) × 8px)`

### Lifecycle Integration

```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _calculateAndNotifyMetrics();
  });
}

@override
void didUpdateWidget(covariant BusinessFeatureButtons oldWidget) {
  super.didUpdateWidget(oldWidget);

  final dataChanged =
      oldWidget.filterDescriptions != widget.filterDescriptions ||
      oldWidget.filters != widget.filters ||
      oldWidget.containerWidth != widget.containerWidth;

  if (dataChanged) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateAndNotifyMetrics();
    });
  }
}
```

**Why Post-Frame Callback:**
- Text measurement requires layout context
- Ensures accurate measurements after initial render
- Recalculates when data changes

---

## Filter Description Logic

### Description Storage Convention

**Regular Filters:** Description stored on filter ID itself

**Special Parent Filters:** Description stored on **LOWEST child ID**

Example: For "Group bookings" (543) with children [544, 545, 546]:
- If business has [545, 546], check description on 545 (lowest)
- Display info icon on parent button (543)

### Description Detection

```dart
bool _hasFilterDescription(int filterId) {
  // Check if this filter itself has a description
  if (_getFilterDescription(filterId) != null) return true;

  // Special handling for special parents - check lowest child ID
  if (_specialParentFilters.contains(filterId)) {
    final childrenIds = _specialParentChildren[filterId];
    if (childrenIds == null || childrenIds.isEmpty) return false;

    // Get selected children on this business
    final selectedChildren = childrenIds
        .where((id) => widget.filtersOfThisBusiness!.contains(id))
        .toList();

    if (selectedChildren.isEmpty) return false;

    // Check LOWEST selected child ID for description
    final lowestChildId = selectedChildren.reduce((a, b) => a < b ? a : b);
    return _getFilterDescription(lowestChildId) != null;
  }

  return false;
}
```

### Description Retrieval

```dart
String? _getFilterDescription(int filterId) {
  if (widget.filterDescriptions == null) return null;

  // Handle List format: [{ filter_id: 123, description: "..." }, ...]
  if (widget.filterDescriptions is List<dynamic>) {
    final descriptions = widget.filterDescriptions as List<dynamic>;
    final descItem = descriptions.firstWhere(
      (item) => item is Map && item['filter_id'] == filterId,
      orElse: () => null,
    );

    if (descItem is Map) {
      final description = descItem['description'] as String?;
      if (description != null && description.trim().isNotEmpty) {
        return description;
      }
    }
  }
  // Handle Map format: { 123: "description", ... }
  else if (widget.filterDescriptions is Map) {
    final descriptions = widget.filterDescriptions as Map;
    final description = (descriptions[filterId] as String?) ??
        (descriptions[filterId.toString()] as String?);

    if (description != null && description.trim().isNotEmpty) {
      return description;
    }
  }

  return null;
}
```

---

## Selection State Logic

### Filter Selection Detection

```dart
bool _isFilterSelected(int filterId) {
  if (widget.filtersUsedForSearch == null) return false;

  // Check direct selection
  if (widget.filtersUsedForSearch!.contains(filterId)) return true;

  // For special parents, check if ANY child is selected
  if (_specialParentFilters.contains(filterId)) {
    final childrenIds = _specialParentChildren[filterId];
    if (childrenIds == null) return false;

    return childrenIds
        .any((childId) => widget.filtersUsedForSearch!.contains(childId));
  }

  return false;
}
```

**Selection Rules:**
- Direct filter ID match → selected
- Special parent with ANY selected child → selected
- Enables highlighting filters that match user's search

### Visual States

**Unselected Filter:**
- Background: `#f2f3f5` (light gray)
- Border: `Colors.grey.shade500` (medium gray)
- Text: `#242629` (dark gray)
- Font Weight: `300` (light)
- Info icon: `#666666` (medium gray)

**Selected Filter:**
- Background: `#FDF2EC` (light orange)
- Border: `#D35400` (orange, 1px)
- Text: `#D35400` (orange)
- Font Weight: `400` (normal)
- Info icon: `#D35400` (orange)

---

## UI Structure

### Widget Build Tree

```
BusinessFeatureButtons (StatefulWidget)
└── Container (width, height)
    └── SingleChildScrollView
        └── Wrap (spacing: 8px, runSpacing: 8px)
            └── [ElevatedButton, ElevatedButton, ...]
                └── Row (mainAxisSize: min)
                    ├── Flexible
                    │   └── Text (filterName)
                    └── [if hasDescription]
                        ├── SizedBox (width: 6px)
                        └── Icon (Icons.info_outline, size: 16)
```

### Button Style Constants

```dart
static const double _buttonHorizontalPadding = 16.0;
static const double _buttonRowHeight = 32.0;
static const double _buttonSpacing = 8.0;
static const double _buttonRunSpacing = 8.0;
static const double _iconSize = 16.0;
static const double _iconSpacing = 6.0;
static const double _fontSize = 14.0;
static const double _borderRadius = 15.0;
```

### Button Implementation

```dart
Widget _buildSingleFilterButton({
  required int filterId,
  required String filterName,
  required bool hasDescription,
  required bool isSelected,
}) {
  return ElevatedButton(
    onPressed: hasDescription
        ? () => _handleFilterTap(filterId, filterName)
        : null,
    style: _buildButtonStyle(isSelected),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            filterName,
            style: _buildButtonTextStyle(isSelected),
          ),
        ),
        if (hasDescription) ...[
          const SizedBox(width: _iconSpacing),
          Icon(
            Icons.info_outline,
            size: _iconSize,
            color: isSelected
                ? const Color(0xFFD35400)
                : const Color(0xFF666666),
          ),
        ],
      ],
    ),
  );
}
```

**Button Behavior:**
- Only buttons with descriptions are tappable (`onPressed != null`)
- Buttons without descriptions are visual-only (`onPressed: null`)
- Tapping button opens FilterDescriptionSheet via callback

---

## Analytics Tracking

### FlutterFlow Version

```dart
void _trackFilterInfoClick(
    int filterId, String filterName, String? description) {
  trackAnalyticsEvent(
    'filter_info_clicked',
    {
      'filter_id': filterId,
      'filter_name': filterName,
      'has_description': description != null && description.isNotEmpty,
      'description_length': description?.length ?? 0,
    },
  ).catchError((error) {
    debugPrint('⚠️ Failed to track filter info click: $error');
  });
}
```

### Migrated Version

```dart
void _trackFilterInfoClick(
    int filterId, String filterName, String? description) {
  _analyticsService.trackEvent(
    'filter_info_clicked',
    {
      'filter_id': filterId,
      'filter_name': filterName,
      'has_description': description != null && description.isNotEmpty,
      'description_length': description?.length ?? 0,
    },
  );
}
```

### Event: `filter_info_clicked`

**Trigger:** User taps info icon on filter button

**Properties:**
- `filter_id` (int) — Filter ID that was tapped
- `filter_name` (string) — Display name of the filter
- `has_description` (boolean) — Whether description exists
- `description_length` (int) — Length of description text

**Purpose:** Track which filter features users want to learn more about

### User Engagement Marking

**FlutterFlow:** `markUserEngaged()`
**Migrated:** `_analyticsService.markUserEngaged()`

Called when user taps any filter button. Marks session as actively engaged.

---

## Usage Examples

### Example 1: Basic Usage on Business Profile Page

```dart
import 'package:journey_mate/widgets/business_feature_buttons.dart';
import 'package:journey_mate/widgets/filter_description_sheet.dart';

class BusinessProfilePage extends StatefulWidget {
  // ...
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  double _featureButtonsHeight = 0;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final business = widget.business;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ... other sections ...

            // Business Features Section
            if (appState.filtersUsedForSearch.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BusinessFeatureButtons(
                  containerWidth: MediaQuery.of(context).size.width - 32,
                  height: _featureButtonsHeight,
                  filters: appState.filters,  // Full hierarchical structure
                  filtersUsedForSearch: appState.filtersUsedForSearch,
                  filtersOfThisBusiness: business.filterIds ?? [],
                  filterDescriptions: appState.filterDescriptions,
                  onInitialCount: (count) async {
                    debugPrint('Business has $count matching filters');
                  },
                  onFilterTap: (filterId, filterName, filterDescription) async {
                    await showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => FilterDescriptionSheet(
                        filterName: filterName,
                        filterDescription: filterDescription ?? '',
                      ),
                    );
                  },
                  onHeightCalculated: (height) async {
                    setState(() {
                      _featureButtonsHeight = height;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### Example 2: Converting Filter Descriptions Format

If filter descriptions come from API as List, convert to Map:

```dart
Map<int, String> _convertFilterDescriptionsToMap(List<dynamic> descriptions) {
  final Map<int, String> result = {};

  for (final desc in descriptions) {
    if (desc is Map && desc.containsKey('filter_id')) {
      final filterId = desc['filter_id'] as int;
      final description = desc['description'] as String? ?? '';
      if (description.isNotEmpty) {
        result[filterId] = description;
      }
    }
  }

  return result;
}
```

Then pass to widget:

```dart
BusinessFeatureButtons(
  // ...
  filterDescriptions: _convertFilterDescriptionsToMap(
    appState.filterDescriptions
  ),
  // ...
)
```

### Example 3: Hiding Section When No Matching Filters

```dart
Widget build(BuildContext context) {
  final appState = context.watch<AppState>();
  final hasMatchingFilters = appState.filtersUsedForSearch.isNotEmpty &&
      business.filterIds != null &&
      business.filterIds!.any(
        (id) => appState.filtersUsedForSearch.contains(id)
      );

  return Column(
    children: [
      // Only show features section if there are matching filters
      if (hasMatchingFilters)
        BusinessFeatureButtons(
          // ...
        ),
    ],
  );
}
```

### Example 4: Custom Analytics Handler

```dart
BusinessFeatureButtons(
  // ...
  onFilterTap: (filterId, filterName, filterDescription) async {
    // Custom analytics
    AnalyticsService().trackEvent('custom_filter_view', {
      'business_id': business.id,
      'filter_id': filterId,
      'source': 'business_profile',
    });

    // Show description
    await showModalBottomSheet(
      context: context,
      builder: (context) => FilterDescriptionSheet(
        filterName: filterName,
        filterDescription: filterDescription ?? '',
      ),
    );
  },
)
```

---

## Error Handling

### Graceful Degradation

All major methods have try-catch blocks:

```dart
@override
Widget build(BuildContext context) {
  try {
    final organizedFilters = _getOrganizedFilters();

    if (organizedFilters.isEmpty) {
      return SizedBox(width: widget.width, height: 0);
    }

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: _buttonSpacing,
          runSpacing: _buttonRunSpacing,
          alignment: WrapAlignment.start,
          children: _buildFilterButtons(organizedFilters),
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error in build method: $e');
    return SizedBox(width: widget.width, height: 0);
  }
}
```

### Error Scenarios

| Scenario | Handling | Result |
|----------|----------|--------|
| Invalid filter structure | Caught in `_getFiltersList()`, returns `[]` | Empty widget (height: 0) |
| Missing filter descriptions | Null check in `_getFilterDescription()` | Buttons without info icons |
| Null business filters | Null check throughout | Shows all filters from hierarchy |
| Height calculation error | Caught in `_calculateAndNotifyMetrics()` | Returns height: 0 |
| Description retrieval error | Try-catch in `_getFilterDescription()` | Returns `null`, no info icon |
| Button tap error | Try-catch in `_handleFilterTap()` | Logs error, callback not executed |
| Analytics tracking error | `.catchError()` on analytics call | Logs warning, continues execution |

### Debug Logging

The widget includes comprehensive debug logging:

```dart
debugPrint('📋 Filters to display: ${organizedFilters.map((f) => f['name']).toList()}');
debugPrint('📐 Height calc: $rowCount rows, ${filters.length} filters, height=$totalHeight, containerWidth=$containerWidth');
debugPrint('Error in _shouldHideFilter: $e');
debugPrint('⚠️ Failed to track filter info click: $error');
```

**Enable Debug Logging:**
```dart
// In main.dart or during development
debugPrint.level = DebugPrintLevel.verbose;
```

---

## Testing Checklist

### Unit Tests

- [ ] Filter flattening with nested hierarchy
- [ ] Filter flattening with direct list
- [ ] Exclusion of payment filters (category 21)
- [ ] Exclusion of category 11 and children
- [ ] Mutual exclusion pairs (hide first if second exists)
- [ ] Special parent synthesis when children exist
- [ ] Special parent NOT synthesized when no children
- [ ] Composite dietary filter exclusion (6-digit IDs)
- [ ] Group bookings dynamic label: single range
- [ ] Group bookings dynamic label: multiple ranges
- [ ] Group bookings dynamic label: includes 40+
- [ ] Filter description retrieval from List format
- [ ] Filter description retrieval from Map format
- [ ] Filter description retrieval for special parents (lowest child)
- [ ] Selection state: direct match
- [ ] Selection state: special parent with selected child
- [ ] Text width measurement accuracy
- [ ] Button width calculation with description
- [ ] Button width calculation without description
- [ ] Height calculation: single row
- [ ] Height calculation: multiple rows
- [ ] Height calculation: empty filters

### Widget Tests

- [ ] Renders empty widget when no filters
- [ ] Renders correct number of buttons
- [ ] Shows info icon on buttons with descriptions
- [ ] Hides info icon on buttons without descriptions
- [ ] Selected filters have orange styling
- [ ] Unselected filters have gray styling
- [ ] Button tap calls `onFilterTap` callback
- [ ] Button tap with null callback doesn't crash
- [ ] Buttons without descriptions are not tappable
- [ ] `onInitialCount` called with correct count
- [ ] `onHeightCalculated` called with correct height
- [ ] Widget updates when filters change
- [ ] Widget updates when containerWidth changes
- [ ] Widget updates when filterDescriptions change

### Integration Tests

- [ ] Display on Business Profile page
- [ ] Integration with FilterDescriptionSheet
- [ ] Height calculation updates parent widget
- [ ] Analytics event fires on button tap
- [ ] User engagement marked on tap
- [ ] Works with empty filtersUsedForSearch
- [ ] Works with empty filtersOfThisBusiness
- [ ] Works with null filterDescriptions
- [ ] Handles API data format variations
- [ ] Performance with large filter lists (100+ filters)

### Edge Cases

- [ ] Business has no matching filters → empty widget
- [ ] All business filters are excluded (payment/category 11) → empty widget
- [ ] Very long filter names → wraps correctly, height accurate
- [ ] Container width very narrow → single column layout
- [ ] Special parent with all children excluded → parent not shown
- [ ] Filter description is empty string → no info icon
- [ ] Mutually exclusive pair where both exist → first hidden
- [ ] Group bookings with no children → shows base label
- [ ] Filter hierarchy depth > 3 levels → flattens correctly

---

## Migration Notes

### FlutterFlow to Pure Flutter Changes

#### Service Injection

**Before (FlutterFlow):**
```dart
markUserEngaged();
trackAnalyticsEvent('filter_info_clicked', {...});
```

**After (Migrated):**
```dart
late AnalyticsService _analyticsService;

@override
void initState() {
  super.initState();
  _analyticsService = AnalyticsService();
}

_analyticsService.markUserEngaged();
_analyticsService.trackEvent('filter_info_clicked', {...});
```

#### Button Style API

**Before (FlutterFlow):**
```dart
MaterialStateProperty.all(...)
MaterialStateProperty.resolveWith<T>(...)
```

**After (Migrated):**
```dart
WidgetStateProperty.all(...)
WidgetStateProperty.resolveWith<T>(...)
```

Flutter 3.22+ deprecated `MaterialStateProperty` in favor of `WidgetStateProperty`.

#### Widget Containers

**Before (FlutterFlow):**
```dart
Container(width: widget.width, height: 0)
```

**After (Migrated):**
```dart
SizedBox(width: widget.width, height: 0)
```

`SizedBox` is more performant for simple size constraints.

### Phase 3 Migration Requirements

#### State Management: Riverpod Integration

**Current Implementation:**
```dart
// Widget receives all data via parameters
BusinessFeatureButtons(
  filters: appState.filters,
  filtersUsedForSearch: appState.filtersUsedForSearch,
  filtersOfThisBusiness: business.filterIds,
  filterDescriptions: appState.filterDescriptions,
)
```

**Phase 3 Riverpod Pattern:**
```dart
// Widget consumes providers directly
class _BusinessFeatureButtonsState extends ConsumerState<BusinessFeatureButtons> {
  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filtersProvider);
    final activeFilters = ref.watch(activeFiltersProvider);
    final descriptions = ref.watch(filterDescriptionsProvider);

    // Widget logic...
  }
}
```

**Benefits:**
- Removes parameter drilling
- Automatic rebuild on data changes
- Better separation of concerns
- Easier testing with mocked providers

#### Analytics Service: Provider Pattern

**Current Implementation:**
```dart
late AnalyticsService _analyticsService;

@override
void initState() {
  super.initState();
  _analyticsService = AnalyticsService();
}
```

**Phase 3 Riverpod Pattern:**
```dart
final analyticsServiceProvider = Provider((ref) => AnalyticsService());

class _BusinessFeatureButtonsState extends ConsumerState<BusinessFeatureButtons> {
  @override
  Widget build(BuildContext context) {
    final analytics = ref.watch(analyticsServiceProvider);

    // Use analytics...
  }
}
```

#### Filter Logic: Extract to Repository

**Current Implementation:**
- All filter logic in widget state class
- 500+ lines of business logic

**Phase 3 Pattern:**
```dart
// lib/repositories/filter_repository.dart
class FilterRepository {
  List<Map<String, dynamic>> getOrganizedFilters({
    required dynamic filters,
    required List<int> businessFilters,
    required List<int> activeFilters,
  }) {
    // Extract all filter logic here
  }

  bool isFilterSelected(int filterId, List<int> activeFilters) { ... }
  String getDisplayName(Map<String, dynamic> filter, List<int> businessFilters) { ... }
  // etc.
}

// Widget becomes thin presentation layer
class _BusinessFeatureButtonsState extends ConsumerState<BusinessFeatureButtons> {
  @override
  Widget build(BuildContext context) {
    final filterRepo = ref.watch(filterRepositoryProvider);
    final organizedFilters = filterRepo.getOrganizedFilters(...);

    return Wrap(
      children: organizedFilters.map((filter) =>
        _buildButton(filter)
      ).toList(),
    );
  }
}
```

**Benefits:**
- Easier to unit test filter logic
- Reusable across widgets
- Widget focuses on presentation only
- Clear separation of concerns

---

## Performance Considerations

### Text Measurement Optimization

**Issue:** `TextPainter` layout is expensive

**Current Implementation:**
```dart
double _measureTextWidth(String text) {
  final textPainter = TextPainter(
    text: TextSpan(text: text, style: _buttonTextStyle),
    maxLines: 1,
    textDirection: ui.TextDirection.ltr,
  )..layout(minWidth: 0, maxWidth: double.infinity);

  return textPainter.size.width;
}
```

Called once per filter during height calculation.

**Optimization Opportunity (Phase 3):**
```dart
// Cache measurements
final Map<String, double> _textWidthCache = {};

double _measureTextWidth(String text) {
  if (_textWidthCache.containsKey(text)) {
    return _textWidthCache[text]!;
  }

  final textPainter = TextPainter(...);
  textPainter.layout(minWidth: 0, maxWidth: double.infinity);

  final width = textPainter.size.width;
  _textWidthCache[text] = width;
  return width;
}
```

**Expected Impact:**
- Reduces measurements from N to unique text count
- Improves performance with duplicate filter names
- Especially beneficial when filters update frequently

### Filter List Processing

**Current Implementation:**
- Flattens hierarchy on every build
- Processes all filters every time

**Optimization Opportunity (Phase 3):**
```dart
List<Map<String, dynamic>>? _cachedFlatFilters;
dynamic _lastFiltersData;

List<Map<String, dynamic>> _getFiltersList() {
  if (widget.filters == _lastFiltersData && _cachedFlatFilters != null) {
    return _cachedFlatFilters!;
  }

  _lastFiltersData = widget.filters;
  _cachedFlatFilters = _flattenFilters(widget.filters);
  return _cachedFlatFilters!;
}
```

**Expected Impact:**
- Avoids redundant flattening operations
- Improves performance when widget rebuilds without data changes

### Wrap Layout Calculation

**Note:** Height calculation algorithm is already optimized:
- O(n) time complexity
- Single pass through filters
- No redundant measurements

No further optimization needed unless profiling shows issues.

---

## Common Issues and Solutions

### Issue 1: Height Calculation Incorrect

**Symptom:** Buttons overflow or have extra space

**Cause:** Container width doesn't match calculation width

**Solution:**
```dart
// Ensure consistent width calculation
final screenWidth = MediaQuery.of(context).size.width;
final padding = 32.0; // Total horizontal padding
final containerWidth = screenWidth - padding;

BusinessFeatureButtons(
  containerWidth: containerWidth,
  // ...
)
```

### Issue 2: Info Icons Not Appearing

**Symptom:** Buttons never show info icons

**Cause:** Filter descriptions format mismatch

**Solution:**
```dart
// Debug description data format
debugPrint('Filter descriptions type: ${widget.filterDescriptions.runtimeType}');
debugPrint('Filter descriptions data: ${widget.filterDescriptions}');

// Ensure correct format:
// List format: [{ filter_id: 123, description: "..." }]
// OR
// Map format: { 123: "description" }
```

### Issue 3: Special Parents Not Synthesizing

**Symptom:** Individual children show instead of parent

**Cause:** Children exist in hierarchy, blocking synthesis

**Solution:**
```dart
// Check if parent exists in original hierarchy
final parentExists = filtersList.any((f) => f['filter_id'] == parentId);

// Only synthesize if parent doesn't exist
if (!parentExists && _shouldSynthesizeParent(parentId)) {
  // Create synthetic parent
}
```

### Issue 4: Group Bookings Label Wrong

**Symptom:** Label shows "Group bookings" instead of range

**Cause:** Filter names don't match expected pattern

**Solution:**
```dart
// Filter names must start with number: "10-14 personer"
// Check filter data:
final filter = _getFilterById(544); // First group booking child
debugPrint('Group booking filter name: ${filter?['name']}');

// Must match regex: r'^(\d+)'
```

### Issue 5: Buttons Not Highlighted

**Symptom:** Matching filters don't have orange styling

**Cause:** `filtersUsedForSearch` not passed or incorrect

**Solution:**
```dart
// Ensure active filters passed to widget
final activeFilters = context.watch<AppState>().filtersUsedForSearch;

BusinessFeatureButtons(
  filtersUsedForSearch: activeFilters, // Must pass user's active filters
  // ...
)

// For special parents, ensure child IDs in filtersUsedForSearch
// Parent highlights if ANY child is in active filters
```

### Issue 6: Composite Dietary Filters Showing

**Symptom:** 6-digit filter IDs appear (e.g., 592057, 596009)

**Cause:** Composite dietary filters not filtered out

**Solution:**
```dart
// Ensure _isCompositeDietaryFilter() is called
bool _isCompositeDietaryFilter(int filterId) {
  final filterIdStr = filterId.toString();
  return filterIdStr.length == 6 &&
      (filterIdStr.startsWith('592') ||
       filterIdStr.startsWith('593') ||
       filterIdStr.startsWith('594') ||
       filterIdStr.startsWith('595') ||
       filterIdStr.startsWith('596') ||
       filterIdStr.startsWith('597'));
}

// Called in _getOrganizedFilters():
if (_isCompositeDietaryFilter(filterId)) return false;
```

---

## Related Components

### FilterDescriptionSheet
**Location:** `lib/widgets/filter_description_sheet.dart`
**Purpose:** Displays filter description in bottom sheet modal
**Integration:** Called from `onFilterTap` callback

```dart
onFilterTap: (filterId, filterName, filterDescription) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => FilterDescriptionSheet(
      filterName: filterName,
      filterDescription: filterDescription ?? '',
    ),
  );
}
```

### Business Profile Page
**Location:** `lib/pages/business_profile_page.dart`
**Purpose:** Main page displaying business details
**Integration:** Hosts BusinessFeatureButtons widget in features section

### AppState / Provider
**Location:** `lib/providers/app_state.dart`
**Purpose:** Global app state management
**Integration:** Provides filters, active filters, and filter descriptions

---

## Documentation Metadata

**Document Created:** 2026-02-19
**FlutterFlow Source Version:** business_feature_buttons.dart (849 lines)
**Migrated Version:** business_feature_buttons.dart (847 lines)
**Last FlutterFlow Update:** Unknown
**Migration Status:** ✅ Complete (Phase 2)
**Next Phase:** Phase 3 — Riverpod integration, repository extraction
**Complexity Rating:** High (filter logic, height calculation, special cases)
**Lines of Code:** 849 (FlutterFlow), 847 (Migrated)
**Dependencies:** AnalyticsService, FilterDescriptionSheet
**Test Coverage:** Unit tests exist, widget tests needed

---

## Change Log

### FlutterFlow → Migrated Changes

**2026-02-19 — Initial Migration**
- ✅ Replaced `markUserEngaged()` with `AnalyticsService.markUserEngaged()`
- ✅ Replaced `trackAnalyticsEvent()` with `AnalyticsService.trackEvent()`
- ✅ Updated `MaterialStateProperty` to `WidgetStateProperty`
- ✅ Changed `Container` to `SizedBox` for size-only constraints
- ✅ Added `AnalyticsService` initialization in `initState()`
- ✅ Removed FlutterFlow import dependencies
- ✅ Added internal service dependencies

**Behavioral Changes:**
- None — All filter logic preserved exactly
- Analytics implementation changed but events identical

**Known Issues:**
- None

---

## Quick Reference

### Filter ID Constants Quick Reference

```dart
// Special Parents
100  — Shared Menu
101  — Multi-course Menu
20   — Outdoor Seating
22   — Private Seating
4    — Michelin Rated
543  — Group bookings

// Group Bookings Children
544  — 10-14 personer
545  — 15-19 personer
546  — 20-24 personer
547  — 25-29 personer
548  — 30-34 personer
549  — 35-39 personer
550  — 40+ personer

// Excluded Categories
21   — Payment category (entire subtree excluded)
11   — Excluded category (entire subtree excluded)
90-97 — Direct children of category 11

// Mutual Exclusion Pairs
109→110, 174→173, 176→175, 181→180, 183→182
```

### Key Methods Quick Reference

| Method | Purpose |
|--------|---------|
| `_flattenFilters()` | Convert hierarchy to flat list |
| `_getFiltersList()` | Get flattened filters from widget data |
| `_isExcludedFilter()` | Check if filter should be excluded |
| `_shouldHideFilter()` | Apply visibility business rules |
| `_shouldSynthesizeParent()` | Check if special parent should be created |
| `_getOrganizedFilters()` | Main orchestrator, returns final filter list |
| `_getFilterDescription()` | Retrieve description for filter ID |
| `_hasFilterDescription()` | Check if filter has description |
| `_isFilterSelected()` | Check if filter matches user's search |
| `_getDisplayName()` | Get display name (with group bookings logic) |
| `_measureTextWidth()` | Measure exact text width with TextPainter |
| `_calculateButtonWidth()` | Calculate button width with padding/icon |
| `_calculateRequiredHeight()` | Calculate total height for wrap layout |
| `_calculateAndNotifyMetrics()` | Calculate and notify parent of metrics |

### Color Constants Quick Reference

```dart
// Selected state
0xFFD35400  — Orange (border, text, icon)
0xFFFDF2EC  — Light orange (background)

// Unselected state
0xFF242629  — Dark gray (text)
0xFF666666  — Medium gray (icon)
0xFFf2f3f5  — Light gray (background)
Colors.grey.shade500  — Border
```

---

**End of Documentation**
