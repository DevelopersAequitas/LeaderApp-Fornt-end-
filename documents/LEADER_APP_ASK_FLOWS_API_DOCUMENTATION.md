# 📱 Leader App — Ask Discovery & Flows Master API Documentation

> **Document Version:** 1.0.0  
> **Target Audience:** Flutter Frontend Team, Mobile Developers, Backend Integrators, QA  
> **Target Flows:**  
> - 🤝 **1. Find a Collaborator (`collaboration`)**  
> - 📢 **2. Help me make the right connection (`referral`)**  
> - 🆘 **3. Guidance & Support (`help`)**  
> **Base URLs:**  
> - **Local Development:** `http://localhost:8000/api/v1` (or `http://192.168.x.x:8000/api/v1`)  
> - **Dev Staging:** `https://dev.peersunity.com/api/v1`  
> - **Production:** `https://peersunity.com/api/v1`  
> **Headers Required:**  
> ```http
> Authorization: Bearer <AUTH_TOKEN>
> Accept: application/json
> Content-Type: application/json
> ```

---

## 📑 Table of Endpoints

| # | Endpoint | Method | Description |
|---|---|:---:|---|
| **1** | `/leader/asks/flows` | `GET` | Get all 3 flows with KPI metrics, sub-types, and section layouts |
| **2** | `/leader/asks/flows/{flow}` | `GET` | Get full master data for a flow (`collaboration`, `referral`, `help`) with sub-types & option groups |
| **3** | `/leader/asks/form-config` | `GET` | Get dynamic form layout, sections & category-filtered options (e.g. for `co_founder`) |
| **4** | `/leader/asks/all-data` | `GET` | All-in-one complete master data across all 3 flows for mobile local caching |
| **5** | `/leader/asks/summary` | `GET` | High-level KPI summary, flow breakdown, and recent requirements |
| **6** | `/leader/asks/{flow}/global` | `GET` | Global community feed for a specific flow with filters |
| **7** | `/leader/asks/{flow}/my` | `GET` | Leader's own requirements history for a specific flow |
| **8** | `/leader/asks/{flow}/leaderboard` | `GET` | Top impact contributors & peers for a specific flow |

---

## 1. Get All 3 Discovery Flows Overview

Loads the 3 primary flow modules with relationship-oriented framing, sub-type categories count, section layout, and KPI statistics.

- **Method:** `GET`
- **URL:** `/api/v1/leader/asks/flows`
- **Query Parameters:**
  - `include_inactive` (optional, boolean): Set to `true` to include inactive flows. Default: `false`.

### Response (`200 OK`)

```json
{
  "success": true,
  "status": true,
  "message": "Ask discovery flows retrieved successfully.",
  "data": {
    "total_flows": 3,
    "flows": [
      {
        "id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
        "code": "collaboration",
        "name": "Find a Collaborator",
        "description": "Find co-founders, business partners, joint venture partners, or distributors.",
        "icon": "handshake",
        "sort_order": 1,
        "is_active": true,
        "types_count": 13,
        "types": [
          {
            "id": "f5b56973-5076-42fa-bb10-37a4018fc83d",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "joint_venture",
            "name": "Joint Venture",
            "description": "Shared business opportunity",
            "level": 1,
            "sort_order": 1,
            "is_active": true,
            "options_count": 40,
            "metadata": []
          },
          {
            "id": "4a9b2548-1455-4855-97f9-81a8c23af6bf",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "co_founder",
            "name": "Co-Founder",
            "description": "Building a business together",
            "level": 1,
            "sort_order": 2,
            "is_active": true,
            "options_count": 54,
            "metadata": []
          },
          {
            "id": "6ce1e768-1e58-4985-b8c5-b0154e77f08e",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "strategic_partner",
            "name": "Strategic Partner",
            "description": "Long-term business growth",
            "level": 1,
            "sort_order": 3,
            "is_active": true,
            "options_count": 48,
            "metadata": []
          },
          {
            "id": "6644c6d8-e0c3-46d9-a9a4-684ddd09b86f",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "technology_partner",
            "name": "Technology Partner",
            "description": "Technology development and integration",
            "level": 1,
            "sort_order": 4,
            "is_active": true,
            "options_count": 48,
            "metadata": []
          },
          {
            "id": "cabd96aa-6b37-4b99-b04e-a5eb32166b87",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "manufacturing_partner",
            "name": "Manufacturing Partner",
            "description": "Production and supply chain",
            "level": 1,
            "sort_order": 5,
            "is_active": true,
            "options_count": 48,
            "metadata": []
          },
          {
            "id": "47e3d0d0-5fc4-40b5-b9a3-04646c0c8f9d",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "distribution_partner",
            "name": "Distribution Partner",
            "description": "Market reach and product distribution",
            "level": 1,
            "sort_order": 6,
            "is_active": true,
            "options_count": 46,
            "metadata": []
          },
          {
            "id": "7993db96-b6c8-43aa-a620-0ec4ba90ff29",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "vendor_service_partner",
            "name": "Vendor / Service Partner",
            "description": "Professional services and business support",
            "level": 1,
            "sort_order": 7,
            "is_active": true,
            "options_count": 46,
            "metadata": []
          },
          {
            "id": "a4c4281d-b2e8-42f9-9c3c-1d0ee771a4d7",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "channel_partner",
            "name": "Channel Partner",
            "description": "Sales and customer acquisition",
            "level": 1,
            "sort_order": 8,
            "is_active": true,
            "options_count": 46,
            "metadata": []
          },
          {
            "id": "b5b459c6-1802-4478-adb9-d6c78fef3727",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "marketing_partner",
            "name": "Marketing Partner",
            "description": "Brand building and audience growth",
            "level": 1,
            "sort_order": 9,
            "is_active": true,
            "options_count": 45,
            "metadata": []
          },
          {
            "id": "ed61ebb0-894b-48ff-86c1-8650f36d5d66",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "implementation_partner",
            "name": "Implementation Partner",
            "description": "Execution and deployment",
            "level": 1,
            "sort_order": 10,
            "is_active": true,
            "options_count": 46,
            "metadata": []
          },
          {
            "id": "732e7b2e-06b8-4897-8cc1-a7ad89521b6b",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "event_partner",
            "name": "Event Partner",
            "description": "Events, networking and experiences",
            "level": 1,
            "sort_order": 11,
            "is_active": true,
            "options_count": 46,
            "metadata": []
          },
          {
            "id": "ae578e18-9566-4217-917e-c5fa6227c24e",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "cross_border_partner",
            "name": "Cross-Border Partner",
            "description": "International business expansion",
            "level": 1,
            "sort_order": 12,
            "is_active": true,
            "options_count": 48,
            "metadata": []
          },
          {
            "id": "933afd29-956b-4442-b6a7-a13f258b4939",
            "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
            "code": "other",
            "name": "Other",
            "description": "Flexible / Custom collaboration",
            "level": 1,
            "sort_order": 13,
            "is_active": true,
            "options_count": 0,
            "metadata": []
          }
        ],
        "sections": {
          "details": ["goal", "collaboration_bring", "collaboration_need"],
          "filters": ["industry", "geography", "business_stage", "timeline", "expected_outcome"]
        },
        "stats": {
          "total_asks": 42,
          "active_asks": 38,
          "fulfilled_asks": 4,
          "matches_count": 184,
          "responses_count": 29
        },
        "metadata": []
      },
      {
        "id": "7f751446-6c89-47f0-8373-3fe2f5292872",
        "code": "referral",
        "name": "Ask for a Referral",
        "description": "Ask peers for warm introductions to prospective clients, vendors, or talent.",
        "icon": "megaphone",
        "sort_order": 2,
        "is_active": true,
        "types_count": 12,
        "types": [
          { "id": "9acd7895-f92e-48a3-9ab9-4dd325a6e051", "code": "customer", "name": "Customer", "options_count": 0 },
          { "id": "0d05b4ab-b003-45df-a196-20c0e3ae784b", "code": "client", "name": "Client", "options_count": 0 },
          { "id": "da5d5b64-bd6e-4050-80f1-ba61548570d0", "code": "dealer", "name": "Dealer", "options_count": 0 },
          { "id": "4d1a529a-1526-446c-b33b-6eb656242ca9", "code": "distributor", "name": "Distributor", "options_count": 0 },
          { "id": "08bc8eee-fcf7-4918-bd7f-6ef655edba91", "code": "buyer", "name": "Buyer", "options_count": 0 },
          { "id": "500e9b3c-09a9-468d-804d-56853c5e063b", "code": "supplier", "name": "Supplier", "options_count": 0 },
          { "id": "40c1b9a4-0d33-460f-b12c-9f540ebdc461", "code": "strategic_partner", "name": "Strategic Partner", "options_count": 0 },
          { "id": "7fb31ce1-f4fb-46d7-b139-aef95be4aa7f", "code": "investor", "name": "Investor", "options_count": 0 },
          { "id": "d60bb427-6540-4401-814f-80a5ca742066", "code": "international_contact", "name": "International Contact", "options_count": 0 },
          { "id": "98786579-8cbc-46e2-b363-553c4707f79f", "code": "media_pr_contact", "name": "Media / PR Contact", "options_count": 0 },
          { "id": "94daddfb-0a8c-450d-93ab-b1f7c83622a1", "code": "industry_expert", "name": "Industry Expert", "options_count": 0 },
          { "id": "9743785c-839f-47c5-8c4d-19e62345d35e", "code": "other", "name": "Other", "options_count": 0 }
        ],
        "sections": {
          "details": ["who_to_meet", "ideal_profile", "referral_reason", "what_i_offer"],
          "filters": ["referral_industry", "referral_geography", "timeline"]
        },
        "stats": {
          "total_asks": 35,
          "active_asks": 30,
          "fulfilled_asks": 5,
          "matches_count": 142,
          "responses_count": 22
        },
        "metadata": []
      },
      {
        "id": "9d787734-9ad2-4ed4-96b2-eb27e9d7b8d8",
        "code": "help",
        "name": "Get Help",
        "description": "Ask peers for advice, mentorship, tasks, introductions and support.",
        "icon": "life-preserver",
        "sort_order": 3,
        "is_active": true,
        "types_count": 12,
        "types": [
          { "id": "8dc5ea6a-5a14-46c8-80d2-5b88b0b65293", "code": "advice", "name": "Advice", "options_count": 0 },
          { "id": "02924589-1930-46ed-b106-42ada367511b", "code": "founder_mentorship", "name": "Founder mentorship", "options_count": 0 },
          { "id": "ecf7456f-ccff-495c-a413-517adbe9da7b", "code": "industry_mentorship", "name": "Industry mentorship", "options_count": 0 },
          { "id": "7d6e7d2d-58c4-41f4-be55-a57f2434aeb8", "code": "mentorship", "name": "Mentorship", "options_count": 0 },
          { "id": "74f4766e-af57-4a8b-96cc-56fc86e2a16f", "code": "small_task", "name": "Small Task", "options_count": 0 },
          { "id": "5decee07-c2c8-472f-9fb5-debef19a88e1", "code": "expert_guidance", "name": "Expert guidance", "options_count": 0 },
          { "id": "559beb03-4c42-4717-b75e-2c226dd74c5d", "code": "introduction", "name": "Introduction", "options_count": 0 },
          { "id": "766999a7-da0d-4a04-ab50-4832c2335dff", "code": "accountability", "name": "Accountability", "options_count": 0 },
          { "id": "777d9ac1-6df1-45da-9ee6-4c0dfb390521", "code": "capital_support", "name": "Capital Support", "options_count": 0 },
          { "id": "031025c9-ece8-42a7-bbf4-48257ec9ddc3", "code": "emotional_peer_support", "name": "Emotional / Peer Support", "options_count": 0 },
          { "id": "5cde850d-4220-468a-b502-41a05b25d44a", "code": "review_feedback", "name": "Review / Feedback", "options_count": 0 },
          { "id": "c0e9da17-c21e-4b3c-9264-99e02f3fda6b", "code": "other", "name": "Other", "options_count": 0 }
        ],
        "sections": {
          "details": ["help_topic", "mentorship_subtype", "what_needed", "done_definition"],
          "filters": ["industry", "geography", "help_duration", "help_timing"]
        },
        "stats": {
          "total_asks": 28,
          "active_asks": 24,
          "fulfilled_asks": 4,
          "matches_count": 96,
          "responses_count": 18
        },
        "metadata": []
      }
    ]
  }
}
```

---

## 2. Get Flow Master Data & Details

Returns complete master data for a single flow (`collaboration`, `referral`, or `help`), including all its categories, relevant dynamic option groups, and options.

- **Method:** `GET`
- **URL Options:**
  - `/api/v1/leader/asks/flows/collaboration`
  - `/api/v1/leader/asks/flows/referral`
  - `/api/v1/leader/asks/flows/help`

### Response (`200 OK` for `/flows/collaboration`)

```json
{
  "success": true,
  "status": true,
  "message": "Flow 'collaboration' details and categories retrieved successfully.",
  "data": {
    "found": true,
    "flow": {
      "id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
      "code": "collaboration",
      "name": "Find a Collaborator",
      "description": "Find co-founders, business partners, joint venture partners, or distributors.",
      "icon": "handshake",
      "sort_order": 1,
      "is_active": true,
      "sections_layout": {
        "details": ["goal", "collaboration_bring", "collaboration_need"],
        "filters": ["industry", "geography", "business_stage", "timeline", "expected_outcome"]
      },
      "stats": {
        "total_asks": 42,
        "active_asks": 38,
        "fulfilled_asks": 4,
        "matches_count": 184,
        "responses_count": 29
      }
    },
    "types": [
      {
        "id": "f5b56973-5076-42fa-bb10-37a4018fc83d",
        "code": "joint_venture",
        "name": "Joint Venture",
        "description": "Shared business opportunity",
        "level": 1,
        "sort_order": 1,
        "is_active": true,
        "options_count": 40
      },
      {
        "id": "4a9b2548-1455-4855-97f9-81a8c23af6bf",
        "code": "co_founder",
        "name": "Co-Founder",
        "description": "Building a business together",
        "level": 1,
        "sort_order": 2,
        "is_active": true,
        "options_count": 54
      }
    ],
    "option_groups": [
      {
        "id": "fc951032-efa9-44f2-9e92-a0b96d9bf4c2",
        "code": "collaboration_bring",
        "name": "What I Bring",
        "description": "Strengths, capabilities, and assets you contribute to the collaboration.",
        "input_type": "multi_select",
        "is_multi_select": true,
        "is_required": false,
        "sort_order": 1,
        "options_count": 300
      },
      {
        "id": "139b38dc-7316-4900-adf1-4c004e64d1e6",
        "code": "collaboration_need",
        "name": "What I Need",
        "description": "What you are seeking from your collaborator partner.",
        "input_type": "multi_select",
        "is_multi_select": true,
        "is_required": false,
        "sort_order": 2,
        "options_count": 285
      },
      {
        "id": "27dbb8cf-8120-43eb-8d48-cb15e985b86d",
        "code": "industry",
        "name": "Industry",
        "description": "Target industry or business vertical.",
        "input_type": "single_select",
        "is_multi_select": false,
        "is_required": false,
        "sort_order": 3,
        "options_count": 5
      },
      {
        "id": "19e07f9c-70e0-410a-b328-98e3b4d4b1cf",
        "code": "geography",
        "name": "Geography",
        "description": "Geographic focus or reach.",
        "input_type": "single_select",
        "is_multi_select": false,
        "is_required": false,
        "sort_order": 4,
        "options_count": 3
      },
      {
        "id": "90e9d6d5-a3d5-47fe-a705-5da309c693a2",
        "code": "business_stage",
        "name": "Business Stage",
        "description": "Current lifecycle stage of the business.",
        "input_type": "single_select",
        "is_multi_select": false,
        "is_required": false,
        "sort_order": 5,
        "options_count": 5
      },
      {
        "id": "d04a6e45-f0bf-40ea-92c2-8408f6236b2f",
        "code": "timeline",
        "name": "Timeline",
        "description": "Urgency and preferred timeline.",
        "input_type": "single_select",
        "is_multi_select": false,
        "is_required": false,
        "sort_order": 6,
        "options_count": 3
      },
      {
        "id": "f8a0ffbe-27e1-45df-92d6-0c9103ee66ef",
        "code": "expected_outcome",
        "name": "Expected Impact",
        "description": "What this connection and collaboration can make possible.",
        "input_type": "single_select",
        "is_multi_select": false,
        "is_required": false,
        "sort_order": 7,
        "options_count": 4
      }
    ]
  }
}
```

---

## 3. Dynamic Form Configuration API

Returns the dynamic form layout, sections, and category-filtered options tailored for mobile requirement creation and editing.

- **Method:** `GET`
- **URL:** `/api/v1/leader/asks/form-config?flow=collaboration&type=co_founder`
- **Query Parameters:**
  - `flow` (required, string): `collaboration`, `referral`, or `help`
  - `type` (optional, string): Sub-type code (e.g. `co_founder`, `joint_venture`, `advice`, `customer`) or UUID.
  - `include_inactive` (optional, boolean): Default `false`.

### Response (`200 OK`)

```json
{
  "success": true,
  "status": true,
  "message": "Dynamic form configuration retrieved successfully.",
  "data": {
    "found": true,
    "flow": {
      "id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
      "code": "collaboration",
      "name": "Find a Collaborator",
      "description": "Find co-founders, business partners, joint venture partners, or distributors.",
      "icon": "handshake",
      "sort_order": 1,
      "is_active": true
    },
    "type": {
      "id": "4a9b2548-1455-4855-97f9-81a8c23af6bf",
      "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
      "code": "co_founder",
      "name": "Co-Founder",
      "description": "Building a business together",
      "level": 1,
      "sort_order": 2,
      "is_active": true
    },
    "sections": {
      "details": ["goal", "collaboration_bring", "collaboration_need"],
      "filters": ["industry", "geography", "business_stage", "timeline", "expected_outcome"]
    },
    "groups": [
      {
        "id": "fc951032-efa9-44f2-9e92-a0b96d9bf4c2",
        "code": "collaboration_bring",
        "name": "What I Bring",
        "description": "Strengths, capabilities, and assets you contribute to the collaboration.",
        "input_type": "multi_select",
        "is_multi_select": true,
        "is_required": false,
        "sort_order": 1,
        "is_active": true,
        "options": [
          { "code": "cf_bring_business_idea", "label": "Business Idea", "sort_order": 1 },
          { "code": "cf_bring_business_vision", "label": "Business Vision", "sort_order": 2 },
          { "code": "cf_bring_business_strategy", "label": "Business Strategy", "sort_order": 3 },
          { "code": "cf_bring_business_planning", "label": "Business Planning", "sort_order": 4 },
          { "code": "cf_bring_business_model_development", "label": "Business Model Development", "sort_order": 5 },
          { "code": "cf_bring_startup_experience", "label": "Startup Experience", "sort_order": 6 },
          { "code": "cf_bring_entrepreneurship_experience", "label": "Entrepreneurship Experience", "sort_order": 7 },
          { "code": "cf_bring_business_leadership", "label": "Business Leadership", "sort_order": 8 },
          { "code": "cf_bring_technical_expertise", "label": "Technical Expertise", "sort_order": 9 },
          { "code": "cf_bring_software_development", "label": "Software Development", "sort_order": 10 },
          { "code": "cf_bring_engineering_expertise", "label": "Engineering Expertise", "sort_order": 11 },
          { "code": "cf_bring_product_development", "label": "Product Development", "sort_order": 12 },
          { "code": "cf_bring_product_design", "label": "Product Design", "sort_order": 13 },
          { "code": "cf_bring_sales_expertise", "label": "Sales Expertise", "sort_order": 14 },
          { "code": "cf_bring_business_development", "label": "Business Development", "sort_order": 15 },
          { "code": "cf_bring_marketing_strategy", "label": "Marketing Strategy", "sort_order": 16 },
          { "code": "cf_bring_digital_marketing", "label": "Digital Marketing", "sort_order": 17 },
          { "code": "cf_bring_capital_investment", "label": "Capital / Investment", "sort_order": 18 },
          { "code": "cf_bring_fundraising", "label": "Fundraising", "sort_order": 19 },
          { "code": "cf_bring_investor_network", "label": "Investor Network", "sort_order": 20 },
          { "code": "cf_bring_industry_expertise", "label": "Industry Expertise", "sort_order": 21 },
          { "code": "cf_bring_existing_customer_base", "label": "Existing Customer Base", "sort_order": 22 },
          { "code": "cf_bring_operations_management", "label": "Operations Management", "sort_order": 23 },
          { "code": "cf_bring_project_management", "label": "Project Management", "sort_order": 24 },
          { "code": "cf_bring_full_time_commitment", "label": "Full-Time Commitment", "sort_order": 25 },
          { "code": "cf_bring_part_time_commitment", "label": "Part-Time Commitment", "sort_order": 26 },
          { "code": "cf_bring_mentorship", "label": "Mentorship", "sort_order": 27 },
          { "code": "cf_bring_strategic_business_connections", "label": "Strategic Business Connections", "sort_order": 28 }
        ]
      },
      {
        "id": "139b38dc-7316-4900-adf1-4c004e64d1e6",
        "code": "collaboration_need",
        "name": "What I Need",
        "description": "What you are seeking from your collaborator partner.",
        "input_type": "multi_select",
        "is_multi_select": true,
        "is_required": false,
        "sort_order": 2,
        "is_active": true,
        "options": [
          { "code": "cf_need_technical_co_founder", "label": "Technical Co-Founder", "sort_order": 1 },
          { "code": "cf_need_business_co_founder", "label": "Business Co-Founder", "sort_order": 2 },
          { "code": "cf_need_sales_co_founder", "label": "Sales Co-Founder", "sort_order": 3 },
          { "code": "cf_need_marketing_co_founder", "label": "Marketing Co-Founder", "sort_order": 4 },
          { "code": "cf_need_product_co_founder", "label": "Product Co-Founder", "sort_order": 5 },
          { "code": "cf_need_finance_co_founder", "label": "Finance Co-Founder", "sort_order": 6 },
          { "code": "cf_need_operations_co_founder", "label": "Operations Co-Founder", "sort_order": 7 },
          { "code": "cf_need_technology_expertise", "label": "Technology Expertise", "sort_order": 8 },
          { "code": "cf_need_software_development", "label": "Software Development", "sort_order": 9 },
          { "code": "cf_need_business_strategy", "label": "Business Strategy", "sort_order": 10 },
          { "code": "cf_need_business_leadership", "label": "Business Leadership", "sort_order": 11 },
          { "code": "cf_need_product_development", "label": "Product Development", "sort_order": 12 },
          { "code": "cf_need_sales_expertise", "label": "Sales Expertise", "sort_order": 13 },
          { "code": "cf_need_marketing_expertise", "label": "Marketing Expertise", "sort_order": 14 },
          { "code": "cf_need_financial_planning", "label": "Financial Planning", "sort_order": 15 },
          { "code": "cf_need_fundraising", "label": "Fundraising", "sort_order": 16 },
          { "code": "cf_need_investor_network", "label": "Investor Network", "sort_order": 17 },
          { "code": "cf_need_industry_expertise", "label": "Industry Expertise", "sort_order": 18 },
          { "code": "cf_need_complementary_skills", "label": "Complementary Skills", "sort_order": 19 },
          { "code": "cf_need_shared_vision", "label": "Shared Vision", "sort_order": 20 },
          { "code": "cf_need_business_idea_validation", "label": "Business Idea Validation", "sort_order": 21 },
          { "code": "cf_need_customer_acquisition", "label": "Customer Acquisition", "sort_order": 22 },
          { "code": "cf_need_full_time_commitment", "label": "Full-Time Commitment", "sort_order": 23 },
          { "code": "cf_need_long_term_commitment", "label": "Long-Term Commitment", "sort_order": 24 },
          { "code": "cf_need_willingness_to_invest_time", "label": "Willingness to Invest Time", "sort_order": 25 },
          { "code": "cf_need_willingness_to_invest_capital", "label": "Willingness to Invest Capital", "sort_order": 26 }
        ]
      },
      {
        "id": "27dbb8cf-8120-43eb-8d48-cb15e985b86d",
        "code": "industry",
        "name": "Industry",
        "input_type": "single_select",
        "is_multi_select": false,
        "options": [
          { "code": "manufacturing", "label": "Manufacturing" },
          { "code": "retail", "label": "Retail" },
          { "code": "tech", "label": "Tech" },
          { "code": "services", "label": "Services" },
          { "code": "other", "label": "Other" }
        ]
      },
      {
        "id": "19e07f9c-70e0-410a-b328-98e3b4d4b1cf",
        "code": "geography",
        "name": "Geography",
        "input_type": "single_select",
        "is_multi_select": false,
        "options": [
          { "code": "my_city", "label": "My city" },
          { "code": "india", "label": "India" },
          { "code": "international", "label": "International" }
        ]
      },
      {
        "id": "90e9d6d5-a3d5-47fe-a705-5da309c693a2",
        "code": "business_stage",
        "name": "Business Stage",
        "input_type": "single_select",
        "is_multi_select": false,
        "options": [
          { "code": "start", "label": "Start" },
          { "code": "grow", "label": "Grow" },
          { "code": "scale", "label": "Scale" },
          { "code": "pre_ipo", "label": "Pre-IPO" },
          { "code": "public", "label": "Public" }
        ]
      },
      {
        "id": "d04a6e45-f0bf-40ea-92c2-8408f6236b2f",
        "code": "timeline",
        "name": "Timeline",
        "input_type": "single_select",
        "is_multi_select": false,
        "options": [
          { "code": "immediate", "label": "Immediate (Within 7 days)" },
          { "code": "one_month", "label": "Within 30 days" },
          { "code": "flexible", "label": "Flexible" }
        ]
      },
      {
        "id": "f8a0ffbe-27e1-45df-92d6-0c9103ee66ef",
        "code": "expected_outcome",
        "name": "Expected Impact",
        "input_type": "single_select",
        "is_multi_select": false,
        "options": [
          { "code": "joint_venture", "label": "Joint Venture / Consortium" },
          { "code": "strategic_partnership", "label": "Strategic Long-Term Partnership" },
          { "code": "knowledge_exchange", "label": "Knowledge Exchange & Mentorship" },
          { "code": "commercial_collaboration", "label": "Commercial Deal / Co-Selling" }
        ]
      }
    ]
  }
}
```

---

## 4. Master Data Everything Payload (All 3 Flows in 1 API)

Ideal for Mobile / Flutter initial sync and local caching (Hive / SQLite). Returns all 3 flows, all sub-types, sections, and options in a single API request.

- **Method:** `GET`
- **URL:** `/api/v1/leader/asks/all-data`

### Response (`200 OK`)

```json
{
  "success": true,
  "status": true,
  "message": "Complete Ask Discovery master data retrieved successfully.",
  "data": {
    "summary": {
      "total_requirements": 105,
      "active_requirements": 92,
      "fulfilled_requirements": 13,
      "total_peer_matches": 422,
      "total_peer_responses": 69
    },
    "flows": [
      {
        "id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
        "code": "collaboration",
        "name": "Find a Collaborator",
        "types_count": 13,
        "types": [ ... ]
      },
      {
        "id": "7f751446-6c89-47f0-8373-3fe2f5292872",
        "code": "referral",
        "name": "Ask for a Referral",
        "types_count": 12,
        "types": [ ... ]
      },
      {
        "id": "9d787734-9ad2-4ed4-96b2-eb27e9d7b8d8",
        "code": "help",
        "name": "Get Help",
        "types_count": 12,
        "types": [ ... ]
      }
    ],
    "version": "1.0.0",
    "timestamp": "2026-10-12T13:42:00+05:30"
  }
}
```

---

## 5. Leader KPI Summary Dashboard

Provides executive metric cards and flow breakdown for the Leader App Dashboard.

- **Method:** `GET`
- **URL:** `/api/v1/leader/asks/summary`

### Response (`200 OK`)

```json
{
  "success": true,
  "status": true,
  "message": "Leader Asks summary and flow breakdown retrieved successfully.",
  "data": {
    "total_requirements": 105,
    "active_requirements": 92,
    "fulfilled_requirements": 13,
    "total_peer_matches": 422,
    "total_peer_responses": 69,
    "flows_breakdown": {
      "collaboration": {
        "name": "Find a Collaborator",
        "total_asks": 42,
        "active_asks": 38,
        "fulfilled_asks": 4,
        "matches_count": 184,
        "responses_count": 29
      },
      "referral": {
        "name": "Ask for a Referral",
        "total_asks": 35,
        "active_asks": 30,
        "fulfilled_asks": 5,
        "matches_count": 142,
        "responses_count": 22
      },
      "help": {
        "name": "Get Help",
        "total_asks": 28,
        "active_asks": 24,
        "fulfilled_asks": 4,
        "matches_count": 96,
        "responses_count": 18
      }
    },
    "recent_requirements": [
      {
        "id": "e93ab234-7fa2-463d-8e45-8b3d0e2e9c12",
        "title": "Seeking Co-Founder for AI Logistics Startup",
        "status": "published",
        "flow": "Find a Collaborator",
        "flow_code": "collaboration",
        "type": "Co-Founder",
        "creator": "Vinit Chavda",
        "created_at": "2026-10-12T10:15:30Z"
      }
    ]
  }
}
```

---

## 6. Flow Community Feed, History & Leaderboard

### Global Community Feed per Flow
- **Method:** `GET`
- **URL:** `/api/v1/leader/asks/{flow}/global`
- **Flow Values:** `collaboration`, `referral`, `help`
- **Query Parameters:** `page`, `per_page`, `search`, `type`, `industry`, `city`

### My Posted Requirements per Flow
- **Method:** `GET`
- **URL:** `/api/v1/leader/asks/{flow}/my`
- **Flow Values:** `collaboration`, `referral`, `help`
- **Query Parameters:** `status` (`published`, `in_progress`, `closed`), `page`

### Flow Leaderboard
- **Method:** `GET`
- **URL:** `/api/v1/leader/asks/{flow}/leaderboard`
- **Flow Values:** `collaboration`, `referral`, `help`
- **Returns:** Top active peers, leaders, and responses count for this flow journey.

---

## 📱 Mobile Flutter Integration Guide

### 1. Initial Launch / Sync
Call `GET /api/v1/leader/asks/all-data` on app launch or flow tab opening:
1. Cache `flows`, `types`, and `sections` into local storage.
2. Render the 3 flow cards:
   - 🤝 **Find a Collaborator**
   - 📢 **Ask for a Referral**
   - 🆘 **Get Help**

### 2. Category Selection & Dynamic Form Rendering
When the user taps a Category (e.g. `Co-Founder` under `collaboration`):
1. Call `GET /api/v1/leader/asks/form-config?flow=collaboration&type=co_founder`.
2. The response returns:
   - `details` groups:
     - `What I Bring` (multi-select chips, all 28 options)
     - `What I Need` (multi-select chips, all 26 options)
   - `filters` groups:
     - `Industry` (single-select)
     - `Geography` (single-select)
     - `Business Stage` (single-select)
     - `Timeline` (single-select)
     - `Expected Impact` (single-select)

### 3. Post Creation Payload
Submit to `POST /api/v1/asks` (or `PUT /api/v1/asks/{id}`):
```json
{
  "flow_id": "96df70c7-6f68-46f0-99b7-7c8c5fa43593",
  "type_id": "4a9b2548-1455-4855-97f9-81a8c23af6bf",
  "title": "Looking for Technical Co-Founder to build SaaS platform",
  "goal": "Build an AI logistics optimization engine and go to market.",
  "answers": [
    {
      "option_group_id": "fc951032-efa9-44f2-9e92-a0b96d9bf4c2",
      "option_id": "48dd5081-c511-40a6-9937-5e30b44ccdf4",
      "code": "cf_bring_business_idea"
    },
    {
      "option_group_id": "139b38dc-7316-4900-adf1-4c004e64d1e6",
      "option_id": "3e9b1012-7fa2-463d-8e45-8b3d0e2e9c12",
      "code": "cf_need_technical_co_founder"
    }
  ]
}
```
