# BUNDLE_AUDIT_REPORT.md
## Phase 2 output — requires user review before Phase 3

**Standard used:** `_reference/BUNDLE_STANDARD.md`
**State map used:** `_reference/MASTER_STATE_MAP.md`
**API reference used:** `_reference/BUILDSHIP_API_REFERENCE.md`
**Audit date:** 2026-02-20
**Audited by:** Phase 2 session

---

## Summary

| Metric | Count |
|--------|-------|
| Files audited | 14/14 |
| Files with Riverpod section (after patch) | 14/14 ✅ |
| Files with custom widget internals patched | 3/3 ✅ |
| pubspec package name errors fixed | 1 (`provider:` → `flutter_riverpod:`) |
| Files at ⭐⭐⭐⭐⭐ | 9 |
| Files at ⭐⭐⭐⭐ | 2 |
| Files at ⭐⭐⭐ | 3 |
| Files at ⭐⭐ or below | 0 |

### Actions taken this phase
- Added `## Riverpod State` section to all 14 files (reads + writes tables, matched to MASTER_STATE_MAP.md)
- Added `## Custom Widget Internals` section to `missing_place`, `contact_us`, `share_feedback`
- Fixed `provider: ^6.1.5` → `flutter_riverpod: ^2.x` in `02_business_profile/BUNDLE.md`
- Added local state tables to menu, gallery, contact-details, welcome, and app-settings files

### Known issues requiring user decision
1. **`05_contact_details/` directory name mismatch** — directory is named `05_contact_details` but contains `BusinessInformationWidget`. Consider renaming to `05_business_information` before Phase 3 to avoid confusion.
2. **ContactUsFormWidget Subject field** — FlutterFlow uses free-text input; JSX design anticipates a dropdown. Implementer must choose: match FlutterFlow (free text) or implement dropdown (requires new BuildShip work). See per-file entry below.
3. **FeedbackFormWidget topic sent as localized string** — The `/feedbackform` API receives the topic as the displayed label (e.g. "Wrong info") not a stable key. If the BuildShip endpoint does string-matching on topic, language changes could cause misrouting. Verify with BuildShip team.
4. **Analytics pageName inconsistency** — `BUNDLE_welcome_page.md` documents `pageName: 'homepage'` but the analytics event type is `page_viewed`. Verify this is the intended `pageName` value vs. `'welcomePage'`.
5. **Settings Hub (07_settings/BUNDLE.md)** — ⭐⭐⭐ quality. Needs richer analytics section and edge cases before Phase 3. Acceptable as a nav hub but flagged.

---

## Per-File Audit

---

### 1 — `pages/01_search/BUNDLE.md` — ⭐⭐⭐⭐⭐ PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Clear user-facing description |
| 2. Routes | ✅ | Entry + exit points with triggers |
| 3. Riverpod State | ✅ | **Added this phase** — 19 provider fields mapped |
| 4. Local State | ✅ | `_filterOverlayOpen`, `_cityPickerOpen`, `_pageStartTime` |
| 5. API Calls | ✅ | SEARCH endpoint fully documented |
| 6. Translation Keys | ✅ | All page-level keys listed |
| 7. Actions & Interactions | ✅ | All user gestures mapped |
| 8. Widgets | ✅ | SearchResultsListView, FilterOverlayWidget, NavBarWidget |
| 9. Analytics Events | ✅ | page_viewed, business_clicked, filter_applied, filter_reset |
| 10. Edge Cases | ✅ | Loading, empty, error, location off, fontScale |

**Actions taken:** Added Riverpod State section.
**Known issues:** None.

---

### 2 — `pages/02_business_profile/BUNDLE.md` — ⭐⭐⭐⭐⭐ PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Comprehensive |
| 2. Routes | ✅ | Entry from search, back navigation |
| 3. Riverpod State | ✅ | **Added this phase** — 13 provider fields mapped |
| 4. Local State | ✅ | Dietary filter IDs, visibleItemCount, pageStartTime |
| 5. API Calls | ✅ | BusinessProfileCall, MenuItemsCall, FilterDescriptionsCall |
| 6. Translation Keys | ✅ | All page-level keys listed |
| 7. Actions & Interactions | ✅ | Tab navigation, menu session, gallery |
| 8. Widgets | ✅ | 8 custom widgets with params and source paths |
| 9. Analytics Events | ✅ | 8 events documented |
| 10. Edge Cases | ✅ | Loading shimmer, error state, empty menu |

**Actions taken:**
- Added Riverpod State section
- Fixed `provider: ^6.1.5` → `flutter_riverpod: ^2.x` (pubspec block + checklist item)

**Known issues:** None remaining.

---

### 3 — `pages/03_menu_full_page/BUNDLE.md` — ⭐⭐⭐⭐⭐ PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Clear |
| 2. Routes | ✅ | From Business Profile, back to Business Profile |
| 3. Riverpod State | ✅ | **Added this phase** — 10 provider fields + 6 local state vars |
| 4. Local State | ✅ | Category ID, menu ID, dietary filters, pageStartTime |
| 5. API Calls | ✅ | No direct API calls; data pre-loaded. Noted. |
| 6. Translation Keys | ✅ | 4 page-level keys documented |
| 7. Actions & Interactions | ✅ | Filter toggle, category scroll, item tap |
| 8. Widgets | ✅ | MenuDishesListView, MenuCategoriesRows, UnifiedFiltersWidget |
| 9. Analytics Events | ✅ | page_viewed, menu_item_viewed, filter events |
| 10. Edge Cases | ✅ | Empty menu, filter panel height (fontScale), bold text |

**Actions taken:** Added Riverpod State section with local state table.
**Known issues:** None.

---

### 4 — `pages/04_gallery_full_page/BUNDLE.md` — ⭐⭐⭐⭐⭐ PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Clear |
| 2. Routes | ✅ | From Business Profile, back navigation |
| 3. Riverpod State | ✅ | **Added this phase** — single provider read (translationsCache) |
| 4. Local State | ✅ | pageStartTime only — appropriately minimal |
| 5. API Calls | ✅ | No API calls; images pre-loaded. Noted. |
| 6. Translation Keys | ✅ | 5 keys (gallery category labels) |
| 7. Actions & Interactions | ✅ | Tab switch, image tap, swipe |
| 8. Widgets | ✅ | GalleryTabWidget, ImageGalleryWidget with params |
| 9. Analytics Events | ✅ | gallery_tab_opened/changed, image_gallery_opened/navigation/closed |
| 10. Edge Cases | ✅ | Empty category, single image mode, precaching |

**Actions taken:** Added Riverpod State section.
**Known issues:** None.

---

### 5 — `pages/05_contact_details/BUNDLE_information_page.md` — ⭐⭐⭐⭐ NEAR-PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Clear |
| 2. Routes | ✅ | From Business Profile "Se alle informationer →" |
| 3. Riverpod State | ✅ | **Added this phase** — businessProvider + translationsCache + filterProvider |
| 4. Local State | ✅ | **Added this phase** — 8 local vars including expandable controller |
| 5. API Calls | ✅ | No direct calls (getFiltersWithUpdate uses cached data) |
| 6. Translation Keys | ✅ | 3 page-level keys |
| 7. Actions & Interactions | ⚠️ | Present but thin — expand/collapse + map interaction not fully detailed |
| 8. Widgets | ✅ | ContactDetailWidget, BusinessFeatureButtons, PaymentOptionsWidget |
| 9. Analytics Events | ⚠️ | Only `page_viewed` documented; `business_contact_toggled` missing |
| 10. Edge Cases | ⚠️ | No edge cases section |

**Actions taken:** Added Riverpod State section and local state table.
**Known issues:**
- Directory named `05_contact_details` but widget is `BusinessInformationWidget` → **user decision required** on rename
- Analytics section thin: `business_contact_toggled` event (from ContactDetailWidget) not documented
- Edge cases section missing (acceptable for Phase 3 since this is a display-only page)

---

### 6 — `pages/06_welcome_onboarding/BUNDLE_welcome_page.md` — ⭐⭐⭐⭐ NEAR-PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | New vs. returning user flow explained |
| 2. Routes | ✅ | App launch entry + 3 exit paths documented |
| 3. Riverpod State | ✅ | **Added this phase** — 5 reads, 5 writes |
| 4. Local State | ✅ | `_returningUser`, `_pageStartTime` |
| 5. API Calls | ✅ | SearchAPICall on Danish path documented |
| 6. Translation Keys | ✅ | 5 keys |
| 7. Actions & Interactions | ✅ | Both button paths + returning user path |
| 8. Widgets | ✅ | No custom widgets; correct |
| 9. Analytics Events | ⚠️ | `pageName: 'homepage'` — inconsistent with route name `WelcomePage`; flagged |
| 10. Edge Cases | ⚠️ | API optimistic error handling documented as known issue |

**Actions taken:** Added Riverpod State section.
**Known issues:**
- `pageName: 'homepage'` vs expected `'welcomePage'` — verify intended analytics page name
- SearchAPI error handling is optimistic (assumes success) — known issue, low priority

---

### 7 — `pages/06_welcome_onboarding/BUNDLE_app_settings_initiate_flow.md` — ⭐⭐⭐⭐ NEAR-PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Language + currency setup for new English users |
| 2. Routes | ✅ | From WelcomePage → SearchResults after setup |
| 3. Riverpod State | ✅ | **Added this phase** — 5 reads, 6 writes |
| 4. Local State | ✅ | `_pageStartTime` only |
| 5. API Calls | ✅ | SearchAPICall on "Complete setup" |
| 6. Translation Keys | ✅ | 7 page-level keys |
| 7. Actions & Interactions | ✅ | Language select, currency select, complete setup |
| 8. Widgets | ✅ | LanguageSelectorButton, CurrencySelectorButton |
| 9. Analytics Events | ✅ | `page_viewed` with `pageName: 'appSettingsInitiateFlow'` |
| 10. Edge Cases | ⚠️ | API optimistic error handling documented as known issue |

**Actions taken:** Added Riverpod State section.
**Known issues:** Same SearchAPI optimistic handling as welcome page.

---

### 8 — `pages/07_settings/BUNDLE.md` — ⭐⭐⭐ ACCEPTABLE (nav hub)

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Navigation hub described |
| 2. Routes | ✅ | 6 exit points listed |
| 3. Riverpod State | ✅ | **Added this phase** — correctly documents "None" |
| 4. Local State | ✅ | `_pageStartTime` only |
| 5. API Calls | ✅ | None; correct for nav hub |
| 6. Translation Keys | ⚠️ | Thin — section headings listed but not all row labels |
| 7. Actions & Interactions | ⚠️ | Row taps listed but not analytics event per tap |
| 8. Widgets | ✅ | NavBarWidget |
| 9. Analytics Events | ⚠️ | Only `page_viewed` documented; no per-row interaction events |
| 10. Edge Cases | ❌ | Section absent |

**Actions taken:** Added Riverpod State section.
**Known issues:** Analytics and edge cases thin — acceptable for a nav hub; not blocking Phase 3.

---

### 9 — `pages/07_settings/settings_main/BUNDLE_settings_main.md` — ⭐⭐⭐⭐⭐ PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Comprehensive hub overview |
| 2. Routes | ✅ | All 6 rows + external URLs documented |
| 3. Riverpod State | ✅ | **Added this phase** — correctly documents "None" |
| 4. Local State | ✅ | `_pageStartTime` only |
| 5. API Calls | ✅ | None; correct |
| 6. Translation Keys | ✅ | All 10 keys + English text |
| 7. Actions & Interactions | ✅ | Each row tap + back button |
| 8. Widgets | ✅ | NavBarWidget |
| 9. Analytics Events | ✅ | `page_viewed` with `pageName: 'settingsAndAccount'` |
| 10. Edge Cases | ✅ | External URL error, NavBar state |

**Actions taken:** Added Riverpod State section.
**Known issues:** Typography inconsistencies documented (design debt — not blocking).

---

### 10 — `pages/07_settings/localization/BUNDLE_language_currency.md` — ⭐⭐⭐⭐⭐ PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Language and currency change flow |
| 2. Routes | ✅ | From Localization hub, back navigation |
| 3. Riverpod State | ✅ | **Added this phase** — 4 reads, 4 writes |
| 4. Local State | ✅ | `_pageStartTime` only |
| 5. API Calls | ✅ | GET_EXCHANGE_RATE (via updateCurrencyWithExchangeRate) |
| 6. Translation Keys | ✅ | 6 page-level keys; widget keys noted as unknown → **now resolvable via widget source** |
| 7. Actions & Interactions | ✅ | Language select, currency select, back button |
| 8. Widgets | ✅ | LanguageSelectorButton, CurrencySelectorButton |
| 9. Analytics Events | ✅ | `page_viewed`, `language_changed`, `currency_changed` |
| 10. Edge Cases | ✅ | Exchange rate fetch failure, offline |

**Actions taken:** Added Riverpod State section.
**Known issues:** Custom widget keys previously "noted as unknown" — LanguageSelectorButton and CurrencySelectorButton translation keys are not documented in this BUNDLE. Phase 3 implementers should read those widget MASTER_READMEs.

---

### 11 — `pages/07_settings/location_sharing/BUNDLE_location_sharing.md` — ⭐⭐⭐⭐⭐ PASS

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Two-state UI explained |
| 2. Routes | ✅ | From Localization hub |
| 3. Riverpod State | ✅ | **Added this phase** — `locationProvider.hasPermission` read + write; important note about AppLifecycleState.resumed |
| 4. Local State | ✅ | `_pageStartTime` only |
| 5. API Calls | ✅ | None (permission check is OS-level) |
| 6. Translation Keys | ✅ | 9 keys across both UI states |
| 7. Actions & Interactions | ✅ | Both button actions per state |
| 8. Widgets | ✅ | No custom widgets; correct |
| 9. Analytics Events | ✅ | `page_viewed`; suggested enhancements noted |
| 10. Edge Cases | ✅ | Both permission states; returning from OS settings |

**Actions taken:** Added Riverpod State section with important AppLifecycleState note.
**Known issues:** None.

---

### 12 — `pages/07_settings/missing_place/BUNDLE_missing_place.md` — ⭐⭐⭐⭐⭐ PASS (upgraded from ⭐⭐⭐)

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Report missing restaurant |
| 2. Routes | ✅ | From Settings hub |
| 3. Riverpod State | ✅ | **Added this phase** — `translationsCacheProvider` read only |
| 4. Local State | ✅ | `_pageStartTime` only |
| 5. API Calls | ✅ | **Added this phase** — `POST /missingplace` with exact request body shape |
| 6. Translation Keys | ✅ | **Added this phase** — 19 widget-internal keys documented |
| 7. Actions & Interactions | ✅ | Form submit, field validation, success/retry |
| 8. Widgets | ✅ | **Added this phase** — MissingLocationFormWidget with full constructor + field docs |
| 9. Analytics Events | ✅ | `markUserEngaged()` on submit; page-level `page_viewed` |
| 10. Edge Cases | ✅ | **Added this phase** — validation errors, network failure, loading state |

**Actions taken:**
- Added Riverpod State section
- Added full Custom Widget Internals section from FF source (form fields, API, translations, analytics, styling)

**Known issues:** None remaining.

---

### 13 — `pages/07_settings/contact_us/BUNDLE_contact_us.md` — ⭐⭐⭐⭐⭐ PASS (upgraded from ⭐⭐⭐)

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Support contact form |
| 2. Routes | ✅ | From Settings hub |
| 3. Riverpod State | ✅ | **Added this phase** — `translationsCacheProvider` read only |
| 4. Local State | ✅ | `_pageStartTime` only |
| 5. API Calls | ✅ | **Added this phase** — `POST /contact` with exact request body shape |
| 6. Translation Keys | ✅ | **Added this phase** — 22 widget-internal keys documented |
| 7. Actions & Interactions | ✅ | Form submit, field validation, success/retry |
| 8. Widgets | ✅ | **Added this phase** — ContactUsFormWidget with full constructor + field docs |
| 9. Analytics Events | ✅ | `markUserEngaged()` on submit; page-level `page_viewed` |
| 10. Edge Cases | ✅ | **Added this phase** — validation errors, network failure, loading state |

**Actions taken:**
- Added Riverpod State section
- Added full Custom Widget Internals section from FF source (4 fields, API, translations, analytics, styling)

**Known issues:**
- Subject field is free-text in FlutterFlow; JSX design anticipates dropdown → **user decision required** on implementation approach

---

### 14 — `pages/07_settings/share_feedback/BUNDLE_share_feedback.md` — ⭐⭐⭐⭐⭐ PASS (upgraded from ⭐⭐⭐)

| Section | Status | Notes |
|---------|--------|-------|
| Metadata block | ✅ | All 5 fields present |
| 1. Page Purpose | ✅ | Feedback collection with topic selection |
| 2. Routes | ✅ | From Settings hub |
| 3. Riverpod State | ✅ | **Added this phase** — `translationsCacheProvider` read only |
| 4. Local State | ✅ | `_pageStartTime` only |
| 5. API Calls | ✅ | **Added this phase** — `POST /feedbackform` with exact request body |
| 6. Translation Keys | ✅ | **Added this phase** — 27 widget-internal keys documented (7 topic labels + form labels) |
| 7. Actions & Interactions | ✅ | Topic selection, checkbox, form submit |
| 8. Widgets | ✅ | **Added this phase** — FeedbackFormWidget with full constructor + field docs |
| 9. Analytics Events | ✅ | `markUserEngaged()` on 3 triggers; `pageName` prop explained |
| 10. Edge Cases | ✅ | **Added this phase** — topic validation, conditional required fields |

**Actions taken:**
- Added Riverpod State section
- Added full Custom Widget Internals section from FF source
- Documented `pageName` prop: received but NOT currently sent to API
- Fixed: `markUserEngaged()` was missing from back button action (fixed 2026-02-19 per BUNDLE)

**Known issues:**
- Topic is sent as localized label string (not key) → verify BuildShip `/feedbackform` does not string-match on English topic names
- `pageName` prop unused in API body → confirm this is intentional

---

## Cross-Reference Findings

### Provider name mismatches vs MASTER_STATE_MAP.md
No mismatches found. All provider names in newly added Riverpod State sections use exact names
from `MASTER_STATE_MAP.md` (e.g. `searchStateProvider`, `businessProvider`, `translationsCacheProvider`, etc.).

**Note on notifier method names:** The exact notifier method names (`updateResults`, `setFilters`,
`setCurrency`, etc.) are placeholder names — the actual Riverpod `StateNotifier` methods will be
defined in Phase 5 when providers are implemented. Phase 3 implementers should update these
names once Phase 5 is complete.

### API endpoint mismatches vs BUILDSHIP_API_REFERENCE.md
| BUNDLE reference | API Reference | Status |
|-----------------|---------------|--------|
| `POST /missingplace` | Not in BUILDSHIP_API_REFERENCE.md | ⚠️ Undocumented endpoint — sourced directly from FF widget source |
| `POST /contact` | Not in BUILDSHIP_API_REFERENCE.md | ⚠️ Undocumented endpoint — sourced directly from FF widget source |
| `POST /feedbackform` | Not in BUILDSHIP_API_REFERENCE.md | ⚠️ Undocumented endpoint — sourced directly from FF widget source |
| `SEARCH` | #1 in API Reference ✅ | |
| `GET_BUSINESS_PROFILE` | #2 in API Reference ✅ | |
| `GET_RESTAURANT_MENU` | #3 in API Reference ✅ | |
| `GET_FILTERS` | #4 in API Reference ✅ | |
| `GET_EXCHANGE_RATE` | #5 in API Reference ✅ | |
| `GET_FILTER_DESCRIPTIONS` | #6 in API Reference ✅ | |
| `GET_UI_TRANSLATIONS` | #8 in API Reference ✅ | |
| `POST_ANALYTICS` | #9 in API Reference ✅ | |

**Action required:** The 3 form submission endpoints (`/missingplace`, `/contact`, `/feedbackform`)
are NOT documented in `BUILDSHIP_API_REFERENCE.md`. They were discovered from FF widget source code.
Add them as endpoints #10, #11, #12 in BUILDSHIP_API_REFERENCE.md before Phase 3 begins.

### Analytics event types vs BUILDSHIP_API_REFERENCE.md valid list
All documented event types across the 14 files match the 36 valid event types in
BUILDSHIP_API_REFERENCE.md Section 9. No invalid event type names found.

### Known issues requiring user decision

| # | Issue | File(s) | Options |
|---|-------|---------|---------|
| 1 | Directory name mismatch | `05_contact_details/` | Rename to `05_business_information/` or leave as-is |
| 2 | ContactUs Subject field | `07_settings/contact_us/BUNDLE_contact_us.md` | Free-text (match FF) or dropdown (match JSX) |
| 3 | FeedbackForm topic as localized string | `07_settings/share_feedback/BUNDLE_share_feedback.md` | Verify BuildShip accepts localized strings or switch to key |
| 4 | Welcome page `pageName: 'homepage'` | `06_welcome_onboarding/BUNDLE_welcome_page.md` | Confirm intended analytics page name |
| 5 | 3 form endpoints undocumented in API ref | BUILDSHIP_API_REFERENCE.md | Add `/missingplace`, `/contact`, `/feedbackform` to API reference |

---

## Phase 3 Gate

**All 14 BUNDLE.md files now have:**
- ✅ Riverpod State section (reads + writes, matched to MASTER_STATE_MAP.md)
- ✅ Custom widget internals for 3 form pages (sourced from FF)
- ✅ Correct package name (flutter_riverpod not provider)

**Before Phase 3 can start:**
- [ ] User reviews this report and resolves the 5 known issues above
- [ ] Phase 3 gap analysis (`_reference/BUILDSHIP_REQUIREMENTS.md`) must be written
- [ ] Phase 3.5 master task list must be approved

**Phase 2 is complete.** Awaiting user review.
