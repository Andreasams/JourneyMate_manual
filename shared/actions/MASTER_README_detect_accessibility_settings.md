# detectAccessibilitySettings Action

**Type:** Custom Action (Async)
**File:** `detect_accessibility_settings.dart` (36 lines)
**Category:** Onboarding & Accessibility
**Status:** ✅ Production Ready
**Priority:** ⭐⭐⭐ (Medium - Accessibility support)

---

## Purpose

Detects system accessibility settings and stores them in FFAppState for app-wide use. Enables the app to respond to user's accessibility preferences like bold text.

**Key Features:**
- Reads system bold text setting
- Stores in FFAppState for global access
- Should be called once on app start
- Lightweight, instant detection

---

## Function Signature

```dart
Future<void> detectAccessibilitySettings(BuildContext context)
```

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `context` | `BuildContext` | **Yes** | BuildContext from calling widget |

### Returns

| Type | Description |
|------|-------------|
| `Future<void>` | No return value |

---

## Dependencies

**No external dependencies** - Uses Flutter's `MediaQuery`

### FFAppState Usage

#### Writes
| State Variable | Type | Purpose |
|---------------|------|---------|
| `isBoldTextEnabled` | `bool` | System bold text setting |

---

## Usage Examples

### Example 1: App Initialization (Recommended)
```dart
// In main app page - first page shown to user
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    actions.detectAccessibilitySettings(context);
  });
}
```

### Example 2: Welcome Page
```dart
// In welcome/onboarding page
class WelcomePage extends StatefulWidget {
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    _detectAccessibility();
  }

  Future<void> _detectAccessibility() async {
    await actions.detectAccessibilitySettings(context);

    if (FFAppState().isBoldTextEnabled) {
      // Adjust UI for bold text users
      setState(() => _useLargerButtons = true);
    }
  }

  @override
  Widget build(BuildContext context) => /* ... */;
}
```

### Example 3: Conditional UI Based on Settings
```dart
// Use detected settings throughout app
Widget _buildText(String text) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FFAppState().isBoldTextEnabled
          ? FontWeight.w700  // Extra bold for accessibility users
          : FontWeight.w400, // Normal weight
    ),
  );
}
```

---

## Detected Settings

### 1. Bold Text (isBoldTextEnabled)

**System Settings:**
- iOS: Settings → Accessibility → Display & Text Size → Bold Text
- Android: Settings → Accessibility → Text and display → Bold text

**Values:**
- `true` - User has enabled system-wide bold text
- `false` - Normal text weight

**Common Adjustments:**
```dart
if (FFAppState().isBoldTextEnabled) {
  // Increase font weights
  // Increase button sizes
  // Improve contrast
}
```

---

## Debug Output

```
♿ Accessibility settings detected:
   Bold text: true
```

---

## When to Call

### ✅ DO Call:
- Once on app start (first page load)
- After app resume if settings might have changed

### ❌ DON'T Call:
- On every page load (unnecessary)
- Before context is available (will error)
- Multiple times per session (wastes resources)

---

## Platform Differences

### iOS
- Bold text requires app restart to take effect
- System prompts user to restart when toggling

### Android
- Bold text applies immediately
- No restart required

---

## Testing Checklist

- [ ] Enable bold text in iOS → isBoldTextEnabled = true
- [ ] Enable bold text in Android → isBoldTextEnabled = true
- [ ] Disable bold text → isBoldTextEnabled = false
- [ ] Verify FFAppState updates correctly
- [ ] Call on first page load → no errors
- [ ] Check debug output shows correct values

---

## Migration Notes

### Phase 3 Changes

1. **Replace FFAppState with Riverpod:**
   ```dart
   // Before:
   FFAppState().update(() {
     FFAppState().isBoldTextEnabled = isBoldTextEnabled;
   });

   // After:
   ref.read(accessibilityProvider.notifier).setBoldText(isBoldTextEnabled);
   ```

2. **Consider adding more accessibility detections:**
   ```dart
   Future<void> detectAccessibilitySettings(BuildContext context) async {
     final mediaQuery = MediaQuery.of(context);

     final settings = AccessibilitySettings(
       boldText: mediaQuery.boldText,
       textScaleFactor: mediaQuery.textScaleFactor,
       highContrast: mediaQuery.highContrast,
       reducedMotion: mediaQuery.disableAnimations,
     );

     ref.read(accessibilityProvider.notifier).updateSettings(settings);
   }
   ```

---

## Related Actions

| Action | Purpose | Relationship |
|--------|---------|--------------|
| N/A | - | Standalone action |

---

## Used By Pages

1. **Welcome/Onboarding** - App initialization

---

## Known Issues

1. **Only detects bold text** - Other accessibility settings (text scale, high contrast) not detected
2. **No automatic re-detection** - Requires manual call if settings change
3. **Requires context** - Must be called after widget tree is built

---

## Accessibility Best Practices

✅ **DO:**
- Call on app start
- Respect bold text setting throughout app
- Test with accessibility features enabled
- Provide alternative UI for accessibility users

❌ **DON'T:**
- Ignore accessibility settings
- Assume all users have default settings
- Remove accessibility features to simplify code

---

**Last Updated:** 2026-02-19
**Migration Status:** ⏳ Phase 2 - Documentation Complete
**Next Step:** Phase 3 - Expand to detect more accessibility settings
