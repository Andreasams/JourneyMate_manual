# Master Translation Keys — All Pages

**Purpose:** Complete list of all translation keys needed for JSX v2 design implementation
**Format:** Ready for SQL generation
**Languages:** da, de, en, es, fi, fr, it, ja, ko, nl, no, pl, sv, uk, zh

---

## How to Use This Document

1. For each key below, provide translations in all 15 languages
2. Generate SQL INSERT statements for Supabase `translations` table
3. Upload to Supabase
4. Call `getTranslationsWithUpdate()` to fetch into app

---

## SEARCH RESULTS PAGE

### Match Section Headers

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `match_full_header` | Section header for restaurants matching all user needs | MATCHES ALL NEEDS | MATCHER ALLE BEHOV |
| `match_partial_header` | Section header for restaurants matching some user needs | PARTIAL MATCH | MATCHER DELVIST |
| `match_other_header` | Section header for restaurants not matching needs | OTHER PLACES | ANDRE STEDER |

### Match Info Text (Dynamic)

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `match_info_matches` | Shows X/Y filters matched | Matches {count}/{total} | Matcher {count}/{total} | `{count}`, `{total}` |
| `match_info_missing` | Shows which filters are missing | Missing: {filters} | Mangler: {filters} | `{filters}` (comma-separated list) |

**Usage Example:**
```dart
// "Matcher 2/3"
final text1 = getTranslations(lang, 'match_info_matches', cache)
  .replaceAll('{count}', '2')
  .replaceAll('{total}', '3');

// "Mangler: Børnestol, Havudsigt"
final text2 = getTranslations(lang, 'match_info_missing', cache)
  .replaceAll('{filters}', 'Børnestol, Havudsigt');
```

### Sort Options

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `sort_match` | Sort by best match (needs-first) | Best match | Bedst match |
| `sort_nearest` | Sort by distance from user | Nearest | Nærmest |
| `sort_station` | Sort by distance from train station | Nearest train station | Nærmest togstation |
| `sort_price_low` | Sort by price ascending | Price: Low to high | Pris: Lav til høj |
| `sort_price_high` | Sort by price descending | Price: High to low | Pris: Høj til lav |
| `sort_newest` | Sort by date added descending | Newest | Nyeste |

### Sort Sheet UI

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `sort_sheet_title` | Bottom sheet title | Sort by | Sortér efter |
| `sort_select_station` | Station selection screen title | Select train station | Vælg togstation |
| `filter_only_open` | Toggle to show only open restaurants | Only open places | Kun åbne steder |

### Empty State

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `search_no_results_title` | Empty state heading | No search results | Ingen søgeresultater | - |
| `search_no_results_body` | Empty state description | We couldn't find any places matching "{query}". Try adjusting your search or filters. | Vi kunne ikke finde steder der matcher "{query}". Prøv at justere din søgning eller filtre. | `{query}` |
| `search_clear_button` | Clear search button | Clear search | Ryd søgning | - |

---

## SQL Generation Template

```sql
-- Match Section Headers
INSERT INTO translations (key, language_code, value) VALUES
('match_full_header', 'da', 'MATCHER ALLE BEHOV'),
('match_full_header', 'de', '[TRANSLATION NEEDED]'),
('match_full_header', 'en', 'MATCHES ALL NEEDS'),
('match_full_header', 'es', '[TRANSLATION NEEDED]'),
('match_full_header', 'fi', '[TRANSLATION NEEDED]'),
('match_full_header', 'fr', '[TRANSLATION NEEDED]'),
('match_full_header', 'it', '[TRANSLATION NEEDED]'),
('match_full_header', 'ja', '[TRANSLATION NEEDED]'),
('match_full_header', 'ko', '[TRANSLATION NEEDED]'),
('match_full_header', 'nl', '[TRANSLATION NEEDED]'),
('match_full_header', 'no', '[TRANSLATION NEEDED]'),
('match_full_header', 'pl', '[TRANSLATION NEEDED]'),
('match_full_header', 'sv', '[TRANSLATION NEEDED]'),
('match_full_header', 'uk', '[TRANSLATION NEEDED]'),
('match_full_header', 'zh', '[TRANSLATION NEEDED]');

-- [Continue for all keys...]
```

---

## BUSINESS PROFILE PAGE

### Match Card

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `match_card_header` | Match card title | Why this match? | Hvorfor matcher det? |
| `match_see_full_list` | Button to expand all needs | See full list | Se hele listen |
| `match_matched_needs` | Section label for matched needs | Matches your needs | Matcher dine behov |
| `match_missed_needs` | Section label for missed needs | Doesn't match | Matcher ikke |

### Quick Action Pills

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `action_call` | Call restaurant button | Call | Ring op |
| `action_website` | Visit website button | Website | Hjemmeside |
| `action_book_table` | Book table button | Book table | Bestil bord |
| `action_view_map` | View on map button | View on map | Se på kort |

### Menu Section

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `menu_filter_show` | Show filters button | Filter | Filtrer |
| `menu_filter_hide` | Hide filters button | Hide filters | Skjul filtre |
| `menu_filter_restrictions` | Dietary restrictions section | Dietary restrictions | Kostrestriktioner |
| `menu_filter_allergens` | Allergens section | Allergens | Allergener |
| `menu_filter_preferences` | Dietary preferences section | Dietary preferences | Kostpræferencer |
| `menu_filter_clear_all` | Clear all filters button | Clear all | Ryd alle |
| `menu_view_full_page` | Open full menu page button | View full menu → | Vis på hel side → |
| `menu_empty_state_title` | Empty state heading when no items match filters | No dishes match your filters | Ingen retter matcher dine filtre |
| `menu_empty_state_body` | Empty state description | Try removing some filters or select 'Clear all' to see the full menu. | Prøv at fjerne nogle filtre eller vælg 'Ryd alle' for at se hele menuen. |

### Gallery Section

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `gallery_tab_food` | Food photos tab | Food | Mad |
| `gallery_tab_drinks` | Drinks photos tab | Drinks | Drikkevarer |
| `gallery_tab_ambiance` | Ambiance photos tab | Ambiance | Lokale |
| `gallery_view_all` | Open full gallery button | View all photos → | Se alle billeder → |

### Information Section

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `info_hours_header` | Opening hours section title | Opening hours | Åbningstider | - |
| `info_hours_today` | Today's hours preview | Today: {hours} | I dag: {hours} | `{hours}` |
| `info_facilities_header` | Facilities section title | Facilities | Faciliteter | - |
| `info_payments_header` | Payment options section title | Payment options | Betalingsmuligheder | - |
| `info_about_header` | About section title | About | Om | - |
| `info_report_error` | Report error button | Report incorrect info | Rapportér fejl | - |

**Usage Example:**
```dart
// "I dag: 10:00–22:00"
final text = getTranslations(lang, 'info_hours_today', cache)
  .replaceAll('{hours}', '10:00–22:00');
```

### Contact Info

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `contact_phone` | Phone label | Phone | Telefon |
| `contact_email` | Email label | Email | Email |
| `contact_instagram` | Instagram label | Instagram | Instagram |
| `contact_address` | Address label | Address | Adresse |
| `contact_copied` | Copy success toast | Copied to clipboard | Kopieret til udklipsholder |

### Share Button

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `share_message` | Share sheet message template | Check out {name}: {url} | Tjek {name} ud: {url} | `{name}`, `{url}` |

**Usage Example:**
```dart
// "Tjek Restaurant Name ud: https://..."
final text = getTranslations(lang, 'share_message', cache)
  .replaceAll('{name}', 'Restaurant Name')
  .replaceAll('{url}', 'https://...');
```

### Opening Hours Day Names

**Note:** These may already exist in FFLocalizations. Verify before adding to Supabase.

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `day_sunday` | Sunday | Sunday | Søndag |
| `day_monday` | Monday | Monday | Mandag |
| `day_tuesday` | Tuesday | Tuesday | Tirsdag |
| `day_wednesday` | Wednesday | Wednesday | Onsdag |
| `day_thursday` | Thursday | Thursday | Torsdag |
| `day_friday` | Friday | Friday | Fredag |
| `day_saturday` | Saturday | Saturday | Lørdag |

### Status Text

**Note:** These may overlap with Search page translations. Verify to avoid duplication.

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `status_open_until` | Open until time | Open until {time} | Åben til {time} | `{time}` |
| `status_closed` | Closed now | Closed | Lukket | - |
| `status_opens_at` | Opens at time | Opens at {time} | Åbner kl. {time} | `{time}` |
| `status_closes_tomorrow` | Closes tomorrow at time | Closes tomorrow at {time} | Lukker i morgen kl. {time} | `{time}` |

---

## MENU FULL PAGE

### Page Heading & Metadata

**Note:** These keys already exist in FlutterFlow. Included here for completeness.

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `foeokmwh` | Page heading | Menu | Menu |
| `sgpknl00` | Last updated prefix | Last brought up to date on  | Sidst ajurført den  |

### Filter Toggle

**Note:** These keys already exist in FlutterFlow. Included here for completeness.

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `bwvizajd` | Show filters button (panel closed) | Show filters | Vis filtre |
| `1smig27j` | Hide filters button (panel open) | Hide filters | Skjul filtre |

### Filter Section Labels & Explainers

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `filter_restrictions_label` | Dietary restrictions section header | Dietary Restrictions | Kostrestriktioner |
| `filter_restrictions_explain` | Explainer text for restrictions | Show only dishes that meet the selected dietary restriction. | Vis kun retter, der overholder den valgte kostrestriktion. |
| `filter_preferences_label` | Dietary preferences section header | Dietary Preferences | Kostpræferencer |
| `filter_preferences_explain` | Explainer text for preferences | Show only dishes that meet the selected diet. | Vis kun retter, der overholder den valgte diæt. |
| `filter_allergens_label` | Allergens section header | Allergens | Allergener |
| `filter_allergens_explain` | Explainer text for allergens | Hide dishes that contain the selected allergen. | Skjul retter, der indeholder det valgte allergen. |

**Note:** Individual filter names (Vegan, Gluten-free, etc.) are already in Supabase `translations` table as filter data.

### Filter Actions

**Note:** Check if `filter_clear_all` overlaps with Business Profile `menu_filter_clear_all` key.

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `filter_clear_all` | Clear all filters button | Clear all | Ryd alle |

### Empty State

**Note:** Check if these overlap with Business Profile `menu_empty_state_*` keys to avoid duplication.

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `menu_no_items_title` | Empty state heading when no items match | No dishes found | Ingen retter fundet |
| `menu_no_items_body` | Empty state description | Try adjusting your filters or select 'Clear all' to see the full menu. | Prøv at justere dine filtre eller vælg 'Ryd alle' for at se hele menuen. |

### Visible Item Count Display

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `menu_showing_count` | Filter summary text | Showing {count} items | Viser {count} retter | `{count}` |
| `menu_showing_count_filtered` | Filter summary with filter description | Showing {count} items matching your filters | Viser {count} retter der matcher dine filtre | `{count}` |

**Usage Example:**
```dart
// "Viser 12 retter der matcher dine filtre"
final text = getTranslations(lang, 'menu_showing_count_filtered', cache)
  .replaceAll('{count}', '12');
```

---

## GALLERY FULL PAGE

### Page Label

**Note:** This key already exists in FlutterFlow. Included here for completeness.

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `9wk6mbas` | Page subtitle/label below app bar | Gallery | Galleri |

### Gallery Category Tabs

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `gallery_food` | Food photos tab | Food | Mad |
| `gallery_menu` | Menu photos tab | Menu | Menu |
| `gallery_interior` | Interior photos tab | Interior | Inde |
| `gallery_outdoor` | Outdoor photos tab | Outdoor | Ude |

### Empty State

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `gallery_no_images` | Empty state message when category has no photos | No images in this category | Ingen billeder i denne kategori |

---

## SETTINGS PAGE (Account Hub)

**Note:** All these keys already exist in FlutterFlow. Included here for completeness and consistency.

### Page Title

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `cpiiq0im` | Page title/heading | Settings & account | Indstillinger & konto |

### Section Headers

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `3tlbn2an` | Section 1 header | My JourneyMate | Min JourneyMate |
| `pb7qrt34` | Section 2 header | Reach out | Tag kontakt |
| `d952v5y4` | Section 3 header | Resources | Ressourcer |

### Setting Rows

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `290fbi5g` | Localization setting row | Localization | Lokalisering |
| `297ogtn9` | Missing place report row | Are we missing a place? | Mangler vi et sted? |
| `uz83tnpj` | Feedback form row | Share feedback | Del feedback |
| `dme8eg1t` | Contact support row | Contact us | Kontakt os |
| `2v106a6z` | Terms of use row | Terms of use | Vilkår for brug |
| `gtmo283r` | Privacy policy row | Privacy policy | Privatlivspolitik |

**Note:** Sub-pages (Localization, Language & Currency, Location Sharing, forms) each have their own translation keys that will be documented separately.

---

## SETTINGS: LOCALIZATION PAGE (Navigation Hub)

**Note:** All these keys already exist in FlutterFlow. The Localization page is a navigation hub that links to Language & Currency and Location Sharing sub-pages.

### App Bar Title

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `3dn3iu2l` | App bar title | Settings | Indstillinger |

### Navigation Rows

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `n5kw731s` | Navigation row 1 (to Language & Currency page) | Language & currency | Sprog & valuta |
| `fojleyaf` | Navigation row 2 (to Location Sharing page) | Location sharing | Lokationsdeling |

**Note:** This page is a simple navigation hub with no inline controls. The JSX v2 design shows a different single-page approach with inline language/currency dropdowns and location status card, which is documented as a future enhancement.

---

## SETTINGS: LANGUAGE & CURRENCY PAGE

**Note:** All these keys already exist in FlutterFlow. This is a dedicated page for language and currency selection settings.

### App Bar Title

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `rct7k6pr` | App bar title | Language & currency | Sprog & valuta |

### Language Section

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `phfch9og` | Language section heading | Set your preferred language fo... | Indstil dit foretrukne sprog fo... |
| `gl71ej9n` | Language section description | Your current app language is E... | Dit nuværende app-sprog er E... |

### Currency Section

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `y0gzdnsp` | Currency section heading | Set your preferred currency fo... | Indstil din foretrukne valuta fo... |
| `n4pzujqg` | Currency description part 1 | Prices will be shown in  | Priser vil blive vist i  |
| `82y059ik` | Exchange rate disclaimer | Exchange rates are updated onc... | Valutakurser opdateres en gang... |

**Note:** This page uses custom widgets (`LanguageSelectorButton`, `CurrencySelectorButton`) for the actual selection UI. Language and currency option names come from `translationsCache` (dynamic data), not static translation keys.

---

## SETTINGS: LOCATION SHARING PAGE

**Note:** All these keys already exist in FlutterFlow. This page handles two permission states (location OFF and ON) with different UI for each.

### App Bar Title

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `k1c3fupg` | App bar title | Location sharing | Lokationsdeling |

### Location OFF State

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `u0wnvdeg` | Heading when location disabled | Turn on location sharing | Slå lokationsdeling til |
| `tht0e2um` | Description when location disabled | To turn on location sharing, t... | For at slå lokationsdeling til... |
| `3r57tlpr` | Button text (enable location) | Turn on location sharing | Slå lokationsdeling til |
| `iucaz964` | Privacy note when disabled | Your location is exclusively u... | Din lokation bruges udelukkende... |

### Location ON State

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `z1v9fk1m` | Heading when location enabled | Location sharing is turned on | Lokationsdeling er slået til |
| `d9nsgosc` | Description when location enabled | You can turn off location shar... | Du kan slå lokationsdeling fra... |
| `2hj5mmov` | Button text (go to settings) | Go to Settings | Gå til Indstillinger |
| `bhki1oos` | Privacy note when enabled | Your location is exclusively u... | Din lokation bruges udelukkende... |

**Note:** This page uses `FFAppState().locationStatus` to determine which UI state to show. Uses custom actions: `checkLocationPermission()`, `openLocationSettings()`.

---

## SETTINGS: FORM PAGES (Missing Place, Contact Us, Share Feedback)

**Note:** These pages use custom form widgets for all form logic. Only page-level translation keys (app bar titles) are documented here. Form field labels, validation messages, and other form-specific text are handled within the custom widgets.

### App Bar Titles

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `f5zshdrf` | Missing Place page title | Are we missing a place? | Mangler vi et sted? |
| `q6agbobw` | Contact Us page title | Contact us | Kontakt os |
| `hjszsd2y` | Share Feedback page title | Share feedback | Del feedback |

**Custom Widgets Used:**
- `MissingLocationFormWidget` - Report missing restaurant form
- `ContactUsFormWidget` - Support contact form
- `FeedbackFormWidget` - User feedback form with topic selection

**Note:** All form widgets receive `currentLanguage` and `translationsCache` props for internal translations. Additional translation keys used within widgets require custom widget source code documentation.

---

## WELCOME / ONBOARDING PAGES

**Note:** These pages handle new user onboarding and returning user welcome. All keys already exist in FlutterFlow.

### Welcome Page (WelcomePageWidget)

**Purpose:** Entry point that intelligently routes new vs returning users

**User Detection:**
- New user (no language set): Shows TWO buttons ("Continue" + "Fortsæt på dansk")
- Returning user (has language): Shows ONE button ("Continue")

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `6dww9uct` | Page heading | Welcome to JourneyMate | Velkommen til JourneyMate |
| `z6e1v2g7` | Tagline | Go out, your way. | Gå ud, på din måde. |
| `0eehrkgn` | Description text | Discover restaurants, cafés, a... | Opdag restauranter, caféer og... |
| `d2mrwxr4` | Primary button | Continue | Fortsæt |
| `cuy6esxb` | Secondary button (Danish quick path) | Fortsæt på dansk | Fortsæt på dansk |

**Navigation Logic:**
- New user + "Continue": → AppSettingsInitiateFlow
- New user + "Fortsæt på dansk": Sets language='da', currency='DKK', calls SearchAPI, → SearchResults
- Returning user + "Continue": → SearchResults

**Custom Actions:** `getTranslationsWithUpdate()`, `checkLocationPermission()`, `detectAccessibilitySettings()`

**Analytics:** `pageName: 'homepage'` (or `'welcomepage'` in some events)

---

### App Settings Initiate Flow (AppSettingsInitiateFlowWidget)

**Purpose:** Language and currency selection for new users (only shown if "Continue" tapped without language set)

**When Reached:**
- NEW users who tap "Continue" (no language set)
- NOT shown to users who tap "Fortsæt på dansk" (direct path)
- NOT shown to returning users

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `opycnrvy` | App bar title | App setup | App-opsætning |
| `0aq8qo7g` | Section heading | Localization | Lokalisering |
| `lup5v7ii` | Section description | Select your preferred language... | Vælg dit foretrukne sprog og... |
| `s3movlvc` | Language label | Language | Sprog |
| `elv468gp` | Currency label | Currency | Valuta |
| `6kxja9sp` | Exchange rate note | Exchange rates are updated onc... | Valutakurser opdateres én gang... |
| `9nldb2d7` | Complete button | Complete setup | Fuldfør opsætning |

**Custom Widgets Used:**
- `LanguageSelectorButton` - Shared with Language & Currency settings page
- `CurrencySelectorButton` - Shared with Language & Currency settings page

**Custom Actions:** `checkLocationPermission()`, `detectAccessibilitySettings()`

**Navigation:** On "Complete setup" → Calls SearchAPI → SearchResults

**Analytics:** `pageName: 'appSettingsInitiateFlow'`

**Note:** Custom selector widgets have their own translation keys (shared with Language & Currency settings page, documented separately).

---

## BUSINESS INFORMATION PAGE

**Note:** This page was previously misidentified as "Contact Details". It is the full Business Information page. All keys already exist in FlutterFlow.

**FlutterFlow Widget:** `BusinessInformationWidget`
**Route:** `BusinessInformation` (path: `businessInformation`)
**JSX File:** `information_page.jsx`

**Purpose:** Full-screen page showing comprehensive restaurant details including Google Maps, opening hours, features, and payment methods.

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `c9r4q0c8` | Expandable hours section header | Hours & contact | Timer & kontakt |
| `7pk0thnp` | Features section header | Features, services & amenities | Faciliteter, services og... |
| `zlgcyzrw` | Payment options section header | Payment options | Betalingsmuligheder |

**Custom Widgets Used:**
- `ContactDetailWidget` - Expandable hours/contact section with phone/email copy actions (has own translation keys)
- `BusinessFeatureButtons` - Dynamic filter feature chips (uses filter names from translationsCache)
- `PaymentOptionsWidget` - Dynamic payment method chips (uses filter names from translationsCache)

**Key Features:**
- Google Maps integration showing business location (200px height)
- Interactive filter chips → open FilterDescriptionSheet bottom sheet
- Dynamic status calculation on page load
- Analytics tracking (page_viewed with duration)

**Analytics:** `pageName: 'businessInformation'`

**Note:** Custom widgets have their own translation keys (documented separately in shared/widgets).

---

## Total Translation Keys Count

- **Search Results Page:** 14 keys
- **Business Profile Page:** 44 keys (includes 13 keys shared with Menu Full)
- **Menu Full Page:** 8 keys (new) + 4 existing FlutterFlow keys + 3 overlapping keys
- **Gallery Full Page:** 5 keys (new) + 1 existing FlutterFlow key
- **Business Information Page:** 3 existing FlutterFlow keys
- **Settings Page (Account hub):** 10 existing FlutterFlow keys
- **Settings: Localization Page (hub):** 3 existing FlutterFlow keys
- **Settings: Language & Currency Page:** 5 existing FlutterFlow keys
- **Settings: Location Sharing Page:** 9 existing FlutterFlow keys
- **Settings: Form Pages (3 pages):** 3 existing FlutterFlow keys (page-level only)
- **Welcome / Onboarding Pages (2 pages):** 12 existing FlutterFlow keys
  - Welcome Page: 5 keys
  - App Settings Initiate Flow: 7 keys

**Grand Total:** 106 keys (page-level only; form widget keys require custom widget documentation)

**Note:** Form pages (Missing Place, Contact Us, Share Feedback) use custom widgets with internal translations. Additional keys within widgets are unknown and require widget source code documentation.

**Notes on Business Profile + Menu Full Pages:**
- Business Profile menu section uses SAME WIDGETS as Menu Full page (UnifiedFiltersWidget, MenuCategoriesRows, MenuDishesListView)
- 13 menu-related translation keys are SHARED between these pages
- These shared keys counted only once in grand total

**Notes on Menu Full Page:**
- 4 keys already exist in FlutterFlow (page heading, filter toggle)
- 3 keys overlap with Business Profile (filter_clear_all, menu empty states)
- Only 8 truly new keys added (filter section labels/explainers + visible item count)

**Notes on Gallery Full Page:**
- 1 key already exists in FlutterFlow (9wk6mbas for "Gallery" label)
- 5 new keys added (4 category tabs + 1 empty state)

**Notes on Settings Pages:**
- Account hub: 10 keys (navigation page)
- Localization hub: 3 keys (navigation page)
- Language & Currency: 5 keys (settings page with custom selector widgets)
- Location Sharing: 9 keys (two-state permission page: OFF + ON)
- Form pages: 3 keys (page-level app bar titles only)
  - Missing Place, Contact Us, Share Feedback
  - Each uses custom form widget with internal translations
  - Widget translation keys unknown (requires custom widget source code)
- All page-level keys already exist in FlutterFlow

---

## BUSINESS PROFILE PAGE (Additional Keys from JSX)

### Status Text (Additional)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `business_status_open` | Open status indicator | Open | Åben |
| `business_status_closed` | Closed status indicator | Closed | Lukket |
| `business_status_until` | Time prefix "until" | until | til |

### Quick Action Buttons (Additional)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `quick_action_call` | Call button | Call | Ring op |
| `quick_action_website` | Website button | Website | Hjemmeside |
| `quick_action_book_table` | Book table button | Book table | Bestil bord |
| `quick_action_view_map` | View map button | View on map | Se på kort |

### Match Card (Additional)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `match_card_matches_all` | Full match indicator | Matches all | Matcher alle |
| `match_card_needs` | Needs label | needs | behov |
| `match_card_matches_partial` | Partial match indicator | Matches | Matcher |
| `match_card_of` | Separator "of" | of | af |

### Opening Hours Section (Additional)

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `section_hours_contact` | Section heading | Opening hours & contact | Åbningstider og kontakt | - |
| `hours_today_label` | Today's hours prefix | Today:  | I dag:  | - |
| `hours_heading` | Hours subheading | OPENING HOURS | ÅBNINGSTIDER | - |

### Contact Section

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `contact_heading` | Contact subheading | CONTACT | KONTAKT |
| `contact_phone` | Phone row label | Phone | Telefon |
| `contact_website` | Website row label | Website | Hjemmeside |
| `contact_instagram` | Instagram row label | Instagram | Instagram |
| `contact_booking` | Booking row label | Booking | Booking |

### Menu Filter Descriptions

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `menu_filter_dietary_restrictions` | Filter section title | Dietary restrictions | Kostrestriktioner |
| `menu_filter_dietary_restrictions_desc` | Filter description | Show only dishes that meet the selected dietary restriction. | Vis kun retter, der overholder den valgte kostrestriktion. |
| `menu_filter_dietary_preferences` | Filter section title | Dietary preferences | Kostpræferencer |
| `menu_filter_dietary_preferences_desc` | Filter description | Show only dishes that meet the selected diet. | Vis kun retter, der overholder den valgte diæt. |
| `menu_filter_allergens` | Filter section title | Allergens | Allergener |
| `menu_filter_allergens_desc` | Filter description | Hide dishes that contain the selected allergen. | Skjul retter, der indeholder det valgte allergen. |

### Section Labels

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `section_gallery` | Gallery section heading | Gallery | Galleri |
| `gallery_view_all` | View all button | View all photos → | Se alle billeder → |
| `section_menu` | Menu section heading | Menu | Menu |
| `menu_last_updated` | Last updated text | Last updated Dec 15, 2025 | Sidst ajourført 15. dec 2025 |
| `menu_hide_filters` | Hide filters button | Hide filters | Skjul filtre |
| `menu_show_filters` | Show filters button | Filter | Filtrer |
| `menu_no_items_heading` | Empty state heading | No dishes match your filters | Ingen retter matcher dine filtre |
| `menu_no_items_desc` | Empty state description | Try removing some filters or select "Clear all"\nto see the full menu. | Prøv at fjerne nogle filtre eller vælg "Ryd alle"\nfor at se hele menuen. |
| `menu_view_full_page` | View full page button | View full page → | Vis på hel side → |
| `section_facilities` | Facilities section heading | Facilities & services | Faciliteter og services |
| `section_payment_options` | Payments section heading | Payment options | Betalingsmuligheder |
| `section_about` | About section heading | About | Om |
| `report_incorrect_info` | Report error button | Report missing or incorrect information | Rapportér manglende eller forkerte oplysninger |

---

## CONTACT COPY POPUP

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `contact_copied_toast` | Success toast message | Copied to clipboard | Kopieret til udklipsholder |

---

## FACILITIES INFO SHEET

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `facilities_info_fallback` | Generic fallback description | For more information about this facility, please contact the restaurant directly. | For mere information om denne facilitet, kontakt venligst restauranten direkte. |

**Note:** Individual facility titles and descriptions come from Supabase filter data translations.

---

## REPORT MISSING INFO MODAL

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `report_modal_title` | Modal title | Report incorrect information | Report incorrect information |
| `report_modal_reporting_for` | Label prefix | Reporting information for | Reporting information for |
| `report_modal_help_text` | Help text | Help us keep information accurate by reporting any incorrect or missing details. | Help us keep information accurate by reporting any incorrect or missing details. |
| `report_modal_field_label` | Form label | What is incorrect or missing?  | What is incorrect or missing?  |
| `report_modal_field_helper` | Helper text | Please describe what information is wrong or missing | Please describe what information is wrong or missing |
| `report_modal_field_placeholder` | Textarea placeholder | Describe the incorrect information... | Describe the incorrect information... |
| `report_modal_submit` | Submit button | Submit report | Submit report |

---

## MENU ITEM DETAIL OVERLAY

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `menu_item_view_danish` | Menu option | View dish in Danish | View dish in Danish |
| `menu_item_view_english` | Menu option | View dish in English | View dish in English |
| `menu_item_view_usd` | Menu option | View price in US Dollar ($) | View price in US Dollar ($) |
| `menu_item_view_gbp` | Menu option | View price in British Pound (£) | View price in British Pound (£) |
| `menu_item_additional_info` | Section heading | Additional Information | Yderligere Information |
| `menu_item_dietary` | Section heading | Dietary preferences and restrictions | Kostpræferencer og restriktioner |
| `menu_item_allergens` | Section heading | Allergens | Allergener |
| `menu_item_reminder_title` | Reminder heading | Reminder | Påmindelse |
| `menu_item_reminder_text` | Reminder message | Always inform the restaurant about allergies and dietary restrictions when ordering. The information here is guidance only. | Fortæl altid restauranten om allergier og kostrestriktioner ved bestilling. Informationen her er kun vejledende. |

---

## MENU FULL PAGE (Additional Keys)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `menu_full_page_heading` | Page heading | Menu | Menu |
| `menu_full_page_last_updated` | Last updated label | Last updated on | Sidst ajurført den |
| `menu_full_hide_filters` | Hide filters button | Hide filters | Skjul filtre |
| `menu_full_show_filters` | Show filters button | Show filters | Vis filtre |
| `menu_full_filters_heading` | Filter panel heading | Filters | Filtre |
| `menu_category_burger_note` | Category note example | Choose whole grain or gluten-free bun (+ 10 kr.) | Vælg mellem fuldkorn eller glutenfri bolle (+ 10 kr.) |

---

## GALLERY FULL PAGE (Additional Keys)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `gallery_full_page_title` | Page title | Gallery | Galleri |

---

## BUSINESS INFORMATION PAGE (Additional Keys)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `information_page_heading_hours` | Section title | Opening hours etc. | Åbningstider m.m. |
| `information_page_heading_facilities` | Section heading | Facilities & services | Faciliteter og services |
| `information_page_heading_payments` | Section heading | Payment options | Betalingsmuligheder |

---

## WELCOME PAGE (Additional Keys from JSX)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `welcome_heading_returning_da` | Heading for returning user (Danish) | Welcome to\nJourneyMate | Velkommen til\nJourneyMate |
| `welcome_heading_new` | Heading for new user (English) | Welcome to\nJourneyMate | Welcome to\nJourneyMate |
| `welcome_tagline` | Tagline | Go out, your way. | Go out, your way. |
| `welcome_description_da` | Description (Danish) | Discover restaurants, cafés, and bars that match your needs | Opdag restauranter, caféer og barer, der matcher dine behov |
| `welcome_description_en` | Description (English) | Discover restaurants, cafés, and bars that match your needs | Discover restaurants, cafés, and bars that match your needs |
| `welcome_button_continue_da` | Button text (Danish) | Continue | Fortsæt |
| `welcome_button_continue_en` | Button text (English) | Continue | Continue |
| `welcome_button_continue_danish` | Button text (quick Danish path) | Continue in Danish | Fortsæt på dansk |

---

## APP SETTINGS INITIATE FLOW (Additional Keys from JSX)

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `onboarding_localization_heading` | Page heading | Localization | Localization |
| `onboarding_localization_desc` | Description | Select your preferred language and currency to personalize your experience. | Select your preferred language and currency to personalize your experience. |
| `onboarding_complete_setup` | Button text | Complete setup | Complete setup |
| `onboarding_language_label` | Section label | Language | Language |
| `onboarding_currency_label` | Section label | Currency | Currency |

---

## SETTINGS MAIN PAGE

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `settings_main_title` | Page title | Settings & account | Settings & account |
| `settings_section_my_journeymate` | Section header | My JourneyMate | My JourneyMate |
| `settings_localization` | Row label | Localization | Localization |
| `settings_section_reach_out` | Section header | Reach out | Reach out |
| `settings_missing_place` | Row label | Are we missing a place? | Are we missing a place? |
| `settings_share_feedback` | Row label | Share feedback | Share feedback |
| `settings_contact_us` | Row label | Contact us | Contact us |
| `settings_section_resources` | Section header | Resources | Resources |
| `settings_terms` | Row label | Terms of use | Terms of use |
| `settings_privacy` | Row label | Privacy policy | Privacy policy |

---

## SHARE FEEDBACK PAGE

### Form Labels & Descriptions

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `feedback_form_title` | Page title | Share feedback | Share feedback |
| `feedback_form_heading` | Heading | Share your feedback | Share your feedback |
| `feedback_form_description` | Description | Your input helps us improve JourneyMate. We read every message. | Your input helps us improve JourneyMate. We read every message. |
| `feedback_form_field_category` | Field label | What is your feedback about?  | What is your feedback about?  |
| `feedback_form_field_category_description` | Helper text | Pick the one that fits best. | Pick the one that fits best. |
| `feedback_form_field_message` | Field label | Tell us more  | Tell us more  |
| `feedback_form_field_message_description` | Helper text | Please describe your feedback in detail so we can understand and act on it. | Please describe your feedback in detail so we can understand and act on it. |
| `feedback_form_field_message_placeholder` | Placeholder | Share your thoughts, suggestions, or concerns... | Share your thoughts, suggestions, or concerns... |
| `feedback_form_checkbox_contact` | Checkbox label | May we contact you? | May we contact you? |
| `feedback_form_checkbox_contact_description` | Checkbox description | If you would like us to follow up on your feedback, please provide your contact information below. | If you would like us to follow up on your feedback, please provide your contact information below. |
| `feedback_form_field_name` | Field label | Your name | Your name |
| `feedback_form_field_name_placeholder` | Placeholder | Enter your name | Enter your name |
| `feedback_form_field_contact` | Field label | Contact information | Contact information |
| `feedback_form_field_contact_description` | Helper text | Please provide an email address or phone number where we can reach you. | Please provide an email address or phone number where we can reach you. |
| `feedback_form_field_contact_placeholder` | Placeholder | Email or phone number | Email or phone number |
| `feedback_form_button_submit` | Button text | Send feedback | Send feedback |

### Feedback Categories

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `feedback_category_wrong_info` | Category chip | Wrong information | Wrong information |
| `feedback_category_ideas` | Category chip | Ideas for the app | Ideas for the app |
| `feedback_category_bug` | Category chip | Bug | Bug |
| `feedback_category_missing_place` | Category chip | Missing a place | Missing a place |
| `feedback_category_suggestion` | Category chip | Suggestion | Suggestion |
| `feedback_category_praise` | Category chip | Praise | Praise |
| `feedback_category_other` | Category chip | Something else | Something else |

---

## MISSING PLACE PAGE

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `missing_place_title` | Page title | Are we missing a place? | Are we missing a place? |
| `missing_place_heading` | Heading | Missing a place? | Missing a place? |
| `missing_place_desc_1` | Description part 1 | If we are missing a place you think should be in JourneyMate, please let us know! | If we are missing a place you think should be in JourneyMate, please let us know! |
| `missing_place_desc_2` | Description part 2 | To make it easier for us to add the place, please provide as much detail as possible. | To make it easier for us to add the place, please provide as much detail as possible. |
| `missing_place_field_name` | Field label | Name of the business  | Name of the business  |
| `missing_place_field_name_placeholder` | Placeholder | Enter business name | Enter business name |
| `missing_place_field_address` | Field label | Address of the business  | Address of the business  |
| `missing_place_field_address_helper` | Helper text | In case other businesses share a similar name | In case other businesses share a similar name |
| `missing_place_field_address_placeholder` | Placeholder | Enter full address | Enter full address |
| `missing_place_field_message` | Field label | Message  | Message  |
| `missing_place_field_message_helper` | Helper text | Message to the JourneyMate-team | Message to the JourneyMate-team |
| `missing_place_field_message_placeholder` | Placeholder | Any additional details that might help us find and add the place... | Any additional details that might help us find and add the place... |
| `missing_place_button_submit` | Button text | Submit | Submit |

---

## CONTACT US PAGE

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `contact_us_title` | Page title | Contact us | Contact us |
| `contact_us_field_fullname` | Field label | Your full name  | Your full name  |
| `contact_us_field_fullname_placeholder` | Placeholder | Enter your full name | Enter your full name |
| `contact_us_field_contact` | Field label | Your email or phone number  | Your email or phone number  |
| `contact_us_field_contact_helper` | Helper text | Please provide either or both so we can get back to you | Please provide either or both so we can get back to you |
| `contact_us_field_contact_placeholder` | Placeholder | email@example.com or +45 12 34 56 78 | email@example.com or +45 12 34 56 78 |
| `contact_us_field_subject` | Field label | Subject  | Subject  |
| `contact_us_field_subject_helper` | Helper text | Topic of what you would like to contact us about | Topic of what you would like to contact us about |
| `contact_us_field_subject_placeholder` | Placeholder | Enter subject | Enter subject |
| `contact_us_field_message` | Field label | Message  | Message  |
| `contact_us_field_message_placeholder` | Placeholder | Type your message here... | Type your message here... |
| `contact_us_button_submit` | Button text | Send message | Send message |

---

## LOCATION SHARING PAGE

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `location_sharing_title` | Page title | Location sharing | Location sharing |
| `location_sharing_heading` | Heading | Turn on location sharing | Turn on location sharing |
| `location_sharing_desc` | Description | Allow JourneyMate to access your location to show nearby restaurants and personalize your experience. | Allow JourneyMate to access your location to show nearby restaurants and personalize your experience. |
| `location_sharing_button_enable` | Button text | Turn on location sharing | Turn on location sharing |
| `location_sharing_privacy_note` | Privacy note | We respect your privacy. Your location is only used to show nearby places and is never shared with third parties. | We respect your privacy. Your location is only used to show nearby places and is never shared with third parties. |

---

## LOCALIZATION PAGE

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `localization_title` | Page title | Localization | Localization |
| `localization_section_language_currency` | Section heading | Language & Currency | Language & Currency |
| `localization_section_location` | Section heading | Location | Location |
| `localization_location_desc` | Description | Allow JourneyMate to show nearby restaurants and personalize recommendations based on your location. | Allow JourneyMate to show nearby restaurants and personalize recommendations based on your location. |
| `localization_location_sharing` | Card label | Location sharing | Location sharing |
| `localization_location_enabled` | Status text (enabled) | Enabled | Enabled |
| `localization_location_disabled` | Status text (disabled) | Disabled | Disabled |
| `localization_location_desc_enabled` | Status description (enabled) | We can show you restaurants near you | We can show you restaurants near you |
| `localization_location_desc_disabled` | Status description (disabled) | Enable to see nearby restaurants | Enable to see nearby restaurants |
| `localization_button_manage` | Button text (when enabled) | Manage location settings | Manage location settings |
| `localization_button_enable` | Button text (when disabled) | Turn on location sharing | Turn on location sharing |
| `localization_privacy_note` | Privacy note | Your location is only used to show nearby places and is never shared with third parties. We respect your privacy. | Your location is only used to show nearby places and is never shared with third parties. We respect your privacy. |
| `localization_field_language` | Field label | Language | Language |
| `localization_field_language_desc` | Description | Set your preferred language for the app | Set your preferred language for the app |
| `localization_field_currency` | Field label | Currency | Currency |
| `localization_field_currency_desc` | Description | Choose your preferred currency for prices | Choose your preferred currency for prices |

---

## SEARCH PAGE (Additional Keys from JSX)

### Location & Search Input

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `city_copenhagen` | City name | Copenhagen | København |
| `search_input_placeholder` | Search bar placeholder | Search restaurants, dishes... | Søg restauranter, retter... |
| `search_results_count` | Results counter header | Search results ({count}) | Søgeresultater ({count}) |
| `search_results_nearby` | Nearby places header | Places near you | Steder nær dig |

### Filter Buttons

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `filter_button_location` | Location filter button | Location | Lokation |
| `filter_button_type` | Type filter button | Type | Type |
| `filter_button_needs` | Needs filter button | Needs | Behov |

### View Toggle

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `view_list` | List view toggle | List | Liste |
| `view_map` | Map view toggle | Map | Kort |
| `view_map_coming_soon` | Map view placeholder heading | Map view | Kortvisning |
| `view_map_coming_soon_desc` | Map view placeholder description | Map view coming soon | Kortvisning kommer snart |

### Filter Sheet Actions

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `filter_sheet_reset` | Reset filters button | Reset | Nulstil | - |
| `filter_sheet_show_results` | Show results button | Show {count} places | Se {count} steder | `{count}` |
| `filter_sheet_see_more` | See more button | See more | Se mere → | - |

### Bottom Navigation

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `tab_explore` | Explore tab | Explore | Udforsk |
| `tab_saved` | Saved tab | Saved | Gemte |
| `tab_profile` | Profile tab | Profile | Profil |

### Empty States (Filter-based)

| Key | Context | English (en) | Danish (da) | Parameters |
|-----|---------|--------------|-------------|------------|
| `search_no_results_body_filters` | Empty state when filters don't match | We couldn't find any places matching your selected filters. Try adjusting your filters. | Vi kunne ikke finde steder der matcher dine valgte filtre. Prøv at justere dine filtre. | - |

---

**Last Updated:** 2026-02-19
