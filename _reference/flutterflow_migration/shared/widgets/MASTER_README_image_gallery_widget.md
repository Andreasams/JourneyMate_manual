# ImageGalleryWidget — Custom Widget Documentation

**File:** `lib/custom_code/widgets/image_gallery_widget.dart`
**Type:** Custom StatefulWidget (Full-Screen Gallery Viewer)
**Category:** UI Component — Image Display & Navigation

---

## Purpose

ImageGalleryWidget is a full-screen image viewer that provides a sophisticated gallery experience for displaying restaurant images. It supports both single-image viewing with bounce effect and multi-image carousel navigation with infinite scroll. The widget features gesture-based navigation, custom arrow buttons, analytics tracking, and a semi-transparent backdrop overlay.

**Primary use cases:**
- Full-screen restaurant image galleries from Business Profile page
- Menu category image viewing
- Food item photo galleries
- Any context requiring immersive image display with navigation

**Key behaviors:**
- **Single Image Mode:** Displays one image with horizontal drag bounce effect (no swipe navigation)
- **Multi-Image Mode:** PageView carousel with infinite scroll, arrow buttons, and swipe gestures
- **Analytics Tracking:** Tracks gallery opens, image navigation, and close methods
- **Backdrop Dismiss:** Tapping the backdrop closes the gallery
- **Close Button:** Always-visible X button in top-left corner
- **Drag Protection:** Prevents accidental closes during drag/swipe gestures

---

## Function Signature

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
  final Future Function(bool? closeAction)? onClose;
}
```

---

## Parameters

### Required Parameters

#### `imageUrls` (List<String>)
**Purpose:** List of image URLs to display in the gallery
**Source:** Restaurant data from Supabase (images array)
**Validation:**
- Must not be empty
- URLs should be valid network image paths
- Used to determine single vs multi-image mode

**Example Values:**
```dart
// Single image
['https://example.com/image1.jpg']

// Multi-image carousel
[
  'https://example.com/interior1.jpg',
  'https://example.com/interior2.jpg',
  'https://example.com/food1.jpg',
  'https://example.com/food2.jpg'
]
```

#### `currentIndex` (int)
**Purpose:** The index of the image to display initially
**Source:** Tapped image index from grid or list view
**Validation:** Must be valid index within imageUrls array (0 to length-1)
**Behavior:**
- In multi-image mode, determines starting position in carousel
- In single-image mode, should be 0 (only one image)
- Used for infinite scroll calculation via virtual page indexing

**Example Values:**
```dart
0  // Start at first image
2  // Start at third image (from grid tap)
```

#### `categoryName` (String)
**Purpose:** Category identifier for analytics tracking
**Source:** Menu category name or image source context
**Used In:** All analytics events to track which category's gallery was viewed

**Example Values:**
```dart
'Interior'
'Food'
'Exterior'
'Menu Items'
'Desserts'
```

---

### Optional Parameters

#### `width` (double?)
**Purpose:** Gallery container width
**Default:** null (uses Positioned.fill for full screen)
**Typical Value:** `double.infinity`
**Note:** Usually passed as double.infinity from parent Container

#### `height` (double?)
**Purpose:** Gallery container height
**Default:** null (uses Positioned.fill for full screen)
**Typical Value:** `double.infinity`
**Note:** Usually passed as double.infinity from parent Container

#### `onClose` (Future Function(bool? closeAction)?)
**Purpose:** Callback function invoked when gallery is closed
**Parameter:** `closeAction` — always receives `true` when triggered
**Typical Action:** `Navigator.pop(context)` to dismiss the overlay
**Called When:**
- User taps the close button (top-left X)
- User taps the backdrop (anywhere outside image)
- NOT called during drag gestures (protected by `_isDragging` flag)

**Example:**
```dart
onClose: (closeAction) async {
  Navigator.pop(context);
}
```

---

## Dependencies

### Flutter Packages
```dart
import 'package:flutter/material.dart';
```

### FlutterFlow Framework Imports
```dart
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart';
import '/flutter_flow/custom_functions.dart';
```

### Custom Actions Used
- **`trackAnalyticsEvent`** — Tracks user interactions with the gallery
- **`markUserEngaged`** — Marks user engagement on navigation actions

### Flutter Widgets Used
- **PageController** — Manages multi-image carousel scrolling
- **PageView.builder** — Infinite scroll image carousel
- **GestureDetector** — Handles taps, drags, and swipes
- **AnimatedContainer** — Smooth bounce animation for single image
- **CustomPaint** — Draws custom arrow icons
- **Material / Ink / InkWell** — Material ripple effects on buttons
- **Image.network** — Loads and displays images from URLs

---

## State Management

### State Variables

#### `_pageController` (PageController)
**Purpose:** Controls PageView scrolling in multi-image mode
**Initialization:** Created with initial page set to virtual index
**Lifecycle:** Disposed in `dispose()` when `_hasMultipleImages` is true

#### `_currentPage` (int)
**Purpose:** Tracks current page index in multi-image carousel
**Initial Value:** Calculated via `_calculateVirtualPageIndex(widget.currentIndex)`
**Updates:** On page change via `_handlePageChanged()`
**Virtual Index:** Uses modulo to map to actual image index

#### `_dragOffset` (double)
**Purpose:** Tracks horizontal drag distance for single-image bounce effect
**Range:** Clamped between `-100.0` and `100.0` pixels
**Reset:** Animated back to `0.0` on drag end

#### `_isDragging` (bool)
**Purpose:** Prevents accidental gallery closes during drag/swipe gestures
**Set True:** On drag start (single image) or horizontal drag start (carousel)
**Set False:** After 300ms delay via `_resetDraggingStateAfterDelay()`
**Checked:** Before executing close actions in `_handleClose()`

---

### Constants

#### Visual Constants
```dart
static const double _backdropOpacity = 0.3;          // Semi-transparent black backdrop
static const double _closeButtonOpacity = 0.5;       // Close button background
static const double _closeButtonSize = 24.0;         // Icon size
static const double _closeButtonPadding = 8.0;       // Padding inside button
static const double _closeButtonMargin = 16.0;       // Distance from screen edge
static const double _maxDragOffset = 100.0;          // Max bounce distance
```

#### Timing Constants
```dart
static const Duration _dragAnimationDuration = Duration(milliseconds: 300);
static const Duration _dragResetDelay = Duration(milliseconds: 300);
static const Curve _dragAnimationCurve = Curves.easeOutBack;  // Bounce effect
```

#### Infinite Scroll Constant
```dart
static const int _virtualMultiplier = 1000;
```
**Purpose:** Creates virtual page space for infinite scrolling
**Calculation:** Total pages = `imageUrls.length * 1000`
**Center Point:** `imageUrls.length * 500`
**Effect:** Allows scrolling thousands of pages in either direction without visible jumps

---

## FFAppState Usage

**FFAppState Access:** None

**Reason:** ImageGalleryWidget is a pure UI component that:
- Receives all data via parameters
- Does not persist state between sessions
- Does not interact with global app state
- Only manages local UI state (page position, drag offset, dragging flag)

---

## Analytics Tracking

The widget tracks three types of analytics events:

### 1. Gallery Opened
**Event Name:** `'image_gallery_opened'`
**Triggered:** On widget initialization (`initState`)
**Parameters:**
```dart
{
  'category': widget.categoryName,            // e.g., 'Interior', 'Food'
  'total_images': widget.imageUrls.length,    // Number of images
  'initial_image_index': widget.currentIndex, // Starting position
  'gallery_type': _hasMultipleImages ? 'carousel' : 'single'
}
```

**Purpose:** Track which galleries users open and from which categories

---

### 2. Image Navigation
**Event Name:** `'image_gallery_navigation'`
**Triggered:** On image change (swipe, arrow left, arrow right)
**Parameters:**
```dart
{
  'category': widget.categoryName,
  'navigation_method': method,  // 'arrow_left', 'arrow_right', 'swipe'
  'from_index': oldIndex % widget.imageUrls.length,
  'to_index': newIndex % widget.imageUrls.length,
  'total_images': widget.imageUrls.length
}
```

**Navigation Methods:**
- `'arrow_left'` — Left arrow button tap
- `'arrow_right'` — Right arrow button tap
- `'swipe'` — PageView swipe gesture (only if consecutive page change)

**Purpose:** Track how users navigate through galleries

---

### 3. Gallery Closed
**Event Name:** `'image_gallery_closed'`
**Triggered:** When user closes the gallery
**Parameters:**
```dart
{
  'category': widget.categoryName,
  'close_method': closeMethod,  // 'close_button' or 'backdrop_tap'
  'final_image_index': _hasMultipleImages ? (_currentPage % imageUrls.length) : 0,
  'total_images': widget.imageUrls.length
}
```

**Close Methods:**
- `'close_button'` — X button tap
- `'backdrop_tap'` — Backdrop tap

**Purpose:** Track how users exit galleries and which image they ended on

---

### Error Handling in Analytics
All analytics events use `.catchError()` to prevent tracking failures from affecting UX:

```dart
trackAnalyticsEvent('event_name', {...}).catchError((error) {
  debugPrint('⚠️ Failed to track [event]: $error');
});
```

---

## Core Behaviors

### Single Image Mode (`imageUrls.length == 1`)

**Characteristics:**
- No PageView or arrow buttons
- Horizontal drag creates bounce effect (max 100px either direction)
- AnimatedContainer with `Curves.easeOutBack` for spring-back animation
- Drag resets to center position (offset: 0) on release
- No swipe-to-dismiss functionality

**Gesture Handling:**
1. `onHorizontalDragStart` → Set `_isDragging = true`
2. `onHorizontalDragUpdate` → Update `_dragOffset` (clamped to ±100px)
3. `onHorizontalDragEnd` → Reset `_dragOffset = 0`, animate back to center
4. After 300ms delay → Set `_isDragging = false`

---

### Multi-Image Mode (`imageUrls.length > 1`)

**Characteristics:**
- PageView.builder with infinite scroll
- Left and right arrow buttons (CircularArrowButton)
- Page indicator shows current position
- Swipe gestures to navigate
- Virtual page indexing for seamless looping

**Infinite Scroll Implementation:**
- **Virtual Pages:** `imageUrls.length * 1000`
- **Center Point:** Start at middle of virtual page space
- **Index Mapping:** `actualIndex = virtualPage % imageUrls.length`
- **Effect:** Can scroll infinitely in both directions

**Example with 4 images:**
```
Virtual pages: 4000 total
Start position: page 2000 (image 0)
User scrolls left to page 1999 → shows image 3
User scrolls right to page 2001 → shows image 1
```

**Gesture Handling:**
1. `onHorizontalDragStart` → Set `_isDragging = true`
2. PageView handles swipe automatically
3. `onPageChanged` → Update `_currentPage`, track navigation
4. After 300ms delay → Set `_isDragging = false`

---

### Navigation Arrow Buttons

**Visual Design:**
- 48x48px circular buttons
- Semi-transparent black background (0.5 opacity)
- Custom-painted white chevron arrows
- Material ripple effect on tap
- Positioned 10px from left/right edges
- Vertically centered

**Arrow Specifications:**
- Stroke width: 2.5px
- Arrow length: 12px (horizontal spread)
- Arrow spread: 20px (vertical height)
- Horizontal offset: 2px (for visual balance)
- Round caps and joins

**Behavior:**
- Left arrow → `_pageController.previousPage()`
- Right arrow → `_pageController.nextPage()`
- Animation duration: 300ms with `Curves.easeInOut`
- Marks user as engaged via `markUserEngaged()`
- Tracks navigation via analytics

---

### Close Mechanisms

#### 1. Close Button (Top-Left X)
**Location:** 16px from left edge, 16px below status bar
**Design:** 24px icon in circular button with 0.5 opacity black background
**Behavior:** Calls `_handleClose(isBackdropTap: false)`
**Analytics:** Tracks as `'close_button'`

#### 2. Backdrop Tap
**Location:** Entire screen area (Stack with GestureDetector)
**Design:** 30% opacity black overlay
**Behavior:** Calls `_handleClose(isBackdropTap: true)`
**Analytics:** Tracks as `'backdrop_tap'`
**Protection:** Blocked during drag gestures via `_isDragging` flag

#### Drag Protection Logic
```dart
Future<void> _handleClose({bool isBackdropTap = false}) async {
  if (!_isDragging && widget.onClose != null) {
    markUserEngaged();
    _trackGalleryClosed(isBackdropTap ? 'backdrop_tap' : 'close_button');
    await widget.onClose?.call(true);
  }
}
```

**Why needed:** Prevents accidental closes when user is mid-swipe or mid-drag

---

## Image Loading & Display

### Network Image Loading
```dart
Image.network(
  imageUrl,
  fit: BoxFit.contain,
)
```

**Fit Mode:** `BoxFit.contain`
- Maintains aspect ratio
- Scales to fit within viewport
- Does not crop
- Centers within available space

**Caching:** Uses Flutter's default image caching
**Error Handling:** None (relies on Flutter's default error widget)
**Loading State:** None (relies on Flutter's default loading behavior)

---

## Usage Examples

### Example 1: Basic Gallery with Multiple Images

```dart
// In Business Profile page — open gallery from image grid
onImageTap: (index) {
  showDialog(
    context: context,
    barrierColor: Colors.transparent,
    builder: (context) => ImageGalleryWidget(
      width: double.infinity,
      height: double.infinity,
      imageUrls: restaurant.interiorImages,  // List<String>
      currentIndex: index,                   // Tapped image index
      categoryName: 'Interior',              // Category for analytics
      onClose: (closeAction) async {
        Navigator.pop(context);
      },
    ),
  );
}
```

---

### Example 2: Single Image Display

```dart
// Display featured image in full-screen
ImageGalleryWidget(
  width: double.infinity,
  height: double.infinity,
  imageUrls: [restaurant.featuredImageUrl],  // Single image
  currentIndex: 0,                            // Only one image
  categoryName: 'Featured',
  onClose: (closeAction) async {
    Navigator.pop(context);
  },
)
```

---

### Example 3: Menu Item Gallery

```dart
// Menu item detail sheet — open gallery from image thumbnails
onMenuImageTap: (itemImages, selectedIndex) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: ImageGalleryWidget(
          width: double.infinity,
          height: double.infinity,
          imageUrls: itemImages,          // Menu item images
          currentIndex: selectedIndex,    // Tapped thumbnail
          categoryName: 'Menu Items',     // Category name
          onClose: (closeAction) async {
            Navigator.pop(context);
          },
        ),
      ),
    ),
  );
}
```

---

### Example 4: Real-World Usage (ImageGalleryOverlaySwipable)

**File:** `lib/profile/gallery/image_gallery_overlay_swipable/image_gallery_overlay_swipable_widget.dart`

```dart
class ImageGalleryOverlaySwipableWidget extends StatefulWidget {
  const ImageGalleryOverlaySwipableWidget({
    super.key,
    required this.imageURLs,
    required this.imageIndex,
    required this.tabCategory,
  });

  final List<String>? imageURLs;
  final int? imageIndex;
  final String? tabCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: custom_widgets.ImageGalleryWidget(
        width: double.infinity,
        height: double.infinity,
        imageUrls: widget!.imageURLs!,
        currentIndex: widget!.imageIndex!,
        categoryName: widget!.tabCategory!,
        onClose: (closeAction) async {
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

**Usage Context:**
- Wraps ImageGalleryWidget in FlutterFlow page component
- Receives parameters from navigation route
- Provides full-screen container
- Simple Navigator.pop on close

---

## Error Handling

### Input Validation

**No explicit validation** in the widget itself. Expected to receive valid data from parent:

**Expected validations in parent:**
```dart
// Ensure imageUrls is not empty
if (restaurant.images.isEmpty) {
  // Don't show gallery
  return;
}

// Ensure currentIndex is valid
final validIndex = index.clamp(0, restaurant.images.length - 1);

// Ensure categoryName is not null
final category = categoryName ?? 'Unknown';
```

---

### Runtime Error Protection

#### 1. Analytics Tracking Errors
All analytics events use `.catchError()`:
```dart
trackAnalyticsEvent('event', {...}).catchError((error) {
  debugPrint('⚠️ Failed to track event: $error');
});
```
**Behavior:** Logs error to debug console but does not crash or show user-facing error

---

#### 2. Page Controller Disposal
```dart
void _disposePageController() {
  if (_hasMultipleImages) {
    _pageController.dispose();
  }
}
```
**Protection:** Only disposes controller if it was initialized (multi-image mode)

---

#### 3. Mounted Check After Delay
```dart
Future.delayed(_dragResetDelay, () {
  if (mounted) {
    setState(() {
      _isDragging = false;
    });
  }
});
```
**Protection:** Checks if widget is still mounted before calling setState

---

### Known Limitations

#### 1. No Image Loading State
- Shows default Flutter loading indicator
- No custom shimmer or placeholder
- No retry mechanism on load failure

#### 2. No Image Error Handling
- Uses Flutter's default error widget (red icon)
- No custom error UI
- No fallback image

#### 3. No Zoom/Pinch Functionality
Despite the class documentation mentioning "zoom capabilities," the implementation does **not include InteractiveViewer or pinch-to-zoom gestures**.

**Future Enhancement:** Add InteractiveViewer wrapper:
```dart
InteractiveViewer(
  minScale: 1.0,
  maxScale: 4.0,
  child: Image.network(imageUrl, fit: BoxFit.contain),
)
```

#### 4. No Page Indicator Display
- No visual indicator showing "Image 2 of 5"
- Users must infer position from swipe navigation
- Could add indicator at bottom:
```dart
Text('${(_currentPage % imageUrls.length) + 1} / ${imageUrls.length}')
```

---

## Testing Checklist

### Functional Tests

#### Single Image Mode
- [ ] Single image displays centered and contained
- [ ] Horizontal drag creates bounce effect (max 100px)
- [ ] Drag release animates back to center smoothly
- [ ] Cannot swipe to other images (only one image)
- [ ] No arrow buttons visible
- [ ] Close button dismisses gallery
- [ ] Backdrop tap dismisses gallery
- [ ] No accidental close during drag

#### Multi-Image Mode
- [ ] Gallery opens to correct initial image (currentIndex)
- [ ] Swipe left/right navigates between images
- [ ] Arrow buttons navigate correctly
- [ ] Infinite scroll works in both directions (no visible jumps)
- [ ] Page tracking updates correctly on navigation
- [ ] Close button dismisses gallery
- [ ] Backdrop tap dismisses gallery
- [ ] No accidental close during swipe

---

### UI/Visual Tests
- [ ] Backdrop is 30% opacity black
- [ ] Close button is visible and positioned correctly (16px from edges)
- [ ] Arrow buttons are visible and properly positioned (10px from edges)
- [ ] Images maintain aspect ratio (BoxFit.contain)
- [ ] Images are centered in viewport
- [ ] Custom arrow icons render correctly (white chevrons)
- [ ] Ripple effects work on all buttons
- [ ] Status bar padding applied correctly to close button

---

### Analytics Tests
- [ ] `image_gallery_opened` tracked on widget init
- [ ] `image_gallery_navigation` tracked on arrow left/right
- [ ] `image_gallery_navigation` tracked on swipe (consecutive pages)
- [ ] `image_gallery_closed` tracked on close button
- [ ] `image_gallery_closed` tracked on backdrop tap
- [ ] Category name included in all events
- [ ] Image indices correctly calculated (virtual % actual)
- [ ] Gallery type correct ('single' vs 'carousel')

---

### Edge Cases
- [ ] Empty image URL list (should be prevented by parent)
- [ ] Invalid currentIndex (out of bounds)
- [ ] Single image with currentIndex > 0
- [ ] Very long image URLs
- [ ] Network errors during image load
- [ ] Rapid swipe gestures don't break page tracking
- [ ] Multiple rapid arrow button taps handled gracefully
- [ ] Widget disposed during drag gesture
- [ ] onClose callback is null (optional parameter)

---

### Performance Tests
- [ ] No memory leaks from PageController
- [ ] Image caching works correctly
- [ ] Smooth 60fps animation on drag/swipe
- [ ] No jank during infinite scroll wrapping
- [ ] Quick gallery open/close (no lag)

---

## Migration Notes

### Phase 3 Migration Priorities

#### 1. Add InteractiveViewer for Zoom
**Current State:** No zoom functionality despite documentation
**Required Change:** Wrap Image.network in InteractiveViewer

```dart
Widget _buildCenteredImage(String imageUrl) {
  return Center(
    child: InteractiveViewer(
      minScale: 1.0,
      maxScale: 4.0,
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
      ),
    ),
  );
}
```

---

#### 2. Add Image Loading & Error States
**Current State:** Relies on Flutter defaults
**Required Change:** Custom loading shimmer and error UI

```dart
Image.network(
  imageUrl,
  fit: BoxFit.contain,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulatedBytesLoaded /
              loadingProgress.expectedTotalBytes!
            : null,
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.white54),
          SizedBox(height: 16),
          Text('Failed to load image', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  },
)
```

---

#### 3. Add Page Indicator
**Current State:** No visual indicator of position
**Required Change:** Add text indicator at bottom

```dart
Positioned(
  bottom: 32,
  left: 0,
  right: 0,
  child: Container(
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.5),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      '${(_currentPage % widget.imageUrls.length) + 1} / ${widget.imageUrls.length}',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: 14),
    ),
  ),
)
```

---

#### 4. Migrate from FlutterFlow Functions

**Replace:**
```dart
// FlutterFlow functions
trackAnalyticsEvent('event', {...});
markUserEngaged();
```

**With:**
```dart
// Riverpod analytics service
ref.read(analyticsServiceProvider).trackEvent('event', {...});
ref.read(engagementTrackerProvider).markEngaged();
```

---

#### 5. Add Translation Support
**Current State:** No translatable strings (minimal text)
**Required Change:** Prepare for future error messages

```dart
// Future error message translation
errorBuilder: (context, error, stackTrace) {
  return Center(
    child: Text(
      FFLocalizations.of(context).getText('failed_to_load_image'),
      style: TextStyle(color: Colors.white),
    ),
  );
}
```

---

#### 6. Improve Gesture Detection
**Current State:** Basic drag protection with delays
**Potential Improvement:** Use GestureDetector.onTapUp instead of delays

```dart
// More precise tap detection
GestureDetector(
  onTapUp: (details) {
    // Only close if tap, not drag
    if (_dragDistance < 10) {  // Threshold for tap vs drag
      _handleClose(isBackdropTap: true);
    }
  },
  ...
)
```

---

### State Management Changes

**Current FlutterFlow Pattern:**
```dart
// Local state only
late PageController _pageController;
late int _currentPage;
double _dragOffset = 0.0;
bool _isDragging = false;
```

**Future Riverpod Pattern:**
```dart
// Keep local state (appropriate for this widget)
// Gallery state is ephemeral and does not need global management
// Only analytics service needs to be injected via Riverpod

class ImageGalleryWidget extends ConsumerStatefulWidget { ... }

class _ImageGalleryWidgetState extends ConsumerState<ImageGalleryWidget> {
  // Local state remains the same
  // Use ref.read() for analytics service
}
```

**Rationale:** Gallery state is temporary UI state that should remain local. Only analytics tracking needs dependency injection.

---

### Breaking Changes to Anticipate

1. **Custom Actions Migration:**
   - `trackAnalyticsEvent` → Riverpod analytics service
   - `markUserEngaged` → Riverpod engagement tracker

2. **Navigation Changes:**
   - `Navigator.pop(context)` → Potential routing service
   - May need to handle navigation state cleanup

3. **Theme Integration:**
   - Currently uses hardcoded colors
   - Should migrate to design system tokens (ACCENT, background colors)

---

### Backwards Compatibility

**Safe to migrate incrementally:**
- Widget is self-contained with no external dependencies
- Parameters are simple types (List<String>, int, String)
- Can be migrated without affecting calling code
- Analytics migration can happen independently

**Dependencies to coordinate:**
- Analytics service migration must complete first
- Theme system should be defined before migrating colors

---

## Additional Notes

### Design Decisions

1. **Infinite Scroll Implementation:** Uses virtual page multiplier (1000x) instead of wrapping logic to avoid visible jumps at boundaries

2. **Drag Protection Delay:** 300ms delay before re-enabling backdrop tap prevents accidental closes during gesture momentum

3. **Single Image Bounce:** Max 100px drag offset provides subtle feedback without allowing dismissal by horizontal swipe

4. **Custom Arrow Painter:** Uses CustomPaint instead of icon font for pixel-perfect arrow design with specific dimensions

5. **Backdrop Opacity:** 30% opacity balances visual separation from background while keeping context visible

---

### Performance Considerations

1. **PageView.builder:** Lazily builds pages as needed, efficient for large image sets

2. **Infinite Scroll:** Virtual multiplier could cause issues with extremely large image sets (memory usage for PageController state)

3. **Image Caching:** Relies on Flutter's default caching, may benefit from explicit cache management for large galleries

4. **Animation Performance:** AnimatedContainer with easeOutBack curve may drop frames on low-end devices

---

### Future Enhancement Ideas

1. **Image Zoom:** Add InteractiveViewer for pinch-to-zoom
2. **Page Indicator:** Visual dots or text showing position
3. **Image Sharing:** Share button to share current image
4. **Download Button:** Save image to device
5. **Double-tap to Zoom:** Double-tap gesture for quick zoom
6. **Caption Display:** Optional text overlay for image descriptions
7. **Thumbnail Strip:** Bottom strip showing all images
8. **Video Support:** Handle video URLs with play controls
9. **Hero Animation:** Smooth transition from thumbnail to full-screen

---

**Documentation Version:** 1.0
**Last Updated:** 2026-02-19
**FlutterFlow Export:** Phase 2 Complete
**Migration Status:** Ready for Phase 3
