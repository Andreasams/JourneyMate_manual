import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/translation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Shared search bar widget used across the app.
///
/// Manages its own [FocusNode] (drives the focus border) and optionally its
/// own [TextEditingController]. Pass an external [controller] when the parent
/// page needs to read or reset the field value (e.g. search_page).
///
/// Usage:
/// ```dart
/// SearchBarWidget(
///   hintTextKey: 'search_placeholder',
///   controller: _searchController,   // optional
///   onChanged: _onSearchTextChanged,
///   onSubmitted: _executeSearch,     // optional
/// )
/// ```
class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.hintTextKey,
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autofocus = false,
    this.backgroundColor,
    this.borderColor,
  });

  /// Translation key used for the placeholder text.
  final String hintTextKey;

  /// Called on every keystroke and when the clear button is tapped (with '').
  final ValueChanged<String>? onChanged;

  /// Called when the user submits via the keyboard action button.
  final ValueChanged<String>? onSubmitted;

  /// Optional external controller. If null the widget creates its own.
  final TextEditingController? controller;

  final bool autofocus;

  /// Optional background color override. Defaults to [AppColors.bgCard].
  final Color? backgroundColor;

  /// Optional unfocused border color. Defaults to [Colors.transparent].
  final Color? borderColor;

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  late TextEditingController _effectiveController;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _focusNode = FocusNode();
    _hasText = _effectiveController.text.isNotEmpty;

    _focusNode.addListener(() {
      if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
    });
    _effectiveController.addListener(() {
      if (mounted) setState(() => _hasText = _effectiveController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (widget.controller == null) _effectiveController.dispose();
    super.dispose();
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppConstants.searchBarHeight,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(
          color: _hasFocus
              ? AppColors.accent
              : (widget.borderColor ?? Colors.transparent),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: _effectiveController,
        focusNode: _focusNode,
        textAlignVertical: TextAlignVertical.center,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofocus: widget.autofocus,
        style: AppTypography.bodyLg.copyWith(
          color: AppColors.textSecondary,
        ),
        decoration: InputDecoration(
          hintText: td(ref, widget.hintTextKey),
          hintStyle: AppTypography.bodyLg.copyWith(
            color: AppColors.textSecondary,
          ),
          filled: false,
          isDense: true,
          prefixIcon: Icon(
            Icons.search,
            size: 21,
            color: AppColors.textMuted,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: AppConstants.searchBarHeight,
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 44,
            minHeight: AppConstants.searchBarHeight,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 0,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  color: AppColors.textMuted,
                  onPressed: _handleClear,
                )
              : null,
        ),
      ),
    );
  }
}
