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

import 'package:map_launcher/map_launcher.dart' as $ml;
import 'package:url_launcher/url_launcher.dart';

import '/profile/contact_details/copy_to_clipboard_phone/copy_to_clipboard_phone_widget.dart';
import '/profile/contact_details/copy_to_clipboard_email/copy_to_clipboard_email_widget.dart';

// ============================================================================
// CONSTANTS & CONFIGURATION
// ============================================================================

/// Layout and styling constants for the contact details widget
class _LayoutConstants {
  static const double sectionSpacingNormal = 16.0;
  static const double sectionSpacingBold = 20.0;
  static const double itemSpacing = 2.0;
  static const double contactInfoTopPaddingNormal = 0.0;
  static const double contactInfoTopPaddingBold = 2.0;
  static const double contactInfoBottomPadding = 8.0;

  static const double titleFontSize = 18.0;
  static const double bodyFontSize = 16.0;

  static const FontWeight titleWeight = FontWeight.normal;
  static const FontWeight bodyLightWeight = FontWeight.w300;
  static const FontWeight bodyNormalWeight = FontWeight.normal;

  static const double dividerThickness = 1.0;
}

/// Color constants for the contact details widget
class _ColorConstants {
  static const Color textPrimary = Color(0xFF14181B);
  static const Color divider = Color(0x4057636C);
}

/// Translation keys for UI text
class _TranslationKeys {
  static const String address = 'fvn7c52j';
  static const String viewOnMap = 'wemfo75s';
  static const String openingHours = 'v1z4dvep';
  static const String contactInformation = 's0a1ukr7';
  static const String phoneNumber = 'nd4d9n42';
  static const String email = 'z32g0m7g';
  static const String sendEmail = '4p3u9ngw';
  static const String website = '8pvvg34m';
  static const String visitWebsite = '9hmbepnd';
  static const String reservation = 'zaws00rk';
  static const String makeReservation = 'g6jqo5n0';
  static const String instagram = '35r2ixsz';
  static const String viewOnInstagram = 'i39eb4yz';
  static const String facebook = 'ehwtf95b';
  static const String viewOnFacebook = 'nhhhl06z';
}

// ============================================================================
// MAIN WIDGET
// ============================================================================

/// Displays business contact information with consistent typography across
/// all accessibility settings.
///
/// Features: - Consistent bold text rendering matching app-wide standards -
/// Conditional display of contact methods based on availability - Integrated
/// with translation system for multilingual support - Responsive spacing
/// based on accessibility settings - Composes OpeningHoursAndWeekdays widget
/// for hours display - Interactive elements with engagement tracking
///
/// Data is sourced directly from FFAppState: - Business info from
/// FFAppState().mostRecentlyViewedBusiness - Opening hours from
/// FFAppState().openingHours
///
/// Parameters: languageCode: ISO language code for localized translations
/// translationsCache: Translation cache from FFAppState
class ContactDetailsWidget extends StatefulWidget {
  const ContactDetailsWidget({
    super.key,
    this.width,
    this.height,
    required this.languageCode,
    required this.translationsCache,
  });

  final double? width;
  final double? height;
  final String languageCode;
  final dynamic translationsCache;

  @override
  State<ContactDetailsWidget> createState() => _ContactDetailsWidgetState();
}

class _ContactDetailsWidgetState extends State<ContactDetailsWidget> {
  // ============================================================================
  // DATA ACCESSORS
  // ============================================================================

  /// Gets business data from FFAppState with safe access pattern
  dynamic get _businessData => FFAppState().mostRecentlyViewedBusiness;

  /// Gets opening hours from FFAppState
  dynamic get _openingHours => FFAppState().openingHours;

  /// Extracts a field from business data safely
  String _getBusinessField(String jsonPath, {String fallback = ''}) {
    final value = getJsonField(_businessData, jsonPath);
    if (value == null) return fallback;
    final stringValue = value.toString();
    // Treat 'null' string as null value
    return stringValue == 'null' ? fallback : stringValue;
  }

  // Address fields
  String get _street => _getBusinessField(r'''$.businessInfo.street''');
  String get _postalCode =>
      _getBusinessField(r'''$.businessInfo.postal_code''');
  String get _postalCity =>
      _getBusinessField(r'''$.businessInfo.postal_city''');
  String get _businessName =>
      _getBusinessField(r'''$.businessInfo.business_name''');

  // Location coordinates
  double? get _latitude =>
      getJsonField(_businessData, r'''$.businessInfo.latitude''');
  double? get _longitude =>
      getJsonField(_businessData, r'''$.businessInfo.longitude''');

  // Contact information
  String? get _phoneGeneral {
    final phone = _getBusinessField(r'''$.businessInfo.general_phone''');
    return phone.isEmpty ? null : phone;
  }

  String? get _emailGeneral {
    final email = _getBusinessField(r'''$.businessInfo.general_email''');
    return email.isEmpty ? null : email;
  }

  String? get _urlWebsite {
    final url = _getBusinessField(r'''$.businessInfo.website_url''');
    return url.isEmpty ? null : url;
  }

  String? get _urlReservation {
    final url = _getBusinessField(r'''$.businessInfo.reservation_url''');
    return url.isEmpty ? null : url;
  }

  String? get _urlInstagram {
    final url = _getBusinessField(r'''$.businessInfo.instagram_url''');
    return url.isEmpty ? null : url;
  }

  String? get _urlFacebook {
    final url = _getBusinessField(r'''$.businessInfo.facebook_url''');
    return url.isEmpty ? null : url;
  }

  // ============================================================================
  // TRANSLATION HELPERS
  // ============================================================================

  /// Gets localized UI text using central translation function
  String _getUIText(String key) {
    return getTranslations(
      widget.languageCode,
      key,
      widget.translationsCache,
    );
  }

  // ============================================================================
  // COMPUTED PROPERTIES
  // ============================================================================

  /// Gets section spacing based on bold text setting
  double get _sectionSpacing {
    return FFAppState().isBoldTextEnabled
        ? _LayoutConstants.sectionSpacingBold
        : _LayoutConstants.sectionSpacingNormal;
  }

  /// Gets contact info top padding based on bold text setting
  double get _contactInfoTopPadding {
    return FFAppState().isBoldTextEnabled
        ? _LayoutConstants.contactInfoTopPaddingBold
        : _LayoutConstants.contactInfoTopPaddingNormal;
  }

  // ============================================================================
  // LIFECYCLE METHODS
  // ============================================================================

  @override
  void didUpdateWidget(ContactDetailsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Rebuild when translations or language changes
    if (widget.translationsCache != oldWidget.translationsCache ||
        widget.languageCode != oldWidget.languageCode) {
      setState(() {});
    }
  }

  // ============================================================================
  // UI BUILDERS
  // ============================================================================

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildAddressSection(),
        _buildOpeningHoursSection(),
        _buildContactInfoSection(),
      ].divide(SizedBox(height: _sectionSpacing)),
    );
  }

  /// Builds the address section with street, postal code, and map link
  Widget _buildAddressSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUIText(_TranslationKeys.address),
          style: _getTitleStyle(),
        ),
        Text(
          _street,
          style: _getBodyLightStyle(),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_postalCode, ',
              style: _getBodyLightStyle(),
            ),
            Text(
              _postalCity,
              style: _getBodyLightStyle(),
            ),
          ].divide(const SizedBox(width: 2)),
        ),
        InkWell(
          onTap: _handleMapTap,
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Text(
            _getUIText(_TranslationKeys.viewOnMap),
            style: _getBodyNormalStyle().copyWith(
              color: FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
      ].divide(const SizedBox(height: _LayoutConstants.itemSpacing)),
    );
  }

  /// Builds the opening hours section by composing OpeningHoursAndWeekdays
  Widget _buildOpeningHoursSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getUIText(_TranslationKeys.openingHours),
          style: _getTitleStyle(),
        ),
        OpeningHoursAndWeekdays(
          width: double.infinity,
          languageCode: widget.languageCode,
          openingHours: _openingHours,
          translationsCache: widget.translationsCache,
        ),
      ].divide(const SizedBox(height: _LayoutConstants.itemSpacing)),
    );
  }

  /// Builds the contact information section with all available contact methods
  Widget _buildContactInfoSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: _contactInfoTopPadding,
            bottom: _LayoutConstants.contactInfoBottomPadding,
          ),
          child: Text(
            _getUIText(_TranslationKeys.contactInformation),
            style: _getTitleStyle(),
          ),
        ),
        ..._buildContactMethodsList(),
      ],
    );
  }

  /// Builds list of available contact methods
  List<Widget> _buildContactMethodsList() {
    final methods = <Widget>[];

    if (_phoneGeneral != null) {
      methods.add(_buildPhoneRow());
    }

    if (_emailGeneral != null) {
      methods.add(_buildEmailRow());
    }

    if (_urlWebsite != null) {
      methods.add(_buildWebsiteRow());
    }

    if (_urlReservation != null) {
      methods.add(_buildReservationRow());
    }

    if (_urlInstagram != null) {
      methods.add(_buildInstagramRow());
    }

    if (_urlFacebook != null) {
      methods.add(_buildFacebookRow());
    }

    return methods;
  }

  /// Builds phone contact row with tap and long-press handlers
  Widget _buildPhoneRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(_TranslationKeys.phoneNumber),
              style: _getBodyLightStyle(),
            ),
            InkWell(
              onTap: () => _handlePhoneTap(_phoneGeneral!),
              onLongPress: () => _handlePhoneLongPress(_phoneGeneral!),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                '+45 $_phoneGeneral',
                style: _getBodyNormalStyle().copyWith(
                  color: FlutterFlowTheme.of(context).primary,
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
  Widget _buildEmailRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(_TranslationKeys.email),
              style: _getBodyLightStyle(),
            ),
            InkWell(
              onTap: () => _handleEmailTap(_emailGeneral!),
              onLongPress: () => _handleEmailLongPress(_emailGeneral!),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(_TranslationKeys.sendEmail),
                style: _getBodyNormalStyle().copyWith(
                  color: FlutterFlowTheme.of(context).primary,
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
  Widget _buildWebsiteRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(_TranslationKeys.website),
              style: _getBodyLightStyle(),
            ),
            InkWell(
              onTap: () => _handleWebsiteTap(_urlWebsite!),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(_TranslationKeys.visitWebsite),
                style: _getBodyNormalStyle().copyWith(
                  color: FlutterFlowTheme.of(context).primary,
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
  Widget _buildReservationRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(_TranslationKeys.reservation),
              style: _getBodyLightStyle(),
            ),
            InkWell(
              onTap: () => _handleReservationTap(_urlReservation!),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(_TranslationKeys.makeReservation),
                style: _getBodyNormalStyle().copyWith(
                  color: FlutterFlowTheme.of(context).primary,
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
  Widget _buildInstagramRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(_TranslationKeys.instagram),
              style: _getBodyLightStyle(),
            ),
            InkWell(
              onTap: () => _handleInstagramTap(_urlInstagram!),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(_TranslationKeys.viewOnInstagram),
                style: _getBodyNormalStyle().copyWith(
                  color: FlutterFlowTheme.of(context).primary,
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
  Widget _buildFacebookRow() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getUIText(_TranslationKeys.facebook),
              style: _getBodyLightStyle(),
            ),
            InkWell(
              onTap: () => _handleFacebookTap(_urlFacebook!),
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Text(
                _getUIText(_TranslationKeys.viewOnFacebook),
                style: _getBodyNormalStyle().copyWith(
                  color: FlutterFlowTheme.of(context).primary,
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
      thickness: _LayoutConstants.dividerThickness,
      color: _ColorConstants.divider,
    );
  }

  // ============================================================================
  // INTERACTION HANDLERS
  // ============================================================================

  /// Handles map link tap
  Future<void> _handleMapTap() async {
    await markUserEngaged();

    await launchMap(
      mapType: $ml.MapType.google,
      address: '$_businessName, $_street, $_postalCode $_postalCity',
      title: _businessName,
    );
  }

  /// Handles phone number tap (initiates call)
  Future<void> _handlePhoneTap(String phone) async {
    await markUserEngaged();

    await launchUrl(Uri(
      scheme: 'tel',
      path: '+45$phone',
    ));
  }

  /// Handles phone number long press (shows copy dialog)
  Future<void> _handlePhoneLongPress(String phone) async {
    await markUserEngaged();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0, 1),
          child: CopyToClipboardPhoneWidget(
            phoneNumber: '+45$phone',
          ),
        );
      },
    );
  }

  /// Handles email tap (opens email client)
  Future<void> _handleEmailTap(String email) async {
    await markUserEngaged();

    await launchUrl(Uri(
      scheme: 'mailto',
      path: email,
    ));
  }

  /// Handles email long press (shows copy dialog)
  Future<void> _handleEmailLongPress(String email) async {
    await markUserEngaged();

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          elevation: 0,
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          alignment: const AlignmentDirectional(0, 1),
          child: CopyToClipboardEmailWidget(
            email: email,
          ),
        );
      },
    );
  }

  /// Handles website link tap
  Future<void> _handleWebsiteTap(String url) async {
    await markUserEngaged();
    await launchURL(url);
  }

  /// Handles reservation link tap
  Future<void> _handleReservationTap(String url) async {
    await markUserEngaged();
    await launchURL(url);
  }

  /// Handles Instagram link tap
  Future<void> _handleInstagramTap(String url) async {
    await markUserEngaged();
    await launchURL(url);
  }

  /// Handles Facebook link tap
  Future<void> _handleFacebookTap(String url) async {
    await markUserEngaged();
    await launchURL(url);
  }

  // ============================================================================
  // STYLING
  // ============================================================================

  /// Gets title text style (used for section headers)
  TextStyle _getTitleStyle() {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontSize: _LayoutConstants.titleFontSize,
      fontWeight: _LayoutConstants.titleWeight,
      color: _ColorConstants.textPrimary,
    );
  }

  /// Gets light body text style (used for labels)
  TextStyle _getBodyLightStyle() {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontSize: _LayoutConstants.bodyFontSize,
      fontWeight: _LayoutConstants.bodyLightWeight,
      color: _ColorConstants.textPrimary,
    );
  }

  /// Gets normal body text style (used for links)
  TextStyle _getBodyNormalStyle() {
    return const TextStyle(
      fontFamily: 'Roboto',
      fontSize: _LayoutConstants.bodyFontSize,
      fontWeight: _LayoutConstants.bodyNormalWeight,
      color: _ColorConstants.textPrimary,
    );
  }
}
