# trackAnalyticsEvent Action

**Type:** Custom Action (Async)
**File:** `track_analytics_event.dart` (149 lines)
**Category:** Analytics & Tracking
**Status:** ✅ Production Ready

---

## Purpose

Tracks analytics events to the BuildShip endpoint. Central analytics action used across all pages to log user interactions, page views, session metrics, and business data.

**Key Features:**
- Maintains backward compatibility with legacy tracking
- Gets sessionId from FFAppState (set by engagement tracker)
- Handles missing session gracefully
- Safely serializes complex eventData to avoid IdentityMap issues

---

## Function Signature

```dart
Future<bool> trackAnalyticsEvent(
  String eventType,
  dynamic eventData,
)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `eventType` | `String` | **Yes** | Event type identifier (e.g., 'business_clicked', 'filter_applied') |
| `eventData` | `dynamic` | No | Event metadata as Map<String, String?> or JSON |

### Returns

| Type | Description |
|------|-------------|
| `Future<bool>` | `true` if event tracked successfully, `false` on error |

---

## Dependencies

### pub.dev Packages
```yaml
http: ^1.2.1              # HTTP requests to BuildShip
shared_preferences: ^2.5.3 # Device ID and session storage
```

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### No FFAppState Dependencies
This action reads from SharedPreferences directly, **not** from FFAppState. This ensures analytics work even if state is corrupted.

---

## SharedPreferences Keys

### Read Keys
```dart
'analytics_device_id'    // Device identifier (required)
'current_session_id'     // Current session UUID (optional but recommended)
```

**Critical:** `analytics_device_id` must be set before calling this action, or tracking will fail.

---

## BuildShip Endpoint

```
POST https://wvb8ww.buildship.run/analytics
Content-Type: application/json
```

### Payload Structure
```json
{
  "eventType": "business_clicked",
  "deviceId": "uuid-device-id",
  "sessionId": "uuid-session-id",
  "userId": "uuid-device-id",
  "eventData": {
    "businessId": "123",
    "clickPosition": "0",
    "filterSessionId": "uuid-filter-session",
    "timeOnListSeconds": "45",
    "totalResults": "12"
  },
  "timestamp": "2026-02-19T14:32:18.000Z"
}
```

---

## Usage Examples

### Example 1: Page View Event
```dart
await actions.trackAnalyticsEvent(
  'page_viewed',
  <String, String>{
    'pageName': 'search_results',
    'durationSeconds': functions
        .getSessionDurationSeconds(_model.pageStartTime!)
        .toString(),
  },
);
```

### Example 2: Business Clicked
```dart
await actions.trackAnalyticsEvent(
  'business_clicked',
  <String, String>{
    'businessId': businessId.toString(),
    'clickPosition': position.toString(),
    'filterSessionId': FFAppState().currentFilterSessionId,
    'timeOnListSeconds': functions
        .getSessionDurationSeconds(FFAppState().sessionStartTime!)
        .toString(),
    'totalResults': FFAppState().searchResultsCount.toString(),
  },
);
```

### Example 3: Filter Applied
```dart
await actions.trackAnalyticsEvent(
  'filter_applied',
  <String, String>{
    'filterType': 'dietary',
    'filterValue': 'vegetarian',
    'filterSessionId': FFAppState().currentFilterSessionId,
  },
);
```

### Example 4: Menu Session End
```dart
await actions.trackAnalyticsEvent(
  'menu_session_ended',
  <String, String>{
    'businessId': widget.businessId.toString(),
    'sessionDuration': functions
        .getSessionDurationSeconds(_model.menuSessionStartTime!)
        .toString(),
    'itemsViewed': _model.viewedItemIds.length.toString(),
    'filtersUsed': _model.usedFiltersCount.toString(),
  },
);
```

---

## Common Event Types

| Event Type | Description | Typical eventData Keys |
|------------|-------------|------------------------|
| `page_viewed` | User visited a page | `pageName`, `durationSeconds` |
| `business_clicked` | User tapped business card | `businessId`, `clickPosition`, `filterSessionId` |
| `filter_applied` | User applied filter | `filterType`, `filterValue`, `filterCount` |
| `filter_reset` | User cleared filters | `filterSessionId`, `timeInSession` |
| `menu_item_viewed` | User opened item details | `itemId`, `businessId`, `itemType` |
| `menu_session_ended` | User left menu page | `businessId`, `sessionDuration`, `itemsViewed` |
| `search_performed` | User searched | `query`, `resultsCount`, `location` |
| `location_permission_granted` | User allowed location | `source` (e.g., 'searchPage') |
| `language_changed` | User changed language | `oldLanguage`, `newLanguage` |
| `currency_changed` | User changed currency | `oldCurrency`, `newCurrency` |

---

## Error Handling

### Error 1: Empty eventType
```
❌ eventType cannot be empty
```
**Return:** `false`
**Fix:** Always provide valid event type string

### Error 2: Missing Device ID
```
❌ Missing deviceId - analytics not initialized
```
**Return:** `false`
**Fix:** Initialize analytics on app start (see "Initialization" section below)

### Error 3: Missing Session ID
```
⚠️ No active session - event may not be tracked properly
   Event type: page_viewed
```
**Return:** `true` (continues with `sessionId: 'no-session'`)
**Impact:** Event tracked but not associated with session

### Error 4: HTTP Failure
```
❌ Failed to track event. Status: 500
   Response: {"error": "Internal server error"}
```
**Return:** `false`
**Impact:** Event lost (no retry mechanism)

### Error 5: Serialization Error
```
⚠️ Error sanitizing eventData: Exception...
```
**Payload:** Sends error details instead of event data:
```json
{
  "eventData": {
    "error": "Failed to serialize eventData",
    "type": "_InternalLinkedHashMap<String, Object>"
  }
}
```

---

## Data Sanitization

The action includes sophisticated data sanitization to handle complex FlutterFlow types:

### _sanitizeEventData() Function

**Purpose:** Converts any eventData type to safely serializable Map<String, dynamic>

**Handles:**
1. `Map<String, String?>` - Common FlutterFlow pattern
2. Generic `Map` types - Recursively converts
3. Non-map types - Wraps in `{value: ...}`
4. Serialization errors - Returns error object

### _sanitizeValue() Function

**Purpose:** Recursively sanitizes individual values for JSON serialization

**Conversions:**
- `String`, `num`, `bool` → unchanged
- `DateTime` → `toUtc().toIso8601String()`
- `List` → recursively sanitize elements
- `Map` → recursively sanitize entries
- Other → `toString()` fallback

**Example:**
```dart
// Input:
{
  'timestamp': DateTime(2026, 2, 19, 14, 30),
  'filters': [1, 2, 3],
  'metadata': {'source': 'search', 'version': 2}
}

// Output:
{
  'timestamp': '2026-02-19T14:30:00.000Z',
  'filters': [1, 2, 3],
  'metadata': {'source': 'search', 'version': '2'}
}
```

---

## Initialization Required

Before calling `trackAnalyticsEvent()` anywhere in the app, the device ID must be initialized:

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// On app start (main.dart or welcome page):
Future<void> initializeAnalytics() async {
  final prefs = await SharedPreferences.getInstance();

  // Check if device ID exists
  String? deviceId = prefs.getString('analytics_device_id');

  if (deviceId == null) {
    // Generate new device ID
    deviceId = const Uuid().v4();
    await prefs.setString('analytics_device_id', deviceId);
    debugPrint('✅ Analytics initialized with deviceId: $deviceId');
  }
}
```

**Call this in:** Welcome page `initState` or `main()` before running app.

---

## Session Management

Sessions are managed by separate engagement tracking actions:

### Session Start
```dart
// Usually called in app initialization
final sessionId = const Uuid().v4();
final prefs = await SharedPreferences.getInstance();
await prefs.setString('current_session_id', sessionId);
```

### Session End
```dart
// Usually called in dispose or background
final prefs = await SharedPreferences.getInstance();
await prefs.remove('current_session_id');
```

**Note:** If no session is active, events are still tracked with `sessionId: 'no-session'`.

---

## Performance Considerations

### Non-Blocking Pattern

Most analytics calls should **not block user interactions**. Use `unawaited()`:

```dart
import 'dart:async'; // For unawaited

// DON'T block navigation:
await actions.trackAnalyticsEvent('button_clicked', {...});
context.pushNamed('NextPage');

// DO allow navigation immediately:
unawaited(actions.trackAnalyticsEvent('button_clicked', {...}));
context.pushNamed('NextPage');
```

### When to Await

**Await** when:
- Tracking page disposal (dispose lifecycle)
- Tracking session end events
- Debugging analytics issues

**Don't await** when:
- Tracking button clicks before navigation
- Tracking interactions mid-flow
- Tracking background events

---

## Debug Output

The action provides extensive debug logging:

### Success
```
✅ Event tracked: business_clicked
```

### Missing Session
```
⚠️ No active session - event may not be tracked properly
   Event type: business_clicked
```

### HTTP Failure
```
❌ Failed to track event. Status: 500
   Response: {"error": "Internal server error"}
```

### Exception
```
❌ Error tracking event: SocketException: Failed host lookup
   Stack trace: ...
```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `markUserEngaged` | Marks user as engaged in session | Calls `trackAnalyticsEvent('user_engaged')` |
| `startMenuSession` | Begins menu browsing session | Initializes session ID |
| `endMenuSession` | Ends menu browsing session | Calls `trackAnalyticsEvent('menu_session_ended')` |
| `trackFilterReset` | Tracks filter clearing | Calls `trackAnalyticsEvent('filter_reset')` |

---

## Used By Pages

This action is used by **ALL pages** in the app:

1. **Search Results** - page views, business clicks, filter actions
2. **Business Profile** - page views, session duration, feature interactions
3. **Menu Full Page** - menu sessions, item views, filter usage
4. **Gallery** - page views, image interactions
5. **Contact Details** - copy actions, call/email taps
6. **Settings** - preference changes, permission actions
7. **Welcome/Onboarding** - setup completion, language selection

---

## Testing Checklist

When implementing in Flutter:

- [ ] Initialize device ID before first tracking call
- [ ] Track page_viewed event with valid pageName
- [ ] Track business_clicked with all required fields
- [ ] Verify events appear in BuildShip logs
- [ ] Test with missing sessionId - verify 'no-session' sent
- [ ] Test with complex eventData - verify sanitization works
- [ ] Test with missing device ID - verify returns false
- [ ] Test HTTP failure - verify returns false and logs error
- [ ] Test eventType validation - empty string returns false
- [ ] Verify timestamp format is ISO 8601 UTC
- [ ] Test non-blocking pattern with unawaited()
- [ ] Verify multiple rapid events don't lose data

---

## Migration Notes

### Phase 3 Changes

1. **Keep BuildShip endpoint** - no changes needed
2. **Keep SharedPreferences** - device ID and session storage unchanged
3. **Replace FFAppState references** in calling code:
   ```dart
   // Before:
   'filterSessionId': FFAppState().currentFilterSessionId,

   // After (Riverpod example):
   'filterSessionId': ref.read(filterSessionProvider).sessionId,
   ```

4. **Maintain event type strings** - keep exact same event names for consistency

### Error Handling Enhancement

Consider adding:
- Retry logic for HTTP failures
- Offline queue for failed events
- Exponential backoff on repeated failures

---

## Known Issues

1. **No retry mechanism** - Failed events are lost
2. **No offline queue** - Events require active internet connection
3. **No rate limiting** - Rapid events could overwhelm endpoint
4. **sessionId not validated** - Accepts any string (including 'no-session')

---

## Security Notes

⚠️ **Important:**
- Device ID is stored **unencrypted** in SharedPreferences
- Event data may contain **PII** (businessId, location, preferences)
- BuildShip endpoint has **no authentication** (URL is public)

**Recommendation for production:**
- Add authentication to BuildShip endpoint
- Encrypt sensitive data in eventData
- Implement server-side PII filtering

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
