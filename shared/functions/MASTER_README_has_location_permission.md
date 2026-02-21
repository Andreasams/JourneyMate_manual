# hasLocationPermission Custom Function

**Status:** DOCUMENTED
**Date:** 2026-02-19
**Author:** Claude Code
**Source File:** `_flutterflow_export\lib\flutter_flow\custom_functions.dart` (lines 2385-2419)

---

## Table of Contents

1. [Purpose](#purpose)
2. [Function Signature](#function-signature)
3. [Parameters](#parameters)
4. [Return Value](#return-value)
5. [Implementation Logic](#implementation-logic)
6. [Dependencies](#dependencies)
7. [FFAppState Usage](#ffappstate-usage)
8. [Usage Examples](#usage-examples)
9. [Edge Cases](#edge-cases)
10. [Testing Checklist](#testing-checklist)
11. [Migration Notes](#migration-notes)

---

## Purpose

`hasLocationPermission` is a **permission status detector** that determines whether the app currently has access to the device's location by checking if FlutterFlow's `currentDeviceLocation` returns real coordinates.

**Key Insight:** FlutterFlow returns `LatLng(0.0, 0.0)` when permission is denied/revoked or location services are disabled. This function detects that zero-coordinate sentinel value to determine permission status.

**Use Cases:**
- Conditionally show distance information in search results
- Display permission prompt UI when location access is unavailable
- Determine whether to show "Near me" sorting options
- Control visibility of location-dependent features

**Important:** This is a **read-only check**. It does NOT request or modify permissions. Use `checkLocationPermission` or `requestLocationPermission` custom actions for permission management.

---

## Function Signature

```dart
bool hasLocationPermission(LatLng? currentDeviceLocation)
```

**Location in codebase:**
- **File:** `_flutterflow_export\lib\flutter_flow\custom_functions.dart`
- **Lines:** 2385-2419

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `currentDeviceLocation` | `LatLng?` | Yes | The device's current location obtained from FlutterFlow's global `currentUserLocationValue` variable. Returns `LatLng(0.0, 0.0)` when permission denied. |

**Parameter Details:**

### `currentDeviceLocation` (LatLng?)

**Source:** FlutterFlow's global `currentUserLocationValue` variable

**Possible Values:**
- `null` — Location never initialized or completely unavailable
- `LatLng(0.0, 0.0)` — Permission denied, revoked, or location services disabled
- `LatLng(lat, lng)` — Real coordinates when permission granted and location available

**FlutterFlow Behavior:**
```dart
// When permission is GRANTED:
currentUserLocationValue = LatLng(55.6761, 12.5683)  // Real Copenhagen coords

// When permission is DENIED/REVOKED or services DISABLED:
currentUserLocationValue = LatLng(0.0, 0.0)  // Sentinel value

// When location completely unavailable:
currentUserLocationValue = null
```

---

## Return Value

**Type:** `bool`

**Values:**
- `true` — Location permission is granted AND device has valid coordinates
- `false` — Permission denied, revoked, location services disabled, or location unavailable

**Return Logic:**
```dart
// Returns false if:
- currentDeviceLocation == null
- currentDeviceLocation.latitude ≈ 0.0 AND longitude ≈ 0.0

// Returns true if:
- currentDeviceLocation has non-zero latitude OR non-zero longitude
```

**Epsilon Comparison:** Uses `0.0001` epsilon for floating-point comparison to avoid precision issues.

---

## Implementation Logic

### Complete Source Code

```dart
bool hasLocationPermission(LatLng? currentDeviceLocation) {
  /// FlutterFlow's currentDeviceLocation returns (0,0) when:
  /// - Permission was never granted
  /// - Permission was revoked
  /// - Location services are disabled
  ///
  /// Returns real coordinates when permission is granted.
  ///
  /// Args:
  ///   currentDeviceLocation: The device's current location from FlutterFlow
  ///
  /// Returns:
  ///   true if location permission is granted (non-zero coordinates)
  ///   false if permission is denied or location unavailable (0,0 coordinates)

  // Handle null case (location unavailable)
  if (currentDeviceLocation == null) {
    return false;
  }

  // Check if coordinates are (0, 0) - indicates no permission
  // Using small epsilon for floating point comparison
  const epsilon = 0.0001;

  final isZeroLat = currentDeviceLocation.latitude.abs() < epsilon;
  final isZeroLng = currentDeviceLocation.longitude.abs() < epsilon;

  // If both are zero, no permission
  if (isZeroLat && isZeroLng) {
    return false;
  }

  // Has real coordinates = has permission
  return true;
}
```

### Logic Breakdown

**Step 1: Null Check**
```dart
if (currentDeviceLocation == null) {
  return false;
}
```
- **Handles:** Location never initialized or completely unavailable
- **Returns:** `false` immediately

**Step 2: Zero Coordinate Detection**
```dart
const epsilon = 0.0001;

final isZeroLat = currentDeviceLocation.latitude.abs() < epsilon;
final isZeroLng = currentDeviceLocation.longitude.abs() < epsilon;

if (isZeroLat && isZeroLng) {
  return false;
}
```
- **Uses epsilon comparison** to avoid floating-point precision issues
- **Checks both coordinates** must be near-zero for "no permission" status
- **Returns:** `false` if both lat/lng are effectively zero

**Step 3: Valid Coordinates**
```dart
return true;
```
- **If reached:** Location has at least one non-zero coordinate
- **Indicates:** Permission granted and location available

### Why Epsilon Comparison?

**Floating-point precision issue:**
```dart
// Direct comparison might fail:
0.0 == 0.00000001  // false, but effectively zero

// Epsilon comparison handles this:
0.00000001.abs() < 0.0001  // true, correctly identified as zero
```

**Epsilon value:** `0.0001` is approximately **11 meters** at the equator, which is:
- **Small enough** to catch legitimate zero-coordinates
- **Large enough** to handle floating-point imprecision
- **Safe buffer** — no real location would be within 11m of (0°, 0°)

---

## Dependencies

### Imports

```dart
import 'lat_lng.dart';
```

**LatLng Type Definition:**
```dart
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);
}
```

### Related Functions

**This function is READ-ONLY.** For permission management, use:

| Custom Action | Purpose | When to Use |
|---------------|---------|-------------|
| `checkLocationPermission` | Check current system permission status | Before showing permission UI |
| `requestLocationPermission` | Request permission from user | When permission needed but not granted |
| `hasLocationPermission` | Quick check if location available | Conditional UI rendering |

**Workflow:**
```dart
// 1. Quick UI check (this function)
final hasPermission = hasLocationPermission(currentUserLocationValue);
if (!hasPermission) {
  // Show "Enable location" button
}

// 2. Before requesting, check system status
final status = await checkLocationPermission();
if (status == 'denied') {
  // Show rationale or open settings
}

// 3. Request permission if needed
await requestLocationPermission();
```

---

## FFAppState Usage

### Global Variables

**None directly.** However, the `currentDeviceLocation` parameter typically comes from:

```dart
FFAppState().currentUserLocationValue
```

### State Dependencies

This function has **no state dependencies**. It is a pure function that:
- Accepts a `LatLng?` parameter
- Returns a `bool` based solely on that parameter
- Does NOT read from or write to `FFAppState`

**Stateless Design Benefits:**
- **Testable:** Can be unit tested without mocking global state
- **Predictable:** Same input always produces same output
- **Reusable:** Can be called from any context without side effects

---

## Usage Examples

### Example 1: Conditional Distance Display

**Scenario:** Show distance in search results only if permission granted

**FlutterFlow Implementation:**
```dart
// In SearchResultsPage widget tree:
Text(
  hasLocationPermission(currentUserLocationValue)
    ? '${returnDistance(currentUserLocationValue, business.latitude, business.longitude, FFAppState().currentLanguage)} km'
    : 'Location unavailable',
)
```

**Phase 3 Flutter Migration:**
```dart
// In SearchResultCard widget:
Widget build(BuildContext context) {
  final hasPermission = hasLocationPermission(
    Provider.of<AppState>(context).currentUserLocation,
  );

  return Column(
    children: [
      Text(businessName),
      if (hasPermission)
        Text(
          '${returnDistance(
            Provider.of<AppState>(context).currentUserLocation,
            business.latitude,
            business.longitude,
            Provider.of<AppState>(context).currentLanguage,
          )} km',
        )
      else
        Text('Location unavailable'),
    ],
  );
}
```

### Example 2: Permission Prompt UI

**Scenario:** Show location permission button when access unavailable

**FlutterFlow Implementation:**
```dart
// In SearchPage conditional visibility:
Visibility(
  visible: !hasLocationPermission(currentUserLocationValue),
  child: Button(
    text: 'Enable Location',
    onPressed: () async {
      await requestLocationPermission();
    },
  ),
)
```

**Phase 3 Flutter Migration:**
```dart
// In SearchPage build method:
Widget build(BuildContext context) {
  final appState = Provider.of<AppState>(context);
  final hasPermission = hasLocationPermission(appState.currentUserLocation);

  return Column(
    children: [
      if (!hasPermission)
        ElevatedButton(
          onPressed: () async {
            await requestLocationPermission();
            // Trigger state update after permission change
            appState.refreshLocation();
          },
          child: Text('Enable Location'),
        ),
      // Search results...
    ],
  );
}
```

### Example 3: Sort Options Menu

**Scenario:** Only show "Near me" sort option if location available

**FlutterFlow Implementation:**
```dart
// In sort dropdown menu:
DropdownMenuItem(
  enabled: hasLocationPermission(currentUserLocationValue),
  child: Row(
    children: [
      Icon(Icons.near_me),
      Text('Near me'),
      if (!hasLocationPermission(currentUserLocationValue))
        Icon(Icons.lock, size: 16), // Show lock icon when disabled
    ],
  ),
)
```

**Phase 3 Flutter Migration:**
```dart
// In SortMenu widget:
Widget _buildSortOptions(BuildContext context) {
  final appState = Provider.of<AppState>(context);
  final hasPermission = hasLocationPermission(appState.currentUserLocation);

  return Column(
    children: [
      _buildSortOption('Best match', 'best_match'),
      _buildSortOption('Rating', 'rating'),
      if (hasPermission)
        _buildSortOption('Near me', 'distance')
      else
        _buildDisabledSortOption(
          'Near me',
          'distance',
          tooltip: 'Enable location to sort by distance',
        ),
    ],
  );
}
```

### Example 4: Map Center Logic

**Scenario:** Center map on user location if available, else default location

**FlutterFlow Implementation:**
```dart
// In MapPage initialization:
final initialMapCenter = hasLocationPermission(currentUserLocationValue)
  ? currentUserLocationValue
  : LatLng(55.6761, 12.5683); // Default to Copenhagen city center

GoogleMapWidget(
  initialLocation: initialMapCenter,
  // ...
)
```

**Phase 3 Flutter Migration:**
```dart
// In MapPage initState:
@override
void initState() {
  super.initState();
  final appState = Provider.of<AppState>(context, listen: false);
  final hasPermission = hasLocationPermission(appState.currentUserLocation);

  setState(() {
    _mapController.animateCamera(
      CameraUpdate.newLatLng(
        hasPermission
          ? appState.currentUserLocation!
          : const LatLng(55.6761, 12.5683), // Copenhagen default
      ),
    );
  });
}
```

### Example 5: Analytics Tracking

**Scenario:** Track permission status in search analytics

**FlutterFlow Implementation:**
```dart
// In search analytics event:
trackAnalyticsEvent(
  'search_performed',
  {
    'query': searchQuery,
    'hasLocationPermission': hasLocationPermission(currentUserLocationValue),
    'resultsCount': results.length,
  },
);
```

**Phase 3 Flutter Migration:**
```dart
// In SearchPage _performSearch method:
void _performSearch(String query) async {
  final appState = Provider.of<AppState>(context, listen: false);
  final hasPermission = hasLocationPermission(appState.currentUserLocation);

  final results = await searchRestaurants(query);

  analytics.logEvent(
    name: 'search_performed',
    parameters: {
      'query': query,
      'has_location_permission': hasPermission,
      'results_count': results.length,
      'user_latitude': hasPermission ? appState.currentUserLocation?.latitude : null,
      'user_longitude': hasPermission ? appState.currentUserLocation?.longitude : null,
    },
  );
}
```

---

## Edge Cases

### Edge Case 1: Null Input

**Scenario:** `currentDeviceLocation` is `null`

**Behavior:**
```dart
hasLocationPermission(null)  // Returns false
```

**Handling:**
- Function returns `false` immediately at null check
- **Safe:** No null pointer exceptions

**When This Occurs:**
- App first launch before location initialized
- Location services completely unavailable
- Device in airplane mode

### Edge Case 2: Exact Zero Coordinates

**Scenario:** Device happens to be at `LatLng(0.0, 0.0)` (Null Island)

**Behavior:**
```dart
hasLocationPermission(LatLng(0.0, 0.0))  // Returns false
```

**Implications:**
- **False negative:** Real location at (0°, 0°) would be treated as "no permission"
- **Acceptable tradeoff:** Null Island is in the Gulf of Guinea, no restaurants exist there
- **Probability:** Effectively zero for restaurant app users

**If This Were a Real Issue:**
```dart
// Alternative implementation would need:
// - Check actual permission status via system API
// - Distinguish between "0,0 sentinel" and "real 0,0 location"
// - Add metadata flag like hasLocationBeenInitialized
```

### Edge Case 3: Near-Zero Coordinates

**Scenario:** Device is very close to (0°, 0°) but not exactly zero

**Example:**
```dart
hasLocationPermission(LatLng(0.00005, 0.00005))  // Returns true
```

**Behavior:**
- Coordinates fall within epsilon range (`0.00005 < 0.0001`)
- Function returns `false` (treated as zero)

**Real-World Context:**
- `0.00005°` ≈ 5.5 meters at the equator
- Extremely unlikely location for a restaurant user
- Safe to treat as "no permission" scenario

### Edge Case 4: One Zero, One Non-Zero

**Scenario:** One coordinate is zero, the other is not

**Example:**
```dart
hasLocationPermission(LatLng(55.6761, 0.0))  // Returns true
```

**Behavior:**
- Only latitude is non-zero
- Function returns `true` (has permission)

**Why This Works:**
- FlutterFlow sets BOTH coordinates to zero when permission denied
- If either is non-zero, it must be a real location
- No valid location has latitude XOR longitude equal to zero where the other is non-zero near (0,0)

**Edge Locations:**
- Equator (latitude = 0, longitude ≠ 0): Valid location, returns `true` ✓
- Prime Meridian (latitude ≠ 0, longitude = 0): Valid location, returns `true` ✓

### Edge Case 5: Permission Changed During Session

**Scenario:** User grants/revokes permission while app is running

**Behavior:**
```dart
// Before revocation:
hasLocationPermission(LatLng(55.6761, 12.5683))  // Returns true

// After revocation (FlutterFlow updates currentUserLocationValue):
hasLocationPermission(LatLng(0.0, 0.0))  // Returns false
```

**Handling:**
- Function correctly reflects new state
- **Important:** FlutterFlow must update `currentUserLocationValue` after permission change
- **Best Practice:** Call `checkLocationPermission()` action after permission changes to refresh location

**Implementation Pattern:**
```dart
// After requesting permission:
await requestLocationPermission();
await Future.delayed(Duration(milliseconds: 500)); // Allow FlutterFlow to update
setState(() {
  // UI will rebuild with new hasLocationPermission() result
});
```

### Edge Case 6: High Precision Coordinates

**Scenario:** Location has many decimal places

**Example:**
```dart
hasLocationPermission(LatLng(55.676098132, 12.568337917))  // Returns true
```

**Behavior:**
- High precision doesn't affect check
- Function only cares about near-zero vs non-zero
- Works correctly regardless of precision

### Edge Case 7: Negative Coordinates

**Scenario:** User is in southern/western hemisphere

**Example:**
```dart
hasLocationPermission(LatLng(-33.8688, -151.2093))  // Sydney, Australia
// Returns true
```

**Behavior:**
- `abs()` is used on both coordinates before comparison
- Negative coordinates work correctly
- Function returns `true` for valid southern/western locations

**Math:**
```dart
(-33.8688).abs() = 33.8688 > 0.0001  // true
(-151.2093).abs() = 151.2093 > 0.0001  // true
// Both non-zero → returns true ✓
```

---

## Testing Checklist

### Unit Tests

**File:** `test/custom_functions/has_location_permission_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journey_mate/flutter_flow/lat_lng.dart';
import 'package:journey_mate/flutter_flow/custom_functions.dart';

void main() {
  group('hasLocationPermission', () {
    test('returns false for null input', () {
      expect(hasLocationPermission(null), false);
    });

    test('returns false for (0, 0) coordinates', () {
      expect(hasLocationPermission(LatLng(0.0, 0.0)), false);
    });

    test('returns false for near-zero coordinates', () {
      expect(hasLocationPermission(LatLng(0.00005, 0.00005)), false);
    });

    test('returns true for valid Copenhagen coordinates', () {
      expect(hasLocationPermission(LatLng(55.6761, 12.5683)), true);
    });

    test('returns true for negative coordinates (southern hemisphere)', () {
      expect(hasLocationPermission(LatLng(-33.8688, 151.2093)), true);
    });

    test('returns true for equator (0 latitude, non-zero longitude)', () {
      expect(hasLocationPermission(LatLng(0.0, 10.0)), true);
    });

    test('returns true for prime meridian (non-zero latitude, 0 longitude)', () {
      expect(hasLocationPermission(LatLng(10.0, 0.0)), true);
    });

    test('returns true for high precision coordinates', () {
      expect(hasLocationPermission(LatLng(55.676098132, 12.568337917)), true);
    });

    test('epsilon boundary: returns false for 0.00009 (within epsilon)', () {
      expect(hasLocationPermission(LatLng(0.00009, 0.00009)), false);
    });

    test('epsilon boundary: returns true for 0.00011 (outside epsilon)', () {
      expect(hasLocationPermission(LatLng(0.00011, 0.00011)), true);
    });
  });
}
```

### Integration Tests

**File:** `integration_test/location_permission_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:journey_mate/main.dart' as app;
import 'package:journey_mate/flutter_flow/custom_functions.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Location Permission Flow', () {
    testWidgets('UI updates when permission denied', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate denied permission (0,0 coordinates)
      // This would need to be injected via test harness
      final result = hasLocationPermission(LatLng(0.0, 0.0));
      expect(result, false);

      // Verify UI shows permission prompt
      expect(find.text('Enable Location'), findsOneWidget);
    });

    testWidgets('Distance shown when permission granted', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simulate granted permission (real coordinates)
      final result = hasLocationPermission(LatLng(55.6761, 12.5683));
      expect(result, true);

      // Verify UI shows distance information
      expect(find.textContaining('km'), findsWidgets);
    });
  });
}
```

### Manual Testing Scenarios

**Test Case 1: First App Launch (No Permission)**
1. Install app on fresh device/emulator
2. **Verify:** `hasLocationPermission()` returns `false`
3. **Verify:** Distance information hidden
4. **Verify:** "Enable Location" button visible

**Test Case 2: Grant Permission**
1. Start with permission denied
2. Tap "Enable Location" button
3. Grant permission in system dialog
4. **Verify:** `hasLocationPermission()` returns `true`
5. **Verify:** Distance information appears
6. **Verify:** "Enable Location" button hidden

**Test Case 3: Revoke Permission During Session**
1. Start with permission granted
2. Open system settings
3. Revoke location permission
4. Return to app
5. **Verify:** `hasLocationPermission()` returns `false`
6. **Verify:** UI updates to show permission prompt

**Test Case 4: Disable Location Services**
1. Start with permission granted
2. Disable location services in system settings
3. Return to app
4. **Verify:** `hasLocationPermission()` returns `false`
5. **Verify:** App handles gracefully (no crashes)

**Test Case 5: Airplane Mode**
1. Start with permission granted
2. Enable airplane mode
3. **Verify:** `hasLocationPermission()` may still return `true` (cached location)
4. **Verify:** App handles stale location gracefully

### Performance Testing

**Test:** Function call overhead
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hasLocationPermission performance', () {
    final location = LatLng(55.6761, 12.5683);
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 10000; i++) {
      hasLocationPermission(location);
    }

    stopwatch.stop();
    print('10,000 calls took ${stopwatch.elapsedMicroseconds}μs');

    // Should complete in under 1ms for 10,000 calls
    expect(stopwatch.elapsedMilliseconds, lessThan(1));
  });
}
```

**Expected Result:** Function is extremely lightweight (simple null check + two comparisons)

---

## Migration Notes

### Phase 3 Migration Checklist

**Before migrating any page that uses location:**

- [ ] Read this documentation
- [ ] Review FlutterFlow usage of `hasLocationPermission`
- [ ] Identify all conditional UI based on permission
- [ ] Plan state management for `currentUserLocation`
- [ ] Implement permission request flow

### Import Statement

```dart
// Phase 3 location:
import 'package:journey_mate/shared/custom_functions.dart';

// Usage:
final hasPermission = hasLocationPermission(currentLocation);
```

### State Management Integration

**FlutterFlow Pattern:**
```dart
// Global state:
FFAppState().currentUserLocationValue

// Usage in widget:
hasLocationPermission(currentUserLocationValue)
```

**Phase 3 Provider Pattern:**
```dart
// AppState class:
class AppState extends ChangeNotifier {
  LatLng? _currentUserLocation;

  LatLng? get currentUserLocation => _currentUserLocation;

  bool get hasLocationPermission =>
    hasLocationPermission(_currentUserLocation);

  Future<void> updateLocation() async {
    final permissionStatus = await Geolocator.checkPermission();
    if (permissionStatus == LocationPermission.always ||
        permissionStatus == LocationPermission.whileInUse) {
      _currentUserLocation = await Geolocator.getCurrentPosition();
    } else {
      _currentUserLocation = const LatLng(0.0, 0.0);
    }
    notifyListeners();
  }
}

// Usage in widget:
final appState = Provider.of<AppState>(context);
final hasPermission = appState.hasLocationPermission;
```

### Permission Request Flow

**Complete Migration Pattern:**

```dart
// 1. Check if we have permission (this function)
Widget _buildLocationDependentUI(BuildContext context) {
  final appState = Provider.of<AppState>(context);

  if (!hasLocationPermission(appState.currentUserLocation)) {
    return _buildPermissionPrompt(context);
  }

  return _buildLocationFeatures(context);
}

// 2. Request permission when needed
Future<void> _requestPermission(BuildContext context) async {
  final appState = Provider.of<AppState>(context, listen: false);

  // Use geolocator package for actual permission request
  final permission = await Geolocator.requestPermission();

  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    // Permission granted - update location
    await appState.updateLocation();
  } else {
    // Permission denied - show settings prompt
    _showSettingsPrompt(context);
  }
}

// 3. Handle permission denied
void _showSettingsPrompt(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Location Permission Required'),
      content: Text('Please enable location in Settings to see distances.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            await Geolocator.openAppSettings();
          },
          child: Text('Open Settings'),
        ),
      ],
    ),
  );
}
```

### Common Migration Patterns

**Pattern 1: Conditional Distance Display**

```dart
// FlutterFlow:
Text(
  hasLocationPermission(currentUserLocationValue)
    ? '${returnDistance(...)} km'
    : '',
)

// Phase 3 Migration:
Widget _buildDistanceText(BuildContext context, Business business) {
  final appState = Provider.of<AppState>(context);

  if (!hasLocationPermission(appState.currentUserLocation)) {
    return const SizedBox.shrink();
  }

  final distance = returnDistance(
    appState.currentUserLocation!,
    business.latitude,
    business.longitude,
    appState.currentLanguage,
  );

  return Text('$distance km');
}
```

**Pattern 2: Permission Prompt Button**

```dart
// FlutterFlow:
Visibility(
  visible: !hasLocationPermission(currentUserLocationValue),
  child: Button(text: 'Enable Location', onPressed: ...),
)

// Phase 3 Migration:
Widget _buildPermissionPrompt(BuildContext context) {
  final appState = Provider.of<AppState>(context);

  if (hasLocationPermission(appState.currentUserLocation)) {
    return const SizedBox.shrink();
  }

  return ElevatedButton(
    onPressed: () => _requestPermission(context),
    child: const Text('Enable Location'),
  );
}
```

**Pattern 3: Sort Menu with Conditional Options**

```dart
// FlutterFlow:
DropdownMenuItem(
  enabled: hasLocationPermission(currentUserLocationValue),
  child: Text('Near me'),
)

// Phase 3 Migration:
List<Widget> _buildSortOptions(BuildContext context) {
  final appState = Provider.of<AppState>(context);
  final hasPermission = hasLocationPermission(appState.currentUserLocation);

  return [
    _buildSortOption('Best match', 'best_match', enabled: true),
    _buildSortOption('Rating', 'rating', enabled: true),
    _buildSortOption(
      'Near me',
      'distance',
      enabled: hasPermission,
      tooltip: hasPermission ? null : 'Enable location to sort by distance',
    ),
  ];
}
```

### Testing After Migration

**Verification Steps:**

1. **Unit Tests Pass:**
   ```bash
   flutter test test/custom_functions/has_location_permission_test.dart
   ```

2. **Integration Tests Pass:**
   ```bash
   flutter test integration_test/location_permission_flow_test.dart
   ```

3. **Manual Testing:**
   - [ ] First launch shows permission prompt
   - [ ] Granting permission shows distance
   - [ ] Revoking permission hides distance
   - [ ] Disabling location services handled gracefully
   - [ ] "Near me" sort disabled without permission

4. **Visual Regression:**
   - [ ] Compare FlutterFlow screenshots with Flutter implementation
   - [ ] Verify permission prompt placement/styling
   - [ ] Check distance display formatting

### Known Issues and Gotchas

**Issue 1: Stale Location After Permission Revocation**

**Problem:** If permission is revoked while app is in background, `currentUserLocation` might still have old coordinates until app refreshes.

**Solution:**
```dart
// Listen for app lifecycle changes:
class _SearchPageState extends State<SearchPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh location when app returns to foreground
      Provider.of<AppState>(context, listen: false).updateLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
```

**Issue 2: Permission Dialog Timing**

**Problem:** Requesting permission immediately on app launch is bad UX and may be rejected by app stores.

**Solution:**
```dart
// Don't request on first launch:
void _onFirstSearchAttempt() async {
  final prefs = await SharedPreferences.getInstance();
  final hasAskedBefore = prefs.getBool('has_asked_location') ?? false;

  if (!hasAskedBefore) {
    // Show contextual explanation first
    await _showLocationRationale();
    await prefs.setBool('has_asked_location', true);
  }

  await _requestPermission();
}
```

**Issue 3: iOS Background Location**

**Problem:** iOS requires separate "Always" permission for background location, but this function doesn't distinguish.

**Solution:**
```dart
// For location-based features, "When In Use" is sufficient:
// hasLocationPermission() will return true for either permission level
// If you need background location specifically, check permission status directly:

final permission = await Geolocator.checkPermission();
final hasBackgroundPermission = permission == LocationPermission.always;
```

### Performance Considerations

**Function is extremely lightweight:**
- **Time complexity:** O(1)
- **Space complexity:** O(1)
- **No async operations**
- **No network calls**
- **No state mutations**

**Safe to call frequently:**
```dart
// OK to call on every build:
@override
Widget build(BuildContext context) {
  final hasPermission = hasLocationPermission(
    Provider.of<AppState>(context).currentUserLocation,
  );
  // ...
}
```

**No need for memoization/caching** — function is already optimal.

---

## Related Documentation

**Other location-related functions:**
- `returnDistance` — Calculate distance between two points (uses this function)
- `latLongcombine` — Create LatLng from separate lat/lng values

**Custom actions (to be documented separately):**
- `checkLocationPermission` — System permission status check
- `requestLocationPermission` — Request permission from user

**Usage in pages:**
- Search Results Page — Distance display
- Map Page — Center on user location
- Business Profile Page — "Get Directions" button

---

**END OF DOCUMENTATION**
