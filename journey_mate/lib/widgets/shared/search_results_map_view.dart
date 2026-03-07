import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/search_providers.dart';
import '../../providers/provider_state_classes.dart';
import '../../providers/settings_providers.dart';
import '../../theme/app_spacing.dart';
import '../../utils/map_marker_helper.dart';
import '../../utils/search_result_helpers.dart';
import 'map_business_preview_card.dart';

/// Map view for search results, displayed when the user toggles to "Kort" mode.
///
/// Renders a Google Map with dot markers for each search result, color-coded
/// by match status. Tapping a marker shows a preview card at the bottom.
/// Tapping the preview card navigates to the business profile.
///
/// Self-contained widget: reads search results and location from providers.
class SearchResultsMapView extends ConsumerStatefulWidget {
  const SearchResultsMapView({
    super.key,
    this.onBusinessTap,
    this.onViewportChanged,
  });

  /// Called when a business is selected (navigate to profile).
  final void Function(int businessId)? onBusinessTap;

  /// Called when the user manually moves/zooms the map and the camera settles.
  /// Provides the visible region bounds for viewport-based search.
  final void Function(LatLngBounds bounds)? onViewportChanged;

  @override
  ConsumerState<SearchResultsMapView> createState() =>
      _SearchResultsMapViewState();
}

class _SearchResultsMapViewState extends ConsumerState<SearchResultsMapView> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  int? _selectedBusinessId;

  /// Cached documents from last build to avoid re-extracting on marker tap.
  List<dynamic> _documents = [];

  /// Cached bounds from last marker build to avoid double iteration.
  LatLngBounds? _lastBounds;

  /// Guards against concurrent/duplicate _buildMarkers calls.
  bool _isBuilding = false;

  /// Subscription for search state changes — closed in dispose().
  late final ProviderSubscription<SearchState> _searchListener;

  /// Suppresses onCameraIdle callback during programmatic camera animations
  /// (e.g. fitBounds, marker tap centering) to prevent infinite fetch loops.
  bool _suppressViewportCallback = false;

  /// Debounce timer for rapid pan/zoom camera movements.
  Timer? _viewportDebounce;

  /// Last viewport bounds reported to parent, used to skip no-op re-fetches.
  LatLngBounds? _lastReportedBounds;

  // Copenhagen default center
  static const LatLng _defaultCenter = LatLng(55.6761, 12.5683);
  static const double _defaultZoom = 12.0;

  /// Minimum change in degrees before a viewport change triggers re-fetch.
  static const double _significantChangeThreshold = 0.001;

  @override
  void initState() {
    super.initState();
    // Listen for search result changes and rebuild markers accordingly.
    // This avoids side effects inside build().
    _searchListener = ref.listenManual(searchStateProvider, (previous, next) {
      final documents = extractDocuments(next.searchResults);
      _documents = documents;
      // Clear selection when results change
      _selectedBusinessId = null;
      // Don't re-fit camera if user has manually panned (viewport search active).
      // The user intentionally moved to this viewport — re-fitting would undo that.
      final shouldFitCamera = _lastReportedBounds == null;
      _rebuildMarkersAndFit(documents, next.scoringFilterIds,
          fitCamera: shouldFitCamera);
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _viewportDebounce?.cancel();
    _searchListener.close();
    _mapController?.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Marker generation
  // ---------------------------------------------------------------------------

  /// Rebuilds markers and optionally fits camera bounds.
  /// When [fitCamera] is false (e.g. after viewport-based search), markers are
  /// rebuilt but the camera stays where the user positioned it.
  void _rebuildMarkersAndFit(
      List<dynamic> documents, List<int> scoringFilterIds,
      {bool fitCamera = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _buildMarkers(documents, scoringFilterIds).then((_) {
          if (mounted && fitCamera) _fitBounds();
        });
      }
    });
  }

  /// Builds markers and computes camera bounds in a single pass over documents.
  Future<void> _buildMarkers(
      List<dynamic> documents, List<int> scoringFilterIds) async {
    if (_isBuilding) return;
    _isBuilding = true;

    try {
      final markers = <Marker>{};
      final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

      // Track bounds while iterating to avoid a second pass
      double? minLat, maxLat, minLng, maxLng;

      for (final doc in documents) {
        if (doc is! Map) continue;

        final lat = (doc['latitude'] as num?)?.toDouble();
        final lng = (doc['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        // Update bounds
        minLat = minLat == null ? lat : (lat < minLat ? lat : minLat);
        maxLat = maxLat == null ? lat : (lat > maxLat ? lat : maxLat);
        minLng = minLng == null ? lng : (lng < minLng ? lng : minLng);
        maxLng = maxLng == null ? lng : (lng > maxLng ? lng : maxLng);

        final businessId = getBusinessId(doc);
        final matchVariant = getMatchVariant(doc, scoringFilterIds);
        final color = MapMarkerHelper.colorForMatchVariant(matchVariant);
        final isSelected = businessId == _selectedBusinessId;

        final icon = await MapMarkerHelper.createDotMarker(
          color: color,
          selected: isSelected,
          devicePixelRatio: devicePixelRatio,
        );

        markers.add(Marker(
          markerId: MarkerId('business_$businessId'),
          position: LatLng(lat, lng),
          icon: icon,
          zIndexInt: isSelected ? 1 : 0,
          onTap: () => _onMarkerTap(businessId),
        ));
      }

      // Compute bounds from accumulated min/max
      _lastBounds = _computeBounds(minLat, maxLat, minLng, maxLng);

      if (mounted) {
        setState(() => _markers = markers);
      }
    } finally {
      _isBuilding = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Camera bounds
  // ---------------------------------------------------------------------------

  LatLngBounds? _computeBounds(
      double? minLat, double? maxLat, double? minLng, double? maxLng) {
    if (minLat == null || maxLat == null || minLng == null || maxLng == null) {
      return null;
    }

    // Add a small padding if all points are at the same location
    if (minLat == maxLat && minLng == maxLng) {
      const offset = 0.005;
      return LatLngBounds(
        southwest: LatLng(minLat - offset, minLng - offset),
        northeast: LatLng(maxLat + offset, maxLng + offset),
      );
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _fitBounds() {
    if (_lastBounds != null && _mapController != null) {
      // Suppress viewport callback to prevent fetch→fitBounds→fetch loop
      _suppressViewportCallback = true;
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_lastBounds!, 48.0),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Interaction
  // ---------------------------------------------------------------------------

  void _onMarkerTap(int businessId) {
    final doc = _documents.firstWhere(
      (d) => getBusinessId(d) == businessId,
      orElse: () => null,
    );

    if (doc == null || doc is! Map) return;

    setState(() {
      _selectedBusinessId = businessId;
    });

    // Rebuild markers to show selected state
    final scoringFilterIds = ref.read(searchStateProvider).scoringFilterIds;
    _buildMarkers(_documents, scoringFilterIds);

    // Center map on selected marker (suppress viewport callback)
    final lat = (doc['latitude'] as num?)?.toDouble();
    final lng = (doc['longitude'] as num?)?.toDouble();
    if (lat != null && lng != null) {
      _suppressViewportCallback = true;
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    }
  }

  void _clearSelection() {
    if (_selectedBusinessId == null) return;
    setState(() {
      _selectedBusinessId = null;
    });
    final scoringFilterIds = ref.read(searchStateProvider).scoringFilterIds;
    _buildMarkers(_documents, scoringFilterIds);
  }

  void _onMapTap(LatLng position) {
    _clearSelection();
  }

  // ---------------------------------------------------------------------------
  // Viewport change detection
  // ---------------------------------------------------------------------------

  /// Called by GoogleMap.onCameraIdle after every camera movement settles.
  /// Debounces rapid pan/zoom, skips programmatic animations, and reports
  /// significant viewport changes to the parent via [onViewportChanged].
  void _onCameraIdle() {
    // Skip if this idle was triggered by a programmatic camera animation
    if (_suppressViewportCallback) {
      _suppressViewportCallback = false;
      return;
    }

    // Skip if no callback is registered
    if (widget.onViewportChanged == null) return;

    // Debounce: cancel any pending callback and wait 500ms
    _viewportDebounce?.cancel();
    _viewportDebounce = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted || _mapController == null) return;

      final bounds = await _mapController!.getVisibleRegion();

      // Skip if viewport hasn't changed significantly
      if (!_isSignificantChange(bounds)) return;

      _lastReportedBounds = bounds;
      widget.onViewportChanged?.call(bounds);
    });
  }

  /// Returns true if the new bounds differ from the last reported bounds
  /// by more than [_significantChangeThreshold] degrees in any direction.
  bool _isSignificantChange(LatLngBounds bounds) {
    if (_lastReportedBounds == null) return true;

    final prev = _lastReportedBounds!;
    return (bounds.northeast.latitude - prev.northeast.latitude).abs() > _significantChangeThreshold ||
        (bounds.northeast.longitude - prev.northeast.longitude).abs() > _significantChangeThreshold ||
        (bounds.southwest.latitude - prev.southwest.latitude).abs() > _significantChangeThreshold ||
        (bounds.southwest.longitude - prev.southwest.longitude).abs() > _significantChangeThreshold;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  /// Finds the selected business document from cached documents.
  Map<String, dynamic>? get _selectedBusiness {
    if (_selectedBusinessId == null) return null;
    final doc = _documents.firstWhere(
      (d) => getBusinessId(d) == _selectedBusinessId,
      orElse: () => null,
    );
    if (doc is Map) return Map<String, dynamic>.from(doc);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Determine initial camera position
    final locationState = ref.watch(locationProvider);
    final userPosition = locationState.currentPosition;

    final initialTarget = userPosition != null
        ? LatLng(userPosition.latitude, userPosition.longitude)
        : _defaultCenter;

    final selectedBusiness = _selectedBusiness;

    return Stack(
      children: [
        // Google Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialTarget,
            zoom: _defaultZoom,
          ),
          markers: _markers,
          myLocationEnabled: userPosition != null,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          trafficEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
            // Fit bounds once map is ready (markers already built via listener)
            _fitBounds();
          },
          onCameraIdle: _onCameraIdle,
          onTap: _onMapTap,
        ),

        // Preview card (when a marker is selected)
        if (selectedBusiness != null)
          Positioned(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            bottom: 56, // Above the floating sort button
            child: MapBusinessPreviewCard(
              key: ValueKey('preview_$_selectedBusinessId'),
              businessData: selectedBusiness,
              onTap: () {
                if (_selectedBusinessId != null) {
                  widget.onBusinessTap?.call(_selectedBusinessId!);
                }
              },
            ),
          ),
      ],
    );
  }
}
