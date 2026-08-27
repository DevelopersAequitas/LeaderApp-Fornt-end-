# 🏛️ Leader App – Circle Details & Leadership Architecture API Contract
**Target Audience**: Backend Engineering Team (Laravel / PostgreSQL API)  
**Date**: August 26, 2026  
**Base URL**: `https://dev.peersunity.com/api/v1`  
**Authentication**: All endpoints require `Authorization: Bearer <AUTH_TOKEN>`

---

## 📌 Executive Summary of Backend Bugs & Requirements

During testing with newly created circles (e.g. `KAA Ahmedabad`, ID `5a8f5823-90c8-4e21-9221-21769972128c`), the following backend discrepancies were identified:

1. **New Circle Mock Values in Directory (`GET /api/v1/teams/circles`)**:
   - Newly created circles with 0 members are currently returned with static mock data: `health_percentage: 94`, `peers_count: 3`, `revenue: "₹1.48Cr"`, and `chair_name: "Arjun Patel"`.
   - **Fix**: For new circles, the API must calculate and return real live values: `peers_count: 0`, `revenue: "₹0.0"`, `health_percentage: 0`, and `chairs: []` (or `chair_name: null`).

2. **Circle Peers Filter Bleed (`GET /api/v1/peers?circle_id=:id` vs `GET /api/v1/teams/circles/:id/peers`)**:
   - When querying peers for circle `5a8f5823-...`, the backend returned members from `Mumbai Tech Sunrise` (`d06173c0-...`).
   - **Fix**: Implement dedicated `GET /api/v1/teams/circles/:circle_id/peers` that strictly joins on `circle_members.circle_id = :circle_id`. If no members exist, return an empty array `[]`.

3. **Multi-Chair Leadership Architecture (Up to 3 Chairs)**:
   - Circles support up to **3 Chairs**, along with **Founders** and **Circle Directors / Co-Directors**.
   - **Fix**: Provide structured `chairs: [...]` or `leadership: { chairs: [...], founders: [...], directors: [...] }` arrays containing leader IDs and contact details so mobile users can tap directly into their profiles.

4. **Circle-Scoped Events (`GET /api/v1/teams/circles/:id/events`)**:
   - Currently returns all global events across the entire organization.
   - **Fix**: Filter events strictly where `events.circle_id = :id`.

---

## 1. Circle Directory API

### `GET /api/v1/teams/circles`
Returns the directory of circles accessible to the authenticated leader.

#### Query Parameters:
| Param | Type | Required | Description |
|---|---|---|---|
| `search` | `string` | Optional | Search query matching circle name or location. |
| `industry` | `string` | Optional | Filter by parent industry name. |
| `status` | `string` | Optional | `Active` or `Inactive`. |

#### Response (`200 OK`):
```json
{
  "success": true,
  "data": [
    {
      "id": "5a8f5823-90c8-4e21-9221-21769972128c",
      "name": "KAA Ahmedabad",
      "category": "Technology & Innovation",
      "location": "Ahmedabad",
      "health_percentage": 0,
      "peers_count": 0,
      "revenue": "₹0.0",
      "status": "Active",
      "launch_date": "2026-08-26",
      "tags": ["Technology", "Ahmedabad", "B2B SaaS"],
      "chairs": [
        {
          "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
          "name": "Siddharth Verma",
          "role": "Circle Chair",
          "avatar_url": "https://dev.peersunity.com/api/v1/files/avatar_siddharth.png",
          "company": "Apex Dynamics Pvt Ltd",
          "designation": "Founder & CEO",
          "phone": "+919876543210",
          "email": "siddharth@apexdynamics.in"
        }
      ],
      "founders": [
        {
          "id": "da41b188-3389-4bac-8da0-f0deec1c4697",
          "name": "Chirag Mali",
          "role": "Circle Founder",
          "avatar_url": "https://dev.peersunity.com/api/v1/files/01a01432-d591-70a6-bea4-2379150814ae",
          "company": "Aequitas Tech",
          "phone": "+919537639248",
          "email": "malichirag1369@gmail.com"
        }
      ],
      "directors": [
        {
          "id": "31888f0c-8812-41d6-aa17-75c448f6b663",
          "name": "Harsh Chauhan",
          "role": "Circle Director",
          "avatar_url": "https://dev.peersunity.com/api/v1/files/avatar_harsh.png",
          "company": "Aequitas IT",
          "phone": "+919876500000",
          "email": "harsh@aequitas.com"
        }
      ]
    }
  ]
}
```

---

## 2. Dedicated Single Circle Details & Leadership

### `GET /api/v1/teams/circles/:circle_id`
Returns rich metadata, metrics, and complete leadership team (up to 3 Chairs).

#### Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "id": "5a8f5823-90c8-4e21-9221-21769972128c",
    "name": "KAA Ahmedabad",
    "category": "Technology & Innovation",
    "location": "Ahmedabad",
    "health_percentage": 92,
    "peers_count": 24,
    "revenue": "₹28.5L",
    "status": "Active",
    "launch_date": "2026-01-15",
    "tags": ["Technology", "Cloud Infra", "FinTech"],
    "chairs": [
      {
        "id": "76265b49-4e41-406e-bb8c-7182d5f6536c",
        "name": "Siddharth Verma",
        "role": "Circle Chair 1",
        "avatar_url": "https://dev.peersunity.com/api/v1/files/avatar_siddharth.png",
        "company": "Apex Dynamics Pvt Ltd",
        "designation": "Founder & CEO",
        "phone": "+919876543210",
        "email": "siddharth@apexdynamics.in"
      },
      {
        "id": "a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d",
        "name": "Pooja Sharma",
        "role": "Circle Chair 2",
        "avatar_url": "https://dev.peersunity.com/api/v1/files/avatar_pooja.png",
        "company": "BioHealth Labs",
        "designation": "Managing Director",
        "phone": "+919876543211",
        "email": "pooja@biohealth.in"
      },
      {
        "id": "e9c8b7a6-5d4c-3b2a-1f0e-9d8c7b6a5e4d",
        "name": "Vikram Malhotra",
        "role": "Circle Chair 3",
        "avatar_url": "https://dev.peersunity.com/api/v1/files/avatar_vikram.png",
        "company": "Malhotra Logistics",
        "designation": "Director",
        "phone": "+919876543212",
        "email": "vikram@malhotra.in"
      }
    ],
    "founders": [
      {
        "id": "da41b188-3389-4bac-8da0-f0deec1c4697",
        "name": "Chirag Mali",
        "role": "Circle Founder",
        "avatar_url": "https://dev.peersunity.com/api/v1/files/01a01432-d591-70a6-bea4-2379150814ae",
        "company": "Aequitas Tech",
        "phone": "+919537639248",
        "email": "malichirag1369@gmail.com"
      }
    ],
    "directors": [
      {
        "id": "31888f0c-8812-41d6-aa17-75c448f6b663",
        "name": "Harsh Chauhan",
        "role": "Circle Director",
        "avatar_url": "https://dev.peersunity.com/api/v1/files/avatar_harsh.png",
        "company": "Aequitas IT",
        "phone": "+919876500000",
        "email": "harsh@aequitas.com"
      }
    ]
  }
}
```

---

## 3. Dedicated Circle Peers List

### `GET /api/v1/teams/circles/:circle_id/peers`
Returns all peers specifically registered and enrolled in `:circle_id`.

#### Query Parameters:
| Param | Type | Required | Description |
|---|---|---|---|
| `status` | `string` | Optional | `Active`, `Pending`, `Inactive` (default: all). |
| `search` | `string` | Optional | Filter by member name or company. |
| `page` | `int` | Optional | Pagination page number. |
| `per_page` | `int` | Optional | Default `20`. |

#### Response (`200 OK` when members exist):
```json
{
  "success": true,
  "message": "Circle peers retrieved successfully.",
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 20,
    "total": 1
  },
  "data": [
    {
      "id": "75aa3aeb-15d6-48bb-96cd-996696b667d0",
      "name": "Chirag Mali",
      "avatar_url": "https://dev.peersunity.com/api/v1/files/01a01432-d591-70a6-bea4-2379150814ae",
      "company": "Aequitas Infotech",
      "circle": "KAA Ahmedabad",
      "circle_id": "5a8f5823-90c8-4e21-9221-21769972128c",
      "location": "Ahmedabad",
      "designation": "Founder & CEO",
      "industry": "Technology",
      "level4_category": "Custom Software Development",
      "tags": "Technology · B2B SaaS",
      "status": "Active",
      "impact_count": 129,
      "deals_formatted": "₹32.5L",
      "coins": 4186000,
      "attendance": "94%",
      "phone": "+919537639248",
      "email": "malichirag1369@gmail.com",
      "is_verified": true,
      "intro_video_url": "https://dev.peersunity.com/api/v1/files/019fb178-6902-710b-a116-29cafad409d2"
    }
  ]
}
```

#### Response (`200 OK` for newly created circle with 0 members):
```json
{
  "success": true,
  "message": "No peers found for this circle.",
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 20,
    "total": 0
  },
  "data": []
}
```

---

## 4. Circle-Scoped Events API

### `GET /api/v1/teams/circles/:circle_id/events`
Returns assemblies and meetings scheduled specifically for `:circle_id`.

#### Query Parameters:
| Param | Type | Required | Description |
|---|---|---|---|
| `filter` | `string` | Optional | `all`, `upcoming`, `completed`. |

#### Response (`200 OK`):
```json
{
  "success": true,
  "data": [
    {
      "id": "b5bf4b70-d3fe-478d-bd6c-4d7300510fbe",
      "circle_id": "5a8f5823-90c8-4e21-9221-21769972128c",
      "title": "KAA Chapter Launch Assembly",
      "date": "2026-09-02",
      "time": "08:00 AM",
      "location": "Grand Ballroom, Hyatt Regency, Ahmedabad",
      "mode": "In-Person",
      "status": "Upcoming",
      "attendees_count": 25
    }
  ]
}
```

---

## 5. Circle Sub-Industries Breakdown

### `GET /api/v1/teams/circles/:circle_id/sub-industries`
Returns active (occupied) and open (available) business slots for `:circle_id`.

#### Response (`200 OK`):
```json
{
  "success": true,
  "data": {
    "circle_id": "5a8f5823-90c8-4e21-9221-21769972128c",
    "active_sub_industries": [
      {
        "id": 19,
        "name": "Custom Software & Web Platforms",
        "peer_count": 1,
        "is_open": false
      }
    ],
    "open_sub_industries": [
      {
        "id": 20,
        "name": "Cybersecurity & Infrastructure",
        "peer_count": 0,
        "is_open": true
      },
      {
        "id": 21,
        "name": "AI & Machine Learning Solutions",
        "peer_count": 0,
        "is_open": true
      }
    ]
  }
}
```

---

## 6. Implementation Checklist for Backend Team

- [ ] **1. Remove hardcoded mocks in `GET /api/v1/teams/circles`**: Return 0 peers, ₹0.0 revenue, 0 health for new circles.
- [ ] **2. Provide `chairs: [...]` array**: Allow up to 3 Chairs per circle with `id`, `name`, `avatar_url`, `phone`, `email`, `designation`.
- [ ] **3. Implement `GET /api/v1/teams/circles/:circle_id/peers`**: Query `circle_members` strictly by `:circle_id` without returning unrelated circle members.
- [ ] **4. Filter `GET /api/v1/teams/circles/:circle_id/events`**: Filter `events.circle_id = :circle_id`.
- [ ] **5. Zero-safe response**: Return empty lists `[]` when a circle has 0 members or 0 events instead of falling back to default records.
