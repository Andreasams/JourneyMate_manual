# getDietaryAndAllergyTitleTranslations - FlutterFlow Custom Function

## Purpose

Returns **static localized translations** for dietary and allergen section headers and disclaimers displayed in the Dish Bottom Sheet. This function provides UI label translations that are hardcoded within the function itself (not sourced from the global translation cache).

**Key Distinction:** Unlike `getTranslations()` which pulls from a dynamic translation cache, this function contains **embedded static translations** for five specific UI elements in seven languages.

**Primary Use Case:**
- Displaying section headers in the Dish Bottom Sheet ("Additional Information", "Dietary preferences and restrictions", "Allergens")
- Displaying disclaimers about information sources and accuracy warnings

---

## Function Signature

```dart
String getDietaryAndAllergyTitleTranslations(
  String key,
  String languageCode,
)
```

---

## Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `key` | `String` | Yes | Translation key identifier for the desired label |
| `languageCode` | `String` | Yes | ISO language code (e.g., 'en', 'da', 'de', 'fr', 'it', 'no', 'sv') |

### Valid Translation Keys

| Key | Purpose |
|-----|---------|
| `'additional_info_header'` | Section header for additional information section |
| `'dietary_header'` | Section header for dietary preferences/restrictions |
| `'allergens_header'` | Section header for allergens |
| `'information_source_header'` | Section header for information source disclaimer |
| `'information_disclaimer'` | Disclaimer text about business-provided data and verification |
| `'journeymate_disclaimer'` | Disclaimer text about JourneyMate's verification efforts |

### Supported Languages

Seven languages are fully supported:
- `'en'` - English
- `'da'` - Danish
- `'de'` - German
- `'fr'` - French
- `'it'` - Italian
- `'no'` - Norwegian
- `'sv'` - Swedish

**Fallback Behavior:**
- If `languageCode` doesn't match a supported language → falls back to English
- If `key` doesn't exist in any language → returns the key itself

---

## Return Value

**Type:** `String`

**Returns:**
- The localized translation string for the specified key and language
- English translation if language not supported
- The key itself if no translation exists

**Example Returns:**

```dart
// English header
getDietaryAndAllergyTitleTranslations('dietary_header', 'en')
→ 'Dietary preferences and restrictions'

// Danish header
getDietaryAndAllergyTitleTranslations('dietary_header', 'da')
→ 'Kostpræferencer og restriktioner'

// German disclaimer with business name placeholder
getDietaryAndAllergyTitleTranslations('information_disclaimer', 'de')
→ 'Informationen zu Inhaltsstoffen, Allergien und Ernährung bereitgestellt von [businessName]. Verifizieren Sie vor der Bestellung immer mit den Mitarbeitern, da sich Inhaltsstoffe ändern können und Kreuzkontaminationen auftreten können.'

// Unsupported language (falls back to English)
getDietaryAndAllergyTitleTranslations('allergens_header', 'es')
→ 'Allergens'

// Invalid key (returns key itself)
getDietaryAndAllergyTitleTranslations('invalid_key', 'en')
→ 'invalid_key'
```

---

## Dependencies

**None.** This function is completely self-contained with no external dependencies.

- Does NOT use `getTranslations()` helper
- Does NOT access `translationsCache`
- Does NOT import any external packages
- Contains all translation data as an internal constant map

---

## FFAppState Usage

**None.** This function does not access FFAppState.

---

## Translation Keys and Output

### Static Translation Data

The function contains an internal constant map with all translations:

```dart
const staticTranslations = {
  'additional_info_header': {
    'en': 'Additional Information',
    'da': 'Yderligere Information',
    'de': 'Weitere Informationen',
    'fr': 'Informations Complémentaires',
    'it': 'Informazioni aggiuntive',
    'no': 'Tilleggsinformasjon',
    'sv': 'Ytterligare Information',
  },
  'dietary_header': {
    'en': 'Dietary preferences and restrictions',
    'da': 'Kostpræferencer og restriktioner',
    'de': 'Ernährungspräferenzen und -einschränkungen',
    'fr': 'Préférences et restrictions alimentaires',
    'it': 'Preferenze e restrizioni dietetiche',
    'no': 'Kostholdsreferanser og restriksjoner',
    'sv': 'Kostpreferenser och restriktioner',
  },
  'allergens_header': {
    'en': 'Allergens',
    'da': 'Allergener',
    'de': 'Allergene',
    'fr': 'Allergènes',
    'it': 'Allergeni',
    'no': 'Allergener',
    'sv': 'Allergener',
  },
  'information_source_header': {
    'en': 'Information source',
    'da': 'Informationskilde',
    'de': 'Informationsquelle',
    'fr': 'Source d\'information',
    'it': 'Fonte di informazione',
    'no': 'Informasjonskilde',
    'sv': 'Informationskälla',
  },
  'information_disclaimer': {
    'en': 'Ingredient, allergy and dietary information provided by [businessName]. Always verify with staff before ordering as ingredients may change and cross-contamination can occur.',
    'da': 'Ingrediens- og diætoplysninger leveret af [businessName]. Verificer altid med personalet før bestilling, da ingredienser kan ændre sig og krydskontaminering kan forekomme.',
    'de': 'Informationen zu Inhaltsstoffen, Allergien und Ernährung bereitgestellt von [businessName]. Verifizieren Sie vor der Bestellung immer mit den Mitarbeitern, da sich Inhaltsstoffe ändern können und Kreuzkontaminationen auftreten können.',
    'fr': 'Informations sur les ingrédients, les allergies et le régime alimentaire fournies par [businessName]. Toujours vérifier auprès du personnel avant de commander, car les ingrédients peuvent changer et une contamination croisée peut se produire.',
    'it': 'Informazioni su ingredienti, allergie e dieta fornite da [businessName]. Verificare sempre con il personale prima di ordinare poiché gli ingredienti possono cambiare e può verificarsi una contaminazione incrociata.',
    'no': 'Ingrediens-, allergi- og diettinformasjon levert av [businessName]. Verifiser alltid med personalet før du bestiller, da ingredienser kan endre seg og krysskontaminering kan oppstå.',
    'sv': 'Ingrediens-, allergi- och kostinformation tillhandahållen av [businessName]. Verifiera alltid med personalen innan du beställer, eftersom ingredienser kan ändras och korskontaminering kan uppstå.',
  },
  'journeymate_disclaimer': {
    'en': 'JourneyMate does its best to verify this information but cannot be held responsible for its accuracy.',
    'da': 'JourneyMate gør sit bedste for at verificere disse oplysninger, men kan ikke holdes ansvarlig for deres nøjagtighed.',
    'de': 'JourneyMate bemüht sich, diese Informationen zu verifizieren, kann jedoch nicht für deren Richtigkeit haftbar gemacht werden.',
    'fr': 'JourneyMate fait de son mieux pour vérifier ces informations, mais ne peut être tenu responsable de leur exactitude.',
    'it': 'JourneyMate fa del suo meglio per verificare queste informazioni, ma non può essere ritenuto responsabile della loro accuratezza.',
    'no': 'JourneyMate gjør sitt beste for å verifisere denne informasjonen, men kan ikke holdes ansvarlig for nøyaktigheten.',
    'sv': 'JourneyMate gör sitt bästa för att verifiera den här informationen, men kan inte hållas ansvarig för dess riktighet.',
  },
};
```

### Business Name Placeholder

The `'information_disclaimer'` key contains a **`[businessName]`** placeholder that must be replaced by the caller:

```dart
final disclaimer = getDietaryAndAllergyTitleTranslations('information_disclaimer', 'en');
// Returns: "...provided by [businessName]..."

// Caller must replace placeholder:
final finalText = disclaimer.replaceAll('[businessName]', actualBusinessName);
// Returns: "...provided by Restaurant Copenhagen..."
```

---

## Usage Examples

### Example 1: Display Section Headers in Dish Bottom Sheet

```dart
Widget build(BuildContext context) {
  final languageCode = FFAppState().currentLanguage;

  return Column(
    children: [
      // Additional Info Header
      Text(
        getDietaryAndAllergyTitleTranslations('additional_info_header', languageCode),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),

      // Dietary Preferences Section
      SectionHeader(
        title: getDietaryAndAllergyTitleTranslations('dietary_header', languageCode),
      ),
      DietaryPreferencesWidget(...),

      // Allergens Section
      SectionHeader(
        title: getDietaryAndAllergyTitleTranslations('allergens_header', languageCode),
      ),
      AllergensWidget(...),
    ],
  );
}
```

### Example 2: Display Information Source Disclaimer

```dart
Widget buildDisclaimerSection(String businessName, String languageCode) {
  // Get source header
  final sourceHeader = getDietaryAndAllergyTitleTranslations(
    'information_source_header',
    languageCode
  );

  // Get disclaimer with business name placeholder
  final rawDisclaimer = getDietaryAndAllergyTitleTranslations(
    'information_disclaimer',
    languageCode
  );

  // Replace placeholder with actual business name
  final disclaimer = rawDisclaimer.replaceAll('[businessName]', businessName);

  // Get JourneyMate disclaimer
  final jmDisclaimer = getDietaryAndAllergyTitleTranslations(
    'journeymate_disclaimer',
    languageCode
  );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(sourceHeader, style: headerStyle),
      SizedBox(height: 8),
      Text(disclaimer, style: bodyStyle),
      SizedBox(height: 8),
      Text(jmDisclaimer, style: bodyStyle),
    ],
  );
}
```

### Example 3: Multilingual Support

```dart
// English
final englishHeader = getDietaryAndAllergyTitleTranslations('allergens_header', 'en');
print(englishHeader); // → "Allergens"

// Danish
final danishHeader = getDietaryAndAllergyTitleTranslations('allergens_header', 'da');
print(danishHeader); // → "Allergener"

// German
final germanHeader = getDietaryAndAllergyTitleTranslations('allergens_header', 'de');
print(germanHeader); // → "Allergene"

// Unsupported language (falls back to English)
final spanishHeader = getDietaryAndAllergyTitleTranslations('allergens_header', 'es');
print(spanishHeader); // → "Allergens"
```

---

## Edge Cases

### Case 1: Invalid Translation Key

```dart
final result = getDietaryAndAllergyTitleTranslations('invalid_key', 'en');
// Returns: 'invalid_key' (the key itself)
```

**Behavior:**
- Returns the key as-is if not found in the static translations map
- No error thrown
- Caller should validate keys before passing

### Case 2: Unsupported Language Code

```dart
final result = getDietaryAndAllergyTitleTranslations('dietary_header', 'es');
// Returns: 'Dietary preferences and restrictions' (English fallback)
```

**Behavior:**
- Falls back to English translation
- Uses null-coalescing operator: `translations?[lang] ?? translations?['en'] ?? key`

### Case 3: Empty Parameters

```dart
// Empty key
final result1 = getDietaryAndAllergyTitleTranslations('', 'en');
// Returns: '' (empty string, since key doesn't exist in map)

// Empty language code
final result2 = getDietaryAndAllergyTitleTranslations('dietary_header', '');
// Returns: 'Dietary preferences and restrictions' (English fallback)
```

**Behavior:**
- Empty key returns empty string (key doesn't exist in map)
- Empty language code triggers English fallback
- No null checks performed (assumes non-null strings)

### Case 4: Case Sensitivity

```dart
// Language code normalization
final result1 = getDietaryAndAllergyTitleTranslations('dietary_header', 'EN');
// Language code is converted to lowercase internally: .toLowerCase()
// Returns: 'Dietary preferences and restrictions' (English)

// Key is case-sensitive
final result2 = getDietaryAndAllergyTitleTranslations('DIETARY_HEADER', 'en');
// Returns: 'DIETARY_HEADER' (key not found, returns key itself)
```

**Behavior:**
- Language code is normalized to lowercase: `languageCode.toLowerCase()`
- Translation key is case-sensitive (must match exactly)

### Case 5: Missing Business Name Replacement

```dart
final disclaimer = getDietaryAndAllergyTitleTranslations('information_disclaimer', 'en');
// Contains: "...provided by [businessName]..."

// If caller forgets to replace placeholder:
// UI will display: "...provided by [businessName]..."
```

**Behavior:**
- Function returns text with `[businessName]` placeholder intact
- **Caller responsibility** to replace placeholder before displaying
- No automatic replacement or validation

---

## Real-World Usage in FlutterFlow

### Location in Codebase

**Primary Usage:**
- `DishBottomSheet` widget (Dish Detail view)

**Search Pattern:**
```bash
grep -r "getDietaryAndAllergyTitleTranslations" lib/
```

### Example from DishBottomSheet

```dart
// Section header display
Container(
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Text(
    getDietaryAndAllergyTitleTranslations('dietary_header', FFAppState().currentLanguage),
    style: FlutterFlowTheme.of(context).bodyMedium.override(
      fontFamily: 'Manrope',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  ),
)

// Information source section with business name replacement
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      getDietaryAndAllergyTitleTranslations('information_source_header', FFAppState().currentLanguage),
      style: FlutterFlowTheme.of(context).labelMedium,
    ),
    SizedBox(height: 8),
    Text(
      getDietaryAndAllergyTitleTranslations('information_disclaimer', FFAppState().currentLanguage)
        .replaceAll('[businessName]', widget.businessName!),
      style: FlutterFlowTheme.of(context).bodySmall,
    ),
    SizedBox(height: 4),
    Text(
      getDietaryAndAllergyTitleTranslations('journeymate_disclaimer', FFAppState().currentLanguage),
      style: FlutterFlowTheme.of(context).bodySmall,
    ),
  ],
)
```

---

## Relationship to Other Functions

### vs. `getTranslations()`

| Aspect | `getDietaryAndAllergyTitleTranslations()` | `getTranslations()` |
|--------|------------------------------------------|---------------------|
| **Data Source** | Static hardcoded map inside function | Dynamic cache from FFAppState |
| **Parameters** | `(key, languageCode)` | `(languageCode, key, translationsCache)` |
| **Scope** | 6 specific UI labels only | All app translations |
| **Cache Dependency** | None | Requires `translationsCache` parameter |
| **Update Method** | Code change required | Cache update at runtime |
| **Fallback** | English → key | Empty string → warning |

**Why Both Exist:**
- `getDietaryAndAllergyTitleTranslations()` → Simple, static UI labels that rarely change
- `getTranslations()` → Dynamic content that can be updated without code changes

### Related Dietary/Allergen Functions

1. **`convertDietaryPreferencesToString()`**
   - Converts dietary **IDs** → formatted localized string
   - Uses `getTranslations()` to fetch individual dietary names
   - Example: `[1, 6]` → "gluten-free and vegan"

2. **`convertAllergiesToString()`**
   - Converts allergen **IDs** → formatted localized string
   - Uses `getTranslations()` to fetch individual allergen names
   - Example: `[2, 7]` → "Contains gluten and milk"

3. **`getDietaryAndAllergyTitleTranslations()`** ← This function
   - Returns **section headers** and **disclaimers**
   - No ID conversion, just key → label mapping
   - Example: `'dietary_header'` → "Dietary preferences and restrictions"

**Typical Usage Together:**

```dart
// Section header (this function)
Text(getDietaryAndAllergyTitleTranslations('dietary_header', languageCode));

// Section content (convertDietaryPreferencesToString)
Text(convertDietaryPreferencesToString(
  [1, 6], // gluten-free, vegan
  languageCode,
  false, // isBeverage
  translationsCache,
));
// → "This dish is gluten-free and vegan"

// Allergens section header (this function)
Text(getDietaryAndAllergyTitleTranslations('allergens_header', languageCode));

// Allergens content (convertAllergiesToString)
Text(convertAllergiesToString(
  [2, 7], // gluten, milk
  languageCode,
  false, // isBeverage
  translationsCache,
));
// → "Contains cereals containing gluten and milk"
```

---

## Testing Checklist

### Functional Tests

- [ ] **All valid keys return correct translations**
  - Test each of the 6 keys ('additional_info_header', 'dietary_header', 'allergens_header', 'information_source_header', 'information_disclaimer', 'journeymate_disclaimer')
  - Verify translations for all 7 languages (en, da, de, fr, it, no, sv)

- [ ] **Invalid key returns key itself**
  - Pass non-existent key
  - Verify it returns the key as-is

- [ ] **Unsupported language falls back to English**
  - Test with 'es', 'zh', 'ja', etc.
  - Verify English translation is returned

- [ ] **Case sensitivity handled correctly**
  - Language code 'EN' → normalized to 'en'
  - Key 'DIETARY_HEADER' → not found, returns key

- [ ] **Business name placeholder preserved**
  - Get 'information_disclaimer'
  - Verify '[businessName]' appears in output
  - Test replacement: `.replaceAll('[businessName]', 'Test Restaurant')`

### Edge Case Tests

- [ ] **Empty parameters**
  - Empty key: returns empty string
  - Empty language code: falls back to English

- [ ] **Null safety** (if applicable)
  - Verify function doesn't accept null parameters (type system enforcement)

- [ ] **Translation completeness**
  - Every key has translations for all 7 languages
  - No missing translations in the static map

### Integration Tests

- [ ] **Used in DishBottomSheet correctly**
  - Section headers display in correct language
  - Disclaimers show with business name replaced
  - Language switching updates all labels

- [ ] **Works with FFAppState language switching**
  - Change language in app settings
  - Verify all section headers update

---

## Migration Notes

### Phase 3 Implementation

**Function Location:**
- **FlutterFlow:** `lib/flutter_flow/custom_functions.dart` (lines 1925-2014)
- **Phase 3:** `lib/shared/functions/get_dietary_and_allergy_title_translations.dart`

**Migration Strategy:**

1. **Extract as standalone utility function**
   ```dart
   // lib/shared/functions/get_dietary_and_allergy_title_translations.dart

   /// Returns localized translations for dietary and allergen section headers/disclaimers.
   String getDietaryAndAllergyTitleTranslations(String key, String languageCode) {
     const staticTranslations = {
       // ... (copy entire map from FlutterFlow)
     };

     final lang = languageCode.toLowerCase();
     final translations = staticTranslations[key];

     return translations?[lang] ?? translations?['en'] ?? key;
   }
   ```

2. **Import in widgets**
   ```dart
   import 'package:journey_mate/shared/functions/get_dietary_and_allergy_title_translations.dart';
   ```

3. **Use in DishBottomSheet**
   ```dart
   // Section headers
   Text(getDietaryAndAllergyTitleTranslations('dietary_header', languageCode))

   // Disclaimers with business name replacement
   Text(
     getDietaryAndAllergyTitleTranslations('information_disclaimer', languageCode)
       .replaceAll('[businessName]', businessName)
   )
   ```

### Key Considerations

**Why Not Use Global Translation Cache?**
- These 6 labels are **UI structure elements** that rarely change
- Hardcoding provides **guaranteed availability** without cache dependency
- Simplifies widget code (no need to pass `translationsCache` parameter)
- Reduces translation file size (fewer entries to manage)

**When to Update Translations:**
- Add new language → add column to static map for all 6 keys
- Change wording → update static map, recompile app
- No runtime updates possible (by design)

**Alternative Approaches:**
1. **Keep as-is:** Static function with embedded translations (simplest)
2. **Move to translation cache:** Add 6 keys to global translations (consistency)
3. **JSON file:** Load from assets (flexibility, but adds complexity)

**Recommended Approach for Phase 3:**
Keep static function as-is. The simplicity and guaranteed availability outweigh the minor duplication.

### Testing Requirements

- [ ] Unit tests for all 6 keys × 7 languages (42 combinations)
- [ ] Fallback behavior tests (invalid key, unsupported language)
- [ ] Business name placeholder replacement test
- [ ] Widget integration tests (DishBottomSheet displays correct labels)
- [ ] Language switching test (labels update when language changes)

---

## Summary

**Function Type:** Static localization utility
**Complexity:** Low (simple map lookup with fallback)
**Dependencies:** None
**Cache Required:** No
**Primary Use:** Dish Bottom Sheet section headers and disclaimers

**Key Takeaways:**
1. Returns **6 specific UI labels** in 7 languages
2. **No dynamic cache** — all translations hardcoded inside function
3. `'information_disclaimer'` key contains `[businessName]` placeholder that **caller must replace**
4. Falls back to English for unsupported languages
5. Returns key itself if key not found in static map
6. Completely independent from `getTranslations()` system

**Migration Priority:** Low — straightforward copy to standalone utility file in Phase 3.
