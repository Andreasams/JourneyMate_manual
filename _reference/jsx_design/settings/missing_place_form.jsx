// ============================================================
// MISSING PLACE FORM
// Form to report missing businesses
// Props: onBack (function), onSubmit (function)
// ============================================================

import { useState } from "react";
import { StatusBar, ACCENT } from "../../shared/_shared.jsx";

export default function MissingPlaceForm({ onBack, onSubmit }) {
  const [name, setName] = useState("");
  const [address, setAddress] = useState("");
  const [message, setMessage] = useState("");

  const handleSubmit = () => {
    if (name.trim() && address.trim() && message.trim()) {
      onSubmit({ name, address, message });
      setName("");
      setAddress("");
      setMessage("");
    }
  };

  const isValid = name.trim() && address.trim() && message.trim();

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
          Are we missing a place?
        </div>
      </div>

      {/* Content */}
      <div style={{
        height: 730,
        overflowY: "scroll",
        padding: "24px",
      }}>
        {/* Heading */}
        <h2 style={{
          fontSize: 18,
          fontWeight: 680,
          color: "#0f0f0f",
          margin: "0 0 12px 0",
        }}>
          Missing a place?
        </h2>

        {/* Description */}
        <p style={{
          fontSize: 14,
          fontWeight: 400,
          color: "#555",
          lineHeight: "20px",
          margin: "0 0 24px 0",
        }}>
          If we are missing a place, we will be very happy to hear from you.
          <br /><br />
          To make it easier for us to add it sooner, please provide as much information as you can.
        </p>

        {/* Name field */}
        <div style={{ marginBottom: 20 }}>
          <label style={{
            fontSize: 14,
            fontWeight: 500,
            color: "#0f0f0f",
            display: "block",
            marginBottom: 8,
          }}>
            Name of the business <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <input
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
            onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
            placeholder="Enter business name"
            style={{
              width: "100%",
              height: 50,
              padding: "0 16px",
              fontSize: 14,
              color: "#0f0f0f",
              background: "#f5f5f5",
              border: "1px solid #e8e8e8",
              borderRadius: 10,
              fontFamily: "inherit",
              transition: "border-color 0.2s ease",
            }}
          />
        </div>

        {/* Address field */}
        <div style={{ marginBottom: 20 }}>
          <label style={{
            fontSize: 14,
            fontWeight: 500,
            color: "#0f0f0f",
            display: "block",
            marginBottom: 4,
          }}>
            Address of the business <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <div style={{
            fontSize: 12,
            color: "#888",
            marginBottom: 8,
          }}>
            In case other businesses share a similar name
          </div>
          <input
            type="text"
            value={address}
            onChange={(e) => setAddress(e.target.value)}
            onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
            onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
            placeholder="Enter full address"
            style={{
              width: "100%",
              height: 50,
              padding: "0 16px",
              fontSize: 14,
              color: "#0f0f0f",
              background: "#f5f5f5",
              border: "1px solid #e8e8e8",
              borderRadius: 10,
              fontFamily: "inherit",
              transition: "border-color 0.2s ease",
            }}
          />
        </div>

        {/* Message field */}
        <div style={{ marginBottom: 24 }}>
          <label style={{
            fontSize: 14,
            fontWeight: 500,
            color: "#0f0f0f",
            display: "block",
            marginBottom: 4,
          }}>
            Message <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <div style={{
            fontSize: 12,
            color: "#888",
            marginBottom: 8,
          }}>
            Message to the JourneyMate-team
          </div>
          <textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
            onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
            placeholder="Any additional details..."
            style={{
              width: "100%",
              minHeight: 120,
              padding: 12,
              fontSize: 14,
              color: "#0f0f0f",
              background: "#f5f5f5",
              border: "1px solid #e8e8e8",
              borderRadius: 10,
              resize: "vertical",
              fontFamily: "inherit",
              transition: "border-color 0.2s ease",
            }}
          />
        </div>

        {/* Submit button */}
        <button
          onClick={handleSubmit}
          disabled={!isValid}
          style={{
            width: "100%",
            height: 50,
            background: isValid ? ACCENT : "#ddd",
            color: "#fff",
            border: "none",
            borderRadius: 12,
            fontSize: 16,
            fontWeight: 600,
            cursor: isValid ? "pointer" : "not-allowed",
          }}
        >
          Submit
        </button>
      </div>
    </div>
  );
}
