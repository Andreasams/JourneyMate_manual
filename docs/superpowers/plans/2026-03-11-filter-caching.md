# Filter Caching Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add SharedPreferences caching to filters so they load instantly on app launch — no spinner, no API wait.

**Architecture:** Mirror the existing `TranslationsCacheNotifier` caching pattern. Filters are cached per-language with 7-day TTL and version bumping. On startup, cached filters load synchronously before `runApp()`. Background refresh keeps data fresh. First launch pre-fetches both Danish and English.

**Tech Stack:** Flutter/Riverpod 3.x, SharedPreferences, dart:convert (all already in project)

**Spec:** `docs/superpowers/specs/2026-03-11-filter-caching-design.md`

---

## File Structure

| File | Role | Change Type |
|------|------|-------------|
| `journey_mate/lib/providers/filter_providers.dart` | Filter provider with cache layer | Modify |
| `journey_mate/lib/main.dart` | App startup — load cached filters, conditional background refresh | Modify |
| `journey_mate/lib/pages/welcome/welcome_page.dart` | Delete unused English filter cache on Danish path | Modify |
| `journey_mate/lib/pages/app_settings_initiate_flow/app_settings_initiate_flow_page.dart` | Delete unused filter caches on setup completion | Modify |

---

## Chunk 1: FilterNotifier Cache Layer

### Task 1: Add cache constants, imports, and make `_buildLookupMap` static

**Files:**
- Modify: `journey_mate/lib/providers/filter_providers.dart:1-5` (imports) and `:66-96` (`_buildLookupMap`)

- [ ] **Step 1: Add imports and cache constants**

At top of `filter_providers.dart`, add `dart:convert` and `shared_preferences` imports. Add cache constants inside the class.

```dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'provider_state_classes.dart';
import '../services/api_service.dart';
import '../theme/app_constants.dart';
```

Inside `FilterNotifier` class, add constants after the class declaration line:

```dart
class FilterNotifier extends AsyncNotifier<FilterState> {
  /// Cache duration: 7 days (same as translations)
  static const int _cacheDurationDays = 7;

  /// Cache version — INCREMENT THIS when filter structure changes.
  /// Forces cache refresh for all users on next launch.
  ///
  /// Version history:
  /// - v1: Initial filter caching implementation (Mar 2026)
  static const int _cacheVersion = 1;
```

- [ ] **Step 2: Make `_buildLookupMap` static**

Change `_buildLookupMap` from instance method to static method. It's already pure (no `this` references).

```dart
  /// Build flat lookup map from hierarchical filter structure
  static Map<int, dynamic> _buildLookupMap(dynamic filters) {
```

Update the call site in `loadFiltersForLanguage` — it already works because static methods are callable from instance methods.

- [ ] **Step 3: Verify the app compiles**

Run: `cd journey_mate && flutter analyze lib/providers/filter_providers.dart`
Expected: No errors (static method is compatible with existing call site)

- [ ] **Step 4: Commit**

```bash
git add journey_mate/lib/providers/filter_providers.dart
git commit -m "refactor: add filter cache imports and make _buildLookupMap static

Preparation for filter caching. No behavior change."
```

---

### Task 2: Add `_saveToCache` and `clearCacheForLanguage` methods

**Files:**
- Modify: `journey_mate/lib/providers/filter_providers.dart`

- [ ] **Step 1: Add `_saveToCache` instance method**

Add after the `clear()` method, before the closing brace of the class:

```dart
  /// Save filter data to SharedPreferences cache with version metadata.
  /// Called after successful API fetch to persist for next launch.
  Future<void> _saveToCache(
    String languageCode,
    dynamic filters,
    List<dynamic> foodDrinkTypes,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final filtersJson = jsonEncode(filters);
      final foodDrinkTypesJson = jsonEncode(foodDrinkTypes);

      await prefs.setString('filters_$languageCode', filtersJson);
      await prefs.setString('filters_${languageCode}_foodDrinkTypes', foodDrinkTypesJson);
      await prefs.setInt('filters_${languageCode}_timestamp', DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt('filters_${languageCode}_version', _cacheVersion);
    } catch (e) {
      // Non-critical — continue without caching
    }
  }
```

- [ ] **Step 2: Add `clearCacheForLanguage` static method**

Add after `_saveToCache`:

```dart
  /// Remove cached filter data for a specific language.
  /// Called when user picks a language and the other pre-fetched cache is no longer needed.
  static Future<void> clearCacheForLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('filters_$languageCode');
      await prefs.remove('filters_${languageCode}_foodDrinkTypes');
      await prefs.remove('filters_${languageCode}_timestamp');
      await prefs.remove('filters_${languageCode}_version');
    } catch (e) {
      // Fail silently
    }
  }
```

- [ ] **Step 3: Verify the app compiles**

Run: `cd journey_mate && flutter analyze lib/providers/filter_providers.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add journey_mate/lib/providers/filter_providers.dart
git commit -m "feat: add filter cache write and clear methods

_saveToCache persists filter JSON to SharedPreferences.
clearCacheForLanguage removes a single language's cache entries."
```

---

### Task 3: Add `loadFromCache` and `isCacheFresh` static methods

**Files:**
- Modify: `journey_mate/lib/providers/filter_providers.dart`

- [ ] **Step 1: Add `loadFromCache` static method**

Add after `clearCacheForLanguage`:

```dart
  /// Load cached filters from SharedPreferences (if available and valid).
  /// Returns FilterState.initial() if cache is missing or version is outdated.
  /// Rebuilds filterLookupMap from deserialized JSON (derived data, not cached).
  static Future<FilterState> loadFromCache(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final filtersJson = prefs.getString('filters_$languageCode');
      final foodDrinkTypesJson = prefs.getString('filters_${languageCode}_foodDrinkTypes');
      final version = prefs.getInt('filters_${languageCode}_version');

      if (filtersJson == null || filtersJson.isEmpty) {
        return FilterState.initial();
      }

      // Cache version mismatch — don't use stale cache
      if (version != _cacheVersion) {
        return FilterState.initial();
      }

      final filters = jsonDecode(filtersJson);
      final foodDrinkTypes = foodDrinkTypesJson != null
          ? (jsonDecode(foodDrinkTypesJson) as List)
          : <dynamic>[];

      // Rebuild lookup map from deserialized data (derived, not cached)
      final lookupMap = _buildLookupMap(filters);

      return FilterState(
        filtersForLanguage: filters,
        filterLookupMap: lookupMap,
        foodDrinkTypes: foodDrinkTypes,
      );
    } catch (e) {
      return FilterState.initial();
    }
  }
```

- [ ] **Step 2: Add `isCacheFresh` static method**

Add after `loadFromCache`:

```dart
  /// Check if cached filters exist and are still valid.
  /// Returns false if no cache, older than 7 days, or version mismatch.
  static Future<bool> isCacheFresh(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('filters_${languageCode}_timestamp');
      final version = prefs.getInt('filters_${languageCode}_version');

      // No cache exists
      if (timestamp == null) return false;

      // Cache version mismatch
      if (version != _cacheVersion) return false;

      // Check age
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final cacheDuration = Duration(days: _cacheDurationDays).inMilliseconds;

      return cacheAge < cacheDuration;
    } catch (e) {
      return false;
    }
  }
```

- [ ] **Step 3: Verify the app compiles**

Run: `cd journey_mate && flutter analyze lib/providers/filter_providers.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add journey_mate/lib/providers/filter_providers.dart
git commit -m "feat: add filter cache read and freshness check methods

loadFromCache reads persisted filters and rebuilds lookup map.
isCacheFresh checks 7-day TTL and version match."
```

---

### Task 4: Add `initializeFromPrefs` and modify `loadFiltersForLanguage`

**Files:**
- Modify: `journey_mate/lib/providers/filter_providers.dart:18-63`

- [ ] **Step 1: Add `initializeFromPrefs` instance method**

Add after the `build()` method:

```dart
  /// Synchronously initialize from cached filter data (called at startup).
  /// Sets state to AsyncData with cached filters so consumers never see AsyncLoading.
  void initializeFromPrefs(FilterState cachedFilterState) {
    if (cachedFilterState.filtersForLanguage != null) {
      state = AsyncData(cachedFilterState);
    }
  }
```

- [ ] **Step 2: Add `fetchAndCacheOnly` method for first-launch dual-fetch**

This method fetches from API and caches to SharedPreferences **without** setting provider state. Used on first launch to cache the second language silently.

Add after `initializeFromPrefs`:

```dart
  /// Fetch filters from API and cache to SharedPreferences only.
  /// Does NOT update provider state. Used on first launch to pre-cache
  /// a second language (e.g. English) while provider state holds the primary (Danish).
  Future<void> fetchAndCacheOnly(
    String languageCode, {
    String? cityId,
  }) async {
    try {
      final response = await ApiService.instance.getFiltersForSearch(
        languageCode: languageCode,
        cityId: cityId ?? AppConstants.kDefaultCityId.toString(),
      );

      if (response.succeeded && response.jsonBody != null) {
        final body = response.jsonBody as Map<String, dynamic>;
        final filters = body['filters'];
        final foodDrinkTypes = body['foodDrinkTypes'] ?? [];
        final foodDrinkTypesList = foodDrinkTypes is List ? foodDrinkTypes : <dynamic>[];

        // Cache only — don't set provider state
        _saveToCache(languageCode, filters, foodDrinkTypesList);
      }
    } catch (e) {
      // Fail silently — this is a background pre-cache
    }
  }
```

- [ ] **Step 3: Modify `loadFiltersForLanguage` — avoid AsyncLoading when data exists, add cache save**

Replace the entire `loadFiltersForLanguage` method:

```dart
  /// Load filters for a specific language and city from API.
  /// [cityId] defaults to [AppConstants.kDefaultCityId] (Copenhagen).
  /// When a city selector is added, pass the selected city ID here.
  ///
  /// Caching behavior:
  /// - When previous data exists: keeps it visible during refresh (no spinner flash)
  /// - When no data exists: sets AsyncLoading (first load)
  /// - After successful fetch: saves to SharedPreferences for next launch
  Future<void> loadFiltersForLanguage(
    String languageCode, {
    String? cityId,
  }) async {
    // Only show loading state if no data exists yet (first load).
    // When refreshing, keep previous data visible — no spinner flash.
    final hasData = state.valueOrNull?.filtersForLanguage != null;
    if (!hasData) {
      state = const AsyncLoading();
    }

    try {
      // Call API
      final response = await ApiService.instance.getFiltersForSearch(
        languageCode: languageCode,
        cityId: cityId ?? AppConstants.kDefaultCityId.toString(),
      );

      if (response.succeeded && response.jsonBody != null) {
        final body = response.jsonBody as Map<String, dynamic>;

        // Extract filters hierarchy and foodDrinkTypes
        final filters = body['filters'];
        final foodDrinkTypes = body['foodDrinkTypes'] ?? [];
        final foodDrinkTypesList = foodDrinkTypes is List ? foodDrinkTypes : <dynamic>[];

        // Build lookup map from hierarchy
        final lookupMap = _buildLookupMap(filters);

        // Update state with loaded data
        state = AsyncData(FilterState(
          filtersForLanguage: filters,
          filterLookupMap: lookupMap,
          foodDrinkTypes: foodDrinkTypesList,
        ));

        // Persist to cache for next launch
        _saveToCache(languageCode, filters, foodDrinkTypesList);

      } else {
        // Only set initial state if we don't already have data
        if (!hasData) {
          state = AsyncData(FilterState.initial());
        }
      }
    } catch (e, stackTrace) {
      // Only set error state if we don't already have data.
      // When refreshing, keep previous data visible.
      if (!hasData) {
        state = AsyncError(e, stackTrace);
      }
    }
  }
```

- [ ] **Step 4: Verify the app compiles**

Run: `cd journey_mate && flutter analyze lib/providers/filter_providers.dart`
Expected: No errors

- [ ] **Step 5: Commit**

```bash
git add journey_mate/lib/providers/filter_providers.dart
git commit -m "feat: add filter initializeFromPrefs, fetchAndCacheOnly, and cache-aware loadFiltersForLanguage

initializeFromPrefs sets cached data at startup (no AsyncLoading).
fetchAndCacheOnly caches a language without setting provider state (first-launch dual-fetch).
loadFiltersForLanguage now:
- Keeps previous data visible during refresh (no spinner flash)
- Saves to SharedPreferences after successful API fetch"
```

---

## Chunk 2: main.dart Startup Integration

### Task 5: Load cached filters at startup and update background loader

**Files:**
- Modify: `journey_mate/lib/main.dart`

- [ ] **Step 1: Add cached filter loading in sync phase (before runApp)**

In `main()`, after the `cachedTranslations` and `isCacheFresh` lines (after line 48), add filter cache loading:

```dart
  // Detect first launch vs returning user (before storedLanguage applies ?? 'en' fallback)
  final hasStoredLanguage = prefs.getString('user_language_code') != null;

  // Load cached filters from SharedPreferences (if available)
  final cachedFilters = hasStoredLanguage
      ? await FilterNotifier.loadFromCache(storedLanguage)
      : FilterState.initial();
  final isFilterCacheFresh = hasStoredLanguage
      ? await FilterNotifier.isCacheFresh(storedLanguage)
      : false;
```

After the `translationsCacheProvider.notifier` init (after line 83), add filter init:

```dart
  container.read(filterProvider.notifier).initializeFromPrefs(cachedFilters);
```

- [ ] **Step 2: Update `_loadAppDataInBackground` signature and logic**

Replace the entire `_loadAppDataInBackground` function:

```dart
/// Loads translations and filters in the background with retry logic.
/// App is already visible — cached data is shown immediately.
/// [skipTranslations] - If true, skip translation refresh (cache is fresh)
/// [skipFilters] - If true, skip filter refresh (cache is fresh)
/// [isFirstLaunch] - If true, fetch filters for both 'da' and 'en'
Future<void> _loadAppDataInBackground(
  ProviderContainer container,
  String languageCode,
  bool skipTranslations,
  bool skipFilters,
  bool isFirstLaunch,
) async {
  const maxAttempts = 3;
  const retryDelay = Duration(seconds: 2);

  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      final futures = <Future>[];

      // Translations: skip if cache is fresh
      if (!skipTranslations) {
        futures.add(
          container.read(translationsCacheProvider.notifier).loadTranslations(languageCode),
        );
      }

      // Filters: skip if cache is fresh
      if (!skipFilters) {
        if (isFirstLaunch) {
          // First launch: fetch Danish (sets provider state) + cache English silently.
          // Danish is the best-guess default (primary market). If user picks a
          // different language in setup wizard, LanguageSelectorButton overwrites state.
          futures.add(
            container.read(filterProvider.notifier).loadFiltersForLanguage('da'),
          );
          futures.add(
            container.read(filterProvider.notifier).fetchAndCacheOnly('en'),
          );
        } else {
          futures.add(
            container.read(filterProvider.notifier).loadFiltersForLanguage(languageCode),
          );
        }
      }

      if (futures.isNotEmpty) {
        await Future.wait(futures).timeout(const Duration(seconds: 10));
      }

      return; // Success
    } catch (e) {
      if (attempt < maxAttempts) {
        await Future.delayed(retryDelay);
      }
    }
  }
}
```

- [ ] **Step 3: Update the `_loadAppDataInBackground` call site**

Replace line 100 (`unawaited(_loadAppDataInBackground(...))`):

```dart
  // ── 7. Background: refresh translations + filters (skip if cache is fresh) ──
  unawaited(_loadAppDataInBackground(
    container,
    storedLanguage,
    isCacheFresh,          // skipTranslations
    isFilterCacheFresh,    // skipFilters
    !hasStoredLanguage,    // isFirstLaunch
  ));
```

- [ ] **Step 4: Update the main.dart doc comment**

Replace the doc comment at the top of `main()` (lines 14-27):

```dart
/// Main entry point — optimized for fast startup with translation + filter caching.
///
/// Strategy: Show welcome page in <200ms with translations AND filters loaded instantly.
/// 1. Single SharedPreferences.getInstance() call
/// 2. Batch-read all stored keys + cached translations + cached filters
/// 3. AnalyticsService.initializeWithPrefs() (only async: UUID write on first launch)
/// 4. Synchronous provider initialization:
///    - FIRST LAUNCH: Welcome page fallbacks (5 keys), no filter cache yet
///    - SUBSEQUENT LAUNCHES: Full cached translations + filters (<100ms)
/// 5. runApp() — user sees welcome page with full translations immediately
/// 6. Background: refresh translations/filters if stale, or dual-fetch on first launch
///
/// CACHE VERSIONING: Increment TranslationsCacheNotifier._cacheVersion or
/// FilterNotifier._cacheVersion when adding new features to force cache refresh.
```

- [ ] **Step 5: Verify the app compiles**

Run: `cd journey_mate && flutter analyze lib/main.dart`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add journey_mate/lib/main.dart
git commit -m "feat: load cached filters at startup, dual-fetch on first launch

Returning users: filters loaded from SharedPreferences before runApp().
First launch: background fetches both 'da' and 'en' filters in parallel.
Cache-fresh filters skip API call entirely."
```

---

## Chunk 3: Cache Cleanup in Welcome and Setup Pages

### Task 6: Delete English filter cache on Danish quick path

**Files:**
- Modify: `journey_mate/lib/pages/welcome/welcome_page.dart:189-213`

- [ ] **Step 1: Add import for FilterNotifier**

Add to the imports at top of `welcome_page.dart`:

```dart
import '../../providers/filter_providers.dart';
```

- [ ] **Step 2: Add cache cleanup in `_handleDanishDirect`**

In `_handleDanishDirect`, after the `await prefs.setString('user_language_code', 'da');` line (line 196), add:

```dart
      // Delete English filter cache (user chose Danish, don't need English)
      FilterNotifier.clearCacheForLanguage('en');
```

Note: fire-and-forget (no `await`) — non-critical cleanup shouldn't block navigation.

- [ ] **Step 3: Verify the app compiles**

Run: `cd journey_mate && flutter analyze lib/pages/welcome/welcome_page.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add journey_mate/lib/pages/welcome/welcome_page.dart
git commit -m "feat: delete English filter cache when user picks Danish path

Cleanup of unused pre-fetched filter cache. Danish filters
already cached from first-launch background dual-fetch."
```

---

### Task 7: Delete unused filter caches on setup wizard completion

**Files:**
- Modify: `journey_mate/lib/pages/app_settings_initiate_flow/app_settings_initiate_flow_page.dart:198-220`

- [ ] **Step 1: Add import for FilterNotifier**

Add to the imports at top of `app_settings_initiate_flow_page.dart`:

```dart
import '../../providers/filter_providers.dart';
```

- [ ] **Step 2: Add cache cleanup in `_handleCompleteSetup`**

In `_handleCompleteSetup`, after `ref.read(localeProvider.notifier).setLocale(_currentLanguageCode);` (line 208), add:

```dart
      // Delete pre-fetched filter caches for languages the user didn't pick.
      // The chosen language's cache was set by LanguageSelectorButton's
      // loadFiltersForLanguage call (or exists from first-launch dual-fetch for 'en').
      if (_currentLanguageCode != 'da') {
        FilterNotifier.clearCacheForLanguage('da');
      }
      if (_currentLanguageCode != 'en') {
        FilterNotifier.clearCacheForLanguage('en');
      }
```

- [ ] **Step 3: Verify the app compiles**

Run: `cd journey_mate && flutter analyze lib/pages/app_settings_initiate_flow/app_settings_initiate_flow_page.dart`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add journey_mate/lib/pages/app_settings_initiate_flow/app_settings_initiate_flow_page.dart
git commit -m "feat: delete unused filter caches on setup wizard completion

Cleans up pre-fetched da/en filter caches, keeping only the
language the user selected."
```

---

## Chunk 4: Final Verification

### Task 8: Full app compile check and manual verification plan

- [ ] **Step 1: Run full project analysis**

Run: `cd journey_mate && flutter analyze`
Expected: No new errors or warnings from our changes

- [ ] **Step 2: Verify no dead code was introduced**

Check that all new methods in `FilterNotifier` are referenced:
- `_saveToCache` — called from `loadFiltersForLanguage` and `fetchAndCacheOnly`
- `fetchAndCacheOnly` — called from `main.dart` (first-launch background dual-fetch)
- `clearCacheForLanguage` — called from `welcome_page.dart` and `app_settings_initiate_flow_page.dart`
- `loadFromCache` — called from `main.dart`
- `isCacheFresh` — called from `main.dart`
- `initializeFromPrefs` — called from `main.dart`
- `_buildLookupMap` (now static) — called from `loadFiltersForLanguage` and `loadFromCache`

- [ ] **Step 3: Commit final state**

If any lint fixes needed from Step 1, commit them:

```bash
git add -A
git commit -m "fix: address any lint issues from filter caching implementation"
```

- [ ] **Step 4: Manual test plan (for user to verify on device)**

Test these scenarios:

1. **Fresh install / first launch:**
   - Delete app, reinstall
   - Open app → welcome page appears
   - Wait 2-3 seconds (background dual-fetch)
   - Tap "Fortsæt på dansk" → search page → open filter sheet → filters visible immediately

2. **Returning user (app restart):**
   - Close app completely, reopen
   - Search page loads → open filter sheet → filters visible immediately (no spinner)

3. **Language switch:**
   - Go to Settings → change language
   - Go back to search → open filter sheet → filters in new language

4. **Setup wizard path:**
   - Fresh install → tap "Continue" → pick a language → tap "Complete setup"
   - Open filter sheet → filters visible in chosen language
