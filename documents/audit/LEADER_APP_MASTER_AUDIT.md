# LEADER APP — MASTER AUDIT

Version 3 · 2026-11-24 · Branch `api-integration` (unchanged) · Labels: **[V]** verified · **[O]** observed · **[A]** assumption · **[G]** backend gap · **[R]** recommendation
(v3 note: this file was rewritten in full after an accidental truncation during an edit; content is the v2 text plus the round-3 corrections marked "round 3".)

## 1. Repository state (protected, untouched)

Modified before this audit (not by it): `android/gradle/wrapper/gradle-wrapper.properties` (Gradle 9.1.0→9.3.1), `android/settings.gradle.kts` (AGP 9.0.1→9.1.1), `circle_details_hero_card.dart` (fallback banner now the `peers_unity_cover_logo.png` asset with a gradient overlay), `teams_model.dart` (many more cadence JSON key fallbacks; `effectiveCoverUrl` no longer falls back to the circle logo and returns null when cover == logo; `cover_photo_url` added), `teams_circle_card.dart`, `pubspec.lock` (dart constraint `>=3.13.0-0`, `listen 1.0.1` added, three package bumps). Untracked: `android/build/`, `assets/images/peers_unity_cover_logo.png`.
Repo root also holds `hs_err_pid*.log` and `replay_pid*.log` (JVM crash logs). `git check-ignore` confirms they are already ignored via `*.log` [V]. `android/build/` is **not** ignored: the root `.gitignore` only has `/build/` and `/android/app/{debug,profile,release}`, and `android/.gitignore` ignores `/.gradle`, `/captures/`, `/local.properties`, `gradle-wrapper.jar`, keystores but has **no `/build/` entry** [V]. [R] add `/build/` to `android/.gitignore` when you decide to. Nothing was deleted or changed.
Round 3 source changes are listed in the progress document (3 source files, 3 new test files); everything else is new files under `documents/audit/` and `.claude/skills/`, all untracked and unstaged.

## 2. Foundation [V]

- Flutter 3.50.0 stable, Dart `^3.12.0`, app id `com.unity.leadersapp` (debug runs as `com.unity.leadersapp.dev`), version 1.0.0+4, Shorebird configured.
- Boot: `main.dart` → portrait lock → `Firebase.initializeApp` → Hive cache + Lottie preload (parallel) → `SessionManager.loadPersistedSession()` → `PushNotificationService.initialize()` → `App`.
- `app.dart`: `MaterialApp`, **`themeMode: ThemeMode.light` only**, Material 3 seeded from `AppColors.primary`, LibreFranklin font, global `navigatorKey`, custom `SmoothPageTransitionsBuilder`, named routes through `AppRoutes.onGenerateRoute`.
- Startup flow (round 3, `splash_view.dart`): Splash (min ≈2.7 s: `SplashBloc` delay + Lottie) → `AppConfigService.fetchAppConfig()` (errors swallowed) → maintenance gate / force-update / optional update → `/home` if `SessionManager().isAuthenticated` else `/login`.
- No dependency-injection container: BLoCs are created in views (`BlocProvider(create: …)`), repositories are instantiated directly (`TeamsRepositoryImpl()`, `PeersRepositoryImpl()`), `SessionManager` is a singleton. Exception: `LoginBloc({AuthRepository? authRepository})` accepts an injected repository (used by the new tests).
- Dependencies: flutter_bloc, dio, flutter_secure_storage, hive/hive_flutter, firebase_core, firebase_messaging, flutter_local_notifications, lottie, video_player, upgrader, in_app_update, country_picker, permission_handler, url_launcher, equatable (plus share_plus/pdf per the engineering report, not re-verified). **Absent:** `intl`, `firebase_auth`, `cloud_firestore`, any chart package, any DI package, any localization package.
- Firebase usage is **messaging only** (push); auth is the app's own OTP REST flow; no Firestore/Storage/Analytics/Crashlytics calls found [V by dependency list; code-level grep not exhaustive].
- Architecture per feature: `bloc/ model/ presenter/ view/(widgets)`, shared `data/repositories/*` (10 repositories) and `data/datasources/{local,remote}`, `core/*`. 386 Dart files, 24 feature folders. Conventions are consistent enough to extend without a new pattern.
- Offline: Hive cache with repository-level fallback on network error (`getPeers`, dashboard/finance metrics, peer details) and a "Loaded from offline cache" message; stale data is **not** marked in the UI [V code, O].
- Environments: `AppEnvironment {dev, local, staging, prod}`; default **dev** unless `--dart-define=ENV=`; the audited device build was on dev [V].
- Auth/session: OTP via `/leader/auth/send-otp` + `/verify-otp`, token in secure storage, profile + capabilities via `/leader/profile`.
- Not traced yet: Dio interceptors / token refresh inside `core/network/api_client.dart`; push deep-link routing.

## 3. Feature inventory [V]

24 feature folders; file counts: peer_profile 38, circle_details 29, reports 25, profile 18, finance 17, login 17, dashboard 16, role_management 14, peers 13, teams 13, splash 11, member_activities 10, otp 10, testimonials 10, notifications 9; business_deals, circulars, impacts, leader_activities, maintenance, p2p_meetings, peers_by_coins, referrals 8 each; requirements 7.
Routes: splash, login, otp, home (tabs: dashboard, peers, teams, finance, reports), profile, peers, peer-profile, peer-collaboration, testimonials, referrals, peers-by-coins, impacts, p2p-meetings, business-deals, requirements, leader-activities, circle-details, circle-peers, circle-sub-industries, circle-events, circle-overview, role-management, circulars, maintenance, report-details, notifications. Aliases: `/teams`,`/circles`→tab 2, `/finance`→3, `/reports`→4.
Bottom navigation (5): Dashboard · Peers · Teams · Finance · Reports. Role management lives under Profile. Tab visibility is driven by capability flags.

## 4. Feature-to-backend mapping

| App feature | Endpoints in `api_endpoints.dart` | Documented in `documents/` | Notes |
|---|---|---|---|
| Auth/profile | `/leader/auth/send-otp`, `verify-otp`, `/leader/profile` (GET/PUT), `/leader/auth/profile/avatar` | LEADER_APP_COMPLETE_API_DOC, BACKEND_API_AND_PERMISSIONS_DOC | Docs mix `/auth/...` and `/leader/auth/...` prefixes → [G] confirm canonical paths |
| Dashboard | `/leader/dashboard/metrics`, `/top-impacters`, `/leader/asks/summary`, `/admin/pending-requests(+summary)`, `/leader/pending-requests/*` | yes | revenue definitions undefined [G] |
| Peers | `/leader/peers`, `/celebrations`, `/{id}`, `/{id}/meetings`, `/{id}/activities`, `sendWish`, `/members/*` | yes | |
| Teams/circles | `/leader/teams/{summary,circles,industries}`, `/circles/{id}[/peers,/sub-industries,/events,/refer-category]` | CIRCLE_DETAILS_API_DOC, DED_AND_INDUSTRIES | cadence JSON shape not pinned |
| Finance | `/leader/finance/{metrics,transactions,milestones}`, commission rates (PUT), offline transaction (POST) | yes | |
| Reports | `/leader/reports(+/{id},/export,/attendance-trend,/{id}/download)` | yes | |
| Activities | impacts, p2p-meetings, business-deals, requirements, referrals, testimonials, peers-by-coins, `leaderActivitiesByType` | ASK_FLOWS doc | |
| Asks/collaboration | `/leader/asks/*` | LEADER_APP_ASK_FLOWS_API_DOCUMENTATION | |
| Roles/RBAC | `/leader/roles`, `/leader/roles/matrix`, `/roles/{id}` | SUPER_ADMIN_ROLE_MATRIX_API_DOC | |
| Notifications/push | `/leader/notifications(+unread-count,mark-read,mark-all-read)`, `/leader/push-token`, `/push-tokens` | yes | |
| Circulars | `/circulars`, publish | partial | |
| App config | `/leader/system/app-config` | yes | drives maintenance/force-update |
| **Tasks / commitments** | none | none | **[G]** |
| **Committees / Powerhouse seats** | none | none | **[G]** |
| **Territory / geography tree** | none (only `regional_scope` string, `managed_circles`) | DED doc says district scoping happens server-side | **[G]** |
| **Leader meeting agenda/attendance** | circle events list only; member attendance endpoints | partial | **[G]** |
| **Appointments / tenure history** | none (only "Active Leadership Assignment" label, "Leadership Tenures" count) | none | **[G]** |
| **Multi-assignment scope switching** | circle filter only | none | **[G]** |
| **Escalations** | none | none | **[G]** |

## 5. Documentation read

Read in full: `SUPER_ADMIN_ROLE_MATRIX_API_DOC.md`, `LeaderApp_Engineering_Work_Report.pdf` (below). Read in part (headings, role matrix, DED section, gap table, delta changes first 200 lines): `BACKEND_API_AND_PERMISSIONS_DOC.md`, `BACKEND_DED_AND_INDUSTRIES_API_DOC.md`, `BACKEND_API_PENDING_ENDPOINTS_DOC.md`, `LEADER_APP_NEW_CHANGES_DOC.md`. **Skimmed only by title/grep, not read through:** `API_INTEGRATION_CONTRACT.md`, `BACKEND_API_SPEC_AND_FIXES_DOC.md`, `CIRCLE_DETAILS_API_DOC.md`, `LEADER_APP_API_DEV_AND_PROD_DOC.md`, `LEADER_APP_ASK_FLOWS_API_DOCUMENTATION.md`, `LEADER_APP_COMPLETE_API_DOC.md`, `STORE_LISTING_METADATA.md`, `backend_api_specification.md`.
Key doc facts: backend permission matrix covers 7 roles × 17 `can_*` flags; DED scope = district (`District ➔ 18 Industries ➔ Circles ➔ Peers`), scoped by token server-side; a 12-capability dynamic matrix replaces static flags when the API returns `enabled_capabilities`.
**`LeaderApp_Engineering_Work_Report.pdf` — read in round 3 with `pdftotext -layout`** (my earlier statement that it could not be extracted was wrong: I had tried `pdftoppm` and a raw-stream regex). Poppler reports a damaged xref table and reconstructs it; 4 pages extracted, page 2 contains only header/footer. Content (15 Oct 2026, "Last 13 Days"): a 25-endpoint integration register (paths shown as `/api/v1/peers`, `/api/v1/finance/metrics`, whereas the code uses `/leader/peers`, `/leader/finance/metrics` → the report's paths are stale or abbreviated); module notes (auth, reports + client-side PDF/CSV export via `share_plus`, Circles & Teams UI, case-insensitive search, `life_impacted_count`); five bug write-ups (release APK defaulted to prod → now dev; search case; impact count; export stubs; controller leak); claims "0 errors, 0 warnings" and "100% MVP + BLoC adherence". Notes: (1) current analyze shows 3 warnings, all in the uncommitted `teams_model.dart`; (2) the report cites a **"Rulebook Rule 4"** (controller lifecycle) — an engineering rulebook exists but is **not in the repository**; [R] please share it; (3) it states mock fixtures were eradicated, yet the old smoke test still exercised mock data (replaced in round 3).

## 6. Official leadership framework reconciliation (website fetched 2026-11-24)

Pages read: /leadership, /circle-roles, /leadership/circle-director, /leadership/circle-founder, /leadership/apply, /circles/purpose, /how-to-earn-impact, /our-story, and (round 3) /leadership/ambassadors. Full detail in the role matrix document. Headlines:
- Six-stage ladder: 001 Foundation ("Begin With Contribution") → 002 Circle Committee ("The Powerhouse") → 003 Monthly Leadership (**Circle Director**) → 004 City Sector Owner (Industry Director) → 005 Regional Builder (Executive Director: Area → District → State → Country) → 006 Ecosystem Steward (Global Leadership). **Circle Director is on the ladder (Stage 003)** — an earlier note saying otherwise was wrong; **Circle Founder** is a separate role outside the numbered stages ("Role 03 of 05"). The site says it is "not designed as a race toward a higher position".
- Internal contradictions on the site: Powerhouse "fourteen" vs 3 Chairs + 9 Leaders = 12 vs "Nineteen roles" (its own lists total 21); "14 active committees" vs "three committees"; "6 Roles" vs five role profiles; "18 Circles" vs "45+ Cities". [R] **do not hard-code any count.**
- **Ambassador** has its own page, `/leadership/ambassadors` ("You carry the name. You carry the trust."): not part of the six-stage ladder or the five-role table, no territory/scope wording, eight activities (Connect Relevant Founders, Authentic Introductions, Carry the Spirit, Share Real Stories, Create Opportunity Bridges, Warm Hospitality, Spot Valuable Contribution, Strengthen Confidence), "This is not a sales role", apply via the generic `/leadership/nominate` link. `/leadership` does not mention it. The app has no Ambassador role/permission/assignment → documented only; no dashboard until the backend defines one.
- "Bilateral confirmation" wording is not on the site; the rule is receiver confirmation in the Unity App ("Anything the receiving Peer has not confirmed … counts for zero"). Attendance does not earn impact.
- Brand lines: "Peers are Partners in Business and Friends in Life", "Lead by serving. Grow by contributing. Influence by earning trust." **Correction (round 5):** the vocabulary rule *is* in the repository — `README.md` §9 "Critical Vocabulary Rule" forbids `member`/`members` and `network`/`[prohibited term]` (use Peer/Leaders/Circle Participants/Executives and Circle Ecosystem/Collaboration/Community/P2P Connections). The approved prohibited term is **[prohibited term]**; it is now enforced by `test/content/brand_vocabulary_test.dart`. The "Rulebook Rule 4" engineering rulebook is still not available.

## 7. Baseline and current checks [V]

- **Baseline (before changes):** `flutter analyze --no-pub` 249 issues (246 `info` `deprecated_member_use` — `package:flutter/material.dart` deprecated since 3.47 — and 3 `warning` `unnecessary_non_null_assertion` in `teams_model.dart:269,271,273`, in the pre-existing uncommitted diff). `flutter test --no-pub` 17 passed / 1 failed (stale smoke test).
- **After round 3:** analyze 250 issues (+1 info, same deprecation, in a new test file; no new warnings/errors); tests **51 passed / 0 failed**.
- Android debug build: round 3 ran `flutter run --no-pub --no-resident --debug` successfully (AGP 9.1.1 / Kotlin 2.4.10 warnings: Flutter says support will soon be dropped and asks for AGP ≥ 9.3.1 and Kotlin ≥ 2.4.20; `firebase_core` and `package_info_plus` apply the Kotlin Gradle Plugin — future-Flutter build risk). Pre-existing, not fixed.
- Environment: C: drive was full during round 3 (see progress doc).

## 8. Repo-level risks

| ID | Risk | Evidence |
|---|---|---|
| R1 | Light theme only; no dark theme, no text-scale handling (0 `textScaler` uses), no reduced-motion handling, 0 `Semantics` widgets | V (grep) |
| R2 | No `intl`/localization; ₹ in 40 files (92 occurrences); English month-name tables; dates converted to **device** timezone, not the circle's | V |
| R3 | Role parsing by substring match in `UserRole.fromLabel`; app roles don't match the website | V |
| R4 | `package:flutter/material.dart` deprecated across the code base: mechanical migration when the SDK removes it | V |
| R5 | `CircleCadenceModel.fromJson` guesses ~10 alternative key paths per field → backend contract unpinned | V |
| R6 | Test-data scrubbing and fabricated defaults in production code (`isDummyPeer`, `activeTenures ?? 42`, `member_since ?? 'Aug 2026'`, `capabilities_count ?? 14`, revenue→deals fallback) | V |
| R7 | `test/data` empty; few BLoC tests (login now covered) | V |
| R8 | Phone/email displayed unmasked on profile screens | O |
| R9 | Stale offline data is not labelled | V code |
| R10 | `android/build/` not git-ignored | V |
| R11 | AGP/Kotlin/KGP-plugin build warnings (see §7) | V |

## 9. Traced source findings (round 3)
Exact service methods, response fields and fallbacks for dashboard revenue, finance revenue, reports roster, profile assignment labels, Circle Details leader classification, cadence duplication, the fabricated tenure default and the notification unread count are in `LEADER_APP_ARCHITECTURE_PROPOSALS.md` §1.

## 10. Still open
Dio interceptor/token-refresh and push deep-link traces; Login/OTP/Splash/Maintenance visual audit (needs a second device/account — the Super Admin session must not be signed out); nested screens not yet opened (see screen audit §1); 8 of 13 docs read only by headings; the engineering "Rulebook" and prohibited-term list.
