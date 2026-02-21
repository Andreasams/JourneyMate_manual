# Phase 7 Implementation: Lessons Learned & Session Protocol

**Created:** 2026-02-21
**Purpose:** Capture lessons learned from Phase 7 widget/page implementation to guide future sessions
**Update Protocol:** Each Claude Code session implementing Phase 7 work MUST append to this document before ending

---

## Session Scope Rule (CRITICAL)

**⚠️ MANDATORY: Each Claude Code session MUST work on ONLY ONE aspect of Phase 7 at a time:**

### For Shared Widgets (29 total):
- **Most widgets:** 3 widgets per session (batch implementation)
- **Exception — Large widgets (MUST be solo sessions):**
  - `menu_dishes_list_view` (~80KB file)
  - `filter_overlay_widget` (~55KB file)
  - These are massive and complex — dedicate one full session to each

### For Pages (12 total):
- **Always:** 1 page per session
- **Never:** Multiple pages in one session
- **Reasoning:** Each page is complex, has dependencies, requires full code review checklist

### Why This Rule Exists:
1. **Token efficiency:** Keeps context focused and prevents bloat
2. **Quality:** Allows thorough testing and review of each component
3. **Handover clarity:** Clean boundaries for next session
4. **Error isolation:** Issues don't cascade across components

---

## Session Workflow (Standard Protocol)

Every Phase 7 session MUST follow this workflow:

### 1. Session Start
- Read `CLAUDE.md` completely
- Read `_reference/SESSION_STATUS.md`
- Read this file (`PHASE7_LESSONS_LEARNED.md`)
- Read `_reference/PROVIDERS_REFERENCE.md`
- Read `DESIGN_SYSTEM_flutter.md`
- Read relevant BUNDLE.md files (for pages) or MASTER_README files (for widgets)

### 2. Implementation
- For widgets: Read FlutterFlow source → MASTER_README → implement with design tokens
- For pages: Read BUNDLE.md → FlutterFlow source → implement per checklist
- Use design tokens (AppColors, AppSpacing, AppTypography, AppRadius) — NO raw hex/pixel values
- Use translation helpers: `ts(context, key)` for static, `td(ref, key)` for dynamic
- Use Riverpod 3.x: `ConsumerWidget`/`ConsumerStatefulWidget`, NOT `StateNotifier`

### 3. Verification
- Run `flutter analyze` — MUST return "No issues found!"
- Fix all warnings/errors before proceeding
- Run code review checklist (see CLAUDE.md)

### 4. Session End
- Mark task(s) as completed
- **Append lessons learned to THIS FILE** (see template below)
- Update SESSION_STATUS.md
- Commit with descriptive message
- Inform user of completion + next steps

---

## Lessons Learned (Append After Each Session)

---

### Session #1: PaymentOptionsWidget (2026-02-21)

**Widget:** `payment_options_widget.dart` (⭐ Very Low complexity)
**Completed By:** Claude Code Session (Initial Phase 7 implementation)
**Duration:** ~2 hours
**Lines of Code:** 567 lines
**Status:** ✅ Complete, 0 issues

#### What Went Well
1. **Design token translation was straightforward:**
   - FlutterFlow colors → AppColors mapping was clean
   - FlutterFlow spacing → AppSpacing mapping was 1:1
   - Used AppRadius.facility (9px) for button border radius

2. **No Riverpod dependencies needed:**
   - Widget is pure StatefulWidget (no provider reads)
   - All data comes via props
   - This made translation very clean

3. **FlutterFlow source was well-structured:**
   - Clear section comments (CONSTANTS, LIFECYCLE, ALGORITHMS, UI BUILDERS)
   - Helper methods were small and focused
   - Easy to translate line-by-line

4. **Flutter analyze caught issues early:**
   - Unnecessary cast warning → fixed
   - Container vs SizedBox suggestion → fixed
   - Final result: 0 issues

#### Challenges & Solutions
1. **Challenge:** Some FlutterFlow colors don't map 1:1 to AppColors
   - FlutterFlow used `#D35400` (darker orange) for selected borders
   - AppColors only has `#E8751A` (lighter orange accent)
   - **Solution:** Used AppColors.accent anyway (design system compliance > pixel-perfect match)

2. **Challenge:** MaterialStateProperty deprecated warning
   - FlutterFlow uses `MaterialStateProperty.all(...)`
   - Flutter 3.x prefers `WidgetStateProperty.all(...)`
   - **Solution:** Changed to `WidgetStateProperty` (modern API)

3. **Challenge:** Container vs SizedBox warnings
   - Flutter analyzer suggests SizedBox for layout-only containers
   - **Solution:** Used SizedBox when only providing width/height constraints

#### Translation Patterns Discovered
1. **Color mapping priorities:**
   ```dart
   // FlutterFlow: raw hex
   static const Color _selectedBorderColor = Color(0xFFD35400);

   // Riverpod 3.x: design token
   static const Color _selectedBorderColor = AppColors.accent;
   ```

2. **Spacing constants:**
   ```dart
   // FlutterFlow: magic numbers
   static const double _buttonSpacing = 8.0;

   // Riverpod 3.x: design tokens
   static const double _buttonSpacing = AppSpacing.sm;
   ```

3. **Border radius:**
   ```dart
   // FlutterFlow: magic number
   borderRadius: BorderRadius.circular(15.0)

   // Riverpod 3.x: design token
   borderRadius: BorderRadius.circular(AppRadius.facility)
   ```

#### Key Takeaways for Next Sessions
1. **Read flutter_export source FIRST** — don't try to implement from MASTER_README alone
2. **Design tokens are non-negotiable** — even if colors don't match exactly
3. **Use WidgetStateProperty** — not MaterialStateProperty (Flutter 3.x)
4. **SizedBox > Container** — when only setting width/height
5. **StatefulWidget is fine** — don't force ConsumerWidget if no provider reads needed
6. **flutter analyze is your friend** — run early and often

#### Files Created/Modified
- ✅ Created: `journey_mate/lib/widgets/shared/payment_options_widget.dart` (567 lines)
- ✅ No other files needed (widget is self-contained)

#### Next Widget Recommended
**FilterDescriptionSheet** (⭐⭐ Low complexity)
- Simple bottom sheet with text display
- Uses DraggableScrollableSheet
- Reads from filterProvider (introduces provider pattern)
- Good next step to learn ConsumerWidget pattern

---

### Session #2: [Widget/Page Name] (YYYY-MM-DD)

**Widget/Page:**
**Completed By:**
**Duration:**
**Status:**

#### What Went Well


#### Challenges & Solutions


#### Translation Patterns Discovered


#### Key Takeaways for Next Sessions


#### Files Created/Modified


---

## Common Pitfalls (Avoid These!)

### Pitfall #1: Using Raw Hex Colors
❌ **Bad:**
```dart
color: Color(0xFFe8751a)
```
✅ **Good:**
```dart
color: AppColors.accent
```

### Pitfall #2: Using Magic Number Spacing
❌ **Bad:**
```dart
padding: EdgeInsets.all(16.0)
```
✅ **Good:**
```dart
padding: EdgeInsets.all(AppSpacing.lg)
```

### Pitfall #3: Using MaterialStateProperty (Deprecated in Flutter 3.x)
❌ **Bad:**
```dart
MaterialStateProperty.all(Colors.white)
```
✅ **Good:**
```dart
WidgetStateProperty.all(Colors.white)
```

### Pitfall #4: Forcing ConsumerWidget When Not Needed
❌ **Bad:**
```dart
class MyWidget extends ConsumerWidget {
  // No ref.watch() or ref.read() anywhere
}
```
✅ **Good:**
```dart
class MyWidget extends StatefulWidget {
  // Pure widget, no provider access needed
}
```

### Pitfall #5: Not Running flutter analyze Before Committing
❌ **Bad:** Commit without checking for issues
✅ **Good:**
```bash
cd journey_mate
flutter analyze
# MUST show "No issues found!"
git add .
git commit -m "..."
```

---

## Design Token Quick Reference

### Colors
```dart
import '../../theme/app_colors.dart';

AppColors.accent          // #e8751a - Orange (CTAs, interactive)
AppColors.green           // #1a9456 - Green (matches only)
AppColors.textPrimary     // #0f0f0f - Headings
AppColors.textSecondary   // #555555 - Body text
AppColors.bgPage          // #ffffff - Page background
AppColors.border          // #e8e8e8 - Default borders
```

### Spacing
```dart
import '../../theme/app_spacing.dart';

AppSpacing.xs    // 4px
AppSpacing.sm    // 8px
AppSpacing.md    // 12px
AppSpacing.lg    // 16px
AppSpacing.xl    // 20px
AppSpacing.xxl   // 24px
```

### Radius
```dart
import '../../theme/app_radius.dart';

AppRadius.chip       // 8px
AppRadius.facility   // 9px
AppRadius.filter     // 10px
AppRadius.input      // 12px
AppRadius.button     // 14px
AppRadius.card       // 16px
```

### Typography
```dart
import '../../theme/app_typography.dart';

AppTypography.pageTitle       // 24px, w800
AppTypography.sectionHeading  // 18px, w700
AppTypography.bodyRegular     // 14px, w400
AppTypography.label           // 14px, w500
```

---

## Widget Complexity Guide

Use this to estimate effort for each widget:

| Complexity | Characteristics | Estimated Time | Example |
|------------|----------------|----------------|---------|
| ⭐ Very Low | Display-only, no state, < 200 lines | 1-2 hours | PaymentOptionsWidget |
| ⭐⭐ Low | Simple state, 1-2 props, < 400 lines | 2-3 hours | FilterDescriptionSheet |
| ⭐⭐⭐ Medium | Complex state, 3-5 props, API calls, < 600 lines | 3-4 hours | ContactUsFormWidget |
| ⭐⭐⭐⭐ High | Very complex state, 5+ props, nested widgets, > 600 lines | 4-6 hours | UnifiedFiltersWidget |
| ⭐⭐⭐⭐⭐ Extreme | Massive file (> 1000 lines), multiple APIs, complex logic | Full session | menu_dishes_list_view |

---

## Translation Checklist (Use for Every Widget)

Before marking a widget complete, verify:

- [ ] ✅ All raw hex colors replaced with AppColors.*
- [ ] ✅ All magic numbers replaced with AppSpacing.* / AppRadius.*
- [ ] ✅ All inline TextStyle replaced with AppTypography.* (or google_fonts)
- [ ] ✅ FFAppState reads/writes replaced with provider reads/writes
- [ ] ✅ StateNotifier replaced with Notifier (Riverpod 3.x)
- [ ] ✅ MaterialStateProperty replaced with WidgetStateProperty
- [ ] ✅ Hardcoded strings replaced with ts() or td()
- [ ] ✅ flutter analyze returns "No issues found!"
- [ ] ✅ Code review checklist passed (see CLAUDE.md)
- [ ] ✅ Lessons learned appended to this file
- [ ] ✅ SESSION_STATUS.md updated
- [ ] ✅ Git commit created

---

## Widget Implementation Order (Recommended)

Based on complexity and dependencies:

### Batch 1 (Very Low/Low complexity, no dependencies)
1. ✅ PaymentOptionsWidget
2. FilterDescriptionSheet
3. MissingLocationFormWidget

### Batch 2 (Low complexity, minimal dependencies)
4. BusinessFeatureButtons
5. MenuCategoriesRows
6. ExpandableTextWidget

### Batch 3 (Medium complexity, introduces patterns)
7. ContactUsFormWidget
8. FeedbackFormWidget
9. NavBarWidget

### Batch 4 (Medium complexity, gallery/package widgets)
10. PackageBottomSheet
11. PackageCoursesDisplay
12. GalleryTabWidget

### Batch 5 (Medium complexity, contact/hours)
13. ContactDetailWidget
14. OpeningHoursAndWeekdays
15. ImageGalleryOverlaySwipableWidget

### Solo Sessions (High complexity, massive files)
16. **MenuDishesListView** (⭐⭐⭐⭐⭐ Extreme) — SOLO SESSION REQUIRED
17. **FilterOverlayWidget** (⭐⭐⭐⭐⭐ Extreme) — SOLO SESSION REQUIRED
18. ItemBottomSheet (⭐⭐⭐⭐ High)
19. UnifiedFiltersWidget (⭐⭐⭐⭐ High)

### Remaining widgets (categorize as you encounter them)
20-29. [To be categorized based on MASTER_README analysis]

---

**End of PHASE7_LESSONS_LEARNED.md**

**Next session:** Read this file completely before starting any work!
