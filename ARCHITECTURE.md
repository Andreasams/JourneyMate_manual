# JourneyMate Architecture Guide

**Version:** 1.0
**Last Updated:** February 2026
**Project Phase:** Maintenance & Debugging (Phase 8)
**App Status:** Live on TestFlight

---

## Purpose

This document explains **how the JourneyMate app is built**. Read this to understand the architectural patterns, state management approach, widget conventions, and code quality standards that ensure all future development maintains consistency.

**Quick Navigation:**
- **Working on a specific task?** See **CLAUDE.md → Task-Based Navigation Guide** (12 scenarios with 10-30 minute targeted reading lists)
- **New to the project?** Read [Philosophy](#philosophy) (lines 22-64) and [State Management](#state-management) (lines 121-260) for 60-minute deep dive
- **Need a specific section?** Use alphabetical index below for direct access

**Section Index (Alphabetical):**
- [Analytics Architecture](#analytics-architecture) (lines 729-803) — Fire-and-forget, ActivityScope, 36 event types
- [API Service Pattern](#api-service-pattern) (lines 461-517) — Singleton, cache, BuildShip integration
- [Code Quality Standards](#code-quality-standards) (lines 806-845) — Flutter analyze, design tokens, algorithms
- [Common Pitfalls](#common-pitfalls) (lines 848-1012) — 11 anti-patterns with fixes (⚠️ read before first commit)
- [Design Token System](#design-token-system) (lines 662-727) — Quick lookup tables for colors, spacing, typography
- [Documentation Philosophy](#documentation-philosophy) (lines 1015-1034) — Three types of docs, when to update
- [Key Architectural Decisions](#key-architectural-decisions) (lines 1065-1098) — CityID, favorites, filters, translations, engagement
- [Philosophy](#philosophy) (lines 22-64) — Five core principles (design tokens, state, translations, analytics, widgets)
- [Pre-Loading Architecture](#pre-loading-architecture) (lines 520-597) — Safe async pattern for instant page loads
- [Project Structure](#project-structure) (lines 67-118) — File organization, 12 pages, 34 widgets, 8 providers
- [Provider Initialization Order](#provider-initialization-order) (lines 1038-1062) — Critical startup sequence in main.dart
- [References](#references) (lines 1101-1110) — Links to other documentation files
- [State Management](#state-management) (lines 121-260) — When to use what, provider catalog, Riverpod 3.x patterns
- [Translation System](#translation-system) (lines 599-659) — Dynamic td() function, 355 keys, 7 languages
- [Widget Patterns](#widget-patterns) (lines 263-458) — Self-contained widgets, page wrappers, bottom sheets

---

## Philosophy

JourneyMate was migrated from FlutterFlow to production Flutter with five core architectural principles:

### 1. Design Token Adherence (Visual Consistency)
- **All colors** from `AppColors` — no raw hex strings
- **All spacing** from `AppSpacing` — no magic pixel numbers
- **All typography** from `AppTypography` — no inline `TextStyle`
- **All radii** from `AppRadius` — no hardcoded border radius values

**Why:** Ensures visual consistency across 12 pages and 34 shared widgets. Design changes propagate automatically.

### 2. Riverpod 3.x State Management (Predictable State)
- **NotifierProvider** for global and session state
- **AsyncNotifierProvider** for API-dependent state
- **Local State** in `ConsumerStatefulWidget` for page-specific UI state
- **No code generation** — all providers hand-written

**Why:** Single source of truth for app state. No FFAppState, no Provider, no confusion.

### 3. Single Source of Truth for Translations (Maintainability)
- **100% dynamic** from Supabase `ui_translations` table via BuildShip API
- **355 app keys** + 142 legacy keys = 497 total
- **7 languages:** en, da, de, fr, it, no, sv
- **Zero hardcoded strings** in production code

**Why:** Translations update without app releases. Content team controls all text.

### 4. Fire-and-Forget Analytics (Never Block UI)
- **AnalyticsService** singleton manages all tracking
- **ActivityScope** wraps app for automatic engagement detection
- **Never await** analytics calls — fire-and-forget with `.catchError()`
- **36 event types** tracked to Supabase via BuildShip

**Why:** User experience is never blocked by analytics. Data loss acceptable, UX responsiveness is not.

### 5. Self-Contained Widgets (Minimal Prop Drilling)
- Widgets read providers and context internally
- Props only for business logic data, not infrastructure (language, translations, dimensions)
- Easier testing, better encapsulation, cleaner code

**Why:** Discovered in Phase 7 — reduces boilerplate and makes widgets reusable without extensive prop passing.

---

## Project Structure

```
journey_mate/
├── lib/
│   ├── main.dart                      # App initialization, provider container setup
│   ├── app.dart                       # MaterialApp configuration, router integration
│   ├── providers/                     # 8 Riverpod NotifierProviders
│   │   ├── app_providers.dart         # Accessibility, analytics, locale
│   │   ├── search_providers.dart      # Search state, filter session management
│   │   ├── business_providers.dart    # Business profile, dietary filters
│   │   ├── filter_providers.dart      # Filter hierarchy (AsyncNotifier)
│   │   ├── settings_providers.dart    # Localization, location permission
│   │   └── provider_state_classes.dart # All state classes (467 lines)
│   ├── services/                      # Singletons for cross-cutting concerns
│   │   ├── api_service.dart           # BuildShip REST API client (352 lines)
│   │   ├── analytics_service.dart     # Analytics + EngagementTracker (469 lines)
│   │   └── translation_service.dart   # td(ref, key) helper function
│   ├── models/                        # Data classes
│   │   ├── latlng.dart                # Location coordinates
│   │   └── api_call_response.dart     # API response wrapper
│   ├── pages/                         # 12 app pages
│   │   ├── search_page.dart           # Main restaurant discovery
│   │   ├── business_profile_page.dart # Restaurant details
│   │   ├── menu_full_page.dart        # Dietary filtering
│   │   ├── gallery_full_page.dart     # Image gallery
│   │   ├── business_information_page.dart # About restaurant
│   │   ├── welcome_page.dart          # Onboarding
│   │   ├── app_settings_initiate_flow_page.dart # Initial language selection
│   │   ├── settings_and_account_page.dart # Settings hub
│   │   ├── localization_settings_page.dart # Language/currency
│   │   ├── location_settings_page.dart # Location sharing
│   │   ├── contact_us_page.dart       # Contact form wrapper
│   │   ├── feedback_page.dart         # Feedback form wrapper
│   │   └── missing_place_page.dart    # Missing place form wrapper
│   ├── widgets/                       # 34 shared widgets
│   │   ├── shared/                    # Reusable components
│   │   ├── activity_scope.dart        # Automatic engagement tracking
│   │   └── app_lifecycle_observer.dart # App state lifecycle hooks
│   ├── theme/                         # Design tokens (source of truth)
│   │   ├── app_colors.dart            # 30 color constants
│   │   ├── app_spacing.dart           # 8 spacing constants
│   │   ├── app_typography.dart        # 14 text styles
│   │   ├── app_radius.dart            # 7 border radius constants
│   │   ├── app_button_styles.dart     # Button style presets
│   │   ├── app_input_decorations.dart # Input decoration presets
│   │   └── app_constants.dart         # Misc constants (CityID, etc.)
│   └── router/
│       └── app_router.dart            # go_router 17.x route definitions (11 routes)
└── test/                              # 70+ passing unit tests
```

---

## State Management

### When to Use What

| Scope | Pattern | Example | Storage |
|-------|---------|---------|---------|
| **Global persisted** | NotifierProvider + SharedPreferences | User language, currency, accessibility settings | SharedPreferences |
| **Session-shared** | NotifierProvider | Search results, filter state, business data | In-memory |
| **API-dependent** | AsyncNotifierProvider | Filter hierarchy, exchange rates | In-memory + API |
| **Page-local UI** | ConsumerStatefulWidget local state | Loading flags, TextControllers, ScrollControllers | Widget State |

### Provider Catalog (Quick Reference)

| Provider | Purpose | State Type | Persistence |
|----------|---------|------------|-------------|
| **accessibilityProvider** | Bold text, font scale | AccessibilityState | SharedPreferences |
| **analyticsProvider** | Analytics state, menu session tracking | AnalyticsState | In-memory |
| **translationsCacheProvider** | UI translations (td keys) | Map<String, String> | API-loaded |
| **localeProvider** | Current app language (triggers MaterialApp rebuild) | Locale | SharedPreferences |
| **localizationProvider** | Currency, exchange rate | LocalizationState | SharedPreferences + API |
| **locationProvider** | Location permission status | LocationState | In-memory |
| **searchStateProvider** | Search results, filters, refinement tracking | SearchState | In-memory |
| **filterProvider** | Filter hierarchy, lookup map, foodDrinkTypes | FilterState | API-loaded |
| **businessProvider** | Business profile, dietary filters | BusinessState | In-memory |

**Full details:** See `_reference/PROVIDERS_REFERENCE.md` (726 lines)

### Riverpod 3.x Patterns (No Code Generation)

#### NotifierProvider (Synchronous State)

```dart
// Definition
final accessibilityProvider =
  NotifierProvider<AccessibilityNotifier, AccessibilityState>(() {
    return AccessibilityNotifier();
  });

// Notifier Class
class AccessibilityNotifier extends Notifier<AccessibilityState> {
  @override
  AccessibilityState build() => AccessibilityState.initial();

  Future<void> setBoldText(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_bold_text_enabled', enabled);
    state = state.copyWith(isBoldTextEnabled: enabled);
  }
}

// Usage in widgets
final accessibilityState = ref.watch(accessibilityProvider);
ref.read(accessibilityProvider.notifier).setBoldText(true);
```

#### AsyncNotifierProvider (API-Dependent State)

```dart
// Definition
final filterProvider =
  AsyncNotifierProvider<FilterNotifier, FilterState>(() {
    return FilterNotifier();
  });

// Notifier Class
class FilterNotifier extends AsyncNotifier<FilterState> {
  @override
  Future<FilterState> build() async => FilterState.initial();

  Future<void> loadFiltersForLanguage(String languageCode) async {
    state = const AsyncLoading();
    try {
      final response = await ApiService.instance.getFiltersForSearch(
        languageCode: languageCode,
      );
      state = AsyncData(FilterState(
        filtersForLanguage: response.jsonBody['filters'],
        filterLookupMap: _buildLookupMap(response.jsonBody['filters']),
        foodDrinkTypes: response.jsonBody['foodDrinkTypes'],
      ));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

// Usage in widgets
final filterState = ref.watch(filterProvider);
filterState.when(
  data: (state) => _buildFilterUI(state),
  loading: () => CircularProgressIndicator(),
  error: (e, st) => ErrorWidget(e),
);
```

#### Page-Local State (Not a Provider)

```dart
class SearchPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  // LOCAL STATE (not in provider)
  DateTime? _pageStartTime;
  bool _isLoading = false;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  @override
  void dispose() {
    _trackPageView(); // Fire-and-forget analytics
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WATCH providers for rebuilds
    final searchState = ref.watch(searchStateProvider);

    return Scaffold(...);
  }
}
```

**Key Rule:** If state is only relevant to one page, use local `State` variables. If state is shared across pages or needs persistence, use a `NotifierProvider`.

---

## Widget Patterns

### Self-Contained ConsumerWidget (Preferred Pattern)

**Discovered:** Phase 7, Session #19
**Applies to:** All form widgets, most shared widgets

```dart
// ❌ WRONG: Passing infrastructure props
ContactUsFormWidget(
  width: double.infinity,
  height: MediaQuery.of(context).size.height,
  currentLanguage: Localizations.localeOf(context).languageCode,
  translationsCache: ref.watch(translationsCacheProvider),
)

// ✅ CORRECT: Widget reads everything internally
const ContactUsFormWidget()

// Widget implementation
class ContactUsFormWidget extends ConsumerStatefulWidget {
  const ContactUsFormWidget({super.key}); // ← No props!

  @override
  ConsumerState<ContactUsFormWidget> createState() =>
    _ContactUsFormWidgetState();
}

class _ContactUsFormWidgetState extends ConsumerState<ContactUsFormWidget> {
  @override
  Widget build(BuildContext context) {
    // Read language internally
    final languageCode = Localizations.localeOf(context).languageCode;

    // Read translations internally
    final translationsCache = ref.watch(translationsCacheProvider);

    // Use for all form logic...
  }
}
```

**Benefits:**
- ✅ Zero prop drilling (widgets read directly from providers/context)
- ✅ Cleaner wrapper pages (no boilerplate prop passing)
- ✅ Better encapsulation (widget owns all its dependencies)
- ✅ Easier testing (no need to mock props)

### Page Wrapper Pattern (For Self-Contained Widgets)

```dart
class ContactUsPage extends ConsumerStatefulWidget {
  const ContactUsPage({super.key});

  @override
  ConsumerState<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends ConsumerState<ContactUsPage> {
  DateTime? _pageStartTime;

  @override
  void initState() {
    super.initState();
    _pageStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _trackPageView(); // Fire-and-forget analytics
    super.dispose();
  }

  void _trackPageView() {
    if (_pageStartTime == null) return;
    final duration = DateTime.now().difference(_pageStartTime!);

    ApiService.instance.postAnalytics(
      eventType: 'page_viewed',
      deviceId: AnalyticsService.instance.deviceId ?? '',
      sessionId: AnalyticsService.instance.currentSessionId ?? '',
      userId: AnalyticsService.instance.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'contactUs',
        'durationSeconds': duration.inSeconds,
      },
    ).catchError((_) => ApiCallResponse.failure('Analytics failed'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(td(ref, 'contact_us')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const SingleChildScrollView(
        child: ContactUsFormWidget(), // ← No props!
      ),
    );
  }
}
```

**Page responsibilities:**
1. App bar with back button + title
2. Analytics tracking (page_viewed on dispose with duration)
3. ScrollView wrapper (if widget doesn't handle scrolling)
4. Navigation context (for back button)

### ConsumerWidget vs ConsumerStatefulWidget

```dart
// Use ConsumerWidget for pure display (no local state)
class LanguageSelectorButton extends ConsumerWidget {
  const LanguageSelectorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Text(locale.languageCode);
  }
}

// Use ConsumerStatefulWidget when you need local state
class FilterOverlayWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<FilterOverlayWidget> createState() =>
    _FilterOverlayWidgetState();
}

class _FilterOverlayWidgetState extends ConsumerState<FilterOverlayWidget> {
  // Local state
  int _activeTabIndex = 0;
  List<int> _selectedFilters = [];

  @override
  Widget build(BuildContext context) {
    // Also read from providers
    final filterState = ref.watch(filterProvider);
    ...
  }
}
```

### Bottom Sheet Pattern

```dart
Future<void> _openFilterSheet() async {
  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true, // For large sheets
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.bottomSheet),
            ),
          ),
          child: Column(
            children: [
              _buildSheetHandle(), // Swipe indicator
              Expanded(child: FilterOverlayWidget(...)),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildSheetHandle() {
  return Container(
    margin: EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: AppColors.border,
      borderRadius: BorderRadius.circular(2),
    ),
  );
}
```

---

## API Service Pattern

All backend calls go through `ApiService.instance` singleton.

**File:** `journey_mate/lib/services/api_service.dart` (352 lines)

### Architecture

- **Singleton:** `ApiService.instance`
- **Base URL:** `https://wvb8ww.buildship.run`
- **Response Wrapper:** `ApiCallResponse(statusCode, jsonBody, error)`
- **Built-in Caching:** GET requests cached by URI (opt-in with `cache: true`)
- **13 Endpoints:** All BuildShip operations documented in `_reference/BUILDSHIP_API_REFERENCE.md`

### Usage Pattern

```dart
// In pages or providers
final response = await ApiService.instance.search(
  filters: [1, 2, 3],
  filtersUsedForSearch: [1, 2, 3],
  cityId: '17',
  searchQuery: 'pizza',
  sortOption: 'rating',
  userLocation: '55.6761,12.5683',
  languageCode: 'da',
);

if (response.statusCode == 200 && response.jsonBody != null) {
  final searchResults = response.jsonBody['documents'];
  final count = response.jsonBody['count'];
  // Update state...
} else {
  // Handle error...
}
```

### Cache Management

```dart
// Caching is automatic for GET requests
final response1 = await ApiService.instance.getBusinessProfile(
  businessId: 123,
  languageCode: 'da',
); // Fetches from API

final response2 = await ApiService.instance.getBusinessProfile(
  businessId: 123,
  languageCode: 'da',
); // Returns cached response

// Manual cache invalidation
ApiService.instance.clearCache(); // Clears all cached responses
```

**Full API contracts:** See `_reference/BUILDSHIP_API_REFERENCE.md` (523 lines)

---

## Pre-Loading Architecture

JourneyMate uses **pre-loading** to make the Search page feel instant. Search results are fetched on previous pages (Welcome, Settings, App Setup Flow), stored in global state, then displayed immediately when Search page loads.

### Pattern

```
┌─────────────────────────────────────────────────────────────┐
│ Welcome/Settings/Setup Page                                  │
│   ↓                                                          │
│ User triggers action (Continue, language change, etc.)      │
│   ↓                                                          │
│ Save notifier = ref.read(searchStateProvider.notifier)      │ ← CRITICAL: Before async
│   ↓                                                          │
│ Navigate to Search Page immediately                         │
│   ↓                                                          │
│ Background: await ApiService.instance.search(...)           │ ← Widget unmounts here
│   ↓                                                          │
│ searchNotifier.updateSearchResults(...)                     │ ← Still works!
│   └──> Updates GLOBAL searchStateProvider                   │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│ Search Page (loads)                                          │
│   ↓                                                          │
│ ref.watch(searchStateProvider)                              │ ← Reads global state
│   ↓                                                          │
│ Shows results OR shimmer if still loading                   │
└─────────────────────────────────────────────────────────────┘
```

### Implementation

**Pages that pre-load:**
- `welcome_page.dart` - 3 functions (returning users, Danish direct, background fetch)
- `settings_main_page.dart` - 1 function (entering settings)
- `app_settings_initiate_flow_page.dart` - 1 function (language selection)

**Safe async pattern:**
```dart
Future<void> _preFetchSearchResults() async {
  try {
    // 1. Save notifier BEFORE async operations
    final searchNotifier = ref.read(searchStateProvider.notifier);

    // 2. Check if cache is fresh (avoid redundant calls)
    if (searchNotifier.isCacheFresh()) {
      return;
    }

    // 3. Optional: Get user location (async)
    final position = await Geolocator.getCurrentPosition(...);

    // 4. Call search API (async)
    final response = await ApiService.instance.search(...);

    // 5. Update global state with saved notifier
    //    Safe even if widget unmounted during steps 3-4
    if (response.succeeded) {
      searchNotifier.updateSearchResults(
        response.jsonBody,
        response.jsonBody['resultCount'],
      );
    }
  } catch (e) {
    // Fail silently - Search page will show shimmer
  }
}
```

**Key rules:**
1. ✅ Save notifier with `ref.read()` BEFORE any `await`
2. ✅ Use saved notifier variable, NOT `ref.read()` again after async
3. ✅ Store in `searchStateProvider` (global state, persists across pages)
4. ✅ Check `isCacheFresh()` to avoid redundant API calls
5. ✅ Fail silently - Search page handles loading/error states

**Why it works:** `searchStateProvider` is a `NotifierProvider` (global app-level state, like FFAppState in FlutterFlow). Updating it from a saved notifier reference works even after the originating widget unmounts.

---

## Translation System

### Dynamic Translation Function: td(ref, key)

```dart
// In any ConsumerWidget or ConsumerStatefulWidget
Text(td(ref, 'search_placeholder'))
Text(td(ref, 'sort_match'))
TextField(
  decoration: InputDecoration(
    hintText: td(ref, 'search_by_name_or_cuisine'),
  ),
)
```

### Implementation

**File:** `journey_mate/lib/services/translation_service.dart` (40 lines)

```dart
String td(WidgetRef ref, String key) {
  final cache = ref.watch(translationsCacheProvider);
  final text = cache[key];

  if (text == null) {
    debugPrint('⚠️ td: Missing dynamic key "$key"');
    return key; // Fallback to key name
  }
  return text;
}
```

### Loading Translations

Translations are loaded at app startup in `main.dart`:

```dart
// Load translations for stored language
await container.read(translationsCacheProvider.notifier)
    .loadTranslations(storedLanguage);
```

When language changes, translations reload and entire app rebuilds via `localeProvider`:

```dart
// User changes language
ref.read(localeProvider.notifier).setLocale('da');
// MaterialApp rebuilds with new locale
// Translations reload automatically
// All td(ref, key) calls return new language text
```

### Translation Stats

- **355 app keys** (search, business profile, menu, settings, etc.)
- **142 legacy keys** (from FlutterFlow migration, will be retired)
- **7 languages:** en (English), da (Danish), de (German), fr (French), it (Italian), no (Norwegian), sv (Swedish)
- **Storage:** Supabase `ui_translations` table
- **API:** BuildShip `GET /languageText` endpoint

---

## Design Token System

**Full reference:** See `DESIGN_SYSTEM_flutter.md` (683 lines)

### Quick Lookup Tables

#### AppColors (30 constants)

| Category | Constant | Hex | Usage |
|----------|----------|-----|-------|
| **Primary** | `accent` | `#e8751a` | CTAs, interactive elements, brand |
| | `green` | `#1a9456` | Match confirmation (never CTAs) |
| | `red` | `#c9403a` | Errors, closed status |
| **Text** | `textPrimary` | `#0f0f0f` | Headings, labels |
| | `textSecondary` | `#333333` | Body text |
| | `textTertiary` | `#888888` | Hints |
| **UI** | `bgPage` | `#ffffff` | Page background |
| | `bgCard` | `#ffffff` | Card background |
| | `border` | `#e8e8e8` | Default borders |
| **Match Status** | `greenBg` | `#f0f9f3` | Full-match card bg |
| | `greenBorder` | `#d0ecd8` | Full-match card border |
| | `orangeBg` | `#fef8f2` | Partial-match card bg |
| | `orangeBorder` | `#f0dcc8` | Partial-match card border |

**Critical Rules:**
- Orange (`#e8751a`) ONLY for CTAs/interactive elements (never match status)
- Green (`#1a9456`) ONLY for match confirmation (never CTAs)

#### AppSpacing (8 constants)

| Constant | Value | Usage |
|----------|-------|-------|
| `xs` | 4px | Minimal spacing |
| `sm` | 8px | Label to input, between paragraphs |
| `md` | 12px | Between chips |
| `lg` | 16px | Standard spacing |
| `xl` | 20px | Between form fields |
| `xxl` | 24px | Page padding |
| `xxxl` | 32px | Section spacing |
| `huge` | 40px | Major section spacing |

#### AppTypography (14 text styles)

| Constant | Size | Weight | Usage |
|----------|------|--------|-------|
| `pageTitle` | 26px | w800 | Page headings |
| `sectionTitle` | 20px | w700 | Section headings |
| `cardTitle` | 18px | w600 | Card headings |
| `bodyLarge` | 18px | w400 | Large body text |
| `bodyRegular` | 16px | w400 | Standard body text |
| `bodySmall` | 14px | w400 | Small body text |
| `labelLarge` | 16px | w600 | Large labels |
| `labelMedium` | 14px | w600 | Standard labels |
| `labelSmall` | 12px | w600 | Small labels |

#### AppRadius (7 constants)

| Constant | Value | Usage |
|----------|-------|-------|
| `card` | 16px | Restaurant cards |
| `button` | 12px | Buttons |
| `chip` | 20px | Filter chips |
| `input` | 8px | Input fields |
| `bottomSheet` | 22px | Bottom sheet top corners |

---

## Analytics Architecture

### AnalyticsService Singleton

**File:** `journey_mate/lib/services/analytics_service.dart` (469 lines)

```dart
// Singleton instance
final analytics = AnalyticsService.instance;

// Properties
analytics.deviceId         // UUID stored in SharedPreferences
analytics.currentSessionId // UUID, 30-minute timeout
analytics.userId           // Empty string (no auth yet)

// Engagement tracker
analytics.engagementTracker.markUserActive() // Called by ActivityScope
```

### ActivityScope (Automatic Engagement Tracking)

**File:** `journey_mate/lib/widgets/activity_scope.dart`

Wraps entire app in `main.dart`:

```dart
ActivityScope(
  child: MaterialApp.router(
    routerConfig: appRouter,
    ...
  ),
)
```

**How it works:**
- Wraps app in `Listener` widget
- Captures ALL pointer events: down, move, scroll
- Calls `AnalyticsService.instance.engagementTracker.markUserActive()` automatically
- No manual tracking needed anywhere in the app

**Migration Rule (Phase 7):**
- ✅ REMOVE all `markUserEngaged()` calls from FlutterFlow source
- ✅ REMOVE the import: `import '/custom_code/actions/mark_user_engaged.dart'`
- ✅ DO NOT REPLACE with anything — ActivityScope handles it automatically

### Fire-and-Forget Pattern

```dart
// NEVER await analytics calls
ApiService.instance.postAnalytics(
  eventType: 'page_viewed',
  deviceId: analytics.deviceId ?? '',
  sessionId: analytics.currentSessionId ?? '',
  userId: analytics.userId ?? '',
  timestamp: DateTime.now().toIso8601String(),
  eventData: {
    'pageName': 'searchPage',
    'durationSeconds': duration.inSeconds,
  },
).catchError((_) => ApiCallResponse.failure('Analytics failed'));
// ← No await, no error handling beyond catchError
```

**Why:** User experience is never blocked by analytics. Data loss is acceptable, UX responsiveness is not.

### Event Types (36 total)

See `_reference/BUILDSHIP_API_REFERENCE.md` for full list. Common events:
- `page_viewed` — Page visit with duration
- `search_executed` — Search performed
- `filter_applied` — Filter selection changed
- `business_card_clicked` — Restaurant card tapped
- `menu_item_clicked` — Menu item expanded
- `language_changed` — Language switched

---

## Code Quality Standards

### Flutter Analyze (Non-Negotiable)

```bash
cd journey_mate
flutter analyze
```

**Required:** `No issues found!` (0 errors, 0 warnings)

**Info-level messages acceptable** when code is demonstrably correct (e.g., `unused_element` for complex algorithms copied from FlutterFlow).

### Design Token Adherence (Non-Negotiable)

- **All colors** from `AppColors` — no raw hex strings (`Color(0xFF...)`)
- **All spacing** from `AppSpacing` — no magic numbers (`16.0`)
- **All text styles** from `AppTypography` — no inline `TextStyle(...)`
- **All radii** from `AppRadius` — no `BorderRadius.circular(16)`

**Exception:** Extremely specific one-off values can use magic numbers with explanatory comments.

### Preserve Complex Algorithms

When migrating from FlutterFlow, preserve complex algorithms even if analyzer suggests refactoring:

```dart
// Preserve FlutterFlow's street/neighborhood length algorithm
// (Complex substring logic for address truncation)
static String streetAndNeighbourhoodLength(
  String? street,
  String? neighbourhood,
) {
  // ... 50 lines of FlutterFlow logic ...
  // DO NOT REFACTOR unless you fully understand edge cases
}
```

**Why:** FlutterFlow algorithms have been tested with real data. Refactoring risks bugs.

---

## Common Pitfalls

### Pitfall #1: Using Raw Hex Colors
❌ **Bad:**
```dart
color: Color(0xFFe8751a)
```
✅ **Good:**
```dart
color: AppColors.accent
```

### Pitfall #2: Using Magic Number Spacing
❌ **Bad:**
```dart
padding: EdgeInsets.all(16.0)
```
✅ **Good:**
```dart
padding: EdgeInsets.all(AppSpacing.lg)
```

### Pitfall #3: Using MaterialStateProperty (Deprecated)
❌ **Bad:**
```dart
MaterialStateProperty.all(Colors.white)
```
✅ **Good:**
```dart
WidgetStateProperty.all(Colors.white)
```

### Pitfall #4: Using .withOpacity() (Deprecated)
❌ **Bad:**
```dart
AppColors.accent.withOpacity(0.5)
```
✅ **Good:**
```dart
AppColors.accent.withValues(alpha: 0.5)
```

### Pitfall #5: Using mounted After Async (Incorrect)
❌ **Bad:**
```dart
await someAsyncOperation();
if (mounted) {
  setState(() { ... });
}
```
✅ **Good:**
```dart
await someAsyncOperation();
if (context.mounted) {
  setState(() { ... });
}
```

### Pitfall #6: Forcing ConsumerWidget When Not Needed
❌ **Bad:**
```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No ref.watch() or ref.read() anywhere in entire widget
    return Text('Hello');
  }
}
```
✅ **Good:**
```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello');
  }
}
```

### Pitfall #7: Not Running flutter analyze Before Committing
❌ **Bad:** Commit without checking
✅ **Good:**
```bash
cd journey_mate
flutter analyze  # Must return "No issues found!"
git add .
git commit -m "feat: add new widget"
```

### Pitfall #8: Passing Infrastructure Props to Self-Contained Widgets
❌ **Bad:**
```dart
ContactUsFormWidget(
  width: double.infinity,
  currentLanguage: Localizations.localeOf(context).languageCode,
  translationsCache: ref.watch(translationsCacheProvider),
)
```
✅ **Good:**
```dart
const ContactUsFormWidget() // Widget reads everything internally
```

### Pitfall #9: Awaiting Analytics Calls
❌ **Bad:**
```dart
await ApiService.instance.postAnalytics(...);
// UI blocked until analytics completes!
```
✅ **Good:**
```dart
ApiService.instance.postAnalytics(...)
    .catchError((_) => ApiCallResponse.failure('Analytics failed'));
// Fire-and-forget, UI never blocked
```

### Pitfall #10: Manually Calling markUserEngaged()
❌ **Bad:**
```dart
import '/custom_code/actions/mark_user_engaged.dart';

Future<void> onButtonTap() async {
  await markUserEngaged(); // ← Manual call
  // ... actual logic
}
```
✅ **Good:**
```dart
Future<void> onButtonTap() async {
  // ... actual logic
  // ActivityScope handles engagement tracking automatically
}
```

### Pitfall #11: Using ref After Async Operations (Widget Might Unmount)
❌ **Bad:**
```dart
Future<void> _fetchSearchResults() async {
  // Start async operation
  final response = await ApiService.instance.search(...);

  // ⚠️ DANGER: Widget might have unmounted during await
  ref.read(searchStateProvider.notifier).updateSearchResults(...);
  // Error: "Using ref when widget is unmounted is unsafe"
}
```

✅ **Good:**
```dart
Future<void> _fetchSearchResults() async {
  // Save notifier BEFORE any async operations
  final searchNotifier = ref.read(searchStateProvider.notifier);

  // Async operations can now happen safely
  final response = await ApiService.instance.search(...);

  // Use saved notifier (safe even if widget unmounted)
  searchNotifier.updateSearchResults(...);
}
```

**Why:** When a widget unmounts (user navigates away, parent rebuilds), `ref` becomes invalid because it relies on `BuildContext`. Saving the notifier before async operations captures a reference that remains safe even after unmount.

**Common in:** Pre-loading pages (Welcome, Settings, App Setup Flow) that fetch search results before navigating to Search page.

---

## Documentation Philosophy

JourneyMate maintains **three types of documentation**:

### 1. Guidance Documents (Git-tracked)
**Purpose:** Explain how to build
**Files:** CLAUDE.md, ARCHITECTURE.md (this file), DESIGN_SYSTEM_flutter.md, CONTRIBUTING.md
**Update when:** Architecture changes, new patterns discovered, workflow changes

### 2. Reference Documents (Git-tracked)
**Purpose:** Canonical truth for APIs, providers, state
**Files:** `_reference/BUILDSHIP_API_REFERENCE.md`, `_reference/PROVIDERS_REFERENCE.md`
**Update when:** API contracts change, providers added/modified

### 3. Historical Documents (Local-only, NOT in Git)
**Purpose:** Understand "why was this built this way?"
**Files:** `pages/*/BUNDLE.md`, `shared/*/MASTER_README_*.md` (207 files)
**Update when:** NEVER (read-only reference from migration phase)

**Key Rule:** If you need to understand why a page works a certain way, read the BUNDLE.md. If you need to build something new, read ARCHITECTURE.md and PROVIDERS_REFERENCE.md.

---

## Provider Initialization Order (Critical)

**File:** `journey_mate/lib/main.dart` (170 lines)

Providers MUST initialize in this exact order at app startup:

```dart
1. AnalyticsService.initialize()     // Device ID first
2. ProviderContainer()                // Create container
3. analyticsProvider.initialize()     // Analytics notifier
4. accessibilityProvider.load()       // Accessibility settings
5. localeProvider.initialize()        // Load language preference
6. localizationProvider.load()        // Load currency preference
7. translationsCacheProvider.load()   // Load translations (3 retries, 2s delay)
8. filterProvider.load()              // Load filters (parallel with translations)
9. locationProvider.checkPermission() // Check location permission
10. AppLifecycleObserver.register()   // Hook app lifecycle
11. UncontrolledProviderScope(...)    // Wrap app with container
12. ActivityScope(...)                // Wrap with engagement tracking
```

**Retry Logic:** Translations and filters retry 3 times with 2-second delays (handles early network unavailability).

**Error Handling:** If startup fails, shows error screen with "Retry" button instead of broken app.

---

## Key Architectural Decisions

### CityID is Always 17 (Copenhagen)
- No city switching UI in v1
- Use `AppConstants.kDefaultCityId` constant
- Pass directly to API calls, no provider needed

### No Favorite Feature
- `restaurantIsFavorited` is a future feature
- Don't build favorite button, state, or UI
- Remove any FlutterFlow references to favorites

### Filter Panel is Bottom Sheet (Not Inline Overlay)
- FlutterFlow uses 3-column inline overlay with `filterOverlayOpen` state
- New design uses `showModalBottomSheet` instead
- Tab selection is local state in bottom sheet widget

### Translation: 100% Supabase (0% Hardcoded)
- Ultimate goal: zero hardcoded translations
- All text from Supabase `ui_translations` table
- Single source of truth for all 7 languages
- Content team controls all text without app releases

### Portrait-Only iPhone, All Orientations iPad
- iPhone locked to portrait (optimal UX for vertical scrolling)
- iPad supports all orientations (table/counter browsing)
- Landscape rarely adds value for restaurant discovery

### ActivityScope Handles Engagement (Never Manual Calls)
- FlutterFlow uses manual `markUserEngaged()` calls in 44+ files
- New app uses ActivityScope widget wrapping entire app
- Automatically detects ALL interactions (tap, scroll, keyboard, navigation)
- Migration rule: REMOVE all `markUserEngaged()` calls, DO NOT REPLACE

---

## References

- **API Contracts:** `_reference/BUILDSHIP_API_REFERENCE.md` (523 lines, 12 endpoints)
- **Provider Catalog:** `_reference/PROVIDERS_REFERENCE.md` (726 lines, 8 providers)
- **Design Tokens:** `DESIGN_SYSTEM_flutter.md` (683 lines, colors/spacing/typography)
- **Quick Start:** `CLAUDE.md` (streamlined session primer)
- **Developer Onboarding:** `CONTRIBUTING.md` (workflow and standards)
- **Migration History:** `_reference/archive/MIGRATION_STATUS.md` (Phase 1-7 archived)
- **Pattern Discovery:** `_reference/archive/PHASE7_PATTERNS.md` (Session logs archived)

---

**Last Updated:** February 2026
**Maintainer:** Development team
**Questions?** Read this file first, then check reference docs, then ask.
