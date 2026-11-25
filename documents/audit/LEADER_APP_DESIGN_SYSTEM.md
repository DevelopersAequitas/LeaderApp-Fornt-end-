# LEADER APP — DESIGN SYSTEM (proposal built on what exists)

Version 1 · 2026-11-24 · Status: **proposal; no source has been changed.** Labels: **[V]** existing in code · **[P]** proposed

## 1. What exists today [V]

- **Colour:** two overlapping files — `core/theme/app_colors.dart` (`AppColors`: primary `#1D4ED8`, pink `#E11D48`, text `#1A2535`, background `#F9FAFC`, semantic success/warning/danger/info + bg + border, chart colours) and `core/theme/app_color.dart` (`AppColor`: same brand colours, plus a complete **light and dark** token set — `darkBackground #12141A`, `darkSurface #1E222D`, `darkTextPrimary` …, gradients, extended semantics). Several names exist in both with different values (`text` `#1A2535` vs `#0F172A`, `background` `#F9FAFC` vs `#F6F9FD`, `success` `#2E7D32` vs `#10B981`). The dark tokens are **not wired to any theme** (`themeMode: light`).
- **Type:** `AppTypography` (LibreFranklin): display 28/24, title 20/16/15, body 14/13/12, label 13/12/11; weights 400–600. Several screens override sizes inline (e.g. 9–13 px captions in the hero card).
- **Spacing/radius:** `AppSpacing` xs4 sm8 md16 lg20 xl24 xxl32; radius 8/12/16/pill.
- **Shared widgets (`core/widgets`):** `stat_card`, `status_pill`, `segmented_control`, `horizontal_selection_chips`, `search_text_field`, `app_shimmer`, `centered_loading_indicator`, `restricted_access_card`, `primary_button`, `custom_app_bar`, `initials_avatar`, `expandable_text`, `gradient_widgets`, `three_d_number_display` (image-digit counters), `star_rating_display`, `detail_row`.
- **Motion:** page transition 240 ms / 200 ms reverse (`AppPageRoute`); 8 files use `TweenAnimationBuilder`/`AnimationController` (finance spline entrance uses an `animationProgress`); shimmer skeletons per feature.
- **Charts:** custom `CustomPainter` splines in Finance and Reports; no tooltip library.

## 2. Direction [P]

Calm, premium, trustworthy: white/very light surfaces, one brand blue as the action colour, the pink only as a secondary accent (gradient used for primary buttons, selected pills, and nothing decorative), generous but compact rhythm. Reduce saturated full-bleed gradient tiles (Dashboard hero) to a restrained KPI strip; use colour for status and data, not decoration.

### 2.1 Tokens (merge into one file; keep current names as aliases to avoid a big-bang rename)
| Group | Tokens |
|---|---|
| Brand | `brandBlue #1D4ED8`, `brandRose #E11D48`, `brandGradient` (buttons/selected only) |
| Surface (light) | `bg #F6F9FD`, `surface #FFFFFF`, `surfaceSubtle #F1F5F9`, `border #E2E8F0` |
| Surface (dark) | existing `AppColor.dark*` tokens, wired through `ThemeData.dark` |
| Text | `text #0F172A`, `textSecondary #475569` (raise from `#64748B`/`#8B9CB4` to pass 4.5:1 on white), `textMuted #64748B` for metadata ≥ 12 px only |
| Semantic | success `#0F7A50`, warning `#B45309`, danger `#C62828`, info `#1A73E8` with matching 8 % tint backgrounds |
| Data colours | 6 categorical colours colour-blind-safe; status colours are not reused as categories |
| Radius | 8 (chips), 12 (rows/inputs), 16 (cards), pill |
| Elevation | none by default; 1 hairline border; 2 levels of shadow for sheets/menus only |
| Spacing | 4-pt grid: 4, 8, 12, 16, 24, 32; page gutter 16; section gap 24 |

Contrast check [V by observation of screenshots, formal check pending]: secondary text `#8B9CB4` on white is ≈ 2.8:1 (fails AA) — used for subtitles throughout the app today.

### 2.2 Typography scale [P]
| Role | Size/weight | Use |
|---|---|---|
| Display | 28/600 | screen hero numbers only |
| Page title | 22/600 | app-bar titles (current 18–24 mixed) |
| Section | 16/600 | section headings |
| Body | 14/400 (min body 14) | primary reading text |
| Secondary | 13/400 | descriptions |
| Label | 12/600 | chips, field labels (no 9–11 px) |
| Metric | 24–32/600, tabular figures | KPIs (`FontFeature.tabularFigures`) |
All sizes respect text scale; tiles use `Flexible`/`FittedBox` with min size, not clipping.

### 2.3 Components [P — reuse first]
| Component | Basis | Notes |
|---|---|---|
| `LeaderIdentityHeader` | new, uses `initials_avatar` | name, role, scope breadcrumb, tenure; opens scope switcher |
| `RoleScopeSelector` | replaces the "All Circles" pill | shows assignment role+scope; sheet lists assignments |
| `LeadershipKpiCard` + `AnimatedNumber` | `stat_card` + new | value, unit, delta, period, tap target ≥ 48 px |
| `ActionTaskCard` | new | "Waiting for my action / for another leader / escalated" |
| `CircleSummaryRow` | replaces `teams_circle_card` list use | 72 px row: logo, name, industry, status pill, health |
| `UpcomingMeetingCard` | new | local-to-circle time + viewer time |
| `PersonTile` | unify peer/impacter/leader rows | one row layout, verified tick, no all-caps |
| `StatusPill` | existing | semantic colours from tokens |
| `FilterChipRow` | `horizontal_selection_chips` | fix edge overflow, add fade/scroll cue, single "All" |
| `MoneyText`/`NumberText` | new | all formatting through the locale formatter |
| `EmptyState`, `ErrorState`, `OfflineBanner`, `StaleDataChip` | new, share one API | message, cause, action |
| `LoadingSkeleton` | `app_shimmer` | skeleton must mirror final layout; max ~1.5 s before showing "still loading" |
| `ChartCard` + `SplineChart`/`BarChart`/`DonutChart` | new module over current painters | monotone interpolation, tooltip, legend, empty/error states, a11y summary |
| `ConfirmSheet` | new | required for Accept/Reject/Delete/Record payment |

### 2.4 Layout rules
- Screen purpose line first; important information above the fold at 360×800 dp; no card inside a card; list rows not boxes.
- App bar: title + max 2 actions; the scope selector moves into the identity header/second line to stop title/pill collisions (Teams, Peers).
- Bottom nav: keep 5 slots; proposed destinations after roadmap Phase 2 (Home, My Scope, People, Actions, More) — final set pending feature inventory and role matrix confirmation.
- Lists > 12 rows use slivers with lazy builders; images sized/cached (`cacheWidth`).

### 2.5 Motion tokens [P]
| Token | Duration | Curve |
|---|---|---|
| `press` | 120–180 ms | easeOut |
| `card-in` | 250–350 ms | easeOutCubic, 40 ms stagger, first paint only |
| `sheet` | 200–300 ms | easeOutCubic |
| `count-up` | 700–1100 ms | easeOutCubic; animate from previous value; never on placeholders |
| `line-draw` | 600–900 ms | easeInOut |
| `bar-grow` | 500–800 ms | easeOutBack-free (no bounce) |
| `donut` | 650–900 ms | easeInOut |
Rules: respect `MediaQuery.disableAnimations` (render final state); one controller per widget, disposed; no looping animations; do not block content on chart animation; `RepaintBoundary` around charts; native `TweenAnimationBuilder` (no new dependency).

### 2.6 Charts [P]
Line for trends, bars for comparisons, donut for ≤ 5 proportions. Required: title, unit, period, legend when > 1 series, tooltip, empty and error state, categories that sum to the total. **Interpolation must be monotone (no overshoot below the data min/baseline)** — fixes the Finance dip. Y-axis ticks from a "nice number" routine with one unit system per axis.

### 2.7 Accessibility [P]
`Semantics` labels on KPIs, charts (text summary), icon buttons; tap targets ≥ 48 dp; AA contrast; focus order; text scale up to 1.5 without overflow; colour is never the only status signal.

## 3. Migration approach
1. Introduce `AppTheme` that builds light **and** dark `ThemeData` from the merged tokens; keep `AppColors`/`AppColor` as deprecated aliases.
2. Build new widgets in `core/widgets/` and `core/formatting/`; migrate screen by screen starting with Dashboard.
3. Add golden tests per component (light, dark, text scale 1.5).
