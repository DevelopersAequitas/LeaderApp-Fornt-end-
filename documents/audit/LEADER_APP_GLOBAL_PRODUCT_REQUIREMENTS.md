# LEADER APP — GLOBAL PRODUCT REQUIREMENTS

Version 1 · 2026-11-24 · Labels: **[V]** verified · **[O]** observed · **[A]** assumption · **[G]** backend gap · **[R]** recommendation

The product is "Peers Global" (website: "25+ Countries", "45+ Cities"). The app today is built for one country. This document lists what is verifiably India-specific, what a global leader needs, and what the backend must supply.

## 1. Current global-readiness assessment (verified)

| Area | Finding | Evidence |
|---|---|---|
| Localization framework | None: 0 uses of `AppLocalizations`, `localizationsDelegates`, `supportedLocales`; `intl` not a dependency; all strings hard-coded English | V grep |
| Currency | `₹` appears in **40 files / 92 places** (Finance, Reports form, Dashboard, models default `'₹0.0'`); compact formats use Indian "L"/"Cr"/"k" (`₹13L`, `₹500.05Cr`, `1.0L`) | V grep, O screenshots |
| Number format | Mixed: raw (`500000`), compact Indian (`₹22.5L`), western (`80.0k`), and an undefined "6.40Q" | O |
| Dates | English month tables in `DateTimeUtils`; ISO strings in UI (`2026-12-02`); no locale-aware date format | V, O |
| Time zones | Parser converts UTC → **device** timezone. A circle's own IANA zone is not used or shown; a leader travelling or a cross-border meeting would see a different local time than the circle's | V (`date_time_utils.dart`) |
| Phone | Login uses `country_picker` (good); profile shows raw E.164 (`+91…`); report/finance inputs are India-centric | V, O |
| Geography | No geography model. Only `regional_scope` string + `managed_circles` names + a city text on circles; DED doc assumes "District ➔ 18 Industries" | V |
| Addresses | City string only (e.g., "Ahmedabad"); no address object | O |
| Text direction / scripts | No RTL handling; font LibreFranklin (Latin) bundled only | V |
| Accessibility | 0 `Semantics`; no `textScaler` handling; light theme only | V grep |
| Calendar "week" rules | Cadence text like "Week 1 • Wednesdays" is built from backend strings with many alias keys | V (R5) |

## 2. Requirements

### 2.1 Geography
- G1 The app must use **backend geography records and ids**; never hard-code states, districts, postal formats, or country lists beyond the phone picker.
- G2 Model: `Geography {id, type (global|country|admin1|admin2|city|hub), name, localizedNames, parentId, countryCode, timezone (IANA)}`; Circle has `geographyId` and `timezone`. [G] none exists today.
- G3 Admin-level labels come from the backend per country (State/Province/Emirate/District/County).
- G4 Scope breadcrumbs ("Global › India › Gujarat › Ahmedabad › Circle") shown wherever a scope is applied.

### 2.2 Currency
- C1 Every monetary value carries `{amount (minor units or decimal string), currency (ISO 4217)}`. Today values arrive as pre-formatted strings (`"₹72,000"`) that the app cannot reformat or convert [V `finance_model.dart`]. [G] backend to send amount+currency.
- C2 Never add or chart values in different currencies without a backend-provided conversion (with date and rate source). A multi-country leader sees per-currency totals, or a clearly labelled converted total.
- C3 One `MoneyFormatter` (symbol, grouping, compact thresholds per locale). Indian lakh/crore grouping only when the **locale or circle country** is India.

### 2.3 Numbers, dates, time
- N1 Locale-aware number formatting (grouping, decimal, percent, compact). Define a single compact rule (K/M/B for en; L/Cr for en-IN) and remove "Q" ambiguity.
- D1 Dates in UI via `intl` `DateFormat` for the active locale; ISO only in debug/logs.
- T1 Meeting times shown **in the circle's IANA zone with the zone abbreviation**, and, when different from the device zone, the viewer's local time as secondary text.
- T2 "Nth weekday" cadences are rendered from structured data `{frequency, weekday, nth, startLocal, endLocal, tz}` (not parsed English).

### 2.4 Languages
- L1 Adopt Flutter `gen-l10n` (ARB) with `en` as source; structure strings by feature. Initial locales: `en`, `hi`; others added on demand. Backend free-text (circle names, posts) stays untranslated.
- L2 Respect system text scale (cap at 1.3–1.5 for dense tiles, no fixed-height text containers) and RTL mirroring for future Arabic.
- L3 Fonts: bundle or fall back for Devanagari and Arabic glyphs (LibreFranklin is Latin) [A: verify glyph coverage].

### 2.5 Phone, contact, privacy
- P1 Parse/display phone numbers with a library (E.164 in storage, national format in UI); validate by country.
- P2 Mask phone/email by default on Profile and Peer Profile; reveal on tap for roles with `can_view_peer_contact_info` (the flag already exists [V]).

### 2.6 Role-scoped data
- S1 Backend filters by assignment scope on every list/metric endpoint; the app additionally shows the active scope and never merges scopes silently. DED is documented to be filtered by token [V]; other roles unverified [A].
- S2 Multi-assignment leaders use a scope switcher whose options are assignments returned by the backend [G].

### 2.7 Content and brand
- B1 Use Peers Global vocabulary from the website ("Peers", "Circle", "Powerhouse", "Chair", "Leader", "Unity App", "Life Impact"). A list of **prohibited terms was not found** in the repo or site; obtain it before writing new copy. [A]
- B2 Contribution rules: impact counts only when the receiving Peer confirms; attendance and self-declared value do not. UI must display the confirmation state.

## 3. Backend contract needs (summary)

| Need | Why | Priority |
|---|---|---|
| `geography` tree + ids on circles/leaders | scope, breadcrumbs, filtering | High |
| `timezone` (IANA) on circle/event | correct meeting times | High |
| money as `{amount, currency}` on all finance/report/deal payloads | formatting, no mixed-currency sums | High |
| structured meeting cadence object | remove guessed alias keys | High |
| leader `assignments[]` with role+scope+tenure | role-aware home, switcher | High |
| localized names (optional) | multi-language directory | Low |

## 4. Verification plan (Phase 8)
Test leaders in ≥3 countries (INR, AED, USD), a UTC+5:30, a UTC+4 and a UTC−5 device, text scale 1.3, RTL smoke test, long names, big numbers; assert no ₹ literal remains outside the formatter (add a lint/grep test).
