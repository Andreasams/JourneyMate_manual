# checkLocationPermission Action

**Type:** Custom Action (Async)
**File:** `check_location_permission.dart` (103 lines)
**Category:** Location & Permissions
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Used on app resume and page loads)

---

## Purpose

Passively checks location permission status using Geolocator and updates FFAppState.locationStatus. This is the WORKING version that successfully detects iOS permission status without showing system dialogs.

**Key Features:**
- Passive check - does NOT trigger system permission dialog
- Detects iOS permission changes made in Settings
- Tracks analytics when permission status changes
- Validates location services are enabled
- Updates FFAppState.locationStatus automatically

---

## Function Signature

```dart
Future<bool> checkLocationPermission(String source)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source` | `String` | **Yes** | Context where check occurred (e.g., 'app_resume', 'page_load') |

### Returns

| Type | Description |
|------|-------------|
| `Future<bool>` | `true` if permission granted, `false` otherwise |

---

## Dependencies

### pub.dev Packages
```yaml
geolocator: ^10.1.0       # Location permission checking
```

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';      // trackAnalyticsEvent
import '/flutter_flow/custom_functions.dart';
```

---

## FFAppState Usage

### Read Properties
```dart
FFAppState().locationStatus  // Previous permission state (for change detection)
```

### Write Properties
```dart
FFAppState().locationStatus  // Updated to current permission state
```

---

## Usage Examples

### Example 1: App Resume Check
```dart
// In app lifecycle handler
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    await actions.checkLocationPermission('app_resume');
  }
}
```

### Example 2: Page Load Check
```dart
// In page initState
@override
void initState() {
  super.initState();

  SchedulerBinding.instance.addPostFrameCallback((_) async {
    await actions.checkLocationPermission('search_page_load');
  });
}
```

### Example 3: Feature Gate Check
```dart
// Before showing location feature
final hasPermission = await actions.checkLocationPermission('map_feature');
if (hasPermission) {
  // Show map
} else {
  // Show permission prompt
}
```

---

## Error Handling

### Error 1: Location Services Disabled
```
❌ Location services are disabled
```
**Result:** Sets `locationStatus = false`, returns `false`
**Fix:** User must enable location services in device settings

### Error 2: Permission Denied
```
❌ Location permission: Denied
```
**Result:** Sets `locationStatus = false`, returns `false`
**Fix:** Call `requestLocationPermission()` to prompt user

### Error 3: Permission Denied Forever
```
🚫 Location permission: Denied Forever
```
**Result:** Sets `locationStatus = false`, returns `false`
**Fix:** Call `openLocationSettings()` - user must enable in Settings

### Error 4: Exception During Check
```
❌ Error checking location permission: [error]
Stack trace: [stackTrace]
```
**Result:** Returns existing `FFAppState().locationStatus` (no state change)
**Fix:** Check device/system permissions

---

## Permission Status Values

| Geolocator Status | Human Readable | FFAppState Value | Analytics Value |
|-------------------|----------------|------------------|-----------------|
| `LocationPermission.whileInUse` | While Using App | `true` | `'whileInUse'` |
| `LocationPermission.always` | Always | `true` | `'always'` |
| `LocationPermission.denied` | Denied | `false` | `'denied'` |
| `LocationPermission.deniedForever` | Denied Forever | `false` | `'deniedForever'` |
| Other | Unable to Determine | `false` | `'unableToDetermine'` |

---

## Analytics Events

### Event: `location_permission_changed`

**Triggered When:** Permission status changes from previous value

**Event Data:**
```dart
{
  'previousStatus': false,           // Previous FFAppState value
  'newStatus': true,                 // New FFAppState value
  'permissionResult': 'whileInUse',  // Human-readable status
  'source': 'app_resume',            // Context of check
  'wasPassiveCheck': true,           // Flag (always true for this action)
}
```

**Not Triggered When:** Permission status unchanged (prevents duplicate events)

---

## Common Use Cases

| Use Case | Source Parameter | When to Use |
|----------|------------------|-------------|
| App returns to foreground | `'app_resume'` | Detect changes made in iOS Settings |
| Page initialization | `'[page_name]_load'` | Verify permission before showing location features |
| Feature gate | `'[feature_name]'` | Check permission before accessing location API |
| Periodic check | `'periodic_check'` | Verify permission during long sessions |

---

## Used By Pages

1. **Search Page** - Check on page load to enable/disable location features
2. **Map Page** - Verify permission before loading map
3. **App Main** - Check on app resume to detect Settings changes
4. **Onboarding** - Check current status before requesting permission

---

## Performance Considerations

### Blocking Behavior
- **Async operation** - Uses `await`
- **Duration:** ~50-100ms on iOS, ~20-50ms on Android
- **Blocks UI** if awaited in build/initState

### Recommended Pattern
```dart
// DON'T block page load
await actions.checkLocationPermission('page_load');

// DO check asynchronously
SchedulerBinding.instance.addPostFrameCallback((_) async {
  await actions.checkLocationPermission('page_load');
});
```

### Analytics Tracking
- **Non-blocking:** Analytics failure doesn't affect result
- **Fire-and-forget:** Analytics errors are logged but swallowed

---

## Debug Output

### Success - Permission Granted
```
📍 Checking location permission (source: app_resume)...
🔍 Permission: LocationPermission.whileInUse
✅ Location permission: While Using App
```

### Success - Permission Denied
```
📍 Checking location permission (source: search_page_load)...
🔍 Permission: LocationPermission.denied
❌ Location permission: Denied
```

### Status Changed - Analytics Tracked
```
📍 Checking location permission (source: app_resume)...
🔍 Permission: LocationPermission.whileInUse
✅ Location permission: While Using App
📊 Permission status changed: false → true
✅ Analytics tracked
```

### Location Services Disabled
```
📍 Checking location permission (source: map_feature)...
❌ Location services are disabled
```

### Error During Check
```
📍 Checking location permission (source: page_load)...
❌ Error checking location permission: PlatformException(...)
Stack trace: ...
```

---

## Testing Checklist

When implementing in Flutter:

- [ ] Check returns `true` when permission granted
- [ ] Check returns `false` when permission denied
- [ ] Check returns `false` when location services disabled
- [ ] FFAppState.locationStatus updated correctly
- [ ] Analytics tracked when status changes
- [ ] Analytics NOT tracked when status unchanged
- [ ] Test iOS "While Using App" permission
- [ ] Test iOS "Always" permission
- [ ] Test Android permission states
- [ ] Test changing permission in Settings and resuming app
- [ ] Test denied forever state (iOS)
- [ ] Test with various source parameters
- [ ] Verify no system dialog shown (passive check)

---

## Migration Notes

### Phase 3 Changes

1. **Keep Geolocator package** - Works well for both platforms
2. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().locationStatus = isGranted;
   });

   // After:
   ref.read(locationStateProvider.notifier).updateStatus(isGranted);
   ```

3. **Keep analytics tracking** - Event names and structure unchanged

### Alternative Approach

Consider using `permission_handler` instead of Geolocator for consistency with other permission actions (see `checkLocationPermissionAndTrack.dart`).

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `requestLocationPermission` | Request permission | Call after this returns `false` |
| `checkLocationPermissionAndTrack` | Alternative check using permission_handler | Different package, same purpose |
| `openLocationSettings` | Open device settings | Call for deniedForever state |
| `debugLocationStatus` | Debug permission issues | Troubleshooting tool |

---

## Known Issues

1. **Two implementations exist** - `checkLocationPermission` (Geolocator) and `checkLocationPermissionAndTrack` (permission_handler). Project should standardize on one.

2. **No denied forever handling** - Action doesn't automatically prompt user to open Settings when permission is permanently denied.

3. **iOS-specific comment** - Code mentions "THIS WORKS!" for iOS but should work on Android too.

---

## Security Notes

⚠️ **Important:**
- Permission status is stored in FFAppState (in-memory only)
- No sensitive location data is accessed during check
- Analytics event contains only permission status (boolean)
- Source parameter may contain page names (not sensitive)

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
