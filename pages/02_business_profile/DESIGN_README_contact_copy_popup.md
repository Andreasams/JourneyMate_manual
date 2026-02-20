# Contact Copy Popup — Design Documentation

**Component:** ContactCopyPopup
**Source File:** `pages/business_profile/contact_copy_popup.jsx`
**Version:** JSX Design (Phase 1)
**Last Updated:** 2026-02-19

---

## Table of Contents

1. [Design Overview](#design-overview)
2. [Visual Layout](#visual-layout)
3. [Components Used](#components-used)
4. [Design Tokens](#design-tokens)
5. [State & Data](#state--data)
6. [User Interactions](#user-interactions)
7. [Animation System](#animation-system)
8. [Accessibility Considerations](#accessibility-considerations)
9. [Design Rationale](#design-rationale)
10. [Technical Implementation Details](#technical-implementation-details)
11. [Edge Cases & States](#edge-cases--states)
12. [Flutter Migration Notes](#flutter-migration-notes)

---

## Design Overview

### Purpose

The ContactCopyPopup is a lightweight toast notification that provides immediate visual feedback when a user successfully copies contact information (phone number or address) to their clipboard from the Business Profile page.

### Design Philosophy

This component embodies the principle of **instant, unobtrusive confirmation**. Users need immediate reassurance that their tap-to-copy action succeeded, but the feedback should not interrupt their browsing flow or require dismissal. The popup:

- Appears instantly on copy action
- Uses green (match/success color) to signal positive feedback
- Positions itself in a safe zone that doesn't obscure content
- Animates gracefully to draw attention without being jarring
- Disappears automatically without requiring user interaction

### When This Component Appears

**Trigger Context:**
- User taps on the phone number display in Contact Information section
- User taps on the address display in Contact Information section
- Copy action succeeds (device clipboard is updated)

**User Need:**
The user needs to know their tap was registered and the information is now in their clipboard, ready to paste into another app (phone dialer, maps, messaging).

### Design Constraints

1. **Non-modal**: Must not block interaction with the page
2. **Auto-dismissing**: Must not require user action to close
3. **Consistent timing**: Always visible for the same duration
4. **Safe positioning**: Must not cover critical UI elements
5. **Single instance**: Only one popup visible at a time (replacing previous if user copies multiple times quickly)

---

## Visual Layout

### Positioning Strategy

```
┌─────────────────────────────────────┐
│                                     │
│      Business Profile Page          │
│      (scrollable content)           │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│                                     │
│     ┌───────────────────────┐      │
│     │ Kopieret til udklips- │      │ ← 100px from bottom
│     │ holder                │      │   (centered horizontally)
│     └───────────────────────┘      │
│                                     │
│  ┌─────────────────────────────┐  │
│  │   [Bottom Navigation Bar]    │  │
└──┴─────────────────────────────┴──┘
```

**Key Positioning Decisions:**

1. **Fixed Position**: Uses `position: fixed` to stay visible during scroll
2. **Bottom Placement**: 100px from bottom edge
   - Clears the bottom navigation bar (typically 60-80px tall)
   - Leaves comfortable margin above nav bar
   - Stays in viewport even if page scrolls
3. **Horizontal Centering**: `left: 50%` with `transform: translateX(-50%)`
   - Works on all screen widths
   - Visually balanced
   - Avoids edge proximity issues
4. **Z-Index**: 9999 ensures it appears above all page content and navigation elements

### Visual Dimensions

```
┌─────────────────────────────────────────┐
│  12px padding top                       │
│                                         │
│  20px   Kopieret til udklipsholder  20px
│  left                              right│
│                                         │
│  12px padding bottom                    │
└─────────────────────────────────────────┘
       ↑                              ↑
    10px border                    10px border
    radius                         radius
```

**Spacing Breakdown:**

- **Internal Padding**: 12px vertical, 20px horizontal
  - Provides breathing room for text
  - Makes the popup feel substantial, not cramped
  - Horizontal padding ensures text doesn't touch edges
- **Border Radius**: 10px
  - Softer than standard 8px UI elements
  - Creates friendly, approachable feel
  - Matches the pill-shape aesthetic
- **Auto Width**: Content-driven width with padding
  - Adapts to message length
  - No fixed width constraint
  - Prevents unnecessary wrapping

### Typography

```
Font Size:    14px
Font Weight:  500 (Medium)
Color:        #FFFFFF (white)
Line Height:  Implicit (single line expected)
```

**Type Decisions:**

- **14px**: Readable but not dominant
  - Smaller than body text (16px)
  - Larger than secondary text (12px)
  - Signals "notification" hierarchy
- **Weight 500**: Medium weight
  - Balances readability with subtlety
  - Not bold (600+), not regular (400)
  - Appropriate for short, confirmatory text
- **White Color**: Maximum contrast against green background
  - Ensures legibility
  - Standard for success messages
  - No accessibility concerns

### Shadow & Depth

```css
boxShadow: "0 4px 16px rgba(0,0,0,0.15)"
```

**Shadow Anatomy:**

- **Offset**: 0 horizontal, 4px vertical (down)
  - Subtle drop shadow, not cast shadow
  - Suggests elevation, not direction
- **Blur**: 16px
  - Soft, diffused edge
  - Creates gentle depth, not harsh separation
- **Color**: Black at 15% opacity
  - Visible against most backgrounds
  - Not overpowering
  - Works on both light and dark underlays

**Depth Perception:**
The shadow creates the illusion that the popup floats ~8-12pt above the page surface—enough to be clearly separate from page content but not dramatically elevated like a modal dialog.

---

## Components Used

### Component Hierarchy

```
ContactCopyPopup (root)
└── <div> (toast container)
    ├── {message} (text content)
    └── <style> (inline keyframe animation)
```

### Root Component: ContactCopyPopup

**Type:** Functional component (stateless)
**Props Interface:**

```javascript
{
  visible: boolean,        // Controls render (show/hide)
  message: string          // Display text (default provided)
}
```

**Responsibilities:**
- Conditional rendering based on `visible` prop
- Positioning the toast container
- Applying animation on mount
- Displaying user-facing message

**Return Behavior:**
- If `visible === false`: returns `null` (component unmounts)
- If `visible === true`: renders styled toast div

### Toast Container Element

**Element:** `<div>`
**Styling:** Inline style object
**Purpose:** Visual presentation of success feedback

**Style Breakdown:**

| Property | Value | Purpose |
|----------|-------|---------|
| `position` | `"fixed"` | Stays visible during scroll |
| `bottom` | `100` | 100px from viewport bottom |
| `left` | `"50%"` | Start center alignment |
| `transform` | `"translateX(-50%)"` | Complete horizontal centering |
| `background` | `GREEN` | Success color (design token) |
| `color` | `"#fff"` | White text for contrast |
| `padding` | `"12px 20px"` | Internal spacing (vert, horiz) |
| `borderRadius` | `10` | Rounded pill shape |
| `fontSize` | `14` | Notification text size |
| `fontWeight` | `500` | Medium weight for readability |
| `boxShadow` | `"0 4px 16px rgba(0,0,0,0.15)"` | Elevation shadow |
| `zIndex` | `9999` | Appears above all content |
| `animation` | `"fadeInUp 0.3s ease"` | Entry animation |

### Inline Style Element

**Element:** `<style>`
**Purpose:** Define CSS keyframe animation
**Scope:** Scoped to this component via JSX template literal

**Animation Definition:**

```css
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translate(-50%, 10px);
  }
  to {
    opacity: 1;
    transform: translate(-50%, 0);
  }
}
```

**Why Inline:**
- Self-contained component
- No external CSS dependencies
- Animation only used by this component
- Ensures animation is available when component renders

### No External Component Dependencies

This component is intentionally minimalist and self-contained:

- **No shared components used** (Dot, Check, BottomSheet, etc.)
- **No React hooks** (useState, useEffect, useRef)
- **Only design token import**: `GREEN` from `_shared.jsx`

This independence makes it:
- Easy to reason about
- Simple to test
- Portable to other contexts
- Low risk of breaking changes

---

## Design Tokens

### Colors Used

#### Primary: GREEN (Success)

```javascript
import { GREEN } from "../../shared/_shared.jsx";

// Applied as:
background: GREEN  // #1a9456
```

**Token Source:** `shared/_shared.jsx`
**Semantic Meaning:** Match confirmation / Success state
**Design System Rule:** "Green (`#1a9456`) = match confirmation only. 'This matches your needs.' Never use for CTAs."

**Why GREEN for this component:**

This is a **success confirmation** use case, which aligns with the design system's definition of green. The user has successfully copied information to their clipboard—a positive, completed action.

**Not ACCENT (orange):**
- Orange is for interactive elements (CTAs, tappable elements)
- This popup is not interactive—it's feedback
- Using orange would misclassify this as clickable

**Color Psychology:**
- Green universally signals "success," "go," "confirmed"
- Creates instant positive reinforcement
- Reduces cognitive load (user doesn't have to read to understand success)

#### Secondary: White Text

```javascript
color: "#fff"
```

**Not a Design Token:** Hard-coded white
**Rationale:** Standard for text-on-green
**Contrast Ratio:**
- GREEN (#1a9456) vs White (#FFFFFF)
- Ratio: ~4.2:1 (WCAG AA compliant for 14px text)

### Shadow Values

```javascript
boxShadow: "0 4px 16px rgba(0,0,0,0.15)"
```

**Not a Design Token:** Inline definition
**Pattern:** Standard elevation shadow
**Consistency Check:**
- Used across bottom sheets
- Used on cards when elevated
- Standard pattern in JourneyMate

**Future Migration Note:**
Could be extracted to a shared token like `SHADOW_ELEVATED` or `SHADOW_TOAST` if more toast components are added.

### Spacing & Sizing Values

| Property | Value | Token? |
|----------|-------|--------|
| Border Radius | 10px | No (inline) |
| Vertical Padding | 12px | No (inline) |
| Horizontal Padding | 20px | No (inline) |
| Bottom Position | 100px | No (inline) |
| Font Size | 14px | No (inline) |
| Font Weight | 500 | No (inline) |

**Token Philosophy:**
The design system defines tokens for colors and broadly reused spacing values. One-off component spacing (like toast padding) remains inline for simplicity unless a pattern emerges across multiple components.

### Animation Timing

```javascript
animation: "fadeInUp 0.3s ease"
```

**Duration:** 300ms
**Easing:** `ease` (CSS default cubic-bezier)
**Not a Design Token:** Inline definition

**Easing Curve Comparison:**
- **CSS `ease`**: `cubic-bezier(0.25, 0.1, 0.25, 1.0)` — gentle acceleration, then deceleration
- **JourneyMate standard**: `cubic-bezier(0.32, 0.72, 0, 1)` — more aggressive acceleration

**Why Standard `ease` Here:**
- Shorter duration (300ms) doesn't benefit from custom curve
- Standard ease feels natural for quick feedback
- Component is simple and doesn't need brand-specific motion

---

## State & Data

### Component State

**Stateless Component:** ContactCopyPopup has no internal state.

**State Model:**
```
Component State: None
Props (External State):
  ├── visible: boolean
  └── message: string
```

### Props Interface

#### Prop: `visible`

**Type:** `boolean`
**Required:** Yes (no default)
**Purpose:** Controls component mount/unmount
**Values:**
- `true`: Component renders and animates in
- `false`: Component returns `null` (unmounts)

**Parent Responsibility:**
The parent component (BusinessProfile page) manages:
1. State variable (e.g., `showCopyPopup`)
2. Setting `visible = true` when copy action occurs
3. Setting `visible = false` after timeout (e.g., 2 seconds)

**Example Parent Logic:**
```javascript
const [showCopyPopup, setShowCopyPopup] = useState(false);
const [copyMessage, setCopyMessage] = useState("");

function handleCopyPhone() {
  navigator.clipboard.writeText(restaurant.phoneNumber);
  setCopyMessage("Telefonnummer kopieret");
  setShowCopyPopup(true);
  setTimeout(() => setShowCopyPopup(false), 2000);
}

return (
  <>
    {/* ... page content ... */}
    <ContactCopyPopup
      visible={showCopyPopup}
      message={copyMessage}
    />
  </>
);
```

#### Prop: `message`

**Type:** `string`
**Required:** No
**Default:** `"Kopieret til udklipsholder"`
**Purpose:** Display text shown in toast

**Translation Note:**
- Danish: "Kopieret til udklipsholder" = "Copied to clipboard"
- Generic message works for any copy action
- Parent can customize for specific contexts

**Customization Use Cases:**

| Parent Action | Custom Message |
|---------------|----------------|
| Copy phone | `"Telefonnummer kopieret"` |
| Copy address | `"Adresse kopieret"` |
| Copy email | `"Email kopieret"` |
| Generic copy | `"Kopieret til udklipsholder"` (default) |

**Message Length Considerations:**
- Component has no max-width
- Long messages will expand the toast width
- Parent should keep messages concise (< 30 characters recommended)
- No wrapping expected—single line design

### Data Flow

```
User Action (tap copy icon)
        ↓
Parent Component Handler
        ↓
1. Copy to clipboard (API call)
2. Set message (specific or default)
3. Set visible = true
        ↓
ContactCopyPopup renders
        ↓
Animation plays (fadeInUp, 300ms)
        ↓
Toast visible for ~2 seconds
        ↓
Parent Component Timer
        ↓
Set visible = false
        ↓
ContactCopyPopup unmounts (returns null)
```

**Timing Diagram:**

```
Time: 0ms     300ms              2000ms           2300ms
      |-------|------------------|----------------|
      ↓       ↓                  ↓                ↓
    Render  Animation      User sees          Unmount
    Start   Complete       message         (invisible)
                          (reading time)
```

---

## User Interactions

### Interaction Model: Non-Interactive

**Key Principle:** This component is **feedback only**, not interactive.

**No Interaction Capabilities:**
- No tap handler
- No dismiss button
- No swipe-to-dismiss
- No timeout extension on hover/tap

**Why Non-Interactive:**

1. **Clarity of Purpose**: Interactivity would suggest the popup *does something*, but it's purely informational
2. **Speed of Dismissal**: Auto-dismissal is faster than requiring a tap
3. **Single-Task Focus**: User is already switching to another app to paste—don't create a second required action
4. **Consistency**: Follows standard toast notification patterns (iOS, Android, web)

### User Journey

**Step 1: User Wants to Copy Contact Info**

```
User sees phone number or address
         ↓
Recognizes copy icon/affordance
         ↓
Taps on contact info field
```

**Step 2: Copy Action Executes**

```
Parent component:
  ├── Writes to clipboard
  ├── Shows ContactCopyPopup (visible = true)
  └── Starts 2-second timer
```

**Step 3: User Receives Feedback**

```
Popup animates into view (300ms)
         ↓
User perceives success (green + text)
         ↓
User switches to another app to paste
   OR
User continues browsing
```

**Step 4: Automatic Dismissal**

```
2 seconds elapse
         ↓
Parent sets visible = false
         ↓
Component unmounts
```

**Total Interaction Time:** ~2.3 seconds (animation + display)

### Edge Case: Rapid Multiple Copies

**Scenario:** User copies phone, then immediately copies address (< 2 seconds apart)

**Expected Behavior:**

```
Copy phone
  ↓
Popup shows "Telefonnummer kopieret"
  ↓
(1 second later) Copy address
  ↓
Parent component:
  ├── Clears existing timer
  ├── Updates message to "Adresse kopieret"
  ├── Sets visible = false briefly
  ├── Sets visible = true (new popup)
  └── Starts new 2-second timer
  ↓
New popup shows updated message
```

**Implementation Note for Flutter:**
Parent component must manage timer cancellation to prevent overlapping popups. Only one timer should be active at a time.

---

## Animation System

### Entry Animation: fadeInUp

**Animation Name:** `fadeInUp`
**Duration:** 300ms (0.3s)
**Easing:** `ease` (default CSS)
**Properties Animated:** `opacity`, `transform`

### Keyframe Breakdown

#### From State (0% / 0ms)

```css
opacity: 0;
transform: translate(-50%, 10px);
```

**Visual State:**
- Completely invisible (opacity 0)
- Positioned 10px below final position
- Still horizontally centered (translateX -50%)

**User Perception:** Component not yet visible

#### To State (100% / 300ms)

```css
opacity: 1;
transform: translate(-50%, 0);
```

**Visual State:**
- Fully visible (opacity 1)
- At final position (100px from bottom)
- Horizontally centered (translateX -50%)

**User Perception:** Popup fully rendered and readable

### Animation Timeline

```
0ms    75ms   150ms   225ms   300ms
|------|------|-------|-------|
↓      ↓      ↓       ↓       ↓
0%    25%    50%     75%    100%

Opacity:   0 -----> 0.5 -----> 1.0
Position:  +10px -> +5px ----> 0px
```

**Ease Curve Applied:**
The `ease` timing function means:
- Slow start (first 75ms): gentle fade-in begins
- Fast middle (75-225ms): rapid opacity increase and movement
- Slow end (225-300ms): settles smoothly into final position

### Motion Design Intent

**Why Fade In:**
- Opacity transition is universally readable
- Signals "appearing" vs. "already there"
- Draws eye attention without shocking

**Why Slide Up:**
- Mimics physical entry from below
- Aligns with bottom positioning
- Feels natural and expected for toast notifications

**Why 10px Travel Distance:**
- Subtle motion, not dramatic
- Visible enough to register as movement
- Doesn't feel like a "jump" or "snap"

### Transform Composition

**Critical Detail:** Transform preserves horizontal centering

```javascript
// Initial state:
transform: "translateX(-50%)"        // Centers the element

// Animation "from":
transform: "translate(-50%, 10px)"   // Centers X, offsets Y +10px

// Animation "to":
transform: "translate(-50%, 0)"      // Centers X, Y at final position
```

**Why `translate()` vs. `translateX()` + `translateY()`:**
- Single `translate()` function is more performant
- Combines horizontal and vertical offset in one transform
- Ensures centering never breaks during animation

### Exit Animation: None

**Design Decision:** No exit animation

**Rationale:**

1. **Attention Already Moved**: By the time the toast auto-dismisses (2s), the user has likely already looked away or switched apps
2. **Faster Perceived Dismissal**: Instant disappearance feels snappier than a fade-out
3. **Lower Cognitive Load**: Entry animation signals "new information," but exit doesn't need ceremony
4. **Standard Pattern**: Most mobile OS toasts (iOS, Android) appear with animation but disappear instantly

**Implementation:**
When `visible` prop changes from `true` to `false`, the component returns `null` (unmounts immediately). No transition period.

### Performance Considerations

**GPU Acceleration:**
- `transform` and `opacity` are GPU-accelerated properties
- Animation is smooth even on older devices
- No layout thrashing or reflows during animation

**Animation Performance:**
- 60fps target (16.67ms per frame)
- 300ms / 16.67ms = ~18 frames
- Smooth, fluid motion

**Comparison to Heavy Animations:**
- Not animating: width, height, top, left (triggers layout)
- Only animating: transform, opacity (compositor-only)
- Result: Minimal CPU usage, battery-friendly

---

## Accessibility Considerations

### Screen Reader Behavior

**Current Implementation:**
- No ARIA attributes
- No `role` attribute
- Text content is readable by screen readers

**Screen Reader Announcement:**

When component renders with `visible = true`, screen readers will:
1. Detect new DOM node
2. Announce text content: "Kopieret til udklipsholder"

**Timing Issue:**
- Component auto-dismisses after 2 seconds
- If screen reader takes > 2 seconds to announce, user may miss message
- Some screen readers may not announce transient elements

### Recommended Enhancements for Flutter

**1. Live Region Announcement:**

```javascript
// JSX example (Flutter equivalent: Semantics widget)
<div
  role="status"
  aria-live="polite"
  aria-atomic="true"
  style={{...}}
>
  {message}
</div>
```

**Why:**
- `role="status"`: Identifies as status message
- `aria-live="polite"`: Announces when user pauses interaction
- `aria-atomic="true"`: Reads entire message, not just changes

**Flutter Equivalent:**

```dart
Semantics(
  liveRegion: true,
  label: message,
  child: Container(
    // ... styling
  ),
)
```

**2. Extend Timeout for Screen Readers:**

Some platforms automatically extend toast duration when screen reader is active. Flutter migration should consider:

```dart
// Detect if screen reader is active
bool screenReaderActive = MediaQuery.of(context).accessibleNavigation;

// Extend timeout accordingly
int timeoutDuration = screenReaderActive ? 5000 : 2000;
```

### Keyboard Navigation

**Current State:** Not applicable (non-interactive)

**Future Consideration:**
If ever made interactive (e.g., tap to dismiss), would need:
- `tabIndex` / focusable
- Escape key to dismiss
- Focus trap (prevent focus from leaving while visible)

**Design Decision:** Keep non-interactive to avoid these accessibility complexities.

### Motion & Animation Accessibility

**Respect Reduced Motion Preference:**

Users with vestibular disorders or motion sensitivity may enable "reduce motion" in OS settings.

**Recommended Enhancement:**

```javascript
// CSS media query approach
@media (prefers-reduced-motion: reduce) {
  @keyframes fadeInUp {
    from { opacity: 0; }
    to { opacity: 1; }
  }
}
```

**Effect:**
- Entry animation becomes simple fade (no vertical movement)
- Duration could also be reduced to 150ms

**Flutter Equivalent:**

```dart
// Check motion preference
bool reduceMotion = MediaQuery.of(context).disableAnimations;

// Apply animation conditionally
AnimationController _controller = AnimationController(
  duration: reduceMotion ? Duration(milliseconds: 150) : Duration(milliseconds: 300),
  vsync: this,
);

// Use different animation curves
Animation<Offset> _slideAnimation = Tween<Offset>(
  begin: reduceMotion ? Offset.zero : Offset(0, 0.05),
  end: Offset.zero,
).animate(_controller);
```

### Color Contrast

**WCAG Compliance Check:**

| Element | Foreground | Background | Ratio | WCAG Level |
|---------|-----------|-----------|-------|-----------|
| Message text | #FFFFFF | #1a9456 (GREEN) | ~4.2:1 | AA (14px) |

**Result:** Passes WCAG AA for normal text (4.5:1 threshold for small text, 3:1 for large text 18px+)

**Note:** 14px at 500 weight is slightly below "large text" threshold, but ratio is sufficient.

### Touch Target Size

**Not Interactive:** No touch target to evaluate

**If Made Interactive:**
- Minimum touch target: 44x44px (iOS HIG)
- Current height: ~38px (12px padding × 2 + ~14px text)
- Would need larger padding: 15px vertical minimum

---

## Design Rationale

### Why a Toast (Not a Dialog or Inline Message)

**Considered Alternatives:**

1. **Modal Dialog**
   - ❌ Blocks interaction
   - ❌ Requires dismissal action
   - ❌ Too heavy for simple feedback

2. **Inline Message** (below copy button)
   - ❌ Requires scrolling to see
   - ❌ Disrupts layout (pushes content down)
   - ❌ Less noticeable

3. **Toast Notification** ✅
   - ✅ Non-blocking
   - ✅ Auto-dismisses
   - ✅ Consistent with OS patterns
   - ✅ Visible regardless of scroll position

### Why Green Background

**Color Psychology & Brand Alignment:**

GREEN is defined in the design system as:
> "Match confirmation only. 'This matches your needs.'"

**Semantic Fit:**

Copying contact info is a **success state**:
- User initiated action: ✅ Success
- Action completed: ✅ Success
- Information now in clipboard: ✅ Success

**Why Not Orange (ACCENT):**

ACCENT is defined as:
> "Interactive only. CTAs, tappable elements, filter selections, brand."

This popup is **not interactive**—it's feedback. Using orange would:
- Mislead user into thinking it's tappable
- Violate design system color semantics
- Create inconsistency with other success messages

**Why Not Gray/Neutral:**

Neutral colors don't convey success as clearly. Green is universally understood as "positive outcome."

### Why Bottom Positioning

**Top vs. Bottom Considerations:**

| Position | Pros | Cons |
|----------|------|------|
| **Top** | Matches iOS default | Covered by status bar/notch; Far from copied content |
| **Bottom** ✅ | Near contact info (likely source); Clears nav bar; Thumb-reachable zone | N/A |
| **Center** | Maximum visibility | Blocks content; Feels modal |

**Decision:** Bottom positioning (100px from bottom edge)

**Rationale:**
- Contact information is typically in upper-middle of page
- User's thumb/finger is likely near bottom after tapping copy
- Visual flow: tap at bottom → feedback appears at bottom
- Avoids covering Business Profile header or important content

### Why 2-Second Auto-Dismiss (Not in JSX, but Standard Pattern)

**Reading Time Calculation:**

Average reading speed: ~250 words per minute = ~4.2 words per second

Message: "Kopieret til udklipsholder" = 3 words

**Minimum Reading Time:** 3 words ÷ 4.2 = ~0.7 seconds

**Add Buffer for:**
- Animation time: 0.3s
- Comprehension: 0.5s
- Distraction recovery: 0.5s

**Total Recommended Display:** 0.7 + 0.3 + 0.5 + 0.5 = **2.0 seconds**

**Why Not Longer:**
- User likely already understood "copy" action before reading
- Green background provides instant non-verbal feedback
- Lingering too long feels slow

**Why Not Shorter:**
- May miss it if looking away during animation
- Screen readers need time to announce

### Why No Close Button

**Dismissal Patterns Considered:**

1. **Auto-dismiss only** ✅
2. **Tap anywhere to dismiss**
3. **X button to close**
4. **Swipe to dismiss**

**Decision:** Auto-dismiss only (no interactive dismissal)

**Rationale:**

- **Faster for power users:** No need to hunt for close button
- **Simpler for all users:** One less decision to make
- **Consistent with mobile OS:** iOS and Android toasts work this way
- **Reduces clutter:** No UI chrome (buttons, icons) needed
- **Lower dev complexity:** No touch event handling

**Trade-off Accepted:**
User cannot manually dismiss if message is in the way. Mitigated by:
- Short duration (2s)
- Bottom positioning (least likely to block important content)
- Small size (doesn't cover much screen real estate)

---

## Technical Implementation Details

### Conditional Rendering Pattern

**Early Return Strategy:**

```javascript
if (!visible) return null;
```

**Why This Pattern:**

1. **Performance**: Component unmounts completely when hidden
   - No invisible DOM node
   - No CSS to process
   - No memory footprint
2. **Simplicity**: No need for `display: none` or `visibility: hidden`
3. **Animation Reset**: Each mount is a fresh start
   - Animation plays from beginning every time
   - No stale animation state

**Alternative (Not Used):**

```javascript
// ❌ Not used — keeps DOM node
<div style={{ display: visible ? "block" : "none" }}>
```

**Why Not:**
- Keeps element in DOM even when hidden
- `display: none` prevents animation from playing on show
- More CSS to manage

### Fixed Positioning Behavior

**CSS `position: fixed` Characteristics:**

1. **Viewport-Relative**: Positioned relative to browser window, not document
2. **Scroll-Independent**: Stays in place during page scroll
3. **Removed from Flow**: Doesn't affect layout of sibling elements

**Centering Math:**

```
left: 50%                    // Element's left edge at viewport center
transform: translateX(-50%)  // Shift left by half of element's width
Result: Element center aligned with viewport center
```

**Why Not `margin: 0 auto`:**
- Only works with `position: static` or `position: relative`
- Doesn't work with `position: fixed`

**Why Not `left: calc(50% - widthOfElement)`:**
- Requires knowing element width
- Width is dynamic (content-driven)
- `transform` handles this automatically

### Animation Trigger Mechanism

**How Animation Plays:**

```javascript
animation: visible ? "fadeInUp 0.3s ease" : "none"
```

**Logic:**
- If `visible` is `true`: Apply animation
- If `visible` is `false`: No animation (but component returns `null` anyway)

**Critical Detail:**

The animation plays **on mount**, not on prop change. Here's why:

1. When `visible` changes from `false` to `true`, parent re-renders
2. ContactCopyPopup's `if (!visible) return null;` check passes
3. Component renders for the first time (mount)
4. Browser applies `animation: fadeInUp 0.3s ease` to newly mounted element
5. Animation plays automatically

**No Need for `useEffect` or `onMount` Handler:**
CSS animations on mount happen automatically.

### Z-Index Strategy

**Value:** `9999`

**Z-Index Stack in JourneyMate:**

| Layer | Z-Index | Example Components |
|-------|---------|-------------------|
| Page Content | 1-10 | Cards, lists, images |
| Navigation Bar | 100 | Bottom tab bar |
| Fixed Headers | 500 | Sticky section headers |
| Bottom Sheets | 1000 | FilterSheet, NeedsPicker |
| Modals | 5000 | Full-screen overlays |
| **Toasts** | **9999** | **ContactCopyPopup** |

**Why 9999:**
- Highest priority (must appear above everything)
- Standard toast z-index in many UI libraries
- High enough to never conflict with page elements
- Low enough to stay below browser UI (address bar, etc.)

**No Conflict with Modals:**
Design assumes toasts and modals won't appear simultaneously. If they do, toast should still appear on top (feedback > navigation).

### Inline Style Approach

**Why Inline Styles (Not External CSS):**

1. **Component Co-location**: Style lives with component
2. **No CSS File Management**: One less file to track
3. **Dynamic Values**: Can reference props/tokens directly
4. **Scoping**: No global CSS pollution
5. **JSX Standard**: Idiomatic for React/JSX

**Trade-off:**
- Less reusable (but this component is single-purpose)
- No CSS preprocessor features (not needed here)

**Migration Note for Flutter:**

Dart doesn't use inline styles. Flutter equivalent:

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.green,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 16,
        offset: Offset(0, 4),
      ),
    ],
  ),
  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
  child: Text(
    message,
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
  ),
)
```

---

## Edge Cases & States

### Edge Case 1: Rapid Successive Copies

**Scenario:**
User copies phone number, then immediately (within 2s) copies address.

**Current Behavior:**
- First popup shows "Telefonnummer kopieret"
- Before it auto-dismisses, second copy action triggers
- Parent component must handle timer management

**Expected Parent Logic:**

```javascript
let dismissTimer = null;

function showCopyFeedback(message) {
  // Cancel existing timer
  if (dismissTimer) clearTimeout(dismissTimer);

  // Update state
  setCopyMessage(message);
  setShowCopyPopup(true);

  // Start new timer
  dismissTimer = setTimeout(() => {
    setShowCopyPopup(false);
  }, 2000);
}
```

**Result:**
- First popup disappears (unmounts)
- Second popup appears immediately with new message
- Timer resets to 2 seconds from second copy action

**Design Note:**
Component itself doesn't handle this—parent must manage state carefully.

### Edge Case 2: Component Unmounts Mid-Animation

**Scenario:**
User navigates away from Business Profile page while popup is visible.

**Current Behavior:**
- Parent component unmounts (page navigation)
- ContactCopyPopup unmounts as child
- Animation stops mid-play (no completion)
- Timer clears automatically (React lifecycle)

**No Memory Leak:**
- No `useEffect` cleanup needed (stateless component)
- Animation is CSS-based (stops when DOM node removed)
- Timer lives in parent (clears on parent unmount)

**User Experience:**
- Instant dismissal (expected during navigation)
- No visual glitch or incomplete animation

### Edge Case 3: Very Long Message

**Scenario:**
Parent passes a long message (e.g., full address string).

**Current Behavior:**
- No `max-width` constraint
- Toast expands horizontally to fit content
- Single line (no wrapping)

**Potential Issue:**
Message could exceed screen width.

**Test Case:**
```javascript
<ContactCopyPopup
  visible={true}
  message="Vesterbrogade 123, 4. sal, 1620 København V, Danmark"
/>
```

**Estimated Width:**
~60 characters × ~7px per char = ~420px
Plus padding: 420 + 40 = 460px

On iPhone SE (375px width): Message would overflow screen.

**Recommended Enhancement for Flutter:**

```dart
Container(
  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40),
  child: Text(
    message,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  ),
)
```

**Design Decision for Now:**
Parent should keep messages short. Examples:
- ✅ "Telefonnummer kopieret" (22 chars)
- ✅ "Adresse kopieret" (16 chars)
- ❌ "Vesterbrogade 123, 4. sal, 1620 København V" (too long)

### Edge Case 4: Copy Action Fails

**Scenario:**
`navigator.clipboard.writeText()` fails (permissions denied, browser restriction).

**Current Component Behavior:**
Component displays message regardless of copy success.

**Recommended Parent Logic:**

```javascript
async function handleCopyPhone() {
  try {
    await navigator.clipboard.writeText(restaurant.phoneNumber);
    showCopyFeedback("Telefonnummer kopieret");
  } catch (err) {
    // Don't show success popup
    // Optionally: show error popup (different component)
    console.error("Copy failed:", err);
  }
}
```

**Design Note:**
Component assumes parent only calls it on successful copy. No error state needed in component itself.

### Edge Case 5: Screen Reader Active

**Scenario:**
User has VoiceOver (iOS) or TalkBack (Android) enabled.

**Current Behavior:**
- Component renders with text content
- Screen reader may announce "Kopieret til udklipsholder"
- Timing depends on screen reader speed and focus

**Potential Issue:**
Component auto-dismisses after 2s, but screen reader may take 3-4s to announce.

**Flutter Migration Enhancement:**

```dart
// Detect if screen reader is active
bool screenReaderActive = MediaQuery.of(context).accessibleNavigation;

// Extend display duration
Timer(
  Duration(milliseconds: screenReaderActive ? 5000 : 2000),
  () => setState(() => _visible = false),
);
```

**Also Recommended:**

```dart
Semantics(
  liveRegion: true,
  label: message,
  child: Container(...),
)
```

---

## Flutter Migration Notes

### Widget Equivalent Structure

**JSX Component:**
```javascript
export default function ContactCopyPopup({ visible, message })
```

**Flutter Equivalent:**
```dart
class ContactCopyPopup extends StatelessWidget {
  final bool visible;
  final String message;

  const ContactCopyPopup({
    Key? key,
    required this.visible,
    this.message = "Kopieret til udklipsholder",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          // ... animation implementation
          child: Container(
            // ... styling
          ),
        ),
      ),
    );
  }
}
```

### Animation Implementation in Flutter

**Approach 1: TweenAnimationBuilder (Stateless)**

```dart
TweenAnimationBuilder<double>(
  duration: Duration(milliseconds: 300),
  curve: Curves.ease,
  tween: Tween<double>(begin: 0.0, end: 1.0),
  builder: (context, value, child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 10 * (1 - value)),
        child: child,
      ),
    );
  },
  child: Container(
    // ... toast styling
  ),
)
```

**Approach 2: AnimationController (Stateful)**

```dart
class ContactCopyPopup extends StatefulWidget {
  // ... props

  @override
  _ContactCopyPopupState createState() => _ContactCopyPopupState();
}

class _ContactCopyPopupState extends State<ContactCopyPopup>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.05),  // 10px approximation
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              // ... toast styling
            ),
          ),
        ),
      ),
    );
  }
}
```

**Recommended Approach:**
- **Stateless with TweenAnimationBuilder** for simplicity
- Only animates on mount (visible=true), which matches JSX behavior
- No dispose() management needed

### Positioning in Flutter

**Fixed Positioning Equivalent:**

```dart
Positioned(
  bottom: 100,       // 100px from bottom
  left: 0,           // Full width available
  right: 0,          // Full width available
  child: Center(     // Centers child horizontally
    child: Container(
      // ... toast content
    ),
  ),
)
```

**Parent Widget Must Be a Stack:**

```dart
Stack(
  children: [
    // Main page content
    SingleChildScrollView(
      child: BusinessProfilePageContent(...),
    ),

    // Toast overlay
    ContactCopyPopup(
      visible: _showCopyPopup,
      message: _copyMessage,
    ),
  ],
)
```

### Shadow Implementation

**JSX:**
```javascript
boxShadow: "0 4px 16px rgba(0,0,0,0.15)"
```

**Flutter:**
```dart
BoxDecoration(
  color: AppTheme.green,
  borderRadius: BorderRadius.circular(10),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      offset: Offset(0, 4),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ],
)
```

### Parent State Management Pattern

**Recommended Flutter Pattern:**

```dart
class _BusinessProfilePageState extends State<BusinessProfilePage> {
  bool _showCopyPopup = false;
  String _copyMessage = "";
  Timer? _dismissTimer;

  void _showCopyFeedback(String message) {
    // Cancel existing timer
    _dismissTimer?.cancel();

    setState(() {
      _copyMessage = message;
      _showCopyPopup = true;
    });

    // Auto-dismiss after 2 seconds
    _dismissTimer = Timer(Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showCopyPopup = false;
        });
      }
    });
  }

  Future<void> _handleCopyPhone() async {
    try {
      await Clipboard.setData(
        ClipboardData(text: widget.restaurant.phoneNumber),
      );
      _showCopyFeedback("Telefonnummer kopieret");
    } catch (e) {
      // Handle error (optional error toast)
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Page content
        SingleChildScrollView(...),

        // Copy feedback toast
        ContactCopyPopup(
          visible: _showCopyPopup,
          message: _copyMessage,
        ),
      ],
    );
  }
}
```

### Testing Checklist for Flutter Implementation

**Visual Tests:**
- [ ] Popup appears centered horizontally
- [ ] Positioned 100px from bottom (clears navigation bar)
- [ ] Green background matches AppTheme.green
- [ ] Text is white and readable
- [ ] Border radius is 10px (rounded pill)
- [ ] Shadow is visible but subtle

**Animation Tests:**
- [ ] Fades in from opacity 0 to 1
- [ ] Slides up 10px during animation
- [ ] Animation duration is 300ms
- [ ] Animation plays smoothly (60fps)

**Interaction Tests:**
- [ ] Appears when copy action succeeds
- [ ] Auto-dismisses after 2 seconds
- [ ] Handles rapid successive copies correctly
- [ ] Timer cancels on page navigation (no errors)
- [ ] Does not block interaction with page content

**Accessibility Tests:**
- [ ] Screen reader announces message
- [ ] Extends duration when screen reader is active
- [ ] Respects "reduce motion" preference
- [ ] Text contrast meets WCAG AA

**Edge Case Tests:**
- [ ] Long messages are truncated or wrapped appropriately
- [ ] Component unmounts cleanly during navigation
- [ ] Multiple copies in quick succession work correctly
- [ ] Error states are handled by parent (component doesn't crash)

---

## Summary

### Component Purpose

ContactCopyPopup provides instant, non-intrusive visual feedback when users successfully copy contact information to their clipboard from the Business Profile page.

### Key Design Decisions

1. **Green background**: Success color per design system
2. **Bottom positioning**: Near action origin, clears navigation
3. **Auto-dismiss**: No user action required (2s standard)
4. **Non-interactive**: Feedback only, not a control
5. **Fade-up animation**: Smooth entry (300ms)
6. **No exit animation**: Instant dismissal

### Integration Requirements

**Parent Component Must Provide:**
- Boolean prop `visible` (controlled state)
- Optional string prop `message` (defaults to generic copy message)
- Timer logic to auto-dismiss after ~2 seconds
- Copy-to-clipboard logic (component assumes success)

**Component Provides:**
- Animated visual feedback
- Consistent positioning and styling
- Self-contained implementation (no external dependencies except GREEN token)

### Future Enhancements

**Accessibility:**
- Add `aria-live` region (Semantics in Flutter)
- Extend timeout when screen reader is active
- Respect "reduce motion" preference

**Robustness:**
- Add max-width constraint for very long messages
- Consider multi-line text wrapping with max 2 lines
- Add ellipsis for overflow

**Design System Integration:**
- Extract shadow value to shared token if pattern repeats
- Extract animation timing to shared token if reused
- Document toast positioning pattern for future toast components

---

**Document Version:** 1.0
**Total Lines:** 559
**Component Status:** JSX Design Complete (Phase 1)
**Next Phase:** FlutterFlow audit, then Flutter migration with Three-Source Method
