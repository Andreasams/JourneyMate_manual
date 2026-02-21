# getSnackbarMessage Custom Function

**Document Version:** 1.0
**Last Updated:** 2026-02-19
**Function Location:** `_flutterflow_export/lib/flutter_flow/custom_functions.dart` (lines 2421-2452)
**Phase 3 Status:** Ready for migration

---

## Purpose

`getSnackbarMessage` retrieves localized snackbar messages for user feedback scenarios across the JourneyMate app. It handles both success and error states for four distinct form submission types: general feedback, contact requests, missing location reports, and erroneous information corrections.

The function acts as a centralized message router, mapping form types and message types to their corresponding translation keys, then retrieving the localized text from the translation cache.

---

## Function Signature

```dart
String? getSnackbarMessage(
  String messageType,
  String formType,
  String currentLanguage,
  dynamic translationsCache,
)
```

---

## Parameters

### `messageType` (String)
**Required:** Yes
**Valid Values:** `'error'`, `'success'`

Specifies the category of snackbar message to display:
- `'error'`: Generic error message (used across all form types)
- `'success'`: Form-specific success message

**Example Usage:**
```dart
// Show error
getSnackbarMessage('error', 'feedback', 'da', cache);

// Show success
getSnackbarMessage('success', 'contact', 'en', cache);
```

### `formType` (String)
**Required:** Yes
**Valid Values:** `'feedback'`, `'contact'`, `'missing_location'`, `'erroneous_info'`

Identifies which form submission triggered the snackbar:
- `'feedback'`: General app feedback form
- `'contact'`: Contact/support request form
- `'missing_location'`: Missing restaurant location report
- `'erroneous_info'`: Incorrect business information correction

**Note:** Only evaluated when `messageType == 'success'`. Error messages are generic across all forms.

### `currentLanguage` (String)
**Required:** Yes
**Format:** ISO 639-1 language code (e.g., `'da'`, `'en'`, `'de'`)

The user's selected language for localization.

### `translationsCache` (dynamic)
**Required:** Yes
**Type:** `Map<String, dynamic>` or JSON string
**Source:** `FFAppState().translationsCache`

The translation cache containing all localized strings. Passed to `getTranslations()` for lookup.

---

## Return Value

**Type:** `String?`

Returns:
- Localized snackbar message string from translation cache (on success)
- `'Invalid form type'` (if `formType` is unrecognized)
- `'Invalid message type'` (if `messageType` is not `'error'` or `'success'`)
- Empty string `''` (if translation key is missing in cache)

**Note:** The function delegates to `getTranslations()`, which may return empty string if the translation key is missing.

---

## Dependencies

### Internal Dependencies
1. **`getTranslations()`** (lines 2161-2235)
   - Retrieves localized strings from translation cache
   - Handles fallback behavior when keys are missing
   - See `MASTER_README_get_translations.md` for details

### FFAppState Dependencies
- **`translationsCache`**: Pre-loaded translation data for current language

### Translation System
The function uses the following translation keys:

| Translation Key | Used For | Example Text (EN) |
|-----------------|----------|-------------------|
| `snackbar_error` | All error scenarios | "Something went wrong. Please try again." |
| `snackbar_feedback_success` | Feedback form success | "Thank you for your feedback!" |
| `snackbar_contact_success` | Contact form success | "Message sent successfully!" |
| `snackbar_missing_location_success` | Missing location success | "Report submitted successfully!" |
| `snackbar_erroneous_info_success` | Erroneous info success | "Correction submitted. Thank you!" |

---

## Translation Keys Reference

### Translation Key Structure
All snackbar translation keys follow the pattern: `snackbar_[category]_[type]`

### Complete Translation Key Set

```dart
// Error message (universal)
'snackbar_error'
  ├─ DA: "Noget gik galt. Prøv venligst igen."
  ├─ EN: "Something went wrong. Please try again."
  ├─ DE: "Etwas ist schief gelaufen. Bitte versuchen Sie es erneut."
  ├─ FR: "Quelque chose s'est mal passé. Veuillez réessayer."
  ├─ IT: "Qualcosa è andato storto. Per favore riprova."
  ├─ NO: "Noe gikk galt. Vennligst prøv igjen."
  └─ SV: "Något gick fel. Vänligen försök igen."

// Success messages (form-specific)
'snackbar_feedback_success'
  ├─ DA: "Tak for din feedback!"
  ├─ EN: "Thank you for your feedback!"
  ├─ DE: "Vielen Dank für Ihr Feedback!"
  ├─ FR: "Merci pour votre retour!"
  ├─ IT: "Grazie per il tuo feedback!"
  ├─ NO: "Takk for tilbakemeldingen!"
  └─ SV: "Tack för din feedback!"

'snackbar_contact_success'
  ├─ DA: "Besked sendt succesfuldt!"
  ├─ EN: "Message sent successfully!"
  ├─ DE: "Nachricht erfolgreich gesendet!"
  ├─ FR: "Message envoyé avec succès!"
  ├─ IT: "Messaggio inviato con successo!"
  ├─ NO: "Melding sendt!"
  └─ SV: "Meddelandet skickades!"

'snackbar_missing_location_success'
  ├─ DA: "Rapport indsendt!"
  ├─ EN: "Report submitted successfully!"
  ├─ DE: "Bericht erfolgreich übermittelt!"
  ├─ FR: "Rapport soumis avec succès!"
  ├─ IT: "Segnalazione inviata con successo!"
  ├─ NO: "Rapport sendt inn!"
  └─ SV: "Rapport inskickad!"

'snackbar_erroneous_info_success'
  ├─ DA: "Rettelse indsendt. Tak!"
  ├─ EN: "Correction submitted. Thank you!"
  ├─ DE: "Korrektur eingereicht. Danke!"
  ├─ FR: "Correction soumise. Merci!"
  ├─ IT: "Correzione inviata. Grazie!"
  ├─ NO: "Korrigering sendt inn. Takk!"
  └─ SV: "Rättelse inskickad. Tack!"
```

---

## Usage Examples

### Example 1: Feedback Form Success
```dart
// After successful feedback submission
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      getSnackbarMessage(
        'success',
        'feedback',
        FFAppState().currentLanguage,
        FFAppState().translationsCache,
      ) ?? 'Success',
    ),
    backgroundColor: Color(0xFF1A9456), // GREEN
  ),
);
```

### Example 2: Contact Form Error
```dart
// After API failure
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      getSnackbarMessage(
        'error',
        'contact', // formType doesn't matter for errors
        FFAppState().currentLanguage,
        FFAppState().translationsCache,
      ) ?? 'Error',
    ),
    backgroundColor: Color(0xFFE74C3C), // Error red
  ),
);
```

### Example 3: Missing Location Report Success
```dart
// After location report submitted to BuildShip
final snackbarText = getSnackbarMessage(
  'success',
  'missing_location',
  FFAppState().currentLanguage,
  FFAppState().translationsCache,
);

if (snackbarText != null && snackbarText.isNotEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(snackbarText),
      backgroundColor: Color(0xFF1A9456),
      duration: Duration(seconds: 3),
    ),
  );
}
```

### Example 4: Erroneous Info Correction Success
```dart
// After business info correction submitted
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      getSnackbarMessage(
        'success',
        'erroneous_info',
        'da',
        FFAppState().translationsCache,
      ) ?? 'Tak!',
    ),
    backgroundColor: Color(0xFF1A9456),
  ),
);
```

---

## Edge Cases and Error Handling

### Edge Case 1: Invalid messageType
**Input:**
```dart
getSnackbarMessage('warning', 'feedback', 'en', cache)
```

**Output:** `'Invalid message type'`

**Handling:** Show generic fallback message to user, log error for debugging.

### Edge Case 2: Invalid formType
**Input:**
```dart
getSnackbarMessage('success', 'unknown_form', 'en', cache)
```

**Output:** `'Invalid form type'`

**Handling:** Show generic success message, log form type for investigation.

### Edge Case 3: Missing Translation Key
**Input:**
```dart
// Translation key 'snackbar_feedback_success' missing from cache
getSnackbarMessage('success', 'feedback', 'en', cache)
```

**Output:** `''` (empty string from `getTranslations()`)

**Handling:** Use null-coalescing operator to provide fallback: `?? 'Success'`

### Edge Case 4: Null Translation Cache
**Input:**
```dart
getSnackbarMessage('success', 'feedback', 'en', null)
```

**Output:** `''` (empty string from `getTranslations()`)

**Handling:** Always ensure translation cache is loaded before calling. Add null check in calling code.

### Edge Case 5: Empty Language Code
**Input:**
```dart
getSnackbarMessage('success', 'feedback', '', cache)
```

**Output:** Translation key returned as-is by `getTranslations()`

**Handling:** Validate language code before calling. Default to `'en'` if missing.

---

## Logic Flow

### Decision Tree
```
getSnackbarMessage(messageType, formType, lang, cache)
  │
  ├─ messageType == 'error'
  │    └─> translationKey = 'snackbar_error'
  │        └─> getTranslations(lang, translationKey, cache)
  │
  ├─ messageType == 'success'
  │    │
  │    ├─ formType == 'feedback'
  │    │    └─> translationKey = 'snackbar_feedback_success'
  │    │        └─> getTranslations(lang, translationKey, cache)
  │    │
  │    ├─ formType == 'contact'
  │    │    └─> translationKey = 'snackbar_contact_success'
  │    │        └─> getTranslations(lang, translationKey, cache)
  │    │
  │    ├─ formType == 'missing_location'
  │    │    └─> translationKey = 'snackbar_missing_location_success'
  │    │        └─> getTranslations(lang, translationKey, cache)
  │    │
  │    ├─ formType == 'erroneous_info'
  │    │    └─> translationKey = 'snackbar_erroneous_info_success'
  │    │        └─> getTranslations(lang, translationKey, cache)
  │    │
  │    └─ formType == (unrecognized)
  │         └─> return 'Invalid form type'
  │
  └─ messageType == (unrecognized)
       └─> return 'Invalid message type'
```

### Pseudo-Code
```dart
function getSnackbarMessage(messageType, formType, lang, cache) {
  var translationKey;

  if (messageType == 'error') {
    // All forms use same error message
    translationKey = 'snackbar_error';

  } else if (messageType == 'success') {
    // Map form type to translation key
    switch (formType) {
      case 'feedback':
        translationKey = 'snackbar_feedback_success';
        break;
      case 'contact':
        translationKey = 'snackbar_contact_success';
        break;
      case 'missing_location':
        translationKey = 'snackbar_missing_location_success';
        break;
      case 'erroneous_info':
        translationKey = 'snackbar_erroneous_info_success';
        break;
      default:
        return 'Invalid form type';
    }

  } else {
    return 'Invalid message type';
  }

  // Retrieve localized string
  return getTranslations(lang, translationKey, cache);
}
```

---

## Real-World Usage Patterns

### Pattern 1: Form Submission Feedback (Most Common)
**Location:** Profile page, Business Profile page, feedback forms
**Trigger:** After BuildShip API call completes (success or failure)

```dart
// In async form submission handler
try {
  final response = await BuildShipAPI.submitFeedback(formData);

  if (response.statusCode == 200) {
    // Show success snackbar
    final message = getSnackbarMessage(
      'success',
      'feedback',
      FFAppState().currentLanguage,
      FFAppState().translationsCache,
    );

    _showSnackbar(context, message ?? 'Success', isError: false);

    // Clear form and close
    Navigator.pop(context);

  } else {
    throw Exception('API error');
  }

} catch (e) {
  // Show error snackbar
  final message = getSnackbarMessage(
    'error',
    'feedback', // formType doesn't matter for errors
    FFAppState().currentLanguage,
    FFAppState().translationsCache,
  );

  _showSnackbar(context, message ?? 'Error', isError: true);
}
```

### Pattern 2: Network Failure Recovery
**Location:** Any form with API integration
**Trigger:** Network timeout, server error, invalid response

```dart
// Generic error handler for all forms
void _handleFormError(BuildContext context, String formType) {
  final errorMessage = getSnackbarMessage(
    'error',
    formType, // Passed for context but not used by function
    FFAppState().currentLanguage,
    FFAppState().translationsCache,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 12),
          Expanded(child: Text(errorMessage ?? 'Error')),
        ],
      ),
      backgroundColor: Color(0xFFE74C3C),
      duration: Duration(seconds: 4),
      action: SnackBarAction(
        label: 'Retry',
        textColor: Colors.white,
        onPressed: () => _retrySubmission(),
      ),
    ),
  );
}
```

### Pattern 3: Multi-Language Form Feedback
**Location:** Settings page language switcher
**Trigger:** After user changes language preference

```dart
// Update snackbar when language changes
void _onLanguageChanged(String newLanguageCode) {
  setState(() {
    FFAppState().currentLanguage = newLanguageCode;
    FFAppState().update(() {}); // Trigger rebuild
  });

  // Show confirmation in NEW language
  final message = getSnackbarMessage(
    'success',
    'contact', // Generic success
    newLanguageCode,
    FFAppState().translationsCache,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message ?? 'Language updated'),
      backgroundColor: Color(0xFF1A9456),
    ),
  );
}
```

---

## Integration with Translation System

### Translation Cache Structure
The translation cache is a flat key-value map:

```dart
FFAppState().translationsCache = {
  'snackbar_error': 'Something went wrong. Please try again.',
  'snackbar_feedback_success': 'Thank you for your feedback!',
  'snackbar_contact_success': 'Message sent successfully!',
  'snackbar_missing_location_success': 'Report submitted successfully!',
  'snackbar_erroneous_info_success': 'Correction submitted. Thank you!',
  // ... other translation keys
}
```

### Cache Loading Process
1. **App Launch:** Load translations for default language (`'da'`)
2. **Language Change:** Fetch and cache translations for new language
3. **Form Pages:** Access pre-loaded cache via `FFAppState().translationsCache`
4. **Snackbar Display:** Call `getSnackbarMessage()` with cached translations

### Translation Key Maintenance
**Add New Form Type:**
1. Define new `formType` value (e.g., `'report_issue'`)
2. Create translation key (e.g., `'snackbar_report_issue_success'`)
3. Add translations for all supported languages in Supabase
4. Update `getSnackbarMessage()` logic to handle new form type

**Example:**
```dart
// In getSnackbarMessage()
else if (formType == 'report_issue') {
  translationKey = 'snackbar_report_issue_success';
}
```

---

## Testing Checklist

### Unit Tests
- [ ] Test all valid `messageType` values (`'error'`, `'success'`)
- [ ] Test all valid `formType` values for success messages
- [ ] Test invalid `messageType` returns `'Invalid message type'`
- [ ] Test invalid `formType` returns `'Invalid form type'`
- [ ] Test with null translation cache (returns empty string)
- [ ] Test with empty language code (returns translation key)
- [ ] Test with missing translation key (returns empty string)
- [ ] Verify `getTranslations()` is called with correct parameters

### Integration Tests
- [ ] Test snackbar display after feedback form submission
- [ ] Test snackbar display after contact form submission
- [ ] Test snackbar display after missing location report
- [ ] Test snackbar display after erroneous info correction
- [ ] Test error snackbar after API failure
- [ ] Test snackbar updates when language changes mid-session

### Widget Tests
- [ ] Verify snackbar appears with correct text
- [ ] Verify snackbar background color matches message type
- [ ] Verify snackbar duration and dismissal behavior
- [ ] Test null-coalescing fallback in UI code

### Localization Tests
- [ ] Test all translation keys exist for supported languages (DA, EN, DE, FR, IT, NO, SV)
- [ ] Verify text fits in snackbar without overflow
- [ ] Test RTL language handling (if applicable in future)
- [ ] Verify consistent tone across all languages

---

## Migration Notes

### Phase 3 Implementation Tasks

#### Task 1: Create Pure Dart Function
**File:** `lib/shared/functions/snackbar_messages.dart`

```dart
/// Retrieves localized snackbar message for user feedback scenarios.
///
/// Maps message types and form types to translation keys, then retrieves
/// the localized text from the translation cache.
///
/// Returns:
/// - Localized message string (on success)
/// - 'Invalid form type' (if formType unrecognized)
/// - 'Invalid message type' (if messageType invalid)
/// - Empty string (if translation missing)
String? getSnackbarMessage(
  String messageType,
  String formType,
  String currentLanguage,
  Map<String, dynamic> translationsCache,
) {
  String translationKey;

  if (messageType == 'error') {
    translationKey = 'snackbar_error';
  } else if (messageType == 'success') {
    if (formType == 'feedback') {
      translationKey = 'snackbar_feedback_success';
    } else if (formType == 'contact') {
      translationKey = 'snackbar_contact_success';
    } else if (formType == 'missing_location') {
      translationKey = 'snackbar_missing_location_success';
    } else if (formType == 'erroneous_info') {
      translationKey = 'snackbar_erroneous_info_success';
    } else {
      return 'Invalid form type';
    }
  } else {
    return 'Invalid message type';
  }

  return getTranslations(
    currentLanguage,
    translationKey,
    translationsCache,
  );
}
```

#### Task 2: Update Import Statements
Replace FlutterFlow custom function imports:
```dart
// OLD (FlutterFlow)
import '/flutter_flow/custom_functions.dart' as functions;

// NEW (Pure Dart)
import 'package:journeymate/shared/functions/snackbar_messages.dart';
```

#### Task 3: Update Function Calls
```dart
// OLD (FlutterFlow)
functions.getSnackbarMessage(
  'success',
  'feedback',
  FFAppState().currentLanguage,
  FFAppState().translationsCache,
)

// NEW (Pure Dart with Provider)
getSnackbarMessage(
  'success',
  'feedback',
  context.read<AppState>().currentLanguage,
  context.read<AppState>().translationsCache,
)
```

#### Task 4: Add Helper Widget (Optional)
Create a reusable snackbar widget to reduce boilerplate:

```dart
// lib/shared/widgets/snackbar_helper.dart

import 'package:flutter/material.dart';
import 'package:journeymate/shared/functions/snackbar_messages.dart';

class SnackbarHelper {
  /// Show success snackbar with localized message
  static void showSuccess(
    BuildContext context,
    String formType,
    String languageCode,
    Map<String, dynamic> translationsCache,
  ) {
    final message = getSnackbarMessage(
      'success',
      formType,
      languageCode,
      translationsCache,
    );

    if (message == null || message.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF1A9456), // GREEN
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar with localized message
  static void showError(
    BuildContext context,
    String formType,
    String languageCode,
    Map<String, dynamic> translationsCache,
  ) {
    final message = getSnackbarMessage(
      'error',
      formType,
      languageCode,
      translationsCache,
    );

    if (message == null || message.isEmpty) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFE74C3C), // Error red
        duration: Duration(seconds: 4),
      ),
    );
  }
}

// Usage:
// SnackbarHelper.showSuccess(context, 'feedback', lang, cache);
// SnackbarHelper.showError(context, 'contact', lang, cache);
```

#### Task 5: Add Tests
```dart
// test/shared/functions/snackbar_messages_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:journeymate/shared/functions/snackbar_messages.dart';

void main() {
  group('getSnackbarMessage', () {
    final mockCache = {
      'snackbar_error': 'Error message',
      'snackbar_feedback_success': 'Feedback success',
      'snackbar_contact_success': 'Contact success',
      'snackbar_missing_location_success': 'Location success',
      'snackbar_erroneous_info_success': 'Info success',
    };

    test('returns error message for error type', () {
      final result = getSnackbarMessage('error', 'any', 'en', mockCache);
      expect(result, 'Error message');
    });

    test('returns feedback success message', () {
      final result = getSnackbarMessage('success', 'feedback', 'en', mockCache);
      expect(result, 'Feedback success');
    });

    test('returns contact success message', () {
      final result = getSnackbarMessage('success', 'contact', 'en', mockCache);
      expect(result, 'Contact success');
    });

    test('returns missing location success message', () {
      final result = getSnackbarMessage('success', 'missing_location', 'en', mockCache);
      expect(result, 'Location success');
    });

    test('returns erroneous info success message', () {
      final result = getSnackbarMessage('success', 'erroneous_info', 'en', mockCache);
      expect(result, 'Info success');
    });

    test('returns invalid form type for unknown form', () {
      final result = getSnackbarMessage('success', 'unknown', 'en', mockCache);
      expect(result, 'Invalid form type');
    });

    test('returns invalid message type for unknown type', () {
      final result = getSnackbarMessage('warning', 'feedback', 'en', mockCache);
      expect(result, 'Invalid message type');
    });
  });
}
```

---

## Related Functions

### Direct Dependencies
1. **`getTranslations()`**
   - Location: `custom_functions.dart` (lines 2161-2235)
   - Purpose: Retrieves localized string from translation cache
   - Documentation: `MASTER_README_get_translations.md`

### Related User Feedback Functions
1. **Form validation functions** (to be documented)
   - Email validation
   - Text length validation
   - Required field checks

2. **BuildShip API submission wrappers** (to be documented)
   - `submitFeedback()`
   - `submitContactRequest()`
   - `reportMissingLocation()`
   - `reportErroneousInfo()`

---

## Design System Alignment

### Color Usage
**From `_reference/journeymate-design-system.md`:**

- **Success Snackbars:** Use `GREEN (#1A9456)` background
  - Indicates successful form submission
  - Confirms positive user action completed

- **Error Snackbars:** Use error red (`#E74C3C` or similar) background
  - Indicates failed operation
  - Requires user attention/retry

**DO NOT use `ACCENT (#E8751A)` for snackbars** — orange is reserved for interactive elements and CTAs, not status indicators.

### Typography
- **Snackbar Text:** Use body text style (weight 400-500)
- **Font Size:** 14-16px for readability
- **Line Height:** 1.4-1.5 for multi-line messages

### Positioning
- **Mobile:** Bottom of screen (standard Material Design)
- **Duration:** 3-4 seconds (user has time to read)
- **Dismissal:** Auto-dismiss OR swipe-to-dismiss

---

## Form Type to Page Mapping

| Form Type | Page/Widget | Trigger |
|-----------|-------------|---------|
| `feedback` | Profile page → Feedback form | After BuildShip API call |
| `contact` | Profile page → Contact form | After BuildShip API call |
| `missing_location` | Search results → Report missing location | After BuildShip API call |
| `erroneous_info` | Business Profile page → Report error | After BuildShip API call |

---

## Translation Key Organization

### Supabase `translations` Table Structure
```sql
CREATE TABLE translations (
  id BIGSERIAL PRIMARY KEY,
  translation_key TEXT NOT NULL,
  language_code TEXT NOT NULL,
  translation_value TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(translation_key, language_code)
);
```

### Example Rows
```sql
INSERT INTO translations (translation_key, language_code, translation_value) VALUES
  ('snackbar_error', 'da', 'Noget gik galt. Prøv venligst igen.'),
  ('snackbar_error', 'en', 'Something went wrong. Please try again.'),
  ('snackbar_feedback_success', 'da', 'Tak for din feedback!'),
  ('snackbar_feedback_success', 'en', 'Thank you for your feedback!');
```

---

## Performance Considerations

1. **Translation Cache:** Pre-loaded at app launch; no runtime API calls
2. **Function Execution:** Constant-time string comparison (O(1))
3. **Memory Footprint:** Minimal (5 translation keys per language)
4. **Snackbar Rendering:** Standard Material widget (no custom rendering)

---

## Accessibility Notes

1. **Screen Readers:** Snackbar content should be announced automatically
2. **High Contrast:** Ensure sufficient contrast between text and background
3. **Duration:** Allow enough time for users to read message (3-4 seconds minimum)
4. **Alternative Feedback:** Consider pairing with haptic feedback for success/error

---

## Future Enhancements

### Potential Improvements (Not in Current Scope)
1. **Add Undo Action:** For reversible operations (e.g., "Message sent" with "Undo" button)
2. **Custom Icons:** Add icons to snackbars (✓ for success, ⚠ for error)
3. **Animation:** Slide-in animation for snackbar appearance
4. **Queue Management:** Handle multiple snackbars in rapid succession
5. **Persistent Errors:** Option to show critical errors until dismissed

---

## Changelog

### Version 1.0 (2026-02-19)
- Initial documentation created from FlutterFlow source
- Documented all 4 form types and 2 message types
- Added translation key reference for 7 languages
- Created migration guide for Phase 3
- Added usage examples and edge case handling

---

## Document Maintenance

**Update Triggers:**
- New form type added (update formType mapping)
- New language added (add translation keys)
- Translation key structure changes (update reference)
- Snackbar design changes (update color/typography specs)

**Related Documentation:**
- `MASTER_README_get_translations.md` (translation system)
- `journeymate-design-system.md` (color/typography rules)
- `page-audit.md` (form submission flows)

---

*End of Documentation*
