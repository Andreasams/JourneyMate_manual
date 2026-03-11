/// Design System Constants
class AppConstants {
  AppConstants._();

  // Application constants
  static const int kDefaultCityId = 17; // Copenhagen

  // Special neighbourhood filter rules
  static const int kFrederiksberg = 36;           // Main Frederiksberg
  static const int kFrederikbergC = 635;          // Frederiksberg C (hidden, bundled with 36)

  /// Hierarchical neighborhood relationships (parent → children)
  /// Only applies to city_id=17 (Copenhagen)
  static const Map<int, List<int>> kNeighborhoodHierarchy = {
    44: [41, 42, 34],  // Indre By → Kongens Nytorv, Nyhavn, Christianshavn
    48: [35, 43],      // Amager → Islands Brygge, Ørestad
    37: [30],          // Nordvest → Bispebjerg
    31: [40],          // Vanløse → Grøndal
  };

  /// Flattened set of all child neighborhood IDs for quick lookup
  static final Set<int> kNeighborhoodChildren =
      kNeighborhoodHierarchy.values.expand((list) => list).toSet();

  // Screen dimensions (reference - iPhone 14/15 standard)
  static const double screenWidth = 390.0;
  static const double screenHeight = 844.0;

  // Component heights
  static const double statusBarHeight = 54.0;
  static const double tabBarHeight = 80.0;
  static const double inputHeight = 50.0;
  static const double buttonHeight = 50.0;
  static const double searchBarHeight = 45.0; // Compact search bars (vs 50px form inputs)

  // Card dimensions
  static const double logoCircleSize = 50.0;
  static const double cardPadding = 14.0;

  // Placeholder images
  static const String kPlaceholderImageUrl =
      'https://tlqfuazpshfaozdvmcbh.supabase.co/storage/v1/object/public/profilepic_restaurants/placeholder.webp';

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
