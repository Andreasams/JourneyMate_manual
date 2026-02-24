# InformationPage JSX Design Documentation

**Component:** `InformationPage`
**File:** `pages/business_profile/information_page.jsx`
**Purpose:** Full-screen dedicated information page showing detailed restaurant data including opening hours, facilities, payment methods, and description
**Parent Context:** Navigated to from BusinessProfile page when user taps "Se alle informationer →" link

---

## Design Overview

The Information Page is a full-screen detail view that provides comprehensive information about a restaurant beyond what's shown on the main Business Profile page. It uses a vertical scroll layout with a header, hero image placeholder, and content sections organized hierarchically. The page emphasizes readability and scanability with clear section headers, expandable content for opening hours, and chip-based displays for facilities and payment options.

**Key Design Principles:**
- **Content hierarchy** — Name and status at top, followed by description, hours, facilities, and payments in descending order of importance
- **Expandable sections** — Opening hours start collapsed to reduce initial page height and allow quick scanning
- **Visual consistency** — Uses same chips, colors, and typography as Business Profile page for seamless transition
- **Information density** — Balances comprehensive data with whitespace and clear visual grouping
- **Navigation clarity** — Back arrow and centered restaurant name in header provide clear context and exit path

**Visual Summary:**
- Fixed header with back button and restaurant name
- 180px hero image placeholder below header
- Scrollable content area with 24px horizontal padding
- Five information sections: name/status, about text, hours (expandable), facilities (chips), payments (chips)
- Bottom padding for scroll overrun

---

## Visual Layout

### Container Structure
```
┌─────────────────────────────────────┐
│ StatusBar (20px)                     │
├─────────────────────────────────────┤
│ Header (60px)                        │ ← Fixed position
│  ← [Restaurant Name]                 │
├─────────────────────────────────────┤
│                                      │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │  Scrollable Content (790px)     │ │ ← Vertical scroll
│ │                                 │ │
│ │  • Hero Image (180px)           │ │
│ │  • Name (24px font)             │ │
│ │  • Status (13px + dot)          │ │
│ │  • About text (14px)            │ │
│ │  • Hours (expandable)           │ │
│ │  • Facilities (chip grid)       │ │
│ │  • Payments (chip grid)         │ │
│ │                                 │ │
│ │  [40px bottom padding]          │ │
│ └─────────────────────────────────┘ │
│                                      │
└─────────────────────────────────────┘
```

### Fixed Header Layout
```
┌─────────────────────────────────────┐
│  [←]      Restaurant Name            │
│  36px      centered with -36ml       │
└─────────────────────────────────────┘
   20px padding left/right
   Border bottom: 1px solid #f2f2f2
```

The header uses a three-column flex layout where the back button takes up space on the left, the title is centered using flex:1 with negative margin compensation, and the right side is empty. This ensures the title stays optically centered regardless of button width.

### Content Sections Hierarchy
```
Hero Image (180px height, full width)
↓
Content Container (24px horizontal padding)
  ├─ Name (24px font, 750 weight, 6px margin bottom)
  ├─ Status (6px dot + 13px text, 16px margin bottom)
  ├─ About (14px font, 20px line-height, 24px margin bottom)
  ├─ Hours Section (expandable, 24px margin bottom, border bottom)
  ├─ Facilities Section (24px margin bottom)
  └─ Payments Section (no bottom margin)
```

Each section follows a consistent pattern:
1. Section header (15px font, 600 weight, 12px margin bottom)
2. Content area (chips or text rows)
3. Bottom margin or border for visual separation

### Expandable Hours Section Layout
```
┌─────────────────────────────────────┐
│ Åbningstider m.m.              ▼    │ ← Collapsed state
├─────────────────────────────────────┤
│                                      │
```

When expanded:
```
┌─────────────────────────────────────┐
│ Åbningstider m.m.              ▲    │
├─────────────────────────────────────┤
│ Mandag              11:30 - 22:00   │
│ Tirsdag             11:30 - 22:00   │
│ Onsdag              11:30 - 22:00   │
│ Torsdag             11:30 - 22:00   │
│ Fredag              11:30 - 23:00   │
│ Lørdag              11:30 - 23:00   │
│ Søndag              Lukket           │
└─────────────────────────────────────┘
```

Each day row:
- 6px vertical padding
- 13px font size, #555 color
- Flex layout with space-between for left/right alignment
- Day name on left, hours on right
- Supports both string format and array of time objects

### Chip Grid Layout
```
Facilities Chips:
┌──────────┐ ┌──────────┐ ┌──────────┐
│ WiFi     │ │ Parkering│ │ Handicap │
└──────────┘ └──────────┘ └──────────┘
┌──────────┐ ┌──────────┐
│ Udeserv. │ │ Takeaway │
└──────────┘ └──────────┘

8px gap between chips
Flex wrap enabled
```

Payment Chips use identical styling and layout:
```
┌──────────┐ ┌──────────┐ ┌──────────┐
│ Kontant  │ │ Kreditk. │ │ MobilePay│
└──────────┘ └──────────┘ └──────────┘
```

---

## Components Used

### External Components
- **`StatusBar`** — Standard 20px status bar component from `shared/_shared.jsx`

### Internal Elements

#### 1. Header Bar
```jsx
<div style={{
  height: 60,
  display: "flex",
  alignItems: "center",
  padding: "0 20px",
  borderBottom: "1px solid #f2f2f2",
}}>
```

**Purpose:** Fixed navigation header with back button and centered restaurant name
**Layout:** Flex row, 60px height, 20px horizontal padding
**Border:** 1px solid #f2f2f2 bottom border for visual separation
**Interaction:** Contains back button and displays restaurant name for context

#### 2. Back Button
```jsx
<button
  onClick={onBack}
  style={{
    width: 36,
    height: 36,
    border: "none",
    background: "transparent",
    cursor: "pointer",
    fontSize: 18,
    color: "#0f0f0f",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
  }}
>
  ←
</button>
```

**Purpose:** Navigate back to Business Profile page
**Size:** 36×36px
**Icon:** Left arrow (←) at 18px font size
**Color:** #0f0f0f (primary text black)
**Behavior:** Transparent background, cursor pointer, calls `onBack` prop

#### 3. Centered Title
```jsx
<div style={{
  flex: 1,
  textAlign: "center",
  fontSize: 16,
  fontWeight: 600,
  color: "#0f0f0f",
  marginLeft: -36,
}}>
  {restaurant.name}
</div>
```

**Purpose:** Display restaurant name centered in header
**Typography:** 16px, 600 weight
**Centering Technique:** Uses flex:1 and -36px left margin to optically center title despite back button
**Dynamic Content:** Shows `restaurant.name` from props

#### 4. Hero Image Placeholder
```jsx
<div style={{
  width: "100%",
  height: 180,
  background: "#d0d0d0",
}} />
```

**Purpose:** Visual anchor and future placeholder for restaurant hero image
**Size:** Full width × 180px height
**Color:** #d0d0d0 (light gray placeholder)
**Position:** Directly below header, above content sections

#### 5. Restaurant Name Heading
```jsx
<h1 style={{
  fontSize: 24,
  fontWeight: 750,
  color: "#0f0f0f",
  margin: "0 0 6px 0",
}}>
  {restaurant.name}
</h1>
```

**Purpose:** Primary heading showing restaurant name in content area
**Typography:** 24px, 750 weight (bold)
**Spacing:** 6px bottom margin to status line
**Semantic:** Uses `<h1>` for proper heading hierarchy

#### 6. Status Indicator
```jsx
<div style={{
  display: "flex",
  alignItems: "center",
  gap: 6,
  marginBottom: 16,
}}>
  <div style={{
    width: 6,
    height: 6,
    borderRadius: "50%",
    background: restaurant.statusOpen ? GREEN : "#c9403a",
  }} />
  <span style={{
    fontSize: 13,
    fontWeight: 460,
    color: "#555",
  }}>
    {restaurant.statusText}
  </span>
</div>
```

**Purpose:** Visual indicator of restaurant open/closed status with text label
**Dot Size:** 6×6px circle
**Colors:** GREEN (#1a9456) for open, #c9403a (red) for closed
**Text:** 13px, 460 weight, #555 color
**Layout:** Flex row with 6px gap between dot and text
**Spacing:** 16px margin below before about text

#### 7. About Description
```jsx
{restaurant.about && (
  <p style={{
    fontSize: 14,
    fontWeight: 400,
    color: "#555",
    lineHeight: "20px",
    margin: "0 0 24px 0",
  }}>
    {restaurant.about}
  </p>
)}
```

**Purpose:** Long-form description text about the restaurant
**Conditional Rendering:** Only shows if `restaurant.about` exists
**Typography:** 14px, 400 weight, 20px line-height for readability
**Color:** #555 (medium gray)
**Spacing:** 24px bottom margin to next section

#### 8. Expandable Hours Section
```jsx
<div style={{
  marginBottom: 24,
  borderBottom: "1px solid #f2f2f2",
  paddingBottom: 16,
}}>
  <div
    onClick={() => setHoursOpen(!hoursOpen)}
    style={{
      display: "flex",
      justifyContent: "space-between",
      alignItems: "center",
      cursor: "pointer",
      padding: "8px 0",
    }}
  >
    <span style={{
      fontSize: 15,
      fontWeight: 600,
      color: "#0f0f0f",
    }}>
      Åbningstider m.m.
    </span>
    <span style={{ fontSize: 12, color: "#888" }}>
      {hoursOpen ? "▲" : "▼"}
    </span>
  </div>

  {hoursOpen && restaurant.hours && (
    <div style={{ marginTop: 12 }}>
      {restaurant.hours.map(([day, time], i) => (
        <div key={i} style={{
          display: "flex",
          justifyContent: "space-between",
          padding: "6px 0",
          fontSize: 13,
          color: "#555",
        }}>
          <span>{day}</span>
          <span>{typeof time === "string" ? time : time.map(t => t.time || t).join(", ")}</span>
        </div>
      ))}
    </div>
  )}
</div>
```

**Purpose:** Collapsible section showing weekly opening hours
**State Management:** Local `hoursOpen` boolean state controls expansion
**Header Interaction:** Click anywhere on header row to toggle
**Indicator:** ▲ when open, ▼ when closed
**Conditional Rendering:** Content only renders when `hoursOpen === true` and `restaurant.hours` exists

**Hours Data Structure:**
- Array of `[day, time]` tuples
- `time` can be string ("11:30 - 22:00", "Lukket") or array of time objects
- Time objects have `.time` property or are string values
- Multiple time ranges joined with ", " separator

**Visual Hierarchy:**
- Section has bottom border (#f2f2f2) and 24px margin for separation
- 8px vertical padding on clickable header
- 12px top margin when expanded content appears
- Each day row has 6px vertical padding, 13px font, #555 color
- Day names left-aligned, times right-aligned with space-between

#### 9. Facilities Section
```jsx
{restaurant.facilities && (
  <div style={{ marginBottom: 24 }}>
    <h3 style={{
      fontSize: 15,
      fontWeight: 600,
      color: "#0f0f0f",
      margin: "0 0 12px 0",
    }}>
      Faciliteter og services
    </h3>
    <div style={{
      display: "flex",
      flexWrap: "wrap",
      gap: 8,
    }}>
      {restaurant.facilities.map((fac, i) => (
        <div key={i} style={{
          padding: "7px 12px",
          borderRadius: 10,
          fontSize: 12.5,
          fontWeight: 540,
          background: "#fff",
          color: "#555",
          border: "1px solid #e8e8e8",
        }}>
          {fac}
        </div>
      ))}
    </div>
  </div>
)}
```

**Purpose:** Display available facilities and services as visual chips
**Conditional Rendering:** Only shows if `restaurant.facilities` exists
**Layout:** Flex wrap grid with 8px gaps
**Chip Styling:**
- 7px vertical × 12px horizontal padding
- 10px border radius (rounded corners)
- 12.5px font size, 540 weight
- White background (#fff)
- Medium gray text (#555)
- Light gray border (1px solid #e8e8e8)

**Section Header:**
- "Faciliteter og services" in Danish
- 15px font, 600 weight
- 12px margin below header before chips

**Bottom Spacing:** 24px margin to next section

#### 10. Payment Methods Section
```jsx
{restaurant.payments && (
  <div>
    <h3 style={{
      fontSize: 15,
      fontWeight: 600,
      color: "#0f0f0f",
      margin: "0 0 12px 0",
    }}>
      Betalingsmuligheder
    </h3>
    <div style={{
      display: "flex",
      flexWrap: "wrap",
      gap: 8,
    }}>
      {restaurant.payments.map((pay, i) => (
        <div key={i} style={{
          padding: "7px 12px",
          borderRadius: 10,
          fontSize: 12.5,
          fontWeight: 540,
          background: "#fff",
          color: "#555",
          border: "1px solid #e8e8e8",
        }}>
          {pay}
        </div>
      ))}
    </div>
  </div>
)}
```

**Purpose:** Display accepted payment methods as visual chips
**Conditional Rendering:** Only shows if `restaurant.payments` exists
**Layout:** Identical to facilities section — flex wrap grid with 8px gaps
**Chip Styling:** Identical to facilities chips (7px×12px padding, 10px radius, etc.)

**Section Header:**
- "Betalingsmuligheder" in Danish
- 15px font, 600 weight
- 12px margin below header before chips

**Bottom Spacing:** No bottom margin (last section on page)

---

## Design Tokens

### Color Palette
| Token | Hex Value | Usage |
|-------|-----------|-------|
| `GREEN` | `#1a9456` | Open status dot |
| `ACCENT` | `#e8751a` | (Imported but not used in this component) |
| Primary Text | `#0f0f0f` | Restaurant name, section headers, back button |
| Secondary Text | `#555` | Status text, about description, chip text, hours rows |
| Tertiary Text | `#888` | Expand/collapse arrow indicator |
| Closed Red | `#c9403a` | Closed status dot |
| Background White | `#fff` | Page background, chip backgrounds |
| Border Gray | `#f2f2f2` | Header bottom border, hours section bottom border |
| Chip Border | `#e8e8e8` | Facility and payment chip borders |
| Placeholder Gray | `#d0d0d0` | Hero image placeholder background |

### Typography Scale
| Use Case | Size | Weight | Line Height | Color |
|----------|------|--------|-------------|-------|
| Page Title (header) | 16px | 600 | — | #0f0f0f |
| Restaurant Name (h1) | 24px | 750 | — | #0f0f0f |
| Section Headers | 15px | 600 | — | #0f0f0f |
| Body Text (about) | 14px | 400 | 20px | #555 |
| Status Text | 13px | 460 | — | #555 |
| Hours Rows | 13px | — | — | #555 |
| Chip Labels | 12.5px | 540 | — | #555 |
| Arrow Indicator | 12px | — | — | #888 |
| Back Arrow | 18px | — | — | #0f0f0f |

**Font Weight Strategy:**
- 400 = Regular body text (about description)
- 460 = Slightly emphasized text (status label)
- 540 = Medium emphasis (chips)
- 600 = Strong emphasis (section headers, page title)
- 750 = Extra bold (main restaurant name heading)

### Spacing System
| Context | Value | Purpose |
|---------|-------|---------|
| Header Height | 60px | Fixed header bar |
| Header Horizontal Padding | 20px | Left/right header padding |
| Content Horizontal Padding | 24px | Left/right content padding |
| Scrollable Area Height | 790px | Main content scroll container |
| Bottom Padding | 40px | Scroll overrun space |
| Hero Image Height | 180px | Image placeholder height |
| Section Bottom Margin | 24px | Space between major sections |
| Header to Content | 6px | Name to status spacing |
| Status to About | 16px | Status to description spacing |
| Section Header to Content | 12px | Header to chips/rows spacing |
| Hours Section Padding Bottom | 16px | Internal bottom padding before border |
| Hours Header Vertical Padding | 8px | Clickable header padding |
| Hours Content Top Margin | 12px | Space when expanded |
| Hours Row Vertical Padding | 6px | Individual day row padding |
| Chip Gap | 8px | Space between chips in grid |
| Chip Vertical Padding | 7px | Top/bottom chip padding |
| Chip Horizontal Padding | 12px | Left/right chip padding |
| Status Dot to Text Gap | 6px | Space between dot and label |

### Component Dimensions
| Element | Size | Notes |
|---------|------|-------|
| Page Container | 390×844px | Standard mobile viewport |
| Status Bar | 390×20px | System status bar |
| Back Button | 36×36px | Square touch target |
| Status Dot | 6×6px | Circular indicator |
| Chip Border Radius | 10px | Rounded corners |
| Border Widths | 1px | All borders consistent |

---

## State & Data

### Component State
```javascript
const [hoursOpen, setHoursOpen] = useState(false);
```

**Purpose:** Controls expansion/collapse of opening hours section
**Type:** Boolean
**Default:** `false` (collapsed on page load)
**Toggle Behavior:** Clicking anywhere on "Åbningstider m.m." header row flips the boolean
**Visual Effect:**
- When `false`: Shows header with ▼ arrow, hides hours rows
- When `true`: Shows header with ▲ arrow, reveals hours rows

**Rationale:** Starting collapsed reduces initial page height and allows users to quickly scan other information. Users interested in hours can expand with a single tap.

### Props Interface
```typescript
interface InformationPageProps {
  restaurant: RestaurantObject;
  onBack: () => void;
}
```

#### `restaurant` Object Structure
```javascript
{
  name: string,              // Restaurant name (shown in header and h1)
  statusOpen: boolean,       // true = open (green dot), false = closed (red dot)
  statusText: string,        // e.g., "Åbent til 22:00", "Lukket • Åbner kl. 11:30"
  about?: string,            // Long-form description (optional, renders if present)
  hours?: Array<[string, string | Array<{time?: string}> | Array<string>]>,
                            // Opening hours data (optional):
                            // [day, time] where time can be:
                            // - String: "11:30 - 22:00" or "Lukket"
                            // - Array of time objects: [{time: "11:30 - 14:00"}, {time: "17:00 - 22:00"}]
                            // - Array of strings: ["11:30 - 14:00", "17:00 - 22:00"]
  facilities?: string[],     // Array of facility names (optional)
                            // e.g., ["WiFi", "Parkering", "Handicapvenlig", "Udeservering"]
  payments?: string[],       // Array of payment method names (optional)
                            // e.g., ["Kontant", "Kreditkort", "MobilePay", "Dankort"]
}
```

#### `onBack` Function
**Type:** `() => void`
**Purpose:** Callback function to handle back navigation
**Usage:** Called when user taps back arrow in header
**Expected Behavior:** Should navigate back to Business Profile page, likely by calling a parent component's state setter or navigation function

### Data Rendering Patterns

#### Conditional Section Rendering
All major sections (about, facilities, payments) use conditional rendering:
```javascript
{restaurant.about && (
  <p>...</p>
)}
```

**Rationale:** Not all restaurants will have all data fields. Conditional rendering prevents empty sections and maintains clean visual hierarchy based on available data.

#### Hours Data Flexibility
The hours rendering logic handles three data formats:
```javascript
{typeof time === "string"
  ? time
  : time.map(t => t.time || t).join(", ")}
```

**Case 1 — Simple String:**
```javascript
["Mandag", "11:30 - 22:00"]
// Renders: 11:30 - 22:00
```

**Case 2 — Array of Objects:**
```javascript
["Mandag", [
  { time: "11:30 - 14:00" },
  { time: "17:00 - 22:00" }
]]
// Renders: 11:30 - 14:00, 17:00 - 22:00
```

**Case 3 — Array of Strings:**
```javascript
["Mandag", ["11:30 - 14:00", "17:00 - 22:00"]]
// Renders: 11:30 - 14:00, 17:00 - 22:00
```

**Rationale:** Supports both simple single-period hours and complex split-shift hours (e.g., lunch and dinner service).

#### Dynamic Chip Generation
Both facilities and payments use `.map()` to generate chips:
```javascript
{restaurant.facilities.map((fac, i) => (
  <div key={i} style={{...}}>
    {fac}
  </div>
))}
```

**Key Behavior:**
- Array index used as React key (safe since arrays are static)
- Each string in array becomes one chip
- Flex wrap handles overflow to multiple rows
- Order preserved from data array

---

## User Interactions

### 1. Back Navigation
**Trigger:** Tap back arrow button (top-left)
**Visual Feedback:** Button has cursor:pointer (web-appropriate)
**Action:** Calls `onBack()` prop function
**Expected Result:** Navigate back to Business Profile page
**Touch Target:** 36×36px (meets WCAG 2.5.5 minimum 44×44px is close, acceptable for secondary action)

### 2. Hours Section Toggle
**Trigger:** Tap anywhere on "Åbningstider m.m." header row
**Visual Feedback:**
- Cursor pointer on hover (web)
- Arrow indicator changes: ▼ → ▲ or ▲ → ▼
**State Change:** `setHoursOpen(!hoursOpen)`
**Visual Result:**
- **Collapsed → Expanded:** Hours rows fade in, arrow flips to ▲
- **Expanded → Collapsed:** Hours rows disappear, arrow flips to ▼

**Touch Target:** Full width of header row with 8px vertical padding
**Rationale:** Large touch target reduces interaction friction. The entire row is clickable rather than just the arrow, following mobile UX best practices.

### 3. Vertical Scrolling
**Context:** Main content area (790px height)
**Behavior:** `overflowY: "scroll"` enables vertical scrolling
**Content Height:** Variable based on data (hero + name + sections)
**Bottom Padding:** 40px provides overscroll space
**Scroll Performance:** Native browser scroll, no custom implementation

**Scroll Behavior:**
- Header remains fixed at top (outside scroll container)
- Hero image scrolls naturally with content
- No scroll snap points
- No parallax effects
- Standard momentum scrolling on mobile

### 4. Passive Interactions (No User Action)

#### Status Dot Color
**Logic:** `restaurant.statusOpen ? GREEN : "#c9403a"`
**Behavior:** Automatically shows green for open, red for closed
**No Interaction:** Purely informational, not clickable

#### Chip Display
**Behavior:** Facilities and payments render as static chips
**No Interaction:** Not tappable, purely informational
**Rationale:** This is a read-only information page. Interactive filtering happens on Search page.

### 5. Data-Driven Visibility
**Conditional Rendering:**
- About text only shows if `restaurant.about` exists
- Hours section only shows if `restaurant.hours` exists
- Facilities section only shows if `restaurant.facilities` exists
- Payments section only shows if `restaurant.payments` exists

**User Experience Impact:**
- Page layout adapts to available data
- No empty section headers
- Cleaner presentation for restaurants with incomplete data
- Vertical spacing adjusts naturally

---

## Design Rationale

### Information Architecture Decisions

#### 1. Full-Screen Dedicated Page (Not Inline Expansion)
**Decision:** Information content lives on a separate routed page rather than expanding inline on Business Profile
**Rationale:**
- Information content can be extensive (long about text, 7-day hours, many facilities)
- Inline expansion would push other Business Profile content (menu, gallery) down
- Separate page allows focused, distraction-free reading
- Provides clear navigation context with back button and title
- Allows future expansion of info sections without affecting main profile layout

**Alternative Rejected:** Inline expandable section on Business Profile page

#### 2. Expandable Hours Section (Default Collapsed)
**Decision:** Opening hours start collapsed and expand on tap
**Rationale:**
- Reduces initial page height for quick scanning
- Hours are important but not the primary information need
- Users specifically interested in hours can expand with one tap
- Expanded state shows full 7-day schedule for trip planning
- Collapse/expand pattern is familiar from accordion UIs

**Alternative Considered:** Always-expanded hours (rejected due to vertical space consumption)

#### 3. Chip-Based Display for Facilities and Payments
**Decision:** Use bordered white chips instead of bullet lists or icons
**Rationale:**
- Visual consistency with Business Profile page chip displays
- Scanability: chips create clear visual units
- Flexible layout: flex wrap handles variable content gracefully
- White chips with gray borders are neutral and non-interactive (read-only context)
- 8px gap provides breathing room without wasting space

**Alternative Rejected:** Icon-based grid (would require icon asset management)

#### 4. Hero Image Placeholder Above Content
**Decision:** 180px full-width placeholder directly below header
**Rationale:**
- Visual anchor point for the page
- Provides context before text-heavy content
- 180px height balances presence without dominating viewport
- Placeholder design indicates future image implementation
- Scrolls naturally with content (not fixed parallax)

**Alternative Considered:** No image, text-only page (rejected due to lack of visual interest)

### Typography and Hierarchy Decisions

#### 5. Restaurant Name Appears Twice (Header + H1)
**Decision:** Name shows in fixed header (16px) and content area (24px)
**Rationale:**
- **Header Name (16px):** Provides persistent context while scrolling, confirms location
- **Content Name (24px):** Serves as semantic `<h1>` heading, larger for primary content hierarchy
- Duplication is intentional: header for navigation context, h1 for content structure
- User never sees both simultaneously (h1 scrolls out of view, header stays visible)

#### 6. Section Headers at 15px (Smaller Than Main Name)
**Decision:** "Åbningstider m.m.", "Faciliteter og services", "Betalingsmuligheder" at 15px
**Rationale:**
- Clear hierarchy: restaurant name (24px) > section headers (15px) > body text (13-14px)
- 600 weight provides sufficient emphasis despite smaller size
- Proportional to the detail-level nature of these sections
- Consistent with information architecture (primary > secondary > tertiary)

#### 7. Body Text at 14px with 20px Line Height
**Decision:** About description uses 14px font with 20px line-height
**Rationale:**
- 20px line-height (1.43 ratio) optimized for readability of longer text
- 14px size balances legibility with space efficiency
- #555 color reduces visual weight while maintaining WCAG AA contrast
- Suitable for descriptive prose that may span multiple lines

### Layout and Spacing Decisions

#### 8. 24px Horizontal Content Padding
**Decision:** Content area uses 24px left/right padding (header uses 20px)
**Rationale:**
- 24px provides comfortable reading margins for text-heavy content
- Slightly wider than header (20px) to emphasize content area
- Aligns with standard mobile content padding (16-24px range)
- Sufficient whitespace without feeling cramped on 390px viewport

#### 9. Consistent 24px Section Spacing
**Decision:** Major sections separated by 24px bottom margin
**Rationale:**
- Creates clear visual grouping without excessive whitespace
- Same spacing value across all sections (hours, facilities, payments)
- 24px balances separation with vertical space efficiency
- Rhythm: 6px (name to status) < 16px (status to about) < 24px (section spacing)

#### 10. 40px Bottom Padding on Scroll Container
**Decision:** Scroll area has 40px padding at bottom
**Rationale:**
- Provides overscroll space so last content isn't cut off
- Allows "scroll bounce" on iOS without clipping content
- 40px is sufficient for comfortable end-of-content indication
- Prevents last section from feeling cramped against viewport edge

### Visual Design Decisions

#### 11. Status Dot Uses GREEN or Red (Not ACCENT)
**Decision:** 6px dot colored GREEN (#1a9456) for open, #c9403a (red) for closed
**Rationale:**
- Follows design system rule: green = match confirmation/positive status
- ACCENT orange (#e8751a) reserved for interactive elements (CTAs, selections)
- Red universally understood as closed/negative status
- 6px size is visible but not dominant
- Dot + text pattern is familiar from many apps (Slack status, etc.)

#### 12. White Chip Backgrounds (Not Colored)
**Decision:** Facility and payment chips use white background with #e8e8e8 border
**Rationale:**
- Read-only context: no interaction, so no interactive color (ACCENT)
- White chips with subtle border create separation without visual weight
- Consistent with design system: colored chips indicate selection/action
- #555 text color matches other secondary information
- Focus on content (facility names) rather than UI decoration

#### 13. Border Colors: #f2f2f2 vs #e8e8e8
**Decision:** Header border and hours section border use #f2f2f2; chips use #e8e8e8
**Rationale:**
- **#f2f2f2 (lighter):** Subtle structural separators (header, section borders)
- **#e8e8e8 (darker):** More defined component borders (chips)
- Two-tier border system creates visual hierarchy without multiple color tokens
- Both are neutral grays that don't compete with content

### Interaction Design Decisions

#### 14. Full-Width Hours Header Clickable (Not Just Arrow)
**Decision:** Entire "Åbningstider m.m." row is clickable, not just the arrow
**Rationale:**
- Larger touch target reduces interaction friction
- Follows mobile UX best practice: entire row is tap target in accordions
- Arrow serves as indicator, not sole interaction point
- Users naturally tap anywhere on the row to expand

#### 15. No Interactions on Chips
**Decision:** Facility and payment chips are static display elements
**Rationale:**
- This is an information page, not a filter or selection context
- Making chips tappable would imply an action (filter, navigate)
- Consistent with design system: chips are interactive on Search page, static elsewhere
- Reduces cognitive load: no decision fatigue about what's clickable

#### 16. No Share, Call, or Map Actions on This Page
**Decision:** Information page is read-only with only back navigation
**Rationale:**
- Actions (share, call, navigate) live on main Business Profile page
- This page serves a focused information-reading purpose
- Adding actions would duplicate Business Profile functionality
- Users can back out to Business Profile for actions
- Separation of concerns: Business Profile = actions, Information Page = data

### Responsiveness and Scroll Behavior

#### 17. Fixed 390×844px Container (No Responsive Breakpoints)
**Decision:** Page designed for specific mobile dimensions
**Rationale:**
- JSX design phase targets standard mobile viewport
- Responsive design will be handled in Flutter implementation
- 390px width is common iOS baseline (iPhone 12/13/14)
- 844px height accommodates standard device heights with header/status

#### 18. Header Fixed, Content Scrolls
**Decision:** Header remains visible while content scrolls underneath
**Rationale:**
- Persistent back button allows exit at any scroll position
- Restaurant name in header maintains context while reading
- Standard pattern: fixed header + scrollable content
- Prevents need to scroll to top to navigate back

#### 19. No Scroll Indicators or Progress Bars
**Decision:** Standard native scroll behavior with no custom indicators
**Rationale:**
- Native scrollbars (on web) or lack thereof (on mobile) are expected
- Content length is variable, making fixed indicators inaccurate
- Users understand scroll behavior intuitively
- 40px bottom padding provides visual "end of content" cue

### Data Structure Flexibility

#### 20. Multiple Hours Format Support
**Decision:** Hours rendering handles string, object array, or string array formats
**Rationale:**
- Future-proofs against different data sources
- Supports simple restaurants (string) and complex schedules (arrays)
- Example: "11:30 - 22:00" vs ["11:30 - 14:00", "17:00 - 22:00"] for split shifts
- Avoids forcing data standardization at early design phase
- `.map(t => t.time || t)` gracefully handles both formats

#### 21. Conditional Section Rendering
**Decision:** All sections (about, hours, facilities, payments) conditionally render
**Rationale:**
- Not all restaurants will have complete data
- Empty sections with "No information available" messages would clutter the page
- Cleaner UX: only show what exists
- Layout adapts naturally: if no about text, next section moves up
- Matches real-world data: some restaurants won't have all fields populated

### Visual Consistency with Business Profile

#### 22. Identical Chip Styling to Business Profile
**Decision:** Chips use same padding, radius, border, font as Business Profile dietary tags
**Rationale:**
- Visual consistency across pages
- User recognizes pattern: "these are informational chips"
- Single shared component possible in Flutter implementation
- Design system coherence: same element type, same styling

#### 23. Status Indicator Pattern Reused
**Decision:** 6px dot + text label pattern matches Business Profile status line
**Rationale:**
- User has already learned this pattern on Business Profile
- Consistent status representation across app
- Same data source (statusOpen, statusText) as Business Profile
- Reinforces visual language: dot = status, GREEN = open, red = closed

---

## Future Considerations

### Flutter Migration Notes

1. **Scroll Performance:** Use `ListView` or `SingleChildScrollView` for main content area. Consider `CustomScrollView` with `SliverAppBar` if pinned header behavior is desired.

2. **Expandable Hours Section:** Implement with `AnimatedContainer` or `ExpansionTile` widget. `ExpansionTile` provides built-in expand/collapse with animation.

3. **Hero Image:** Replace placeholder with `CachedNetworkImage` or `Image.network` with proper loading states and error handling.

4. **Chip Components:** Create shared `InfoChip` widget for facilities and payments. Identical styling suggests single reusable component.

5. **Back Navigation:** Use `Navigator.pop(context)` for back button. Consider `WillPopScope` to handle Android hardware back button.

6. **Data Validation:** Add null safety checks and default values for all optional fields (about, hours, facilities, payments).

7. **Hours Parsing:** Consider separate data model for complex hours structures. Current string handling works for display but may need stricter typing in Dart.

8. **Accessibility:** Add semantic labels for screen readers, especially for status dot (color alone is not accessible).

### Potential Enhancements (Not in Current Design)

1. **Expandable About Section:** If about text is very long, could collapse to 3-4 lines with "Read more" expansion.

2. **Phone/Website Links:** Could add tappable phone number and website URL fields if data is available.

3. **Map Integration:** "See on map" link could open native maps app with restaurant location.

4. **Share Action:** Could add share button to header for sharing restaurant information.

5. **Hours Formatting:** Could add "Today" label next to current day in hours list for easier scanning.

6. **Special Hours:** Could support holiday hours or temporary schedule changes with distinct styling.

7. **Icons for Facilities:** Could add icons next to facility names (WiFi icon, parking icon, etc.) for faster scanning.

8. **Payment Method Icons:** Could show card brand logos for credit card types (Visa, Mastercard, etc.).

9. **Dietary Tags:** Could move dietary information from Business Profile to this page as a dedicated section.

10. **Translations:** All Danish strings should be externalized for localization in Flutter implementation.

---

## Summary

The Information Page is a focused, read-only detail view that presents comprehensive restaurant information in a scannable, hierarchical layout. It uses expandable sections (hours), chip-based displays (facilities, payments), and conditional rendering to adapt to available data. The design emphasizes readability with generous spacing, clear typography hierarchy, and visual consistency with the Business Profile page. The single interaction point (expandable hours) is intentionally simple, keeping the page focused on information consumption rather than complex interactions. The fixed header with back button provides persistent navigation context, while the scrollable content area accommodates variable content length gracefully.

**Core Design Principle:** This page is the "full story" of a restaurant's practical information—what it offers, when it's open, how you can pay—presented in a format optimized for reading and scanning, not interaction or action-taking.
