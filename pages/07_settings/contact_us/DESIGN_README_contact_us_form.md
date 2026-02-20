# Contact Us Form — JSX Design Documentation

**Design file:** `C:\Users\Rikke\Documents\JourneyMate-v2\pages\settings\contact_us_form.jsx`

**Date documented:** 2026-02-19

**Status:** JSX design reference — not yet implemented in Flutter

---

## Design Overview

### Purpose
The Contact Us Form provides users with a structured way to submit support inquiries, feedback, or other communication to JourneyMate support. The form collects essential contact information and message details required for effective customer support response.

### Page Type
Full-page form view with scrollable content area and fixed header navigation.

### Key Design Decisions
1. **All fields required** — Every field includes a red asterisk (*) indicating it's mandatory
2. **Flexible contact input** — Users can provide email, phone, or both for response flexibility
3. **Helper text guidance** — Contact field includes explicit instructions to check for spelling mistakes
4. **Real-time validation** — Submit button is disabled until all fields contain trimmed non-empty values
5. **Focus state feedback** — Input borders change to accent orange on focus for clear interaction state
6. **Auto-reset on submit** — Form clears all fields after successful submission for multi-submission scenarios

### Navigation Context
- **Entry points:** Settings page → Contact Us option
- **Exit points:** Back button returns to previous screen
- **Props required:** `onBack` (function), `onSubmit` (function)

---

## Visual Layout

### Screen Structure (390×844px)

```
┌─────────────────────────────────────────┐
│  StatusBar (44px)                       │
├─────────────────────────────────────────┤
│  Header (60px)                          │
│  [←]     Contact us                     │
├─────────────────────────────────────────┤
│  Scrollable Content (730px)             │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Your full name *                │   │
│  │ [Input field]                   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Your email or phone number *    │   │
│  │ Helper text                     │   │
│  │ [Input field]                   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Subject *                       │   │
│  │ Helper text                     │   │
│  │ [Input field]                   │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ Message *                       │   │
│  │ [Textarea]                      │   │
│  │                                 │   │
│  │                                 │   │
│  └─────────────────────────────────┘   │
│                                         │
│  [Send message button]                 │
│                                         │
└─────────────────────────────────────────┘
```

### Header Bar
- **Height:** 60px
- **Layout:** Three-zone (back button, centered title, empty right zone)
- **Border:** 1px solid #f2f2f2 bottom border
- **Background:** White (#fff)

**Back Button:**
- **Size:** 36×36px
- **Position:** Left edge (20px padding)
- **Icon:** ← (left arrow character)
- **Font size:** 18px
- **Color:** #0f0f0f
- **Background:** Transparent
- **Alignment:** Centered

**Title:**
- **Text:** "Contact us"
- **Font size:** 16px
- **Font weight:** 600
- **Color:** #0f0f0f
- **Alignment:** Center
- **Offset:** -36px margin-left (to compensate for back button width)

### Content Area
- **Height:** 730px (calculated: 844 - 44 StatusBar - 60 header - 10 buffer)
- **Padding:** 24px all sides
- **Scroll:** Vertical overflow enabled
- **Background:** White (#fff)

### Form Layout
Four input fields stacked vertically with consistent spacing.

**Field Spacing:**
- Full name field: 20px bottom margin
- Contact field: 20px bottom margin
- Subject field: 20px bottom margin
- Message field: 24px bottom margin (extra space before button)

---

## Components Used

### StatusBar Component
```jsx
<StatusBar />
```
- Imported from `../../shared/_shared.jsx`
- Height: 44px
- Standard iOS/Android status bar visual

### Form Field Structure
Each field follows a consistent structure:
1. Label with required indicator
2. Helper text (for contact and subject fields)
3. Input/textarea component

### Input Fields (Text Type)
**Shared Properties:**
- **Width:** 100% (fills parent container minus padding)
- **Height:** 50px
- **Padding:** 0 16px (horizontal)
- **Font size:** 14px
- **Font color:** #0f0f0f
- **Background:** #f5f5f5 (light gray)
- **Border:** 1px solid #e8e8e8 (default state)
- **Border radius:** 10px
- **Font family:** inherit
- **Transition:** border-color 0.2s ease

**State-Specific Styling:**
- **Default:** Border #e8e8e8
- **Focus:** Border ACCENT (#e8751a) — controlled by onFocus event
- **Blur:** Border returns to #e8e8e8 — controlled by onBlur event

### Textarea Field (Message)
**Unique Properties:**
- **Min height:** 120px (expandable)
- **Padding:** 12px all sides (symmetric)
- **Resize:** vertical (user can expand vertically only)
- **Font size:** 14px
- **Same styling as text inputs** for consistency

### Label Component
**Structure:**
```jsx
<label>
  Label text <span style={{ color: "#c9403a" }}>*</span>
</label>
```

**Label Styling:**
- **Font size:** 14px
- **Font weight:** 500
- **Color:** #0f0f0f
- **Display:** block
- **Margin bottom:** 8px (full name, message) or 4px (contact, subject)

**Required Indicator:**
- **Character:** * (asterisk)
- **Color:** #c9403a (error red)
- **Position:** Inline after label text

### Helper Text Component
**Styling:**
- **Font size:** 12px
- **Color:** #888 (medium gray)
- **Margin bottom:** 8px (between label and input)
- **Display:** block

**Usage:**
- Contact field: "Please provide either or both. Check for spelling mistakes before submitting."
- Subject field: "Topic of what you would like to contact us about"

### Submit Button
**Styling:**
- **Width:** 100%
- **Height:** 50px
- **Border radius:** 12px
- **Font size:** 16px
- **Font weight:** 600
- **Border:** none
- **Text:** "Send message"

**State-Dependent Styling:**
- **Valid state (all fields filled):**
  - Background: ACCENT (#e8751a)
  - Color: #fff
  - Cursor: pointer
- **Invalid state (any field empty):**
  - Background: #ddd (light gray)
  - Color: #fff
  - Cursor: not-allowed
  - Disabled: true

---

## Design Tokens

### Colors Referenced

| Token | Hex Value | Usage in Form |
|-------|-----------|---------------|
| **ACCENT** | #e8751a | Submit button (enabled), input focus border |
| **Text Primary** | #0f0f0f | Labels, input text, header text |
| **Required Red** | #c9403a | Required asterisk indicator |
| **Helper Gray** | #888 | Helper text below labels |
| **Background Light** | #f5f5f5 | Input/textarea backgrounds |
| **Border Default** | #e8e8e8 | Input/textarea borders (unfocused) |
| **Border Divider** | #f2f2f2 | Header bottom border |
| **Button Disabled** | #ddd | Submit button (disabled state) |
| **White** | #fff | Page background, button text |

### Typography Scale

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Header title | 16px | 600 | #0f0f0f |
| Back button | 18px | default | #0f0f0f |
| Label text | 14px | 500 | #0f0f0f |
| Input text | 14px | default | #0f0f0f |
| Placeholder | 14px | default | inherits |
| Helper text | 12px | default | #888 |
| Submit button | 16px | 600 | #fff |

### Spacing System

| Measurement | Value | Usage |
|-------------|-------|-------|
| Header horizontal padding | 20px | Left/right padding |
| Content padding | 24px | All sides of content area |
| Field spacing (standard) | 20px | Bottom margin between fields |
| Field spacing (before button) | 24px | Extra space before submit |
| Label-to-input gap | 8px | Full name, message fields |
| Label-to-helper gap | 4px | Contact, subject fields |
| Helper-to-input gap | 8px | After helper text |

### Border Radius

| Element | Radius | Rationale |
|---------|--------|-----------|
| Input fields | 10px | Softer, form-friendly feel |
| Submit button | 12px | Slightly more prominent |

---

## State & Data

### Local State Variables

```javascript
const [fullName, setFullName] = useState("");
const [contact, setContact] = useState("");
const [subject, setSubject] = useState("");
const [message, setMessage] = useState("");
```

**All fields:**
- **Type:** String
- **Initial value:** "" (empty string)
- **Controlled inputs:** Each field has value and onChange binding
- **Reset behavior:** All set back to "" after successful submit

### Computed State

```javascript
const isValid = fullName.trim() &&
                contact.trim() &&
                subject.trim() &&
                message.trim();
```

**Validation Logic:**
- **Method:** All fields must have trimmed non-empty values
- **Purpose:** Enable/disable submit button
- **Check:** `.trim()` removes leading/trailing whitespace before boolean evaluation
- **Result:** Boolean (true = all fields valid, false = at least one field empty/whitespace-only)

### Props Interface

```typescript
interface ContactUsFormProps {
  onBack: () => void;      // Called when back button clicked
  onSubmit: (data: {       // Called when form is validly submitted
    fullName: string;
    contact: string;
    subject: string;
    message: string;
  }) => void;
}
```

### No External Data
This form does not fetch or display external data. It is purely a data collection interface.

---

## User Interactions

### Navigation Interactions

**Back Button Click:**
```javascript
onClick={onBack}
```
- **Trigger:** User taps back arrow (←) in header
- **Action:** Calls `onBack()` prop function
- **Expected behavior:** Parent component handles navigation to previous screen
- **Note:** Does not validate or clear form — user can return with partially filled form

### Form Field Interactions

**Text Input Focus:**
```javascript
onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
```
- **Trigger:** User taps/clicks inside input field
- **Visual feedback:** Border color changes from #e8e8e8 to ACCENT (#e8751a)
- **Duration:** Persists while field has focus
- **Transition:** 0.2s ease

**Text Input Blur:**
```javascript
onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
```
- **Trigger:** User taps outside input field or tabs to next field
- **Visual feedback:** Border color returns to #e8e8e8
- **Transition:** 0.2s ease

**Text Input Change:**
```javascript
onChange={(e) => setFullName(e.target.value)}
// Similar for contact, subject, message
```
- **Trigger:** User types in field
- **Action:** Updates corresponding state variable
- **Validation:** Triggers re-calculation of `isValid` computed state
- **Effect:** May enable/disable submit button

### Submit Interaction

**Button Click:**
```javascript
onClick={handleSubmit}
disabled={!isValid}
```
- **Trigger:** User taps "Send message" button
- **Pre-condition:** Button only enabled when `isValid === true`
- **Action sequence:**
  1. Validate all fields again (redundant check)
  2. Call `onSubmit()` prop with data object
  3. Clear all form fields (reset to empty strings)

**handleSubmit Logic:**
```javascript
const handleSubmit = () => {
  if (fullName.trim() && contact.trim() && subject.trim() && message.trim()) {
    onSubmit({ fullName, contact, subject, message });
    setFullName("");
    setContact("");
    setSubject("");
    setMessage("");
  }
};
```

**Note:** The validation check inside `handleSubmit` is technically redundant since button is disabled when invalid, but provides defensive coding.

### Keyboard Interactions

**Field Placeholders:**
- Full name: "Enter your full name"
- Contact: "email@example.com or +45 12 34 56 78"
- Subject: "Enter subject"
- Message: "Type your message here..."

**Tab Order:**
1. Back button
2. Full name input
3. Contact input
4. Subject input
5. Message textarea
6. Submit button

**Textarea Resizing:**
- **User control:** Vertical resize handle enabled
- **Minimum height:** 120px
- **Direction:** vertical only (no horizontal resize)
- **Purpose:** Allows users to expand message area for longer messages

---

## Form Validation Rules

### Field-Level Validation

**Full Name Field:**
- **Type:** text
- **Required:** Yes (red asterisk)
- **Validation:** Must contain at least one non-whitespace character after trim
- **No format validation:** Does not check for first/last name split or special characters
- **Placeholder:** "Enter your full name"

**Contact Field:**
- **Type:** text
- **Required:** Yes (red asterisk)
- **Validation:** Must contain at least one non-whitespace character after trim
- **No format validation:** Does not validate email format or phone number format
- **Flexibility:** Accepts email, phone, or both separated by space/comma
- **Helper text warning:** "Check for spelling mistakes before submitting"
- **Placeholder:** "email@example.com or +45 12 34 56 78"

**Subject Field:**
- **Type:** text
- **Required:** Yes (red asterisk)
- **Validation:** Must contain at least one non-whitespace character after trim
- **Purpose guidance:** "Topic of what you would like to contact us about"
- **Placeholder:** "Enter subject"

**Message Field:**
- **Type:** textarea
- **Required:** Yes (red asterisk)
- **Validation:** Must contain at least one non-whitespace character after trim
- **Minimum length:** None specified (any non-empty trimmed text accepted)
- **Maximum length:** None specified
- **Placeholder:** "Type your message here..."

### Form-Level Validation

**Submit Button Enablement:**
```javascript
const isValid = fullName.trim() &&
                contact.trim() &&
                subject.trim() &&
                message.trim();
```

**Rules:**
- **All fields required:** Every field must pass validation
- **Whitespace handling:** `.trim()` removes leading/trailing spaces before check
- **Real-time validation:** Button state updates on every keystroke
- **Visual feedback:**
  - Enabled: Orange button (#e8751a), pointer cursor
  - Disabled: Gray button (#ddd), not-allowed cursor

### Validation Feedback

**No inline error messages:**
- Design relies on required asterisks to communicate requirement
- No red text or error borders on empty fields
- Submit button state is the only validation feedback

**Focus state provides guidance:**
- Orange border on focused field indicates current input area
- Helper text provides proactive guidance before errors occur

### Post-Submit Behavior

**On successful submit:**
```javascript
onSubmit({ fullName, contact, subject, message });
setFullName("");
setContact("");
setSubject("");
setMessage("");
```

**Form reset:**
- All fields cleared to empty strings
- Submit button becomes disabled (isValid = false)
- Ready for new submission
- No success message displayed (handled by parent component)

**Design assumption:** Parent component via `onSubmit` handles:
- API call to submit data
- Success/error feedback display
- Navigation after submission (if needed)

---

## Design Rationale

### Why This Form Structure?

**1. All fields required with asterisks**
- **Decision:** Every field marked with red * and required for submission
- **Rationale:** Support requests need complete information for effective response
- **Alternative considered:** Making contact field optional if email provided
- **Why rejected:** Flexibility is better — user chooses how to be contacted

**2. Flexible contact input (email OR phone OR both)**
- **Decision:** Single text field accepting email, phone, or both
- **Rationale:** Reduces friction — user provides what they're comfortable with
- **Alternative considered:** Separate email and phone fields
- **Why rejected:** More fields = more friction, and only one contact method is needed
- **Helper text supports this:** Explicit instruction to provide "either or both"

**3. Focus state uses accent orange**
- **Decision:** Input borders turn orange (#e8751a) when focused
- **Rationale:** Consistent with JourneyMate's interactive element pattern
- **Accessibility:** Clear visual feedback for which field is active
- **Alternative considered:** Keep gray borders, use shadow for focus
- **Why rejected:** Orange is the established interactive color throughout the app

**4. Real-time submit button validation**
- **Decision:** Button disabled until all fields pass validation
- **Rationale:** Prevents invalid submissions and provides clear progress feedback
- **Visual clarity:** Gray button communicates "not ready," orange communicates "ready"
- **Alternative considered:** Allow click and show error messages
- **Why rejected:** Disabled state is clearer and prevents error state entirely

**5. Form auto-resets after submit**
- **Decision:** All fields cleared to empty strings post-submit
- **Rationale:** Prepares form for potential follow-up message
- **Use case:** User might want to submit multiple topics separately
- **Alternative considered:** Keep form filled after submit
- **Why rejected:** Could confuse user about whether message was sent

**6. Helper text for contact and subject fields**
- **Decision:** Small gray text below label provides guidance
- **Rationale:** Proactive guidance prevents errors before they occur
- **Contact field:** Warns about spelling mistakes (critical for response)
- **Subject field:** Clarifies purpose of field (topic, not title)
- **Alternative considered:** Tooltips or info icons
- **Why rejected:** Helper text is always visible, requires no additional interaction

**7. Textarea allows vertical resizing**
- **Decision:** Message field can be expanded by user
- **Rationale:** Some support messages require more space than 120px provides
- **User control:** Empowers user to adjust interface to their needs
- **Constraint:** Vertical only prevents breaking layout width
- **Alternative considered:** Fixed height with scroll
- **Why rejected:** Resizing allows user to see full message context

**8. No inline error validation**
- **Decision:** No red borders or error text for empty fields
- **Rationale:** Required asterisks communicate requirement upfront
- **Submit button state:** Provides clear feedback about form readiness
- **User flow:** Focus-first approach — guide rather than criticize
- **Alternative considered:** Show errors on blur if field empty
- **Why rejected:** Feels punitive when user is still filling form

**9. Header matches standard JourneyMate pattern**
- **Decision:** Back button, centered title, 60px height, bottom border
- **Rationale:** Consistency with all other pages in app
- **Navigation clarity:** User always knows how to go back
- **Alternative considered:** Close X button on right
- **Why rejected:** Back arrow is established pattern

### Accessibility Considerations

**Label-input association:**
- Each label is properly associated with its input
- Required asterisks are inline with labels (screen readers will announce)

**Color contrast:**
- #0f0f0f text on white meets WCAG AA standards
- Helper text (#888) may be borderline but is secondary information
- Required red (#c9403a) has sufficient contrast

**Focus indicators:**
- Orange border provides clear visual focus state
- 0.2s transition prevents jarring changes

**Button states:**
- Disabled button uses `disabled` attribute (not just visual)
- Cursor changes communicate interactivity state
- Color contrast maintained in both states

### Mobile UX Optimizations

**Field height (50px):**
- Large enough for comfortable touch targets (meets 44px minimum)
- Consistent height prevents layout shifting

**Padding (24px content area):**
- Adequate thumb clearance from screen edges
- Prevents accidental taps on back button when filling fields

**Scrollable content:**
- 730px scroll area ensures all fields accessible even with keyboard
- Vertical scroll enables form to work on shorter devices

**Placeholder text examples:**
- Contact field placeholder shows both email and phone format
- Helps user understand expected input format

### Data Handling Considerations

**Trim validation:**
- Prevents submission of whitespace-only fields
- Ensures data quality before sending to support system

**No client-side format validation:**
- Contact field accepts any format (email, phone, both, other)
- Reduces friction — backend can parse and validate
- User responsibility to check spelling (as noted in helper text)

**State management:**
- Local component state (not persisted)
- Form does not auto-save drafts
- If user navigates away, data is lost (common form pattern)

**Prop-based submission:**
- `onSubmit` prop allows parent to handle API call
- Separation of concerns: form handles UI, parent handles data persistence
- Enables different submission handlers (email, API, local storage, etc.)

### Why No Success/Error Feedback Here?

**Decision:** Form does not display submission success or error states
**Rationale:**
- Parent component controls post-submit flow (via `onSubmit` prop)
- May navigate to confirmation screen
- May show toast/snackbar message
- May stay on form with banner message
- Flexibility for different use cases

**Form responsibility:** Collect and validate data
**Parent responsibility:** Submit data and handle response

---

## Design Tokens Deep Dive

### Color System Usage

**Primary Interactive Color (ACCENT #e8751a):**
- Submit button background (enabled state)
- Input focus borders
- **Design principle:** Orange = interactive/tappable elements

**Text Hierarchy:**
- **#0f0f0f (darkest):** Labels, input text, header — primary readable content
- **#888 (medium gray):** Helper text — secondary guidance
- **#fff (white):** Button text — high contrast on orange

**State Communication:**
- **#e8751a (accent orange):** Ready/active state
- **#ddd (light gray):** Disabled/not-ready state
- **#c9403a (error red):** Required indicator (warning color, not error state)

**Subtle UI Elements:**
- **#f5f5f5 (very light gray):** Input backgrounds — subtle distinction from white
- **#e8e8e8 (light gray):** Input borders — visible but not prominent
- **#f2f2f2 (divider gray):** Header border — barely visible separation

### Typography Hierarchy

**Font size progression:**
- 18px: Back button (functional, not text)
- 16px: Header title, submit button (prominent actions)
- 14px: Labels, inputs (standard reading size)
- 12px: Helper text (secondary information)

**Font weight progression:**
- 600: Header title, submit button (emphasis)
- 500: Labels (mild emphasis)
- Default: Inputs, helper text (regular weight)

### Spacing Rhythm

**20px spacing unit:**
- Between form fields (standard)
- Header horizontal padding

**24px spacing unit:**
- Content area padding (all sides)
- Before submit button (extra emphasis)

**8px spacing unit:**
- Label to input gap (standard)
- Helper text to input gap

**4px spacing unit:**
- Label to helper text gap (tight grouping)

### Border Radius Philosophy

**10px input radius:**
- Friendly, approachable feel
- Standard for form inputs throughout app

**12px button radius:**
- Slightly more prominent than inputs
- Signals importance and interactivity

**No sharp corners:**
- Consistent with modern, friendly app design
- Reduces visual tension

---

## Implementation Notes for Flutter Migration

### State Management Approach
```dart
// Local state variables
String _fullName = '';
String _contact = '';
String _subject = '';
String _message = '';

// Computed property
bool get _isValid =>
    _fullName.trim().isNotEmpty &&
    _contact.trim().isNotEmpty &&
    _subject.trim().isNotEmpty &&
    _message.trim().isNotEmpty;
```

### Input Field Focus State
```dart
// Use FocusNode to track focus state
final _fullNameFocusNode = FocusNode();
Color _getBorderColor(FocusNode focusNode) {
  return focusNode.hasFocus
      ? AppTheme.accent
      : AppTheme.borderDefault;
}
```

### Form Submission
```dart
void _handleSubmit() {
  if (_isValid) {
    widget.onSubmit({
      'fullName': _fullName,
      'contact': _contact,
      'subject': _subject,
      'message': _message,
    });
    setState(() {
      _fullName = '';
      _contact = '';
      _subject = '';
      _message = '';
    });
  }
}
```

### TextField Widget Pattern
```dart
TextField(
  controller: _fullNameController,
  focusNode: _fullNameFocusNode,
  decoration: InputDecoration(
    filled: true,
    fillColor: AppTheme.backgroundLight,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: _getBorderColor(_fullNameFocusNode),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: AppTheme.accent,
      ),
    ),
  ),
)
```

### Scrollable Content Area
```dart
SingleChildScrollView(
  child: Padding(
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full name field
        // Contact field
        // Subject field
        // Message field
        // Submit button
      ],
    ),
  ),
)
```

### Button State Management
```dart
ElevatedButton(
  onPressed: _isValid ? _handleSubmit : null,
  style: ElevatedButton.styleFrom(
    backgroundColor: _isValid
        ? AppTheme.accent
        : AppTheme.buttonDisabled,
    disabledBackgroundColor: AppTheme.buttonDisabled,
  ),
  child: Text('Send message'),
)
```

---

## Component Dependencies

### External Imports
```javascript
import { useState } from "react";
import { StatusBar, ACCENT } from "../../shared/_shared.jsx";
```

**From React:**
- `useState` — manages local form field state

**From _shared.jsx:**
- `StatusBar` component — standard status bar visual
- `ACCENT` color token — #e8751a orange for interactive elements

### No Additional Dependencies
- Pure React component (no custom hooks)
- No third-party form libraries
- No validation libraries
- No icon libraries (uses text characters: ←)

---

## Responsive Behavior

### Fixed Dimensions
- **Width:** 390px (iPhone 13/14 standard width)
- **Height:** 844px (iPhone 13/14 standard height)
- **No responsive breakpoints** — designed for mobile only

### Scrollable Content Strategy
- **Fixed header:** 60px header stays at top
- **Scrollable body:** 730px content area with vertical scroll
- **Reason:** Ensures form accessible even when keyboard appears
- **Keyboard handling:** Browser/OS pushes content up, scroll enables access to bottom fields

### Content Reflow
- **Field widths:** 100% of container (minus 24px padding each side)
- **Actual input width:** 390 - 48 = 342px usable width
- **Button width:** Matches field widths (100%)
- **No horizontal scroll:** All content fits within 390px width

---

## Testing Considerations

### Manual Test Cases

**Test 1: Empty Form Validation**
- Load page with all fields empty
- Expected: Submit button disabled (gray)
- Expected: No error messages shown

**Test 2: Partial Fill Validation**
- Fill only full name field
- Expected: Submit button remains disabled
- Fill all except message
- Expected: Submit button remains disabled

**Test 3: All Fields Valid**
- Fill all four fields with non-empty text
- Expected: Submit button enabled (orange)

**Test 4: Whitespace-Only Validation**
- Fill all fields with only spaces
- Expected: Submit button remains disabled (trim validation)

**Test 5: Focus State Visual Feedback**
- Tap into full name field
- Expected: Border turns orange immediately
- Tap outside field
- Expected: Border returns to gray
- Repeat for all fields

**Test 6: Submit and Reset**
- Fill all fields and tap submit
- Expected: `onSubmit` called with correct data object
- Expected: All fields cleared to empty strings
- Expected: Submit button disabled again

**Test 7: Navigation Back**
- Fill some fields
- Tap back button
- Expected: `onBack` called
- Expected: Fields remain filled (no automatic clear)

**Test 8: Textarea Resize**
- Focus message field
- Drag vertical resize handle
- Expected: Field expands vertically
- Expected: Submit button remains visible (via scroll)

**Test 9: Long Text Input**
- Enter very long text in each field
- Expected: Text scrolls within field horizontally (single-line inputs)
- Expected: Textarea shows multiple lines
- Expected: No layout breaking

**Test 10: Special Characters**
- Enter special characters (@, -, +, etc.) in contact field
- Expected: Accepted without validation errors
- Enter emojis in message field
- Expected: Accepted and displayed correctly

### Accessibility Tests

**Test 11: Screen Reader Navigation**
- Enable screen reader
- Tab through form
- Expected: Labels read including "required"
- Expected: Placeholders read as hints

**Test 12: Keyboard-Only Navigation**
- Use only Tab, Shift+Tab, Enter
- Expected: Can navigate all fields
- Expected: Can submit form with Enter on button

**Test 13: Focus Trap**
- Tab forward through all elements
- Expected: Focus cycles through back button → fields → submit button
- Tab backward
- Expected: Reverse order maintained

### Edge Cases

**Test 14: Rapid Submit Clicks**
- Fill form and enable button
- Click submit multiple times rapidly
- Expected: Only one submit call
- Expected: Form resets before second click can fire

**Test 15: State Persistence Across Navigation**
- Not tested in this design
- Assumption: Parent component does not preserve state

**Test 16: Network Failure Handling**
- Not tested in this component
- Assumption: Parent component via `onSubmit` handles errors

---

## Visual Design Specifications

### Input Field Anatomy
```
┌─────────────────────────────────────────┐
│ Label text *            ← 14px, w500    │
│ Helper text             ← 12px, #888    │
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│ ┃ Input text or placeh...           ┃   │ ← 50px height
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│ ↑                                   ↑   │
│ 16px padding              16px padding  │
└─────────────────────────────────────────┘
```

**Border states:**
- Default: 1px #e8e8e8
- Focus: 1px #e8751a (accent orange)
- Transition: 0.2s ease

### Button Anatomy
```
┌─────────────────────────────────────────┐
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│ ┃                                   ┃   │ ← 50px height
│ ┃        Send message               ┃   │ ← 16px, w600, white
│ ┃                                   ┃   │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
└─────────────────────────────────────────┘
```

**Background colors:**
- Enabled: #e8751a (accent orange)
- Disabled: #ddd (light gray)

### Header Anatomy
```
┌─────────────────────────────────────────┐
│ ┌────┐                                  │
│ │ ←  │     Contact us                   │ ← 60px height
│ └────┘                                  │
│ 36×36      16px, w600, centered         │
├─────────────────────────────────────────┤ ← 1px #f2f2f2
```

---

## Future Enhancement Considerations

### Potential Additions (Not in Current Design)

**Email/Phone Format Validation:**
- Could add client-side validation for email format
- Could validate phone number format (e.g., Danish format)
- **Trade-off:** Adds friction vs. flexibility

**Character Counters:**
- Could show character count for message field
- Useful if backend has length limits
- **Trade-off:** Adds visual noise

**Draft Auto-Save:**
- Could persist form state in localStorage
- Prevents data loss on accidental navigation
- **Trade-off:** Privacy concerns, added complexity

**Success/Error Inline Feedback:**
- Could show "Message sent!" banner after submit
- Could display submission errors inline
- **Trade-off:** Currently handled by parent component

**Field-Level Error Messages:**
- Could show "Email format invalid" on blur
- **Trade-off:** Current design avoids punitive feedback

**Loading State on Submit:**
- Could show spinner/loader while API call pending
- Could disable form during submission
- **Trade-off:** Currently handled by parent component

**Attachment Support:**
- Could add file upload field for screenshots
- **Trade-off:** Complicates form, increases support workload

**Pre-Filled User Info:**
- Could auto-populate name/contact from user profile
- **Trade-off:** Requires authentication state, reduces flexibility

---

## Documentation End

**Total lines:** 589 lines

**Last updated:** 2026-02-19

**Design status:** JSX reference complete, ready for Flutter implementation planning

**Next step:** Compare with FlutterFlow original implementation to capture any functionality differences or missing features.
