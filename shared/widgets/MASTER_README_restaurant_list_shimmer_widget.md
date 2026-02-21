# RestaurantListShimmerWidget

**Type:** Custom Widget
**File:** `restaurant_list_shimmer_widget.dart` (202 lines)
**Category:** Loading States
**Status:** ✅ Production Ready

---

## Purpose

A shimmer loading placeholder that displays animated skeleton states for a list of restaurants while actual data is being fetched. Provides visual feedback during API calls or data loading operations, maintaining user engagement and preventing perceived slowness.

**Key Features:**
- Animated shimmer effect using `shimmer` package
- Six skeleton cards matching restaurant list item layout
- Square logo placeholder + four text placeholders per card
- Dividers between items matching actual list styling
- Configurable container dimensions
- Mimics visual structure of actual restaurant cards

---

## Parameters

```dart
RestaurantListShimmerWidget({
  super.key,
  this.width,    // Optional container width
  this.height,   // Optional container height
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (defaults to `double.infinity`) |
| `height` | `double?` | No | Container height (defaults to content height) |

---

## Dependencies

### External Package
```dart
import 'package:shimmer/shimmer.dart';
```

**Shimmer Package:** `shimmer: ^3.0.0` (or compatible version)
- Provides `Shimmer.fromColors()` widget for animated gradient effect
- Creates smooth "loading wave" animation across skeleton elements

### Internal Dependencies
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

---

## Visual Structure

### Skeleton Card Layout

Each of the 6 shimmer items has this structure:

```
┌─────────────────────────────────────────┐
│ ┌──────┐  Restaurant Name Placeholder   │
│ │ Logo │  Price Range Placeholder       │  ← 100x100px logo
│ │ 100px│  Distance Placeholder          │  ← 4 text lines
│ └──────┘  Location Placeholder          │
└─────────────────────────────────────────┘
         ─────────────────────               ← Divider (1px, #F1F4F8)
```

### Placeholder Dimensions

| Element | Width | Height | Description |
|---------|-------|--------|-------------|
| Logo | 100px | 100px | Square placeholder with 4px border radius |
| Restaurant Name | 100px | 16px | First text line (shortest) |
| Price Range | 200px | 16px | Second text line (longest) |
| Distance | 150px | 16px | Third text line (medium) |
| Location | 120px | 16px | Fourth text line (medium-short) |

**Layout Spacing:**
- Logo to info column: 8px horizontal gap
- Between text placeholders: 8px vertical gap
- Item vertical padding: 4px top + 4px bottom
- Divider height: 12px total (includes spacing)

---

## Shimmer Animation

### Animation Colors

```dart
static final Color _baseColor = Colors.grey[300]!;      // #E0E0E0 - Starting color
static final Color _highlightColor = Colors.grey[100]!; // #F5F5F5 - Sweep color
static const Color _placeholderColor = Colors.white;    // #FFFFFF - Placeholder fill
```

**Animation Pattern:**
- Gradient sweeps from left to right continuously
- Creates "loading wave" effect across all skeleton elements
- Default shimmer duration: ~1500ms per cycle (package default)
- Smooth transition between base and highlight colors

### Visual Effect

The shimmer creates a moving gradient that gives the impression of:
1. Content being loaded/processed
2. Active system state (not frozen)
3. Anticipated completion (something is happening)

---

## Layout Structure

### Main Container (lines 91-96)

```dart
Container(
  width: widget.width ?? double.infinity,  // Fill parent if width not specified
  height: widget.height,                   // Content-based if height not specified
  child: _buildShimmerList(),
)
```

**Behavior:**
- Width defaults to full available width
- Height adapts to content unless explicitly set
- Wrapped in `Shimmer.fromColors()` for animation

### List View (lines 99-105)

```dart
ListView.separated(
  itemCount: _shimmerItemCount,              // 6 items
  separatorBuilder: (_, __) => _buildDivider(),
  itemBuilder: (_, index) => _buildShimmerListItem(),
)
```

**Configuration:**
- Fixed 6 items regardless of expected data length
- Dividers between each item (not after last)
- Scrollable if content exceeds container height

---

## Skeleton Card Structure

### Card Layout (lines 112-124)

```dart
Padding(
  padding: const EdgeInsets.symmetric(vertical: _itemVerticalPadding),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,  // Align logo/info to top
    children: [
      _buildLogoPlaceholder(),                     // Left: 100x100px logo
      const SizedBox(width: _logoToInfoSpacing),   // Gap: 8px
      _buildInfoColumn(),                          // Right: Stacked text lines
    ],
  ),
)
```

### Logo Placeholder (lines 127-136)

```dart
Container(
  width: _logoSize,                // 100px
  height: _logoSize,               // 100px
  decoration: BoxDecoration(
    color: _placeholderColor,      // White
    borderRadius: BorderRadius.circular(_logoBorderRadius), // 4px
  ),
)
```

**Visual:** Square white box with slightly rounded corners (4px radius)

### Info Column (lines 139-154)

```dart
Expanded(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,  // Left-align text
    children: [
      _buildRestaurantNamePlaceholder(),  // Width: 100px
      const SizedBox(height: _infoItemSpacing),
      _buildPriceRangePlaceholder(),      // Width: 200px
      const SizedBox(height: _infoItemSpacing),
      _buildDistancePlaceholder(),        // Width: 150px
      const SizedBox(height: _infoItemSpacing),
      _buildLocationPlaceholder(),        // Width: 120px
    ],
  ),
)
```

**Visual:** Four white rectangular bars stacked vertically, varying widths to mimic text

---

## Text Placeholder Widths

The varying widths create realistic text-like appearance:

```dart
static const double _restaurantNameWidth = 100.0;  // Shortest - typical name length
static const double _priceRangeWidth = 200.0;     // Longest - "kr 200-400 per person"
static const double _distanceWidth = 150.0;       // Medium - "1.2 km away"
static const double _locationWidth = 120.0;       // Medium-short - neighborhood name
```

**Rationale:**
- Different widths prevent "mechanical" appearance
- Approximate actual content lengths from real data
- Create visual variety while maintaining alignment
- Mimic natural text flow patterns

---

## Divider Styling

### Divider Configuration (lines 194-200)

```dart
const Divider(
  height: _dividerHeight,      // 12.0 - Total space occupied
  thickness: _dividerThickness, // 1.0 - Visual line thickness
  color: _dividerColor,        // #F1F4F8 - Light gray
)
```

**Visual Result:**
- 1px light gray line between cards
- 12px total space (includes padding above/below line)
- Matches divider styling in actual restaurant list
- Provides visual separation without heavy borders

---

## Constants Reference

### Complete Constants List (lines 43-74)

```dart
// Animation Colors
static final Color _baseColor = Colors.grey[300]!;
static final Color _highlightColor = Colors.grey[100]!;
static const Color _placeholderColor = Colors.white;

// List Configuration
static const int _shimmerItemCount = 6;

// Divider Styling
static const double _dividerHeight = 12.0;
static const double _dividerThickness = 1.0;
static const Color _dividerColor = Color(0xFFF1F4F8);

// Item Layout
static const double _itemVerticalPadding = 4.0;
static const double _logoToInfoSpacing = 8.0;
static const double _infoItemSpacing = 8.0;

// Logo Dimensions
static const double _logoSize = 100.0;
static const double _logoBorderRadius = 4.0;

// Info Placeholder Dimensions
static const double _infoPlaceholderHeight = 16.0;
static const double _restaurantNameWidth = 100.0;
static const double _priceRangeWidth = 200.0;
static const double _distanceWidth = 150.0;
static const double _locationWidth = 120.0;
```

**All values are hard-coded constants** - no dynamic calculation or state changes.

---

## Usage Patterns

### During Search API Call

```dart
// In SearchResults page
bool isLoading = FFAppState().isLoadingSearch;

// In build method:
if (isLoading) {
  return custom_widgets.RestaurantListShimmerWidget(
    width: double.infinity,
    height: MediaQuery.of(context).size.height - 200, // Account for header/filters
  );
} else {
  return SearchResultsListView(
    restaurants: FFAppState().searchResults,
    // ... other params
  );
}
```

### During Initial Load

```dart
// On page load before first search
@override
void initState() {
  super.initState();

  // Show shimmer immediately
  setState(() {
    FFAppState().isLoadingSearch = true;
  });

  // Trigger initial search
  performSearchAndUpdateState(...).then((_) {
    setState(() {
      FFAppState().isLoadingSearch = false;
    });
  });
}
```

### During Filter Changes

```dart
// User applies new filters
Future<void> onFilterApply() async {
  // Show shimmer during re-fetch
  FFAppState().update(() {
    FFAppState().isLoadingSearch = true;
  });

  // Fetch with new filters
  await performSearchAndUpdateState(...);

  // Hide shimmer, show results
  FFAppState().update(() {
    FFAppState().isLoadingSearch = false;
  });
}
```

---

## State Management

### No Internal State

The widget is **stateless in behavior** (uses `StatefulWidget` for FlutterFlow compatibility but has no mutable state):
- No `initState()` logic
- No `setState()` calls
- No timers or controllers
- Animation handled entirely by `Shimmer` package

### Parent Controls Visibility

```dart
// Parent page manages when to show/hide shimmer
bool showShimmer = /* loading state from FFAppState or local state */;

showShimmer
  ? RestaurantListShimmerWidget(...)
  : SearchResultsListView(...)
```

**Lifecycle:**
1. Parent sets `isLoading = true`
2. Parent renders `RestaurantListShimmerWidget`
3. Shimmer displays and animates automatically
4. API call completes
5. Parent sets `isLoading = false`
6. Parent renders actual results list

---

## Performance Considerations

### Efficient Rendering

1. **Static Placeholders**
   - All dimensions are constants (no recalculation)
   - No conditional logic in build methods
   - Simple Container/Row/Column layout

2. **Shimmer Package Optimization**
   - Uses GPU-accelerated gradient animation
   - Single `Shimmer.fromColors()` wraps entire list (not per-item)
   - Minimal CPU overhead during animation

3. **Fixed Item Count**
   - Always renders exactly 6 items (no dynamic calculation)
   - ListView reuses widget instances efficiently
   - No data fetching or processing during render

### Memory Footprint

- **Widget tree depth:** 4-5 levels (shallow)
- **No image assets:** Pure Flutter primitives (Container, SizedBox, Divider)
- **No controllers:** No AnimationController, ScrollController, etc.
- **Instant disposal:** No cleanup required on unmount

---

## Visual Fidelity

### Matching Actual Restaurant Cards

The skeleton placeholders are designed to match:

| Actual Card Element | Skeleton Equivalent |
|---------------------|---------------------|
| Restaurant logo (100x100 NetworkImage) | 100x100 white Container |
| Restaurant name (bold, ~10-30 chars) | 100px white bar (short name) |
| Price range + cuisine (lighter, ~20-40 chars) | 200px white bar (longest line) |
| Distance + status (e.g., "1.2 km • Open") | 150px white bar (medium length) |
| Location/neighborhood | 120px white bar (short-medium) |

**Alignment:**
- Logo on left, info on right (matches actual cards)
- Info column left-aligned and top-aligned
- 8px gap between logo and info (matches actual spacing)
- 8px vertical spacing between text lines (matches actual)

---

## Edge Cases Handled

### Container Sizing

1. **No width specified** → Defaults to `double.infinity` (fills parent)
2. **No height specified** → Uses content height (6 items + dividers)
3. **Height < content** → ListView becomes scrollable
4. **Width < 250px** → Text placeholders may overlap (not handled, assumes reasonable width)

### Shimmer Package

1. **Package not installed** → Compile-time error (explicit dependency)
2. **Animation performance issues** → Shimmer package handles frame drops gracefully
3. **Multiple shimmers on screen** → Each animates independently (no interference)

### Layout Edge Cases

1. **Very narrow screens** → Logo + info column stack horizontally (may need horizontal scroll)
2. **Very wide screens** → Placeholders maintain fixed widths (don't stretch to fill)
3. **Rapid show/hide** → Shimmer starts/stops cleanly without artifacts

---

## Design System Alignment

### Color Usage

- **White placeholders** (`#FFFFFF`) - Neutral, high contrast with gray shimmer
- **Light gray shimmer** (`#E0E0E0` → `#F5F5F5`) - Subtle, non-distracting animation
- **Divider color** (`#F1F4F8`) - Matches actual restaurant list dividers

**No brand colors used** - Loading state should be neutral, not draw attention

### Spacing Consistency

- **8px gaps** - Matches design system spacing scale
- **4px border radius** - Consistent with subtle rounded corners elsewhere
- **100px logo** - Matches actual restaurant logo size in cards

---

## Usage Example

### Complete Integration Example

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

class SearchResultsWidget extends StatefulWidget {
  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header, filters, etc.
          SearchHeader(...),
          FilterTitlesRow(...),

          // Results area with conditional shimmer
          Expanded(
            child: FFAppState().isLoadingSearch
              ? custom_widgets.RestaurantListShimmerWidget(
                  width: double.infinity,
                )
              : custom_widgets.SearchResultsListView(
                  restaurants: FFAppState().searchResults,
                  languageCode: FFAppState().languageCode,
                  translationsCache: FFAppState().translationsCache,
                  // ... other params
                ),
          ),
        ],
      ),
    );
  }
}
```

### Required Setup

1. **Install shimmer package** in `pubspec.yaml`:
   ```yaml
   dependencies:
     shimmer: ^3.0.0
   ```

2. **Manage loading state** in FFAppState or local state:
   ```dart
   bool isLoadingSearch = false;
   ```

3. **Toggle state** during API calls:
   ```dart
   setState(() => isLoadingSearch = true);
   await apiCall();
   setState(() => isLoadingSearch = false);
   ```

---

## Testing Checklist

When implementing in Flutter:

- [ ] Verify shimmer animation plays smoothly (60fps)
- [ ] Verify 6 skeleton cards display
- [ ] Verify logo placeholder is 100x100px square
- [ ] Verify four text placeholders per card
- [ ] Verify text placeholder widths (100, 200, 150, 120)
- [ ] Verify 8px spacing between logo and info column
- [ ] Verify 8px spacing between text placeholders
- [ ] Verify dividers appear between cards (not after last)
- [ ] Verify divider color matches (#F1F4F8)
- [ ] Test with `width: double.infinity` (fills parent)
- [ ] Test with explicit `height` (scrollable if too small)
- [ ] Test rapid show/hide (no animation artifacts)
- [ ] Test multiple shimmers on screen (no interference)
- [ ] Verify no memory leaks on dispose
- [ ] Verify performance with slow device (animation still smooth)

---

## Related Elements

### Used By Pages
- **SearchResults** (`search_results_widget.dart`) - Main loading state
- **Map** (potentially) - Loading restaurant pins

### Related Widgets
- `SearchResultsListView` - The actual results list this mimics
- `RestaurantCard` - Individual card this skeleton represents

### Related State
- `FFAppState().isLoadingSearch` - Controls shimmer visibility
- `FFAppState().searchResults` - Loaded when shimmer hides

---

## Migration Notes

### Phase 3 Implementation

This widget is **trivially portable** to pure Flutter:

1. **No FlutterFlow dependencies** (already uses standard Flutter + one package)
2. **No translation needed** (no text content)
3. **No state management** (stateless behavior)
4. **No custom actions** (self-contained)

**Migration steps:**
1. Copy file to `lib/widgets/shimmer/`
2. Remove FlutterFlow import block (lines 1-9)
3. Add shimmer package to `pubspec.yaml`
4. Update parent pages to import from new location
5. No code changes needed

### Alternative: flutter_skeleton Package

If `shimmer` package has issues, consider alternatives:
- `skeletons` package (more pre-built components)
- `shimmer_animation` (lighter weight)
- Manual `AnimatedContainer` with `LinearGradient` (DIY approach)

Current implementation with `shimmer` is production-proven and recommended.

---

## Known Issues

None currently documented.

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
