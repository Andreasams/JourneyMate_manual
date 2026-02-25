// ============================================================
// MENU ITEM DETAIL OVERLAY
// Expandable overlay showing full menu item details
// Props: visible (boolean), onClose (function), item (object)
// ============================================================

import { useState } from "react";
import { ACCENT } from "../../shared/_shared.jsx";

export default function MenuItemDetailOverlay({ visible, onClose, item }) {
  const [language, setLanguage] = useState("da");
  const [currency, setCurrency] = useState("DKK");
  const [reminderOpen, setReminderOpen] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);

  if (!visible || !item) return null;

  const translations = {
    da: {
      additionalInfo: "Yderligere Information",
      dietary: "Kostpræferencer og restriktioner",
      allergens: "Allergener",
      reminder: "Påmindelse",
      reminderText1: "Husk altid at bekræfte ingrediens- og kostoplysninger med personalet, inden du bestiller. Ingredienser, opskrifter og personale kan ændre sig, og krydskontaminering kan forekomme.",
      reminderText2: "JourneyMate kan ikke garantere nøjagtigheden af disse oplysninger. Ved alvorlige allergier eller diætbehov, kontakt venligst restauranten direkte.",
    },
    en: {
      additionalInfo: "Additional Information",
      dietary: "Dietary preferences and restrictions",
      allergens: "Allergens",
      reminder: "Reminder",
      reminderText1: "Always verify ingredient and dietary information with staff before ordering. Ingredients, recipes, and staff can change, and cross-contamination may occur.",
      reminderText2: "JourneyMate cannot guarantee the accuracy of this information. For severe allergies or dietary requirements, please contact the restaurant directly.",
    },
  };

  const t = translations[language];

  // Convert price based on currency
  const convertPrice = (priceStr) => {
    const basePrice = parseFloat(priceStr.replace(/[^\d.]/g, ""));
    if (currency === "USD") return `$${(basePrice / 7.5).toFixed(0)}`;
    if (currency === "GBP") return `£${(basePrice / 9).toFixed(0)}`;
    return priceStr;
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

    {/* Overlay */}
    <div style={{
      position: "fixed",
      top: "8%",
      left: "50%",
      transform: "translateX(-50%)",
      width: "min(92%, 400px)",
      maxHeight: "84vh",
      background: "#fff",
      borderRadius: 16,
      zIndex: 9999,
      display: "flex",
      flexDirection: "column",
    }}>
      {/* Drag handle */}
      <div style={{
        width: 36,
        height: 4,
        borderRadius: 4,
        background: "#ddd",
        margin: "12px auto 0",
      }} />

      {/* Header buttons */}
      <div style={{
        display: "flex",
        justifyContent: "space-between",
        padding: "12px 16px 0",
      }}>
        <button
          onClick={onClose}
          style={{
            width: 32,
            height: 32,
            border: "none",
            background: "transparent",
            fontSize: 20,
            color: "#0f0f0f",
            cursor: "pointer",
          }}
        >
          ✕
        </button>

        {/* Three-dot menu */}
        <div style={{ position: "relative" }}>
          <button
            onClick={() => setMenuOpen(!menuOpen)}
            style={{
              width: 32,
              height: 32,
              border: "none",
              background: "transparent",
              fontSize: 20,
              color: "#0f0f0f",
              cursor: "pointer",
            }}
          >
            ⋯
          </button>

          {menuOpen && (
            <div style={{
              position: "absolute",
              top: 36,
              right: 0,
              background: "#fff",
              border: "1px solid #e8e8e8",
              borderRadius: 10,
              boxShadow: "0 4px 12px rgba(0,0,0,0.08)",
              zIndex: 100,
              minWidth: 220,
            }}>
              <div
                onClick={() => {
                  setLanguage("da");
                  setMenuOpen(false);
                }}
                style={{
                  padding: "12px 16px",
                  cursor: "pointer",
                  background: language === "da" ? "#fef8f2" : "#fff",
                  borderBottom: "1px solid #f2f2f2",
                  fontSize: 14,
                }}
              >
                View dish in Danish
              </div>
              <div
                onClick={() => {
                  setLanguage("en");
                  setMenuOpen(false);
                }}
                style={{
                  padding: "12px 16px",
                  cursor: "pointer",
                  background: language === "en" ? "#fef8f2" : "#fff",
                  borderBottom: "1px solid #f2f2f2",
                  fontSize: 14,
                }}
              >
                View dish in English
              </div>
              <div
                onClick={() => {
                  setCurrency("USD");
                  setMenuOpen(false);
                }}
                style={{
                  padding: "12px 16px",
                  cursor: "pointer",
                  background: currency === "USD" ? "#fef8f2" : "#fff",
                  borderBottom: "1px solid #f2f2f2",
                  fontSize: 14,
                }}
              >
                View price in US Dollar ($)
              </div>
              <div
                onClick={() => {
                  setCurrency("GBP");
                  setMenuOpen(false);
                }}
                style={{
                  padding: "12px 16px",
                  cursor: "pointer",
                  background: currency === "GBP" ? "#fef8f2" : "#fff",
                  fontSize: 14,
                }}
              >
                View price in British Pound (£)
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Content */}
      <div style={{
        padding: "8px 24px 24px",
        overflowY: "auto",
      }}>
        {/* Item name */}
        <h3 style={{
          fontSize: 18,
          fontWeight: 630,
          color: "#0f0f0f",
          lineHeight: "24px",
          margin: "0 0 8px 0",
        }}>
          {language === "da" ? item.name : item.nameEn || item.name}
        </h3>

        {/* Price */}
        <div style={{
          fontSize: 15,
          fontWeight: 540,
          color: ACCENT,
          margin: "0 0 12px 0",
        }}>
          {convertPrice(item.price)}
        </div>

        {/* Description */}
        <p style={{
          fontSize: 14,
          fontWeight: 400,
          color: "#555",
          lineHeight: "20px",
          margin: "0 0 20px 0",
        }}>
          {language === "da" ? item.description : item.descriptionEn || item.description}
        </p>

        {/* Divider */}
        <div style={{
          height: 1,
          background: "#f2f2f2",
          margin: "0 0 20px 0",
        }} />

        {/* Additional Information */}
        <div style={{
          fontSize: 15,
          fontWeight: 600,
          color: "#0f0f0f",
          margin: "0 0 12px 0",
        }}>
          {t.additionalInfo}
        </div>

        {/* Dietary preferences */}
        {item.dietary && (
          <div style={{ marginBottom: 16 }}>
            <div style={{
              fontSize: 13,
              fontWeight: 500,
              color: "#555",
              marginBottom: 4,
            }}>
              {t.dietary}
            </div>
            <div style={{
              fontSize: 13,
              fontWeight: 400,
              color: "#555",
            }}>
              {language === "da" ? item.dietary : item.dietaryEn || item.dietary}
            </div>
          </div>
        )}

        {/* Allergens */}
        {item.allergens && (
          <div style={{ marginBottom: 16 }}>
            <div style={{
              fontSize: 13,
              fontWeight: 500,
              color: "#555",
              marginBottom: 4,
            }}>
              {t.allergens}
            </div>
            <div style={{
              fontSize: 13,
              fontWeight: 400,
              color: "#555",
            }}>
              {language === "da" ? item.allergens : item.allergensEn || item.allergens}
            </div>
          </div>
        )}

        {/* Reminder expandable */}
        <div>
          <div
            onClick={() => setReminderOpen(!reminderOpen)}
            style={{
              display: "flex",
              justifyContent: "space-between",
              alignItems: "center",
              padding: "8px 0",
              cursor: "pointer",
            }}
          >
            <div style={{
              fontSize: 13,
              fontWeight: 500,
              color: "#555",
            }}>
              {t.reminder}
            </div>
            <span style={{ fontSize: 12, color: "#888" }}>
              {reminderOpen ? "▲" : "▼"}
            </span>
          </div>

          {reminderOpen && (
            <div style={{
              fontSize: 13,
              fontWeight: 400,
              color: "#555",
              lineHeight: "18px",
              paddingTop: 8,
            }}>
              <p style={{ margin: "0 0 12px 0" }}>
                {t.reminderText1}
              </p>
              <p style={{ margin: 0 }}>
                {t.reminderText2}
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  </>);
}
