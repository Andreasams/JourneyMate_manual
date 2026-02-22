import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/welcome/welcome_page.dart';
import '../pages/app_settings_initiate_flow/app_settings_initiate_flow_page.dart';
import '../pages/search_page.dart';
import '../pages/business_profile_page.dart';
import '../pages/menu_full_page.dart';

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
      builder: (context, state) => const SearchPage(),
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

    // Phase 7.5: Gallery Full Page
    GoRoute(
      path: '/business/:id/gallery',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return _placeholderPage(
          'Gallery',
          'Phase 7.5 - Business ID: $id',
        );
      },
    ),

    // Phase 7.6: Business Information
    GoRoute(
      path: '/business/:id/information',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return _placeholderPage(
          'Business Information',
          'Phase 7.6 - Business ID: $id',
        );
      },
    ),

    // Phase 7.7: Settings Main
    GoRoute(
      path: '/settings',
      builder: (context, state) => _placeholderPage(
        'Settings',
        'Phase 7.7 - Main settings page',
      ),
    ),

    // App Settings Initiate Flow (English onboarding wizard)
    GoRoute(
      path: '/set-language-currency',
      builder: (context, state) => const AppSettingsInitiateFlowPage(),
    ),

    // Phase 7.8: Localization
    GoRoute(
      path: '/settings/localization',
      builder: (context, state) => _placeholderPage(
        'Localization',
        'Phase 7.8 - Language & currency settings',
      ),
    ),

    // Phase 7.9: Location Sharing
    GoRoute(
      path: '/settings/location',
      builder: (context, state) => _placeholderPage(
        'Location Sharing',
        'Phase 7.9 - Location permissions',
      ),
    ),

    // Phase 7.10: Contact Us
    GoRoute(
      path: '/settings/contact',
      builder: (context, state) => _placeholderPage(
        'Contact Us',
        'Phase 7.10 - Support form',
      ),
    ),

    // Phase 7.11: Share Feedback
    GoRoute(
      path: '/settings/feedback',
      builder: (context, state) => _placeholderPage(
        'Share Feedback',
        'Phase 7.11 - Feedback form',
      ),
    ),

    // Phase 7.12: Missing Place
    GoRoute(
      path: '/settings/missing-place',
      builder: (context, state) => _placeholderPage(
        'Missing Place',
        'Phase 7.12 - Report missing restaurant',
      ),
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

/// Creates a placeholder page for Phase 4
Widget _placeholderPage(String title, String subtitle) {
  return Scaffold(
    appBar: AppBar(
      title: Text(title),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const Text(
              'This page will be implemented in Phase 7',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
