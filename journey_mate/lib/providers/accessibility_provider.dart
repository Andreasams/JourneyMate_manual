import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Accessibility state
class AccessibilityState {
  final bool isBoldTextEnabled;
  final double fontScale;

  AccessibilityState({
    required this.isBoldTextEnabled,
    required this.fontScale,
  });

  AccessibilityState copyWith({
    bool? isBoldTextEnabled,
    double? fontScale,
  }) {
    return AccessibilityState(
      isBoldTextEnabled: isBoldTextEnabled ?? this.isBoldTextEnabled,
      fontScale: fontScale ?? this.fontScale,
    );
  }
}

/// Accessibility provider (Riverpod 3.x)
final accessibilityProvider =
    NotifierProvider<AccessibilityNotifier, AccessibilityState>(() {
  return AccessibilityNotifier();
});

class AccessibilityNotifier extends Notifier<AccessibilityState> {
  @override
  AccessibilityState build() {
    return AccessibilityState(isBoldTextEnabled: false, fontScale: 1.0);
  }

  /// Load accessibility settings from preferences
  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final isBold = prefs.getBool('is_bold_text_enabled') ?? false;
    final scale = prefs.getDouble('font_scale') ?? 1.0;

    state = AccessibilityState(isBoldTextEnabled: isBold, fontScale: scale);
  }

  /// Set bold text preference
  Future<void> setBoldText(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_bold_text_enabled', enabled);
    state = state.copyWith(isBoldTextEnabled: enabled);
  }

  /// Set font scale preference
  Future<void> setFontScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', scale);
    state = state.copyWith(fontScale: scale);
  }
}
