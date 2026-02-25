// ============================================================
// JOURNEYMATE — SEARCH PAGE (Udforsk)
// List view with filter sheet, needs picker, sort, and chip row.
// Props:
//   onSelect(restaurant)  — navigate to business profile
//   activeNeeds           — Set<string> of persistent needs
//   onToggleNeed(string)  — add/remove a need
//   onOpenNeedsPicker()   — open the needs picker sheet
// ============================================================

import { useState } from "react";
import {
  ACCENT, GREEN, GREEN_BG, GREEN_BORDER,
  filterSets, allRestaurants, trainStations,
  Dot, Check, StatusBar, BottomSheet, TabBar,
} from "../../shared/_shared.jsx";

// ── Sort options ─────────────────────────────────────────────
const SORT_OPTIONS = [
  {key:"match",      label:"Bedst match",     icon:"★"},
  {key:"nearest",    label:"Nærmest",         icon:"↕"},
  {key:"station",    label:"Nærmest togstation", icon:"🚉", hasSubmenu:true},
  {key:"price_low",  label:"Pris: Lav til høj",icon:"↑"},
  {key:"price_high", label:"Pris: Høj til lav",icon:"↓"},
  {key:"newest",     label:"Nyeste",          icon:"✦"},
];

// ── Filter sheet (three-column tabs) ─────────────────────────
function FilterSheet({initialTab, selectedFilters, onToggle, onClose, visible, resultCount, onReset, activeNeeds}) {
  const tabs = ["Lokation","Type","Behov"];
  const [activeTab, setActiveTab] = useState(initialTab || tabs[0]);
  const data = filterSets[activeTab];
  const pk   = Object.keys(data);
  const [ap, setAp] = useState(pk[0]);
  const [ai, setAi] = useState(data[pk[0]]?.items?.[0] || "");

  const switchTab = (t) => {
    setActiveTab(t);
    const d = filterSets[t];
    const p = Object.keys(d);
    setAp(p[0]);
    setAi(d[p[0]]?.items?.[0] || "");
  };

  const curData = filterSets[activeTab];
  const curPk   = Object.keys(curData);
  const items   = curData[ap]?.items || [];
  const subs    = curData[ap]?.subs?.[ai] || [];

  // An item counts as selected if it's in selectedFilters,
  // or (Behov tab only) if it's in activeNeeds
  const isSel = (x) => selectedFilters.has(x) || (activeTab === "Behov" && activeNeeds.has(x));

  const gpc = (p) => {
    const a = curData[p]?.items || [];
    const s = a.flatMap(it => curData[p]?.subs?.[it] || []);
    return [...a, ...s].filter(x => isSel(x)).length;
  };

  const getTabCount = (tab) => {
    const d = filterSets[tab]; let c = 0;
    Object.values(d).forEach(p => {
      p.items.forEach(it => { if (selectedFilters.has(it)) c++; });
      Object.values(p.subs || {}).forEach(sa => sa.forEach(s => { if (selectedFilters.has(s)) c++; }));
    });
    if (tab === "Behov") [...activeNeeds].forEach(n => { if (!selectedFilters.has(n)) c++; });
    return c;
  };

  return (
    <BottomSheet visible={visible} onClose={onClose} height="78%">
      {/* Tab bar — widths match columns: 36% / 33% / 31% */}
      <div style={{display:"flex",borderBottom:"1px solid #f0f0f0",flexShrink:0}}>
        {tabs.map((t, ti) => {
          const isA = activeTab === t;
          const cnt = getTabCount(t);
          const w   = ti === 0 ? "36%" : ti === 1 ? "33%" : "31%";
          return (
            <button key={t} onClick={() => switchTab(t)} style={{
              width:w, flexShrink:0, padding:"12px 0", background:"none", border:"none",
              cursor:"pointer", fontFamily:"inherit", fontSize:14,
              fontWeight:isA ? 640 : 480, color:isA ? ACCENT : "#888",
              borderBottom:isA ? `2.5px solid ${ACCENT}` : "2.5px solid transparent",
              textAlign:"center", display:"flex", alignItems:"center", justifyContent:"center", gap:5,
            }}>
              {t}
              {cnt > 0 && (
                <span style={{
                  fontSize:10, fontWeight:700, color:"#fff",
                  background:isA ? ACCENT : "#bbb",
                  width:18, height:18, minWidth:18, minHeight:18,
                  borderRadius:"50%", display:"inline-flex", alignItems:"center",
                  justifyContent:"center", lineHeight:1,
                }}>{cnt}</span>
              )}
            </button>
          );
        })}
      </div>

      {/* Three-column content — fixed widths, no layout shift on tab switch */}
      <div style={{display:"flex",flex:1,minHeight:0}}>
        {/* Column 1 — category groups (36%) */}
        <div style={{width:"36%",borderRight:"1px solid #f0f0f0",overflowY:"auto",background:"#fafafa",padding:"6px 0",flexShrink:0}}>
          {curPk.map(p => {
            const active = ap === p;
            const cnt    = gpc(p);
            return (
              <button key={p} onClick={() => { setAp(p); setAi(curData[p]?.items?.[0] || ""); }} style={{
                display:"flex", alignItems:"center", justifyContent:"space-between",
                width:"100%", textAlign:"left", padding:"11px 10px 11px 14px",
                border:"none", background:active ? "#fff" : "transparent",
                fontSize:13, fontWeight:active ? 620 : 440, color:active ? ACCENT : "#777",
                cursor:"pointer", fontFamily:"inherit",
                borderLeft:active ? `2.5px solid ${ACCENT}` : "2.5px solid transparent",
                lineHeight:1.35,
              }}>
                <span>{p}</span>
                {cnt > 0 && (
                  <span style={{fontSize:10,fontWeight:700,color:"#fff",background:ACCENT,width:18,height:18,minWidth:18,minHeight:18,borderRadius:"50%",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,lineHeight:1}}>{cnt}</span>
                )}
              </button>
            );
          })}
        </div>

        {/* Column 2 — items with checkboxes (33%) */}
        <div style={{width:"33%",borderRight:"1px solid #f0f0f0",overflowY:"auto",padding:"6px 0",flexShrink:0}}>
          {items.map(item => {
            const sel    = isSel(item);
            const active = ai === item;
            return (
              <button key={item} onClick={() => { setAi(item); onToggle(item); }} style={{
                display:"flex", alignItems:"center", gap:8, width:"100%", textAlign:"left",
                padding:"11px 12px", border:"none",
                background:active ? "#f8f8f8" : "transparent",
                fontSize:13, fontWeight:sel ? 620 : 440,
                color:sel ? "#0f0f0f" : "#777", cursor:"pointer", fontFamily:"inherit",
              }}>
                <span style={{width:18,height:18,borderRadius:5,border:sel?"none":"1.5px solid #ccc",background:sel?ACCENT:"#fff",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                  {sel && <Check/>}
                </span>
                {item}
              </button>
            );
          })}
        </div>

        {/* Column 3 — sub-items (31%) — always rendered to prevent layout shift */}
        <div style={{width:"31%",overflowY:"auto",padding:"6px 0",flexShrink:0}}>
          {subs.map(sub => {
            const sel = isSel(sub);
            return (
              <button key={sub} onClick={() => onToggle(sub)} style={{
                display:"flex", alignItems:"center", gap:7, width:"100%", textAlign:"left",
                padding:"10px 10px", border:"none", background:"transparent",
                fontSize:12, fontWeight:sel ? 600 : 420, color:sel ? "#0f0f0f" : "#888",
                cursor:"pointer", fontFamily:"inherit", lineHeight:1.35,
              }}>
                <span style={{width:16,height:16,borderRadius:4,border:sel?"none":"1.5px solid #ccc",background:sel?ACCENT:"#fff",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                  {sel && <Check size={9}/>}
                </span>
                {sub}
              </button>
            );
          })}
        </div>
      </div>

      {/* Footer */}
      <div style={{display:"flex",gap:10,padding:"14px 20px 32px",borderTop:"1px solid #f0f0f0",flexShrink:0}}>
        <button onClick={onReset} style={{flex:1,padding:"13px 0",borderRadius:12,border:"1.5px solid #e0e0e0",background:"#fff",fontSize:14,fontWeight:580,color:"#666",cursor:"pointer",fontFamily:"inherit"}}>Nulstil</button>
        <button onClick={onClose} style={{flex:2,padding:"13px 0",borderRadius:12,border:"none",background:ACCENT,fontSize:14,fontWeight:620,color:"#fff",cursor:"pointer",fontFamily:"inherit"}}>Se {resultCount} steder</button>
      </div>
    </BottomSheet>
  );
}

// ── Needs picker sheet ────────────────────────────────────────
function NeedsPicker({activeNeeds, onToggle, onClose, visible}) {
  const cats = {
    "Diæt":         ["Helt glutenfrit","Glutenfri muligheder","Fuldt vegansk","Veganske muligheder","Fuldt vegetarisk","Vegetariske muligheder","Laktosefri","Halal","Kosher","Pescetarisk"],
    "Tilgængelighed":["Kørestol","Elevator","Blindevenlig"],
    "Børn":         ["Børnestol","Puslerum","Legeplads","Børnemenu"],
    "Hunde":        ["Hunde tilladt inde","Hunde tilladt ude","Vandskål"],
    "Stemning":     ["Havudsigt","Tagterrasse","Ved vandet","Romantisk","Hyggelig"],
    "Udendørs":     ["Gårdhave","Fortov","Terrasse"],
  };
  const [ac, setAc] = useState("Diæt");

  return (
    <BottomSheet visible={visible} onClose={onClose} height="72%" zBase={30}>
      <div style={{padding:"4px 20px 14px",borderBottom:"1px solid #f0f0f0",flexShrink:0}}>
        <h3 style={{margin:0,fontSize:20,fontWeight:720,color:"#0f0f0f"}}>Dine behov</h3>
        <p style={{margin:"4px 0 0",fontSize:13,color:"#999"}}>Vælg hvad der er vigtigt — vi husker det</p>
      </div>
      <div style={{display:"flex",overflowX:"auto",borderBottom:"1px solid #f0f0f0",flexShrink:0,padding:"0 4px"}}>
        {Object.keys(cats).map(c => (
          <button key={c} onClick={() => setAc(c)} style={{
            flexShrink:0, padding:"11px 14px", background:"none", border:"none",
            cursor:"pointer", fontFamily:"inherit", fontSize:13,
            fontWeight:ac === c ? 620 : 460, color:ac === c ? ACCENT : "#888",
            borderBottom:ac === c ? `2.5px solid ${ACCENT}` : "2.5px solid transparent",
          }}>{c}</button>
        ))}
      </div>
      <div style={{flex:1,overflowY:"auto",padding:"16px 20px"}}>
        <div style={{display:"flex",flexWrap:"wrap",gap:10}}>
          {cats[ac].map(item => {
            const a = activeNeeds.has(item);
            return (
              <button key={item} onClick={() => onToggle(item)} style={{
                padding:"10px 16px", borderRadius:12, cursor:"pointer", fontFamily:"inherit",
                fontSize:14, fontWeight:a ? 600 : 460,
                background:a ? GREEN_BG : "#fff",
                border:a ? `1.5px solid ${GREEN_BORDER}` : "1.5px solid #e8e8e8",
                color:a ? GREEN : "#555",
                display:"flex", alignItems:"center", gap:8,
              }}>
                {a && <Check size={12} color={GREEN}/>}
                {item}
              </button>
            );
          })}
        </div>
      </div>
      <div style={{padding:"14px 20px 32px",borderTop:"1px solid #f0f0f0",flexShrink:0}}>
        <button onClick={onClose} style={{width:"100%",padding:"14px 0",borderRadius:14,border:"none",background:"#0f0f0f",fontSize:15,fontWeight:620,color:"#fff",cursor:"pointer",fontFamily:"inherit"}}>Gem mine behov</button>
      </div>
    </BottomSheet>
  );
}

// ── Restaurant card ───────────────────────────────────────────
function Card({r, i, onSelect, hasNeeds, variant}) {
  const [expanded, setExpanded] = useState(false);
  const closed = !r.statusOpen;

  // Today's hours — simplified to overall span for card preview
  const days = ["Søndag","Mandag","Tirsdag","Onsdag","Torsdag","Fredag","Lørdag"];
  const today      = days[new Date().getDay()];
  const todayEntry = (r.hours || []).find(([d]) => d === today);
  let todayStr = "";
  if (todayEntry) {
    if (typeof todayEntry[1] === "string") {
      todayStr = todayEntry[1];
    } else if (Array.isArray(todayEntry[1]) && todayEntry[1].length > 0) {
      const slots    = todayEntry[1];
      const firstOpen  = slots[0].time.split("–")[0];
      const lastClose  = slots[slots.length - 1].time.split("–")[1];
      todayStr = `${firstOpen}–${lastClose}`;
    }
  }

  const photos = ["#f0dcc8","#e8c8b8","#d4b8a0","#c0d8c8","#b0c8b8","#d8ccc0","#c8b8a8","#e0d0c0"];

  return (
    <div onClick={() => setExpanded(!expanded)} style={{
      padding:14, marginBottom:8, borderRadius:16, cursor:"pointer", background:"#fff",
      border: variant === "full"    ? `1.5px solid ${GREEN_BORDER}`
            : variant === "partial" ? "1.5px solid #f0dcc8"
            :                        "1.5px solid #e8e8e8",
      opacity:closed ? 0.5 : 1,
      animation:`cardIn 0.25s ease ${Math.min(i, 8) * 0.04}s both`,
    }}>
      {/* Base row */}
      <div style={{display:"flex",gap:12,alignItems:"flex-start"}}>
        <div style={{width:50,height:50,borderRadius:13,background:r.bg,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
          <span style={{color:"#fff",fontSize:15,fontWeight:700}}>{r.initial}</span>
        </div>
        <div style={{flex:1,minWidth:0}}>
          <div style={{display:"flex",justifyContent:"space-between",alignItems:"baseline",marginBottom:2}}>
            <span style={{fontSize:15.5,fontWeight:630,color:"#0f0f0f",overflow:"hidden",textOverflow:"ellipsis",whiteSpace:"nowrap",marginRight:8}}>{r.name}</span>
            <span style={{fontSize:12,color:"#aaa",fontWeight:500,flexShrink:0}}>{r.distance}</span>
          </div>
          <div style={{display:"flex",alignItems:"center",gap:6,marginBottom:2}}>
            <span style={{fontSize:12.5,fontWeight:560,color:closed?"#c9403a":"#2a9456"}}>{closed?"Lukket":"Åben"}</span>
            <Dot/><span style={{fontSize:12.5,color:"#999"}}>{r.statusText || `til ${r.closingTime}`}</span>
          </div>
          <div style={{display:"flex",alignItems:"center",gap:6}}>
            <span style={{fontSize:12.5,color:"#999"}}>{r.cuisine}</span>
            <Dot/>
            <span style={{fontSize:12.5,color:"#999"}}>{r.priceRange}</span>
          </div>
        </div>
      </div>

      {/* Partial match info box */}
      {hasNeeds && variant === "partial" && (
        <div style={{marginTop:10,padding:"9px 11px",borderRadius:10,background:"#fef8f2",display:"flex",alignItems:"flex-start",gap:8}}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={ACCENT} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{flexShrink:0,marginTop:1}}>
            <circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>
          </svg>
          <div style={{fontSize:12,color:"#555",lineHeight:1.4}}>
            <span style={{fontWeight:580}}>Matcher {r.matchCount}/{r.matchCount + r.missedNeeds.length}</span>
            {" · "}Mangler: {r.missedNeeds.join(", ")}
          </div>
        </div>
      )}

      {/* Expanded preview */}
      {expanded && (
        <div style={{marginTop:12,paddingTop:12,borderTop:"1px solid #f2f2f2"}}>
          <div style={{fontSize:12.5,color:"#888",marginBottom:4}}>{r.address}</div>
          {todayStr && (
            <div style={{fontSize:12.5,color:"#666",marginBottom:10}}>
              I dag: {todayStr === "Lukket"
                ? <span style={{color:"#c9403a"}}>{todayStr}</span>
                : todayStr}
            </div>
          )}
          <div style={{display:"flex",gap:4,overflowX:"auto",paddingBottom:4,margin:"0 -2px"}}>
            {photos.map((c, pi) => (
              <div key={pi} style={{width:80,height:60,borderRadius:8,background:c,flexShrink:0}}/>
            ))}
          </div>
          <button
            onClick={(e) => { e.stopPropagation(); onSelect(r); }}
            style={{display:"block",width:"100%",marginTop:10,padding:"9px 0",borderRadius:10,border:"1.5px solid #e8e8e8",background:"#fff",fontSize:12.5,fontWeight:560,color:"#555",cursor:"pointer",fontFamily:"inherit",textAlign:"center"}}
          >
            Se mere →
          </button>
        </div>
      )}

      {/* Collapse chevron */}
      {!expanded && (
        <div style={{display:"flex",justifyContent:"center",marginTop:6}}>
          <svg width="14" height="8" viewBox="0 0 14 8" fill="none" stroke="#ddd" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="M1 1l6 6 6-6"/>
          </svg>
        </div>
      )}
    </div>
  );
}

// ── Main search page ──────────────────────────────────────────
export default function SearchPage({onSelect, activeNeeds, onToggleNeed, onClearAllNeeds, onOpenNeedsPicker, onTabChange}) {
  const [activeSheet,      setActiveSheet]      = useState(null);
  const [sheetVisible,     setSheetVisible]     = useState(false);
  const [selectedFilters,  setSelectedFilters]  = useState(new Set());
  const [searchFocused,    setSearchFocused]    = useState(false);
  const [viewMode,         setViewMode]         = useState("liste");
  const [activeSort,       setActiveSort]       = useState("match");
  const [selectedStation,  setSelectedStation]  = useState(null);
  const [showOnlyOpen,     setShowOnlyOpen]     = useState(false);
  const [sortSheetView,    setSortSheetView]    = useState("options"); // "options" or "stations"
  const [sortSheetOpen,    setSortSheetOpen]    = useState(false);
  const [sortSheetVisible, setSortSheetVisible] = useState(false);

  const hasFilters = selectedFilters.size > 0;

  // Get all Behov items from filterSets to identify which selectedFilters are needs
  const allBehovItems = new Set();
  Object.values(filterSets.Behov).forEach(category => {
    category.items.forEach(item => allBehovItems.add(item));
    Object.values(category.subs || {}).forEach(subArray => {
      subArray.forEach(sub => allBehovItems.add(sub));
    });
  });

  // Combine persistent needs (activeNeeds) + session needs (Behov items from selectedFilters)
  const needsFromFilters = [...selectedFilters].filter(f => allBehovItems.has(f));
  const allNeeds = new Set([...activeNeeds, ...needsFromFilters]);
  const hasNeeds = allNeeds.size > 0;

  const openSheet  = (k) => { setActiveSheet(k); requestAnimationFrame(() => requestAnimationFrame(() => setSheetVisible(true))); };
  const closeSheet = ()  => { setSheetVisible(false); setTimeout(() => setActiveSheet(null), 300); };
  const toggleFilter = (f) => { const s = new Set(selectedFilters); s.has(f) ? s.delete(f) : s.add(f); setSelectedFilters(s); };

  const openSortSheet  = () => { setSortSheetView("options"); setSortSheetOpen(true);  requestAnimationFrame(() => requestAnimationFrame(() => setSortSheetVisible(true))); };
  const closeSortSheet = () => { setSortSheetVisible(false); setTimeout(() => { setSortSheetOpen(false); setSortSheetView("options"); }, 300); };

  // Attach match counts to each restaurant using combined needs
  const withMatch = allRestaurants.map(r => {
    const m = [...allNeeds].filter(n => r.has.includes(n));
    return { ...r, matchCount:m.length, matchedNeeds:m, missedNeeds:[...allNeeds].filter(n => !r.has.includes(n)) };
  });

  const parsePrice = (r) => { const m = r.priceRange.match(/\d+/); return m ? parseInt(m[0]) : 0; };
  const applySort  = (list) => {
    switch (activeSort) {
      case "nearest":    return [...list].sort((a,b) => parseFloat(a.distance) - parseFloat(b.distance));
      case "price_low":  return [...list].sort((a,b) => parsePrice(a) - parsePrice(b));
      case "price_high": return [...list].sort((a,b) => parsePrice(b) - parsePrice(a));
      case "match":      return hasNeeds ? [...list].sort((a,b) => b.matchCount - a.matchCount || parseFloat(a.distance) - parseFloat(b.distance)) : list;
      default:           return list;
    }
  };

  const sorted       = applySort(withMatch);
  const filtered     = showOnlyOpen ? sorted.filter(r => r.statusOpen) : sorted;
  // Show match sections when ANY filter is selected (Location, Type, or Behov)
  // NOTE: Match calculation currently only works for Behov filters (stored in r.has array)
  // TODO Phase 3: Implement Type and Location matching when real data structure available
  const showMatchSections = hasNeeds || hasFilters;
  const fullMatch    = showMatchSections ? filtered.filter(r => r.matchCount === allNeeds.size) : [];
  const partialMatch = showMatchSections ? filtered.filter(r => r.matchCount > 0 && r.matchCount < allNeeds.size) : [];
  const noMatch      = showMatchSections ? filtered.filter(r => r.matchCount === 0) : [];

  // Count active filters per tab button
  const getFC = (key) => {
    const d = filterSets[key]; let c = 0;
    Object.values(d).forEach(p => {
      p.items.forEach(it => { if (selectedFilters.has(it)) c++; });
      Object.values(p.subs || {}).forEach(sa => sa.forEach(s => { if (selectedFilters.has(s)) c++; }));
    });
    if (key === "Behov") [...activeNeeds].forEach(n => { if (!selectedFilters.has(n)) c++; });
    return c;
  };

  const activeSortLabel = activeSort === "station" && selectedStation
    ? selectedStation
    : SORT_OPTIONS.find(s => s.key === activeSort)?.label || "Sortér";

  return (<>
    <StatusBar/>

    {/* Scrollable content area */}
    <div style={{height:844-54-80,overflowY:"auto",overflowX:"hidden"}}>

      {/* Header: city, search, title, filter buttons */}
      <div style={{padding:"4px 20px 0"}}>
        <div style={{display:"flex",alignItems:"center",gap:5,marginBottom:14}}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={ACCENT} strokeWidth="2.2" strokeLinecap="round">
            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/>
          </svg>
          <span style={{fontSize:13.5,fontWeight:580,color:"#0f0f0f"}}>København</span>
        </div>
        <div style={{display:"flex",alignItems:"center",gap:10,background:"#f5f5f5",borderRadius:12,padding:"11px 14px",marginBottom:16,border:searchFocused?`1.5px solid ${ACCENT}`:"1.5px solid transparent"}}>
          <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#999" strokeWidth="2" strokeLinecap="round">
            <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
          </svg>
          <input
            type="text" placeholder="Søg restauranter, retter..."
            onFocus={() => setSearchFocused(true)} onBlur={() => setSearchFocused(false)}
            style={{border:"none",background:"none",outline:"none",fontSize:15,color:"#0f0f0f",width:"100%",fontFamily:"inherit"}}
          />
        </div>
        <h2 style={{fontSize:24,fontWeight:720,color:"#0f0f0f",margin:"0 0 14px",letterSpacing:"-0.025em"}}>
          {hasFilters || hasNeeds ? `Søgeresultater (${filtered.length})` : "Steder nær dig"}
        </h2>

        {/* Filter buttons */}
        <div style={{display:"flex",gap:8}}>
          {["Lokation","Type","Behov"].map(f => {
            const isA = activeSheet === f;
            const cnt = getFC(f);
            return (
              <button key={f} onClick={() => { isA ? closeSheet() : openSheet(f); }} style={{
                flex:1, padding:"9px 0", borderRadius:10,
                border:isA ? `1.5px solid ${ACCENT}` : "1.5px solid #e8e8e8",
                fontSize:13.5, fontWeight:570, cursor:"pointer", fontFamily:"inherit",
                background:isA ? ACCENT : "#fff", color:isA ? "#fff" : "#555", position:"relative",
              }}>
                {f}{cnt > 0 && !isA ? ` (${cnt})` : ""}
                {cnt > 0 && !isA && (
                  <span style={{position:"absolute",top:5,right:5,width:6,height:6,borderRadius:"50%",background:ACCENT}}/>
                )}
              </button>
            );
          })}
        </div>
      </div>

      {/* Active filter chip row */}
      {(hasFilters || hasNeeds) && (
        <div style={{padding:"14px 0 8px",borderBottom:"1px solid #f2f2f2"}}>
          <div style={{display:"flex",alignItems:"center",position:"relative"}}>
            <div style={{flexShrink:0,paddingLeft:20,background:"#fff",zIndex:2,display:"flex",alignItems:"center"}}>
              <button
                onClick={() => { setSelectedFilters(new Set()); onClearAllNeeds(); }}
                style={{padding:"7px 12px",borderRadius:8,border:"1.5px solid #e0e0e0",background:"#fff",fontSize:12.5,fontWeight:580,color:ACCENT,cursor:"pointer",fontFamily:"inherit",whiteSpace:"nowrap"}}
              >Ryd alle</button>
              <div style={{width:10,background:"linear-gradient(to right, #fff, transparent)",flexShrink:0,height:"100%"}}/>
            </div>
            <div style={{display:"flex",gap:6,overflowX:"auto",paddingRight:20,paddingBottom:2}}>
              {[...activeNeeds].map(n => (
                <button key={n} onClick={() => onToggleNeed(n)} style={{flexShrink:0,display:"flex",alignItems:"center",gap:5,padding:"7px 10px 7px 12px",borderRadius:8,border:`1.5px solid ${GREEN_BORDER}`,background:GREEN_BG,fontSize:12.5,fontWeight:540,color:GREEN,cursor:"pointer",fontFamily:"inherit",whiteSpace:"nowrap"}}>
                  {n}
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#aaa" strokeWidth="2.5" strokeLinecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
                </button>
              ))}
              {[...selectedFilters].map(f => (
                <button key={f} onClick={() => toggleFilter(f)} style={{flexShrink:0,display:"flex",alignItems:"center",gap:5,padding:"7px 10px 7px 12px",borderRadius:8,border:`1.5px solid ${GREEN_BORDER}`,background:GREEN_BG,fontSize:12.5,fontWeight:540,color:GREEN,cursor:"pointer",fontFamily:"inherit",whiteSpace:"nowrap"}}>
                  {f}
                  <svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#aaa" strokeWidth="2.5" strokeLinecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}


      {/* Liste / Kort toggle */}
      <div style={{display:"flex",alignItems:"center",margin:"12px 20px 0",overflow:"hidden"}}>
        {["Liste","Kort"].map(v => {
          const isA = viewMode === v.toLowerCase();
          return (
            <button key={v} onClick={() => setViewMode(v.toLowerCase())} style={{
              flex:1, padding:"8px 0", fontSize:13.5, fontWeight:isA?620:480,
              color:isA?"#0f0f0f":"#999", background:isA?"#f5f5f5":"#fff",
              border:"1.5px solid #e8e8e8", cursor:"pointer", fontFamily:"inherit",
              borderRadius:v==="Liste"?"8px 0 0 8px":"0 8px 8px 0",
              marginLeft:v==="Kort"?"-1.5px":0, boxSizing:"border-box",
            }}>{v}</button>
          );
        })}
      </div>

      {/* Results */}
      {viewMode === "liste" ? (
        <div style={{padding:"16px 20px 32px"}}>
          {showMatchSections ? (<>
            {fullMatch.length > 0 && (
              <div style={{marginBottom:4}}>
                <div style={{fontSize:11,fontWeight:620,color:GREEN,textTransform:"uppercase",letterSpacing:"0.05em",marginBottom:10,display:"flex",alignItems:"center",gap:5}}>
                  <Check size={11} color={GREEN}/> Matcher alle behov
                </div>
                {fullMatch.map((r,i) => <Card key={r.id} r={r} i={i} onSelect={onSelect} hasNeeds variant="full"/>)}
              </div>
            )}
            {partialMatch.length > 0 && (
              <div style={{marginBottom:4}}>
                <div style={{fontSize:11,fontWeight:620,color:ACCENT,textTransform:"uppercase",letterSpacing:"0.05em",marginBottom:10,marginTop:24}}>Matcher delvist</div>
                {partialMatch.map((r,i) => <Card key={r.id} r={r} i={i} onSelect={onSelect} hasNeeds variant="partial"/>)}
              </div>
            )}
            {noMatch.length > 0 && (
              <div>
                <div style={{fontSize:11,fontWeight:620,color:"#bbb",textTransform:"uppercase",letterSpacing:"0.05em",marginBottom:10,marginTop:24}}>Andre steder</div>
                {noMatch.map((r,i) => <Card key={r.id} r={r} i={i} onSelect={onSelect} hasNeeds={false} variant="none"/>)}
              </div>
            )}
          </>) : (
            filtered.map((r,i) => <Card key={r.id} r={r} i={i} onSelect={onSelect} hasNeeds={false} variant="none"/>)
          )}
        </div>
      ) : (
        <div style={{flex:1,display:"flex",alignItems:"center",justifyContent:"center",padding:"60px 20px",textAlign:"center"}}>
          <div>
            <div style={{width:64,height:64,borderRadius:16,background:"#f5f5f5",display:"flex",alignItems:"center",justifyContent:"center",margin:"0 auto 12px"}}>
              <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#ccc" strokeWidth="1.5" strokeLinecap="round">
                <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/>
              </svg>
            </div>
            <div style={{fontSize:15,fontWeight:600,color:"#999"}}>Kortvisning</div>
            <div style={{fontSize:13,color:"#bbb",marginTop:4}}>Kommer snart</div>
          </div>
        </div>
      )}
    </div>

    {/* Floating sort button — list view only */}
    {viewMode === "liste" && (
      <button onClick={openSortSheet} style={{
        position:"absolute", bottom:92, right:16, zIndex:6,
        display:"flex", alignItems:"center", gap:5,
        padding:"9px 14px", borderRadius:20,
        background:ACCENT, color:"#fff", border:"none",
        fontSize:12.5, fontWeight:580, cursor:"pointer", fontFamily:"inherit",
        boxShadow:"0 2px 8px rgba(0,0,0,0.12)",
      }}>
        <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.5" strokeLinecap="round">
          <path d="M3 6h18M6 12h12M9 18h6"/>
        </svg>
        {activeSortLabel}
      </button>
    )}

    <TabBar activeTab="udforsk" onChangeTab={onTabChange}/>

    {/* Sort sheet */}
    {sortSheetOpen && (
      <BottomSheet visible={sortSheetVisible} onClose={closeSortSheet} height="62%">
        <style>{`
          @keyframes slideOutLeft { from { transform:translateX(0); opacity:1; } to { transform:translateX(-100%); opacity:0; } }
          @keyframes slideInRight { from { transform:translateX(100%); opacity:0; } to { transform:translateX(0); opacity:1; } }
          @keyframes slideOutRight { from { transform:translateX(0); opacity:1; } to { transform:translateX(100%); opacity:0; } }
          @keyframes slideInLeft { from { transform:translateX(-100%); opacity:0; } to { transform:translateX(0); opacity:1; } }
        `}</style>

        {/* Header - changes based on view */}
        <div style={{padding:"4px 20px 10px",borderBottom:"1px solid #f0f0f0",flexShrink:0,display:"flex",alignItems:"center",gap:12}}>
          {sortSheetView === "stations" && (
            <button
              onClick={() => setSortSheetView("options")}
              style={{background:"none",border:"none",padding:"4px",cursor:"pointer",display:"flex",alignItems:"center",marginLeft:-8}}
            >
              <svg width="10" height="16" viewBox="0 0 10 16" fill="none" stroke="#666" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M8 2L2 8l6 6"/>
              </svg>
            </button>
          )}
          <h3 style={{margin:0,fontSize:18,fontWeight:680,color:"#0f0f0f"}}>
            {sortSheetView === "stations" ? "Vælg togstation" : "Sortér efter"}
          </h3>
        </div>

        {/* Content area with sliding views */}
        <div style={{flex:1,position:"relative",overflow:"hidden"}}>
          {/* Sort options view */}
          <div
            key={sortSheetView} // Force re-render for animation
            style={{
              position:"absolute",
              inset:0,
              overflowY:"auto",
              padding:"8px 0",
              animation: sortSheetView === "options" ? "slideInLeft 0.3s cubic-bezier(0.32,0.72,0,1)" : "slideOutLeft 0.3s cubic-bezier(0.32,0.72,0,1)",
              display: sortSheetView === "options" ? "block" : "none",
            }}
          >
            {/* "Open now" filter toggle */}
            <div style={{padding:"12px 20px",borderBottom:"1px solid #f0f0f0",marginBottom:8}}>
              <button
                onClick={() => setShowOnlyOpen(!showOnlyOpen)}
                style={{
                  display:"flex", alignItems:"center", justifyContent:"space-between",
                  width:"100%", padding:"12px 14px", borderRadius:10,
                  border:showOnlyOpen ? `1.5px solid ${GREEN_BORDER}` : "1.5px solid #e8e8e8",
                  background:showOnlyOpen ? GREEN_BG : "#fff",
                  cursor:"pointer", fontFamily:"inherit",
                }}
              >
                <div style={{display:"flex",alignItems:"center",gap:10}}>
                  <div style={{
                    width:20, height:20, borderRadius:5,
                    border:showOnlyOpen ? "none" : "1.5px solid #ccc",
                    background:showOnlyOpen ? GREEN : "#fff",
                    display:"flex", alignItems:"center", justifyContent:"center",
                    flexShrink:0,
                  }}>
                    {showOnlyOpen && <Check size={11} color="#fff"/>}
                  </div>
                  <span style={{fontSize:15,fontWeight:showOnlyOpen?600:460,color:showOnlyOpen?GREEN:"#666"}}>
                    Kun åbne steder
                  </span>
                </div>
                {showOnlyOpen && (
                  <span style={{fontSize:12,color:GREEN,fontWeight:540}}>
                    {filtered.length} steder
                  </span>
                )}
              </button>
            </div>

            {SORT_OPTIONS.map(opt => {
              const isA = activeSort === opt.key;
              const isStation = opt.key === "station";
              const displayLabel = isStation && selectedStation ? `${opt.label}: ${selectedStation}` : opt.label;

              return (
                <button
                  key={opt.key}
                  onClick={() => {
                    if (opt.hasSubmenu) {
                      setSortSheetView("stations");
                    } else {
                      setActiveSort(opt.key);
                      closeSortSheet();
                    }
                  }}
                  style={{
                    display:"flex", alignItems:"center", justifyContent:"space-between",
                    width:"100%", padding:"14px 20px", border:"none",
                    background:isA?"#fafafa":"transparent", cursor:"pointer", fontFamily:"inherit",
                  }}
                >
                  <span style={{fontSize:15,fontWeight:isA?620:460,color:isA?"#0f0f0f":"#666"}}>{displayLabel}</span>
                  <div style={{display:"flex",alignItems:"center",gap:8}}>
                    {isA && !opt.hasSubmenu && (
                      <div style={{width:20,height:20,borderRadius:"50%",background:ACCENT,display:"flex",alignItems:"center",justifyContent:"center"}}>
                        <Check size={11}/>
                      </div>
                    )}
                    {opt.hasSubmenu && (
                      <svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke="#bbb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M1 1l6 6-6 6"/>
                      </svg>
                    )}
                  </div>
                </button>
              );
            })}
          </div>

          {/* Station picker view */}
          <div
            key={`${sortSheetView}-stations`} // Force re-render for animation
            style={{
              position:"absolute",
              inset:0,
              overflowY:"auto",
              animation: sortSheetView === "stations" ? "slideInRight 0.3s cubic-bezier(0.32,0.72,0,1)" : "slideOutRight 0.3s cubic-bezier(0.32,0.72,0,1)",
              display: sortSheetView === "stations" ? "block" : "none",
            }}
          >
            {trainStations.map(station => {
              const isSelected = selectedStation === station;
              return (
                <button
                  key={station}
                  onClick={() => {
                    setSelectedStation(station);
                    setActiveSort("station");
                    setSortSheetView("options");
                  }}
                  style={{
                    display:"flex", alignItems:"center", justifyContent:"space-between",
                    width:"100%", padding:"16px 20px", border:"none",
                    background:isSelected?"#fafafa":"transparent",
                    cursor:"pointer", fontFamily:"inherit",
                  }}
                >
                  <span style={{fontSize:15,fontWeight:isSelected?620:460,color:isSelected?"#0f0f0f":"#666"}}>
                    {station}
                  </span>
                  {isSelected && (
                    <div style={{width:20,height:20,borderRadius:"50%",background:ACCENT,display:"flex",alignItems:"center",justifyContent:"center"}}>
                      <Check size={11}/>
                    </div>
                  )}
                </button>
              );
            })}
          </div>
        </div>

        {/* Footer note - only show in station view */}
        {sortSheetView === "stations" && (
          <div style={{padding:"12px 20px",borderTop:"1px solid #f0f0f0",background:"#fafafa",flexShrink:0}}>
            <div style={{fontSize:12,color:"#999",lineHeight:1.4}}>
              💡 I den færdige app vil dette sortere steder efter afstand til den valgte station via Typesense & BuildShip.
            </div>
          </div>
        )}
      </BottomSheet>
    )}

    {/* Filter sheet */}
    {activeSheet && (
      <FilterSheet
        initialTab={activeSheet}
        selectedFilters={selectedFilters}
        onToggle={toggleFilter}
        onClose={closeSheet}
        visible={sheetVisible}
        resultCount={filtered.length}
        onReset={() => setSelectedFilters(new Set())}
        activeNeeds={activeNeeds}
      />
    )}
  </>);
}
