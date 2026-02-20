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

---

## Custom Widget Internals — FeedbackFormWidget

> Source: `_flutterflow_export/lib/custom_code/widgets/feedback_form_widget.dart`

### Constructor signature
```dart
FeedbackFormWidget({
  double? width,
  double? height,
  required String currentLanguage,    // FFLocalizations.of(context).languageCode
  required dynamic translationsCache, // FFAppState().translationsCache
  String? pageName,                   // 'shareFeedback' — context identifier, NOT sent to API
})
```

**`pageName` note:** This prop is received and stored as `widget.pageName` but is NOT
currently included in the API request body. It is available for future use to route
feedback to different handlers based on the originating page context.

### Form fields
| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| Topic | Chip buttons (Wrap) | Yes | Must select one | 7 options, animated 200ms |
| Message | Textarea (6 lines) | Yes | Not empty AND ≥ 10 chars | |
| "Contact me" checkbox | Checkbox | No | Boolean, default false | Makes Name + Contact required |
| Name | Text input (1 line) | Conditional | Required only if checkbox checked | Shows required * when checked |
| Contact info | Text input (1 line) | Conditional | Required only if checkbox checked | Email or phone |

### Topic options (7, localized via translation keys)
| Translation key | Default label (approximate) |
|----------------|---------------------------|
| `feedback_topic_wrong_info` | Wrong info |
| `feedback_topic_app_ideas` | App ideas |
| `feedback_topic_bug` | Bug |
| `feedback_topic_missing_place` | Missing place |
| `feedback_topic_suggestion` | Suggestion |
| `feedback_topic_praise` | Praise |
| `feedback_topic_other` | Other |

Topic buttons use `Wrap` layout with 8px horizontal spacing. Selected topic color: `#EE8B60`.
Unselected: `#F2F3F5` background with grey border. Both animate via `AnimatedContainer` (200ms).

### API call
- **Endpoint:** `POST https://wvb8ww.buildship.run/feedbackform`
- **Request body:**
  ```json
  {
    "topic": "Wrong info",           // Localized label string of selected topic
    "message": "...",
    "allowContact": false,           // true if checkbox checked
    "name": "..." ,                  // null if not provided
    "contact": "...",                // null if not provided
    "languageCode": "en"
  }
  ```
- **Response:** `{ "success": true }` or `{ "success": false, "error": "..." }`
- **Trigger:** User taps submit button (after successful validation)
- **Loading state:** Submit button replaced by `CircularProgressIndicator` (white, 20×20px, 2px stroke)
- **Important:** `topic` is sent as the **localized label string** (not a key). If the user's
  language changes between topic selection and submission, the sent topic label will reflect
  the language active at selection time.

### Success handling
- `_isSubmitted` set to `true`
- Submit button replaced by green success box:
  - `Icons.check_circle_outline` (green, 32px)
  - `feedback_form_success_message` (green, 15px, w500)
  - `feedback_form_success_navigate_away` (green 80% opacity, 13px, w400)

### Error handling
- `_submissionError` set to error string
- Error box + retry button below:
  - `Icons.error_outline` (red, 32px)
  - `feedback_form_error_submission` (red, 15px, w500)
  - Submit button reappears below the error box for retry

### Internal translation keys (all via `getTranslations(currentLanguage, key, translationsCache)`)
| Key | Used for |
|-----|----------|
| `feedback_form_title_main` | Section heading (20px, w500) |
| `feedback_form_subtitle_main` | Description paragraph (15px, w300) |
| `feedback_form_title_topic` | Topic section label (required *) |
| `feedback_form_subtitle_topic` | Topic helper text |
| `feedback_topic_wrong_info` | Topic chip label |
| `feedback_topic_app_ideas` | Topic chip label |
| `feedback_topic_bug` | Topic chip label |
| `feedback_topic_missing_place` | Topic chip label |
| `feedback_topic_suggestion` | Topic chip label |
| `feedback_topic_praise` | Topic chip label |
| `feedback_topic_other` | Topic chip label |
| `feedback_form_error_topic_required` | Validation: no topic selected |
| `feedback_form_title_message` | Message field label (required *) |
| `feedback_form_subtitle_message` | Message helper text |
| `feedback_form_hint_message` | Message placeholder |
| `feedback_form_error_message_required` | Validation: message empty |
| `feedback_form_error_message_too_short` | Validation: message < 10 chars |
| `feedback_form_title_contact_consent` | Checkbox section label |
| `feedback_form_subtitle_contact_consent` | Checkbox description (with checkbox inline) |
| `feedback_form_title_name` | Name field label (required * when checkbox checked) |
| `feedback_form_hint_name` | Name placeholder |
| `feedback_form_error_name_required` | Validation: name empty (when checkbox) |
| `feedback_form_title_contact_info` | Contact field label (required * when checkbox) |
| `feedback_form_subtitle_contact_info` | Contact helper (email or phone) |
| `feedback_form_hint_contact_info` | Contact placeholder |
| `feedback_form_error_contact_required` | Validation: contact empty (when checkbox) |
| `feedback_form_button_submit` | Submit button label |
| `feedback_form_success_message` | Success state: main message |
| `feedback_form_success_navigate_away` | Success state: sub-message |
| `feedback_form_error_submission` | Error state: error message |

### Analytics events
`markUserEngaged()` is called in three places:
1. `_handleTopicSelected()` — when user taps any topic chip
2. `_handleContactRequiredChanged()` — when user toggles "Contact me" checkbox
3. `_handleSubmit()` — on every submit attempt (before validation)

No `trackAnalyticsEvent()` calls inside this widget — analytics are tracked at the page level only.

### Styling constants
| Property | Value |
|----------|-------|
| Text field background | `#F2F3F5` |
| Submit button color | `#E9874B` (orange) |
| Selected topic color | `#EE8B60` (selected chip bg) |
| Unselected topic color | `#F2F3F5` (unselected chip bg) |
| Unselected topic text | `#242629` |
| Topic border (unselected) | `Colors.grey[500]` |
| Topic button height | 32px, radius 8px |
| Success color | `#249689` (green) |
| Error color | `Colors.red` |
| Submit button size | 200×40px, radius 8px |
| Checkbox active color | `#E9874B` (orange, matches submit) |
| Bottom padding | 140px (for keyboard clearance) |
| Section spacing | 24px |

### Language change support
`didUpdateWidget()` is overridden — if `currentLanguage` or `translationsCache` changes,
`setState()` is called to re-render all translated strings (including topic labels).
