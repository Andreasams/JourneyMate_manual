# Location Sharing Settings — Complete Bundle

**FlutterFlow Widget:** `LocationSharingWidget`
**Route:** `LocationSharing` (path: `locationSharing`)
**Status:** ✅ Production Ready

---

## Purpose

Location permission management page with two-state UI (permission OFF and ON). Helps users enable or disable location sharing with clear instructions for accessing system settings.

**Primary User Tasks:**
- Enable location sharing to see nearby restaurants
- Disable location sharing if already enabled
- Understand privacy implications

---

## User Flow

```
Settings → Localization → Location sharing
  │
  ├─ Page loads (initState):
  │    ├─ Call checkLocationPermission('locationSharing')
  │    ├─ Updates FFAppState().locationStatus (true/false)
  │    └─ Record page start time
  │
  ├─ UI renders based on FFAppState().locationStatus:
  │    │
  │    ├─ IF Location OFF (!locationStatus):
  │    │    ├─ Heading: "Turn on location sharing"
  │    │    ├─ Description: How to enable instructions
  │    │    ├─ Button: "Turn on location sharing"
  │    │    ├─ Privacy note
  │    │    └─ Tap button → openLocationSettings('locationSharing')
  │    │
  │    └─ IF Location ON (locationStatus):
  │         ├─ Heading: "Location sharing is turned on"
  │         ├─ Description: How to disable instructions
  │         ├─ Button: "Go to Settings"
  │         ├─ Privacy note
  │         └─ Tap button → openLocationSettings('locationSharingDeactivate')
  │
  ├─ User taps button → Opens system location settings
  │
  ├─ User changes permission in system settings
  │
  ├─ User returns to app
  │
  └─ Page dispose → Track analytics (page_viewed with duration)
```

---

## Page Structure

### App Bar

**Configuration:**
- White background
- Back button (left): iOS style arrow
- Title: Translation key `'k1c3fupg'` ("Location sharing" / "Lokationsdeling")
- Center title: Yes

**Back Button Action:**
- `await actions.markUserEngaged()`
- `context.safePop()`

### Two-State Content (Conditional Rendering)

**State Determined By:** `FFAppState().locationStatus` (boolean)
- `false` → Location OFF UI
- `true` → Location ON UI

---

## State 1: Location OFF UI

**Display Condition:** `!FFAppState().locationStatus`

**Layout:** Centered content with vertical arrangement

### Elements

1. **Heading**
   - Text: Translation key `'u0wnvdeg'` ("Turn on location sharing" / "Slå lokationsdeling til")
   - Font: 24px, 600 weight
   - Alignment: Center
   - Padding: Bottom margin

2. **Description**
   - Text: Translation key `'tht0e2um'` ("To turn on location sharing, t..." / "For at slå lokationsdeling til...")
   - Font: 14px, 400 weight
   - Color: Secondary text
   - Alignment: Center
   - Content: Step-by-step instructions for enabling in system settings
   - Padding: Bottom margin

3. **Button**
   - Text: Translation key `'3r57tlpr'` ("Turn on location sharing" / "Slå lokationsdeling til")
   - Style: Primary filled button (orange)
   - Width: 270px (or full width minus padding)
   - Height: 50px
   - Action: `openLocationSettings('locationSharing')`

4. **Privacy Note**
   - Text: Translation key `'iucaz964'` ("Your location is exclusively u..." / "Din lokation bruges udelukkende...")
   - Font: 13px, 400 weight
   - Color: Tertiary text (light grey)
   - Alignment: Center
   - Content: Privacy reassurance about data usage
   - Padding: Top margin

---

## State 2: Location ON UI

**Display Condition:** `FFAppState().locationStatus`

**Layout:** Centered content with vertical arrangement

### Elements

1. **Heading**
   - Text: Translation key `'z1v9fk1m'` ("Location sharing is turned on" / "Lokationsdeling er slået til")
   - Font: 24px, 600 weight
   - Alignment: Center
   - Padding: Bottom margin

2. **Description**
   - Text: Translation key `'d9nsgosc'` ("You can turn off location shar..." / "Du kan slå lokationsdeling fra...")
   - Font: 14px, 400 weight
   - Color: Secondary text
   - Alignment: Center
   - Content: Instructions for disabling in system settings
   - Padding: Bottom margin

3. **Button**
   - Text: Translation key `'2hj5mmov'` ("Go to Settings" / "Gå til Indstillinger")
   - Style: Primary filled button (orange)
   - Width: 270px (or full width minus padding)
   - Height: 50px
   - Action: `openLocationSettings('locationSharingDeactivate')`

4. **Privacy Note**
   - Text: Translation key `'bhki1oos'` ("Your location is exclusively u..." / "Din lokation bruges udelukkende...")
   - Font: 13px, 400 weight
   - Color: Tertiary text (light grey)
   - Alignment: Center
   - Content: Privacy reassurance about data usage
   - Padding: Top margin

**Note:** Privacy note keys may be identical (`'iucaz964'` and `'bhki1oos'` might have same text, or slightly different wording for each state).

---

## Translation Keys

### App Bar
| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `'k1c3fupg'` | App bar title | Location sharing | Lokationsdeling |

### Location OFF State
| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `'u0wnvdeg'` | Heading | Turn on location sharing | Slå lokationsdeling til |
| `'tht0e2um'` | Description | To turn on location sharing, t... | For at slå lokationsdeling til... |
| `'3r57tlpr'` | Button | Turn on location sharing | Slå lokationsdeling til |
| `'iucaz964'` | Privacy note | Your location is exclusively u... | Din lokation bruges udelukkende... |

### Location ON State
| Key | Context | English (en) | Danish (da) |
|-----|---------|--------------|-------------|
| `'z1v9fk1m'` | Heading | Location sharing is turned on | Lokationsdeling er slået til |
| `'d9nsgosc'` | Description | You can turn off location shar... | Du kan slå lokationsdeling fra... |
| `'2hj5mmov'` | Button | Go to Settings | Gå til Indstillinger |
| `'bhki1oos'` | Privacy note | Your location is exclusively u... | Din lokation bruges udelukkende... |

**Total:** 9 translation keys (1 app bar + 4 per state)

---

## Custom Actions Used

### 1. checkLocationPermission()
- **Called:** On page load (`initState`)
- **Purpose:** Determine current location permission status
- **Parameters:** Page identifier (`'locationSharing'`)
- **Side Effects:** Updates `FFAppState().locationStatus` (boolean)
- **Logic:**
  - Queries OS for location permission status
  - Sets `locationStatus = true` if granted
  - Sets `locationStatus = false` if denied/not determined

### 2. openLocationSettings()
- **Called:** When user taps button (both states)
- **Purpose:** Open system location settings
- **Parameters:**
  - State 1: `'locationSharing'` (enable context)
  - State 2: `'locationSharingDeactivate'` (disable context)
- **Behavior:**
  - Opens iOS Settings app → Privacy & Security → Location Services
  - Opens Android Settings → Location
  - May deep-link directly to app's location permission settings

**Note:** Different parameters may provide context for analytics or future enhancements, but both open system settings.

### 3. markUserEngaged()
- **Called:** On back button tap
- **Purpose:** Track user engagement
- **Parameters:** None

### 4. trackAnalyticsEvent()
- **Called:** On page dispose
- **Purpose:** Track page view with duration
- **Parameters:**
  - Event name: `'page_viewed'`
  - Event data: `{ 'pageName': 'locationSharingSettings', 'durationSeconds': calculated }`

---

## FFAppState Usage

### Read
- `locationStatus` (boolean) - Determines which UI state to show

### Write
- `locationStatus` - Updated by `checkLocationPermission()` on page load

---

## Model State Variables

### _model Fields

| Field | Type | Purpose |
|-------|------|---------|
| `pageStartTime` | DateTime | Records when page loaded (for analytics) |

---

## Lifecycle Events

### initState

**Sequence:**
1. Create model
2. Post-frame callback:
   - Check location permission: `await actions.checkLocationPermission('locationSharing')`
     - This updates `FFAppState().locationStatus`
   - Record page start time: `_model.pageStartTime = getCurrentTimestamp`
   - Call `setState()` to trigger UI rebuild with correct state

### dispose

**Sequence:**
1. Track analytics:
   ```dart
   await actions.trackAnalyticsEvent('page_viewed', {
     'pageName': 'locationSharingSettings',
     'durationSeconds': calculated,
   });
   ```
2. Dispose model: `_model.dispose()`
3. Call super: `super.dispose()`

---

## Analytics Events

### page_viewed

**Triggered:** On page dispose
**Event Data:**
- `pageName`: `'locationSharingSettings'`
- `durationSeconds`: Time spent on page

**Potential Enhancements:**
- Add `initialState: 'on' | 'off'`
- Add `finalState: 'on' | 'off'` (if permission changed)
- Add `buttonTapped: true/false`
- Add `permissionChanged: true/false`

---

## Navigation

### Entry Points

**From:** Settings → Localization hub
**Method:** User taps "Location sharing" row
**Route:** `context.pushNamed('LocationSharing')`

### Exit Points

**Back Button:**
- Action: `await actions.markUserEngaged()` → `context.safePop()`
- Returns to Localization hub

**Button Actions:**
- Both buttons open system settings (external navigation)
- User must return to app manually
- On return, page may need to refresh to detect permission change

---

## Design Specifications

### Colors

- Background: `primaryBackground` (white)
- App bar background: White
- Text primary: `primaryText` (near-black)
- Text secondary: Secondary text color (grey)
- Text tertiary: Tertiary text color (light grey)
- Button: Primary color (orange, `#e8751a`)
- Button text: White

### Typography

- App bar title: 16px, 400 weight, center
- Heading: 24px, 600 weight, center
- Description: 14px, 400 weight, center
- Button: 16px, 600 weight
- Privacy note: 13px, 400 weight, center

### Spacing

- Content: Centered vertically and horizontally
- Heading → Description: 16px gap
- Description → Button: 24px gap
- Button → Privacy note: 16px gap
- Content padding: 24px horizontal

### Button Specs

- Width: 270px (or full width with margins)
- Height: 50px
- Border radius: 12px
- Background: Primary orange
- Text: White, 16px, 600 weight

---

## Comparison with JSX Design

**JSX Design Note:** The JSX design shows only the "request permission" state (location OFF). It's a single-state design focused on the initial permission request.

**FlutterFlow Implementation:** Uses a two-state approach handling both permission OFF and ON scenarios.

### Architectural Difference

| Aspect | JSX Design | FlutterFlow Implementation |
|--------|-----------|---------------------------|
| **States Handled** | 1 (request permission only) | 2 (OFF + ON) ✓ |
| **Permission Already Granted** | No UI shown | Dedicated "already on" UI ✓ |
| **Disable Instructions** | Not provided | Clear disable instructions ✓ |
| **State Detection** | Not documented | Automatic on page load ✓ |

**Decision:** FlutterFlow's two-state approach is MORE comprehensive and user-friendly. Handles complete permission lifecycle.

### Content Similarities

- Privacy reassurance (JSX has, FlutterFlow has)
- Clear instructions (JSX has, FlutterFlow has for both states)
- Centered layout (JSX has, FlutterFlow has)
- Primary CTA button (JSX has, FlutterFlow has)

---

## Known Issues

None identified. Implementation is clean and handles both permission states correctly.

---

## Testing Checklist

### Page Load
- [ ] Page loads correctly
- [ ] `checkLocationPermission()` called on load
- [ ] `FFAppState().locationStatus` updated correctly
- [ ] Correct UI state displayed based on permission
- [ ] Page start time recorded

### Location OFF State
- [ ] Heading displays: "Turn on location sharing"
- [ ] Description shows enable instructions
- [ ] Button displays: "Turn on location sharing"
- [ ] Privacy note displays
- [ ] Tapping button opens system location settings
- [ ] Context parameter: `'locationSharing'`

### Location ON State
- [ ] Heading displays: "Location sharing is turned on"
- [ ] Description shows disable instructions
- [ ] Button displays: "Go to Settings"
- [ ] Privacy note displays
- [ ] Tapping button opens system location settings
- [ ] Context parameter: `'locationSharingDeactivate'`

### Navigation
- [ ] Back button marks engagement
- [ ] Back button returns to Localization hub

### Permission Change Detection
- [ ] User changes permission in system settings
- [ ] Returns to app
- [ ] Page refreshes (if still active) or reloads (on next visit) with correct state
- [ ] `FFAppState().locationStatus` updated on next load

### Analytics
- [ ] page_viewed event tracked on dispose
- [ ] Duration calculated correctly

---

## Migration Priority

⭐⭐⭐⭐ **High** - Essential for location-based features (nearby restaurants)

---

## Related Documentation

- **JSX Design:** Shows only request permission flow (single state)
- **Gap Analysis:** `pages/07_settings/GAP_ANALYSIS_location_sharing.md`
- **PAGE README:** `pages/07_settings/PAGE_README.md` (expand section)
- **FlutterFlow Source:** User provided complete source code
- **Related Pages:**
  - Localization hub (parent)
  - Language & Currency (sibling page)
- **Custom Actions:**
  - `checkLocationPermission()` - Permission status check
  - `openLocationSettings()` - System settings navigation

---

**Last Updated:** 2026-02-19
**Status:** ✅ Complete documentation

**Key Feature:** Two-state UI intelligently handles both permission scenarios (OFF + ON), providing clear instructions for enabling AND disabling location sharing.

---

## Riverpod State

> Cross-reference: `_reference/MASTER_STATE_MAP.md`

### Reads
| Provider | Field | Used for |
|----------|-------|----------|
| `ref.watch(locationProvider)` | `hasPermission` | Determines which of the two UI states is shown: OFF state (!hasPermission) or ON state (hasPermission) |

### Writes
| Provider | Notifier method | Trigger |
|----------|----------------|---------|
| `ref.read(locationProvider.notifier).setPermission(...)` | `setPermission` | checkLocationPermission called on page init (with `'locationSharing'` param for analytics) |

**Note:** `openLocationSettings` redirects to the OS settings panel. It does NOT directly write to `locationProvider`. When the user returns to the app, a subsequent `checkLocationPermission` call updates `hasPermission`. This re-check should be triggered in `AppLifecycleState.resumed`.

### Local state (NOT in providers)
| Variable | Type | Purpose |
|----------|------|---------|
| `_pageStartTime` | `DateTime` | Analytics duration calculation on dispose |
