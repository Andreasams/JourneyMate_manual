# FeedbackFormWidget Documentation

**File:** `lib/custom_code/widgets/feedback_form_widget.dart`
**Type:** Custom Stateful Widget
**Purpose:** Multi-field feedback submission form with topic selection, message input, optional contact information, and BuildShip API integration

---

## Overview

The FeedbackFormWidget is a comprehensive feedback collection interface that allows users to submit structured feedback to JourneyMate. The widget features:

- Topic selection with 7 predefined categories
- Multi-line message input with validation
- Optional contact consent checkbox
- Conditional name and contact fields
- Form validation with inline error messages
- BuildShip API submission with loading states
- Success/error state UI feedback
- Full translation support
- User engagement tracking

The widget is fully self-contained with no dependencies on external state except for translations cache, making it easily embeddable in settings or profile pages.

---

## Function Signature

```dart
class FeedbackFormWidget extends StatefulWidget {
  const FeedbackFormWidget({
    super.key,
    this.width,
    this.height,
    required this.currentLanguage,
    required this.translationsCache,
    this.pageName,
  });

  final double? width;
  final double? height;
  final String currentLanguage;
  final dynamic translationsCache;
  final String? pageName;
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `currentLanguage` | `String` | Current language code for translation lookup (e.g., 'en', 'da') |
| `translationsCache` | `dynamic` | Translations cache from FFAppState containing all localized strings |

### Optional Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `width` | `double?` | `null` | Widget width (not actively used, form uses available width) |
| `height` | `double?` | `null` | Widget height (not actively used, form uses scroll view) |
| `pageName` | `String?` | `null` | Page name for analytics context (currently unused) |

---

## Dependencies

### Flutter Framework
```dart
import 'package:flutter/material.dart';
```

### FlutterFlow Infrastructure
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
```

### Custom Code
```dart
import '/custom_code/actions/index.dart';        // markUserEngaged()
import '/flutter_flow/custom_functions.dart';    // getTranslations()
```

### External Packages
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
```

### Custom Actions Used
- **`markUserEngaged()`**: Called on topic selection, contact checkbox change, and form submission to extend engagement window

### Custom Functions Used
- **`getTranslations(languageCode, key, cache)`**: Retrieves translated strings for all UI text

---

## FFAppState Usage

### State Variables Read
- **`translationsCache`**: Dynamic map containing all translation strings
  - Passed directly as widget parameter
  - Used in `_getUIText()` for all UI string lookups
  - Not modified by this widget

### State Variables Written
None. This widget is completely stateless regarding FFAppState and only reads the translations cache.

---

## Form Architecture

### Topic Selection System

**7 Predefined Topics:**
```dart
static const List<String> _topicKeys = [
  'feedback_topic_wrong_info',      // Incorrect restaurant information
  'feedback_topic_app_ideas',       // Feature suggestions
  'feedback_topic_bug',             // Bug reports
  'feedback_topic_missing_place',   // Missing restaurants
  'feedback_topic_suggestion',      // General suggestions
  'feedback_topic_praise',          // Positive feedback
  'feedback_topic_other',           // Other feedback
];
```

**UI Implementation:**
- Topics rendered as selectable buttons using `Wrap` layout
- Single-selection model (radio button behavior)
- Selected state: Orange background (`#EE8B60`), white text
- Unselected state: Light gray background (`#F2F3F5`), dark text
- Animated transition on selection (200ms)
- Required field with validation

### Form Fields

| Field | Type | Required | Validation | Character Limits |
|-------|------|----------|------------|------------------|
| Topic | Single-select buttons | Yes | Must select one topic | N/A |
| Message | Multi-line text (6 lines) | Yes | Min 10 characters | No max enforced |
| Contact consent | Checkbox | No | N/A | N/A |
| Name | Single-line text | Conditional* | Required if contact consent checked | No limit |
| Contact info | Single-line text | Conditional* | Required if contact consent checked | No limit |

*Conditional fields become required when "Allow contact" checkbox is enabled.

### Validation Rules

**Topic Field:**
```dart
if (_selectedTopic == null || _selectedTopic!.isEmpty) {
  _topicError = _getUIText('feedback_form_error_topic_required');
  isValid = false;
}
```

**Message Field:**
```dart
final message = _messageController.text.trim();
if (message.isEmpty) {
  _messageError = _getUIText('feedback_form_error_message_required');
  isValid = false;
} else if (message.length < 10) {
  _messageError = _getUIText('feedback_form_error_message_too_short');
  isValid = false;
}
```

**Conditional Contact Fields:**
```dart
if (_requireContact) {
  final name = _nameController.text.trim();
  final contact = _contactController.text.trim();

  if (name.isEmpty) {
    _nameError = _getUIText('feedback_form_error_name_required');
    isValid = false;
  }

  if (contact.isEmpty) {
    _contactError = _getUIText('feedback_form_error_contact_required');
    isValid = false;
  }
}
```

**Real-time Error Clearing:**
- Errors clear as user types in text fields
- Topic error clears on topic selection
- Contact field errors clear when unchecking consent

---

## API Integration

### Endpoint
```dart
static const String _apiEndpoint =
    'https://wvb8ww.buildship.run/feedbackform';
```

### Request Format
```dart
POST https://wvb8ww.buildship.run/feedbackform
Content-Type: application/json

{
  "topic": "Forkerte oplysninger",              // Localized topic label
  "message": "User's feedback message...",      // Trimmed message text
  "allowContact": true,                         // Contact consent flag
  "name": "John Doe",                           // Trimmed name (or null)
  "contact": "john@example.com",                // Trimmed contact (or null)
  "languageCode": "da"                          // Current language code
}
```

**Request Body Fields:**

| Field | Type | Always Present | Description |
|-------|------|----------------|-------------|
| `topic` | `String` | Yes | Localized topic label (not the key) |
| `message` | `String` | Yes | User's feedback message (trimmed) |
| `allowContact` | `bool` | Yes | Whether user consented to contact |
| `name` | `String?` | No | User's name (null if empty) |
| `contact` | `String?` | No | User's email/phone (null if empty) |
| `languageCode` | `String` | Yes | ISO language code |

### Response Handling

**Success Response (200 OK):**
```json
{
  "success": true
}
```

**Error Responses:**
```json
{
  "success": false,
  "error": "Error message description"
}
```

**Status Codes:**
- `200`: Success (with `success: true`)
- `200`: Application error (with `success: false` and error message)
- Non-200: HTTP error (parsed from body if JSON, generic error otherwise)

### Submission Flow

```dart
Future<void> _handleSubmit() async {
  markUserEngaged();  // Track user engagement

  if (_isSubmitting) return;  // Prevent double submission

  if (!_validateForm()) return;  // Client-side validation

  setState(() {
    _isSubmitting = true;
    _submissionError = null;
  });

  try {
    await _submitToAPI();

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSubmitted = true;  // Show success state
      });
    }
  } catch (error) {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _submissionError = error.toString();  // Show error state
      });
    }
  }
}
```

---

## Translation Keys

### Main Form Sections

| Key | Context | Example (English) |
|-----|---------|-------------------|
| `feedback_form_title_main` | Main form title | "Share your feedback" |
| `feedback_form_subtitle_main` | Main form subtitle | "Help us improve JourneyMate" |
| `feedback_form_title_topic` | Topic selection title | "What's your feedback about?" |
| `feedback_form_subtitle_topic` | Topic selection subtitle | "Choose a category" |
| `feedback_form_title_message` | Message field title | "Your feedback" |
| `feedback_form_subtitle_message` | Message field subtitle | "Tell us more" |
| `feedback_form_title_contact_consent` | Contact consent title | "Can we reach you?" |
| `feedback_form_subtitle_contact_consent` | Contact consent subtitle | "Check if you'd like us to follow up" |
| `feedback_form_title_name` | Name field title | "Your name" |
| `feedback_form_title_contact_info` | Contact info field title | "Email or phone" |
| `feedback_form_subtitle_contact_info` | Contact info field subtitle | "How should we reach you?" |

### Topic Options

| Key | Translation (English) |
|-----|-----------------------|
| `feedback_topic_wrong_info` | "Wrong information" |
| `feedback_topic_app_ideas` | "App ideas" |
| `feedback_topic_bug` | "Bug report" |
| `feedback_topic_missing_place` | "Missing place" |
| `feedback_topic_suggestion` | "Suggestion" |
| `feedback_topic_praise` | "Praise" |
| `feedback_topic_other` | "Other" |

### Field Hints

| Key | Purpose |
|-----|---------|
| `feedback_form_hint_message` | Message textarea placeholder |
| `feedback_form_hint_name` | Name field placeholder |
| `feedback_form_hint_contact_info` | Contact field placeholder |

### Validation Errors

| Key | Trigger Condition |
|-----|-------------------|
| `feedback_form_error_topic_required` | No topic selected |
| `feedback_form_error_message_required` | Message field empty |
| `feedback_form_error_message_too_short` | Message < 10 characters |
| `feedback_form_error_name_required` | Contact consent checked, name empty |
| `feedback_form_error_contact_required` | Contact consent checked, contact empty |

### Submission States

| Key | Context |
|-----|---------|
| `feedback_form_button_submit` | Submit button text |
| `feedback_form_success_message` | Success message title |
| `feedback_form_success_navigate_away` | Success message subtitle |
| `feedback_form_error_submission` | Generic submission error |

**Total Translation Keys:** 26 keys

---

## Analytics Tracking

### User Engagement Tracking

**Function Called:** `markUserEngaged()`

**Tracking Points:**
1. **Topic Selection** (`_handleTopicSelected`)
2. **Contact Consent Toggle** (`_handleContactRequiredChanged`)
3. **Form Submission Attempt** (`_handleSubmit`)

**Purpose:**
- Extends the user engagement window tracked by the engagement heartbeat system
- Helps measure actual user activity vs idle time
- Does not send analytics events directly (delegates to engagement system)

**Implementation:**
```dart
void _handleTopicSelected(String label) {
  markUserEngaged();  // Extend engagement window
  setState(() {
    _selectedTopic = label;
    _topicError = null;
  });
}
```

### Page-Level Analytics

The widget itself **does not track analytics events**, but the containing page (ShareFeedbackWidget) tracks:

**Event:** `page_viewed`
**Parameters:**
- `pageName`: "shareFeedbackSettings"
- `durationSeconds`: Session duration in seconds

**Tracked on:** Page disposal (when user navigates away)

### Potential Additional Analytics

The widget could track (not currently implemented):
- Feedback submission success/failure
- Topic selection distribution
- Contact consent rate
- Form abandonment rate
- Average message length
- Validation error frequency

---

## State Management

### Local State Variables

| Variable | Type | Initial Value | Purpose |
|----------|------|---------------|---------|
| `_selectedTopic` | `String?` | `null` | Currently selected feedback topic |
| `_messageController` | `TextEditingController` | Empty | Message text field controller |
| `_requireContact` | `bool` | `false` | Contact consent checkbox state |
| `_nameController` | `TextEditingController` | Empty | Name field controller |
| `_contactController` | `TextEditingController` | Empty | Contact info field controller |
| `_topicError` | `String?` | `null` | Topic validation error message |
| `_messageError` | `String?` | `null` | Message validation error message |
| `_nameError` | `String?` | `null` | Name validation error message |
| `_contactError` | `String?` | `null` | Contact validation error message |
| `_isSubmitting` | `bool` | `false` | API submission in progress flag |
| `_isSubmitted` | `bool` | `false` | Successful submission flag |
| `_submissionError` | `String?` | `null` | API submission error message |

### Lifecycle Management

**`initState()`**
- Not overridden (uses default initialization)
- Controllers created at declaration

**`didUpdateWidget()`**
```dart
void didUpdateWidget(FeedbackFormWidget oldWidget) {
  super.didUpdateWidget(oldWidget);

  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.currentLanguage != oldWidget.currentLanguage) {
    setState(() {});  // Rebuild with new translations
  }
}
```

**`dispose()`**
```dart
void dispose() {
  _messageController.dispose();
  _nameController.dispose();
  _contactController.dispose();
  super.dispose();
}
```

---

## UI Design Constants

### Color Palette

| Constant | Hex Value | Usage |
|----------|-----------|-------|
| `_titleColor` | `#14181B` | Section titles |
| `_subtitleColor` | `#14181B` | Section subtitles |
| `_textFieldBackground` | `#F2F3F5` | Text input backgrounds |
| `_submitButtonColor` | `#E9874B` | Submit button background |
| `_submitButtonTextColor` | `#FFFFFF` | Submit button text |
| `_errorColor` | `#FF0000` | Error messages and validation |
| `_successColor` | `#249689` | Success message |
| `_selectedTopicColor` | `#EE8B60` | Selected topic button |
| `_unselectedTopicColor` | `#F2F3F5` | Unselected topic button |
| `_selectedTopicTextColor` | `#FFFFFF` | Selected topic text |
| `_unselectedTopicTextColor` | `#242629` | Unselected topic text |
| `_topicBorderColor` | `Colors.grey[500]` | Topic button borders |

### Typography

| Element | Font Size | Font Weight | Usage |
|---------|-----------|-------------|-------|
| Main title | 20.0 | w500 | "Share your feedback" |
| Section titles | 18.0 | w500 | Field labels |
| Subtitles | 15.0 | w300 | Helper text |
| Text fields | 14.0 | Default | Input text |
| Topic buttons | 14.0 | w400 | Topic labels |
| Submit button | 16.0 | w500 | "Submit" |
| Error text | 12.0 | w400 | Validation errors |

### Layout Spacing

| Constant | Value | Usage |
|----------|-------|-------|
| `_sectionSpacing` | 24.0 | Between form sections |
| `_fieldSpacing` | 8.0 | Between label and field |
| `_subtitleToFieldSpacing` | 6.0 | Between subtitle and input |
| `_submitButtonTopMargin` | 40.0 | Above submit button |
| `_bottomPadding` | 140.0 | Bottom scroll padding |
| `_topicButtonSpacing` | 8.0 | Horizontal spacing between topics |
| `_topicButtonRunSpacing` | 0.0 | Vertical spacing between topic rows |

### Component Dimensions

| Component | Width | Height | Border Radius |
|-----------|-------|--------|---------------|
| Submit button | 200.0 | 40.0 | 8.0 |
| Topic button | Auto | 32.0 | 8.0 |
| Text field | Auto | Auto | 8.0 |

---

## Usage Examples

### Basic Usage (Settings Page)

```dart
// In ShareFeedbackWidget page
Container(
  width: double.infinity,
  height: MediaQuery.sizeOf(context).height,
  child: custom_widgets.FeedbackFormWidget(
    width: double.infinity,
    height: MediaQuery.sizeOf(context).height,
    currentLanguage: FFLocalizations.of(context).languageCode,
    pageName: 'shareFeedback',
    translationsCache: FFAppState().translationsCache,
  ),
)
```

### Embedded in Bottom Sheet

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => Container(
    height: MediaQuery.of(context).size.height * 0.9,
    child: FeedbackFormWidget(
      currentLanguage: FFLocalizations.of(context).languageCode,
      translationsCache: FFAppState().translationsCache,
      pageName: 'feedbackBottomSheet',
    ),
  ),
);
```

### With Custom Language Override

```dart
FeedbackFormWidget(
  currentLanguage: 'en',  // Force English
  translationsCache: FFAppState().translationsCache,
  pageName: 'profileSettings',
)
```

---

## Error Handling

### Validation Error Display

**Inline Error Messages:**
- Displayed below the affected field
- Red text (`#FF0000`)
- 12px font size
- Appears immediately after validation failure
- Clears as user types or makes selection

**Required Field Indicators:**
- Red asterisk (*) appended to title
- Applied to topic, message, and conditionally to name/contact

### API Error Handling

**Network Errors:**
```dart
catch (error) {
  if (mounted) {
    setState(() {
      _isSubmitting = false;
      _submissionError = error.toString();  // Shows in UI
    });
  }
}
```

**Error UI:**
- Red bordered container with error icon
- Error message from API or generic fallback
- Submit button remains available for retry
- User can fix issues and resubmit

### Success State Handling

**Success UI:**
```dart
Widget _buildSuccessMessage() {
  return Center(
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: _successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_submitButtonRadius),
        border: Border.all(color: _successColor, width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, color: _successColor, size: 32),
          SizedBox(height: 8),
          Text(_getUIText('feedback_form_success_message')),
          SizedBox(height: 4),
          Text(_getUIText('feedback_form_success_navigate_away')),
        ],
      ),
    ),
  );
}
```

**Post-Submission:**
- Form remains in success state (no auto-reset)
- User must navigate away manually
- Form data persists in controllers (not cleared)

### Edge Cases

| Scenario | Handling |
|----------|----------|
| Translations cache null/empty | Falls back to key as display text |
| Multiple rapid submit clicks | Prevented by `_isSubmitting` guard |
| Widget disposed during API call | `if (mounted)` check prevents state updates |
| Empty trimmed input | Validation catches before submission |
| Network timeout | HTTP exception caught, shown as error |
| Malformed JSON response | JSON decode exception caught |

---

## Testing Checklist

### Unit Tests

- [ ] `_validateForm()` returns false when topic not selected
- [ ] `_validateForm()` returns false when message empty
- [ ] `_validateForm()` returns false when message < 10 characters
- [ ] `_validateForm()` returns false when contact required but name empty
- [ ] `_validateForm()` returns false when contact required but contact empty
- [ ] `_validateForm()` returns true when all required fields valid
- [ ] `_getUIText()` returns correct translations for all keys
- [ ] `_getLocalizedTopicLabels()` returns correct number of topics

### Widget Tests

- [ ] Widget renders without errors
- [ ] All form sections visible on initial render
- [ ] Topic buttons render with correct count (7)
- [ ] Selecting topic updates UI state
- [ ] Selecting topic clears topic error
- [ ] Typing in message field clears message error
- [ ] Checkbox toggles contact required state
- [ ] Required asterisk appears/disappears based on checkbox
- [ ] Submit button disabled during submission
- [ ] Submit button shows loading indicator during submission
- [ ] Success message displays after successful submission
- [ ] Error message displays after failed submission
- [ ] Form remains interactive after error
- [ ] Translations update when language changes

### Integration Tests

- [ ] API call sends correct request body format
- [ ] API call includes all required fields
- [ ] API call handles 200 success response
- [ ] API call handles 200 error response
- [ ] API call handles non-200 HTTP errors
- [ ] `markUserEngaged()` called on topic selection
- [ ] `markUserEngaged()` called on checkbox toggle
- [ ] `markUserEngaged()` called on form submission
- [ ] Form submits successfully with minimal required fields
- [ ] Form submits successfully with all fields filled
- [ ] Form submits localized topic label (not key)
- [ ] Form includes language code in request

### Manual Testing

- [ ] Test all 7 topic selections
- [ ] Test message with exactly 10 characters
- [ ] Test message with < 10 characters (should error)
- [ ] Test with contact consent enabled/disabled
- [ ] Test required field validation errors display
- [ ] Test error messages clear on user input
- [ ] Test form in English language
- [ ] Test form in Danish language
- [ ] Test keyboard behavior (submit on Enter, etc.)
- [ ] Test with very long message text
- [ ] Test with special characters in all fields
- [ ] Test network timeout scenario
- [ ] Test with invalid API endpoint (error handling)
- [ ] Test layout on small screens (320px width)
- [ ] Test layout on large screens (tablet)
- [ ] Test scrolling with keyboard open
- [ ] Test submit button accessibility (tap target size)

### Accessibility Tests

- [ ] All text inputs have semantic labels
- [ ] Checkbox has semantic label
- [ ] Error messages announced to screen readers
- [ ] Submit button state changes announced
- [ ] Focus order follows logical flow
- [ ] Touch targets meet minimum size (48x48dp)
- [ ] Color contrast meets WCAG AA standards
- [ ] Form operable with keyboard only
- [ ] Success/error states readable by screen readers

---

## Migration Notes

### Phase 3 Migration Requirements

#### 1. Remove FlutterFlow Dependencies

**Current FlutterFlow imports to remove:**
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
```

**Replace with pure Flutter/Dart:**
```dart
// No replacements needed - these are unused in this widget
```

#### 2. Translation System Migration

**Current implementation:**
```dart
String _getUIText(String key) {
  return getTranslations(
    widget.currentLanguage,
    key,
    widget.translationsCache,
  );
}
```

**Migrate to flutter_localizations:**
```dart
// Use AppLocalizations instead of custom function
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String _getUIText(BuildContext context, String key) {
  final localizations = AppLocalizations.of(context);

  // Map keys to localization methods
  switch (key) {
    case 'feedback_form_title_main':
      return localizations.feedbackFormTitleMain;
    case 'feedback_form_subtitle_main':
      return localizations.feedbackFormSubtitleMain;
    // ... map all 26 keys
    default:
      return key;  // Fallback to key if not found
  }
}
```

#### 3. Custom Actions Migration

**`markUserEngaged()` migration:**

Current import:
```dart
import '/custom_code/actions/index.dart';
```

Migrate to Riverpod provider:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// In your engagement tracking provider file
final engagementProvider = Provider<EngagementService>((ref) {
  return EngagementService();
});

// Update widget to ConsumerStatefulWidget
class FeedbackFormWidget extends ConsumerStatefulWidget { ... }

// In state class
void _handleTopicSelected(String label) {
  ref.read(engagementProvider).markUserEngaged();  // New way
  setState(() { ... });
}
```

#### 4. State Management with Riverpod

**No major state changes needed** - widget is already self-contained. However:

```dart
// Convert to ConsumerStatefulWidget for provider access
class FeedbackFormWidget extends ConsumerStatefulWidget {
  const FeedbackFormWidget({
    super.key,
    required this.currentLanguage,
    this.pageName,
  });

  final String currentLanguage;
  final String? pageName;

  // Remove translationsCache parameter (use provider instead)
}

class _FeedbackFormWidgetState extends ConsumerState<FeedbackFormWidget> {
  // Access translations from provider if needed
  // Or use AppLocalizations directly from context
}
```

#### 5. API Client Migration

**Current implementation uses raw `http` package:**
```dart
import 'package:http/http.dart' as http;

final response = await http.post(
  Uri.parse(_apiEndpoint),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode(requestBody),
);
```

**Migrate to centralized API service:**
```dart
import 'package:yourapp/services/api_client.dart';

// Create BuildShipApiClient service
class BuildShipApiClient {
  Future<Map<String, dynamic>> submitFeedback({
    required String topic,
    required String message,
    required bool allowContact,
    String? name,
    String? contact,
    required String languageCode,
  }) async {
    final response = await _httpClient.post(
      '/feedbackform',
      body: {
        'topic': topic,
        'message': message,
        'allowContact': allowContact,
        'name': name,
        'contact': contact,
        'languageCode': languageCode,
      },
    );
    return response.data;
  }
}

// In widget
final apiClient = ref.read(apiClientProvider);
await apiClient.submitFeedback(...);
```

#### 6. Color Constants Migration

**Move to theme:**
```dart
// In app_theme.dart
class AppColors {
  static const feedbackSubmitButton = Color(0xFFE9874B);
  static const feedbackSuccess = Color(0x FF249689);
  static const feedbackSelectedTopic = Color(0xFFEE8B60);
  // ... etc
}

// In widget
color: Theme.of(context).extension<AppColors>()!.feedbackSubmitButton
```

#### 7. Required Translations in ARB Files

**Create `app_en.arb`:**
```json
{
  "feedbackFormTitleMain": "Share your feedback",
  "feedbackFormSubtitleMain": "Help us improve JourneyMate",
  "feedbackFormTitleTopic": "What's your feedback about?",
  "feedbackFormSubtitleTopic": "Choose a category",
  "feedbackTopicWrongInfo": "Wrong information",
  "feedbackTopicAppIdeas": "App ideas",
  "feedbackTopicBug": "Bug report",
  "feedbackTopicMissingPlace": "Missing place",
  "feedbackTopicSuggestion": "Suggestion",
  "feedbackTopicPraise": "Praise",
  "feedbackTopicOther": "Other",
  "feedbackFormTitleMessage": "Your feedback",
  "feedbackFormSubtitleMessage": "Tell us more (at least 10 characters)",
  "feedbackFormHintMessage": "Type your feedback here...",
  "feedbackFormTitleContactConsent": "Can we reach you?",
  "feedbackFormSubtitleContactConsent": "Check if you'd like us to follow up",
  "feedbackFormTitleName": "Your name",
  "feedbackFormHintName": "Enter your name",
  "feedbackFormTitleContactInfo": "Email or phone",
  "feedbackFormSubtitleContactInfo": "How should we reach you?",
  "feedbackFormHintContactInfo": "your@email.com or phone number",
  "feedbackFormErrorTopicRequired": "Please select a topic",
  "feedbackFormErrorMessageRequired": "Please enter your feedback",
  "feedbackFormErrorMessageTooShort": "Feedback must be at least 10 characters",
  "feedbackFormErrorNameRequired": "Please enter your name",
  "feedbackFormErrorContactRequired": "Please enter your email or phone",
  "feedbackFormButtonSubmit": "Submit feedback",
  "feedbackFormSuccessMessage": "Thank you for your feedback!",
  "feedbackFormSuccessNavigateAway": "You can now close this page",
  "feedbackFormErrorSubmission": "Failed to submit feedback. Please try again."
}
```

**Create `app_da.arb`:**
```json
{
  "feedbackFormTitleMain": "Del din feedback",
  "feedbackFormSubtitleMain": "Hjælp os med at forbedre JourneyMate",
  "feedbackFormTitleTopic": "Hvad handler din feedback om?",
  "feedbackFormSubtitleTopic": "Vælg en kategori",
  "feedbackTopicWrongInfo": "Forkerte oplysninger",
  "feedbackTopicAppIdeas": "App-ideer",
  "feedbackTopicBug": "Fejlrapport",
  "feedbackTopicMissingPlace": "Manglende sted",
  "feedbackTopicSuggestion": "Forslag",
  "feedbackTopicPraise": "Ros",
  "feedbackTopicOther": "Andet",
  "feedbackFormTitleMessage": "Din feedback",
  "feedbackFormSubtitleMessage": "Fortæl os mere (mindst 10 tegn)",
  "feedbackFormHintMessage": "Skriv din feedback her...",
  "feedbackFormTitleContactConsent": "Må vi kontakte dig?",
  "feedbackFormSubtitleContactConsent": "Sæt kryds, hvis du gerne vil have svar",
  "feedbackFormTitleName": "Dit navn",
  "feedbackFormHintName": "Indtast dit navn",
  "feedbackFormTitleContactInfo": "Email eller telefon",
  "feedbackFormSubtitleContactInfo": "Hvordan skal vi kontakte dig?",
  "feedbackFormHintContactInfo": "din@email.dk eller telefonnummer",
  "feedbackFormErrorTopicRequired": "Vælg venligst et emne",
  "feedbackFormErrorMessageRequired": "Indtast venligst din feedback",
  "feedbackFormErrorMessageTooShort": "Feedback skal være mindst 10 tegn",
  "feedbackFormErrorNameRequired": "Indtast venligst dit navn",
  "feedbackFormErrorContactRequired": "Indtast venligst din email eller telefon",
  "feedbackFormButtonSubmit": "Send feedback",
  "feedbackFormSuccessMessage": "Tak for din feedback!",
  "feedbackFormSuccessNavigateAway": "Du kan nu lukke denne side",
  "feedbackFormErrorSubmission": "Kunne ikke sende feedback. Prøv venligst igen."
}
```

#### 8. Analytics Migration

**Current:** Direct function calls to `markUserEngaged()`

**Migrate to analytics service:**
```dart
// Create analytics service
class AnalyticsService {
  void trackFeedbackTopicSelected(String topic) {
    // Firebase Analytics or similar
  }

  void trackFeedbackSubmitted({
    required String topic,
    required bool allowedContact,
    required String languageCode,
  }) {
    // Track submission
  }

  void trackFeedbackError(String error) {
    // Track errors
  }
}

// In widget
final analytics = ref.read(analyticsProvider);
analytics.trackFeedbackTopicSelected(label);
```

#### 9. Testing Migration

**Add to test suite:**
```dart
// test/widgets/feedback_form_widget_test.dart
void main() {
  testWidgets('validates required fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: FeedbackFormWidget(currentLanguage: 'en'),
        ),
      ),
    );

    // Find and tap submit without filling fields
    await tester.tap(find.text('Submit feedback'));
    await tester.pump();

    // Verify error messages appear
    expect(find.text('Please select a topic'), findsOneWidget);
    expect(find.text('Please enter your feedback'), findsOneWidget);
  });
}
```

---

## Known Issues & Limitations

1. **No form reset after success**: User must navigate away to submit new feedback
2. **No character limit on message**: Could allow extremely long submissions
3. **No email validation**: Contact field accepts any string
4. **No rate limiting**: User could spam submissions
5. **No offline support**: Requires network connection
6. **No draft saving**: Lost on navigation away
7. **Localized topic sent to API**: Backend must handle all language variants
8. **No accessibility labels**: Screen reader support incomplete
9. **No loading timeout**: Long API calls block indefinitely
10. **No retry with exponential backoff**: Simple retry on error only

---

## Performance Considerations

- **Text controller disposal**: Properly cleaned up in `dispose()`
- **Mounted check**: Prevents setState after widget disposal
- **Real-time validation**: Only validates when necessary (on submit, on change)
- **Animation duration**: 200ms topic button transitions (smooth but not sluggish)
- **Scroll optimization**: SingleChildScrollView with specific bottom padding
- **No unnecessary rebuilds**: Only rebuilds when translations change
- **HTTP client**: Uses default client (consider connection pooling for production)

---

## Security Considerations

1. **Input sanitization**: Backend must sanitize all user input
2. **Rate limiting**: Should be enforced at API level
3. **Contact information**: Stored securely, GDPR compliance required
4. **API endpoint hardcoded**: Consider environment variables for production
5. **No authentication**: Anonymous submissions (consider adding user ID)
6. **HTTPS required**: Endpoint uses HTTPS (enforced)
7. **Error messages**: Don't expose sensitive backend information

---

## Related Files

- **Widget file:** `lib/custom_code/widgets/feedback_form_widget.dart`
- **Usage page:** `lib/app_settings/share_feedback/share_feedback_widget.dart`
- **Page model:** `lib/app_settings/share_feedback/share_feedback_model.dart`
- **Custom action:** `lib/custom_code/actions/mark_user_engaged.dart`
- **Translation function:** `lib/flutter_flow/custom_functions.dart` (getTranslations)
- **Widget exports:** `lib/custom_code/widgets/index.dart`

---

## Design System Compliance

**Colors:**
- ✅ Submit button uses orange (`#E9874B`) for interactive element
- ✅ Success state uses teal (`#249689`) for positive feedback
- ✅ Selected topic uses orange variant (`#EE8B60`)
- ✅ Text fields use light gray background (`#F2F3F5`)
- ✅ No black backgrounds used

**Typography:**
- ✅ Font weights mapped to Flutter standards (w300-w500)
- ✅ Consistent font sizing hierarchy
- ✅ Readable text sizes (minimum 12px)

**Spacing:**
- ✅ Consistent 24px section spacing
- ✅ Proper field spacing (8px label-to-field)
- ✅ Adequate touch targets (minimum 32px height)

**Interaction:**
- ✅ Clear visual feedback on topic selection
- ✅ Disabled state for submit button during loading
- ✅ Real-time error clearing on user input
- ✅ Loading indicator on submit button

---

## Future Enhancements

1. **Form reset option**: Add "Submit another" button after success
2. **Character counter**: Show remaining characters for message field
3. **Email validation**: Regex validation for contact field
4. **Attachment support**: Allow users to attach screenshots
5. **Draft auto-save**: Save form state to local storage
6. **Rich text editor**: Support formatting in message field
7. **Topic search**: Filter topics if list grows
8. **Sentiment analysis**: Auto-categorize feedback tone
9. **Response tracking**: Allow users to check status of feedback
10. **A/B testing**: Test different topic labels and form layouts

---

**Last Updated:** 2026-02-19
**Documented By:** Claude Code
**FlutterFlow Export Version:** Latest
**Widget Version:** 1.0.0
