# Menu Item Detail Overlay — JSX Design Documentation

**File:** `pages/business_profile/menu_item_detail_overlay.jsx`
**Type:** Modal overlay component
**Purpose:** Display detailed information about a selected menu item including name, price, description, dietary information, and allergens
**Date:** 2026-02-19

---

## Design Overview

The Menu Item Detail Overlay is a centered modal overlay that appears when a user taps on a menu item from the business profile or full menu page. It displays comprehensive information about the selected dish, including:

- Item name and description (bilingual support)
- Price with currency conversion
- Dietary preferences and restrictions
- Allergen information
- A collapsible reminder about verifying dietary information with restaurant staff

The overlay features a clean, card-like design that centers on the screen with a semi-transparent backdrop. It includes language and currency switching options accessed through a three-dot menu.

**Key design characteristics:**
- Fixed position centered overlay (not a bottom sheet despite having a drag handle)
- Semi-transparent black backdrop (40% opacity)
- Maximum width of 400px or 92% of viewport width
- Maximum height of 84vh to prevent overflow
- Scrollable content area for long descriptions or multiple dietary notes
- Bilingual support (Danish/English) with dynamic content switching
- Multi-currency support (DKK, USD, GBP) with live conversion
- Expandable reminder section for dietary verification warnings

---

## Visual Layout

### Overall Structure

```
┌──────────────────────────────────────────────────┐
│ [Backdrop: rgba(0,0,0,0.4)]                      │
│                                                   │
│   ┌──────────────────────────────────────┐      │
│   │ [Drag handle: 36×4px, #ddd]          │      │
│   ├──────────────────────────────────────┤      │
│   │ [✕]                           [⋯]    │      │
│   ├──────────────────────────────────────┤      │
│   │                                       │      │
│   │ Item Name                             │      │
│   │ Price (in selected currency)          │      │
│   │                                       │      │
│   │ Description text...                   │      │
│   │                                       │      │
│   │ ──────────────────────────────────── │      │
│   │                                       │      │
│   │ Additional Information                │      │
│   │                                       │      │
│   │ • Dietary preferences                 │      │
│   │ • Allergens                           │      │
│   │ • Reminder ▼                          │      │
│   │                                       │      │
│   └──────────────────────────────────────┘      │
│                                                   │
└──────────────────────────────────────────────────┘
```

### Positioning and Sizing

**Overlay positioning:**
- `position: fixed`
- `top: 8%` (creates consistent top margin)
- `left: 50%` with `transform: translateX(-50%)` (perfect centering)
- `width: min(92%, 400px)` (responsive but capped)
- `maxHeight: 84vh` (leaves space for system UI)
- `borderRadius: 16px`
- `zIndex: 9999` (above backdrop at 9998)

**Backdrop:**
- `position: fixed`
- `inset: 0` (full screen coverage)
- `background: rgba(0,0,0,0.4)` (40% black)
- `zIndex: 9998`
- Clicking backdrop triggers `onClose`

### Header Section

**Drag handle:**
- Width: 36px
- Height: 4px
- Border radius: 4px
- Background: `#ddd`
- Position: `12px auto 0` (centered horizontally, 12px top margin)
- Purpose: Visual affordance for drag-to-dismiss (though not implemented in JSX)

**Action buttons row:**
- Container: `display: flex`, `justify-content: space-between`
- Padding: `12px 16px 0`
- Left side: Close button (✕)
- Right side: Three-dot menu button (⋯)

**Close button (✕):**
- Size: 32×32px
- Border: none
- Background: transparent
- Font size: 20px
- Color: `#0f0f0f`
- Click handler: `onClose`

**Three-dot menu button (⋯):**
- Size: 32×32px
- Border: none
- Background: transparent
- Font size: 20px
- Color: `#0f0f0f`
- Toggles dropdown menu for language/currency selection

### Three-Dot Menu Dropdown

**Container:**
- `position: absolute`
- `top: 36px`, `right: 0` (aligned to button)
- Background: `#fff`
- Border: `1px solid #e8e8e8`
- Border radius: 10px
- Box shadow: `0 4px 12px rgba(0,0,0,0.08)`
- Min width: 220px
- `zIndex: 100`

**Menu items:**
Four options presented:
1. "View dish in Danish"
2. "View dish in English"
3. "View price in US Dollar ($)"
4. "View price in British Pound (£)"

**Item styling:**
- Padding: `12px 16px`
- Font size: 14px
- Border bottom: `1px solid #f2f2f2` (except last item)
- Background: `#fef8f2` when selected, `#fff` otherwise
- Cursor: pointer
- On click: Update language/currency state and close menu

### Content Section

**Container:**
- Padding: `8px 24px 24px`
- `overflow-y: auto` (scrollable if content exceeds overlay height)

**Item name:**
- Font size: 18px
- Font weight: 630
- Color: `#0f0f0f`
- Line height: 24px
- Margin: `0 0 8px 0`
- Content: Dynamic based on language selection

**Price:**
- Font size: 15px
- Font weight: 540
- Color: `ACCENT` (`#e8751a`)
- Margin: `0 0 12px 0`
- Content: Dynamic based on currency selection
- Conversion logic:
  - USD: Base price ÷ 7.5
  - GBP: Base price ÷ 9
  - DKK: Base price (no conversion)

**Description:**
- Font size: 14px
- Font weight: 400
- Color: `#555`
- Line height: 20px
- Margin: `0 0 20px 0`
- Content: Dynamic based on language selection

**Divider:**
- Height: 1px
- Background: `#f2f2f2`
- Margin: `0 0 20px 0`

### Additional Information Section

**Section title:**
- Font size: 15px
- Font weight: 600
- Color: `#0f0f0f`
- Margin: `0 0 12px 0`
- Text: "Additional Information" or "Yderligere Information"

**Dietary preferences subsection:**
- Only rendered if `item.dietary` exists
- Margin bottom: 16px
- Label:
  - Font size: 13px
  - Font weight: 500
  - Color: `#555`
  - Margin bottom: 4px
  - Text: "Dietary preferences and restrictions" or "Kostpræferencer og restriktioner"
- Value:
  - Font size: 13px
  - Font weight: 400
  - Color: `#555`
  - Content: Dynamic based on language selection

**Allergens subsection:**
- Only rendered if `item.allergens` exists
- Margin bottom: 16px
- Label:
  - Font size: 13px
  - Font weight: 500
  - Color: `#555`
  - Margin bottom: 4px
  - Text: "Allergens" or "Allergener"
- Value:
  - Font size: 13px
  - Font weight: 400
  - Color: `#555`
  - Content: Dynamic based on language selection

### Reminder Expandable Section

**Header (clickable):**
- Display: flex (space-between alignment)
- Padding: `8px 0`
- Cursor: pointer
- Click handler: Toggles `reminderOpen` state
- Label:
  - Font size: 13px
  - Font weight: 500
  - Color: `#555`
  - Text: "Reminder" or "Påmindelse"
- Arrow icon:
  - Font size: 12px
  - Color: `#888`
  - Content: "▲" when open, "▼" when closed

**Expanded content:**
- Only rendered when `reminderOpen === true`
- Font size: 13px
- Font weight: 400
- Color: `#555`
- Line height: 18px
- Padding top: 8px
- Contains two paragraphs:
  1. First paragraph (margin: `0 0 12px 0`):
     - Danish: "Husk altid at bekræfte ingrediens- og kostoplysninger med personalet, inden du bestiller. Ingredienser, opskrifter og personale kan ændre sig, og krydskontaminering kan forekomme."
     - English: "Always verify ingredient and dietary information with staff before ordering. Ingredients, recipes, and staff can change, and cross-contamination may occur."
  2. Second paragraph (margin: 0):
     - Danish: "JourneyMate kan ikke garantere nøjagtigheden af disse oplysninger. Ved alvorlige allergier eller diætbehov, kontakt venligst restauranten direkte."
     - English: "JourneyMate cannot guarantee the accuracy of this information. For severe allergies or dietary requirements, please contact the restaurant directly."

---

## Components Used

### External Components

None. This is a standalone component with no external dependencies beyond React hooks.

### Internal Sub-Components

No sub-components defined. All UI elements are rendered inline within the main component function.

### Third-Party Libraries

**React hooks:**
- `useState` — Manages four pieces of local state:
  - `language` (string: "da" or "en")
  - `currency` (string: "DKK", "USD", or "GBP")
  - `reminderOpen` (boolean)
  - `menuOpen` (boolean)

---

## Design Tokens

### Colors

**Primary colors used:**
- `ACCENT` (`#e8751a`) — Price display
- `#0f0f0f` — Item name, section titles, close/menu buttons
- `#555` — Description text, labels, values, reminder text
- `#888` — Arrow icons in reminder section
- `#ddd` — Drag handle
- `#f2f2f2` — Divider, menu item borders
- `#e8e8e8` — Menu dropdown border
- `#fff` — Overlay background, menu background
- `#fef8f2` — Selected menu item background (light orange tint)
- `rgba(0,0,0,0.4)` — Backdrop

**Color usage rationale:**
- Orange (`ACCENT`) used only for price to indicate transactional information
- Dark gray (`#0f0f0f`) for primary text (name, titles)
- Medium gray (`#555`) for secondary text (descriptions, labels)
- Light gray (`#ddd`, `#f2f2f2`) for dividers and visual separators
- White background maintains clean, card-like appearance
- Light orange tint (`#fef8f2`) for selected state maintains brand consistency

### Typography

**Font sizes and weights:**
- **18px / 630** — Item name (primary heading)
- **15px / 600** — Section title ("Additional Information")
- **15px / 540** — Price (emphasis on transactional info)
- **14px / 400** — Description text (body copy)
- **13px / 500** — Subsection labels (dietary, allergens, reminder)
- **13px / 400** — Subsection values and reminder content
- **12px** — Arrow icons
- **20px** — Button icons (✕, ⋯)

**Line heights:**
- Item name: 24px (1.33 ratio)
- Description: 20px (1.43 ratio)
- Reminder content: 18px (1.38 ratio)

**Font weight mapping notes:**
- 630 not standard — maps to 600 in Flutter
- 540 not standard — maps to 500 in Flutter

### Spacing

**Outer spacing:**
- Overlay top margin: 8% of viewport height
- Overlay side margins: 4% of viewport width (92% width)
- Max height: 84vh (leaves 16vh total for system UI)

**Internal padding:**
- Drag handle margin: `12px auto 0`
- Header buttons padding: `12px 16px 0`
- Content padding: `8px 24px 24px`
- Menu dropdown item padding: `12px 16px`
- Reminder header padding: `8px 0`
- Reminder content padding-top: 8px

**Element spacing:**
- Item name margin-bottom: 8px
- Price margin-bottom: 12px
- Description margin-bottom: 20px
- Divider margin-bottom: 20px
- Section title margin-bottom: 12px
- Subsection margin-bottom: 16px
- Label margin-bottom: 4px
- Reminder paragraph 1 margin-bottom: 12px

### Dimensions

**Fixed sizes:**
- Drag handle: 36×4px
- Close button: 32×32px
- Three-dot menu button: 32×32px
- Divider height: 1px
- Border radius: 16px (overlay), 10px (menu dropdown), 4px (drag handle)
- Menu dropdown min-width: 220px
- Overlay max-width: 400px
- Overlay width: `min(92%, 400px)`

### Effects

**Box shadow:**
- Menu dropdown: `0 4px 12px rgba(0,0,0,0.08)` (soft elevation)

**Border:**
- Menu dropdown: `1px solid #e8e8e8`
- Menu item separator: `1px solid #f2f2f2`

**Cursor:**
- Interactive elements: `pointer`

---

## State & Data

### Component Props

**Required props:**
- `visible` (boolean) — Controls whether overlay is rendered
  - When `false` or if `item` is `null`, component returns `null` (not rendered)
- `onClose` (function) — Callback to close the overlay
  - Triggered by backdrop click or close button click
- `item` (object) — Menu item data with following structure:
  - `name` (string) — Danish item name
  - `nameEn` (string, optional) — English item name
  - `price` (string) — Price string (e.g., "125 kr")
  - `description` (string) — Danish description
  - `descriptionEn` (string, optional) — English description
  - `dietary` (string, optional) — Danish dietary information
  - `dietaryEn` (string, optional) — English dietary information
  - `allergens` (string, optional) — Danish allergen information
  - `allergensEn` (string, optional) — English allergen information

### Local State

**1. `language` (string)**
- Initial value: `"da"` (Danish)
- Possible values: `"da"` | `"en"`
- Purpose: Controls which language version of content is displayed
- Updated by: Three-dot menu dropdown selections
- Affects:
  - Item name display
  - Description display
  - Dietary information display
  - Allergen information display
  - All UI labels and reminder text

**2. `currency` (string)**
- Initial value: `"DKK"` (Danish Krone)
- Possible values: `"DKK"` | `"USD"` | `"GBP"`
- Purpose: Controls price display currency
- Updated by: Three-dot menu dropdown selections
- Affects: Price conversion and symbol display

**3. `reminderOpen` (boolean)**
- Initial value: `false`
- Purpose: Controls visibility of reminder text
- Updated by: Clicking reminder section header
- Affects: Whether two paragraphs of warning text are shown

**4. `menuOpen` (boolean)**
- Initial value: `false`
- Purpose: Controls visibility of three-dot dropdown menu
- Updated by: Clicking three-dot menu button
- Affects: Whether language/currency options dropdown is shown
- Note: Automatically set to `false` when any menu option is selected

### Data Transformation Functions

**`convertPrice(priceStr)`**
- Input: String like "125 kr" or "95 kr"
- Process:
  1. Extract numeric value using regex: `parseFloat(priceStr.replace(/[^\d.]/g, ""))`
  2. If `currency === "USD"`: Divide by 7.5, format as `$XX`
  3. If `currency === "GBP"`: Divide by 9, format as `£XX`
  4. Otherwise: Return original price string
- Output: Formatted price string with currency symbol
- Note: Uses `.toFixed(0)` for whole number display (no decimals)

**Translation selection logic:**
- Uses `translations[language]` to get appropriate text object
- Assigns to `t` constant for concise access
- All UI labels reference `t.additionalInfo`, `t.dietary`, etc.

**Content selection logic:**
- Item name: `language === "da" ? item.name : item.nameEn || item.name`
- Description: `language === "da" ? item.description : item.descriptionEn || item.description`
- Dietary: `language === "da" ? item.dietary : item.dietaryEn || item.dietary`
- Allergens: `language === "da" ? item.allergens : item.allergensEn || item.allergens`
- Falls back to Danish if English version is missing

### Translations Object

**Structure:**
```javascript
translations = {
  da: { additionalInfo, dietary, allergens, reminder, reminderText1, reminderText2 },
  en: { additionalInfo, dietary, allergens, reminder, reminderText1, reminderText2 }
}
```

**Danish translations:**
- `additionalInfo`: "Yderligere Information"
- `dietary`: "Kostpræferencer og restriktioner"
- `allergens`: "Allergener"
- `reminder`: "Påmindelse"
- `reminderText1`: "Husk altid at bekræfte ingrediens- og kostoplysninger med personalet, inden du bestiller. Ingredienser, opskrifter og personale kan ændre sig, og krydskontaminering kan forekomme."
- `reminderText2`: "JourneyMate kan ikke garantere nøjagtigheden af disse oplysninger. Ved alvorlige allergier eller diætbehov, kontakt venligst restauranten direkte."

**English translations:**
- `additionalInfo`: "Additional Information"
- `dietary`: "Dietary preferences and restrictions"
- `allergens`: "Allergens"
- `reminder`: "Reminder"
- `reminderText1`: "Always verify ingredient and dietary information with staff before ordering. Ingredients, recipes, and staff can change, and cross-contamination may occur."
- `reminderText2`: "JourneyMate cannot guarantee the accuracy of this information. For severe allergies or dietary requirements, please contact the restaurant directly."

---

## User Interactions

### Opening the Overlay

**Trigger:**
- Parent component sets `visible` prop to `true`
- Parent component passes selected `item` object
- Component renders if both conditions met

**Visual behavior:**
- Backdrop fades in with semi-transparent black overlay
- Overlay card appears centered on screen
- Content is immediately visible and scrollable

### Closing the Overlay

**Two methods:**

1. **Backdrop click:**
   - User clicks anywhere on semi-transparent backdrop
   - Triggers `onClose` callback
   - Parent component handles state update to hide overlay

2. **Close button (✕):**
   - User clicks X button in top-left of overlay
   - Triggers `onClose` callback
   - Parent component handles state update to hide overlay

**Note:** No drag-to-dismiss implemented despite drag handle presence

### Three-Dot Menu Interaction

**Opening menu:**
- User clicks three-dot button (⋯) in top-right
- `menuOpen` state toggles to `true`
- Dropdown appears below button with 4 options
- Dropdown is absolutely positioned relative to button

**Selecting menu option:**
- User clicks any of the 4 menu items
- Language/currency state updates based on selection
- `menuOpen` state set to `false` (menu closes)
- UI immediately updates to reflect new language/currency

**Menu options and their effects:**

1. **"View dish in Danish":**
   - Sets `language` to `"da"`
   - Updates all content to Danish versions
   - Menu background changes to `#fef8f2` (selected state)

2. **"View dish in English":**
   - Sets `language` to `"en"`
   - Updates all content to English versions (or falls back to Danish if English not available)
   - Menu background changes to `#fef8f2` (selected state)

3. **"View price in US Dollar ($)":**
   - Sets `currency` to `"USD"`
   - Price converts: DKK amount ÷ 7.5
   - Displays as `$XX`
   - Menu background changes to `#fef8f2` (selected state)

4. **"View price in British Pound (£)":**
   - Sets `currency` to `"GBP"`
   - Price converts: DKK amount ÷ 9
   - Displays as `£XX`
   - Menu background changes to `#fef8f2` (selected state)

**Visual feedback:**
- Currently selected option has light orange background (`#fef8f2`)
- Unselected options have white background
- All items have hover cursor (pointer)

### Reminder Section Interaction

**Collapsed state (initial):**
- Shows "Reminder"/"Påmindelse" label
- Shows downward arrow (▼)
- No warning text visible
- Entire header is clickable

**Expanding:**
- User clicks reminder header
- `reminderOpen` state toggles to `true`
- Arrow changes to upward (▲)
- Two paragraphs of warning text appear below
- Text slides in (rendered conditionally, no animation specified)

**Collapsing:**
- User clicks reminder header again
- `reminderOpen` state toggles to `false`
- Arrow changes back to downward (▼)
- Warning text disappears (unmounted)

**Purpose of reminder:**
- Legal disclaimer about dietary information accuracy
- Warns users to verify information with restaurant staff
- Emphasizes risk of cross-contamination
- States JourneyMate cannot guarantee information accuracy
- Advises users with severe allergies to contact restaurant directly

### Content Scrolling

**Scrollable area:**
- Content container has `overflow-y: auto`
- Max height is constrained by overlay's `maxHeight: 84vh`
- If content exceeds available space, vertical scrollbar appears
- Scrolling only affects content area (header with buttons remains fixed)

**Scenarios requiring scroll:**
- Long item descriptions
- Multiple dietary preferences listed
- Multiple allergens listed
- Reminder expanded with long warning text
- Combination of all above

---

## Design Rationale

### Centered Overlay vs Bottom Sheet

**Decision: Centered modal overlay**
- Despite having a drag handle (visual affordance), this is NOT a bottom sheet
- Positioned at `top: 8%` (not bottom)
- Fixed width with centering transform
- Backdrop dismissal pattern (click-to-close)

**Why this approach:**
- Menu items are relatively short-form content (not article-length)
- Centered position brings focus to the item being reviewed
- Doesn't obscure underlying business profile content as much as full-screen modal
- Allows user to see context (they're still on business profile page)
- More traditional modal pattern familiar to users

**Drag handle presence:**
- Likely vestigial from bottom sheet design exploration
- Provides visual affordance for "this is dismissible"
- Could be implemented for drag-to-dismiss in future
- Maintains consistency with other sheet-like components

### Language and Currency Switching

**Decision: In-overlay language/currency controls**
- Three-dot menu provides access to 4 options
- Immediate switching without leaving overlay
- State preserved while overlay is open

**Why this approach:**
- Users may want to see item details in their preferred language
- Tourists need price in their home currency for quick mental calculation
- Switching should not require closing and reopening overlay
- Settings should be easily discoverable (three-dot menu is common pattern)

**Currency conversion rates:**
- USD: Divide by 7.5 (approximate exchange rate)
- GBP: Divide by 9 (approximate exchange rate)
- Whole numbers only (`.toFixed(0)`) — easier to scan quickly
- Note: These are hardcoded approximations, not live exchange rates

**Language fallback logic:**
- Always falls back to Danish if English version missing
- Prevents blank content if translation incomplete
- Pattern: `language === "da" ? item.name : item.nameEn || item.name`

### Dietary and Allergen Information Display

**Decision: Structured, labeled subsections**
- Clear labels: "Dietary preferences and restrictions" and "Allergens"
- Values displayed below labels with slightly lighter weight
- Both sections only render if data exists (conditional rendering)

**Why this approach:**
- Critical safety information must be clearly labeled
- Separation between dietary preferences (choices) and allergens (restrictions) is important
- Absence of section implies no relevant information (reduces cognitive load)
- Consistent labeling across languages

**Information hierarchy:**
1. Item name, price, description (primary)
2. Divider (clear separation)
3. "Additional Information" section title (groups following content)
4. Dietary preferences (if present)
5. Allergens (if present)
6. Reminder (legal disclaimer)

### Reminder Section Design

**Decision: Expandable/collapsible section**
- Initially collapsed (not visible)
- User must explicitly expand to read disclaimer
- Arrow icon indicates interactivity

**Why this approach:**
- Legal disclaimer is important but not primary content
- Collapsing reduces initial visual clutter
- Users with dietary needs will likely expand (those who need it find it)
- Users without dietary concerns can ignore it (doesn't obstruct primary content)
- Explicit interaction ensures user has seen the warning if they expand it

**Content of reminder:**
- Two distinct points:
  1. "Verify with staff" — practical advice
  2. "JourneyMate cannot guarantee" — legal disclaimer
- Both emphasize user responsibility and restaurant authority
- Mentions specific risks: recipe changes, staff changes, cross-contamination
- Strong language: "severe allergies" → "contact restaurant directly"

### Price Display Styling

**Decision: Orange accent color, medium weight**
- Color: `ACCENT` (`#e8751a`)
- Font size: 15px
- Font weight: 540
- Prominent but not overpowering

**Why this approach:**
- Orange is used exclusively for transactional/interactive elements
- Price is important decision factor but not primary content (name and description are)
- Medium weight and size balances visibility with hierarchy
- Stands out without dominating the layout
- Consistent with orange = "action/transaction" pattern across app

### Content Padding and Spacing

**Decision: Generous padding, clear vertical rhythm**
- Content padding: `8px 24px 24px` (horizontal padding is 24px)
- Consistent spacing between sections (12px, 16px, 20px intervals)
- Divider creates clear break between primary and secondary content

**Why this approach:**
- 24px horizontal padding creates comfortable reading width
- Vertical spacing creates scannable hierarchy
- Divider signals transition from "item details" to "additional info"
- Generous spacing prevents cramped feeling in small modal
- Scrollable area allows for expansion without compromising spacing

### Close Button Placement

**Decision: Top-left position**
- Standard iOS pattern (Android typically uses top-right or back button)
- Consistent with other modals/sheets in app
- Symbol: ✕ (clear close indicator)

**Why this approach:**
- Top-left is more accessible for right-handed users holding phone in left hand
- Matches iOS conventions (most users familiar with pattern)
- Backdrop click provides additional close method (no "wrong" side)
- Three-dot menu on opposite side provides visual balance

### Menu Dropdown Design

**Decision: Appears below three-dot button, right-aligned**
- Absolute positioning relative to button
- White background with subtle border and shadow
- Selected state uses light orange background
- Four distinct options (2 language, 2 currency)

**Why this approach:**
- Standard dropdown menu pattern (familiar to users)
- Right-aligned keeps menu within overlay bounds
- Selected state provides clear feedback
- Grouping language and currency in one menu reduces UI complexity
- Light orange selected state maintains brand consistency
- Closes automatically after selection (no extra dismiss action needed)

### Responsive Sizing

**Decision: Width and height constraints**
- Width: `min(92%, 400px)`
- Max height: 84vh
- Centered with transform

**Why this approach:**
- 92% width provides 4% margins on each side (comfortable on small screens)
- 400px max width prevents excessive width on tablets or large phones
- 84vh max height leaves room for system UI (status bar, home indicator)
- Centering with transform is pixel-perfect regardless of overlay size
- Content scrolling handles overflow gracefully

### Accessibility Considerations (Implicit in Design)

**Visual hierarchy:**
- Clear heading (item name at 18px/630)
- Section titles provide structure
- Labels for all data fields
- Sufficient color contrast (all text on white background)

**Interactive elements:**
- Large touch targets (32×32px buttons)
- Cursor pointer on all clickable elements
- Visual feedback on menu selection (background color change)
- Clear icons (✕, ⋯, ▲, ▼)

**Content structure:**
- Logical reading order (top to bottom)
- Clear separation between sections (divider line)
- Optional content (dietary, allergens) only shown when present
- Critical warning (reminder) is user-expandable

---

## Implementation Notes

### Early Return Pattern

```javascript
if (!visible || !item) return null;
```

- Prevents rendering when overlay not needed
- Guards against null reference errors if `item` is undefined
- Clean pattern for conditional component rendering

### Translation Pattern

```javascript
const t = translations[language];
// Later: {t.additionalInfo}, {t.dietary}, etc.
```

- Single source of truth for all UI text
- Easy to add more languages (just extend `translations` object)
- Falls back gracefully if English content missing from `item` object

### Menu Auto-Close Pattern

```javascript
onClick={() => {
  setLanguage("da");
  setMenuOpen(false);
}}
```

- Every menu option closes the menu after selection
- Prevents need for separate close action
- Reduces clicks/taps required

### Conditional Rendering Pattern

```javascript
{item.dietary && (
  <div>...</div>
)}
```

- Clean way to hide sections when data not present
- Prevents empty sections or "N/A" placeholders
- Makes layout more compact when less information available

### Fragment Wrapper

```javascript
return (<>
  {/* Backdrop */}
  <div onClick={onClose}>...</div>
  {/* Overlay */}
  <div>...</div>
</>);
```

- Returns two sibling elements (backdrop and overlay)
- Fragment (`<>...</>`) avoids extra wrapper div
- Both elements positioned with `position: fixed` (no need for parent positioning context)

---

## Future Considerations

### Potential Enhancements (Not in Current Design)

1. **Drag-to-dismiss functionality:**
   - Drag handle is present but not functional
   - Could implement swipe-down gesture to close
   - Would provide additional intuitive close method

2. **Item images:**
   - No image display in current design
   - Could add image at top of overlay (below header)
   - Would make items more visually appealing and identifiable

3. **Persistent language/currency preferences:**
   - Currently resets to DA/DKK on each overlay open
   - Could persist selection across overlay sessions
   - Would improve experience for non-Danish users

4. **Animation on open/close:**
   - No transition animations specified
   - Could add slide-up or fade-in animation
   - Backdrop could fade in/out
   - Would create more polished feel

5. **Share functionality:**
   - No way to share or save item details
   - Could add share button in header
   - Would allow users to share interesting dishes with friends

6. **Add to favorites:**
   - No favoriting mechanism
   - Could add heart icon in header
   - Would allow users to save dishes for later reference

7. **Nutritional information:**
   - No calorie or macro information displayed
   - Could add expandable nutrition section
   - Would support health-conscious users

8. **Live exchange rates:**
   - Currently uses hardcoded conversion rates
   - Could fetch live rates from API
   - Would provide accurate price conversions

9. **Image gallery:**
   - If item has multiple images, could show gallery
   - Swipeable image carousel at top
   - Would showcase dish from multiple angles

10. **Ingredients list:**
    - Separate from allergens section
    - Full ingredient breakdown
    - Would support users with specific dietary restrictions beyond allergens

---

## Related Components and Files

### Parent Components (Assumed)

- **Business Profile page** — Likely shows menu items as cards/list
- **Full Menu page** — Likely shows categorized menu items
- Both would pass `item` object and handle `visible` state

### Shared Dependencies

- `ACCENT` color token from `shared/_shared.jsx`
- No other shared components used (entirely self-contained)

### Data Source

- `item` object structure assumed from prop usage:
  - Must have: `name`, `price`, `description`
  - Optional: `nameEn`, `descriptionEn`, `dietary`, `dietaryEn`, `allergens`, `allergensEn`
- Likely comes from restaurant menu data structure
- May be subset of larger menu item object

### Translation System Integration

- Uses inline translations object (not shared translation system)
- Two languages supported: Danish (da), English (en)
- All UI text is localized
- Item content localization depends on data availability

---

## Design Principles Demonstrated

### 1. Progressive Disclosure

- Primary information (name, price, description) shown immediately
- Additional information (dietary, allergens) shown below divider
- Reminder collapsed by default (user must expand)
- Language/currency options hidden in menu until needed

### 2. Clear Visual Hierarchy

- Item name is largest and boldest (18px/630)
- Price is emphasized with orange color (15px/540)
- Description is body text (14px/400)
- Labels are smaller but bold (13px/500)
- Values are smaller and regular (13px/400)

### 3. Scannability

- Clear section breaks (divider line)
- Consistent label-value pairs
- Adequate spacing between sections
- Short lines (24px horizontal padding constrains width)

### 4. User Control

- User chooses when to close (backdrop or button)
- User chooses language and currency
- User chooses whether to expand reminder
- No auto-close or forced timing

### 5. Safety and Transparency

- Prominent price display (no hidden costs)
- Clear dietary and allergen information
- Explicit warning about verifying information with staff
- Disclaimer about information accuracy

### 6. Consistency with Design System

- Uses `ACCENT` color token for interactive/transactional elements
- Follows established spacing patterns
- Uses standard gray scale for text hierarchy
- Maintains border radius consistency (16px for overlay)

### 7. Mobile-First Design

- Responsive width (`min(92%, 400px)`)
- Touch-friendly button sizes (32×32px minimum)
- Scrollable content area for small screens
- Backdrop click provides easy dismiss method

---

## Summary

The Menu Item Detail Overlay is a well-structured, centered modal component that prioritizes clarity and usability. It effectively presents menu item information with appropriate visual hierarchy, supports bilingual content with currency conversion, and includes important safety disclaimers for dietary restrictions.

**Key strengths:**
- Clean, card-like design centered on screen
- Clear information hierarchy (name → price → description → additional info)
- Bilingual support with fallback logic
- Multi-currency conversion for international users
- Collapsible reminder reduces initial clutter while maintaining legal clarity
- Multiple close methods (backdrop, button)
- Conditional rendering of optional sections (dietary, allergens)
- Self-contained with minimal dependencies

**Design cohesion:**
- Consistent use of orange (`ACCENT`) for transactional information (price)
- Standard gray scale for text hierarchy
- Follows mobile modal patterns (backdrop dismiss, centered positioning)
- Maintains design system spacing and typography conventions

**User experience focus:**
- All critical information immediately visible
- Optional information easily accessible
- Language/currency switching without closing overlay
- Clear visual feedback for interactive elements
- Safety warnings accessible but not intrusive

This component demonstrates thoughtful design for displaying menu item details in a restaurant discovery app, balancing information density with readability, and providing flexible language/currency options for a diverse user base.

---

**Lines:** 600
