import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../models/lat_lng.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../services/custom_functions/business_status.dart';
import '../../services/custom_functions/hours_formatter.dart';
import '../../services/custom_functions/distance_calculator.dart';
import '../../services/custom_functions/address_formatter.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import 'restaurant_list_shimmer_widget.dart';

/// A performant ListView displaying search results for businesses.
///
/// Encapsulates all list rendering, item display, tap handling, analytics,
/// and navigation logic. Shows shimmer loading state when data is unavailable.
///
/// This widget uses Riverpod's selective rebuild pattern to only update
/// when searchResults changes, ensuring optimal performance.
class SearchResultsListView extends ConsumerStatefulWidget {
  const SearchResultsListView({
    super.key,
    this.width,
    this.height,
    required this.userLocation,
    this.onBusinessTap,
  });

  final double? width;
  final double? height;
  final Position? userLocation;
  final void Function(int businessId)? onBusinessTap;

  @override
  ConsumerState<SearchResultsListView> createState() =>
      _SearchResultsListViewState();
}

class _SearchResultsListViewState
    extends ConsumerState<SearchResultsListView> {
  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// Cache for status text per business (keyed by business_id)
  final Map<int, String?> _statusTextCache = {};

  /// Cache for status colors per business (keyed by business_id)
  final Map<int, Color?> _statusColorCache = {};

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------

  /// Fires a fire-and-forget `business_clicked` analytics event.
  void _trackBusinessClick(int businessId, int clickPosition) {
    final searchState = ref.read(searchStateProvider);
    unawaited(ApiService.instance.postAnalytics(
      eventType: 'business_clicked',
      deviceId: AnalyticsService.instance.deviceId ?? 'unknown',
      sessionId: AnalyticsService.instance.currentSessionId ?? 'unknown',
      userId: AnalyticsService.instance.userId ?? 'unknown',
      eventData: {
        'businessId': businessId,
        'clickPosition': clickPosition,
        'filterSessionId': searchState.currentFilterSessionId,
        'timeOnListSeconds':
            AnalyticsService.instance.getSessionDurationSeconds(),
        'totalResults': searchState.searchResultsCount,
      },
      timestamp: DateTime.now().toIso8601String(),
    ));
  }

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Item separator height based on font scale
  double get _itemSeparatorHeight {
    final fontScale = ref.watch(accessibilityProvider).isBoldTextEnabled;
    return fontScale ? 4.0 : 2.0;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Selective rebuild: ONLY when searchResults changes
    final searchResults = ref.watch(
      searchStateProvider.select((state) => state.searchResults),
    );

    // Show shimmer while loading
    if (searchResults == null) {
      return const RestaurantListShimmerWidget();
    }

    // Extract documents
    final documents = _extractDocuments(searchResults);

    // Empty state
    if (documents.isEmpty) {
      return _buildEmptyState();
    }

    // List of businesses
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 32.0),
      itemCount: documents.length,
      separatorBuilder: (_, _) => SizedBox(height: _itemSeparatorHeight),
      itemBuilder: (context, index) {
        final businessData = documents[index];
        final businessId = _getBusinessId(businessData);

        return GestureDetector(
          onTap: () {
            _trackBusinessClick(businessId, index);
            widget.onBusinessTap?.call(businessId);
          },
          child: _BusinessListItem(
            key: ValueKey('business_$businessId'),
            businessData: businessData,
            userLocation: widget.userLocation,
            statusText: _statusTextCache[businessId],
            statusColor: _statusColorCache[businessId],
            onStatusLoaded: (text, color) {
              if (mounted) {
                setState(() {
                  _statusTextCache[businessId] = text;
                  _statusColorCache[businessId] = color;
                });
              }
            },
          ),
        );
      },
    );
  }

  List<dynamic> _extractDocuments(dynamic searchResults) {
    if (searchResults is Map && searchResults.containsKey('documents')) {
      final docs = searchResults['documents'];
      if (docs is List) return docs;
    }
    return [];
  }

  int _getBusinessId(dynamic businessData) {
    if (businessData is Map) {
      // API returns 'business_id' (not 'id')
      final value = businessData['business_id'];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            td(ref, 'noresultsfound'),
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Business List Item Widget
// =============================================================================

class _BusinessListItem extends ConsumerStatefulWidget {
  const _BusinessListItem({
    super.key,
    required this.businessData,
    required this.userLocation,
    this.statusText,
    this.statusColor,
    this.onStatusLoaded,
  });

  final dynamic businessData;
  final Position? userLocation;
  final String? statusText;
  final Color? statusColor;
  final void Function(String? text, Color? color)? onStatusLoaded;

  @override
  ConsumerState<_BusinessListItem> createState() => _BusinessListItemState();
}

class _BusinessListItemState extends ConsumerState<_BusinessListItem> {
  String? _statusText;
  Color? _statusColor;

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const double _imageSize = 84.0;
  static const String _placeholderImageUrl =
      'https://tlqfuazpshfaozdvmcbh.supabase.co/storage/v1/object/public/profilepic_restaurants/placeholder.webp';

  // ---------------------------------------------------------------------------
  // JSON Field Extraction
  // ---------------------------------------------------------------------------

  T? _getField<T>(String fieldName) {
    try {
      if (widget.businessData is Map) {
        final value = widget.businessData[fieldName];
        if (value is T) return value;
        // Type coercion for numbers
        if (T == int && value is num) return value.toInt() as T;
        if (T == double && value is num) return value.toDouble() as T;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? get _profilePicture => _getField<String>('profile_picture_url');
  String? get _businessName => _getField<String>('business_name');
  double? get _latitude => _getField<double>('latitude');
  double? get _longitude => _getField<double>('longitude');
  String? get _street => _getField<String>('street');
  String? get _neighbourhoodName => _getField<String>('neighbourhood_name');
  int? get _priceRangeMin => _getField<int>('price_range_min');
  int? get _priceRangeMax => _getField<int>('price_range_max');
  dynamic get _openingHours => _getField<dynamic>('business_hours');

  String? get _businessType {
    final languageCode = Localizations.localeOf(context).languageCode;
    final localizedType = _getField<String>('business_type_$languageCode');
    return localizedType ?? _getField<String>('business_type');
  }

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  double get _rowSpacing {
    final fontScale = ref.watch(accessibilityProvider).isBoldTextEnabled;
    return fontScale ? 4.0 : 2.0;
  }

  double get _exchangeRate => ref.watch(localizationProvider).exchangeRate;
  String get _userCurrencyCode => ref.watch(localizationProvider).currencyCode;
  bool get _locationEnabled {
    return ref.watch(
      localizationProvider.select((state) => state.currencyCode != 'DKK'),
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    if (widget.statusText != null) {
      _statusText = widget.statusText;
      _statusColor = widget.statusColor;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadStatus());
    }
  }

  Future<void> _loadStatus() async {
    if (!mounted || _openingHours == null) return;

    // Get language code and translations cache
    final languageCode = Localizations.localeOf(context).languageCode;
    final translationsCache = ref.read(translationsCacheProvider);

    // Use determineStatusAndColor function from business_status.dart
    final statusResult = determineStatusAndColor(
      _openingHours,
      DateTime.now(),
      languageCode,
      translationsCache,
    );

    if (mounted) {
      setState(() {
        _statusText = statusResult['text'] as String?;
        _statusColor = statusResult['color'] as Color?;
      });
      widget.onStatusLoaded?.call(_statusText, _statusColor);
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: _imageSize),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImage(),
          const SizedBox(width: 8),
          Expanded(child: _buildInfoColumn()),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.network(
        _profilePicture ?? _placeholderImageUrl,
        width: _imageSize,
        height: _imageSize,
        fit: BoxFit.scaleDown,
        errorBuilder: (context, error, stackTrace) => Image.network(
          _placeholderImageUrl,
          width: _imageSize,
          height: _imageSize,
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }

  Widget _buildInfoColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNameRow(),
        SizedBox(height: _rowSpacing),
        _buildStatusRow(),
        SizedBox(height: _rowSpacing),
        _buildDetailsRow(),
        SizedBox(height: _rowSpacing),
        _buildAddressRow(),
      ],
    );
  }

  Widget _buildNameRow() {
    return Text(
      _businessName ?? 'Business',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.cardRestaurantName,
    );
  }

  Widget _buildStatusRow() {
    final statusText = _statusText ?? 'Open';
    final statusColor = _statusColor ?? AppColors.success;
    final timingText = _getTimingText();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          statusText,
          style: AppTypography.bodyRegular.copyWith(
            color: statusColor,
            fontWeight: statusText.toLowerCase() == 'closed'
                ? FontWeight.w600
                : FontWeight.normal,
          ),
        ),
        if (timingText != null && timingText.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            '•',
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              timingText,
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  /// Returns timing text like "til 22:00" or "opens at 10:00"
  String? _getTimingText() {
    if (_openingHours == null) return null;

    final languageCode = Localizations.localeOf(context).languageCode;
    final translationsCache = ref.read(translationsCacheProvider);

    return openClosesAt(
      _openingHours,
      DateTime.now(),
      languageCode,
      translationsCache,
    );
  }

  Widget _buildDetailsRow() {
    final items = <Widget>[];

    // Business type
    if (_businessType != null && _businessType!.isNotEmpty) {
      items.add(Flexible(
        child: Text(
          _businessType!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.bodyRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ));
    }

    // Price range
    final priceRange = _getPriceRangeText();
    if (priceRange != null && priceRange.isNotEmpty) {
      if (items.isNotEmpty) {
        items.addAll([
          const SizedBox(width: 4),
          Text('•',
              style: AppTypography.bodyRegular
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 4),
        ]);
      }
      items.add(Text(
        priceRange,
        style: AppTypography.bodyRegular.copyWith(
          color: AppColors.textSecondary,
        ),
      ));
    }

    // Distance
    final distanceText = _getDistanceText();
    if (distanceText != null) {
      if (items.isNotEmpty) {
        items.addAll([
          const SizedBox(width: 4),
          Text('•',
              style: AppTypography.bodyRegular
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 4),
        ]);
      }
      items.add(Text(
        distanceText,
        style: AppTypography.bodyRegular.copyWith(
          color: AppColors.textSecondary,
        ),
      ));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: items);
  }

  String? _getPriceRangeText() {
    if (_priceRangeMin == null || _priceRangeMax == null) return null;

    // Use existing price_formatter from Session #5
    return convertAndFormatPriceRange(
      _priceRangeMin!.toDouble(),
      _priceRangeMax!.toDouble(),
      'DKK',
      _exchangeRate,
      _userCurrencyCode,
    );
  }

  String? _getDistanceText() {
    if (!_locationEnabled ||
        widget.userLocation == null ||
        _latitude == null ||
        _longitude == null) {
      return null;
    }

    final languageCode = Localizations.localeOf(context).languageCode;

    // Create LatLng from user position
    final userLatLng = LatLng(
      widget.userLocation!.latitude,
      widget.userLocation!.longitude,
    );

    // Use returnDistance function from distance_calculator.dart
    final distance = returnDistance(
      userLatLng,
      _latitude!,
      _longitude!,
      languageCode,
    );

    final unit = languageCode == 'en' ? ' mi.' : ' km.';
    return '$distance$unit';
  }

  Widget _buildAddressRow() {
    final address = _formatAddress();
    return Text(
      address,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: AppTypography.bodyRegular.copyWith(
        color: AppColors.textSecondary,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatAddress() {
    final street = _street ?? '';
    final neighbourhood = _neighbourhoodName ?? '';

    if (street.isEmpty && neighbourhood.isEmpty) {
      return td(ref, 'addressunavail');
    }
    if (street.isEmpty) return neighbourhood;
    if (neighbourhood.isEmpty) return street;

    // Use streetAndNeighbourhoodLength function from address_formatter.dart
    return streetAndNeighbourhoodLength(neighbourhood, street);
  }
}
