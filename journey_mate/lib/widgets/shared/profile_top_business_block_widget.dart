import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../theme/app_colors.dart';
import '../../providers/app_providers.dart';
import '../../providers/business_providers.dart';
import '../../providers/settings_providers.dart';
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
/// - Self-contained (reads all data from providers internally)
class ProfileTopBusinessBlockWidget extends ConsumerStatefulWidget {
  const ProfileTopBusinessBlockWidget({super.key});

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

    // Read opening hours from provider
    final openingHours = ref.read(businessProvider).openingHours;
    if (openingHours == null) return;

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
        openingHours,
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
    // Read from provider
    final business = ref.watch(businessProvider).currentBusiness;
    final imageUrl = business?['profile_picture']?['url'] as String?;

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
    // Read from provider
    final business = ref.watch(businessProvider).currentBusiness;
    final businessName = business?['business_name'] as String? ?? 'BusinessName';

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            businessName,
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
    // Read from provider
    final openingHours = ref.watch(businessProvider).openingHours;

    // Get hours text from openClosesAt function
    final hoursText = openClosesAt(
      openingHours,
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
    // Read from providers
    final business = ref.watch(businessProvider).currentBusiness;
    final localization = ref.watch(localizationProvider);

    // Extract business data
    final priceRangeMin = (business?['price_range_min'] as int?) ?? 0;
    final priceRangeMax = (business?['price_range_max'] as int?) ?? 0;
    final businessType = business?['business_type'] as String?;

    // Get price range text with actual currency conversion
    final priceText = convertAndFormatPriceRange(
      priceRangeMin.toDouble(),
      priceRangeMax.toDouble(),
      'DKK', // Source currency (business data is in DKK)
      localization.exchangeRate,
      localization.currencyCode,
    );

    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Business type
        if (businessType != null)
          Text(
            businessType,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 15.0,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
              letterSpacing: 0.0,
            ),
          ),

        // Bullet + Price
        if (businessType != null && priceText != null) ...[
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

        // TODO: Add distance calculation (requires async location fetch)
      ],
    );
  }

  // ============================================================================
  // ROW 4: ADDRESS
  // ============================================================================

  Widget _buildRow4Address() {
    // Read from provider
    final business = ref.watch(businessProvider).currentBusiness;
    final street = business?['address']?['street'] as String?;
    final neighbourhoodName = business?['address']?['neighbourhood_name'] as String?;

    // Get formatted address
    String addressText;
    if (street != null && neighbourhoodName != null) {
      addressText = streetAndNeighbourhoodLength(
        neighbourhoodName,
        street,
      );
    } else if (street != null) {
      addressText = street;
    } else if (neighbourhoodName != null) {
      addressText = neighbourhoodName;
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
