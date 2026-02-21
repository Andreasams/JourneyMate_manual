/// Design System Constants
class AppConstants {
  AppConstants._();

  // Application constants
  static const int kDefaultCityId = 17; // Copenhagen

  // Screen dimensions (reference - iPhone 14/15 standard)
  static const double screenWidth = 390.0;
  static const double screenHeight = 844.0;

  // Component heights
  static const double statusBarHeight = 54.0;
  static const double tabBarHeight = 80.0;
  static const double inputHeight = 50.0;
  static const double buttonHeight = 50.0;

  // Card dimensions
  static const double logoCircleSize = 50.0;
  static const double cardPadding = 14.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
