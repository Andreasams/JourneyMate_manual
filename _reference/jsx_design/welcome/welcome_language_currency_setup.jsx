// ============================================================
// LANGUAGE & CURRENCY SETUP PAGE
// First-time user setup flow for selecting language and currency
// Props: onComplete (function), language (string), currency (string),
//        onLanguageChange (function), onCurrencyChange (function)
// ============================================================

import { StatusBar, ACCENT, LanguageCurrencyDropdowns } from "../../shared/_shared.jsx";

export default function WelcomeLanguageCurrencySetup({
  onComplete,
  language,
  currency,
  onLanguageChange,
  onCurrencyChange,
}) {
  return (
    <div style={{
      width: 390,
      height: 844,
      background: "#fff",
      overflow: "hidden",
      position: "relative",
    }}>
      <StatusBar />

      {/* Content */}
      <div style={{
        height: 790,
        overflowY: "scroll",
        padding: "24px",
      }}>
        {/* Simple divider */}
        <div style={{
          height: 1,
          background: "#f2f2f2",
          marginBottom: 32,
        }}/>

        {/* Heading */}
        <h2 style={{
          fontSize: 22,
          fontWeight: 700,
          color: "#0f0f0f",
          margin: "0 0 8px 0",
        }}>
          Localization
        </h2>

        {/* Description */}
        <p style={{
          fontSize: 14,
          fontWeight: 400,
          color: "#555",
          lineHeight: "20px",
          margin: "0 0 32px 0",
        }}>
          Select your preferred language and currency to use in the app.
        </p>

        {/* Language & Currency Dropdowns */}
        <LanguageCurrencyDropdowns
          language={language}
          currency={currency}
          onLanguageChange={onLanguageChange}
          onCurrencyChange={onCurrencyChange}
          showDescriptions={false}
        />

        {/* Complete setup button */}
        <button
          onClick={onComplete}
          style={{
            width: "100%",
            height: 50,
            background: ACCENT,
            color: "#fff",
            border: "none",
            borderRadius: 12,
            fontSize: 16,
            fontWeight: 600,
            cursor: "pointer",
            marginTop: 40,
          }}
        >
          Complete setup
        </button>
      </div>
    </div>
  );
}
