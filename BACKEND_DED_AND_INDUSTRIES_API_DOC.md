# 🚀 Backend API Requirements & Data Fixes Document
**Document Purpose**: Specification for new Industries API and Backend Database / Logic fixes for the **District Executive Director (DED)** and leadership roles.

---

## 📌 Section 1: New API Endpoint Needed — Get All Industries

### `GET /api/v1/teams/industries` (or `GET /api/v1/industries`)
Fetches the official master list of industries (all 18 official industries) along with active circle and peer counts. When accessed by a District Executive Director (DED), it scopes the counts to their assigned district.

- **URL**: `/api/v1/teams/industries`
- **Method**: `GET`
- **Auth**: `Bearer <token>` (Required)
- **Query Parameters (Optional)**:
  - `district_id` (UUID, optional): Filter by district. If omitted, backend derives it from the authenticated leader's token.
  - `status` (`active` | `all`, default: `active`)

#### ✅ Expected Response (200 OK):
```json
{
  "success": true,
  "message": "Industries fetched successfully.",
  "data": [
    {
      "id": "ind_01",
      "name": "Technology",
      "slug": "technology",
      "icon_url": "https://api.peersunity.com/icons/technology.png",
      "circles_count": 3,
      "peers_count": 82,
      "status": "Active"
    },
    {
      "id": "ind_02",
      "name": "Manufacturing",
      "slug": "manufacturing",
      "icon_url": "https://api.peersunity.com/icons/manufacturing.png",
      "circles_count": 2,
      "peers_count": 45,
      "status": "Active"
    },
    {
      "id": "ind_03",
      "name": "Real Estate",
      "slug": "real-estate",
      "icon_url": "https://api.peersunity.com/icons/real-estate.png",
      "circles_count": 1,
      "peers_count": 28,
      "status": "Active"
    },
    {
      "id": "ind_04",
      "name": "Healthcare",
      "slug": "healthcare",
      "icon_url": "https://api.peersunity.com/icons/healthcare.png",
      "circles_count": 2,
      "peers_count": 36,
      "status": "Active"
    },
    {
      "id": "ind_05",
      "name": "Financial Services",
      "slug": "financial-services",
      "icon_url": "https://api.peersunity.com/icons/financial-services.png",
      "circles_count": 1,
      "peers_count": 20,
      "status": "Active"
    },
    {
      "id": "ind_06",
      "name": "Education & Skill",
      "slug": "education-skill",
      "icon_url": "https://api.peersunity.com/icons/education.png",
      "circles_count": 1,
      "peers_count": 18,
      "status": "Active"
    },
    {
      "id": "ind_07",
      "name": "Agriculture & Food",
      "slug": "agriculture-food",
      "icon_url": "https://api.peersunity.com/icons/agriculture.png",
      "circles_count": 1,
      "peers_count": 15,
      "status": "Active"
    },
    {
      "id": "ind_08",
      "name": "Green & Sustainability",
      "slug": "green-sustainability",
      "icon_url": "https://api.peersunity.com/icons/green.png",
      "circles_count": 1,
      "peers_count": 12,
      "status": "Active"
    },
    {
      "id": "ind_09",
      "name": "Media & Entertainment",
      "slug": "media-entertainment",
      "icon_url": "https://api.peersunity.com/icons/media.png",
      "circles_count": 0,
      "peers_count": 0,
      "status": "Active"
    },
    {
      "id": "ind_10",
      "name": "Tourism & Hospitality",
      "slug": "tourism-hospitality",
      "icon_url": "https://api.peersunity.com/icons/tourism.png",
      "circles_count": 0,
      "peers_count": 0,
      "status": "Active"
    },
    {
      "id": "ind_11",
      "name": "Retail & FMCG",
      "slug": "retail-fmcg",
      "icon_url": "https://api.peersunity.com/icons/retail.png",
      "circles_count": 1,
      "peers_count": 14,
      "status": "Active"
    },
    {
      "id": "ind_12",
      "name": "Logistics & Supply Chain",
      "slug": "logistics-supply-chain",
      "icon_url": "https://api.peersunity.com/icons/logistics.png",
      "circles_count": 1,
      "peers_count": 16,
      "status": "Active"
    },
    {
      "id": "ind_13",
      "name": "Construction & Infra",
      "slug": "construction-infra",
      "icon_url": "https://api.peersunity.com/icons/construction.png",
      "circles_count": 0,
      "peers_count": 0,
      "status": "Active"
    },
    {
      "id": "ind_14",
      "name": "Legal & Professional",
      "slug": "legal-professional",
      "icon_url": "https://api.peersunity.com/icons/legal.png",
      "circles_count": 1,
      "peers_count": 11,
      "status": "Active"
    },
    {
      "id": "ind_15",
      "name": "Fashion & Lifestyle",
      "slug": "fashion-lifestyle",
      "icon_url": "https://api.peersunity.com/icons/fashion.png",
      "circles_count": 0,
      "peers_count": 0,
      "status": "Active"
    },
    {
      "id": "ind_16",
      "name": "Automotive",
      "slug": "automotive",
      "icon_url": "https://api.peersunity.com/icons/automotive.png",
      "circles_count": 0,
      "peers_count": 0,
      "status": "Active"
    },
    {
      "id": "ind_17",
      "name": "Energy & Power",
      "slug": "energy-power",
      "icon_url": "https://api.peersunity.com/icons/energy.png",
      "circles_count": 0,
      "peers_count": 0,
      "status": "Active"
    },
    {
      "id": "ind_18",
      "name": "Chemicals & Materials",
      "slug": "chemicals-materials",
      "icon_url": "https://api.peersunity.com/icons/chemicals.png",
      "circles_count": 0,
      "peers_count": 0,
      "status": "Active"
    }
  ]
}
```

---

## 🛠️ Section 2: Backend Database & Logic Fixes Required

### 1. 🛑 Fix Circle Names in DB (Placeholder Text Removal)
- **Current Issue**: `GET /api/v1/teams/circles` is returning:
  `"name": "Enter the complete name of the circle."` and `"name": "Test 1"`.
- **Backend Fix**: Update the `circles` table so all seeded circles have proper, professional names:
  - Example: `"Ahmedabad Tech Pioneers"`, `"Ahmedabad MSME Growth Circle"`, `"Satellite Business Circle"`.

### 2. 🛑 Fix Peer Circle Association in DB
- **Current Issue**: `GET /api/v1/peers` and `GET /api/v1/dashboard/top-impacters` return peers located in `ahmedabad` but with `"circle": "Mumbai Tech Sunrise"`.
- **Backend Fix**: Update foreign keys in the `peers` table so that peers located in Ahmedabad link to the active Ahmedabad circle ID and circle name.

### 3. 🛑 Fix Reports Circle Association
- **Current Issue**: `GET /api/v1/reports` returns reports linked to `"Mumbai Tech Sunrise"`.
- **Backend Fix**: Filter reports by the authenticated DED's `district_id` or link sample reports to the actual district circles.

---

## 💼 Section 3: District Executive Director (DED) Role Specification

### 1. Hierarchy & Permissions
- **Scope**: Entire District (e.g., District Ahmedabad).
- **Structure**: `District ➔ 18 Industries ➔ Circles ➔ Peers`.
- **Visibility**:
  - DED must see all **18 Industries** in the district.
  - Under each Industry, DED must see **all Circles** located in their district.
  - DED can view all peers enrolled in those district circles.

### 2. Financial Model (10% Subscription Overriding Commission)
- **Commission Rule**: DED earns **10%** overriding commission on all peer membership subscription fees paid across all circles within their district.
- **Backend Calculation for DED in `GET /api/v1/finance/metrics`**:
  - `total_collections`: Total peer subscription revenue collected across all circles in the district.
  - `ded_commission_earned`: `total_collections * 0.10` (10% payout).
  - `total_dues`: Outstanding subscription dues across all district peers.
  - `projected_annual_revenue`: Projected annual district revenue.

### 3. Automatic District Scoping via Bearer Token
When the mobile app sends:
`Authorization: Bearer <token>`
The backend should automatically inspect the user's role:
- If `role == "district_exec_director"`, automatically filter all queries:
  - `SELECT * FROM circles WHERE district_id = leader.district_id`
  - `SELECT * FROM peers WHERE circle_id IN (SELECT id FROM circles WHERE district_id = leader.district_id)`
  - `SELECT * FROM reports WHERE circle_id IN (SELECT id FROM circles WHERE district_id = leader.district_id)`
  - `SELECT * FROM transactions WHERE circle_id IN (SELECT id FROM circles WHERE district_id = leader.district_id)`
