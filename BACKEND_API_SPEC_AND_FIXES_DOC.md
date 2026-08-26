# 🚀 Leader App – Comprehensive Backend API & Architecture Contract
**Target Audience**: Backend Engineering, API, Database & Security Teams  
**Purpose**: Authoritative specification for role-scoped peers list, dedicated circle peers endpoint, rich peer profile details, finance graph metrics, and the multi-tier **Hierarchical Reporting System** with peer membership dates.

---

## 📌 Table of Contents
1. [Section 1: Role-Scoped All Peers API Fix (`GET /api/v1/peers`)](#section-1-role-scoped-all-peers-api-fix-get-apiv1peers)
2. [Section 2: Dedicated Circle Peers Endpoint (`GET /api/v1/teams/circles/:circle_id/peers`)](#section-2-dedicated-circle-peers-endpoint-get-apiv1teamscirclescircle_idpeers)
3. [Section 3: Finance Metrics & Revenue Graph Trend Fix (`GET /api/v1/finance/metrics`)](#section-3-finance-metrics--revenue-graph-trend-fix-get-apiv1financemetrics)
4. [Section 4: Detailed Peer Profile API Fix (`GET /api/v1/peers/:id`)](#section-4-detailed-peer-profile-api-fix-get-apiv1peersid)
5. [Section 5: Multi-Tier Hierarchical Reporting System & Peer Membership Dates](#section-5-multi-tier-hierarchical-reporting-system--peer-membership-dates)
6. [Section 6: PostgreSQL Database Schema (DDL, Foreign Keys & Indexes)](#section-6-postgresql-database-schema-ddl-foreign-keys--indexes)

---

## Section 1: Role-Scoped All Peers API Fix (`GET /api/v1/peers`)

### 🛑 Current Problem:
The backend was either returning an unscoped list or failing to filter peers according to the logged-in user's role and circle access.

### ✅ Required Backend Scoping Logic (Derived automatically from Bearer Token):
When the frontend calls `GET /api/v1/peers` with `Authorization: Bearer <token>`, the backend **must inspect the leader's role and scope query results**:

| Active User Role | Scoping Filter Rule |
|---|---|
| **Circle Chair (CC)** | Only peers belonging to their assigned circle (`circle_id = leader.assigned_circle_id`). |
| **Circle Founder / Director (CF / CD)** | Only peers belonging to circles launched/managed by this founder. |
| **Industry Director (ID)** | All peers belonging to all circles within their assigned industry vertical. |
| **District Exec Director (DED)** | All peers belonging to all circles within their assigned district (`district_id = leader.district_id`). |
| **Country Director / Super Admin** | All peers across the entire platform. |

### 🌐 Endpoint Details:
- **Route**: `GET /api/v1/peers`
- **Headers**: `Authorization: Bearer <AUTH_TOKEN>`
- **Query Parameters (Optional)**:
  - `circle_id` (UUID, optional): Filter by a specific circle within the leader's allowed scope.
  - `status` (`Active` | `Needs Attention` | `At Risk` | `Pending` | `All`, default: `All`): Filter by peer health status.
  - `sort` (`impact` | `deals` | `attendance` | `name`, default: `impact`): Sort order.
  - `search` (String, optional): Case-insensitive search on peer name, company name, city, designation, or specialization.
  - `page` (Integer, default: 1)
  - `per_page` (Integer, default: 20)

### 📦 Expected JSON Response (`200 OK`):
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

## Section 2: Dedicated Circle Peers Endpoint (`GET /api/v1/teams/circles/:circle_id/peers`)

### 🛑 Purpose:
On the **Circle Details** screen, under the **Peers Tab**, the app requires all peers belonging specifically to that designated Circle ID.

### 🌐 Endpoint Details:
- **Route**: `GET /api/v1/teams/circles/{circle_id}/peers`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer <AUTH_TOKEN>`
- **Query Parameters (Optional)**:
  - `status` (`Active` | `Needs Attention` | `At Risk` | `All`, default: `All`)
  - `search` (String, optional)
  - `sort` (`impact` | `deals` | `attendance` | `name`, default: `impact`)

### 📦 Expected JSON Response (`200 OK`):
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

## Section 3: Finance Metrics & Revenue Graph Trend Fix (`GET /api/v1/finance/metrics`)

### 🛑 Current Problem:
The mobile finance charts require continuous monthly coordinates (`revenue_trend` for spline/line charts and `business_deals` for bar charts) along with the headline metric cards.

### 🌐 Endpoint Details:
- **Route**: `GET /api/v1/finance/metrics`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer <AUTH_TOKEN>`
- **Query Parameters (Optional)**:
  - `circle_id` (UUID, optional): Scopes metrics to a single circle if selected in the app dropdown.

### 📦 Expected JSON Response (`200 OK`):
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
      {
        "month": "Jan",
        "value": 45.0,
        "collections_raw": 4500000,
        "dues_raw": 500000
      },
      {
        "month": "Feb",
        "value": 52.5,
        "collections_raw": 5250000,
        "dues_raw": 600000
      },
      {
        "month": "Mar",
        "value": 61.0,
        "collections_raw": 6100000,
        "dues_raw": 800000
      },
      {
        "month": "Apr",
        "value": 58.0,
        "collections_raw": 5800000,
        "dues_raw": 750000
      },
      {
        "month": "May",
        "value": 74.5,
        "collections_raw": 7450000,
        "dues_raw": 900000
      },
      {
        "month": "Jun",
        "value": 84.5,
        "collections_raw": 8450000,
        "dues_raw": 1220000
      }
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
      {
        "role": "Circle Chair",
        "direct_referral_cut": "0%",
        "app_join_cut": "0%"
      },
      {
        "role": "Circle Founder / Director",
        "direct_referral_cut": "5%",
        "app_join_cut": "2.5%"
      },
      {
        "role": "Industry Director",
        "direct_referral_cut": "10%",
        "app_join_cut": "4%"
      },
      {
        "role": "District Exec Director (DED)",
        "direct_referral_cut": "10%",
        "app_join_cut": "5%"
      }
    ]
  }
}
```

---

## Section 4: Detailed Peer Profile API Fix (`GET /api/v1/peers/:id`)

### 🛑 Purpose:
When tapping any peer card from any screen, the app opens the full **Peer Profile Screen**. This endpoint must return **all** rich personal, company, category, metric, meeting, and activity history.

### 🌐 Endpoint Details:
- **Route**: `GET /api/v1/peers/{id}`
- **Method**: `GET`
- **Headers**: `Authorization: Bearer <AUTH_TOKEN>`

### 📦 Expected JSON Response (`200 OK`):
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

## Section 5: Multi-Tier Hierarchical Reporting System & Peer Membership Dates

### 🏗️ Reporting Hierarchy & Role Visibility Workflow:

The reporting engine enforces a strict **bottom-up visibility and top-down review** hierarchy:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          SUPER ADMIN / NATIONAL LEADERSHIP                  │
│                     (Can view & export ALL reports nationwide)               │
└──────────────────────────────────────▲──────────────────────────────────────┘
                                       │ Submits District Reports
┌──────────────────────────────────────┴──────────────────────────────────────┐
│                    DISTRICT EXECUTIVE DIRECTOR (DED)                        │
│    • Can VIEW all reports submitted by Circle Chairs, CF, CD & ID           │
│      across all circles in their District.                                  │
│    • Can SUBMIT District Operations / Performance Reports to Super Admin.   │
└──────────────────────────────────────▲──────────────────────────────────────┘
                                       │ Submits Industry Reports
┌──────────────────────────────────────┴──────────────────────────────────────┐
│                         INDUSTRY DIRECTOR (ID)                              │
│    • Can VIEW all circle reports within their Industry Vertical (CC, CF, CD)│
│    • Can SUBMIT Industry Vertical Performance Reports to DED & Super Admin. │
└──────────────────────────────────────▲──────────────────────────────────────┘
                                       │ Submits Circle Reports
┌──────────────────────────────────────┴──────────────────────────────────────┐
│                    CIRCLE FOUNDER / CIRCLE DIRECTOR (CF / CD)               │
│    • Can VIEW all reports submitted by Circle Chairs in their circles.      │
│    • Can SUBMIT Circle Expansion Reports to ID, DED & Super Admin.          │
└──────────────────────────────────────▲──────────────────────────────────────┘
                                       │ Submits Monthly Circle Reports
┌──────────────────────────────────────┴──────────────────────────────────────┐
│                            CIRCLE CHAIR (CC)                                │
│    • Submits Monthly / Weekly Meeting & Assembly reports for their circle.  │
│    • Reports are visible to CF, CD, ID, DED, and Super Admin.               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 🌐 1. Submit Report API (`POST /api/v1/reports`)
- **Route**: `POST /api/v1/reports`
- **Headers**: `Authorization: Bearer <AUTH_TOKEN>`
- **Request Body**:
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
- **Response (`201 Created`):**
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

### 🌐 2. Get Scoped Reports List (`GET /api/v1/reports`)
- **Route**: `GET /api/v1/reports`
- **Headers**: `Authorization: Bearer <AUTH_TOKEN>`
- **Query Parameters**:
  - `circle_id` (UUID, optional): Filter by circle.
  - `report_type` (`Monthly` | `Weekly` | `District` | `Industry` | `All`, default: `All`)
  - `status` (`Under Review` | `Approved` | `Actioned` | `All`)
  - `page` (Integer, default: 1)
  - `per_page` (Integer, default: 20)

- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "rep_101",
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
        },
        {
          "peer_id": "a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d",
          "name": "Pooja Sharma",
          "avatar_url": "https://peersunity.com/storage/avatars/pooja.png",
          "company": "BioHealth Labs",
          "designation": "Managing Director",
          "status": "Needs Attention",
          "platform_membership_start": "2024-02-01",
          "platform_membership_end": "2025-02-01",
          "circle_joining_date": "2024-04-15",
          "circle_renewal_date": "2025-04-15",
          "attendance": "68%",
          "deals_closed": "₹14.0L",
          "p2p_count": 8,
          "referrals_count": 4
        }
      ]
    }
  ]
}
```

---

### 🌐 3. Get Full Report Details with Peer Roster (`GET /api/v1/reports/:id`)
- **Route**: `GET /api/v1/reports/{id}`
- **Headers**: `Authorization: Bearer <AUTH_TOKEN>`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Report details fetched successfully.",
  "data": {
    "id": "rep_101",
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
      },
      {
        "peer_id": "a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d",
        "name": "Pooja Sharma",
        "avatar_url": "https://peersunity.com/storage/avatars/pooja.png",
        "company": "BioHealth Labs",
        "designation": "Managing Director",
        "status": "Needs Attention",
        "platform_membership_start": "2024-02-01",
        "platform_membership_end": "2025-02-01",
        "circle_joining_date": "2024-04-15",
        "circle_renewal_date": "2025-04-15",
        "attendance": "68%",
        "deals_closed": "₹14.0L",
        "p2p_count": 8,
        "referrals_count": 4
      }
    ]
  }
}
```

---

## Section 6: PostgreSQL Database Schema (DDL, Foreign Keys & Indexes)

Run these queries in PostgreSQL to support all features, foreign keys, and indexes:

```sql
-- 1. Reports Master Table (with Multi-tier Scoping & Peer Breakdown)
CREATE TABLE IF NOT EXISTS leader_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID REFERENCES circles(id) ON DELETE CASCADE,
    district_id UUID NULL,
    industry_id UUID NULL,
    submitted_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    submitter_role VARCHAR(100) NOT NULL,
    report_type VARCHAR(50) NOT NULL DEFAULT 'Monthly',
    period VARCHAR(50) NOT NULL,
    attendance_percentage NUMERIC(5, 2) DEFAULT 0.00,
    deals_closed_value VARCHAR(100) NULL,
    total_revenue VARCHAR(100) NULL,
    content TEXT NULL,
    summary_text TEXT NULL,
    highlights TEXT NULL,
    challenges_faced TEXT NULL,
    action_items TEXT NULL,
    included_sections JSONB DEFAULT '["attendance", "financials", "peer_roster"]'::jsonb,
    peers_roster JSONB DEFAULT '[]'::jsonb,
    status VARCHAR(50) NOT NULL DEFAULT 'Under Review',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE NULL
);

-- 2. Peer Circle Memberships Table (Tracks start/expiry dates for Global App & Circles)
CREATE TABLE IF NOT EXISTS circle_peer_memberships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    circle_id UUID NOT NULL REFERENCES circles(id) ON DELETE CASCADE,
    platform_membership_start DATE NOT NULL,
    platform_membership_end DATE NOT NULL,
    circle_joining_date DATE NOT NULL,
    circle_renewal_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Active',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_user_circle UNIQUE (user_id, circle_id)
);

-- 3. High Performance Indexes
CREATE INDEX IF NOT EXISTS idx_leader_reports_circle ON leader_reports (circle_id);
CREATE INDEX IF NOT EXISTS idx_leader_reports_district ON leader_reports (district_id);
CREATE INDEX IF NOT EXISTS idx_leader_reports_submitter ON leader_reports (submitted_by_user_id);
CREATE INDEX IF NOT EXISTS idx_circle_peer_user ON circle_peer_memberships (user_id);
CREATE INDEX IF NOT EXISTS idx_circle_peer_circle ON circle_peer_memberships (circle_id);
CREATE INDEX IF NOT EXISTS idx_circle_peer_status ON circle_peer_memberships (status);
```
