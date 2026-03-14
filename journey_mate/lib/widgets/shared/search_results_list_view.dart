import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../providers/search_providers.dart';
import '../../providers/settings_providers.dart';
import '../../providers/app_providers.dart';
import '../../providers/filter_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_constants.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_radius.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../services/custom_functions/business_status.dart';
import '../../services/custom_functions/hours_formatter.dart';
import '../../services/custom_functions/distance_calculator.dart';
import '../../services/translation_service.dart';
import '../../services/analytics_service.dart';
import '../../services/api_service.dart';
import '../../services/business_cache.dart';
import '../../utils/search_result_helpers.dart';
import 'restaurant_list_shimmer_widget.dart';
import 'image_gallery_widget.dart';

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
    this.onBusinessTap,
  });

  final double? width;
  final double? height;
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

  // Pre-loading state
  Timer? _scrollStopTimer;
  final Set<int> _visibleBusinessIds = {};
  final Set<int> _preloadedBusinessIds = {}; // For gallery images
  final Set<int> _preloadedProfileIds = {}; // For API profile data
  dynamic _lastPreloadedResults;
  final ScrollController _listScrollController = ScrollController();

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
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void didUpdateWidget(SearchResultsListView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final searchState = ref.read(searchStateProvider);
    if (searchState.searchResults != _lastPreloadedResults) {
      _visibleBusinessIds.clear();
      _preloadedBusinessIds.clear();
      _preloadedProfileIds.clear();
      _lastPreloadedResults = searchState.searchResults;

      // Clear API cache on new search
      ApiService.instance.clearCache();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _preloadTop5Restaurants();
          _preloadTop5Profiles();
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollStopTimer?.cancel();
    _listScrollController.dispose();
    _preloadedProfileIds.clear();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Pre-loading Methods
  // ---------------------------------------------------------------------------

  void _preloadTop5Restaurants() {
    final documents = extractDocuments(ref.read(searchStateProvider).searchResults);
    for (int i = 0; i < documents.length && i < 5; i++) {
      final businessData = documents[i];
      final businessId = getBusinessId(businessData);
      _preloadBusinessImages(businessId, businessData);
    }
  }

  void _preloadBusinessImages(int businessId, dynamic businessData) {
    if (_preloadedBusinessIds.contains(businessId)) return;

    final galleryImages = businessData['gallery_images'] as List<dynamic>?;
    if (galleryImages == null || galleryImages.isEmpty) return;

    _preloadedBusinessIds.add(businessId);

    // Pre-load all 12 images (no throttling per requirements)
    for (final img in galleryImages.take(12)) {
      final imageUrl = img is String ? img : (img['url'] as String?);
      if (imageUrl != null && mounted) {
        precacheImage(CachedNetworkImageProvider(imageUrl), context);
      }
    }
  }

  void _preloadTop5Profiles() {
    final documents = extractDocuments(ref.read(searchStateProvider).searchResults);
    final languageCode = Localizations.localeOf(context).languageCode;

    for (int i = 0; i < documents.length && i < 5; i++) {
      final businessData = documents[i];
      final businessId = getBusinessId(businessData);
      _preloadBusinessProfile(businessId, languageCode);
    }
  }

  void _preloadBusinessProfile(int businessId, String languageCode) {
    if (businessId <= 0 || _preloadedProfileIds.contains(businessId)) return;

    _preloadedProfileIds.add(businessId);

    // Fire-and-forget API call - caches in ApiService
    unawaited(
      ApiService.instance.getBusinessProfile(
        businessId: businessId,
        languageCode: languageCode,
      ).catchError((error) {
        _preloadedProfileIds.remove(businessId); // Allow retry
        return ApiCallResponse.failure(error.toString());
      }),
    );
  }

  void _onScroll(ScrollNotification notification) {
    _scrollStopTimer?.cancel();
    _scrollStopTimer = Timer(const Duration(milliseconds: 300), () {
      _preloadVisibleCards();
    });
  }

  void _preloadVisibleCards() {
    final documents = extractDocuments(ref.read(searchStateProvider).searchResults);
    final languageCode = Localizations.localeOf(context).languageCode;

    // Get list of all business IDs in order for adjacency calculation
    final businessIds = documents.map((doc) => getBusinessId(doc)).toList();

    // Build set of IDs to pre-load: visible + 1 above + 1 below each visible card
    final idsToPreload = <int>{};
    for (final visibleId in _visibleBusinessIds) {
      idsToPreload.add(visibleId); // The visible card itself

      final index = businessIds.indexOf(visibleId);
      if (index != -1) {
        if (index > 0) {
          idsToPreload.add(businessIds[index - 1]); // 1 above
        }
        if (index < businessIds.length - 1) {
          idsToPreload.add(businessIds[index + 1]); // 1 below
        }
      }
    }

    // Pre-load images and profiles for all target IDs
    for (final businessId in idsToPreload) {
      // Pre-load images (existing logic)
      if (!_preloadedBusinessIds.contains(businessId)) {
        final businessData = documents.firstWhere(
          (doc) => getBusinessId(doc) == businessId,
          orElse: () => null,
        );
        if (businessData != null) {
          _preloadBusinessImages(businessId, businessData);
        }
      }

      // Pre-load profile API data (NEW)
      if (!_preloadedProfileIds.contains(businessId)) {
        _preloadBusinessProfile(businessId, languageCode);
      }
    }
  }

  void _markCardAsVisible(int businessId) {
    _visibleBusinessIds.add(businessId);
  }

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Item separator height based on font scale
  double get _itemSeparatorHeight {
    return AppSpacing.sm; // Static 8px per JSX
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Watch both searchResults AND scoring filters for match grouping
    final searchState = ref.watch(searchStateProvider);
    final searchResults = searchState.searchResults;
    final scoringFilterIds = searchState.scoringFilterIds;

    // Show shimmer while loading
    if (searchResults == null) {
      return const RestaurantListShimmerWidget();
    }

    // Extract documents
    final documents = extractDocuments(searchResults);

    // Empty state
    if (documents.isEmpty) {
      return _buildEmptyState();
    }

    // Show match sections only when scoring filters are active
    // The node computes matchCount against scoringFilterIds
    final showMatchSections = scoringFilterIds.isNotEmpty;

    if (showMatchSections) {
      return _buildSectionedList(documents, scoringFilterIds.length);
    } else {
      return _buildFlatList(documents);
    }
  }

  /// Builds a flat list when no filters are active
  Widget _buildFlatList(List<dynamic> documents) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll(notification);
        return false;
      },
      child: ListView.separated(
        controller: _listScrollController,
        primary: false,
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxxl), // 16px top per JSX
        itemCount: documents.length,
        separatorBuilder: (_, _) => SizedBox(height: _itemSeparatorHeight),
        itemBuilder: (context, index) {
          final businessData = documents[index];
          final businessId = getBusinessId(businessData);

          return VisibilityDetector(
            key: Key('business_${businessId}_visibility'),
            onVisibilityChanged: (info) {
              if (info.visibleFraction > 0.8) {
                _markCardAsVisible(businessId);
              }
            },
            child: _BusinessListItem(
              key: ValueKey('business_$businessId'),
              businessData: businessData,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildBusinessCard(
    dynamic businessData,
    String matchVariant,
    int totalActiveFilters,
    int itemIndex,
  ) {
    final businessId = getBusinessId(businessData);
    return VisibilityDetector(
      key: Key('business_${businessId}_visibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.8) {
          _markCardAsVisible(businessId);
        }
      },
      child: _BusinessListItem(
        key: ValueKey('business_$businessId'),
        businessData: businessData,
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
      ),
    );
  }

  Widget _buildSectionHeader(String section, {bool isFirst = false}) {
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
      padding: EdgeInsets.only(
        left: 0,  // JSX relies on content padding, not explicit
        right: 0,
        top: isFirst ? 0 : AppSpacing.xxl, // 0px first, 24px subsequent
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 5), // 5px per JSX
          ],
          Text(
            td(ref, labelKey),
            style: AppTypography.bodySmHeavy.copyWith(
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

  /// Extracts section field from document, with matchCount fallback
  String _getSection(dynamic businessData, int totalActiveFilters) {
    // First, try matchCount fallback (handles API version mismatch, caching, etc.)
    if (businessData is Map && !businessData.containsKey('section')) {
      final matchCount = _getMatchCount(businessData);
      if (matchCount == totalActiveFilters) return 'fullMatch';
      if (matchCount == totalActiveFilters - 1) return 'partialMatch';
      return 'others';
    }

    // Then read section field from API response
    if (businessData is Map && businessData.containsKey('section')) {
      final section = businessData['section'];
      if (section is String &&
          ['fullMatch', 'partialMatch', 'others'].contains(section)) {
        return section;
      }
    }

    // Final fallback: invalid or missing section → "others"
    return 'others';
  }

  /// Maps API section values to existing header variant strings
  String _mapSectionToVariant(String section) {
    switch (section) {
      case 'fullMatch':
        return 'full';
      case 'partialMatch':
        return 'partial';
      case 'others':
        return 'none';
      default:
        return 'none';
    }
  }

  /// Maps section strings to numeric levels for comparison
  int _getSectionLevel(String section) {
    switch (section) {
      case 'fullMatch': return 0;
      case 'partialMatch': return 1;
      case 'others': return 2;
      default: return 2; // Treat unknown as 'others'
    }
  }

  /// Validates that documents are in proper section order (fullMatch → partialMatch → others)
  bool _isProperlyOrdered(List<dynamic> documents, int totalActiveFilters) {
    if (documents.isEmpty) return true;

    int maxSectionLevel = -1; // fullMatch=0, partialMatch=1, others=2

    for (final doc in documents) {
      final section = _getSection(doc, totalActiveFilters);
      final currentLevel = _getSectionLevel(section);

      // Backwards transition detected (e.g., others → partial)
      if (currentLevel < maxSectionLevel) {
        return false;
      }

      maxSectionLevel = currentLevel;
    }

    return true; // All transitions are forward
  }

  /// Ensures documents are in proper section order
  /// Fast path: If already ordered, return as-is (99% of cases)
  /// Backup path: Re-group by section if ordering is wrong
  List<dynamic> _ensureProperSectionOrder(List<dynamic> documents, int totalActiveFilters) {
    // Fast path: If already ordered, return as-is (99% of cases)
    if (_isProperlyOrdered(documents, totalActiveFilters)) {
      return documents;
    }

    // Backup path: Re-group by section

    // Group into three lists
    final fullMatch = <dynamic>[];
    final partialMatch = <dynamic>[];
    final others = <dynamic>[];

    for (final doc in documents) {
      final section = _getSection(doc, totalActiveFilters);
      switch (section) {
        case 'fullMatch': fullMatch.add(doc); break;
        case 'partialMatch': partialMatch.add(doc); break;
        case 'others': others.add(doc); break;
      }
    }

    // Return in proper order (preserves original order within each section)
    return [...fullMatch, ...partialMatch, ...others];
  }

  /// Builds sectioned list with backend-driven section headers
  Widget _buildSectionedList(List<dynamic> documents, int totalActiveFilters) {
    // Safety net - ensure proper order
    final orderedDocuments = _ensureProperSectionOrder(documents, totalActiveFilters);

    final items = <Widget>[];
    String? previousSection;
    int itemIndex = 0; // Global analytics counter

    for (final doc in orderedDocuments) {
      final currentSection = _getSection(doc, totalActiveFilters);

      // Insert header when section changes
      if (currentSection != previousSection) {
        final isFirst = previousSection == null;
        items.add(_buildSectionHeader(
          _mapSectionToVariant(currentSection),
          isFirst: isFirst,
        ));
        previousSection = currentSection;
      }

      // Render card
      final variant = _mapSectionToVariant(currentSection);
      items.add(_buildBusinessCard(doc, variant, totalActiveFilters, itemIndex++));
      items.add(SizedBox(height: _itemSeparatorHeight));
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _onScroll(notification);
        return false;
      },
      child: ListView(
        controller: _listScrollController,
        primary: false,
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xxxl),
        children: items,
      ),
    );
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
          const SizedBox(height: AppSpacing.lg),
          Text(
            td(ref, 'noresultsfound'),
            style: AppTypography.bodyLg.copyWith(
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
    required this.matchVariant,
    required this.activeFilterCount,
    required this.itemIndex,
    this.statusText,
    this.statusColor,
    this.onStatusLoaded,
    this.onBusinessTap,
  });

  final dynamic businessData;
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

  static const double _imageSize = AppConstants.logoCircleSize; // 50px per design spec
  static const double _galleryThumbSize = 100.0;
  static const String _placeholderImageUrl = AppConstants.kPlaceholderImageUrl;

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
  String? get _street => _getField<String>('street');
  String? get _neighbourhoodName => _getField<String>('neighbourhood_name');
  String? get _postalCode => _getField<String>('postal_code');
  String? get _city => _getField<String>('postal_city'); // API returns 'postal_city', not 'city'
  int? get _priceRangeMin => _getField<int>('price_range_min');
  int? get _priceRangeMax => _getField<int>('price_range_max');
  dynamic get _openingHours => _getField<dynamic>('business_hours');
  int? get _matchCount => _getField<int>('matchCount');
  List<dynamic>? get _missedFilters => _getField<List<dynamic>>('missedFilters');
  List<dynamic>? get _galleryImages => _getField<List<dynamic>>('gallery_images');

  String? get _businessType {
    final languageCode = Localizations.localeOf(context).languageCode;
    final localizedType = _getField<String>('business_type_$languageCode');
    return localizedType ?? _getField<String>('business_type');
  }

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  double get _rowSpacing {
    return AppSpacing.xxs; // Static 2px per JSX
  }

  /// Returns border color based on match variant
  Color get _borderColor {
    switch (widget.matchVariant) {
      case 'full':
        return AppColors.fullMatchCardBorder;
      case 'partial':
        return AppColors.orangeBorder;
      case 'none':
      default:
        return AppColors.border;
    }
  }

  double get _exchangeRate => ref.watch(localizationProvider).exchangeRate;
  String get _userCurrencyCode => ref.watch(localizationProvider).currencyCode;

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
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      // Make entire card area tappable, not just areas with visible widgets
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: _imageSize),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: _borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.card), // 16px per JSX
        ),
        padding: const EdgeInsets.all(AppSpacing.mlg), // 14px per JSX
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Base card content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImage(),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildInfoColumn()),
                  ],
                ),
                // Partial match info box (inside card, above chevron)
                if (widget.matchVariant == 'partial' && widget.activeFilterCount > 0)
                  _buildPartialMatchInfoBox(),
                // Collapse chevron (shown when NOT expanded)
                if (!_isExpanded) _buildCollapseChevron(),
              ],
            ),
            // Expanded preview section
            if (_isExpanded) _buildExpandedPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.logoSmall), // 12px
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
        errorWidget: (context, url, error) => CachedNetworkImage(
          imageUrl: _placeholderImageUrl,
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
          ),
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
        // Address removed from collapsed state - only shows in expanded
      ],
    );
  }

  Widget _buildNameRow() {
    final distanceText = _getDistanceText();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _businessName ?? 'Business',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyHeavy,
          ),
        ),
        if (distanceText != null) ...[
          const SizedBox(width: 8), // Prevent text collision
          Text(
            distanceText,
            style: AppTypography.bodySmMedium, // 12px w500
          ),
        ],
      ],
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
          style: AppTypography.bodySm.copyWith(
            color: statusColor,
          ),
        ),
        if (timingText != null && timingText.isNotEmpty) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '•',
            style: AppTypography.bodySm.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              timingText,
              style: AppTypography.bodySm, // 12.5px, no override needed
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
    return result;
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
          style: AppTypography.bodySm, // 12.5px per JSX
        ),
      ));
    }

    // Price range
    final priceRange = _getPriceRangeText();
    if (priceRange != null && priceRange.isNotEmpty) {
      if (items.isNotEmpty) {
        items.addAll([
          const SizedBox(width: AppSpacing.xs),
          Text('•',
              style: AppTypography.bodySm
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: AppSpacing.xs),
        ]);
      }
      items.add(Text(
        priceRange,
        style: AppTypography.bodySm, // 12.5px per JSX
      ));
    }

    // Distance is now in name row - removed from here

    return Row(mainAxisSize: MainAxisSize.min, children: items);
  }

  String? _getPriceRangeText() {
    if (_priceRangeMin == null || _priceRangeMax == null) {
      return null;
    }

    // Use existing price_formatter from Session #5
    // Force no decimals for search results page
    final result = convertAndFormatPriceRange(
      _priceRangeMin!.toDouble(),
      _priceRangeMax!.toDouble(),
      'DKK',
      _exchangeRate,
      _userCurrencyCode,
      forceNoDecimals: true,
    );
    return result;
  }

  String? _getDistanceText() {
    // Use precomputed distance fields from Typesense node v9.3.
    // distanceFromStation is non-null only when sortBy=station with a valid
    // station, so it naturally takes priority when present.
    final rawMeters = _getField<int>('distanceFromStation')
        ?? _getField<int>('distanceFromUser');

    if (rawMeters == null) return null;

    final languageCode = Localizations.localeOf(context).languageCode;

    // Non-English: ALWAYS metric. English: use stored preference.
    final distanceUnit = languageCode == 'en'
        ? ref.read(localizationProvider).distanceUnit
        : 'metric';

    // Convert meters → km, then to miles if imperial
    var distance = rawMeters / 1000.0;
    if (distanceUnit == 'imperial') {
      distance = distance * 0.621371;
    }
    distance = double.parse(distance.toStringAsFixed(1));

    return formatDistanceText(distance, distanceUnit);
  }

  // Address removed from collapsed state - now only in expanded state via _buildFullAddress()

  // ---------------------------------------------------------------------------
  // Expandable Card Preview
  // ---------------------------------------------------------------------------

  Widget _buildCollapseChevron() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSpacing.xsm,
        bottom: AppSpacing.xs,
      ),
      child: Center(
        child: Icon(
          Icons.keyboard_arrow_down,
          size: 14, // Approximate 14×8px SVG
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildExpandedPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 1,
          color: AppColors.divider,
        ),
        const SizedBox(height: AppSpacing.md),
        // Full address
        _buildFullAddress(),
        // When sorting by station, card header shows station distance,
        // so show user distance here to provide both data points.
        if (_getField<int>('distanceFromStation') != null)
          _buildDistanceFromUser(),
        const SizedBox(height: AppSpacing.xsm),
        // Today's hours
        _buildTodayHours(),
        const SizedBox(height: AppSpacing.md),
        // Swipeable gallery
        if (_galleryImages != null && _galleryImages!.isNotEmpty) _buildSwipeableGallery(),
        if (_galleryImages != null && _galleryImages!.isNotEmpty) const SizedBox(height: AppSpacing.md),
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
      style: AppTypography.bodySm.copyWith(
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildDistanceFromUser() {
    final rawMeters = _getField<int>('distanceFromUser');
    if (rawMeters == null) return const SizedBox.shrink();

    final languageCode = Localizations.localeOf(context).languageCode;
    final distanceUnit = languageCode == 'en'
        ? ref.read(localizationProvider).distanceUnit
        : 'metric';

    var distance = rawMeters / 1000.0;
    if (distanceUnit == 'imperial') {
      distance = distance * 0.621371;
    }
    distance = double.parse(distance.toStringAsFixed(1));

    final formatted = formatDistanceText(distance, distanceUnit);
    // translation_value already contains ":" — just add a space before the number
    return Text(
      '${td(ref, 'distance_from_you')} $formatted',
      style: AppTypography.bodySm.copyWith(
        color: AppColors.textTertiary,
      ),
    );
  }

  Widget _buildTodayHours() {
    if (_openingHours == null) {
      return Text(
        td(ref, 'hours_no_data'),
        style: AppTypography.bodySm.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    // Get today's hours string
    final todayStr = _getTodayHoursRange();

    return Text(
      '${td(ref, 'today_prefix')} $todayStr', // Space between label and time
      style: AppTypography.bodySm.copyWith(
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
      return td(ref, 'closed');
    }

    final dayHoursMap = Map<String, dynamic>.from(dayHours);

    // Check if closed
    final closed = dayHoursMap['closed'] == true ||
        dayHoursMap['closed'] == 'true' ||
        dayHoursMap['by_appointment_only'] == true ||
        dayHoursMap['by_appointment_only'] == 'true';

    if (closed) {
      return td(ref, 'closed');
    }

    // Get first time slot (most common case)
    final openTime = dayHoursMap['opening_time_1']?.toString();
    final closeTime = dayHoursMap['closing_time_1']?.toString();

    if (openTime != null && closeTime != null) {
      // Strip seconds from time format (08:00:00 -> 08:00)
      final formattedOpen = _formatTime(openTime);
      final formattedClose = _formatTime(closeTime);

      // Check if there are multiple slots
      final slot2Open = dayHoursMap['opening_time_2']?.toString();
      if (slot2Open != null) {
        // Multiple slots - show first slot with indicator
        return '$formattedOpen-$formattedClose +';
      }
      return '$formattedOpen-$formattedClose';
    }

    return td(ref, 'hours_no_data');
  }

  /// Helper to strip seconds from time string (HH:MM:SS -> HH:MM)
  String _formatTime(String time) {
    // If time contains seconds (e.g., "08:00:00"), strip them
    if (time.length > 5 && time.contains(':')) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
    }
    return time;
  }

  Widget _buildSwipeableGallery() {
    final galleryImages = _galleryImages!;
    final displayImages = galleryImages.take(12).toList(); // Max 12 images

    // Convert gallery images to URL strings for ImageGalleryWidget
    final imageUrls = displayImages
        .map((img) => img is String ? img : (img['url'] as String? ?? _placeholderImageUrl))
        .toList();

    return SizedBox(
      height: _galleryThumbSize,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayImages.length,
        itemBuilder: (context, index) {
          final imageUrl = imageUrls[index];

          return Padding(
            padding: EdgeInsets.only(right: index < displayImages.length - 1 ? 8 : 0),
            child: GestureDetector(
              // Prevent taps from bubbling up to parent card GestureDetector
              behavior: HitTestBehavior.opaque,
              onTap: () {
                ImageGalleryWidget.show(
                  context,
                  imageUrls: imageUrls,
                  currentIndex: index,
                  categoryName: td(ref, 'gallery_food'),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: _galleryThumbSize,
                  height: _galleryThumbSize,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: _galleryThumbSize,
                    height: _galleryThumbSize,
                    color: AppColors.bgInput,
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: _galleryThumbSize,
                    height: _galleryThumbSize,
                    color: AppColors.border,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppColors.textTertiary,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeeMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {
          final businessId = _getField<int>('business_id') ?? 0;

          // Validate businessId before navigating
          if (businessId > 0) {
            // Cache preview data for instant display
            if (widget.businessData is Map<String, dynamic>) {
              BusinessCache.instance.cacheBusinessPreview(
                widget.businessData as Map<String, dynamic>,
              );
            }

            widget.onBusinessTap?.call(businessId);
          } else {
            // Show error to user
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Unable to open business details'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          backgroundColor: AppColors.bgCard,
          side: BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.filter),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              td(ref, 'expandable_show_more'),
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.textSecondary,
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
            if (filter != null && filter['name'] != null) {
              missedNames.add(
                _buildCombinedFilterName(filterId, filter, state.filterLookupMap),
              );
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
      margin: EdgeInsets.only(top: AppSpacing.sm), // 8px top spacing inside card
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.orangeBg,
        borderRadius: BorderRadius.circular(AppRadius.filter),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              missedNames.isNotEmpty ? '$matchesText · $missingText' : matchesText,
              style: AppTypography.bodySm.copyWith(
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

  /// Builds display name for a missed filter, combining parent+child names
  /// for known parent-child combos. Mirrors selected_filters_btns._getDisplayName().
  ///
  /// - Bakery children (585, 586): "$parentName ${lowercaseChild}"
  /// - All other children (158, 159, 588, 184-207): "$parentName: $childName"
  /// - Non-combo filters: plain filter name
  static const _comboParentChildren = <int, List<int>>{
    56: [585, 586],
    58: [158, 159],
    55: [588],
    100: [196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207],
    101: [184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195],
  };
  static const _bakeryChildIds = {585, 586};
  static final _allComboChildIds =
      _comboParentChildren.values.expand((list) => list).toSet();

  String _buildCombinedFilterName(
    int filterId,
    dynamic filter,
    Map<int, dynamic> filterLookupMap,
  ) {
    final childName = filter['name'] as String;

    if (!_allComboChildIds.contains(filterId)) return childName;

    // Look up parent name from the lookup map
    final parentId = filter['parent_id'] as int?;
    if (parentId == null) return childName;

    final parentFilter = filterLookupMap[parentId];
    final parentName = parentFilter?['name'] as String?;
    if (parentName == null) return childName;

    // Bakery children: "Bageri med café" (lowercase, no colon)
    if (_bakeryChildIds.contains(filterId)) {
      final lowercased = childName.isNotEmpty
          ? childName[0].toLowerCase() + childName.substring(1)
          : childName;
      return '$parentName $lowercased';
    }

    // All others: "Parent: Child"
    return '$parentName: $childName';
  }

  // _formatAddress() removed - address now only shown in expanded state via _buildFullAddress()
}
