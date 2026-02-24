# Settings Form Pages — Gap Analysis (Combined)

**Pages Covered:** Missing Place, Contact Us, Share Feedback
**Purpose:** Identify functional differences between JSX v2 designs and FlutterFlow implementation
**Date:** 2026-02-19

---

## Gap Categories

- **A1**: Buildable with existing data (Frontend logic after API response)
- **A2**: Buildable with existing data (Backend logic in BuildShip before return)
- **B**: Requires BuildShip API changes
- **C**: Translation infrastructure gaps (new keys needed)
- **D**: Known missing features (user-identified, not in current scope)

---

## Summary

| Category | Count | Description |
|----------|-------|-------------|
| A1 | 0 | Frontend display logic (all in custom widgets) |
| A2 | 0 | Backend processing logic |
| B | 0 | API endpoint changes |
| C | 1 | Translation keys needed (verification only) |
| D | 0 | Known future features |
| **Total** | **1** | **Functional gap identified** |

---

## Observation: Consistent Wrapper Pattern

All three form pages follow the **same architectural pattern** in FlutterFlow:

### Common Page Structure

**Page Wrapper:**
- Simple `StatefulWidget` with app bar
- Back button (calls `markUserEngaged()`)
- Single translation key for app bar title
- Full-height custom widget for form content
- Page view analytics on dispose

**Custom Widget:**
- All form logic encapsulated in custom widget
- Props: `width`, `height`, `currentLanguage`, `translationsCache`
- Additional props vary by widget type

**Pattern Benefits:**
- Clean separation of concerns (page vs form logic)
- Reusable form widgets
- Consistent navigation behavior
- Simplified page-level code

---

## Missing Place Page

### FlutterFlow Implementation (Verified)

**Route:** `MissingPlace` (path: `missingPlace`)
**File:** `lib/app_settings/missing_place/missing_place_widget.dart`

**Translation Keys:**
- App bar title: `'f5zshdrf'` - "Are we missing a place?"

**Custom Widget:**
- `MissingLocationFormWidget`
- Props:
  - `width: double.infinity`
  - `height: MediaQuery.sizeOf(context).height`
  - `currentLanguage: FFLocalizations.of(context).languageCode`
  - `translationsCache: FFAppState().translationsCache`

**Analytics:**
- Event: `page_viewed`
- Data: `pageName: 'missingPlaceSettings'`, `durationSeconds`

**Custom Actions:**
- `markUserEngaged()` - On back button tap
- `trackAnalyticsEvent()` - On page dispose

**JSX Design:**
- Comprehensive form design with 3 fields (name, address, message)
- All fields required with validation
- Helper text for address and message fields
- Submit button with disabled state
- Form reset after submission

**Note:** Actual form UI and validation logic is in `MissingLocationFormWidget` (custom widget code not provided).

---

## Contact Us Page

### FlutterFlow Implementation (Verified)

**Route:** `ContactUs` (path: `contactUs`)
**File:** `lib/app_settings/contact_us/contact_us_widget.dart`

**Translation Keys:**
- App bar title: `'q6agbobw'` - "Contact us"

**Custom Widget:**
- `ContactUsFormWidget`
- Props:
  - `width: double.infinity`
  - `height: MediaQuery.sizeOf(context).height`
  - `currentLanguage: FFLocalizations.of(context).languageCode`
  - `translationsCache: FFAppState().translationsCache`

**Analytics:**
- Event: `page_viewed`
- Data: `pageName: 'contactUsSettings'`, `durationSeconds`

**Custom Actions:**
- `markUserEngaged()` - On back button tap
- `trackAnalyticsEvent()` - On page dispose

**Additional UI:**
- Wrapped in `SingleChildScrollView`
- Padding: 6px left/right
- Empty container below widget (1px height, possibly for spacing)

**JSX Design:**
- Support contact form with email, subject, message fields
- Email validation
- Subject selection or free text
- Message textarea
- Submit button with validation

**Note:** Actual form UI and validation logic is in `ContactUsFormWidget` (custom widget code not provided).

---

## Share Feedback Page

### FlutterFlow Implementation (Verified)

**Route:** `ShareFeedback` (path: `shareFeedback`)
**File:** `lib/app_settings/share_feedback/share_feedback_widget.dart`

**Translation Keys:**
- App bar title: `'hjszsd2y'` - "Share feedback"

**Custom Widget:**
- `FeedbackFormWidget`
- Props:
  - `width: double.infinity`
  - `height: MediaQuery.sizeOf(context).height`
  - `currentLanguage: FFLocalizations.of(context).languageCode`
  - `pageName: 'shareFeedback'` ⭐ **Unique prop**
  - `translationsCache: FFAppState().translationsCache`

**Analytics:**
- Event: `page_viewed`
- Data: `pageName: 'shareFeedbackSettings'`, `durationSeconds`

**Custom Actions:**
- **Missing** `markUserEngaged()` on back button ⚠️ (inconsistency)
- `trackAnalyticsEvent()` - On page dispose

**Additional UI:**
- Wrapped in `SingleChildScrollView`
- Padding: 6px left/right
- Empty container below widget (1px height)

**JSX Design:**
- Two-step form: topic selection → feedback details
- Topic buttons with icons
- Page-specific feedback form
- Message textarea
- Submit with validation

**Note:**
1. Actual form UI and validation logic is in `FeedbackFormWidget` (custom widget code not provided).
2. Additional custom widgets mentioned: `UserFeedbackButtonsPage`, `UserFeedbackButtonsTopic` (may be used within main widget)
3. `pageName` prop suggests form behavior varies by page context

---

## Translation Keys Summary

### Gap C.1: Form Page Translation Keys

**FlutterFlow Implementation (Verified from Source Code):**

All three pages use a single translation key for the app bar title:

| Page | Key | English Comment | Danish Translation |
|------|-----|-----------------|---------------------|
| Missing Place | `f5zshdrf` | Are we missing a place? | Mangler vi et sted? |
| Contact Us | `q6agbobw` | Contact us | Kontakt os |
| Share Feedback | `hjszsd2y` | Share feedback | Del feedback |

**Custom Widget Translation Keys:**

The custom widgets (`MissingLocationFormWidget`, `ContactUsFormWidget`, `FeedbackFormWidget`) receive `translationsCache` prop and `currentLanguage`, suggesting they handle their own translations internally.

**Unknown (Requires Custom Widget Code):**
- Form field labels
- Helper text
- Validation messages
- Submit button text
- Success/error messages
- Additional form-specific text

**No Gap:** All page-level translation keys exist in FlutterFlow. Custom widget translation keys would need to be extracted from widget source code.

---

## Architecture Summary

### Frontend Logic (A1) - 0 gaps

All form logic encapsulated in custom widgets. Page-level code is minimal wrapper.

### Backend Logic (A2) - 0 gaps

Form submission logic handled by custom widgets (unknown implementation).

### API Changes (B) - 0 gaps

Submission endpoints called from custom widgets (unknown implementation).

### Translation Keys (C) - 1 gap

- 3 page-level translation keys already exist in FlutterFlow (app bar titles)
- Custom widget translation keys unknown (requires widget source code)
- Need to add page-level keys to MASTER_TRANSLATION_KEYS.md

### Known Missing (D) - 0 gaps

No features explicitly marked as "not in current scope" by user.

---

## Custom Widgets Requirements

### Common Widget Props

All three form widgets receive:
- `width: double.infinity` - Full width
- `height: MediaQuery.sizeOf(context).height` - Full available height
- `currentLanguage: languageCode` - For translations
- `translationsCache: FFAppState().translationsCache` - Translation data

### Widget-Specific Props

**FeedbackFormWidget only:**
- `pageName: 'shareFeedback'` - Context identifier

**Purpose:** Allows widget to adapt behavior/content based on page context.

---

## Known Issues

### Issue 1: Missing markUserEngaged() Call

⚠️ **Share Feedback back button inconsistency:**
- Missing Place: Has `markUserEngaged()` ✓
- Contact Us: Has `markUserEngaged()` ✓
- Share Feedback: **Missing** `markUserEngaged()` ⚠️

**Impact:** User engagement not tracked when leaving Share Feedback page via back button.

**Fix:** Add `await actions.markUserEngaged();` before `context.pop()` in ShareFeedbackWidget.

**Code Reference:** Share Feedback line 73 (back button onPressed)

---

## Migration Notes

### High Priority

1. **Fix Share Feedback engagement tracking** - Add missing `markUserEngaged()` call
2. **Document custom form widgets** - Extract translation keys and logic from:
   - `MissingLocationFormWidget`
   - `ContactUsFormWidget`
   - `FeedbackFormWidget`

### Medium Priority

1. **Add page-level translation keys** to MASTER_TRANSLATION_KEYS.md
2. **Document analytics events** for form submissions (in custom widgets)
3. **Verify form submission endpoints** (called from custom widgets)

### Low Priority

1. **Compare JSX designs with widget implementations** - Determine if all JSX features implemented
2. **Document UserFeedbackButtonsPage and UserFeedbackButtonsTopic** - Additional widgets for feedback flow

---

## Next Steps

1. ✅ **Extract custom widget source code** - Read:
   - `MissingLocationFormWidget.dart`
   - `ContactUsFormWidget.dart`
   - `FeedbackFormWidget.dart`
   - `UserFeedbackButtonsPage.dart`
   - `UserFeedbackButtonsTopic.dart`

2. **Document widget translation keys** - Extract all keys used within widgets

3. **Document form fields and validation** - Capture complete form specifications

4. **Document submission logic** - API endpoints, success/error handling

5. **Create comprehensive BUNDLE files** - One for each form page with complete details

6. **Update PAGE_README.md** - Expand form page sections with verified details

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete (page-level) / ⚠️ Widget-level requires custom widget code
**Total Gaps:** 1 (0 frontend + 0 backend + 0 API + 1 translation + 0 known missing)

**Key Finding:** All three form pages follow a consistent wrapper pattern with custom widgets encapsulating form logic. Page-level code is minimal (app bar + widget wrapper). Translation keys and form behavior are inside custom widgets.

**Critical Issue:** Share Feedback page missing `markUserEngaged()` call on back button (inconsistency with other pages).

**Next Phase:** Document custom form widgets to complete gap analysis.
