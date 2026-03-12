import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'providers/locale_provider.dart';

/// Root application widget
///
/// **Phase 3 Optimization: ConsumerWidget for Instant Locale Changes**
/// - Watches `localeProvider` to rebuild app when language changes
/// - Enables instant visual feedback (locale changes before translations load)
/// - Pages see updated `Localizations.localeOf(context)` immediately
class JourneyMateApp extends ConsumerWidget {
  const JourneyMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Watch locale changes for instant app-wide rebuild
    final locale = ref.watch(localeProvider);

    // Apply Google Fonts to the theme
    final theme = appTheme().copyWith(
      textTheme: GoogleFonts.robotoTextTheme(appTheme().textTheme),
    );

    return MaterialApp.router(
      title: 'JourneyMate',
      theme: theme,
      locale: locale, // ✅ Set locale dynamically
      supportedLocales: const [
        // ── Active languages ──
        Locale('en'), // English
        Locale('da'), // Danish
        Locale('de'), // German
        Locale('fr'), // French
        Locale('it'), // Italian
        Locale('no'), // Norwegian
        Locale('sv'), // Swedish
        // ── Inactive languages (ready for activation) ──
        Locale('es'), // Spanish
        Locale('fi'), // Finnish
        Locale('ja'), // Japanese
        Locale('ko'), // Korean
        Locale('nl'), // Dutch
        Locale('pl'), // Polish
        Locale('uk'), // Ukrainian
        Locale('zh'), // Chinese
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      // ⚠️ Flutter 3.x: Use TextScaler.linear() not textScaleFactor
      builder: (context, child) {
        final scale = MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.0);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
          ),
          child: child!,
        );
      },
    );
  }
}
