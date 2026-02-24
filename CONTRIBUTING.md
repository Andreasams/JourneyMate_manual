# Contributing to JourneyMate

**Welcome!** This guide helps you get started contributing to the JourneyMate codebase.

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Andreasams/JourneyMate_manual.git
cd JourneyMate-Organized
```

### 2. Read the Documentation (60 minutes)

Read these documents **in order** to become productive:

| Document | Time | Purpose |
|----------|------|---------|
| **CLAUDE.md** | 10 min | Session rules, critical decisions, quick reference |
| **ARCHITECTURE.md** | 45 min | How the app is built (state management, patterns, pitfalls) |
| **DESIGN_SYSTEM_flutter.md** | 15 min | Design tokens (colors, spacing, typography) |

**After reading:**
- You'll understand the tech stack (Flutter 3.x, Riverpod 3.x, BuildShip API)
- You'll know the design patterns (self-contained widgets, NotifierProvider, fire-and-forget analytics)
- You'll know the code quality standards (design tokens, flutter analyze, no magic numbers)

### 3. Set Up Flutter Environment

```bash
cd journey_mate
flutter pub get
flutter analyze  # Should return "No issues found!"
```

---

## Development Workflow

### Creating a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

**Branch naming:**
- `feature/` — New features (e.g., `feature/add-map-view`)
- `fix/` — Bug fixes (e.g., `fix/search-crash`)
- `chore/` — Maintenance (e.g., `chore/update-dependencies`)
- `docs/` — Documentation (e.g., `docs/update-architecture`)

### Making Changes

1. **Follow architectural patterns** — See `ARCHITECTURE.md` for:
   - When to use NotifierProvider vs local state
   - Self-contained widget pattern (no infrastructure props)
   - Fire-and-forget analytics pattern
   - Common pitfalls to avoid

2. **Use design tokens** — ALL values from token classes:
   ```dart
   // ✅ Good
   color: AppColors.accent
   padding: EdgeInsets.all(AppSpacing.lg)
   style: AppTypography.bodyRegular

   // ❌ Bad
   color: Color(0xFFe8751a)
   padding: EdgeInsets.all(16.0)
   style: TextStyle(fontSize: 16)
   ```

3. **Use translations** — NO hardcoded strings:
   ```dart
   // ✅ Good
   Text(td(ref, 'search_placeholder'))

   // ❌ Bad
   Text('Search for restaurants')
   ```

4. **Run flutter analyze** — Before committing:
   ```bash
   cd journey_mate
   flutter analyze  # Must return "No issues found!"
   ```

### Committing Changes

**Commit message format:**
```
<type>: <short description>

<optional body>

<optional footer>
```

**Types:**
- `feat:` — New feature
- `fix:` — Bug fix
- `chore:` — Maintenance (dependencies, config, etc.)
- `docs:` — Documentation updates
- `refactor:` — Code refactoring (no behavior change)
- `test:` — Add or update tests

**Examples:**
```bash
git add .
git commit -m "feat: add dietary filter to menu page"
git commit -m "fix: resolve grey screen navigation issue"
git commit -m "chore: update flutter dependencies"
git commit -m "docs: update ARCHITECTURE.md with new pattern"
```

### Opening a Pull Request

```bash
git push -u origin feature/your-feature-name
```

Then open a PR on GitHub:
1. Write a clear title (same as commit message)
2. Describe what changed and why
3. Reference any related issues
4. Request review from maintainers

---

## Code Standards

### Design Token Adherence (Non-Negotiable)

- **All colors** from `AppColors` — See `DESIGN_SYSTEM_flutter.md`
- **All spacing** from `AppSpacing` — No magic pixel numbers
- **All typography** from `AppTypography` — No inline TextStyle
- **All radii** from `AppRadius` — No hardcoded border radius

**Exception:** Extremely specific one-off values can use magic numbers with explanatory comments.

### State Management (Riverpod 3.x)

- **Global/session state:** `NotifierProvider` or `AsyncNotifierProvider`
- **Page-local UI state:** Local `State` variables in `ConsumerStatefulWidget`
- **NO FFAppState, NO Provider, NO StateNotifier** (deprecated Riverpod 2.x)

**When to use what:**
- Shared across pages? → `NotifierProvider`
- Needs persistence? → `NotifierProvider` + SharedPreferences
- API-dependent? → `AsyncNotifierProvider`
- Only relevant to one page? → Local `State` variables

See `ARCHITECTURE.md` for decision matrix and examples.

### Translation (No Hardcoded Strings)

ALL user-facing text uses `td(ref, 'key')`:

```dart
Text(td(ref, 'search_placeholder'))
TextField(
  decoration: InputDecoration(
    hintText: td(ref, 'search_by_name_or_cuisine'),
  ),
)
```

### Analytics (Fire-and-Forget)

NEVER await analytics calls:

```dart
// ✅ Good
ApiService.instance.postAnalytics(...)
    .catchError((_) => ApiCallResponse.failure('Analytics failed'));

// ❌ Bad
await ApiService.instance.postAnalytics(...);
```

**Why:** User experience is never blocked by analytics.

### Flutter 3.x APIs (Not Deprecated 2.x)

Use modern Flutter APIs:

```dart
// ✅ Good
WidgetStateProperty.all(Colors.white)
AppColors.accent.withValues(alpha: 0.5)
if (context.mounted) { setState(...); }

// ❌ Bad (deprecated)
MaterialStateProperty.all(Colors.white)
AppColors.accent.withOpacity(0.5)
if (mounted) { setState(...); }
```

---

## Testing

### Running Tests

```bash
cd journey_mate
flutter test
```

**Required:** All tests must pass before opening a PR.

### Writing Tests

- **Provider tests:** Test state mutations and persistence
- **Widget tests:** Test UI behavior and user interactions
- **Integration tests:** Test API calls and navigation flows

See existing tests in `journey_mate/test/` for examples.

---

## API Development

All backend calls go through `ApiService.instance` singleton.

**Full API contracts:** See `_reference/BUILDSHIP_API_REFERENCE.md` (523 lines, 12 endpoints)

**Example:**
```dart
final response = await ApiService.instance.search(
  filters: [1, 2, 3],
  filtersUsedForSearch: [1, 2, 3],
  cityId: '17',
  searchQuery: 'pizza',
  sortOption: 'rating',
  userLocation: '55.6761,12.5683',
  languageCode: 'da',
);

if (response.statusCode == 200 && response.jsonBody != null) {
  final searchResults = response.jsonBody['documents'];
  // Update state...
} else {
  // Handle error...
}
```

---

## Questions?

### Where to Look for Answers

1. **Architecture questions** → Read `ARCHITECTURE.md` first
2. **API contracts** → Check `_reference/BUILDSHIP_API_REFERENCE.md`
3. **State management** → Check `_reference/PROVIDERS_REFERENCE.md`
4. **Design tokens** → Check `DESIGN_SYSTEM_flutter.md`
5. **"Why was this built this way?"** → Read `pages/*/BUNDLE.md` (local file, not in Git)

### Need More Help?

- **GitHub issues:** Open an issue on the repo
- **Pull request comments:** Ask questions directly in your PR

---

## Code Review Checklist

Before requesting review, verify:

- [ ] `flutter analyze` returns "No issues found!" (0 warnings, 0 errors)
- [ ] All tests pass (`flutter test`)
- [ ] All colors from `AppColors` (no raw hex)
- [ ] All spacing from `AppSpacing` (no magic numbers)
- [ ] All text styles from `AppTypography` (no inline TextStyle)
- [ ] All translations via `td(ref, key)` (no hardcoded strings)
- [ ] No FFAppState references (only Riverpod 3.x)
- [ ] Analytics calls are fire-and-forget (never awaited)
- [ ] Commit message follows format (type: description)

---

## Additional Resources

- **Flutter Documentation:** https://docs.flutter.dev/
- **Riverpod Documentation:** https://riverpod.dev/
- **go_router Documentation:** https://pub.dev/packages/go_router
- **JourneyMate GitHub Repo:** https://github.com/Andreasams/JourneyMate_manual

---

**Happy Coding!** 🎉

**Questions about this guide?** Open an issue or update this file with a PR.
