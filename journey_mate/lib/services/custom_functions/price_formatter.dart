import 'dart:convert';
import 'package:intl/intl.dart';

/// Returns the formatting rules (symbol, placement, decimals) for a given currency code.
///
/// This function acts as the central source of truth for all currency display rules.
///
/// Args:
///   currencyCode: The ISO 4217 currency code (e.g., 'DKK', 'EUR').
///
/// Returns:
///   A JSON string containing 'symbol' (String), 'isPrefix' (bool), and 'decimals' (int).
String? getCurrencyFormattingRules(String currencyCode) {
  const Map<String, Map<String, dynamic>> currencyFormattingRules = {
    'CNY': {'symbol': '¥', 'isPrefix': true, 'decimals': 0},
    'DKK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
    'EUR': {'symbol': '€', 'isPrefix': true, 'decimals': 2},
    'GBP': {'symbol': '£', 'isPrefix': true, 'decimals': 1},
    'JPY': {'symbol': '¥', 'isPrefix': false, 'decimals': 0},
    'KRW': {'symbol': '₩', 'isPrefix': false, 'decimals': 0},
    'NOK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
    'PLN': {'symbol': 'zł', 'isPrefix': false, 'decimals': 0},
    'SEK': {'symbol': 'kr.', 'isPrefix': false, 'decimals': 0},
    'UAH': {'symbol': '₴', 'isPrefix': false, 'decimals': 0},
    'USD': {'symbol': '\$', 'isPrefix': true, 'decimals': 2},
  };

  const Map<String, dynamic> defaultCurrencyRule = {
    'symbol': 'kr.',
    'isPrefix': false,
    'decimals': 0,
  };

  // Normalize the input code to uppercase
  final code = currencyCode.toUpperCase();

  // Get the rule or use default
  final rule = currencyFormattingRules[code] ?? defaultCurrencyRule;

  // Return as JSON string for FlutterFlow compatibility
  return jsonEncode(rule);
}

/// Converts and formats a single price with currency conversion and localized formatting.
///
/// Used to display prices in the user's preferred currency.
/// Handles currency conversion using exchange rates and formats according to currency-specific rules.
///
/// Args:
///  basePrice: Price in original currency
///  originalCurrencyCode: ISO 4217 currency code of the original price
///  exchangeRate: Exchange rate from original to target currency
///  targetCurrencyCode: ISO 4217 currency code for output
///
/// Returns:
///  Formatted price string with appropriate currency symbol, decimals, and placement
String? convertAndFormatPrice(
  double basePrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
) {
  /// Gets format pattern based on decimal places
  String getFormatPattern(int decimals) {
    switch (decimals) {
      case 0:
        return '###,###';
      case 1:
        return '###,##0.0';
      case 2:
        return '###,##0.00';
      default:
        return '###,###';
    }
  }

  // Validate inputs
  if (basePrice < 0 || exchangeRate <= 0) return null;

  // Normalize currency codes
  final targetCode = targetCurrencyCode.toUpperCase();
  final originalCode = originalCurrencyCode.toUpperCase();

  // Convert price (skip conversion if same currency)
  final convertedPrice =
      originalCode == targetCode ? basePrice : basePrice * exchangeRate;

  // Get currency formatting rules from central function
  final rulesJson = getCurrencyFormattingRules(targetCode);

  if (rulesJson == null) return null;

  // Parse JSON rules
  final Map<String, dynamic> rules;
  try {
    rules = jsonDecode(rulesJson);
  } catch (e) {
    return null; // Failed to parse rules
  }

  final symbol = rules['symbol'] as String;
  final isPrefix = rules['isPrefix'] as bool;
  final decimals = rules['decimals'] as int;

  // Format price based on decimal places
  final pattern = getFormatPattern(decimals);
  final formattedPrice = decimals == 0
      ? NumberFormat(pattern).format(convertedPrice.round())
      : NumberFormat(pattern).format(convertedPrice);

  // Build output string based on symbol placement
  return isPrefix ? '$symbol$formattedPrice' : '$formattedPrice $symbol';
}

/// Converts and formats a price range with currency conversion.
///
/// Used to display price ranges (e.g., "100-200 kr.") in the user's preferred currency.
///
/// Args:
///   minPrice: Minimum price in original currency
///   maxPrice: Maximum price in original currency
///   originalCurrencyCode: ISO 4217 currency code of the original price
///   exchangeRate: Exchange rate from original to target currency
///   targetCurrencyCode: ISO 4217 currency code for output
///
/// Returns:
///   Formatted price range string (e.g., "100-200 kr.")
String? convertAndFormatPriceRange(
  double minPrice,
  double maxPrice,
  String originalCurrencyCode,
  double exchangeRate,
  String targetCurrencyCode,
) {
  final formattedMin = convertAndFormatPrice(
    minPrice,
    originalCurrencyCode,
    exchangeRate,
    targetCurrencyCode,
  );

  final formattedMax = convertAndFormatPrice(
    maxPrice,
    originalCurrencyCode,
    exchangeRate,
    targetCurrencyCode,
  );

  if (formattedMin == null || formattedMax == null) return null;

  // Extract numeric parts (remove symbols and spaces)
  final minNumeric = formattedMin.replaceAll(RegExp(r'[^\d,]'), '');
  final maxNumeric = formattedMax.replaceAll(RegExp(r'[^\d,]'), '');

  // Extract symbol from either formatted price
  final symbol = formattedMin.contains(RegExp(r'[^\d\s,.-]'))
      ? formattedMin.replaceAll(RegExp(r'[\d\s,.-]'), '').trim()
      : '';

  // Check if symbol is prefix or suffix
  final isPrefix = formattedMin.startsWith(symbol);

  // Build range string
  if (isPrefix) {
    return '$symbol$minNumeric-$maxNumeric';
  } else {
    return '$minNumeric-$maxNumeric $symbol';
  }
}
