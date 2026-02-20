# BUNDLE_STANDARD.md
## The standard every BUNDLE.md must satisfy

**Phase:** Phase 2 — Documentation Audit
**Created:** 2026-02-20
**Used by:** BUNDLE_AUDIT_REPORT.md and all Phase 3 page implementation sessions

This document defines the 10 required sections every BUNDLE.md must contain, the
minimum bar for each section, and one example per section. All 14 existing BUNDLE.md
files are audited against this standard. Phase 3 implementers must read the relevant
BUNDLE.md before writing a single line of code.

---

## Required Metadata Block

Every BUNDLE.md must open with a metadata block before any sections:

```markdown
**FlutterFlow source:** `_flutterflow_export/lib/pages/[widget_name]/[widget_name]_widget.dart`
**Route name:** `WidgetName.routeName` (e.g. `WelcomePage`)
**Route path:** `/routePath` (e.g. `/welcomePage`)
**Status:** ⏳ Ready to implement | 🔄 In Progress | ✅ Complete
**Last updated:** YYYY-MM-DD
```

**Minimum bar:** All five fields present. Status badge set to ⏳ until implementation begins.

---

## Section 1 — Page Purpose

**What it defines:** 1–3 sentences. What problem this page solves for the user. Not a
technical description — a user-facing description.

**Minimum bar:** At least 1 sentence. Must name the user's goal (what they can accomplish
on this page), not just the widget class name.

**Fails if:** "This is the SearchResultsWidget page." (name only, no purpose)

**Example:**
> The Search page is the app's home screen. Users type free text to find restaurants and
> apply dietary/location filters to narrow results. Every search interaction is tracked to
> improve recommendations.

---

## Section 2 — Routes

**What it defines:** All entry points (where the user comes from + the trigger that
navigates here) and all exit points (where the user can go + the trigger + any params passed).

**Minimum bar:** At least one entry point and one exit point. Must specify the trigger
(button tap, app launch, etc.), not just the destination name.

**Fails if:** "Navigates to BusinessProfile" — missing trigger and missing params.

**Example:**
```markdown
### Entry points
| From | Trigger |
|------|---------|
| App launch | No existing session → first screen |
| BusinessProfile | Back button tap |

### Exit points
| To | Trigger | Params passed |
|----|---------|---------------|
| BusinessProfile | Restaurant card tap | `business_id` via FFAppState `mostRecentlyViewedBusiness` |
| FilterSheet | Filter button tap | None — sheet reads state directly |
```

---

## Section 3 — Riverpod State

**What it defines:** For each Riverpod provider this page touches: which fields it reads,
which notifier methods it calls to write, and the user-visible reason.

Provider names and field names must exactly match `_reference/MASTER_STATE_MAP.md`.

**Minimum bar:** Tables for Reads and Writes. Every `FFAppState` reference in the
FlutterFlow source must appear here, mapped to its Riverpod provider. If a page reads
nothing from providers, state "None — page uses only local state."

**Fails if:** Empty section, or uses old FFAppState names without provider mapping.

**Example:**
```markdown
### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(translationsCacheProvider)` | `translationsCache` | All translated text on this page |
| `ref.watch(searchStateProvider)` | `searchResults` | Restaurant list |
| `ref.watch(searchStateProvider)` | `filtersUsedForSearch` | Active filter chips |
| `ref.watch(locationProvider)` | `hasPermission` | Sort by distance when true |

### Writes
| Provider | Notifier method | Trigger |
|----------|----------------|---------|
| `ref.read(searchStateProvider.notifier).updateResults(...)` | `updateResults` | Search API response received |
| `ref.read(searchStateProvider.notifier).setFilters(...)` | `setFilters` | User taps filter chip |
```

---

## Section 4 — Local State

**What it defines:** All widget-level state variables that are NOT stored in any Riverpod
provider. These are `ConsumerStatefulWidget` instance variables.

Cross-reference: `MASTER_STATE_MAP.md` Section "Page-Local Variables" confirms which
FFAppState vars become local state.

**Minimum bar:** Explicit list with type, default value, and purpose. If a page has no
local state, state "None."

**Fails if:** Omits variables that appear in the FlutterFlow source as local page state.

**Example:**
```markdown
| Variable | Type | Default | Purpose |
|----------|------|---------|---------|
| `_filterOverlayOpen` | `bool` | `false` | Controls filter sheet visibility |
| `_cityPickerOpen` | `bool` | `false` | Controls city picker overlay |
| `_pageStartTime` | `DateTime` | `DateTime.now()` | Analytics duration calculation |
```

---

## Section 5 — API Calls

**What it defines:** Every BuildShip API call this page makes. Must include: endpoint
name (from `BUILDSHIP_API_REFERENCE.md`), trigger condition, exact input parameters
sent, and which response fields are used.

**Minimum bar:** One row per API call. Must cross-reference `BUILDSHIP_API_REFERENCE.md`
endpoint name. "No API calls" is a valid and acceptable entry.

**Fails if:** "Calls the search API" — no endpoint name, no inputs, no outputs used.

**Example:**
```markdown
| Endpoint | Trigger | Inputs sent | Response fields used |
|----------|---------|-------------|---------------------|
| `SEARCH` | User submits search or filter | `filters`, `city_id="17"`, `search_input`, `userLocation`, `language_code` | `documents` → `searchStateProvider.searchResults`, `resultCount` → `searchResultsCount` |
| `GET_UI_TRANSLATIONS` | Language change | `languageCode` | Full map → `translationsCacheProvider` |
```

---

## Section 6 — Translation Keys

**What it defines:** Every UI string displayed on this page, identified by its Supabase
translation key, English text, and Danish text. Separates page-level keys (from
`FFLocalizations`) from widget-level keys (from `getTranslations()` / `translationsCache`).

Cross-reference: `MASTER_TRANSLATION_KEYS.md` for verified key → value pairs.

**Minimum bar:** Table covering all visible text. Must note which system (FFLocalizations
static strings vs. Supabase dynamic via `translationsCache`). "No translated text" is valid.

**Fails if:** Lists only 3 keys when the page clearly has 10 visible text elements.

**Example:**
```markdown
### Page-level keys (FFLocalizations static)
| Key | English | Danish |
|-----|---------|--------|
| `6dww9uct` | Welcome to JourneyMate | Velkommen til JourneyMate |
| `d2mrwxr4` | Continue | Fortsæt |

### Widget-level keys (Supabase via translationsCache)
Used inside custom widgets — see widget BUNDLE/README for their keys.
```

---

## Section 7 — Actions & Interactions

**What it defines:** A catalogue of every user gesture on this page, mapping it to: what
state changes, what navigation occurs, what analytics event fires, and what API call
triggers (if any).

**Minimum bar:** One row per distinct user action. Must be exhaustive — every button,
every tap target, every gesture. "No user interactions" is only valid for pure display pages.

**Fails if:** Describes navigation without listing the analytics event. Omits back button.

**Example:**
```markdown
| User action | State change | Navigation | Analytics | API call |
|-------------|-------------|------------|-----------|----------|
| Tap restaurant card | `businessProvider.currentBusiness` ← card data | → BusinessProfile | `business_clicked` event | None |
| Tap filter chip | `searchStateProvider.filtersUsedForSearch` updated | None | `filter_applied` event | `SEARCH` re-triggered |
| Tap back (OS) | None | ← Previous page | `page_viewed` with duration on dispose | None |
```

---

## Section 8 — Widgets

**What it defines:** All non-trivial UI components used on this page. Custom widgets
(from `shared/widgets/`), shared widgets (from `shared/`), and complex in-page components.
Must include constructor params passed and a path to the widget's own README/BUNDLE.

**Minimum bar:** One row per custom widget. Standard Flutter widgets (Text, Column, etc.)
do not need to be listed. Must include path to widget documentation.

**Fails if:** "Uses FilterOverlayWidget" — no params, no README path.

**Example:**
```markdown
| Widget | Params passed | Documentation |
|--------|---------------|---------------|
| `SearchResultsListView` | `searchResults`, `filtersUsedForSearch`, `locationStatus`, `fontScale` | `shared/widgets/MASTER_README_search_results_list_view.md` |
| `FilterOverlayWidget` | `onClose: () => setState(...)`, `languageCode`, `translationsCache` | `shared/widgets/MASTER_README_filter_overlay_widget.md` |
| `NavBarWidget` | `currentIndex: 0` | `shared/widgets/MASTER_README_nav_bar_widget.md` |
```

---

## Section 9 — Analytics Events

**What it defines:** Every analytics event this page fires. Event name must be one of the
30 valid event types from `BUILDSHIP_API_REFERENCE.md` Section 9. Must include trigger
condition and the `eventData` payload shape.

**Minimum bar:** One row per event. Must use exact event type strings from the valid list.
Every page fires at least `page_viewed` on dispose.

**Fails if:** "Tracks page views" — no event name, no eventData.

**Example:**
```markdown
| Event | Trigger | eventData payload |
|-------|---------|------------------|
| `page_viewed` | Page dispose | `{ "pageName": "homepage", "duration": getSessionDurationSeconds() }` |
| `business_clicked` | Restaurant card tap | `{ "businessId": id, "businessName": name, "position": index }` |
| `filter_applied` | Filter chip toggled | `{ "filterId": id, "filterName": name, "activeFilters": [...] }` |
```

---

## Section 10 — Edge Cases

**What it defines:** How the page behaves in non-happy-path scenarios. Loading states,
empty states, error states, offline behaviour, and accessibility concerns.

**Minimum bar:** At least 4 edge cases. Must cover: loading, empty/zero-results, API
error, and at least one accessibility concern (font scale / bold text).

**Fails if:** Only documents the happy path. Omits loading state.

**Example:**
```markdown
| Scenario | Behaviour |
|----------|-----------|
| Search API call in flight | `RestaurantListShimmerWidget` shown instead of results |
| Search returns 0 results | Empty state illustration + "No results" text |
| Search API returns error | Error banner with retry button; previous results cleared |
| No location permission | Distance sorting disabled; location banner shown |
| `fontScale = true` | Filter panel height increased to 385px (from 350px) |
| `isBoldTextEnabled = true` | All text rendered one weight heavier |
```

---

## Compliance checklist

Use this checklist when auditing or writing a BUNDLE.md:

- [ ] Metadata block present (5 fields: source path, route name, route path, status badge, date)
- [ ] Section 1 — Page Purpose (1–3 sentences, user-facing)
- [ ] Section 2 — Routes (entry + exit, with triggers + params)
- [ ] Section 3 — Riverpod State (reads + writes tables, matched to MASTER_STATE_MAP.md)
- [ ] Section 4 — Local State (explicit list or "None")
- [ ] Section 5 — API Calls (endpoint name, trigger, inputs, outputs — matched to BUILDSHIP_API_REFERENCE.md)
- [ ] Section 6 — Translation Keys (table with keys + English + Danish, system identified)
- [ ] Section 7 — Actions & Interactions (all user gestures → state + nav + analytics + API)
- [ ] Section 8 — Widgets (custom widgets with params + README path)
- [ ] Section 9 — Analytics Events (exact event type strings, trigger, eventData)
- [ ] Section 10 — Edge Cases (loading, empty, error, offline, accessibility — minimum 4)

---

## Cross-reference rules

| If the BUNDLE.md mentions... | Verify against... |
|------------------------------|-------------------|
| A Riverpod provider name | `_reference/MASTER_STATE_MAP.md` — exact provider name |
| An API endpoint | `_reference/BUILDSHIP_API_REFERENCE.md` — exact endpoint + shape |
| An analytics event type | `_reference/BUILDSHIP_API_REFERENCE.md` Section 9 — valid event list |
| A translation key | `MASTER_TRANSLATION_KEYS.md` — key → English value |
| A custom widget | `shared/widgets/MASTER_README_[widget].md` — exists and is referenced |
| A custom action | `shared/actions/MASTER_README_[action].md` — exists and is referenced |

---

## Scoring guide (used in BUNDLE_AUDIT_REPORT.md)

| Score | Meaning |
|-------|---------|
| ⭐⭐⭐⭐⭐ | All 10 sections present and meet minimum bar. Riverpod section accurate. |
| ⭐⭐⭐⭐ | 8–9 sections present. Minor gaps (e.g. missing edge cases, thin analytics). |
| ⭐⭐⭐ | 6–7 sections present OR a critical section (Routes, Riverpod State, API) is missing/wrong. |
| ⭐⭐ | 4–5 sections present. Major gaps that would block implementation. |
| ⭐ | Fewer than 4 sections or multiple critical sections missing. |
