# RestaurantShimmerWidget

**Type:** Custom Widget
**File:** `restaurant_shimmer_widget.dart` (337 lines)
**Category:** UI Components / Loading States
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Core loading state for restaurant detail page)

---

## Purpose

A shimmer loading placeholder widget for the restaurant detail page. Displays animated skeleton loading states for all major page sections including restaurant logo, info, OK line indicator, gallery title/tabs/images, and menu category buttons.

**Key Features:**
- Shimmer animation using `shimmer` package
- Full page skeleton for restaurant detail view
- Logo + restaurant info section
- OK line match indicator placeholder
- Gallery section with title, tabs, and image grid
- Menu section with category button placeholders
- Consistent color scheme (grey 300 → grey 100 gradient)
- Realistic dimensions matching actual content
- No translation dependency (pure visual skeleton)

---

## Parameters

```dart
RestaurantShimmerWidget({
  super.key,
  this.width,
  this.height,
})
```

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `width` | `double?` | No | Container width (defaults to `double.infinity`) |
| `height` | `double?` | No | Container height (not used - auto-sized by content) |

---

## Dependencies

### pub.dev Packages
```yaml
dependencies:
  shimmer: ^3.0.0  # Shimmer animation effect
```

### Internal Dependencies
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
import 'package:shimmer/shimmer.dart';
```

### Custom Actions Used
None

### Custom Functions Used
None

---

## FFAppState Usage

### Read Properties
None - This is a pure UI widget with no state dependencies.

### Write Properties
None

### State Listening
None - Static skeleton UI only.

---

## Lifecycle Events

### StatefulWidget with No Lifecycle Logic

This widget extends `StatefulWidget` but contains **no lifecycle methods** beyond `build()`. All configuration is static constants.

**Why StatefulWidget?**
- FlutterFlow convention (consistency)
- No actual state management needed
- Could be refactored to `StatelessWidget`

---

## User Interactions

None - This is a non-interactive loading placeholder.

---

## Display States

### Single State: Loading
**Condition:** Widget is built
**Display:** Full shimmer skeleton with all sections animated

**No Conditional States:**
- Widget always shows the same skeleton
- No empty/error/success states (transitions to real content)

---

## Shimmer Configuration

### Animation Colors
```dart
static final Color _baseColor = Colors.grey[300]!;       // Starting color
static final Color _highlightColor = Colors.grey[100]!; // Highlight sweep
static const Color _placeholderColor = Colors.white;    // Box background
```

### Shimmer.fromColors Wrapper
```dart
Shimmer.fromColors(
  baseColor: _baseColor,
  highlightColor: _highlightColor,
  child: _buildMainContainer(),
)
```

**Effect:** Continuous left-to-right shimmer animation over all placeholder boxes

---

## Layout Structure

### Main Container (lines 117-134)
```dart
Container(
  width: widget.width ?? double.infinity,
  padding: const EdgeInsets.all(_containerPadding),  // 16px
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLogoAndInfoSection(),
      SizedBox(height: 16),
      _buildOkLine(),
      SizedBox(height: 24),
      _buildGallerySection(),
      SizedBox(height: 24),
      _buildMenuSection(),
    ],
  ),
)
```

**Sections in Order:**
1. Logo & restaurant info
2. OK line indicator
3. Gallery (title, section title, tabs, images)
4. Menu (title, category buttons)

---

## Section 1: Logo & Info (lines 141-181)

### Layout
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    _buildLogoPlaceholder(),            // 107x107 square
    SizedBox(width: 8),
    _buildRestaurantInfoColumn(),       // Expandable column
  ],
)
```

### Logo Placeholder (lines 153-162)
**Dimensions:** 107 x 107 px (square)
**Border Radius:** 8px
**Color:** White background (shimmer highlights sweep over)

### Restaurant Info Column (lines 165-181)
**Placeholders:**
1. **Restaurant Name** - 200w x 24h px
2. **Cuisine Type** - 150w x 16h px
3. **Address** - 180w x 16h px
4. **Contact** - 160w x 16h px

**Spacing:** 8px between each placeholder

---

## Section 2: OK Line (lines 188-190)

### Placeholder
**Dimensions:** 120w x 16h px
**Purpose:** Represents the OK line match indicator (e.g., "8 af dine 9 behov opfyldt")

---

## Section 3: Gallery (lines 197-276)

### Title (lines 213-216)
**Dimensions:** 80w x 20h px
**Purpose:** Gallery section title placeholder

### Section Title (lines 219-222)
**Dimensions:** 80w x 20h px (duplicate of title)
**Purpose:** Represents "Se i galleriet" or similar section header

### Tabs (lines 225-248)
**Layout:** Horizontal scrolling row
**Count:** 4 tab placeholders
**Dimensions per Tab:**
- Width: 80px
- Height: 32px
- Border Radius: 16px (pill shape)
- Spacing: 8px between tabs

### Image Grid (lines 251-276)
**Layout:** Fixed-height horizontal row with 4 equal-width images
**Container Height:** 100px
**Count:** 4 image placeholders
**Spacing:** 8px between images
**Border Radius:** 8px

**Implementation:**
```dart
Row(
  children: List.generate(
    4,
    (index) => Expanded(
      child: Container(
        margin: EdgeInsets.only(right: isLastItem ? 0 : 8),
        decoration: BoxDecoration(
          color: _placeholderColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  ),
)
```

---

## Section 4: Menu (lines 283-322)

### Title (lines 295-297)
**Dimensions:** 100w x 20h px
**Purpose:** Menu section title placeholder

### Category Buttons (lines 300-322)
**Layout:** Horizontal row (non-scrolling)
**Count:** 3 button placeholders
**Dimensions per Button:**
- Width: 100px
- Height: 36px
- Border Radius: 18px (pill shape)
- Spacing: 8px between buttons

---

## Style Constants

### Layout Constants
```dart
static const double _containerPadding = 16.0;          // Main container padding
static const double _defaultBorderRadius = 8.0;        // Standard corners
```

### Logo Section
```dart
static const double _logoSize = 107.0;                 // Logo square size
static const double _logoToInfoSpacing = 8.0;          // Logo-to-info gap
static const double _infoItemSpacing = 8.0;            // Between info lines
```

### Restaurant Info Placeholders
```dart
static const double _restaurantNameWidth = 200.0;
static const double _restaurantNameHeight = 24.0;
static const double _infoLineHeight = 16.0;
static const double _cuisineWidth = 150.0;
static const double _addressWidth = 180.0;
static const double _contactWidth = 160.0;
```

### Section Spacing
```dart
static const double _logoToOkLineSpacing = 16.0;       // Logo → OK line
static const double _okLineToGallerySpacing = 24.0;    // OK line → Gallery
static const double _galleryTitleToTabsSpacing = 16.0; // Title → Tabs
static const double _tabsToImagesSpacing = 16.0;       // Tabs → Images
static const double _galleryToMenuSpacing = 24.0;      // Gallery → Menu
static const double _menuTitleToButtonsSpacing = 16.0; // Menu title → Buttons
```

### OK Line
```dart
static const double _okLineWidth = 120.0;
static const double _okLineHeight = 16.0;
```

### Gallery Section
```dart
static const double _galleryTitleWidth = 80.0;
static const double _galleryTitleHeight = 20.0;
static const int _galleryTabCount = 4;
static const double _galleryTabWidth = 80.0;
static const double _galleryTabHeight = 32.0;
static const double _galleryTabBorderRadius = 16.0;
static const double _galleryTabSpacing = 8.0;
static const double _galleryImageHeight = 100.0;
static const int _galleryImageCount = 4;
static const double _galleryImageSpacing = 8.0;
```

### Menu Section
```dart
static const double _menuTitleWidth = 100.0;
static const double _menuTitleHeight = 20.0;
static const int _menuButtonCount = 3;
static const double _menuButtonWidth = 100.0;
static const double _menuButtonHeight = 36.0;
static const double _menuButtonBorderRadius = 18.0;
static const double _menuButtonSpacing = 8.0;
```

---

## Helper Method

### _buildPlaceholder (lines 329-335)
```dart
Widget _buildPlaceholder({required double width, required double height}) {
  return Container(
    width: width,
    height: height,
    color: _placeholderColor,
  );
}
```

**Purpose:** Generic rectangular placeholder builder for text-like elements
**No Border Radius:** Simple box (unlike logo/images which have rounded corners)

---

## Usage Example

### In Restaurant Detail Page

```dart
import '/custom_code/widgets/index.dart' as custom_widgets;

// In build method:
FutureBuilder<RestaurantData>(
  future: fetchRestaurantDetails(restaurantId),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      // Show shimmer while loading
      return custom_widgets.RestaurantShimmerWidget(
        width: double.infinity,
      );
    }

    if (snapshot.hasError) {
      return ErrorDisplay(error: snapshot.error);
    }

    // Show real content when loaded
    return RestaurantDetailContent(data: snapshot.data!);
  },
)
```

### Typical Context
**Used When:**
- Restaurant detail page is loading
- Initial navigation from search results
- Refreshing restaurant data
- Network request in progress

**Replaced By:**
- Actual restaurant content widgets (logo, gallery, menu)
- Error state UI (if fetch fails)

---

## Related Elements

### Used By Pages
- **Restaurant Detail Page** (`restaurant_detail_widget.dart`) - Shows during data fetch

### Related Widgets
- `RestaurantListShimmerWidget` - Uses this widget in a list view for search results
- `GalleryWidget` - Real gallery component that replaces shimmer
- `MenuWidget` - Real menu component that replaces shimmer

### Related Packages
- `shimmer` - Animation effect provider

---

## Performance Characteristics

### Lightweight Loading State
1. **Static Constants** - All dimensions cached at compile time
2. **No State Management** - Pure UI, no FFAppState access
3. **Efficient List Generation** - `List.generate` for tabs/images/buttons
4. **Single Shimmer Wrapper** - One animation controller for entire widget
5. **No Network Calls** - Pure skeleton UI

### Shimmer Package Performance
- Efficient GPU-accelerated gradient animation
- Single animation controller per widget
- Minimal CPU overhead

---

## Edge Cases Handled

1. **Null width** - Defaults to `double.infinity`
2. **Null height** - Ignored (auto-sized by content)
3. **Last item spacing** - No right margin on final gallery image/menu button
4. **Expandable info column** - Uses `Expanded` to fill available space
5. **Horizontal scroll tabs** - `SingleChildScrollView` for narrow screens

---

## Design Decisions

### Why 4 Gallery Tabs?
Matches typical restaurant gallery structure (All, Food, Interior, Exterior)

### Why 3 Menu Buttons?
Represents common category count (e.g., Breakfast, Lunch, Dinner)

### Why 4 Gallery Images?
Fits typical mobile viewport without overwhelming vertical space

### Why Different Spacing (16px vs 24px)?
- **16px** - Within sections (tight grouping)
- **24px** - Between sections (clear separation)

### Why White Placeholders?
- Clean, minimal appearance
- Shimmer gradient clearly visible
- Matches typical card/container backgrounds

---

## Testing Checklist

When implementing or modifying:

- [ ] Verify shimmer animation runs smoothly
- [ ] Check all placeholders render with correct dimensions
- [ ] Verify spacing between sections matches constants
- [ ] Test logo placeholder is square (107x107)
- [ ] Verify info column expands to fill space
- [ ] Check gallery tabs scroll horizontally
- [ ] Verify gallery images have equal widths
- [ ] Test menu buttons fit in horizontal row
- [ ] Verify border radius on rounded elements (logo, gallery, tabs, buttons)
- [ ] Check shimmer colors contrast properly
- [ ] Test with different screen widths
- [ ] Verify no overflow errors on narrow screens
- [ ] Check transition to real content is smooth
- [ ] Test performance with multiple instances (list view)

---

## Migration Notes

### Phase 3 Strategy

**FlutterFlow → Pure Flutter**

#### 1. Remove StatefulWidget Conversion
```dart
// Before:
class RestaurantShimmerWidget extends StatefulWidget { ... }

// After (if no state needed):
class RestaurantShimmerWidget extends StatelessWidget { ... }
```

#### 2. Simplify Imports
```dart
// Remove unused FlutterFlow imports
// Keep only:
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
```

#### 3. Widget Parameters
```dart
// Before:
final double? width;
final double? height;

// After:
final double width;  // Required parameter
// Remove height (unused)
```

#### 4. Theme Integration (Optional)
```dart
// Before:
static final Color _baseColor = Colors.grey[300]!;

// After:
Color get _baseColor => Theme.of(context).colorScheme.surfaceVariant;
```

---

## Known Issues

None currently documented.

---

## Analytics Events

None - This is a non-interactive loading placeholder with no user engagement tracking.

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with Shimmer Package
