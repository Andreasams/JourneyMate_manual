# Share Feedback - Fix Required

**File:** `lib/app_settings/share_feedback/share_feedback_widget.dart`
**Issue:** Missing `markUserEngaged()` call on back button
**Priority:** High (consistency + analytics)
**Date Identified:** 2026-02-19

---

## The Problem

Share Feedback page does NOT call `markUserEngaged()` before navigating back, unlike all other form pages.

**Consistency Check:**
- ✅ Missing Place: Has `markUserEngaged()` on back button
- ✅ Contact Us: Has `markUserEngaged()` on back button
- ❌ Share Feedback: **MISSING** `markUserEngaged()` on back button

**Impact:**
- User engagement not tracked when leaving Share Feedback page via back button
- Breaks analytics consistency across form pages
- Prevents proper user engagement metrics

---

## Current Code

**Location:** Line 94-96 in FlutterFlow source
**File:** `FLUTTERFLOW_ORIGINAL_CODE_share_feedback_form.txt`

```dart
onPressed: () async {
  context.pop();
},
```

---

## Required Fix

**Add `markUserEngaged()` call before navigation:**

```dart
onPressed: () async {
  await actions.markUserEngaged();
  context.safePop();
},
```

**Changes:**
1. Add `await actions.markUserEngaged();` before navigation
2. Change `context.pop()` to `context.safePop()` (matches other pages)

---

## Reference Implementation

**Contact Us page (correct pattern):**
```dart
onPressed: () async {
  await actions.markUserEngaged();
  context.safePop();
},
```

**Missing Place page (correct pattern):**
```dart
onPressed: () async {
  await actions.markUserEngaged();
  context.safePop();
},
```

---

## Testing After Fix

1. Navigate to Share Feedback page
2. Fill in some form data (optional)
3. Tap back button
4. Verify:
   - [ ] `markUserEngaged()` action is called
   - [ ] Page navigates back correctly
   - [ ] No errors in console
   - [ ] Analytics event recorded

---

## Related Documentation

- **BUNDLE:** `BUNDLE_share_feedback.md` (documents this issue)
- **Gap Analysis:** `GAP_ANALYSIS_form_pages.md` (identified this issue)
- **Comparison Files:**
  - Contact Us: `FLUTTERFLOW_ORIGINAL_CODE_contact_us_form.txt`
  - Missing Place: `FLUTTERFLOW_ORIGINAL_CODE_missing_place_form.txt`

---

**Status:** ✅ **FIXED** - 2026-02-19
**File Updated:** `journey_mate/lib/pages/share_feedback_page.dart` (lines 205-208)
**Estimated Effort:** 2 minutes (simple one-line addition)
