import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:map_launcher/map_launcher.dart' as ml;
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../services/translation_service.dart';
import '../../providers/business_providers.dart';
import '../../providers/app_providers.dart';
import 'opening_hours_and_weekdays.dart';

/// Displays business contact information with consistent typography across
/// all accessibility settings.
///
/// Features:
/// - Consistent bold text rendering matching app-wide standards
/// - Conditional display of contact methods based on availability
/// - Integrated with translation system for multilingual support
/// - Responsive spacing based on accessibility settings
/// - Composes OpeningHoursAndWeekdays widget for hours display
/// - Interactive elements with engagement tracking
///
/// Data is sourced from providers:
/// - Business info from businessProvider
/// - Opening hours from businessProvider
/// - Accessibility settings from accessibilityProvider
class ContactDetailsWidget extends ConsumerStatefulWidget {
  const ContactDetailsWidget({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  ConsumerState<ContactDetailsWidget> createState() =>
      _ContactDetailsWidgetState();
}

class _ContactDetailsWidgetState extends ConsumerState<ContactDetailsWidget> {
  // ============================================================================
  // CONSTANTS
  // ============================================================================

  static const double _sectionSpacingNormal = 16.0;
  static const double _sectionSpacingBold = 20.0;
  static const double _itemSpacing = 2.0;
  static const double _contactInfoTopPaddingNormal = 0.0;
  static const double _contactInfoTopPaddingBold = 2.0;
  static const double _contactInfoBottomPadding = 8.0;

  static const double _dividerThickness = 1.0;

  // ============================================================================
  // DATA ACCESSORS
  // ============================================================================

  /// Extracts a field from business data safely
  String _getBusinessField(Map<String, dynamic>? businessData, String field,
      {String fallback = ''}) {
    if (businessData == null) return fallback;
    final value = businessData[field];
    if (value == null) return fallback;
    final stringValue = value.toString();
    // Treat 'null' string as null value
    return stringValue == 'null' ? fallback : stringValue;
  }

  // ============================================================================
  // TRANSLATION HELPERS
  // ============================================================================

  String _getUIText(BuildContext context, String key) {
    return td(ref, key);
  }

  // ============================================================================
  // COMPUTED PROPERTIES
  // ============================================================================

  double get _sectionSpacing {
    final accessibility = ref.watch(accessibilityProvider);
    return accessibility.isBoldTextEnabled
        ? _sectionSpacingBold
        : _sectionSpacingNormal;
  }

  double get _contactInfoTopPadding {
    final accessibility = ref.watch(accessibilityProvider);
    return accessibility.isBoldTextEnabled
        ? _contactInfoTopPaddingBold
        : _contactInfoTopPaddingNormal;
  }

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void didUpdateWidget(ContactDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // State rebuilds automatically via Riverpod watchers
  }

  // ============================================================================
  // UI BUILDERS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    final business = ref.watch(businessProvider);
    final currentBusiness = business.currentBusiness;

    if (currentBusiness == null) {
      return const SizedBox.shrink();
    }

    // Safe cast to Map
    final businessData = currentBusiness is Map<String, dynamic>
        ? currentBusiness
        : <String, dynamic>{};

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAddressSection(context, businessData),
        _buildOpeningHoursSection(context),
        _buildContactInfoSection(context, businessData),
      ]
          .expand((widget) => [widget, SizedBox(height: _sectionSpacing)])
          .toList()
        ..removeLast(), // Remove trailing spacing
    );
  }

  /// Builds the address section with street, postal code, and map link
  Widget _buildAddressSection(
      BuildContext context, Map<String, dynamic> businessData) {
    final street = _getBusinessField(businessData, 'street');
    final postalCode = _getBusinessField(businessData, 'postal_code');
    final postalCity = _getBusinessField(businessData, 'postal_city');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUIText(context, 'address_label'), // address
          style: AppTypography.sectionHeading,
        ),
        Text(
          street,
          style: AppTypography.bodyRegular,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$postalCode, ',
              style: AppTypography.bodyRegular,
            ),
            Text(
              postalCity,
              style: AppTypography.bodyRegular,
            ),
          ].expand((w) => [w, const SizedBox(width: 2)]).toList()
            ..removeLast(),
        ),
        InkWell(
          onTap: () => _handleMapTap(context, businessData),
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Text(
            _getUIText(context, 'view_on_map_action'), // view on map
            style: AppTypography.bodyRegular.copyWith(
              color: AppColors.accent,
            ),
          ),
        ),
      ].expand((w) => [w, const SizedBox(height: _itemSpacing)]).toList()
        ..removeLast(),
    );
  }

  /// Builds the opening hours section by composing OpeningHoursAndWeekdays
  Widget _buildOpeningHoursSection(BuildContext context) {
    final business = ref.watch(businessProvider);
    final openingHours = business.openingHours;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUIText(context, 'opening_hours_label'), // opening hours
          style: AppTypography.sectionHeading,
        ),
        OpeningHoursAndWeekdays(
          width: double.infinity,
          openingHours: openingHours,
        ),
      ].expand((w) => [w, const SizedBox(height: _itemSpacing)]).toList()
        ..removeLast(),
    );
  }

  /// Builds the contact information section with all available contact methods
  Widget _buildContactInfoSection(
      BuildContext context, Map<String, dynamic> businessData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: _contactInfoTopPadding,
            bottom: _contactInfoBottomPadding,
          ),
          child: Text(
            _getUIText(context, 'feedback_form_title_contact_info'), // contact information
            style: AppTypography.sectionHeading,
          ),
        ),
        ..._buildContactMethodsList(context, businessData),
      ],
    );
  }

  /// Builds list of available contact methods
  List<Widget> _buildContactMethodsList(
      BuildContext context, Map<String, dynamic> businessData) {
    final methods = <Widget>[];

    final phoneGeneral = _getBusinessField(businessData, 'general_phone');
    if (phoneGeneral.isNotEmpty) {
      methods.add(_buildPhoneRow(context, phoneGeneral));
    }

    final emailGeneral = _getBusinessField(businessData, 'general_email');
    if (emailGeneral.isNotEmpty) {
      methods.add(_buildEmailRow(context, emailGeneral));
    }

    final urlWebsite = _getBusinessField(businessData, 'website_url');
    if (urlWebsite.isNotEmpty) {
      methods.add(_buildWebsiteRow(context, urlWebsite));
    }

    final urlReservation = _getBusinessField(businessData, 'reservation_url');
    if (urlReservation.isNotEmpty) {
      methods.add(_buildReservationRow(context, urlReservation));
    }

    final urlInstagram = _getBusinessField(businessData, 'instagram_url');
    if (urlInstagram.isNotEmpty) {
      methods.add(_buildInstagramRow(context, urlInstagram));
    }

    final urlFacebook = _getBusinessField(businessData, 'facebook_url');
    if (urlFacebook.isNotEmpty) {
      methods.add(_buildFacebookRow(context, urlFacebook));
    }

    return methods;
  }

  /// Builds phone contact row with tap and long-press handlers
  Widget _buildPhoneRow(BuildContext context, String phone) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(context, 'phone_number_label'), // phone number
              style: AppTypography.bodyRegular,
            ),
            InkWell(
              onTap: () => _handlePhoneTap(phone),
              onLongPress: () => _handlePhoneLongPress(context, phone),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                '+45 $phone',
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  /// Builds email contact row with tap and long-press handlers
  Widget _buildEmailRow(BuildContext context, String email) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(context, 'email_label'), // email
              style: AppTypography.bodyRegular,
            ),
            InkWell(
              onTap: () => _handleEmailTap(email),
              onLongPress: () => _handleEmailLongPress(context, email),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(context, 'send_email_action'), // send email
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  /// Builds website link row
  Widget _buildWebsiteRow(BuildContext context, String url) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(context, 'website'), // website
              style: AppTypography.bodyRegular,
            ),
            InkWell(
              onTap: () => _handleWebsiteTap(url),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(context, 'visit_website_action'), // visit website
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  /// Builds reservation link row
  Widget _buildReservationRow(BuildContext context, String url) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(context, 'booking'), // reservation
              style: AppTypography.bodyRegular,
            ),
            InkWell(
              onTap: () => _handleReservationTap(url),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(context, 'make_reservation_action'), // make reservation
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  /// Builds Instagram link row
  Widget _buildInstagramRow(BuildContext context, String url) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(context, 'instagram'), // instagram
              style: AppTypography.bodyRegular,
            ),
            InkWell(
              onTap: () => _handleInstagramTap(url),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(context, 'view_instagram_action'), // view on Instagram
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  /// Builds Facebook link row
  Widget _buildFacebookRow(BuildContext context, String url) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(context, 'facebook_label'), // facebook
              style: AppTypography.bodyRegular,
            ),
            InkWell(
              onTap: () => _handleFacebookTap(url),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(context, 'view_facebook_action'), // view on Facebook
                style: AppTypography.bodyRegular.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        _buildDivider(),
      ],
    );
  }

  /// Builds a standard divider
  Widget _buildDivider() {
    return const Divider(
      thickness: _dividerThickness,
      color: Color(0x4057636C),
    );
  }

  // ============================================================================
  // INTERACTION HANDLERS
  // ============================================================================

  /// Handles map link tap
  Future<void> _handleMapTap(
      BuildContext context, Map<String, dynamic> businessData) async {
    final businessName = _getBusinessField(businessData, 'business_name');
    final latitude = businessData['latitude'] as double?;
    final longitude = businessData['longitude'] as double?;

    if (latitude != null && longitude != null) {
      final availableMaps = await ml.MapLauncher.installedMaps;
      if (availableMaps.isNotEmpty && context.mounted) {
        await availableMaps.first.showMarker(
          coords: ml.Coords(latitude, longitude),
          title: businessName,
        );
      }
    }
  }

  /// Handles phone number tap (initiates call)
  Future<void> _handlePhoneTap(String phone) async {
    await launchUrl(Uri(
      scheme: 'tel',
      path: '+45$phone',
    ));
  }

  /// Handles phone number long press (shows copy dialog)
  Future<void> _handlePhoneLongPress(BuildContext context, String phone) async {
    if (!mounted) return;

    final copied = await _showCopyDialog(
      context,
      '+45$phone',
      td(ref, 'missing_location_copy_to_clipboard'), // "Copy to clipboard"
    );

    if (copied && context.mounted) {
      await _showCopiedConfirmation(context);
    }
  }

  /// Handles email tap (opens email client)
  Future<void> _handleEmailTap(String email) async {
    await launchUrl(Uri(
      scheme: 'mailto',
      path: email,
    ));
  }

  /// Handles email long press (shows copy dialog)
  Future<void> _handleEmailLongPress(BuildContext context, String email) async {
    if (!mounted) return;

    final copied = await _showCopyDialog(
      context,
      email,
      td(ref, 'missing_location_copy_to_clipboard'),
    );

    if (copied && context.mounted) {
      await _showCopiedConfirmation(context);
    }
  }

  /// Handles website link tap
  Future<void> _handleWebsiteTap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Handles reservation link tap
  Future<void> _handleReservationTap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Handles Instagram link tap
  Future<void> _handleInstagramTap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Handles Facebook link tap
  Future<void> _handleFacebookTap(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // ============================================================================
  // DIALOG HELPERS
  // ============================================================================

  /// Shows copy-to-clipboard dialog, returns true if user tapped to copy
  Future<bool> _showCopyDialog(
      BuildContext context, String text, String prompt) async {
    bool copied = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: InkWell(
          onTap: () {
            Clipboard.setData(ClipboardData(text: text));
            copied = true;
            Navigator.of(dialogContext).pop();
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              prompt,
              style: AppTypography.bodyRegular,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    return copied;
  }

  /// Shows "Copied!" confirmation dialog with 1-second auto-dismiss
  Future<void> _showCopiedConfirmation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: Text(
          td(ref, 'missing_location_copied'), // "Copied!"
          style: AppTypography.bodyRegular,
          textAlign: TextAlign.center,
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}
