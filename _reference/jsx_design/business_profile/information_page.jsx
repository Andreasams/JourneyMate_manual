// ============================================================
// INFORMATION PAGE
// Detailed information page accessible from business profile
// Props: restaurant (object), onBack (function)
// ============================================================

import { useState } from "react";
import { StatusBar, ACCENT, GREEN, OpeningHoursSection } from "../../shared/_shared.jsx";

export default function InformationPage({ restaurant, onBack }) {

  return (
    <div style={{
      width: 390,
      height: 844,
      background: "#fff",
      overflow: "hidden",
      position: "relative",
    }}>
      <StatusBar />

      {/* Scrollable content */}
      <div style={{
        height: 790,
        overflowY: "scroll",
        paddingBottom: 40,
      }}>
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

        {/* Hero image placeholder */}
        <div style={{
          width: "100%",
          height: 180,
          background: "#d0d0d0",
        }} />

        {/* Content */}
        <div style={{ padding: "20px 24px" }}>
          {/* Name */}
          <h1 style={{
            fontSize: 24,
            fontWeight: 750,
            color: "#0f0f0f",
            margin: "0 0 6px 0",
          }}>
            {restaurant.name}
          </h1>

          {/* Status */}
          <div style={{
            display: "flex",
            alignItems: "center",
            gap: 6,
            marginBottom: 16,
          }}>
            <div style={{
              width: 6,
              height: 6,
              borderRadius: "50%",
              background: restaurant.statusOpen ? GREEN : "#c9403a",
            }} />
            <span style={{
              fontSize: 13,
              fontWeight: 460,
              color: "#555",
            }}>
              {restaurant.statusText}
            </span>
          </div>

          {/* About description */}
          {restaurant.about && (
            <p style={{
              fontSize: 14,
              fontWeight: 400,
              color: "#555",
              lineHeight: "20px",
              margin: "0 0 24px 0",
            }}>
              {restaurant.about}
            </p>
          )}

          {/* Opening hours expandable */}
          <OpeningHoursSection
            title="Åbningstider m.m."
            hours={restaurant.hours}
            contact={{ phone: restaurant.phone, links: restaurant.links }}
            variant="info"
          />

          {/* Facilities and services */}
          {restaurant.facilities && (
            <div style={{ marginBottom: 24 }}>
              <h3 style={{
                fontSize: 15,
                fontWeight: 600,
                color: "#0f0f0f",
                margin: "0 0 12px 0",
              }}>
                Faciliteter og services
              </h3>
              <div style={{
                display: "flex",
                flexWrap: "wrap",
                gap: 8,
              }}>
                {restaurant.facilities.map((fac, i) => (
                  <div
                    key={i}
                    style={{
                      padding: "7px 12px",
                      borderRadius: 10,
                      fontSize: 12.5,
                      fontWeight: 540,
                      background: "#fff",
                      color: "#555",
                      border: "1px solid #e8e8e8",
                    }}
                  >
                    {typeof fac === "string" ? fac : fac.l}
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Payment methods */}
          {restaurant.payments && (
            <div>
              <h3 style={{
                fontSize: 15,
                fontWeight: 600,
                color: "#0f0f0f",
                margin: "0 0 12px 0",
              }}>
                Betalingsmuligheder
              </h3>
              <div style={{
                display: "flex",
                flexWrap: "wrap",
                gap: 8,
              }}>
                {restaurant.payments.map((pay, i) => (
                  <div
                    key={i}
                    style={{
                      padding: "7px 12px",
                      borderRadius: 10,
                      fontSize: 12.5,
                      fontWeight: 540,
                      background: "#fff",
                      color: "#555",
                      border: "1px solid #e8e8e8",
                    }}
                  >
                    {pay}
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
