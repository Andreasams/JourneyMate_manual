# Filter Caching Design

**Date:** 2026-03-11
**Status:** Ready for Review
**Problem:** Filters are fetched from API on every app launch with no caching. Users see a spinner when opening the filter sheet because filters haven't loaded yet.

---

## Goal

Filters load instantly from cache on every app launch — no spinner, no waiting. The filter sheet is always ready when the user opens it.

## User Experience

### First Launch
1. App starts, shows welcome page
2. No stored language exists — skip cache loading, proceed to fresh fetch
3. Background: downloads filters for **both Danish and English** (two parallel API calls)
4. Both are cached to SharedPreferences
5. User taps "Continue" (enters setup wizard) or "Fortsæt på dansk" (Danish direct path)
6. **Danish path:** deletes English filter cache, navigates to search — Danish filters ready
7. **Setup wizard:** user picks language + currency, taps "Complete setup" — deletes all filter caches except the chosen language, navigates to search — filters ready

### Returning User (Every Subsequent Launch)
1. App starts, reads stored `user_language_code`
2. Loads cached filters for that language synchronously from SharedPreferences
3. Filters are available immediately — no API wait, no spinner
4. Background: checks if cache is stale (>7 days or version mismatch)
5. If stale, refreshes from API and updates cache silently (previous data stays visible)
6. User opens filter sheet — filters always there

### Language Switch (Settings Page)
1. User changes language in Settings
2. API call fetches filters for new language (unavoidable — only current language is cached)
3. Previous filter data stays visible during fetch (no spinner flash)
4. After API responds, new filters replace old, and are cached to SharedPreferences
5. User navigates back to search — filters ready (API call had time to complete)

## Technical Design

### Cache Storage (SharedPreferences)

Per-language keys, same pattern as translations:

| Key | Type | Purpose |
|-----|------|---------|
| `filters_{lang}` | String (JSON) | Filter hierarchy |
| `filters_{lang}_foodDrinkTypes` | String (JSON) | Food/drink type list |
| `filters_{lang}_timestamp` | int (epoch ms) | When cache was written |
| `filters_{lang}_version` | int | Cache version for forced refresh |

Example: `filters_da`, `filters_da_foodDrinkTypes`, `filters_da_timestamp`, `filters_da_version`

**Note:** `filterLookupMap` is NOT cached — it's derived data. It is rebuilt by calling `_buildLookupMap()` on the deserialized `filtersForLanguage` JSON when loading from cache.

### Cache Policy
- **TTL:** 7 days (same as translations)
- **Version:** Starts at 1, increment to force cache refresh for all users
- **Freshness check:** `timestamp < 7 days AND version == current`

### FilterNotifier Changes

Stays as `AsyncNotifier<FilterState>`. The `build()` method already returns `FilterState.initial()` which resolves as `AsyncData` (not `AsyncLoading`). The `initializeFromPrefs()` method overwrites this with cached data — also `AsyncData`. So from the consumer's perspective, filter state is never `AsyncLoading` on startup.

**Constraint:** `build()` must remain synchronous (return immediately with no `await`) so that `state` is accessible before `runApp()`. This matches the existing pattern — `build()` just returns `FilterState.initial()` with no async work.

**New static methods (mirroring TranslationsCacheNotifier):**

- `loadFromCache(lang)` — reads from SharedPreferences, deserializes JSON, rebuilds `filterLookupMap` via `_buildLookupMap()`, returns `FilterState` or `FilterState.initial()` if missing/stale version
- `isCacheFresh(lang)` — checks TTL + version match
- `clearCacheForLanguage(lang)` — removes one language's 4 cache entries

**New instance methods:**

- `initializeFromPrefs(cachedFilterState)` — sets `state = AsyncData(cached)`, called from `main.dart` after build completes
- `_saveToCache(lang, filters, foodDrinkTypes)` — persists to SharedPreferences after successful API fetch

**Modified method:**
- `loadFiltersForLanguage()` — two changes:
  1. After successful API response, calls `_saveToCache()` to persist
  2. When previous data exists, does NOT set `state = AsyncLoading` — keeps previous data visible during refresh. Only sets `AsyncLoading` when no data exists (truly first load)

**To support `loadFromCache` calling `_buildLookupMap`:** Make `_buildLookupMap` a static method (it's already pure — takes input, returns output, no side effects).

### main.dart Changes

**Startup sequence (synchronous init phase, before runApp):**
```
1. Check if user_language_code exists in SharedPreferences
2. If it exists (returning user):
   a. Load cached filters via FilterNotifier.loadFromCache(storedLanguage)
   b. Check freshness via FilterNotifier.isCacheFresh(storedLanguage)
   c. Call filterNotifier.initializeFromPrefs(cachedFilterState)
   → Filters immediately available as AsyncData
3. If it doesn't exist (first launch):
   a. Skip cache loading entirely (nothing to load)
   → Filters stay as AsyncData(FilterState.initial()) until background fetch completes
```

**Background phase (after runApp, unawaited):**
```
First launch (no stored language):
  - _loadAppDataInBackground detects first launch (no stored language)
  - Calls loadFiltersForLanguage('da') and loadFiltersForLanguage('en') via Future.wait
    (translations still fetched once for default language as before)
  - Both results cached to SharedPreferences via _saveToCache
  - Provider state set from 'da' — best-guess default for Danish quick path.
    Overwritten if user picks a different language in setup wizard.
  - Note: Does NOT set AsyncLoading since this is the initial load path

Returning user, cache is fresh:
  - Skip filter API call entirely (already loaded from cache in sync phase)

Returning user, cache is stale:
  - Refresh from API silently (previous cached data stays visible)
  - Update cache on success
```

### welcome_page.dart Changes

**"Fortsæt på dansk" handler (`_handleDanishDirect`):**
- After saving language preference, delete English filter cache: `FilterNotifier.clearCacheForLanguage('en')`
- Danish filters already cached from background dual-fetch

**"Continue" handler (`_handleEnglishSetup`):**
- No cache cleanup here — user hasn't chosen their language yet (entering setup wizard)

### app_settings_initiate_flow_page.dart Changes

**"Complete setup" handler (`_handleCompleteSetup`):**
- After persisting the chosen language, delete filter caches for all other languages
- Simple approach: delete both `da` and `en` caches, then the chosen language's cache survives because it was set by `LanguageSelectorButton`'s `loadFiltersForLanguage` call (which caches after API response)
- If user kept default English (never changed language selector), English cache from first-launch dual-fetch is already present

### language_selector_button.dart Changes

No changes needed. The existing `loadFiltersForLanguage()` call already happens on language switch, and with the `_saveToCache` addition in `FilterNotifier`, caching is automatic.

## Files Changed

| File | Change |
|------|--------|
| `filter_providers.dart` | Add `dart:convert` + `shared_preferences` imports, add cache methods (`loadFromCache`, `isCacheFresh`, `clearCacheForLanguage`, `initializeFromPrefs`, `_saveToCache`), make `_buildLookupMap` static, modify `loadFiltersForLanguage` to persist and avoid AsyncLoading when data exists |
| `main.dart` | Load cached filters in sync phase (like translations), dual-language fetch on first launch, conditional background refresh |
| `welcome_page.dart` | Delete English filter cache in `_handleDanishDirect` |
| `app_settings_initiate_flow_page.dart` | Delete unused filter caches in `_handleCompleteSetup` |

**No new files. No new dependencies (SharedPreferences and dart:convert already used in project).**

## What This Does NOT Change

- Filter API contract (same endpoint, same parameters)
- Filter UI consumers (same `.when()` pattern, same widgets)
- Search results flow (independent from filters)
- Translation caching (untouched)
- FilterState class (no changes to provider_state_classes.dart)

## Edge Cases

| Scenario | Behavior |
|----------|----------|
| First launch, no internet | Filters fail to download, cache stays empty. FilterState is `AsyncData(initial)` with null filters — filter sheet shows error text, not spinner |
| Cache exists but API fails on background refresh | Keep using cached data (stale but functional) |
| User force-kills app during first launch | On next launch: no stored language → treated as first launch again → dual-fetch retried. Any partial cache from previous attempt is harmless (overwritten or cleaned up when user picks language) |
| Cache version bumped in app update | `loadFromCache` and `isCacheFresh` reject old version → fresh fetch on next launch |
| User picks language other than da/en in setup wizard | LanguageSelectorButton triggers `loadFiltersForLanguage` which fetches from API and caches. On "Complete setup", da + en caches cleaned up |
| Language switch in Settings, API fails | Previous filter data stays visible (no AsyncLoading set). User can still use filters. Next app launch retries |

## Success Criteria

1. Returning users never see a filter spinner on app launch
2. First-launch users see filters immediately after picking their language
3. Filter cache persists across app kills and restarts
4. Language switch caches new language for next session
5. No spinner flash during background refresh or language switch
6. No regression in filter display or selection behavior
