# requestLocationPermission Action

**Type:** Custom Action (Async)
**File:** `request_location_permission.dart` (102 lines)
**Category:** Location & Permissions
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Critical - Core location feature)

---

## Purpose

Requests location permission using Geolocator package and updates FFAppState. This action provides a complete permission request flow with service validation, state updates, and analytics tracking.

**Key Features:**
- Checks if location services are enabled before requesting
- Requests permission using system dialog
- Updates FFAppState.locationStatus based on result
- Tracks analytics only when permission status changes
- Provides detailed debug logging for all permission states
- Handles all permission states: granted, denied, deniedForever, restricted

**Package Used:** `geolocator` (different from other location actions that use `permission_handler`)

---

## Function Signature

```dart
Future<bool> requestLocationPermission(String source)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source` | `String` | **Yes** | Context where request occurred (e.g., 'onboarding', 'settings', 'search_page') |

### Returns

| Type | Description |
|------|-------------|
| `Future<bool>` | `true` if permission granted (whileInUse or always), `false` otherwise |

---

## Dependencies

### pub.dev Packages
```yaml
geolocator: ^11.0.0       # Location services and permissions
```

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';           // trackAnalyticsEvent
import '/flutter_flow/custom_functions.dart';
```

### FFAppState Usage

#### Reads
| State Variable | Type | Purpose |
|---------------|------|---------|
| `locationStatus` | `bool` | Previous permission state (for change detection) |

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `locationStatus` | `bool` | Updated to permission grant state |

---

## Permission States

This action handles all `LocationPermission` enum values:

| Permission State | Return Value | FFAppState.locationStatus | User Action Required |
|-----------------|--------------|---------------------------|----------------------|
| `whileInUse` | `true` | `true` | None - app can use location |
| `always` | `true` | `true` | None - background access granted |
| `denied` | `false` | `false` | Can request again |
| `deniedForever` | `false` | `false` | Must open Settings manually |
| `unableToDetermine` | `false` | `false` | Check device configuration |

---

## Usage Examples

### Example 1: Onboarding Flow
```dart
// In welcome page - request location on first launch
bool granted = await actions.requestLocationPermission('onboarding');

if (granted) {
  // Proceed to location-based search
  context.pushNamed('SearchResults');
} else {
  // Show manual location entry
  context.pushNamed('ManualLocation');
}
```

### Example 2: Settings Page
```dart
// User toggles location switch in settings
bool granted = await actions.requestLocationPermission('settings_page');

setState(() {
  _locationEnabled = granted;
});

if (!granted) {
  // Show message about opening Settings
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Location permission required')),
  );
}
```

### Example 3: Feature Gate
```dart
// Before showing map or location-based feature
if (!FFAppState().locationStatus) {
  bool granted = await actions.requestLocationPermission('map_feature');

  if (!granted) {
    return; // Don't show feature
  }
}

// Show location-based feature
```

---

## Error Handling

### Error 1: Location Services Disabled
```
❌ Location services are disabled
```
**Return:** `false`
**FFAppState:** `locationStatus = false`
**Fix:** User must enable in device Settings → Privacy → Location Services

### Error 2: Permission Denied
```
❌ Permission denied
```
**Return:** `false`
**FFAppState:** `locationStatus = false`
**Impact:** Can request again later

### Error 3: Permission Denied Forever
```
🚫 Permission denied forever - user must enable in Settings
```
**Return:** `false`
**FFAppState:** `locationStatus = false`
**Fix:** Use `openLocationSettings()` to guide user

### Error 4: Exception During Request
```
❌ Error requesting location permission: [error message]
Stack trace: ...
```
**Return:** `false`
**FFAppState:** `locationStatus = false`
**Impact:** Permission state unknown

---

## Analytics Event

### Event Type: `location_permission_changed`

**Tracked ONLY when** `previousStatus != newStatus`

**Event Data:**
```dart
{
  'previousStatus': bool,        // State before request
  'newStatus': bool,             // State after request
  'permissionResult': String,    // 'whileInUse', 'always', 'denied', 'deniedForever', 'unableToDetermine'
  'source': String,              // Context where requested
  'wasRequest': true,            // Flag to distinguish from passive checks
}
```

**Example:**
```json
{
  "previousStatus": false,
  "newStatus": true,
  "permissionResult": "whileInUse",
  "source": "onboarding",
  "wasRequest": true
}
```

---

## State Flow

```
1. Capture previousStatus from FFAppState
2. Check if location services enabled
   ├─ NO → Return false, set FFAppState = false
   └─ YES → Continue
3. Request permission (shows system dialog)
4. Evaluate permission result
5. Update FFAppState.locationStatus
6. If status changed → Track analytics
7. Return isGranted
```

---

## Debug Output

### Success - While In Use
```
📍 Requesting location permission (source: onboarding)...
🔍 Permission result: LocationPermission.whileInUse
✅ Permission granted: While Using App
✅ Analytics tracked
```

### Success - Always
```
📍 Requesting location permission (source: settings)...
🔍 Permission result: LocationPermission.always
✅ Permission granted: Always
✅ Analytics tracked
```

### Denied
```
📍 Requesting location permission (source: search_page)...
🔍 Permission result: LocationPermission.denied
❌ Permission denied
```

### Denied Forever
```
📍 Requesting location permission (source: map)...
🔍 Permission result: LocationPermission.deniedForever
🚫 Permission denied forever - user must enable in Settings
```

---

## Comparison with Similar Actions

| Action | Package | Behavior | Use Case |
|--------|---------|----------|----------|
| `requestLocationPermission` | `geolocator` | Checks services + requests | ⚠️ Legacy - prefer next one |
| `requestLocationPermissionAndTrack` | `permission_handler` | Requests only | ✅ Recommended |
| `checkLocationPermissionAndTrack` | `permission_handler` | Passive check only | App resume checks |

**Note:** This action uses `geolocator` while newer actions use `permission_handler`. Consider migrating to `requestLocationPermissionAndTrack` for consistency.

---

## Testing Checklist

- [ ] Request permission on first app launch
- [ ] Verify system dialog appears with app name
- [ ] Grant "While Using App" → returns true
- [ ] Grant "Always" → returns true
- [ ] Deny permission → returns false
- [ ] Deny permission twice → becomes deniedForever
- [ ] Verify FFAppState.locationStatus updates correctly
- [ ] Check analytics event fires only on status change
- [ ] Request again with same status → no analytics
- [ ] Test with location services OFF → returns false
- [ ] Verify error handling on exceptions

---

## Migration Notes

### Phase 3 Changes

1. **Consider replacing with `requestLocationPermissionAndTrack`:**
   ```dart
   // Current (uses geolocator):
   await actions.requestLocationPermission('onboarding');

   // Future (uses permission_handler - consistent with other actions):
   await actions.requestLocationPermissionAndTrack('onboarding');
   ```

2. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().locationStatus = isGranted;
   });

   // After:
   ref.read(locationProvider.notifier).setPermissionStatus(isGranted);
   ```

3. **Keep analytics tracking pattern** - It's well-designed (tracks only changes)

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `checkLocationPermission` | Checks current status | Called before requesting |
| `checkLocationPermissionAndTrack` | Passive check with analytics | Used on app resume |
| `requestLocationPermissionAndTrack` | Modern request action | Recommended alternative |
| `openLocationSettings` | Opens device settings | Used when deniedForever |

---

## Used By Pages

1. **Welcome/Onboarding** - Initial permission request
2. **Settings** - Enable location toggle
3. **Search Results** - Feature gate for location search

---

## Known Issues

1. **Uses geolocator instead of permission_handler** - Inconsistent with other location actions
2. **No handling for iOS "precise location" toggle** - iOS 14+ feature not addressed
3. **Analytics tracking errors not propagated** - Fails silently if analytics fails

---

## Security Notes

⚠️ **Location Data Handling:**
- Permission status stored unencrypted in FFAppState
- Consider documenting location usage in Privacy Policy
- Ensure location data is not logged or tracked unnecessarily

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Migrate to permission_handler for consistency
