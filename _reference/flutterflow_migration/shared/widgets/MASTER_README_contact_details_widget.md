# ContactDetailsWidget - Custom Widget Documentation

**Source File:** `_flutterflow_export\lib\custom_code\widgets\contact_details_widget.dart`
**Widget Type:** Custom StatefulWidget (FlutterFlow export)
**Last Updated:** 2026-02-19
**Migration Status:** Not yet migrated to Phase 3

---

## Purpose

ContactDetailsWidget displays comprehensive business contact information with consistent typography across all accessibility settings. It provides interactive elements for common user actions like calling, emailing, viewing on maps, and visiting social media profiles.

**Key Features:**
- Consistent bold text rendering matching app-wide standards
- Conditional display of contact methods based on availability
- Integrated with translation system for multilingual support
- Responsive spacing based on accessibility settings (bold text enabled/disabled)
- Composes OpeningHoursAndWeekdays widget for hours display
- Interactive elements with engagement tracking
- Tap-to-call, tap-to-email, tap-to-map functionality
- Long-press copy-to-clipboard for phone and email
- External app integrations (maps, phone dialer, email client, social media)

**Data Sources:**
- Business info from `FFAppState().mostRecentlyViewedBusiness`
- Opening hours from `FFAppState().openingHours`

---

## Function Signature

```dart
class ContactDetailsWidget extends StatefulWidget {
  const ContactDetailsWidget({
    super.key,
    this.width,
    this.height,
    required this.languageCode,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final String languageCode;
  final dynamic translationsCache;
}
```

---

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `languageCode` | `String` | ISO language code for localized translations (e.g., 'en', 'da', 'de') |
| `translationsCache` | `dynamic` | Translation cache from FFAppState containing all UI text |

### Optional Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `width` | `double?` | Widget width | `null` (uses parent constraints) |
| `height` | `double?` | Widget height | `null` (uses parent constraints) |

---

## Dependencies

### FlutterFlow Dependencies
- `FFAppState` - Global app state for business data and accessibility settings
- `FlutterFlowTheme` - Theme system for primary color
- `getJsonField()` - Safe JSON field extraction
- `getTranslations()` - Translation function

### Custom Dependencies
- `OpeningHoursAndWeekdays` widget - Displays opening hours in structured format
- `CopyToClipboardPhoneWidget` - Dialog for copying phone numbers
- `CopyToClipboardEmailWidget` - Dialog for copying email addresses
- `markUserEngaged()` action - Tracks user engagement for analytics

### External Packages
- `map_launcher` (as `$ml`) - Launches map apps with addresses
- `url_launcher` - Opens URLs, phone dialer, and email client

### Flutter SDK
- `flutter/material.dart` - Core UI framework
- `showDialog()` - Dialog display
- `showModalBottomSheet()` - Not used in this widget but common in parent contexts

---

## FFAppState Usage

### Read Access

| State Variable | Type | Usage |
|----------------|------|-------|
| `FFAppState().mostRecentlyViewedBusiness` | `dynamic` (JSON) | Source of all business contact information |
| `FFAppState().openingHours` | `dynamic` (JSON) | Opening hours data passed to OpeningHoursAndWeekdays widget |
| `FFAppState().isBoldTextEnabled` | `bool` | Controls spacing adjustments for accessibility |

### Business Data Fields (from `mostRecentlyViewedBusiness`)

| JSON Path | Type | Usage | Nullable |
|-----------|------|-------|----------|
| `$.businessInfo.business_name` | String | Business name for map integration | No |
| `$.businessInfo.street` | String | Street address | No |
| `$.businessInfo.postal_code` | String | Postal code | No |
| `$.businessInfo.postal_city` | String | City name | No |
| `$.businessInfo.latitude` | double | Map coordinates | Yes |
| `$.businessInfo.longitude` | double | Map coordinates | Yes |
| `$.businessInfo.general_phone` | String | Phone number | Yes |
| `$.businessInfo.general_email` | String | Email address | Yes |
| `$.businessInfo.website_url` | String | Website URL | Yes |
| `$.businessInfo.reservation_url` | String | Reservation system URL | Yes |
| `$.businessInfo.instagram_url` | String | Instagram profile URL | Yes |
| `$.businessInfo.facebook_url` | String | Facebook page URL | Yes |

### Write Access

None - this widget is read-only.

---

## Translation Keys

All UI text is translated using the `getTranslations()` function. Translation keys are defined in the `_TranslationKeys` class:

| Key | Translation Key ID | English Text | Usage |
|-----|-------------------|--------------|-------|
| `address` | `fvn7c52j` | "Address" | Address section header |
| `viewOnMap` | `wemfo75s` | "View on map" | Map link text |
| `openingHours` | `v1z4dvep` | "Opening hours" | Hours section header |
| `contactInformation` | `s0a1ukr7` | "Contact information" | Contact section header |
| `phoneNumber` | `nd4d9n42` | "Phone number" | Phone row label |
| `email` | `z32g0m7g` | "Email" | Email row label |
| `sendEmail` | `4p3u9ngw` | "Send email" | Email action text |
| `website` | `8pvvg34m` | "Website" | Website row label |
| `visitWebsite` | `9hmbepnd` | "Visit website" | Website action text |
| `reservation` | `zaws00rk` | "Reservation" | Reservation row label |
| `makeReservation` | `g6jqo5n0` | "Make reservation" | Reservation action text |
| `instagram` | `35r2ixsz` | "Instagram" | Instagram row label |
| `viewOnInstagram` | `i39eb4yz` | "View on Instagram" | Instagram action text |
| `facebook` | `ehwtf95b` | "Facebook" | Facebook row label |
| `viewOnFacebook` | `nhhhl06z` | "View on Facebook" | Facebook action text |

### Translation Usage Pattern

```dart
String _getUIText(String key) {
  return getTranslations(
    widget.languageCode,
    key,
    widget.translationsCache,
  );
}
```

---

## Analytics Tracking

### User Engagement Events

All interactive elements call `markUserEngaged()` before performing their action. This tracks user engagement for analytics:

| Action | Function Called | Engagement Tracked |
|--------|----------------|-------------------|
| View on map tap | `_handleMapTap()` | Yes |
| Phone number tap (call) | `_handlePhoneTap()` | Yes |
| Phone long-press (copy) | `_handlePhoneLongPress()` | Yes |
| Email tap (send) | `_handleEmailTap()` | Yes |
| Email long-press (copy) | `_handleEmailLongPress()` | Yes |
| Website link tap | `_handleWebsiteTap()` | Yes |
| Reservation link tap | `_handleReservationTap()` | Yes |
| Instagram link tap | `_handleInstagramTap()` | Yes |
| Facebook link tap | `_handleFacebookTap()` | Yes |

### Engagement Implementation

```dart
Future<void> _handleMapTap() async {
  await markUserEngaged(); // Tracks engagement first
  await launchMap(...);    // Then performs action
}
```

**Note:** `markUserEngaged()` uses SharedPreferences to communicate with the engagement tracker in `main.dart`. It updates a `last_user_activity` timestamp that extends the user's engaged time window by 15 seconds.

---

## Widget Structure

### Layout Hierarchy

```
ContactDetailsWidget (Column)
├── _buildAddressSection() - Address and map link
│   ├── "Address" title (translated)
│   ├── Street address
│   ├── Postal code and city
│   └── "View on map" link (tappable)
│
├── _buildOpeningHoursSection() - Hours display
│   ├── "Opening hours" title (translated)
│   └── OpeningHoursAndWeekdays widget
│
└── _buildContactInfoSection() - All contact methods
    ├── "Contact information" title (translated)
    └── _buildContactMethodsList() - Dynamic list
        ├── Phone row (if available)
        ├── Email row (if available)
        ├── Website row (if available)
        ├── Reservation row (if available)
        ├── Instagram row (if available)
        └── Facebook row (if available)
```

### Section Spacing

Sections are divided by dynamic spacing based on accessibility settings:

- **Normal mode:** 16.0 pixels
- **Bold text enabled:** 20.0 pixels

```dart
double get _sectionSpacing {
  return FFAppState().isBoldTextEnabled
      ? _LayoutConstants.sectionSpacingBold
      : _LayoutConstants.sectionSpacingNormal;
}
```

---

## Layout Constants

### Spacing

| Constant | Value | Usage |
|----------|-------|-------|
| `sectionSpacingNormal` | 16.0 | Gap between major sections (normal) |
| `sectionSpacingBold` | 20.0 | Gap between major sections (bold text) |
| `itemSpacing` | 2.0 | Gap between items within a section |
| `contactInfoTopPaddingNormal` | 0.0 | Contact section top padding (normal) |
| `contactInfoTopPaddingBold` | 2.0 | Contact section top padding (bold) |
| `contactInfoBottomPadding` | 8.0 | Contact section bottom padding |

### Typography

| Constant | Value | Usage |
|----------|-------|-------|
| `titleFontSize` | 18.0 | Section headers |
| `bodyFontSize` | 16.0 | Body text and links |
| `titleWeight` | `FontWeight.normal` | Section headers weight |
| `bodyLightWeight` | `FontWeight.w300` | Light labels |
| `bodyNormalWeight` | `FontWeight.normal` | Interactive links |

### Colors

| Constant | Value | Usage |
|----------|-------|-------|
| `textPrimary` | `Color(0xFF14181B)` | All text |
| `divider` | `Color(0x4057636C)` | Row dividers (25% opacity) |

**Note:** Interactive elements use `FlutterFlowTheme.of(context).primary` for link color (orange in JourneyMate design system).

---

## Conditional Rendering Logic

### Contact Methods Visibility

Contact method rows are only displayed if the corresponding data exists:

```dart
List<Widget> _buildContactMethodsList() {
  final methods = <Widget>[];

  if (_phoneGeneral != null) {
    methods.add(_buildPhoneRow());
  }

  if (_emailGeneral != null) {
    methods.add(_buildEmailRow());
  }

  // ... etc for website, reservation, social media

  return methods;
}
```

### Null Handling

Fields are extracted safely with fallback values:

```dart
String _getBusinessField(String jsonPath, {String fallback = ''}) {
  final value = getJsonField(_businessData, jsonPath);
  if (value == null) return fallback;
  final stringValue = value.toString();
  // Treat 'null' string as null value
  return stringValue == 'null' ? fallback : stringValue;
}
```

**Special Cases:**
- Empty strings are treated as null for optional fields (phone, email, URLs)
- String value "null" is treated as actual null
- Address fields (street, postal code, city) always display (use empty string fallback)

---

## User Interaction Patterns

### Map Integration

**Tap behavior:** Opens Google Maps with business address

```dart
Future<void> _handleMapTap() async {
  await markUserEngaged();

  await launchMap(
    mapType: $ml.MapType.google,
    address: '$_businessName, $_street, $_postalCode $_postalCity',
    title: _businessName,
  );
}
```

**Package:** `map_launcher` handles map app selection and URL formatting

---

### Phone Number Interaction

**Tap behavior:** Initiates phone call

```dart
Future<void> _handlePhoneTap(String phone) async {
  await markUserEngaged();

  await launchUrl(Uri(
    scheme: 'tel',
    path: '+45$phone',
  ));
}
```

**Long-press behavior:** Shows copy-to-clipboard dialog

```dart
Future<void> _handlePhoneLongPress(String phone) async {
  await markUserEngaged();

  if (!mounted) return;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        alignment: const AlignmentDirectional(0, 1),
        child: CopyToClipboardPhoneWidget(
          phoneNumber: '+45$phone',
        ),
      );
    },
  );
}
```

**Display format:** `+45 XXXXXXXX` (Danish country code hardcoded)

**Dialog behavior:**
1. Shows "Tap here to copy the phone number" prompt
2. On tap, copies to clipboard and shows success message
3. Auto-dismisses after 1500ms

---

### Email Interaction

**Tap behavior:** Opens email client with pre-filled recipient

```dart
Future<void> _handleEmailTap(String email) async {
  await markUserEngaged();

  await launchUrl(Uri(
    scheme: 'mailto',
    path: email,
  ));
}
```

**Long-press behavior:** Shows copy-to-clipboard dialog

```dart
Future<void> _handleEmailLongPress(String email) async {
  await markUserEngaged();

  if (!mounted) return;

  await showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        alignment: const AlignmentDirectional(0, 1),
        child: CopyToClipboardEmailWidget(
          email: email,
        ),
      );
    },
  );
}
```

**Dialog behavior:**
1. Shows "Tap here to copy the email" prompt
2. On tap, copies to clipboard and shows success message
3. Auto-dismisses after 1500ms

---

### URL Interaction

All URL-based interactions (website, reservation, Instagram, Facebook) use the same pattern:

```dart
Future<void> _handleWebsiteTap(String url) async {
  await markUserEngaged();
  await launchURL(url); // FlutterFlow utility function
}
```

**URL Types:**
- **Website:** Opens business website in external browser
- **Reservation:** Opens third-party reservation system (e.g., Resengo)
- **Instagram:** Opens Instagram profile (app or web)
- **Facebook:** Opens Facebook page (app or web)

---

## Opening Hours Integration

The widget composes the `OpeningHoursAndWeekdays` widget for displaying hours:

```dart
Widget _buildOpeningHoursSection() {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        _getUIText(_TranslationKeys.openingHours),
        style: _getTitleStyle(),
      ),
      OpeningHoursAndWeekdays(
        width: double.infinity,
        languageCode: widget.languageCode,
        openingHours: _openingHours,
        translationsCache: widget.translationsCache,
      ),
    ].divide(const SizedBox(height: _LayoutConstants.itemSpacing)),
  );
}
```

**Data Flow:**
1. Opening hours data is read from `FFAppState().openingHours`
2. Passed directly to `OpeningHoursAndWeekdays` widget
3. Widget handles formatting and display logic internally

**See:** `MASTER_README_opening_hours_and_weekdays.md` for detailed hours display documentation

---

## Typography System

### Text Styles

The widget uses three consistent text styles:

#### Title Style (Section Headers)
```dart
TextStyle _getTitleStyle() {
  return const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 18.0,
    fontWeight: FontWeight.normal,
    color: Color(0xFF14181B),
  );
}
```

**Usage:** "Address", "Opening hours", "Contact information"

#### Body Light Style (Labels)
```dart
TextStyle _getBodyLightStyle() {
  return const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16.0,
    fontWeight: FontWeight.w300,
    color: Color(0xFF14181B),
  );
}
```

**Usage:** Street address, postal code/city, contact method labels

#### Body Normal Style (Interactive Links)
```dart
TextStyle _getBodyNormalStyle() {
  return const TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: Color(0xFF14181B),
  );
}
```

**Usage:** Base for all interactive elements (color overridden to primary)

### Link Color Override

All interactive elements override the base text color:

```dart
style: _getBodyNormalStyle().copyWith(
  color: FlutterFlowTheme.of(context).primary, // Orange (#e8751a)
),
```

---

## Widget Lifecycle

### Initialization

No special initialization required. Widget is stateless for data purposes (reads from FFAppState on each build).

### Updates

Widget rebuilds when translation or language changes:

```dart
@override
void didUpdateWidget(ContactDetailsWidget oldWidget) {
  super.didUpdateWidget(oldWidget);

  // Rebuild when translations or language changes
  if (widget.translationsCache != oldWidget.translationsCache ||
      widget.languageCode != oldWidget.languageCode) {
    setState(() {});
  }
}
```

**Trigger:** Parent widget passes new `translationsCache` or `languageCode`

### Disposal

No special cleanup required (no controllers or subscriptions).

---

## Usage Examples

### Example 1: Basic Usage on Business Profile Page

```dart
// From business_profile_page.dart
ContactDetailsWidget(
  languageCode: FFAppState().activeLanguageCode,
  translationsCache: FFAppState().translationsCache,
)
```

**Context:** Displayed as a section in the business profile page scrollable content.

**Prerequisites:**
- `FFAppState().mostRecentlyViewedBusiness` must be populated
- `FFAppState().openingHours` must be populated
- User has selected a business (navigated from search results)

---

### Example 2: With Custom Dimensions

```dart
ContactDetailsWidget(
  width: 350.0,
  height: 600.0,
  languageCode: 'da',
  translationsCache: FFAppState().translationsCache,
)
```

**Note:** Width/height parameters exist for FlutterFlow compatibility but are typically unused. Widget size is controlled by parent constraints.

---

### Example 3: Language Switching

```dart
// When user changes language
setState(() {
  FFAppState().activeLanguageCode = 'de';
});

// Widget automatically rebuilds with new translations via didUpdateWidget
```

---

## Error Handling

### Missing Business Data

Widget handles missing data gracefully:

```dart
String? get _phoneGeneral {
  final phone = _getBusinessField(r'''$.businessInfo.general_phone''');
  return phone.isEmpty ? null : phone;
}
```

**Behavior:** If field is null, empty, or string "null", the entire contact method row is hidden.

### Failed External Actions

External actions (map launch, URL open) fail silently:

```dart
Future<void> _handleMapTap() async {
  await markUserEngaged();

  await launchMap(...); // May throw, but not caught
}
```

**Rationale:** FlutterFlow's `launchMap()` and `launchURL()` functions handle errors internally and show OS-level error messages to user.

### Engagement Tracking Failures

Engagement tracking fails silently:

```dart
// From mark_user_engaged.dart
try {
  final prefs = await SharedPreferences.getInstance();
  final now = DateTime.now().millisecondsSinceEpoch;
  await prefs.setInt('last_user_activity', now);
  debugPrint('👆 User engagement marked at $now');
} catch (e) {
  // Fail silently - engagement tracking is non-critical
  debugPrint('⚠️ Failed to mark user engaged: $e');
}
```

**Behavior:** If SharedPreferences access fails, user interaction still proceeds normally.

### Mounted Check for Dialogs

Dialogs check `mounted` status before showing:

```dart
Future<void> _handlePhoneLongPress(String phone) async {
  await markUserEngaged();

  if (!mounted) return; // Prevents showing dialog on disposed widget

  await showDialog(...);
}
```

---

## Testing Checklist

### Unit Tests

- [ ] `_getBusinessField()` returns correct value for valid JSON path
- [ ] `_getBusinessField()` returns fallback for null value
- [ ] `_getBusinessField()` treats string "null" as null
- [ ] `_getBusinessField()` returns fallback for empty string
- [ ] Phone number getter returns null for empty phone
- [ ] Email getter returns null for empty email
- [ ] Section spacing returns 20.0 when bold text enabled
- [ ] Section spacing returns 16.0 when bold text disabled
- [ ] Translation function is called with correct key and language code

### Widget Tests

- [ ] Widget renders address section with all fields
- [ ] Widget renders opening hours section
- [ ] Widget renders contact info section header
- [ ] Phone row displays when phone number exists
- [ ] Phone row hidden when phone number is null
- [ ] Email row displays when email exists
- [ ] Email row hidden when email is null
- [ ] Website row displays when URL exists
- [ ] Website row hidden when URL is null
- [ ] Reservation row displays when URL exists
- [ ] Instagram row displays when URL exists
- [ ] Facebook row displays when URL exists
- [ ] Multiple contact methods display in correct order
- [ ] Dividers render between contact method rows
- [ ] Interactive text uses primary color
- [ ] Non-interactive text uses text primary color
- [ ] Widget rebuilds when translationsCache changes
- [ ] Widget rebuilds when languageCode changes

### Integration Tests

- [ ] Map link opens Google Maps with correct address
- [ ] Phone tap initiates phone call with +45 prefix
- [ ] Phone long-press shows copy dialog
- [ ] Phone copy dialog copies correct number to clipboard
- [ ] Phone copy dialog shows success message
- [ ] Phone copy dialog auto-dismisses after 1500ms
- [ ] Email tap opens email client with correct recipient
- [ ] Email long-press shows copy dialog
- [ ] Email copy dialog copies correct email to clipboard
- [ ] Email copy dialog shows success message
- [ ] Email copy dialog auto-dismisses after 1500ms
- [ ] Website link opens external browser
- [ ] Reservation link opens reservation system
- [ ] Instagram link opens Instagram profile
- [ ] Facebook link opens Facebook page
- [ ] All interactions call `markUserEngaged()`
- [ ] Engagement timestamp updates in SharedPreferences

### Accessibility Tests

- [ ] Widget renders correctly with bold text enabled
- [ ] Section spacing increases with bold text enabled
- [ ] Contact info top padding increases with bold text enabled
- [ ] Text remains readable at all accessibility font sizes
- [ ] InkWell splash feedback is transparent (per design)
- [ ] Interactive elements have sufficient tap targets (48x48)

### Edge Cases

- [ ] Widget handles business with no contact methods
- [ ] Widget handles business with only address (no phone/email/URLs)
- [ ] Widget handles business with all contact methods
- [ ] Widget handles missing latitude/longitude (map link still works)
- [ ] Widget handles translation cache reload
- [ ] Widget handles language switch mid-display
- [ ] Dialog doesn't show if widget unmounted during async operation
- [ ] Multiple rapid taps don't open multiple dialogs
- [ ] Phone number formats correctly with +45 prefix
- [ ] Email addresses handle special characters

---

## Migration Notes

### Phase 3 Requirements

When migrating this widget to pure Flutter (Phase 3):

#### 1. State Management Migration

**Current:** Direct FFAppState access

```dart
dynamic get _businessData => FFAppState().mostRecentlyViewedBusiness;
dynamic get _openingHours => FFAppState().openingHours;
bool get _isBoldTextEnabled => FFAppState().isBoldTextEnabled;
```

**Phase 3:** Use Riverpod provider

```dart
// Create providers
final currentBusinessProvider = StateProvider<Business?>((ref) => null);
final openingHoursProvider = StateProvider<OpeningHours?>((ref) => null);
final accessibilityProvider = StateProvider<AccessibilitySettings>((ref) => AccessibilitySettings());

// In widget
class ContactDetailsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final business = ref.watch(currentBusinessProvider);
    final hours = ref.watch(openingHoursProvider);
    final accessibility = ref.watch(accessibilityProvider);

    // ...
  }
}
```

#### 2. Data Model Creation

**Current:** Dynamic JSON with `getJsonField()`

**Phase 3:** Type-safe data models

```dart
class BusinessContactInfo {
  final String businessName;
  final String street;
  final String postalCode;
  final String postalCity;
  final double? latitude;
  final double? longitude;
  final String? generalPhone;
  final String? generalEmail;
  final String? websiteUrl;
  final String? reservationUrl;
  final String? instagramUrl;
  final String? facebookUrl;

  BusinessContactInfo({
    required this.businessName,
    required this.street,
    required this.postalCode,
    required this.postalCity,
    this.latitude,
    this.longitude,
    this.generalPhone,
    this.generalEmail,
    this.websiteUrl,
    this.reservationUrl,
    this.instagramUrl,
    this.facebookUrl,
  });

  factory BusinessContactInfo.fromJson(Map<String, dynamic> json) {
    final businessInfo = json['businessInfo'] as Map<String, dynamic>;
    return BusinessContactInfo(
      businessName: businessInfo['business_name'] as String,
      street: businessInfo['street'] as String,
      postalCode: businessInfo['postal_code'] as String,
      postalCity: businessInfo['postal_city'] as String,
      latitude: businessInfo['latitude'] as double?,
      longitude: businessInfo['longitude'] as double?,
      generalPhone: _nullableString(businessInfo['general_phone']),
      generalEmail: _nullableString(businessInfo['general_email']),
      websiteUrl: _nullableString(businessInfo['website_url']),
      reservationUrl: _nullableString(businessInfo['reservation_url']),
      instagramUrl: _nullableString(businessInfo['instagram_url']),
      facebookUrl: _nullableString(businessInfo['facebook_url']),
    );
  }

  static String? _nullableString(dynamic value) {
    if (value == null || value == 'null') return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }
}
```

#### 3. Translation System Migration

**Current:** FlutterFlow `getTranslations()` function

**Phase 3:** Use `flutter_i18n` or similar

```dart
// Instead of:
String _getUIText(String key) {
  return getTranslations(
    widget.languageCode,
    key,
    widget.translationsCache,
  );
}

// Use:
import 'package:flutter_i18n/flutter_i18n.dart';

String _getUIText(BuildContext context, String key) {
  return FlutterI18n.translate(context, 'contact_details.$key');
}
```

#### 4. Theme Integration

**Current:** FlutterFlow theme + hardcoded constants

**Phase 3:** Use JourneyMate design system

```dart
// Create app_theme.dart with constants
class AppTheme {
  static const Color primaryOrange = Color(0xFFE8751A);
  static const Color textPrimary = Color(0xFF14181B);
  static const Color divider = Color(0x4057636C);

  static const double titleFontSize = 18.0;
  static const double bodyFontSize = 16.0;
}

// In widget:
style: TextStyle(
  fontSize: AppTheme.bodyFontSize,
  color: AppTheme.primaryOrange,
),
```

#### 5. Analytics Migration

**Current:** `markUserEngaged()` via SharedPreferences

**Phase 3:** Use Firebase Analytics or similar

```dart
// Create analytics service
class AnalyticsService {
  static Future<void> trackContactInteraction(String type) async {
    await FirebaseAnalytics.instance.logEvent(
      name: 'contact_interaction',
      parameters: {
        'interaction_type': type,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}

// In handlers:
Future<void> _handlePhoneTap(String phone) async {
  await AnalyticsService.trackContactInteraction('phone_call');
  await launchUrl(Uri(scheme: 'tel', path: '+45$phone'));
}
```

#### 6. Copy Dialog Migration

**Current:** FlutterFlow-generated dialog widgets

**Phase 3:** Create reusable dialog service

```dart
class ClipboardDialogService {
  static Future<void> showCopyPhoneDialog(
    BuildContext context,
    String phoneNumber,
  ) async {
    await showDialog(
      context: context,
      builder: (ctx) => _CopyDialog(
        title: 'Copy phone number',
        content: phoneNumber,
        onCopy: () => Clipboard.setData(ClipboardData(text: phoneNumber)),
      ),
    );
  }
}
```

#### 7. Testing Migration

**FlutterFlow widgets are not unit-testable in isolation.**

**Phase 3 Requirements:**
- Create mock providers for Riverpod
- Create test data fixtures for BusinessContactInfo
- Mock external dependencies (url_launcher, map_launcher)
- Test translation key lookup
- Test conditional rendering logic
- Integration test external app launches

---

### Breaking Changes from FlutterFlow

When migrating, note these FlutterFlow-specific features that will require changes:

| FlutterFlow Feature | Phase 3 Alternative |
|---------------------|---------------------|
| `FFAppState()` | Riverpod StateProvider |
| `getJsonField()` | Type-safe model classes |
| `getTranslations()` | flutter_i18n or similar |
| `FlutterFlowTheme.of(context)` | Custom ThemeData |
| `launchURL()` | `url_launcher` package directly |
| `launchMap()` | `map_launcher` package directly |
| `FFLocalizations` in dialogs | flutter_i18n throughout |
| Dynamic JSON state | Typed state classes |

---

### Design System Alignment

Verify alignment with `_reference/journeymate-design-system.md`:

- [ ] Orange (`#E8751A`) used for all interactive elements
- [ ] Orange NOT used for status indicators (that's green)
- [ ] Text primary (`#14181B`) used for body text
- [ ] Roboto font family throughout
- [ ] Font size 18 for section headers
- [ ] Font size 16 for body text
- [ ] Light weight (300) for labels
- [ ] Normal weight (400) for interactive text
- [ ] Spacing adjusts for bold text accessibility setting
- [ ] Divider opacity at 25%
- [ ] No star ratings displayed
- [ ] No black backgrounds

---

## Related Documentation

- **Opening Hours Display:** `MASTER_README_opening_hours_and_weekdays.md`
- **Business Profile Page:** `_reference/page-audit.md` (Business Profile section)
- **Translation System:** `MASTER_README_get_translations.md` (when created)
- **Analytics Tracking:** `MASTER_README_mark_user_engaged.md` (when created)
- **Design System:** `_reference/journeymate-design-system.md`

---

## Common Issues and Solutions

### Issue: Phone numbers not launching dialer

**Symptom:** Tap on phone number does nothing

**Cause:** `url_launcher` package not configured for iOS/Android

**Solution:**
- iOS: Add `LSApplicationQueriesSchemes` to Info.plist with `tel` scheme
- Android: No configuration needed (works by default)

---

### Issue: Map link opens wrong location

**Symptom:** Map shows incorrect or generic location

**Cause:** Address format not recognized by map app

**Solution:** Verify business name and full address are populated. Format: `Business Name, Street, Postal Code City`

---

### Issue: Copy dialog doesn't show

**Symptom:** Long-press does nothing

**Cause:** Widget unmounted during async operation

**Solution:** Already handled with `if (!mounted) return` check

---

### Issue: Translations not updating when language changes

**Symptom:** UI text remains in old language

**Cause:** Widget not rebuilding when translationsCache changes

**Solution:** Already handled in `didUpdateWidget()` - verify parent is passing updated translationsCache

---

### Issue: Contact methods showing when data is null

**Symptom:** Empty rows displayed

**Cause:** String "null" not being treated as actual null

**Solution:** Already handled with `stringValue == 'null' ? fallback : stringValue` check

---

### Issue: Bold text setting not affecting spacing

**Symptom:** Spacing doesn't increase when bold text enabled

**Cause:** FFAppState not updating correctly

**Solution:** Verify accessibility settings are properly persisted to FFAppState

---

## Performance Considerations

### Build Performance

- **Conditional widget building:** Only builds contact method rows that have data
- **Divide utility:** Efficiently adds spacing between sections
- **Const constructors:** Constants used where possible for optimization

### Async Operations

- **markUserEngaged():** ~1-2ms SharedPreferences write (non-blocking)
- **launchMap():** Async but doesn't block UI (opens external app)
- **launchUrl():** Async but doesn't block UI (opens external app/client)
- **showDialog():** UI blocking intentionally (user interaction required)

### Memory

- **No cached data:** Reads from FFAppState on each build (state is source of truth)
- **No subscriptions:** No StreamBuilder or listeners to manage
- **Dialog disposal:** Dialogs properly disposed when dismissed

---

## Summary

ContactDetailsWidget is a comprehensive, production-ready widget for displaying business contact information with:

- **Full translation support** via 13 translation keys
- **9 interaction types** (map, call, email, website, reservation, Instagram, Facebook, + copy dialogs)
- **User engagement tracking** on all interactions
- **Accessibility-aware spacing** for bold text setting
- **Type-safe null handling** for optional contact methods
- **External app integrations** via url_launcher and map_launcher
- **Elegant copy-to-clipboard UX** via long-press dialogs

The widget follows FlutterFlow patterns and is ready for Phase 3 migration to pure Flutter with Riverpod state management and type-safe models.
