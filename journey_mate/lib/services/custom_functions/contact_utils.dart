// Shared contact formatting utilities.
// Used by quick_actions_pills_widget and opening_hours_contact_widget.

/// Formats a phone number for dialing by stripping non-digits and prepending +45.
///
/// Examples:
///   "33 11 68 68" → "+4533116868"
///   "+45 33 11 68 68" → "+4533116868" (no double prefix)
///   "33116868" → "+4533116868"
String formatPhoneForDial(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.startsWith('45') && digits.length > 8) {
    return '+$digits';
  }
  return '+45$digits';
}

/// Formats a phone number for display with spacing: +45 XX XX XX XX.
///
/// Strips non-digits, detects existing +45 prefix, then groups the local
/// digits into pairs separated by spaces.
///
/// Examples:
///   "33116868"       → "+45 33 11 68 68"
///   "+4533116868"    → "+45 33 11 68 68"
///   "33 11 68 68"    → "+45 33 11 68 68"
///   "+45 40 40 96 04" → "+45 40 40 96 04"
String formatPhoneForDisplay(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  final String localDigits;
  if (digits.startsWith('45') && digits.length > 8) {
    localDigits = digits.substring(2);
  } else {
    localDigits = digits;
  }
  final buffer = StringBuffer('+45');
  for (int i = 0; i < localDigits.length; i += 2) {
    buffer.write(' ');
    final end = (i + 2 <= localDigits.length) ? i + 2 : localDigits.length;
    buffer.write(localDigits.substring(i, end));
  }
  return buffer.toString();
}

/// Ensures a URL has an https:// protocol prefix.
///
/// Returns the URL unchanged if it already has http:// or https://.
/// Otherwise prepends https://.
String ensureHttpsUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  return 'https://$url';
}
