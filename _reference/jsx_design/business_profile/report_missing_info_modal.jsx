// ============================================================
// REPORT MISSING INFORMATION MODAL
// Modal for reporting incorrect/missing business information
// Props: visible (boolean), onClose (function), restaurant (object), onSubmit (function)
// ============================================================

import { useState } from "react";
import { ACCENT } from "../../shared/_shared.jsx";

export default function ReportMissingInfoModal({ visible, onClose, restaurant, onSubmit }) {
  const [message, setMessage] = useState("");

  if (!visible || !restaurant) return null;

  const handleSubmit = () => {
    if (message.trim()) {
      onSubmit({ restaurant: restaurant.name, message });
      setMessage("");
      onClose();
    }
  };

  return (<>
    {/* Backdrop */}
    <div
      onClick={onClose}
      style={{
        position: "fixed",
        inset: 0,
        background: "rgba(0,0,0,0.4)",
        zIndex: 9998,
      }}
    />

    {/* Modal */}
    <div style={{
      position: "fixed",
      top: "50%",
      left: "50%",
      transform: "translate(-50%, -50%)",
      width: "min(90%, 360px)",
      maxHeight: "70vh",
      background: "#fff",
      borderRadius: 16,
      zIndex: 9999,
      display: "flex",
      flexDirection: "column",
      boxShadow: "0 8px 32px rgba(0,0,0,0.12)",
    }}>
      {/* Close button - top right */}
      <button
        onClick={onClose}
        style={{
          position: "absolute",
          top: 12,
          right: 12,
          width: 32,
          height: 32,
          border: "none",
          background: "transparent",
          fontSize: 18,
          color: "#999",
          cursor: "pointer",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          borderRadius: "50%",
          transition: "background 0.2s",
        }}
        onMouseEnter={(e) => e.target.style.background = "#f5f5f5"}
        onMouseLeave={(e) => e.target.style.background = "transparent"}
      >
        ✕
      </button>

      {/* Content */}
      <div style={{
        padding: "24px 24px 24px",
        overflowY: "auto",
      }}>
        {/* Title */}
        <h3 style={{
          fontSize: 18,
          fontWeight: 680,
          color: "#0f0f0f",
          margin: "0 0 12px 0",
          paddingRight: 32,
        }}>
          Report incorrect information
        </h3>

        {/* Restaurant info */}
        <div style={{
          fontSize: 12,
          color: "#888",
          marginBottom: 2,
        }}>
          Reporting information for
        </div>
        <div style={{
          fontSize: 14,
          fontWeight: 500,
          color: "#0f0f0f",
          marginBottom: 1,
        }}>
          {restaurant.name}
        </div>
        <div style={{
          fontSize: 12,
          color: "#888",
          marginBottom: 16,
        }}>
          {restaurant.address}
        </div>

        {/* Help text */}
        <p style={{
          fontSize: 13,
          color: "#555",
          lineHeight: "18px",
          margin: "0 0 16px 0",
        }}>
          Help us keep information accurate. Please let us know what needs to be corrected.
        </p>

        {/* Form label */}
        <label style={{
          fontSize: 13,
          fontWeight: 500,
          color: "#0f0f0f",
          display: "block",
          marginBottom: 4,
        }}>
          What is incorrect or missing? <span style={{ color: "#c9403a" }}>*</span>
        </label>

        <div style={{
          fontSize: 11,
          color: "#888",
          marginBottom: 8,
        }}>
          Please describe what information is wrong/missing and what it should be instead
        </div>

        {/* Text area */}
        <textarea
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="Describe the incorrect information..."
          style={{
            width: "100%",
            minHeight: 100,
            padding: 12,
            fontSize: 14,
            color: "#0f0f0f",
            background: "#f5f5f5",
            border: "1px solid #e8e8e8",
            borderRadius: 10,
            resize: "vertical",
            fontFamily: "inherit",
            marginBottom: 16,
          }}
        />

        {/* Submit button */}
        <button
          onClick={handleSubmit}
          disabled={!message.trim()}
          style={{
            width: "100%",
            height: 50,
            background: message.trim() ? ACCENT : "#ddd",
            color: "#fff",
            border: "none",
            borderRadius: 12,
            fontSize: 16,
            fontWeight: 600,
            cursor: message.trim() ? "pointer" : "not-allowed",
          }}
        >
          Submit report
        </button>
      </div>
    </div>
  </>);
}
