# Phase 7: Next Session Instructions

**Created:** 2026-02-22
**For:** Next Claude Code session continuing Phase 7 work
**Working Directory:** `C:\Users\Rikke\Documents\JourneyMate-Organized`

---

## ✅ Current Status: Ready for Page Implementation

**All prerequisites complete:**
- ✅ **34/34 shared widgets built** (100% complete)
- ✅ **All 20 flutter analyze issues fixed** (0 errors, 0 warnings, 0 info)
- ✅ **Codebase clean and verified**
- ✅ **All foundation complete** (providers, routing, API, translations)

**What's been built (recent sessions):**
- ProfileTopBusinessBlockWidget (510 lines) — Hero section for Business Profile
- ImageGalleryWidget (379 lines) — Full-screen gallery with infinite scroll
- ImageGalleryOverlaySwipableWidget (50 lines) — Overlay wrapper for gallery
- ContactDetailsWidget (693 lines) — Contact info with hours/links
- All 4 custom functions (distance, address, hours, price formatters)
- determineStatusAndColor action (407 lines) — Business status calculation

**What's next:**
🎯 **Implement Business Profile Page (Phase 7.3 per master plan)**

---

## CRITICAL: Read These Documents FIRST (In This Order)

Before doing ANYTHING, read these foundation documents completely:

### 1. Core Protocol Documents (MANDATORY)
1. **`CLAUDE.md`** — Session rules, product decisions, Git workflow, known decisions
2. **`_reference/SESSION_STATUS.md`** — Current project state, what's been completed
3. **`_reference/PHASE7_LESSONS_LEARNED.md`** — Widget/page implementation patterns, session protocol
4. **`_reference/PROVIDERS_REFERENCE.md`** — All 8 Riverpod providers documented
5. **`DESIGN_SYSTEM_flutter.md`** — All design tokens (AppColors, AppSpacing, AppTypography, AppRadius)

### 2. Phase 7 Master Plan (MANDATORY)
6. **`C:\Users\Rikke\.claude\plans\drifting-meandering-koala.md`** — Complete Phase 7 implementation plan (500+ lines)
   - Read lines 1-100: Context and prerequisites
   - Read lines 418-500: Business Profile page specification
   - This is the SINGLE SOURCE OF TRUTH for Phase 7

### 3. Business Profile Page Spec (MANDATORY)
7. **`pages/02_business_profile/BUNDLE.md`** — Complete functional specification
8. **`pages/02_business_profile/GAP_ANALYSIS.md`** — Gaps between FlutterFlow and BuildShip
9. **`_flutterflow_export/lib/profile/business_profile/business_profile_widget.dart`** — FlutterFlow ground truth

### 4. BuildShip API Reference (MANDATORY)
10. **`_reference/BUILDSHIP_API_REFERENCE.md`** — All 12 BuildShip endpoints documented
    - Endpoint #2: GET_BUSINESS_PROFILE (business data, hours, gallery, menu structure)
    - Endpoint #3: GET_RESTAURANT_MENU (menu items with dietary info)
    - Endpoint #8: GET_FILTER_DESCRIPTIONS (filter descriptions for feature chips)

---

## Session Workflow: Building Business Profile Page

### Phase 0: Setup & Foundation Reading (30 minutes)

**DO NOT SKIP THIS PHASE.** Every session must start here.

1. ✅ Read all 10 documents listed above in order
2. ✅ Confirm current git branch: `main`
3. ✅ Run `flutter analyze` — must return "No issues found!"
4. ✅ Review existing page files:
   ```bash
   ls -la journey_mate/lib/pages/*.dart
   # Should see: search_page.dart, welcome_page.dart (or similar)
   ```

### Phase 1: Pre-Implementation Planning (45 minutes)

**Understand the page scope:**

**Business Profile Page Complexity: ⭐⭐⭐⭐⭐ EXTREMELY HIGH**

This is the MOST COMPLEX page in the app. It includes:
- 3 parallel API calls on mount (BusinessProfile, MenuItems, FilterDescriptions)
- Hero section with business info, status, distance, quick actions
- 3 tabs (Menu, Gallery, About) with different data/widgets per tab
- Menu tab: Category chips + dishes list + dietary filtering + item/package bottom sheets
- Gallery tab: 4-tab gallery (Overview/Food/Drinks/Interior) + full-screen overlay
- About tab: Hours, features, payment options, description
- Complex state management across multiple providers
- Analytics tracking for page view, tab switches, item taps, feature taps

**Key Implementation Challenges:**
1. **Data loading orchestration** — 3 API calls in parallel with loading states
2. **Tab state management** — 3 tabs with different widget trees
3. **Route parameters** — Extract business ID from `/business/:id` route
4. **Provider coordination** — businessProvider, filterProvider, translationsCacheProvider, localizationProvider
5. **Match card display** — Only show if arriving from Search (needs previous route context)
6. **Dietary filtering** — Filter menu items based on user's dietary preferences

**Read these widget MASTER_READMEs before starting:**
- ProfileTopBusinessBlockWidget (hero section)
- MenuCategoriesRows (horizontal category chips)
- MenuDishesListView (menu items grouped by category)
- UnifiedFiltersWidget (dietary filtering panel)
- ItemBottomSheet (menu item details)
- PackageBottomSheet (package selection)
- GalleryTabWidget (4-tab gallery)
- ImageGalleryOverlaySwipableWidget (full-screen gallery overlay)
- ContactDetailsWidget (hours, contact info, social links)
- BusinessFeatureButtons (facility/feature chips)
- PaymentOptionsWidget (payment method chips)
- FilterDescriptionSheet (filter/feature description popup)

### Phase 2: Implementation Strategy (15 minutes)

**Recommended implementation order:**

1. **Page scaffold + routing** (30 min)
   - Create `business_profile_page.dart`
   - Add route parameter extraction: `GoRouterState.pathParameters['id']`
   - Set up TabController for 3 tabs
   - Add NavBarWidget at bottom

2. **Data loading logic** (45 min)
   - Create 3 parallel API calls in `initState`/`build`
   - Store data in businessProvider
   - Add loading states (shimmer skeletons)
   - Add error states (retry button)

3. **Hero section (Tab-independent)** (30 min)
   - Add ProfileTopBusinessBlockWidget at top
   - Wire up all 12 props from businessProvider
   - Add quick action buttons (Call, Map, Website) below hero
   - Add match card (conditional on coming from Search)

4. **Tab 1: Menu** (60 min)
   - MenuCategoriesRows (horizontal chips)
   - MenuDishesListView (menu items)
   - UnifiedFiltersWidget (dietary filters)
   - "View on full page" button → navigate `/business/:id/menu`
   - Item tap → open ItemBottomSheet
   - Package tap → open PackageBottomSheet

5. **Tab 2: Gallery** (45 min)
   - GalleryTabWidget (4 tabs: Overview, Food, Drinks, Interior)
   - "View all images" button → navigate `/business/:id/gallery`
   - Image tap → open ImageGalleryOverlaySwipableWidget

6. **Tab 3: About** (45 min)
   - ContactDetailsWidget (hours, contact info)
   - BusinessFeatureButtons (facility chips)
   - PaymentOptionsWidget (payment methods)
   - Business description text

7. **Analytics integration** (30 min)
   - trackPageViewed on mount
   - trackTabSwitched on tab change
   - trackMenuItemClicked on item tap
   - trackFeatureClicked on feature chip tap

8. **Edge cases & error handling** (30 min)
   - API failures → show error state with retry
   - Empty menu → show "No menu available" message
   - No gallery images → show placeholder
   - Missing business data → graceful fallbacks

**Total Estimated Time:** 5-6 hours (1 full session)

### Phase 3: Implementation (Main Work)

**File to create:**
```
journey_mate/lib/pages/business_profile_page.dart
```

**Key patterns to follow:**

#### Pattern 1: Page Structure (ConsumerStatefulWidget)
```dart
class BusinessProfilePage extends ConsumerStatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  ConsumerState<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage>
    with SingleTickerProviderStateMixin {
  // TabController for 3 tabs
  late TabController _tabController;

  // Loading state
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBusinessData();
  }

  Future<void> _loadBusinessData() async {
    // Extract business ID from route
    final businessId = int.parse(
      GoRouterState.of(context).pathParameters['id']!,
    );

    // 3 parallel API calls
    try {
      final results = await Future.wait([
        ApiService.instance.getBusinessProfile(businessId, languageCode),
        ApiService.instance.getMenuItems(businessId, languageCode),
        ApiService.instance.getFilterDescriptions(languageCode),
      ]);

      // Store data in providers
      ref.read(businessProvider.notifier).setBusinessData(results[0]);
      ref.read(businessProvider.notifier).setMenuData(results[1]);
      ref.read(filterProvider.notifier).setDescriptions(results[2]);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load business data';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorState();
    return _buildMainContent();
  }
}
```

#### Pattern 2: Hero Section (Always Visible)
```dart
Widget _buildHeroSection() {
  final business = ref.watch(businessProvider).currentBusiness;
  final userLocation = ref.watch(locationProvider).currentPosition;

  return Column(
    children: [
      ProfileTopBusinessBlockWidget(
        openingHours: business.businessHours,
        userLocation: userLocation,
        priceRangeMin: business.priceRangeMin,
        priceRangeMax: business.priceRangeMax,
        profilePicture: business.profilePicture?.url,
        businessName: business.businessName,
        latitude: business.address?.latitude,
        longitude: business.address?.longitude,
        street: business.address?.street,
        neighbourhoodName: business.address?.neighbourhoodName,
        businessID: business.businessId,
        businessType: business.businessType,
      ),
      SizedBox(height: AppSpacing.md),
      _buildQuickActions(),
      if (_showMatchCard) _buildMatchCard(),
    ],
  );
}
```

#### Pattern 3: TabBarView for 3 Tabs
```dart
Widget _buildMainContent() {
  return Column(
    children: [
      _buildHeroSection(),
      TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: ts(context, 'tab_menu')),
          Tab(text: ts(context, 'tab_gallery')),
          Tab(text: ts(context, 'tab_about')),
        ],
      ),
      Expanded(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildMenuTab(),
            _buildGalleryTab(),
            _buildAboutTab(),
          ],
        ),
      ),
      NavBarWidget(activePage: 'Search'), // Bottom nav
    ],
  );
}
```

#### Pattern 4: Menu Tab (Most Complex)
```dart
Widget _buildMenuTab() {
  final menuItems = ref.watch(businessProvider).menuItems;
  final categories = ref.watch(businessProvider).menuCategories;

  return Column(
    children: [
      // Category chips (horizontal scroll)
      MenuCategoriesRows(categories: categories),

      // Dietary filter panel
      UnifiedFiltersWidget(
        onFilterChanged: (filterIds) {
          ref.read(businessProvider.notifier).updateDietaryFilters(filterIds);
        },
      ),

      // Menu items list
      Expanded(
        child: MenuDishesListView(
          menuItems: menuItems,
          onItemTap: (item) => _showItemBottomSheet(item),
          onPackageTap: (package) => _showPackageBottomSheet(package),
        ),
      ),

      // "View on full page" button
      ElevatedButton(
        onPressed: () => context.push('/business/${businessId}/menu'),
        child: Text(ts(context, 'view_full_menu')),
      ),
    ],
  );
}

void _showItemBottomSheet(MenuItem item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => ItemBottomSheet(
      menuItemId: item.id,
      menuItemName: item.name,
      // ... all other props
    ),
  );
}
```

#### Pattern 5: Gallery Tab
```dart
Widget _buildGalleryTab() {
  final galleryImages = ref.watch(businessProvider).galleryImages;

  return Column(
    children: [
      Expanded(
        child: GalleryTabWidget(
          images: galleryImages,
          onImageTap: (index, category) => _showFullScreenGallery(index, category),
        ),
      ),
      ElevatedButton(
        onPressed: () => context.push('/business/${businessId}/gallery'),
        child: Text(ts(context, 'view_all_images')),
      ),
    ],
  );
}

void _showFullScreenGallery(int index, String category) {
  Navigator.push(
    context,
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => ImageGalleryOverlaySwipableWidget(
        imageURLs: galleryImages.map((img) => img.url).toList(),
        imageIndex: index,
        tabCategory: category,
      ),
    ),
  );
}
```

#### Pattern 6: About Tab
```dart
Widget _buildAboutTab() {
  final business = ref.watch(businessProvider).currentBusiness;

  return SingleChildScrollView(
    padding: EdgeInsets.all(AppSpacing.md),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Opening hours
        ContactDetailsWidget(
          businessHours: business.businessHours,
          contact: business.contact,
          address: business.address,
        ),

        SizedBox(height: AppSpacing.lg),

        // Features/services
        Text(
          ts(context, 'section_features'),
          style: AppTypography.h2,
        ),
        SizedBox(height: AppSpacing.sm),
        BusinessFeatureButtons(
          filters: business.filters,
          onFilterTap: (filterId) => _showFilterDescription(filterId),
        ),

        SizedBox(height: AppSpacing.lg),

        // Payment options
        Text(
          ts(context, 'section_payment'),
          style: AppTypography.h2,
        ),
        SizedBox(height: AppSpacing.sm),
        PaymentOptionsWidget(
          paymentFilters: business.filters
              .where((f) => f.categoryId == 21 || f.categoryId == 423)
              .toList(),
        ),

        SizedBox(height: AppSpacing.lg),

        // Business description
        if (business.description != null) ...[
          Text(
            ts(context, 'section_about'),
            style: AppTypography.h2,
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            business.description!,
            style: AppTypography.bodyRegular,
          ),
        ],
      ],
    ),
  );
}
```

#### Pattern 7: Analytics Tracking
```dart
@override
void initState() {
  super.initState();
  _tabController = TabController(length: 3, vsync: this);

  // Track page viewed
  SchedulerBinding.instance.addPostFrameCallback((_) {
    final analytics = AnalyticsService.instance;
    ApiService.instance.postAnalytics(
      eventType: 'page_viewed',
      deviceId: analytics.deviceId ?? '',
      sessionId: analytics.currentSessionId ?? '',
      userId: analytics.userId ?? '',
      timestamp: DateTime.now().toIso8601String(),
      eventData: {
        'pageName': 'businessProfilePage',
        'businessId': businessId,
      },
    );
  });

  // Track tab switches
  _tabController.addListener(() {
    if (!_tabController.indexIsChanging) {
      final tabNames = ['menu', 'gallery', 'about'];
      ApiService.instance.postAnalytics(
        eventType: 'tab_switched',
        // ... same pattern
        eventData: {'tabName': tabNames[_tabController.index]},
      );
    }
  });

  _loadBusinessData();
}
```

### Phase 4: Verification (CRITICAL — Do NOT Skip)

**Run ALL these checks before committing:**

1. ✅ **flutter analyze** — must return "No issues found!"
   ```bash
   cd journey_mate
   flutter analyze
   ```

2. ✅ **Design token compliance check:**
   - Search for raw hex colors: `grep -r "Color(0x" journey_mate/lib/pages/business_profile_page.dart`
     - Result should be empty OR only from AppColors imports
   - Search for magic numbers: Look for spacing values not from AppSpacing
   - Search for inline TextStyle: All text should use AppTypography

3. ✅ **Translation check:**
   - All UI text uses `ts(context, key)` or `td(ref, key)`
   - No hardcoded English/Danish strings in UI

4. ✅ **Edge case handling:**
   - Test with empty menu items
   - Test with no gallery images
   - Test with missing business description
   - Test API failure scenarios (add retry button)

5. ✅ **Provider usage:**
   - Only read from providers using `ref.watch()` in build
   - Only write to providers using `ref.read().notifier` in event handlers
   - No FFAppState references anywhere

6. ✅ **Activity tracking:**
   - No manual `markUserEngaged()` calls (ActivityScope handles this)

### Phase 5: Translation Keys (Phase 6B)

**Add new translation keys to both:**

1. **`journey_mate/lib/services/translation_service.dart`** (kStaticTranslations map)
2. **`_reference/NEW_TRANSLATION_KEYS.sql`** (SQL INSERT statements)

**Expected new keys for Business Profile page (~10):**
- `tab_menu`, `tab_gallery`, `tab_about`
- `view_full_menu`, `view_all_images`
- `section_features`, `section_payment`, `section_about`
- `why_this_match`, `quick_actions`
- Error messages: `failed_to_load`, `retry`

**SQL format:**
```sql
INSERT INTO ui_translations (translation_key, language_code, translation_text, category)
VALUES
  ('tab_menu', 'en', 'Menu', 'ui'),
  ('tab_menu', 'da', 'Menu', 'ui'),
  -- repeat for all 7 languages (en, da, de, fr, it, no, sv)
;
```

### Phase 6: Commit

**Commit message format:**
```bash
git add journey_mate/lib/pages/business_profile_page.dart
git add journey_mate/lib/services/translation_service.dart  # if updated
git add _reference/NEW_TRANSLATION_KEYS.sql  # if updated
git commit -m "feat(phase7.3): implement Business Profile page

- 3 parallel API calls (BusinessProfile, MenuItems, FilterDescriptions)
- Hero section: ProfileTopBusinessBlockWidget + quick actions + match card
- Tab 1 (Menu): MenuCategoriesRows + MenuDishesListView + UnifiedFiltersWidget + item/package bottom sheets
- Tab 2 (Gallery): GalleryTabWidget + ImageGalleryOverlaySwipableWidget overlay
- Tab 3 (About): ContactDetailsWidget + BusinessFeatureButtons + PaymentOptionsWidget + description
- Analytics: page viewed, tab switches, item taps, feature taps
- Loading states: shimmer skeletons during API calls
- Error states: retry button on API failures
- Design tokens: AppColors, AppSpacing, AppTypography, AppRadius throughout
- Translation helpers: ts()/td() for all UI text
- [X] flutter analyze: 0 issues

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
"
```

### Phase 7: Update SESSION_STATUS.md

**Update these sections:**

```markdown
## Current Status
**Phase:** Phase 7 — IN PROGRESS (Page Implementation)
**Last completed task:** Business Profile page (7.3) complete (2026-02-XX)
**Next task:** Menu Full Page (7.4) OR Gallery Full Page (7.5) per master plan
**Blocked on:** Nothing

## Files changed this session
- `journey_mate/lib/pages/business_profile_page.dart` (created, ~XXX lines)
- `journey_mate/lib/services/translation_service.dart` (updated kStaticTranslations)
- `_reference/NEW_TRANSLATION_KEYS.sql` (appended X new keys)
- `_reference/SESSION_STATUS.md` (this file updated)

## Decisions made this session
- [Document any key decisions made during implementation]
- [Any deviations from BUNDLE.md or master plan]
- [Any patterns discovered or lessons learned]

## What the next session must do first
- Read Phase 7 master plan for next page (Menu Full Page or Gallery Full Page)
- Read PHASE7_LESSONS_LEARNED.md
- Continue page implementation per strict dependency order
```

---

## Critical Success Criteria

This session is successful when:

✅ **Business Profile page fully implemented**
- All 3 tabs working (Menu, Gallery, About)
- All widgets integrated correctly
- All API calls working
- All analytics events firing

✅ **Design quality**
- `flutter analyze` returns "No issues found!"
- All design tokens used (no raw values)
- All text uses translation helpers

✅ **Edge cases handled**
- Loading states (shimmer)
- Error states (retry button)
- Empty states (no menu, no gallery)

✅ **Documentation updated**
- SESSION_STATUS.md updated
- Translation keys added (if any)
- Commit message complete and descriptive

---

## Common Pitfalls to Avoid

❌ **DO NOT:**
1. Skip reading foundation documents (especially BUNDLE.md and master plan)
2. Use raw hex colors or magic numbers (always use AppColors, AppSpacing)
3. Hardcode UI text (always use ts()/td() helpers)
4. Reference FFAppState or FlutterFlow patterns directly
5. Add `markUserEngaged()` calls (ActivityScope handles this automatically)
6. Use `StateNotifier` or `StateNotifierProvider` (use Riverpod 3.x: Notifier/NotifierProvider)
7. Forget to add `context.mounted` checks after async operations
8. Use `.withOpacity()` (use `.withValues(alpha:)` for Flutter 3.x)
9. Skip the verification phase (flutter analyze, edge cases, design tokens)
10. Commit without updating SESSION_STATUS.md

✅ **DO:**
1. Read all foundation docs before starting
2. Follow the implementation order (scaffold → data loading → hero → tabs)
3. Use design tokens for ALL styling (AppColors, AppSpacing, AppTypography, AppRadius)
4. Test edge cases (empty data, API failures, loading states)
5. Add analytics tracking (page view, tab switches, item taps)
6. Run `flutter analyze` before committing
7. Update SESSION_STATUS.md and translation files
8. Write descriptive commit message with Co-Authored-By line

---

## Quick Reference Links

**Foundation Docs:**
- `CLAUDE.md` — Session rules
- `_reference/SESSION_STATUS.md` — Current state
- `_reference/PHASE7_LESSONS_LEARNED.md` — Implementation patterns
- `_reference/PROVIDERS_REFERENCE.md` — All providers
- `DESIGN_SYSTEM_flutter.md` — Design tokens

**Master Plan:**
- `C:\Users\Rikke\.claude\plans\drifting-meandering-koala.md` — Phase 7 complete plan

**Business Profile Spec:**
- `pages/02_business_profile/BUNDLE.md` — Functional spec
- `pages/02_business_profile/GAP_ANALYSIS.md` — BuildShip gaps
- `_flutterflow_export/lib/profile/business_profile/business_profile_widget.dart` — Ground truth

**API Reference:**
- `_reference/BUILDSHIP_API_REFERENCE.md` — All endpoints

---

## Estimated Session Time

**Total:** 5-6 hours (1 full Claude Code session)

**Breakdown:**
- Phase 0 (Setup): 30 min
- Phase 1 (Planning): 45 min
- Phase 2 (Strategy): 15 min
- Phase 3 (Implementation): 4-5 hours
- Phase 4 (Verification): 30 min
- Phase 5 (Translation): 15 min
- Phase 6 (Commit): 10 min
- Phase 7 (Docs): 10 min

---

**Good luck! 🚀**

This is a complex page, but all the widgets are built and ready to use. Take your time, follow the patterns, and test thoroughly.

If you encounter blockers, document them in SESSION_STATUS.md and ask the user for clarification.
