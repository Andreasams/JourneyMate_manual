import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/app_providers.dart';
import '../../providers/filter_providers.dart';
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
    debugPrint('📊 [6] SearchResultsListView.build() START');

    // Watch both searchResults AND active filters for match grouping
    final searchState = ref.watch(searchStateProvider);
    final searchResults = searchState.searchResults;
    final activeFilters = searchState.filtersUsedForSearch;

    // Show shimmer while loading
    if (searchResults == null) {
      debugPrint('📊 [6a] searchResults null → returning shimmer');
      return const RestaurantListShimmerWidget();
    }

    // Extract documents
    final documents = _extractDocuments(searchResults);

    // Empty state
    if (documents.isEmpty) {
      debugPrint('📊 [6b] documents empty → returning empty state');
      return _buildEmptyState();
    }

    debugPrint('📊 [6c] documents.length=${documents.length}, activeFilters=${activeFilters.length}');

    // Check if we should show match sections
    final showMatchSections = activeFilters.isNotEmpty;

    // List of businesses
    // LayoutBuilder kept for debug constraint logging.
    // Parent Stack uses StackFit.expand to provide tight height constraints.
    return LayoutBuilder(
      builder: (context, constraints) {
        debugPrint('📐 [7] LISTVIEW LayoutBuilder: ${constraints.maxHeight}h × ${constraints.maxWidth}w');

        if (constraints.maxHeight == 0) {
          debugPrint('⚠️  [7] WARNING: maxHeight is ZERO - ListView will not render!');
        }

        if (showMatchSections) {
          return _buildMatchSections(documents, activeFilters.length, constraints);
        } else {
          return _buildFlatList(documents, constraints);
        }
      },
    );
  }

  /// Builds a flat list when no filters are active
  Widget _buildFlatList(List<dynamic> documents, BoxConstraints constraints) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 32.0),
      itemCount: documents.length,
      separatorBuilder: (_, _) => SizedBox(height: _itemSeparatorHeight),
      itemBuilder: (context, index) {
        debugPrint('📋 [8] ListView itemBuilder called for index=$index');
        final businessData = documents[index];
        final businessId = _getBusinessId(businessData);

        return _BusinessListItem(
          key: ValueKey('business_$businessId'),
          businessData: businessData,
          userLocation: widget.userLocation,
          matchVariant: 'none', // No match categorization
          activeFilterCount: 0,
          itemIndex: index,
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
          onBusinessTap: (id) {
            _trackBusinessClick(id, index);
            widget.onBusinessTap?.call(id);
          },
        );
      },
    );
  }

  /// Builds match sections (Full Match, Partial Match, No Match) when filters are active
  Widget _buildMatchSections(
    List<dynamic> documents,
    int totalActiveFilters,
    BoxConstraints constraints,
  ) {
    // Group documents by match quality
    final fullMatch = <dynamic>[];
    final partialMatch = <dynamic>[];
    final noMatch = <dynamic>[];

    for (final doc in documents) {
      final matchCount = _getMatchCount(doc);
      if (matchCount == totalActiveFilters) {
        fullMatch.add(doc);
      } else if (matchCount > 0) {
        partialMatch.add(doc);
      } else {
        noMatch.add(doc);
      }
    }

    debugPrint('🎯 Match sections: full=${fullMatch.length}, partial=${partialMatch.length}, none=${noMatch.length}');

    // Build sections list
    final sections = <Widget>[];
    int itemIndex = 0;

    // Full match section
    if (fullMatch.isNotEmpty) {
      sections.add(_buildSectionHeader('full'));
      for (final doc in fullMatch) {
        sections.add(_buildBusinessCard(doc, 'full', totalActiveFilters, itemIndex++));
        sections.add(SizedBox(height: _itemSeparatorHeight));
      }
    }

    // Partial match section
    if (partialMatch.isNotEmpty) {
      sections.add(_buildSectionHeader('partial'));
      for (final doc in partialMatch) {
        sections.add(_buildBusinessCard(doc, 'partial', totalActiveFilters, itemIndex++));
        sections.add(SizedBox(height: _itemSeparatorHeight));
      }
    }

    // No match section
    if (noMatch.isNotEmpty) {
      sections.add(_buildSectionHeader('none'));
      for (final doc in noMatch) {
        sections.add(_buildBusinessCard(doc, 'none', totalActiveFilters, itemIndex++));
        sections.add(SizedBox(height: _itemSeparatorHeight));
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32.0),
      children: sections,
    );
  }

  Widget _buildBusinessCard(
    dynamic businessData,
    String matchVariant,
    int totalActiveFilters,
    int itemIndex,
  ) {
    final businessId = _getBusinessId(businessData);
    return _BusinessListItem(
      key: ValueKey('business_$businessId'),
      businessData: businessData,
      userLocation: widget.userLocation,
      matchVariant: matchVariant,
      activeFilterCount: totalActiveFilters,
      itemIndex: itemIndex,
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
      onBusinessTap: (id) {
        _trackBusinessClick(id, itemIndex);
        widget.onBusinessTap?.call(id);
      },
    );
  }

  Widget _buildSectionHeader(String section) {
    final String labelKey;
    final Color color;
    final IconData? icon;

    switch (section) {
      case 'full':
        labelKey = 'match_full_header'; // "MATCHES ALL NEEDS"
        color = AppColors.green;
        icon = Icons.check;
        break;
      case 'partial':
        labelKey = 'match_partial_header'; // "PARTIAL MATCH"
        color = AppColors.accent;
        icon = null;
        break;
      case 'none':
        labelKey = 'match_other_header'; // "OTHER PLACES"
        color = AppColors.textTertiary;
        icon = null;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            td(ref, labelKey),
            style: AppTypography.bodyRegular.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  int _getMatchCount(dynamic businessData) {
    if (businessData is Map) {
      final value = businessData['matchCount'];
      if (value is int) return value;
      if (value is num) return value.toInt();
    }
    return 0;
  }

  List<dynamic> _extractDocuments(dynamic searchResults) {
    // After updateSearchResults() normalization, searchResults is already a List
    if (searchResults is List) {
      return searchResults;
    }

    // Fallback: handle Map format (for backwards compatibility)
    if (searchResults is Map && searchResults.containsKey('documents')) {
      final docs = searchResults['documents'];
      if (docs is List) {
        return docs;
      }
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
    required this.matchVariant,
    required this.activeFilterCount,
    required this.itemIndex,
    this.statusText,
    this.statusColor,
    this.onStatusLoaded,
    this.onBusinessTap,
  });

  final dynamic businessData;
  final Position? userLocation;
  final String matchVariant; // 'full', 'partial', 'none'
  final int activeFilterCount; // Total number of active filters
  final int itemIndex; // Position in list for analytics
  final String? statusText;
  final Color? statusColor;
  final void Function(String? text, Color? color)? onStatusLoaded;
  final void Function(int businessId)? onBusinessTap;

  @override
  ConsumerState<_BusinessListItem> createState() => _BusinessListItemState();
}

class _BusinessListItemState extends ConsumerState<_BusinessListItem> {
  String? _statusText;
  Color? _statusColor;
  bool _isExpanded = false;

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
  String? get _postalCode => _getField<String>('postal_code');
  String? get _city => _getField<String>('city');
  int? get _priceRangeMin => _getField<int>('price_range_min');
  int? get _priceRangeMax => _getField<int>('price_range_max');
  dynamic get _openingHours => _getField<dynamic>('business_hours');
  int? get _matchCount => _getField<int>('matchCount');
  List<dynamic>? get _missedFilters => _getField<List<dynamic>>('missedFilters');
  List<dynamic>? get _photos => _getField<List<dynamic>>('photos');

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

  /// Returns border color based on match variant
  Color get _borderColor {
    switch (widget.matchVariant) {
      case 'full':
        return const Color(0xFFb8d4c0); // Green border for full match
      case 'partial':
        return const Color(0xFFf0dcc8); // Light orange for partial match
      case 'none':
      default:
        return const Color(0xFFe8e8e8); // Gray for no match
    }
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
    if (!mounted || _openingHours == null) {
      return;
    }

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
    debugPrint('🏪 [9] _BusinessListItem.build() for: $_businessName');

    return LayoutBuilder(
      builder: (context, itemConstraints) {
        debugPrint('📐 [10] ITEM LayoutBuilder: ${itemConstraints.maxHeight}h × ${itemConstraints.maxWidth}w');

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: _imageSize),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  border: Border.all(color: _borderColor, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Base card content
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImage(),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoColumn()),
                      ],
                    ),
                    // Expanded preview section
                    if (_isExpanded) _buildExpandedPreview(),
                    // Collapse chevron (shown when NOT expanded)
                    if (!_isExpanded) _buildCollapseChevron(),
                  ],
                ),
              ),
            ),
            // Partial match info box
            if (widget.matchVariant == 'partial' && widget.activeFilterCount > 0)
              _buildPartialMatchInfoBox(),
          ],
        );
      },
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
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            _placeholderImageUrl,
            width: _imageSize,
            height: _imageSize,
            fit: BoxFit.scaleDown,
          );
        },
      ),
    );
  }

  Widget _buildInfoColumn() {
    debugPrint('🔍   _buildInfoColumn()');
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
    debugPrint('🔍   _buildNameRow(): ${_businessName ?? "Business"}');
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
    debugPrint('🔍   _buildStatusRow(): status=$statusText, timing=$timingText');

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
    if (_openingHours == null) {
      debugPrint('🔍   _getTimingText(): no opening hours');
      return null;
    }

    final languageCode = Localizations.localeOf(context).languageCode;
    final translationsCache = ref.read(translationsCacheProvider);

    final result = openClosesAt(
      _openingHours,
      DateTime.now(),
      languageCode,
      translationsCache,
    );
    debugPrint('🔍   _getTimingText(): $result');
    return result;
  }

  Widget _buildDetailsRow() {
    debugPrint('🔍   _buildDetailsRow()');
    final items = <Widget>[];

    // Business type
    if (_businessType != null && _businessType!.isNotEmpty) {
      debugPrint('🔍     Business type: $_businessType');
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
    if (_priceRangeMin == null || _priceRangeMax == null) {
      debugPrint('🔍     _getPriceRangeText(): no price data');
      return null;
    }

    // Use existing price_formatter from Session #5
    final result = convertAndFormatPriceRange(
      _priceRangeMin!.toDouble(),
      _priceRangeMax!.toDouble(),
      'DKK',
      _exchangeRate,
      _userCurrencyCode,
    );
    debugPrint('🔍     Price range: $result');
    return result;
  }

  String? _getDistanceText() {
    if (!_locationEnabled ||
        widget.userLocation == null ||
        _latitude == null ||
        _longitude == null) {
      debugPrint('🔍     _getDistanceText(): skipped (location_enabled=$_locationEnabled, has_user_location=${widget.userLocation != null}, has_coords=${_latitude != null && _longitude != null})');
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
    final result = '$distance$unit';
    debugPrint('🔍     Distance: $result');
    return result;
  }

  Widget _buildAddressRow() {
    final address = _formatAddress();
    debugPrint('🔍   _buildAddressRow(): $address');
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
  // Expandable Card Preview
  // ---------------------------------------------------------------------------

  Widget _buildCollapseChevron() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Icon(
          Icons.keyboard_arrow_down,
          size: 20,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildExpandedPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          height: 1,
          color: const Color(0xFFf2f2f2),
        ),
        const SizedBox(height: 12),
        // Full address
        _buildFullAddress(),
        const SizedBox(height: 6),
        // Today's hours
        _buildTodayHours(),
        const SizedBox(height: 12),
        // Photo grid
        if (_photos != null && _photos!.isNotEmpty) _buildPhotoGrid(),
        if (_photos != null && _photos!.isNotEmpty) const SizedBox(height: 12),
        // "See more" button
        _buildSeeMoreButton(),
      ],
    );
  }

  Widget _buildFullAddress() {
    final street = _street ?? '';
    final postalCode = _postalCode ?? '';
    final city = _city ?? '';

    String fullAddress = '';
    if (street.isNotEmpty) {
      fullAddress = street;
      if (postalCode.isNotEmpty || city.isNotEmpty) {
        fullAddress += ', ';
        if (postalCode.isNotEmpty) fullAddress += '$postalCode ';
        if (city.isNotEmpty) fullAddress += city;
      }
    } else if (_neighbourhoodName?.isNotEmpty ?? false) {
      fullAddress = _neighbourhoodName!;
    } else {
      fullAddress = td(ref, 'addressunavail');
    }

    return Text(
      fullAddress,
      style: AppTypography.bodyRegular.copyWith(
        fontSize: 12.5,
        color: const Color(0xFF888888),
      ),
    );
  }

  Widget _buildTodayHours() {
    if (_openingHours == null) {
      return Text(
        td(ref, 'hours_no_data'),
        style: AppTypography.bodyRegular.copyWith(
          fontSize: 12.5,
          color: AppColors.textSecondary,
        ),
      );
    }

    // Get today's hours string
    final todayStr = _getTodayHoursRange();

    return Text(
      '${td(ref, 'expandable_today_label')} $todayStr', // Space between label and time
      style: AppTypography.bodyRegular.copyWith(
        fontSize: 12.5,
        color: AppColors.textSecondary,
      ),
    );
  }

  /// Returns today's hours in format "HH:MM-HH:MM" or "Closed"
  String _getTodayHoursRange() {
    if (_openingHours == null || _openingHours is! Map) {
      return td(ref, 'hours_no_data');
    }

    final businessHoursMap = Map<String, dynamic>.from(_openingHours);
    final currentDay = (DateTime.now().weekday - 1) % 7; // Monday = 0
    final dayKey = currentDay.toString();
    final dayHours = businessHoursMap[dayKey];

    if (dayHours == null || dayHours is! Map) {
      return td(ref, 'hours_closed');
    }

    final dayHoursMap = Map<String, dynamic>.from(dayHours);

    // Check if closed
    final closed = dayHoursMap['closed'] == true ||
        dayHoursMap['closed'] == 'true' ||
        dayHoursMap['by_appointment_only'] == true ||
        dayHoursMap['by_appointment_only'] == 'true';

    if (closed) {
      return td(ref, 'hours_closed');
    }

    // Get first time slot (most common case)
    final openTime = dayHoursMap['opening_time_1']?.toString();
    final closeTime = dayHoursMap['closing_time_1']?.toString();

    if (openTime != null && closeTime != null) {
      // Check if there are multiple slots
      final slot2Open = dayHoursMap['opening_time_2']?.toString();
      if (slot2Open != null) {
        // Multiple slots - show first slot with indicator
        return '$openTime-$closeTime +';
      }
      return '$openTime-$closeTime';
    }

    return td(ref, 'hours_no_data');
  }

  Widget _buildPhotoGrid() {
    final photos = _photos!;
    final displayPhotos = photos.take(8).toList(); // Max 8 photos per JSX

    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: displayPhotos.length,
        separatorBuilder: (context, index) => const SizedBox(width: 4),
        itemBuilder: (context, index) {
          final photoUrl = displayPhotos[index] is String
              ? displayPhotos[index] as String
              : displayPhotos[index]['url'] as String?;

          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              photoUrl ?? _placeholderImageUrl,
              width: 80,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 60,
                  color: AppColors.border,
                  child: Icon(
                    Icons.image_not_supported,
                    color: AppColors.textTertiary,
                    size: 24,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeeMoreButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          final businessId = _getField<int>('business_id') ?? 0;
          widget.onBusinessTap?.call(businessId);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              td(ref, 'expandable_show_more'),
              style: AppTypography.bodyRegular.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Partial Match Info Box
  // ---------------------------------------------------------------------------

  Widget _buildPartialMatchInfoBox() {
    final matchCount = _matchCount ?? 0;
    final missedFilters = _missedFilters ?? [];

    if (matchCount == 0 || missedFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get missed filter names
    final filterState = ref.watch(filterProvider);
    final missedNames = <String>[];

    filterState.when(
      data: (state) {
        for (final filterId in missedFilters) {
          if (filterId is int) {
            final filter = state.filterLookupMap[filterId];
            if (filter != null && filter['filter_name'] != null) {
              missedNames.add(filter['filter_name'] as String);
            }
          }
        }
      },
      loading: () {},
      error: (e, stack) {},
    );

    final totalFilters = matchCount + missedFilters.length;
    final missedText = missedNames.join(', ');

    // Get translated strings with placeholder replacement
    final matchesText = td(ref, 'match_info_matches')
        .replaceAll('{count}', matchCount.toString())
        .replaceAll('{total}', totalFilters.toString());

    final missingText = missedNames.isNotEmpty
        ? td(ref, 'match_info_missing').replaceAll('{filters}', missedText)
        : '';

    return Container(
      margin: const EdgeInsets.only(top: 10, left: 12, right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFfef8f2), // Light orange background
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              missedNames.isNotEmpty ? '$matchesText · $missingText' : matchesText,
              style: AppTypography.bodyRegular.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatAddress() {
    final street = _street ?? '';
    final neighbourhood = _neighbourhoodName ?? '';

    debugPrint('🔍     _formatAddress(): street=$street, neighbourhood=$neighbourhood');

    if (street.isEmpty && neighbourhood.isEmpty) {
      return td(ref, 'addressunavail');
    }
    if (street.isEmpty) return neighbourhood;
    if (neighbourhood.isEmpty) return street;

    // Use streetAndNeighbourhoodLength function from address_formatter.dart
    return streetAndNeighbourhoodLength(neighbourhood, street);
  }
}
