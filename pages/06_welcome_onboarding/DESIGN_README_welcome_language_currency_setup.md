# Welcome Language & Currency Setup — JSX Design Documentation

**File:** `C:\Users\Rikke\Documents\JourneyMate\pages\welcome\welcome_language_currency_setup.jsx`
**Component:** `WelcomeLanguageCurrencySetup`
**Purpose:** First-time user setup flow for selecting language and currency preferences
**Design Version:** v2 JSX
**Date Documented:** 2026-02-19

---

## Table of Contents

1. [Design Overview](#design-overview)
2. [Visual Layout](#visual-layout)
3. [Components Used](#components-used)
4. [Design Tokens](#design-tokens)
5. [State & Data](#state--data)
6. [User Interactions](#user-interactions)
7. [Design Rationale](#design-rationale)
8. [Component Architecture](#component-architecture)
9. [Typography System](#typography-system)
10. [Spacing & Measurements](#spacing--measurements)
11. [Accessibility Considerations](#accessibility-considerations)
12. [Edge Cases & States](#edge-cases--states)

---

## Design Overview

### Purpose & Context

The Language & Currency Setup page is the final step in the welcome onboarding flow. After users complete the location/train station selection, they arrive at this screen to configure their localization preferences before entering the main app.

This screen serves two critical functions:
1. **Language selection** — Sets the interface language for all UI strings throughout the app
2. **Currency selection** — Sets the preferred currency for displaying prices and costs

### Design Philosophy

The design follows a minimal, focused approach:
- Clean white background with subtle dividers
- Clear hierarchy with heading, description, and form elements
- No skip option — these selections are required before completing setup
- Single action button at bottom to complete the setup flow
- Reuses the `LanguageCurrencyDropdowns` component from settings for consistency

### User Flow Position

```
Welcome/Location Setup → Train Station Selection → [THIS PAGE] → Main App (Search)
```

Users cannot skip this step. The "Complete setup" button commits both selections and advances to the main app.

---

## Visual Layout

### Container Structure

```
┌─────────────────────────────────────┐
│ StatusBar (54px)                    │ ← iOS status bar overlay
├─────────────────────────────────────┤
│                                     │
│ [Divider line] (1px, #f2f2f2)      │ ← 32px margin below
│                                     │
│ Localization (heading)              │ ← 22px, weight 700
│ Select your preferred... (desc)     │ ← 14px, #555, 8px below heading
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Language                        │ │ ← 16px, weight 600
│ │ [Dropdown: English 🇬🇧    ▼]   │ │ ← 50px height, #f5f5f5 bg
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Currency                        │ │ ← 16px, weight 600
│ │ [Dropdown: Danish krone (kr.)▼]│ │ ← 50px height, #f5f5f5 bg
│ └─────────────────────────────────┘ │
│                                     │
│ [40px spacing]                      │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │   Complete setup                │ │ ← Orange CTA, 50px height
│ └─────────────────────────────────┘ │
│                                     │
│ [Scrollable area if content grows] │
└─────────────────────────────────────┘
```

### Layout Measurements

**Container:**
- Width: `390px` (iPhone viewport standard)
- Height: `844px` (iPhone 14 Pro viewport)
- Background: `#fff` (pure white)
- Padding: `24px` horizontal, applied to scrollable content area

**Scrollable Content Area:**
- Height: `790px` (844px - 54px status bar)
- Overflow: `scroll` vertical
- Padding: `24px` on all sides

**Vertical Spacing:**
- Status bar to divider: `0px` (divider at top of scrollable area)
- Divider to heading: `32px`
- Heading to description: `8px`
- Description to form: `32px`
- Between language and currency sections: `32px` (built into component)
- Form to CTA button: `40px`

---

## Components Used

### 1. StatusBar

**Source:** `shared/_shared.jsx`

**Usage:**
```jsx
<StatusBar />
```

**Purpose:** Renders the iOS status bar overlay with time, cellular signal, battery, etc.

**Dimensions:**
- Height: `54px`
- Position: Absolute, top of viewport
- Background: White/transparent depending on system theme

**Implementation Notes:**
- Fixed position component that overlays all content
- Provides visual consistency with iOS native apps
- Does not affect content flow (positioned absolutely)

---

### 2. LanguageCurrencyDropdowns

**Source:** `shared/_shared.jsx`

**Usage:**
```jsx
<LanguageCurrencyDropdowns
  language={language}           // Current language code (e.g., "en", "da")
  currency={currency}           // Current currency code (e.g., "DKK", "USD")
  onLanguageChange={onLanguageChange}  // Callback: (code: string) => void
  onCurrencyChange={onCurrencyChange}  // Callback: (code: string) => void
  showDescriptions={false}      // Hides explanatory text under labels
/>
```

**Purpose:** Shared component that renders both language and currency selection dropdowns with consistent styling and behavior.

**Key Features:**
- Self-contained state for dropdown open/closed
- Flag emoji display for languages
- Currency symbol display for currencies
- Selected state highlighting with orange tint background (`#fef8f2`)
- Smooth dropdown animations
- Click-outside-to-close behavior (not visible in JSX, but expected in implementation)

**Visual Breakdown:**

#### Language Selector

**Label:**
- Text: "Language" (or "Sprog" if Danish selected)
- Font size: `16px`
- Font weight: `600`
- Color: `#0f0f0f`
- Margin below: `12px` (when `showDescriptions={false}`)

**Dropdown Button:**
- Width: `100%`
- Height: `50px`
- Background: `#f5f5f5` (light gray fill)
- Border: `1px solid #e8e8e8`
- Border radius: `10px`
- Padding: `0 16px` horizontal
- Display: Flex, space-between alignment
- Cursor: `pointer`

**Button Content:**
- Left side: Flag emoji + language name
  - Gap: `8px` between flag and name
  - Font size: `14px`
  - Color: `#0f0f0f`
- Right side: Arrow indicator
  - Character: `▼` (closed) or `▲` (open)
  - Font size: `12px`
  - Color: `#888`

**Dropdown Menu (when open):**
- Position: Absolute, `54px` below button top
- Width: Full width of button
- Background: `#fff`
- Border: `1px solid #e8e8e8`
- Border radius: `10px`
- Box shadow: `0 4px 12px rgba(0,0,0,0.08)` (soft shadow)
- Z-index: `100`
- Max height: `280px`
- Overflow: `auto` vertical scroll

**Language Options:**
1. English 🇬🇧
2. Dansk 🇩🇰
3. Deutsch 🇩🇪
4. Svenska 🇸🇪
5. Norsk 🇳🇴
6. Italiano 🇮🇹
7. Français 🇫🇷

**Each Option:**
- Padding: `12px 16px`
- Display: Flex, align center
- Gap: `8px` between flag and name
- Cursor: `pointer`
- Background: `#fef8f2` (orange tint) if selected, `#fff` otherwise
- Border bottom: `1px solid #f2f2f2` (except last item)
- Font size: `14px`
- Color: `#0f0f0f`

---

#### Currency Selector

**Label:**
- Text: "Currency" (or "Valuta" if Danish selected)
- Font size: `16px`
- Font weight: `600`
- Color: `#0f0f0f`
- Margin below: `12px` (when `showDescriptions={false}`)

**Dropdown Button:**
- Identical styling to language dropdown button
- Content format: "Currency name (symbol)" — e.g., "Danish krone (kr.)"

**Currency Options:**
1. US dollar ($) — `USD`
2. British pound (£) — `GBP`
3. Danish krone (kr.) — `DKK`

**Each Option:**
- Same styling as language options
- Format: "Currency name (symbol)"
- Selected state: `#fef8f2` background

---

### 3. Top Divider Line

**Implementation:**
```jsx
<div style={{
  height: 1,
  background: "#f2f2f2",
  marginBottom: 32,
}}/>
```

**Purpose:** Subtle visual separator between status bar and content, providing a gentle boundary without harsh contrast.

**Styling:**
- Height: `1px`
- Background: `#f2f2f2` (light gray)
- Margin below: `32px`
- Full width (inherits from parent padding)

---

### 4. Heading & Description

**Heading:**
```jsx
<h2 style={{
  fontSize: 22,
  fontWeight: 700,
  color: "#0f0f0f",
  margin: "0 0 8px 0",
}}>
  Localization
</h2>
```

**Description:**
```jsx
<p style={{
  fontSize: 14,
  fontWeight: 400,
  color: "#555",
  lineHeight: "20px",
  margin: "0 0 32px 0",
}}>
  Select your preferred language and currency to use in the app.
</p>
```

**Purpose:** Clear, concise explanation of the page's function. Uses the term "Localization" which groups both language and currency as regional preferences.

---

### 5. Complete Setup Button

**Implementation:**
```jsx
<button
  onClick={onComplete}
  style={{
    width: "100%",
    height: 50,
    background: ACCENT,        // #e8751a (orange)
    color: "#fff",
    border: "none",
    borderRadius: 12,
    fontSize: 16,
    fontWeight: 600,
    cursor: "pointer",
    marginTop: 40,
  }}
>
  Complete setup
</button>
```

**Purpose:** Primary call-to-action that commits the user's selections and completes the onboarding flow.

**Styling:**
- Width: `100%` (full width of container minus padding)
- Height: `50px`
- Background: `#e8751a` (ACCENT orange)
- Text color: `#fff` (white)
- Border: None
- Border radius: `12px` (rounded corners)
- Font size: `16px`
- Font weight: `600`
- Cursor: `pointer`
- Margin top: `40px`

**Interaction States:**
- Default: Orange background
- Hover: (Not specified in JSX, likely slightly darker orange or shadow)
- Active/Press: (Not specified in JSX, likely deeper press effect)
- Disabled: (Not implemented, button is always enabled)

**Text:** "Complete setup" — clear action verb + outcome

---

## Design Tokens

### Colors

**Primary:**
- `ACCENT` = `#e8751a` — Orange brand color, used for CTA button
- `#fff` — Pure white background
- `#0f0f0f` — Primary text (near-black)

**Secondary:**
- `#555` — Secondary text (description)
- `#888` — Tertiary text (dropdown arrows, labels)

**Borders & Dividers:**
- `#f2f2f2` — Light divider line
- `#e8e8e8` — Dropdown borders

**Backgrounds:**
- `#f5f5f5` — Dropdown button background (light gray)
- `#fef8f2` — Selected item background (orange tint, 5% orange overlay)

**Shadows:**
- `0 4px 12px rgba(0,0,0,0.08)` — Dropdown menu shadow (soft, subtle)

### Spacing Scale

**Vertical Rhythm:**
- `8px` — Heading to description
- `12px` — Label to dropdown button
- `32px` — Major section spacing (divider to heading, description to form, between dropdowns)
- `40px` — Form to CTA button

**Horizontal Padding:**
- `24px` — Page content padding (left/right)
- `16px` — Dropdown button internal padding

**Component Heights:**
- `54px` — Status bar
- `50px` — Dropdown buttons and CTA button
- `1px` — Divider line

### Border Radius Scale

- `10px` — Dropdown buttons and menus (slightly rounded)
- `12px` — CTA button (more rounded for emphasis)

### Font Sizes

- `22px` — Page heading (h2)
- `16px` — Section labels and CTA button text
- `14px` — Description text, dropdown options
- `12px` — Dropdown arrow indicators

### Font Weights

- `700` — Heading (bold)
- `600` — Labels and CTA button (semi-bold)
- `400` — Description text (regular)

---

## State & Data

### Component Props

```typescript
interface WelcomeLanguageCurrencySetupProps {
  onComplete: () => void;           // Callback when user clicks "Complete setup"
  language: string;                  // Current language code (e.g., "en", "da")
  currency: string;                  // Current currency code (e.g., "DKK", "USD")
  onLanguageChange: (code: string) => void;  // Callback when language changes
  onCurrencyChange: (code: string) => void;  // Callback when currency changes
}
```

### State Flow

**Initial State:**
- `language` prop provides the current language selection (default likely "en")
- `currency` prop provides the current currency selection (default likely "DKK")
- Dropdowns render closed state
- CTA button is enabled and ready

**During Interaction:**
- User clicks language dropdown → `langOpen` state toggles to `true` (internal to LanguageCurrencyDropdowns)
- User selects a language → `onLanguageChange(code)` fires → `langOpen` closes
- User clicks currency dropdown → `currOpen` state toggles to `true`
- User selects a currency → `onCurrencyChange(code)` fires → `currOpen` closes
- Parent component updates `language` and `currency` props
- Dropdowns re-render with new selected values

**On Completion:**
- User clicks "Complete setup" button
- `onComplete()` callback fires
- Parent component saves preferences (likely to persistent storage)
- User navigates to main app (Search page)

### Data Structures

**Language Options:**
```javascript
const languages = [
  { code: "en", name: "English", flag: "🇬🇧" },
  { code: "da", name: "Dansk", flag: "🇩🇰" },
  { code: "de", name: "Deutsch", flag: "🇩🇪" },
  { code: "sv", name: "Svenska", flag: "🇸🇪" },
  { code: "no", name: "Norsk", flag: "🇳🇴" },
  { code: "it", name: "Italiano", flag: "🇮🇹" },
  { code: "fr", name: "Français", flag: "🇫🇷" },
];
```

**Currency Options:**
```javascript
const currencies = [
  { code: "USD", name: "US dollar", symbol: "$" },
  { code: "GBP", name: "British pound", symbol: "£" },
  { code: "DKK", name: "Danish krone", symbol: "kr." },
];
```

**Selected Item Lookup:**
```javascript
const selectedLang = languages.find(l => l.code === language) || languages[0];
const selectedCurr = currencies.find(c => c.code === currency) || currencies[2];
```

Defaults:
- Language: First in array (`English`)
- Currency: Third in array (`DKK` — Danish krone)

---

## User Interactions

### 1. Page Load

**Trigger:** User arrives from train station selection page

**Behavior:**
- Page renders with status bar visible
- Divider line appears at top
- Heading and description display
- Language dropdown shows current selection (flag + name)
- Currency dropdown shows current selection (name + symbol)
- Dropdowns are closed state (▼ arrow)
- CTA button is visible and enabled

**Visual State:**
- Clean, minimal layout
- All text is readable
- Orange CTA button draws attention

---

### 2. Language Selection

**Trigger:** User taps/clicks the language dropdown button

**Behavior:**
1. Dropdown opens with smooth animation (not specified in JSX, but expected)
2. Arrow indicator changes from ▼ to ▲
3. Menu appears below button with 7 language options
4. Current selection is highlighted with `#fef8f2` background
5. Menu overlays content below (z-index: 100)
6. Scrollbar appears if content exceeds 280px height

**User selects an option:**
1. `onLanguageChange(code)` callback fires with selected code
2. Dropdown closes
3. Button updates to show new flag + language name
4. If Danish is selected, labels change to Danish:
   - "Language" → "Sprog"
   - "Currency" → "Valuta"

**Click outside:**
- Dropdown closes (behavior expected but not shown in JSX)

---

### 3. Currency Selection

**Trigger:** User taps/clicks the currency dropdown button

**Behavior:**
1. Dropdown opens with smooth animation
2. Arrow indicator changes from ▼ to ▲
3. Menu appears below button with 3 currency options
4. Current selection is highlighted with `#fef8f2` background
5. Menu overlays content below (z-index: 100)
6. No scrollbar needed (only 3 options fit within dropdown height)

**User selects an option:**
1. `onCurrencyChange(code)` callback fires with selected code
2. Dropdown closes
3. Button updates to show new currency name + symbol

**Click outside:**
- Dropdown closes

---

### 4. Complete Setup

**Trigger:** User taps/clicks the "Complete setup" button

**Behavior:**
1. `onComplete()` callback fires
2. Parent component persists language and currency selections
3. User navigates to main app (likely Search page)
4. Onboarding flow is marked complete

**Visual Feedback:**
- Button press animation (not specified, likely scale/shadow change)
- Immediate navigation to next screen

---

### 5. Dropdown Interaction States

**Closed State:**
- Button shows current selection
- Arrow points down (▼)
- Light gray background (`#f5f5f5`)
- Subtle border (`#e8e8e8`)

**Open State:**
- Button remains visible with selection
- Arrow points up (▲)
- Menu appears below with shadow
- Options are listed with borders between items
- Selected option has orange tint background

**Hover/Focus State (not specified in JSX):**
- Expected: Slight color change or shadow on button hover
- Expected: Option background changes on hover

---

## Design Rationale

### Why This Design Works

#### 1. Simplicity and Focus

**Decision:** Minimal page with only essential elements (heading, description, two dropdowns, one button)

**Rationale:**
- Users are at the end of onboarding — they want to complete setup quickly
- No distractions or unnecessary options
- Clear single path forward (no skip, no back button)
- Reduces cognitive load and decision fatigue

**Evidence of Design Thinking:**
- No decorative elements or imagery
- No secondary actions or links
- Straightforward labels ("Language", "Currency", "Complete setup")
- Description is one sentence, not a paragraph

---

#### 2. Shared Component Reuse

**Decision:** Use `LanguageCurrencyDropdowns` component with `showDescriptions={false}`

**Rationale:**
- Consistency with settings page where users can change these later
- Reduces maintenance burden (one component, multiple uses)
- Users encounter familiar UI when they access settings
- Same behavior and styling across contexts

**Benefits:**
- Less code duplication
- Easier to update styling/behavior globally
- Predictable interaction patterns for users

---

#### 3. Required Selection (No Skip)

**Decision:** No skip button or "Use default" option

**Rationale:**
- Language and currency are critical to the user experience
- Setting defaults without user awareness could cause confusion later
- Forces intentional choice, increasing engagement
- Users are more likely to remember their selections if they actively choose

**Trade-offs:**
- Adds friction to onboarding flow
- But: This is the final setup step, so friction is acceptable
- Users have already invested time in location/station setup

---

#### 4. Orange CTA Button

**Decision:** Use ACCENT orange (`#e8751a`) for "Complete setup" button

**Rationale:**
- Orange is the brand's interactive color (per design system)
- High contrast against white background
- Signals action and progress
- Consistent with other primary CTAs throughout the app

**Why Not Green?**
- Green is reserved for "match confirmation" status (per design system)
- Orange = "do this action", Green = "this matches your needs"
- Using orange maintains semantic clarity

---

#### 5. Dropdown Over Modal/Picker

**Decision:** Use custom dropdown menus instead of native pickers or modal sheets

**Rationale:**
- Provides visual consistency with settings page
- Allows for custom styling (flag emojis, selected state highlighting)
- Keeps user in context — no modal overlay that hides the page
- More discoverable — user can see all options immediately when opened

**Trade-offs:**
- Custom dropdowns require more implementation work
- But: Provides better UX and brand consistency

---

#### 6. Flag Emojis for Languages

**Decision:** Show flag emoji next to each language name

**Rationale:**
- Visual recognition is faster than reading text
- Flags provide immediate context for users unfamiliar with language names
- Adds personality and visual interest without clutter
- Standard pattern in language pickers across apps

**Why These Specific Flags?**
- 🇬🇧 for English (UK flag, most recognizable)
- 🇩🇰 for Danish (primary market)
- 🇩🇪, 🇸🇪, 🇳🇴, 🇮🇹, 🇫🇷 for German, Swedish, Norwegian, Italian, French (regional markets)

---

#### 7. Currency Symbol Display

**Decision:** Show both currency name and symbol in format "Name (symbol)"

**Rationale:**
- Symbol alone could be ambiguous (e.g., $ for USD vs. other dollar currencies)
- Name alone lacks visual recognition
- Combined format is clear and informative
- Symbol in parentheses is secondary info, name is primary

**Examples:**
- "US dollar ($)"
- "British pound (£)"
- "Danish krone (kr.)"

---

#### 8. Selected State Highlighting

**Decision:** Use `#fef8f2` (orange tint) background for selected items in dropdowns

**Rationale:**
- Subtle but clear indication of current selection
- Orange tint ties to brand color without being overwhelming
- Differentiates selected item from unselected items
- Provides feedback when user re-opens dropdown

**Why Not Bold Text or Checkmark?**
- Background color is more noticeable
- Maintains clean, minimal design
- Checkmarks add visual clutter

---

#### 9. Top Divider Line

**Decision:** Include subtle 1px divider line below status bar

**Rationale:**
- Provides gentle separation between system UI and app content
- Prevents content from feeling cramped against status bar
- Adds polish and refinement to the design
- Matches pattern used in other pages (consistent across app)

---

#### 10. No Back Button

**Decision:** No back navigation option

**Rationale:**
- This is the final setup step — going back would be unusual
- Users should complete the flow forward, not revisit previous steps
- Reduces complexity and decision-making
- If user needs to change location/station, they can do so later in settings

**Expected Behavior:**
- System back button (Android) or swipe gesture (iOS) could go back
- But: No explicit back button in UI

---

#### 11. Scrollable Content Area

**Decision:** Make content area scrollable (height: 790px, overflow: scroll)

**Rationale:**
- Prepares for content expansion (e.g., adding more form fields)
- Prevents layout breaking on smaller screens
- Allows for bottom CTA button to remain accessible
- Standard pattern for form pages

**Current State:**
- Content fits within viewport, so scrolling is not needed
- But: Structure supports future additions without layout issues

---

#### 12. `showDescriptions={false}`

**Decision:** Hide the explanatory text under each dropdown label

**Rationale:**
- Reduces visual clutter on setup page
- Descriptions are more relevant in settings (explaining exchange rates, etc.)
- Onboarding users want speed — descriptions slow them down
- Labels ("Language", "Currency") are self-explanatory

**Trade-offs:**
- Users don't see exchange rate warning during setup
- But: This is acceptable — they'll see it in settings if they change currency later

---

## Component Architecture

### Parent-Child Relationship

```
WelcomeLanguageCurrencySetup (page)
  ├─ StatusBar (shared component)
  ├─ Top divider (div element)
  ├─ Heading (h2 element)
  ├─ Description (p element)
  ├─ LanguageCurrencyDropdowns (shared component)
  │   ├─ Language selector
  │   │   ├─ Label
  │   │   ├─ Dropdown button
  │   │   └─ Dropdown menu (conditional, when langOpen = true)
  │   └─ Currency selector
  │       ├─ Label
  │       ├─ Dropdown button
  │       └─ Dropdown menu (conditional, when currOpen = true)
  └─ Complete setup button (button element)
```

### Data Flow

```
Parent Component (App/OnboardingFlow)
  ↓ Props: language, currency, handlers
WelcomeLanguageCurrencySetup
  ↓ Props: language, currency, handlers, showDescriptions=false
LanguageCurrencyDropdowns
  ↓ Internal state: langOpen, currOpen
Dropdown Menus (conditional render)
  ↓ User selects option
Handler fires: onLanguageChange(code) or onCurrencyChange(code)
  ↑ Bubbles up to parent
Parent updates state
  ↓ Re-renders with new props
LanguageCurrencyDropdowns updates selected values
```

### Prop Flow Diagram

```
[App/OnboardingFlow State]
  ├─ language: "en"
  ├─ currency: "DKK"
  ├─ onLanguageChange: (code) => { setLanguage(code) }
  ├─ onCurrencyChange: (code) => { setCurrency(code) }
  └─ onComplete: () => { savePreferences(); navigateToSearch(); }
        ↓
[WelcomeLanguageCurrencySetup]
  ├─ Receives all props
  ├─ Passes language, currency, handlers to LanguageCurrencyDropdowns
  └─ Attaches onComplete to button click
        ↓
[LanguageCurrencyDropdowns]
  ├─ Receives language, currency, handlers, showDescriptions
  ├─ Manages dropdown open/closed state internally
  └─ Calls handlers when user selects options
        ↓
[User Selection] → Handler fires → Parent state updates → Props update → Re-render
```

---

## Typography System

### Hierarchy

**Level 1: Page Heading**
- Element: `<h2>`
- Font size: `22px`
- Font weight: `700` (bold)
- Color: `#0f0f0f` (near-black)
- Purpose: Primary page title ("Localization")

**Level 2: Section Labels**
- Font size: `16px`
- Font weight: `600` (semi-bold)
- Color: `#0f0f0f`
- Purpose: Dropdown labels ("Language", "Currency")

**Level 3: Body Text**
- Element: `<p>` (description)
- Font size: `14px`
- Font weight: `400` (regular)
- Color: `#555` (medium gray)
- Line height: `20px`
- Purpose: Explanatory text

**Level 4: Form Elements**
- Font size: `14px`
- Font weight: `400` (regular)
- Color: `#0f0f0f` (dropdown options)
- Purpose: Dropdown button text and menu options

**Level 5: Button Text**
- Font size: `16px`
- Font weight: `600` (semi-bold)
- Color: `#fff` (white on orange)
- Purpose: CTA button text

**Level 6: UI Indicators**
- Font size: `12px`
- Color: `#888` (light gray)
- Purpose: Dropdown arrow indicators

### Line Height & Spacing

**Heading:**
- No explicit line-height set (browser default ~1.2)
- Margin: `0 0 8px 0`

**Description:**
- Line height: `20px` (1.43 ratio at 14px font size)
- Margin: `0 0 32px 0`

**Labels:**
- No explicit line-height set
- Margin: `0 0 12px 0` (from LanguageCurrencyDropdowns)

**Button:**
- No explicit line-height set (vertically centered via flex/height)

### Font Family

Not specified in JSX design. Expected implementation:
- System font stack (e.g., `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif`)
- Or: Custom brand font (e.g., Inter, Poppins, etc.)

---

## Spacing & Measurements

### Vertical Spacing Breakdown

```
[Status Bar: 54px]
[Scrollable area starts]
  [Divider: 1px]
  [Spacing: 32px]
  [Heading: ~27px]
  [Spacing: 8px]
  [Description: ~40px (2 lines at 20px line-height)]
  [Spacing: 32px]
  [Language label: ~16px]
  [Spacing: 12px]
  [Language dropdown: 50px]
  [Spacing: 32px] (built into LanguageCurrencyDropdowns)
  [Currency label: ~16px]
  [Spacing: 12px]
  [Currency dropdown: 50px]
  [Spacing: 40px]
  [CTA button: 50px]
  [Bottom padding: 24px]
```

**Total content height:** ~390px (fits comfortably in 790px scrollable area)

### Horizontal Spacing

**Page padding:** `24px` left and right

**Dropdown internal padding:** `16px` left and right

**Gap between flag and text:** `8px` (in language options)

### Component Dimensions

**Status bar:** 54px height

**Divider:** 1px height, full width

**Dropdown buttons:** 50px height, 100% width

**Dropdown menu:** Max 280px height (language), auto height (currency)

**CTA button:** 50px height, 100% width

**Dropdown border:** 1px

### Border Radius

**Dropdown buttons:** `10px`

**Dropdown menus:** `10px`

**CTA button:** `12px`

---

## Accessibility Considerations

### Semantic HTML

**Current Structure:**
- `<h2>` for page heading (semantic heading level)
- `<p>` for description (semantic paragraph)
- `<button>` for CTA (semantic interactive element)
- `<div>` for dropdowns (not semantic, but acceptable for custom components)

**Improvements for Implementation:**
- Add `role="combobox"` to dropdown buttons
- Add `aria-expanded` attribute (true/false) to indicate dropdown state
- Add `aria-haspopup="listbox"` to dropdown buttons
- Add `role="listbox"` to dropdown menus
- Add `role="option"` to each menu item
- Add `aria-selected="true"` to selected options
- Add `tabindex="0"` to dropdown buttons and options for keyboard navigation

### Keyboard Navigation

**Not Specified in JSX, but Expected:**
- Tab key moves focus between dropdowns and CTA button
- Enter/Space opens focused dropdown
- Arrow keys navigate options in open dropdown
- Enter/Space selects focused option
- Escape closes open dropdown
- Tab with dropdown open closes dropdown and moves focus

### Screen Reader Support

**Current Labels:**
- "Localization" heading provides context
- Description explains purpose
- "Language" and "Currency" labels are clear

**Improvements:**
- Add `aria-label` to dropdowns with full context (e.g., "Select language, currently English")
- Add `aria-labelledby` linking labels to dropdown buttons
- Announce selected option when changed
- Announce dropdown open/closed state

### Visual Accessibility

**Contrast Ratios (estimated):**
- Heading (`#0f0f0f` on `#fff`): ~20:1 (excellent, exceeds WCAG AAA)
- Description (`#555` on `#fff`): ~9:1 (excellent, exceeds WCAG AAA)
- Dropdown text (`#0f0f0f` on `#f5f5f5`): ~19:1 (excellent)
- CTA button (`#fff` on `#e8751a`): ~4.5:1 (good, meets WCAG AA)

**Font Sizes:**
- Minimum 14px for body text (meets WCAG AA)
- Heading at 22px (well above minimum)

**Touch Targets:**
- Dropdown buttons: 50px height (exceeds 44px minimum)
- CTA button: 50px height (exceeds 44px minimum)
- Dropdown options: ~36px height (12px padding × 2 + text height, meets minimum)

---

## Edge Cases & States

### 1. Initial Load with No Selections

**Scenario:** User arrives with no language/currency set

**Expected Behavior:**
- Language defaults to `languages[0]` (English)
- Currency defaults to `currencies[2]` (Danish krone)
- Dropdowns render with these defaults
- User can change selections normally

**Design Consideration:**
- Default to most common language (English) and market currency (DKK)

---

### 2. Dropdown Open When User Clicks Complete

**Scenario:** User has language dropdown open and clicks "Complete setup"

**Expected Behavior:**
- Dropdown should close
- `onComplete` should fire
- User navigates to next screen

**Design Consideration:**
- CTA button should be accessible even with dropdown open
- Dropdown menu should not obscure CTA button (z-index: 100, menu above content but CTA is below)

---

### 3. Multiple Dropdowns Open Simultaneously

**Scenario:** User opens language dropdown, then opens currency dropdown without closing language

**Expected Behavior:**
- Only one dropdown should be open at a time
- Opening currency dropdown should close language dropdown

**Implementation Note:**
- Not specified in JSX, but expected behavior
- Likely handled by click-outside logic or shared state in parent component

---

### 4. Long Language Names Overflow

**Scenario:** Language name exceeds dropdown button width

**Expected Behavior:**
- Text should truncate with ellipsis or wrap
- Button height should remain 50px (no expansion)

**Current Design:**
- No text overflow handling specified
- Expected: `text-overflow: ellipsis`, `white-space: nowrap`, `overflow: hidden`

---

### 5. Small Screen / Short Viewport

**Scenario:** User views page on a shorter device (e.g., iPhone SE at 667px height)

**Expected Behavior:**
- Scrollable content area adjusts to available height
- User can scroll to see CTA button
- Dropdowns remain functional

**Design Consideration:**
- Scrollable area height is fixed at 790px, but parent container should adjust
- Content fits within most modern phone viewports

---

### 6. Language Change Mid-Flow

**Scenario:** User selects Danish, then changes to English before clicking Complete

**Expected Behavior:**
- Labels update immediately when language changes
- "Sprog" → "Language", "Valuta" → "Currency"
- Dropdown buttons reflect new selections
- No data loss or state corruption

**Implementation Note:**
- Labels must be reactive to `language` prop
- LanguageCurrencyDropdowns component handles label translation internally

---

### 7. Slow Network / API Failure

**Scenario:** `onComplete` callback triggers API call that fails

**Expected Behavior (not specified in JSX):**
- Error message should display
- User should be able to retry
- Selections should persist

**Design Consideration:**
- JSX design does not show error states
- Implementation should add error handling

---

### 8. Dropdown Menu Extends Below Viewport

**Scenario:** Dropdown opens and menu extends below visible area

**Expected Behavior:**
- Menu should scroll internally (max-height: 280px with overflow: auto)
- Or: Menu should open upward if not enough space below

**Current Design:**
- Language dropdown has `maxHeight: 280px` and `overflowY: auto`
- Currency dropdown has only 3 options, so no scroll needed

---

### 9. User Clicks Outside Dropdown

**Scenario:** Dropdown is open, user clicks on page background or other element

**Expected Behavior:**
- Dropdown closes without selecting an option
- Previous selection remains unchanged

**Implementation Note:**
- Not specified in JSX, but expected behavior
- Requires click-outside detection logic

---

### 10. Rapid Clicking / Double Selection

**Scenario:** User rapidly clicks dropdown options or button

**Expected Behavior:**
- Prevent multiple simultaneous state updates
- Dropdown should close after first valid selection
- No race conditions or duplicate callbacks

**Design Consideration:**
- Click handlers should debounce or disable during state transitions

---

## Conclusion

The Welcome Language & Currency Setup page is a minimal, focused design that completes the onboarding flow by capturing essential user preferences. The design prioritizes speed and clarity, using a shared dropdown component for consistency with the settings page.

Key strengths:
- Clean, uncluttered layout
- Clear hierarchy and visual flow
- Reusable component architecture
- Semantic use of orange CTA for primary action
- Required selections ensure intentional user choice

Areas for implementation attention:
- Add keyboard navigation support
- Implement click-outside-to-close behavior
- Add error handling for completion failures
- Ensure dropdown menus don't obscure CTA button
- Test on various screen sizes and orientations

This design establishes a solid foundation for the final onboarding step, balancing user speed with the need for explicit preference setting.
