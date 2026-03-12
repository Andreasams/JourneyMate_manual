# JourneyMate Flutter Design System

**Version:** 1.3 - March 2026
**Last Updated:** 2026-03-12
**Implementation:** `journey_mate/lib/theme/` (design token source files)

**Purpose:** Complete Flutter implementation reference for the JourneyMate design system. Every design decision from the JSX design system has been translated to Flutter/Dart patterns.

**Related Documentation:**
- **ARCHITECTURE.md** — Explains WHEN and HOW to use these design tokens in code
- **CLAUDE.md** — Quick reference for code review checklist (design token adherence)
- **CONTRIBUTING.md** — Developer onboarding with design standards

---

## Quick Start

```dart
import '../shared/app_theme.dart';

// Use predefined colors
Container(color: AppColors.accent)

// Use predefined spacing
SizedBox(height: AppSpacing.xl)

// Use predefined text styles
Text('Hello', style: AppTypography.body)

// Use predefined input decorations
TextField(decoration: AppInputDecorations.standard(hintText: 'Email'))

// Use predefined button styles
ElevatedButton(style: AppButtonStyles.primary, ...)
```

---

## 1. Colors (AppColors)

### Primary Palette

| Constant | Hex | Usage |
|----------|-----|-------|
| `AppColors.accent` | `#e8751a` | CTAs, interactive elements, filter selections, brand |
| `AppColors.green` | `#1a9456` | Match confirmation, need-match pills |
| `AppColors.greenBg` | `#f0f9f3` | Background for full-match cards |
| `AppColors.greenBorder` | `#d0ecd8` | Border for full-match cards |
| `AppColors.red` | `#c9403a` | Closed status, errors, warnings |
| `AppColors.redBorder` | `#f5d5d2` | Border for missed-need chips in match cards |
| `AppColors.redBg` | `#fef4f3` | Background for no-match cards and error states |
| `AppColors.orangeBg` | `#fef8f2` | Background for partial-match cards |
| `AppColors.orangeBorder` | `#f0dcc8` | Border for partial-match cards |
| `AppColors.fullMatchCardBorder` | `#b8d4c0` | Border for full-match restaurant cards in search results |

### Text Colors

| Constant | Hex | Usage |
|----------|-----|-------|
| `AppColors.textPrimary` | `#0f0f0f` | Headings, labels, important content |
| `AppColors.textSecondary` | `#555555` | Body text, descriptions |
| `AppColors.textTertiary` | `#888888` | Hints, helper text |
| `AppColors.textMuted` | `#999999` | Less important information |
| `AppColors.textPlaceholder` | `#aaaaaa` | Input placeholders |
| `AppColors.textDisabled` | `#bbbbbb` | Disabled text |

### UI Element Colors

| Constant | Hex | Usage |
|----------|-----|-------|
| `AppColors.bgPage` | `#ffffff` | Primary page background |
| `AppColors.bgCard` | `#ffffff` | Card backgrounds |
| `AppColors.bgInput` | `#f5f5f5` | Input field backgrounds |
| `AppColors.bgSurface` | `#fafafa` | Alternative light background |
| `AppColors.border` | `#e8e8e8` | Default borders |
| `AppColors.borderSubtle` | `#f0f0f0` | Very light borders |
| `AppColors.divider` | `#f2f2f2` | Separator lines |
| `AppColors.dotSeparator` | `#D0D0D0` | Decorative dot separators (hero row: status . price . distance) |

### Semantic Colors (Aliases)

| Constant | Maps To | Usage |
|----------|---------|-------|
| `AppColors.error` | `red` | Form errors, required asterisks |
| `AppColors.success` | `green` | Confirmations, success states |

### Color Rules (Critical)

1. **Orange is NEVER used for match status** - Orange means "interactive" or "brand"
2. **Green is NEVER used for CTAs** - Green is purely informational (matches)
3. **No black backgrounds** - Darkest element is `#0f0f0f` text
4. **No colored shadows** - Shadows are always neutral black with low opacity

---

## 2. Spacing (AppSpacing)

| Constant | Value | Usage |
|----------|-------|-------|
| `AppSpacing.xxs` | 2px | Tight row spacing (between card text lines) |
| `AppSpacing.xs` | 4px | Minimal spacing, small icon-to-text gaps |
| `AppSpacing.xsm` | 6px | Small inline spacing (status row gaps) |
| `AppSpacing.sm` | 8px | Label to input, between paragraphs, heading to description |
| `AppSpacing.msm` | 10px | Section header bottom margin |
| `AppSpacing.md` | 12px | Between chips, moderate gaps |
| `AppSpacing.mlg` | 14px | Card padding |
| `AppSpacing.lg` | 16px | Standard spacing |
| `AppSpacing.xl` | 20px | **Standard page padding (all pages)**, between form fields |
| `AppSpacing.xxl` | 24px | Before submit button, major section gaps |
| `AppSpacing.xxxl` | 32px | Section spacing |
| `AppSpacing.huge` | 40px | Major section spacing |

### Common Patterns

```dart
// Label to input field
const SizedBox(height: AppSpacing.sm)  // 8px

// Between form fields
const SizedBox(height: AppSpacing.xl)  // 20px

// Before submit button
const SizedBox(height: AppSpacing.xxl)  // 24px

// Page padding (standard for all pages)
padding: const EdgeInsets.all(AppSpacing.xl)  // 20px

// Heading to description
const SizedBox(height: AppSpacing.sm)  // 8px
```

---

## 3. Border Radii (AppRadius)

**Unified scale: 2 · 4 · 8 · 12 · 16 · 20.** Every radius maps to one of six values. Semantic names give context; the underlying scale keeps visuals consistent. Overhauled in commit `c4066fc` (2026-03-11).

| Scale | Constant | Value | Usage |
|-------|----------|-------|-------|
| 2px | `AppRadius.handle` | 2px | Drag handles in bottom sheets |
| 4px | `AppRadius.checkbox` | 4px | Checkbox corners (filter columns, sort, feedback) |
| 8px | `AppRadius.chip` | 8px | Chips, facility tags, payment badges |
| 8px | `AppRadius.facility` | 8px | Facility / payment containers (same weight as chips) |
| 12px | `AppRadius.filter` | 12px | Filter buttons, tab selectors |
| 12px | `AppRadius.input` | 12px | Text inputs, text areas, dropdowns |
| 12px | `AppRadius.button` | 12px | Primary / secondary action buttons |
| 12px | `AppRadius.logoSmall` | 12px | Small logo containers (50×50) |
| 16px | `AppRadius.card` | 16px | Cards (search results, settings, match cards) |
| 16px | `AppRadius.logoLarge` | 16px | Large logo / avatar containers |
| 20px | `AppRadius.bottomSheet` | 20px | Bottom sheet top corners |
| 20px | `AppRadius.pill` | 20px | Pill-shaped floating buttons (sort, open-only) |

### Common Patterns

```dart
// Input field
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),  // 12px
    ),
  ),
)

// Primary button
ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),  // 12px
    ),
  ),
)

// Card
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.card),  // 16px
  ),
)

// Pill button (sort, open-only)
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.pill),  // 20px
  ),
)
```

### Migration from Old Values

| Old Value | New Value | Notes |
|-----------|-----------|-------|
| `checkbox: 5` | `checkbox: 4` | Tightened to match 4px step |
| `facility: 9` | `facility: 8` | Aligned with chip (same visual weight) |
| `filter: 10` | `filter: 12` | Aligned with input/button scale step |
| `button: 14` | `button: 12` | Aligned with filter/input scale step |
| `logoSmall: 13` | `logoSmall: 12` | Aligned with 12px scale step |
| `logoLarge: 18` | `logoLarge: 16` | Aligned with card scale step |
| `bottomSheet: 22` | `bottomSheet: 20` | Aligned with 20px scale step |
| — | `handle: 2` | NEW (drag handles) |
| — | `pill: 20` | NEW (pill-shaped floating buttons) |

---

## 4. Typography (AppTypography)

**23-style type scale.** Headings: 6-level hierarchy (26→16, 2px steps, h1–h5 w700, h6 w600) plus hero (28/w800). Body: 14/15/16 at w300–w700. All styles default to `textPrimary` with `height: 1.45`. Only `button` (white) and `price` (accent) differ.

**Streamlined in commit `7f0c892` (2026-03-10):** Replaced 21 inconsistent styles with a clean, predictable scale. Heavy body variants added 2026-03-10.
**Heading scale expanded in commit `8095eb9` (2026-03-10):** 6-level hierarchy (h1-h6), 2px steps. Removed h1Heavy and letterSpacing from headings.
**Hero + body weight split (2026-03-11):** Added `hero` (28/w800) for welcome page titles (commit `c4066fc`). Softened `h6` from w700→w600 (commit `a9649cd`). Renamed `bodyHeavy` (w700) → `bodyExtraHeavy`, added new `bodyHeavy` at w600 (commit `3469f47`).

### Compact Reference

```
HERO
hero → 28/w800/1.2  — welcome page titles

HEADINGS — 6-level hierarchy, 2px steps, h1–h5 w700, h6 w600
h1 → 26/w700/1.2  — app-section entry titles (Search, Settings)
h2 → 24/w700/1.2  — featured entity names (restaurant, coupon, blog)
h3 → 22/w700/1.3  — sheet / overlay titles
h4 → 20/w700/1.3  — section headings, sub-headings
h5 → 18/w700/1.3  — AppBar titles (deliberately understated)
h6 → 16/w600/1.3  — sub-section labels (e.g. inside collapsibles)

BODY (3 sizes × 3–5 weights, all 1.45 line height, all textPrimary)
                  Light(w300)    Regular(w400)  Medium(w500)   Heavy(w600)    ExtraHeavy(w700)
bodyLg (16px)     —              bodyLg         bodyLgMedium   —              bodyLgHeavy
body   (15px)     bodyLight      body           bodyMedium     bodyHeavy      bodyExtraHeavy
bodySm (14px)     —              bodySm         bodySmMedium   —              bodySmHeavy

UI
button       → 18/w600/white/1.2
price        → 14/w600/accent/1.45
```

### Hero Title

| Style | Size | Weight | Line Height | Role |
|-------|------|--------|-------------|------|
| `AppTypography.hero` | 28px | w800 | 1.2 | Welcome page titles |

Added in commit `c4066fc` (2026-03-11) for large welcome page headings that need extra visual weight above h1.

### Headings — 2px Step System

All headings use `textPrimary`. No letterSpacing. h1–h5 use w700; h6 uses w600 (softened in commit `a9649cd`).

| Style | Size | Weight | Line Height | Role |
|-------|------|--------|-------------|------|
| `AppTypography.h1` | 26px | w700 | 1.2 | App-section entry titles (Search, Settings) |
| `AppTypography.h2` | 24px | w700 | 1.2 | Featured entity names (restaurant, coupon, blog) |
| `AppTypography.h3` | 22px | w700 | 1.3 | Sheet / overlay titles |
| `AppTypography.h4` | 20px | w700 | 1.3 | Section headings, sub-headings |
| `AppTypography.h5` | 18px | w700 | 1.3 | AppBar titles (deliberately understated) |
| `AppTypography.h6` | 16px | w600 | 1.3 | Sub-section labels, settings subheadings |

**Hierarchy logic:**
- h1–h3 are all "page titles" in their respective contexts (app section, page, sheet)
- h4 is for sectioning content within a page
- h5 is deliberately small so AppBar titles don't compete with page headings
- h6 bridges headings and body text for sub-section labels (w600, lighter than other headings)

### Body Text (3 sizes × 3–4 weights)

All body styles: `color: textPrimary`, `height: 1.45`

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.bodyLg` | 16px | w400 | Long-form text, descriptions |
| `AppTypography.bodyLgMedium` | 16px | w500 | Labels, emphasized body |
| `AppTypography.bodyLgHeavy` | 16px | w700 | Bold body text, strong emphasis |
| `AppTypography.body` | 15px | w400 | Standard body text |
| `AppTypography.bodyLight` | 15px | w300 | Light secondary text (last-updated rows, subtle metadata) |
| `AppTypography.bodyMedium` | 15px | w500 | Card names, menu items |
| `AppTypography.bodyHeavy` | 15px | w600 | Emphasized card names, section labels |
| `AppTypography.bodyExtraHeavy` | 15px | w700 | Bold card names (opening hours, contact values) |
| `AppTypography.bodySm` | 14px | w400 | Helper text, card details |
| `AppTypography.bodySmMedium` | 14px | w500 | Chips, status, distance |
| `AppTypography.bodySmHeavy` | 14px | w700 | Bold small text, highlighted details |

### UI Elements

| Style | Size | Weight | Color | Usage |
|-------|------|--------|-------|-------|
| `AppTypography.button` | 18px | w600 | white | Primary buttons |
| `AppTypography.price` | 14px | w600 | accent | Prices (orange) |

### Migration from Old Names

| Old Name (removed) | New Name | Notes |
|---------------------|----------|-------|
| `pageTitle` | `h1` | Same: 26/w700 |
| `restaurantName` / `h1Heavy` | `h2` | Was 26/w800, now 24/w700 |
| `sectionHeading` | `h4` | Was `h2` (20/w700), renamed |
| `categoryHeading` | `h5` | Was `h3` (18/w700), renamed |
| `bodyRegular` | `bodyLg` | Same: 16/w400 |
| `label` | `bodyLgMedium` | Same: 16/w500 |
| `bodySmall` | `bodyMedium` | Was 16/w500, now 15/w500 |
| `bodyTiny` | `bodySm` | Same: 14/w400 |
| `subtitle` | Use `bodyLg.copyWith(...)` | Removed (was 16/w300) |
| `helper` | `bodySm` | Same: 14/w400 |
| `input` | `bodyLg` | Same: 16/w400 |
| `placeholder` | `bodyLg` | Same: 16/w400 |
| `chip` | `bodySmMedium.copyWith(...)` | Was 12.5/w600, now use 14/w500 base |
| `status` | `bodySmMedium.copyWith(...)` | Was 12.5/w600, now use 14/w500 base |
| `viewToggle` | Removed | Was 13.5/w500 |
| `cardRestaurantName` | `bodyExtraHeavy` | Was 15.5/w700, now 15/w700 (renamed from bodyHeavy) |
| `menuItemName` | `bodyMedium.copyWith(fontWeight: FontWeight.w600)` | Was 15/w600 |
| `price` | `price` | Size changed: was 13.5, now 14 |
| `cardDetail` | `bodySm` | Same: 14/w400 |
| `cardDistance` | `bodySmMedium` | Same: 14/w500 |
| `button` | `button` | Unchanged: 18/w600/white |

### Font Weight Mapping

Design system uses numeric weights (420-750). Flutter only supports 100-900 in increments of 100:

| Design Weight | Flutter Weight | Mapping Rule |
|--------------|----------------|--------------|
| 420-460 | `FontWeight.w400` | Regular |
| 480-540 | `FontWeight.w500` | Medium |
| 560-600 | `FontWeight.w600` | Semibold |
| 620-680 | `FontWeight.w700` | Bold |
| 700-750 | `FontWeight.w800` | Extra-bold (hero token only) |

### Common Patterns

```dart
// Section heading
Text(
  'Share feedback',
  style: AppTypography.h4,  // 20px, w700
)

// Form label
Text(
  'Your name',
  style: AppTypography.bodyLgMedium,  // 16px, w500, textPrimary
)

// Helper text
Text(
  'Enter your full name',
  style: AppTypography.bodySm,  // 14px, w400
)

// Body paragraph
Text(
  'Description text...',
  style: AppTypography.bodyLg,  // 16px, w400, textPrimary
)

// Price
Text(
  '149 DKK',
  style: AppTypography.price,  // 14px, w600, accent
)
```

### Dynamic Font Size Override

`filter_overlay_widget.dart` uses `_adjustedFontSize()` for dynamic sizing. Inline styles there still need `fontSize` override via `.copyWith()`:

```dart
// When dynamic sizing is needed
Text(
  label,
  style: AppTypography.bodySm.copyWith(
    fontSize: _adjustedFontSize(14),  // Scale for responsive layout
  ),
)
```

---

## 5. Input Decorations (AppInputDecorations)

**Unified in commit `9e67b62` (2026-03-10):** All forms now use consistent input styling — `AppTypography.body` for text, `AppColors.bgInput` for fill, `AppRadius.input` for corners, proper border states (error, focusedError, accent focused). The `bgCardSubtle` color alias was removed (was just `bgSurface`).

### Standard Single-Line Input

```dart
TextField(
  decoration: AppInputDecorations.standard(
    hintText: 'Enter your email',
    labelText: 'Email',  // Optional
  ),
)
```

**Generates:**
- Filled with `bgInput` (#f5f5f5)
- Border radius: 12px
- Border: #e8e8e8 (normal), orange (focused), red (error)
- Padding: 16px horizontal, 14px vertical
- Fixed height when wrapped: 50px

### Multiline Input (Textarea)

```dart
TextField(
  maxLines: 6,
  decoration: AppInputDecorations.multiline(
    hintText: 'Type your message...',
  ),
)
```

**Generates:**
- Same styling as standard
- Padding: 12px all around (better for multiline)
- No fixed height (expands with content)

### With Prefix/Suffix Icons

```dart
TextField(
  decoration: AppInputDecorations.standard(
    hintText: 'Search',
    prefixIcon: Icon(Icons.search),
    suffixIcon: Icon(Icons.clear),
  ),
)
```

### Fixed Height Pattern

For pixel-perfect 50px height (form inputs):

```dart
SizedBox(
  height: AppConstants.inputHeight,  // 50px
  child: TextField(
    decoration: AppInputDecorations.standard(...),
  ),
)
```

### Search Bar Component

Search bars are a **distinct component** from form inputs and do NOT use `AppInputDecorations.standard()`.

**Always use the shared widget — never build the raw Container+TextField pattern inline:**

```dart
// lib/widgets/shared/search_bar_widget.dart
SearchBarWidget(
  hintTextKey: 'search_placeholder',   // translation key
  controller: _searchController,        // optional external controller
  onChanged: _onSearchTextChanged,      // called on every keystroke AND clear
  onSubmitted: _executeSearch,          // optional — keyboard submit action
)
```

**Current usages:**
- `lib/pages/search/search_page.dart` — main search bar (with debounced API call)
- `lib/widgets/shared/sort_bottom_sheet.dart` — station list filter (local filtering)

**Widget internals (for reference):**
- Manages its own `FocusNode` (drives the transparent → orange border on focus)
- Creates an internal `TextEditingController` when none is passed in
- Shows a clear button (`Icons.clear`) when the field has text; tapping it calls `onChanged('')`
- Height: `AppConstants.searchBarHeight` (45px), radius: `AppRadius.input` (12px)

**Key differences from form inputs (`AppInputDecorations.standard`):**

| Property | Search Bar (`SearchBarWidget`) | Form Input |
|----------|-------------------------------|------------|
| Height | 45px (`searchBarHeight`) | 50px (`inputHeight`) |
| Background | `bgInput` always, border changes on focus | `bgInput` with visible border always |
| Border (unfocused) | Transparent | `AppColors.border` |
| Border (focused) | `AppColors.accent` (1.5px) | `AppColors.accent` |
| Outline borders | `InputBorder.none` on all states | Standard `OutlineInputBorder` |
| Decoration | `SearchBarWidget` | `AppInputDecorations.standard()` |

**When to use which:**
- **Search bars** (search page, station picker, any future search locations): Use `SearchBarWidget`
- **Form inputs** (feedback, contact, missing place, settings): Use `AppInputDecorations.standard()`

---

## 6. Button Styles (AppButtonStyles)

### Primary Button (Orange CTA)

```dart
ElevatedButton(
  onPressed: _handleSubmit,
  style: AppButtonStyles.primary,
  child: Text('Submit'),
)
```

**Generated style:**
- Background: `accent` (orange)
- Text: White, 16px, w600
- Border radius: 12px (`AppRadius.button`)
- Padding: 24px horizontal, 14px vertical
- No elevation
- Disabled: #bbbbbb background

### Secondary Button (Outlined)

```dart
OutlinedButton(
  onPressed: _handleCancel,
  style: AppButtonStyles.secondary,
  child: Text('Cancel'),
)
```

**Generated style:**
- Background: Transparent
- Text: `textPrimary` (#0f0f0f), 16px, w600
- Border: #e8e8e8
- Border radius: 12px (`AppRadius.button`)
- Same padding as primary

### Full-Width Button Pattern

```dart
SizedBox(
  width: double.infinity,
  height: AppConstants.buttonHeight,  // 50px
  child: ElevatedButton(
    style: AppButtonStyles.primary,
    onPressed: _handleSubmit,
    child: Text('Send message'),
  ),
)
```

### Submit Button (TextButton — Unified Pattern)

All submit/action buttons across settings pages and welcome page use this `TextButton` pattern (not `ElevatedButton`). Unified in commit `604bdb6` to match the filter overlay's apply button.

```dart
SizedBox(
  width: double.infinity,
  child: TextButton(
    onPressed: _handleSubmit,
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(AppColors.accent),
      foregroundColor: WidgetStateProperty.all(AppColors.textWhite),
      padding: WidgetStateProperty.all(
        EdgeInsets.symmetric(vertical: AppSpacing.lg),
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        AppTypography.button.copyWith(fontWeight: FontWeight.w600),
      ),
      minimumSize: WidgetStateProperty.all(Size(double.infinity, 50)),
    ),
    child: Text(td(ref, 'submit_button_key')),
  ),
)
```

**Used in:** `contact_us_form_widget.dart`, `feedback_form_widget.dart`, `missing_location_form_widget.dart`, `welcome_page.dart`, `filter_overlay_widget.dart`

---

## 7. Common UI Patterns

### Form Field Group

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Label with asterisk for required fields
    RichText(
      text: TextSpan(
        text: 'Your name ',
        style: AppTypography.bodyLgMedium,
        children: [
          TextSpan(
            text: '*',
            style: TextStyle(color: AppColors.error),
          ),
        ],
      ),
    ),
    SizedBox(height: AppSpacing.sm),  // 8px

    // Input field with fixed height
    SizedBox(
      height: AppConstants.inputHeight,  // 50px
      child: TextField(
        decoration: AppInputDecorations.standard(
          hintText: 'Enter your name',
        ),
      ),
    ),
  ],
)
```

### Form Field with Helper Text

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Label
    Text('Email or phone', style: AppTypography.bodyLgMedium),
    SizedBox(height: AppSpacing.xs),  // 4px

    // Helper text
    Text(
      'Please provide either or both',
      style: AppTypography.bodySm,
    ),
    SizedBox(height: AppSpacing.sm),  // 8px

    // Input field
    SizedBox(
      height: AppConstants.inputHeight,
      child: TextField(
        decoration: AppInputDecorations.standard(
          hintText: 'email@example.com',
        ),
      ),
    ),
  ],
)
```

### Form Page Pattern (Settings Forms)

**Standard pattern for all settings form pages** (share_feedback, contact_us, missing_place, localization).

This pattern creates visual hierarchy through **weight + color**, not size differences:

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Main page title (if present)
    Text(
      'Main Title',
      style: AppTypography.h4,  // 20px, w700
    ),
    SizedBox(height: AppSpacing.sm),  // 8px

    // Main subtitle
    Text(
      'Description of the page',
      style: AppTypography.bodyLg.copyWith(
        fontWeight: FontWeight.w300,
        color: AppColors.textSecondary,
      ),  // 16px, w300, textSecondary
    ),
    SizedBox(height: 28),  // Tighter first gap (not 32px)

    // Section title (heavier weight)
    Text(
      'Section Title',
      style: AppTypography.bodyLgMedium.copyWith(
        fontWeight: FontWeight.w600,  // Override w500 → w600
      ),
    ),
    SizedBox(height: AppSpacing.sm),  // 8px

    // Section subtitle
    Text(
      'Section description',
      style: AppTypography.bodyLg.copyWith(
        fontWeight: FontWeight.w300,
        color: AppColors.textSecondary,
      ),  // 16px, w300, textSecondary
    ),
    SizedBox(height: AppSpacing.sm),  // 8px

    // Input field with 14px placeholder
    TextField(
      decoration: InputDecoration(
        hintText: 'Placeholder text',
        hintStyle: AppTypography.bodyLg.copyWith(fontSize: 14),
      ),
    ),

    SizedBox(height: AppSpacing.xxl),  // 24px between sections

    // Next section...
  ],
)
```

**Key Rules:**
- Section titles: 16px, **w600**, textPrimary (darker, heavier)
- Subtitles: **16px**, w300, textSecondary (lighter weight, lighter color) - use `AppTypography.bodyLg.copyWith(fontWeight: FontWeight.w300, color: AppColors.textSecondary)`
- Placeholders: **14px** (not default 16px)
- First gap: **28px** (tighter than other sections)
- Section spacing: **24px** (AppSpacing.xxl, not xl)

**Rationale:** Consistent visual hierarchy across all settings forms. Weight (w600 vs w300) and color (textPrimary vs textSecondary) create clear distinction. The old `subtitle` style was removed in the 14-style streamlining (commit `7f0c892`); use `.copyWith()` on `bodyLg` for the same effect.

**Example files:**
- `journey_mate/lib/pages/settings/widgets/feedback_form_widget.dart`
- `journey_mate/lib/pages/settings/widgets/contact_us_form_widget.dart`
- `journey_mate/lib/pages/settings/widgets/missing_location_form_widget.dart`
- `journey_mate/lib/pages/settings/localization_page.dart`

**Git references:** Commits `f20ceaf`, `9db531a` (2026-02-24)

---

### Multi-Paragraph Text

```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'First paragraph text...',
      style: AppTypography.bodyLg,
    ),
    SizedBox(height: AppSpacing.sm),  // 8px between paragraphs
    Text(
      'Second paragraph text...',
      style: AppTypography.bodyLg,
    ),
  ],
)
```

### Category Chip (Selected/Unselected)

```dart
GestureDetector(
  onTap: () => setState(() => _selected = !_selected),
  child: Container(
    padding: EdgeInsets.symmetric(
      horizontal: AppSpacing.md + 2,  // 14px
      vertical: AppSpacing.sm,  // 8px
    ),
    decoration: BoxDecoration(
      color: _selected ? AppColors.accent : AppColors.bgPage,
      borderRadius: BorderRadius.circular(AppRadius.filter),  // 10px
      border: Border.all(
        color: _selected ? AppColors.accent : AppColors.border,
      ),
    ),
    child: Text(
      'Category',
      style: AppTypography.bodySmMedium.copyWith(
        color: _selected ? AppColors.bgPage : AppColors.textSecondary,
      ),
    ),
  ),
)
```

### Checkbox with Text (AppCheckbox)

**Use `AppCheckbox`** (commit `c4066fc`) for consistent checkbox styling across the app. Replaces manual `Checkbox` + `Row` patterns.

**Source:** `journey_mate/lib/widgets/shared/app_checkbox.dart`

```dart
// Standard usage — tapping anywhere on the row toggles
AppCheckbox(
  value: _checked,
  onChanged: (value) => setState(() => _checked = value),
  label: td(ref, 'checkbox_label'),
)
```

**AppCheckbox provides:**
- Custom-drawn checkbox container (18×18px, `AppRadius.checkbox` corners)
- Active: `AppColors.accent` fill + white check icon
- Inactive: `AppColors.border` border
- Full-row tap target (label + checkbox both toggle)
- `AppTypography.body` label with `AppColors.textPrimary`

**For manual cases** (when AppCheckbox doesn't fit), match the same spec:

```dart
Container(
  width: 18,
  height: 18,
  decoration: BoxDecoration(
    color: _checked ? AppColors.accent : Colors.transparent,
    border: _checked ? null : Border.all(color: AppColors.border, width: 1.5),
    borderRadius: BorderRadius.circular(AppRadius.checkbox),  // 4px
  ),
  child: _checked
      ? Icon(Icons.check, size: 10, color: Colors.white)
      : null,
)
```

---

## 8. Page Structure Patterns

### Standard Form Page

```dart
Scaffold(
  backgroundColor: AppColors.bgPage,
  appBar: AppBar(
    backgroundColor: AppColors.bgPage,
    elevation: 0,
    surfaceTintColor: Colors.transparent, // Material 3: prevent orange tint when scrolled
    scrolledUnderElevation: 0, // Material 3: keep elevation at 0 when scrolled
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
      onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text('Page Title', style: AppTypography.h5),
    centerTitle: true,
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.xxl),  // 24px
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form fields...
          SizedBox(height: AppSpacing.huge),  // 40px before button

          // Submit button
          SizedBox(
            width: double.infinity,
            height: AppConstants.buttonHeight,
            child: ElevatedButton(
              style: AppButtonStyles.primary,
              onPressed: _handleSubmit,
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    ),
  ),
)
```

**Note:** As of commit `c97e48d` (2026-02-24), AppBar Material 3 properties (`surfaceTintColor`, `scrolledUnderElevation`) are configured in `journey_mate/lib/theme/app_theme.dart` and automatically applied to all AppBars. Individual pages do not need to specify these properties unless overriding the theme. See ARCHITECTURE.md → Common Pitfall #12 for theme-first approach.

---

## 9. Constants (AppConstants)

### Screen Dimensions (Reference)

```dart
AppConstants.screenWidth   // 390.0 (iPhone 14/15)
AppConstants.screenHeight  // 844.0
```

### Component Heights

```dart
AppConstants.statusBarHeight   // 54.0
AppConstants.tabBarHeight      // 80.0
AppConstants.inputHeight       // 50.0 (form inputs: email, feedback, etc.)
AppConstants.searchBarHeight   // 45.0 (search bars only — compact for header density)
AppConstants.buttonHeight      // 50.0
```

### Card Dimensions

```dart
AppConstants.logoCircleSize  // 50.0
AppConstants.cardPadding     // 14.0
```

### Animation Durations

```dart
AppConstants.animationFast    // Duration(milliseconds: 200)
AppConstants.animationNormal  // Duration(milliseconds: 300)
AppConstants.animationSlow    // Duration(milliseconds: 500)
```

---

## 10. Verify Before Committing

### Anti-Patterns

❌ **Hardcoded colors** → Use `AppColors.*`
```dart
Color(0xFFE8751A)  // Wrong
AppColors.accent   // Correct
```

❌ **Hardcoded spacing** → Use `AppSpacing.*`
```dart
SizedBox(height: 20)      // Wrong
SizedBox(height: AppSpacing.xl)  // Correct
```

❌ **Hardcoded radii** → Use `AppRadius.*`
```dart
BorderRadius.circular(10)  // Wrong for inputs
BorderRadius.circular(AppRadius.input)  // Correct (12px)
```

❌ **Custom input decorations** → Use `AppInputDecorations.*`
```dart
InputDecoration(filled: true, fillColor: Color(0xFFF5F5F5), ...)  // Wrong
AppInputDecorations.standard(hintText: '...')  // Correct
```

❌ **Inline text styles** → Use `AppTypography.*`
```dart
TextStyle(fontSize: 14, fontWeight: FontWeight.w500)  // Wrong
AppTypography.bodyLgMedium  // Correct
```

### Quick Checks

| Area | Correct Token | Value | Notes |
|------|---------------|-------|-------|
| Label to input gap | `AppSpacing.sm` | 8px | |
| Between form fields | `AppSpacing.xl` | 20px | General forms |
| Form page sections | `AppSpacing.xxl` | 24px | Settings forms only |
| First gap (forms) | Custom `28` | 28px | After main subtitle |
| **Page horizontal padding** | **`AppSpacing.xl`** | **20px** | **Standard for ALL pages** |
| Input radius | `AppRadius.input` | 12px | |
| Button radius | `AppRadius.button` | 12px | Was 14px, aligned to 12px scale |
| Card radius | `AppRadius.card` | 16px | |
| Bottom sheet corners | `AppRadius.bottomSheet` | 20px | Was 22px, aligned to 20px scale |
| Pill buttons | `AppRadius.pill` | 20px | Sort, open-only floating buttons |
| Orange color | CTAs only | Never match status |
| Green color | Match confirmation only | Never CTAs |

---

## 11. Bottom Sheet Design Guide

**Source file:** `journey_mate/lib/widgets/shared/bottom_sheet_header.dart`
**Last verified:** 2026-03-12

Bottom sheets are the primary overlay pattern in JourneyMate. This guide defines the shared foundation and the named variants.

### 11.1 Foundation (Every Bottom Sheet)

These rules apply to **every** bottom sheet in the app, no exceptions.

#### Drag Handle

Always present. Signals drag-to-dismiss.

| Property | Value | Token |
|----------|-------|-------|
| Width | 40px | Hardcoded |
| Height | 4px | Hardcoded |
| Color (light bg) | `AppColors.border` | — |
| Color (dark bg) | `Colors.white` @ 40% alpha | For full-screen galleries |
| Border radius | 2px | `AppRadius.handle` |
| Position | Top-center, 8px from top | `BottomSheetHeader.swipeBarTopPadding` |

#### Container Decoration

```dart
Container(
  decoration: BottomSheetHeader.sheetDecoration(), // bgCard + top corners
  // or with custom bg:
  decoration: BottomSheetHeader.sheetDecoration(color: AppColors.bgPage),
)
```

| Property | Value | Token |
|----------|-------|-------|
| Background | `AppColors.bgCard` (default) | Overridable via `color` param |
| Top corners | 20px | `AppRadius.bottomSheet` |

#### showModalBottomSheet Call

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,      // Always
  backgroundColor: Colors.transparent, // Always (shows rounded corners)
  builder: (context) => MySheet(...),
);
```

### 11.2 Close / Action Buttons (Optional)

When present, close and action buttons must use identical styling. Position and presence vary per sheet.

#### Button Style

| Property | Value | Token |
|----------|-------|-------|
| Container size | 40x40px | `BottomSheetHeader.actionButtonSize` |
| Background | `AppColors.bgSurface` | — |
| Border radius | 20px (circle) | `BottomSheetHeader.actionButtonBorderRadius` |
| Icon size | 24px | `BottomSheetHeader.actionIconSize` |
| Icon color | `AppColors.textPrimary` | — |
| Edge offset | 12px from top and side | `BottomSheetHeader.actionButtonPosition` |

#### Via BottomSheetHeader

```dart
// Close button top-right
BottomSheetHeader(
  rightAction: BottomSheetAction(
    icon: Icons.close,
    onPressed: () => Navigator.of(context).pop(),
  ),
)

// Close left + menu right (with image)
BottomSheetHeader(
  leftAction: BottomSheetAction(icon: Icons.close, onPressed: onClose),
  rightAction: BottomSheetAction(icon: Icons.more_horiz, onPressed: onMenu),
  image: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
)
```

#### Manual (When Not Using BottomSheetHeader)

For sheets that build custom headers (e.g. MapSelectionSheet), match the same icon/size/color:

```dart
GestureDetector(
  onTap: () => Navigator.of(context).pop(),
  child: Icon(Icons.close, size: 24, color: AppColors.textPrimary),
)
```

### 11.3 Title Typography

| Sheet complexity | Style | Example |
|------------------|-------|---------|
| Full-featured (scrollable, multi-section) | `AppTypography.h4` | Sort, Description, Package, Item |
| Lightweight (few options, compact) | `AppTypography.h6` | Map selection |
| Form-based | `AppTypography.h3` | Erroneous info report |

Title is always left-aligned with `AppSpacing.lg` (16px) horizontal padding.

### 11.4 Named Variants

#### Content Sheet (with Image Header)

Used for: **ItemBottomSheet**, **PackageBottomSheet**

- Image header: 200px tall, fills width, clipped to top corners
- Close button: **left** (user navigated into detail)
- Menu button: **right** (three-dot `Icons.more_horiz`)
- Height: 90% of screen (`0.90`)
- Nested navigation supported (Package → Item detail)

```dart
BottomSheetHeader(
  leftAction: BottomSheetAction(icon: Icons.close, onPressed: onClose),
  rightAction: BottomSheetAction(icon: Icons.more_horiz, onPressed: onMenu),
  image: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
)
```

#### Text Sheet

Used for: **DescriptionSheet**

- No image
- Close button: **right**
- Self-sizing: min 40% / max 80% of screen height
- Scrollable when content exceeds max height
- Auto-linkified text (URLs, emails, phone numbers)

```dart
BottomSheetHeader(
  rightAction: BottomSheetAction(
    icon: Icons.close,
    onPressed: () => Navigator.of(context).pop(),
  ),
)
```

#### Selection Sheet

Used for: **SortBottomSheet**, **MapSelectionSheet**

- No image
- Close button: varies (Sort has none; Map has right)
- Custom header (does not use BottomSheetHeader widget)
- Drag handle built manually to same spec
- Fixed height based on content

#### Multi-Column Sheet

Used for: **FilterOverlayWidget**

- No image, no close button
- Custom header with drag handle
- DraggableScrollableSheet: `initial: 0.84, min: 0.4, max: 0.95`
- 3-column hierarchical layout with tabs

#### Form Sheet

Used for: **ErroneousInfoFormWidget**

- No image
- Close button: **left** (via BottomSheetHeader)
- Max height: 80% of screen
- Scrollable form content
- Three-state UI: default / success / error

#### Gallery Sheet (Full-Screen)

Used for: **ImageGalleryWidget**

- Full-screen black background (no rounded corners)
- Drag handle: **white @ 40% alpha** (visible on dark bg)
- Close button: **top-left**, semi-transparent `bgCard` @ 80% alpha background
- Positioned 60px from top (avoids iPhone gesture area)

### 11.5 Complete Inventory

| Sheet | File | Header | Close Btn | Title | Image |
|-------|------|--------|-----------|-------|-------|
| ItemBottomSheet | `item_bottom_sheet.dart` | BottomSheetHeader | Left | h4 | Yes (200px) |
| PackageBottomSheet | `package_bottom_sheet.dart` | BottomSheetHeader | Left | h4 | Yes (200px) |
| DescriptionSheet | `description_sheet.dart` | BottomSheetHeader | Right | h4 | No |
| ErroneousInfoFormWidget | `erroneous_info_form_widget.dart` | BottomSheetHeader | Left | h3 | No |
| SortBottomSheet | `sort_bottom_sheet.dart` | Custom | None | h4 | No |
| FilterOverlayWidget | `filter_overlay_widget.dart` | Custom | None | Custom | No |
| MapSelectionSheet | `map_selection_sheet.dart` | Custom | Right | h6 | No |
| ImageGalleryWidget | `image_gallery_widget.dart` | Custom (dark) | Left | None | Full-screen |

### 11.6 Decision Checklist (New Bottom Sheets)

When creating a new bottom sheet:

1. **Drag handle:** Always include (40px, `AppColors.border`, `AppRadius.handle`)
2. **Container:** Use `BottomSheetHeader.sheetDecoration()`
3. **showModalBottomSheet:** Always `isScrollControlled: true`, `backgroundColor: Colors.transparent`
4. **Close button needed?** If yes, use `BottomSheetAction` with `Icons.close`, 24px, `AppColors.textPrimary`
5. **Close button position:** Left = user navigated into detail; Right = user opened an overlay
6. **Image header?** If yes, use `BottomSheetHeader(image: ...)` with 200px height
7. **Title style:** h4 for standard sheets, h6 for lightweight, h3 for forms
8. **Use BottomSheetHeader widget?** Preferred unless you need a custom layout (like SortBottomSheet's submenu navigation)

---

**Status:** Complete — All design tokens implemented | **Source of truth:** `journey_mate/lib/theme/` | **Last verified:** 2026-03-12
