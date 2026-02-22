# Translation Supabase Gap Analysis
**Created:** 2026-02-22
**Purpose:** Identify which of the 355 app keys are missing from Supabase (294 keys)

---

## Current State Summary

| Location | Key Count | Notes |
|----------|-----------|-------|
| **App (kStaticTranslations)** | 355 keys | All keys currently used by the app |
| **Supabase (ui_translations)** | 294 keys | Current database state |
| **GAP** | **61 keys** | Keys in app but NOT in Supabase |

---

## Confirmed Findings

### ✅ NEW_TRANSLATION_KEYS.sql Keys ARE in Supabase

The following Phase 7 keys were confirmed to exist in Supabase:
- `contact_form_button_submit`
- `missing_location_title_main`

**Implication:** NEW_TRANSLATION_KEYS.sql (or at least part of it) has ALREADY been executed against Supabase.

**Question:** When was this executed? Was it the full file or partial?

---

## The 61 Missing Keys

**These 61 keys exist in the app but NOT in Supabase.**

### Likely Composition:

Based on your FlutterFlow architecture explanation:

1. **FlutterFlow Page Keys (~30-40 keys)**
   - Keys that were hardcoded in FlutterFlow pages
   - Never went through Supabase in FlutterFlow
   - Now in `kStaticTranslations` but not in database
   - Format: 8-char IDs like `6dww9uct`, `0eehrkgn`

2. **JSX New Keys (~20-30 keys)**
   - Keys added during JSX design phase
   - Not in FlutterFlow at all
   - Added to `kStaticTranslations` but never migrated to Supabase
   - Format: Could be 8-char IDs or descriptive names

---

## Next Steps to Identify the Gap

### Step 1: Get Full List of Keys in Supabase

**USER ACTION:** Run this in Supabase:

```sql
-- Export all distinct translation keys from Supabase
SELECT DISTINCT translation_key
FROM ui_translations
ORDER BY translation_key;
```

**Save the result** to a file (e.g., `supabase_keys.txt`)

---

### Step 2: Extract All Keys from App

I can generate this for you from `kStaticTranslations`:

```bash
# This will extract all 355 keys from the app
grep "  '.*': {" journey_mate/lib/services/translation_service.dart | \
  sed "s/  '\(.*\)':.*/\1/" | \
  sort > app_keys.txt
```

---

### Step 3: Find the Gap

```bash
# Compare and find keys in app but NOT in Supabase
comm -23 app_keys.txt supabase_keys.txt > missing_from_supabase.txt

# This will give us the exact 61 keys that need to be added to Supabase
```

---

## Understanding NEW_TRANSLATION_KEYS.sql Status

**Given that some NEW keys exist in Supabase, one of these is true:**

### Scenario A: Full File Was Run
- All 148 keys from NEW_TRANSLATION_KEYS.sql were inserted
- The 61 missing keys are ONLY FlutterFlow page keys (8-char IDs)
- **Action:** Need to create SQL for the 61 FlutterFlow page keys

### Scenario B: Partial File Was Run
- Only some NEW keys were inserted (e.g., just MissingLocation + ContactForm sections)
- The 61 missing keys = remaining NEW keys + FlutterFlow page keys
- **Action:** Need to identify which NEW keys are missing, then insert them + FlutterFlow keys

### Scenario C: NEW Keys Were Added Separately
- The NEW keys in Supabase were added manually/individually, not from the SQL file
- The 61 missing keys = most of NEW_TRANSLATION_KEYS.sql + some FlutterFlow page keys
- **Action:** Run the full NEW_TRANSLATION_KEYS.sql with ON CONFLICT handling

---

## Recommended Approach

### Phase 1: Identify the 61 Missing Keys

**USER:** Provide the list of 294 keys from Supabase (Step 1 query above)

**ME:** I'll generate the exact list of 61 missing keys by comparing with the app's 355 keys

### Phase 2: Categorize Missing Keys

Once we have the 61 keys, I'll categorize them:
- FlutterFlow page keys (8-char IDs)
- NEW_TRANSLATION_KEYS.sql keys (if any are missing)
- Other keys

### Phase 3: Generate Missing Keys SQL

I'll create a new SQL file that:
- Extracts translations for the 61 missing keys from `kStaticTranslations`
- Generates INSERT statements in the same format as NEW_TRANSLATION_KEYS.sql
- Uses `ON CONFLICT` to avoid duplicates

### Phase 4: Execute & Verify

- Run the generated SQL against Supabase
- Verify: `SELECT COUNT(DISTINCT translation_key) FROM ui_translations;` should return **355**
- App can then switch to 100% dynamic translations (`td()`)

---

## What You Need to Do NOW

**Run this query in Supabase and paste the full result:**

```sql
SELECT DISTINCT translation_key
FROM ui_translations
ORDER BY translation_key;
```

**Expected output:** 294 rows (one key per row)

Once you provide this, I can:
1. Generate the exact list of 61 missing keys
2. Extract their translations from `kStaticTranslations`
3. Create the final migration SQL file
4. Give you the exact commands to complete Phase 6B

---

## Alternative Quick Check

If you can't easily export all 294 keys, run these targeted queries:

```sql
-- How many FlutterFlow keys (8-char format) are in Supabase?
SELECT COUNT(DISTINCT translation_key)
FROM ui_translations
WHERE LENGTH(translation_key) = 8
  AND translation_key ~ '^[a-z0-9]{8}$';

-- How many NEW keys (descriptive format) are in Supabase?
SELECT COUNT(DISTINCT translation_key)
FROM ui_translations
WHERE LENGTH(translation_key) > 8
  AND translation_key ~ '_';

-- Sample of FlutterFlow keys in Supabase
SELECT DISTINCT translation_key
FROM ui_translations
WHERE LENGTH(translation_key) = 8
  AND translation_key ~ '^[a-z0-9]{8}$'
LIMIT 20;

-- Sample of NEW keys in Supabase
SELECT DISTINCT translation_key
FROM ui_translations
WHERE LENGTH(translation_key) > 8
  AND translation_key ~ '_'
LIMIT 20;
```

This will help us understand the composition of the 294 keys.
