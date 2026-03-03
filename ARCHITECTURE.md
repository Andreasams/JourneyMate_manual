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
- **New to the project?** Read [Philosophy](#philosophy) (lines 39-81) and [State Management](#state-management) (lines 146-285) for 60-minute deep dive
- **Need a specific section?** Use alphabetical index below for direct access

**Section Index (Alphabetical):**
- [Analytics Architecture](#analytics-architecture) (lines 1129-1203) — Fire-and-forget, ActivityScope, 36 event types
- [API Service Pattern](#api-service-pattern) (lines 834-890) — Singleton, cache, BuildShip integration
- [Code Quality Standards](#code-quality-standards) (lines 1206-1245) — Flutter analyze, design tokens, algorithms
- [Common Pitfalls](#common-pitfalls) (lines 1248-1768) — 16 anti-patterns with fixes (⚠️ read before first commit)
- [Design Token System](#design-token-system) (lines 1116-1127) — Quick lookup tables for colors, spacing, typography
- [Documentation Philosophy](#documentation-philosophy) (lines 1771-1791) — Three types of docs, when to update
- [Key Architectural Decisions](#key-architectural-decisions) (lines 1821-1854) — CityID, favorites, filters, translations, engagement
- [Location Permission Pattern](#location-permission-pattern) (lines 973-1051) — Three methods, when to use what, Settings fallback
- [Philosophy](#philosophy) (lines 39-81) — Five core principles (design tokens, state, translations, analytics, widgets)
- [Pre-Loading Architecture](#pre-loading-architecture) (lines 893-970) — Safe async pattern for instant page loads
- [Project Structure](#project-structure) (lines 84-143) — File organization, 12 pages, 34 widgets, 8 providers
- [Provider Initialization Order](#provider-initialization-order) (lines 1794-1818) — Critical startup sequence in main.dart
- [References](#references) (lines 1857-1871) — Links to other documentation files
- [State Management](#state-management) (lines 146-285) — When to use what, provider catalog, Riverpod 3.x patterns
- [Swipe Gesture Patterns](#swipe-gesture-patterns) (lines 486-831) — 8 patterns for dismissible UI, adaptive thresholds, nested gestures
- [Translation System](#translation-system) (lines 1054-1113) — Dynamic td() function, 355 keys, 7 languages
- [Widget Patterns](#widget-patterns) (lines 288-483) — Self-contained widgets, page wrappers, bottom sheets

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

### Filter Coordination Pattern (Parent Callbacks)

**Discovered:** Commit `8606b21`, March 2026
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
    // Check if current station is still valid for new neighbourhood
    if (_currentSort == 'station' && _selectedStation != null) {
      final searchState = ref.read(searchStateProvider);
      final neighbourhoodId = searchState.selectedNeighbourhoodId;

      if (neighbourhoodId != null) {
        // Check station compatibility using same logic as filter
        final filterState = ref.read(filterProvider);
        final isStationInNeighbourhood = filterState.when(
          data: (state) {
            final stationData = state.filterLookupMap[_selectedStation];
            if (stationData != null) {
              final neighbourhoodId1 = stationData['neighbourhood_id_1'] as int?;
              final neighbourhoodId2 = stationData['neighbourhood_id_2'] as int?;
              return neighbourhoodId1 == neighbourhoodId ||
                     neighbourhoodId2 == neighbourhoodId;
            }
            return false;
          },
          loading: () => true,  // Keep station while loading
          error: (_, __) => true, // Keep station on error
        );

        // Reset to default if station is no longer valid
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
- ✅ Uses same validation logic as filter list (neighbourhood_id_1 OR neighbourhood_id_2)
- ✅ Handles AsyncData states gracefully (keeps selection while loading)

**Common Use Cases:**
- Neighbourhood filter → affects station list (commit `8606b21`)
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
  neighbourhoodId: 47,             // v9: NEW geographic filter
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

### 3. Historical Documents (Reference-only)
**Purpose:** Understand "why was this built this way?"
**Files:** `_reference/flutterflow_migration/pages/*/BUNDLE.md`, `_reference/flutterflow_migration/shared/*/MASTER_README_*.md` (207 files)
**Update when:** NEVER (read-only reference from migration phase)

**Key Rule:** If you need to understand why a page works a certain way, read the BUNDLE.md in `_reference/flutterflow_migration/`. If you need to build something new, read ARCHITECTURE.md and PROVIDERS_REFERENCE.md.

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
