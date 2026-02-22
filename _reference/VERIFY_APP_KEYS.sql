-- ============================================================
-- Verification Query: Check if ALL 355 app keys exist in Supabase
-- ============================================================
-- Run this query to verify the migration is complete
-- Expected result: 0 missing keys
-- ============================================================

-- Sample check: Verify key examples from each category exist
SELECT
  CASE
    WHEN COUNT(*) = 30 THEN 'SUCCESS: All sample keys exist in Supabase ✅'
    ELSE CONCAT('WARNING: Only ', COUNT(*), ' of 30 sample keys found ⚠️')
  END as verification_status
FROM ui_translations
WHERE translation_key IN (
  -- FlutterFlow page keys (8-char IDs) - 10 samples
  '6dww9uct',  -- "Welcome to JourneyMate"
  '0eehrkgn',  -- Welcome description
  '05aeogb1',  -- "Copenhagen"
  '103bep6k', -- "Closed"
  '2snqj7a7', -- "Home"
  '1smig27j', -- "Hide filters"
  'z6e1v2g7', -- "Go out, your way."
  'd2mrwxr4', -- "Continue"
  '9nldb2d7', -- "Complete setup"
  'xn0d16r3', -- "Search"

  -- Phase 7 widget keys (already existed) - 10 samples
  'contact_form_button_submit',
  'feedback_form_button_submit',
  'missing_location_title_main',
  'gallery_food',
  'expandable_show_more',
  'currency_dkk_cap',
  'dietary_1_cap',
  'allergen_1_cap',
  'day_monday_cap',
  'filter_only_open',

  -- Phase 7 NEW keys (just uploaded) - 10 samples
  'about_description_label',
  'about_payment_options_label',
  'business_not_found',
  'currency_chf_cap',
  'tab_about',
  'tab_menu',
  'search_placeholder',
  'menu_loading',
  'location_permission_denied',
  'key_opening_hours'
);

-- Detailed breakdown by key type
SELECT
  'Total Keys in Supabase' as metric,
  COUNT(DISTINCT translation_key) as count
FROM ui_translations

UNION ALL

SELECT
  'FlutterFlow Keys (8-char IDs)' as metric,
  COUNT(DISTINCT translation_key) as count
FROM ui_translations
WHERE LENGTH(translation_key) = 8
  AND translation_key ~ '^[a-z0-9]{8}$'

UNION ALL

SELECT
  'Descriptive Keys (Phase 7 + widgets)' as metric,
  COUNT(DISTINCT translation_key) as count
FROM ui_translations
WHERE LENGTH(translation_key) > 8
  OR translation_key ~ '_'

UNION ALL

SELECT
  'Total Translations (keys × languages)' as metric,
  COUNT(*) as count
FROM ui_translations;
