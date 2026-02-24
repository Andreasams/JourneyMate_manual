# streetAndNeighbourhoodLength() Function Documentation

**Version:** 1.0
**Location:** `lib/flutter_flow/custom_functions.dart` (lines 2016-2091)
**Category:** Address Formatting / Display Logic
**Status:** Production

---

## Purpose

The `streetAndNeighbourhoodLength()` function formats street addresses with neighbourhood information based on street name length to optimize display space in UI components. It intelligently handles Copenhagen neighbourhood names by using abbreviations or omitting neighbourhood information when street names are too long, preventing text overflow and ensuring addresses remain readable within constrained UI spaces.

**Key Design Principle:** Prioritize street name visibility while providing neighbourhood context when space permits. Copenhagen-specific neighbourhoods get special treatment with postal code abbreviations (e.g., "Kbh K", "Kbh V") while other neighbourhoods are shown in full or omitted entirely.

---

## Function Signature

```dart
String streetAndNeighbourhoodLength(
  String neighbourhood,
  String streetName,
)
```

---

## Parameters

### `neighbourhood` (String, required)
- **Description:** Full neighbourhood/district name
- **Format:** Exact string match required for abbreviation lookup
- **Examples:**
  - Copenhagen: `'Indre by'`, `'Nørrebro'`, `'Vesterbro'`, `'Islands brygge'`
  - Non-Copenhagen: `'Frederiksberg'`, `'Amager'`, `'Valby'`
- **Source:** Business location data from Supabase `businesses` table
- **Case sensitivity:** Yes (must match exact casing in configuration)
- **Validation:** No validation; unknown neighbourhoods default to full display

### `streetName` (String, required)
- **Description:** Street name with house number (e.g., "Vesterbrogade 23")
- **Format:** Complete street address without neighbourhood
- **Examples:**
  - `'Vesterbrogade 23'`
  - `'Nørrebrogade 52A'`
  - `'H.C. Andersens Boulevard 1'`
- **Source:** Business location data from Supabase `businesses` table
- **Validation:** No validation; empty strings handled gracefully
- **Character count:** Determines formatting logic

---

## Return Value

**Type:** `String`

**Format Variations:**

1. **Full neighbourhood display:**
   - `"Vesterbrogade 23, Vesterbro"`
   - Used when: `streetName.length < 20`

2. **Abbreviated neighbourhood display:**
   - `"Vesterbrogade 23, Kbh V"`
   - Used when: `streetName.length >= 20 AND < 27` (Copenhagen only)

3. **Street name only:**
   - `"Vesterbrogade 23"`
   - Used when: `streetName.length >= 27` (Copenhagen with abbreviation)
   - Used when: `streetName.length >= 20` (non-Copenhagen without abbreviation)

4. **Unknown neighbourhood (always full):**
   - `"Vesterbrogade 23, UnknownNeighbourhood"`
   - Used when: Neighbourhood not in either configuration set

**Edge Cases:**
- Empty `streetName`: Returns `, neighbourhood` or empty string
- Empty `neighbourhood`: Returns street name only
- Both empty: Returns empty string
- Unknown neighbourhood: Always shows full (assumes important context)

---

## Dependencies

### Internal Dependencies
None. Pure string manipulation function with no external dependencies.

### External Dependencies
None. Self-contained logic with embedded configuration.

### FlutterFlow Integration
- **Usage Context:** Called from business profile pages and search result cards
- **Parameter Binding:** Passed directly from business data fields
- **No FFAppState Usage:** Function is stateless with no global state access

---

## FFAppState Usage

**This function does NOT use FFAppState.**

All configuration is embedded within the function as constants. This design choice ensures:
1. No dependency on app state initialization
2. Predictable behavior across all contexts
3. No performance overhead from state lookups
4. Easier testing with no mocking required

---

## Configuration Data

### Copenhagen Neighbourhoods with Abbreviations

```dart
const neighbourhoodAbbreviations = {
  'Carlsberg Byen': 'Kbh V',    // Copenhagen V (Vesterbro postal district)
  'Christianshavn': 'Kbh K',    // Copenhagen K (City center)
  'Grøndal': 'Kbh N',            // Copenhagen N (Nordvest postal district)
  'Indre by': 'Kbh K',          // Copenhagen K (Inner city)
  'Islands brygge': 'Kbh S',    // Copenhagen S (South district)
  'Kongens Nytorv': 'Kbh K',    // Copenhagen K (City center)
  'Nordhavn': 'Kbh Ø',           // Copenhagen Ø (East district)
  'Nordvest': 'Kbh N',           // Copenhagen N (Northwest)
  'Nyhavn': 'Kbh K',             // Copenhagen K (City center)
  'Nørrebro': 'Kbh N',           // Copenhagen N (North district)
  'Sydhavnen': 'Kbh S',          // Copenhagen S (South harbor)
  'Vesterbro': 'Kbh V',          // Copenhagen V (West district)
  'Østerbro': 'Kbh Ø',           // Copenhagen Ø (East district)
};
```

**Design Rationale:**
- Uses official Copenhagen postal district codes (K, N, S, V, Ø)
- "Kbh" abbreviation for "København" (Copenhagen)
- Maps multiple neighbourhoods to same postal districts
- Provides meaningful geographic context in minimal space

### Non-Copenhagen Neighbourhoods (No Abbreviations)

```dart
const neighbourhoodsWithoutAbbreviations = {
  'Amager',              // Island district, south-east Copenhagen
  'Bispebjerg',          // North-west Copenhagen area
  'Brønshøj-Husum',      // North-west Copenhagen area
  'Frederiksberg',       // Independent municipality within Copenhagen
  'Valby',               // South-west Copenhagen district
  'Vanløse',             // West Copenhagen district
  'Ørestad',             // Modern development area, south Amager
};
```

**Design Rationale:**
- No postal code abbreviations available for these areas
- Names are relatively short (9-15 characters)
- Omitted entirely if street name too long (cleaner than truncation)
- Unknown neighbourhoods treated similarly (better to show full name or nothing)

### Length Thresholds

```dart
const lengthForAbbreviation = 20;  // Use abbreviation if street length >= 20
const lengthForOmission = 27;      // Omit neighbourhood if street length >= 27
```

**Design Rationale:**
- **20 characters:** Tested threshold where full neighbourhood names start causing UI overflow
- **27 characters:** Absolute maximum where even abbreviations risk overflow
- **7-character gap:** Allows abbreviated forms to provide value between thresholds
- Based on typical UI constraints in business cards and profile headers

---

## Implementation Logic

### Decision Tree

```
INPUT: neighbourhood, streetName

1. streetLength = streetName.length

2. Is neighbourhood in neighbourhoodAbbreviations?
   YES:
     a. streetLength >= 27?
        → Return streetName only
     b. streetLength >= 20?
        → Return "$streetName, ${abbreviated}"
     c. streetLength < 20?
        → Return "$streetName, $neighbourhood"

   NO:
     3. Is neighbourhood in neighbourhoodsWithoutAbbreviations?
        YES:
          a. streetLength >= 20?
             → Return streetName only
          b. streetLength < 20?
             → Return "$streetName, $neighbourhood"

        NO:
          4. Unknown neighbourhood
             → Always return "$streetName, $neighbourhood"
```

### Formatting Rules

**Rule 1: Copenhagen neighbourhoods (has abbreviation)**
- Short street (<20): Show full neighbourhood
- Medium street (20-26): Show abbreviated neighbourhood
- Long street (≥27): Show street only

**Rule 2: Non-Copenhagen neighbourhoods (no abbreviation)**
- Short street (<20): Show full neighbourhood
- Long street (≥20): Show street only

**Rule 3: Unknown neighbourhoods**
- Always show full neighbourhood (assume it's important context)

**Rule 4: Empty inputs**
- Graceful degradation: show whatever data is available

---

## Usage Examples

### Example 1: Short Street with Copenhagen Neighbourhood

```dart
final result = streetAndNeighbourhoodLength(
  'Vesterbro',
  'Istedgade 12'  // 12 characters
);

// Returns: "Istedgade 12, Vesterbro"
// Reason: Street < 20 chars, full neighbourhood shown
```

### Example 2: Medium Street with Copenhagen Neighbourhood

```dart
final result = streetAndNeighbourhoodLength(
  'Nørrebro',
  'Nørrebrogade 52A, 2. tv'  // 23 characters
);

// Returns: "Nørrebrogade 52A, 2. tv, Kbh N"
// Reason: 20 <= street < 27, abbreviation used
```

### Example 3: Long Street with Copenhagen Neighbourhood

```dart
final result = streetAndNeighbourhoodLength(
  'Islands brygge',
  'Islands Brygge 43, 3. sal, th'  // 32 characters
);

// Returns: "Islands Brygge 43, 3. sal, th"
// Reason: Street >= 27 chars, neighbourhood omitted entirely
```

### Example 4: Non-Copenhagen Neighbourhood (Short)

```dart
final result = streetAndNeighbourhoodLength(
  'Frederiksberg',
  'Smallegade 10'  // 13 characters
);

// Returns: "Smallegade 10, Frederiksberg"
// Reason: Street < 20 chars, full neighbourhood shown
```

### Example 5: Non-Copenhagen Neighbourhood (Long)

```dart
final result = streetAndNeighbourhoodLength(
  'Frederiksberg',
  'Falkoner Allé 21, 4. mf'  // 23 characters
);

// Returns: "Falkoner Allé 21, 4. mf"
// Reason: Street >= 20 chars, neighbourhood omitted (no abbreviation available)
```

### Example 6: Unknown Neighbourhood

```dart
final result = streetAndNeighbourhoodLength(
  'Tårnby',  // Not in either configuration set
  'Amager Landevej 92'  // 19 characters
);

// Returns: "Amager Landevej 92, Tårnby"
// Reason: Unknown neighbourhoods always shown in full
```

### Example 7: Edge Case - Empty Street Name

```dart
final result = streetAndNeighbourhoodLength(
  'Vesterbro',
  ''
);

// Returns: ", Vesterbro"
// Reason: Graceful degradation with available data
```

### Example 8: Edge Case - Empty Neighbourhood

```dart
final result = streetAndNeighbourhoodLength(
  '',
  'Vesterbrogade 23'
);

// Returns: "Vesterbrogade 23"
// Reason: Only street shown when neighbourhood missing
```

---

## Edge Cases

### Case 1: Empty String Parameters

**Input:**
```dart
streetAndNeighbourhoodLength('', '')
```

**Behavior:** Returns empty string
**Rationale:** No data available to format
**Recommendation:** Check for empty business address data before calling

### Case 2: Null-Like Empty Strings

**Input:**
```dart
streetAndNeighbourhoodLength('Vesterbro', '')
```

**Behavior:** Returns `", Vesterbro"`
**Rationale:** Graceful degradation preserves available data
**Recommendation:** Validate street name exists before calling

### Case 3: Very Long Street Names (>40 characters)

**Input:**
```dart
streetAndNeighbourhoodLength(
  'Indre by',
  'Hans Christian Andersens Boulevard 27, 3. sal, lejlighed 12'  // 60 chars
)
```

**Behavior:** Returns street only (no neighbourhood)
**Rationale:** At 60 chars, any additional text would overflow
**Recommendation:** UI should handle text wrapping or truncation

### Case 4: Neighbourhood Name Variations

**Input:**
```dart
streetAndNeighbourhoodLength('VESTERBRO', 'Istedgade 12')  // Wrong casing
```

**Behavior:** Treated as unknown neighbourhood (shows full)
**Rationale:** Case-sensitive lookup requires exact match
**Recommendation:** Normalize neighbourhood names in database to match configuration

### Case 5: Boundary Length Values

**Input:**
```dart
streetAndNeighbourhoodLength('Vesterbro', '12345678901234567890')  // Exactly 20 chars
```

**Behavior:** Returns abbreviated form (threshold uses `>=`)
**Rationale:** Inclusive threshold at 20 characters
**Note:** Test boundary cases during UI development

### Case 6: Special Characters in Street Names

**Input:**
```dart
streetAndNeighbourhoodLength('Østerbro', 'H.C. Ørstedsvej 12, 2.')  // Danish chars
```

**Behavior:** Counts all characters including dots and spaces
**Rationale:** `.length` counts all characters in string
**Note:** Special characters don't affect logic, only count

### Case 7: Unknown But Similar Neighbourhood Names

**Input:**
```dart
streetAndNeighbourhoodLength('Nørrebro Nord', 'Tagensvej 86')  // Similar but not exact
```

**Behavior:** Treated as unknown (shows full)
**Rationale:** No partial matching; exact string match required
**Recommendation:** Add variations to configuration if commonly encountered

---

## Design Context

### Why This Function Exists

**Problem:** Business addresses in Copenhagen contain both street names and neighbourhood names. When displayed in UI components with constrained width (cards, headers, lists), combining both often causes text overflow, truncation, or wrapping that degrades readability.

**Solution:** Dynamically adjust the level of location detail based on street name length:
1. **Short streets:** Include full neighbourhood (provides maximum context)
2. **Medium streets:** Use postal code abbreviation (balances context and space)
3. **Long streets:** Omit neighbourhood entirely (prioritizes address visibility)

**Design Decision:** Street name is MORE important than neighbourhood because:
- Users need the exact address to navigate
- Neighbourhood is supplementary context (nice-to-have)
- Map integration can show neighbourhood visually
- Postal codes (Kbh K, Kbh V, etc.) provide sufficient area context

### Copenhagen-Specific Logic

**Why abbreviations only for Copenhagen:**
1. Copenhagen has well-established postal district codes (K, V, N, S, Ø)
2. "Kbh" abbreviation is universally recognized in Denmark
3. Other municipalities lack standardized short forms
4. Better to omit than invent abbreviations users won't recognize

**Postal District Mapping:**
- **K (Indre by):** City center, tourist areas, business district
- **V (Vest):** Vesterbro, Carlsberg, western areas
- **N (Nord):** Nørrebro, Nordvest, northern districts
- **S (Syd):** Islands Brygge, Amager, southern areas
- **Ø (Øst):** Østerbro, Nordhavn, eastern areas

### Alternative Approaches Considered

**Rejected: Fixed truncation (e.g., "Vesterbr...")**
- Pros: Simple implementation
- Cons: Looks unprofessional, loses semantic meaning, hard to read
- Reason rejected: User experience unacceptable

**Rejected: Two-line display**
- Pros: Shows all information
- Cons: Increases card height, breaks visual rhythm, inconsistent spacing
- Reason rejected: UI consistency more important than complete data

**Rejected: Tooltip/hover for full address**
- Pros: Preserves all information
- Cons: Mobile app (no hover), extra interaction required, hidden information
- Reason rejected: Not practical for mobile-first design

**Accepted: Dynamic abbreviation/omission**
- Pros: Clean display, prioritizes critical info, leverages postal codes
- Cons: More complex logic, requires configuration maintenance
- Reason accepted: Best balance of readability and information density

---

## Testing Checklist

### Unit Tests

- [ ] **Test 1:** Short street (<20 chars) with Copenhagen neighbourhood returns full
- [ ] **Test 2:** Medium street (20-26 chars) with Copenhagen neighbourhood returns abbreviated
- [ ] **Test 3:** Long street (≥27 chars) with Copenhagen neighbourhood returns street only
- [ ] **Test 4:** Short street with non-Copenhagen neighbourhood returns full
- [ ] **Test 5:** Long street (≥20 chars) with non-Copenhagen neighbourhood returns street only
- [ ] **Test 6:** Any length street with unknown neighbourhood returns full
- [ ] **Test 7:** Empty street name returns graceful degradation
- [ ] **Test 8:** Empty neighbourhood returns street only
- [ ] **Test 9:** Both empty returns empty string
- [ ] **Test 10:** Boundary value (exactly 20 chars) triggers abbreviation
- [ ] **Test 11:** Boundary value (exactly 27 chars) triggers omission
- [ ] **Test 12:** Special characters counted correctly in length
- [ ] **Test 13:** Case sensitivity in neighbourhood matching
- [ ] **Test 14:** All 13 Copenhagen neighbourhoods map to correct abbreviations
- [ ] **Test 15:** All 7 non-Copenhagen neighbourhoods handled correctly

### Integration Tests

- [ ] **Test 16:** Function called from business profile page displays correctly
- [ ] **Test 17:** Function called from search results card displays correctly
- [ ] **Test 18:** Business data with missing neighbourhood field handled gracefully
- [ ] **Test 19:** Business data with null neighbourhood field handled gracefully
- [ ] **Test 20:** UI text wrapping works with all return formats
- [ ] **Test 21:** Copenhagen businesses across all postal districts display correctly
- [ ] **Test 22:** Frederiksberg businesses (independent municipality) display correctly
- [ ] **Test 23:** Businesses outside Copenhagen area display correctly

### Visual Regression Tests

- [ ] **Test 24:** Business card width accommodates longest expected output
- [ ] **Test 25:** No text overflow in any test case
- [ ] **Test 26:** Consistent vertical alignment with/without neighbourhood
- [ ] **Test 27:** Comma spacing visually correct
- [ ] **Test 28:** Danish characters (æ, ø, å) display correctly
- [ ] **Test 29:** Abbreviations visually distinguishable from full names

### Performance Tests

- [ ] **Test 30:** Function executes in <1ms (pure string operations)
- [ ] **Test 31:** No memory allocation overhead (constant lookups)
- [ ] **Test 32:** ListView with 100+ calls maintains 60fps scroll

---

## Migration Notes

### From FlutterFlow to Pure Flutter

**Original Implementation:**
- Function exists in `custom_functions.dart` in FlutterFlow project
- Already pure Dart code (no FlutterFlow-specific dependencies)
- Used as Custom Function in FlutterFlow expression builder

**Migration Steps:**

1. **Copy function exactly as-is:**
   ```dart
   // No modifications needed to function body
   // Configuration constants remain unchanged
   // No FFAppState dependencies to replace
   ```

2. **Create dedicated utility file:**
   ```dart
   // lib/utils/address_formatting.dart

   /// Formats street address with neighbourhood based on length constraints
   String streetAndNeighbourhoodLength(
     String neighbourhood,
     String streetName,
   ) {
     // Paste function body here unchanged
   }
   ```

3. **Update import statements in widgets:**
   ```dart
   // Old (FlutterFlow)
   import '/flutter_flow/custom_functions.dart';

   // New (Pure Flutter)
   import 'package:journeymate/utils/address_formatting.dart';
   ```

4. **Usage in widgets remains identical:**
   ```dart
   // Before and after migration (no change)
   Text(
     streetAndNeighbourhoodLength(
       business.neighbourhood,
       business.streetName,
     ),
   )
   ```

**No Breaking Changes:**
- Function signature unchanged
- Return format unchanged
- Configuration data unchanged
- No state dependencies to refactor

**Testing Approach:**
1. Run existing FlutterFlow tests before migration
2. Copy function to pure Flutter project
3. Run identical tests in pure Flutter
4. Verify outputs match exactly
5. Visual regression testing on UI components

**Recommended File Structure:**
```
lib/
  utils/
    address_formatting.dart         ← Place function here
  widgets/
    business_card.dart              ← Uses function
    business_profile_header.dart    ← Uses function
  pages/
    search_results_page.dart        ← Uses function via widgets
```

**Import Pattern:**
```dart
// Single utility file approach
import 'package:journeymate/utils/address_formatting.dart';

// Alternative: Create barrel export if many address utilities
// lib/utils/utils.dart
export 'address_formatting.dart';
export 'distance_formatting.dart';
export 'price_formatting.dart';
```

### Known Issues from FlutterFlow

**Issue 1: Neighbourhood Data Inconsistency**
- **Problem:** Some businesses in database have outdated/incorrect neighbourhood names
- **Impact:** Unknown neighbourhoods always show full name (might not match abbreviation set)
- **Solution:** Database cleanup script to normalize neighbourhood names
- **Workaround:** Add common variations to configuration sets

**Issue 2: Case Sensitivity**
- **Problem:** Configuration uses exact case matching
- **Impact:** "Nørrebro" matches but "NØRREBRO" or "nørrebro" don't
- **Solution:** Normalize case in database or add `.toLowerCase()` comparison
- **Workaround:** Document required casing in database schema

**Issue 3: Future Neighbourhood Additions**
- **Problem:** New Copenhagen neighbourhoods may emerge (e.g., Nordhavn expansion)
- **Impact:** New areas treated as unknown until configuration updated
- **Solution:** Add neighbourhoods to configuration when discovered
- **Monitoring:** Check analytics for unknown neighbourhood occurrences

### Configuration Maintenance

**When to Update Configuration:**

1. **New Copenhagen neighbourhoods:**
   - Add to `neighbourhoodAbbreviations` map
   - Determine correct postal district (K, V, N, S, or Ø)
   - Test with real business addresses from that area

2. **Municipality changes:**
   - Monitor for administrative boundary changes
   - Update mappings if postal districts reorganized
   - Extremely rare but should be on maintenance radar

3. **Threshold adjustments:**
   - Monitor UI overflow issues in production
   - Gather data on actual street name lengths
   - Adjust `lengthForAbbreviation` or `lengthForOmission` if needed
   - Requires A/B testing before changing (affects all addresses)

**Configuration Documentation:**
- Keep this document updated when configuration changes
- Document reason for each addition/change
- Note date and version when configuration modified
- Link to relevant UI/UX decisions

### Testing After Configuration Changes

When adding new neighbourhoods or changing thresholds:

1. **Unit test new neighbourhood:**
   ```dart
   test('New neighbourhood displays correctly', () {
     final short = streetAndNeighbourhoodLength('NewArea', 'Street 1');
     final long = streetAndNeighbourhoodLength('NewArea', 'Very Long Street Name Here');

     expect(short, equals('Street 1, NewArea'));
     expect(long, equals('Very Long Street Name Here'));  // or with abbreviation
   });
   ```

2. **Visual regression test:**
   - Screenshot all business cards with new neighbourhood
   - Verify no UI overflow or wrapping issues
   - Check on multiple device sizes (phone, tablet)

3. **Production monitoring:**
   - Deploy to staging first
   - Monitor error logs for null pointer exceptions
   - Check analytics for unexpected "unknown neighbourhood" occurrences

---

## Performance Characteristics

### Time Complexity
- **O(1)** constant time
- Single map lookup: O(1)
- String length check: O(1)
- String concatenation: O(n) where n = string length, but strings are short (typically <50 chars)
- **Overall:** Negligible performance impact

### Space Complexity
- **O(1)** constant space
- Configuration maps stored as constants (no heap allocation per call)
- No dynamic memory allocation during execution
- Single string return value (minimal heap usage)

### Optimization Notes
- **No premature optimization needed:** Function is already highly efficient
- **Map lookup vs if/else chain:** Map lookup chosen for maintainability, performance difference negligible
- **String concatenation:** Single concatenation per call, acceptable for short strings
- **Could optimize further (not recommended):**
  - Pre-compute all possible outputs (explosion of combinations)
  - Use integer codes instead of string keys (hurts readability)
  - Cache results (unnecessary for stateless function)

**Benchmark Results (Expected):**
- Single call: <0.5ms
- 1000 calls: <50ms
- Memory overhead per call: <100 bytes
- **Conclusion:** Performance is not a concern for this function

---

## Related Functions

### Functions Using This Function

1. **Business Card Widgets:**
   - Display formatted address in search results
   - Pass `business.neighbourhood` and `business.streetName` directly

2. **Business Profile Header:**
   - Show formatted address below business name
   - Same parameter binding as cards

3. **Map Pin Info Windows:**
   - Display address when user taps map marker
   - May use in combination with distance calculations

### Functions Called By This Function

**None.** This is a leaf function with no internal dependencies.

### Related Address Formatting Functions

**Consider creating these companion functions:**

1. **`formatFullAddress()`:**
   - Combines street, neighbourhood, postal code, city
   - Uses `streetAndNeighbourhoodLength()` for street/neighbourhood part
   - Adds postal code and city name
   - Example: `"Istedgade 12, Kbh V, 1650 København"`

2. **`getNeighbourhoodAbbreviation()`:**
   - Extracts just the abbreviation logic
   - Returns abbreviation or full name
   - Useful for standalone neighbourhood displays

3. **`formatAddressOneLine()`:**
   - Ultra-compact format for very narrow spaces
   - Example: `"Istedgade 12, V"` (just postal district)

4. **`formatAddressForAccessibility()`:**
   - Always uses full neighbourhood names (no abbreviations)
   - Optimizes for screen readers
   - Expands "Kbh" to "København" for clarity

---

## Accessibility Considerations

### Screen Reader Behavior

**Current Implementation:**
- Screen readers will read abbreviations literally ("K b h K")
- Not ideal for accessibility

**Recommended Enhancement:**
```dart
// Add aria-label equivalent in Flutter
Semantics(
  label: formatAddressForAccessibility(neighbourhood, streetName),
  child: Text(
    streetAndNeighbourhoodLength(neighbourhood, streetName),
  ),
)
```

**Alternative Approach:**
- Expand abbreviations when accessibility mode is active
- Check `MediaQuery.of(context).accessibleNavigation`
- Return full neighbourhood instead of abbreviated

### Visual Clarity

**Current Implementation:**
- Comma separator between street and neighbourhood
- No special styling for abbreviations

**Recommended Enhancement:**
```dart
// Use different text styles
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: streetName, style: boldStyle),
      TextSpan(text: ', ', style: regularStyle),
      TextSpan(text: neighbourhood, style: secondaryStyle),  // Lighter color
    ],
  ),
)
```

### Internationalization

**Current Limitation:**
- Configuration is Denmark/Copenhagen-specific
- Abbreviations only in Danish ("Kbh")

**Future Considerations:**
- Add language parameter for international expansion
- Support abbreviations in other languages ("Cph K" for English)
- Consider cultural expectations (some regions never abbreviate)

---

## Version History

**Version 1.0 (Current)**
- Initial implementation in FlutterFlow
- 13 Copenhagen neighbourhoods with abbreviations
- 7 non-Copenhagen neighbourhoods without abbreviations
- Length thresholds: 20 (abbreviation), 27 (omission)

**Future Versions (Planned):**

**Version 1.1 (Proposed):**
- Add accessibility enhancement (screen reader support)
- Add `formatAddressForAccessibility()` companion function
- Document additional Copenhagen neighbourhoods as discovered

**Version 2.0 (Consideration):**
- Add language parameter for international expansion
- Support multiple abbreviation sets (Danish, English, etc.)
- Make thresholds configurable (adaptive to device width)

---

## Summary

The `streetAndNeighbourhoodLength()` function is a well-designed, production-ready utility that solves a specific UI problem: displaying addresses in constrained spaces without overflow or truncation. Its strength lies in:

1. **Smart abbreviation logic** for Copenhagen neighbourhoods
2. **Simple implementation** with clear configuration
3. **No external dependencies** (pure Dart, no state)
4. **Graceful degradation** for edge cases
5. **Easy migration** to pure Flutter (no changes needed)

**Migration Status:** ✅ Ready for pure Flutter (copy as-is)
**Maintenance Burden:** ⚠️ Low (occasional neighbourhood additions)
**Performance Impact:** ✅ Negligible (O(1) constant time)
**Test Coverage Required:** ✅ High (15+ unit tests recommended)

**Key Takeaway:** This function exemplifies good utility design: focused purpose, clear logic, minimal dependencies, and easy to test. Use it as a template for other formatting utilities in the codebase.
