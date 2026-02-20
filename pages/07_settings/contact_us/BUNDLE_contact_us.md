# Contact Us Settings — Complete Bundle

**FlutterFlow Widget:** `ContactUsWidget`
**Route:** `ContactUs` (path: `contactUs`)
**Custom Form Widget:** `ContactUsFormWidget`
**Status:** ✅ Production Ready

---

## Purpose

Support contact form allowing users to reach out to JourneyMate team with questions, issues, or feedback. Simple form page following consistent wrapper pattern.

**Primary User Task:** Send support request with email, subject, and message.

---

## User Flow

```
Settings → (Navigation path TBD) → Contact us
  │
  ├─ Page loads (initState):
  │    └─ Record page start time
  │
  ├─ User views:
  │    ├─ App bar: "Contact us"
  │    └─ ContactUsFormWidget (full-height custom widget)
  │         ├─ Form fields (inside widget):
  │         │    ├─ Email (required, with validation)
  │         │    ├─ Subject (dropdown or text input)
  │         │    └─ Message (required, textarea)
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
- Title: Translation key `'q6agbobw'` ("Contact us" / "Kontakt os")
- Center title: Yes

**Back Button Action:**
- `await actions.markUserEngaged()`
- `context.safePop()`

### Content Area

**Single Element:**
- `ContactUsFormWidget` custom widget wrapped in `SingleChildScrollView`
- Padding: 6px left/right
- Additional empty container below (1px height, possibly for spacing)
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
| `'q6agbobw'` | App bar title | Contact us | Kontakt os |

### Custom Widget Keys (Unknown)

The `ContactUsFormWidget` receives `translationsCache` prop and handles its own translations internally.

**Expected Keys (based on JSX design):**
- Form field labels: "Email", "Subject", "Message"
- Subject dropdown options (if applicable)
- Placeholder text for fields
- Submit button text: "Send message" or similar
- Validation error messages: "Please enter a valid email", "Message is required"
- Success message: "Thank you! We'll get back to you soon."
- Error message: "Failed to send message. Please try again."

**Note:** Actual keys require reading `ContactUsFormWidget` source code.

---

## Custom Widget Used

### ContactUsFormWidget
- **Location:** Custom code widget
- **Purpose:** Complete support contact form
- **Props:**
  - `width` (double) - Widget width (`double.infinity`)
  - `height` (double) - Widget height (full screen height)
  - `currentLanguage` (String) - Language code for translations
  - `translationsCache` (dynamic) - Translation data

**Expected Features (based on JSX design):**
1. **Email Field** (required)
   - Text input
   - Email validation (format check)
   - Error message: "Please enter a valid email"

2. **Subject Field** (required)
   - May be dropdown with predefined options:
     - "General question"
     - "Report a bug"
     - "Feature request"
     - "Account issue"
     - "Other"
   - OR free text input
   - Validation: Not empty

3. **Message Field** (required)
   - Textarea
   - Validation: Not empty
   - Min length: ~10 characters (typical)

4. **Submit Button**
   - Disabled when form invalid
   - Enabled when all required fields valid
   - Shows loading indicator during submission

5. **Form Validation**
   - Real-time email validation
   - Required field checks
   - Error messages below fields
   - Submit button state management

6. **Submission Logic**
   - API call to support endpoint
   - Success: Show success message, reset form
   - Error: Show error message, keep form data for retry

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
  - Event data: `{ 'pageName': 'contactUsSettings', 'durationSeconds': calculated }`

**Note:** `ContactUsFormWidget` likely calls additional custom actions for:
- Form submission API call
- Email validation
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
     'pageName': 'contactUsSettings',
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
- `pageName`: `'contactUsSettings'`
- `durationSeconds`: Time spent on page

**Custom Widget Events (Expected):**
- `contact_form_submitted` - When form successfully submitted
- `contact_form_submission_failed` - When form submission fails
- May include: `subject` category for analytics segmentation

---

## Navigation

### Entry Points

**From:** Settings (navigation path TBD)
**Method:** User taps link/button to contact support
**Route:** `context.pushNamed('ContactUs')`

### Exit Points

**Back Button:**
- Action: `await actions.markUserEngaged()` → `context.safePop()`
- Returns to previous page

**After Successful Submission:**
- May auto-navigate back after showing success message
- Or allow user to send another message

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

- Content padding: 6px left/right (page wrapper)
- Additional spacing: Handled by custom widget
- Form fills full available height

---

## JSX Design Reference

**Form Fields (from DESIGN_README):**
1. Email (required, validated format)
2. Subject (required, dropdown or text)
3. Message (required, textarea)

**Validation:**
- Email: Required, valid email format
- Subject: Required, not empty
- Message: Required, min length

**Submit Button:**
- Text: "Send message" or similar
- Disabled when invalid
- Enabled when valid
- Shows loading indicator during submission

**Form Reset:**
- After successful submission, form resets to empty state

---

## Known Issues

### Issue 1: Inconsistent with Other Form Pages

✅ **Has `markUserEngaged()` on back button** (consistent with Missing Place)

**Note:** Share Feedback page is missing this call - Contact Us is correct.

---

## Testing Checklist

### Page Load
- [ ] Page loads correctly
- [ ] App bar shows "Contact us" title
- [ ] Back button present and functional
- [ ] ContactUsFormWidget renders correctly
- [ ] Widget receives correct props (language, translations cache)
- [ ] Page start time recorded

### Form Functionality (Custom Widget)
- [ ] All form fields display correctly
- [ ] Email validation works
- [ ] Subject field works (dropdown or text)
- [ ] Message field accepts text
- [ ] Required fields validated
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

⭐⭐⭐ **Medium** - Important support channel for users

---

## Related Documentation

- **JSX Design:** Form design details (DESIGN_README_contact_us_form.md)
- **Gap Analysis:** `pages/07_settings/GAP_ANALYSIS_form_pages.md` (combined analysis)
- **PAGE README:** `pages/07_settings/PAGE_README.md`
- **FlutterFlow Source:** User provided complete source code
- **Custom Widget:** `ContactUsFormWidget` (requires separate documentation)
- **Related Widget README:** `shared/widgets/MASTER_README_contact_us_form_widget.md` (if exists)

---

## Next Steps for Complete Documentation

1. **Read `ContactUsFormWidget` source code**
   - Extract all translation keys
   - Document form fields and validation rules
   - Document subject dropdown options (if applicable)
   - Document API endpoint for submission
   - Document success/error handling

2. **Create/update widget documentation**
   - `shared/widgets/MASTER_README_contact_us_form_widget.md`

3. **Update MASTER_TRANSLATION_KEYS.md**
   - Add all form-level translation keys

---

**Last Updated:** 2026-02-19
**Status:** ✅ Page-level documentation complete, ⚠️ Custom widget requires source code

**Key Pattern:** Follows consistent wrapper pattern - simple page with app bar + full-height custom widget. All form logic encapsulated in widget. Scrollable wrapper allows form to adapt to different screen sizes.

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(translationsCacheProvider)` | `translationsCache` | Passed directly to `ContactUsFormWidget` for all form labels, hints, errors, and success/error messages |

### Writes
None from page level. `ContactUsFormWidget` calls the BuildShip `/contact` endpoint directly via `http.post()`. The submission does not update any Riverpod provider — it is purely a fire-and-forget form submission.

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation on dispose |
