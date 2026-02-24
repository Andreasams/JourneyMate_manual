# ContactUsFormWidget — Master Documentation

**Custom Widget Type:** Form UI Component
**FlutterFlow Source:** `_flutterflow_export/lib/custom_code/widgets/contact_us_form_widget.dart`
**Used On:** Contact Us Settings page
**Purpose:** Provides a complete contact form interface for users to submit inquiries to JourneyMate support with validation, API submission, and success/error state handling.

---

## Purpose

The ContactUsFormWidget is a **stateful custom widget** that renders a multi-field contact form with:

1. **Four input fields**: Name, Contact (email/phone), Subject, and Message
2. **Client-side validation** for required fields and minimum message length
3. **API submission** to BuildShip endpoint (`https://wvb8ww.buildship.run/contact`)
4. **Translation support** for all UI text across multiple languages
5. **State management** for loading, success, and error states
6. **User engagement tracking** via `markUserEngaged()` action

This widget handles the entire form lifecycle: display → validation → submission → feedback, making it a self-contained contact solution requiring only language and translation parameters.

---

## Function Signature

```dart
class ContactUsFormWidget extends StatefulWidget {
  const ContactUsFormWidget({
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

  @override
  State<ContactUsFormWidget> createState() => _ContactUsFormWidgetState();
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Purpose | Source |
|-----------|------|---------|--------|
| `currentLanguage` | `String` | Current app language code (e.g., 'en', 'da', 'de') | `FFLocalizations.of(context).languageCode` |
| `translationsCache` | `dynamic` | Cached translations map from FFAppState | `FFAppState().translationsCache` |

### Optional Parameters

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| `width` | `double?` | `null` | Widget width constraint (typically `double.infinity`) |
| `height` | `double?` | `null` | Widget height constraint (typically screen height) |

**Note:** While `width` and `height` are optional in the signature, they are always provided in practice to ensure proper layout within the parent container.

---

## Dependencies

### FlutterFlow Imports
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Core Dependencies
```dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
```

### Custom Functions Used

| Function | Purpose | Usage |
|----------|---------|-------|
| `getTranslations()` | Retrieves translated text for a given key | Used by `_getUIText()` helper method |
| `markUserEngaged()` | Tracks user interaction analytics | Called when submit button is pressed |

**Custom Functions Location:** `/flutter_flow/custom_functions.dart`
**Custom Actions Location:** `/custom_code/actions/index.dart`

---

## FFAppState Usage

### Read Operations

| State Variable | Type | Usage | Access Pattern |
|----------------|------|-------|----------------|
| `translationsCache` | `dynamic` | Stores all translation strings for the app | Passed as widget parameter, used in `_getUIText()` |

**Important:** This widget does **NOT** write to FFAppState. It is a pure display/interaction widget that submits data to an external API.

---

## Form Fields

### Field Structure

The form contains **four required fields**, each with validation:

#### 1. Name Field

```dart
TextEditingController _nameController = TextEditingController();
String? _nameError;
```

**Validation Rules:**
- Must not be empty (trimmed)
- Error message: `contact_form_error_name_required`

**UI Specification:**
- Max lines: 1 (single-line input)
- Hint text: `contact_form_hint_name`
- Title: `contact_form_title_name` (with required asterisk)

---

#### 2. Contact Field (Email or Phone)

```dart
TextEditingController _contactController = TextEditingController();
String? _contactError;
```

**Validation Rules:**
- Must not be empty (trimmed)
- **No format validation** (accepts any non-empty string)
- Error message: `contact_form_error_contact_required`

**UI Specification:**
- Max lines: 1 (single-line input)
- Subtitle: `contact_form_subtitle_contact` (explains email or phone)
- Hint text: `contact_form_hint_contact`
- Title: `contact_form_title_contact` (with required asterisk)

**Note:** The field name is "contact" rather than "email" to support both email addresses and phone numbers. The subtitle explains this to users.

---

#### 3. Subject Field

```dart
TextEditingController _subjectController = TextEditingController();
String? _subjectError;
```

**Validation Rules:**
- Must not be empty (trimmed)
- Error message: `contact_form_error_subject_required`

**UI Specification:**
- Max lines: 1 (single-line input)
- Subtitle: `contact_form_subtitle_subject` (explains purpose)
- Hint text: `contact_form_hint_subject`
- Title: `contact_form_title_subject` (with required asterisk)

---

#### 4. Message Field

```dart
TextEditingController _messageController = TextEditingController();
String? _messageError;
```

**Validation Rules:**
- Must not be empty (trimmed)
- Must be at least 10 characters long
- Error messages:
  - Empty: `contact_form_error_message_required`
  - Too short: `contact_form_error_message_too_short`

**UI Specification:**
- Max lines: 6 (multi-line textarea)
- Subtitle: `contact_form_subtitle_message` (explains detail level)
- Hint text: `contact_form_hint_message`
- Title: `contact_form_title_message` (with required asterisk)

---

## Validation Logic

### Client-Side Validation Method

```dart
bool _validateForm() {
  bool isValid = true;

  setState(() {
    // Clear all previous errors
    _nameError = null;
    _contactError = null;
    _subjectError = null;
    _messageError = null;

    // Validate name
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _nameError = _getUIText('contact_form_error_name_required');
      isValid = false;
    }

    // Validate contact
    final contact = _contactController.text.trim();
    if (contact.isEmpty) {
      _contactError = _getUIText('contact_form_error_contact_required');
      isValid = false;
    }

    // Validate subject
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) {
      _subjectError = _getUIText('contact_form_error_subject_required');
      isValid = false;
    }

    // Validate message
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _messageError = _getUIText('contact_form_error_message_required');
      isValid = false;
    } else if (message.length < 10) {
      _messageError = _getUIText('contact_form_error_message_too_short');
      isValid = false;
    }
  });

  return isValid;
}
```

### Inline Error Clearing

Each text field has an `onChanged` handler that clears its error state when the user starts typing:

```dart
onChanged: (_) {
  if (errorText != null) {
    setState(() {
      if (controller == _nameController) {
        _nameError = null;
      } else if (controller == _contactController) {
        _contactError = null;
      } else if (controller == _subjectController) {
        _subjectError = null;
      } else if (controller == _messageController) {
        _messageError = null;
      }
    });
  }
},
```

**User Experience:** Errors disappear as soon as the user begins correcting them, providing immediate feedback without requiring resubmission.

---

## API Integration

### Endpoint Configuration

```dart
static const String _apiEndpoint = 'https://wvb8ww.buildship.run/contact';
```

**BuildShip Endpoint:** `/contact`
**Method:** POST
**Content-Type:** `application/json`

---

### Request Structure

```dart
final requestBody = {
  'name': _nameController.text.trim(),
  'contact': _contactController.text.trim(),
  'subject': _subjectController.text.trim(),
  'message': _messageController.text.trim(),
  'languageCode': widget.currentLanguage,
};
```

**Request Body Fields:**

| Field | Type | Source | Purpose |
|-------|------|--------|---------|
| `name` | `String` | Name field (trimmed) | User's full name |
| `contact` | `String` | Contact field (trimmed) | User's email or phone |
| `subject` | `String` | Subject field (trimmed) | Inquiry subject line |
| `message` | `String` | Message field (trimmed) | Full message body |
| `languageCode` | `String` | `widget.currentLanguage` | User's language for response routing |

---

### Response Handling

#### Success Response (200)

```dart
if (response.statusCode == 200) {
  final responseData = jsonDecode(response.body);
  if (responseData['success'] == true) {
    return; // Success
  } else {
    throw Exception(responseData['error'] ?? 'Unknown error occurred');
  }
}
```

**Expected Success Response:**
```json
{
  "success": true
}
```

---

#### Error Response (Non-200)

```dart
else {
  final errorData = jsonDecode(response.body);
  throw Exception(errorData['error'] ?? 'Failed to submit contact form');
}
```

**Expected Error Response:**
```json
{
  "error": "Error description here"
}
```

---

### Submission Flow

```dart
Future<void> _handleSubmit() async {
  markUserEngaged(); // Track user interaction

  if (_isSubmitting) return; // Prevent double-submission

  if (!_validateForm()) {
    return; // Show validation errors, don't submit
  }

  setState(() {
    _isSubmitting = true;
    _submissionError = null;
  });

  try {
    await _submitToAPI();

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true; // Show success message
      });
    }
  } catch (error) {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submissionError = error.toString(); // Show error message
      });
    }
  }
}
```

**State Flow:**
1. **Idle** → User clicks submit
2. **Validating** → `_validateForm()` checks all fields
3. **Submitting** → `_isSubmitting = true`, show loading spinner
4. **Success** → `_isSubmitted = true`, show success message
5. **Error** → `_submissionError` set, show error message with retry button

---

## Translation Support

### Translation Keys

The widget uses **20 translation keys** for complete internationalization:

#### Main Section
- `contact_form_title_main` — Main page title (e.g., "How can we help you?")
- `contact_form_subtitle_main` — Main page subtitle/description

#### Field Titles (all with required asterisk)
- `contact_form_title_name` — "Your name"
- `contact_form_title_contact` — "Contact information"
- `contact_form_title_subject` — "Subject"
- `contact_form_title_message` — "Your message"

#### Field Subtitles
- `contact_form_subtitle_contact` — "Email address or phone number"
- `contact_form_subtitle_subject` — "Brief description of your inquiry"
- `contact_form_subtitle_message` — "Please provide details about your inquiry"

#### Field Hints (placeholder text)
- `contact_form_hint_name` — e.g., "John Doe"
- `contact_form_hint_contact` — e.g., "email@example.com or +45 12 34 56 78"
- `contact_form_hint_subject` — e.g., "Problem with restaurant information"
- `contact_form_hint_message` — e.g., "Describe your issue in detail..."

#### Validation Errors
- `contact_form_error_name_required` — "Name is required"
- `contact_form_error_contact_required` — "Contact information is required"
- `contact_form_error_subject_required` — "Subject is required"
- `contact_form_error_message_required` — "Message is required"
- `contact_form_error_message_too_short` — "Message must be at least 10 characters"

#### Submission Feedback
- `contact_form_button_submit` — "Send message"
- `contact_form_success_message` — "Thank you! Your message has been sent."
- `contact_form_success_navigate_away` — "You can now navigate away from this page."
- `contact_form_error_submission` — "Failed to send message. Please try again."

---

### Translation Helper Method

```dart
String _getUIText(String key) {
  return getTranslations(
    widget.currentLanguage,
    key,
    widget.translationsCache,
  );
}
```

**Purpose:** Simplifies translation lookups throughout the widget code.

**Note:** The `getTranslations()` function is a global custom function that retrieves translated strings from the `translationsCache` based on the current language code and translation key.

---

## State Management

### State Variables

| Variable | Type | Initial Value | Purpose |
|----------|------|---------------|---------|
| `_nameController` | `TextEditingController` | Empty | Controls name field input |
| `_contactController` | `TextEditingController` | Empty | Controls contact field input |
| `_subjectController` | `TextEditingController` | Empty | Controls subject field input |
| `_messageController` | `TextEditingController` | Empty | Controls message field input |
| `_nameError` | `String?` | `null` | Error message for name field |
| `_contactError` | `String?` | `null` | Error message for contact field |
| `_subjectError` | `String?` | `null` | Error message for subject field |
| `_messageError` | `String?` | `null` | Error message for message field |
| `_isSubmitting` | `bool` | `false` | Loading state during API call |
| `_isSubmitted` | `bool` | `false` | Success state after submission |
| `_submissionError` | `String?` | `null` | Error message from API call |

---

### State Lifecycle

#### Widget Update Detection

```dart
@override
void didUpdateWidget(ContactUsFormWidget oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.currentLanguage != oldWidget.currentLanguage) {
    setState(() {}); // Rebuild UI with new translations
  }
}
```

**Purpose:** Automatically updates all UI text when the user changes language or translations are refreshed.

---

#### Resource Cleanup

```dart
@override
void dispose() {
  _nameController.dispose();
  _contactController.dispose();
  _subjectController.dispose();
  _messageController.dispose();
  super.dispose();
}
```

**Purpose:** Prevents memory leaks by disposing all text controllers when the widget is removed.

---

## UI Components

### Layout Structure

```dart
Widget build(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 140.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildIntroductionSection(),
        const SizedBox(height: 24.0),
        _buildNameSection(),
        const SizedBox(height: 24.0),
        _buildContactSection(),
        const SizedBox(height: 24.0),
        _buildSubjectSection(),
        const SizedBox(height: 24.0),
        _buildMessageSection(),
        const SizedBox(height: 40.0),
        _buildSubmitArea(),
      ],
    ),
  );
}
```

**Layout Notes:**
- Bottom padding: 140px (prevents submit button from being hidden by bottom navigation)
- Section spacing: 24px between all sections
- Submit button top margin: 40px (creates visual separation)

---

### Design Constants

#### Colors

```dart
static const Color _titleColor = Color(0xFF14181B);          // Dark gray for titles
static const Color _subtitleColor = Color(0xFF14181B);       // Dark gray for subtitles
static const Color _textFieldBackground = Color(0xFFF2F3F5); // Light gray for inputs
static const Color _submitButtonColor = Color(0xFFE9874B);   // Orange (JourneyMate brand)
static const Color _submitButtonTextColor = Colors.white;    // White button text
static const Color _errorColor = Colors.red;                 // Standard red for errors
static const Color _successColor = Color(0xFF249689);        // Teal for success
```

**Design System Alignment:**
- Button color (`#E9874B`) aligns with JourneyMate's orange accent color
- Success color (`#249689`) provides clear visual differentiation from errors
- Text field background (`#F2F3F5`) matches standard input styling across the app

---

#### Typography

```dart
static const double _mainTitleFontSize = 20.0;
static const double _titleFontSize = 18.0;
static const double _subtitleFontSize = 15.0;
static const double _submitButtonFontSize = 16.0;
static const double _textFieldFontSize = 14.0;

static const FontWeight _titleFontWeight = FontWeight.w500;
static const FontWeight _subtitleFontWeight = FontWeight.w300;
static const FontWeight _submitButtonFontWeight = FontWeight.w500;
```

**Typography Hierarchy:**
1. Main title (20px, w500) — Most prominent
2. Field titles (18px, w500) — Clear section headers
3. Button text (16px, w500) — Actionable emphasis
4. Subtitles (15px, w300) — Supporting information
5. Text fields (14px, default weight) — Input text

---

#### Spacing & Dimensions

```dart
static const double _submitButtonWidth = 200.0;
static const double _submitButtonHeight = 40.0;
static const double _submitButtonRadius = 8.0;
static const double _submitButtonPadding = 16.0;
static const double _submitButtonTopMargin = 40.0;

static const double _sectionSpacing = 24.0;
static const double _fieldSpacing = 8.0;
static const double _subtitleToFieldSpacing = 6.0;
static const double _textFieldBorderRadius = 8.0;
static const double _textFieldPadding = 12.0;
static const double _bottomPadding = 140.0;
```

---

### Text Field Component

```dart
Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required int maxLines,
  String? errorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontSize: 14.0),
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Color(0xFFF2F3F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(12.0),
          errorBorder: errorText != null
              ? OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.red, width: 1),
                )
              : null,
        ),
        onChanged: (_) {
          if (errorText != null) {
            // Clear error when user starts typing
            setState(() { /* ... */ });
          }
        },
      ),
      if (errorText != null)
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
    ],
  );
}
```

**Features:**
- Filled background (no border by default)
- Red border appears when error is present
- Error text displays below field with 4px spacing
- Error auto-clears when user types

---

### Submit Area States

The submit area dynamically renders based on submission state:

#### 1. Default State (Submit Button)

```dart
Widget _buildSubmitButton() {
  return Center(
    child: SizedBox(
      width: 200.0,
      height: 40.0,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        // ... styling ...
        child: _isSubmitting
            ? CircularProgressIndicator(/* ... */)
            : Text(_getUIText('contact_form_button_submit')),
      ),
    ),
  );
}
```

**States:**
- **Enabled:** Orange button with "Send message" text
- **Loading:** Disabled button (50% opacity) with white spinner

---

#### 2. Success State

```dart
Widget _buildSuccessMessage() {
  return Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Color(0xFF249689).withOpacity(0.1), // Light teal background
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Color(0xFF249689), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: Color(0xFF249689), size: 32),
          const SizedBox(height: 8),
          Text(_getUIText('contact_form_success_message'), /* ... */),
          const SizedBox(height: 4),
          Text(_getUIText('contact_form_success_navigate_away'), /* ... */),
        ],
      ),
    ),
  );
}
```

**Visual Design:**
- Teal check icon (32px)
- Teal border and light teal background
- Two-line message: main success text + navigation instruction

---

#### 3. Error State

```dart
Widget _buildErrorMessage() {
  return Center(
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1), // Light red background
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(color: Colors.red, width: 1),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              Text(_getUIText('contact_form_error_submission'), /* ... */),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSubmitButton(), // Retry button
      ],
    ),
  );
}
```

**Visual Design:**
- Red error icon (32px)
- Red border and light red background
- Error message text
- Submit button appears below for retry

---

## Analytics Tracking

### User Engagement Event

```dart
Future<void> _handleSubmit() async {
  markUserEngaged(); // Called immediately when submit button is pressed

  // ... validation and submission logic ...
}
```

**Tracked Action:** `markUserEngaged()`
**Timing:** Fires **before** form validation
**Purpose:** Records that the user actively engaged with the contact form, regardless of validation outcome

**Note:** The `markUserEngaged()` custom action updates user engagement metrics and is used across the app to track active usage patterns.

---

## Usage Examples

### Example 1: Basic Implementation (Contact Us Page)

```dart
// From: _flutterflow_export/lib/app_settings/contact_us/contact_us_widget.dart

Container(
  width: double.infinity,
  height: MediaQuery.sizeOf(context).height,
  child: custom_widgets.ContactUsFormWidget(
    width: double.infinity,
    height: MediaQuery.sizeOf(context).height,
    currentLanguage: FFLocalizations.of(context).languageCode,
    translationsCache: FFAppState().translationsCache,
  ),
)
```

**Context:** This is the only usage of ContactUsFormWidget in the codebase, embedded in the Contact Us settings page.

**Page Structure:**
- App bar with "Contact us" title and back button
- Full-screen scrollable area containing the form widget
- No additional UI elements (form is self-contained)

---

### Example 2: Page Analytics Integration

```dart
// Parent page (_ContactUsWidgetState) tracking:

@override
void initState() {
  super.initState();
  _model = createModel(context, () => ContactUsModel());

  SchedulerBinding.instance.addPostFrameCallback((_) async {
    _model.pageStartTime = getCurrentTimestamp;
    safeSetState(() {});
  });
}

@override
void dispose() {
  () async {
    await actions.trackAnalyticsEvent(
      'page_viewed',
      <String, String>{
        'pageName': 'contactUsSettings',
        'durationSeconds': functions
            .getSessionDurationSeconds(_model.pageStartTime!)
            .toString(),
      },
    );
  }();

  _model.dispose();
  super.dispose();
}
```

**Analytics Events:**
- **Page View Event:** `page_viewed` with `pageName: 'contactUsSettings'`
- **Duration Tracking:** Measures time spent on contact form page
- **User Engagement:** Tracked when submit button is pressed (inside widget)

---

## Error Handling

### Client-Side Validation Errors

**When Triggered:** User attempts to submit form with invalid/missing data

**Error Display:**
- Red border appears on invalid field(s)
- Error text displays below affected field(s)
- All errors shown simultaneously (not one-at-a-time)

**Error Recovery:**
- Errors clear as soon as user begins typing in the field
- No need to resubmit to clear errors

---

### API Submission Errors

**When Triggered:** Network failure or server error during submission

**Error Types:**

1. **Network Timeout/Connection Error**
   ```dart
   catch (error) {
     setState(() {
       _submissionError = error.toString(); // e.g., "SocketException: ..."
     });
   }
   ```

2. **Server Error (Non-200 Response)**
   ```dart
   throw Exception(errorData['error'] ?? 'Failed to submit contact form');
   ```

3. **Success=False Response (200 but error in body)**
   ```dart
   throw Exception(responseData['error'] ?? 'Unknown error occurred');
   ```

**Error Display:**
- Red error box with error icon
- Generic error message from translation key
- Submit button reappears for retry
- Form data remains intact (not cleared)

---

### Edge Cases Handled

#### 1. Double-Submission Prevention

```dart
if (_isSubmitting) return; // Early exit if already submitting
```

**Protection:** Button is disabled during submission, and code checks `_isSubmitting` flag to prevent concurrent requests.

---

#### 2. Widget Unmount During API Call

```dart
if (mounted) {
  setState(() {
    _isSubmitting = false;
    _isSubmitted = true;
  });
}
```

**Protection:** Always checks `mounted` before calling `setState()` after async operations to prevent "setState called after dispose" errors.

---

#### 3. Translation Cache Updates

```dart
@override
void didUpdateWidget(ContactUsFormWidget oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.currentLanguage != oldWidget.currentLanguage) {
    setState(() {}); // Rebuild with new translations
  }
}
```

**Protection:** Automatically rebuilds UI when translations change (e.g., user switches language while form is open).

---

## Testing Checklist

### Functional Tests

- [ ] **Form displays correctly** with all four fields visible
- [ ] **Translation keys load** for all UI text in all supported languages
- [ ] **Name validation** shows error when empty, clears when valid
- [ ] **Contact validation** shows error when empty, clears when valid
- [ ] **Subject validation** shows error when empty, clears when valid
- [ ] **Message validation** shows error when empty
- [ ] **Message length validation** shows error when < 10 characters
- [ ] **Multiple validation errors** display simultaneously
- [ ] **Inline error clearing** removes errors when user types
- [ ] **Submit button disabled** during submission
- [ ] **Loading spinner** appears during API call
- [ ] **Success state** displays after successful submission
- [ ] **Error state** displays after failed submission
- [ ] **Retry functionality** works after error (button reappears)
- [ ] **Form data persists** after validation failure or submission error
- [ ] **Double-submission prevented** (button disabled during loading)
- [ ] **User engagement tracked** when submit button pressed
- [ ] **Resource cleanup** (controllers disposed on widget disposal)

---

### API Integration Tests

- [ ] **API endpoint reachable** (`https://wvb8ww.buildship.run/contact`)
- [ ] **Request body structure** matches expected format
- [ ] **Language code included** in request body
- [ ] **200 response with success=true** triggers success state
- [ ] **200 response with success=false** triggers error state with message
- [ ] **Non-200 response** triggers error state with fallback message
- [ ] **Network timeout** handled gracefully
- [ ] **Connection failure** handled gracefully

---

### UI/UX Tests

- [ ] **Form scrollable** when keyboard appears
- [ ] **Submit button visible** (not hidden behind keyboard or nav bar)
- [ ] **Bottom padding sufficient** (140px prevents nav bar overlap)
- [ ] **Field focus behavior** correct (keyboard opens, field scrolls into view)
- [ ] **Tap outside dismisses keyboard** (handled by parent page)
- [ ] **Required asterisks** appear on all field titles
- [ ] **Subtitle text** appears for Contact, Subject, and Message fields
- [ ] **Hint text** displays in all fields
- [ ] **Error text styling** matches design (12px, red)
- [ ] **Success message styling** matches design (teal border/icon)
- [ ] **Error message styling** matches design (red border/icon)
- [ ] **Button styling** matches JourneyMate brand (orange)
- [ ] **Disabled button opacity** correct (50%)

---

### Translation Tests

For each supported language (EN, DA, DE, etc.):

- [ ] **All 20 translation keys** load correctly
- [ ] **Main title and subtitle** display properly
- [ ] **Field titles** all translated
- [ ] **Field subtitles** all translated
- [ ] **Hint texts** all translated
- [ ] **Validation errors** all translated
- [ ] **Button text** translated
- [ ] **Success message** translated
- [ ] **Error message** translated
- [ ] **Language switch mid-session** updates all text without requiring restart

---

### Edge Case Tests

- [ ] **Empty form submission** shows all four validation errors
- [ ] **Partial form submission** shows only missing field errors
- [ ] **Message with 9 characters** shows "too short" error
- [ ] **Message with 10 characters** passes validation
- [ ] **Whitespace-only input** treated as empty (trimmed)
- [ ] **Very long input** doesn't break layout
- [ ] **Special characters** in fields handled correctly
- [ ] **Language switch while form filled** preserves field values
- [ ] **Back navigation during submission** cancels request gracefully
- [ ] **App backgrounded during submission** resumes correctly

---

## Migration Notes (Phase 3)

### Current Implementation Pattern

**State Management:** Local `StatefulWidget` with private state variables
**Translation Access:** Direct FFAppState access via widget parameters
**API Calls:** Direct `http.post()` calls with manual JSON encoding

---

### Required Changes for Phase 3

#### 1. State Management Migration (Riverpod)

**Current:**
```dart
class ContactUsFormWidget extends StatefulWidget {
  final String currentLanguage;
  final dynamic translationsCache;
  // ...
}
```

**Phase 3:**
```dart
class ContactUsFormWidget extends ConsumerStatefulWidget {
  // Remove translationsCache parameter
  const ContactUsFormWidget({super.key, this.width, this.height});

  // currentLanguage accessed via Riverpod provider
}
```

**Changes Required:**
- Convert to `ConsumerStatefulWidget`
- Remove `currentLanguage` and `translationsCache` parameters
- Access translations via `ref.watch(translationsProvider)`
- Access current language via `ref.watch(languageProvider)`
- Update `_getUIText()` to use provider instead of parameters

---

#### 2. Translation System Integration

**Current:**
```dart
String _getUIText(String key) {
  return getTranslations(
    widget.currentLanguage,
    key,
    widget.translationsCache,
  );
}
```

**Phase 3:**
```dart
String _getUIText(String key, WidgetRef ref) {
  final translations = ref.watch(translationsProvider);
  final language = ref.watch(languageProvider);
  return translations.getText(language, key);
}
```

**Changes Required:**
- Replace global `getTranslations()` function with provider-based system
- Pass `WidgetRef` to all methods that need translations
- Remove dependency on `widget.currentLanguage` and `widget.translationsCache`

---

#### 3. API Service Layer

**Current:**
```dart
Future<void> _submitToAPI() async {
  final response = await http.post(
    Uri.parse('https://wvb8ww.buildship.run/contact'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );
  // ... manual response parsing ...
}
```

**Phase 3:**
```dart
Future<void> _submitToAPI() async {
  final apiService = ref.read(apiServiceProvider);
  await apiService.submitContactForm(
    name: _nameController.text.trim(),
    contact: _contactController.text.trim(),
    subject: _subjectController.text.trim(),
    message: _messageController.text.trim(),
    languageCode: ref.read(languageProvider),
  );
}
```

**Changes Required:**
- Create `ContactFormService` or add method to existing `ApiService`
- Move endpoint URL to service configuration
- Move request/response handling to service layer
- Widget only handles UI state, service handles API communication

---

#### 4. Custom Actions Migration

**Current:**
```dart
markUserEngaged(); // Global custom action
```

**Phase 3:**
```dart
await ref.read(analyticsServiceProvider).markUserEngaged();
```

**Changes Required:**
- Convert `markUserEngaged()` to method on `AnalyticsService`
- Access via Riverpod provider instead of global function
- Make async/await explicit

---

#### 5. Parent Page Integration Changes

**Current Usage:**
```dart
custom_widgets.ContactUsFormWidget(
  width: double.infinity,
  height: MediaQuery.sizeOf(context).height,
  currentLanguage: FFLocalizations.of(context).languageCode,
  translationsCache: FFAppState().translationsCache,
)
```

**Phase 3 Usage:**
```dart
ContactUsFormWidget(
  width: double.infinity,
  height: MediaQuery.sizeOf(context).height,
)
```

**Changes Required:**
- Remove `currentLanguage` parameter
- Remove `translationsCache` parameter
- Widget self-manages language/translation access via providers

---

### Testing Requirements for Phase 3 Migration

- [ ] **Riverpod providers** correctly supply language and translations
- [ ] **Translation updates** trigger widget rebuild when language changes
- [ ] **API service** correctly handles all request/response scenarios
- [ ] **Analytics service** records user engagement
- [ ] **Provider disposal** doesn't cause memory leaks
- [ ] **Hot reload** preserves form state during development
- [ ] **Error handling** still works with service layer abstraction
- [ ] **All existing functional tests pass** after migration

---

### Breaking Changes Summary

| Current | Phase 3 | Impact |
|---------|---------|--------|
| `StatefulWidget` | `ConsumerStatefulWidget` | Add Riverpod dependency |
| `currentLanguage` parameter | `languageProvider` | Remove parameter from constructor |
| `translationsCache` parameter | `translationsProvider` | Remove parameter from constructor |
| `getTranslations()` function | `translations.getText()` | Change function call signature |
| `markUserEngaged()` function | `analyticsService.markUserEngaged()` | Change to async method call |
| Direct `http.post()` | `apiService.submitContactForm()` | Move API logic to service layer |

---

## Design System Notes

### Color Usage Compliance

- **Orange (`#E9874B`):** Used for submit button (interactive element) ✓
- **Teal (`#249689`):** Used for success state (not green `#1a9456`, intentional choice for this context) ✓
- **Red (`#FF0000`):** Used for validation errors ✓
- **Dark Gray (`#14181B`):** Used for titles and body text ✓
- **Light Gray (`#F2F3F5`):** Used for input field backgrounds ✓

**No design system violations detected.**

---

### Typography Compliance

- **Title weight (500):** Maps to `FontWeight.w500` ✓
- **Subtitle weight (300):** Maps to `FontWeight.w300` ✓
- **Button weight (500):** Maps to `FontWeight.w500` ✓

**All font weights align with JourneyMate design system.**

---

### Spacing Compliance

- **Section spacing (24px):** Consistent vertical rhythm ✓
- **Bottom padding (140px):** Prevents overlap with bottom navigation ✓
- **Field spacing (8px):** Standard input group spacing ✓

**All spacing values follow established patterns.**

---

## Known Limitations

1. **No email format validation:** Contact field accepts any non-empty string. Consider adding regex validation for email/phone formats in future versions.

2. **No "clear form" button:** After submission success, user must navigate away to clear form. Could add a "Submit another" button that resets state.

3. **No character counter:** Message field has minimum length (10 chars) but no visual indicator. Consider adding counter for better UX.

4. **No autofill support:** Fields don't support browser/OS autofill. Could add `autofillHints` to text fields.

5. **No file attachment support:** Contact form is text-only. Users cannot attach screenshots or documents.

6. **Generic error messages:** API errors don't provide specific guidance. Could enhance error messages based on error type.

---

## Related Files

- **Parent Page:** `_flutterflow_export/lib/app_settings/contact_us/contact_us_widget.dart`
- **Page Model:** `_flutterflow_export/lib/app_settings/contact_us/contact_us_model.dart`
- **Custom Actions:** `_flutterflow_export/lib/custom_code/actions/index.dart`
- **Custom Functions:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart`
- **Widget Export:** `_flutterflow_export/lib/custom_code/widgets/index.dart`

---

## Conclusion

The ContactUsFormWidget is a **production-ready, self-contained form component** that handles the complete contact form lifecycle from validation to API submission. Its key strengths are:

1. **Complete translation support** for international users
2. **Robust validation** with inline error clearing
3. **Clear state management** for loading, success, and error states
4. **User engagement tracking** via analytics
5. **Defensive error handling** for network/API failures
6. **Clean separation of concerns** (UI, validation, API)

The widget is **ready for Phase 3 migration** to Riverpod with clear migration paths documented above. The primary changes will be removing parameter dependencies and accessing state via providers instead.

---

**Documentation Version:** 1.0
**Last Updated:** 2026-02-19
**Status:** Complete and ready for Phase 3 migration
