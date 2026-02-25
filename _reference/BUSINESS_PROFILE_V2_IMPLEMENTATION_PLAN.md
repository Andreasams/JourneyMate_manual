# Business Profile Page V2 - Implementation Plan (Phases 2-8)

**Status:** Phase 1 Complete ✅ | Phases 2-8 Pending

**Phase 1 Completion Summary:**
- ✅ Main page scaffold (`business_profile_page_v2.dart`)
- ✅ Hero section widget (logo, name, details)
- ✅ Quick actions pills (white bg, dark text/icons per JSX)
- ✅ AppBar with back, share, and info icons
- ✅ Analytics tracking (page view, session duration, button taps)
- ✅ API integration (3 parallel calls)
- ✅ Compilation verified (no errors)

---

## Phase 2: Match Card & Tags (2-3 hours)

### Goal
Display filter matching card with expandable matched/missed filters, and horizontal scrollable tags row.

### Files to Create
1. `lib/widgets/business_profile/match_card_widget_v2.dart` (replace existing)
2. `lib/widgets/business_profile/tags_row_widget.dart` (new)

### Implementation Details

#### Match Card Widget (`match_card_widget_v2.dart`)

**Data Source:**
- Read from `businessProvider.filterDescriptions` (List<dynamic>)
- Read from `businessProvider.matchedCount` and `totalCount`
- Read from `searchStateProvider.filtersUsedForSearch` to check if filters active

**UI Specs (JSX lines 190-237):**
- **Conditional display:** Only show if `filtersUsedForSearch.isNotEmpty`
- **Container styling:**
  - Full match (100%): `border: 1.5px solid #d0ecd8`, `background: #f0f9f3`
  - Partial match: `border: 1.5px solid #f0dcc8`, `background: #fef8f2`
  - Border radius: 12px
  - Margin bottom: 16px
- **Header (collapsed):**
  - Icon: Green checkmark (full match) or orange info icon (partial)
  - Text: "Matcher alle X behov" (full) or "Matcher X af Y behov" (partial)
  - Font: 13.5px, weight 600, color #0f0f0f
  - Chevron icon (rotates 180° when expanded)
  - Padding: 12px 14px
  - Tap to toggle expansion
- **Expanded content:**
  - Padding: 0 14px 14px (no top padding)
  - Flex wrap row with 5px gap
  - **Matched filters:**
    - Background: white
    - Text color: #1a9456 (AppColors.green)
    - Border: 1px solid #d0ecd8 (AppColors.greenBorder)
    - Check icon (8px, green) before text
    - Padding: 3px 8px
    - Border radius: 6px
    - Font: 11px, weight 560 → w600
  - **Missed filters:**
    - Background: white
    - Text color: #c9403a (AppColors.red)
    - Border: 1px solid #f5d5d2
    - X icon (8px, red) before text
    - Padding: 3px 8px
    - Border radius: 6px
    - Font: 11px, weight 520 → w600

**State Management:**
- Local `bool _isExpanded = false` in `ConsumerStatefulWidget`
- Toggle on tap, animate chevron rotation

**Analytics:**
- Track expansion/collapse:
  ```dart
  ApiService.instance.postAnalytics(
    eventType: 'match_card_toggled',
    deviceId: analyticsState.deviceId,
    sessionId: analyticsState.sessionId ?? '',
    userId: '',
    timestamp: DateTime.now().toIso8601String(),
    eventData: {
      'action': _isExpanded ? 'expanded' : 'collapsed',
      'matched_count': matchedCount,
      'total_count': totalCount,
      'is_full_match': matchedCount == totalCount,
    },
  );
  ```

**Translation Keys:**
- `'match_all_needs'` → "Matcher alle {count} behov"
- `'match_partial_needs'` → "Matcher {count} af {total} behov"

#### Tags Row Widget (`tags_row_widget.dart`)

**Data Source:**
- Read from `businessProvider.currentBusiness['tags']` (List<String>?)
- Conditional display: hide if tags list is null or empty

**UI Specs (JSX lines 262-274 pattern):**
- Horizontal `SingleChildScrollView`
- Row of chips with 8px gap
- Padding: 0 24px on right for scroll fade
- **Chip styling:**
  - Background: white
  - Border: 1.5px solid #e8e8e8
  - Border radius: 8px (AppRadius.chip)
  - Padding: 6px 12px
  - Font: 12.5px, weight 460 → w500, color #555 (AppColors.textSecondary)

**No interactions:** Display-only (not tappable)

### Integration with Main Page
In `business_profile_page_v2.dart`, add after quick actions:
```dart
// 3. Match Card (if search filters are active)
const MatchCardWidgetV2(),
SizedBox(height: AppSpacing.lg),

// 4. Tags Row (if tags exist)
const TagsRowWidget(),
SizedBox(height: AppSpacing.lg),
```

### Testing Checklist
- [ ] Match card shows only when filters are active
- [ ] Full match: green border + background
- [ ] Partial match: orange border + background
- [ ] Expansion animation smooth
- [ ] Matched filters have green check + green colors
- [ ] Missed filters have red X + red colors
- [ ] Tags display horizontally scrollable
- [ ] Tags hide when no tags data
- [ ] Analytics tracked on expand/collapse

---

## Phase 3: Opening Hours & Contact (3-4 hours)

### Goal
Create expandable opening hours section with contact information.

### Files to Modify
1. Reuse existing `lib/widgets/shared/opening_hours_and_weekdays.dart`
2. Or create `lib/widgets/business_profile/opening_hours_contact_widget.dart` if existing widget doesn't match JSX

### Implementation Details

**Decision Point:** Check if `OpeningHoursAndWeekdays` widget matches JSX design (lines 239-246). If yes, reuse it. If no, create new widget following JSX specs.

**Data Source:**
- Read from `businessProvider.openingHours` (dynamic)
- Read from `businessProvider.currentBusiness['phone_number']`, `['website']`, `['booking_url']`, etc.

**UI Specs (JSX lines 239-246 + Contact section):**
- **Section title:** "Åbningstider og kontakt" (18px, weight 680)
- **Collapsed state:**
  - Shows today's hours preview (e.g., "I dag: 07:00–10:00, 11:30–14:30")
  - Chevron icon (rotates 180° when expanded)
  - Border bottom: 1px solid #f2f2f2 (optional, check JSX)
- **Expanded state:**
  - **Hours table:**
    - Background: #fafafa (AppColors.bgSurface)
    - Border radius: 14px
    - Padding: 16px
    - Label: "ÅBNINGSTIDER" (uppercase, 11.5px, weight 620, color #666)
    - Each day: left-aligned day name, right-aligned hours
    - Multi-slot days: show all time ranges with notes
    - Closed: red text color (#c9403a)
    - Border between rows: 1px solid #ececec
  - **Contact section:**
    - Divider: 1px solid #e8e8e8
    - Label: "KONTAKT" (uppercase, 11.5px, weight 620, color #666)
    - Each row:
      - Left: Label text (#555)
      - Right: Value text (#222 for phone, orange for links)
      - Font: 14px
      - Border between: 1px solid #ececec
    - **Phone:**
      - Tap: launch phone dialer (`url_launcher`)
      - Long press: copy to clipboard (show SnackBar confirmation)
    - **Website, Booking, Instagram, Facebook:**
      - Tap: open in external browser
      - Display truncated if too long
    - **Email:**
      - Tap: launch email client
      - Long press: copy to clipboard

**State Management:**
- Local `bool _isExpanded = false` in `ConsumerStatefulWidget`

**Analytics:**
- Track expansion:
  ```dart
  eventType: 'opening_hours_toggled',
  eventData: {'action': _isExpanded ? 'expanded' : 'collapsed'}
  ```
- Track contact taps:
  ```dart
  eventType: 'contact_link_tapped',
  eventData: {'link_type': 'phone|website|booking|email', 'business_id': businessId}
  ```

**Translation Keys:**
- `'opening_hours_and_contact'` → "Åbningstider og kontakt"
- `'today_prefix'` → "I dag: "
- `'closed'` → "Lukket"
- `'opening_hours_label'` → "Åbningstider"
- `'contact_label'` → "Kontakt"
- `'phone'` → "Telefon"
- `'website'` → "Hjemmeside"
- `'booking'` → "Booking"
- `'email'` → "E-mail"
- `'copied_to_clipboard'` → "Kopieret til udklipsholder"

### Integration
Add to main page after tags section.

---

## Phase 4: Gallery with Tabbed Categories (6-8 hours)

### Goal
Create tabbed gallery with flat tabs (bottom border indicator) and swipeable 3-column image grids.

### Files to Create
1. `lib/widgets/business_profile/gallery_section_widget.dart` (replace existing)

### Implementation Details

**Data Source:**
- Read from `businessProvider.currentBusiness['gallery_images']`
- Expected structure:
  ```dart
  {
    'food': ['url1', 'url2', ...],
    'menu': ['url1', 'url2', ...],
    'interior': ['url1', 'url2', ...],
    'exterior': ['url1', 'url2', ...],
  }
  ```

**UI Specs (JSX lines 248-293):**
- **Section heading:** "Galleri" (18px, weight 680, margin bottom 12px)
- **Tab bar:**
  - **CRITICAL:** Flat tabs with bottom border indicator (NOT pills!)
  - 4 tabs: "Mad", "Menu", "Inde", "Ude"
  - Each tab:
    - Flex: 1 (equal width)
    - Padding: 6px 0
    - Font: 13.5px
    - **Active:** weight 620, color orange (#e8751a), border-bottom 2px solid orange
    - **Inactive:** weight 460, color #999, border-bottom 2px solid transparent
    - Tap to switch tabs
- **Image grid:**
  - 3 columns with 3px gap
  - Aspect ratio 1:1 (square images)
  - Maximum 6 images per tab
  - **Variable border radii (alternating pattern):**
    - Image 0 (top-left): 10px 4px 4px 4px
    - Image 1 (top-center): 4px 4px 4px 4px
    - Image 2 (top-right): 4px 10px 4px 4px
    - Image 3 (bottom-left): 4px 4px 4px 10px
    - Image 4 (bottom-center): 4px 4px 4px 4px
    - Image 5 (bottom-right): 4px 4px 10px 4px
  - **Swipeable:** Use `PageView` or detect touch gestures
    - Swipe left: next tab
    - Swipe right: previous tab
    - Sync tab selection with swipe
  - **Visual indicator:** Dot indicators below grid (active: orange, inactive: light gray)
  - **Tap image:** Open `ImageGalleryWidget` modal (existing widget)
- **"See All" button:**
  - Center-aligned
  - Text: "Se alle billeder →" (13px, weight 540, color #555)
  - Navigate to `/business/:id/gallery` route
  - Margin top: 8px

**State Management:**
- Local `String _activeTab = 'Mad'` (or use index)
- `PageController` for swipe detection

**Analytics:**
- Track tab change:
  ```dart
  eventType: 'gallery_tab_changed',
  eventData: {'tab': tabName, 'business_id': businessId}
  ```
- Track image tap:
  ```dart
  eventType: 'gallery_image_tapped',
  eventData: {'tab': tabName, 'image_index': index, 'business_id': businessId}
  ```
- Track "See All" tap:
  ```dart
  eventType: 'gallery_see_all_tapped',
  eventData: {'business_id': businessId}
  ```

**Translation Keys:**
- `'gallery'` → "Galleri"
- `'gallery_tab_food'` → "Mad"
- `'gallery_tab_menu'` → "Menu"
- `'gallery_tab_interior'` → "Inde"
- `'gallery_tab_exterior'` → "Ude"
- `'gallery_see_all'` → "Se alle billeder"

### Integration
Add to main page after opening hours section, with divider before.

---

## Phase 5: Menu Section with Inline Filter Panel (12-16 hours)

### Goal
Create complete menu section with inline 3-section filter panel that expands/collapses.

### Files to Create
1. `lib/widgets/business_profile/menu_section_widget.dart` (new)
2. `lib/widgets/business_profile/menu_filter_panel_widget.dart` (new)
3. `lib/widgets/business_profile/menu_item_card_widget.dart` (new)

### Implementation Details

#### Menu Section Widget

**Data Source:**
- Read from `businessProvider.menuItems` (Map with categories)
- Read from `businessProvider.availableDietaryPreferences`
- Read from `businessProvider.availableDietaryRestrictions`
- Read from `businessProvider.selectedDietaryRestrictionIds`
- Read from `businessProvider.selectedDietaryPreferenceId`
- Read from `businessProvider.excludedAllergyIds`

**UI Specs (JSX lines 297-497):**

**1. Menu Header:**
- Section heading: "Menu" (18px, weight 680)
- Last reviewed date (if available): "Sidst ajourført {date}" (11.5px, color #bbb, right-aligned)
- Spacing: heading and date on same line with space-between

**2. "Filtrer" Toggle Button:**
- Text: "Filtrer" (collapsed) or "Skjul filtre" (expanded)
- Font: 13.5px, weight 560, color orange (#e8751a)
- No background, no border (text button only)
- Margin bottom: 14px
- Hover opacity: 0.7
- Tap to toggle filter panel

**3. Inline Filter Panel (expanded state):**
- **Container:**
  - Background: #fafafa
  - Border: 1px solid #f0f0f0
  - Border radius: 14px
  - Padding: 16px
  - Margin bottom: 16px
  - Slide-in animation (0.3s ease-out)
- **3 sections:**
  1. **Kostrestriktioner:**
     - Heading: "Kostrestriktioner" (14px, weight 640, color #0f0f0f)
     - Description: "Vis kun retter, der overholder den valgte kostrestriktion." (12px, color #999, margin bottom 10px)
     - Chips: "Glutenfrit", "Laktosefrit"
     - **Multi-select:** User can select multiple
  2. **Kostpræferencer:**
     - Heading: "Kostpræferencer" (14px, weight 640, color #0f0f0f)
     - Description: "Vis kun retter, der overholder den valgte diæt." (12px, color #999, margin bottom 10px)
     - Chips: "Pescetarvenligt", "Vegansk", "Vegetarisk"
     - **Multi-select:** User can select multiple
  3. **Allergener:**
     - Heading: "Allergener" (14px, weight 640, color #0f0f0f)
     - Description: "Skjul retter, der indeholder det valgte allergen." (12px, color #999, margin bottom 10px)
     - Chips: "Bløddyr", "Fisk", "Jordnødder", "Korn", "Mælk", "Æg", "Soja", "Selleri", "Sennep", "Sesamfrø"
     - **Multi-exclude:** Selected allergens hide items containing them
- **Chip styling:**
  - **Selected:** border 1.5px solid orange, background orange, color white, weight 600
  - **Unselected:** border 1.5px solid #e4e4e4, background white, color #666, weight 460
  - Padding: 6px 12px
  - Border radius: 8px
  - Staggered transition delay (50ms × index)

**4. Category Chips (below filter panel):**
- Horizontal scrollable row with 8px gap
- Categories from `menuItems` keys
- **Active category:** border 1.5px solid orange, background orange, color white, weight 600
- **Inactive:** border 1.5px solid #e4e4e4, background white, color #555, weight 480
- Padding: 7px 14px
- Border radius: 9px
- Tap to switch category

**5. Menu Items List:**
- Heading: Active category name (16px, weight 650, margin bottom 2px)
- **Empty state (no items match filters):**
  - Background: #fafafa
  - Border: 1px solid #f0f0f0
  - Border radius: 12px
  - Padding: 32px 20px
  - Center-aligned
  - Icon: info icon (48px, color #d0d0d0)
  - Heading: "Ingen retter matcher dine filtre" (15px, weight 680)
  - Description: "Prøv at fjerne nogle filtre eller vælg 'Ryd alle' for at se hele menuen." (13px, color #888, line height 18px)
- **Menu item card:**
  - Padding: 12px 0
  - Border bottom: 1px solid #f2f2f2 (except last item)
  - **Layout:**
    - Top row: Item name (left, 15px, weight 590) | Price (right, 13.5px, weight 540, color orange)
    - Bottom row: Description (13px, color #999, line height 1.4, max 2 lines with ellipsis)
  - Optional image (133x75, right-aligned, if `item['image_url']` exists)
  - Cursor pointer if item has details

**6. "View Full Menu" Button:**
- Center-aligned
- Text: "Vis på hel side →" (13px, weight 540, color #555)
- Navigate to `/business/:id/menu` route
- Margin top: 12px

**State Management:**
- Local `bool _filterPanelExpanded = false`
- Local `String _activeCategory` (first category by default)
- Filter state managed in `businessProvider`:
  - `selectedDietaryRestrictionIds` (List<int>)
  - `selectedDietaryPreferenceId` (int?)
  - `excludedAllergyIds` (List<int>)

**Filter Logic:**
- On filter change:
  1. Update `businessProvider` filter state
  2. Re-filter menu items based on:
     - Item must have all selected dietary restrictions
     - Item must have selected dietary preference (if any)
     - Item must NOT contain any excluded allergens
  3. Update visible items list
  4. Track analytics (filter interaction)

**Analytics:**
- Track filter panel toggle:
  ```dart
  eventType: 'menu_filter_panel_toggled',
  eventData: {'action': expanded ? 'expanded' : 'collapsed', 'business_id': businessId}
  ```
- Track filter change:
  ```dart
  eventType: 'menu_filter_changed',
  eventData: {
    'filter_type': 'restriction|preference|allergen',
    'filter_id': filterId,
    'filter_name': filterName,
    'action': 'added|removed',
    'business_id': businessId,
  }
  ```
- Track category change:
  ```dart
  eventType: 'menu_category_changed',
  eventData: {'category': categoryName, 'business_id': businessId}
  ```
- Track item tap:
  ```dart
  eventType: 'menu_item_tapped',
  eventData: {
    'item_name': itemName,
    'category': categoryName,
    'has_details': hasDetails,
    'business_id': businessId,
  }
  ```

**Translation Keys:**
- `'menu'` → "Menu"
- `'last_reviewed'` → "Sidst ajourført"
- `'filter_button'` → "Filtrer"
- `'hide_filters'` → "Skjul filtre"
- `'dietary_restrictions'` → "Kostrestriktioner"
- `'dietary_restrictions_desc'` → "Vis kun retter..."
- `'dietary_preferences'` → "Kostpræferencer"
- `'dietary_preferences_desc'` → "Vis kun retter..."
- `'allergens'` → "Allergener"
- `'allergens_desc'` → "Skjul retter..."
- `'no_items_match'` → "Ingen retter matcher dine filtre"
- `'no_items_desc'` → "Prøv at fjerne nogle filtre..."
- `'view_full_menu'` → "Vis på hel side"

### Integration
Add to main page after gallery section, with divider before.

---

## Phase 6: Facilities & Payments (4-5 hours)

### Goal
Display facility pills with **green highlighting** for matches (not orange!), and payment options.

### Files to Modify
1. `lib/widgets/shared/business_feature_buttons.dart` (fix highlighting logic)
2. `lib/widgets/shared/payment_options_widget.dart` (verify styling matches JSX)

### Implementation Details

#### Facilities Section

**Data Source:**
- Read from `businessProvider.currentBusiness['facilities']` (List<Map>)
  - Structure: `[{'filter_id': 123, 'label': 'Kørestolsvenlig', 'description': '...'}, ...]`
- Read from `searchStateProvider.filtersUsedForSearch` (List<int>) to check matches
- Read from filter data to get descriptions for info icon

**UI Specs (JSX lines 501-538):**
- **Section heading:** "Faciliteter og services" (18px, weight 680, margin bottom 12px)
- **Pills layout:**
  - Flex wrap with 8px gap
  - Each pill:
    - Padding: 7px 12px
    - Border radius: 9px (AppRadius.facility)
    - Font: 13px
    - **Matched facility (CRITICAL - GREEN not orange!):**
      - Border: 1.5px solid #d0ecd8 (AppColors.greenBorder)
      - Background: #f0f9f3 (AppColors.greenBg)
      - Text color: #1a9456 (AppColors.green)
      - Font weight: 580 → w600
    - **Non-matched:**
      - Border: 1.5px solid #e8e8e8
      - Background: white
      - Text color: #444
      - Font weight: 480 → w500
    - **Info icon (if description exists):**
      - 12px icon after text
      - Color: green (matched) or #bbb (unmatched)
      - Tap opens `FacilitiesInfoSheet` modal
- **Match detection logic:**
  ```dart
  bool isMatch = filtersUsedForSearch.any((filterId) {
    final facility = facilities.firstWhere(
      (f) => f['filter_id'] == filterId,
      orElse: () => null,
    );
    return facility != null;
  });
  ```

**Analytics:**
- Track info icon tap:
  ```dart
  eventType: 'facility_info_tapped',
  eventData: {
    'facility_id': facilityId,
    'facility_name': facilityName,
    'business_id': businessId,
  }
  ```

#### Payment Options Section

**Data Source:**
- Read from `businessProvider.currentBusiness['payment_methods']` (List<String>)

**UI Specs (JSX lines 542-550):**
- **Section heading:** "Betalingsmuligheder" (18px, weight 680, margin bottom 12px)
- **Pills layout:**
  - Flex wrap with 8px gap
  - Each pill:
    - Padding: 7px 14px
    - Border radius: 9px
    - Border: 1.5px solid #e8e8e8
    - Background: white (no highlighting even if in search filters)
    - Font: 13px, weight 480, color #555
- **Predefined order:** Card types first, then wallets, then cash, then other
  - Order: VISA, MasterCard, Amex, Dankort, MobilePay, Apple Pay, Google Pay, Kontanter, Other
- **Display-only:** No tap interaction

**Translation Keys:**
- `'facilities_and_services'` → "Faciliteter og services"
- `'payment_options'` → "Betalingsmuligheder"

### Integration
Add to main page after menu section, with dividers before each section.

---

## Phase 7: About & Report Link (2-3 hours)

### Goal
Create expandable about section and report link.

### Files to Create
1. `lib/widgets/business_profile/about_section_widget.dart` (new)
2. `lib/widgets/business_profile/report_link_widget.dart` (new)

### Implementation Details

#### About Section Widget

**Data Source:**
- Read from `businessProvider.currentBusiness['about']` (String?)
- Conditional display: hide if about text is null or empty

**UI Specs (JSX lines 552-563):**
- **Header (button):**
  - Full-width row with space-between
  - Left: "Om" heading (18px, weight 680, color #0f0f0f)
  - Right: Chevron icon (14px, color #999, rotates 180° when expanded)
  - Padding: 0
  - No background, no border
  - Tap to toggle expansion
- **Expanded content:**
  - Paragraph text (14px, color #555, line height 1.65)
  - Margin top: 12px
  - Margin bottom: 0

**State Management:**
- Local `bool _isExpanded = false` in `ConsumerStatefulWidget`

**Analytics:**
- Track expansion:
  ```dart
  eventType: 'about_section_toggled',
  eventData: {
    'action': _isExpanded ? 'expanded' : 'collapsed',
    'business_id': businessId,
  }
  ```

**Translation Keys:**
- `'about'` → "Om"

#### Report Link Widget

**UI Specs (JSX line 564 + design notes):**
- **Section:**
  - Padding: 24px 24px 44px (large bottom padding)
  - Center-aligned
- **Button:**
  - Text: "Rapportér manglende eller forkerte oplysninger" (13px, weight 500, color #bbb)
  - Underline decoration with 3px offset
  - No background, no border
  - Tap opens `ErroneousInfoFormWidget` bottom sheet (existing widget)

**Analytics:**
- Track button tap:
  ```dart
  eventType: 'report_link_tapped',
  eventData: {'business_id': businessId}
  ```

**Translation Keys:**
- `'report_incorrect_info'` → "Rapportér manglende eller forkerte oplysninger"

### Integration
Add to main page after payments section, with divider before about section.

---

## Phase 8: Info Icon & Navigation (1-2 hours)

### Goal
Verify info icon in AppBar navigates correctly (already implemented in Phase 1).

### Verification Steps
1. Verify `Icons.info_outline` in AppBar actions (line ~291)
2. Verify navigation to `/business/:id/information` route
3. Verify analytics tracking on tap
4. Test navigation flow

**No new files needed** - this was completed in Phase 1.

---

## Final Integration & Testing (3-4 hours)

### Main Page Assembly

Update `business_profile_page_v2.dart` to include all sections:

```dart
Widget _buildContent() {
  return CustomScrollView(
    slivers: [
      SliverPadding(
        padding: EdgeInsets.only(
          top: AppSpacing.lg,
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
        ),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            // 1. Hero Section
            const HeroSectionWidget(),
            SizedBox(height: AppSpacing.mlg),

            // 2. Quick Actions Pills
            const QuickActionsPillsWidget(),
            SizedBox(height: AppSpacing.lg),

            // 3. Match Card (if filters active)
            const MatchCardWidgetV2(),
            SizedBox(height: AppSpacing.lg),

            // 4. Tags Row (if tags exist)
            const TagsRowWidget(),
            SizedBox(height: AppSpacing.lg),

            // DIVIDER
            Container(height: 1, color: AppColors.divider),
            SizedBox(height: AppSpacing.lg),

            // 5. Opening Hours & Contact
            const OpeningHoursContactWidget(),
            SizedBox(height: AppSpacing.lg),

            // DIVIDER
            Container(height: 1, color: AppColors.divider),

            // 6. Gallery
            const GallerySectionWidget(),
            SizedBox(height: AppSpacing.lg),

            // DIVIDER
            Container(height: 1, color: AppColors.divider),

            // 7. Menu
            const MenuSectionWidget(),
            SizedBox(height: AppSpacing.lg),

            // DIVIDER
            Container(height: 1, color: AppColors.divider),

            // 8. Facilities
            const FacilitiesSectionWidget(),
            SizedBox(height: AppSpacing.lg),

            // DIVIDER
            Container(height: 1, color: AppColors.divider),

            // 9. Payment Options
            const PaymentOptionsSectionWidget(),
            SizedBox(height: AppSpacing.lg),

            // DIVIDER
            Container(height: 1, color: AppColors.divider),

            // 10. About
            const AboutSectionWidget(),
            SizedBox(height: AppSpacing.lg),

            // DIVIDER
            Container(height: 1, color: AppColors.divider),

            // 11. Report Link
            const ReportLinkWidget(),
          ]),
        ),
      ),
    ],
  );
}
```

### Comprehensive Testing Checklist

#### Visual Design Verification
- [ ] Quick action pills: white bg, gray border, dark text/icons ✅
- [ ] Match card: green for 100%, orange for partial ✅
- [ ] Gallery tabs: flat with 2px orange bottom border (not pills!)
- [ ] Menu filter panel: inline 3-section layout (not modal)
- [ ] Facilities pills: green highlighting for matches (not orange!)
- [ ] All spacing matches JSX specs
- [ ] All border radii match JSX specs
- [ ] All colors match design tokens

#### Functional Verification
- [ ] Quick actions launch correct apps ✅
- [ ] Match card shows correct matched/missed filters
- [ ] Match card expands/collapses smoothly
- [ ] Tags display horizontally scrollable
- [ ] Opening hours expand/collapse smoothly
- [ ] Contact links work (call, email, open URLs)
- [ ] Gallery tabs switch content correctly
- [ ] Gallery images swipeable
- [ ] Gallery images tap to full-screen modal
- [ ] Menu filter panel expands/collapses inline
- [ ] Menu filter chips toggle correctly
- [ ] Menu items filter based on selections
- [ ] Empty state shows when no items match
- [ ] Facilities open info sheet on tap
- [ ] Green highlights only matched facilities
- [ ] Payment options display correctly
- [ ] About section expands/collapses
- [ ] Report link opens form
- [ ] Info icon navigates to information page ✅

#### Analytics Verification
- [ ] Page view tracked ✅
- [ ] Session duration tracked ✅
- [ ] Quick action taps tracked ✅
- [ ] Match card expand/collapse tracked
- [ ] Gallery tab changes tracked
- [ ] Gallery image taps tracked
- [ ] Menu filter changes tracked
- [ ] Menu category changes tracked
- [ ] Menu item taps tracked
- [ ] Facility info taps tracked
- [ ] About expand/collapse tracked
- [ ] Report link tap tracked
- [ ] Info button tap tracked ✅
- [ ] Share button tap tracked ✅

#### Code Quality
- [ ] All text uses `td(ref, 'key')` ✅
- [ ] All colors use `AppColors` or JSX hex values ✅
- [ ] All spacing uses `AppSpacing` constants ✅
- [ ] All typography uses `AppTypography` styles ✅
- [ ] No raw magic numbers ✅
- [ ] `flutter analyze` passes with no errors ✅
- [ ] No FFAppState usage ✅
- [ ] Self-contained widgets ✅

---

## Migration Strategy

1. **Develop v2 alongside v1:** All v2 files created in parallel (no breaking changes)
2. **Test v2 thoroughly:** Use test route `/business/:id/v2` for testing
3. **Update router:** Switch main route to use v2 page once verified
4. **Remove old files:** Delete FlutterFlow-migrated files after successful deployment
5. **Monitor analytics:** Compare v1 vs v2 metrics for 1 week

---

## Success Criteria

### Must Complete
✅ All 12 sections render correctly with JSX-matching UI
✅ Menu filter panel is inline and collapsible (not modal)
✅ Gallery tabs are flat with bottom border indicator (not pills)
✅ Quick actions have white background with border (not orange)
✅ Facilities use green highlighting for matches (not orange)
✅ All text uses translation keys
✅ All colors use design tokens or JSX hex values
✅ All API data displays correctly
✅ All analytics tracking works
✅ `flutter analyze` passes

### Nice to Have
- Smooth animations for all expand/collapse interactions
- Optimized performance for large menus
- Accessibility support (semantic labels, tap targets)
- Loading states and error handling
- Skeleton screens for async data

---

## Estimated Total Time

- **Phase 1:** 4-6 hours ✅ COMPLETE
- **Phase 2:** 2-3 hours
- **Phase 3:** 3-4 hours
- **Phase 4:** 6-8 hours
- **Phase 5:** 12-16 hours
- **Phase 6:** 4-5 hours
- **Phase 7:** 2-3 hours
- **Phase 8:** 1-2 hours (already done)
- **Final Integration:** 3-4 hours

**Total:** 37-51 hours (2-3 days focused work per phase)

---

## Notes for Implementation

- **Follow JSX exactly:** When in doubt, check JSX reference lines
- **Self-contained widgets:** Each widget reads providers internally, no infrastructure props
- **Analytics fire-and-forget:** Never await analytics calls
- **Translation keys:** Use `td(ref, 'key')` for all text
- **Design tokens:** Use `AppColors`, `AppSpacing`, `AppTypography`, `AppRadius`
- **Test incrementally:** Verify each phase compiles before moving to next
- **Commit frequently:** Commit after each phase completion

---

**Last Updated:** 2026-02-25
**Status:** Phase 1 Complete, Ready for Phase 2
