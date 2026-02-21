# openLocationSettings Action

**Type:** Custom Action (Async)
**File:** `open_location_settings.dart` (73 lines)
**Category:** Location & Permissions
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Recovery path for denied permissions)

---

## Purpose

Opens device settings so user can manually enable location permission. This is the **recovery action** for when permission is permanently denied and cannot be requested programmatically.

**Key Features:**
- Opens device Settings app directly to app permissions
- Checks current permission status before opening (for analytics)
- Tracks analytics event for monitoring user behavior
- Handles errors gracefully
- No return value - app resumes automatically when user returns

**Critical Use Case:** When `requestLocationPermissionAndTrack` returns `permanentlyDenied`, this is the only way to recover.

---

## Function Signature

```dart
Future<void> openLocationSettings(String source)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `source` | `String` | **Yes** | Context where settings opened (e.g., 'settings_page', 'permission_denied_dialog', 'feature_gate') |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value - action completes when settings opened |

---

## Dependencies

### pub.dev Packages
```yaml
permission_handler: ^11.0.0    # openAppSettings()
```

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';           // trackAnalyticsEvent
import '/flutter_flow/custom_functions.dart';
```

### FFAppState Usage

**No direct FFAppState access** - reads permission status via `permission_handler` only.

**Note:** Permission changes made in Settings will be detected on app resume via `checkLocationPermissionAndTrack('app_resume')`.

---

## Usage Examples

### Example 1: Permission Permanently Denied Dialog
```dart
// Show dialog when permission permanently denied
Future<void> _showPermanentlyDeniedDialog() async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Location Permission Required'),
      content: Text(
        'Location access was previously denied. '
        'To enable it, please go to Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Open Settings'),
        ),
      ],
    ),
  );

  if (result == true) {
    await actions.openLocationSettings('permission_denied_dialog');
  }
}
```

### Example 2: Settings Page Toggle
```dart
// User toggles location in settings, but permission is denied
Future<void> _onLocationToggleChanged(bool value) async {
  if (!value) {
    setState(() => _locationEnabled = false);
    return;
  }

  // Try to request permission
  bool granted = await actions.requestLocationPermissionAndTrack('settings_page');

  if (!granted) {
    // Check if permanently denied
    final status = await Permission.location.status;

    if (status.isPermanentlyDenied) {
      // Open settings
      await actions.openLocationSettings('settings_page');
    }
  }

  setState(() => _locationEnabled = granted);
}
```

### Example 3: Feature Gate with Recovery
```dart
// User tries to access location feature but permission denied
Future<void> _accessMapFeature() async {
  if (!FFAppState().locationStatus) {
    bool granted = await actions.requestLocationPermissionAndTrack('map_feature');

    if (!granted) {
      // Show bottom sheet with "Open Settings" button
      showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enable Location Access'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  actions.openLocationSettings('feature_gate');
                },
                child: Text('Open Settings'),
              ),
            ],
          ),
        ),
      );
      return;
    }
  }

  // Show map feature
  _loadMap();
}
```

---

## Error Handling

### Error 1: Failed to Open Settings
```
❌ Error opening settings: [error]
```
**Impact:** Settings not opened, user remains in app
**Analytics:** Tracks error event

**Possible Causes:**
- Device policy restrictions
- Malformed app settings URL (rare)
- Permission handler bug

---

## Analytics Events

### Event 1: Settings Opened Successfully

**Event Type:** `location_settings_opened`

**Event Data:**
```dart
{
  'source': String,              // Context where opened
  'currentStatus': String,       // Full PermissionStatus enum value
  'isGranted': bool,             // Current grant state
}
```

**Example:**
```json
{
  "source": "settings_page",
  "currentStatus": "PermissionStatus.permanentlyDenied",
  "isGranted": false
}
```

### Event 2: Error Opening Settings

**Event Type:** `location_settings_error`

**Event Data:**
```dart
{
  'source': String,              // Context where attempted
  'error': String,               // Error message
}
```

**Example:**
```json
{
  "source": "permission_denied_dialog",
  "error": "PlatformException: Cannot open settings"
}
```

---

## Behavior Flow

```
1. Check current permission status (for analytics context)
2. Track 'location_settings_opened' analytics event
3. Call openAppSettings() - opens device Settings app
4. App goes to background
5. User enables/disables location in Settings
6. User returns to app (app resumes)
7. App lifecycle observer detects resume
8. Calls checkLocationPermissionAndTrack('app_resume')
9. Detects permission change and updates FFAppState
10. UI reacts to FFAppState change
```

---

## Debug Output

### Success
```
⚙️ Opening device settings for location (source: settings_page)
✅ Device settings opened
   User can enable location manually
   Permission will be detected on app resume
```

### Error
```
⚙️ Opening device settings for location (source: feature_gate)
❌ Error opening settings: PlatformException(...)
⚠️ Failed to track error: [analytics error]
```

---

## Platform Behavior

### iOS
- Opens: Settings → [App Name] → Location
- User can select: Never, Ask Next Time, While Using, Always
- On return to app: `checkLocationPermissionAndTrack` detects change

### Android
- Opens: Settings → Apps → [App Name] → Permissions → Location
- User can toggle: Allow / Don't Allow
- On return to app: `checkLocationPermissionAndTrack` detects change

---

## App Resume Detection

**CRITICAL:** After user returns from Settings, the app must detect permission changes:

```dart
// In main app widget or root page:
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Detect permission changes made in Settings
      unawaited(actions.checkLocationPermissionAndTrack('app_resume'));
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(...);
}
```

---

## Testing Checklist

- [ ] Open settings from permission denied dialog
- [ ] Open settings from settings page toggle
- [ ] Open settings from feature gate
- [ ] Verify iOS opens to correct settings screen
- [ ] Verify Android opens to correct settings screen
- [ ] Enable location in Settings, return to app → detected
- [ ] Disable location in Settings, return to app → detected
- [ ] Verify analytics event fires with correct source
- [ ] Test error handling (simulate platform error)
- [ ] Verify app lifecycle observer detects resume
- [ ] Check FFAppState updates after resume

---

## Migration Notes

### Phase 3 Changes

1. **Keep openAppSettings() call** - System API, no changes needed
2. **Ensure app-wide lifecycle observer is configured:**
   ```dart
   // In main.dart or root widget
   void didChangeAppLifecycleState(AppLifecycleState state) {
     if (state == AppLifecycleState.resumed) {
       ref.read(locationProvider.notifier).checkPermissionStatus();
     }
   }
   ```

3. **Keep analytics tracking** - Monitors user recovery flow
4. **Consider adding UI feedback** when returning from Settings:
   ```dart
   if (state == AppLifecycleState.resumed) {
     final wasInSettings = _userOpenedSettings;
     if (wasInSettings) {
       _showPermissionChangeToast();
     }
   }
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `requestLocationPermissionAndTrack` | Request permission | Calls this when permanentlyDenied |
| `checkLocationPermissionAndTrack` | Detect changes on resume | Called after returning from Settings |
| `debugLocationStatus` | Debug permission state | Use to verify Settings changes |

---

## Used By Pages

1. **Settings** - Location toggle when denied
2. **Search Results** - Feature gate recovery
3. **Business Profile** - Map feature recovery
4. **Permission Denied Dialogs** - Primary use case

---

## Known Issues

1. **No return value for success/failure** - Can't detect if user actually changed permission
2. **Timing dependency on app resume** - Must have lifecycle observer configured
3. **No timeout handling** - If user stays in Settings for hours, no special handling

---

## UX Best Practices

✅ **Do:**
- Show clear explanation before opening Settings
- Provide "Cancel" option in dialogs
- Detect changes on app resume and show confirmation
- Track analytics to monitor recovery success rate

❌ **Don't:**
- Open Settings without user consent
- Open Settings repeatedly (once per session max)
- Assume user enabled permission (always check on resume)
- Show multiple dialogs in sequence

---

## Security Notes

✅ **Privacy-Friendly:**
- User explicitly chooses to open Settings
- No automatic permission requests
- Respects user's permission decisions

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Ensure lifecycle observer configured in root widget
