// ============================================================
// PROFIL (USER PROFILE) PAGE
// User account and profile management
// Props: user (object), onNavigate (function), onLogout (function)
// ============================================================

import { StatusBar, ACCENT } from "../../shared/_shared.jsx";

export default function Profil({ user = {}, onNavigate, onLogout }) {
  const { name = "User", email = "user@example.com", avatar } = user;

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
        {/* Header with avatar */}
        <div style={{
          padding: "32px 20px",
          textAlign: "center",
          borderBottom: "1px solid #f2f2f2",
        }}>
          {/* Avatar */}
          <div style={{
            width: 80,
            height: 80,
            borderRadius: "50%",
            background: ACCENT,
            color: "#fff",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 32,
            fontWeight: 700,
            margin: "0 auto 16px",
          }}>
            {avatar || name.charAt(0).toUpperCase()}
          </div>

          {/* Name */}
          <h1 style={{
            fontSize: 22,
            fontWeight: 700,
            color: "#0f0f0f",
            margin: "0 0 4px 0",
          }}>
            {name}
          </h1>

          {/* Email */}
          <div style={{
            fontSize: 14,
            fontWeight: 400,
            color: "#888",
          }}>
            {email}
          </div>
        </div>

        {/* Account section */}
        <div style={{ padding: "24px 20px" }}>
          <div style={{
            fontSize: 14,
            fontWeight: 600,
            color: "#0f0f0f",
            marginBottom: 12,
          }}>
            Konto
          </div>

          <div
            onClick={() => onNavigate("edit-profile")}
            style={{
              padding: "14px 0",
              borderBottom: "1px solid #f2f2f2",
              cursor: "pointer",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
            }}
          >
            <span style={{ fontSize: 14, color: "#555" }}>Rediger profil</span>
            <span style={{ fontSize: 16, color: "#bbb" }}>›</span>
          </div>

          <div
            onClick={() => onNavigate("settings")}
            style={{
              padding: "14px 0",
              borderBottom: "1px solid #f2f2f2",
              cursor: "pointer",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
            }}
          >
            <span style={{ fontSize: 14, color: "#555" }}>Indstillinger</span>
            <span style={{ fontSize: 16, color: "#bbb" }}>›</span>
          </div>

          <div
            onClick={() => onNavigate("saved-places")}
            style={{
              padding: "14px 0",
              borderBottom: "1px solid #f2f2f2",
              cursor: "pointer",
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
            }}
          >
            <span style={{ fontSize: 14, color: "#555" }}>Gemte steder</span>
            <span style={{ fontSize: 16, color: "#bbb" }}>›</span>
          </div>
        </div>

        {/* Logout button */}
        <div style={{ padding: "0 20px 32px" }}>
          <button
            onClick={onLogout}
            style={{
              width: "100%",
              height: 50,
              background: "transparent",
              color: "#c9403a",
              border: "2px solid #c9403a",
              borderRadius: 12,
              fontSize: 16,
              fontWeight: 600,
              cursor: "pointer",
            }}
          >
            Log ud
          </button>
        </div>
      </div>

      {/* Bottom tab bar */}
      <div style={{
        position: "absolute",
        bottom: 0,
        left: 0,
        right: 0,
        height: 80,
        background: "#fff",
        borderTop: "1px solid #f2f2f2",
        display: "flex",
      }}>
        <div style={{
          flex: 1,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          cursor: "pointer",
        }}>
          <span style={{ fontSize: 24, marginBottom: 2 }}>🔍</span>
          <span style={{ fontSize: 11, color: "#888" }}>Udforsk</span>
        </div>
        <div style={{
          flex: 1,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          cursor: "pointer",
        }}>
          <span style={{ fontSize: 24, marginBottom: 2 }}>❤️</span>
          <span style={{ fontSize: 11, color: "#888" }}>Mine behov</span>
        </div>
        <div style={{
          flex: 1,
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          justifyContent: "center",
          cursor: "pointer",
        }}>
          <span style={{ fontSize: 24, marginBottom: 2 }}>👤</span>
          <span style={{ fontSize: 11, color: ACCENT, fontWeight: 600 }}>Profil</span>
        </div>
      </div>
    </div>
  );
}
