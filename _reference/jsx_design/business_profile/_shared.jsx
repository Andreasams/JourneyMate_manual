// ============================================================
// JOURNEYMATE — SHARED
// Design tokens, restaurant data, and shared micro-components.
// Imported by every page file.
// ============================================================

import { useState, useRef } from "react";

// ── Design tokens ────────────────────────────────────────────
export const ACCENT       = "#e8751a";
export const GREEN        = "#1a9456";
export const GREEN_BG     = "#f0f9f3";
export const GREEN_BORDER = "#d0ecd8";

// ── Train stations (for sorting) ────────────────────────────
export const trainStations = [
  "København H",
  "Nørreport",
  "Østerport",
  "Vesterport",
  "Flintholm",
];

// ── Filter data ──────────────────────────────────────────────
export const filterSets = {
  Lokation: {
    Nabolag:          { items: ["Amager","Bispebjerg","Christianshavn","Frederiksberg","Indre By","Nørrebro","Østerbro","Vesterbro","Valby","Vanløse"], subs: {} },
    "Shopping steder":{ items: ["Strøget","Torvehallerne","Fields","Fisketorvet"], subs: {} },
  },
  Type: {
    "Type af sted":      { items: ["Bageri","Barer & Pubs","Café","Food truck","Is og desserter","Restaurant"], subs: {"Bageri":["Med café","Med siddepladser"],"Café":["Med brunch","Med alkohol"],"Restaurant":["Fine dining","Casual","Buffet"]} },
    Køkkentype:          { items: ["Dansk","Italiensk","Japansk","Mexicansk","Nordisk","Thailandsk","Vegansk"], subs: {} },
    Madtype:             { items: ["Brunch","Frokost","Aftensmad","Street food","Dessert"], subs: {} },
    "Type af drikkevare":{ items: ["Specialkaffe","Naturvin","Cocktails","Øl"], subs: {} },
  },
  Behov: {
    "Diæt og restriktioner": { items: ["Allergier","Gluten","Vegetar","Vegansk","Pescetar","Halal","Laktose","Kosher"], subs: {"Allergier":["Sikker for cøliakere","Er cøliaki-venligt","Glutenfri retter"],"Gluten":["Helt glutenfrit","Glutenfri muligheder"],"Vegetar":["Fuldt vegetarisk","Vegetariske muligheder"],"Vegansk":["Fuldt vegansk","Veganske muligheder"],"Laktose":["Laktosefri","Laktosefri muligheder"]} },
    Måltidstyper:            { items: ["Morgenmad","Frokost","Aftensmad","Brunch"], subs: {} },
    "Menu typer":            { items: ["À la carte","Buffet","Fast menu","Tasting"], subs: {} },
    Michelin:                { items: ["1 stjerne","2 stjerner","3 stjerner","Bib Gourmand"], subs: {} },
    Tilgængelighed:          { items: ["Kørestol","Elevator","Blindevenlig"], subs: {} },
    Børnevenlig:             { items: ["Børnestol","Puslerum","Legeplads","Børnemenu"], subs: {} },
    Hundevenlig:             { items: ["Hunde tilladt inde","Hunde tilladt ude","Vandskål"], subs: {} },
    "Lokation og udsigt":    { items: ["Havudsigt","Tagterrasse","Have","Ved vandet"], subs: {} },
    "Udendørs siddepladser": { items: ["Gårdhave","Fortov","Terrasse"], subs: {} },
    "Private siddepladser":  { items: ["Separat rum","Booth"], subs: {} },
    Selskaber:               { items: ["Fødselsdage","Firmafest","Bryllup"], subs: {} },
    Underholdning:           { items: ["Live musik","DJ","Quiz"], subs: {} },
  },
};

// ── Restaurant data ──────────────────────────────────────────
const fullProfile1 = {
  phone: "+45 33 14 42 10",
  about: "42Raw er en plantbaseret restaurant i centrum af København med rå, veganske og glutenfri retter lavet med friske, økologiske ingredienser.",
  hours: [
    ["Mandag",  [{time:"07:00–10:00",note:"Køkken lukker 09:30"},{time:"11:30–14:30"},{time:"17:00–22:00",note:"Køkken lukker 21:15"}]],
    ["Tirsdag", [{time:"07:00–10:00",note:"Køkken lukker 09:30"},{time:"11:30–14:30"},{time:"17:00–22:00",note:"Køkken lukker 21:15"}]],
    ["Onsdag",  [{time:"07:00–10:00",note:"Køkken lukker 09:30"},{time:"11:30–14:30"},{time:"17:00–22:00",note:"Køkken lukker 21:15"}]],
    ["Torsdag", [{time:"07:00–10:00",note:"Køkken lukker 09:30"},{time:"11:30–14:30"},{time:"17:00–22:00",note:"Køkken lukker 21:15"}]],
    ["Fredag",  [{time:"07:00–10:00",note:"Køkken lukker 09:30"},{time:"11:30–14:30"},{time:"17:00–23:00",note:"Køkken lukker 22:00"}]],
    ["Lørdag",  [{time:"10:00–15:00"},{time:"17:00–23:00",note:"Køkken lukker 22:00"}]],
    ["Søndag",  "Lukket"],
  ],
  facilities:      [{l:"Udendørs siddepladser",i:true},{l:"Wifi",i:false},{l:"Kørestolsvenlig",i:true},{l:"Vegansk menu",i:true}],
  payments:        ["VISA","MasterCard","MobilePay"],
  menuCategories:  ["Bowls","Smoothies","Salater","Desserter"],
  menuItems: {
    "Bowls":    [{name:"Green Power Bowl",desc:"Spinat, avocado, quinoa, edamame, tahini",price:"139 kr."},{name:"Buddha Bowl",desc:"Ris, tofu, edamame, gulerod, sesamdressing",price:"129 kr."},{name:"Tropical Bowl",desc:"Mango, kokos, granola, passionsfrugt",price:"119 kr."}],
    "Smoothies":[{name:"Tropical Green",desc:"Spinat, mango, banan, ingefær",price:"79 kr."},{name:"Berry Blast",desc:"Blåbær, jordbær, banan, mandelmælk",price:"79 kr."}],
    "Salater":  [{name:"Raw Pad Thai",desc:"Squash-nudler, peanut, lime, koriander",price:"149 kr."},{name:"Caesar Salat",desc:"Romaine, vegansk dressing, croutoner, parmesan",price:"139 kr."}],
    "Desserter":[{name:"Rå brownie",desc:"Dadler, kakao, valnødder, kokos",price:"65 kr."}],
  },
  menuLastReviewed: "12. januar 2026",
  links: {website:"42raw.dk",instagram:"@42raw",booking:"Bestil bord"},
};

const fullProfile2 = {
  phone: "+45 60 55 00 03",
  about: "H.U.G bageri er et økologisk og glutenfrit bageri i hjertet af København. Med kærlighed til råvarerne bager vi hver dag friskt brød, boller og kager — alt uden gluten.",
  hours: [["Mandag","07:30–17:30"],["Tirsdag","07:30–17:30"],["Onsdag","07:30–17:30"],["Torsdag","07:30–17:30"],["Fredag","07:30–17:30"],["Lørdag","08:00–16:00"],["Søndag","08:00–16:00"]],
  facilities:      [{l:"Udendørs siddepladser",i:true},{l:"Morgenmad",i:false},{l:"Børnestol",i:true},{l:"Hunde tilladt ude",i:true},{l:"Økologisk",i:false}],
  payments:        ["VISA","MasterCard","MobilePay","Kontanter"],
  menuCategories:  ["Brød","Boller","Bagværk","Kager","Store bestillinger"],
  menuItems: {
    "Brød":             [{name:"Robrød",desc:"Rismel, hørfrø, boghvede, solsikkekerner, carob",price:"68 kr."},{name:"Søsters sunde",desc:"Sorghummel, sesamfrø, hirsemel, hirseflager",price:"72 kr."},{name:"Lyst Surdejsbrød",desc:"Hirsemel, sorghummel, loppefrø, salt",price:"65 kr."},{name:"Grovbrød",desc:"Boghvedemel, loppefrø, salt, gær",price:"65 kr."}],
    "Boller":           [{name:"Fiberbolle",desc:"Hirsemel, loppefrø, solsikkekerner",price:"28 kr."},{name:"Morgenbolle",desc:"Rismel, gulerod, solsikke",price:"25 kr."}],
    "Bagværk":          [{name:"Kanelsnegel",desc:"Glutenfri mel, smør, kanel, kardemomme",price:"45 kr."},{name:"Tebirkes",desc:"Birkes, smør, glutenfrit wienerbrødsmel",price:"38 kr."}],
    "Kager":            [{name:"Gulerodskage",desc:"Gulerod, mandel, kanel, glasur",price:"55 kr."},{name:"Drømmekage",desc:"Kokos, brun farin, smør",price:"48 kr."}],
    "Store bestillinger":[{name:"Lagkage (10 pers)",desc:"Bestilles 3 dage i forvejen",price:"520 kr."}],
  },
  menuLastReviewed: "18. november 2025",
  links: {website:"hugbageri.dk",instagram:"@hugbageri"},
};

const stubHours = [["Mandag","10:00–22:00"],["Tirsdag","10:00–22:00"],["Onsdag","10:00–22:00"],["Torsdag","10:00–22:00"],["Fredag","10:00–23:00"],["Lørdag","10:00–23:00"],["Søndag","10:00–21:00"]];
const stub = {
  phone:"",about:"",hours:stubHours,facilities:[],payments:["VISA","MasterCard"],
  menuCategories:["Menu"],menuItems:{"Menu":[{name:"Se fuld menu",desc:"Besøg hjemmeside for fuldt menukort",price:""}]},
  menuLastReviewed:"",links:{},
};

const mk = (id,name,cuisine,price,addr,dist,rat,init,bg,open,close,has,note,prof,statusText) => ({
  id,name,cuisine,priceRange:price,address:addr,distance:dist,rating:rat,initial:init,bg,
  statusOpen:open,closingTime:close,statusText,has,note,...prof,
});

export const allRestaurants = [
  mk(1, "42Raw",             "Plantbaseret",      "330–410 kr.", "Pilestræde 32, Indre By",              "350m",  4.5, "42", "#1a1a1a", true,  "18:00", ["Helt glutenfrit","Fuldt vegansk","Laktosefri","Havudsigt","Kørestol"],       "Fuldt glutenfrit køkken",  fullProfile1, "til 18:00"),
  mk(2, "H.U.G Bageri",      "Glutenfrit bageri", "100–520 kr.", "Øster Farimagsgade 20, Kbh Ø",         "1.1km", 4.6, "HG","#2d5a3d", true,  "16:00", ["Helt glutenfrit","Fuldt vegansk","Havudsigt","Børnestol","Hunde tilladt ude"],"100% glutenfrit bageri",   fullProfile2, "til 16:00"),
  mk(3, "Palæo",             "Nordisk",           "350–550 kr.", "Bryghusgade 8, Indre By",              "600m",  4.7, "Pa","#4a6b3d", true,  "22:00", ["Helt glutenfrit","Havudsigt","Kørestol"],                                   "Alle retter kan laves glutenfri", stub, "til 22:00"),
  mk(4, "GRØD",              "Grødbar",           "80–140 kr.",  "Jægersborggade 50, Nørrebro",          "1.8km", 4.4, "GR","#8a7a60", true,  "16:00", ["Helt glutenfrit","Fuldt vegansk","Havudsigt"],                              "Glutenfri havregryn tilgængelig", stub),
  mk(5, "Souls",             "Vegansk café",      "120–220 kr.", "Gothersgade 48, Indre By",             "450m",  4.5, "So","#5a7a5a", true,  "17:00", ["Helt glutenfrit","Fuldt vegansk","Havudsigt","Laktosefri"],                  "Dedikeret vegansk køkken", stub),
  mk(6, "SimpleRaw",         "Raw food",          "180–320 kr.", "Guldbergsgade 8, Nørrebro",            "2.0km", 4.3, "SR","#6a8a5a", true,  "19:00", ["Helt glutenfrit","Fuldt vegansk","Havudsigt"],                              "Alt glutenfrit og råt",    stub),
  mk(7, "The Organic Boho",  "Økologisk café",    "90–180 kr.",  "Ravnsborggade 14, Nørrebro",           "1.9km", 4.2, "OB","#7a6a4a", true,  "18:00", ["Helt glutenfrit","Havudsigt","Børnestol"],                                  "Glutenfri brunch dagligt", stub),
  mk(8, "Green Bite",        "Plantebaseret",     "110–190 kr.", "Istedgade 93, Vesterbro",              "2.3km", 4.1, "GB","#4a7a5a", true,  "20:00", ["Helt glutenfrit","Fuldt vegansk","Havudsigt"],                              "Glutenfri muligheder",     stub),
  mk(9, "Café Retro",        "Økologisk café",    "70–150 kr.",  "Knabrostræde 26, Indre By",            "500m",  4.0, "CR","#6a5a4a", true,  "17:00", ["Helt glutenfrit","Havudsigt"],                                              "Har glutenfri brød",       stub),
  mk(10,"Hart Bageri",       "Bageri",            "60–120 kr.",  "Gl. Kongevej 109, Frederiksberg",      "2.5km", 4.6, "HB","#3a3a3a", true,  "17:00", ["Helt glutenfrit","Havudsigt"],                                              "Glutenfri brød dagligt",   stub),
  mk(11,"Mother",            "Pizza",             "140–280 kr.", "Høkerboderne 9, Indre By",             "400m",  4.3, "Mo","#8a4a3a", true,  "23:00", ["Helt glutenfrit","Havudsigt","Børnestol"],                                  "Glutenfri pizzabund +30kr",stub),
  mk(12,"Sögreni",           "Nordisk brasserie", "280–480 kr.", "Strandvejen 12, Østerbro",             "1.4km", 4.7, "Sö","#2a4a5e", true,  "22:00", ["Havudsigt","Kørestol","Fuldt vegetarisk","Tagterrasse"],                    "Har enkelte glutenfri retter", stub),
  mk(13,"Café Dyrehaven",    "Café & brunch",     "90–180 kr.",  "Sønder Boulevard 72, Vesterbro",       "2.1km", 4.3, "CD","#6b5a4a", true,  "23:00", ["Helt glutenfrit","Børnestol","Hunde tilladt inde"],                         "Ingen havudsigt",          stub),
  mk(14,"Papirøen",          "Street food",       "80–200 kr.",  "Trangravsvej 14, Christianshavn",      "1.6km", 4.2, "Pi","#5a6a7a", true,  "21:00", ["Havudsigt","Børnestol"],                                                    "Flere boder med glutenfri",stub),
  mk(15,"La Banchina",       "Havnebar",          "150–300 kr.", "Refshalevej 141, Refshaleøen",         "3.2km", 4.5, "LB","#4a5a6a", true,  "22:00", ["Helt glutenfrit","Ved vandet","Havudsigt"],                                 "Ved havnen",               stub),
  mk(16,"Sidecar",           "Cocktailbar",       "120–250 kr.", "Studiestræde 6, Indre By",             "550m",  4.4, "Sc","#5a3a4a", true,  "02:00", ["Havudsigt"],                                                                "Kun drikkevarer",          stub, "lukker i morgen kl. 02:00"),
  mk(17,"Maekhong Thai",     "Thailandsk",        "190–300 kr.", "Ryesgade 84, Østerbro",                "1.3km", 4.1, "MT","#7a3b3b", false, "16:00", ["Halal"],                                                                    "Kan tilpasse efter behov", stub, "åbner kl. 16:00"),
  mk(18,"Kebabistan",        "Kebab",             "60–110 kr.",  "Nørrebrogade 95, Nørrebro",            "1.7km", 3.9, "Ke","#7a5a3a", true,  "23:00", ["Halal"],                                                                    "Intet glutenfrit udvalg",  stub),
  mk(19,"Sushi Neko",        "Japansk",           "200–400 kr.", "Nørre Farimagsgade 41, Indre By",      "700m",  4.4, "SN","#3a3a5a", true,  "22:00", [],                                                                           "",                         stub),
  mk(20,"Bistro Boheme",     "Fransk bistro",     "250–450 kr.", "Esplanaden 8, Indre By",               "900m",  4.5, "BB","#4a3a3a", true,  "23:00", [],                                                                           "",                         stub),
  mk(21,"Noodle House",      "Kinesisk",          "80–150 kr.",  "Istedgade 41, Vesterbro",              "2.4km", 3.8, "NH","#5a4a3a", true,  "21:30", [],                                                                           "",                         stub),
];

// ── Micro-components ─────────────────────────────────────────
export const Dot = () => (
  <span style={{width:3,height:3,borderRadius:"50%",background:"#d0d0d0",flexShrink:0,display:"inline-block"}}/>
);

export const Check = ({size=10, color="#fff"}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20 6L9 17l-5-5"/>
  </svg>
);

export const StatusBar = () => (
  <div style={{height:54,padding:"14px 28px 0",display:"flex",justifyContent:"space-between",alignItems:"center",flexShrink:0}}>
    <span style={{fontSize:15,fontWeight:600,color:"#0f0f0f"}}>9:41</span>
    <div style={{display:"flex",gap:5,alignItems:"center"}}>
      {/* Signal bars */}
      <svg width="17" height="12" viewBox="0 0 17 12">
        <rect x="0"  y="3" width="2.5" height="9"  rx="1" fill="#0f0f0f"/>
        <rect x="4"  y="2" width="2.5" height="10" rx="1" fill="#0f0f0f"/>
        <rect x="8"  y="1" width="2.5" height="11" rx="1" fill="#0f0f0f"/>
        <rect x="12" y="0" width="2.5" height="12" rx="1" fill="#0f0f0f"/>
      </svg>
      {/* Wifi */}
      <svg width="16" height="12" viewBox="0 0 16 12">
        <path d="M8 2.4C5.6 2.4 3.4 3.4 1.8 5L0 3.2C2.2 1.2 5 0 8 0s5.8 1.2 8 3.2L14.2 5C12.6 3.4 10.4 2.4 8 2.4z" fill="#0f0f0f"/>
        <path d="M8 6.8c-1.6 0-3 .6-4.1 1.7L2.1 6.7C3.8 5.2 5.8 4.4 8 4.4s4.2.8 5.9 2.3l-1.8 1.8C11 7.4 9.6 6.8 8 6.8z" fill="#0f0f0f"/>
        <circle cx="8" cy="11" r="1.8" fill="#0f0f0f"/>
      </svg>
      {/* Battery */}
      <svg width="27" height="13" viewBox="0 0 27 13">
        <rect x="0" y="1" width="22" height="11" rx="3.5" stroke="#0f0f0f" strokeWidth="1" fill="none"/>
        <rect x="2" y="3" width="16" height="7"  rx="2"   fill="#0f0f0f"/>
        <rect x="23" y="4.5" width="2.5" height="4" rx="1" fill="#0f0f0f" opacity="0.4"/>
      </svg>
    </div>
  </div>
);

// ── Draggable bottom sheet ────────────────────────────────────
export function BottomSheet({children, visible, onClose, height="78%", zBase=10}) {
  const startY = useRef(0);
  const curY   = useRef(0);
  const ref    = useRef(null);
  const drag   = useRef(false);

  const ts = (e) => { startY.current = e.touches[0].clientY; drag.current = true; };
  const tm = (e) => {
    if (!drag.current) return;
    curY.current = e.touches[0].clientY - startY.current;
    if (curY.current > 0 && ref.current) {
      ref.current.style.transform  = `translateY(${curY.current}px)`;
      ref.current.style.transition = "none";
    }
  };
  const te = () => {
    drag.current = false;
    if (curY.current > 80) onClose();
    else if (ref.current) {
      ref.current.style.transform  = "translateY(0)";
      ref.current.style.transition = "transform 0.3s cubic-bezier(0.32,0.72,0,1)";
    }
    curY.current = 0;
  };

  const md = (e) => {
    startY.current = e.clientY; drag.current = true;
    const mm = (ev) => {
      curY.current = ev.clientY - startY.current;
      if (curY.current > 0 && ref.current) {
        ref.current.style.transform  = `translateY(${curY.current}px)`;
        ref.current.style.transition = "none";
      }
    };
    const mu = () => {
      drag.current = false;
      if (curY.current > 80) onClose();
      else if (ref.current) {
        ref.current.style.transform  = "translateY(0)";
        ref.current.style.transition = "transform 0.3s cubic-bezier(0.32,0.72,0,1)";
      }
      curY.current = 0;
      window.removeEventListener("mousemove", mm);
      window.removeEventListener("mouseup",   mu);
    };
    window.addEventListener("mousemove", mm);
    window.addEventListener("mouseup",   mu);
  };

  return (<>
    {visible && (
      <div
        onClick={onClose}
        style={{position:"absolute",inset:0,background:"rgba(0,0,0,0.35)",zIndex:zBase,transition:"opacity 0.3s"}}
      />
    )}
    <div
      ref={ref}
      style={{
        position:"absolute",bottom:0,left:0,right:0,height,background:"#fff",
        borderRadius:"22px 22px 0 0",zIndex:zBase+10,display:"flex",flexDirection:"column",
        transform:visible?"translateY(0)":"translateY(100%)",
        transition:"transform 0.3s cubic-bezier(0.32,0.72,0,1)",
        boxShadow:"0 -8px 40px rgba(0,0,0,0.08)",
        pointerEvents:visible?"auto":"none",
      }}
    >
      <div
        onTouchStart={ts} onTouchMove={tm} onTouchEnd={te} onMouseDown={md}
        style={{padding:"12px 20px 8px",cursor:"grab",flexShrink:0}}
      >
        <div style={{width:36,height:4,borderRadius:4,background:"#ddd",margin:"0 auto"}}/>
      </div>
      {children}
    </div>
  </>);
}

// ── Language & Currency Dropdowns ───────────────────────────
// Shared between welcome flow and settings/localization
export function LanguageCurrencyDropdowns({ language, currency, onLanguageChange, onCurrencyChange, showDescriptions = true }) {
  const [langOpen, setLangOpen] = useState(false);
  const [currOpen, setCurrOpen] = useState(false);

  const languages = [
    { code: "en", name: "English", flag: "🇬🇧" },
    { code: "da", name: "Dansk", flag: "🇩🇰" },
    { code: "de", name: "Deutsch", flag: "🇩🇪" },
    { code: "sv", name: "Svenska", flag: "🇸🇪" },
    { code: "no", name: "Norsk", flag: "🇳🇴" },
    { code: "it", name: "Italiano", flag: "🇮🇹" },
    { code: "fr", name: "Français", flag: "🇫🇷" },
  ];

  const currencies = [
    { code: "USD", name: "US dollar", symbol: "$" },
    { code: "GBP", name: "British pound", symbol: "£" },
    { code: "DKK", name: "Danish krone", symbol: "kr." },
  ];

  const selectedLang = languages.find(l => l.code === language) || languages[0];
  const selectedCurr = currencies.find(c => c.code === currency) || currencies[2];

  return (
    <div style={{ width: "100%" }}>
      {/* Language selector */}
      <div style={{ marginBottom: 32 }}>
        <div style={{
          fontSize: 16,
          fontWeight: 600,
          color: "#0f0f0f",
          marginBottom: showDescriptions ? 8 : 12,
        }}>
          {language === "da" ? "Sprog" : "Language"}
        </div>

        {showDescriptions && (
          <div style={{
            fontSize: 13,
            fontWeight: 400,
            color: "#888",
            marginBottom: 12,
            lineHeight: "18px",
          }}>
            {language === "da"
              ? "Vælg dit foretrukne sprog til appen"
              : "Set your preferred language for the app"}
          </div>
        )}

        <div style={{ position: "relative" }}>
          <div
            onClick={() => setLangOpen(!langOpen)}
            style={{
              width: "100%",
              height: 50,
              background: "#f5f5f5",
              border: "1px solid #e8e8e8",
              borderRadius: 10,
              padding: "0 16px",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              cursor: "pointer",
            }}
          >
            <div style={{
              display: "flex",
              alignItems: "center",
              gap: 8,
              fontSize: 14,
              color: "#0f0f0f",
            }}>
              <span>{selectedLang.flag}</span>
              <span>{selectedLang.name}</span>
            </div>
            <span style={{ fontSize: 12, color: "#888" }}>
              {langOpen ? "▲" : "▼"}
            </span>
          </div>

          {langOpen && (
            <div style={{
              position: "absolute",
              top: 54,
              left: 0,
              right: 0,
              background: "#fff",
              border: "1px solid #e8e8e8",
              borderRadius: 10,
              boxShadow: "0 4px 12px rgba(0,0,0,0.08)",
              zIndex: 100,
              maxHeight: 280,
              overflowY: "auto",
            }}>
              {languages.map((lang, i) => (
                <div
                  key={lang.code}
                  onClick={() => {
                    onLanguageChange(lang.code);
                    setLangOpen(false);
                  }}
                  style={{
                    padding: "12px 16px",
                    display: "flex",
                    alignItems: "center",
                    gap: 8,
                    cursor: "pointer",
                    background: lang.code === language ? "#fef8f2" : "#fff",
                    borderBottom: i < languages.length - 1 ? "1px solid #f2f2f2" : "none",
                  }}
                >
                  <span>{lang.flag}</span>
                  <span style={{ fontSize: 14, color: "#0f0f0f" }}>{lang.name}</span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Currency selector */}
      <div>
        <div style={{
          fontSize: 16,
          fontWeight: 600,
          color: "#0f0f0f",
          marginBottom: showDescriptions ? 8 : 12,
        }}>
          {language === "da" ? "Valuta" : "Currency"}
        </div>

        {showDescriptions && (
          <div style={{
            fontSize: 13,
            fontWeight: 400,
            color: "#888",
            marginBottom: 12,
            lineHeight: "18px",
          }}>
            {language === "da"
              ? "Valutakurser opdateres hver 24. time, så faktiske priser kan variere lidt."
              : "Exchange rates are updated once every 24 hrs, so actual prices may vary slightly."}
          </div>
        )}

        <div style={{ position: "relative" }}>
          <div
            onClick={() => setCurrOpen(!currOpen)}
            style={{
              width: "100%",
              height: 50,
              background: "#f5f5f5",
              border: "1px solid #e8e8e8",
              borderRadius: 10,
              padding: "0 16px",
              display: "flex",
              alignItems: "center",
              justifyContent: "space-between",
              cursor: "pointer",
            }}
          >
            <div style={{ fontSize: 14, color: "#0f0f0f" }}>
              {selectedCurr.name} ({selectedCurr.symbol})
            </div>
            <span style={{ fontSize: 12, color: "#888" }}>
              {currOpen ? "▲" : "▼"}
            </span>
          </div>

          {currOpen && (
            <div style={{
              position: "absolute",
              top: 54,
              left: 0,
              right: 0,
              background: "#fff",
              border: "1px solid #e8e8e8",
              borderRadius: 10,
              boxShadow: "0 4px 12px rgba(0,0,0,0.08)",
              zIndex: 100,
            }}>
              {currencies.map((curr, i) => (
                <div
                  key={curr.code}
                  onClick={() => {
                    onCurrencyChange(curr.code);
                    setCurrOpen(false);
                  }}
                  style={{
                    padding: "12px 16px",
                    cursor: "pointer",
                    background: curr.code === currency ? "#fef8f2" : "#fff",
                    borderBottom: i < currencies.length - 1 ? "1px solid #f2f2f2" : "none",
                  }}
                >
                  <span style={{ fontSize: 14, color: "#0f0f0f" }}>
                    {curr.name} ({curr.symbol})
                  </span>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

// ── Opening Hours Section ──────────────────────────────────────
// Shared collapsible opening hours component
// Used in both business profile and information page
// Expanded view is identical; only collapsed view differs (title + today's preview)
export function OpeningHoursSection({
  title,
  hours,
  todayPreview, // Only shown on business profile when collapsed
  contact,
  variant = "profile" // "profile" or "info" (affects styling)
}) {
  const [isOpen, setIsOpen] = useState(false);
  const isProfile = variant === "profile";

  return (
    <div style={{ padding: isProfile ? "0 24px 16px" : "0", marginBottom: isProfile ? 0 : 24 }}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        style={{
          width: "100%",
          display: "flex",
          alignItems: isProfile ? "flex-start" : "center",
          justifyContent: "space-between",
          background: "none",
          border: "none",
          cursor: "pointer",
          fontFamily: "inherit",
          padding: isProfile ? 0 : "8px 0",
          textAlign: "left",
          borderBottom: !isProfile ? "1px solid #f2f2f2" : "none",
          paddingBottom: !isProfile ? 16 : 0,
        }}
      >
        <div>
          <h3 style={{
            margin: 0,
            fontSize: isProfile ? 18 : 15,
            fontWeight: isProfile ? 680 : 600,
            color: "#0f0f0f"
          }}>
            {title}
          </h3>
          {!isOpen && todayPreview && (
            <div style={{ fontSize: 13, color: "#888", marginTop: 4 }}>
              I dag: {todayPreview === "Lukket"
                ? <span style={{ color: "#c9403a" }}>{todayPreview}</span>
                : todayPreview}
            </div>
          )}
        </div>
        <svg
          width="14"
          height="14"
          viewBox="0 0 24 24"
          fill="none"
          stroke={isProfile ? "#999" : "#888"}
          strokeWidth="2.5"
          strokeLinecap="round"
          style={{
            transition: "transform 0.25s",
            transform: isOpen ? "rotate(180deg)" : "rotate(0)",
            marginTop: isProfile ? 4 : 0,
            flexShrink: 0
          }}
        >
          <path d="M6 9l6 6 6-6"/>
        </svg>
      </button>

      {isOpen && (
        <div style={{
          marginTop: isProfile ? 14 : 12,
          background: isProfile ? "#fafafa" : "transparent",
          borderRadius: isProfile ? 14 : 0,
          padding: isProfile ? 16 : 0
        }}>
          {/* Hours table */}
          <div style={{ marginBottom: contact ? 16 : 0 }}>
            {isProfile && (
              <div style={{
                fontSize: 11.5,
                fontWeight: 620,
                color: "#666",
                textTransform: "uppercase",
                letterSpacing: "0.04em",
                marginBottom: 10
              }}>
                Åbningstider
              </div>
            )}
            {(hours || []).map(([day, slots], idx) => {
              const isString = typeof slots === "string";
              const isArr = Array.isArray(slots);

              if (isProfile) {
                return (
                  <div
                    key={idx}
                    style={{
                      display: "flex",
                      padding: "5px 0",
                      borderBottom: idx < (hours || []).length - 1 ? "1px solid #ececec" : "none"
                    }}
                  >
                    <div style={{
                      width: 90,
                      flexShrink: 0,
                      fontSize: 13.5,
                      fontWeight: 500,
                      color: "#333",
                      paddingTop: isArr && slots.length > 1 ? 2 : 0
                    }}>
                      {day}
                    </div>
                    <div style={{ flex: 1 }}>
                      {isString && (
                        <div style={{
                          fontSize: 13.5,
                          color: slots === "Lukket" ? "#c9403a" : "#444",
                          fontWeight: slots === "Lukket" ? 520 : 460,
                          fontVariantNumeric: "tabular-nums"
                        }}>
                          {slots}
                        </div>
                      )}
                      {isArr && slots.map((slot, si) => (
                        <div
                          key={si}
                          style={{
                            display: "flex",
                            justifyContent: "space-between",
                            alignItems: "baseline",
                            padding: slots.length > 1 ? "2px 0" : "0",
                            gap: 8
                          }}
                        >
                          <span style={{
                            fontSize: 13.5,
                            color: "#444",
                            fontVariantNumeric: "tabular-nums",
                            fontWeight: 460
                          }}>
                            {slot.time}
                          </span>
                          {slot.note && (
                            <span style={{
                              fontSize: 11.5,
                              color: "#999",
                              fontWeight: 440
                            }}>
                              ({slot.note})
                            </span>
                          )}
                        </div>
                      ))}
                    </div>
                  </div>
                );
              } else {
                // Info page variant - simpler
                return (
                  <div
                    key={idx}
                    style={{
                      display: "flex",
                      justifyContent: "space-between",
                      padding: "6px 0",
                      fontSize: 13,
                      color: "#555"
                    }}
                  >
                    <span>{day}</span>
                    <span>
                      {typeof slots === "string"
                        ? slots
                        : Array.isArray(slots)
                          ? slots.map(t => t.time || t).join(", ")
                          : slots}
                    </span>
                  </div>
                );
              }
            })}
          </div>

          {/* Contact section (always shown when expanded) */}
          {contact && (
            <>
              <div style={{ height: 1, background: "#e8e8e8", marginBottom: 16 }} />
              <div>
                <div style={{
                  fontSize: 11.5,
                  fontWeight: 620,
                  color: "#666",
                  textTransform: "uppercase",
                  letterSpacing: "0.04em",
                  marginBottom: 10
                }}>
                  Kontakt
                </div>
                {contact.phone && (
                  <div style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 0",
                    borderBottom: "1px solid #ececec",
                    fontSize: 14
                  }}>
                    <span style={{ color: "#555" }}>Telefon</span>
                    <span style={{ color: "#222", fontWeight: 520 }}>{contact.phone}</span>
                  </div>
                )}
                {contact.links?.website && (
                  <div style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 0",
                    borderBottom: "1px solid #ececec",
                    fontSize: 14
                  }}>
                    <span style={{ color: "#555" }}>Hjemmeside</span>
                    <span style={{ color: ACCENT, fontWeight: 520 }}>{contact.links.website}</span>
                  </div>
                )}
                {contact.links?.instagram && (
                  <div style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 0",
                    borderBottom: "1px solid #ececec",
                    fontSize: 14
                  }}>
                    <span style={{ color: "#555" }}>Instagram</span>
                    <span style={{ color: ACCENT, fontWeight: 520 }}>{contact.links.instagram}</span>
                  </div>
                )}
                {contact.links?.booking && (
                  <div style={{
                    display: "flex",
                    justifyContent: "space-between",
                    alignItems: "center",
                    padding: "8px 0",
                    fontSize: 14
                  }}>
                    <span style={{ color: "#555" }}>Booking</span>
                    <span style={{ color: ACCENT, fontWeight: 520 }}>{contact.links.booking}</span>
                  </div>
                )}
              </div>
            </>
          )}
        </div>
      )}
    </div>
  );
}

// ═══════════════════════════════════════════════════════════════
// Tab bar — Bottom navigation
// ═══════════════════════════════════════════════════════════════
export function TabBar({ activeTab, onChangeTab }) {
  const tabs = [
    {
      key: "udforsk",
      label: "Udforsk",
      icon: "M21 21l-4.35-4.35M11 19a8 8 0 100-16 8 8 0 000 16z"
    },
    {
      key: "mine-behov",
      label: "Mine behov",
      icon: "M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"
    },
    {
      key: "profil",
      label: "Profil",
      icon: "M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8z"
    },
  ];

  return (
    <div style={{
      position: "absolute",
      bottom: 0,
      left: 0,
      right: 0,
      height: 80,
      background: "rgba(255,255,255,0.95)",
      backdropFilter: "blur(16px)",
      borderTop: "1px solid #f0f0f0",
      display: "flex",
      justifyContent: "space-around",
      alignItems: "flex-start",
      paddingTop: 10,
      zIndex: 5,
    }}>
      {tabs.map(t => (
        <button
          key={t.key}
          onClick={() => onChangeTab?.(t.key)}
          style={{
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
            gap: 3,
            background: "none",
            border: "none",
            cursor: "pointer",
            padding: "2px 16px",
          }}
        >
          <svg
            width="21"
            height="21"
            viewBox="0 0 24 24"
            fill="none"
            stroke={activeTab === t.key ? ACCENT : "#bbb"}
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          >
            <path d={t.icon} />
          </svg>
          <span style={{
            fontSize: 10.5,
            fontWeight: activeTab === t.key ? 620 : 480,
            color: activeTab === t.key ? ACCENT : "#bbb"
          }}>
            {t.label}
          </span>
        </button>
      ))}
    </div>
  );
}
