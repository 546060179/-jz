# Color, Typography, and Spacing

## Overview

This guide provides comprehensive guidance on visual design tokens - the fundamental building blocks of a design system. Use this when establishing design tokens, creating color palettes, defining typography scales, or setting up spacing systems.

## Color Systems

### Building a Color Palette

A complete color palette includes:

1. **Primary colors**: Brand identity and main actions
2. **Secondary colors**: Supporting elements and variety
3. **Neutral colors**: Text, backgrounds, borders
4. **Semantic colors**: Success, warning, error, info states

### Color Scale Generation

Create 9-11 shades for each color to provide flexibility:

```css
:root {
  /* Primary Blue Scale */
  --blue-50: #eff6ff;
  --blue-100: #dbeafe;
  --blue-200: #bfdbfe;
  --blue-300: #93c5fd;
  --blue-400: #60a5fa;
  --blue-500: #3b82f6; /* Base color */
  --blue-600: #2563eb;
  --blue-700: #1d4ed8;
  --blue-800: #1e40af;
  --blue-900: #1e3a8a;
  --blue-950: #172554;
}
```

**Scale Guidelines**:

- 50-100: Very light tints (backgrounds, subtle highlights)
- 200-300: Light tints (hover states, borders)
- 400-500: Medium shades (primary UI elements)
- 600-700: Dark shades (hover states, emphasis)
- 800-950: Very dark shades (text, high contrast)

### Semantic Color Mapping

Map semantic meanings to your color scales:

```css
:root {
  /* Semantic Colors */
  --color-primary: var(--blue-600);
  --color-primary-hover: var(--blue-700);
  --color-primary-light: var(--blue-50);

  --color-success: var(--green-600);
  --color-success-light: var(--green-50);
  --color-success-dark: var(--green-700);

  --color-warning: var(--amber-500);
  --color-warning-light: var(--amber-50);
  --color-warning-dark: var(--amber-600);

  --color-error: var(--red-600);
  --color-error-light: var(--red-50);
  --color-error-dark: var(--red-700);

  --color-info: var(--sky-600);
  --color-info-light: var(--sky-50);
  --color-info-dark: var(--sky-700);
}
```

### Neutral Color System

Neutrals are the most-used colors in your palette:

```css
:root {
  /* Neutral Gray Scale */
  --gray-50: #f9fafb;
  --gray-100: #f3f4f6;
  --gray-200: #e5e7eb;
  --gray-300: #d1d5db;
  --gray-400: #9ca3af;
  --gray-500: #6b7280;
  --gray-600: #4b5563;
  --gray-700: #374151;
  --gray-800: #1f2937;
  --gray-900: #111827;
  --gray-950: #030712;

  /* Semantic Neutral Mapping */
  --color-background: var(--gray-50);
  --color-surface: #ffffff;
  --color-surface-elevated: #ffffff;

  --color-border: var(--gray-200);
  --color-border-strong: var(--gray-300);

  --color-text-primary: var(--gray-900);
  --color-text-secondary: var(--gray-600);
  --color-text-tertiary: var(--gray-500);
  --color-text-disabled: var(--gray-400);

  --color-text-inverse: #ffffff;
}
```

### Color Contrast Requirements

**WCAG 2.2 Level AA Requirements**:

- Normal text (< 18px): 4.5:1 contrast ratio
- Large text (≥ 18px or ≥ 14px bold): 3:1 contrast ratio
- UI components and graphics: 3:1 contrast ratio

**Testing Contrast**:

```jsx
// Example: Ensure button text meets contrast requirements
const Button = ({ variant = "primary", children }) => {
  const styles = {
    primary: {
      // White text on blue-600 = 4.5:1+ contrast ✓
      background: "var(--blue-600)",
      color: "#ffffff",
    },
    secondary: {
      // Gray-900 text on white = 16:1 contrast ✓
      background: "#ffffff",
      color: "var(--gray-900)",
      border: "1px solid var(--gray-300)",
    },
  };

  return <button style={styles[variant]}>{children}</button>;
};
```

### Dark Mode Color Strategy

Create a parallel dark mode palette:

```css
/* Light mode (default) */
:root {
  --color-background: #ffffff;
  --color-surface: #f9fafb;
  --color-text-primary: #111827;
  --color-text-secondary: #6b7280;
  --color-border: #e5e7eb;
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  :root {
    --color-background: #111827;
    --color-surface: #1f2937;
    --color-text-primary: #f9fafb;
    --color-text-secondary: #9ca3af;
    --color-border: #374151;
  }
}

/* Manual dark mode toggle */
[data-theme="dark"] {
  --color-background: #111827;
  --color-surface: #1f2937;
  --color-text-primary: #f9fafb;
  --color-text-secondary: #9ca3af;
  --color-border: #374151;
}
```

**Dark Mode Best Practices**:

- Don't just invert colors - design intentionally
- Reduce pure white (#ffffff) to off-white (#f9fafb)
- Reduce pure black (#000000) to dark gray (#111827)
- Increase elevation with lighter surfaces, not shadows
- Test contrast ratios in both modes

## Typography System

### Font Selection

**System Font Stack** (fast, native):

```css
font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen",
  "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;
```

**Custom Fonts** (brand identity):

```css
/* Import from Google Fonts */
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap");

:root {
  --font-sans: "Inter", -apple-system, BlinkMacSystemFont, sans-serif;
  --font-serif: "Georgia", "Times New Roman", serif;
  --font-mono: "Menlo", "Monaco", "Courier New", monospace;
}
```

**Font Loading Best Practices**:

- Use `font-display: swap` to prevent invisible text
- Subset fonts to include only needed characters
- Preload critical fonts
- Limit to 2-3 font families maximum

### Type Scale

Use a modular scale for consistent sizing:

**Major Third Scale (1.250 ratio)**:

```css
:root {
  /* Font Sizes */
  --text-xs: 0.75rem; /* 12px */
  --text-sm: 0.875rem; /* 14px */
  --text-base: 1rem; /* 16px */
  --text-lg: 1.125rem; /* 18px */
  --text-xl: 1.25rem; /* 20px */
  --text-2xl: 1.5rem; /* 24px */
  --text-3xl: 1.875rem; /* 30px */
  --text-4xl: 2.25rem; /* 36px */
  --text-5xl: 3rem; /* 48px */
  --text-6xl: 3.75rem; /* 60px */
  --text-7xl: 4.5rem; /* 72px */
}
```

**Alternative Scales**:

- Minor Third (1.200): Subtle hierarchy
- Major Third (1.250): Balanced hierarchy
- Perfect Fourth (1.333): Strong hierarchy
- Golden Ratio (1.618): Dramatic hierarchy

### Font Weights

Define a clear weight system:

```css
:root {
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
}

/* Usage */
.body-text {
  font-weight: var(--font-weight-normal);
}
.emphasis {
  font-weight: var(--font-weight-medium);
}
.heading {
  font-weight: var(--font-weight-semibold);
}
.strong {
  font-weight: var(--font-weight-bold);
}
```

### Line Height

Optimize for readability:

```css
:root {
  /* Line Heights */
  --leading-none: 1;
  --leading-tight: 1.25;
  --leading-snug: 1.375;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;
  --leading-loose: 2;
}

/* Usage Guidelines */
h1,
h2,
h3 {
  line-height: var(--leading-tight);
} /* Headings: tighter */
p,
li {
  line-height: var(--leading-normal);
} /* Body: normal */
.caption {
  line-height: var(--leading-relaxed);
} /* Small text: looser */
```

### Letter Spacing (Tracking)

Adjust spacing for different sizes:

```css
:root {
  --tracking-tighter: -0.05em;
  --tracking-tight: -0.025em;
  --tracking-normal: 0;
  --tracking-wide: 0.025em;
  --tracking-wider: 0.05em;
  --tracking-widest: 0.1em;
}

/* Usage */
.heading-large {
  font-size: var(--text-5xl);
  letter-spacing: var(--tracking-tight); /* Tighter for large text */
}

.uppercase-label {
  text-transform: uppercase;
  letter-spacing: var(--tracking-wider); /* Wider for uppercase */
  font-size: var(--text-xs);
}
```

### Typography Tokens

Complete typography token system:

```css
:root {
  /* Display Styles */
  --typography-display-2xl: 4.5rem/1.1/700; /* size/line-height/weight */
  --typography-display-xl: 3.75rem/1.1/700;
  --typography-display-lg: 3rem/1.2/700;

  /* Heading Styles */
  --typography-h1: 2.25rem/1.25/600;
  --typography-h2: 1.875rem/1.3/600;
  --typography-h3: 1.5rem/1.35/600;
  --typography-h4: 1.25rem/1.4/600;
  --typography-h5: 1.125rem/1.4/500;
  --typography-h6: 1rem/1.5/500;

  /* Body Styles */
  --typography-body-lg: 1.125rem/1.6/400;
  --typography-body: 1rem/1.6/400;
  --typography-body-sm: 0.875rem/1.5/400;

  /* Utility Styles */
  --typography-caption: 0.75rem/1.5/400;
  --typography-overline: 0.75rem/1.5/600;
  --typography-code: 0.875rem/1.5/400;
}
```

**Usage Example**:

```jsx
const Typography = ({ variant = "body", children }) => {
  const styles = {
    h1: { fontSize: "2.25rem", lineHeight: 1.25, fontWeight: 600 },
    h2: { fontSize: "1.875rem", lineHeight: 1.3, fontWeight: 600 },
    body: { fontSize: "1rem", lineHeight: 1.6, fontWeight: 400 },
    caption: { fontSize: "0.75rem", lineHeight: 1.5, fontWeight: 400 },
  };

  return <div style={styles[variant]}>{children}</div>;
};
```

## Spacing System

### Base Unit

Use a base-8 or base-4 spacing system:

**Base-8 System** (recommended):

```css
:root {
  --space-0: 0;
  --space-1: 0.5rem; /* 8px */
  --space-2: 1rem; /* 16px */
  --space-3: 1.5rem; /* 24px */
  --space-4: 2rem; /* 32px */
  --space-5: 2.5rem; /* 40px */
  --space-6: 3rem; /* 48px */
  --space-8: 4rem; /* 64px */
  --space-10: 5rem; /* 80px */
  --space-12: 6rem; /* 96px */
  --space-16: 8rem; /* 128px */
  --space-20: 10rem; /* 160px */
  --space-24: 12rem; /* 192px */
}
```

**Base-4 System** (more granular):

```css
:root {
  --space-0: 0;
  --space-1: 0.25rem; /* 4px */
  --space-2: 0.5rem; /* 8px */
  --space-3: 0.75rem; /* 12px */
  --space-4: 1rem; /* 16px */
  --space-5: 1.25rem; /* 20px */
  --space-6: 1.5rem; /* 24px */
  --space-8: 2rem; /* 32px */
  --space-10: 2.5rem; /* 40px */
  --space-12: 3rem; /* 48px */
  --space-16: 4rem; /* 64px */
}
```

### Semantic Spacing

Map spacing to semantic purposes:

```css
:root {
  /* Component Internal Spacing */
  --space-component-xs: var(--space-1); /* 8px - tight padding */
  --space-component-sm: var(--space-2); /* 16px - default padding */
  --space-component-md: var(--space-3); /* 24px - comfortable padding */
  --space-component-lg: var(--space-4); /* 32px - spacious padding */

  /* Layout Spacing */
  --space-section-sm: var(--space-8); /* 64px - small section gap */
  --space-section-md: var(--space-12); /* 96px - medium section gap */
  --space-section-lg: var(--space-16); /* 128px - large section gap */

  /* Stack Spacing (vertical) */
  --space-stack-xs: var(--space-1); /* 8px - tight list items */
  --space-stack-sm: var(--space-2); /* 16px - default list items */
  --space-stack-md: var(--space-4); /* 32px - separated items */
  --space-stack-lg: var(--space-6); /* 48px - distinct sections */

  /* Inline Spacing (horizontal) */
  --space-inline-xs: var(--space-1); /* 8px - tight buttons */
  --space-inline-sm: var(--space-2); /* 16px - default buttons */
  --space-inline-md: var(--space-3); /* 24px - separated items */
  --space-inline-lg: var(--space-4); /* 32px - distinct groups */
}
```

### Container Widths

Define maximum widths for content containers:

```css
:root {
  --container-xs: 20rem; /* 320px - narrow forms */
  --container-sm: 24rem; /* 384px - small cards */
  --container-md: 28rem; /* 448px - medium cards */
  --container-lg: 32rem; /* 512px - large cards */
  --container-xl: 36rem; /* 576px - narrow content */
  --container-2xl: 42rem; /* 672px - readable content */
  --container-3xl: 48rem; /* 768px - comfortable reading */
  --container-4xl: 56rem; /* 896px - wide content */
  --container-5xl: 64rem; /* 1024px - dashboard */
  --container-6xl: 72rem; /* 1152px - wide dashboard */
  --container-7xl: 80rem; /* 1280px - full width */
}
```

**Optimal Reading Width**: 60-75 characters per line (typically 42-48rem)

### Border Radius

Create a consistent radius scale:

```css
:root {
  --radius-none: 0;
  --radius-sm: 0.125rem; /* 2px - subtle */
  --radius-base: 0.25rem; /* 4px - default */
  --radius-md: 0.375rem; /* 6px - medium */
  --radius-lg: 0.5rem; /* 8px - large */
  --radius-xl: 0.75rem; /* 12px - extra large */
  --radius-2xl: 1rem; /* 16px - very large */
  --radius-3xl: 1.5rem; /* 24px - huge */
  --radius-full: 9999px; /* Fully rounded */
}

/* Semantic Mapping */
:root {
  --radius-button: var(--radius-md);
  --radius-input: var(--radius-base);
  --radius-card: var(--radius-lg);
  --radius-modal: var(--radius-xl);
  --radius-avatar: var(--radius-full);
}
```

### Shadows

Define elevation through shadows:

```css
:root {
  /* Shadow Scale */
  --shadow-xs: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-sm: 0 1px 3px 0 rgb(0 0 0 / 0.1), 0 1px 2px -1px rgb(0 0 0 / 0.1);
  --shadow-base: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-md: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 /
          0.1);
  --shadow-xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);
  --shadow-2xl: 0 50px 100px -20px rgb(0 0 0 / 0.25);

  /* Semantic Shadows */
  --shadow-card: var(--shadow-sm);
  --shadow-dropdown: var(--shadow-md);
  --shadow-modal: var(--shadow-xl);
  --shadow-focus: 0 0 0 3px rgb(59 130 246 / 0.5);
}
```

## Design Token Organization

### Token Structure

Organize tokens in layers:

1. **Primitive tokens**: Raw values
2. **Semantic tokens**: Purpose-based references
3. **Component tokens**: Component-specific values

```css
/* Layer 1: Primitives */
:root {
  --blue-600: #2563eb;
  --space-4: 2rem;
  --text-base: 1rem;
}

/* Layer 2: Semantic */
:root {
  --color-primary: var(--blue-600);
  --space-component-md: var(--space-4);
  --font-size-body: var(--text-base);
}

/* Layer 3: Component */
:root {
  --button-bg: var(--color-primary);
  --button-padding: var(--space-component-md);
  --button-font-size: var(--font-size-body);
}
```

### Token Naming Convention

Use consistent naming:

```
--{category}-{property}-{variant}-{state}
```

**Examples**:

- `--color-text-primary` (category-property-variant)
- `--button-bg-primary-hover` (component-property-variant-state)
- `--space-stack-md` (category-purpose-size)

## Practical Examples

### Complete Button System

```css
:root {
  /* Button Spacing */
  --button-padding-y-sm: var(--space-1);
  --button-padding-x-sm: var(--space-2);
  --button-padding-y-md: var(--space-2);
  --button-padding-x-md: var(--space-4);
  --button-padding-y-lg: var(--space-3);
  --button-padding-x-lg: var(--space-6);

  /* Button Typography */
  --button-font-size-sm: var(--text-sm);
  --button-font-size-md: var(--text-base);
  --button-font-size-lg: var(--text-lg);
  --button-font-weight: var(--font-weight-medium);

  /* Button Appearance */
  --button-radius: var(--radius-md);
  --button-shadow: var(--shadow-sm);
  --button-shadow-hover: var(--shadow-base);
}

.button {
  padding: var(--button-padding-y-md) var(--button-padding-x-md);
  font-size: var(--button-font-size-md);
  font-weight: var(--button-font-weight);
  border-radius: var(--button-radius);
  box-shadow: var(--button-shadow);
  transition: all 150ms ease;
}

.button:hover {
  box-shadow: var(--button-shadow-hover);
}

.button-primary {
  background: var(--color-primary);
  color: var(--color-text-inverse);
}

.button-sm {
  padding: var(--button-padding-y-sm) var(--button-padding-x-sm);
  font-size: var(--button-font-size-sm);
}
```

### Card Component Tokens

```css
:root {
  --card-bg: var(--color-surface);
  --card-border: 1px solid var(--color-border);
  --card-radius: var(--radius-lg);
  --card-shadow: var(--shadow-card);
  --card-padding: var(--space-4);
  --card-gap: var(--space-3);
}

.card {
  background: var(--card-bg);
  border: var(--card-border);
  border-radius: var(--card-radius);
  box-shadow: var(--card-shadow);
  padding: var(--card-padding);
}

.card > * + * {
  margin-top: var(--card-gap);
}
```

## Best Practices

### Do's

- ✅ Use CSS custom properties for all design tokens
- ✅ Define tokens at the `:root` level for global access
- ✅ Use semantic naming that describes purpose, not appearance
- ✅ Create a consistent scale for all token types
- ✅ Document token usage and guidelines
- ✅ Test color contrast ratios for accessibility
- ✅ Use relative units (rem, em) for scalability
- ✅ Organize tokens in logical groups
- ✅ Version your design tokens
- ✅ Provide both light and dark mode tokens

### Don'ts

- ❌ Don't use magic numbers - always use tokens
- ❌ Don't create one-off values outside the system
- ❌ Don't use pixel values for spacing or typography
- ❌ Don't skip contrast testing
- ❌ Don't create too many token variations (keep it simple)
- ❌ Don't use color names that describe appearance (blue-button)
- ❌ Don't forget to update tokens when design changes
- ❌ Don't mix token systems (pick base-4 or base-8, not both)

## Resources

### Tools

- [Coolors](https://coolors.co/) - Color palette generator
- [Palettte](https://palettte.app/) - Color scale generator
- [Type Scale](https://type-scale.com/) - Typography scale calculator
- [Modular Scale](https://www.modularscale.com/) - Ratio-based scales
- [Contrast Checker](https://webaim.org/resources/contrastchecker/) - WCAG contrast validation
- [Accessible Colors](https://accessible-colors.com/) - Find accessible color combinations

### Design Systems

- [Tailwind CSS](https://tailwindcss.com/docs/customizing-colors) - Comprehensive token system
- [Material Design](https://m3.material.io/styles/color/overview) - Google's design tokens
- [Primer](https://primer.style/design/foundations/color) - GitHub's design system
- [Polaris](https://polaris.shopify.com/tokens/colors) - Shopify's design tokens

### Reading

- [Refactoring UI](https://www.refactoringui.com/) - Practical design token usage
- [Design Tokens W3C](https://design-tokens.github.io/community-group/) - Token specification
