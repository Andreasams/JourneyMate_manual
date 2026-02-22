# Phase 7.4 ImageGalleryWidget Implementation — Session Handover

**Created:** 2026-02-22
**Context:** Preparatory work for Session 5 (Profile Component Widgets)
**Working Directory:** `C:\Users\Rikke\Documents\JourneyMate-Organized`

---

## Executive Summary

**What Was Just Completed:**
- ✅ All 4 custom functions for ProfileTopBusinessBlockWidget
- ✅ 1 custom action (determineStatusAndColor) for business status calculation
- ✅ LatLng model class created
- ✅ flutter analyze: 0 issues
- ✅ All committed and documented

**What Needs to Be Done Next:**
- 🎯 **IMMEDIATE TASK:** Implement ImageGalleryWidget (~1,000 lines)
- 🎯 **AFTER THAT:** Session 5 Profile Components (3 widgets)
- 🎯 **THEN:** Continue Phase 7.4 Sessions 6-11 per plan

**Why ImageGalleryWidget Must Come First:**
- `ImageGalleryOverlaySwipableWidget` (Session 5) wraps `ImageGalleryWidget`
- Cannot implement the wrapper without the core gallery widget
- Documented dependency in Phase 7.4 plan

---

## Current Project State

### Phase Status
- **Phase 7 Preliminary Task:** 34/34 widgets complete (100%) ✅
- **Phase 7.3 (Search Page):** Complete ✅
- **Phase 7.4 (Business Profile Page):** IN PROGRESS 🔄
  - Custom functions/actions: Complete ✅
  - ImageGalleryWidget: **NEXT TASK** ⏭️
  - Profile Components (Sessions 5-7): Pending
  - Page Implementation (Sessions 8-11): Pending

### Files Just Created (2026-02-22)

**Custom Functions:**
```
journey_mate/lib/services/custom_functions/
  ├── distance_calculator.dart         (64 lines)
  ├── address_formatter.dart           (92 lines)
  ├── hours_formatter.dart             (347 lines)
  └── price_formatter.dart             (already existed from Session #16)
```

**Custom Action:**
```
journey_mate/lib/services/custom_actions/
  └── determine_status_and_color.dart  (407 lines)
```

**Model:**
```
journey_mate/lib/models/
  └── lat_lng.dart                     (24 lines)
```

**Git Status:**
- All changes committed
- Branch: main
- Last commit: "docs: update SESSION_STATUS.md - Phase 7.4 custom functions/actions complete"

---

## ImageGalleryWidget — Implementation Specification

### Overview

**Purpose:**
Full-screen image gallery with swipeable carousel, category labels, and analytics tracking.

**Complexity:** ⭐⭐⭐⭐ High (~1,000 lines)

**Type:** StatefulWidget with AnimationController

**Key Features:**
1. **PageView carousel** with infinite scroll (virtual page multiplier pattern)
2. **Single image mode** with bounce effect (drag up to 100px, snaps back)
3. **Category labels** overlay (Food/Drinks/Interior/Overview)
4. **Close button** (top-left X)
5. **Analytics tracking** for gallery_opened, navigation, and gallery_closed events
6. **Gradient overlays** for better text readability
7. **Cached network images** with loading/error states

### File Locations

**Implementation Target:**
```
journey_mate/lib/widgets/shared/image_gallery_widget.dart
```

**Documentation Sources (READ THESE FIRST):**
1. `shared/widgets/MASTER_README_image_gallery_widget.md` (982 lines)
   - Complete specification with all parameters
   - Analytics tracking requirements
   - Edge cases and examples

2. `_flutterflow_export/lib/custom_code/widgets/image_gallery_widget.dart` (ground truth)
   - Actual FlutterFlow implementation
   - Virtual page indexing logic
   - Bounce effect math

3. `DESIGN_SYSTEM_flutter.md` — Design tokens reference

4. `_reference/PROVIDERS_REFERENCE.md` — Provider usage patterns

### Function Signature

```dart
class ImageGalleryWidget extends StatefulWidget {
  const ImageGalleryWidget({
    super.key,
    this.width,
    this.height,
    required this.imageUrls,
    required this.currentIndex,
    required this.categoryName,
    this.onClose,
  });

  final double? width;
  final double? height;
  final List<String> imageUrls;
  final int currentIndex;
  final String categoryName;
  final Future<void> Function(bool?)? onClose;

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}
```

### Key Implementation Details

#### 1. Virtual Page Indexing (Infinite Scroll)

**Pattern from FlutterFlow:**
```dart
// Multiply real index by 1000 for infinite scroll feel
const int virtualPageMultiplier = 1000;
final int virtualInitialPage = currentIndex * virtualPageMultiplier;

// Controller
final PageController pageController = PageController(
  initialPage: virtualInitialPage,
);

// Builder
PageView.builder(
  controller: pageController,
  itemBuilder: (context, virtualIndex) {
    final realIndex = virtualIndex % imageUrls.length;
    return _buildImagePage(imageUrls[realIndex]);
  },
);
```

**Why:** Creates illusion of infinite scrolling (swipe backward from first image wraps to last)

#### 2. Single Image Mode (Bounce Effect)

**When:** `imageUrls.length == 1`

**Pattern:**
```dart
GestureDetector(
  onVerticalDragUpdate: (details) {
    // Allow drag up to 100px, then resistance
    final dragAmount = details.primaryDelta ?? 0;
    // Apply drag with damping
  },
  onVerticalDragEnd: (details) {
    // Snap back to original position with animation
  },
  child: Transform.translate(
    offset: Offset(0, _dragOffset),
    child: _buildImagePage(imageUrls[0]),
  ),
)
```

**Max drag:** 100px vertically (with resistance curve)

#### 3. Analytics Tracking

**Fire 3 events:**

**gallery_opened** (on initState):
```dart
ApiService.instance.postAnalytics(
  eventType: 'gallery_opened',
  deviceId: deviceId,
  sessionId: sessionId,
  userId: userId,
  eventData: {
    'category': categoryName,
    'initial_index': currentIndex,
    'total_images': imageUrls.length,
  },
  timestamp: DateTime.now().toIso8601String(),
);
```

**gallery_image_viewed** (on page change):
```dart
ApiService.instance.postAnalytics(
  eventType: 'gallery_image_viewed',
  deviceId: deviceId,
  sessionId: sessionId,
  userId: userId,
  eventData: {
    'category': categoryName,
    'image_index': realIndex,
    'total_images': imageUrls.length,
    'navigation_method': 'swipe', // or 'programmatic'
  },
  timestamp: DateTime.now().toIso8601String(),
);
```

**gallery_closed** (on dispose or close button):
```dart
ApiService.instance.postAnalytics(
  eventType: 'gallery_closed',
  deviceId: deviceId,
  sessionId: sessionId,
  userId: userId,
  eventData: {
    'category': categoryName,
    'final_index': _currentRealIndex,
    'total_images': imageUrls.length,
    'time_spent_seconds': timeDifference,
  },
  timestamp: DateTime.now().toIso8601String(),
);
```

**Important:** All analytics are fire-and-forget (no await, no error handling blocks UI)

#### 4. Design Tokens

**Colors:**
- Overlay gradient: `AppColors.textPrimary.withValues(alpha: 0.6)`
- Close button background: `AppColors.bgCard.withValues(alpha: 0.8)`
- Category label background: `AppColors.bgInput.withValues(alpha: 0.9)`

**Spacing:**
- Close button position: `top: AppSpacing.xl, left: AppSpacing.xl`
- Category label position: `bottom: AppSpacing.xxl, right: AppSpacing.xl`
- Category label padding: `EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm)`

**Typography:**
- Category label: `AppTypography.body1.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)`

**Radius:**
- Category label border: `BorderRadius.circular(AppRadius.button)`

#### 5. Image Loading

**Use CachedNetworkImage:**
```dart
CachedNetworkImage(
  imageUrl: imageUrl,
  fit: BoxFit.contain,
  placeholder: (context, url) => Center(
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
    ),
  ),
  errorWidget: (context, url, error) => Center(
    child: Icon(
      Icons.error_outline,
      size: 48,
      color: AppColors.textSecondary,
    ),
  ),
)
```

#### 6. Close Button

**Pattern:**
```dart
Positioned(
  top: AppSpacing.xl,
  left: AppSpacing.xl,
  child: SafeArea(
    child: Material(
      color: AppColors.bgCard.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(AppRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.button),
        onTap: () async {
          // Fire gallery_closed analytics
          if (onClose != null) {
            await onClose!(true);
          } else {
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            Icons.close,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
      ),
    ),
  ),
)
```

#### 7. Edge Cases to Handle

| Case | Behavior |
|------|----------|
| Empty imageUrls list | Show error message, don't crash |
| currentIndex out of bounds | Clamp to valid range (0 to length-1) |
| Single image | Enable bounce effect, disable PageView |
| Network error | Show error icon, allow retry |
| Very tall image | Use BoxFit.contain (don't crop) |
| Very wide image | Use BoxFit.contain (don't crop) |

---

## Implementation Checklist

### Pre-Implementation (5 minutes)

- [ ] Read `shared/widgets/MASTER_README_image_gallery_widget.md` completely
- [ ] Read FlutterFlow source: `_flutterflow_export/lib/custom_code/widgets/image_gallery_widget.dart`
- [ ] Review `DESIGN_SYSTEM_flutter.md` for AppColors, AppSpacing, AppTypography, AppRadius
- [ ] Review `_reference/PROVIDERS_REFERENCE.md` for analyticsProvider usage

### Core Implementation (90 minutes)

- [ ] Create `journey_mate/lib/widgets/shared/image_gallery_widget.dart`
- [ ] Add StatefulWidget scaffold with all 6 parameters
- [ ] Implement state variables:
  - [ ] `PageController _pageController`
  - [ ] `int _currentRealIndex`
  - [ ] `double _dragOffset` (for bounce effect)
  - [ ] `DateTime _openedAt` (for analytics)
  - [ ] `AnimationController?` (if using bounce animation)
- [ ] Implement initState():
  - [ ] Initialize PageController with virtual initial page
  - [ ] Fire gallery_opened analytics
  - [ ] Store _openedAt timestamp
- [ ] Implement dispose():
  - [ ] Fire gallery_closed analytics
  - [ ] Dispose PageController
  - [ ] Dispose AnimationController (if using)
- [ ] Implement build() for imageUrls.length > 1:
  - [ ] Stack with PageView.builder
  - [ ] Virtual page indexing (% imageUrls.length)
  - [ ] PageView listener for page changes → analytics
  - [ ] CachedNetworkImage for each page
  - [ ] Positioned close button (top-left)
  - [ ] Positioned category label (bottom-right)
  - [ ] Gradient overlay for readability
- [ ] Implement build() for imageUrls.length == 1:
  - [ ] GestureDetector for vertical drag
  - [ ] Transform.translate with _dragOffset
  - [ ] Bounce animation on drag end
  - [ ] Same close button + category label
- [ ] Handle empty imageUrls:
  - [ ] Show error message
  - [ ] Close button still works

### Analytics Integration (15 minutes)

- [ ] Import `AnalyticsService` + `ApiService`
- [ ] Import `analyticsProvider` from app_providers
- [ ] Extract deviceId, sessionId, userId from analyticsProvider
- [ ] Fire gallery_opened in initState (fire-and-forget)
- [ ] Fire gallery_image_viewed on page change (fire-and-forget)
- [ ] Fire gallery_closed in dispose (fire-and-forget)
- [ ] Calculate time_spent_seconds correctly

### Design Token Compliance (15 minutes)

- [ ] All colors use AppColors (no raw Color() or Colors.*)
- [ ] All spacing uses AppSpacing (no magic numbers)
- [ ] All text styles use AppTypography
- [ ] All border radius uses AppRadius
- [ ] Use .withValues(alpha:) instead of .withOpacity() (Flutter 3.x)

### Testing & Verification (15 minutes)

- [ ] Run `flutter analyze` → must return "No issues found!"
- [ ] Test with 1 image (bounce effect works)
- [ ] Test with 3+ images (infinite scroll works)
- [ ] Test close button (fires analytics, calls onClose callback)
- [ ] Test swipe left/right (page changes, analytics fires)
- [ ] Test empty list (shows error, doesn't crash)
- [ ] Check all design tokens applied (no raw colors/spacing)

### Commit & Document (10 minutes)

- [ ] Commit with message: `feat(phase7.4-prep): implement ImageGalleryWidget - full-screen gallery with infinite scroll`
- [ ] Update SESSION_STATUS.md:
  - Phase: Phase 7.4 prep complete
  - Last completed: ImageGalleryWidget implementation
  - Next task: Session 5 Profile Components (3 widgets)
- [ ] No translation keys needed (uses categoryName passed as prop)

---

## Dependencies & Imports

### Required Imports

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Theme
import '../../theme/app_theme.dart';

// Services
import '../../services/api_service.dart';
import '../../services/analytics_service.dart';

// Providers
import '../../providers/app_providers.dart';
```

### Already Available Packages

All required packages are already in `pubspec.yaml`:
- ✅ `cached_network_image: ^3.4.1`
- ✅ `flutter_riverpod: ^3.2.1`

No additional dependencies needed.

---

## Common Pitfalls to Avoid

### 1. Virtual Page Index Math Error

❌ **WRONG:**
```dart
final realIndex = virtualIndex ~/ imageUrls.length;
```

✅ **CORRECT:**
```dart
final realIndex = virtualIndex % imageUrls.length;
```

**Why:** Modulo (%) gives remainder, which maps virtual → real index correctly.

### 2. Forgetting to Dispose Controllers

❌ **WRONG:**
```dart
@override
void dispose() {
  super.dispose();
}
```

✅ **CORRECT:**
```dart
@override
void dispose() {
  _pageController.dispose();
  _animationController?.dispose();
  super.dispose();
}
```

**Why:** Memory leak if controllers not disposed.

### 3. Awaiting Analytics Calls

❌ **WRONG:**
```dart
await ApiService.instance.postAnalytics(...);
```

✅ **CORRECT:**
```dart
ApiService.instance.postAnalytics(...); // Fire-and-forget, no await
```

**Why:** Analytics should never block UI. Let them fail silently.

### 4. Using MaterialStateProperty Instead of WidgetStateProperty

❌ **WRONG (Flutter 3.x deprecated):**
```dart
MaterialStateProperty.all<Color>(AppColors.accent)
```

✅ **CORRECT (Flutter 3.x):**
```dart
WidgetStateProperty.all<Color>(AppColors.accent)
```

### 5. Using .withOpacity() Instead of .withValues()

❌ **WRONG (Flutter 3.x deprecated):**
```dart
AppColors.textPrimary.withOpacity(0.6)
```

✅ **CORRECT (Flutter 3.x):**
```dart
AppColors.textPrimary.withValues(alpha: 0.6)
```

### 6. Hard-Coding Colors or Spacing

❌ **WRONG:**
```dart
Positioned(
  top: 20.0,
  left: 20.0,
  child: Container(
    color: Color(0x99FFFFFF),
    // ...
  ),
)
```

✅ **CORRECT:**
```dart
Positioned(
  top: AppSpacing.xl,
  left: AppSpacing.xl,
  child: Container(
    color: AppColors.bgCard.withValues(alpha: 0.8),
    // ...
  ),
)
```

---

## After ImageGalleryWidget is Complete

### Next Session: Profile Components (Session 5)

**Implement 3 widgets:**

1. **ProfileTopBusinessBlockWidget** (~600 lines)
   - Uses all 4 custom functions + determineStatusAndColor action
   - Hero section with business image, name, type, status
   - "Why This Match?" card with matched/missed filters
   - Address + distance display

2. **ContactDetailWidget** (~500 lines)
   - Contact modal bottom sheet
   - Phone/website/address/Instagram display
   - "Open in Maps" button with map_launcher
   - Copy-to-clipboard with toast confirmation

3. **ImageGalleryOverlaySwipableWidget** (~100 lines)
   - Thin wrapper around ImageGalleryWidget
   - Receives parameters from parent
   - Passes to ImageGalleryWidget with Navigator.pop on close

**Estimated time:** 2-3 hours for all 3 widgets

---

## Quick Reference

### Key File Paths

**Implementation target:**
```
journey_mate/lib/widgets/shared/image_gallery_widget.dart
```

**Documentation sources:**
```
shared/widgets/MASTER_README_image_gallery_widget.md
_flutterflow_export/lib/custom_code/widgets/image_gallery_widget.dart
DESIGN_SYSTEM_flutter.md
_reference/PROVIDERS_REFERENCE.md
```

**Custom functions (just created, ready to use):**
```
journey_mate/lib/services/custom_functions/distance_calculator.dart
journey_mate/lib/services/custom_functions/address_formatter.dart
journey_mate/lib/services/custom_functions/hours_formatter.dart
journey_mate/lib/services/custom_functions/price_formatter.dart
```

**Custom action (just created, ready to use):**
```
journey_mate/lib/services/custom_actions/determine_status_and_color.dart
```

### Design Token Quick Reference

```dart
// Colors
AppColors.accent        // Orange #e8751a
AppColors.matchGreen    // Green #1a9456
AppColors.textPrimary   // Text primary
AppColors.textSecondary // Text secondary
AppColors.bgCard        // Card background
AppColors.bgInput       // Input background

// Spacing
AppSpacing.sm    // 8px
AppSpacing.md    // 12px
AppSpacing.lg    // 16px
AppSpacing.xl    // 20px
AppSpacing.xxl   // 24px

// Typography
AppTypography.h1     // 24px w800
AppTypography.h2     // 18px w700
AppTypography.body1  // 14px w400
AppTypography.body2  // 12.5px w500

// Radius
AppRadius.card          // 16px
AppRadius.button        // 14px
AppRadius.bottomSheet   // 22px
```

### Analytics Provider Usage

```dart
// Get IDs for analytics
final analyticsState = ref.read(analyticsProvider);
final deviceId = AnalyticsService.instance.deviceId ?? 'unknown';
final sessionId = analyticsState.sessionId ?? 'unknown';
final userId = AnalyticsService.instance.userId ?? 'unknown';

// Fire analytics (fire-and-forget, no await)
ApiService.instance.postAnalytics(
  eventType: 'gallery_opened',
  deviceId: deviceId,
  sessionId: sessionId,
  userId: userId,
  eventData: {'key': 'value'},
  timestamp: DateTime.now().toIso8601String(),
);
```

---

## Success Criteria

ImageGalleryWidget is complete when:

- ✅ File created: `journey_mate/lib/widgets/shared/image_gallery_widget.dart`
- ✅ All 6 parameters implemented correctly
- ✅ Virtual page indexing works (infinite scroll feel)
- ✅ Single image bounce effect works (100px max drag)
- ✅ Close button fires analytics and calls onClose callback
- ✅ Category label displays correctly (bottom-right)
- ✅ All 3 analytics events fire correctly (gallery_opened, gallery_image_viewed, gallery_closed)
- ✅ All design tokens used (no raw colors, no magic numbers)
- ✅ CachedNetworkImage with proper loading/error states
- ✅ Edge cases handled (empty list, out of bounds index, network errors)
- ✅ `flutter analyze` returns "No issues found!"
- ✅ Committed with descriptive message
- ✅ SESSION_STATUS.md updated

**After completion:**
- 🎯 Ready to start Session 5 (Profile Component Widgets)
- 🎯 All dependencies for ProfileTopBusinessBlockWidget available
- 🎯 Phase 7.4 can proceed to Sessions 6-11 (page implementation)

---

**End of Handover Document**

**Created:** 2026-02-22
**For:** ImageGalleryWidget implementation session
**Part of:** Phase 7.4 Business Profile Page implementation
