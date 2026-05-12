# VibeShort — Component Specifications

## 1. Content Cards

### Large Card (Banner Scroll)

| Property | Value |
|----------|-------|
| Width | 225px |
| Height | 400px |
| Border radius | 12px |
| Image area | Top 300px, full width |
| Info area | Bottom, `#141621` background |
| Title | Lexend Deca 20px/400, Title Case, `#FFFFFF` |
| Description | Lexend Deca 12px/300, `#6C7398` |
| Tags | Inside info area, 8px radius, `#050713` bg, `#5A68FF` text |
| Gradient overlay | Bottom-up: `rgba(20,22,33,0)` → `rgba(20,22,33,1)` |

### Medium Card (3-up Horizontal)

| Property | Value |
|----------|-------|
| Width | 117px |
| Height | 156px + text below |
| Border radius | 12px |
| Image | Full card, background-size cover |
| Play badge | Bottom-right, 62×20px, blur bg, 8px radius |
| Title | Lexend Deca 12px/300, Title Case, `#C4C7D6` |
| Tags below | 8px radius, `#141621` bg, `#5A68FF` text, 9px |

### List Card (Single Column)

| Property | Value |
|----------|-------|
| Layout | Horizontal: 108×144px image + text area |
| Image radius | 12px |
| Image border | 0.9px `#26282D` |
| Title | Montserrat 14px/700, `#CED0D6` |
| Description | Montserrat 12px/500, `#8D9199` |
| Episode | Montserrat 12px/500, `#9F9FA2` |
| Play button | 32px height, 12px radius, `#191A1E` bg |

## 2. Tags & Badges

### Content Tag

| Property | Value |
|----------|-------|
| Height | 20px |
| Padding | 0 6px |
| Border radius | 8px |
| Background | `#050713` (on dark surface) or `#141621` (on cards) |
| Text | Lexend Deca 9px/500, `#5A68FF` |

### Status Tag (Corner Badge)

| Variant | Background | Text | Position |
|---------|-----------|------|----------|
| HOT | `linear-gradient(270deg, #FF6164, #FFB1B0)` | `#0D0E10`, Montserrat 8px/800 italic | Top-right, `border-radius: 0 0 0 8px` |
| NEW | `linear-gradient(270deg, #0FFFE7, #C8FFD8)` | `#141621` | Same |
| EXCLUSIVE | `linear-gradient(270deg, #F86DFF, #FBCBFF)` | `#141621` | Same |

### Gradient Tag (Inline)

| Property | Value |
|----------|-------|
| Height | 20px (large) / 16px (small) |
| Border radius | 8px 0 0 8px (left-rounded only) |
| Background | `linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%)` |
| Text | Lexend Deca 12px/500 or 9px/500, `#141621` |
| Tail | 4px wide decorative element |

### Exclusive Pill

| Property | Value |
|----------|-------|
| Height | 14px |
| Padding | 3px 4px |
| Border radius | 100px |
| Background | `#050713` |
| Text | Lexend Deca 8px/400, gradient text `linear-gradient(90deg, #4051FF, #CECECE)` |
| Icon | 12×12px VibeShort logo mark |

## 3. Play Badge

| Property | Value |
|----------|-------|
| Height | 20px |
| Padding | 0 8px (or 4px gap) |
| Border radius | 8px |
| Background | `rgba(20, 22, 33, 0.12)` |
| Backdrop filter | `blur(40px)` |
| Icon | Play fill, 10px, white |
| Text | Montserrat 10px/500, `#FFFFFF` |
| Content | View count (e.g. "667.3M") |

## 4. Buttons

### Play Button (Primary Action)

| Property | Value |
|----------|-------|
| Height | 32px |
| Padding | 6px 20px |
| Border radius | 12px |
| Background | `#191A1E` |
| Text | Montserrat 14px/700, `#FFFFFF` |
| Icon | Play fill, left of text |

### No other button variants observed — derive as needed using:
- Secondary: border 1px `#26282D`, transparent bg, `#FFFFFF` text
- Ghost: no border, no bg, `#5A68FF` text

## 5. Navigation

### Tab Bar

| Property | Value |
|----------|-------|
| Border radius | 20px |
| Background | `rgba(25, 26, 30, 0.76)` |
| Backdrop filter | `blur(40px)` |
| Items | Home, Short, Reward, My List, Profile |
| Active text | Lexend Deca 9px/600, `#FFFFFF` |
| Inactive text | Lexend Deca 9px/400, `#C4C7D6` |
| Icon size | 24px above text |
| Active indicator | Gradient glow beneath icon |

### Header

| Property | Value |
|----------|-------|
| Background | Transparent (overlays banner) |
| Logo | VibeShort wordmark, Lexend Deca 24px/400, white |
| Right action | Search icon, 48×48px touch target |
| Status bar | Standard iOS, white text |

## 6. Sections

### Section Title

| Property | Value |
|----------|-------|
| Font | Lexend Deca 28px/300, Title Case |
| Color | `#FFFFFF` |
| Padding | 0 8px (aligned with card grid) |

### Section Container (Dark Card)

| Property | Value |
|----------|-------|
| Background | Transparent (default) or `#050713` with 20px radius |
| Padding | 20px 8px |
| Gap between sections | 40px |

## 7. Banner / Hero

### Full-width Banner

| Property | Value |
|----------|-------|
| Width | 100% (375px on mobile) |
| Height | 500px |
| Border radius | 0 (full bleed) |
| Image | Full cover, multiple layers |
| Top scrim | `linear-gradient(180deg, #050713 18%, rgba(5,7,19,0.75) 59%, transparent 100%)` |
| Bottom scrim | `linear-gradient(180deg, transparent 0%, rgba(5,7,19,0.75) 52%, #050713 100%)` |
| Content position | Bottom-center, above bottom scrim |
| Title | Lexend Deca 24px/600, white, centered, Title Case |
| Subtitle badge | Exclusive pill + title text |

### Banner Pagination

| Property | Value |
|----------|-------|
| Dots | 12px wide (active) / 16px wide (inactive) × 3px height |
| Active color | `#FFFFFF` at 100% |
| Inactive color | `rgba(255,255,255,0.2)` |
| Position | Below banner content |

## 8. States

### Empty State
- Dark surface card with centered icon (Phosphor fill, 48px, `#6E727A`)
- Single line text: Montserrat 14px/500, `#8D9199`
- No illustrations, no decorative elements

### Loading State
- Skeleton: `#141621` rectangles with 12px radius
- No shimmer animation — static placeholder

### Error State
- Icon: warning-fill, `#FF6164`
- Text: Montserrat 14px/500, `#CED0D6`
- Retry button: standard play button style
