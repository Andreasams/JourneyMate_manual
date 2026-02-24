# Search Page UI Analysis

**Source:** React/JSX prototype for JourneyMate restaurant search page
**Frame Size:** 390×844px (iPhone viewport)
**Generated:** 2026-02-24

---

## 1. UI Elements Inventory

### Top-Level Structure
1. **Phone Frame Container** — Outermost wrapper simulating physical device
2. **StatusBar** — System status (time, signal, battery)
3. **Scrollable Content Area** — Main content container (710px height)
4. **TabBar** — Bottom navigation (80px fixed height)

### Header Section
5. **Location Indicator** — "København" with pin icon
6. **Search Bar** — Text input with search icon and clear button
7. **Page Title** — "Steder nær dig" or "Søgeresultater (n)"
8. **Filter Button Group** — Three buttons: "Lokation", "Type", "Behov"

### Active Filters Section
9. **"Ryd alle" Button** — Clear all filters action
10. **Active Filter Chips** — Removable filter tags (green background for needs, green for filters)
11. **Horizontal Scroll Container** — Wraps filter chips with fade gradient

### View Toggle
12. **Liste/Kort Toggle** — Two-button segmented control

### Restaurant Cards (Lista View)
13. **Restaurant Card** — Repeating component with:
    - **Restaurant Avatar** — Colored square with initials
    - **Restaurant Name** — Bold title
    - **Distance Label** — Right-aligned distance
    - **Status Indicator** — "Åben"/"Lukket" with dot separator
    - **Status Text** — Closing time or opening time
    - **Cuisine Type** — Secondary info
    - **Price Range** — Secondary info
    - **Expand/Collapse Chevron** — Dropdown indicator
    - **Partial Match Banner** (conditional) — Orange info box
    - **Expanded Content** (conditional):
      - Address line
      - Today's hours
      - Photo thumbnails grid (8 items, 80×60px each)
      - "Se mere →" button

### Section Headers (When Filters Active)
14. **"Matcher alle behov" Header** — Green with checkmark icon
15. **"Matcher delvist" Header** — Orange, uppercase
16. **"Andre steder" Header** — Gray, uppercase

### No Results State
17. **Empty State Container** — Centered layout with:
    - **Search Icon Circle** — 80×80px gray background
    - **"No search results" Title**
    - **Explanation Text**
    - **"Clear search" Button** (conditional)

### Map View Placeholder
18. **Map Coming Soon State** — Gray icon with placeholder text

### Floating Actions
19. **Floating Sort Button** — Bottom-right FAB with sort icon and label

### Bottom Sheets
20. **Filter Sheet** (78% height):
    - **Tab Group** — "Lokation" (36%), "Type" (33%), "Behov" (31%)
    - **Primary Column** — Categories with count badges
    - **Secondary Column** — Items with checkboxes
    - **Tertiary Column** — Sub-items with checkboxes
    - **Action Bar** — "Nulstil" and "Se n steder" buttons
    - **Drag Handle** — 36×4px gray bar at top

21. **Sort Sheet** (62% height):
    - **Header** — "Sortér efter" with back button (conditional)
    - **"Kun åbne steder" Checkbox** — Toggle with count
    - **Sort Options List** — 6 options with checkmarks/arrows
    - **Station Submenu** — 5 train stations
    - **Info Footer** (conditional) — Gray tip box

22. **Needs Picker Sheet** (72% height):
    - **Header** — "Dine behov" title + subtitle
    - **Category Tabs** — 6 tabs (Diæt, Tilgængelighed, Børn, Hunde, Stemning, Udendørs)
    - **Pill Grid** — Checkable pills in flexbox wrap
    - **"Gem mine behov" Button** — Black CTA at bottom

### Tab Bar (Bottom Navigation)
23. **Udforsk Tab** — Search icon + label
24. **Mine behov Tab** — Shield icon + label
25. **Profil Tab** — User icon + label

### Micro-Components
26. **Dot Separator** — 3×3px gray circle
27. **Check Icon** — SVG checkmark (10×10px default)
28. **Backdrop Overlay** — Semi-transparent black (z-index 10)

---

## 2. Spacing Reference

### Global Spacing
- **Phone outer padding:** 24px all sides
- **Phone border radius:** 48px
- **Phone bezel:** 10px + 1px border
- **Content horizontal padding:** 20px (standard)

### StatusBar (54px height)
- **Padding:** 14px top, 28px horizontal, 0px bottom
- **Time to icons gap:** space-between (flex)
- **Icon group gap:** 5px

### Header Section
- **Location to search gap:** 14px
- **Search to title gap:** 16px (implicit from marginBottom)
- **Title to filter buttons gap:** 14px
- **Filter button gap:** 8px
- **Filter button padding:** 9px vertical, 0px horizontal

### Search Bar
- **Border radius:** 12px
- **Padding:** 11px vertical, 14px horizontal
- **Icon to input gap:** 10px
- **Border:** 1.5px (focused: ACCENT, unfocused: transparent)

### Active Filters Section
- **Section padding:** 14px top, 0px horizontal, 8px bottom
- **"Ryd alle" padding:** 7px vertical, 12px horizontal
- **Fade gradient width:** 10px
- **Chip gap:** 6px
- **Chip padding:** 7px vertical, 10px right, 12px left
- **Chip icon gap:** 5px
- **Chip border radius:** 8px
- **Chip border:** 1.5px
- **Section padding right:** 20px

### Liste/Kort Toggle
- **Margin:** 12px top, 20px horizontal, 0px bottom
- **Button padding:** 8px vertical, 0px horizontal
- **Border radius:** 8px (left button: 8px 0 0 8px, right: 0 8px 8px 0)
- **Border:** 1.5px
- **Negative margin between buttons:** -1.5px

### Restaurant Card
- **Outer padding:** 14px
- **Margin bottom:** 8px
- **Border radius:** 16px
- **Border:** 1.5px
- **Avatar to content gap:** 12px
- **Avatar size:** 50×50px
- **Avatar border radius:** 13px
- **Name to distance:** space-between with 8px marginRight on name
- **Status line gap:** 6px
- **Dot margin:** implicit from gap
- **Partial match banner margin top:** 10px
- **Partial match banner padding:** 9px vertical, 11px horizontal
- **Partial match banner border radius:** 10px
- **Partial match banner icon gap:** 8px
- **Expanded content margin top:** 12px
- **Expanded content padding top:** 12px
- **Photo grid gap:** 4px
- **Photo size:** 80×60px
- **Photo border radius:** 8px
- **Photo grid negative margin:** 0px -2px (horizontal)
- **"Se mere" button margin top:** 10px
- **"Se mere" button padding:** 9px vertical, 0px horizontal
- **"Se mere" button border radius:** 10px
- **Chevron container margin top:** 6px
- **Chevron padding bottom:** 4px

### Section Headers
- **Font:** 11px
- **Margin bottom:** 10px
- **Icon gap:** 5px (for "Matcher alle behov")
- **Margin top (subsequent sections):** 24px

### Floating Sort Button
- **Position:** bottom 92px, right 16px
- **Padding:** 9px vertical, 14px horizontal
- **Border radius:** 20px
- **Icon to text gap:** 5px
- **z-index:** 6

### TabBar (80px height)
- **Padding top:** 10px
- **Tab gap:** space-around (flex)
- **Tab padding:** 2px vertical, 16px horizontal
- **Icon to label gap:** 3px
- **Border top:** 1px

### Filter Sheet
- **Border radius:** 22px 22px 0 0 (top corners only)
- **Drag handle padding:** 12px top, 20px horizontal, 8px bottom
- **Drag handle size:** 36×4px
- **Drag handle border radius:** 4px
- **Tab padding:** 12px vertical, 0px horizontal
- **Tab gap:** 5px (for badge)
- **Tab border bottom:** 2.5px
- **Primary column padding:** 6px vertical, 0px horizontal
- **Primary column item padding:** 11px vertical, 10-14px horizontal
- **Primary column left border:** 2.5px
- **Secondary column padding:** 6px vertical, 0px horizontal
- **Secondary column item padding:** 11px vertical, 12px horizontal
- **Secondary column item gap:** 8px
- **Tertiary column padding:** 6px vertical, 0px horizontal
- **Tertiary column item padding:** 10px vertical, 10px horizontal
- **Tertiary column item gap:** 7px
- **Action bar padding:** 14px top, 20px horizontal, 32px bottom
- **Action bar gap:** 10px
- **Button border radius:** 12px
- **Nulstil padding:** 13px vertical, 0px horizontal
- **Apply button padding:** 13px vertical, 0px horizontal

### Sort Sheet
- **Header padding:** 4px top, 20px horizontal, 10px bottom
- **Back button padding:** 4px
- **Back button margin left:** -8px
- **Header gap:** 12px
- **Checkbox section padding:** 12px vertical, 20px horizontal
- **Checkbox container padding:** 12px vertical, 14px horizontal
- **Checkbox container border radius:** 10px
- **Checkbox gap:** 10px
- **Option padding:** 14px vertical, 20px horizontal
- **Option end gap:** 8px
- **Info footer padding:** 12px vertical, 20px horizontal

### Needs Picker Sheet
- **Header padding:** 4px top, 20px horizontal, 14px bottom
- **Category tab padding:** 11px vertical, 14px horizontal
- **Category tab border bottom:** 2.5px
- **Content padding:** 16px top, 20px horizontal
- **Pill gap:** 10px
- **Pill padding:** 10px vertical, 16px horizontal
- **Pill border radius:** 12px
- **Pill icon gap:** 8px
- **Footer padding:** 14px top, 20px horizontal, 32px bottom
- **Footer button padding:** 14px vertical, 0px horizontal
- **Footer button border radius:** 14px

### No Results State
- **Container padding:** 60px vertical, 32px horizontal
- **Icon circle size:** 80×80px
- **Icon circle margin bottom:** 24px
- **Title margin bottom:** 12px
- **Text margin bottom:** 32px
- **Text max width:** 280px
- **Clear button padding:** 12px vertical, 24px horizontal

---

## 3. Font Size Reference

### StatusBar
- **Time:** 15px (weight: 600)
- **System icons:** 17×12px, 16×12px, 27×13px (SVG)

### Header Section
- **Location label:** 15px (weight: 600)
- **Location icon:** 15×15px (SVG)
- **Search placeholder/input:** 15px (weight: normal)
- **Search icon:** 17×17px (SVG)
- **Page title:** 24px (weight: 720, letterSpacing: -0.025em)
- **Filter buttons:** 13.5px (weight: 570)
- **Filter button badge:** Visible as red dot (6×6px), or " (n)" in text

### Active Filters
- **"Ryd alle" button:** 12.5px (weight: 580)
- **Filter chips:** 12.5px (weight: 540)
- **Chip close icon:** 10×10px (SVG)

### Liste/Kort Toggle
- **Button text:** 13.5px (weight: 620 active, 480 inactive)

### Restaurant Card
- **Name:** 15.5px (weight: 630)
- **Distance:** 12px (weight: 500)
- **Status:** 12.5px (weight: 560)
- **Status text:** 12.5px (weight: normal)
- **Cuisine/price:** 12.5px (weight: normal)
- **Avatar initial:** 15px (weight: 700)
- **Partial match label:** 12px (weight: 580)
- **Partial match icon:** 14×14px (SVG)
- **Address (expanded):** 12.5px (weight: normal)
- **Hours (expanded):** 12.5px (weight: normal)
- **"Se mere" button:** 12.5px (weight: 560)
- **Chevron:** 14×8px (SVG)

### Section Headers
- **"Matcher alle behov":** 11px (weight: 620, uppercase)
- **"Matcher delvist":** 11px (weight: 620, uppercase)
- **"Andre steder":** 11px (weight: 620, uppercase)
- **Checkmark icon:** 11×11px (SVG)

### Floating Sort Button
- **Label:** 12.5px (weight: 580)
- **Icon:** 12×12px (SVG)

### TabBar
- **Tab label:** 10.5px (weight: 620 active, 480 inactive)
- **Tab icon:** 21×21px (SVG)

### Filter Sheet
- **Tab labels:** 14px (weight: 640 active, 480 inactive)
- **Tab count badges:** 10px (weight: 700)
- **Badge circle:** 18×18px
- **Primary column items:** 13px (weight: 620 active, 440 inactive)
- **Secondary column items:** 13px (weight: 620 selected, 440 unselected)
- **Tertiary column items:** 12px (weight: 600 selected, 420 unselected)
- **Checkbox (secondary):** 18×18px
- **Checkbox (tertiary):** 16×16px
- **Checkmark (secondary):** 10×10px (SVG)
- **Checkmark (tertiary):** 9×9px (SVG)
- **"Nulstil" button:** 14px (weight: 580)
- **Apply button:** 14px (weight: 620)

### Sort Sheet
- **Header:** 18px (weight: 680)
- **Back arrow:** 10×16px (SVG)
- **"Kun åbne steder":** 15px (weight: 600 selected, 460 unselected)
- **Option labels:** 15px (weight: 620 active, 460 inactive)
- **Checkmark circle:** 20×20px
- **Checkmark:** 11×11px (SVG)
- **Right arrow:** 8×14px (SVG)
- **Info footer text:** 12px (weight: normal)

### Needs Picker Sheet
- **Header title:** 20px (weight: 720)
- **Header subtitle:** 13px (weight: normal)
- **Category tabs:** 13px (weight: 620 active, 460 inactive)
- **Pills:** 14px (weight: 600 active, 460 inactive)
- **Pill checkmark:** 12×12px (SVG)
- **Footer button:** 15px (weight: 620)

### No Results State
- **Emoji icon:** 36px (fontSize, in 80×80px circle)
- **Title:** 20px (weight: 680)
- **Body text:** 14px (weight: 400, lineHeight: 20px)
- **Clear button:** 14px (weight: 600)

### Map Placeholder
- **Map icon:** 28×28px (SVG)
- **Title:** 15px (weight: 600)
- **Subtitle:** 13px (weight: normal)

### Micro-Components
- **Dot separator:** 3×3px circle
- **Check icon (default):** 10×10px (SVG, strokeWidth: 3.5)

---

## 4. Relative Positioning

### Vertical Hierarchy (Top to Bottom)

```
┌─────────────────────────────────────────────┐
│ StatusBar (absolute top, 54px)              │ position: relative, flexShrink: 0
├─────────────────────────────────────────────┤
│                                             │
│ Scrollable Content (710px)                 │ overflowY: auto
│ ┌─────────────────────────────────────┐   │
│ │ Header Section                       │   │ padding: 4px 20px 0
│ │ • Location indicator                 │   │ marginBottom: 14px (inline-flex)
│ │ • Search bar                         │   │ marginBottom: 16px
│ │ • Page title                         │   │ marginBottom: 14px
│ │ • Filter buttons (flex row)          │   │ gap: 8px
│ └─────────────────────────────────────┘   │
│ ┌─────────────────────────────────────┐   │
│ │ Active Filters Section (conditional) │   │ padding: 14px 0 8px, borderBottom
│ │ • "Ryd alle" (flexShrink: 0)         │   │ paddingLeft: 20px, z-index: 2
│ │ • Fade gradient (10px width)         │   │
│ │ • Chip horizontal scroll             │   │ paddingRight: 20px
│ └─────────────────────────────────────┘   │
│ ┌─────────────────────────────────────┐   │
│ │ Liste/Kort Toggle                    │   │ margin: 12px 20px 0
│ └─────────────────────────────────────┘   │
│ ┌─────────────────────────────────────┐   │
│ │ Results Area                         │   │ padding: 16px 20px 32px
│ │ • Section header (conditional)       │   │ marginBottom: 10px
│ │ • Restaurant cards (loop)            │   │ marginBottom: 8px per card
│ │   - First card: animation delay 0s   │   │
│ │   - Second card: 0.04s delay         │   │
│ │   - ...up to 8th: 0.32s delay        │   │
│ └─────────────────────────────────────┘   │
│                                             │
├─────────────────────────────────────────────┤
│ TabBar (absolute bottom, 80px)              │ position: absolute, z-index: 5
└─────────────────────────────────────────────┘
```

### Z-Index Layering (Back to Front)

```
z-index 0  : Default content (cards, headers, text)
z-index 5  : TabBar (fixed bottom navigation)
z-index 6  : Floating Sort Button (FAB)
z-index 10 : Bottom sheet backdrop (FilterSheet/SortSheet)
z-index 20 : Bottom sheet content (FilterSheet/SortSheet)
z-index 30 : Needs Picker backdrop (higher tier)
z-index 40 : Needs Picker content (higher tier)
```

### Horizontal Layout Patterns

#### Filter Button Group (Flex Row)
```
┌────────────┬────────────┬────────────┐
│ Lokation   │   Type     │   Behov    │  gap: 8px, flex: 1 each
└────────────┴────────────┴────────────┘
```

#### Filter Sheet Three-Column Layout
```
┌──────────────┬─────────────┬────────────┐
│  Primary     │  Secondary  │  Tertiary  │
│  36% width   │  33% width  │  31% width │ (exact, never approximate)
│  (Categories)│  (Items)    │ (Sub-items)│
└──────────────┴─────────────┴────────────┘
```

#### Liste/Kort Toggle (Segmented Control)
```
┌──────────────────┬──────────────────┐
│      Liste       │       Kort       │  flex: 1 each, negative margin overlap
└──────────────────┴──────────────────┘
```

#### Restaurant Card Layout
```
┌──────────────────────────────────────────┐
│ ┌────┐  Name                    Distance │
│ │ Av │  Status • til 18:00               │  gap: 12px between avatar & content
│ │ at │  Cuisine • Price                  │  flex: 1 for text block
│ └────┘                                    │
├──────────────────────────────────────────┤ (conditional expanded content)
│ Address                                   │
│ Hours                                     │
│ ┌──┬──┬──┬──┬──┬──┬──┬──┐               │  gap: 4px
│ │  ││  ││  ││  ││  ││  ││  ││  │        │  8 photos, 80×60px each
│ └──┴──┴──┴──┴──┴──┴──┴──┘               │
│ ┌──────────────────────────────────────┐ │
│ │          Se mere →                    │ │
│ └──────────────────────────────────────┘ │
└──────────────────────────────────────────┘
```

#### Active Filters Row (Horizontal Scroll)
```
┌──────────┬─────────────────────────────────────────────────►
│ Ryd alle │ [Helt glutenfri ×] [Fuldt vegansk ×] [Filter ×] ...
└──────────┴ (scrollable, paddingRight: 20px)
            ◄─ 10px fade gradient
```

#### TabBar Layout (Space-Around)
```
┌──────────────┬──────────────┬──────────────┐
│   Udforsk    │  Mine behov  │    Profil    │  justifyContent: space-around
│   [icon]     │    [icon]    │    [icon]    │  flexDirection: column per tab
│   [label]    │    [label]   │    [label]   │  gap: 3px icon-to-label
└──────────────┴──────────────┴──────────────┘
```

### Floating Sort Button Position
```
Relative to phone frame (390×844):
• bottom: 92px (12px above TabBar which is at 80px height + padding)
• right: 16px
• Positioned above TabBar but below main content
```

### Bottom Sheet Positioning
```
All bottom sheets:
• position: absolute
• bottom: 0, left: 0, right: 0
• borderRadius: 22px 22px 0 0 (top corners only)
• transform: translateY(0) when visible, translateY(100%) when hidden
• transition: 0.3s cubic-bezier(0.32, 0.72, 0, 1)

Heights:
• FilterSheet: 78% of viewport
• SortSheet: 62% of viewport
• NeedsPicker: 72% of viewport

Drag handle:
• Centered horizontally (margin: 0 auto)
• 36×4px gray bar
• padding: 12px 20px 8px (creates 20px from edges)
```

### Restaurant Card Internal Alignment
```
┌─────────────────────────────────────────────┐
│ [Avatar]  Name (flex:1, overflow:hidden)    │ alignItems: flex-start
│   50×50   ↓ 2px gap                         │
│  13px r   Status • Text (alignItems:center) │ gap: 6px between elements
│           ↓ 2px gap                         │
│           Cuisine • Price                   │
│           ↓ 10px gap (if partial match)     │
│           [Partial match banner]            │
│           ↓ 12px gap (if expanded)          │
│           [Expanded content]                │
└─────────────────────────────────────────────┘
```

### Filter Sheet Tab Column Relationships
```
Primary column click:
→ Updates Secondary column items
→ Resets Tertiary column to first sub-item

Secondary column click:
→ Toggles checkbox
→ Updates Tertiary column (if has subs)
→ Maintains Primary column selection

Tertiary column click:
→ Toggles checkbox only
→ No cascade effects
```

### Responsive Scroll Behaviors
- **Active filters:** Horizontal scroll with left-pinned "Ryd alle" + fade gradient
- **Filter sheet columns:** Each column independently scrollable (overflowY: auto)
- **Sort sheet:** Single column scroll with conditional back button in header
- **Needs picker pills:** Wrap in grid (flexWrap: wrap)
- **Restaurant photos:** Horizontal scroll with negative margins (-2px)

### Animation Entry Delays (Restaurant Cards)
```
Card index 0: delay 0s
Card index 1: delay 0.04s
Card index 2: delay 0.08s
Card index 3: delay 0.12s
Card index 4: delay 0.16s
Card index 5: delay 0.20s
Card index 6: delay 0.24s
Card index 7: delay 0.28s
Card index 8+: delay 0.32s (capped at Math.min(i, 8))

Animation: cardIn 0.25s ease forwards
From: opacity 0, translateY(8px)
To: opacity 1, translateY(0)
```

---

## Notes

1. **Color Design Tokens**
   - ACCENT: `#e8751a` (orange, used for CTAs and active states)
   - GREEN: `#1a9456` (used for needs/matches)
   - GREEN_BG: `#f0f9f3` (light green background)
   - GREEN_BORDER: `#d0ecd8` (light green border)

2. **Typography Weights**
   - 420-440: Body text, unselected items
   - 460-480: Secondary labels, inactive tabs
   - 540-580: Button text, selected items
   - 600-640: Headers, active tabs
   - 680-720: Page titles, section headers

3. **Border Patterns**
   - Buttons/cards: 1.5px solid
   - Active states: Colored borders (ACCENT or GREEN_BORDER)
   - Inactive states: #e8e8e8 gray
   - Bottom sheets: No border, rely on shadow

4. **Scroll Container Indicators**
   - Active filter chips: Fade gradient (10px, white to transparent)
   - No visible scrollbars (`::-webkit-scrollbar{display:none}`, `scrollbar-width:none`)

5. **Exact Column Width Rule** (Critical Product Decision #12)
   - Filter sheet tabs: 36% / 33% / 31% (never approximate)
   - Must maintain exact percentages for visual design

6. **Self-Contained Widget Pattern**
   - All sheets read their own data internally
   - Props only for business logic (selectedFilters, activeNeeds, etc.)
   - No infrastructure props for display concerns

7. **Conditional Rendering Triggers**
   - Partial match banner: `hasNeeds && variant==="partial"`
   - Active filters section: `hasFilters || hasNeeds`
   - Section headers: `showMatchSections` (true when filters/needs active)
   - Empty state: `filtered.length === 0`
