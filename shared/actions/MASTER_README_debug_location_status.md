# debugLocationStatus Action

**Type:** Custom Action (Async)
**File:** `debug_location_status.dart` (80 lines)
**Category:** Location & Permissions (Debug Tool)
**Status:** ✅ Production Ready (Debug Only)
**Priority:** ⭐⭐ (Low - Development tool)

---

## Purpose

Diagnostic action that provides comprehensive location permission debugging information. Returns formatted string with permission state analysis comparing iOS system status with FFAppState value.

**Key Features:**
- Checks FFAppState before and after update attempt
- Reads all iOS permission status flags
- Attempts FFAppState update and measures result
- Provides analysis of discrepancies (if any)
- Returns formatted text suitable for display in debug UI

**Use Case:** Troubleshooting permission state synchronization issues during development.

---

## Function Signature

```dart
Future<String> debugLocationStatus()
```

### Parameters

**No parameters required**

### Returns

| Type | Description |
|------|-------------|
| `Future<String>` | Multi-line formatted debug report |

---

## Dependencies

### pub.dev Packages
```yaml
permission_handler: ^11.0.0    # Permission status reading
```

### Internal Dependencies
```dart
// No custom imports - uses FFAppState directly
```

### FFAppState Usage

#### Reads
| State Variable | Type | Purpose |
|---------------|------|---------|
| `locationStatus` | `bool` | Before and after update |

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `locationStatus` | `bool` | Tests update mechanism |

---

## Output Format

```
=== LOCATION DEBUG ===

FFAppState BEFORE: false

iOS Permission Status:
  isGranted: true
  isDenied: false
  isPermanentlyDenied: false
  isRestricted: false
  isLimited: false

Attempting update to: true
Update call completed

FFAppState AFTER: true

--- ANALYSIS ---
SUCCESS: Value changed
from false to true
```

---

## Usage Examples

### Example 1: Debug Button in Settings
```dart
// Add debug button (development builds only)
if (kDebugMode) {
  ElevatedButton(
    onPressed: () async {
      final report = await actions.debugLocationStatus();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Location Debug'),
          content: SingleChildScrollView(
            child: Text(report, style: TextStyle(fontFamily: 'monospace')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        ),
      );
    },
    child: Text('Debug Location'),
  ),
}
```

### Example 2: Automated Test Diagnostics
```dart
// In integration test when permission check fails
test('location permission should be granted', () async {
  final granted = await actions.requestLocationPermissionAndTrack('test');

  if (!granted) {
    // Get diagnostic info
    final debug = await actions.debugLocationStatus();
    print(debug); // Shows in test output
    fail('Permission not granted. Debug info:\n$debug');
  }

  expect(granted, true);
});
```

### Example 3: Console Logging on Errors
```dart
// When permission behavior is unexpected
Future<void> _checkLocationWithDebug() async {
  final granted = await actions.checkLocationPermissionAndTrack('feature');

  if (!granted && kDebugMode) {
    final debug = await actions.debugLocationStatus();
    debugPrint(debug);
  }

  return granted;
}
```

---

## Analysis Outputs

### Case 1: Both Correct (iOS Granted, FFAppState True)
```
--- ANALYSIS ---
OK: Both show granted
```

### Case 2: Both Correct (iOS Denied, FFAppState False)
```
--- ANALYSIS ---
OK: Both show denied
```

### Case 3: iOS Granted but FFAppState False (Sync Issue)
```
--- ANALYSIS ---
PROBLEM: iOS granted but
FFAppState is false
```
**Meaning:** System says granted but app state is wrong
**Action:** FFAppState not being updated properly

### Case 4: iOS Denied but FFAppState True (Sync Issue)
```
--- ANALYSIS ---
PROBLEM: iOS denied but
FFAppState is true
```
**Meaning:** System says denied but app state is wrong
**Action:** FFAppState not being cleared properly

### Case 5: Value Changed During Debug
```
--- ANALYSIS ---
SUCCESS: Value changed
from false to true
```
**Meaning:** Update worked and synchronized state
**Action:** State is now correct

---

## Diagnostic Steps

The action performs these checks in sequence:

```
1. Read FFAppState BEFORE
   ├─ Baseline value for comparison

2. Read iOS Permission Status
   ├─ isGranted (true/false)
   ├─ isDenied (true/false)
   ├─ isPermanentlyDenied (true/false)
   ├─ isRestricted (true/false)
   └─ isLimited (true/false - iOS 14+ approximate)

3. Attempt FFAppState Update
   ├─ Calculate isGranted from iOS status
   ├─ Call FFAppState().update()
   └─ Wait 100ms for update to propagate

4. Read FFAppState AFTER
   └─ Compare with BEFORE value

5. Analyze Results
   ├─ Compare iOS vs FFAppState
   ├─ Check if update worked
   └─ Identify discrepancies
```

---

## Common Issues Detected

### Issue 1: FFAppState Not Updating
**Symptoms:**
```
Attempting update to: true
FFAppState AFTER: false
PROBLEM: iOS granted but FFAppState is false
```
**Causes:**
- FFAppState locked or corrupted
- Multiple concurrent updates
- Update timing issue

**Fix:** Restart app, check for conflicting updates

### Issue 2: Permission Changed Outside App
**Symptoms:**
```
FFAppState BEFORE: true
iOS isGranted: false
PROBLEM: iOS denied but FFAppState is true
```
**Causes:**
- User disabled in Settings while app backgrounded
- App didn't detect resume event

**Fix:** Implement app lifecycle observer

### Issue 3: Limited Permission (iOS)
**Symptoms:**
```
iOS Permission Status:
  isGranted: false
  isLimited: true
```
**Causes:**
- User selected "Approximate Location" in iOS 14+

**Fix:** Decide if approximate location is acceptable

---

## Error Handling

### Exception During Debug
```
=== LOCATION DEBUG ===

[... partial output ...]

ERROR: PlatformException: Permission check failed
```
**Return:** Partial debug report with error appended
**Impact:** Still provides useful debugging context

---

## Testing Checklist

- [ ] Run debug action with permission granted
- [ ] Run debug action with permission denied
- [ ] Run debug action with permission permanently denied
- [ ] Run debug action on iOS with "Limited" permission
- [ ] Verify BEFORE and AFTER values shown
- [ ] Verify analysis correctly identifies sync issues
- [ ] Test with FFAppState already correct
- [ ] Test with FFAppState incorrect (manually set wrong value)
- [ ] Verify error handling shows partial output
- [ ] Check output formatting in AlertDialog

---

## Migration Notes

### Phase 3 Changes

1. **Remove from production builds:**
   ```dart
   // Only include in debug/development
   if (kDebugMode) {
     // Debug UI
   }
   ```

2. **Replace FFAppState with Riverpod (if kept):**
   ```dart
   // Before:
   final beforeValue = FFAppState().locationStatus;

   // After:
   final beforeValue = ref.read(locationProvider).permissionGranted;
   ```

3. **Consider removing entirely** - May not be needed in production Flutter app

4. **Alternative: Add to Flutter DevTools extension** instead of in-app UI

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `checkLocationPermissionAndTrack` | Production permission check | What this debugs |
| `checkLocationByFetching` | Alternative debug approach | Complementary tool |

---

## Used By

**Development/Testing Only** - Not used in production code paths

---

## Known Issues

1. **No analytics tracking** - Debug actions should not track analytics
2. **Hard-coded 100ms delay** - Arbitrary timing assumption
3. **Modifies FFAppState** - Side effect even in debug action
4. **Output format not localized** - English only

---

## Performance Impact

✅ **Minimal:**
- Single permission check (fast)
- Small string buffer allocation
- 100ms intentional delay
- Should NOT be called frequently

⚠️ **Warning:** Do not call in loops or timers - debug tool only!

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Remove from production or move to DevTools
