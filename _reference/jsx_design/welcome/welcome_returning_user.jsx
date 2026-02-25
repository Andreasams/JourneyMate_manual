// ============================================================
// WELCOME PAGE — RETURNING USER (Danish)
// Returning user welcome screen with single CTA
// Props: onContinue (function)
// ============================================================

import { ACCENT } from "../../shared/_shared.jsx";

export default function WelcomeReturningUser({ onContinue }) {
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
      {/* Heading (Danish) */}
      <h1 style={{
        fontSize: 28,
        fontWeight: 700,
        color: "#0f0f0f",
        textAlign: "center",
        margin: "0 0 40px 0",
        lineHeight: "34px",
      }}>
        Velkommen til<br />JourneyMate
      </h1>

      {/* Mascot */}
      <img
        src="../../FF-pages-images/journeymate_mascot.png"
        alt="JourneyMate maskot"
        style={{
          width: 180,
          height: 180,
          objectFit: "contain",
          margin: "0 0 40px 0",
        }}
      />

      {/* Tagline (English) */}
      <div style={{
        fontSize: 18,
        fontWeight: 500,
        color: "#0f0f0f",
        textAlign: "center",
        margin: "0 0 12px 0",
      }}>
        Go out, your way.
      </div>

      {/* Description (Danish) */}
      <p style={{
        fontSize: 14,
        fontWeight: 400,
        color: "#555",
        textAlign: "center",
        lineHeight: "20px",
        margin: "0 0 48px 0",
        maxWidth: 320,
      }}>
        Opdag restauranter, caféer og barer filtreret efter din livsstil, præferencer og kostbehov.
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
        }}
      >
        Fortsæt
      </button>
    </div>
  );
}
