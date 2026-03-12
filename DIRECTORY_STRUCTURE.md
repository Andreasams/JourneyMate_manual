# JourneyMate — Directory Structure

**Last Updated:** March 12, 2026

This document describes the organization of the JourneyMate project directory.

---

## Root Directory

The root contains only essential documentation and configuration files:

```
C:\Users\Rikke\Documents\JourneyMate\Main\
├── CLAUDE.md                      # Main instructions for Claude Code sessions
├── ARCHITECTURE.md                # App architecture and patterns
├── DESIGN_SYSTEM_flutter.md       # Design tokens (colors, spacing, typography)
├── NAVIGATION_GUIDE.md            # Task-based documentation navigation
├── CONTRIBUTING.md                # Contribution guidelines
├── DIRECTORY_STRUCTURE.md         # This file
├── codemagic.yaml                 # CI/CD configuration
├── .gitignore                     # Git ignore rules
└── journey_mate/                  # Main Flutter application
```

---

## Key Directories

### `/journey_mate/` — Production Flutter App
The main Flutter application codebase. This is the only production code.

**Path:** `journey_mate/`
**Contents:** All Flutter app code (pages, widgets, providers, services, models)
**Reference:** See ARCHITECTURE.md for code organization

#### Folder-Per-Page Pattern

All pages follow the **folder-per-page pattern** for organization:

**Structure:**
```
lib/pages/
├── <page_name>/
│   └── <page_name>_page.dart
```

**Example:**
```
lib/pages/
├── search/
│   └── search_page.dart              ← List + map view toggle
├── business_profile/
│   ├── business_profile_page.dart
│   └── business_profile_page_v2.dart  ← Page variants in same folder
└── settings/
    ├── settings_main_page.dart
    ├── localization_page.dart
    └── contact_us_page.dart  ← Related pages grouped in subfolder
```

**Benefits:**
1. **Clear organization** — One folder per page
2. **Co-location** — Page-specific widgets can live with page
3. **Consistency** — All pages follow same pattern
4. **Easier navigation** — Predictable import paths

**Import paths:**
- From `lib/router/app_router.dart`: `import '../pages/search/search_page.dart';`
- From another page: `import '../../pages/business_profile/business_profile_page.dart';`

**Migration:** Standardized March 2026 (commit 1086daf). Previously, some pages were at root (`lib/pages/search_page.dart`) while others were in folders.

#### Widget Organization: Shared vs Page-Specific

**Decision Rule:** Widgets belong in `lib/pages/<section>/widgets/` if used by 1 page, `lib/widgets/shared/` if used by 2+ pages.

**Example: Settings Section (Commit 6d5b8d4)**

```
lib/pages/settings/
├── widgets/                                    ← Page-specific widgets
│   ├── contact_us_form_widget.dart            (Contact Us page only)
│   ├── feedback_form_widget.dart              (Share Feedback page only)
│   ├── location_status_card.dart              (Localization page only)
│   └── missing_location_form_widget.dart      (Missing Place page only)
├── settings_main_page.dart
├── contact_us_page.dart
├── localization_page.dart
├── share_feedback_page.dart
└── missing_place_page.dart
```

**Why section-level (`lib/pages/settings/widgets/`) instead of per-page folders?**
- Settings pages are simple wrappers — widgets contain the logic
- All 4 widgets belong to settings section semantically
- Reduces folder nesting (2 levels instead of 3)
- Alternative: Move to per-page folders if widgets become complex (e.g., multiple widgets per page)

**Import paths after organization:**
- From settings page: `import 'widgets/contact_us_form_widget.dart';`
- From widget to theme: `import '../../../theme/app_colors.dart';`

**Widgets that stayed in `lib/widgets/shared/`:**
- `LanguageSelectorButton` — Used on Welcome page + Localization page
- `CurrencySelectorButton` — Used on Welcome page + Localization page
- `NavBarWidget` — Used on Settings page + Search page
- `search_results_map_view.dart` — Google Maps map view for search results (commit `c545543`)
- `map_business_preview_card.dart` — Preview card shown on map marker tap (commit `c545543`)
- `bottom_sheet_header.dart` — Shared header with swipe bar + action buttons for all bottom sheets (commit `80ae4b6`)
- `map_selection_sheet.dart` — Bottom sheet for choosing Google Maps or Apple Maps (commit `cf10d08`)

**Deleted widgets (commit `e79ec2c` — unused/consolidated):**
- `allergies_filter_widget.dart`, `contact_details_widget.dart`, `dietary_preferences_filter_widgets.dart`, `dietary_restrictions_filter_widget.dart`, `menu_item_card.dart`, `user_feedback_buttons_page.dart`, `user_feedback_buttons_topic.dart`

**Utility files in `lib/utils/`:**
- `map_marker_helper.dart` — Marker icon generation for Google Maps (commit `c545543`)
- `search_result_helpers.dart` — Shared lat/lng extraction from search result documents (commit `c545543`)

**Utility files in `lib/services/custom_functions/`:**
- `language_currency_config.dart` — Single source of truth for language→currency mapping, 15 languages (commit `8eb4a47`)
- `contact_utils.dart` — `formatPhoneForDial()`, `ensureHttpsUrl()` shared contact formatting (commit `932e351`)

**Pattern established March 2, 2026 (commit 6d5b8d4):** Page-specific widgets live near their pages, not in shared/ directory.

---

### `/_reference/` — Documentation & References
API contracts, provider references, and endpoint specifications.

**Path:** `_reference/`

**Structure:**
```
_reference/
├── BUILDSHIP_API_REFERENCE.md          # API contracts for 13 BuildShip endpoints
├── PROVIDERS_REFERENCE.md              # Riverpod provider catalog
├── _buildship/                         # Individual BuildShip endpoint specs
│   └── SEARCH_NODE_v9.2.ts            # Full search endpoint reference (920 lines, v9.2 with geo bounds)
└── _supabase/                          # Supabase table schema references
```

**Purpose:**
- API contracts and provider references for active development
- BuildShip endpoint specs and Supabase schema for API work

---

### `/development_images/` — Development Screenshots
Screenshots and images used for development reference and documentation.

**Path:** `development_images/`
**Contents:** UI screenshots, mockups, and visual references

---

### `/assets/` — Static Assets & Images
Static assets not directly used in the app but part of the project.

**Path:** `assets/`
**Contents:**
- `journeymate_mascot.png` — App mascot image
- `placefindr_launcher_icon_transparent_warm_beige.png` — Legacy launcher icon

**Note:** App assets used in the Flutter app are in `journey_mate/assets/`

---

### `/config/` — Configuration & Keys
Sensitive configuration files and API keys (local only, not in git).

**Path:** `config/`
**Contents:**
- `AuthKey_NXG563P998.p8` — Apple App Store Connect API key (local only)
- `README.md` — Setup instructions (tracked in git)

**⚠️ Security:**
- This directory is in `.gitignore` (except README.md)
- All sensitive files are excluded from version control
- Never commit API keys, certificates, or secrets
- See `config/README.md` for setup instructions

---

### `/.claude/` — Claude Code Configuration
Claude Code settings, skills, and hooks.

**Path:** `.claude/`
**Contents:** User-specific Claude Code configuration (not checked into git)

---

## Quick Reference Table

| File/Folder | Purpose | Used By |
|-------------|---------|---------|
| `CLAUDE.md` | Session instructions | Claude Code (every session) |
| `ARCHITECTURE.md` | App architecture | Claude Code, developers |
| `DESIGN_SYSTEM_flutter.md` | Design tokens | Claude Code, developers |
| `NAVIGATION_GUIDE.md` | Task-based docs | Claude Code (task-specific) |
| `_reference/BUILDSHIP_API_REFERENCE.md` | API contracts | Claude Code (API work) |
| `_reference/PROVIDERS_REFERENCE.md` | Provider catalog | Claude Code (state work) |
| `journey_mate/` | Production code | Flutter build, runtime |
| `config/AuthKey_NXG563P998.p8` | Apple API key | CI/CD (codemagic.yaml) |

---

## For Claude Code Sessions

**Required reading order:**
1. `CLAUDE.md` (this directory, session rules)
2. `ARCHITECTURE.md` (app patterns)
3. `DESIGN_SYSTEM_flutter.md` (design tokens)
4. `_reference/BUILDSHIP_API_REFERENCE.md` (API contracts)
5. `_reference/PROVIDERS_REFERENCE.md` (provider catalog)

**Task-specific:** See `NAVIGATION_GUIDE.md` for targeted reading lists (10-30 minutes)

**Reference when needed:**
- API specs: `_reference/_buildship/` and `_reference/_supabase/`

---

## Maintenance

**When adding new files:**
- Documentation → Root (if essential) or `_reference/`
- Reference specs → `_reference/_buildship/` or `_reference/_supabase/`
- Historical docs → `_reference/archive/`
- Analysis reports → `_reference/`
- Development images → `images_for_debugging/` (ignored by git)
- Static assets → `assets/`
- Config/keys → `config/` (always ignored by git, except README.md)

**Keep root clean:** Only essential docs that Claude Code needs frequently should be in root.

---

**GitHub Repository:** https://github.com/Andreasams/JourneyMate_manual
