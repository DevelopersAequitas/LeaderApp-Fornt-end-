# LEADER APP — ROLE AND SCOPE MATRIX

Version 1 · 2026-11-24 · Labels: **[V]** verified in code/docs · **[W]** from peersglobal.com (fetched 2026-11-24) · **[O]** observed on device · **[A]** assumption · **[G]** backend gap · **[R]** recommendation

Principle: roles, scope and permissions come from the backend assignment. The app must not infer territory from a role name, and must not hard-code seat counts from marketing copy.

## 1. Three vocabularies that do not yet agree

| Concept | Website [W] | App `UserRole` enum [V] | Backend permission doc [V] |
|---|---|---|---|
| Circle Founder | Founder: "creates the possibility"; outside the numbered ladder | `circleFounder` | Circle Founder |
| Circle Director | Stage 003 "Monthly Leadership" (on the ladder) | `circleDirector` | Circle Director |
| Industry Director | Stage 04 "City Sector Owner" | `industryDirector` | Industry Director |
| Executive Director | Stage 05 "Regional Builder": Area → District → State → Country | `districtExecDirector` ("District Exec Director") **and** `countryDirector` (two separate roles) | District Exec Director; Country Director (matrix column) |
| Global Leadership | Stage 06 "Ecosystem Steward" | `superAdmin` (admin role, not a leadership stage) | Super Admin |
| Powerhouse / committees | Business Growth, Membership Experience, Events & Impact; each Chair + 3 Leaders | `chairBusinessGrowth`, `chairMembership`, `chairEvents` ("Events & Programs"), generic `circleChair` | single "Circle Chair" column |
| Committee Leaders (9) | Named leaders (e.g. Business Growth Leader, Member Success Leader, Events & Experience Leader …) | **absent** | **absent** |
| Project Chairs (9) | City Expansion … Alumni & Legacy | **absent** | **absent** |
| Ambassador | Own page `/leadership/ambassadors`; not in the ladder or five-role table; no scope wording; nomination link shared with other leaders | **absent** | **absent** |
| Seat counts | "Fourteen" Powerhouse; 3+9=12 on Director page; "Nineteen roles" (its own lists total 21); "14 active committees" vs "three committees" | n/a | n/a |

Differences to resolve with the product owner: (1) "Executive Director" is one role with four possible scope levels on the site but two enum roles in the app; (2) committee names differ ("Membership Experience" vs `chairMembership`, "Events & Impact" vs "Events & Programs"); (3) Leaders and Project Chairs have no app representation; (4) Ambassador is requested in the brief but not published; (5) the site's own counts conflict. [R] Treat the **backend role/assignment records** as the single source; add roles only after the backend supports them.

## 2. App roles → what the app grants today

Source: `LeaderPermissions` (22 boolean flags) built from the login response or from `enabled_capabilities`; `SessionManager.permissions` returns `allGranted` for Super Admin [V]. The backend matrix is below; where the app overrides it the cell is marked ≠.

| Flag | Circle Chair | Circle Founder | Circle Director | Industry Dir. | District Exec Dir. | Country Dir. | Super Admin |
|---|:--:|:--:|:--:|:--:|:--:|:--:|:--:|
| access_dashboard | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| view_overall_revenue | ✖ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| review_pending_peers | ✔ | ✔ | ✔ | ✖ | ✔ | ✖ | ✖ (≠ app: Super Admin saw "6 pending peers · Review") |
| access_peers_tab | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| add_edit_peer | ✖ | ✔ | ✔ | ✖ | ✔ | ✔ | ✔ |
| send_wishes | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| access_teams_tab / manage_circles | ✖ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| access_finance_tab | ✖ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| modify_finance_settings | ✖ | ✖ | ✖ | ✖ | ✔ | ✔ | ✔ |
| issue_coins | ✖ | ✖ | ✖ | ✖ | ✖ | ✔ | ✔ |
| access_reports_tab | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| submit_reports | ✔ | ✔ | ✔ | ✖ | ✖ | ✖ | ✖ (≠ app: Super Admin saw the Submit Report form) |
| export_peer_data | ✖ | ✔ | ✔ | ✔ | ✔ | ✔ | ✔ |
| export_financial_data | ✖ | ✖ | ✖ | ✖ | ✔ | ✔ | ✔ |
| export_global_data | ✖ | ✖ | ✖ | ✖ | ✖ | ✖ | ✔ |
| access_role_management | ✖ | ✖ | ✖ | ✖ | ✖ | ✖ | ✔ |

Source: `BACKEND_API_AND_PERMISSIONS_DOC.md` §2 [V]. The three committee-chair enum values and Country Director are not separate columns in that document [V]. The dynamic role matrix (Role Management screen) can override these at runtime [V]: observed "Chair – Business Growth Committee: 5 of 13 capabilities" [O] vs 12 capabilities in `SUPER_ADMIN_ROLE_MATRIX_API_DOC.md` [V] — [G] confirm the 13th capability.

## 3. Scope model

| Leader | Scope the app can express today | Scope the product needs [W] | Gap |
|---|---|---|---|
| Circle Director / Founder / Chair | `managed_circles: [..]` and the circle filter pill | One Circle (or a few) | OK; per-assignment role not returned [G] |
| Industry Director | circle filter across industries; "Industry clusters" flag | Sector across multiple Circles in a city | No industry-assignment object [G] |
| District Exec Director | `regional_scope: "District"`; server filters by token (DED doc) | Area/District | OK per doc |
| Country Director / other Executive scopes | `regional_scope` string | State, Country | No geography ids, level or parent [G] |
| Super Admin / Global | "Global Scope" label | Global leadership | OK |
| Multi-assignment | Profile lists 44 assignments as identical rows [O] | Role/scope switcher with explicit scope | Assignment records need role, scope level, geography id, start/end [G] |

Observed on the device: Super Admin with 44 "Active Leadership Assignment" circles, none with a role label [O].

## 4. Role-specific home priorities (proposed; supported-data column is what exists today)

| Role | Home modules proposed | Data supported today | Data missing [G] |
|---|---|---|---|
| Circle Director | Circle health (attendance, peers), next meeting, pending peer reviews, chair/leader activity, verified contributions | peers, circle events, reports attendance trend, pending requests, impacts | committee seats, chair/leader progress, tasks |
| Circle Founder | Formation progress, founding peers, category availability (171 open / 1 closed visible), launch milestones, handover | category availability, peers, milestones (finance) | formation/launch milestones, handover status |
| Industry Director | Circles in sector, performance comparison, collaborations, sector events | industries + circles lists | sector assignment, comparison metrics |
| Executive Director | Territory coverage, circle health across scope, leadership capacity, escalations | district scoping server-side, finance metrics | geography tree, capacity, escalations |
| Committee Chair | Committee tasks, members, meetings, outcomes | none dedicated | committees, tasks, meetings agenda |
| Committee Leader | Personal tasks, deadlines, submissions | none | tasks |
| Ambassador | Outreach, introduced entrepreneurs, follow-ups | "Peers Introduced", "Visitor Registrations" counts exist | role not published/not in app |

## 5. Rules to preserve [W]
- Verified contribution requires receiver confirmation in the Unity App; attendance and self-declared value earn nothing — the Impacts/Contributions UI must show state (declared / confirmed) and never imply self-verified impact.
- Never expose global member data to scoped leaders; every list must respect the token scope (already true server-side for DED per doc; [A] not verified for other roles).
- Hide, not just disable, actions the role cannot perform (Record Payment, Commission Setup, post delete were all visible to Super Admin only by design).

## 6. Recommendations
1. Backend: return an `assignments[]` array per leader: `{role_key, role_label, scope_type (circle|industry|territory|global), scope_id, scope_path, geography_level, starts_at, ends_at, status}`.
2. App: replace the enum-string matching with `role_key` from the backend; keep `UserRole` only for presentation fallbacks.
3. Keep committee/leader/project-chair UI behind backend support; do not synthesize seats from website numbers.
4. Confirm Ambassador and Executive Director scope levels with the product owner before design.
