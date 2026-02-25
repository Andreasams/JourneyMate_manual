// ============================================================
// CONTACT US FORM
// Form to contact JourneyMate support
// Props: onBack (function), onSubmit (function)
// ============================================================

import { useState } from "react";
import { StatusBar, ACCENT } from "../../shared/_shared.jsx";

export default function ContactUsForm({ onBack, onSubmit }) {
  const [fullName, setFullName] = useState("");
  const [contact, setContact] = useState("");
  const [subject, setSubject] = useState("");
  const [message, setMessage] = useState("");

  const handleSubmit = () => {
    if (fullName.trim() && contact.trim() && subject.trim() && message.trim()) {
      onSubmit({ fullName, contact, subject, message });
      setFullName("");
      setContact("");
      setSubject("");
      setMessage("");
    }
  };

  const isValid = fullName.trim() && contact.trim() && subject.trim() && message.trim();

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
          Contact us
        </div>
      </div>

      {/* Content */}
      <div style={{
        height: 730,
        overflowY: "scroll",
        padding: "24px",
      }}>
        {/* Full name */}
        <div style={{ marginBottom: 20 }}>
          <label style={{
            fontSize: 14,
            fontWeight: 500,
            color: "#0f0f0f",
            display: "block",
            marginBottom: 8,
          }}>
            Your full name <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <input
            type="text"
            value={fullName}
            onChange={(e) => setFullName(e.target.value)}
            onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
            onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
            placeholder="Enter your full name"
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

        {/* Email or phone */}
        <div style={{ marginBottom: 20 }}>
          <label style={{
            fontSize: 14,
            fontWeight: 500,
            color: "#0f0f0f",
            display: "block",
            marginBottom: 4,
          }}>
            Your email or phone number <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <div style={{
            fontSize: 12,
            color: "#888",
            marginBottom: 8,
          }}>
            Please provide either or both. Check for spelling mistakes before submitting.
          </div>
          <input
            type="text"
            value={contact}
            onChange={(e) => setContact(e.target.value)}
            onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
            onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
            placeholder="email@example.com or +45 12 34 56 78"
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

        {/* Subject */}
        <div style={{ marginBottom: 20 }}>
          <label style={{
            fontSize: 14,
            fontWeight: 500,
            color: "#0f0f0f",
            display: "block",
            marginBottom: 4,
          }}>
            Subject <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <div style={{
            fontSize: 12,
            color: "#888",
            marginBottom: 8,
          }}>
            Topic of what you would like to contact us about
          </div>
          <input
            type="text"
            value={subject}
            onChange={(e) => setSubject(e.target.value)}
            onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
            onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
            placeholder="Enter subject"
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

        {/* Message */}
        <div style={{ marginBottom: 24 }}>
          <label style={{
            fontSize: 14,
            fontWeight: 500,
            color: "#0f0f0f",
            display: "block",
            marginBottom: 8,
          }}>
            Message <span style={{ color: "#c9403a" }}>*</span>
          </label>
          <textarea
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onFocus={(e) => e.currentTarget.style.borderColor = ACCENT}
            onBlur={(e) => e.currentTarget.style.borderColor = "#e8e8e8"}
            placeholder="Type your message here..."
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
          Send message
        </button>
      </div>
    </div>
  );
}
