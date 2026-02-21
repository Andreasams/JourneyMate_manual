# Phase 7 Implementation: Lessons Learned & Session Protocol

**Created:** 2026-02-21
**Last Updated:** 2026-02-21
**Purpose:** Capture lessons learned from Phase 7 widget/page implementation to guide future sessions AND enable final cross-widget consistency review
**Update Protocol:** Each Claude Code session implementing Phase 7 work MUST update this document before ending

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

### 4. Session End (3 REQUIRED UPDATES)
1. **Update Pattern Discovery Timeline** (if you discovered a new pattern)
2. **Update Widget Build Order** (add your session entry)
3. **Append session lessons learned** (if relevant — see guidelines below)
4. Update SESSION_STATUS.md
5. Commit with descriptive message
6. Inform user of completion + next steps

---

## How to Update This Document (Guidelines for Each Session)

### ✅ ALWAYS Update (Every Session):

**1. Widget Build Order Table** (see section below)
- Add row for your session showing:
  - Session number
  - Widgets built
  - Patterns that existed at time of build
  - Total lines of code

**2. Session Status Tracking**
- Update widget count in SESSION_STATUS.md
- Mark widgets as complete in Widget Implementation Order section

### ⚠️ CONDITIONALLY Update (Only When Relevant):

**3. Pattern Discovery Timeline** (see section below)
- Add row ONLY if you discovered a NEW pattern that:
  - Should be applied to future widgets
  - Should be retrofitted to past widgets (note which ones)
  - Changes how something should be implemented

**4. Session Lessons Learned Entry** (detailed entry)
- Add full session entry ONLY if you:
  - Discovered a new pattern or approach
  - Encountered a non-obvious challenge with useful solution
  - Found a pitfall that future sessions should avoid
  - Made decisions affecting future implementations

**5. Common Pitfalls Section**
- Add new pitfall ONLY if it's a recurring mistake risk
- Must have ❌ Bad example + ✅ Good example

### ❌ NEVER Add:

- Lessons that contradict CLAUDE.md rules
- "Worked as expected" boilerplate
- Duplicate patterns already documented
- Empty/vague entries without specific examples

---

## 🚨 CRITICAL RULE: Lessons Learned MUST NOT Contradict Established Rules

**Lessons learned are for sharing NEW patterns and solutions WITHIN the established constraints.**

**❌ NEVER document lessons learned that:**
- Contradict or weaken existing rules in CLAUDE.md
- Suggest skipping steps from the standard workflow
- Recommend breaking design system compliance
- Propose shortcuts that bypass verification
- Conflict with phase protocols or design documents

**✅ VALID lessons learned examples:**
- "MaterialStateProperty → WidgetStateProperty (Flutter 3.x)" — technical update
- "Use AppColors.accent even if FlutterFlow color doesn't match exactly" — reinforces design token rule
- "SizedBox > Container for layout-only constraints" — best practice within analyzer guidance

**If you think a rule should change, that's a user decision (update CLAUDE.md), NOT a lesson learned.**

---

## Pattern Discovery Timeline

**Purpose:** Track WHEN patterns were discovered and which widgets need them retrofitted.

**How to update:** Add a row when you discover a NEW pattern that should apply to other widgets.

| Session | Pattern Discovered | Applies To | Widgets Built Before This Pattern |
|---------|-------------------|------------|-----------------------------------|
| #1 | WidgetStateProperty (not MaterialStateProperty) | All widgets | None (first session) |
| #2 | `.withValues(alpha:)` not `.withOpacity()` | All color transparency | #1 (PaymentOptionsWidget) |
| #2 | Language code via `Localizations.localeOf(context)` | All widgets needing API language | #1 (PaymentOptionsWidget) |
| #4 | Widget-local state uses State variables (not Notifier) | All stateful widgets | #1-5 |
| #6 | `context.mounted` not `mounted` after async | All async operations | #1-11 |
| #6 | Null-aware spread operator for optional map entries | All optional map construction | #1-11 |
| #6 | Language-adaptive layout widths for CJK/Polish/Finnish | Widgets displaying translated day/month names | #1-11 |
| #7 | Topic sent as localized label string (not stable key) | Forms using `supabaseInsertObject` | N/A (first form) |
| #7 | Remove `markUserEngaged()` calls (ActivityScope handles it) | All widgets | #1-15 (but none had it) |
| #8 | Filter column widths must be exact: 36%/33%/31% | Filter-related widgets | #1-17 |

**Note:** After all 29 widgets complete, use this table for "Final Review Checklist" to propagate patterns backward.

---

## Widget Build Order

**Purpose:** Show what patterns were available when each widget was built (for final review).

**How to update:** Add a row at end of each session.

| Session | Widgets Built | Patterns Available At Build Time | Lines of Code |
|---------|---------------|----------------------------------|---------------|
| #1 | PaymentOptionsWidget | (baseline) | 567 |
| #2 | FilterDescriptionSheet, MissingLocationFormWidget | +.withValues, +language access | 652 |
| #3 | ExpandableTextWidget, BusinessFeatureButtons | +.withValues, +language access | 1,089 |
| #4 | MenuCategoriesRows | +widget-local state | 1,106 |
| #5 | PackageCoursesDisplay, PackageBottomSheet, GalleryTabWidget | +widget-local state | 2,207 |
| #6 | OpeningHoursAndWeekdays, ContactDetailsWidget, ImageGalleryOverlay | +context.mounted, +null-aware spread, +language-adaptive layout | 1,155 |
| #7 | ContactUsFormWidget, FeedbackFormWidget, NavBarWidget | +localized labels for forms, +markUserEngaged removal | 1,530 |
| #8 | FilterTitlesRow, CategoryDescriptionSheet, LanguageSelectorButton | +exact filter column widths | 632 |

**Total implemented:** 18/29 widgets (62%)
**Total lines of code:** ~8,938 lines

---

## Migration Rules from FlutterFlow (ALWAYS APPLY)

### ✅ User Engagement Tracking: REMOVE markUserEngaged()

**FlutterFlow Pattern (44+ files):**
```dart
import '/custom_code/actions/mark_user_engaged.dart';

Future<void> onButtonTap() async {
  await markUserEngaged(); // ← Manual call in every widget
  // ... actual logic
}
```

**New Flutter App Pattern (AUTOMATIC):**
```dart
// NO manual calls needed!
// ActivityScope wraps entire app in main.dart:41
// Automatically detects ALL interactions (tap, scroll, keyboard)
Future<void> onButtonTap() async {
  // ... actual logic (engagement tracked automatically)
}
```

**Migration Rule:**
1. ✅ **REMOVE** all `markUserEngaged()` calls from FlutterFlow source
2. ✅ **REMOVE** the import: `import '/custom_code/actions/mark_user_engaged.dart'`
3. ✅ **DO NOT REPLACE** with anything — ActivityScope handles it automatically

**Why This Is Better:**
- ✅ Zero manual calls needed (can't forget to add tracking)
- ✅ Catches ALL interactions automatically (tap, scroll, keyboard, navigation)
- ✅ More accurate (ActivityScope wraps entire app, sees everything)
- ✅ Cleaner widget code (no boilerplate)
- ✅ Direct method call (no SharedPreferences overhead)

**Implementation Details:**
- `ActivityScope` widget wraps app (`journey_mate/lib/widgets/activity_scope.dart`)
- Uses `Listener` widget with `onPointerDown`, `onPointerMove`, `onPointerSignal`
- Calls `AnalyticsService.instance.engagementTracker.markUserActive()` automatically
- Engagement tracker manages 30-minute session timeout and 60-second flush

**Applies To:** ALL 29 widgets and ALL 12 pages in Phase 7.

**Reference:** See CLAUDE.md decision #31 for full rationale.

---

## Session Lessons Learned (Detailed Entries)

**Note:** These entries preserve temporal context for final cross-widget review. Each session documents what was known at that moment in time.

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

---

### Session #2: FilterDescriptionSheet + MissingLocationFormWidget (2026-02-21)

**Widgets:** FilterDescriptionSheet (165 lines) + MissingLocationFormWidget (487 lines)
**Completed By:** Claude Code Session #2
**Duration:** ~3 hours
**Status:** ✅ Complete, 0 issues

#### What Went Well

1. **FilterDescriptionSheet was straightforward:**
   - Simple StatefulWidget (no Riverpod needed) - same pattern as Session #1
   - Clear FlutterFlow source with minimal FlutterFlow-specific code
   - Design token translation was 1:1 (no ambiguous colors)

2. **MissingLocationFormWidget followed established patterns:**
   - ConsumerStatefulWidget for API access
   - 3-state rendering pattern (default/success/error) was clear
   - Validation logic translated cleanly from FlutterFlow

3. **Translation key management worked well:**
   - Added 18 keys to kStaticTranslations with all 7 languages
   - Generated 126 SQL INSERT statements automatically
   - Descriptive key names make keys self-documenting

#### Challenges & Solutions

1. **Challenge:** Used non-existent `currentLanguageProvider`
   - FlutterFlow passes `currentLanguage` as prop; assumed Riverpod had equivalent provider
   - PROVIDERS_REFERENCE.md has no language provider
   - **Solution:** Use `Localizations.localeOf(context).languageCode` (same pattern as `ts()` helper)
   - **Pattern for future:** Any widget needing language code for API calls should use locale from context

2. **Challenge:** `.withOpacity()` deprecation warnings in Flutter 3.x
   - FlutterFlow code uses `.withOpacity(0.5)` for alpha transparency
   - Flutter 3.x deprecated this in favor of `.withValues(alpha: 0.5)`
   - **Solution:** Search-replace all `.withOpacity(` → `.withValues(alpha:`
   - **Pattern for future:** Always use `.withValues(alpha:)` for color transparency in Flutter 3.x

3. **Challenge:** FlutterFlow colors don't match design system
   - FlutterFlow: #E9874B (button), #249689 (success)
   - Design system: #e8751a (AppColors.accent), #1a9456 (AppColors.success)
   - **Solution:** Use design system colors + add code comment explaining deviation
   - **Pattern for future:** Design system compliance > pixel-perfect FlutterFlow match (already established in Session #1)

#### Translation Patterns Discovered

1. **No language provider exists** — use `Localizations.localeOf(context).languageCode` for API calls
2. **Translation helper for ConsumerWidgets:**
   ```dart
   // Import translation_service.dart
   import '../../services/translation_service.dart';

   // Use ts(context, key) for static keys
   Text(ts(context, 'missing_location_title_main'))
   ```

3. **Phase 6B key naming:**
   - Descriptive snake_case: `'missing_location_title_business_name'`
   - Prefixed by widget/page: `'missing_location_*'`
   - Grouped logically: titles, subtitles, hints, errors, status

#### Key Takeaways for Next Sessions

1. **Language code access pattern:**
   ```dart
   final locale = Localizations.localeOf(context);
   final languageCode = locale.languageCode;
   ```
   Do NOT assume `currentLanguageProvider` exists.

2. **Flutter 3.x color transparency:**
   Always use `.withValues(alpha: 0.5)`, NEVER `.withOpacity(0.5)`.

3. **Form validation pattern:**
   - Validate all fields in one method that returns bool
   - Clear all errors first, then set new errors
   - Real-time error clearing: onChanged clears that field's error
   - Example in MissingLocationFormWidget is reusable

4. **3-state UI pattern (default/success/error):**
   ```dart
   Widget _buildSubmitArea() {
     if (_isSubmitted) return _buildSuccessMessage();
     if (_submissionError != null) return _buildErrorMessage();
     return _buildSubmitButton();
   }
   ```

5. **Design system color decisions are final:**
   - Document deviation in code comment
   - Do NOT try to match FlutterFlow colors exactly
   - AppColors.* always takes precedence

6. **StatefulWidget vs ConsumerStatefulWidget decision:**
   - No provider reads? → StatefulWidget (FilterDescriptionSheet)
   - Needs provider access? → ConsumerStatefulWidget (MissingLocationFormWidget)
   - Don't force ConsumerWidget if not needed

#### Files Created/Modified

- ✅ Created: `journey_mate/lib/widgets/shared/filter_description_sheet.dart` (165 lines)
- ✅ Created: `journey_mate/lib/widgets/shared/missing_location_form_widget.dart` (487 lines)
- ✅ Updated: `journey_mate/lib/services/translation_service.dart` (18 keys added)
- ✅ Created: `_reference/NEW_TRANSLATION_KEYS.sql` (126 SQL statements)
- ✅ Updated: `_reference/SESSION_STATUS.md`

---

### Session #4: MenuCategoriesRows (2026-02-21)

**Widget:** MenuCategoriesRows (6/29 widgets)
**Completed By:** Claude Code Session #4
**Duration:** ~4 hours
**Lines of Code:** 1,106 lines (reduced from 1,250 via state management simplification)
**Status:** ✅ Complete, 0 issues

#### What Went Well

1. **Widget-local state pattern discovery:**
   - Initially attempted widget-local Notifier (following FlutterFlow's BLoC pattern)
   - Realized Riverpod 3.x Notifiers REQUIRE providers and are for shared state
   - Successfully migrated to plain State variables with setState() for truly widget-local state
   - This is simpler and more appropriate than creating unnecessary providers

2. **All 7 algorithms preserved unchanged:**
   - Menu transformation (150 lines)
   - Display configuration detection (25 lines)
   - Auto-scroll to visible item (65 lines)
   - Selection change handling (40 lines)
   - Visible selection processing (30 lines)
   - GlobalKey management (~50 lines)
   - Type safety helpers (25 lines)
   - All algorithms are BLoC-agnostic and copied directly

3. **Design token translation was clean:**
   - FlutterFlow `Color(0xFFEE8B60)` → `AppColors.accent`
   - FlutterFlow `Color(0xFFf2f3f5)` → `AppColors.bgSurface`
   - FlutterFlow `8.0` spacing → `AppSpacing.sm`
   - FlutterFlow `16.0` padding → `AppSpacing.lg`
   - FlutterFlow `8.0` radius → `AppRadius.chip`

4. **Translation migration worked perfectly:**
   - Removed `languageCode` and `translationsCache` props
   - Used `td(ref, key)` for dynamic translations via `translationsCacheProvider`
   - Multi-course header translations already exist in `kStaticTranslations`

#### Challenges & Solutions

1. **Challenge:** Widget-local Notifier pattern doesn't work in Riverpod 3.x
   - FlutterFlow uses `MenuCategoryCubit extends Cubit<State>` locally
   - Tried `MenuCategoryNotifier extends Notifier<State>` as widget field
   - **Problem:** `_notifier.state` is `@protected` and only accessible inside Notifier class
   - **Problem:** `_notifier.dispose()` method doesn't exist on Notifier
   - **Solution:** Use plain State variables in ConsumerStatefulWidget:
     ```dart
     // Widget-local state (no Notifier needed)
     List<Menu> _menus = [];
     String _selectedMenuId = '';
     String _selectedCategoryId = '';

     // Update with setState()
     setState(() {
       _selectedMenuId = menuId;
       _selectedCategoryId = categoryId;
     });
     ```

2. **Challenge:** `dynamic?` type warning
   - FlutterFlow code has `final dynamic? visibleSelection`
   - **Solution:** Changed to `final dynamic visibleSelection` (dynamic is already nullable)

3. **Challenge:** Unnecessary underscore warnings in separatorBuilder
   - FlutterFlow uses `(_, __) =>` for unused lambda parameters
   - **Solution:** Changed to `(_, _) =>` (analyzer prefers single underscore for second param)

#### Translation Patterns Discovered

1. **Widget-local state in Riverpod 3.x:**
   ```dart
   // ❌ WRONG: Notifier needs provider
   class _MyWidgetState extends ConsumerState<MyWidget> {
     late final MyNotifier _notifier;

     @override
     Widget build(BuildContext context) {
       return Text(_notifier.state.value); // ❌ Can't access .state
     }
   }

   // ✅ CORRECT: Use plain State variables
   class _MyWidgetState extends ConsumerState<MyWidget> {
     String _value = '';

     void _update(String newValue) {
       setState(() => _value = newValue);
     }

     @override
     Widget build(BuildContext context) {
       return Text(_value); // ✅ Works perfectly
     }
   }
   ```

2. **When to use Notifier vs State variables:**
   - **Notifier + Provider:** State is shared across multiple widgets/pages
   - **State variables:** State is 100% scoped to single widget instance
   - **ConsumerStatefulWidget:** Needs to READ providers but has local state

3. **BLoC → Widget-local state migration:**
   - Remove `Cubit`/`Notifier` class entirely
   - Convert state class fields to plain State variables
   - Replace `emit(newState)` with `setState(() => _field = value)`
   - Remove `_cubit.close()` from dispose (State variables need no cleanup)

#### Key Takeaways for Next Sessions

1. **Riverpod 3.x widget-local state pattern:**
   - DO NOT create widget-local Notifier classes
   - Use plain State variables in ConsumerStatefulWidget
   - Only use Notifier when state needs to be shared via provider
   - This is simpler than BLoC's widget-local Cubit pattern

2. **Large widget migration strategy:**
   - Read entire FlutterFlow file first (understand structure)
   - Identify truly widget-local state vs. shared state
   - Copy algorithms unchanged (they're framework-agnostic)
   - Only translate state management wrapper code
   - Design tokens last (mechanical search-replace)

3. **Frame callback safety:**
   - Always check `if (!mounted) return;` after frame callbacks
   - Critical for widgets that may be disposed during async operations

4. **GlobalKey position calculation:**
   - Null-check `itemKey?.currentContext` before accessing
   - Null-check RenderBox casts
   - Wrap in try-catch for robustness

5. **Multiple ScrollControllers:**
   - Store in widget State, not in Notifier
   - Dispose in correct order (notifier first if exists, then controllers)

6. **Complex widgets are ⭐⭐ Low complexity if:**
   - Algorithms are portable (no framework coupling)
   - State is widget-local (no provider dependencies)
   - UI is simple (basic buttons and lists)
   - Line count doesn't indicate difficulty

#### Files Created/Modified

- ✅ Created: `journey_mate/lib/widgets/shared/menu_categories_rows.dart` (1,106 lines)
- ✅ Updated: `_reference/SESSION_STATUS.md`

---

### Session #6: OpeningHoursAndWeekdays + ContactDetailsWidget + ImageGalleryOverlaySwipableWidget (2026-02-21)

**Widgets:** Batch 5 (3 widgets)
**Completed By:** Claude Code Session #6
**Status:** ✅ Complete, 0 issues

#### What Went Well
1. OpeningHoursAndWeekdays translation system with 23 keys worked smoothly
2. ContactDetailsWidget map_launcher and url_launcher integration was straightforward
3. Language-adaptive layout logic was well-documented in FlutterFlow source
4. Flutter 3.x patterns (context.mounted, null-aware spread) applied correctly
5. All 11 flutter analyze issues fixed efficiently

#### Challenges & Solutions

1. **Challenge:** Language-adaptive column width logic for OpeningHoursAndWeekdays
   **Solution:** Created helper method `_getWeekdayColumnWidth(languageCode)` with CJK/Polish/Finnish/default cases:
   ```dart
   double _getWeekdayColumnWidth(String languageCode) {
     // CJK languages use shorter characters
     if (['zh', 'ja', 'ko'].contains(languageCode)) return 75.0;
     // Polish/Finnish use longer weekday names
     if (['pl', 'fi'].contains(languageCode)) return 125.0;
     // Default for most European languages
     return 85.0;
   }
   ```

2. **Challenge:** Copy-to-clipboard dialogs with 1-second auto-dismiss in ContactDetailsWidget
   **Solution:** Used `showDialog` + `Future.delayed(Duration(seconds: 1))` + `context.mounted` check before `Navigator.pop`:
   ```dart
   await _showCopyDialog(context, text, label);
   await Future.delayed(const Duration(seconds: 1));
   if (context.mounted) {
     Navigator.of(context, rootNavigator: true).pop();
   }
   ```

3. **Challenge:** Flutter analyzer wanted null-aware pattern for optional map entries
   **Solution:** Used null-aware spread operator `...?` instead of collection-if:
   ```dart
   // ❌ BEFORE (lint warning)
   if (note != null) 'note': note,

   // ✅ AFTER (no warning)
   ...?note != null ? {'note': note} : null,
   ```

4. **Challenge:** `use_build_context_synchronously` warnings after async operations
   **Solution:** Changed `mounted` checks to `context.mounted` (Flutter 3.x best practice):
   ```dart
   // ❌ BEFORE
   if (mounted) {
     await _showCopiedConfirmation(context);
   }

   // ✅ AFTER
   if (context.mounted) {
     await _showCopiedConfirmation(context);
   }
   ```

5. **Challenge:** Unused imports triggering flutter analyze warnings
   **Solution:** Removed unused `app_colors.dart` and `app_spacing.dart` imports when only `app_typography.dart` was needed

#### Key Takeaways for Next Sessions

1. **Language-adaptive layout pattern:**
   When building widgets that display language-dependent text (day names, month names, etc.), always check if column widths need to vary by language:
   ```dart
   double _getColumnWidth(String lang) {
     if (['zh', 'ja', 'ko'].contains(lang)) return narrowWidth;
     if (['pl', 'fi'].contains(lang)) return wideWidth;
     return defaultWidth;
   }
   ```

2. **External package integration (map_launcher, url_launcher):**
   - Always check availability before launching:
     ```dart
     final availableMaps = await MapLauncher.installedMaps;
     if (availableMaps.isNotEmpty && context.mounted) {
       await availableMaps.first.showMarker(...);
     }

     final uri = Uri.parse(url);
     if (await canLaunchUrl(uri)) {
       await launchUrl(uri);
     }
     ```
   - Wrap in try-catch for robust error handling
   - Check `context.mounted` before showing error dialogs

3. **Wrapper widget pattern (ImageGalleryOverlaySwipableWidget):**
   - Thin wrappers can be < 100 lines
   - Delegate all logic to composed widget
   - Only handle onClose callbacks or navigation
   - Use placeholder UI when underlying widget doesn't exist yet

4. **Null-aware spread operator pattern (Flutter 3.x):**
   When adding optional entries to a map literal, prefer `...?` over collection-if to satisfy linter:
   ```dart
   Map<String, dynamic> data = {
     'required_field': value,
     ...?optionalValue != null ? {'optional_field': optionalValue} : null,
   };
   ```

5. **context.mounted vs mounted:**
   After ANY async operation (Future.delayed, API call, file I/O), always check `context.mounted` (not `mounted`) before using BuildContext:
   ```dart
   await someAsyncOperation();
   if (context.mounted) {
     Navigator.pop(context);
     ScaffoldMessenger.of(context).showSnackBar(...);
   }
   ```

#### Files Created/Modified
- ✅ Created: opening_hours_and_weekdays.dart (~392 lines)
- ✅ Created: contact_details_widget.dart (~693 lines)
- ✅ Created: image_gallery_overlay_swipable_widget.dart (~70 lines)
- ✅ Updated: translation_service.dart (36 keys: 23 + 13)
- ✅ Updated: NEW_TRANSLATION_KEYS.sql (252 translations: 161 + 91)

#### Widget-Specific Notes

**OpeningHoursAndWeekdays:**
- Parses complex `openingHours` JSON structure (7 days × 5 slots × 2 cutoffs per slot)
- Responsive wrapping: cutoff times move to next line when `textScaleFactor >= 1.1` or bold text enabled
- Translation keys use descriptive names: `day_monday_cap`, `cutoff_type_kitchen_close`, etc.
- Does NOT use Riverpod (pure StatefulWidget with props)

**ContactDetailsWidget:**
- Composes OpeningHoursAndWeekdays (dependency satisfied in same batch)
- 6 conditional contact methods: phone, email, website, reservation, Instagram, Facebook
- Uses businessProvider (read-only) for current business data
- Uses accessibilityProvider (read-only) for bold text setting
- All icons from Feather Icons (consistent with design system)

**ImageGalleryOverlaySwipableWidget:**
- Placeholder implementation (ImageGalleryWidget from custom_widgets not yet available)
- Shows temporary UI with category name, image count, and close button
- Will be replaced when ImageGalleryWidget is implemented in a future batch

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

### Pitfall #6: Using .withOpacity() (Deprecated in Flutter 3.x)
❌ **Bad:**
```dart
color: AppColors.accent.withOpacity(0.5)
```
✅ **Good:**
```dart
color: AppColors.accent.withValues(alpha: 0.5)
```
**Why:** `.withOpacity()` is deprecated in Flutter 3.x. Always use `.withValues(alpha:)` for transparency.

### Pitfall #7: Assuming currentLanguageProvider Exists
❌ **Bad:**
```dart
final languageCode = ref.watch(currentLanguageProvider);
```
✅ **Good:**
```dart
final languageCode = Localizations.localeOf(context).languageCode;
```
**Why:** No language provider exists in PROVIDERS_REFERENCE.md. Use `Localizations.localeOf(context)` instead.

### Pitfall #8: Using mounted Instead of context.mounted After Async
❌ **Bad:**
```dart
await someAsyncOperation();
if (mounted) {
  Navigator.pop(context); // ⚠️ Can cause lint warning
}
```
✅ **Good:**
```dart
await someAsyncOperation();
if (context.mounted) {
  Navigator.pop(context); // ✅ Flutter 3.x best practice
}
```
**Why:** Flutter 3.x linter prefers `context.mounted` for async operations to avoid `use_build_context_synchronously` warnings.

### Pitfall #9: Using collection-if for Optional Map Entries
❌ **Bad:**
```dart
Map<String, dynamic> data = {
  'required': value,
  if (optional != null) 'optional': optional, // ⚠️ Lint warning
};
```
✅ **Good:**
```dart
Map<String, dynamic> data = {
  'required': value,
  ...?optional != null ? {'optional': optional} : null, // ✅ No warning
};
```
**Why:** Flutter 3.x linter prefers null-aware spread operator for cleaner null handling.

### Pitfall #10: Creating Widget-Local Notifier Classes
❌ **Bad:**
```dart
class _MyWidgetState extends ConsumerState<MyWidget> {
  late final MyNotifier _notifier; // ❌ Notifier needs provider

  @override
  void initState() {
    super.initState();
    _notifier = MyNotifier();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_notifier.state); // ❌ Can't access .state (protected)
  }
}
```
✅ **Good:**
```dart
class _MyWidgetState extends ConsumerState<MyWidget> {
  String _value = ''; // ✅ Plain state variable

  void _update(String newValue) {
    setState(() => _value = newValue);
  }

  @override
  Widget build(BuildContext context) {
    return Text(_value); // ✅ Works perfectly
  }
}
```
**Why:** Riverpod 3.x Notifiers require providers. For widget-local state, use plain State variables with `setState()`.

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
- [ ] ✅ `.withOpacity()` replaced with `.withValues(alpha:)`
- [ ] ✅ `mounted` replaced with `context.mounted` after async operations
- [ ] ✅ Hardcoded strings replaced with ts() or td()
- [ ] ✅ flutter analyze returns "No issues found!"
- [ ] ✅ Code review checklist passed (see CLAUDE.md)
- [ ] ✅ Lessons learned appended to this file (if relevant)
- [ ] ✅ SESSION_STATUS.md updated
- [ ] ✅ Git commit created

---

## Widget Implementation Order (Remaining Widgets)

**Widgets Complete:** 18/29 (62%)

### Remaining Widgets (11 total):

**Priority 1 — Business/Menu Components:**
- BusinessHoursWidget (⭐⭐ Low)
- MenuItemCard (⭐⭐⭐ Medium)
- DietaryBadgesRow (⭐⭐ Low)

**Priority 2 — Filter Components:**
- UnifiedFiltersWidget (⭐⭐⭐⭐ High) — Complex filter state
- FilterChipRow (⭐⭐ Low)

**Priority 3 — Search/Results Components:**
- SearchBarWidget (⭐⭐⭐ Medium)
- BusinessCardWidget (⭐⭐⭐ Medium)
- SectionHeaderRow (⭐ Very Low)

**Priority 4 — Massive Solo Sessions:**
- **MenuDishesListView** (⭐⭐⭐⭐⭐ Extreme) — SOLO SESSION REQUIRED (~1,500+ lines)
- **FilterOverlayWidget** (⭐⭐⭐⭐⭐ Extreme) — SOLO SESSION REQUIRED (~1,200+ lines)

**Priority 5 — Miscellaneous:**
- ItemBottomSheet (⭐⭐⭐⭐ High) — Depends on MenuDishesListView

---

## Final Review Checklist (Run After All 29 Widgets Complete)

**Purpose:** Ensure pattern consistency across all widgets by propagating discoveries backward and verifying early decisions forward.

### Phase 1: Pattern Propagation (Forward Pass)

For each pattern in "Pattern Discovery Timeline", review all widgets built BEFORE that session:

- [ ] **WidgetStateProperty pattern (Session #1):** Review widgets #2-29 for any MaterialStateProperty usage
- [ ] **`.withValues(alpha:)` pattern (Session #2):** Review widget #1 (PaymentOptionsWidget) for `.withOpacity()` usage
- [ ] **Language code access (Session #2):** Review widget #1 for any language code needs
- [ ] **Widget-local state (Session #4):** Review widgets #1-5 for any widget-local Notifier usage
- [ ] **`context.mounted` (Session #6):** Review widgets #1-11 for `mounted` checks after async
- [ ] **Null-aware spread (Session #6):** Review widgets #1-11 for collection-if in map literals
- [ ] **Language-adaptive layout (Session #6):** Review widgets #1-11 for fixed-width columns with translated text
- [ ] **Localized labels for forms (Session #7):** Review any forms in widgets #1-15
- [ ] **Filter column widths 36%/33%/31% (Session #8):** Review any filter-related widgets in #1-17

### Phase 2: Design Token Consistency

- [ ] All 29 widgets use `AppColors.*` (no raw hex strings)
- [ ] All 29 widgets use `AppSpacing.*` (no magic pixel numbers)
- [ ] All 29 widgets use `AppRadius.*` (no hardcoded border radius)
- [ ] All 29 widgets use `AppTypography.*` or `GoogleFonts.*` (no inline TextStyle)
- [ ] Orange (#e8751a) only for CTAs/interactive elements (never match status)
- [ ] Green (#1a9456) only for match confirmation (never CTAs)

### Phase 3: Translation Consistency

- [ ] All 29 widgets use `ts(context, key)` for static FlutterFlow keys
- [ ] All 29 widgets use `td(ref, key)` for dynamic Supabase keys
- [ ] No hardcoded English strings remain in any widget
- [ ] All new translation keys added to `_reference/NEW_TRANSLATION_KEYS.sql`
- [ ] All keys follow naming convention (descriptive snake_case with widget/page prefix)

### Phase 4: State Management Consistency

- [ ] Widget-local state: Uses State variables with `setState()` (not Notifier)
- [ ] Shared state: Uses proper provider reads via `ref.watch()` or `ref.read()`
- [ ] No `StatefulWidget` where `ConsumerStatefulWidget` needed (widget reads providers)
- [ ] No `ConsumerWidget` where `StatefulWidget` sufficient (widget doesn't read providers)

### Phase 5: Flutter 3.x Best Practices

- [ ] All 29 widgets use `WidgetStateProperty` (not MaterialStateProperty)
- [ ] All 29 widgets use `.withValues(alpha:)` (not `.withOpacity()`)
- [ ] All 29 widgets use `context.mounted` after async (not `mounted`)
- [ ] All 29 widgets use null-aware spread `...?` for optional map entries
- [ ] All imports cleaned (no unused imports in any widget)
- [ ] All 29 widgets pass `flutter analyze` with 0 issues

### Phase 6: FlutterFlow Migration Verification

- [ ] All 29 widgets have `markUserEngaged()` calls removed (ActivityScope handles it)
- [ ] No imports of `/custom_code/actions/mark_user_engaged.dart` remain
- [ ] All FlutterFlow-specific patterns translated to Riverpod 3.x patterns
- [ ] All BLoC Cubits converted to either Notifier (shared state) or State variables (widget-local)

### Phase 7: Code Quality

- [ ] All 29 widgets have clear section comments (if > 300 lines)
- [ ] All 29 widgets have descriptive variable/method names
- [ ] All complex algorithms have explanatory comments
- [ ] No TODOs or FIXMEs remain unresolved
- [ ] All edge cases handled (null checks, empty states, error states)

---

**End of PHASE7_LESSONS_LEARNED.md**

**Next session:** Read this file completely before starting any work!

**After all 29 widgets complete:** Run "Final Review Checklist" to ensure consistency.
