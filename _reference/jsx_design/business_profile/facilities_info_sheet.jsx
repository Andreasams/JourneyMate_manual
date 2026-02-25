// ============================================================
// FACILITIES INFO SHEET
// Bottom sheet showing detailed facility information
// Props: visible (boolean), onClose (function), facility (object)
// ============================================================

import { BottomSheet, ACCENT } from "../../shared/_shared.jsx";

export default function FacilitiesInfoSheet({ visible, onClose, facility }) {
  if (!facility) return null;

  // Sample detailed info based on facility label
  const facilityInfo = {
    "Udendørs siddepladser": {
      title: "Udendørs siddepladser",
      description: "Vi har udendørs siddepladser med udsigt. Perfekt til solrige dage og lune sommeraftener."
    },
    "Morgenmad": {
      title: "Morgenmad",
      description: "Vi serverer morgenmad dagligt fra kl. 7:00 til 11:00. Vores morgenmadsmenu inkluderer friskbagte croissanter, brød, æg, pålæg og friskpresset juice."
    },
    "Børnestol": {
      title: "Børnestol",
      description: "Vi har børnestole tilgængelige. Giv os besked når du bestiller bord, så vi sørger for at have en klar til jer."
    },
    "Hunde tilladt ude": {
      title: "Hunde tilladt ude",
      description: "Hunde er velkomne i vores udeområde. Vi har vandskåle tilgængelige."
    },
    "Økologisk": {
      title: "Økologiske ingredienser",
      description: "Vi prioriterer økologiske og bæredygtige ingredienser i vores køkken."
    }
  };

  const info = facilityInfo[facility.l] || {
    title: facility.l,
    description: "For mere information om denne facilitet, kontakt venligst restauranten direkte."
  };

  return (
    <BottomSheet
      visible={visible}
      onClose={onClose}
      height="50%"
    >
      <div style={{
        padding: "24px 20px 32px",
        height: "calc(100% - 20px)",
        overflowY: "auto",
      }}>
        {/* Title */}
        <h3 style={{
          fontSize: 20,
          fontWeight: 680,
          color: "#0f0f0f",
          margin: "0 0 16px 0",
          paddingRight: 40,
        }}>
          {info.title}
        </h3>

        {/* Description */}
        <p style={{
          fontSize: 14,
          fontWeight: 400,
          color: "#555",
          lineHeight: "20px",
          margin: 0,
        }}>
          {info.description}
        </p>
      </div>
    </BottomSheet>
  );
}
