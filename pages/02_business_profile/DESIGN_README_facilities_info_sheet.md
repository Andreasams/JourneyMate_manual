# Facilities Info Sheet — Design Documentation

**File:** `pages/business_profile/facilities_info_sheet.jsx`
**Type:** Modal Bottom Sheet Component
**Purpose:** Display detailed information about a specific facility or amenity offered by the restaurant
**Last Updated:** 2026-02-19

---

## Table of Contents

1. [Design Overview](#design-overview)
2. [Visual Layout](#visual-layout)
3. [Components Used](#components-used)
4. [Design Tokens](#design-tokens)
5. [State & Data](#state--data)
6. [User Interactions](#user-interactions)
7. [Design Rationale](#design-rationale)
8. [Accessibility Considerations](#accessibility-considerations)

---

## Design Overview

### Purpose and Function

The Facilities Info Sheet is a modal bottom sheet that provides users with detailed information about a specific facility or amenity offered by a restaurant. When a user taps the info icon (ⓘ) next to a facility chip on the Business Profile page, this sheet slides up from the bottom of the screen, displaying expanded details about that facility.

**Key Characteristics:**
- **Modal presentation** — Slides up from bottom, dims background
- **Single-purpose display** — Shows one facility at a time
- **Dismissible** — User can close by tapping outside or swiping down
- **Concise content** — Title and description only, no additional UI elements
- **Half-screen height** — Takes up 50% of viewport for quick reference

**User Journey Context:**

```
Business Profile page
  ↓
User taps info icon (ⓘ) on facility chip
  ↓
Facilities Info Sheet slides up
  ↓
User reads facility details
  ↓
User closes sheet (tap outside, swipe down, or back)
  ↓
Returns to Business Profile page
```

### Design Philosophy

This component follows the "progressive disclosure" pattern — basic facility information is shown as chips on the Business Profile page, with detailed explanations available on-demand through this sheet. The design prioritizes:

1. **Minimal friction** — Opens instantly, no loading states
2. **Clarity** — Large, readable text with clear hierarchy
3. **Brevity** — Concise descriptions that respect user time
4. **Consistency** — Uses the same BottomSheet component as other modals

---

## Visual Layout

### Overall Structure

```
┌─────────────────────────────────────┐
│  ═══  Handle bar                    │  ← BottomSheet component
├─────────────────────────────────────┤
│                                     │
│  [Title]                         [X]│  ← 24px top padding
│                                     │
│  Description text spanning          │  ← 16px below title
│  multiple lines with clear          │
│  readability and proper line        │
│  height.                            │
│                                     │
│                                     │
│                                     │  ← Scrollable if content long
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
└─────────────────────────────────────┘
     50% of viewport height
```

### Layout Specifications

**Sheet Dimensions:**
- **Height:** 50% of viewport height
- **Width:** Full viewport width minus safe areas
- **Corner radius:** 20px (top corners only, inherited from BottomSheet)
- **Background:** White (#ffffff)

**Content Container:**
- **Padding:** 24px (top), 20px (horizontal), 32px (bottom)
- **Vertical scroll:** Enabled if content exceeds available height
- **Height calculation:** `calc(100% - 20px)` to account for handle

**Title:**
- **Font size:** 20px
- **Font weight:** 680
- **Color:** #0f0f0f (near-black)
- **Margin bottom:** 16px
- **Padding right:** 40px (to avoid close button overlap)
- **Margin:** 0 (top, left, right for title itself)

**Description:**
- **Font size:** 14px
- **Font weight:** 400 (regular)
- **Color:** #555555 (medium gray)
- **Line height:** 20px (1.43x ratio for readability)
- **Margin:** 0

### Visual Hierarchy

The sheet uses a clear two-level hierarchy:

1. **Primary level (Title):**
   - Largest text (20px)
   - Heaviest weight (680)
   - Darkest color (#0f0f0f)
   - Establishes what facility is being described

2. **Secondary level (Description):**
   - Smaller text (14px)
   - Normal weight (400)
   - Lighter color (#555)
   - Provides detailed explanation

**No tertiary elements** — The design intentionally avoids additional UI like buttons, links, or icons within the content area. This keeps focus on reading the information.

### Spacing System

Spacing follows a clear rhythm:

```
Top padding:        24px  (breathing room from handle)
Title bottom:       16px  (separation between title and body)
Horizontal padding: 20px  (consistent left/right margins)
Bottom padding:     32px  (extra space for scroll affordance)
```

The spacing creates a comfortable reading experience while maintaining density — the user can see most content without scrolling in typical cases.

---

## Components Used

### BottomSheet Component

**Source:** `shared/_shared.jsx`

The FacilitiesInfoSheet wraps its content in the shared `BottomSheet` component, which handles:
- Modal presentation with backdrop
- Slide-up animation with spring physics
- Drag handle at top
- Close button (X) in top-right
- Swipe-to-dismiss gesture
- Tap-outside-to-dismiss interaction

**Props passed to BottomSheet:**
```jsx
<BottomSheet
  visible={visible}     // Boolean from parent
  onClose={onClose}     // Callback to parent
  height="50%"          // Fixed half-screen height
>
```

**Why BottomSheet is appropriate:**
- **Consistent behavior** — All bottom sheets in the app behave identically
- **Native feel** — Swipe gestures match iOS/Android patterns
- **Accessibility** — Built-in keyboard trap, focus management
- **Dismissal options** — Multiple intuitive ways to close

### Native HTML Elements

Beyond the BottomSheet wrapper, the component uses only semantic HTML:

**`<div>` — Content container:**
```jsx
<div style={{
  padding: "24px 20px 32px",
  height: "calc(100% - 20px)",
  overflowY: "auto",
}}>
```
- Manages padding, scroll, and height
- No additional semantic meaning needed (inside modal)

**`<h3>` — Title heading:**
```jsx
<h3 style={{
  fontSize: 20,
  fontWeight: 680,
  color: "#0f0f0f",
  margin: "0 0 16px 0",
  paddingRight: 40,
}}>
```
- Semantic heading level appropriate for modal title
- Not `<h1>` because it's nested within Business Profile context
- Not `<h2>` because it's subordinate to profile title

**`<p>` — Description paragraph:**
```jsx
<p style={{
  fontSize: 14,
  fontWeight: 400,
  color: "#555",
  lineHeight: "20px",
  margin: 0,
}}>
```
- Standard paragraph element for body text
- No `<div>` for text content (respects semantic HTML)

**No additional components** — The design deliberately avoids:
- Custom buttons or links
- Icons within content
- List structures
- Images or media
- Interactive elements

This simplicity ensures fast rendering and clear focus on the information itself.

---

## Design Tokens

### Colors

**Text Colors:**
```jsx
#0f0f0f  // Title — near-black, maximum contrast
#555555  // Description — medium gray, readable but secondary
```

**Background Colors:**
```jsx
#ffffff  // Sheet background (inherited from BottomSheet)
```

**Interactive Colors:**
```jsx
ACCENT (#e8751a)  // Not used in this component
                  // (BottomSheet close button uses it)
```

**Why no accent color usage:**
The facilities info is purely informational, with no interactive elements beyond dismissal. The orange accent would introduce visual noise without functional purpose.

### Typography

**Font Weights:**
```jsx
680  // Title — Bold, attention-grabbing
400  // Description — Regular, easy to read for longer text
```

**Font Sizes:**
```jsx
20px  // Title — Large enough to establish hierarchy
14px  // Description — Standard body text size
```

**Line Heights:**
```jsx
20px for 14px text = 1.43x ratio
```
This ratio provides comfortable reading for multi-line descriptions without excessive vertical space.

**Font Family:**
Inherited from global styles (Inter variable font), ensuring consistency with the rest of the app.

### Spacing Scale

```jsx
32px  // Bottom padding (extra scroll affordance)
24px  // Top padding (breathing room)
20px  // Horizontal padding (content margins)
16px  // Title bottom margin (hierarchy separation)
40px  // Title right padding (avoid close button)
```

All values align with the 4px base grid used throughout JourneyMate.

### Border Radius

```jsx
20px  // Top corners (inherited from BottomSheet)
```

### Shadow & Elevation

Not explicitly defined in this component. The BottomSheet component handles the modal backdrop and elevation:
- **Backdrop:** Semi-transparent black overlay
- **Sheet elevation:** Appears above all page content

---

## State & Data

### Component Props

```jsx
function FacilitiesInfoSheet({ visible, onClose, facility })
```

**`visible` (boolean):**
- Controls whether the sheet is shown or hidden
- Passed from parent (Business Profile page)
- Managed by parent's state (`showInfoSheet` boolean)
- When `false`, BottomSheet animates out

**`onClose` (function):**
- Callback executed when user dismisses sheet
- Parent defines this to set `showInfoSheet = false`
- Triggered by:
  - Tapping close button (X)
  - Tapping backdrop
  - Swiping down on sheet
  - Pressing back/escape

**`facility` (object):**
- The facility data object from the restaurant's `facilities` array
- Structure: `{ l: "Label", i: "IconName" }`
- Example: `{ l: "Udendørs siddepladser", i: "outdoor_seat" }`
- Used to look up detailed information

### Early Return Pattern

```jsx
if (!facility) return null;
```

**Purpose:**
- Prevents rendering errors if sheet opens without facility data
- Returns `null` (renders nothing) rather than empty sheet
- Defensive programming for edge cases

**When this occurs:**
- Parent passes `facility={null}` or `facility={undefined}`
- Sheet is in transition state between facilities
- Programming error in parent component

### Facility Information Lookup

```jsx
const facilityInfo = {
  "Udendørs siddepladser": {
    title: "Udendørs siddepladser",
    description: "Vi har udendørs siddepladser med udsigt..."
  },
  "Morgenmad": { ... },
  // etc.
};
```

**Data Structure:**
- **Key:** Facility label (Danish text string)
- **Value:** Object with `title` and `description`

**Purpose:**
- Maps from terse chip labels to full explanatory text
- Provides rich descriptions for common facilities
- Allows customization beyond simple label display

**Current facility types with detailed info:**
1. **Udendørs siddepladser** — Outdoor seating with view
2. **Morgenmad** — Breakfast service with hours and menu details
3. **Børnestol** — High chairs with reservation note
4. **Hunde tilladt ude** — Dog-friendly outdoor area with amenities
5. **Økologisk** — Organic and sustainable ingredients

**Fallback for unknown facilities:**
```jsx
const info = facilityInfo[facility.l] || {
  title: facility.l,
  description: "For mere information om denne facilitet, kontakt venligst restauranten direkte."
};
```

If a facility isn't in the predefined list:
- Uses the raw label as the title
- Shows generic "contact restaurant" message
- Prevents blank or error state

### Content Derivation

```jsx
{info.title}      // Rendered in <h3>
{info.description} // Rendered in <p>
```

The `info` object (either from `facilityInfo` dictionary or fallback) provides both strings displayed in the UI.

**No additional state:**
- No local `useState` hooks
- No scroll position tracking
- No dynamic content fetching
- Sheet is purely presentational based on passed props

---

## User Interactions

### Opening the Sheet

**Trigger:** User taps info icon (ⓘ) on a facility chip in Business Profile page

**Parent-side logic:**
```jsx
// Parent state (Business Profile page)
const [showInfoSheet, setShowInfoSheet] = useState(false);
const [selectedFacility, setSelectedFacility] = useState(null);

// On info icon tap
setSelectedFacility(facility);
setShowInfoSheet(true);
```

**Component receives:**
- `visible={true}`
- `facility={tappedFacility}`

**Animation:**
- BottomSheet slides up from bottom with spring curve
- Backdrop fades in behind sheet
- Takes ~300ms to fully appear

### Reading Content

**Static display:**
- Content is immediately visible (no loading)
- User can scroll if description is long
- No interactive elements to distract from reading

**Scroll behavior:**
```jsx
overflowY: "auto"
```
- Vertical scroll enabled automatically if content exceeds `calc(100% - 20px)`
- Scrollbar appears only when needed (native OS styling)
- Smooth scrolling on touch devices

### Closing the Sheet

**Four dismissal methods:**

1. **Tap close button (X):**
   - Close button provided by BottomSheet component
   - Top-right corner, always visible
   - Tapping calls `onClose()`

2. **Tap backdrop:**
   - Tapping the dimmed area outside sheet
   - Handled by BottomSheet component
   - Calls `onClose()`

3. **Swipe down:**
   - Drag sheet downward (touch gesture)
   - Threshold crossing triggers `onClose()`
   - Spring animation back down

4. **Back/escape key:**
   - Android back button
   - Escape key on desktop
   - Handled by BottomSheet modal logic
   - Calls `onClose()`

**Close callback:**
```jsx
onClose() → Parent sets showInfoSheet = false
```

**Animation:**
- Sheet slides down with spring curve
- Backdrop fades out
- Takes ~300ms to fully dismiss

### No Additional Interactions

The sheet intentionally has **no links, buttons, or tappable elements** within the content area. This design choice:
- Keeps focus on reading information
- Prevents navigation confusion (user knows they're in a modal)
- Simplifies implementation (no nested interaction states)
- Matches user expectation for info dialogs

If a user wants to learn more, they must:
1. Close this sheet
2. Return to Business Profile
3. Use other actions (call restaurant, visit website, etc.)

---

## Design Rationale

### Why a Bottom Sheet?

**Alternatives considered:**
1. **Full-page modal** — Too heavy for small amount of content
2. **Tooltip/popover** — Too small for multi-line descriptions
3. **Inline expansion** — Would disrupt Business Profile page layout
4. **New page** — Adds navigation stack complexity for simple info

**Why bottom sheet wins:**
- **Native mobile pattern** — Users expect quick info in bottom sheets
- **Quick dismiss** — Easy to swipe away or tap outside
- **Contextual** — Remains visually connected to Business Profile page
- **No state pollution** — Doesn't add to browser history or nav stack

### Why 50% Height?

**Height options:**
- 30% — Too cramped, forces scroll for all content
- 50% — Comfortable reading space, minimal scroll
- 70% — Feels like full page, loses "quick reference" feel
- Dynamic — Complex to implement, can cause layout shift

**50% strikes the balance:**
- Large enough to show title + 3-4 lines of text without scroll
- Small enough to feel temporary and dismissible
- Consistent with other info sheets in the app
- Works across phone and tablet viewports

### Why Predefined Facility Info?

**Alternative approaches:**
1. **Database-driven descriptions** — Each restaurant provides custom text
2. **Generic placeholders** — All facilities show same generic message
3. **Predefined dictionary** — Central mapping from label to description (current approach)
4. **No detail view** — Users see only chip labels, no expansion

**Why predefined dictionary:**
- **Consistency** — All restaurants describe "Morgenmad" the same way
- **Quality control** — Descriptions are well-written, not user-generated
- **Simplicity** — No need for restaurants to write descriptions
- **Fallback safety** — Unknown facilities still show something useful

**Trade-off accepted:**
- Descriptions are generic, not restaurant-specific
- Example: "Vi serverer morgenmad..." is identical for all restaurants with "Morgenmad"
- This is acceptable because facility chips themselves are already standardized

**Future enhancement:**
If restaurants want custom facility descriptions, the data model would need:
```jsx
facility: {
  l: "Morgenmad",
  i: "breakfast",
  desc: "Custom description from restaurant" // Added field
}
```
Then component would prioritize `facility.desc` over `facilityInfo` dictionary.

### Why No Links or CTAs?

**Temptation to add:**
- "Book a table" button
- "See menu" link
- "Call about this" action
- External link to facility details page

**Why kept simple:**
- **Single responsibility** — This component displays info, not actions
- **Action centralization** — All actions happen from Business Profile page
- **Cognitive load** — User opened sheet to read, not to navigate
- **Dismissal clarity** — User knows closing sheet returns them to profile

**Where actions belong:**
- Booking button → Business Profile page top section
- Menu link → Business Profile page "Vis hele menuen" action
- Call button → Business Profile page contact section
- Website link → Business Profile page contact section

### Why Title = Facility Label?

```jsx
title: "Udendørs siddepladser",
```

The title repeats the facility label from the chip. This might seem redundant, but:

**Benefits:**
- **Confirmation** — User knows they tapped the right info icon
- **Context** — If user scrolls, title remains visible
- **Accessibility** — Screen reader announces what facility is being described
- **Consistency** — All bottom sheets have a title

**Alternative:**
Title could be different, like:
- "Udendørs siddepladser" → "Om vores udeservering"
- "Morgenmad" → "Morgenmadstilbud"

But this adds complexity without clear benefit. The label already conveys what the facility is.

### Why Medium Gray for Description?

**Color choice:**
```jsx
color: "#555555"
```

**Alternatives:**
- `#0f0f0f` — Same as title (too much visual weight)
- `#999999` — Too light, reduces readability
- `#333333` — Darker, but doesn't differentiate from title enough
- `#555555` — Current choice

**Rationale:**
- **Hierarchy** — Clearly secondary to title without being faint
- **Readability** — Passes WCAG AA contrast ratio on white (7.4:1)
- **Consistency** — Used for secondary text throughout JourneyMate
- **Comfortable reading** — Not too dark (straining) or too light (squinting)

### Why Inline Styles Instead of Classes?

```jsx
<p style={{ fontSize: 14, fontWeight: 400, ... }}>
```

**Alternatives:**
1. **CSS classes** — External stylesheet with `.facility-description`
2. **Styled components** — CSS-in-JS library
3. **Inline styles** — Current approach

**Why inline styles:**
- **Simplicity** — No build step required for JSX reference files
- **Colocation** — Style and structure visible together
- **No naming** — No need to invent class names
- **JSX consistency** — All JourneyMate JSX files use inline styles

**Trade-off:**
- Less DRY (styles repeated if component reused)
- No pseudo-selectors (`:hover`, `:focus`)
- Larger component file size

These trade-offs are acceptable because:
- This is design reference, not production code
- Component is simple with few styles
- No interactive states requiring pseudo-selectors

### Why No Loading State?

**No loading indicators because:**
1. Content is passed as a prop (already available)
2. No API calls or async operations
3. Opening sheet is instant (no network delay)
4. Facility info is predefined (not fetched)

**When loading would be needed:**
If descriptions were fetched from API:
```jsx
const [loading, setLoading] = useState(false);

useEffect(() => {
  if (facility) {
    setLoading(true);
    fetchFacilityDetails(facility.l)
      .then(data => setInfo(data))
      .finally(() => setLoading(false));
  }
}, [facility]);

if (loading) return <Spinner />;
```

Current design avoids this complexity by keeping data client-side.

### Why No Close Button in Content?

**BottomSheet component provides:**
- Close button (X) in top-right
- Backdrop tap to close
- Swipe down to close

**No "Done" or "Close" button at bottom because:**
- **Redundant** — Three dismissal methods already exist
- **Scroll issue** — Button at bottom requires scroll on small screens
- **Visual clutter** — Adds unnecessary UI element
- **Non-standard** — iOS/Android info sheets don't have bottom buttons

**User expectation:**
Mobile users know to:
- Swipe down on bottom sheets
- Tap outside modal areas
- Tap X button in corner

No explicit "Done" button needed.

---

## Accessibility Considerations

### Semantic HTML

**Heading level:**
```jsx
<h3>
```
- Appropriate level for modal title nested in page context
- Screen readers announce as heading, allowing navigation
- Not `<div>` with visual styling alone

**Paragraph:**
```jsx
<p>
```
- Semantic paragraph element for body text
- Screen readers read with appropriate pauses
- Not `<div>` or `<span>` for text content

### Keyboard Navigation

**Handled by BottomSheet component:**
- Tab trap (focus stays within sheet while open)
- Escape key closes sheet
- Focus returns to triggering element on close

**No focusable elements in content:**
Since there are no interactive elements (buttons, links), focus remains on the close button provided by BottomSheet.

### Screen Reader Support

**Component structure:**
```
[Modal]
  [Heading level 3] "Udendørs siddepladser"
  [Paragraph] "Vi har udendørs siddepladser med udsigt..."
```

**Screen reader experience:**
1. User taps info icon
2. Screen reader announces: "Modal opened"
3. Focus moves to close button
4. User can navigate to heading and paragraph
5. User closes modal
6. Screen reader announces: "Modal closed"
7. Focus returns to info icon

**ARIA attributes:**
Not explicitly defined in this component. The BottomSheet wrapper handles:
- `role="dialog"`
- `aria-modal="true"`
- `aria-labelledby` (points to title)
- `aria-describedby` (points to content)

### Color Contrast

**Title contrast:**
- Color: #0f0f0f on #ffffff
- Ratio: 19.6:1
- Passes WCAG AAA (requires 7:1)

**Description contrast:**
- Color: #555555 on #ffffff
- Ratio: 7.4:1
- Passes WCAG AA (requires 4.5:1)

All text is highly readable for users with low vision.

### Touch Target Size

**Dismissal methods:**
- Close button: 44×44px minimum (standard for BottomSheet)
- Backdrop: Full-screen tap target
- Swipe down: Full sheet width

No additional touch targets within content (no links/buttons).

### Text Scaling

**Fixed pixel sizes:**
```jsx
fontSize: 20  // Title
fontSize: 14  // Description
```

**Considerations:**
- Pixel sizes don't scale with OS text size settings
- User who increases system font size won't see larger text

**Mitigation:**
- Font sizes are already large (20px, 14px)
- Line height (20px) provides comfortable spacing even if text scales
- Bottom sheet allows vertical scroll for long descriptions

**Future enhancement:**
Use relative units:
```jsx
fontSize: "1.25rem"  // Title (20px default)
fontSize: "0.875rem" // Description (14px default)
```
This would respect user's font size preferences.

### Motion Sensitivity

**Bottom sheet animation:**
- Slide-up transition with spring curve
- ~300ms duration

**Considerations:**
- Some users experience discomfort from animations
- No way to disable in current design

**Future enhancement:**
Respect `prefers-reduced-motion`:
```jsx
@media (prefers-reduced-motion: reduce) {
  // Instant show/hide instead of slide animation
}
```

BottomSheet component would handle this globally.

---

## Conclusion

The Facilities Info Sheet is a minimal, purpose-built component that provides exactly what users need: quick access to detailed facility information without leaving the Business Profile page context. By leveraging the shared BottomSheet component and maintaining extreme simplicity (no actions, no loading, no interactivity beyond dismissal), the design achieves fast rendering, clear focus, and intuitive behavior.

**Key design strengths:**
1. **Instant display** — No loading, no API calls
2. **Clear hierarchy** — Bold title, readable description
3. **Multiple dismissal options** — Swipe, tap, close button
4. **Consistent behavior** — Uses same BottomSheet as other modals
5. **Fallback safety** — Unknown facilities still show useful message
6. **Semantic HTML** — Accessible to screen readers

**Accepted trade-offs:**
1. **Generic descriptions** — All restaurants with "Morgenmad" show identical text
2. **No custom content** — Restaurants can't write their own facility descriptions
3. **No actions** — User must close sheet to access booking/menu/contact features
4. **Fixed pixel sizes** — Text doesn't scale with OS font size settings

**Migration notes for Flutter:**
- Replace `BottomSheet` component with `showModalBottomSheet` + `DraggableScrollableSheet`
- Map `facilityInfo` dictionary to Dart Map or JSON asset
- Use `Text` widgets with `TextStyle` for title and description
- Implement `GestureDetector` or inherit dismissal from modal behavior
- Consider `StreamBuilder` if facility info will be fetched from API in future

**Estimated complexity:**
- **JSX to Flutter:** Low (static content display, no complex logic)
- **Lines of code:** ~50 lines in Flutter (similar to JSX)
- **Testing needs:** Minimal (verify each predefined facility shows correct description)

---

**End of design documentation for FacilitiesInfoSheet component.**
