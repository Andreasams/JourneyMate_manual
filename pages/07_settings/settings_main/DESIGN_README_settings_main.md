# Settings Main Page — Design Documentation

## Design Overview

The Settings Main page (`settings_main.jsx`) serves as the central hub for all application settings and account-related actions. It functions as a navigation gateway that organizes settings into three distinct categories: personal settings (My JourneyMate), communication channels (Reach out), and legal information (Resources).

**Core Purpose:** Provide organized access to all app configuration, user support, and legal documentation through a clean, scannable list interface.

**Page Type:** Navigation hub with categorized list items

**Navigation Context:** Accessible from the "Profil" tab in the main tab bar, representing the user's personal space within the app.

**Key Design Principles:**
- Clear visual hierarchy with section headers
- Consistent interaction patterns across all list items
- Minimal cognitive load through familiar list-based interface
- Icon-based visual scanning support
- Progressive disclosure (settings details revealed on tap)

---

## Visual Layout

### Page Structure

The page uses a three-tier vertical layout:

```
┌─────────────────────────────┐
│ Status Bar (44px)           │
├─────────────────────────────┤
│                             │
│ Scrollable Content (710px)  │
│                             │
│ ┌─────────────────────────┐ │
│ │ Page Header             │ │
│ ├─────────────────────────┤ │
│ │ Section 1: My JM        │ │
│ │  • Setting Row          │ │
│ ├─────────────────────────┤ │
│ │ Section 2: Reach out    │ │
│ │  • Setting Row          │ │
│ │  • Setting Row          │ │
│ │  • Setting Row          │ │
│ ├─────────────────────────┤ │
│ │ Section 3: Resources    │ │
│ │  • Setting Row          │ │
│ │  • Setting Row          │ │
│ └─────────────────────────┘ │
│                             │
├─────────────────────────────┤
│ Tab Bar (90px)              │
└─────────────────────────────┘
```

### Viewport Dimensions

- **Total Page:** 390×844px (iPhone 14/15 standard viewport)
- **Status Bar:** 390×44px
- **Content Area:** 390×710px (scrollable)
- **Tab Bar:** 390×90px (fixed bottom)

### Content Spacing and Layout

**Page Header:**
- Top padding: 20px
- Side padding: 20px
- Bottom padding: 16px
- Header text size: 24px
- Header weight: 700 (bold)
- Header color: `ACCENT` (#e8751a)
- Alignment: Left-aligned

**Section Layout:**
- Section bottom margin: 24px
- Section header side padding: 20px
- Section header bottom padding: 8px
- Section header text size: 14px
- Section header weight: 600
- Section header color: #0f0f0f (darkest text)

**Setting Row Layout:**
- Vertical padding: 14px
- Horizontal padding: 20px
- Row height: ~47px (content + padding)
- Border bottom: 1px solid #f2f2f2
- Background: #fff (default), #f9f9f9 (hover)
- Transition: background 0.2s ease

---

## Components Used

### Imported Components

**StatusBar** — Standard app status bar imported from `_shared.jsx`
- Displays time, signal, battery, etc.
- Height: 44px
- Fixed top position

**TabBar** — Bottom navigation imported from `_shared.jsx`
- Height: 90px
- Active tab: "profil" (Settings page is under Profile tab)
- Handles tab switching with `onChangeTab` callback
- Navigation logic: "udforsk" tab navigates back using `onBack()`

### Local Components

**SettingsRow** — Custom list item component defined within the page

**Purpose:** Reusable interactive list item for all settings and actions.

**Props:**
- `iconPath` (string) — SVG path data for the leading icon
- `label` (string) — Text label for the setting item
- `onClick` (function) — Navigation or action handler

**Structure:**
```
┌────────────────────────────────────┐
│ [Icon]  Label               [→]   │
└────────────────────────────────────┘
```

**Visual Specifications:**
- Display: Flex row
- Alignment: Center-aligned vertically
- Gap: 12px between icon and label
- Cursor: Pointer
- Interactive states: Hover changes background

**Icon (Leading):**
- Size: 18×18px
- ViewBox: 24×24 (scaled down)
- Stroke: #666 (medium gray)
- Stroke width: 2px
- Stroke caps: Round
- Stroke joins: Round
- Fill: None (outlined icons only)

**Label (Middle):**
- Flex: 1 (takes all available space)
- Font size: 14px
- Font weight: 400 (regular)
- Color: #555 (dark gray, slightly lighter than black)
- Text alignment: Left

**Chevron (Trailing):**
- Size: 8×14px
- ViewBox: 8×14
- Path: Right-pointing chevron (`M1 1l6 6-6 6`)
- Stroke: #bbb (light gray)
- Stroke width: 2px
- Stroke caps: Round
- Stroke joins: Round
- Visual weight: Subtle (secondary visual element)

---

## Design Tokens

### Colors

**From `_shared.jsx`:**
- `ACCENT` (#e8751a) — Used for page title

**Local Colors:**
- `#fff` — Row background (default state)
- `#f9f9f9` — Row background (hover state)
- `#f2f2f2` — Row border bottom (divider)
- `#0f0f0f` — Section header text (darkest)
- `#555` — Row label text (dark gray)
- `#666` — Row icon stroke (medium gray)
- `#bbb` — Chevron stroke (light gray)

### Typography

**Page Title:**
- Size: 24px
- Weight: 700 (bold)
- Color: ACCENT (#e8751a)
- Role: Primary heading, establishes page identity

**Section Headers:**
- Size: 14px
- Weight: 600 (semibold)
- Color: #0f0f0f (darkest)
- Role: Category labels, organize content

**Setting Row Labels:**
- Size: 14px
- Weight: 400 (regular)
- Color: #555 (dark gray)
- Role: Action/setting names, scannable list items

### Spacing System

**Padding Values:**
- 20px — Page horizontal margins, header top/sides, section header sides
- 16px — Header bottom padding (tighter below title)
- 14px — Row vertical padding (comfortable tap target)
- 12px — Icon-to-label gap (clear visual grouping)
- 8px — Section header bottom padding (minimal space before list)

**Margin Values:**
- 24px — Section bottom margin (clear separation between groups)

**Border Values:**
- 1px — Row divider (subtle separation)

### Transitions

**Row Hover Animation:**
- Property: background
- Duration: 0.2s
- Easing: ease
- Purpose: Smooth visual feedback on hover

---

## State & Data

### Component Props

**SettingsMain Component:**
- `onNavigate` (function) — Callback for navigating to sub-pages
  - Called with page identifier: `"localization"`, `"missing-place"`, `"share-feedback"`, `"contact-us"`, `"terms"`, `"privacy"`
  - Parent component handles actual navigation logic
  - Decouples settings page from navigation implementation

- `onBack` (function) — Callback for navigating back to Explore
  - Triggered when user taps "udforsk" tab
  - Returns to main discovery flow
  - Maintains tab bar navigation pattern

### Navigation Targets

**Section 1: My JourneyMate**
1. **Localization** — `onNavigate("localization")`
   - Icon: Globe (international symbol)
   - Path: `M12 2a10 10 0 100 20 10 10 0 000-20zM2 12h20M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z`
   - Purpose: Language, region, and localization settings

**Section 2: Reach out**
1. **Are we missing a place?** — `onNavigate("missing-place")`
   - Icon: Plus sign (addition symbol)
   - Path: `M12 5v14M5 12h14`
   - Purpose: Submit missing restaurant suggestions

2. **Share feedback** — `onNavigate("share-feedback")`
   - Icon: Chat bubble (communication)
   - Path: `M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z`
   - Purpose: General app feedback and suggestions

3. **Contact us** — `onNavigate("contact-us")`
   - Icon: Mail envelope (direct communication)
   - Path: `M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2zM22 6l-10 7L2 6`
   - Purpose: Direct contact for support or inquiries

**Section 3: Resources**
1. **Terms of use** — `onNavigate("terms")`
   - Icon: Document (legal document)
   - Path: `M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8zM14 2v6h6M16 13H8M16 17H8M10 9H8`
   - Purpose: Legal terms and conditions

2. **Privacy policy** — `onNavigate("privacy")`
   - Icon: Shield (protection/security)
   - Path: `M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z`
   - Purpose: Privacy practices and data handling policy

### State Management

**No Local State:** The Settings Main page is a pure navigation component with no internal state. All interactions trigger navigation callbacks.

**Hover State:** Mouse hover on setting rows changes background color
- Managed through inline `onMouseEnter` and `onMouseLeave` handlers
- Provides visual feedback for desktop/tablet use
- Does not apply on mobile (touch interface)

**Active Tab State:** TabBar receives `activeTab="profil"` prop
- Indicates settings page is part of Profile section
- Highlights Profile tab in bottom navigation
- Maintains navigation context across app

---

## User Interactions

### Primary Interactions

**1. Setting Row Tap**

**Trigger:** User taps/clicks on any setting row

**Visual Feedback:**
- Desktop/tablet: Background changes to #f9f9f9 on hover (before tap)
- Mobile: Native touch highlight (browser default)
- Chevron icon provides affordance (indicates navigation)

**Action:** Calls `onClick` handler, which invokes `onNavigate(pageId)`

**Result:** Navigation to specific settings sub-page or action form

**Example Flow:**
```
User taps "Localization" row
  ↓
onClick handler fires
  ↓
onNavigate("localization") called
  ↓
Parent component navigates to LocalizationSettings page
```

**2. Tab Bar Navigation**

**Trigger:** User taps a tab in bottom TabBar

**Special Case — "udforsk" Tab:**
- Calls `onBack()` callback instead of normal tab navigation
- Returns user to Explore/Search page
- Maintains back navigation pattern from Settings

**Other Tabs:**
- Would trigger normal tab navigation (handlers not provided in this page)
- Settings page doesn't manage cross-tab navigation directly
- Parent component handles tab routing

**Active Tab Highlight:**
- "profil" tab is highlighted (Settings is under Profile section)
- Visual feedback: Orange indicator, larger icon size
- User understands current location in app

### Interaction Patterns

**List Scanning:**
- Users scan list from top to bottom
- Section headers provide categorical grouping
- Icons provide quick visual identification
- Chevrons indicate all items are tappable/navigable

**Visual Feedback Hierarchy:**
1. **Hover** (desktop) — Background color change (#f9f9f9)
2. **Tap** (all devices) — Browser/OS native highlight
3. **Navigation** (all devices) — Page transition to sub-page

**Accessibility Considerations:**
- Adequate tap target size (47px height with padding)
- Clear visual hierarchy (color, size, weight)
- Consistent interaction patterns (all rows behave identically)
- Icon + text provides redundant information (not icon-only)

### No Scrolling Animations

The content area is scrollable (`overflowY: "scroll"`), but scroll behavior is native browser scrolling with no custom animations or effects.

---

## Design Rationale

### Organizational Structure

**Three-Category Grouping:**

The settings are divided into three semantic categories that match user mental models:

1. **My JourneyMate** — Personal customization
   - Contains settings that affect the user's experience
   - Currently: Localization (language/region)
   - Future: Could include notification preferences, display settings, etc.
   - Naming: "My" emphasizes personal ownership and customization

2. **Reach out** — User-to-team communication
   - Contains all ways to contact or provide input to the JourneyMate team
   - Three distinct channels: Suggest missing places, share feedback, direct contact
   - Naming: "Reach out" feels friendly and approachable (not "Support" or "Help")
   - Rationale: Encourages user participation in improving the app

3. **Resources** — Legal and informational
   - Contains standard legal documentation
   - Separated from personal settings to avoid confusion
   - Naming: "Resources" is neutral and informative
   - Rationale: Legal content doesn't fit semantically with personal settings or communication

**Why Not Flat List?**
- Without categories, users must scan 6+ items to find what they need
- Categories reduce cognitive load by chunking related items
- Section headers provide visual breaks and aid scanning
- Users can skip entire sections that aren't relevant to their task

### Visual Hierarchy

**Title Size (24px) vs. Section Headers (14px):**
- Large size difference (10px) creates clear primary/secondary hierarchy
- Page title establishes context: "Settings & account"
- Section headers fade into background, serve as scannable dividers
- Users can quickly identify which category contains their target

**Icon + Text + Chevron Pattern:**
- **Icon:** Quick visual identification (especially for repeat visits)
- **Text:** Primary information, readable and clear
- **Chevron:** Universal symbol for "go to next screen"
- All three elements work together to communicate affordance

**Color Restraint:**
- ACCENT orange used ONLY for page title (brand/emphasis)
- All setting rows use gray-scale colors (neutral, no hierarchy within list)
- Consistent visual weight across all rows (no item is more important)
- Hover state is subtle (#f9f9f9) — feedback without distraction

### Icon Design

**Why Outlined Icons?**
- Lighter visual weight than filled icons
- Better for dense lists (doesn't create visual clutter)
- Matches modern, clean aesthetic
- Consistent stroke width (2px) creates visual rhythm

**Why Specific Icons?**
- **Globe** for Localization — Universal symbol for language/region
- **Plus** for Missing Place — Add/create action
- **Chat Bubble** for Feedback — Casual conversation
- **Mail** for Contact — Formal communication
- **Document** for Terms — Legal/text document
- **Shield** for Privacy — Protection/security

Each icon has strong semantic association with its label, reducing cognitive load.

### Interaction Design

**Hover State (#f9f9f9):**
- Provides feedback on desktop/tablet (mouse devices)
- Subtle color change (not drastic contrast)
- Does not interfere with mobile touch interactions
- Transition (0.2s ease) prevents jarring color snaps

**Consistent Row Behavior:**
- Every row is interactive (no disabled/static rows)
- Every row navigates to a new page (no in-page actions)
- Every row follows same pattern (icon-label-chevron)
- Users learn interaction model after first tap

**Why No Toggle Switches?**
- Settings are not binary on/off states
- Each setting requires a sub-page for detailed configuration
- Progressive disclosure keeps main page simple
- Toggle switches would imply immediate action (misleading)

### Spacing and Rhythm

**Vertical Rhythm:**
- Row height (47px with padding) creates consistent beat
- 1px borders separate items without heavy visual weight
- Section margins (24px) provide breathing room between categories
- Header padding (8px below) keeps header close to its list

**Horizontal Alignment:**
- All text left-aligned (reading direction)
- Icons left-aligned with text
- Chevrons right-aligned (visual balance)
- 20px side padding creates comfortable margins on mobile

### Content Strategy

**Section Naming:**
- "My JourneyMate" — Not "Settings" (too generic), not "Preferences" (too technical)
- "Reach out" — Not "Support" (implies problems), not "Contact" (too formal)
- "Resources" — Not "Legal" (sounds intimidating), not "Information" (too vague)

Each section name is friendly, approachable, and descriptive.

**Row Labels:**
- "Are we missing a place?" — Question format invites participation
- "Share feedback" — Friendly and casual (not "Submit feedback")
- "Contact us" — Standard and clear
- "Terms of use" — Standard legal language
- "Privacy policy" — Standard legal language
- "Localization" — Technical but universally understood

### Navigation Pattern

**Tab Bar Active State:**
- Settings page is accessed from "Profil" tab
- Active tab: "profil" (always highlighted when on Settings page)
- Tapping "udforsk" calls `onBack()` — returns to discovery flow
- Other tabs would navigate to their respective sections

**Why "profil" Tab?**
- Settings are part of user's personal space
- Profile tab encompasses user-related content (not search/discovery)
- Matches mental model: Settings belong under "My Profile"

### Progressive Disclosure

**No Inline Settings:**
- No settings are configured directly on this page
- Every action requires navigation to a sub-page
- Rationale: Keeps main hub simple and scannable
- Sub-pages can provide detailed forms, explanations, and context

**Example:**
- Localization row doesn't show current language on main page
- User taps to see dedicated page with language selector
- Avoids cluttering main page with secondary information

### Performance and Simplicity

**No Complex State:**
- Page is purely presentational
- No API calls, no data fetching
- No loading states, no error handling
- Fast, reliable rendering

**No Animations:**
- No scroll effects
- No entrance animations
- Only hover transition (subtle feedback)
- Prioritizes speed and simplicity over visual flair

### Accessibility

**Clear Tap Targets:**
- Row height (47px) exceeds minimum touch target size (44px)
- Full row is tappable (not just text or icon)
- Large tap area reduces mis-taps

**Color Contrast:**
- Section headers (#0f0f0f) on white — excellent contrast
- Row labels (#555) on white — good contrast
- Icons (#666) on white — adequate contrast
- Hover state (#f9f9f9) maintains contrast

**Semantic Structure:**
- Section headers provide logical grouping
- List structure is inherently scannable
- Icon + text provides redundant information (not icon-only)

---

## Implementation Notes

### Component Reusability

**SettingsRow Component:**
- Defined locally within SettingsMain page
- Could be extracted to `_shared.jsx` if used elsewhere
- Currently: Only used on Settings Main page, so local definition is appropriate
- Props interface is clean and reusable (iconPath, label, onClick)

### Navigation Decoupling

**Why `onNavigate` Callback?**
- Settings page doesn't know how navigation is implemented
- Parent component handles routing (could be React Router, custom, etc.)
- Makes page easier to test (mock navigation)
- Maintains separation of concerns (UI vs. routing logic)

### Tab Bar Integration

**Why `onBack` for "udforsk" Tab?**
- Settings page is not the "home" of the app
- User expects "Explore" tab to return to main search/discovery
- `onBack()` callback allows parent to implement navigation back
- Other tabs use normal TabBar navigation (parent handles routing)

### Icon SVG Paths

**Hardcoded SVG Paths:**
- Each icon path is hardcoded in the SettingsRow call
- Rationale: Only 6 icons, no need for icon library
- Alternative: Could extract to constant or icon component if list grows
- Current approach: Simple, explicit, no abstraction overhead

### Scroll Behavior

**Native Scrolling:**
- Content area uses `overflowY: "scroll"`
- No custom scroll effects or parallax
- Native mobile scroll behavior (momentum, bounce)
- Better performance, native feel

### Missing Features (By Design)

**No Search:**
- Only 6 settings items — search would add complexity without value
- Categories make scanning fast enough

**No Back Button:**
- Settings page is accessed from tab bar, not pushed onto stack
- User returns via tab bar (tap "udforsk" to go back)
- Matches tab-based navigation pattern

**No Settings Values:**
- Current language, notification status, etc. not shown
- Rationale: Keeps main page simple, values shown on sub-pages
- Trade-off: User must tap to see current state

---

## Design Consistency

### Alignment with JourneyMate Design System

**Color Usage:**
- Orange (ACCENT) used for page title — matches app-wide pattern
- Gray-scale for UI elements — matches design system's neutral palette
- No green used — correctly reserved for match indicators elsewhere

**Typography:**
- Font weights match design system (400, 600, 700)
- Font sizes align with app-wide scale
- Left-aligned text matches app convention

**Spacing:**
- 20px horizontal margins match other pages
- Consistent with search, business profile, and other main pages
- Creates visual rhythm across app

**Interactive Elements:**
- Hover transitions match other clickable elements
- Chevron icon matches search result cards
- Consistent affordances across app

### Differences from Other Pages

**List-Based Layout:**
- Unlike Search (card-based) or Business Profile (content sections)
- List pattern is appropriate for settings navigation
- Matches user expectations for settings interfaces

**No Status Indicators:**
- Unlike Search (match percentage, distance)
- Settings rows don't need secondary information
- All rows have equal visual weight

**Fixed Content:**
- Unlike Search (filtered, sorted, dynamic)
- Settings are static, predictable
- No empty states, no loading states

---

## Future Considerations

### Scalability

**If Settings List Grows:**
- Consider alphabetical or frequency-based sorting
- Add search if list exceeds 10-12 items
- Consider accordion pattern for large categories
- Might need tabs for major setting areas (Account, Preferences, About)

**If Sections Grow:**
- "My JourneyMate" could expand to include: Notifications, Display, Privacy, Account
- "Reach out" is probably stable at 3 items
- "Resources" might add: About, Licenses, Credits

### Enhanced Features

**Setting Value Preview:**
- Show current language in gray text below "Localization"
- Requires fetching/displaying current state
- Trade-off: More information vs. more visual clutter

**Badge Indicators:**
- Red badge for unread announcements (if added)
- Orange dot for pending feedback responses
- Requires notification system

**Search/Filter:**
- If settings list grows significantly
- Search bar at top of content area
- Filters section headers and rows in real-time

### Accessibility Enhancements

**Screen Reader Support:**
- Add aria-label for chevron ("Navigate to [setting name]")
- Add role="list" and role="listitem" for semantic structure
- Add aria-current for active section

**Keyboard Navigation:**
- Focus styles for keyboard users
- Tab through all setting rows
- Enter/Space to activate

**High Contrast Mode:**
- Ensure hover state is visible in high contrast
- Verify icon strokes are visible
- Test with Windows High Contrast, macOS Increase Contrast

### Localization

**Text Strings to Localize:**
- "Settings & account" — Page title
- "My JourneyMate" — Section header
- "Localization" — Row label
- "Reach out" — Section header
- "Are we missing a place?" — Row label
- "Share feedback" — Row label
- "Contact us" — Row label
- "Resources" — Section header
- "Terms of use" — Row label
- "Privacy policy" — Row label

**Design Considerations:**
- Some languages may have longer text (German, Finnish)
- Row layout can accommodate 2-3x English length
- Section headers may need width adjustment
- Icons remain language-neutral

---

## Conclusion

The Settings Main page design prioritizes **clarity**, **scannability**, and **simplicity**. It organizes settings into logical categories, uses familiar list-based UI patterns, and provides clear affordances for navigation. The design is scalable (can accommodate more settings), accessible (adequate contrast and tap targets), and consistent with the broader JourneyMate design system.

The page succeeds at its primary goal: **helping users quickly find and navigate to the setting or action they need**, without unnecessary complexity or cognitive load.
