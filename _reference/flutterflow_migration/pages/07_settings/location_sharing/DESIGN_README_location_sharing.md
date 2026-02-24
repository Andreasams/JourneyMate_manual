# Location Sharing Page — JSX Design Documentation

**Source file:** `C:\Users\Rikke\Documents\JourneyMate-v2\pages\settings\location_sharing.jsx`
**Page name:** Location Sharing
**Purpose:** Manage location permission, explain benefits, and guide users to enable location access
**Navigation:** Settings → Location sharing

---

## Design Overview

The Location Sharing page is a focused permission request screen that explains why JourneyMate needs location access and provides a single, clear call-to-action to enable it. Unlike typical permission dialogs, this is a full-page experience that gives users context and reassurance before requesting system-level permissions.

### Core Principles

1. **Transparency First** — Explain exactly why location is needed before requesting permission
2. **Single Clear Action** — One primary button, no competing choices
3. **Privacy Reassurance** — Explicit statement about data usage and third-party sharing
4. **Minimal Friction** — Simple layout, centered content, no distractions

### Design Context

This page appears when:
- Users access Settings and select "Location sharing"
- Location permissions are disabled or not yet requested
- The app needs to explain location benefits before triggering system permission dialog

The page does NOT include:
- Toggle switches (action is binary: grant or don't)
- Permission status indicators (assumes permission not yet granted)
- Settings to control location precision (system-level control)
- "Maybe later" or "Skip" options (back button serves this purpose)

### Visual Strategy

**Centered Content Layout** — All elements centered to create a focused, dialog-like experience within a full-page context. This mirrors system permission dialogs while providing more context.

**Progressive Information Hierarchy:**
1. Page title (header bar) — establishes context
2. Section heading — frames the request
3. Benefit description — explains value proposition
4. Primary action — clear path forward
5. Privacy statement — addresses concerns

**Whitespace Usage** — Generous padding (32px top, 24px horizontal) and vertical spacing (16-24px between elements) creates a calm, considered feeling appropriate for a permission request.

---

## Visual Layout

### Page Structure

```
┌─────────────────────────────────────┐
│  [←]   Location sharing             │  60px header
├─────────────────────────────────────┤
│                                     │
│     Turn on location sharing        │  22px heading
│                                     │
│   Allow JourneyMate to access your  │  14px description
│   location to show nearby restau-   │
│   rants and provide better...       │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Turn on location sharing        │ │  50px CTA button
│ └─────────────────────────────────┘ │
│                                     │
│  We respect your privacy. Your...   │  13px privacy text
│                                     │
└─────────────────────────────────────┘
```

### Dimensions & Positioning

**Canvas:**
- Width: 390px
- Height: 844px
- Background: `#fff`
- Overflow: hidden

**Header Bar:**
- Height: 60px
- Border bottom: 1px solid `#f2f2f2`
- Padding: 0 20px
- Back button: 36×36px, positioned left
- Title: centered with -36px left margin offset (compensates for back button)

**Content Container:**
- Padding: 32px 24px (top/bottom, left/right)
- Starts immediately below header

**Element Vertical Spacing:**
- Heading: 0 0 16px 0
- Description: 0 0 24px 0
- Button: 0 0 24px 0 (margin bottom)
- Privacy text: no bottom margin (last element)

### Layout Measurements

**Header:**
- Back button hit area: 36×36px
- Back button icon: 18px font size
- Title font: 16px, weight 600
- Title position: center with -36px left margin

**Content Area (inside 32px/24px padding):**
- Heading: 22px font, 700 weight
- Description: 14px font, 400 weight, 20px line height
- Button: full width (342px after padding), 50px height, 12px border radius
- Privacy text: 13px font, 400 weight, 18px line height

**Horizontal Alignment:**
- All text elements: `text-align: center`
- Button: `width: 100%` (fills container)

---

## Components Used

### 1. StatusBar (Imported)

**Source:** `../../shared/_shared.jsx`

**Purpose:** Standard iOS status bar showing time, battery, signal

**Integration:**
```jsx
<StatusBar />
```

Positioned at top of page, consistent across all app screens.

### 2. Header Bar (Inline Component)

**Structure:**
```jsx
<div> {/* container */}
  <button> ← </button> {/* back button */}
  <div> Location sharing </div> {/* title */}
</div>
```

**Styling:**
- Container: 60px height, flex row, items centered, padding 0 20px
- Border: 1px solid `#f2f2f2` bottom
- Back button: 36×36px, transparent background, no border
- Back icon: 18px font size, `#0f0f0f` color
- Title: flex 1, centered text, 16px font, 600 weight, -36px left margin

**Back Button Behavior:**
- Trigger: `onClick={onBack}`
- Cursor: pointer
- Visual state: none (relies on touch feedback)

### 3. Content Section (Inline Component)

**Structure:**
```jsx
<div> {/* container */}
  <h2> Turn on location sharing </h2>
  <p> Allow JourneyMate to access... </p>
  <button> Turn on location sharing </button>
  <div> We respect your privacy... </div>
</div>
```

**Container Styling:**
- Padding: 32px 24px
- No max-width constraint
- No background (inherits white from page)

**Heading (h2):**
- Font: 22px, 700 weight
- Color: `#0f0f0f`
- Margin: 0 0 16px 0
- Text align: center

**Description (p):**
- Font: 14px, 400 weight
- Color: `#555`
- Line height: 20px
- Margin: 0 0 24px 0
- Text align: center

**CTA Button:**
- Width: 100% (full container width)
- Height: 50px
- Background: `ACCENT` (`#e8751a`)
- Color: `#fff`
- Border: none
- Border radius: 12px
- Font: 16px, 600 weight
- Cursor: pointer
- Margin: 0 0 24px 0

**Privacy Statement (div):**
- Font: 13px, 400 weight
- Color: `#888`
- Line height: 18px
- Text align: center
- No margin (last element)

### 4. CTA Button (Inline)

**Design Details:**

**Dimensions:**
- Full width of parent container
- 50px height (standard CTA height)
- 12px border radius (standard button radius)

**Typography:**
- Text: "Turn on location sharing"
- Font size: 16px
- Font weight: 600
- Color: white (`#fff`)
- No text transform

**Color:**
- Background: `ACCENT` orange (`#e8751a`)
- No hover state defined (relies on touch feedback)
- No disabled state (button always active)

**Interaction:**
- Trigger: `onClick={onEnableLocation}`
- Cursor: pointer
- No loading state
- No success state

### Component Dependencies

**Imported from shared:**
- `StatusBar` — iOS status bar component
- `ACCENT` — orange brand color token (`#e8751a`)

**Inline (page-specific):**
- Header bar with back button
- Content section with heading, description, CTA, privacy text

**Not Used:**
- No `BottomSheet`
- No filter components
- No card components
- No list views
- No toggles or switches
- No permission status indicators

---

## Design Tokens

### Colors

**Text Colors:**
- Primary text: `#0f0f0f` (heading, back button icon, header title)
- Secondary text: `#555` (description)
- Tertiary text: `#888` (privacy statement)
- White text: `#fff` (button label)

**Background Colors:**
- Page background: `#fff`
- Button background: `ACCENT` (`#e8751a`)
- Header background: transparent (inherits white)

**Border Colors:**
- Header border: `#f2f2f2` (subtle separator)

**Brand Colors Used:**
- `ACCENT` — orange (`#e8751a`) for CTA button
- No green used (not a match confirmation page)

### Typography

**Font Sizes:**
- 22px — page heading
- 18px — back button icon
- 16px — header title, button label
- 14px — description text
- 13px — privacy statement

**Font Weights:**
- 700 — heading (bold)
- 600 — header title, button label (semibold)
- 400 — description, privacy text (regular)

**Line Heights:**
- 20px — description text (1.43 ratio)
- 18px — privacy text (1.38 ratio)
- Default — heading, button (single line)

**Text Alignment:**
- Center — heading, description, privacy text
- Left — back button icon (in flex center container)

### Spacing

**Padding:**
- Header horizontal: 20px
- Content top/bottom: 32px
- Content left/right: 24px

**Margins (Vertical Spacing):**
- Heading bottom: 16px
- Description bottom: 24px
- Button bottom: 24px
- Privacy text bottom: 0

**Component Dimensions:**
- Header height: 60px
- Back button: 36×36px
- CTA button height: 50px

**Border Radius:**
- Button: 12px
- Back button: none (rectangular hit area)

### Elevation & Effects

**No shadows** — flat design, no elevation

**No blur effects** — no backdrop filters

**No gradients** — solid colors only

**No animations defined** — static layout (transitions would be added in implementation)

---

## State & Data

### Component Props

**Required Props:**

1. **onBack** (function)
   - Purpose: Navigate back to Settings page
   - Trigger: Back button click
   - Return value: none (void)
   - Example: `() => navigate('/settings')`

2. **onEnableLocation** (function)
   - Purpose: Request location permission from system
   - Trigger: CTA button click
   - Return value: none (void)
   - Example: `() => requestLocationPermission()`

### Internal State

**No local state** — this is a stateless presentational component. All logic handled by parent.

### Data Flow

**Input Flow:**
```
Parent Component
  ↓
  onBack prop → Back button click
  onEnableLocation prop → CTA button click
```

**No data display** — page contains only static content and actions

**No permission status** — assumes permission not yet granted (otherwise page wouldn't be shown)

### Permission States (Not Managed Here)

The design assumes this page is shown when:
- Location permission is "not determined" or "denied"
- User has navigated to Settings → Location sharing
- App needs to request permission

The design does NOT handle:
- "Permission already granted" state (different page or no page needed)
- "Permission denied" state with "Open Settings" CTA (would require different content)
- Loading state while checking permission
- Error state if permission request fails

These states would be handled by parent component logic or different page variations.

### Expected Implementation State Management

**Parent component should track:**
- Current permission status (not determined / denied / granted)
- Whether to show this page (only if not granted)
- Navigation history (to determine back destination)
- System permission dialog result

**Parent component should handle:**
- Calling system permission API
- Responding to permission grant/deny
- Navigating away after permission granted
- Showing different content if permission denied with "Open Settings" option

---

## User Interactions

### 1. Back Button (Header)

**Trigger:** Click back arrow (←) button

**Visual Feedback:**
- Cursor: pointer
- No hover state defined
- Touch feedback handled by system/browser

**Action:**
- Execute `onBack()` prop
- Typically navigates to Settings page
- No confirmation required

**Expected Behavior:**
- Immediate navigation
- No permission state change
- User can return to this page later

### 2. CTA Button (Enable Location)

**Trigger:** Click "Turn on location sharing" button

**Visual Feedback:**
- Cursor: pointer
- No hover state defined
- Touch feedback handled by system/browser
- No loading indicator (system dialog appears immediately)

**Action:**
- Execute `onEnableLocation()` prop
- Typically triggers system permission dialog
- Parent component handles permission API call

**Expected Flow:**
1. User clicks button
2. System permission dialog appears (iOS/Android native)
3. User grants or denies permission
4. Dialog closes
5. Parent component responds to result:
   - If granted: navigate away or show success
   - If denied: show different content or return to Settings

**No Explicit "Deny" Option:**
- Users can navigate back without enabling
- Denying happens in system dialog, not on this page

### 3. Text Reading (No Interaction)

**Purpose:** Inform user about location benefits and privacy

**Heading:** "Turn on location sharing"
- Establishes clear action expectation

**Description:** "Allow JourneyMate to access your location to show nearby restaurants and provide better recommendations."
- Explains concrete benefits (nearby results, better recommendations)
- Uses app name ("JourneyMate") for clarity
- Short enough to read quickly (27 words)

**Privacy Statement:** "We respect your privacy. Your location is only used to improve your experience and is never shared with third parties without your consent."
- Addresses primary concern (third-party sharing)
- Reassures with "respect your privacy" framing
- Specific commitment: "never shared...without your consent"
- Length: 26 words (readable at glance)

### Interaction Patterns

**Modal-Like Behavior:**
- Page feels like a focused dialog despite being full-screen
- Only two actions: back or enable
- No navigation chrome or tabs
- No scroll (all content fits above fold)

**Single-Purpose Flow:**
- Entire page dedicated to one decision
- No competing actions or distractions
- Clear hierarchy guides to primary action

**Trust Building:**
- Benefit explanation before request
- Privacy commitment visible before action
- No hidden agendas or fine print links

### Accessibility Considerations (Design Intent)

**Touch Targets:**
- Back button: 36×36px (meets minimum 44×44 recommendation with padding)
- CTA button: 50px height (exceeds minimum)

**Text Readability:**
- Sufficient contrast: `#0f0f0f` on white (meets WCAG AAA)
- Description: `#555` on white (meets WCAG AA)
- Privacy text: `#888` on white (meets WCAG AA for large text)
- Font sizes: 13px minimum (readable on mobile)

**Semantic Structure (Intent):**
- `<h2>` for heading (proper heading hierarchy)
- `<p>` for description (semantic text block)
- `<button>` elements (not divs styled as buttons)

**Focus Order (Expected):**
1. Back button
2. CTA button
- Text elements not focusable (reading only)

---

## Design Rationale

### Why Full-Page Instead of Modal?

**Decision:** Use full page navigation instead of modal/bottom sheet overlay.

**Reasoning:**

1. **Importance Signal** — Location permission is a critical decision that affects core app functionality. Full-page treatment signals this importance.

2. **Reading Time** — Users need time to read explanation and privacy statement. Full page gives them space to read without feeling rushed.

3. **Navigation Context** — Coming from Settings, full-page navigation feels expected (not an interruption).

4. **iOS Design Pattern** — Follows iOS Settings app convention where permission pages are full screens.

5. **No Interruption** — Page is navigated to intentionally, not shown as interruption during task.

### Why Center-Aligned Content?

**Decision:** Center all text and button instead of left-aligned.

**Reasoning:**

1. **Dialog-Like Feel** — Creates focused, modal-like experience within full page.

2. **Visual Balance** — Symmetry creates calm feeling appropriate for permission request.

3. **Draws Attention** — Center alignment focuses eyes on content, not edges.

4. **Mirrors System Dialogs** — iOS permission dialogs use centered text, maintaining consistency.

5. **Single Column** — No competing columns or sidebars, so center makes sense.

### Why Single CTA Instead of "Allow/Deny" Buttons?

**Decision:** Single "Turn on location sharing" button, no explicit deny button.

**Reasoning:**

1. **System Handles Deny** — System permission dialog provides deny option, no need to duplicate.

2. **Reduces Friction** — Single action is less intimidating than forced binary choice.

3. **Back Button = Soft Deny** — Users can navigate back if not ready, which is less permanent than explicit deny.

4. **Positive Framing** — Focuses on benefit of enabling, not consequences of denying.

5. **Cleaner Design** — Single button is visually cleaner than button pair.

### Why Show Privacy Statement?

**Decision:** Include privacy commitment below CTA button.

**Reasoning:**

1. **Address Primary Concern** — Location is sensitive data; users want to know how it's used.

2. **Build Trust** — Explicit commitment shows transparency and respect.

3. **Before Action** — Users see commitment before granting permission, not buried in ToS.

4. **Third-Party Concern** — "Never shared with third parties" addresses most common worry.

5. **Reassurance Timing** — Appears after benefit explanation but before final decision.

### Why No Permission Status Indicator?

**Decision:** No toggle, status badge, or "Currently: Disabled" indicator.

**Reasoning:**

1. **Context Implies Status** — Page only shown when permission not granted, so status is obvious.

2. **Reduces Visual Noise** — No need for redundant information.

3. **Action-Oriented** — Focus is on what to do (enable), not current state (disabled).

4. **Simpler Mental Model** — Page = request. No request needed = no page.

5. **Follows iOS Pattern** — iOS permission pages don't show current status, just request.

### Why This Content Order? (Heading → Benefit → CTA → Privacy)

**Decision:** Specific sequence of information presentation.

**Reasoning:**

1. **Heading First** — Establishes what page is about ("Turn on location sharing").

2. **Benefit Second** — Answers "why should I?" before asking for action.

3. **CTA Third** — Call to action appears after user is informed but before concerns.

4. **Privacy Last** — Addresses concern after presenting value, reinforces trust before final decision.

**Psychological Flow:**
1. What is this? (heading)
2. What's in it for me? (benefit)
3. What do I do? (CTA)
4. Is it safe? (privacy)

This order builds momentum toward action while addressing concerns.

### Why "Turn on location sharing" Instead of "Allow Location Access"?

**Decision:** Use "Turn on location sharing" for both heading and button text.

**Reasoning:**

1. **Positive Framing** — "Turn on" implies enabling a feature, not granting permission.

2. **Feature Language** — "Location sharing" frames as app capability, not permission grant.

3. **Less Intimidating** — "Sharing" feels more collaborative than "access" (which implies taking).

4. **Consistency** — Same phrasing in heading and button reinforces clear action.

5. **User Control** — "Turn on" implies user is in control, can turn off later.

### Why No "Maybe Later" or "Skip" Option?

**Decision:** Only back button for declining, no explicit "skip" action.

**Reasoning:**

1. **Not a Mandatory Step** — Page accessed via Settings, not during onboarding, so no need to explicitly skip.

2. **Back Button Sufficient** — Users understand back button means "not now."

3. **Reduces Decision Paralysis** — Fewer options = simpler choice.

4. **Cleaner Visual** — Single CTA is less cluttered than CTA + secondary action.

5. **Permission Timing** — User navigated here intentionally; if not ready, they'll navigate away.

### Why No "What You'll Get" List or Feature Breakdown?

**Decision:** Single benefit paragraph instead of bulleted feature list.

**Reasoning:**

1. **Brevity** — Users want to make decision quickly, not read a sales pitch.

2. **Two Clear Benefits** — "Nearby restaurants" + "better recommendations" are sufficient and concrete.

3. **Visual Simplicity** — No bullets or icons needed, keeps focus on action.

4. **Trust Through Simplicity** — Not trying too hard to convince shows respect for user's time.

5. **Aligns with iOS Pattern** — iOS permission requests are brief explanations, not feature lists.

### Why White Background Instead of Branded Color?

**Decision:** Plain white background instead of orange accent or gradient.

**Reasoning:**

1. **Neutral Context** — Permission request should feel informational, not sales-y.

2. **Readability** — Black text on white is highest contrast and easiest to read.

3. **Serious Tone** — White background signals importance and seriousness.

4. **Consistency** — Settings pages typically use white backgrounds.

5. **Orange for Action Only** — Reserve accent color for interactive element (button), not decoration.

---

## Design Patterns & Best Practices

### Permission Request UX Pattern

**Pattern:** Full-page context before system dialog.

**Why Used:**
- iOS 14+ requires explanation before showing permission dialog
- Users more likely to grant permission when they understand benefits
- Pre-dialog explanation reduces confusion when system dialog appears

**Implementation:**
1. User navigates to page
2. Reads benefit and privacy info
3. Clicks CTA
4. System permission dialog appears
5. User grants or denies in system dialog
6. App responds to result

**Alternative Pattern (Not Used):** Showing system dialog immediately without explanation.
**Why Not:** Higher denial rate, user confusion, feels intrusive.

### Progressive Disclosure Pattern

**Pattern:** Information revealed in hierarchy of importance.

**Why Used:**
- Users scan page top-to-bottom
- Most important info (heading, benefit) appears first
- Supporting info (privacy) appears after action but still visible
- No hidden information or "Learn more" links

**Implementation:**
1. Heading (what)
2. Benefit (why)
3. Action (how)
4. Reassurance (concerns)

**Alternative Pattern (Not Used):** All info in collapsible sections or "Learn more" links.
**Why Not:** Adds friction, reduces transparency, feels like hiding information.

### Single Primary Action Pattern

**Pattern:** One clear primary action, minimal alternatives.

**Why Used:**
- Reduces decision paralysis
- Guides user to intended outcome
- Less visual clutter
- Focuses attention on benefit, not choice

**Implementation:**
- One prominent CTA button
- Back button for declining (secondary, less prominent)
- No "Skip," "Maybe later," or "Don't allow" buttons

**Alternative Pattern (Not Used):** Two equal buttons ("Allow" / "Don't Allow").
**Why Not:** Creates forced choice, increases anxiety, equal prominence reduces conversion.

### Trust-Building Through Transparency Pattern

**Pattern:** Explicit privacy commitment visible before action.

**Why Used:**
- Location is sensitive data
- Users distrust apps with unclear data usage
- Transparency builds trust
- Commitment is specific, not vague

**Implementation:**
- Privacy statement below CTA (seen before clicking)
- Specific commitment: "never shared with third parties"
- Simple language: "we respect your privacy"
- No legal jargon or ToS links (saves that for actual policy)

**Alternative Pattern (Not Used):** No privacy statement, or only in ToS/Privacy Policy.
**Why Not:** Users won't read separate policy, want reassurance before granting permission.

### iOS Settings Page Pattern

**Pattern:** Matches iOS Settings app convention for permission pages.

**Why Used:**
- Users familiar with iOS Settings patterns
- Consistency reduces cognitive load
- Follows platform conventions
- Feels native, not custom

**Implementation:**
- Full-page navigation (not modal)
- Header with back button and title
- Centered content with clear hierarchy
- Single action button

**Alternative Pattern (Not Used):** Custom modal, bottom sheet, or card-based design.
**Why Not:** Feels less native, adds unnecessary creativity, breaks user expectations.

---

## Functional Requirements (Design Implications)

### Navigation Behavior

**Entry Points:**
- Settings page → "Location sharing" list item
- (Potentially) Onboarding flow → location setup step
- (Potentially) Search page → "Enable location for better results" prompt

**Exit Points:**
- Back button → Returns to entry point (typically Settings)
- After permission granted → Returns to entry point or shows confirmation
- After permission denied → Shows different content or returns to Settings

**Navigation Style:**
- Full-page push navigation (slides in from right)
- Back button dismisses with slide-out to left
- No modal presentation (not dismissible by swipe down)

### Permission Request Flow

**Before This Page:**
1. App checks permission status
2. If not granted, shows this page
3. User reads content

**On This Page:**
1. User clicks "Turn on location sharing" button
2. `onEnableLocation()` called
3. System permission dialog appears

**System Dialog:**
- iOS: "Allow 'JourneyMate' to use your location?"
  - "Allow While Using App"
  - "Allow Once"
  - "Don't Allow"
- Android: "Allow JourneyMate to access this device's location?"
  - "While using the app"
  - "Only this time"
  - "Don't allow"

**After Dialog Dismisses:**
- If granted: navigate away or show success
- If denied: update app state, potentially show "Open Settings" guidance
- If "Allow Once": treat as granted for this session

### Error Handling (Not Shown in Design)

**Possible Errors:**
- Permission API not available (very rare)
- User already denied permanently (requires "Open Settings" flow)

**Design Does Not Include:**
- Error state UI
- "Open Settings" CTA (for permanent deny)
- Loading state (permission dialog appears immediately)

These would be handled by parent component or different page variation.

### Data Requirements

**No API Calls:** Page is purely presentational, no data fetching.

**No Persistence:** Page does not store permission status (handled by system).

**No Analytics (Explicit):** Design does not specify analytics events, but implementation should track:
- Page viewed
- "Turn on location sharing" clicked
- Permission granted/denied result

---

## Implementation Notes (Design-to-Code)

### Component Architecture

**Suggested Structure:**
```
LocationSharingPage (Stateless)
  ├─ StatusBar (imported)
  ├─ Header
  │   ├─ BackButton
  │   └─ Title
  └─ Content
      ├─ Heading
      ├─ Description
      ├─ CTAButton
      └─ PrivacyStatement
```

**Why Stateless:**
- No local state needed
- All logic in parent component
- Pure presentation based on props

### Responsive Considerations

**Fixed Width Design:** 390px (iPhone 12/13/14 width)

**For Larger Screens:**
- Consider max-width constraint on content (e.g., 390px centered)
- Or keep full width but increase padding
- Button should stay full-width within container (not grow to 600px on tablets)

**For Smaller Screens:**
- Reduce top/bottom padding if needed (32px → 24px)
- Keep left/right padding at 24px minimum
- Font sizes stay same (already mobile-optimized)

### Animation Opportunities

**Not Defined in Design, but Recommended:**

1. **Page Transition:**
   - Slide in from right on entry
   - Slide out to left on back button
   - 300ms duration, ease-out curve

2. **Button Press:**
   - Scale to 0.98 on touch
   - 100ms duration
   - Or subtle opacity change (1.0 → 0.9)

3. **Content Fade-In:**
   - Heading, description, button, privacy text fade in sequentially
   - 200ms delay between elements
   - Creates polished feel on page load

**No Loading State:**
- Permission dialog appears immediately
- No need for spinner or skeleton

### Accessibility Implementation

**Semantic HTML (Web) / Accessibility IDs (Native):**
- `<h2>` for heading (or appropriate heading level)
- `<p>` for description and privacy text
- `<button>` for back button and CTA
- Proper ARIA labels if needed

**Focus Management:**
- Initial focus on back button (standard navigation)
- Tab order: back button → CTA button
- Text elements not focusable (not interactive)

**Screen Reader:**
- Heading: "Turn on location sharing"
- Description: reads full benefit explanation
- Button: "Turn on location sharing, button"
- Privacy: reads full privacy statement

**Dynamic Content:**
- If page shows different content based on permission state (e.g., "Open Settings" instead), announce change to screen reader

### Testing Checklist

**Visual Testing:**
- [ ] Page renders correctly on 390px width
- [ ] All text is centered
- [ ] Back button is 36×36px and aligned left
- [ ] Header title is centered (accounting for back button)
- [ ] CTA button is full width with 24px padding on sides
- [ ] Spacing matches spec (16px, 24px gaps)
- [ ] Colors match tokens (ACCENT, #0f0f0f, #555, #888)

**Interaction Testing:**
- [ ] Back button navigates to previous page
- [ ] CTA button triggers permission request
- [ ] System permission dialog appears after CTA click
- [ ] Page responds correctly to permission grant
- [ ] Page responds correctly to permission deny
- [ ] Touch targets are adequate size (44×44px minimum)

**Content Testing:**
- [ ] All text is readable (contrast, size)
- [ ] Description explains concrete benefits
- [ ] Privacy statement is visible before action
- [ ] No typos or grammar errors

**Accessibility Testing:**
- [ ] VoiceOver/TalkBack reads content correctly
- [ ] Focus order is logical (back → CTA)
- [ ] Button labels are descriptive
- [ ] Color contrast meets WCAG AA minimum

**Edge Case Testing:**
- [ ] Permission already granted (page should not show)
- [ ] Permission denied permanently (should show different content)
- [ ] User denies in dialog (page should respond appropriately)
- [ ] User presses back button (navigation works)

---

## Design System Compliance

### Color Usage

**Orange (ACCENT) Usage: ✓ Correct**
- Used for CTA button (interactive element)
- Not used for decorative purposes
- Aligns with "Orange = interactive only" rule

**Green Usage: N/A**
- No green used (not a match confirmation page)

**Black Usage: ✓ Correct**
- Darkest text is `#0f0f0f` (primary text)
- No black backgrounds (follows "No black backgrounds" rule)

**Background: ✓ Correct**
- White background (`#fff`)
- Follows standard page background pattern

### Typography

**Font Weights:**
- 700 (heading) → `FontWeight.w700`
- 600 (title, button) → `FontWeight.w600`
- 400 (description, privacy) → `FontWeight.w400`

All weights are standard values, no custom mapping needed.

**Font Sizes:**
- 22px (heading) — page title size
- 16px (button) — standard CTA size
- 14px (description) — standard body text
- 13px (privacy) — standard fine print

All sizes follow existing patterns from other pages.

### Spacing

**Padding Values:**
- 32px (top/bottom) — standard page padding
- 24px (left/right) — standard page padding
- 20px (header horizontal) — standard header padding

**Margins:**
- 16px (heading bottom) — standard heading spacing
- 24px (element spacing) — standard section spacing

All spacing values are multiples of 8px (grid compliance).

### Component Patterns

**Header Pattern: ✓ Matches**
- 60px height
- Back button left, title centered
- 1px border bottom `#f2f2f2`
- Matches Search, Business Profile, other pages

**Button Pattern: ✓ Matches**
- 50px height (standard CTA)
- 12px border radius (standard button)
- ACCENT background (orange)
- White text
- Full width in container

**No Custom Patterns:**
- No new component types introduced
- All elements use established patterns
- Aligns with existing design system

---

## Cross-Page Consistency

### Similar Pages

**Settings Pages:**
- Account settings
- Notification preferences
- Privacy settings
- Language selection

**Permission Pages:**
- Location sharing (this page)
- Notification permission
- Camera permission (if app uses photos)

**Common Patterns:**
- Header with back button and centered title
- Content padding: 32px/24px
- Centered text alignment
- Single primary action
- White background

### Differences from Other Pages

**Unlike Search/Business Profile:**
- No bottom tab bar (Settings section has no tabs)
- No filter UI
- No card-based layout
- No scroll (fits in viewport)

**Unlike Onboarding:**
- No multi-step flow
- No progress indicators
- No "Next" button (only single action)
- Accessed via Settings, not initial launch

**Unlike Full Menu/Gallery:**
- No full-screen overlay
- No close button (uses back button)
- No navigation gesture (standard page push/pop)

### Design Consistency Elements

**Present on This Page:**
- StatusBar component (shared)
- ACCENT color token (shared)
- Standard header pattern
- Standard button pattern
- Standard spacing values

**Not Present (Correctly):**
- Bottom tab bar (Settings pages don't have tabs)
- Card components (not a list view)
- Filter UI (not a discovery page)
- Match indicators (not relevant to permissions)

---

## Future Considerations

### Permission Status Variations

**Current Design:** Assumes permission not granted.

**Future Needs:**

1. **Permission Granted State:**
   - Change heading: "Location sharing is on"
   - Change description: "JourneyMate has access to your location."
   - Change button: "Turn off location sharing" or "Open Settings"
   - Add status indicator: green checkmark or "Enabled" badge

2. **Permission Denied Permanently:**
   - Change heading: "Location access required"
   - Change description: "JourneyMate needs location access to show nearby restaurants."
   - Change button: "Open Settings" (launches iOS Settings app)
   - Add instructional text: "1. Open Settings, 2. Tap Location, 3. Select 'While Using App'"

3. **Permission Denied Once (Can Re-Request):**
   - Keep current design
   - Add note: "You previously declined. We need location access to show nearby restaurants."

### Permission Precision (iOS 14+)

**Current Design:** Requests "While Using App" permission.

**Future Consideration:**
- iOS offers "Precise Location" toggle in Settings
- App may need to request precise location if user enables "Approximate Location"
- Could add section explaining why precise location is preferred (more accurate results)

### Integration with Onboarding

**Current:** Accessed via Settings.

**Future:** May be step in onboarding flow.

**Design Changes Needed:**
- Add progress indicator (1 of 3, 2 of 3, etc.)
- Change back button to "Skip" (if permission not mandatory)
- Add "Next" or "Continue" after permission granted
- Adjust header title to fit onboarding context

### Analytics Integration

**Current:** No explicit analytics in design.

**Future Implementation Should Track:**
- `location_sharing_page_viewed`
- `location_sharing_enable_clicked`
- `location_permission_granted`
- `location_permission_denied`
- `location_sharing_back_clicked`

### Geolocation-Dependent Features

**Current:** Generic benefit description ("nearby restaurants").

**Future:** Could personalize based on user's location:
- "Show restaurants within 2 miles"
- "Find places near [City Name]"
- "Discover hidden gems in your neighborhood"

But keep generic for privacy-sensitive users.

---

## Conclusion

The Location Sharing page is a focused, single-purpose permission request screen that prioritizes clarity, transparency, and user trust. By following iOS design patterns, using centered alignment for focus, and including an explicit privacy commitment, the design reduces friction in the permission request flow while building user confidence.

Key design strengths:
- **Clear value proposition** — benefits explained before request
- **Single primary action** — reduces decision paralysis
- **Trust through transparency** — privacy commitment visible
- **Platform consistency** — follows iOS Settings patterns
- **Visual simplicity** — no unnecessary decoration

The design is intentionally static and stateless, delegating all logic to the parent component. This keeps the page maintainable and makes it easy to reuse in different contexts (Settings, Onboarding, first-time search) with only prop changes.

Future iterations should consider permission status variations (granted, denied permanently) and potential integration into onboarding flow, but the core pattern established here provides a solid foundation.
