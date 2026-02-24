# Share Feedback — Integration Guide
## From JSX UI Shell to Full Implementation

**Starting Point:** `share_feedback_page_from_jsx.dart` (clean Flutter UI, no backend)
**Reference:** `BUNDLE_share_feedback.md` (tells you what to add)
**Examples:** FlutterFlow `share_feedback_page.dart` (working implementations)

---

## Step 1: Translation System ✅

**Goal:** Replace all hardcoded English text with translation keys

### What to Add (from BUNDLE):

**15 Translation keys needed:**
```dart
// App bar
feedback_form_title

// Heading & description
feedback_form_heading
feedback_form_description

// Category field
feedback_form_field_category
feedback_form_field_category_description
feedback_topic_wrong_info
feedback_topic_app_ideas
feedback_topic_bug
feedback_topic_missing_place
feedback_topic_suggestion
feedback_topic_praise
feedback_topic_other

// Message field
feedback_form_field_message
feedback_form_field_message_description

// Checkbox
feedback_form_checkbox_contact
feedback_form_checkbox_contact_description

// Contact fields
feedback_form_field_name
feedback_form_field_contact
feedback_form_field_contact_description

// Button
feedback_form_button_submit

// Validation errors (add later)
feedback_form_error_topic_required
feedback_form_error_message_required
feedback_form_error_message_too_short
feedback_form_error_name_required
feedback_form_error_contact_required

// Response messages (add later)
feedback_form_success
feedback_form_error_submission_failed
```

### How to Add:

1. **Create translation helper function:**
```dart
String _getUIText(String key) {
  final appState = context.read<AppState>();
  return getTranslations(
    appState.userLanguageCode,
    key,
    appState.translationsCache,
  );
}
```

2. **Replace hardcoded text:**
```dart
// Before:
title: const Text('Share feedback'),

// After:
title: Text(_getUIText('feedback_form_title')),
```

3. **Update category list:**
```dart
// Before:
final List<String> _categories = [
  'Wrong information',
  'Ideas for the app',
  // ...
];

// After:
final List<String> _categoryKeys = [
  'feedback_topic_wrong_info',
  'feedback_topic_app_ideas',
  // ...
];

// In build method:
_categoryKeys.map((key) {
  final label = _getUIText(key);
  // ...
}).toList()
```

**Reference Example:** See FlutterFlow `share_feedback_page.dart` lines 80-87

---

## Step 2: User Engagement Tracking ✅

**Goal:** Track when user leaves the page via back button

### What to Add (from BUNDLE):

**Action:** `markUserEngaged()` on back button press

### How to Add:

1. **Import the action:**
```dart
import '../actions/mark_user_engaged.dart';
```

2. **Update back button:**
```dart
// Before:
onPressed: () {
  Navigator.of(context).pop();
},

// After:
onPressed: () async {
  await markUserEngaged();
  if (!context.mounted) return;
  Navigator.of(context).pop();
},
```

**Reference Example:** See FlutterFlow `share_feedback_page.dart` lines 205-208

---

## Step 3: Page Analytics ✅

**Goal:** Track page view duration when user leaves

### What to Add (from BUNDLE):

**Event:** `page_viewed` with `pageName` and `durationSeconds`

### How to Add:

1. **Import the action:**
```dart
import '../actions/track_analytics_event.dart';
```

2. **Add state variable:**
```dart
DateTime? _pageStartTime;
```

3. **Record start time in initState:**
```dart
@override
void initState() {
  super.initState();
  SchedulerBinding.instance.addPostFrameCallback((_) {
    _pageStartTime = DateTime.now();
  });
}
```

4. **Track on dispose:**
```dart
@override
void dispose() {
  if (_pageStartTime != null) {
    final duration = DateTime.now().difference(_pageStartTime!).inSeconds;
    trackAnalyticsEvent('page_viewed', <String, String>{
      'pageName': 'shareFeedbackSettings',
      'durationSeconds': duration.toString(),
    });
  }
  _messageController.dispose();
  _nameController.dispose();
  _contactController.dispose();
  super.dispose();
}
```

**Reference Example:** See FlutterFlow `share_feedback_page.dart` lines 58-78

---

## Step 4: Form Validation ✅

**Goal:** Add proper validation with error messages

### What to Add (from BUNDLE):

**Validation rules:**
- Category: Required (show error on submit if not selected)
- Message: Required, min 10 characters
- Name: Required if `allowContact` is true
- Contact: Required if `allowContact` is true

### How to Add:

1. **Add form key:**
```dart
final _formKey = GlobalKey<FormState>();
```

2. **Wrap in Form widget:**
```dart
Form(
  key: _formKey,
  child: Column(
    // ... existing content
  ),
)
```

3. **Add validation to message field:**
```dart
TextFormField(
  controller: _messageController,
  maxLines: 6,
  decoration: InputDecoration(
    // ... existing decoration
  ),
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return _getUIText('feedback_form_error_message_required');
    }
    if (value.trim().length < 10) {
      return _getUIText('feedback_form_error_message_too_short');
    }
    return null;
  },
)
```

4. **Add category validation in submit:**
```dart
void _handleSubmit() {
  // Validate category selection
  if (_selectedCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_getUIText('feedback_form_error_topic_required')),
        backgroundColor: const Color(0xFFC9403A),
      ),
    );
    return;
  }

  if (!_formKey.currentState!.validate()) {
    return;
  }

  // ... rest of submit logic
}
```

5. **Add conditional validation for contact fields:**
```dart
TextFormField(
  controller: _nameController,
  decoration: InputDecoration(/* ... */),
  validator: (value) {
    if (_allowContact && (value == null || value.trim().isEmpty)) {
      return _getUIText('feedback_form_error_name_required');
    }
    return null;
  },
)
```

**Reference Example:** See FlutterFlow `share_feedback_page.dart` lines 89-103, 354-362, 438-443, 484-490

---

## Step 5: BuildShip API Integration ✅

**Goal:** Submit feedback to backend

### What to Add (from BUNDLE):

**API Endpoint:** `https://wvb8ww.buildship.run/feedbackform`

**Request:**
- Method: POST
- Headers: `Content-Type: application/json`
- Body:
  ```json
  {
    "topic": "selected category label",
    "message": "user message",
    "languageCode": "en",
    "allowContact": true,
    "name": "optional if allowContact true",
    "contact": "optional if allowContact true"
  }
  ```

**Response:**
- Success: `{ "success": true }`
- Error: `{ "success": false, "error": "error message" }`

### How to Add:

1. **Import http package:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../app_state.dart';
```

2. **Add loading state:**
```dart
bool _isSubmitting = false;
```

3. **Update submit method:**
```dart
Future<void> _handleSubmit() async {
  // Validation (from Step 4)
  if (_selectedCategory == null) { /* ... */ }
  if (!_formKey.currentState!.validate()) { /* ... */ }

  setState(() {
    _isSubmitting = true;
  });

  try {
    final appState = context.read<AppState>();

    // Build request body
    final body = {
      'topic': _selectedCategory,
      'message': _messageController.text,
      'languageCode': appState.userLanguageCode,
      'allowContact': _allowContact,
    };

    // Only include name/contact if checkbox enabled AND fields have values
    if (_allowContact) {
      if (_nameController.text.isNotEmpty) {
        body['name'] = _nameController.text;
      }
      if (_contactController.text.isNotEmpty) {
        body['contact'] = _contactController.text;
      }
    }

    final response = await http.post(
      Uri.parse('https://wvb8ww.buildship.run/feedbackform'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Parse response body
      final responseData = json.decode(response.body);
      if (responseData['success'] != true) {
        throw Exception(responseData['error'] ?? 'Unknown error occurred');
      }

      // Success - track analytics
      trackAnalyticsEvent('feedback_form_submitted', <String, String>{
        'topic': _selectedCategory!,
      });

      // Clear form
      setState(() {
        _selectedCategory = null;
        _allowContact = false;
      });
      _messageController.clear();
      _nameController.clear();
      _contactController.clear();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getUIText('feedback_form_success')),
            backgroundColor: AppColors.green,
          ),
        );

        // Navigate back after short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } else {
      throw Exception('Server error');
    }
  } catch (e) {
    // Network error
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getUIText('feedback_form_error_submission_failed')),
          backgroundColor: const Color(0xFFC9403A),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
```

4. **Update submit button to show loading:**
```dart
ElevatedButton(
  onPressed: _isSubmitting ? null : _handleSubmit,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
    // ...
  ),
  child: _isSubmitting
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
      : Text(_getUIText('feedback_form_button_submit')),
)
```

**Reference Example:** See FlutterFlow `share_feedback_page.dart` lines 89-194

---

## Complete Integration Checklist

### Step 1: Translation System
- [ ] Import translation helper
- [ ] Replace all hardcoded text (15 keys)
- [ ] Test language switching

### Step 2: User Engagement
- [ ] Import markUserEngaged action
- [ ] Add to back button
- [ ] Test tracking fires

### Step 3: Page Analytics
- [ ] Import trackAnalyticsEvent action
- [ ] Add pageStartTime state
- [ ] Track in initState
- [ ] Track in dispose
- [ ] Verify event data

### Step 4: Form Validation
- [ ] Add Form widget and key
- [ ] Add validators to all fields
- [ ] Add category validation
- [ ] Test error messages
- [ ] Test conditional validation

### Step 5: API Integration
- [ ] Import http package
- [ ] Add loading state
- [ ] Build request body correctly
- [ ] Handle success response
- [ ] Handle error response
- [ ] Add success snackbar
- [ ] Add error snackbar
- [ ] Track submission analytics
- [ ] Test form reset
- [ ] Test navigation after success

---

## Final Result

You'll have:
- ✅ Clean JSX-based UI (from Step 0)
- ✅ Full translation system (Step 1)
- ✅ User engagement tracking (Step 2)
- ✅ Page view analytics (Step 3)
- ✅ Form validation (Step 4)
- ✅ Backend API integration (Step 5)

**Best of both worlds:** JSX beauty + FlutterFlow functionality!

---

**Estimated Time:**
- Step 1 (Translations): 30 minutes
- Step 2 (Engagement): 5 minutes
- Step 3 (Analytics): 10 minutes
- Step 4 (Validation): 20 minutes
- Step 5 (API): 30 minutes
- **Total: ~1.5 hours** (vs 3-4 hours refactoring FlutterFlow code)

---

**Last Updated:** 2026-02-19
**Status:** Complete integration guide, step-by-step from JSX shell to full implementation
