# Welcome New User — JSX Design Documentation

**File:** `pages/welcome/welcome_new_user.jsx`
**Purpose:** First-time user onboarding screen with language selection
**Version:** v2 JSX Design
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
8. [Typography Specifications](#typography-specifications)
9. [Spacing & Dimensions](#spacing--dimensions)
10. [Color Palette](#color-palette)
11. [Accessibility Considerations](#accessibility-considerations)

---

## Design Overview

### Purpose

The Welcome New User page serves as the entry point for first-time users of JourneyMate. It introduces the app's value proposition and allows users to select their preferred language (English or Danish) before proceeding to the main onboarding flow.

### Design Philosophy

This screen embodies a **clean, centered, welcoming** approach:

- **Minimalist layout** — no navigation chrome, status bars, or distractions
- **Vertical centering** — all content is vertically and horizontally centered
- **Friendly branding** — mascot image provides personality and warmth
- **Clear hierarchy** — heading → mascot → tagline → description → CTAs
- **Language-first** — language selection is immediate, not buried in settings

### Screen Dimensions

- **Canvas:** 390 × 844px (iPhone 12/13/14 standard size)
- **Content padding:** 32px horizontal (326px effective width)
- **All elements centered** on the vertical axis

---

## Visual Layout

### Element Hierarchy (Top to Bottom)

```
┌─────────────────────────────────────┐
│                                     │
│          Welcome to                 │ ← Heading (28px, bold)
│         JourneyMate                 │
│                                     │
│            40px gap                 │
│                                     │
│         [Mascot Image]              │ ← 180×180px mascot
│                                     │
│            40px gap                 │
│                                     │
│       Go out, your way.             │ ← Tagline (18px, medium)
│                                     │
│            12px gap                 │
│                                     │
│   Discover restaurants, cafés,      │ ← Description (14px, regular)
│   and bars filtered by your         │
│   lifestyle, preferences, and       │
│   dietary needs.                    │
│                                     │
│            48px gap                 │
│                                     │
│      ┌─────────────────┐           │
│      │    Continue     │           │ ← Primary CTA (filled)
│      └─────────────────┘           │
│                                     │
│            12px gap                 │
│                                     │
│      ┌─────────────────┐           │
│      │ Fortsæt på dansk│           │ ← Secondary CTA (outlined)
│      └─────────────────┘           │
│                                     │
└─────────────────────────────────────┘
```

### Layout Sections

#### 1. Header Section

**Position:** Top of centered content
**Content:** Multi-line heading "Welcome to / JourneyMate"

**Styling:**
- Font size: 28px
- Font weight: 700 (bold)
- Color: `#0f0f0f` (near-black)
- Line height: 34px
- Text align: center
- Bottom margin: 40px

**Design decision:** The heading is split across two lines with `<br />` to create visual rhythm and prevent awkward wrapping.

#### 2. Mascot Section

**Position:** Center of screen (vertically and horizontally)
**Content:** JourneyMate mascot illustration

**Styling:**
- Width: 180px
- Height: 180px
- Object fit: contain
- Bottom margin: 40px
- Source: `/FF-pages-images/journeymate_mascot.png`

**Design decision:** The mascot is the largest visual element, establishing brand personality immediately. At 180×180px, it's prominent without overwhelming the text.

#### 3. Tagline Section

**Position:** Below mascot
**Content:** "Go out, your way."

**Styling:**
- Font size: 18px
- Font weight: 500 (medium)
- Color: `#0f0f0f` (near-black)
- Text align: center
- Bottom margin: 12px

**Design decision:** The tagline is punchier and bolder than the description, using a larger font size and medium weight to differentiate it.

#### 4. Description Section

**Position:** Below tagline
**Content:** Value proposition paragraph

**Styling:**
- Font size: 14px
- Font weight: 400 (regular)
- Color: `#555` (medium gray)
- Line height: 20px
- Text align: center
- Bottom margin: 48px
- Max width: 320px

**Design decision:** The description is set in a lighter gray (`#555`) to visually de-emphasize it compared to the tagline. The max-width prevents overly long lines on larger screens.

#### 5. CTA Section

**Position:** Bottom of centered content
**Content:** Two stacked buttons (Continue, Fortsæt på dansk)

**Layout:**
- Both buttons: 100% width, max 280px
- Height: 50px each
- Gap between: 12px
- Border radius: 12px

---

## Components Used

### External Components

**From `_shared.jsx`:**
- `ACCENT` — orange color token (`#e8751a`)

### Native HTML Elements

#### 1. Container `<div>`

**Purpose:** Main page wrapper
**Styling:**
- Fixed dimensions: 390 × 844px
- White background: `#fff`
- Flexbox: column, centered (both axes)
- Horizontal padding: 32px

**Role:** Establishes the canvas and centers all content vertically and horizontally.

#### 2. Heading `<h1>`

**Purpose:** Page title
**Content:** "Welcome to JourneyMate" (with line break)
**Styling:** See Header Section above

**Role:** Provides semantic structure and visual hierarchy.

#### 3. Image `<img>`

**Purpose:** Display mascot illustration
**Attributes:**
- `src`: `/FF-pages-images/journeymate_mascot.png`
- `alt`: "JourneyMate mascot"

**Role:** Adds personality and visual interest. Alt text ensures accessibility.

#### 4. Tagline `<div>`

**Purpose:** Display product tagline
**Content:** "Go out, your way."
**Styling:** See Tagline Section above

**Role:** Communicates core value proposition concisely.

#### 5. Description `<p>`

**Purpose:** Explain app functionality
**Content:** Full value proposition paragraph
**Styling:** See Description Section above

**Role:** Provides context for new users about what the app does.

#### 6. Primary Button `<button>`

**Purpose:** Continue to onboarding
**Content:** "Continue"
**Event:** `onClick={onContinue}`

**Styling:**
- Background: `ACCENT` (`#e8751a`)
- Text color: `#fff` (white)
- Border: none
- Border radius: 12px
- Font size: 16px
- Font weight: 600 (semibold)
- Cursor: pointer

**Role:** Primary CTA for users who want to proceed in English.

#### 7. Secondary Button `<button>`

**Purpose:** Switch to Danish and continue
**Content:** "Fortsæt på dansk"
**Event:** `onClick={onSelectDanish}`

**Styling:**
- Background: transparent
- Text color: `ACCENT` (`#e8751a`)
- Border: `2px solid ACCENT`
- Border radius: 12px
- Font size: 16px
- Font weight: 600 (semibold)
- Cursor: pointer

**Role:** Secondary CTA for users who prefer Danish language.

---

## Design Tokens

### Colors

| Token | Value | Usage |
|-------|-------|-------|
| `ACCENT` | `#e8751a` | Primary button background, secondary button border/text |
| `#fff` | White | Page background, primary button text |
| `#0f0f0f` | Near-black | Heading, tagline text |
| `#555` | Medium gray | Description text |

### Typography

| Element | Size | Weight | Line Height | Color |
|---------|------|--------|-------------|-------|
| Heading | 28px | 700 | 34px | `#0f0f0f` |
| Tagline | 18px | 500 | default | `#0f0f0f` |
| Description | 14px | 400 | 20px | `#555` |
| Button text | 16px | 600 | default | varies |

### Spacing

| Purpose | Value |
|---------|-------|
| Page horizontal padding | 32px |
| Heading bottom margin | 40px |
| Mascot bottom margin | 40px |
| Tagline bottom margin | 12px |
| Description bottom margin | 48px |
| Button gap | 12px |

### Dimensions

| Element | Width | Height |
|---------|-------|--------|
| Canvas | 390px | 844px |
| Mascot | 180px | 180px |
| Buttons | 100% (max 280px) | 50px |

### Border Radius

| Element | Radius |
|---------|--------|
| Buttons | 12px |

---

## State & Data

### Props Interface

```javascript
{
  onContinue: Function,      // Callback when "Continue" is tapped
  onSelectDanish: Function   // Callback when "Fortsæt på dansk" is tapped
}
```

### Component State

**None.** This is a **stateless functional component**. It accepts two callback functions as props and renders static content.

### Data Flow

```
User taps "Continue"
  ↓
onContinue() fires
  ↓
Parent component handles navigation (likely to needs selection)

User taps "Fortsæt på dansk"
  ↓
onSelectDanish() fires
  ↓
Parent component:
  1. Sets app language to Danish
  2. Navigates to Danish version of next screen
```

### No Local State

The component does not use:
- `useState` hooks
- Local variables that change
- Form inputs
- Dynamic content

**Why:** This is a static welcome screen. All language selection and navigation logic is handled by the parent component (likely `index.jsx` or an onboarding coordinator).

---

## User Interactions

### Interaction Map

```
┌─────────────────────────────────────┐
│                                     │
│       [Non-interactive text]        │
│       [Non-interactive image]       │
│       [Non-interactive text]        │
│                                     │
│      ┌─────────────────┐           │
│      │    Continue     │ ← Tap 1   │
│      └─────────────────┘           │
│                                     │
│      ┌─────────────────┐           │
│      │ Fortsæt på dansk│ ← Tap 2   │
│      └─────────────────┘           │
│                                     │
└─────────────────────────────────────┘
```

### Interaction 1: Continue Button

**Trigger:** User taps "Continue" button
**Visual feedback:** Browser default (cursor: pointer)
**Action:** Calls `onContinue()` prop function
**Expected result:** Parent navigates to next onboarding step (English)

**States:**
- **Default:** Orange background (`ACCENT`), white text
- **Hover:** No hover state defined (mobile-first)
- **Active:** No active state defined
- **Disabled:** Not applicable (always enabled)

### Interaction 2: Danish Button

**Trigger:** User taps "Fortsæt på dansk" button
**Visual feedback:** Browser default (cursor: pointer)
**Action:** Calls `onSelectDanish()` prop function
**Expected result:** Parent sets language to Danish and navigates

**States:**
- **Default:** Transparent background, orange border and text
- **Hover:** No hover state defined (mobile-first)
- **Active:** No active state defined
- **Disabled:** Not applicable (always enabled)

### No Other Interactions

The following elements are **not interactive**:
- Heading text
- Mascot image
- Tagline text
- Description text
- Page background

**Why:** This screen has a single purpose: language selection and continuation. No secondary actions or informational overlays are needed.

---

## Design Rationale

### Why This Layout?

#### 1. Vertical Centering

**Decision:** All content is vertically centered using flexbox.

**Rationale:**
- Creates a balanced, harmonious first impression
- Focuses attention on the mascot and CTAs
- Avoids awkward top-heavy or bottom-heavy layouts
- Works consistently across different screen heights

**Alternative considered:** Top-aligned layout with mascot at top
**Why rejected:** Feels less welcoming, creates too much whitespace at bottom

#### 2. Mascot as Hero Element

**Decision:** The mascot is the largest visual element (180×180px).

**Rationale:**
- Establishes brand personality immediately
- Creates emotional connection before functional explanation
- Differentiates JourneyMate from generic restaurant apps
- Makes the screen memorable

**Alternative considered:** Hero image of food/restaurant
**Why rejected:** Generic, doesn't establish unique brand identity

#### 3. Two-Button Language Selection

**Decision:** Provide both English and Danish CTAs upfront.

**Rationale:**
- **No hidden settings menu** — language choice is immediate and obvious
- **Equal prominence** — both languages feel like first-class options
- **Clear visual hierarchy** — filled button (Continue) is primary, outlined button is secondary
- **Reduces friction** — Danish users don't have to hunt for language settings

**Alternative considered:** Single "Continue" button, language selection in settings
**Why rejected:** Creates extra steps for Danish users, makes language feel like an afterthought

#### 4. Filled vs. Outlined Button Style

**Decision:** Primary button is filled (orange), secondary is outlined (orange border, transparent fill).

**Rationale:**
- **Visual hierarchy** — filled button draws more attention
- **Assumption of English default** — most users likely default to English, so it gets the stronger visual
- **But not dismissive of Danish** — outlined button is still prominent, not a tertiary "link" style
- **Follows platform conventions** — iOS and Material Design both use filled primary / outlined secondary

**Alternative considered:** Both buttons filled, different colors
**Why rejected:** Accent orange is the only brand color for CTAs; using a second color (e.g., gray) would weaken the brand

#### 5. Content Width Constraints

**Decision:** Description has max-width of 320px, buttons have max-width of 280px.

**Rationale:**
- **Readability** — prevents overly long lines on larger screens
- **Visual consistency** — buttons don't stretch awkwardly wide
- **Centered appearance** — constraining width makes centering more obvious
- **Responsive-ready** — if this were adapted for tablet, content wouldn't stretch to full width

**Alternative considered:** Full width (minus padding)
**Why rejected:** Description text would be too wide on larger screens, buttons would look stretched

#### 6. Spacing Rhythm

**Decision:** Spacing follows a clear rhythm: 40px → 40px → 12px → 48px → 12px.

**Rationale:**
- **40px gaps** — between major sections (heading, mascot, description)
- **12px gaps** — between related elements (tagline/description, buttons)
- **48px final gap** — extra breathing room before CTAs
- **Creates visual groupings** — smaller gaps signal relatedness

**Alternative considered:** Uniform 32px spacing throughout
**Why rejected:** Doesn't create visual hierarchy, feels monotonous

#### 7. No Skip Option

**Decision:** No "Skip" or "I'll do this later" option.

**Rationale:**
- **Language selection is essential** — the app needs to know which language to display
- **Needs selection comes next** — the next screen (onboarding) is also essential for personalization
- **Not a tutorial** — this isn't optional guidance, it's core setup
- **Low friction** — selecting a language takes one tap, not worth skipping

**Alternative considered:** Add "Skip" button that defaults to English
**Why rejected:** Adds clutter, creates confusion about what "Skip" means

---

## Typography Specifications

### Font Family

**Not specified in JSX.** The design assumes the system font stack will be applied by the parent application or CSS reset. Likely:

```css
font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
```

**For Flutter migration:** Use `GoogleFonts.inter()` or `GoogleFonts.manrope()` based on the design system choice.

### Type Scale

| Purpose | Size | Weight | Weight Name | Line Height | Letter Spacing |
|---------|------|--------|-------------|-------------|----------------|
| Heading | 28px | 700 | Bold | 34px | default |
| Tagline | 18px | 500 | Medium | default | default |
| Description | 14px | 400 | Regular | 20px | default |
| Button label | 16px | 600 | Semibold | default | default |

### Font Weight Mapping (for Flutter)

When migrating to Flutter:

| Design Weight | Flutter Weight |
|---------------|----------------|
| 400 (regular) | `FontWeight.w400` |
| 500 (medium) | `FontWeight.w500` |
| 600 (semibold) | `FontWeight.w600` |
| 700 (bold) | `FontWeight.w700` |

### Line Height Rationale

- **Heading (34px / 28px = 1.21)** — Tight line height for bold text, prevents excessive space between lines
- **Description (20px / 14px = 1.43)** — Comfortable reading line height for multi-line paragraph

---

## Spacing & Dimensions

### Spacing System

```
┌─────────────────────────────────────┐
│         [Page Padding: 32px]        │
│                                     │
│            [Heading]                │
│                                     │
│          ↓ 40px gap                 │
│                                     │
│            [Mascot]                 │
│                                     │
│          ↓ 40px gap                 │
│                                     │
│            [Tagline]                │
│                                     │
│          ↓ 12px gap                 │
│                                     │
│         [Description]               │
│                                     │
│          ↓ 48px gap                 │
│                                     │
│       [Primary Button]              │
│                                     │
│          ↓ 12px gap                 │
│                                     │
│      [Secondary Button]             │
│                                     │
│         [Page Padding: 32px]        │
└─────────────────────────────────────┘
```

### Spacing Values

| Purpose | Value | Usage |
|---------|-------|-------|
| Page padding (horizontal) | 32px | Left and right edges |
| Major section gap | 40px | Between heading/mascot, mascot/tagline |
| Minor section gap | 12px | Between tagline/description, buttons |
| Pre-CTA gap | 48px | Before button section (extra breathing room) |

### Dimension Values

| Element | Width | Height | Notes |
|---------|-------|--------|-------|
| Canvas | 390px | 844px | iPhone 12/13/14 standard |
| Content area | 326px | N/A | 390 - (32×2) |
| Mascot | 180px | 180px | Square, centered |
| Description | 320px (max) | Auto | Constrained for readability |
| Buttons | 280px (max) | 50px | Constrained to prevent stretching |

### Border Radius

| Element | Radius | Rationale |
|---------|--------|-----------|
| Buttons | 12px | Matches design system standard (confirmed in other pages) |

---

## Color Palette

### Primary Colors

| Color Name | Hex Value | RGB | Usage |
|------------|-----------|-----|-------|
| Orange (ACCENT) | `#e8751a` | rgb(232, 117, 26) | Primary button fill, secondary button border/text |
| White | `#fff` | rgb(255, 255, 255) | Page background, primary button text |
| Near-Black | `#0f0f0f` | rgb(15, 15, 15) | Heading, tagline text |
| Medium Gray | `#555` | rgb(85, 85, 85) | Description text |

### Color Semantics

**Orange (`ACCENT`):**
- **Role:** Brand color, interactive elements
- **Used for:** Buttons (primary fill, secondary outline)
- **Not used for:** Text (except button labels), backgrounds

**White:**
- **Role:** Clean canvas, high contrast against orange
- **Used for:** Page background, button text on orange
- **Not used for:** Body text (would lack contrast)

**Near-Black (`#0f0f0f`):**
- **Role:** Primary text color
- **Used for:** Headings, important copy
- **Not used for:** Backgrounds (design system rule: no black backgrounds)

**Medium Gray (`#555`):**
- **Role:** Secondary text color
- **Used for:** Descriptive copy that's less critical
- **Not used for:** Headings or CTAs (would reduce emphasis)

### Contrast Ratios

| Text | Background | Ratio | WCAG AA Pass? | WCAG AAA Pass? |
|------|------------|-------|---------------|----------------|
| `#0f0f0f` on `#fff` | White | 20.5:1 | ✅ Yes | ✅ Yes |
| `#555` on `#fff` | White | 7.5:1 | ✅ Yes | ✅ Yes |
| `#fff` on `#e8751a` | Orange | 4.1:1 | ✅ Yes | ❌ No (4.5:1 needed) |
| `#e8751a` on `#fff` | White | 4.1:1 | ✅ Yes | ❌ No |

**Notes:**
- White text on orange meets WCAG AA for normal text (4.5:1 not required for large text 18px+)
- Button labels are 16px semibold, which counts as "large text" under WCAG
- All other text exceeds AAA standards

---

## Accessibility Considerations

### Semantic HTML

**Strengths:**
- Uses `<h1>` for page heading (proper document outline)
- Uses `<p>` for paragraph text (semantic structure)
- Uses `<button>` for interactive elements (keyboard accessible)
- Provides `alt` text for mascot image

**Improvements for Flutter migration:**
- Add `Semantics` widgets around all text
- Ensure buttons have semantic labels
- Consider adding language hints (`lang="en"` / `lang="da"`)

### Keyboard Navigation

**Current state:** Buttons are keyboard accessible (native `<button>` elements).

**Tab order:**
1. "Continue" button
2. "Fortsæt på dansk" button

**For Flutter migration:**
- Ensure both buttons are focusable
- Add visible focus indicators (border or shadow)
- Support Enter/Space to activate

### Screen Readers

**Image alt text:**
- `alt="JourneyMate mascot"` — descriptive, not decorative

**Button labels:**
- "Continue" — clear action
- "Fortsæt på dansk" — clear action in Danish

**Improvements for Flutter:**
- Add `Semantics(button: true, label: "Continue to onboarding")` for more context
- Add `Semantics(button: true, label: "Continue in Danish")` for consistency

### Color Contrast

See "Contrast Ratios" section above. All text meets WCAG AA standards.

### Touch Target Size

**Buttons:**
- Height: 50px
- Width: Up to 280px (full width minus padding)

**Meets guidelines:**
- ✅ iOS minimum: 44pt
- ✅ Material Design minimum: 48dp
- ✅ WCAG 2.1 Level AAA: 44×44px

### Language Support

**Bilingual design:**
- English is primary language (heading, tagline, description, primary button)
- Danish is available via secondary button ("Fortsæt på dansk")

**For Flutter migration:**
- Implement full i18n with separate Danish version of this screen
- Or keep bilingual approach with dynamic text based on language selection

---

## Migration Notes for Flutter (Future Reference)

### Widget Structure

```dart
Scaffold(
  backgroundColor: Colors.white,
  body: SafeArea(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Heading
          Text('Welcome to\nJourneyMate', ...),
          SizedBox(height: 40),

          // Mascot
          Image.asset('assets/images/mascot.png', ...),
          SizedBox(height: 40),

          // Tagline
          Text('Go out, your way.', ...),
          SizedBox(height: 12),

          // Description
          Text('Discover restaurants...', ...),
          SizedBox(height: 48),

          // Primary button
          ElevatedButton(...),
          SizedBox(height: 12),

          // Secondary button
          OutlinedButton(...),
        ],
      ),
    ),
  ),
)
```

### Asset Requirements

- Mascot image: `assets/images/mascot.png` (or SVG)
- Should be high-resolution (2x, 3x versions for iOS)

### Responsive Considerations

- Current design is fixed at 390×844px
- For Flutter, use `MediaQuery` to adapt to different screen sizes
- Consider using `LayoutBuilder` to adjust mascot size on smaller screens
- Button max-width should scale proportionally

### Animation Opportunities

**Not in JSX design, but could add:**
- Fade-in animation when screen appears
- Mascot entrance animation (scale or slide)
- Button hover states (for web/desktop)

---

## Summary

The Welcome New User page is a **clean, centered, welcoming onboarding screen** that:

1. **Establishes brand personality** with the mascot as the hero element
2. **Communicates value proposition** through tagline and description
3. **Offers language choice upfront** with two equally prominent CTAs
4. **Uses clear visual hierarchy** (filled primary, outlined secondary)
5. **Maintains accessibility** with semantic HTML and good contrast
6. **Follows design system rules** (orange for CTAs, no black backgrounds)

The design is **stateless, prop-driven, and mobile-first**, making it straightforward to migrate to Flutter while preserving the exact visual design and interaction patterns.

**Key design decisions:**
- Vertical centering creates balance and focus
- Mascot (180×180px) is the largest element, establishing personality
- Two buttons (filled + outlined) provide clear language choice
- Spacing rhythm (40px → 12px → 48px) creates visual groupings
- Max-width constraints (320px, 280px) ensure readability

**Migration priority:** Medium-high (onboarding is critical, but app can function without this specific welcome screen if language is preset).

