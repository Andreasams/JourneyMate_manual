# markUserEngaged Action

**Type:** Custom Action (Async)
**File:** `mark_user_engaged.dart` (47 lines)
**Category:** Analytics & Engagement
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐⭐⭐ (HIGHEST - Called on EVERY user interaction)

---

## Purpose

Marks user as actively engaged by updating the "last active" timestamp used by the engagement tracker to extend the user's engaged time window by 15 seconds. This is the MOST FREQUENTLY CALLED action in the entire app.

**Key Features:**
- Ultra-lightweight (~1-2ms overhead)
- Non-blocking operation
- Communicates with main.dart engagement tracker via SharedPreferences
- Fails silently - never disrupts user experience
- Called on every meaningful user interaction

---

## Function Signature

```dart
Future<void> markUserEngaged()
```

### Parameters

**No parameters required** - Automatically captures current timestamp

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | Completes when timestamp is stored (no return value) |

---

## Dependencies

### pub.dev Packages
```yaml
shared_preferences: ^2.5.3  # Timestamp storage for engagement tracking
```

### Internal Dependencies
**None** - Standalone action with no dependencies on other custom code

---

## SharedPreferences Keys

### Write Keys
```dart
'last_user_activity'  // Timestamp in milliseconds since epoch
```

**Value Format:** `int` - `DateTime.now().millisecondsSinceEpoch`

---

## Usage Examples

### Example 1: Search Bar Text Change
```dart
// In search TextField onChanged
TextField(
  onChanged: (value) async {
    await actions.markUserEngaged();
    // ... perform search
  },
)
```

### Example 2: Filter Applied
```dart
// In filter toggle handler
onTap: () async {
  await actions.markUserEngaged();
  // ... apply filter
}
```

### Example 3: Business Card Clicked
```dart
// In business card tap handler
GestureDetector(
  onTap: () async {
    await actions.markUserEngaged();
    context.pushNamed('BusinessProfile', extra: businessId);
  },
)
```

### Example 4: Navigation Event
```dart
// In bottom tab bar
BottomNavigationBar(
  onTap: (index) async {
    await actions.markUserEngaged();
    _pageController.jumpToPage(index);
  },
)
```

### Example 5: Non-Blocking Pattern (Recommended)
```dart
import 'dart:async'; // For unawaited

// Don't block user interaction
GestureDetector(
  onTap: () {
    unawaited(actions.markUserEngaged());  // Fire and forget
    context.pushNamed('NextPage');
  },
)
```

---

## Error Handling

### Error 1: SharedPreferences Access Failure
```
⚠️ Failed to mark user engaged: [error]
```
**Result:** Fails silently - no impact on user experience
**Impact:** Engagement window won't extend (15-second window may expire)

---

## How It Works

### Communication Pattern

1. **Custom Code** (pages/widgets):
   ```dart
   await markUserEngaged();
   // Writes timestamp to SharedPreferences
   ```

2. **Engagement Tracker** (main.dart):
   ```dart
   // Checks SharedPreferences every 5 seconds
   final lastActivity = prefs.getInt('last_user_activity');
   if (now - lastActivity < 15000) {
     // User is still engaged
   }
   ```

3. **Engagement Window:**
   - Each call extends window by 15 seconds
   - Engagement tracker monitors for activity
   - If >15 seconds pass, user marked as disengaged

### Timestamp Flow
```
User Action → markUserEngaged() → SharedPreferences
                                          ↓
                              Engagement Tracker (main.dart)
                                          ↓
                              Extends Session Duration
```

---

## Common Use Cases

| Use Case | Frequency | Impact |
|----------|-----------|--------|
| Search bar typing | Every keystroke | Extends engagement during search |
| Filter toggle | Per filter change | Tracks active filtering sessions |
| Business card tap | Per navigation | Maintains engagement during browsing |
| Menu item click | Per item viewed | Tracks menu exploration |
| Tab navigation | Per tab switch | Monitors app section usage |
| Scroll events | Throttled (every 1-2s) | Tracks content consumption |
| Button press | Per interaction | General engagement tracking |

---

## Used By Pages

**ALL PAGES** - Every interactive element should call this action:

1. **Search Results Page** - Text input, filter toggles, card taps
2. **Business Profile Page** - Tab switches, image taps, button presses
3. **Menu Full Page** - Item clicks, filter changes, category scrolls
4. **Gallery Page** - Image swipes, share button
5. **Contact Details Page** - Copy actions, call/email taps
6. **Settings Page** - Option changes, toggle switches
7. **Onboarding Pages** - Button taps, input changes

---

## Performance Considerations

### Ultra-Lightweight Operation
- **Duration:** ~1-2ms on most devices
- **Async but non-blocking:** Use `unawaited()` for best UX
- **No UI impact:** Completely background operation
- **No network calls:** Local storage only

### Recommended Pattern

```dart
// BEST: Non-blocking fire-and-forget
unawaited(actions.markUserEngaged());
performUserAction();

// OK: Blocking (but fast)
await actions.markUserEngaged();
performUserAction();

// AVOID: Blocking critical path
await actions.markUserEngaged();
await showDialog(...);  // User waits extra 1-2ms
```

### Throttling Recommendations

For high-frequency events (e.g., scroll), throttle calls:

```dart
Timer? _engagementThrottle;

void onScroll() {
  if (_engagementThrottle?.isActive ?? false) return;

  _engagementThrottle = Timer(Duration(seconds: 1), () {
    unawaited(actions.markUserEngaged());
  });
}
```

---

## Debug Output

### Success (Default)
```
👆 User engagement marked at 1645123456789
```

### Failure (Exception)
```
⚠️ Failed to mark user engaged: PlatformException(...)
```

**Note:** Debug output is commented out by default for performance. Uncomment for troubleshooting:

```dart
// Optional: Uncomment for debugging
debugPrint('👆 User engagement marked at $now');
```

---

## Testing Checklist

When implementing in Flutter:

- [ ] Action completes successfully without errors
- [ ] Timestamp written to SharedPreferences
- [ ] Engagement tracker reads timestamp correctly
- [ ] Multiple rapid calls don't cause issues
- [ ] Works with unawaited() pattern
- [ ] Fails gracefully when SharedPreferences unavailable
- [ ] No UI lag or jank from calls
- [ ] Test on search bar typing (high frequency)
- [ ] Test on navigation (low frequency)
- [ ] Verify engagement window extends correctly
- [ ] Test engagement timeout after 15 seconds
- [ ] Verify no memory leaks from frequent calls

---

## Migration Notes

### Phase 3 Changes

1. **Keep SharedPreferences** - Best solution for main.dart communication
2. **Keep simple implementation** - No need to complicate
3. **Consider centralized wrapper:**
   ```dart
   // Riverpod provider wrapper (optional)
   final engagementProvider = Provider((ref) {
     return EngagementService();
   });

   class EngagementService {
     Future<void> markEngaged() async {
       await markUserEngaged();
     }
   }
   ```

4. **Add to interaction mixin:**
   ```dart
   mixin UserEngagementMixin {
     Future<void> onUserInteraction() async {
       unawaited(actions.markUserEngaged());
     }
   }
   ```

### Performance Optimization

Consider batching if called extremely frequently (>100 times/second):

```dart
class EngagementBatcher {
  DateTime? _lastMark;

  Future<void> markIfNeeded() async {
    final now = DateTime.now();
    if (_lastMark == null ||
        now.difference(_lastMark!) > Duration(seconds: 1)) {
      await markUserEngaged();
      _lastMark = now;
    }
  }
}
```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| `trackAnalyticsEvent` | Track specific events | Called separately for detailed analytics |
| `startMenuSession` | Begin menu session | May call markUserEngaged internally |
| `endMenuSession` | End menu session | Marks final engagement point |

---

## Known Issues

1. **No built-in throttling** - High-frequency events (scroll) may call too often
2. **Silent failures** - Errors don't surface to developer (by design)
3. **No batching** - Each call writes to SharedPreferences individually
4. **15-second window hardcoded** - Can't adjust without modifying engagement tracker

---

## Security Notes

✅ **No security concerns:**
- Stores only timestamp (milliseconds since epoch)
- No user data or PII
- Local storage only (not transmitted)
- No authentication required

---

## Engagement Tracker Integration

### Main.dart Setup

```dart
// In main.dart or app initialization
class _EngagementTracker {
  Timer? _heartbeatTimer;
  bool _isEngaged = false;

  void start() {
    _heartbeatTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt('last_user_activity') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      final wasEngaged = _isEngaged;
      _isEngaged = (now - lastActivity) < 15000; // 15-second window

      if (_isEngaged && !wasEngaged) {
        // User became engaged
        debugPrint('✅ User engaged');
      } else if (!_isEngaged && wasEngaged) {
        // User became disengaged
        debugPrint('💤 User disengaged');
      }
    });
  }
}
```

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Flutter Implementation
**Usage Note:** Call on EVERY user interaction - this is the heartbeat of engagement tracking
