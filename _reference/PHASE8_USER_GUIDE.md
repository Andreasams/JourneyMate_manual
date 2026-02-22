# Phase 8: Complete Migration to 100% Dynamic Translations

**Status:** READY TO EXECUTE (deferred - waiting for user decision)
**Created:** 2026-02-22
**Estimated Time:** 4-6 hours total

---

## Goal

Eliminate all hardcoded translations and use Supabase as the single source of truth for all UI text.

---

## Current State

- ✅ 354 translation keys in hardcoded `kStaticTranslations` map
- ✅ 1,050 SQL statements ready in `_reference/NEW_TRANSLATION_KEYS.sql`
- ⚠️ App uses **dual system**: `ts()` for static + `td()` for dynamic

## Target State

- ✅ 0 hardcoded translations
- ✅ 100% dynamic from Supabase via BuildShip API
- ✅ Single API: `td(ref, key)` for everything

---

## 4-Step Implementation

### **STEP 1: SQL Migration** (YOUR ACTION - 10-15 minutes)

**What:** Load all Phase 7 translation keys into Supabase

**How:**
1. Open Supabase dashboard → SQL Editor
2. Copy entire contents of `_reference/NEW_TRANSLATION_KEYS.sql`
3. Paste and execute
4. Verify success:
   ```sql
   SELECT COUNT(*) FROM ui_translations;
   -- Should see ~2,500 total rows

   SELECT COUNT(DISTINCT translation_key) FROM ui_translations;
   -- Should see ~350-360 unique keys
   ```

**Important:** The SQL file contains 1,050 INSERT statements (150 unique keys × 7 languages). This is safe to run—it only adds new rows, doesn't modify existing data.

---

### **STEP 2: Code Migration** (CLAUDE ACTION - 2-3 hours)

**What:** Replace all `ts(context, key)` calls with `td(ref, key)` across all pages

**Files to modify:** All 13 pages
- Welcome page
- App Settings Initiate Flow
- Search page
- Business Profile
- Menu Full Page
- Gallery Full Page
- Business Information
- Settings Main
- Localization
- Location Sharing
- Contact Us
- Share Feedback
- Missing Place

**Pattern:**
```dart
// BEFORE
Text(ts(context, 'xn0d16r3'))  // Static from hardcoded map

// AFTER
Text(td(ref, 'xn0d16r3'))      // Dynamic from Supabase
```

**⚠️ CRITICAL:** Cannot proceed with this step until Step 1 SQL migration is complete and verified. Changing `ts()` to `td()` before SQL is loaded will break the app (keys won't be found).

---

### **STEP 3: Cleanup** (CLAUDE ACTION - 30 minutes)

**What:** Delete the hardcoded translation map

**Actions:**
1. Delete `kStaticTranslations` map from `translation_service.dart` (~1,900 lines)
2. Remove `ts()` function completely
3. Update file header documentation

**Result:** `translation_service.dart` shrinks from ~2,100 lines → ~200 lines

---

### **STEP 4: Verification** (BOTH - 1-2 hours)

**Automated checks (Claude does):**
- ✅ `flutter analyze` returns 0 issues
- ✅ Search codebase for remaining `ts(` calls (should be 0)
- ✅ Verify `kStaticTranslations` deleted

**Manual testing (you do):**
1. Run app: `flutter run`
2. Test in **English**:
   - Navigate all 12 pages
   - Verify all text displays correctly
   - Check empty states, errors, dynamic content
3. Switch to **Danish** in settings
4. Navigate all 12 pages again
5. Verify all text is in Danish (no English fallbacks)

---

## Success Criteria ✅

Phase 8 is complete when:
- [ ] SQL migration confirmed (1,050 rows in Supabase)
- [ ] All `ts()` calls replaced with `td()` (0 remaining)
- [ ] `kStaticTranslations` deleted
- [ ] `flutter analyze`: 0 issues
- [ ] Manual testing passes in English & Danish
- [ ] All 12 pages work correctly
- [ ] Committed: `feat(phase8): migrate to 100% dynamic translations ✅`

---

## When You're Ready to Execute

**Tell Claude:**
> "I've run the SQL migration (Step 1). Please proceed with Phase 8 Steps 2-4."

**Claude will:**
1. Replace all `ts()` → `td()` across all pages (2-3 hours)
2. Delete `kStaticTranslations` map (30 min)
3. Run automated verification (30 min)
4. Commit changes

**You will:**
1. Run manual testing in English & Danish (1 hour)
2. Confirm everything works
3. Approve final commit

---

## Why This Matters

**Benefits:**
- ✅ Single source of truth (no sync issues between hardcoded + Supabase)
- ✅ Easier to maintain (update translations in Supabase UI, not code)
- ✅ Easier to add new languages (just add to Supabase, no code changes)
- ✅ Cleaner codebase (1,900 fewer lines)
- ✅ Production-ready architecture

**Risks:**
- ⚠️ Requires Supabase to be available (app won't work offline without translations)
- ⚠️ Slight performance hit on first load (caches after initial fetch)

**Mitigation:**
- BuildShip API is reliable (Supabase-backed)
- Translations are cached in `translationsCacheProvider` after first load
- App already depends on Supabase for all other data

---

## Alternative: Defer Phase 8

Phase 8 is **not urgent**. The app works perfectly with the dual translation system.

**You could defer Phase 8 until:**
- After initial user testing
- After deploying to TestFlight
- After gathering feedback
- After confirming app stability

**Current state is production-ready.** Phase 8 is an architectural improvement, not a bug fix.

---

## Rollback Plan

If Phase 8 causes issues:

```bash
cd /c/Users/Rikke/Documents/JourneyMate-Organized
git log --oneline -5
git revert <commit-hash>  # Undo Phase 8 changes
git push origin main
```

The hardcoded `kStaticTranslations` map will be restored from git history.

---

**Status:** Waiting for user decision to proceed or defer.
