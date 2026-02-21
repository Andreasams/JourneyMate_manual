# requestLocationPermissionAndTrack Action

**Type:** Custom Action (Async)
**File:** `request_location_permission_and_track.dart` (134 lines)
**Category:** Location & Permissions
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Critical - Primary permission request)

---

## Purpose

Requests location permission from system, updates FFAppState, and tracks analytics. This is the **primary permission request action** and should be used when user actively requests location access (e.g., button clicks, toggle switches).

**Key Features:**
- **ACTIVE REQUEST** - Shows system permission dialog
- Tracks analytics only when permission status changes (prevents duplicates)
- Updates FFAppState.locationStatus to match result
- Handles all permission states including iOS "Limited" (approximate)
- Provides detailed logging for debugging
- Tracks errors in analytics for monitoring

**Difference from `requestLocationPermission`:** Uses `permission_handler` (consistent with check action) instead of `geolocator`.

---

## Function Signature

```dart
Future<bool> requestLocationPermissionAndTrack(String source)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source` | `String` | **Yes** | Context where request occurred (e.g., 'onboarding', 'settings_page', 'map_feature') |

### Returns

| Type | Description |
|------|-------------|
| `Future<bool>` | `true` if permission granted, `false` otherwise |

---

## Dependencies

### pub.dev Packages
```yaml
permission_handler: ^11.0.0    # Permission requests
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

## Permission Status Handling

This action handles all `PermissionStatus` enum values:

| Permission Status | isGranted | Return | FFAppState | Next Step |
|------------------|-----------|--------|------------|-----------|
| `granted` | `true` | `true` | `true` | Use location features |
| `denied` | `false` | `false` | `false` | Can request again later |
| `permanentlyDenied` | `false` | `false` | `false` | Open Settings via `openLocationSettings()` |
| `restricted` | `false` | `false` | `false` | Parental controls - can't grant |
| `limited` | `false` | `false` | `false` | iOS approximate only |
| `unknown` | `false` | `false` | `false` | Check device configuration |

---

## Usage Examples

### Example 1: Onboarding Flow
```dart
// First-time app setup - request permission
Future<void> _requestLocationInOnboarding() async {
  bool granted = await actions.requestLocationPermissionAndTrack('onboarding');

  if (granted) {
    // Proceed to main app with location
    context.pushNamed('SearchResults');
  } else {
    // Show alternative flow or skip location features
    context.pushNamed('SearchWithoutLocation');
  }
}
```

### Example 2: Settings Toggle
```dart
// User toggles "Enable Location" switch in settings
Future<void> _onLocationToggleChanged(bool value) async {
  if (value) {
    bool granted = await actions.requestLocationPermissionAndTrack('settings_page');

    setState(() {
      _locationEnabled = granted;
    });

    if (!granted) {
      // Show guide to open Settings if permanently denied
      _showPermanentlyDeniedDialog();
    }
  } else {
    // User disabled - just update UI
    setState(() => _locationEnabled = false);
  }
}
```

### Example 3: Feature-Gated Access
```dart
// User clicks "Find Nearby" button requiring location
Future<void> _onFindNearbyPressed() async {
  if (!FFAppState().locationStatus) {
    bool granted = await actions.requestLocationPermissionAndTrack('map_feature');

    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location required for this feature')),
      );
      return;
    }
  }

  // Show nearby restaurants
  _loadNearbyRestaurants();
}
```

---

## Error Handling

### Error 1: Empty Source Parameter
```
⚠️ Warning: source parameter is empty, using "unknown"
```
**Return:** Continues with `source = 'unknown'`
**Impact:** Analytics will show 'unknown' source

### Error 2: User Denies Permission
```
❌ Location permission denied
```
**Return:** `false`
**FFAppState:** `locationStatus = false`
**Next Step:** Can request again later

### Error 3: Permission Permanently Denied
```
🚫 Location permission permanently denied
   User must enable in device settings
```
**Return:** `false`
**FFAppState:** `locationStatus = false`
**Next Step:** Use `openLocationSettings()` to guide user

### Error 4: iOS Limited Permission
```
⚡ Location permission limited (iOS approximate location)
```
**Return:** `false` (treated as not fully granted)
**FFAppState:** `locationStatus = false`
**Impact:** App gets approximate location only

### Error 5: Exception During Request
```
❌ Error requesting location permission: [error]
```
**Return:** `false`
**FFAppState:** `locationStatus = false`
**Analytics:** Tracks error with details

---

## Analytics Event

### Event Type: `location_permission_changed`

**Tracked ONLY when** `previousStatus != newStatus` OR on error

**Event Data (Success):**
```dart
{
  'previousStatus': bool,        // State before request
  'newStatus': bool,             // State after request
  'permissionResult': String,    // 'granted', 'denied', 'permanentlyDenied', 'restricted', 'limited', 'unknown'
  'source': String,              // Context where requested
}
```

**Event Data (Error):**
```dart
{
  'previousStatus': bool,        // State before error
  'newStatus': false,            // Always false on error
  'permissionResult': 'error',   // Indicates exception occurred
  'source': String,              // Context where requested
  'error': String,               // Error message
}
```

**Examples:**

User grants permission:
```json
{
  "previousStatus": false,
  "newStatus": true,
  "permissionResult": "granted",
  "source": "onboarding"
}
```

User denies permanently:
```json
{
  "previousStatus": false,
  "newStatus": false,
  "permissionResult": "permanentlyDenied",
  "source": "settings_page"
}
```

---

## State Flow

```
1. Validate source parameter (default to 'unknown' if empty)
2. Capture previousStatus from FFAppState
3. Request permission (shows system dialog)
4. Evaluate permission result
5. Update FFAppState.locationStatus
6. If status changed:
   ├─ Track analytics event
   └─ Log change to console
7. If status unchanged:
   └─ Skip analytics
8. Return isGranted
```

**On Error:**
```
1. Catch exception
2. Set FFAppState.locationStatus = false
3. Track error in analytics (always, even if status unchanged)
4. Return false
```

---

## Debug Output

### Success - Permission Granted
```
📍 Requesting location permission (source: onboarding)...
✅ Location permission granted
📊 Permission status changed, tracking analytics...
✅ Analytics tracked: granted from onboarding
```

### User Denies
```
📍 Requesting location permission (source: settings_page)...
❌ Location permission denied
📊 Permission status changed, tracking analytics...
✅ Analytics tracked: denied from settings_page
```

### Already Granted (No Change)
```
📍 Requesting location permission (source: map_feature)...
✅ Location permission granted
⏭️  Permission status unchanged (true), skipping analytics
```

### Permanently Denied
```
📍 Requesting location permission (source: onboarding)...
🚫 Location permission permanently denied
   User must enable in device settings
📊 Permission status changed, tracking analytics...
✅ Analytics tracked: permanentlyDenied from onboarding
```

---

## When to Use vs Other Actions

| Scenario | Use This Action | Use checkLocationPermissionAndTrack |
|----------|----------------|-------------------------------------|
| User clicks "Enable Location" button | ✅ YES | ❌ NO |
| Settings toggle changed | ✅ YES | ❌ NO |
| First-time permission request | ✅ YES | ❌ NO |
| Feature gate with user action | ✅ YES | ❌ NO |
| App resumes from background | ❌ NO | ✅ YES |
| Page initialization check | ❌ NO | ✅ YES |
| Passive verification | ❌ NO | ✅ YES |

**Rule:** Use this for **user-initiated requests** (shows dialog), use `checkLocationPermissionAndTrack` for **passive checks** (no dialog).

---

## Testing Checklist

- [ ] Request permission on first app launch
- [ ] Verify system dialog appears
- [ ] Grant permission → returns true, FFAppState = true
- [ ] Deny permission → returns false, FFAppState = false
- [ ] Deny twice → becomes permanentlyDenied
- [ ] Request again with status unchanged → no analytics
- [ ] Request with status changed → analytics fires
- [ ] Test with empty source → uses 'unknown'
- [ ] Test iOS "Limited" → returns false, treated as not granted
- [ ] Test error during request → tracks error analytics
- [ ] Verify error sets FFAppState = false

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   final previousStatus = FFAppState().locationStatus;
   FFAppState().update(() {
     FFAppState().locationStatus = isGranted;
   });

   // After:
   final previousStatus = ref.read(locationProvider).permissionGranted;
   ref.read(locationProvider.notifier).setPermissionStatus(isGranted);
   ```

2. **Keep analytics deduplication** - Well-designed pattern
3. **Keep error tracking** - Good for monitoring permission issues
4. **Consider adding retry logic** for transient errors

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `requestLocationPermission` | Legacy request (geolocator) | Older version, consider replacing |
| `checkLocationPermissionAndTrack` | Passive check | Use for app resume |
| `openLocationSettings` | Opens device settings | Use when permanentlyDenied |
| `debugLocationStatus` | Debug diagnostic | Use for troubleshooting |

---

## Used By Pages

1. **Welcome/Onboarding** - First-time permission request
2. **Settings** - Enable/disable location toggle
3. **Search Results** - Feature gate for nearby search
4. **Business Profile** - Map and directions feature

---

## Known Issues

1. **iOS "Limited" (approximate) treated as not granted** - May want to support approximate location
2. **No retry logic on transient errors** - Single attempt only
3. **Analytics tracking for unchanged status could be optional** - Currently tracks on every call if status changes

---

## Security Notes

✅ **User Control:**
- Only shows dialog when user initiates action
- Respects system permission state
- Tracks permission changes for compliance monitoring

⚠️ **Privacy Considerations:**
- Ensure location usage is explained before requesting
- Add location usage description to Info.plist (iOS)
- Add location permissions to AndroidManifest.xml

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with Riverpod
