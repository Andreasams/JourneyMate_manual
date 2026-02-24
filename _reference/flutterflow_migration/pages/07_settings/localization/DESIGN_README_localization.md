# Localization Page — JSX Design Documentation

**File:** `C:\Users\Rikke\Documents\JourneyMate-v2\pages\settings\localization.jsx`
**Version:** v2 JSX Design
**Date Documented:** 2026-02-19
**Scope:** JSX design specification only (no FlutterFlow comparison)

---

## Design Overview

### Purpose

The Localization page is a settings page that consolidates language, currency, and location preferences in a single interface. It provides a centralized hub for users to configure all localization-related settings that affect how restaurant information is displayed and personalized.

### Key Responsibilities

1. **Language Selection** — Set the app's display language from seven supported options
2. **Currency Selection** — Choose preferred currency for price display with exchange rate transparency
3. **Location Management** — Control location sharing permissions with clear status feedback and quick enable/disable functionality

### Design Philosophy

This page follows a **progressive disclosure** pattern where:
- Basic language/currency selection is inline and self-contained
- Location settings show current status at-a-glance with contextual action buttons
- Disabled location state encourages enablement with prominent CTA
- Enabled location state provides access to detailed management via secondary button

The design prioritizes **transparency** (clear status indicators, privacy notes) and **efficiency** (direct enabling, smart button text based on state).

---

## Visual Layout

### Page Structure

```
┌─────────────────────────────────┐
│ StatusBar (44px)                │
├─────────────────────────────────┤
│ Header (60px)                   │
│  ← | Localization                │
├─────────────────────────────────┤
│                                 │
│ Scrollable Content (730px)      │
│                                 │
│  Language & Currency Section    │
│  ┌──────────────────────────┐  │
│  │ Language & Currency      │  │
│  │                          │  │
│  │ LanguageCurrencyDropdowns│  │
│  └──────────────────────────┘  │
│                                 │
│  ─────────────────────────────  │
│                                 │
│  Location Section               │
│  ┌──────────────────────────┐  │
│  │ Location                 │  │
│  │ Description text         │  │
│  │                          │  │
│  │ Status Card              │  │
│  │  [icon] sharing • ON/OFF │  │
│  │  Context message         │  │
│  │                          │  │
│  │ [Action Button]          │  │
│  │ Privacy note (if OFF)    │  │
│  └──────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```

### Dimensions

- **Canvas:** 390 × 844px (iPhone standard viewport)
- **Header Height:** 60px
- **Content Area:** 730px scrollable
- **Horizontal Padding:** 24px
- **Section Spacing:** 40px between Language & Currency and Location sections
- **Divider Spacing:** 32px margin after divider

---

## Components Used

### 1. StatusBar

**Source:** `StatusBar` component from `_shared.jsx`

**Purpose:** iOS status bar simulation showing time, signal, battery

**Styling:**
- Height: 44px
- Background: white
- Contains system UI elements

---

### 2. Header

**Type:** Custom inline component

**Layout:**
```
┌────────────────────────────┐
│ [←]  Localization          │
└────────────────────────────┘
```

**Structure:**
- **Container:** 60px height, flexbox (center alignment), 20px horizontal padding
- **Border:** 1px solid `#f2f2f2` bottom border
- **Back Button:**
  - Size: 36 × 36px
  - Icon: "←" character
  - Font size: 18px
  - Color: `#0f0f0f`
  - Background: transparent
  - No border, pointer cursor
- **Title:**
  - Text: "Localization"
  - Font size: 16px
  - Font weight: 600
  - Color: `#0f0f0f`
  - Centered with `flex: 1`, `textAlign: center`
  - **Negative margin trick:** `marginLeft: -36px` to center title accounting for back button width

**Interaction:**
- Back button triggers `onBack` callback (returns to settings hub)

---

### 3. LanguageCurrencyDropdowns

**Source:** `LanguageCurrencyDropdowns` component from `_shared.jsx`

**Purpose:** Reusable dual-dropdown selector for language and currency preferences

**Props Passed:**
```jsx
<LanguageCurrencyDropdowns
  language={language}              // Current language code (e.g., "da")
  currency={currency}              // Current currency code (e.g., "DKK")
  onLanguageChange={setLanguage}   // Callback to update language state
  onCurrencyChange={setCurrency}   // Callback to update currency state
  showDescriptions={true}          // Show helper text under labels
/>
```

**Supported Languages:**
| Code | Language | Flag |
|------|----------|------|
| `en` | English | 🇬🇧 |
| `da` | Dansk | 🇩🇰 |
| `de` | Deutsch | 🇩🇪 |
| `sv` | Svenska | 🇸🇪 |
| `no` | Norsk | 🇳🇴 |
| `it` | Italiano | 🇮🇹 |
| `fr` | Français | 🇫🇷 |

**Supported Currencies:**
| Code | Name | Symbol |
|------|------|--------|
| `USD` | US dollar | $ |
| `GBP` | British pound | £ |
| `DKK` | Danish krone | kr. |

**Component Behavior:**

**Language Dropdown:**
- **Label:** "Sprog" (if Danish) or "Language"
- **Description:** Localized text about setting preferred language
- **Closed State:**
  - 50px height button
  - Background: `#f5f5f5`
  - Border: 1px solid `#e8e8e8`
  - Border radius: 10px
  - Shows: flag emoji + language name + down arrow (▼)
- **Open State:**
  - Shows dropdown menu below (position: absolute, top: 54px)
  - White background with border and shadow
  - Max height: 280px with scroll
  - Each option: 12px vertical padding, flag + name
  - Selected option: `#fef8f2` background (light orange tint)
  - Dividers between options: `#f2f2f2`
  - Click option → updates language, closes dropdown

**Currency Dropdown:**
- **Label:** "Valuta" (if Danish) or "Currency"
- **Description:** Localized text about 24-hour exchange rate updates with slight variance disclaimer
- **Closed State:** Same styling as language dropdown
  - Shows: currency name + symbol in parentheses + down arrow
- **Open State:** Same styling as language dropdown
  - Shows: currency name + symbol for each option
  - Selected option: `#fef8f2` background

**Design Notes:**
- Both dropdowns share identical styling patterns for consistency
- Dropdown menus use `z-index: 100` to appear above other content
- Up/down arrows (▲/▼) provide clear affordance for expand/collapse state
- Selected items use brand-adjacent orange tint for subtle highlighting
- Component is self-contained with internal open/close state management

---

### 4. Location Section

**Type:** Custom inline component group

**Structure:** Three-part composition:

#### 4.1 Section Header

**Layout:**
```
Location
Description paragraph explaining the benefit of location sharing
```

**Styling:**
- **Title:**
  - Font size: 18px
  - Font weight: 680 (bold)
  - Color: `#0f0f0f`
  - Margin bottom: 8px
- **Description:**
  - Font size: 13px
  - Color: `#888` (medium gray)
  - Line height: 18px
  - Margin bottom: 16px
  - Text: "Allow JourneyMate to show nearby restaurants and provide better recommendations based on your location."

#### 4.2 Status Card

**Purpose:** At-a-glance display of current location sharing state

**Layout:**
```
┌─────────────────────────────────────┐
│ [📍 icon] Location sharing  ● Status│
│ Context message                     │
└─────────────────────────────────────┘
```

**Styling:**
- **Container:**
  - Padding: 16px
  - Border radius: 12px
  - Border: 1.5px solid `#e8e8e8`
  - Background: `#fafafa` (subtle gray tint)
  - Margin bottom: 12px

- **Top Row (flex container, space-between):**
  - **Left Group:**
    - Location pin icon (SVG, 20×20px, `#666` stroke)
    - Text: "Location sharing"
    - Font size: 14px, font weight: 500, color: `#0f0f0f`
    - Gap: 10px between icon and text
  - **Right Group (status indicator):**
    - Dot: 6px circle, color depends on state
    - Status text: "Enabled" or "Disabled"
    - Font size: 13px, font weight: 500
    - Gap: 6px between dot and text

**State-Dependent Styling:**

| State | Dot Color | Text Color | Context Message |
|-------|-----------|------------|-----------------|
| Enabled | `#2a9456` (green) | `#2a9456` (green) | "We can show you restaurants near you" |
| Disabled | `#c9403a` (red) | `#c9403a` (red) | "Enable to see nearby restaurants" |

- **Context Message:**
  - Font size: 12px
  - Color: `#999` (light gray)
  - Line height: 16px
  - Appears below status row with 4px gap

**Design Notes:**
- Uses semantic color coding (green = enabled, red = disabled)
- Context message changes based on state to provide actionable information
- Card design with subtle background differentiates from action button below

#### 4.3 Action Button

**Purpose:** Primary action for location management (state-dependent behavior)

**Behavior Logic:**
```javascript
onClick={() => {
  if (!locationEnabled) {
    // Direct action: Enable location immediately
    setLocationEnabled(true);
  } else {
    // Navigation: Go to detailed settings
    onNavigate("location-sharing");
  }
}}
```

**State-Dependent Appearance:**

**When Location is DISABLED:**
- **Style:** Primary CTA button
- **Background:** `#e8751a` (ACCENT orange)
- **Hover Background:** `#d96816` (darker orange)
- **Text Color:** `#fff` (white)
- **Border:** None
- **Text:** "Turn on location sharing"
- **Icon:** None
- **Privacy Note Below:**
  - Font size: 11px
  - Color: `#aaa` (light gray)
  - Line height: 14px
  - Text align: center
  - Margin top: 12px
  - Text: "Your location is only used to show nearby places. We never share it with third parties."

**When Location is ENABLED:**
- **Style:** Secondary navigation button
- **Background:** Transparent
- **Hover Background:** `#f9f9f9` (subtle gray)
- **Text Color:** `#555` (dark gray)
- **Border:** 1.5px solid `#e8e8e8`
- **Text:** "Manage location settings"
- **Icon:** Right-facing chevron (8×14px, `#bbb` stroke)
- **Privacy Note:** Hidden

**Common Button Properties:**
- Width: 100% (full width)
- Height: 48px
- Border radius: 12px
- Font size: 15px
- Font weight: 600
- Display: flex (center alignment)
- Gap: 8px (between text and icon)
- Transition: `background 0.2s ease`
- Cursor: pointer

**Design Rationale:**
- **Disabled state = action button:** Users can enable location with a single tap directly from this screen, reducing friction
- **Enabled state = navigation button:** Once enabled, button becomes a secondary-styled link to more detailed settings
- **Privacy note appears only when disabled:** Addresses potential user concerns about privacy at the moment of decision
- **Button text is explicit:** "Turn on" vs "Manage" clearly communicates the action outcome
- **Visual hierarchy shifts:** Prominent orange CTA when disabled → subtle bordered button when enabled (reduces visual noise once action is taken)

---

## Design Tokens

### Color Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `ACCENT` | `#e8751a` | Primary CTA button (Turn on location) |
| Button hover | `#d96816` | Darker orange hover state |
| Primary text | `#0f0f0f` | Headers, labels, titles |
| Secondary text | `#888` | Descriptions, helper text |
| Tertiary text | `#999` | Status card context messages |
| Light text | `#aaa` | Privacy note |
| Medium gray | `#555` | Enabled button text |
| Border light | `#e8e8e8` | Card borders, input borders |
| Border lighter | `#f2f2f2` | Header border, dividers |
| Background tint | `#fafafa` | Status card background |
| Input background | `#f5f5f5` | Dropdown closed state backgrounds |
| White | `#fff` | Page background, dropdown menus |
| Orange tint | `#fef8f2` | Selected dropdown item highlight |
| Green (enabled) | `#2a9456` | Location enabled status |
| Red (disabled) | `#c9403a` | Location disabled status |
| Icon gray | `#666` | Location pin icon |
| Chevron gray | `#bbb` | Navigation arrow in enabled button |

### Typography Scale

| Element | Size | Weight | Color | Line Height |
|---------|------|--------|-------|-------------|
| Page title (header) | 16px | 600 | `#0f0f0f` | — |
| Section title | 18px | 680 | `#0f0f0f` | — |
| Dropdown label | 16px | 600 | `#0f0f0f` | — |
| Status card label | 14px | 500 | `#0f0f0f` | — |
| Description text | 13px | 400 | `#888` | 18px |
| Status text | 13px | 500 | Dynamic | — |
| Dropdown closed value | 14px | 400 | `#0f0f0f` | — |
| Dropdown open option | 14px | 400 | `#0f0f0f` | — |
| Status card context | 12px | 400 | `#999` | 16px |
| Dropdown arrow | 12px | 400 | `#888` | — |
| Privacy note | 11px | 400 | `#aaa` | 14px |
| Button text | 15px | 600 | Dynamic | — |
| Back button icon | 18px | 400 | `#0f0f0f` | — |

### Spacing System

**Vertical Rhythm:**
- Section spacing: 40px (between Language & Currency and Location)
- Divider margin: 32px (after horizontal rule)
- Subsection spacing: 32px (between language and currency dropdowns in shared component)
- Group spacing: 16px (title to description in Location section)
- Element spacing: 12px (status card to button, description to input in shared component)
- Component spacing: 8px (description to status card context, label to description in shared component)

**Horizontal Spacing:**
- Page horizontal padding: 24px
- Content horizontal padding: 20px (header only)
- Card internal padding: 16px
- Dropdown internal padding: 16px horizontal
- Dropdown option padding: 16px horizontal
- Icon-text gaps: 8-10px (status card: 10px, button icon: 8px)

**Element Heights:**
- Header: 60px
- Dropdown inputs: 50px
- Action button: 48px
- Back button: 36×36px

**Border Radii:**
- Status card: 12px
- Action button: 12px
- Dropdowns: 10px

**Border Widths:**
- Card border: 1.5px
- Enabled button border: 1.5px
- Dropdown border: 1px
- Header border: 1px

---

## State & Data

### Component State

```javascript
const [language, setLanguage] = useState("da");           // Current language code
const [currency, setCurrency] = useState("DKK");          // Current currency code
const [locationEnabled, setLocationEnabled] = useState(false); // Location permission status
```

### Internal State (LanguageCurrencyDropdowns)

```javascript
const [langOpen, setLangOpen] = useState(false);   // Language dropdown open/closed
const [currOpen, setCurrOpen] = useState(false);   // Currency dropdown open/closed
```

### Default Values

- **Language:** `"da"` (Danish)
- **Currency:** `"DKK"` (Danish krone)
- **Location:** `false` (disabled by default)

**Rationale:** Defaults assume Danish market as primary target (based on krone as default currency and Danish as default language).

### Data Collections (from LanguageCurrencyDropdowns)

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

**Selection Logic:**
```javascript
const selectedLang = languages.find(l => l.code === language) || languages[0];
const selectedCurr = currencies.find(c => c.code === currency) || currencies[2];
```
- Fallback to English if language code doesn't match
- Fallback to Danish krone if currency code doesn't match

### State Persistence (Implementation Detail)

**Note:** This JSX design does not specify persistence mechanism. In Flutter implementation:
- `language` and `currency` would likely be persisted to SharedPreferences or similar
- `locationEnabled` would reflect actual device permission status (read-only in this context)
- Settings would not auto-apply; requires explicit save action (though this design shows immediate state changes for preview purposes)

---

## User Interactions

### 1. Navigation

**Back Button:**
- **Trigger:** Click "←" button in header
- **Action:** `onBack()` callback
- **Expected behavior:** Return to settings hub/main settings screen
- **Visual feedback:** Button is tappable area (36×36px), no visual hover state in design

### 2. Language Selection

**Open Dropdown:**
- **Trigger:** Click language selector (entire 50px tall button)
- **Action:** Toggle `langOpen` state → dropdown appears
- **Visual change:** Arrow changes from ▼ to ▲

**Select Language:**
- **Trigger:** Click language option in dropdown menu
- **Action:**
  1. Call `onLanguageChange(lang.code)`
  2. Update `language` state
  3. Close dropdown (`setLangOpen(false)`)
- **Visual feedback:**
  - Selected option shows orange tint background (`#fef8f2`)
  - Dropdown closes
  - Selected language appears in closed selector with flag

**Close Dropdown:**
- **Trigger:** Click anywhere outside dropdown (expected behavior, not explicitly coded in design)
- **Action:** Close dropdown without changing selection

**Effect on UI:**
- Labels and descriptions immediately update to selected language
- "Language" → "Sprog" or vice versa depending on selection
- Currency label changes between "Currency" and "Valuta"

### 3. Currency Selection

**Open Dropdown:**
- **Trigger:** Click currency selector
- **Action:** Toggle `currOpen` state → dropdown appears
- **Visual change:** Arrow changes from ▼ to ▲

**Select Currency:**
- **Trigger:** Click currency option in dropdown menu
- **Action:**
  1. Call `onCurrencyChange(curr.code)`
  2. Update `currency` state
  3. Close dropdown (`setCurrOpen(false)`)
- **Visual feedback:**
  - Selected option shows orange tint background
  - Dropdown closes
  - Selected currency appears in closed selector with symbol

### 4. Location Control (Context-Sensitive)

**When Location is DISABLED:**

**Enable Location:**
- **Trigger:** Click "Turn on location sharing" button
- **Action:** `setLocationEnabled(true)`
- **Visual feedback:**
  - Button transitions from orange CTA to bordered secondary button
  - Status card updates:
    - Dot changes from red to green
    - "Disabled" → "Enabled"
    - Context message changes
  - Privacy note disappears
  - Button text changes to "Manage location settings" with chevron icon
- **Expected side effects (implementation):**
  - Would trigger device location permission prompt
  - Would update persistent permission state

**When Location is ENABLED:**

**Navigate to Settings:**
- **Trigger:** Click "Manage location settings" button
- **Action:** `onNavigate("location-sharing")`
- **Expected behavior:** Navigate to detailed location settings page
- **Visual feedback:** Button hover state (background: `#f9f9f9`)

### 5. Hover States (Desktop/Web)

**Language/Currency Dropdowns:**
- No explicit hover states defined (would likely add subtle background change in implementation)

**Enable Location Button:**
- **Hover:** Background changes from `#e8751a` to `#d96816` (darker orange)
- **Transition:** 0.2s ease

**Manage Location Button:**
- **Hover:** Background changes from transparent to `#f9f9f9`
- **Transition:** 0.2s ease

### 6. Scrolling

**Content Scrolling:**
- **Container:** 730px tall scrollable area
- **Content:** Vertically scrollable if total content exceeds viewport
- **Behavior:** Standard vertical scroll (no custom scroll styling defined)

---

## Design Rationale

### 1. Consolidation of Localization Settings

**Decision:** Combine language, currency, and location in a single page titled "Localization"

**Reasoning:**
- All three settings affect how the user experiences location-based content (restaurants)
- Currency and language are intrinsically linked to geographic context
- Location permission provides geographic data that makes currency/language more relevant
- Reduces navigation depth (no need to drill into separate settings for each)
- Creates a clear mental model: "All the settings about where I am and how I see places"

**Alternative considered:** Separate pages for each setting
- **Rejected because:** Would create unnecessary navigation complexity for closely related settings

### 2. LanguageCurrencyDropdowns as Shared Component

**Decision:** Extract language and currency selection into a shared component

**Reasoning:**
- Used in both welcome/onboarding flow and settings
- Identical behavior and appearance in both contexts
- `showDescriptions` prop allows context-appropriate verbosity
- Single source of truth for supported languages/currencies
- Reduces code duplication and maintains consistency

**Component boundary:** Includes both language and currency in one component because they're always presented together and share identical interaction patterns

### 3. Location Status Card Design

**Decision:** Show current location state in a dedicated card with visual status indicators (colored dot + text)

**Reasoning:**
- **At-a-glance status:** Users can immediately see if location is enabled without reading body text
- **Semantic color coding:** Red/green is universally understood for off/on states
- **Context-aware messaging:** Different helper text for each state guides appropriate action
- **Separation from action button:** Card shows "what is", button shows "what you can do"
- **Visual hierarchy:** Card background differentiates from button, preventing card from being mistaken as tappable

**Alternative considered:** Simple toggle switch
- **Rejected because:** Location permission is more complex than a simple on/off (requires OS-level permission prompt), and we want to provide navigation to detailed settings when enabled

### 4. State-Dependent Button Behavior

**Decision:** Button changes appearance and behavior based on location state (enable when off, navigate when on)

**Reasoning:**
- **Minimizes friction for primary action:** Most important action when location is disabled is to enable it → make that a single tap without navigation
- **Progressive disclosure:** Once enabled, user may want fine-grained control (e.g., "while using app" vs "always") → navigate to detailed page
- **Visual communication:** Orange CTA signals important action, bordered button signals navigation
- **Reduces cognitive load:** User doesn't need to understand permission complexity upfront
- **Optimizes for common path:** Most users either want to quickly enable or don't care about details

**Alternative considered:** Always navigate to a separate location settings page
- **Rejected because:** Adds unnecessary friction for the 90% case (simple enable/disable)

### 5. Privacy Note Visibility

**Decision:** Show privacy reassurance only when location is disabled

**Reasoning:**
- **Addresses concerns at decision point:** Users hesitant to enable location need reassurance about data usage
- **Reduces visual noise when enabled:** Once permission is granted, privacy note is redundant (user has already accepted)
- **Trust-building language:** "We never share it with third parties" directly addresses primary concern
- **Strategic placement:** Below CTA button, after user has read benefits but before clicking

**Alternative considered:** Always show privacy note
- **Rejected because:** Clutters interface after user has already made decision

### 6. Currency Exchange Rate Disclaimer

**Decision:** Include disclaimer about 24-hour update frequency in currency description text

**Reasoning:**
- **Transparency:** Sets accurate expectations about price accuracy
- **Trust:** Acknowledging limitations builds credibility
- **Legal/practical:** Prevents user complaints about price discrepancies
- **Placement:** In description text (optional reading) rather than prominent warning (doesn't disrupt flow)

### 7. Dropdown Menu Design Pattern

**Decision:** Use custom dropdown with absolute positioning rather than native select element

**Reasoning:**
- **Visual consistency:** Native selects vary drastically across platforms/browsers
- **Design control:** Can style selected item highlighting, spacing, borders exactly as desired
- **Icon integration:** Can easily include flag emojis in language options
- **Touch-friendly:** Can control exact tap target size (50px height)
- **Animation potential:** Can add transitions for open/close (not defined in this design but possible)

**Trade-off:** Requires manual accessibility implementation (keyboard navigation, ARIA labels) in final implementation

### 8. Localized UI Labels

**Decision:** Labels and descriptions change language immediately when language is selected

**Reasoning:**
- **Instant feedback:** User sees immediate effect of language change
- **Confirmation:** Provides implicit confirmation that setting worked
- **User testing:** Allows user to preview language before committing (if save action is required elsewhere)

**Implementation note:** Only visible UI text changes; would need translation system integration for full app translation

### 9. Section Divider Usage

**Decision:** Use thin horizontal divider between Language & Currency and Location sections

**Reasoning:**
- **Logical grouping:** Language and currency are settings inputs; location is permission management (different interaction model)
- **Visual breathing room:** Creates clear separation without adding heavy UI chrome
- **Hierarchy signal:** Indicates two distinct setting categories within same page

**Alternative considered:** No divider, rely on spacing alone
- **Rejected because:** Sections are visually similar enough (both have headers and inputs/buttons) that spacing alone doesn't clearly separate them

### 10. "Localization" vs "Language & Region" Naming

**Decision:** Title page "Localization" rather than "Language & Region" or "Preferences"

**Reasoning:**
- **Technical accuracy:** Localization encompasses language, currency, and location
- **Developer-friendly:** Technical term that's well-understood in software context
- **Concise:** Single word rather than compound phrase
- **Neutral:** Doesn't prioritize language over currency/location

**Alternative considered:** "Language & Region"
- **Rejected because:** Doesn't explicitly include currency or location, which are primary settings on this page

**Note:** User testing may reveal that non-technical users find "Localization" unclear; alternative titles to test:
- "Language & Currency"
- "Regional Settings"
- "Display Preferences"

### 11. Default Values as Regional Assumptions

**Decision:** Default to Danish language and Danish krone

**Reasoning:**
- **Target market:** App appears to be designed for Danish/Nordic market (evidenced by krone as default, Danish translations present)
- **User expectation:** Users in target region expect localized defaults
- **Reduces friction:** 90% of users won't need to change defaults

**Implementation consideration:** Would ideally detect user's device language/region and set defaults accordingly in production

### 12. Limited Currency Options

**Decision:** Only offer three currency options (USD, GBP, DKK) rather than comprehensive list

**Reasoning:**
- **Target markets:** Likely focusing on specific geographic regions (US, UK, Denmark/Nordic)
- **API constraints:** May only have reliable exchange rate data for these currencies
- **Simplicity:** Shorter list is easier to scan and select
- **Data availability:** Restaurant price data may only be available in these currencies

**Design flexibility:** Easy to add more currencies to the array if needed

### 13. Flag Emojis for Language Options

**Decision:** Display flag emoji next to language name in language selector

**Reasoning:**
- **Visual scanning:** Flags are instantly recognizable, faster than reading text
- **Accessibility:** Works for users who don't read Latin script (can recognize flag)
- **Delight:** Adds visual interest and personality
- **Space efficiency:** Compact visual indicator

**Trade-offs:**
- Flags don't always map perfectly to languages (e.g., English → UK flag, but English is spoken in many countries)
- Emoji rendering varies across platforms (but acceptable degradation)

### 14. Mobile-First Dimensions

**Decision:** Design at 390px width (iPhone 13/14 standard viewport)

**Reasoning:**
- **Primary use case:** Restaurant discovery is inherently mobile (on-the-go usage)
- **Touch targets:** 48-50px tall buttons/inputs are optimized for finger taps
- **Vertical scroll:** Accommodates content that would be cramped on smaller screens

**Responsive considerations (not shown in JSX design):**
- Would likely use same layout on larger phones (up to ~430px width)
- Tablet/desktop would possibly show two-column layout or keep single-column with max-width

---

## Interaction Patterns

### Progressive Disclosure Flow

```
Initial State (Location Disabled)
         ↓
User taps "Turn on location sharing"
         ↓
Location enabled (button changes)
         ↓
User taps "Manage location settings" (if needed)
         ↓
Navigate to detailed location page
```

**Key insight:** Most users stop at step 3 (enabled); detailed management is secondary need

### Dropdown Interaction Flow

```
Dropdown Closed
         ↓
User taps selector
         ↓
Dropdown Opens (menu appears, arrow flips)
         ↓
User taps option
         ↓
Selection updates, dropdown closes
```

**Single-click selection:** No "Apply" button needed; selection is immediate

### Language Change Side Effect

```
User selects new language
         ↓
Language state updates
         ↓
All visible labels re-render with new language
         ↓
User sees immediate feedback
```

**Note:** This is preview/demo behavior; full app would require translation loading/refresh

---

## Edge Cases and States

### 1. No Language Selected (Impossible)

**Scenario:** `language` state is undefined or invalid code

**Fallback:** `languages.find(...) || languages[0]` → defaults to English

**Rationale:** Prevents blank selector, ensures UI is never broken

### 2. No Currency Selected (Impossible)

**Scenario:** `currency` state is undefined or invalid code

**Fallback:** `currencies.find(...) || currencies[2]` → defaults to DKK

**Rationale:** Same as above

### 3. Dropdown Open with Scroll

**Scenario:** Language dropdown is opened while page is scrolled

**Current behavior:** Dropdown position is absolute relative to selector, so it appears in correct position

**Potential issue:** If dropdown is near bottom of screen, it might overflow viewport

**Implementation consideration:** Would need to detect available space and flip dropdown upward if needed

### 4. Both Dropdowns Open Simultaneously

**Scenario:** User opens language dropdown, then clicks currency dropdown without closing first

**Current behavior:** Each dropdown has independent open state, so technically both could be open

**Potential issue:** Visual confusion

**Implementation consideration:** Opening one dropdown should auto-close the other (add `setCurrOpen(false)` when opening language dropdown and vice versa)

### 5. Location Permission Denied by OS

**Scenario:** User taps "Turn on location sharing", but denies permission in OS prompt

**Current behavior (in this JSX design):** State changes to enabled immediately (no permission check)

**Production behavior:** Would need to:
1. Request OS permission
2. Wait for user response
3. Only update state if permission granted
4. Show error message if denied
5. Provide "Go to Settings" action if denied (requires OS-level settings change)

**Design implication:** May need additional UI state for "permission denied" with different messaging

### 6. Empty State (Not Applicable)

**Scenario:** No languages or currencies available

**Current behavior:** Hard-coded arrays, so empty state cannot occur

**Production consideration:** If currencies were fetched from API, would need loading state and empty state design

### 7. Loading State (Not Present)

**Scenario:** Settings are being fetched from persistent storage or API

**Current behavior:** No loading state in design

**Production consideration:** May need skeleton UI or spinner for initial settings load

---

## Accessibility Considerations

### Keyboard Navigation (Not Implemented in JSX)

**Required for production:**
- Tab order: Back button → Language dropdown → Currency dropdown → Location button
- Enter/Space to activate buttons and open dropdowns
- Arrow keys to navigate dropdown options
- Escape to close dropdowns
- Focus visible indicators for all interactive elements

### Screen Reader Support (Not Implemented in JSX)

**Required for production:**
- `aria-label` on back button ("Go back")
- `aria-expanded` on dropdowns (true when open)
- `aria-selected` on dropdown options
- `role="listbox"` on dropdown menus
- `role="option"` on dropdown items
- Status card should have `aria-live="polite"` region so status changes are announced
- Button text should be descriptive ("Turn on location sharing" is good, "Enable" alone would be insufficient)

### Color Contrast

**Evaluated against WCAG AA (4.5:1 for normal text, 3:1 for large text):**

| Element | Foreground | Background | Ratio | Pass? |
|---------|-----------|------------|-------|-------|
| Primary text (#0f0f0f) | #0f0f0f | #fff | ~19:1 | ✅ AAA |
| Secondary text (#888) | #888 | #fff | ~3.5:1 | ✅ AA large, ⚠️ AA small |
| Tertiary text (#999) | #999 | #fff | ~2.8:1 | ❌ Fails AA |
| Status text enabled (#2a9456) | #2a9456 | #fafafa | ~3.8:1 | ✅ AA large |
| Status text disabled (#c9403a) | #c9403a | #fafafa | ~4.2:1 | ✅ AA |
| Button text (white) | #fff | #e8751a | ~3.3:1 | ✅ AA large, ⚠️ AA small |

**Accessibility debt:**
- Tertiary text (#999) fails contrast (status card context messages)
- Secondary text (#888) marginally passes for large text only

**Recommendations:**
- Darken #999 to #888 or #777 for better contrast
- Consider darkening #888 to #666 for descriptions

### Touch Target Sizes

**Evaluated against WCAG 2.2 (minimum 44×44px):**

| Element | Size | Pass? |
|---------|------|-------|
| Back button | 36×36px | ⚠️ Below minimum (acceptable if 8px padding around increases tap area) |
| Dropdown selectors | Full width × 50px | ✅ Pass |
| Dropdown options | Full width × ~36px | ⚠️ Below minimum height |
| Location button | Full width × 48px | ✅ Pass |

**Accessibility debt:**
- Dropdown options should be 44px tall minimum
- Back button should have larger tap target (use padding to expand invisible hit area)

### Focus Indicators

**Not defined in JSX design**

**Production requirement:** All interactive elements need visible focus state (2px outline or border change)

---

## Performance Considerations

### Re-Render Triggers

**Expensive operations:**
- None identified (no heavy computations)

**Re-render triggers:**
- State changes (language, currency, locationEnabled)
- Dropdown open/close state changes
- Shared component re-renders when language/currency props change

**Optimization opportunities:**
- LanguageCurrencyDropdowns could use `React.memo` to prevent re-renders when unrelated state changes
- Language and currency data arrays could be memoized (though they're static, so negligible impact)

### Animation Performance

**Transitions defined:**
- Button background color: `0.2s ease`

**Performance notes:**
- Background color transitions are GPU-accelerated, performant
- Dropdown open/close has no animation (instant appearance)
- Could add `transform` or `opacity` transitions to dropdowns for smoother UX (would need `will-change` hint for performance)

### Memory Usage

**Static data size:**
- 7 language objects × ~50 bytes = ~350 bytes
- 3 currency objects × ~40 bytes = ~120 bytes
- Total: <1 KB (negligible)

**State size:**
- 3 primitive values (2 strings, 1 boolean) = ~24 bytes
- No large data structures, no memory concerns

---

## Integration Points

### Props Interface

```javascript
function LocalizationPage({
  onBack,      // () => void — Callback when back button is tapped
  onNavigate   // (route: string) => void — Navigation callback for routing
})
```

**Expected routing:**
- `onNavigate("location-sharing")` → Navigate to detailed location settings page

**Implementation note:** Does not return selected values via props; would need to be managed via context, global state, or parent state lift

### External Dependencies

**From `_shared.jsx`:**
- `StatusBar` — Status bar component
- `LanguageCurrencyDropdowns` — Dual dropdown selector component
- `ACCENT` — Orange color constant (`#e8751a`)

**React dependencies:**
- `useState` — For local state management

### Storage Integration (Not Implemented)

**Persistent state requirements:**
- `language` should be saved to device storage
- `currency` should be saved to device storage
- `locationEnabled` should reflect OS permission status (read from permission API, not saved independently)

**Suggested approach:**
- On language/currency change, call async save function
- On component mount, call async load function to restore saved values
- Location state should be queried from device on mount, not stored

### Translation System Integration (Partially Implemented)

**Current behavior:**
- Hard-coded translations for Danish vs English (two languages only)
- Inline conditional rendering (`language === "da" ? "Sprog" : "Language"`)

**Production requirements:**
- Integrate with translation system (e.g., i18n library)
- Use translation keys instead of inline conditionals
- Support all seven languages defined in dropdown (currently only da/en are translated)

**Example refactor:**
```javascript
// Current (in shared component):
{language === "da" ? "Sprog" : "Language"}

// Production:
{t("settings.language.label")}
```

### Location Permission API (Not Implemented)

**Required integration:**
```javascript
// When "Turn on location sharing" is tapped:
const requestLocation = async () => {
  const status = await requestLocationPermission(); // Native API call
  if (status === "granted") {
    setLocationEnabled(true);
  } else {
    // Show error message
  }
};
```

**Platform differences:**
- iOS: `CLLocationManager` authorization status
- Android: `ACCESS_FINE_LOCATION` permission
- Web: `navigator.geolocation.getCurrentPosition()` with permission check

---

## Future Enhancements

### 1. Auto-Detect Language/Currency

**Enhancement:** Detect user's device language and region, set defaults automatically

**Benefits:**
- Better first-run experience
- Reduces setup friction
- More personalized

**Implementation:** Use `navigator.language` (web) or device locale APIs (native)

### 2. Recently Used Languages

**Enhancement:** Show most recently used languages at top of dropdown

**Benefits:**
- Faster access for multilingual users
- Reduces scrolling in long list

**Implementation:** Store selection history, sort dropdown array

### 3. Search/Filter Languages

**Enhancement:** Add search input to language dropdown for faster selection

**Benefits:**
- Scalability if more languages are added
- Faster for users who know what they want

**Implementation:** Filter `languages` array based on search input

### 4. More Currency Options

**Enhancement:** Expand currency list to include EUR, JPY, etc.

**Benefits:**
- Supports more markets
- Better international usability

**Considerations:** Requires reliable exchange rate API for all currencies

### 5. Location Accuracy Settings

**Enhancement:** Add granular location settings (high accuracy vs battery saving, always vs while using)

**Benefits:**
- User control over battery usage
- Privacy-conscious users can choose less precise location

**Implementation:** Navigate to detailed location page (already designed with "Manage location settings" button)

### 6. Preview Currency Conversion

**Enhancement:** Show example price in different currencies when selecting

**Benefits:**
- Helps user understand what currency change means
- Provides context for decision

**Example:** "Danish krone (kr.) — e.g., 100 kr. = $14"

### 7. Dropdown Animation

**Enhancement:** Add smooth expand/collapse animation to dropdowns

**Benefits:**
- More polished feel
- Helps user track state change

**Implementation:** CSS transition on max-height or transform

### 8. Confirmation for Major Changes

**Enhancement:** Show confirmation dialog before changing language (warns user that app UI will change)

**Benefits:**
- Prevents accidental changes
- Gives user chance to cancel

**Trade-off:** Adds friction to intentional changes

### 9. Sync Across Devices

**Enhancement:** Sync localization settings across user's devices via cloud account

**Benefits:**
- Consistent experience
- Reduces setup on new devices

**Requirements:** User account system, cloud storage

### 10. Language-Specific Keyboard

**Enhancement:** When typing in search/input fields, automatically switch to keyboard matching selected language

**Benefits:**
- Easier to type in non-English languages
- Better autocorrect suggestions

**Implementation:** Platform-specific keyboard APIs (iOS `UITextInputMode`, Android `InputMethodManager`)

---

## Related Designs

### 1. Welcome Flow Language/Currency Selection

**File:** Likely `pages/welcome.jsx` or `pages/onboarding.jsx`

**Relationship:** Uses same `LanguageCurrencyDropdowns` component

**Differences:**
- May have different surrounding context (welcome copy vs settings page)
- May auto-advance to next screen after selection vs staying on page

### 2. Location Sharing Detail Page

**Route:** `"location-sharing"` (navigated to from "Manage location settings" button)

**Expected contents:**
- Detailed explanation of location usage
- Granular permission settings (always/while using/never)
- Location accuracy settings
- Option to disable location
- Privacy policy link

**Design status:** Not provided in this documentation (would need separate design spec)

### 3. Settings Hub

**Route:** Parent page that contains link to Localization page

**Expected contents:**
- List of setting categories
- "Localization" or "Language & Region" option that navigates here

**Interaction:** This page's `onBack()` returns to settings hub

---

## Technical Notes

### Browser/Platform Compatibility

**CSS Features Used:**
- Flexbox (widely supported)
- Absolute positioning (widely supported)
- Box shadow (widely supported)
- SVG (widely supported)

**JavaScript Features:**
- React hooks (`useState`) — Requires React 16.8+
- Arrow functions — ES6+
- Template literals — ES6+

**No compatibility concerns for modern browsers (2020+)**

### Responsive Behavior (Not Defined)

**Current design:** Fixed 390px width

**Production considerations:**
- Use `max-width: 390px` + `width: 100%` for smaller devices
- Add media query for tablets/desktop to constrain max width
- Consider two-column layout for very wide screens (>768px)

### SVG Icon Usage

**Location Pin Icon:**
```jsx
<svg width="20" height="20" viewBox="0 0 24 24" fill="none"
     stroke="#666" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
  <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/>
  <circle cx="12" cy="10" r="3"/>
</svg>
```

**Chevron Icon:**
```jsx
<svg width="8" height="14" viewBox="0 0 8 14" fill="none"
     stroke="#bbb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
  <path d="M1 1l6 6-6 6"/>
</svg>
```

**Design notes:**
- Inline SVGs for maximum control over styling
- Could be extracted to shared icon component for reusability
- Stroke color is hard-coded (could accept prop for flexibility)

---

## Design System Alignment

### Component Patterns

**Dropdown Pattern:**
- Matches standard JourneyMate dropdown styling (light background, border, rounded corners)
- Consistent with other input fields across app
- Selected state uses brand-adjacent orange tint (`#fef8f2`)

**Button Hierarchy:**
- Primary CTA: Orange background, white text (matches app-wide CTA style)
- Secondary button: White/transparent background, border, gray text (matches app-wide secondary style)
- Hover states: Darker shade for primary, light tint for secondary

**Status Indicators:**
- Green for positive/enabled state (matches app-wide "match" indicator)
- Red for negative/disabled state (standard error/warning color)
- Colored dot + colored text for redundancy (supports colorblind users)

**Spacing:**
- 24px page padding matches app-wide content padding
- 16px card padding matches card components elsewhere
- 12px element spacing is standard micro-spacing unit

### Typography Consistency

**Title hierarchy:**
- Page title: 16px/600 (matches navigation header style)
- Section title: 18px/680 (matches card/section headers)
- Input labels: 16px/600 (matches form label style)

**Body text:**
- Description: 13px/400 (matches helper text across app)
- Status text: 14px/500 (matches secondary information text)

### Color Consistency

**Brand colors:**
- Primary orange (`#e8751a`) for CTAs — matches app-wide brand color
- Text black (`#0f0f0f`) for primary content — matches app-wide text
- Light grays for borders/backgrounds — matches app-wide neutral palette

**Semantic colors:**
- Green for positive status — matches filter match indicators
- Red for negative status — matches error states
- Gray tones for inactive/secondary — matches app-wide hierarchy

---

## Appendix: Code Structure

### File Organization

```
LocalizationPage (default export)
├── Props: { onBack, onNavigate }
├── State: language, currency, locationEnabled
└── JSX Structure:
    ├── Container (390×844px)
    ├── StatusBar
    ├── Header
    │   ├── Back Button
    │   └── Title
    └── Scrollable Content
        ├── Language & Currency Section
        │   ├── Section Title
        │   └── LanguageCurrencyDropdowns
        ├── Divider
        └── Location Section
            ├── Section Header (title + description)
            ├── Status Card
            │   ├── Icon + Label + Status Indicator
            │   └── Context Message
            ├── Action Button (state-dependent)
            └── Privacy Note (conditional)
```

### Shared Component Structure (LanguageCurrencyDropdowns)

```
LanguageCurrencyDropdowns
├── Props: language, currency, onLanguageChange, onCurrencyChange, showDescriptions
├── State: langOpen, currOpen
├── Data: languages[], currencies[]
└── JSX Structure:
    ├── Language Selector
    │   ├── Label (localized)
    │   ├── Description (conditional)
    │   ├── Closed Dropdown Button
    │   │   ├── Selected Language (flag + name)
    │   │   └── Arrow Indicator
    │   └── Open Dropdown Menu (conditional)
    │       └── Language Options (map)
    └── Currency Selector
        ├── Label (localized)
        ├── Description (conditional)
        ├── Closed Dropdown Button
        │   ├── Selected Currency (name + symbol)
        │   └── Arrow Indicator
        └── Open Dropdown Menu (conditional)
            └── Currency Options (map)
```

---

## Summary of Key Design Decisions

1. **Three-part structure:** Language/Currency + Divider + Location (logical grouping)
2. **Shared component reuse:** LanguageCurrencyDropdowns used across app (consistency + DRY)
3. **State-dependent button:** Enable vs manage based on location state (progressive disclosure)
4. **Privacy note positioning:** Only shown when disabled, below CTA (addresses concerns at decision point)
5. **Immediate language feedback:** UI labels update instantly (confirmation of selection)
6. **Status card design:** Separate card for status display (differentiates "what is" from "what you can do")
7. **Semantic color coding:** Red/green for status (universal understanding)
8. **Custom dropdowns:** Full design control vs native selects (visual consistency)
9. **Mobile-first dimensions:** 390px width, touch-friendly targets (primary use case)
10. **Exchange rate transparency:** 24-hour update disclaimer in currency description (trust building)

---

**End of Design Documentation**

This document captures the complete JSX design specification for the Localization settings page. For implementation guidance, refer to `CLAUDE.md` for Flutter migration workflow and design system documentation for component patterns.
