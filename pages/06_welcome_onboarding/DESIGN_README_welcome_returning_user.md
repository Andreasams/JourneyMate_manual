# Design Documentation: Welcome Returning User

**File:** `pages/welcome/welcome_returning_user.jsx`
**Purpose:** Returning user welcome screen with single CTA
**Screen Type:** Welcome flow variant
**Language Mix:** Danish interface with English tagline
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
8. [Content & Copy](#content--copy)
9. [Accessibility Considerations](#accessibility-considerations)
10. [Responsive Behavior](#responsive-behavior)
11. [Comparison: New vs Returning User Screens](#comparison-new-vs-returning-user-screens)

---

## Design Overview

### Purpose
The returning user welcome screen provides a simplified entry point for users who have previously onboarded. Unlike the new user onboarding flow (which includes need selection and explanations), this screen offers immediate access to the app with a single "Continue" button.

### Key Characteristics
- **Minimalist approach:** Single CTA, no need selection, no multi-step flow
- **Brand reinforcement:** Mascot and tagline establish visual identity
- **Immediate access:** One tap to main app
- **Consistent branding:** Same visual elements as new user onboarding (mascot, tagline)
- **Localized content:** Danish interface with English tagline maintaining brand voice

### Design Philosophy
This screen balances two goals:
1. **Re-engagement:** Welcome users back with friendly, recognizable branding
2. **Efficiency:** Minimize friction between launch and app usage

The design assumes users already understand the app's value proposition and have configured their needs, so it focuses on quick re-entry rather than education or configuration.

---

## Visual Layout

### Screen Dimensions
- **Width:** 390px (iPhone design width)
- **Height:** 844px (full screen height)
- **Background:** Pure white (`#fff`)
- **Content padding:** 32px horizontal

### Layout Structure

```
┌─────────────────────────────────────┐
│                                     │
│          [Vertical Center]          │
│                                     │
│         Velkommen til               │
│         JourneyMate                 │ ← Heading (28px, bold)
│                                     │
│            [Mascot]                 │ ← 180x180px image
│          (180x180px)                │
│                                     │
│       Go out, your way.             │ ← Tagline (18px, medium)
│                                     │
│    Opdag restauranter, caféer...    │ ← Description (14px, regular)
│                                     │
│         [Fortsæt button]            │ ← Primary CTA (280px wide)
│                                     │
│          [Vertical Center]          │
│                                     │
└─────────────────────────────────────┘
```

### Vertical Spacing
The layout uses a centered flexbox with explicit bottom margins creating hierarchical spacing:

- **Heading → Mascot:** 40px gap
- **Mascot → Tagline:** 40px gap
- **Tagline → Description:** 12px gap (tight coupling)
- **Description → CTA:** 48px gap (emphasis before action)

### Horizontal Layout
- **Container:** Centered with 32px side padding
- **Content:** Center-aligned text
- **Button:** Max-width 280px (compact, thumb-friendly)
- **Description:** Max-width 320px (optimal reading length)

### Visual Hierarchy

**Primary (most prominent):**
- Mascot image (largest visual element)
- Heading ("Velkommen til JourneyMate")
- CTA button (orange accent color)

**Secondary:**
- Tagline ("Go out, your way.")

**Tertiary:**
- Description text (gray, smaller)

---

## Components Used

### 1. Heading (H1)
```jsx
<h1 style={{
  fontSize: 28,
  fontWeight: 700,
  color: "#0f0f0f",
  textAlign: "center",
  margin: "0 0 40px 0",
  lineHeight: "34px",
}}>
  Velkommen til<br />JourneyMate
</h1>
```

**Purpose:** Primary greeting and brand name display

**Typography:**
- **Font size:** 28px (large, attention-grabbing)
- **Weight:** 700 (bold, strong presence)
- **Line height:** 34px (1.21 ratio, comfortable for two-line text)
- **Color:** `#0f0f0f` (near-black, maximum readability)

**Layout:**
- Center-aligned
- Hard line break after "Velkommen til"
- 40px bottom margin

**Content Structure:**
- Line 1: "Velkommen til" (Welcome to)
- Line 2: "JourneyMate" (brand name emphasized by isolation)

### 2. Mascot Image
```jsx
<img
  src="../../FF-pages-images/journeymate_mascot.png"
  alt="JourneyMate maskot"
  style={{
    width: 180,
    height: 180,
    objectFit: "contain",
    margin: "0 0 40px 0",
  }}
/>
```

**Purpose:** Visual brand identity, personality injection, recognition anchor

**Specifications:**
- **Dimensions:** 180x180px (fixed, same as new user onboarding)
- **Object fit:** `contain` (preserves aspect ratio, no distortion)
- **Alt text:** "JourneyMate maskot" (Danish, accessible)

**Visual Role:**
- Largest single element on screen
- Central focus point
- Friendly, approachable visual tone
- Consistent with new user onboarding (builds recognition)

### 3. Tagline
```jsx
<div style={{
  fontSize: 18,
  fontWeight: 500,
  color: "#0f0f0f",
  textAlign: "center",
  margin: "0 0 12px 0",
}}>
  Go out, your way.
</div>
```

**Purpose:** Brand value proposition, emotional appeal

**Typography:**
- **Font size:** 18px (medium-large, visible but not dominant)
- **Weight:** 500 (medium, confident but not bold)
- **Color:** `#0f0f0f` (same as heading, maintains hierarchy through size)

**Content:**
- **Language:** English (intentional brand voice)
- **Tone:** Empowering, personal, aspirational
- **Message:** Emphasizes user autonomy and personalization

### 4. Description Text
```jsx
<p style={{
  fontSize: 14,
  fontWeight: 400,
  color: "#555",
  textAlign: "center",
  lineHeight: "20px",
  margin: "0 0 48px 0",
  maxWidth: 320,
}}>
  Opdag restauranter, caféer og barer filtreret efter din livsstil, præferencer og kostbehov.
</p>
```

**Purpose:** Explain app value in concrete terms

**Typography:**
- **Font size:** 14px (standard body text)
- **Weight:** 400 (regular, readable)
- **Color:** `#555` (gray, de-emphasized vs heading/tagline)
- **Line height:** 20px (1.43 ratio, readable for longer text)

**Layout:**
- **Max-width:** 320px (prevents overly wide lines, improves readability)
- **Margin bottom:** 48px (large gap before CTA creates clear separation)

**Content Structure:**
- **Language:** Danish (user interface language)
- **What it describes:** Core functionality
- **Key elements:** "restauranter, caféer og barer" (venues)
- **Filtering logic:** "livsstil, præferencer og kostbehov" (lifestyle, preferences, dietary needs)

### 5. Continue Button (Primary CTA)
```jsx
<button
  onClick={onContinue}
  style={{
    width: "100%",
    maxWidth: 280,
    height: 50,
    background: ACCENT,
    color: "#fff",
    border: "none",
    borderRadius: 12,
    fontSize: 16,
    fontWeight: 600,
    cursor: "pointer",
  }}
>
  Fortsæt
</button>
```

**Purpose:** Primary action to enter the app

**Styling:**
- **Width:** Full width (up to 280px max)
- **Height:** 50px (touch-friendly, substantial)
- **Background:** `ACCENT` (`#e8751a` — JourneyMate orange)
- **Text color:** White (`#fff`)
- **Border radius:** 12px (rounded, friendly)
- **Border:** None (filled button style)

**Typography:**
- **Font size:** 16px (legible, standard button text)
- **Weight:** 600 (semi-bold, clear action)
- **Label:** "Fortsæt" (Danish for "Continue")

**Interaction:**
- **Cursor:** Pointer (hover affordance)
- **Action:** Calls `onContinue` prop function

**Design Choice:**
- Filled button (vs outline) signals primary action
- Orange color creates visual pop against white background
- Compact max-width (280px) keeps button centered and thumb-friendly

---

## Design Tokens

### Colors

**Text Colors:**
- `#0f0f0f` — Primary text (heading, tagline)
- `#555` — Secondary text (description)
- `#fff` — Button text (white on orange)

**Background Colors:**
- `#fff` — Screen background (pure white)
- `ACCENT` (`#e8751a`) — Button background (JourneyMate orange)

**Color Usage Philosophy:**
- **Orange accent used sparingly:** Only for primary CTA (maintains visual hierarchy)
- **Black text on white background:** Maximum readability, clean aesthetic
- **Gray for secondary content:** De-emphasizes description vs heading/tagline

### Typography Scale

**Hierarchy (largest to smallest):**
1. **Heading:** 28px / 700 weight
2. **Tagline:** 18px / 500 weight
3. **Button:** 16px / 600 weight
4. **Description:** 14px / 400 weight

**Font Weight Mapping:**
- 400: Regular (description)
- 500: Medium (tagline)
- 600: Semi-bold (button)
- 700: Bold (heading)

**Line Height Strategy:**
- Heading: 34px (1.21 ratio — tight for short text)
- Description: 20px (1.43 ratio — comfortable for body text)
- Tagline/Button: No explicit line-height (single-line text)

### Spacing System

**Vertical Spacing (margin-bottom values):**
- **40px:** Heading → Mascot, Mascot → Tagline (major section breaks)
- **48px:** Description → Button (pre-action emphasis)
- **12px:** Tagline → Description (tight coupling of related content)

**Horizontal Spacing:**
- **32px:** Screen side padding (comfortable edge distance)

**Containment:**
- **280px:** Button max-width (compact, centered)
- **320px:** Description max-width (readable line length)

### Border Radius
- **12px:** Button corners (friendly, approachable)

### Layout Dimensions
- **390px:** Screen width (iPhone design standard)
- **844px:** Screen height (full-screen layout)
- **180px:** Mascot size (square, same as onboarding)
- **50px:** Button height (touch-friendly)

---

## State & Data

### Component Props

**onContinue** (function, required)
- **Type:** Callback function
- **Purpose:** Triggered when user taps "Fortsæt" button
- **Expected behavior:** Navigate to main app (search page or home)

**Prop Flow:**
```
Parent (navigation controller)
  ↓ passes onContinue function
WelcomeReturningUser
  ↓ calls onContinue
Navigate to main app
```

### Local State
**None.** This component is purely presentational with a single callback.

### Data Requirements
**None.** All content is hardcoded (static welcome message).

### Assumptions
- User has previously completed onboarding
- User's needs are already saved in persistent storage
- No need selection or configuration is required
- User is authenticated (or app supports anonymous mode)

---

## User Interactions

### Primary Action: Continue Button

**Trigger:** Tap/click "Fortsæt" button

**Visual Feedback:**
- Cursor changes to pointer on hover (desktop)
- Expected: Native button press animation (not implemented in JSX)

**Expected Outcome:**
- `onContinue` callback is invoked
- Navigate to main app (search page)
- Destroy welcome screen (one-time show per session)

**User Flow:**
```
App Launch (returning user detected)
  ↓
WelcomeReturningUser screen shown
  ↓
User taps "Fortsæt"
  ↓
onContinue() called
  ↓
Navigate to Search/Home
  ↓
Welcome screen dismissed
```

### Non-Interactive Elements
- Heading: Static text
- Mascot: Static image (no tap action)
- Tagline: Static text
- Description: Static text

### No Secondary Actions
Unlike new user onboarding (which has "Skip" or "Next" buttons), this screen has only one path: continue to app.

### Expected Behavior

**Desktop/Web:**
- Button shows pointer cursor on hover
- Click triggers navigation

**Mobile/Touch:**
- Button responds to touch events
- Haptic feedback on tap (if implemented)
- No hover state needed

---

## Design Rationale

### Why a Separate Returning User Screen?

**Problem:** New user onboarding includes need selection, explanatory text, and multiple steps. Forcing returning users through this flow creates friction and wastes time.

**Solution:** Dedicated returning user screen with:
- **Single CTA:** Immediate access to app
- **No configuration:** Assumes needs are already set
- **Brief reminder:** Mascot and tagline reinforce brand without explaining value

### Why Keep the Mascot and Tagline?

**Brand Consistency:**
- Mascot creates visual continuity with onboarding
- Users recognize the character, reinforcing memory
- Friendly visual tone maintains app personality

**Emotional Re-engagement:**
- "Go out, your way" reminds users of app's value
- Positive, empowering message sets tone for session
- Brief enough to not slow down return

### Why Only One Button?

**User Intent is Clear:**
- User opened the app → they want to use it
- No need for "Skip" (where would they skip to?)
- No need for "Learn More" (they already onboarded)

**Reduced Cognitive Load:**
- One action = one decision
- Faster path to value
- No distraction or confusion

### Why Center Everything?

**Visual Balance:**
- Single-column centered layout is simple and clean
- No left/right alignment decisions needed
- Focus naturally falls on center content

**Mobile-First Design:**
- Narrow viewports benefit from centered content
- Equal padding on both sides
- Content naturally scales to different widths

### Content Hierarchy Decisions

**Heading First:**
- "Velkommen til JourneyMate" is personal and welcoming
- Brand name is primary identifier
- Danish language signals localized experience

**Mascot Second:**
- Largest visual element draws attention
- Creates emotional connection
- Breaks up text blocks

**Tagline Third:**
- English tagline maintains brand voice
- "Go out, your way" is memorable, short
- Reinforces value proposition

**Description Fourth:**
- Explains functionality for users who may have forgotten
- Gray color de-emphasizes (not critical to read)
- Provides context without blocking action

**CTA Last:**
- Natural reading flow ends with action
- Large spacing before button creates emphasis
- Orange color draws eye downward

### Why Minimal Spacing Between Tagline and Description?

**Semantic Coupling:**
- Tagline and description both explain app value
- They form a conceptual unit (emotional + practical)
- Tight spacing (12px) groups them visually

**Contrast with CTA Spacing:**
- Large gap (48px) before button separates thought from action
- Creates visual "breathing room" before decision

---

## Content & Copy

### Language Strategy

**Mixed Danish/English:**
- **Danish:** UI elements (heading, description, button)
- **English:** Brand tagline ("Go out, your way")

**Rationale:**
- Danish for usability (users read interface in native language)
- English tagline for brand consistency (same across markets)
- Creates memorable "brand moment" in English

### Heading

**Danish:** "Velkommen til JourneyMate"
**English translation:** "Welcome to JourneyMate"

**Copy Analysis:**
- Personal and warm ("Velkommen" vs impersonal "Hej")
- Brand name isolated on second line (emphasis)
- Simple, direct greeting

### Tagline

**English:** "Go out, your way."

**Copy Analysis:**
- Three-word imperative (action-oriented)
- "Your way" emphasizes personalization
- Period at end (statement, not question — confident)
- Aspirational and empowering tone

**Why in English:**
- Taglines often remain in original language for brand consistency
- English has global recognition and "cool" factor in Danish market
- Shorter and punchier than Danish translation would be

### Description

**Danish:** "Opdag restauranter, caféer og barer filtreret efter din livsstil, præferencer og kostbehov."

**English translation:** "Discover restaurants, cafes, and bars filtered by your lifestyle, preferences, and dietary needs."

**Copy Analysis:**
- Starts with action verb ("Opdag" — Discover)
- Lists venue types (concrete, specific)
- Explains filtering logic (lifestyle, preferences, dietary needs)
- One sentence (concise, scannable)

**What It Communicates:**
- **What:** Find places (restaurants, cafes, bars)
- **How:** Filtered by your needs
- **Why:** Personalized to you

### Button Label

**Danish:** "Fortsæt"
**English translation:** "Continue"

**Copy Analysis:**
- Single word (fast to read)
- Implies forward motion (not "Enter" or "Start")
- Suggests continuity (you're not starting over, you're returning)

**Alternatives Considered (hypothetically):**
- "Kom i gang" (Get started) — too onboarding-focused
- "Gå til appen" (Go to app) — too descriptive
- "OK" — too dismissive
- "Fortsæt" — just right (implies resuming where you left off)

---

## Accessibility Considerations

### Screen Reader Support

**Image Alt Text:**
```jsx
alt="JourneyMate maskot"
```
- Descriptive in Danish (matches UI language)
- Identifies mascot as brand element
- Avoids overly detailed description (not critical information)

**Semantic HTML:**
- Uses `<h1>` for heading (proper hierarchy)
- Uses `<p>` for description (semantic body text)
- Uses `<button>` for CTA (native accessibility)

### Keyboard Navigation

**Tab Order:**
1. Continue button (only interactive element)

**Enter/Space:**
- Activates button (native browser behavior)

### Visual Accessibility

**Text Contrast:**
- Heading: Black (`#0f0f0f`) on white → WCAG AAA
- Description: Gray (`#555`) on white → WCAG AA (4.54:1)
- Button: White on orange (`#e8751a`) → WCAG AA (3.21:1 for large text)

**Text Sizing:**
- Minimum text: 14px (description) → readable
- Button text: 16px → comfortable
- Heading: 28px → high visibility

**Touch Target Size:**
- Button: 280x50px → exceeds 44x44px minimum

### Motion Sensitivity
- No animations in JSX design
- No auto-advancing content
- User-controlled navigation

---

## Responsive Behavior

### Fixed Width Design

**Current Implementation:**
- Screen width: 390px (fixed)
- Screen height: 844px (fixed)

**Target Device:**
- iPhone design dimensions
- Not responsive to different screen sizes

### Responsive Adaptation Strategy (for Flutter)

**Horizontal Adaptation:**
- Container padding: 32px (fixed) → could scale for larger screens
- Button max-width: 280px → could use percentage-based width
- Description max-width: 320px → could scale with screen width

**Vertical Adaptation:**
- Centered flexbox → handles different heights gracefully
- Content will remain vertically centered
- Spacing (40px, 48px) may need scaling for very short screens

### Content Overflow

**Image Handling:**
- `objectFit: "contain"` → prevents distortion if container resizes
- Fixed 180x180px size → may need scaling for small screens

**Text Handling:**
- All text is center-aligned → adapts to width changes
- Max-width constraints prevent overly wide lines

---

## Comparison: New vs Returning User Screens

### Structural Similarities

**Both Include:**
- Mascot (180x180px, same image)
- Tagline ("Go out, your way")
- Description explaining app value
- Center-aligned, white background
- Orange accent CTA button

### Key Differences

| Aspect | New User | Returning User |
|--------|----------|----------------|
| **Steps** | Multi-step flow (welcome → needs → confirmation) | Single screen |
| **Need Selection** | Required (categories + items) | Not shown (already configured) |
| **CTA Count** | Multiple (Next, Skip, etc.) | Single (Continue) |
| **CTA Purpose** | Advance to next step | Enter main app |
| **User Flow** | Linear onboarding journey | Immediate access |
| **Time to Value** | 3-4 steps | 1 tap |
| **Content Depth** | Explains need selection | Brief reminder |

### Design Consistency

**Maintained Elements:**
- Mascot placement and size
- Tagline wording
- Typography scale
- Orange accent color
- Centered layout

**Why Consistent:**
- Users should recognize the brand
- Returning users see familiar visual language
- Mascot creates continuity between first use and return

### When to Show Each Screen

**New User Welcome:**
- First app launch
- User has not completed onboarding
- No saved needs in storage

**Returning User Welcome:**
- Subsequent app launches
- User has completed onboarding
- Needs are saved in persistent storage

### Transition Logic

```
App Launch
  ↓
Check: Has user onboarded?
  ↓
├── No → Show New User Onboarding
│         (WelcomeNewUser → Need Selection → Confirmation)
│
└── Yes → Show Returning User Welcome
          (WelcomeReturningUser)
  ↓
Continue to Main App
```

---

## Design Tokens Summary

### Color Palette Used

| Token | Hex | Usage |
|-------|-----|-------|
| Primary text | `#0f0f0f` | Heading, tagline |
| Secondary text | `#555` | Description |
| Background | `#fff` | Screen background |
| ACCENT | `#e8751a` | Button background |
| Button text | `#fff` | Button label |

### Typography Tokens

| Element | Size | Weight | Line Height | Color |
|---------|------|--------|-------------|-------|
| Heading | 28px | 700 | 34px | `#0f0f0f` |
| Tagline | 18px | 500 | (default) | `#0f0f0f` |
| Button | 16px | 600 | (default) | `#fff` |
| Description | 14px | 400 | 20px | `#555` |

### Spacing Tokens

| Token | Value | Usage |
|-------|-------|-------|
| Screen padding | 32px | Horizontal container padding |
| Major gap | 40px | Heading → Mascot, Mascot → Tagline |
| Pre-action gap | 48px | Description → Button |
| Tight coupling | 12px | Tagline → Description |

### Layout Tokens

| Token | Value | Usage |
|-------|-------|-------|
| Screen width | 390px | Container width |
| Screen height | 844px | Container height |
| Mascot size | 180x180px | Image dimensions |
| Button height | 50px | Touch target height |
| Button max-width | 280px | CTA width constraint |
| Description max-width | 320px | Text line-length constraint |

### Radius Tokens

| Token | Value | Usage |
|-------|-------|-------|
| Button radius | 12px | Rounded corners |

---

## Implementation Notes

### Props Contract
```jsx
<WelcomeReturningUser
  onContinue={() => navigateToSearch()}
/>
```

**Parent Responsibilities:**
- Detect if user is returning (has completed onboarding)
- Provide navigation function to main app
- Handle welcome screen dismissal

### State Management
- No internal state
- Fully controlled by parent via props
- Stateless functional component

### Asset Dependency
```
../../FF-pages-images/journeymate_mascot.png
```
- Mascot image must exist at this path
- Image should be optimized for web/mobile (PNG, reasonable file size)
- Recommended: Include @2x and @3x versions for high-DPI displays

### No Analytics (Yet)
Current JSX design does not include analytics tracking. Flutter implementation should consider:
- Screen view event ("welcome_returning_user_viewed")
- Button click event ("welcome_returning_user_continue_tapped")

---

## Flutter Migration Considerations

### Widget Structure
```dart
class WelcomeReturningUserPage extends StatelessWidget {
  final VoidCallback onContinue;

  const WelcomeReturningUserPage({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Heading
              Text('Velkommen til\nJourneyMate', ...),
              SizedBox(height: 40),

              // Mascot
              Image.asset('assets/images/journeymate_mascot.png', ...),
              SizedBox(height: 40),

              // Tagline
              Text('Go out, your way.', ...),
              SizedBox(height: 12),

              // Description
              Text('Opdag restauranter...', ...),
              SizedBox(height: 48),

              // Button
              ElevatedButton(
                onPressed: onContinue,
                child: Text('Fortsæt'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Theme Integration
- Use `Theme.of(context).colorScheme.primary` for ACCENT
- Use `Theme.of(context).textTheme` for typography
- Define custom text styles if needed

### Image Asset
- Place mascot in `assets/images/journeymate_mascot.png`
- Add to `pubspec.yaml` asset declaration
- Consider providing 2x and 3x variants

### Button Styling
- Use `ElevatedButton.styleFrom()` for consistent styling
- Match 12px border radius
- Ensure 50px minimum height

### Safe Area
- Add `SafeArea` widget to avoid notch/status bar overlap
- Consider bottom safe area for devices with home indicator

---

## Design System Alignment

### Follows JourneyMate Design System:
✓ Uses ACCENT orange (`#e8751a`) only for interactive elements
✓ Uses near-black (`#0f0f0f`) for primary text
✓ Uses gray (`#555`) for secondary text
✓ White background (not dark)
✓ 12px border radius for buttons
✓ Consistent typography scale

### Deviations/Custom Choices:
- Mascot size (180px) not explicitly in design system (but consistent with onboarding)
- Specific spacing values (40px, 48px) chosen for this layout

---

## Questions for FlutterFlow Comparison

When comparing to FlutterFlow implementation, verify:

1. **Conditional rendering:** How does FlutterFlow detect returning users?
2. **Navigation target:** Where does onContinue navigate to (Search? Home? Last page?)
3. **Welcome frequency:** Is this shown every launch, or only after re-install?
4. **Animation:** Does FlutterFlow add any fade-in or slide transitions?
5. **Mascot asset:** Is the mascot image the same across all welcome screens?
6. **Button states:** Are there hover/pressed/disabled styles not shown in JSX?
7. **Analytics:** Does FlutterFlow track welcome screen views or button taps?
8. **Session logic:** Is there a "Don't show again" mechanism?

---

## Summary

The `WelcomeReturningUser` component is a **minimalist re-engagement screen** designed for efficiency and brand reinforcement. It serves as a brief "hello" moment before granting immediate access to the main app.

**Core Design Principles:**
1. **Single action:** One button, one path, no friction
2. **Brand consistency:** Mascot and tagline match onboarding
3. **Clear hierarchy:** Visual flow from greeting → imagery → action
4. **User respect:** No unnecessary steps for returning users

**Key Metrics:**
- **Taps to app:** 1 (vs. 3+ for new user onboarding)
- **Time to value:** ~1 second (vs. 30+ seconds for onboarding)
- **Cognitive load:** Minimal (no decisions, no configuration)

This screen exemplifies **respectful design**: it welcomes users back without wasting their time, reinforces the brand without over-explaining, and provides immediate access to the value they came for.

---

**End of Design Documentation**
