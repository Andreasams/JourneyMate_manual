# Translation Migration Analysis & Strategy
**Created:** 2026-02-22
**Purpose:** Compare MASTER_TRANSLATION_KEYS.md vs NEW_TRANSLATION_KEYS.sql and determine migration path

---

## Executive Summary

**The app currently uses 355 translation keys total:**
- **~217 FlutterFlow keys** (8-char IDs like `6dww9uct`, `05aeogb1`) - from Phase 6A
- **~138 Phase 7 keys** (descriptive names like `contact_details_phone`, `missing_location_title_main`) - from Phase 7 page implementation

**MASTER_TRANSLATION_KEYS.md appears to be OUTDATED** — it's a planning document from the JSX design phase that was superseded when the FlutterFlow export became the ground truth.

---

## Detailed Breakdown

### Current State: What's in kStaticTranslations (the app)

```
Total keys in app: 355
├─ FlutterFlow keys (~217): 8-character IDs from original export
├─ Phase 7 new keys (~138): Descriptive names added during page implementation
```

**Sample FlutterFlow keys (8-char format):**
```
01uw12sq, 05aeogb1, 0aq8qo7g, 0eehrkgn, 0j8lvplu, 0qr5v44h,
103bep6k, 1fqmkf0t, 6dww9uct, 6f2losum, 6kxja9sp, 6nflsf8i
```

**Sample Phase 7 keys (descriptive format):**
```
about_description_label, about_payment_options_label,
contact_details_phone, contact_details_email,
missing_location_title_main, feedback_form_button_submit
```

---

## File Comparison

### 1. MASTER_TRANSLATION_KEYS.md (251 keys)

**Status:** OUTDATED PLANNING DOCUMENT
**Created:** Early in project (JSX v2 design phase)
**Purpose:** Planning document for "all translation keys needed for JSX v2 design"
**Languages:** 15 languages (da, de, en, es, fi, fr, it, ja, ko, nl, no, pl, sv, uk, zh)
**Format:** Markdown tables with English/Danish examples (NOT actual SQL)

**Key observations from the file:**
- Contains notes like "These keys already exist in FlutterFlow. Included here for completeness."
- Contains notes like "Verify before adding to Supabase"
- Many keys were planning/wishlist items that were later found to exist in FlutterFlow
- **Only 19 keys from this file actually made it into the app** (out of 251!)
  - 13 keys overlap with NEW_TRANSLATION_KEYS.sql
  - 6 keys are unique to MASTER but in the app

**Keys that overlap (exist in both MASTER and current app):**
```
bwvizajd, feedback_form_button_submit, filter_only_open, foeokmwh,
fojleyaf, gallery_food, gallery_interior, gallery_menu, gallery_no_images,
gallery_outdoor, opycnrvy, sort_match, sort_nearest, sort_newest,
sort_price_high, sort_price_low, sort_sheet_title, sort_station, zlgcyzrw
```

**Conclusion:** MASTER_TRANSLATION_KEYS.md is 92% UNUSED (232/251 keys never made it into the app). It should be treated as a **historical planning document**, not a current data source.

---

### 2. NEW_TRANSLATION_KEYS.sql (148 keys)

**Status:** ACTIVE — READY FOR MIGRATION
**Created:** During Phase 6B/7 (page-by-page implementation)
**Purpose:** Actual SQL INSERTs for new keys added during Phase 7
**Languages:** 7 languages (en, da, de, fr, it, no, sv)
**Format:** Executable SQL INSERT statements

**Key observations:**
- **132 keys from this file are actually used in the app** (out of 148)
- 16 keys in this file are NOT in the app (may have been renamed or removed during implementation)
- These are REAL keys with REAL translations, ready to insert into Supabase

**Sample keys from NEW_TRANSLATION_KEYS.sql:**
```sql
-- MissingLocationFormWidget (18 keys)
missing_location_title_main, missing_location_subtitle_main_1,
missing_location_title_business_name, missing_location_hint_business_address

-- ContactUsFormWidget (17 keys)
contact_form_button_submit, contact_form_error_contact_required,
contact_form_hint_message, contact_form_subtitle_contact

-- FeedbackFormWidget (16 keys)
feedback_form_button_submit, feedback_form_error_email_invalid,
feedback_form_hint_email, feedback_form_subtitle_email

-- And 97 more keys from other Phase 7 widgets/pages...
```

**Conclusion:** NEW_TRANSLATION_KEYS.sql is the REAL migration file that should be executed.

---

## Overlap Analysis

### Keys in BOTH MASTER and NEW (13 keys - duplicates):
```
filter_only_open, gallery_food, gallery_interior, gallery_menu,
gallery_no_images, gallery_outdoor, sort_match, sort_nearest,
sort_newest, sort_price_high, sort_price_low, sort_sheet_title,
sort_station
```

**Implication:** These 13 keys are duplicated. If MASTER was already executed to Supabase, running NEW_TRANSLATION_KEYS.sql might create conflicts (duplicate key errors) or overwrite existing translations.

---

## What's in Supabase Right Now?

**We don't have direct Supabase access in this analysis, but based on the codebase context:**

### Scenario A: MASTER_TRANSLATION_KEYS was NEVER executed
- Supabase likely contains: **FlutterFlow keys (~217) + possibly some dynamic BuildShip keys**
- NEW_TRANSLATION_KEYS.sql is 100% new data
- **Action:** Execute NEW_TRANSLATION_KEYS.sql directly

### Scenario B: MASTER_TRANSLATION_KEYS was PARTIALLY executed
- Supabase might contain: **FlutterFlow keys + some MASTER keys (e.g., the 13 overlapping keys)**
- NEW_TRANSLATION_KEYS.sql would have 13 duplicate keys
- **Action:** Need to check Supabase for existing keys, or use `INSERT ... ON CONFLICT` to upsert

### Scenario C: MASTER_TRANSLATION_KEYS was FULLY executed
- Supabase contains: **FlutterFlow keys + all 251 MASTER keys**
- But 232 of those keys are UNUSED by the app
- NEW_TRANSLATION_KEYS.sql would have 13 duplicate keys
- **Action:** Clean up unused MASTER keys, upsert the 13 overlapping keys, insert the rest from NEW

---

## Recommended Migration Strategy

### Step 1: VERIFY CURRENT SUPABASE STATE (USER ACTION)

**You need to run this SQL in Supabase to understand what's there:**

```sql
-- Check total keys in Supabase
SELECT COUNT(*) as total_keys FROM ui_translations;
SELECT COUNT(DISTINCT translation_key) as unique_keys FROM ui_translations;

-- Check if MASTER keys exist (sample check)
SELECT translation_key FROM ui_translations
WHERE translation_key IN (
  'match_full_header', 'match_partial_header', 'match_other_header',
  'sort_match', 'sort_nearest', 'sort_station', 'filter_only_open'
)
ORDER BY translation_key;

-- Check if NEW keys exist (sample check)
SELECT translation_key FROM ui_translations
WHERE translation_key IN (
  'missing_location_title_main', 'contact_form_button_submit',
  'feedback_form_button_submit', 'about_description_label'
)
ORDER BY translation_key;

-- Check if FlutterFlow keys exist (sample check)
SELECT translation_key FROM ui_translations
WHERE translation_key IN (
  '6dww9uct', '05aeogb1', '0aq8qo7g', '0eehrkgn', '6f2losum'
)
ORDER BY translation_key;
```

**Based on the results, choose the appropriate path below:**

---

### Step 2A: If Supabase has ONLY FlutterFlow keys (Scenario A - MOST LIKELY)

**This is the simplest case and most likely scenario.**

✅ **Action:** Run NEW_TRANSLATION_KEYS.sql directly

```bash
# No modifications needed - execute as-is
psql <supabase-connection> -f _reference/NEW_TRANSLATION_KEYS.sql
```

**Result:**
- Supabase will have: 217 FlutterFlow keys + 148 NEW keys = 365 total keys
- App uses 355 of these (10 extra keys is fine - future use or deprecated)

---

### Step 2B: If Supabase has FlutterFlow + SOME MASTER keys (Scenario B)

**This means MASTER was partially executed, likely just the 13 overlapping keys.**

✅ **Action:** Modify NEW_TRANSLATION_KEYS.sql to use UPSERT (ON CONFLICT)

**Modification needed at the top of NEW_TRANSLATION_KEYS.sql:**

```sql
-- Change all INSERT statements to:
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES (...)
ON CONFLICT (translation_key, language_code)
DO UPDATE SET
  translation_text = EXCLUDED.translation_text,
  category = EXCLUDED.category;
```

**Or simpler:** Use a temp table approach to skip duplicates:

```sql
-- At the start of NEW_TRANSLATION_KEYS.sql, add:
CREATE TEMP TABLE IF NOT EXISTS new_translations (
  translation_key TEXT,
  language_code TEXT,
  translation_text TEXT,
  category TEXT
);

-- Then change all INSERT INTO ui_translations to INSERT INTO new_translations

-- At the end, add:
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
SELECT * FROM new_translations
WHERE NOT EXISTS (
  SELECT 1 FROM ui_translations
  WHERE ui_translations.translation_key = new_translations.translation_key
    AND ui_translations.language_code = new_translations.language_code
);
```

---

### Step 2C: If Supabase has FlutterFlow + ALL MASTER keys (Scenario C - UNLIKELY)

**This means MASTER was fully executed, leaving 232 unused keys in Supabase.**

⚠️ **Action:** Clean up Supabase, then run NEW_TRANSLATION_KEYS.sql

**Step 2C.1: Identify unused MASTER keys**

```sql
-- List all keys from MASTER that are NOT in the app
-- (You'll need to manually create this list from the analysis above)
-- Here are the 232 unused keys from MASTER that should be removed:

-- [This would require generating a full list from the comm analysis]
```

**Step 2C.2: Delete unused MASTER keys**

```sql
DELETE FROM ui_translations
WHERE translation_key IN (
  -- 232 keys that are in MASTER but NOT in the app
  -- (list to be generated based on comparison)
);
```

**Step 2C.3: Run NEW_TRANSLATION_KEYS.sql with UPSERT** (see Step 2B)

---

## Language Coverage Issue

**CRITICAL DIFFERENCE:**

- **MASTER_TRANSLATION_KEYS.md:** 15 languages
  `da, de, en, es, fi, fr, it, ja, ko, nl, no, pl, sv, uk, zh`

- **NEW_TRANSLATION_KEYS.sql:** 7 languages
  `en, da, de, fr, it, no, sv`

**Missing in NEW_TRANSLATION_KEYS.sql:** `es, ja, ko, nl, pl, uk, zh` (8 languages)

**Implication:** If you run NEW_TRANSLATION_KEYS.sql as-is, the 148 new keys will only exist in 7 languages. Users who select Spanish, Japanese, Korean, Dutch, Polish, Ukrainian, or Chinese will see MISSING TRANSLATIONS for all Phase 7 features.

**Recommendation:** Before running NEW_TRANSLATION_KEYS.sql, ADD translations for the missing 8 languages, or accept that those languages will fall back to English for Phase 7 keys.

---

## Final Recommendation

### RECOMMENDED APPROACH (Safe & Clean)

1. **VERIFY:** Run Step 1 SQL queries to check current Supabase state
2. **BACKUP:** Export current `ui_translations` table before making changes
3. **IF Supabase has only FlutterFlow keys (most likely):**
   - Run NEW_TRANSLATION_KEYS.sql as-is → adds 148 keys × 7 languages = 1,036 rows
4. **IF Supabase has FlutterFlow + MASTER keys:**
   - Option A (simple): Use ON CONFLICT upsert (see Step 2B)
   - Option B (clean): Delete unused MASTER keys first, then run NEW with upsert
5. **LANGUAGE GAP:** Decide whether to translate the 148 NEW keys into the missing 8 languages
6. **VERIFY:** After migration, run:
   ```sql
   SELECT COUNT(DISTINCT translation_key) FROM ui_translations;
   -- Expected: ~365 keys (217 FlutterFlow + 148 NEW)
   ```
7. **ARCHIVE:** Move MASTER_TRANSLATION_KEYS.md to `_reference/_archive/` since it's outdated

---

## What About MASTER_TRANSLATION_KEYS.md?

**Status:** OUTDATED — 92% of its keys were never used in the app.

**Recommendation:**

✅ **ARCHIVE IT** — Move to `_reference/_archive/MASTER_TRANSLATION_KEYS.md`

**Reasoning:**
- Only 19 of its 251 keys are in the app (7.5% usage rate)
- 13 of those 19 keys are duplicates of NEW_TRANSLATION_KEYS.sql
- Many keys have notes like "already exist in FlutterFlow" — proving it was superseded
- It's in markdown format, not executable SQL — it was never meant to be run
- Keeping it in the main `_reference/` folder creates confusion

**If you want to preserve it for historical reference:**

```bash
mkdir -p _reference/_archive
git mv MASTER_TRANSLATION_KEYS.md _reference/_archive/
git commit -m "chore: archive outdated MASTER_TRANSLATION_KEYS.md (superseded by FlutterFlow export)"
```

---

## Summary Table

| File | Status | Keys | In App | Languages | Action |
|------|--------|------|--------|-----------|--------|
| **FlutterFlow keys** (in app) | Active | ~217 | 217 (100%) | 7+ | Already in Supabase |
| **NEW_TRANSLATION_KEYS.sql** | READY TO MIGRATE | 148 | 132 (89%) | 7 | ✅ **RUN THIS** |
| **MASTER_TRANSLATION_KEYS.md** | OUTDATED | 251 | 19 (7.5%) | 15 | 🗄️ Archive |

---

## Next Steps (USER ACTION)

1. ✅ **Read this analysis**
2. ✅ **Run Step 1 verification queries in Supabase** to determine current state
3. ✅ **Report back:** How many keys are in Supabase? Do MASTER keys exist?
4. ✅ **Based on your report:** I'll prepare the exact migration SQL to run
5. ✅ **Execute migration SQL** in Supabase
6. ✅ **Verify:** Confirm all 355 app keys exist in Supabase
7. ✅ **Continue to Phase 8:** Switch app from `ts()` to `td()`, delete `kStaticTranslations`

---

**Questions for User:**

1. How many rows are currently in your `ui_translations` table in Supabase?
2. Do any of the MASTER keys exist (e.g., `match_full_header`, `sort_match`)?
3. Do any of the NEW keys exist (e.g., `missing_location_title_main`)?
4. Do you want to add translations for the missing 8 languages (es, ja, ko, nl, pl, uk, zh) before running the migration?
