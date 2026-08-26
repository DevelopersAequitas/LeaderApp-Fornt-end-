# 📱 Leader App – Backend API Integration & Data Contract Document
**Target Audience**: Mobile App Engineers (Flutter / React Native / iOS / Android) & Backend Engineering Teams  
**Base URL**: `https://<YOUR_API_DOMAIN>/api/v1`  
**Authentication**: All endpoints require `Authorization: Bearer <AUTH_TOKEN>`

---

## 📌 Table of Contents
1. [General Headers & Response Standard](#1-general-headers--response-standard)
2. [Module 1: Role-Scoped Peers API (`GET /api/v1/peers`)](#module-1-role-scoped-peers-api-get-apiv1peers)
3. [Module 2: Dedicated Circle Peers (`GET /api/v1/teams/circles/:circle_id/peers`)](#module-2-dedicated-circle-peers-get-apiv1teamscirclescircle_idpeers)
4. [Module 3: Finance Metrics & Trend Graphs (`GET /api/v1/finance/metrics`)](#module-3-finance-metrics--trend-graphs-get-apiv1financemetrics)
5. [Module 4: Detailed Rich Peer Profile (`GET /api/v1/peers/:id`)](#module-4-detailed-rich-peer-profile-get-apiv1peersid)
6. [Module 5: Hierarchical Reporting System](#module-5-hierarchical-reporting-system)
   - [5.1 Submit Report (`POST /api/v1/reports`)](#51-submit-report-post-apiv1reports)
   - [5.2 List Reports (`GET /api/v1/reports`)](#52-list-reports-get-apiv1reports)
   - [5.3 Report Details (`GET /api/v1/reports/:id`)](#53-report-details-get-apiv1reportsid)
7. [TypeScript / Dart Data Interfaces](#7-typescript--dart-data-interfaces)

---

## 1. General Headers & Response Standard

### Standard Headers:
```http
Authorization: Bearer <JWT_ACCESS_TOKEN>
Accept: application/json
Content-Type: application/json
```

### Standard Response Envelopes:
- **Success**: `{ "success": true, "message": "...", "data": ... }`
- **Error**: `{ "success": false, "message": "Error description", "errors": { ... } }`

---

## Module 1: Role-Scoped Peers API (`GET /api/v1/peers`)

### 📌 Description:
Returns peers filtered automatically based on the logged-in leader's role (Circle Chair, Circle Founder/Director, Industry Director, DED, or Super Admin).

- **Endpoint**: `GET /api/v1/peers`
- **Query Parameters**:
  | Parameter | Type | Required | Default | Description |
  |---|---|---|---|---|
  | `circle_id` | UUID | No | `null` | Filter by specific circle |
  | `status` | String | No | `All` | `Active`, `Needs Attention`, `At Risk`, `Pending`, `All` |
  | `sort` | String | No | `impact` | `impact`, `deals`, `attendance`, `name` |
  | `search` | String | No | `null` | Search on name, company, city, designation |
  | `page` | Integer | No | `1` | Page number |
  | `per_page` | Integer | No | `20` | Items per page |

### 📥 Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Peers retrieved successfully.",
  "meta": {
    "current_page": 1,
    "last_page": 3,
    "per_page": 20,
    "total": 48
  },
  "data": [
    {
      "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
      "name": "Siddharth Verma",
      "avatar_url": "https://peersunity.com/storage/avatars/siddharth.png",
      "company": "Apex Dynamics Pvt Ltd",
      "circle": "Mumbai Tech Sunrise",
      "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
      "location": "Mumbai",
      "designation": "Founder & CEO",
      "industry": "Technology",
      "level4_category": "FinTech SaaS",
      "tags": "FinTech · Series A · B2B SaaS",
      "status": "Active",
      "impact_count": 48,
      "deals_formatted": "₹32.5L",
      "coins": 1240,
      "attendance": "94%",
      "phone": "+919876543210",
      "email": "siddharth@apexdynamics.in",
      "is_verified": true,
      "intro_video_url": "https://peersunity.com/storage/videos/siddharth_intro.mp4"
    }
  ]
}
```

---

## Module 2: Dedicated Circle Peers (`GET /api/v1/teams/circles/:circle_id/peers`)

### 📌 Description:
Used on the **Circle Details Screen > Peers Tab** to load all peer members for a specific circle.

- **Endpoint**: `GET /api/v1/teams/circles/{circle_id}/peers`
- **Path Parameter**: `circle_id` (UUID, required)
- **Query Parameters**:
  | Parameter | Type | Required | Default | Description |
  |---|---|---|---|---|
  | `status` | String | No | `All` | `Active`, `Needs Attention`, `At Risk`, `All` |
  | `search` | String | No | `null` | Search peer name or company |
  | `sort` | String | No | `impact` | `impact`, `deals`, `attendance`, `name` |

### 📥 Success Response (`200 OK`):
```json
{
  "success": true,
  "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
  "circle_name": "Mumbai Tech Sunrise",
  "total_peers": 56,
  "data": [
    {
      "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
      "name": "Siddharth Verma",
      "avatar_url": "https://peersunity.com/storage/avatars/siddharth.png",
      "company": "Apex Dynamics Pvt Ltd",
      "circle": "Mumbai Tech Sunrise",
      "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
      "location": "Mumbai",
      "designation": "Founder & CEO",
      "industry": "Technology",
      "level4_category": "FinTech SaaS",
      "tags": "FinTech · Series A · B2B SaaS",
      "status": "Active",
      "impact_count": 48,
      "deals_formatted": "₹32.5L",
      "coins": 1240,
      "attendance": "94%",
      "phone": "+919876543210",
      "email": "siddharth@apexdynamics.in",
      "joined_date": "2024-01-15",
      "is_verified": true,
      "intro_video_url": "https://peersunity.com/storage/videos/siddharth_intro.mp4"
    }
  ]
}
```

---

## Module 3: Finance Metrics & Trend Graphs (`GET /api/v1/finance/metrics`)

### 📌 Description:
Powers the **Finance & Accounts Dashboard**, headline metric cards, 6-month continuous spline/bar charts, and commission rate tiers.

- **Endpoint**: `GET /api/v1/finance/metrics`
- **Query Parameter**: `circle_id` (UUID, optional) to filter metrics to a single circle.

### 📥 Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Finance metrics and trend datasets fetched successfully.",
  "data": {
    "total_collections": "₹84.5L",
    "total_dues": "₹12.2L",
    "projected_annual_revenue": "₹1.48Cr",
    "deals_closed": 28,
    "coin_issuances_total": 14500,
    "revenue_trend": [
      { "month": "Jan", "value": 45.0, "collections_raw": 4500000, "dues_raw": 500000 },
      { "month": "Feb", "value": 52.5, "collections_raw": 5250000, "dues_raw": 600000 },
      { "month": "Mar", "value": 61.0, "collections_raw": 6100000, "dues_raw": 800000 },
      { "month": "Apr", "value": 58.0, "collections_raw": 5800000, "dues_raw": 750000 },
      { "month": "May", "value": 74.5, "collections_raw": 7450000, "dues_raw": 900000 },
      { "month": "Jun", "value": 84.5, "collections_raw": 8450000, "dues_raw": 1220000 }
    ],
    "business_deals": [
      { "month": "Jan", "value": 14.0 },
      { "month": "Feb", "value": 18.0 },
      { "month": "Mar", "value": 22.0 },
      { "month": "Apr", "value": 19.0 },
      { "month": "May", "value": 25.0 },
      { "month": "Jun", "value": 28.0 }
    ],
    "commission_rates": [
      {
        "label": "Direct Referral Commission",
        "rate": "10%",
        "description": "Earned on direct peer joins into your circles.",
        "status": "Active"
      },
      {
        "label": "District Override Royalty",
        "rate": "10%",
        "description": "Quarterly override on total district revenue.",
        "status": "Active"
      }
    ],
    "commission_structure": [
      { "role": "Circle Chair", "direct_referral_cut": "0%", "app_join_cut": "0%" },
      { "role": "Circle Founder / Director", "direct_referral_cut": "5%", "app_join_cut": "2.5%" },
      { "role": "Industry Director", "direct_referral_cut": "10%", "app_join_cut": "4%" },
      { "role": "District Exec Director (DED)", "direct_referral_cut": "10%", "app_join_cut": "5%" }
    ]
  }
}
```

---

## Module 4: Detailed Rich Peer Profile (`GET /api/v1/peers/:id`)

### 📌 Description:
Loaded when tapping any peer card from any screen. Returns complete biographical data, metrics, contact links, meetings, and testimonials.

- **Endpoint**: `GET /api/v1/peers/{id}`
- **Path Parameter**: `id` (UUID, required)

### 📥 Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Peer profile details retrieved successfully.",
  "data": {
    "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
    "name": "Siddharth Verma",
    "avatar_url": "https://peersunity.com/storage/avatars/siddharth.png",
    "designation": "Founder & CEO",
    "company": "Apex Dynamics Pvt Ltd",
    "circle": "Mumbai Tech Sunrise",
    "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
    "location": "Mumbai, Maharashtra, India",
    "industry": "Technology",
    "level4_category": "FinTech SaaS",
    "sub_industry": "FinTech Enterprise Solutions",
    "status": "Active",
    "is_verified": true,
    "intro_video_url": "https://peersunity.com/storage/videos/siddharth_intro.mp4",
    "bio": "Building scalable cloud infrastructure and enterprise FinTech platforms.",
    "birthday": "25 August",
    "anniversary": "12 November",
    "joined_date": "15 January 2024",
    "contact": {
      "email": "siddharth@apexdynamics.in",
      "phone": "+919876543210",
      "linkedin": "https://linkedin.com/in/siddharthverma",
      "whatsapp": "+919876543210"
    },
    "metrics": {
      "impact": 48,
      "impact_count": 48,
      "deals_given": "₹32.5L",
      "deals_received": "₹45.0L",
      "deals_closed": "₹77.5L",
      "attendance_percentage": "94%",
      "attendance_rate": "94%",
      "p2p_meetings": 24,
      "p2p_sessions": 24,
      "referrals_given": 18,
      "referrals_received": 12,
      "coins": 1240,
      "coins_earned": 1240
    },
    "tags": [
      "FinTech",
      "Series A",
      "B2B SaaS"
    ],
    "meetings": [
      {
        "id": "meet_301",
        "day": "01",
        "month": "Sep",
        "title": "Monthly Circle Assembly",
        "time_location": "7:30 AM - The Grand Ballroom, Mumbai",
        "status": "Confirmed",
        "type": "Circle Meeting"
      }
    ],
    "activities": [
      {
        "id": "act_401",
        "icon_type": "arrows",
        "title": "Completed 1-on-1 P2P meeting with Ananya Roy",
        "subtitle": "Discussed Healthcare AI Integration Pipeline",
        "created_at": "2 hours ago"
      }
    ],
    "testimonials": [
      {
        "id": "tst_901",
        "author_name": "Kavitha Rao",
        "author_initials": "KR",
        "subtitle": "Industry Director · Technology",
        "rating": 5,
        "content": "Siddharth's team delivered a state-of-the-art payment solution.",
        "date": "10 Aug 2026"
      }
    ]
  }
}
```

---

## Module 5: Hierarchical Reporting System

### 5.1 Submit Report (`POST /api/v1/reports`)
- **Endpoint**: `POST /api/v1/reports`
- **Request Body (`application/json`)**:
```json
{
  "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
  "report_type": "Monthly",
  "period": "August 2026",
  "attendance_percentage": 94.5,
  "deals_closed_value": "₹18.5L",
  "total_revenue": "₹24.0L",
  "content": "Overall meeting went smoothly with strong attendance across sub-industries.",
  "summary_text": "Strong participation with 4 new peer referrals closed.",
  "highlights": "Launched 2 new FinTech partnerships and added 3 verified peers.",
  "challenges_faced": "Need faster turnaround on peer onboarding verification.",
  "action_items": "Follow up with 3 pending members for fee renewal and schedule Q4 assemblies.",
  "included_sections": [
    "attendance",
    "financials",
    "peer_roster",
    "p2p_meetings",
    "action_items"
  ]
}
```
- **Response (`201 Created`)**:
```json
{
  "success": true,
  "message": "Report submitted successfully and routed to higher leadership.",
  "data": {
    "report_id": "9a01f822-1082-4112-aa01-d82049182390",
    "status": "Under Review",
    "visible_to_roles": ["circleFounder", "circleDirector", "industryDirector", "districtExecDirector", "superAdmin"]
  }
}
```

---

### 5.2 List Reports (`GET /api/v1/reports`)
- **Endpoint**: `GET /api/v1/reports`
- **Query Parameters**:
  - `circle_id` (UUID, optional)
  - `report_type` (`Monthly` | `Weekly` | `District` | `Industry` | `All`, default: `All`)
  - `status` (`Under Review` | `Approved` | `Actioned` | `All`, default: `All`)
  - `page` (Integer, default: 1)
  - `per_page` (Integer, default: 20)

- **Response (`200 OK`)**:
```json
{
  "success": true,
  "data": [
    {
      "id": "9a01f822-1082-4112-aa01-d82049182390",
      "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
      "circle_name": "Mumbai Tech Sunrise",
      "report_type": "Monthly",
      "period": "August 2026",
      "submitted_by": "Arjun Patel",
      "submitter_role": "Circle Chair",
      "submitted_at": "2026-08-25T10:00:00Z",
      "status": "Approved",
      "attendance_percentage": 94,
      "deals_closed_value": "₹18.5L",
      "total_revenue": "₹24.0L",
      "summary_text": "Strong monthly participation with 4 new peer referrals closed.",
      "action_items": "Follow up with 3 pending members for fee renewal.",
      "peers_roster": [
        {
          "peer_id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
          "name": "Siddharth Verma",
          "avatar_url": "https://peersunity.com/storage/avatars/siddharth.png",
          "company": "Apex Dynamics Pvt Ltd",
          "designation": "Founder & CEO",
          "status": "Active",
          "platform_membership_start": "2024-01-15",
          "platform_membership_end": "2025-01-15",
          "circle_joining_date": "2024-03-01",
          "circle_renewal_date": "2025-03-01",
          "attendance": "94%",
          "deals_closed": "₹32.5L",
          "p2p_count": 24,
          "referrals_count": 18
        }
      ]
    }
  ]
}
```

---

### 5.3 Report Details (`GET /api/v1/reports/:id`)
- **Endpoint**: `GET /api/v1/reports/{id}`
- **Response (`200 OK`)**:
```json
{
  "success": true,
  "message": "Report details fetched successfully.",
  "data": {
    "id": "9a01f822-1082-4112-aa01-d82049182390",
    "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
    "circle_name": "Mumbai Tech Sunrise",
    "district_id": "dis_mum_01",
    "district_name": "District Mumbai",
    "industry_name": "Technology",
    "report_type": "Monthly",
    "period": "August 2026",
    "submitted_by": "Arjun Patel",
    "submitter_role": "Circle Chair",
    "submitted_at": "2026-08-25T10:00:00Z",
    "status": "Approved",
    "attendance_percentage": 94.5,
    "deals_closed_value": "₹18.5L",
    "total_revenue": "₹24.0L",
    "summary_text": "Strong monthly participation with 4 new peer referrals closed.",
    "highlights": "Launched 2 new FinTech partnerships and added 3 verified peers.",
    "challenges_faced": "Need faster turnaround on peer onboarding verification.",
    "action_items": "Follow up with 3 pending members for fee renewal and schedule Q4 assemblies.",
    "peers_roster": [
      {
        "peer_id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
        "name": "Siddharth Verma",
        "avatar_url": "https://peersunity.com/storage/avatars/siddharth.png",
        "company": "Apex Dynamics Pvt Ltd",
        "designation": "Founder & CEO",
        "status": "Active",
        "platform_membership_start": "2024-01-15",
        "platform_membership_end": "2025-01-15",
        "circle_joining_date": "2024-03-01",
        "circle_renewal_date": "2025-03-01",
        "attendance": "94%",
        "deals_closed": "₹32.5L",
        "p2p_count": 24,
        "referrals_count": 18
      }
    ]
  }
}
```

---

## 7. TypeScript / Dart Data Interfaces

### TypeScript (`types.ts`):
```typescript
export interface PeerCard {
  id: string;
  name: string;
  avatar_url: string | null;
  company: string;
  circle: string;
  circle_id: string;
  location: string;
  designation: string;
  industry: string;
  level4_category: string;
  tags: string;
  status: 'Active' | 'Needs Attention' | 'At Risk' | 'Pending';
  impact_count: number;
  deals_formatted: string;
  coins: number;
  attendance: string;
  phone: string;
  email: string;
  is_verified: boolean;
  intro_video_url: string | null;
  joined_date?: string;
}

export interface FinanceMetrics {
  total_collections: string;
  total_dues: string;
  projected_annual_revenue: string;
  deals_closed: number;
  coin_issuances_total: number;
  revenue_trend: Array<{
    month: string;
    value: number;
    collections_raw: number;
    dues_raw: number;
  }>;
  business_deals: Array<{
    month: string;
    value: number;
  }>;
  commission_rates: Array<{
    label: string;
    rate: string;
    description: string;
    status: string;
  }>;
  commission_structure: Array<{
    role: string;
    direct_referral_cut: string;
    app_join_cut: string;
  }>;
}

export interface PeerRosterItem {
  peer_id: string;
  name: string;
  avatar_url: string | null;
  company: string;
  designation: string;
  status: string;
  platform_membership_start: string;
  platform_membership_end: string;
  circle_joining_date: string;
  circle_renewal_date: string;
  attendance: string;
  deals_closed: string;
  p2p_count: number;
  referrals_count: number;
}
```
