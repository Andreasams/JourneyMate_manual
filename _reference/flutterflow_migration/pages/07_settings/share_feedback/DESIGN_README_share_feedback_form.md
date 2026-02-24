# Share Feedback Form — JSX Design Documentation

**Component:** `ShareFeedbackForm`
**File Path:** `pages/settings/share_feedback_form.jsx`
**Design Version:** v2 (JSX implementation)
**Last Updated:** 2026-02-19

---

## Design Overview

The Share Feedback Form is a full-screen modal form that allows users to submit feedback about the JourneyMate app. The form follows a structured approach with category selection, detailed message input, and optional contact information. The design prioritizes clarity and ease of use while collecting actionable feedback from users.

### Purpose

- Collect structured feedback from users about the app
- Categorize feedback for easier processing and routing
- Allow users to optionally provide contact information for follow-up
- Validate required fields before submission
- Reset form state after successful submission

### Key Design Characteristics

- **Single-page form layout** - All fields visible without pagination
- **Progressive disclosure** - Contact fields appear only when checkbox is checked
- **Category-based categorization** - Seven predefined categories for feedback type
- **Required field indicators** - Red asterisks mark mandatory fields
- **Disabled state management** - Submit button disabled until required fields complete
- **Inline validation** - Focus states provide visual feedback during input

### User Flow

1. User navigates to feedback form from settings menu
2. User selects a feedback category (required)
3. User enters detailed feedback message (required)
4. User optionally checks "May we contact you?" checkbox
5. If checked, user provides name and contact information (optional)
6. User taps "Send feedback" button (enabled only when category + message filled)
7. Form submits feedback data via `onSubmit` callback
8. Form resets to blank state after successful submission

---

## Visual Layout

### Screen Structure

```
┌─────────────────────────────────────┐
│ ← [Title: Share feedback]           │ Header (60px)
├─────────────────────────────────────┤
│                                     │
│ Share your feedback                 │ Heading (18px, 680 weight)
│ Your input helps us improve...      │ Description (14px, 400 weight)
│                                     │
│ What is your feedback about? *      │ Label (14px, 500 weight)
│ Pick the one that fits best.        │ Helper text (12px, 888)
│ [Wrong info] [Ideas] [Bug]          │ Category chips (wrapping)
│ [Missing place] [Suggestion]        │
│ [Praise] [Something else]           │
│                                     │
│ Tell us more *                       │ Label (14px, 500 weight)
│ Please describe your feedback...    │ Helper text (12px, 888)
│ ┌───────────────────────────────┐  │ Textarea (120px min height)
│ │ Share your thoughts,          │  │
│ │ suggestions, or concerns...   │  │
│ │                               │  │
│ └───────────────────────────────┘  │
│                                     │
│ ☐ May we contact you?               │ Checkbox with label
│   If you would like us to...        │ Helper text
│                                     │
│ [Conditional contact fields]         │ Shown when checkbox checked
│                                     │
│ ┌───────────────────────────────┐  │
│ │     Send feedback             │  │ Submit button (50px)
│ └───────────────────────────────┘  │
│                                     │ Scrollable content area
└─────────────────────────────────────┘
```

### Layout Specifications

| Element | Dimensions | Position |
|---------|-----------|----------|
| Screen canvas | 390×844px | Fixed viewport |
| Status bar | Full width × system height | Top |
| Header | 390×60px | Below status bar |
| Content area | 390×730px | Scrollable container |
| Content padding | 24px all sides | Inner spacing |
| Back button | 36×36px | Left-aligned in header |
| Title | Centered | Header center (with -36px offset) |
| Category chips | Variable width | Wrapping flex container |
| Textarea | Full width × 120px min | Resizable vertically |
| Submit button | Full width × 50px | Bottom of form |

### Spacing System

- **Section margins:** 24px between major sections
- **Field margins:** 20-24px between form fields
- **Label spacing:** 4-8px between label and input
- **Helper text:** 8-12px between label and input field
- **Chip gap:** 8px between category chips
- **Checkbox gap:** 12px between checkbox and label text
- **Content padding:** 24px horizontal and vertical

---

## Components Used

### Header Component

**Purpose:** Navigation and page identification

**Structure:**
- Back button (←) on the left
- Centered title "Share feedback"
- Bottom border separator

**Specifications:**
- Height: 60px
- Background: White (#fff)
- Border bottom: 1px solid #f2f2f2
- Padding: 0 20px horizontal

**Back Button:**
- Size: 36×36px
- Border: None
- Background: Transparent
- Font size: 18px
- Color: #0f0f0f
- Interaction: Calls `onBack()` prop

**Title Text:**
- Font size: 16px
- Font weight: 600
- Color: #0f0f0f
- Alignment: Center (with -36px margin-left to compensate for back button)

### Heading Section

**Purpose:** Introduce the form and explain its purpose

**Structure:**
- Main heading: "Share your feedback"
- Description paragraph: "Your input helps us improve the app and make it better for everyone."

**Specifications:**

Heading:
- Font size: 18px
- Font weight: 680
- Color: #0f0f0f
- Margin bottom: 8px

Description:
- Font size: 14px
- Font weight: 400
- Color: #555
- Line height: 20px
- Margin bottom: 24px

### Category Selection

**Purpose:** Allow users to categorize their feedback type

**Structure:**
- Label: "What is your feedback about?" with red asterisk
- Helper text: "Pick the one that fits best."
- Seven category chips in wrapping layout

**Category Options:**
1. Wrong information
2. Ideas for the app
3. Bug
4. Missing a place
5. Suggestion
6. Praise
7. Something else

**Chip Specifications:**

Unselected state:
- Background: White (#fff)
- Border: 1px solid #e8e8e8
- Color: #555
- Padding: 8px 14px
- Border radius: 10px
- Font size: 13px
- Font weight: 540

Selected state:
- Background: ACCENT (#e8751a)
- Border: 1px solid ACCENT
- Color: White (#fff)

Hover state (unselected only):
- Background: #f9f9f9
- Transition: background 0.2s ease

**Interaction:**
- Single selection only
- Click to select category
- Selected chip remains highlighted
- Clicking another chip deselects previous

### Message Textarea

**Purpose:** Collect detailed feedback from user

**Structure:**
- Label: "Tell us more" with red asterisk
- Helper text: "Please describe your feedback in detail. The more information you provide, the better we can help."
- Multi-line textarea field

**Specifications:**
- Width: 100%
- Min height: 120px
- Padding: 12px
- Font size: 14px
- Color: #0f0f0f
- Background: #f5f5f5
- Border: 1px solid #e8e8e8
- Border radius: 10px
- Resize: Vertical only
- Placeholder: "Share your thoughts, suggestions, or concerns..."

**Focus State:**
- Border color: ACCENT (#e8751a)
- Transition: border-color 0.2s ease

**Blur State:**
- Border color: #e8e8e8

### Contact Permission Checkbox

**Purpose:** Allow users to opt in to follow-up contact

**Structure:**
- Checkbox input (18×18px)
- Label heading: "May we contact you?"
- Helper text: "If you would like us to follow up with you, please tick this box and provide your details below."

**Specifications:**

Checkbox:
- Size: 18×18px
- Margin top: 2px (for alignment)
- Cursor: pointer

Label container:
- Display: Flex
- Align items: Flex-start
- Gap: 12px
- Cursor: pointer

Label heading:
- Font size: 14px
- Font weight: 500
- Color: #0f0f0f
- Margin bottom: 4px

Helper text:
- Font size: 12px
- Color: #888
- Line height: 16px

**Interaction:**
- Checkbox toggles `allowContact` state
- When checked, reveals name and contact fields below
- When unchecked, hides conditional fields

### Conditional Contact Fields

**Purpose:** Collect user contact information for follow-up

**Visibility:** Only shown when `allowContact` is `true`

**Structure:**
1. Name field (optional)
2. Contact information field (optional)

#### Name Field

**Label:** "Your name"

**Specifications:**
- Width: 100%
- Height: 50px
- Padding: 0 16px
- Font size: 14px
- Color: #0f0f0f
- Background: #f5f5f5
- Border: 1px solid #e8e8e8
- Border radius: 10px
- Placeholder: "Enter your name"
- Margin bottom: 20px

**Focus State:**
- Border color: ACCENT (#e8751a)
- Transition: border-color 0.2s ease

#### Contact Information Field

**Label:** "Contact information"

**Helper text:** "Please provide an email address or phone number so we can reach you."

**Specifications:**
- Width: 100%
- Height: 50px
- Padding: 0 16px
- Font size: 14px
- Color: #0f0f0f
- Background: #f5f5f5
- Border: 1px solid #e8e8e8
- Border radius: 10px
- Placeholder: "Email or phone number"
- Margin bottom: 24px

**Focus State:**
- Border color: ACCENT (#e8751a)
- Transition: border-color 0.2s ease

**Field Characteristics:**
- No specific format validation in design (accepts any text)
- Helper text suggests email or phone, but no enforcement
- Both fields are optional (no asterisk)

### Submit Button

**Purpose:** Submit feedback form data

**Text:** "Send feedback"

**Specifications:**

Enabled state:
- Width: 100%
- Height: 50px
- Background: ACCENT (#e8751a)
- Color: White (#fff)
- Border: None
- Border radius: 12px
- Font size: 16px
- Font weight: 600
- Cursor: pointer

Disabled state:
- Background: #ddd
- Cursor: not-allowed
- All other properties same as enabled

**Interaction:**
- Button disabled when `!isValid` (category missing or message empty)
- Clicking enabled button calls `handleSubmit()`
- No loading state shown in design

---

## Design Tokens

### Colors

| Token | Value | Usage |
|-------|-------|-------|
| ACCENT | #e8751a | Category chip selection, focus borders, enabled button |
| Text primary | #0f0f0f | Headings, labels, input text |
| Text secondary | #555 | Description, unselected chip text |
| Text tertiary | #888 | Helper text, placeholder guidance |
| Required indicator | #c9403a | Asterisk for required fields |
| Background primary | #fff | Screen background, unselected chips |
| Background secondary | #f5f5f5 | Input fields, textarea |
| Border default | #e8e8e8 | Input borders, chip borders |
| Border separator | #f2f2f2 | Header bottom border |
| Disabled background | #ddd | Disabled button background |
| Hover background | #f9f9f9 | Unselected chip hover |

### Typography

| Element | Font Size | Font Weight | Line Height | Color |
|---------|-----------|-------------|-------------|-------|
| Page title | 16px | 600 | Default | #0f0f0f |
| Section heading | 18px | 680 | Default | #0f0f0f |
| Description | 14px | 400 | 20px | #555 |
| Field label | 14px | 500 | Default | #0f0f0f |
| Helper text | 12px | 400 | 16px | #888 |
| Category chip | 13px | 540 | Default | #555 / #fff (selected) |
| Input text | 14px | 400 | Default | #0f0f0f |
| Button text | 16px | 600 | Default | #fff |

### Spacing

| Element | Value |
|---------|-------|
| Screen padding | 24px |
| Section spacing | 24px |
| Field spacing | 20-24px |
| Label-to-input | 4-8px |
| Label-to-helper | 4px |
| Helper-to-input | 8-12px |
| Chip gap | 8px |
| Checkbox-to-label | 12px |

### Border Radius

| Element | Value |
|---------|-------|
| Category chips | 10px |
| Input fields | 10px |
| Textarea | 10px |
| Submit button | 12px |

### Dimensions

| Element | Value |
|---------|-------|
| Back button | 36×36px |
| Header height | 60px |
| Content area | 390×730px |
| Input height | 50px |
| Textarea min height | 120px |
| Button height | 50px |
| Checkbox size | 18×18px |

---

## State & Data

### Component Props

```javascript
{
  onBack: function,      // Callback for back button navigation
  onSubmit: function     // Callback for form submission, receives feedback object
}
```

### Local State Variables

```javascript
const [category, setCategory] = useState(null);
// Purpose: Selected feedback category
// Type: String or null
// Initial value: null
// Options: "Wrong information" | "Ideas for the app" | "Bug" |
//          "Missing a place" | "Suggestion" | "Praise" | "Something else"

const [message, setMessage] = useState("");
// Purpose: User's detailed feedback message
// Type: String
// Initial value: ""
// Validation: Required, must have non-empty trimmed value

const [allowContact, setAllowContact] = useState(false);
// Purpose: Whether user permits follow-up contact
// Type: Boolean
// Initial value: false
// Effect: Shows/hides name and contact fields

const [name, setName] = useState("");
// Purpose: User's name for contact purposes
// Type: String
// Initial value: ""
// Visibility: Only when allowContact is true
// Validation: None (optional field)

const [contact, setContact] = useState("");
// Purpose: User's email or phone number
// Type: String
// Initial value: ""
// Visibility: Only when allowContact is true
// Validation: None (accepts any text)
```

### Computed Values

```javascript
const isValid = category && message.trim();
// Purpose: Determines if form can be submitted
// Type: Boolean
// Logic: True when category selected AND message non-empty
// Effect: Enables/disables submit button
```

### Category Data

```javascript
const categories = [
  "Wrong information",    // Data accuracy issues
  "Ideas for the app",    // Feature suggestions
  "Bug",                  // Technical problems
  "Missing a place",      // Restaurant/venue not in database
  "Suggestion",           // General improvements
  "Praise",               // Positive feedback
  "Something else",       // Catch-all category
];
```

**Design Notes:**
- Seven predefined categories cover most feedback scenarios
- "Something else" provides catch-all for edge cases
- Categories are user-friendly, non-technical language
- Order likely reflects priority/frequency of feedback types

### Form Data Structure

When submitted, the form constructs this data object:

```javascript
{
  category: String,         // Required: selected category
  message: String,          // Required: trimmed message text
  name: String,            // Optional: only if allowContact is true
  contact: String          // Optional: only if allowContact is true
}
```

**Data Flow:**
1. User fills form fields (updates state)
2. User clicks "Send feedback" (triggers `handleSubmit`)
3. Validation check: `category && message.trim()`
4. If valid, construct feedback object
5. Call `onSubmit(feedback)` prop with data
6. Reset all state to initial values
7. Form ready for next submission

---

## User Interactions

### Navigation

**Back Button:**
- **Trigger:** Click/tap back arrow (←) in header
- **Action:** Calls `onBack()` prop function
- **Effect:** Expected to navigate to previous screen (settings menu)
- **Behavior:** No form validation or save prompt
- **Data Loss:** Form data not preserved if user navigates away

### Category Selection

**Initial State:**
- All chips rendered in neutral state
- No category pre-selected
- `category` state is `null`

**Selection Flow:**
1. User taps any category chip
2. `setCategory(cat)` updates state
3. Selected chip changes to ACCENT background
4. Selected chip text changes to white
5. Previous selection (if any) returns to neutral

**Visual Feedback:**
- Selected chip: Orange background, white text, orange border
- Unselected chips: White background, gray text, gray border
- Hover (unselected only): Light gray background (#f9f9f9)

**Behavior Notes:**
- Single selection only (not multi-select)
- No deselection mechanism (once selected, a category must remain chosen)
- To change category, click different chip

### Message Input

**Textarea Interaction:**
- Click to focus
- Focus shows orange border (ACCENT)
- Type to enter feedback
- Textarea expands vertically if content exceeds 120px
- Blur returns border to gray

**Placeholder:**
- "Share your thoughts, suggestions, or concerns..."
- Disappears when user begins typing

**Validation:**
- No character limit enforced
- No real-time validation shown
- Validation occurs on submit attempt

### Contact Permission

**Checkbox Interaction:**
1. User clicks checkbox or label area
2. `setAllowContact(e.target.checked)` toggles state
3. If checked, name and contact fields appear below
4. If unchecked, conditional fields disappear
5. Field values preserved in state even when hidden

**Label Clickability:**
- Entire label area is clickable
- Checkbox itself is clickable
- Both trigger the same state update

**Conditional Field Behavior:**
- Fields shown/hidden based on `allowContact` boolean
- No animation or transition on appear/disappear
- Fields maintain values if user unchecks then rechecks
- React conditional rendering: `{allowContact && (<>...</>)}`

### Contact Fields (Conditional)

**Name Field:**
- Standard text input
- Focus shows orange border
- No validation or format requirements
- Optional field (no asterisk)

**Contact Information Field:**
- Standard text input
- Focus shows orange border
- Accepts any text (email, phone, or other)
- No format validation in design
- Optional field (no asterisk)

**Helper Text:**
- Suggests "email address or phone number"
- No enforcement of format

### Form Submission

**Submit Button States:**

Disabled:
- Shown when `!isValid` (category missing OR message empty)
- Gray background (#ddd)
- "not-allowed" cursor
- Click has no effect

Enabled:
- Shown when `isValid` is true
- Orange background (ACCENT)
- "pointer" cursor
- Click triggers `handleSubmit()`

**Submission Flow:**

1. User clicks enabled "Send feedback" button
2. `handleSubmit()` function executes
3. Validation check: `if (category && message.trim())`
4. Construct feedback object:
   ```javascript
   {
     category: "Bug",
     message: "The search doesn't work properly",
     ...(allowContact && { name: "Anna", contact: "anna@example.com" })
   }
   ```
5. Call `onSubmit(feedback)` with data
6. Reset all form state:
   - `setCategory(null)`
   - `setMessage("")`
   - `setAllowContact(false)`
   - `setName("")`
   - `setContact("")`
7. Form returns to empty state

**No Success/Error Feedback:**
- Design does not show success message
- No error states shown in JSX
- Assumes `onSubmit` handles success/error responses
- Parent component responsible for navigation or feedback

### Focus States

**Input Fields:**
- Textarea: Border changes to ACCENT on focus
- Name field: Border changes to ACCENT on focus
- Contact field: Border changes to ACCENT on focus
- All transitions: 0.2s ease

**Keyboard Navigation:**
- No explicit tab order shown in design
- Standard HTML input focus order expected

### Hover States

**Category Chips:**
- Unselected chips show #f9f9f9 background on hover
- Selected chip has no hover state change
- Transition: background 0.2s ease

**Buttons:**
- Back button: No hover state shown
- Submit button: No hover state shown in design

---

## Design Rationale

### Form Structure Decisions

**Single-Page Layout:**
- All fields visible without scrolling/pagination
- User can see entire form scope before filling
- Reduces cognitive load and abandonment
- Typical mobile form best practice

**Category-First Approach:**
- Category selection placed before message field
- Forces user to categorize before writing
- Helps user frame their feedback appropriately
- Enables backend routing and prioritization

**Progressive Disclosure:**
- Contact fields hidden by default
- Reduces form intimidation factor
- Only shown when user explicitly opts in
- Prevents unnecessary data collection

### Validation Strategy

**Required Field Indicators:**
- Red asterisk (*) marks category and message as required
- Color: #c9403a (distinct from ACCENT orange)
- Standard form convention for required fields
- Contact fields intentionally have no asterisk

**Submit Button Disablement:**
- Button disabled until minimum valid data entered
- Prevents error states and failed submissions
- Visual feedback (gray) signals incomplete form
- Enables instantly when requirements met

**No Inline Validation:**
- No character counters shown
- No format validation on contact field
- No error messages for empty fields
- Simplifies UI, relies on button state for guidance

### Category Design

**Seven Categories:**
- Comprehensive coverage of feedback types
- User-friendly, non-technical language
- "Something else" catch-all prevents user frustration
- Specific categories enable better triage

**Category Order:**
- "Wrong information" first (likely common, actionable)
- "Ideas for the app" second (encourages feature requests)
- "Bug" third (critical technical feedback)
- "Missing a place" fourth (specific to restaurant app)
- "Suggestion" fifth (general improvements)
- "Praise" sixth (positive feedback)
- "Something else" last (catch-all)

**Single Selection:**
- Forces user to choose primary feedback type
- Simplifies backend processing
- User can always submit multiple forms if needed

### Contact Fields Design

**Opt-In Approach:**
- Default to anonymous feedback
- Respects user privacy
- Reduces friction for quick feedback
- Contact only when user wants follow-up

**Flexible Contact Field:**
- Single field accepts email OR phone
- No format validation required
- Reduces field count (less intimidating)
- Text says "email address or phone number" but accepts anything

**Optional Contact Fields:**
- Name and contact both optional even when checkbox checked
- User can check box but leave fields blank
- Maximizes feedback submission (don't block on contact info)

### Visual Design Choices

**Orange (ACCENT) for Interactive Elements:**
- Selected category chips
- Focus borders on inputs
- Submit button enabled state
- Consistent with JourneyMate brand
- High contrast against white/gray backgrounds

**Gray (#ddd) for Disabled State:**
- Clear visual indicator of unavailable action
- Sufficient contrast against white background
- Standard disabled button appearance

**Background Differentiation:**
- White screen background
- Light gray (#f5f5f5) input backgrounds
- Provides subtle depth
- Distinguishes interactive areas

**Rounded Corners:**
- 10px for chips and inputs
- 12px for submit button (slightly more prominent)
- Modern, friendly appearance
- Consistent with app design system

### Accessibility Considerations

**Label-Input Associations:**
- Clear labels above each input
- Helper text provides context
- Placeholder text offers examples

**Color Contrast:**
- #0f0f0f text on white background (high contrast)
- #555 secondary text sufficient for readability
- ACCENT orange meets WCAG AA standards

**Button States:**
- Cursor changes indicate interactivity
- Disabled state visually distinct
- Button large enough for easy tapping (50px height)

**Focus Indicators:**
- Orange border on focused inputs
- Clear visual feedback for keyboard navigation

### User Experience Decisions

**Immediate Field Reset:**
- Form resets to blank after submission
- Allows quick multiple submissions
- No lingering data confuses state
- User can submit multiple feedback items in session

**No Save Draft:**
- No mechanism to save incomplete form
- Encourages completion in single session
- Reduces complexity

**No Character Limits:**
- Textarea can expand indefinitely
- No arbitrary restriction on feedback length
- Encourages detailed feedback

**No Confirmation Dialog:**
- Submit happens immediately
- Assumes `onSubmit` provides feedback
- Reduces steps for user

### Data Collection Strategy

**Minimal Required Data:**
- Only category and message required
- Maximizes submission rate
- Reduces abandonment

**Structured Category Data:**
- Predefined categories enable analytics
- Backend can route/prioritize automatically
- Easier to aggregate feedback trends

**Flexible Contact Method:**
- Single text field reduces friction
- User chooses communication preference
- Backend can parse/validate as needed

### Mobile-First Design

**Touch Target Sizes:**
- Category chips: 8px padding vertical, 14px horizontal (sufficient)
- Buttons: 50px height (easily tappable)
- Checkbox: 18×18px (standard mobile size)
- Back button: 36×36px (standard nav element)

**Scrollable Content:**
- 730px content area accommodates form fields
- Vertical scroll for longer content
- Fixed header stays in view

**Input Field Heights:**
- 50px standard input height (comfortable for touch)
- 120px minimum textarea (allows multiple lines visible)

### Typography Hierarchy

**Font Weights:**
- 680 for section heading (strong emphasis)
- 600 for page title and button (medium emphasis)
- 540 for category chips (subtle emphasis)
- 500 for field labels (clear hierarchy)
- 400 for body text and inputs (readable)

**Font Sizes:**
- 18px section heading (largest, primary hierarchy)
- 16px page title and button (secondary hierarchy)
- 14px labels, description, input text (body)
- 13px category chips (compact display)
- 12px helper text (tertiary, supportive)

### Error Prevention

**Form Validation:**
- Submit button disabled prevents error states
- No validation errors need to be shown
- User cannot submit incomplete form

**Category Pre-selection:**
- No default category (forces intentional choice)
- User must actively select

**Message Trimming:**
- `message.trim()` prevents whitespace-only submissions
- User must enter actual content

### Future Considerations

**What's Not in Design:**
- No success message shown after submit
- No error handling for API failures
- No loading state during submission
- No "Cancel" button (only back navigation)
- No draft saving mechanism
- No file attachment capability
- No rating system or satisfaction scores
- No form field validation errors

**Potential Enhancements:**
- Character counter for message field
- Email/phone format validation
- Success toast after submission
- Loading spinner during API call
- Draft auto-save to localStorage
- Image attachment for bug reports
- Multi-select categories if needed

---

## Technical Implementation Notes

### Component Architecture

**Props Interface:**
```javascript
{
  onBack: () => void,              // Navigate to previous screen
  onSubmit: (feedback: object) => void  // Handle feedback submission
}
```

**State Management:**
- Five local state variables using `useState`
- No global state required
- State resets after successful submission

**Conditional Rendering:**
- Contact fields use React conditional: `{allowContact && (<>...</>)}`
- No animation/transition effects

**Event Handlers:**
- `onBack`: Back button click
- `setCategory(cat)`: Category chip click
- `setMessage(e.target.value)`: Textarea change
- `setAllowContact(e.target.checked)`: Checkbox change
- `setName(e.target.value)`: Name input change
- `setContact(e.target.value)`: Contact input change
- `handleSubmit()`: Submit button click
- Focus/blur handlers for border color changes
- Hover handlers for chip background changes

### Form Submission Logic

```javascript
const handleSubmit = () => {
  if (category && message.trim()) {
    const feedback = {
      category,
      message,
      ...(allowContact && { name, contact }),
    };
    onSubmit(feedback);
    // Reset form
    setCategory(null);
    setMessage("");
    setAllowContact(false);
    setName("");
    setContact("");
  }
};
```

**Validation:**
- Checks `category` is not null
- Checks `message.trim()` is not empty
- Conditional spread includes contact fields only if `allowContact` is true

**Form Reset:**
- All state variables returned to initial values
- Form ready for next submission
- No confirmation or undo

### Data Structure

**Category Array:**
```javascript
const categories = [
  "Wrong information",
  "Ideas for the app",
  "Bug",
  "Missing a place",
  "Suggestion",
  "Praise",
  "Something else",
];
```

**Feedback Object:**
```javascript
{
  category: "Bug",
  message: "Search crashes when I enter special characters",
  // Optional fields below (only if allowContact is true):
  name: "Erik Hansen",
  contact: "erik@example.com"
}
```

### Styling Approach

**Inline Styles:**
- All styles defined inline in JSX
- No external CSS files
- Dynamic styles based on state (selected, focused, disabled)

**Dynamic Style Logic:**
- Category chip background: `category === cat ? ACCENT : "#fff"`
- Submit button background: `isValid ? ACCENT : "#ddd"`
- Focus border color: Set via `onFocus`/`onBlur` handlers
- Hover background: Set via `onMouseEnter`/`onMouseLeave` handlers

**Transitions:**
- Background changes: 0.2s ease
- Border color changes: 0.2s ease

### Accessibility Attributes

**Not Present in Current Design:**
- No `aria-label` attributes
- No `aria-required` attributes
- No `aria-describedby` for helper text
- No `role` attributes
- No screen reader announcements

**Potential Enhancements:**
- Add `aria-required="true"` to category and message
- Add `aria-describedby` linking labels to helper text
- Add `aria-invalid` for validation states
- Add focus trap when form is modal
- Add screen reader announcement on form reset

### Browser Compatibility

**Standard HTML Elements:**
- `<div>`, `<button>`, `<input>`, `<textarea>`, `<label>`
- No custom components beyond React

**CSS Features:**
- Flexbox for layout
- Standard border/background/padding properties
- Transitions (widely supported)

**JavaScript Features:**
- React hooks: `useState`
- Template literals
- Spread operator
- Arrow functions
- Ternary operators
- Array `.map()` method

---

## Summary

The Share Feedback Form is a well-structured, user-friendly interface for collecting categorized feedback from JourneyMate users. The design balances simplicity with comprehensive data collection through progressive disclosure and clear validation. Key strengths include the category-first approach, minimal required fields, optional contact follow-up, and disabled-button validation strategy.

The form follows mobile-first principles with appropriate touch targets, scrollable content, and clear visual hierarchy. The design system is consistently applied with ACCENT orange for interactive states and a clear typography scale.

The implementation is straightforward with local state management, inline styling, and props-based callbacks for navigation and submission. Form data is reset after submission, allowing multiple feedback submissions in a single session.

Future enhancements could include success messaging, error handling, loading states, form field validation, and accessibility improvements, but the current design provides a solid foundation for collecting actionable user feedback.
