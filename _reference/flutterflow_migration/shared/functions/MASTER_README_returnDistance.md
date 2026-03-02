# returnDistance Function

**Type:** Custom Function (Pure)
**File:** `custom_functions.dart` (lines 16-66)
**Category:** Geolocation & Distance Calculation
**Status:** ✅ Production Ready
**⚠️ BREAKING CHANGE (commit c767773, 2026-03-02):** Function signature changed from `languageCode` to `distanceUnit` parameter. See Migration Note below.

---

## Purpose

Calculates the great-circle distance between two geographical points using the Haversine formula. Converts output to miles when `distanceUnit` is `'imperial'`, otherwise returns kilometers.

**Key Features:**
- Precise distance calculation using Haversine formula
- Explicit unit conversion based on `distanceUnit` parameter ('imperial' or 'metric')
- Input validation for latitude/longitude bounds
- Optimized for performance with minimal memory allocation

---

## Function Signature

```dart
double returnDistance(
  LatLng currentDeviceLocation,
  double businessLatitude,
  double businessLongitude,
  String distanceUnit,  // ⚠️ BREAKING CHANGE: Was 'languageCode' before commit c767773
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currentDeviceLocation` | `LatLng` | **Yes** | The current location of the device as a LatLng object |
| `businessLatitude` | `double` | **Yes** | The latitude of the business location (-90 to 90) |
| `businessLongitude` | `double` | **Yes** | The longitude of the business location (-180 to 180) |
| `distanceUnit` | `String` | **Yes** | Distance unit: `'imperial'` (miles) or `'metric'` (kilometers). **Breaking change (commit c767773):** Previously accepted `languageCode` — now requires explicit unit. |

### Returns

| Type | Description |
|------|-------------|
| `double` | Distance rounded to one decimal place in kilometers or miles |

---

## ⚠️ Migration Note (Commit c767773)

**Breaking change:** The 4th parameter changed from `languageCode` to `distanceUnit`.

**Before (deprecated):**
```dart
final distance = returnDistance(
  userLocation,
  businessLat,
  businessLng,
  'en',  // ❌ Language code
);
```

**After (current):**
```dart
// Option 1: Read from provider (recommended)
final localization = ref.read(localizationProvider);
final languageCode = Localizations.localeOf(context).languageCode;

// Non-English: ALWAYS metric (ignore stored preference)
// English: Use stored preference (imperial or metric)
final effectiveUnit = languageCode == 'en'
    ? localization.distanceUnit
    : 'metric';

final distance = returnDistance(
  userLocation,
  businessLat,
  businessLng,
  effectiveUnit,  // ✅ Distance unit
);

// Option 2: Hardcode metric (for non-English contexts)
final distance = returnDistance(
  userLocation,
  businessLat,
  businessLng,
  'metric',  // ✅ Always show kilometers
);
```

**Rationale:** Decoupled distance unit from language to support English users in metric countries (Europe, Australia, etc.).

---

## Implementation

### Haversine Formula

```dart
// Conversion factor for degrees to radians
var p = 0.017453292519943295;

// Convert latitudes and longitudes from degrees to radians
double lat1 = currentDeviceLocation.latitude * p;
double lon1 = currentDeviceLocation.longitude * p;
double lat2 = businessLatitude * p;
double lon2 = businessLongitude * p;

// Haversine formula to calculate the distance
double a = 0.5 -
    math.cos(lat2 - lat1) / 2 +
    math.cos(lat1) * math.cos(lat2) * (1 - math.cos(lon2 - lon1)) / 2;

// Distance in kilometers (Earth's diameter = 12742 km)
double result = 12742 * math.asin(math.sqrt(a));
```

### Unit Conversion Logic

```dart
// If language code is English, convert to miles
if (languageCode.toLowerCase() == 'en') {
  result = result * 0.621371;
}

// Round to one decimal place and return
return double.parse(result.toStringAsFixed(1));
```

**Conversion Factor:** 1 km = 0.621371 miles

---

## Dependencies

### pub.dev Packages
```dart
import 'dart:math' as math;  // For cos, asin, sqrt functions
```

### Internal Dependencies
```dart
import 'lat_lng.dart';  // LatLng class (FlutterFlow)
```

---

## Usage Examples

### Example 1: Search Results Card Distance
```dart
final distance = functions.returnDistance(
  currentUserLocationValue!,  // User's current location
  restaurantItem.latitude,     // Business latitude from database
  restaurantItem.longitude,    // Business longitude from database
  FFLocalizations.of(context).languageCode,  // 'en', 'da', etc.
);

// Display distance
Text('$distance ${languageCode == 'en' ? 'mi' : 'km'}');
// Output: "1.2 mi" (English) or "2.0 km" (Danish)
```

### Example 2: Business Profile Distance
```dart
// In BusinessProfileWidget:
final distanceText = functions.returnDistance(
  FFAppState().currentDeviceLocation,
  widget.businessLat,
  widget.businessLong,
  FFLocalizations.of(context).languageCode,
).toString();

Text('$distanceText ${FFLocalizations.of(context).getText('distance_unit')}');
```

### Example 3: Sort by Distance
```dart
// Sort restaurants by distance from user
final sortedRestaurants = restaurants.toList()..sort((a, b) {
  final distA = functions.returnDistance(
    currentUserLocationValue!,
    a.latitude,
    a.longitude,
    'en',
  );
  final distB = functions.returnDistance(
    currentUserLocationValue!,
    b.latitude,
    b.longitude,
    'en',
  );
  return distA.compareTo(distB);
});
```

### Example 4: Filter by Distance Radius
```dart
// Show only restaurants within 5 km
final nearbyRestaurants = allRestaurants.where((restaurant) {
  final distance = functions.returnDistance(
    currentUserLocationValue!,
    restaurant.latitude,
    restaurant.longitude,
    'da',  // Always calculate in km
  );
  return distance <= 5.0;
}).toList();
```

### Example 5: Distance with Conditional Display
```dart
// Show distance only if location permission granted
final distance = hasLocationPermission
    ? functions.returnDistance(
        currentUserLocationValue!,
        businessLat,
        businessLong,
        languageCode,
      )
    : null;

Text(distance != null
  ? '$distance ${languageCode == 'en' ? 'mi' : 'km'}'
  : FFLocalizations.of(context).getText('location_unavailable')
);
```

---

## Used By Pages

| Page | Usage | Purpose |
|------|-------|---------|
| **Search Results** | Display distance for each restaurant card | Show proximity to user |
| **Business Profile** | Display distance in header | Show how far business is |
| **Map View** | Calculate distances for pin labels | Distance context on map |

---

## Used By Custom Widgets

| Widget | Usage | Purpose |
|--------|-------|---------|
| `RestaurantCardWidget` | Distance badge display | Show proximity on cards |
| `BusinessHeaderWidget` | Distance in header | Show business distance |
| `MapPinWidget` | Distance labels on pins | Context on map markers |

---

## Edge Cases Handled

### Edge Case 1: Invalid Latitude (Out of Bounds)
**Input:**
```dart
returnDistance(
  LatLng(55.6761, 12.5683),  // Copenhagen
  91.0,                      // Invalid latitude > 90
  12.5683,
  'en',
)
```

**Behavior:**
```
Exception: Invalid business latitude: 91.0
```

**Validation:**
```dart
if (businessLatitude < -90 || businessLatitude > 90) {
  throw Exception("Invalid business latitude: $businessLatitude");
}
```

### Edge Case 2: Invalid Longitude (Out of Bounds)
**Input:**
```dart
returnDistance(
  LatLng(55.6761, 12.5683),
  55.6761,
  185.0,  // Invalid longitude > 180
  'en',
)
```

**Behavior:**
```
Exception: Invalid business longitude: 185.0
```

**Validation:**
```dart
if (businessLongitude < -180 || businessLongitude > 180) {
  throw Exception("Invalid business longitude: $businessLongitude");
}
```

### Edge Case 3: Identical Locations
**Input:**
```dart
returnDistance(
  LatLng(55.6761, 12.5683),
  55.6761,
  12.5683,
  'da',
)
```

**Returns:** `0.0` km (correct - no distance)

### Edge Case 4: Antipodal Points (Opposite Sides of Earth)
**Input:**
```dart
returnDistance(
  LatLng(0.0, 0.0),    // Equator, Prime Meridian
  0.0,
  180.0,               // Opposite side
  'en',
)
```

**Returns:** ~12,450.0 mi (approximately half Earth's circumference)

### Edge Case 5: Near-Zero Distance
**Input:**
```dart
returnDistance(
  LatLng(55.676098, 12.568337),  // Copenhagen street corner
  55.676100,                      // 0.2 meters away
  12.568340,
  'da',
)
```

**Returns:** `0.0` km (rounds down from 0.00002 km)

### Edge Case 6: Language Code Case Sensitivity
**Input:**
```dart
// Test with uppercase/mixed case
returnDistance(location, lat, long, 'EN')   // Uppercase
returnDistance(location, lat, long, 'En')   // Mixed
returnDistance(location, lat, long, 'en')   // Lowercase
```

**Behavior:** All handled correctly due to `languageCode.toLowerCase() == 'en'`

---

## Unit Conversion Details

### Kilometers (Default)
**Languages:** da, de, fr, it, nl, no, sv, pl, fi, ja, ko, uk, zh, es

**Formula:** Direct output from Haversine (no conversion)

**Example:**
```dart
returnDistance(location, 55.6761, 12.5683, 'da')  // Returns: 2.5 km
```

### Miles (English Only)
**Language:** en

**Formula:** `kilometers * 0.621371`

**Example:**
```dart
returnDistance(location, 55.6761, 12.5683, 'en')  // Returns: 1.6 mi
```

**Conversion Accuracy:**
- 1 km = 0.621371 miles (standard conversion)
- Rounded to 1 decimal place for display

---

## Performance Considerations

### Time Complexity
- **O(1)** - Fixed number of trigonometric operations

### Memory Usage
- **O(1)** - No allocations, only primitive operations

### Execution Time
- **< 10 microseconds** - Very fast (trigonometric functions are optimized)

### Optimization Notes

**Already Optimized:**
- Uses efficient Haversine formula (industry standard)
- Minimal floating-point operations
- No unnecessary object allocations
- Direct return without intermediate storage

**Why Haversine?**
- More accurate than simple Euclidean distance
- Accounts for Earth's curvature
- Industry-standard for geolocation apps
- Accuracy: ±0.3% for typical distances

**Alternative (Not Used):**
Vincenty formula - More accurate but 10x slower, unnecessary for UI display

---

## Accuracy Analysis

### Haversine Formula Accuracy

**Assumptions:**
- Earth is a perfect sphere (it's actually an oblate spheroid)
- Radius = 6,371 km (mean Earth radius)

**Accuracy:**
- **Short distances (< 100 km):** ±50 meters
- **Medium distances (100-1000 km):** ±0.3%
- **Long distances (> 1000 km):** ±0.5%

**For JourneyMate:**
- Typical use: 0-20 km (local restaurants)
- Accuracy: ±50 meters (acceptable for UI display)
- User perception: 1 decimal place sufficient

### Rounding Impact

**One Decimal Place:**
```
0.5 km = 500 meters
0.1 km = 100 meters
```

**User Experience:**
- "1.2 km" vs "1.234 km" - no meaningful difference
- Cleaner UI without excessive precision
- Matches user mental model of distance

---

## Testing Checklist

When implementing in Flutter:

- [ ] Test Copenhagen to Nyhavn (short distance ~1 km)
- [ ] Test Copenhagen to Aarhus (medium distance ~200 km)
- [ ] Test Copenhagen to London (long distance ~1000 km)
- [ ] Test with English language code - returns miles
- [ ] Test with Danish language code - returns kilometers
- [ ] Test with invalid latitude > 90 - throws exception
- [ ] Test with invalid latitude < -90 - throws exception
- [ ] Test with invalid longitude > 180 - throws exception
- [ ] Test with invalid longitude < -180 - throws exception
- [ ] Test identical locations - returns 0.0
- [ ] Test uppercase language code 'EN' - works correctly
- [ ] Test rounding: 1.25 km → 1.3 km (rounds up)
- [ ] Test rounding: 1.24 km → 1.2 km (rounds down)
- [ ] Test near-zero distance - returns 0.0
- [ ] Test antipodal points - returns ~20,000 km
- [ ] Verify conversion: 5 km = 3.1 mi
- [ ] Verify conversion: 10 mi = 16.1 km (reverse check)
- [ ] Test performance: 1000 calculations < 10ms

---

## Migration Notes

### Phase 3 Changes

**Keep function as-is** - pure Dart with standard dependencies.

**Update calling code** to use new state management:
```dart
// Before (FlutterFlow):
functions.returnDistance(
  currentUserLocationValue!,
  businessLat,
  businessLong,
  FFLocalizations.of(context).languageCode,
)

// After (Riverpod example):
functions.returnDistance(
  ref.watch(userLocationProvider)!,
  business.latitude,
  business.longitude,
  Localizations.localeOf(context).languageCode,
)
```

**Update LatLng import:**
```dart
// Before:
import 'package:journey_mate/flutter_flow/lat_lng.dart';

// After (use native Flutter):
import 'package:google_maps_flutter/google_maps_flutter.dart';
// LatLng class from Google Maps plugin
```

---

## Related Functions

| Function | Relationship |
|----------|-------------|
| `latLongcombine` | Creates LatLng objects used by this function |
| `hasLocationPermission` | Determines if location available for distance calculation |

---

## Related Custom Actions

| Action | Relationship |
|--------|-------------|
| `requestLocationPermission` | Must grant permission before calling this function |
| `updateCurrentLocation` | Updates location used by this function |

---

## Known Issues

1. **No great-circle vs driving distance** - Shows straight-line distance, not travel distance
2. **No unit preference setting** - Unit determined by language only (could add user preference)
3. **Assumes Earth radius = 6371 km** - Could use WGS84 ellipsoid for ±0.1% better accuracy
4. **No error handling for null LatLng** - Assumes currentDeviceLocation is never null

**None of these are critical** - current implementation sufficient for restaurant discovery app.

---

## Future Enhancements

1. **Add user unit preference** - Override language-based unit selection
2. **Add driving distance** - Integrate Google Directions API
3. **Add distance categories** - "Nearby" (< 1 km), "Walking distance" (< 2 km), etc.
4. **Add elevation consideration** - Account for hills (not needed for Copenhagen)
5. **Add cached results** - Cache distances for performance (only if needed)

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ Phase 3 - Keep as-is, update imports
**Priority:** ⭐⭐⭐⭐⭐ Critical (used on every restaurant card)
