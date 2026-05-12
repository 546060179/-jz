# VibeShort — Platform Mapping

## CSS Custom Properties

```css
:root,
[data-theme="dark"] {
  /* Colors */
  --background: #050713;
  --bg: #050713;
  --surface1: #141621;
  --surface2: #191A1E;
  --surface3: #26282D;
  --border: #141621;
  --border-visible: #26282D;
  --text1: #FFFFFF;
  --text2: #CED0D6;
  --text3: #8D9199;
  --text4: #6E727A;
  --accent: #5A68FF;
  --accent-subtle: #0A1580;

  /* Semantic */
  --success: #0FFFE7;
  --warning: #FFB347;
  --error: #FF6164;

  /* Gradient Tags */
  --tag-hot: linear-gradient(270deg, #FF6164 0%, #FFB1B0 100%);
  --tag-new: linear-gradient(270deg, #0FFFE7 0%, #C8FFD8 100%);
  --tag-exclusive: linear-gradient(270deg, #F86DFF 0%, #FBCBFF 100%);
  --tag-brand: linear-gradient(-90deg, #CECECE 0%, #6A74FF 100%);

  /* Typography */
  --font-display: 'Lexend Deca', 'Inter', system-ui, sans-serif;
  --font-body: 'Montserrat', 'Inter', system-ui, sans-serif;

  /* Spacing */
  --space-2xs: 2px;
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 12px;
  --space-lg: 16px;
  --space-xl: 20px;
  --space-2xl: 24px;
  --space-3xl: 32px;
  --space-4xl: 40px;

  /* Radii */
  --radius-element: 4px;
  --radius-control: 8px;
  --radius-component: 12px;
  --radius-container: 20px;
  --radius-pill: 100px;

  /* Elevation */
  --glass-blur: blur(40px);
  --glass-bg: rgba(25, 26, 30, 0.76);
  --glow-brand: 0 1px 6px rgba(127, 115, 255, 0.85);
  --glow-inset: inset 0 0 5.2px rgba(187, 197, 255, 0.4);

  /* Motion */
  --ease: cubic-bezier(0.4, 0, 0.2, 1);
  --duration-fast: 150ms;
  --duration-normal: 250ms;
  --duration-slow: 400ms;
}

[data-theme="light"] {
  --background: #F0F1F5;
  --bg: #F0F1F5;
  --surface1: #FFFFFF;
  --surface2: #F0F1F5;
  --surface3: #CED0D6;
  --border: #CED0D6;
  --border-visible: #C4C7D6;
  --text1: #050713;
  --text2: #6E727A;
  --text3: #8D9199;
  --text4: #9F9FA2;
  --accent: #5A68FF;
  --accent-subtle: #E8EAFF;
}
```

## SwiftUI Extensions

```swift
import SwiftUI

extension Color {
    // MARK: - Backgrounds
    static let vsBackground = Color(hex: "#050713")
    static let vsSurface1 = Color(hex: "#141621")
    static let vsSurface2 = Color(hex: "#191A1E")
    static let vsSurface3 = Color(hex: "#26282D")

    // MARK: - Text
    static let vsText1 = Color.white
    static let vsText2 = Color(hex: "#CED0D6")
    static let vsText3 = Color(hex: "#8D9199")
    static let vsText4 = Color(hex: "#6E727A")

    // MARK: - Accent
    static let vsAccent = Color(hex: "#5A68FF")
    static let vsAccentSubtle = Color(hex: "#0A1580")

    // MARK: - Semantic
    static let vsSuccess = Color(hex: "#0FFFE7")
    static let vsWarning = Color(hex: "#FFB347")
    static let vsError = Color(hex: "#FF6164")

    // MARK: - Borders
    static let vsBorder = Color(hex: "#141621")
    static let vsBorderVisible = Color(hex: "#26282D")
}

extension Font {
    // Display
    static let vsDisplay = Font.custom("LexendDeca-Light", size: 28)
    static let vsH1 = Font.custom("LexendDeca-SemiBold", size: 24)
    static let vsH2 = Font.custom("LexendDeca-Regular", size: 20)
    static let vsH3 = Font.custom("Montserrat-Bold", size: 14)
    static let vsBody = Font.custom("Montserrat-Medium", size: 12)
    static let vsBodySm = Font.custom("LexendDeca-Light", size: 12)
    static let vsCaption = Font.custom("Montserrat-SemiBold", size: 10)
    static let vsLabel = Font.custom("Montserrat-ExtraBoldItalic", size: 8)
    static let vsTag = Font.custom("LexendDeca-Medium", size: 9)
}

// MARK: - Spacing
enum VSSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let xxxxl: CGFloat = 40
}

// MARK: - Radii
enum VSRadius {
    static let element: CGFloat = 4
    static let control: CGFloat = 8
    static let component: CGFloat = 12
    static let container: CGFloat = 20
    static let pill: CGFloat = 100
}

// MARK: - View Modifiers
struct VSGlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(Color.vsSurface2.opacity(0.76))
    }
}

struct VSCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.vsSurface1)
            .clipShape(RoundedRectangle(cornerRadius: VSRadius.component, style: .continuous))
    }
}

extension View {
    func vsGlass() -> some View { modifier(VSGlassBackground()) }
    func vsCard() -> some View { modifier(VSCardStyle()) }
}
```

## Tailwind Config

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        vs: {
          bg: '#050713',
          surface1: '#141621',
          surface2: '#191A1E',
          surface3: '#26282D',
          text1: '#FFFFFF',
          text2: '#CED0D6',
          text3: '#8D9199',
          text4: '#6E727A',
          accent: '#5A68FF',
          'accent-subtle': '#0A1580',
          success: '#0FFFE7',
          warning: '#FFB347',
          error: '#FF6164',
          border: '#141621',
          'border-visible': '#26282D',
        }
      },
      fontFamily: {
        display: ['"Lexend Deca"', 'Inter', 'system-ui', 'sans-serif'],
        body: ['"Montserrat"', 'Inter', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        'vs-element': '4px',
        'vs-control': '8px',
        'vs-component': '12px',
        'vs-container': '20px',
        'vs-pill': '100px',
      },
      spacing: {
        'vs-2xs': '2px',
        'vs-xs': '4px',
        'vs-sm': '8px',
        'vs-md': '12px',
        'vs-lg': '16px',
        'vs-xl': '20px',
        'vs-2xl': '24px',
        'vs-3xl': '32px',
        'vs-4xl': '40px',
      },
      backdropBlur: {
        'vs-glass': '40px',
      },
      boxShadow: {
        'vs-glow': '0 1px 6px rgba(127, 115, 255, 0.85)',
        'vs-inset': 'inset 0 0 5.2px rgba(187, 197, 255, 0.4)',
      },
      transitionDuration: {
        'vs-fast': '150ms',
        'vs-normal': '250ms',
        'vs-slow': '400ms',
      },
      transitionTimingFunction: {
        'vs': 'cubic-bezier(0.4, 0, 0.2, 1)',
      }
    }
  }
}
```

## Android (Kotlin / Compose)

```kotlin
object VibeShortTokens {
    // Colors
    val Background = Color(0xFF050713)
    val Surface1 = Color(0xFF141621)
    val Surface2 = Color(0xFF191A1E)
    val Surface3 = Color(0xFF26282D)
    val Text1 = Color(0xFFFFFFFF)
    val Text2 = Color(0xFFCED0D6)
    val Text3 = Color(0xFF8D9199)
    val Text4 = Color(0xFF6E727A)
    val Accent = Color(0xFF5A68FF)
    val AccentSubtle = Color(0xFF0A1580)
    val Success = Color(0xFF0FFFE7)
    val Warning = Color(0xFFFFB347)
    val Error = Color(0xFFFF6164)

    // Radii
    val RadiusElement = 4.dp
    val RadiusControl = 8.dp
    val RadiusComponent = 12.dp
    val RadiusContainer = 20.dp
    val RadiusPill = 100.dp

    // Spacing
    val Space2xs = 2.dp
    val SpaceXs = 4.dp
    val SpaceSm = 8.dp
    val SpaceMd = 12.dp
    val SpaceLg = 16.dp
    val SpaceXl = 20.dp
    val Space2xl = 24.dp
    val Space3xl = 32.dp
    val Space4xl = 40.dp
}
```
