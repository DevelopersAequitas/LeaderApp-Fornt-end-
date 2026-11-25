# LEADER APP — IMPLEMENTATION ROADMAP

Version 1 · 2026-11-24 · Status: **proposal awaiting approval; no application source has been changed.**
Rules for every phase: stay on `api-integration`; no reset/clean/stash; no staging/commit/push without approval; do not touch the existing uncommitted Android/Teams/Circle changes except where a task says so (and then ask first); no invented endpoints/fields; dev API only; update `LEADER_APP_IMPLEMENTATION_PROGRESS.md` after each phase.

## Phase 0 — Safety and baseline (done in audit; items to close)
- 0.1 Baseline recorded (analyze 249 issues; tests 17/18) ✔ — see master audit §7.
- 0.2 Decide ownership of the 3 `unnecessary_non_null_assertion` warnings in the uncommitted `teams_model.dart` (they're yours; I will not touch without approval).
- 0.3 Read the PDF report and the 8 docs only skimmed; obtain the brand-rules/prohibited-terms document. *(blocking for copy only)*
- 0.4 Add `/build/` to `android/.gitignore` — **needs your OK** (config change).

## Phase 1 — Trust fixes (small, independent; each its own change) 
| # | Task | Files (expected) | Risk | Test |
|---|---|---|---|---|
| 1.1 | Fix 15 px overflow in Report Activity Inclusion header (`Wrap`/`Flexible`) | `report_submit_section.dart` | low | widget test at 360 dp, text scale 1.3 |
| 1.2 | Monotone spline (or clamp control points to baseline) so charts never dip below the data range | `finance_spline_chart.dart`, `reports_spline_chart.dart` | low | painter unit test: all path y ≥ baseline for the Sep/Oct data |
| 1.3 | Roster load for "All Circles": reuse the export service's fallback (global peers endpoint) or hide the roster block and show an explicit "select a circle" state; **do not submit an empty roster silently** | `reports_bloc.dart`, submit section | medium (business behaviour) | bloc test |
| 1.4 | Notification count single source (bell, header chip, feed) | `notification_count_service.dart`, `notifications_view.dart` | medium | bloc/service test |
| 1.5 | Label revenue figures with definition+period; remove revenue→deals fallback and `activeTenures ?? 42` default (show "—") | dashboard hero, finance model | **business-rule adjacent: needs approval** | model tests |
| 1.6 | Fix stale smoke test to the splash/login flow | `test/app_smoke_test.dart` | low | test |
**Exit:** analyze unchanged or better; tests green.

## Phase 2 — Foundation: tokens, theme, formatting (no visual redesign yet)
- 2.1 Merge `AppColor`/`AppColors` into one token source (aliases preserved).
- 2.2 `AppTheme.light()` + `AppTheme.dark()`; `themeMode: system` behind a setting; fix hard-coded white nav bar.
- 2.3 `core/formatting/` — `MoneyFormatter`, `NumberFormatter`, `DateFormatter`, zone-aware time; add `intl` (**dependency change: needs approval**) and `gen-l10n` skeleton with `en`.
- 2.4 Replace ₹/L/k literals with formatters incrementally (grep-gate test).
- 2.5 Shared `EmptyState/ErrorState/OfflineBanner/StaleDataChip/ConfirmSheet`, `AnimatedNumber`, chart module.
**Depends on:** 0.x; **Exit:** goldens for new widgets in light/dark/scale 1.5.

## Phase 3 — Role-aware information architecture
- 3.1 Backend contract draft for `assignments[]`, geography, timezone, money, cadence (see matrix & global docs) → hand to backend. *(blocks 3.3+ for full fidelity)*
- 3.2 `LeaderContext` (active assignment) in `SessionManager` with a safe fallback to today's behaviour when `assignments[]` is absent.
- 3.3 `LeaderIdentityHeader` + `RoleScopeSelector` replacing the circle pill (works with existing `managed_circles` meanwhile).
- 3.4 Navigation proposal finalised with you (Home / My Scope / People / Actions / More) after feature inventory sign-off.

## Phase 4 — Leadership Command Center (Home)
Compose from modules: Needs-your-action (pending peers, pending approvals — data exists), Upcoming meetings (circle events — exists), Circle/scope health (attendance trend, peers — exists), Contribution & impact (impacts, confirmed state), Updates (circulars/notifications). Modules for Committee/Tasks/Territory render **only when the backend provides data** (no placeholders with invented numbers). Per-role module sets from the matrix, behind capability flags.

## Phase 5 — Operations screens
- Teams/Circles: compact `CircleSummaryRow`, search+filters, health; Circle Details: single cadence block, correct leader sections, localized times.
- Peers: `PersonTile`, filter chip row fix, privacy masking.
- Activity lists: keep the summary+2-tab pattern; consistent money/number formatting; confirm sheets on Accept/Reject.
- Profile: assignments grouped by role/scope.
- Blocked/waiting on backend: Committees, Tasks, Escalations, Appointment history.

## Phase 6 — Impact and reporting
Contribution views with confirmation state; Finance KPI semantics and chart module; Reports form restructure (stepper), history with formatted metrics; leader-specific summaries.

## Phase 7 — Motion and polish
`AnimatedNumber` on KPIs (animate from previous value, not on placeholders), chart entrance animations per design-system tokens, press feedback, skeleton → content cross-fade, reduced-motion support, Semantics.

## Phase 8 — Global readiness
Locale switch (`en`, `hi`), currency/time-zone matrix tests, phone formatting, RTL smoke, text scale 1.5.

## Phase 9 — QA
`flutter analyze`, unit/bloc/widget tests, device runs on 360×800, 411×914 and a tablet-size window, dark mode, offline, slow/failed API, long text; performance profile (jank on charts); regression walk of every route in the screen inventory.

## Dependency graph (short)
0 → 1 (parallel tasks) → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9. Backend contract work (3.1) should start now and run in parallel; Phases 4–6 degrade gracefully without it.

## Approvals needed before coding (explicit)
1. Which Phase 1 items to start with (suggest 1.1, 1.2, 1.6 first — no business-rule impact).
2. Business-rule items (1.3, 1.5): the intended behaviour.
3. Adding `intl` and `flutter_localizations`.
4. Navigation structure and role-module sets.
5. Ambassador role and committee/leader seat model.
