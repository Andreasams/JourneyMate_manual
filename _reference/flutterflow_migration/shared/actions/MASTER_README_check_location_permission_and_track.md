# checkLocationPermissionAndTrack Action

**Type:** Custom Action (Async)
**File:** `check_location_permission_and_track.dart` (119 lines)
**Category:** Location & Permissions
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (Critical - App resume detection)

---

## Purpose

Passively checks current location permission status without showing system dialog. This is a **read-only** permission check that detects changes made in device Settings and tracks analytics only when status changes.

**Key Features:**
- **PASSIVE CHECK** - Does NOT request permission or show dialogs
- Detects permission changes made in iOS/Android Settings
- Tracks analytics only when status changes (prevents duplicate events)
- Updates FFAppState.locationStatus to match system state
- Maintains existing state on errors (safe failure mode)
- Handles all permission states including iOS "Limited" (approximate location)

**Critical Use Case:** App resume detection - automatically detects when user enables location in Settings and returns to app.

---

## Function Signature

```dart
Future<bool> checkLocationPermissionAndTrack(String source)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source` | `String` | **Yes** | Context where check occurred (e.g., 'app_resume', 'page_load', 'feature_gate') |

### Returns

| Type | Description |
|------|-------------|
| `Future<bool>` | `true` if permission currently granted, `false` otherwise |

---

## Dependencies

### pub.dev Packages
```yaml
permission_handler: ^11.0.0    # Permission status checking
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
| `locationStatus` | `bool` | Updated to current permission state |

---

## Permission Status Handling

This action handles all `PermissionStatus` enum values:

| Permission Status | isGranted | FFAppState | Description | iOS/Android |
|------------------|-----------|------------|-------------|-------------|
| `granted` | `true` | `true` | Full location access | Both |
| `denied` | `false` | `false` | Permission denied, can request again | Both |
| `permanentlyDenied` | `false` | `false` | User selected "Don't Allow" twice | Both |
| `restricted` | `false` | `false` | Parental controls or device policy | iOS |
| `limited` | `false` | `false` | Approximate location only (iOS 14+) | iOS |
| `unknown` | `false` | `false` | Unable to determine state | Both |

---

## Usage Examples

### Example 1: App Resume Detection (Primary Use Case)
```dart
// In main app widget - detect permission changes when app resumes
class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check if user enabled location in Settings
      unawaited(actions.checkLocationPermissionAndTrack('app_resume'));
    }
  }
}
```

### Example 2: Page Load Verification
```dart
// Verify permission state on page initialization without prompting user
@override
void initState() {
  super.initState();

  // Check current state (no dialog)
  actions.checkLocationPermissionAndTrack('search_page_load').then((granted) {
    if (granted) {
      _loadNearbyRestaurants();
    } else {
      _showLocationPrompt();
    }
  });
}
```

### Example 3: Feature Gate
```dart
// Check before showing location feature (non-intrusive)
Future<void> _showMapFeature() async {
  bool granted = await actions.checkLocationPermissionAndTrack('feature_gate');

  if (!granted) {
    // Show "Enable Location" button instead of automatic request
    _showLocationRequiredMessage();
    return;
  }

  // Show map feature
  _displayMap();
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

### Error 2: Exception During Check
```
❌ Error checking location permission: [error]
   Maintaining existing state: true
```
**Return:** Current FFAppState.locationStatus value
**FFAppState:** Unchanged (safe failure mode)
**Impact:** No state change on error - prevents false negatives

---

## Analytics Event

### Event Type: `location_permission_changed`

**Tracked ONLY when** `previousStatus != newStatus`

**Event Data:**
```dart
{
  'previousStatus': bool,        // State before check
  'newStatus': bool,             // State after check
  'permissionResult': String,    // 'granted', 'denied', 'permanentlyDenied', 'restricted', 'limited', 'unknown'
  'source': String,              // Context where checked
  'wasPassiveCheck': true,       // Flag to distinguish from active requests
}
```

**Example - User enabled in Settings:**
```json
{
  "previousStatus": false,
  "newStatus": true,
  "permissionResult": "granted",
  "source": "app_resume",
  "wasPassiveCheck": true
}
```

**Note:** `wasPassiveCheck: true` distinguishes this from `requestLocationPermissionAndTrack` events.

---

## State Flow

```
1. Capture previousStatus from FFAppState
2. Check current permission status (NO DIALOG)
3. Determine if granted (status.isGranted)
4. Update FFAppState.locationStatus
5. If status changed:
   ├─ Track analytics event
   └─ Log change to console
6. If status unchanged:
   └─ Skip analytics
7. Return isGranted
```

---

## Debug Output

### Permission Granted
```
📍 Checking location permission status (source: app_resume)...
✅ Location permission: granted
⏭️  Permission status unchanged (true), skipping analytics
```

### Permission Changed (Enabled in Settings)
```
📍 Checking location permission status (source: app_resume)...
✅ Location permission: granted
📊 Permission status changed, tracking analytics...
✅ Analytics tracked: granted from app_resume (passive)
```

### Permission Denied
```
📍 Checking location permission status (source: feature_gate)...
❌ Location permission: denied
⏭️  Permission status unchanged (false), skipping analytics
```

### Permission Permanently Denied
```
📍 Checking location permission status (source: page_load)...
🚫 Location permission: permanently denied
```

### iOS Limited (Approximate)
```
📍 Checking location permission status (source: app_resume)...
⚡ Location permission: limited (approximate)
```

---

## When to Use vs Other Actions

| Scenario | Use This Action | Use requestLocationPermissionAndTrack |
|----------|----------------|--------------------------------------|
| App resumes from background | ✅ YES | ❌ NO |
| Check before showing feature | ✅ YES | ❌ NO |
| Page initialization check | ✅ YES | ❌ NO |
| User clicks "Enable Location" | ❌ NO | ✅ YES |
| Settings toggle changed | ❌ NO | ✅ YES |
| First-time permission request | ❌ NO | ✅ YES |

**Rule:** Use this for **passive checks**, use `requestLocationPermissionAndTrack` for **active requests**.

---

## Performance Considerations

### Non-Blocking Pattern
```dart
// DON'T block UI:
await actions.checkLocationPermissionAndTrack('app_resume');

// DO check in background:
unawaited(actions.checkLocationPermissionAndTrack('app_resume'));
```

### Avoid Over-Checking
```dart
// ❌ BAD - checks too frequently
Timer.periodic(Duration(seconds: 1), (_) {
  actions.checkLocationPermissionAndTrack('timer');
});

// ✅ GOOD - checks only on meaningful events
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    unawaited(actions.checkLocationPermissionAndTrack('app_resume'));
  }
}
```

---

## Testing Checklist

- [ ] Check permission when status is already granted
- [ ] Check permission when status is already denied
- [ ] Verify no system dialog appears (passive check)
- [ ] Enable location in iOS Settings, resume app → detects change
- [ ] Disable location in Settings, resume app → detects change
- [ ] Verify analytics fires ONLY when status changes
- [ ] Check multiple times with same status → no duplicate analytics
- [ ] Test with empty source parameter → uses 'unknown'
- [ ] Test with error during check → maintains existing state
- [ ] Verify FFAppState.locationStatus updates correctly
- [ ] Test iOS "Limited" (approximate) permission

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

2. **Keep passive check pattern** - This is well-designed
3. **Keep analytics deduplication** - Only tracks changes
4. **Consider adding to app-wide lifecycle observer**

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `checkLocationPermission` | Basic check (no analytics) | Simpler version |
| `requestLocationPermissionAndTrack` | Active permission request | Use when user initiates |
| `openLocationSettings` | Opens device settings | Use when permanentlyDenied |
| `debugLocationStatus` | Debug diagnostic | Use for troubleshooting |

---

## Used By Pages

1. **Main App** - App resume detection (most important)
2. **Search Results** - Page load verification
3. **Business Profile** - Map feature gate
4. **Settings** - Status display (non-intrusive check)

---

## Known Issues

1. **iOS "Limited" (approximate) treated as denied** - May want to handle separately
2. **No distinction between "denied" and "not yet asked"** - Permission handler limitation
3. **Safe failure mode might hide real errors** - Returns existing state on exception

---

## Security Notes

✅ **Privacy-Friendly:**
- No dialogs or prompts shown to user
- Only checks existing permission state
- Perfect for non-intrusive permission monitoring

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation with Riverpod
