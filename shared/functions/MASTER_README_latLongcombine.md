# latLongcombine Function

**Type:** Custom Function (Pure)
**File:** `custom_functions.dart` (lines 68-80)
**Category:** Geolocation & Data Transformation
**Status:** ✅ Production Ready

---

## Purpose

Combines separate latitude and longitude values into a single LatLng object with precision limited to 4 decimal places. Used primarily to convert database double values into FlutterFlow's LatLng type.

**Key Features:**
- Precision normalization (4 decimal places)
- Type conversion from double to LatLng
- Consistent coordinate formatting

---

## Function Signature

```dart
LatLng latLongcombine(
  double lat,
  double long,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `lat` | `double` | **Yes** | Latitude value (will be rounded to 4 decimal places) |
| `long` | `double` | **Yes** | Longitude value (will be rounded to 4 decimal places) |

### Returns

| Type | Description |
|------|-------------|
| `LatLng` | FlutterFlow LatLng object with 4-decimal precision |

---

## Implementation

```dart
LatLng latLongcombine(
  double lat,
  double long,
) {
  // Assuming lat and long are single values
  double latValue =
      double.parse(double.parse(lat.toString()).toStringAsFixed(4));
  double longValue =
      double.parse(double.parse(long.toString()).toStringAsFixed(4));

  // Return the LatLng object
  return LatLng(latValue, longValue);
}
```

**Precision Logic:**
1. Convert double to string
2. Parse back to double (normalizes scientific notation)
3. Format to 4 decimal places
4. Parse back to double (final value)
5. Create LatLng object

---

## Dependencies

### pub.dev Packages
- None (uses Dart core library)

### Internal Dependencies
```dart
import 'lat_lng.dart';  // FlutterFlow LatLng class
```

---

## Precision Analysis

### 4 Decimal Places = ~11 meters

| Decimal Places | Precision | Use Case |
|----------------|-----------|----------|
| 1 | ~11 km | Country-level |
| 2 | ~1.1 km | City-level |
| 3 | ~110 m | Neighborhood |
| **4** | **~11 m** | **Street address** |
| 5 | ~1.1 m | Building |
| 6 | ~11 cm | Exact position |

**For JourneyMate:**
- Restaurants identified by street address
- 4 decimal places = 11-meter accuracy
- Sufficient for restaurant location display
- Matches Google Maps precision for businesses

---

## Usage Examples

### Example 1: Create LatLng from Database Values
```dart
// Business data from Supabase:
final businessLat = 55.676098;
final businessLong = 12.568337;

// Convert to LatLng:
final location = functions.latLongcombine(businessLat, businessLong);

// Use in Map:
GoogleMap(
  initialCameraPosition: CameraPosition(
    target: location,
    zoom: 14.0,
  ),
);
```

### Example 2: Store User Location in State
```dart
// Get location from device:
Position position = await Geolocator.getCurrentPosition();

// Convert to LatLng for storage:
FFAppState().currentUserLocation = functions.latLongcombine(
  position.latitude,
  position.longitude,
);
```

### Example 3: Create LatLng from API Response
```dart
// BuildShip API returns separate lat/long:
final apiResponse = await actions.searchBusinesses();

for (var business in apiResponse['documents']) {
  final location = functions.latLongcombine(
    business['latitude'],
    business['longitude'],
  );

  businessLocations.add(location);
}
```

### Example 4: Normalize Coordinate Precision
```dart
// Normalize high-precision GPS coordinates:
final gpsLat = 55.67609812345678;  // GPS precision
final gpsLong = 12.56833712345678;

final normalized = functions.latLongcombine(gpsLat, gpsLong);
// Returns: LatLng(55.6761, 12.5683) - normalized to 4 decimals
```

### Example 5: Create LatLng from Form Input
```dart
// User enters coordinates manually:
final latController = TextEditingController();
final longController = TextEditingController();

// Parse and combine:
final location = functions.latLongcombine(
  double.parse(latController.text),
  double.parse(longController.text),
);
```

---

## Used By Pages

| Page | Usage | Purpose |
|------|-------|---------|
| **Map View** | Convert business coordinates to LatLng | Display markers |
| **Search Results** | Convert coordinates for distance calculation | Show distances |
| **Business Profile** | Convert business location for map display | Show location |

---

## Used By Custom Actions

| Action | Usage | Purpose |
|--------|-------|---------|
| `searchBusinesses` | Convert API coordinates to LatLng | Process search results |
| `updateUserLocation` | Convert GPS coordinates to LatLng | Store user location |
| `geocodeAddress` | Convert geocoding results to LatLng | Address → coordinates |

---

## Edge Cases Handled

### Edge Case 1: High-Precision Input
**Input:**
```dart
latLongcombine(
  55.67609812345678,  // 14 decimal places
  12.56833712345678,
)
```

**Returns:**
```dart
LatLng(55.6761, 12.5683)  // Truncated to 4 decimals
```

### Edge Case 2: Low-Precision Input
**Input:**
```dart
latLongcombine(
  55.6,     // 1 decimal place
  12.5,     // 1 decimal place
)
```

**Returns:**
```dart
LatLng(55.6000, 12.5000)  // Padded to 4 decimals
```

### Edge Case 3: Zero Coordinates
**Input:**
```dart
latLongcombine(0.0, 0.0)
```

**Returns:**
```dart
LatLng(0.0000, 0.0000)
```

**Meaning:** Null Island (0°N, 0°E) in the Gulf of Guinea - valid but unlikely

### Edge Case 4: Negative Coordinates
**Input:**
```dart
latLongcombine(
  -33.8688,  // Sydney, Australia
  151.2093,
)
```

**Returns:**
```dart
LatLng(-33.8688, 151.2093)  // Handles negative correctly
```

### Edge Case 5: Boundary Values
**Input:**
```dart
latLongcombine(90.0, 180.0)    // North Pole, Date Line
latLongcombine(-90.0, -180.0)  // South Pole, Date Line
```

**Returns:**
```dart
LatLng(90.0000, 180.0000)
LatLng(-90.0000, -180.0000)
```

**Note:** No validation - accepts any values (validation done by returnDistance)

### Edge Case 6: Scientific Notation Input
**Input:**
```dart
latLongcombine(5.56761e1, 1.25683e1)  // Scientific notation
```

**Returns:**
```dart
LatLng(55.6761, 12.5683)  // Correctly parsed
```

---

## Known Issues & Limitations

### Issue 1: Double Parsing Overhead
**Problem:**
```dart
double.parse(double.parse(lat.toString()).toStringAsFixed(4))
```

**Inefficiency:**
- Converts double → string → double → string → double
- 4 conversions for a simple rounding operation

**Better Implementation:**
```dart
double latValue = (lat * 10000).roundToDouble() / 10000;
double longValue = (long * 10000).roundToDouble() / 10000;
return LatLng(latValue, longValue);
```

**Impact:** Minimal (< 1 microsecond difference), but cleaner code

### Issue 2: No Input Validation
**Problem:** Accepts any double values, including invalid coordinates

**Examples:**
```dart
latLongcombine(999.0, 999.0)    // Invalid - no error
latLongcombine(-200.0, 500.0)   // Out of bounds - no error
```

**Recommendation:** Add validation:
```dart
if (lat < -90 || lat > 90) {
  throw ArgumentError('Invalid latitude: $lat');
}
if (long < -180 || long > 180) {
  throw ArgumentError('Invalid longitude: $long');
}
```

**Current Behavior:** Validation happens in `returnDistance()`, not here

### Issue 3: Silent Precision Loss
**Problem:** Truncates precision without notification

**Example:**
```dart
latLongcombine(55.676098765, 12.568337890)
// Loses: .000000765 and .000000890
// User unaware of precision change
```

**Impact:** Acceptable for restaurant locations (±11m precision sufficient)

### Issue 4: No NaN/Infinity Handling
**Problem:**
```dart
latLongcombine(double.nan, double.infinity)
// Creates: LatLng(NaN, Infinity) - invalid but doesn't crash
```

**Recommendation:** Add checks:
```dart
if (lat.isNaN || lat.isInfinite || long.isNaN || long.isInfinite) {
  throw ArgumentError('Invalid coordinate values');
}
```

---

## Performance Considerations

### Time Complexity
- **O(1)** - Fixed number of operations

### Memory Usage
- **O(1)** - Creates single LatLng object

### Execution Time
- **< 5 microseconds** - Very fast despite string conversions

### Optimization Opportunity

**Current Implementation:**
```dart
double.parse(double.parse(lat.toString()).toStringAsFixed(4))
```

**Optimized Alternative:**
```dart
(lat * 10000).roundToDouble() / 10000
```

**Performance Gain:** ~2-3x faster (avoids string operations)

**Migration Recommendation:** Update during Phase 3

---

## Testing Checklist

When implementing in Flutter:

- [ ] Test with typical Copenhagen coordinates - correct output
- [ ] Test with high-precision input (14 decimals) - truncated to 4
- [ ] Test with low-precision input (1 decimal) - padded to 4
- [ ] Test with zero coordinates (0.0, 0.0) - valid LatLng
- [ ] Test with negative coordinates (Southern/Western hemispheres) - correct
- [ ] Test with boundary values (90, 180) - valid LatLng
- [ ] Test with scientific notation input - correctly parsed
- [ ] Test with NaN input - behavior documented
- [ ] Test with Infinity input - behavior documented
- [ ] Test output in returnDistance - distances calculated correctly
- [ ] Test output in GoogleMap - markers display correctly
- [ ] Verify precision: 55.676098 → 55.6761
- [ ] Verify precision: 12.568337 → 12.5683
- [ ] Test performance: 1000 combinations < 5ms

---

## Migration Notes

### Phase 3 Changes

**Option 1: Keep as-is** (simplest)
```dart
LatLng latLongcombine(double lat, double long) {
  double latValue =
      double.parse(double.parse(lat.toString()).toStringAsFixed(4));
  double longValue =
      double.parse(double.parse(long.toString()).toStringAsFixed(4));
  return LatLng(latValue, longValue);
}
```

**Option 2: Optimize** (recommended)
```dart
LatLng latLongcombine(double lat, double long) {
  // Faster: avoid string conversions
  double latValue = (lat * 10000).roundToDouble() / 10000;
  double longValue = (long * 10000).roundToDouble() / 10000;
  return LatLng(latValue, longValue);
}
```

**Option 3: Add validation** (safest)
```dart
LatLng latLongcombine(double lat, double long) {
  // Validate inputs
  if (lat < -90 || lat > 90) {
    throw ArgumentError('Invalid latitude: $lat');
  }
  if (long < -180 || long > 180) {
    throw ArgumentError('Invalid longitude: $long');
  }
  if (lat.isNaN || long.isNaN) {
    throw ArgumentError('Coordinates cannot be NaN');
  }

  // Normalize precision
  double latValue = (lat * 10000).roundToDouble() / 10000;
  double longValue = (long * 10000).roundToDouble() / 10000;

  return LatLng(latValue, longValue);
}
```

**Update LatLng import:**
```dart
// Before:
import 'package:journey_mate/flutter_flow/lat_lng.dart';

// After (use Google Maps):
import 'package:google_maps_flutter/google_maps_flutter.dart';
```

---

## Related Functions

| Function | Relationship |
|----------|-------------|
| `returnDistance` | Uses LatLng objects created by this function |
| `hasLocationPermission` | Checks before creating LatLng from device location |

---

## Related Custom Actions

| Action | Relationship |
|--------|-------------|
| `searchBusinesses` | Converts API coordinates using this function |
| `updateUserLocation` | Stores LatLng created by this function |
| `geocodeAddress` | Converts geocoding results to LatLng |

---

## Why 4 Decimal Places?

### Precision vs. Use Case

**Too Precise (6+ decimals):**
- Precision: < 1 meter
- Use case: GPS tracking, navigation
- Not needed: Restaurant locations don't change at centimeter level

**Too Imprecise (2-3 decimals):**
- Precision: 100-1000 meters
- Use case: City-level mapping
- Problem: Multiple restaurants at "same" location

**Just Right (4 decimals):**
- Precision: ~11 meters
- Use case: Street addresses
- Perfect: Identifies specific building without excessive precision
- Matches: Google Maps business locations

---

## Future Enhancements

1. **Add input validation** - Prevent invalid coordinates
2. **Optimize implementation** - Avoid string conversions
3. **Add NaN/Infinity checks** - Explicit error handling
4. **Support variable precision** - Optional decimal places parameter
5. **Add coordinate system parameter** - Support WGS84 vs other systems

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ Phase 3 - Optimize & add validation
**Priority:** ⭐⭐⭐ Medium-High (used frequently but simple function)
