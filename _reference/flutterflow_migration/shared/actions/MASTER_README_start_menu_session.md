# startMenuSession Action

**Type:** Custom Action (Async)
**File:** `start_menu_session.dart` (80 lines)
**Category:** Session Management & Analytics
**Status:** ✅ Production Ready

---

## Purpose

Initializes a menu browsing session when a user opens a business's menu page. Generates a unique session ID, sets up comprehensive tracking metrics in FFAppState, and logs the session start event to analytics.

**Key Features:**
- Generates UUID v4 for unique session identification
- Initializes browsing metrics (item clicks, package clicks, categories viewed, scroll depth)
- Initializes filter engagement tracking (interactions, resets, zero/low result counts)
- Stores session data in FFAppState for real-time metric updates
- Tracks session start event via BuildShip analytics
- Returns session ID for immediate use
- Handles errors gracefully with fallback session ID

**Critical for:**
- Understanding menu browsing behavior patterns
- Measuring filter effectiveness and UX quality
- Tracking user engagement with menu content
- Identifying problematic filter combinations (zero results)
- Session-based analytics and funnel analysis

---

## Function Signature

```dart
Future<String> startMenuSession(int businessId)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `businessId` | `int` | **Yes** | ID of the business whose menu is being viewed |

### Returns

| Type | Description |
|------|-------------|
| `Future<String>` | Unique menu session ID (UUID v4 format) or error fallback ID |

**Return Values:**
- **Success:** `"550e8400-e29b-41d4-a716-446655440000"` (example UUID v4)
- **Error:** `"error-1708356738000"` (error prefix + timestamp)

---

## Dependencies

### pub.dev Packages
```yaml
uuid: ^4.5.1              # UUID v4 generation for session IDs
```

### Internal Dependencies
```dart
import '/custom_code/actions/index.dart';          # trackAnalyticsEvent
import '/flutter_flow/custom_functions.dart';      # (no direct usage)
```

### FFAppState Dependencies
```dart
FFAppState().menuSessionData  // Read-write: Comprehensive session tracking
```

---

## FFAppState Structure

### menuSessionData (Map<String, dynamic>)

Complete structure initialized by this action:

```dart
FFAppState().menuSessionData = {
  // ========== SESSION IDENTIFICATION ==========
  'menuSessionId': String,              // UUID v4 format

  // ========== BROWSING METRICS ==========
  'itemClicks': int,                    // Individual menu items clicked
  'packageClicks': int,                 // Package/bundle items clicked
  'categoriesViewed': List<String>,     // Category IDs user scrolled through
  'deepestScrollPercent': int,          // Maximum scroll depth (0-100)

  // ========== FILTER ENGAGEMENT TRACKING ==========
  'filterInteractions': int,            // Total filter toggles (all types)
  'filterResets': int,                  // Times "Clear All" pressed
  'everHadFiltersActive': bool,         // Was any filter ever used?

  // ========== FILTER RESULT QUALITY METRICS ==========
  'zeroResultCount': int,               // Times filters resulted in 0 items
  'lowResultCount': int,                // Times filters resulted in 1-2 items
  'filterResultHistory': List<int>,     // Result count after each filter change
};
```

### Initial Values

All metrics start at zero/empty when session begins:

```dart
{
  'menuSessionId': '550e8400-e29b-41d4-a716-446655440000',
  'itemClicks': 0,
  'packageClicks': 0,
  'categoriesViewed': [],
  'deepestScrollPercent': 0,
  'filterInteractions': 0,
  'filterResets': 0,
  'everHadFiltersActive': false,
  'zeroResultCount': 0,
  'lowResultCount': 0,
  'filterResultHistory': [],
}
```

---

## Analytics Event Tracked

### Event: `menu_session_started`

Logged to BuildShip analytics endpoint when session initializes.

**Payload:**
```json
{
  "eventType": "menu_session_started",
  "deviceId": "device-uuid",
  "sessionId": "current-session-uuid",
  "userId": "device-uuid",
  "eventData": {
    "menu_session_id": "550e8400-e29b-41d4-a716-446655440000",
    "business_id": "123"
  },
  "timestamp": "2026-02-19T14:32:18.000Z"
}
```

**Event Data Keys:**

| Key | Type | Description |
|-----|------|-------------|
| `menu_session_id` | `String` | Unique session UUID |
| `business_id` | `int` | Business ID being viewed |

---

## Usage Examples

### Example 1: Start Menu Session on Page Load

```dart
class FullMenuPageWidget extends StatefulWidget {
  const FullMenuPageWidget({
    Key? key,
    required this.businessId,
  }) : super(key: key);

  final int businessId;

  @override
  State<FullMenuPageWidget> createState() => _FullMenuPageWidgetState();
}

class _FullMenuPageWidgetState extends State<FullMenuPageWidget> {
  late String _menuSessionId;

  @override
  void initState() {
    super.initState();
    _initializeMenuSession();
  }

  Future<void> _initializeMenuSession() async {
    // Start menu session and store ID
    _menuSessionId = await actions.startMenuSession(widget.businessId);

    debugPrint('Menu session started: $_menuSessionId');
  }

  @override
  Widget build(BuildContext context) {
    // ... menu page UI
  }
}
```

### Example 2: Start Session with Error Handling

```dart
Future<void> _startMenuSession() async {
  try {
    final sessionId = await actions.startMenuSession(widget.businessId);

    // Check if session started successfully
    if (sessionId.startsWith('error-')) {
      debugPrint('⚠️ Session started with fallback ID: $sessionId');
      // Continue with degraded analytics - app still functions
    } else {
      debugPrint('✅ Session started successfully: $sessionId');
    }

    setState(() {
      _menuSessionId = sessionId;
    });
  } catch (e) {
    debugPrint('❌ Critical error starting menu session: $e');
    // Fallback: generate local session ID
    _menuSessionId = 'local-${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

### Example 3: Access Session ID Later

```dart
// After session started, retrieve ID from FFAppState
final sessionData = FFAppState().menuSessionData as Map<String, dynamic>;
final menuSessionId = sessionData['menuSessionId'] as String?;

if (menuSessionId != null && menuSessionId.isNotEmpty) {
  // Use session ID for additional tracking
  await actions.trackAnalyticsEvent(
    'menu_item_expanded',
    {
      'menu_session_id': menuSessionId,
      'item_id': itemId.toString(),
      'business_id': widget.businessId.toString(),
    },
  );
}
```

### Example 4: Verify Session Initialized Before Using Metrics

```dart
void _trackItemClick(int itemId) {
  final sessionData = FFAppState().menuSessionData as Map<String, dynamic>?;

  if (sessionData == null || sessionData.isEmpty) {
    debugPrint('⚠️ Menu session not initialized - cannot track click');
    return;
  }

  // Safe to update metrics
  sessionData['itemClicks'] = (sessionData['itemClicks'] as int? ?? 0) + 1;
  FFAppState().update(() {
    FFAppState().menuSessionData = sessionData;
  });
}
```

---

## Metric Update Actions

These actions update the metrics initialized by `startMenuSession`:

### updateMenuSessionFilterMetrics

**Called when:** User toggles any filter (dietary, allergen, preference)

**Updates:**
- `filterInteractions` (+1)
- `everHadFiltersActive` (true)
- `filterResultHistory` (appends current result count)
- `zeroResultCount` (+1 if results = 0)
- `lowResultCount` (+1 if results = 1-2)

```dart
// After filter toggle
await actions.updateMenuSessionFilterMetrics(
  filteredMenuItems.length, // Current visible item count
);
```

### trackFilterReset

**Called when:** User presses "Clear All" or "Ryd alle" button

**Updates:**
- `filterResets` (+1)

```dart
// When clear filters button tapped
await actions.trackFilterReset(widget.businessId);
```

### Manual Metric Updates

**Item Click:**
```dart
final sessionData = FFAppState().menuSessionData as Map<String, dynamic>;
sessionData['itemClicks'] = (sessionData['itemClicks'] as int? ?? 0) + 1;
FFAppState().update(() {
  FFAppState().menuSessionData = sessionData;
});
```

**Package Click:**
```dart
sessionData['packageClicks'] = (sessionData['packageClicks'] as int? ?? 0) + 1;
```

**Category Viewed:**
```dart
final categoriesViewed = List<String>.from(
  sessionData['categoriesViewed'] as List? ?? []
);
if (!categoriesViewed.contains(categoryId)) {
  categoriesViewed.add(categoryId);
  sessionData['categoriesViewed'] = categoriesViewed;
}
```

**Scroll Depth:**
```dart
final currentScrollPercent = (scrollOffset / maxScroll * 100).round();
final deepestScroll = sessionData['deepestScrollPercent'] as int? ?? 0;
if (currentScrollPercent > deepestScroll) {
  sessionData['deepestScrollPercent'] = currentScrollPercent;
}
```

---

## Session Lifecycle

### Complete Flow

```dart
// ========== 1. SESSION START ==========
// Called in initState of menu page
final menuSessionId = await actions.startMenuSession(businessId);
// Result: FFAppState().menuSessionData initialized with zeros

// ========== 2. USER BROWSES MENU ==========
// User scrolls, clicks items, views categories
sessionData['itemClicks'] += 1;
sessionData['deepestScrollPercent'] = max(current, previous);

// ========== 3. USER APPLIES FILTERS ==========
// User toggles dietary restriction
await actions.updateMenuSessionFilterMetrics(filteredItems.length);
// Result: filterInteractions = 1, everHadFiltersActive = true

// User gets zero results
await actions.updateMenuSessionFilterMetrics(0);
// Result: zeroResultCount = 1

// User clears filters
await actions.trackFilterReset(businessId);
// Result: filterResets = 1

// ========== 4. SESSION END ==========
// Called in dispose or when leaving page
await actions.endMenuSession(businessId);
// Result: Comprehensive metrics sent to analytics, FFAppState reset
```

---

## Error Handling

### Error 1: UUID Generation Failure

```
⚠️ Failed to start menu session: Exception...
   Stack trace: ...
```

**Fallback Behavior:**
- Returns `'error-1708356738000'` (error prefix + timestamp)
- Session continues with fallback ID
- Analytics still tracked (with error ID)
- App functionality unaffected

**Causes:**
- UUID package not available (rare)
- Memory allocation failure (rare)
- Dart runtime exception (rare)

**Fix:**
- No user action needed
- Session continues normally
- Check BuildShip for error-prefixed sessions

### Error 2: FFAppState Update Failure

```
⚠️ Failed to start menu session: setState() called during build
```

**Fallback Behavior:**
- Returns error session ID
- FFAppState not initialized
- Subsequent metric updates will fail silently

**Causes:**
- Called during widget build (before initState completed)
- FFAppState not initialized

**Fix:**
- Always call in `initState` after `super.initState()`
- Never call synchronously during build

### Error 3: Analytics Tracking Failure

Session ID still generated and returned even if `trackAnalyticsEvent` fails.

**Impact:**
- Session ID valid and usable
- FFAppState metrics still tracked
- Only the `menu_session_started` event lost

---

## Debug Output

### Success

```
📋 Menu session started: 550e8400-e29b-41d4-a716-446655440000
   Business ID: 123
```

### Error

```
⚠️ Failed to start menu session: Exception: UUID generation failed
   Stack trace: #0 startMenuSession (package:journey_mate/...)
```

### Verify Initialization

```dart
debugPrint('Session data: ${FFAppState().menuSessionData}');
// Output:
// Session data: {
//   menuSessionId: 550e8400-e29b-41d4-a716-446655440000,
//   itemClicks: 0,
//   packageClicks: 0,
//   ...
// }
```

---

## Integration Points

### 1. Menu Page initState

```dart
@override
void initState() {
  super.initState();

  // CRITICAL: Start session before any tracking
  SchedulerBinding.instance.addPostFrameCallback((_) async {
    _menuSessionId = await actions.startMenuSession(widget.businessId);
  });
}
```

### 2. Filter Widget

When user toggles filter:
```dart
onFilterChanged: (filteredItems) async {
  // Update filter metrics after each change
  await actions.updateMenuSessionFilterMetrics(filteredItems.length);
}
```

### 3. Item Click Handler

```dart
onTap: () {
  // Update click metric before navigation
  final sessionData = FFAppState().menuSessionData as Map<String, dynamic>;
  sessionData['itemClicks'] = (sessionData['itemClicks'] as int? ?? 0) + 1;
  FFAppState().update(() => FFAppState().menuSessionData = sessionData);

  // Navigate to item details
  context.pushNamed('ItemDetailsPage', extra: item);
}
```

### 4. Page Disposal

```dart
@override
void dispose() {
  // End session and send analytics
  actions.endMenuSession(widget.businessId);
  super.dispose();
}
```

---

## Testing Checklist

When implementing in Flutter:

- [ ] Session starts successfully in `initState`
- [ ] UUID v4 format validated (`xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx`)
- [ ] FFAppState.menuSessionData initialized with all keys
- [ ] All numeric metrics start at 0
- [ ] All list metrics start as empty arrays
- [ ] `everHadFiltersActive` starts as false
- [ ] `menu_session_started` event tracked to BuildShip
- [ ] Event includes correct `menu_session_id` and `business_id`
- [ ] Session ID retrievable from FFAppState after initialization
- [ ] Error case returns `error-{timestamp}` format
- [ ] Error case still initializes FFAppState (or fails gracefully)
- [ ] Multiple rapid initializations don't corrupt state
- [ ] Session ID persists throughout page lifecycle
- [ ] Related actions can read/update metrics after initialization
- [ ] Debug output shows session ID on success
- [ ] Debug output shows error details on failure

---

## Common Issues & Solutions

### Issue 1: Session Not Initialized Before Metric Update

**Symptom:**
```dart
// Error: type 'Null' is not a subtype of type 'Map<String, dynamic>'
final sessionData = FFAppState().menuSessionData as Map<String, dynamic>;
```

**Cause:** Trying to update metrics before `startMenuSession` completed

**Solution:**
```dart
// Check if initialized before using
final sessionData = FFAppState().menuSessionData as Map<String, dynamic>?;
if (sessionData != null && sessionData['menuSessionId'] != null) {
  // Safe to update metrics
}
```

### Issue 2: Session ID Lost After State Rebuild

**Symptom:** Session ID exists initially but becomes empty after page rebuild

**Cause:** FFAppState not properly persisted across rebuilds

**Solution:**
```dart
// Store session ID in page model as backup
class _FullMenuPageState extends State<FullMenuPageWidget> {
  late String _localSessionId;

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    _localSessionId = await actions.startMenuSession(widget.businessId);
    setState(() {});
  }
}
```

### Issue 3: Multiple Sessions Started for Same Page

**Symptom:** Multiple `menu_session_started` events for single page visit

**Cause:** `startMenuSession` called in `build()` or multiple times

**Solution:**
```dart
// Only call once in initState
bool _sessionStarted = false;

@override
void initState() {
  super.initState();
  if (!_sessionStarted) {
    _sessionStarted = true;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await actions.startMenuSession(widget.businessId);
    });
  }
}
```

### Issue 4: Analytics Event Not Tracked

**Symptom:** Session ID generated but no `menu_session_started` in BuildShip logs

**Cause:** `trackAnalyticsEvent` dependency not working

**Check:**
1. Device ID initialized in SharedPreferences
2. BuildShip endpoint accessible
3. Network connection available
4. No firewall blocking requests

**Verify:**
```dart
final prefs = await SharedPreferences.getInstance();
final deviceId = prefs.getString('analytics_device_id');
debugPrint('Device ID: $deviceId'); // Must not be null
```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `endMenuSession` | Ends menu session | Reads metrics initialized by `startMenuSession` |
| `updateMenuSessionFilterMetrics` | Updates filter metrics | Updates `filterInteractions`, `zeroResultCount`, etc. |
| `trackFilterReset` | Tracks filter clearing | Updates `filterResets` counter |
| `trackAnalyticsEvent` | Sends events to BuildShip | Called internally to log session start |

---

## Used By Pages

| Page | Usage | When Called |
|------|-------|-------------|
| **Full Menu Page** | Primary usage | `initState` when page loads |
| **Business Profile** | Potential future usage | If menu preview added |

**Note:** Currently only used by Full Menu Page. Other menu-viewing contexts may adopt this pattern in future.

---

## Migration Notes

### Phase 3 Changes

1. **Keep UUID generation** - no changes needed
2. **Replace FFAppState with state management:**
   ```dart
   // Before (FlutterFlow):
   FFAppState().update(() {
     FFAppState().menuSessionData = {...};
   });

   // After (Riverpod):
   ref.read(menuSessionProvider.notifier).initializeSession(sessionId);
   ```

3. **Consider persistent session storage:**
   ```dart
   // Store session ID in SharedPreferences as backup
   final prefs = await SharedPreferences.getInstance();
   await prefs.setString('current_menu_session_id', sessionId);
   ```

4. **Add session timeout handling:**
   ```dart
   // Auto-end session after 30 minutes of inactivity
   Timer? _inactivityTimer;

   void _resetInactivityTimer() {
     _inactivityTimer?.cancel();
     _inactivityTimer = Timer(Duration(minutes: 30), () {
       actions.endMenuSession(widget.businessId);
     });
   }
   ```

### State Management Options

**Option 1: Riverpod Provider**
```dart
final menuSessionProvider = StateNotifierProvider<MenuSessionNotifier, MenuSessionState>((ref) {
  return MenuSessionNotifier();
});

class MenuSessionState {
  final String sessionId;
  final int itemClicks;
  final int packageClicks;
  // ... other metrics
}
```

**Option 2: ChangeNotifier**
```dart
class MenuSessionModel extends ChangeNotifier {
  String _sessionId = '';
  int _itemClicks = 0;

  void initializeSession(String id) {
    _sessionId = id;
    notifyListeners();
  }
}
```

---

## Performance Considerations

### Memory Usage

**FFAppState Structure Size:**
- Base map: ~200 bytes
- Session ID string: ~40 bytes
- Metrics (integers): ~64 bytes
- Lists (empty): ~40 bytes
- **Total per session:** ~350 bytes

**With Active Session:**
- Filter result history (100 entries): ~800 bytes
- Categories viewed (20 entries): ~400 bytes
- **Peak usage:** ~1.5 KB per session

**Impact:** Negligible - safe for continuous usage

### Execution Time

**Typical execution:** 5-15ms
- UUID generation: 1-2ms
- FFAppState update: 2-5ms
- Analytics call: 2-8ms (non-blocking)

**Impact:** Imperceptible to user - safe for `initState`

### Network Impact

**Single analytics event:**
- Payload size: ~300-500 bytes
- Frequency: Once per menu page visit
- **Impact:** Negligible bandwidth usage

---

## Security Notes

⚠️ **Important:**

- **Session ID is not authenticated** - anyone with ID could theoretically send fake metrics
- **Business ID exposed** in analytics payload (not sensitive in this context)
- **No PII collected** in session initialization (only business ID)

**Recommendations:**
- BuildShip endpoint should validate session IDs server-side
- Consider adding checksum or signature to prevent metric tampering
- Rate-limit analytics endpoint to prevent abuse

---

## Advanced Usage

### Pattern 1: Pre-loading Session for Instant Navigation

```dart
// In Business Profile page, pre-start menu session
Future<void> _preloadMenuSession() async {
  // Start session before navigation
  final sessionId = await actions.startMenuSession(widget.businessId);

  // Navigate immediately - session already active
  context.pushNamed('FullMenuPage', extra: {
    'businessId': widget.businessId,
    'preloadedSessionId': sessionId,
  });
}
```

### Pattern 2: Session Recovery After App Resume

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Check if session still valid
    final sessionData = FFAppState().menuSessionData as Map<String, dynamic>?;

    if (sessionData == null || sessionData.isEmpty) {
      // Session lost - reinitialize
      debugPrint('⚠️ Session lost - restarting');
      actions.startMenuSession(widget.businessId);
    }
  }
}
```

### Pattern 3: Multi-Session Tracking (Future Enhancement)

```dart
// If supporting multiple menus open simultaneously
class MultiSessionManager {
  final Map<int, String> _businessSessions = {};

  Future<String> startSession(int businessId) async {
    if (_businessSessions.containsKey(businessId)) {
      debugPrint('⚠️ Session already exists for business $businessId');
      return _businessSessions[businessId]!;
    }

    final sessionId = await actions.startMenuSession(businessId);
    _businessSessions[businessId] = sessionId;
    return sessionId;
  }

  Future<void> endSession(int businessId) async {
    final sessionId = _businessSessions.remove(businessId);
    if (sessionId != null) {
      await actions.endMenuSession(businessId);
    }
  }
}
```

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
