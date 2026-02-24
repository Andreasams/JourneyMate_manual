# Welcome / Onboarding Pages

**Routes:** `/WelcomePage`, `/AppSettingsInitiateFlow`
**Route Names:** `WelcomePage`, `AppSettingsInitiateFlow`
**Status:** ✅ Production Ready

---

## Purpose

Initial onboarding flow for new users and welcome back screen for returning users. Handles language/currency selection and accessibility detection.

**Primary User Task:** Set language and currency preferences before using app.

---

## Key Features

- **New User Flow:** Language → Currency → Accessibility setup
- **Returning User:** "Fortsæt på dansk" quick continue
- **7 Languages:** English, Danish, German, Italian, Swedish, Norwegian, French
- **Currency Selection:** Auto-suggested based on language
- **Accessibility Detection:** Font scale, high contrast

---

## Custom Widgets Used

| Widget | Purpose | Priority |
|--------|---------|----------|
| `LanguageSelectorButton` | Language dropdown | ⭐⭐⭐⭐⭐ |
| `CurrencySelectorButton` | Currency dropdown | ⭐⭐⭐⭐⭐ |

---

## Custom Actions Used

| Action | Purpose |
|--------|---------|
| `getTranslationsWithUpdate` | Load translations cache |
| `updateCurrencyForLanguage` | Set default currency |
| `updateCurrencyWithExchangeRate` | Fetch exchange rates |
| `detectAccessibilitySettings` | Detect font scale/contrast |
| `trackAnalyticsEvent` | Track onboarding completion |

---

## Custom Functions Used

| Function | Purpose |
|----------|---------|
| `getLanguageOptions` | Available languages list |
| `getCurrencyOptionsForLanguage` | Currencies for language |
| `getLocalizedCurrencyName` | Currency display name |
| `getTranslations` | UI text |

---

## FFAppState Usage

### Write
- `userLanguageCode` - Selected language
- `userCurrencyCode` - Selected currency
- `exchangeRate` - Currency conversion rate
- `translationsCache` - Loaded translations
- `fontScale` - Accessibility setting
- `highContrast` - Accessibility setting

---

## Lifecycle Events

**initState:**
1. Detect if new or returning user
2. Load translations if needed
3. Detect accessibility settings

**dispose:**
1. Track analytics: `onboarding_completed`

---

## User Interactions

**Language Select:** Update language → Fetch translations → Suggest currency
**Currency Select:** Update currency → Fetch exchange rate
**Continue Button:** Save preferences → Navigate to search

---

## Analytics Events

- `onboarding_completed` - Language, currency, accessibility settings
- `language_changed` - Old/new language
- `currency_changed` - Old/new currency

---

## Migration Priority

⭐⭐⭐⭐⭐ **Critical** - First user experience

**Last Updated:** 2026-02-19
