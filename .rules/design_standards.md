📘 PEERS GLOBAL UNITY — UI/UX DESIGN STANDARDS (SENIOR SPEC)

Design intent: premium, trustworthy, calm B2B community platform.
NOT a social app, NOT a gamified consumer app — gamification (coins,
badges, impact score) must feel like quiet recognition, not confetti.

═══════════════════════════════════
1. TYPOGRAPHY — WEIGHT CAP & SCALE
═══════════════════════════════════
❌ NEVER use FontWeight.w700, w800, w900, or FontWeight.bold anywhere
   in the app. Heavy weights read as "shouty" and consumer-app, not premium B2B.

✅ Weight system (hard cap: w500 max):
| Token          | FontWeight | Use case                                |
|----------------|-----------|-------------------------------------------|
| regular         | w400      | Body text, descriptions, list content     |
| medium          | w500      | Headers, titles, labels, emphasis (MAX)   |
| light (optional)| w300      | Large display numbers/stats only          |

✅ Type scale (Flutter TextTheme mapping — 4 sizes max per screen):
| Style          | Size | Weight | Line height | Use                         |
|----------------|------|--------|-------------|------------------------------|
| displayLarge    | 28   | w500   | 1.2         | Stat numbers, hero headers   |
| titleLarge      | 20   | w500   | 1.3         | Screen titles                |
| titleMedium     | 16   | w500   | 1.4         | Card headers, section labels |
| bodyLarge       | 14   | w400   | 1.5         | Primary body/content text    |
| bodySmall       | 12   | w400   | 1.5         | Secondary/meta/caption text  |
| labelSmall      | 11   | w500   | 1.3         | Chips, tags, overlines        |

RULE: Max 2 typography styles visible in any single card/component.
RULE: Never letter-space body text; only labelSmall/overline may use
      +0.2–0.5 letter spacing for a "premium tag" feel.

═══════════════════════════════════
2. COLOR DISCIPLINE
═══════════════════════════════════
- Palette per tenant resolves via AppColor/DynamicColor — never hardcoded.
- Base neutral palette: max 5 greys (bg, surface, border, textSecondary,
  textDisabled) + 1 brand primary + 1 accent (used sparingly, <10% of
  any screen's visual weight) + semantic (success/error/warning — used
  ONLY for status, never decoration).
- No gradients on functional UI (buttons, cards, inputs). Gradients are
  reserved for brand/marketing surfaces only (splash, onboarding hero).
- Dark mode: deep slate/charcoal (#12141A range), never pure black.
- Text-on-surface contrast: minimum WCAG AA (4.5:1 body, 3:1 large text)
  — non-negotiable, check every custom color pairing.

═══════════════════════════════════
3. SPACING & LAYOUT GRID
═══════════════════════════════════
- 4px base unit. Allowed values only: 4, 8, 12, 16, 24, 32, 48.
- Screen horizontal padding: 16 (mobile), 24 (tablet breakpoint ≥600dp).
- Card internal padding: 16 default, 12 for dense/compact cards.
- Gap between stacked cards/sections: 12 (related items), 24 (section break).
- Never use spacing values outside the scale, even "just this once."

═══════════════════════════════════
4. COMPONENT STANDARDS
═══════════════════════════════════
Buttons:
- Height: 48 (primary actions), 40 (secondary/inline).
- Radius: 24–28 (pill) for primary CTAs; 10–12 for secondary/utility buttons.
- One primary button per screen. Secondary actions = text/outline buttons,
  never a second filled button competing for attention.

Cards:
- Radius: 12–16. Elevation: flat + 1px hairline border preferred over
  drop-shadow (premium look = subtle, not floaty). If shadow is used:
  blur ≤ 8, opacity ≤ 6%, no colored shadows.

Inputs:
- Height: 48–52. Radius: 10–12. Border 1px, focus state = 1.5px brand color,
  never a glow/shadow focus ring.

Avatars: CircleBorder always. Standard sizes: 32 (list rows), 48 (cards),
  64+ (profile headers) — no in-between sizes.

Chips/Tags/Badges (impact badges, circle tags): radius 8–10 if rectangular,
  full pill (999) if status/label — pick one convention per context and
  stay consistent app-wide.

═══════════════════════════════════
5. ICONOGRAPHY
═══════════════════════════════════
- Outline/line icons only (Feather-style or custom SVG set) — no filled
  Material defaults, no emoji-as-icon.
- Fixed sizes: 20 (inline/list), 24 (nav/toolbar) — nothing else.
- Icon color always from AppColor tokens, never raw.

═══════════════════════════════════
6. MOTION
═══════════════════════════════════
- Duration: 150–250ms for micro-interactions, 300ms max for screen
  transitions. Nothing above 300ms — feels sluggish on a productivity app.
- Curve: Curves.easeInOut or Curves.fastOutSlowIn only.
- No bounce, elastic, or "playful" curves — this is a B2B trust product.
- Skeleton loaders (shimmer) for Loading state, not spinners, for any
  content that has a known layout shape (lists, cards, profile).

═══════════════════════════════════
7. CONTENT DENSITY & INFORMATION HIERARCHY
═══════════════════════════════════
- Every screen: 1 primary focal element, everything else secondary.
- List rows: max 3 lines of text total (title + 1 meta line + 1 status/tag).
- Never show a raw number without a label (e.g., "1,204" alone is dead
  weight — pair with "Lives Impacted" label at bodySmall under it).
- Empty states are mandatory design objects, not afterthoughts: icon +
  1-line message + 1 action, never a blank screen.
- Progressive disclosure: show 3–5 items + "View all," never a full
  unpaginated dump on a primary screen.

═══════════════════════════════════
8. ACCESSIBILITY & RESPONSIVENESS
═══════════════════════════════════
- Minimum tappable target: 44x44 (Flutter: ensure via padding, not just
  visual icon size).
- Text scales with system font size (no fixed pixel containers that
  clip text at larger accessibility sizes) — test at 130% scale.
- Support both light/dark themes from day one — never ship a
  light-only screen and "add dark mode later."
- Breakpoints: mobile <600dp, tablet 600–1024dp, desktop >1024dp —
  design every screen with tablet layout in mind minimum (2-column
  card grids, not stretched single-column).

═══════════════════════════════════
9. GAMIFICATION-SPECIFIC RULE (Life Impact System)
═══════════════════════════════════
- Impact score, coins, badges: presented as quiet stat cards / profile
  chips — never as pop-up confetti, never as loud red-badge notification
  bait. Recognition should feel earned/dignified, matching brand tone.
- Badge iconography: line-art medallion style, single accent color,
  never cartoonish or bright multicolor.

═══════════════════════════════════
10. SENIOR-DEV SELF-CHECK BEFORE SHIPPING A SCREEN
═══════════════════════════════════
□ Any FontWeight above w500 anywhere? → reject, fix.
□ Any spacing value outside 4/8/12/16/24/32/48? → reject, fix.
□ More than 2 type styles or more than 1 primary CTA on screen? → simplify.
□ Any raw hex/Colors.* or hardcoded fontSize? → replace with tokens.
□ Does it hold up at 130% text scale and on a tablet width? → verify.
□ Does gamification content feel loud/consumer-y? → tone it down.
□ Loading/Empty/Error states designed, not just Success? → add them.