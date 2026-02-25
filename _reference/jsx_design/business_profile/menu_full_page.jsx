// ============================================================
// MENU FULL PAGE
// Expanded menu view with category navigation and dietary filters
// Props: restaurant (object), onBack (function), onItemClick (function)
// ============================================================

import { useState } from "react";
import { StatusBar, ACCENT } from "../../shared/_shared.jsx";

export default function MenuFullPage({ restaurant, onBack, onItemClick }) {
  const [activeCat, setActiveCat] = useState("Burger");
  const [filterOpen, setFilterOpen] = useState(false);
  const [selectedRestrictions, setSelectedRestrictions] = useState(new Set());
  const [selectedPreferences, setSelectedPreferences] = useState(new Set());
  const [selectedAllergens, setSelectedAllergens] = useState(new Set(["Blødyr", "Fisk", "Jordnødder"]));

  const categories = restaurant.menuCategories || ["Mød", "Drikke", "Burger", "Poké bowls", "Classic bowls", "Sand"];

  const restrictions = ["Glutenfrit", "Laktosefrit"];
  const preferences = ["Pescetarianligt", "Vegansk", "Vegetarisk"];
  const allergens = ["Blødyr", "Fisk", "Jordnødder", "Korn med..."];

  const toggleFilter = (set, setter, value) => {
    const newSet = new Set(set);
    newSet.has(value) ? newSet.delete(value) : newSet.add(value);
    setter(newSet);
  };

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
          {restaurant.name}
        </div>
      </div>

      {/* Scrollable content */}
      <div style={{
        height: 730,
        overflowY: "scroll",
      }}>
        <div style={{ padding: "16px 20px" }}>
          {/* Menu heading and last updated */}
          <div style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "flex-start",
            marginBottom: 8,
          }}>
            <h2 style={{
              fontSize: 18,
              fontWeight: 680,
              color: "#0f0f0f",
              margin: 0,
            }}>
              Menu
            </h2>
            <div style={{
              fontSize: 11,
              color: "#888",
              textAlign: "right",
            }}>
              Sidst ajurført den {restaurant.menuLastReviewed || "15. december 2025"}
            </div>
          </div>

          {/* Filter toggle */}
          <div
            onClick={() => setFilterOpen(!filterOpen)}
            style={{
              fontSize: 13,
              fontWeight: 500,
              color: ACCENT,
              cursor: "pointer",
              marginBottom: 16,
            }}
          >
            {filterOpen ? "Skjul filtre" : "Vis filtre"}
          </div>

          {/* Filter panel */}
          {filterOpen && (
            <div style={{
              background: "#fafafa",
              borderRadius: 12,
              padding: 16,
              marginBottom: 16,
            }}>
              <div style={{
                fontSize: 15,
                fontWeight: 600,
                color: "#0f0f0f",
                marginBottom: 12,
              }}>
                Filtre
              </div>

              {/* Restrictions */}
              <div style={{ marginBottom: 16 }}>
                <div style={{
                  fontSize: 13,
                  fontWeight: 500,
                  color: "#555",
                  marginBottom: 6,
                }}>
                  Kostrestriktioner
                </div>
                <div style={{
                  fontSize: 12,
                  color: "#888",
                  marginBottom: 8,
                  lineHeight: "16px",
                }}>
                  Vis kun retter, der overholder den valgte kostrestriktion.
                </div>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                  {restrictions.map(r => (
                    <div
                      key={r}
                      onClick={() => toggleFilter(selectedRestrictions, setSelectedRestrictions, r)}
                      style={{
                        padding: "7px 12px",
                        borderRadius: 10,
                        fontSize: 12.5,
                        fontWeight: 540,
                        background: selectedRestrictions.has(r) ? ACCENT : "#fff",
                        color: selectedRestrictions.has(r) ? "#fff" : "#555",
                        border: `1px solid ${selectedRestrictions.has(r) ? ACCENT : "#e8e8e8"}`,
                        cursor: "pointer",
                      }}
                    >
                      {r}
                    </div>
                  ))}
                </div>
              </div>

              {/* Preferences */}
              <div style={{ marginBottom: 16 }}>
                <div style={{
                  fontSize: 13,
                  fontWeight: 500,
                  color: "#555",
                  marginBottom: 6,
                }}>
                  Kostpræferencer
                </div>
                <div style={{
                  fontSize: 12,
                  color: "#888",
                  marginBottom: 8,
                  lineHeight: "16px",
                }}>
                  Vis kun retter, der overholder den valgte diæt.
                </div>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                  {preferences.map(p => (
                    <div
                      key={p}
                      onClick={() => toggleFilter(selectedPreferences, setSelectedPreferences, p)}
                      style={{
                        padding: "7px 12px",
                        borderRadius: 10,
                        fontSize: 12.5,
                        fontWeight: 540,
                        background: selectedPreferences.has(p) ? ACCENT : "#fff",
                        color: selectedPreferences.has(p) ? "#fff" : "#555",
                        border: `1px solid ${selectedPreferences.has(p) ? ACCENT : "#e8e8e8"}`,
                        cursor: "pointer",
                      }}
                    >
                      {p}
                    </div>
                  ))}
                </div>
              </div>

              {/* Allergens */}
              <div>
                <div style={{
                  fontSize: 13,
                  fontWeight: 500,
                  color: "#555",
                  marginBottom: 6,
                }}>
                  Allergener
                </div>
                <div style={{
                  fontSize: 12,
                  color: "#888",
                  marginBottom: 8,
                  lineHeight: "16px",
                }}>
                  Skjul retter, der indeholder det valgte allergen.
                </div>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
                  {allergens.map(a => (
                    <div
                      key={a}
                      onClick={() => toggleFilter(selectedAllergens, setSelectedAllergens, a)}
                      style={{
                        padding: "7px 12px",
                        borderRadius: 10,
                        fontSize: 12.5,
                        fontWeight: 540,
                        background: selectedAllergens.has(a) ? ACCENT : "#fff",
                        color: selectedAllergens.has(a) ? "#fff" : "#555",
                        border: `1px solid ${selectedAllergens.has(a) ? ACCENT : "#e8e8e8"}`,
                        cursor: "pointer",
                      }}
                    >
                      {a}
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* Category chips */}
          <div style={{
            display: "flex",
            gap: 8,
            overflowX: "auto",
            marginBottom: 20,
            paddingBottom: 4,
          }}>
            {categories.map(cat => (
              <div
                key={cat}
                onClick={() => setActiveCat(cat)}
                style={{
                  padding: "7px 14px",
                  borderRadius: 10,
                  fontSize: 13,
                  fontWeight: 580,
                  background: activeCat === cat ? ACCENT : "#fff",
                  color: activeCat === cat ? "#fff" : "#555",
                  border: `1px solid ${activeCat === cat ? ACCENT : "#e8e8e8"}`,
                  cursor: "pointer",
                  whiteSpace: "nowrap",
                }}
              >
                {cat}
              </div>
            ))}
          </div>

          {/* Menu section */}
          <div style={{ marginBottom: 24 }}>
            <h3 style={{
              fontSize: 16,
              fontWeight: 630,
              color: "#0f0f0f",
              margin: "0 0 8px 0",
            }}>
              {activeCat}
            </h3>

            {activeCat === "Burger" && (
              <div style={{
                fontSize: 12,
                color: "#888",
                marginBottom: 16,
                display: "flex",
                alignItems: "center",
                gap: 4,
              }}>
                Vælg mellem fuldkorn eller glutenfri bolle (+ 10 kr.)
                <span style={{
                  width: 14,
                  height: 14,
                  borderRadius: "50%",
                  border: "1px solid #888",
                  display: "inline-flex",
                  alignItems: "center",
                  justifyContent: "center",
                  fontSize: 10,
                }}>
                  i
                </span>
              </div>
            )}

            {/* Menu items */}
            {restaurant.menuItems && restaurant.menuItems
              .filter(item => item.category === activeCat)
              .map((item, i) => (
                <div
                  key={i}
                  onClick={() => onItemClick && onItemClick(item)}
                  style={{
                    marginBottom: 20,
                    cursor: "pointer",
                  }}
                >
                  <div style={{
                    fontSize: 15,
                    fontWeight: 590,
                    color: "#0f0f0f",
                    marginBottom: 4,
                  }}>
                    {item.name}
                  </div>
                  <p style={{
                    fontSize: 13,
                    fontWeight: 400,
                    color: "#555",
                    lineHeight: "18px",
                    margin: "0 0 6px 0",
                  }}>
                    {item.description}
                  </p>
                  <div style={{
                    fontSize: 13.5,
                    fontWeight: 540,
                    color: ACCENT,
                  }}>
                    {item.price}
                  </div>
                </div>
              ))}
          </div>
        </div>
      </div>
    </div>
  );
}
