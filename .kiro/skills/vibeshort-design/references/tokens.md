# VibeShort — Design Tokens

## 1. Fonts

| Role | Family | Weights | Why |
|------|--------|---------|-----|
| Display / Titles | Lexend Deca | 300, 400, 500, 600 | Geometric sans with excellent readability at large sizes. The light weight feels cinematic and editorial — perfect for drama titles. |
| Body / UI | Montserrat | 500, 600, 700, 800 | Dense geometric sans that packs information tightly. Bold weights for labels create visual punch against the dark canvas. |
| Metrics | Montserrat | 600 | Numeric data (view counts, episode numbers) in SemiBold for scanability. |

**Fallback stacks:**
- Lexend Deca: `'Lexend Deca', 'Inter', system-ui, sans-serif`
- Montserrat: `'Montserrat', 'Inter', system-ui, sans-serif`

**Google Fonts import:**
```
Lexend+Deca:wght@300;400;500;600&family=Montserrat:ital,wght@0,500;0,600;0,700;0,800;1,800
```

## 2. Type Scale

| Token | Size | Line Height | Letter Spacing | Weight | Family | Use |
|-------|------|-------------|----------------|--------|--------|-----|
| `--display` | 28px | 1.4 | 0 | 300 | Lexend Deca | Section titles ("New Coming", "Recommend For you") |
| `--h1` | 24px | 1.33 | 0 | 600 | Lexend Deca | Banner headline, hero title |
| `--h2` | 20px | 1.4 | 0 | 400 | Lexend Deca | Large card titles |
| `--h3` | 14px | 1.43 | 0 | 700 | Montserrat | List card titles, button text |
| `--body` | 12px | 1.33 | 0 | 500 | Montserrat | Descriptions, body text |
| `--body-sm` | 12px | 1.33 | 0 | 300 | Lexend Deca | Card subtitles, descriptions |
| `--caption` | 10px | 1.6 | 0 | 600 | Montserrat | View counts, metrics |
| `--label` | 8px | 1.5 | 0.02em | 800 | Montserrat | Status badges (HOT, NEW, EXCLUSIVE) |
| `--tag` | 9px | 1.56 | 0 | 500 | Lexend Deca | Content tags, tab labels |

## 3. Colors

### Dark Mode (Primary)

| Token | Value | Role |
|-------|-------|------|
| `--background` | `#050713` | Page canvas |
| `--surface1` | `#141621` | Primary cards, info panels |
| `--surface2` | `#191A1E` | Tab bar, nested surfaces |
| `--surface3` | `#26282D` | Borders, dividers |
| `--border` | `#141621` | Subtle borders |
| `--border-visible` | `#26282D` | Intentional borders (card strokes) |
| `--text1` | `#FFFFFF` | Primary text, titles |
| `--text2` | `#CED0D6` | Secondary text, card titles |
| `--text3` | `#8D9199` | Tertiary text, descriptions |
| `--text4` | `#6E727A` | Disabled, timestamps |
| `--accent` | `#5A68FF` | Brand accent, active states |
| `--accent-subtle` | `#0A1580` | Accent tinted backgrounds |

### Semantic Colors

| Token | Value | Use |
|-------|-------|-----|
| `--success` | `#0FFFE7` | Positive states |
| `--warning` | `#FFB347` | Caution states |
| `--error` | `#FF6164` | Error, destructive |

### Gradient Tags

| Tag | Gradient | Text Color |
|-----|----------|------------|
| HOT | `linear-gradient(270deg, #FF6164 0%, #FFB1B0 100%)` | `#0D0E10` |
| NEW | `linear-gradient(270deg, #0FFFE7 0%, #C8FFD8 100%)` | `#141621` |
| EXCLUSIVE | `linear-gradient(270deg, #F86DFF 0%, #FBCBFF 100%)` | `#141621` |
| Brand | `linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)` | `#141621` |

## 4. Spacing

| Token | Value | Use |
|-------|-------|-----|
| `--space-2xs` | 2px | Micro gaps |
| `--space-xs` | 4px | Tag internal gaps, icon margins |
| `--space-sm` | 8px | Card gaps in horizontal scroll |
| `--space-md` | 12px | Card gaps in vertical list, section internal |
| `--space-lg` | 16px | Page horizontal padding |
| `--space-xl` | 20px | Section internal padding |
| `--space-2xl` | 24px | Between card groups |
| `--space-3xl` | 32px | — |
| `--space-4xl` | 40px | Between feed sections |
| `--space-5xl` | 48px | — |
| `--space-6xl` | 64px | — |

## 5. Radii

| Token | Value | Use |
|-------|-------|-----|
| `--radius-element` | 4px | Small controls |
| `--radius-control` | 8px | Tags, play badges |
| `--radius-component` | 12px | Content cards, buttons |
| `--radius-container` | 20px | Banner, tab bar, section cards |
| `--radius-pill` | 100px | Exclusive pill badge |
| `--radius-full` | 999px | Circular elements |

## 6. Elevation

| Level | Treatment | Use |
|-------|-----------|-----|
| Flat | No shadow, border only | Default cards |
| Glass | `backdrop-filter: blur(40px)` + semi-transparent bg | Tab bar, play badges |
| Glow | `0 1px 6px rgba(127,115,255,0.85)` | Brand logo, active accent |
| Inset glow | `inset 0 0 5.2px rgba(187,197,255,0.4)` + `blur(1px)` | Special interactive elements |

## 7. Motion

| Token | Value | Use |
|-------|-------|-----|
| `--ease` | `cubic-bezier(0.4, 0, 0.2, 1)` | Default easing |
| `--duration-fast` | 150ms | Micro-interactions, hover |
| `--duration-normal` | 250ms | Page transitions, reveals |
| `--duration-slow` | 400ms | Modal open/close |

Personality: **Smooth.** Transitions feel like a camera pan — no bounce, no overshoot. Content slides in with confidence.

## 8. Iconography

**Observed style:** Custom filled icons, 24px, geometric construction with soft corners. Solid fill, minimal detail.

**Fallback kit:** Phosphor Fill
- CDN: `https://unpkg.com/@phosphor-icons/web@2/src/fill/style.css`
- Class prefix: `ph-fill ph-`
- Match reasoning: Phosphor fill matches the solid geometric style. The brand uses filled icons throughout (play, search, subscribe, arrow) with rounded forms.

**Disclaimer:** Icons in generated previews use Phosphor Fill as a best-match fallback. The brand's actual icons are proprietary.
