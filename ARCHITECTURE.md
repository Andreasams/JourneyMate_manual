# JourneyMate Architecture Guide

**Version:** 1.0
**Last Updated:** March 2026
**Project Phase:** Maintenance & Debugging (Phase 8)
**App Status:** Live on TestFlight

---

## Purpose

This document explains **how the JourneyMate app is built**. Read this to understand the architectural patterns, state management approach, widget conventions, and code quality standards that ensure all future development maintains consistency.

**Quick Navigation:**
- **Working on a specific task?** See **CLAUDE.md → Task-Based Navigation Guide** (12 scenarios with 10-30 minute targeted reading lists)
- **New to the project?** Read [Philosophy](#philosophy) (lines 39-81) and [State Management](#state-management) (lines 146-285) for 60-minute deep dive
- **Need a specific section?** Use alphabetical index below for direct access

**Section Index (Alphabetical):**
- [Analytics Architecture](#analytics-architecture) (lines 1833-1907) — Fire-and-forget, ActivityScope, 47 event types
- [API Service Pattern](#api-service-pattern) (lines 1376-1510) — Singleton, cache, BuildShip integration, graceful degradation, BusinessCache
- [Code Quality Standards](#code-quality-standards) (lines 1910-2029) — Flutter analyze, design tokens, algorithms
- [Code Review Checklist](#code-review-checklist) (lines 2032-2126) — Pre-commit checklist (⚠️ use before every commit)
- [Common Pitfalls](#common-pitfalls) (lines 2129-3487) — 34 anti-patterns with fixes (⚠️ read before first commit)
- [Design Token System](#design-token-system) (lines 1820-1830) — Quick lookup tables for colors, spacing, typography
- [Documentation Philosophy](#documentation-philosophy) (lines 3490-3503) — Three types of docs, when to update
- [Key Architectural Decisions](#key-architectural-decisions) (lines 3533-3566) — CityID, favorites, filters, translations, engagement
- [Location Permission Pattern](#location-permission-pattern) (lines 1593-1671) — Three methods, when to use what, Settings fallback
- [Philosophy](#philosophy) (lines 39-81) — Five core principles (design tokens, state, translations, analytics, widgets)
- [Pre-Loading Architecture](#pre-loading-architecture) (lines 1513-1590) — Safe async pattern for instant page loads
- [Project Structure](#project-structure) (lines 86-151) — File organization, 12 pages, 34 widgets, 8 providers
- [Provider Initialization Order](#provider-initialization-order) (lines 3506-3530) — Critical startup sequence in main.dart
- [References](#references) (lines 3569-3577) — Links to other documentation files
- [State Management](#state-management) (lines 154-351) — When to use what, provider catalog, Riverpod 3.x patterns, ref.listen
- [Swipe Gesture Patterns](#swipe-gesture-patterns) (lines 1028-1373) — 8 patterns for dismissible UI, adaptive thresholds, nested gestures
- [Translation System](#translation-system) (lines 1674-1817) — Dynamic td() function, 344 keys, 4-step fallback chain, 15 languages
- [Widget Patterns](#widget-patterns) (lines 354-1025) — Self-contained widgets, page wrappers, bottom sheets, BottomSheetHeader, contact utils, cross-page reuse, MenuSectionWidget, TabbedGalleryWidget, MenuScrollController, map view

---

## Philosophy

JourneyMate was migrated from FlutterFlow to production Flutter with five core architectural principles:

### 1. Design Token Adherence (Visual Consistency)
- **All colors** from `AppColors` — no raw hex strings
- **All spacing** from `AppSpacing` — no magic pixel numbers
- **All typography** from `AppTypography` — no inline `TextStyle`
- **All radii** from `AppRadius` — no hardcoded border radius values

**Why:** Ensures visual consistency across 12 pages and 35 shared widgets. Design changes propagate automatically.

### 2. Riverpod 3.x State Management (Predictable State)
- **NotifierProvider** for global and session state
- **AsyncNotifierProvider** for API-dependent state
- **Local State** in `ConsumerStatefulWidget` for page-specific UI state
- **No code generation** — all providers hand-written

**Why:** Single source of truth for app state. No FFAppState, no Provider, no confusion.

### 3. Single Source of Truth for Translations (Maintainability)
- **100% dynamic** from Supabase `ui_translations` table via BuildShip API
- **344 app keys** in Supabase (0 legacy keys remaining)
- **15 languages** in Supabase, **7 fallback languages** hardcoded in app (en, da, de, fr, it, no, sv)
- **Zero hardcoded strings** in production code

**Why:** Translations update without app releases. Content team controls all text.

### 4. Fire-and-Forget Analytics (Never Block UI)
- **AnalyticsService** singleton manages all tracking
- **ActivityScope** wraps app for automatic engagement detection
- **Never await** analytics calls — fire-and-forget with `.catchError()`
- **47 event types** tracked to Supabase via BuildShip

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
│   ├── services/                      # Singletons + shared utilities
│   │   ├── api_service.dart           # BuildShip REST API client (352 lines)
│   │   ├── analytics_service.dart     # Analytics + EngagementTracker (469 lines)
│   │   ├── translation_service.dart   # td(ref, key) helper function
│   │   └── custom_functions/          # Shared formatting utilities (ported from FlutterFlow)
│   │       ├── address_formatter.dart # streetAndNeighbourhoodLength()
│   │       ├── business_status.dart   # determineStatusAndColor()
│   │       ├── distance_calculator.dart # returnDistance() + formatDistanceText()
│   │       ├── hours_formatter.dart   # openClosesAt(), daysDayOpeningHour()
│   │       └── price_formatter.dart   # convertAndFormatPriceRange()
│   ├── models/                        # Data classes
│   │   ├── latlng.dart                # Location coordinates
│   │   └── api_call_response.dart     # API response wrapper
│   ├── pages/                         # 12 app pages (folder-per-page pattern)
│   │   ├── search/
│   │   │   └── search_page.dart       # Main restaurant discovery
│   │   ├── business_profile/
│   │   │   ├── business_profile_page.dart # Restaurant details (v1)
│   │   │   └── business_profile_page_v2.dart # Restaurant details (v2)
│   │   ├── menu_full_page/
│   │   │   └── menu_full_page.dart    # Dietary filtering
│   │   ├── gallery_full_page/
│   │   │   └── gallery_full_page.dart # Image gallery
│   │   ├── business_information/
│   │   │   └── business_information_page.dart # About restaurant
│   │   ├── welcome/
│   │   │   └── welcome_page.dart      # Onboarding
│   │   ├── app_settings_initiate_flow/
│   │   │   └── app_settings_initiate_flow_page.dart # Initial language selection
│   │   └── settings/                  # Settings pages (5 sub-pages)
│   │       ├── settings_main_page.dart # Settings hub
│   │       ├── localization_page.dart # Language/currency
│   │       ├── contact_us_page.dart   # Contact form wrapper
│   │       ├── share_feedback_page.dart # Feedback form wrapper
│   │       └── missing_place_page.dart # Missing place form wrapper
│   ├── widgets/                       # 35 shared widgets
│   │   ├── shared/                    # Reusable components
│   │   ├── activity_scope.dart        # Automatic engagement tracking
│   │   └── app_lifecycle_observer.dart # App state lifecycle hooks
│   ├── theme/                         # Design tokens (source of truth)
│   │   ├── app_colors.dart            # 30 color constants
│   │   ├── app_spacing.dart           # 8 spacing constants
│   │   ├── app_typography.dart        # 17 text styles
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

### Atomic State Updates for Dependent Fields

When multiple state fields depend on each other, update them together in a single provider method call. Separate `state = state.copyWith(...)` calls create stale-state windows where consumers see inconsistent values between frames.

```dart
// Inside searchStateProvider notifier:
void updateSearchResults({
  required List<Map<String, dynamic>> normalizedResults,
  required int fullMatchCount,
  required List<int> scoringFilterIds,
}) {
  // All dependent fields update atomically — consumers never see partial state
  state = state.copyWith(
    normalizedResults: normalizedResults,
    fullMatchCount: fullMatchCount,
    scoringFilterIds: scoringFilterIds,
    visibleResultCount: scoringFilterIds.isNotEmpty
        ? fullMatchCount
        : normalizedResults.length,
  );
}
```

**Why:** `visibleResultCount` depends on both `fullMatchCount` and `scoringFilterIds`. If updated separately, the Open Now badge and page title could briefly show a count from the previous search while new results are already visible.

**Rule:** If field B is derived from fields A and C, always update A, B, and C in the same `copyWith()` call.

**Git reference:** Commits `e48e0cf`, `5eba0e4` — fix: use full-match count for Open Now badge

### ref.listen for Async Data Reactivity

When a widget mounts before its provider has data (e.g., menu page opens before menu API responds), use `ref.listen()` to react to state transitions:

```dart
@override
Widget build(BuildContext context) {
  // ref.watch handles display — shows loading/data/error
  final businessState = ref.watch(businessProvider);

  // ref.listen handles side effects on data arrival
  ref.listen(businessProvider, (previous, next) {
    if (previous?.menuItems == null && next.menuItems != null) {
      // Menu data just arrived — trigger dependent operations
      _onMenuDataLoaded(next.menuItems);
    }
  });

  return _buildContent(businessState);
}
```

**When to use which:**
- `ref.watch()` — Reactive display (rebuilds widget when state changes)
- `ref.listen()` — Side effects on state transitions (one-time actions when data arrives)
- `ref.read()` — Fire-and-forget actions (button taps, analytics, never in `build()`)

**Reference:** Commit `5eae0ca` — MenuDishesListView reacts to menu data arriving after mount

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

### Cross-Page Widget Reuse Pattern

When two pages display the same business data section, extract it to a shared widget rather than duplicating computation logic.

**Example:** Business information page and business profile page both show hero section, opening hours, and contact info. Rather than duplicating status computation (open/closed, hours formatting) in both pages:

```dart
// SHARED: lib/widgets/shared/business_profile/hero_section_widget.dart
class HeroSectionWidget extends ConsumerWidget {
  final Map<String, dynamic> businessData;
  const HeroSectionWidget({required this.businessData, super.key});
  // Self-contained — computes status, reads translations internally
}

// Used in business_profile_page_v2.dart AND business_information_page.dart
HeroSectionWidget(businessData: businessInfo)
```

**Rule:** If two pages display the same business data section, extract to shared widget. Don't duplicate status computation logic across pages.

**Reference:** Commit `9e75f0f` — business information page restructured to reuse profile widgets (removed ~130 lines of duplicated logic)

### Shared Utility Functions Pattern

When multiple widgets need the same formatting or validation logic, extract to a shared utility file rather than duplicating across widgets.

**File:** `journey_mate/lib/services/custom_functions/contact_utils.dart`

```dart
/// Formats a phone number for dialing by stripping non-digits and prepending +45.
/// "33 11 68 68" → "+4533116868"
/// "+45 33 11 68 68" → "+4533116868" (no double prefix)
String formatPhoneForDial(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
  if (digits.startsWith('45') && digits.length > 8) {
    return '+$digits';
  }
  return '+45$digits';
}

/// Ensures a URL has an https:// protocol prefix.
String ensureHttpsUrl(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return 'https://$url';
}
```

**Used by:** `quick_actions_pills_widget.dart`, `opening_hours_contact_widget.dart`, `contact_details_widget.dart`

**Reference:** Commit `932e351` — extracted shared contact utilities from duplicated widget logic

### MenuSectionWidget — Shared Menu Section

**File:** `journey_mate/lib/widgets/shared/menu_section_widget.dart` (~330 lines)

Consolidated menu section logic used by both `InlineMenuWidget` (business profile) and `MenuFullPage`. Eliminated ~580 lines of duplication.

| Consumer | Before | After |
|----------|--------|-------|
| `InlineMenuWidget` | 371 lines | 74 lines (thin wrapper + "View full page" link) |
| `MenuFullPage` | 436 lines | 153 lines (Scaffold/AppBar + analytics + shared widget) |

**Key unification:**
- Filter toggle (show/hide) instead of always-visible
- Dynamic 1-2 category rows (42/72px) instead of fixed single row (40px)
- `GestureDetector` + `viewInsets` padding on all bottom sheets
- Consistent horizontal padding (`AppSpacing.xxl`)

**Bug fixes discovered during extraction:**
- Description sheet keys: used snake_case/short names, but `MenuDishesListView` sends camelCase (`categoryName`/`categoryDescription`)
- Currency code: inline was hardcoded to `'DKK'`, now reads from business data
- Analytics double-counting: `MenuFullPage` duplicated item/package/category tracking already handled by `MenuDishesListView`

**Reference:** Commit `51e2b58`

### TabbedGalleryWidget — Unified Gallery

**File:** `journey_mate/lib/widgets/shared/tabbed_gallery_widget.dart` (~680 lines)

Consolidates `GalleryTabWidget` + `InlineGalleryWidget` (~1200 lines) into a single prop-based widget for both full-page and inline business profile contexts.

**API:** `galleryData`, `onImageTap` (sync void), `limitToEightImages`, `onViewAllTap` (VoidCallback?), `pageName` (analytics context)

**Key fix — tab-jumping bug:** Dropped `TabController`, uses `PageController` + `_targetPage` guard to ignore intermediate `onPageChanged` events during `animateToPage`. Without this guard, jumping across multiple tabs triggers intermediate page change events that override the animation target.

```dart
// _targetPage guard pattern:
// 1. Set _targetPage on tap
// 2. In onPageChanged, ignore if page != _targetPage
// 3. Clear _targetPage when destination reached
```

**Animation:** 450ms duration (up from 300ms) for visible tab transitions. `AnimatedBuilder` on `PageController` provides smooth indicator sliding.

**Reference:** Commit `a348fd4`

### MenuScrollController — Category Chip → Dishes List Communication

**File:** `journey_mate/lib/widgets/shared/menu_dishes_list_view.dart` (controller class defined here)

`ChangeNotifier` that enables `MenuSectionWidget` → `MenuDishesListView` scroll communication. Tapping a category chip scrolls the dishes list to that category header.

```dart
class MenuScrollController extends ChangeNotifier {
  String? _targetCategory;
  String? get targetCategory => _targetCategory;

  void scrollTo(String categoryId) {
    _targetCategory = categoryId;
    notifyListeners();  // Re-tap works (ChangeNotifier doesn't suppress same-value)
  }
}
```

**Why ChangeNotifier over Provider:** Provider-based scroll detection was fundamentally broken — `_getSelectedCategoryId()` always returned 0, so the build-time comparison never triggered a scroll. ChangeNotifier avoids same-value suppression (re-tapping the same chip re-scrolls).

**Lifecycle:** Created in `MenuSectionWidget`, passed to `MenuDishesListView`. Listener attached in `initState`/`didUpdateWidget`, removed in `dispose`.

**Reference:** Commit `05029da`

### Map View with Viewport-Based Geo-Filtering Pattern

Search page supports list/map toggle via page-local `_ViewMode` enum. Each mode uses different parameters:

| | List Mode | Map Mode |
|--|-----------|----------|
| **Page size** | 20 | 200 |
| **Display** | Paginated card list | Google Maps markers |
| **Geo-filtering** | None | Viewport bounds (`geoBoundsJson`) |
| **On interaction** | Load next page | Re-query on pan/zoom |

**Key files:**
- `search_results_map_view.dart` — Google Maps widget with markers
- `map_business_preview_card.dart` — Bottom card shown on marker tap
- `map_marker_helper.dart` — Marker icon generation utilities
- `search_result_helpers.dart` — Shared lat/lng extraction from result documents

**API integration:** Map mode sends `geoBoundsJson` parameter (format: `{"ne_lat":55.72,"ne_lng":12.62,"sw_lat":55.65,"sw_lng":12.50}`) which BuildShip converts to a Typesense geo polygon filter. This is ANDed with all other filters but does NOT affect sort order.

**Reference:** Commit `c545543` — search map view implementation

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
    width: 80,
    height: 4,
    decoration: BoxDecoration(
      color: AppColors.textPrimary,
      borderRadius: BorderRadius.circular(20),
    ),
  );
}
```

### BottomSheetHeader — Shared Bottom Sheet Widget

**File:** `journey_mate/lib/widgets/shared/bottom_sheet_header.dart`

All JourneyMate bottom sheets use a shared `BottomSheetHeader` widget for consistent styling. It renders a swipe bar indicator and optional left/right action buttons, with support for an image background.

**BottomSheetAction data class:**
```dart
class BottomSheetAction {
  const BottomSheetAction({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;
}
```

**Usage — standard close button:**
```dart
BottomSheetHeader(
  rightAction: BottomSheetAction(
    icon: Icons.close,
    onPressed: () => Navigator.of(context).pop(),
  ),
)
```

**Usage — image header with back + close:**
```dart
BottomSheetHeader(
  image: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
  imageHeight: 200.0,
  leftAction: BottomSheetAction(icon: Icons.arrow_back, onPressed: onBack),
  rightAction: BottomSheetAction(icon: Icons.close, onPressed: onClose),
)
```

**Constants (reusable by consuming widgets):**

| Constant | Value | Purpose |
|----------|-------|---------|
| `swipeBarWidth` | 80.0 | Width of the swipe indicator bar |
| `swipeBarHeight` | 4.0 | Height of the swipe indicator bar |
| `swipeBarTopPadding` | 8.0 | Top padding above swipe bar |
| `actionButtonSize` | 40.0 | Size of action buttons (close, back) |
| `actionButtonPosition` | 12.0 | Offset from edges for action buttons |
| `actionIconSize` | 24.0 | Icon size within action buttons |
| `actionButtonBorderRadius` | 20.0 | Corner radius of action buttons |
| `swipeBarBorderRadius` | 20.0 | Corner radius of swipe indicator |

**Static helper — `sheetDecoration()`:**
```dart
// Canonical container decoration for bottom sheets
Container(
  decoration: BottomSheetHeader.sheetDecoration(),
  child: Column(children: [BottomSheetHeader(...), ...]),
)
```

**Reference:** Commit `80ae4b6` — extracted shared BottomSheetHeader from duplicated bottom sheet boilerplate

### Filter Coordination Pattern (Parent Callbacks)

**Discovered:** Commit `8606b21`, March 2026 | **Updated:** Commits `bd1c12f`/`61a7cea` (multi-select)
**Applies to:** Widgets with interdependent filter state (one filter affects another's validity)

When filter selections have dependencies (e.g., neighbourhood filter affects station availability), use parent callbacks to coordinate state:

```dart
// ❌ WRONG: No coordination - UI shows invalid station
FilterOverlayWidget(
  width: MediaQuery.of(context).size.width,
  height: MediaQuery.of(context).size.height,
  // ... other props, but no callbacks
)
// Problem: User selects neighbourhood that doesn't include current station
// Result: Sort button displays station that's not available in filter list

// ✅ CORRECT: Callback notifies parent to check and fix inconsistencies
FilterOverlayWidget(
  width: MediaQuery.of(context).size.width,
  height: MediaQuery.of(context).size.height,
  onNeighbourhoodSelected: () {
    // Check if current station is still valid for the new neighbourhood(s)
    if (_currentSort == 'station' && _selectedStation != null) {
      final searchState = ref.read(searchStateProvider);
      final neighbourhoodIds = searchState.selectedNeighbourhoodId; // List<int>?

      if (neighbourhoodIds != null && neighbourhoodIds.isNotEmpty) {
        // Check if station belongs to any of the selected neighbourhoods
        final filterState = ref.read(filterProvider);
        final isStationInNeighbourhood = filterState.when(
          data: (state) {
            final stationData = state.filterLookupMap[_selectedStation];
            if (stationData != null) {
              final neighbourhoodId1 = stationData['neighbourhood_id_1'] as int?;
              final neighbourhoodId2 = stationData['neighbourhood_id_2'] as int?;
              return neighbourhoodIds.any((nId) =>
                  neighbourhoodId1 == nId || neighbourhoodId2 == nId);
            }
            return false;
          },
          loading: () => true,  // Keep station while loading
          error: (_, __) => true, // Keep station on error
        );

        // Reset to default if station is not in any selected neighbourhood
        if (!isStationInNeighbourhood) {
          setState(() {
            _currentSort = 'nearest';
            _selectedStation = null;
          });
          _executeSearch(searchState.currentSearchText); // Trigger new search
        }
      }
    }
  },
  onShoppingAreaSelected: () {
    // Similar logic for shopping area dependencies
  },
)
```

**When to Use:**
- One filter selection invalidates another filter's current value
- Filter UI needs to stay consistent (don't show unavailable options)
- Parent page holds state that depends on filter selections

**Pattern Benefits:**
- ✅ Prevents UI inconsistencies (sort button showing unavailable station)
- ✅ Automatic state correction (resets to safe default when needed)
- ✅ Uses `.any()` OR logic across all selected neighbourhoods (neighbourhood_id_1 OR neighbourhood_id_2)
- ✅ Handles AsyncData states gracefully (keeps selection while loading)

**Common Use Cases:**
- Neighbourhood filter (multi-select) → affects station list (commits `8606b21`, `bd1c12f`)
- Shopping area filter → affects neighbourhood list
- Cuisine type → affects dish availability
- Date/time selection → affects "Open Now" filter validity

**Reference:**
- `journey_mate/lib/widgets/shared/filter_overlay_widget.dart` — Callback parameters
- `journey_mate/lib/pages/search/search_page.dart` — Callback implementation
- Commit `8606b21` — Auto-clear station sort when filtered out by neighbourhood

---

### Parent-Child Filter Pattern (Hierarchical Filters)

**Discovered:** Commit `a917eee`, March 2026
**Applies to:** Filter types with hierarchical relationships (parent category + specific sub-types)

Some filters have parent-child relationships where selecting a child (specific sub-type) makes the parent (general category) redundant. The app handles this with:
1. **Count deduplication** — Parent+child counts as 1 selection, not 2
2. **Smart chip display** — Hide parent chip, show combined "Parent: Child" chip
3. **Formatting rules** — Lowercase for Bakery children, colon for others

```dart
/// Parent-child filter relationships
/// Bakery (56) → [585, 586]
/// Café (58) → [158, 159]
/// Food truck (55) → [588]
/// Sharing menu (100) → [196-207]
/// Multi-course menu (101) → [184-195]

// ❌ WRONG: Parent and child both count separately
final filterCounts = <int, int>{1: 0, 2: 0, 3: 0};
for (final filterId in activeFilters) {  // [56, 585] → counts as 2
  final titleId = _findTitleIdForFilter(filterId, lookupMap);
  counts[titleId] = (counts[titleId] ?? 0) + 1;
}
// Result: Type filter shows count of 2 (incorrect - double-counts Bakery + With seating)

// ✅ CORRECT: Deduplicate parent+child before counting
final deduplicatedFilters = _deduplicateParentChildCombos(activeFilters);  // [56, 585] → [585]
for (final filterId in deduplicatedFilters) {
  final titleId = _findTitleIdForFilter(filterId, lookupMap);
  counts[titleId] = (counts[titleId] ?? 0) + 1;
}
// Result: Type filter shows count of 1 (correct - combined selection)

List<int> _deduplicateParentChildCombos(List<int> activeFilters) {
  const parentChildRelationships = <int, List<int>>{
    56: [585, 586],        // Bakery → [With seating, With café]
    58: [158, 159],        // Café → [With in-house bakery, In bookstore]
    55: [588],             // Food truck → [Other]
    100: [196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207],  // Sharing menu → 12 courses
    101: [184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195],  // Multi-course menu → 12 courses
  };

  final activeSet = activeFilters.toSet();
  final parentsToRemove = <int>{};

  for (final entry in parentChildRelationships.entries) {
    final parentId = entry.key;
    final childrenIds = entry.value;

    // If parent + ANY child selected, remove parent from count
    if (activeSet.contains(parentId)) {
      final hasChild = childrenIds.any((id) => activeSet.contains(id));
      if (hasChild) parentsToRemove.add(parentId);
    }
  }

  return activeFilters.where((id) => !parentsToRemove.contains(id)).toList();
}
```

**Display Logic: Hide Parent Chips**

```dart
// Hide parent chips when children are selected
final parentsToHide = _findParentsToHide(selectedFilterIds);
final visibleChips = allDisplayIds.where((id) => !parentsToHide.contains(id)).toList();

Set<int> _findParentsToHide(List<int> selectedFilterIds) {
  final parentsToHide = <int>{};
  for (final entry in _parentChildRelationships.entries) {
    final hasChild = entry.value.any((childId) => selectedFilterIds.contains(childId));
    if (hasChild) parentsToHide.add(entry.key);
  }
  return parentsToHide;
}
```

**Formatting Rules:**

```dart
// Bakery children (585, 586) — lowercase format
// "Bakery with seating" (matches dietary composite pattern)
if (_bakeryChildrenIds.contains(filterId) && parentName != null) {
  final lowercasedName = _lowercaseFirstLetter(name);
  return '$parentName $lowercasedName';  // NO colon
}

// All other children — colon format
// "Café: In bookstore", "Sharing menu: 5 courses"
if (_allChildrenIds.contains(filterId) && parentName != null) {
  return '$parentName: $name';  // WITH colon
}
```

**When to Use:**
- Filter hierarchy where parent is redundant when child selected
- Display needs to show context for ambiguous child names
- Count accuracy matters (prevent double-counting)

**Pattern Benefits:**
- ✅ Prevents double-counting parent+child selections
- ✅ Clearer UX (shows combined "Parent: Child" chip instead of two separate chips)
- ✅ Count accuracy across multiple consumers (search_page.dart, filter_titles_row.dart)
- ✅ Consistent formatting rules

**Common Use Cases:**
- Bakery with seating vs plain Bakery
- Café with in-house bakery vs plain Café
- Multi-course menu: 3 courses vs plain Multi-course menu
- Any hierarchical filter where child adds specificity

**Reference:**
- `journey_mate/lib/utils/filter_count_helper.dart` — Count deduplication
- `journey_mate/lib/widgets/shared/selected_filters_btns.dart` — Chip display logic
- Commit `a917eee` — Parent-child display logic with count deduplication

**CRITICAL ORDERING REQUIREMENT:** See Common Pitfall #18 for ordering requirements.

---

### Filter Exclusivity Pattern (_removeConflictingFilters)

**Discovered:** Commit `7f2a95c`, March 2026
**Applies to:** Mutually exclusive filter categories (neighbourhoods, train stations, shopping areas)

Some filter categories are **mutually exclusive** — only one "location anchor" can be active at a time. When selecting a new item from an exclusive category, existing selections from that category must be cleared BEFORE adding the new one.

**Pattern Implementation:**

```dart
// Helper method to remove conflicting filters
void _removeConflictingFilters(List<int> categoryIds) {
  setState(() {
    _selectedFilterIds.removeWhere((id) => categoryIds.contains(_getCategoryId(id)));
  });
}

// Train stations (exclusive) - line 798
void _handleTrainStationSelection(int stationId) {
  _removeConflictingFilters([_trainStationCategoryId]);  // Clear other stations FIRST
  setState(() => _selectedFilterIds.add(stationId));     // Add new station
  _onSearchTriggered();                                  // Trigger search
}

// Shopping areas (exclusive) - line 818
void _handleShoppingAreaSelection(int shoppingAreaId) {
  _removeConflictingFilters([_shoppingAreaCategoryId]);  // Clear other shopping areas FIRST
  setState(() => _selectedFilterIds.add(shoppingAreaId));
  _onSearchTriggered();
}

// Neighbourhoods (exclusive) - line 838
void _handleNeighborhoodSelection(int neighbourhoodId) {
  _removeConflictingFilters([_neighborhoodCategoryId]);  // Clear other neighbourhoods FIRST ✅
  setState(() => _selectedFilterIds.add(neighbourhoodId));
  _onSearchTriggered();
}
```

**Bug Fixed:** Neighbourhoods were missing the `_removeConflictingFilters()` call before commit `7f2a95c`, allowing multiple neighbourhood groups to be selected simultaneously (e.g., filter IDs 47 + 45 both active). This caused:
- Incorrect filter chip display (multiple neighbourhoods showing)
- Broken search results (conflicting location anchors)
- Confusing UX (user thought they selected one neighbourhood, but two were active)

**Why this pattern is critical:**
- **Neighbourhoods, train stations, and shopping areas are mutually exclusive** — only one "location anchor" can be active
- Without clearing, filter state becomes inconsistent
- Search API doesn't handle multiple exclusive filters correctly
- Filter chips display incorrectly

**Consistency across all three exclusive categories:**

| Category | Handler Method | Exclusivity Call |
|----------|---------------|------------------|
| Train Stations | `_handleTrainStationSelection()` | `_removeConflictingFilters([_trainStationCategoryId])` ✅ |
| Shopping Areas | `_handleShoppingAreaSelection()` | `_removeConflictingFilters([_shoppingAreaCategoryId])` ✅ |
| Neighbourhoods | `_handleNeighborhoodSelection()` | `_removeConflictingFilters([_neighborhoodCategoryId])` ✅ (fixed) |

**All three now follow the same pattern:** Clear → Add → Search

**When to Use:**
- Filter categories where only one item should be active at a time
- Location-based filters (neighbourhoods, stations, shopping areas)
- Any mutually exclusive selection UI

**Reference:**
- `journey_mate/lib/widgets/shared/filter_overlay_widget.dart` — All three handler methods
- Commit `7f2a95c` — fix(filters): enforce exclusive neighbourhood selection for standalone neighbourhoods

---

## Swipe Gesture Patterns

**Discovered:** Phase 8, commit `58a7549` — Search page location banner swipe-to-dismiss
**Applies to:** Dismissible banners, cards, notifications, horizontal navigation

### Pattern 1: HitTestBehavior for Nested Interactivity

**Problem:** GestureDetector blocks taps on child widgets by default.
**Solution:** Use `HitTestBehavior.translucent` to capture swipe gestures while allowing child taps.

```dart
GestureDetector(
  behavior: HitTestBehavior.translucent, // ← Critical for nested interactivity
  onHorizontalDragStart: _handleDragStart,
  onHorizontalDragUpdate: _handleDragUpdate,
  onHorizontalDragEnd: _handleDragEnd,
  child: Container(
    child: TextButton(
      onPressed: () { ... }, // ← Still works! GestureArena resolves tap vs swipe
    ),
  ),
)
```

**How it works:**
- `translucent`: Captures gestures AND allows child taps
- `deferToChild` (default): Blocks child interaction entirely
- GestureArena automatically resolves: Short tap → button wins, horizontal drag → swipe wins

**Reference:** `journey_mate/lib/pages/search/search_page.dart:881`

---

### Pattern 2: Dynamic Animation Duration for Responsiveness

**Problem:** Fixed animation duration feels laggy during drag or sluggish on dismiss.
**Solution:** Use 0ms during drag, medium on reset, fast on dismiss.

```dart
AnimatedContainer(
  duration: Duration(
    milliseconds: _isBannerDismissing
      ? 250                           // Fast dismiss
      : (_bannerDragOffset == 0.0 ? 300 : 0), // Smooth reset or instant drag
  ),
  curve: Curves.easeOut,
  transform: Matrix4.translationValues(_bannerDragOffset, 0.0, 0.0),
  child: ...,
)
```

**Timing pattern:**
- **0ms during drag:** Immediate visual feedback (no lag on finger movement)
- **300ms on reset:** Smooth bounce-back when user releases early
- **250ms on dismiss:** Snappy feel for committed dismissal

**Why:** Responsiveness is the difference between feeling native vs web-like.

---

### Pattern 3: LayoutBuilder + postFrameCallback for Runtime Measurements

**Problem:** Can't know widget dimensions at build time (varies by screen, orientation, font scaling).
**Solution:** Capture dimensions after layout completes.

```dart
LayoutBuilder(
  builder: (context, constraints) {
    // Capture banner width for threshold calculation
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && _bannerWidth != constraints.maxWidth) {
        setState(() {
          _bannerWidth = constraints.maxWidth;
        });
      }
    });

    return GestureDetector(...);
  },
)
```

**Why postFrameCallback:**
- LayoutBuilder gives `constraints.maxWidth` during build
- postFrameCallback ensures measurement after layout completes
- Always check `mounted` before `setState` in callback

**Reference:** `journey_mate/lib/pages/search/search_page.dart:870-882`

---

### Pattern 4: Adaptive Threshold (Percentage, Not Fixed Pixels)

**Problem:** Fixed 100px threshold is too easy on iPhone SE (26%) but too hard on iPad Pro (9%).
**Solution:** Use percentage-based threshold that scales naturally.

```dart
void _handleDragEnd(DragEndDetails details) {
  // Calculate threshold: 30% of banner width
  final dismissThreshold = _bannerWidth * 0.3;

  // Check velocity: fast swipe left
  final velocity = details.velocity.pixelsPerSecond.dx;
  final fastSwipeLeft = velocity < -500;

  // Dismiss if: swipe distance > 30% OR fast swipe
  if (_bannerDragOffset.abs() > dismissThreshold || fastSwipeLeft) {
    _dismissBanner();
  } else {
    _resetBanner();
  }
}
```

**Threshold scaling:**
- iPhone SE (375px): 30% = 112px
- iPad Pro (1024px): 30% = 307px
- Velocity fallback: -500px/s (iOS standard for swipe detection)

**Why:** Consistent UX across all device sizes, matches user expectations.

---

### Pattern 5: Clamping for Natural Gesture Constraints

**Problem:** Right-swipe makes no sense for dismiss action.
**Solution:** Clamp to negative values only.

```dart
void _handleDragUpdate(DragUpdateDetails details) {
  if (_isBannerDismissing || _bannerWidth == 0.0) return;

  setState(() {
    _bannerDragOffset = (_bannerDragOffset + details.delta.dx).clamp(-_bannerWidth, 0.0);
    // ← Clamp prevents right-swipe (only negative = left slide)
  });
}
```

**Why:** Matches iOS system swipe behaviors (no overshoot, feels natural).

---

### Pattern 6: Animation State Guard

**Problem:** User can interact during animation, causing double-dismiss or state corruption.
**Solution:** Guard flag prevents interaction during animation.

```dart
bool _isBannerDismissing = false;

void _handleDragStart(DragStartDetails details) {
  // Early return if dismissing
  if (_isBannerDismissing) return;

  setState(() { ... });
}

void _dismissBanner() {
  setState(() {
    _isBannerDismissing = true; // ← Lock state
    _bannerDragOffset = -_bannerWidth;
  });

  // Disable buttons too
  TextButton(
    onPressed: _isBannerDismissing ? null : () { ... },
  )
}
```

**Prevents:**
- Double-dismiss (user swipes again mid-animation)
- Mid-animation state corruption
- Race conditions with async operations

---

### Pattern 7: Mounted Checks After Async Animation

**Problem:** Widget could unmount if user navigates away during dismiss animation.
**Solution:** Always check `mounted` after `Future.delayed`.

```dart
void _dismissBanner() {
  setState(() {
    _isBannerDismissing = true;
    _bannerDragOffset = -_bannerWidth;
  });

  // Wait for animation to complete
  Future.delayed(const Duration(milliseconds: 250), () {
    if (mounted) {  // ← Critical check
      ref.read(locationProvider.notifier).dismissBanner();
      setState(() {
        _bannerDragOffset = 0.0;
        _isBannerDismissing = false;
      });
    }
  });
}
```

**Pattern:** `Future.delayed(...)`, THEN `if (mounted)` before state changes.

---

### Pattern 8: Matrix4.translationValues for GPU-Accelerated Animation

**Problem:** Animating `margin` or `padding` triggers layout, causing jank.
**Solution:** Use `transform` property for GPU-accelerated animation.

```dart
AnimatedContainer(
  transform: Matrix4.translationValues(_bannerDragOffset, 0.0, 0.0),
  // ← GPU-accelerated, no layout recalculation
  child: ...,
)

// NOT this (causes layout):
// margin: EdgeInsets.only(left: _bannerDragOffset),
```

**Why:** `transform` is GPU-accelerated, smoother than margin changes which trigger layout.

**Parameters:**
- `translationValues(x, y, z)` where `x` = horizontal offset
- Negative x = slide left, positive = slide right

---

### Complete Example: Dismissible Banner

```dart
class _SearchPageState extends ConsumerState<SearchPage> {
  // Swipe state
  double _bannerDragOffset = 0.0;
  bool _isBannerDismissing = false;
  double _bannerWidth = 0.0;

  Widget _buildLocationBanner() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Capture width
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted && _bannerWidth != constraints.maxWidth) {
            setState(() { _bannerWidth = constraints.maxWidth; });
          }
        });

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (details) {
            if (_isBannerDismissing) return;
            // Start drag...
          },
          onHorizontalDragUpdate: (details) {
            if (_isBannerDismissing || _bannerWidth == 0.0) return;
            setState(() {
              _bannerDragOffset = (_bannerDragOffset + details.delta.dx).clamp(-_bannerWidth, 0.0);
            });
          },
          onHorizontalDragEnd: (details) {
            if (_isBannerDismissing || _bannerWidth == 0.0) return;

            final dismissThreshold = _bannerWidth * 0.3;
            final velocity = details.velocity.pixelsPerSecond.dx;

            if (_bannerDragOffset.abs() > dismissThreshold || velocity < -500) {
              _dismissBanner();
            } else {
              _resetBanner();
            }
          },
          child: AnimatedContainer(
            duration: Duration(
              milliseconds: _isBannerDismissing ? 250 : (_bannerDragOffset == 0.0 ? 300 : 0),
            ),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_bannerDragOffset, 0.0, 0.0),
            child: Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.orangeBg,
                borderRadius: BorderRadius.circular(AppRadius.filter),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_off, color: AppColors.accent),
                  SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(td(ref, 'location_permission_denied'))),
                  TextButton(
                    onPressed: _isBannerDismissing ? null : () async {
                      await ref.read(locationProvider.notifier).enableLocation();
                      // Check permission granted...
                    },
                    child: Text(td(ref, 'location_permission_enable')),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _dismissBanner() {
    setState(() {
      _isBannerDismissing = true;
      _bannerDragOffset = -_bannerWidth;
    });

    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        ref.read(locationProvider.notifier).dismissBanner();
        setState(() {
          _bannerDragOffset = 0.0;
          _isBannerDismissing = false;
          _bannerWidth = 0.0;
        });
      }
    });
  }

  void _resetBanner() {
    setState(() { _bannerDragOffset = 0.0; });
  }
}
```

**Reference implementation:** `journey_mate/lib/pages/search/search_page.dart:869-1012`

---

### When to Use Swipe Gestures

| UI Element | Use Swipe? | Why |
|------------|-----------|-----|
| Dismissible banner/notification | ✅ Yes | Expected mobile UX, reduces need for close button |
| Horizontal pagination (images, tabs) | ✅ Yes | Natural gesture for sequential content |
| Delete confirmation | ✅ Yes | iOS Mail pattern, feels native |
| Modal dialog dismiss | ❌ No | Use close button — swipe might conflict with scroll |
| Vertical scroll list | ❌ No | Conflicts with scroll gesture |
| Non-dismissible content | ❌ No | Don't train users that everything swipes |

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
// In pages or providers (v9 API)
final response = await ApiService.instance.search(
  filters: [1, 2, 3],              // Scoring filters only (v9: no filtersUsedForSearch)
  cityId: '17',
  searchQuery: 'pizza',
  sortOption: 'nearest',           // v9: 'nearest', 'station', 'price_low', 'price_high'
  userLocation: '55.6761,12.5683',
  languageCode: 'da',
  neighbourhoodId: [47, 52],       // v9: geographic filter (List<int>?, JSON-encoded for API)
  shoppingAreaId: 2001,            // v9: NEW geographic filter
  onlyOpen: true,                  // v9: Over-fetches + local filtering
);

if (response.statusCode == 200 && response.jsonBody != null) {
  final searchResults = response.jsonBody['documents'];
  final fullMatchCount = response.jsonBody['fullMatchCount'];  // v9: NEW field
  final pagination = response.jsonBody['pagination'];

  // v9: Each document has 'section' field for rendering
  for (final doc in searchResults) {
    final section = doc['section'];  // 'fullMatch', 'partialMatch', 'others'
    // Render section header when section value changes
  }
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

**Full API contracts:** See `_reference/BUILDSHIP_API_REFERENCE.md`

### Graceful Degradation on Secondary API Failure

When a page calls multiple APIs (e.g., business profile + menu), a failure in one should NOT break the entire page. Use page-local error flags to degrade gracefully:

```dart
class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage> {
  bool _menuLoadFailed = false;

  Future<void> _loadMenu() async {
    try {
      final response = await ApiService.instance.getRestaurantMenu(businessId);
      if (response.statusCode == 200) {
        ref.read(businessProvider.notifier).setMenuItems(response.jsonBody);
      } else {
        setState(() => _menuLoadFailed = true);
      }
    } catch (e) {
      setState(() => _menuLoadFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _buildHeroSection(),      // Always visible
      _buildOpeningHours(),     // Always visible
      if (_menuLoadFailed)
        _buildMenuErrorWidget() // Error widget in menu section only
      else
        _buildMenuSection(),    // Normal menu display
    ]);
  }
}
```

**Rule:** Primary content (business profile) remains fully visible when secondary content (menu) fails. Track failures with page-local bools, show error widgets in the failing section only.

**Reference:** Commit `5eae0ca` — menu API failure shows error widget without hiding business profile

### BusinessCache — In-Memory LRU Preview Cache

**File:** `journey_mate/lib/services/business_cache.dart`

Standalone singleton cache (NOT a Riverpod provider) that stores business preview data from search results for instant display when navigating to business profile pages.

**Key properties:**
- **50-entry max** with LRU eviction via `LinkedHashMap` insertion order
- **Singleton access:** `BusinessCache.instance` (no Riverpod dependency)
- **LRU promotion:** `getBusinessPreview()` removes and re-inserts entry at end
- **Eviction:** When cache exceeds `_maxEntries`, oldest entry (first key) is removed

**API:**
```dart
// Cache preview data when displaying search results
BusinessCache.instance.cacheBusinessPreview(searchResultMap);

// Retrieve cached preview for instant page load
final preview = BusinessCache.instance.getBusinessPreview(businessId);

// Clear all cached data (e.g., on logout)
BusinessCache.instance.clear();
```

**Why standalone singleton, not a Riverpod provider?**
- Cache is a simple key-value store with no reactive subscribers
- Used by both search results list and business profile page (no widget tree dependency)
- Avoids unnecessary Riverpod overhead for a pure data cache

**Reference:** Commit `ae9ad82` — in-memory LRU cache for business preview data

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

## Location Permission Pattern

JourneyMate uses three distinct permission request methods from `locationProvider`. Choosing the right method prevents silent failures and ensures users always have a path to enable location.

### The Three Methods

**1. `enableLocation()` — Smart Enable (RECOMMENDED)**
```dart
await ref.read(locationProvider.notifier).enableLocation();
```
- Shows permission dialog if first time
- Opens Settings if previously denied
- Opens Settings if already granted (for permission management)
- **Use for:** User-facing "Enable Location" / "Activate" buttons

**2. `requestPermission()` — Dialog Only (RARE)**
```dart
bool granted = await ref.read(locationProvider.notifier).requestPermission();
```
- Shows permission dialog only
- Returns `false` if previously denied (NO Settings fallback)
- **Use for:** Programmatic requests where you need immediate yes/no
- **Warning:** Fails silently after user denies once — prefer `enableLocation()` for UI elements

**3. `requestPermissionIfNeeded()` — Safe Startup Check**
```dart
await ref.read(locationProvider.notifier).requestPermissionIfNeeded();
```
- Only requests if status == denied (never asked before)
- Becomes no-op after first denial
- **Use for:** App startup permission check in `main.dart`

### When to Use What

| Scenario | Method | Reason |
|----------|--------|--------|
| "Enable Location" button on page | `enableLocation()` | Always provides path forward (dialog or Settings) |
| Search page location banner | `enableLocation()` | User expects to activate location |
| LocationStatusCard "Activate" button | `enableLocation()` | User-facing activation UI |
| App startup permission check | `requestPermissionIfNeeded()` | Safe to call on every launch |
| Programmatic permission request | `requestPermission()` | Rare — only if you need immediate yes/no |
| Returning from Settings | `checkPermission()` | Refresh current status |

### Common Pitfall: Using requestPermission() for UI Buttons

❌ **Bad:**
```dart
// Using requestPermission() for user-facing button
ElevatedButton(
  onPressed: () async {
    final granted = await ref.read(locationProvider.notifier).requestPermission();
    // If user previously denied, this returns false silently
    // User has no path to Settings — stuck with "Enable Location" button that does nothing
  },
  child: Text('Enable Location'),
)
```

✅ **Good:**
```dart
// Using enableLocation() for user-facing button
ElevatedButton(
  onPressed: () async {
    await ref.read(locationProvider.notifier).enableLocation();
    // First time: shows permission dialog
    // Previously denied: opens Settings
    // Already granted: opens Settings for management
    // Always provides a path forward
  },
  child: Text('Enable Location'),
)
```

**Why it matters:** `requestPermission()` fails silently after the first denial. Users get stuck with an "Enable Location" button that appears broken. `enableLocation()` always provides a path forward (Settings app).

**Reference:** See `_reference/PROVIDERS_REFERENCE.md` → locationProvider → Method Selection Guide for full API details.

**Git history:** Pattern established in commit 50fedf3 (search banner fix), documented in commit a663a34.

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
  // 1. Supabase API cache (primary source)
  final cache = ref.watch(translationsCacheProvider);
  final text = cache[key];

  if (text != null && text.isNotEmpty) {
    return text;
  }

  // 2. Welcome page fallbacks (hardcoded for offline/first launch)
  final locale = ref.watch(localeProvider);
  final lang = locale.languageCode;

  final welcomeFallback = kWelcomeFallbackTranslations[lang]?[key];
  if (welcomeFallback != null) {
    return welcomeFallback;
  }

  // 3. Business profile fallbacks (hardcoded for offline/first launch)
  final businessFallback = kBusinessProfileFallbackTranslations[lang]?[key];
  if (businessFallback != null) {
    return businessFallback;
  }

  // 4. Key name as last resort
  debugPrint('⚠️ td: Missing translation key "$key"');
  return key;
}
```

> **Fallback chain (4 steps):** The `td()` function resolves translations in order:
> 1. Supabase API cache (`translationsCacheProvider`) — primary, always preferred
> 2. Welcome page fallbacks (`kWelcomeFallbackTranslations`) — hardcoded for offline/first launch
> 3. Business profile fallbacks (`kBusinessProfileFallbackTranslations`) — hardcoded for offline/first launch
> 4. Key name as last resort (logs warning)
>
> **Reference:** Commits `03a5073`, `9f7a6bb` — added business profile fallback layer and cleaned up legacy keys

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

- **344 app keys** (search, business profile, menu, settings, etc.)
- **0 legacy keys** (all FlutterFlow migration keys cleaned up — commit `9f7a6bb`)
- **15 languages in Supabase:** en, da, de, es, fi, fr, it, ja, ko, nl, no, pl, sv, uk, zh
- **7 fallback languages in app:** en, da, de, fr, it, no, sv (hardcoded in `kWelcomeFallbackTranslations` and `kBusinessProfileFallbackTranslations`)
- **~5,160 translation rows** in Supabase (344 keys x 15 languages)
- **Storage:** Supabase `ui_translations` table
- **API:** BuildShip `GET /languageText` endpoint

### Date Formatting with intl Package Locale Support

**Pattern:** Use `intl` package's built-in locale support instead of hardcoding language-specific date formats.

**Context:** App supports 15 languages (en, da, de, es, fi, fr, it, ja, ko, nl, no, pl, sv, uk, zh). Originally, date formatting was hardcoded for only Danish and English. Updated to support all 15 by letting `intl` package handle locale-specific formatting automatically.

✅ **Good:**
```dart
import 'package:intl/intl.dart';

String _formatLocalizedDate(String? isoDate, String languageCode) {
  if (isoDate == null || isoDate.isEmpty) return '';

  try {
    final parsedDate = DateTime.parse(isoDate);

    try {
      // intl automatically handles locale-specific formatting:
      // - ja/zh: 年月日 characters (2026年2月22日)
      // - ko: periods (2026. 2. 22.)
      // - European languages: locale-specific month names (22. feb. 2026, 22 févr. 2026)
      return DateFormat.yMMMd(languageCode).format(parsedDate);
    } catch (e) {
      // Fallback to English for unsupported locales
      return DateFormat.yMMMd('en').format(parsedDate);
    }
  } catch (e) {
    return '';  // Invalid date format
  }
}

// Usage:
final formattedDate = _formatLocalizedDate(business['last_reviewed_at'], currentLanguage);
// en: "Feb 22, 2026"
// da: "22. feb. 2026"
// ja: "2026年2月22日"
// ko: "2026. 2. 22."
```

**Why this works:**
- `DateFormat.yMMMd(languageCode)` automatically uses locale data from `intl` package for 100+ languages
- Asian languages get proper date characters (年月日 for Japanese/Chinese, periods for Korean)
- European languages get localized month abbreviations (feb., févr., febr., など)
- No need to maintain switch statements or manual formatting for each language

**When NOT to use this:**
- Custom date formats not supported by `intl` (e.g., "3 days ago", relative time)
- Dates requiring additional logic (e.g., "Today", "Yesterday")
- Non-date localization (use `td(ref, key)` for all text translations)

**Affected files:**
- `menu_full_page.dart` — Menu last updated date display
- `inline_menu_widget.dart` — Business profile inline menu date display

**Reference:** Commit `90d014c` — fix(i18n): expand menu date formatting to support all 15 languages

---

## Design Token System

**Full reference:** See **DESIGN_SYSTEM_flutter.md** — Complete token catalog with color palettes, spacing scale, typography styles, border radii, input decorations, button styles, and copy-paste UI patterns.

**Source files:** `journey_mate/lib/theme/` (8 files: `app_colors.dart`, `app_spacing.dart`, `app_typography.dart`, `app_radius.dart`, `app_constants.dart`, `app_button_styles.dart`, `app_input_decorations.dart`, `app_theme.dart`)

**Critical Rules:**
- Orange (`AppColors.accent`) ONLY for CTAs/interactive elements (never match status)
- Green (`AppColors.green`) ONLY for match confirmation (never CTAs)
- All colors via `AppColors.*`, spacing via `AppSpacing.*`, typography via `AppTypography.*`, radii via `AppRadius.*` — no raw hex, magic numbers, or inline TextStyle

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

### Event Types (47 total)

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

### Defensive Client-Side Validation (Best Practice)

**Pattern:** Even when backend is fixed, add lightweight client-side validation for critical ordering/grouping logic. This provides insurance against future backend regressions, network corruption, or cached responses.

**Example: Search Results Section Ordering**

Backend was fixed to return properly ordered sections (full match → partial match → no match), but client-side defensive validation adds a safety layer:

```dart
List<RestaurantWithMatchInfo> _buildSectionedList(List<RestaurantWithMatchInfo> results) {
  // Apply defensive grouping before rendering
  final orderedResults = _ensureProperSectionOrder(results);
  // ... rest of rendering logic
}

List<RestaurantWithMatchInfo> _ensureProperSectionOrder(List<RestaurantWithMatchInfo> results) {
  // Fast path: validate ordering (O(n), <1ms, zero allocations)
  if (_isProperlyOrdered(results)) {
    return results;  // 99% of cases exit here
  }

  // Backup path: re-group by section (1-5ms, rare)
  print('⚠️ Search results not properly ordered - applying defensive grouping');

  final fullMatches = results.where((r) => r.matchLevel == 'fullMatch').toList();
  final partialMatches = results.where((r) => r.matchLevel == 'partialMatch').toList();
  final noMatches = results.where((r) => r.matchLevel == 'noMatch').toList();

  return [...fullMatches, ...partialMatches, ...noMatches];
}

bool _isProperlyOrdered(List<RestaurantWithMatchInfo> results) {
  int currentLevel = 0;
  for (final result in results) {
    final level = _getSectionLevel(result.matchLevel);
    if (level < currentLevel) return false;  // Early exit on out-of-order
    currentLevel = level;
  }
  return true;
}

int _getSectionLevel(String matchLevel) {
  switch (matchLevel) {
    case 'fullMatch': return 0;
    case 'partialMatch': return 1;
    case 'noMatch': return 2;
    default: return 3;
  }
}
```

**Why this is a best practice:**
- **Fast path is cheap:** O(n) validation with early exit, zero allocations (typically <1ms)
- **Backup path rarely runs:** Only when API fails, network corruption, or cached responses
- **Logs warnings:** Makes backend regressions visible in monitoring/debugging
- **User experience protected:** Search results always display correctly, even if API breaks

**When to use defensive validation:**
- Critical user-facing logic (search results, navigation, checkout flows)
- Data that affects UI rendering order or correctness
- Backend contracts that changed recently (during stabilization period)
- High-impact user flows where failure is unacceptable

**When NOT to use:**
- Simple CRUD operations with no ordering requirements
- Internal data structures not directly user-facing
- Over-engineering: Don't add validation "just in case" without concrete risk assessment
- Performance-critical paths where validation cost is too high

**Performance characteristics:**
- **Fast path (validation):** <1ms, O(n) with early exit
- **Backup path (re-grouping):** 1-5ms, O(n) with three iterations
- **Expected frequency:** Fast path: 99%+, backup path: <1%

**Monitoring:** Warning logs make backend issues visible in production monitoring, allowing proactive fixes before user reports.

**Reference:**
- `journey_mate/lib/pages/search/search_page.dart` — Search results defensive grouping
- Commit `67405da` — feat(search): add client-side defensive grouping for search results

---

## Code Review Checklist

**Purpose:** Pre-commit checklist consolidating all non-negotiable rules from ARCHITECTURE.md. Use this before every commit to catch common mistakes.

### Design Tokens (Non-Negotiable)

- [ ] **Colors from AppColors** — No raw hex values like `Color(0xFFe8751a)`. Use `AppColors.accent`, `AppColors.primary`, etc.
  - See [Pitfall #1](#pitfall-1-using-raw-hex-colors) (line 1778)
  - See [Design Token System](#design-token-system) (lines 1116-1127)

- [ ] **Spacing from AppSpacing** — No magic numbers like `16.0`. Use `AppSpacing.md`, `AppSpacing.lg`, etc.
  - See [Pitfall #2](#pitfall-2-using-magic-numbers-for-spacing) (line 1792)
  - See [Design Token System](#design-token-system) (lines 1116-1127)

- [ ] **Typography from AppTypography** — No inline `TextStyle(...)`. Use `AppTypography.h1`, `AppTypography.body`, `AppTypography.bodySm`, etc. (17-style scale: h1/h1Heavy/h2/h3, bodyLg/bodyLgMedium/bodyLgHeavy/body/bodyMedium/bodyHeavy/bodySm/bodySmMedium/bodySmHeavy, button, price).
  - See [Design Token System](#design-token-system) (lines 1116-1127)

- [ ] **Radii from AppRadius** — No `BorderRadius.circular(16)`. Use `AppRadius.lg`, `AppRadius.full`, etc.
  - See [Design Token System](#design-token-system) (lines 1116-1127)

- [ ] **Color semantics enforced** — Orange (`AppColors.accent`) for CTAs only, green (`AppColors.matchGreen`) for match confirmation only
  - See [Philosophy](#philosophy) → Design Tokens (lines 44-50)

### State Management Patterns

- [ ] **Global state uses NotifierProvider/AsyncNotifierProvider** — No `FFAppState`, `Provider`, or `StateNotifier` (deprecated Riverpod 2.x)
  - See [State Management](#state-management) (lines 146-285)

- [ ] **Page-local state uses local State variables** — Not provider state
  - See [State Management](#state-management) → When to Use What (lines 183-227)

- [ ] **Atomic updates for dependent fields** — Update related fields together to prevent orphaned state
  - See [Pitfall #6](#pitfall-6-non-atomic-updates-to-dependent-fields) (line 1874)

### Translations

- [ ] **All text via td(ref, 'key')** — No hardcoded string literals
  - See [Translation System](#translation-system) (lines 1054-1113)
  - See [Philosophy](#philosophy) → Translations (lines 60-62)

### Widget Architecture

- [ ] **Self-contained widgets** — Widgets read providers/context internally. No infrastructure props (language, translations, dimensions)
  - See [Philosophy](#philosophy) → Self-Contained Widgets (lines 71-81)
  - See [Pitfall #7](#pitfall-7-prop-drilling-infrastructure-data) (line 1897)

- [ ] **ConsumerWidget only when using ref** — Use StatelessWidget for pure widgets with no provider reads
  - See [State Management](#state-management) → Widget Types (lines 146-182)

### Analytics

- [ ] **Fire-and-forget analytics** — Never `await` analytics calls
  - See [Analytics Architecture](#analytics-architecture) (lines 1129-1203)
  - See [Pitfall #11](#pitfall-11-awaiting-analytics-calls) (line 1987)

- [ ] **No manual markUserEngaged() calls** — ActivityScope handles engagement automatically
  - See [Analytics Architecture](#analytics-architecture) → ActivityScope Pattern (lines 1164-1178)

### Flutter 3.x APIs

- [ ] **WidgetStateProperty (not MaterialStateProperty)** — Flutter 3.x renamed this class
  - See [Pitfall #3](#pitfall-3-using-deprecated-materialstateproperty) (line 1813)

- [ ] **.withValues(alpha:) instead of .withOpacity()** — Flutter 3.x deprecated `withOpacity`
  - See [Pitfall #4](#pitfall-4-using-deprecated-withopacity) (line 1829)

- [ ] **context.mounted checks after async** — Always check `if (!context.mounted) return;` after `await`
  - See [Pitfall #5](#pitfall-5-missing-contextmounted-checks) (line 1845)

### Linting Rules

- [ ] **No double underscores in parameter names** — Triggers `unnecessary_underscores` lint
  - Use `e`, `s`, `error`, `stack` instead of `_`, `__`
  - Example: `error: (e, s) => true` NOT `error: (_, __) => true`
  - See [Pitfall #19](#pitfall-19-using-double-underscores-in-callbacks) (line 2196)

- [ ] **Null-aware spread for conditional map entries** — Use `...?condition ? {'key': value} : null`
  - NOT `if (condition) 'key': value` (syntax error)
  - See [Pitfall #21](#pitfall-21-incorrect-conditional-map-entries) (line 2242)

### Code Quality

- [ ] **flutter analyze clean** — 0 errors, 0 warnings
  - See [Code Quality Standards](#code-quality-standards) (lines 1206-1245)

- [ ] **No unaddressed TODOs** — Resolve or remove before committing

### Shared Source Verification

- [ ] **Check app_theme.dart before modifying pages** — Shared theme tokens should be used, not duplicated
  - See [Code Quality Standards](#code-quality-standards) → Shared Sources (lines 1224-1245)

- [ ] **Check lib/widgets/shared/ before creating new widgets** — Reuse existing widgets when possible
  - See [Project Structure](#project-structure) → Shared Widgets (lines 120-130)

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

### Pitfall #11: Using ref After Widget Might Unmount

This pitfall has two common contexts where widgets can unmount and invalidate `ref`:

#### Variation A: Async Operations

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

**Common in:** Pre-loading pages (Welcome, Settings, App Setup Flow) that fetch search results before navigating to Search page.

#### Variation B: dispose() Method

❌ **Bad:**
```dart
class MyWidget extends ConsumerStatefulWidget { ... }

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  void dispose() {
    // ⚠️ DANGER: Widget is already unmounting, ref may be invalid
    ref.read(searchStateProvider.notifier).setFilters([...]);
    // Error: "Using ref when widget is unmounted is unsafe"
    super.dispose();
  }
}
```

✅ **Good:**
```dart
class MyWidget extends ConsumerStatefulWidget { ... }

class _MyWidgetState extends ConsumerState<MyWidget> {
  // Save notifier for safe disposal
  late final SearchStateNotifier _savedSearchNotifier;

  @override
  void initState() {
    super.initState();
    // Save notifier BEFORE widget can unmount
    _savedSearchNotifier = ref.read(searchStateProvider.notifier);
  }

  @override
  void dispose() {
    // Use saved notifier (safe even during unmount)
    _savedSearchNotifier.setFilters([...]);
    super.dispose();
  }
}
```

**Common in:** Widgets that sync state on disposal (filter overlays, forms, bottom sheets).

**Reference:** See commit `c998826` — "fix: prevent ref access in dispose() in filter overlay widget"

---

**Why:** When a widget unmounts (user navigates away, parent rebuilds, or `dispose()` is called), `ref` becomes invalid because it relies on `BuildContext`. Saving the notifier early (before async operations OR in `initState()`) captures a reference that remains safe even after unmount.

---

### Pitfall #12: Fixing Individual Implementations Before Checking Shared Source

**Problem:** When encountering UI issues (styling, spacing, positioning), developers might modify multiple individual page implementations instead of fixing the shared source (theme configuration or shared component).

**Why it happens:**
- Bottom-up search pattern finds individual implementations first
- Mental model treats UI elements as standalone per page
- Missing awareness of centralized theme or shared components in `lib/theme/` and `lib/widgets/shared/`

**Impact:**
- Wasted effort modifying N files when 1 fix would suffice
- Inconsistent fixes (easy to miss files)
- Duplication of code

---

#### Case A: AppBar Styling (commit `c97e48d`)

❌ **Bad Approach** (bottom-up):
```dart
// Attempted to modify 10+ individual page AppBars
// journey_mate/lib/pages/settings/share_feedback_page.dart
appBar: AppBar(
  backgroundColor: AppColors.bgPage,
  elevation: 0,
  surfaceTintColor: Colors.transparent, // ← Repeated 10+ times!
  scrolledUnderElevation: 0,
),

// journey_mate/lib/pages/settings/contact_us_page.dart
appBar: AppBar(
  backgroundColor: AppColors.bgPage,
  elevation: 0,
  surfaceTintColor: Colors.transparent, // ← Duplication!
  scrolledUnderElevation: 0,
),

// ... 8 more files with identical changes
```

✅ **Correct Approach** (theme-first):
```dart
// journey_mate/lib/theme/app_theme.dart
// ONE centralized fix affects all AppBars automatically
appBarTheme: AppBarTheme(
  backgroundColor: AppColors.bgPage,
  foregroundColor: AppColors.textPrimary,
  elevation: 0,
  surfaceTintColor: Colors.transparent, // ← Single source of truth
  scrolledUnderElevation: 0, // ← Propagates to all pages
  centerTitle: true,
),
```

---

#### Case B: Bottom Navigation Positioning (commit `4fad9e5`)

❌ **Bad Approach** (per-page customization):
```dart
// Settings page — custom navbar wrapper causing spacing bug
return Scaffold(
  body: SafeArea(
    child: Stack(
      children: [
        Padding(padding: EdgeInsets.fromLTRB(20, 40, 20, 80), ...),
        Align(
          alignment: Alignment.bottomCenter,
          child: const NavBarWidget(...), // ← Custom positioning wrapper
        ),
      ],
    ),
  ),
);
```

✅ **Correct Approach** (shared component):
```dart
// Search + Settings pages — identical usage of shared component
return Scaffold(
  body: SafeArea(...),
  bottomNavigationBar: const NavBarWidget(...), // ← Shared component, no wrappers
);
```

---

**Rule:** For ANY UI issue, always check shared sources FIRST before modifying individual pages.

**Workflow:**
1. ✅ **First**: Check `lib/theme/app_theme.dart` for centralized theme (ThemeData)
2. ✅ **Second**: Check `lib/widgets/shared/` for shared components (used on 2+ pages)
3. ✅ **Third**: Check `lib/pages/<section>/widgets/` for page-specific components (used on 1 page)
4. ✅ **Fourth**: If fix needed, modify theme/shared component (affects all pages)
5. ✅ **Last**: Only modify individual pages if truly page-specific behavior needed

**Theme-controlled UI elements:**
- AppBar: `ThemeData.appBarTheme` (backgroundColor, elevation, surfaceTintColor, scrolledUnderElevation, titleTextStyle)
- ElevatedButton: `ThemeData.elevatedButtonTheme` (background, foreground, padding, shape)
- TextField: `ThemeData.inputDecorationTheme` (border, fillColor, focusedBorder)
- Card: `ThemeData.cardTheme` (color, elevation, shape)
- Checkbox: `ThemeData.checkboxTheme` (fillColor, side)
- BottomSheet: `ThemeData.bottomSheetTheme` (backgroundColor, shape)

**Shared components:**
- NavBarWidget (bottom navigation), FilterOverlayWidget, ContactUsFormWidget, FeedbackFormWidget, SelectedFiltersBtns

**Common in:** All pages with AppBars, bottom navigation, forms, inputs, buttons, cards.

**References:**
- Commit `c97e48d` — "fix: remove Material 3 orange tint from AppBar when scrolling"
- Commit `4fad9e5` — "fix: align navbar spacing on search and settings pages"

---

### Pitfall #13: Map Type Variance in Collection Callbacks

**What:** Using `Map<String, dynamic>` in `orElse:` callbacks when method signature expects `Map<String, Object>` causes type errors due to Dart's contravariance rules.

**When it happens:**
- `List.firstWhere()`, `lastWhere()`, `singleWhere()` with `orElse:` returning maps
- Generic methods where type parameter has specific constraints
- Flutter 3.41.x enforces stricter type variance than earlier versions

**Error message:**
```
TypeError: Instance of '() => Map<String, dynamic>':
type '() => Map<String, dynamic>' is not a subtype of
type '(() => Map<String, Object>)?'
```

**Root cause:** `Map<String, dynamic>` is NOT a subtype of `Map<String, Object>` in Dart due to contravariance. Even though `Object` is a supertype of `dynamic` for values, the map types are invariant in their value type parameter.

❌ **Bad:**
```dart
final selectedStation = trainStations.firstWhere(
  (s) => s['id'] == selectedStationId,
  orElse: () => <String, dynamic>{},  // ← Type error!
);
```

**Why it fails:** Method signature expects `Map<String, Object> Function()?` but receives `Map<String, dynamic> Function()`. These are incompatible types.

✅ **Good:**
```dart
final selectedStation = trainStations.firstWhere(
  (s) => s['id'] == selectedStationId,
  orElse: () => <String, Object>{},  // ← Matches expected type
);
```

**Alternative (explicit cast):**
```dart
final selectedStation = trainStations.firstWhere(
  (s) => s['id'] == selectedStationId,
  orElse: () => <String, dynamic>{} as Map<String, Object>,
);
```
**Note:** Cast works but triggers `unnecessary_cast` analyzer warning. Using `Map<String, Object>` directly is cleaner.

**Where this applies:**
- All `firstWhere()` / `lastWhere()` / `singleWhere()` with map-returning `orElse:`
- Any generic method where callback return type has specific constraints
- BuildShip response parsing where you filter/search for specific objects

**Common in:** Filter widgets, search features, any code using collection lookups with fallback empty maps.

**Git reference:** Commit `f5ab2a9` — "fix: resolve type error when reopening SortBottomSheet after train station selection"

---

### Pitfall #14: Using enableLocation() Void Return Type Incorrectly

**What:** Attempting to assign `enableLocation()` result to a variable causes "use_of_void_result" analyzer error.

❌ **Bad:**
```dart
final granted = await ref.read(locationProvider.notifier).enableLocation();
if (granted && mounted) {
  // This crashes! enableLocation() returns void, not bool
  _executeSearch(...);
}
```

**Error message:**
```
This expression has a type of 'void' so its value can't be used
Error code: use_of_void_result
```

✅ **Good:**
```dart
// Call enableLocation, then check state
await ref.read(locationProvider.notifier).enableLocation();

if (mounted) {
  final locationState = ref.read(locationProvider);
  if (locationState.hasPermission) {
    _executeSearch(...);
  }
}
```

**Why:** `enableLocation()` updates provider state but returns `Future<void>`. Always check method signatures in PROVIDERS_REFERENCE.md before using provider methods.

**Common in:** Search page location banner, LocationStatusCard buttons, any "Activate Location" UI.

**Git reference:** Commit `58a7549` — "feat(search): replace banner dismiss button with swipe-left gesture" (bug fix unrelated to swipe feature)

---

### Pitfall #15: Using HitTestBehavior.deferToChild with Tappable Children

**What:** GestureDetector with default behavior blocks taps on child buttons when gesture handlers are present.

❌ **Bad:**
```dart
GestureDetector(
  // Default: HitTestBehavior.deferToChild
  onHorizontalDragUpdate: (details) { ... },
  child: Container(
    child: TextButton(
      onPressed: () { ... }, // ← NEVER FIRES! Gesture detector blocks it
    ),
  ),
)
```

**Result:** Button looks tappable but doesn't respond to taps. User taps multiple times, nothing happens.

✅ **Good:**
```dart
GestureDetector(
  behavior: HitTestBehavior.translucent, // ← Captures gestures AND allows child taps
  onHorizontalDragUpdate: (details) { ... },
  child: Container(
    child: TextButton(
      onPressed: () { ... }, // ← Works! GestureArena resolves tap vs swipe
    ),
  ),
)
```

**How it works:**
- `translucent`: Captures gestures AND allows child taps
- `deferToChild` (default): Blocks child interaction when gesture handlers present
- GestureArena automatically resolves: Short tap → button wins, horizontal drag → swipe wins

**Common in:** Dismissible banners with action buttons, swipeable cards with tappable content, horizontal lists with selectable items.

**Git reference:** Commit `58a7549` — "feat(search): replace banner dismiss button with swipe-left gesture"

---

### Pitfall #16: Fixed Pixel Thresholds for Mobile Gestures

**What:** Using fixed pixel values for swipe thresholds doesn't scale across device sizes.

❌ **Bad:**
```dart
void _handleDragEnd(DragEndDetails details) {
  if (_dragOffset.abs() > 100) { // ← Fixed 100px doesn't scale
    _dismiss();
  }
}
```

**Problem:**
- iPhone SE (375px wide): 100px = 26% of screen (too easy to dismiss accidentally)
- iPad Pro (1024px wide): 100px = 9% of screen (feels broken, too hard to dismiss)

✅ **Good:**
```dart
void _handleDragEnd(DragEndDetails details) {
  // Adaptive threshold: 30% of widget width
  final dismissThreshold = _widgetWidth * 0.3;

  // Velocity fallback for quick swipes
  final velocity = details.velocity.pixelsPerSecond.dx;
  final fastSwipe = velocity.abs() > 500;

  if (_dragOffset.abs() > dismissThreshold || fastSwipe) {
    _dismiss();
  } else {
    _reset();
  }
}
```

**Result:**
- iPhone SE (375px): 30% = 112px (feels right)
- iPad Pro (1024px): 30% = 307px (scales naturally)
- Velocity fallback: Fast flick dismisses regardless of distance

**Why percentage-based:**
- Consistent UX across all device sizes
- Matches user expectations (same effort on small and large screens)
- iOS standard: 30% distance OR 500px/s velocity for swipe detection

**Common in:** Swipe-to-dismiss banners, horizontal pagination, swipeable cards, drawer navigation.

**Git reference:** Commit `58a7549` — "feat(search): replace banner dismiss button with swipe-left gesture"

---

### Pitfall #17: Using 'filter_name' Instead of 'name' for Filter Objects

**Problem:** Filter objects from `filterProvider.filterLookupMap` use the field `'name'`, NOT `'filter_name'`. Using the wrong field name causes filter names to appear as empty strings in UI.

**Why it happens:**
- Direct Supabase queries may use column name `filter_name`
- BuildShip API returns filters with `name` field (see BUILDSHIP_API_REFERENCE.md → GET_FILTERS_FOR_SEARCH)
- Easy to confuse database column names with API response field names

**Impact:**
- Filter names don't display in UI (silent failure — no errors, just empty strings)
- Affects partial match info box, match card chips, or any widget using filter lookup
- Hard to debug without checking API response structure

❌ **Incorrect:**
```dart
final filter = ref.read(filterProvider).value?.filterLookupMap[filterId];
final filterName = filter['filter_name'];  // ❌ Always null!
```

✅ **Correct:**
```dart
final filter = ref.read(filterProvider).value?.filterLookupMap[filterId];
final filterName = filter['name'] as String;  // ✅ Returns actual name
```

**Widgets using filterLookupMap correctly:**
- `selected_filters_btns.dart` — Selected filter buttons
- `filter_overlay_widget.dart` — Filter panel
- `business_feature_buttons.dart` — Feature buttons
- `payment_options_widget.dart` — Payment options
- `search_results_list_view.dart` — Partial match info box (fixed)
- `match_card_widget.dart` — Match filter chips (fixed)

**Rule:** Always use `filter['name']` when accessing filter objects from `filterProvider.filterLookupMap`.

**Why the field is 'name' not 'filter_name':**
- GET_FILTERS_FOR_SEARCH endpoint returns: `{ id, name, cat_id, icon, description }`
- `filterLookupMap` stores these API response objects directly
- Database column `filter_name` is NOT exposed in API response

**Common in:** Any widget displaying filter names using filterProvider state.

---

### Pitfall #18: Parent-Child Filter Deduplication Must Happen Before titleId Lookup

**Problem:** When calculating filter counts for parent-child filter relationships, deduplication must occur BEFORE titleId lookup. If deduplication happens after lookup, both consumers (search_page.dart and filter_titles_row.dart) will see incorrect counts.

**Discovered:** Commit `a917eee` — Parent-child filter count deduplication

**Why it happens:**
- `titleId` represents filter category (Location, Type, Preferences)
- Filter count shows "Type (3)" or "Preferences (2)" based on titleId groups
- If parent+child both get titleIds assigned, count becomes 2 instead of 1
- Deduplication AFTER titleId lookup only affects one consumer, not both

❌ **Incorrect:**
```dart
// WRONG: Deduplicate after titleId lookup
final counts = <int, int>{1: 0, 2: 0, 3: 0};
for (final filterId in activeFilters) {  // [56, 585]
  final titleId = _findTitleIdForFilter(filterId, lookupMap);
  counts[titleId] = (counts[titleId] ?? 0) + 1;  // Both get counted
}
// counts now = {2: 2} (Type category has 2 selections)
// Deduplicating here won't help - count is already wrong
```

✅ **Correct:**
```dart
// Deduplicate BEFORE titleId lookup
final deduplicatedFilters = _deduplicateParentChildCombos(activeFilters);  // [56, 585] → [585]
for (final filterId in deduplicatedFilters) {
  final titleId = _findTitleIdForFilter(filterId, lookupMap);
  counts[titleId] = (counts[titleId] ?? 0) + 1;
}
// counts = {2: 1} (Type category has 1 selection, correct!)
```

**How to fix:**
1. Call `_deduplicateParentChildCombos()` FIRST, before any lookups
2. Use deduplicated list for all subsequent operations
3. Both count consumers see correct values automatically

**Where it applies:**
- `filter_count_helper.dart` — calculateFilterCounts()
- Any widget that groups filters by titleId for display
- Any analytics that tracks filter selection counts

**Why order matters:**
- titleId lookup assigns category (Type, Location, Preferences)
- Deduplication removes parent from list
- If parent already got a titleId, deduplication comes too late

**Git reference:** Commit `a917eee` — feat(filters): implement parent-child display logic

**Related ordering requirement:** Parent hiding must happen AFTER routed ID inclusion (neighbourhood/shopping area chips need routed IDs preserved for display).

---

### Pitfall #19: Using Double Underscores for Unused Parameters

**Problem:** Using `__` (double underscore) for parameter names triggers `unnecessary_underscores` lint error, causing `flutter analyze` to fail.

**When it happens:**
- Error callbacks with multiple ignored parameters: `(_, __) => ...`
- Any function parameter where you need multiple ignored arguments
- Flutter 3.41.x enforces stricter linting rules than earlier versions

**Error message:**
```
info • Unnecessary use of multiple underscores • lib/pages/search/search_page.dart:380:46 • unnecessary_underscores

1 issue found. (ran in 15.9s)
Build failed :|
Step 9 script `Flutter analyze` exited with status code 1
```

**Why it fails:** Dart lint rules prohibit consecutive underscores for parameter names as they reduce readability without adding value.

❌ **Bad:**
```dart
// Error callback with double underscore
error: (_, __) => true,  // ← Triggers unnecessary_underscores lint
```

✅ **Good:**
```dart
// Option 1: Simple parameter names
error: (e, s) => true,  // ← Short names for error, stackTrace

// Option 2: Descriptive names (if referenced)
error: (error, stack) => true,

// Option 3: Single underscore for ONE ignored param
loading: (_) => true,  // ← Acceptable for single ignored parameter
```

**Naming conventions for unused parameters:**
- Single ignored parameter: `_` (acceptable)
- Two ignored parameters: `(e, s)` or `(error, stack)` (no `__`)
- Mixed (first used, second ignored): `(value, _)` or better: `(value, s)`

**Common in:** AsyncValue.when() callbacks, error handlers, Stream listeners with multiple parameters.

**Reference:** Commit `1ba36c5` — fix(search): replace double underscore with simple parameter names

---

### Pitfall #20: Using Colors.white/Colors.black Instead of AppColors

**Problem:** Flutter's built-in `Colors.white` and `Colors.black` bypass the design system just like raw hex values. Developers assume named Flutter colors are "safe" since they're not `Color(0xFF...)`, but they prevent theming and break consistency.

❌ **Bad:**
```dart
TextButton(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all(Colors.white),  // ← Bypasses AppColors
    foregroundColor: WidgetStateProperty.all(Colors.black),   // ← Bypasses AppColors
    textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16)),  // ← Hardcoded size
  ),
  child: Text('Submit'),
)
```

✅ **Good:**
```dart
TextButton(
  style: ButtonStyle(
    backgroundColor: WidgetStateProperty.all(AppColors.accent),
    foregroundColor: WidgetStateProperty.all(AppColors.textWhite),
    textStyle: WidgetStateProperty.all(
      AppTypography.button.copyWith(fontWeight: FontWeight.w600),
    ),
  ),
  child: Text('Submit'),
)
```

**Mapping:**
| Flutter Color | AppColors Equivalent |
|---------------|---------------------|
| `Colors.white` | `AppColors.bgPage` or `AppColors.textWhite` (context-dependent) |
| `Colors.black` | `AppColors.textPrimary` |
| Hardcoded `fontSize` | `AppTypography.button.fontSize` or other `AppTypography.*` |

**Why it matters:** All colors must come from `AppColors` so the design system remains the single source of truth. This includes Flutter's named colors, not just raw hex.

**Common in:** Button styles, background colors, text colors across form pages and settings.

**Git reference:** Commit `604bdb6` — fix: unify button style across settings/welcome pages to match filter overlay

---

### Pitfall #21: Using Explicit Null Checks in Map Literals Instead of Null-Aware Spread

**Lint rule:** `use_null_aware_elements`

**Problem:** When adding conditional key-value pairs to map literals, Flutter analyzer enforces using the null-aware spread operator `...?` instead of explicit `if` statements. This is required for idiomatic Dart code and will cause CI/CD builds to fail.

❌ **Bad:**
```dart
eventData: {
  'session_duration_seconds': duration.inSeconds,
  if (businessIdInt != null) 'business_id': businessIdInt,  // ← Analyzer error
},
```

✅ **Good:**
```dart
eventData: {
  'session_duration_seconds': duration.inSeconds,
  ...?businessIdInt != null ? {'business_id': businessIdInt} : null,
},
```

**Pattern breakdown:**
```dart
// Conditional key-value pair in map:
if (condition) 'key': value,                           // ❌ Analyzer rejects
...?condition ? {'key': value} : null,                 // ✅ Null-aware spread

// Multiple conditional keys:
if (neighbourhoodId != null) 'neighbourhoodId': json.encode(neighbourhoodId),
if (shoppingAreaId != null) 'shoppingAreaId': shoppingAreaId,
// Becomes:
...?neighbourhoodId != null ? {'neighbourhoodId': json.encode(neighbourhoodId)} : null,
...?shoppingAreaId != null ? {'shoppingAreaId': shoppingAreaId} : null,
```

**Why this matters:**
- **CI/CD blocks builds** if `flutter analyze` finds this pattern
- The `...?` operator safely spreads a nullable map, adding key-value pairs only if the map exists
- Enforced by Flutter analyzer's `use_null_aware_elements` lint rule since Flutter 3.x

**Real-world fix locations:**
- `lib/pages/business_profile/business_profile_page_v2.dart:314` — Analytics event data with optional business_id
- `lib/pages/business_profile/business_profile_page_v2.dart:619` — About section toggle event with optional business_id
- `lib/services/api_service.dart:154` — Search API request params with optional neighbourhoodId/shoppingAreaId

**Common in:** Analytics event data, API request parameters, configuration maps with optional fields.

**Discovered:** 2026-03-03 during CI build failure — `flutter analyze` reported 3 issues blocking deployment

**Git reference:** Commit `810377f` — fix: use null-aware spread operators in map literals

---

### Pitfall #22: Using context.go() Instead of context.push() for Full Pages

**Problem:** Using `context.go()` to navigate to full-page views clears the navigation stack, leaving nothing to pop back to. This breaks the back button, stranding users on the full page with no way to return.

❌ **Bad:**
```dart
// Navigate to menu full page (BREAKS BACK BUTTON)
GestureDetector(
  onTap: () => context.go('/menu/$businessId'),
  child: Text('View Full Menu'),
)
```

✅ **Good:**
```dart
// Navigate to menu full page (back button works)
GestureDetector(
  onTap: () => context.push('/menu/$businessId'),
  child: Text('View Full Menu'),
)
```

**Why this matters:**
- `context.go()` **replaces** the entire navigation stack (like browser navigation)
- `context.push()` **adds** to the navigation stack (allows popping back)
- Full page widgets use `Navigator.of(context).pop()` for back button
- Without proper stack, `pop()` has nowhere to return to

**When to use each:**
- **`context.go()`** - Top-level navigation between main sections (e.g., switching from search to profile to settings)
- **`context.push()`** - Drill-down navigation (e.g., search → business profile → gallery/menu/info full pages)

**All three full pages now use consistent pattern:**
```dart
// Gallery full page
GestureDetector(
  onTap: () => context.push('/gallery/$businessId'),  // ✅
)

// Menu full page
GestureDetector(
  onTap: () => context.push('/menu/$businessId'),     // ✅ (fixed in commit 395a536)
)

// Business Info full page
GestureDetector(
  onTap: () => context.push('/info/$businessId'),     // ✅
)
```

All three pages use `Navigator.of(context).pop()` for back buttons, which requires items in the navigation stack.

**Bug manifestation:** User taps "View Full Menu" → menu page loads → user taps back button → nothing happens (no navigation stack to pop).

**Discovered:** 2026-03-04 during full page navigation testing — menu full page back button was non-functional.

**Git reference:** Commit `395a536` — fix(navigation): change menu full page navigation from go() to push()

---

### Pitfall #23: Using AnimatedSize for Simple Expand/Collapse

**Problem:** `AnimatedSize` causes visual jankiness when animating expandable sections because it measures child dimensions on every frame. For simple expand/collapse animations, `AnimatedOpacity` provides smoother results with GPU-accelerated compositing.

❌ **Bad:**
```dart
// Janky animation due to child measurement overhead
AnimatedSize(
  duration: Duration(milliseconds: 250),
  child: _isExpanded
    ? Column(
        children: [
          OpeningHoursDisplay(),
          ContactLinksDisplay(),
          // Complex widget tree
        ],
      )
    : SizedBox.shrink(),
)
```

✅ **Good:**
```dart
// Smooth fade animation with GPU compositing
AnimatedOpacity(
  duration: Duration(milliseconds: 150),
  opacity: _isExpanded ? 1.0 : 0.0,
  child: _isExpanded
    ? Column(
        children: [
          OpeningHoursDisplay(),
          ContactLinksDisplay(),
          // Complex widget tree
        ],
      )
    : SizedBox.shrink(),
)
```

**Why this matters:**
- `AnimatedSize` measures child dimensions on every animation frame → janky
- `AnimatedOpacity` uses GPU-accelerated compositing → smooth 60fps
- Complex children (lists, columns, rows) amplify the jankiness
- Fade animations are visually cleaner for expandable sections

**When AnimatedSize IS appropriate:**
- Animating between known, simple sizes (e.g., button width: 100px → 150px)
- Single-line text expanding to two lines
- Simple containers without complex child layout
- Cases where size change must be visible (not just show/hide)

**When to use AnimatedOpacity instead:**
- Expandable sections with lists/columns
- Complex widget trees with multiple layers
- Any case where you notice animation jankiness
- Simple show/hide transitions

**Performance comparison (business profile opening hours section):**
- `AnimatedSize(250ms)`: Visible frame drops, janky motion
- `AnimatedOpacity(150ms)`: Smooth 60fps, clean fade

**Discovered:** 2026-03-04 during business profile UX improvements — opening hours/contact section animation was janky.

**Git reference:** Commit `33daf5b` — fix(profile): replace janky AnimatedSize with smooth AnimatedOpacity

---

### Pitfall #24: Filter State Management - Routing Logic and State Restoration

**Context:** Filter overlay manages complex state with three columns, parent-child hierarchies, and routed IDs (neighbourhoods, shopping areas). Two related bugs revealed architectural fragility when multiple state sources aren't properly synchronized.

#### Bug 1: Routing Logic Priority

**Problem:** Parent neighbourhoods (Indre By, Amager, Nordvest, Vanløse) have both subcategories (children) AND need immediate search triggering. Checking `hasSubitems` first routes them to column-opening logic, skipping the search trigger entirely.

❌ **Bad:**
```dart
void _handleItemSelection(FilterCategory category, int itemId) {
  final hasSubitems = category.subcategories.any((sub) => sub.filterId == itemId);

  // Parent neighbourhoods fall through to this branch - WRONG!
  if (hasSubitems) {
    _openColumn3(category, itemId);  // Opens column 3 but NO SEARCH
    return;
  }

  // Standalone items
  _handleStandaloneSelection(itemId);
}
```

✅ **Good:**
```dart
void _handleItemSelection(FilterCategory category, int itemId) {
  // CHECK PARENT NEIGHBOURHOODS FIRST (before hasSubitems check)
  if (AppConstants.kNeighborhoodHierarchy.containsKey(itemId)) {
    _handleNeighborhoodSelection(itemId);  // Handles: selection + search + column 3 + exclusivity
    return;  // Early exit prevents falling through to wrong branch
  }

  final hasSubitems = category.subcategories.any((sub) => sub.filterId == itemId);
  if (hasSubitems) {
    _openColumn3(category, itemId);
    return;
  }

  _handleStandaloneSelection(itemId);
}
```

**Why:** Parent neighbourhoods need special handling: they trigger search immediately (like standalone items) BUT also open column 3 (like items with subitems) AND enforce exclusivity (clear other neighbourhoods). Generic `hasSubitems` check doesn't capture this complexity.

#### Bug 2: State Restoration After Widget Updates

**Problem:** Widget updates from provider props overwrite `_selectedFilterIds` without restoring routed IDs (neighbourhoods, shopping areas) from provider. This orphans routed IDs, breaking filter chip display and greying logic.

❌ **Bad:**
```dart
void _handleSelectedFilterChanges() {
  // Widget updates from provider props
  setState(() {
    _selectedFilterIds = widget.selectedFilterIds;  // Overwrites local state
  });
  // Neighbourhood IDs and shopping area IDs are now ORPHANED
  // Filter chips disappear, greying logic fails
}
```

✅ **Good:**
```dart
void _handleSelectedFilterChanges() {
  setState(() {
    _selectedFilterIds = widget.selectedFilterIds;

    // RESTORE routed IDs from provider (mirrors _initializeStateFromProps pattern)
    _selectedNeighbourhoodIds = widget.selectedNeighbourhoodIds ?? [];
    _selectedShoppingAreaIds = widget.selectedShoppingAreaIds ?? [];
  });
}
```

**Why:** Routed IDs (neighbourhoods, shopping areas) live in separate provider lists because they need special routing logic. Widget updates must restore these IDs to `_selectedFilterIds` to keep UI state consistent. This mirrors the initialization pattern used in `_initializeStateFromProps()`.

**Architectural lesson:** Complex state with multiple sources (props + routing + local state) requires careful synchronization. **State update handlers must mirror initialization logic** to maintain consistency across widget rebuilds.

**Bug manifestation:**
1. User selects parent neighbourhood (e.g., "Indre By") → no search triggered, column 3 doesn't open
2. User selects filter in another category → widget rebuilds → neighbourhood chip disappears from selected filters display

**Discovered:** 2026-03-04 during filter panel testing — parent neighbourhood selection was non-functional.

**Git reference:** Commit `543e25c` — fix(filters): resolve parent neighbourhood selection not triggering search

---

### Pitfall #25: Passing Partial API Responses to Providers When Downstream Consumers Need Full Structure

**Context:** When storing API responses in providers, it's tempting to extract and pass only the "main" data array (e.g., `menuData['menu_items']`). However, if ANY downstream consumer (widget, validation logic, processing function) needs OTHER keys from the response (e.g., `categories`, `availablePreferences`), passing partial data causes silent validation failures.

**Root Cause:** MenuDishesListView._isValidNormalizedData() expects a Map with a 'categories' key. When only `menu_items` array is passed, validation fails silently, triggering `_clearDataStructures()` which results in an empty display.

❌ **Bad:**
```dart
// business_profile_page_v2.dart
final menuResponse = await ApiService.instance.getRestaurantMenu(businessId);

// Extract only menu_items array
final menuItems = menuResponse.jsonBody['menu_items'];

// Pass partial data (missing categories, availablePreferences, availableRestrictions)
ref.read(businessProvider.notifier).setMenuItems(menuItems);

// Later, in MenuDishesListView (line 812):
final categories = widget.normalizedMenuData['categories']; // ❌ NULL! Key doesn't exist
// Validation fails → empty display
```

✅ **Good:**
```dart
// business_profile_page_v2.dart
final menuResponse = await ApiService.instance.getRestaurantMenu(businessId);

// Pass FULL response Map containing ALL keys
ref.read(businessProvider.notifier).setMenuItems(menuResponse.jsonBody);
// Now available: menu_items, categories, availablePreferences, availableRestrictions

// Later, in MenuDishesListView (line 812):
final categories = widget.normalizedMenuData['categories']; // ✅ Works! Full Map passed
```

**Why:**
- Provider's `dynamic` type accepts any structure at runtime without compile-time errors
- Silent validation failures (no error logs) make data structure mismatches extremely hard to debug
- Downstream consumers may need multiple keys from API responses, not just the "main" array
- Passing full Map is safer: consumers extract what they need, unused keys are harmless

**When to pass full API response:**
- ✅ Response contains multiple top-level keys (e.g., `{menu_items: [], categories: [], filters: []}`)
- ✅ Multiple widgets/functions consume the data (can't predict all their needs)
- ✅ Validation or processing logic expects specific Map structure

**When partial extraction is safe:**
- ✅ Only ONE consumer exists and you control its implementation
- ✅ Consumer explicitly documents expected structure (e.g., `List<Map<String, dynamic>>`)
- ✅ You've verified no validation logic depends on other keys

**Reference:** Commit `5f4aeab` — "fix: menu items now display by passing full API response to provider"

**Detection:**
- Data displays empty despite successful API response
- No error logs or exceptions thrown
- Validation methods like `_isValidNormalizedData()` silently return false
- Works in one widget but breaks in another that expects different keys

**Prevention:**
- When in doubt, pass full `response.jsonBody` to providers
- Document expected structure in provider method comments
- Add debug logging to validation methods to surface silent failures

### Pitfall #26: businessHours Day Keys Use 0=Monday (Not 0=Sunday)

**Context:** The BuildShip API's `businessHours` object uses string keys `"0"` (Monday) through `"6"` (Sunday). Dart's `DateTime.weekday` returns 1=Monday through 7=Sunday. The conversion must use `weekday - 1`, NOT `weekday % 7`.

❌ **Bad:**
```dart
// OpeningHoursContactWidget — get today's hours
final todayKey = '${DateTime.now().weekday % 7}';
final todayHours = businessHours[todayKey];
// Monday(1)%7=1 → shows Tuesday's hours (off by one)
// Sunday(7)%7=0 → shows Monday's hours (off by six)
```

✅ **Good:**
```dart
final todayKey = '${DateTime.now().weekday - 1}';
final todayHours = businessHours[todayKey];
// Monday(1)-1=0 → correct
// Sunday(7)-1=6 → correct
```

**Why:** `weekday % 7` shifts every day by +1 because `DateTime.weekday` starts at 1 (Monday), not 0. The modulo wraps Sunday(7) to 0, which is Monday in the API — making it wrong for every day of the week.

**Also:** Inline code comments may incorrectly state "0=Sunday" when the API actually uses 0=Monday. Always verify against `BUILDSHIP_API_REFERENCE.md` §2 `business_hours` object.

**Reference:** Commit `6804d38` — Bug 1 in business profile API audit

---

### Pitfall #27: Unsafe `as double?` on Decoded JSON Numeric Fields

**Context:** Dart's JSON decoder returns `int` for whole numbers (e.g., `55` → `int`, `55.6` → `double`). Casting with `as double?` throws a `TypeError` at runtime when the value is actually an `int`.

❌ **Bad:**
```dart
// business_information_page.dart — read coordinates
final lat = business['latitude'] as double?;  // TypeError if value is int (e.g., 55)
final lng = business['longitude'] as double?;
```

✅ **Good:**
```dart
final lat = (business['latitude'] as num?)?.toDouble();  // Safe: int→double, double→double
final lng = (business['longitude'] as num?)?.toDouble();
```

**Why:** API responses may return whole numbers (55 vs 55.0) depending on database column precision and JSON serialization. The `as num?` cast accepts both `int` and `double`, then `.toDouble()` normalizes to `double`.

**Audit scope:** All pages reading numeric fields from decoded JSON API responses — coordinates (lat/lng), prices, counts, match scores.

**Reference:** Commit `172a66e` — business information page crash from unsafe coordinate casting

---

### Pitfall #28: Nested Scroll Physics Conflicts

**Context:** A `GridView` with `AlwaysScrollableScrollPhysics` inside a `PageView` (horizontal swipe) fights the parent for gestures. The child scroll physics intercepts vertical drags, preventing the parent `PageView` from detecting horizontal swipes.

❌ **Bad:**
```dart
// Full-page gallery tab — GridView inside horizontal PageView
GridView.builder(
  physics: const AlwaysScrollableScrollPhysics(),  // Fights parent PageView
  // ...
)
```

✅ **Good:**
```dart
// Full-page gallery: remove fixed height constraint + ClampingScrollPhysics
GridView.builder(
  physics: const ClampingScrollPhysics(),  // Cooperates with parent PageView
  shrinkWrap: true,  // Sizes to content, not viewport
  // ...
)

// Inline gallery (fixed 2-row height): NeverScrollableScrollPhysics
GridView.builder(
  physics: const NeverScrollableScrollPhysics(),  // Parent handles all scrolling
  // ...
)
```

**Rule of thumb:**
- **Full-page nested scroll:** `ClampingScrollPhysics` — allows scrolling but doesn't steal gestures
- **Fixed-height nested grid (inline):** `NeverScrollableScrollPhysics` — parent handles everything

**Reference:** Commit `b419988` — gallery full page gesture conflict fix

---

### Pitfall #29: Cache Provider Must Match Display Widget

**Context:** Using `precacheImage(NetworkImage(url))` populates Flutter's HTTP image cache, but `CachedNetworkImage` uses its own disk cache (`flutter_cache_manager`). The precached image is never found by the display widget.

❌ **Bad:**
```dart
// Precache with Flutter's ImageProvider...
await precacheImage(NetworkImage(imageUrl), context);

// ...but display with CachedNetworkImage — DIFFERENT CACHE!
CachedNetworkImage(imageUrl: imageUrl)  // Cache miss, loads from network again
```

✅ **Good:**
```dart
// Precache with CachedNetworkImageProvider (same cache layer as display widget)
await precacheImage(CachedNetworkImageProvider(imageUrl), context);

// Display with CachedNetworkImage — SAME CACHE
CachedNetworkImage(imageUrl: imageUrl)  // Cache hit!
```

**Principle:** Always match the image provider to the display widget's cache layer. `CachedNetworkImage` → `CachedNetworkImageProvider`. `Image.network` → `NetworkImage`.

**Reference:** Commit `b419988` — gallery precache was populating wrong cache layer

---

### Pitfall #30: menuCategories vs menuItems — Different Data Structures

**Context:** `MenuCategoriesRows` (the category chips widget on the menu page) expects `menuCategories` from the business profile API response. Using `menuItems` from the menu API endpoint passes the wrong data structure — similar field names but different shapes.

❌ **Bad:**
```dart
// menu_full_page.dart — using menu API response
final menuData = ref.watch(businessProvider).menuItems;
MenuCategoriesRows(categories: menuData['menu_items'])  // WRONG structure
```

✅ **Good:**
```dart
// menu_full_page.dart — extract from BUSINESS PROFILE data
final business = ref.watch(businessProvider).currentBusiness;
final menuCategories = business['menuCategories'];  // From GET_BUSINESS_PROFILE
MenuCategoriesRows(categories: menuCategories)  // Correct structure
```

**Why:** The business profile API returns `menuCategories` (category names with display order for chips). The menu API returns `menu_items` (full dish details with prices, descriptions, dietary info). They serve different purposes and have different schemas.

**Reference:** Commits `5eae0ca`, `c9e9eff` — menu category chips showed wrong data

---

### Pitfall #31: ref.read() in Computed Getters Causes Stale Data

**Context:** Using `ref.read()` in build-time getters (like `_hasAboutContent` or `_buildAboutSection`) returns a one-time snapshot. The widget never rebuilds when the underlying state changes, showing stale data.

❌ **Bad:**
```dart
class _BusinessProfileState extends ConsumerState<BusinessProfilePage> {
  // Computed getter using ref.read — reads once, never updates
  bool get _hasAboutContent {
    final business = ref.read(businessProvider).currentBusiness;  // Stale!
    return business?['description'] != null;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasAboutContent) { ... }  // May show stale value
  }
}
```

✅ **Good:**
```dart
@override
Widget build(BuildContext context) {
  // ref.watch in build() — reactive, rebuilds on state changes
  final business = ref.watch(businessProvider).currentBusiness;
  final hasAboutContent = business?['description'] != null;

  if (hasAboutContent) { ... }  // Always current
}
```

**Rule:** `ref.read()` = fire-and-forget actions (button taps, analytics). `ref.watch()` = reactive display (anything in `build()` or called from `build()`).

**Reference:** Commits `2cb5e50`, `c9e9eff` — business profile showed stale "About" section

---

### Pitfall #32: Analytics Session Timing — Fire on Page Open, Not After API Response

**Context:** Menu session analytics (`_trackMenuSessionStart`) should fire in `initState()` (page open) to capture accurate session duration. Firing after the API response arrives means slow or failed API calls produce inaccurate (or missing) timing data.

❌ **Bad:**
```dart
void _onMenuDataLoaded(dynamic menuData) {
  _trackMenuSessionStart();  // Late — session start time is after API delay
}
```

✅ **Good:**
```dart
@override
void initState() {
  super.initState();
  _trackMenuSessionStart();  // Immediate — session starts when page opens
  _menuSessionStarted = true;  // Guard for dispose()
}

@override
void dispose() {
  if (_menuSessionStarted) {  // Only end sessions that actually started
    _trackMenuSessionEnd();
  }
  super.dispose();
}
```

**Why:** Session duration = `dispose time - start time`. If start time is delayed by API latency, the duration is artificially shortened. If the API fails entirely, no session is tracked at all. Guard `dispose()` with `_menuSessionStarted` to prevent tracking sessions that never started.

**Reference:** Commits `5eae0ca`, `c9e9eff` — menu session timing accuracy fix

---

### Pitfall #33: ref.read() in dispose() Throws StateError — Cache Analytics State Early

**Context:** Calling `ref.read(analyticsProvider)` in `dispose()` throws `StateError` when navigating between business profiles. This corrupts widget tree finalization and cascades into unrelated viewport assertion and duplicate GlobalKey errors.

**Extends Pitfall #11:** Pitfall #11 covers saving a notifier reference in `initState()` for safe disposal. This pitfall covers the analytics-specific pattern where `deviceId`/`sessionId` must be cached as instance fields.

❌ **Bad:**
```dart
@override
void dispose() {
  final analytics = ref.read(analyticsProvider);  // StateError!
  ApiService.instance.postAnalytics(
    deviceId: analytics.deviceId,  // Never reached
    sessionId: analytics.sessionId,
  );
  super.dispose();
}
```

✅ **Good:**
```dart
String? _cachedDeviceId;
String? _cachedSessionId;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final analytics = ref.read(analyticsProvider);
    _cachedDeviceId = analytics.deviceId;
    _cachedSessionId = analytics.sessionId;
  });
}

@override
void dispose() {
  ApiService.instance.postAnalytics(
    deviceId: _cachedDeviceId ?? '',  // Safe — cached while ref was valid
    sessionId: _cachedSessionId ?? '',
  );
  super.dispose();
}
```

**Key insight:** A single `StateError` during finalization cascades into unrelated viewport and `GlobalKey` failures, making the root cause hard to diagnose.

**Reference:** Commit `dd052b5` — "fix: cache analytics state to avoid ref access in dispose()"

---

### Pitfall #34: TabController + PageController Dual-Control Causes Tab-Jumping Bug

**Context:** Using both `TabController` and `PageController` to control a tabbed view causes intermediate `onPageChanged` events when jumping across multiple tabs. For example, jumping from tab 0 to tab 3 fires events for tabs 1 and 2, which override the animation target.

❌ **Bad:**
```dart
// Dual controllers — onPageChanged fires for every intermediate page
TabController _tabController;
PageController _pageController;

void _onTabTap(int index) {
  _pageController.animateToPage(index, ...);
}

void _onPageChanged(int page) {
  _tabController.animateTo(page);  // Fires for tab 1, 2, then 3!
}
```

✅ **Good — _targetPage guard pattern:**
```dart
PageController _pageController;
int? _targetPage;  // Guard

void _onTabTap(int index) {
  _targetPage = index;  // 1. Set target
  _pageController.animateToPage(index, ...);
}

void _onPageChanged(int page) {
  if (_targetPage != null && page != _targetPage) return;  // 2. Ignore intermediates
  _targetPage = null;  // 3. Clear when destination reached
  setState(() => _currentPage = page);
}
```

**Rule:** When using `PageController` with animated page transitions, always guard `onPageChanged` with a `_targetPage` field to filter intermediate events.

**Reference:** Commit `a348fd4` — "refactor: unify GalleryTabWidget + InlineGalleryWidget into TabbedGalleryWidget"

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

- **Development Process:** `CODE_DEVELOPMENT_WORKFLOW.md` (systematic workflow for writing code)
- **API Contracts:** `_reference/BUILDSHIP_API_REFERENCE.md` (523 lines, 12 endpoints)
- **Provider Catalog:** `_reference/PROVIDERS_REFERENCE.md` (797 lines, 8 providers)
- **Design Tokens:** `DESIGN_SYSTEM_flutter.md` (869 lines, colors/spacing/typography)
- **Quick Start:** `CLAUDE.md` (streamlined session primer)
- **Developer Onboarding:** `CONTRIBUTING.md` (workflow and standards)

---

**Last Updated:** March 2026
**Maintainer:** Development team
**Questions?** Read this file first, then check reference docs, then ask.
