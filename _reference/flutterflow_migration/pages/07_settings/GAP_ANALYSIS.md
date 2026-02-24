# Settings Pages — Gap Analysis

**Purpose:** Identify functional differences between JSX v2 design and FlutterFlow implementation

**Methodology:** Compare DESIGN_README_settings_main.md (JSX v2) with PAGE_README.md + BUNDLE.md (FlutterFlow)

**Date:** 2026-02-19

---

## Gap Categories

- **A1**: Buildable with existing data (Frontend logic after API response)
- **A2**: Buildable with existing data (Backend logic in BuildShip before return)
- **B**: Requires BuildShip API changes
- **C**: Translation infrastructure gaps (new keys needed)
- **D**: Known missing features (user-identified, not in current scope)

---

## Summary

| Category | Count | Description |
|----------|-------|-------------|
| A1 | 0 | Frontend display logic |
| A2 | 0 | Backend processing logic |
| B | 0 | API endpoint changes |
| C | 1 | Translation keys needed |
| D | 0 | Known future features |
| **Total** | **1** | **Functional gap identified** |

---

## Scope Note: Settings is Multiple Pages

The "Settings" functionality is implemented as a **collection of 8 separate pages**:

1. **Account** (`/Account`) - Main settings hub (THIS gap analysis)
2. **Localization** (`/Localization`) - Navigation hub for language & location
3. **Language & Currency** (`/LanguageAndCurrency`) - Actual settings
4. **Location Sharing** (`/LocationSharing`) - Location permissions
5. **Missing Place** (`/MissingPlace`) - Report missing restaurant form
6. **Share Feedback** (`/ShareFeedback`) - User feedback form
7. **Contact Us** (`/ContactUs`) - Support contact form
8. **Privacy Policy** - External URL (Google Docs)

**This gap analysis covers ONLY the main Account hub page.** Sub-pages require separate gap analyses.

---

## Observation: JSX Design vs FlutterFlow Structure

The JSX v2 design shows a **simpler single-page settings interface** with inline controls.

The FlutterFlow implementation uses a **multi-level navigation structure** with dedicated pages for each setting.

**Key Differences:**

| Aspect | JSX v2 Design | FlutterFlow Implementation |
|--------|---------------|----------------------------|
| **Structure** | Single page with sections | Hub page + 7 sub-pages |
| **Navigation** | Sections expand inline | Navigate to dedicated pages |
| **Complexity** | Simple list | Multi-level navigation tree |
| **Settings** | "My JourneyMate" section only | 3 sections (My JM, Reach out, Resources) |

**Design Decision:** FlutterFlow's multi-page approach provides better organization and separates concerns (settings vs feedback vs legal). This should be preserved during migration.

---

## Detailed Gap Analysis

### Gap C.1: Settings Page Translation Keys

**JSX v2 Design:**
- Page title: "Settings & account"
- Section headers: "My JourneyMate", "Reach out", "Resources"
- Setting row labels: "Localization", "Are we missing a place?", "Share feedback", "Contact us", "Terms of use", "Privacy policy"
- Code reference: `DESIGN_README_settings_main.md` lines 1-400

**FlutterFlow Implementation:**
- All text uses translation keys via `FFLocalizations.of(context).getText(key)`
- 10 translation keys total
- Code reference: `PAGE_README.md` lines 82-100

**Translation Keys Already in FlutterFlow:**

| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `cpiiq0im` | Page title | Settings & account | Indstillinger & konto |
| `3tlbn2an` | Section header 1 | My JourneyMate | Min JourneyMate |
| `290fbi5g` | Setting row 1 | Localization | Lokalisering |
| `pb7qrt34` | Section header 2 | Reach out | Tag kontakt |
| `297ogtn9` | Setting row 2 | Are we missing a place? | Mangler vi et sted? |
| `uz83tnpj` | Setting row 3 | Share feedback | Del feedback |
| `dme8eg1t` | Setting row 4 | Contact us | Kontakt os |
| `d952v5y4` | Section header 3 | Resources | Ressourcer |
| `2v106a6z` | Setting row 5 | Terms of use | Vilkår for brug |
| `gtmo283r` | Setting row 6 | Privacy policy | Privatlivspolitik |

**No Gap:** All translation keys already exist in FlutterFlow. Need to verify they're in MASTER_TRANSLATION_KEYS.md for consistency across all pages.

---

## Features in FlutterFlow NOT in JSX Design

The FlutterFlow implementation has several enhancements not in the JSX v2 design:

### Enhancement 1: Three-Section Organization
- **JSX:** Only shows "My JourneyMate" section with localization
- **FlutterFlow:** Three sections (My JourneyMate, Reach out, Resources)
- **Keep:** Yes, provides better organization for feedback channels and legal docs

### Enhancement 2: Communication Channels Section
- **Section:** "Reach out" with 3 options
  - Are we missing a place? (suggest new restaurants)
  - Share feedback (general app feedback)
  - Contact us (support/help)
- **Keep:** Yes, essential for user feedback and product improvement

### Enhancement 3: Resources Section
- **Section:** "Resources" with 2 options
  - Terms of use (legal)
  - Privacy policy (legal)
- **Keep:** Yes, legally required documentation

### Enhancement 4: Icon System
- **Feature:** Each setting row has a Material icon (18px)
  - Localization: `Icons.location_on`
  - Missing place: `Icons.add_circle`
  - Share feedback: `Icons.feedback_rounded`
  - Contact us: `Icons.email_rounded`
  - Terms: `Icons.checklist_rtl_rounded`
  - Privacy: `Icons.privacy_tip`
- **Keep:** Yes, improves scannability and visual interest

### Enhancement 5: Engagement Tracking
- **Feature:** `markUserEngaged()` called on every row tap (6 total)
- **Purpose:** Track user activity for analytics
- **Keep:** Yes, valuable for understanding user behavior

### Enhancement 6: Page View Analytics
- **Feature:** Tracks `page_viewed` event with duration on dispose
- **Event Data:** `pageName: 'settingsAndAccount'`, `durationSeconds`
- **Keep:** Yes, measures engagement with settings

### Enhancement 7: Consistent Row Pattern
- **Visual:** All rows use identical layout (icon + label + chevron)
- **Height:** 40px with standard dividers
- **Interaction:** Transparent splash colors, consistent tap behavior
- **Keep:** Yes, provides predictable UX

---

## Sub-Pages Overview (Future Gap Analyses Needed)

The Settings hub links to sub-pages that each require their own gap analysis:

### 1. Localization Page
- **Route:** `/Localization`
- **Type:** Navigation hub (links to Language & Currency + Location Sharing)
- **Gap Analysis:** Needed
- **Priority:** ⭐⭐⭐⭐⭐ (Critical for internationalization)

### 2. Language & Currency Page
- **Route:** `/LanguageAndCurrency`
- **Type:** Actual settings with dropdowns
- **Custom Widgets:** `LanguageSelectorButton`, `CurrencySelectorButton`
- **Custom Actions:** `updateCurrencyForLanguage`, `updateCurrencyWithExchangeRate`, `getTranslationsWithUpdate`
- **Gap Analysis:** Needed
- **Priority:** ⭐⭐⭐⭐⭐ (Critical)

### 3. Location Sharing Page
- **Route:** `/LocationSharing`
- **Type:** Permission management with toggle
- **Custom Actions:** `checkLocationPermission`, `requestLocationPermissionAndTrack`, `openLocationSettings`
- **Gap Analysis:** Needed
- **Priority:** ⭐⭐⭐⭐⭐ (Critical)

### 4. Missing Place Page
- **Route:** `/MissingPlace`
- **Type:** Form for suggesting new restaurants
- **Custom Widgets:** `MissingLocationFormWidget`
- **Analytics:** `missing_place_reported` event
- **Gap Analysis:** Needed
- **Priority:** ⭐⭐⭐⭐ (High - user contribution feature)

### 5. Share Feedback Page
- **Route:** `/ShareFeedback`
- **Type:** Feedback form with topic selection
- **Custom Widgets:** `FeedbackFormWidget`, `UserFeedbackButtonsPage`, `UserFeedbackButtonsTopic`
- **Analytics:** `feedback_submitted` event
- **Gap Analysis:** Needed
- **Priority:** ⭐⭐⭐⭐ (High - product improvement)

### 6. Contact Us Page
- **Route:** `/ContactUs`
- **Type:** Support contact form
- **Custom Widgets:** `ContactUsFormWidget`
- **Gap Analysis:** Needed
- **Priority:** ⭐⭐⭐ (Medium - support channel)

### 7. Privacy Policy Page
- **Route:** External URL (Google Docs)
- **Issue:** ⚠️ Only available in English
- **Gap Analysis:** Translation issue, not functional gap
- **Priority:** ⭐⭐ (Low - legal requirement)

---

## Migration Notes

### High Priority Gaps
None for the main Account hub page. All translation keys already exist.

### Medium Priority Gaps
1. **Gap C.1:** Verify all translation keys are in MASTER_TRANSLATION_KEYS.md for consistency

### Low Priority Gaps
None identified.

---

## Architecture Summary

### Frontend Logic (A1) - 0 gaps
No frontend logic gaps identified. Page is a simple navigation hub.

### Backend Logic (A2) - 0 gaps
No backend processing required. Page only provides navigation links.

### API Changes (B) - 0 gaps
No API calls on this page. Pure navigation hub.

### Translation Keys (C) - 1 gap
- 10 translation keys already exist in FlutterFlow
- Need to add to MASTER_TRANSLATION_KEYS.md for consistency
- Sub-pages will have their own translation keys

### Known Missing (D) - 0 gaps
No features explicitly marked as "not in current scope" by user.

---

## Known Issues

### Privacy Policy Translation
⚠️ **Privacy Policy Only in English:**
- Currently only available in English (external Google Docs)
- Other languages show blank text or fallback to English
- **Solution:** Translate document or add language notice
- **Priority:** Low (legal requirement, but not blocking)

### External Dependencies
⚠️ **Legal Documents on Google Docs:**
- Terms and Privacy Policy hosted on external Google Docs
- Risk: URLs may change or become inaccessible
- **Solution:** Consider in-app legal text or self-hosted web view
- **Priority:** Low (acceptable for MVP)

---

## Next Steps

1. **Add translation keys to MASTER_TRANSLATION_KEYS.md**
   - 10 keys from Account hub page
   - Include English and Danish translations
   - Mark as "already in FlutterFlow"

2. **Create gap analyses for sub-pages**
   - Localization page (navigation hub)
   - Language & Currency page (critical settings)
   - Location Sharing page (critical permissions)
   - Missing Place page (user contribution)
   - Share Feedback page (product improvement)
   - Contact Us page (support)

3. **Verify translation consistency**
   - Ensure all keys match across FlutterFlow and MASTER_TRANSLATION_KEYS.md
   - Check that Danish translations are accurate

4. **Document sub-page navigation flow**
   - Settings → Localization → Language & Currency
   - Settings → Localization → Location Sharing
   - Settings → [Form Pages]
   - Settings → [External URLs]

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete (Account hub page only)
**Total Gaps:** 1 (0 frontend + 0 backend + 0 API + 1 translation + 0 known missing)

**Key Finding:** The Account hub page is production-ready with all translation keys existing in FlutterFlow. Sub-pages require separate gap analyses to identify their specific needs.

**Note:** The JSX design shows a simpler single-page approach, but FlutterFlow's multi-page structure provides better organization. The multi-page approach should be preserved during migration.
