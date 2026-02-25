// ============================================================
// LOCATION SHARING PAGE
// Location permission management and explanation
// Props: onBack (function), onEnableLocation (function)
// ============================================================

import { StatusBar, ACCENT } from "../../shared/_shared.jsx";

export default function LocationSharingPage({ onBack, onEnableLocation }) {
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
          Location sharing
        </div>
      </div>

      {/* Content */}
      <div style={{
        padding: "32px 24px",
      }}>
        {/* Heading */}
        <h2 style={{
          fontSize: 22,
          fontWeight: 700,
          color: "#0f0f0f",
          margin: "0 0 16px 0",
          textAlign: "center",
        }}>
          Turn on location sharing
        </h2>

        {/* Description */}
        <p style={{
          fontSize: 14,
          fontWeight: 400,
          color: "#555",
          lineHeight: "20px",
          margin: "0 0 24px 0",
          textAlign: "center",
        }}>
          Allow JourneyMate to access your location to show nearby restaurants and provide better recommendations.
        </p>

        {/* CTA button */}
        <button
          onClick={onEnableLocation}
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
            marginBottom: 24,
          }}
        >
          Turn on location sharing
        </button>

        {/* Privacy info */}
        <div style={{
          fontSize: 13,
          fontWeight: 400,
          color: "#888",
          lineHeight: "18px",
          textAlign: "center",
        }}>
          We respect your privacy. Your location is only used to improve your experience and is never shared with third parties without your consent.
        </div>
      </div>
    </div>
  );
}
