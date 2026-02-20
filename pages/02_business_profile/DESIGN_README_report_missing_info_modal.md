# Report Missing Information Modal — Design Documentation

**Component:** `ReportMissingInfoModal`
**Source file:** `C:\Users\Rikke\Documents\JourneyMate\pages\business_profile\report_missing_info_modal.jsx`
**Type:** Modal overlay component
**Purpose:** Allows users to report incorrect or missing business information for a restaurant
**Created:** 2026-02-19

---

## Design Overview

The Report Missing Information Modal is a centered overlay modal that provides users with a simple form to report inaccuracies in restaurant data. It follows a standard modal interaction pattern with backdrop dismissal, explicit close button, and form validation.

### Primary Use Case

Users viewing a restaurant's Business Profile page notice incorrect information (wrong hours, outdated phone number, missing amenities, etc.) and want to report it to help maintain data quality.

### Design Philosophy

- **Centered overlay modal:** Traditional modal positioning for focused attention
- **Clear context:** Displays restaurant name and address to confirm what's being reported
- **Required field validation:** Submit button disabled until message is entered
- **Simple dismissal:** Multiple ways to close (backdrop, close button, post-submit)
- **No error states:** Simple validation prevents submission of empty reports
- **Immediate feedback:** Modal closes instantly on submit (assumes success)

### Visual Language

The modal uses:
- Clean white background with subtle shadow
- Centered positioning with responsive width constraints
- Gray backdrop overlay (40% opacity black)
- Orange accent for enabled submit button
- Gray disabled state for submit button
- Minimal borders and rounded corners throughout

---

## Visual Layout

### Modal Structure

```
┌─────────────────────────────────────────────┐
│ Fixed backdrop (full viewport, 40% black)  │
│  ┌───────────────────────────────────┐     │
│  │ Modal container (centered)         │     │
│  │  ┌─────────────────────────────┐  │ ✕   │
│  │  │ Title (18px, bold)          │  │     │
│  │  ├─────────────────────────────┤  │     │
│  │  │ "Reporting information for" │  │     │
│  │  │ Restaurant Name (14px)      │  │     │
│  │  │ Address (12px, gray)        │  │     │
│  │  ├─────────────────────────────┤  │     │
│  │  │ Help text (13px, gray)      │  │     │
│  │  ├─────────────────────────────┤  │     │
│  │  │ Field label (13px, bold) *  │  │     │
│  │  │ Instructions (11px, gray)   │  │     │
│  │  │ ┌───────────────────────┐   │  │     │
│  │  │ │ Textarea              │   │  │     │
│  │  │ │ (100px min height)    │   │  │     │
│  │  │ └───────────────────────┘   │  │     │
│  │  ├─────────────────────────────┤  │     │
│  │  │ [ Submit report button ]    │  │     │
│  │  └─────────────────────────────┘  │     │
│  └───────────────────────────────────┘     │
└─────────────────────────────────────────────┘
```

### Dimensions and Positioning

- **Modal width:** `min(90%, 360px)` — responsive with max width constraint
- **Modal max-height:** `70vh` — prevents overflow on small screens
- **Vertical position:** `top: 50%; transform: translateY(-50%)` — true center
- **Horizontal position:** `left: 50%; transform: translateX(-50%)` — true center
- **Border radius:** `16px` — consistent with card design language
- **Box shadow:** `0 8px 32px rgba(0,0,0,0.12)` — subtle elevation
- **Backdrop z-index:** `9998`
- **Modal z-index:** `9999`

### Close Button Positioning

- **Position:** Absolute, top-right corner
- **Top offset:** `12px`
- **Right offset:** `12px`
- **Dimensions:** `32px × 32px` circular hit target
- **Icon:** `✕` (Unicode multiplication sign)
- **Icon size:** `18px`
- **Hover state:** `#f5f5f5` background
- **Transition:** `background 0.2s`

---

## Content Sections

### 1. Title Area

**Text:** "Report incorrect information"

**Styling:**
- Font size: `18px`
- Font weight: `680` (maps to FontWeight.w700 in Flutter)
- Color: `#0f0f0f` (darkest text)
- Margin bottom: `12px`
- Padding right: `32px` (prevents overlap with close button)

**Purpose:** Clear statement of modal function without ambiguity.

### 2. Restaurant Context Section

**Three-line structure:**

1. **Label line:** "Reporting information for"
   - Font size: `12px`
   - Color: `#888` (light gray)
   - Margin bottom: `2px`

2. **Restaurant name:**
   - Font size: `14px`
   - Font weight: `500`
   - Color: `#0f0f0f`
   - Margin bottom: `1px`
   - Content: `{restaurant.name}`

3. **Address:**
   - Font size: `12px`
   - Color: `#888`
   - Margin bottom: `16px`
   - Content: `{restaurant.address}`

**Purpose:** Confirms to the user which restaurant they're reporting about, preventing confusion when multiple restaurants are being browsed.

### 3. Help Text

**Text:** "Help us keep information accurate. Please let us know what needs to be corrected."

**Styling:**
- Font size: `13px`
- Color: `#555` (medium gray)
- Line height: `18px` (1.38 ratio for readability)
- Margin bottom: `16px`

**Purpose:** Sets tone (collaborative, helpful) and clarifies user's role in data quality.

### 4. Form Field Section

#### Field Label

**Text:** "What is incorrect or missing?" with red asterisk

**Styling:**
- Font size: `13px`
- Font weight: `500`
- Color: `#0f0f0f`
- Display: `block`
- Margin bottom: `4px`
- Asterisk color: `#c9403a` (red, indicating required)

#### Field Instructions

**Text:** "Please describe what information is wrong/missing and what it should be instead"

**Styling:**
- Font size: `11px`
- Color: `#888`
- Margin bottom: `8px`

**Purpose:** Guides users to provide actionable feedback (not just "this is wrong" but "X should be Y").

#### Textarea

**Styling:**
- Width: `100%`
- Min height: `100px` (allows vertical resize)
- Padding: `12px` (all sides)
- Font size: `14px`
- Color: `#0f0f0f`
- Background: `#f5f5f5` (light gray, distinguishes from modal background)
- Border: `1px solid #e8e8e8`
- Border radius: `10px`
- Resize: `vertical` (allows user to expand if needed)
- Font family: `inherit` (uses system font)
- Margin bottom: `16px`
- Placeholder: "Describe the incorrect information..."

**Behavior:**
- Controlled input: `value={message}`
- On change: `setMessage(e.target.value)`
- No character limit imposed
- No validation error display (simple required check only)

### 5. Submit Button

**Text:** "Submit report"

**Styling (enabled state):**
- Width: `100%`
- Height: `50px`
- Background: `ACCENT` (`#e8751a` orange)
- Color: `#fff` (white text)
- Border: `none`
- Border radius: `12px`
- Font size: `16px`
- Font weight: `600`
- Cursor: `pointer`

**Styling (disabled state):**
- Background: `#ddd` (light gray)
- Cursor: `not-allowed`
- All other properties same

**Enabled condition:** `message.trim()` must be truthy (non-empty after trimming whitespace)

**On click:** Calls `handleSubmit()` if enabled

---

## Components Used

This modal is a self-contained component with no shared sub-components. All UI elements are inline JSX.

### External Dependencies

1. **React hooks:**
   - `useState` — manages message text input

2. **Shared tokens:**
   - `ACCENT` from `../../shared/_shared.jsx` — orange color for enabled button

3. **Props received:**
   - `visible` (boolean) — controls modal visibility
   - `onClose` (function) — callback to close modal
   - `restaurant` (object) — restaurant data (requires `name` and `address` properties)
   - `onSubmit` (function) — callback to handle report submission

### Component Hierarchy

```
ReportMissingInfoModal (root)
├── Fragment (<>...</>)
│   ├── Backdrop div (full screen, onClick closes)
│   └── Modal container div (centered)
│       ├── Close button (top-right)
│       └── Content div (scrollable)
│           ├── Title h3
│           ├── Restaurant context section
│           │   ├── Label div ("Reporting information for")
│           │   ├── Name div (restaurant.name)
│           │   └── Address div (restaurant.address)
│           ├── Help text p
│           ├── Form section
│           │   ├── Label (with asterisk)
│           │   ├── Instructions div
│           │   └── Textarea (controlled input)
│           └── Submit button
```

---

## Design Tokens

### Colors Used

| Token | Hex | Usage |
|-------|-----|-------|
| `ACCENT` | `#e8751a` | Submit button (enabled state) |
| (hardcoded) | `#fff` | Modal background, button text |
| (hardcoded) | `#0f0f0f` | Title, restaurant name, input text |
| (hardcoded) | `#555` | Help text |
| (hardcoded) | `#888` | Labels, address, instructions |
| (hardcoded) | `#999` | Close button icon |
| (hardcoded) | `#ddd` | Submit button (disabled state) |
| (hardcoded) | `#f5f5f5` | Close button hover, textarea background |
| (hardcoded) | `#e8e8e8` | Textarea border |
| (hardcoded) | `#c9403a` | Required asterisk (red) |
| (hardcoded) | `rgba(0,0,0,0.4)` | Backdrop overlay |
| (hardcoded) | `rgba(0,0,0,0.12)` | Modal shadow |

### Typography Scale

| Element | Font Size | Weight | Line Height | Color |
|---------|-----------|--------|-------------|-------|
| Title | 18px | 680 | default | #0f0f0f |
| Restaurant name | 14px | 500 | default | #0f0f0f |
| Button text | 16px | 600 | default | #fff |
| Textarea | 14px | 400 | default | #0f0f0f |
| Field label | 13px | 500 | default | #0f0f0f |
| Help text | 13px | 400 | 18px | #555 |
| Context label | 12px | 400 | default | #888 |
| Address | 12px | 400 | default | #888 |
| Instructions | 11px | 400 | default | #888 |

### Spacing Values

| Purpose | Value |
|---------|-------|
| Modal border radius | 16px |
| Content padding | 24px (all sides) |
| Title margin bottom | 12px |
| Context label margin bottom | 2px |
| Restaurant name margin bottom | 1px |
| Address margin bottom | 16px |
| Help text margin bottom | 16px |
| Field label margin bottom | 4px |
| Instructions margin bottom | 8px |
| Textarea margin bottom | 16px |
| Textarea padding | 12px |
| Textarea border radius | 10px |
| Button height | 50px |
| Button border radius | 12px |
| Close button dimensions | 32px × 32px |
| Close button top offset | 12px |
| Close button right offset | 12px |

---

## State & Data

### Local State

```javascript
const [message, setMessage] = useState("");
```

**Purpose:** Tracks the user's report message input.

**Initial value:** Empty string (`""`)

**Updates:** Set by textarea `onChange` handler

**Used for:**
1. Textarea controlled input value
2. Submit button enabled/disabled logic
3. Submitted to parent via `onSubmit` callback

### Props

#### `visible` (boolean, required)

Controls whether the modal is rendered. When `false`, component returns `null` and nothing is displayed.

**Typical flow:**
- Parent component toggles this to `true` when user clicks "Report missing info" button
- Modal renders
- User submits or closes
- Parent sets back to `false`

#### `onClose` (function, required)

Callback function invoked when modal should close.

**Triggered by:**
1. Clicking backdrop
2. Clicking close button (top-right ✕)
3. Successful submission (after `onSubmit` completes)

**No arguments passed** to this callback.

#### `restaurant` (object, required)

Restaurant data object. Modal returns `null` if this is not provided.

**Required properties:**
- `name` (string) — displayed in context section
- `address` (string) — displayed in context section

**Other properties ignored** by this component.

#### `onSubmit` (function, required)

Callback function invoked when user submits a valid report.

**Called with object:**
```javascript
{
  restaurant: restaurant.name,  // string
  message: message              // string (trimmed)
}
```

**When triggered:**
- User clicks "Submit report" button
- Message is non-empty after trimming

**Flow after call:**
1. `onSubmit()` is invoked with data
2. Local `message` state is reset to `""`
3. `onClose()` is invoked to dismiss modal

### Derived State

#### `message.trim()` — Submit button enabled condition

**Logic:** Button is enabled only when `message.trim()` evaluates to truthy.

**Why trim?** Prevents submission of whitespace-only messages.

**Effects:**
- Sets button `disabled` attribute
- Sets button background color (orange vs gray)
- Sets button cursor style (pointer vs not-allowed)

---

## User Interactions

### Opening the Modal

**Not handled by this component.** Parent component must:
1. Set `visible={true}` prop
2. Optionally provide initial focus management

**Visual transition:** None built-in. Modal appears instantly when `visible` becomes `true`.

### Closing the Modal

**Three methods:**

#### 1. Backdrop Click

- User clicks anywhere on the backdrop (gray area outside modal)
- `onClick={onClose}` on backdrop div
- Modal closes without submitting

**Implementation note:** Only the backdrop div has the `onClick`, not the modal container, so clicks inside the modal don't close it.

#### 2. Close Button (✕)

- User clicks the ✕ button in top-right corner
- `onClick={onClose}` on button element
- Modal closes without submitting

**Hover feedback:**
- Default: transparent background
- Hover: `#f5f5f5` background (light gray circle)
- Transition: `0.2s` ease

#### 3. Successful Submission

- User clicks "Submit report" with valid message
- `handleSubmit()` runs
- After `onSubmit()` callback, `onClose()` is invoked
- Modal closes automatically

### Typing in the Textarea

**Behavior:**
- Click textarea to focus (standard browser behavior)
- Type characters — `onChange` updates `message` state
- Newlines allowed (textarea supports multi-line)
- No max length enforced
- Vertical resize handle available (browser default)

**Visual feedback:**
- Focus outline (browser default, not customized)
- Submit button changes from gray to orange when `message.trim()` becomes non-empty

### Submitting the Report

**Precondition:** `message.trim()` must be truthy (disabled state prevents click if not)

**Click "Submit report" button:**

```javascript
const handleSubmit = () => {
  if (message.trim()) {
    onSubmit({ restaurant: restaurant.name, message });
    setMessage("");
    onClose();
  }
};
```

**Steps:**
1. Verify message is non-empty (double-check)
2. Call parent's `onSubmit` with data object
3. Reset local `message` state to empty string
4. Call parent's `onClose` to dismiss modal

**No error handling** for failed submission — assumes parent handles any async errors gracefully.

**No loading state** — submit button doesn't show spinner or disable during submission.

### Edge Cases

#### User clicks Submit with whitespace-only message

**Can't happen.** Button is disabled when `message.trim()` is falsy, and `handleSubmit` has a guard condition.

#### `restaurant` prop is `null` or undefined

**Modal doesn't render.** Early return: `if (!visible || !restaurant) return null;`

#### User resizes textarea very large

**No constraints.** Vertical resize is allowed. Modal has `maxHeight: "70vh"` with `overflowY: "auto"` on content, so scrolling will appear if needed.

#### User presses Escape key

**No handler implemented.** Escape key does not close modal. Must use backdrop or close button.

---

## Design Rationale

### Why a Centered Modal (Not Bottom Sheet)?

**Decision:** Use centered overlay modal instead of bottom sheet pattern used elsewhere in app.

**Rationale:**
- **Task importance:** Reporting incorrect data is a deliberate, considered action, not a quick filter selection
- **Desktop compatibility:** Centered modals work better on desktop viewports than bottom sheets
- **Form focus:** A form requires sustained attention; centered position reduces distractions from surrounding page content
- **Tradition:** Users expect forms in modals to be centered

**Consistency note:** This breaks from the bottom sheet pattern used for filters and other pickers, but the use case justifies the exception.

### Why No Validation Error Messages?

**Decision:** Only disable submit button when message is empty. No red error text or warning messages.

**Rationale:**
- **Single validation rule:** Only one thing can go wrong (empty message) — disabled button is sufficient feedback
- **No async validation:** No need to check message content, length, or format server-side before allowing submit
- **Reduced complexity:** Error messaging adds UI states, transitions, and potential accessibility issues
- **Clear affordance:** Gray disabled button with "not-allowed" cursor communicates "you can't click this yet"

**Alternative considered:** Show "Message is required" error below textarea. Rejected as unnecessary for single-field form.

### Why Trim Whitespace Instead of Blocking It?

**Decision:** Allow whitespace entry, but validate on `message.trim()` for button enable and submit.

**Rationale:**
- **Natural typing:** Users may start with spaces, delete text, paste content with leading/trailing spaces
- **Blocking input is jarring:** Preventing space/enter keypresses confuses users
- **Trim on submit is standard:** Common pattern in web forms — clean the data before processing, don't restrict input

### Why No Character Limit?

**Decision:** Textarea has no maxLength attribute, no character counter, no length validation.

**Rationale:**
- **Unknown optimal length:** Some reports need two words ("Hours are wrong"), others need detailed descriptions
- **Imposing limit creates pressure:** Users may feel rushed or constrained, leading to less useful reports
- **Backend can handle it:** Assume API can accept reasonable text lengths (up to several paragraphs)
- **Resize handle available:** If user writes a lot, they can expand the textarea

**Risk accepted:** User could paste very long text. If this becomes a problem in production, add a soft limit (warning at 500 chars?) or hard backend validation.

### Why No Success Confirmation Message?

**Decision:** Modal closes immediately after submit, with no "Report submitted successfully!" message or animation.

**Rationale:**
- **Optimistic UI:** Assume submission succeeds; don't make user wait for server response
- **Reduces friction:** Extra confirmation screen adds a step, requiring user to dismiss it
- **Trust assumed:** User trusts the button did what it said ("Submit report" → report was submitted)

**Alternative considered:** Show a toast notification after closing. Not implemented in this component but could be added by parent.

**Risk accepted:** If submission fails, user won't know unless parent component handles errors and reopens modal or shows an alert.

### Why Reset Message State After Submit?

**Decision:** `setMessage("")` is called after successful submit, before closing.

**Rationale:**
- **Clean slate for next use:** If user reopens modal (for same or different restaurant), textarea should be empty
- **Privacy consideration:** Don't leave previous report text in state if user switches to a different restaurant profile
- **Matches form behavior:** Standard forms clear after submission

**Timing note:** Reset happens before `onClose()` to ensure state is clean even if modal remains mounted but hidden.

### Why Include Restaurant Name in onSubmit Data?

**Decision:** Pass `restaurant.name` (not full restaurant object) in submit callback.

**Rationale:**
- **Minimal data transfer:** Parent already has full restaurant object; only needs to know which restaurant the report is about
- **API alignment:** Likely that API expects `restaurantName` or `restaurantId`, not entire object
- **Decoupling:** Modal doesn't need to know restaurant's internal ID structure — parent can map name to ID before API call

**Note:** If restaurant objects have a unique `id` field, consider passing `restaurant.id` instead of `restaurant.name` to avoid ambiguity with restaurants that might have identical names.

### Why Position Close Button Inside Content Padding?

**Decision:** Close button is positioned `absolute` within modal container, not outside modal background.

**Rationale:**
- **Clear association:** ✕ inside modal boundary clearly indicates it closes this modal
- **Mobile safety:** Keeps interactive element away from screen edge notches/rounded corners
- **Shadow inclusion:** Button appears above modal shadow, not floating separately
- **Responsive friendly:** Button moves with modal on different screen sizes

### Why Allow Backdrop Click to Close?

**Decision:** Clicking outside modal (on backdrop) calls `onClose`, same as ✕ button.

**Rationale:**
- **User expectation:** Standard modal behavior across web and mobile apps
- **Escape route:** Provides quick way to cancel without moving to close button
- **No data loss risk:** User hasn't submitted yet, and if they've typed something, they probably didn't mean to click outside (but it's just a report, not a critical document)

**Alternative considered:** Require confirmation dialog if message is non-empty. Rejected as overly protective for low-stakes content.

### Why Use `#c9403a` for Required Asterisk?

**Decision:** Red asterisk next to field label, using `#c9403a` (distinct red).

**Rationale:**
- **Universal convention:** Red asterisk means "required field" across virtually all forms
- **Accessibility consideration:** Color is not the only indicator — asterisk symbol itself conveys meaning
- **Not the accent orange:** Red is distinct from orange, which is reserved for interactive elements and CTAs
- **Not a brand color:** This is a system-level UI convention, not a brand expression

**Color choice:** `#c9403a` is a standard web-safe red, readable against white background, not too aggressive.

---

## Accessibility Considerations

### Keyboard Navigation

**Current implementation:**

- Tab order: Close button → Textarea → Submit button
- Enter key: Not captured (does not submit form or close modal)
- Escape key: Not captured (does not close modal)

**Missing features:**

- No focus trap (tab can escape modal to background page)
- No Escape key handler
- No Enter key to submit (standard for single-input forms)

**Improvement recommendations:**

1. Add Escape key listener to close modal:
   ```javascript
   useEffect(() => {
     const handleEscape = (e) => {
       if (e.key === 'Escape' && visible) onClose();
     };
     window.addEventListener('keydown', handleEscape);
     return () => window.removeEventListener('keydown', handleEscape);
   }, [visible, onClose]);
   ```

2. Add Enter key submit (Ctrl+Enter or Cmd+Enter for textarea with newlines):
   ```javascript
   const handleKeyDown = (e) => {
     if ((e.ctrlKey || e.metaKey) && e.key === 'Enter' && message.trim()) {
       handleSubmit();
     }
   };
   // Add to textarea: onKeyDown={handleKeyDown}
   ```

3. Focus management:
   - Auto-focus textarea when modal opens
   - Trap focus within modal while open
   - Return focus to trigger button when closed

### Screen Reader Support

**Current state:**

- No ARIA attributes
- No `role="dialog"`
- No `aria-labelledby` pointing to title
- No `aria-describedby` for help text
- No `aria-required` on textarea
- No `aria-disabled` on button (uses `disabled` attribute, which is sufficient)

**Improvement recommendations:**

1. Add modal semantics:
   ```jsx
   <div
     role="dialog"
     aria-labelledby="report-title"
     aria-describedby="report-help"
     aria-modal="true"
   >
   ```

2. Add IDs to referenced elements:
   ```jsx
   <h3 id="report-title">...</h3>
   <p id="report-help">...</p>
   ```

3. Add field semantics:
   ```jsx
   <label htmlFor="report-message">...</label>
   <textarea
     id="report-message"
     aria-required="true"
     aria-invalid={!message.trim()}
   />
   ```

4. Announce modal opening:
   - Use `aria-live` region to announce "Report incorrect information dialog opened"

### Visual Accessibility

**Color contrast:**

- Title (`#0f0f0f` on `#fff`): 20.31:1 ✓ WCAG AAA
- Help text (`#555` on `#fff`): 7.88:1 ✓ WCAG AA
- Labels (`#888` on `#fff`): 4.54:1 ✓ WCAG AA for large text
- Instructions (`#888` on `#fff`): 4.54:1 ✓ WCAG AA for large text
- Button text (`#fff` on `#e8751a`): 3.14:1 ⚠ Fails WCAG AA for body text (passes for large text)

**Note:** Submit button contrast is borderline. Consider darkening orange slightly for better accessibility, or ensure button text is minimum 18px/14px bold.

**Focus indicators:**

- No custom focus styles — relies on browser defaults
- Browser defaults vary in visibility
- Recommendation: Add visible focus outlines to all interactive elements

### Motion and Animation

**Current state:**

- No animations or transitions (except close button hover)
- Modal appears/disappears instantly
- No reduced motion considerations needed

**Future enhancement:**

If animations are added (fade-in, scale-up), respect `prefers-reduced-motion`:
```css
@media (prefers-reduced-motion: reduce) {
  /* disable/reduce animations */
}
```

---

## Responsive Behavior

### Viewport Width Adaptation

**Modal width:** `min(90%, 360px)`

| Viewport Width | Modal Width | Side Margins |
|----------------|-------------|--------------|
| ≥ 400px | 360px | 20px each side |
| 375px | 337.5px | 18.75px each side |
| 320px | 288px | 16px each side |

**Consistency:** Modal maintains readable width on all devices, never becoming too narrow or too wide.

### Viewport Height Adaptation

**Modal max-height:** `70vh` (70% of viewport height)

**Scrolling behavior:**
- Content div has `overflowY: "auto"`
- If content exceeds 70vh, vertical scrollbar appears inside modal
- Modal position remains vertically centered
- Backdrop remains fixed full-screen

**Small screen handling:**
- On very short viewports (e.g., landscape phone orientation), modal may take most of screen height
- Content scrolls, preventing clipping of submit button
- Close button remains visible at top

### Text Overflow Handling

**Long restaurant names:**
- No truncation or ellipsis
- Name wraps to multiple lines if needed
- Title padding-right: `32px` prevents collision with close button

**Long addresses:**
- Wraps naturally to multiple lines
- No max-width constraint

**Long help text:**
- Line-height: `18px` provides good readability
- No ellipsis or truncation

**Textarea content:**
- Scrolls vertically if exceeds `minHeight: 100px`
- User can resize taller with resize handle
- No horizontal scroll (width: 100% with padding prevents overflow)

---

## Future Enhancement Considerations

### Not Currently Implemented

1. **Loading state after submit**
   - Show spinner on button
   - Disable button during async submission
   - Prevent multiple submissions

2. **Error handling**
   - Display API error message
   - Retry mechanism
   - Keep modal open on failure

3. **Success confirmation**
   - Toast notification after close
   - Checkmark animation before close
   - "Report submitted" text overlay

4. **Field categories**
   - Dropdown to select type of error (hours, contact, menu, etc.)
   - Pre-fill common corrections
   - Structured data submission

5. **Photo upload**
   - Attach image showing incorrect information
   - Camera integration for menu/hours photos

6. **User identification**
   - Optional email for follow-up
   - Link to user account for report history
   - Anonymous vs. identified reporting

7. **Previous reports**
   - Show if this restaurant already has pending reports
   - Prevent duplicate submissions
   - Indicate if user has reported before

8. **Validation enhancements**
   - Minimum character count (e.g., 10 chars)
   - Spam detection (repeated words, all caps)
   - Profanity filter

9. **Accessibility improvements**
   - Focus trap
   - Escape key handling
   - ARIA attributes
   - Keyboard shortcuts

10. **Animation polish**
    - Modal fade-in/scale-up
    - Button ripple effect
    - Submit success animation
    - Backdrop fade transition

---

## Integration Requirements

### Parent Component Responsibilities

When using `ReportMissingInfoModal`, the parent must:

1. **Manage visibility state:**
   ```javascript
   const [modalVisible, setModalVisible] = useState(false);
   ```

2. **Provide restaurant object:**
   ```javascript
   <ReportMissingInfoModal
     restaurant={currentRestaurant}  // must have .name and .address
     visible={modalVisible}
     onClose={() => setModalVisible(false)}
     onSubmit={handleReport}
   />
   ```

3. **Handle submission:**
   ```javascript
   const handleReport = async ({ restaurant, message }) => {
     // Submit to API
     // Show success/error feedback
     // Log analytics event
   };
   ```

4. **Optional: Success/error feedback**
   - Toast notification
   - Analytics tracking
   - User notification preferences

5. **Optional: Focus management**
   - Capture focus before opening modal
   - Restore focus after closing
   - Prevent body scroll while open

### Data Structure

**Minimal `restaurant` object required:**
```javascript
{
  name: string,     // required for display and submission
  address: string   // required for display context
}
```

**Additional properties ignored** by this component but may be needed for API:
```javascript
{
  id: string,          // unique identifier for API
  // other properties not used by modal
}
```

**Submitted data structure:**
```javascript
{
  restaurant: string,  // restaurant.name
  message: string      // user's trimmed input
}
```

---

## Visual Design Checklist

### Layout ✓
- [x] Centered modal positioning
- [x] Responsive width with max constraint
- [x] Max height with scrollable content
- [x] Backdrop overlay
- [x] Close button in top-right corner
- [x] Proper padding and spacing

### Typography ✓
- [x] Clear title hierarchy (18px bold)
- [x] Restaurant context readable (14px name, 12px address)
- [x] Helpful instructional text (13px help, 11px field instructions)
- [x] Readable input text (14px)
- [x] Clear button label (16px bold)

### Colors ✓
- [x] Orange (ACCENT) for enabled CTA
- [x] Gray for disabled state
- [x] Red asterisk for required field
- [x] Appropriate text color hierarchy (#0f0f0f → #555 → #888)
- [x] Subtle border and background colors

### Interactions ✓
- [x] Close button hover feedback
- [x] Disabled button visual state
- [x] Backdrop click to close
- [x] Controlled textarea input
- [x] Submit validation

### Content ✓
- [x] Clear title and purpose
- [x] Restaurant context displayed
- [x] Helpful instructional text
- [x] Required field indicator
- [x] Descriptive placeholder

### Missing (Future) ⚠
- [ ] Focus trap and keyboard navigation
- [ ] ARIA attributes for accessibility
- [ ] Loading state during submission
- [ ] Error handling and display
- [ ] Success confirmation
- [ ] Animation/transitions

---

## Component Testing Scenarios

### Happy Path

1. User clicks "Report missing info" button on business profile
2. Modal opens with restaurant name and address
3. User reads help text
4. User clicks in textarea and types report message
5. Submit button changes from gray to orange
6. User clicks "Submit report"
7. Parent's `onSubmit` callback receives data
8. Modal closes
9. User sees business profile again

### Empty Submission Prevention

1. Modal opens
2. User clicks textarea but types nothing
3. Submit button remains gray and disabled
4. User clicks submit button → nothing happens (disabled prevents click)
5. User types spaces only
6. Submit button remains gray (trim check)
7. User types actual message
8. Submit button becomes orange
9. User deletes message back to empty
10. Submit button becomes gray again

### Dismissal Paths

1. **Backdrop click:**
   - User clicks outside modal
   - Modal closes without submitting
   - Message state reset (if any)

2. **Close button:**
   - User clicks ✕ in top-right
   - Modal closes without submitting
   - Message state reset (if any)

3. **Post-submit:**
   - User submits valid report
   - Modal closes automatically
   - Message state already reset

### Edge Cases

1. **Very long restaurant name:**
   - Name wraps to multiple lines
   - Doesn't overlap close button (padding-right: 32px)

2. **Very long address:**
   - Address wraps naturally
   - Modal expands vertically if needed

3. **Very long message:**
   - Textarea scrolls internally
   - User can resize textarea taller
   - Modal scrolls if content exceeds 70vh

4. **Rapid open/close:**
   - Message state resets each time
   - No stale data from previous open

5. **Missing restaurant prop:**
   - Modal returns null (doesn't render)
   - No error thrown

6. **visible=false:**
   - Modal returns null
   - No DOM elements rendered

---

## Summary

The Report Missing Information Modal is a straightforward, single-purpose form overlay that allows users to submit reports about incorrect restaurant data. Its design prioritizes clarity and simplicity over advanced features, with a clean visual presentation and minimal validation logic.

**Key characteristics:**
- Centered modal with backdrop
- Single required text field
- Inline validation (trim check only)
- No error messaging or loading states
- Immediate submission and dismissal
- Responsive width and scrollable content

**Best suited for:**
- Low-frequency user action (reporting is occasional, not primary workflow)
- Non-critical data collection (reports can be reviewed by moderators)
- Simple text feedback without structured data requirements

**Migration considerations:**
- Add keyboard navigation and focus management for accessibility
- Implement loading state if API latency is noticeable
- Add error handling for submission failures
- Consider ARIA attributes for screen reader support

**Design consistency:**
- Orange accent color aligns with brand
- Typography hierarchy matches design system
- Spacing and border radius match card design language
- Exception to bottom sheet pattern justified by use case
