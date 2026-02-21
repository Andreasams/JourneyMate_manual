# Phase 7 Batch 4 Implementation Plan
## Package & Gallery Widgets (3 widgets)

**Created:** 2026-02-21
**Session:** Batch 4 of Phase 7 Preliminary Task
**Progress:** 6/29 widgets complete before this batch
**Batch Focus:** Gallery and package navigation widgets

---

## 1. Widget Specifications

### Widget 1: PackageBottomSheet (package_navigation_sheet)

**Type:** StatefulWidget (nested Navigator pattern)
**Expected Lines:** ~1,255 lines (FlutterFlow source)
**Complexity:** ⭐⭐⭐ Medium-High
**Riverpod Usage:** ConsumerStatefulWidget (needs translationsCacheProvider, localizationProvider, businessProvider)

**Props/Parameters:**
```dart
final dynamic normalizedMenuData;  // Full menu data from businessProvider
final int packageId;                // Which package to display
final String businessName;          // For disclaimer text
```

**Provider Dependencies:**
- `businessProvider` - read menu data
- `localizationProvider` - currency conversion (currencyCode, exchangeRate)
- `translationsCacheProvider` - dynamic translations for UI text (td helper)

**Key Features:**
- Two-level nested navigation: Package overview → Item detail view
- Platform-specific transitions (iOS: CupertinoPageRoute, Android: PageRouteBuilder)
- Custom Navigator with GlobalKey for nested routing
- DraggableScrollableSheet for bottom sheet
- Image display with fallback states
- Premium upcharge display
- Expandable "Information source" accordion section
- Calls PackageCoursesDisplay widget internally

**Translation Keys:**
- `error_package_not_found` (dynamic from td)
- `info_header_additional` (dynamic from td)
- `info_header_dietary` (dynamic from td)
- `info_header_allergens` (dynamic from td)
- `info_header_source` (dynamic from td)
- `info_disclaimer_business` (dynamic from td, has [businessName] placeholder)
- `info_disclaimer_journeymate` (dynamic from td)

**Design Token Mappings:**
| FlutterFlow | AppColors/AppSpacing | Notes |
|-------------|---------------------|-------|
| Color(0xFF14181B) | AppColors.textPrimary | Swipe bar, close/back icons |
| Color(0xFFF2F3F5) | AppColors.bgSurface | Close/back button backgrounds |
| Color(0xFFE9874B) | AppColors.accent | Premium price badges |
| 20.0 | AppRadius.bottomSheet | Top border radius |
| 28.0 | AppSpacing.xxl + 4 | Horizontal content padding |
| 12.0 | AppSpacing.md | Various spacing |

**Known Challenges:**
- Nested Navigator inside bottom sheet (requires GlobalKey management)
- Platform-specific transition builders (iOS CupertinoPageRoute vs Android PageRouteBuilder)
- Coordinate with PackageCoursesDisplay widget (must be implemented first)
- Slate transition animations (slide-in from right, slide-out with parallax)

---

### Widget 2: PackageCoursesDisplay

**Type:** StatefulWidget
**Expected Lines:** ~571 lines (FlutterFlow source)
**Complexity:** ⭐⭐⭐ Medium
**Riverpod Usage:** ConsumerStatefulWidget (needs translationsCacheProvider, localizationProvider)

**Props/Parameters:**
```dart
final double height;                    // Fixed height constraint
final dynamic menuData;                 // Menu data structure
final int packageId;                    // Target package ID
final Future Function(dynamic)? onItemTap;  // Callback for item tap
```

**Provider Dependencies:**
- `localizationProvider` - currency conversion
- `translationsCacheProvider` - UI text (td helper)

**Key Features:**
- Hierarchical display: Package → Courses → Menu Items
- Premium upcharge badges for items with extra cost
- Styled course headers and descriptions
- Visual hierarchy with left border + indentation
- Item tap handler passes full item data to parent
- O(1) menu item lookup via HashMap

**Translation Keys:**
- `error_package_not_found` (dynamic from td)

**Design Token Mappings:**
| FlutterFlow | AppColors/AppSpacing | Notes |
|-------------|---------------------|-------|
| Color(0xFFE9874B) | AppColors.accent | Premium badge color |
| Color(0xFFE0E0E0) | AppColors.border | Item left border |
| 8.0 | AppRadius.chip | Container border radius |
| 16.0 | AppSpacing.lg | List padding |
| 20.0 | AppSpacing.xl | Course bottom margin |
| 4.0 | AppSpacing.xs | Item description top spacing |

**Known Challenges:**
- Building menu item lookup map from normalized menu data
- Handling premium upcharge display logic
- Filtering excluded items
- Constructing complete item data for tap callbacks

---

### Widget 3: GalleryTabWidget

**Type:** StatefulWidget with TabController + PageController
**Expected Lines:** ~671 lines (FlutterFlow source)
**Complexity:** ⭐⭐⭐ Medium
**Riverpod Usage:** ConsumerStatefulWidget (needs translationsCacheProvider)

**Props/Parameters:**
```dart
final dynamic galleryData;              // Gallery data structure
final Future Function(List<String>, int, String)? onImageTap;  // Callback for full-screen viewer
final bool limitToEightImages;          // Limit to first 8 images per category
```

**Provider Dependencies:**
- `translationsCacheProvider` - category labels (td helper)
- `analyticsProvider` - gallery opened/tab changed events

**Key Features:**
- 4-tab gallery: Food, Menu, Interior, Outdoor
- Tab-based navigation synced with PageView
- Grid layout: 4 columns × 2 rows
- Image precaching (first 8 per category)
- Localized category names
- Analytics tracking: gallery_tab_opened, gallery_tab_changed
- Lazy tracking: gallery opened only on first user interaction

**Translation Keys:**
- `gallery_food` (dynamic from td)
- `gallery_menu` (dynamic from td)
- `gallery_interior` (dynamic from td)
- `gallery_outdoor` (dynamic from td)
- `gallery_no_images` (dynamic from td)

**Design Token Mappings:**
| FlutterFlow | AppColors/AppSpacing | Notes |
|-------------|---------------------|-------|
| Color(0xFFE9874B) | AppColors.accent | Selected tab color |
| Color(0xFF14181B) | AppColors.textPrimary | Unselected tab color |
| Color(0xFFE0E0E0) | AppColors.border | Tab bar bottom border |
| 4.0 | AppSpacing.xs | Grid spacing |
| 12.0 | AppSpacing.md | Tab bar bottom margin |
| 4.0 | AppRadius.xs | Image border radius (not in constants, use 4.0) |

**Known Challenges:**
- Syncing TabController and PageController
- SingleTickerProviderStateMixin required
- Image precaching must happen after first frame (addPostFrameCallback)
- Analytics tracking deferred until first user interaction (not on mount)
- Custom tab indicator (width = label.length * 10px)

---

## 2. Implementation Order

**Order:** PackageCoursesDisplay → PackageBottomSheet → GalleryTabWidget

**Rationale:**
1. **PackageCoursesDisplay first** - PackageBottomSheet depends on it (used internally)
2. **PackageBottomSheet second** - Most complex (nested Navigator, platform-specific transitions)
3. **GalleryTabWidget last** - Independent widget, good to end batch with cleaner implementation

**Estimated Time:**
- PackageCoursesDisplay: 2-3 hours
- PackageBottomSheet: 3-4 hours
- GalleryTabWidget: 2-3 hours
- **Total:** 7-10 hours

---

## 3. Critical Files

### PackageBottomSheet
- **FlutterFlow source:** `_flutterflow_export/lib/custom_code/widgets/package_navigation_sheet.dart`
- **MASTER_README:** None (file doesn't exist)
- **Related widgets:** PackageCoursesDisplay (called internally)
- **API service:** None (uses data from businessProvider)

### PackageCoursesDisplay
- **FlutterFlow source:** `_flutterflow_export/lib/custom_code/widgets/package_courses_display.dart`
- **MASTER_README:** None (file doesn't exist)
- **Related widgets:** None
- **API service:** None (uses data passed as props)

### GalleryTabWidget
- **FlutterFlow source:** `_flutterflow_export/lib/custom_code/widgets/gallery_tab_widget.dart`
- **MASTER_README:** None (file doesn't exist)
- **Related widgets:** ImageGalleryOverlaySwipableWidget (called via onImageTap callback)
- **API service:** None (uses gallery data from businessProvider)

---

## 4. Design Token Mappings

### Colors
| FlutterFlow | AppColors | Notes |
|-------------|-----------|-------|
| Color(0xFFE9874B) | `AppColors.accent` | Orange for premium badges, selected tabs |
| Color(0xFF14181B) | `AppColors.textPrimary` | Swipe bar, icons, unselected tabs |
| Color(0xFFF2F3F5) | `AppColors.bgSurface` | Button backgrounds |
| Color(0xFFE0E0E0) | `AppColors.border` | Item borders, tab bar border |
| Colors.white | `AppColors.bgPage` | Sheet background |
| Colors.black | `AppColors.textPrimary` | Package/item names |
| Colors.black87 | `AppColors.textSecondary` | Descriptions |
| Colors.grey[200] | `AppColors.bgInput` | Image error background |
| Color(0xFF57636C) | Use `AppColors.textTertiary` (closest match) | Divider color |

### Spacing
| FlutterFlow | AppSpacing | Notes |
|-------------|-----------|-------|
| 4.0 | `AppSpacing.xs` | Minimal spacing |
| 8.0 | `AppSpacing.sm` | Swipe bar top/bottom, item left padding |
| 12.0 | `AppSpacing.md` | Content top spacing, tab bar margin |
| 16.0 | `AppSpacing.lg` | List padding |
| 20.0 | `AppSpacing.xl` | Course bottom margin |
| 28.0 | Use `AppSpacing.xxl + 4` (24 + 4) | Content horizontal padding |

### Radii
| FlutterFlow | AppRadius | Notes |
|-------------|-----------|-------|
| 4.0 | Use `4.0` directly | Image border radius, premium badge (not in constants) |
| 8.0 | `AppRadius.chip` | Container border radius |
| 20.0 | `AppRadius.bottomSheet` | Sheet top corners, swipe bar, button corners |

### Typography
| FlutterFlow | AppTypography | Notes |
|-------------|---------------|-------|
| 22.0, w500 | `AppTypography.sectionHeading` (18px, w700) + override size | Package name |
| 18.0, w400 | `AppTypography.bodyRegular` (14px, w400) + override size | Package price, descriptions |
| 20.0, w500 | `AppTypography.categoryHeading` (16px, w700) + override size | Course name |
| 16.0, w500 | `AppTypography.label` (14px, w500) + override size | Info headers |
| 18.0, w500 | `AppTypography.menuItemName` (15px, w600) + override size | Item names |

**⚠️ Note:** Many FlutterFlow font sizes don't map 1:1 to AppTypography. Use closest match + `.copyWith(fontSize:)` override.

---

## 5. Translation Requirements

### How Many Keys?
- **PackageBottomSheet:** 7 keys (all dynamic from td)
- **PackageCoursesDisplay:** 1 key (dynamic from td)
- **GalleryTabWidget:** 5 keys (all dynamic from td)
- **Total:** 13 keys

### Key Naming Pattern
All keys use descriptive snake_case and are fetched via `td(ref, key)`:
- `error_*` - Error messages
- `info_header_*` - Section headers
- `info_disclaimer_*` - Disclaimer text
- `gallery_*` - Gallery category labels

### Languages
All 7 languages: en, da, de, fr, it, no, sv

### Append to SQL File?
**No new SQL needed.** All keys are already in Supabase `ui_translations` table (confirmed dynamic keys from buildship).

---

## 6. Known Gotchas (from Past Sessions)

### 1. Language Code Access
```dart
// ❌ WRONG: currentLanguageProvider doesn't exist
final lang = ref.watch(currentLanguageProvider);

// ✅ CORRECT: Use Localizations.localeOf(context).languageCode
final locale = Localizations.localeOf(context);
final languageCode = locale.languageCode;
```

### 2. Flutter 3.x Color Transparency
```dart
// ❌ WRONG: .withOpacity() is deprecated
color: AppColors.accent.withOpacity(0.1)

// ✅ CORRECT: .withValues(alpha:)
color: AppColors.accent.withValues(alpha: 0.1)
```

### 3. Design System Colors > FlutterFlow Colors
Always use `AppColors.*` even if colors don't match exactly. Add code comment explaining deviation.
```dart
// FlutterFlow uses #E9874B but design system uses #e8751a (AppColors.accent)
// Using AppColors.accent for design system consistency
color: AppColors.accent,
```

### 4. WidgetStateProperty Not MaterialStateProperty
```dart
// ❌ WRONG: MaterialStateProperty (deprecated)
MaterialStateProperty.all(Colors.white)

// ✅ CORRECT: WidgetStateProperty (Flutter 3.x)
WidgetStateProperty.all(Colors.white)
```

### 5. SizedBox > Container for Layout-Only
```dart
// ❌ SUBOPTIMAL: Container with only constraints
Container(height: 12)

// ✅ BETTER: SizedBox for layout-only constraints
SizedBox(height: AppSpacing.md)
```

### 6. Widget-Local State Pattern (from Session #4)
```dart
// ❌ WRONG: Trying to use widget-local Notifier
class _MyWidgetState extends ConsumerState<MyWidget> {
  late final MyNotifier _notifier;  // ❌ Notifier needs provider
}

// ✅ CORRECT: Use plain State variables
class _MyWidgetState extends ConsumerState<MyWidget> {
  bool _isExpanded = false;  // ✅ Local state variable
  void _toggle() => setState(() => _isExpanded = !_isExpanded);
}
```

### 7. SingleTickerProviderStateMixin Required for TabController
```dart
// ✅ CORRECT: GalleryTabWidget needs this for TabController
class _GalleryTabWidgetState extends ConsumerState<GalleryTabWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
}
```

### 8. Nested Navigator Pattern
```dart
// ✅ CORRECT: PackageBottomSheet uses this pattern
final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

Navigator(
  key: _navigatorKey,
  onGenerateRoute: (settings) {
    if (settings.name == '/item') {
      return _buildItemRoute(settings);
    }
    return _buildPackageRoute();
  },
)

// Navigation within nested navigator
_navigatorKey.currentState?.pushNamed('/item', arguments: itemData);
```

---

## 7. Verification Plan

### flutter analyze
```bash
cd journey_mate
flutter analyze
# MUST return: "No issues found!"
```

### Manual Test Cases

**PackageBottomSheet:**
- [ ] Bottom sheet opens with package overview
- [ ] Package image displays (with fallback for missing image)
- [ ] Premium upcharge badges appear on items
- [ ] Tapping menu item navigates to item detail view
- [ ] Back button returns to package overview
- [ ] Close button dismisses sheet
- [ ] Information source accordion expands/collapses
- [ ] Platform-specific transitions (iOS swipe-back, Android slide)

**PackageCoursesDisplay:**
- [ ] Courses display in correct order
- [ ] Course names and descriptions render
- [ ] Menu items display under each course
- [ ] Premium upcharge badges appear when > 0
- [ ] Excluded items don't render
- [ ] Tapping item triggers onItemTap callback with full data
- [ ] Scrolling works correctly

**GalleryTabWidget:**
- [ ] All 4 tabs render (Food, Menu, Interior, Outdoor)
- [ ] Selected tab highlights in orange
- [ ] Tapping tab switches page
- [ ] Swiping PageView switches tab
- [ ] Images display in 4×2 grid
- [ ] Tapping image triggers onImageTap callback
- [ ] Images precache (first 8 per category)
- [ ] Empty state shows when no images
- [ ] Analytics fire: gallery_tab_opened, gallery_tab_changed

### Code Review Checklist
- [ ] All colors use AppColors.* (no raw hex)
- [ ] All spacing uses AppSpacing.* (no magic numbers)
- [ ] All radii use AppRadius.* or documented exceptions
- [ ] Typography uses AppTypography.* with overrides where needed
- [ ] Translation uses td(ref, key) for all UI text
- [ ] No FFAppState references
- [ ] ConsumerStatefulWidget for provider access
- [ ] Widget-local state in State variables (not Notifiers)
- [ ] flutter analyze returns 0 issues

---

## 8. Session Handover

### Update SESSION_STATUS.md
```markdown
**Phase:** Phase 7 Preliminary Task — Shared widget implementation (9/29 complete)
**Last completed task:** Batch 4 (3 widgets) — PackageCoursesDisplay, PackageBottomSheet, GalleryTabWidget complete (2026-02-21 Session #5)
**Next task:** Batch 5 (3 widgets) — ContactDetailWidget, OpeningHoursAndWeekdays, ImageGalleryOverlaySwipableWidget
**Blocked on:** Nothing — continue widget implementation per PHASE7_LESSONS_LEARNED.md protocol
```

### Commit Message Format
```
feat(phase7): implement Batch 4 widgets (PackageBottomSheet, PackageCoursesDisplay, GalleryTabWidget)

- PackageBottomSheet: Nested Navigator with package/item views
- PackageCoursesDisplay: Hierarchical course/item display with premium badges
- GalleryTabWidget: 4-tab gallery with image precaching and analytics
- All widgets use Riverpod 3.x (ConsumerStatefulWidget)
- Design token compliance: AppColors, AppSpacing, AppRadius
- Translation: All UI text via td(ref, key)
- flutter analyze: 0 issues
```

---

## 9. Implementation Checklist

### Pre-Implementation
- [ ] Read CLAUDE.md
- [ ] Read _reference/PHASE7_LESSONS_LEARNED.md
- [ ] Read _reference/PROVIDERS_REFERENCE.md
- [ ] Read DESIGN_SYSTEM_flutter.md
- [ ] Read this plan completely

### Widget 1: PackageCoursesDisplay
- [ ] Read FlutterFlow source: `package_courses_display.dart`
- [ ] Create file: `journey_mate/lib/widgets/shared/package_courses_display.dart`
- [ ] Implement StatefulWidget → ConsumerStatefulWidget
- [ ] Build menu item lookup map (O(1) access)
- [ ] Implement hierarchical layout (package → courses → items)
- [ ] Add premium badge logic
- [ ] Apply design tokens (colors, spacing, typography)
- [ ] Translation: td(ref, 'error_package_not_found')
- [ ] Verify no raw colors/spacing
- [ ] Manual test: Scroll, tap items, premium badges
- [ ] flutter analyze: 0 issues

### Widget 2: PackageBottomSheet
- [ ] Read FlutterFlow source: `package_navigation_sheet.dart`
- [ ] Create file: `journey_mate/lib/widgets/shared/package_bottom_sheet.dart`
- [ ] Implement nested Navigator with GlobalKey
- [ ] Build package overview page (_PackageViewPage)
- [ ] Build item detail page (_ItemDetailPage)
- [ ] Build information source accordion (_InformationSourceSection)
- [ ] Add platform-specific route builders (iOS/Android)
- [ ] Integrate PackageCoursesDisplay widget
- [ ] Apply design tokens (colors, spacing, typography, radii)
- [ ] Translation: 7 dynamic keys via td()
- [ ] Verify no raw colors/spacing
- [ ] Manual test: Navigate, swipe, close, accordion
- [ ] flutter analyze: 0 issues

### Widget 3: GalleryTabWidget
- [ ] Read FlutterFlow source: `gallery_tab_widget.dart`
- [ ] Create file: `journey_mate/lib/widgets/shared/gallery_tab_widget.dart`
- [ ] Add SingleTickerProviderStateMixin
- [ ] Initialize TabController + PageController
- [ ] Parse gallery data into categories
- [ ] Build custom tab bar (equal-width tabs with indicator)
- [ ] Build PageView with 4×2 grid per page
- [ ] Sync TabController ↔ PageController
- [ ] Add image precaching (first 8 per category)
- [ ] Add analytics: gallery_tab_opened, gallery_tab_changed
- [ ] Defer analytics tracking until first user interaction
- [ ] Apply design tokens (colors, spacing, typography)
- [ ] Translation: 5 category labels via td()
- [ ] Verify no raw colors/spacing
- [ ] Manual test: Tab tap, swipe, image tap, analytics
- [ ] flutter analyze: 0 issues

### Post-Implementation
- [ ] Run flutter analyze (MUST return 0 issues)
- [ ] Run code review checklist (see Section 7)
- [ ] No new translation keys needed (all keys already in Supabase)
- [ ] Update SESSION_STATUS.md (9/29 widgets complete)
- [ ] Append lessons learned to PHASE7_LESSONS_LEARNED.md (if relevant)
- [ ] Commit all 3 widgets

---

## 10. Expected File Sizes

| Widget | Expected Lines | Actual Lines (after implementation) |
|--------|----------------|-------------------------------------|
| PackageCoursesDisplay | ~571 | ___ |
| PackageBottomSheet | ~1,255 | ___ |
| GalleryTabWidget | ~671 | ___ |
| **Total** | **~2,497** | **___** |

---

## 11. Success Criteria

Batch 4 is complete when:
- [ ] All 3 widgets implemented per FlutterFlow source
- [ ] All widgets use Riverpod 3.x (ConsumerStatefulWidget, td helper)
- [ ] All design tokens applied (no raw hex/pixels)
- [ ] All translations use td(ref, key)
- [ ] flutter analyze returns 0 issues
- [ ] All manual tests pass
- [ ] Code review checklist complete
- [ ] SESSION_STATUS.md updated (9/29 widgets complete)
- [ ] Lessons learned appended (if relevant)
- [ ] Clean commit with descriptive message

---

**End of Phase 7 Batch 4 Plan**

Next session: Implement all 3 widgets following this plan, then prepare Batch 5 plan.
