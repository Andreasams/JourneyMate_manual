import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_providers.dart';
import '../../providers/settings_providers.dart';
import '../../services/custom_functions/business_status.dart';
import '../../services/custom_functions/distance_calculator.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../utils/search_result_helpers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Compact preview card shown when a map marker is tapped.
///
/// Floats at the bottom of the map area. Shows business thumbnail, name,
/// status, cuisine type, price range, and distance. Tapping navigates
/// to the business profile.
class MapBusinessPreviewCard extends ConsumerStatefulWidget {
  const MapBusinessPreviewCard({
    super.key,
    required this.businessData,
    required this.onTap,
  });

  /// Raw business document from search results API.
  final Map<String, dynamic> businessData;

  /// Called when the card is tapped (navigate to profile).
  final VoidCallback onTap;

  @override
  ConsumerState<MapBusinessPreviewCard> createState() =>
      _MapBusinessPreviewCardState();
}

class _MapBusinessPreviewCardState
    extends ConsumerState<MapBusinessPreviewCard>
    with SingleTickerProviderStateMixin {
  static const double _imageSize = 56.0;
  static const String _placeholderImageUrl = AppConstants.kPlaceholderImageUrl;

  String? _statusText;
  Color? _statusColor;

  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load status here (not initState) because Localizations.localeOf(context)
    // requires inherited widgets to be fully wired up.
    if (_statusText == null) {
      _loadStatus();
    }
  }

  @override
  void didUpdateWidget(MapBusinessPreviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (getBusinessId(oldWidget.businessData) !=
        getBusinessId(widget.businessData)) {
      // Clear stale status before reloading — prevents showing previous
      // business's status if new business has no opening hours.
      _statusText = null;
      _statusColor = null;
      _loadStatus();
      // Re-animate on new business
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data extraction (uses shared getField from search_result_helpers)
  // ---------------------------------------------------------------------------

  String? get _profilePicture => getField<String>(widget.businessData, 'profile_picture_url');
  String? get _businessName => getField<String>(widget.businessData, 'business_name');
  double? get _latitude => getField<double>(widget.businessData, 'latitude');
  double? get _longitude => getField<double>(widget.businessData, 'longitude');
  int? get _priceRangeMin => getField<int>(widget.businessData, 'price_range_min');
  int? get _priceRangeMax => getField<int>(widget.businessData, 'price_range_max');
  dynamic get _openingHours => getField<dynamic>(widget.businessData, 'business_hours');

  String? get _businessType {
    final languageCode = Localizations.localeOf(context).languageCode;
    return getField<String>(widget.businessData, 'business_type_$languageCode') ??
        getField<String>(widget.businessData, 'business_type');
  }

  // ---------------------------------------------------------------------------
  // Status
  // ---------------------------------------------------------------------------

  void _loadStatus() {
    if (_openingHours == null) return;

    final languageCode = Localizations.localeOf(context).languageCode;
    final translationsCache = ref.read(translationsCacheProvider);

    final result = determineStatusAndColor(
      _openingHours,
      DateTime.now(),
      languageCode,
      translationsCache,
    );

    if (mounted) {
      setState(() {
        _statusText = result['text'] as String?;
        _statusColor = result['color'] as Color?;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Distance
  // ---------------------------------------------------------------------------

  String? _getDistanceText() {
    final rawMeters = getField<int>(widget.businessData, 'distanceFromUser');

    if (rawMeters == null) return null;

    final languageCode = Localizations.localeOf(context).languageCode;
    final distanceUnit = languageCode == 'en'
        ? ref.read(localizationProvider).distanceUnit
        : 'metric';

    var distance = rawMeters / 1000.0;
    if (distanceUnit == 'imperial') {
      distance = distance * 0.621371;
    }
    distance = double.parse(distance.toStringAsFixed(1));

    return formatDistanceText(distance, distanceUnit);
  }

  // ---------------------------------------------------------------------------
  // Price
  // ---------------------------------------------------------------------------

  String? _getPriceRangeText() {
    if (_priceRangeMin == null || _priceRangeMax == null) return null;

    final localization = ref.read(localizationProvider);
    return convertAndFormatPriceRange(
      _priceRangeMin!.toDouble(),
      _priceRangeMax!.toDouble(),
      'DKK',
      localization.exchangeRate,
      localization.currencyCode,
      forceNoDecimals: true,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildThumbnail(),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _buildInfo()),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.chip),
      child: CachedNetworkImage(
        imageUrl: _profilePicture ?? _placeholderImageUrl,
        width: _imageSize,
        height: _imageSize,
        fit: BoxFit.scaleDown,
        placeholder: (context, url) => Container(
          width: _imageSize,
          height: _imageSize,
          color: AppColors.bgInput,
        ),
        errorWidget: (context, url, error) => Container(
          width: _imageSize,
          height: _imageSize,
          color: AppColors.bgInput,
          child: Icon(Icons.restaurant, color: AppColors.textTertiary, size: 24),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    final distanceText = _getDistanceText();
    final statusText = _statusText ?? '';
    final statusColor = _statusColor ?? AppColors.success;
    final priceRange = _getPriceRangeText();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Line 1: Name + distance
        Row(
          children: [
            Expanded(
              child: Text(
                _businessName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodyMedium,
              ),
            ),
            if (distanceText != null) ...[
              const SizedBox(width: 6),
              Text(distanceText, style: AppTypography.bodySmMedium),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xxs),

        // Line 2: Status · Cuisine · Price
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (statusText.isNotEmpty)
              Text(
                statusText,
                style: AppTypography.bodySm.copyWith(
                  color: statusColor,
                ),
              ),
            if (statusText.isNotEmpty && _businessType != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text('·',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: AppSpacing.xs),
            ],
            if (_businessType != null)
              Flexible(
                child: Text(
                  _businessType!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm,
                ),
              ),
            if (priceRange != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Text('·',
                  style: AppTypography.bodySm
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(width: AppSpacing.xs),
              Text(priceRange, style: AppTypography.bodySm),
            ],
          ],
        ),
      ],
    );
  }
}
