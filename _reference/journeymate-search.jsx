import { useState, useRef } from "react";

// ── Design tokens ─────────────────────────────────────────────
const ACCENT       = "#e8751a";
const GREEN        = "#1a9456";
const GREEN_BG     = "#f0f9f3";
const GREEN_BORDER = "#d0ecd8";

// ── Micro-components ─────────────────────────────────────────
const Dot = () => (
  <span style={{width:3,height:3,borderRadius:"50%",background:"#d0d0d0",flexShrink:0,display:"inline-block"}}/>
);
const Check = ({size=10, color="#fff"}) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none" stroke={color} strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round">
    <path d="M20 6L9 17l-5-5"/>
  </svg>
);
const StatusBar = () => (
  <div style={{height:54,padding:"14px 28px 0",display:"flex",justifyContent:"space-between",alignItems:"center",flexShrink:0}}>
    <span style={{fontSize:15,fontWeight:600,color:"#0f0f0f"}}>9:41</span>
    <div style={{display:"flex",gap:5,alignItems:"center"}}>
      <svg width="17" height="12" viewBox="0 0 17 12">
        <rect x="0" y="3" width="2.5" height="9" rx="1" fill="#0f0f0f"/>
        <rect x="4" y="2" width="2.5" height="10" rx="1" fill="#0f0f0f"/>
        <rect x="8" y="1" width="2.5" height="11" rx="1" fill="#0f0f0f"/>
        <rect x="12" y="0" width="2.5" height="12" rx="1" fill="#0f0f0f"/>
      </svg>
      <svg width="16" height="12" viewBox="0 0 16 12">
        <path d="M8 2.4C5.6 2.4 3.4 3.4 1.8 5L0 3.2C2.2 1.2 5 0 8 0s5.8 1.2 8 3.2L14.2 5C12.6 3.4 10.4 2.4 8 2.4z" fill="#0f0f0f"/>
        <path d="M8 6.8c-1.6 0-3 .6-4.1 1.7L2.1 6.7C3.8 5.2 5.8 4.4 8 4.4s4.2.8 5.9 2.3l-1.8 1.8C11 7.4 9.6 6.8 8 6.8z" fill="#0f0f0f"/>
        <circle cx="8" cy="11" r="1.8" fill="#0f0f0f"/>
      </svg>
      <svg width="27" height="13" viewBox="0 0 27 13">
        <rect x="0" y="1" width="22" height="11" rx="3.5" stroke="#0f0f0f" strokeWidth="1" fill="none"/>
        <rect x="2" y="3" width="16" height="7" rx="2" fill="#0f0f0f"/>
        <rect x="23" y="4.5" width="2.5" height="4" rx="1" fill="#0f0f0f" opacity="0.4"/>
      </svg>
    </div>
  </div>
);

// ── BottomSheet ───────────────────────────────────────────────
function BottomSheet({children, visible, onClose, height="78%", zBase=10}) {
  const startY = useRef(0), curY = useRef(0), ref = useRef(null), drag = useRef(false);
  const ts = (e) => { startY.current = e.touches[0].clientY; drag.current = true; };
  const tm = (e) => {
    if (!drag.current) return;
    curY.current = e.touches[0].clientY - startY.current;
    if (curY.current > 0 && ref.current) { ref.current.style.transform=`translateY(${curY.current}px)`; ref.current.style.transition="none"; }
  };
  const te = () => {
    drag.current = false;
    if (curY.current > 80) onClose();
    else if (ref.current) { ref.current.style.transform="translateY(0)"; ref.current.style.transition="transform 0.3s cubic-bezier(0.32,0.72,0,1)"; }
    curY.current = 0;
  };
  const md = (e) => {
    startY.current = e.clientY; drag.current = true;
    const mm = (ev) => { curY.current = ev.clientY - startY.current; if (curY.current>0&&ref.current){ref.current.style.transform=`translateY(${curY.current}px)`;ref.current.style.transition="none";} };
    const mu = () => { drag.current=false; if(curY.current>80)onClose(); else if(ref.current){ref.current.style.transform="translateY(0)";ref.current.style.transition="transform 0.3s cubic-bezier(0.32,0.72,0,1)";} curY.current=0; window.removeEventListener("mousemove",mm); window.removeEventListener("mouseup",mu); };
    window.addEventListener("mousemove",mm); window.addEventListener("mouseup",mu);
  };
  return (<>
    {visible && <div onClick={onClose} style={{position:"absolute",inset:0,background:"rgba(0,0,0,0.35)",zIndex:zBase,transition:"opacity 0.3s"}}/>}
    <div ref={ref} style={{position:"absolute",bottom:0,left:0,right:0,height,background:"#fff",borderRadius:"22px 22px 0 0",zIndex:zBase+10,display:"flex",flexDirection:"column",transform:visible?"translateY(0)":"translateY(100%)",transition:"transform 0.3s cubic-bezier(0.32,0.72,0,1)",boxShadow:"0 -8px 40px rgba(0,0,0,0.08)",pointerEvents:visible?"auto":"none"}}>
      <div onTouchStart={ts} onTouchMove={tm} onTouchEnd={te} onMouseDown={md} style={{padding:"12px 20px 8px",cursor:"grab",flexShrink:0}}>
        <div style={{width:36,height:4,borderRadius:4,background:"#ddd",margin:"0 auto"}}/>
      </div>
      {children}
    </div>
  </>);
}

// ── Filter data ───────────────────────────────────────────────
const filterSets = {
  Lokation: {
    Nabolag: { items:["Amager","Bispebjerg","Christianshavn","Frederiksberg","Indre By","Nørrebro","Østerbro","Vesterbro","Valby","Vanløse"], subs:{} },
    "Shopping steder": { items:["Strøget","Torvehallerne","Fields","Fisketorvet"], subs:{} },
  },
  Type: {
    "Type af sted": { items:["Bageri","Barer & Pubs","Café","Food truck","Is og desserter","Restaurant"], subs:{"Bageri":["Med café","Med siddepladser"],"Café":["Med brunch","Med alkohol"],"Restaurant":["Fine dining","Casual","Buffet"]} },
    Køkkentype: { items:["Dansk","Italiensk","Japansk","Mexicansk","Nordisk","Thailandsk","Vegansk"], subs:{} },
    Madtype: { items:["Brunch","Frokost","Aftensmad","Street food","Dessert"], subs:{} },
    "Type af drikkevare": { items:["Specialkaffe","Naturvin","Cocktails","Øl"], subs:{} },
  },
  Behov: {
    "Diæt og restriktioner": { items:["Allergier","Gluten","Vegetar","Vegansk","Pescetar","Halal","Laktose","Kosher"], subs:{"Allergier":["Sikker for cøliakere","Er cøliaki-venligt","Glutenfri retter"],"Gluten":["Helt glutenfrit","Glutenfri muligheder"],"Vegetar":["Fuldt vegetarisk","Vegetariske muligheder"],"Vegansk":["Fuldt vegansk","Veganske muligheder"],"Laktose":["Laktosefri","Laktosefri muligheder"]} },
    Måltidstyper: { items:["Morgenmad","Frokost","Aftensmad","Brunch"], subs:{} },
    "Menu typer": { items:["À la carte","Buffet","Fast menu","Tasting"], subs:{} },
    Michelin: { items:["1 stjerne","2 stjerner","3 stjerner","Bib Gourmand"], subs:{} },
    Tilgængelighed: { items:["Kørestol","Elevator","Blindevenlig"], subs:{} },
    Børnevenlig: { items:["Børnestol","Puslerum","Legeplads","Børnemenu"], subs:{} },
    Hundevenlig: { items:["Hunde tilladt inde","Hunde tilladt ude","Vandskål"], subs:{} },
    "Lokation og udsigt": { items:["Havudsigt","Tagterrasse","Have","Ved vandet"], subs:{} },
    "Udendørs siddepladser": { items:["Gårdhave","Fortov","Terrasse"], subs:{} },
  },
};

const trainStations = ["København H","Nørreport","Østerport","Vesterport","Flintholm"];

// ── Restaurant data ───────────────────────────────────────────
const stub = {phone:"",about:"",hours:[["Mandag","10:00–22:00"],["Tirsdag","10:00–22:00"],["Onsdag","10:00–22:00"],["Torsdag","10:00–22:00"],["Fredag","10:00–23:00"],["Lørdag","10:00–23:00"],["Søndag","10:00–21:00"]],facilities:[],payments:["VISA","MasterCard"],menuCategories:["Menu"],menuItems:{"Menu":[{name:"Se fuld menu",desc:"Besøg hjemmeside for fuldt menukort",price:""}]},menuLastReviewed:"",links:{}};
const mk = (id,name,cuisine,price,addr,dist,rat,init,bg,open,close,has,note,prof,statusText) => ({id,name,cuisine,priceRange:price,address:addr,distance:dist,rating:rat,initial:init,bg,statusOpen:open,closingTime:close,statusText,has,note,...prof});
const allRestaurants = [
  mk(1,"42Raw","Plantbaseret","330–410 kr.","Pilestræde 32, Indre By","350m",4.5,"42","#1a1a1a",true,"18:00",["Helt glutenfrit","Fuldt vegansk","Laktosefri","Havudsigt","Kørestol"],"Fuldt glutenfrit køkken",stub,"til 18:00"),
  mk(2,"H.U.G Bageri","Glutenfrit bageri","100–520 kr.","Øster Farimagsgade 20, Kbh Ø","1.1km",4.6,"HG","#2d5a3d",true,"16:00",["Helt glutenfrit","Fuldt vegansk","Havudsigt","Børnestol","Hunde tilladt ude"],"100% glutenfrit bageri",stub,"til 16:00"),
  mk(3,"Palæo","Nordisk","350–550 kr.","Bryghusgade 8, Indre By","600m",4.7,"Pa","#4a6b3d",true,"22:00",["Helt glutenfrit","Havudsigt","Kørestol"],"Alle retter kan laves glutenfri",stub,"til 22:00"),
  mk(4,"GRØD","Grødbar","80–140 kr.","Jægersborggade 50, Nørrebro","1.8km",4.4,"GR","#8a7a60",true,"16:00",["Helt glutenfrit","Fuldt vegansk","Havudsigt"],"Glutenfri havregryn tilgængelig",stub),
  mk(5,"Souls","Vegansk café","120–220 kr.","Gothersgade 48, Indre By","450m",4.5,"So","#5a7a5a",true,"17:00",["Helt glutenfrit","Fuldt vegansk","Havudsigt","Laktosefri"],"Dedikeret vegansk køkken",stub),
  mk(6,"SimpleRaw","Raw food","180–320 kr.","Guldbergsgade 8, Nørrebro","2.0km",4.3,"SR","#6a8a5a",true,"19:00",["Helt glutenfrit","Fuldt vegansk","Havudsigt"],"Alt glutenfrit og råt",stub),
  mk(7,"The Organic Boho","Økologisk café","90–180 kr.","Ravnsborggade 14, Nørrebro","1.9km",4.2,"OB","#7a6a4a",true,"18:00",["Helt glutenfrit","Havudsigt","Børnestol"],"Glutenfri brunch dagligt",stub),
  mk(8,"Green Bite","Plantebaseret","110–190 kr.","Istedgade 93, Vesterbro","2.3km",4.1,"GB","#4a7a5a",true,"20:00",["Helt glutenfrit","Fuldt vegansk","Havudsigt"],"Glutenfri muligheder",stub),
  mk(9,"Café Retro","Økologisk café","70–150 kr.","Knabrostræde 26, Indre By","500m",4.0,"CR","#6a5a4a",true,"17:00",["Helt glutenfrit","Havudsigt"],"Har glutenfri brød",stub),
  mk(10,"Hart Bageri","Bageri","60–120 kr.","Gl. Kongevej 109, Frederiksberg","2.5km",4.6,"HB","#3a3a3a",true,"17:00",["Helt glutenfrit","Havudsigt"],"Glutenfri brød dagligt",stub),
  mk(11,"Mother","Pizza","140–280 kr.","Høkerboderne 9, Indre By","400m",4.3,"Mo","#8a4a3a",true,"23:00",["Helt glutenfrit","Havudsigt","Børnestol"],"Glutenfri pizzabund +30kr",stub),
  mk(12,"Sögreni","Nordisk brasserie","280–480 kr.","Strandvejen 12, Østerbro","1.4km",4.7,"Sö","#2a4a5e",true,"22:00",["Havudsigt","Kørestol","Fuldt vegetarisk","Tagterrasse"],"Har enkelte glutenfri retter",stub),
  mk(13,"Café Dyrehaven","Café & brunch","90–180 kr.","Sønder Boulevard 72, Vesterbro","2.1km",4.3,"CD","#6b5a4a",true,"23:00",["Helt glutenfrit","Børnestol","Hunde tilladt inde"],"Ingen havudsigt",stub),
  mk(14,"Papirøen","Street food","80–200 kr.","Trangravsvej 14, Christianshavn","1.6km",4.2,"Pi","#5a6a7a",true,"21:00",["Havudsigt","Børnestol"],"Flere boder med glutenfri",stub),
  mk(15,"La Banchina","Havnebar","150–300 kr.","Refshalevej 141, Refshaleøen","3.2km",4.5,"LB","#4a5a6a",true,"22:00",["Helt glutenfrit","Ved vandet","Havudsigt"],"Ved havnen",stub),
  mk(16,"Sidecar","Cocktailbar","120–250 kr.","Studiestræde 6, Indre By","550m",4.4,"Sc","#5a3a4a",true,"02:00",["Havudsigt"],"Kun drikkevarer",stub,"lukker i morgen kl. 02:00"),
  mk(17,"Maekhong Thai","Thailandsk","190–300 kr.","Ryesgade 84, Østerbro","1.3km",4.1,"MT","#7a3b3b",false,"16:00",["Halal"],"Kan tilpasse efter behov",stub,"åbner kl. 16:00"),
  mk(18,"Kebabistan","Kebab","60–110 kr.","Nørrebrogade 95, Nørrebro","1.7km",3.9,"Ke","#7a5a3a",true,"23:00",["Halal"],"Intet glutenfrit udvalg",stub),
  mk(19,"Sushi Neko","Japansk","200–400 kr.","Nørre Farimagsgade 41, Indre By","700m",4.4,"SN","#3a3a5a",true,"22:00",[],"",stub),
  mk(20,"Bistro Boheme","Fransk bistro","250–450 kr.","Esplanaden 8, Indre By","900m",4.5,"BB","#4a3a3a",true,"23:00",[],"",stub),
  mk(21,"Noodle House","Kinesisk","80–150 kr.","Istedgade 41, Vesterbro","2.4km",3.8,"NH","#5a4a3a",true,"21:30",[],"",stub),
];

// ── Sort options ──────────────────────────────────────────────
const SORT_OPTIONS = [
  {key:"match",      label:"Bedst match",        icon:"★"},
  {key:"nearest",    label:"Nærmest",            icon:"↕"},
  {key:"station",    label:"Nærmest togstation", icon:"🚉", hasSubmenu:true},
  {key:"price_low",  label:"Pris: Lav til høj",  icon:"↑"},
  {key:"price_high", label:"Pris: Høj til lav",  icon:"↓"},
  {key:"newest",     label:"Nyeste",             icon:"✦"},
];

// ── Filter Sheet ──────────────────────────────────────────────
function FilterSheet({initialTab, selectedFilters, onToggle, onClose, visible, resultCount, onReset, activeNeeds}) {
  const tabs = ["Lokation","Type","Behov"];
  const [activeTab, setActiveTab] = useState(initialTab || tabs[0]);
  const data = filterSets[activeTab];
  const pk = Object.keys(data);
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
  const curPk = Object.keys(curData);
  const items = curData[ap]?.items || [];
  const subs = curData[ap]?.subs?.[ai] || [];
  const isSel = (x) => selectedFilters.has(x) || (activeTab==="Behov" && activeNeeds.has(x));
  const gpc = (p) => {
    const a = curData[p]?.items||[];
    const s = a.flatMap(it=>curData[p]?.subs?.[it]||[]);
    return [...a,...s].filter(x=>isSel(x)).length;
  };
  const getTabCount = (tab) => {
    const d = filterSets[tab]; let c=0;
    Object.values(d).forEach(p=>{p.items.forEach(it=>{if(selectedFilters.has(it))c++;});Object.values(p.subs||{}).forEach(sa=>sa.forEach(s=>{if(selectedFilters.has(s))c++;}));});
    if(tab==="Behov")[...activeNeeds].forEach(n=>{if(!selectedFilters.has(n))c++;});
    return c;
  };

  return (
    <BottomSheet visible={visible} onClose={onClose} height="78%">
      <div style={{display:"flex",borderBottom:"1px solid #f0f0f0",flexShrink:0}}>
        {tabs.map((t,ti)=>{
          const isA=activeTab===t;
          const cnt=getTabCount(t);
          const w=ti===0?"36%":ti===1?"33%":"31%";
          return (
            <button key={t} onClick={()=>switchTab(t)} style={{width:w,flexShrink:0,padding:"12px 0",background:"none",border:"none",cursor:"pointer",fontFamily:"inherit",fontSize:14,fontWeight:isA?640:480,color:isA?ACCENT:"#888",borderBottom:isA?`2.5px solid ${ACCENT}`:"2.5px solid transparent",textAlign:"center",display:"flex",alignItems:"center",justifyContent:"center",gap:5}}>
              {t}
              {cnt>0&&<span style={{fontSize:10,fontWeight:700,color:"#fff",background:isA?ACCENT:"#bbb",width:18,height:18,minWidth:18,minHeight:18,borderRadius:"50%",display:"inline-flex",alignItems:"center",justifyContent:"center",lineHeight:1}}>{cnt}</span>}
            </button>
          );
        })}
      </div>
      <div style={{display:"flex",flex:1,minHeight:0}}>
        <div style={{width:"36%",borderRight:"1px solid #f0f0f0",overflowY:"auto",background:"#fafafa",padding:"6px 0",flexShrink:0}}>
          {curPk.map(p=>{
            const active=ap===p,cnt=gpc(p);
            return <button key={p} onClick={()=>{setAp(p);setAi(curData[p]?.items?.[0]||"");}} style={{display:"flex",alignItems:"center",justifyContent:"space-between",width:"100%",textAlign:"left",padding:"11px 10px 11px 14px",border:"none",background:active?"#fff":"transparent",fontSize:13,fontWeight:active?620:440,color:active?ACCENT:"#777",cursor:"pointer",fontFamily:"inherit",borderLeft:active?`2.5px solid ${ACCENT}`:"2.5px solid transparent",lineHeight:1.35}}>
              <span>{p}</span>
              {cnt>0&&<span style={{fontSize:10,fontWeight:700,color:"#fff",background:ACCENT,width:18,height:18,minWidth:18,minHeight:18,borderRadius:"50%",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0,lineHeight:1}}>{cnt}</span>}
            </button>;
          })}
        </div>
        <div style={{width:"33%",borderRight:"1px solid #f0f0f0",overflowY:"auto",padding:"6px 0",flexShrink:0}}>
          {items.map(item=>{
            const sel=isSel(item),active=ai===item;
            return <button key={item} onClick={()=>{setAi(item);onToggle(item);}} style={{display:"flex",alignItems:"center",gap:8,width:"100%",textAlign:"left",padding:"11px 12px",border:"none",background:active?"#f8f8f8":"transparent",fontSize:13,fontWeight:sel?620:440,color:sel?"#0f0f0f":"#777",cursor:"pointer",fontFamily:"inherit"}}>
              <span style={{width:18,height:18,borderRadius:5,border:sel?"none":"1.5px solid #ccc",background:sel?ACCENT:"#fff",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>{sel&&<Check/>}</span>
              {item}
            </button>;
          })}
        </div>
        <div style={{width:"31%",overflowY:"auto",padding:"6px 0",flexShrink:0}}>
          {subs.map(sub=>{
            const sel=isSel(sub);
            return <button key={sub} onClick={()=>onToggle(sub)} style={{display:"flex",alignItems:"center",gap:7,width:"100%",textAlign:"left",padding:"10px 10px",border:"none",background:"transparent",fontSize:12,fontWeight:sel?600:420,color:sel?"#0f0f0f":"#888",cursor:"pointer",fontFamily:"inherit",lineHeight:1.35}}>
              <span style={{width:16,height:16,borderRadius:4,border:sel?"none":"1.5px solid #ccc",background:sel?ACCENT:"#fff",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>{sel&&<Check size={9}/>}</span>
              {sub}
            </button>;
          })}
        </div>
      </div>
      <div style={{display:"flex",gap:10,padding:"14px 20px 32px",borderTop:"1px solid #f0f0f0",flexShrink:0}}>
        <button onClick={onReset} style={{flex:1,padding:"13px 0",borderRadius:12,border:"1.5px solid #e0e0e0",background:"#fff",fontSize:14,fontWeight:580,color:"#666",cursor:"pointer",fontFamily:"inherit"}}>Nulstil</button>
        <button onClick={onClose} style={{flex:2,padding:"13px 0",borderRadius:12,border:"none",background:ACCENT,fontSize:14,fontWeight:620,color:"#fff",cursor:"pointer",fontFamily:"inherit"}}>Se {resultCount} steder</button>
      </div>
    </BottomSheet>
  );
}

// ── Needs Picker ──────────────────────────────────────────────
function NeedsPicker({activeNeeds, onToggle, onClose, visible}) {
  const cats = {
    "Diæt":["Helt glutenfrit","Glutenfri muligheder","Fuldt vegansk","Veganske muligheder","Fuldt vegetarisk","Vegetariske muligheder","Laktosefri","Halal","Kosher","Pescetarisk"],
    "Tilgængelighed":["Kørestol","Elevator","Blindevenlig"],
    "Børn":["Børnestol","Puslerum","Legeplads","Børnemenu"],
    "Hunde":["Hunde tilladt inde","Hunde tilladt ude","Vandskål"],
    "Stemning":["Havudsigt","Tagterrasse","Ved vandet","Romantisk","Hyggelig"],
    "Udendørs":["Gårdhave","Fortov","Terrasse"],
  };
  const [ac, setAc] = useState("Diæt");
  return (
    <BottomSheet visible={visible} onClose={onClose} height="72%" zBase={30}>
      <div style={{padding:"4px 20px 14px",borderBottom:"1px solid #f0f0f0",flexShrink:0}}>
        <h3 style={{margin:0,fontSize:20,fontWeight:720,color:"#0f0f0f"}}>Dine behov</h3>
        <p style={{margin:"4px 0 0",fontSize:13,color:"#999"}}>Vælg hvad der er vigtigt — vi husker det</p>
      </div>
      <div style={{display:"flex",overflowX:"auto",borderBottom:"1px solid #f0f0f0",flexShrink:0,padding:"0 4px"}}>
        {Object.keys(cats).map(c=>(
          <button key={c} onClick={()=>setAc(c)} style={{flexShrink:0,padding:"11px 14px",background:"none",border:"none",cursor:"pointer",fontFamily:"inherit",fontSize:13,fontWeight:ac===c?620:460,color:ac===c?ACCENT:"#888",borderBottom:ac===c?`2.5px solid ${ACCENT}`:"2.5px solid transparent"}}>{c}</button>
        ))}
      </div>
      <div style={{flex:1,overflowY:"auto",padding:"16px 20px"}}>
        <div style={{display:"flex",flexWrap:"wrap",gap:10}}>
          {cats[ac].map(item=>{
            const a=activeNeeds.has(item);
            return <button key={item} onClick={()=>onToggle(item)} style={{padding:"10px 16px",borderRadius:12,cursor:"pointer",fontFamily:"inherit",fontSize:14,fontWeight:a?600:460,background:a?GREEN_BG:"#fff",border:a?`1.5px solid ${GREEN_BORDER}`:"1.5px solid #e8e8e8",color:a?GREEN:"#555",display:"flex",alignItems:"center",gap:8}}>
              {a&&<Check size={12} color={GREEN}/>}{item}
            </button>;
          })}
        </div>
      </div>
      <div style={{padding:"14px 20px 32px",borderTop:"1px solid #f0f0f0",flexShrink:0}}>
        <button onClick={onClose} style={{width:"100%",padding:"14px 0",borderRadius:14,border:"none",background:"#0f0f0f",fontSize:15,fontWeight:620,color:"#fff",cursor:"pointer",fontFamily:"inherit"}}>Gem mine behov</button>
      </div>
    </BottomSheet>
  );
}

// ── Restaurant Card ───────────────────────────────────────────
function Card({r, i, onSelect, hasNeeds, variant}) {
  const [expanded, setExpanded] = useState(false);
  const closed = !r.statusOpen;
  const days = ["Søndag","Mandag","Tirsdag","Onsdag","Torsdag","Fredag","Lørdag"];
  const today = days[new Date().getDay()];
  const todayEntry = (r.hours||[]).find(([d])=>d===today);
  let todayStr = "";
  if (todayEntry) {
    if (typeof todayEntry[1]==="string") todayStr=todayEntry[1];
    else if (Array.isArray(todayEntry[1])&&todayEntry[1].length>0) {
      const slots=todayEntry[1];
      todayStr=`${slots[0].time.split("–")[0]}–${slots[slots.length-1].time.split("–")[1]}`;
    }
  }
  const photos = ["#f0dcc8","#e8c8b8","#d4b8a0","#c0d8c8","#b0c8b8","#d8ccc0","#c8b8a8","#e0d0c0"];
  return (
    <div onClick={()=>setExpanded(!expanded)} style={{padding:14,marginBottom:8,borderRadius:16,cursor:"pointer",background:"#fff",border:variant==="full"?`1.5px solid ${GREEN_BORDER}`:variant==="partial"?"1.5px solid #f0dcc8":"1.5px solid #e8e8e8",opacity:closed?0.5:1,animation:`cardIn 0.25s ease ${Math.min(i,8)*0.04}s both`}}>
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
            <Dot/><span style={{fontSize:12.5,color:"#999"}}>{r.statusText||`til ${r.closingTime}`}</span>
          </div>
          <div style={{display:"flex",alignItems:"center",gap:6}}>
            <span style={{fontSize:12.5,color:"#999"}}>{r.cuisine}</span>
            <Dot/>
            <span style={{fontSize:12.5,color:"#999"}}>{r.priceRange}</span>
          </div>
        </div>
      </div>
      {hasNeeds && variant==="partial" && (
        <div style={{marginTop:10,padding:"9px 11px",borderRadius:10,background:"#fef8f2",display:"flex",alignItems:"flex-start",gap:8}}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={ACCENT} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{flexShrink:0,marginTop:1}}><circle cx="12" cy="12" r="10"/><path d="M12 16v-4M12 8h.01"/></svg>
          <div style={{fontSize:12,color:"#555",lineHeight:1.4}}>
            <span style={{fontWeight:580}}>Matcher {r.matchCount}/{r.matchCount+r.missedNeeds.length}</span>{" · "}Mangler: {r.missedNeeds.join(", ")}
          </div>
        </div>
      )}
      {expanded && (
        <div style={{marginTop:12,paddingTop:12,borderTop:"1px solid #f2f2f2"}}>
          <div style={{fontSize:12.5,color:"#888",marginBottom:4}}>{r.address}</div>
          {todayStr&&<div style={{fontSize:12.5,color:"#666",marginBottom:10}}>I dag: {todayStr==="Lukket"?<span style={{color:"#c9403a"}}>{todayStr}</span>:todayStr}</div>}
          <div style={{display:"flex",gap:4,overflowX:"auto",paddingBottom:4,margin:"0 -2px"}}>
            {photos.map((c,pi)=><div key={pi} style={{width:80,height:60,borderRadius:8,background:c,flexShrink:0}}/>)}
          </div>
          <button onClick={(e)=>{e.stopPropagation();onSelect(r);}} style={{display:"block",width:"100%",marginTop:10,padding:"9px 0",borderRadius:10,border:"1.5px solid #e8e8e8",background:"#fff",fontSize:12.5,fontWeight:560,color:"#555",cursor:"pointer",fontFamily:"inherit",textAlign:"center"}}>Se mere →</button>
        </div>
      )}
      {!expanded&&<div style={{display:"flex",justifyContent:"center",marginTop:6}}><svg width="14" height="8" viewBox="0 0 14 8" fill="none" stroke="#ddd" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M1 1l6 6 6-6"/></svg></div>}
    </div>
  );
}

// ── TabBar ────────────────────────────────────────────────────
function TabBar({activeTab, onChangeTab}) {
  const tabs = [
    {key:"udforsk",   label:"Udforsk",    icon:"M21 21l-4.35-4.35M11 19a8 8 0 100-16 8 8 0 000 16z"},
    {key:"minebehov", label:"Mine behov", icon:"M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"},
    {key:"profil",    label:"Profil",     icon:"M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2M12 11a4 4 0 100-8 4 4 0 000 8z"},
  ];
  return (
    <div style={{position:"absolute",bottom:0,left:0,right:0,height:80,background:"rgba(255,255,255,0.95)",backdropFilter:"blur(16px)",borderTop:"1px solid #f0f0f0",display:"flex",justifyContent:"space-around",alignItems:"flex-start",paddingTop:10,zIndex:5}}>
      {tabs.map(t=>(
        <button key={t.key} onClick={()=>onChangeTab?.(t.key)} style={{display:"flex",flexDirection:"column",alignItems:"center",gap:3,background:"none",border:"none",cursor:"pointer",padding:"2px 16px"}}>
          <svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke={activeTab===t.key?ACCENT:"#bbb"} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d={t.icon}/></svg>
          <span style={{fontSize:10.5,fontWeight:activeTab===t.key?620:480,color:activeTab===t.key?ACCENT:"#bbb"}}>{t.label}</span>
        </button>
      ))}
    </div>
  );
}

// ── No Results ────────────────────────────────────────────────
function SearchNoResults({searchQuery, onClearSearch}) {
  return (
    <div style={{display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",padding:"60px 32px",flex:1}}>
      <div style={{width:80,height:80,borderRadius:"50%",background:"#f5f5f5",display:"flex",alignItems:"center",justifyContent:"center",marginBottom:24}}>
        <span style={{fontSize:36,opacity:0.5}}>🔍</span>
      </div>
      <h2 style={{fontSize:20,fontWeight:680,color:"#0f0f0f",textAlign:"center",margin:"0 0 12px 0"}}>No search results</h2>
      <p style={{fontSize:14,fontWeight:400,color:"#888",textAlign:"center",lineHeight:"20px",margin:"0 0 32px 0",maxWidth:280}}>
        We couldn't find any places matching "{searchQuery}". Try adjusting your search or filters.
      </p>
      {searchQuery&&(
        <button onClick={onClearSearch} style={{padding:"12px 24px",background:"transparent",color:ACCENT,border:`2px solid ${ACCENT}`,borderRadius:10,fontSize:14,fontWeight:600,cursor:"pointer"}}>Clear search</button>
      )}
    </div>
  );
}

// ── Main Search Page ──────────────────────────────────────────
export default function SearchPage() {
  const [activeSheet, setActiveSheet] = useState(null);
  const [sheetVisible, setSheetVisible] = useState(false);
  const [selectedFilters, setSelectedFilters] = useState(new Set());
  const [activeNeeds, setActiveNeeds] = useState(new Set(["Helt glutenfrit"]));
  const [searchFocused, setSearchFocused] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const [viewMode, setViewMode] = useState("liste");
  const [activeSort, setActiveSort] = useState("match");
  const [selectedStation, setSelectedStation] = useState(null);
  const [showOnlyOpen, setShowOnlyOpen] = useState(false);
  const [sortSheetView, setSortSheetView] = useState("options");
  const [sortSheetOpen, setSortSheetOpen] = useState(false);
  const [sortSheetVisible, setSortSheetVisible] = useState(false);
  const [needsPickerOpen, setNeedsPickerOpen] = useState(false);
  const [needsPickerVisible, setNeedsPickerVisible] = useState(false);
  const [activeTab, setActiveTab] = useState("udforsk");

  const hasFilters = selectedFilters.size > 0;
  const allBehovItems = new Set();
  Object.values(filterSets.Behov).forEach(cat=>{cat.items.forEach(it=>allBehovItems.add(it));Object.values(cat.subs||{}).forEach(sa=>sa.forEach(s=>allBehovItems.add(s)));});
  const needsFromFilters = [...selectedFilters].filter(f=>allBehovItems.has(f));
  const allNeeds = new Set([...activeNeeds,...needsFromFilters]);
  const hasNeeds = allNeeds.size > 0;

  const openSheet  = (k) => { setActiveSheet(k); requestAnimationFrame(()=>requestAnimationFrame(()=>setSheetVisible(true))); };
  const closeSheet = ()  => { setSheetVisible(false); setTimeout(()=>setActiveSheet(null),300); };
  const toggleFilter = (f) => { const s=new Set(selectedFilters); s.has(f)?s.delete(f):s.add(f); setSelectedFilters(s); };
  const toggleNeed = (n) => { const s=new Set(activeNeeds); s.has(n)?s.delete(n):s.add(n); setActiveNeeds(s); };
  const openSortSheet  = () => { setSortSheetView("options"); setSortSheetOpen(true); requestAnimationFrame(()=>requestAnimationFrame(()=>setSortSheetVisible(true))); };
  const closeSortSheet = () => { setSortSheetVisible(false); setTimeout(()=>{setSortSheetOpen(false);setSortSheetView("options");},300); };
  const openNeedsPicker  = () => { setNeedsPickerOpen(true); requestAnimationFrame(()=>requestAnimationFrame(()=>setNeedsPickerVisible(true))); };
  const closeNeedsPicker = () => { setNeedsPickerVisible(false); setTimeout(()=>setNeedsPickerOpen(false),300); };

  const withMatch = allRestaurants.map(r=>{
    const m=[...allNeeds].filter(n=>r.has.includes(n));
    return{...r,matchCount:m.length,matchedNeeds:m,missedNeeds:[...allNeeds].filter(n=>!r.has.includes(n))};
  });
  const parsePrice = (r) => { const m=r.priceRange.match(/\d+/); return m?parseInt(m[0]):0; };
  const applySort = (list) => {
    switch(activeSort) {
      case "nearest": return [...list].sort((a,b)=>parseFloat(a.distance)-parseFloat(b.distance));
      case "price_low": return [...list].sort((a,b)=>parsePrice(a)-parsePrice(b));
      case "price_high": return [...list].sort((a,b)=>parsePrice(b)-parsePrice(a));
      case "match": return hasNeeds?[...list].sort((a,b)=>b.matchCount-a.matchCount||parseFloat(a.distance)-parseFloat(b.distance)):list;
      default: return list;
    }
  };

  const queryFiltered = searchQuery
    ? withMatch.filter(r=>r.name.toLowerCase().includes(searchQuery.toLowerCase())||r.cuisine.toLowerCase().includes(searchQuery.toLowerCase()))
    : withMatch;
  const sorted = applySort(queryFiltered);
  const filtered = showOnlyOpen ? sorted.filter(r=>r.statusOpen) : sorted;
  const showMatchSections = hasNeeds || hasFilters;
  const fullMatch    = showMatchSections ? filtered.filter(r=>r.matchCount===allNeeds.size) : [];
  const partialMatch = showMatchSections ? filtered.filter(r=>r.matchCount>0&&r.matchCount<allNeeds.size) : [];
  const noMatch      = showMatchSections ? filtered.filter(r=>r.matchCount===0) : [];

  const getFC = (key) => {
    const d=filterSets[key]; let c=0;
    Object.values(d).forEach(p=>{p.items.forEach(it=>{if(selectedFilters.has(it))c++;});Object.values(p.subs||{}).forEach(sa=>sa.forEach(s=>{if(selectedFilters.has(s))c++;}));});
    if(key==="Behov")[...activeNeeds].forEach(n=>{if(!selectedFilters.has(n))c++;});
    return c;
  };

  const activeSortLabel = activeSort==="station"&&selectedStation ? selectedStation : SORT_OPTIONS.find(s=>s.key===activeSort)?.label||"Sortér";

  return (
    <div style={{display:"flex",alignItems:"center",justifyContent:"center",minHeight:"100vh",background:"#f2f2f2",padding:24}}>
      <style>{`
        @keyframes cardIn { from{opacity:0;transform:translateY(8px)} to{opacity:1;transform:translateY(0)} }
        @keyframes slideOutLeft { from{transform:translateX(0);opacity:1} to{transform:translateX(-100%);opacity:0} }
        @keyframes slideInRight { from{transform:translateX(100%);opacity:0} to{transform:translateX(0);opacity:1} }
        @keyframes slideOutRight { from{transform:translateX(0);opacity:1} to{transform:translateX(100%);opacity:0} }
        @keyframes slideInLeft { from{transform:translateX(-100%);opacity:0} to{transform:translateX(0);opacity:1} }
        ::-webkit-scrollbar{display:none}
        *{scrollbar-width:none}
        input::placeholder{color:#bbb}
      `}</style>

      {/* Phone frame */}
      <div style={{width:390,height:844,background:"#fff",borderRadius:48,position:"relative",overflow:"hidden",boxShadow:"0 30px 80px rgba(0,0,0,0.25),0 0 0 10px #1a1a1a,0 0 0 11px #333"}}>

        <StatusBar/>

        {/* Scrollable content */}
        <div style={{height:844-54-80,overflowY:"auto",overflowX:"hidden"}}>

          {/* Header */}
          <div style={{padding:"4px 20px 0"}}>
            <div style={{display:"inline-flex",alignItems:"center",gap:6,marginBottom:14,padding:"7px 0"}}>
              <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke={ACCENT} strokeWidth="2.2" strokeLinecap="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
              <span style={{fontSize:15,fontWeight:600,color:"#0f0f0f"}}>København</span>
            </div>
            <div style={{display:"flex",alignItems:"center",gap:10,background:"#f5f5f5",borderRadius:12,padding:"11px 14px",marginBottom:16,border:searchFocused?`1.5px solid ${ACCENT}`:"1.5px solid transparent"}}>
              <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#999" strokeWidth="2" strokeLinecap="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
              <input
                type="text"
                placeholder="Søg restauranter, retter..."
                value={searchQuery}
                onChange={e=>setSearchQuery(e.target.value)}
                onFocus={()=>setSearchFocused(true)}
                onBlur={()=>setSearchFocused(false)}
                style={{border:"none",background:"none",outline:"none",fontSize:15,color:"#0f0f0f",width:"100%",fontFamily:"inherit"}}
              />
              {searchQuery&&<button onClick={()=>setSearchQuery("")} style={{background:"none",border:"none",cursor:"pointer",fontSize:16,color:"#bbb",padding:0,lineHeight:1}}>×</button>}
            </div>



            <h2 style={{fontSize:24,fontWeight:720,color:"#0f0f0f",margin:"0 0 14px",letterSpacing:"-0.025em"}}>
              {hasFilters||hasNeeds?`Søgeresultater (${filtered.length})`:"Steder nær dig"}
            </h2>

            {/* Filter buttons */}
            <div style={{display:"flex",gap:8}}>
              {["Lokation","Type","Behov"].map(f=>{
                const isA=activeSheet===f,cnt=getFC(f);
                return <button key={f} onClick={()=>{isA?closeSheet():openSheet(f);}} style={{flex:1,padding:"9px 0",borderRadius:10,border:isA?`1.5px solid ${ACCENT}`:"1.5px solid #e8e8e8",fontSize:13.5,fontWeight:570,cursor:"pointer",fontFamily:"inherit",background:isA?ACCENT:"#fff",color:isA?"#fff":"#555",position:"relative"}}>
                  {f}{cnt>0&&!isA?` (${cnt})`:""}
                  {cnt>0&&!isA&&<span style={{position:"absolute",top:5,right:5,width:6,height:6,borderRadius:"50%",background:ACCENT}}/>}
                </button>;
              })}
            </div>
          </div>

          {/* Active filter chips */}
          {(hasFilters||hasNeeds)&&(
            <div style={{padding:"14px 0 8px",borderBottom:"1px solid #f2f2f2"}}>
              <div style={{display:"flex",alignItems:"center",position:"relative"}}>
                <div style={{flexShrink:0,paddingLeft:20,background:"#fff",zIndex:2,display:"flex",alignItems:"center"}}>
                  <button onClick={()=>{setSelectedFilters(new Set());setActiveNeeds(new Set());}} style={{padding:"7px 12px",borderRadius:8,border:"1.5px solid #e0e0e0",background:"#fff",fontSize:12.5,fontWeight:580,color:ACCENT,cursor:"pointer",fontFamily:"inherit",whiteSpace:"nowrap"}}>Ryd alle</button>
                  <div style={{width:10,background:"linear-gradient(to right, #fff, transparent)",flexShrink:0,height:"100%"}}/>
                </div>
                <div style={{display:"flex",gap:6,overflowX:"auto",paddingRight:20,paddingBottom:2}}>
                  {[...activeNeeds].map(n=>(
                    <button key={n} onClick={()=>toggleNeed(n)} style={{flexShrink:0,display:"flex",alignItems:"center",gap:5,padding:"7px 10px 7px 12px",borderRadius:8,border:`1.5px solid ${GREEN_BORDER}`,background:GREEN_BG,fontSize:12.5,fontWeight:540,color:GREEN,cursor:"pointer",fontFamily:"inherit",whiteSpace:"nowrap"}}>
                      {n}<svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#aaa" strokeWidth="2.5" strokeLinecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
                    </button>
                  ))}
                  {[...selectedFilters].map(f=>(
                    <button key={f} onClick={()=>toggleFilter(f)} style={{flexShrink:0,display:"flex",alignItems:"center",gap:5,padding:"7px 10px 7px 12px",borderRadius:8,border:`1.5px solid ${GREEN_BORDER}`,background:GREEN_BG,fontSize:12.5,fontWeight:540,color:GREEN,cursor:"pointer",fontFamily:"inherit",whiteSpace:"nowrap"}}>
                      {f}<svg width="10" height="10" viewBox="0 0 24 24" fill="none" stroke="#aaa" strokeWidth="2.5" strokeLinecap="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}

          {/* List/Map toggle */}
          <div style={{display:"flex",alignItems:"center",margin:"12px 20px 0",overflow:"hidden"}}>
            {["Liste","Kort"].map(v=>{
              const isA=viewMode===v.toLowerCase();
              return <button key={v} onClick={()=>setViewMode(v.toLowerCase())} style={{flex:1,padding:"8px 0",fontSize:13.5,fontWeight:isA?620:480,color:isA?"#0f0f0f":"#999",background:isA?"#f5f5f5":"#fff",border:"1.5px solid #e8e8e8",cursor:"pointer",fontFamily:"inherit",borderRadius:v==="Liste"?"8px 0 0 8px":"0 8px 8px 0",marginLeft:v==="Kort"?"-1.5px":0,boxSizing:"border-box"}}>{v}</button>;
            })}
          </div>

          {/* Results */}
          {viewMode==="liste" ? (
            <div style={{padding:"16px 20px 32px"}}>
              {filtered.length===0 ? (
                <SearchNoResults searchQuery={searchQuery} onClearSearch={()=>setSearchQuery("")}/>
              ) : showMatchSections ? (<>
                {fullMatch.length>0&&(
                  <div style={{marginBottom:4}}>
                    <div style={{fontSize:11,fontWeight:620,color:GREEN,textTransform:"uppercase",letterSpacing:"0.05em",marginBottom:10,display:"flex",alignItems:"center",gap:5}}>
                      <Check size={11} color={GREEN}/> Matcher alle behov
                    </div>
                    {fullMatch.map((r,i)=><Card key={r.id} r={r} i={i} onSelect={()=>{}} hasNeeds variant="full"/>)}
                  </div>
                )}
                {partialMatch.length>0&&(
                  <div style={{marginBottom:4}}>
                    <div style={{fontSize:11,fontWeight:620,color:ACCENT,textTransform:"uppercase",letterSpacing:"0.05em",marginBottom:10,marginTop:24}}>Matcher delvist</div>
                    {partialMatch.map((r,i)=><Card key={r.id} r={r} i={i} onSelect={()=>{}} hasNeeds variant="partial"/>)}
                  </div>
                )}
                {noMatch.length>0&&(
                  <div>
                    <div style={{fontSize:11,fontWeight:620,color:"#bbb",textTransform:"uppercase",letterSpacing:"0.05em",marginBottom:10,marginTop:24}}>Andre steder</div>
                    {noMatch.map((r,i)=><Card key={r.id} r={r} i={i} onSelect={()=>{}} hasNeeds={false} variant="none"/>)}
                  </div>
                )}
              </>) : (
                filtered.map((r,i)=><Card key={r.id} r={r} i={i} onSelect={()=>{}} hasNeeds={false} variant="none"/>)
              )}
            </div>
          ) : (
            <div style={{flex:1,display:"flex",alignItems:"center",justifyContent:"center",padding:"60px 20px",textAlign:"center"}}>
              <div>
                <div style={{width:64,height:64,borderRadius:16,background:"#f5f5f5",display:"flex",alignItems:"center",justifyContent:"center",margin:"0 auto 12px"}}>
                  <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#ccc" strokeWidth="1.5" strokeLinecap="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"/><circle cx="12" cy="10" r="3"/></svg>
                </div>
                <div style={{fontSize:15,fontWeight:600,color:"#999"}}>Kortvisning</div>
                <div style={{fontSize:13,color:"#bbb",marginTop:4}}>Kommer snart</div>
              </div>
            </div>
          )}
        </div>

        {/* Floating sort button */}
        {viewMode==="liste"&&(
          <button onClick={openSortSheet} style={{position:"absolute",bottom:92,right:16,zIndex:6,display:"flex",alignItems:"center",gap:5,padding:"9px 14px",borderRadius:20,background:ACCENT,color:"#fff",border:"none",fontSize:12.5,fontWeight:580,cursor:"pointer",fontFamily:"inherit",boxShadow:"0 2px 8px rgba(0,0,0,0.12)"}}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.5" strokeLinecap="round"><path d="M3 6h18M6 12h12M9 18h6"/></svg>
            {activeSortLabel}
          </button>
        )}

        <TabBar activeTab={activeTab} onChangeTab={setActiveTab}/>

        {/* Sort sheet */}
        {sortSheetOpen&&(
          <BottomSheet visible={sortSheetVisible} onClose={closeSortSheet} height="62%">
            <div style={{padding:"4px 20px 10px",borderBottom:"1px solid #f0f0f0",flexShrink:0,display:"flex",alignItems:"center",gap:12}}>
              {sortSheetView==="stations"&&(
                <button onClick={()=>setSortSheetView("options")} style={{background:"none",border:"none",padding:"4px",cursor:"pointer",display:"flex",alignItems:"center",marginLeft:-8}}>
                  <svg width="10" height="16" viewBox="0 0 10 16" fill="none" stroke="#666" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M8 2L2 8l6 6"/></svg>
                </button>
              )}
              <h3 style={{margin:0,fontSize:18,fontWeight:680,color:"#0f0f0f"}}>{sortSheetView==="stations"?"Vælg togstation":"Sortér efter"}</h3>
            </div>
            <div style={{flex:1,position:"relative",overflow:"hidden"}}>
              <div style={{position:"absolute",inset:0,overflowY:"auto",padding:"8px 0",display:sortSheetView==="options"?"block":"none"}}>
                <div style={{padding:"12px 20px",borderBottom:"1px solid #f0f0f0",marginBottom:8}}>
                  <button onClick={()=>setShowOnlyOpen(!showOnlyOpen)} style={{display:"flex",alignItems:"center",justifyContent:"space-between",width:"100%",padding:"12px 14px",borderRadius:10,border:showOnlyOpen?`1.5px solid ${GREEN_BORDER}`:"1.5px solid #e8e8e8",background:showOnlyOpen?GREEN_BG:"#fff",cursor:"pointer",fontFamily:"inherit"}}>
                    <div style={{display:"flex",alignItems:"center",gap:10}}>
                      <div style={{width:20,height:20,borderRadius:5,border:showOnlyOpen?"none":"1.5px solid #ccc",background:showOnlyOpen?GREEN:"#fff",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
                        {showOnlyOpen&&<Check size={11} color="#fff"/>}
                      </div>
                      <span style={{fontSize:15,fontWeight:showOnlyOpen?600:460,color:showOnlyOpen?GREEN:"#666"}}>Kun åbne steder</span>
                    </div>
                    {showOnlyOpen&&<span style={{fontSize:12,color:GREEN,fontWeight:540}}>{filtered.length} steder</span>}
                  </button>
                </div>
                {SORT_OPTIONS.map(opt=>{
                  const isA=activeSort===opt.key;
                  const displayLabel=opt.key==="station"&&selectedStation?`${opt.label}: ${selectedStation}`:opt.label;
                  return (
                    <button key={opt.key} onClick={()=>{if(opt.hasSubmenu)setSortSheetView("stations");else{setActiveSort(opt.key);closeSortSheet();}}} style={{display:"flex",alignItems:"center",justifyContent:"space-between",width:"100%",padding:"14px 20px",border:"none",background:isA?"#fafafa":"transparent",cursor:"pointer",fontFamily:"inherit"}}>
                      <span style={{fontSize:15,fontWeight:isA?620:460,color:isA?"#0f0f0f":"#666"}}>{displayLabel}</span>
                      <div style={{display:"flex",alignItems:"center",gap:8}}>
                        {isA&&!opt.hasSubmenu&&<div style={{width:20,height:20,borderRadius:"50%",background:ACCENT,display:"flex",alignItems:"center",justifyContent:"center"}}><Check size={11}/></div>}
                        {opt.hasSubmenu&&<svg width="8" height="14" viewBox="0 0 8 14" fill="none" stroke="#bbb" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M1 1l6 6-6 6"/></svg>}
                      </div>
                    </button>
                  );
                })}
              </div>
              <div style={{position:"absolute",inset:0,overflowY:"auto",display:sortSheetView==="stations"?"block":"none"}}>
                {trainStations.map(station=>{
                  const isSel=selectedStation===station;
                  return <button key={station} onClick={()=>{setSelectedStation(station);setActiveSort("station");setSortSheetView("options");}} style={{display:"flex",alignItems:"center",justifyContent:"space-between",width:"100%",padding:"16px 20px",border:"none",background:isSel?"#fafafa":"transparent",cursor:"pointer",fontFamily:"inherit"}}>
                    <span style={{fontSize:15,fontWeight:isSel?620:460,color:isSel?"#0f0f0f":"#666"}}>{station}</span>
                    {isSel&&<div style={{width:20,height:20,borderRadius:"50%",background:ACCENT,display:"flex",alignItems:"center",justifyContent:"center"}}><Check size={11}/></div>}
                  </button>;
                })}
              </div>
            </div>
            {sortSheetView==="stations"&&(
              <div style={{padding:"12px 20px",borderTop:"1px solid #f0f0f0",background:"#fafafa",flexShrink:0}}>
                <div style={{fontSize:12,color:"#999",lineHeight:1.4}}>💡 I den færdige app vil dette sortere steder efter afstand til den valgte station.</div>
              </div>
            )}
          </BottomSheet>
        )}

        {/* Filter sheet */}
        {activeSheet&&(
          <FilterSheet
            initialTab={activeSheet}
            selectedFilters={selectedFilters}
            onToggle={toggleFilter}
            onClose={closeSheet}
            visible={sheetVisible}
            resultCount={filtered.length}
            onReset={()=>setSelectedFilters(new Set())}
            activeNeeds={activeNeeds}
          />
        )}

        {/* Needs picker */}
        {needsPickerOpen&&(
          <NeedsPicker
            activeNeeds={activeNeeds}
            onToggle={toggleNeed}
            onClose={closeNeedsPicker}
            visible={needsPickerVisible}
          />
        )}
      </div>
    </div>
  );
}
