// ============================================================
// SETTINGS MAIN PAGE
// Main settings and account navigation hub
// Props: onNavigate (function)
// ============================================================

import { StatusBar, ACCENT, TabBar } from "../../shared/_shared.jsx";

export default function SettingsMain({ onNavigate, onBack }) {
  const SettingsRow = ({ iconPath, label, onClick }) => (
    <div
      onClick={onClick}
      onMouseEnter={(e) => e.currentTarget.style.background = "#f9f9f9"}
      onMouseLeave={(e) => e.currentTarget.style.background = "#fff"}
      style={{
        display: "flex",
        alignItems: "center",
        gap: 12,
        padding: "14px 20px",
        borderBottom: "1px solid #f2f2f2",
        cursor: "pointer",
        background: "#fff",
        transition: "background 0.2s ease",
      }}
    >
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#666" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d={iconPath}/>
      </svg>
      <span style={{
        flex: 1,
        fontSize: 14,
        fontWeight: 400,
        color: "#555",
      }}>
        {label}
      </span>
      <svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke="#bbb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M1 1l6 6-6 6"/>
      </svg>
    </div>
  );

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
        height: 710,
        overflowY: "scroll",
      }}>
        {/* Header */}
        <div style={{ padding: "20px 20px 16px" }}>
          <h1 style={{
            fontSize: 24,
            fontWeight: 700,
            color: ACCENT,
            margin: 0,
          }}>
            Settings & account
          </h1>
        </div>

        {/* My JourneyMate section */}
        <div style={{ marginBottom: 24 }}>
          <div style={{
            fontSize: 14,
            fontWeight: 600,
            color: "#0f0f0f",
            padding: "0 20px 8px",
          }}>
            My JourneyMate
          </div>
          <SettingsRow
            iconPath="M12 2a10 10 0 100 20 10 10 0 000-20zM2 12h20M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"
            label="Localization"
            onClick={() => onNavigate("localization")}
          />
        </div>

        {/* Reach out section */}
        <div style={{ marginBottom: 24 }}>
          <div style={{
            fontSize: 14,
            fontWeight: 600,
            color: "#0f0f0f",
            padding: "0 20px 8px",
          }}>
            Reach out
          </div>
          <SettingsRow
            iconPath="M12 5v14M5 12h14"
            label="Are we missing a place?"
            onClick={() => onNavigate("missing-place")}
          />
          <SettingsRow
            iconPath="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"
            label="Share feedback"
            onClick={() => onNavigate("share-feedback")}
          />
          <SettingsRow
            iconPath="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2zM22 6l-10 7L2 6"
            label="Contact us"
            onClick={() => onNavigate("contact-us")}
          />
        </div>

        {/* Resources section */}
        <div>
          <div style={{
            fontSize: 14,
            fontWeight: 600,
            color: "#0f0f0f",
            padding: "0 20px 8px",
          }}>
            Resources
          </div>
          <SettingsRow
            iconPath="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8zM14 2v6h6M16 13H8M16 17H8M10 9H8"
            label="Terms of use"
            onClick={() => onNavigate("terms")}
          />
          <SettingsRow
            iconPath="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"
            label="Privacy policy"
            onClick={() => onNavigate("privacy")}
          />
        </div>
      </div>

      {/* Bottom tab bar */}
      <TabBar activeTab="profil" onChangeTab={(tab) => {
        if (tab === "udforsk") onBack();
        // other tabs would navigate if handlers were provided
      }} />
    </div>
  );
}
