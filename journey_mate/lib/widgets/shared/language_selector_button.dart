import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/filter_providers.dart';
import '../../providers/app_providers.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';

/// LanguageSelectorButton - Settings button for language selection
///
/// Displays current language with a chevron icon. Tapping opens a custom
/// overlay dropdown with 7 language options (en, da, de, fr, it, no, sv).
/// Selecting a new language triggers localization update, translation reload,
/// filter reload, and currency auto-suggestion.
///
/// **IDENTICAL UI TO CurrencySelectorButton** — both use custom overlay pattern
///
/// Props:
/// - currentLanguageCode: Current language code (e.g., 'en', 'da')
/// - onLanguageSelected: Callback with new language code
/// - width: Button width
/// - height: Button height (defaults to 50px)
///
/// Provider Dependencies:
/// - localizationProvider: Trigger currency auto-suggestion after language change
/// - translationsCacheProvider: Trigger reload after language change
/// - filterProvider: Trigger reload after language change
/// - searchStateProvider: Invalidate cache (results are language-specific)
///
/// Design:
/// - Button: white background, border (#e8e8e8), parameterized height
/// - Displays current language name (e.g., "English", "Dansk")
/// - Chevron down/up icon on right
/// - Custom overlay dropdown positioned 4px below button
/// - Overlay matches button width
/// - Language names in native form (Dansk, not Danish)
class LanguageSelectorButton extends ConsumerStatefulWidget {
  const LanguageSelectorButton({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
    this.width,
    this.height,
  });

  final String currentLanguageCode;
  final Function(String) onLanguageSelected;
  final double? width;
  final double? height;

  @override
  ConsumerState<LanguageSelectorButton> createState() =>
      _LanguageSelectorButtonState();
}

class _LanguageSelectorButtonState
    extends ConsumerState<LanguageSelectorButton> {
  // ─────────────────────────────────────────────────────────────────────────────
  // State & Keys
  // ─────────────────────────────────────────────────────────────────────────────

  /// Global key to get button position for overlay placement
  final GlobalKey _buttonKey = GlobalKey();

  /// Tracks overlay entry for manual dismissal
  OverlayEntry? _overlayEntry;

  /// Tracks if overlay is currently visible
  bool _isOverlayVisible = false;

  /// Tracks last language change time for debouncing
  static DateTime? _lastLanguageChangeTime;

  /// Cooldown period between language changes (prevents race conditions)
  static const _languageChangeCooldown = Duration(milliseconds: 500);

  // ─────────────────────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _dismissOverlay();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Language Configuration
  // ─────────────────────────────────────────────────────────────────────────────

  // Language names in their native form (MUST NOT be translated)
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'da': 'Dansk',
    'de': 'Deutsch',
    'fr': 'Français',
    'it': 'Italiano',
    'no': 'Norsk',
    'sv': 'Svenska',
  };

  // Language order (same as FlutterFlow)
  static const List<String> _languageOrder = [
    'da', // Danish first (Denmark is the target market)
    'en', // English second (international)
    'de', // German
    'sv', // Swedish
    'no', // Norwegian
    'it', // Italian
    'fr', // French
  ];

  // ─────────────────────────────────────────────────────────────────────────────
  // Data Retrieval
  // ─────────────────────────────────────────────────────────────────────────────

  /// Gets the language display name
  String _getLanguageDisplayName(String languageCode) {
    return _languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Overlay Management
  // ─────────────────────────────────────────────────────────────────────────────

  /// Shows the language selection overlay
  void _showOverlay(BuildContext context) {
    if (_isOverlayVisible) return;

    final renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final buttonSize = renderBox.size;
    final buttonPosition = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _buildOverlay(
        context: context,
        buttonPosition: buttonPosition,
        buttonWidth: buttonSize.width,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOverlayVisible = true;
    });
  }

  /// Dismisses the overlay
  void _dismissOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Language Selection
  // ─────────────────────────────────────────────────────────────────────────────

  /// Handles language selection from overlay
  Future<void> _handleLanguageSelection(String newLanguageCode) async {
    // Dismiss overlay immediately for responsive feel
    _dismissOverlay();

    // Skip if selecting same language
    if (newLanguageCode == widget.currentLanguageCode) return;

    // Debounce: prevent rapid language changes that could cause race conditions
    final now = DateTime.now();
    if (_lastLanguageChangeTime != null &&
        now.difference(_lastLanguageChangeTime!) < _languageChangeCooldown) {
      debugPrint('⏱️ Language change debounced (too soon after last change)');
      return;
    }
    _lastLanguageChangeTime = now;

    try {
      // Persist language to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_language_code', newLanguageCode);
      debugPrint('✅ Language saved to preferences: $newLanguageCode');

      // Reload translations for new language
      await ref.read(translationsCacheProvider.notifier).loadTranslations(newLanguageCode);

      // Reload filters for new language
      await ref.read(filterProvider.notifier).loadFiltersForLanguage(newLanguageCode);

      // Invalidate search cache (results are language-specific)
      ref.read(searchStateProvider.notifier).invalidateCache();
      debugPrint('🌍 Language changed, search cache invalidated');

      // Auto-suggest currency for new language
      await ref.read(localizationProvider.notifier).updateCurrencyForLanguageChange(newLanguageCode);
      debugPrint('💰 Currency auto-suggestion triggered for language: $newLanguageCode');

      // Notify parent callback
      widget.onLanguageSelected(newLanguageCode);

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Language changed to ${_languageNames[newLanguageCode]}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error changing language: $e');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change language'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Main
  // ─────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final languageName = _getLanguageDisplayName(widget.currentLanguageCode);

    return GestureDetector(
      onTap: () => _showOverlay(context),
      child: Container(
        key: _buttonKey,
        width: widget.width,
        height: widget.height ?? 50.0,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                languageName,
                style: AppTypography.bodyRegular.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
              Icon(
                _isOverlayVisible
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
                size: 24.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // Build: Overlay
  // ─────────────────────────────────────────────────────────────────────────────

  /// Builds the complete overlay positioned below the button
  Widget _buildOverlay({
    required BuildContext context,
    required Offset buttonPosition,
    required double buttonWidth,
  }) {
    return Stack(
      children: [
        // Invisible barrier to detect outside taps
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismissOverlay,
            child: Container(color: Colors.transparent),
          ),
        ),
        // Language selection overlay
        Positioned(
          left: buttonPosition.dx,
          top: buttonPosition.dy + (widget.height ?? 50.0) + AppSpacing.xs,
          child: _buildOverlayContent(context, buttonWidth),
        ),
      ],
    );
  }

  /// Builds the overlay content container
  Widget _buildOverlayContent(BuildContext context, double width) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4.0,
              spreadRadius: 1.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: _buildLanguageList(context),
      ),
    );
  }

  /// Builds the list of language options
  Widget _buildLanguageList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: _languageOrder.map((languageCode) {
        return _buildLanguageItem(context, languageCode);
      }).toList(),
    );
  }

  /// Builds a single language item
  Widget _buildLanguageItem(BuildContext context, String languageCode) {
    return InkWell(
      onTap: () => _handleLanguageSelection(languageCode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          top: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        child: Text(
          _getLanguageDisplayName(languageCode),
          style: AppTypography.bodyRegular.copyWith(
            fontWeight: FontWeight.w300,
          ),
        ),
      ),
    );
  }
}
