# Lessons Learned: JSX → Flutter Conversion

**Purpose:** Document patterns, gotchas, and best practices discovered while converting JSX v2 designs to clean Flutter/Dart code.

**Format:** Each conversion adds new insights. This is a living document we build together.

---

## Page 1: Share Feedback Form

**Date:** 2026-02-19
**JSX Source:** `pages/settings/share_feedback_form.jsx`
**Flutter Output:** `share_feedback_page_from_jsx.dart`
**Lines of Code:** JSX 352 lines → Flutter ~450 lines (includes comments & TODO markers)

### Core Conversion Patterns

#### 1. React State → Flutter State

**JSX Pattern:**
```jsx
const [category, setCategory] = useState(null);
const [message, setMessage] = useState("");
```

**Flutter Pattern:**
```dart
class ShareFeedbackPage extends StatefulWidget {
  // Widget definition
}

class _ShareFeedbackPageState extends State<ShareFeedbackPage> {
  String? _selectedCategory;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose(); // Important: prevent memory leaks
    super.dispose();
  }
}
```

**Lesson:** Flutter uses `TextEditingController` for text inputs instead of state variables. Must dispose controllers to prevent memory leaks.

---

#### 2. Conditional Rendering

**JSX Pattern:**
```jsx
{allowContact && (
  <>
    <input ... />
    <input ... />
  </>
)}
```

**Flutter Pattern:**
```dart
if (_allowContact) ...[
  TextField(...),
  SizedBox(height: 24),
  TextField(...),
]
```

**Lesson:** Use spread operator `...[]` to conditionally insert multiple widgets. The `if` statement is cleaner than ternary for multiple widgets.

---

#### 3. Computed Values

**JSX Pattern:**
```jsx
const isValid = category && message.trim();
```

**Flutter Pattern:**
```dart
bool get _isValid {
  return _selectedCategory != null && _messageController.text.trim().isNotEmpty;
}
```

**Lesson:** Use getters for computed values. They automatically recalculate when state changes (after `setState`).

---

### Layout & Styling Patterns

#### 4. Color Definitions

**JSX Pattern:**
```jsx
import { ACCENT, GREEN } from "../../shared/_shared.jsx";
// Use: background: ACCENT
```

**Flutter Pattern:**
```dart
class AppColors {
  static const Color accent = Color(0xFFE8751A);
  static const Color green = Color(0xFF1A9456);
}
// Use: backgroundColor: AppColors.accent
```

**Lesson:** Define colors as static const in a class. Hex colors need `0xFF` prefix. Later, move to `app_theme.dart`.

---

#### 5. Font Weights

**JSX to Flutter Mapping:**
- JSX `fontWeight: 400` → Flutter `FontWeight.w400`
- JSX `fontWeight: 460` → Flutter `FontWeight.w500` (round up to nearest 100)
- JSX `fontWeight: 540` → Flutter `FontWeight.w600` (round up)
- JSX `fontWeight: 680` → Flutter `FontWeight.w700` (non-standard JSX value)
- JSX `fontWeight: 750` → Flutter `FontWeight.w800` (round up)

**Lesson:** Flutter only supports font weights in increments of 100. Round JSX values to nearest 100. Non-standard values (like 680) fallback to nearest standard weight anyway.

---

#### 6. Line Height Conversion

**JSX Pattern:**
```jsx
lineHeight: "20px"  // 14px font
```

**Flutter Pattern:**
```dart
height: 1.43  // 20 ÷ 14 = 1.43
```

**Lesson:** Flutter `height` is a multiplier, not absolute pixels. Calculate: `lineHeight ÷ fontSize`.

---

### Pixel-Perfect Refinements

#### 7. Fixed-Height Input Fields

**Initial Approach (font-dependent):**
```dart
TextField(
  decoration: InputDecoration(
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
)
```

**Pixel-Perfect Approach:**
```dart
SizedBox(
  height: 50, // Matches JSX height: 50
  child: TextField(
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  ),
)
```

**Lesson:** For pixel-perfect JSX match, wrap TextField in SizedBox with fixed height. Otherwise, height varies by font size/platform.

**Trade-off:** Fixed height is less flexible for accessibility (larger text sizes), but matches design exactly.

---

#### 8. Checkbox Alignment

**Initial Approach (misaligned):**
```dart
Row(
  children: [
    Checkbox(...),  // Has built-in padding
    Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: 12),  // Compensates for padding
        child: Text(...),
      ),
    ),
  ],
)
```

**Pixel-Perfect Approach:**
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Checkbox(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity(horizontal: -4, vertical: -4),
      // Removes built-in padding
    ),
    SizedBox(width: 12),  // Explicit gap matching JSX
    Expanded(
      child: Column(
        children: [...],  // No top padding needed
      ),
    ),
  ],
)
```

**Lesson:** Flutter Checkbox has built-in padding for touch target. Use `shrinkWrap` + `visualDensity` to remove it for pixel-perfect alignment.

---

### Interactive Patterns

#### 9. Button Enabled/Disabled State

**JSX Pattern:**
```jsx
<button
  onClick={handleSubmit}
  disabled={!isValid}
  style={{
    background: isValid ? ACCENT : "#ddd",
    cursor: isValid ? "pointer" : "not-allowed",
  }}
>
```

**Flutter Pattern:**
```dart
ElevatedButton(
  onPressed: _isValid ? _handleSubmit : null,  // null = disabled
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    disabledBackgroundColor: Color(0xFFDDDDDD),
  ),
  child: Text('Submit'),
)
```

**Lesson:** Setting `onPressed: null` automatically disables button. Use `disabledBackgroundColor` to control disabled appearance.

---

#### 10. Focus Border Color Change

**JSX Pattern:**
```jsx
<textarea
  onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
  onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
/>
```

**Flutter Pattern:**
```dart
TextField(
  decoration: InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.accent),
    ),
  ),
)
```

**Lesson:** Flutter handles focus state changes declaratively through InputDecoration borders. No need for manual event handlers.

---

#### 11. Chip Selection with Visual Toggle

**JSX Pattern:**
```jsx
<div
  onClick={() => setCategory(cat)}
  style={{
    background: category === cat ? ACCENT : "#fff",
    color: category === cat ? "#fff" : "#555",
    border: `1px solid ${category === cat ? ACCENT : "#e8e8e8"}`,
  }}
>
```

**Flutter Pattern:**
```dart
GestureDetector(
  onTap: () {
    setState(() {
      _selectedCategory = category;
    });
  },
  child: Container(
    decoration: BoxDecoration(
      color: isSelected ? AppColors.accent : Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isSelected ? AppColors.accent : AppColors.border,
      ),
    ),
    child: Text(
      category,
      style: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
    ),
  ),
)
```

**Lesson:** Use GestureDetector for clickable non-button elements. Container handles border/background. Text color must be set separately (not inherited from Container).

---

### Form Handling

#### 12. Form Reset After Submit

**JSX Pattern:**
```jsx
const handleSubmit = () => {
  if (category && message.trim()) {
    onSubmit(feedback);
    // Reset
    setCategory(null);
    setMessage("");
    setAllowContact(false);
    setName("");
    setContact("");
  }
};
```

**Flutter Pattern:**
```dart
void _handleSubmit() {
  if (!_isValid) return;

  // Submit logic...

  setState(() {
    _selectedCategory = null;
    _allowContact = false;
  });
  _messageController.clear();
  _nameController.clear();
  _contactController.clear();
}
```

**Lesson:** Mix of `setState()` for boolean/selection state and `.clear()` for TextEditingControllers. Don't forget to wrap state changes in `setState()`.

---

### Architecture Decisions

#### 13. Page Structure: StatefulWidget vs StatelessWidget

**Decision:** Use StatefulWidget for form pages

**Rationale:**
- Forms have local state (selections, input values)
- Need TextEditingControllers (require disposal)
- Form validation state changes on user input
- Later will add: loading state, error messages, API calls

**When to use StatelessWidget:**
- Display-only pages
- Pages where all state is in Provider/inherited
- Static information pages

---

#### 14. Scaffold + AppBar Pattern

**JSX Pattern:**
```jsx
<div>
  {/* Header */}
  <div style={{ height: 60, borderBottom: "1px solid #f2f2f2" }}>
    <button onClick={onBack}>←</button>
    <div>Share feedback</div>
  </div>
  {/* Content */}
  <div style={{ overflowY: "scroll" }}>...</div>
</div>
```

**Flutter Pattern:**
```dart
Scaffold(
  backgroundColor: AppColors.bgPage,
  appBar: AppBar(
    leading: IconButton(icon: Icon(Icons.arrow_back_ios), ...),
    title: Text('Share feedback'),
    centerTitle: true,
  ),
  body: SafeArea(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(...),
    ),
  ),
)
```

**Lesson:** Flutter's Scaffold + AppBar is more idiomatic than manual header divs. SafeArea handles device notches. SingleChildScrollView replaces fixed-height scroll containers.

**Advantage:** Automatic back button on iOS/Android, system status bar handling, keyboard avoidance.

---

### Comments & Documentation

#### 15. TODO Comments for Backend Integration

**Pattern:**
```dart
// TODO: Add markUserEngaged() call here
Navigator.of(context).pop();

// TODO: Translation key 'feedback_form_title'
title: Text('Share feedback'),

// TODO: Add BuildShip API call here
debugPrint('Feedback submitted: $feedback');
```

**Lesson:** Mark every piece of hardcoded data or missing functionality with TODO comments. Makes it easy to search for what needs to be added during integration steps.

**Organization:**
- Translation keys: `// TODO: Translation key 'key_name'`
- Actions: `// TODO: Add actionName() call`
- API: `// TODO: Add API endpoint call`
- Validation: `// TODO: Add validation error`

---

### What Works Well in This Approach

#### 16. "Chassis First" Advantages

**What we got:**
- ✅ Clean, readable code (no auto-generated cruft)
- ✅ Easy to review and spot issues
- ✅ All UI logic working (form, validation state, conditional rendering)
- ✅ Clear separation: UI (done) vs Backend (TODO)
- ✅ Testable in isolation (can preview UI before adding API)

**Estimated time:**
- JSX → Flutter conversion: ~1 hour
- Review + refinements: ~20 minutes
- Total: ~1.5 hours for UI shell

**vs Alternative (refactor FlutterFlow code):**
- Understanding auto-generated code: ~1 hour
- Untangling widget tree: ~1 hour
- Removing unnecessary complexity: ~1 hour
- Total: ~3 hours, less learning value

---

### What to Watch Out For

#### 17. Flutter-Specific Gotchas

**Memory Leaks:**
- ❌ Forgetting to dispose TextEditingControllers
- ✅ Always add dispose() method

**State Management:**
- ❌ Changing state without setState() (UI won't update)
- ✅ Wrap state changes in setState()

**Context Usage:**
- ❌ Using context after async gap without checking
- ✅ Check `if (!mounted) return;` after async operations

**Color Format:**
- ❌ Using `Color(0xE8751A)` (missing alpha)
- ✅ Use `Color(0xFFE8751A)` (FF = fully opaque)

---

## Summary: Share Feedback Conversion

**Conversion Quality:** ✅ Pixel-perfect (with refinements)

**Code Quality:** ✅ Production-ready as UI shell

**Readability:** ✅ Easy to understand and modify

**Next Steps:** Follow integration guide to add backend functionality

**Key Takeaway:** Starting with clean JSX→Flutter conversion creates a solid foundation that's easy to enhance incrementally. Much better for learning than refactoring complex auto-generated code.

---

## Pages 2 & 3: Contact Us + Missing Place Forms

**Date:** 2026-02-19
**JSX Sources:** `contact_us_form.jsx`, `missing_place_form.jsx`
**Flutter Outputs:** `contact_us_page_from_jsx.dart`, `missing_place_page_from_jsx.dart`
**Complexity:** Simpler than Share Feedback (no chips, no conditional rendering)

### New Lessons Learned

#### 18. Multi-Paragraph Text in JSX

**JSX Pattern:**
```jsx
<p style={{ lineHeight: "20px" }}>
  If we are missing a place, we will be very happy to hear from you.
  <br /><br />
  To make it easier for us to add it sooner, please provide as much information as you can.
</p>
```

**Flutter Pattern:**
```dart
RichText(
  text: const TextSpan(
    style: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
      height: 1.43, // 20px / 14px
    ),
    children: [
      TextSpan(text: 'If we are missing a place...'),
      TextSpan(text: '\n\n'),  // Double line break = paragraph spacing
      TextSpan(text: 'To make it easier for us...'),
    ],
  ),
)
```

**Lesson:** Use RichText with TextSpan children for multi-paragraph text. `\n\n` creates paragraph spacing matching `<br /><br />`.

**Alternative:** Use separate Text widgets, but RichText allows shared styling + translation key management.

---

#### 19. Form Pattern Validated

**Observation across 3 forms:**

All three forms (Share Feedback, Contact Us, Missing Place) follow the same pattern:
1. StatefulWidget with TextEditingControllers
2. Computed `_isValid` getter
3. `_handleSubmit()` with form reset
4. Fixed-height input fields (50px)
5. Same spacing (20px between fields, 24px before button)
6. Same color scheme
7. Same border/focus behavior

**Pattern Recognition:**
- ✅ Simple forms = 3-4 text fields + submit button
- ✅ Complex forms = Add category chips OR conditional fields
- ✅ All follow Scaffold + AppBar + SingleChildScrollView structure

**This confirms:** The "chassis approach" works well. Pattern repeats cleanly across similar pages.

---

#### 20. Code Duplication Opportunity

**Issue:** AppColors class is duplicated in every file:

```dart
// contact_us_page_from_jsx.dart
class AppColors {
  static const Color accent = Color(0xFFE8751A);
  // ...
}

// missing_place_page_from_jsx.dart
class AppColors {
  static const Color accent = Color(0xFFE8751A);
  // ...
}
```

**Solution for production:**
Create `shared/app_theme.dart`:
```dart
class AppColors {
  static const Color accent = Color(0xFFE8751A);
  static const Color bgPage = Color(0xFFFFFFFF);
  // ... all colors
}
```

Then import:
```dart
import '../shared/app_theme.dart';
```

**Lesson:** For now, duplicate for independence (each file is self-contained). During integration, consolidate into shared file.

**Trade-off:** Duplication = easier to review individual files. Shared = DRY but adds dependency.

---

#### 21. Heading + Description Pattern

**JSX Pattern:**
```jsx
<h2>Missing a place?</h2>
<p>Description text...</p>
```

**Flutter Pattern:**
```dart
const Text(
  'Missing a place?',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,  // h2 → 700 weight
  ),
),
const SizedBox(height: 12),
const Text(
  'Description text...',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,  // p → 400 weight
  ),
),
```

**Lesson:** HTML heading tags map to font weight + size in Flutter:
- `<h2>` → fontSize 18, fontWeight w700
- `<p>` → fontSize 14, fontWeight w400

Spacing between heading and description: 12px (in JSX: margin-bottom: 12px)

---

#### 22. Consistent onChanged Pattern

**Pattern emerging:**
```dart
TextField(
  controller: _nameController,
  onChanged: (value) {
    setState(() {}); // Update button state
  },
)
```

**Why needed:** Button enable/disable depends on `_isValid` getter, which checks controller values. `setState()` triggers rebuild → getter recalculates → button updates.

**Lesson:** For simple validation (required fields), use `onChanged: (value) => setState(() {})` on every text field. More concise than tracking each field separately.

**Alternative (more efficient):**
```dart
onChanged: (value) {
  if (mounted) setState(() {});
}
```
Adds safety check for async scenarios.

---

### Summary: Contact Us + Missing Place

**Conversion Time:** ~30 minutes each (patterns already established)

**Code Quality:** ✅ Clean, pixel-perfect, production-ready UI shells

**New Patterns Found:**
- Multi-paragraph text → RichText
- Heading + description spacing
- Confirmed form pattern consistency

**Key Insight:** Once patterns are established (Share Feedback), similar pages convert MUCH faster. The "chassis approach" scales well.

---

### Code Review Fixes Applied

**All Three Pages - Critical Fixes:**

#### 23. Generic Type in State Declaration (Compiler Warning)

**Wrong:**
```dart
class ShareFeedbackPage extends StatefulWidget {
  @override
  State createState() => _ShareFeedbackPageState();  // Missing generic!
}
```

**Correct:**
```dart
class ShareFeedbackPage extends StatefulWidget {
  @override
  State<ShareFeedbackPage> createState() => _ShareFeedbackPageState();
}
```

**Lesson:** Always specify generic type for `createState()`. Without it, framework warnings are suppressed and type safety is reduced.

**Impact:** Won't crash but hides useful error messages during development.

---

#### 24. Code Duplication - AppColors Extracted

**Problem:** AppColors class duplicated in all three files = divergence risk.

**Solution:** Create `shared/app_theme.dart`:
```dart
class AppColors {
  AppColors._();  // Prevent instantiation

  static const Color accent = Color(0xFFE8751A);
  // ... all colors
}
```

**Import in all pages:**
```dart
import '../../shared/app_theme.dart';
```

**Lesson:** Extract shared definitions immediately, even during "chassis" phase. Cost of duplication > cost of creating shared file.

**Why critical:** Changing accent color in one file leaves others silently wrong.

---

#### 25. iOS-Only Back Arrow Icon

**Wrong:**
```dart
Icon(Icons.arrow_back_ios)  // iOS chevron on Android
```

**Better:**
```dart
Icon(Icons.arrow_back_ios_new)  // Better rendering, still iOS-style
```

**Best (platform-adaptive):**
```dart
Icon(Platform.isIOS ? Icons.arrow_back_ios_new : Icons.arrow_back)
```

**Lesson:** `arrow_back_ios_new` has better rendering than `arrow_back_ios`. For production, consider platform-adaptive icons.

**Decision:** Using `arrow_back_ios_new` for consistency across both forms for now. Can make platform-adaptive later.

---

#### 26. Form Reset Pattern - setState Scope

**Wrong (ContactUs, MissingPlace - initial version):**
```dart
// Reset form
_fullNameController.clear();
_contactController.clear();
setState(() {});  // Empty setState just for rebuild
```

**Correct (ShareFeedback pattern):**
```dart
// Reset form
setState(() {
  _selectedCategory = null;
  _allowContact = false;
  _messageController.clear();
  _nameController.clear();
  _contactController.clear();
});
```

**Lesson:** Put ALL state changes inside `setState()`, including controller clears. This ensures atomic updates and correct handling if operation fails mid-function (e.g., API call fails after clearing some controllers).

**Why matters:** If API call fails after clearing controllers outside setState, form may be in inconsistent state.

---

#### 27. Multi-Paragraph Text - RichText vs Column

**Initial approach (MissingPlace):**
```dart
RichText(
  text: TextSpan(
    children: [
      TextSpan(text: 'First paragraph'),
      TextSpan(text: '\n\n'),
      TextSpan(text: 'Second paragraph'),
    ],
  ),
)
```

**Better approach:**
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('First paragraph'),  // TODO: Translation key
    SizedBox(height: 8),
    Text('Second paragraph'),  // TODO: Translation key
  ],
)
```

**Lesson:** Use Column + separate Text widgets for multi-paragraph text. Easier to manage translation keys (one per paragraph) and more flexible for styling.

**Trade-off:** RichText = shared styling, Column = individual translation keys. Column wins for maintainability.

---

#### 28. Spacing Consistency

**Rule established:**
- 8px: Between label and input field
- 8px: Between heading and description
- 20px: Between form fields
- 24px: Before submit button
- 4px: Between label and helper text

**Lesson:** Document spacing rules as you go. Consistency matters for professional feel.

**Applied across all three forms for pixel-perfect consistency.**

---

---

## Major Milestone: Complete Flutter Design System Created

**Date:** 2026-02-19
**Deliverables:** `shared/app_theme.dart` + `DESIGN_SYSTEM_flutter.md`

### What Was Created

#### 29. Comprehensive app_theme.dart

**Complete implementation of journeymate-design-system.md in Flutter:**

**Classes created:**
1. `AppColors` - All 20 colors (primary palette, neutrals, semantic)
2. `AppSpacing` - 8 standard spacing values (4-40px)
3. `AppRadius` - 9 border radius values (8-22px)
4. `AppTypography` - 20 text styles (headings, body, UI elements)
5. `AppInputDecorations` - Reusable input decorations (standard, multiline)
6. `AppButtonStyles` - Reusable button styles (primary, secondary)
7. `AppConstants` - Screen dimensions, heights, durations

**Total:** 60+ predefined design tokens

**Lesson:** Create comprehensive theme file ONCE at project start. Prevents:
- ❌ Hardcoded hex values scattered across files
- ❌ Inconsistent spacing (mixing 8, 10, 12px randomly)
- ❌ Wrong border radii (10px vs 12px for inputs)
- ❌ Duplicated InputDecoration logic in every file

**Benefits:**
- ✅ Single source of truth
- ✅ Immediate design system compliance
- ✅ Easy global changes (update one file)
- ✅ Type-safe constants (IDE autocomplete)

---

#### 30. DESIGN_SYSTEM_flutter.md Reference Document

**Purpose:** Flutter-specific design system reference

**Contents:**
1. Complete color palette with usage rules
2. Spacing scale with common patterns
3. Border radius guide with components
4. Typography scale with examples
5. Reusable UI patterns (form fields, buttons, checkboxes)
6. Page structure templates
7. Decision checklist (before writing any UI)
8. Anti-patterns (what NOT to do)
9. Migration path (JSX → Flutter conversion guide)

**Lesson:** Design decisions should be documented ONCE, then followed religiously.

**Key principle:** "Decisions should be made once and then followed after." - User feedback

**Impact:** Every future page conversion now has clear reference. No more guessing spacing or colors.

---

#### 31. Design System Fixes Required

**What we discovered:** Original three forms had incorrect values

**Corrections needed:**
1. Border radius: Input fields use 12px (not 10px), buttons use 14px (not 12px)
2. Spacing: Need consistent use of design system spacing
3. Colors: Missing GREEN_BG, ORANGE_BG, and other palette colors

**Next step:** Update ShareFeedback, ContactUs, MissingPlace to use new theme

**Lesson:** Better to discover inconsistencies early (3 files) than late (14 files). This is why the user's question was perfect timing.

---

## Design System Adherence Refactoring

**Date:** 2026-02-19 (immediately after creating comprehensive design system)
**Action:** Updated all three existing forms to use design system tokens

### What Was Changed

#### 32. Border Radius Corrections Applied

**Before (wrong):**
```dart
// Input fields
border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),  // ❌ Wrong: should be 12px
)

// Primary buttons
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(12),  // ❌ Wrong: should be 14px
)

// Category chips (ShareFeedback)
borderRadius: BorderRadius.circular(10),  // This one was correct (filter chips)
```

**After (correct):**
```dart
// Input fields
border: OutlineInputBorder(
  borderRadius: BorderRadius.circular(AppRadius.input),  // ✅ 12px
)

// Primary buttons
shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(AppRadius.button),  // ✅ 14px
)

// Category chips
borderRadius: BorderRadius.circular(AppRadius.filter),  // ✅ 10px (explicit reference)
```

**Lesson:** Using `AppRadius.*` constants prevents silent bugs from incorrect hardcoded values. Also makes the purpose clear (`.input`, `.button`, `.filter`).

**Impact:** All three forms now pixel-perfect match the design system specification.

---

#### 33. Spacing Standardization

**Before (hardcoded):**
```dart
const SizedBox(height: 8),
const SizedBox(height: 20),
const SizedBox(height: 24),
const SizedBox(height: 40),
```

**After (semantic):**
```dart
SizedBox(height: AppSpacing.sm),    // 8px - label to input
SizedBox(height: AppSpacing.xl),    // 20px - between fields
SizedBox(height: AppSpacing.xxl),   // 24px - section spacing
SizedBox(height: AppSpacing.huge),  // 40px - before button
```

**Lesson:** Semantic spacing names make intent clear and enable global changes.

**Example:** If design team decides field spacing should be 24px instead of 20px, change ONE constant (`AppSpacing.xl`) instead of finding/replacing "20" across 14 files.

---

#### 34. Typography Standardization

**Before (inline styles):**
```dart
const Text(
  'Share your feedback',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  ),
)

RichText(
  text: const TextSpan(
    text: 'What is your feedback about? ',
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
  ),
)
```

**After (semantic styles):**
```dart
Text(
  'Share your feedback',
  style: AppTypography.sectionHeading,  // 18px, w700
)

RichText(
  text: TextSpan(
    text: 'What is your feedback about? ',
    style: AppTypography.label,  // 14px, w500
  ),
)
```

**Also replaced:**
- Placeholders → `AppTypography.placeholder`
- Helper text → `AppTypography.helper`
- Button text → `AppTypography.button`
- Body text → `AppTypography.bodyRegular`
- Chip text → `AppTypography.chip`

**Lesson:** Using `AppTypography.*` styles ensures consistency AND makes purpose explicit. A section heading looks like a section heading everywhere.

**Bonus:** Can now change all labels globally (e.g., adjust letter spacing) by editing ONE style definition.

---

#### 35. Component Height Standardization

**Before (magic numbers):**
```dart
SizedBox(
  height: 50,  // What is 50? Input height? Button height?
  child: TextField(...),
)

SizedBox(
  width: double.infinity,
  height: 50,  // Same number, different meaning
  child: ElevatedButton(...),
)
```

**After (explicit constants):**
```dart
SizedBox(
  height: AppConstants.inputHeight,  // 50px - explicit purpose
  child: TextField(...),
)

SizedBox(
  width: double.infinity,
  height: AppConstants.buttonHeight,  // 50px - explicit purpose
  child: ElevatedButton(...),
)
```

**Lesson:** Even when values are identical (both 50px), use semantic constants. Makes intent clear and allows independent changes (inputs could become 48px while buttons stay 50px).

---

#### 36. Disabled Button Color Standardization

**Before (hardcoded):**
```dart
style: ElevatedButton.styleFrom(
  disabledBackgroundColor: const Color(0xFFDDDDDD),  // ❌ Hardcoded
)
```

**After (design token):**
```dart
style: ElevatedButton.styleFrom(
  disabledBackgroundColor: AppColors.textDisabled,  // ✅ #BBBBBB from design system
)
```

**Lesson:** The design system defines `textDisabled` as `#BBBBBB`, not `#DDDDDD`. Using the constant caught this discrepancy.

**Impact:** Disabled buttons now match the design system's accessibility guidelines (higher contrast).

---

### Summary: Design System Adherence Refactoring

**Files updated:** 3 (ShareFeedback, ContactUs, MissingPlace)
**Lines changed:** ~100 replacements across all three files
**Time taken:** ~30 minutes (systematic find-replace)

**Changes applied:**
1. ✅ Border radii: 10px → `AppRadius.input` (12px) for all inputs
2. ✅ Border radii: 12px → `AppRadius.button` (14px) for all buttons
3. ✅ Border radii: 10px → `AppRadius.filter` (explicit) for chips
4. ✅ Spacing: All hardcoded values → `AppSpacing.*` constants
5. ✅ Typography: All inline styles → `AppTypography.*` styles
6. ✅ Heights: All `50` → `AppConstants.inputHeight` or `.buttonHeight`
7. ✅ Colors: Disabled button color corrected (#DDDDDD → #BBBBBB)

**Key Principle Validated:** "Decisions should be made once and then followed after."

**Impact:** All three forms now:
- Match design system pixel-perfectly
- Use semantic design tokens (maintainable)
- Are ready as templates for remaining pages

---

## Settings Pages Conversion (Using Design System from Start)

**Date:** 2026-02-19
**Pages:** settings_main, localization, location_sharing
**Approach:** Design tokens from the start - no refactoring needed!

### Pages Converted

#### 37. List-Based Navigation Pattern (settings_main)

**JSX Pattern:**
```jsx
// Reusable SettingsRow component
const SettingsRow = ({ iconPath, label, onClick }) => (
  <div onClick={onClick} style={{ /* styles */ }}>
    <svg>{iconPath}</svg>
    <span>{label}</span>
    <svg>{/* chevron */}</svg>
  </div>
);

// Usage in sections
<SettingsRow
  iconPath="M12 2a10 10 0 100 20..."
  label="Localization"
  onClick={() => onNavigate("localization")}
/>
```

**Flutter Pattern:**
```dart
// Private widget for reusable row
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Color(0xFF666666)),
            SizedBox(width: AppSpacing.md),
            Expanded(child: Text(label, style: ...)),
            Icon(Icons.chevron_right, size: 18),
          ],
        ),
      ),
    );
  }
}
```

**Lesson:** Private widgets (`_WidgetName`) are perfect for page-specific reusable components. Keep them in the same file for simplicity.

**Pattern benefits:**
- Consistent tap targets
- Built-in divider between rows
- Hover effects via InkWell
- Semantic spacing with design tokens

---

#### 38. Section Headers in List Views

**JSX Pattern:**
```jsx
<div style={{ fontSize: 14, fontWeight: 600, padding: "0 20px 8px" }}>
  My JourneyMate
</div>
```

**Flutter Pattern:**
```dart
class _SectionHeader extends StatelessWidget {
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,  // 20px horizontal
        0,
        AppSpacing.xl,
        AppSpacing.sm,  // 8px bottom
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
```

**Lesson:** Section headers get their own widget for consistency. Note the asymmetric padding (horizontal + bottom only).

**Usage in ListView:**
```dart
Column(
  children: [
    _SectionHeader(title: 'My JourneyMate'),
    _SettingsRow(...),
    _SettingsRow(...),
    SizedBox(height: AppSpacing.xxl),  // Section gap
    _SectionHeader(title: 'Reach out'),
    _SettingsRow(...),
  ],
)
```

---

#### 39. Conditional UI State (localization page)

**JSX Pattern:**
```jsx
const [locationEnabled, setLocationEnabled] = useState(false);

// Conditional rendering
<button style={{
  background: locationEnabled ? "transparent" : ACCENT,
  color: locationEnabled ? "#555" : "#fff",
}}>
  {locationEnabled ? "Manage location settings" : "Turn on location sharing"}
</button>
```

**Flutter Pattern:**
```dart
bool _locationEnabled = false;

// Conditional widget selection
_locationEnabled
  ? OutlinedButton(
      onPressed: () { /* navigate to manage */ },
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: BorderSide(color: AppColors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Text('Manage location settings'),
          Icon(Icons.chevron_right),
        ],
      ),
    )
  : ElevatedButton(
      onPressed: () { /* enable location */ },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
      ),
      child: Text('Turn on location sharing'),
    )
```

**Lesson:** When button styling differs significantly (outlined vs elevated), use different button types instead of style overrides.

**When to use:**
- Different button types: Use ternary operator
- Same button type, different props: Use conditional properties

---

#### 40. Status Indicators with Color

**JSX Pattern:**
```jsx
<div style={{
  width: 6,
  height: 6,
  borderRadius: "50%",
  background: locationEnabled ? "#2a9456" : "#c9403a",
}}/>
<span style={{ color: locationEnabled ? "#2a9456" : "#c9403a" }}>
  {locationEnabled ? "Enabled" : "Disabled"}
</span>
```

**Flutter Pattern:**
```dart
Row(
  children: [
    Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _locationEnabled ? AppColors.green : AppColors.red,
      ),
    ),
    SizedBox(width: 6),
    Text(
      _locationEnabled ? 'Enabled' : 'Disabled',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: _locationEnabled ? AppColors.green : AppColors.red,
      ),
    ),
  ],
)
```

**Lesson:** Green = success/enabled, Red = error/disabled. Use design system colors (`AppColors.green`, `AppColors.red`), not hardcoded hex values.

**Pattern used for:**
- Status indicators (enabled/disabled)
- Match status (full/partial/none)
- Open/closed status for businesses

---

#### 41. Centered CTA Page Layout (location_sharing)

**JSX Pattern:**
```jsx
<div style={{ padding: "32px 24px" }}>
  <h2 style={{ textAlign: "center" }}>Turn on location sharing</h2>
  <p style={{ textAlign: "center" }}>Description text...</p>
  <button style={{ width: "100%" }}>Turn on location sharing</button>
  <div style={{ textAlign: "center" }}>Privacy info...</div>
</div>
```

**Flutter Pattern:**
```dart
Padding(
  padding: EdgeInsets.fromLTRB(
    AppSpacing.xxl,  // 24px horizontal
    AppSpacing.xxxl, // 32px top
    AppSpacing.xxl,
    AppSpacing.xxl,  // 24px bottom
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Text('Turn on location sharing', textAlign: TextAlign.center),
      SizedBox(height: AppSpacing.lg),
      Text('Description...', textAlign: TextAlign.center),
      SizedBox(height: AppSpacing.xxl),
      SizedBox(
        width: double.infinity,
        height: AppConstants.buttonHeight,
        child: ElevatedButton(...),
      ),
      SizedBox(height: AppSpacing.xxl),
      Text('Privacy info...', textAlign: TextAlign.center),
    ],
  ),
)
```

**Lesson:** Use `textAlign: TextAlign.center` for centered text, not wrapper widgets. Use `mainAxisAlignment: MainAxisAlignment.start` to prevent vertical centering (content starts at top).

**Pattern for:** Onboarding screens, permission requests, empty states, success screens

---

#### 42. Design Tokens from the Start

**What we did differently:**
Instead of:
1. Write code with hardcoded values
2. Get user feedback about wrong values
3. Refactor everything to use tokens

We did:
1. Write code with design tokens from start
2. Values are correct immediately
3. No refactoring needed

**Example:**
```dart
// ✅ Correct from start
Container(
  padding: EdgeInsets.all(AppSpacing.lg),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.input),  // 12px
    border: Border.all(color: AppColors.border, width: 1.5),
    color: AppColors.bgSurface,
  ),
)
```

**Time saved:**
- ShareFeedback refactoring: 15 minutes
- ContactUs refactoring: 10 minutes
- MissingPlace refactoring: 10 minutes
- **Total saved:** 35 minutes by using tokens from start on 3 new pages

**Lesson:** Up-front investment in design system pays off immediately. Every new page saves refactoring time.

---

#### 43. Placeholder Widgets for Complex Components

**Challenge:** LanguageCurrencyDropdowns component is complex (custom dropdowns, multiple states)

**Solution:** Create placeholder widget that shows basic UI, add TODO for full implementation

**Placeholder Pattern:**
```dart
/// Placeholder for LanguageCurrencyDropdowns component
/// TODO: Implement full dropdown functionality with proper UI
class _LanguageCurrencyPlaceholder extends StatelessWidget {
  final String selectedLanguage;
  final String selectedCurrency;
  // ... callbacks

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Show selected value, non-interactive for now
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.input),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_getLanguageName(selectedLanguage)),
              Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ],
    );
  }

  String _getLanguageName(String code) {
    final languages = {'en': '🇬🇧 English', 'da': '🇩🇰 Dansk', ...};
    return languages[code] ?? languages['en']!;
  }
}
```

**Lesson:** For complex shared components, create simplified placeholder in the page file. Can be extracted to shared file when fully implemented.

**Benefits:**
- Page structure is complete
- Visual layout matches design
- Clear TODO for functionality to add
- Can demo the page without waiting for full implementation

---

### Summary: Settings Pages Batch

**Pages converted:** 3 (settings_main, localization, location_sharing)
**Time taken:** ~45 minutes total (15 minutes each)
**Lines of code:** ~600 lines total

**New patterns discovered:**
1. ✅ List-based navigation with private widgets
2. ✅ Section headers in list views
3. ✅ Conditional UI state (outlined vs elevated buttons)
4. ✅ Status indicators with semantic colors
5. ✅ Centered CTA page layout
6. ✅ Placeholder widgets for complex components

**Design system benefits validated:**
- ✅ No refactoring needed (used tokens from start)
- ✅ Consistent spacing, colors, typography
- ✅ 35 minutes saved compared to refactoring approach

**Code quality:** Production-ready UI shells, all ready for functionality integration

---

## Code Review: Settings Pages - Critical Lessons

**Date:** 2026-02-19 (after initial settings pages conversion)
**Pages reviewed:** settings_main, localization, location_sharing
**Outcome:** Discovered we only partially adopted design system - missed convenience methods

### The Core Problem

**What we did:**
- ✅ Used design system tokens (AppColors, AppSpacing, AppRadius)
- ✅ Replaced hardcoded values with constants
- ❌ **Missed using convenience methods** (AppButtonStyles, AppInputDecorations, AppTypography)
- ❌ **Partially adopted typography** - still had inline TextStyle declarations
- ❌ **Used wrong semantic tokens** - picked closest hex instead of closest meaning

**Why it matters:** Design system has two layers:
1. **Base tokens** (colors, spacing, radius) - we used these ✓
2. **Convenience methods** (button styles, input decorations, typography) - we missed these ✗

---

#### 44. Use Convenience Methods, Not Just Tokens

**Anti-pattern we fell into:**
```dart
// ❌ Wrong: Using tokens but defining button style inline
ElevatedButton(
  onPressed: onPressed,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.input), // Also wrong radius!
    ),
  ),
  child: Text('Submit', style: AppTypography.button),
)
```

**Correct pattern:**
```dart
// ✅ Right: Use the convenience method
ElevatedButton(
  onPressed: onPressed,
  style: AppButtonStyles.primary, // All styling defined once
  child: Text('Submit', style: AppTypography.button),
)
```

**Why convenience methods exist:**
1. **DRY principle** - Define button styling once, use everywhere
2. **Consistency** - Can't accidentally use wrong radius (input vs button)
3. **Maintainability** - Change button style globally by editing one place
4. **Prevents drift** - Can't silently diverge from design system

**Lesson:** The design system provides convenience methods specifically to prevent inline duplication. Using just the base tokens (colors, spacing) is only half the solution.

**Impact:** Every inline `ElevatedButton.styleFrom` is tech debt that should be `AppButtonStyles.primary`.

---

#### 45. Semantic Token Meaning > Hex Value Proximity

**Anti-pattern we fell into:**
```dart
// ❌ Wrong: Picked closest hex value
Icon(icon, color: Color(0xFF666666))  // Original JSX had #666

// Closest hex in design system:
// AppColors.textSecondary = #555555 (difference: #111)
// AppColors.textTertiary = #888888 (difference: #222)

// We should pick textSecondary (#555) since it's closer, right?
```

**Correct thinking:**
```dart
// ✅ Right: Pick closest semantic meaning
Icon(icon, color: AppColors.textTertiary)  // #888

// Why? textTertiary means "de-emphasized UI elements"
// textSecondary means "body text, descriptions"
// Icons in settings rows are de-emphasized, not body text
// Semantic meaning matters more than hex proximity
```

**Lesson:** Design system tokens have semantic meaning. An icon in a settings row is "tertiary" (de-emphasized chrome) not "secondary" (content). Pick the token that matches the semantic role, even if hex value differs more.

**Other examples:**
- `AppColors.divider` for separator lines (not `borderSubtle` for container borders)
- `AppColors.textDisabled` for chevrons (#BBB) - semantically correct even though it's for disabled text

---

#### 46. Border Radius Has Semantic Meaning

**Anti-pattern we fell into:**
```dart
// ❌ Wrong: Used input radius for buttons and cards
ElevatedButton(
  style: ElevatedButton.styleFrom(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.input), // 12px - WRONG!
    ),
  ),
)

Container(  // Status card
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.input), // 12px - WRONG!
  ),
)
```

**Correct pattern:**
```dart
// ✅ Right: Use semantic radius
ElevatedButton(
  style: AppButtonStyles.primary, // Uses AppRadius.button (14px)
)

Container(  // Status card
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadius.card), // 16px - CORRECT!
  ),
)
```

**Radius semantic mapping:**
- `AppRadius.chip` (8px) - Small pills, tags
- `AppRadius.facility` (9px) - Facility/payment icons
- `AppRadius.filter` (10px) - Filter buttons, category chips
- `AppRadius.input` (12px) - Text fields, textareas
- `AppRadius.button` (14px) - Primary/secondary buttons
- `AppRadius.card` (16px) - Cards, containers, status boxes

**Lesson:** Border radius communicates component type. Buttons should look like buttons (14px), not inputs (12px). Cards should look like cards (16px), not inputs (12px).

**Impact:** Using wrong radius makes buttons appear "squarer" than intended and breaks visual hierarchy.

---

#### 47. Typography Tokens Are Non-Negotiable

**Anti-pattern we fell into:**
```dart
// ❌ Wrong: Inline TextStyle even though token exists
Text(
  'Section Title',
  style: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  ),
)
```

**Correct pattern:**
```dart
// ✅ Right: Use typography token
Text(
  'Section Title',
  style: AppTypography.bodyRegular, // 14px, w400, textSecondary
)
```

**When token doesn't exist exactly:**
```dart
// Design needs 14px w600, but only bodyMedium (14px w500) exists

// ✅ Option 1: Use closest token with comment
Text(
  'Section Header',
  style: AppTypography.bodyMedium, // Note: 14px w500, design is w600
)

// ✅ Option 2: Use token + copyWith for critical differences
Text(
  'Section Header',
  style: AppTypography.bodyMedium.copyWith(
    fontWeight: FontWeight.w600, // Design system gap: no token for 14px w600
  ),
)
```

**Lesson:** Always use typography tokens. If exact match doesn't exist, document the gap and use closest token or copyWith. Never use fully inline TextStyle declarations.

**Why it matters:** Typography changes are frequent in design refinement. Using tokens means changing all headings is a one-line change, not a find-replace across 50 files.

---

#### 48. Document Design System Gaps

**What we discovered:**
- 14px w600 (section headers) - no token exists
- 16px w600 (dropdown labels) - no token exists
- 22px w700 (page headings) - sits between sectionHeading (18px) and pageTitle (24px)
- 13px w400 (privacy notes) - bodySmall is 13px w500

**Correct pattern when gap exists:**
```dart
// ✅ Add comment explaining the gap
Text(
  'Section Header',
  // Note: Using bodyMedium (14px w500) - closest token to 14px w600
  // Design system gap: No token exists for 14px w600
  style: AppTypography.bodyMedium,
)
```

**Lesson:** When design system lacks a token, document it with a comment. This creates a record of gaps that can be:
1. Added to design system later
2. Accepted as "close enough" trade-offs
3. Discussed with design team

**Don't silently work around gaps** - document them so they can be addressed systematically.

---

#### 49. Hardcoded Hex Values Are Tech Debt

**Pattern we found in review:**
```dart
// ❌ Found these hardcoded colors
Color(0xFF666666)  // Icon color
Color(0xFFBBBBBB)  // Chevron color
```

**Why it's tech debt:**
1. **No semantic meaning** - What does #666 represent?
2. **Can't change globally** - Have to find-replace across files
3. **Diverges silently** - Other pages might use #666, #888, #555 inconsistently
4. **Breaks design system** - Explicitly listed as anti-pattern

**Correct pattern:**
```dart
// ✅ Always use semantic token
color: AppColors.textTertiary,  // Clear meaning: de-emphasized UI element
color: AppColors.textDisabled,  // Clear meaning: disabled/inactive state
```

**Lesson:** Every hardcoded hex value is a bug waiting to happen. Even if the hex value is "close enough" to a token, use the token for semantic clarity and maintainability.

**Red flag:** If you're writing `Color(0xFF...)` anywhere except in `app_theme.dart`, you're doing it wrong.

---

#### 50. Button Height Consistency Matters

**Issue found in LocalizationPage:**
```dart
// ❌ Wrong: Hardcoded button height
SizedBox(
  height: 48,  // Every other page uses 50 - this is inconsistent!
  child: ElevatedButton(...),
)
```

**Correct pattern:**
```dart
// ✅ Right: Use constant
SizedBox(
  height: AppConstants.buttonHeight,  // 50px everywhere
  child: ElevatedButton(...),
)
```

**Why it matters:** Visual consistency. When buttons on different pages have different heights (48px vs 50px), users notice the inconsistency even if they can't articulate why it feels "off".

**Lesson:** Even 2px differences matter for visual polish. Use constants for component dimensions so consistency is automatic.

---

#### 51. The Two-Layer Design System Adoption

**What we learned:** Design system has two layers that must both be adopted:

**Layer 1: Base Tokens** (we did this ✓)
- `AppColors.*` - Color values
- `AppSpacing.*` - Spacing scale
- `AppRadius.*` - Border radii
- `AppTypography.*` - Text styles

**Layer 2: Convenience Methods** (we missed this ✗)
- `AppButtonStyles.primary` - Complete button styling
- `AppButtonStyles.secondary` - Complete outlined button styling
- `AppInputDecorations.standard()` - Complete input decoration
- `AppInputDecorations.multiline()` - Complete textarea decoration

**Lesson:** Using Layer 1 without Layer 2 is incomplete adoption. You still get duplication (inline `styleFrom` repeated everywhere) and inconsistency (wrong radius for buttons).

**Complete adoption means:**
- ✅ Zero inline `ElevatedButton.styleFrom` declarations
- ✅ Zero inline `OutlinedButton.styleFrom` declarations
- ✅ Zero inline `InputDecoration` with full decoration properties
- ✅ Zero inline `TextStyle` with fontSize/fontWeight/color
- ✅ Zero hardcoded hex values
- ✅ Zero hardcoded spacing/radius magic numbers

---

### Code Review Impact

**Files fixed:** 3 (settings_main, localization, location_sharing)
**Lines changed:** ~60 replacements
**Time to fix:** ~20 minutes

**Issues corrected:**
1. ✅ Button radius: 12px → 14px (all buttons)
2. ✅ Card radius: 12px → 16px (status card)
3. ✅ Button styles: inline → `AppButtonStyles.primary`
4. ✅ Hardcoded colors: #666, #BBB → semantic tokens
5. ✅ Button height: 48px → 50px (consistency)
6. ✅ Divider color: `borderSubtle` → `divider`
7. ✅ Typography: inline TextStyle → AppTypography tokens
8. ✅ Spacing: hardcoded 10 → AppSpacing.sm
9. ✅ Design gaps documented with comments

**Key insight:** Writing code that "looks like it follows the design system" (uses some tokens) is not the same as actually following it (uses tokens + convenience methods).

**Preventive checklist for future pages:**
- [ ] Zero inline `styleFrom` declarations
- [ ] Zero hardcoded hex colors
- [ ] Zero hardcoded spacing/radius numbers
- [ ] Zero inline TextStyle with fontSize/fontWeight
- [ ] All buttons use AppButtonStyles.*
- [ ] All inputs use AppInputDecorations.*
- [ ] All text uses AppTypography.*
- [ ] Design system gaps documented with comments

---

## Next Steps: Welcome Page & App Settings Flow

**Remaining pages:**
1. Welcome page (complex: multiple paths, state detection)
2. App settings initiate flow (onboarding sequence)

**After that:** Move to core app pages (search, business profile, menu, gallery)

**Approach for future pages:** Apply preventive checklist to avoid repeat code review.

---

**Last Updated:** 2026-02-19
**Pages Converted:** 7/14 (Share Feedback, Contact Us, Missing Place, Settings Main, Localization, Location Sharing, Welcome)
**Total Lessons:** 58
**Code Review Iterations:** 3 (forms batch + settings batch + Layer 2 InputDecorations adoption)
**Design System:** ✅ Complete (app_theme.dart + DESIGN_SYSTEM_flutter.md)
**Design System Adoption:** ⚠️ Partial (one design system gap identified: accent-outlined button)

---

## Lessons from Code Review #3: Layer 2 Input Decorations

After fixing buttons and typography, a comprehensive review revealed that **none of the form pages** were using `AppInputDecorations` convenience methods. Every `TextField` still had inline `InputDecoration` with 15-20 lines of repetitive border definitions.

### 52. AppInputDecorations Migration Pattern

**The Anti-Pattern:**
```dart
TextField(
  controller: _nameController,
  decoration: InputDecoration(
    hintText: 'Enter your name',
    hintStyle: AppTypography.placeholder,
    filled: true,
    fillColor: AppColors.bgInput,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.input),
      borderSide: const BorderSide(color: AppColors.accent),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
  ),
)
```

**Why It's Wrong:**
- 15 lines of repetitive code per text field
- Violates DRY principle - every form page duplicates the same border logic
- Makes design changes difficult (would need to update every field individually)
- Ignores the convenience methods explicitly provided for this purpose

**The Correct Pattern:**
```dart
// Single-line text field
TextField(
  controller: _nameController,
  decoration: AppInputDecorations.standard(
    hintText: 'Enter your name',
  ),
)

// Multiline textarea
TextField(
  controller: _messageController,
  maxLines: 6,
  decoration: AppInputDecorations.multiline(
    hintText: 'Type your message...',
  ),
)
```

**Why It's Correct:**
- Reduces 15 lines to 3 lines per field
- All border styling comes from app_theme.dart - single source of truth
- If design changes (e.g., border color, radius, focus style), update once in app_theme.dart, all fields update
- Semantic clarity - `AppInputDecorations.standard()` communicates intent better than inline repetition

**Migration Checklist:**
- [ ] All single-line TextFields use `AppInputDecorations.standard()`
- [ ] All multiline TextFields use `AppInputDecorations.multiline()`
- [ ] Only hintText parameter passed (other params default correctly)
- [ ] No inline `InputDecoration` with full decoration properties

**Impact:** This affected **all three form pages** (ShareFeedback, MissingPlace, ContactUs). Each page had 3-4 text fields with inline decorations. Total lines removed: ~200+.

---

### 53. AppButtonStyles.primary Already Includes Disabled Styling

**The Misunderstanding:**

Form pages need buttons that:
- Are orange when enabled
- Are gray when disabled (form invalid)

Because of this, all three form pages used inline `ElevatedButton.styleFrom`:

```dart
ElevatedButton(
  onPressed: _isValid ? _handleSubmit : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.accent,
    disabledBackgroundColor: AppColors.textDisabled,  // "We need this!"
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    ),
  ),
  child: Text('Submit'),
)
```

**Why This Was Wrong:**

The assumption was that `AppButtonStyles.primary` doesn't include disabled styling, so inline `styleFrom` was necessary.

**The Truth:**

```dart
// From app_theme.dart line 418-428
static ButtonStyle primary = ElevatedButton.styleFrom(
  backgroundColor: AppColors.accent,
  disabledBackgroundColor: AppColors.textDisabled,  // ✅ Already included!
  foregroundColor: Colors.white,
  textStyle: AppTypography.button,
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.button),
  ),
  elevation: 0,
);
```

**The disabled styling was always there.** Form pages could have used `AppButtonStyles.primary` from day one.

**The Correct Pattern:**

```dart
ElevatedButton(
  onPressed: _isValid ? _handleSubmit : null,
  style: AppButtonStyles.primary,  // ✅ That's it. Disabled styling included.
  child: Text('Submit', style: AppTypography.button),
)
```

**Key Lesson:**

Before deciding you "need" inline styling because "the convenience method doesn't support X", **verify by reading the convenience method's implementation**. The thing you need is probably already there.

**When inline styling IS justified:**
- You need something genuinely custom that no convenience method provides
- Document why with a comment explaining the gap

**When it's NOT justified:**
- "I need disabled styling" → check AppButtonStyles.primary source
- "I need specific radius" → check if the convenience method already has it
- "I need specific padding" → check defaults before overriding

---

### 54. Resolve AppSpacing Before Submit Button Ambiguity

**The Problem:**

The design system contained a contradiction:

- **Section 2 spacing table:** "24px (xxl) before submit button"
- **Section 8 Standard Form Page pattern:** Shows `AppSpacing.huge` (40px) before button in example code

**Result:** Three pages had three different interpretations:
- ShareFeedbackPage: `AppSpacing.huge` (40px) ✅
- MissingPlacePage: `AppSpacing.xxl` (24px) ❌
- ContactUsPage: `AppSpacing.xxl` (24px) ❌

**The Resolution:**

After reviewing visual hierarchy and FlutterFlow screenshots, the correct spacing is **40px (AppSpacing.huge)**.

**Why 40px Is Correct:**
1. **Visual hierarchy:** Submit button is the page's primary action - it needs significant breathing room above it to stand out
2. **FlutterFlow reference:** Original designs use 40px spacing before submit buttons
3. **Standard Form Page pattern:** The example in section 8 is correct; the table in section 2 was an error

**Canonical Pattern:**

```dart
// Last form field
TextField(...),
SizedBox(height: AppSpacing.xl),  // 20px between fields

// ... more fields ...

// Final spacing before button
SizedBox(height: AppSpacing.huge),  // ✅ 40px before submit button

// Submit button
SizedBox(
  width: double.infinity,
  height: AppConstants.buttonHeight,
  child: ElevatedButton(
    onPressed: _isValid ? _handleSubmit : null,
    style: AppButtonStyles.primary,
    child: Text('Submit', style: AppTypography.button),
  ),
),
```

**When to use AppSpacing.huge (40px):**
- Before primary action buttons on form pages
- Before CTA buttons on landing/onboarding pages
- Any time you need strong visual separation before the page's main action

**When to use AppSpacing.xxl (24px):**
- Between sections within the form
- After section headings before first field
- Between field groups

**Impact:** MissingPlacePage and ContactUsPage had incorrect 24px spacing. Fixed to 40px for consistency.

---

## Lessons from Welcome Page Conversion

### 55. Accent-Outlined Button Pattern (Design System Gap)

**The Pattern:**

Welcome Page introduces a new button variant: outlined button with **orange** border and text, as opposed to the standard grey outlined secondary button.

**JSX Design:**
```jsx
<button
  style={{
    background: "transparent",
    color: ACCENT,           // Orange text
    border: `2px solid ${ACCENT}`,  // Orange border
    borderRadius: 12,
  }}
>
  Fortsæt på dansk
</button>
```

**Current Design System State:**

`AppButtonStyles.secondary` provides outlined buttons, but uses **grey** (`AppColors.border`) for both border and text:
```dart
static ButtonStyle secondary = OutlinedButton.styleFrom(
  foregroundColor: AppColors.textPrimary,
  side: BorderSide(color: AppColors.border, width: 1.5),
  // ...
);
```

**The Gap:**

No convenience method exists for **accent-colored outlined buttons**. The design requires orange border + orange text, which is semantically different from the grey secondary style.

**Approved Interim Pattern:**

Until `AppButtonStyles.accentOutlined` is added to the design system, use inline `styleFrom` **with a comment documenting the gap**:

```dart
OutlinedButton(
  // Note: Design system gap - accent-outlined button pattern
  // AppButtonStyles.secondary uses grey border/text (AppColors.border)
  // This button needs orange border/text (AppColors.accent)
  // TODO: Add AppButtonStyles.accentOutlined to design system
  style: OutlinedButton.styleFrom(
    foregroundColor: AppColors.accent,
    side: BorderSide(
      color: AppColors.accent,
      width: 2,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    ),
  ),
  child: Text(
    'Fortsæt på dansk',
    style: AppTypography.button.copyWith(
      color: AppColors.accent, // Override white to orange
    ),
  ),
)
```

**Key Points:**
- Comment explains **why** inline `styleFrom` is acceptable here (design system gap)
- TODO flags that this should be standardized
- Uses design tokens throughout (AppColors.accent, AppRadius.button, AppTypography.button)
- Prevents future pages from each solving this differently

**Long-term Solution:**

Add to `app_theme.dart`:
```dart
/// Accent outlined button - Orange border and text
static ButtonStyle accentOutlined = OutlinedButton.styleFrom(
  foregroundColor: AppColors.accent,
  side: BorderSide(color: AppColors.accent, width: 2),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.button),
  ),
  elevation: 0,
);
```

Then all pages can use: `style: AppButtonStyles.accentOutlined`

---

### 56. ConstrainedBox for JSX maxWidth Pattern

**JSX Pattern:**
```jsx
<button style={{ maxWidth: 280, width: "100%" }}>
  Continue
</button>
```

**Flutter Equivalent:**
```dart
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 280),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: 50, child: ElevatedButton(...)),
    ],
  ),
)
```

**Why This Works:**
- `ConstrainedBox` limits maximum width to 280px
- `crossAxisAlignment: CrossAxisAlignment.stretch` makes children fill available width
- Button expands to fill `ConstrainedBox`, but never exceeds 280px
- On wider screens, content stays centered and constrained

**Anti-pattern:**
```dart
// DON'T hardcode width on button directly
SizedBox(
  width: 280, // Doesn't adapt to smaller screens
  child: ElevatedButton(...),
)
```

**When to Use:**
- Centered content that should be constrained on wide screens
- JSX `maxWidth` + `width: "100%"` patterns
- Responsive layouts where content should grow but not exceed limit

---

### 57. Centered Full-Screen Layout Pattern

**JSX Pattern:**
```jsx
<div style={{
  display: "flex",
  flexDirection: "column",
  alignItems: "center",
  justifyContent: "center",
  height: 844,
}}>
  {/* Content */}
</div>
```

**Flutter Equivalent:**
```dart
Scaffold(
  body: SafeArea(
    child: Center(  // Vertical + horizontal centering
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Content
          ],
        ),
      ),
    ),
  ),
)
```

**Key Structure:**
1. `SafeArea` - Respects device notches/home indicators
2. `Center` - Provides vertical and horizontal centering
3. `Padding` - Adds horizontal margins
4. `Column` with `mainAxisAlignment: MainAxisAlignment.center` - Ensures content is centered even when shorter than screen

**When to Use:**
- Onboarding/welcome screens
- Full-screen CTAs
- Centered splash/intro content

**When NOT to Use:**
- Pages with scrollable content (use `SingleChildScrollView` instead)
- Pages with app bars or bottom navigation (breaks layout)
- Dense information pages (content should be top-aligned)

---

### 58. Design System Gap: 48px Spacing

**Discovered in:** Welcome Page

**JSX Value:** 48px margin between description and buttons

**Design System Tokens:**
- `AppSpacing.huge` = 40px (closest)
- `AppSpacing.xxxl` = 32px (too small)

**Gap:** No token exists for 48px spacing.

**Resolution:** Use hardcoded value with comment:
```dart
// Note: 48px spacing from JSX - design gap
// No token exists (huge=40px, xxxl=32px)
SizedBox(height: 48),
```

**When Documented Gaps Are Acceptable:**

If a spacing value:
1. Appears in JSX design
2. Has no matching token
3. Is documented with a comment explaining the gap
4. Is only used in one specific context

Then hardcoding with a comment is correct.

**Not Acceptable:**
```dart
SizedBox(height: 48),  // No comment - why 48? Why not use token?
```

**Design System Action Item:** Evaluate if 48px should be added as a token (e.g., `AppSpacing.jumbo`). If this pattern recurs across multiple pages, standardize it.

---

## Lessons from Business Profile Page Conversion

**Date:** 2026-02-19
**JSX Source:** `pages/business/business_profile.jsx`
**Flutter Output:** `business_profile_page_from_jsx.dart`
**Lines:** 1,737 Flutter / 603 JSX
**Helper widgets:** 12 private widget classes

---

### 59. Horizontal Scroller Right-Edge Bleed Pattern

**The JSX Pattern:**
```jsx
<div style={{
  display: "flex",
  overflowX: "auto",
  marginRight: -24,   // cancel parent's right padding
  paddingRight: 24,   // restore it inside scroll container
  paddingBottom: 2,
}}>
  {/* scrollable pills */}
</div>
```

**What it does:** Allows scrollable content to bleed past the parent container's right padding to the physical screen edge. The last pill scrolls fully off-screen rather than stopping at the content gutter. This is a deliberate design choice that communicates "there is more content to the right."

**The Flutter Anti-Pattern:**
```dart
// ❌ Wrong: symmetric padding clips the trailing item
Padding(
  padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
  child: SizedBox(
    height: 36,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      ...
    ),
  ),
),
```

**The Flutter Correct Pattern:**
```dart
// ✅ Right: leading padding only — trailing side bleeds to screen edge
SizedBox(
  height: 36,
  child: ListView.separated(
    scrollDirection: Axis.horizontal,
    // Note: Leading padding only — JSX negative-margin bleed pattern
    // Trailing items scroll to screen edge, not content gutter
    padding: EdgeInsets.only(left: AppSpacing.xxl),
    itemCount: actions.length,
    separatorBuilder: (_, __) => SizedBox(width: AppSpacing.sm),
    itemBuilder: (context, index) { ... },
  ),
),
```

**When This Applies:**
- Any horizontal scroller inside a padded parent container
- Quick action pills, category chips, gallery tabs when in scroll mode
- Any JSX with `overflowX: "auto"` on a row inside a padded parent

**When It Doesn't Apply:**
- Full-width rows without parent horizontal padding
- Rows where all items are always visible (no scrolling needed)

---

### 60. Conditional Rendering From Data Flags Must Be Preserved

**The Pattern in JSX:**
```jsx
{f.i && (
  <svg width="12" height="12" ...>
    <circle cx="12" cy="12" r="10"/>
    <path d="M12 16v-4M12 8h.01"/>
  </svg>
)}
```

The `f.i` property is a boolean flag on each facility object indicating whether that facility has detail info available. Only facilities with info should show the info icon — the icon communicates "tap for details."

**The Anti-Pattern:**
```dart
// ❌ Wrong: always renders icon, creates false affordance
Row(
  children: [
    Text(facility),
    SizedBox(width: 5),
    Icon(Icons.info_outline, size: 12),  // always visible
  ],
)
```

**The Correct Pattern:**
```dart
// ✅ Right: conditional per data flag
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Text(facility),
    // Note: JSX only shows info icon when f.i is true
    // TODO: When real data is wired, pass hasInfo flag through to widget
    if (facilityHasInfo) ...[
      SizedBox(width: 5),
      Icon(Icons.info_outline, size: 12, ...),
    ],
  ],
)
```

**Why It Matters:**
Showing a tappable icon on a non-tappable item is a false affordance. Users will tap it, nothing will happen, and they'll be confused. The visual presence of UI controls communicates interactivity — that signal must only appear when the interaction is available.

**When Data Models Are Simplified:**
When the Flutter shell uses `List<String>` instead of the full data model, add a TODO at the widget level noting that the boolean flag must be carried through when real data is wired:

```dart
// TODO: facilities currently List<String> — extend to carry f.i flag
// JSX: only facilities with f.i=true show info icon and respond to tap
```

---

### 61. Placeholder Data Is a Different Category Than Design Gaps

**The Problem:**

Gallery placeholder color arrays, mock restaurant data, and other explicitly temporary values are fundamentally different from design system gaps. Treating them the same way creates noise — someone reading `// Design gap: no token` on a placeholder color block will wonder why no token was added, when the entire block will disappear when real images load.

**Two Categories, Two Comment Styles:**

```dart
// ✅ Design gap comment — token system issue that needs resolution
// Note: #ececec for inner-panel row separators
// Design gap: sits between AppColors.divider (#f2f2f2) and AppColors.border (#e8e8e8)
// No exact token — document for design system review
color: Color(0xFFECECEC),

// ✅ Placeholder comment — temporary data that will be replaced entirely
// PLACEHOLDER: replace with real network images from gallery API
// These colors are stand-ins for the 6-image grid per tab
final Map<String, List<Color>> placeholderColors = {
  'Mad': [Color(0xFFF0DCC8), Color(0xFFE8C8B8), ...],
  ...
};
```

**The Key Distinction:**
- **Design gap:** A real design value (color, size, weight) exists in the JSX but has no equivalent token. The value should eventually be in `app_theme.dart` or accepted as an approved exception.
- **Placeholder:** The entire data structure will be replaced with real content. The specific values are irrelevant — they exist only to make the UI visible during development.

Without this distinction, it becomes impossible to know which `Color(0xFF...)` values in the codebase need token resolution and which ones will vanish when the page is connected to real data.

---

### 62. Dead Code Parameters Must Be Wired or Removed

**Discovered in:** `_FilterSection.isLast` parameter

```dart
class _FilterSection extends StatelessWidget {
  final bool isLast;

  const _FilterSection({
    // ...
    this.isLast = false,  // parameter declared
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      // isLast is never referenced here — dead code
    );
  }
}
```

The `isLast` flag was presumably added to control whether the section gets bottom padding/spacing, but no logic in `build()` references it. One call site passes `isLast: true` (the allergens section) which silently has no effect.

**The Two Acceptable States:**

Either the parameter is implemented:
```dart
// In build():
if (!isLast) SizedBox(height: 14),  // spacing between sections
```

Or it is removed entirely:
```dart
// Remove from constructor and all call sites
```

**Why It Matters:**
A dead parameter with a `true` call site implies intent that was never followed through. When another developer reads `isLast: true`, they will expect it to do something. Finding that it doesn't produces confusion and erodes trust in the codebase.

**Connection to Lesson (List-Boundary Parameters):**
Dead code on a boundary parameter is arguably worse than a missing boundary check — at least a missing check is a visible omission. A parameter that appears to be set but silently does nothing is an invisible bug.

---

### 63. Design Gap Comments Must Be Consistent at Every Usage Site

**Discovered in:** `Color(0xFF444444)` in `_QuickActionButtons` vs `_OpeningHoursContactSection`

```dart
// In _QuickActionButtons — gap is documented:
// Note: #444 for text - darker than textSecondary (#555)
// Design gap: No exact token
style: AppTypography.bodySmall.copyWith(color: Color(0xFF444444)),

// In _OpeningHoursContactSection hours rows — same value, no comment:
style: AppTypography.bodySmall.copyWith(
  fontSize: 13.5,
  color: Color(0xFF444444),  // ← no comment anywhere
),
```

**The Rule:**
If a value requires a gap comment in one location, it requires the same comment at every location it appears. A reader reviewing the hours section alone has no way to know this value was deliberate. They may "fix" it to a token, which could be correct or incorrect — but they can't tell.

**Practical Pattern:**
When you copy a hardcoded value from one widget to another, also copy the gap comment. If the comment would feel redundant, that is a signal the value should instead be extracted to a well-named constant:

```dart
// Within the file, define once at top:
// Note: #444 appears in both quick actions and hours text — design gap, no exact token
// Sits between textPrimary (#0f0f0f) and textSecondary (#555). Pending token addition.
static const Color _textDark = Color(0xFF444444);
```

---

### 64. Section Padding Must Be Read From JSX Verbatim

**Discovered in:** `_FacilitiesSection` and `_PaymentSection`

JSX shorthand `padding: "16px 24px"` means **16px top/bottom, 24px left/right** — the CSS two-value shorthand is `vertical horizontal`. This produced two incorrect Flutter translations:

```dart
// _FacilitiesSection — wrong
padding: EdgeInsets.all(AppSpacing.lg),  // 16px all sides — collapses h to 16

// _PaymentSection — wrong
padding: EdgeInsets.all(AppSpacing.xxl),  // 24px all sides — expands v to 24
```

Both sections end up with incorrect vertical spacing against their dividers.

**The Correct Translation:**
```dart
// JSX: padding: "16px 24px" → Flutter:
padding: EdgeInsets.symmetric(
  vertical: AppSpacing.lg,   // 16px
  horizontal: AppSpacing.xxl, // 24px
),
```

**CSS Padding Shorthand Reference:**
- 1 value: all sides
- 2 values: `vertical horizontal`
- 3 values: `top horizontal bottom`
- 4 values: `top right bottom left`

Misreading two-value shorthand as "the same value applied everywhere" is a common error. Always expand JSX padding shorthand explicitly before translating.

---

### 65. Semantic Radius Must Override JSX Numeric Values for Containers

**Discovered in:** `_MatchCard` using `AppRadius.input` (12px) for a card container

JSX specifies `borderRadius: 12` on the match card. `AppRadius.input` happens to be 12px. But `AppRadius.input` is semantically for text fields and textareas — not card containers. The match card is a card-shaped container. Per lesson 46, `AppRadius.card` (16px) is the correct semantic token for cards.

**The Principle:**
When a JSX numeric value coincidentally matches an `AppRadius` token that carries the wrong semantic meaning, prefer the semantically correct token and document the numeric deviation:

```dart
// Note: JSX uses borderRadius 12px — matches AppRadius.input numerically
// but match card is a container, not an input field
// Using AppRadius.card (16px) for correct semantic meaning
// TODO: Confirm 12px vs 16px with design team
borderRadius: BorderRadius.circular(AppRadius.card),
```

**The Anti-Pattern:**
```dart
// ❌ Wrong: picked token by numeric proximity, ignoring semantic meaning
borderRadius: BorderRadius.circular(AppRadius.input),  // 12px but wrong type
```

This extends lesson 46 (border radius has semantic meaning) to cover the case where the JSX numeric value happens to match the wrong token. Semantic correctness takes priority over numeric fidelity — and the deviation should always be documented.

---

**Last Updated:** 2026-02-19
**Pages Converted:** 14/14 (all pages)
**Total Lessons:** 65
**Code Review Iterations:** 4
**Design System Adoption:** Layer 1 complete, Layer 2 partial (form inputs)

## Lessons from Search Page Conversion

**Date:** 2026-02-19
**JSX Source:** `pages/search/search.jsx`, `pages/search/search_no_results.jsx`
**Flutter Output:** `search_page_from_jsx.dart`
**Lines:** 2,326 Flutter / 836 JSX (combined)
**Helper widgets:** 10 private widget classes

---

### 66. `Opacity` Widget for JSX `opacity` Property

**The Bug:**
```dart
// ❌ Compile error — Container has no opacity parameter
Container(
  opacity: closed ? 0.5 : 1.0,
  child: ...,
)
```

`Container` does not have an `opacity` parameter in Flutter. This fails to compile. The JSX `opacity: 0.5` on any container element translates to wrapping with the `Opacity` widget:

```dart
// ✅ Correct
Opacity(
  opacity: closed ? 0.5 : 1.0,
  child: Container(...),
)
```

**Notes:**
- `Opacity` is expensive for animated values — prefer `AnimatedOpacity` or `FadeTransition` if the opacity changes dynamically
- For static conditional states (open/closed restaurant, disabled items) `Opacity` is fine
- `ColorFiltered` is an alternative but `Opacity` is the direct translation
- Never look for `opacity:` as a named parameter on `Container`, `Padding`, `DecoratedBox`, or similar layout widgets — it does not exist on any of them

---

### 67. Stop-Propagation Pattern for Nested Interactive Zones

**The JSX Pattern:**
```jsx
<div onClick={() => setExpanded(!expanded)}>
  {/* ... */}
  <button onClick={(e) => { e.stopPropagation(); onSelect(r); }}>
    Se mere →
  </button>
</div>
```

`e.stopPropagation()` prevents the child button click from bubbling up to the parent card's click handler. Without it, tapping the button would toggle expansion AND navigate simultaneously.

**Flutter Has No Direct Equivalent**

In Flutter, tap events from `InkWell`/`GestureDetector` bubble up through the widget tree. A button inside an `InkWell`-wrapped container will trigger both handlers unless explicitly blocked.

**The Flutter Fix — Use `HitTestBehavior.opaque` on the child:**
```dart
// Outer card tap — toggles expand
InkWell(
  onTap: () => setState(() => _expanded = !_expanded),
  child: Container(
    child: Column(
      children: [
        // ... card content ...
        
        // "Se mere" button — navigates without collapsing card
        GestureDetector(
          behavior: HitTestBehavior.opaque,  // Consumes gesture, blocks bubbling
          onTap: () => widget.onTap(),
          child: Container(
            // Style as button
          ),
        ),
      ],
    ),
  ),
)
```

**Alternative — Restructure so zones don't overlap:**
Only wrap the non-button parts of the card in the outer `InkWell`. Place the action button as a sibling to the `InkWell`, not inside it.

**When to Look for This:**
- Any JSX with `e.stopPropagation()` or `e.preventDefault()` on a child element
- Cards with inline CTAs (expandable cards, list items with secondary actions)
- Any nested clickable element inside a larger clickable area

Always check for stop-propagation when translating nested interactive elements. Missing it produces silent behavioral bugs where both handlers fire.

---

### 68. Widgets Should Not Embed `Expanded` or `Flexible`

**The Anti-Pattern:**
```dart
// ❌ Wrong: _FilterButton always returns Expanded
class _FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(   // ← crashes if parent isn't Row/Column/Flex
      child: InkWell(...),
    );
  }
}
```

`Expanded`, `Flexible`, and `Spacer` are layout directives that only function as direct children of `Row`, `Column`, or `Flex`. Embedding one inside a widget's `build()` method means the widget will throw a runtime exception when used in any other parent context (`Stack`, `Center`, `Padding`, etc.).

**The Correct Pattern — `Expanded` belongs at the call site:**
```dart
// ✅ Correct: Expanded at call site, widget stays portable
Row(
  children: [
    Expanded(child: _FilterButton(label: 'Lokation', ...)),
    SizedBox(width: 8),
    Expanded(child: _FilterButton(label: 'Type', ...)),
    SizedBox(width: 8),
    Expanded(child: _FilterButton(label: 'Behov', ...)),
  ],
)

// _FilterButton returns its own InkWell/Container only
class _FilterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(...);  // Portable — works in any parent
  }
}
```

**Why This Happens:**
When a widget is always used in a `Row` with equal-width distribution, it's tempting to embed `Expanded` to avoid repeating it at every call site. Resist this — the widget's usefulness depends on it not making assumptions about its parent's layout.

**The Rule:**
A widget's `build()` may only contain layout-directive widgets (`Expanded`, `Flexible`, `Spacer`) if the widget itself is explicitly designed and documented as a `Row`/`Column` child — which is an unusual and specialized case. In practice: never.

---

**Last Updated:** 2026-02-19
**Pages Converted:** 15/15 (all pages, including search page)
**Total Lessons:** 68
**Code Review Iterations:** 5
**Critical Bugs Found This Session:** 2 (compile error, stop-propagation)
