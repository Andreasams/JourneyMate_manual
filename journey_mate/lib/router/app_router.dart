import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/welcome/welcome_page.dart';
import '../pages/app_settings_initiate_flow/app_settings_initiate_flow_page.dart';
import '../pages/search/search_page.dart';
import '../pages/business_profile/business_profile_page.dart';
import '../pages/menu_full_page/menu_full_page.dart';
import '../pages/gallery_full_page/gallery_full_page.dart';
import '../pages/business_information/business_information_page.dart';
import '../pages/settings/settings_main_page.dart';
import '../pages/settings/localization_page.dart';
import '../pages/settings/contact_us_page.dart';
import '../pages/settings/share_feedback_page.dart';
import '../pages/settings/missing_place_page.dart';

/// Application router with all 11 routes
/// Uses go_router 17.x for navigation
final appRouter = GoRouter(
  initialLocation: '/welcome',
  routes: [
    // Root redirect to welcome
    GoRoute(
      path: '/',
      redirect: (context, state) => '/welcome',
    ),

    // Phase 7.1: Welcome / Onboarding
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),

    // Phase 7.3.2: Search (COMPLETE ✅)
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const SearchPage(),
      ),
    ),

    // Phase 7.3: Business Profile (COMPLETE ✅)
    GoRoute(
      path: '/business/:id',
      builder: (context, state) {
        final businessId = state.pathParameters['id']!;
        return BusinessProfilePage(businessId: businessId);
      },
    ),

    // Phase 7.4: Menu Full Page (COMPLETE ✅)
    GoRoute(
      path: '/business/:id/menu',
      builder: (context, state) {
        final businessId = state.pathParameters['id']!;
        return MenuFullPage(businessId: businessId);
      },
    ),

    // Phase 7.5: Gallery Full Page (COMPLETE ✅)
    GoRoute(
      path: '/business/:id/gallery',
      builder: (context, state) {
        final businessId = state.pathParameters['id']!;
        return GalleryFullPage(businessId: businessId);
      },
    ),

    // Phase 7.6: Business Information (COMPLETE ✅)
    GoRoute(
      path: '/business/:id/information',
      builder: (context, state) {
        final businessId = state.pathParameters['id']!;
        return BusinessInformationPage(businessId: businessId);
      },
    ),

    // Phase 7.7: Settings Main (COMPLETE ✅)
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: const SettingsMainPage(),
      ),
    ),

    // App Settings Initiate Flow (English onboarding wizard)
    GoRoute(
      path: '/set-language-currency',
      builder: (context, state) => const AppSettingsInitiateFlowPage(),
    ),

    // Phase 7.8: Localization (includes location sharing) (COMPLETE ✅)
    GoRoute(
      path: '/settings/localization',
      builder: (context, state) => const LocalizationPage(),
    ),

    // Phase 7.10: Contact Us (COMPLETE ✅)
    GoRoute(
      path: '/settings/contact',
      builder: (context, state) => const ContactUsPage(),
    ),

    // Phase 7.11: Share Feedback (COMPLETE ✅)
    GoRoute(
      path: '/settings/feedback',
      builder: (context, state) => const ShareFeedbackPage(),
    ),

    // Phase 7.12: Missing Place (COMPLETE ✅)
    GoRoute(
      path: '/settings/missing-place',
      builder: (context, state) => const MissingPlacePage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '404',
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    ),
  ),
);
