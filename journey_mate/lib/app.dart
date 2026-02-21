import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Root application widget
class JourneyMateApp extends StatelessWidget {
  const JourneyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Apply Google Fonts to the theme
    final theme = appTheme().copyWith(
      textTheme: GoogleFonts.robotoTextTheme(appTheme().textTheme),
    );

    return MaterialApp.router(
      title: 'JourneyMate',
      theme: theme,
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
