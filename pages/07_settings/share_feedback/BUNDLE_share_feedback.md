# Share Feedback Settings — Complete Bundle

**FlutterFlow Widget:** `ShareFeedbackWidget`
**Route:** `ShareFeedback` (path: `shareFeedback`)
**Custom Form Widget:** `FeedbackFormWidget`
**Status:** ✅ Production Ready (with known issue)

---

## Purpose

Allows users to provide feedback about the JourneyMate app. May include two-step flow: topic selection → feedback details. Simple form page following consistent wrapper pattern.

**Primary User Task:** Share feedback about app features, usability, or experience.

---

## User Flow

```
Settings → (Navigation path TBD) → Share feedback
  │
  ├─ Page loads (initState):
  │    └─ Record page start time
  │
  ├─ User views:
  │    ├─ App bar: "Share feedback"
  │    └─ FeedbackFormWidget (full-height custom widget)
  │         ├─ Possible two-step flow (inside widget):
  │         │    ├─ Step 1: Topic selection (buttons with icons)
  │         │    │    ├─ "App features"
  │         │    │    ├─ "User experience"
  │         │    │    ├─ "Performance"
  │         │    │    ├─ "Design"
  │         │    │    └─ "Other"
  │         │    │
  │         │    └─ Step 2: Feedback form
  │         │         ├─ Topic (pre-filled from step 1)
  │         │         ├─ Message (textarea)
  │         │         └─ Submit button
  │         │
  │         └─ OR single-step form (needs verification)
  │
  ├─ User interacts with form (handled by custom widget):
  │    ├─ Select topic (if multi-step)
  │    ├─ Write feedback message
  │    └─ Tap submit → API call → Success/error handling
  │
  ├─ Back button:
  │    ✅ FIXED (2026-02-19): markUserEngaged() call added
  │    └─ Mark engagement, navigate back (consistent with other form pages)
  │
  └─ Page dispose → Track analytics (page_viewed with duration)
```

---

## Page Structure

### Simple Wrapper Pattern

**Architecture:**
- StatefulWidget with app bar
- Single custom widget fills entire content area
- All form logic encapsulated in custom widget
- Page wrapper handles only: app bar, back button, analytics

### App Bar

**Configuration:**
- White background
- Back button (left): iOS style arrow
- Title: Translation key `'hjszsd2y'` ("Share feedback" / "Del feedback")
- Center title: Yes

**Back Button Action:**
```dart
onPressed: () async {
  await markUserEngaged();
  context.pop(); // ✅ FIXED (2026-02-19)
},
```

**✅ FIXED (2026-02-19):** Now consistent with other form pages, calls `await markUserEngaged()` before navigating back.

### Content Area

**Single Element:**
- `FeedbackFormWidget` custom widget wrapped in `SingleChildScrollView`
- Padding: 6px left/right
- Additional empty container below (1px height, possibly for spacing)
- Props:
  - `width`: `double.infinity` (full width)
  - `height`: `MediaQuery.sizeOf(context).height` (full available height)
  - `currentLanguage`: `FFLocalizations.of(context).languageCode`
  - `pageName`: `'shareFeedback'` ⭐ **Unique prop** (allows widget to adapt behavior based on page context)
  - `translationsCache`: `FFAppState().translationsCache`

---

## Translation Keys

### Page-Level Keys (1 key)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `'hjszsd2y'` | App bar title | Share feedback | Del feedback |

### Custom Widget Keys (Unknown)

The `FeedbackFormWidget` receives `translationsCache` prop and handles its own translations internally.

**Expected Keys (based on JSX design and pageName prop):**
- **Topic Selection Step (if multi-step):**
  - "Select feedback topic" heading
  - Topic button labels: "App features", "User experience", "Performance", "Design", "Other"
  - Topic descriptions/icons

- **Feedback Form Step:**
  - "Topic" label (if shown)
  - "Message" or "Feedback" label
  - Placeholder text: "Share your thoughts..."
  - Submit button text: "Send feedback"

- **Validation & Feedback:**
  - Error messages: "Please select a topic", "Message is required"
  - Success message: "Thank you for your feedback!"
  - Error message: "Failed to send feedback. Please try again."

**Note:** Actual keys require reading `FeedbackFormWidget` source code. The `pageName` prop suggests the widget may show different content/behavior for different pages.

---

## Custom Widgets Used

### FeedbackFormWidget
- **Location:** Custom code widget
- **Purpose:** Complete feedback form, possibly with two-step flow
- **Props:**
  - `width` (double) - Widget width (`double.infinity`)
  - `height` (double) - Widget height (full screen height)
  - `currentLanguage` (String) - Language code for translations
  - `pageName` (String) - Page context identifier (`'shareFeedback'`) ⭐ **Unique**
  - `translationsCache` (dynamic) - Translation data

**Purpose of `pageName` Prop:**
- Allows widget to adapt behavior based on where it's used
- May show different topics for different pages
- May show page-specific feedback questions
- Enables reusability across multiple pages

**Expected Features (based on JSX design):**
1. **Topic Selection (Step 1, if multi-step)**
   - Grid or list of topic buttons
   - Icons for each topic
   - Tap to select and proceed to Step 2

2. **Feedback Form (Step 2 or single-step)**
   - Topic display (if pre-selected)
   - Message textarea (required)
   - Character count (possibly)
   - Submit button

3. **Form Validation**
   - Topic selection required (if multi-step)
   - Message required, min length
   - Submit button state management

4. **Submission Logic**
   - API call to feedback endpoint
   - Includes: topic, message, pageName, user context
   - Success: Show success message, reset form
   - Error: Show error message, keep form data

**Additional Widgets Mentioned:**
- `UserFeedbackButtonsPage` - May be used for topic selection
- `UserFeedbackButtonsTopic` - May be used for topic buttons

**Documentation:** Requires custom widget source code for complete details.

---

## Custom Actions Used

### 1. ✅ markUserEngaged() - FIXED!
- **Called:** On back button tap (fixed 2026-02-19)
- **Purpose:** Track user engagement
- **Parameters:** None
- **Status:** Now consistent with other form pages

### 2. trackAnalyticsEvent()
- **Called:** On page dispose
- **Purpose:** Track page view with duration
- **Parameters:**
  - Event name: `'page_viewed'`
  - Event data: `{ 'pageName': 'shareFeedbackSettings', 'durationSeconds': calculated }`

**Note:** `FeedbackFormWidget` likely calls additional custom actions for:
- Form submission API call
- Success/error handling
- Analytics tracking for feedback submission (may include topic category)

---

## FFAppState Usage

### Read (by custom widget)
- `translationsCache` - For translated form labels and messages

### Write (by custom widget, if any)
- Unknown - requires custom widget source code

---

## Model State Variables

### _model Fields

| Field | Type | Purpose |
|-------|------|---------|
| `pageStartTime` | DateTime | Records when page loaded (for analytics) |

**Note:** Custom widget manages its own internal state (form data, selected topic, validation, submission status).

---

## Lifecycle Events

### initState

**Sequence:**
1. Create model
2. Post-frame callback:
   - Record page start time: `_model.pageStartTime = getCurrentTimestamp`

**Note:** Minimal page-level initialization. Custom widget handles its own initialization.

### dispose

**Sequence:**
1. Track analytics:
   ```dart
   await actions.trackAnalyticsEvent('page_viewed', {
     'pageName': 'shareFeedbackSettings',
     'durationSeconds': calculated,
   });
   ```
2. Dispose model: `_model.dispose()`
3. Call super: `super.dispose()`

---

## Analytics Events

### page_viewed

**Triggered:** On page dispose
**Event Data:**
- `pageName`: `'shareFeedbackSettings'`
- `durationSeconds`: Time spent on page

**Custom Widget Events (Expected):**
- `feedback_submitted` - When form successfully submitted
  - May include: `topic` (feedback category)
  - May include: `pageName` (where feedback originated)
- `feedback_submission_failed` - When form submission fails
- `feedback_topic_selected` - When user selects a topic (if multi-step)

---

## Navigation

### Entry Points

**From:** Settings (navigation path TBD)
**Method:** User taps link/button to share feedback
**Route:** `context.pushNamed('ShareFeedback')`

### Exit Points

**Back Button:**
- Action: `await markUserEngaged()` → `context.pop()` ✅ **FIXED** (2026-02-19)
- Returns to previous page

**After Successful Submission:**
- May auto-navigate back after showing success message
- Or allow user to send more feedback

---

## Design Specifications

### Colors

- Background: `primaryBackground` (white)
- App bar background: White
- Text: Defined in custom widget
- Button: Defined in custom widget
- Topic buttons: Defined in custom widget
- Form elements: Defined in custom widget

### Typography

- App bar title: 16px, 400 weight, center
- Form elements: Defined in custom widget

### Spacing

- Content padding: 6px left/right (page wrapper)
- Additional spacing: Handled by custom widget
- Form fills full available height

---

## JSX Design Reference

**Two-Step Flow (from DESIGN_README):**

**Step 1: Topic Selection**
- Grid of topic buttons with icons
- Topics: App features, User experience, Performance, Design, Other
- Each button shows icon + label
- Tap to proceed to feedback form

**Step 2: Feedback Form**
- Topic (pre-filled, may be editable)
- Message textarea (required)
- Submit button

**Validation:**
- Topic: Required (if not pre-filled)
- Message: Required, min length ~10 characters

**Submit Button:**
- Text: "Send feedback" or similar
- Disabled when invalid
- Enabled when valid
- Shows loading indicator during submission

---

## Known Issues

### ✅ Issue 1: Missing markUserEngaged() Call - FIXED (2026-02-19)

**Previously Critical Inconsistency (NOW RESOLVED):**
- Missing Place: Has `markUserEngaged()` ✓
- Contact Us: Has `markUserEngaged()` ✓
- Share Feedback: **NOW HAS** `markUserEngaged()` ✅

**Fixed Code (share_feedback_page.dart lines 205-208):**
```dart
onPressed: () async {
  await markUserEngaged();
  context.pop();
},
```

**Impact:** User engagement now properly tracked when leaving Share Feedback page via back button.

**Fix Applied:** 2026-02-19 - All form pages now consistent

---

## Testing Checklist

### Page Load
- [ ] Page loads correctly
- [ ] App bar shows "Share feedback" title
- [ ] Back button present and functional
- [ ] FeedbackFormWidget renders correctly
- [ ] Widget receives correct props (language, pageName, translations cache)
- [ ] Page start time recorded

### Form Functionality (Custom Widget)
- [ ] Topic selection displays (if multi-step)
- [ ] All topics available
- [ ] Selecting topic proceeds to feedback form
- [ ] Message field displays
- [ ] Required field validation works
- [ ] Submit button disabled when invalid
- [ ] Submit button enabled when valid
- [ ] Form submission works
- [ ] Success message displays
- [ ] Error message displays on failure
- [ ] Form resets after success

### Navigation
- [x] ✅ Back button marks engagement (FIXED 2026-02-19)
- [ ] Back button returns to previous page

### Analytics
- [ ] page_viewed event tracked on dispose
- [ ] Duration calculated correctly
- [ ] Feedback submission events tracked (by custom widget)
- [ ] Topic category tracked in feedback submission event

---

## Migration Priority

⭐⭐⭐ **Medium** - Important feedback channel, but not critical path

**✅ Fix Completed (2026-02-19):** Added `markUserEngaged()` call to back button

---

## Related Documentation

- **JSX Design:** Form design details (DESIGN_README_share_feedback.md or similar)
- **Gap Analysis:** `pages/07_settings/GAP_ANALYSIS_form_pages.md` (combined analysis, documents the missing markUserEngaged issue)
- **PAGE README:** `pages/07_settings/PAGE_README.md`
- **FlutterFlow Source:** User provided complete source code
- **Custom Widgets:**
  - `FeedbackFormWidget` (requires separate documentation)
  - `UserFeedbackButtonsPage` (if exists)
  - `UserFeedbackButtonsTopic` (if exists)

---

## Next Steps for Complete Documentation

1. **✅ DONE: Added missing markUserEngaged() call (2026-02-19)**
   - Updated share_feedback_page.dart back button
   - Now matches behavior of Missing Place and Contact Us pages

2. **Read `FeedbackFormWidget` source code**
   - Extract all translation keys
   - Document two-step flow (if implemented)
   - Document topic options
   - Document form fields and validation rules
   - Document API endpoint for submission
   - Document success/error handling
   - Understand purpose of `pageName` prop

3. **Read related widget source code**
   - `UserFeedbackButtonsPage` (if exists)
   - `UserFeedbackButtonsTopic` (if exists)

4. **Create widget documentation**
   - `shared/widgets/MASTER_README_feedback_form_widget.md`

5. **Update MASTER_TRANSLATION_KEYS.md**
   - Add all form-level translation keys

---

**Last Updated:** 2026-02-19
**Status:** ✅ Page-level documentation complete, ✅ markUserEngaged() fix applied, ⚠️ Custom widget requires source code

**Key Pattern:** Follows consistent wrapper pattern but has `pageName` prop (unique feature). ✅ **Fixed (2026-02-19):** User engagement tracking now consistent with all other form pages.

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(translationsCacheProvider)` | `translationsCache` | Passed directly to `FeedbackFormWidget` for all topic labels, form labels, hints, errors, and success/error messages |

### Writes
None from page level. `FeedbackFormWidget` calls the BuildShip `/feedbackform` endpoint directly via `http.post()`. The submission does not update any Riverpod provider — it is purely a fire-and-forget form submission.

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation on dispose |
