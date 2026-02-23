import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../theme/app_colors.dart';
import '../../models/lat_lng.dart';
import '../../providers/app_providers.dart';
import '../../services/custom_functions/distance_calculator.dart';
import '../../services/custom_functions/address_formatter.dart';
import '../../services/custom_functions/hours_formatter.dart';
import '../../services/custom_functions/price_formatter.dart';
import '../../services/custom_actions/determine_status_and_color.dart';

/// Hero section component for Business Profile page.
///
/// Displays critical business information in a compact 107px card:
/// - Business logo (100x100)
/// - Business name
/// - Status (open/closed) with hours
/// - Type, price range, and distance
/// - Address
///
/// Features:
/// - Async status calculation via determineStatusAndColor action
/// - Intelligent address formatting via streetAndNeighbourhoodLength
/// - Currency-aware price formatting via convertAndFormatPriceRange
/// - Distance calculation from user location via returnDistance
/// - Hours messaging via openClosesAt
///
/// All data passed via props (no Riverpod dependencies).
class ProfileTopBusinessBlockWidget extends ConsumerStatefulWidget {
  const ProfileTopBusinessBlockWidget({
    super.key,
    required this.openingHours,
    required this.userLocation,
    required this.priceRangeMin,
    required this.priceRangeMax,
    this.profilePicture,
    this.businessName,
    this.latitude,
    this.longitude,
    this.street,
    this.neighbourhoodName,
    this.businessID,
    this.businessType,
  });

  /// Business hours map (JSONB with 7 days × 5 time slots)
  final dynamic openingHours;

  /// User's current coordinates for distance calculation
  final LatLng? userLocation;

  /// Minimum price in DKK
  final int priceRangeMin;

  /// Maximum price in DKK
  final int priceRangeMax;

  /// Business logo/image URL
  final String? profilePicture;

  /// Business display name
  final String? businessName;

  /// Business location latitude
  final double? latitude;

  /// Business location longitude
  final double? longitude;

  /// Street address
  final String? street;

  /// Borough/neighbourhood name
  final String? neighbourhoodName;

  /// Unique business identifier
  final int? businessID;

  /// Category (e.g., "Vegetarian Restaurant")
  final String? businessType;

  @override
  ConsumerState<ProfileTopBusinessBlockWidget> createState() =>
      _ProfileTopBusinessBlockWidgetState();
}

class _ProfileTopBusinessBlockWidgetState
    extends ConsumerState<ProfileTopBusinessBlockWidget> {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  /// Status text from determineStatusAndColor action
  /// (e.g., "Open", "Closed", "Opening soon", "Closing soon")
  String? _statusText;

  /// Status indicator color from determineStatusAndColor action
  /// (green for open, red for closed)
  Color? _statusColor;

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void initState() {
    super.initState();

    // Call determineStatusAndColor action after first frame
    // This is an async operation that updates _statusColor and _statusText
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadStatusAndColor();
    });
  }

  /// Calls determineStatusAndColor action to calculate business status
  Future<void> _loadStatusAndColor() async {
    if (!mounted) return;

    try {
      // Call action with positional parameters
      final statusText = await determineStatusAndColor(
        // 1. statuscolor callback
        (Color color) async {
          if (mounted) {
            setState(() => _statusColor = color);
          }
        },
        // 2. businessHoursInput
        widget.openingHours,
        // 3. currentDateTime
        DateTime.now(),
        // 4. languageCode
        Localizations.localeOf(context).languageCode,
        // 5. translationsCache
        ref.read(translationsCacheProvider),
      );

      // Update status text
      if (mounted) {
        setState(() => _statusText = statusText);
      }
    } catch (e) {
      // Silent failure - show default status
      if (mounted) {
        setState(() {
          _statusText = 'Status unknown';
          _statusColor = Colors.grey;
        });
      }
    }
  }

  // ============================================================================
  // BUILD METHOD
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 107.0, // Fixed height from FlutterFlow
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        // No border radius (FlutterFlow uses 0.0 for all corners)
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          _buildBusinessImage(),
          const SizedBox(width: 8.0), // FlutterFlow spacing
          Expanded(child: _buildInfoSection()),
        ],
      ),
    );
  }

  // ============================================================================
  // BUSINESS IMAGE SECTION
  // ============================================================================

  Widget _buildBusinessImage() {
    final imageUrl = widget.profilePicture;

    if (imageUrl == null || imageUrl.isEmpty) {
      // Show placeholder if no image
      return Container(
        width: 100.0,
        height: 100.0,
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(5.0), // FlutterFlow radius
        ),
        child: Icon(
          Icons.business,
          size: 40.0,
          color: AppColors.textTertiary,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0), // FlutterFlow radius
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: 100.0,
        height: 100.0,
        fit: BoxFit.scaleDown, // Match FlutterFlow
        placeholder: (context, url) => Container(
          width: 100.0,
          height: 100.0,
          color: AppColors.bgSurface,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 100.0,
          height: 100.0,
          decoration: BoxDecoration(
            color: AppColors.bgSurface,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Icon(
            Icons.broken_image,
            size: 40.0,
            color: AppColors.textTertiary,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // INFO SECTION (4 ROWS)
  // ============================================================================

  Widget _buildInfoSection() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildRow1BusinessName(),
        const SizedBox(height: 3.0), // FlutterFlow spacing between rows
        _buildRow2StatusAndHours(),
        const SizedBox(height: 3.0),
        _buildRow3TypePriceDistance(),
        const SizedBox(height: 3.0),
        _buildRow4Address(),
      ],
    );
  }

  // ============================================================================
  // ROW 1: BUSINESS NAME
  // ============================================================================

  Widget _buildRow1BusinessName() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            widget.businessName ?? 'BusinessName', // FlutterFlow fallback
            style: TextStyle(
              fontFamily: 'Roboto', // Using Roboto as default
              fontSize: 20.0, // FlutterFlow custom size
              fontWeight: FontWeight.w500, // FlutterFlow weight
              color: AppColors.textPrimary,
              letterSpacing: 0.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // ROW 2: STATUS + HOURS
  // ============================================================================

  Widget _buildRow2StatusAndHours() {
    // Get hours text from openClosesAt function
    final hoursText = openClosesAt(
      widget.openingHours,
      DateTime.now(),
      Localizations.localeOf(context).languageCode,
      ref.read(translationsCacheProvider),
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Status indicator dot (8x8 circle)
        if (_statusColor != null)
          Container(
            width: 8.0,
            height: 8.0,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
        if (_statusColor != null) const SizedBox(width: 4.0),

        // Status text
        Text(
          _statusText ?? 'Open', // Default fallback
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15.0, // FlutterFlow custom size
            fontWeight: FontWeight.w400, // FlutterFlow weight
            color: _statusColor ?? AppColors.textSecondary,
            letterSpacing: 0.0,
          ),
        ),

        // Bullet separator
        const SizedBox(width: 4.0),
        Text(
          '•',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 15.0,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            letterSpacing: 0.0,
          ),
        ),
        const SizedBox(width: 4.0),

        // Hours text
        Expanded(
          child: Text(
            hoursText,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.w300, // FlutterFlow weight (lighter)
              color: AppColors.textSecondary,
              letterSpacing: 0.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // ROW 3: TYPE + PRICE + DISTANCE
  // ============================================================================

  Widget _buildRow3TypePriceDistance() {
    // Get price range text
    final priceText = convertAndFormatPriceRange(
      widget.priceRangeMin.toDouble(),
      widget.priceRangeMax.toDouble(),
      'DKK', // Source currency
      1.0, // TODO: Get actual exchange rate from localizationProvider
      'DKK', // TODO: Get target currency from localizationProvider
    );

    // Calculate distance if user location and business location are available
    String? distanceText;
    if (widget.userLocation != null &&
        widget.latitude != null &&
        widget.longitude != null) {
      try {
        final distance = returnDistance(
          widget.userLocation!,
          widget.latitude!,
          widget.longitude!,
          Localizations.localeOf(context).languageCode,
        );

        // Format distance with unit (function returns number only)
        final languageCode = Localizations.localeOf(context).languageCode;
        final unit = languageCode == 'en' ? ' mi.' : '  km.';
        distanceText = '$distance$unit';
      } catch (e) {
        // Silent failure - hide distance on error
        distanceText = null;
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Business type
        if (widget.businessType != null)
          Text(
            widget.businessType!,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
              letterSpacing: 0.0,
            ),
          ),

        // Bullet + Price
        if (widget.businessType != null && priceText != null) ...[
          const SizedBox(width: 4.0),
          Text(
            '•',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(width: 4.0),
        ],

        // Price range
        if (priceText != null)
          Text(
            priceText,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
              letterSpacing: 0.0,
            ),
          ),

        // Bullet + Distance (only if location available)
        if (distanceText != null) ...[
          const SizedBox(width: 4.0),
          Text(
            '•',
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(width: 4.0),
          Text(
            distanceText,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ],
    );
  }

  // ============================================================================
  // ROW 4: ADDRESS
  // ============================================================================

  Widget _buildRow4Address() {
    // Get formatted address
    String addressText;
    if (widget.street != null && widget.neighbourhoodName != null) {
      addressText = streetAndNeighbourhoodLength(
        widget.neighbourhoodName!,
        widget.street!,
      );
    } else if (widget.street != null) {
      addressText = widget.street!;
    } else if (widget.neighbourhoodName != null) {
      addressText = widget.neighbourhoodName!;
    } else {
      addressText = 'København'; // FlutterFlow fallback
    }

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            addressText,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
              letterSpacing: 0.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
