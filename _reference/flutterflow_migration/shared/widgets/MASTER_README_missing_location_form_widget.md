# MissingLocationFormWidget — FlutterFlow Export Documentation

**Source:** `_flutterflow_export/lib/custom_code/widgets/missing_location_form_widget.dart`
**Type:** Custom StatefulWidget
**Phase 3 Status:** Not migrated
**Last Updated:** 2026-02-19

---

## Purpose

A form widget that allows users to submit information about a restaurant location that is missing from the JourneyMate database. The widget provides:

- Three required input fields: business name, business address, and a descriptive message
- Client-side validation with inline error messages
- API submission to BuildShip endpoint
- Success/error state handling
- Full translation support for multi-language interface
- User engagement tracking via `markUserEngaged()`

The widget is designed to be displayed in a bottom sheet or modal context, allowing users to contribute to the restaurant database when they cannot find a specific location.

---

## Function Signature

```dart
class MissingLocationFormWidget extends StatefulWidget {
  const MissingLocationFormWidget({
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

| Parameter | Type | Purpose | Example Values |
|-----------|------|---------|----------------|
| `currentLanguage` | `String` | Current UI language code for translation lookup | `'da'`, `'en'` |
| `translationsCache` | `dynamic` | Translation cache object passed from FFAppState | `FFAppState().translationsCache` |

### Optional Parameters

| Parameter | Type | Default | Purpose |
|-----------|------|---------|---------|
| `width` | `double?` | `null` | Widget width constraint (currently unused in implementation) |
| `height` | `double?` | `null` | Widget height constraint (currently unused in implementation) |

### Notes on Parameters

- **`width` and `height`**: These parameters are declared but not used in the current implementation. The widget uses `SingleChildScrollView` with padding that adapts to content.
- **`translationsCache`**: Must contain all required translation keys (see Translation Keys section). The widget calls `getTranslations()` to retrieve localized strings.
- **`currentLanguage`**: Sent to API endpoint with form submission to enable language-specific processing on the backend.

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

### External Packages

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
```

### Custom Functions Used

| Function | Source | Purpose | Signature |
|----------|--------|---------|-----------|
| `getTranslations()` | `/flutter_flow/custom_functions.dart` | Retrieves translated string for a given key | `String getTranslations(String language, String key, dynamic cache)` |
| `markUserEngaged()` | `/custom_code/actions/index.dart` | Tracks user engagement event | `void markUserEngaged()` |

---

## FFAppState Usage

### State Variables Read

| Variable | Type | When Read | Purpose |
|----------|------|-----------|---------|
| `currentLanguage` | `String` | On every render via `_getUIText()` | Determines which translation to display |
| `translationsCache` | `dynamic` | On every render via `_getUIText()` | Provides translation data |

### State Variables Written

**None.** This widget does not write to FFAppState.

### Widget State Management

The widget maintains its own local state:

```dart
final TextEditingController _businessNameController;
final TextEditingController _businessAddressController;
final TextEditingController _messageController;

String? _businessNameError;
String? _businessAddressError;
String? _messageError;
bool _isSubmitting;
bool _isSubmitted;
String? _submissionError;
```

---

## Translation Keys

All text in the widget is fully translatable. The following translation keys must exist in the `translationsCache`:

### Form Labels and Instructions

| Translation Key | Context | Example (English) |
|----------------|---------|-------------------|
| `missing_location_title_main` | Main form title | "Can't find the location?" |
| `missing_location_subtitle_main_1` | First intro paragraph | "Help us improve JourneyMate by submitting missing restaurant information." |
| `missing_location_subtitle_main_2` | Second intro paragraph | "We'll review your submission and add the location to our database." |
| `missing_location_title_business_name` | Business name field label | "Restaurant name" |
| `missing_location_hint_business_name` | Business name placeholder | "Enter the name of the restaurant" |
| `missing_location_title_business_address` | Business address field label | "Address" |
| `missing_location_subtitle_business_address` | Address field instruction | "Provide the full address including street, city, and postal code" |
| `missing_location_hint_business_address` | Address placeholder | "Enter the full address" |
| `missing_location_title_message` | Message field label | "Additional information" |
| `missing_location_subtitle_message` | Message field instruction | "Tell us more about this location (minimum 10 characters)" |
| `missing_location_hint_message` | Message placeholder | "E.g., hours, specialties, accessibility features..." |

### Validation Errors

| Translation Key | Triggered When | Example (English) |
|----------------|---------------|-------------------|
| `missing_location_error_name_required` | Business name is empty | "Please enter the restaurant name" |
| `missing_location_error_address_required` | Business address is empty | "Please enter the restaurant address" |
| `missing_location_error_message_required` | Message field is empty | "Please provide additional information" |
| `missing_location_error_message_too_short` | Message is less than 10 characters | "Please provide at least 10 characters" |

### Submit Button and Status Messages

| Translation Key | Context | Example (English) |
|----------------|---------|-------------------|
| `missing_location_button_submit` | Submit button label | "Submit location" |
| `missing_location_success_message` | Shown after successful submission | "Thank you! Your submission has been received." |
| `missing_location_success_navigate_away` | Instruction after success | "You can now close this form." |
| `missing_location_error_submission` | Shown on API error | "Something went wrong. Please try again." |

### Translation Retrieval Logic

```dart
String _getUIText(String key) {
  return getTranslations(
    widget.currentLanguage,
    key,
    widget.translationsCache,
  );
}
```

This method wraps the `getTranslations()` custom function for convenient access throughout the widget.

---

## Analytics Tracking

### Events Tracked

| Event | Trigger Point | Purpose |
|-------|--------------|---------|
| User engagement | `_handleSubmit()` called | Marks user as engaged via `markUserEngaged()` |

### Implementation

```dart
Future<void> _handleSubmit() async {
  markUserEngaged();  // Track engagement before validation

  if (_isSubmitting) return;
  if (!_validateForm()) return;

  // Continue with submission...
}
```

**Note:** The widget calls `markUserEngaged()` at the start of the submit handler, regardless of validation outcome. This ensures user intent is tracked even if the form has errors.

**Missing Analytics:** Unlike other widgets in the codebase (e.g., `FilterDescriptionSheet`, `ShareButton`), this widget does NOT call `trackAnalyticsEvent()` for specific form interactions. This may be intentional, or it could be enhanced to track:
- Form field interactions
- Validation failures
- Successful submissions
- API errors

---

## Form Validation

### Validation Rules

| Field | Rules | Error Message Key |
|-------|-------|------------------|
| Business Name | Must not be empty after trim | `missing_location_error_name_required` |
| Business Address | Must not be empty after trim | `missing_location_error_address_required` |
| Message | Must not be empty after trim | `missing_location_error_message_required` |
| Message | Must be at least 10 characters | `missing_location_error_message_too_short` |

### Validation Logic

```dart
bool _validateForm() {
  bool isValid = true;

  setState(() {
    // Clear all errors
    _businessNameError = null;
    _businessAddressError = null;
    _messageError = null;

    // Validate business name
    final businessName = _businessNameController.text.trim();
    if (businessName.isEmpty) {
      _businessNameError = _getUIText('missing_location_error_name_required');
      isValid = false;
    }

    // Validate business address
    final businessAddress = _businessAddressController.text.trim();
    if (businessAddress.isEmpty) {
      _businessAddressError = _getUIText('missing_location_error_address_required');
      isValid = false;
    }

    // Validate message
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      _messageError = _getUIText('missing_location_error_message_required');
      isValid = false;
    } else if (message.length < 10) {
      _messageError = _getUIText('missing_location_error_message_too_short');
      isValid = false;
    }
  });

  return isValid;
}
```

### Real-Time Error Clearing

Errors are cleared as the user types in the corresponding field:

```dart
onChanged: (_) {
  if (errorText != null) {
    setState(() {
      if (controller == _businessNameController) {
        _businessNameError = null;
      } else if (controller == _businessAddressController) {
        _businessAddressError = null;
      } else if (controller == _messageController) {
        _messageError = null;
      }
    });
  }
},
```

---

## API Integration

### Endpoint

```dart
static const String _apiEndpoint = 'https://wvb8ww.buildship.run/missingplace';
```

### Request Format

**Method:** `POST`
**Headers:**
```json
{
  "Content-Type": "application/json"
}
```

**Body:**
```json
{
  "businessName": "Restaurant Name",
  "businessAddress": "123 Main St, Copenhagen 1234",
  "message": "Great vegan options, wheelchair accessible entrance",
  "languageCode": "da"
}
```

### Response Handling

**Success Response (200):**
```json
{
  "success": true
}
```

**Error Response (400/500):**
```json
{
  "success": false,
  "error": "Error message description"
}
```

### Submission Logic

```dart
Future<void> _submitToAPI() async {
  final requestBody = {
    'businessName': _businessNameController.text.trim(),
    'businessAddress': _businessAddressController.text.trim(),
    'message': _messageController.text.trim(),
    'languageCode': widget.currentLanguage,
  };

  final response = await http.post(
    Uri.parse(_apiEndpoint),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );

  if (response.statusCode == 200) {
    final responseData = jsonDecode(response.body);
    if (responseData['success'] == true) {
      return;  // Success
    } else {
      throw Exception(responseData['error'] ?? 'Unknown error occurred');
    }
  } else {
    final errorData = jsonDecode(response.body);
    throw Exception(errorData['error'] ?? 'Failed to submit missing location');
  }
}
```

### Submission Flow

```dart
Future<void> _handleSubmit() async {
  markUserEngaged();              // Track engagement

  if (_isSubmitting) return;      // Prevent double-submission
  if (!_validateForm()) return;   // Validate inputs

  setState(() {
    _isSubmitting = true;          // Show loading state
    _submissionError = null;       // Clear previous errors
  });

  try {
    await _submitToAPI();          // Call API

    if (mounted) {
      setState(() {
        _isSubmitting = false;     // Stop loading
        _isSubmitted = true;       // Show success message
      });
    }
  } catch (error) {
    if (mounted) {
      setState(() {
        _isSubmitting = false;     // Stop loading
        _submissionError = error.toString();  // Show error message
      });
    }
  }
}
```

---

## UI State Management

### Three UI States

The widget renders one of three states in the submit area:

#### 1. Default State — Submit Button

**Condition:** `!_isSubmitted && _submissionError == null`

**Rendered:**
- Orange button with text from `missing_location_button_submit`
- Button width: 200px, height: 40px, radius: 8px
- Disabled state (50% opacity) when `_isSubmitting == true`
- Loading spinner (20x20, white) when submitting

#### 2. Success State

**Condition:** `_isSubmitted == true`

**Rendered:**
- Green success container with check icon
- Success message from `missing_location_success_message`
- Secondary instruction from `missing_location_success_navigate_away`
- Green accent color: `#249689`

#### 3. Error State

**Condition:** `_submissionError != null`

**Rendered:**
- Red error container with error icon
- Error message from `missing_location_error_submission`
- Submit button rendered below error (for retry)
- Red accent color: `Colors.red`

---

## Design System Constants

### Colors

```dart
static const Color _titleColor = Color(0xFF14181B);             // Text headings
static const Color _subtitleColor = Color(0xFF14181B);          // Text subtitles
static const Color _textFieldBackground = Color(0xFFF2F3F5);    // Input fields
static const Color _submitButtonColor = Color(0xFFE9874B);      // Orange button
static const Color _submitButtonTextColor = Colors.white;       // Button text
static const Color _errorColor = Colors.red;                    // Errors
static const Color _successColor = Color(0xFF249689);           // Success state
```

### Typography

```dart
static const double _mainTitleFontSize = 20.0;        // "Can't find the location?"
static const double _titleFontSize = 18.0;            // Field labels
static const double _subtitleFontSize = 15.0;         // Instructions
static const double _submitButtonFontSize = 16.0;     // Button text
static const double _textFieldFontSize = 14.0;        // Input text

static const FontWeight _titleFontWeight = FontWeight.w500;
static const FontWeight _subtitleFontWeight = FontWeight.w300;
static const FontWeight _submitButtonFontWeight = FontWeight.w500;
```

### Spacing

```dart
static const double _sectionSpacing = 24.0;              // Between form sections
static const double _fieldSpacing = 8.0;                 // Label to input
static const double _subtitleToFieldSpacing = 6.0;      // Subtitle to input
static const double _submitButtonTopMargin = 40.0;      // Above submit button
static const double _bottomPadding = 140.0;             // ScrollView bottom padding
```

### Component Dimensions

```dart
static const double _submitButtonWidth = 200.0;
static const double _submitButtonHeight = 40.0;
static const double _submitButtonRadius = 8.0;
static const double _submitButtonPadding = 16.0;
static const double _textFieldBorderRadius = 8.0;
static const double _textFieldPadding = 12.0;
```

---

## Usage Examples

### Example 1: Display in Bottom Sheet

```dart
void _showMissingLocationForm(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: MissingLocationFormWidget(
        currentLanguage: FFAppState().currentLanguage,
        translationsCache: FFAppState().translationsCache,
      ),
    ),
  );
}
```

### Example 2: Full-Screen Modal

```dart
Navigator.of(context).push(
  MaterialPageRoute(
    fullscreenDialog: true,
    builder: (context) => Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MissingLocationFormWidget(
        currentLanguage: FFAppState().currentLanguage,
        translationsCache: FFAppState().translationsCache,
      ),
    ),
  ),
);
```

### Example 3: Embedded in Page

```dart
class MissingLocationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Missing Location')),
      body: MissingLocationFormWidget(
        currentLanguage: FFAppState().currentLanguage,
        translationsCache: FFAppState().translationsCache,
      ),
    );
  }
}
```

---

## Error Handling

### Validation Errors

**Display Strategy:**
- Inline error text below each field with red border
- Error appears immediately on submit if field is invalid
- Error clears as user types in the field

**Example Validation Error Display:**

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
        decoration: InputDecoration(
          hintText: hintText,
          errorBorder: errorText != null
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              )
            : null,
        ),
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

### API Errors

**Handled Scenarios:**
1. **Network failure** — Exception thrown by `http.post()`
2. **Non-200 status code** — Error extracted from response body
3. **Success: false in response** — Error message from response data
4. **Unparseable response** — Falls back to generic error message

**Error Display:**
- Red error container with error icon
- Generic error message from `missing_location_error_submission` translation key
- Submit button rendered below for retry attempt
- Original form data preserved in controllers

**Error Recovery:**
```dart
catch (error) {
  if (mounted) {
    setState(() {
      _isSubmitting = false;
      _submissionError = error.toString();  // Store error
    });
  }
}
```

### Widget Lifecycle Errors

**Protection Against Unmounted Widget:**
```dart
if (mounted) {
  setState(() {
    // Safe to update state
  });
}
```

This pattern is used in both success and error handlers to prevent calling `setState()` on an unmounted widget (e.g., if user closes the sheet during submission).

---

## Testing Checklist

### Unit Tests

- [ ] Validation logic for empty business name
- [ ] Validation logic for empty business address
- [ ] Validation logic for empty message
- [ ] Validation logic for message shorter than 10 characters
- [ ] All fields valid returns true
- [ ] Error clearing on text input
- [ ] API request body construction with correct fields
- [ ] API response parsing for success case
- [ ] API response parsing for error case
- [ ] Submit button disabled during submission

### Widget Tests

- [ ] Widget renders initial state correctly
- [ ] All translation keys are retrieved and displayed
- [ ] Submit button is enabled when not submitting
- [ ] Submit button shows loading spinner during submission
- [ ] Validation errors appear after invalid submission
- [ ] Validation errors disappear when user types
- [ ] Error state renders with error message and retry button
- [ ] Success state renders with success message
- [ ] Text field controllers dispose properly

### Integration Tests

- [ ] Form submission with valid data calls API endpoint
- [ ] Form submission with invalid data does not call API
- [ ] API success response transitions to success state
- [ ] API error response transitions to error state
- [ ] Retry button after error calls API again
- [ ] User engagement tracked on submit
- [ ] Language change updates all UI text
- [ ] Form works correctly in bottom sheet context
- [ ] Keyboard opens and scrolls form correctly
- [ ] Mounted check prevents setState after unmount

### Manual Testing Scenarios

#### Scenario 1: Happy Path
1. Open form
2. Enter valid business name: "Café Hygge"
3. Enter valid address: "Nørrebrogade 45, 2200 København N"
4. Enter valid message: "Great vegan options and cozy atmosphere"
5. Tap submit button
6. Verify loading state appears
7. Verify success message appears after API response

#### Scenario 2: Validation Errors
1. Open form
2. Tap submit button without filling any fields
3. Verify all three fields show error messages
4. Type in business name field
5. Verify business name error disappears
6. Type 5 characters in message field
7. Verify "too short" error appears on submit
8. Type 10+ characters in message field
9. Verify submission proceeds

#### Scenario 3: API Error
1. Disconnect network or use invalid endpoint
2. Fill form with valid data
3. Submit form
4. Verify error state appears with error message
5. Tap retry button
6. Verify form resubmits

#### Scenario 4: Translation Updates
1. Open form in Danish (`currentLanguage: 'da'`)
2. Verify all UI text is in Danish
3. Change language to English (`currentLanguage: 'en'`)
4. Verify all UI text updates to English
5. Verify placeholder text and error messages also update

#### Scenario 5: Bottom Sheet Context
1. Display widget in bottom sheet
2. Tap in text field
3. Verify keyboard opens without obscuring input
4. Scroll form while keyboard is open
5. Tap outside text field to dismiss keyboard
6. Verify form remains visible and functional

---

## Migration Notes (Phase 3)

### Current Implementation (FlutterFlow)

**State Management:**
- Uses `StatefulWidget` with local state
- Direct parameter passing for `currentLanguage` and `translationsCache`
- No FFAppState dependencies beyond the passed parameters

**API Integration:**
- Direct HTTP calls using `http` package
- Hardcoded BuildShip endpoint
- Manual JSON encoding/decoding

**Translation System:**
- Calls `getTranslations()` custom function
- Requires translation cache to be passed as parameter
- Supports dynamic language switching via `didUpdateWidget`

### Recommended Phase 3 Changes

#### 1. Migrate to Riverpod State Management

**Before:**
```dart
class MissingLocationFormWidget extends StatefulWidget {
  final String currentLanguage;
  final dynamic translationsCache;

  const MissingLocationFormWidget({
    required this.currentLanguage,
    required this.translationsCache,
  });
}
```

**After:**
```dart
class MissingLocationFormWidget extends ConsumerStatefulWidget {
  const MissingLocationFormWidget({super.key});

  @override
  ConsumerState<MissingLocationFormWidget> createState() =>
    _MissingLocationFormWidgetState();
}

class _MissingLocationFormWidgetState
    extends ConsumerState<MissingLocationFormWidget> {

  String _getUIText(String key) {
    final language = ref.watch(currentLanguageProvider);
    final translations = ref.watch(translationsCacheProvider);
    return getTranslations(language, key, translations);
  }
}
```

**Benefits:**
- Eliminates parameter drilling
- Automatic rebuilds on language change
- Consistent with other migrated widgets

#### 2. Create API Service Layer

**Before:**
```dart
Future<void> _submitToAPI() async {
  final response = await http.post(
    Uri.parse(_apiEndpoint),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );
  // Manual response parsing...
}
```

**After:**
```dart
// lib/services/missing_location_service.dart
class MissingLocationService {
  Future<void> submitMissingLocation({
    required String businessName,
    required String businessAddress,
    required String message,
    required String languageCode,
  }) async {
    final result = await ApiClient.post(
      endpoint: '/missingplace',
      body: {
        'businessName': businessName,
        'businessAddress': businessAddress,
        'message': message,
        'languageCode': languageCode,
      },
    );

    if (!result.success) {
      throw ApiException(result.error ?? 'Unknown error');
    }
  }
}

// In widget:
Future<void> _handleSubmit() async {
  final service = ref.read(missingLocationServiceProvider);
  await service.submitMissingLocation(
    businessName: _businessNameController.text.trim(),
    businessAddress: _businessAddressController.text.trim(),
    message: _messageController.text.trim(),
    languageCode: ref.read(currentLanguageProvider),
  );
}
```

**Benefits:**
- Centralized API logic
- Testable without widget context
- Consistent error handling
- Type-safe API calls

#### 3. Add Analytics Enhancement

**Current:** Only calls `markUserEngaged()` on submit.

**Recommended Enhancement:**
```dart
// Track form opened
@override
void initState() {
  super.initState();
  ref.read(analyticsProvider).trackEvent(
    'missing_location_form_opened',
    properties: {
      'language': ref.read(currentLanguageProvider),
    },
  );
}

// Track submission attempt
Future<void> _handleSubmit() async {
  ref.read(analyticsProvider).trackEvent(
    'missing_location_submit_attempted',
    properties: {
      'has_business_name': _businessNameController.text.isNotEmpty,
      'has_address': _businessAddressController.text.isNotEmpty,
      'message_length': _messageController.text.length,
    },
  );

  // Continue with existing logic...
}

// Track validation failures
if (!_validateForm()) {
  ref.read(analyticsProvider).trackEvent(
    'missing_location_validation_failed',
    properties: {
      'errors': [
        if (_businessNameError != null) 'business_name',
        if (_businessAddressError != null) 'business_address',
        if (_messageError != null) 'message',
      ],
    },
  );
  return;
}

// Track successful submission
ref.read(analyticsProvider).trackEvent(
  'missing_location_submitted',
  properties: {
    'business_name': _businessNameController.text.trim(),
    'language': ref.read(currentLanguageProvider),
  },
);
```

#### 4. Extract Form Validation Logic

**Current:** Validation logic mixed with widget state management.

**Recommended:**
```dart
// lib/validators/missing_location_validator.dart
class MissingLocationValidator {
  static ValidationResult validateBusinessName(String value) {
    if (value.trim().isEmpty) {
      return ValidationResult.error('missing_location_error_name_required');
    }
    return ValidationResult.valid();
  }

  static ValidationResult validateBusinessAddress(String value) {
    if (value.trim().isEmpty) {
      return ValidationResult.error('missing_location_error_address_required');
    }
    return ValidationResult.valid();
  }

  static ValidationResult validateMessage(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ValidationResult.error('missing_location_error_message_required');
    }
    if (trimmed.length < 10) {
      return ValidationResult.error('missing_location_error_message_too_short');
    }
    return ValidationResult.valid();
  }
}

// In widget:
bool _validateForm() {
  final nameResult = MissingLocationValidator.validateBusinessName(
    _businessNameController.text
  );
  final addressResult = MissingLocationValidator.validateBusinessAddress(
    _businessAddressController.text
  );
  final messageResult = MissingLocationValidator.validateMessage(
    _messageController.text
  );

  setState(() {
    _businessNameError = nameResult.isValid
      ? null
      : _getUIText(nameResult.errorKey!);
    _businessAddressError = addressResult.isValid
      ? null
      : _getUIText(addressResult.errorKey!);
    _messageError = messageResult.isValid
      ? null
      : _getUIText(messageResult.errorKey!);
  });

  return nameResult.isValid && addressResult.isValid && messageResult.isValid;
}
```

**Benefits:**
- Testable validation logic
- Reusable across different form contexts
- Clear separation of concerns

#### 5. Design System Alignment

**Current Constants:**
```dart
static const Color _submitButtonColor = Color(0xFFE9874B);  // Orange
static const Color _successColor = Color(0xFF249689);       // Teal/green
```

**Should Verify Against:**
- `_reference/journeymate-design-system.md`
- Confirm orange matches `ACCENT` (#e8751a) or button color
- Confirm success green matches `GREEN` (#1a9456)

**Note:** The current colors may not match the design system exactly:
- `_submitButtonColor`: `#E9874B` vs design system `#e8751a` (ACCENT)
- `_successColor`: `#249689` vs design system `#1a9456` (GREEN)

These should be aligned during Phase 3 migration.

#### 6. Widget Naming Consistency

**Current:** `MissingLocationFormWidget` (FlutterFlow convention)

**Phase 3:** Consider renaming to match pure Flutter conventions:
- `MissingLocationForm` (if used as a standalone widget)
- Or keep `MissingLocationFormWidget` for consistency with other custom widgets

### Migration Checklist

- [ ] Convert to `ConsumerStatefulWidget` for Riverpod
- [ ] Remove `currentLanguage` and `translationsCache` parameters
- [ ] Use `ref.watch()` to access language and translations
- [ ] Extract API logic to `MissingLocationService`
- [ ] Extract validation logic to `MissingLocationValidator`
- [ ] Add comprehensive analytics tracking
- [ ] Verify design system color alignment
- [ ] Add unit tests for validation logic
- [ ] Add unit tests for API service
- [ ] Add widget tests for UI states
- [ ] Add integration tests for full flow
- [ ] Update documentation with new implementation
- [ ] Remove `markUserEngaged()` if replaced by analytics system

---

## Related Components

### Pages That May Use This Widget

| Page | Context | Trigger |
|------|---------|---------|
| Search Page | Bottom sheet | "Location not found" button in empty state |
| Map Page | Bottom sheet | "Report missing" action on map |
| Business Profile | Modal | "This isn't the right place" action |

### Similar Form Patterns

| Widget/Page | Similarity | Differences |
|-------------|-----------|--------------|
| Contact form (if exists) | Form validation, API submission | Different fields, different endpoint |
| Feedback form (if exists) | User contribution flow | Different purpose, different validation rules |

### Dependencies on This Widget

**None identified.** This is a standalone form widget with no child widgets that depend on it.

---

## Known Issues and Limitations

### Current Limitations

1. **No file upload support** — User cannot attach photos or documents
2. **No location picker** — User must manually type address (no map integration)
3. **No duplicate detection** — Backend must handle checking if location already exists
4. **Generic error messages** — API errors not parsed for specific user-facing messages
5. **No offline support** — Form cannot be submitted without network connection
6. **No autosave** — User data lost if they close the form before submitting

### Potential Enhancements (Phase 3)

1. **Address autocomplete** — Integrate Google Places API for address suggestions
2. **GPS location capture** — Allow user to share current location or drop a pin
3. **Photo upload** — Let users attach photos of the restaurant
4. **Draft saving** — Persist form data to local storage if user closes before submitting
5. **Offline queue** — Queue submissions for retry when network is restored
6. **Structured address fields** — Separate fields for street, city, postal code
7. **Business hours input** — Structured input for hours of operation
8. **Cuisine tags** — Allow user to specify restaurant type/cuisine
9. **Accessibility features input** — Checkboxes for wheelchair access, etc.

---

## End of Documentation

**Documentation Version:** 1.0
**Flutter Version Compatibility:** 3.x+
**Dart Version Compatibility:** 3.0+

**Next Steps:**
- Review this documentation against FlutterFlow source for accuracy
- Use as reference during Phase 3 migration
- Update with actual implementation details post-migration
- Add to widget catalog for searchability
