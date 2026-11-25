# LEADER APP — ARCHITECTURE PROPOSALS & SOURCE TRACE (round 3)

2026-11-24 · Status: proposals + read-only findings. **Nothing in this file has been implemented** except the three approved fixes (see progress doc).
Labels: **[V]** verified in source · **[O]** observed on device · **[A]** assumption · **[G]** backend gap/decision

## 1. Exact source trace of the eight requested findings

### 1.1 Dashboard revenue
- Request: `DashboardRemoteDataSource` → `GET {baseUrl}/leader/dashboard/metrics` (`ApiEndpoints.dashboardMetrics`), cached in Hive as `dashboard_metrics_<circleId|all>` (`dashboard_repository.dart:24`), offline fallback from that cache (`:32`, `:59`).
- Field: `json['overall_revenue']?.toString()` → `DashboardMetricsModel.overallRevenue` (`dashboard_metrics_model.dart:182`), a **pre-formatted string**; not computed in the app.
- Display (`dashboard_hero_card.dart:60-67`): if `overallRevenue` is null/blank/`"₹0.0"`/`"₹0"` the card shows **`metrics.deals`** (business-deal value) under the label "Total Revenue". Visibility: Super Admin or `permissions.canViewOverallRevenue`; otherwise the card becomes "Total Coins".
- **Approved rule:** never substitute deal value for revenue; show "unavailable" if absent; show deal value separately and labelled.

### 1.2 Finance revenue aggregation
- `FinanceRemoteDataSource` → `GET /leader/finance/metrics` (+ `circleId`), cache key `finance_metrics_<circleId|all>` (`finance_repository.dart:40`).
- `FinanceMetricsModel.fromJson` (`finance_model.dart`): `totalRevenue = total_revenue ?? projected_annual_revenue ?? '₹0.0'`; `circleRevenue = circle_revenue ?? total_collections ?? '₹0.0'`; `dealsClosed = deals_closed ?? 0`; `commissionDue = commission_due ?? total_dues ?? '₹0.0'`; `totalCollections`, `totalDues` strings; `activeTenures = (active_tenures as num?)?.toInt() ?? 42`; `revenueTrend = revenue_trend[{month,value}]`, `businessDeals = business_deals[{month,value}]`. **No aggregation in the app**; the trend is plotted as received (no sorting).
- Fallbacks that can show wrong values: revenue falls back to *projected annual* revenue; circle revenue falls back to *total collections*; missing strings become `'₹0.0'`; tenures default to **42** (fabricated).
- **Reconciliation of ₹65,000 (dashboard) vs ₹72,000 (finance):** different endpoints (`dashboard/metrics.overall_revenue` vs `finance/metrics.total_revenue`), unspecified definitions/periods. Cannot be attributed from the app. [G] Backend must document each field (what is counted, period, currency, role scoping). Interim: label each value with its source/period; do not force equality.

### 1.3 Reports roster query
- Submit form roster: `ReportsBloc._onLoadCirclePeersForReport` → `TeamsRepository.getCirclePeers(circleId)` (`/leader/teams/circles/{id}/peers`); **returns immediately when `circleId` is empty** (`reports_bloc.dart:400`), so "All Circles" never loads a roster → "All 0 peers" (O).
- Filter `ReportModel.isDummyPeer` hard-codes two names and two UUIDs (`report_model.dart:245-260`).
- Export service (`report_export_service.dart:110-150`) already falls back from `getCirclePeers` to `PeersRepositoryImpl.getPeers(circleId: …)` when the circle endpoint is empty — a partial precedent for the global fallback.
- `PeerModel` carries a **single** `circle` + `circleId` (`peer_model.dart:8-9`) and `status`; `/leader/peers` supports `circle_id`, `status`, `search`, `page`, `per_page`.

### 1.4 Profile leadership assignment labels
- `SessionManager` profile parse: `managedCircles` = list of circle **names** from `/leader/profile → managed_circles` (`session_manager.dart:~85-102`), `regionalScope = regional_scope ?? 'Own Circle'`, `capabilitiesCount = capabilities_count ?? 14`, `memberSince = member_since ?? 'Aug 2026'` (fabricated default).
- `profile_assigned_circles_card.dart:115` renders the **constant** `'Active Leadership Assignment'` for every entry; there is no per-assignment role, scope, dates or id in the model.

### 1.5 Circle Details leader classification
- `circle_leadership_card.dart:30-67`: "**Circle Leaders**" = `circle.chairs` (or the single `chairName` as role "Circle Chair", designation "Chairperson"); "**Regional Leaders**" = `circle.founders` **+** `circle.directors` (or `founderName`/`directorName` with hard-coded designations "Founder & CEO", "Managing Director"). So Founders and Directors are placed under "Regional Leaders" by **UI bucketing**, although they are circle-level roles — the cause of the Founder under "Regional Leaders" seen on device. The designations are invented strings, not backend data.

### 1.6 Meeting cadence duplication
- The same cadence appears in `circle_events_section.dart:121` ("Recurring Circle Cadence" banner), `circle_meeting_card.dart:366` ("Recurring Cadence:" strip) and the tile row (`circle_meeting_card.dart:395-425`: Cadence, Timing, Format, Stage), plus `circle_overview_section.dart:136,161` (Timing, Format). All read `CircleCadenceModel`. It is a view-composition duplication, not a data duplication.

### 1.7 Fabricated default tenure count
- `finance_model.dart`: `activeTenures = (json['active_tenures'] as num?)?.toInt() ?? 42`. The device showed 50 (value from the API); 42 would appear only if the field were missing.

### 1.8 Notification unread count (three sources)
1. **Bell badge**: `NotificationCountService.unreadCount` (a `ValueNotifier`). Updated by `fetchUnreadCount()` (`GET /leader/notifications/unread-count`, with fallbacks to `data.unread_count`, `rawJson.unread_count`, then list header), by `NotificationsBloc` after loading the feed (`notifications_bloc.dart:73`), and **incremented locally by +1 on every foreground FCM message** (`push_notification_service.dart:307`).
2. **"N new" chip**: `NotificationsState.unreadCount` = server `unread_count` from the list response, else count of loaded items with `isUnread` (`notifications_bloc.dart:71`).
3. **Feed rows**: items are **filtered client-side** by `LeaderNotificationModel.isLeaderNotification`, which drops member-app types (event detail, feed, chat, connections …) (`notifications_bloc.dart:~66`, model `:88`).
- Consequence [V by code, matches O]: the server unread count includes notifications the feed hides, so the bell/chip can show 1–2 while the visible list is empty; the local +1 can also drift from the server. [G] Backend should count only leader-relevant notifications (or accept a `scope=leader` filter). [R] After approval: derive the chip from the filtered list or re-sync the bell from the server after each push, and show the hidden-count honestly.

## 2. Reports — "All Circles" (approved rule) — implementation approach
Approved: fetch all eligible Peers across the leader's authorized scope; dedupe by Peer ID; keep circle associations; show unique-peer count separately from circle-membership count; respect active membership/eligibility; never show 0 because no circle was chosen; never export an incomplete roster as complete.
- **Frontend (possible today):** when circle = All, page through `GET /leader/peers` (`page`, `per_page`) until `has_more` is false, optionally per authorized circle (`managed_circles` ids) if the global call is capped; dedupe by `PeerModel.id`; group `{peerId → set of (circleId, circleName, status)}`; filter `status` per the report-eligibility rule; expose `uniquePeers` and `memberships`.
- **Unknown/backend questions [G]:** (a) does `/leader/peers` return one row per membership or one per person, and does `circle` hold one value or the first? (b) a `circles: [{id,name,membership_status}]` array per peer is needed to represent multi-circle membership; (c) the report-specific eligibility rule (which statuses count: Active only? At Risk? Pending?); (d) a total count/`has_more` guarantee so completeness can be verified; (e) scope enforcement for non-super-admin roles.
- **Safety rules to implement:** if any page fails or `has_more` stays true, mark the roster **incomplete**, disable "attach roster/export" with an explicit message, and never present the partial list as complete; show a "Roster: 63 unique Peers · 71 Circle memberships" summary; keep the specific-circle path unchanged.
- **Decision requested:** the eligibility statuses (c) and whether multi-circle peers count once in attendance/deal metrics.

## 3. Dashboard revenue (approved rule) — implementation approach
- Source of truth for "Revenue": the finance service field. Preferred: Dashboard reads `GET /leader/finance/metrics.total_revenue` (or the backend-confirmed authoritative field) instead of `dashboard/metrics.overall_revenue`; until the backend documents both, the Dashboard tile is **labelled with source and period** and shows **"Unavailable"** (not 0, not deals) when the value is null/blank. Business deal value stays a separate tile ("Business Deals", already present) and is never used as a fallback.
- Keep `₹0` only when the API explicitly returns zero **and** a numeric field exists; distinguish `null` (unavailable) from `0`. Requires the models to carry `num?`/`Money?` rather than preformatted strings [G] (see global doc).
- Do not alter existing historical values; add a small reconciliation note in Finance explaining the two definitions once the backend confirms them.

## 4. Internationalization foundation — proposed architecture (not implemented)
**Compatibility inspected.** `pubspec.yaml` has no `intl`/`flutter_localizations`; `pubspec.lock` has no `intl` entry [V]. The lock carries your uncommitted changes (dart constraint `>=3.13.0-0`, `listen 1.0.1` added, three package bumps, one sha change) which must stay. Flutter 3.50.0 / Dart 3.12+ are compatible with `flutter_localizations` (SDK package) and the `intl` version Flutter pins.
**Smallest dependency change:** add under `dependencies`: `flutter_localizations: {sdk: flutter}` and `intl: <the version flutter_localizations pins>`; run `flutter pub get --no-example` (plain `get`, **not** `upgrade`) so existing locked versions stay, only `intl` and its transitive entries are appended. Verify with `git diff pubspec.lock` that only additions occur. `generate: true` + `l10n.yaml` only when ARB-based UI strings are approved.
**Layers (new folder `lib/core/l10n/` + `lib/core/formatting/`):**
1. `AppLocale` resolver — locale from device (default `en`); override per user setting later. No languages beyond `en` until an approved list exists (the installed Flutter l10n skill example uses `es`; that is **not** adopted).
2. `AppFormatters` (inject via `InheritedWidget`/extension on `BuildContext`): `money(Money)`, `number`, `compact`, `percent`, `date`, `dateTime`, `relative`, `time(zone)`; built on `intl` (`NumberFormat.currency/compact`, `DateFormat`).
3. `Money {BigDecimal-like decimal string/minor units, currencyCode}` model + parser for legacy preformatted strings (**read-only adapter**, so existing screens can migrate gradually).
4. `TimeZoneService`: IANA zone from the Circle/event (when backend provides it) → `timezone` package **(new dependency, separate approval)**; fallback = device zone, with an "in your time" secondary line.
5. `PhoneFormatter`: use `country_picker` (already a dependency) for dial codes; E.164 for storage; display grouped by country (consider `phone_numbers_parser`, **separate approval**).
6. Guard: a unit test that fails if a new `'₹'` literal is added outside the formatter/adapter.
**Language resources:** add `gen-l10n` (`l10n.yaml`, `lib/l10n/app_en.arb`) only for new/migrated screens; keep all current English copy as default; no translations.
**Order:** formatters + Money adapter → migrate Reports/Finance/Dashboard money → dates/times for events → ARB for migrated screens.

## 5. Navigation and role architecture — mapping to the existing structure (no route changes yet)
Current: bottom nav = Dashboard · Peers · Teams · Finance · Reports; app bar = circle switcher, bell, avatar→Profile; Profile → Role Matrix, Circulars.

| Conceptual destination | Today's functions that belong there | Notes |
|---|---|---|
| **Home** | Dashboard hero KPIs, Activity/Asks/Community/Leadership KPI groups, Top 5 Impacters, pending-peers card, celebrations summary | Becomes action-first; data exists |
| **Assigned Scope** | Teams (circle/industry directory, Circle Details, events, sub-industries, leaders), the scope switcher, regional scope, Finance *views* (revenue, collections, deals), Reports history/analytics | Scope = Circle / industry / territory; territory needs backend |
| **Team & Committees** | Peers directory, Circle leaders (Chairs/Founders/Directors), peer profile; committees/Leaders/Project Chairs **not supported by backend** | Committees appear only when assignments exist |
| **Actions & Responsibilities** | Pending Approvals, Recommended Peers, Visitor Registrations, Asks (collaboration/referral/help), Report submission, Record Payment, Commission Setup (role-gated) | Tasks/escalations: **no backend** |
| **Profile & Settings** | Profile, assignments, Role Matrix (Super Admin), Circulars, Notifications, sign-out | Notifications can also stay as a bell |

Proposal: keep five slots; relabel/regroup only after the home and scope modules exist, behind a feature flag, leaving current routes intact (`/teams`, `/finance`, `/reports` aliases already redirect into tabs).

## 6. Role architecture (documentation only)
- **Executive Director** = one role with a **scope** (Area/District/State/Country) taken from the backend assignment; the app today has `districtExecDirector` and `countryDirector` enum values — **keep both backend identifiers and permissions untouched**; only the presentation label may unify ("Executive Director · District").
- **Ambassador**: recognised in the public framework (page `/leadership/ambassadors`, "You carry the name. You carry the trust."; not a numbered stage; no territory text; applies through the generic nomination link). No Ambassador role, permission or assignment exists in the app/backend → **documented only; no dashboard**.
- **Committees:** model as configurable assignments `{assignmentId, kind: committee|project_chair, committeeKey|projectKey, seat: chair|leader, circleId, personId, status}`; committee keys and seat counts come from backend config, **not** hard-coded; project chairs kept separate from standing committees. **Backend support today: none.**
- **Public-site inconsistencies to respect:** Powerhouse "fourteen" vs 3 Chairs + 9 Leaders vs "Nineteen roles" (its own lists total 21); "14 active committees" vs "three committees"; "6 Roles" vs five role profiles. Circle Director is **Stage 003** of the ladder (corrects an earlier note); Circle Founder is a separate role outside the numbered stages.

## 7. Brand and content rules
The prohibited term and brand-rule document referenced in the brief are not in the repository or on the public pages read. Rule applied from now on: UI copy uses Circles, Collaboration, Introductions, Peer relationships, Business growth, Learning/Sales/Resources, Contribution, Life Impact, Leadership, Trust. **Open item:** supply the exact prohibited term(s) so a lint/grep check can be added. Legacy backend identifiers (e.g. `Referrals`/`ReferralsView`, `referral` keys) stay for compatibility; the brand-facing label mapping is a presentation-layer table (to be built with the formatting layer). Existing visible strings such as "Referrals" and "Recommended Peers" should be reviewed against the term once it is known.


## 8. Round 4 additions

### 8.1 Remaining backend requirements — All Circles report roster (approved rules 1–10)
The app cannot apply these rules without data it does not receive today. Required contract (names indicative, to be agreed with the backend):

| Rule | What the app needs from the API |
|---|---|
| 1, 6, 7 Active, approved membership only; exclude pending/rejected/expired/suspended/removed/deactivated | Each Peer-in-Circle record must carry an explicit **membership status** from a documented enum (the real status strings), e.g. `membership: {circle_id, circle_name, status, approved_at, ends_at}`. No status vocabulary exists in the app or the documents today — **no strings were invented**. |
| 2, 3, 4, 5 Unique Peer ID, one row per person, all qualifying Circles, unique-vs-membership counts | `GET /leader/peers` (or a new `GET /leader/reports/roster?circle_id=all`) returning one object per **person** with `circles: [membership…]` plus `meta.total_unique_peers` and `meta.total_memberships`; paging with a reliable `has_more`/`total` so completeness can be verified. |
| 8 Exclude visitors unless report eligibility includes them | A documented report-eligibility rule or a `registration_type`/`eligible_for_reports` flag per Peer. |
| 9 Same rule for preview, generation and export | One backend roster definition consumed by the form preview, `POST /leader/reports` and the export endpoint (`/leader/reports/export`, `/{id}/download`), instead of three client-side code paths. |
| 10 Authorization and scope | The roster endpoint must enforce the caller's scope server-side (DED district scope is documented; other roles unverified). |

Until then the app blocks submission for "All Circles" with the roster breakdown on (see progress doc round 4, item 3) rather than attaching an incomplete list.

### 8.2 Other backend/product dependencies recorded this round
- Revenue: written definition, period and role scope of `dashboard/metrics.overall_revenue` versus `finance/metrics.total_revenue`; confirmation of which is authoritative for the Dashboard.
- Money as `{amount, currency}` instead of pre-formatted strings (the `Money` adapter reads legacy strings only as a bridge).
- Circle IANA time zone (or UTC offset) on Circles and events; `timezone` package approval for daylight-saving-correct conversion.
- A token-refresh endpoint and 401 contract (the app stores a refresh token it cannot use).
- Push payload contract: a stable `route` + `id` schema instead of free-text `screen` strings.
- 403 semantics on verify-OTP (the app treats every 403 as "not a leader").
- Dead code to confirm: `ReportsTrendCard` / `ReportsSplineChart` are not mounted — decide whether the attendance-trend card should be shown (endpoint `/leader/reports/attendance-trend` exists) or removed.


## 9. Round 5 — investigations and backend contracts (2026-11-24)

### 9.1 `ReportsTrendCard` — investigation (kept, not mounted, not removed)
- **Why it is not mounted.** It *was* mounted: `ReportHistorySection` rendered `ReportsTrendCard(attendanceTrend: …)` in commit `2871bc8` (15 Oct 2026) and the next commit `39c86fc` (16 Oct, "implement comprehensive reports feature …") deleted that line; no commit message gives a reason. What remains: `ReportHistorySection` still declares the `attendanceTrend` field (never read), `ReportsView` still passes `state.attendanceTrend` in, and **`ReportsBloc` still calls `GET /leader/reports/attendance-trend` on every load** (plus builds a fallback series from submitted reports using `period.substring(0,3)`, which collides across years and mislabels "Q3 2026"/"Weekly" periods). So the app pays for a request and a computation whose result is thrown away.
- **API.** Documented in `LEADER_APP_COMPLETE_API_DOC.md` #25 and `LEADER_APP_API_DEV_AND_PROD_DOC.md` #16: `GET /api/v1/reports/attendance-trend?circle_id=` → `data: [{month, value}]` (six points, `value` = average attendance %). **Observed on the dev API (device log, 24 Nov):** `{success: true, data: []}` for All Circles *and* for a specific Circle, so the card would render nothing today (`ReportsTrendCard` returns `SizedBox.shrink()` when empty).
- **Value to leaders.** Attendance governance is a named Circle Director responsibility on the public site ("Attendance Governance & Participation Standards"); the store listing promises "attendance trends … interactive graphical charts" and a "Reports & Trends" screenshot (`STORE_LISTING_METADATA.md`); no other screen shows attendance **over time** (History cards show a single report's attendance). So the intent is legitimate and product-supported.
- **Recommendation.** Keep the component and the tested `monotoneSplineControlPoints` utility. Re-mount only after (a) the backend returns ≥ 2 real points for the selected scope, (b) the contract defines All-Circles semantics (average? per-Circle series?), and (c) month keys carry the year (`2026-10`) with the period granularity. Meanwhile stop the wasted call/fallback (a separate, small change: needs your approval). If product abandons the trend, remove the card, chart, fallback and endpoint call together. **Do not show fabricated points.**

### 9.2 All Circles report roster — backend contract proposal
**Facts from the documents (all 13 now read where they define this):**
- `status` on a Peer in `GET /peers` is a **health** value: `Active | Needs Attention | At Risk | Pending` (`API_INTEGRATION_CONTRACT.md` TypeScript type; `BACKEND_API_SPEC_AND_FIXES_DOC.md` §1). It is not a membership status.
- `GET /teams/circles/:id/peers` documents a *different* filter set: `Active | Pending | Inactive` (`CIRCLE_DETAILS_API_DOC.md` §3) and, in another doc, `Active | Needs Attention | At Risk`.
- Membership persistence is described twice with different table names: `circle_peer_memberships(user_id, circle_id, platform_membership_start/end, circle_joining_date, circle_renewal_date, status VARCHAR(50) DEFAULT 'Active', UNIQUE(user_id, circle_id))` and `circle_members`. A Postgres enum **`circle_member_status_enum`** is mentioned, with only two *added* values (`needs_attention`, `under_review`); its base values are never listed.
- **Therefore the status vocabulary (approved / pending / rejected / expired / suspended / removed / deactivated) is not defined anywhere.** No string was invented in the app.
- Roster items already carry dates (`platform_membership_end`, `circle_renewal_date`) but these are dates, not statuses; they must not be turned into an eligibility rule on the client.
- The app sends `included_sections` keys (`p2p_meetings, referrals, deals_closed, testimonials, visitor_registrations, attendance`) that differ from the documented set (`attendance, financials, peer_roster, p2p_meetings, action_items`).

**Proposed contract (names indicative; to be agreed):**
```
GET /api/v1/leader/reports/roster?circle_id=<uuid|all>&report_type=Monthly&period=2026-10
200 {
  "success": true,
  "data": {
    "scope": { "type": "all_circles|circle", "circle_ids": ["…"] },        // server-resolved from the token
    "eligibility": { "rule_version": "2026-11", "included_membership_statuses": ["<real enum values>"],
                     "excludes_registration_types": ["visitor","guest"] },  // published, not guessed by the app
    "peers": [ { "peer_id": "uuid", "name": "…", "company": "…", "designation": "…",
                 "memberships": [ { "circle_id": "uuid", "circle_name": "…", "membership_status": "<enum>",
                                    "joined_at": "2024-03-01", "ends_at": "2025-03-01" } ] } ],
    "meta": { "unique_peers": 63, "qualifying_memberships": 71,
              "excluded_memberships_by_status": { "<enum>": 4 },
              "complete": true, "generated_at": "2026-11-24T12:00:00Z", "snapshot_id": "uuid" }
  }
}
POST /api/v1/leader/reports  { …, "roster_snapshot_id": "uuid" }   // submit references the snapshot, not client-built JSON
GET  /api/v1/leader/reports/export?…&roster_snapshot_id=…          // export uses the same snapshot
errors: 422 ROSTER_INCOMPLETE | 403 UNAUTHORIZED_ACCESS | 404 RESOURCE_NOT_FOUND
```
Requirements: (1) publish the full status enum and which values mean *active, approved*; (2) one record per **person** with `memberships[]` (a Peer in two qualifying Circles = 1 unique Peer, 2 memberships); (3) the server enforces the leader's scope; (4) `complete:false` (timeouts, paging cut-off) must be returned explicitly; (5) one definition shared by preview, report generation and export; (6) `included_sections` vocabulary aligned with the app.
**App behaviour once available:** show "N unique Peers · M Circle memberships" with the Circle names/ids per Peer; the specific-Circle path shows only that Circle's qualifying members; **block submit/export whenever `complete` is false or the roster call fails** (today: blocked for All Circles — preserved).

### 9.3 Revenue and deal figures — what the documents define (still not reconcilable)
- Documented finance fields: `total_collections`, `total_dues`, `projected_annual_revenue`, `deals_closed`, `coin_issuances_total`, `revenue_trend[{month,value,collections_raw,dues_raw}]`, `business_deals[{month,value}]`. The app also reads **`total_revenue`, `circle_revenue`, `commission_due`, `active_tenures`, `circle_budget`, which no document defines**; the dev API evidently returns them (₹72,000 / ₹16,200 / 50 on the device).
- Documented dashboard fields: `overall_revenue` ("₹1.48Cr" — the same sample figure as finance's `projected_annual_revenue` in one document, "₹1.20Cr" in another), `overall_deals_closed` ("₹1.20Cr"), `deals` ("₹86.4L").
- `revenue_trend[].value` is documented in **lakhs** (`45.0`) with the exact rupee amount in `collections_raw`; the dev API returns rupees in `value` (chart peaks at 72,000). Two different projected-annual-revenue samples appear in two documents.
- Conclusion: ₹65,000 (dashboard `overall_revenue`) and ₹72,000 (finance `total_revenue`) cannot be mapped to documented definitions. **Backend must define** each field: what is counted, period, currency, role scope, and which is authoritative for the Dashboard. The app now shows "Unavailable" for a missing revenue or deal value, shows an explicit zero as zero, and never substitutes one metric for another. Other fabricated zeros still present (not changed this round): `circle_leadership_card.dart` `dealsFormatted ?? '₹0'`, and the id-only Peer Profile route builds a placeholder peer with `dealsFormatted: '₹0'` and **`attendance: '90%'`** until details load — relevant to push links that open a Peer by id.

### 9.4 Time zones — implementation, dependency, backend gap
- **Dependency.** `timezone 0.11.2` was already in the tree (transitive via `flutter_local_notifications`). It is now a direct dependency: `pubspec.yaml` +1 line (`timezone: 0.11.2`), `pubspec.lock` **one line changed** (`transitive` → `direct main`), no version change; `intl 0.20.3` unaffected; pure Dart, compatible with Flutter 3.50.0 / Dart ^3.12. Your uncommitted lock changes are intact.
- **Code.** `lib/core/formatting/event_time_zones.dart` (IANA lookup, DST-aware offset **at the instant**, unknown/blank id → `null`, no hard-coded zones) and `AppFormatters.eventTime(startUtc, endUtc, ianaZone, zoneOffset, showZoneId, showViewerTime)`: priority IANA id > fixed offset > device zone; always an explicit `UTC±h[:mm]` label; start and end are resolved separately so an event straddling a DST change shows both offsets; optional "(your time: …)" for a leader in another zone. 16 tests (31 in the formatting folder) including the exact US DST boundaries (06:59:59Z vs 07:00:00Z on 2026‑03‑08, and 2026‑11‑01), London BST, Sydney (southern hemisphere), Kathmandu +5:45, Chatham +12:45, unknown ids. Note: `DateFormat` needs `AppFormatters.initialize()` (it throws `LocaleDataException` otherwise, even for English).
- **Not wired into screens** (visible output would change; needs your go-ahead). English remains the only language.
- **Backend gap.** Events are documented as `date: "2026-09-01"`, `time: "10:00 AM"` — local wall-time strings with **no zone, no IANA id and no UTC instant**; Circle meeting cadence is also zone-less; other documents mix `…Z` and `+05:30` timestamps. Required: `starts_at_utc`/`ends_at_utc` (ISO‑8601 `Z`) and `timezone` (IANA) on events/meetings and on Circles. Until then circle-local times cannot be presented correctly.

### 9.5 Phone numbers — inspection (no dependency added, no stored number touched)
- **Login.** `country_picker` selects the dial code (default `+91` 🇮🇳). The WhatsApp/phone field accepts **digits only and hard-limits input to 10 digits** (`LengthLimitingTextInputFormatter(10)`), so numbers longer than 10 national digits cannot be typed; the identifier sent is `<dialCode><digits>` (E.164‑shaped). `LoginBloc` validates 7–15 digits, and the email channel also accepts `^\+?[0-9]{7,15}$`. No per-country length/format rules.
- **Profile edit / Peer edit.** Free-text fields (`TextInputType.phone`), `trim()` only, **no validation, no country picker**; the profile hint is India-specific (`+91 98765 43210`); the value is sent as typed to `PUT /auth/profile` / peer update.
- **Display.** Raw backend string. `tel:` uses it unmodified; WhatsApp links strip `+`/spaces (peer profile) or only non-digits except `+` (refer sheet: `https://wa.me/+…`, whereas `wa.me` expects digits only [A]). `hide_phone` is respected (shows "Hidden by Peer 🔒").
- **Backend expectation.** E.164 in most examples (`+919876543210`); one example uses spaces (`+91 98765 43210`); `users.phone` and `secondary_mobile` are indexed; `prospect_phone` in referrals is E.164.
- **Sufficient today?** `country_picker` gives dial codes only; it cannot validate or format by country. **Recommendation (only if approved):** `phone_numbers_parser` — pure Dart, v9.0.29 (published 2026‑11‑01), only dependency `meta`, SDK `>=3.0 <4.0`, full pub points — for E.164 parsing/validation/national formatting; lift the 10-digit cap and validate per country. Do **not** rewrite stored numbers; normalise at input and keep display read-only-formatted.

### 9.6 Authentication token refresh — contract status and proposal
- **What the documents say.** `POST /auth/verify-otp` returns `auth_token` (opaque), `refresh_token` (opaque), `token_type: "Bearer"`, `expires_in: 86400` (24 h, all environments); errors: `UNAUTHENTICATED` (401, "missing or expired Bearer token"), `UNAUTHORIZED_ACCESS` (403), `INVALID_CREDENTIALS` (422). **No refresh endpoint, no logout endpoint, and no rotation/revocation/concurrency rules appear in any of the 13 documents** (the word "refresh" occurs only in login responses). **Therefore no refresh logic was implemented — I will not invent an endpoint or token format.**
- **App today.** The refresh token is stored (`SessionManager`, secure storage) and never used; the Dio interceptor only injects the bearer token and logs; a 401 becomes an `UnauthenticatedException` that nothing handles — after 24 h every call fails and the leader must sign out/in manually. Debug builds log request headers (including the bearer token) and response bodies.
- **Required backend contract (proposal).** `POST /api/v1/leader/auth/refresh {refresh_token}` → `{auth_token, refresh_token, expires_in}` (rotate the refresh token; revoke the old one; detect reuse); `401 REFRESH_TOKEN_INVALID|EXPIRED` on failure; `POST /api/v1/leader/auth/logout {refresh_token}` revoking the family; documented refresh lifetime; idempotency header for retried POSTs.
- **Client design ready for when the contract exists.** A `QueuedInterceptor` with a single-flight refresh (one refresh for any number of concurrent 401s; others wait and retry with the new token); retry **once**, only for safe/idempotent requests (GET, or POST with an idempotency key); never intercept the refresh/send-OTP/verify-OTP calls (no loops); persist the rotated pair atomically in secure storage; on a confirmed refresh failure clear the session and route to Login (the notification navigator's `reset()` hook already exists); redact `Authorization` and tokens in logs. **Not implemented**, and a "sign out on any 401" shortcut was not added because it could end your Super Admin session during testing.

### 9.7 Push notification deep links — implemented
- **Before.** Three independent substring routers (push service, local-notification tap, notification-feed tap) that lost entity ids, ignored authentication/readiness (a cold-start tap was dropped or raced Splash), pushed any string from the payload as a route, and had different rules (peers → home tab in one, standalone route in another).
- **Now.** `lib/core/notifications/`: `NotificationPayload` → typed `NotificationDestination` (home tab, notifications feed, profile, role management, **peer profile by id, Circle details by id, report details by id**, none); `NotificationNavigator` (injectable, fully unit-tested) is the single entry for foreground, background, cold-start, local-notification and feed taps (`AppNotificationNavigator.instance`). A tap **waits** until a Navigator exists, the leader is authenticated and the home shell reported ready (`markReady()` from `DashboardView`); the latest pending tap is opened exactly once, discarded after 15 min, dropped on sign-out (`reset()`), and duplicates within 2 s are ignored. Circle/Report destinations fetch by id; a deleted/unavailable entity shows "That Circle/report is no longer available." and opens the feed; an unauthorised destination (checked against the leader's permission flags) shows "You do not have access to that screen." and opens the feed; unknown payload strings are no longer pushed as routes.
- **Payload fields used.** Existing: `route` | `screen` | `click_action`, `type` | `notification_type`, `category`. **Proposed (not currently guaranteed by the backend):** `entity_type` ∈ {peer, circle, report} and `entity_id` — used when present, otherwise legacy behaviour (and the id is lost as before). Note the documents disagree on the notification **list** shape (`message/is_unread/created_at/category` vs `body/is_read/time_ago/type/action_url` with `action_url: "/peers/review/usr_489"`); `action_url` is documented only in one example, so it is **not** parsed.
- **Behaviour changes to be aware of:** the feed's "peer" taps now open the Peers **tab** (as push already did) instead of the standalone Peers route; push taps with `role/tenure/appointed` types now reach Role Management (previously feed only).
- **Required backend contract:** FCM `data` = `{notification_id, type, category, route, entity_type, entity_id}` with a closed `route`/`entity_type` vocabulary; a stable response for deleted entities (404 `RESOURCE_NOT_FOUND`).
- **Verification.** 24 navigator tests + a real-app cold-start test (tap before the widget tree exists → Splash → Home → opens the Reports tab exactly once). Not verified on the device: a real FCM push cannot be sent from here.

### 9.8 Brand vocabulary check (new)
- The approved prohibited term is **[prohibited term]**; `README.md` §9 ("Critical Vocabulary Rule", which I had missed earlier — I wrongly reported the rule was not in the repo) additionally forbids `member`/`members` and `network`, listing replacements (Peers/Leaders/Circle Participants/Executives; Circle Ecosystem/Collaboration/Community/P2P Connections).
- `test/content/brand_vocabulary_test.dart` **fails the build** if "[prohibited term]" appears in any Dart string literal under `lib/` or in README/`documents/**/*.md` (comments, identifiers and snake_case backend keys such as `speed_networking` are not scanned; allowlist: one icon-matching literal against backend event titles, the README's own rule text, one verbatim API payload sample). It also prints (never fails) how many user-facing strings still contain the README-only words: **34 with "member(s)", 5 with "network"** (e.g. "Circle Members", "No Member Events", "Please check your network"). Enforcing those is a copy decision for you; no user-facing copy was changed.

### 9.9 Backend documents — reading status (honest)
Read **in full**: `SUPER_ADMIN_ROLE_MATRIX_API_DOC`, `BACKEND_API_SPEC_AND_FIXES_DOC`, `CIRCLE_DETAILS_API_DOC`, `backend_api_specification`, `API_INTEGRATION_CONTRACT`, `STORE_LISTING_METADATA`, `BACKEND_DED_AND_INDUSTRIES_API_DOC` (§1–3), `LEADER_APP_NEW_CHANGES_DOC` (all). Read **in part** (the parts that define auth, permissions, notifications, finance, reports, events, errors and DDL; the rest are near-duplicates of the documents above): `LEADER_APP_COMPLETE_API_DOC` (~85 %: all but the role-matrix CRUD and sub-industry samples), `LEADER_APP_API_DEV_AND_PROD_DOC` (~20 %: environments, auth, permission matrix, error envelope, test flow; its endpoint sections duplicate `COMPLETE`), `BACKEND_API_AND_PERMISSIONS_DOC` (~25 %: matrix, notification and role endpoints), `BACKEND_API_PENDING_ENDPOINTS_DOC` (gap table + first endpoints), `LEADER_APP_ASK_FLOWS_API_DOCUMENTATION` (~25 %: endpoint table, summary, integration guide; the ~640 lines of master-data JSON were not read). Contradictions found between documents: the permission matrix differs (`can_review_pending_peers` is `true` for Super Admin in `COMPLETE`, `false` in `DEV_AND_PROD`/`PERMISSIONS`; 21 documented flags vs 22 in the app); role capability counts (12 documented vs 13 shown); status vocabularies (§9.2); notification list shape (§9.7); `projected_annual_revenue` samples (§9.3); paths with and without the `/leader` prefix; phone with and without spaces.


---

## 10. Phase 3 continuation — full backend documentation audit (13 / 13 complete, 2026-11-24)

All 5 previously partially-read backend documents were read in full from line 1 to EOF:

| Document | Lines Read (1–EOF) | Primary Scope |
|---|---:|---|
| `LEADER_APP_COMPLETE_API_DOC.md` | 1,146 | 37 endpoints (`/api/v1/...`), 21-flag matrix (5 cols), 12 Web RBAC capabilities, Postgres DDL |
| `LEADER_APP_API_DEV_AND_PROD_DOC.md` | 1,017 | 26 endpoints (`/api/v1/...`), 7-role × 21-flag matrix, Tab 0–5 UI breakdown, error envelope |
| `BACKEND_API_AND_PERMISSIONS_DOC.md` | 916 | 25 endpoints (`/api/v1/...`), 7-role × 17-row matrix table, JWT auth spec, error envelope |
| `BACKEND_API_PENDING_ENDPOINTS_DOC.md` | 345 | 10-row gap matrix (later folded into `COMPLETE`), partial payload specs |
| `LEADER_APP_ASK_FLOWS_API_DOCUMENTATION.md` | 841 | 8 Ask discovery read endpoints (`/api/v1/leader/asks/...`) + 2 write endpoints (`/api/v1/asks`) + master data JSON |

### 10.1 Verified backend contradictions across the 5 completed docs
- **Route prefix drift:** Docs 1–4 document `/api/v1/auth/...`, `/api/v1/dashboard/...`, `/api/v1/peers/...` without `/leader`; Doc 5 uses `/api/v1/leader/asks/...` for reads and `/api/v1/asks` for writes; the Flutter app uses `/api/v1/leader/...` across core modules.
- **Permission matrix drift:** `can_review_pending_peers`, `can_add_edit_peer`, `can_assign_circle_chair`, `can_issue_coins`, `can_submit_reports`, and `can_export_financial_data` conflict between `COMPLETE` (5 role columns, omitting `Country Director`) and `DEV_AND_PROD` / `PERMISSIONS` (7 role columns).
- **Peer profile schema drift:** `COMPLETE` returns nested `contact{}` + `metrics{}`; `DEV_AND_PROD` and `PERMISSIONS` return flat fields (`phone`, `email`, `intro_video_url`, `testimonials[]`, `referrals[]`).
- **Notifications schema drift:** `COMPLETE` returns `{body, type, is_read, time_ago, action_url}` and marks read via `{notification_id, mark_all}`; `DEV_AND_PROD` / `PERMISSIONS` return `{message, category, is_unread, created_at}` and mark read via `{notification_ids: [...] | ["all"]}`.
- **Ask Flows create contract mismatch:** `POST /api/v1/asks` requires `answers[].option_id` (UUID), while `GET /api/v1/leader/asks/form-config` option objects return only `{code, label, sort_order}` without `id`/`option_id`. Also `sections` vs `sections_layout` and `option_groups` vs `groups` differ between `/flows/{flow}` and `/form-config`.
- **Token format & staging URL drift:** Sanctum pipe tokens (`14|...`) in Docs 1–2 vs JWT in Doc 3; staging URL `dev.peersunity.com` vs `staging-api.peersunity.com`.

### 10.2 Confirmed missing backend contracts (explicitly absent across all 13 docs)
1. **Authentication lifecycle:** No token refresh endpoint, no logout endpoint, no token rotation/revocation contract, no `GET /auth/me` or `GET /auth/permissions` re-sync endpoint, no OTP rate-limit/unregistered-user status contract.
2. **Membership status vocabulary & All Circles roster:** No authoritative `circle_member_status_enum` base value list (only `needs_attention` and `under_review` DDL additions); no multi-circle roster endpoint returning `unique_peers` vs `qualifying_memberships` with completeness guarantees.
3. **Event timestamps & timezones:** Events carry split local `"date"` and `"time"` strings with no ISO-8601 `starts_at_utc`/`ends_at_utc` and no IANA `timezone` field on events or Circles.
4. **Pagination metadata:** Zero response pagination envelope (`total`, `page`, `per_page`, `has_more`, `last_page`) documented anywhere; query params vary (`page`/`limit` vs `page`/`per_page` vs `page` only).
5. **Financial contracts:** Read endpoints return pre-formatted INR strings (`"₹1.48Cr"`, `"₹86.4L"`) with no numeric amount + ISO-4217 currency code; no `GET /finance/commission-rates` endpoint; `dashboard/metrics.overall_revenue` vs `finance/metrics.total_revenue` remain undefined.
6. **Attendance trend:** `GET /reports/attendance-trend` returns month abbreviations (`"Feb"`) with no year, granularity, or All-Circles aggregation rule; dev API currently returns `data: []`.
7. **Push notifications:** `entity_type` / `entity_id` deep-link payload fields are proposed frontend contract fields, not guaranteed by backend docs; push token registration/unregistration is absent from Docs 1–5.
8. **RBAC-referenced write endpoints:** Missing specs for pending peer approve/reject, peer CRUD, circle/chair management, coin issuance, report approve/reject, Export Center, and Ask response/match/detail/close flows.
