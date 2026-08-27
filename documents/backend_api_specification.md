# 📘 Peers Global Leader App - Backend API Specification

> **Target Backend Team & System Architects**  
> **Base URL (Dev):** `https://dev.peersunity.com/api/v1`  
> **Auth Scheme:** `Authorization: Bearer <JWT_AUTH_TOKEN>`  
> **Format:** Standard JSON (`Content-Type: application/json`, `Accept: application/json`)

---

## 📌 Standard API Response Structure

All API responses from the server must follow the standardized wrapper format:

### Success Response (HTTP 200 / 201)
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { ... }
}
```

### Error Response (HTTP 400 / 401 / 403 / 404 / 422 / 500)
```json
{
  "success": false,
  "message": "Human-readable error explanation",
  "error_code": "RESOURCE_NOT_FOUND",
  "details": {}
}
```

---

## 🚀 1. System Configuration & App Lifecycle (Force/Optional Update & Maintenance)

### `GET /api/v1/system/app-config`
Returns current minimum required version, latest available version, and maintenance mode controls.

#### Request Headers:
```http
GET /api/v1/system/app-config HTTP/1.1
Host: dev.peersunity.com
Authorization: Bearer <TOKEN> (Optional for pre-auth app launch)
```

#### Response (HTTP 200):
```json
{
  "success": true,
  "data": {
    "min_required_version": "1.0.0",
    "latest_version": "1.2.0",
    "is_maintenance_mode": false,
    "maintenance_title": "System Under Maintenance",
    "maintenance_message": "We are currently performing essential infrastructure upgrades. Please check back shortly.",
    "force_update_title": "App Update Required",
    "force_update_message": "A critical new version of Leader App is required to access your circle data. Please update from the store.",
    "optional_update_title": "New Update Available",
    "optional_update_message": "Version 1.2.0 includes enhanced analytics, new role circulars, and performance improvements.",
    "store_url_android": "https://play.google.com/store/apps/details?id=com.unity.leadersapp",
    "store_url_ios": "https://apps.apple.com/app/leader-app/id123456789",
    "allowed_bypass_roles": ["superAdmin", "super_admin"]
  }
}
```

#### Description:
- **Force Update Trigger:** If client app version < `min_required_version`, client displays a non-dismissible blocking update dialog.
- **Optional Update Trigger:** If `min_required_version` <= client app version < `latest_version`, client displays an update prompt with a "Later" option.
- **Maintenance Mode:** If `is_maintenance_mode == true`, all users except roles listed in `allowed_bypass_roles` are blocked from app usage.

---

## 📢 2. Role-Targeted Circulars & Announcements

### `GET /api/v1/circulars`
Fetches administrative circulars filtered for the authenticated user's role.

#### Request Headers:
```http
GET /api/v1/circulars HTTP/1.1
Host: dev.peersunity.com
Authorization: Bearer <TOKEN>
```

#### Response (HTTP 200):
```json
{
  "success": true,
  "data": [
    {
      "id": "circ_001",
      "title": "Q3 Circle Performance Audits & Submission Timelines",
      "content": "All Circle Chairs and Founders are required to finalize pending peer referrals and submit weekly activity reports before the 28th of this month.",
      "target_roles": ["circleChair", "circleFounder", "circleDirector"],
      "priority": "Urgent",
      "published_at": "2 hours ago",
      "author_name": "National Directorate",
      "author_role": "Super Admin",
      "attachment_url": "https://dev.peersunity.com/storage/docs/circular_q3.pdf",
      "is_read": false
    },
    {
      "id": "circ_002",
      "title": "New Annual Fee Collection & Ledger Reconciliation Guidelines",
      "content": "District Executive Directors and Country Directors can now configure customized annual fee schedules directly from the Financial Analytics module.",
      "target_roles": ["districtExecDirector", "countryDirector", "superAdmin"],
      "priority": "Important",
      "published_at": "Yesterday",
      "author_name": "Finance Audit Committee",
      "author_role": "Director",
      "attachment_url": null,
      "is_read": true
    },
    {
      "id": "circ_003",
      "title": "Platform Version 1.2.0 Launch & Enhanced Matrix Security",
      "content": "The new role capabilities matrix is now active across all global regions with real-time capability sync.",
      "target_roles": ["all"],
      "priority": "General",
      "published_at": "2 days ago",
      "author_name": "Central Admin Team",
      "author_role": "Super Admin",
      "attachment_url": null,
      "is_read": true
    }
  ]
}
```

---

### `POST /api/v1/circulars/publish`
Allows Super Admin or Directors to broadcast a new role-targeted circular.

#### Request Body:
```json
{
  "title": "Special General Assembly Announcement",
  "content": "A special assembly meeting is scheduled for next Monday at 7:00 PM for all Circle Chairs.",
  "target_roles": ["circleChair", "chairBusinessGrowth", "chairMembership", "chairEvents"],
  "priority": "Urgent",
  "attachment_url": null
}
```

#### Response (HTTP 201):
```json
{
  "success": true,
  "message": "Circular published successfully",
  "data": {
    "id": "circ_004",
    "title": "Special General Assembly Announcement",
    "content": "A special assembly meeting is scheduled for next Monday at 7:00 PM for all Circle Chairs.",
    "target_roles": ["circleChair", "chairBusinessGrowth", "chairMembership", "chairEvents"],
    "priority": "Urgent",
    "published_at": "Just now",
    "author_name": "National Directorate",
    "author_role": "Super Admin"
  }
}
```

---

## 👥 3. Peer Profile Privacy & Role-Based Editing

### `GET /api/v1/peers/:id`
Retrieves detailed information for a peer including privacy visibility settings.

#### Response (HTTP 200):
```json
{
  "success": true,
  "data": {
    "id": "peer_101",
    "name": "Rahul Verma",
    "avatar_url": "https://dev.peersunity.com/storage/avatars/rahul.jpg",
    "company": "Apex Solar Systems",
    "designation": "Founder & MD",
    "circle": "Solar & Green Energy Circle",
    "circle_id": "circle_05",
    "location": "Ahmedabad, Gujarat",
    "industry": "Renewable Energy",
    "level4_category": "Rooftop Solar EPC",
    "phone": "+91 98765 43210",
    "email": "rahul@apexsolar.in",
    "hide_phone": true,
    "hide_email": false,
    "status": "Active",
    "is_verified": true,
    "impact_count": 42,
    "deals_formatted": "₹1.4 Cr",
    "coins": 850,
    "attendance": "96%",
    "joined_date": "Jan 2025",
    "intro_video_url": "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"
  }
}
```

#### Privacy Rules:
- If `hide_phone == true`: Backend should either mask the phone (e.g. `"********"`) or omit it for non-admin requests, while returning the actual value when the requesting user is a **Super Admin** or has `canAddEditPeer` privilege.
- If `hide_email == true`: Backend should mask or omit email for non-admin viewers.

---

### `PUT /api/v1/peers/:id`
Updates peer biographical information, contact privacy flags, and media links. Accessible by **Super Admin** or leaders with `manage_peers` / `canAddEditPeer` capability.

#### Request Body:
```json
{
  "name": "Rahul Verma",
  "company": "Apex Solar Systems Private Limited",
  "designation": "Managing Director",
  "phone": "+91 98765 43210",
  "email": "rahul@apexsolar.in",
  "hide_phone": true,
  "hide_email": false,
  "status": "Active",
  "intro_video_url": "https://youtu.be/example_intro"
}
```

#### Response (HTTP 200):
```json
{
  "success": true,
  "message": "Peer profile updated successfully",
  "data": {
    "id": "peer_101",
    "name": "Rahul Verma",
    "company": "Apex Solar Systems Private Limited",
    "designation": "Managing Director",
    "phone": "+91 98765 43210",
    "email": "rahul@apexsolar.in",
    "hide_phone": true,
    "hide_email": false,
    "status": "Active",
    "intro_video_url": "https://youtu.be/example_intro"
  }
}
```

---

## 🔐 4. Dynamic Role Capabilities Matrix

### `GET /api/v1/roles/matrix`
Returns all capability definitions and mapped role privileges.

#### Response (HTTP 200):
```json
{
  "success": true,
  "data": {
    "capabilities": [
      { "id": "access_dashboard", "name": "Access Dashboard", "category": "Navigation & Access", "description": "Allows access to the primary metrics and impacter list dashboard." },
      { "id": "access_teams", "name": "Access Circles & Teams", "category": "Navigation & Access", "description": "Allows viewing circles, directors, and chairs directories." },
      { "id": "access_finance", "name": "Access Financial Analytics", "category": "Navigation & Access", "description": "Allows viewing fee collections, dues, and transaction histories." },
      { "id": "regional_data", "name": "View Regional Scope Data", "category": "Navigation & Access", "description": "Access and filter data beyond own local circle (District/Country level)." },
      { "id": "view_peers", "name": "View Peer Profiles", "category": "Core Operations", "description": "Allows viewing and browsing peer profile details and attendance stats." },
      { "id": "manage_peers", "name": "Add/Edit Peer Information", "category": "Core Operations", "description": "Allows coordinators to add new peers or edit biographical fields." },
      { "id": "request_actions", "name": "Request Introductions & Actions", "category": "Core Operations", "description": "Allows sending wishes, introductions, and review peer approvals." },
      { "id": "view_reports", "name": "View & Submit Weekly Reports", "category": "Compliance & Growth", "description": "Allows viewing, submitting, and tracking weekly circle reports." },
      { "id": "manage_finance", "name": "Manage Financial Settings", "category": "Finance Control", "description": "Allows setting fee structures, tracking dues, and refunding." },
      { "id": "coin_payouts", "name": "Process Coin Payouts", "category": "Finance Control", "description": "Allows executing coin reward payouts to leaders and founders." },
      { "id": "manage_roles", "name": "Manage Roles & Matrix", "category": "Administration", "description": "Grants access to the Super Admin Role Matrix and privileges." },
      { "id": "system_configs", "name": "Configure System Parameters", "category": "Administration", "description": "Manage system-wide categories, tags, and launch configurations." }
    ],
    "roles": [
      {
        "id": "circleFounder",
        "label": "Circle Founder",
        "is_system_role": true,
        "enabled_capabilities": [
          "access_dashboard", "access_teams", "access_finance", "view_peers", "manage_peers", "request_actions", "view_reports"
        ]
      },
      {
        "id": "circleDirector",
        "label": "Circle Director",
        "is_system_role": true,
        "enabled_capabilities": [
          "access_dashboard", "access_teams", "access_finance", "view_peers", "manage_peers", "request_actions", "view_reports"
        ]
      },
      {
        "id": "industryDirector",
        "label": "Industry Director",
        "is_system_role": true,
        "enabled_capabilities": [
          "access_dashboard", "access_teams", "access_finance", "regional_data", "view_peers", "request_actions", "view_reports"
        ]
      },
      {
        "id": "districtExecDirector",
        "label": "District Exec Director",
        "is_system_role": true,
        "enabled_capabilities": [
          "access_dashboard", "access_finance", "regional_data", "view_peers", "manage_peers", "request_actions", "view_reports", "manage_finance", "access_teams"
        ]
      },
      {
        "id": "countryDirector",
        "label": "Country Director",
        "is_system_role": true,
        "enabled_capabilities": [
          "access_dashboard", "access_teams", "access_finance", "regional_data", "view_peers", "manage_peers", "request_actions", "view_reports", "manage_finance", "coin_payouts"
        ]
      },
      {
        "id": "superAdmin",
        "label": "Super Admin",
        "is_system_role": true,
        "enabled_capabilities": [
          "access_dashboard", "access_teams", "access_finance", "regional_data", "view_peers", "manage_peers", "request_actions", "view_reports", "manage_finance", "coin_payouts", "manage_roles", "system_configs"
        ]
      },
      {
        "id": "32120618-0942-43ca-a95c-6abdc98f039a",
        "role_key": "business_growth_committee",
        "label": "Chair - Business Growth Committee",
        "is_system_role": false,
        "enabled_capabilities": [
          "access_dashboard", "view_peers", "request_actions", "view_reports"
        ]
      },
      {
        "id": "1454e712-0453-4659-95c2-3c820fc0725f",
        "role_key": "membership_growth_committee",
        "label": "Chair - Membership Committee",
        "is_system_role": false,
        "enabled_capabilities": [
          "access_dashboard", "view_peers", "request_actions", "view_reports"
        ]
      },
      {
        "id": "385752e6-358c-46e5-8f51-281734553d93",
        "role_key": "events_impacts_committee",
        "label": "Chair - Events & Programs Committee",
        "is_system_role": false,
        "enabled_capabilities": [
          "access_dashboard", "view_peers", "request_actions", "view_reports"
        ]
      },
      {
        "id": "9d2aeeef-e8b5-4416-8b44-4ed50967fbe2",
        "role_key": "regional_coordinator",
        "label": "Regional Coordinator",
        "is_system_role": false,
        "enabled_capabilities": [
          "access_dashboard", "view_peers", "regional_data"
        ]
      }
    ]
  }
}
```

---

### `PUT /api/v1/roles/matrix`
Updates capability assignments for a role.

#### Request Body:
```json
{
  "role_id": "32120618-0942-43ca-a95c-6abdc98f039a",
  "enabled_capabilities": [
    "access_dashboard",
    "access_teams",
    "view_peers",
    "request_actions",
    "view_reports"
  ]
}
```

#### Response (HTTP 200):
```json
{
  "success": true,
  "message": "Role capabilities updated successfully"
}
```

---

### `POST /api/v1/roles`
Creates a dynamic custom role.

#### Request Body:
```json
{
  "label": "Zonal Coordinator",
  "enabled_capabilities": [
    "access_dashboard",
    "view_peers",
    "regional_data"
  ]
}
```

#### Response (HTTP 201):
```json
{
  "success": true,
  "data": {
    "id": "6fa8d521-3642-4e89-9fa1-45601289de32",
    "role_key": "zonal_coordinator",
    "label": "Zonal Coordinator",
    "is_system_role": false,
    "enabled_capabilities": [
      "access_dashboard",
      "view_peers",
      "regional_data"
    ]
  }
}
```
