// ============================================================
// SEARCH NO RESULTS PAGE
// Empty state when search returns no matches
// Props: searchQuery (string), onClearSearch (function)
// ============================================================

import { StatusBar, ACCENT } from "../../shared/_shared.jsx";

export default function SearchNoResults({ searchQuery, onClearSearch }) {
  return (
    <div style={{
      width: 390,
      height: 844,
      background: "#fff",
      display: "flex",
      flexDirection: "column",
      alignItems: "center",
      justifyContent: "center",
      padding: "0 32px",
    }}>
      <StatusBar />

      {/* Empty state icon */}
      <div style={{
        width: 80,
        height: 80,
        borderRadius: "50%",
        background: "#f5f5f5",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        marginBottom: 24,
      }}>
        <span style={{ fontSize: 36, opacity: 0.5 }}>🔍</span>
      </div>

      {/* Heading */}
      <h2 style={{
        fontSize: 20,
        fontWeight: 680,
        color: "#0f0f0f",
        textAlign: "center",
        margin: "0 0 12px 0",
      }}>
        No search results
      </h2>

      {/* Description */}
      <p style={{
        fontSize: 14,
        fontWeight: 400,
        color: "#888",
        textAlign: "center",
        lineHeight: "20px",
        margin: "0 0 32px 0",
        maxWidth: 280,
      }}>
        We couldn't find any places matching "{searchQuery}". Try adjusting your search or filters.
      </p>

      {/* Clear search button */}
      {searchQuery && (
        <button
          onClick={onClearSearch}
          style={{
            padding: "12px 24px",
            background: "transparent",
            color: ACCENT,
            border: `2px solid ${ACCENT}`,
            borderRadius: 10,
            fontSize: 14,
            fontWeight: 600,
            cursor: "pointer",
          }}
        >
          Clear search
        </button>
      )}
    </div>
  );
}
