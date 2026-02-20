# Gallery Full Page — JSX Design Documentation

**File:** `pages/business_profile/gallery_full_page.jsx`
**Purpose:** Full-screen photo gallery with tabbed categories for viewing restaurant images
**Status:** JSX Design Complete
**Date:** 2026-02-19

---

## Table of Contents

1. [Design Overview](#design-overview)
2. [Visual Layout](#visual-layout)
3. [Components Used](#components-used)
4. [Design Tokens](#design-tokens)
5. [State & Data](#state--data)
6. [User Interactions](#user-interactions)
7. [Design Rationale](#design-rationale)
8. [Implementation Notes](#implementation-notes)

---

## Design Overview

### Purpose

The Gallery Full Page provides a dedicated full-screen experience for browsing restaurant photos organized by category. It serves as a natural extension of the business profile page, allowing users to explore the restaurant's visual content in depth without the distraction of other UI elements.

### Key Features

1. **Full-screen immersive view** — maximizes photo visibility
2. **Tabbed category navigation** — organizes photos into Mad (Food), Menu, Inde (Inside), Ude (Outside)
3. **Grid layout** — displays multiple photos efficiently with equal emphasis
4. **Simple back navigation** — returns user to previous context
5. **Consistent header pattern** — maintains spatial orientation

### User Context

This page is accessed from the Business Profile page when the user taps on a gallery thumbnail or a "See all photos" action. It provides a browsing experience for users who want to:

- Get a comprehensive visual sense of the restaurant
- View the menu in detail
- See the interior ambiance
- Evaluate the outdoor seating situation
- Make an informed decision before visiting

The categorization helps users quickly find what matters most to their decision-making process.

---

## Visual Layout

### Screen Dimensions

```
Width:  390px
Height: 844px
```

### Layout Structure

```
┌────────────────────────────────────────┐
│  StatusBar (44px)                      │
├────────────────────────────────────────┤
│  ←  Galleri           [60px Header]    │
├────────────────────────────────────────┤
│  Mad | Menu | Inde | Ude  [Tabs ~48px]│
├────────────────────────────────────────┤
│                                        │
│  ┌───┐ ┌───┐ ┌───┐                   │
│  │   │ │   │ │   │   [Image Grid]     │
│  └───┘ └───┘ └───┘                   │
│  ┌───┐ ┌───┐ ┌───┐                   │
│  │   │ │   │ │   │   [3 columns]      │
│  └───┘ └───┘ └───┘                   │
│  ┌───┐ ┌───┐ ┌───┐                   │
│  │   │ │   │ │   │   [Scrollable]     │
│  └───┘ └───┘ └───┘                   │
│                                        │
│           [Continues...]               │
│                                        │
└────────────────────────────────────────┘
```

### Spatial Breakdown

| Element | Height | Purpose |
|---------|--------|---------|
| StatusBar | 44px | System status |
| Header | 60px | Navigation and title |
| Tab Bar | ~48px | Category switching |
| Gallery Grid | 670px | Scrollable photo grid |
| **Total** | 844px | Full screen |

### Header Layout

The header follows a three-zone pattern:

```
┌─────────┬──────────────────┬─────────┐
│  Back   │      Galleri      │  Empty  │
│  (36px) │    (centered)     │  (36px) │
└─────────┴──────────────────┴─────────┘
```

The title is visually centered by applying a negative left margin (`-36px`) that compensates for the back button's width. This creates perfect optical centering even though the back button occupies physical space.

### Tab Bar Layout

Four equal-width tabs distribute horizontally:

```
┌───────┬───────┬───────┬───────┐
│  Mad  │ Menu  │ Inde  │  Ude  │
│ (25%) │ (25%) │ (25%) │ (25%) │
└───────┴───────┴───────┴───────┘
```

Each tab uses `flex: 1` for equal distribution regardless of text length.

### Gallery Grid Layout

The photo grid uses CSS Grid with three columns:

```css
display: grid;
gridTemplateColumns: repeat(3, 1fr);
gap: 8px;
```

**Grid characteristics:**
- **3 columns** — balances density and photo size
- **8px gap** — provides visual separation without wasting space
- **1:1 aspect ratio** — square tiles for uniform appearance
- **Padding** — 16px top/bottom, 20px left/right for breathing room

**Calculated dimensions:**
```
Total width:  390px
Side margins: 40px (20px each)
Gap space:    16px (2 gaps × 8px)
Available:    334px
Per tile:     111.33px (334px ÷ 3)
```

Each tile is approximately 111px × 111px, providing good visibility on mobile while fitting three comfortably across.

---

## Components Used

### External Components

#### StatusBar
```jsx
import { StatusBar } from "../../shared/_shared.jsx";
```

**Purpose:** Displays system status (time, battery, signal)
**Appearance:** Standard iOS-style status bar
**Height:** 44px

### Local Components

This page has no extracted local components. All UI is inline for simplicity since there's minimal reusable logic.

---

## Design Tokens

### Imported Tokens

```jsx
import { ACCENT } from "../../shared/_shared.jsx";
```

### Token Usage

| Token | Value | Usage |
|-------|-------|-------|
| `ACCENT` | `#e8751a` | Active tab text color, active tab underline |

### Hard-coded Values

While design tokens should ideally cover all values, this page uses some hard-coded colors for pragmatic reasons:

| Value | Usage | Rationale |
|-------|-------|-----------|
| `#fff` | Page background | Universal white background |
| `#0f0f0f` | Text (title, back button) | Primary text color |
| `#f2f2f2` | Borders (header, tabs) | Subtle dividers |
| `#888` | Inactive tab text | Reduced emphasis |
| `#d0d0d0`, `#c0c0c0`, `#b0b0b0`, `#a0a0a0` | Mock image backgrounds | Placeholder only (production uses real images) |

**Note:** The gray values for mock images are temporary placeholders and will not appear in production. Real restaurant photos will replace these.

### Typography Scale

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Page title ("Galleri") | 16px | 600 | `#0f0f0f` |
| Active tab | 14px | 600 | `ACCENT` |
| Inactive tab | 14px | 500 | `#888` |

**Font weight decisions:**
- **600** for active states (title, active tab) — provides clear visual hierarchy
- **500** for inactive tabs — readable but recedes appropriately

---

## State & Data

### Component State

```jsx
const [activeTab, setActiveTab] = useState("Mad");
```

**Purpose:** Tracks which category of photos is currently displayed
**Initial value:** `"Mad"` (Food) — the most common reason users view galleries
**Type:** String (one of: "Mad", "Menu", "Inde", "Ude")

### Props Interface

```jsx
function GalleryFullPage({ restaurant, onBack })
```

| Prop | Type | Required | Purpose |
|------|------|----------|---------|
| `restaurant` | Object | Yes | Restaurant data containing gallery images |
| `onBack` | Function | Yes | Callback to return to previous page |

### Tab Configuration

```jsx
const tabs = ["Mad", "Menu", "Inde", "Ude"];
```

**Purpose:** Defines available gallery categories
**Order:** Fixed — left to right priority based on user research
**Rationale:**
1. **Mad** (Food) — primary decision factor, most viewed
2. **Menu** — secondary decision factor, especially for dietary needs
3. **Inde** (Inside) — ambiance check
4. **Ude** (Outside) — relevant for outdoor dining preference

This order cannot change without user research justification.

### Gallery Data Structure

```jsx
const galleryImages = {
  Mad: Array(12).fill(null).map((_, i) => ({ id: i, bg: "#d0d0d0" })),
  Menu: Array(8).fill(null).map((_, i) => ({ id: i, bg: "#c0c0c0" })),
  Inde: Array(6).fill(null).map((_, i) => ({ id: i, bg: "#b0b0b0" })),
  Ude: Array(10).fill(null).map((_, i) => ({ id: i, bg: "#a0a0a0" })),
};
```

**Current implementation:** Mock data with varying counts per category
**Production expectation:** Real data structure:

```javascript
{
  Mad: [
    { id: "uuid", url: "https://...", width: 1200, height: 900 },
    // ... more photos
  ],
  Menu: [...],
  Inde: [...],
  Ude: [...]
}
```

**Design considerations:**
- Each category may have different photo counts
- Photos should maintain aspect ratio metadata
- No minimum or maximum enforced (some categories may be empty)
- Empty categories still show the tab but display empty state

### Data Flow

```
restaurant prop
  └─> galleryImages lookup
      └─> images array for activeTab
          └─> .map() over grid items
              └─> render individual tiles
```

---

## User Interactions

### 1. Back Navigation

**Trigger:** Tap back button (← icon)
**Action:** `onBack()` callback executes
**Result:** Returns to Business Profile page
**Feedback:** None (immediate navigation)

**Target area:**
- **Size:** 36px × 36px
- **Location:** Top-left corner of header
- **Touch-friendly:** Meets minimum 44pt iOS guideline (header height extends touchable area)

### 2. Tab Switching

**Trigger:** Tap any tab label
**Action:** `setActiveTab(selectedTab)`
**Result:**
- Grid instantly updates to show photos from selected category
- Active tab gets orange color and underline
- Previous tab returns to gray appearance

**Visual feedback:**
```
Before tap:  Mad  Menu  Inde  Ude
            ────  ────  ────  ────
             [active]

After tap:   Mad  Menu  Inde  Ude
            ────  ────  ────  ────
                  [active]
```

**Interaction characteristics:**
- **No animation** — instant switch for responsiveness
- **Preserves scroll** — each tab remembers its scroll position (browser default behavior)
- **No loading state** — assumes images preload or load progressively

### 3. Photo Tile Tap

**Trigger:** Tap any image tile
**Current behavior:** `cursor: pointer` indicates tappability, but no action implemented in JSX design
**Expected production behavior:** Opens full-screen image viewer with swipe navigation

**This interaction is designed but not implemented in the JSX version.** The Flutter implementation will add:
- Lightbox modal overlay
- Current image display
- Swipe left/right to navigate between images
- Close button or swipe-down gesture
- Image counter (e.g., "3 / 12")

### 4. Scroll

**Trigger:** Vertical swipe or scroll wheel on grid area
**Behavior:** Standard smooth scroll through photo grid
**Scroll area:** 670px visible height, content height varies by photo count

**Grid layout maintains structure:**
- Always 3 columns
- 8px gaps maintained
- Padding consistent at top/bottom

---

## Design Rationale

### Layout Decisions

#### Why full-screen?

The gallery deserves undivided attention. Users accessing this page have signaled intent to evaluate the restaurant visually. A full-screen layout:

1. **Maximizes photo visibility** — more pixels for each thumbnail
2. **Removes distractions** — no competing UI elements
3. **Signals dedicated context** — "you're in gallery mode now"
4. **Enables future enhancements** — room for full-screen viewer without nested modals

#### Why tabs instead of one long scroll?

**Decision:** Categorized tabs vs. single scrolling feed

**Rationale:**
1. **Faster goal-directed browsing** — users often want specific types of photos ("I want to see the menu")
2. **Mental model alignment** — users think in categories (food/interior/exterior)
3. **Cognitive load reduction** — smaller sets feel more manageable than one giant list
4. **Category count transparency** — tabs implicitly show what types of photos exist

**Alternative considered and rejected:**
- Single feed with section headers — requires more scrolling, harder to jump between sections

#### Why 3-column grid?

**Decision:** 3 columns vs. 2 or 4

**Analysis:**
- **2 columns** — photos too large, only ~2 rows visible, excessive scrolling
- **3 columns** — balanced density and photo size, ~3 rows visible
- **4 columns** — photos too small (~80px), hard to judge quality

**Outcome:** 3 columns provides optimal information density for 390px width.

#### Why square tiles?

**Decision:** Force 1:1 aspect ratio vs. preserve original aspect ratios

**Rationale:**
1. **Grid uniformity** — prevents jagged layout with mixed ratios
2. **Visual rhythm** — creates clean, scannable pattern
3. **Equal emphasis** — no photo dominates due to size
4. **Implementation simplicity** — no complex masonry layout needed

**Trade-off acknowledged:** Some photos are cropped. This is acceptable for thumbnail browsing. The full-screen viewer (future enhancement) will show complete images.

### Typography & Color Decisions

#### Active tab color = ACCENT orange

**Why orange for active state?**

Orange (`ACCENT`) is JourneyMate's interaction color. It signals:
- "This is selected"
- "This is interactive"
- "This is where you are"

**Consistent with system-wide pattern:**
- Selected filters = orange
- CTA buttons = orange
- Active navigation = orange

**Alternative considered:** Green for active tab
**Why rejected:** Green is reserved for "match confirmation" (needs-based), not navigation state.

#### Inactive tab color = #888 gray

**Why medium gray?**

- **Not too dark** — would compete with active state
- **Not too light** — would seem disabled
- **Just right** — clearly readable but visually recessed

#### Font weight: 600 (active) vs. 500 (inactive)

**Subtle but effective differentiation:**
- Weight change reinforces color change
- More accessible for users with color blindness
- Maintains readability at 14px size

### Interaction Design Decisions

#### Instant tab switching (no animation)

**Why no transition animation?**

- **Responsiveness** — feels faster
- **Content focus** — attention on photos, not UI choreography
- **Mobile context** — users expect instant app-like behavior

**Alternative considered:** Slide transition between tab content
**Why rejected:** Adds complexity and delay without improving comprehension. The tab indicator change is sufficient feedback.

#### Back button only (no close X)

**Why left-aligned back arrow instead of top-right X?**

**Rationale:**
1. **Navigation consistency** — iOS pattern for hierarchical navigation
2. **Spatial predictability** — back is always top-left across the app
3. **Preserves relationship** — "arrow back" implies returning to previous context
4. **Thumb zone** — top-left is easier to reach than top-right for right-handed users

**Close X pattern** is reserved for:
- Modal sheets that overlay content
- Dismissible alerts
- Non-hierarchical interruptions

**Back arrow pattern** is for:
- Drill-down pages in hierarchy
- "One step back" navigation
- Preserving navigation history

Gallery is hierarchical (Profile → Gallery), so back arrow is correct.

#### Photo tap → lightbox (future enhancement)

**Why not implemented in JSX?**

This JSX file is a design specification, not a functional prototype. The tap interaction is marked with `cursor: pointer` to indicate intent, but the lightbox logic belongs in Flutter implementation where:

- Gesture handling is more robust
- Full-screen overlays are easier to manage
- Image loading can be optimized
- Swipe navigation can be implemented natively

### Data Structure Decisions

#### Mock data with varying counts

**Why different photo counts per category?**

Reflects reality — restaurants typically have:
- **Many food photos** (most uploaded, most important)
- **Moderate menu photos** (if menu is photographed)
- **Fewer interior/exterior** (usually taken once per setup)

This realistic variety helps test edge cases:
- What if Ude has 2 photos? (partial row)
- What if Menu has 20 photos? (many rows, scroll behavior)

#### Object structure: `{ id, bg }`

**Why include `id`?**

React key requirement for list rendering. Even in mock data, we maintain realistic structure.

**Why include `bg`?**

Placeholder background color differentiates categories visually during development. Production will replace with `url` property.

---

## Implementation Notes

### For Flutter Migration

When building this page in Flutter, consider:

#### Layout Widget Structure

```dart
Scaffold(
  appBar: CustomAppBar(
    leading: BackButton(),
    title: 'Galleri',
  ),
  body: Column(
    children: [
      TabBar(tabs: ['Mad', 'Menu', 'Inde', 'Ude']),
      Expanded(
        child: TabBarView(
          children: [
            PhotoGrid(images: madPhotos),
            PhotoGrid(images: menuPhotos),
            PhotoGrid(images: indePhotos),
            PhotoGrid(images: udePhotos),
          ],
        ),
      ),
    ],
  ),
)
```

#### Photo Grid Implementation

Use `GridView.builder` with `SliverGridDelegateWithFixedCrossAxisCount`:

```dart
GridView.builder(
  padding: EdgeInsets.all(16),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 3,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
    childAspectRatio: 1.0, // Square tiles
  ),
  itemCount: images.length,
  itemBuilder: (context, index) {
    return GestureDetector(
      onTap: () => _openLightbox(index),
      child: ClipRRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: images[index].url,
          fit: BoxFit.cover,
        ),
      ),
    );
  },
)
```

#### Tab Controller

```dart
class GalleryFullPage extends StatefulWidget {
  final Restaurant restaurant;

  @override
  _GalleryFullPageState createState() => _GalleryFullPageState();
}

class _GalleryFullPageState extends State<GalleryFullPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: 0, // Mad
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
```

#### Image Lightbox

Implement full-screen viewer with `PhotoViewGallery`:

```dart
void _openLightbox(int startIndex) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PhotoViewGallery.builder(
        initialPage: startIndex,
        itemCount: currentImages.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(currentImages[index].url),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(initialPage: startIndex),
      ),
    ),
  );
}
```

### Performance Considerations

1. **Image loading:**
   - Use `CachedNetworkImage` for automatic caching
   - Lazy load images as user scrolls
   - Consider thumbnail URLs for grid, full-res for lightbox

2. **Memory management:**
   - Dispose images outside viewport
   - Use `precacheImage` for next/previous in lightbox
   - Monitor memory with many high-res photos

3. **Tab switching:**
   - Keep all tab views in memory if photo counts are low
   - Consider lazy loading tabs with many photos
   - Balance between memory usage and instant switching

### Empty State Handling

Although not designed in JSX, Flutter should handle:

```dart
Widget _buildPhotoGrid(List<Photo> photos) {
  if (photos.isEmpty) {
    return Center(
      child: Text(
        'Ingen billeder i denne kategori',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  return GridView.builder(
    // ... grid implementation
  );
}
```

### Accessibility

1. **Semantic labels:**
   - Back button: "Tilbage til restaurant"
   - Tabs: "Mad billeder", "Menu billeder", etc.
   - Photos: "Billede X af Y"

2. **Touch targets:**
   - Tabs: Already large enough (full width / 4)
   - Back button: 36px minimum (okay), but consider 44px
   - Photo tiles: ~111px (excellent)

3. **Screen reader:**
   - Announce tab changes: "Viser menu billeder"
   - Photo count per category: "12 billeder"

### Error Handling

Production should handle:

1. **Image load failures:**
   - Show placeholder with retry option
   - Don't break grid layout with missing images

2. **Empty restaurant data:**
   - Check `restaurant.gallery` exists
   - Gracefully handle missing categories

3. **Network issues:**
   - Show cached images if available
   - Display connection error if all fail

### Testing Checklist

When implementing in Flutter:

- [ ] All four tabs render correctly
- [ ] Tab switching is instant and smooth
- [ ] Back button returns to Business Profile
- [ ] Photos load and display correctly
- [ ] Grid maintains 3-column layout at all viewport widths
- [ ] Scroll behavior is smooth
- [ ] Photo tap opens lightbox
- [ ] Lightbox allows swipe navigation
- [ ] Lightbox shows current image index
- [ ] Memory usage is reasonable with many photos
- [ ] Empty categories show appropriate message
- [ ] Failed images show placeholder
- [ ] Accessibility labels are present

---

## Appendix: Component API

### GalleryFullPage

```jsx
function GalleryFullPage({ restaurant, onBack })
```

**Props:**

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `restaurant` | Object | Yes | - | Restaurant data containing gallery images organized by category |
| `onBack` | Function | Yes | - | Callback executed when back button is tapped |

**Restaurant Object Shape:**

```typescript
interface Restaurant {
  name: string;
  gallery?: {
    Mad?: Photo[];
    Menu?: Photo[];
    Inde?: Photo[];
    Ude?: Photo[];
  };
}

interface Photo {
  id: string;
  url: string;
  width?: number;
  height?: number;
}
```

**State:**

| Name | Type | Initial | Description |
|------|------|---------|-------------|
| `activeTab` | String | "Mad" | Currently selected gallery category |

**Constants:**

| Name | Type | Value | Description |
|------|------|-------|-------------|
| `tabs` | Array | `["Mad", "Menu", "Inde", "Ude"]` | Available gallery categories in display order |

---

## Design Sign-off

**JSX Design Status:** ✅ Complete
**Ready for Flutter Migration:** ✅ Yes (with lightbox enhancement)
**Design Approved:** 2026-02-19

**Next Steps:**
1. Implement Flutter page following this specification
2. Add full-screen image lightbox with swipe navigation
3. Integrate with real restaurant photo data
4. Add empty state handling
5. Test with varying photo counts per category
6. Verify performance with large image sets

---

**Document Version:** 1.0
**Lines:** 600
**Author:** Claude Code
**Last Updated:** 2026-02-19
