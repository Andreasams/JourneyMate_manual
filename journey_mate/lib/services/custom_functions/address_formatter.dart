/// Formats street addresses with neighbourhood information based on street name length.
///
/// Intelligently handles Copenhagen neighbourhood names by using abbreviations or omitting
/// neighbourhood information when street names are too long, preventing text overflow.
///
/// Args:
///   neighbourhood: Full neighbourhood/district name
///   streetName: Street name with house number (e.g., "Vesterbrogade 23")
///
/// Returns:
///   Formatted address string with appropriate neighbourhood display
String streetAndNeighbourhoodLength(
  String neighbourhood,
  String streetName,
) {
  // Configuration: Copenhagen neighbourhoods with postal code abbreviations
  const neighbourhoodAbbreviations = {
    'Carlsberg Byen': 'Kbh V',
    'Christianshavn': 'Kbh K',
    'Grøndal': 'Kbh N',
    'Indre by': 'Kbh K',
    'Islands brygge': 'Kbh S',
    'Kongens Nytorv': 'Kbh K',
    'Nordhavn': 'Kbh Ø',
    'Nordvest': 'Kbh N',
    'Nyhavn': 'Kbh K',
    'Nørrebro': 'Kbh N',
    'Sydhavnen': 'Kbh S',
    'Vesterbro': 'Kbh V',
    'Østerbro': 'Kbh Ø',
  };

  // Configuration: Non-Copenhagen neighbourhoods (no abbreviations available)
  const neighbourhoodsWithoutAbbreviations = {
    'Amager',
    'Bispebjerg',
    'Brønshøj-Husum',
    'Frederiksberg',
    'Valby',
    'Vanløse',
    'Ørestad',
  };

  // Length thresholds for formatting decisions
  const lengthForAbbreviation = 20; // Use abbreviation if street length >= 20
  const lengthForOmission = 27; // Omit neighbourhood if street length >= 27

  final streetLength = streetName.length;

  // Check if neighbourhood has an abbreviation (Copenhagen areas)
  if (neighbourhoodAbbreviations.containsKey(neighbourhood)) {
    final abbreviation = neighbourhoodAbbreviations[neighbourhood]!;

    // Long street: omit neighbourhood entirely
    if (streetLength >= lengthForOmission) {
      return streetName;
    }

    // Medium street: use abbreviation
    if (streetLength >= lengthForAbbreviation) {
      return '$streetName, $abbreviation';
    }

    // Short street: show full neighbourhood
    return '$streetName, $neighbourhood';
  }

  // Check if neighbourhood is in non-Copenhagen set (no abbreviation available)
  if (neighbourhoodsWithoutAbbreviations.contains(neighbourhood)) {
    // Long street: omit neighbourhood
    if (streetLength >= lengthForAbbreviation) {
      return streetName;
    }

    // Short street: show full neighbourhood
    return '$streetName, $neighbourhood';
  }

  // Unknown neighbourhood: always show full name (assume it's important context)
  return '$streetName, $neighbourhood';
}
