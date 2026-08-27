# Leader App – Backend API & Access Control Contract (Development & Production)

This document provides the complete, authoritative API and Access Control Contract for the **Leader Mobile App** (Flutter / Frontend Integration). It covers environment configurations, authentication flows, the dynamic 21-flag permission matrix, tab/screen layout mappings, all **37 REST API endpoints** with complete JSON request/response schemas, and manual PostgreSQL database setup scripts.

---

## 1. Environment Configurations

| Setting | Development (Local / QA) | Staging | Production |
|---|---|---|---|
| **Base URL** | `http://localhost:8000/api/v1` (or local IP) | `https://dev.peersunity.com/api/v1` | `https://peersunity.com/api/v1` |
| **HTTP Headers** | `Accept: application/json`<br>`Content-Type: application/json` | `Accept: application/json`<br>`Content-Type: application/json` | `Accept: application/json`<br>`Content-Type: application/json` |
| **Auth Header** | `Authorization: Bearer <AUTH_TOKEN>` | `Authorization: Bearer <AUTH_TOKEN>` | `Authorization: Bearer <AUTH_TOKEN>` |
| **Test OTP** | `123456` (universal dev bypass) | `123456` (QA enabled) | Live SMS / WhatsApp / Email 6-Digit OTP |
| **Token Lifetime** | 86400 seconds (24 Hours) | 86400 seconds (24 Hours) | 86400 seconds (24 Hours) |

---

## 2. Dynamic RBAC Architecture & 2-Way Web Sync

The Leader App is deeply integrated with the platform's **Dynamic RBAC Web System** (`https://peersunity.com/admin/rbac/permission-matrix`).

```
┌────────────────────────────────────────────────────────────────────────────────────────┐
│             Web Admin RBAC Control (https://peersunity.com/admin/rbac/permission-matrix)│
│  [roles] ◄──► [role_module_access] ◄──► [role_page_permissions] ◄──► [role_data_scope] │
└────────────────────────────────────────┬───────────────────────────────────────────────┘
                                         │  Two-Way Real-time Sync
                                         ▼
┌────────────────────────────────────────────────────────────────────────────────────────┐
│                              Leader App API & Access Control                           │
│  • 12 Granular Capabilities (access_dashboard, access_teams, access_finance, ...)      │
│  • 21-Flag Frontend Permission Matrix (can_access_dashboard, can_access_finance_tab,..) │
│  • LeaderPermissionService & LeaderRoleMatrixService (Auto-Detects RBAC Updates)        │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

### Module to Capability Mapping:
- `Dashboard` Module (`dashboard`) ➔ `access_dashboard` (`can_access_dashboard`)
- `Circles` Module (`circles`) ➔ `access_teams` (`can_access_teams_tab`, `can_manage_circles`)
- `Finance & Analytics` Module (`finance-analytics`) ➔ `access_finance`, `manage_finance` (`can_access_finance_tab`, `can_modify_finance_settings`, `can_view_overall_revenue`)
- `Peers` Module (`members`) ➔ `view_peers` (`can_access_peers_tab`, `can_view_peer_profile`, `can_view_peer_contact_info`) + `manage_peers` (`can_add_edit_peer`)
- `Activities` Module (`activities`) ➔ `request_actions` (`can_send_wishes`)
- `Referral Report` / `Activities` Module ➔ `view_reports` (`can_access_reports_tab`, `can_submit_reports`)
- `Coins` Module (`coins`) ➔ `coin_payouts` (`can_issue_coins`)
- `Role Management` Module (`role-management`) ➔ `manage_roles` (`can_access_role_management`)
- `Settings` Module (`settings`) ➔ `system_configs`
- `Role Data Scope` (District / State / Global) ➔ `regional_data` (`can_view_regional_scope`)

---

## 3. 21-Flag Permission Matrix Contract

Upon successful login/OTP verification, the backend returns the user's role and **21 boolean permissions** that dictate the mobile UI state:

| Permission Key | Circle Chair | Circle Founder / Director | Industry Director | District Exec Director | Super Admin |
|---|:---:|:---:|:---:|:---:|:---:|
| `can_access_dashboard` | `true` | `true` | `true` | `true` | `true` |
| `can_view_overall_revenue` | `false` | `true` | `true` | `true` | `true` |
| `can_review_pending_peers` | `true` | `true` | `true` | `true` | `true` |
| `can_access_peers_tab` | `true` | `true` | `true` | `true` | `true` |
| `can_add_edit_peer` | `false` | `true` | `true` | `true` | `true` |
| `can_send_wishes` | `true` | `true` | `true` | `true` | `true` |
| `can_view_peer_profile` | `true` | `true` | `true` | `true` | `true` |
| `can_view_peer_contact_info` | `true` | `true` | `true` | `true` | `true` |
| `can_access_teams_tab` | `false` | `true` | `true` | `true` | `true` |
| `can_manage_circles` | `false` | `true` | `true` | `true` | `true` |
| `can_assign_circle_chair` | `false` | `true` | `true` | `true` | `true` |
| `can_access_finance_tab` | `false` | `true` | `true` | `true` | `true` |
| `can_modify_finance_settings` | `false` | `false` | `false` | `true` | `true` |
| `can_issue_coins` | `false` | `false` | `false` | `true` | `true` |
| `can_access_reports_tab` | `true` | `true` | `true` | `true` | `true` |
| `can_submit_reports` | `true` | `true` | `true` | `false` | `false` |
| `can_export_peer_data` | `false` | `true` | `true` | `true` | `true` |
| `can_export_financial_data` | `false` | `true` | `true` | `true` | `true` |
| `can_export_global_data` | `false` | `false` | `false` | `false` | `true` |
| `can_access_role_management` | `false` | `false` | `false` | `false` | `true` |
| `can_view_regional_scope` | `false` | `false` | `true` | `true` | `true` |

---

## 4. Complete REST API Specifications (All 37 Endpoints)

---

### 4.1 Authentication & Profile APIs

#### 1. Request Login OTP
- **Route:** `POST /api/v1/auth/send-otp`
- **Request Body:**
```json
{
  "email_or_phone": "harshchauhanwork26@gmail.com"
}
```
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "OTP has been sent successfully to your registered email/phone.",
  "data": {
    "is_registered": true,
    "otp_expiry_seconds": 300
  }
}
```

#### 2. Verify Login OTP
- **Route:** `POST /api/v1/auth/verify-otp`
- **Request Body:**
```json
{
  "email_or_phone": "harshchauhanwork26@gmail.com",
  "otp": "123456"
}
```
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Authentication successful",
  "data": {
    "auth_token": "14|6O8y3h...4fE",
    "refresh_token": "RNKgujzcPbmqwTE8zmI5DYmLSj2OyexjylxaYGzi",
    "token_type": "Bearer",
    "expires_in": 86400,
    "user": {
      "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
      "name": "Harsh Chauhan",
      "email": "harshchauhanwork26@gmail.com",
      "phone": "+919724636800",
      "role": "superAdmin",
      "custom_role_label": null,
      "regional_scope": "Global Scope",
      "member_since": "Aug 2026",
      "avatar_url": "https://peersunity.com/storage/avatars/76265b49.png",
      "managed_circles": [
        {
          "id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
          "name": "Ahmedabad Tech Circle",
          "location": "Ahmedabad",
          "category": "Technology"
        }
      ]
    },
    "permissions": {
      "can_access_dashboard": true,
      "can_view_overall_revenue": true,
      "can_review_pending_peers": true,
      "can_access_peers_tab": true,
      "can_add_edit_peer": true,
      "can_send_wishes": true,
      "can_view_peer_profile": true,
      "can_view_peer_contact_info": true,
      "can_access_teams_tab": true,
      "can_manage_circles": true,
      "can_assign_circle_chair": true,
      "can_access_finance_tab": true,
      "can_modify_finance_settings": true,
      "can_issue_coins": true,
      "can_access_reports_tab": true,
      "can_submit_reports": false,
      "can_export_peer_data": true,
      "can_export_financial_data": true,
      "can_export_global_data": true,
      "can_access_role_management": true,
      "can_view_regional_scope": true
    }
  }
}
```

#### 3. Update Profile Bio & Details
- **Route:** `PUT /api/v1/auth/profile`
- **Headers:** `Authorization: Bearer <TOKEN>`
- **Request Body:**
```json
{
  "name": "Arjun Patel",
  "phone": "+919876543210",
  "bio": "Circle Chair for Mumbai Tech Sunrise.",
  "company_name": "Apex Dynamics Pvt Ltd"
}
```
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Profile updated successfully.",
  "data": {
    "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
    "name": "Arjun Patel",
    "phone": "+919876543210",
    "bio": "Circle Chair for Mumbai Tech Sunrise.",
    "company_name": "Apex Dynamics Pvt Ltd",
    "avatar_url": "https://peersunity.com/storage/avatars/76265b49.png"
  }
}
```

#### 4. Upload Profile Avatar Image
- **Route:** `POST /api/v1/auth/profile/avatar`
- **Headers:** `Authorization: Bearer <TOKEN>`, `Content-Type: multipart/form-data`
- **Request Body:** `avatar`: [Binary Image File (JPG/PNG/WEBP)]
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Avatar updated successfully.",
  "data": {
    "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
    "name": "Arjun Patel",
    "phone": "+919876543210",
    "avatar_url": "https://peersunity.com/storage/avatars/abc1234.png"
  }
}
```

---

### 4.2 Tab 0: Dashboard Endpoints

#### 5. Get Dashboard Metrics
- **Route:** `GET /api/v1/dashboard/metrics`
- **Query Params:** `circle_id` (optional, UUID)
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
    "circle_name": "Mumbai Tech Sunrise",
    "overall_revenue": "₹1.48Cr",
    "overall_deals_closed": "₹1.20Cr",
    "impact": 142,
    "deals": "₹86.4L",
    "p2p_meetings": 38,
    "total_peers": 48,
    "total_peers_growth": 4,
    "referrals": 28,
    "testimonials": 42,
    "coins": 3840,
    "pending_peers_count": 4
  }
}
```

#### 6. Get Top 5 Impacters
- **Route:** `GET /api/v1/dashboard/top-impacters`
- **Query Params:** `circle_id` (optional, UUID)
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "rank": 1,
      "name": "Siddharth Verma",
      "company": "Apex Dynamics Pvt Ltd",
      "location": "Mumbai",
      "lives": 48,
      "coins": 1240
    }
  ]
}
```

---

### 4.3 Tab 1: Peers & Quick Actions Endpoints

#### 7. List Peers Directory
- **Route:** `GET /api/v1/peers`
- **Query Params:** `circle_id`, `status` (`Active`, `Needs Attention`, `At Risk`), `sort` (`name`, `impact`, `deals`, `attendance`), `search`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
      "name": "Siddharth Verma",
      "company": "Apex Dynamics Pvt Ltd",
      "circle": "Mumbai Tech Sunrise",
      "location": "Mumbai",
      "tags": "FinTech · Series A · B2B SaaS",
      "status": "Active",
      "impact_count": 48,
      "deals_formatted": "₹32.5L",
      "coins": 1240,
      "attendance": "94%"
    }
  ]
}
```

#### 8. Get Peer Celebrations
- **Route:** `GET /api/v1/peers/celebrations`
- **Query Params:** `circle_id` (optional, UUID)
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "birthdays": [
      {
        "id": "cel_01",
        "peer_id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
        "name": "Siddharth Verma",
        "company": "Apex Dynamics Pvt Ltd",
        "date_formatted": "25 Aug",
        "is_today": true
      }
    ],
    "anniversaries": [
      {
        "id": "cel_03",
        "peer_id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
        "name": "Rohan Deshmukh",
        "company": "Elevate Logistics",
        "milestone": "3 Years in Circle",
        "date_formatted": "28 Aug",
        "is_today": false
      }
    ]
  }
}
```

#### 9. Get Detailed Peer Profile
- **Route:** `GET /api/v1/peers/:id`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
    "name": "Siddharth Verma",
    "designation": "Founder & CEO",
    "company": "Apex Dynamics Pvt Ltd",
    "circle": "Mumbai Tech Sunrise",
    "location": "Mumbai, India",
    "contact": {
      "email": "siddharth@apexdynamics.in",
      "phone": "+919876543210",
      "linkedin": "linkedin.com/in/siddharthverma"
    },
    "metrics": {
      "impact": 48,
      "deals_given": "₹32.5L",
      "deals_received": "₹45.0L",
      "attendance": "94%",
      "p2p_meetings": 24,
      "referrals_given": 18
    },
    "bio": "Building scalable cloud infrastructure and enterprise FinTech platforms.",
    "sub_industry": "FinTech SaaS",
    "tags": ["FinTech", "Series A", "B2B SaaS"]
  }
}
```

#### 10. Send Celebration Wish
- **Route:** `POST /api/v1/peers/:id/send-wish`
- **Request Body:**
```json
{
  "type": "birthday",
  "message": "Happy Birthday Siddharth! Wishing you massive growth and success!"
}
```
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Wish sent to Siddharth Verma successfully!"
}
```

#### 11. Get Peer Meetings & P2P History
- **Route:** `GET /api/v1/peers/:id/meetings`
- **Response (`200 OK`):**
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

#### 12. Get Peer Activity Audit Feed
- **Route:** `GET /api/v1/peers/:id/activities`
- **Query Params:** `page=1&limit=20`
- **Response (`200 OK`):**
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

#### 13. Log 1-on-1 P2P Meeting
- **Route:** `POST /api/v1/peers/p2p-meetings`
- **Request Body:**
```json
{
  "peer_id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
  "meeting_date": "2026-09-01",
  "meeting_place": "Starbucks BKC, Mumbai",
  "remarks": "Strategic partnership on enterprise AI consulting."
}
```
- **Response (`201 Created`):**
```json
{
  "success": true,
  "message": "P2P meeting logged successfully.",
  "data": {
    "meeting_id": "bfc1e7d6-effc-48e9-ac62-e494f83390f8",
    "status": "Confirmed"
  }
}
```

---

### 4.4 Tab 2: Teams, Circles & Sub-Industries

#### 14. Get Teams Overview Summary
- **Route:** `GET /api/v1/teams/summary`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "total_circles": 12,
    "avg_health": 88,
    "total_peers": 420,
    "total_revenue": "₹4.8Cr"
  }
}
```

#### 15. Get Circles List
- **Route:** `GET /api/v1/teams/circles`
- **Query Params:** `industry`, `status`, `search`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
      "name": "Mumbai Tech Sunrise",
      "category": "Technology",
      "location": "Mumbai",
      "health_percentage": 94,
      "peers_count": 56,
      "revenue": "₹1.48Cr",
      "chair_name": "Arjun Patel",
      "founders_count": 2,
      "status": "Active"
    }
  ]
}
```

#### 16. Get Circle Details
- **Route:** `GET /api/v1/teams/circles/:id`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
    "name": "Mumbai Tech Sunrise",
    "category": "Technology",
    "location": "Mumbai",
    "launch_date": "Jan 2022",
    "health_percentage": 94,
    "chair": {
      "id": "usr_987214",
      "name": "Arjun Patel",
      "email": "arjun@peersglobal.in",
      "phone": "+919876543209"
    },
    "founders": [
      {
        "id": "usr_110",
        "name": "Sanjana Mehta",
        "email": "sanjana@peersglobal.in"
      }
    ],
    "metrics": {
      "total_peers": 56,
      "attendance_rate": "92%",
      "monthly_revenue": "₹12.4L",
      "annual_revenue": "₹1.48Cr"
    },
    "members": [
      {
        "id": "peer_001",
        "name": "Siddharth Verma",
        "company": "Apex Dynamics Pvt Ltd",
        "status": "Active"
      }
    ]
  }
}
```

#### 17. Get Circle Sub-Industries Breakdown
- **Route:** `GET /api/v1/teams/circles/:id/sub-industries`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
    "active_sub_industries": [
      {
        "id": "19",
        "name": "Web & App Development",
        "peer_count": 4,
        "is_open": false
      },
      {
        "id": "20",
        "name": "AI & Machine Learning",
        "peer_count": 2,
        "is_open": false
      }
    ],
    "open_sub_industries": [
      {
        "id": "22",
        "name": "Cybersecurity & Cloud",
        "peer_count": 0,
        "is_open": true
      },
      {
        "id": "23",
        "name": "FinTech SaaS",
        "peer_count": 0,
        "is_open": true
      }
    ]
  }
}
```

#### 18. Get Circle Events & Assemblies
- **Route:** `GET /api/v1/teams/circles/:id/events`
- **Query Params:** `filter` (`all`, `upcoming`, `completed`)
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "37c1fe0d-4e79-40bb-bbbe-8cfe5e2f92e2",
      "title": "Tech Growth Summit 2026",
      "date": "2026-09-01",
      "time": "10:00 AM",
      "location": "The Grand Ballroom, Mumbai",
      "mode": "In-Person",
      "status": "Upcoming",
      "attendees_count": 48
    },
    {
      "id": "53a9d9d3-f7cf-4c69-9736-d862b4e49d8e",
      "title": "AI & ML Peer Workshop",
      "date": "2026-08-10",
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

### 4.5 Tab 3: Finance & Accounts

#### 19. Get Finance Metrics
- **Route:** `GET /api/v1/finance/metrics`
- **Query Params:** `circle_id` (optional, UUID)
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "total_collections": "₹84.5L",
    "total_dues": "₹12.2L",
    "projected_annual_revenue": "₹1.20Cr",
    "coin_issuances_total": 14500
  }
}
```

#### 20. Get Transactions & Dues Ledger
- **Route:** `GET /api/v1/finance/transactions`
- **Query Params:** `circle_id`, `status` (`Paid`, `Pending`, `Overdue`)
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "txn_8921",
      "peer_name": "Siddharth Verma",
      "circle_name": "Mumbai Tech Sunrise",
      "amount": "₹45,000",
      "type": "Annual Membership Fee",
      "status": "Paid",
      "date": "2026-08-15"
    }
  ]
}
```

#### 21. Update Commission Rates (Super Admin)
- **Route:** `PUT /api/v1/finance/commission-rates`
- **Request Body:**
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
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Commission rates updated successfully."
}
```

#### 22. Record Offline / Manual Fee Payment
- **Route:** `POST /api/v1/finance/transactions/record-offline`
- **Request Body:**
```json
{
  "peer_id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
  "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
  "amount": 45000,
  "payment_mode": "Cheque",
  "reference_number": "CHQ-890211",
  "payment_date": "2026-08-25",
  "type": "Annual Membership Fee"
}
```
- **Response (`201 Created`):**
```json
{
  "success": true,
  "message": "Payment recorded successfully.",
  "data": {
    "transaction_id": "defb736a-b5f9-4769-ba12-a334c5702407",
    "status": "Paid"
  }
}
```

---

### 4.6 Tab 4: Reports & Analytics

#### 23. List Performance Reports
- **Route:** `GET /api/v1/reports`
- **Query Params:** `circle_id`, `type` (`Monthly`, `Weekly`)
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "rep_101",
      "circle_name": "Mumbai Tech Sunrise",
      "report_type": "Monthly",
      "period": "July 2026",
      "submitted_by": "Arjun Patel",
      "submitted_at": "2026-08-01T10:00:00Z",
      "status": "Approved",
      "attendance_percentage": 92,
      "deals_closed_value": "₹14.2L",
      "summary_text": "Strong monthly participation with 4 new peer referrals closed."
    }
  ]
}
```

#### 24. Submit Performance Report
- **Route:** `POST /api/v1/reports`
- **Request Body:**
```json
{
  "circle_id": "d06173c0-368c-4bfd-b682-e07e67fdb320",
  "report_type": "Monthly",
  "period": "August 2026",
  "attendance_percentage": 94.5,
  "deals_closed_value": "₹18.5L",
  "content": "Overall meeting went smoothly with strong attendance across sub-industries.",
  "action_items": "Follow up with 3 pending members for fee renewal."
}
```
- **Response (`201 Created`):**
```json
{
  "success": true,
  "message": "Report submitted successfully!",
  "data": {
    "report_id": "9a01f822-1082-4112-aa01-d82049182390"
  }
}
```

#### 25. Get Attendance Trend
- **Route:** `GET /api/v1/reports/attendance-trend`
- **Query Params:** `circle_id` (optional, UUID)
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {"month": "Feb", "value": 72.0},
    {"month": "Mar", "value": 78.0},
    {"month": "Apr", "value": 74.0},
    {"month": "May", "value": 82.0},
    {"month": "Jun", "value": 87.0},
    {"month": "Jul", "value": 90.0}
  ]
}
```

#### 26. Get Report Dynamic Download URL
- **Route:** `GET /api/v1/reports/:id/download`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "report_id": "9a01f822-1082-4112-aa01-d82049182390",
    "file_name": "Report-Monthly-August-2026.pdf",
    "file_format": "PDF",
    "file_size": "2.4 MB",
    "download_url": "https://peersunity.com/api/v1/files/9a01f822-1082-4112-aa01-d82049182390/download?type=pdf",
    "expires_in_seconds": 3600
  }
}
```

---

### 4.7 Referrals, Testimonials & Coins

#### 27. List Business Referrals
- **Route:** `GET /api/v1/referrals`
- **Query Params:** `circle_id`, `status`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "ref_501",
      "rank": 1,
      "peer_name": "Siddharth Verma",
      "company": "Apex Dynamics Pvt Ltd",
      "referrals_count": 14,
      "value_formatted": "₹18.4L",
      "status": "Active",
      "source": "Direct"
    }
  ]
}
```

#### 28. Submit Business Referral Lead
- **Route:** `POST /api/v1/referrals`
- **Request Body:**
```json
{
  "to_peer_id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
  "prospect_name": "Rajesh Singhania",
  "prospect_company": "Reliance Retail Tech",
  "prospect_phone": "+919822019283",
  "prospect_email": "rajesh@relianceretail.com",
  "estimated_deal_value": "₹15.0L",
  "notes": "Interested in AI automation platform consulting."
}
```
- **Response (`201 Created`):**
```json
{
  "success": true,
  "message": "Referral created and forwarded to peer.",
  "data": {
    "referral_id": "e201b10a-3199-4c12-9843-820194820129",
    "status": "Pending"
  }
}
```

#### 29. List Testimonials
- **Route:** `GET /api/v1/testimonials`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "tst_901",
      "author_name": "Kavitha Rao",
      "author_role": "Industry Director",
      "target_peer_name": "Siddharth Verma",
      "circle_name": "Mumbai Tech Sunrise",
      "content": "Siddharth's team delivered a state-of-the-art solution that increased efficiency by 40%.",
      "date": "2026-08-10"
    }
  ]
}
```

#### 30. Get Coins Leaderboard
- **Route:** `GET /api/v1/peers-by-coins`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "total_platform_coins": 3840,
    "leaderboard": [
      {
        "rank": 1,
        "peer_name": "Siddharth Verma",
        "circle_name": "Mumbai Tech Sunrise",
        "coins": 1240
      }
    ]
  }
}
```

---

### 4.8 Notifications

#### 31. List Notifications
- **Route:** `GET /api/v1/notifications`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": [
    {
      "id": "notif_001",
      "title": "New Peer Registration",
      "body": "Rahul Sharma applied to join Mumbai Tech Sunrise.",
      "type": "membership",
      "is_read": false,
      "time_ago": "10 mins ago",
      "action_url": "/peers/review/usr_489"
    }
  ]
}
```

#### 32. Mark Notifications as Read
- **Route:** `POST /api/v1/notifications/mark-read`
- **Request Body:**
```json
{
  "notification_id": "notif_001",
  "mark_all": false
}
```
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Notifications updated successfully."
}
```

---

### 4.9 Tab 5: Role & Permission Management (Matrix)

#### 33. Get Role Permission Matrix
- **Route:** `GET /api/v1/roles/matrix`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "data": {
    "capabilities": [
      {"id": "access_dashboard", "name": "Access Dashboard", "category": "Navigation & Access"},
      {"id": "access_teams", "name": "Access Teams Tab", "category": "Navigation & Access"},
      {"id": "access_finance", "name": "Access Financial Analytics", "category": "Navigation & Access"},
      {"id": "regional_data", "name": "View Regional Scope Data", "category": "Navigation & Access"},
      {"id": "view_peers", "name": "View Peer Profiles", "category": "Core Operations"},
      {"id": "manage_peers", "name": "Add/Edit Peer Information", "category": "Core Operations"},
      {"id": "request_actions", "name": "Endorse Testimonials & Referrals", "category": "Core Operations"},
      {"id": "view_reports", "name": "View Performance Reports", "category": "Core Operations"},
      {"id": "manage_finance", "name": "Modify Financial Settings", "category": "Financial Control"},
      {"id": "coin_payouts", "name": "Issue Coin Payouts", "category": "Financial Control"},
      {"id": "manage_roles", "name": "Manage App Roles (Matrix)", "category": "Administration"},
      {"id": "system_configs", "name": "System Global Settings", "category": "Administration"}
    ],
    "roles": [
      {
        "id": "circleChair",
        "label": "Circle Chair",
        "is_system_role": true,
        "enabled_capabilities": ["access_dashboard", "view_peers", "request_actions", "view_reports"]
      },
      {
        "id": "superAdmin",
        "label": "Super Admin",
        "is_system_role": true,
        "enabled_capabilities": [
          "access_dashboard", "access_teams", "access_finance", "regional_data",
          "view_peers", "manage_peers", "request_actions", "view_reports",
          "manage_finance", "coin_payouts", "manage_roles", "system_configs"
        ]
      }
    ]
  }
}
```

#### 34. Update Role Capability Assignments
- **Route:** `PUT /api/v1/roles/matrix`
- **Request Body:**
```json
{
  "role_id": "circleChair",
  "enabled_capabilities": [
    "access_dashboard",
    "view_peers",
    "request_actions",
    "view_reports"
  ]
}
```
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Role capabilities updated successfully."
}
```

#### 35. Create Custom Role
- **Route:** `POST /api/v1/roles`
- **Request Body:**
```json
{
  "label": "Regional Coordinator",
  "enabled_capabilities": [
    "access_dashboard",
    "view_peers",
    "regional_data"
  ]
}
```
- **Response (`201 Created`):**
```json
{
  "success": true,
  "message": "Custom role created successfully.",
  "data": {
    "id": "019488b0-a3df-7b56-8a9d-b4f0e9876543",
    "role_key": "regional_coordinator",
    "label": "Regional Coordinator",
    "is_system_role": false,
    "enabled_capabilities": [
      "access_dashboard",
      "view_peers",
      "regional_data"
    ]
  }
}
```

#### 36. Update Custom Role
- **Route:** `PUT /api/v1/roles/:id`
- **Request Body:**
```json
{
  "label": "Senior Regional Coordinator",
  "enabled_capabilities": [
    "access_dashboard",
    "view_peers",
    "regional_data",
    "access_teams"
  ]
}
```
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Role updated successfully."
}
```

#### 37. Delete Custom Role
- **Route:** `DELETE /api/v1/roles/:id`
- **Response (`200 OK`):**
```json
{
  "success": true,
  "message": "Custom role deleted successfully."
}
```

---

## 5. Manual PostgreSQL Database Queries (DDL & Indexes)

Run these queries in PostgreSQL (`devunity` / production database) to ensure all tables, enums, and indexes are in place:

```sql
-- 1. Leader Commission Rates Table
CREATE TABLE IF NOT EXISTS leader_commission_rates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id VARCHAR(100) NOT NULL,
    direct_referral_cut_percentage NUMERIC(5, 2) DEFAULT 0.00,
    app_join_cut_percentage NUMERIC(5, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_leader_comm_role UNIQUE (role_id)
);

-- 2. Leader Role Capabilities Table
CREATE TABLE IF NOT EXISTS leader_role_capabilities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id VARCHAR(100) NOT NULL,
    capability_key VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_role_capability UNIQUE (role_id, capability_key)
);

-- 3. Leader Reports Table
CREATE TABLE IF NOT EXISTS leader_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    circle_id UUID NOT NULL,
    submitted_by_user_id UUID NOT NULL,
    report_type VARCHAR(50) NOT NULL DEFAULT 'Monthly',
    period VARCHAR(50) NOT NULL,
    attendance_percentage NUMERIC(5, 2) DEFAULT 0.00,
    deals_closed_value VARCHAR(100) NULL,
    content TEXT NULL,
    summary_text TEXT NULL,
    action_items TEXT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'Under Review',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE NULL
);

-- 4. Leader Wishes Table
CREATE TABLE IF NOT EXISTS leader_wishes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_user_id UUID NOT NULL,
    receiver_user_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Add PostgreSQL Indexes for High-Performance Mobile Lookups
CREATE INDEX IF NOT EXISTS idx_users_phone ON users (phone);
CREATE INDEX IF NOT EXISTS idx_users_secondary_mobile ON users (secondary_mobile);
CREATE INDEX IF NOT EXISTS idx_leader_reports_circle ON leader_reports (circle_id);
CREATE INDEX IF NOT EXISTS idx_p2p_meetings_initiator ON p2p_meetings (initiator_user_id);
CREATE INDEX IF NOT EXISTS idx_p2p_meetings_peer ON p2p_meetings (peer_user_id);
CREATE INDEX IF NOT EXISTS idx_referrals_from_user ON referrals (from_user_id);
CREATE INDEX IF NOT EXISTS idx_referrals_to_user ON referrals (to_user_id);

-- 6. Circle Member Status Enum Extensions (Optional)
ALTER TYPE circle_member_status_enum ADD VALUE IF NOT EXISTS 'needs_attention';
ALTER TYPE circle_member_status_enum ADD VALUE IF NOT EXISTS 'under_review';
```
