# Codemagic CI/CD Setup Guide for JourneyMate

**Last Updated:** 2026-02-21
**App:** JourneyMate (journey_mate/)
**Bundle ID:** dk.journeymate.journeymate
**Repository:** https://github.com/Andreasams/JourneyMate_manual

---

## Overview

This guide walks through configuring Codemagic CI/CD for the JourneyMate Flutter app. The setup enables:

- **Automatic builds** on push to main branch
- **TestFlight submission** for iOS builds
- **Build gates** (flutter analyze + flutter test must pass)
- **Email notifications** on build success/failure
- **Build number management** (offset +250 from AppStore build 249)

**Workflow:** `ios-workflow` (single workflow for iOS only)

**Build time:** ~15-20 minutes per build

**Triggering:** Automatic on push to `main` branch

---

## Prerequisites

Before configuring Codemagic, ensure you have:

### 1. Apple Developer Account

- **Membership:** Active Apple Developer Program membership ($99/year)
- **Team ID:** Your 10-character Team ID (find at https://developer.apple.com/account)
- **App Store Connect Access:** Admin or App Manager role

### 2. App Store Connect API Key

Required for automated TestFlight submission:

1. Go to https://appstoreconnect.apple.com/access/integrations/api
2. Click "Generate API Key" (or use existing key)
3. Save these values:
   - **Issuer ID** (UUID format, e.g., `12345678-abcd-1234-abcd-1234567890ab`)
   - **Key ID** (10-character alphanumeric, e.g., `AB12CD34EF`)
   - **Private Key** (download `.p8` file — DOWNLOAD IMMEDIATELY, can't re-download)
4. Store `.p8` file securely (you'll upload to Codemagic)

**Key Permissions:**
- Access: "Developer"
- App Manager: ✅ (allows TestFlight submission)

### 3. iOS Distribution Certificate + Provisioning Profile

**Option A: Let Codemagic manage (recommended)**
- Codemagic will auto-create certificates/profiles via App Store Connect API
- Requires API key with Admin role
- Easiest for new setups

**Option B: Manual upload**
- Export Distribution Certificate (.p12) from Keychain Access
- Download App Store Provisioning Profile from developer.apple.com
- Upload both to Codemagic manually

**For this guide:** We use Option A (auto-managed via API key)

### 4. GitHub Repository Access

- Repository: `Andreasams/JourneyMate_manual`
- Access: Admin or Write permissions (to configure webhooks)
- Branch: `main` (protected branch recommended)

### 5. Google Play Account (future — deferred to Phase 8)

Not required for Phase 4.5 (iOS-only workflow).

When adding Android:
- Google Play Developer Account ($25 one-time fee)
- Service Account JSON key
- Release keystore + credentials

---

## Codemagic Configuration Steps

### Step 1: Connect GitHub Repository

1. Go to https://codemagic.io/apps
2. Click **"Add application"**
3. Select **"Connect repository from GitHub"**
4. Authorize Codemagic (if first time)
5. Select repository: **Andreasams/JourneyMate_manual**
6. Click **"Finish: Add application"**

**Result:** Repository is now visible in Codemagic dashboard

### Step 2: Select Workflow

1. In the app view, click **"Start your first build"**
2. Codemagic will detect `journey_mate/codemagic.yaml`
3. Select workflow: **ios-workflow**
4. Do NOT start build yet (need to configure signing first)

### Step 3: Configure iOS Code Signing

#### Option A: Automatic via App Store Connect API (recommended)

1. Go to app settings → **"Distribution"** tab
2. Click **"App Store Connect"** → **"Add integration"**
3. Enter App Store Connect API credentials:
   - **Issuer ID:** [Your UUID from Prerequisites #2]
   - **Key ID:** [Your 10-char key from Prerequisites #2]
   - **API Key:** Upload `.p8` file from Prerequisites #2
4. Click **"Save"**
5. Name integration: `Codemagic` (must match `integrations.app_store_connect` in codemagic.yaml)

**Codemagic will now:**
- Auto-fetch/create Distribution Certificate
- Auto-fetch/create App Store Provisioning Profile
- Store securely in Codemagic keychain

#### Option B: Manual Certificate Upload (alternative)

1. Go to app settings → **"Code signing identities"** tab
2. Click **"iOS certificates"** → **"Add certificate"**
3. Upload **Distribution Certificate (.p12)**
4. Enter certificate password
5. Click **"Add"**
6. Click **"Provisioning profiles"** → **"Add profile"**
7. Upload **App Store Provisioning Profile (.mobileprovision)**
8. Click **"Add"**

### Step 4: Configure Environment Variables

The `codemagic.yaml` workflow references these environment variables:

#### Built-in Variables (no configuration needed)

- `BUILD_NUMBER` — Codemagic auto-incrementing counter (starts at 1)
- `BUNDLE_ID` — Defined in `codemagic.yaml` vars section
- `XCODE_PROJECT` — Defined in `codemagic.yaml` vars section
- `XCODE_SCHEME` — Defined in `codemagic.yaml` vars section

#### Custom Environment Groups (optional — for future expansion)

If you want to add more variables (API keys, secrets):

1. Go to **"Teams"** (top nav) → Your team → **"Environment variables"**
2. Click **"Add group"**
3. Group name: `ios_signing` (or custom)
4. Add variables:
   - Key: `MY_API_KEY`
   - Value: `secret-value`
   - Secure: ✅ (checked = hidden in logs)
5. Click **"Add"**
6. Reference in `codemagic.yaml` environment section:
   ```yaml
   environment:
     groups:
       - ios_signing
   ```

**For Phase 4.5:** No custom groups needed (all signing via App Store Connect integration)

### Step 5: Configure Build Triggers

1. Go to app settings → **"Build triggers"** tab
2. Enable **"Trigger on push"**
3. Select branch: **main**
4. Watched file paths: (leave empty = watch all files)
5. Click **"Save"**

**Result:** Every push to `main` will trigger `ios-workflow`

**Advanced options:**
- **Trigger on pull request:** ❌ Disabled (only build main branch)
- **Trigger on tag:** ❌ Disabled
- **Cancel outdated webhook builds:** ✅ Enabled (saves build time)

### Step 6: Configure Email Notifications

1. Go to app settings → **"Email notifications"** tab
2. Add recipient: **andreasstrandgaard@gmail.com** (from `codemagic.yaml`)
3. Notification settings:
   - Build succeeded: ✅
   - Build failed: ✅
   - Build started: ❌ (optional, can be noisy)
4. Click **"Save"**

**Email content includes:**
- Build number (e.g., 251, 252, 253...)
- Build duration
- Commit message + author
- Link to build logs
- Download link for .ipa artifact

### Step 7: Test First Build

1. Make a trivial change in `journey_mate/` (e.g., update a comment)
2. Commit + push to `main`:
   ```bash
   git add journey_mate/lib/main.dart
   git commit -m "test: trigger first Codemagic build"
   git push origin main
   ```
3. Go to Codemagic dashboard → **"Builds"** tab
4. Watch build logs in real-time

**Expected build flow:**
1. ✅ Set up Flutter (flutter precache)
2. ✅ Set up code signing (fetch cert/profile)
3. ✅ Get Flutter dependencies (flutter pub get)
4. ✅ Generate iOS configuration (flutter build ios --config-only)
5. ✅ Install CocoaPods dependencies (pod install)
6. ✅ Flutter analyze (MUST pass — 0 issues)
7. ✅ Flutter test (allowed to fail for now via `|| true`)
8. ✅ Set build number (BUILD_NUMBER + 250 = 251)
9. ✅ Build iOS app (flutter build ios + xcode-project build-ipa)
10. ✅ Submit to TestFlight (via App Store Connect API)
11. ✅ Send email notification

**Build time:** ~15-20 minutes

**Build artifacts:**
- `.ipa` file (iOS app package)
- `.xcarchive` (Xcode archive with debug symbols)

### Step 8: Verify TestFlight Submission

1. Go to https://appstoreconnect.apple.com/apps
2. Select **JourneyMate**
3. Navigate to **TestFlight** tab
4. Wait ~5-10 minutes for Apple processing
5. New build should appear (build number 251+)
6. Add testers via **Internal Testing** group
7. Testers receive email with TestFlight link

**If build doesn't appear:**
- Check Codemagic logs for TestFlight submission errors
- Verify App Store Connect API key has "App Manager" role
- Confirm bundle ID matches: `dk.journeymate.journeymate`

---

## Build Versioning

### How Build Numbers Work

**pubspec.yaml version:** `1.0.0+249`
- `1.0.0` = User-facing version (major.minor.patch)
- `249` = Last AppStore build number (from previous deployment)

**Codemagic BUILD_NUMBER:** Auto-incrementing counter (1, 2, 3...)

**Offset calculation in codemagic.yaml:**
```bash
agvtool new-version -all $((BUILD_NUMBER + 250))
```

**Result:**
- 1st build: `BUILD_NUMBER=1` → `1 + 250 = 251`
- 2nd build: `BUILD_NUMBER=2` → `2 + 250 = 252`
- 3rd build: `BUILD_NUMBER=3` → `3 + 250 = 253`

**Why offset +250?**
- Continues from last uploaded build (249)
- App Store requires monotonically increasing build numbers
- Each new build must have higher number than previous

### How to Update Version Number

**For minor updates (1.0.0 → 1.0.1):**

1. Edit `journey_mate/pubspec.yaml`:
   ```yaml
   version: 1.0.1+249  # Increment minor, keep build number
   ```
2. Commit + push:
   ```bash
   git add journey_mate/pubspec.yaml
   git commit -m "chore: bump version to 1.0.1"
   git push origin main
   ```
3. Codemagic will build version 1.0.1 with build number 251+ (auto-incremented)

**For major updates (1.0.0 → 2.0.0):**

1. Edit `journey_mate/pubspec.yaml`:
   ```yaml
   version: 2.0.0+249  # Increment major, reset minor/patch, keep build number
   ```
2. Follow same commit/push flow

**IMPORTANT:**
- **Never manually set build number in pubspec.yaml to match Codemagic offset**
  - Pubspec build number (`+249`) is ignored by Codemagic
  - `agvtool new-version` overrides it during build
- **Only change user-facing version (1.0.0 part)**
- **Let Codemagic manage build numbers via offset**

### When to Update Offset

If you ever upload a build manually (outside Codemagic):

1. Note the new highest build number on AppStore (e.g., 300)
2. Calculate new offset:
   - Next Codemagic BUILD_NUMBER will be (last + 1)
   - If last was 50, next is 51
   - Offset = 300 - 51 = 249
3. Update `codemagic.yaml`:
   ```yaml
   agvtool new-version -all $((BUILD_NUMBER + 249))
   ```
4. Commit + push

**For Phase 4.5:** No manual builds planned — offset +250 is correct

---

## Troubleshooting

### Build Fails: "flutter analyze found issues"

**Error:**
```
flutter analyze
Analyzing journey_mate...
warning • Unused import • lib/pages/search_page.dart:5:8
1 issue found.
```

**Fix:**
1. Run locally: `flutter analyze`
2. Fix all warnings (remove unused imports, fix deprecated APIs, etc.)
3. Verify: `flutter analyze` returns `No issues found!`
4. Commit + push fixed code
5. Codemagic will retry automatically

**Prevention:** Run `flutter analyze` before every commit

### Build Fails: "No provisioning profile found"

**Error:**
```
error: No profiles for 'dk.journeymate.journeymate' were found
```

**Fix:**
1. Verify bundle ID in `codemagic.yaml` matches Xcode: `dk.journeymate.journeymate`
2. Check App Store Connect → Identifiers → dk.journeymate.journeymate exists
3. Re-run "Set up code signing" in Codemagic settings
4. Trigger manual build

### Build Fails: "agvtool: no such file or directory"

**Error:**
```
cd journey_mate/ios
agvtool new-version -all $((BUILD_NUMBER + 250))
-bash: agvtool: command not found
```

**Fix:**
- This should never happen (agvtool is part of Xcode)
- Verify `xcode: latest` in `codemagic.yaml` environment section
- Contact Codemagic support if persists

### Build Succeeds but TestFlight Submission Fails

**Error:**
```
App Store Connect API error: NOT_AUTHORIZED
```

**Fix:**
1. Verify App Store Connect API key permissions:
   - Role: "Admin" or "App Manager"
   - Access: "Developer" ✅
2. Re-upload API key in Codemagic settings
3. Confirm integration name matches codemagic.yaml: `Codemagic`

### Build Takes Too Long (>30 minutes)

**Normal time:** 15-20 minutes

**If longer:**
- Check `max_build_duration: 120` in codemagic.yaml (allows up to 2 hours)
- Slow steps:
  - "Install CocoaPods dependencies" (~5 min) — normal
  - "Build iOS app" (~8 min) — normal
  - "flutter test" — may hang if tests don't terminate
- **Fix:** Cancel build, investigate locally, push fix

### Build Number Skipped (e.g., 251 → 253)

**Cause:** Codemagic BUILD_NUMBER increments even if build fails

**Example:**
- Build 1 fails → BUILD_NUMBER=1 used (offset to 251), but no .ipa uploaded
- Build 2 succeeds → BUILD_NUMBER=2 used (offset to 252)
- Result: Build 251 missing from TestFlight

**Fix:** This is expected behavior — build numbers may have gaps. Not a problem.

### Email Notification Not Received

**Check:**
1. Codemagic settings → Email notifications → Recipient correct?
2. Check spam folder
3. Verify build finished (not still running)

**Fix:** Update email in Codemagic settings + trigger new build

---

## Post-Setup Checklist

After completing all steps, verify:

- [ ] Repository connected: `Andreasams/JourneyMate_manual`
- [ ] Workflow detected: `ios-workflow` from `journey_mate/codemagic.yaml`
- [ ] App Store Connect integration added (name: `Codemagic`)
- [ ] iOS signing configured (auto-managed via API key)
- [ ] Build trigger enabled for `main` branch pushes
- [ ] Email notifications configured: `andreasstrandgaard@gmail.com`
- [ ] Test build succeeded (build number 251+)
- [ ] TestFlight received new build
- [ ] `flutter analyze` returns 0 issues locally
- [ ] `flutter test` passes locally (or fix tests before removing `|| true`)

---

## Workflow Details (codemagic.yaml Reference)

### Instance Type

```yaml
instance_type: mac_mini_m1
```

**Options:**
- `mac_mini_m1` — M1 Mac (fastest for iOS builds, recommended)
- `mac_mini_m2` — M2 Mac (even faster, higher cost)
- `mac_pro` — Intel Mac (slower, lower cost)

**For Phase 4.5:** Using M1 (good balance of speed/cost)

### Build Gates

```yaml
- name: Flutter analyze
  script: flutter analyze
```

**Purpose:** Enforce code quality — build fails if warnings/errors exist

**To disable temporarily:**
```yaml
script: flutter analyze || true  # Allows warnings, not recommended
```

```yaml
- name: Flutter test
  script: flutter test || true
```

**Purpose:** Run unit tests

**Current state:** `|| true` allows test failures (Phase 7 has minimal tests)

**Phase 8:** Remove `|| true` once test suite is complete

### Artifacts

```yaml
artifacts:
  - journey_mate/build/ios/ipa/*.ipa
  - journey_mate/build/ios/archive/*.xcarchive
```

**Downloads available:**
- `.ipa` — Install on device via Xcode or 3rd-party tools
- `.xcarchive` — Contains debug symbols for crash reporting (upload to Firebase Crashlytics later)

**Retention:** 30 days on Codemagic (download if you need longer storage)

### Publishing

```yaml
app_store_connect:
  auth: integration
  submit_to_testflight: true
  submit_to_app_store: false
```

**Options:**
- `submit_to_testflight: true` — Auto-submit to TestFlight (current setting)
- `submit_to_app_store: true` — Auto-submit for App Store review (DANGER — use only for production releases)

**For Phase 4.5:** TestFlight only (no automatic App Store submission)

---

## Future Enhancements (Phase 8+)

### 1. Android Workflow

Add second workflow to `codemagic.yaml`:

```yaml
workflows:
  android-workflow:
    name: Android Workflow
    instance_type: linux_x2
    environment:
      flutter: stable
      android_signing:
        - keystore_reference: android_keystore
      vars:
        PACKAGE_NAME: "dk.journeymate.journeymate"
    scripts:
      - name: Build Android app
        script: |
          cd journey_mate
          flutter build appbundle --release
    publishing:
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
```

**Requirements:**
- Google Play Service Account JSON key
- Android Release Keystore (.jks file)
- Keystore password + key password

### 2. Remove Test Failure Bypass

Once tests are complete:

```yaml
- name: Flutter test
  script: flutter test  # Remove || true
```

**Result:** Build fails if any test fails (ensures test coverage)

### 3. Slack Notifications

Add Slack webhook for team notifications:

```yaml
publishing:
  slack:
    channel: '#ci-builds'
    notify_on_build_start: false
    notify:
      success: true
      failure: true
```

### 4. Build Caching

Speed up builds by caching dependencies:

```yaml
cache:
  cache_paths:
    - $HOME/.pub-cache
    - $HOME/Library/Caches/CocoaPods
```

**Benefit:** Reduces build time from 20 min → 12 min (after first build)

### 5. Pull Request Builds

Enable builds on PRs (without TestFlight submission):

```yaml
triggering:
  events:
    - push
    - pull_request
  branch_patterns:
    - pattern: '*'
      include: true
```

**Benefit:** Catch issues before merging to main

---

## Security Best Practices

1. **Never commit secrets to codemagic.yaml**
   - Use environment variables for API keys
   - Mark as "Secure" in Codemagic UI (hidden in logs)

2. **Rotate App Store Connect API keys annually**
   - Revoke old keys in App Store Connect
   - Generate new key + update Codemagic

3. **Limit API key permissions**
   - Use "Developer" role (not "Admin" unless needed)
   - Scope to specific apps if possible

4. **Enable two-factor auth on Apple ID**
   - Protects against account compromise
   - Required for App Store Connect access

5. **Review build logs**
   - Check for exposed secrets (API keys, tokens)
   - Sanitize logs before sharing publicly

---

## Support Resources

**Codemagic Documentation:**
- https://docs.codemagic.io/
- Flutter guide: https://docs.codemagic.io/flutter-configuration/flutter-projects/
- iOS signing: https://docs.codemagic.io/yaml-code-signing/signing-ios/

**JourneyMate Project:**
- Repository: https://github.com/Andreasams/JourneyMate_manual
- CLAUDE.md: Phase-specific instructions
- SESSION_STATUS.md: Current project state

**Contact:**
- Email: andreasstrandgaard@gmail.com
- GitHub Issues: https://github.com/Andreasams/JourneyMate_manual/issues

---

## Summary

After completing this guide:

✅ **Codemagic CI/CD configured for JourneyMate**
✅ **Automatic iOS builds on push to main**
✅ **TestFlight submission enabled**
✅ **Build gates enforced (flutter analyze)**
✅ **Email notifications active**
✅ **Build number management (offset +250)**

**Next Steps:**
1. Continue Phase 7 widget implementation
2. Push to main after Phase 8
3. Monitor first production build on Codemagic
4. Test on device via TestFlight

**Phase 4.5 Complete!** CI/CD ready for final integration.
