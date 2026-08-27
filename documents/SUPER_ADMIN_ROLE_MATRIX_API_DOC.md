# 🛡️ Super Admin Dynamic Role Matrix & RBAC Backend Specification

This document provides the exact contract for backend engineers to implement and sync dynamic permissions configured by the **Super Admin** through the **Role Matrix**.

---

## 1. Overview of the Dynamic RBAC System

When Super Admin modifies a role's capabilities via the Leader App (e.g., enabling or disabling tabs for `districtExecDirector`, `circleFounder`, `circleChair`, etc.), those settings are saved to the backend database via:
`PUT /api/v1/roles/matrix`

When any user logs in (`POST /api/v1/auth/verify-otp`) or fetches their profile (`GET /api/v1/profile`), the backend **MUST return their active role's dynamic capabilities** from the database instead of static hardcoded permissions.

---

## 2. Capability IDs Dictionary (12 Core Capabilities)

| Capability ID | Category | Description | Frontend Effect |
|---|---|---|---|
| `access_dashboard` | Navigation & Access | Allows access to the primary metrics and dashboard. | Controls Dashboard Tab |
| `access_teams` | Navigation & Access | Allows viewing circles, directors, and chairs directories. | Controls Circles & Teams Tab |
| `access_finance` | Navigation & Access | Allows viewing fee collections, dues, and transaction histories. | Controls Finance Tab & Revenue Metrics |
| `regional_data` | Navigation & Access | Access and filter data beyond own local circle (District/Country level). | Enables District/Country Filter Scopes |
| `view_peers` | Core Operations | Allows viewing and browsing peer profile details and attendance stats. | Controls Peers Tab & Peer Directory |
| `manage_peers` | Core Operations | Allows coordinators to add new peers or edit biographical fields. | Enables Add Peer button & Profile Edits |
| `request_actions` | Core Operations | Allows sending wishes, introductions, and review peer approvals. | Enables Wishes & Approval Action Bar |
| `view_reports` | Compliance & Growth | Allows viewing, submitting, and tracking weekly circle reports. | Controls Reports Tab & Submission Forms |
| `manage_finance` | Finance Control | Allows setting fee structures, tracking dues, and refunding. | Enables Fee Settings & Dues Adjustments |
| `coin_payouts` | Finance Control | Allows executing coin reward payouts to leaders and founders. | Enables Coin Payout & Grant Actions |
| `manage_roles` | Administration | Grants access to the Super Admin Role Matrix and privileges. | Enables Role Settings Menu in Profile |
| `system_configs` | Administration | Manage system-wide categories, tags, and launch configurations. | Enables Circle Creation & Assignment Tools |

---

## 3. Endpoints Specification

### 3.1 Fetch Role Matrix
- **Endpoint**: `GET /api/v1/roles/matrix`
- **Headers**: `Authorization: Bearer <super_admin_token>`
- **Response**: `200 OK`
```json
{
  "success": true,
  "data": {
    "capabilities": [
      {
        "id": "access_dashboard",
        "name": "Access Dashboard",
        "category": "Navigation & Access",
        "description": "Allows access to the primary metrics and impacter list dashboard."
      },
      {
        "id": "access_teams",
        "name": "Access Circles & Teams",
        "category": "Navigation & Access",
        "description": "Allows viewing circles, directors, and chairs directories."
      },
      {
        "id": "access_finance",
        "name": "Access Financial Analytics",
        "category": "Navigation & Access",
        "description": "Allows viewing fee collections, dues, and transaction histories."
      },
      {
        "id": "regional_data",
        "name": "View Regional Scope Data",
        "category": "Navigation & Access",
        "description": "Access and filter data beyond own local circle (District/Country level)."
      },
      {
        "id": "view_peers",
        "name": "View Peer Profiles",
        "category": "Core Operations",
        "description": "Allows viewing and browsing peer profile details and attendance stats."
      },
      {
        "id": "manage_peers",
        "name": "Add/Edit Peer Information",
        "category": "Core Operations",
        "description": "Allows coordinators to add new peers or edit biographical fields."
      },
      {
        "id": "request_actions",
        "name": "Request Introductions & Actions",
        "category": "Core Operations",
        "description": "Allows sending wishes, introductions, and review peer approvals."
      },
      {
        "id": "view_reports",
        "name": "View & Submit Weekly Reports",
        "category": "Compliance & Growth",
        "description": "Allows viewing, submitting, and tracking weekly circle reports."
      },
      {
        "id": "manage_finance",
        "name": "Manage Financial Settings",
        "category": "Finance Control",
        "description": "Allows setting fee structures, tracking dues, and refunding."
      },
      {
        "id": "coin_payouts",
        "name": "Process Coin Payouts",
        "category": "Finance Control",
        "description": "Allows executing coin reward payouts to leaders and founders."
      },
      {
        "id": "manage_roles",
        "name": "Manage Roles & Matrix",
        "category": "Administration",
        "description": "Grants access to the Super Admin Role Matrix and privileges."
      },
      {
        "id": "system_configs",
        "name": "Configure System Parameters",
        "category": "Administration",
        "description": "Manage system-wide categories, tags, and launch configurations."
      }
    ],
    "roles": [
      {
        "role": {
          "id": "circleChair",
          "label": "Circle Chair",
          "is_system_role": true
        },
        "enabled_capabilities": [
          "access_dashboard",
          "view_peers",
          "request_actions",
          "view_reports"
        ]
      },
      {
        "role": {
          "id": "districtExecDirector",
          "label": "District Executive Director",
          "is_system_role": true
        },
        "enabled_capabilities": [
          "access_dashboard",
          "access_finance",
          "regional_data",
          "view_peers",
          "manage_peers",
          "request_actions",
          "view_reports",
          "manage_finance"
        ]
      }
    ]
  }
}
```

---

### 3.2 Update Role Matrix Capabilities
- **Endpoint**: `PUT /api/v1/roles/matrix`
- **Headers**: `Authorization: Bearer <super_admin_token>`
- **Request Payload**:
```json
{
  "role_id": "districtExecDirector",
  "enabled_capabilities": [
    "access_dashboard",
    "access_finance",
    "regional_data",
    "view_peers",
    "manage_peers",
    "request_actions",
    "view_reports",
    "manage_finance"
  ]
}
```
- **Response**: `200 OK`
```json
{
  "success": true,
  "message": "Role capabilities updated successfully."
}
```

---

### 3.3 Auth Verification Response (`POST /api/v1/auth/verify-otp`)
When a user logs in with their OTP, the backend MUST query the **saved role capabilities** for that user's role and return them inside the `permissions` object:

```json
{
  "success": true,
  "data": {
    "auth_token": "1421|...",
    "refresh_token": "...",
    "user": {
      "id": "user_uuid",
      "name": "Leader Name",
      "email": "leader@example.com",
      "phone": "+919876543210",
      "role": "districtExecDirector",
      "regional_scope": "District Scope",
      "managed_circles": ["Mumbai Sunrise", "Ahmedabad Tech"],
      "member_since": "Aug 2026",
      "capabilities_count": 8,
      "avatar_url": "https://dev.peersunity.com/storage/avatars/leader.png"
    },
    "permissions": {
      "enabled_capabilities": [
        "access_dashboard",
        "access_finance",
        "regional_data",
        "view_peers",
        "manage_peers",
        "request_actions",
        "view_reports",
        "manage_finance"
      ]
    }
  }
}
```

> **Note**: If the backend returns `enabled_capabilities` as an array of capability strings, the Flutter App will automatically translate and enforce navigation tabs and action buttons in real time!
