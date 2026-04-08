# Responsive Design Patterns

## Overview

This guide provides comprehensive patterns and best practices for building responsive user interfaces that work seamlessly across all device sizes. Use this guidance when building layouts, implementing navigation, or optimizing for different screen sizes. The patterns here emphasize mobile-first development, flexible layouts, and performance-conscious responsive techniques.

## Mobile-First Principles

Mobile-first design is an approach where you design and develop for mobile devices first, then progressively enhance the experience for larger screens. This approach ensures better performance, forces prioritization of content, and results in cleaner, more maintainable code.

### Why Mobile-First?

1. **Performance**: Mobile devices have limited bandwidth and processing power. Starting mobile ensures you build lean, fast experiences
2. **Content Priority**: Limited screen space forces you to prioritize what's truly important
3. **Progressive Enhancement**: It's easier to add features for larger screens than to remove them for smaller ones
4. **User Base**: Mobile traffic often exceeds desktop traffic for many applications

### Mobile-First CSS Strategy

Write your base styles for mobile, then use `min-width` media queries to add complexity for larger screens:

```css
/* Base styles - Mobile first (320px and up) */
.container {
  padding: 1rem;
  font-size: 1rem;
}

.grid {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

/* Tablet and up (768px and up) */
@media (min-width: 48rem) {
  .container {
    padding: 2rem;
  }

  .grid {
    flex-direction: row;
    flex-wrap: wrap;
  }

  .grid-item {
    flex: 1 1 calc(50% - 1rem);
  }
}

/* Desktop and up (1024px and up) */
@media (min-width: 64rem) {
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 3rem;
  }

  .grid-item {
    flex: 1 1 calc(33.333% - 1rem);
  }
}
```

### Avoid Desktop-First Anti-Pattern

❌ **Bad - Desktop-first with max-width**:

```css
/* Desktop styles */
.container {
  width: 1200px;
  padding: 3rem;
}

/* Override for mobile */
@media (max-width: 768px) {
  .container {
    width: 100%;
    padding: 1rem;
  }
}
```

✅ **Good - Mobile-first with min-width**:

```css
/* Mobile styles */
.container {
  width: 100%;
  padding: 1rem;
}

/* Enhance for desktop */
@media (min-width: 768px) {
  .container {
    max-width: 1200px;
    padding: 3rem;
  }
}
```

## Breakpoint Strategies

Breakpoints define where your layout adapts to different screen sizes. Choose breakpoints based on content needs, not specific devices.

### Recommended Breakpoint System

```css
/* Mobile: 320px - 767px (base styles, no media query needed) */

/* Tablet: 768px - 1023px */
@media (min-width: 48rem) {
  /* 768px */
}

/* Desktop: 1024px - 1439px */
@media (min-width: 64rem) {
  /* 1024px */
}

/* Large Desktop: 1440px+ */
@media (min-width: 90rem) {
  /* 1440px */
}
```

### Using rem Units for Breakpoints

Always use `rem` units for media queries to respect user font size preferences:

```css
/* ✅ Good - Uses rem (respects user preferences) */
@media (min-width: 48rem) {
  /* 768px at default 16px base */
}

/* ❌ Bad - Uses px (ignores user preferences) */
@media (min-width: 768px) {
}
```

### Content-Based Breakpoints

Add breakpoints where your content breaks, not at arbitrary device sizes:

```css
.card-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1rem;
}

/* Add breakpoint when cards have enough space */
@media (min-width: 30rem) {
  /* ~480px */
  .card-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 60rem) {
  /* ~960px */
  .card-grid {
    grid-template-columns: repeat(3, 1fr);
  }
}

@media (min-width: 80rem) {
  /* ~1280px */
  .card-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}
```

### Common Breakpoint Patterns

**Two-Column Layout**:

```css
.layout {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

@media (min-width: 64rem) {
  .layout {
    flex-direction: row;
  }

  .sidebar {
    flex: 0 0 16rem;
  }

  .main-content {
    flex: 1;
  }
}
```

**Responsive Typography**:

```css
body {
  font-size: 1rem; /* 16px */
  line-height: 1.5;
}

h1 {
  font-size: 2rem; /* 32px */
  line-height: 1.2;
}

@media (min-width: 48rem) {
  body {
    font-size: 1.125rem; /* 18px */
  }

  h1 {
    font-size: 2.5rem; /* 40px */
  }
}

@media (min-width: 64rem) {
  h1 {
    font-size: 3rem; /* 48px */
  }
}
```

## Responsive Image Techniques

Images are often the largest assets on a page. Serving appropriately sized images for each device is crucial for performance.

### Using srcset for Resolution Switching

The `srcset` attribute allows browsers to choose the most appropriate image based on screen size and pixel density:

```html
<img
  src="image-800w.jpg"
  srcset="
    image-400w.jpg   400w,
    image-800w.jpg   800w,
    image-1200w.jpg 1200w,
    image-1600w.jpg 1600w
  "
  sizes="(min-width: 64rem) 50vw, 100vw"
  alt="Descriptive alt text"
  loading="lazy"
/>
```

**Explanation**:

- `srcset`: Lists available image files with their widths
- `sizes`: Tells browser how much space image will occupy at different breakpoints
- `loading="lazy"`: Defers loading until image is near viewport

### Using picture Element for Art Direction

Use `<picture>` when you need different crops or compositions for different screen sizes:

```html
<picture>
  <!-- Mobile: Portrait crop -->
  <source
    media="(max-width: 47.99rem)"
    srcset="hero-mobile-400w.jpg 400w, hero-mobile-800w.jpg 800w"
    sizes="100vw"
  />

  <!-- Tablet: Square crop -->
  <source
    media="(min-width: 48rem) and (max-width: 63.99rem)"
    srcset="hero-tablet-800w.jpg 800w, hero-tablet-1200w.jpg 1200w"
    sizes="100vw"
  />

  <!-- Desktop: Landscape crop -->
  <source
    media="(min-width: 64rem)"
    srcset="hero-desktop-1200w.jpg 1200w, hero-desktop-1600w.jpg 1600w"
    sizes="100vw"
  />

  <!-- Fallback -->
  <img src="hero-desktop-1200w.jpg" alt="Hero image description" />
</picture>
```

### Responsive Background Images

For CSS background images, use media queries:

```css
.hero {
  background-image: url("hero-mobile.jpg");
  background-size: cover;
  background-position: center;
  min-height: 20rem;
}

@media (min-width: 48rem) {
  .hero {
    background-image: url("hero-tablet.jpg");
    min-height: 30rem;
  }
}

@media (min-width: 64rem) {
  .hero {
    background-image: url("hero-desktop.jpg");
    min-height: 40rem;
  }
}

/* High DPI screens */
@media (min-width: 64rem) and (min-resolution: 2dppx) {
  .hero {
    background-image: url("hero-desktop-2x.jpg");
  }
}
```

### Modern Image Formats

Use modern formats with fallbacks:

```html
<picture>
  <!-- WebP for browsers that support it -->
  <source type="image/webp" srcset="image.webp" />

  <!-- AVIF for even better compression -->
  <source type="image/avif" srcset="image.avif" />

  <!-- Fallback to JPEG -->
  <img src="image.jpg" alt="Description" />
</picture>
```

### Responsive Image Best Practices

1. **Always include alt text** for accessibility
2. **Use lazy loading** for images below the fold: `loading="lazy"`
3. **Specify width and height** to prevent layout shift:
   ```html
   <img src="image.jpg" width="800" height="600" alt="Description" />
   ```
4. **Optimize image quality**: 80-85% JPEG quality is usually sufficient
5. **Consider aspect ratio boxes** to prevent layout shift:

   ```css
   .image-container {
     aspect-ratio: 16 / 9;
     overflow: hidden;
   }

   .image-container img {
     width: 100%;
     height: 100%;
     object-fit: cover;
   }
   ```

## Mobile-Optimized Navigation Patterns

Navigation is one of the most challenging aspects of responsive design. Here are proven patterns for mobile navigation.

### Hamburger Menu Pattern

The most common mobile navigation pattern:

```html
<nav class="navbar">
  <div class="navbar-brand">
    <a href="/">Logo</a>
  </div>

  <button
    class="navbar-toggle"
    aria-label="Toggle navigation"
    aria-expanded="false"
    aria-controls="navbar-menu"
  >
    <span class="hamburger-icon"></span>
  </button>

  <div class="navbar-menu" id="navbar-menu">
    <ul class="navbar-nav">
      <li><a href="/about">About</a></li>
      <li><a href="/services">Services</a></li>
      <li><a href="/contact">Contact</a></li>
    </ul>
  </div>
</nav>
```

```css
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background: #fff;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.1);
}

.navbar-toggle {
  display: block;
  background: none;
  border: none;
  padding: 0.5rem;
  cursor: pointer;
}

.hamburger-icon {
  display: block;
  width: 1.5rem;
  height: 0.125rem;
  background: #333;
  position: relative;
}

.hamburger-icon::before,
.hamburger-icon::after {
  content: "";
  position: absolute;
  width: 100%;
  height: 0.125rem;
  background: #333;
  left: 0;
}

.hamburger-icon::before {
  top: -0.5rem;
}

.hamburger-icon::after {
  bottom: -0.5rem;
}

.navbar-menu {
  position: fixed;
  top: 4rem;
  left: 0;
  right: 0;
  bottom: 0;
  background: #fff;
  transform: translateX(-100%);
  transition: transform 0.3s ease;
  overflow-y: auto;
}

.navbar-menu.is-active {
  transform: translateX(0);
}

.navbar-nav {
  list-style: none;
  padding: 1rem;
  margin: 0;
}

.navbar-nav li {
  margin-bottom: 0.5rem;
}

.navbar-nav a {
  display: block;
  padding: 0.75rem 1rem;
  color: #333;
  text-decoration: none;
  font-size: 1.125rem;
}

/* Desktop: Show full navigation */
@media (min-width: 64rem) {
  .navbar-toggle {
    display: none;
  }

  .navbar-menu {
    position: static;
    transform: none;
    background: transparent;
  }

  .navbar-nav {
    display: flex;
    padding: 0;
  }

  .navbar-nav li {
    margin-bottom: 0;
    margin-left: 1rem;
  }

  .navbar-nav a {
    padding: 0.5rem;
    font-size: 1rem;
  }
}
```

### Tab Bar Pattern (Bottom Navigation)

Common in mobile apps, useful for primary navigation:

```html
<nav class="tab-bar" role="navigation" aria-label="Primary navigation">
  <a href="/" class="tab-bar-item" aria-current="page">
    <svg class="tab-bar-icon" aria-hidden="true"><!-- Home icon --></svg>
    <span class="tab-bar-label">Home</span>
  </a>
  <a href="/search" class="tab-bar-item">
    <svg class="tab-bar-icon" aria-hidden="true"><!-- Search icon --></svg>
    <span class="tab-bar-label">Search</span>
  </a>
  <a href="/profile" class="tab-bar-item">
    <svg class="tab-bar-icon" aria-hidden="true"><!-- Profile icon --></svg>
    <span class="tab-bar-label">Profile</span>
  </a>
</nav>
```

```css
.tab-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  display: flex;
  background: #fff;
  border-top: 0.0625rem solid #e0e0e0;
  padding: 0.5rem 0;
  z-index: 100;
}

.tab-bar-item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0.5rem;
  color: #666;
  text-decoration: none;
  transition: color 0.2s;
}

.tab-bar-item[aria-current="page"] {
  color: #007bff;
}

.tab-bar-icon {
  width: 1.5rem;
  height: 1.5rem;
  margin-bottom: 0.25rem;
}

.tab-bar-label {
  font-size: 0.75rem;
}

/* Hide on desktop */
@media (min-width: 64rem) {
  .tab-bar {
    display: none;
  }
}
```

### Priority+ Pattern

Shows as many items as fit, hides overflow in a "More" menu:

```html
<nav class="priority-nav">
  <ul class="priority-nav-list" id="priority-nav-list">
    <li><a href="/home">Home</a></li>
    <li><a href="/about">About</a></li>
    <li><a href="/services">Services</a></li>
    <li><a href="/portfolio">Portfolio</a></li>
    <li><a href="/blog">Blog</a></li>
    <li><a href="/contact">Contact</a></li>
  </ul>

  <button class="priority-nav-more" id="more-button" hidden>
    More
    <svg aria-hidden="true"><!-- Dropdown icon --></svg>
  </button>

  <ul class="priority-nav-dropdown" id="more-menu" hidden>
    <!-- Overflow items moved here by JavaScript -->
  </ul>
</nav>
```

This pattern requires JavaScript to detect overflow and move items dynamically.

### Accessible Navigation Best Practices

1. **Use semantic HTML**: `<nav>`, `<ul>`, `<li>`, `<a>`
2. **Provide ARIA labels**: `aria-label="Main navigation"`
3. **Indicate current page**: `aria-current="page"`
4. **Keyboard accessible**: All interactive elements must be focusable
5. **Focus management**: Trap focus in mobile menus when open
6. **Skip links**: Provide "Skip to main content" link:

   ```html
   <a href="#main-content" class="skip-link">Skip to main content</a>
   ```

   ```css
   .skip-link {
     position: absolute;
     top: -3rem;
     left: 0;
     padding: 1rem;
     background: #000;
     color: #fff;
     z-index: 1000;
   }

   .skip-link:focus {
     top: 0;
   }
   ```

## CSS Examples Using Relative Units

Relative units create flexible, accessible designs that respect user preferences.

### rem vs em vs px

- **rem**: Relative to root font size (usually 16px). Best for consistent spacing and typography
- **em**: Relative to parent font size. Best for component-specific scaling
- **px**: Absolute unit. Use sparingly for borders and shadows

### Typography with rem

```css
:root {
  font-size: 16px; /* Base size, but users can override */
}

body {
  font-size: 1rem; /* 16px */
  line-height: 1.5; /* 24px */
}

h1 {
  font-size: 2.5rem; /* 40px */
  margin-bottom: 1rem; /* 16px */
  line-height: 1.2;
}

h2 {
  font-size: 2rem; /* 32px */
  margin-bottom: 0.75rem; /* 12px */
  line-height: 1.3;
}

h3 {
  font-size: 1.5rem; /* 24px */
  margin-bottom: 0.5rem; /* 8px */
  line-height: 1.4;
}

p {
  font-size: 1rem; /* 16px */
  margin-bottom: 1rem; /* 16px */
}

small {
  font-size: 0.875rem; /* 14px */
}
```

### Spacing System with rem

```css
:root {
  --space-xs: 0.25rem; /* 4px */
  --space-sm: 0.5rem; /* 8px */
  --space-md: 1rem; /* 16px */
  --space-lg: 1.5rem; /* 24px */
  --space-xl: 2rem; /* 32px */
  --space-2xl: 3rem; /* 48px */
  --space-3xl: 4rem; /* 64px */
}

.card {
  padding: var(--space-lg);
  margin-bottom: var(--space-md);
  border-radius: 0.5rem;
}

.button {
  padding: var(--space-sm) var(--space-md);
  margin-right: var(--space-sm);
}

.section {
  padding: var(--space-2xl) var(--space-md);
}

@media (min-width: 64rem) {
  .section {
    padding: var(--space-3xl) var(--space-xl);
  }
}
```

### Component Scaling with em

Use `em` for components that should scale proportionally:

```css
.button {
  font-size: 1rem;
  padding: 0.5em 1em; /* Scales with font-size */
  border-radius: 0.25em;
  border: 0.0625em solid currentColor;
}

.button-large {
  font-size: 1.25rem; /* Padding automatically scales */
}

.button-small {
  font-size: 0.875rem; /* Padding automatically scales */
}
```

### Flexible Layouts with Relative Units

```css
.container {
  width: 100%;
  max-width: 75rem; /* 1200px */
  margin: 0 auto;
  padding: 0 1rem;
}

@media (min-width: 48rem) {
  .container {
    padding: 0 2rem;
  }
}

.grid {
  display: grid;
  gap: 1.5rem;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 18rem), 1fr));
}

.card {
  padding: 1.5rem;
  border-radius: 0.5rem;
}

.card-title {
  font-size: 1.25rem;
  margin-bottom: 0.75rem;
}

.card-content {
  font-size: 1rem;
  line-height: 1.6;
}
```

### When to Use px

Use pixels for:

- **Borders**: `border: 1px solid #ccc;`
- **Box shadows**: `box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);`
- **Very small values**: `border-radius: 2px;`

Avoid pixels for:

- Font sizes
- Padding and margins
- Layout dimensions
- Media query breakpoints

## Responsive Layout Patterns

### Fluid Grid with CSS Grid

```css
.grid-auto {
  display: grid;
  gap: 1.5rem;
  grid-template-columns: repeat(auto-fit, minmax(min(100%, 20rem), 1fr));
}
```

This creates a responsive grid that:

- Fits as many columns as possible
- Each column is at least 20rem wide
- On mobile, falls back to single column
- No media queries needed!

### Sidebar Layout

```css
.layout {
  display: grid;
  gap: 2rem;
  grid-template-columns: 1fr;
}

@media (min-width: 64rem) {
  .layout {
    grid-template-columns: 16rem 1fr;
  }

  .layout-reverse {
    grid-template-columns: 1fr 16rem;
  }
}
```

### Holy Grail Layout

```css
.holy-grail {
  display: grid;
  min-height: 100vh;
  grid-template-rows: auto 1fr auto;
  grid-template-columns: 1fr;
}

.header {
  grid-column: 1 / -1;
}

.main {
  display: grid;
  gap: 2rem;
  padding: 2rem 1rem;
}

.footer {
  grid-column: 1 / -1;
}

@media (min-width: 64rem) {
  .main {
    grid-template-columns: 12rem 1fr 12rem;
    padding: 2rem;
  }
}
```

## Testing Responsive Designs

### Browser DevTools

1. **Chrome DevTools**: Toggle device toolbar (Cmd/Ctrl + Shift + M)
2. **Test multiple viewports**: iPhone, iPad, Desktop
3. **Test orientation**: Portrait and landscape
4. **Test zoom levels**: 100%, 150%, 200%

### Responsive Testing Checklist

- [ ] Test on actual devices (not just emulators)
- [ ] Test with different font sizes (browser zoom)
- [ ] Test with slow network (throttling)
- [ ] Verify images load appropriately for each breakpoint
- [ ] Check navigation works on touch devices
- [ ] Verify no horizontal scrolling on mobile
- [ ] Test form inputs on mobile keyboards
- [ ] Check touch target sizes (minimum 44x44px)
- [ ] Verify readable text without zooming (minimum 16px)
- [ ] Test landscape orientation on mobile

## Best Practices Summary

1. **Always start mobile-first** - Design and code for small screens first
2. **Use relative units** - rem for spacing/typography, em for component scaling
3. **Choose content-based breakpoints** - Not device-specific sizes
4. **Optimize images** - Use srcset, picture, and modern formats
5. **Make navigation accessible** - Keyboard support, ARIA labels, focus management
6. **Test on real devices** - Emulators don't catch everything
7. **Respect user preferences** - Font size, reduced motion, color schemes
8. **Avoid fixed widths** - Use max-width instead of width
9. **Use flexible layouts** - CSS Grid and Flexbox over floats
10. **Performance matters** - Lazy load images, minimize CSS, avoid layout shifts

## Resources

- [MDN: Responsive Design](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Responsive_Design)
- [Web.dev: Responsive Images](https://web.dev/responsive-images/)
- [A Complete Guide to CSS Media Queries](https://css-tricks.com/a-complete-guide-to-css-media-queries/)
- [Responsive Design Patterns](https://responsivedesign.is/patterns/)
- [Every Layout](https://every-layout.dev/) - Modern CSS layout patterns
- [Inclusive Components](https://inclusive-components.design/) - Accessible component patterns
