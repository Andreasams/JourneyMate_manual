# JourneyMate Flutter Design System

**Version:** 1.0 - February 2026
**Source:** `C:\Users\Rikke\Documents\JourneyMate-v2\journeymate-design-system.md`
**Implementation:** `shared/app_theme.dart`

**Purpose:** Complete Flutter implementation reference for the JourneyMate design system. Every design decision from the JSX design system has been translated to Flutter/Dart patterns.

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
| `AppSpacing.xs` | 4px | Minimal spacing |
| `AppSpacing.sm` | 8px | Label to input, between paragraphs, heading to description |
| `AppSpacing.md` | 12px | Between chips, moderate gaps |
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

### Headings

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.pageTitle` | 24px | w800 | Page titles (h2) |
| `AppTypography.restaurantName` | 24px | w800 | Business names (h1) |
| `AppTypography.sectionHeading` | 18px | w700 | Section headings (h3) |
| `AppTypography.categoryHeading` | 16px | w700 | Category headings (h4) |

### Body Text

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.bodyRegular` | 14px | w400 | Body paragraphs, descriptions |
| `AppTypography.bodyMedium` | 14px | w500 | Emphasized body text |
| `AppTypography.bodySmall` | 13px | w500 | Smaller body text |
| `AppTypography.bodyTiny` | 12px | w400 | Tiny text, footnotes |

### UI Elements

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.label` | 14px | w500 | Form field labels |
| `AppTypography.helper` | 12px | w400 | Helper text below fields |
| `AppTypography.input` | 14px | w400 | Text inside input fields |
| `AppTypography.placeholder` | 14px | w400 | Input placeholder text |
| `AppTypography.button` | 16px | w600 | Button text |
| `AppTypography.chip` | 12.5px | w600 | Chip/tag text |
| `AppTypography.status` | 12.5px | w600 | Status indicators |

### Card Elements

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `AppTypography.cardRestaurantName` | 15.5px | w700 | Restaurant name in cards |
| `AppTypography.menuItemName` | 15px | w600 | Menu item names |
| `AppTypography.price` | 13.5px | w600 | Prices (orange color) |

### Font Weight Mapping

Design system uses numeric weights (420-750). Flutter only supports 100-900 in increments of 100:

| Design Weight | Flutter Weight | Mapping Rule |
|--------------|----------------|--------------|
| 420-460 | `FontWeight.w400` | Regular |
| 480-540 | `FontWeight.w500` | Medium |
| 560-600 | `FontWeight.w600` | Semibold |
| 620-680 | `FontWeight.w700` | Bold |
| 700-750 | `FontWeight.w800` | Extra-bold |

### Common Patterns

```dart
// Page heading
Text(
  'Share feedback',
  style: AppTypography.sectionHeading,  // 18px, w700
)

// Form label
Text(
  'Your name',
  style: AppTypography.label,  // 14px, w500
)

// Helper text
Text(
  'Enter your full name',
  style: AppTypography.helper,  // 12px, w400
)

// Body paragraph
Text(
  'Description text...',
  style: AppTypography.bodyRegular,  // 14px, w400
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

For pixel-perfect 50px height:

```dart
SizedBox(
  height: AppConstants.inputHeight,  // 50px
  child: TextField(
    decoration: AppInputDecorations.standard(...),
  ),
)
```

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

---

## 9. Constants (AppConstants)

### Screen Dimensions (Reference)

```dart
AppConstants.screenWidth   // 390.0 (iPhone 14/15)
AppConstants.screenHeight  // 844.0
```

### Component Heights

```dart
AppConstants.statusBarHeight  // 54.0
AppConstants.tabBarHeight     // 80.0
AppConstants.inputHeight      // 50.0
AppConstants.buttonHeight     // 50.0
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

## 10. Decision Checklist

Before writing any UI code, ask:

### Colors
- [ ] Am I using `AppColors.accent` for interactive elements?
- [ ] Am I using `AppColors.green` ONLY for match confirmation?
- [ ] Am I using the correct text color for hierarchy?

### Spacing
- [ ] Label to input: 8px (`AppSpacing.sm`)
- [ ] Between fields: 20px (`AppSpacing.xl`)
- [ ] Before button: 24px (`AppSpacing.xxl`)
- [ ] Page padding: 24px (`AppSpacing.xxl`)

### Border Radius
- [ ] Input fields: 12px (`AppRadius.input`)
- [ ] Buttons: 14px (`AppRadius.button`)
- [ ] Cards: 16px (`AppRadius.card`)

### Typography
- [ ] Labels: `AppTypography.label` (14px, w500)
- [ ] Helper text: `AppTypography.helper` (12px, w400)
- [ ] Body: `AppTypography.bodyRegular` (14px, w400)
- [ ] Headings: Appropriate heading style

### Input Fields
- [ ] Using `AppInputDecorations.standard()` or `.multiline()`
- [ ] Wrapped in `SizedBox(height: 50)` for fixed height
- [ ] Correct padding (16px horizontal, 14px vertical)

### Buttons
- [ ] Using `AppButtonStyles.primary` or `.secondary`
- [ ] Full-width pattern: `SizedBox(width: double.infinity, height: 50)`
- [ ] Correct border radius: 14px

---

## 11. Anti-Patterns (Don't Do This)

❌ **Hardcoding colors:**
```dart
Color(0xFFE8751A)  // Wrong
AppColors.accent   // Correct
```

❌ **Hardcoding spacing:**
```dart
SizedBox(height: 20)      // Wrong
SizedBox(height: AppSpacing.xl)  // Correct
```

❌ **Wrong border radius:**
```dart
BorderRadius.circular(10)  // Wrong for inputs
BorderRadius.circular(AppRadius.input)  // Correct (12px)
```

❌ **Creating custom input decoration each time:**
```dart
InputDecoration(
  filled: true,
  fillColor: Color(0xFFF5F5F5),  // Wrong - duplicating logic
  // ...
)

// Correct - use predefined
AppInputDecorations.standard(hintText: '...')
```

❌ **Inconsistent text styles:**
```dart
TextStyle(fontSize: 14, fontWeight: FontWeight.w500)  // Wrong
AppTypography.label  // Correct
```

---

## 12. Migration Path

When converting JSX to Flutter:

1. **Colors:** Replace all hex codes with `AppColors.*`
2. **Spacing:** Replace all hardcoded numbers with `AppSpacing.*`
3. **Radii:** Use `AppRadius.*` for all border radius values
4. **Typography:** Use `AppTypography.*` for all text
5. **Inputs:** Use `AppInputDecorations.*` for all text fields
6. **Buttons:** Use `AppButtonStyles.*` for all buttons

---

**Last Updated:** 2026-02-19
**Status:** Complete - All design tokens implemented
**Next:** Update existing form pages to use new system
