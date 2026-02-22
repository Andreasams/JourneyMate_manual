# Phase 8 Implementation Plan: 100% Dynamic Translation Migration

**Created:** 2026-02-22
**Purpose:** Complete migration from hardcoded translations to 100% dynamic Supabase-backed system
**Working Directory:** `C:\Users\Rikke\Documents\JourneyMate-Organized`

---

## Overview

Phase 8 completes the translation architecture by migrating all hardcoded translations to Supabase, creating a single source of truth for all UI text across all 7 languages.

### Current State
- ✅ 191 FlutterFlow keys in `kStaticTranslations` (Phase 6A)
- ✅ 163 new keys added during Phase 7 implementation
- ✅ **Total: 354 keys** in `kStaticTranslations` map
- ✅ All keys have SQL INSERT statements in `NEW_TRANSLATION_KEYS.sql` (1,050 entries)
- ⚠️ App uses dual translation system: `ts(context, key)` for static + `td(ref, key)` for dynamic

### End State Goal
- ✅ 100% of translations in Supabase `ui_translations` table
- ✅ 0% hardcoded text in app
- ✅ Single translation API: `td(ref, key)` for everything
- ✅ `kStaticTranslations` deleted
- ✅ All languages load from BuildShip API (`https://wvb8ww.buildship.run/languageText`)

---

## Phase 8 Tasks

### Task 1: SQL Migration (USER ACTION REQUIRED)

**Responsibility:** User must run SQL against Supabase
**File:** `_reference/NEW_TRANSLATION_KEYS.sql`
**Rows to insert:** 1,050 translations (150 unique keys × 7 languages)

**Steps:**
1. Open Supabase dashboard → SQL Editor
2. Copy contents of `_reference/NEW_TRANSLATION_KEYS.sql`
3. Execute SQL (inserts all Phase 6B keys into `ui_translations` table)
4. Verify insertion:
   ```sql
   SELECT COUNT(*) FROM ui_translations;
   -- Expected: ~2,500 rows (original keys + FlutterFlow 191 + Phase 6B 150)

   SELECT COUNT(DISTINCT translation_key) FROM ui_translations;
   -- Expected: ~350-360 unique keys
   ```

**⚠️ Critical:** Do NOT proceed with Task 2 until SQL migration is complete and verified.

---

### Task 2: Code Migration - Replace All `ts()` Calls (CLAUDE ACTION)

**Objective:** Replace all `ts(context, key)` calls with `td(ref, key)` across all 12 pages

**Files to modify:**
1. `journey_mate/lib/pages/welcome/welcome_page.dart`
2. `journey_mate/lib/pages/app_settings_initiate_flow/app_settings_initiate_flow_page.dart`
3. `journey_mate/lib/pages/search_page.dart`
4. `journey_mate/lib/pages/business_profile_page.dart`
5. `journey_mate/lib/pages/menu_full_page.dart`
6. `journey_mate/lib/pages/gallery_full_page.dart`
7. `journey_mate/lib/pages/business_information_page.dart`
8. `journey_mate/lib/pages/settings/settings_main_page.dart`
9. `journey_mate/lib/pages/settings/localization_page.dart`
10. `journey_mate/lib/pages/settings/location_sharing_page.dart`
11. `journey_mate/lib/pages/settings/contact_us_page.dart`
12. `journey_mate/lib/pages/settings/share_feedback_page.dart`
13. `journey_mate/lib/pages/settings/missing_place_page.dart`

**Pattern:**
```dart
// Before (static)
Text(ts(context, 'xn0d16r3'))

// After (dynamic)
Text(td(ref, 'xn0d16r3'))
```

**Critical Change:** Pages using `ts()` must change from `ConsumerWidget` to `ConsumerStatefulWidget` if they aren't already, OR add `ref` parameter if they're builder functions.

**Widget Class Changes:**
- `StatelessWidget` → NO CHANGE (widgets use `td(ref, key)` already)
- `StatefulWidget` → `ConsumerStatefulWidget` (to access `ref`)
- `ConsumerWidget` → NO CHANGE (already has `ref`)
- `ConsumerStatefulWidget` → NO CHANGE (already has `ref`)

---

### Task 3: Code Migration - Delete Hardcoded Map (CLAUDE ACTION)

**File:** `journey_mate/lib/services/translation_service.dart`

**Actions:**
1. Delete entire `kStaticTranslations` map (~1,900 lines)
2. Update file header to remove TEMPORARY warnings
3. Optionally: Make `ts()` an alias to `td()` for backwards compatibility
   ```dart
   // Option A: Delete ts() entirely (RECOMMENDED)
   // Remove ts() function completely

   // Option B: Alias ts() to td() (backwards compatible)
   String ts(BuildContext context, String key) {
     // Get ref from context (requires provider scope)
     return td(ProviderScope.containerOf(context), key);
   }
   ```

**Recommendation:** Delete `ts()` entirely (Option A) for cleaner codebase.

---

### Task 4: Verification (CLAUDE + USER ACTION)

**Automated Checks:**
1. Run `flutter analyze` → must return 0 issues
2. Search for remaining `ts(` calls:
   ```bash
   cd journey_mate && grep -r "ts(" lib/
   # Expected: 0 matches in .dart files (or only in comments)
   ```
3. Verify `kStaticTranslations` deleted:
   ```bash
   cd journey_mate && grep -c "kStaticTranslations" lib/services/translation_service.dart
   # Expected: 0
   ```

**Manual Testing (USER):**
1. Run app: `flutter run`
2. Change language to Danish in settings
3. Navigate through all 12 pages, verify:
   - All text appears (no blank labels)
   - All text is in Danish (no English fallbacks)
4. Change language to English, repeat verification
5. Test edge cases:
   - Empty states (search with no results)
   - Error messages (submit form with validation errors)
   - Dynamic content (menu items, business details)

**Rollback Plan (if issues found):**
```bash
git revert HEAD  # Undo Phase 8 code changes
# Re-add kStaticTranslations from git history if needed
```

---

## Success Criteria

Phase 8 is complete when ALL of the following are true:

- [ ] ✅ SQL migration complete (1,050 rows inserted into `ui_translations`)
- [ ] ✅ All `ts(context, key)` calls replaced with `td(ref, key)` (0 remaining)
- [ ] ✅ `kStaticTranslations` map deleted from `translation_service.dart`
- [ ] ✅ `ts()` function removed (or aliased to `td()`)
- [ ] ✅ `flutter analyze` returns 0 issues
- [ ] ✅ Manual testing passes in English and Danish
- [ ] ✅ All 12 pages display correctly with dynamic translations
- [ ] ✅ Commit: `feat(phase8): migrate to 100% dynamic translations ✅`
- [ ] ✅ Documentation updated: SESSION_STATUS.md, CLAUDE.md

---

## Timeline Estimate

**Task 1 (SQL):** 10-15 minutes (user action)
**Task 2 (Replace ts()):** 2-3 hours (automated find/replace + verification)
**Task 3 (Delete map):** 30 minutes (delete + cleanup)
**Task 4 (Verification):** 1-2 hours (automated + manual testing)

**Total:** 4-6 hours (excluding user SQL migration time)

---

## Risk Assessment

**Low Risk:**
- ✅ SQL migration is additive (doesn't modify existing data)
- ✅ Code changes are mechanical (find/replace pattern)
- ✅ git rollback available if issues found

**Medium Risk:**
- ⚠️ Missing translation keys (if SQL migration incomplete)
- ⚠️ Runtime errors if `td(ref, key)` called with invalid key

**Mitigation:**
- Verify SQL migration count before code changes
- Test in both languages before committing
- Keep git history clean for easy rollback

---

## Next Steps

**User:** Confirm SQL migration is ready, then run Task 1
**Claude:** Proceed with Tasks 2-4 after user confirms SQL complete

**Decision Point:** Should Claude proceed with Task 2 now, or wait for user to confirm SQL migration first?

**Recommendation:** Wait for user confirmation to avoid code/data desync.
