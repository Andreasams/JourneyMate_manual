// ============================================================
// CONTACT COPY SUCCESS POPUP
// Small success toast shown after copying contact info
// Props: visible (boolean), message (string)
// ============================================================

import { GREEN } from "../../shared/_shared.jsx";

export default function ContactCopyPopup({ visible, message = "Kopieret til udklipsholder" }) {
  if (!visible) return null;

  return (
    <div style={{
      position: "fixed",
      bottom: 100,
      left: "50%",
      transform: "translateX(-50%)",
      background: GREEN,
      color: "#fff",
      padding: "12px 20px",
      borderRadius: 10,
      fontSize: 14,
      fontWeight: 500,
      boxShadow: "0 4px 16px rgba(0,0,0,0.15)",
      zIndex: 9999,
      animation: visible ? "fadeInUp 0.3s ease" : "none",
    }}>
      {message}

      <style>{`
        @keyframes fadeInUp {
          from {
            opacity: 0;
            transform: translate(-50%, 10px);
          }
          to {
            opacity: 1;
            transform: translate(-50%, 0);
          }
        }
      `}</style>
    </div>
  );
}
