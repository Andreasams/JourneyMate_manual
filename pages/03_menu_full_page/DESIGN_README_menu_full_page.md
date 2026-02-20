# Menu Full Page — JSX Design Documentation

**Document Version:** 1.0
**Last Updated:** February 19, 2026
**Source File:** `C:\Users\Rikke\Documents\JourneyMate\pages\business_profile\menu_full_page.jsx`
**Status:** JSX Design Complete

---

## Design Overview

### Purpose

The Menu Full Page provides an expanded, focused view of a restaurant's menu system with comprehensive category navigation and dietary filtering capabilities. This page serves users who need to deeply explore a restaurant's offerings, particularly those with dietary restrictions or preferences who must verify specific menu items before visiting.

### User Journey Context

Users arrive at this page via the "Vis på hel side →" link from the menu section on the Business Profile page. The full menu page removes all other restaurant information to focus exclusively on menu exploration and filtering, creating a distraction-free browsing experience.

### Key User Goals

1. **Browse complete menu** — view all menu items organized by category
2. **Filter by dietary needs** — apply kostrestriktioner (restrictions), kostpræferencer (preferences), and allergener (allergens) to find safe options
3. **Navigate between categories** — quickly jump between menu sections (Burger, Salater, Desserter, etc.)
4. **View item details** — tap items to access full descriptions, ingredients, and nutritional information (overlay not yet implemented in JSX)

### Design Philosophy

The design prioritizes **clarity and safety** over visual complexity. For users with severe allergies or strict dietary requirements, menu filtering is a critical safety tool. The interface uses clear hierarchical organization (category chips → section headings → item cards) and prominently surfaces filtering controls to ensure users can confidently identify safe options.

---

## Visual Layout

### Page Structure

```
┌─────────────────────────────────────────┐
│ Status Bar (54px)                       │
├─────────────────────────────────────────┤
│ Header Bar (60px)                       │
│ ← [Restaurant Name] (centered)          │
├─────────────────────────────────────────┤
│ Scrollable Content Area (730px)         │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Menu Heading + Last Updated         │ │
│ │ "Vis filtre" / "Skjul filtre"       │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ [Filter Panel — conditional]            │
│                                         │
│ [Category Chips — horizontal scroll]    │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ [Active Category Section]           │ │
│ │ Category Name + Info                │ │
│ │                                     │ │
│ │ Menu Item 1                         │ │
│ │ Description                         │ │
│ │ Price                               │ │
│ │                                     │ │
│ │ Menu Item 2                         │ │
│ │ ...                                 │ │
│ └─────────────────────────────────────┘ │
│                                         │
└─────────────────────────────────────────┘
```

### Layout Dimensions

- **Frame:** 390×844px (iPhone 14/15 standard)
- **Status bar:** 54px height
- **Header bar:** 60px height (including 1px bottom border)
- **Scrollable content:** 730px height (`844 - 54 - 60`)
- **Horizontal padding:** 20px left/right (content area)
- **No tab bar** — this is a full-screen modal page

### Vertical Rhythm

```
16px — Top padding (content area)
↓
[Menu heading + last updated] (8px margin-bottom)
↓
[Filter toggle] (16px margin-bottom)
↓
[Filter panel if open] (16px margin-bottom)
↓
[Category chips] (20px margin-bottom)
↓
[Category section] (24px margin-bottom)
↓
[Menu items with 20px spacing between]
```

---

## Components Used

### 1. Header Bar

**Purpose:** Provides navigation context and back action.

**Structure:**
```jsx
<div style={{
  height: 60,
  display: "flex",
  alignItems: "center",
  padding: "0 20px",
  borderBottom: "1px solid #f2f2f2",
}}>
```

**Elements:**
- **Back button:** 36×36px transparent button, `←` arrow (18px font), `#0f0f0f` color
- **Restaurant name:** Centered text (16px, weight 600, `#0f0f0f`), offset by `-36px` margin-left to account for back button width
- **Right side:** Empty (no actions on this page)

**Interaction:**
- Back button calls `onBack()` prop function
- Returns user to Business Profile page

**Design Notes:**
- Border-bottom creates subtle separation from content
- Centered title provides clear context of which restaurant's menu is displayed
- Negative margin technique ensures true optical centering despite asymmetric left button

---

### 2. Menu Heading Section

**Purpose:** Page title with metadata and filter toggle.

**Structure:**
```jsx
<div style={{
  display: "flex",
  justifyContent: "space-between",
  alignItems: "flex-start",
  marginBottom: 8,
}}>
```

**Elements:**
- **"Menu" heading:** 18px, weight 680, `#0f0f0f`
- **Last updated timestamp:** 11px, `#888`, right-aligned
  - Text: "Sidst ajurført den [date]"
  - Example: "Sidst ajurført den 15. december 2025"
  - Falls back to placeholder if `restaurant.menuLastReviewed` is undefined

**Design Notes:**
- Two-column layout (heading left, timestamp right) maximizes use of horizontal space
- Timestamp provides transparency about menu currency — critical for users with dietary restrictions who need confidence the information is current
- Flex-start alignment keeps elements aligned at baseline even if text wraps

---

### 3. Filter Toggle Link

**Purpose:** Show/hide dietary filter panel.

**Structure:**
```jsx
<div
  onClick={() => setFilterOpen(!filterOpen)}
  style={{
    fontSize: 13,
    fontWeight: 500,
    color: ACCENT,
    cursor: "pointer",
    marginBottom: 16,
  }}
>
  {filterOpen ? "Skjul filtre" : "Vis filtre"}
</div>
```

**States:**
- **Closed state:** "Vis filtre" text
- **Open state:** "Skjul filtre" text
- Both states use orange (`ACCENT`) color and pointer cursor

**Design Notes:**
- Orange color signals interactivity (consistent with design system rule: orange = interactive)
- Text changes to describe current action (not current state) — "Vis" when hidden, "Skjul" when visible
- Positioned above filter panel so it remains accessible when panel expands

---

### 4. Filter Panel

**Purpose:** Three-section collapsible filtering system for dietary restrictions, preferences, and allergens.

**Visibility:** Conditional — only renders when `filterOpen === true`

**Structure:**
```jsx
{filterOpen && (
  <div style={{
    background: "#fafafa",
    borderRadius: 12,
    padding: 16,
    marginBottom: 16,
  }}>
```

**Visual Treatment:**
- Light grey background (`#fafafa`) creates visual separation from white page background
- 12px border radius softens edges
- 16px internal padding provides breathing room

#### Section 1: Kostrestriktioner (Dietary Restrictions)

**Content:**
- **Section label:** "Kostrestriktioner" (13px, weight 500, `#555`)
- **Explainer text:** "Vis kun retter, der overholder den valgte kostrestriktion." (12px, `#888`, 16px line-height)
- **Filter chips:** Horizontal wrap layout, 8px gap
  - Options: "Glutenfrit", "Laktosefrit"

**Behavior:**
- **Exclusive selection** (implied by explainer text "den valgte" — singular)
- Clicking one restriction deselects others (toggle on/off)
- Selected state: orange background, white text, orange border
- Unselected state: white background, `#555` text, `#e8e8e8` border

#### Section 2: Kostpræferencer (Dietary Preferences)

**Content:**
- **Section label:** "Kostpræferencer" (13px, weight 500, `#555`)
- **Explainer text:** "Vis kun retter, der overholder den valgte diæt." (12px, `#888`)
- **Filter chips:** Horizontal wrap layout, 8px gap
  - Options: "Pescetarianligt", "Vegansk", "Vegetarisk"

**Behavior:**
- Same selection pattern as restrictions
- Exclusive selection (one diet at a time)

#### Section 3: Allergener (Allergens)

**Content:**
- **Section label:** "Allergener" (13px, weight 500, `#555`)
- **Explainer text:** "Skjul retter, der indeholder det valgte allergen." (12px, `#888`)
- **Filter chips:** Horizontal wrap layout, 8px gap
  - Options: "Blødyr", "Fisk", "Jordnødder", "Korn med..."
  - Default state: "Blødyr", "Fisk", "Jordnødder" pre-selected

**Behavior:**
- **Multiple selection allowed** (explainer uses "det valgte" but allows multiple — filters are additive)
- Chips toggle independently
- Inverse logic: selected allergens **hide** items (vs restrictions/preferences which **show** items)
- Default selections demonstrate the feature and suggest personalization

**Design Notes:**
- Three sections with identical visual structure but different behavioral logic
- Explainer text clarifies the filtering mechanism (show vs hide, singular vs multiple)
- 16px spacing between sections creates clear grouping
- Chips use same visual language as category chips (below) for consistency
- Pre-selected allergens in default state suggest that users should customize this to their needs

**Chip Styling (all sections):**
```jsx
style={{
  padding: "7px 12px",
  borderRadius: 10,
  fontSize: 12.5,
  fontWeight: 540,
  background: selected ? ACCENT : "#fff",
  color: selected ? "#fff" : "#555",
  border: `1px solid ${selected ? ACCENT : "#e8e8e8"}`,
  cursor: "pointer",
}}
```

---

### 5. Category Navigation Chips

**Purpose:** Horizontal scrollable row for quick navigation between menu categories.

**Structure:**
```jsx
<div style={{
  display: "flex",
  gap: 8,
  overflowX: "auto",
  marginBottom: 20,
  paddingBottom: 4,
}}>
```

**Elements:**
- One chip per category in `restaurant.menuCategories` array
- Default categories: "Mød", "Drikke", "Burger", "Poké bowls", "Classic bowls", "Sand"
- Active category controlled by `activeCat` state

**Chip Styling:**
```jsx
<div
  onClick={() => setActiveCat(cat)}
  style={{
    padding: "7px 14px",
    borderRadius: 10,
    fontSize: 13,
    fontWeight: 580,
    background: activeCat === cat ? ACCENT : "#fff",
    color: activeCat === cat ? "#fff" : "#555",
    border: `1px solid ${activeCat === cat ? ACCENT : "#e8e8e8"}`,
    cursor: "pointer",
    whiteSpace: "nowrap",
  }}
>
```

**States:**
- **Active:** Orange background, white text, orange border
- **Inactive:** White background, grey text, grey border

**Interaction:**
- Clicking any chip:
  1. Updates `activeCat` state
  2. Triggers re-render of menu items section
  3. Only items matching `item.category === activeCat` are displayed

**Design Notes:**
- Horizontal scroll allows unlimited categories without wrapping or truncating
- `paddingBottom: 4px` prevents scrollbar from visually touching chips
- `whiteSpace: "nowrap"` ensures category names don't wrap within chips
- Active state uses orange (interactive signal) not green (match signal)
- 8px gap between chips creates comfortable tapping targets

---

### 6. Category Section

**Purpose:** Display header and items for currently active menu category.

**Structure:**
```jsx
<div style={{ marginBottom: 24 }}>
  <h3 style={{
    fontSize: 16,
    fontWeight: 630,
    color: "#0f0f0f",
    margin: "0 0 8px 0",
  }}>
    {activeCat}
  </h3>
```

**Elements:**
- **Category heading:** Repeats active category name (16px, weight 630, `#0f0f0f`)
- **Optional info block:** Conditional rendering for category-specific notices
- **Menu items list:** Filtered array of items matching active category

#### Category-Specific Info Block (Burger Example)

**Conditional Logic:**
```jsx
{activeCat === "Burger" && (
  <div style={{
    fontSize: 12,
    color: "#888",
    marginBottom: 16,
    display: "flex",
    alignItems: "center",
    gap: 4,
  }}>
    Vælg mellem fuldkorn eller glutenfri bolle (+ 10 kr.)
    <span style={{
      width: 14,
      height: 14,
      borderRadius: "50%",
      border: "1px solid #888",
      display: "inline-flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: 10,
    }}>
      i
    </span>
  </div>
)}
```

**Design Notes:**
- Only renders for "Burger" category (example of extensible pattern)
- Small "i" icon (14px circle, `#888` border, 10px text) signals supplementary information
- Text explains option pricing and customization availability
- 4px gap between text and icon creates natural grouping
- Future implementation: tapping icon could open tooltip or modal with more detail

---

### 7. Menu Item Cards

**Purpose:** Display individual menu items with name, description, and price.

**Structure:**
```jsx
<div
  onClick={() => onItemClick && onItemClick(item)}
  style={{
    marginBottom: 20,
    cursor: "pointer",
  }}
>
```

**Elements:**
- **Item name:** 15px, weight 590, `#0f0f0f`, 4px margin-bottom
- **Description:** 13px, weight 400, `#555`, 18px line-height, 6px margin-bottom
- **Price:** 13.5px, weight 540, orange (`ACCENT`)

**Layout:**
```
┌────────────────────────────────┐
│ Green Power Bowl               │ ← name
│ Spinat, avocado, quinoa,       │ ← description
│ edamame, tahini                │    (wraps naturally)
│ 139 kr.                        │ ← price
└────────────────────────────────┘
   ↓ 20px margin-bottom
```

**Interaction:**
- Entire card is tappable
- `onClick` calls `onItemClick(item)` prop function
- Intended to open item detail overlay (not yet implemented)
- Cursor changes to pointer on hover (desktop)

**Filtering Logic:**
```jsx
restaurant.menuItems
  .filter(item => item.category === activeCat)
  .map((item, i) => ...)
```
- Only items matching `activeCat` render
- Filter state (restrictions/preferences/allergens) **not yet connected** to rendering — filtering logic is prepared but not implemented

**Design Notes:**
- 20px spacing between items creates clear separation and comfortable tapping
- Description uses full-width, allowing natural wrap for longer text
- Price uses orange to signal commercial information and create visual hierarchy
- No images or icons — text-first design prioritizes clarity and scannability
- Hover state not defined (future enhancement: subtle background color change)

**Accessibility Notes:**
- Item name uses sufficient color contrast (WCAG AA compliant: `#0f0f0f` on `#fff`)
- Description text contrast is slightly lower but within WCAG AA range (`#555` on `#fff`)
- Future implementation should add ARIA labels for screen readers (e.g., "Menu item: [name], Price: [price]")

---

## Design Tokens

### Colors Used

| Token | Value | Usage in This Page |
|-------|-------|-------------------|
| `ACCENT` | `#e8751a` | Filter chips (selected), category chips (active), filter toggle text, menu item prices |
| Primary text | `#0f0f0f` | Restaurant name, "Menu" heading, category names, item names |
| Secondary text | `#555` | Filter labels, item descriptions, unselected chip text |
| Tertiary text | `#888` | Last updated timestamp, explainer text, info text, "i" icon border |
| Background (surface) | `#fafafa` | Filter panel background |
| Background (cards) | `#fff` | Filter chips (unselected), category chips (inactive), page background |
| Borders (default) | `#e8e8e8` | Unselected chip borders |
| Borders (subtle) | `#f2f2f2` | Header bottom border |

**Note:** Green is not used on this page (no match indicators), and red is not used (no closed/warning states).

---

### Typography Scale

| Element | Size | Weight | Color | Line Height |
|---------|------|--------|-------|-------------|
| Restaurant name (header) | 16px | 600 | `#0f0f0f` | — |
| "Menu" heading | 18px | 680 | `#0f0f0f` | — |
| Category heading | 16px | 630 | `#0f0f0f` | — |
| Filter section labels | 13px | 500 | `#555` | — |
| Filter toggle | 13px | 500 | `ACCENT` | — |
| Category chip text | 13px | 580 | varies | — |
| Filter chip text | 12.5px | 540 | varies | — |
| Explainer text | 12px | 400 | `#888` | 16px |
| Info text (category notice) | 12px | 400 | `#888` | — |
| Last updated timestamp | 11px | 400 | `#888` | — |
| "i" icon | 10px | 400 | `#888` | — |
| Item name | 15px | 590 | `#0f0f0f` | — |
| Item description | 13px | 400 | `#555` | 18px |
| Item price | 13.5px | 540 | `ACCENT` | — |

**Flutter Weight Mapping:**
- 400: `FontWeight.w400` (regular)
- 500: `FontWeight.w500` (medium)
- 540: `FontWeight.w500` (medium) ← round down
- 580: `FontWeight.w600` (semibold) ← round up
- 590: `FontWeight.w600` (semibold) ← round up
- 600: `FontWeight.w600` (semibold)
- 630: `FontWeight.w700` (bold) ← round up
- 680: `FontWeight.w700` (bold)

---

### Spacing System

**Padding:**
- Page horizontal: 20px
- Header horizontal: 20px
- Filter panel: 16px (all sides)
- Chip internal: 7px vertical, 12-14px horizontal
- Content area top: 16px

**Margins:**
- Menu heading bottom: 8px
- Filter toggle bottom: 16px
- Filter panel bottom: 16px
- Category chips bottom: 20px
- Category section bottom: 24px
- Menu item cards bottom: 20px
- Filter section internal: 16px (between sections)
- Section label bottom: 6px (restrictions/preferences)
- Explainer text bottom: 8px
- Category heading bottom: 8px
- Info block bottom: 16px
- Item name bottom: 4px
- Item description bottom: 6px

**Gaps:**
- Category chips: 8px
- Filter chips: 8px
- Info text to icon: 4px

---

### Border Radii

- Filter panel: 12px
- Chips (filter + category): 10px
- "i" icon circle: 50% (perfect circle)

---

## State & Data

### Component State

```jsx
const [activeCat, setActiveCat] = useState("Burger");
const [filterOpen, setFilterOpen] = useState(false);
const [selectedRestrictions, setSelectedRestrictions] = useState(new Set());
const [selectedPreferences, setSelectedPreferences] = useState(new Set());
const [selectedAllergens, setSelectedAllergens] = useState(
  new Set(["Blødyr", "Fisk", "Jordnødder"])
);
```

#### `activeCat` (string)

**Purpose:** Tracks currently displayed menu category.

**Initial Value:** `"Burger"` (hardcoded default — should ideally default to first category in `restaurant.menuCategories`)

**Updates:**
- User clicks a category chip
- New category name is set
- Menu items re-filter to show only items in active category

**Used By:**
- Category chip active state styling
- Category section heading text
- Menu items filter logic

#### `filterOpen` (boolean)

**Purpose:** Controls visibility of dietary filter panel.

**Initial Value:** `false` (panel hidden by default)

**Updates:**
- User clicks "Vis filtre" / "Skjul filtre" toggle
- Boolean flips between true/false

**Used By:**
- Filter panel conditional rendering
- Filter toggle text (conditional: "Vis" vs "Skjul")

#### `selectedRestrictions` (Set<string>)

**Purpose:** Tracks active dietary restrictions (Glutenfrit, Laktosefrit).

**Initial Value:** Empty Set

**Data Structure:**
```javascript
// Example after selecting "Glutenfrit":
Set(1) { "Glutenfrit" }
```

**Updates:**
- User clicks a restriction chip
- `toggleFilter(selectedRestrictions, setSelectedRestrictions, chipValue)` is called
- If value exists in Set: remove it (deselect)
- If value doesn't exist: add it (select)

**Intended Behavior (not enforced):**
- Should be **exclusive** (only one restriction at a time) based on explainer text
- Current implementation allows multiple selections via toggle
- Future implementation should enforce single-selection logic

#### `selectedPreferences` (Set<string>)

**Purpose:** Tracks active dietary preferences (Pescetarianligt, Vegansk, Vegetarisk).

**Initial Value:** Empty Set

**Updates:** Same toggle logic as restrictions

**Intended Behavior:** Same exclusive selection pattern as restrictions

#### `selectedAllergens` (Set<string>)

**Purpose:** Tracks allergens to **hide** from menu display.

**Initial Value:** Pre-populated Set with three defaults:
```javascript
Set(3) { "Blødyr", "Fisk", "Jordnødder" }
```

**Updates:** Toggle logic (add/remove from Set)

**Behavioral Difference:**
- Restrictions/preferences **show** matching items
- Allergens **hide** items containing them
- Inverse filtering logic

**Pre-Selection Rationale:**
- Demonstrates the feature's purpose on first view
- Encourages personalization (user sees items are already hidden, prompts them to adjust)
- Provides sensible defaults for common allergens

---

### Props

```jsx
function MenuFullPage({ restaurant, onBack, onItemClick })
```

#### `restaurant` (object)

**Type:** Restaurant data object (from `_shared.jsx`)

**Required Fields:**
- `name` (string) — displayed in header
- `menuCategories` (array of strings) — category chip list
- `menuItems` (array of objects) — item data
  - Each object requires: `category`, `name`, `description`, `price`
- `menuLastReviewed` (string) — optional timestamp

**Usage:**
- Header: `restaurant.name`
- Categories: `restaurant.menuCategories`
- Items: `restaurant.menuItems.filter(...)`
- Timestamp: `restaurant.menuLastReviewed || "15. december 2025"`

#### `onBack` (function)

**Type:** `() => void`

**Purpose:** Navigation callback for back button.

**Expected Behavior:**
- Called when user taps back arrow
- Should return user to Business Profile page
- No parameters passed

**Implementation Pattern:**
```jsx
// In parent component:
const [view, setView] = useState("profile");

<MenuFullPage
  onBack={() => setView("profile")}
  ...
/>
```

#### `onItemClick` (function)

**Type:** `(item: MenuItem) => void`

**Purpose:** Callback for menu item interaction.

**Expected Behavior:**
- Called when user taps any menu item card
- Receives full item object as parameter
- Should open item detail overlay (not yet implemented)

**Current Implementation:**
```jsx
onClick={() => onItemClick && onItemClick(item)}
```
- Safe call pattern: checks if prop exists before calling
- Passes entire item object (name, description, price, category)

**Future Implementation Notes:**
- Item detail overlay should show:
  - Full item name
  - Complete description (not clamped)
  - Ingredients list (if available in data)
  - Allergen information
  - Nutritional data (if available)
  - Customization options (if available)
- Overlay should support drag-to-dismiss (consistent with design system bottom sheets)

---

### Filter Data

```javascript
const restrictions = ["Glutenfrit", "Laktosefrit"];
const preferences = ["Pescetarianligt", "Vegansk", "Vegetarisk"];
const allergens = ["Blødyr", "Fisk", "Jordnødder", "Korn med..."];
```

**Hardcoded Arrays:** These are page-local constants, not imported from `_shared.jsx`.

**Rationale for Local Definition:**
- Menu-level filtering is distinct from restaurant-level filtering
- Filter labels are simplified for clarity (vs detailed hierarchy in filter sheet)
- Future implementation may extend these from backend data

**String Matching Consideration:**
- Filter strings should match backend data model keys
- E.g., "Glutenfrit" here should match `item.dietary_info.glutenfrit` (or similar)
- Current implementation does not connect filter state to rendering logic

---

### Data Flow

```
User Action → State Update → UI Re-render → Display Update

1. Click Category Chip
   → setActiveCat("Bowls")
   → activeCat state updates
   → menu items filter by category
   → only "Bowls" items render

2. Click "Vis filtre"
   → setFilterOpen(true)
   → filterOpen state updates
   → filter panel renders

3. Click "Glutenfrit" chip
   → toggleFilter(selectedRestrictions, setSelectedRestrictions, "Glutenfrit")
   → Set updates (add or remove "Glutenfrit")
   → chip styling updates (orange or white)
   → (menu items do NOT re-filter — logic not implemented)

4. Click Menu Item
   → onItemClick(item)
   → parent handles navigation
   → (overlay not implemented)
```

**Critical Gap:** Filter state changes do not trigger menu item filtering. The `selectedRestrictions`, `selectedPreferences`, and `selectedAllergens` Sets control chip styling only — they do not affect which items render. Implementing this requires:

```javascript
// Proposed filtering logic:
restaurant.menuItems
  .filter(item => item.category === activeCat)
  .filter(item => {
    // Restriction filter (show only matching)
    if (selectedRestrictions.size > 0) {
      const hasRestriction = Array.from(selectedRestrictions).some(r =>
        item.dietary_info?.restrictions?.includes(r)
      );
      if (!hasRestriction) return false;
    }

    // Preference filter (show only matching)
    if (selectedPreferences.size > 0) {
      const hasPref = Array.from(selectedPreferences).some(p =>
        item.dietary_info?.preferences?.includes(p)
      );
      if (!hasPref) return false;
    }

    // Allergen filter (hide items containing)
    if (selectedAllergens.size > 0) {
      const hasAllergen = Array.from(selectedAllergens).some(a =>
        item.allergens?.includes(a)
      );
      if (hasAllergen) return false;
    }

    return true;
  })
  .map((item, i) => ...)
```

This requires updating the `MenuItem` data model to include `dietary_info` and `allergens` fields.

---

## User Interactions

### 1. Back Navigation

**Trigger:** User taps back arrow button (top-left)

**Sequence:**
1. Tap detected on back button
2. `onBack()` prop function called
3. Parent component handles navigation
4. Page slides out (animation handled by parent)
5. User returns to Business Profile page

**Visual Feedback:**
- No hover state on JSX (desktop cursor changes to pointer)
- Future: Add tap highlight (brief opacity change on mobile)

---

### 2. Filter Panel Toggle

**Trigger:** User taps "Vis filtre" or "Skjul filtre" text

**Opening Sequence:**
1. User taps "Vis filtre"
2. `setFilterOpen(true)` called
3. Filter panel renders with slide-down animation (CSS transition)
4. Text changes to "Skjul filtre"
5. Panel displays three filter sections

**Closing Sequence:**
1. User taps "Skjul filtre"
2. `setFilterOpen(false)` called
3. Filter panel slides up and unmounts
4. Text changes back to "Vis filtre"
5. Selected filter state persists (chips remain selected)

**Animation Notes:**
- No animation currently defined in JSX
- Recommended: `max-height` transition from `0` to `auto` (requires known max height)
- Alternative: `scale-y` transform from 0 to 1 with `transform-origin: top`
- Duration: 250ms, easing: `ease-out`

**State Persistence:**
- Filter selections (restrictions/preferences/allergens) remain when panel closes
- Only visibility toggles — selected chips stay selected

---

### 3. Filter Chip Selection

**Trigger:** User taps a chip in any of the three filter sections

**Sequence:**
1. User taps chip (e.g., "Glutenfrit")
2. `toggleFilter(selectedRestrictions, setSelectedRestrictions, "Glutenfrit")` called
3. Function checks if "Glutenfrit" exists in Set
4. If exists: removes from Set (deselect)
5. If not exists: adds to Set (select)
6. State updates, component re-renders
7. Chip style changes (orange background + white text ↔ white background + grey text)
8. (Menu items should filter but logic not implemented)

**Visual States:**
- **Unselected:** White background, `#555` text, `#e8e8e8` border
- **Selected:** Orange background, white text, orange border
- **Hover (desktop):** Cursor changes to pointer (no other visual change)

**Selection Patterns:**

**Restrictions & Preferences (intended behavior):**
- Should be **exclusive** (only one selectable at a time)
- Selecting one should deselect others
- Current implementation allows multiple — requires logic update

**Allergens:**
- **Multiple selection allowed** and intended
- Each allergen toggles independently
- Additive filtering (all selected allergens are excluded)

**Implementation Note:**
```javascript
// Current toggle function (allows multiple):
const toggleFilter = (set, setter, value) => {
  const newSet = new Set(set);
  newSet.has(value) ? newSet.delete(value) : newSet.add(value);
  setter(newSet);
};

// Needed for restrictions/preferences (exclusive):
const toggleExclusiveFilter = (set, setter, value) => {
  const newSet = set.has(value) ? new Set() : new Set([value]);
  setter(newSet);
};
```

---

### 4. Category Navigation

**Trigger:** User taps a category chip

**Sequence:**
1. User taps chip (e.g., "Salater")
2. `setActiveCat("Salater")` called
3. State updates, component re-renders
4. Chip styling updates (orange for active, white for others)
5. Category section heading changes to "Salater"
6. Menu items re-filter to show only items where `item.category === "Salater"`
7. Previous category's items unmount, new category's items render

**Scroll Behavior:**
- Category chip row scrolls horizontally (native overflow scroll)
- Tapping chip does NOT auto-scroll it into view (could be enhancement)
- Menu items section scrolls to top when category changes (parent scroll container)

**Animation Notes:**
- No transition animation between category switches
- Items simply appear/disappear (instant swap)
- Future enhancement: Fade transition or slide animation

**Edge Cases:**
- **Empty category:** If no items match `activeCat`, section renders with heading but no items
- **Invalid category:** If user state somehow sets invalid category, no items render

---

### 5. Menu Item Selection

**Trigger:** User taps anywhere on a menu item card

**Sequence:**
1. User taps item card
2. `onClick` handler fires
3. Checks if `onItemClick` prop exists (`onItemClick && onItemClick(item)`)
4. If exists: calls `onItemClick(item)` with full item object
5. Parent component receives callback
6. (Intended: Open item detail overlay)
7. (Not implemented: Overlay mount and animation)

**Expected Overlay Behavior (not implemented):**
```
1. Bottom sheet slides up from bottom
2. Backdrop appears (semi-transparent black)
3. Sheet displays:
   - Item name (larger text)
   - Full description (no line clamp)
   - Ingredients list (if available)
   - Allergen warnings (if applicable)
   - Nutritional information (if available)
   - Price (prominent)
4. User can scroll within sheet if content overflows
5. User can drag down to dismiss
6. User can tap backdrop to dismiss
```

**Visual Feedback:**
- Cursor changes to pointer (desktop)
- Future: Add tap highlight (brief background color change on mobile)

**Accessibility Notes:**
- Entire card is tappable (generous hit area)
- Future: Add ARIA role="button" and keyboard navigation support

---

### 6. Horizontal Scroll (Category Chips)

**Behavior:**
- Native browser/OS scroll behavior
- Touch-based swipe on mobile
- Trackpad/mouse wheel on desktop
- No scroll indicators in JSX (browser default)

**Scroll Physics:**
- Momentum scroll on iOS
- Standard scroll on Android/desktop
- No snap-to-chip behavior (continuous scroll)

**Overflow Handling:**
- `overflowX: "auto"` shows scrollbar only when content exceeds width
- `paddingBottom: 4px` prevents scrollbar from touching chips
- Last chip has natural padding (no special edge treatment)

**Potential Enhancements:**
- Add scroll shadows (fade at edges when scrollable)
- Add snap points for chip alignment
- Add scroll indicators (e.g., dots below row)

---

## Design Rationale

### Why Full-Screen Modal Design?

**Decision:** The menu page is a full-screen modal without tab bar or other navigation chrome.

**Rationale:**
1. **Focus:** Users viewing full menu are in deep-dive mode — they need to scan many items and apply filters without distraction
2. **Screen real estate:** Removing tab bar adds 80px of vertical space, allowing ~4 additional menu items visible without scrolling
3. **Clear entry/exit:** Single back button makes exit path obvious — no confusion about navigation hierarchy
4. **Filter visibility:** Full-width filter panel needs maximum horizontal space for three sections

**Alternative Considered:**
- Keep tab bar for persistent navigation
- **Rejected because:** Tab bar would compete with filter panel visually, and users in focused menu browsing don't need to jump to other sections

---

### Why Collapsible Filter Panel?

**Decision:** Filters hidden by default behind "Vis filtre" toggle.

**Rationale:**
1. **Progressive disclosure:** Most users browsing a full menu don't need dietary filters — hiding them by default keeps interface clean
2. **Vertical space:** Filter panel consumes ~180px when open — this would push menu items below fold
3. **Optional feature:** Filters are powerful but not required — clear labeling makes feature discoverable without forcing it
4. **State persistence:** Users can set filters, close panel, and continue browsing with filters applied

**Alternative Considered:**
- Always-visible filter panel
- **Rejected because:** Too much UI before content; users without dietary restrictions see unnecessary complexity

---

### Why Three Separate Filter Sections?

**Decision:** Split filters into Kostrestriktioner, Kostpræferencer, and Allergener sections with distinct selection behaviors.

**Rationale:**
1. **Conceptual clarity:** Restrictions (medical), preferences (choice), and allergens (safety) are different mental models
2. **Selection logic:** Restrictions/preferences are exclusive (one diet at a time), allergens are additive (multiple possible)
3. **Explainer text:** Different filtering mechanisms ("show only" vs "hide") require distinct explanations
4. **User research:** Interview findings showed users think about dietary needs in these three categories

**Alternative Considered:**
- Single unified filter list
- **Rejected because:** Mixing exclusive and multiple-selection patterns without clear grouping would confuse users

---

### Why Category Chips Instead of Dropdown?

**Decision:** Horizontal scrollable row of chips for category navigation.

**Rationale:**
1. **Visibility:** All categories visible at once (with scroll) — users can see options without opening a menu
2. **Tap targets:** Large chips (7px vertical padding) are easier to tap than dropdown items
3. **No modal:** Dropdown would require opening/closing, adding interaction friction
4. **Visual continuity:** Chips match filter chips and category chips in Business Profile

**Alternative Considered:**
- Dropdown select menu
- **Rejected because:** Requires two taps (open menu, select item) vs one tap on chip; hides available options

---

### Why Repeat Category Name as Heading?

**Decision:** Category name appears both in chips (interactive) and as section heading (informational).

**Rationale:**
1. **Scroll context:** When user scrolls down in long category (e.g., 20 burger items), chip row scrolls off-screen — heading maintains context
2. **Visual hierarchy:** Heading signals start of new content section (consistent with profile page section headings)
3. **Category-specific info:** Heading provides anchor point for optional info blocks (e.g., burger bun options)
4. **Redundancy acceptable:** Desktop users who can see both simultaneously are not confused by repetition

**Alternative Considered:**
- Sticky category chip row (always visible at top)
- **Rejected because:** Would obscure filter toggle and waste vertical space; plus sticky positioning has mobile browser quirks

---

### Why Info Block for Burger Category?

**Decision:** Conditional rendering of notice text with "i" icon for specific categories (currently only Burger).

**Rationale:**
1. **Contextual information:** Some menu categories have universal modifiers (e.g., bun choices) that apply to all items
2. **Reduce repetition:** Rather than noting bun options in every burger description, state once at top
3. **Extensibility:** Pattern allows future categories to include their own notices (e.g., "Drikke: All coffees available iced")
4. **Visual hierarchy:** Icon + grey text color signals supplementary info without competing with menu items

**Alternative Considered:**
- Add info to every item description
- **Rejected because:** Excessive repetition; increases cognitive load; harder to update if info changes

---

### Why Orange for Prices?

**Decision:** Menu item prices use orange (`ACCENT`) color.

**Rationale:**
1. **Consistency:** Prices throughout JourneyMate use orange (card preview, profile menu section)
2. **Hierarchy:** Orange color makes prices scannable without reading full descriptions
3. **Commercial signal:** Orange associates price with brand (JourneyMate orange = trusted pricing info)
4. **Not green:** Green is reserved for "matches your needs" — price is not a match indicator

**Alternative Considered:**
- Black or grey prices
- **Rejected because:** Lower visual hierarchy makes price scanning harder; loses brand association

---

### Why Pre-Select Allergens?

**Decision:** `selectedAllergens` Set initializes with three items: "Blødyr", "Fisk", "Jordnødder".

**Rationale:**
1. **Feature demonstration:** First-time users immediately see that filters are active and items are hidden
2. **Encourages customization:** Seeing pre-selected items prompts users to adjust to their actual allergies
3. **Sensible defaults:** Shellfish, fish, and peanuts are common severe allergens — reasonable starting point
4. **Explainer clarity:** Seeing orange chips makes explainer text ("Skjul retter...") easier to understand

**Alternative Considered:**
- All allergens unselected by default
- **Rejected because:** Users might not realize allergen filtering exists; empty state provides no visual example

---

### Why Not Implement Filter Logic?

**Decision:** Filter state (restrictions, preferences, allergens) updates UI but does not filter menu items.

**Rationale:**
1. **JSX design phase:** Current implementation is visual design reference, not functional app
2. **Data model incomplete:** Menu items in `_shared.jsx` lack dietary metadata (restrictions, allergens, etc.)
3. **Backend dependency:** Real filtering requires structured data from BuildShip API
4. **Clear TODO boundary:** UI design complete; filtering logic is Flutter implementation task

**Implementation Path:**
1. Extend `MenuItem` model with dietary fields
2. Add filtering logic to `.filter()` chain
3. Connect filter state to item rendering
4. Add "No items found" empty state
5. Consider adding filter result count ("Viser 8 retter")

---

### Why No Images for Menu Items?

**Decision:** Menu items display text only (name, description, price) without thumbnails or photos.

**Rationale:**
1. **Content priority:** Users with dietary restrictions prioritize ingredient information over visuals
2. **Vertical density:** Images would double card height, reducing scannable items per screen
3. **Data availability:** Not all restaurants provide item photos; inconsistent imagery creates uneven experience
4. **Load performance:** Text-only rendering is instant; images require loading states and bandwidth

**Alternative Considered:**
- Small thumbnails (60×60px) left-aligned
- **Rejected because:** Reduces text width, slows scanning, creates layout complexity with varying text lengths

---

### Why Simple Last Updated Timestamp?

**Decision:** Small grey text in top-right of page: "Sidst ajurført den [date]".

**Rationale:**
1. **Trust signal:** Users with allergies need confidence that menu is current — timestamp provides verification
2. **Restaurant accountability:** Knowing last review date helps users assess reliability
3. **Subtle placement:** Top-right position provides context without distracting from content
4. **No icon needed:** Text is self-explanatory; adding calendar icon would clutter

**Alternative Considered:**
- Relative time ("Updated 3 days ago")
- **Rejected because:** Requires client-side date calculation; absolute date is more trustworthy

---

### Why No Search or Keyword Filter?

**Decision:** No search bar or keyword input for finding specific menu items.

**Rationale:**
1. **Use case mismatch:** Users viewing full menu are browsing, not searching for known items
2. **Category navigation sufficient:** Most menus have 3-8 categories with 5-15 items each — small enough to browse
3. **Mobile keyboard:** Search input requires keyboard which obscures half the screen
4. **Dietary filters more important:** Space prioritized for restriction/allergen filtering (safety-critical)

**Future Consideration:**
- Add search for restaurants with 100+ menu items (e.g., comprehensive wine lists)
- Trigger threshold: If `menuItems.length > 50`, show search input

---

### Why No Item Favoriting or List-Building?

**Decision:** No UI for saving favorite items or building meal lists.

**Rationale:**
1. **Out of scope for V1:** Core user need is "find safe options" not "build meal plan"
2. **Feature complexity:** Favorites require user accounts, persistent storage, sync across devices
3. **Screen space:** Adding favorite icons to every item would clutter layout
4. **Interaction cost:** Requires careful UX to avoid accidental taps while scrolling

**Future Roadmap:**
- V2: Add "Save to list" feature for meal planning
- Requires backend user profile system

---

## Implementation Notes for Flutter Migration

### Three-Source Method Checklist

Before implementing, review:

1. **FlutterFlow Source (Ground Truth):**
   - Location: `_flutterflow_export/lib/pages/menu_full_page/`
   - Check for:
     - Translation keys (`getTranslations()` calls)
     - Analytics events (`trackAnalyticsEvent()` calls)
     - State management patterns (`FFAppState` usage)
     - API calls for menu data
     - Navigation cleanup on back
     - Custom actions or functions

2. **Page Audit Specifications:**
   - Location: `_reference/page-audit.md`
   - Verify audit matches FlutterFlow source
   - Note any discrepancies

3. **Screenshots:**
   - Location: `FF-pages-images/menu_full_page/`
   - Compare FlutterFlow design to JSX v2 design
   - Note layout differences

---

### Data Model Extensions Needed

#### MenuItem Model (add to `lib/models/menu_item.dart`)

```dart
class MenuItem {
  final String name;
  final String description;
  final String price;
  final String category;

  // NEW FIELDS REQUIRED FOR FILTERING:
  final List<String>? dietaryRestrictions; // ["Glutenfrit", "Laktosefrit"]
  final List<String>? dietaryPreferences;  // ["Vegansk", "Vegetarisk"]
  final List<String>? allergens;           // ["Blødyr", "Fisk", "Jordnødder"]
  final String? ingredients;               // Full ingredient list
  final Map<String, dynamic>? nutritionInfo; // Calories, protein, etc.

  MenuItem({
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.dietaryRestrictions,
    this.dietaryPreferences,
    this.allergens,
    this.ingredients,
    this.nutritionInfo,
  });
}
```

---

### Component Mapping

| JSX Element | Flutter Widget |
|-------------|----------------|
| Header bar with back button | `AppBar` with custom styling |
| Horizontal scrollable chips | `SingleChildScrollView` + `Row` of `ChoiceChip` widgets |
| Filter panel expand/collapse | `AnimatedContainer` with height transition |
| Filter chip toggle | `FilterChip` with custom styling or `ChoiceChip` |
| Menu items list | `ListView.builder` with filtered data |
| Collapsible sections | `ExpansionTile` or custom `AnimatedContainer` |

---

### State Management Strategy

**Option 1: Local State (StatefulWidget)**
```dart
class MenuFullPageState extends State<MenuFullPage> {
  String _activeCategory = "Burger";
  bool _filterOpen = false;
  Set<String> _selectedRestrictions = {};
  Set<String> _selectedPreferences = {};
  Set<String> _selectedAllergens = {"Blødyr", "Fisk", "Jordnødder"};

  // ... methods
}
```

**Option 2: Provider (if used globally)**
```dart
class MenuFilterProvider extends ChangeNotifier {
  // Same state as above
  // Expose getters and update methods
}
```

**Recommendation:** Use local state initially (StatefulWidget). Filters are page-specific and don't need global access. Promote to Provider only if filtering logic needs to persist across navigation or be shared with other pages.

---

### Filtering Logic Implementation

```dart
// In build method or extracted to method:
List<MenuItem> _getFilteredItems() {
  List<MenuItem> items = widget.restaurant.menuItems
      .where((item) => item.category == _activeCategory)
      .toList();

  // Apply restriction filter
  if (_selectedRestrictions.isNotEmpty) {
    items = items.where((item) {
      return _selectedRestrictions.any((restriction) =>
          item.dietaryRestrictions?.contains(restriction) ?? false);
    }).toList();
  }

  // Apply preference filter
  if (_selectedPreferences.isNotEmpty) {
    items = items.where((item) {
      return _selectedPreferences.any((pref) =>
          item.dietaryPreferences?.contains(pref) ?? false);
    }).toList();
  }

  // Apply allergen filter (inverse — hide items)
  if (_selectedAllergens.isNotEmpty) {
    items = items.where((item) {
      return !_selectedAllergens.any((allergen) =>
          item.allergens?.contains(allergen) ?? false);
    }).toList();
  }

  return items;
}
```

---

### Empty State Handling

Add conditional rendering when no items match filters:

```dart
if (_getFilteredItems().isEmpty)
  Padding(
    padding: EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        Icon(Icons.restaurant_menu, size: 48, color: Colors.grey[400]),
        SizedBox(height: 16),
        Text(
          'Ingen retter matcher dine filtre',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedRestrictions.clear();
              _selectedPreferences.clear();
              _selectedAllergens.clear();
            });
          },
          child: Text('Nulstil filtre'),
        ),
      ],
    ),
  )
```

---

### Exclusive Selection Logic (Restrictions/Preferences)

```dart
void _toggleExclusiveFilter(Set<String> filterSet, String value) {
  setState(() {
    if (filterSet.contains(value)) {
      filterSet.clear(); // Deselect current
    } else {
      filterSet.clear(); // Clear all
      filterSet.add(value); // Select new one
    }
  });
}
```

---

### Category Default

Current JSX hardcodes `"Burger"` as default. Improve by using first category:

```dart
String _activeCategory = "";

@override
void initState() {
  super.initState();
  if (widget.restaurant.menuCategories.isNotEmpty) {
    _activeCategory = widget.restaurant.menuCategories.first;
  }
}
```

---

### Translation Integration

All static text must use translation system:

```dart
// Filter section labels:
getTranslations(context)['menu_full_restrictions_label']
getTranslations(context)['menu_full_preferences_label']
getTranslations(context)['menu_full_allergens_label']

// Explainer text:
getTranslations(context)['menu_full_restrictions_explainer']
getTranslations(context)['menu_full_allergens_explainer']

// Filter toggle:
filterOpen
  ? getTranslations(context)['menu_full_hide_filters']
  : getTranslations(context)['menu_full_show_filters']

// Empty state:
getTranslations(context)['menu_full_no_items_found']
```

---

### Analytics Events

Track these interactions:

```dart
// Page view:
trackAnalyticsEvent('menu_full_page_viewed', {
  'restaurant_id': widget.restaurant.id,
  'restaurant_name': widget.restaurant.name,
});

// Category switch:
trackAnalyticsEvent('menu_category_changed', {
  'restaurant_id': widget.restaurant.id,
  'category': categoryName,
});

// Filter interaction:
trackAnalyticsEvent('menu_filter_applied', {
  'restaurant_id': widget.restaurant.id,
  'filter_type': 'restriction', // or 'preference', 'allergen'
  'filter_value': filterValue,
});

// Item click:
trackAnalyticsEvent('menu_item_clicked', {
  'restaurant_id': widget.restaurant.id,
  'item_name': item.name,
  'item_category': item.category,
  'item_price': item.price,
});
```

---

### Navigation Cleanup

On back navigation, ensure no state leaks:

```dart
// In back button onPressed:
Navigator.of(context).pop();
// No need to clear filter state — page disposes naturally
```

If implementing item detail overlay as bottom sheet:

```dart
void _showItemDetail(MenuItem item) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ItemDetailSheet(item: item),
  );
}
```

---

### Accessibility Improvements

```dart
// Category chips:
ChoiceChip(
  label: Text(category),
  selected: _activeCategory == category,
  onSelected: (selected) {
    setState(() => _activeCategory = category);
    // Announce category change for screen readers:
    SemanticsService.announce(
      'Viser kategori: $category',
      TextDirection.ltr,
    );
  },
)

// Filter chips:
Semantics(
  label: 'Filter: $filterValue',
  selected: isSelected,
  child: FilterChip(...),
)

// Menu items:
Semantics(
  label: '${item.name}, ${item.price}',
  button: true,
  child: GestureDetector(...),
)
```

---

### Performance Considerations

1. **Memoize filtered items:** Use `useMemo` (if using hooks) or cache filtered list to avoid recomputing on every rebuild
2. **Lazy load images (future):** If adding item photos, use `cached_network_image` with placeholders
3. **Virtualized scrolling:** `ListView.builder` already handles this — only visible items render
4. **Avoid rebuilding entire list:** Use `const` constructors where possible

---

## Future Enhancements (Post-V1)

### Item Detail Overlay

**Scope:** Full-screen or 90% height bottom sheet showing:
- Large item name
- Full description (multi-paragraph if needed)
- Complete ingredients list
- Allergen warnings (highlighted in red if user has active allergen filters)
- Nutritional information table (calories, protein, carbs, fat)
- Customization options (e.g., "Add avocado +15 kr.")
- "Add to favorites" button (requires user account)

**Design Considerations:**
- Use same bottom sheet pattern as filter sheet (drag handle, backdrop dismiss)
- Scroll content if exceeds height
- Highlight allergens in description text (e.g., bold + red color for "indeholder jordnødder")
- Add "Close" X button in top-right corner

---

### Filter Result Count

**Scope:** Show count of visible items after filtering.

**Location:** Below category chips, above section heading.

**Example:** "Viser 12 retter" or "Viser 3 af 8 retter"

**Design:**
```jsx
<div style={{
  fontSize: 12,
  color: "#888",
  marginBottom: 8,
}}>
  Viser {filteredItems.length} {filteredItems.length === 1 ? 'ret' : 'retter'}
</div>
```

**Rationale:** Helps users understand filter effectiveness ("Only 3 items are safe for me" vs "No filters active, showing all 20 items").

---

### Search Input

**Trigger:** Show search bar if `menuItems.length > 50`

**Location:** Below filter toggle, above category chips.

**Behavior:**
- Text input with search icon
- Filters items by name or description (case-insensitive)
- Works in conjunction with dietary filters (both apply)
- Shows result count ("Viser 4 retter matchende 'salat'")

**Design:**
```jsx
<input
  type="text"
  placeholder="Søg i menuen..."
  style={{
    width: "100%",
    padding: "10px 14px",
    borderRadius: 8,
    border: "1px solid #e8e8e8",
    fontSize: 14,
  }}
/>
```

---

### Category Scroll Shadows

**Scope:** Visual fade indicators at edges of category chip row when scrollable.

**Implementation:**
- Gradient overlays (white to transparent) positioned absolutely at left/right edges
- Only show when content overflows (detect via scrollWidth vs clientWidth)
- Fade in/out based on scroll position (hide left shadow at start, hide right shadow at end)

**Rationale:** Improves discoverability of scrollable content (many users don't realize horizontal scroll is available).

---

### Nutritional Icons

**Scope:** Small icons next to menu items indicating key attributes.

**Icons:**
- 🌱 Vegan
- 🥛 Dairy-free
- 🌾 Gluten-free
- 🌶️ Spicy
- ⭐ Popular item

**Location:** Below item name, before description.

**Design Constraint:** Limit to 3 icons max per item to avoid visual clutter.

**Data Requirement:** Extend MenuItem model with `tags: string[]` field.

---

### Compare Items

**Scope:** Allow users to select multiple items (checkboxes) and view side-by-side comparison.

**Use Case:** User choosing between two similar items wants to compare ingredients, nutritional info, and prices.

**UI Pattern:**
1. "Compare" mode toggle button (top-right of page)
2. Checkboxes appear on each item card
3. Floating "Compare (2)" button appears when 2-3 items selected
4. Tapping opens comparison sheet with 2-3 column layout

**Complexity:** High — requires dedicated comparison UI and state management.

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-19 | Initial design documentation — JSX design complete, filtering logic placeholder |

---

## Related Documentation

- **Design System:** `_reference/journeymate-design-system.md`
- **Business Profile Page:** `../01_business_profile_page/DESIGN_README_business_profile.md`
- **Filter System:** `../00_filter_system/DESIGN_README_filter_system.md`
- **Shared Components:** `_shared.jsx` (design tokens, data, micro-components)

---

**End of Document**
