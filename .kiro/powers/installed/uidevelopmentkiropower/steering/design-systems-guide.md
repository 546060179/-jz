# Design Systems Guide

## Overview

This guide provides comprehensive guidance on creating, implementing, and maintaining design systems for consistent, scalable user interfaces. A design system is more than a component library—it's a collection of reusable components, design tokens, patterns, and guidelines that ensure consistency across your entire product.

Use this guide when:

- Starting a new design system from scratch
- Implementing an existing design system in code
- Maintaining consistency across a growing application
- Scaling UI development across multiple teams
- Migrating from ad-hoc styling to a systematic approach

## What is a Design System?

A design system consists of three core layers:

**1. Design Tokens**: The atomic design decisions (colors, spacing, typography)
**2. Components**: Reusable UI building blocks built with design tokens
**3. Patterns**: Guidelines for combining components to solve common problems

**Benefits**:

- **Consistency**: Unified look and feel across all products
- **Efficiency**: Faster development with reusable components
- **Scalability**: Easy to maintain and extend as products grow
- **Collaboration**: Shared language between designers and developers
- **Quality**: Accessibility and best practices baked in

## Design Tokens

Design tokens are the foundation of any design system. They are named entities that store visual design attributes, making it easy to maintain a consistent visual language.

### Core Token Categories

**1. Color Tokens**
**2. Typography Tokens**
**3. Spacing Tokens**
**4. Border Radius Tokens**
**5. Shadow Tokens**
**6. Transition Tokens**

### Color Tokens

Colors should be organized into semantic categories with multiple shades for flexibility.

#### Color Palette Structure

```javascript
// ✅ Good: Semantic color system with shades
const colors = {
  // Brand colors
  primary: {
    50: "#e3f2fd",
    100: "#bbdefb",
    200: "#90caf9",
    300: "#64b5f6",
    400: "#42a5f5",
    500: "#2196f3", // Base color
    600: "#1e88e5",
    700: "#1976d2",
    800: "#1565c0",
    900: "#0d47a1",
  },

  // Semantic colors
  success: {
    50: "#e8f5e9",
    500: "#4caf50",
    900: "#1b5e20",
  },
  error: {
    50: "#ffebee",
    500: "#f44336",
    900: "#b71c1c",
  },
  warning: {
    50: "#fff3e0",
    500: "#ff9800",
    900: "#e65100",
  },

  // Neutral colors
  gray: {
    50: "#fafafa",
    100: "#f5f5f5",
    200: "#eeeeee",
    300: "#e0e0e0",
    400: "#bdbdbd",
    500: "#9e9e9e",
    600: "#757575",
    700: "#616161",
    800: "#424242",
    900: "#212121",
  },

  // Functional colors
  background: {
    primary: "#ffffff",
    secondary: "#f5f5f5",
    tertiary: "#eeeeee",
  },
  text: {
    primary: "#212121",
    secondary: "#757575",
    disabled: "#bdbdbd",
    inverse: "#ffffff",
  },
  border: {
    light: "#e0e0e0",
    medium: "#bdbdbd",
    dark: "#757575",
  },
};

// ❌ Bad: Arbitrary color names without system
const colors = {
  blue: "#2196f3",
  lightBlue: "#64b5f6",
  darkBlue: "#1565c0",
  red: "#f44336",
  // No semantic meaning, hard to maintain
};
```

#### Implementing Color Tokens

**CSS Custom Properties**:

```css
/* tokens.css */
:root {
  /* Primary colors */
  --color-primary-50: #e3f2fd;
  --color-primary-500: #2196f3;
  --color-primary-900: #0d47a1;

  /* Semantic colors */
  --color-success: #4caf50;
  --color-error: #f44336;
  --color-warning: #ff9800;

  /* Text colors */
  --color-text-primary: #212121;
  --color-text-secondary: #757575;

  /* Background colors */
  --color-bg-primary: #ffffff;
  --color-bg-secondary: #f5f5f5;
}

/* Dark mode */
[data-theme="dark"] {
  --color-text-primary: #ffffff;
  --color-text-secondary: #bdbdbd;
  --color-bg-primary: #121212;
  --color-bg-secondary: #1e1e1e;
}

/* Usage */
.button-primary {
  background-color: var(--color-primary-500);
  color: var(--color-text-inverse);
}
```

**JavaScript/TypeScript**:

```typescript
// tokens.ts
export const colors = {
  primary: {
    50: "#e3f2fd",
    500: "#2196f3",
    900: "#0d47a1",
  },
  text: {
    primary: "#212121",
    secondary: "#757575",
  },
} as const;

// Type-safe token access
type ColorToken = typeof colors;
type PrimaryShade = keyof typeof colors.primary;

// Usage in styled-components
import styled from "styled-components";

const Button = styled.button`
  background-color: ${colors.primary[500]};
  color: ${colors.text.primary};
`;
```

**Tailwind CSS Configuration**:

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#e3f2fd",
          500: "#2196f3",
          900: "#0d47a1",
        },
        success: "#4caf50",
        error: "#f44336",
      },
    },
  },
};

// Usage: className="bg-primary-500 text-white"
```

### Typography Tokens

Typography tokens define font families, sizes, weights, line heights, and letter spacing.

#### Typography Scale

```javascript
// ✅ Good: Modular typography scale
const typography = {
  // Font families
  fontFamily: {
    sans: '"Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
    serif: '"Merriweather", Georgia, serif',
    mono: '"Fira Code", "Courier New", monospace',
  },

  // Font sizes (using modular scale: 1.250 - Major Third)
  fontSize: {
    xs: "0.75rem", // 12px
    sm: "0.875rem", // 14px
    base: "1rem", // 16px
    lg: "1.125rem", // 18px
    xl: "1.25rem", // 20px
    "2xl": "1.5rem", // 24px
    "3xl": "1.875rem", // 30px
    "4xl": "2.25rem", // 36px
    "5xl": "3rem", // 48px
    "6xl": "3.75rem", // 60px
  },

  // Font weights
  fontWeight: {
    light: 300,
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
    extrabold: 800,
  },

  // Line heights
  lineHeight: {
    none: 1,
    tight: 1.25,
    snug: 1.375,
    normal: 1.5,
    relaxed: 1.625,
    loose: 2,
  },

  // Letter spacing
  letterSpacing: {
    tighter: "-0.05em",
    tight: "-0.025em",
    normal: "0",
    wide: "0.025em",
    wider: "0.05em",
    widest: "0.1em",
  },
};

// ❌ Bad: Arbitrary sizes without system
const typography = {
  small: "13px",
  medium: "15px",
  large: "19px",
  // No consistent scale
};
```

#### Typography Implementation

```css
/* CSS Custom Properties */
:root {
  /* Font families */
  --font-sans: "Inter", -apple-system, sans-serif;
  --font-serif: "Merriweather", Georgia, serif;
  --font-mono: "Fira Code", monospace;

  /* Font sizes */
  --text-xs: 0.75rem;
  --text-sm: 0.875rem;
  --text-base: 1rem;
  --text-lg: 1.125rem;
  --text-xl: 1.25rem;
  --text-2xl: 1.5rem;
  --text-3xl: 1.875rem;

  /* Font weights */
  --font-normal: 400;
  --font-medium: 500;
  --font-semibold: 600;
  --font-bold: 700;

  /* Line heights */
  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.625;
}

/* Typography classes */
.heading-1 {
  font-family: var(--font-sans);
  font-size: var(--text-4xl);
  font-weight: var(--font-bold);
  line-height: var(--leading-tight);
  letter-spacing: -0.025em;
}

.body-text {
  font-family: var(--font-sans);
  font-size: var(--text-base);
  font-weight: var(--font-normal);
  line-height: var(--leading-normal);
}
```

### Spacing Tokens

Consistent spacing creates visual rhythm and hierarchy. Use a spacing scale based on a base unit (typically 4px or 8px).

#### Spacing Scale

```javascript
// ✅ Good: 4px base unit spacing scale
const spacing = {
  0: "0",
  1: "0.25rem", // 4px
  2: "0.5rem", // 8px
  3: "0.75rem", // 12px
  4: "1rem", // 16px
  5: "1.25rem", // 20px
  6: "1.5rem", // 24px
  8: "2rem", // 32px
  10: "2.5rem", // 40px
  12: "3rem", // 48px
  16: "4rem", // 64px
  20: "5rem", // 80px
  24: "6rem", // 96px
  32: "8rem", // 128px
};

// ❌ Bad: Arbitrary spacing values
const spacing = {
  small: "7px",
  medium: "15px",
  large: "23px",
  // No consistent system
};
```

#### Spacing Implementation

```css
/* CSS Custom Properties */
:root {
  --space-0: 0;
  --space-1: 0.25rem;
  --space-2: 0.5rem;
  --space-3: 0.75rem;
  --space-4: 1rem;
  --space-6: 1.5rem;
  --space-8: 2rem;
  --space-12: 3rem;
  --space-16: 4rem;
}

/* Usage */
.card {
  padding: var(--space-6);
  margin-bottom: var(--space-4);
  gap: var(--space-3);
}

.section {
  padding-block: var(--space-16);
  padding-inline: var(--space-4);
}
```

**React Component Example**:

```tsx
// Using spacing tokens in components
import { spacing } from './tokens'

const Card = styled.div`
  padding: ${spacing[6]};
  margin-bottom: ${spacing[4]};
  gap: ${spacing[3]};
`

// Or with Chakra UI
<Box p={6} mb={4} gap={3}>
  {/* Content */}
</Box>
```

### Additional Design Tokens

#### Border Radius

```javascript
const borderRadius = {
  none: "0",
  sm: "0.125rem", // 2px
  base: "0.25rem", // 4px
  md: "0.375rem", // 6px
  lg: "0.5rem", // 8px
  xl: "0.75rem", // 12px
  "2xl": "1rem", // 16px
  "3xl": "1.5rem", // 24px
  full: "9999px", // Fully rounded
};
```

#### Shadows

```javascript
const shadows = {
  none: "none",
  sm: "0 1px 2px 0 rgba(0, 0, 0, 0.05)",
  base: "0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)",
  md: "0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)",
  lg: "0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)",
  xl: "0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)",
  "2xl": "0 25px 50px -12px rgba(0, 0, 0, 0.25)",
  inner: "inset 0 2px 4px 0 rgba(0, 0, 0, 0.06)",
};
```

#### Transitions

```javascript
const transitions = {
  duration: {
    fast: "150ms",
    base: "200ms",
    slow: "300ms",
    slower: "500ms",
  },
  easing: {
    linear: "linear",
    in: "cubic-bezier(0.4, 0, 1, 1)",
    out: "cubic-bezier(0, 0, 0.2, 1)",
    inOut: "cubic-bezier(0.4, 0, 0.2, 1)",
  },
};
```

## Creating a Color Palette

A well-designed color palette is essential for a cohesive design system. Follow these steps to create an effective palette.

### Step 1: Define Brand Colors

Start with your primary brand color and generate a full scale of shades.

**Tools for Generating Color Scales**:

- [Tailwind Color Palette Generator](https://uicolors.app/create)
- [Coolors](https://coolors.co/)
- [Adobe Color](https://color.adobe.com/)
- [Palettte](https://palettte.app/)

**Manual Approach**:

```javascript
// Start with base color (500)
const primaryBase = "#2196f3";

// Generate lighter shades (50-400)
// Increase lightness, decrease saturation slightly
const primary = {
  50: "#e3f2fd", // Very light
  100: "#bbdefb",
  200: "#90caf9",
  300: "#64b5f6",
  400: "#42a5f5",
  500: "#2196f3", // Base
  600: "#1e88e5", // Slightly darker
  700: "#1976d2",
  800: "#1565c0",
  900: "#0d47a1", // Very dark
};
```

### Step 2: Add Semantic Colors

Define colors for common UI states and feedback.

```javascript
const semanticColors = {
  success: {
    light: "#81c784",
    base: "#4caf50",
    dark: "#388e3c",
  },
  error: {
    light: "#e57373",
    base: "#f44336",
    dark: "#d32f2f",
  },
  warning: {
    light: "#ffb74d",
    base: "#ff9800",
    dark: "#f57c00",
  },
  info: {
    light: "#64b5f6",
    base: "#2196f3",
    dark: "#1976d2",
  },
};
```

### Step 3: Create Neutral Palette

Grays are used extensively for text, borders, and backgrounds.

```javascript
const neutral = {
  white: "#ffffff",
  50: "#fafafa",
  100: "#f5f5f5",
  200: "#eeeeee",
  300: "#e0e0e0",
  400: "#bdbdbd",
  500: "#9e9e9e",
  600: "#757575",
  700: "#616161",
  800: "#424242",
  900: "#212121",
  black: "#000000",
};
```

### Step 4: Ensure Accessibility

Verify color contrast ratios meet WCAG AA standards (4.5:1 for normal text, 3:1 for large text).

```javascript
// ✅ Good: Sufficient contrast
const button = {
  background: "#2196f3", // Primary 500
  text: "#ffffff", // White
  // Contrast ratio: 4.6:1 ✓
};

// ❌ Bad: Insufficient contrast
const button = {
  background: "#90caf9", // Primary 200 (too light)
  text: "#ffffff", // White
  // Contrast ratio: 1.9:1 ✗
};
```

**Testing Tools**:

- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
- Chrome DevTools (Inspect element → Color picker shows contrast ratio)
- [Contrast Ratio Calculator](https://contrast-ratio.com/)

## Creating Typography Scales

A harmonious typography scale creates visual hierarchy and improves readability.

### Step 1: Choose a Modular Scale

Use a mathematical ratio to generate font sizes that relate harmoniously.

**Common Ratios**:

- **1.125 (Major Second)**: Subtle, great for body-heavy content
- **1.200 (Minor Third)**: Balanced, versatile for most projects
- **1.250 (Major Third)**: Noticeable, good for marketing sites
- **1.333 (Perfect Fourth)**: Strong hierarchy
- **1.414 (Augmented Fourth)**: Dramatic, editorial designs
- **1.618 (Golden Ratio)**: Classic, elegant

**Example: Major Third (1.250) Scale**:

```javascript
// Base size: 16px (1rem)
const fontSizes = {
  xs: "0.64rem", // 10.24px (16 / 1.25²)
  sm: "0.8rem", // 12.8px  (16 / 1.25)
  base: "1rem", // 16px
  lg: "1.25rem", // 20px    (16 × 1.25)
  xl: "1.563rem", // 25px    (16 × 1.25²)
  "2xl": "1.953rem", // 31.25px (16 × 1.25³)
  "3xl": "2.441rem", // 39px    (16 × 1.25⁴)
  "4xl": "3.052rem", // 48.83px (16 × 1.25⁵)
  "5xl": "3.815rem", // 61px    (16 × 1.25⁶)
};
```

**Tools**:

- [Type Scale](https://typescale.com/)
- [Modular Scale](https://www.modularscale.com/)

### Step 2: Define Text Styles

Create reusable text styles for common use cases.

```typescript
// Text style definitions
const textStyles = {
  // Headings
  h1: {
    fontSize: "3.052rem",
    fontWeight: 700,
    lineHeight: 1.2,
    letterSpacing: "-0.02em",
  },
  h2: {
    fontSize: "2.441rem",
    fontWeight: 700,
    lineHeight: 1.25,
    letterSpacing: "-0.01em",
  },
  h3: {
    fontSize: "1.953rem",
    fontWeight: 600,
    lineHeight: 1.3,
  },
  h4: {
    fontSize: "1.563rem",
    fontWeight: 600,
    lineHeight: 1.4,
  },

  // Body text
  bodyLarge: {
    fontSize: "1.25rem",
    fontWeight: 400,
    lineHeight: 1.6,
  },
  body: {
    fontSize: "1rem",
    fontWeight: 400,
    lineHeight: 1.5,
  },
  bodySmall: {
    fontSize: "0.875rem",
    fontWeight: 400,
    lineHeight: 1.5,
  },

  // UI text
  button: {
    fontSize: "1rem",
    fontWeight: 500,
    lineHeight: 1,
    letterSpacing: "0.01em",
  },
  caption: {
    fontSize: "0.75rem",
    fontWeight: 400,
    lineHeight: 1.4,
  },
  overline: {
    fontSize: "0.75rem",
    fontWeight: 600,
    lineHeight: 1,
    letterSpacing: "0.1em",
    textTransform: "uppercase",
  },
};
```

### Step 3: Implement Typography System

```css
/* CSS Implementation */
.text-h1 {
  font-size: 3.052rem;
  font-weight: 700;
  line-height: 1.2;
  letter-spacing: -0.02em;
}

.text-body {
  font-size: 1rem;
  font-weight: 400;
  line-height: 1.5;
}

.text-caption {
  font-size: 0.75rem;
  font-weight: 400;
  line-height: 1.4;
  color: var(--color-text-secondary);
}
```

```tsx
// React Component
import styled from "styled-components";

export const Heading1 = styled.h1`
  font-size: ${({ theme }) => theme.fontSize["4xl"]};
  font-weight: ${({ theme }) => theme.fontWeight.bold};
  line-height: 1.2;
  letter-spacing: -0.02em;
`;

export const Body = styled.p`
  font-size: ${({ theme }) => theme.fontSize.base};
  font-weight: ${({ theme }) => theme.fontWeight.normal};
  line-height: 1.5;
`;
```

## Creating Spacing Systems

Consistent spacing creates visual rhythm and makes layouts feel cohesive.

### Step 1: Choose a Base Unit

Most design systems use either 4px or 8px as the base unit.

**4px Base Unit** (more granular):

```javascript
const spacing = {
  0: "0",
  1: "0.25rem", // 4px
  2: "0.5rem", // 8px
  3: "0.75rem", // 12px
  4: "1rem", // 16px
  5: "1.25rem", // 20px
  6: "1.5rem", // 24px
  8: "2rem", // 32px
  10: "2.5rem", // 40px
  12: "3rem", // 48px
  16: "4rem", // 64px
};
```

**8px Base Unit** (simpler):

```javascript
const spacing = {
  0: "0",
  1: "0.5rem", // 8px
  2: "1rem", // 16px
  3: "1.5rem", // 24px
  4: "2rem", // 32px
  5: "2.5rem", // 40px
  6: "3rem", // 48px
  8: "4rem", // 64px
  10: "5rem", // 80px
};
```

### Step 2: Apply Spacing Consistently

Use spacing tokens for all margins, padding, and gaps.

```tsx
// ✅ Good: Using spacing tokens
const Card = styled.div`
  padding: ${spacing[6]};
  margin-bottom: ${spacing[4]};
  gap: ${spacing[3]};
`;

// ❌ Bad: Arbitrary spacing values
const Card = styled.div`
  padding: 23px;
  margin-bottom: 17px;
  gap: 11px;
`;
```

### Step 3: Create Layout Utilities

```css
/* Spacing utilities */
.p-0 {
  padding: 0;
}
.p-1 {
  padding: 0.25rem;
}
.p-2 {
  padding: 0.5rem;
}
.p-4 {
  padding: 1rem;
}
.p-6 {
  padding: 1.5rem;
}

.m-0 {
  margin: 0;
}
.m-2 {
  margin: 0.5rem;
}
.m-4 {
  margin: 1rem;
}
.m-6 {
  margin: 1.5rem;
}

.gap-2 {
  gap: 0.5rem;
}
.gap-4 {
  gap: 1rem;
}
.gap-6 {
  gap: 1.5rem;
}
```

## Component Patterns

Components are the building blocks of your design system. Document patterns for creating and using components consistently.

### Component Documentation Strategy

Each component should have comprehensive documentation:

**1. Overview**: What the component does and when to use it
**2. Variants**: Different visual styles (primary, secondary, outlined, etc.)
**3. States**: Interactive states (default, hover, focus, active, disabled)
**4. Props/API**: All available properties and their types
**5. Accessibility**: ARIA attributes, keyboard navigation, screen reader support
**6. Examples**: Code examples showing common use cases
**7. Do's and Don'ts**: Best practices and anti-patterns

### Example: Button Component Documentation

```markdown
# Button Component

## Overview

Buttons trigger actions or events. Use buttons for important actions that users need to take.

## Variants

- **Primary**: Main call-to-action (e.g., "Submit", "Save")
- **Secondary**: Less prominent actions (e.g., "Cancel")
- **Outlined**: Alternative to secondary
- **Ghost**: Minimal styling for tertiary actions
- **Danger**: Destructive actions (e.g., "Delete")

## States

- Default
- Hover
- Focus (keyboard navigation)
- Active (pressed)
- Disabled
- Loading

## Props

- `variant`: 'primary' | 'secondary' | 'outlined' | 'ghost' | 'danger'
- `size`: 'sm' | 'md' | 'lg'
- `disabled`: boolean
- `loading`: boolean
- `fullWidth`: boolean
- `onClick`: () => void

## Accessibility

- Uses semantic `<button>` element
- Keyboard accessible (Enter and Space keys)
- Visible focus indicator
- Disabled state communicated to screen readers
- Loading state announced with aria-live

## Examples

[Code examples here]

## Do's and Don'ts

✅ Use primary buttons for main actions
✅ Provide clear, action-oriented labels
❌ Don't use more than one primary button per section
❌ Don't use generic labels like "Click here"
```

### Component Implementation Example

```tsx
// Button.tsx
import styled from "styled-components";
import { colors, spacing, fontSize, borderRadius } from "./tokens";

interface ButtonProps {
  variant?: "primary" | "secondary" | "outlined" | "ghost" | "danger";
  size?: "sm" | "md" | "lg";
  disabled?: boolean;
  loading?: boolean;
  fullWidth?: boolean;
  children: React.ReactNode;
  onClick?: () => void;
}

const StyledButton = styled.button<ButtonProps>`
  /* Base styles */
  font-family: inherit;
  font-weight: 500;
  border: none;
  border-radius: ${borderRadius.md};
  cursor: pointer;
  transition: all 150ms ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: ${spacing[2]};

  /* Size variants */
  ${({ size = "md" }) => {
    const sizes = {
      sm: `
        padding: ${spacing[2]} ${spacing[3]};
        font-size: ${fontSize.sm};
      `,
      md: `
        padding: ${spacing[3]} ${spacing[4]};
        font-size: ${fontSize.base};
      `,
      lg: `
        padding: ${spacing[4]} ${spacing[6]};
        font-size: ${fontSize.lg};
      `,
    };
    return sizes[size];
  }}

  /* Color variants */
  ${({ variant = "primary" }) => {
    const variants = {
      primary: `
        background-color: ${colors.primary[500]};
        color: white;
        &:hover:not(:disabled) {
          background-color: ${colors.primary[600]};
        }
      `,
      secondary: `
        background-color: ${colors.gray[200]};
        color: ${colors.gray[900]};
        &:hover:not(:disabled) {
          background-color: ${colors.gray[300]};
        }
      `,
      outlined: `
        background-color: transparent;
        color: ${colors.primary[500]};
        border: 1px solid ${colors.primary[500]};
        &:hover:not(:disabled) {
          background-color: ${colors.primary[50]};
        }
      `,
      ghost: `
        background-color: transparent;
        color: ${colors.gray[700]};
        &:hover:not(:disabled) {
          background-color: ${colors.gray[100]};
        }
      `,
      danger: `
        background-color: ${colors.error[500]};
        color: white;
        &:hover:not(:disabled) {
          background-color: ${colors.error[600]};
        }
      `,
    };
    return variants[variant];
  }}
  
  /* Full width */
  ${({ fullWidth }) => fullWidth && "width: 100%;"}
  
  /* Disabled state */
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }

  /* Focus state */
  &:focus-visible {
    outline: 2px solid ${colors.primary[500]};
    outline-offset: 2px;
  }
`;

export function Button({ children, loading, disabled, ...props }: ButtonProps) {
  return (
    <StyledButton disabled={disabled || loading} aria-busy={loading} {...props}>
      {loading && <Spinner aria-hidden="true" />}
      {children}
    </StyledButton>
  );
}
```

## Implementing a Design System

### Step-by-Step Implementation

**1. Set Up Token Infrastructure**

```typescript
// tokens/index.ts
export { colors } from "./colors";
export { typography } from "./typography";
export { spacing } from "./spacing";
export { borderRadius } from "./border-radius";
export { shadows } from "./shadows";
export { transitions } from "./transitions";
```

**2. Create Theme Provider**

```tsx
// theme/ThemeProvider.tsx
import { createContext, useContext } from "react";
import * as tokens from "../tokens";

const ThemeContext = createContext(tokens);

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  return (
    <ThemeContext.Provider value={tokens}>{children}</ThemeContext.Provider>
  );
}

export function useTheme() {
  return useContext(ThemeContext);
}
```

**3. Build Component Library**

```
components/
├── Button/
│   ├── Button.tsx
│   ├── Button.test.tsx
│   ├── Button.stories.tsx
│   └── index.ts
├── Input/
│   ├── Input.tsx
│   ├── Input.test.tsx
│   ├── Input.stories.tsx
│   └── index.ts
└── index.ts
```

**4. Document Components**

Use Storybook or similar tools to create interactive documentation:

```bash
npm install --save-dev @storybook/react
npx storybook init
```

```tsx
// Button.stories.tsx
import type { Meta, StoryObj } from "@storybook/react";
import { Button } from "./Button";

const meta: Meta<typeof Button> = {
  title: "Components/Button",
  component: Button,
  tags: ["autodocs"],
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: {
    variant: "primary",
    children: "Primary Button",
  },
};

export const Secondary: Story = {
  args: {
    variant: "secondary",
    children: "Secondary Button",
  },
};

export const Disabled: Story = {
  args: {
    variant: "primary",
    disabled: true,
    children: "Disabled Button",
  },
};
```

**5. Create Usage Guidelines**

Document when and how to use each component:

```markdown
# Button Usage Guidelines

## When to Use

- Triggering actions (submit forms, open modals, navigate)
- Primary calls-to-action
- Confirming or canceling operations

## When Not to Use

- Navigation between pages (use Link instead)
- Toggling states (use Switch or Checkbox)
- Selecting from options (use Radio or Select)

## Best Practices

- Use clear, action-oriented labels ("Save Changes" not "Submit")
- Limit to one primary button per section
- Place primary action on the right in dialogs
- Ensure minimum 44×44px touch target
- Provide loading states for async actions
```

## Working with Existing Design Systems

When you have an existing design system, follow these practices to maintain consistency.

### Extracting Design Tokens from Figma

If your design system is defined in Figma, extract tokens systematically:

**1. Identify Token Categories**

- Colors (from color styles)
- Typography (from text styles)
- Spacing (from layout grids and component spacing)
- Effects (shadows, blurs)

**2. Use Figma Tokens Plugin**

Install the [Figma Tokens](https://www.figma.com/community/plugin/843461159747178978/Figma-Tokens) plugin to export design tokens as JSON.

**3. Transform to Code**

```javascript
// figma-tokens.json (exported from Figma)
{
  "colors": {
    "primary": {
      "500": { "value": "#2196f3" }
    }
  }
}

// Transform to code tokens
const colors = {
  primary: {
    500: '#2196f3'
  }
}
```

### Applying Design System Tokens Consistently

**✅ Good: Using design system tokens**

```tsx
// Always reference tokens
const Card = styled.div`
  background-color: ${({ theme }) => theme.colors.background.primary};
  padding: ${({ theme }) => theme.spacing[6]};
  border-radius: ${({ theme }) => theme.borderRadius.lg};
  box-shadow: ${({ theme }) => theme.shadows.md};
`;
```

**❌ Bad: Hardcoded values**

```tsx
// Don't use arbitrary values
const Card = styled.div`
  background-color: #ffffff;
  padding: 24px;
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
`;
```

### Handling Design System Conflicts

When visual requirements conflict with design system tokens:

**1. Prefer Design System Tokens**

Try to use existing tokens even if not perfect match:

```tsx
// Visual requirement: 22px padding
// Design system: 20px (spacing[5]) or 24px (spacing[6])
// ✅ Choose closest: spacing[6] (24px)
<Box padding={6}>
```

**2. Propose Token Addition**

If a value is needed frequently, propose adding it to the design system:

```typescript
// Propose adding to spacing scale
const spacing = {
  // ... existing tokens
  5.5: "1.375rem", // 22px - new token
};
```

**3. Document Exceptions**

If you must deviate, document why:

```tsx
// Exception: Brand requirement for exact 22px padding
// TODO: Discuss with design team about adding spacing[5.5]
const SpecialCard = styled.div`
  padding: 1.375rem; /* 22px - brand requirement */
`;
```

### Reusing Existing Components

**✅ Good: Compose from existing components**

```tsx
// Reuse Button component with custom content
function SaveButton() {
  return (
    <Button variant="primary" onClick={handleSave}>
      <SaveIcon />
      Save Changes
    </Button>
  );
}
```

**❌ Bad: Duplicating component logic**

```tsx
// Don't recreate existing components
function SaveButton() {
  return (
    <button className="custom-save-button" onClick={handleSave}>
      Save Changes
    </button>
  );
}
```

## Best Practices for Maintaining Consistency

### 1. Establish Clear Governance

**Define Ownership**:

- Who can add new tokens?
- Who approves component additions?
- How are breaking changes handled?

**Version Control**:

- Use semantic versioning for design system package
- Document all changes in CHANGELOG
- Provide migration guides for breaking changes

### 2. Automate Consistency Checks

**Linting Design Tokens**:

```javascript
// .stylelintrc.js
module.exports = {
  rules: {
    // Enforce design token usage
    "scale-unlimited/declaration-strict-value": [
      ["/color/", "fill", "stroke", "background-color"],
      {
        ignoreValues: ["transparent", "inherit", "currentColor"],
      },
    ],
  },
};
```

**ESLint Rules**:

```javascript
// .eslintrc.js
module.exports = {
  rules: {
    // Warn on hardcoded colors
    "no-restricted-syntax": [
      "warn",
      {
        selector: "Literal[value=/#[0-9a-f]{3,6}/i]",
        message: "Use design system color tokens instead of hex colors",
      },
    ],
  },
};
```

### 3. Create Component Templates

Provide templates for creating new components:

```tsx
// templates/Component.template.tsx
import styled from "styled-components";
import { spacing, colors, borderRadius } from "../tokens";

interface ComponentNameProps {
  // Define props
}

const StyledComponentName = styled.div`
  /* Use design tokens */
  padding: ${spacing[4]};
  background-color: ${colors.background.primary};
  border-radius: ${borderRadius.md};
`;

export function ComponentName(props: ComponentNameProps) {
  return <StyledComponentName>{/* Implementation */}</StyledComponentName>;
}
```

### 4. Regular Design System Audits

Periodically audit your codebase for consistency:

```bash
# Find hardcoded colors
grep -r "#[0-9a-f]\{6\}" src/

# Find hardcoded spacing
grep -r "[0-9]\+px" src/ | grep -v "node_modules"

# Find components not using design system
grep -r "styled\." src/ | grep -v "theme\."
```

### 5. Educate Team Members

**Onboarding Documentation**:

```markdown
# Design System Quick Start

## Using Design Tokens

Always import and use design tokens:

\`\`\`tsx
import { colors, spacing } from '@/design-system/tokens'

const Card = styled.div\`
background: \${colors.background.primary};
padding: \${spacing[6]};
\`
\`\`\`

## Finding Components

Check Storybook before creating new components:

- http://localhost:6006

## Getting Help

- #design-system Slack channel
- Design system documentation: /docs/design-system
- Office hours: Tuesdays 2-3pm
```

### 6. Monitor Design System Usage

Track which components are used most frequently:

```typescript
// analytics.ts
export function trackComponentUsage(componentName: string) {
  // Track in analytics
  analytics.track("component_used", {
    component: componentName,
    timestamp: new Date(),
  });
}

// In components
export function Button(props: ButtonProps) {
  useEffect(() => {
    trackComponentUsage("Button");
  }, []);

  return <StyledButton {...props} />;
}
```

### 7. Provide Migration Paths

When updating design system, provide clear migration guides:

```markdown
# Migration Guide: v2.0.0

## Breaking Changes

### Color Token Restructure

**Before (v1.x)**:
\`\`\`tsx
colors.blue500
\`\`\`

**After (v2.x)**:
\`\`\`tsx
colors.primary[500]
\`\`\`

### Automated Migration

Run codemod to automatically update:
\`\`\`bash
npx @company/design-system-codemod v1-to-v2
\`\`\`

### Manual Migration

1. Update color imports
2. Update spacing references
3. Update component props
```

## Design System Examples

### Example 1: Complete Token System

```typescript
// tokens/index.ts
export const designTokens = {
  colors: {
    primary: {
      50: "#e3f2fd",
      100: "#bbdefb",
      200: "#90caf9",
      300: "#64b5f6",
      400: "#42a5f5",
      500: "#2196f3",
      600: "#1e88e5",
      700: "#1976d2",
      800: "#1565c0",
      900: "#0d47a1",
    },
    gray: {
      50: "#fafafa",
      100: "#f5f5f5",
      200: "#eeeeee",
      300: "#e0e0e0",
      400: "#bdbdbd",
      500: "#9e9e9e",
      600: "#757575",
      700: "#616161",
      800: "#424242",
      900: "#212121",
    },
    success: "#4caf50",
    error: "#f44336",
    warning: "#ff9800",
  },

  spacing: {
    0: "0",
    1: "0.25rem",
    2: "0.5rem",
    3: "0.75rem",
    4: "1rem",
    6: "1.5rem",
    8: "2rem",
    12: "3rem",
    16: "4rem",
  },

  fontSize: {
    xs: "0.75rem",
    sm: "0.875rem",
    base: "1rem",
    lg: "1.125rem",
    xl: "1.25rem",
    "2xl": "1.5rem",
    "3xl": "1.875rem",
    "4xl": "2.25rem",
  },

  fontWeight: {
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
  },

  borderRadius: {
    none: "0",
    sm: "0.125rem",
    base: "0.25rem",
    md: "0.375rem",
    lg: "0.5rem",
    xl: "0.75rem",
    full: "9999px",
  },

  shadows: {
    sm: "0 1px 2px 0 rgba(0, 0, 0, 0.05)",
    base: "0 1px 3px 0 rgba(0, 0, 0, 0.1)",
    md: "0 4px 6px -1px rgba(0, 0, 0, 0.1)",
    lg: "0 10px 15px -3px rgba(0, 0, 0, 0.1)",
    xl: "0 20px 25px -5px rgba(0, 0, 0, 0.1)",
  },
} as const;

export type DesignTokens = typeof designTokens;
```

### Example 2: Theme Configuration

```typescript
// theme/theme.ts
import { designTokens } from "../tokens";

export const lightTheme = {
  ...designTokens,
  colors: {
    ...designTokens.colors,
    background: {
      primary: "#ffffff",
      secondary: "#f5f5f5",
      tertiary: "#eeeeee",
    },
    text: {
      primary: "#212121",
      secondary: "#757575",
      disabled: "#bdbdbd",
    },
    border: {
      light: "#e0e0e0",
      medium: "#bdbdbd",
    },
  },
};

export const darkTheme = {
  ...designTokens,
  colors: {
    ...designTokens.colors,
    background: {
      primary: "#121212",
      secondary: "#1e1e1e",
      tertiary: "#2c2c2c",
    },
    text: {
      primary: "#ffffff",
      secondary: "#bdbdbd",
      disabled: "#757575",
    },
    border: {
      light: "#2c2c2c",
      medium: "#424242",
    },
  },
};

export type Theme = typeof lightTheme;
```

### Example 3: Component with Design System

```tsx
// components/Card/Card.tsx
import styled from "styled-components";
import { Theme } from "../../theme";

interface CardProps {
  variant?: "elevated" | "outlined" | "filled";
  padding?: keyof Theme["spacing"];
  children: React.ReactNode;
}

const StyledCard = styled.div<CardProps>`
  background-color: ${({ theme }) => theme.colors.background.primary};
  border-radius: ${({ theme }) => theme.borderRadius.lg};
  padding: ${({ theme, padding = 6 }) => theme.spacing[padding]};

  ${({ theme, variant = "elevated" }) => {
    switch (variant) {
      case "elevated":
        return `box-shadow: ${theme.shadows.md};`;
      case "outlined":
        return `border: 1px solid ${theme.colors.border.light};`;
      case "filled":
        return `background-color: ${theme.colors.background.secondary};`;
    }
  }}
`;

export function Card({ children, ...props }: CardProps) {
  return <StyledCard {...props}>{children}</StyledCard>;
}
```

### Example 4: Responsive Design with Tokens

```tsx
// components/Container/Container.tsx
import styled from "styled-components";

const Container = styled.div`
  width: 100%;
  margin-inline: auto;
  padding-inline: ${({ theme }) => theme.spacing[4]};

  /* Responsive breakpoints using design tokens */
  @media (min-width: 640px) {
    max-width: 640px;
    padding-inline: ${({ theme }) => theme.spacing[6]};
  }

  @media (min-width: 768px) {
    max-width: 768px;
  }

  @media (min-width: 1024px) {
    max-width: 1024px;
    padding-inline: ${({ theme }) => theme.spacing[8]};
  }

  @media (min-width: 1280px) {
    max-width: 1280px;
  }
`;

export default Container;
```

## Common Pitfalls and Solutions

### Pitfall 1: Too Many Token Variations

**Problem**: Creating too many similar tokens makes the system hard to use.

```javascript
// ❌ Bad: Too granular
const colors = {
  blue50: "#e3f2fd",
  blue75: "#d1e9fc",
  blue100: "#bbdefb",
  blue125: "#a8d5fa",
  // ... 20 more shades
};
```

**Solution**: Stick to a consistent scale (50, 100, 200, etc.).

```javascript
// ✅ Good: Clear, consistent scale
const colors = {
  blue: {
    50: "#e3f2fd",
    100: "#bbdefb",
    200: "#90caf9",
    // ... standard scale
  },
};
```

### Pitfall 2: Inconsistent Naming

**Problem**: Mixing naming conventions confuses developers.

```javascript
// ❌ Bad: Inconsistent naming
const tokens = {
  primaryColor: "#2196f3",
  text_secondary: "#757575",
  "spacing-large": "2rem",
};
```

**Solution**: Choose one convention and stick to it.

```javascript
// ✅ Good: Consistent camelCase
const tokens = {
  colorPrimary: "#2196f3",
  colorTextSecondary: "#757575",
  spacingLarge: "2rem",
};
```

### Pitfall 3: Not Documenting Token Usage

**Problem**: Developers don't know which token to use when.

**Solution**: Document semantic meaning and use cases.

```typescript
// ✅ Good: Clear documentation
const colors = {
  // Primary brand color - use for main CTAs, links, focus states
  primary: {
    500: "#2196f3",
  },

  // Success color - use for positive feedback, success messages
  success: "#4caf50",

  // Error color - use for error states, destructive actions
  error: "#f44336",
};
```

### Pitfall 4: Hardcoding Values in Components

**Problem**: Bypassing the design system defeats its purpose.

```tsx
// ❌ Bad: Hardcoded values
const Button = styled.button`
  padding: 12px 24px;
  background: #2196f3;
  border-radius: 8px;
`;
```

**Solution**: Always use design tokens.

```tsx
// ✅ Good: Using tokens
const Button = styled.button`
  padding: ${({ theme }) => `${theme.spacing[3]} ${theme.spacing[6]}`};
  background: ${({ theme }) => theme.colors.primary[500]};
  border-radius: ${({ theme }) => theme.borderRadius.lg};
`;
```

### Pitfall 5: Not Planning for Dark Mode

**Problem**: Adding dark mode later requires refactoring everything.

**Solution**: Use semantic color tokens from the start.

```typescript
// ✅ Good: Semantic tokens support theming
const theme = {
  colors: {
    background: {
      primary: "#ffffff", // Changes to #121212 in dark mode
      secondary: "#f5f5f5", // Changes to #1e1e1e in dark mode
    },
    text: {
      primary: "#212121", // Changes to #ffffff in dark mode
      secondary: "#757575", // Changes to #bdbdbd in dark mode
    },
  },
};
```

### Pitfall 6: Over-Engineering

**Problem**: Creating overly complex systems that are hard to use.

**Solution**: Start simple, add complexity only when needed.

```typescript
// ✅ Good: Start with essentials
const tokens = {
  colors: {
    /* core colors */
  },
  spacing: {
    /* 8-10 values */
  },
  typography: {
    /* 6-8 sizes */
  },
};

// Add more as needed:
// - borderRadius
// - shadows
// - transitions
```

## Tools and Resources

### Design Token Tools

**Token Management**:

- [Style Dictionary](https://amzn.github.io/style-dictionary/) - Transform design tokens to multiple platforms
- [Theo](https://github.com/salesforce-ux/theo) - Design token toolkit from Salesforce
- [Figma Tokens](https://www.figma.com/community/plugin/843461159747178978/Figma-Tokens) - Sync tokens between Figma and code

**Color Tools**:

- [Coolors](https://coolors.co/) - Color palette generator
- [Palettte](https://palettte.app/) - Build smooth color palettes
- [UI Colors](https://uicolors.app/create) - Tailwind-style color palette generator
- [Contrast Ratio](https://contrast-ratio.com/) - Check WCAG color contrast

**Typography Tools**:

- [Type Scale](https://typescale.com/) - Generate modular typography scales
- [Modular Scale](https://www.modularscale.com/) - Calculate harmonious type scales
- [Archetype](https://archetypeapp.com/) - Typography testing tool

### Component Documentation

**Storybook**:

- [Storybook](https://storybook.js.org/) - UI component explorer
- [Storybook Addons](https://storybook.js.org/addons) - Accessibility, responsive, dark mode testing

**Alternative Documentation Tools**:

- [Docz](https://www.docz.site/) - Documentation with MDX
- [Styleguidist](https://react-styleguidist.js.org/) - React component documentation
- [Docusaurus](https://docusaurus.io/) - Documentation websites

### Design System Examples

**Open Source Design Systems**:

- [Material Design](https://m3.material.io/) - Google's design system
- [Ant Design](https://ant.design/) - Enterprise design system
- [Atlassian Design System](https://atlassian.design/) - Comprehensive design system
- [Polaris](https://polaris.shopify.com/) - Shopify's design system
- [Carbon Design System](https://carbondesignsystem.com/) - IBM's design system
- [Primer](https://primer.style/) - GitHub's design system
- [Fluent UI](https://developer.microsoft.com/en-us/fluentui) - Microsoft's design system

**Design System Showcases**:

- [Design Systems Repo](https://designsystemsrepo.com/) - Collection of design systems
- [Adele](https://adele.uxpin.com/) - Repository of design systems

### Learning Resources

**Books**:

- "Design Systems" by Alla Kholmatova
- "Atomic Design" by Brad Frost
- "Refactoring UI" by Adam Wathan & Steve Schoger

**Articles**:

- [Design Systems Handbook](https://www.designbetter.co/design-systems-handbook) - InVision
- [Building a Design System](https://www.smashingmagazine.com/design-systems-book/) - Smashing Magazine
- [Design Tokens](https://css-tricks.com/what-are-design-tokens/) - CSS-Tricks

**Courses**:

- [Design Systems with React](https://frontendmasters.com/courses/design-systems/) - Frontend Masters
- [Advanced Design Systems](https://www.leveluptutorials.com/tutorials/design-systems-with-react) - Level Up Tutorials

### Community

**Slack Communities**:

- [Design Systems Slack](https://design-systems.slack.com/)
- [Figma Community](https://www.figma.com/community)

**Conferences**:

- [Clarity Conference](https://www.clarityconf.com/) - Design systems conference
- [Design Systems London](https://www.designsystemslondon.com/)

## Quick Reference

### Design Token Checklist

When creating a design system, ensure you have:

- [ ] Color palette with 9-11 shades per color
- [ ] Semantic color tokens (success, error, warning, info)
- [ ] Neutral/gray scale (9-11 shades)
- [ ] Typography scale (6-8 font sizes)
- [ ] Font weight scale (4-6 weights)
- [ ] Spacing scale (8-12 values)
- [ ] Border radius tokens (5-7 values)
- [ ] Shadow tokens (4-6 levels)
- [ ] Transition/animation tokens

### Component Documentation Checklist

Each component should have:

- [ ] Overview and purpose
- [ ] Visual variants
- [ ] Interactive states
- [ ] Props/API documentation
- [ ] Accessibility notes
- [ ] Code examples
- [ ] Do's and don'ts
- [ ] Related components

### Consistency Maintenance Checklist

- [ ] Design token linting rules configured
- [ ] Component templates available
- [ ] Storybook or documentation site set up
- [ ] Governance process defined
- [ ] Regular design system audits scheduled
- [ ] Team training materials created
- [ ] Migration guides for updates
- [ ] Usage analytics tracking

## Summary

A well-implemented design system provides:

1. **Consistency**: Unified visual language across products
2. **Efficiency**: Faster development with reusable components
3. **Scalability**: Easy to maintain as products grow
4. **Quality**: Accessibility and best practices built-in
5. **Collaboration**: Shared language between design and development

**Key Principles**:

- Start with design tokens (colors, typography, spacing)
- Build components using tokens
- Document everything thoroughly
- Maintain consistency through automation
- Iterate based on team feedback
- Plan for theming from the start

**Remember**: A design system is never "done"—it evolves with your product and team needs. Start simple, document well, and grow systematically.
