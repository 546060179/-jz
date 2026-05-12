---
name: vibeshort-design
description: "This skill should be used when the user explicitly says 'VibeShort style', 'VibeShort design', '/vibeshort-design', or directly asks to use/apply the VibeShort design system. NEVER trigger automatically for generic UI or design tasks."
version: 1.0.0
allowed-tools: [Read, Write, Edit, Glob, Grep]
---

# VibeShort Design Language

You are building interfaces for VibeShort — a short drama streaming platform. Every screen you produce must feel like a dark cinema lobby: deep blue-black walls, content posters glowing under spotlights, and vivid neon category tags that pop like theater marquee lights.

## Philosophy

**Immersive dark cinema.** The canvas is a near-black void (`#050713`) that absorbs peripheral attention and pushes content forward. Color is rationed — it arrives only through poster imagery and gradient status tags, making each color moment feel earned. The primary tension: absolute darkness vs. explosive chromatic bursts.

Design lineage: Netflix's dark immersion meets TikTok's vertical-first density, filtered through a premium short-form drama sensibility. Think: a boutique screening room, not a multiplex.

## Design Principles

1. **Content is the color.** The UI is monochrome dark. Poster imagery and gradient tags are the only chromatic elements. Never add decorative color to chrome.
2. **Gradient tags are signal devices.** HOT (red→pink), NEW (teal→mint), EXCLUSIVE (magenta→lavender) — each gradient carries semantic meaning. Never use gradients decoratively.
3. **Glass over shadow.** Elevation comes from backdrop-blur at 40px, not drop shadows. The only shadow is the brand glow (`0 1px 6px rgba(127,115,255,0.85)`) on the logo.
4. **Lexend for narrative, Montserrat for data.** Display/titles use Lexend Deca (light/regular) for its cinematic, readable quality. Labels, metrics, and UI chrome use Montserrat (bold/extrabold) for density and punch.
5. **Rounded but not soft.** 12px radius on cards, 8px on tags, 20px on containers. Never pill-shaped except the exclusive badge. The roundness says "approachable entertainment" without becoming childish.
6. **Vertical-first density.** Content cards are tall (3:4 or 9:16 aspect). Horizontal scrolls use tight 8px gaps. The feed is dense — users scroll through drama thumbnails like flipping through a bookshelf.
7. **Scrim hierarchy.** Gradient overlays (top-down and bottom-up) on imagery create text-safe zones without obscuring the poster art. Never use solid color overlays.

## Craft Rules

### Visual Hierarchy Layers

| Layer | Treatment | Example |
|-------|-----------|---------|
| Canvas | `#050713` flat | Page background |
| Surface | `#141621` or `#191A1E` | Cards, tab bar, info panels |
| Content | Poster imagery | Thumbnails, banners |
| Signal | Gradient tags | HOT, NEW, EXCLUSIVE badges |
| Interactive | `#5A68FF` accent | Active tab, brand elements |

### Typography Discipline

- Max 2 font families per screen (Lexend Deca + Montserrat)
- Section titles: Lexend Deca Light 28px, Title Case
- Card titles: Lexend Deca Light 12-16px, Title Case
- Body/descriptions: Lexend Deca Light 12px or Montserrat Medium 12px
- Labels/badges: Montserrat ExtraBold Italic 8px, UPPERCASE
- Metrics (view counts, episode numbers): Montserrat SemiBold 10px

### Color Strategy

- Background: `#050713` (always)
- Surfaces: `#141621`, `#191A1E`, `#26282D` (layered depth)
- Text hierarchy: `#FFFFFF` → `#CED0D6` → `#8D9199` → `#6E727A`
- Accent: `#5A68FF` (tags, active states, brand gradient)
- Status gradients: HOT red, NEW teal, EXCLUSIVE magenta
- Never use accent as a background fill — only as text color or thin indicator

### Spacing

- Card gaps: 8px (horizontal scroll), 12px (vertical list)
- Section padding: 8-16px horizontal
- Section spacing: 40px between feed sections
- Inner card padding: 4px

### Squint Test

Squint at the screen. You should see: a dark field with rectangular poster shapes arranged in clear horizontal bands. Gradient tag corners should be the brightest non-image elements. If anything else glows or draws attention, it's wrong.

## Anti-Patterns

1. No light mode as default — dark is the primary and only production mode
2. No drop shadows on cards — use border (`0.9px #26282D`) or backdrop-blur
3. No solid color backgrounds on tags — always gradient
4. No border-radius > 20px except the exclusive pill badge (100px)
5. No serif fonts anywhere
6. No decorative illustrations or empty states with cute graphics
7. No white or light backgrounds for any surface
8. No opacity below 0.7 on text — readability is non-negotiable
9. No horizontal card layouts wider than 225px in feed context
10. No animated gradients or shimmer effects on static content
11. No rounded-pill buttons — buttons use 12px radius
12. No more than 3 gradient tags visible simultaneously per card

## Workflow

When building a VibeShort screen:

1. Start with `#050713` canvas
2. Lay out content zones as `#141621` surfaces
3. Place poster imagery with gradient scrim overlays
4. Add text hierarchy (white → gray progression)
5. Apply gradient status tags where semantically appropriate
6. Add glass-blur elements (tab bar, play badges) last
7. Verify: does it feel like a dark cinema? Are gradient tags the only color?

## Reference Files

- `references/tokens.md` — Complete token definitions
- `references/components.md` — Component specifications
- `references/platform-mapping.md` — CSS, SwiftUI, Tailwind mappings
