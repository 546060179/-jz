# Micro-Interactions and Animations

## Overview

This guide covers animation and transition patterns that enhance user experience through subtle, purposeful motion. Use this when adding interactive feedback, transitions between states, or creating engaging UI animations.

## Principles of Good Animation

### 1. Purpose-Driven

Every animation should serve a purpose:

- **Feedback**: Confirm user actions
- **Guidance**: Direct attention to important elements
- **Relationships**: Show how elements relate spatially
- **Continuity**: Maintain context during transitions
- **Delight**: Add personality without distraction

### 2. Performance-First

Animations should be smooth and performant:

- Use CSS transforms and opacity (GPU-accelerated)
- Avoid animating layout properties (width, height, top, left)
- Keep animations under 60fps
- Use `will-change` sparingly for complex animations

### 3. Timing and Easing

Natural motion follows physics:

- **Duration**: 200-500ms for most UI animations
- **Easing**: Use ease-out for entrances, ease-in for exits
- **Consistency**: Similar elements should animate similarly

## CSS Animation Fundamentals

### Transitions

For simple state changes:

```css
/* Basic transition */
.button {
  background-color: #0066cc;
  transition: background-color 200ms ease-out;
}

.button:hover {
  background-color: #0052a3;
}

/* Multiple properties */
.card {
  transform: scale(1);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 200ms ease-out, box-shadow 200ms ease-out;
}

.card:hover {
  transform: scale(1.02);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}

/* Transition all (use cautiously) */
.element {
  transition: all 200ms ease-out;
}
```

### Keyframe Animations

For complex, multi-step animations:

```css
/* Define animation */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Apply animation */
.element {
  animation: fadeInUp 400ms ease-out;
}

/* With multiple steps */
@keyframes pulse {
  0%,
  100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.notification {
  animation: pulse 2s ease-in-out infinite;
}
```

### Transform Properties

GPU-accelerated properties for smooth animations:

```css
/* Translate (move) */
.slide-in {
  transform: translateX(-100%);
  transition: transform 300ms ease-out;
}

.slide-in.active {
  transform: translateX(0);
}

/* Scale (resize) */
.zoom {
  transform: scale(1);
  transition: transform 200ms ease-out;
}

.zoom:hover {
  transform: scale(1.1);
}

/* Rotate */
.spin {
  transform: rotate(0deg);
  transition: transform 300ms ease-out;
}

.spin:hover {
  transform: rotate(180deg);
}

/* Combine transforms */
.card {
  transform: translateY(0) scale(1) rotate(0deg);
  transition: transform 300ms ease-out;
}

.card:hover {
  transform: translateY(-4px) scale(1.02) rotate(1deg);
}
```

## Common Micro-Interactions

### Button Interactions

**Press Effect**:

```css
.button {
  transform: scale(1);
  transition: transform 100ms ease-out;
}

.button:active {
  transform: scale(0.95);
}
```

**Ripple Effect** (Material Design):

```jsx
function RippleButton({ children, onClick }) {
  const [ripples, setRipples] = useState([]);

  const handleClick = (e) => {
    const button = e.currentTarget;
    const rect = button.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    const ripple = { x, y, id: Date.now() };
    setRipples([...ripples, ripple]);

    setTimeout(() => {
      setRipples((ripples) => ripples.filter((r) => r.id !== ripple.id));
    }, 600);

    onClick?.(e);
  };

  return (
    <button className="ripple-button" onClick={handleClick}>
      {children}
      {ripples.map((ripple) => (
        <span
          key={ripple.id}
          className="ripple"
          style={{ left: ripple.x, top: ripple.y }}
        />
      ))}
    </button>
  );
}
```

```css
.ripple-button {
  position: relative;
  overflow: hidden;
}

.ripple {
  position: absolute;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.6);
  transform: translate(-50%, -50%) scale(0);
  animation: ripple-animation 600ms ease-out;
  pointer-events: none;
}

@keyframes ripple-animation {
  to {
    transform: translate(-50%, -50%) scale(20);
    opacity: 0;
  }
}
```

### Loading States

**Spinner**:

```css
.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid rgba(0, 0, 0, 0.1);
  border-top-color: #0066cc;
  border-radius: 50%;
  animation: spin 800ms linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}
```

**Skeleton Loading**:

```css
.skeleton {
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: loading 1.5s ease-in-out infinite;
}

@keyframes loading {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}
```

**Progress Bar**:

```jsx
function ProgressBar({ progress }) {
  return (
    <div className="progress-bar">
      <div className="progress-fill" style={{ width: `${progress}%` }} />
    </div>
  );
}
```

```css
.progress-bar {
  width: 100%;
  height: 4px;
  background: #e0e0e0;
  border-radius: 2px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background: #0066cc;
  transition: width 300ms ease-out;
}
```

### Hover Effects

**Underline Animation**:

```css
.link {
  position: relative;
  text-decoration: none;
  color: #0066cc;
}

.link::after {
  content: "";
  position: absolute;
  bottom: -2px;
  left: 0;
  width: 100%;
  height: 2px;
  background: currentColor;
  transform: scaleX(0);
  transform-origin: right;
  transition: transform 250ms ease-out;
}

.link:hover::after {
  transform: scaleX(1);
  transform-origin: left;
}
```

**Lift Effect**:

```css
.card {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  transition: transform 200ms ease-out, box-shadow 200ms ease-out;
}

.card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0, 0, 0, 0.15);
}
```

**Glow Effect**:

```css
.button {
  box-shadow: 0 0 0 0 rgba(0, 102, 204, 0.5);
  transition: box-shadow 200ms ease-out;
}

.button:hover {
  box-shadow: 0 0 0 8px rgba(0, 102, 204, 0);
}
```

### Focus States

**Accessible Focus Ring**:

```css
.button {
  outline: none;
  position: relative;
}

.button::before {
  content: "";
  position: absolute;
  inset: -4px;
  border: 2px solid #0066cc;
  border-radius: inherit;
  opacity: 0;
  transition: opacity 150ms ease-out;
}

.button:focus-visible::before {
  opacity: 1;
}
```

**Animated Focus**:

```css
.input {
  border: 2px solid #e0e0e0;
  transition: border-color 200ms ease-out;
}

.input:focus {
  border-color: #0066cc;
  outline: none;
}

/* Animated label */
.input-wrapper {
  position: relative;
}

.input-label {
  position: absolute;
  top: 50%;
  left: 12px;
  transform: translateY(-50%);
  color: #666;
  pointer-events: none;
  transition: top 200ms ease-out, font-size 200ms ease-out, color 200ms ease-out;
}

.input:focus + .input-label,
.input:not(:placeholder-shown) + .input-label {
  top: -8px;
  font-size: 0.75rem;
  color: #0066cc;
  background: white;
  padding: 0 4px;
}
```

## Page Transitions

### Fade Transitions

```jsx
import { motion, AnimatePresence } from "framer-motion";

function PageTransition({ children, location }) {
  return (
    <AnimatePresence mode="wait">
      <motion.div
        key={location}
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        transition={{ duration: 0.3 }}
      >
        {children}
      </motion.div>
    </AnimatePresence>
  );
}
```

### Slide Transitions

```jsx
function SlideTransition({ children, direction = "left" }) {
  const variants = {
    enter: {
      x: direction === "left" ? 100 : -100,
      opacity: 0,
    },
    center: {
      x: 0,
      opacity: 1,
    },
    exit: {
      x: direction === "left" ? -100 : 100,
      opacity: 0,
    },
  };

  return (
    <motion.div
      variants={variants}
      initial="enter"
      animate="center"
      exit="exit"
      transition={{ duration: 0.3, ease: "easeOut" }}
    >
      {children}
    </motion.div>
  );
}
```

## Modal and Dialog Animations

### Fade and Scale

```css
.modal-overlay {
  opacity: 0;
  transition: opacity 200ms ease-out;
}

.modal-overlay.open {
  opacity: 1;
}

.modal-content {
  transform: scale(0.9);
  opacity: 0;
  transition: transform 200ms ease-out, opacity 200ms ease-out;
}

.modal-overlay.open .modal-content {
  transform: scale(1);
  opacity: 1;
}
```

### Slide from Bottom (Mobile)

```css
.modal-mobile {
  transform: translateY(100%);
  transition: transform 300ms ease-out;
}

.modal-mobile.open {
  transform: translateY(0);
}
```

## List Animations

### Staggered Entrance

```jsx
import { motion } from "framer-motion";

function StaggeredList({ items }) {
  const container = {
    hidden: { opacity: 0 },
    show: {
      opacity: 1,
      transition: {
        staggerChildren: 0.1,
      },
    },
  };

  const item = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0 },
  };

  return (
    <motion.ul variants={container} initial="hidden" animate="show">
      {items.map((item, i) => (
        <motion.li key={i} variants={item}>
          {item}
        </motion.li>
      ))}
    </motion.ul>
  );
}
```

### Reordering Animation

```jsx
import { Reorder } from "framer-motion";

function ReorderableList({ items, setItems }) {
  return (
    <Reorder.Group values={items} onReorder={setItems}>
      {items.map((item) => (
        <Reorder.Item key={item.id} value={item}>
          {item.text}
        </Reorder.Item>
      ))}
    </Reorder.Group>
  );
}
```

## Scroll Animations

### Fade In on Scroll

```jsx
import { useInView } from "framer-motion";
import { useRef } from "react";

function FadeInOnScroll({ children }) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });

  return (
    <div
      ref={ref}
      style={{
        opacity: isInView ? 1 : 0,
        transform: isInView ? "translateY(0)" : "translateY(50px)",
        transition: "all 0.6s ease-out",
      }}
    >
      {children}
    </div>
  );
}
```

### Parallax Effect

```jsx
import { useScroll, useTransform, motion } from "framer-motion";

function ParallaxSection({ children }) {
  const { scrollYProgress } = useScroll();
  const y = useTransform(scrollYProgress, [0, 1], ["0%", "50%"]);

  return <motion.div style={{ y }}>{children}</motion.div>;
}
```

## Toast Notifications

```jsx
import { motion, AnimatePresence } from "framer-motion";

function Toast({ message, isVisible, onClose }) {
  return (
    <AnimatePresence>
      {isVisible && (
        <motion.div
          className="toast"
          initial={{ opacity: 0, y: 50, scale: 0.3 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          exit={{ opacity: 0, scale: 0.5, transition: { duration: 0.2 } }}
        >
          {message}
          <button onClick={onClose}>×</button>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
```

```css
.toast {
  position: fixed;
  bottom: 20px;
  right: 20px;
  background: #333;
  color: white;
  padding: 1rem 1.5rem;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}
```

## Performance Optimization

### Use will-change Sparingly

```css
/* ❌ Bad: Always on */
.element {
  will-change: transform;
}

/* ✅ Good: Only when needed */
.element:hover {
  will-change: transform;
}

.element {
  transition: transform 200ms ease-out;
}
```

### Prefer Transform and Opacity

```css
/* ❌ Bad: Triggers layout */
.element {
  transition: width 200ms, height 200ms, top 200ms, left 200ms;
}

/* ✅ Good: GPU-accelerated */
.element {
  transition: transform 200ms, opacity 200ms;
}
```

### Use transform3d for Hardware Acceleration

```css
/* Force GPU acceleration */
.element {
  transform: translate3d(0, 0, 0);
}
```

### Reduce Motion for Accessibility

```css
/* Respect user preferences */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

```jsx
// React implementation
function AnimatedComponent() {
  const prefersReducedMotion = window.matchMedia(
    "(prefers-reduced-motion: reduce)"
  ).matches;

  const duration = prefersReducedMotion ? 0 : 0.3;

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      transition={{ duration }}
    >
      Content
    </motion.div>
  );
}
```

## Animation Libraries

### Framer Motion

Modern animation library for React:

```bash
npm install framer-motion
```

**Basic Usage**:

```jsx
import { motion } from "framer-motion";

function Component() {
  return (
    <motion.div
      initial={{ opacity: 0, scale: 0.8 }}
      animate={{ opacity: 1, scale: 1 }}
      exit={{ opacity: 0, scale: 0.8 }}
      transition={{ duration: 0.3 }}
    >
      Content
    </motion.div>
  );
}
```

### GSAP

Professional-grade animation library:

```bash
npm install gsap
```

**Basic Usage**:

```javascript
import gsap from "gsap";

gsap.to(".element", {
  x: 100,
  duration: 1,
  ease: "power2.out",
});
```

### React Spring

Physics-based animation library:

```bash
npm install @react-spring/web
```

**Basic Usage**:

```jsx
import { useSpring, animated } from "@react-spring/web";

function Component() {
  const springs = useSpring({
    from: { opacity: 0, transform: "translateY(50px)" },
    to: { opacity: 1, transform: "translateY(0px)" },
  });

  return <animated.div style={springs}>Content</animated.div>;
}
```

## Timing Functions

### Standard Easing Curves

```css
/* Linear - constant speed */
transition-timing-function: linear;

/* Ease - slow start, fast middle, slow end */
transition-timing-function: ease;

/* Ease-in - slow start */
transition-timing-function: ease-in;

/* Ease-out - slow end (best for entrances) */
transition-timing-function: ease-out;

/* Ease-in-out - slow start and end */
transition-timing-function: ease-in-out;
```

### Custom Cubic Bezier

```css
/* Material Design standard */
transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);

/* Material Design deceleration */
transition-timing-function: cubic-bezier(0, 0, 0.2, 1);

/* Material Design acceleration */
transition-timing-function: cubic-bezier(0.4, 0, 1, 1);

/* Bounce effect */
transition-timing-function: cubic-bezier(0.68, -0.55, 0.265, 1.55);
```

## Best Practices

### Do's

- ✅ Keep animations under 500ms for UI interactions
- ✅ Use ease-out for entrances, ease-in for exits
- ✅ Animate transform and opacity for performance
- ✅ Provide purpose for every animation
- ✅ Respect prefers-reduced-motion
- ✅ Test animations on low-end devices
- ✅ Use consistent timing across similar elements
- ✅ Provide immediate feedback for user actions
- ✅ Use subtle animations for frequent interactions
- ✅ Test with real content and data

### Don'ts

- ❌ Don't animate layout properties (width, height, top, left)
- ❌ Don't make animations too slow (> 500ms for UI)
- ❌ Don't animate everything
- ❌ Don't use animations that distract from content
- ❌ Don't forget mobile performance
- ❌ Don't ignore accessibility preferences
- ❌ Don't use animations without purpose
- ❌ Don't make users wait for animations
- ❌ Don't use different timing for similar elements
- ❌ Don't overuse will-change

## Resources

### Animation Libraries

- [Framer Motion](https://www.framer.com/motion/) - React animation library
- [GSAP](https://greensock.com/gsap/) - Professional animation platform
- [React Spring](https://www.react-spring.dev/) - Physics-based animations
- [Anime.js](https://animejs.com/) - Lightweight animation library

### Tools

- [Cubic Bezier Generator](https://cubic-bezier.com/) - Visual easing editor
- [Animista](https://animista.net/) - CSS animation library
- [LottieFiles](https://lottiefiles.com/) - Animation assets

### Learning

- [UI Animation Principles](https://www.youtube.com/watch?v=1MCJXG5z8p0) - Google I/O talk
- [The Ultimate Guide to Animations in React](https://www.joshwcomeau.com/react/animated-sparkles-in-react/) - Josh Comeau
- [Animation at Work](https://abookapart.com/products/animation-at-work) - Rachel Nabors
