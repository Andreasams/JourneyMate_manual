// ============================================================
// GALLERY FULL PAGE
// Full-screen photo gallery with tabbed categories
// Props: restaurant (object), onBack (function)
// ============================================================

import { useState } from "react";
import { StatusBar, ACCENT } from "../../shared/_shared.jsx";

export default function GalleryFullPage({ restaurant, onBack }) {
  const [activeTab, setActiveTab] = useState("Mad");

  const tabs = ["Mad", "Menu", "Inde", "Ude"];

  // Mock gallery data - in production this would come from restaurant object
  const galleryImages = {
    Mad: Array(12).fill(null).map((_, i) => ({ id: i, bg: "#d0d0d0" })),
    Menu: Array(8).fill(null).map((_, i) => ({ id: i, bg: "#c0c0c0" })),
    Inde: Array(6).fill(null).map((_, i) => ({ id: i, bg: "#b0b0b0" })),
    Ude: Array(10).fill(null).map((_, i) => ({ id: i, bg: "#a0a0a0" })),
  };

  const images = galleryImages[activeTab] || [];

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
          Galleri
        </div>
      </div>

      {/* Tabs */}
      <div style={{
        display: "flex",
        borderBottom: "1px solid #f2f2f2",
        padding: "0 20px",
      }}>
        {tabs.map(tab => (
          <div
            key={tab}
            onClick={() => setActiveTab(tab)}
            style={{
              flex: 1,
              textAlign: "center",
              padding: "12px 0",
              fontSize: 14,
              fontWeight: activeTab === tab ? 600 : 500,
              color: activeTab === tab ? ACCENT : "#888",
              cursor: "pointer",
              borderBottom: activeTab === tab ? `2px solid ${ACCENT}` : "2px solid transparent",
              marginBottom: -1,
            }}
          >
            {tab}
          </div>
        ))}
      </div>

      {/* Gallery grid */}
      <div style={{
        height: 670,
        overflowY: "scroll",
        padding: "16px 20px",
      }}>
        <div style={{
          display: "grid",
          gridTemplateColumns: "repeat(3, 1fr)",
          gap: 8,
        }}>
          {images.map((img, i) => (
            <div
              key={i}
              style={{
                width: "100%",
                paddingTop: "100%",
                background: img.bg,
                borderRadius: 8,
                position: "relative",
                cursor: "pointer",
              }}
            >
              {/* Image content would go here */}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
