import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radius.dart';
import '../../services/translation_service.dart';
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';
import '../../widgets/shared/nav_bar_widget.dart';

/// Settings Main Page (Phase 7.7)
///
/// Navigation hub for all settings pages with 3 sections:
/// 1. My JourneyMate: Localization
/// 2. Reach out: Missing place, Share feedback, Contact us
/// 3. Resources: Terms of use, Privacy policy (external URLs)
///
/// Analytics: Tracks page_viewed with duration on dispose
class SettingsMainPage extends ConsumerStatefulWidget {
  const SettingsMainPage({super.key});

  @override
  ConsumerState<SettingsMainPage> createState() => _SettingsMainPageState();
}

class _SettingsMainPageState extends ConsumerState<SettingsMainPage> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageStartTime = DateTime.now();
    });
  }

  @override
  void dispose() {
    // Track page view analytics with duration
    if (_pageStartTime != null) {
      final durationSeconds = DateTime.now().difference(_pageStartTime!).inSeconds;
      final analytics = AnalyticsService.instance;
      // Fire-and-forget analytics call
      ApiService.instance.postAnalytics(
        eventType: 'page_viewed',
        deviceId: analytics.deviceId ?? '',
        sessionId: analytics.currentSessionId ?? '',
        userId: analytics.userId ?? '',
        timestamp: DateTime.now().toIso8601String(),
        eventData: {
          'pageName': 'settingsAndAccount',
          'durationSeconds': durationSeconds,
        },
      ).catchError((_) => ApiCallResponse.failure('Analytics failed'));
    }
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 80.0), // Bottom padding for NavBar
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title
                    Text(
                      td(ref, 'cpiiq0im'), // "Settings & account"
                      style: AppTypography.pageTitle.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),

                    // Section 1: My JourneyMate
                    _buildSection(
                      context,
                      td(ref, '3tlbn2an'), // "My JourneyMate"
                      [
                        _buildSettingRow(
                          context,
                          icon: Icons.location_on,
                          label: td(ref, '290fbi5g'), // "Localization"
                          onTap: () {
                            context.push('/settings/localization');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // Section 2: Reach out
                    _buildSection(
                      context,
                      td(ref, 'pb7qrt34'), // "Reach out"
                      [
                        _buildSettingRow(
                          context,
                          icon: Icons.add_circle,
                          label: td(ref, '297ogtn9'), // "Are we missing a place?"
                          onTap: () {
                            context.push('/settings/missing-place');
                          },
                          showDividerAbove: false,
                        ),
                        _buildSettingRow(
                          context,
                          icon: Icons.feedback_rounded,
                          label: td(ref, 'uz83tnpj'), // "Share feedback"
                          onTap: () {
                            context.push('/settings/feedback');
                          },
                        ),
                        _buildSettingRow(
                          context,
                          icon: Icons.email_rounded,
                          label: td(ref, 'dme8eg1t'), // "Contact us"
                          onTap: () {
                            context.push('/settings/contact');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxxl),

                    // Section 3: Resources
                    _buildSection(
                      context,
                      td(ref, 'd952v5y4'), // "Resources"
                      [
                        _buildSettingRow(
                          context,
                          icon: Icons.checklist_rtl_rounded,
                          label: td(ref, '2v106a6z'), // "Terms of use"
                          onTap: () {
                            _launchURL(
                                'https://docs.google.com/document/d/1CAjvjWt73BgvBZSMUKiIyPbz2sZ5RiqCMGuD0R6KVpc/edit?usp=sharing');
                          },
                          showDividerAbove: false,
                        ),
                        _buildSettingRow(
                          context,
                          icon: Icons.privacy_tip,
                          label: td(ref, 'gtmo283r'), // "Privacy policy"
                          onTap: () {
                            _launchURL(
                                'https://docs.google.com/document/d/1nO_TaK-HB8-CV9FM8zs3uu0mYgCT4taO0nBSv2iHw3A/edit?usp=sharing');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // NavBar at bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: const NavBarWidget(
                pageIsSearchResults: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section with header and setting rows
  Widget _buildSection(
    BuildContext context,
    String header,
    List<Widget> rows,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Text(
          header,
          style: AppTypography.bodyMedium.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Setting rows with dividers
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          child: Column(
            children: rows,
          ),
        ),
      ],
    );
  }

  /// Builds a setting row with icon, label, and chevron
  Widget _buildSettingRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool showDividerAbove = true,
  }) {
    return Column(
      children: [
        if (showDividerAbove)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.divider,
          ),
        InkWell(
          onTap: onTap,
          splashColor: Colors.transparent,
          highlightColor: AppColors.bgInput.withAlpha((0.5 * 255).round()),
          child: Container(
            height: 48.0,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon + Label
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: AppColors.textSecondary,
                      size: 18.0,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      label,
                      style: AppTypography.bodyRegular.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                // Chevron
                Icon(
                  Icons.keyboard_arrow_right_outlined,
                  color: AppColors.textSecondary,
                  size: 22.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
