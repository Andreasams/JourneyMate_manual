# generateAndStoreFilterSessionId Action

**Type:** Custom Action (Async)
**File:** `generate_and_store_filter_session_id.dart` (35 lines)
**Category:** Search & Filters
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐ (High - Session initialization)

---

## Purpose

Generates a new unique filter session ID (UUID v4) and stores it in FFAppState. Used when starting a new filter session to ensure proper tracking throughout the filter flow.

**Key Features:**
- Generates cryptographically random UUID v4
- Immediately stores in FFAppState.currentFilterSessionId
- Returns the generated ID for immediate use
- Simple, focused action with single responsibility

---

## Function Signature

```dart
Future<String> generateAndStoreFilterSessionId()
```

### Parameters

**No parameters required**

### Returns

| Type | Description |
|------|-------------|
| `Future<String>` | Newly generated session ID (UUID v4 format) |

---

## Dependencies

### pub.dev Packages
```yaml
uuid: ^4.0.0              # UUID generation
```

### FFAppState Usage

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `currentFilterSessionId` | `String` | New session UUID |

---

## UUID Format

**Example:** `550e8400-e29b-41d4-a716-446655440000`

- **Version:** UUID v4 (random)
- **Length:** 36 characters (32 hex + 4 hyphens)
- **Uniqueness:** 2^122 possible values (collision probability negligible)

---

## Usage Examples

### Example 1: App Initialization
```dart
// In app startup or welcome page
@override
void initState() {
  super.initState();
  _initializeFilterSession();
}

Future<void> _initializeFilterSession() async {
  final sessionId = await actions.generateAndStoreFilterSessionId();
  debugPrint('Session initialized: $sessionId');
}
```

### Example 2: Session Reset
```dart
// When user clears all filters
Future<void> _resetFilterSession() async {
  // Generate new session
  final newSessionId = await actions.generateAndStoreFilterSessionId();

  // Track session start
  await actions.trackAnalyticsEvent('filter_session_started', {
    'filterSessionId': newSessionId,
  });
}
```

### Example 3: Called from checkAndResetFilterSession
```dart
// Inside checkAndResetFilterSession action
if (shouldResetSession) {
  final oldSessionId = FFAppState().currentFilterSessionId;

  // Generate new session
  await generateAndStoreFilterSessionId();

  // Track transition
  await trackAnalyticsEvent('filter_session_started', {
    'filterSessionId': FFAppState().currentFilterSessionId,
    'previousSessionId': oldSessionId,
  });
}
```

---

## Debug Output

```
✅ Generated new filter session ID: 550e8400-e29b-41d4-a716-446655440000
```

---

## When to Call

### ✅ DO Call When:
- App initializes (welcome page or main page `initState`)
- User clears all filters (complete reset)
- Starting new filter session after previous ended
- App detects corrupted/invalid session ID

### ❌ DO NOT Call When:
- User modifies existing filters (keep same session)
- User changes search text (keep same session)
- Page navigation (keep same session)
- App resumes from background (keep same session)

**Rule:** One session = one continuous search/filter interaction. Don't reset unless user explicitly starts over.

---

## Testing Checklist

- [ ] Call action → returns valid UUID v4 string
- [ ] Verify UUID format matches: `xxxxxxxx-xxxx-4xxx-xxxx-xxxxxxxxxxxx`
- [ ] Check FFAppState.currentFilterSessionId is updated
- [ ] Call twice → generates different IDs
- [ ] Verify no collisions in 1000 calls (probabilistic test)
- [ ] Check session ID persists across page navigation
- [ ] Verify session ID used in analytics events

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().currentFilterSessionId = newSessionId;
   });

   // After:
   ref.read(filterSessionProvider.notifier).setSessionId(newSessionId);
   ```

2. **Keep UUID generation** - Standard, no changes needed
3. **Consider adding session start time:**
   ```dart
   Future<String> generateAndStoreFilterSessionId() async {
     final newSessionId = const Uuid().v4();
     final startTime = DateTime.now();

     ref.read(filterSessionProvider.notifier).startNewSession(
       sessionId: newSessionId,
       startTime: startTime,
     );

     return newSessionId;
   }
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `checkAndResetFilterSession` | Session lifecycle management | Calls this on reset |
| `trackAnalyticsEvent` | Analytics tracking | Uses generated session ID |

---

## Used By Actions

1. **checkAndResetFilterSession** - Primary caller on session reset
2. **App initialization** - Called once on app start

---

## Known Issues

**None** - Simple, focused action with no known issues.

---

## Security Notes

✅ **UUID v4 is cryptographically random:**
- Safe to use in URLs or analytics
- Not sequential or predictable
- No PII leakage

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Riverpod migration
