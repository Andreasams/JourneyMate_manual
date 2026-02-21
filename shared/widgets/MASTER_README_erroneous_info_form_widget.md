# ErroneousInfoFormWidget

**Custom Widget | FlutterFlow Export**

A bottom sheet form that allows users to report incorrect or missing business information for the currently viewed business. Displays in a modal sheet with validation, submission handling, and success/error states.

---

## Purpose

The `ErroneousInfoFormWidget` provides a user-facing form for submitting corrections about business information (hours, address, menu items, etc.). It:

- Displays within a modal bottom sheet
- Shows the business name and address being reported
- Validates user input (minimum 10 characters)
- Submits reports to BuildShip API endpoint
- Shows loading, success, and error states
- Matches ItemDetailSheet visual style
- Tracks user engagement on submit and close

**Design Philosophy:** Styled consistently with `ItemDetailSheet` to provide visual continuity across the app's modal interfaces.

---

## Function Signature

```dart
class ErroneousInfoFormWidget extends StatefulWidget {
  const ErroneousInfoFormWidget({
    super.key,
    this.width,
    this.height,
    required this.currentLanguage,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final String currentLanguage;
  final dynamic translationsCache;
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `currentLanguage` | `String` | Current language code (e.g., 'en', 'da') for UI translations |
| `translationsCache` | `dynamic` (JSON) | Translation cache from FFAppState containing all UI text |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `double?` | `null` | Widget width (typically `double.infinity`) |
| `height` | `double?` | `null` | Widget height (typically `MediaQuery.sizeOf(context).height`) |

---

## Dependencies

### Flutter Packages
- `flutter/material.dart` - Core UI components
- `http` - API requests (`package:http/http.dart`)
- `dart:convert` - JSON encoding/decoding

### FlutterFlow Imports
- `/backend/schema/structs/index.dart` - Data structures
- `/backend/schema/enums/enums.dart` - Enum types
- `/backend/supabase/supabase.dart` - Database access
- `/flutter_flow/flutter_flow_theme.dart` - Theme system
- `/flutter_flow/flutter_flow_util.dart` - Utilities (including `markUserEngaged`)
- `/flutter_flow/custom_functions.dart` - Custom functions (including `getTranslations`)

### Custom Functions Used
- `getTranslations(languageCode, key, cache)` - Retrieves translated text
- `markUserEngaged()` - Updates last user interaction timestamp for analytics

---

## FFAppState Usage

### Read Access

| Field | Type | Usage |
|-------|------|-------|
| `mostRecentlyViewedBusiness` | `Map<String, dynamic>` | Source of business information being reported |
| `translationsCache` | `dynamic` (JSON) | Passed as parameter, used for all UI text |

### Business Data Structure

The widget reads from `FFAppState().mostRecentlyViewedBusiness`:

```dart
{
  'businessInfo': {
    'business_id': int,        // Used in API submission
    'business_name': String,   // Displayed to user
    'street': String,          // Displayed in address
    'postal_code': String,     // Displayed in address
    'postal_city': String      // Displayed in address
  }
}
```

**Critical:** Widget assumes `mostRecentlyViewedBusiness` is populated before display. Parent must ensure this state is set (typically by visiting Business Profile page first).

---

## Translation Keys

All UI text is retrieved via `getTranslations()` using these keys:

### Main Content
| Key | Purpose | Example Text |
|-----|---------|--------------|
| `erroneous_info_title_main` | Sheet title | "Report incorrect information" |
| `erroneous_info_subtitle_reporting_for` | Label above business name | "Reporting information for" |
| `erroneous_info_subtitle_main` | Help text explaining form | "Help us keep information accurate..." |

### Message Field
| Key | Purpose | Example Text |
|-----|---------|--------------|
| `erroneous_info_title_message` | Field label | "What information is incorrect?" |
| `erroneous_info_subtitle_message` | Field description | "Please describe what needs to be corrected" |
| `erroneous_info_hint_message` | Placeholder text | "E.g., 'Opening hours are wrong...'"|

### Validation Errors
| Key | Purpose | Example Text |
|-----|---------|--------------|
| `erroneous_info_error_message_required` | Empty field error | "Please describe what's incorrect" |
| `erroneous_info_error_message_too_short` | Length validation | "Please provide at least 10 characters" |

### Submission States
| Key | Purpose | Example Text |
|-----|---------|--------------|
| `erroneous_info_button_submit` | Submit button label | "Submit report" |
| `erroneous_info_error_submission` | API error message | "Failed to submit. Please try again." |
| `erroneous_info_success_message` | Success confirmation | "Thank you! We'll review your report." |
| `erroneous_info_success_navigate_away` | Post-success instruction | "You can close this sheet." |

### Parent Page Usage
| Key | Purpose | Example Text |
|-----|---------|--------------|
| `report_missing_or_erroneous_info` | Button text on Business Profile | "Report missing or incorrect information" |

---

## Analytics Tracking

### User Engagement Events

The widget calls `markUserEngaged()` on these actions:

| Action | Trigger | Purpose |
|--------|---------|---------|
| Submit report | `_handleSubmit()` called | Track form submission attempt |
| Close sheet | Close button tapped | Track sheet dismissal |

**Note:** No explicit `trackAnalyticsEvent()` calls exist in this widget. Only engagement timestamps are tracked via `markUserEngaged()`, which updates `SharedPreferences` for session analytics.

---

## Usage Examples

### Real-World Implementation (Business Profile Page)

**File:** `lib/profile/business_information/business_profile/business_profile_widget.dart`

```dart
// Button that opens the form
GestureDetector(
  onTap: () async {
    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: ModalSubmitErroneousInfoWidget(
              businessName: widget.businessName,
              businessID: widget.businessId,
            ),
          ),
        );
      },
    );
  },
  child: Text(
    functions.getTranslations(
      FFLocalizations.of(context).languageCode,
      'report_missing_or_erroneous_info',
      FFAppState().translationsCache
    ),
    style: FlutterFlowTheme.of(context).bodyMedium.override(
      fontFamily: 'Roboto',
      color: Color(0xFFE9874B),
      fontSize: 14.0,
    ),
  ),
)
```

### Wrapper Component (Modal Container)

**File:** `lib/profile/business_information/modal_submit_erroneous_info/modal_submit_erroneous_info_widget.dart`

```dart
class ModalSubmitErroneousInfoWidget extends StatefulWidget {
  const ModalSubmitErroneousInfoWidget({
    super.key,
    required this.businessName,
    required this.businessID,
  });

  final String? businessName;
  final int? businessID;

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height,
      child: custom_widgets.ErroneousInfoFormWidget(
        width: double.infinity,
        height: MediaQuery.sizeOf(context).height,
        currentLanguage: FFLocalizations.of(context).languageCode,
        translationsCache: FFAppState().translationsCache,
      ),
    );
  }
}
```

**Design Pattern:** The widget is wrapped in a modal-specific component that handles sizing and state watching. The custom widget itself is presentation-focused.

---

## State Management

### Local State Variables

| Variable | Type | Initial | Purpose |
|----------|------|---------|---------|
| `_messageController` | `TextEditingController` | `TextEditingController()` | Controls message text field |
| `_messageError` | `String?` | `null` | Validation error for message field |
| `_isSubmitting` | `bool` | `false` | Shows loading spinner during API call |
| `_isSubmitted` | `bool` | `false` | Triggers success message display |
| `_submissionError` | `String?` | `null` | Stores API error for user display |

### State Lifecycle

```
Initial State
  ↓
User types → Clear error on change (_messageError = null)
  ↓
User submits → Validate → _validateForm()
  ↓
Valid? → _isSubmitting = true → API call
  ↓
Success? → _isSubmitted = true (show success message)
  ↓
Error? → _submissionError = error.toString() (show error + retry)
```

---

## Validation Rules

### Message Field Validation

```dart
bool _validateForm() {
  final message = _messageController.text.trim();

  // Rule 1: Required field
  if (message.isEmpty) {
    _messageError = _getUIText('erroneous_info_error_message_required');
    return false;
  }

  // Rule 2: Minimum length
  if (message.length < 10) {
    _messageError = _getUIText('erroneous_info_error_message_too_short');
    return false;
  }

  return true;
}
```

**Validation Behavior:**
- Error shown on submit attempt
- Error cleared immediately on user typing
- Field border turns red when error exists
- Error text appears below field

---

## API Integration

### Endpoint

```
POST https://wvb8ww.buildship.run/erroneousinfo
Content-Type: application/json
```

### Request Body

```json
{
  "businessId": 12345,
  "businessName": "Restaurant Name",
  "message": "The opening hours are incorrect...",
  "languageCode": "en"
}
```

### Response Format

**Success (200):**
```json
{
  "success": true
}
```

**Error (4xx/5xx):**
```json
{
  "success": false,
  "error": "Error description"
}
```

### Error Handling

```dart
Future<void> _submitToAPI() async {
  final response = await http.post(
    Uri.parse(_apiEndpoint),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['success'] == true) {
      return; // Success
    } else {
      throw Exception(responseData['error'] ?? 'Unknown error occurred');
    }
  } else {
    final errorData = jsonDecode(response.body);
    throw Exception(
      errorData['error'] ?? 'Failed to submit erroneous info report'
    );
  }
}
```

**Error Display:** Exceptions are caught in `_handleSubmit()` and stored in `_submissionError`, which displays a user-friendly error banner above the submit button.

---

## Visual Design

### Layout Structure

```
┌─────────────────────────────────────────┐
│ ╌╌╌╌╌╌╌╌ (swipe bar)         [X]       │ ← Header (56px)
├─────────────────────────────────────────┤
│                                         │
│ Report incorrect information            │ ← Title (22px, w600)
│                                         │
│ Reporting information for               │ ← Subtitle (14px)
│ Restaurant Name                         │ ← Business name (16px, w500)
│ Street Address, 1234 City               │ ← Address (14px)
│                                         │
│ Help us keep information accurate...    │ ← Help text (14px, w300)
│                                         │
│ What information is incorrect? *        │ ← Field label (16px, w500)
│ Please describe what needs...           │ ← Field description
│ ┌─────────────────────────────────────┐ │
│ │ E.g., 'Opening hours are wrong...'  │ │ ← Text field (120-180px)
│ │                                     │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [     Submit report (or spinner)      ] │ ← Submit button (44px)
│                                         │
└─────────────────────────────────────────┘
```

### Color Palette

| Element | Color | Hex | Usage |
|---------|-------|-----|-------|
| Background | White | `#FFFFFF` | Sheet background |
| Swipe bar | Dark gray | `#14181B` | Top drag indicator |
| Close button bg | Light gray | `#F2F3F5` | Close button background |
| Close icon | Dark gray | `#14181B` | X icon color |
| Title text | Dark gray | `#14181B` | Main headings |
| Subtitle text | Medium gray | `#57636C` | Body text, labels |
| Text field bg | Light gray | `#F2F3F5` | Input background |
| Submit button | Orange | `#E9874B` | Primary action |
| Submit text | White | `#FFFFFF` | Button text |
| Error | Red | `#FF0000` | Validation errors |
| Success | Teal | `#249689` | Success confirmation |

### Typography

| Element | Size | Weight | Family |
|---------|------|--------|--------|
| Main title | 22px | 600 | Roboto |
| Section header | 16px | 500 | Roboto |
| Body text | 14px | 400 | Roboto |
| Light body | 14px | 300 | Roboto |
| Business name | 16px | 500 | Roboto |
| Button text | 16px | 500 | Roboto |

### Spacing Constants

| Constant | Value | Usage |
|----------|-------|-------|
| Sheet border radius | 20px | Top corners of sheet |
| Content padding | 28px | Horizontal margins |
| Section spacing | 20px | Between major sections |
| Small spacing | 4px | Tight vertical gaps |
| Medium spacing | 8px | Standard vertical gaps |
| Label-to-field | 8px | Space between label and input |

---

## Success State Behavior

When submission succeeds (`_isSubmitted = true`):

### Visual Changes

```dart
// Submit area is replaced with success message
Container(
  padding: EdgeInsets.all(16.0),
  decoration: BoxDecoration(
    color: Color(0xFF249689).withOpacity(0.1),  // Light teal background
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: Color(0xFF249689), width: 1),
  ),
  child: Column(
    children: [
      Icon(Icons.check_circle_outline, color: teal, size: 32),
      Text('erroneous_info_success_message'),
      Text('erroneous_info_success_navigate_away'),
    ],
  ),
)
```

### User Actions After Success

- User can close sheet manually (form data persists until close)
- No automatic dismissal (allows user to read confirmation)
- Sheet remains open for explicit dismissal

**Design Rationale:** Prevents accidental re-opening and gives users confirmation their report was received.

---

## Error Handling

### Validation Errors (Client-Side)

**Trigger:** Form submission with invalid input

**Display:**
- Red border around text field
- Error text below field (12px, red)
- Submit button remains enabled for retry

**Recovery:**
- Error clears on next keystroke
- User can immediately correct and resubmit

### Submission Errors (API Failures)

**Trigger:** HTTP error or API returns `success: false`

**Display:**
```dart
Container(
  padding: EdgeInsets.all(12.0),
  decoration: BoxDecoration(
    color: Colors.red.withOpacity(0.1),
    borderRadius: BorderRadius.circular(8.0),
    border: Border.all(color: Colors.red, width: 1),
  ),
  child: Row(
    children: [
      Icon(Icons.error_outline, color: red, size: 20),
      Text('erroneous_info_error_submission'),
    ],
  ),
)
```

**Recovery:**
- Error banner shows above submit button
- Submit button re-enabled for retry
- User can edit message and resubmit

### Edge Cases

| Scenario | Behavior |
|----------|----------|
| Network timeout | Exception caught → shows error banner |
| Invalid JSON response | Exception caught → shows error banner |
| Missing business data | Assumes `mostRecentlyViewedBusiness` exists (may crash if null) |
| Widget unmounted during API call | `if (mounted)` check prevents setState errors |

---

## Testing Checklist

### Unit Tests

- [ ] `_validateForm()` returns false for empty message
- [ ] `_validateForm()` returns false for message < 10 characters
- [ ] `_validateForm()` returns true for valid message
- [ ] `_getBusinessInfo()` extracts correct fields from FFAppState
- [ ] `_formatBusinessAddress()` formats address correctly
- [ ] `_getUIText()` calls getTranslations with correct parameters

### Widget Tests

- [ ] Widget builds successfully with valid parameters
- [ ] Title displays correct translation
- [ ] Business name displays from FFAppState
- [ ] Address formats correctly
- [ ] Text field accepts input
- [ ] Error message appears on empty submit
- [ ] Error clears on typing
- [ ] Submit button shows spinner during submission
- [ ] Success message replaces form on successful submit
- [ ] Error banner appears on API failure
- [ ] Close button dismisses sheet

### Integration Tests

- [ ] Modal opens from Business Profile page
- [ ] `mostRecentlyViewedBusiness` is populated before modal opens
- [ ] API submission succeeds with valid input
- [ ] API errors display user-friendly messages
- [ ] `markUserEngaged()` called on submit
- [ ] `markUserEngaged()` called on close
- [ ] Sheet dismisses on close button tap

### Visual Regression Tests

- [ ] Sheet matches ItemDetailSheet styling
- [ ] Text field height constrained (120-180px)
- [ ] Success state displays correctly
- [ ] Error state displays correctly
- [ ] Loading state displays spinner

### Accessibility Tests

- [ ] Screen reader announces form labels
- [ ] Error messages read by assistive tech
- [ ] Submit button disabled state communicated
- [ ] Success message announced
- [ ] Close button has semantic label

---

## Migration Notes (Phase 3)

### State Management Changes

**Current (FlutterFlow):**
```dart
final businessData = FFAppState().mostRecentlyViewedBusiness;
```

**Target (Riverpod):**
```dart
final businessData = ref.watch(currentBusinessProvider);
```

**Migration Task:** Replace direct FFAppState access with Riverpod provider.

### Translation System Changes

**Current (FlutterFlow):**
```dart
String _getUIText(String key) {
  return getTranslations(
    widget.currentLanguage,
    key,
    widget.translationsCache,
  );
}
```

**Target (Riverpod + l10n):**
```dart
String _getUIText(String key) {
  return context.l10n.translate(key);
}
```

**Migration Task:** Replace custom translation function with Flutter l10n system.

### API Integration Changes

**Current (http package):**
```dart
import 'package:http/http.dart' as http;

final response = await http.post(
  Uri.parse(_apiEndpoint),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(requestBody),
);
```

**Target (Dio + service layer):**
```dart
final response = await ref.read(apiServiceProvider)
  .submitErroneousInfoReport(requestBody);
```

**Migration Task:** Extract API call to dedicated service class with Dio-based HTTP client.

### User Engagement Tracking

**Current (Custom Action):**
```dart
markUserEngaged();
```

**Target (Analytics Service):**
```dart
ref.read(analyticsServiceProvider).trackEvent(
  'erroneous_info_form_interaction',
  parameters: {'action': 'submit'},
);
```

**Migration Task:** Replace engagement marker with proper analytics event tracking.

### Validation Enhancement

**Current:** Client-side validation only

**Recommended:** Add server-side validation feedback
```dart
// Handle specific API validation errors
if (responseData['validationErrors'] != null) {
  setState(() {
    _messageError = responseData['validationErrors']['message'];
  });
  return;
}
```

---

## Breaking Changes to Watch For

### FFAppState Structure Changes

If business data structure changes in Supabase:
```dart
// Current assumption
FFAppState().mostRecentlyViewedBusiness['businessInfo']['business_id']

// May need to adapt to new structure
FFAppState().currentBusiness.id
```

### Translation Key Naming

If translation keys are renamed during l10n migration, all 12 keys must be updated:
- `erroneous_info_title_main`
- `erroneous_info_subtitle_reporting_for`
- `erroneous_info_subtitle_main`
- `erroneous_info_title_message`
- `erroneous_info_subtitle_message`
- `erroneous_info_hint_message`
- `erroneous_info_error_message_required`
- `erroneous_info_error_message_too_short`
- `erroneous_info_button_submit`
- `erroneous_info_error_submission`
- `erroneous_info_success_message`
- `erroneous_info_success_navigate_away`

### API Endpoint Changes

If BuildShip endpoint changes or moves to different service:
```dart
// Update constant
static const String _apiEndpoint = 'NEW_ENDPOINT_URL';

// Verify request/response contract remains same
```

---

## Known Limitations

1. **Business Data Dependency:** Widget crashes if `mostRecentlyViewedBusiness` is null or malformed. Parent must ensure data exists before showing modal.

2. **No Offline Support:** API submission fails without network. No queuing or retry mechanism.

3. **No Character Limit:** Text field accepts unlimited input (may cause API issues if backend has limit).

4. **No Success Auto-Dismiss:** Sheet remains open after success, requiring manual close. May cause confusion if user doesn't notice success state.

5. **Generic Error Messages:** All API errors show same generic message (`erroneous_info_error_submission`), reducing debugging clarity.

6. **No Field-Specific Error Handling:** Server validation errors (if any) cannot be mapped to specific fields.

---

## Performance Considerations

### API Call Optimization

- Single HTTP POST (no multiple requests)
- Request body minimal (~200 bytes)
- No retry logic (user must manually retry)

### Widget Rebuild Optimization

```dart
@override
void didUpdateWidget(ErroneousInfoFormWidget oldWidget) {
  super.didUpdateWidget(oldWidget);

  // Only rebuild if translations or language changed
  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.currentLanguage != oldWidget.currentLanguage) {
    setState(() {});
  }
}
```

**Purpose:** Prevents unnecessary rebuilds when parent updates unrelated props.

### Text Field Performance

- Single controller (no multiple text fields)
- Error state updates only on validation attempt
- Clears error immediately on input (prevents repeated validation)

---

## Related Components

### Sibling Components (Similar Patterns)

| Component | Relationship | Shared Elements |
|-----------|-------------|-----------------|
| `ItemDetailSheet` | Visual style reference | Header design, colors, typography |
| `CategoryDescriptionSheet` | Modal pattern | Sheet layout, close button, swipe bar |
| `FilterDescriptionSheet` | Modal pattern | Bottom sheet container, padding |

### Parent Components

| Component | File | Invocation Context |
|-----------|------|-------------------|
| `ModalSubmitErroneousInfoWidget` | `modal_submit_erroneous_info_widget.dart` | Wrapper that handles sizing and state |
| `BusinessProfileWidget` | `business_profile_widget.dart` | Triggers modal on button tap |

### Supporting Services

| Service | Usage |
|---------|-------|
| `getTranslations()` | All UI text retrieval |
| `markUserEngaged()` | Engagement timestamp tracking |
| BuildShip API | Report submission endpoint |

---

## Implementation Checklist (Phase 3)

### Pre-Migration
- [ ] Audit all 12 translation keys exist in translations system
- [ ] Verify BuildShip endpoint accepts current request format
- [ ] Document expected API response formats
- [ ] Identify all pages that use this modal

### Migration Steps
- [ ] Create Riverpod provider for current business data
- [ ] Create API service method for report submission
- [ ] Replace FFAppState with provider
- [ ] Replace custom translations with l10n
- [ ] Replace http with Dio
- [ ] Add analytics event tracking
- [ ] Update wrapper component (ModalSubmitErroneousInfo)
- [ ] Update Business Profile page invocation

### Post-Migration
- [ ] Test validation edge cases
- [ ] Test API error scenarios
- [ ] Test success flow end-to-end
- [ ] Verify engagement tracking works
- [ ] Test with all supported languages
- [ ] Add offline handling (if required)
- [ ] Add character limit (if required)

---

## Additional Notes

### Design Consistency

This widget deliberately matches `ItemDetailSheet` styling to maintain visual coherence across modal interfaces. When updating design tokens, ensure both components stay aligned.

### Localization Testing

All 12 translation keys must be verified for:
- Correct key naming
- Appropriate text length (especially button text)
- Cultural appropriateness (error messages)
- Placeholder text clarity

### API Contract

The BuildShip endpoint expects exact field names:
- `businessId` (camelCase, not snake_case)
- `businessName` (camelCase)
- `message` (lowercase)
- `languageCode` (camelCase)

If backend changes naming convention, update `_submitToAPI()` request body mapping.

---

**Document Version:** 1.0
**Last Updated:** 2026-02-19
**Source File:** `lib/custom_code/widgets/erroneous_info_form_widget.dart`
**FlutterFlow Key:** `f09tg`
