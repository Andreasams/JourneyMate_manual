# Missing Place Settings — Complete Bundle

**FlutterFlow Widget:** `MissingPlaceWidget`
**Route:** `MissingPlace` (path: `missingPlace`)
**Custom Form Widget:** `MissingLocationFormWidget`
**Status:** ✅ Production Ready

---

## Purpose

Allows users to report restaurants or places that are missing from the JourneyMate database. Simple form page following consistent wrapper pattern.

**Primary User Task:** Report a missing restaurant with name, address, and optional message.

---

## User Flow

```
Settings → (Navigation path TBD) → Are we missing a place?
  │
  ├─ Page loads (initState):
  │    └─ Record page start time
  │
  ├─ User views:
  │    ├─ App bar: "Are we missing a place?"
  │    └─ MissingLocationFormWidget (full-height custom widget)
  │         ├─ Form fields (inside widget):
  │         │    ├─ Restaurant name (required)
  │         │    ├─ Address (required, with helper text)
  │         │    └─ Message (optional, textarea with helper text)
  │         │
  │         ├─ Submit button (disabled until valid)
  │         └─ Form validation (inside widget)
  │
  ├─ User interacts with form (handled by custom widget):
  │    ├─ Fill in fields
  │    ├─ Button enables when valid
  │    └─ Tap submit → API call → Success/error handling
  │
  ├─ Back button:
  │    └─ Mark engagement, navigate back
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
- Title: Translation key `'f5zshdrf'` ("Are we missing a place?" / "Mangler vi et sted?")
- Center title: Yes

**Back Button Action:**
- `await actions.markUserEngaged()`
- `context.safePop()`

### Content Area

**Single Element:**
- `MissingLocationFormWidget` custom widget
- Props:
  - `width`: `double.infinity` (full width)
  - `height`: `MediaQuery.sizeOf(context).height` (full available height)
  - `currentLanguage`: `FFLocalizations.of(context).languageCode`
  - `translationsCache`: `FFAppState().translationsCache`

---

## Translation Keys

### Page-Level Keys (1 key)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `'f5zshdrf'` | App bar title | Are we missing a place? | Mangler vi et sted? |

### Custom Widget Keys (Unknown)

The `MissingLocationFormWidget` receives `translationsCache` prop and handles its own translations internally.

**Expected Keys (based on JSX design):**
- Form field labels: "Restaurant name", "Address", "Message"
- Helper text for address and message fields
- Submit button text: "Submit" or "Send"
- Validation error messages
- Success message: "Thank you for your submission!"
- Error message: "Something went wrong. Please try again."

**Note:** Actual keys require reading `MissingLocationFormWidget` source code.

---

## Custom Widget Used

### MissingLocationFormWidget
- **Location:** Custom code widget
- **Purpose:** Complete form for reporting missing restaurants
- **Props:**
  - `width` (double) - Widget width (`double.infinity`)
  - `height` (double) - Widget height (full screen height)
  - `currentLanguage` (String) - Language code for translations
  - `translationsCache` (dynamic) - Translation data

**Expected Features (based on JSX design):**
1. **Name Field** (required)
   - Text input
   - Validation: Not empty
   - Max length: ~100 characters

2. **Address Field** (required)
   - Text input or textarea
   - Helper text: "Include street, city, and country if possible"
   - Validation: Not empty

3. **Message Field** (optional)
   - Textarea
   - Helper text: "Any additional information that might help us find this place"
   - Validation: None (optional)

4. **Submit Button**
   - Disabled when form invalid
   - Enabled when required fields filled
   - Shows loading indicator during submission

5. **Form Validation**
   - Real-time validation
   - Error messages below fields
   - Submit button state management

6. **Submission Logic**
   - API call to report endpoint
   - Success: Show success message, reset form
   - Error: Show error message, keep form data

**Documentation:** Requires custom widget source code for complete details.

---

## Custom Actions Used

### 1. markUserEngaged()
- **Called:** On back button tap
- **Purpose:** Track user engagement
- **Parameters:** None

### 2. trackAnalyticsEvent()
- **Called:** On page dispose
- **Purpose:** Track page view with duration
- **Parameters:**
  - Event name: `'page_viewed'`
  - Event data: `{ 'pageName': 'missingPlaceSettings', 'durationSeconds': calculated }`

**Note:** `MissingLocationFormWidget` likely calls additional custom actions for:
- Form submission API call
- Success/error handling
- Analytics tracking for form submission

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

**Note:** Custom widget manages its own internal state (form data, validation, submission status).

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
     'pageName': 'missingPlaceSettings',
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
- `pageName`: `'missingPlaceSettings'`
- `durationSeconds`: Time spent on page

**Custom Widget Events (Expected):**
- `missing_place_submitted` - When form successfully submitted
- `missing_place_submission_failed` - When form submission fails

---

## Navigation

### Entry Points

**From:** Settings (navigation path TBD)
**Method:** User taps link/button to report missing place
**Route:** `context.pushNamed('MissingPlace')`

### Exit Points

**Back Button:**
- Action: `await actions.markUserEngaged()` → `context.safePop()`
- Returns to previous page

**After Successful Submission:**
- May auto-navigate back after showing success message
- Or allow user to submit another report

---

## Design Specifications

### Colors

- Background: `primaryBackground` (white)
- App bar background: White
- Text: Defined in custom widget
- Button: Defined in custom widget
- Form elements: Defined in custom widget

### Typography

- App bar title: 16px, 400 weight, center
- Form elements: Defined in custom widget

### Spacing

- Content padding: Handled by custom widget
- Form fills full available height

---

## JSX Design Reference

**Form Fields (from DESIGN_README):**
1. Restaurant name (required, text input)
2. Address (required, textarea, helper text)
3. Message (optional, textarea, helper text)

**Validation:**
- Name: Required, not empty
- Address: Required, not empty
- Message: Optional

**Submit Button:**
- Text: "Submit" or similar
- Disabled when invalid
- Enabled when valid
- Shows loading indicator during submission

**Form Reset:**
- After successful submission, form resets to empty state

---

## Known Issues

None identified at page wrapper level. Custom widget functionality requires testing.

---

## Testing Checklist

### Page Load
- [ ] Page loads correctly
- [ ] App bar shows "Are we missing a place?" title
- [ ] Back button present and functional
- [ ] MissingLocationFormWidget renders at full height
- [ ] Widget receives correct props (language, translations cache)
- [ ] Page start time recorded

### Form Functionality (Custom Widget)
- [ ] All form fields display correctly
- [ ] Required fields validated
- [ ] Optional fields work correctly
- [ ] Submit button disabled when invalid
- [ ] Submit button enabled when valid
- [ ] Form submission works
- [ ] Success message displays
- [ ] Error message displays on failure
- [ ] Form resets after success

### Navigation
- [ ] Back button marks engagement
- [ ] Back button returns to previous page

### Analytics
- [ ] page_viewed event tracked on dispose
- [ ] Duration calculated correctly
- [ ] Form submission events tracked (by custom widget)

---

## Migration Priority

⭐⭐⭐ **Medium** - Utility feature for user feedback

---

## Related Documentation

- **JSX Design:** Form design details (need to locate specific JSX file)
- **Gap Analysis:** `pages/07_settings/GAP_ANALYSIS_form_pages.md` (combined analysis)
- **PAGE README:** `pages/07_settings/PAGE_README.md`
- **FlutterFlow Source:** User provided complete source code
- **Custom Widget:** `MissingLocationFormWidget` (requires separate documentation)

---

## Next Steps for Complete Documentation

1. **Read `MissingLocationFormWidget` source code**
   - Extract all translation keys
   - Document form fields and validation rules
   - Document API endpoint for submission
   - Document success/error handling

2. **Create widget documentation**
   - `shared/widgets/MASTER_README_missing_location_form_widget.md`

3. **Update MASTER_TRANSLATION_KEYS.md**
   - Add all form-level translation keys

---

**Last Updated:** 2026-02-19
**Status:** ✅ Page-level documentation complete, ⚠️ Custom widget requires source code

**Key Pattern:** Follows consistent wrapper pattern - simple page with app bar + full-height custom widget. All form logic encapsulated in widget.

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(translationsCacheProvider)` | `translationsCache` | Passed directly to `MissingLocationFormWidget` for all form labels, hints, errors, and success/error messages |

### Writes
None from page level. `MissingLocationFormWidget` calls the BuildShip `/missingplace` endpoint directly via `http.post()`. The submission does not update any Riverpod provider — it is purely a fire-and-forget form submission.

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation on dispose |

---

## Custom Widget Internals — MissingLocationFormWidget

> Source: `_flutterflow_export/lib/custom_code/widgets/missing_location_form_widget.dart`

### Constructor signature
```dart
MissingLocationFormWidget({
  double? width,
  double? height,
  required String currentLanguage,    // FFLocalizations.of(context).languageCode
  required dynamic translationsCache, // FFAppState().translationsCache
})
```

### Form fields
| Field | Type | Required | Validation | Max lines |
|-------|------|----------|------------|-----------|
| Business name | Text input | Yes | Not empty | 1 |
| Business address | Text input | Yes | Not empty | 1 |
| Message | Textarea | Yes | Not empty AND length ≥ 10 chars | 6 |

All three fields display a red `*` asterisk next to their label when required. Error messages
appear below the field (red, 12px). Errors clear immediately on any text change.

### API call
- **Endpoint:** `POST https://wvb8ww.buildship.run/missingplace`
- **Request body:**
  ```json
  {
    "businessName": "...",
    "businessAddress": "...",
    "message": "...",
    "languageCode": "en"
  }
  ```
- **Response:** `{ "success": true }` or `{ "success": false, "error": "..." }`
- **Trigger:** User taps submit button (after successful validation)
- **Loading state:** Submit button replaced by `CircularProgressIndicator` (white, 20×20px, 2px stroke)

### Success handling
- `_isSubmitted` set to `true`
- Submit button replaced by green success box (border + light background):
  - `Icons.check_circle_outline` (green, 32px)
  - `missing_location_success_message` (green, 15px, w500)
  - `missing_location_success_navigate_away` (green 80% opacity, 13px, w400)
- No retry — form is done. User must navigate away manually.

### Error handling
- `_submissionError` set to error string
- Submit button replaced by red error box + retry button below:
  - `Icons.error_outline` (red, 32px)
  - `missing_location_error_submission` (red, 15px, w500)
  - Submit button reappears below the error box for retry

### Internal translation keys (all via `getTranslations(currentLanguage, key, translationsCache)`)
| Key | Used for |
|-----|----------|
| `missing_location_title_main` | Section heading (20px, w500) |
| `missing_location_subtitle_main_1` | First description paragraph (15px, w300) |
| `missing_location_subtitle_main_2` | Second description paragraph (15px, w300) |
| `missing_location_title_business_name` | Business name field label |
| `missing_location_hint_business_name` | Business name placeholder text |
| `missing_location_error_name_required` | Validation: name empty |
| `missing_location_title_business_address` | Address field label |
| `missing_location_subtitle_business_address` | Address helper text |
| `missing_location_hint_business_address` | Address placeholder text |
| `missing_location_error_address_required` | Validation: address empty |
| `missing_location_title_message` | Message field label |
| `missing_location_subtitle_message` | Message helper text |
| `missing_location_hint_message` | Message placeholder text |
| `missing_location_error_message_required` | Validation: message empty |
| `missing_location_error_message_too_short` | Validation: message < 10 chars |
| `missing_location_button_submit` | Submit button label |
| `missing_location_success_message` | Success state: main message |
| `missing_location_success_navigate_away` | Success state: sub-message |
| `missing_location_error_submission` | Error state: error message |

### Analytics events
`markUserEngaged()` is called in `_handleSubmit()` on every submit attempt (before validation).
No `trackAnalyticsEvent()` calls inside this widget — analytics are tracked at the page level only.

### Styling constants
| Property | Value |
|----------|-------|
| Text field background | `#F2F3F5` |
| Submit button color | `#E9874B` (orange) |
| Success color | `#249689` (green) |
| Error color | `Colors.red` |
| Submit button size | 200×40px, radius 8px |
| Text field radius | 8px |
| Bottom padding | 140px (for keyboard clearance) |
| Section spacing | 24px |

### Language change support
`didUpdateWidget()` is overridden — if `currentLanguage` or `translationsCache` changes,
`setState()` is called to re-render all translated strings immediately.
