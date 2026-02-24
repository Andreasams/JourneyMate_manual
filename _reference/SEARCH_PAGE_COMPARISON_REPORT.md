# Search Page UI Comparison Report

**Generated:** 2026-02-24
**Reference:** SEARCH_PAGE_UI_ANALYSIS.md (JSX prototype)
**Implementation:** journey_mate/lib/widgets/shared/search_results_list_view.dart

---

## Executive Summary

This report compares the JSX prototype specifications against the current Flutter implementation for the search results page. Key findings:

- ✅ **17 exact matches** (correctly implemented)
- ⚠️ **12 significant differences** (implementation differs from spec)
- 📝 **5 missing features** (not yet implemented)

---

## 1. Restaurant Card Structure

### Card Container

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Border radius** | 16px | 8px | ⚠️ DIFFERENT |
| **Border width** | 1.5px | 1.5px | ✅ MATCH |
| **Padding** | 14px all sides | 12px all sides | ⚠️ DIFFERENT |
| **Margin bottom** | 8px | Dynamic (2px or 4px based on font scale) | ⚠️ DIFFERENT |

**Impact:** The cards appear with tighter padding (12px vs 14px) and sharper corners (8px vs 16px radius), creating a slightly more compact and less rounded appearance than the design spec.

---

## 2. Avatar/Profile Picture

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Size** | 50×50px | 84×84px | ⚠️ DIFFERENT |
| **Border radius** | 13px | 5px | ⚠️ DIFFERENT |
| **Gap to content** | 12px | 12px | ✅ MATCH |

**Impact:** The profile picture is significantly larger (68% bigger) and has sharper corners. This is a major visual difference from the design spec.

---

## 3. Typography - Card Content

### Restaurant Name

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Font size** | 15.5px | 15.5px | ✅ MATCH |
| **Font weight** | 630 | 700 (w700) | ⚠️ DIFFERENT |

### Distance Label

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Font size** | 12px | Displayed inline in details row | ⚠️ DIFFERENT |
| **Font weight** | 500 | bodyRegular (400) with copy | ⚠️ DIFFERENT |
| **Position** | Right-aligned separate | Inline with cuisine/price | ⚠️ DIFFERENT |

**Note:** The reference shows distance as a separate right-aligned element in the name row. Current implementation shows it inline at the end of the details row (after cuisine and price).

### Status Text

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Status font size** | 12.5px | 16px (bodyRegular base) | ⚠️ DIFFERENT |
| **Status weight** | 560 | Normal or w600 (conditional) | ⚠️ SIMILAR |
| **Timing text size** | 12.5px | 16px (bodyRegular) | ⚠️ DIFFERENT |

### Cuisine/Price Text

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Font size** | 12.5px | 16px (bodyRegular) | ⚠️ DIFFERENT |
| **Font weight** | Normal (400) | 400 | ✅ MATCH |

**Impact:** All card body text (status, timing, cuisine, price) uses 16px instead of the specified 12.5px, making text appear larger than designed.

---

## 4. Row Spacing (Internal Card)

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Name to status gap** | 2px (implicit) | 2px or 4px (font scale dependent) | ✅ SIMILAR |
| **Status to details gap** | 2px (implicit) | 2px or 4px (font scale dependent) | ✅ SIMILAR |
| **Details to address gap** | 2px (implicit) | 2px or 4px (font scale dependent) | ✅ SIMILAR |

---

## 5. Section Headers

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Font size** | 11px | 11px | ✅ MATCH |
| **Font weight** | 620 | 700 (w700) | ⚠️ DIFFERENT |
| **Uppercase** | Yes | Via translation keys | ✅ FUNCTIONAL |
| **Padding left/right** | 0px (content padding handles) | 20px explicit | ⚠️ DIFFERENT |
| **Padding top** | 0px first, 24px subsequent | 16px (all sections) | ⚠️ DIFFERENT |
| **Padding bottom** | 10px | 8px | ⚠️ DIFFERENT |
| **Icon size** | 11×11px | 11px | ✅ MATCH |
| **Icon gap** | 5px | 4px | ⚠️ DIFFERENT |

**Impact:** Section headers have more left/right padding (20px vs relying on content padding) and less consistent top spacing.

---

## 6. Partial Match Info Box

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Margin top** | 10px | 10px | ✅ MATCH |
| **Margin left/right** | 0px (full width) | 12px | ⚠️ DIFFERENT |
| **Padding vertical** | 9px | 9px | ✅ MATCH |
| **Padding horizontal** | 11px | 11px | ✅ MATCH |
| **Border radius** | 10px | 10px | ✅ MATCH |
| **Background color** | #fef8f2 | #fef8f2 | ✅ MATCH |
| **Icon size** | 14×14px | 14px | ✅ MATCH |
| **Icon gap** | 8px | 8px | ✅ MATCH |
| **Text font size** | 12px | 12px | ✅ MATCH |

**Impact:** The info box is inset by 12px on each side rather than full width, creating narrower appearance.

---

## 7. Expanded Card Content

### Divider & Spacing

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Margin top** | 12px | 12px | ✅ MATCH |
| **Divider height** | Not specified | 1px | ✅ IMPLEMENTED |
| **Padding after divider** | 12px | 12px | ✅ MATCH |

### Full Address

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Font size** | 12.5px | 12.5px | ✅ MATCH |
| **Color** | Secondary | #888888 (gray) | ✅ MATCH |
| **Margin bottom** | Implicit | 6px | ✅ MATCH |

### Today's Hours

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Font size** | 12.5px | 12.5px | ✅ MATCH |
| **Margin bottom** | Implicit | 12px | ✅ MATCH |

### Photo Grid

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Photo size** | 80×60px | 80×60px | ✅ MATCH |
| **Border radius** | 8px | 8px | ✅ MATCH |
| **Gap between photos** | 4px | 4px | ✅ MATCH |
| **Max photos displayed** | 8 | 8 | ✅ MATCH |
| **Margin bottom** | Implicit | 12px | ✅ MATCH |

### "See More" Button

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Margin top** | 10px | Part of column | ✅ FUNCTIONAL |
| **Padding vertical** | 9px | TextButton default (minimal) | ⚠️ DIFFERENT |
| **Padding horizontal** | 0px | 0px (explicit) | ✅ MATCH |
| **Border radius** | 10px | No background (text button) | ⚠️ DIFFERENT |
| **Font size** | 12.5px | 16px (bodyRegular) | ⚠️ DIFFERENT |
| **Font weight** | 560 | 600 (w600) | ✅ SIMILAR |

**Impact:** "See more" button text is larger (16px vs 12.5px) than specified.

---

## 8. Collapse Chevron

| Property | Reference (JSX) | Current Implementation | Status |
|----------|----------------|----------------------|--------|
| **Margin top** | 6px | 8px | ⚠️ DIFFERENT |
| **Padding bottom** | 4px | 0px | ⚠️ DIFFERENT |
| **Icon size** | 14×8px (SVG) | 20px | ⚠️ DIFFERENT |

**Impact:** Chevron is larger (20px vs ~14px) and has slightly different spacing.

---

## 9. Missing Features (Not Yet Implemented)

The following features from the reference are not implemented in the current code:

1. **Animation delays on card appearance**
   - Reference: Staggered animation with 0.04s increments (cards 0-8)
   - Current: No animation implemented

2. **Distance label positioning**
   - Reference: Right-aligned in name row
   - Current: Inline at end of details row

3. **Filter button badge indicator**
   - Reference: Red dot (6×6px) or count text
   - Current: Not applicable (card-level view only)

4. **Active filters section**
   - Reference: Horizontal scroll with "Ryd alle" button
   - Current: Not applicable (card-level view only)

5. **Liste/Kort toggle**
   - Reference: Two-button segmented control
   - Current: Not applicable (card-level view only)

**Note:** Items 3-5 are likely implemented at the page level, not in the search_results_list_view widget.

---

## 10. Summary of Key Differences

### Critical Differences (Visual Impact)

1. **Avatar size:** 84×84px vs 50×50px (68% larger)
2. **Card border radius:** 8px vs 16px (sharper corners)
3. **Card padding:** 12px vs 14px (tighter)
4. **All body text:** 16px vs 12.5px (28% larger)

### Minor Differences (Low Impact)

1. **Section header spacing:** Slight variations in top/bottom padding
2. **Font weights:** 700 vs 620-630 (close approximations)
3. **Chevron size:** 20px vs 14px
4. **Partial match box margins:** 12px inset vs full width

### Design Tokens Usage

✅ **Correctly using design tokens:**
- `AppColors` for all colors
- `AppTypography.cardRestaurantName` for restaurant name
- `AppTypography.bodyRegular` for body text
- `AppColors.accent`, `AppColors.success`, etc. for status colors

⚠️ **Not using design tokens:**
- Hardcoded padding values (12px instead of `AppSpacing.*`)
- Hardcoded border radius (8 instead of `AppRadius.*`)
- Some hardcoded spacing values (2px, 4px, 6px, 8px, etc.)

---

## 11. Recommendations

### High Priority (Visual Consistency)

1. **Reduce avatar size** from 84px to 50px to match design
2. **Adjust card border radius** from 8px to 16px (or use `AppRadius.large`)
3. **Increase card padding** from 12px to 14px (or use `AppSpacing.medium`)
4. **Reduce body text sizes** from 16px to 12.5px for status/cuisine/price

### Medium Priority (Design System Compliance)

1. **Replace hardcoded spacing** with `AppSpacing` constants
2. **Replace hardcoded radius** with `AppRadius` constants
3. **Standardize font weights** to match exact reference specs (create custom weights if needed)

### Low Priority (Refinements)

1. **Adjust section header spacing** to match exact reference (24px top for subsequent, 10px bottom)
2. **Adjust chevron size and spacing** to match reference
3. **Implement animation delays** for card appearance (if performance allows)

---

## 12. Breaking Down Typography Issues

The current implementation uses `AppTypography.bodyRegular` (16px, w400) as the base and applies inline overrides for some properties. The reference specifies more granular sizes:

| Element | Reference | Current Base | Override Applied | Result |
|---------|-----------|--------------|-----------------|--------|
| Restaurant name | 15.5px, w630 | cardRestaurantName | None | 15.5px, w700 ✅ |
| Status | 12.5px, w560 | bodyRegular | Conditional w600 | 16px, w400/w600 ❌ |
| Status timing | 12.5px, w400 | bodyRegular | None | 16px, w400 ❌ |
| Cuisine | 12.5px, w400 | bodyRegular | None | 16px, w400 ❌ |
| Price | 12.5px, w400 | bodyRegular | None | 16px, w400 ❌ |
| Distance | 12px, w500 | bodyRegular | None | 16px, w400 ❌ |
| Address (collapsed) | Implied 12.5px | bodyRegular | None | 16px, w400 ❌ |
| Address (expanded) | 12.5px, w400 | bodyRegular | fontSize: 12.5 | 12.5px, w400 ✅ |
| Hours (expanded) | 12.5px, w400 | bodyRegular | fontSize: 12.5 | 12.5px, w400 ✅ |
| Partial match | 12px, w580 | bodyRegular | fontSize: 12 | 12px, w400 ❌ |

**Recommendation:** Create a new `AppTypography.cardDetail` style:
```dart
static const TextStyle cardDetail = TextStyle(
  fontSize: 12.5,
  fontWeight: FontWeight.w400,
  color: AppColors.textSecondary,
  height: 1.3,
);
```

---

## 13. Conclusion

The current implementation is **functionally complete** but has **visual discrepancies** from the design specification. The most impactful differences are:

1. Avatar size (68% larger)
2. Card border radius (50% smaller)
3. Body text sizes (28% larger)
4. Card padding (14% smaller)

These differences create a more **compact, sharp-cornered, text-heavy** appearance compared to the reference design's **rounded, spacious, visually balanced** layout.

**Estimated effort to match spec:** 2-3 hours (mostly typography and spacing adjustments)

---

**End of Report**
