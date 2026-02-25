// ============================================================
// LOCALIZATION PAGE
// Language, currency, and location settings - all in one place
// Props: onBack (function), onNavigate (function)
// ============================================================

import { useState } from "react";
import { StatusBar, LanguageCurrencyDropdowns, ACCENT } from "../../shared/_shared.jsx";

export default function LocalizationPage({ onBack, onNavigate }) {
  const [language, setLanguage] = useState("da");
  const [currency, setCurrency] = useState("DKK");
  const [locationEnabled, setLocationEnabled] = useState(false);

  return (
    <div style={{
      width: 390,
      height: 844,
      background: "#fff",
      overflow: "hidden",
      position: "relative",
    }}>
      <StatusBar />

      {/* Header */}
      <div style={{
        height: 60,
        display: "flex",
        alignItems: "center",
        padding: "0 20px",
        borderBottom: "1px solid #f2f2f2",
      }}>
        <button
          onClick={onBack}
          style={{
            width: 36,
            height: 36,
            border: "none",
            background: "transparent",
            cursor: "pointer",
            fontSize: 18,
            color: "#0f0f0f",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
          }}
        >
          ←
        </button>
        <div style={{
          flex: 1,
          textAlign: "center",
          fontSize: 16,
          fontWeight: 600,
          color: "#0f0f0f",
          marginLeft: -36,
        }}>
          Localization
        </div>
      </div>

      {/* Content */}
      <div style={{
        height: 730,
        overflowY: "scroll",
        padding: "24px",
      }}>
        {/* Language & Currency Section */}
        <div style={{ marginBottom: 40 }}>
          <h3 style={{
            fontSize: 18,
            fontWeight: 680,
            color: "#0f0f0f",
            margin: "0 0 16px 0",
          }}>
            Language & Currency
          </h3>
          <LanguageCurrencyDropdowns
            language={language}
            currency={currency}
            onLanguageChange={setLanguage}
            onCurrencyChange={setCurrency}
            showDescriptions={true}
          />
        </div>

        {/* Divider */}
        <div style={{
          height: 1,
          background: "#f0f0f0",
          marginBottom: 32,
        }}/>

        {/* Location Sharing Section */}
        <div>
          <h3 style={{
            fontSize: 18,
            fontWeight: 680,
            color: "#0f0f0f",
            margin: "0 0 8px 0",
          }}>
            Location
          </h3>

          <p style={{
            fontSize: 13,
            color: "#888",
            lineHeight: "18px",
            margin: "0 0 16px 0",
          }}>
            Allow JourneyMate to show nearby restaurants and provide better recommendations based on your location.
          </p>

          {/* Current Status Card */}
          <div style={{
            padding: "16px",
            borderRadius: 12,
            border: "1.5px solid #e8e8e8",
            background: "#fafafa",
            marginBottom: 12,
          }}>
            <div style={{
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              marginBottom: 4,
            }}>
              <div style={{
                display: "flex",
                alignItems: "center",
                gap: 10,
              }}>
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#666" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/>
                  <circle cx="12" cy="10" r="3"/>
                </svg>
                <span style={{
                  fontSize: 14,
                  fontWeight: 500,
                  color: "#0f0f0f",
                }}>
                  Location sharing
                </span>
              </div>

              <div style={{
                display: "flex",
                alignItems: "center",
                gap: 6,
              }}>
                <div style={{
                  width: 6,
                  height: 6,
                  borderRadius: "50%",
                  background: locationEnabled ? "#2a9456" : "#c9403a",
                }}/>
                <span style={{
                  fontSize: 13,
                  fontWeight: 500,
                  color: locationEnabled ? "#2a9456" : "#c9403a",
                }}>
                  {locationEnabled ? "Enabled" : "Disabled"}
                </span>
              </div>
            </div>

            <div style={{
              fontSize: 12,
              color: "#999",
              lineHeight: "16px",
            }}>
              {locationEnabled
                ? "We can show you restaurants near you"
                : "Enable to see nearby restaurants"}
            </div>
          </div>

          {/* Action Button */}
          <button
            onClick={() => {
              if (!locationEnabled) {
                // Enable location directly
                setLocationEnabled(true);
              } else {
                // Navigate to full page to see details or disable
                onNavigate("location-sharing");
              }
            }}
            onMouseEnter={(e) => {
              if (!locationEnabled) {
                e.currentTarget.style.background = "#d96816";
              } else {
                e.currentTarget.style.background = "#f9f9f9";
              }
            }}
            onMouseLeave={(e) => {
              if (!locationEnabled) {
                e.currentTarget.style.background = ACCENT;
              } else {
                e.currentTarget.style.background = "transparent";
              }
            }}
            style={{
              width: "100%",
              height: 48,
              background: locationEnabled ? "transparent" : ACCENT,
              color: locationEnabled ? "#555" : "#fff",
              border: locationEnabled ? "1.5px solid #e8e8e8" : "none",
              borderRadius: 12,
              fontSize: 15,
              fontWeight: 600,
              cursor: "pointer",
              fontFamily: "inherit",
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              gap: 8,
              transition: "background 0.2s ease",
            }}
          >
            {locationEnabled ? (
              <>
                Manage location settings
                <svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke="#bbb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M1 1l6 6-6 6"/>
                </svg>
              </>
            ) : (
              "Turn on location sharing"
            )}
          </button>

          {/* Privacy note */}
          {!locationEnabled && (
            <div style={{
              fontSize: 11,
              color: "#aaa",
              lineHeight: "14px",
              textAlign: "center",
              marginTop: 12,
            }}>
              Your location is only used to show nearby places. We never share it with third parties.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
