// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';
import 'package:provider/provider.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';

/// A performant ListView displaying search results for businesses.
///
/// Encapsulates all list rendering, item display, tap handling, analytics,
/// and navigation logic. Shows shimmer loading state when data is
/// unavailable.
///
/// This widget explicitly listens to FFAppState changes and rebuilds when
/// searchResults updates, ensuring real-time updates from search bar.
class SearchResultsListView extends StatefulWidget {
  const SearchResultsListView({
    super.key,
    this.width,
    this.height,
    required this.userLocation,
  });

  final double? width;
  final double? height;
  final LatLng userLocation;

  @override
  State<SearchResultsListView> createState() => _SearchResultsListViewState();
}

class _SearchResultsListViewState extends State<SearchResultsListView> {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const double _imageSize = 84.0;
  static const String _placeholderImageUrl =
      'https://tlqfuazpshfaozdvmcbh.supabase.co/storage/v1/object/public/profilepic_restaurants/placeholder.webp';

  // ---------------------------------------------------------------------------
  // State
  // ---------------------------------------------------------------------------

  /// Cache for status text per business (keyed by business_id)
  final Map<int, String?> _statusTextCache = {};

  /// Cache for status colors per business (keyed by business_id)
  final Map<int, Color?> _statusColorCache = {};

  /// Listener for FFAppState changes
  VoidCallback? _appStateListener;

  /// Last known search results to detect changes
  dynamic _lastSearchResults;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _lastSearchResults = FFAppState().searchResults;
    _setupAppStateListener();
  }

  @override
  void dispose() {
    _removeAppStateListener();
    super.dispose();
  }

  /// Sets up listener for FFAppState changes
  void _setupAppStateListener() {
    // Access FFAppState through context when it becomes available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _appStateListener = () {
        if (!mounted) return;

        final currentResults = FFAppState().searchResults;

        // Only rebuild if search results actually changed
        if (currentResults != _lastSearchResults) {
          debugPrint('🔄 SearchResultsListView detected FFAppState change');
          _lastSearchResults = currentResults;

          // Force rebuild when search results change
          if (mounted) {
            setState(() {});
          }
        }
      };

      // Add listener
      FFAppState().addListener(_appStateListener!);
    });
  }

  /// Removes the FFAppState listener
  void _removeAppStateListener() {
    if (_appStateListener != null) {
      FFAppState().removeListener(_appStateListener!);
      _appStateListener = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  /// Row spacing based on font scale setting
  double get _rowSpacing => FFAppState().fontScale ? 4.0 : 2.0;

  /// Item separator height based on font scale
  double get _itemSeparatorHeight => FFAppState().fontScale ? 4.0 : 2.0;

  /// Search results from app state
  dynamic get _searchResults => FFAppState().searchResults;

  /// List of business documents from search results
  List<dynamic> get _documents {
    if (_searchResults == null) return [];
    try {
      return getJsonField(_searchResults, r'$.documents')?.toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  /// Whether we have data to display
  bool get _hasData => _searchResults != null && _documents.isNotEmpty;

  /// Whether to show shimmer (no data yet)
  bool get _showShimmer => _searchResults == null;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Still use context.watch for other FFAppState properties
    context.watch<FFAppState>();

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height,
      child: Stack(
        children: [
          if (_hasData) _buildListView(),
          if (!_showShimmer && !_hasData) _buildEmptyState(),
          if (_showShimmer) _buildShimmer(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // List View
  // ---------------------------------------------------------------------------

  Widget _buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 32),
      itemCount: _documents.length,
      separatorBuilder: (_, __) => SizedBox(height: _itemSeparatorHeight),
      itemBuilder: (context, index) {
        final businessData = _documents[index];
        final businessId = _getJsonInt(businessData, r'$.business_id');

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () => _handleBusinessTap(businessData, index),
              child: _BusinessListItem(
                key: ValueKey('business_$businessId'),
                businessData: businessData,
                userLocation: widget.userLocation,
                statusText: _statusTextCache[businessId],
                statusColor: _statusColorCache[businessId],
                onStatusLoaded: (text, color) {
                  if (businessId != null) {
                    _statusTextCache[businessId] = text;
                    _statusColorCache[businessId] = color;
                  }
                },
              ),
            ),
            Divider(
              thickness: 1,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Tap Handler
  // ---------------------------------------------------------------------------

  Future<void> _handleBusinessTap(dynamic businessData, int index) async {
    final businessId = _getJsonInt(businessData, r'$.business_id');
    final businessName = _getJsonString(businessData, r'$.business_name');
    final openingHours = getJsonField(businessData, r'$.business_hours');
    final filters = (getJsonField(businessData, r'$.filters', true) as List?)
        ?.cast<int>()
        .toList();

    if (businessId == null) {
      debugPrint('❌ Cannot navigate: missing business_id');
      return;
    }

    // Unfocus any active text fields before navigation
    FocusScope.of(context).unfocus();

    // Fire analytics in background (non-blocking)
    unawaited(_trackBusinessClick(businessId, index));

    // Mark user as engaged (non-blocking)
    unawaited(actions.markUserEngaged());

    // Store minimal state for next page
    FFAppState().openingHours = openingHours;
    if (filters != null) {
      FFAppState().filtersOfSelectedBusiness = filters;
    }

    // Navigate
    if (mounted) {
      context.pushNamed(
        BusinessProfileWidget.routeName,
        pathParameters: {
          'businessId': serializeParam(businessId, ParamType.int) ?? '',
          'businessName':
              serializeParam(businessName ?? 'Business', ParamType.String) ??
                  '',
        },
      );
    }
  }

  /// Tracks business click analytics event
  Future<void> _trackBusinessClick(int businessId, int position) async {
    try {
      await actions.trackAnalyticsEvent(
        'business_clicked',
        <String, String>{
          'businessId': businessId.toString(),
          'clickPosition': position.toString(),
          'filterSessionId': FFAppState().currentFilterSessionId,
          'timeOnListSeconds': functions
              .getSessionDurationSeconds(FFAppState().sessionStartTime!)
              .toString(),
          'totalResults': FFAppState().searchResultsCount.toString(),
        },
      );
    } catch (e) {
      debugPrint('⚠️ Analytics tracking failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Empty & Shimmer States
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(height: 16),
          Text(
            FFLocalizations.of(context).getVariableText(
              enText: 'No results found',
              daText: 'Ingen resultater fundet',
              deText: 'Keine Ergebnisse gefunden',
              itText: 'Nessun risultato trovato',
              svText: 'Inga resultat hittades',
              noText: 'Ingen resultater funnet',
              frText: 'Aucun résultat trouvé',
            ),
            style: FlutterFlowTheme.of(context).titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return custom_widgets.RestaurantListShimmerWidget(
      width: double.infinity,
      height: double.infinity,
    );
  }

  // ---------------------------------------------------------------------------
  // JSON Helpers
  // ---------------------------------------------------------------------------

  int? _getJsonInt(dynamic json, String path) {
    try {
      final value = getJsonField(json, path);
      if (value is int) return value;
      if (value is num) return value.toInt();
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _getJsonString(dynamic json, String path) {
    try {
      return getJsonField(json, path)?.toString();
    } catch (_) {
      return null;
    }
  }
}

// =============================================================================
// Business List Item Widget
// =============================================================================

class _BusinessListItem extends StatefulWidget {
  const _BusinessListItem({
    super.key,
    required this.businessData,
    required this.userLocation,
    this.statusText,
    this.statusColor,
    this.onStatusLoaded,
  });

  final dynamic businessData;
  final LatLng userLocation;
  final String? statusText;
  final Color? statusColor;
  final void Function(String? text, Color? color)? onStatusLoaded;

  @override
  State<_BusinessListItem> createState() => _BusinessListItemState();
}

class _BusinessListItemState extends State<_BusinessListItem> {
  String? _statusText;
  Color? _statusColor;

  // ---------------------------------------------------------------------------
  // JSON Field Extraction
  // ---------------------------------------------------------------------------

  T? _getField<T>(String path) {
    try {
      return getJsonField(widget.businessData, path) as T?;
    } catch (_) {
      return null;
    }
  }

  String? get _profilePicture => _getField<String>(r'$.profile_picture_url');
  String? get _businessName => _getField<String>(r'$.business_name');
  double? get _latitude => _getField<num>(r'$.latitude')?.toDouble();
  double? get _longitude => _getField<num>(r'$.longitude')?.toDouble();
  String? get _street => _getField<String>(r'$.street');
  String? get _neighbourhoodName => _getField<String>(r'$.neighbourhood_name');
  int? get _priceRangeMin => _getField<int>(r'$.price_range_min');
  int? get _priceRangeMax => _getField<int>(r'$.price_range_max');
  dynamic get _openingHours => _getField<dynamic>(r'$.business_hours');

  String? get _businessType {
    final languageCode = FFLocalizations.of(context).languageCode;
    final localizedType = _getField<String>('\$.business_type_$languageCode');
    return localizedType ?? _getField<String>(r'$.business_type');
  }

  // ---------------------------------------------------------------------------
  // Computed Properties
  // ---------------------------------------------------------------------------

  double get _rowSpacing => FFAppState().fontScale ? 4.0 : 2.0;
  double get _exchangeRate => FFAppState().exchangeRate;
  String get _userCurrencyCode => FFAppState().userCurrencyCode;
  bool get _locationEnabled => FFAppState().locationStatus;

  static const double _imageSize = 84.0;
  static const String _placeholderImageUrl =
      'https://tlqfuazpshfaozdvmcbh.supabase.co/storage/v1/object/public/profilepic_restaurants/placeholder.webp';

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

    final text = await actions.determineStatusAndColor(
      (color) async {
        if (mounted) {
          setState(() => _statusColor = color);
        }
      },
      _openingHours,
      getCurrentTimestamp,
      FFLocalizations.of(context).languageCode,
      FFAppState().translationsCache,
    );

    if (mounted) {
      setState(() => _statusText = text);
      widget.onStatusLoaded?.call(text, _statusColor);
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
      overflow: TextOverflow.clip,
      style: FlutterFlowTheme.of(context).titleLarge.override(
            fontFamily: FlutterFlowTheme.of(context).titleLargeFamily,
            fontSize: 18,
            fontWeight: FontWeight.normal,
            letterSpacing: 0,
            useGoogleFonts: !FlutterFlowTheme.of(context).titleLargeIsCustom,
          ),
    );
  }

  Widget _buildStatusRow() {
    final theme = FlutterFlowTheme.of(context);
    final languageCode = FFLocalizations.of(context).languageCode;
    final isOpen = FFAppState().BusinessIsOpen;

    final statusText = isOpen
        ? (_statusText ?? _getLocalizedText('Open', 'Åben'))
        : _getLocalizedText('Closed', 'Lukket');
    final statusColor = isOpen ? (_statusColor ?? theme.success) : theme.error;
    final statusWeight = isOpen ? FontWeight.normal : FontWeight.w600;

    final timingText = _openingHours != null
        ? functions.openClosesAt(
            _openingHours,
            getCurrentTimestamp,
            languageCode,
            FFAppState().translationsCache,
          )
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          statusText,
          style: _bodyStyle(color: statusColor, fontWeight: statusWeight),
        ),
        if (timingText != null && timingText.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text('•', style: _bodyStyle()),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              timingText,
              style: _bodyStyle(),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailsRow() {
    final languageCode = FFLocalizations.of(context).languageCode;

    String? priceRange;
    if (_priceRangeMin != null && _priceRangeMax != null) {
      priceRange = functions.convertAndFormatPriceRange(
        _priceRangeMin!.toDouble(),
        _priceRangeMax!.toDouble(),
        'DKK',
        _exchangeRate,
        _userCurrencyCode,
      );
    }

    String? distanceText;
    if (_locationEnabled && _latitude != null && _longitude != null) {
      final distance = functions.returnDistance(
        widget.userLocation,
        _latitude!,
        _longitude!,
        languageCode,
      );
      final unit = languageCode == 'en' ? ' mi.' : ' km.';
      distanceText = '$distance$unit';
    }

    final items = <Widget>[];

    if (_businessType != null && _businessType!.isNotEmpty) {
      items.add(Flexible(
        child: Text(
          _businessType!,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: _bodyStyle(),
        ),
      ));
    }

    if (priceRange != null && priceRange.isNotEmpty) {
      if (items.isNotEmpty) {
        items.addAll([
          const SizedBox(width: 4),
          Text('•', style: _bodyStyle()),
          const SizedBox(width: 4),
        ]);
      }
      items.add(Text(priceRange, style: _bodyStyle()));
    }

    if (distanceText != null) {
      if (items.isNotEmpty) {
        items.addAll([
          const SizedBox(width: 4),
          Text('•', style: _bodyStyle()),
          const SizedBox(width: 4),
        ]);
      }
      items.add(Text(distanceText, style: _bodyStyle()));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: items);
  }

  Widget _buildAddressRow() {
    final address = _formatAddress();
    return Text(
      address,
      maxLines: 1,
      overflow: TextOverflow.clip,
      style: _bodyStyle(),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _formatAddress() {
    final street = _street ?? '';
    final neighbourhood = _neighbourhoodName ?? '';

    if (street.isEmpty && neighbourhood.isEmpty) {
      return _getLocalizedText(
          'Address unavailable', 'Adresse ikke tilgængelig');
    }
    if (street.isEmpty) return neighbourhood;
    if (neighbourhood.isEmpty) return street;

    return functions.streetAndNeighbourhoodLength(neighbourhood, street);
  }

  TextStyle _bodyStyle({Color? color, FontWeight? fontWeight}) {
    final theme = FlutterFlowTheme.of(context);
    return theme.bodyMedium.override(
      fontFamily: theme.bodyMediumFamily,
      fontSize: 15,
      letterSpacing: 0.0,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w300,
      useGoogleFonts: !theme.bodyMediumIsCustom,
    );
  }

  String _getLocalizedText(String en, String da) {
    return FFLocalizations.of(context).languageCode == 'da' ? da : en;
  }
}
