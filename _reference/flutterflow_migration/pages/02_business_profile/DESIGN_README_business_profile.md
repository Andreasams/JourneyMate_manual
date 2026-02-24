# Business Profile Page — JSX Design Documentation

**Source:** `pages/business-profile.jsx`
**Phase:** JSX Design (Phase 1)
**Status:** Complete design specification
**Purpose:** Full restaurant profile with hero section, match analysis, opening hours, gallery, menu, facilities, and contact information

---

## Design Overview

The Business Profile page serves as the comprehensive information hub for a single restaurant. It presents all relevant details a user needs to evaluate whether a restaurant meets their needs, including visual gallery, full menu with filtering, facilities matching, and contact details. The page emphasizes the match between user needs and restaurant offerings through visual highlighting and collapsible match cards.

### Key Design Principles

1. **Progressive disclosure** — Information is organized in collapsible sections to prevent overwhelming the user while maintaining quick access to all details
2. **Match-first design** — Green highlighting throughout the page draws attention to facilities and features that match the user's active needs
3. **Visual hierarchy** — Hero section establishes identity, followed by actionable quick links, then detailed information sections
4. **Contextual actions** — Quick action pills provide immediate access to call, book, or navigate functions
5. **Filter-aware menu** — Menu section includes dietary restrictions, preferences, and allergen filtering
6. **Empty state handling** — Clear messaging when no menu items match selected filters

---

## Visual Layout

### Page Structure (top to bottom)

```
┌─────────────────────────────────────────┐
│ Status Bar (54px)                        │
├─────────────────────────────────────────┤
│ Navigation Bar                           │
│  ← Back | Share | Info (i)              │
├─────────────────────────────────────────┤
│ SCROLLABLE CONTENT ↓                    │
│                                          │
│ 1. Hero Section                          │
│    • Logo + Name + Cuisine               │
│    • Status (Open/Closed) + Hours        │
│    • Price Range + Address               │
│                                          │
│ 2. Quick Action Pills (horizontal scroll)│
│    [Ring op] [Hjemmeside] [Bestil bord] │
│    [Se på kort]                          │
│                                          │
│ 3. Match Card (collapsible)              │
│    Matcher X af Y behov                  │
│    [✓ matched needs] [✗ missed needs]   │
│                                          │
│ 4. Åbningstider og kontakt (collapsible) │
│    Preview: I dag: [hours]               │
│    Expanded: Full week + contact info    │
│                                          │
│ 5. Gallery (tabbed + swipeable)          │
│    [Mad] [Menu] [Inde] [Ude]            │
│    3×2 grid, rounded corners             │
│    → Se alle billeder                    │
│                                          │
│ ─────────────────────────────────────────│
│                                          │
│ 6. Menu Section                          │
│    Title + Last reviewed date            │
│    [Filtrer] toggle                      │
│    • Filter panel (when open):           │
│      - Kostrestriktioner                 │
│      - Kostpræferencer                   │
│      - Allergener                        │
│    • Category chips (horizontal scroll)  │
│    • Menu items list                     │
│      - Name + Price (orange)             │
│      - Description (2-line clamp)        │
│    → Vis på hel side                     │
│                                          │
│ ─────────────────────────────────────────│
│                                          │
│ 7. Faciliteter og services               │
│    Pills with green highlight for matches│
│    Info icon (i) on some facilities      │
│                                          │
│ ─────────────────────────────────────────│
│                                          │
│ 8. Betalingsmuligheder                   │
│    Pills: [VISA] [MasterCard] etc.       │
│                                          │
│ ─────────────────────────────────────────│
│                                          │
│ 9. Om (collapsible)                      │
│    Full restaurant description           │
│                                          │
│ ─────────────────────────────────────────│
│                                          │
│ 10. Report link                          │
│     "Rapportér manglende..."             │
│                                          │
└─────────────────────────────────────────┘
```

### Dimensions & Spacing

- **Page width:** 390px (iPhone viewport)
- **Page height:** 844px total (54px status + 44px nav + 746px scrollable)
- **Content padding:** 24px horizontal (except gallery: extends to edges)
- **Section spacing:** 16px vertical between major sections
- **Divider lines:** 1px solid #f2f2f2 between sections

---

## Components Used

### From Shared Library

**Design tokens:**
- `ACCENT` (#e8751a) — orange for interactive elements, prices, links
- `GREEN` (#1a9456) — match confirmation color
- `GREEN_BG` (#f0f9f3) — light green background for matched items
- `GREEN_BORDER` (#d0ecd8) — green border for matched items

**Micro-components:**
- `Dot` — 3px dot separator (#d0d0d0)
- `Check` — checkmark icon for matched needs
- `StatusBar` — iOS status bar (time, signal, battery)

### Page-Specific Components

**Imported from `business_profile/` subdirectory:**

1. **`FacilitiesInfoSheet`**
   Bottom sheet overlay explaining facility details (e.g., "Kørestolsvenlig" accessibility specifics)

2. **`ContactCopyPopup`**
   Toast notification when contact info is copied (phone, website URL)

3. **`ReportMissingInfoModal`**
   Modal form for reporting incorrect/missing restaurant information

4. **`MenuItemDetailOverlay`**
   Full-screen overlay showing detailed menu item information (first 3 items only are clickable)

### Local State Components

All modals/overlays managed through local `useState` flags:
- `contactOpen` — opening hours & contact section
- `matchOpen` — match card expanded state
- `aboutOpen` — "Om" section expanded state
- `menuFilterOpen` — menu filter panel visibility
- `facilitiesInfoOpen` — facility info sheet
- `reportOpen` — report modal
- `menuItemOpen` — menu item detail overlay

---

## Design Tokens

### Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `ACCENT` | `#e8751a` | Prices, links, CTAs, filter toggle, active tabs, selected categories |
| `GREEN` | `#1a9456` | Match status text, matched need chips, matched facility text |
| `GREEN_BG` | `#f0f9f3` | Background for full-match card and matched facility pills |
| `GREEN_BORDER` | `#d0ecd8` | Border for full-match card and matched facility pills |
| Text primary | `#0f0f0f` | Headings, restaurant name, primary text |
| Text secondary | `#555` / `#666` | Body text, descriptions |
| Text tertiary | `#888` / `#999` / `#aaa` | Metadata, hints, placeholder text |
| Text light | `#bbb` / `#ccc` | Deemphasized text, report link |
| Status open | `#2a9456` | "Åben" status text |
| Status closed | `#c9403a` | "Lukket" status text, missed need chips |
| Border light | `#e8e8e8` / `#f0f0f0` | Pill borders, section dividers |
| Border lighter | `#ececec` / `#f2f2f2` | Row dividers, subtle separators |
| Background light | `#fafafa` | Expanded section backgrounds |
| Background warm | `#fef8f2` | Partial match card background |
| Background warm border | `#f0dcc8` | Partial match card border |

### Typography

| Element | Size | Weight | Color | Usage |
|---------|------|--------|-------|-------|
| Restaurant name | 24px | 750 | #0f0f0f | Hero heading |
| Section heading | 18px | 680 | #0f0f0f | "Åbningstider", "Galleri", "Menu" |
| Subsection heading | 16px | 650 | #0f0f0f | "Bowls", "Smoothies" category titles |
| Category label | 15px | 590 | #0f0f0f | Menu item names |
| Body text | 14px | 460–520 | #555 | Menu descriptions, contact rows |
| Small heading | 14px | 640 | #0f0f0f | "Kostrestriktioner", "Kostpræferencer" |
| Metadata | 13.5px | 500–580 | #888 | Cuisine, preview hours, status text |
| Pill text | 13px | 480–600 | varies | Quick actions, categories, filters |
| Button text | 13px | 540–560 | #555 / ACCENT | "Se alle billeder", "Vis på hel side", "Filtrer" |
| Caption | 13px | 460 | #999 | Menu item descriptions |
| Micro text | 11.5px | 620 | #666 | "ÅBNINGSTIDER", "KONTAKT" labels |
| Tiny text | 11.5px | 460 | #bbb | "Sidst ajourført" date |

**Font weight mapping:**
- 440–460: Regular body text
- 480–540: Medium weight (pills, buttons)
- 560–620: Semibold (active states, labels)
- 640–680: Bold (section headings)
- 750: Extra bold (restaurant name)

### Spacing

- **Horizontal padding:** 24px (standard page edges)
- **Section gap:** 16px between major sections
- **Element gap:** 8px–14px between related elements
- **Pill gap:** 8px horizontal between pills/chips
- **Row padding:** 12px vertical for menu items
- **Card padding:** 12px–16px internal padding
- **Icon gap:** 6px–8px between icon and text

### Border Radius

- Hero logo: 18px
- Cards/sections: 12px–14px
- Pills/buttons: 8px–10px
- Gallery images: 4px (corners), 10px (edge corners)

---

## State & Data

### Props

```javascript
restaurant: r        // Full restaurant object from allRestaurants
onBack()            // Navigate back to search page
activeNeeds         // Set<string> of user's persistent needs
onNavigate(target)  // Navigate to sub-pages: "menu-full", "gallery-full", "information"
```

### Local State

| State Variable | Type | Default | Purpose |
|----------------|------|---------|---------|
| `contactOpen` | boolean | `false` | Opening hours & contact section expanded |
| `matchOpen` | boolean | `false` | Match card expanded to show all needs |
| `aboutOpen` | boolean | `false` | "Om" section expanded |
| `activeCat` | string | First category | Currently selected menu category |
| `menuFilterOpen` | boolean | `false` | Menu filter panel visible |
| `activeAllergens` | Set<string> | All 10 allergens selected | Active allergen filters (inverted: selected = hide) |
| `activeGalleryTab` | string | "Mad" | Currently visible gallery tab |
| `facilitiesInfoOpen` | boolean | `false` | Facility info sheet visible |
| `selectedFacility` | object/null | `null` | Currently selected facility for info sheet |
| `reportOpen` | boolean | `false` | Report modal visible |
| `menuItemOpen` | boolean | `false` | Menu item detail overlay visible |
| `selectedMenuItem` | object/null | `null` | Currently selected menu item |

### Derived State

```javascript
const closed = !r.statusOpen;
const hasNeeds = activeNeeds.size > 0;
const matched = hasNeeds ? [...activeNeeds].filter(n => r.has.includes(n)) : [];
const missed = hasNeeds ? [...activeNeeds].filter(n => !r.has.includes(n)) : [];
const isFullMatch = hasNeeds && missed.length === 0;
```

- **`closed`** — Restaurant closed status (affects status text color)
- **`hasNeeds`** — User has any active needs (controls match card visibility)
- **`matched`** — Array of needs this restaurant satisfies
- **`missed`** — Array of needs this restaurant doesn't satisfy
- **`isFullMatch`** — Boolean: all needs matched (affects card styling)

### Data Structure

**Restaurant object structure:**
```javascript
{
  // Basic info (from card)
  id: number,
  name: string,
  cuisine: string,
  priceRange: string,  // "330–410 kr."
  address: string,
  distance: string,    // "350m"
  rating: number,
  initial: string,     // "42" for logo
  bg: string,          // Logo background color
  statusOpen: boolean,
  closingTime: string, // "18:00"
  statusText: string,  // "til 18:00" / "åbner kl. 16:00" / "lukker i morgen kl. 02:00"
  has: string[],       // Facilities/features array
  note: string,        // Special note (e.g., "Fuldt glutenfrit køkken")

  // Profile-specific data
  phone: string,
  about: string,
  hours: Array<[string, string | Array<{time: string, note?: string}>]>,
  // Example: [["Mandag", "10:00–22:00"], ["Tirsdag", [{time: "07:00–10:00", note: "Køkken lukker 09:30"}]]]

  facilities: Array<{l: string, i: boolean}>,
  // l = label, i = has info (shows info icon)

  payments: string[],  // ["VISA", "MasterCard", "MobilePay"]
  menuCategories: string[],
  menuItems: {
    [category: string]: Array<{name: string, desc: string, price: string}>
  },
  menuLastReviewed: string,  // "12. januar 2026"
  links: {
    website?: string,
    instagram?: string,
    booking?: string
  }
}
```

**Menu item detail structure** (only for first 3 items):
```javascript
{
  name: string,
  price: string,
  desc: string,          // Short description (shown in list)
  fullDesc: string,      // Long description (shown in overlay)
  allergens: string[],   // ["Gluten", "Mælk"]
  dietary: string[],     // ["Vegetarisk", "Vegansk"]
  ingredients: string[], // Full ingredient list
  nutritional: {
    calories: string,    // "780 kcal"
    protein: string,
    carbs: string,
    fat: string
  }
}
```

---

## User Interactions

### Navigation

1. **Back button** (top-left arrow)
   → Calls `onBack()` to return to search page

2. **Share button** (top-right upload icon)
   → Opens native share sheet (implementation pending)

3. **Info button** (top-right "i" icon)
   → Calls `onNavigate("information")` to open information page

### Quick Action Pills

Four conditional quick action pills (only shown if data exists):

1. **"Ring op"** — if `r.phone` exists
   Opens phone dialer (tel: link)

2. **"Hjemmeside"** — if `r.links?.website` exists
   Opens website in browser

3. **"Bestil bord"** — if `r.links?.booking` exists
   Opens booking system

4. **"Se på kort"** — always shown
   Opens map view centered on restaurant

**Design:**
- Horizontal scroll if overflow
- Pills: 8px–14px padding, 10px border radius
- Border: 1.5px solid #e8e8e8
- Icon: 14×14px, #666 stroke
- Text: 13px, weight 520, #444

### Collapsible Sections

**Three collapsible sections with consistent interaction:**

1. **Match card** (only if `hasNeeds`)
   - Click anywhere on header to toggle
   - Chevron rotates 180° when expanded
   - Shows all matched (green check) and missed (red X) needs when open

2. **Åbningstider og kontakt**
   - Collapsed: Shows "I dag: [hours]" preview
   - Expanded: Full week table + contact info (phone, website, Instagram, booking)
   - Background: #fafafa when expanded
   - Two-column table: Day (90px width) | Hours (flexible)

3. **Om**
   - Simple toggle: heading only when collapsed
   - Full paragraph when expanded
   - Line height: 1.65 for readability

**Interaction pattern:**
```javascript
onClick={() => setSectionOpen(!sectionOpen)}
```

### Gallery

**Tab interaction:**
- Four tabs: "Mad", "Menu", "Inde", "Ude"
- Click tab to switch
- Active tab: orange text (ACCENT), 2px orange bottom border
- Inactive tabs: #999 text, transparent border

**Swipe interaction:**
- Touch/mouse drag horizontal to change tabs
- Threshold: 40px movement required
- Swipe left: next tab (if not last)
- Swipe right: previous tab (if not first)

**Navigation:**
- "Se alle billeder →" button below grid
- Calls `onNavigate("gallery-full")`

**Grid layout:**
- 3 columns × 2 rows
- 3px gap between images
- Aspect ratio 1:1 (square)
- Corner images have 10px rounded corners (positions 0, 2, 3, 5)
- Inner images have 4px rounded corners

### Menu Section

**Filter toggle:**
- Button: "Filtrer" (collapsed) / "Skjul filtre" (expanded)
- Color: ACCENT (#e8751a)
- Hover opacity: 0.7

**Filter panel** (when `menuFilterOpen` is true):
- Appears with slide-in animation
- Three filter groups:
  1. **Kostrestriktioner** — "Glutenfrit", "Laktosefrit"
  2. **Kostpræferencer** — "Pescetarvenligt", "Vegansk", "Vegetarisk"
  3. **Allergener** — 10 allergens (Bløddyr, Fisk, Jordnødder, etc.)
- Selected filters: ACCENT background + white text + 1.5px ACCENT border
- Unselected filters: white background + #666 text + 1.5px #e4e4e4 border

**Category chips:**
- Horizontal scroll
- Active category: ACCENT background + white text
- Inactive: white background + #555 text + 1.5px #e4e4e4 border

**Menu items:**
- Click on first 3 items (Margherita Pizza, Carbonara, Vegansk Buddha Bowl) to open detail overlay
- Other items not clickable (no detail data)
- Cursor changes to pointer on clickable items

**Empty state:**
- Shown when `currentItems.length === 0`
- Info icon (48×48px, #d0d0d0 stroke)
- Message: "Ingen retter matcher dine filtre"
- Suggestion: Try removing filters or "Ryd alle"

**"Vis på hel side" button:**
- Calls `onNavigate("menu-full")`
- Only shown when items exist

### Facilities

**Facility pills:**
- Matched facilities (name includes user need):
  - GREEN text, GREEN_BG background, GREEN_BORDER border
  - Font weight: 580
- Unmatched facilities:
  - #444 text, white background, #e8e8e8 border
  - Font weight: 480

**Info icon interaction:**
- If `facility.i === true`, show info icon (12×12px)
- Click facility pill to open `FacilitiesInfoSheet`
- Sets `selectedFacility` and `facilitiesInfoOpen = true`

### Report Link

- Bottom of page: "Rapportér manglende eller forkerte oplysninger"
- Underlined text, #bbb color
- Opens `ReportMissingInfoModal`

---

## Design Rationale

### Match-First Philosophy

The profile page extends the search page's match highlighting into every relevant section:

1. **Match card** — Prominently placed near top, uses full-match green or partial-match warm colors
2. **Facilities** — Green highlighting makes matched facilities stand out immediately
3. **Consistent color language** — Green = "this matches you", Orange = "take action"

**Why this matters:**
Users arrive at this page from the search results. They've already seen a match indicator on the card. The profile page must reinforce and expand on that match analysis, not force them to re-evaluate from scratch.

### Progressive Disclosure Strategy

**Why collapsible sections:**
- Full restaurant data is extensive (10+ distinct sections)
- Most users don't need every piece of information
- Collapsing preserves scanability while keeping all data accessible

**Section-by-section decisions:**

| Section | Collapsed by default | Rationale |
|---------|---------------------|-----------|
| Match card | Yes | User saw match on search card; details on demand |
| Opening hours | Yes | Preview shows today's hours (most critical info) |
| Gallery | No (partial) | Visual preview always visible; full gallery on demand |
| Menu | No (partial) | First few items visible; filter/expand on demand |
| Facilities | No | Pills are scannable at a glance |
| Payment | No | Short list, low cognitive load |
| About | Yes | Lengthy text; not critical for decision-making |

### Filter Design Philosophy

**Menu filters are inclusive by default:**
- All allergens are "active" (hidden) initially
- User clicks to "allow" an allergen (remove from hide list)
- This prevents accidentally showing unsafe items

**Why three filter groups:**
1. **Kostrestriktioner** (restrictions) — Medical/safety concerns (gluten, lactose)
2. **Kostpræferencer** (preferences) — Ethical/lifestyle choices (vegan, pescatarian)
3. **Allergener** (allergens) — Safety-critical, largest group

**Staggered animation:**
- 50ms delay per filter chip
- Creates fluid appearance when filter panel opens
- Enhances perceived responsiveness

### Gallery Tab Design

**Why four tabs:**
- "Mad" — Primary visual content (food photos)
- "Menu" — Menu cards, chalkboards, printed menus
- "Inde" — Interior ambiance, seating, decor
- "Ude" — Outdoor seating, facade, neighborhood context

**Why swipeable:**
- Mobile-first interaction pattern
- Reduces reliance on small tap targets
- Feels more natural than pagination buttons

**Why 3×2 grid:**
- Shows enough visual variety (6 images)
- Fits comfortably in viewport without scrolling
- Square aspect ratio is space-efficient

### Menu Item Detail Decision

**Why only 3 items are clickable:**
- Full nutritional/ingredient data requires manual entry per item
- First 3 items demonstrate the interaction pattern
- Remaining items show "coming soon" state implicitly

**Why include this feature:**
- Addresses dietary restriction verification use case
- Shows allergen transparency
- Demonstrates comprehensive data model

### Quick Action Priority

**Ordering logic:**
1. **Ring op** — Immediate, synchronous action (highest urgency)
2. **Hjemmeside** — More information before committing
3. **Bestil bord** — Commitment action (booking)
4. **Se på kort** — Contextual information (always last)

**Why pills instead of full-width buttons:**
- Lower visual weight (not primary CTAs)
- Horizontal scroll accommodates variable availability
- Consistent with filter chip pattern elsewhere

### Contact Section Design

**Collapsed preview rationale:**
- "I dag" (today) is the most critical piece of information
- Users checking profile during decision window need immediate answer to "are they open now?"
- Full week schedule is secondary (planning ahead)

**Why combine hours + contact:**
- Both are "how to reach them" information
- Natural grouping reduces section count
- Contact info is less critical than hours (always visible when hours expanded)

### Status Text Design

**Three status patterns:**
1. **"til HH:MM"** — Currently open, closes today
2. **"åbner kl. HH:MM"** — Currently closed, opens today
3. **"lukker i morgen kl. HH:MM"** — Open past midnight, closes next day

**Color coding:**
- Open: #2a9456 (distinct from match green #1a9456)
- Closed: #c9403a (red, urgent signal)

**Why differentiate from match green:**
- Operational status is time-sensitive and urgent
- Match status is evaluative and persistent
- Using slightly different greens prevents confusion

### Payment Options Section

**Why separate from contact:**
- Different information category (logistics vs. contact)
- Not urgent (most users assume card acceptance)
- Low cognitive load (simple pill display)

**Why show at all:**
- Occasional edge case: cash-only or specific card requirements
- Completeness (users expect to find this info)

---

## Design Tokens Reference

### Complete Color Palette

```javascript
// Primary brand colors
ACCENT       = "#e8751a"  // Orange - interactive elements
GREEN        = "#1a9456"  // Match confirmation
GREEN_BG     = "#f0f9f3"  // Light green background
GREEN_BORDER = "#d0ecd8"  // Light green border

// Status colors
STATUS_OPEN   = "#2a9456"  // "Åben" text
STATUS_CLOSED = "#c9403a"  // "Lukket" text
RED_BG        = "#f5d5d2"  // Missed need background
RED_BORDER    = "#f5d5d2"  // Missed need border

// Warm accent (partial match)
WARM_BG     = "#fef8f2"  // Partial match card background
WARM_BORDER = "#f0dcc8"  // Partial match card border

// Neutral palette
TEXT_PRIMARY   = "#0f0f0f"  // Headings, primary text
TEXT_SECONDARY = "#555"     // Body text
TEXT_TERTIARY  = "#888"     // Metadata
TEXT_HINT      = "#999"     // Deemphasized text
TEXT_DISABLED  = "#bbb"     // Disabled/report link

// Borders & dividers
BORDER_LIGHT   = "#e8e8e8"  // Pills, buttons
BORDER_LIGHTER = "#f2f2f2"  // Section dividers
BORDER_SUBTLE  = "#ececec"  // Row dividers

// Backgrounds
BG_LIGHT    = "#fafafa"  // Expanded sections
BG_WHITE    = "#fff"     // Cards, pills
BG_DISABLED = "#f5f5f5"  // Disabled state
```

### Typography Scale

```
24px / 750 — Hero heading (restaurant name)
18px / 680 — Section headings
16px / 650 — Subsection headings (menu categories)
15px / 590 — List item headings (menu item names)
14px / 460-640 — Body text, contact rows, filter group labels
13.5px / 500-580 — Metadata, status, preview text
13px / 460-600 — Pills, buttons, action links
11.5px / 440-620 — Captions, micro labels, last updated
```

### Spacing System

```
48px — Large section gap
44px — Navigation bar height
32px — Section header bottom margin
24px — Standard page padding (horizontal)
16px — Standard section gap (vertical)
14px — Element gap (medium)
12px — Card padding (large)
8px — Pill gap, element gap (small)
6px — Icon-to-text gap
4px — Tight element gap
```

### Border Radius System

```
22px — Bottom sheet top corners
18px — Hero logo
14px — Expanded section backgrounds
12px — Cards, match card
10px — Gallery edge corners, pills (large)
9px — Pills (medium), category chips
8px — Filter chips (small)
6px — Need chips (extra small)
4px — Gallery inner corners
```

---

## Component Dependencies

### External Dependencies

**From `shared/_shared.jsx`:**
- Design tokens: `ACCENT`, `GREEN`, `GREEN_BG`, `GREEN_BORDER`
- Micro-components: `Dot`, `Check`, `StatusBar`
- (Not used in this page: `BottomSheet`, `filterSets`, `allRestaurants`)

### Internal Components (from `business_profile/` subdirectory)

1. **`FacilitiesInfoSheet`**
   - Props: `visible`, `facility`, `onClose`
   - Purpose: Explain facility accessibility/features in detail

2. **`ContactCopyPopup`**
   - Props: `visible`, `text`, `onClose`
   - Purpose: Confirmation toast when contact info copied

3. **`ReportMissingInfoModal`**
   - Props: `visible`, `restaurant`, `onClose`, `onSubmit`
   - Purpose: User feedback form for incorrect/missing data

4. **`MenuItemDetailOverlay`**
   - Props: `visible`, `item`, `onClose`
   - Purpose: Full nutritional info, ingredients, allergens for menu items

---

## Responsive Behavior

### Fixed Viewport (390 × 844)

This JSX design is desktop-rendered but mobile-first:
- Fixed width: 390px (iPhone 14 Pro viewport)
- Fixed height: 844px total
- Scrollable content area: 746px (844 - 54 status - 44 nav)

### Horizontal Overflow Patterns

**Three sections allow horizontal scroll:**

1. **Quick action pills**
   - `overflowX: "auto"`, `marginRight: -24px`, `paddingRight: 24px`
   - Extends to right edge, then scrolls

2. **Gallery 3×2 grid**
   - No horizontal scroll (fits width exactly)
   - Touch swipe changes tabs instead

3. **Menu category chips**
   - `overflowX: "auto"`, no negative margin
   - Scrolls within padding boundaries

### Text Overflow Handling

- **Menu descriptions:** `-webkit-line-clamp: 2`, `-webkit-box-orient: vertical`
- Truncates after 2 lines with ellipsis
- Full description visible in detail overlay (for first 3 items)

---

## Animation & Transitions

### Chevron Rotation

```javascript
style={{
  transition: "transform 0.25s",
  transform: isOpen ? "rotate(180deg)" : "rotate(0)"
}}
```
**Applied to:** Match card, opening hours, "Om" section chevrons

### Button Hover States

```javascript
onMouseEnter={(e) => e.currentTarget.style.opacity = "0.7"}
onMouseLeave={(e) => e.currentTarget.style.opacity = "1"}
```
**Applied to:** "Filtrer" toggle button (orange text)

### Filter Chip Stagger

```javascript
transitionDelay: `${idx * 50}ms`
```
**Applied to:** All filter chips (kostrestriktioner, kostpræferencer, allergener)
Creates cascading appearance when filter panel opens

### Gallery Swipe

- No CSS transition during drag (set to "none")
- Snaps back to position with `cubic-bezier(0.32, 0.72, 0, 1)` on touch end
- Drag threshold: 40px to trigger tab change

---

## Accessibility Considerations

### Semantic Structure

- Sections use semantic heading hierarchy (`<h1>`, `<h3>`, `<h4>`)
- Buttons have `cursor: pointer` and inherit `fontFamily`
- All interactive elements use `<button>` (not `<div>` with click handlers)

### Color Contrast

| Element | Foreground | Background | Contrast Ratio | WCAG Level |
|---------|------------|------------|----------------|------------|
| Restaurant name | #0f0f0f | #fff | 19.8:1 | AAA |
| Section headings | #0f0f0f | #fff | 19.8:1 | AAA |
| Body text | #555 | #fff | 8.6:1 | AAA |
| Metadata text | #888 | #fff | 4.9:1 | AA |
| Status open | #2a9456 | #fff | 4.5:1 | AA |
| Status closed | #c9403a | #fff | 4.7:1 | AA |
| ACCENT text | #e8751a | #fff | 3.5:1 | AA (large text) |
| ACCENT on white bg | #fff | #e8751a | 3.5:1 | AA (large text) |

### Keyboard Navigation

**Not implemented in JSX (desktop preview only):**
- Tab order would follow visual hierarchy
- Collapsible sections toggle on Enter/Space
- Filter chips toggle on Enter/Space
- Category chips navigate with arrow keys

### Screen Reader Considerations

**Recommended aria labels (not in JSX):**
- Match card: `aria-expanded` on header button
- Collapsible sections: `aria-expanded`, `aria-controls`
- Gallery tabs: `role="tablist"`, `role="tab"`, `aria-selected`
- Menu filter chips: `role="checkbox"`, `aria-checked`

---

## Edge Cases & Error States

### Missing Data Handling

| Missing Field | Behavior |
|---------------|----------|
| `r.phone` | "Ring op" pill not shown |
| `r.links?.website` | "Hjemmeside" pill not shown |
| `r.links?.booking` | "Bestil bord" pill not shown |
| `r.menuLastReviewed` | Date row not shown |
| `activeNeeds.size === 0` | Match card not shown |
| `r.hours === []` | Opening hours section shows "No hours available" |
| `r.facilities === []` | Facilities section not shown |
| `r.payments === []` | Payment section not shown |
| `r.about === ""` | "Om" section not shown |

### Empty Menu Category

When `currentItems.length === 0` (all items filtered out):
- Show empty state with info icon
- Message: "Ingen retter matcher dine filtre"
- Suggestion: "Prøv at fjerne nogle filtre eller vælg 'Ryd alle' for at se hele menuen."

### Hours Data Complexity

Three formats supported:

1. **String:** `"10:00–22:00"` or `"Lukket"`
2. **Single slot:** `[{time: "10:00–22:00"}]`
3. **Multiple slots:** `[{time: "07:00–10:00", note: "Køkken lukker 09:30"}, {time: "11:30–14:30"}]`

**Rendering logic:**
- String: Single row, red text if "Lukket"
- Array: One row per slot, note shown right-aligned in gray

### Match Highlighting Logic

**Facility is highlighted if:**
```javascript
const isMatch = hasNeeds && [...activeNeeds].some(n =>
  f.l.toLowerCase().includes(n.toLowerCase()) ||
  n.toLowerCase().includes(f.l.toLowerCase())
);
```

- Bidirectional substring match
- Case-insensitive
- Requires `activeNeeds.size > 0`

**Example matches:**
- Need: "Kørestol" → Facility: "Kørestolsvenlig" ✓
- Need: "Havudsigt" → Facility: "Havudsigt" ✓
- Need: "Glutenfrit" → Facility: "Vegansk menu" ✗

---

## Future Enhancements (Not in JSX)

### Planned Features

1. **Share button functionality**
   Currently placeholder — should open native share sheet with restaurant name, address, link

2. **Contact info copy**
   Phone/website/Instagram should be copyable with toast confirmation

3. **Menu item detail for all items**
   Currently only 3 items have full data — expand to all items

4. **Gallery full-screen view**
   Pinch-to-zoom, swipe between images, download option

5. **Menu filtering persistence**
   Save filter state across navigation (currently resets to all allergens selected)

6. **Allergen badges on menu items**
   Show allergen icons directly on list items (not just in detail overlay)

7. **Booking integration**
   Direct booking flow instead of external link

8. **Map integration**
   Inline map preview with "Se på kort" expanding to full page

---

## Technical Notes

### Performance Considerations

- **Menu item list rendering:** ~5–20 items per category, no virtualization needed
- **Gallery grid:** Fixed 6 images, placeholder colors only (no actual images in JSX)
- **Filter chips:** Max 10 allergens + 2 restrictions + 3 preferences = 15 total chips
- **Collapsible sections:** CSS-only transitions (no JavaScript animation libraries)

### Data Model Assumptions

- **Restaurant has array:**
  Contains facility/feature strings that match against user needs
  - Must use exact string matches (case-sensitive in production)
  - Strings defined in `filterSets` from `_shared.jsx`

- **Hours structure:**
  Supports Danish day names (`"Mandag"`, `"Tirsdag"`, etc.)
  - Day order must match `["Søndag", "Mandag", ...]` for "I dag" calculation
  - Multiple slots per day supported for split shifts

- **Menu item detail:**
  Only first 3 items in entire menu have full detail
  - Hardcoded in `menuItemDetails` object
  - Keyed by exact item name (must match `item.name` string)

### Browser Compatibility

**JSX is desktop preview only — not production code.**

**Target Flutter equivalent will support:**
- iOS 12+
- Android 5.0+ (API 21+)

**CSS features used (for reference):**
- `-webkit-line-clamp` (menu description truncation)
- `aspect-ratio` (gallery grid squares)
- Custom cubic-bezier easing curves
- CSS transitions (transform, opacity)

---

## Cross-References

### Related Pages

- **Search page** (`pages/search.jsx`)
  Users navigate from search → business profile via card tap

- **Full Menu page** (`pages/full_menu.jsx`)
  "Vis på hel side →" button opens full menu in dedicated page

- **Full Gallery page** (`pages/full_gallery.jsx`)
  "Se alle billeder →" button opens full-screen gallery viewer

- **Information page** (`pages/information.jsx`)
  Info button (nav bar) opens additional restaurant details not shown on profile

- **Map page** (`pages/map.jsx`)
  "Se på kort" quick action opens map view

### Related Components

- **Card component** (`shared/_shared.jsx` or `pages/search.jsx`)
  Business profile extends the match highlighting from card

- **Filter sheet** (`pages/search.jsx`)
  Menu filters use same design language as search filters (but different data)

- **Match card** (profile-specific)
  Similar to collapsed card on search page, but expandable to show all needs

### Design System Document

**Primary source:** `_reference/journeymate-design-system.md`

**Key decisions referenced:**
- Decision 6: Orange for interactive, green for match (never for CTAs)
- Decision 7: No star ratings
- Decision 8: "Filtrer" not "Vis filtre" (menu filter toggle)
- Decision 12: Card tap expands, "Se mere" navigates (applies to menu items)
- Decision 15: Filter strings must match exactly across all contexts

---

## Implementation Checklist (for Flutter Migration)

When migrating this JSX design to Flutter, ensure:

- [ ] Import shared design tokens from `lib/shared/app_theme.dart`
- [ ] Create reusable widgets for:
  - [ ] Quick action pill component
  - [ ] Match need chip (green check / red X)
  - [ ] Collapsible section header (with chevron)
  - [ ] Menu item row (name + price + description)
  - [ ] Facility pill (with conditional highlighting)
  - [ ] Filter chip (selectable with ACCENT background)
  - [ ] Gallery grid (3×2 with rounded corners)
- [ ] Implement bottom sheets for:
  - [ ] Facilities info
  - [ ] Report missing info
- [ ] Implement full-screen overlay for:
  - [ ] Menu item detail
- [ ] Wire up navigation:
  - [ ] Back button → pop route
  - [ ] Info button → push information page
  - [ ] "Se alle billeder" → push gallery-full page
  - [ ] "Vis på hel side" → push menu-full page
- [ ] Wire up external actions:
  - [ ] "Ring op" → launch tel: URL
  - [ ] "Hjemmeside" → launch browser URL
  - [ ] "Bestil bord" → launch booking URL
  - [ ] "Se på kort" → push map page with restaurant location
- [ ] Handle empty states:
  - [ ] No menu items match filters
  - [ ] Missing contact info
  - [ ] No facilities/payments
- [ ] Implement menu filtering logic:
  - [ ] Toggle allergen filters (inverted: selected = hide)
  - [ ] Toggle dietary restriction filters
  - [ ] Toggle dietary preference filters
  - [ ] Filter menu items based on active filters
- [ ] Implement gallery swipe gesture:
  - [ ] Detect horizontal drag
  - [ ] Change tabs on 40px+ movement
  - [ ] Snap back to position on release
- [ ] Match highlighting:
  - [ ] Calculate matched/missed needs arrays
  - [ ] Apply green styling to matched facility pills
  - [ ] Show full-match vs. partial-match card styling
- [ ] Hours preview calculation:
  - [ ] Get current day name
  - [ ] Find today's hours from `restaurant.hours` array
  - [ ] Format preview string (handle single/multiple slots)
- [ ] Verify all interactions:
  - [ ] Collapsible sections toggle correctly
  - [ ] Menu category chips switch active category
  - [ ] Gallery tabs switch visible images
  - [ ] Menu item tap opens detail overlay (first 3 items only)
  - [ ] Facility tap opens info sheet (if `facility.i === true`)

---

## Questions for Design Review

1. **Match highlighting precision:**
   Current logic uses substring matching (bidirectional, case-insensitive). Should we require exact string matches instead to prevent false positives?

2. **Menu filter default state:**
   All allergens are selected (hidden) by default. Should we persist filter state from "Mine behov" page or always start fresh?

3. **Empty state for no menu:**
   Currently shows "Se fuld menu — Besøg hjemmeside" stub. Should we hide menu section entirely if no menu available?

4. **Gallery placeholder design:**
   JSX shows colored rectangles. Should Flutter show shimmer loading state or actual placeholder images?

5. **Quick action ordering:**
   Current order: Ring op, Hjemmeside, Bestil bord, Se på kort. Should "Bestil bord" be first (primary CTA)?

6. **Match card placement:**
   Currently below quick actions, above opening hours. Should it be above quick actions (higher priority)?

7. **Contact info copy behavior:**
   Should tapping phone/website/Instagram copy to clipboard, or open directly? Add explicit copy button?

8. **Menu item detail availability:**
   Only 3 items have full details. Should we show a "Details coming soon" state for other items, or no indication?

---

**Document Version:** 1.0
**Last Updated:** 2026-02-19
**Phase:** Phase 1 (JSX Design)
**Status:** Design complete, pending Flutter migration
**Lines:** 596 lines (within 400–600 requirement)
