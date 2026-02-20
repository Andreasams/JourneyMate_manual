# Information Page — JSX v2 Design

**Component:** `InformationPage`
**Location:** `pages/business_profile/information_page.jsx`
**Parent:** Business Profile page
**Purpose:** Full-page detailed information view for a restaurant

---

## Component Props

```jsx
InformationPage({
  restaurant,  // Restaurant object with all details
  onBack       // Navigation function to return to business profile
})
```

---

## Layout Structure

### Page Container
- **Dimensions:** 390×844px
- **Background:** White (#fff)
- **Overflow:** Hidden
- **Position:** Relative

### Scrollable Content Area
- **Height:** 790px (full page minus status bar)
- **Overflow:** Vertical scroll
- **Bottom padding:** 40px

---

## Header Section (60px)

**Layout:**
- Height: 60px
- Flex layout, center-aligned
- Horizontal padding: 20px
- Border bottom: 1px solid #f2f2f2

**Back Button:**
- Size: 36×36px
- Background: Transparent
- Icon: ← (left arrow)
- Color: #0f0f0f
- Font size: 18px

**Title:**
- Text: `{restaurant.name}`
- Position: Centered (with -36px left margin to account for back button)
- Font size: 16px
- Font weight: 600
- Color: #0f0f0f

---

## Hero Image (180px)

**Placeholder:**
- Width: 100%
- Height: 180px
- Background: #d0d0d0 (grey placeholder)

**Expected in Production:**
- Hero image from restaurant data
- Likely first image or featured image

---

## Content Section

**Container padding:** 20px top/bottom, 24px left/right

### 1. Restaurant Name

**Typography:**
- Font size: 24px
- Font weight: 750
- Color: #0f0f0f
- Margin bottom: 6px

**Data source:** `restaurant.name`

---

### 2. Status Indicator

**Layout:**
- Flex row, 6px gap
- Margin bottom: 16px

**Status dot:**
- Size: 6×6px
- Border radius: 50% (circle)
- Color: GREEN (#1a9456) if open, #c9403a if closed
- Conditional: `restaurant.statusOpen` boolean

**Status text:**
- Font size: 13px
- Font weight: 460
- Color: #555
- Data source: `restaurant.statusText`

**Expected status text examples:**
- "Åbent til 22:00" (Open until 10pm)
- "Lukket – åbner kl. 11:00" (Closed – opens at 11am)
- "Lukker i morgen kl. 02:00" (Closes tomorrow at 2am)

---

### 3. About Description (Optional)

**Conditional rendering:** Only if `restaurant.about` exists

**Typography:**
- Font size: 14px
- Font weight: 400
- Color: #555
- Line height: 20px
- Margin bottom: 24px

**Data source:** `restaurant.about`

**Expected content:**
- Restaurant description
- Cuisine style
- Atmosphere
- History or unique features

---

### 4. Opening Hours Section (Expandable)

**Component:** `OpeningHoursSection` (from shared)

**Props:**
- `title`: "Åbningstider m.m." (Opening hours etc.)
- `hours`: `restaurant.hours` (array of hour objects)
- `contact`: Object with `{ phone: restaurant.phone, links: restaurant.links }`
- `variant`: "info" (affects styling/behavior)

**Expected behavior:**
- Expandable/collapsible section
- Shows opening hours for each day of week
- Includes contact information (phone, links)
- Info variant may have different styling than business profile variant

**Hours data structure:**
```javascript
hours: [
  { day: "Mandag", hours: "11:00-22:00" },
  { day: "Tirsdag", hours: "11:00-22:00" },
  // ...
]
```

**Contact data structure:**
```javascript
contact: {
  phone: "+45 12 34 56 78",
  links: {
    website: "https://example.com",
    booking: "https://booking.example.com"
  }
}
```

---

### 5. Facilities and Services (Optional)

**Conditional rendering:** Only if `restaurant.facilities` exists

**Section heading:**
- Text: "Faciliteter og services" (Facilities and services)
- Font size: 15px
- Font weight: 600
- Color: #0f0f0f
- Margin bottom: 12px

**Facility chips:**
- Layout: Flex wrap, 8px gap
- Padding: 7px 12px
- Border radius: 10px
- Font size: 12.5px
- Font weight: 540
- Background: #fff
- Color: #555
- Border: 1px solid #e8e8e8

**Data source:** `restaurant.facilities` array

**Expected facility examples:**
- "Handicapvenligt" (Wheelchair accessible)
- "Udeservering" (Outdoor seating)
- "WiFi"
- "Parkering" (Parking)
- "Børnevenligt" (Child-friendly)

**Data format handling:**
- Facilities can be strings: `"WiFi"`
- OR objects with label: `{ l: "WiFi" }`
- Code: `typeof fac === "string" ? fac : fac.l`

**Margin bottom:** 24px

---

### 6. Payment Methods (Optional)

**Conditional rendering:** Only if `restaurant.payments` exists

**Section heading:**
- Text: "Betalingsmuligheder" (Payment options)
- Font size: 15px
- Font weight: 600
- Color: #0f0f0f
- Margin bottom: 12px

**Payment chips:**
- Layout: Flex wrap, 8px gap
- Padding: 7px 12px
- Border radius: 10px
- Font size: 12.5px
- Font weight: 540
- Background: #fff
- Color: #555
- Border: 1px solid #e8e8e8

**Data source:** `restaurant.payments` array (strings only)

**Expected payment examples:**
- "Kontant" (Cash)
- "Dankort"
- "Visa"
- "Mastercard"
- "MobilePay"
- "American Express"

---

## Design Specifications

### Colors

| Element | Color | Hex |
|---------|-------|-----|
| Page background | White | #fff |
| Header border | Light grey | #f2f2f2 |
| Hero placeholder | Grey | #d0d0d0 |
| Primary text | Black | #0f0f0f |
| Secondary text | Dark grey | #555 |
| Status dot (open) | Green | #1a9456 |
| Status dot (closed) | Red | #c9403a |
| Chip background | White | #fff |
| Chip border | Light grey | #e8e8e8 |

### Typography

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Header title | 16px | 600 | #0f0f0f |
| Restaurant name | 24px | 750 | #0f0f0f |
| Status text | 13px | 460 | #555 |
| About text | 14px | 400 | #555 |
| Section heading | 15px | 600 | #0f0f0f |
| Chip text | 12.5px | 540 | #555 |

### Spacing

| Element | Spacing |
|---------|---------|
| Header padding | 0 20px |
| Content padding | 20px 24px |
| Header height | 60px |
| Hero height | 180px |
| Status dot size | 6×6px |
| Status gap | 6px |
| Chip padding | 7px 12px |
| Chip gap | 8px |
| Chip border radius | 10px |
| Section margin bottom | 24px |
| Name margin bottom | 6px |
| Status margin bottom | 16px |
| Heading margin bottom | 12px |

---

## Interactive Elements

### Back Button
- **Action:** Calls `onBack()` function
- **Visual feedback:** Cursor pointer
- **Returns to:** Business Profile page

### Scrollable Content
- **Behavior:** Vertical scroll for content overflow
- **Scroll area:** 790px height

---

## Data Dependencies

**Required restaurant fields:**
- ✅ `name` - Restaurant name
- ✅ `statusOpen` - Boolean (open/closed)
- ✅ `statusText` - Status display text

**Optional restaurant fields:**
- `about` - Description text
- `hours` - Opening hours array
- `phone` - Phone number
- `links` - Object with website/booking URLs
- `facilities` - Array of facility strings or objects
- `payments` - Array of payment method strings

---

## Differences from FlutterFlow Implementation

**JSX v2 (This Design):**
- ✅ Hero image: Grey placeholder (180px)
- ✅ Simpler layout, scrollable content only
- ❌ No map integration
- ❌ No address/neighborhood display
- ✅ Facilities and payments as chip lists
- ✅ OpeningHoursSection component (expandable)

**FlutterFlow Implementation:**
- ✅ Google Maps integration (200px height, zoom 12, red marker)
- ✅ Address and neighborhood display
- ✅ Three custom widgets: ContactDetailWidget, BusinessFeatureButtons, PaymentOptionsWidget
- ✅ More sophisticated widget composition

**Gap Analysis:** FlutterFlow implementation is MORE comprehensive than JSX v2 design.

---

## Translation Keys (Expected)

**Hardcoded Danish text in JSX:**
- "Åbningstider m.m." → Should use translation key
- "Faciliteter og services" → Should use translation key
- "Betalingsmuligheder" → Should use translation key

**Expected translation keys:**
- `information_page_heading_hours` - "Åbningstider m.m." / "Opening hours etc."
- `information_page_heading_facilities` - "Faciliteter og services" / "Facilities and services"
- `information_page_heading_payments` - "Betalingsmuligheder" / "Payment options"

---

## Implementation Notes

1. **Hero Image:** Replace grey placeholder with actual restaurant image
2. **Translation System:** Replace hardcoded Danish strings with translation keys
3. **Map Integration:** Consider adding map (as in FlutterFlow version) for better UX
4. **Address Display:** Consider adding address/neighborhood (as in FlutterFlow version)
5. **Component Reuse:** OpeningHoursSection is shared component from _shared.jsx

---

**Last Updated:** 2026-02-19
**Status:** JSX v2 design documented, simpler than FlutterFlow implementation
**Migration Note:** FlutterFlow implementation is more feature-rich (includes map, address, custom widgets)
