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
