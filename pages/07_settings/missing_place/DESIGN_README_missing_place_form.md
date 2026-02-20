# Missing Place Form — JSX Design Documentation

**File:** `pages/settings/missing_place_form.jsx`
**Date:** 2026-02-19
**Status:** JSX Design Complete

---

## Design Overview

The Missing Place Form is a user-feedback interface that allows users to report restaurants or businesses that are not currently in the JourneyMate database. This form serves a critical role in crowdsourcing data quality and completeness, helping JourneyMate expand its restaurant coverage based on real user needs.

**Purpose:**
- Collect structured information about missing businesses from users
- Enable community-driven database expansion
- Demonstrate responsiveness to user feedback
- Gather actionable data for the JourneyMate team

**Core user journey:**
1. User searches for a restaurant but doesn't find it
2. User navigates to Settings → "Report a missing place"
3. User fills out name, address, and additional message
4. Form validates that all required fields are filled
5. User submits the report
6. Form resets for potential additional submissions

The form is designed to be straightforward and respectful of the user's time while gathering enough information to make the submission actionable for the team.

---

## Visual Layout

### Screen Structure

```
┌─────────────────────────────────────┐
│         Status Bar (54px)           │  System status
├─────────────────────────────────────┤
│  ← | Are we missing a place? | (60) │  Header bar
├─────────────────────────────────────┤
│                                     │
│  Missing a place?                   │  Heading (18pt, 680)
│                                     │
│  If we are missing a place...       │  Description text
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Name of the business *      │   │  Required field
│  │ [text input]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Address of the business *   │   │  Required field
│  │ In case other...            │   │  Helper text
│  │ [text input]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ Message *                   │   │  Required field
│  │ Message to the JourneyMate  │   │  Helper text
│  │ [textarea - multiline]      │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │        Submit               │   │  Action button
│  └─────────────────────────────┘   │
│                                     │
│  [scrollable content area]          │
└─────────────────────────────────────┘
```

### Layout Specifications

**Container:**
- Total canvas: 390 × 844px
- Background: white (#fff)
- Overflow: hidden

**Header bar:**
- Height: 60px
- Background: white
- Border-bottom: 1px solid #f2f2f2
- Padding: 0 20px
- Contains: back button (left), centered title

**Content area:**
- Height: 730px (844 - 54 status - 60 header)
- Padding: 24px all sides
- Overflow-y: scroll
- Contains all form elements

**Spacing hierarchy:**
- Heading to description: 12px gap
- Description to first field: 24px gap
- Between fields: 20px gap
- After message field: 24px gap to submit button
- Internal label to input: 8px gap (name field)
- Internal label to helper to input: 4px + 8px (address/message)

---

## Components Used

### Status Bar

```jsx
<StatusBar />
```

**Implementation:**
- Imported from `../../shared/_shared.jsx`
- Standard 54px height system status bar
- Consistent across all pages

### Header Bar

**Back Button:**
- Size: 36 × 36px
- Background: transparent
- Font-size: 18px
- Color: #0f0f0f
- Icon: ← (left arrow)
- Position: left-aligned in header
- Action: calls `onBack()` prop

**Title:**
- Text: "Are we missing a place?"
- Font-size: 16px
- Font-weight: 600
- Color: #0f0f0f
- Position: centered with -36px left margin to optically center (accounting for back button)

### Form Elements

#### Heading (h2)
```jsx
<h2>Missing a place?</h2>
```
- Font-size: 18px
- Font-weight: 680
- Color: #0f0f0f
- Margin-bottom: 12px

#### Description (p)
```jsx
<p>
  If we are missing a place, we will be very happy to hear from you.
  <br /><br />
  To make it easier for us to add it sooner, please provide as much
  information as you can.
</p>
```
- Font-size: 14px
- Font-weight: 400
- Color: #555
- Line-height: 20px
- Margin-bottom: 24px
- Contains line breaks for paragraph separation

#### Field Container
Each field is wrapped in a `<div>` with bottom margin (20px for text inputs, 24px for textarea).

#### Label Element
```jsx
<label>
  Name of the business <span style={{ color: "#c9403a" }}>*</span>
</label>
```
- Font-size: 14px
- Font-weight: 500
- Color: #0f0f0f
- Display: block
- Margin-bottom: 8px (or 4px when helper text follows)
- Required indicator: red asterisk (#c9403a)

#### Helper Text
Used for address and message fields:
```jsx
<div>In case other businesses share a similar name</div>
```
- Font-size: 12px
- Color: #888
- Margin-bottom: 8px (after label, before input)

#### Text Input
```jsx
<input
  type="text"
  value={name}
  onChange={(e) => setName(e.target.value)}
  placeholder="Enter business name"
  onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
  onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
/>
```
- Width: 100%
- Height: 50px
- Padding: 0 16px
- Font-size: 14px
- Color: #0f0f0f
- Background: #f5f5f5
- Border: 1px solid #e8e8e8
- Border-radius: 10px
- Transition: border-color 0.2s ease
- Focus state: border becomes ACCENT (#e8751a)
- Blur state: border returns to #e8e8e8

#### Textarea
```jsx
<textarea
  value={message}
  onChange={(e) => setMessage(e.target.value)}
  placeholder="Any additional details..."
  onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
  onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
/>
```
- Width: 100%
- Min-height: 120px
- Padding: 12px
- Font-size: 14px
- Color: #0f0f0f
- Background: #f5f5f5
- Border: 1px solid #e8e8e8
- Border-radius: 10px
- Resize: vertical
- Transition: border-color 0.2s ease
- Focus state: border becomes ACCENT
- Blur state: border returns to #e8e8e8

#### Submit Button
```jsx
<button
  onClick={handleSubmit}
  disabled={!isValid}
>
  Submit
</button>
```
- Width: 100%
- Height: 50px
- Background: ACCENT (#e8751a) when valid, #ddd when invalid
- Color: #fff
- Border: none
- Border-radius: 12px
- Font-size: 16px
- Font-weight: 600
- Cursor: pointer when valid, not-allowed when invalid
- Disabled state: grayed out (#ddd background)

---

## Design Tokens

### Colors

**From shared:**
- `ACCENT` = #e8751a (orange)
  - Used for: focused input borders, enabled submit button

**Local definitions:**
- White: #fff (background, button text)
- Black: #0f0f0f (text, heading, labels)
- Gray-50: #f5f5f5 (input background)
- Gray-200: #e8e8e8 (input border default)
- Gray-300: #ddd (disabled button background)
- Gray-400: #888 (helper text)
- Gray-500: #555 (description text)
- Gray-100: #f2f2f2 (header border)
- Red: #c9403a (required asterisk)

**Color usage rationale:**
- **Orange (ACCENT):** Used for interactive focus states and primary action (submit button), maintaining brand consistency
- **Red asterisk:** Standard web convention for required fields, high visibility
- **Gray backgrounds (#f5f5f5):** Distinguishes input areas from white page background
- **Gray borders (#e8e8e8):** Subtle definition without competing with content
- **Disabled gray (#ddd):** Clear visual feedback that action is not yet available

### Typography

**Font weights:**
- 400: body text (description)
- 500: labels
- 600: header title, submit button
- 680: page heading

**Font sizes:**
- 12px: helper text
- 14px: labels, input text, description
- 16px: header title, submit button
- 18px: page heading, back button icon

**Line heights:**
- 20px: description text (provides comfortable reading)
- Default: other elements use browser defaults

### Spacing

**Padding:**
- Header horizontal: 20px
- Content area: 24px all sides
- Input horizontal: 16px (text inputs), 12px (textarea)

**Margin:**
- Heading to description: 12px
- Description to first field: 24px
- Between input fields: 20px
- Message field to submit: 24px
- Label to input: 8px (without helper), 4px (with helper)
- Helper to input: 8px

**Heights:**
- Status bar: 54px
- Header bar: 60px
- Text inputs: 50px
- Textarea: min 120px (vertically resizable)
- Submit button: 50px

**Widths:**
- Container: 390px
- Back button: 36px
- All inputs: 100% of container

### Border Radius

- Text inputs: 10px (softer, more form-like)
- Submit button: 12px (slightly larger, more prominent)

---

## State & Data

### Local State Variables

```jsx
const [name, setName] = useState("");
const [address, setAddress] = useState("");
const [message, setMessage] = useState("");
```

**Purpose:**
- Each state variable corresponds to one required form field
- All fields start empty
- Updated on user input via onChange handlers
- Reset to empty strings after successful submission

### Computed Values

```jsx
const isValid = name.trim() && address.trim() && message.trim();
```

**Validation logic:**
- All three fields must contain non-whitespace content
- Trimming removes leading/trailing spaces before validation
- Simple boolean check, no regex or complex validation
- Drives button enabled/disabled state and visual appearance

### Props Interface

```jsx
function MissingPlaceForm({ onBack, onSubmit })
```

**onBack:**
- Type: function
- Purpose: navigate back to previous screen (likely settings page)
- Called when: back button clicked

**onSubmit:**
- Type: function
- Purpose: handle form submission with user data
- Called when: submit button clicked AND form is valid
- Receives: object with `{ name, address, message }`

---

## User Interactions

### 1. Navigation In

**Trigger:** User taps "Report a missing place" from Settings page

**Effect:** Missing Place Form page slides in with standard transition

**Entry state:** All fields empty, submit button disabled (gray)

### 2. Back Navigation

**Trigger:** User taps ← back button

**Action:**
```jsx
onClick={onBack}
```

**Effect:**
- Calls parent-provided `onBack()` function
- Typically navigates back to Settings page
- No confirmation dialog (form data is lost)

**Design note:** No unsaved changes warning is implemented. If this is a concern, parent component should handle it.

### 3. Text Input (Name, Address)

**Trigger:** User taps into text field

**Focus behavior:**
```jsx
onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
```
- Border color changes to orange (#e8751a)
- Transition: 0.2s ease

**Blur behavior:**
```jsx
onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
```
- Border color returns to light gray
- Transition: 0.2s ease

**Input behavior:**
```jsx
onChange={(e) => setName(e.target.value)}
```
- Updates corresponding state variable
- Re-evaluates `isValid` computed value
- May enable submit button if this completes all required fields

**Placeholder text:**
- Name: "Enter business name"
- Address: "Enter full address"
- Low-contrast, disappears on input

### 4. Textarea Input (Message)

**Behavior:** Same as text inputs with these differences:
- Multi-line input supported
- Min-height: 120px
- User can resize vertically (resize: vertical)
- Padding: 12px (instead of 0 16px) for better multi-line appearance
- Placeholder: "Any additional details..."

**Design note:** Vertical resize gives users control over how much space they need while maintaining a minimum usable height.

### 5. Submit Button State

**Disabled state (initially):**
- Condition: `!isValid` (any required field is empty or whitespace-only)
- Visual: gray background (#ddd)
- Cursor: not-allowed
- Click: no action (disabled attribute prevents)

**Enabled state:**
- Condition: `isValid` (all required fields have content)
- Visual: orange background (ACCENT)
- Cursor: pointer
- Click: calls `handleSubmit()`

**State transitions:**
- Updates reactively as user types in any field
- No explicit animation on enable/disable
- Clear visual feedback through color change

### 6. Form Submission

**Trigger:** User clicks submit button while form is valid

**Action:**
```jsx
const handleSubmit = () => {
  if (name.trim() && address.trim() && message.trim()) {
    onSubmit({ name, address, message });
    setName("");
    setAddress("");
    setMessage("");
  }
};
```

**Flow:**
1. Re-validates all fields (defensive check)
2. Calls parent-provided `onSubmit()` with data object
3. Clears all three form fields
4. Submit button returns to disabled state (form now empty)

**Parent responsibility:** The parent component (likely Settings page) is responsible for:
- Showing success/error feedback (toast, modal, etc.)
- API call to submit data
- Navigation away from form if appropriate

**Design note:** Form resets immediately after submission, allowing users to submit multiple missing places without re-navigating. This is intentional for power users who may want to report several missing businesses in one session.

### 7. Keyboard Interactions

**Enter key behavior:** Not explicitly handled (browser default)
- In text inputs: may trigger form submission (browser behavior)
- In textarea: creates new line (expected behavior)

**Tab navigation:** Standard HTML form order:
1. Back button
2. Name input
3. Address input
4. Message textarea
5. Submit button

---

## Design Rationale

### Form Structure Decisions

**1. Three required fields (name, address, message)**

**Rationale:** This is the minimum viable set for actionable submissions:
- **Name:** Essential identifier
- **Address:** Disambiguates businesses with similar names, provides location data
- **Message:** Captures additional context (hours, cuisine type, why user wants it added)

All fields are required to ensure submissions are useful to the team. Optional fields often result in incomplete data.

**2. Helper text on address and message fields**

**Rationale:**
- **Address helper:** "In case other businesses share a similar name" — educates users on why address is necessary, not just obvious
- **Message helper:** "Message to the JourneyMate-team" — clarifies audience and tone (users know a human will read this)

These appear between label and input, reducing visual noise while providing context when needed.

**3. No email or contact field**

**Rationale:** This is a feedback form, not a support request. Users shouldn't expect a response. If follow-up is needed, the team can add a contact field later or integrate with user accounts.

### Validation & Feedback

**1. Simple trim-based validation**

**Rationale:**
```jsx
const isValid = name.trim() && address.trim() && message.trim();
```
- Prevents empty or whitespace-only submissions
- No complex regex or format validation
- User can enter any format (street address, business name with numbers/symbols, etc.)
- Team can handle data normalization on backend

**2. Real-time button state updates**

**Rationale:**
- Submit button is disabled until all fields are filled
- No "click to see errors" anti-pattern
- Users get immediate feedback that form is incomplete
- Reduces frustration of attempted submission failures

**3. No inline error messages**

**Rationale:**
- Current validation is binary (field empty or not)
- Button state clearly indicates when form is submittable
- Red asterisks indicate required fields upfront
- No need for "This field is required" messages

**4. Orange focus states**

**Rationale:**
- Brand color (ACCENT) used for interactive states
- High contrast against gray borders
- Smooth 0.2s transition prevents jarring changes
- Clearly indicates active input

### Visual Hierarchy

**1. Centered header title with optical centering**

**Rationale:**
```jsx
marginLeft: -36
```
- Back button is 36px wide on left side
- Without compensation, title would be off-center
- -36px margin creates true visual center
- Maintains symmetry in header bar

**2. Large, conversational heading**

**Rationale:**
- "Missing a place?" (18px, 680 weight) is friendly and direct
- Mirrors header title but more casual
- Sets conversational tone for user feedback

**3. Descriptive text before fields**

**Rationale:**
- Two-paragraph description sets context and expectations
- "we will be very happy to hear from you" — appreciative tone
- "as much information as you can" — encourages detail without demanding it
- Positioned before fields so users understand purpose before engaging

**4. Consistent input styling**

**Rationale:**
- All inputs use same background (#f5f5f5), border (#e8e8e8), radius (10px)
- Textarea matches text inputs for visual consistency
- Users quickly understand "this is fillable"

### Interaction Patterns

**1. Form resets after submission**

**Rationale:**
- Allows multiple submissions in one session
- Users may want to report several missing places
- No navigation required between submissions
- Parent handles feedback (success toast, etc.)

**2. No confirmation on back navigation**

**Rationale:**
- Form is quick to fill (three fields)
- No "are you sure you want to leave?" interruption
- Users who accidentally navigate back can easily return
- Reduces friction for casual browsing

**3. Disabled button instead of error messages**

**Rationale:**
- Simpler mental model: "fill everything, then submit"
- No negative feedback (error messages)
- Required asterisks set expectations upfront
- Button color change is positive affordance

### Accessibility Considerations

**1. Semantic HTML elements**

**Implementation:**
- `<label>` elements for input labels
- `<input>` and `<textarea>` for form fields
- `<button>` for actions
- Proper label-to-input association (though explicit `htmlFor` could be added)

**Rationale:** Screen readers can correctly interpret form structure and read labels.

**2. Color-independent state indicators**

**Implementation:**
- Disabled button has cursor: not-allowed
- `disabled` attribute prevents interaction
- Focus states use border changes (not just color)

**Rationale:** Users with color blindness can still understand form state through cursor changes and disabled attribute.

**3. Clear required field indicators**

**Implementation:**
- Red asterisk (*) on all three field labels
- Consistent placement (after label text)
- High contrast (#c9403a)

**Rationale:** Universally understood convention for required fields.

**Areas for improvement (not implemented):**
- Explicit `htmlFor` attributes on labels
- `aria-required` attributes on inputs
- `aria-describedby` linking helper text to inputs
- Focus trap for keyboard navigation
- Visible focus outline (currently browser default)

### Typography Decisions

**1. Font weight 680 for heading**

**Rationale:**
- Slightly bolder than 600 (header title) but not as heavy as 700
- Creates clear hierarchy: heading > header > labels
- Maintains brand's preference for nuanced weights

**2. Gray tones for secondary text**

**Rationale:**
- #555 for description (dark enough to read, lighter than body)
- #888 for helper text (clearly secondary)
- Creates three-tier hierarchy: primary (#0f0f0f), secondary (#555), tertiary (#888)

**3. Consistent 14px input text**

**Rationale:**
- Matches label size for visual continuity
- Comfortable reading size on mobile
- Input text doesn't feel cramped or oversized

### Spacing Decisions

**1. 24px padding around content area**

**Rationale:**
- Generous whitespace prevents cramped feeling
- Consistent with other settings pages
- Maintains readability on various screen sizes

**2. 20px gaps between fields**

**Rationale:**
- Clearly separates fields without excessive space
- Allows comfortable scrolling
- Forms a visual rhythm with 24px section gaps

**3. 50px input height**

**Rationale:**
- Large enough for comfortable tapping on mobile
- Matches button height for consistency
- Accommodates 14px text with padding

### Button Design Decisions

**1. Full-width submit button**

**Rationale:**
- Large tap target for mobile
- Primary action is unmissable
- Common pattern in mobile forms

**2. Orange (ACCENT) for enabled, gray for disabled**

**Rationale:**
- Orange = interactive brand color
- Clear contrast between states
- Disabled gray (#ddd) is obviously non-interactive

**3. Bottom placement with 24px top margin**

**Rationale:**
- Natural reading order (fields → button)
- Space prevents accidental taps
- Thumb-reachable on most devices

### Edge Cases & Considerations

**1. Whitespace-only input**

**Handling:** `name.trim()` validation prevents submission of whitespace
**Design note:** No explicit error message, button remains disabled

**2. Very long text**

**Handling:**
- Text inputs scroll horizontally (browser default)
- Textarea is vertically resizable
- No character limit implemented

**Design note:** Backend should handle long submissions, UI doesn't constrain

**3. Rapid back navigation after submit**

**Handling:**
- Parent's `onSubmit()` is responsible for API call
- If user navigates back before API completes, parent must handle
- Form itself has no loading state

**Design note:** Consider adding loading state in future if API is slow

**4. Multiple submissions**

**Handling:** Form resets after each submission, allowing immediate reuse
**Design note:** No "already submitted" state or throttling

**5. Navigation away with filled fields**

**Handling:** Data is lost, no warning
**Design note:** Intentionally simple; could add confirmation dialog in parent if needed

### Layout Considerations

**1. Fixed 390 × 844 canvas**

**Rationale:**
- iPhone 12/13/14 Pro dimensions
- Design spec, not production implementation
- Real Flutter build would use responsive layout

**2. Scrollable content area**

**Rationale:**
- Form may not fit on smaller screens
- Allows for future expansion (more fields)
- Header and status bar remain fixed

**3. No bottom padding on content area**

**Rationale:**
- Submit button provides visual bottom boundary
- Padding is on container itself (24px)

---

## Visual States Summary

### Form States

**1. Initial/Empty State**
- All fields empty
- Submit button gray and disabled
- No validation messages
- Cursor: not-allowed on button

**2. Partially Filled State**
- One or two fields have content
- Submit button still gray and disabled
- No error indication
- Active field shows orange focus border

**3. Valid/Ready State**
- All three fields have content
- Submit button orange and enabled
- Cursor: pointer on button
- Active field shows orange focus border

**4. Post-Submission State**
- All fields cleared (back to empty)
- Submit button gray and disabled
- No success message (parent's responsibility)
- User can immediately start new submission

### Field States

**1. Default (unfocused, empty)**
- Background: #f5f5f5
- Border: 1px solid #e8e8e8
- Placeholder visible

**2. Focused (empty)**
- Background: #f5f5f5
- Border: 1px solid ACCENT (#e8751a)
- Placeholder visible
- Transition: 0.2s ease

**3. Focused (with content)**
- Background: #f5f5f5
- Border: 1px solid ACCENT
- Text visible, no placeholder

**4. Unfocused (with content)**
- Background: #f5f5f5
- Border: 1px solid #e8e8e8
- Text visible, no placeholder
- Transition: 0.2s ease

---

## Component API

### Props

```typescript
interface MissingPlaceFormProps {
  onBack: () => void;
  onSubmit: (data: { name: string; address: string; message: string }) => void;
}
```

**onBack:**
- Required: yes
- Called when: back button clicked
- No parameters
- Typically navigates to Settings page

**onSubmit:**
- Required: yes
- Called when: submit button clicked AND all fields are filled
- Parameters: object with trimmed field values
- Typically triggers API call and shows success feedback

### Data Returned

```typescript
{
  name: string;      // User-entered business name (trimmed)
  address: string;   // User-entered address (trimmed)
  message: string;   // User-entered message (trimmed)
}
```

### Integration Example

```jsx
<MissingPlaceForm
  onBack={() => navigation.goBack()}
  onSubmit={(data) => {
    // Send to API
    submitMissingPlace(data);
    // Show success feedback
    showToast("Thank you! We'll review your submission.");
    // Optionally navigate away
    navigation.goBack();
  }}
/>
```

---

## Design Tokens Reference

```jsx
// Imported
ACCENT = "#e8751a"

// Local colors
"#fff"      // white background
"#0f0f0f"   // primary text, headings, labels
"#555"      // description text
"#888"      // helper text
"#f5f5f5"   // input background
"#e8e8e8"   // input border default
"#ddd"      // disabled button
"#f2f2f2"   // header border
"#c9403a"   // required asterisk

// Spacing
24px   // content padding, section gaps
20px   // field gaps
12px   // heading to description
8px    // label to input
4px    // label to helper

// Typography
18px/680   // heading
16px/600   // header title, button
14px/500   // labels
14px/400   // input text, description
12px       // helper text

// Dimensions
390 × 844    // canvas
54px         // status bar
60px         // header bar
50px         // inputs, button
120px        // textarea min-height
36px         // back button

// Border radius
10px   // inputs
12px   // button

// Transitions
0.2s ease   // border color on focus/blur
```

---

## Future Considerations

### Not Implemented (By Design)

**1. Success/error feedback**
- Currently parent's responsibility
- Could add inline success message after submission
- Could add error handling for API failures

**2. Field-level validation**
- No email format checks
- No address format checks
- No character limits
- Intentionally permissive to avoid false negatives

**3. Loading state**
- No spinner during submission
- No disabled state during API call
- Parent should handle if needed

**4. Confirmation dialog on back**
- No "unsaved changes" warning
- Intentionally frictionless
- Could add if user testing reveals need

**5. Contact information field**
- No email or phone number requested
- One-way feedback only
- Could add if team needs follow-up capability

### Potential Enhancements

**1. Photo upload**
- Allow users to attach business photos
- Would help team verify submissions
- Requires API support

**2. Category suggestion**
- Dropdown for business type (restaurant, cafe, bar, etc.)
- Pre-structured data for team
- Must not be required (users may not know)

**3. Duplicate prevention**
- Check if place already submitted
- Prevent redundant reports
- Requires database lookup

**4. Estimated response time**
- Set expectations for review time
- "We typically review submissions within 5 business days"
- Reduces support inquiries

**5. Submission history**
- Show user's previous submissions
- Status tracking (pending, added, rejected)
- Requires user account integration

**6. Auto-fill from clipboard**
- Detect address in clipboard
- Offer to paste into address field
- Convenience feature for power users

---

## Design System Compliance

### Colors
- Uses ACCENT (#e8751a) for interactive elements
- Uses #0f0f0f for primary text
- Uses gray scale for hierarchy
- Does NOT use green (correctly - not a match indicator)

### Typography
- Font weights follow design system (400, 500, 600, 680)
- Font sizes are within system scale (12-18px range)
- Line height specified for body text (20px)

### Spacing
- Uses 24px for major sections
- Uses 20px for related elements
- Uses 8/12px for micro-spacing
- Consistent with design system rhythm

### Border Radius
- 10px for inputs (standard for form elements)
- 12px for buttons (standard for primary actions)

### Interaction Patterns
- Orange for interactive states (focus, primary action)
- Smooth transitions (0.2s ease)
- Clear enabled/disabled states
- Consistent with system patterns

---

## Responsive Behavior

**Current implementation:** Fixed 390px width (design spec)

**Flutter implementation considerations:**
- Use `MediaQuery.of(context).size.width` for width
- Maintain padding percentages
- Keep button full-width
- Consider tablet layouts (side-by-side labels/inputs)

---

## Testing Considerations

### Manual Testing Checklist

**Navigation:**
- [ ] Back button navigates to Settings
- [ ] Entering page shows empty form

**Input validation:**
- [ ] Submit disabled when all fields empty
- [ ] Submit disabled when any field empty
- [ ] Submit disabled when fields contain only whitespace
- [ ] Submit enabled when all fields have content

**Focus states:**
- [ ] Input border turns orange on focus
- [ ] Input border returns to gray on blur
- [ ] Transition is smooth (0.2s)

**Submission:**
- [ ] Submit calls onSubmit with correct data
- [ ] Fields reset to empty after submission
- [ ] Submit button disables after submission

**Edge cases:**
- [ ] Very long input (100+ characters) in text fields
- [ ] Very long input (500+ characters) in textarea
- [ ] Special characters in inputs (emoji, symbols)
- [ ] Whitespace-only input (should not validate)
- [ ] Rapid submit clicks (should call once)

### Accessibility Testing

- [ ] Screen reader reads labels correctly
- [ ] Tab navigation flows logically
- [ ] Disabled button announces as disabled
- [ ] Required fields announced as required

---

## Conclusion

The Missing Place Form is a straightforward, user-friendly interface for collecting business submissions. Its design prioritizes:

1. **Simplicity:** Three required fields, clear validation, obvious action
2. **Clarity:** Helper text, required indicators, conversational tone
3. **Efficiency:** Real-time validation, immediate reset for multiple submissions
4. **Consistency:** Matches design system colors, spacing, and patterns
5. **Accessibility:** Semantic HTML, clear states, keyboard-friendly

The form balances minimal user effort (quick to fill) with maximum utility (all necessary data collected). By resetting after submission, it supports power users who may report multiple missing places. By keeping validation simple, it avoids false negatives and respects diverse input formats.

**Lines:** 577
