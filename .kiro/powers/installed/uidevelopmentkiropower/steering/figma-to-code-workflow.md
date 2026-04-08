# Figma to Code Workflow

## Overview

This guide provides a systematic approach to converting Figma designs into production-ready React components. Use this guidance when working with Figma designs, extracting design tokens, mapping components, or maintaining design-code consistency.

## Design-to-Code Process

### 1. Design Analysis Phase

Before writing any code, analyze the Figma design to understand:

- **Component hierarchy**: Identify reusable components vs. one-off elements
- **Design tokens**: Colors, typography, spacing, shadows, borders
- **Responsive behavior**: How layouts adapt across breakpoints
- **Interactive states**: Hover, focus, active, disabled, error states
- **Accessibility requirements**: Color contrast, focus indicators, ARIA needs

### 2. Design Token Extraction

Extract design tokens systematically to ensure consistency:

**Colors**:

```typescript
// Extract from Figma color styles
export const colors = {
  primary: {
    50: "#f0f9ff",
    100: "#e0f2fe",
    500: "#0ea5e9",
    600: "#0284c7",
    900: "#0c4a6e",
  },
  neutral: {
    50: "#fafafa",
    100: "#f5f5f5",
    500: "#737373",
    900: "#171717",
  },
  semantic: {
    success: "#10b981",
    warning: "#f59e0b",
    error: "#ef4444",
    info: "#3b82f6",
  },
};
```

**Typography**:

```typescript
// Extract from Figma text styles
export const typography = {
  fontFamily: {
    sans: ["Inter", "system-ui", "sans-serif"],
    mono: ["Fira Code", "monospace"],
  },
  fontSize: {
    xs: "0.75rem", // 12px
    sm: "0.875rem", // 14px
    base: "1rem", // 16px
    lg: "1.125rem", // 18px
    xl: "1.25rem", // 20px
    "2xl": "1.5rem", // 24px
    "3xl": "1.875rem", // 30px
  },
  fontWeight: {
    normal: 400,
    medium: 500,
    semibold: 600,
    bold: 700,
  },
  lineHeight: {
    tight: 1.25,
    normal: 1.5,
    relaxed: 1.75,
  },
};
```

**Spacing**:

```typescript
// Extract from Figma auto-layout spacing
export const spacing = {
  0: "0",
  1: "0.25rem", // 4px
  2: "0.5rem", // 8px
  3: "0.75rem", // 12px
  4: "1rem", // 16px
  6: "1.5rem", // 24px
  8: "2rem", // 32px
  12: "3rem", // 48px
  16: "4rem", // 64px
};
```

**Shadows**:

```typescript
// Extract from Figma effects
export const shadows = {
  sm: "0 1px 2px 0 rgb(0 0 0 / 0.05)",
  md: "0 4px 6px -1px rgb(0 0 0 / 0.1)",
  lg: "0 10px 15px -3px rgb(0 0 0 / 0.1)",
  xl: "0 20px 25px -5px rgb(0 0 0 / 0.1)",
};
```

### 3. Component Mapping Strategy

Map Figma components to React components systematically:

**Atomic Components** (Buttons, Inputs, Icons):

- Create one React component per Figma component
- Support all variants defined in Figma
- Include all interactive states

**Composite Components** (Cards, Forms, Navigation):

- Break down into smaller atomic components
- Use composition over duplication
- Maintain Figma's component hierarchy

**Layout Components** (Grids, Containers, Sections):

- Extract auto-layout properties (flex direction, gap, padding)
- Convert to CSS Grid or Flexbox
- Ensure responsive behavior

## Code Examples: Converting Figma to React

### Example 1: Button Component

**Figma Design**:

- Component with variants: primary, secondary, outline
- Sizes: small, medium, large
- States: default, hover, focus, disabled

**React Implementation**:

```tsx
import { cva, type VariantProps } from "class-variance-authority";

const buttonVariants = cva(
  // Base styles
  "inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
  {
    variants: {
      variant: {
        primary:
          "bg-primary-600 text-white hover:bg-primary-700 focus-visible:ring-primary-600",
        secondary:
          "bg-neutral-100 text-neutral-900 hover:bg-neutral-200 focus-visible:ring-neutral-500",
        outline:
          "border-2 border-primary-600 text-primary-600 hover:bg-primary-50 focus-visible:ring-primary-600",
      },
      size: {
        small: "h-8 px-3 text-sm",
        medium: "h-10 px-4 text-base",
        large: "h-12 px-6 text-lg",
      },
    },
    defaultVariants: {
      variant: "primary",
      size: "medium",
    },
  }
);

interface ButtonProps
  extends React.ButtonHTMLAttributes<HTMLButtonElement>,
    VariantProps<typeof buttonVariants> {
  children: React.ReactNode;
}

export function Button({
  variant,
  size,
  className,
  children,
  ...props
}: ButtonProps) {
  return (
    <button className={buttonVariants({ variant, size, className })} {...props}>
      {children}
    </button>
  );
}
```

### Example 2: Card Component with Auto-Layout

**Figma Design**:

- Auto-layout: vertical, 16px gap, 24px padding
- Contains: image, title, description, button
- Border radius: 12px, shadow: medium

**React Implementation**:

```tsx
interface CardProps {
  image: string;
  imageAlt: string;
  title: string;
  description: string;
  actionLabel: string;
  onAction: () => void;
}

export function Card({
  image,
  imageAlt,
  title,
  description,
  actionLabel,
  onAction,
}: CardProps) {
  return (
    <div className="flex flex-col gap-4 p-6 rounded-xl shadow-md bg-white">
      {/* Image */}
      <img
        src={image}
        alt={imageAlt}
        className="w-full h-48 object-cover rounded-lg"
      />

      {/* Content - matches Figma's 16px gap */}
      <div className="flex flex-col gap-2">
        <h3 className="text-xl font-semibold text-neutral-900">{title}</h3>
        <p className="text-base text-neutral-600 leading-relaxed">
          {description}
        </p>
      </div>

      {/* Action */}
      <Button variant="primary" onClick={onAction}>
        {actionLabel}
      </Button>
    </div>
  );
}
```

### Example 3: Responsive Grid Layout

**Figma Design**:

- Desktop: 3 columns, 24px gap
- Tablet: 2 columns, 16px gap
- Mobile: 1 column, 12px gap

**React Implementation**:

```tsx
interface GridProps {
  children: React.ReactNode;
}

export function ResponsiveGrid({ children }: GridProps) {
  return (
    <div className="grid grid-cols-1 gap-3 md:grid-cols-2 md:gap-4 lg:grid-cols-3 lg:gap-6">
      {children}
    </div>
  );
}

// Usage
<ResponsiveGrid>
  <Card {...cardProps1} />
  <Card {...cardProps2} />
  <Card {...cardProps3} />
</ResponsiveGrid>;
```

### Example 4: Form Input with States

**Figma Design**:

- States: default, focus, error, disabled
- Includes: label, input, helper text, error message

**React Implementation**:

```tsx
interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  helperText?: string;
  error?: string;
}

export function Input({
  label,
  helperText,
  error,
  className,
  ...props
}: InputProps) {
  const inputId = React.useId();
  const helperTextId = React.useId();
  const errorId = React.useId();

  return (
    <div className="flex flex-col gap-1.5">
      {/* Label */}
      <label htmlFor={inputId} className="text-sm font-medium text-neutral-900">
        {label}
      </label>

      {/* Input */}
      <input
        id={inputId}
        aria-describedby={
          error ? errorId : helperText ? helperTextId : undefined
        }
        aria-invalid={error ? "true" : "false"}
        className={`
          h-10 px-3 rounded-md border transition-colors
          ${
            error
              ? "border-error focus:ring-2 focus:ring-error focus:border-error"
              : "border-neutral-300 focus:ring-2 focus:ring-primary-600 focus:border-primary-600"
          }
          disabled:bg-neutral-100 disabled:cursor-not-allowed
          ${className}
        `}
        {...props}
      />

      {/* Helper text or error */}
      {error ? (
        <p id={errorId} className="text-sm text-error" role="alert">
          {error}
        </p>
      ) : helperText ? (
        <p id={helperTextId} className="text-sm text-neutral-600">
          {helperText}
        </p>
      ) : null}
    </div>
  );
}
```

### Example 5: Navigation with Figma Variants

**Figma Design**:

- Horizontal navigation
- Items have active/inactive states
- Mobile: hamburger menu

**React Implementation**:

```tsx
interface NavItem {
  label: string;
  href: string;
  icon?: React.ReactNode;
}

interface NavigationProps {
  items: NavItem[];
  activeHref: string;
}

export function Navigation({ items, activeHref }: NavigationProps) {
  const [mobileMenuOpen, setMobileMenuOpen] = React.useState(false);

  return (
    <nav className="bg-white border-b border-neutral-200">
      <div className="max-w-7xl mx-auto px-4">
        {/* Desktop Navigation */}
        <div className="hidden md:flex gap-1 h-16 items-center">
          {items.map((item) => {
            const isActive = item.href === activeHref;
            return (
              <a
                key={item.href}
                href={item.href}
                className={`
                  flex items-center gap-2 px-4 py-2 rounded-md font-medium transition-colors
                  ${
                    isActive
                      ? "bg-primary-50 text-primary-600"
                      : "text-neutral-600 hover:bg-neutral-100 hover:text-neutral-900"
                  }
                `}
                aria-current={isActive ? "page" : undefined}
              >
                {item.icon}
                {item.label}
              </a>
            );
          })}
        </div>

        {/* Mobile Navigation */}
        <div className="md:hidden">
          <button
            onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
            className="p-2"
            aria-expanded={mobileMenuOpen}
            aria-label="Toggle menu"
          >
            {/* Hamburger icon */}
            <svg
              className="w-6 h-6"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M4 6h16M4 12h16M4 18h16"
              />
            </svg>
          </button>

          {mobileMenuOpen && (
            <div className="py-2">
              {items.map((item) => {
                const isActive = item.href === activeHref;
                return (
                  <a
                    key={item.href}
                    href={item.href}
                    className={`
                      flex items-center gap-2 px-4 py-3 font-medium
                      ${
                        isActive
                          ? "bg-primary-50 text-primary-600"
                          : "text-neutral-600"
                      }
                    `}
                    aria-current={isActive ? "page" : undefined}
                  >
                    {item.icon}
                    {item.label}
                  </a>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </nav>
  );
}
```

## Using the Figma MCP Server

The Figma MCP server enables direct access to Figma files and design data:

### Accessing Design Files

```typescript
// Get file information
const fileData = await figma.getFile({
  fileKey: "your-file-key",
});

// Extract components
const components = fileData.document.children.filter(
  (node) => node.type === "COMPONENT"
);

// Get styles (colors, text styles, effects)
const styles = await figma.getFileStyles({
  fileKey: "your-file-key",
});
```

### Extracting Design Tokens

```typescript
// Extract color styles
const colorTokens = styles.meta.styles
  .filter((style) => style.style_type === "FILL")
  .map((style) => ({
    name: style.name,
    value: style.fills[0].color,
  }));

// Extract text styles
const textTokens = styles.meta.styles
  .filter((style) => style.style_type === "TEXT")
  .map((style) => ({
    name: style.name,
    fontFamily: style.fontFamily,
    fontSize: style.fontSize,
    fontWeight: style.fontWeight,
    lineHeight: style.lineHeightPx,
  }));
```

### Component Inspection

```typescript
// Get component details
const component = await figma.getComponent({
  fileKey: "your-file-key",
  nodeId: "component-node-id",
});

// Extract properties
const properties = {
  width: component.absoluteBoundingBox.width,
  height: component.absoluteBoundingBox.height,
  padding: component.paddingLeft, // if auto-layout
  gap: component.itemSpacing, // if auto-layout
  borderRadius: component.cornerRadius,
};
```

## Best Practices for Design-Code Consistency

### 1. Establish a Single Source of Truth

**DO**:

- Use Figma as the design source of truth
- Extract design tokens programmatically when possible
- Version control your design token files
- Document any deviations from Figma in code comments

**DON'T**:

- Hardcode colors, spacing, or typography values
- Create design tokens that don't exist in Figma
- Make visual changes without updating Figma first

### 2. Maintain Component Parity

**DO**:

```tsx
// ✅ Match Figma component variants exactly
<Button variant="primary" size="large">
  Click me
</Button>

// ✅ Use the same naming conventions as Figma
<Card variant="elevated" padding="comfortable">
  Content
</Card>
```

**DON'T**:

```tsx
// ❌ Create variants that don't exist in Figma
<Button variant="super-special" size="huge">
  Click me
</Button>

// ❌ Use different naming conventions
<Card type="raised" space="big">
  Content
</Card>
```

### 3. Handle Responsive Behavior Explicitly

**DO**:

```tsx
// ✅ Document responsive behavior from Figma
// Figma: Desktop (1440px) - 3 columns, Tablet (768px) - 2 columns, Mobile (375px) - 1 column
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  {items.map((item) => (
    <Card key={item.id} {...item} />
  ))}
</div>
```

**DON'T**:

```tsx
// ❌ Guess at responsive behavior
<div className="grid grid-cols-4 gap-2">
  {items.map((item) => (
    <Card key={item.id} {...item} />
  ))}
</div>
```

### 4. Preserve Accessibility from Design

**DO**:

```tsx
// ✅ Ensure Figma's color contrast is maintained
const colors = {
  // Figma: 4.8:1 contrast ratio (WCAG AA compliant)
  primary: "#0284c7",
  onPrimary: "#ffffff",
};

// ✅ Add accessibility features even if not in Figma
<button aria-label="Close dialog" className="...">
  <CloseIcon aria-hidden="true" />
</button>;
```

**DON'T**:

```tsx
// ❌ Change colors in ways that break accessibility
const colors = {
  primary: "#87ceeb", // Light blue - poor contrast!
  onPrimary: "#ffffff",
};

// ❌ Omit accessibility attributes
<button className="...">
  <CloseIcon />
</button>;
```

### 5. Document Design Decisions

**DO**:

```tsx
/**
 * Primary Button Component
 *
 * Figma: https://figma.com/file/abc123/Design-System?node-id=123
 *
 * Design notes:
 * - Uses primary-600 color from design tokens
 * - Height matches Figma's 40px (h-10 = 2.5rem)
 * - Border radius is 6px (rounded-md)
 * - Hover state darkens by one shade (primary-700)
 *
 * Deviations from Figma:
 * - Added focus-visible ring for keyboard accessibility (not in Figma)
 * - Added disabled state opacity (Figma shows as separate variant)
 */
export function Button({ ... }) {
  // ...
}
```

### 6. Regular Design-Code Audits

Establish a process for keeping design and code in sync:

1. **Weekly sync**: Review new Figma changes with design team
2. **Token updates**: Re-extract design tokens when Figma styles change
3. **Component audits**: Compare rendered components to Figma quarterly
4. **Visual regression tests**: Use Playwright to catch unintended changes
5. **Documentation updates**: Keep component docs in sync with Figma

### 7. Handle Design System Evolution

**When Figma changes**:

```typescript
// Version your design tokens
// tokens/v1.ts - old version
export const colorsV1 = { ... };

// tokens/v2.ts - new version
export const colorsV2 = { ... };

// Provide migration path
export function migrateToV2(component: ComponentV1): ComponentV2 {
  // Migration logic
}
```

**When code needs to diverge**:

```tsx
// Document why and link to discussion
/**
 * Note: This component uses a custom animation that doesn't exist in Figma.
 * Rationale: Improves perceived performance for data loading.
 * Discussion: https://github.com/org/repo/issues/123
 * Design team approved: 2024-01-15
 */
```

## Common Pitfalls and Solutions

### Pitfall 1: Pixel-Perfect Obsession

**Problem**: Spending excessive time matching Figma exactly, down to the pixel.

**Solution**: Focus on visual consistency, not pixel perfection. Use design tokens and let the browser handle sub-pixel rendering.

### Pitfall 2: Ignoring Figma Constraints

**Problem**: Figma shows a fixed-width design, but code needs to be responsive.

**Solution**: Collaborate with designers to understand intended responsive behavior. Document assumptions.

### Pitfall 3: Hardcoding Values

**Problem**: Copying values directly from Figma inspector into CSS.

**Solution**: Always use design tokens. If a value doesn't exist in tokens, discuss with design team.

### Pitfall 4: Missing Interactive States

**Problem**: Implementing only the default state shown in Figma.

**Solution**: Check Figma for variants and component properties. Implement all states (hover, focus, active, disabled, error).

### Pitfall 5: Accessibility Afterthought

**Problem**: Building exactly what's in Figma without considering accessibility.

**Solution**: Enhance designs with proper semantic HTML, ARIA attributes, keyboard navigation, and focus management.

## Workflow Checklist

Before starting implementation:

- [ ] Review complete Figma file, not just one frame
- [ ] Identify all component variants and states
- [ ] Extract design tokens (colors, typography, spacing)
- [ ] Note responsive behavior and breakpoints
- [ ] Check color contrast ratios
- [ ] Identify reusable components
- [ ] Clarify any ambiguous interactions with design team

During implementation:

- [ ] Use design tokens, not hardcoded values
- [ ] Match component naming to Figma
- [ ] Implement all variants and states
- [ ] Add accessibility enhancements
- [ ] Test responsive behavior at all breakpoints
- [ ] Verify color contrast meets WCAG AA
- [ ] Add keyboard navigation support

After implementation:

- [ ] Compare rendered component to Figma side-by-side
- [ ] Run accessibility audit with Lighthouse
- [ ] Test with keyboard navigation
- [ ] Test with screen reader
- [ ] Document any deviations from Figma
- [ ] Update component documentation
- [ ] Create visual regression test

## Resources

- **Figma API Documentation**: https://www.figma.com/developers/api
- **Figma Tokens Plugin**: https://www.figma.com/community/plugin/843461159747178978
- **Style Dictionary**: https://amzn.github.io/style-dictionary/ (for token transformation)
- **Figma to Code Plugins**: https://www.figma.com/community/search?model_type=public_plugins&q=code
- **Design Tokens W3C Spec**: https://design-tokens.github.io/community-group/format/
- **Component Driven Development**: https://www.componentdriven.org/
