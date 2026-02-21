# getSessionDurationSeconds Function

**Type:** Custom Function (Pure)
**File:** `custom_functions.dart` (line 2237-2239)
**Category:** Analytics & Session Tracking
**Status:** ✅ Production Ready

---

## Purpose

Calculates the duration (in seconds) between a session start time and the current time. Used universally across all pages to track session durations for analytics.

**Critical:** This is the **most-used function** in the entire app - called by every page's dispose() method for analytics tracking.

---

## Function Signature

```dart
int getSessionDurationSeconds(DateTime sessionStartTime)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `sessionStartTime` | `DateTime` | **Yes** | Timestamp when session/page/interaction started |

### Returns

| Type | Description |
|------|-------------|
| `int` | Duration in seconds (rounded down to nearest second) |

---

## Implementation

```dart
int getSessionDurationSeconds(DateTime sessionStartTime) {
  return DateTime.now().difference(sessionStartTime).inSeconds;
}
```

**Complexity:** O(1)
**Side Effects:** None (pure function)

---

## Dependencies

### pub.dev Packages
- None (uses Dart core library)

### Internal Dependencies
- None

---

## Usage Examples

### Example 1: Page View Duration (Most Common)
```dart
// In page initState:
_model.pageStartTime = getCurrentTimestamp;

// In page dispose:
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

### Example 2: Menu Browsing Session
```dart
// Start menu session:
_model.menuSessionStartTime = getCurrentTimestamp;

// End menu session:
await actions.trackAnalyticsEvent(
  'menu_session_ended',
  <String, String>{
    'businessId': widget.businessId.toString(),
    'sessionDuration': functions
        .getSessionDurationSeconds(_model.menuSessionStartTime!)
        .toString(),
  },
);
```

### Example 3: Filter Session Tracking
```dart
// When user first opens filters:
_model.filterSessionStartTime = getCurrentTimestamp;

// When user submits search with filters:
await actions.trackAnalyticsEvent(
  'filter_applied',
  <String, String>{
    'timeInFilterSession': functions
        .getSessionDurationSeconds(_model.filterSessionStartTime!)
        .toString(),
  },
);
```

### Example 4: Time on Search Results Before Click
```dart
// Page load:
FFAppState().sessionStartTime = getCurrentTimestamp;

// Business card tap:
await actions.trackAnalyticsEvent(
  'business_clicked',
  <String, String>{
    'timeOnListSeconds': functions
        .getSessionDurationSeconds(FFAppState().sessionStartTime!)
        .toString(),
  },
);
```

---

## Common Use Cases

| Use Case | Start Time Storage | Tracked When | Event Data Key |
|----------|-------------------|--------------|----------------|
| **Page view duration** | `_model.pageStartTime` | Page dispose | `durationSeconds` |
| **Menu session** | `_model.menuSessionStartTime` | Menu dispose | `sessionDuration` |
| **Filter session** | `_model.filterSessionStartTime` | Filter submit | `timeInFilterSession` |
| **Time on list** | `FFAppState().sessionStartTime` | Business tap | `timeOnListSeconds` |
| **Item view time** | `_model.itemViewStartTime` | Item close | `itemViewDuration` |
| **Gallery view time** | `_model.galleryStartTime` | Gallery close | `galleryDuration` |

---

## Used By Pages

**ALL pages** use this function in their dispose() method:

| Page | Purpose | Event Type |
|------|---------|------------|
| **Search Results** | Track time spent browsing results | `page_viewed` |
| **Business Profile** | Track time viewing business details | `page_viewed` |
| **Menu Full Page** | Track menu browsing duration | `page_viewed`, `menu_session_ended` |
| **Gallery Full Page** | Track gallery viewing time | `page_viewed` |
| **Contact Details** | Track contact page duration | `page_viewed` |
| **Welcome/Onboarding** | Track onboarding flow time | `page_viewed` |
| **Settings** | Track settings page duration | `page_viewed` |
| **User Profile** | Track profile page duration | `page_viewed` |

---

## Used By Custom Actions

| Action | Purpose |
|--------|---------|
| None | This function is called directly from page code, not through actions |

---

## Used By Custom Widgets

| Widget | Purpose |
|--------|---------|
| None | Widgets don't track durations directly - pages handle this in dispose |

---

## Edge Cases Handled

### Edge Case 1: Future Start Time
**Scenario:** `sessionStartTime` is in the future (clock skew, manual setting)

**Behavior:**
```dart
DateTime.now().difference(futureTime).inSeconds
// Returns negative number (e.g., -120)
```

**Impact:** Analytics receives negative duration
**Recommendation:** Add validation in calling code:
```dart
final duration = functions.getSessionDurationSeconds(startTime!);
if (duration < 0) {
  debugPrint('⚠️ Invalid session duration: $duration');
  return; // Skip analytics
}
```

### Edge Case 2: Very Old Start Time
**Scenario:** Session start time is hours/days old (app backgrounded)

**Behavior:** Returns accurate duration (e.g., 7200 for 2 hours)

**Impact:** Skews session duration analytics with outliers
**Recommendation:** Consider capping durations:
```dart
final duration = functions.getSessionDurationSeconds(startTime!);
final cappedDuration = duration > 3600 ? 3600 : duration; // Max 1 hour
```

### Edge Case 3: Null Start Time
**Scenario:** Function called before start time is set

**Behavior:** Dart throws `Null check operator used on a null value`

**Prevention:** Always use null-aware operators in calling code:
```dart
'durationSeconds': _model.pageStartTime != null
    ? functions.getSessionDurationSeconds(_model.pageStartTime!).toString()
    : '0',
```

---

## Performance Characteristics

### Time Complexity
- **O(1)** - Single subtraction operation

### Memory Usage
- **O(1)** - No allocations, returns primitive int

### Execution Time
- **< 1 microsecond** - Extremely fast

### Optimization Notes
- Already optimal - no improvements needed
- Pure function - safe to call repeatedly
- No caching needed (always computes fresh)

---

## Testing Checklist

When implementing in Flutter:

- [ ] Test with start time 1 second ago - returns 1
- [ ] Test with start time 60 seconds ago - returns 60
- [ ] Test with start time 1 hour ago - returns 3600
- [ ] Test with start time in future - returns negative number
- [ ] Test with start time at exact current time - returns 0
- [ ] Test null safety - verify calling code handles null
- [ ] Test in page dispose - verify analytics event includes duration
- [ ] Test rapid calls - verify results increase over time
- [ ] Test with device time zone change - verify correct calculation
- [ ] Test with daylight saving time transition - verify correct calculation

---

## Migration Notes

### Phase 3 Changes

**No changes needed** - function is already pure Dart with no FlutterFlow dependencies.

**Keep as-is:**
```dart
int getSessionDurationSeconds(DateTime sessionStartTime) {
  return DateTime.now().difference(sessionStartTime).inSeconds;
}
```

**Update calling code** to use new state management:
```dart
// Before (FFAppState):
functions.getSessionDurationSeconds(FFAppState().sessionStartTime!)

// After (Riverpod example):
functions.getSessionDurationSeconds(ref.read(sessionProvider).startTime!)
```

---

## Analytics Impact

This function is **critical for analytics** - it powers:

1. **User engagement metrics** - Time spent per page
2. **Session quality** - Longer sessions = more engaged users
3. **Feature usage** - Which features retain attention
4. **Bounce rate detection** - Sessions < 5 seconds
5. **A/B test evaluation** - Compare engagement across variants

**Data Quality:**
- Resolution: 1 second (sufficient for page-level tracking)
- Accuracy: Depends on device clock (generally reliable)
- Precision: Integer seconds (no decimal places)

---

## Known Issues

1. **No validation** - Accepts any DateTime, including future dates
2. **No rounding control** - Always floors to integer seconds (doesn't round up)
3. **No timezone handling** - Assumes both times use same timezone (they do, both use device time)
4. **Negative durations possible** - Returns negative number for future start times

**None of these are critical** - current implementation is sufficient for analytics use cases.

---

## Related Functions

| Function | Relationship |
|----------|-------------|
| `buildFilterAppliedEventData` | Uses this to calculate `timeSincePreviousRefinement` |

---

## Related Actions

| Action | Relationship |
|--------|-------------|
| `trackAnalyticsEvent` | Receives duration as event data |
| `endMenuSession` | Calculates menu session duration |

---

**Last Updated:** 2026-02-19
**Migration Status:** ✅ Phase 3 - No changes needed (pure Dart)
**Priority:** ⭐⭐⭐⭐⭐ Critical (used by all pages)
