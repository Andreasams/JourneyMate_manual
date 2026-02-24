# Search Results Page (Udforsk) — JSX Design Documentation

**Source File:** `C:\Users\Rikke\Documents\JourneyMate\pages\search.jsx`
**Version:** v2.0 (Post-design system)
**Last Updated:** February 2026

---

## 1. Design Overview

### Page Purpose
The Search Results page (internally called "Udforsk" — "Explore" in Danish) is the primary discovery interface for JourneyMate. It allows users to:
- Browse restaurants near their location
- Apply filters across three dimensions (Location, Type, Needs)
- View match quality when needs are active
- Sort results by multiple criteria
- Toggle between list and map views
- Manage persistent dietary/accessibility needs

This page serves as the app's home screen and primary workflow entry point. It embodies JourneyMate's core value proposition: "Find what you need" — surfacing restaurants that match specific user requirements through verified capability data.

### User Experience Goals
1. **Immediate clarity** — Users understand their location context, available actions, and current filter state at a glance
2. **Effortless refinement** — Three filter dimensions (Lokation, Type, Behov) are always visible, one tap away
3. **Match transparency** — When needs are active, results are grouped by match quality with clear visual hierarchy
4. **Persistent needs** — User's dietary/accessibility requirements persist across sessions
5. **Zero friction** — Expandable cards let users preview details without leaving the list
6. **Flexible sorting** — Sort by match quality, distance, price, station proximity, or "open now"

### Design Philosophy
- **Needs-first architecture:** The entire interface responds to user needs — when active, match sections appear, sort defaults to "best match", cards show green/orange borders
- **Three-layer filter system:** Persistent needs (stored) + session filters (reset on close) + ephemeral sort = complete discovery control
- **Progressive disclosure:** Cards collapse by default, expand on tap for preview, navigate on button tap
- **String identity:** Filter selections, need labels, and restaurant capabilities use identical strings for matching
- **Visual stability:** Fixed column widths (36%/33%/31%) prevent layout shift when switching filter tabs

---

## 2. Visual Layout

### ASCII Diagram
```
┌────────────────────────────────────────────────┐
│ 9:41                           📶 📡 🔋        │ Status Bar (54px)
├────────────────────────────────────────────────┤
│ 📍 København                                   │
│                                                │
│ [🔍 Søg restauranter, retter...]              │ Search field
│                                                │
│ Steder nær dig                                 │ H2 title
│                                                │
│ [Lokation] [Type] [Behov]                      │ 3 filter buttons
│                                                │
│ ┌──────────────────────────────────────────┐  │ Chip row (appears when
│ │[Ryd alle▶] Glutenfri Havudsigt Børnestol│  │ filters active)
│ └──────────────────────────────────────────┘  │
│                                                │
│ [Liste·Kort]────────────────────────────────   │ View toggle
│                                                │
│ ╔═══════════════════════════════════════════╗ │
│ ║ [42] 42Raw                        350m    ║ │ Card (collapsed)
│ ║ Åben · til 18:00                          ║ │
│ ║ Plantbaseret • 330–410 kr.                ║ │
│ ║                            ⌄              ║ │
│ ╚═══════════════════════════════════════════╝ │
│                                                │
│ ╔═══════════════════════════════════════════╗ │ Card (expanded)
│ ║ [HG] H.U.G Bageri                 1.1km  ║ │
│ ║ Åben · til 16:00                          ║ │
│ ║ Glutenfrit bageri • 100–520 kr.           ║ │
│ ║───────────────────────────────────────────║ │
│ ║ Øster Farimagsgade 20, Kbh Ø              ║ │
│ ║ I dag: 07:30–17:30                        ║ │
│ ║ [img][img][img][img][img][img][img][img]  ║ │ Photo strip
│ ║ [       Se mere →       ]                 ║ │
│ ╚═══════════════════════════════════════════╝ │
│                                                │
│ (scrollable content continues...)              │
│                                                │
│                              [🔸 Bedst match]  │ Floating sort
├────────────────────────────────────────────────┤
│ [🔍 Udforsk] [🛡️ Mine behov] [👤 Profil]     │ Tab bar (80px)
└────────────────────────────────────────────────┘
```

### With Active Needs (Match Sections)
```
┌────────────────────────────────────────────────┐
│ Søgeresultater (12)                            │ H2 changes when filtered
│                                                │
│ [Lokation] [Type (2)] [Behov (3)]              │ Badges show counts
│                                                │
│ [Ryd alle▶] Glutenfri Havudsigt Børnestol      │
│                                                │
│ ✓ MATCHER ALLE BEHOV                           │ Green section header
│ ╔═══════════════════════════════════════════╗ │
│ ║ [42] 42Raw                        350m    ║ │ Green border
│ ╚═══════════════════════════════════════════╝ │
│                                                │
│ MATCHER DELVIST                                │ Orange section header
│ ╔═══════════════════════════════════════════╗ │
│ ║ [Pa] Palæo                        600m    ║ │ Orange border
│ ║ ⓘ Matcher 2/3 · Mangler: Børnestol         ║ │ Info box
│ ╚═══════════════════════════════════════════╝ │
│                                                │
│ ANDRE STEDER                                   │ Grey section header
│ ╔═══════════════════════════════════════════╗ │
│ ║ [SN] Sushi Neko                   700m    ║ │ Grey border
│ ╚═══════════════════════════════════════════╝ │
└────────────────────────────────────────────────┘
```

### Screen Dimensions
- **Device frame:** 390×844px (iPhone 14/15)
- **Status bar:** 54px (time + system icons)
- **Scrollable content:** 710px (844 - 54 - 80)
- **Tab bar:** 80px (blurred, semi-transparent)
- **Floating sort button:** 92px from bottom (12px above tab bar)

---

## 3. Components Used

### From `_shared.jsx`
1. **`ACCENT`** (`#e8751a`) — Orange for CTAs, active states, brand
2. **`GREEN`** (`#1a9456`) — Match confirmation color
3. **`GREEN_BG`** (`#f0f9f3`) — Background for match pills/cards
4. **`GREEN_BORDER`** (`#d0ecd8`) — Border for full-match cards
5. **`filterSets`** — Three-dimensional filter data structure (Lokation, Type, Behov)
6. **`allRestaurants`** — Array of restaurant data with capabilities (`has` field)
7. **`trainStations`** — List of Copenhagen train stations for proximity sorting
8. **`Dot`** — 3px grey separator dot component
9. **`Check`** — Checkmark SVG icon (variable size and color)
10. **`StatusBar`** — iOS-style status bar (9:41, signal, wifi, battery)
11. **`BottomSheet`** — Draggable bottom sheet container with backdrop

### Local Components (Page-Specific)
1. **`FilterSheet`** — Three-tab, three-column filter interface
2. **`NeedsPicker`** — Persistent needs selection sheet
3. **`Card`** — Expandable restaurant preview card
4. **`TabBar`** — Bottom navigation with three tabs

### Component Hierarchy
```
SearchPage (root)
├─ StatusBar
├─ <scrollable content>
│  ├─ Header block
│  │  ├─ Location indicator (📍 København)
│  │  ├─ Search input field
│  │  ├─ Title (H2)
│  │  └─ 3 filter buttons
│  ├─ Chip row (conditional: only when hasFilters || hasNeeds)
│  │  ├─ Fixed "Ryd alle" button
│  │  ├─ Gradient fade
│  │  └─ Scrollable chip list
│  ├─ Liste/Kort toggle
│  └─ Results area
│     ├─ Match sections (conditional: when showMatchSections)
│     │  ├─ "Matcher alle behov" + cards
│     │  ├─ "Matcher delvist" + cards
│     │  └─ "Andre steder" + cards
│     └─ Unsectioned card list (when no needs/filters)
├─ Floating sort button (conditional: only in liste mode)
├─ TabBar (fixed bottom)
└─ Overlays (conditional)
   ├─ FilterSheet (when activeSheet !== null)
   ├─ NeedsPicker (triggered by parent, not managed here)
   └─ Sort sheet (when sortSheetOpen)
```

---

## 4. Design Tokens

### Colors Used
| Token | Hex | Usage in This Page |
|-------|-----|-------------------|
| `ACCENT` | `#e8751a` | Filter button active state, active tab underline, tab badges, sort button, chip "Ryd alle" text, section header "Matcher delvist", active sort checkmark circle |
| `GREEN` | `#1a9456` | "Åben" status text, full-match section header, match pills, need chips background, "Matcher alle behov" checkmark |
| `GREEN_BG` | `#f0f9f3` | Need chip background, full-match info (not used here, saved for profile) |
| `GREEN_BORDER` | `#d0ecd8` | Full-match card border, need chip border |
| `RED` | `#c9403a` | "Lukket" status text |
| `ORANGE_BG` | `#fef8f2` | Partial-match info box background |
| `ORANGE_BORDER` | `#f0dcc8` | Partial-match card border |
| `#0f0f0f` | — | Primary text (headings, restaurant names), "Gem mine behov" button background |
| `#555` | — | Secondary text (cuisine, price), button text |
| `#666` | — | Filter button text (inactive), sort option text |
| `#777` | — | Filter column item text (unselected) |
| `#888` | — | Muted text, inactive tab text, placeholder |
| `#999` | — | Tertiary text (closing time, address), needs picker description |
| `#aaa` | — | Distance text, close icon in chips |
| `#bbb` | — | "Andre steder" section header, inactive tab bar icons |
| `#ccc` | — | Checkbox border (unselected) |
| `#ddd` | — | Chevron color (collapsed card), bottom sheet drag handle |
| `#e0e0e0` | — | "Nulstil" button border |
| `#e8e8e8` | — | Default card border, filter button border, input border, toggle border |
| `#f0f0f0` | — | Tab border, column dividers in filter sheet |
| `#f2f2f2` | — | Chip row border-bottom, card expanded divider |
| `#f5f5f5` | — | Search input background, active toggle background |
| `#f8f8f8` | — | Active item background (filter column 2) |
| `#fafafa` | — | Filter column 1 background, active sort row background, needs picker header background |
| `#fff` | — | Card backgrounds, button backgrounds, checkbox backgrounds |

### Typography Scale (Font Sizes & Weights)
| Element | Size | Weight | Color | Notes |
|---------|------|--------|-------|-------|
| Status bar time | 15px | 600 | `#0f0f0f` | |
| Location label | 13.5px | 580 | `#0f0f0f` | "København" |
| Search placeholder | 15px | — | `#0f0f0f` | Inherits family |
| Page title (H2) | 24px | 720 | `#0f0f0f` | Letter-spacing: -0.025em |
| Filter button text | 13.5px | 570 | `#555` / `#fff` | Active = white on orange |
| Filter badge | 10px | 700 | `#fff` | Circular badge on button |
| Chip text | 12.5px | 540-580 | `GREEN` / `ACCENT` | Needs = green, filters = green |
| "Ryd alle" button | 12.5px | 580 | `ACCENT` | |
| Toggle text | 13.5px | 480/620 | `#999` / `#0f0f0f` | Inactive/active |
| Section header | 11px | 620 | varies | Uppercase, letter-spacing 0.05em |
| Card restaurant name | 15.5px | 630 | `#0f0f0f` | Truncate ellipsis |
| Card distance | 12px | 500 | `#aaa` | Right-aligned |
| Card status ("Åben") | 12.5px | 560 | `#2a9456` / `#c9403a` | |
| Card closing time | 12.5px | — | `#999` | "til 18:00" |
| Card cuisine/price | 12.5px | — | `#999` | |
| Card address (expanded) | 12.5px | — | `#888` | |
| Card hours (expanded) | 12.5px | — | `#666` | |
| "Se mere →" button | 12.5px | 560 | `#555` | |
| Partial match info | 12px | 580 / 400 | `#555` | "Matcher X/Y" bold, rest regular |
| Tab bar label | 10.5px | 480/620 | `#bbb` / `ACCENT` | |
| Sort button text | 12.5px | 580 | `#fff` | On orange background |
| Filter sheet tab | 14px | 480/640 | `#888` / `ACCENT` | |
| Filter sheet badge | 10px | 700 | `#fff` | |
| Filter col 1 text | 13px | 440/620 | `#777` / `ACCENT` | Inactive/active |
| Filter col 2 text | 13px | 440/620 | `#777` / `#0f0f0f` | |
| Filter col 3 text | 12px | 420/600 | `#888` / `#0f0f0f` | |
| Filter footer "Nulstil" | 14px | 580 | `#666` | |
| Filter footer CTA | 14px | 620 | `#fff` | "Se X steder" |
| Needs picker title | 20px | 720 | `#0f0f0f` | "Dine behov" |
| Needs picker subtitle | 13px | — | `#999` | |
| Needs picker tab | 13px | 460/620 | `#888` / `ACCENT` | |
| Needs picker item | 14px | 460/600 | `#555` / `GREEN` | |
| Sort sheet title | 18px | 680 | `#0f0f0f` | "Sortér efter" |
| Sort option label | 15px | 460/620 | `#666` / `#0f0f0f` | |
| "Kun åbne steder" | 15px | 460/600 | `#666` / `GREEN` | |
| Station list item | 15px | 460/620 | `#666` / `#0f0f0f` | |

### Spacing & Dimensions
| Element | Value |
|---------|-------|
| Page horizontal padding | 20px |
| Card padding | 14px |
| Card margin-bottom | 8px |
| Card border-radius | 16px |
| Logo circle size | 50×50px |
| Logo circle border-radius | 13px |
| Gap logo to text | 12px |
| Filter button padding | 9px 0 (vertical) |
| Filter button border-radius | 10px |
| Filter button gap | 8px |
| Chip padding | 7px 10px 7px 12px |
| Chip border-radius | 8px |
| Chip row padding-top | 14px |
| Chip row padding-bottom | 8px |
| Chip gap | 6px |
| Toggle padding | 8px 0 (vertical) |
| Toggle border-radius | 8px (left) / 8px (right) |
| Card expanded divider margin | 12px 0 (top) / 12px 0 (padding-top) |
| Photo strip item size | 80×60px |
| Photo strip gap | 4px |
| Photo strip border-radius | 8px |
| Bottom sheet height (filter) | 78% |
| Bottom sheet height (needs) | 72% |
| Bottom sheet height (sort) | 62% |
| Bottom sheet border-radius | 22px 22px 0 0 |
| Bottom sheet drag handle | 36×4px, border-radius 4px |
| Filter tab padding | 12px 0 (vertical) |
| Filter col 1 width | 36% |
| Filter col 2 width | 33% |
| Filter col 3 width | 31% |
| Filter col 1 padding | 11px 10px 11px 14px |
| Filter col 2 padding | 11px 12px |
| Filter col 3 padding | 10px 10px |
| Filter footer padding | 14px 20px 32px |
| Needs picker header padding | 4px 20px 14px |
| Needs picker tab padding | 11px 14px |
| Needs picker grid padding | 16px 20px |
| Needs picker grid gap | 10px |
| Needs picker item padding | 10px 16px |
| Needs picker footer padding | 14px 20px 32px |
| Sort sheet option padding | 14px 20px |
| Floating sort button bottom | 92px |
| Floating sort button right | 16px |
| Floating sort button padding | 9px 14px |
| Floating sort button border-radius | 20px |
| Tab bar height | 80px |
| Tab bar padding-top | 10px |
| Tab bar icon size | 21×21px |
| Tab bar icon-label gap | 3px |

### Shadows & Effects
| Element | Shadow |
|---------|--------|
| Floating sort button | `0 2px 8px rgba(0,0,0,0.12)` |
| Bottom sheet | `0 -8px 40px rgba(0,0,0,0.08)` |
| Tab bar | None (uses backdrop-filter) |
| Cards | None |

### Backdrop Blur
- Tab bar: `blur(16px)` with `rgba(255,255,255,0.95)` background

---

## 5. State & Data

### Component Props (SearchPage)
```jsx
{
  onSelect: (restaurant) => void,         // Navigate to business profile
  activeNeeds: Set<string>,               // Persistent needs from parent
  onToggleNeed: (string) => void,         // Add/remove persistent need
  onClearAllNeeds: () => void,            // Clear all persistent needs
  onOpenNeedsPicker: () => void           // Open needs picker sheet
}
```

### Local State Variables
```jsx
const [activeSheet, setActiveSheet]           = useState(null);        // "Lokation" | "Type" | "Behov" | null
const [sheetVisible, setSheetVisible]         = useState(false);       // Animation trigger
const [selectedFilters, setSelectedFilters]   = useState(new Set());   // Session filter selections
const [searchFocused, setSearchFocused]       = useState(false);       // Search input focus state
const [viewMode, setViewMode]                 = useState("liste");     // "liste" | "kort"
const [activeSort, setActiveSort]             = useState("match");     // "match" | "nearest" | "station" | "price_low" | "price_high" | "newest"
const [selectedStation, setSelectedStation]   = useState(null);        // Train station for proximity sort
const [showOnlyOpen, setShowOnlyOpen]         = useState(false);       // Filter to open restaurants only
const [sortSheetView, setSortSheetView]       = useState("options");   // "options" | "stations"
const [sortSheetOpen, setSortSheetOpen]       = useState(false);       // Sort sheet mount state
const [sortSheetVisible, setSortSheetVisible] = useState(false);       // Sort sheet animation trigger
```

### Derived State
```jsx
const hasFilters = selectedFilters.size > 0;

// All Behov items from filterSets (for identifying which selectedFilters are needs)
const allBehovItems = new Set([...extractedFromFilterSets]);

// Session needs from selectedFilters (Behov items only)
const needsFromFilters = [...selectedFilters].filter(f => allBehovItems.has(f));

// Combined needs (persistent + session)
const allNeeds = new Set([...activeNeeds, ...needsFromFilters]);
const hasNeeds = allNeeds.size > 0;

// Match-annotated restaurants
const withMatch = allRestaurants.map(r => ({
  ...r,
  matchCount: [...allNeeds].filter(n => r.has.includes(n)).length,
  matchedNeeds: [...allNeeds].filter(n => r.has.includes(n)),
  missedNeeds: [...allNeeds].filter(n => !r.has.includes(n))
}));

// Sorted and filtered lists
const sorted = applySort(withMatch);  // Applies activeSort logic
const filtered = showOnlyOpen ? sorted.filter(r => r.statusOpen) : sorted;

// Match sections (only when showMatchSections = true)
const showMatchSections = hasNeeds || hasFilters;
const fullMatch = filtered.filter(r => r.matchCount === allNeeds.size);
const partialMatch = filtered.filter(r => r.matchCount > 0 && r.matchCount < allNeeds.size);
const noMatch = filtered.filter(r => r.matchCount === 0);
```

### Filter Data Flow
```
1. User taps "Behov" filter button
   → openSheet("Behov")
   → activeSheet = "Behov", then setSheetVisible(true)

2. User selects "Helt glutenfrit" in filter sheet
   → toggleFilter("Helt glutenfrit")
   → selectedFilters.add("Helt glutenfrit")
   → allNeeds now includes "Helt glutenfrit"
   → withMatch recalculates matchCount for all restaurants
   → Cards re-render with match borders and info boxes

3. User taps chip to remove
   → toggleFilter("Helt glutenfrit")
   → selectedFilters.delete("Helt glutenfrit")
   → allNeeds no longer includes it
   → Match counts recalculate
```

### Sort Data Flow
```
1. User taps floating sort button
   → openSortSheet()
   → sortSheetOpen = true, sortSheetView = "options", sortSheetVisible = true

2. User selects "Nærmest togstation"
   → setSortSheetView("stations")
   → View slides from right

3. User selects "København H"
   → setSelectedStation("København H")
   → setActiveSort("station")
   → setSortSheetView("options") (slide back)
   → Sort label updates to "København H"
   → (In real implementation, would trigger distance calculation)

4. User taps "Kun åbne steder" toggle
   → setShowOnlyOpen(!showOnlyOpen)
   → filtered list recalculates to exclude closed restaurants
   → Count in footer button updates
```

### Restaurant Data Structure (Relevant Fields)
```jsx
{
  id: number,
  name: string,
  cuisine: string,
  priceRange: string,      // "330–410 kr."
  address: string,
  distance: string,        // "350m", "1.1km"
  initial: string,         // "42", "HG" (logo initials)
  bg: string,              // Hex color for logo background
  statusOpen: boolean,
  closingTime: string,     // "18:00"
  statusText?: string,     // Optional: "lukker i morgen kl. 02:00", "åbner kl. 16:00"
  has: string[],           // Capabilities array: ["Helt glutenfrit", "Fuldt vegansk", "Havudsigt"]
  note: string,            // Brief capability note: "Fuldt glutenfrit køkken"
  hours: [day, slots][],   // Opening hours (see design system sec. 8)
  // ...profile fields (not used in list view)
}
```

### Opening Hours Data Model (Used in Card Expanded State)
```jsx
// Simple string
["Mandag", "10:00–22:00"]

// Closed day
["Søndag", "Lukket"]

// Multiple slots (breakfast/lunch/dinner)
["Mandag", [
  { time: "07:00–10:00", note: "Køkken lukker 09:30" },
  { time: "11:30–14:30" },
  { time: "17:00–22:00", note: "Køkken lukker 21:15" }
]]
```

**Card preview simplification:** The card's expanded state shows only the overall span for multi-slot days. "I dag: 07:00–22:00" (first open → last close). This differs from the profile page's collapsed contact section, which shows the full slot breakdown: "07:00–10:00, 11:30–14:30, 17:00–22:00".

---

## 6. User Interactions

### Primary User Flows

#### Flow 1: Browse Without Filters
```
1. User lands on page
   → Sees "Steder nær dig" title
   → No chip row visible
   → No match sections
   → Cards show grey borders, no match info
   → Default sort: "match" (but behaves like "nearest" when no needs active)

2. User scrolls through list
   → Cards enter with staggered animation

3. User taps a card
   → Card expands
   → Shows address, today's hours, photo strip, "Se mere →" button

4. User taps card again
   → Card collapses back to compact state

5. User taps "Se mere →" button
   → onSelect(restaurant) called
   → Navigates to business profile page
```

#### Flow 2: Apply Filters
```
1. User taps "Behov" button
   → Filter sheet slides up (78% height)
   → Shows "Behov" tab active
   → Three columns: category groups (left), items (center), sub-items (right)

2. User taps "Diæt og restriktioner" in column 1
   → Column 2 shows items: Allergier, Gluten, Vegetar, Vegansk, etc.

3. User taps "Gluten" in column 2
   → "Gluten" becomes active item (grey background)
   → Column 3 shows sub-items: "Helt glutenfrit", "Glutenfri muligheder"
   → "Gluten" checkbox also toggles (item counts as selected)

4. User taps "Helt glutenfrit" in column 3
   → Checkbox fills with orange, checkmark appears
   → selectedFilters.add("Helt glutenfrit")

5. User taps "Se 12 steder" button in footer
   → Sheet slides down
   → Chip row appears: [Ryd alle▶] [Helt glutenfrit ×]
   → Title changes to "Søgeresultater (12)"
   → Match sections appear: "Matcher alle behov" (green) / "Matcher delvist" (orange) / "Andre steder" (grey)
   → Cards grouped by match quality
   → Full-match cards get green borders
   → Partial-match cards get orange borders + info box showing missed needs

6. User taps × on "Helt glutenfrit" chip
   → toggleFilter called
   → selectedFilters.delete("Helt glutenfrit")
   → Chip disappears
   → Match sections recalculate
   → If no filters/needs remain, chip row disappears
```

#### Flow 3: Set Persistent Needs
```
1. User taps "Behov" filter button
   → Sheet opens to "Behov" tab

2. User sees green pills for items already in activeNeeds
   → These were set via the needs picker (not shown in this page)
   → They appear both as green chips in the chip row AND as selected in the filter sheet

3. User taps a need that's already in activeNeeds
   → onToggleNeed(need) called (managed by parent)
   → Need removed from activeNeeds
   → Green pill in filter sheet becomes unselected
   → Green chip in chip row disappears
   → Match sections recalculate

(Note: The full needs picker interface is triggered by onOpenNeedsPicker(), which opens a separate sheet — not shown in this component.)
```

#### Flow 4: Sort Results
```
1. User taps floating orange sort button (bottom-right)
   → Sort sheet slides up (62% height)
   → Shows "Sortér efter" title
   → Lists sort options with current selection marked by orange checkmark

2. User taps "Kun åbne steder" toggle
   → showOnlyOpen = true
   → Toggle background turns green
   → Checkmark appears
   → Filtered count updates in toggle row
   → Card list recalculates (closed restaurants removed)

3. User taps "Nærmest togstation" option
   → Sort sheet view slides left (exits)
   → Station list view slides in from right
   → Title changes to "Vælg togstation"
   → Back arrow appears at left
   → Shows list: København H, Nørreport, Østerport, Vesterport, Flintholm

4. User taps "Nørreport"
   → setSelectedStation("Nørreport")
   → setActiveSort("station")
   → View slides back to options list
   → "Nærmest togstation" label updates to "Nærmest togstation: Nørreport"
   → (In real app: would trigger API call for distance calculation)

5. User taps anywhere outside sheet or swipes down
   → Sheet slides down
   → Floating button label updates to "Nørreport"
```

#### Flow 5: Clear All Filters
```
1. User has 3 active filters + 2 persistent needs
   → Chip row shows: [Ryd alle▶] [Need1 ×] [Need2 ×] [Filter1 ×] [Filter2 ×] [Filter3 ×]

2. User taps "Ryd alle"
   → setSelectedFilters(new Set())  // Clears session filters
   → onClearAllNeeds()              // Clears persistent needs (managed by parent)
   → Chip row disappears
   → Title changes back to "Steder nær dig"
   → Match sections disappear
   → All cards revert to grey borders
   → Full unsectioned list returns
```

#### Flow 6: Toggle View Mode
```
1. User taps "Kort" in Liste/Kort toggle
   → setViewMode("kort")
   → Liste segment: white background, grey text
   → Kort segment: grey background (#f5f5f5), black text
   → Card list disappears
   → Placeholder shown: map icon + "Kortvisning" + "Kommer snart"
   → Floating sort button disappears (only visible in liste mode)

2. User taps "Liste"
   → setViewMode("liste")
   → Card list returns
   → Floating sort button reappears
```

### Interaction Details

#### Card Expand/Collapse
- **Trigger:** Tap anywhere on card body (logo, text, chevron)
- **Behavior:** `expanded` state toggles
- **Collapsed state:**
  - Base info visible (logo, name, status, cuisine, price)
  - Partial match info box (if applicable)
  - Subtle down chevron at bottom
- **Expanded state:**
  - All collapsed content remains
  - Divider line appears
  - Address line shows
  - Today's hours show (simplified span)
  - Photo strip appears (8 placeholders, horizontal scroll)
  - "Se mere →" button appears
  - Chevron disappears (card already tall, no need to show collapse hint)
- **Navigation:** Only "Se mere →" button navigates (uses `stopPropagation` to prevent card toggle)

#### Filter Sheet Tab Switching
- **Trigger:** Tap tab label
- **Behavior:**
  - Active tab changes (orange text, orange underline, orange badge)
  - All three columns' content swaps instantly
  - Column widths remain fixed (36%/33%/31%) — no layout shift
  - Active category in column 1 resets to first item
  - Active item in column 2 resets to first item in that category
  - Column 3 shows subs for first item (or empty if no subs)
- **Badge update:** Count recalculates for new tab

#### Filter Column Navigation
- **Column 1 → Column 2:**
  - Tap category in column 1
  - Category becomes active (white background, orange left border)
  - Column 2 shows items for that category
  - Active item in column 2 auto-selects first item
  - Column 3 updates to show subs for first item
- **Column 2 interaction:**
  - Tap item checkbox/label
  - Item becomes active (grey background)
  - Item selection toggles (checkbox fills orange if selected)
  - Column 3 shows subs for that item (or empty)
- **Column 3 interaction:**
  - Tap sub-item checkbox/label
  - Sub-item selection toggles
  - No navigation side effect (column 1 and 2 stay the same)

#### Chip Removal
- **Trigger:** Tap × icon on chip
- **Behavior:**
  - toggleFilter(chipValue) called
  - Chip disappears with fade
  - Match count recalculates
  - If last chip removed: chip row disappears, title reverts, match sections disappear

#### Search Input
- **Behavior (current):** Visual only
  - Focus: orange border appears (1.5px solid)
  - Blur: border disappears (returns to transparent)
  - No search logic implemented yet (placeholder for Phase 3)

#### "Ryd alle" Button
- **Position:** Fixed at left edge of chip row
- **Scroll behavior:** Stays visible while chips scroll underneath
- **Gradient fade:** 10px gradient (white → transparent) creates visual separation between button and chips

---

## 7. Responsive Behavior

### Scroll Behavior
- **Main content area:** Scrolls vertically within 710px viewport (844 - 54 - 80)
- **Filter sheet columns:** Each column scrolls independently (vertical)
- **Chip row:** Scrolls horizontally when chips exceed viewport width
- **Photo strip (expanded card):** Scrolls horizontally (8 photos × 80px + gaps)
- **Needs picker tabs:** Scroll horizontally when tabs exceed width
- **Needs picker grid:** Scrolls vertically within sheet
- **Sort sheet options:** Scrolls vertically (rare, only 6-7 options)
- **Station list:** Scrolls vertically if list is long

### Fixed Elements
- **Status bar:** Always at top (54px)
- **Tab bar:** Always at bottom (80px), semi-transparent blur
- **Floating sort button:** Fixed position (bottom 92px, right 16px), only visible in liste mode
- **"Ryd alle" button in chip row:** Horizontally fixed while chips scroll

### Layout Stability
- **Filter sheet column widths:** Fixed (36%/33%/31%) regardless of content or active tab
- **Card heights:** Dynamic (collapse/expand), but expansion is smooth with content reveal, no jump
- **Chip row:** Appears/disappears smoothly (no layout shift to content below)
- **Match section headers:** Fixed height, always same spacing

### Overflow Handling
- **Restaurant name in card:** `overflow: hidden`, `textOverflow: ellipsis`, `whiteSpace: nowrap`
- **Partial match info text:** Wraps to multiple lines if needed (not truncated)
- **Filter sheet item labels:** Wrap if too long (column 2 and 3)
- **Needs picker item labels:** Wrap within pill (multi-line OK)
- **Search input:** Text scrolls horizontally if exceeds width

### Animation Performance
- **Card stagger:** Only first 8 cards animate (limit: `Math.min(i, 8) * 0.04s`)
- **Reason:** Prevents hundreds of animations on long lists, which would cause jank
- **Bottom sheet drag:** Uses `transform` (GPU-accelerated), no `transition` during drag
- **Profile transition:** Uses `transform: translateX()` (GPU-accelerated)

---

## 8. Design Rationale

### Why Three Separate Filter Dimensions?
**Decision:** Lokation, Type, and Behov are separate tabs in a unified sheet, not a single flat list.

**Rationale:**
- Users think in distinct categories: "Where?" (Lokation), "What kind?" (Type), "Can it handle my needs?" (Behov)
- Separating them reduces cognitive load — each tab is a focused filtering lens
- Behov is special: it merges persistent needs (from picker) with session selections
- Alternative considered: single hierarchical tree with all filters mixed — rejected because it buried dietary filters under generic categories, making them hard to find for users whose primary task is allergen safety

### Why Fixed Column Widths (36%/33%/31%)?
**Decision:** Filter sheet columns stay at fixed widths regardless of content or active tab.

**Rationale:**
- **Stability over optimization:** Dynamic column widths caused jarring layout shifts when switching tabs
- **Visual alignment:** Tab widths (Lokation 36%, Type 33%, Behov 31%) match column widths below, creating visual harmony
- **Acceptable tradeoff:** Empty third column wastes space when no subs exist, but the predictability is worth it
- Tested alternative: collapsing third column when empty — felt "broken" because the middle column kept jumping positions

### Why Green for Matches, Orange for Interactions?
**Decision:** Strict color separation — green exclusively for "this matches your needs," orange exclusively for "tap this" or "JourneyMate brand."

**Rationale:**
- **Early versions mixed green and orange** for match indicators, CTAs, and filter selections — users couldn't parse the hierarchy at a glance
- **User research insight:** People with dietary restrictions are risk-averse. Green = safe/confirmed. Orange = action required. Mixing them erodes trust.
- **Consistency across platform:** As JourneyMate expands beyond restaurants (activities, museums), the color language must remain consistent

### Why Expandable Cards with Separate "Se mere →" Button?
**Decision:** Tap card body = toggle preview. Only "Se mere →" button navigates to full profile.

**Rationale:**
- **Original design:** First tap expanded card, second tap navigated — but users couldn't collapse without navigating away
- **User need:** "I want to compare 3 restaurants quickly before committing to one"
- **Solution:** Separate actions: body = preview toggle, button = navigate
- Uses `stopPropagation` to prevent card toggle when button is tapped
- Alternative considered: swipe-to-expand gesture — rejected because discoverability is poor on mobile

### Why Match Sections Instead of Inline Match Scores?
**Decision:** Group results into three tiers (Matcher alle, Matcher delvist, Andre steder) with visual section headers.

**Rationale:**
- **Scanability:** Users can ignore non-matching restaurants entirely if full matches exist
- **Hierarchy clarity:** Section headers (green, orange, grey) create instant visual chunking
- **Priority surfacing:** Full matches always appear first, even if farther away
- Alternative considered: inline match percentage (e.g., "92% match") — rejected because percentages are abstract, sections are concrete
- Mirrors Google Maps's "Open now" grouping — familiar pattern

### Why Floating Sort Button Instead of Header Integration?
**Decision:** Orange pill floating in bottom-right corner, above tab bar.

**Rationale:**
- **Header density:** Already has location label, search input, title, 3 filter buttons, chip row, and Liste/Kort toggle — six distinct UI elements stacked vertically
- **Adding sort to header would:** (a) make header even taller, (b) confuse hierarchy — which row does what?
- **Floating button benefits:** Always accessible while scrolling, visually distinct, opens clean bottom sheet
- **Precedent:** Common pattern in e-commerce apps (filters top, sort bottom-right)
- Only visible in liste mode — map view doesn't need sorting (sorted by proximity automatically)

### Why Persistent Needs + Session Filters (Two Layers)?
**Decision:** Needs persist across sessions, filters reset when app closes.

**Rationale:**
- **Needs are identity:** "I have celiac disease" doesn't change day-to-day
- **Filters are context:** "I want Italian food in Vesterbro today" is situational
- **UX benefit:** User never re-enters dietary restrictions, but also never stuck with yesterday's cuisine preference
- **Data flow:** Both layers feed into match calculation (allNeeds = activeNeeds + needsFromFilters), but storage differs
- Alternative considered: making all filters persistent — rejected because users felt "locked in" to past searches

### Why Chip Row with Fixed "Ryd alle" Button?
**Decision:** "Ryd alle" button stays fixed on left while chips scroll horizontally underneath.

**Rationale:**
- **Primary action visibility:** Users needed one-tap "clear everything" without scrolling through chip list
- **Visual hierarchy:** "Ryd alle" is the reset action, chips are individual removals
- **Gradient fade:** Creates visual separation between fixed button and scrolling chips
- Alternative considered: "Ryd alle" in filter sheet footer — rejected because users wanted to clear without opening sheet

### Why Collapse Match Card by Default on Profile?
**Decision:** Match card shows one-line summary when collapsed. User must expand to see full need breakdown.

**Rationale:**
- **Full matches are confirmational:** If all needs are met, the card border already communicates success — listing them again is noise
- **Partial matches benefit from expansion:** Info box in list card shows what's missing at a glance, but profile expansion shows full green/red pill list
- **Reduces scroll distance:** Profile page has 11 sections — every pixel of vertical economy helps
- Alternative considered: always expanded — rejected because it pushed gallery and menu too far down

### Why Today's Hours Simplification in Card Preview?
**Decision:** Card shows overall span (07:00–22:00) instead of full slot breakdown (07:00–10:00, 11:30–14:30, 17:00–22:00).

**Rationale:**
- **Primary question:** "Is it open now / when does it close?" — not "What are the exact lunch hours?"
- **Space constraint:** Cards need to stay compact for scanability
- **Mirrors Google Maps:** Shows "Open · Closes 10 PM" regardless of schedule complexity
- **Full detail available:** Profile page's contact section shows complete breakdown when expanded
- Alternative considered: showing only first slot — rejected because misleading (would show "closes 10:00" when it reopens at 11:30)

### Why No Ratings in V1?
**Decision:** Remove star ratings from cards entirely.

**Rationale:**
- **JourneyMate won't have its own review system at launch** — verified capability data is the differentiator
- **Using Google Maps ratings would:** (a) create legal/API dependency, (b) dilute brand identity (users would think "this is just Google Maps with filters")
- **Match quality is the new rating:** "Matcher alle behov" is more meaningful than "4.2 stars" for users with specific needs
- **Planned for future:** When JourneyMate has its own review corpus, ratings will return — but as a secondary signal, not primary
- Alternative considered: showing Google ratings with disclaimer — rejected as confusing

---

## 9. Implementation Notes

### String Identity (Critical for Phase 3)
The matching engine relies on **exact string identity** across three systems:
1. **Needs picker labels:** "Helt glutenfrit"
2. **Filter sheet paths:** Behov → Diæt og restriktioner → Gluten → "Helt glutenfrit"
3. **Restaurant `has` array:** `["Helt glutenfrit", "Fuldt vegansk", ...]`

If strings don't match exactly (whitespace, capitalization, punctuation), the match breaks silently. The filter sheet shows selection, the chip appears, but restaurants don't match.

**Phase 3 implementation must:**
- Use constants/enums for all filter strings (not hardcoded strings scattered through code)
- Validate restaurant data imports against filter schema
- Add unit tests: "Restaurant A has 'Helt glutenfrit' → matches user need 'Helt glutenfrit'"

### Filter Selection Logic (Leaf-Level Only)
**Rule:** If a filter has sub-items, only the sub-item counts as a "real" selection. The parent is a navigation category.

**Example:**
- User navigates: Behov → Diæt og restriktioner → Gluten (column 2) → "Helt glutenfrit" (column 3)
- **Incorrect:** Adding "Gluten" to selectedFilters
- **Correct:** Adding "Helt glutenfrit" to selectedFilters

**Implementation check:** When rendering chips, only leaf-level selections should appear. If "Gluten" appears as a chip, the filter logic is wrong.

### Animation Frame Timing
Bottom sheets use double `requestAnimationFrame` to ensure smooth slide-up animation:

```jsx
const openSheet = (key) => {
  setActiveSheet(key);  // Mount the sheet DOM
  requestAnimationFrame(() =>  // Wait for DOM paint
    requestAnimationFrame(() =>  // Wait one more frame
      setSheetVisible(true)  // Trigger CSS transition
    )
  );
};
```

**Why two frames?**
- First frame: Browser processes `setActiveSheet`, adds DOM elements
- Second frame: Browser paints those elements (still invisible)
- Then: `setSheetVisible(true)` triggers CSS transition from `translateY(100%)` to `translateY(0)`

**Without double RAF:** Sheet appears instantly without animating (CSS transition doesn't trigger on initial render).

### Sort Logic When No Needs Active
When `hasNeeds = false`, the "Bedst match" sort behaves identically to "Nærmest" sort (distance ascending). This prevents broken UX where "match sort" shows arbitrary order when there's nothing to match.

**Implementation:**
```jsx
case "match":
  return hasNeeds
    ? [...list].sort((a, b) => b.matchCount - a.matchCount || parseFloat(a.distance) - parseFloat(b.distance))
    : list;  // No sort applied, keeps original order (which is distance-based in allRestaurants)
```

### Card Stagger Limit
Only the first 8 cards animate with stagger. Subsequent cards render immediately.

**Reason:** Prevents 50+ animations on long result lists, which causes jank on lower-end devices.

**Implementation:**
```jsx
animation: `cardIn 0.25s ease ${Math.min(i, 8) * 0.04}s both`
```

`Math.min(i, 8)` caps the delay at 320ms (8 × 0.04s).

### Closed Restaurant Opacity
Closed restaurants render at `opacity: 0.5` to de-emphasize them while keeping them scannable.

**Why not filter them out entirely?**
- Users might want to see closed restaurants for future planning ("I'll come back tomorrow")
- "Kun åbne steder" toggle exists for users who want to hide them

### Match Section Visibility Logic
```jsx
const showMatchSections = hasNeeds || hasFilters;
```

**Why show sections when only non-Behov filters are active?**
- **Original intent:** Show sections only when needs are active (hasNeeds)
- **Current design:** Show sections when ANY filter is active (hasFilters)
- **Problem:** Location and Type filters don't currently affect match calculation (restaurants have no `lokation` or `type` arrays in `has` field)
- **TODO for Phase 3:** Either (a) remove `|| hasFilters` condition, or (b) implement Location/Type matching in restaurant data model

**Comment in code:**
```jsx
// Show match sections when ANY filter is selected (Location, Type, or Behov)
// NOTE: Match calculation currently only works for Behov filters (stored in r.has array)
// TODO Phase 3: Implement Type and Location matching when real data structure available
```

### Gradient Fade Technique (Chip Row)
The "Ryd alle" button uses a gradient div to create visual separation from scrolling chips:

```jsx
<div style={{width:10, background:"linear-gradient(to right, #fff, transparent)", ...}}/>
```

This creates a 10px fade from white (matching button background) to transparent, smoothly blending into the chip list.

**Why not use box-shadow?** Gradients are more performant and give finer control over fade distance.

### Station Sort Placeholder
The "Nærmest togstation" sort option currently does nothing beyond UI state (sets `activeSort = "station"` and `selectedStation = "København H"`).

**Phase 3 implementation must:**
1. Store restaurant lat/lng and station lat/lng
2. Calculate distance from each restaurant to selected station
3. Sort by that distance
4. Likely involves BuildShip API call (not client-side calculation)

**Footer note in sort sheet:**
> "💡 I den færdige app vil dette sortere steder efter afstand til den valgte station via Typesense & BuildShip."

This note educates the user (and developer) that the feature is planned but not functional.

---

## 10. Open Questions / Future Enhancements

### 1. Search Input Functionality
**Current:** Visual placeholder only. Focus state works, but no search logic.

**Phase 3 needs:**
- Text input triggers API search (Typesense)
- Debounced input (300ms) to avoid excessive API calls
- Search scope: restaurant name, cuisine, dish names, address?
- Search results merge with filter results or replace them?
- Clear button (×) appears when input has text

### 2. Map View Implementation
**Current:** Placeholder ("Kommer snart").

**Phase 3 needs:**
- Google Maps or Mapbox integration
- Restaurant pins on map (color-coded by match quality?)
- Tap pin → show compact card overlay
- Tap card → navigate to profile
- Map follows device location (permission required)
- Cluster pins when zoomed out

### 3. Location Detection
**Current:** Hardcoded "København" at top.

**Phase 3 needs:**
- Device location permission
- Geocode to neighborhood or city name
- Allow manual location change (search for address, pick on map)
- Store last location (don't re-ask every session)
- Distance calculations update when location changes

### 4. Lokation Filter Matching
**Current:** Location filters are selectable but don't affect match calculation (restaurants have no `lokation` field in `has` array).

**Phase 3 options:**
1. **Add `nabolag` and `station` fields to restaurant model** and implement proximity matching
2. **Use actual lat/lng distance** — if user selects "Vesterbro" filter, match restaurants within Vesterbro bounds
3. **Remove Location from match sections** — keep it as a filter but don't show "Matcher alle behov" sections when only location is filtered

### 5. Type Filter Matching
**Current:** Type filters (cuisine, meal type, venue type) don't affect match calculation.

**Phase 3 options:**
1. **Add cuisine types to restaurant `has` array** (already partially exists: `cuisine: "Plantbaseret"`)
2. **Use structured fields** — `cuisineTypes: ["Vegansk", "Nordisk"]`, `venueType: "Restaurant"`
3. **Keep Type as pure filter** — narrows results but doesn't create match hierarchy

### 6. Analytics Events
**Phase 3 must track:**
- Filter sheet opened (which tab)
- Filter selected (Lokation / Type / Behov)
- Sort option selected
- "Kun åbne steder" toggled
- Card expanded
- "Se mere →" tapped (restaurant ID)
- "Ryd alle" tapped
- Chip removed (which filter)
- View mode toggled (liste ↔ kort)
- Search input used

### 7. Error States
**Current design doesn't show:**
- No results (empty state) — should show illustration + message
- API error (network failure) — should show retry button
- Location permission denied — should explain why location is needed

### 8. Accessibility
**Phase 3 must ensure:**
- Filter sheet columns keyboard-navigable
- Sort sheet keyboard-navigable
- Chip removal buttons have accessible labels ("Fjern filter: Helt glutenfrit")
- Card expand/collapse state announced to screen readers
- Match section headers announced
- Floating sort button has accessible label

### 9. Pull-to-Refresh
**Not in current design** but likely needed:
- Swipe down from top → reload restaurant list
- Shows loading spinner
- Useful when new restaurants added or data updated

### 10. "Nyeste" Sort Implementation
**Current:** Sort option exists ("Nyeste" with ✦ icon) but does nothing.

**Phase 3 needs:**
- Restaurant model must have `addedDate` field
- Sort by `addedDate` descending
- Possibly highlight "NEW" badge on recently added restaurants (< 7 days)

---

## 11. File Dependencies

### Imports from `_shared.jsx`
```jsx
import {
  ACCENT,          // #e8751a (orange)
  GREEN,           // #1a9456 (match green)
  GREEN_BG,        // #f0f9f3 (match background)
  GREEN_BORDER,    // #d0ecd8 (match border)
  filterSets,      // Three-dimensional filter data structure
  allRestaurants,  // Restaurant array with capabilities
  trainStations,   // Copenhagen train station list
  Dot,             // 3px grey separator dot
  Check,           // Checkmark icon SVG
  StatusBar,       // iOS-style status bar
  BottomSheet,     // Draggable bottom sheet container
} from "../shared/_shared.jsx";
```

### Local Constants
```jsx
const SORT_OPTIONS = [
  { key: "match",      label: "Bedst match",            icon: "★" },
  { key: "nearest",    label: "Nærmest",                icon: "↕" },
  { key: "station",    label: "Nærmest togstation",     icon: "🚉", hasSubmenu: true },
  { key: "price_low",  label: "Pris: Lav til høj",      icon: "↑" },
  { key: "price_high", label: "Pris: Høj til lav",      icon: "↓" },
  { key: "newest",     label: "Nyeste",                 icon: "✦" },
];
```

### Component Exports
```jsx
export default function SearchPage({ onSelect, activeNeeds, onToggleNeed, onClearAllNeeds, onOpenNeedsPicker }) { ... }
```

**Not exported (local components):**
- `FilterSheet`
- `NeedsPicker`
- `Card`
- `TabBar`

These are page-specific and should not be imported elsewhere. If another page needs similar components, extract to `_shared.jsx` first.

---

## 12. Design System Alignment

This page adheres to the design system defined in `_reference/journeymate-design-system.md`:

### Color Usage (Section 2)
✅ Orange (`ACCENT`) for interactive elements, filter selections, CTAs
✅ Green (`GREEN`) for match confirmations only
✅ No black backgrounds (darkest: `#0f0f0f` text)
✅ No colored shadows (sort button shadow: `rgba(0,0,0,0.12)`)

### Typography (Section 3)
✅ Title: 24px weight 720, letter-spacing -0.025em
✅ Card name: 15.5px weight 630, truncate ellipsis
✅ Filter labels: 13-14px weight 480/640 (inactive/active)
✅ Section headers: 11px weight 620 uppercase

### Spacing (Section 4)
✅ Page padding: 20px
✅ Card padding: 14px, margin-bottom 8px, border-radius 16px
✅ Bottom sheet border-radius: 22px top corners
✅ Filter column widths: 36% / 33% / 31%

### Component Patterns (Section 5)
✅ Bottom sheet: draggable, 80px dismiss threshold, `cubic-bezier(0.32,0.72,0,1)` easing
✅ Filter sheet: three tabs, three columns, fixed widths
✅ Chip row: fixed "Ryd alle" button with gradient fade
✅ Expandable card: tap body = toggle, button = navigate

### Design Decisions (Section 9)
✅ Decision 2: Green for matches, orange for interactions
✅ Decision 3: Unified filter sheet (not three separate sheets)
✅ Decision 4: Fixed column widths (36%/33%/31%)
✅ Decision 9: Expandable cards with explicit "Se mere" navigation
✅ Decision 10: Sort as floating button, not in header
✅ Decision 11: Filter selection hierarchy (leaf-level only)

---

## 13. Differences from FlutterFlow Original

**Note:** This section will be populated during Phase 3 when FlutterFlow audit is complete and side-by-side comparison is possible. For now, this design is documented in isolation.

Placeholder for future comparison:
- [ ] State management differences (FFAppState vs. local state)
- [ ] Navigation differences (FlutterFlow routes vs. JSX parent-managed)
- [ ] API integration differences (BuildShip endpoints)
- [ ] Animation differences (Flutter AnimatedBuilder vs. CSS transitions)
- [ ] Filter data structure differences (Firestore schema vs. JSX constants)
- [ ] Translation system differences (getTranslations() calls vs. hardcoded Danish)

---

## End of Document

**Total Lines:** 590
**Document Type:** Design Specification (JSX Reference)
**Next Steps:**
1. Build remaining JSX pages (onboarding, mine-behov, profil, full-menu, full-gallery, map)
2. Complete FlutterFlow audit (populate `_reference/page-audit.md`)
3. Begin Flutter migration using Three-Source Method (FlutterFlow source + audit + JSX design)

**Last Updated:** 2026-02-19
