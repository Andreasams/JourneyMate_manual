# ProfileTopBusinessBlockWidget

## Purpose
Hero section component for Business Profile page. Displays critical business information in a compact 107px card at the top of the profile.

## Widget Type
StatefulWidget (no Riverpod dependencies - all data passed via props)

## Props (12 total)

### Required Props (4)
- `openingHours` (dynamic) - Business hours map (complex JSONB structure with 7 days × 5 time slots)
- `userLocation` (LatLng) - User's current coordinates for distance calculation
- `priceRangeMin` (int) - Minimum price in DKK
- `priceRangeMax` (int) - Maximum price in DKK

### Optional Props (8)
- `profilePicture` (String?) - Business logo/image URL
- `businessName` (String?) - Business display name
- `latitude` (double?) - Business location latitude
- `longitude` (double?) - Business location longitude
- `street` (String?) - Street address
- `neighbourhoodName` (String?) - Borough/neighbourhood name
- `businessID` (int?) - Unique business identifier
- `businessType` (String?) - Category (e.g., "Vegetarian Restaurant")

## State Management
- Widget type: StatefulWidget (no Riverpod - pure props-based)
- Local state:
  - `_statusColor` (Color?) - Status indicator color (green=open, red=closed)
  - `_statusText` (String?) - Localized status message ("Open", "Closed", "Opens at X", etc.)

## Custom Functions Used (4)

All functions are synchronous and called directly in build():

1. **returnDistance()** - `distance_calculator.dart`
   - Calculate distance from user to business (Haversine formula)
   - Auto-converts to miles for English, km for other languages
   - Returns: `double` (e.g., 1.2 km)

2. **streetAndNeighbourhoodLength()** - `address_formatter.dart`
   - Format address intelligently based on street name length
   - Copenhagen-specific neighbourhood abbreviations
   - Returns: `String` (e.g., "Vesterbrogade 23, Kbh V")

3. **openClosesAt()** - `hours_formatter.dart`
   - Return "closes at X" or "opens at X" message based on current time
   - Handles complex scenarios: overnight hours, multiple slots, by-appointment
   - Returns: `String` (e.g., "til 22:00", "opens tomorrow at 10:00")

4. **convertAndFormatPriceRange()** - `price_formatter.dart`
   - Format price range with currency conversion
   - Returns: `String` (e.g., "100-200 kr.", "€50 - €100")

## Custom Actions Used (1)

1. **determineStatusAndColor()** - `determine_status_and_color.dart`
   - Async action that calculates open/closed status with 30-minute "soon" thresholds
   - Called once on component load via `SchedulerBinding.addPostFrameCallback()`
   - Updates `_statusColor` and `_statusText` via `setState()`
   - Returns: `String` (status text)
   - Side effect: Sets color via callback `(Color color) { setState(() => _statusColor = color); }`

## Visual Layout (107px height)

```
┌─────────────────────────────────────────────────────────────┐
│ [Image]  [Info Section]                                     │
│  100x100  ├─ Row 1: Business Name (20px, w500, bold)       │
│   5px     │                                                  │
│  radius   ├─ Row 2: [Dot] Status • Closing Time            │
│           │  (15px, w400, status text colored by action)    │
│           │                                                  │
│           ├─ Row 3: Type • Price • Distance                 │
│           │  (15px, w400, all light gray)                   │
│           │                                                  │
│           └─ Row 4: Street Address + Neighbourhood          │
│              (15px, w400, light gray)                        │
└─────────────────────────────────────────────────────────────┘

Spacing:
- Image to info: 8px horizontal
- Between rows: 3px vertical
- Within rows: 4px horizontal (bullet separator)
- Container padding: 0px (full width)
- Container height: 107px (fixed)
```

## Row Details

### Row 1: Business Name
- **Content**: Business name string
- **Styling**: 20px, fontWeight w500 (medium), textPrimary color
- **Fallback**: "BusinessName" if null
- **Overflow**: Text ellipsis (maxLines: 1)

### Row 2: Status + Hours
- **Content**:
  - Status dot (8x8 circle, colored by determineStatusAndColor action)
  - Status text from action ("Open", "Closed", "Opening soon", "Closing soon")
  - Bullet separator ("•")
  - Hours text from openClosesAt() ("til 22:00", "opens at 10:00", etc.)
- **Styling**: 15px, fontWeight w400, textSecondary color (except status text uses action's color)
- **Conditional**: Status display depends on action completion (async)

### Row 3: Type + Price + Distance
- **Content**:
  - Business type ("Vegetarian Restaurant")
  - Bullet separator ("•")
  - Price range (formatted with currency: "100-200 kr.")
  - Bullet separator ("•") - only if location available
  - Distance - only shown if user location is available AND business location is valid
- **Styling**: 15px, fontWeight w400, textSecondary color
- **Fallback**: "Type" for type, "Unavailable" for price, "0 km" for distance

### Row 4: Address
- **Content**: Formatted address from streetAndNeighbourhoodLength()
- **Styling**: 15px, fontWeight w400, textSecondary color
- **Fallback**: "København" if address is null
- **Overflow**: Text ellipsis (maxLines: 1)

## Translation Keys
All translations accessed via `Localizations.localeOf(context).languageCode` passed to custom functions.

**Function-specific translation keys** (handled internally by custom functions):
- Status messages: 'status_open', 'status_closed', 'status_opening_soon', 'status_closing_soon'
- Hours messages: 'hours_closes_at', 'hours_opens_tomorrow', 'hours_closed_today', etc. (15+ keys)
- Distance units: automatically handled by returnDistance() (returns formatted string with unit)

**Bullet separator:**
- Uses plain text "•" (not a translation key)

## Edge Cases

1. **No opening hours** → Show "Hours not available" (handled by openClosesAt function)
2. **No user location** → Hide distance display entirely (conditional rendering)
3. **No business location** → Hide distance display entirely (conditional rendering)
4. **No address** → Show "København" as fallback
5. **Action fails** → Status text defaults to "Open" or "Closed", color defaults to gray
6. **Image load fails** → CachedNetworkImage shows error widget (icon + text)
7. **Null props** → Graceful fallbacks throughout (use ?? operator)
8. **Very long business name** → Ellipsis truncation (maxLines: 1)
9. **Very long address** → Ellipsis truncation (maxLines: 1)

## Performance Notes

- `determineStatusAndColor()` is async but called once on load (not on rebuild)
- All 4 custom functions are synchronous and fast (< 1ms each)
- Image loading is lazy via CachedNetworkImage with placeholder
- No expensive computations in build() method
- Status calculation happens post-frame to avoid blocking initial render

## Design Tokens

### Colors
- Business name: `AppColors.textPrimary` (#0f0f0f)
- All other text: `AppColors.textSecondary` (#555555)
- Status open: `Color(0xFF518751)` (green from action)
- Status closed: `Color(0xFFFF5963)` (red from action)
- Container background: `AppColors.bgCard` (white)
- Image placeholder: `AppColors.bgSurface` (#fafafa)

### Spacing
- Image to info gap: 8px (not AppSpacing - FlutterFlow uses 8px directly)
- Between rows: 3px vertical (not AppSpacing - FlutterFlow uses 3px directly)
- Within rows: 4px horizontal (not AppSpacing - FlutterFlow uses 4px directly)
- **Note**: FlutterFlow uses non-standard spacing here (3px, 4px, 8px). We preserve these exact values for pixel-perfect match.

### Typography
- Business name: 20px, w500 (custom - not AppTypography)
- Other text: 15px, w400/w300 (custom - not AppTypography)
- **Note**: FlutterFlow uses non-standard font sizes (15px, 20px) and weights (w300). We preserve these exact values.

### Radius
- Image: 5px border radius (custom - not AppRadius)
- Container: 0px border radius (no rounding)
- **Note**: FlutterFlow uses non-standard radius. We preserve 5px for image.

## Dependencies

### Dart Packages
```dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:cached_network_image/cached_network_image.dart';
```

### Internal Imports
```dart
import '../../theme/app_colors.dart';
import '../../models/lat_lng.dart';
import '../../services/custom_functions/distance_calculator.dart';
import '../../services/custom_functions/address_formatter.dart';
import '../../services/custom_functions/hours_formatter.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../services/custom_actions/determine_status_and_color.dart';
```

## Usage Example

```dart
ProfileTopBusinessBlockWidget(
  // Required props
  openingHours: businessData['business_hours'],
  userLocation: userLatLng,
  priceRangeMin: 100,
  priceRangeMax: 200,

  // Optional props
  profilePicture: businessData['logo_url'],
  businessName: businessData['name'],
  latitude: businessData['latitude'],
  longitude: businessData['longitude'],
  street: businessData['street_address'],
  neighbourhoodName: businessData['neighbourhood'],
  businessID: businessData['id'],
  businessType: businessData['business_type'],
)
```

## FlutterFlow Source Reference
- **File**: `_flutterflow_export/lib/profile/business_information/profile_top_business_block/profile_top_business_block_widget.dart`
- **Lines**: 346 lines total
- **Key Sections**:
  - Line 65-76: Action call via SchedulerBinding
  - Line 107-115: Image rendering
  - Line 130-145: Business name row
  - Line 151-224: Status + hours row
  - Line 226-316: Type + price + distance row
  - Line 317-337: Address row

## Testing Checklist

- [ ] Widget renders with all props filled
- [ ] Widget renders with only required props
- [ ] Status updates correctly when action completes
- [ ] Distance displays in km for Danish, mi for English
- [ ] Distance hidden when no user location
- [ ] Distance hidden when no business location
- [ ] Price range formats correctly with currency
- [ ] Address formats correctly (short/medium/long streets)
- [ ] Hours message displays correctly
- [ ] Image loads and displays
- [ ] Image fallback works when URL is null/invalid
- [ ] All edge cases handled (null props, missing data)
- [ ] No flutter analyze issues
- [ ] Action failure handled gracefully (default status shown)

## Known Limitations

1. **Translation cache access**: Widget is StatefulWidget (no ref), so translations must be passed to custom functions. Functions have temporary hardcoded translations until wired to translationsCacheProvider.

2. **Exchange rate access**: Widget doesn't have access to localizationProvider for exchange rate. Uses hardcoded 1.0 for now (displays in original DKK).

3. **Action color palette**: determineStatusAndColor returns hardcoded colors (green/red) that don't use AppColors design tokens. This is intentional to match FlutterFlow exactly.

## Migration Notes from FlutterFlow

### Removed Patterns
- ✅ No `markUserEngaged()` calls (ActivityScope handles engagement automatically)
- ✅ No `FFAppState()` references (widget is props-based)
- ✅ No `FFLocalizations` (uses `Localizations.localeOf(context)`)
- ✅ No `FlutterFlowTheme` (uses AppColors + custom styling)
- ✅ No `safeSetState` (uses regular `setState`)

### Preserved Patterns
- ✅ SchedulerBinding for action call (unchanged)
- ✅ Exact spacing values (3px, 4px, 8px)
- ✅ Exact font sizes (15px, 20px)
- ✅ Exact font weights (w300, w400, w500)
- ✅ 107px container height (unchanged)
- ✅ 5px image border radius (unchanged)

## Session Implementation Details
- **Session**: Phase 7.4 Session 5
- **Date**: 2026-02-22
- **Lines of Code**: ~600 lines (estimated)
- **Complexity**: ⭐⭐⭐⭐ High (multiple async dependencies, complex layout, 4 custom functions + 1 action)
