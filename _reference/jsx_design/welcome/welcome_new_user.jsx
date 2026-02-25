// ============================================================
// WELCOME PAGE — NEW USER (English)
// First-time user onboarding with language selection
// Props: onContinue (function), onSelectDanish (function)
// ============================================================

import { ACCENT } from "../../shared/_shared.jsx";

export default function WelcomeNewUser({ onContinue, onSelectDanish }) {
  return (
    <div style={{
      width: 390,
      height: 844,
      background: "#fff",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      padding: "0 32px",
    }}>
      {/* Heading */}
      <h1 style={{
        fontSize: 28,
        fontWeight: 700,
        color: "#0f0f0f",
        textAlign: "center",
        margin: "0 0 40px 0",
        lineHeight: "34px",
      }}>
        Welcome to<br />JourneyMate
      </h1>

      {/* Mascot */}
      <img
        src="../../FF-pages-images/journeymate_mascot.png"
        alt="JourneyMate mascot"
        style={{
          width: 180,
          height: 180,
          objectFit: "contain",
          margin: "0 0 40px 0",
        }}
      />

      {/* Tagline */}
      <div style={{
        fontSize: 18,
        fontWeight: 500,
        color: "#0f0f0f",
        textAlign: "center",
        margin: "0 0 12px 0",
      }}>
        Go out, your way.
      </div>

      {/* Description */}
      <p style={{
        fontSize: 14,
        fontWeight: 400,
        color: "#555",
        textAlign: "center",
        lineHeight: "20px",
        margin: "0 0 48px 0",
        maxWidth: 320,
      }}>
        Discover restaurants, cafés, and bars filtered by your lifestyle, preferences, and dietary needs.
      </p>

      {/* Continue button (filled) */}
      <button
        onClick={onContinue}
        style={{
          width: "100%",
          maxWidth: 280,
          height: 50,
          background: ACCENT,
          color: "#fff",
          border: "none",
          borderRadius: 12,
          fontSize: 16,
          fontWeight: 600,
          cursor: "pointer",
          margin: "0 0 12px 0",
        }}
      >
        Continue
      </button>

      {/* Danish button (outlined) */}
      <button
        onClick={onSelectDanish}
        style={{
          width: "100%",
          maxWidth: 280,
          height: 50,
          background: "transparent",
          color: ACCENT,
          border: `2px solid ${ACCENT}`,
          borderRadius: 12,
          fontSize: 16,
          fontWeight: 600,
          cursor: "pointer",
        }}
      >
        Fortsæt på dansk
      </button>
    </div>
  );
}
