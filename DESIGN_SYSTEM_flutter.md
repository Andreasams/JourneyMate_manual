# JourneyMate Flutter Design System

**Version:** 1.1 - March 2026
**Last Updated:** March 2026
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
Text('Hello', style: AppTypography.bodyRegular)

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
| `AppSpacing.xl` | 20px | Between form fields |
| `AppSpacing.xxl` | 24px | Page padding, before submit button |
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

// Page padding
padding: const EdgeInsets.all(AppSpacing.xxl)  // 24px

// Heading to description
const SizedBox(height: AppSpacing.sm)  // 8px
```

---

## 3. Border Radii (AppRadius)

| Constant | Value | Usage |
|----------|-------|-------|
| `AppRadius.chip` | 8px | Small chips, tags |
| `AppRadius.checkbox` | 5px | Filter checkboxes (columns 2 & 3) |
| `AppRadius.facility` | 9px | Facility/payment badges |
| `AppRadius.filter` | 10px | Filter buttons, gallery inner corners |
| `AppRadius.input` | 12px | **Input fields** (most common) |
| `AppRadius.logoSmall` | 13px | Small logo circles (50×50px) |
| `AppRadius.button` | 14px | **Primary buttons** |
| `AppRadius.card` | 16px | Cards, containers |
| `AppRadius.logoLarge` | 18px | Profile page logos |
| `AppRadius.bottomSheet` | 22px | Bottom sheets (top corners only) |

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
      borderRadius: BorderRadius.circular(AppRadius.button),  // 14px
    ),
  ),
)

// Card
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.card),  // 16px
  ),
)
```

---

## 4. Typography (AppTypography)

### Font Weight Mapping ⚠️ IMPORTANT

Design system uses numeric weights (420-750). Flutter only supports 100-900 in increments of 100:

| Design Weight | Flutter Weight | Mapping Rule |
|--------------|----------------|--------------|
| 420-460 | `FontWeight.w400` | Regular |
| 480-540 | `FontWeight.w500` | Medium |
| 560-600 | `FontWeight.w600` | Semibold |
| 620-680 | `FontWeight.w700` | Bold |
| 700-750 | `FontWeight.w800` | Extra-bold |

**Rule:** Always round design weights to the nearest Flutter weight constant.

---

### Headings

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.pageTitle` | 26px | w700 | Page titles (h2) |
| `AppTypography.restaurantName` | 26px | w800 | Business names (h1) |
| `AppTypography.sectionHeading` | 20px | w700 | Section headings (h3) |
| `AppTypography.categoryHeading` | 18px | w700 | Category headings (h4) |

### Body Text

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.bodyRegular` | 16px | w400 | Body paragraphs, descriptions |
| `AppTypography.bodyMedium` | 16px | w500 | Emphasized body text |
| `AppTypography.bodySmall` | 15px | w500 | Smaller body text |
| `AppTypography.bodyTiny` | 14px | w400 | Tiny text, footnotes |

### UI Elements

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.label` | 16px | w500 | Form field labels |
| `AppTypography.helper` | 14px | w400 | Helper text below fields |
| `AppTypography.input` | 16px | w400 | Text inside input fields |
| `AppTypography.placeholder` | 16px | w400 | Input placeholder text |
| `AppTypography.button` | 18px | w600 | Button text |
| `AppTypography.chip` | 12.5px | w600 | Chip/tag text |
| `AppTypography.status` | 12.5px | w600 | Status indicators |
| `AppTypography.filterTab` | 16px | w600 | Filter panel tabs |
| `AppTypography.viewToggle` | 13.5px | w500 | List/Map toggle buttons |

### Card Elements

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.cardRestaurantName` | 15.5px | w700 | Restaurant name in cards |
| `AppTypography.menuItemName` | 15px | w600 | Menu item names |
| `AppTypography.price` | 13.5px | w600 | Prices (orange color) |
| `AppTypography.cardDetail` | 14px | w400 | Status, cuisine, price in cards |
| `AppTypography.cardDistance` | 14px | w500 | Distance label (right-aligned) |

### Common Patterns

```dart
// Page heading
Text(
  'Share feedback',
  style: AppTypography.sectionHeading,  // 20px, w700
)

// Form label
Text(
  'Your name',
  style: AppTypography.label,  // 16px, w500, textPrimary
)

// Helper text
Text(
  'Enter your full name',
  style: AppTypography.helper,  // 14px, w400
)

// Body paragraph
Text(
  'Description text...',
  style: AppTypography.bodyRegular,  // 16px, w400, textSecondary
)
```

---

## 5. Input Decorations (AppInputDecorations)

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

Search bars are a **distinct component** from form inputs and do NOT use `AppInputDecorations.standard()`. Use this pattern whenever building a search bar:

```dart
Container(
  height: AppConstants.searchBarHeight,  // 45px (compact)
  decoration: BoxDecoration(
    color: AppColors.bgInput,
    borderRadius: BorderRadius.circular(AppRadius.input),  // 12px
    border: Border.all(
      color: hasFocus ? AppColors.accent : Colors.transparent,
      width: 1.5,
    ),
  ),
  child: TextField(
    style: AppTypography.input,
    decoration: InputDecoration(
      hintText: 'Search...',
      hintStyle: AppTypography.placeholder,
      filled: false,
      prefixIcon: Icon(Icons.search, size: 17, color: AppColors.textMuted),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,   // 12px
        vertical: AppSpacing.md,     // 12px
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
    ),
  ),
)
```

**Key differences from form inputs (`AppInputDecorations.standard`):**

| Property | Search Bar | Form Input |
|----------|-----------|------------|
| Height | 45px (`searchBarHeight`) | 50px (`inputHeight`) |
| Background | `bgInput` always, border changes on focus | `bgInput` with visible border always |
| Border (unfocused) | Transparent | `AppColors.border` |
| Border (focused) | `AppColors.accent` | `AppColors.accent` |
| Outline borders | `InputBorder.none` on all states | Standard `OutlineInputBorder` |
| Decoration | Custom (as above) | `AppInputDecorations.standard()` |

**When to use which:**
- **Search bars** (search page, future search locations): Use the pattern above
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
- Border radius: 14px
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
- Border radius: 14px
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
        style: AppTypography.label,
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
    Text('Email or phone', style: AppTypography.label),
    SizedBox(height: AppSpacing.xs),  // 4px

    // Helper text
    Text(
      'Please provide either or both',
      style: AppTypography.helper,
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
      style: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    ),
    SizedBox(height: AppSpacing.sm),  // 8px

    // Main subtitle
    Text(
      'Description of the page',
      style: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: AppColors.textSecondary,
      ),
    ),
    SizedBox(height: 28),  // Tighter first gap (not 32px)

    // Section title (heavier weight)
    Text(
      'Section Title',
      style: AppTypography.label.copyWith(
        fontWeight: FontWeight.w600,  // Override w500 → w600
      ),
    ),
    SizedBox(height: AppSpacing.sm),  // 8px

    // Section subtitle
    Text(
      'Section description',
      style: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: AppColors.textSecondary,
      ),
    ),
    SizedBox(height: AppSpacing.sm),  // 8px

    // Input field with 14px placeholder
    TextField(
      decoration: InputDecoration(
        hintText: 'Placeholder text',
        hintStyle: AppTypography.placeholder.copyWith(fontSize: 14),
      ),
    ),

    SizedBox(height: AppSpacing.xxl),  // 24px between sections

    // Next section...
  ],
)
```

**Key Rules:**
- Section titles: 16px, **w600**, textPrimary (darker, heavier)
- Subtitles: **14px**, w300, textSecondary (lighter weight, lighter color)
- Placeholders: **14px** (not default 16px)
- First gap: **28px** (tighter than other sections)
- Section spacing: **24px** (AppSpacing.xxl, not xl)

**Rationale:** Consistent visual hierarchy across all settings forms. Weight (w600 vs w300) and color (textPrimary vs textSecondary) create clear distinction without size differences. Placeholders match subtitle size for visual consistency.

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
      style: AppTypography.bodyRegular,
    ),
    SizedBox(height: AppSpacing.sm),  // 8px between paragraphs
    Text(
      'Second paragraph text...',
      style: AppTypography.bodyRegular,
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
      color: _selected ? AppColors.accent : Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.filter),  // 10px
      border: Border.all(
        color: _selected ? AppColors.accent : AppColors.border,
      ),
    ),
    child: Text(
      'Category',
      style: AppTypography.chip.copyWith(
        color: _selected ? Colors.white : AppColors.textSecondary,
      ),
    ),
  ),
)
```

### Checkbox with Text

```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Checkbox(
      value: _checked,
      onChanged: (value) => setState(() => _checked = value ?? false),
      activeColor: AppColors.accent,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
    ),
    SizedBox(width: AppSpacing.md),  // 12px
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Label', style: AppTypography.label),
          SizedBox(height: AppSpacing.xs),  // 4px
          Text('Description', style: AppTypography.helper),
        ],
      ),
    ),
  ],
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
    title: Text('Page Title', style: AppTypography.categoryHeading),
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
AppTypography.label  // Correct
```

### Quick Checks

| Area | Correct Token | Value | Notes |
|------|---------------|-------|-------|
| Label to input gap | `AppSpacing.sm` | 8px | |
| Between form fields | `AppSpacing.xl` | 20px | General forms |
| Form page sections | `AppSpacing.xxl` | 24px | Settings forms only |
| First gap (forms) | Custom `28` | 28px | After main subtitle |
| Page padding | `AppSpacing.xxl` | 24px | |
| Input radius | `AppRadius.input` | 12px | |
| Button radius | `AppRadius.button` | 14px | |
| Card radius | `AppRadius.card` | 16px | |
| Orange color | CTAs only | Never match status |
| Green color | Match confirmation only | Never CTAs |

---

**Status:** Complete — All design tokens implemented | **Source of truth:** `journey_mate/lib/theme/` | **Last verified:** 2026-03-03
