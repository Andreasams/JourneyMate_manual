// ============================================================
// SHARE FEEDBACK FORM
// Form to share feedback about the app
// Props: onBack (function), onSubmit (function)
// ============================================================

import { useState } from "react";
import { StatusBar, ACCENT } from "../../shared/_shared.jsx";

export default function ShareFeedbackForm({ onBack, onSubmit }) {
  const [category, setCategory] = useState(null);
  const [message, setMessage] = useState("");
  const [allowContact, setAllowContact] = useState(false);
  const [name, setName] = useState("");
  const [contact, setContact] = useState("");

  const categories = [
    "Wrong information",
    "Ideas for the app",
    "Bug",
    "Missing a place",
    "Suggestion",
    "Praise",
    "Something else",
  ];

  const handleSubmit = () => {
    if (category && message.trim()) {
      const feedback = {
        category,
        message,
        ...(allowContact && { name, contact }),
      };
      onSubmit(feedback);
      // Reset form
      setCategory(null);
      setMessage("");
      setAllowContact(false);
      setName("");
      setContact("");
    }
  };

  const isValid = category && message.trim();

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
          Share feedback
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
          margin: "0 0 8px 0",
        }}>
          Share your feedback
        </h2>

        {/* Description */}
        <p style={{
          fontSize: 14,
          fontWeight: 400,
          color: "#555",
          lineHeight: "20px",
          margin: "0 0 24px 0",
        }}>
          Your input helps us improve the app and make it better for everyone.
        </p>

        {/* Category selection */}
        <div style={{ marginBottom: 24 }}>
          <label style={{
            fontSize: 14,
            fontWeight: 500,
            color: "#0f0f0f",
            display: "block",
            marginBottom: 4,
          }}>
            What is your feedback about? <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <div style={{
            fontSize: 12,
            color: "#888",
            marginBottom: 12,
          }}>
            Pick the one that fits best.
          </div>
          <div style={{
            display: "flex",
            flexWrap: "wrap",
            gap: 8,
          }}>
            {categories.map(cat => (
              <div
                key={cat}
                onClick={() => setCategory(cat)}
                onMouseEnter={(e) => {
                  if (category !== cat) {
                    e.currentTarget.style.background = "#f9f9f9";
                  }
                }}
                onMouseLeave={(e) => {
                  if (category !== cat) {
                    e.currentTarget.style.background = "#fff";
                  }
                }}
                style={{
                  padding: "8px 14px",
                  borderRadius: 10,
                  fontSize: 13,
                  fontWeight: 540,
                  background: category === cat ? ACCENT : "#fff",
                  color: category === cat ? "#fff" : "#555",
                  border: `1px solid ${category === cat ? ACCENT : "#e8e8e8"}`,
                  cursor: "pointer",
                  transition: "background 0.2s ease",
                }}
              >
                {cat}
              </div>
            ))}
          </div>
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
            Tell us more <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <div style={{
            fontSize: 12,
            color: "#888",
            marginBottom: 8,
          }}>
            Please describe your feedback in detail. The more information you provide, the better we can help.
          </div>
          <textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
            onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
            placeholder="Share your thoughts, suggestions, or concerns..."
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

        {/* Contact permission */}
        <div style={{ marginBottom: 24 }}>
          <label style={{
            display: "flex",
            alignItems: "flex-start",
            gap: 12,
            cursor: "pointer",
          }}>
            <input
              type="checkbox"
              checked={allowContact}
              onChange={(e) => setAllowContact(e.target.checked)}
              style={{
                marginTop: 2,
                width: 18,
                height: 18,
                cursor: "pointer",
              }}
            />
            <div>
              <div style={{
                fontSize: 14,
                fontWeight: 500,
                color: "#0f0f0f",
                marginBottom: 4,
              }}>
                May we contact you?
              </div>
              <div style={{
                fontSize: 12,
                color: "#888",
                lineHeight: "16px",
              }}>
                If you would like us to follow up with you, please tick this box and provide your details below.
              </div>
            </div>
          </label>
        </div>

        {/* Conditional contact fields */}
        {allowContact && (
          <>
            <div style={{ marginBottom: 20 }}>
              <label style={{
                fontSize: 14,
                fontWeight: 500,
                color: "#0f0f0f",
                display: "block",
                marginBottom: 8,
              }}>
                Your name
              </label>
              <input
                type="text"
                value={name}
                onChange={(e) => setName(e.target.value)}
                onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
                onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
                placeholder="Enter your name"
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

            <div style={{ marginBottom: 24 }}>
              <label style={{
                fontSize: 14,
                fontWeight: 500,
                color: "#0f0f0f",
                display: "block",
                marginBottom: 4,
              }}>
                Contact information
              </label>
              <div style={{
                fontSize: 12,
                color: "#888",
                marginBottom: 8,
              }}>
                Please provide an email address or phone number so we can reach you.
              </div>
              <input
                type="text"
                value={contact}
                onChange={(e) => setContact(e.target.value)}
                onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
                onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
                placeholder="Email or phone number"
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
          </>
        )}

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
          Send feedback
        </button>
      </div>
    </div>
  );
}
