# Leader App — Pending Backend APIs & Data Gaps Specification

> **Document Version:** 1.0.0  
> **Prepared For:** Backend Engineering & Product Team  
> **Base URLs:**
> - Dev: `https://dev.peersunity.com/api/v1`
> - Production: `https://peersunity.com/api/v1`

---

## 📌 Executive Summary

The Flutter Leader Mobile App has completed **Clean Architecture** refactoring (MVP + BLoC + Repository Pattern + ApiClient). The core 26 REST APIs and the 21-flag RBAC permission matrix are integrated.

However, several specialized screens, subtabs, and detail workflows currently rely on local frontend schemas and **require dedicated backend REST API endpoints** to be fully dynamic in production.

This document details every section, the required API endpoints, HTTP methods, parameters, and exact JSON request/response contracts.

---

## 📋 Comprehensive API Gap Matrix

| # | Feature / Screen | Section / Tab | Gap Description | Proposed API Endpoint | Method | Priority |
|---|---|---|---|---|---|---|
| 1 | **Circle Details** | Sub-Industries Tab | Active & Open sub-industry slots per circle | `/teams/circles/{id}/sub-industries` | `GET` | **High** |
| 2 | **Circle Details** | Events Tab | Upcoming & Completed circle assemblies/summits | `/teams/circles/{id}/events` | `GET` | **High** |
| 3 | **Peer Profile** | Meetings Tab | Historical & scheduled P2P / circle meetings | `/peers/{id}/meetings` | `GET` | **High** |
| 4 | **Peer Profile** | Activity Tab | Chronological audit feed of peer actions | `/peers/{id}/activities` | `GET` | **Medium** |
| 5 | **Finance** | Commission Setup | Super Admin modifying commission cuts per role | `/finance/commission-rates` | `PUT` | **High** |
| 6 | **Finance** | Record Offline Fee | Coordinator marking manual cash/cheque fee | `/finance/transactions/record-offline` | `POST` | **Medium** |
| 7 | **Profile** | Edit Bio & Avatar | Updating leader phone, email, or avatar image | `/auth/profile` | `PUT / POST` | **High** |
| 8 | **Dashboard / Quick Actions** | Log P2P Session | Quick registration of a 1-on-1 meeting | `/peers/p2p-meetings` | `POST` | **Medium** |
| 9 | **Dashboard / Quick Actions** | Create Referral | Submitting a business lead on behalf of a peer | `/referrals` | `POST` | **High** |
| 10 | **Reports** | Download Link | Generating dynamic pre-signed S3 PDF/Excel download URLs | `/reports/{id}/download` | `GET` | **Medium** |

---

## 🔍 Detailed Endpoint Specifications

---

### 1. Circle Details — Sub-Industries Breakdown

* **Current Status:** Displays static local categories.
* **Target Screen:** `CircleDetailsView` ➔ Sub-Industries Tab.
* **Endpoint:** `GET /api/v1/teams/circles/{circle_id}/sub-industries`
* **Headers:** `Authorization: Bearer <TOKEN>`

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "circle_id": "cir_101",
    "active_sub_industries": [
      {
        "id": "sub_01",
        "name": "Web & App Development",
        "peer_count": 4,
        "is_open": false
      },
      {
        "id": "sub_02",
        "name": "AI & Machine Learning",
        "peer_count": 2,
        "is_open": false
      }
    ],
    "open_sub_industries": [
      {
        "id": "sub_03",
        "name": "Cybersecurity & Cloud",
        "peer_count": 0,
        "is_open": true
      },
      {
        "id": "sub_04",
        "name": "FinTech SaaS",
        "peer_count": 0,
        "is_open": true
      }
    ]
  }
}
```

---

### 2. Circle Details — Circle Events & Assemblies

* **Current Status:** Displays static local event list.
* **Target Screen:** `CircleDetailsView` ➔ Events Tab.
* **Endpoint:** `GET /api/v1/teams/circles/{circle_id}/events`
* **Query Parameters:**
  * `filter`: `all` | `upcoming` | `completed` (Optional)

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": [
    {
      "id": "evt_201",
      "title": "Tech Growth Summit 2026",
      "date": "2026-09-01",
      "time": "10:00 AM",
      "location": "The Grand Ballroom, Mumbai",
      "mode": "In-Person",
      "status": "Upcoming",
      "attendees_count": 48
    },
    {
      "id": "evt_202",
      "title": "AI & ML Peer Workshop",
      "date": "2026-08-20",
      "time": "03:00 PM",
      "location": "Zoom Online",
      "mode": "Online",
      "status": "Completed",
      "attendees_count": 52
    }
  ]
}
```

---

### 3. Peer Profile — Meetings & P2P History

* **Current Status:** Profile headers are live; meetings subtab needs dedicated sub-resource.
* **Target Screen:** `PeerProfileView` ➔ Meetings Tab.
* **Endpoint:** `GET /api/v1/peers/{peer_id}/meetings`

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": [
    {
      "id": "meet_301",
      "day": "01",
      "month": "Sep",
      "title": "Monthly Circle Meeting",
      "time_location": "7:30 AM - Grand Ballroom, Mumbai",
      "status": "Confirmed",
      "type": "Circle Meeting"
    },
    {
      "id": "meet_302",
      "day": "12",
      "month": "Sep",
      "title": "P2P 1-on-1 Alignment",
      "time_location": "4:00 PM - Starbucks BKC",
      "status": "Open",
      "type": "P2P Meeting"
    }
  ]
}
```

---

### 4. Peer Profile — Activity Audit Trail

* **Current Status:** Displays calculated stats; requires real chronological activity feed.
* **Target Screen:** `PeerProfileView` ➔ Activity Tab.
* **Endpoint:** `GET /api/v1/peers/{peer_id}/activities`
* **Query Parameters:** `page=1&limit=20`

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "data": [
    {
      "id": "act_401",
      "icon_type": "arrows",
      "title": "Completed P2P meeting with Ananya Roy",
      "subtitle": "Discussed healthcare AI integration pipeline",
      "created_at": "2 hours ago"
    },
    {
      "id": "act_402",
      "icon_type": "speaker",
      "title": "Gave 2 referrals to CloudSoft",
      "subtitle": "Enterprise Cloud Migration leads",
      "created_at": "3 days ago"
    },
    {
      "id": "act_403",
      "icon_type": "trophy",
      "title": "Closed ₹14.2L deal with Veritas Tech",
      "subtitle": "Transaction confirmed by Circle Director",
      "created_at": "1 week ago"
    }
  ]
}
```

---

### 5. Financial Management — Update Commission Structure

* **Current Status:** Read-only from `/finance/metrics`. Needs mutation endpoint for Super Admin.
* **Target Screen:** `FinanceView` ➔ Commission Structure Table.
* **Endpoint:** `PUT /api/v1/finance/commission-rates`
* **Headers:** `Authorization: Bearer <TOKEN>` (Requires Super Admin permissions)

#### Request Body:
```json
{
  "commission_rates": [
    {
      "role_id": "circleFounder",
      "direct_referral_cut_percentage": 5.0,
      "app_join_cut_percentage": 2.5
    },
    {
      "role_id": "circleDirector",
      "direct_referral_cut_percentage": 7.5,
      "app_join_cut_percentage": 3.0
    },
    {
      "role_id": "industryDirector",
      "direct_referral_cut_percentage": 10.0,
      "app_join_cut_percentage": 4.0
    }
  ]
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Commission rates updated successfully."
}
```

---

### 6. Financial Management — Record Manual / Offline Payment

* **Current Status:** Read-only transactions from `/finance/transactions`.
* **Target Screen:** `FinanceView` ➔ Record Dues Modal.
* **Endpoint:** `POST /api/v1/finance/transactions/record-offline`

#### Request Body:
```json
{
  "peer_id": "peer_001",
  "circle_id": "cir_101",
  "amount": 45000,
  "payment_mode": "Cheque",
  "reference_number": "CHQ-890211",
  "payment_date": "2026-08-25",
  "type": "Annual Membership Fee"
}
```

#### Success Response (`201 Created`):
```json
{
  "success": true,
  "message": "Payment recorded successfully.",
  "data": {
    "transaction_id": "txn_9042",
    "status": "Paid"
  }
}
```

---

### 7. User Profile & Settings — Update Profile & Avatar

* **Current Status:** Session initialized upon login; edits require server persistence.
* **Target Screen:** `ProfileView` ➔ Edit Profile.
* **Endpoint (Bio):** `PUT /api/v1/auth/profile`
* **Endpoint (Avatar):** `POST /api/v1/auth/profile/avatar` (Multipart `image/png`, `image/jpeg`)

#### Request Body (`PUT /auth/profile`):
```json
{
  "name": "Arjun Patel",
  "phone": "+919876543210",
  "bio": "Circle Chair for Mumbai Tech Sunrise.",
  "company_name": "Apex Dynamics Pvt Ltd"
}
```

#### Success Response (`200 OK`):
```json
{
  "success": true,
  "message": "Profile updated successfully.",
  "data": {
    "id": "usr_101",
    "name": "Arjun Patel",
    "phone": "+919876543210",
    "avatar_url": "https://peersunity.com/storage/avatars/usr_101.png"
  }
}
```

---

### 8. Quick Actions — Submit a Referral / Endorsement

* **Current Status:** Referrals list is read via `/referrals`. Adding a referral needs an API.
* **Target Screen:** Referrals Modal.
* **Endpoint:** `POST /api/v1/referrals`

#### Request Body:
```json
{
  "to_peer_id": "peer_002",
  "prospect_name": "Rajesh Singhania",
  "prospect_company": "Reliance Retail Tech",
  "prospect_phone": "+919822019283",
  "prospect_email": "rajesh@relianceretail.com",
  "estimated_deal_value": "₹15.0L",
  "notes": "Interested in AI automation platform consulting."
}
```

#### Success Response (`201 Created`):
```json
{
  "success": true,
  "message": "Referral created and forwarded to peer.",
  "data": {
    "referral_id": "ref_892",
    "status": "Pending"
  }
}
```

---

## 🚀 Summary of Next Steps for Backend Team

1. Implement the **7 high-priority endpoints** outlined above.
2. Ensure CORS and Auth middleware (`Bearer <TOKEN>`) allow requests from mobile clients.
3. Validate that `circle_id` filtering returns scoped data matching the user's role.
