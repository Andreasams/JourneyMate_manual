// ============================================================
// JOURNEYMATE — BUSINESS PROFILE PAGE
// Full restaurant profile: hero, quick actions, match card,
// opening hours, gallery, menu, facilities, payments, about.
// Props:
//   restaurant   — restaurant object from allRestaurants
//   onBack()     — navigate back to search
//   activeNeeds  — Set<string> of persistent needs
//   onNavigate() — navigate to sub-pages (menu-full, gallery-full, information)
// ============================================================

import { useState } from "react";
import {
  ACCENT, GREEN, GREEN_BG, GREEN_BORDER,
  Dot, Check, StatusBar, BottomSheet, OpeningHoursSection,
} from "../../shared/_shared.jsx";
import FacilitiesInfoSheet from "./facilities_info_sheet.jsx";
import ContactCopyPopup from "./contact_copy_popup.jsx";
import ReportMissingInfoModal from "./report_missing_info_modal.jsx";
import MenuItemDetailOverlay from "./menu_item_detail_overlay.jsx";

export default function BusinessProfilePage({restaurant: r, onBack, activeNeeds, onNavigate}) {
  const [matchOpen,       setMatchOpen]       = useState(false);
  const [aboutOpen,       setAboutOpen]       = useState(false);
  const [activeCat,       setActiveCat]       = useState((r.menuCategories || ["Menu"])[0]);
  const [menuFilterOpen,  setMenuFilterOpen]  = useState(false);
  const [activeAllergens, setActiveAllergens] = useState(new Set(["Bløddyr","Fisk","Jordnødder","Korn","Mælk","Æg","Soja","Selleri","Sennep","Sesamfrø"]));
  const [activeGalleryTab,setActiveGalleryTab]= useState("Mad");
  const [facilitiesInfoOpen, setFacilitiesInfoOpen] = useState(false);
  const [selectedFacility, setSelectedFacility] = useState(null);
  const [reportOpen, setReportOpen] = useState(false);
  const [menuItemOpen, setMenuItemOpen] = useState(false);
  const [selectedMenuItem, setSelectedMenuItem] = useState(null);

  const closed      = !r.statusOpen;
  const hasNeeds    = activeNeeds.size > 0;
  const matched     = hasNeeds ? [...activeNeeds].filter(n => r.has.includes(n)) : [];
  const missed      = hasNeeds ? [...activeNeeds].filter(n => !r.has.includes(n)) : [];
  const isFullMatch = hasNeeds && missed.length === 0;

  const toggleA = (val) => {
    const s = new Set(activeAllergens);
    s.has(val) ? s.delete(val) : s.add(val);
    setActiveAllergens(s);
  };

  const cats         = r.menuCategories || ["Menu"];
  const currentItems = (r.menuItems || {})[activeCat] || [];
  const galleryTabs  = ["Mad","Menu","Inde","Ude"];

  // Sample detailed data for first 3 menu items (only these will be clickable)
  const menuItemDetails = {
    "Margherita Pizza": {
      name: "Margherita Pizza",
      price: "89 kr.",
      desc: "Klassisk italiensk pizza med tomatsauce, mozzarella og frisk basilikum. Bagt i stenovn ved 450°C for den perfekte sprøde bund.",
      fullDesc: "Vores Margherita er en hyldest til den napolitanske tradition. Vi bruger San Marzano tomater fra Campania-regionen, importeret bufala mozzarella og frisk basilikum fra vores egen have. Dejen hviler i 48 timer for at udvikle den karakteristiske syrlige smag. Hver pizza bages i præcis 90 sekunder i vores håndbyggede Napoli-ovn ved 480°C.",
      allergens: ["Gluten", "Mælk"],
      dietary: ["Vegetarisk"],
      ingredients: ["Hvedemel type 00", "San Marzano tomater", "Bufala mozzarella", "Frisk basilikum", "Ekstra jomfru olivenolie", "Havsalt"],
      nutritional: {
        calories: "780 kcal",
        protein: "32g",
        carbs: "98g",
        fat: "28g"
      }
    },
    "Carbonara": {
      name: "Carbonara",
      price: "125 kr.",
      desc: "Traditionel romersk pasta med guanciale, pecorino romano, æg og sort peber.",
      fullDesc: "Autentisk Carbonara lavet efter den klassiske opskrift fra Rom. Vi bruger håndskåret guanciale (lufttørret svinekæbe) fra Lazio, der steges sprød. Pastaen blandes med en cremet sauce af økologiske æggeblommer og revet Pecorino Romano DOP. Ingen fløde – kun de fire originale ingredienser og masser af friskkværnet sort peber.",
      allergens: ["Gluten", "Æg", "Mælk"],
      dietary: [],
      ingredients: ["Spaghetti", "Guanciale", "Pecorino Romano DOP", "Økologiske æggeblommer", "Sort peber"],
      nutritional: {
        calories: "920 kcal",
        protein: "42g",
        carbs: "87g",
        fat: "45g"
      }
    },
    "Vegansk Buddha Bowl": {
      name: "Vegansk Buddha Bowl",
      price: "95 kr.",
      desc: "Farverig bowl med quinoa, stegte grøntsager, avocado, kikærter og tahin-dressing.",
      fullDesc: "En nærende og mættende bowl fyldt med sunde plantebaserede ingredienser. Bunden er lavet af luftig quinoa, toppet med krydrede ovnbagte søde kartofler, sprøde kikærter, frisk avocado, syltede rødkål, edamamebønner og pumpernellefrø. Serveres med vores hjemmelavede tahindressing med citron og hvidløg.",
      allergens: ["Sesam"],
      dietary: ["Vegansk", "Glutenfri"],
      ingredients: ["Quinoa", "Søde kartofler", "Kikærter", "Avocado", "Rødkål", "Edamamebønner", "Pumpernellefrø", "Tahin", "Citron", "Hvidløg"],
      nutritional: {
        calories: "520 kcal",
        protein: "18g",
        carbs: "65g",
        fat: "22g"
      }
    }
  };

  // Placeholder gallery colors per tab
  const gc = {
    Mad:  ["#f0dcc8","#e8c8b8","#d4b8a0","#c8a888","#ddc8b0","#f0e0d0"],
    Menu: ["#e0e0e0","#d8d8d8","#d0d0d0","#c8c8c8","#e0e0e0","#d8d8d8"],
    Inde: ["#d8ccc0","#c8b8a8","#e0d0c0","#d0c0b0","#c8b8a8","#d8ccc0"],
    Ude:  ["#c0d8c8","#b0c8b8","#a8c0a8","#b8d0b8","#c0d8c8","#b0c8b8"],
  };

  // Today's hours — full slot detail for profile (unlike card's simplified span)
  const days       = ["Søndag","Mandag","Tirsdag","Onsdag","Torsdag","Fredag","Lørdag"];
  const today      = days[new Date().getDay()];
  const todayEntry = (r.hours || []).find(([d]) => d === today);
  const todayPreview = todayEntry
    ? (typeof todayEntry[1] === "string"
        ? todayEntry[1]
        : Array.isArray(todayEntry[1])
          ? todayEntry[1].map(s => s.time).join(", ")
          : "")
    : "";

  const quickActions = [
    r.phone
      ? {label:"Ring op",    icon:"M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6A19.79 19.79 0 012.12 4.18 2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"}
      : null,
    r.links?.website
      ? {label:"Hjemmeside", icon:"M12 2a10 10 0 100 20 10 10 0 000-20zM2 12h20M12 2a15.3 15.3 0 014 10 15.3 15.3 0 01-4 10 15.3 15.3 0 01-4-10 15.3 15.3 0 014-10z"}
      : null,
    r.links?.booking
      ? {label:"Bestil bord",icon:"M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"}
      : null,
    {label:"Se på kort", icon:"M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0zM12 13a3 3 0 100-6 3 3 0 000 6z"},
  ].filter(Boolean);

  return (<>
    <StatusBar/>

    {/* Nav bar */}
    <div style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"4px 20px 0"}}>
      <button onClick={onBack} style={{background:"none",border:"none",cursor:"pointer",padding:4}}>
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#0f0f0f" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
      </button>
      <div style={{display:"flex",gap:14}}>
        <button style={{background:"none",border:"none",cursor:"pointer",padding:4}}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#0f0f0f" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8M16 6l-4-4-4 4M12 2v13"/>
          </svg>
        </button>
        <button onClick={() => onNavigate && onNavigate("information")} style={{background:"none",border:"none",cursor:"pointer",padding:4}}>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#0f0f0f" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>
          </svg>
        </button>
      </div>
    </div>

    {/* Scrollable body */}
    <div style={{height:844-54-44,overflowY:"auto",overflowX:"hidden"}}>

      {/* 1. Hero */}
      <div style={{padding:"16px 24px 0"}}>
        <div style={{display:"flex",gap:16,alignItems:"flex-start",marginBottom:14}}>
          <div style={{width:64,height:64,borderRadius:18,background:r.bg,display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
            <span style={{color:"#fff",fontSize:20,fontWeight:700}}>{r.initial}</span>
          </div>
          <div style={{flex:1}}>
            <h1 style={{margin:"0 0 4px",fontSize:24,fontWeight:750,color:"#0f0f0f",letterSpacing:"-0.03em"}}>{r.name}</h1>
            <div style={{fontSize:13.5,color:"#888",marginBottom:2}}>{r.cuisine}</div>
            <div style={{display:"flex",alignItems:"center",gap:7}}>
              <span style={{fontSize:13,fontWeight:580,color:closed?"#c9403a":"#2a9456"}}>{closed?"Lukket":"Åben"}</span>
              <Dot/><span style={{fontSize:13,color:"#999"}}>til {r.closingTime}</span>
              <Dot/><span style={{fontSize:13,color:"#999"}}>{r.priceRange}</span>
            </div>
            <div style={{fontSize:13,color:"#aaa",marginTop:3}}>{r.address}</div>
          </div>
        </div>

        {/* 2. Quick action pills */}
        <div style={{display:"flex",gap:8,overflowX:"auto",marginBottom:16,paddingBottom:2,marginRight:-24,paddingRight:24}}>
          {quickActions.map(a => (
            <button key={a.label} style={{flexShrink:0,display:"flex",alignItems:"center",gap:6,padding:"8px 14px",borderRadius:10,border:"1.5px solid #e8e8e8",background:"#fff",cursor:"pointer",fontFamily:"inherit",fontSize:13,fontWeight:520,color:"#444"}}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#666" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d={a.icon}/>
              </svg>
              {a.label}
            </button>
          ))}
        </div>

        {/* 3. Match card — collapsed by default */}
        {hasNeeds && (
          <div style={{
            marginBottom:16, borderRadius:12, overflow:"hidden",
            border:isFullMatch ? `1.5px solid ${GREEN_BORDER}` : "1.5px solid #f0dcc8",
            background:isFullMatch ? GREEN_BG : "#fef8f2",
          }}>
            <button onClick={() => setMatchOpen(!matchOpen)} style={{
              width:"100%", display:"flex", alignItems:"center", justifyContent:"space-between",
              padding:"12px 14px", background:"transparent", border:"none",
              cursor:"pointer", fontFamily:"inherit",
            }}>
              <div style={{display:"flex",alignItems:"center",gap:8}}>
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={isFullMatch?GREEN:ACCENT} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                  {isFullMatch
                    ? <path d="M20 6L9 17l-5-5"/>
                    : <><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></>}
                </svg>
                <span style={{fontSize:13.5,fontWeight:600,color:"#0f0f0f"}}>
                  {isFullMatch
                    ? `Matcher alle ${matched.length} behov`
                    : `Matcher ${matched.length} af ${activeNeeds.size} behov`}
                </span>
              </div>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#999" strokeWidth="2.5" strokeLinecap="round" style={{transition:"transform 0.25s",transform:matchOpen?"rotate(180deg)":"rotate(0)",flexShrink:0}}>
                <path d="M6 9l6 6 6-6"/>
              </svg>
            </button>
            {matchOpen && (
              <div style={{padding:"0 14px 14px"}}>
                <div style={{display:"flex",gap:5,flexWrap:"wrap"}}>
                  {matched.map(n => (
                    <span key={n} style={{display:"inline-flex",alignItems:"center",gap:3,padding:"3px 8px",borderRadius:6,fontSize:11,fontWeight:560,background:"#fff",color:GREEN,border:`1px solid ${GREEN_BORDER}`}}>
                      <Check size={8} color={GREEN}/>{n}
                    </span>
                  ))}
                  {missed.map(n => (
                    <span key={n} style={{display:"inline-flex",alignItems:"center",gap:3,padding:"3px 8px",borderRadius:6,fontSize:11,fontWeight:520,background:"#fff",color:"#c9403a",border:"1px solid #f5d5d2"}}>
                      <svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="#c9403a" strokeWidth="3" strokeLinecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
                      {n}
                    </span>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}
      </div>

      {/* 4. Opening hours & contact — collapsible, Option B preview */}
      <OpeningHoursSection
        title="Åbningstider og kontakt"
        hours={r.hours}
        todayPreview={todayPreview}
        contact={{ phone: r.phone, links: r.links }}
        variant="profile"
      />

      {/* 5. Gallery — tabbed + swipeable */}
      <div style={{padding:"0 0 16px"}}>
        <div style={{padding:"0 24px",marginBottom:12}}>
          <h3 style={{margin:"0 0 12px",fontSize:18,fontWeight:680,color:"#0f0f0f"}}>Galleri</h3>
          <div style={{display:"flex"}}>
            {galleryTabs.map(t => (
              <button key={t} onClick={() => setActiveGalleryTab(t)} style={{
                flex:1, padding:"6px 0", background:"none", border:"none",
                cursor:"pointer", fontFamily:"inherit", fontSize:13.5, textAlign:"center",
                fontWeight:activeGalleryTab===t?620:460,
                color:activeGalleryTab===t?ACCENT:"#999",
                borderBottom:activeGalleryTab===t?`2px solid ${ACCENT}`:"2px solid transparent",
              }}>{t}</button>
            ))}
          </div>
        </div>
        <div
          style={{overflow:"hidden",padding:"0 24px"}}
          onTouchStart={(e) => { e.currentTarget._touchX = e.touches[0].clientX; }}
          onTouchEnd={(e) => {
            const dx = e.changedTouches[0].clientX - (e.currentTarget._touchX || 0);
            if (Math.abs(dx) > 40) {
              const ci = galleryTabs.indexOf(activeGalleryTab);
              if (dx < 0 && ci < galleryTabs.length - 1) setActiveGalleryTab(galleryTabs[ci + 1]);
              if (dx > 0 && ci > 0) setActiveGalleryTab(galleryTabs[ci - 1]);
            }
          }}
        >
          <div style={{display:"grid",gridTemplateColumns:"repeat(3, 1fr)",gap:3}}>
            {(gc[activeGalleryTab] || gc.Mad).map((c, i) => (
              <div key={i} style={{
                aspectRatio:"1",
                background:c,
                borderRadius:
                  i===0 ? "10px 4px 4px 4px" :
                  i===2 ? "4px 10px 4px 4px" :
                  i===3 ? "4px 4px 4px 10px" :
                  i===5 ? "4px 4px 10px 4px" : 4,
              }}/>
            ))}
          </div>
        </div>
        <div style={{textAlign:"center",marginTop:8}}>
          <button onClick={() => onNavigate && onNavigate("gallery-full")} style={{background:"none",border:"none",fontSize:13,fontWeight:540,color:"#555",cursor:"pointer",fontFamily:"inherit"}}>Se alle billeder →</button>
        </div>
      </div>

      <div style={{height:1,background:"#f2f2f2"}}/>

      {/* 6. Menu */}
      <div style={{padding:"16px 24px 0"}}>
        <div style={{display:"flex",alignItems:"baseline",justifyContent:"space-between",marginBottom:4}}>
          <h3 style={{margin:0,fontSize:18,fontWeight:680,color:"#0f0f0f"}}>Menu</h3>
          {r.menuLastReviewed && (
            <span style={{fontSize:11.5,color:"#bbb",fontWeight:460}}>Sidst ajourført {r.menuLastReviewed}</span>
          )}
        </div>
        {/* "Filtrer" toggle — not "Vis filtre" (see Decision 8) */}
        <button
          onClick={() => setMenuFilterOpen(!menuFilterOpen)}
          onMouseEnter={(e) => e.currentTarget.style.opacity = "0.7"}
          onMouseLeave={(e) => e.currentTarget.style.opacity = "1"}
          style={{
            background:"none",
            border:"none",
            fontSize:13.5,
            fontWeight:560,
            color:ACCENT,
            cursor:"pointer",
            fontFamily:"inherit",
            padding:0,
            marginBottom:14,
            transition:"opacity 0.2s ease",
          }}
        >
          {menuFilterOpen ? "Skjul filtre" : "Filtrer"}
        </button>

        {menuFilterOpen && (
          <div style={{
            background:"#fafafa",
            borderRadius:14,
            padding:16,
            marginBottom:16,
            border:"1px solid #f0f0f0",
            animation: "slideIn 0.3s ease-out",
            "@keyframes slideIn": {
              from: { opacity: 0, transform: "translateY(-10px)" },
              to: { opacity: 1, transform: "translateY(0)" }
            }
          }}>
            {/* Kostrestriktioner */}
            <div style={{marginBottom:14}}>
              <div style={{fontSize:14,fontWeight:640,color:"#0f0f0f",marginBottom:2}}>Kostrestriktioner</div>
              <div style={{fontSize:12,color:"#999",marginBottom:10,lineHeight:1.4}}>Vis kun retter, der overholder den valgte kostrestriktion.</div>
              <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                {["Glutenfrit","Laktosefrit"].map((x, idx) => {
                  const a = activeAllergens.has(x);
                  return <button key={x} onClick={() => toggleA(x)} style={{
                    padding:"6px 12px",
                    borderRadius:8,
                    border:a?`1.5px solid ${ACCENT}`:"1.5px solid #e4e4e4",
                    background:a?ACCENT:"#fff",
                    color:a?"#fff":"#666",
                    fontSize:12.5,
                    fontWeight:a?600:460,
                    cursor:"pointer",
                    fontFamily:"inherit",
                    transition:"all 0.2s ease",
                    transitionDelay:`${idx * 50}ms`,
                  }}>{x}</button>;
                })}
              </div>
            </div>
            {/* Kostpræferencer */}
            <div style={{marginBottom:14}}>
              <div style={{fontSize:14,fontWeight:640,color:"#0f0f0f",marginBottom:2}}>Kostpræferencer</div>
              <div style={{fontSize:12,color:"#999",marginBottom:10,lineHeight:1.4}}>Vis kun retter, der overholder den valgte diæt.</div>
              <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                {["Pescetarvenligt","Vegansk","Vegetarisk"].map((x, idx) => {
                  const a = activeAllergens.has(x);
                  return <button key={x} onClick={() => toggleA(x)} style={{
                    padding:"6px 12px",
                    borderRadius:8,
                    border:a?`1.5px solid ${ACCENT}`:"1.5px solid #e4e4e4",
                    background:a?ACCENT:"#fff",
                    color:a?"#fff":"#666",
                    fontSize:12.5,
                    fontWeight:a?600:460,
                    cursor:"pointer",
                    fontFamily:"inherit",
                    transition:"all 0.2s ease",
                    transitionDelay:`${idx * 50}ms`,
                  }}>{x}</button>;
                })}
              </div>
            </div>
            {/* Allergener */}
            <div>
              <div style={{fontSize:14,fontWeight:640,color:"#0f0f0f",marginBottom:2}}>Allergener</div>
              <div style={{fontSize:12,color:"#999",marginBottom:10,lineHeight:1.4}}>Skjul retter, der indeholder det valgte allergen.</div>
              <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
                {["Bløddyr","Fisk","Jordnødder","Korn","Mælk","Æg","Soja","Selleri","Sennep","Sesamfrø"].map((x, idx) => {
                  const a = activeAllergens.has(x);
                  return <button key={x} onClick={() => toggleA(x)} style={{
                    padding:"6px 12px",
                    borderRadius:8,
                    border:a?`1.5px solid ${ACCENT}`:"1.5px solid #e4e4e4",
                    background:a?ACCENT:"#fff",
                    color:a?"#fff":"#666",
                    fontSize:12.5,
                    fontWeight:a?600:460,
                    cursor:"pointer",
                    fontFamily:"inherit",
                    transition:"all 0.2s ease",
                    transitionDelay:`${idx * 50}ms`,
                  }}>{x}</button>;
                })}
              </div>
            </div>
          </div>
        )}

        {/* Category chips */}
        <div style={{display:"flex",gap:8,overflowX:"auto",marginBottom:16,paddingBottom:2}}>
          {cats.map(c => (
            <button key={c} onClick={() => setActiveCat(c)} style={{
              flexShrink:0, padding:"7px 14px", borderRadius:9, fontFamily:"inherit",
              border:activeCat===c?`1.5px solid ${ACCENT}`:"1.5px solid #e4e4e4",
              background:activeCat===c?ACCENT:"#fff",
              color:activeCat===c?"#fff":"#555",
              fontSize:13, fontWeight:activeCat===c?600:480, cursor:"pointer",
            }}>{c}</button>
          ))}
        </div>
      </div>

      {/* Menu items */}
      <div style={{padding:"0 24px 16px"}}>
        <h4 style={{margin:"0 0 2px",fontSize:16,fontWeight:650,color:"#0f0f0f"}}>{activeCat}</h4>

        {/* Empty state when no items match filters */}
        {currentItems.length === 0 && (
          <div style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            padding: "32px 20px",
            textAlign: "center",
            background: "#fafafa",
            borderRadius: 12,
            border: "1px solid #f0f0f0",
            marginTop: 12,
          }}>
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="#d0d0d0" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" style={{ marginBottom: 12 }}>
              <circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>
            </svg>
            <h3 style={{
              fontSize: 15,
              fontWeight: 680,
              color: "#0f0f0f",
              margin: "0 0 6px 0",
            }}>
              Ingen retter matcher dine filtre
            </h3>
            <p style={{
              fontSize: 13,
              fontWeight: 400,
              color: "#888",
              lineHeight: "18px",
              margin: 0,
            }}>
              Prøv at fjerne nogle filtre eller vælg "Ryd alle"<br/>for at se hele menuen.
            </p>
          </div>
        )}

        {/* Menu items list */}
        {currentItems.length > 0 && currentItems.map((item, i) => {
          const hasDetails = menuItemDetails[item.name];
          return (
            <div
              key={i}
              onClick={() => {
                if (hasDetails) {
                  setSelectedMenuItem(menuItemDetails[item.name]);
                  setMenuItemOpen(true);
                }
              }}
              style={{
                padding:"12px 0",
                borderBottom:i<currentItems.length-1?"1px solid #f2f2f2":"none",
                cursor: hasDetails ? "pointer" : "default",
              }}
            >
              <div style={{display:"flex",justifyContent:"space-between",alignItems:"baseline",marginBottom:3}}>
                <span style={{fontSize:15,fontWeight:590,color:"#0f0f0f"}}>{item.name}</span>
                {item.price && <span style={{fontSize:13.5,fontWeight:540,color:ACCENT,flexShrink:0,marginLeft:12}}>{item.price}</span>}
              </div>
              <div style={{fontSize:13,color:"#999",lineHeight:1.4,display:"-webkit-box",WebkitLineClamp:2,WebkitBoxOrient:"vertical",overflow:"hidden"}}>{item.desc}</div>
            </div>
          );
        })}

        {currentItems.length > 0 && (
          <div style={{textAlign:"center",marginTop:12}}>
            <button onClick={() => onNavigate && onNavigate("menu-full")} style={{background:"none",border:"none",fontSize:13,fontWeight:540,color:"#555",cursor:"pointer",fontFamily:"inherit"}}>Vis på hel side →</button>
          </div>
        )}
      </div>

      <div style={{height:1,background:"#f2f2f2"}}/>

      {/* 7. Facilities — GREEN highlight for need-matches */}
      <div style={{padding:"16px 24px"}}>
        <h3 style={{margin:"0 0 12px",fontSize:18,fontWeight:680,color:"#0f0f0f"}}>Faciliteter og services</h3>
        <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
          {(r.facilities || []).map(f => {
            const isMatch = hasNeeds && [...activeNeeds].some(n =>
              f.l.toLowerCase().includes(n.toLowerCase()) || n.toLowerCase().includes(f.l.toLowerCase())
            );
            return (
              <div
                key={f.l}
                onClick={() => {
                  if (f.i) {
                    setSelectedFacility(f);
                    setFacilitiesInfoOpen(true);
                  }
                }}
                style={{
                  padding:"7px 12px", borderRadius:9,
                  border:isMatch?`1.5px solid ${GREEN_BORDER}`:"1.5px solid #e8e8e8",
                  background:isMatch?GREEN_BG:"#fff",
                  color:isMatch?GREEN:"#444",
                  fontSize:13, fontWeight:isMatch?580:480,
                  display:"flex", alignItems:"center", gap:5,
                  cursor:f.i?"pointer":"default",
                }}
              >
                {f.l}
                {f.i && (
                  <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={isMatch?GREEN:"#bbb"} strokeWidth="2" strokeLinecap="round">
                    <circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/>
                  </svg>
                )}
              </div>
            );
          })}
        </div>
      </div>

      <div style={{height:1,background:"#f2f2f2"}}/>

      {/* 8. Payment options */}
      <div style={{padding:"16px 24px"}}>
        <h3 style={{margin:"0 0 12px",fontSize:18,fontWeight:680,color:"#0f0f0f"}}>Betalingsmuligheder</h3>
        <div style={{display:"flex",gap:8,flexWrap:"wrap"}}>
          {(r.payments || []).map(p => (
            <div key={p} style={{padding:"7px 14px",borderRadius:9,border:"1.5px solid #e8e8e8",fontSize:13,fontWeight:480,color:"#555"}}>{p}</div>
          ))}
        </div>
      </div>

      <div style={{height:1,background:"#f2f2f2"}}/>

      {/* 9. About — collapsible */}
      <div style={{padding:"16px 24px"}}>
        <button onClick={() => setAboutOpen(!aboutOpen)} style={{width:"100%",display:"flex",justifyContent:"space-between",background:"none",border:"none",cursor:"pointer",fontFamily:"inherit",padding:0}}>
          <h3 style={{margin:0,fontSize:18,fontWeight:680,color:"#0f0f0f"}}>Om</h3>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#999" strokeWidth="2.5" strokeLinecap="round" style={{transition:"transform 0.25s",transform:aboutOpen?"rotate(180deg)":"rotate(0)"}}>
            <path d="M6 9l6 6 6-6"/>
          </svg>
        </button>
        {aboutOpen && <p style={{margin:"12px 0 0",fontSize:14,color:"#555",lineHeight:1.65}}>{r.about}</p>}
      </div>

      <div style={{height:1,background:"#f2f2f2"}}/>

      {/* 10. Report */}
      <div style={{padding:"24px 24px 44px",textAlign:"center"}}>
        <button onClick={() => setReportOpen(true)} style={{background:"none",border:"none",fontSize:13,fontWeight:500,color:"#bbb",cursor:"pointer",fontFamily:"inherit",textDecoration:"underline",textUnderlineOffset:3}}>
          Rapportér manglende eller forkerte oplysninger
        </button>
      </div>
    </div>

    {/* Facilities Info Sheet */}
    {selectedFacility && (
      <FacilitiesInfoSheet
        visible={facilitiesInfoOpen}
        facility={selectedFacility}
        onClose={() => setFacilitiesInfoOpen(false)}
      />
    )}

    {/* Report Missing Info Modal */}
    <ReportMissingInfoModal
      visible={reportOpen}
      restaurant={r}
      onClose={() => setReportOpen(false)}
      onSubmit={(data) => {
        console.log("Report submitted:", data);
        setReportOpen(false);
      }}
    />

    {/* Menu Item Detail Overlay */}
    <MenuItemDetailOverlay
      visible={menuItemOpen}
      item={selectedMenuItem}
      onClose={() => setMenuItemOpen(false)}
    />
  </>);
}
