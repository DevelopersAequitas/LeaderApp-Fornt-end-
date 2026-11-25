# LEADER APP — SCREEN-BY-SCREEN AUDIT

Version 2 · 2026-11-24 · Device: Samsung SM-A528B (Android 14, 1080×2400) · API: **dev** · Session: Super Admin
Method: `adb` taps + `screencap`, read-only. Nothing was submitted, approved, rejected, created or edited. Forms and sheets were opened and closed.
Evidence labels: **[V]** verified on device or in code · **[O]** observed, root cause not traced · **[A]** assumption · **[G]** backend gap · **[R]** recommendation.
Redacted screenshots: `documents/audit/screenshots/` (member names, photos, phone numbers, emails and the signed-in user's avatar are mosaicked; originals are kept outside the repo).

## 1. Screen inventory and inspection status

| # | Screen | Route / entry | Status | Screenshot(s) |
|---|---|---|---|---|
| 1 | Dashboard (tab 0) + Activity/Asks/Community/Leadership tabs | `/home` tab 0 | **Inspected** | 01, 01b, 01c, 11, 12, 13 |
| 2 | Peers list, sort chips | tab 1 | **Inspected** | 02 |
| 3 | Peers → Celebrations | tab 1 segment | **Inspected** | 26 |
| 4 | Teams / Circles & Teams | tab 2 | **Inspected** | 03, 03_loaded |
| 5 | Finance (KPIs, charts, transactions) | tab 3 | **Inspected** (top and mid) | 04, 30 |
| 6 | Finance → Record Offline/Dues Payment sheet | button | **Opened, not submitted** | 28 |
| 7 | Finance → Configure Commission Rates sheet | button | **Opened, not saved** | 29 |
| 8 | Reports → Submit Report form | tab 4 | **Inspected** (upper form; lower part below the fold not scrolled) | 05, 05_loaded |
| 9 | Reports → History & Analytics | tab 4 | **Inspected** | 31 |
| 10 | Report Details | from history card | **Inspected** | 32, 32b |
| 11 | Notifications | bell | **Inspected** (feed empty; no detail screen reachable) | 06 |
| 12 | Circle switcher bottom sheet | app-bar pill | **Inspected** | 07 |
| 13 | My Profile | avatar | **Inspected** (top to bottom) | 08, 08b, 08c |
| 14 | Role & Permission Matrix | Profile | **Inspected** (first role only; no toggles changed) | 09 |
| 15 | Official Circulars | Profile | **Inspected** (empty state only) | 10 |
| 16 | P2P Meetings | Dashboard tile | **Inspected** | 14 |
| 17 | Referrals | Dashboard tile | **Inspected** | 15 |
| 18 | Endorsements & Testimonials | Dashboard tile | **Inspected** | 16 |
| 19 | Visitor Registrations | Dashboard tile | **Inspected** | 17 |
| 20 | Recommended Peers | Dashboard tile | **Inspected** | 18 |
| 21 | Peers Introduced | Dashboard tile | **Inspected** | 19 |
| 22 | Pending Approvals | Dashboard tile | **Inspected** (Accept/Reject buttons present, not pressed) | 20 |
| 23 | Life Impacts | hero tile | **Inspected** | 22 |
| 24 | Business Deals | hero tile | **Inspected** | 23 |
| 25 | Circle Details | Teams card | **Inspected** (3 scroll positions) | 24, 24b, 24c |
| 26 | Circle Events & Gatherings | Circle Details → View all | **Inspected** (list only; Event Detail screen not opened) | 25 |
| 27 | Peer Profile (Overview tab) | Peers row | **Inspected** (3 scroll positions) | 27, 27b, 27c |
| 28 | Peer Collaborations (Asks) | Peer Profile | **Inspected** (empty state only) | 33 |
| 29 | Dashboard "Pending peers → Review" card | Dashboard bottom | **Seen**, not opened separately (same data as #22) | 01c |
| — | Splash, Login, OTP | app start | **Not opened.** Requires signing out; session was preserved on request. **Source-only**. | — |
| — | Maintenance gate | `/maintenance` | **Not opened** (needs `app-config` flag). Source-only. | — |
| — | Peer Profile → Activity tab, Need Help, Referrals asks, Events/Attendance, Testimonials, Coins, Introduced, edit-peer sheet | Peer Profile | **Not opened** | — |
| — | Circle Overview, Circle Peers, Sub-Industries, Refer-category tab, Event Detail | Circle Details | **Not opened** (`/circle-*` routes exist) | — |
| — | Role Management: other roles, custom-role create sheet | Profile | **Not opened** (edit-heavy) | — |
| — | Circular detail / publish | Circulars | **Not opened** (no data; publish is a write action) | — |
| — | Edit Profile sheet, avatar upload | Profile | **Not opened** (write path) | — |
| — | Teams industry/status filters + search results, At-Risk view | Teams | **Not opened** | — |
| — | Peers search, Add/Edit peer, Send wish | Peers | **Not opened** (write path) | — |
| — | Export PDF / Excel | Report Details | **Not pressed** (creates files/downloads) | — |
| — | Dark mode, other screen sizes, offline, API-failure states | — | **Not tested.** No dark theme exists. [V] | — |

## 2. Per-screen audit (inspected screens)

Columns: purpose · role scope · data source · layout/visual · interaction · loading/empty/error · recommended design · priority.

### 2.1 Dashboard — `features/dashboard/view/dashboard_view.dart`
- **Purpose:** global executive overview. **Role scope:** all roles with `can_access_dashboard`; hero tile 1 swaps to "Total Coins" when the role lacks `canViewOverallRevenue` [V code]. **Data:** `/leader/dashboard/metrics`, `/leader/dashboard/top-impacters`, `/leader/asks/summary`, `/admin/pending-requests*`.
- **Layout:** app bar (logo, role label, circle pill, bell, avatar) → 3 gradient tiles with 3D art → 4-tab KPI grid → Top 5 Impacters → "6 pending peers · Review" card at the very bottom.
- **Problems:** [O] no scope/tenure/territory shown, only the role label "Super Admin". [O] the only action card (pending peers) is last on a long scroll. [O] 8 KPI tiles per tab, no hierarchy; labels wrap mid-word ("Peer Recomme-ndations"). [O] Community tab shows "6.40Q" total coins (unit "Q" undefined). [O] "Leadership" tab shows event/mentor/speaker counts, nothing about the leader's own responsibilities. [O] Top-5 rows repeat person+industry strings; scores have no label. [V code] hero "Total Revenue" falls back to the **deals** value when `overall_revenue` is null/0 (`dashboard_hero_card.dart:60-67`), which mislabels deal value as revenue.
- **Interaction:** 7 of the 8 Activity tiles (all except "Peers") and all 3 hero tiles open the expected destination; the Asks/Community/Leadership tile grids were viewed but their tiles were not tapped. Hero "Total Revenue" opens Finance tab; "Lives Impacted" opens Life Impacts; "Business Deals" opens Business Deals.
- **States:** shimmer skeleton exists; empty/error not exercised.
- **Recommended:** Leadership Command Center: identity+scope header, "Needs your action" band first, role-specific modules, one compact KPI strip, charts only where actionable. **Priority: High.**

### 2.2 Peers — `peers_view.dart`
- **Purpose:** directory + celebrations. **Data:** `/leader/peers`, `/leader/peers/celebrations`.
- **Problems:** [O] sort chips overflow the right edge with no scroll cue; [O] company truncates, industry tag repeated on every row; [O] ALL-CAPS names; [O] unlabeled score chip. **Works:** 63 peers, verified badges, initial avatars, Celebrations list with Wish button (not pressed).
- **Priority: Medium.**

### 2.3 Teams — `teams_view.dart` (**contains your uncommitted work**)
- **Purpose:** circle directory. **Data:** `/leader/teams/{summary,circles,industries}`.
- **Problems:** [O] title "Circles & Teams" almost touches the circle pill (app bar crowding); [O] industry chip row sits against the app bar; [O] each card ≈ 280 px tall because the banner is a large image (test data uses a document screenshot as cover), so ~2 cards per screen; [O] title and subtitle repeat the same text; tag chip clipped ("Techn…"); [O] status pill overlaps banner. [V] first load shows a 3–4 s skeleton.
- **Recommended:** compact circle row (logo, name, industry, status, health indicator) with optional banner on detail only. **Priority: High.**

### 2.4 Finance — `finance_view.dart`
- **Purpose:** revenue/commission analytics + payment recording. **Role scope:** `can_access_finance_tab`; Record Payment / Commission Setup are write actions gated by `canModifyFinanceSettings` [V code, Super Admin sees both]. **Data:** `/leader/finance/{metrics,transactions,milestones}`.
- **Problems:** [V] Revenue Trend curve dips below zero between Sep–Oct (see data investigation §3.1). [O] y-axis mixes "1.0L"/"80.0k" labels; top gridline "1.0L" exceeds all data. [O] "50 Active Leadership Tenures" is a count shown among currency KPIs. [V code] `activeTenures` falls back to **42** if the API omits it (`finance_model.dart`), a fabricated default. [O] transaction rows repeat the same payer/amount patterns, descriptions truncated. [V] currency is hard-coded ₹ (see global doc).
- **Record Payment sheet:** [O] "Peer ID / Peer Name" is free text (no peer picker); ₹ prefix fixed; payment-type select. **Commission sheet:** role tabs (Circle Founder, Circle Director, …), % inputs; save button visible. Neither was submitted.
- **Priority: High** (chart bug, KPI semantics).

### 2.5 Reports — `reports_view.dart`
- **Submit form:** [V] **RenderFlex overflow by 15 px** in "Report Activity Inclusion" header (debug stripe visible); [V code] "All 0 peers" under "All Circles" because `LoadCirclePeersForReport` returns early when no circle is chosen (`reports_bloc.dart:400`), so the roster never loads; [O] ₹-specific placeholders; [O] long single-column form, 5 s skeleton first.
- **History & Analytics:** [O] two filter rows both start with an "All"/"all" chip (duplicate, inconsistent case); [O] metric chips show raw numbers (`Deals: 500000`, `Revenue: 100000`) next to formatted ones (`₹22.5L`, `₹28.0L`); [O] same author shown as "Industry Director" in one card and "Super Admin" in another.
- **Report Details:** [O] header good; metric chips unformatted (500000); roster shows ₹500.05Cr per peer vs 500000 total (test data, values do not reconcile); identical 94 % attendance on every peer; Export PDF/Excel buttons not pressed.
- **Priority: Critical (overflow) / High (roster).**

### 2.6 Notifications — `notifications_view.dart`
- [O] bell badge showed **2**, then **1**; header says "1 new"; feed says "All Caught Up" with no items. Three different counts for the same state; root cause not traced (feed vs `leader/notifications/unread-count`). Filter chips (All/Circle/Peers/Finance…) overflow right edge. **Priority: High** (trust).

### 2.7 Profile — `profile_view.dart`
- [O] 44 "Assigned Circles & Territory" rows, each a flat "Active Leadership Assignment" — no role, scope level, start date or committee per assignment; includes test circles (`test10`, `test2`). [O] "Global Scope" shown. [O] phone and email displayed unmasked. Role Matrix and Circulars entries at bottom; "Sign Out" button.
- **Recommended:** group assignments by role/scope; show tenure; mask contact by default. **Priority: High.**

### 2.8 Role Matrix — `role_management_view.dart`
- [V] shows "5 of 13 capabilities" while `SUPER_ADMIN_ROLE_MATRIX_API_DOC.md` defines 12 (doc/app drift). [O] two "All" chips in filter row; role title truncated ("Chair - Business …"); Save button always visible with "Synced" pill. Toggles not touched. **Priority: Medium.**

### 2.9 Circulars — empty state with filters (Urgent/Important/Routine), search, Refresh. Fine. **Low.**

### 2.10 Activity lists (P2P, Referrals, Endorsements, Visitors, Recommended, Introduced, Pending Approvals, Life Impacts, Business Deals)
- Consistent pattern: summary card + 2 tabs (Activity Records / Contributors) + record cards. Good pattern; reuse. [O] test strings visible ("kaa", "heyeb", "yf7ff7"). [O] Accept/Reject are inline on Recommended Peers and Pending Approvals; **confirmation behaviour not tested**. [O] Business Deals amounts appear as raw "100000" / "25000". **Priority: Medium.**

### 2.11 Circle Details — `circle_details_view.dart` (**your hero-card changes live here**)
- Sections: banner+logo, title/status, About, Focus areas, Category Availability (171 open / 1 closed), Regional Leaders, Circle Peers, Meetings & Events (7).
- [O] "Regional Leaders (1)" lists a person labelled **Circle Founder**, and the same person also appears under Circle Peers — role/section mismatch or duplicate. [O] cadence appears three times (banner strip, tile row, card) with truncation ("Monthly Circle Conc…", "1st Wednesday …", "09:00 PM - 10:…"). [O] dates ISO (`2026-12-02`), no timezone. [O] header chip "₹2.0" is unlabeled. [O] "Meetings & Events 7" shows one card inline.
- **Priority: High.**

### 2.12 Events & Gatherings — [O] chips All 7 / Upcoming 1 / Completed 6, cadence banner, cards with mode/status; ISO dates; attendee counts. Good base. **Medium.**

### 2.13 Peer Profile — `peer_profile_view.dart` (38 files)
- Overview/Activity tabs; hero card; contact (phone/email/WhatsApp shown plainly); milestones; performance tiles (Coins `64009000…` truncated); shortcut cards (Collaborations, Need Help, Referrals, Events); tags; Posts & Creatives with **delete (trash) icon on each post** visible to this role. [O] truncated joined date. Collaborations: empty state OK. **Priority: Medium** (delete affordance needs role/confirm check).

## 3. Data-discrepancy investigation (source-traced)

### 3.1 Negative revenue chart (Finance) — **cause: rendering, not data**
1. Source: `FinanceChartPoint.value` from `/leader/finance/metrics → revenue_trend[]` `{month, value}`; no sorting or aggregation in the app [V `finance_model.dart`]. The plotted dots at Jun–Oct sit at the zero baseline and Nov is positive, so data points are ≥ 0.
2. Rendering: `_SplineChartPainter` (`finance_spline_chart.dart:~320-400`) clamps each **point** to `[0,1]` but builds the curve with cubic Béziers using tangent control points `(p[i+1]-p[i-1])*0.18`. Between Sep(0) and Oct(0) the Oct control point is `Oct − tangent`, where the tangent follows the steep Oct→Nov rise, so the control point is below the baseline and the curve overshoots below 0.
3. Conclusion [V]: overshoot of a non-monotone cubic spline. A monotone-cubic (Fritsch–Carlson) interpolation or clamping control points to the baseline fixes it. No business calculation is involved. **Not changed.** Same painter pattern likely exists in `reports_spline_chart.dart` [A, not checked].

### 3.2 Dashboard "Total Revenue ₹65,000" vs Finance "Total Revenue ₹72,000" and "Circle Revenue ₹16,200"
- Dashboard value = `overall_revenue` from `GET /leader/dashboard/metrics`; falls back to `deals` text when null/"₹0"/"₹0.0" [V].
- Finance value = `total_revenue` (fallback `projected_annual_revenue`) from `GET /leader/finance/metrics`; "Circle Revenue" = `circle_revenue` (fallback `total_collections`) [V].
- Two endpoints, two key names, unspecified definitions; both arrive as preformatted strings (the app does not compute them). The ₹7,000 difference **cannot be attributed from the app**; raw API JSON was not captured (would require reading the auth token). [G] backend must define "overall revenue", "total revenue", "circle revenue" and their periods. Until then label each with its definition and period.

### 3.3 Reports "All 0 peers" vs Peers "All Peers (63)"
- Peers tab: count = `state.totalPeersCount` (else list length) from `/leader/peers` for the selected circle filter [V code `peers_view.dart:265`].
- Reports: roster list comes from `TeamsRepository.getCirclePeers(circleId)` and `LoadCirclePeersForReport` returns immediately when `circleId.isEmpty` (All Circles) [V `reports_bloc.dart:400`]; also filters hard-coded "dummy" names/IDs (`ReportModel.isDummyPeer`). So under All Circles the count is 0 by construction, and a submit would attach an empty roster [A: submit path not exercised]. The export service has a fallback to the global peers endpoint, the submit form does not.
- Peers count 63 is the global list and does not exclude those dummy peers, so the two counts can also differ for a second reason when a circle is chosen.

### 3.4 Other code-level findings
- `isDummyPeer` hard-codes two person names and two UUIDs in production code (test-data scrub) — [V] `report_model.dart:245-260`.
- `activeTenures ?? 42` fabricated default — [V].
- Dashboard revenue→deals fallback — [V].
- Smoke test fails: expects "Sign in" text on first frame, app starts on splash — [V].

## 4. UI/UX issue register (ranked)

| ID | Pri | Screen | Issue | Evidence |
|---|---|---|---|---|
| UX-01 | Critical | Reports form | 15 px RenderFlex overflow in activity-inclusion header | V (screenshot 05_loaded) |
| UX-02 | High | Reports form | Roster "All 0 peers" under All Circles; empty roster may be attached | V code |
| UX-03 | High | Finance | Revenue spline dips below zero | V code+screenshot |
| UX-04 | High | Dashboard/Finance | Conflicting revenue figures, unlabeled definitions; revenue falls back to deals | V code |
| UX-05 | High | Dashboard | No action-first layout; pending approvals at bottom; no scope/tenure | O |
| UX-06 | High | Notifications | Bell 2 / header "1 new" / empty feed | O |
| UX-07 | High | Teams | 280 px cards, title collides with pill, duplicated title/subtitle | O |
| UX-08 | High | Profile | 44 undifferentiated assignments; no role/scope/tenure per assignment | O |
| UX-09 | High | Circle Details | "Regional Leaders" shows a Circle Founder; person repeated; cadence shown 3× | O |
| UX-10 | High | Reports/Finance | Inconsistent money formatting (500000 vs ₹22.5L vs ₹500.05Cr), ₹ hard-coded | V |
| UX-11 | Medium | Peers/Notifications/Role matrix | Chip rows overflow edge, duplicate "All" chips | O |
| UX-12 | Medium | Dashboard | KPI label wrapping, "6.40Q" unit, unlabeled scores, saturated hero tiles | O |
| UX-13 | Medium | Approvals | Inline Accept/Reject: confirmation not verified | O |
| UX-14 | Medium | Peer Profile | Trash icon on every post; contact data unmasked | O |
| UX-15 | Medium | Global | No dark theme, no localization, no Semantics, no text-scale handling | V |
| UX-16 | Low | Several | Truncated text (company, cadence, coins) | O |
| UX-17 | Low | Test data | Placeholder strings visible in lists | O |

## 5. Recommended design direction (summary; see design system and roadmap)
Action-first role-aware home; compact list rows instead of tall cards; one money/number/date formatting layer; one chart module with monotone splines, tooltips and entrance animation; shared EmptyState/ErrorState/Skeleton; unify chip rows; keep the existing "summary card + two tabs" list pattern for activity screens.


---

## 6. Phase 3 Continuation — Nested Screen Audit Additions (2026-11-24, Samsung SM-A528B, updated debug build)

Read-only walkthrough after installing the updated debug APK (`adb install -r`, Super Admin session preserved throughout):

| Screen | Inspection Mode | Key Findings |
|---|---|---|
| **Teams → Industry & Status Filters** | **Visually inspected (device)** | Industry chip filter works (`Manufacturing & Engineering Circles (5)` narrows list to matching circles), but the section header renders **`MANUFACTURING & ENGINEERING CIRCLES CIRCLES`** (`teams_view.dart:70` appends ` CIRCLES` even when the industry name already ends with `Circles`), wrapping to 3 lines and shifting the `All / Active / At Risk` status filter row downward. |
| **Circle Details → Circle Peers (`CirclePeersScreen`)** | **Visually inspected (device)** | Reached via `See more` on Circle Details. Shows search bar, `All / Active / At-Risk` status chips, `Showing 2 of 2 peers`, and standard `PeerCard` rows. Clean layout; note one peer's backend `designation` string is literally `"Member"` (server data). |
| **Circle Details → Event Detail (`CircleEventDetailScreen`)** | **Visually inspected (device)** | Reached via Circle Details meeting card. Confirmed updated timezone-aware formatting (`Wed, Dec 2, 2026 (1st Wednesday · Monthly) · 09:00 PM - 10:00 PM` without misleading fabricated UTC offset for zone-less dev payload) and updated brand copy (`Circle Peers`, `Registered Circle Peers`, `No Circle Peers Registered Yet`, `Peers of this circle will appear here when registered.`). Observed discrepancy: header reports `15 Total Registered Attendees` (`attendees_count`) while the attendee list is empty (`attendees: []` from API; `CircleMeetingCard` also omits `attendingPeers` when pushing `CircleEventDetailScreen`). |
| **Peer Profile → Activity Sub-Tab** | **Visually inspected (device)** | Reached from Peers → Peer Profile → `Activity (5)`. Renders `RECENT ACTIVITY` timeline with relative timestamps (`3 hours ago`, `7 hours ago`, `1 week ago`). Observed backend data leakage: raw internal UUID tag `[sn_match:<uuid>]` and prohibited server copy (`Speed [prohibited term] Round 1`) appear in backend activity descriptions. |
| **Profile → Hero & Role Management (`RoleManagementView`)** | **Visually inspected (device)** | Confirmed updated brand copy `Peer since Nov 2026`. In Role Management, confirmed `Chair - Business Growth Committee` chip is ~891 px wide (nearly full viewport width), leaving only a ~121 px sliver of the second chip (`Chair - Membership Committee`) visible at the right edge before horizontal scrolling; duplicate `All` filter chips remain. Toggles/Save were NOT touched. |
| **Circle Overview (`CircleOverviewScreen`)** | **Source-only inspected** | Registered as named route `AppRoutes.circleOverview`, but no button or navigation path in `CircleDetailsView` currently links to it. Renders health progress bar, meeting cadence card (duplicates `CircleMeetingCard`), and sub-industry tags (`circle_overview_section.dart`). |
| **Splash, Login, OTP, Maintenance** | **Source-only inspected** | Not visually inspected on device because doing so would require signing out of the preserved Super Admin session (no second test device/account available). Login international phone input covered by widget & BLoC tests. |
| **Peer Profile → Need Help, Referral Asks, Events/Attendance, Testimonials, Coins, Introduced, Edit Sheets** | **Source-only inspected** | Brand copy and Event timezone formatting verified in source and unit/widget tests; not individually opened on device during this pass. |
