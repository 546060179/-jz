# Performance Optimization

## Overview

This guide provides comprehensive performance optimization strategies for building fast, responsive user interfaces. Use this guidance when implementing UI components, animations, images, or any feature where performance impacts user experience. The patterns here emphasize perceived performance, efficient rendering, and resource optimization to ensure your interfaces feel instant and responsive across all devices.

## UI Performance Considerations

Performance is not just about load time—it's about how fast your interface feels to users. A performant UI responds immediately to user input, animates smoothly, and never feels sluggish or unresponsive.

### Core Web Vitals

Google's Core Web Vitals are key metrics for measuring user experience:

**Largest Contentful Paint (LCP)**: Measures loading performance

- **Target**: < 2.5 seconds
- **What it measures**: Time until largest content element is visible
- **How to improve**: Optimize images, reduce server response time, eliminate render-blocking resources

**First Input Delay (FID)**: Measures interactivity

- **Target**: < 100 milliseconds
- **What it measures**: Time from user interaction to browser response
- **How to improve**: Break up long JavaScript tasks, use web workers, defer non-critical JavaScript

**Cumulative Layout Shift (CLS)**: Measures visual stability

- **Target**: < 0.1
- **What it measures**: Sum of all unexpected layout shifts
- **How to improve**: Set image/video dimensions, avoid inserting content above existing content, use CSS transforms

**Interaction to Next Paint (INP)**: Measures overall responsiveness

- **Target**: < 200 milliseconds
- **What it measures**: Latency of all user interactions
- **How to improve**: Optimize event handlers, reduce JavaScript execution time, use requestIdleCallback

### Performance Budget

Establish performance budgets to maintain fast experiences:

```javascript
// Example performance budget
const performanceBudget = {
  // Resource sizes
  javascript: "200 KB", // Total JS bundle size
  css: "50 KB", // Total CSS size
  images: "500 KB", // Total image size per page
  fonts: "100 KB", // Total font files

  // Timing metrics
  firstContentfulPaint: "1.5s",
  largestContentfulPaint: "2.5s",
  timeToInteractive: "3.5s",
  totalBlockingTime: "300ms",

  // Resource counts
  requests: 50, // Maximum HTTP requests
  domNodes: 1500, // Maximum DOM elements
};
```

### Measuring Performance

**Using Lighthouse**:

```bash
# Run Lighthouse audit
npx lighthouse https://your-site.com --view

# Run with specific categories
npx lighthouse https://your-site.com --only-categories=performance --view
```

**Using Web Vitals Library**:

```javascript
import { onCLS, onFID, onLCP, onINP } from "web-vitals";

function sendToAnalytics(metric) {
  // Send to your analytics endpoint
  console.log(metric);
}

onCLS(sendToAnalytics);
onFID(sendToAnalytics);
onLCP(sendToAnalytics);
onINP(sendToAnalytics);
```

**Using Performance API**:

```javascript
// Measure custom timing
performance.mark("component-render-start");

// ... render component ...

performance.mark("component-render-end");
performance.measure(
  "component-render",
  "component-render-start",
  "component-render-end"
);

const measure = performance.getEntriesByName("component-render")[0];
console.log(`Component rendered in ${measure.duration}ms`);
```

### React Performance Profiling

```javascript
import { Profiler } from "react";

function onRenderCallback(
  id, // Component identifier
  phase, // "mount" or "update"
  actualDuration, // Time spent rendering
  baseDuration, // Estimated time without memoization
  startTime, // When render started
  commitTime, // When render committed
  interactions // Set of interactions
) {
  console.log(`${id} (${phase}) took ${actualDuration}ms`);
}

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <YourComponent />
    </Profiler>
  );
}
```

## Image Optimization

Images are typically the largest assets on a page. Optimizing them is crucial for performance.

### Image Format Selection

Choose the right format for each use case:

| Format   | Best For                    | Pros                                    | Cons                            |
| -------- | --------------------------- | --------------------------------------- | ------------------------------- |
| **AVIF** | Photos, complex images      | Best compression, supports transparency | Limited browser support         |
| **WebP** | Photos, graphics            | Excellent compression, wide support     | Not supported in older browsers |
| **JPEG** | Photos                      | Universal support, good compression     | No transparency                 |
| **PNG**  | Graphics with transparency  | Lossless, transparency support          | Large file sizes                |
| **SVG**  | Icons, logos, illustrations | Scalable, small file size               | Not suitable for photos         |

### Modern Image Format Implementation

```html
<picture>
  <!-- AVIF: Best compression (newest browsers) -->
  <source type="image/avif" srcset="image.avif" />

  <!-- WebP: Great compression (modern browsers) -->
  <source type="image/webp" srcset="image.webp" />

  <!-- JPEG: Fallback (all browsers) -->
  <img
    src="image.jpg"
    alt="Description"
    width="800"
    height="600"
    loading="lazy"
  />
</picture>
```

### Responsive Images with srcset

Serve appropriately sized images for different screen sizes:

```html
<img
  src="image-800w.jpg"
  srcset="
    image-400w.jpg   400w,
    image-800w.jpg   800w,
    image-1200w.jpg 1200w,
    image-1600w.jpg 1600w
  "
  sizes="(min-width: 1024px) 50vw, 100vw"
  alt="Responsive image"
  width="800"
  height="600"
  loading="lazy"
/>
```

**Explanation**:

- `srcset`: Available image sizes
- `sizes`: How much viewport width the image occupies
- `width`/`height`: Prevents layout shift
- `loading="lazy"`: Defers loading until near viewport

### Lazy Loading Images

**Native Lazy Loading**:

```html
<!-- ✅ Good: Native lazy loading -->
<img src="image.jpg" alt="Description" loading="lazy" />

<!-- ✅ Good: Eager loading for above-the-fold images -->
<img src="hero.jpg" alt="Hero image" loading="eager" />
```

**Intersection Observer for Advanced Control**:

```javascript
// Custom lazy loading with Intersection Observer
const imageObserver = new IntersectionObserver(
  (entries, observer) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        const img = entry.target;
        img.src = img.dataset.src;
        img.classList.remove("lazy");
        observer.unobserve(img);
      }
    });
  },
  {
    rootMargin: "50px", // Load 50px before entering viewport
  }
);

document.querySelectorAll("img.lazy").forEach((img) => {
  imageObserver.observe(img);
});
```

```html
<img
  data-src="image.jpg"
  alt="Description"
  class="lazy"
  src="placeholder.jpg"
/>
```

### Image Optimization Best Practices

1. **Compress images**: Use tools like ImageOptim, Squoosh, or Sharp
2. **Set explicit dimensions**: Prevents layout shift
3. **Use appropriate quality**: 80-85% JPEG quality is usually sufficient
4. **Lazy load below-the-fold images**: Use `loading="lazy"`
5. **Serve scaled images**: Don't serve 2000px images for 400px containers
6. **Use CDN**: Serve images from CDN with automatic optimization
7. **Implement blur-up technique**: Show low-quality placeholder while loading

**Blur-up Placeholder Example**:

```css
.image-container {
  position: relative;
  overflow: hidden;
}

.image-placeholder {
  position: absolute;
  inset: 0;
  filter: blur(10px);
  transform: scale(1.1);
  transition: opacity 0.3s;
}

.image-placeholder.loaded {
  opacity: 0;
}

.image-actual {
  width: 100%;
  height: auto;
  display: block;
}
```

```javascript
const img = document.querySelector(".image-actual");
const placeholder = document.querySelector(".image-placeholder");

img.addEventListener("load", () => {
  placeholder.classList.add("loaded");
});
```

### Image Optimization Tools

**Build-time Optimization**:

```bash
# Using Sharp (Node.js)
npm install sharp

# Using next/image (Next.js)
import Image from 'next/image';

<Image
  src="/image.jpg"
  alt="Description"
  width={800}
  height={600}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,..."
/>
```

**Automated Optimization Services**:

- Cloudinary
- Imgix
- ImageKit
- Cloudflare Images

## Performant Animation Patterns

Animations can make interfaces feel responsive and delightful, but poorly implemented animations cause jank and sluggishness.

### The 60fps Rule

For smooth animations, you need to render a new frame every 16.67ms (60 frames per second). The browser has about 10-12ms per frame after accounting for overhead.

### CSS Properties and Performance

Not all CSS properties are equal when it comes to performance:

**✅ Cheap to Animate (GPU-accelerated)**:

- `transform` (translate, scale, rotate)
- `opacity`

**⚠️ Expensive to Animate (triggers layout/paint)**:

- `width`, `height`
- `top`, `left`, `right`, `bottom`
- `margin`, `padding`
- `border`
- `font-size`
- `background-color` (triggers paint)

### Use Transform Instead of Position

❌ **Bad - Animates position (triggers layout)**:

```css
.box {
  position: absolute;
  left: 0;
  transition: left 0.3s;
}

.box:hover {
  left: 100px; /* Triggers layout recalculation */
}
```

✅ **Good - Animates transform (GPU-accelerated)**:

```css
.box {
  transform: translateX(0);
  transition: transform 0.3s;
}

.box:hover {
  transform: translateX(100px); /* GPU-accelerated */
}
```

### Use Opacity Instead of Visibility

❌ **Bad - Animates visibility**:

```css
.modal {
  visibility: hidden;
  transition: visibility 0.3s;
}

.modal.open {
  visibility: visible;
}
```

✅ **Good - Animates opacity**:

```css
.modal {
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.3s;
}

.modal.open {
  opacity: 1;
  pointer-events: auto;
}
```

### Hardware Acceleration

Force GPU acceleration for smooth animations:

```css
.animated-element {
  /* Promote to own layer */
  will-change: transform;
  transform: translateZ(0); /* Force GPU acceleration */
}

/* Remove will-change after animation */
.animated-element.animation-complete {
  will-change: auto;
}
```

**⚠️ Warning**: Don't overuse `will-change`. It consumes memory. Only use on elements that will actually animate.

### Performant Animation Examples

**Smooth Fade In**:

```css
@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.fade-in {
  animation: fadeIn 0.3s ease-out;
}
```

**Smooth Scale on Hover**:

```css
.card {
  transition: transform 0.2s ease-out;
}

.card:hover {
  transform: scale(1.05);
}
```

**Smooth Slide-in Menu**:

```css
.menu {
  transform: translateX(-100%);
  transition: transform 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.menu.open {
  transform: translateX(0);
}
```

**Loading Spinner**:

```css
@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.spinner {
  animation: spin 1s linear infinite;
  /* GPU acceleration */
  will-change: transform;
}
```

### Respecting User Preferences

Always respect `prefers-reduced-motion`:

```css
/* Default: animations enabled */
.animated {
  transition: transform 0.3s;
}

/* Disable animations for users who prefer reduced motion */
@media (prefers-reduced-motion: reduce) {
  .animated {
    transition: none;
    animation: none;
  }
}
```

**JavaScript Implementation**:

```javascript
const prefersReducedMotion = window.matchMedia(
  "(prefers-reduced-motion: reduce)"
).matches;

if (!prefersReducedMotion) {
  // Enable animations
  element.classList.add("animated");
}
```

### Animation Performance Checklist

- [ ] Use `transform` and `opacity` for animations
- [ ] Avoid animating `width`, `height`, `top`, `left`
- [ ] Use `will-change` sparingly and remove after animation
- [ ] Keep animations under 300ms for UI feedback
- [ ] Test animations on low-end devices
- [ ] Respect `prefers-reduced-motion`
- [ ] Use `requestAnimationFrame` for JavaScript animations
- [ ] Avoid animating many elements simultaneously
- [ ] Use CSS animations over JavaScript when possible

## Virtualization for Large Lists

Rendering thousands of DOM elements causes performance issues. Virtualization renders only visible items.

### When to Use Virtualization

Use virtualization when:

- Rendering > 100 items
- Items have consistent or calculable heights
- Users need to scroll through large datasets
- Performance is noticeably degraded

### React Virtualization Libraries

**react-window** (recommended for most cases):

```bash
npm install react-window
```

```javascript
import { FixedSizeList } from "react-window";

function VirtualizedList({ items }) {
  const Row = ({ index, style }) => (
    <div style={style} className="list-item">
      {items[index].name}
    </div>
  );

  return (
    <FixedSizeList
      height={600} // Viewport height
      itemCount={items.length}
      itemSize={50} // Height of each item
      width="100%"
    >
      {Row}
    </FixedSizeList>
  );
}
```

**Variable Height Items**:

```javascript
import { VariableSizeList } from "react-window";

function VirtualizedVariableList({ items }) {
  const getItemSize = (index) => {
    // Return height for each item
    return items[index].height || 50;
  };

  const Row = ({ index, style }) => (
    <div style={style} className="list-item">
      {items[index].content}
    </div>
  );

  return (
    <VariableSizeList
      height={600}
      itemCount={items.length}
      itemSize={getItemSize}
      width="100%"
    >
      {Row}
    </VariableSizeList>
  );
}
```

**react-virtuoso** (easier API, auto-sizing):

```bash
npm install react-virtuoso
```

```javascript
import { Virtuoso } from "react-virtuoso";

function VirtualizedList({ items }) {
  return (
    <Virtuoso
      style={{ height: "600px" }}
      data={items}
      itemContent={(index, item) => (
        <div className="list-item">{item.name}</div>
      )}
    />
  );
}
```

### Virtualized Grid

```javascript
import { FixedSizeGrid } from "react-window";

function VirtualizedGrid({ items, columnCount }) {
  const Cell = ({ columnIndex, rowIndex, style }) => {
    const index = rowIndex * columnCount + columnIndex;
    const item = items[index];

    if (!item) return null;

    return (
      <div style={style} className="grid-item">
        {item.name}
      </div>
    );
  };

  return (
    <FixedSizeGrid
      columnCount={columnCount}
      columnWidth={200}
      height={600}
      rowCount={Math.ceil(items.length / columnCount)}
      rowHeight={200}
      width="100%"
    >
      {Cell}
    </FixedSizeGrid>
  );
}
```

### Infinite Scrolling with Virtualization

```javascript
import { Virtuoso } from "react-virtuoso";
import { useState, useCallback } from "react";

function InfiniteScrollList() {
  const [items, setItems] = useState([
    /* initial items */
  ]);
  const [hasMore, setHasMore] = useState(true);

  const loadMore = useCallback(() => {
    if (!hasMore) return;

    // Fetch more items
    fetchMoreItems().then((newItems) => {
      if (newItems.length === 0) {
        setHasMore(false);
      } else {
        setItems((prev) => [...prev, ...newItems]);
      }
    });
  }, [hasMore]);

  return (
    <Virtuoso
      style={{ height: "600px" }}
      data={items}
      endReached={loadMore}
      itemContent={(index, item) => (
        <div className="list-item">{item.name}</div>
      )}
      components={{
        Footer: () => (hasMore ? <div>Loading...</div> : null),
      }}
    />
  );
}
```

### Virtualization Best Practices

1. **Use for large lists**: > 100 items
2. **Provide consistent item sizes**: Improves performance
3. **Implement proper loading states**: Show skeletons while loading
4. **Handle keyboard navigation**: Ensure accessibility
5. **Test scroll performance**: On low-end devices
6. **Consider pagination**: For very large datasets (> 10,000 items)
7. **Cache rendered items**: Avoid re-rendering unchanged items

### Alternative: Pagination

For some use cases, pagination is better than virtualization:

```javascript
function PaginatedList({ items, itemsPerPage = 20 }) {
  const [currentPage, setCurrentPage] = useState(1);

  const startIndex = (currentPage - 1) * itemsPerPage;
  const endIndex = startIndex + itemsPerPage;
  const currentItems = items.slice(startIndex, endIndex);
  const totalPages = Math.ceil(items.length / itemsPerPage);

  return (
    <div>
      <ul>
        {currentItems.map((item) => (
          <li key={item.id}>{item.name}</li>
        ))}
      </ul>

      <div className="pagination">
        <button
          onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
          disabled={currentPage === 1}
        >
          Previous
        </button>

        <span>
          Page {currentPage} of {totalPages}
        </span>

        <button
          onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
          disabled={currentPage === totalPages}
        >
          Next
        </button>
      </div>
    </div>
  );
}
```

## Performance Testing Strategies

### Automated Performance Testing

**Lighthouse CI**:

```bash
# Install Lighthouse CI
npm install -g @lhci/cli

# Run Lighthouse CI
lhci autorun --collect.url=http://localhost:3000
```

**lighthouse-ci.json**:

```json
{
  "ci": {
    "collect": {
      "numberOfRuns": 3,
      "url": ["http://localhost:3000"]
    },
    "assert": {
      "assertions": {
        "categories:performance": ["error", { "minScore": 0.9 }],
        "categories:accessibility": ["error", { "minScore": 0.9 }],
        "first-contentful-paint": ["error", { "maxNumericValue": 2000 }],
        "largest-contentful-paint": ["error", { "maxNumericValue": 2500 }],
        "cumulative-layout-shift": ["error", { "maxNumericValue": 0.1 }]
      }
    }
  }
}
```

**Playwright Performance Testing**:

```javascript
import { test, expect } from "@playwright/test";

test("page loads within performance budget", async ({ page }) => {
  // Start performance measurement
  await page.goto("http://localhost:3000");

  // Get performance metrics
  const metrics = await page.evaluate(() => {
    const navigation = performance.getEntriesByType("navigation")[0];
    const paint = performance.getEntriesByType("paint");

    return {
      domContentLoaded:
        navigation.domContentLoadedEventEnd -
        navigation.domContentLoadedEventStart,
      loadComplete: navigation.loadEventEnd - navigation.loadEventStart,
      firstPaint: paint.find((p) => p.name === "first-paint")?.startTime,
      firstContentfulPaint: paint.find(
        (p) => p.name === "first-contentful-paint"
      )?.startTime,
    };
  });

  // Assert performance budgets
  expect(metrics.firstContentfulPaint).toBeLessThan(2000);
  expect(metrics.domContentLoaded).toBeLessThan(3000);
  expect(metrics.loadComplete).toBeLessThan(5000);
});

test("images are lazy loaded", async ({ page }) => {
  await page.goto("http://localhost:3000");

  // Check that below-the-fold images have loading="lazy"
  const lazyImages = await page.locator('img[loading="lazy"]').count();
  expect(lazyImages).toBeGreaterThan(0);
});

test("no layout shifts on load", async ({ page }) => {
  await page.goto("http://localhost:3000");

  // Wait for page to stabilize
  await page.waitForLoadState("networkidle");

  // Get CLS score
  const cls = await page.evaluate(() => {
    return new Promise((resolve) => {
      let clsScore = 0;
      const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          if (!entry.hadRecentInput) {
            clsScore += entry.value;
          }
        }
      });
      observer.observe({ type: "layout-shift", buffered: true });

      setTimeout(() => {
        observer.disconnect();
        resolve(clsScore);
      }, 3000);
    });
  });

  expect(cls).toBeLessThan(0.1);
});
```

### Manual Performance Testing

**Chrome DevTools Performance Panel**:

1. Open DevTools (F12)
2. Go to Performance tab
3. Click Record
4. Interact with your app
5. Stop recording
6. Analyze:
   - Long tasks (> 50ms)
   - Layout thrashing
   - Excessive repaints
   - JavaScript execution time

**Network Throttling**:

```javascript
// Test on slow 3G
// Chrome DevTools > Network > Throttling > Slow 3G

// Or use Lighthouse with throttling
npx lighthouse https://your-site.com --throttling.cpuSlowdownMultiplier=4
```

**CPU Throttling**:

```javascript
// Chrome DevTools > Performance > CPU: 4x slowdown
// Simulates low-end mobile devices
```

### Performance Monitoring in Production

**Real User Monitoring (RUM)**:

```javascript
import { onCLS, onFID, onLCP, onINP, onTTFB } from "web-vitals";

function sendToAnalytics({ name, value, id }) {
  // Send to your analytics service
  fetch("/analytics", {
    method: "POST",
    body: JSON.stringify({ name, value, id }),
    headers: { "Content-Type": "application/json" },
  });
}

// Monitor all Core Web Vitals
onCLS(sendToAnalytics);
onFID(sendToAnalytics);
onLCP(sendToAnalytics);
onINP(sendToAnalytics);
onTTFB(sendToAnalytics);
```

**Performance Observer API**:

```javascript
// Monitor long tasks
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.duration > 50) {
      console.warn("Long task detected:", entry);
      // Send to analytics
    }
  }
});

observer.observe({ entryTypes: ["longtask"] });
```

### Performance Testing Checklist

- [ ] Run Lighthouse audit (score > 90)
- [ ] Test on slow 3G network
- [ ] Test on low-end mobile device
- [ ] Measure Core Web Vitals in production
- [ ] Check bundle size (< 200 KB JavaScript)
- [ ] Verify images are optimized and lazy loaded
- [ ] Test with CPU throttling (4x slowdown)
- [ ] Check for layout shifts (CLS < 0.1)
- [ ] Verify animations run at 60fps
- [ ] Test large list performance (virtualization)
- [ ] Monitor performance in production (RUM)

## Additional Performance Optimizations

### Code Splitting

Split your JavaScript bundle to load only what's needed:

```javascript
// React lazy loading
import { lazy, Suspense } from "react";

const HeavyComponent = lazy(() => import("./HeavyComponent"));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <HeavyComponent />
    </Suspense>
  );
}
```

### Tree Shaking

Ensure your build tool removes unused code:

```javascript
// ✅ Good: Named imports (tree-shakeable)
import { specific, functions } from "library";

// ❌ Bad: Default import (not tree-shakeable)
import _ from "lodash";

// ✅ Good: Import specific lodash functions
import debounce from "lodash/debounce";
```

### Debouncing and Throttling

Limit expensive operations:

```javascript
// Debounce: Wait until user stops typing
import { debounce } from "lodash";

const handleSearch = debounce((query) => {
  // Expensive search operation
  searchAPI(query);
}, 300);

// Throttle: Limit execution rate
import { throttle } from "lodash";

const handleScroll = throttle(() => {
  // Expensive scroll handler
  updateScrollPosition();
}, 100);
```

### Memoization

Cache expensive computations:

```javascript
import { useMemo, useCallback } from "react";

function ExpensiveComponent({ data }) {
  // Memoize expensive calculation
  const processedData = useMemo(() => {
    return data.map((item) => expensiveTransform(item));
  }, [data]);

  // Memoize callback
  const handleClick = useCallback(() => {
    // Handle click
  }, []);

  return <div>{/* Use processedData */}</div>;
}
```

### Web Workers

Offload heavy computations to background threads:

```javascript
// worker.js
self.addEventListener("message", (e) => {
  const result = heavyComputation(e.data);
  self.postMessage(result);
});

// main.js
const worker = new Worker("worker.js");

worker.postMessage(data);

worker.addEventListener("message", (e) => {
  console.log("Result:", e.data);
});
```

## Resources

### Tools

- [Lighthouse](https://developers.google.com/web/tools/lighthouse) - Automated auditing
- [WebPageTest](https://www.webpagetest.org/) - Detailed performance testing
- [Chrome DevTools](https://developer.chrome.com/docs/devtools/) - Performance profiling
- [web-vitals](https://github.com/GoogleChrome/web-vitals) - Core Web Vitals library
- [Bundle Analyzer](https://www.npmjs.com/package/webpack-bundle-analyzer) - Visualize bundle size

### Learning Resources

- [Web.dev Performance](https://web.dev/performance/) - Comprehensive performance guides
- [MDN Performance](https://developer.mozilla.org/en-US/docs/Web/Performance) - Performance documentation
- [CSS Triggers](https://csstriggers.com/) - What CSS properties trigger layout/paint
- [High Performance Browser Networking](https://hpbn.co/) - Deep dive into performance

### Image Optimization

- [Squoosh](https://squoosh.app/) - Image compression tool
- [ImageOptim](https://imageoptim.com/) - Mac image optimizer
- [Sharp](https://sharp.pixelplumbing.com/) - Node.js image processing

### Communities

- [Web Performance Slack](https://webperformance.slack.com/) - Performance community
- [PerfPlanet](https://www.perfplanet.com/) - Performance blog

## Quick Reference: Performance Checklist

| Optimization            | Implementation                         | Impact |
| ----------------------- | -------------------------------------- | ------ |
| Image optimization      | Use WebP/AVIF, lazy loading, srcset    | High   |
| Code splitting          | Dynamic imports, route-based splitting | High   |
| Minimize JavaScript     | Tree shaking, remove unused code       | High   |
| Use transform/opacity   | Avoid animating layout properties      | High   |
| Virtualize long lists   | react-window, react-virtuoso           | High   |
| Lazy load components    | React.lazy, Suspense                   | Medium |
| Debounce/throttle       | Limit expensive operations             | Medium |
| Memoization             | useMemo, useCallback, React.memo       | Medium |
| Preload critical assets | `<link rel="preload">`                 | Medium |
| Use CDN                 | Serve static assets from CDN           | Medium |
| Compress assets         | Gzip/Brotli compression                | Low    |
| Minimize CSS            | Remove unused styles                   | Low    |
